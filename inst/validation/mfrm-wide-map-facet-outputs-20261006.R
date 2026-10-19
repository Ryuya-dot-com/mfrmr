# Source after the original validation helpers in a separate source snapshot.
# This extends only facet/category handling; existing estimators, numerical
# retries, source admission and interval rules remain unchanged.

wide_recovery_input <- function(condition, replicate, data, truth, provenance,
    facets = c("Rater", "Criterion")) {
  stopifnot(identical(facets, c("Rater", "Criterion")) ||
    identical(facets, c("Rater", "Criterion", "Task")))
  levels <- lapply(truth[facets], names)
  stopifnot(length(condition) == 1L, nzchar(condition), length(replicate) == 1L,
    replicate >= 1L, replicate == floor(replicate), is.data.frame(data),
    all(c("Person", facets, "Score") %in% names(data)), nrow(data) > 0L,
    !anyNA(data[c("Person", facets, "Score")]), length(provenance) > 0L,
    all(vapply(levels, function(x) length(x) >= 2L && !anyNA(x) && !anyDuplicated(x), TRUE)),
    is.matrix(truth$steps), ncol(truth$steps) >= 1L,
    identical(rownames(truth$steps), levels$Criterion),
    identical(names(truth$log_slopes), levels$Criterion),
    all(is.finite(unlist(truth))),
    max(abs(c(vapply(truth[facets], sum, 0), rowSums(truth$steps), sum(truth$log_slopes)))) < 1e-10)
  categories <- 0:ncol(truth$steps)
  stopifnot(all(data$Score %in% categories),
    all(vapply(facets, function(f) all(as.character(data[[f]]) %in% levels[[f]]), TRUE)))
  grid <- do.call(expand.grid, c(list(Theta = c(-2, -1, 0, 1, 2)), levels,
    list(stringsAsFactors = FALSE)))
  x <- list(ConditionId = condition, Replicate = as.integer(replicate), data = data,
    truth = truth, levels = levels, categories = categories, grid = grid,
    provenance = provenance, contract = if (length(facets) == 2L) "two_facet_native_initial_recovery_v1" else
      "three_facet_native_initial_recovery_v1")
  x$InputId <- wide_mml_hash(x); x
}

wide_recovery_data <- function(data, facets = c("Rater", "Criterion")) {
  x <- data[c("Person", facets, "Score")]
  for (f in c("Person", facets)) x[[f]] <- as.character(x[[f]])
  x$Score <- as.numeric(x$Score); rownames(x) <- NULL; x
}

wide_recovery_probabilities <- function(input, parameters) {
  g <- input$grid; k <- input$categories
  eta <- g$Theta - parameters$Rater[g$Rater] - parameters$Criterion[g$Criterion]
  if ("Task" %in% names(input$levels)) eta <- eta - parameters$Task[g$Task]
  steps <- t(apply(parameters$steps, 1L, function(x) c(0, cumsum(x))))
  logits <- exp(parameters$log_slopes[g$Criterion]) *
    (outer(eta, k) - steps[g$Criterion, , drop = FALSE])
  out <- matrix(NA_real_, nrow(g), length(k))
  good <- apply(logits, 1L, function(x) all(is.finite(x)))
  if (any(good)) {
    mass <- exp(logits[good, , drop = FALSE] - apply(logits[good, , drop = FALSE], 1L, max))
    out[good, ] <- mass / rowSums(mass)
  }
  out
}

