# Independent precision follow-up for the unchanged N240 population intervals.
# From package root, use the retained R library and four single-thread settings.
# Phases: freeze, prepare, run 1 / run 2, summarize. Never extend by results.
precision_script <- 'inst/validation/mfrm-lr-rsm-precision-20261010.R'
precision_root <- 'validation-results/mfrm-lr-rsm-precision-20261010'
precision_original <- 'validation-results/mfrm-lr-rsm-confirmation-20261009'
source('inst/validation/mfrm-lr-rsm-confirmation-20261009.R')
for (path in rsm_confirm_helpers) source(path)

precision_protocol <- function() {
  p <- rsm_confirm_protocol()
  p$version <- 'RSM-LR-N240-independent-precision-v1'
  p$N <- 240L
  p$Replicates <- 3200L
  p$Shards <- 2L
  # The retained producer computes all six targets; only these are primary here.
  p$primary_decisions <- c('beta:X', 'contrast:difference')
  p$rationale <- paste('Independent fixed allocation, with no pooling with inspected R800 data.',
    'At 3200 returns and assumed coverage .93875, the exact-binomial probability',
    'of the unchanged 95% MC interval lying within [.92,.98] is about .984.',
    'At .95 delivery there are about 3040 returns; delivery uncertainty is reported.',
    'The two primary labels have the same coverage event, not independent replications.')
  p$secondary <- c('other four interval targets', 'initial intervals', 'scoring-source review',
    'bias', 'empirical SD', 'mean SE', 'width', 'all-attempt coverage')
  p$scope <- paste('Unchanged four-category SD1 rho.5 paired-L1 RSM at N240.',
    'This addresses the two N240 inconclusive labels only; N20 and all other model/design obligations remain.',
    'The complete existing scoring/interval producer is retained to avoid a new selection implementation.')
  p$stop <- paste('Complete exactly 3200 independent attempts. No outcome inspection or decisions before completion;',
    'no favorable stopping, automatic extension, redraw or pooling. Retain failed attempts.',
    'A further inconclusive result remains inconclusive; this allocation does not guarantee support.')
  p
}

precision_current <- function() {
  runtime <- wide_mml_runtime()
  stopifnot(all(runtime$threads == '1'))
  list(protocol = precision_protocol(), runtime = runtime,
    source = tools::md5sum(unique(c(precision_script, rsm_confirm_script,
      rsm_confirm_helpers, names(runtime$source)[names(runtime$source) != 'loaded:mfrmr']))))
}

precision_manifest <- function() {
  x <- rsm_confirm_read(file.path(precision_root, 'manifest.rds'))$payload
  stopifnot(identical(x[names(precision_current())], precision_current()))
  rsm_confirm_verify(x$evidence)
  x
}

precision_freeze <- function() {
  old <- rsm_confirm_read(file.path(precision_original, 'manifest.rds'))$payload
  now <- precision_current()
  stopifnot(identical(now$protocol$inference, old$protocol$inference),
            identical(now$protocol$criteria, old$protocol$criteria))
  # These implement estimation, source qualification, boundaries and interval selection.
  paths <- c(rsm_confirm_helpers, 'R/api-population-intervals.R',
    'R/core-native-location-inference.R', 'R/api-prediction.R')
  archived <- file.path(precision_original, 'execution-source', paths)
  old_hash <- rsm_confirm_read(file.path(precision_original, 'execution.rds'))$payload$current$source
  stopifnot(identical(unname(tools::md5sum(archived)), unname(old_hash[paths])))
  old_runtime <- rsm_confirm_read(file.path(precision_original, 'execution.rds'))$payload$current$runtime
  stopifnot(identical(now$runtime$source['loaded:mfrmr'], old_runtime$source['loaded:mfrmr']))
  for (i in seq_along(paths)) stopifnot(identical(
    parse(paths[i], keep.source = FALSE), parse(archived[i], keep.source = FALSE)))
  cost <- read.csv(file.path(precision_original, 'job-accounting.csv'))
  mean_seconds <- mean(cost$Elapsed[cost$N == 240L])
  manifest <- c(now, list(template = old$template,
    evidence = tools::md5sum(c(file.path(precision_original,
      c('manifest.rds', 'execution.rds', 'summary-verification-20261010.rds',
        'summary.rds', 'job-accounting.csv')), archived)),
    cost = list(historical_mean_worker_seconds = mean_seconds,
      projected_worker_hours = 3200 * mean_seconds / 3600,
      nominal_two_worker_hours = 1600 * mean_seconds / 3600,
      note = 'Projection from completed compatible phases; excludes added I/O/load and is not a deadline.')))
  dir.create(precision_root, recursive = TRUE, showWarnings = FALSE)
  saved <- wide_mml_phase(file.path(precision_root, 'manifest.rds'),
                          now$protocol$version, function() manifest)
  stopifnot(identical(saved, manifest))
  for (path in names(now$source)) {
    dest <- file.path(precision_root, 'source', path)
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    if (!file.exists(dest)) stopifnot(file.copy(path, dest))
    stopifnot(unname(tools::md5sum(dest)) == now$source[[path]])
  }
  cat('Frozen 3200 independent N240 attempts, unchanged procedure and criteria.\n')
  print(manifest$cost)
}

