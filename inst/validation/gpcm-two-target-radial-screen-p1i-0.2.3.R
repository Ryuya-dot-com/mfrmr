# mfrmr 0.2.3 GPCM two-target radial face P1i audit
#
# For a two-criterion target set T, write lambda_c=tau*kappa_c with tau>0
# and prod_{c in T} kappa_c=1. With B_r=tau*q_r,
# V_c=lambda_c*u_c, and G_ck=lambda_c*H_ck, target logits are
#   k(V_c-kappa_c*B_r+tau*kappa_c*z)-G_ck.
# This is exact for tau>0 and remains defined at tau=0, where the two target
# criteria retain proportional Rater effects kappa_c*B_r. P1i screens all six
# two-target faces with the relative coefficient free. It does not certify
# unseen within-face basins, coefficient-ratio infinity, or three-target faces.

mfrmr_gtr_p1i_specification <- "0.2.3-draft.1"
mfrmr_gtr_p1i_contract <- "mfrmr_gpcm_two_target_radial_screen_p1i_v1"
mfrmr_gtr_p1i_dependency_contract <-
  "mfrmr_gpcm_single_target_face_screen_p1h_v1"
mfrmr_gtr_p1i_dependency_sha256 <-
  "860d70528718414c6f8d63f2f92410ed5269ec0319c44db44f97d66b5685524a"
mfrmr_gtr_p1i_target_sets <- utils::combn(1:4, 2L, simplify = FALSE)
mfrmr_gtr_p1i_routes <- c("interior_down", "singleton_mean_reverse_up")
mfrmr_gtr_p1i_tau_grid <- mfrmr_gst_p1h_lambda_grid
mfrmr_gtr_p1i_quadrature <- mfrmr_gst_p1h_quadrature
mfrmr_gtr_p1i_derivative_taus <- mfrmr_gst_p1h_derivative_lambdas
mfrmr_gtr_p1i_derivative_step <- mfrmr_gst_p1h_derivative_step
mfrmr_gtr_p1i_gradient_check_tolerance <-
  mfrmr_gst_p1h_gradient_check_tolerance
mfrmr_gtr_p1i_identity_tolerance <- mfrmr_gst_p1h_identity_tolerance
mfrmr_gtr_p1i_route_tolerance <- 5e-6
mfrmr_gtr_p1i_monotonicity_tolerance <-
  mfrmr_gst_p1h_monotonicity_tolerance

mfrmr_gtr_p1i_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gtr_p1i_require_sources <- function() {
  target <- environment(mfrmr_gtr_p1i_require_sources)
  required <- c(
    "mfrmr_gst_p1h_contract",
    "mfrmr_run_gpcm_single_target_face_screen_p1h",
    "mfrmr_gc4_p1g_layout", "mfrmr_gc4_p1g_unpack",
    "mfrmr_gsrc_p1f_layout", "mfrmr_gsrc_p1f_limit_bundle",
    "mfrmr_gcl_p1e_optimize", "mfrmr_gcl_p1e_softmax",
    "mfrmr_gqi_p1b_context", "mfrmr_num_central_gradient",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector"
  )
  available <- vapply(
    required, exists, logical(1), envir = target, inherits = TRUE
  )
  mfrmr_gtr_p1i_assert(
    all(available) && identical(
      get("mfrmr_gst_p1h_contract", envir = target, inherits = TRUE),
      mfrmr_gtr_p1i_dependency_contract
    ),
    "Source P0 through P1h and their numerical dependencies before P1i."
  )
  invisible(TRUE)
}

mfrmr_gtr_p1i_target_id <- function(target_indices) {
  paste0("C", sort(as.integer(target_indices)), collapse = "+")
}

mfrmr_gtr_p1i_validate_target <- function(target_indices, n_criterion = 4L) {
  target_indices <- sort(unique(as.integer(target_indices)))
  mfrmr_gtr_p1i_assert(
    length(target_indices) == 2L &&
      all(target_indices >= 1L & target_indices <= n_criterion),
    "P1i requires exactly two distinct target criteria."
  )
  target_indices
}

