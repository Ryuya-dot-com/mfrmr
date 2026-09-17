# Fixed main study. Numerical helpers and the prespecified design are unchanged.
source('inst/validation/local-testlet-pair-allocation-0.2.4.R')
source('inst/validation/local-testlet-optimizer-controls-0.2.4.R')

testlet_main_save <- function(value, path) {
  temporary <- paste0(path, '.tmp')
  saveRDS(value, temporary)
  stopifnot(file.rename(temporary, path))
}

testlet_main_checkpoint <- function(path, identity, expression) {
  identity$stage <- basename(path)
  if (file.exists(path)) {
    old <- readRDS(path)
    stopifnot(identical(old$identity, identity))
    return(old$value)
  }
  value <- force(expression)
  testlet_main_save(list(identity = identity, value = value, saved = Sys.time()), path)
  value
}

testlet_main_targets <- function(generated, pairs) {
  people <- testlet_pilot_targets(generated)
  people <- people[people$Kind == 'person', ]
  p <- 2L * seq_len(pairs) - 1L; q <- p + 1L
  stopifnot(max(q) <= length(generated$theta))
  rbind(people, data.frame(Target = paste0('P', p, '_minus_P', q), Kind = 'difference',
    P1 = p, P2 = q, Truth = generated$theta[p] - generated$theta[q]))
}

testlet_main_status <- function(spec, fit, reference) {
  value <- fit$value$captured$value
  reference_order <- if (is.null(value)) NA_integer_ else as.integer(tail(fit$value$history[, 'Order'], 1)) + 60L
  differences <- rep(NA_real_, 3); reference_score <- NA_real_
  if (!is.null(value) && !is.null(reference$value)) {
    differences <- c(abs(value$loglik - reference$value$loglik),
      max(abs(value$moments - reference$value$moments)), max(abs(value$gradient - reference$value$gradient)))
    reference_score <- testlet_projected_score(value$par, reference$value$gradient)
  }
  reasons <- character()
  if (is.null(value)) reasons <- 'fit_error' else {
    if (value$convergence != 0) reasons <- c(reasons, paste0('native_code_', value$convergence))
    if (!is.finite(value$projected_score) || value$projected_score > 1e-5) reasons <- c(reasons, 'projected_score')
    if (value$search_boundary) reasons <- c(reasons, 'search_boundary')
    if (!all(is.finite(c(differences, reference_score))) ||
        !all(differences <= c(1e-7, 1e-7, 1e-6)) || reference_score > 1e-5)
      reasons <- c(reasons, 'reference_unresolved')
  }
  warning_text <- c(fit$warnings, fit$value$captured$warnings, reference$warnings)
  error_text <- c(fit$error, fit$value$captured$error, reference$error)
  if (length(warning_text)) reasons <- c(reasons, 'capture_warning')
  if (any(nzchar(error_text))) reasons <- unique(c(reasons, 'capture_error'))
  cbind(spec, FitReady = !length(reasons), Reason = paste(reasons, collapse = ' | '),
    NativeCode = if (is.null(value)) NA_integer_ else value$convergence,
    ProjectedScore = if (is.null(value)) NA_real_ else value$projected_score,
    EstimatedVariance = if (is.null(value)) NA_real_ else value$par[6],
    BoundaryZero = if (is.null(value)) NA else value$par[6] == 0,
    Error = paste(error_text[nzchar(error_text)], collapse = ' | '), Warnings = paste(warning_text, collapse = ' | '),
    FitSeconds = fit$elapsed, ReferenceOrder = reference_order, ReferenceProjectedScore = reference_score,
    ReferenceLogLikDifference = differences[1], ReferenceMomentDifference = differences[2],
    ReferenceScoreDifference = differences[3])
}

