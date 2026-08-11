# Repository-only analytic attribution for rejected extreme GPCM score rows.
#
# This diagnostic independently reconstructs the fixed-quadrature Person
# posterior and the GPCM sufficient-statistic score. It does not alter the
# rejected v2 calibration, freeze general NUM-SCORE-TOL, or authorize any
# inference, boundary, selection, or confirmation claim.

mfrmr_gsea_contract_version <- "mfrmr_gpcm_extreme_score_attribution_v1"
mfrmr_gsea_sources_loaded <- FALSE
mfrmr_gsea_absolute_floor <- 1e-8
mfrmr_gsea_scaled_rate <- 1e-10
mfrmr_gsea_scenario_ids <- c(
  "NUM-GPCM-SCORE-CAL-C-WEAK5",
  "NUM-GPCM-SCORE-CAL-R-WEAK5",
  "NUM-GPCM-SCORE-CAL-R-WORK5"
)

mfrmr_gsea_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsea_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"),
    file.path("..", "..", "..", "inst", "validation"),
    "."
  )
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-calibration-runner-0.2.3.R"
  ))]
  if (length(candidates) == 0L) {
    stop("Cannot locate the GPCM score-attribution sources.", call. = FALSE)
  }
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsea_require_sources <- function() {
  target <- environment(mfrmr_gsea_require_sources)
  required <- c(
    "mfrmr_gscr_manifest", "mfrmr_gscr_fit", "mfrmr_gscr_point",
    "mfrmr_gscr_parameter_class", "mfrmr_num_fit_context",
    "mfrmr_gno_independent_oracle", "mfrmr_gno_probability_difference",
    "mfrmr_num_logprob_bundle", "mfrmr_num_get"
  )
  if (!isTRUE(get0("mfrmr_gsea_sources_loaded", envir = target,
                   inherits = FALSE, ifnotfound = FALSE))) {
    sys.source(file.path(
      mfrmr_gsea_validation_dir(),
      "gpcm-score-calibration-runner-0.2.3.R"
    ), envir = target)
    assign("mfrmr_gsea_sources_loaded", TRUE, envir = target)
  }
  if (exists("mfrmr_gscr_require_sources", envir = target,
             inherits = FALSE)) {
    get("mfrmr_gscr_require_sources", envir = target,
        inherits = FALSE)()
  }
  available <- vapply(required, exists, logical(1), envir = target,
                      inherits = FALSE)
  mfrmr_gsea_assert(
    all(available),
    paste0("The score-attribution source chain is incomplete: ",
           paste(required[!available], collapse = ", "), ".")
  )
  invisible(TRUE)
}

mfrmr_gsea_project_sum_zero <- function(expanded_gradient) {
  expanded_gradient <- suppressWarnings(as.numeric(expanded_gradient))
  mfrmr_gsea_assert(
    length(expanded_gradient) >= 2L && all(is.finite(expanded_gradient)),
    "Sum-zero projection requires at least two finite expanded gradients."
  )
  expanded_gradient[seq_len(length(expanded_gradient) - 1L)] -
    expanded_gradient[length(expanded_gradient)]
}

mfrmr_gsea_p_geq <- function(probability) {
  probability <- as.matrix(probability)
  mfrmr_gsea_assert(
    nrow(probability) > 0L && ncol(probability) >= 2L &&
      all(is.finite(probability)),
    "Category probabilities must be a finite nonempty polytomous matrix."
  )
  do.call(cbind, lapply(seq_len(ncol(probability) - 1L), function(step) {
    rowSums(probability[, (step + 1L):ncol(probability), drop = FALSE])
  }))
}

