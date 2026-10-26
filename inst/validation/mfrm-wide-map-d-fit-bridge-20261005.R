# Source/input bridge for D's 208 retained q31 two-family fit stages.
# No fitting, information calculation, numerical admission or output-stage reuse.
# Run from the development root with the retained R 4.6.1 runtime.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
script <- 'inst/validation/mfrm-wide-map-d-fit-bridge-20261005.R'
out <- 'validation-results/mfrm-wide-map-d-fit-bridge-20261005'
stopifnot(!dir.exists(out))
matched <- 'validation-results/gmfrm-adaptive-matched-20260930'
core <- 'validation-results/gmfrm-core-screen-20261001'
repair <- 'validation-results/gmfrm-adaptive-stationarity-20260930'
pilot <- 'validation-results/gmfrm-design-screen-20261001/core-pilot'
registry <- 'validation-results/mfrm-wide-map-r50-20261001/d-inputs/inputs.csv'
rows <- read.csv(registry, stringsAsFactors = FALSE)
rows <- rows[nzchar(rows$CandidateFit), ]
stopifnot(nrow(rows) == 208L, !anyDuplicated(rows[c('ConditionId', 'Replicate')]),
  all(rows$CandidateStages == 1L))
resolve <- function(x) sub('^/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/', '', x)
without_grid_attributes <- function(x) { attr(x, 'out.attrs') <- NULL; x }
bindings <- character()
verify <- function(paths, expected = NULL) {
  actual <- tools::md5sum(resolve(paths))
  stopifnot(!anyNA(actual), is.null(expected) || identical(unname(actual), unname(expected)))
  bindings <<- c(bindings, actual)
  invisible(actual)
}
source_paths <- c(script, 'DESCRIPTION', 'NAMESPACE', list.files('R', '[.]R$', full.names = TRUE),
  list.files('src', '[.](cpp|h|so)$', full.names = TRUE))
source_hashes <- tools::md5sum(source_paths)
stopifnot(!anyNA(source_hashes))
manifest_paths <- file.path(c(matched, core, pilot), 'manifest.rds')
verify(c(registry, manifest_paths, file.path(repair, 'replay-manifest.rds')))
manifests <- lapply(manifest_paths, readRDS)
names(manifests) <- c('matched', 'core', 'pilot')
old_source <- file.path(matched, 'source')
h <- manifests$matched$source_hashes
keep <- grepl('^(R/|src/|DESCRIPTION$|NAMESPACE$|inst/validation/)', names(h))
verify(file.path(old_source, names(h)[keep]), h[keep])
for (m in manifests[c('core', 'pilot')]) {
  h <- m$source_hashes
  keep <- grepl('/(R/|src/|DESCRIPTION$|NAMESPACE$|inst/validation/)', names(h))
  verify(names(h)[keep], h[keep])
}
stopifnot(unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']])) ==
  unname(manifests$matched$source_hashes['src/mfrmr.so']))
for (name in c('mml_backend.cpp', 'cpp11.cpp', 'mfrmr.so'))
  stopifnot(unname(tools::md5sum(file.path('src', name))) ==
    unname(manifests$matched$source_hashes[file.path('src', name)]))

# Compare function expressions, including default arguments, rather than text
# comments. Follow statically named package calls from the adaptive optimizer.
definitions <- function(root) {
  result <- list()
  for (path in list.files(file.path(root, 'R'), '[.]R$', full.names = TRUE))
    for (x in parse(path, keep.source = FALSE))
      if (is.call(x) && identical(x[[1L]], as.name('<-')) && is.symbol(x[[2L]]) &&
          is.call(x[[3L]]) && identical(x[[3L]][[1L]], as.name('function')))
        result[[as.character(x[[2L]])]] <- x[[3L]]
  result
}
reachable <- function(map, root) {
  seen <- character(); todo <- root
  while (length(todo)) {
    name <- todo[1L]; todo <- todo[-1L]
    if (name %in% seen || !name %in% names(map)) next
    seen <- c(seen, name)
    called <- codetools::findGlobals(eval(map[[name]], baseenv()), merge = FALSE)$functions
    todo <- union(todo, intersect(called, names(map)))
  }
  seen
}
old <- definitions(old_source); current <- definitions('.')
optimizer_functions <- union(reachable(old, 'mfrm_gmfrm_adaptive_fit'),
  reachable(current, 'mfrm_gmfrm_adaptive_fit'))
