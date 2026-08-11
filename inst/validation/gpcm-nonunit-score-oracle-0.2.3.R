# Repository-only non-unit GPCM score/likelihood oracle for mfrmr 0.2.3.
#
# This deterministic strengthening reuses the fixed data/configuration and
# additive-coordinate expansion from the earlier canonical-score pilot, but it
# independently expands free log slopes, constructs the non-unit GPCM softmax
# kernel, performs Person-wise fixed-quadrature marginalization, and
# differentiates that independent objective numerically. It does not freeze the
# general NUM-SCORE-TOL, authorize confirmation, or prove a boundary result.

mfrmr_gno_contract_version <- "mfrmr_gpcm_nonunit_score_oracle_v1"
# The pre-existing draft.12 ladder was c(1e-4, 3e-5, 1e-5). Calibration at
# the finite slope-stress points showed the expected central-difference
# truncation error at the two larger steps, while 1e-5 remained below the
# repository-only structural-oracle limit. This is a calibration choice, not a
# frozen general NUM-SCORE-TOL or a confirmation-stage selection.
mfrmr_gno_primary_step <- 1e-5
mfrmr_gno_expected_points <- c(
  "retained_solution",
  "high_dispersion_probe",
  "finite_slope_stress_forward",
  "finite_slope_stress_reverse"
)
mfrmr_gno_limits <- c(
  log_probability = 1e-12,
  probability = 1e-12,
  objective = 1e-10,
  score = 1e-6,
  transform = 1e-12,
  geometric_mean = 1e-12
)

mfrmr_gno_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gno_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) {
    stop("Cannot locate the repository validation directory.", call. = FALSE)
  }
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gno_require_base_contract <- function() {
  target <- environment(mfrmr_gno_require_base_contract)
  required <- c(
    "mfrmr_num_fixture", "mfrmr_num_fit_context",
    "mfrmr_num_logprob_bundle", "mfrmr_num_central_gradient"
  )
  available <- vapply(
    required, exists, logical(1), envir = target, inherits = FALSE
  )
  if (!all(available)) {
    sys.source(
      file.path(
        mfrmr_gno_validation_dir(),
        "numerical-stationarity-pilot-0.2.3.R"
      ),
      envir = target
    )
  }
  available <- vapply(
    required, exists, logical(1), envir = target, inherits = FALSE
  )
  mfrmr_gno_assert(
    all(available),
    "The canonical-score base contract could not be loaded."
  )
  invisible(TRUE)
}

mfrmr_gno_expand_slopes <- function(free_log_slopes) {
  free_log_slopes <- suppressWarnings(as.numeric(free_log_slopes))
  mfrmr_gno_assert(
    length(free_log_slopes) > 0L && all(is.finite(free_log_slopes)),
    "`free_log_slopes` must be a non-empty finite numeric vector."
  )
  expanded_log_slopes <- c(free_log_slopes, -sum(free_log_slopes))
  slopes <- exp(expanded_log_slopes)
  mfrmr_gno_assert(
    all(is.finite(slopes)) && all(slopes > 0),
    "The independent positive-slope expansion is not representable."
  )
  list(
    log_slopes = expanded_log_slopes,
    slopes = slopes,
    geometric_mean_residual = abs(mean(log(slopes)))
  )
}