mfrmr_gsea_independent_score <- function(context, par) {
  mfrmr_gsea_require_sources()
  mfrmr_gsea_assert(
    identical(as.character(context$config$model), "GPCM") &&
      identical(as.character(context$config$method), "MML"),
    "The analytic attribution requires a direct MML GPCM context."
  )
  par <- suppressWarnings(as.numeric(par))
  mfrmr_gsea_assert(
    length(par) == nrow(context$coordinates) && all(is.finite(par)),
    "`par` must match the finite identified-free coordinate table."
  )
  mfrmr_gsea_assert(
    as.integer(context$sizes$theta) == 0L &&
      (is.null(context$config$population_spec$active) ||
       !isTRUE(context$config$population_spec$active)),
    "The attribution is restricted to the fixed-standard-normal MML design."
  )
  mfrmr_gsea_assert(
    length(context$config$interaction_specs) == 0L,
    "The attribution does not cover active facet interactions."
  )

  params <- mfrmr_num_get("expand_params")(
    par, context$sizes, context$config
  )
  base_eta <- mfrmr_num_get("compute_base_eta")(
    context$idx, params, context$config
  )
  quad_basis <- mfrmr_num_get("resolve_person_quadrature_basis")(
    quad = context$quad,
    population_spec = mfrmr_num_get("materialize_population_spec")(
      context$config, params
    ),
    person_count = context$config$n_person
  )
  oracle <- mfrmr_gno_independent_oracle(context, par)
  log_likelihood_by_person <- rowsum(
    oracle$log_prob_mat, context$idx$person, reorder = FALSE
  )
  person_ids <- as.integer(rownames(log_likelihood_by_person))
  log_joint <- quad_basis$log_weights[person_ids, , drop = FALSE] +
    log_likelihood_by_person
  row_maximum <- apply(log_joint, 1L, max)
  posterior <- exp(log_joint - row_maximum)
  posterior <- posterior / rowSums(posterior)
  observation_person_row <- match(context$idx$person, person_ids)
  mfrmr_gsea_assert(
    !anyNA(observation_person_row) && all(is.finite(posterior)) &&
      max(abs(rowSums(posterior) - 1)) <= 1e-12,
    "The independently reconstructed Person posterior is invalid."
  )
  observation_posterior <- posterior[observation_person_row, , drop = FALSE]

  n_obs <- length(context$idx$score_k)
  n_cat <- as.integer(context$config$n_cat)
  n_steps <- n_cat - 1L
  score_k <- as.integer(context$idx$score_k)
  k_values <- 0:(n_cat - 1L)
  step_cumulative <- t(apply(
    params$steps_mat, 1L, function(value) c(0, cumsum(value))
  ))
  step_cumulative_observed <- step_cumulative[
    context$idx$step_idx, , drop = FALSE
  ]
  independent_slope <- mfrmr_gno_expand_slopes(
    par[as.integer(context$slices$log_slopes)]
  )$slopes
  slope_observed <- independent_slope[context$idx$slope_idx]
  observation_index <- cbind(seq_len(n_obs), score_k + 1L)
  indicator_geq <- outer(score_k, seq_len(n_steps), ">=") * 1
  weight <- context$idx$weight

  facet_gradient <- lapply(
    context$config$facet_names,
    function(facet) numeric(length(params$facets[[facet]]))
  )
  names(facet_gradient) <- context$config$facet_names
  step_gradient <- matrix(0, nrow(params$steps_mat), n_steps)
  slope_gradient <- numeric(length(independent_slope))

  for (node in seq_len(ncol(posterior))) {
    probability <- oracle$probability_list[[node]]
    expected_score <- as.vector(probability %*% k_values)
    residual <- slope_observed * (score_k - expected_score)
    if (!is.null(weight)) residual <- residual * weight
    posterior_residual <- residual * observation_posterior[, node]
    for (facet in context$config$facet_names) {
      sign <- context$config$facet_signs[[facet]]
      if (is.null(sign)) sign <- -1
      summed <- rowsum(
        matrix(sign * posterior_residual, ncol = 1L),
        context$idx$facets[[facet]], reorder = FALSE
      )
      levels <- as.integer(rownames(summed))
      facet_gradient[[facet]][levels] <-
        facet_gradient[[facet]][levels] + as.numeric(summed)
    }

    step_residual <- (
      mfrmr_gsea_p_geq(probability) - indicator_geq
    ) * slope_observed * observation_posterior[, node]
    if (!is.null(weight)) step_residual <- step_residual * weight
    summed_step <- rowsum(
      step_residual, context$idx$step_idx, reorder = FALSE
    )
    step_levels <- as.integer(rownames(summed_step))
    step_gradient[step_levels, ] <-
      step_gradient[step_levels, , drop = FALSE] + summed_step

    eta <- base_eta + quad_basis$nodes[context$idx$person, node]
    linear_part <- outer(eta, k_values) - step_cumulative_observed
    observed_linear <- linear_part[observation_index]
    expected_linear <- rowSums(probability * linear_part)
    slope_residual <- slope_observed *
      (observed_linear - expected_linear) * observation_posterior[, node]
    if (!is.null(weight)) slope_residual <- slope_residual * weight
    summed_slope <- rowsum(
      matrix(slope_residual, ncol = 1L),
      context$idx$slope_idx, reorder = FALSE
    )
    slope_levels <- as.integer(rownames(summed_slope))
    slope_gradient[slope_levels] <- slope_gradient[slope_levels] +
      as.numeric(summed_slope)
  }

  facet_free <- unlist(lapply(
    context$config$facet_names,
    function(facet) mfrmr_gsea_project_sum_zero(facet_gradient[[facet]])
  ), use.names = FALSE)
  step_free <- unlist(lapply(seq_len(nrow(step_gradient)), function(row) {
    mfrmr_gsea_project_sum_zero(step_gradient[row, ])
  }), use.names = FALSE)
  slope_free <- mfrmr_gsea_project_sum_zero(slope_gradient)
  score <- -c(facet_free, step_free, slope_free)
  mfrmr_gsea_assert(
    length(score) == length(par) && all(is.finite(score)),
    "The independently reconstructed analytic score is incomplete."
  )
  list(
    score = score,
    posterior = posterior,
    posterior_row_sum_residual = max(abs(rowSums(posterior) - 1)),
    objective = oracle$objective,
    slopes = independent_slope
  )
}

