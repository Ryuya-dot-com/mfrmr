# Shared read-only calibration-pilot aggregation; no fitting or scoring reruns.
source('inst/validation/person-estimated-calibration-0.2.4-summary.R')

testlet_pilot_summarize <- function(
    prefix = 'inst/validation/local-testlet-calibration-pilot-0.2.4',
    output = 'validation-results/local-testlet-calibration-pilot-20260917', pilot_only = TRUE) {
  plan <- readRDS(file.path(output, 'plan.rds'))
  pairs <- if ('Pairs' %in% names(plan$manifest)) plan$manifest$Pairs else rep(4L, nrow(plan$manifest))
  paths <- file.path(output, paste0(plan$manifest$ID, '-result.rds'))
  stopifnot(all(file.exists(paths)))
  records <- lapply(paths, readRDS)
  status <- do.call(rbind, lapply(records, `[[`, 'status'))
  rows <- do.call(rbind, lapply(records, function(x) cbind(Cell = x$spec$Cell,
    Replicate = x$spec$Replicate, N = x$spec$N, Variance = x$spec$Variance,
    rbind(x$oracle$rows, x$plugin$rows))))
  rows$Band <- ifelse(rows$Kind == 'difference', 'pairs', ifelse(rows$Truth < -1, 'theta_below_minus1',
    ifelse(rows$Truth > 1, 'theta_above_1', 'theta_minus1_to_1')))
  checks <- list()
  check <- function(label, condition) {
    checks[[length(checks) + 1L]] <<- data.frame(Check = label, Pass = isTRUE(condition))
  }
  check('all unique planned datasets', nrow(status) == nrow(plan$manifest) && !anyDuplicated(status$ID) &&
    identical(as.character(status$ID), as.character(plan$manifest$ID)))
  check('frozen sources and data unchanged', identical(plan$sources, tools::md5sum(names(plan$sources))) &&
    identical(plan$data_hashes, tools::md5sum(names(plan$data_hashes))))
  check('record lineage matches manifest', all(vapply(seq_along(records), function(i)
    identical(records[[i]]$sources, plan$sources) && identical(records[[i]]$data_hash, plan$data_hashes[i]), logical(1))))
  check('all attempted target rows retained', nrow(rows) == 2 * sum(plan$manifest$N + pairs) &&
    !anyDuplicated(rows[c('Cell', 'Replicate', 'Method', 'Target')]))
  check('no unavailable event relabeled as noncoverage', all(is.na(rows$Covered[!rows$Available])) &&
    all(is.finite(rows$CDF[rows$Available])))
  check('coverage follows continuous CDF event', all(rows$Covered[rows$Available] ==
    (rows$CDF[rows$Available] >= .025 & rows$CDF[rows$Available] <= .975)))
  check('nonready fits keep every plugin target unavailable', all(vapply(seq_along(records), function(i) {
    x <- records[[i]]
    x$status$FitReady || (!any(x$plugin$rows$Available) && nrow(x$plugin$rows) == x$spec$N + pairs[i])
  }, logical(1))))
  check('generator identities', all(vapply(seq_len(nrow(plan$manifest)), function(i) {
    g <- readRDS(names(plan$data_hashes)[i])
    max(g$audit) <= 1e-12 && identical(g$gamma, sqrt(g$par[6]) * g$local_normals)
  }, logical(1))))
  # Reuse the established ratio/cluster-MCSE helper, with all assigned dataset
  # clusters retained even when a stratum has zero available observations.
  ratio <- function(numerator, denominator) pec_cluster(numerator / pmax(denominator, 1), denominator)
  check('cluster MCSE helper bridge', abs(ratio(c(8, 10), c(10, 10))$estimate - .9) < 1e-12 &&
    abs(ratio(c(8, 10), c(10, 10))$mcse - .1) < 1e-12)
  check('zero-count cluster retained', length(ratio(c(2, 0, 0), c(2, 1, 0))$influence) == 3L)
  strata <- c('all_persons', 'theta_below_minus1', 'theta_minus1_to_1', 'theta_above_1', 'pairs')
  summaries <- paired <- replicate_rows <- counts <- list()
  for (cell in 1:4) {
    s <- status[status$Cell == cell, ]
    counts[[cell]] <- data.frame(Cell = cell, N = s$N[1], Variance = s$Variance[1], Planned = sum(plan$manifest$Cell == cell),
      Completed = nrow(s), FitReady = sum(s$FitReady),
      ZeroVarianceReturned = sum(s$BoundaryZero, na.rm = TRUE), ZeroVarianceReady = sum(s$BoundaryZero & s$FitReady, na.rm = TRUE),
      CaptureErrors = sum(nzchar(s$Error)), WarningTrials = sum(nzchar(s$Warnings)),
      NativeNonzero = sum(s$NativeCode != 0, na.rm = TRUE),
      ScoreNotReady = sum(grepl('projected_score', s$Reason)), MeanFitSeconds = mean(s$FitSeconds))
    for (stratum in strata) {
      all <- rows[rows$Cell == cell & (if (stratum == 'all_persons') rows$Kind == 'person' else rows$Band == stratum), ]
      for (method in c('oracle', 'plugin')) {
        z <- all[all$Method == method, ]
        per_rep <- do.call(rbind, lapply(s$Replicate, function(b) {
          v <- z[z$Replicate == b, ]
          valid <- v$Available
          data.frame(Cell = cell, Stratum = stratum, Method = method, Replicate = b,
            Attempted = nrow(v), Available = sum(valid), Covered = sum(v$Covered[valid]),
            ErrorSum = sum(v$Mean[valid] - v$Truth[valid]), SquaredErrorSum = sum((v$Mean[valid] - v$Truth[valid])^2))
        }))
        replicate_rows[[length(replicate_rows) + 1L]] <- per_rep
        availability <- ratio(per_rep$Available, per_rep$Attempted)
        coverage <- ratio(per_rep$Covered, per_rep$Available)
        covered_attempt <- ratio(per_rep$Covered, per_rep$Attempted)
        bias <- ratio(per_rep$ErrorSum, per_rep$Available)
        mse <- ratio(per_rep$SquaredErrorSum, per_rep$Available)
        summaries[[length(summaries) + 1L]] <- data.frame(Cell = cell, N = s$N[1], Variance = s$Variance[1],
          Stratum = stratum, Method = method, Replicates = nrow(s), Attempted = sum(per_rep$Attempted),
          Available = sum(per_rep$Available), Covered = sum(per_rep$Covered),
          Availability = availability$estimate, AvailabilityMCSE = availability$mcse,
          CoverageAmongAvailable = coverage$estimate, CoverageMCSE = coverage$mcse,
          CoveredPerAttempt = covered_attempt$estimate, CoveredPerAttemptMCSE = covered_attempt$mcse,
          BiasAmongAvailable = bias$estimate, RMSEAmongAvailable = sqrt(mse$estimate), PilotOnly = pilot_only)
      }
      a <- all[all$Method == 'oracle', ]
      b <- all[all$Method == 'plugin', ]
      b <- b[match(paste(a$Replicate, a$Target), paste(b$Replicate, b$Target)), ]
      stopifnot(identical(a$Truth, b$Truth), !anyNA(b$Replicate))
      both <- a$Available & b$Available
      per_rep <- do.call(rbind, lapply(s$Replicate, function(k) {
        take <- a$Replicate == k & both
        data.frame(Replicate = k, Matched = sum(take), OracleCovered = sum(a$Covered[take]),
          PluginCovered = sum(b$Covered[take]))
      }))
      difference <- ratio(per_rep$PluginCovered - per_rep$OracleCovered, per_rep$Matched)
      paired[[length(paired) + 1L]] <- data.frame(Cell = cell, N = s$N[1], Variance = s$Variance[1],
        Stratum = stratum, Replicates = nrow(s), Matched = sum(per_rep$Matched),
        OracleCoverageMatched = ratio(per_rep$OracleCovered, per_rep$Matched)$estimate,
        PluginCoverageMatched = ratio(per_rep$PluginCovered, per_rep$Matched)$estimate,
        PluginMinusOracle = difference$estimate, DifferenceMCSE = difference$mcse, PilotOnly = pilot_only)
    }
  }
  summaries <- do.call(rbind, summaries)
  paired <- do.call(rbind, paired)
  counts <- do.call(rbind, counts)
  replicate_rows <- do.call(rbind, replicate_rows)
  check('cell person/pair denominators', all(summaries$Attempted[summaries$Stratum == 'all_persons'] ==
    summaries$Replicates[summaries$Stratum == 'all_persons'] * summaries$N[summaries$Stratum == 'all_persons']) &&
    all(summaries$Attempted[summaries$Stratum == 'pairs'] ==
      summaries$Replicates[summaries$Stratum == 'pairs'] * pairs[match(summaries$Cell[summaries$Stratum == 'pairs'], plan$manifest$Cell)]))
  check('paired denominators cannot exceed either method', all(vapply(seq_len(nrow(paired)), function(i) {
    selected <- summaries[summaries$Cell == paired$Cell[i] & summaries$Stratum == paired$Stratum[i], ]
    paired$Matched[i] <= min(selected$Available)
  }, logical(1))))
  attempts <- unlist(lapply(records, function(x) c(x$oracle$attempts, x$plugin$attempts)), recursive = FALSE)
  attempts <- unlist(attempts, recursive = FALSE)
  ready <- Filter(function(x) isTRUE(x$captured$value$ready), attempts)
  scoring <- data.frame(Attempts = length(attempts), Qualified = length(ready),
    CaptureErrors = sum(vapply(attempts, function(x) nzchar(x$captured$error), logical(1))),
    WarningAttempts = sum(vapply(attempts, function(x) length(x$captured$warnings) > 0, logical(1))),
    MaxMassError = max(vapply(ready, function(x) abs(x$captured$value$mass - 1), numeric(1))),
    MaxCDFChange = max(vapply(ready, function(x) x$captured$value$changes[1], numeric(1))),
    MaxMeanChange = max(vapply(ready, function(x) x$captured$value$changes[2], numeric(1))),
    MaxIntegrationError = max(vapply(ready, function(x) x$captured$value$integration_error, numeric(1))),
    MinCutoffDistance = min(vapply(ready, function(x) min(abs(x$captured$value$cdf - c(.025, .975))), numeric(1))))
  check('saved scoring attempts satisfy numerical gates', scoring$Qualified == sum(rows$Available) &&
    scoring$MaxMassError <= 1e-7 && scoring$MaxCDFChange <= 1e-6 && scoring$MaxMeanChange <= 1e-6 &&
    scoring$MaxIntegrationError <= 1e-6 && scoring$MinCutoffDistance > 1e-6)
  audit <- do.call(rbind, checks)
  for (name in c('status', 'rows', 'counts', 'summaries', 'paired', 'replicate_rows', 'scoring', 'audit'))
    write.csv(get(name), paste0(prefix, '-', name, '.csv'), row.names = FALSE)
  summary_sources <- tools::md5sum(unique(c(if (file.exists(paste0(prefix, '-summary.R'))) paste0(prefix, '-summary.R'),
    'inst/validation/local-testlet-calibration-pilot-0.2.4-summary.R',
    'inst/validation/person-estimated-calibration-0.2.4-summary.R')))
  evidence <- list(plan = plan, summary_sources = summary_sources, status = status, rows = rows,
    counts = counts, summaries = summaries, paired = paired, replicate_rows = replicate_rows, scoring = scoring, audit = audit,
    preflight_archive = if (file.exists(file.path(output, 'initial-generation-plan.rds')))
      list(plan = readRDS(file.path(output, 'initial-generation-plan.rds')),
        source = readLines(file.path(output, 'initial-generation-runner.R'))) else NULL,
    generated = lapply(names(plan$data_hashes), readRDS), records = records, completed = Sys.time())
  saveRDS(evidence, paste0(prefix, '-evidence.rds'))
  print(counts)
  print(paired[paired$Stratum %in% c('all_persons', 'pairs'), ])
  print(scoring)
  print(audit)
  stopifnot(all(audit$Pass))
  invisible(evidence)
}

if (sys.nframe() == 0L) testlet_pilot_summarize()
