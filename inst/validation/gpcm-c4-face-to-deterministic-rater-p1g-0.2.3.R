# mfrmr 0.2.3 GPCM C4 face-to-deterministic-Rater P1g audit
#
# On the P1f single-target C4 face, target logits are
#   lambda [k(u_4 - q_r + z) - H_4k].
# Define V_4=lambda*u_4, B_r=lambda*q_r, and G_4=lambda*H_4. Then
#   k(V_4 - B_r + lambda*z) - G_4k
# is an exact finite-lambda reparameterization and remains defined at
# lambda=0. The limit retains C4 Rater structure but removes all latent-person
# variation. P1g profiles this one declared face and directly optimizes its
# deterministic-Rater endpoint. It does not close other target faces or the
# full empty-random-product hierarchy.

mfrmr_gc4_p1g_specification <- "0.2.3-draft.1"
mfrmr_gc4_p1g_contract <-
  "mfrmr_gpcm_c4_face_to_deterministic_rater_p1g_v1"
mfrmr_gc4_p1g_dependency_contract <-
  "mfrmr_gpcm_slope_rate_cone_p1f_v1"
mfrmr_gc4_p1g_dependency_sha256 <-
  "01e6b04af33565a4dc350fdd24285e619a5cc2cbaec35f8ce5d2ab49d99d59d9"
mfrmr_gc4_p1g_lambda_grid <- c(0, 0.001, 0.003, 0.01, 0.03, 0.1, 0.2)
mfrmr_gc4_p1g_routes <- c("p1e_forward_down", "boundary_reverse_up")
mfrmr_gc4_p1g_quadrature <- c(61L, 91L, 121L)
mfrmr_gc4_p1g_derivative_lambdas <- c(0, 0.2)
mfrmr_gc4_p1g_derivative_step <- 1e-6
mfrmr_gc4_p1g_gradient_check_tolerance <- 5e-6
mfrmr_gc4_p1g_identity_tolerance <- 1e-9
mfrmr_gc4_p1g_route_tolerance <- 1e-6
mfrmr_gc4_p1g_monotonicity_tolerance <- 1e-7

mfrmr_gc4_p1g_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gc4_p1g_require_sources <- function() {
  target <- environment(mfrmr_gc4_p1g_require_sources)
  required <- c(
    "mfrmr_gsrc_p1f_contract", "mfrmr_run_gpcm_slope_rate_cone_p1f",
    "mfrmr_gsrc_p1f_from_p1e", "mfrmr_gsrc_p1f_limit_bundle",
    "mfrmr_gsrc_p1f_layout", "mfrmr_gcl_p1e_transform",
    "mfrmr_gcl_p1e_optimize", "mfrmr_gcl_p1e_softmax",
    "mfrmr_gqi_p1b_context", "mfrmr_num_central_gradient",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector"
  )
  available <- vapply(
    required, exists, logical(1), envir = target, inherits = TRUE
  )
  mfrmr_gc4_p1g_assert(
    all(available) && identical(
      get("mfrmr_gsrc_p1f_contract", envir = target, inherits = TRUE),
      mfrmr_gc4_p1g_dependency_contract
    ),
    "Source P0 through P1f and their numerical dependencies before P1g."
  )
  invisible(TRUE)
}

