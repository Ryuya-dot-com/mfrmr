# mfrmr 0.2.3 GPCM ordered coefficient-ratio boundary P1j audit
#
# For distinct fast and slow target criteria, write
#   lambda_slow = mu, lambda_fast = mu * rho, mu > 0, rho > 0.
# Scale the shared Rater coordinate by the slower coefficient:
#   B_r = mu * q_r.
# Then the slow and fast target logits are respectively
#   k(V_slow - B_r + mu*z) - G_slow,
#   k(V_fast - rho*B_r + mu*rho*z) - G_fast.
# This is exactly the P1f two-target likelihood for rho>0. At rho=0 it is
# exactly the P1h/P1g singleton likelihood for the slow target: the fast
# criterion becomes an ordinary non-target fixed category distribution.
# P1j audits that nesting and its local natural-rho derivative. It does not
# replace fixed-rho profiling or certify the complete two-target faces.

mfrmr_gorb_p1j_specification <- "0.2.3-draft.1"
mfrmr_gorb_p1j_contract <-
  "mfrmr_gpcm_ordered_ratio_boundary_p1j_v1"
mfrmr_gorb_p1j_dependency_contract <-
  "mfrmr_gpcm_two_target_radial_screen_p1i_v1"
mfrmr_gorb_p1j_dependency_sha256 <-
  "2208b7d8eb5da024de8ece28acba6f3b188e2d0e8d2bea0deccf0c031f275c1e"
mfrmr_gorb_p1j_identity_tolerance <- 1e-9
mfrmr_gorb_p1j_gradient_tolerance <- 1e-6
mfrmr_gorb_p1j_rho_derivative_step <- 1e-5
mfrmr_gorb_p1j_derivative_mus <- c(0, 0.2)
mfrmr_gorb_p1j_derivative_tolerance <- 2e-5

mfrmr_gorb_p1j_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gorb_p1j_require_sources <- function() {
  target <- environment(mfrmr_gorb_p1j_require_sources)
  required <- c(
    "mfrmr_gtr_p1i_contract",
    "mfrmr_run_gpcm_two_target_radial_screen_p1i",
    "mfrmr_gtr_p1i_layout", "mfrmr_gtr_p1i_unpack",
    "mfrmr_gtr_p1i_bundle", "mfrmr_gsrc_p1f_layout",
    "mfrmr_gsrc_p1f_limit_bundle", "mfrmr_gc4_p1g_layout",
    "mfrmr_gc4_p1g_unpack", "mfrmr_gc4_p1g_limit_bundle",
    "mfrmr_gst_p1h_bundle", "mfrmr_gcl_p1e_softmax",
    "mfrmr_gqi_p1b_context", "mfrmr_gss_get"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )
  mfrmr_gorb_p1j_assert(
    all(available) && identical(
      get("mfrmr_gtr_p1i_contract", envir = target, inherits = TRUE),
      mfrmr_gorb_p1j_dependency_contract
    ),
    "Source P0 through P1i and their numerical dependencies before P1j."
  )
  invisible(TRUE)
}

mfrmr_gorb_p1j_ordered_pairs <- local({
  out <- do.call(rbind, lapply(seq_len(4L), function(slow) {
    fast <- setdiff(seq_len(4L), slow)
    data.frame(
      FastIndex = fast,
      SlowIndex = rep(slow, length(fast)),
      stringsAsFactors = FALSE
    )
  }))
  rownames(out) <- NULL
  out$OrderedPairId <- paste0(
    "C", out$FastIndex, "_fast__C", out$SlowIndex, "_slow"
  )
  out
})

mfrmr_gorb_p1j_validate_order <- function(
    fast_index,
    slow_index,
    n_criterion = 4L) {
  fast_index <- as.integer(fast_index)[1L]
  slow_index <- as.integer(slow_index)[1L]
  mfrmr_gorb_p1j_assert(
    all(is.finite(c(fast_index, slow_index))) &&
      fast_index >= 1L && fast_index <= n_criterion &&
      slow_index >= 1L && slow_index <= n_criterion &&
      fast_index != slow_index,
    "P1j requires two distinct valid ordered target indices."
  )
  list(
    fast_index = fast_index,
    slow_index = slow_index,
    target_indices = sort(c(fast_index, slow_index)),
    ordered_pair_id = paste0(
      "C", fast_index, "_fast__C", slow_index, "_slow"
    )
  )
}