stopifnot(length(optimizer_functions) == 136L,
  all(vapply(optimizer_functions, function(n) identical(old[[n]], current[[n]]), TRUE)),
  identical(old$mfrm_fit_product_slopes, current$mfrm_fit_product_slopes))
repair_manifest <- readRDS(file.path(repair, 'replay-manifest.rds'))
verify(names(repair_manifest$input_hashes), repair_manifest$input_hashes)

# Block numerical work: the retained optimizer result is compared unchanged.
for (name in c('fit_mfrm', 'run_mfrm_optimization', 'mfrm_gmfrm_em',
               'compute_mml_parameter_covariance'))
  trace(name, tracer = quote(stop('D fit bridge must not fit or calculate information.')),
    where = asNamespace('mfrmr'), print = FALSE)
expected_replay <- list(person = 'Person', facets = c('Task', 'Rater'), score = 'Score',
  rating_min = 0, rating_max = 2, keep_original = TRUE, category_policy = 'preserve',
  model = 'GPCM', method = 'MML', step_facet = 'Rater', slope_facet = c('Task', 'Rater'),
  noncenter_facet = 'Rater', quad_points = 31L, maxit = 500L, optimizer = 'BFGS',
  mml_engine = 'direct', gpcm_mml_identification = 'fixed_standard_normal',
  mml_integration = 'adaptive', reltol = 1e-10, gpcm_mml_start = 'neutral_em')