run_testlet_main_coverage <- function(generate_only = FALSE) {
  prefix <- 'inst/validation/local-testlet-main-coverage-0.2.4'
  output <- 'validation-results/local-testlet-main-coverage-20260917'
  frozen <- readRDS(paste0(prefix, '-plan.rds'))
  stopifnot(identical(frozen$sources, tools::md5sum(names(frozen$sources))),
    identical(frozen$inputs, tools::md5sum(names(frozen$inputs))),
    identical(frozen$design, readLines(paste0(prefix, '-protocol.md'))))
  sources <- tools::md5sum(c(paste0(prefix, '.R'), names(frozen$sources)))
  inputs <- tools::md5sum(c(paste0(prefix, '-plan.rds'), paste0(prefix, '-protocol.md'), names(frozen$inputs)))
  reporting_sources <- tools::md5sum(c(paste0(prefix, '-summary.R'),
    'inst/validation/local-testlet-calibration-pilot-0.2.4-summary.R',
    'inst/validation/person-estimated-calibration-0.2.4-summary.R'))
  stopifnot(!anyNA(c(sources, inputs, reporting_sources)))
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  lock <- file.path(output, 'run-lock')
  if (!dir.create(lock, showWarnings = FALSE)) stop('run-lock exists: inspect its PID before resuming')
  on.exit(unlink(lock, recursive = TRUE), add = TRUE)
  writeLines(as.character(Sys.getpid()), file.path(lock, 'pid'))
  identity <- list(sources = sources, inputs = inputs, reporting_sources = reporting_sources)
  testlet_main_checkpoint(file.path(output, 'source-contract.rds'), identity,
    list(started = Sys.time(), session = sessionInfo(), parent = system2('git', 'rev-parse HEAD', stdout = TRUE)))
  plan_path <- file.path(output, 'plan.rds')
  if (file.exists(plan_path)) {
    plan <- readRDS(plan_path)
    stopifnot(identical(plan$sources, sources), identical(plan$inputs, inputs),
      identical(plan$reporting_sources, reporting_sources), identical(plan$manifest, frozen$manifest),
      identical(plan$data_hashes, tools::md5sum(names(plan$data_hashes))))
  } else {
    paths <- character(nrow(frozen$manifest))
    for (j in seq_len(nrow(frozen$manifest))) {
      spec <- frozen$manifest[j, ]
      paths[j] <- file.path(output, paste0(spec$ID, '-data.rds'))
      generated <- if (file.exists(paths[j])) readRDS(paths[j]) else
        testlet_pilot_generate(spec$N, spec$Variance, spec$Seed)
      stopifnot(max(generated$audit) <= 1e-12,
        identical(generated, testlet_pilot_generate(spec$N, spec$Variance, spec$Seed)))
      if (!file.exists(paths[j])) testlet_main_save(generated, paths[j])
      if (j %% 100L == 0L) cat('GENERATED', j, '/', nrow(frozen$manifest), '\n')
    }
    plan <- list(manifest = frozen$manifest, sources = sources, inputs = inputs,
      reporting_sources = reporting_sources, data_hashes = tools::md5sum(paths),
      start = frozen$start, controls = frozen$controls, design = frozen$design,
      created = Sys.time(), session = sessionInfo())
    stopifnot(!anyNA(plan$data_hashes))
    testlet_main_save(plan, plan_path)
  }
  cat('DATA FROZEN:', nrow(plan$manifest), 'datasets; all generation identities verified\n')
  if (generate_only) return(invisible(plan))
  statuses <- vector('list', nrow(plan$manifest))
  for (j in seq_len(nrow(plan$manifest))) {
    spec <- plan$manifest[j, ]
    path <- file.path(output, paste0(spec$ID, '-result.rds'))
    key <- list(spec = spec, sources = sources, inputs = inputs, data_hash = plan$data_hashes[j])
    if (file.exists(path)) {
      old <- readRDS(path)
      stopifnot(identical(old[names(key)], key), identical(old$control, plan$controls[[j]]))
      statuses[[j]] <- old$status
      cat('REUSE', spec$ID, '\n'); next
    }
    generated <- readRDS(names(plan$data_hashes)[j])
    stage <- function(name) file.path(output, paste0(spec$ID, '-', name, '.rds'))
    cat('FIT', spec$ID, 'N', spec$N, 'variance', spec$Variance, '\n')
    fit <- testlet_main_checkpoint(stage('fit'), key,
      stress_capture(testlet_controlled_fit(generated$fixture, plan$start, plan$controls[[j]])))
    value <- fit$value$captured$value
    reference <- testlet_main_checkpoint(stage('reference'), key, if (is.null(value)) NULL else
      stress_capture(testlet_estimation_evaluate(generated$fixture, value$par,
        as.integer(tail(fit$value$history[, 'Order'], 1)) + 60L)))
    status <- testlet_main_status(spec, fit, reference)
    targets <- testlet_main_targets(generated, spec$Pairs)
    cat('SCORE', spec$ID, 'fit_ready', status$FitReady, 'reason', status$Reason, '\n')
    oracle <- testlet_main_checkpoint(stage('oracle'), key,
      testlet_allocation_score(generated, generated$par, 'oracle', targets))
    plugin <- testlet_main_checkpoint(stage('plugin'), key,
      testlet_allocation_score(generated, if (status$FitReady) value$par else generated$par, 'plugin', targets,
        if (status$FitReady) '' else status$Reason))
    stopifnot(nrow(oracle$rows) == spec$N + spec$Pairs, nrow(plugin$rows) == spec$N + spec$Pairs)
    result <- c(key, list(status = status, control = plan$controls[[j]], fit = fit, reference = reference,
      oracle = oracle, plugin = plugin, finished = Sys.time()))
    testlet_main_save(result, path)
    statuses[[j]] <- status
    cat('DONE', j, '/', nrow(plan$manifest), spec$ID, 'oracle_available', sum(oracle$rows$Available),
      'plugin_available', sum(plugin$rows$Available), '\n')
    flush.console()
  }
  stopifnot(identical(sources, tools::md5sum(names(sources))), identical(inputs, tools::md5sum(names(inputs))),
    identical(reporting_sources, tools::md5sum(names(reporting_sources))),
    identical(plan$data_hashes, tools::md5sum(names(plan$data_hashes))))
  testlet_main_save(list(status = do.call(rbind, statuses), completed = Sys.time()),
    file.path(output, 'execution-complete.rds'))
  cat('MAIN EXECUTION COMPLETE: 1200 datasets retained\n')
  source(paste0(prefix, '-summary.R'))
  summarize_testlet_main_coverage()
}

if (sys.nframe() == 0L) run_testlet_main_coverage('generate' %in% commandArgs(TRUE))
