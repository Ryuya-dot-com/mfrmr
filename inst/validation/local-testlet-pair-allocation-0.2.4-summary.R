# Read-only aggregation of retained fits and additional pair-scoring checkpoints.
source('inst/validation/person-estimated-calibration-0.2.4-summary.R')

summarize_testlet_pair_allocation <- function() {
  prefix <- 'inst/validation/local-testlet-pair-allocation-0.2.4'
  output <- 'validation-results/local-testlet-pair-allocation-20260917'
  plan <- readRDS(file.path(output, 'plan.rds'))
  stopifnot(identical(plan$inputs, tools::md5sum(names(plan$inputs))),
    identical(plan$sources, tools::md5sum(names(plan$sources))))
  x <- readRDS(names(plan$inputs))
  records <- lapply(plan$manifest$ID, function(id) readRDS(file.path(output, paste0(id, '-result.rds'))))
  bridge <- readRDS(file.path(output, 'bridge.rds'))
  seconds <- function(attempts) sum(vapply(attempts, function(a) a$captured$elapsed, numeric(1)))
  pair_rows <- scoring <- timing <- list()
  original_rows_equal <- targets_equal <- logical(length(records))
  for (j in seq_along(records)) {
    r <- records[[j]]; old <- x$records[[j]]; spec <- r$spec
    original_rows_equal[j] <- targets_equal[j] <- TRUE
    for (method in c('oracle', 'plugin')) {
      previous <- old[[method]]$rows
      previous <- previous[previous$Kind == 'difference', ]
      added <- r[[method]]$rows
      both <- rbind(previous, added)
      target_columns <- names(plan$targets[[j]])
      actual <- both[, target_columns]; expected <- plan$targets[[j]]
      rownames(actual) <- rownames(expected) <- NULL
      targets_equal[j] <- targets_equal[j] && identical(actual, expected)
      retained <- both[seq_len(4L), ]; rownames(retained) <- rownames(previous) <- NULL
      original_rows_equal[j] <- original_rows_equal[j] && identical(retained, previous)
      attempts <- c(old[[method]]$attempts[previous$Target], r[[method]]$attempts)
      pair_rows[[length(pair_rows) + 1L]] <- cbind(spec[rep(1L, nrow(both)), ], PairIndex = seq_len(nrow(both)), both,
        Reused = seq_len(nrow(both)) <= 4L, Seconds = vapply(attempts, seconds, numeric(1)))
      for (target in added$Target) {
        a <- r[[method]]$attempts[[target]]
        last <- tail(a, 1)[[1]]
        v <- last$captured$value
        errors <- vapply(a, function(z) z$captured$error, character(1))
        warnings <- unlist(lapply(a, function(z) z$captured$warnings))
        scoring[[length(scoring) + 1L]] <- data.frame(Cell = spec$Cell, Replicate = spec$Replicate,
          Target = target, Method = method, Attempts = length(a), Errors = sum(nzchar(errors)),
          Warnings = length(warnings), Available = added$Available[added$Target == target],
          MassError = if (is.null(v)) NA_real_ else abs(v$mass - 1),
          CDFChange = if (is.null(v)) NA_real_ else v$changes[1],
          MeanChange = if (is.null(v)) NA_real_ else v$changes[2],
          IntegrationError = if (is.null(v)) NA_real_ else v$integration_error,
          CutoffDistance = if (is.null(v)) NA_real_ else min(abs(v$cdf - c(.025, .975))))
      }
    }
    person_seconds <- sum(vapply(c('oracle', 'plugin'), function(method) {
      people <- old[[method]]$rows$Target[old[[method]]$rows$Kind == 'person']
      sum(vapply(old[[method]]$attempts[people], seconds, numeric(1)))
    }, numeric(1)))
    timing[[j]] <- cbind(spec, FitSeconds = old$fit$elapsed, ReferenceSeconds = old$reference$elapsed,
      PersonSeconds = person_seconds,
      BaseSeconds = old$fit$elapsed + old$reference$elapsed + person_seconds,
      AddedPairWallSeconds = r$elapsed)
  }
  pair_rows <- do.call(rbind, pair_rows)
  scoring <- do.call(rbind, scoring)
  timing <- do.call(rbind, timing)
  replicate_rows <- list()
  for (cell in 1:4) {
    n <- plan$manifest$N[plan$manifest$Cell == cell][1]
    for (k in plan$pair_counts[[as.character(n)]]) for (rep in 1:10) {
      selected <- pair_rows[pair_rows$Cell == cell & pair_rows$Replicate == rep & pair_rows$PairIndex <= k, ]
      oracle <- selected[selected$Method == 'oracle', ]; plugin <- selected[selected$Method == 'plugin', ]
      stopifnot(identical(oracle$Target, plugin$Target), identical(oracle$Truth, plugin$Truth))
      matched <- oracle$Available & plugin$Available
      for (metric in c('oracle_coverage', 'plugin_coverage', 'plugin_minus_oracle')) {
        if (metric == 'plugin_minus_oracle') {
          denominator <- sum(matched)
          numerator <- sum(plugin$Covered[matched] - oracle$Covered[matched])
          gain <- sum(plugin$Covered[matched] & !oracle$Covered[matched])
          loss <- sum(!plugin$Covered[matched] & oracle$Covered[matched])
        } else {
          z <- if (metric == 'oracle_coverage') oracle else plugin
          denominator <- sum(z$Available); numerator <- sum(z$Covered[z$Available])
          gain <- loss <- NA_integer_
        }
        replicate_rows[[length(replicate_rows) + 1L]] <- data.frame(Cell = cell, N = n,
          Variance = oracle$Variance[1], PairCount = k, Replicate = rep, Metric = metric,
          Assigned = k, Denominator = denominator, Numerator = numerator,
          PluginOnlyCovered = gain, OracleOnlyCovered = loss)
      }
    }
  }
  replicate_rows <- do.call(rbind, replicate_rows)
  summaries <- list()
  keys <- unique(replicate_rows[, c('Cell', 'N', 'Variance', 'PairCount', 'Metric')])
  for (j in seq_len(nrow(keys))) {
    key <- keys[j, ]
    z <- replicate_rows[replicate_rows$Cell == key$Cell & replicate_rows$PairCount == key$PairCount &
      replicate_rows$Metric == key$Metric, ]
    v <- pec_cluster(z$Numerator / pmax(z$Denominator, 1), z$Denominator)
    summaries[[j]] <- cbind(key, Datasets = nrow(z), Assigned = sum(z$Assigned),
      AvailableOrMatched = sum(z$Denominator), Numerator = sum(z$Numerator),
      PluginOnlyCovered = sum(z$PluginOnlyCovered), OracleOnlyCovered = sum(z$OracleOnlyCovered),
      Estimate = v$estimate, MCSE = v$mcse,
      AvailableAndCoveredRate = if (key$Metric == 'plugin_minus_oracle') NA_real_ else
        sum(z$Numerator) / sum(z$Assigned))
  }
  summaries <- do.call(rbind, summaries)
  baseline <- summaries[summaries$PairCount == 4L, ]
  m <- match(paste(summaries$Cell, summaries$Metric), paste(baseline$Cell, baseline$Metric))
  summaries$MCSEOverFourPairs <- ifelse(baseline$MCSE[m] > 0, summaries$MCSE / baseline$MCSE[m], NA_real_)
  planning <- cells <- list()
  keys <- unique(summaries[, c('Cell', 'N', 'Variance', 'PairCount')])
  for (j in seq_len(nrow(keys))) {
    key <- keys[j, ]; cell <- key$Cell; k <- key$PairCount
    person <- x$planning[x$planning$Cell == cell & x$planning$Stratum == 'all_persons', ]
    pair <- summaries[summaries$Cell == cell & summaries$PairCount == k, ]
    p <- rbind(data.frame(Stratum = 'all_persons', person[, c('Metric', 'Estimate', 'MCSE')]),
      data.frame(Stratum = 'pairs', pair[, c('Metric', 'Estimate', 'MCSE')]))
    p$TargetMCSE <- .005
    p$ProjectedDatasets <- ifelse(is.finite(p$MCSE) & p$MCSE > 0, ceiling(10 * (p$MCSE / .005)^2), NA_real_)
    planning[[j]] <- cbind(key[rep(1L, nrow(p)), ], p)
    t <- timing[timing$Cell == cell, ]
    z <- pair_rows[pair_rows$Cell == cell & pair_rows$PairIndex <= k, ]
    cells[[j]] <- cbind(key, MaximumProjectedDatasets = max(p$ProjectedDatasets, na.rm = TRUE),
      UninformedMetrics = sum(!is.finite(p$ProjectedDatasets)), MeanBaseSeconds = mean(t$BaseSeconds),
      MeanPairSeconds = sum(z$Seconds) / 10, MeanTotalSeconds = mean(t$BaseSeconds) + sum(z$Seconds) / 10)
  }
  planning <- do.call(rbind, planning); cells <- do.call(rbind, cells)
  allocations <- expand.grid(N24Pairs = plan$pair_counts[['24']], N120Pairs = plan$pair_counts[['120']])
  allocations <- do.call(rbind, lapply(seq_len(nrow(allocations)), function(j) {
    a <- allocations[j, ]
    z <- cells[(cells$N == 24 & cells$PairCount == a$N24Pairs) |
      (cells$N == 120 & cells$PairCount == a$N120Pairs), ]
    b <- max(200, 100 * ceiling(max(z$MaximumProjectedDatasets) / 100))
    # Supplementary theoretical benchmark, separate from the frozen pilot rule.
    # Exact oracle equal-tail coverage averages to .95 over the model, and
    # disjoint pairs are independent when calibration is fixed at the truth.
    oracle_b <- ceiling(.95 * .05 / (.005^2 * min(a$N24Pairs, a$N120Pairs)))
    adjusted <- max(b, 100 * ceiling(oracle_b / 100))
    cbind(a, DatasetsPerCell = b, TotalDatasets = 4 * b, UninformedMetrics = sum(z$UninformedMetrics),
      EstimatedSerialHours = b * sum(z$MeanTotalSeconds) / 3600,
      IdealOracleRequiredDatasets = oracle_b, BenchmarkAdjustedDatasetsPerCell = adjusted,
      BenchmarkAdjustedSerialHours = adjusted * sum(z$MeanTotalSeconds) / 3600)
  }))
  check <- function(label, pass) data.frame(Check = label, Pass = isTRUE(pass))
  old_pairs <- x$planning[x$planning$Stratum == 'pairs', ]
  m <- match(paste(baseline$Cell, baseline$Metric), paste(old_pairs$Cell, old_pairs$Metric))
  audit <- do.call(rbind, list(
    check('all 40 records retain plan and input provenance', length(records) == 40 &&
      all(vapply(seq_along(records), function(j) {
        r <- records[[j]]
        identical(r$spec, plan$manifest[j, ]) && identical(r$sources, plan$sources) &&
          identical(r$inputs, plan$inputs) && identical(r$data_hash, plan$data_hashes[j])
      }, logical(1)))),
    check('eight bridge rows and integral histories agree exactly', length(bridge$records) == 8 &&
      identical(bridge$sources, plan$sources) && identical(bridge$inputs, plan$inputs) &&
      all(vapply(bridge$records, function(b) b$rows_equal && b$attempts_equal, logical(1)))),
    check('original four pair rows retained exactly', all(original_rows_equal) && sum(pair_rows$Reused) == 320L),
    check('complete pair targets match frozen prespecified truth and membership', all(targets_equal)),
    check('each full pairing uses every person exactly once', all(vapply(seq_along(plan$targets), function(j) {
      t <- plan$targets[[j]]
      identical(sort(c(t$P1, t$P2)), seq_len(plan$manifest$N[j]))
    }, logical(1)))),
    check('additional rows and attempts have unique ownership', nrow(scoring) == 2560L &&
      nrow(pair_rows) == 2880L && !anyDuplicated(pair_rows[, c('Cell', 'Replicate', 'Method', 'Target')]) &&
      !anyDuplicated(scoring[, c('Cell', 'Replicate', 'Method', 'Target')])),
    check('all additional pairs are numerically available', all(scoring$Available)),
    check('additional scoring retains no errors or warnings', sum(scoring$Errors) == 0 && sum(scoring$Warnings) == 0),
    check('all additional scoring meets frozen continuous-CDF criteria', all(scoring$MassError <= 1e-7 &
      scoring$CDFChange <= 1e-6 & scoring$MeanChange <= 1e-6 & scoring$IntegrationError <= 1e-6 &
      scoring$CutoffDistance > 1e-6)),
    check('every summary retains all ten assigned dataset clusters', all(summaries$Datasets == 10L) &&
      all(summaries$Assigned == 10L * summaries$PairCount) && all(summaries$AvailableOrMatched <= summaries$Assigned)),
    check('equal complete denominators agree with direct dataset-mean MCSE', all(vapply(seq_len(nrow(summaries)), function(j) {
      s <- summaries[j, ]
      z <- replicate_rows[replicate_rows$Cell == s$Cell & replicate_rows$PairCount == s$PairCount &
        replicate_rows$Metric == s$Metric, ]
      if (!all(z$Denominator == s$PairCount)) return(TRUE)
      y <- z$Numerator / z$Denominator
      abs(s$Estimate - mean(y)) <= 1e-14 && abs(s$MCSE - sd(y) / sqrt(10)) <= 1e-14
    }, logical(1)))),
    check('four-pair estimates and dataset-cluster MCSE reproduce saved summary',
      max(abs(baseline$Estimate - old_pairs$Estimate[m])) <= 1e-14 && max(abs(baseline$MCSE - old_pairs$MCSE[m])) <= 1e-14),
    check('every person planning metric is reused unchanged', all(vapply(seq_len(nrow(planning)), function(j) {
      p <- planning[j, ]; if (p$Stratum != 'all_persons') return(TRUE)
      old <- x$planning[x$planning$Cell == p$Cell & x$planning$Stratum == p$Stratum & x$planning$Metric == p$Metric, ]
      identical(p$Estimate, old$Estimate) && identical(p$MCSE, old$MCSE)
    }, logical(1)))),
    check('zero or undefined MCSE is not assigned zero replication need',
      all(is.na(planning$ProjectedDatasets[!is.finite(planning$MCSE) | planning$MCSE == 0]))),
    check('paired numerator retains gains and losses separately', {
      z <- replicate_rows[replicate_rows$Metric == 'plugin_minus_oracle', ]
      all(z$Numerator == z$PluginOnlyCovered - z$OracleOnlyCovered)
    }),
    check('elapsed times are finite and nonnegative', all(is.finite(pair_rows$Seconds) & pair_rows$Seconds >= 0) &&
      all(is.finite(timing$BaseSeconds) & timing$BaseSeconds >= 0) && all(timing$AddedPairWallSeconds >= 0))))
  tables <- list(pair_rows = pair_rows, scoring = scoring, timing = timing, replicate_rows = replicate_rows,
    summaries = summaries, planning = planning, cells = cells, allocations = allocations, audit = audit)
  for (name in names(tables)) write.csv(tables[[name]], paste0(prefix, '-', name, '.csv'), row.names = FALSE)
  evidence <- c(list(plan = plan, input = x, records = records, bridge = bridge,
    analysis_specification = readLines(paste0(prefix, '.md')),
    summary_sources = tools::md5sum(c(paste0(prefix, '-summary.R'),
      'inst/validation/person-estimated-calibration-0.2.4-summary.R')), completed = Sys.time()), tables)
  saveRDS(evidence, paste0(prefix, '-evidence.rds'))
  print(audit); print(cells); print(allocations)
  stopifnot(all(audit$Pass))
  invisible(evidence)
}

if (sys.nframe() == 0L) summarize_testlet_pair_allocation()
