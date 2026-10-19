# Repository-only E observation-law bridge. Source the existing stage,
# recovery, interval and scoring helpers first. Three-facet output adaptation
# and missing-facet coordinate maps remain required work, not fit refusals.
wide_e_input <- function(condition, replicate,
    root = 'validation-results/mfrm-wide-map-r50-20261001/e-inputs') {
  index_path <- file.path(root, 'inputs.csv')
  verified <- readRDS(file.path(root, 'verified-inputs.rds'))
  stopifnot(identical(tools::md5sum(index_path), verified$inputs_md5))
  index <- read.csv(index_path, stringsAsFactors = FALSE)
  row <- index[index$ConditionId == condition & index$Replicate == replicate, ]
  stopifnot(nrow(row) == 1L, row$Selector == 'views[[View]]$data',
    row$CovarianceSampling == 'random_rosters',
    unname(tools::md5sum(row$Bundle)) == row$BundleMD5)
  b <- readRDS(row$Bundle); v <- b$views[[row$View]]; s <- v$spec
  stopifnot(b$unit$Replicate == replicate, b$unit$N == row$N,
    b$unit$Truth == row$Truth, b$unit$CohortId == row$CohortId,
    s$design == row$View, v$theta_key == row$ThetaKey,
    s$covariance_sampling == row$CovarianceSampling)
  if (!identical(s$facets, c('Rater', 'Criterion')))
    stop('E output bridge for Task is unfinished; retain this planned condition.')
  truth <- s$truth[c('Rater', 'Criterion', 'steps', 'log_slopes')]
  for (f in c('Rater', 'Criterion')) names(truth[[f]]) <- as.character(seq_along(truth[[f]]))
  rownames(truth$steps) <- names(truth$log_slopes) <- names(truth$Criterion)
  # The fitted data are only observed responses. Deleted latent responses stay
  # in the original bundle, never in input$data or the estimator's arguments.
  wide_recovery_input(condition, replicate, v$data, truth,
    list(index = tools::md5sum(index_path), bundle = tools::md5sum(row$Bundle),
      view = row$View, row = row, covariance_sampling = s$covariance_sampling))
}

wide_e_bundle <- function(input) {
  stopifnot(identical(input$InputId, wide_mml_hash(input[setdiff(names(input), 'InputId')])) )
  p <- input$provenance; path <- names(p$bundle)
  stopifnot(length(path) == 1L, identical(tools::md5sum(path), p$bundle))
  b <- readRDS(path); v <- b$views[[p$view]]
  stopifnot(identical(input$data, v$data), b$unit$Replicate == input$Replicate,
    identical(p$covariance_sampling, v$spec$covariance_sampling),
    !anyDuplicated(b$persons), identical(names(b$abilities[[v$theta_key]]), b$persons),
    all(is.finite(b$abilities[[v$theta_key]])), all(v$data$Person %in% b$persons))
  b
}

wide_e_training_panel <- function(input) {
  b <- wide_e_bundle(input); v <- b$views[[input$provenance$view]]
  planned <- data.frame(Person = b$persons, Theta = unname(b$abilities[[v$theta_key]]))
  x <- list(Panel = 'training', Family = 'training_rescore',
    CohortId = b$unit$CohortId, data = input$data, planned = planned,
    provenance = input$provenance$bundle, scale = 'canonical_theta',
    contract = 'E_same_observed_training_responses_v1')
  x$DataId <- wide_mml_hash(list(data = x$data, planned = planned,
    CohortId = x$CohortId, scale = x$scale))
  x$PanelId <- wide_mml_hash(x); x
}

wide_e_training_native <- function(input, spec, fitting, stage) {
  # Reuse the unchanged native-output collector with only its panel reader
  # redirected. This keeps zero-response Persons in the planned denominator.
  collect <- wide_training_native
  environment(collect) <- list2env(list(wide_training_panel = wide_e_training_panel),
    parent = environment(collect))
  collect(input, spec, fitting, stage)
}

wide_e_specs <- function(input) {
  b <- wide_e_bundle(input); s <- b$views[[input$provenance$view]]$spec
  if (any(vapply(names(input$levels), function(f)
      !setequal(input$levels[[f]], unique(as.character(input$data[[f]]))), TRUE)))
    stop('Missing-facet coordinate bridge is unfinished; retain the dataset and its planned outputs.')
  template <- wide_f_read('validation-results/mfrm-wide-map-recovery-20261002/witness-manifest.rds')$payload$specs
  keys <- switch(b$unit$Truth, 'S-RSM' = c('PCM-MML-free', 'PCM-JML'),
    'S-PCM' = c('PCM-MML-free', 'PCM-JML', 'GPCM-MML-free', 'GPCM-JML', 'GPCM-JML2', 'GPCM-JML4'),
    'S-GPCM' = c('GPCM-MML-free', 'GPCM-JML', 'GPCM-JML2', 'GPCM-JML4'))
  stopifnot(length(keys) > 0L, all(keys %in% names(template)))
  specs <- lapply(template[keys], function(spec) {
    spec$ConditionId <- input$ConditionId; spec$Replicate <- input$Replicate
    spec$InputId <- input$InputId; spec$args$data <- input$data
    spec$purpose <- 'E_R50_descriptive_comparison'
    if (b$unit$Truth == 'S-RSM') {
      spec$Arm <- sub('PCM', 'RSM', spec$Arm, fixed = TRUE)
      spec$args$model <- 'RSM'; spec$args$step_facet <- NULL
    }
    spec$Arm <- sub('-MML-free$', '-MML-free-population', spec$Arm)
    spec$Arm <- sub('-JML([24])$', '-JML-order\\1', spec$Arm)
    if (!is.null(spec$args$population_formula))
      spec$args$person_data <- data.frame(Person = b$persons)
    if (!is.null(spec$args$jml_correction_order))
      spec$args$jml_correction_sampling <- s$covariance_sampling
    wide_interval_spec(input, spec)
  })
  names(specs) <- vapply(specs, `[[`, '', 'Arm')
  allocation <- read.csv('validation-results/mfrm-wide-map-r50-20261001/conditions.csv', stringsAsFactors = FALSE)
  row <- allocation[allocation$ConditionId == input$ConditionId, ]
  stopifnot(nrow(row) == 1L, identical(names(specs), strsplit(row$Arms, ';', fixed = TRUE)[[1L]]))
  specs
}