precision_prepare <- function() {
  m <- precision_manifest(); p <- m$protocol
  head_path <- 'validation-results/mfrm-wide-map-r50-20261001/rng-head.rds'
  reg_path <- file.path(precision_root, 'rng-registry.rds')
  if (!file.exists(reg_path)) {
    head <- readRDS(head_path); rsm_confirm_verify(head$registry_md5)
    previous <- readRDS(head$registry)
    stopifnot(head$next_unit_ordinal == 10331L,
              previous$next_unit_ordinal == head$next_unit_ordinal)
    units <- data.frame(Replicate = seq_len(p$Replicates), N = p$N,
                        Truth = 'S-RSM', SD = p$SD)
    units$ParentId <- sprintf('PREC-RSM:N240:rho0.5:rep%04d', units$Replicate)
    stream <- previous$next_unused_unit_stream
    streams <- lapply(seq_len(nrow(units)), function(i) {
      component <- stream; seeds <- list()
      for (name in c('ability', 'assignment', 'response', 'covariate')) {
        seeds[[name]] <- component; component <- parallel::nextRNGSubStream(component)
      }
      stream <<- parallel::nextRNGStream(stream); seeds
    })
    registry <- list(epoch = p$version, manifest = wide_mml_hash(m), predecessor = head,
      predecessor_head_md5 = tools::md5sum(head_path), units = units, streams = streams,
      first_unit_ordinal = head$next_unit_ordinal,
      next_unit_ordinal = head$next_unit_ordinal + nrow(units),
      next_unused_unit_stream = stream, RNG = c("L'Ecuyer-CMRG", 'Inversion', 'Rejection'))
    rsm_confirm_verify(registry$predecessor_head_md5)
    wide_mml_save(registry, reg_path)
  }
  registry <- readRDS(reg_path)
  stopifnot(identical(registry$manifest, wide_mml_hash(m)))
  next_head <- list(registry = reg_path, registry_md5 = tools::md5sum(reg_path),
    preceding_registry_md5 = registry$predecessor$registry_md5,
    last_reserved_unit_ordinal = registry$next_unit_ordinal - 1L,
    next_unit_ordinal = registry$next_unit_ordinal, epoch = registry$epoch,
    note = '3200 independent N240 precision-follow-up parents; no pooling or outcome-based extension.')
  head <- readRDS(head_path)
  if (identical(head, registry$predecessor)) wide_mml_save(next_head, head_path)
  else stopifnot(identical(head, next_head))
  RNGkind("L'Ecuyer-CMRG", normal.kind = 'Inversion', sample.kind = 'Rejection')
  ab_check_equation()
  dir.create(file.path(precision_root, 'bundles'), showWarnings = FALSE)
  paths <- character(nrow(registry$units))
  for (i in seq_along(paths)) {
    unit <- registry$units[i, ]; seeds <- registry$streams[[i]]
    path <- paths[i] <- file.path(precision_root, 'bundles', sprintf('parent-%04d.rds', i))
    if (!file.exists(path)) {
      ab <- ab_generate(unit, seeds); ab_check_bundle(ab, unit, seeds)
      assign('.Random.seed', seeds$covariate, .GlobalEnv); Z <- rnorm(unit$N)
      persons <- data.frame(Person = names(ab$theta),
        X = p$Rho * unname(ab$theta) / p$SD + sqrt(1-p$Rho^2) * Z)
      wide_mml_save(list(ab = ab, persons = persons, Z = Z), path)
    }
    x <- readRDS(path); ab_check_bundle(x$ab, unit, seeds)
    stopifnot(identical(x$persons$Person, names(x$ab$theta)),
      identical(x$persons$X, p$Rho * unname(x$ab$theta) / p$SD + sqrt(1-p$Rho^2) * x$Z))
  }
  x <- readRDS(paths[1]); regenerated <- ab_generate(registry$units[1, ], registry$streams[[1]])
  assign('.Random.seed', registry$streams[[1]]$covariate, .GlobalEnv)
  stopifnot(identical(x$ab, regenerated), identical(x$Z, rnorm(p$N)))
  inputs <- list(registry = tools::md5sum(reg_path), bundles = tools::md5sum(paths))
  saved <- wide_mml_phase(file.path(precision_root, 'inputs.rds'), wide_mml_hash(m), function() inputs)
  stopifnot(identical(saved, inputs))
  cat('All 3200 inputs frozen and audited; no fitting in preparation.\n')
}