wide_recovery_plan <- function(input, spec) {
  a <- spec$args
  stopifnot(identical(input$contract, if (length(input$levels) == 2L)
      "two_facet_native_initial_recovery_v1" else "three_facet_native_initial_recovery_v1"),
    identical(input$InputId, wide_mml_hash(input[setdiff(names(input), "InputId")])),
    identical(spec$ConditionId, input$ConditionId), spec$Replicate == input$Replicate,
    identical(a$data, input$data), identical(a$facets, names(input$levels)),
    a$person == "Person", a$score == "Score", a$model %in% c("PCM", "GPCM", "RSM"),
    a$method %in% c("MML", "JML"), a$rating_min == 0,
    a$rating_max == max(input$categories), a$category_policy == "preserve")
  if (a$model != "RSM") stopifnot(a$step_facet == "Criterion")
  if (a$model == "GPCM") stopifnot(identical(a$slope_facet, "Criterion"))
  encode <- function(...) paste(..., sep = ":")
  rows <- lapply(names(input$levels), function(facet) {
    levels <- input$levels[[facet]]
    data.frame(Target = c(encode("contrast", facet, paste(levels[1:2], collapse = "-")),
      encode("location", facet, levels)), Kind = c("contrast", rep("location", length(levels))),
      Owner = facet, Coordinate = "native_location", ScaleReference = "centered_native_location",
      ReferenceValue = c(input$truth[[facet]][1] - input$truth[[facet]][2], input$truth[[facet]]),
      Eligibility = "eligible", stringsAsFactors = FALSE)
  })
  rows$slopes <- data.frame(Target = encode("log_slope", "Criterion", input$levels$Criterion),
    Kind = "log_slope", Owner = "Criterion", Coordinate = "log_slope", ScaleReference = "geometric_mean_one",
    ReferenceValue = input$truth$log_slopes, Eligibility = if (a$model == "GPCM") "eligible" else "fixed")
  g <- input$grid
  rows$probability <- data.frame(Target = unlist(lapply(input$categories, function(k)
      do.call(encode, c(list("probability"), g[c("Theta", names(input$levels))], list(k))))),
    Kind = "probability", Owner = "response", Coordinate = "probability",
    ScaleReference = "canonical_theta_native_locations", ReferenceValue = as.vector(wide_recovery_probabilities(input, input$truth)),
    Eligibility = "eligible")
  plan <- do.call(rbind, rows); rownames(plan) <- NULL
  plan$ConditionId <- input$ConditionId; plan$Replicate <- input$Replicate; plan$InputId <- input$InputId
  plan$Arm <- spec$Arm; plan$Output <- "point"; plan$Reference <- "generating_parameter"
  plan$Primary <- plan$Kind != "location"
  plan <- rbind(transform(plan, Analysis = "initial_finite_return"),
    transform(plan, Analysis = "initial_numerical_pass"))
  plan
}

wide_recovery_fit_identity <- function(fit, input, spec) {
  a <- spec$args; cfg <- fit$config
  stopifnot(inherits(fit, "mfrm_fit"), !inherits(fit, "mfrm_imported_fit"),
    identical(cfg$model, a$model), identical(cfg$method, a$method),
    identical(cfg$facet_names, a$facets), identical(cfg$facet_levels, input$levels),
    cfg$n_cat == length(input$categories), fit$prep$rating_min == 0,
    fit$prep$rating_max == max(input$categories), all(fit$prep$data$Weight == 1),
    identical(wide_recovery_data(fit$prep$data, a$facets), wide_recovery_data(input$data, a$facets)),
    !length(fit$interactions$specs), nrow(fit$interactions$effects) == 0L)
  adjusted <- mfrmr:::mfrm_has_jml_adjustment(fit)
  stopifnot(identical(adjusted, !is.null(a$jml_correction_order)))
  if (adjusted) {
    stopifnot(identical(fit$jml_adjustment$estimator$order, as.integer(a$jml_correction_order)),
      identical(fit$jml_adjustment$estimator$sampling, a$jml_correction_sampling))
  } else {
    stopifnot(all(cfg$facet_signs[a$facets] == -1), !length(cfg$interaction_specs))
    for (facet in a$facets) stopifnot(isTRUE(all.equal(cfg$facet_specs[[facet]],
      mfrmr:::build_facet_constraint(input$levels[[facet]]))))
    owners <- if (a$model == "RSM") "shared" else input$levels$Criterion
    expected <- setNames(lapply(owners, function(x) mfrmr:::build_step_constraint(
      length(input$categories) - 1L, scope = x)), owners)
    stopifnot(isTRUE(all.equal(cfg$step_specs, expected)))
  }
  if (a$model != "RSM") stopifnot(cfg$step_facet == "Criterion")
  if (a$model == "GPCM") {
    stopifnot(identical(cfg$slope_facet, "Criterion"))
    if (!adjusted) stopifnot(cfg$gpcm_spec$scale_reference == "geometric_mean_one")
  }
  if (a$method == "MML") {
    active <- !is.null(a$population_formula)
    stopifnot(identical(isTRUE(fit$population$active), active))
    if (active) stopifnot(identical(as.character(a$population_formula), c("~", "1")),
      identical(fit$population$design_columns, "(Intercept)"))
  }
  invisible(TRUE)
}

wide_f_predict <- function(fit, data, prior, q, person_data = NULL) mfrmr::predict_mfrm_units(fit,
  new_data = data, person = "Person", facets = fit$config$facet_names, score = "Score",
  scoring_prior = prior, person_data = person_data, interval_level = .95, n_draws = 0L,
  readiness_policy = "error", scoring_quad_points = q)