mfrmr_gsea_audit_fit <- function(fit, scenario) {
  context <- mfrmr_num_fit_context(fit)
  rows <- lapply(mfrmr_gsc_points()$Point, function(point) {
    par <- mfrmr_gscr_point(fit, point)
    package_score <- suppressWarnings(as.numeric(context$gr(par)))
    independent <- mfrmr_gsea_independent_score(context, par)
    route <- mfrmr_num_logprob_bundle(context, par, include_probs = TRUE)
    route_objective <- suppressWarnings(as.numeric(context$fn(par))[1])
    oracle <- mfrmr_gno_independent_oracle(context, par)
    structural_pass <- all(is.finite(c(
      route$log_prob_mat, route_objective, oracle$log_prob_mat,
      oracle$objective
    ))) &&
      max(abs(route$log_prob_mat - oracle$log_prob_mat)) <=
        mfrmr_gno_limits["log_probability"] &&
      mfrmr_gno_probability_difference(
        route$prob_list, oracle$probability_list
      ) <= mfrmr_gno_limits["probability"] &&
      abs(route_objective - oracle$objective) <=
        mfrmr_gno_limits["objective"]
    scale <- pmax(1, abs(package_score), abs(independent$score))
    difference <- abs(package_score - independent$score)
    allowance <- mfrmr_gsea_absolute_floor + mfrmr_gsea_scaled_rate * scale
    coordinates <- context$coordinates
    coordinates$ParameterClassFrozen <- mfrmr_gscr_parameter_class(
      coordinates, as.character(scenario$SlopeOwner)
    )
    coordinates$ScenarioId <- as.character(scenario$ScenarioId)
    coordinates$Point <- point
    coordinates$PackageScore <- package_score
    coordinates$IndependentScore <- independent$score
    coordinates$ScoreScale <- scale
    coordinates$AbsDifference <- difference
    coordinates$CombinedAllowance <- allowance
    coordinates$AllowanceRatio <- difference / allowance
    coordinates$CoordinatePass <- difference <= allowance
    coordinates$StructuralOraclePass <- structural_pass
    coordinates$CalibrationResultChanged <- FALSE
    coordinates$ConfirmationAuthorized <- FALSE
    coordinates
  })
  coordinates <- do.call(rbind, rows)
  evidence <- do.call(rbind, lapply(
    split(
      coordinates,
      interaction(
        coordinates$Point, coordinates$ParameterClassFrozen,
        drop = TRUE, lex.order = TRUE
      )
    ),
    function(group) data.frame(
      ContractVersion = mfrmr_gsea_contract_version,
      ScenarioId = as.character(group$ScenarioId[1]),
      Point = as.character(group$Point[1]),
      ParameterClass = as.character(group$ParameterClassFrozen[1]),
      CoordinateCount = nrow(group),
      MaxAbsDifference = max(group$AbsDifference),
      MaxAllowanceRatio = max(group$AllowanceRatio),
      StructuralOraclePass = all(group$StructuralOraclePass),
      EvaluationComplete = all(is.finite(unlist(group[c(
        "PackageScore", "IndependentScore", "AbsDifference",
        "CombinedAllowance", "AllowanceRatio"
      )], use.names = FALSE))),
      CalibrationResultChanged = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  ))
  row.names(evidence) <- NULL
  list(coordinates = coordinates, evidence = evidence)
}

mfrmr_gsea_decision <- function(evidence) {
  mfrmr_gsea_require_sources()
  expected <- expand.grid(
    ScenarioId = mfrmr_gsea_scenario_ids,
    Point = mfrmr_gsc_points()$Point,
    ParameterClass = mfrmr_gsc_expected_classes,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  key <- function(data) paste(
    data$ScenarioId, data$Point, data$ParameterClass, sep = "::"
  )
  required <- c(
    "ContractVersion", names(expected), "MaxAbsDifference",
    "MaxAllowanceRatio", "StructuralOraclePass", "EvaluationComplete",
    "CalibrationResultChanged", "ConfirmationAuthorized"
  )
  complete <- is.data.frame(evidence) &&
    all(required %in% names(evidence)) && nrow(evidence) == nrow(expected) &&
    !anyDuplicated(key(evidence)) &&
    identical(sort(key(evidence)), sort(key(expected))) &&
    all(evidence$ContractVersion == mfrmr_gsea_contract_version)
  agreement <- complete && all(evidence$EvaluationComplete %in% TRUE) &&
    all(evidence$StructuralOraclePass %in% TRUE) &&
    all(is.finite(evidence$MaxAllowanceRatio)) &&
    all(evidence$MaxAllowanceRatio <= 1) &&
    all(evidence$CalibrationResultChanged %in% FALSE) &&
    all(evidence$ConfirmationAuthorized %in% FALSE)
  data.frame(
    ContractVersion = mfrmr_gsea_contract_version,
    ExpectedRows = nrow(expected),
    Complete = complete,
    AnalyticAttributionAgreement = agreement,
    Status = if (agreement) "attribution_agreement" else "rejected",
    V2CalibrationStatus = "rejected_unchanged",
    GeneralNUMSCORETOLStatus = "pilot_required",
    CalibrationResultChanged = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_extreme_score_attribution <- function(
    dry_run = TRUE, authorize = FALSE, progress = TRUE) {
  mfrmr_gsea_require_sources()
  manifest <- mfrmr_gscr_manifest()
  manifest <- manifest[
    match(mfrmr_gsea_scenario_ids, manifest$ScenarioId), , drop = FALSE
  ]
  mfrmr_gsea_assert(
    !anyNA(manifest$ScenarioId) && nrow(manifest) == 3L,
    "The three rejected-surface attribution scenarios are unavailable."
  )
  if (isTRUE(dry_run)) {
    return(list(
      contract_version = mfrmr_gsea_contract_version,
      manifest = manifest,
      executed = FALSE,
      v2_calibration_status = "rejected_unchanged",
      general_num_score_tol_status = "pilot_required",
      confirmation_authorized = FALSE
    ))
  }
  mfrmr_gsea_assert(
    isTRUE(authorize),
    "Score attribution requires explicit `authorize = TRUE`."
  )
  results <- lapply(seq_len(nrow(manifest)), function(index) {
    scenario <- manifest[index, , drop = FALSE]
    if (isTRUE(progress)) message("GPCM score attribution: ", scenario$ScenarioId)
    fitted <- mfrmr_gscr_fit(scenario)
    mfrmr_gsea_assert(
      !is.null(fitted$fit) && length(fitted$fit$opt$par) > 0L &&
        all(is.finite(fitted$fit$opt$par)),
      paste0("Attribution fit failed: ", scenario$ScenarioId, ".")
    )
    audit <- mfrmr_gsea_audit_fit(fitted$fit, scenario)
    list(
      fit = data.frame(
        ScenarioId = as.character(scenario$ScenarioId),
        FixtureSHA256 = fitted$fixture_sha256,
        OptimizerConvergence = as.integer(fitted$fit$opt$convergence),
        FitReadiness = as.character(fitted$fit$summary$FitReadiness[1]),
        InferenceReady = isTRUE(fitted$fit$summary$InferenceReady[1]),
        stringsAsFactors = FALSE
      ),
      coordinates = audit$coordinates,
      evidence = audit$evidence
    )
  })
  evidence <- do.call(rbind, lapply(results, `[[`, "evidence"))
  list(
    contract_version = mfrmr_gsea_contract_version,
    manifest = manifest,
    fits = do.call(rbind, lapply(results, `[[`, "fit")),
    coordinates = do.call(rbind, lapply(results, `[[`, "coordinates")),
    evidence = evidence,
    decision = mfrmr_gsea_decision(evidence),
    executed = TRUE,
    v2_calibration_status = "rejected_unchanged",
    general_num_score_tol_status = "pilot_required",
    calibration_result_changed = FALSE,
    confirmation_authorized = FALSE
  )
}
