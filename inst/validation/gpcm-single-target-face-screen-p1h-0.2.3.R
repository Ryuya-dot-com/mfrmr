# mfrmr 0.2.3 GPCM remaining single-target face P1h audit
#
# P1g established exact lambda-scaled coordinates for C4. P1h applies the
# same mathematical construction to C1--C3 without rerunning C4. For target t,
#   B_r=lambda_t*q_r, V_t=lambda_t*u_t, G_t=lambda_t*H_t
# gives target logits k(V_t-B_r+lambda_t*z)-G_t and a direct lambda_t=0
# deterministic-Rater endpoint. This screens all remaining single-target
# faces and singleton deterministic-Rater strata, not multiple-target faces.

mfrmr_gst_p1h_specification <- "0.2.3-draft.1"
mfrmr_gst_p1h_contract <- "mfrmr_gpcm_single_target_face_screen_p1h_v1"
mfrmr_gst_p1h_dependency_contract <-
  "mfrmr_gpcm_c4_face_to_deterministic_rater_p1g_v1"
mfrmr_gst_p1h_dependency_sha256 <-
  "210bba683ab154d9684db9bb2fab67b7f56d8478cf950e0de742db2563f239f3"
mfrmr_gst_p1h_target_indices <- 1:3
mfrmr_gst_p1h_routes <- c("interior_down", "c4_endpoint_reverse_up")
mfrmr_gst_p1h_lambda_grid <- mfrmr_gc4_p1g_lambda_grid
mfrmr_gst_p1h_quadrature <- mfrmr_gc4_p1g_quadrature
mfrmr_gst_p1h_derivative_lambdas <- mfrmr_gc4_p1g_derivative_lambdas
mfrmr_gst_p1h_derivative_step <- mfrmr_gc4_p1g_derivative_step
mfrmr_gst_p1h_gradient_check_tolerance <-
  mfrmr_gc4_p1g_gradient_check_tolerance
mfrmr_gst_p1h_identity_tolerance <- mfrmr_gc4_p1g_identity_tolerance
mfrmr_gst_p1h_route_tolerance <- mfrmr_gc4_p1g_route_tolerance
mfrmr_gst_p1h_monotonicity_tolerance <-
  mfrmr_gc4_p1g_monotonicity_tolerance

mfrmr_gst_p1h_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gst_p1h_require_sources <- function() {
  target <- environment(mfrmr_gst_p1h_require_sources)
  required <- c(
    "mfrmr_gc4_p1g_contract",
    "mfrmr_run_gpcm_c4_face_to_deterministic_rater_p1g",
    "mfrmr_gc4_p1g_layout", "mfrmr_gc4_p1g_unpack",
    "mfrmr_gsrc_p1f_layout", "mfrmr_gsrc_p1f_limit_bundle",
    "mfrmr_gcl_p1e_optimize", "mfrmr_gcl_p1e_softmax",
    "mfrmr_gqi_p1b_context", "mfrmr_num_central_gradient",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector"
  )
  available <- vapply(
    required, exists, logical(1), envir = target, inherits = TRUE
  )
  mfrmr_gst_p1h_assert(
    all(available) && identical(
      get("mfrmr_gc4_p1g_contract", envir = target, inherits = TRUE),
      mfrmr_gst_p1h_dependency_contract
    ),
    "Source P0 through P1g and their numerical dependencies before P1h."
  )
  invisible(TRUE)
}

