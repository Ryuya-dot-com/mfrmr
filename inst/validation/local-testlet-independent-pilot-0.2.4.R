# Independent data with frozen optimizer controls; numerical helpers are reused.
source('inst/validation/local-testlet-calibration-pilot-0.2.4.R')
source('inst/validation/local-testlet-optimizer-controls-0.2.4.R')

run_testlet_independent_pilot <- function(generate_only = FALSE) {
  prefix <- 'inst/validation/local-testlet-independent-pilot-0.2.4'
  output <- 'validation-results/local-testlet-independent-pilot-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  input_paths <- c('inst/validation/local-testlet-calibration-pilot-0.2.4-evidence.rds',
    'inst/validation/local-testlet-optimizer-controls-0.2.4-evidence.rds')
  pilot <- readRDS(input_paths[1])
  selection <- readRDS(input_paths[2])
  stopifnot(selection$counts$CandidateForIndependentPilot[selection$counts$Setting == 'scaled_gradient'],
    identical(selection$plan$sources, tools::md5sum(names(selection$plan$sources))))
  sources <- tools::md5sum(c(paste0(prefix, '.R'), names(selection$plan$sources)))
  inputs <- tools::md5sum(input_paths)
  plan_path <- file.path(output, 'plan.rds')
  if (file.exists(plan_path)) {
    plan <- readRDS(plan_path)
    stopifnot(identical(plan$sources, sources), identical(plan$inputs, inputs),
      identical(plan$data_hashes, tools::md5sum(names(plan$data_hashes))))
  } else {
    manifest <- pilot$plan$manifest
    manifest$Seed <- 261017000L + 1000L * manifest$Cell + manifest$Replicate
    stopifnot(!any(manifest$Seed %in% pilot$plan$manifest$Seed), !anyDuplicated(manifest$Seed))
    data_paths <- character(nrow(manifest))
    for (j in seq_len(nrow(manifest))) {
      spec <- manifest[j, ]
      generated <- testlet_pilot_generate(spec$N, spec$Variance, spec$Seed)
      stopifnot(max(generated$audit) <= 1e-12,
        identical(generated, testlet_pilot_generate(spec$N, spec$Variance, spec$Seed)))
      data_paths[j] <- file.path(output, paste0(spec$ID, '-data.rds'))
      saveRDS(generated, data_paths[j])
    }
    plan <- list(manifest = manifest, sources = sources, inputs = inputs,
      data_hashes = tools::md5sum(data_paths), start = pilot$plan$start,
      selected_setting = selection$plan$settings[selection$plan$settings$Setting == 'scaled_gradient', ],
      prior_seeds = pilot$plan$manifest$Seed, design = readLines(paste0(prefix, '.md')),
      created = Sys.time(), parent = system2('git', 'rev-parse HEAD', stdout = TRUE), session = sessionInfo())
    saveRDS(plan, plan_path)
    write.csv(manifest, paste0(prefix, '-manifest.csv'), row.names = FALSE)
  }
  if (generate_only) { cat('FROZEN', nrow(plan$manifest), 'independent datasets\n'); return(invisible(plan)) }
  for (j in seq_len(nrow(plan$manifest))) {
    spec <- plan$manifest[j, ]
    path <- file.path(output, paste0(spec$ID, '-result.rds'))
    if (file.exists(path)) {
      previous <- readRDS(path)
      stopifnot(identical(previous$sources, sources), identical(previous$inputs, inputs),
        identical(previous$data_hash, plan$data_hashes[j]))
      cat('REUSE', spec$ID, '\n'); next
    }
    generated <- readRDS(names(plan$data_hashes)[j])
    control <- list(maxit = 250L, fnscale = spec$N, factr = 0, pgtol = 5e-6 / spec$N)
    fit_path <- file.path(output, paste0(spec$ID, '-fit.rds'))
    if (file.exists(fit_path)) {
      checkpoint <- readRDS(fit_path)
      stopifnot(identical(checkpoint$sources, sources), identical(checkpoint$inputs, inputs),
        identical(checkpoint$data_hash, plan$data_hashes[j]), identical(checkpoint$control, control))
      fit <- checkpoint$fit
    } else {
      cat('FIT', spec$ID, 'N', spec$N, 'variance', spec$Variance, '\n')
      fit <- stress_capture(testlet_controlled_fit(generated$fixture, plan$start, control))
      saveRDS(list(fit = fit, control = control, sources = sources, inputs = inputs,
        data_hash = plan$data_hashes[j]), fit_path)
    }
    value <- fit$value$captured$value
    reference <- NULL
    reference_order <- NA_integer_
    differences <- rep(NA_real_, 3)
    reference_score <- NA_real_
    if (!is.null(value)) {
      reference_order <- as.integer(tail(fit$value$history[, 'Order'], 1)) + 60L
      reference <- stress_capture(testlet_estimation_evaluate(generated$fixture, value$par, reference_order))
      if (!is.null(reference$value)) {
        differences <- c(abs(value$loglik - reference$value$loglik),
          max(abs(value$moments - reference$value$moments)), max(abs(value$gradient - reference$value$gradient)))
        reference_score <- testlet_projected_score(value$par, reference$value$gradient)
      }
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
    ready <- !length(reasons)
    status <- cbind(spec, FitReady = ready, Reason = paste(reasons, collapse = ' | '),
      NativeCode = if (is.null(value)) NA_integer_ else value$convergence,
      ProjectedScore = if (is.null(value)) NA_real_ else value$projected_score,
      EstimatedVariance = if (is.null(value)) NA_real_ else value$par[6],
      BoundaryZero = if (is.null(value)) NA else value$par[6] == 0,
      Error = paste(error_text[nzchar(error_text)], collapse = ' | '), Warnings = paste(warning_text, collapse = ' | '),
      FitSeconds = fit$elapsed, ReferenceOrder = reference_order, ReferenceProjectedScore = reference_score,
      ReferenceLogLikDifference = differences[1], ReferenceMomentDifference = differences[2],
      ReferenceScoreDifference = differences[3])
    cat('SCORE', spec$ID, 'ready', ready, 'reason', status$Reason, '\n')
    oracle <- testlet_pilot_score(generated, generated$par, 'oracle')
    plugin <- testlet_pilot_score(generated, if (ready) value$par else generated$par, 'plugin',
      if (ready) '' else status$Reason)
    result <- list(spec = spec, sources = sources, inputs = inputs, data_hash = plan$data_hashes[j],
      status = status, control = control, fit = fit, reference = reference,
      oracle = oracle, plugin = plugin, finished = Sys.time())
    saveRDS(result, path)
    cat('DONE', spec$ID, 'oracle', sum(oracle$rows$Available), 'plugin', sum(plugin$rows$Available), '\n')
  }
  stopifnot(identical(sources, tools::md5sum(names(sources))), identical(inputs, tools::md5sum(names(inputs))),
    identical(plan$data_hashes, tools::md5sum(names(plan$data_hashes))))
  cat('INDEPENDENT PILOT COMPLETE: 40 datasets retained\n')
}

if (sys.nframe() == 0L) run_testlet_independent_pilot('generate' %in% commandArgs(TRUE))