mfrmr_gorb_p1j_plan <- function() {
  single_rows <- expand.grid(
    ScenarioId = mfrmr_gcl_p1e_scenarios,
    SlowIndex = seq_len(4L),
    FastIndex = seq_len(4L),
    SourceRouteNumber = seq_len(2L),
    Mu = mfrmr_gtr_p1i_tau_grid,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  single_rows <- single_rows[
    single_rows$FastIndex != single_rows$SlowIndex, , drop = FALSE
  ]
  single_rows$OrderedPairId <- paste0(
    "C", single_rows$FastIndex,
    "_fast__C", single_rows$SlowIndex, "_slow"
  )
  single_rows$IndependentRhoDerivativeScheduled <-
    single_rows$Mu %in% mfrmr_gorb_p1j_derivative_mus
  single_rows$SelectionAuthorized <- FALSE
  single_rows$ConfirmationAuthorized <- FALSE
  rownames(single_rows) <- NULL
  list(
    ordered_pairs = mfrmr_gorb_p1j_ordered_pairs,
    singleton_nesting = single_rows,
    positive_p1i_transport_count = 288L,
    singleton_nesting_count = 672L,
    fixed_rho_profiles_planned = FALSE,
    coefficient_ratio_profiles_completed = FALSE,
    three_target_faces_evaluated = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gorb_p1j_from_p1f <- function(
    y,
    context,
    fast_index,
    slow_index) {
  order <- mfrmr_gorb_p1j_validate_order(fast_index, slow_index)
  layout <- mfrmr_gc4_p1g_layout(context)
  p1f_layout <- mfrmr_gsrc_p1f_layout(context, order$target_indices)
  y <- as.numeric(y)
  mfrmr_gorb_p1j_assert(
    length(y) == p1f_layout$dimension &&
      p1f_layout$dimension == layout$dimension + 2L,
    "P1j conversion requires one valid two-target P1f vector."
  )
  lambda <- exp(y[p1f_layout$log_lambda])
  names(lambda) <- p1f_layout$target_indices
  mu <- unname(lambda[as.character(order$slow_index)])
  lambda_fast <- unname(lambda[as.character(order$fast_index)])
  rho <- lambda_fast / mu
  mfrmr_gorb_p1j_assert(
    all(is.finite(c(lambda, mu, rho))) &&
      all(lambda > 0) && mu > 0 && rho > 0,
    "P1j conversion requires finite positive coefficients."
  )
  x <- y[-p1f_layout$log_lambda]
  x[layout$rater] <- mu * y[p1f_layout$rater]
  x[layout$location[order$slow_index]] <-
    mu * y[p1f_layout$location[order$slow_index]]
  x[layout$location[order$fast_index]] <-
    lambda_fast * y[p1f_layout$location[order$fast_index]]
  steps <- matrix(
    y[p1f_layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  steps[order$slow_index, ] <- mu * steps[order$slow_index, ]
  steps[order$fast_index, ] <-
    lambda_fast * steps[order$fast_index, ]
  x[layout$steps] <- as.numeric(t(steps))
  list(
    x = x,
    mu = mu,
    rho = rho,
    lambda_fast = lambda_fast,
    order = order
  )
}

mfrmr_gorb_p1j_to_p1f <- function(
    x,
    mu,
    rho,
    context,
    fast_index,
    slow_index) {
  order <- mfrmr_gorb_p1j_validate_order(fast_index, slow_index)
  layout <- mfrmr_gc4_p1g_layout(context)
  p1f_layout <- mfrmr_gsrc_p1f_layout(context, order$target_indices)
  x <- as.numeric(x)
  mu <- as.numeric(mu)[1L]
  rho <- as.numeric(rho)[1L]
  mfrmr_gorb_p1j_assert(
    length(x) == layout$dimension && all(is.finite(x)) &&
      is.finite(mu) && mu > 0 && is.finite(rho) && rho > 0,
    "P1j inverse P1f conversion requires finite x, mu > 0, and rho > 0."
  )
  lambda_fast <- mu * rho
  y <- numeric(p1f_layout$dimension)
  y[-p1f_layout$log_lambda] <- x
  y[p1f_layout$rater] <- x[layout$rater] / mu
  y[p1f_layout$location[order$slow_index]] <-
    x[layout$location[order$slow_index]] / mu
  y[p1f_layout$location[order$fast_index]] <-
    x[layout$location[order$fast_index]] / lambda_fast
  steps <- matrix(
    x[layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  steps[order$slow_index, ] <- steps[order$slow_index, ] / mu
  steps[order$fast_index, ] <-
    steps[order$fast_index, ] / lambda_fast
  y[p1f_layout$steps] <- as.numeric(t(steps))
  lambda <- setNames(
    c(lambda_fast, mu), c(order$fast_index, order$slow_index)
  )
  y[p1f_layout$log_lambda] <- log(
    lambda[as.character(p1f_layout$target_indices)]
  )
  y
}

mfrmr_gorb_p1j_from_p1i <- function(
    w,
    tau,
    context,
    target_indices,
    fast_index,
    slow_index) {
  order <- mfrmr_gorb_p1j_validate_order(fast_index, slow_index)
  target_indices <- sort(unique(as.integer(target_indices)))
  mfrmr_gorb_p1j_assert(
    identical(target_indices, order$target_indices),
    "P1j/P1i conversion requires the same unordered target pair."
  )
  tau <- as.numeric(tau)[1L]
  unpacked <- mfrmr_gtr_p1i_unpack(w, context, target_indices)
  mfrmr_gorb_p1j_assert(
    is.finite(tau) && tau > 0,
    "P1j/P1i conversion requires tau > 0."
  )
  lambda <- tau * unpacked$relative$kappa
  names(lambda) <- target_indices
  mu <- unname(lambda[as.character(order$slow_index)])
  lambda_fast <- unname(lambda[as.character(order$fast_index)])
  rho <- lambda_fast / mu
  x <- as.numeric(w[seq_len(unpacked$layout$base_dimension)])
  x[unpacked$layout$rater] <-
    (mu / tau) * x[unpacked$layout$rater]
  list(
    x = x,
    mu = mu,
    rho = rho,
    lambda_fast = lambda_fast,
    order = order
  )
}

mfrmr_gorb_p1j_to_p1i <- function(
    x,
    mu,
    rho,
    context,
    fast_index,
    slow_index) {
  order <- mfrmr_gorb_p1j_validate_order(fast_index, slow_index)
  layout <- mfrmr_gtr_p1i_layout(context)
  x <- as.numeric(x)
  mu <- as.numeric(mu)[1L]
  rho <- as.numeric(rho)[1L]
  mfrmr_gorb_p1j_assert(
    length(x) == layout$base_dimension && all(is.finite(x)) &&
      is.finite(mu) && mu > 0 && is.finite(rho) && rho > 0,
    "P1j inverse P1i conversion requires finite x, mu > 0, and rho > 0."
  )
  tau <- mu * sqrt(rho)
  w <- numeric(layout$dimension)
  w[seq_len(layout$base_dimension)] <- x
  w[layout$rater] <- sqrt(rho) * x[layout$rater]
  log_kappa <- setNames(
    c(0.5 * log(rho), -0.5 * log(rho)),
    c(order$fast_index, order$slow_index)
  )
  w[layout$relative] <-
    unname(log_kappa[as.character(order$target_indices[1L])])
  list(w = w, tau = tau, order = order)
}

mfrmr_gorb_p1j_bundle <- function(
    x,
    mu,
    rho,
    context,
    fast_index,
    slow_index,
    include_gradient = TRUE) {
  order <- mfrmr_gorb_p1j_validate_order(fast_index, slow_index)
  mu <- as.numeric(mu)[1L]
  rho <- as.numeric(rho)[1L]
  mfrmr_gorb_p1j_assert(
    is.finite(mu) && mu >= 0 && is.finite(rho) && rho >= 0,
    "P1j likelihood requires mu >= 0 and rho >= 0."
  )
  base <- mfrmr_gc4_p1g_unpack(x, context)
  layout <- base$layout
  idx <- context$idx
  n <- length(idx$score_k)
  n_nodes <- length(context$quad$nodes)
  k_values <- 0:(context$config$n_cat - 1L)
  observed_index <- cbind(seq_len(n), idx$score_k + 1L)
  criterion <- as.integer(idx$slope_idx)
  rater_index <- as.integer(idx$facets[["Rater"]])
  slow_observation <- criterion == order$slow_index
  fast_observation <- criterion == order$fast_index
  log_probability <- matrix(0, nrow = n, ncol = n_nodes)
  probability <- vector("list", n_nodes)
  for (q in seq_len(n_nodes)) {
    eta <- base$location[criterion]
    eta[slow_observation] <- eta[slow_observation] -
      base$rater[rater_index[slow_observation]] +
      mu * context$quad$nodes[q]
    eta[fast_observation] <- eta[fast_observation] -
      rho * base$rater[rater_index[fast_observation]] +
      mu * rho * context$quad$nodes[q]
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
  score_mu <- 0
  score_rho <- 0
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

    rater_derivative <- numeric(n)
    rater_derivative[slow_observation] <- -1
    rater_derivative[fast_observation] <- -rho
    rater_sum <- rowsum(
      matrix(rater_derivative * posterior_residual, ncol = 1L),
      rater_index, reorder = FALSE
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

    z <- context$quad$nodes[q]
    score_mu <- score_mu + sum(
      posterior_residual[slow_observation] * z
    ) + sum(
      posterior_residual[fast_observation] * rho * z
    )
    score_rho <- score_rho + sum(
      posterior_residual[fast_observation] *
        (-base$rater[rater_index[fast_observation]] + mu * z)
    )
  }
  gradient <- c(
    -mfrmr_gss_get("project_sum_zero_gradient")(score_rater),
    -score_location,
    -mfrmr_gss_get("project_step_matrix_gradient")(score_step)
  )
  mfrmr_gorb_p1j_assert(
    length(gradient) == layout$dimension &&
      all(is.finite(c(gradient, score_mu, score_rho))),
    "P1j ordered-ratio likelihood gradient is invalid."
  )
  list(
    objective = objective,
    gradient = gradient,
    mu_gradient = -score_mu,
    rho_gradient = -score_rho,
    log_probability = log_probability,
    posterior = posterior
  )
}

mfrmr_gorb_p1j_single_bundle <- function(
    x,
    mu,
    context,
    slow_index,
    include_gradient = TRUE) {
  slow_index <- as.integer(slow_index)[1L]
  if (slow_index == 4L) {
    mfrmr_gc4_p1g_limit_bundle(
      x, mu, context, target_index = 4L,
      include_gradient = include_gradient
    )
  } else {
    mfrmr_gst_p1h_bundle(
      x, mu, context, slow_index,
      include_gradient = include_gradient
    )
  }
}

mfrmr_gorb_p1j_contexts <- function(p1i, scenario_id) {
  source <- p1i$p1h$p1g$p1f$p1e$p1d$p1c$p0b$
    scenario_results[[scenario_id]]
  contexts <- lapply(mfrmr_gtr_p1i_quadrature, function(q) {
    mfrmr_gqi_p1b_context(source$fit, q)
  })
  names(contexts) <- as.character(mfrmr_gtr_p1i_quadrature)
  contexts
}

mfrmr_gorb_p1j_transport_table <- function(p1i) {
  rows <- p1i$profile[p1i$profile$Tau > 0, , drop = FALSE]
  out <- vector("list", nrow(rows))
  context_cache <- list()
  for (index in seq_len(nrow(rows))) {
    row <- rows[index, , drop = FALSE]
    scenario_id <- row$ScenarioId
    if (is.null(context_cache[[scenario_id]])) {
      context_cache[[scenario_id]] <-
        mfrmr_gorb_p1j_contexts(p1i, scenario_id)
    }
    context <- context_cache[[scenario_id]][["121"]]
    targets <- c(row$TargetIndex1, row$TargetIndex2)
    key <- paste(
      scenario_id, row$TargetSetId, row$RouteId, row$Tau, sep = "::"
    )
    candidate <- p1i$profile_objects[[key]]
    unpacked <- mfrmr_gtr_p1i_unpack(candidate$w, context, targets)
    lambda <- row$Tau * unpacked$relative$kappa
    slow_position <- which.max(lambda)
    slow_index <- targets[slow_position]
    fast_index <- targets[-slow_position]
    converted <- mfrmr_gorb_p1j_from_p1i(
      candidate$w, row$Tau, context, targets,
      fast_index, slow_index
    )
    recovered <- mfrmr_gorb_p1j_to_p1i(
      converted$x, converted$mu, converted$rho, context,
      fast_index, slow_index
    )
    ordered <- mfrmr_gorb_p1j_bundle(
      converted$x, converted$mu, converted$rho, context,
      fast_index, slow_index, include_gradient = FALSE
    )
    p1i_value <- mfrmr_gtr_p1i_bundle(
      candidate$w, row$Tau, context, targets,
      include_gradient = FALSE
    )$objective
    out[[index]] <- data.frame(
      ScenarioId = scenario_id,
      TargetSetId = row$TargetSetId,
      RouteId = row$RouteId,
      Tau = row$Tau,
      FastIndex = fast_index,
      SlowIndex = slow_index,
      OrderedPairId = paste0(
        "C", fast_index, "_fast__C", slow_index, "_slow"
      ),
      Mu = converted$mu,
      Rho = converted$rho,
      P1iObjective = p1i_value,
      OrderedObjective = ordered$objective,
      ObjectiveAbsDifference = abs(p1i_value - ordered$objective),
      CoordinateRoundtripMaxAbsDifference = max(abs(
        recovered$w - candidate$w
      )),
      TauRoundtripAbsDifference = abs(recovered$tau - row$Tau),
      SourceP1iEligible = row$ProfileCandidateEligible,
      PositiveP1iTransportIdentityComplete =
        isTRUE(row$ProfileCandidateEligible) &&
        abs(p1i_value - ordered$objective) <=
          mfrmr_gorb_p1j_identity_tolerance &&
        max(abs(recovered$w - candidate$w)) <=
          mfrmr_gorb_p1j_identity_tolerance &&
        abs(recovered$tau - row$Tau) <=
          mfrmr_gorb_p1j_identity_tolerance,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result
}

mfrmr_gorb_p1j_single_profile_rows <- function(p1i) {
  p1h <- p1i$p1h
  lower <- p1h$profile
  lower$SingleSource <- "P1h"
  c4 <- p1h$p1g$profile
  c4$TargetIndex <- 4L
  c4$SingleSource <- "P1g"
  common <- intersect(names(lower), names(c4))
  required <- c(
    "ScenarioId", "TargetIndex", "RouteId", "Lambda",
    "ObjectiveQ121", "LambdaObjectiveDerivative",
    "ProfileCandidateEligible", "SingleSource"
  )
  mfrmr_gorb_p1j_assert(
    all(required %in% common),
    "P1j could not construct the frozen single-target portfolio."
  )
  out <- rbind(lower[required], c4[required])
  rownames(out) <- NULL
  out
}

mfrmr_gorb_p1j_single_object <- function(
    p1i,
    scenario_id,
    slow_index,
    route_id,
    mu) {
  if (slow_index == 4L) {
    return(p1i$p1h$p1g$profile_objects[[paste(
      scenario_id, route_id, mu, sep = "::"
    )]]$z)
  }
  p1i$p1h$profile_objects[[paste(
    scenario_id, slow_index, route_id, mu, sep = "::"
  )]]$z
}

mfrmr_gorb_p1j_nesting_table <- function(p1i) {
  single <- mfrmr_gorb_p1j_single_profile_rows(p1i)
  out <- vector("list", nrow(single) * 3L)
  context_cache <- list()
  output_index <- 1L
  for (row_index in seq_len(nrow(single))) {
    row <- single[row_index, , drop = FALSE]
    scenario_id <- row$ScenarioId
    slow_index <- row$TargetIndex
    if (is.null(context_cache[[scenario_id]])) {
      context_cache[[scenario_id]] <-
        mfrmr_gorb_p1j_contexts(p1i, scenario_id)
    }
    context <- context_cache[[scenario_id]][["121"]]
    x <- mfrmr_gorb_p1j_single_object(
      p1i, scenario_id, slow_index, row$RouteId, row$Lambda
    )
    single_bundle <- mfrmr_gorb_p1j_single_bundle(
      x, row$Lambda, context, slow_index,
      include_gradient = TRUE
    )
    for (fast_index in setdiff(seq_len(4L), slow_index)) {
      ordered <- mfrmr_gorb_p1j_bundle(
        x, row$Lambda, 0, context, fast_index, slow_index,
        include_gradient = TRUE
      )
      derivative_scheduled <-
        row$Lambda %in% mfrmr_gorb_p1j_derivative_mus
      numeric_rho <- NA_real_
      derivative_difference <- NA_real_
      if (derivative_scheduled) {
        h <- mfrmr_gorb_p1j_rho_derivative_step
        f0 <- ordered$objective
        f1 <- mfrmr_gorb_p1j_bundle(
          x, row$Lambda, h, context, fast_index, slow_index,
          include_gradient = FALSE
        )$objective
        f2 <- mfrmr_gorb_p1j_bundle(
          x, row$Lambda, 2 * h, context, fast_index, slow_index,
          include_gradient = FALSE
        )$objective
        numeric_rho <- (-3 * f0 + 4 * f1 - f2) / (2 * h)
        derivative_difference <- abs(ordered$rho_gradient - numeric_rho)
      }
      objective_difference <- abs(
        ordered$objective - single_bundle$objective
      )
      gradient_difference <- max(abs(
        ordered$gradient - single_bundle$gradient
      ))
      single_mu_gradient <- if (slow_index == 4L) {
        single_bundle$lambda_gradient
      } else {
        single_bundle$lambda_gradient
      }
      mu_gradient_difference <- abs(
        ordered$mu_gradient - single_mu_gradient
      )
      identity_complete <-
        isTRUE(row$ProfileCandidateEligible) &&
        objective_difference <= mfrmr_gorb_p1j_identity_tolerance &&
        gradient_difference <= mfrmr_gorb_p1j_gradient_tolerance &&
        mu_gradient_difference <= mfrmr_gorb_p1j_gradient_tolerance &&
        (!derivative_scheduled || (
          is.finite(derivative_difference) &&
            derivative_difference <=
              mfrmr_gorb_p1j_derivative_tolerance
        ))
      out[[output_index]] <- data.frame(
        ScenarioId = scenario_id,
        OrderedPairId = paste0(
          "C", fast_index, "_fast__C", slow_index, "_slow"
        ),
        FastIndex = fast_index,
        SlowIndex = slow_index,
        SingleSource = row$SingleSource,
        SourceRouteId = row$RouteId,
        Mu = row$Lambda,
        SourceSingleObjective = single_bundle$objective,
        OrderedRhoZeroObjective = ordered$objective,
        ObjectiveAbsDifference = objective_difference,
        GradientMaxAbsDifference = gradient_difference,
        MuGradientAbsDifference = mu_gradient_difference,
        RhoObjectiveDerivative = ordered$rho_gradient,
        IndependentRhoDerivativeScheduled = derivative_scheduled,
        NumericRhoObjectiveDerivative = numeric_rho,
        RhoDerivativeAbsDifference = derivative_difference,
        SourceSingleEligible = row$ProfileCandidateEligible,
        OrderedRatioBoundaryIdentityComplete = identity_complete,
        BoundaryRhoDerivativeNonnegative =
          is.finite(ordered$rho_gradient) &&
          ordered$rho_gradient >= -mfrmr_gorb_p1j_identity_tolerance,
        FixedRhoProfileCompleted = FALSE,
        FullTwoTargetFaceGloballyCertified = FALSE,
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
      output_index <- output_index + 1L
    }
  }
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result
}

mfrmr_gorb_p1j_overall_decision <- function(transport, nesting) {
  transport_complete <- nrow(transport) == 288L &&
    all(transport$PositiveP1iTransportIdentityComplete)
  nesting_complete <- nrow(nesting) == 672L &&
    all(nesting$OrderedRatioBoundaryIdentityComplete)
  derivative_nonnegative <- nesting_complete &&
    all(nesting$BoundaryRhoDerivativeNonnegative)
  data.frame(
    AllPositiveP1iPointsTransported = transport_complete,
    AllTwelveOrderedRatioBoundaryIdentitiesCertified = nesting_complete,
    AllBoundaryRhoDerivativesNonnegative = derivative_nonnegative,
    CoefficientRatioBoundaryLikelihoodIdentityCertified = nesting_complete,
    CoefficientRatioLocalDerivativeGridScreened = derivative_nonnegative,
    CoefficientRatioProfilesCompleted = FALSE,
    AllSixTwoTargetFacesGloballyCertified = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    UpperVarianceJointPathStatus = "not_evaluated",
    SourceSolutionDecision =
      "blocked_fixed_rho_profiles_three_target_faces_remaining_rater_strata_and_upper_boundary_open",
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_ordered_ratio_boundary_p1j <- function(
    p1i = NULL,
    allow_dependency_rebuild = FALSE,
    progress = FALSE) {
  mfrmr_gorb_p1j_require_sources()
  if (is.null(p1i)) {
    mfrmr_gorb_p1j_assert(
      isTRUE(allow_dependency_rebuild),
      paste0(
        "P1j requires a supplied P1i result by default; set ",
        "allow_dependency_rebuild=TRUE for the long dependency rebuild."
      )
    )
    p1i <- mfrmr_run_gpcm_two_target_radial_screen_p1i(
      progress = progress
    )
  }
  mfrmr_gorb_p1j_assert(
    is.list(p1i) && identical(
      p1i$contract, mfrmr_gorb_p1j_dependency_contract
    ),
    "P1j requires one complete P1i dependency result."
  )
  transport <- mfrmr_gorb_p1j_transport_table(p1i)
  nesting <- mfrmr_gorb_p1j_nesting_table(p1i)
  overall <- mfrmr_gorb_p1j_overall_decision(transport, nesting)
  structure(
    list(
      contract = mfrmr_gorb_p1j_contract,
      specification = mfrmr_gorb_p1j_specification,
      dependency_contract = mfrmr_gorb_p1j_dependency_contract,
      dependency_sha256 = mfrmr_gorb_p1j_dependency_sha256,
      plan = mfrmr_gorb_p1j_plan(),
      transport = transport,
      singleton_nesting = nesting,
      overall_decision = overall,
      p1i = p1i,
      AllPositiveP1iPointsTransported =
        overall$AllPositiveP1iPointsTransported,
      AllTwelveOrderedRatioBoundaryIdentitiesCertified =
        overall$AllTwelveOrderedRatioBoundaryIdentitiesCertified,
      AllBoundaryRhoDerivativesNonnegative =
        overall$AllBoundaryRhoDerivativesNonnegative,
      CoefficientRatioBoundaryLikelihoodIdentityCertified =
        overall$CoefficientRatioBoundaryLikelihoodIdentityCertified,
      CoefficientRatioLocalDerivativeGridScreened =
        overall$CoefficientRatioLocalDerivativeGridScreened,
      CoefficientRatioProfilesCompleted = FALSE,
      AllSixTwoTargetFacesGloballyCertified = FALSE,
      ThreeTargetFacesEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_ordered_ratio_boundary_p1j"
  )
}