wide_f_run <- function(source, panel, prior, out, runtime, artifact_dir = NULL) {
  stopifnot(prior %in% c("reference","retained"),
    identical(panel$PanelId, wide_mml_hash(panel[setdiff(names(panel),"PanelId")])),
    identical(source$SourceId, wide_mml_hash(source[setdiff(names(source),"SourceId")])))
  actual <- if (prior == "reference") list(mean = 0, sd = 1) else NULL
  # Evaluation truth is not supplied to the scorer or the retry predicate.
  facets <- source$spec$args$facets
  rows <- panel$data[c("Person",facets,"Score")]
  portable <- !is.null(artifact_dir)
  if (portable) {
    stopifnot(!is.null(source$spec$args$jml_correction_order))
    rows$Event <- if ("Event" %in% names(panel$data)) panel$data$Event else
      ave(seq_len(nrow(rows)), do.call(interaction,c(rows[c("Person",facets)],list(drop=TRUE))),FUN=seq_along)
  }
  manifest <- list(SourceId = source$SourceId, PanelId = panel$PanelId, prior = prior,
    actual_prior = actual, data = rows, orders = c(31L,61L,121L), runtime = runtime)
  if (!is.null(panel$person_data)) {
    stopifnot(prior == "retained", !portable)
    manifest$person_data <- panel$person_data
  }
  if (portable) manifest$portable <- list(route = "frozen_corrected_jml", artifact_dir = artifact_dir)
  dir.create(out,recursive = TRUE,showWarnings = FALSE)
  old <- wide_mml_phase(file.path(out,"manifest.rds"),"held-out-scoring-v1",function() manifest)
  if (!identical(old,manifest)) stop("Scoring data, source, prior or procedure changed.")
  identity <- wide_mml_hash(manifest); attempts <- list(); finished <- FALSE; q <- 31L
  status <- function(value) wide_mml_save(list(status = value, identity = identity,
    scoring_order = q, time = Sys.time()),file.path(out,"status.rds"))
  on.exit(if (!finished) status("interrupted"),add = TRUE)
  source_ready <- !nzchar(source$error) && isTRUE(source$review$ready)
  artifacts <- list()
  for (q in manifest$orders) {
    status("running")
    if (portable && source_ready) {
      extraction <- wide_f_artifact(source,q,artifact_dir,runtime)
      artifacts[[as.character(q)]] <- list(path = file.path(artifact_dir,paste0("q",q,".rds")),
        checksum = wide_mml_hash(extraction))
    }
    binding <- list(job = identity, scoring_order = q)
    if (portable) binding$artifact <- artifacts[[as.character(q)]]
    a <- wide_mml_phase(file.path(out,paste0("score-q",q,".rds")), binding,function() {
        if (!source_ready) return(list(value = NULL, error = paste("Scoring source refused:",
          source$error,paste(source$review$reason_codes,collapse = "; "),
          source$review$local_calibration_review$review), warnings = character(), elapsed = 0))
        if (portable) {
          if (nzchar(extraction$error)) return(list(value = NULL,
            error = paste("Calibration extraction failed:",extraction$error),
            warnings = character(), elapsed = 0))
          return(wide_mml_capture(function() mfrmr::score_mfrm_calibration(extraction$value,rows,
            person = "Person", facets = setNames(facets,facets), score = "Score",
            event_id = "Event", scoring_prior = actual, interval_level = .95)))
        }
        wide_mml_capture(function() {
          if (is.null(panel$person_data)) wide_f_predict(source$fit,rows,actual,q) else
            wide_f_predict(source$fit,rows,actual,q,person_data=panel$person_data)
        })
      })
    attempts[[as.character(q)]] <- a
    if (!wide_f_retry(a$error)) break
  }
  selected <- list(identity = identity, source_ready = source_ready, source_stage = source$stage,
    attempts = attempts, selected_order = q, prior = prior, SourceId = source$SourceId, PanelId = panel$PanelId)
  if (portable) {
    selected$route <- "frozen_corrected_jml"
    selected$artifacts <- artifacts
  }
  saved <- wide_mml_phase(file.path(out,"selected.rds"),identity,function() selected)
  stopifnot(identical(saved,selected)); status("complete"); finished <- TRUE
  saved
}