mfrmr_gno_independent_oracle <- function(context, par) {
  mfrmr_gno_require_base_contract()
  mfrmr_gno_assert(
    identical(as.character(context$config$model), "GPCM"),
    "The non-unit oracle requires a GPCM context."
  )
  par <- suppressWarnings(as.numeric(par))
  mfrmr_gno_assert(
    length(par) == nrow(context$coordinates) && all(is.finite(par)),
    "`par` must match the finite identified-free GPCM coordinate vector."
  )

  # Additive/step/population coordinates are deliberately held to the package's
  # declared identification contract. The slope transformation below does not
  # consume params$log_slopes or params$slopes, so a shared slope-expansion bug
  # cannot manufacture oracle agreement.
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

  slope_slice <- as.integer(context$slices$log_slopes)
  slope_levels <- as.character(context$config$gpcm_spec$levels)
  mfrmr_gno_assert(
    length(slope_levels) >= 2L &&
      length(slope_slice) == length(slope_levels) - 1L,
    "The GPCM context has an invalid identified slope dimension."
  )
  independent_slopes <- mfrmr_gno_expand_slopes(par[slope_slice])

  n_obs <- length(context$idx$score_k)
  n_cat <- as.integer(context$config$n_cat)
  k_values <- 0:(n_cat - 1L)
  step_cumulative <- t(apply(
    params$steps_mat,
    1L,
    function(value) c(0, cumsum(value))
  ))
  step_cumulative_observed <- step_cumulative[
    context$idx$step_idx, , drop = FALSE
  ]
  slope_observed <- independent_slopes$slopes[context$idx$slope_idx]
  mfrmr_gno_assert(
    length(slope_observed) == n_obs && all(is.finite(slope_observed)) &&
      all(slope_observed > 0),
    "The independently expanded slopes do not index the observed responses."
  )

  observed <- cbind(seq_len(n_obs), context$idx$score_k + 1L)
  log_probability_matrix <- matrix(
    NA_real_, nrow = n_obs, ncol = ncol(quad_basis$nodes)
  )
  probability_list <- vector("list", ncol(quad_basis$nodes))
  for (node in seq_len(ncol(quad_basis$nodes))) {
    eta <- base_eta + quad_basis$nodes[context$idx$person, node]
    linear_part <- outer(eta, k_values) - step_cumulative_observed
    log_kernel <- linear_part * slope_observed
    row_maximum <- apply(log_kernel, 1L, max)
    log_normalizer <- row_maximum +
      log(rowSums(exp(log_kernel - row_maximum)))
    probability <- exp(log_kernel - log_normalizer)
    log_probability <- log_kernel[observed] - log_normalizer
    if (!is.null(context$idx$weight)) {
      log_probability <- log_probability * context$idx$weight
    }
    log_probability_matrix[, node] <- log_probability
    probability_list[[node]] <- probability
  }

  log_likelihood_by_person <- rowsum(
    log_probability_matrix,
    context$idx$person,
    reorder = FALSE
  )
  person_ids <- as.integer(rownames(log_likelihood_by_person))
  log_joint <- quad_basis$log_weights[person_ids, , drop = FALSE] +
    log_likelihood_by_person
  row_maximum <- apply(log_joint, 1L, max)
  objective <- -sum(
    row_maximum + log(rowSums(exp(log_joint - row_maximum)))
  )

  list(
    log_prob_mat = log_probability_matrix,
    probability_list = probability_list,
    objective = objective,
    log_slopes = independent_slopes$log_slopes,
    slopes = independent_slopes$slopes,
    geometric_mean_residual =
      independent_slopes$geometric_mean_residual
  )
}

mfrmr_gno_point <- function(fit, point) {
  mfrmr_gno_require_base_contract()
  point <- match.arg(point, mfrmr_gno_expected_points)
  context <- mfrmr_num_fit_context(fit)
  par <- as.numeric(fit$opt$par)
  slope_slice <- as.integer(context$slices$log_slopes)
  n_levels <- length(fit$config$gpcm_spec$levels)

  if (identical(point, "retained_solution")) return(par)
  if (identical(point, "high_dispersion_probe")) {
    target <- exp(seq(log(0.45), log(2.20), length.out = n_levels))
    target_log <- log(target) - mean(log(target))
  } else {
    target_log <- seq(-3, 3, length.out = n_levels)
    if (identical(point, "finite_slope_stress_reverse")) {
      target_log <- rev(target_log)
    }
  }
  par[slope_slice] <- target_log[seq_len(n_levels - 1L)]
  par
}