wide_e_future_bundle <- function(input, path) {
  b <- wide_e_bundle(input)
  root <- 'validation-results/mfrm-wide-map-r50-20261001/e-inputs'
  registry <- readRDS(file.path(root, 'rng-registry.rds'))
  verified <- readRDS(file.path(root, 'verified-inputs.rds'))
  stopifnot(identical(tools::md5sum(file.path(root, 'rng-registry.rds')), verified$registry_md5))
  originals <- c('validation-results/mfrm-wide-map-r50-20261001/ab-inputs/source/mfrm-wide-map-ab-inputs-20261001.R',
    'validation-results/mfrm-wide-map-r50-20261001/c-inputs/source/inst/validation/mfrm-wide-map-c-inputs-20261001.R',
    'inst/validation/mfrm-wide-map-e-inputs-20261001.R')
  frozen <- file.path(root, 'source', originals)
  stopifnot(!anyNA(registry$source_md5[originals]),
    identical(unname(tools::md5sum(frozen)), unname(registry$source_md5[originals])))
  rates_path <- 'validation-results/mfrm-missingness-control-rates-20261001/verified-rates.rds'
  rates_frozen <- file.path(root, 'source', rates_path)
  stopifnot(unname(tools::md5sum(rates_frozen)) == unname(registry$source_md5[rates_path]))
  binding <- list(parent = input$provenance$bundle, generator = tools::md5sum(frozen),
    rates = tools::md5sum(rates_frozen),
    bridge = tools::md5sum('inst/validation/mfrm-wide-map-e-output-20261006.R'),
    M = 60L, views = names(b$views), first_substream = b$rng$F_first_unused,
    contract = 'E_F_population_original_mechanisms_v1')
  wide_mml_phase(path, binding, function() {
    # Load the frozen functions once in dependency order. Suppress only their
    # redundant source() calls; generator and probability bodies are unchanged.
    context <- new.env(parent = globalenv())
    context$source <- function(file, ...) {
      stopifnot(file %in% originals[1:2]); invisible(NULL)
    }
    for (file in frozen) sys.source(file, envir = context)
    # Selection follows the calibration parent's declared scope, including its
    # joint mechanisms at N20/N480. Future M60 must not silently drop them.
    context$e_designs <- names(b$views); context$e_joint <- character()
    old_kind <- RNGkind(); had_seed <- exists('.Random.seed', .GlobalEnv, inherits = FALSE)
    if (had_seed) old_seed <- get('.Random.seed', .GlobalEnv)
    on.exit({do.call(RNGkind, as.list(old_kind));
      if (had_seed) assign('.Random.seed', old_seed, .GlobalEnv)
      else if (exists('.Random.seed', .GlobalEnv, inherits = FALSE)) rm('.Random.seed', envir = .GlobalEnv)}, add = TRUE)
    RNGkind("L'Ecuyer-CMRG", normal.kind = 'Inversion', sample.kind = 'Rejection')
    stream <- b$rng$F_first_unused; seeds <- list()
    for (component in c('ability', 'assignment', 'response', 'missingness')) {
      seeds[[component]] <- stream; stream <- parallel::nextRNGSubStream(stream)
    }
    seeds$F_first_unused <- stream
    unit <- b$unit; unit$N <- 60L; unit$CohortId <- paste(b$unit$CohortId, 'F-pop', sep = ':')
    future <- context$e_generate(unit, seeds, readRDS(rates_frozen)$rows)
    stopifnot(identical(names(future$views), names(b$views)))
    old_persons <- future$persons; persons <- paste0('F-', old_persons)
    future$persons <- persons
    future$abilities <- lapply(future$abilities, setNames, persons)
    for (view in names(future$views)) {
      v <- future$views[[view]]
      for (field in c('assignment', 'planned', 'data'))
        v[[field]]$Person <- persons[match(v[[field]]$Person, old_persons)]
      stopifnot(identical(v$spec, b$views[[view]]$spec))
      future$views[[view]] <- v
    }
    stopifnot(!any(persons %in% b$persons))
    list(bundle = future, binding = binding, next_unused_substream = stream)
  })
}

wide_e_future_panel <- function(input, future) {
  b <- wide_e_bundle(input); f <- future$bundle; view <- input$provenance$view
  stopifnot(identical(future$binding$parent, input$provenance$bundle),
    identical(f$views[[view]]$spec, b$views[[view]]$spec),
    identical(f$unit$CohortId, paste(b$unit$CohortId, 'F-pop', sep = ':')),
    length(f$persons) == 60L, !any(f$persons %in% b$persons))
  v <- f$views[[view]]
  planned <- data.frame(Person = f$persons, Theta = unname(f$abilities[[v$theta_key]]))
  x <- list(Panel = 'population', Family = 'F-pop', CohortId = f$unit$CohortId,
    data = v$data, planned = planned, seeds = f$rng,
    provenance = future$binding, scale = 'canonical_theta',
    contract = 'E_F_population_original_mechanisms_v1')
  x$DataId <- wide_mml_hash(list(data = x$data, planned = planned,
    CohortId = x$CohortId, scale = x$scale))
  x$PanelId <- wide_mml_hash(x); x
}