mfrmr_gtr_p1i_plan <- function() {
  target_rows <- do.call(rbind, lapply(
    mfrmr_gtr_p1i_target_sets,
    function(value) data.frame(
      TargetSetId = mfrmr_gtr_p1i_target_id(value),
      TargetIndices = paste(value, collapse = ","),
      stringsAsFactors = FALSE
    )
  ))
  rows <- merge(
    expand.grid(
      ScenarioId = mfrmr_gcl_p1e_scenarios,
      RouteId = mfrmr_gtr_p1i_routes,
      Tau = mfrmr_gtr_p1i_tau_grid,
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    ),
    target_rows,
    by = NULL
  )
  rows$ScenarioOrder <- match(rows$ScenarioId, mfrmr_gcl_p1e_scenarios)
  rows$TargetOrder <- match(
    rows$TargetSetId,
    vapply(mfrmr_gtr_p1i_target_sets, mfrmr_gtr_p1i_target_id, character(1L))
  )
  rows$RouteOrder <- match(rows$RouteId, mfrmr_gtr_p1i_routes)
  rows$TauOrder <- match(rows$Tau, mfrmr_gtr_p1i_tau_grid)
  rows <- rows[order(
    rows$ScenarioOrder, rows$TargetOrder,
    rows$RouteOrder, rows$TauOrder
  ), , drop = FALSE]
  rownames(rows) <- NULL
  rows$OptimizationQuadrature <- 121L
  rows$IndependentDerivativeScheduled <-
    rows$Tau %in% mfrmr_gtr_p1i_derivative_taus
  rows$SelectionAuthorized <- FALSE
  rows$ConfirmationAuthorized <- FALSE
  list(
    profile = rows,
    pair_count = 6L,
    radial_coefficient = "tau=sqrt(lambda_1*lambda_2)",
    relative_coefficient =
      "kappa_c=lambda_c/tau;product_pair_kappa=1",
    AllTwoTargetGridsScreened = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gtr_p1i_layout <- function(context) {
  base <- mfrmr_gc4_p1g_layout(context)
  list(
    rater = base$rater,
    location = base$location,
    steps = base$steps,
    relative = base$dimension + 1L,
    n_rater = base$n_rater,
    n_criterion = base$n_criterion,
    step_free_per_criterion = base$step_free_per_criterion,
    base_dimension = base$dimension,
    dimension = base$dimension + 1L
  )
}

mfrmr_gtr_p1i_relative <- function(relative_log_kappa) {
  relative_log_kappa <- as.numeric(relative_log_kappa)[1L]
  mfrmr_gtr_p1i_assert(
    is.finite(relative_log_kappa),
    "P1i relative log coefficient must be finite."
  )
  kappa <- exp(c(relative_log_kappa, -relative_log_kappa))
  mfrmr_gtr_p1i_assert(
    all(is.finite(kappa) & kappa > 0),
    "P1i relative coefficients must be finite and positive."
  )
  list(
    relative_log_kappa = relative_log_kappa,
    log_kappa = c(relative_log_kappa, -relative_log_kappa),
    kappa = kappa,
    sign = c(1, -1),
    geometric_mean = exp(mean(log(kappa)))
  )
}

mfrmr_gtr_p1i_unpack <- function(w, context, target_indices) {
  layout <- mfrmr_gtr_p1i_layout(context)
  target_indices <- mfrmr_gtr_p1i_validate_target(
    target_indices, layout$n_criterion
  )
  w <- as.numeric(w)
  mfrmr_gtr_p1i_assert(
    length(w) == layout$dimension && all(is.finite(w)),
    "P1i scaled vector has invalid dimension or values."
  )
  base <- mfrmr_gc4_p1g_unpack(
    w[seq_len(layout$base_dimension)], context
  )
  relative <- mfrmr_gtr_p1i_relative(w[layout$relative])
  list(
    layout = layout,
    target_indices = target_indices,
    base = base,
    relative = relative
  )
}

mfrmr_gtr_p1i_from_p1f <- function(y, context, target_indices) {
  target_indices <- mfrmr_gtr_p1i_validate_target(target_indices)
  layout <- mfrmr_gtr_p1i_layout(context)
  p1f_layout <- mfrmr_gsrc_p1f_layout(context, target_indices)
  y <- as.numeric(y)
  mfrmr_gtr_p1i_assert(
    length(y) == p1f_layout$dimension &&
      p1f_layout$dimension == layout$dimension + 1L,
    "P1i conversion requires one valid two-target P1f vector."
  )
  lambda <- exp(y[p1f_layout$log_lambda])
  tau <- exp(mean(log(lambda)))
  kappa <- lambda / tau
  mfrmr_gtr_p1i_assert(
    all(is.finite(lambda) & lambda > 0) && is.finite(tau) && tau > 0,
    "P1i conversion requires finite positive target coefficients."
  )
  w <- numeric(layout$dimension)
  base <- y[-p1f_layout$log_lambda]
  base[layout$rater] <- tau * y[p1f_layout$rater]
  base[layout$location[target_indices]] <-
    lambda * y[p1f_layout$location[target_indices]]
  steps <- matrix(
    y[p1f_layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  steps[target_indices, ] <- steps[target_indices, , drop = FALSE] * lambda
  base[layout$steps] <- as.numeric(t(steps))
  w[seq_len(layout$base_dimension)] <- base
  w[layout$relative] <- log(kappa[1L])
  list(
    w = w,
    tau = tau,
    lambda = lambda,
    kappa = kappa,
    target_indices = target_indices
  )
}

mfrmr_gtr_p1i_to_p1f <- function(w, tau, context, target_indices) {
  target_indices <- mfrmr_gtr_p1i_validate_target(target_indices)
  tau <- as.numeric(tau)[1L]
  layout <- mfrmr_gtr_p1i_layout(context)
  p1f_layout <- mfrmr_gsrc_p1f_layout(context, target_indices)
  unpacked <- mfrmr_gtr_p1i_unpack(w, context, target_indices)
  mfrmr_gtr_p1i_assert(
    is.finite(tau) && tau > 0,
    "P1i inverse conversion requires tau > 0."
  )
  kappa <- unpacked$relative$kappa
  lambda <- tau * kappa
  base <- as.numeric(w[seq_len(layout$base_dimension)])
  y <- numeric(p1f_layout$dimension)
  y[-p1f_layout$log_lambda] <- base
  y[p1f_layout$rater] <- base[layout$rater] / tau
  y[p1f_layout$location[target_indices]] <-
    base[layout$location[target_indices]] / lambda
  steps <- matrix(
    base[layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  steps[target_indices, ] <-
    steps[target_indices, , drop = FALSE] / lambda
  y[p1f_layout$steps] <- as.numeric(t(steps))
  y[p1f_layout$log_lambda] <- log(lambda)
  y
}

mfrmr_gtr_p1i_interior_start <- function(
    context,
    par,
    target_indices) {
  target_indices <- mfrmr_gtr_p1i_validate_target(target_indices)
  layout <- mfrmr_gtr_p1i_layout(context)
  params <- mfrmr_gss_get("expand_params")(
    par, context$sizes, context$config
  )
  slopes <- as.numeric(params$slopes)
  sigma <- sqrt(as.numeric(params$population$sigma2))
  lambda <- slopes[target_indices] * sigma
  tau <- exp(mean(log(lambda)))
  kappa <- lambda / tau
  location <- as.numeric(params$population$coefficients[1L]) -
    as.numeric(params$facets[["Criterion"]])
  step_free <- matrix(
    par[context$slices$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  w <- numeric(layout$dimension)
  w[layout$rater] <- tau * par[context$slices$Rater] / sigma
  w[layout$location] <- slopes * location
  w[layout$steps] <- as.numeric(t(step_free * slopes))
  w[layout$relative] <- log(kappa[1L])
  mfrmr_gtr_p1i_assert(
    all(is.finite(w)) && is.finite(tau) && tau > 0,
    "P1i interior-derived start is invalid."
  )
  list(
    w = w,
    tau = tau,
    lambda = lambda,
    kappa = kappa,
    target_indices = target_indices
  )
}

mfrmr_gtr_p1i_bundle <- function(
    w,
    tau,
    context,
    target_indices,
    include_gradient = TRUE) {
  tau <- as.numeric(tau)[1L]
  mfrmr_gtr_p1i_assert(
    is.finite(tau) && tau >= 0,
    "P1i likelihood requires tau >= 0."
  )
  unpacked <- mfrmr_gtr_p1i_unpack(w, context, target_indices)
  layout <- unpacked$layout
  target_indices <- unpacked$target_indices
  kappa <- unpacked$relative$kappa
  relative_sign <- unpacked$relative$sign
  base <- unpacked$base
  idx <- context$idx
  n <- length(idx$score_k)
  n_nodes <- length(context$quad$nodes)
  k_values <- 0:(context$config$n_cat - 1L)
  observed_index <- cbind(seq_len(n), idx$score_k + 1L)
  criterion <- as.integer(idx$slope_idx)
  rater_index <- as.integer(idx$facets[["Rater"]])
  target_position <- match(criterion, target_indices)
  target_observation <- !is.na(target_position)
  observation_kappa <- rep(0, n)
  observation_sign <- rep(0, n)
  observation_kappa[target_observation] <-
    kappa[target_position[target_observation]]
  observation_sign[target_observation] <-
    relative_sign[target_position[target_observation]]
  log_probability <- matrix(0, nrow = n, ncol = n_nodes)
  probability <- vector("list", n_nodes)
  for (q in seq_len(n_nodes)) {
    eta <- base$location[criterion]
    eta[target_observation] <- eta[target_observation] -
      observation_kappa[target_observation] *
        base$rater[rater_index[target_observation]] +
      tau * observation_kappa[target_observation] *
        context$quad$nodes[q]
    log_num <- outer(eta, k_values) -
      base$step_cumulative[criterion, , drop = FALSE]
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
  score_relative <- 0
  score_tau <- 0
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
    rater_score_obs <- -observation_kappa[target_observation] *
      posterior_residual[target_observation]
    rater_sum <- rowsum(
      matrix(rater_score_obs, ncol = 1L),
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
    target_rater <- base$rater[rater_index[target_observation]]
    relative_eta_derivative <-
      observation_sign[target_observation] *
      observation_kappa[target_observation] *
      (-target_rater + tau * context$quad$nodes[q])
    score_relative <- score_relative + sum(
      posterior_residual[target_observation] * relative_eta_derivative
    )
    score_tau <- score_tau + sum(
      posterior_residual[target_observation] *
        observation_kappa[target_observation] * context$quad$nodes[q]
    )
  }
  gradient <- c(
    -mfrmr_gss_get("project_sum_zero_gradient")(score_rater),
    -score_location,
    -mfrmr_gss_get("project_step_matrix_gradient")(score_step),
    -score_relative
  )
  mfrmr_gtr_p1i_assert(
    length(gradient) == layout$dimension &&
      all(is.finite(c(gradient, score_tau))),
    "P1i radial likelihood gradient is invalid."
  )
  list(
    objective = objective,
    gradient = gradient,
    tau_gradient = -score_tau,
    kappa = kappa,
    relative_log_kappa = unpacked$relative$relative_log_kappa,
    log_probability = log_probability,
    posterior = posterior
  )
}

mfrmr_gtr_p1i_conditional_oracle <- function(
    w,
    context,
    target_indices) {
  unpacked <- mfrmr_gtr_p1i_unpack(w, context, target_indices)
  base <- unpacked$base
  kappa <- unpacked$relative$kappa
  idx <- context$idx
  n <- length(idx$score_k)
  k_values <- 0:(context$config$n_cat - 1L)
  criterion <- as.integer(idx$slope_idx)
  rater_index <- as.integer(idx$facets[["Rater"]])
  target_position <- match(criterion, unpacked$target_indices)
  target <- !is.na(target_position)
  eta <- base$location[criterion]
  eta[target] <- eta[target] -
    kappa[target_position[target]] * base$rater[rater_index[target]]
  log_num <- outer(eta, k_values) -
    base$step_cumulative[criterion, , drop = FALSE]
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

mfrmr_gtr_p1i_identity_row <- function(
    scenario_id,
    start,
    contexts,
    target_indices) {
  y <- mfrmr_gtr_p1i_to_p1f(
    start$w, start$tau, contexts[["121"]], target_indices
  )
  recovered <- mfrmr_gtr_p1i_from_p1f(
    y, contexts[["121"]], target_indices
  )
  p1f_objectives <- vapply(contexts, function(context) {
    mfrmr_gsrc_p1f_limit_bundle(
      y, context, target_indices, include_gradient = FALSE
    )$objective
  }, numeric(1L))
  p1i_objectives <- vapply(contexts, function(context) {
    mfrmr_gtr_p1i_bundle(
      start$w, start$tau, context, target_indices,
      include_gradient = FALSE
    )$objective
  }, numeric(1L))
  bundle <- mfrmr_gtr_p1i_bundle(
    start$w, start$tau, contexts[["121"]], target_indices,
    include_gradient = TRUE
  )
  numeric_gradient <- mfrmr_num_central_gradient(
    function(value) mfrmr_gtr_p1i_bundle(
      value, start$tau, contexts[["121"]], target_indices,
      include_gradient = FALSE
    )$objective,
    start$w,
    mfrmr_gtr_p1i_derivative_step
  )
  objective_difference <- max(abs(p1f_objectives - p1i_objectives))
  gradient_difference <- max(abs(bundle$gradient - numeric_gradient))
  data.frame(
    ScenarioId = scenario_id,
    TargetSetId = mfrmr_gtr_p1i_target_id(target_indices),
    InteriorTau = start$tau,
    InteriorKappa1 = start$kappa[1L],
    InteriorKappa2 = start$kappa[2L],
    CoordinateRoundtripMaxAbsDifference = max(abs(
      recovered$w - start$w
    )),
    TauRoundtripAbsDifference = abs(recovered$tau - start$tau),
    P1fP1iObjectiveMaxAbsDifference = objective_difference,
    P1iAnalyticNumericGradientMaxAbsDifference = gradient_difference,
    IdentityComplete = all(is.finite(c(
      p1f_objectives, p1i_objectives, bundle$gradient, numeric_gradient
    ))) &&
      objective_difference <= mfrmr_gtr_p1i_identity_tolerance &&
      gradient_difference <= mfrmr_gtr_p1i_gradient_check_tolerance,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ScaledVectorSHA256 = mfrmr_gss_hash_vector(start$w),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtr_p1i_profile_candidate <- function(
    scenario_id,
    target_indices,
    route_id,
    tau,
    start,
    contexts,
    interior_objective,
    maxit,
    reltol) {
  fn <- function(value) mfrmr_gtr_p1i_bundle(
    value, tau, contexts[["121"]], target_indices,
    include_gradient = FALSE
  )$objective
  gr <- function(value) mfrmr_gtr_p1i_bundle(
    value, tau, contexts[["121"]], target_indices,
    include_gradient = TRUE
  )$gradient
  optimized <- mfrmr_gcl_p1e_optimize(start, fn, gr, maxit, reltol)
  returned <- isTRUE(optimized$returned)
  w <- optimized$par
  objective <- NA_real_
  gradient <- numeric(0)
  numeric_gradient <- numeric(0)
  tau_gradient <- NA_real_
  kappa <- rep(NA_real_, 2L)
  relative_log_kappa <- NA_real_
  objectives <- setNames(rep(NA_real_, length(contexts)), names(contexts))
  oracle_difference <- NA_real_
  derivative_scheduled <- tau %in% mfrmr_gtr_p1i_derivative_taus
  if (returned) {
    bundle <- mfrmr_gtr_p1i_bundle(
      w, tau, contexts[["121"]], target_indices,
      include_gradient = TRUE
    )
    objective <- bundle$objective
    gradient <- bundle$gradient
    tau_gradient <- bundle$tau_gradient
    kappa <- bundle$kappa
    relative_log_kappa <- bundle$relative_log_kappa
    if (derivative_scheduled) {
      numeric_gradient <- tryCatch(
        mfrmr_num_central_gradient(
          fn, w, mfrmr_gtr_p1i_derivative_step
        ),
        error = function(condition) rep(NA_real_, length(w))
      )
    }
    objectives <- vapply(contexts, function(context) {
      mfrmr_gtr_p1i_bundle(
        w, tau, context, target_indices, include_gradient = FALSE
      )$objective
    }, numeric(1L))
    if (tau == 0) {
      oracle_difference <- abs(
        objective - mfrmr_gtr_p1i_conditional_oracle(
          w, contexts[["121"]], target_indices
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
    all(is.finite(c(gradient, tau_gradient, kappa, objectives))) &&
    (!derivative_scheduled || (
      is.finite(derivative_difference) &&
        derivative_difference <= mfrmr_gtr_p1i_gradient_check_tolerance
    )) &&
    (tau != 0 || (
      is.finite(oracle_difference) &&
        oracle_difference <= mfrmr_gtr_p1i_identity_tolerance
    ))
  eligible <- complete && identical(severity, "pass")
  row <- data.frame(
    ScenarioId = scenario_id,
    TargetSetId = mfrmr_gtr_p1i_target_id(target_indices),
    TargetIndex1 = target_indices[1L],
    TargetIndex2 = target_indices[2L],
    RouteId = route_id,
    Tau = tau,
    TauBoundary = tau == 0,
    FitReturned = returned,
    ObjectiveQ121 = objective,
    ObjectiveQ61 = as.numeric(objectives[["61"]]),
    ObjectiveQ91 = as.numeric(objectives[["91"]]),
    QuadratureObjectiveRange = if (all(is.finite(objectives))) {
      diff(range(objectives))
    } else NA_real_,
    InteriorObjectiveQ121 = as.numeric(interior_objective),
    ProfileMinusInteriorObjective = objective - as.numeric(interior_objective),
    RelativeLogKappa = relative_log_kappa,
    Kappa1 = kappa[1L],
    Kappa2 = kappa[2L],
    KappaProductResidual = prod(kappa) - 1,
    ScaledGradientMaxAbs = if (
      length(gradient) > 0L && all(is.finite(gradient))
    ) max(abs(gradient)) else NA_real_,
    TauObjectiveDerivative = tau_gradient,
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
      if (tau == 0) {
        "stationary_paired_rater_endpoint_and_oracle_complete"
      } else {
        "stationary_two_target_radial_profile_complete"
      }
    } else if (complete) {
      "radial_profile_complete_but_stationarity_not_passed"
    } else {
      "radial_profile_fit_or_derivative_incomplete"
    },
    CoefficientRatioBoundaryCertified = FALSE,
    FullTwoTargetFaceGloballyCertified = FALSE,
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
      mfrmr_gss_hash_vector(w)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
  list(row = row, w = w, optimized = optimized)
}

mfrmr_gtr_p1i_pairwise <- function(profile) {
  key <- interaction(
    profile$ScenarioId, profile$TargetSetId, profile$Tau, drop = TRUE
  )
  groups <- split(profile, key)
  out <- lapply(groups, function(value) {
    down <- value[value$RouteId == "interior_down", , drop = FALSE]
    up <- value[value$RouteId == "singleton_mean_reverse_up", , drop = FALSE]
    complete <- nrow(down) == 1L && nrow(up) == 1L
    difference <- if (complete) {
      abs(down$ObjectiveQ121 - up$ObjectiveQ121)
    } else NA_real_
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      TargetSetId = value$TargetSetId[1L],
      Tau = value$Tau[1L],
      BothRoutesPresent = complete,
      BothRoutesEligible = complete &&
        isTRUE(down$ProfileCandidateEligible) &&
        isTRUE(up$ProfileCandidateEligible),
      ObjectiveAbsDifference = difference,
      RelativeLogKappaAbsDifference = if (complete) {
        abs(down$RelativeLogKappa - up$RelativeLogKappa)
      } else NA_real_,
      RouteAgreementWithinCalibrationTolerance = complete &&
        is.finite(difference) &&
        difference <= mfrmr_gtr_p1i_route_tolerance,
      CoefficientRatioToleranceStatus = "not_frozen_calibration_only",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result[order(
    match(result$ScenarioId, mfrmr_gcl_p1e_scenarios),
    result$TargetSetId, result$Tau
  ), , drop = FALSE]
}

mfrmr_gtr_p1i_decision <- function(
    scenario_id,
    target_set_id,
    profile,
    pairwise) {
  rows <- profile[
    profile$ScenarioId == scenario_id &
      profile$TargetSetId == target_set_id, , drop = FALSE
  ]
  pairs <- pairwise[
    pairwise$ScenarioId == scenario_id &
      pairwise$TargetSetId == target_set_id, , drop = FALSE
  ]
  mfrmr_gtr_p1i_assert(
    nrow(rows) == 2L * length(mfrmr_gtr_p1i_tau_grid) &&
      nrow(pairs) == length(mfrmr_gtr_p1i_tau_grid),
    "P1i decision requires one complete two-route pair profile."
  )
  route_monotone <- vapply(mfrmr_gtr_p1i_routes, function(route_id) {
    value <- rows[rows$RouteId == route_id, , drop = FALSE]
    value <- value[order(value$Tau), , drop = FALSE]
    all(diff(value$ObjectiveQ121) >=
          -mfrmr_gtr_p1i_monotonicity_tolerance)
  }, logical(1L))
  endpoint <- rows[rows$Tau == 0, , drop = FALSE]
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
    rows$TauObjectiveDerivative[rows$Tau > 0] >=
      -mfrmr_gtr_p1i_monotonicity_tolerance
  )
  endpoint_derivatives_zero <- all(
    abs(endpoint$TauObjectiveDerivative) <=
      mfrmr_gtr_p1i_identity_tolerance
  )
  complete <- all_eligible && all(route_monotone) && routes_agree &&
    positive_derivatives && endpoint_derivatives_zero
  status <- if (complete && endpoint_above) {
    "two_target_radial_grid_descends_to_paired_rater_limit_above_interior"
  } else if (complete && endpoint_below) {
    "two_target_radial_grid_descends_to_competitive_paired_rater_limit"
  } else if (endpoint_eligible) {
    "paired_rater_limit_observed_radial_grid_inconclusive"
  } else {
    "two_target_radial_screen_inconclusive"
  }
  data.frame(
    ScenarioId = scenario_id,
    TargetSetId = target_set_id,
    AllRadialProfilePointsEligible = all_eligible,
    BothRoutesMonotoneFromTauZero = all(route_monotone),
    AllPositiveTauGridDerivativesNonnegative = positive_derivatives,
    BothEndpointTauDerivativesNumericallyZero = endpoint_derivatives_zero,
    AllRoutePairsAgreeWithinCalibrationTolerance = routes_agree,
    BothPairedRaterEndpointsEligible = endpoint_eligible,
    BothEndpointObjectivesAboveInterior = endpoint_above,
    BothEndpointObjectivesBelowInterior = endpoint_below,
    EndpointMinusInteriorMinimum = if (endpoint_eligible) {
      min(endpoint$ProfileMinusInteriorObjective)
    } else NA_real_,
    EndpointMinusInteriorMaximum = if (endpoint_eligible) {
      max(endpoint$ProfileMinusInteriorObjective)
    } else NA_real_,
    EndpointRelativeLogKappaMaximumAbs = if (endpoint_eligible) {
      max(abs(endpoint$RelativeLogKappa))
    } else NA_real_,
    TwoTargetRadialGridStatus = status,
    TwoTargetRadialGridLocallyAdjudicated = complete,
    PairedDeterministicRaterLimitAdjudicated = endpoint_eligible,
    CoefficientRatioBoundaryCertified = FALSE,
    FullTwoTargetFaceGloballyCertified = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtr_p1i_overall_decision <- function(decisions) {
  complete <- nrow(decisions) ==
    length(mfrmr_gcl_p1e_scenarios) * 6L &&
    all(decisions$TwoTargetRadialGridLocallyAdjudicated) &&
    all(decisions$PairedDeterministicRaterLimitAdjudicated)
  data.frame(
    AllSixTwoTargetRadialGridsScreened = complete,
    AllSixPairedDeterministicRaterStrataScreened = complete,
    AnyPairedEndpointBelowQualifiedInterior = any(
      decisions$EndpointMinusInteriorMaximum < 0
    ),
    MinimumPairedEndpointMinusInterior = min(
      decisions$EndpointMinusInteriorMinimum
    ),
    CoefficientRatioBoundariesCertified = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    ThreeCriterionDeterministicRaterStrataEvaluated = FALSE,
    AllCriterionDeterministicRaterStratumEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    UpperVarianceJointPathStatus = "not_evaluated",
    SourceSolutionDecision =
      "blocked_ratio_boundaries_three_target_faces_remaining_rater_strata_and_upper_boundary_open",
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtr_p1i_singleton_endpoint <- function(
    p1h,
    scenario_id,
    target_index) {
  if (target_index == 4L) {
    return(p1h$p1g$profile_objects[[paste(
      scenario_id, "boundary_reverse_up", 0, sep = "::"
    )]]$z)
  }
  p1h$profile_objects[[paste(
    scenario_id, target_index, "c4_endpoint_reverse_up", 0, sep = "::"
  )]]$z
}

mfrmr_run_gpcm_two_target_radial_screen_p1i <- function(
    maxit = 800L,
    reltol = 1e-12,
    progress = FALSE,
    p1h = NULL) {
  mfrmr_gtr_p1i_require_sources()
  maxit <- as.integer(maxit)[1L]
  reltol <- as.numeric(reltol)[1L]
  mfrmr_gtr_p1i_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0,
    "P1i requires finite positive optimization controls."
  )
  if (is.null(p1h)) {
    p1h <- mfrmr_run_gpcm_single_target_face_screen_p1h(
      progress = progress
    )
  }
  mfrmr_gtr_p1i_assert(
    is.list(p1h) && identical(
      p1h$contract, mfrmr_gtr_p1i_dependency_contract
    ),
    "P1i requires one complete P1h dependency result."
  )
  plan <- mfrmr_gtr_p1i_plan()
  identity_rows <- list()
  profile_rows <- list()
  profile_objects <- list()
  identity_index <- profile_index <- 1L
  for (scenario_id in mfrmr_gcl_p1e_scenarios) {
    source <- p1h$p1g$p1f$p1e$p1d$p1c$p0b$
      scenario_results[[scenario_id]]
    contexts <- lapply(mfrmr_gtr_p1i_quadrature, function(q) {
      mfrmr_gqi_p1b_context(source$fit, q)
    })
    names(contexts) <- as.character(mfrmr_gtr_p1i_quadrature)
    anchor <- p1h$p1g$p1f$p1e$p1d$p1c$
      interior_candidate_objects[[scenario_id]]$opt$par
    interior <- p1h$p1g$p1f$p1e$p1d$p1c$interior_candidates[
      p1h$p1g$p1f$p1e$p1d$p1c$interior_candidates$ScenarioId ==
        scenario_id, , drop = FALSE
    ]
    for (target_indices in mfrmr_gtr_p1i_target_sets) {
      target_id <- mfrmr_gtr_p1i_target_id(target_indices)
      interior_start <- mfrmr_gtr_p1i_interior_start(
        contexts[["121"]], anchor, target_indices
      )
      identity_rows[[identity_index]] <- mfrmr_gtr_p1i_identity_row(
        scenario_id, interior_start, contexts, target_indices
      )
      identity_index <- identity_index + 1L
      singleton1 <- mfrmr_gtr_p1i_singleton_endpoint(
        p1h, scenario_id, target_indices[1L]
      )
      singleton2 <- mfrmr_gtr_p1i_singleton_endpoint(
        p1h, scenario_id, target_indices[2L]
      )
      layout <- mfrmr_gtr_p1i_layout(contexts[["121"]])
      boundary_start <- numeric(layout$dimension)
      boundary_start[seq_len(layout$base_dimension)] <-
        (singleton1 + singleton2) / 2
      boundary_start[layout$relative] <- 0
      starts <- list(
        interior_down = interior_start$w,
        singleton_mean_reverse_up = boundary_start
      )
      for (route_id in mfrmr_gtr_p1i_routes) {
        tau_order <- if (route_id == "interior_down") {
          rev(mfrmr_gtr_p1i_tau_grid)
        } else {
          mfrmr_gtr_p1i_tau_grid
        }
        previous <- starts[[route_id]]
        for (tau in tau_order) {
          if (isTRUE(progress)) message(
            "Two-target P1i: ", scenario_id, " / ", target_id,
            " / ", route_id, " / tau=", tau
          )
          candidate <- mfrmr_gtr_p1i_profile_candidate(
            scenario_id = scenario_id,
            target_indices = target_indices,
            route_id = route_id,
            tau = tau,
            start = previous,
            contexts = contexts,
            interior_objective = interior$CommonDenseObjective,
            maxit = maxit,
            reltol = reltol
          )
          key <- paste(scenario_id, target_id, route_id, tau, sep = "::")
          profile_objects[[key]] <- candidate
          profile_rows[[profile_index]] <- candidate$row
          profile_index <- profile_index + 1L
          if (isTRUE(candidate$row$FitReturned)) previous <- candidate$w
        }
      }
    }
  }
  identity_table <- do.call(rbind, identity_rows)
  rownames(identity_table) <- NULL
  profile_table <- do.call(rbind, profile_rows)
  rownames(profile_table) <- NULL
  profile_table <- profile_table[order(
    match(profile_table$ScenarioId, mfrmr_gcl_p1e_scenarios),
    profile_table$TargetSetId,
    match(profile_table$RouteId, mfrmr_gtr_p1i_routes),
    profile_table$Tau
  ), , drop = FALSE]
  pairwise <- mfrmr_gtr_p1i_pairwise(profile_table)
  target_ids <- vapply(
    mfrmr_gtr_p1i_target_sets, mfrmr_gtr_p1i_target_id, character(1L)
  )
  decisions <- do.call(rbind, lapply(
    mfrmr_gcl_p1e_scenarios,
    function(scenario_id) do.call(rbind, lapply(
      target_ids,
      mfrmr_gtr_p1i_decision,
      scenario_id = scenario_id,
      profile = profile_table,
      pairwise = pairwise
    ))
  ))
  rownames(decisions) <- NULL
  overall <- mfrmr_gtr_p1i_overall_decision(decisions)
  structure(
    list(
      contract = mfrmr_gtr_p1i_contract,
      specification = mfrmr_gtr_p1i_specification,
      dependency_contract = mfrmr_gtr_p1i_dependency_contract,
      dependency_sha256 = mfrmr_gtr_p1i_dependency_sha256,
      plan = plan,
      nested_p1f_identity = identity_table,
      profile = profile_table,
      profile_objects = profile_objects,
      pairwise = pairwise,
      decisions = decisions,
      overall_decision = overall,
      p1h = p1h,
      AllSixTwoTargetRadialGridsScreened =
        overall$AllSixTwoTargetRadialGridsScreened,
      AllSixPairedDeterministicRaterStrataScreened =
        overall$AllSixPairedDeterministicRaterStrataScreened,
      CoefficientRatioBoundariesCertified = FALSE,
      ThreeTargetFacesEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      UpperVarianceJointPathStatus = "not_evaluated",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_two_target_radial_screen_p1i"
  )
}