mfrmr_gno_probability_difference <- function(left, right) {
  mfrmr_gno_assert(
    is.list(left) && is.list(right) && length(left) == length(right) &&
      length(left) > 0L,
    "Probability lists must have the same positive length."
  )
  dimensions_match <- all(vapply(
    seq_along(left),
    function(index) identical(dim(left[[index]]), dim(right[[index]])),
    logical(1L)
  ))
  if (!dimensions_match) return(NA_real_)
  difference <- unlist(Map(
    function(x, y) as.numeric(x) - as.numeric(y),
    left,
    right
  ), use.names = FALSE)
  if (length(difference) == 0L || any(!is.finite(difference))) {
    return(NA_real_)
  }
  max(abs(difference))
}

mfrmr_gno_audit_fit <- function(fit,
                                primary_step = mfrmr_gno_primary_step) {
  mfrmr_gno_require_base_contract()
  context <- mfrmr_num_fit_context(fit)
  mfrmr_gno_assert(
    identical(as.character(fit$config$model), "GPCM"),
    "`fit` must use model = 'GPCM'."
  )
  slope_slice <- as.integer(context$slices$log_slopes)
  rows <- lapply(mfrmr_gno_expected_points, function(point) {
    par <- mfrmr_gno_point(fit, point)
    route <- mfrmr_num_logprob_bundle(context, par, include_probs = TRUE)
    route_objective <- suppressWarnings(as.numeric(context$fn(par))[1])
    route_score <- suppressWarnings(as.numeric(context$gr(par)))
    oracle <- mfrmr_gno_independent_oracle(context, par)
    oracle_score <- mfrmr_num_central_gradient(
      function(value) mfrmr_gno_independent_oracle(context, value)$objective,
      par,
      rel_step = primary_step
    )
    package_params <- mfrmr_num_get("expand_params")(
      par, context$sizes, context$config
    )
    score_difference <- abs(route_score - oracle_score)
    finite <- all(is.finite(c(
      route$log_prob_mat,
      route_objective,
      route_score,
      oracle$log_prob_mat,
      oracle$objective,
      oracle_score,
      oracle$log_slopes,
      oracle$slopes,
      package_params$log_slopes,
      package_params$slopes
    )))
    data.frame(
      ContractVersion = mfrmr_gno_contract_version,
      Point = point,
      PrimaryRelativeStep = primary_step,
      FreeCoordinates = length(par),
      FreeSlopeCoordinates = length(slope_slice),
      MinSlope = min(oracle$slopes),
      MaxSlope = max(oracle$slopes),
      GeometricMeanResidual = oracle$geometric_mean_residual,
      LogProbabilityMaxAbsDifference = if (finite) {
        max(abs(route$log_prob_mat - oracle$log_prob_mat))
      } else {
        NA_real_
      },
      ProbabilityMaxAbsDifference = if (finite) {
        mfrmr_gno_probability_difference(
          route$prob_list, oracle$probability_list
        )
      } else {
        NA_real_
      },
      ObjectiveAbsDifference = if (finite) {
        abs(route_objective - oracle$objective)
      } else {
        NA_real_
      },
      ScoreMaxAbsDifference = if (finite) {
        max(score_difference)
      } else {
        NA_real_
      },
      SlopeScoreMaxAbsDifference = if (finite) {
        max(score_difference[slope_slice])
      } else {
        NA_real_
      },
      ExpandedLogSlopeMaxAbsDifference = if (finite) {
        max(abs(package_params$log_slopes - oracle$log_slopes))
      } else {
        NA_real_
      },
      ExpandedSlopeMaxAbsDifference = if (finite) {
        max(abs(package_params$slopes - oracle$slopes))
      } else {
        NA_real_
      },
      EvaluationComplete = finite,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gno_decision <- function(audit) {
  required <- c(
    "ContractVersion", "Point", "PrimaryRelativeStep",
    "LogProbabilityMaxAbsDifference",
    "ProbabilityMaxAbsDifference", "ObjectiveAbsDifference",
    "ScoreMaxAbsDifference", "SlopeScoreMaxAbsDifference",
    "ExpandedLogSlopeMaxAbsDifference", "ExpandedSlopeMaxAbsDifference",
    "GeometricMeanResidual", "EvaluationComplete", "SelectionAuthorized",
    "ConfirmationAuthorized"
  )
  complete_structure <- is.data.frame(audit) &&
    all(required %in% names(audit)) &&
    nrow(audit) == length(mfrmr_gno_expected_points) &&
    !anyDuplicated(audit$Point) &&
    identical(
      sort(as.character(audit$Point)),
      sort(mfrmr_gno_expected_points)
    ) &&
    all(as.character(audit$ContractVersion) == mfrmr_gno_contract_version)
  step_complete <- complete_structure &&
    all(is.finite(audit$PrimaryRelativeStep)) &&
    all(audit$PrimaryRelativeStep == mfrmr_gno_primary_step)
  numeric_complete <- step_complete && all(audit$EvaluationComplete) &&
    all(is.finite(unlist(audit[c(
      "LogProbabilityMaxAbsDifference",
      "ProbabilityMaxAbsDifference",
      "ObjectiveAbsDifference",
      "ScoreMaxAbsDifference",
      "SlopeScoreMaxAbsDifference",
      "ExpandedLogSlopeMaxAbsDifference",
      "ExpandedSlopeMaxAbsDifference",
      "GeometricMeanResidual"
    )], use.names = FALSE)))
  exact <- numeric_complete &&
    all(audit$LogProbabilityMaxAbsDifference <=
          mfrmr_gno_limits["log_probability"]) &&
    all(audit$ProbabilityMaxAbsDifference <=
          mfrmr_gno_limits["probability"]) &&
    all(audit$ObjectiveAbsDifference <= mfrmr_gno_limits["objective"]) &&
    all(audit$ScoreMaxAbsDifference <= mfrmr_gno_limits["score"]) &&
    all(audit$SlopeScoreMaxAbsDifference <= mfrmr_gno_limits["score"]) &&
    all(audit$ExpandedLogSlopeMaxAbsDifference <=
          mfrmr_gno_limits["transform"]) &&
    all(audit$ExpandedSlopeMaxAbsDifference <=
          mfrmr_gno_limits["transform"]) &&
    all(audit$GeometricMeanResidual <=
          mfrmr_gno_limits["geometric_mean"]) &&
    all(audit$SelectionAuthorized %in% FALSE) &&
    all(audit$ConfirmationAuthorized %in% FALSE)
  data.frame(
    ContractVersion = mfrmr_gno_contract_version,
    ExpectedPoints = length(mfrmr_gno_expected_points),
    CompleteStructure = complete_structure,
    NumericComplete = numeric_complete,
    NonunitOracleObserved = exact,
    Status = if (exact) "review_oracle_agreement" else "rejected",
    ScoreToleranceStatus = "pilot_required",
    BoundaryClaim = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_nonunit_score_oracle <- function() {
  mfrmr_gno_require_base_contract()
  fixture <- mfrmr_num_fixture("polytomous_fixed")
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  fit <- suppressMessages(suppressWarnings(fit_fun(
    fixture$data,
    person = "Person",
    facets = "Item",
    score = "Score",
    rating_min = fixture$rating_min,
    rating_max = fixture$rating_max,
    method = "MML",
    model = "GPCM",
    step_facet = "Item",
    slope_facet = "Item",
    quad_points = 31L,
    maxit = 2000L,
    reltol = 1e-12,
    optimizer = "L-BFGS-B",
    mml_engine = "direct"
  )))
  mfrmr_gno_assert(
    length(fit$opt$par) > 0L && all(is.finite(fit$opt$par)),
    "The fixed GPCM oracle fit did not retain a finite parameter vector."
  )
  audit <- mfrmr_gno_audit_fit(fit)
  decision <- mfrmr_gno_decision(audit)
  list(
    contract_version = mfrmr_gno_contract_version,
    fixture_id = fixture$fixture_id,
    fixture_sha256 = fixture$sha256,
    audit = audit,
    decision = decision,
    score_tolerance_status = "pilot_required",
    boundary_claim = FALSE,
    selection_authorized = FALSE,
    confirmation_authorized = FALSE
  )
}
