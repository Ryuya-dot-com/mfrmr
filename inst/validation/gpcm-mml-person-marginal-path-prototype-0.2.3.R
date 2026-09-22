# Draft.72 analytic finite-q Person-marginal GPCM slope-path oracle.

mfrmr_gpcm_mml_person_path_problem <- function(fit, quadrature_points,
                                                expanded_direction) {
  if (!inherits(fit, "mfrm_fit") ||
      !identical(as.character(fit$config$model), "GPCM") ||
      !identical(as.character(fit$config$method), "MML")) {
    stop("The Person-marginal path prototype requires an MML GPCM fit.",
         call. = FALSE)
  }
  q <- suppressWarnings(as.integer(quadrature_points)[1L])
  if (length(q) != 1L || is.na(q) || q < 1L) {
    stop("`quadrature_points` must be one positive integer.", call. = FALSE)
  }
  levels <- as.character(fit$config$gpcm_spec$levels)
  direction <- as.numeric(expanded_direction)
  names(direction) <- names(expanded_direction)
  if (is.null(names(direction)) || anyDuplicated(names(direction)) ||
      !setequal(names(direction), levels)) {
    stop("`expanded_direction` must name every fitted slope level once.",
         call. = FALSE)
  }
  direction <- direction[levels]
  if (any(!is.finite(direction)) ||
      abs(sum(direction)) > 10 * .Machine$double.eps ||
      sum(direction == 1) != 1L || sum(direction == -1) != 1L ||
      any(!direction %in% c(-1, 0, 1))) {
    stop("The prototype requires one +1, one -1, and sum-zero loadings.",
         call. = FALSE)
  }
  internal <- function(name) getFromNamespace(name, "mfrmr")
  config <- fit$config
  sizes <- internal("build_param_sizes")(config)
  idx <- internal("build_indices")(
    fit$prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  slices <- internal("build_param_slices")(sizes)
  list(
    fit = fit,
    config = config,
    sizes = sizes,
    idx = idx,
    slices = slices,
    quadrature_points = q,
    quad = internal("gauss_hermite_normal")(q),
    levels = levels,
    expanded_direction = direction,
    free_direction = direction[seq_len(length(direction) - 1L)]
  )
}

mfrmr_gpcm_mml_person_path_point <- function(problem, distance,
                                              include_details = FALSE) {
  t <- as.numeric(distance)[1L]
  if (length(t) != 1L || is.na(t) || !is.finite(t)) {
    stop("`distance` must be one finite scalar.", call. = FALSE)
  }
  internal <- function(name) getFromNamespace(name, "mfrmr")
  par <- problem$fit$opt$par
  par[problem$slices$log_slopes] <-
    par[problem$slices$log_slopes] + t * problem$free_direction
  cache <- internal("make_param_cache")(
    problem$sizes, problem$config, problem$idx, is_mml = TRUE
  )
  cache$ensure(par)
  params <- cache$params()
  bundle <- internal("mfrm_mml_logprob_bundle")(
    idx = problem$idx,
    config = problem$config,
    quad = problem$quad,
    params = params,
    base_eta = cache$base_eta(),
    step_cum = cache$step_cum(),
    include_probs = TRUE,
    include_linear_part = TRUE
  )
  person <- internal("mfrm_mml_person_bundle")(
    log_prob_mat = bundle$log_prob_mat,
    person_int = bundle$person_int,
    quad_basis = bundle$quad_basis,
    include_posterior = TRUE
  )
  n_obs <- length(problem$idx$score_k)
  n_nodes <- problem$quadrature_points
  score_index <- cbind(seq_len(n_obs), problem$idx$score_k + 1L)
  slope_index <- as.integer(problem$idx$slope_idx)
  slope <- as.numeric(params$slopes[slope_index])
  loading <- as.numeric(problem$expanded_direction[slope_index])
  weight <- as.numeric(if (is.null(problem$idx$weight)) {
    rep(1, n_obs)
  } else problem$idx$weight)
  observation_derivative <- observation_second_component <- matrix(
    NA_real_, nrow = n_obs, ncol = n_nodes
  )
  for (node in seq_len(n_nodes)) {
    utility <- as.matrix(bundle$linear_part_list[[node]])
    probability <- as.matrix(bundle$prob_list[[node]])
    observed <- utility[score_index]
    mean_utility <- rowSums(probability * utility)
    centered <- utility - mean_utility
    variance_utility <- rowSums(probability * centered^2)
    observation_derivative[, node] <- weight * loading * slope *
      (observed - mean_utility)
    observation_second_component[, node] <- weight * loading^2 *
      (slope * (observed - mean_utility) - slope^2 * variance_utility)
  }
  node_derivative <- rowsum(
    observation_derivative, bundle$person_int, reorder = FALSE
  )
  node_second_component <- rowsum(
    observation_second_component, bundle$person_int, reorder = FALSE
  )
  node_person_ids <- as.integer(rownames(node_derivative))
  person_order <- match(person$person_ids, node_person_ids)
  if (anyNA(person_order)) {
    stop("The prototype could not align Person-node derivatives.",
         call. = FALSE)
  }
  node_derivative <- node_derivative[person_order, , drop = FALSE]
  node_second_component <-
    node_second_component[person_order, , drop = FALSE]
  posterior <- person$posterior
  person_derivative <- rowSums(posterior * node_derivative)
  node_centered <- node_derivative - person_derivative
  person_second <- rowSums(posterior * node_second_component) +
    rowSums(posterior * node_centered^2)
  log_likelihood <- sum(person$log_marginal)
  optimizer_log_likelihood <- -internal("mfrm_loglik_mml")(
    par, problem$idx, problem$config, problem$sizes, problem$quad
  )
  row <- data.frame(
    Distance = t,
    LogLikelihood = log_likelihood,
    OptimizerLogLikelihood = optimizer_log_likelihood,
    LikelihoodDifference = log_likelihood - optimizer_log_likelihood,
    FirstDerivative = sum(person_derivative),
    SecondDerivative = sum(person_second),
    NegativeObservationNodeDerivatives = sum(
      observation_derivative < 0
    ),
    NegativePersonNodeDerivatives = sum(node_derivative < 0),
    NegativePersonMarginalDerivatives = sum(person_derivative < 0),
    MinimumObservationNodeDerivative = min(observation_derivative),
    MinimumPersonNodeDerivative = min(node_derivative),
    MinimumPersonMarginalDerivative = min(person_derivative),
    MaximumPersonMarginalDerivative = max(person_derivative),
    HalfLineCertified = FALSE,
    ReadinessEffect = "none_prototype_only",
    stringsAsFactors = FALSE
  )
  if (!isTRUE(include_details)) return(row)
  list(
    summary = row,
    observation_derivative = observation_derivative,
    observation_second_component = observation_second_component,
    node_derivative = node_derivative,
    node_second_component = node_second_component,
    person_derivative = person_derivative,
    person_second_derivative = person_second,
    posterior = posterior,
    log_prob_mat = bundle$log_prob_mat
  )
}

mfrmr_gpcm_mml_person_path_profile <- function(problem, distances,
                                                difference_step = 1e-4) {
  values <- as.numeric(distances)
  h <- as.numeric(difference_step)[1L]
  if (length(values) == 0L || any(!is.finite(values)) ||
      length(h) != 1L || is.na(h) || !is.finite(h) || h <= 0) {
    stop("Distances must be finite and `difference_step` positive.",
         call. = FALSE)
  }
  rows <- lapply(values, function(value) {
    center <- mfrmr_gpcm_mml_person_path_point(problem, value)
    lower <- mfrmr_gpcm_mml_person_path_point(problem, value - h)
    upper <- mfrmr_gpcm_mml_person_path_point(problem, value + h)
    center$FiniteDifferenceFirst <-
      (upper$LogLikelihood - lower$LogLikelihood) / (2 * h)
    center$FiniteDifferenceSecondFromLikelihood <-
      (upper$LogLikelihood - 2 * center$LogLikelihood +
         lower$LogLikelihood) / h^2
    center$FiniteDifferenceSecond <-
      (upper$FirstDerivative - lower$FirstDerivative) / (2 * h)
    center$FirstDerivativeDifference <-
      center$FirstDerivative - center$FiniteDifferenceFirst
    center$SecondDerivativeDifference <-
      center$SecondDerivative - center$FiniteDifferenceSecond
    center
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_mml_person_path_boundary <- function(
    problem, tie_tolerance = sqrt(.Machine$double.eps)) {
  tolerance <- as.numeric(tie_tolerance)[1L]
  if (length(tolerance) != 1L || is.na(tolerance) ||
      !is.finite(tolerance) || tolerance < 0) {
    stop("`tie_tolerance` must be one finite nonnegative scalar.",
         call. = FALSE)
  }
  internal <- function(name) getFromNamespace(name, "mfrmr")
  par <- problem$fit$opt$par
  cache <- internal("make_param_cache")(
    problem$sizes, problem$config, problem$idx, is_mml = TRUE
  )
  cache$ensure(par)
  params <- cache$params()
  bundle <- internal("mfrm_mml_logprob_bundle")(
    idx = problem$idx,
    config = problem$config,
    quad = problem$quad,
    params = params,
    base_eta = cache$base_eta(),
    step_cum = cache$step_cum(),
    include_probs = FALSE,
    include_linear_part = TRUE
  )
  current <- internal("mfrm_mml_person_bundle")(
    log_prob_mat = bundle$log_prob_mat,
    person_int = bundle$person_int,
    quad_basis = bundle$quad_basis,
    include_posterior = FALSE
  )
  n_obs <- length(problem$idx$score_k)
  n_nodes <- problem$quadrature_points
  n_categories <- as.integer(problem$config$n_cat)
  score_index <- cbind(seq_len(n_obs), problem$idx$score_k + 1L)
  slope_index <- as.integer(problem$idx$slope_idx)
  loading <- as.numeric(problem$expanded_direction[slope_index])
  weight <- as.numeric(if (is.null(problem$idx$weight)) {
    rep(1, n_obs)
  } else problem$idx$weight)
  effective <- weight > 0
  person_index <- as.integer(bundle$person_int)
  positive_rows <- which(effective & loading == 1)
  negative_rows <- which(effective & loading == -1)
  if (length(positive_rows) == 0L || length(negative_rows) == 0L) {
    stop("The boundary prototype requires both effective direction groups.",
         call. = FALSE)
  }

  positive_compatible <- matrix(
    TRUE, nrow = n_obs, ncol = n_nodes
  )
  positive_ties <- matrix(1L, nrow = n_obs, ncol = n_nodes)
  negative_leading <- matrix(0, nrow = n_obs, ncol = n_nodes)
  for (node in seq_len(n_nodes)) {
    utility <- as.matrix(bundle$linear_part_list[[node]])
    observed <- utility[score_index]
    maximum <- apply(utility, 1L, max)
    comparison_scale <- pmax(1, abs(maximum), abs(observed))
    positive_compatible[, node] <-
      maximum - observed <= tolerance * comparison_scale
    maximum_matrix <- matrix(
      maximum, nrow = n_obs, ncol = n_categories
    )
    tie_scale <- pmax(1, abs(maximum_matrix), abs(utility))
    positive_ties[, node] <- rowSums(
      abs(utility - maximum_matrix) <= tolerance * tie_scale
    )
    uniform_mean <- rowMeans(utility)
    negative_leading[, node] <- weight *
      as.numeric(params$slopes[slope_index]) *
      (uniform_mean - observed)
  }

  person_ids <- current$person_ids
  person_node_compatible <- matrix(
    TRUE, nrow = length(person_ids), ncol = n_nodes,
    dimnames = list(as.character(person_ids), NULL)
  )
  for (p in seq_along(person_ids)) {
    rows <- intersect(
      positive_rows, which(person_index == person_ids[[p]])
    )
    person_node_compatible[p, ] <- if (length(rows) == 0L) {
      FALSE
    } else colSums(!positive_compatible[rows, , drop = FALSE]) == 0L
  }
  compatible_count <- rowSums(person_node_compatible)
  if (any(compatible_count == 0L)) {
    return(data.frame(
      State = "zero_person_boundary_marginal",
      BoundaryLogLikelihood = -Inf,
      CurrentLogLikelihood = sum(current$log_marginal),
      BoundaryImprovement = -Inf,
      TailCoefficient = NA_real_,
      MinimumCompatibleNodesPerPerson = min(compatible_count),
      MaximumCompatibleNodesPerPerson = max(compatible_count),
      HalfLineCertified = FALSE,
      TailCertified = FALSE,
      ReadinessEffect = "none_prototype_only",
      stringsAsFactors = FALSE
    ))
  }

  boundary_log_prob <- bundle$log_prob_mat
  boundary_log_prob[positive_rows, ] <-
    -log(positive_ties[positive_rows, , drop = FALSE]) *
    weight[positive_rows]
  boundary_log_prob[negative_rows, ] <- matrix(
    -log(n_categories) * weight[negative_rows],
    nrow = length(negative_rows), ncol = n_nodes
  )
  boundary_by_person <- rowsum(
    boundary_log_prob, person_index, reorder = FALSE
  )
  boundary_by_person <- boundary_by_person[
    match(person_ids, as.integer(rownames(boundary_by_person))), ,
    drop = FALSE
  ]
  log_joint <- bundle$quad_basis$log_weights[person_ids, , drop = FALSE] +
    boundary_by_person
  log_joint[!person_node_compatible] <- -Inf
  row_maximum <- apply(log_joint, 1L, max)
  boundary_log_marginal <- row_maximum +
    log(rowSums(exp(log_joint - row_maximum)))
  posterior <- exp(log_joint - boundary_log_marginal)

  negative_leading[loading != -1 | !effective, ] <- 0
  leading_by_person <- rowsum(
    negative_leading, person_index, reorder = FALSE
  )
  leading_by_person <- leading_by_person[
    match(person_ids, as.integer(rownames(leading_by_person))), ,
    drop = FALSE
  ]
  tail_by_person <- rowSums(posterior * leading_by_person)
  boundary_log_likelihood <- sum(boundary_log_marginal)
  current_log_likelihood <- sum(current$log_marginal)
  data.frame(
    State = "boundary_and_leading_tail_computed",
    BoundaryLogLikelihood = boundary_log_likelihood,
    CurrentLogLikelihood = current_log_likelihood,
    BoundaryImprovement = boundary_log_likelihood - current_log_likelihood,
    TailCoefficient = sum(tail_by_person),
    MinimumCompatibleNodesPerPerson = min(compatible_count),
    MaximumCompatibleNodesPerPerson = max(compatible_count),
    HalfLineCertified = FALSE,
    TailCertified = FALSE,
    ReadinessEffect = "none_prototype_only",
    stringsAsFactors = FALSE
  )
}