mfrmr_gc4_p1g_plan <- function() {
  rows <- expand.grid(
    ScenarioId = mfrmr_gcl_p1e_scenarios,
    RouteId = mfrmr_gc4_p1g_routes,
    Lambda = mfrmr_gc4_p1g_lambda_grid,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  rows$ScenarioOrder <- match(
    rows$ScenarioId, mfrmr_gcl_p1e_scenarios
  )
  rows$RouteOrder <- match(rows$RouteId, mfrmr_gc4_p1g_routes)
  rows$LambdaOrder <- match(rows$Lambda, mfrmr_gc4_p1g_lambda_grid)
  rows <- rows[order(
    rows$ScenarioOrder, rows$RouteOrder, rows$LambdaOrder
  ), , drop = FALSE]
  rownames(rows) <- NULL
  rows$OptimizationQuadrature <- 121L
  rows$IndependentDerivativeScheduled <-
    rows$Lambda %in% mfrmr_gc4_p1g_derivative_lambdas
  rows$SelectionAuthorized <- FALSE
  rows$ConfirmationAuthorized <- FALSE
  list(
    profile = rows,
    target_set = "C4",
    finite_transform =
      "B=lambda*q;V4=lambda*u4;G4=lambda*H4",
    direct_limit = "C4_deterministic_Rater_no_latent_person",
    FullC4FaceGloballyCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gc4_p1g_layout <- function(context) {
  n_rater <- length(context$config$facet_levels[["Rater"]])
  n_criterion <- length(context$config$facet_levels[["Criterion"]])
  position <- 1L
  allocate <- function(n) {
    out <- seq.int(position, length.out = n)
    position <<- position + n
    out
  }
  list(
    rater = allocate(n_rater - 1L),
    location = allocate(n_criterion),
    steps = allocate(context$sizes$steps),
    n_rater = n_rater,
    n_criterion = n_criterion,
    step_free_per_criterion = context$sizes$steps / n_criterion,
    dimension = position - 1L
  )
}

mfrmr_gc4_p1g_fixture_contract <- function(context, target_index) {
  target_index <- as.integer(target_index)[1L]
  levels <- as.character(context$config$facet_levels[["Criterion"]])
  base <- mfrmr_gcl_p1e_fixture_contract(context, target_index)
  data.frame(
    base,
    TargetIsC4 = target_index == 4L && identical(levels[target_index], "C4"),
    P1gExactFixtureContract = isTRUE(base$ExactFixtureContract) &&
      target_index == 4L && identical(levels[target_index], "C4"),
    FullC4FaceGloballyCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gc4_p1g_unpack <- function(z, context) {
  layout <- mfrmr_gc4_p1g_layout(context)
  z <- as.numeric(z)
  mfrmr_gc4_p1g_assert(
    length(z) == layout$dimension && all(is.finite(z)),
    "P1g scaled coordinate vector has invalid dimension or values."
  )
  rater <- mfrmr_gss_get("expand_facet")(
    z[layout$rater], layout$n_rater
  )
  step_free <- matrix(
    z[layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  step_matrix <- t(vapply(seq_len(layout$n_criterion), function(index) {
    mfrmr_gss_get("expand_sum_zero_vector")(
      step_free[index, ], context$config$n_cat - 1L
    )
  }, numeric(context$config$n_cat - 1L)))
  step_cumulative <- t(apply(
    step_matrix, 1L, function(value) c(0, cumsum(value))
  ))
  list(
    layout = layout,
    rater = rater,
    location = z[layout$location],
    step_free = step_free,
    step_matrix = step_matrix,
    step_cumulative = step_cumulative
  )
}

mfrmr_gc4_p1g_from_p1f <- function(y, context, target_index) {
  target_index <- as.integer(target_index)[1L]
  p1f_layout <- mfrmr_gsrc_p1f_layout(context, target_index)
  layout <- mfrmr_gc4_p1g_layout(context)
  y <- as.numeric(y)
  mfrmr_gc4_p1g_assert(
    length(y) == p1f_layout$dimension &&
      p1f_layout$dimension == layout$dimension + 1L &&
      target_index == 4L,
    "P1g conversion requires one valid single-target C4 P1f vector."
  )
  lambda <- exp(y[p1f_layout$log_lambda])
  mfrmr_gc4_p1g_assert(
    is.finite(lambda) && lambda > 0,
    "P1g conversion requires one finite positive target coefficient."
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
  list(
    z = z,
    lambda = lambda,
    target_index = target_index,
    ScaledDimension = layout$dimension,
    P1fDimension = p1f_layout$dimension,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gc4_p1g_to_p1f <- function(z, lambda, context, target_index) {
  target_index <- as.integer(target_index)[1L]
  lambda <- as.numeric(lambda)[1L]
  layout <- mfrmr_gc4_p1g_layout(context)
  p1f_layout <- mfrmr_gsrc_p1f_layout(context, target_index)
  z <- as.numeric(z)
  mfrmr_gc4_p1g_assert(
    length(z) == layout$dimension && all(is.finite(z)) &&
      is.finite(lambda) && lambda > 0 && target_index == 4L,
    "P1g inverse conversion requires finite scaled coordinates and lambda > 0."
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

mfrmr_gc4_p1g_limit_bundle <- function(
    z,
    lambda,
    context,
    target_index = 4L,
    include_gradient = TRUE) {
  lambda <- as.numeric(lambda)[1L]
  target_index <- as.integer(target_index)[1L]
  mfrmr_gc4_p1g_assert(
    is.finite(lambda) && lambda >= 0 && target_index == 4L,
    "P1g likelihood requires lambda >= 0 and the declared C4 target."
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
  target_observation <- criterion == target_index
  log_probability <- matrix(0, nrow = n, ncol = n_nodes)
  probability <- vector("list", n_nodes)
  for (q in seq_len(n_nodes)) {
    eta <- unpacked$location[criterion]
    eta[target_observation] <- eta[target_observation] -
      unpacked$rater[rater_index[target_observation]] +
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
      matrix(-posterior_residual[target_observation], ncol = 1L),
      rater_index[target_observation], reorder = FALSE
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

    lambda_score <- context$quad$nodes[q] * residual[target_observation] *
      observation_posterior[target_observation, q]
    if (!is.null(idx$weight)) {
      lambda_score <- lambda_score * idx$weight[target_observation]
    }
    score_lambda <- score_lambda + sum(lambda_score)
  }
  gradient <- c(
    -mfrmr_gss_get("project_sum_zero_gradient")(score_rater),
    -score_location,
    -mfrmr_gss_get("project_step_matrix_gradient")(score_step)
  )
  mfrmr_gc4_p1g_assert(
    length(gradient) == layout$dimension &&
      all(is.finite(c(gradient, score_lambda))),
    "P1g scaled likelihood gradient is invalid."
  )
  list(
    objective = objective,
    gradient = gradient,
    lambda_gradient = -score_lambda,
    log_probability = log_probability,
    posterior = posterior
  )
}

mfrmr_gc4_p1g_conditional_oracle <- function(
    z,
    context,
    target_index = 4L) {
  target_index <- as.integer(target_index)[1L]
  mfrmr_gc4_p1g_assert(
    target_index == 4L,
    "P1g conditional oracle is restricted to the declared C4 target."
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

mfrmr_gc4_p1g_identity_row <- function(
    scenario_id,
    route_id,
    y_p1f,
    contexts,
    target_index) {
  converted <- mfrmr_gc4_p1g_from_p1f(
    y_p1f, contexts[["121"]], target_index
  )
  recovered <- mfrmr_gc4_p1g_to_p1f(
    converted$z, converted$lambda, contexts[["121"]], target_index
  )
  p1f_objectives <- vapply(contexts, function(context) {
    mfrmr_gsrc_p1f_limit_bundle(
      y_p1f, context, target_index, include_gradient = FALSE
    )$objective
  }, numeric(1L))
  p1g_objectives <- vapply(contexts, function(context) {
    mfrmr_gc4_p1g_limit_bundle(
      converted$z, converted$lambda, context, target_index,
      include_gradient = FALSE
    )$objective
  }, numeric(1L))
  bundle <- mfrmr_gc4_p1g_limit_bundle(
    converted$z, converted$lambda, contexts[["121"]], target_index,
    include_gradient = TRUE
  )
  numeric_gradient <- mfrmr_num_central_gradient(
    function(value) mfrmr_gc4_p1g_limit_bundle(
      value, converted$lambda, contexts[["121"]], target_index,
      include_gradient = FALSE
    )$objective,
    converted$z,
    mfrmr_gc4_p1g_derivative_step
  )
  objective_difference <- max(abs(p1f_objectives - p1g_objectives))
  gradient_difference <- max(abs(bundle$gradient - numeric_gradient))
  data.frame(
    ScenarioId = scenario_id,
    RouteId = route_id,
    TargetSetId = "C4",
    Lambda = converted$lambda,
    CoordinateRoundtripMaxAbsDifference = max(abs(recovered - y_p1f)),
    P1fP1gObjectiveMaxAbsDifference = objective_difference,
    P1gAnalyticNumericGradientMaxAbsDifference = gradient_difference,
    IdentityComplete = all(is.finite(c(
      p1f_objectives, p1g_objectives, bundle$gradient, numeric_gradient
    ))) &&
      objective_difference <= mfrmr_gc4_p1g_identity_tolerance &&
      gradient_difference <= mfrmr_gc4_p1g_gradient_check_tolerance,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ScaledVectorSHA256 = mfrmr_gss_hash_vector(converted$z),
    stringsAsFactors = FALSE
  )
}

mfrmr_gc4_p1g_profile_candidate <- function(
    scenario_id,
    route_id,
    lambda,
    start,
    contexts,
    target_index,
    interior_objective,
    maxit,
    reltol) {
  fn <- function(value) mfrmr_gc4_p1g_limit_bundle(
    value, lambda, contexts[["121"]], target_index,
    include_gradient = FALSE
  )$objective
  gr <- function(value) mfrmr_gc4_p1g_limit_bundle(
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
  derivative_scheduled <- lambda %in% mfrmr_gc4_p1g_derivative_lambdas
  if (returned) {
    bundle <- mfrmr_gc4_p1g_limit_bundle(
      z, lambda, contexts[["121"]], target_index,
      include_gradient = TRUE
    )
    objective <- bundle$objective
    gradient <- bundle$gradient
    lambda_gradient <- bundle$lambda_gradient
    if (derivative_scheduled) {
      numeric_gradient <- tryCatch(
        mfrmr_num_central_gradient(
          fn, z, mfrmr_gc4_p1g_derivative_step
        ),
        error = function(condition) rep(NA_real_, length(z))
      )
    }
    objectives <- vapply(contexts, function(context) {
      mfrmr_gc4_p1g_limit_bundle(
        z, lambda, context, target_index, include_gradient = FALSE
      )$objective
    }, numeric(1L))
    if (lambda == 0) {
      oracle_difference <- abs(
        objective - mfrmr_gc4_p1g_conditional_oracle(
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
        derivative_difference <= mfrmr_gc4_p1g_gradient_check_tolerance
    )) &&
    (lambda != 0 || (
      is.finite(oracle_difference) &&
        oracle_difference <= mfrmr_gc4_p1g_identity_tolerance
    ))
  eligible <- complete && identical(severity, "pass")
  row <- data.frame(
    ScenarioId = scenario_id,
    RouteId = route_id,
    TargetSetId = "C4",
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
    FullC4FaceGloballyCertified = FALSE,
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

mfrmr_gc4_p1g_pairwise <- function(profile) {
  groups <- split(
    profile,
    interaction(profile$ScenarioId, profile$Lambda, drop = TRUE)
  )
  out <- lapply(groups, function(value) {
    forward <- value[value$RouteId == "p1e_forward_down", , drop = FALSE]
    reverse <- value[value$RouteId == "boundary_reverse_up", , drop = FALSE]
    complete <- nrow(forward) == 1L && nrow(reverse) == 1L
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      Lambda = value$Lambda[1L],
      BothRoutesPresent = complete,
      BothRoutesEligible = complete &&
        isTRUE(forward$ProfileCandidateEligible) &&
        isTRUE(reverse$ProfileCandidateEligible),
      ObjectiveAbsDifference = if (complete) {
        abs(forward$ObjectiveQ121 - reverse$ObjectiveQ121)
      } else NA_real_,
      RouteAgreementWithinCalibrationTolerance = complete &&
        is.finite(forward$ObjectiveQ121) && is.finite(reverse$ObjectiveQ121) &&
        abs(forward$ObjectiveQ121 - reverse$ObjectiveQ121) <=
          mfrmr_gc4_p1g_route_tolerance,
      FullC4FaceGloballyCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result[order(
    match(result$ScenarioId, mfrmr_gcl_p1e_scenarios), result$Lambda
  ), , drop = FALSE]
}

mfrmr_gc4_p1g_decision <- function(
    scenario_id,
    profile,
    pairwise) {
  rows <- profile[profile$ScenarioId == scenario_id, , drop = FALSE]
  pairs <- pairwise[pairwise$ScenarioId == scenario_id, , drop = FALSE]
  mfrmr_gc4_p1g_assert(
    nrow(rows) == 2L * length(mfrmr_gc4_p1g_lambda_grid) &&
      nrow(pairs) == length(mfrmr_gc4_p1g_lambda_grid),
    "P1g decision requires the complete two-route C4 profile."
  )
  route_monotone <- vapply(mfrmr_gc4_p1g_routes, function(route_id) {
    value <- rows[rows$RouteId == route_id, , drop = FALSE]
    value <- value[order(value$Lambda), , drop = FALSE]
    all(diff(value$ObjectiveQ121) >= -mfrmr_gc4_p1g_monotonicity_tolerance)
  }, logical(1L))
  endpoint <- rows[rows$Lambda == 0, , drop = FALSE]
  all_eligible <- all(rows$ProfileCandidateEligible)
  endpoint_eligible <- nrow(endpoint) == 2L &&
    all(endpoint$ProfileCandidateEligible)
  endpoint_above <- endpoint_eligible &&
    all(endpoint$ProfileMinusInteriorObjective > 0)
  routes_agree <- all(pairs$BothRoutesEligible) &&
    all(pairs$RouteAgreementWithinCalibrationTolerance)
  positive_derivatives <- all(
    rows$LambdaObjectiveDerivative[rows$Lambda > 0] >=
      -mfrmr_gc4_p1g_monotonicity_tolerance
  )
  endpoint_derivatives_zero <- all(
    abs(endpoint$LambdaObjectiveDerivative) <=
      mfrmr_gc4_p1g_identity_tolerance
  )
  status <- if (
    all_eligible && all(route_monotone) && endpoint_above && routes_agree &&
      positive_derivatives && endpoint_derivatives_zero
  ) {
    "declared_c4_face_grid_descends_to_stationary_deterministic_rater_limit_above_interior"
  } else if (endpoint_eligible) {
    "c4_deterministic_rater_limit_observed_face_grid_inconclusive"
  } else {
    "c4_face_to_deterministic_rater_audit_inconclusive"
  }
  data.frame(
    ScenarioId = scenario_id,
    AllScaledProfilePointsEligible = all_eligible,
    BothRoutesMonotoneFromLambdaZero = all(route_monotone),
    AllPositiveLambdaGridDerivativesNonnegative = positive_derivatives,
    BothEndpointLambdaDerivativesNumericallyZero =
      endpoint_derivatives_zero,
    AllRoutePairsAgreeWithinCalibrationTolerance = routes_agree,
    BothDeterministicRaterEndpointsEligible = endpoint_eligible,
    BothEndpointObjectivesAboveInterior = endpoint_above,
    EndpointMinusInteriorMinimum = if (endpoint_eligible) {
      min(endpoint$ProfileMinusInteriorObjective)
    } else NA_real_,
    C4FaceGridStatus = status,
    DeclaredC4FaceGridLocallyAdjudicated = all_eligible &&
      all(route_monotone) && routes_agree && positive_derivatives &&
      endpoint_derivatives_zero,
    C4DeterministicRaterLimitAdjudicated = endpoint_eligible,
    FullC4FaceGloballyCertified = FALSE,
    OtherRandomTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    UpperVarianceJointPathStatus = "not_evaluated",
    SourceSolutionDecision =
      "blocked_other_target_faces_empty_random_hierarchy_and_upper_boundary_open",
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gc4_p1g_signature <- function(decision) {
  data.frame(
    Metric = c(
      "c4_scaled_profile", "c4_deterministic_rater_limit",
      "full_c4_face", "other_random_target_faces",
      "empty_random_product_hierarchy", "upper_joint_variance_boundary",
      "source_solution_selection", "hessian", "dff_fit_rank", "overall"
    ),
    State = c(
      as.character(decision$C4FaceGridStatus),
      if (isTRUE(decision$C4DeterministicRaterLimitAdjudicated)) {
        "stationary_direct_conditional_limit"
      } else "blocked",
      "not_globally_certified", "not_evaluated", "incomplete",
      "not_evaluated", "blocked", "not_evaluated", "not_evaluated",
      "review"
    ),
    Eligibility = c(
      "declared_c4_grid_calibration_only",
      "declared_c4_deterministic_rater_stratum_only",
      rep("not_selection_eligible", 8L)
    ),
    Reason = c(
      "exact_lambda_scaled_coordinates_and_two_route_profile",
      "lambda_zero_matches_independent_conditional_oracle",
      "finite_lambda_grid_does_not_exclude_unseen_interior_basin",
      "thirteen_other_nonempty_random_target_faces_remain",
      "only_the_c4_maximal_slope_rater_stratum_is_evaluated",
      "large_variance_joint_path_remains_separate",
      "global_boundary_work_remains_open",
      "source_solution_not_selected",
      "source_solution_not_selected",
      "p1g_c4_face_to_deterministic_rater_calibration_only"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_c4_face_to_deterministic_rater_p1g <- function(
    maxit = 800L,
    reltol = 1e-12,
    progress = FALSE,
    p1f = NULL) {
  mfrmr_gc4_p1g_require_sources()
  maxit <- as.integer(maxit)[1L]
  reltol <- as.numeric(reltol)[1L]
  mfrmr_gc4_p1g_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0,
    "P1g requires finite positive optimization controls."
  )
  if (is.null(p1f)) {
    p1f <- mfrmr_run_gpcm_slope_rate_cone_p1f(progress = progress)
  }
  mfrmr_gc4_p1g_assert(
    is.list(p1f) && identical(
      p1f$contract, mfrmr_gc4_p1g_dependency_contract
    ),
    "P1g requires one complete P1f dependency result."
  )
  plan <- mfrmr_gc4_p1g_plan()
  identity_rows <- list()
  fixture_rows <- list()
  profile_rows <- list()
  profile_objects <- list()
  identity_index <- fixture_index <- profile_index <- 1L
  for (scenario_id in mfrmr_gcl_p1e_scenarios) {
    source <- p1f$p1e$p1d$p1c$p0b$scenario_results[[scenario_id]]
    contexts <- lapply(mfrmr_gc4_p1g_quadrature, function(q) {
      mfrmr_gqi_p1b_context(source$fit, q)
    })
    names(contexts) <- as.character(mfrmr_gc4_p1g_quadrature)
    geometry <- p1f$p1e$p1d$geometry[
      p1f$p1e$p1d$geometry$ScenarioId == scenario_id, , drop = FALSE
    ]
    target_index <- as.integer(geometry$TargetSlopeIndex)
    fixture <- mfrmr_gc4_p1g_fixture_contract(
      contexts[["121"]], target_index
    )
    fixture$ScenarioId <- scenario_id
    fixture_rows[[fixture_index]] <- fixture
    fixture_index <- fixture_index + 1L
    anchor <- p1f$p1e$p1d$p1c$interior_candidate_objects[[scenario_id]]$opt$par
    transform <- mfrmr_gcl_p1e_transform(
      contexts[["121"]], anchor, target_index,
      max(mfrmr_gcl_p1e_t_ladder)
    )
    starts <- list()
    for (source_route in mfrmr_gcl_p1e_routes) {
      p1e_candidate <- p1f$p1e$reduced_limit_candidate_objects[[paste(
        scenario_id, source_route, sep = "::"
      )]]
      y_p1f <- mfrmr_gsrc_p1f_from_p1e(p1e_candidate$y, transform)
      identity_rows[[identity_index]] <- mfrmr_gc4_p1g_identity_row(
        scenario_id, source_route, y_p1f, contexts, target_index
      )
      identity_index <- identity_index + 1L
      starts[[source_route]] <- mfrmr_gc4_p1g_from_p1f(
        y_p1f, contexts[["121"]], target_index
      )$z
    }
    interior <- p1f$p1e$p1d$p1c$interior_candidates[
      p1f$p1e$p1d$p1c$interior_candidates$ScenarioId == scenario_id,
      , drop = FALSE
    ]
    for (route_id in mfrmr_gc4_p1g_routes) {
      source_route <- if (route_id == "p1e_forward_down") {
        "interior_forward"
      } else {
        "boundary_reverse"
      }
      lambda_order <- if (route_id == "p1e_forward_down") {
        rev(mfrmr_gc4_p1g_lambda_grid)
      } else {
        mfrmr_gc4_p1g_lambda_grid
      }
      previous <- starts[[source_route]]
      for (lambda in lambda_order) {
        if (isTRUE(progress)) message(
          "C4 face P1g: ", scenario_id, " / ", route_id,
          " / lambda=", lambda
        )
        candidate <- mfrmr_gc4_p1g_profile_candidate(
          scenario_id = scenario_id,
          route_id = route_id,
          lambda = lambda,
          start = previous,
          contexts = contexts,
          target_index = target_index,
          interior_objective = interior$CommonDenseObjective,
          maxit = maxit,
          reltol = reltol
        )
        key <- paste(scenario_id, route_id, lambda, sep = "::")
        profile_objects[[key]] <- candidate
        profile_rows[[profile_index]] <- candidate$row
        profile_index <- profile_index + 1L
        if (isTRUE(candidate$row$FitReturned)) previous <- candidate$z
      }
    }
  }
  fixture_table <- do.call(rbind, fixture_rows)
  rownames(fixture_table) <- NULL
  identity_table <- do.call(rbind, identity_rows)
  rownames(identity_table) <- NULL
  profile_table <- do.call(rbind, profile_rows)
  rownames(profile_table) <- NULL
  profile_table <- profile_table[order(
    match(profile_table$ScenarioId, mfrmr_gcl_p1e_scenarios),
    match(profile_table$RouteId, mfrmr_gc4_p1g_routes),
    profile_table$Lambda
  ), , drop = FALSE]
  pairwise <- mfrmr_gc4_p1g_pairwise(profile_table)
  decisions <- do.call(rbind, lapply(
    mfrmr_gcl_p1e_scenarios,
    mfrmr_gc4_p1g_decision,
    profile = profile_table,
    pairwise = pairwise
  ))
  rownames(decisions) <- NULL
  signatures <- setNames(lapply(
    mfrmr_gcl_p1e_scenarios,
    function(scenario_id) mfrmr_gc4_p1g_signature(decisions[
      decisions$ScenarioId == scenario_id, , drop = FALSE
    ])
  ), mfrmr_gcl_p1e_scenarios)
  structure(
    list(
      contract = mfrmr_gc4_p1g_contract,
      specification = mfrmr_gc4_p1g_specification,
      dependency_contract = mfrmr_gc4_p1g_dependency_contract,
      dependency_sha256 = mfrmr_gc4_p1g_dependency_sha256,
      plan = plan,
      fixture_contracts = fixture_table,
      nested_p1f_identity = identity_table,
      profile = profile_table,
      profile_objects = profile_objects,
      pairwise = pairwise,
      decisions = decisions,
      decision_signatures = signatures,
      p1f = p1f,
      DeclaredC4FaceGridLocallyAdjudicated = all(
        decisions$DeclaredC4FaceGridLocallyAdjudicated
      ),
      C4DeterministicRaterLimitAdjudicated = all(
        decisions$C4DeterministicRaterLimitAdjudicated
      ),
      FullC4FaceGloballyCertified = FALSE,
      OtherRandomTargetFacesEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      UpperVarianceJointPathStatus = "not_evaluated",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_c4_face_to_deterministic_rater_p1g"
  )
}