mfrmr_gst_p1h_plan <- function() {
  rows <- expand.grid(
    ScenarioId = mfrmr_gcl_p1e_scenarios,
    TargetIndex = mfrmr_gst_p1h_target_indices,
    RouteId = mfrmr_gst_p1h_routes,
    Lambda = mfrmr_gst_p1h_lambda_grid,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  rows$ScenarioOrder <- match(
    rows$ScenarioId, mfrmr_gcl_p1e_scenarios
  )
  rows$TargetOrder <- match(
    rows$TargetIndex, mfrmr_gst_p1h_target_indices
  )
  rows$RouteOrder <- match(rows$RouteId, mfrmr_gst_p1h_routes)
  rows$LambdaOrder <- match(rows$Lambda, mfrmr_gst_p1h_lambda_grid)
  rows <- rows[order(
    rows$ScenarioOrder, rows$TargetOrder,
    rows$RouteOrder, rows$LambdaOrder
  ), , drop = FALSE]
  rownames(rows) <- NULL
  rows$TargetSetId <- paste0("C", rows$TargetIndex)
  rows$OptimizationQuadrature <- 121L
  rows$IndependentDerivativeScheduled <-
    rows$Lambda %in% mfrmr_gst_p1h_derivative_lambdas
  rows$SelectionAuthorized <- FALSE
  rows$ConfirmationAuthorized <- FALSE
  list(
    profile = rows,
    new_target_sets = paste0("C", mfrmr_gst_p1h_target_indices),
    c4_evidence_source = "P1g",
    AllFourSingleTargetGridsScreened = FALSE,
    MultipleRandomTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gst_p1h_target_contract <- function(context, target_index) {
  target_index <- as.integer(target_index)[1L]
  levels <- as.character(context$config$facet_levels[["Criterion"]])
  base <- mfrmr_gcl_p1e_fixture_contract(context, target_index)
  data.frame(
    base,
    TargetSetId = levels[target_index],
    TargetIsNewSingle = target_index %in% mfrmr_gst_p1h_target_indices,
    P1hExactFixtureContract = isTRUE(base$ExactFixtureContract) &&
      target_index %in% mfrmr_gst_p1h_target_indices &&
      identical(levels[target_index], paste0("C", target_index)),
    MultipleRandomTargetFacesEvaluated = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gst_p1h_to_p1f <- function(z, lambda, context, target_index) {
  target_index <- as.integer(target_index)[1L]
  lambda <- as.numeric(lambda)[1L]
  layout <- mfrmr_gc4_p1g_layout(context)
  p1f_layout <- mfrmr_gsrc_p1f_layout(context, target_index)
  z <- as.numeric(z)
  mfrmr_gst_p1h_assert(
    length(z) == layout$dimension && all(is.finite(z)) &&
      is.finite(lambda) && lambda > 0 &&
      target_index %in% mfrmr_gst_p1h_target_indices,
    "P1h conversion requires one new single target and lambda > 0."
  )
  y <- numeric(p1f_layout$dimension)
  y[-p1f_layout$log_lambda] <- z
  y[p1f_layout$rater] <- z[layout$rater] / lambda
  y[p1f_layout$location[target_index]] <-
    z[layout$location[target_index]] / lambda
  steps <- matrix(
    z[layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  steps[target_index, ] <- steps[target_index, ] / lambda
  y[p1f_layout$steps] <- as.numeric(t(steps))
  y[p1f_layout$log_lambda] <- log(lambda)
  y
}

mfrmr_gst_p1h_from_p1f <- function(y, context, target_index) {
  target_index <- as.integer(target_index)[1L]
  layout <- mfrmr_gc4_p1g_layout(context)
  p1f_layout <- mfrmr_gsrc_p1f_layout(context, target_index)
  y <- as.numeric(y)
  mfrmr_gst_p1h_assert(
    length(y) == p1f_layout$dimension &&
      target_index %in% mfrmr_gst_p1h_target_indices,
    "P1h inverse conversion requires one new single target."
  )
  lambda <- exp(y[p1f_layout$log_lambda])
  mfrmr_gst_p1h_assert(
    is.finite(lambda) && lambda > 0,
    "P1h inverse conversion requires a finite positive coefficient."
  )
  z <- y[-p1f_layout$log_lambda]
  z[layout$rater] <- lambda * y[p1f_layout$rater]
  z[layout$location[target_index]] <-
    lambda * y[p1f_layout$location[target_index]]
  steps <- matrix(
    y[p1f_layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  steps[target_index, ] <- lambda * steps[target_index, ]
  z[layout$steps] <- as.numeric(t(steps))
  list(z = z, lambda = lambda, target_index = target_index)
}

mfrmr_gst_p1h_interior_start <- function(context, par, target_index) {
  target_index <- as.integer(target_index)[1L]
  layout <- mfrmr_gc4_p1g_layout(context)
  params <- mfrmr_gss_get("expand_params")(
    par, context$sizes, context$config
  )
  slopes <- as.numeric(params$slopes)
  sigma <- sqrt(as.numeric(params$population$sigma2))
  location <- as.numeric(params$population$coefficients[1L]) -
    as.numeric(params$facets[["Criterion"]])
  step_free <- matrix(
    par[context$slices$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  z <- numeric(layout$dimension)
  z[layout$rater] <-
    slopes[target_index] * par[context$slices$Rater]
  z[layout$location] <- slopes * location
  z[layout$steps] <- as.numeric(t(step_free * slopes))
  lambda <- slopes[target_index] * sigma
  mfrmr_gst_p1h_assert(
    all(is.finite(z)) && is.finite(lambda) && lambda > 0,
    "P1h interior-derived start is invalid."
  )
  list(
    z = z,
    lambda = lambda,
    slopes = slopes,
    sigma = sigma,
    target_index = target_index,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gst_p1h_bundle <- function(
    z,
    lambda,
    context,
    target_index,
    include_gradient = TRUE) {
  lambda <- as.numeric(lambda)[1L]
  target_index <- as.integer(target_index)[1L]
  mfrmr_gst_p1h_assert(
    is.finite(lambda) && lambda >= 0 &&
      target_index %in% mfrmr_gst_p1h_target_indices,
    "P1h likelihood requires lambda >= 0 and a C1--C3 target."
  )
  unpacked <- mfrmr_gc4_p1g_unpack(z, context)
  layout <- unpacked$layout
  idx <- context$idx
  n <- length(idx$score_k)
  n_nodes <- length(context$quad$nodes)
  k_values <- 0:(context$config$n_cat - 1L)
  observed_index <- cbind(seq_len(n), idx$score_k + 1L)
  criterion <- as.integer(idx$slope_idx)
  rater_index <- as.integer(idx$facets[["Rater"]])
  target <- criterion == target_index
  log_probability <- matrix(0, nrow = n, ncol = n_nodes)
  probability <- vector("list", n_nodes)
  for (q in seq_len(n_nodes)) {
    eta <- unpacked$location[criterion]
    eta[target] <- eta[target] - unpacked$rater[rater_index[target]] +
      lambda * context$quad$nodes[q]
    log_num <- outer(eta, k_values) -
      unpacked$step_cumulative[criterion, , drop = FALSE]
    softmax <- mfrmr_gcl_p1e_softmax(log_num)
    lp <- log_num[observed_index] - softmax$log_denom
    if (!is.null(idx$weight)) lp <- lp * idx$weight
    log_probability[, q] <- lp
    probability[[q]] <- softmax$probs
  }
  ll_by_person <- rowsum(log_probability, idx$person, reorder = FALSE)
  person_ids <- as.integer(rownames(ll_by_person))
  log_weights <- log(as.numeric(context$quad$weights))
  log_joint <- sweep(ll_by_person, 2L, log_weights, "+")
  row_max <- apply(log_joint, 1L, max)
  log_marginal <- row_max + log(rowSums(exp(log_joint - row_max)))
  objective <- -sum(log_marginal)
  if (!isTRUE(include_gradient)) return(list(objective = objective))

  posterior <- exp(log_joint - log_marginal)
  person_to_row <- integer(context$config$n_person)
  person_to_row[person_ids] <- seq_along(person_ids)
  observation_person_row <- person_to_row[idx$person]
  observation_posterior <- posterior[observation_person_row, , drop = FALSE]
  score_rater <- numeric(layout$n_rater)
  score_location <- numeric(layout$n_criterion)
  score_step <- matrix(
    0, nrow = layout$n_criterion,
    ncol = context$config$n_cat - 1L
  )
  score_lambda <- 0
  indicator_geq <- outer(
    idx$score_k, seq_len(context$config$n_cat - 1L), ">="
  ) * 1
  for (q in seq_len(n_nodes)) {
    probs <- probability[[q]]
    expected <- as.vector(probs %*% k_values)
    residual <- idx$score_k - expected
    posterior_residual <- residual * observation_posterior[, q]
    if (!is.null(idx$weight)) {
      posterior_residual <- posterior_residual * idx$weight
    }
    location_sum <- rowsum(
      matrix(posterior_residual, ncol = 1L), criterion, reorder = FALSE
    )
    location_ids <- as.integer(rownames(location_sum))
    score_location[location_ids] <- score_location[location_ids] +
      as.vector(location_sum)
    rater_sum <- rowsum(
      matrix(-posterior_residual[target], ncol = 1L),
      rater_index[target], reorder = FALSE
    )
    rater_ids <- as.integer(rownames(rater_sum))
    score_rater[rater_ids] <- score_rater[rater_ids] +
      as.vector(rater_sum)
    p_geq <- mfrmr_gss_get("compute_P_geq")(probs)
    step_score <- (p_geq - indicator_geq) *
      observation_posterior[, q]
    if (!is.null(idx$weight)) step_score <- step_score * idx$weight
    step_sum <- rowsum(step_score, criterion, reorder = FALSE)
    step_ids <- as.integer(rownames(step_sum))
    score_step[step_ids, ] <- score_step[step_ids, , drop = FALSE] +
      step_sum
    lambda_score <- context$quad$nodes[q] * residual[target] *
      observation_posterior[target, q]
    if (!is.null(idx$weight)) {
      lambda_score <- lambda_score * idx$weight[target]
    }
    score_lambda <- score_lambda + sum(lambda_score)
  }
  gradient <- c(
    -mfrmr_gss_get("project_sum_zero_gradient")(score_rater),
    -score_location,
    -mfrmr_gss_get("project_step_matrix_gradient")(score_step)
  )
  mfrmr_gst_p1h_assert(
    length(gradient) == layout$dimension &&
      all(is.finite(c(gradient, score_lambda))),
    "P1h scaled likelihood gradient is invalid."
  )
  list(
    objective = objective,
    gradient = gradient,
    lambda_gradient = -score_lambda,
    log_probability = log_probability,
    posterior = posterior
  )
}

mfrmr_gst_p1h_conditional_oracle <- function(
    z,
    context,
    target_index) {
  target_index <- as.integer(target_index)[1L]
  mfrmr_gst_p1h_assert(
    target_index %in% mfrmr_gst_p1h_target_indices,
    "P1h oracle requires a C1--C3 target."
  )
  unpacked <- mfrmr_gc4_p1g_unpack(z, context)
  idx <- context$idx
  n <- length(idx$score_k)
  k_values <- 0:(context$config$n_cat - 1L)
  criterion <- as.integer(idx$slope_idx)
  rater_index <- as.integer(idx$facets[["Rater"]])
  target <- criterion == target_index
  eta <- unpacked$location[criterion]
  eta[target] <- eta[target] - unpacked$rater[rater_index[target]]
  log_num <- outer(eta, k_values) -
    unpacked$step_cumulative[criterion, , drop = FALSE]
  softmax <- mfrmr_gcl_p1e_softmax(log_num)
  log_probability <- log_num[cbind(seq_len(n), idx$score_k + 1L)] -
    softmax$log_denom
  if (!is.null(idx$weight)) log_probability <- log_probability * idx$weight
  list(
    objective = -sum(log_probability),
    log_probability = log_probability,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gst_p1h_identity_row <- function(
    scenario_id,
    start,
    contexts,
    target_index) {
  y <- mfrmr_gst_p1h_to_p1f(
    start$z, start$lambda, contexts[["121"]], target_index
  )
  recovered <- mfrmr_gst_p1h_from_p1f(
    y, contexts[["121"]], target_index
  )
  p1f_objectives <- vapply(contexts, function(context) {
    mfrmr_gsrc_p1f_limit_bundle(
      y, context, target_index, include_gradient = FALSE
    )$objective
  }, numeric(1L))
  p1h_objectives <- vapply(contexts, function(context) {
    mfrmr_gst_p1h_bundle(
      start$z, start$lambda, context, target_index,
      include_gradient = FALSE
    )$objective
  }, numeric(1L))
  bundle <- mfrmr_gst_p1h_bundle(
    start$z, start$lambda, contexts[["121"]], target_index,
    include_gradient = TRUE
  )
  numeric_gradient <- mfrmr_num_central_gradient(
    function(value) mfrmr_gst_p1h_bundle(
      value, start$lambda, contexts[["121"]], target_index,
      include_gradient = FALSE
    )$objective,
    start$z,
    mfrmr_gst_p1h_derivative_step
  )
  objective_difference <- max(abs(p1f_objectives - p1h_objectives))
  gradient_difference <- max(abs(bundle$gradient - numeric_gradient))
  data.frame(
    ScenarioId = scenario_id,
    TargetIndex = target_index,
    TargetSetId = paste0("C", target_index),
    InteriorLambda = start$lambda,
    CoordinateRoundtripMaxAbsDifference = max(abs(
      recovered$z - start$z
    )),
    LambdaRoundtripAbsDifference = abs(recovered$lambda - start$lambda),
    P1fP1hObjectiveMaxAbsDifference = objective_difference,
    P1hAnalyticNumericGradientMaxAbsDifference = gradient_difference,
    IdentityComplete = all(is.finite(c(
      p1f_objectives, p1h_objectives, bundle$gradient, numeric_gradient
    ))) &&
      objective_difference <= mfrmr_gst_p1h_identity_tolerance &&
      gradient_difference <= mfrmr_gst_p1h_gradient_check_tolerance,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ScaledVectorSHA256 = mfrmr_gss_hash_vector(start$z),
    stringsAsFactors = FALSE
  )
}

mfrmr_gst_p1h_profile_candidate <- function(
    scenario_id,
    target_index,
    route_id,
    lambda,
    start,
    contexts,
    interior_objective,
    maxit,
    reltol) {
  fn <- function(value) mfrmr_gst_p1h_bundle(
    value, lambda, contexts[["121"]], target_index,
    include_gradient = FALSE
  )$objective
  gr <- function(value) mfrmr_gst_p1h_bundle(
    value, lambda, contexts[["121"]], target_index,
    include_gradient = TRUE
  )$gradient
  optimized <- mfrmr_gcl_p1e_optimize(start, fn, gr, maxit, reltol)
  returned <- isTRUE(optimized$returned)
  z <- optimized$par
  objective <- NA_real_
  gradient <- numeric(0)
  numeric_gradient <- numeric(0)
  lambda_gradient <- NA_real_
  objectives <- setNames(rep(NA_real_, length(contexts)), names(contexts))
  oracle_difference <- NA_real_
  derivative_scheduled <- lambda %in% mfrmr_gst_p1h_derivative_lambdas
  if (returned) {
    bundle <- mfrmr_gst_p1h_bundle(
      z, lambda, contexts[["121"]], target_index,
      include_gradient = TRUE
    )
    objective <- bundle$objective
    gradient <- bundle$gradient
    lambda_gradient <- bundle$lambda_gradient
    if (derivative_scheduled) {
      numeric_gradient <- tryCatch(
        mfrmr_num_central_gradient(
          fn, z, mfrmr_gst_p1h_derivative_step
        ),
        error = function(condition) rep(NA_real_, length(z))
      )
    }
    objectives <- vapply(contexts, function(context) {
      mfrmr_gst_p1h_bundle(
        z, lambda, context, target_index, include_gradient = FALSE
      )$objective
    }, numeric(1L))
    if (lambda == 0) {
      oracle_difference <- abs(
        objective - mfrmr_gst_p1h_conditional_oracle(
          z, contexts[["121"]], target_index
        )$objective
      )
    }
  }
  diagnostics <- optimized$selected$diagnostics %||% list()
  severity <- as.character(
    diagnostics$ConvergenceSeverity %||% "fail"
  )[1L]
  derivative_difference <- if (
    derivative_scheduled && length(gradient) == length(numeric_gradient) &&
      length(gradient) > 0L && all(is.finite(c(gradient, numeric_gradient)))
  ) max(abs(gradient - numeric_gradient)) else NA_real_
  complete <- returned && is.finite(objective) &&
    length(gradient) == length(start) &&
    all(is.finite(c(gradient, lambda_gradient, objectives))) &&
    (!derivative_scheduled || (
      is.finite(derivative_difference) &&
        derivative_difference <= mfrmr_gst_p1h_gradient_check_tolerance
    )) &&
    (lambda != 0 || (
      is.finite(oracle_difference) &&
        oracle_difference <= mfrmr_gst_p1h_identity_tolerance
    ))
  eligible <- complete && identical(severity, "pass")
  row <- data.frame(
    ScenarioId = scenario_id,
    TargetIndex = target_index,
    TargetSetId = paste0("C", target_index),
    RouteId = route_id,
    Lambda = lambda,
    LambdaBoundary = lambda == 0,
    FitReturned = returned,
    ObjectiveQ121 = objective,
    ObjectiveQ61 = as.numeric(objectives[["61"]]),
    ObjectiveQ91 = as.numeric(objectives[["91"]]),
    QuadratureObjectiveRange = if (all(is.finite(objectives))) {
      diff(range(objectives))
    } else NA_real_,
    InteriorObjectiveQ121 = as.numeric(interior_objective),
    ProfileMinusInteriorObjective = objective - as.numeric(interior_objective),
    ScaledGradientMaxAbs = if (
      length(gradient) > 0L && all(is.finite(gradient))
    ) max(abs(gradient)) else NA_real_,
    LambdaObjectiveDerivative = lambda_gradient,
    IndependentDerivativeScheduled = derivative_scheduled,
    AnalyticNumericScaledGradientMaxAbsDifference = derivative_difference,
    ConditionalOracleObjectiveAbsDifference = oracle_difference,
    ConvergenceCode = as.integer(
      diagnostics$ConvergenceCode %||% NA_integer_
    )[1L],
    ConvergenceReason = as.character(
      diagnostics$ConvergenceReason %||% "not_returned"
    )[1L],
    ConvergenceSeverity = severity,
    ProfileCandidateEligible = eligible,
    ProfileEligibilityReason = if (eligible) {
      if (lambda == 0) {
        "stationary_scaled_endpoint_and_conditional_oracle_complete"
      } else {
        "stationary_scaled_finite_lambda_profile_complete"
      }
    } else if (complete) {
      "scaled_profile_complete_but_stationarity_not_passed"
    } else {
      "scaled_profile_fit_or_derivative_incomplete"
    },
    FullSingleTargetFaceGloballyCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = optimized$elapsed,
    WarningCount = length(optimized$warnings),
    WarningText = paste(optimized$warnings, collapse = " | "),
    ErrorText = paste(
      optimized$errors[nzchar(optimized$errors)], collapse = " | "
    ),
    StartVectorSHA256 = mfrmr_gss_hash_vector(start),
    ReturnedVectorSHA256 = if (returned) {
      mfrmr_gss_hash_vector(z)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
  list(row = row, z = z, optimized = optimized)
}

mfrmr_gst_p1h_pairwise <- function(profile) {
  key <- interaction(
    profile$ScenarioId, profile$TargetIndex, profile$Lambda, drop = TRUE
  )
  groups <- split(profile, key)
  out <- lapply(groups, function(value) {
    down <- value[value$RouteId == "interior_down", , drop = FALSE]
    up <- value[value$RouteId == "c4_endpoint_reverse_up", , drop = FALSE]
    complete <- nrow(down) == 1L && nrow(up) == 1L
    difference <- if (complete) {
      abs(down$ObjectiveQ121 - up$ObjectiveQ121)
    } else NA_real_
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      TargetIndex = value$TargetIndex[1L],
      TargetSetId = value$TargetSetId[1L],
      Lambda = value$Lambda[1L],
      BothRoutesPresent = complete,
      BothRoutesEligible = complete &&
        isTRUE(down$ProfileCandidateEligible) &&
        isTRUE(up$ProfileCandidateEligible),
      ObjectiveAbsDifference = difference,
      RouteAgreementWithinCalibrationTolerance = complete &&
        is.finite(difference) &&
        difference <= mfrmr_gst_p1h_route_tolerance,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result[order(
    match(result$ScenarioId, mfrmr_gcl_p1e_scenarios),
    result$TargetIndex, result$Lambda
  ), , drop = FALSE]
}

mfrmr_gst_p1h_decision <- function(
    scenario_id,
    target_index,
    profile,
    pairwise) {
  rows <- profile[
    profile$ScenarioId == scenario_id &
      profile$TargetIndex == target_index, , drop = FALSE
  ]
  pairs <- pairwise[
    pairwise$ScenarioId == scenario_id &
      pairwise$TargetIndex == target_index, , drop = FALSE
  ]
  mfrmr_gst_p1h_assert(
    nrow(rows) == 2L * length(mfrmr_gst_p1h_lambda_grid) &&
      nrow(pairs) == length(mfrmr_gst_p1h_lambda_grid),
    "P1h decision requires one complete two-route single-target profile."
  )
  route_monotone <- vapply(mfrmr_gst_p1h_routes, function(route_id) {
    value <- rows[rows$RouteId == route_id, , drop = FALSE]
    value <- value[order(value$Lambda), , drop = FALSE]
    all(diff(value$ObjectiveQ121) >=
          -mfrmr_gst_p1h_monotonicity_tolerance)
  }, logical(1L))
  endpoint <- rows[rows$Lambda == 0, , drop = FALSE]
  all_eligible <- all(rows$ProfileCandidateEligible)
  endpoint_eligible <- nrow(endpoint) == 2L &&
    all(endpoint$ProfileCandidateEligible)
  endpoint_above <- endpoint_eligible &&
    all(endpoint$ProfileMinusInteriorObjective > 0)
  endpoint_below <- endpoint_eligible &&
    all(endpoint$ProfileMinusInteriorObjective < 0)
  routes_agree <- all(pairs$BothRoutesEligible) &&
    all(pairs$RouteAgreementWithinCalibrationTolerance)
  positive_derivatives <- all(
    rows$LambdaObjectiveDerivative[rows$Lambda > 0] >=
      -mfrmr_gst_p1h_monotonicity_tolerance
  )
  endpoint_derivatives_zero <- all(
    abs(endpoint$LambdaObjectiveDerivative) <=
      mfrmr_gst_p1h_identity_tolerance
  )
  complete <- all_eligible && all(route_monotone) && routes_agree &&
    positive_derivatives && endpoint_derivatives_zero
  status <- if (complete && endpoint_above) {
    "single_target_grid_descends_to_deterministic_rater_limit_above_interior"
  } else if (complete && endpoint_below) {
    "single_target_grid_descends_to_competitive_deterministic_rater_limit_below_interior"
  } else if (endpoint_eligible) {
    "single_target_deterministic_rater_limit_observed_grid_inconclusive"
  } else {
    "single_target_face_screen_inconclusive"
  }
  data.frame(
    ScenarioId = scenario_id,
    TargetIndex = target_index,
    TargetSetId = paste0("C", target_index),
    AllScaledProfilePointsEligible = all_eligible,
    BothRoutesMonotoneFromLambdaZero = all(route_monotone),
    AllPositiveLambdaGridDerivativesNonnegative = positive_derivatives,
    BothEndpointLambdaDerivativesNumericallyZero =
      endpoint_derivatives_zero,
    AllRoutePairsAgreeWithinCalibrationTolerance = routes_agree,
    BothDeterministicRaterEndpointsEligible = endpoint_eligible,
    BothEndpointObjectivesAboveInterior = endpoint_above,
    BothEndpointObjectivesBelowInterior = endpoint_below,
    EndpointMinusInteriorMinimum = if (endpoint_eligible) {
      min(endpoint$ProfileMinusInteriorObjective)
    } else NA_real_,
    EndpointMinusInteriorMaximum = if (endpoint_eligible) {
      max(endpoint$ProfileMinusInteriorObjective)
    } else NA_real_,
    SingleTargetGridStatus = status,
    SingleTargetGridLocallyAdjudicated = complete,
    SingletonDeterministicRaterLimitAdjudicated = endpoint_eligible,
    FullSingleTargetFaceGloballyCertified = FALSE,
    MultipleRandomTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gst_p1h_portfolio <- function(decisions, p1g) {
  new_rows <- decisions[, c(
    "ScenarioId", "TargetIndex", "TargetSetId",
    "SingleTargetGridStatus", "SingleTargetGridLocallyAdjudicated",
    "SingletonDeterministicRaterLimitAdjudicated",
    "EndpointMinusInteriorMinimum", "EndpointMinusInteriorMaximum"
  )]
  c4_rows <- lapply(seq_len(nrow(p1g$decisions)), function(index) {
    value <- p1g$decisions[index, , drop = FALSE]
    data.frame(
      ScenarioId = value$ScenarioId,
      TargetIndex = 4L,
      TargetSetId = "C4",
      SingleTargetGridStatus = value$C4FaceGridStatus,
      SingleTargetGridLocallyAdjudicated =
        value$DeclaredC4FaceGridLocallyAdjudicated,
      SingletonDeterministicRaterLimitAdjudicated =
        value$C4DeterministicRaterLimitAdjudicated,
      EndpointMinusInteriorMinimum = value$EndpointMinusInteriorMinimum,
      EndpointMinusInteriorMaximum = value$EndpointMinusInteriorMinimum,
      stringsAsFactors = FALSE
    )
  })
  out <- rbind(new_rows, do.call(rbind, c4_rows))
  rownames(out) <- NULL
  out[order(
    match(out$ScenarioId, mfrmr_gcl_p1e_scenarios), out$TargetIndex
  ), , drop = FALSE]
}

mfrmr_gst_p1h_overall_decision <- function(portfolio) {
  all_screened <- nrow(portfolio) ==
    length(mfrmr_gcl_p1e_scenarios) * 4L &&
    all(portfolio$SingleTargetGridLocallyAdjudicated) &&
    all(portfolio$SingletonDeterministicRaterLimitAdjudicated)
  data.frame(
    AllFourSingleTargetGridsScreened = all_screened,
    AllFourSingletonDeterministicRaterStrataScreened = all_screened,
    AnySingletonEndpointBelowQualifiedInterior = any(
      portfolio$EndpointMinusInteriorMaximum < 0
    ),
    MinimumSingletonEndpointMinusInterior = min(
      portfolio$EndpointMinusInteriorMinimum
    ),
    MultipleRandomTargetFacesEvaluated = FALSE,
    MultiCriterionDeterministicRaterStrataEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    UpperVarianceJointPathStatus = "not_evaluated",
    SourceSolutionDecision =
      "blocked_multiple_target_faces_multicriterion_rater_strata_and_upper_boundary_open",
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_single_target_face_screen_p1h <- function(
    maxit = 800L,
    reltol = 1e-12,
    progress = FALSE,
    p1g = NULL) {
  mfrmr_gst_p1h_require_sources()
  maxit <- as.integer(maxit)[1L]
  reltol <- as.numeric(reltol)[1L]
  mfrmr_gst_p1h_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0,
    "P1h requires finite positive optimization controls."
  )
  if (is.null(p1g)) {
    p1g <- mfrmr_run_gpcm_c4_face_to_deterministic_rater_p1g(
      progress = progress
    )
  }
  mfrmr_gst_p1h_assert(
    is.list(p1g) && identical(
      p1g$contract, mfrmr_gst_p1h_dependency_contract
    ),
    "P1h requires one complete P1g dependency result."
  )
  plan <- mfrmr_gst_p1h_plan()
  target_rows <- list()
  identity_rows <- list()
  profile_rows <- list()
  profile_objects <- list()
  target_row_index <- identity_index <- profile_index <- 1L
  for (scenario_id in mfrmr_gcl_p1e_scenarios) {
    source <- p1g$p1f$p1e$p1d$p1c$p0b$scenario_results[[scenario_id]]
    contexts <- lapply(mfrmr_gst_p1h_quadrature, function(q) {
      mfrmr_gqi_p1b_context(source$fit, q)
    })
    names(contexts) <- as.character(mfrmr_gst_p1h_quadrature)
    anchor <- p1g$p1f$p1e$p1d$p1c$
      interior_candidate_objects[[scenario_id]]$opt$par
    interior <- p1g$p1f$p1e$p1d$p1c$interior_candidates[
      p1g$p1f$p1e$p1d$p1c$interior_candidates$ScenarioId == scenario_id,
      , drop = FALSE
    ]
    c4_endpoint <- p1g$profile_objects[[paste(
      scenario_id, "boundary_reverse_up", 0, sep = "::"
    )]]$z
    for (target_index in mfrmr_gst_p1h_target_indices) {
      contract <- mfrmr_gst_p1h_target_contract(
        contexts[["121"]], target_index
      )
      contract$ScenarioId <- scenario_id
      target_rows[[target_row_index]] <- contract
      target_row_index <- target_row_index + 1L
      interior_start <- mfrmr_gst_p1h_interior_start(
        contexts[["121"]], anchor, target_index
      )
      identity_rows[[identity_index]] <- mfrmr_gst_p1h_identity_row(
        scenario_id, interior_start, contexts, target_index
      )
      identity_index <- identity_index + 1L
      starts <- list(
        interior_down = interior_start$z,
        c4_endpoint_reverse_up = c4_endpoint
      )
      for (route_id in mfrmr_gst_p1h_routes) {
        lambda_order <- if (route_id == "interior_down") {
          rev(mfrmr_gst_p1h_lambda_grid)
        } else {
          mfrmr_gst_p1h_lambda_grid
        }
        previous <- starts[[route_id]]
        for (lambda in lambda_order) {
          if (isTRUE(progress)) message(
            "Single-target P1h: ", scenario_id, " / C", target_index,
            " / ", route_id, " / lambda=", lambda
          )
          candidate <- mfrmr_gst_p1h_profile_candidate(
            scenario_id = scenario_id,
            target_index = target_index,
            route_id = route_id,
            lambda = lambda,
            start = previous,
            contexts = contexts,
            interior_objective = interior$CommonDenseObjective,
            maxit = maxit,
            reltol = reltol
          )
          key <- paste(
            scenario_id, target_index, route_id, lambda, sep = "::"
          )
          profile_objects[[key]] <- candidate
          profile_rows[[profile_index]] <- candidate$row
          profile_index <- profile_index + 1L
          if (isTRUE(candidate$row$FitReturned)) previous <- candidate$z
        }
      }
    }
  }
  target_table <- do.call(rbind, target_rows)
  rownames(target_table) <- NULL
  identity_table <- do.call(rbind, identity_rows)
  rownames(identity_table) <- NULL
  profile_table <- do.call(rbind, profile_rows)
  rownames(profile_table) <- NULL
  profile_table <- profile_table[order(
    match(profile_table$ScenarioId, mfrmr_gcl_p1e_scenarios),
    profile_table$TargetIndex,
    match(profile_table$RouteId, mfrmr_gst_p1h_routes),
    profile_table$Lambda
  ), , drop = FALSE]
  pairwise <- mfrmr_gst_p1h_pairwise(profile_table)
  decisions <- do.call(rbind, lapply(
    mfrmr_gcl_p1e_scenarios,
    function(scenario_id) do.call(rbind, lapply(
      mfrmr_gst_p1h_target_indices,
      mfrmr_gst_p1h_decision,
      scenario_id = scenario_id,
      profile = profile_table,
      pairwise = pairwise
    ))
  ))
  rownames(decisions) <- NULL
  portfolio <- mfrmr_gst_p1h_portfolio(decisions, p1g)
  overall <- mfrmr_gst_p1h_overall_decision(portfolio)
  structure(
    list(
      contract = mfrmr_gst_p1h_contract,
      specification = mfrmr_gst_p1h_specification,
      dependency_contract = mfrmr_gst_p1h_dependency_contract,
      dependency_sha256 = mfrmr_gst_p1h_dependency_sha256,
      plan = plan,
      target_contracts = target_table,
      nested_p1f_identity = identity_table,
      profile = profile_table,
      profile_objects = profile_objects,
      pairwise = pairwise,
      decisions = decisions,
      single_target_portfolio = portfolio,
      overall_decision = overall,
      p1g = p1g,
      AllFourSingleTargetGridsScreened =
        overall$AllFourSingleTargetGridsScreened,
      AllFourSingletonDeterministicRaterStrataScreened =
        overall$AllFourSingletonDeterministicRaterStrataScreened,
      MultipleRandomTargetFacesEvaluated = FALSE,
      MultiCriterionDeterministicRaterStrataEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      UpperVarianceJointPathStatus = "not_evaluated",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_single_target_face_screen_p1h"
  )
}
