# D's saved calibration-cohort targets and initial native Person output.
# Source the existing MML, F, D response and D scoring helpers first.
# Same-response re-scoring uses wide_d_f_run unchanged and stays a separate route.
wide_d_training_panel <- function(input) {
  stopifnot(identical(tools::md5sum(names(input$provenance)), input$provenance))
  b <- input$bundle; truth <- input$truth
  if (b$unit$Type == 'rubric') {
    persons <- names(b$latent_z)
  } else {
    stopifnot(b$unit$Type %in% c('historical-240', 'historical-core', 'historical-new'))
    persons <- sprintf('p%03d', seq_len(b$unit$N))
  }
  stopifnot(length(persons) == input$row$N, !anyNA(persons), !anyDuplicated(persons),
    length(b$latent_z) == length(persons), all(is.finite(b$latent_z)),
    setequal(as.character(input$data$Person), persons))
  origin <- switch(b$unit$Type,
    'historical-240' = 'reconstructed_rng_source_bridge_not_original_latent_archive',
    'historical-core' = 'reconstructed_frozen_core_generator',
    'historical-new' = 'saved_declared_draws',
    'rubric' = 'inherited_saved_AB_draws')
  planned <- data.frame(Person = persons, Theta = unname(b$latent_z),
    GeneratingTheta = truth$mu + truth$sd * unname(b$latent_z),
    LatentProvenance = origin)
  panel <- list(Panel = 'training', Family = 'training_rescore',
    CohortId = b$unit$CohortId, data = input$data, planned = planned,
    categories = 0:(truth$K-1L), facets = truth$facets,
    provenance = input$provenance, rng_origin = b$rng_origin,
    scale = 'population_relative_z', contract = 'D_same_training_responses_v1')
  panel$DataId <- wide_mml_hash(list(data = panel$data, planned = planned,
    CohortId = panel$CohortId, scale = panel$scale))
  panel$PanelId <- wide_mml_hash(panel); panel
}

wide_d_training_native <- function(input, calibration) {
  panel <- wide_d_training_panel(input)
  manifest_path <- file.path(calibration, 'manifest.rds')
  fit_path <- file.path(calibration, 'q31-fit.rds')
  m <- wide_f_read(manifest_path)$payload; f <- wide_f_read(fit_path)
  spec <- m$spec
  if (identical(spec$purpose, 'D_fresh_historical_two_family')) {
    wide_d_fresh_validate(spec, list())
  } else {
    stopifnot(identical(spec$purpose, 'D_retained_comparison'))
  }
  stopifnot(identical(R.version.string, m$runtime$R),
    spec$ConditionId == input$row$ConditionId, spec$Replicate == input$row$Replicate,
    identical(spec$args$data, input$data), identical(spec$args$method, 'MML'),
    identical(spec$args$slope_facet, spec$args$facets),
    identical(f$binding, list(job = wide_mml_hash(m), order = 31L, phase = 'fit', dependency = NULL)))
  z <- panel$planned; fitting <- f$payload
  z$Observed <- vapply(z$Person, function(id)
    sum(input$data$Person == id & !is.na(input$data$Score)), 1L)
  z$ResponseExtreme <- vapply(z$Person, function(id) {
    y <- input$data$Score[input$data$Person == id & !is.na(input$data$Score)]
    if (!length(y)) 'missing_only' else if (all(y == min(panel$categories))) 'low' else
      if (all(y == max(panel$categories))) 'high' else 'none'
  }, '')
  z$Estimate <- z$ConditionalSD <- NA_real_; z$Returned <- FALSE
  z$EstimateUse <- z$SourceFitReadiness <- NA_character_; z$Reason <- fitting$error
  if (!nzchar(fitting$error)) {
    fit <- fitting$value; tab <- fit$facets$person
    pop <- wide_d_fixed_normal_parameters(fit)$native_population
    stopifnot(!anyDuplicated(tab$Person), all(tab$Person %in% z$Person),
      all(tab$PrimaryEstimateBasis == 'posterior_eap'))
    ix <- match(z$Person, tab$Person)
    z$Estimate <- (tab$Estimate[ix]-pop['mean'])/pop['sd']
    z$ConditionalSD <- tab$PosteriorSD[ix]/pop['sd']
    z$Returned <- !is.na(ix) & !is.na(z$Estimate) & z$Observed > 0L
    for (field in c('EstimateUse', 'SourceFitReadiness')) z[[field]] <- as.character(tab[[field]][ix])
    z$Reason <- ifelse(z$Returned, '', ifelse(z$Observed == 0L, 'No observed responses', 'Native estimate not returned'))
  }
  z$Finite <- z$Returned & is.finite(z$Estimate); z$Infinite <- z$Returned & is.infinite(z$Estimate)
  z$Error <- ifelse(z$Returned, z$Estimate-z$Theta, NA_real_); z$SquaredError <- z$Error^2
  z$ConditionId <- spec$ConditionId; z$Replicate <- spec$Replicate; z$Arm <- spec$Arm
  z$SourceStage <- paste0('q31:', f$checksum); z$NativeBasis <- 'posterior_eap'
  z$Procedure <- 'initial_native_training_score'; z$Scale <- panel$scale
  list(records = z, sources = tools::md5sum(c(manifest_path, fit_path)),
    input = input$provenance, PanelId = panel$PanelId,
    scope = 'Initial native output, including its original readiness labels. No source admission, re-scoring or confidence interval is inferred from a finite return.')
}