precision_summarize <- function() {
  m <- precision_manifest(); p <- m$protocol
  execution <- precision_current()
  inputs <- rsm_confirm_read(file.path(precision_root, 'inputs.rds'))$payload
  rsm_confirm_verify(inputs$registry); rsm_confirm_verify(inputs$bundles)
  paths <- file.path(precision_root, 'jobs', sprintf('parent-%04d', seq_len(p$Replicates)), 'records.rds')
  stopifnot(all(file.exists(paths)))
  records <- do.call(rbind, lapply(seq_along(paths), function(i) {
    x <- rsm_confirm_read(paths[i]); dir <- dirname(paths[i])
    selected <- rsm_confirm_read(file.path(dir, 'selected.rds'))
    job <- rsm_confirm_read(file.path(dir, 'manifest.rds'))$payload
    stopifnot(identical(x$binding, list(selected = selected$checksum,
      input = inputs$bundles[i], manifest = wide_mml_hash(m), execution = wide_mml_hash(execution))))
    rebuilt <- rsm_lr_records(job$spec, selected$payload, dir)
    stopifnot(identical(rebuilt, x$payload[names(rebuilt)]))
    x$payload
  }))
  primary <- subset(records, Selection == 'selected' & Output == 'interval')
  summary <- do.call(rbind, lapply(split(primary, primary$Target), function(z) {
    stopifnot(nrow(z) == p$Replicates, !anyDuplicated(z$ParentId))
    a <- z[z$Available, ]; k <- sum(a$Covered); n <- nrow(a)
    d <- rsm_confirm_decision(nrow(z), n, k)
    # Independent beta-quantile check of the exact coverage limits.
    ci <- if (n) c(if (k == 0) 0 else qbeta(.025,k,n-k+1),
      if (k == n) 1 else qbeta(.975,k+1,n-k)) else c(NA_real_,NA_real_)
    stopifnot(isTRUE(all.equal(ci,d$coverage,tolerance=1e-13)))
    data.frame(Target = z$Target[1], Attempted = nrow(z), Returned = n, Covered = k,
      Availability = n/nrow(z), AvailabilityLower = d$availability[1], AvailabilityUpper = d$availability[2],
      Coverage = if(n) k/n else NA_real_, CoverageLower = ci[1], CoverageUpper = ci[2],
      ReturnedAndCovered = k/nrow(z), JointLower = d$joint[1], JointUpper = d$joint[2],
      Bias = if(n) mean(a$Error) else NA_real_, EmpiricalSD = if(n>1) sd(a$Error) else NA_real_,
      MeanSE = if(n) mean(a$SE) else NA_real_, MeanWidth = if(n) mean(a$Upper-a$Lower) else NA_real_,
      Decision = if(z$Target[1] %in% p$primary_decisions) d$status else 'descriptive')
  }))
  b <- subset(primary, Target == 'beta:X'); d <- subset(primary, Target == 'contrast:difference')
  d <- d[match(b$ParentId,d$ParentId), ]
  stopifnot(identical(b$Available,d$Available), identical(b$Covered,d$Covered))
  for (field in c('Estimate','SE','Lower','Upper','Truth'))
    stopifnot(isTRUE(all.equal(d[[field]],2*b[[field]],tolerance=1e-12)))
  result <- list(summary = summary, records = records, manifest = tools::md5sum(file.path(precision_root,'manifest.rds')),
    inputs = tools::md5sum(file.path(precision_root,'inputs.rds')), record_hashes = tools::md5sum(paths), session = sessionInfo())
  wide_mml_phase(file.path(precision_root,'summary.rds'), wide_mml_hash(m), function() result)
  write.csv(summary,file.path(precision_root,'summary.csv'),row.names=FALSE)
  print(summary,row.names=FALSE)
}

# Reuse the unchanged production-stage orchestrator and its record accounting.
rsm_confirm_root <- precision_root
rsm_confirm_current <- precision_current
rsm_confirm_manifest <- precision_manifest
if (sys.nframe() == 0L) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  args <- commandArgs(TRUE)
  stopifnot(length(args) >= 1L)
  switch(args[1], freeze = precision_freeze(), prepare = precision_prepare(),
    run = rsm_confirm_run(as.integer(args[2])), summarize = precision_summarize(), stop('Unknown phase'))
}