wide_f_records <- function(source, panel, selected) {
  stopifnot(identical(source$SourceId,selected$SourceId), identical(panel$PanelId,selected$PanelId))
  portable <- identical(selected$route,"frozen_corrected_jml")
  result <- lapply(c("default31","refinement"), function(rule) {
    q <- if (rule == "default31") 31L else selected$selected_order
    a <- selected$attempts[[as.character(q)]]; stopifnot(!is.null(a))
    z <- panel$planned; z$Observed <- vapply(z$Person, function(id)
      sum(panel$data$Person == id & !is.na(panel$data$Score)), 1L)
    z$Extreme <- vapply(z$Person,function(id) {
      y <- panel$data$Score[panel$data$Person == id & !is.na(panel$data$Score)]
      length(y) > 0L && (all(y == source$spec$args$rating_min) || all(y == source$spec$args$rating_max))
    },TRUE)
    z$Estimate <- z$SD <- z$Lower <- z$Upper <- z$PriorMean <- z$PriorSD <- NA_real_
    z$ScoreAvailable <- z$IntervalAvailable <- FALSE
    z$Reason <- a$error; z$BatchStatus <- if (!selected$source_ready) "source_refused" else
      if (startsWith(a$error,"Calibration extraction failed:")) "extraction_refused" else
      if (wide_f_retry(a$error)) "integration_refused" else if (nzchar(a$error)) "error" else "returned"
    z$BatchCheck <- "no_return"
    if (!nzchar(a$error)) {
      v <- a$value; t <- v$estimates
      if (portable) {
        mfrmr:::mfrmr_validate_calibration_score(v)
        stopifnot(v$settings$schema_version == 5L, v$settings$quadrature_order == q,
          all(t$EstimateBasis == "posterior_eap_fixed_calibration"),
          all(t$UncertaintyBasis == "conditional_on_frozen_point_calibration"))
        usable <- t$Disposition %in% c("scored","scored_review")
      } else {
        mfrmr:::prediction_validate_population_output(v)
        stopifnot(inherits(v,"mfrm_unit_prediction"), v$settings$scoring_quad_points == q,
          v$settings$n_draws == 0, identical(v$settings$readiness_policy,"error"),
          isTRUE(v$settings$source_scoring_ready))
        usable <- t$EstimateUse == "fitted_object_scoring"
      }
      stopifnot(!anyDuplicated(t$Person), all(t$Person %in% z$Person),
        v$settings$interval_level == .95, isTRUE(selected$source_ready),
        identical(v$settings$scoring_prior, if (selected$prior == "reference") list(mean=0,sd=1) else NULL))
      ix <- match(z$Person,t$Person)
      for (field in c("Estimate","SD","Lower","Upper","PriorMean","PriorSD")) z[[field]] <- t[[field]][ix]
      checked <- !is.null(v$settings$score_integration_review)
      if (checked) stopifnot(all(v$settings$score_integration_review$Passed))
      z$BatchCheck <- if (checked) "public_EAP_SD_pass" else "not_performed_by_public_procedure"
      z$ScoreAvailable <- !is.na(ix) & z$Observed > 0 & is.finite(z$Estimate) &
        usable[ix]
      z$IntervalAvailable <- z$ScoreAvailable & is.finite(z$SD) & z$SD > 0 &
        is.finite(z$Lower) & is.finite(z$Upper) & z$Lower < z$Upper
      z$Reason <- ifelse(z$ScoreAvailable,"",ifelse(z$Observed == 0,"No usable responses","Score not returned"))
    }
    z$IntervalReason <- ifelse(z$IntervalAvailable,"",ifelse(nzchar(z$Reason),z$Reason,"Conditional interval not returned"))
    z$Error <- ifelse(z$ScoreAvailable,z$Estimate-z$Theta,NA_real_)
    z$Covered <- z$IntervalAvailable & z$Lower <= z$Theta & z$Upper >= z$Theta
    z$Covered[!z$IntervalAvailable] <- FALSE
    z$ConditionId <- source$spec$ConditionId; z$Replicate <- source$spec$Replicate; z$Arm <- source$spec$Arm
    z$Prior <- selected$prior; z$Rule <- rule; z$Panel <- panel$Panel; z$Family <- panel$Family
    z$PanelId <- panel$PanelId; z$DataId <- panel$DataId
    z$CohortId <- panel$CohortId; z$SourceId <- source$SourceId
    z$SourceStage <- source$stage; z$ScoringOrder <- q; z$Scale <- panel$scale
    z$ScoringRoute <- if (portable) "frozen_corrected_jml" else "fitted_object"
    z$ConditionalUncertainty <- TRUE; z
  })
  do.call(rbind,result)
}

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
  truth <- s$truth[c(s$facets, 'steps', 'log_slopes')]
  for (f in s$facets) names(truth[[f]]) <- as.character(seq_along(truth[[f]]))
  rownames(truth$steps) <- names(truth$log_slopes) <- names(truth$Criterion)
  # The fitted data are only observed responses. Deleted latent responses stay
  # in the original bundle, never in input$data or the estimator's arguments.
  wide_recovery_input(condition, replicate, v$data, truth,
    list(index = tools::md5sum(index_path), bundle = tools::md5sum(row$Bundle),
      view = row$View, row = row, covariance_sampling = s$covariance_sampling), facets = s$facets)
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
    spec$args$facets <- names(input$levels)
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