records <- vector('list', nrow(rows))
for (i in seq_len(nrow(rows))) {
  row <- rows[i, ]
  verify(c(row$CandidateFit, row$Bundle, row$MetadataBundle),
    c(row$CandidateMD5, row$BundleMD5, row$MetadataMD5))
  saved <- readRDS(row$CandidateFit)
  parent <- if (startsWith(row$CandidateFit, paste0(matched, '/'))) 'matched' else 'core'
  stopifnot(identical(saved$job, basename(row$CandidateFit)),
    identical(saved$manifest_md5, unname(tools::md5sum(manifest_paths[match(parent, names(manifests))]))),
    identical(names(saved$stages), '31'))
  provenance <- saved$provenance
  if (provenance$kind == 'reused') {
    verify(names(provenance$files), provenance$files)
    prior <- readRDS(resolve(names(provenance$files)[1L]))
    stopifnot(identical(saved$stages[['31']]$fitting, prior$stages[['31']]$fitting))
    if (saved$job %in% repair_manifest$reused_jobs)
      stopifnot(!any(vapply(prior$stages, function(s) any(vapply(
        s$fitting$value$opt$mml_initialization$attempts, function(a)
          isTRUE(a$value$optimizer_polish$Triggered) && identical(
            a$value$optimizer_diagnostics$ConvergenceReason, 'code_zero_large_gradient'), TRUE)), TRUE)))
  } else if (provenance$kind == 'timing-pilot') {
    verify(names(provenance$source), provenance$source)
    prior <- readRDS(resolve(names(provenance$source)[1L]))
    stopifnot(identical(saved$stages, prior$stages),
      identical(prior$manifest_md5, unname(tools::md5sum(manifest_paths[3L]))))
  } else stopifnot(identical(provenance$kind, 'refit'),
    identical(provenance$source_hashes, manifests$matched$source_hashes))
  stage <- saved$stages[['31']]; fit <- stage$fitting$value
  data <- readRDS(resolve(row$Bundle))$case$data
  stopifnot(inherits(fit, 'mfrm_fit'), !nzchar(stage$fitting$error), stage$order == 31L,
    identical(without_grid_attributes(fit$gmfrm$specification$data), without_grid_attributes(data)),
    identical(fit$config$replay_inputs[names(expected_replay)], expected_replay),
    length(unique(data$Person)) == row$N, nrow(data) == row$ObservedRows,
    !anyDuplicated(data[c('Person', 'Task', 'Rater')]))
  common <- mfrmr:::mfrm_gmfrm_common_setup(data, 2)
  stopifnot(identical(common$prep$repeated_ratings, 'review'),
    identical(common$config$repeated_ratings, 'review'),
    is.null(common$config$population_spec$terms))
  # New fields describe the unchanged default and inactive population. Data-frame
  # out.attrs is expand.grid display metadata; compare every column and row label.
  prep <- common$prep; prep$repeated_ratings <- NULL
  for (field in c('data', 'omitted_data')) {
    stopifnot(identical(without_grid_attributes(prep[[field]]),
      without_grid_attributes(fit$prep[[field]])))
    prep[[field]] <- fit$prep[[field]]
  }
  stopifnot(identical(prep, fit$prep))
  cfg <- common$config; cfg$repeated_ratings <- NULL; cfg$population_spec$terms <- NULL
  stopifnot(identical(cfg, fit$config[names(cfg)]),
    identical(common$sizes, mfrmr:::build_param_sizes(fit$config)),
    identical(common$idx, mfrmr:::build_indices(fit$prep, 'Rater', c('Task', 'Rater'),
      gpcm_spec = fit$config$gpcm_spec)),
    identical(mfrmr:::gauss_hermite_normal(31L), fit$config$estimation_control$quadrature))
  records[[i]] <- data.frame(ConditionId = row$ConditionId, Replicate = row$Replicate,
    CandidateFit = row$CandidateFit, CandidateMD5 = row$CandidateMD5, Order = 31L,
    Kind = provenance$kind, FitStageCompatible = TRUE,
    FittingFingerprint = mfrmr:::mfrm_checkpoint_fingerprint(stage$fitting),
    OriginalConverged = isTRUE(fit$summary$Converged),
    OriginalSeverity = fit$opt$optimizer_diagnostics$ConvergenceSeverity,
    OldSlopeIntervalReturned = all(attr(stage$inference$value, 'diagnostics')$CIEligible),
    OutputStagesAdmitted = FALSE)
  if (i %% 25L == 0L) { cat('Checked', i, 'of 208 retained fit stages\n'); flush.console() }
}
stopifnot(identical(tools::md5sum(source_paths), source_hashes))
bindings <- bindings[!duplicated(names(bindings))]
stopifnot(identical(tools::md5sum(names(bindings)), bindings))
dir.create(out)
saveRDS(list(records = do.call(rbind, records), sources = source_hashes, inputs = bindings,
  optimizer_functions = optimizer_functions, procedure = expected_replay,
  preserved_prior_reuse = repair_manifest[c('refit_jobs', 'reused_jobs')],
  loaded_binary = tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']]),
  source_review = c('136 adaptive optimizer functions and backend are unchanged.',
    'Public two-family dispatch body is unchanged; the new outer repeated_ratings argument defaults to review.',
    'Prepared columns, row labels, indices, model parameters and quadrature agree exactly.',
    'Only inactive population terms, default repeated-rating metadata and data-frame display attributes differ.',
    'Original fitted objects and earlier stopping histories remain immutable.'),
  new_fits = 0L, new_information_calculations = 0L, new_responses = 0L,
  session = capture.output(sessionInfo()),
  scope = 'Compatibility of retained q31 fitting stages with the declared adaptive neutral_em procedure. Scoring-source checks, native location intervals and new output stages remain separate; no broad D dispatch/procedure freeze or coverage qualification follows.'),
  file.path(out, 'verified.rds'))
stopifnot(file.copy(script, file.path(out, basename(script))))
print(table(do.call(rbind, records)$Kind))
cat('All 208 retained q31 fitting stages are source/input compatible. No new fits.\n')
