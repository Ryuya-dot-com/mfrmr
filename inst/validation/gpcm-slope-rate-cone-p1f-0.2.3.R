# mfrmr 0.2.3 GPCM lower-boundary slope-rate cone P1f audit
#
# Let sigma(t) = sigma0 exp(-s t), s > 0, and
# a_c(t) = a_c0 exp(r_c t). Geometric-mean-one slope identification gives
# sum_c r_c = 0. A finite random coefficient a_c sigma requires r_c <= s.
# After u_c = r_c / s and w_c = (1 - u_c) / J, the admissible normalized
# rate set is exactly the standard simplex: w_c >= 0 and sum_c w_c = 1.
# A nonempty proper target set T = {c: u_c = 1} is therefore a simplex face.
# P1f enumerates those faces and derives their canonical reduced likelihood.
# It does not optimize all faces, classify the no-random-product stratum, or
# authorize source selection and downstream inference.

mfrmr_gsrc_p1f_specification <- "0.2.3-draft.1"
mfrmr_gsrc_p1f_contract <- "mfrmr_gpcm_slope_rate_cone_p1f_v1"
mfrmr_gsrc_p1f_dependency_contract <-
  "mfrmr_gpcm_coordinate_scaled_joint_limit_p1e_v1"
mfrmr_gsrc_p1f_dependency_sha256 <-
  "38a931ab9f2de9e8c48579f4fd1bf356f013d2e14c9dc7c7993d9b2e0691915f"
mfrmr_gsrc_p1f_derivative_step <- 1e-6
mfrmr_gsrc_p1f_directional_probe_step <- 1e-3
mfrmr_gsrc_p1f_nested_objective_tolerance <- 1e-9
mfrmr_gsrc_p1f_gradient_check_tolerance <- 5e-6

mfrmr_gsrc_p1f_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsrc_p1f_require_sources <- function() {
  target <- environment(mfrmr_gsrc_p1f_require_sources)
  required <- c(
    "mfrmr_gcl_p1e_contract",
    "mfrmr_run_gpcm_coordinate_scaled_joint_limit_p1e",
    "mfrmr_gcl_p1e_transform", "mfrmr_gcl_p1e_limit_bundle",
    "mfrmr_gcl_p1e_softmax", "mfrmr_gqi_p1b_context",
    "mfrmr_num_central_gradient", "mfrmr_gss_get",
    "mfrmr_gss_hash_vector", "mfrmr_gss_compare_signatures"
  )
  available <- vapply(
    required, exists, logical(1), envir = target, inherits = TRUE
  )
  mfrmr_gsrc_p1f_assert(
    all(available) && identical(
      get("mfrmr_gcl_p1e_contract", envir = target, inherits = TRUE),
      mfrmr_gsrc_p1f_dependency_contract
    ),
    "Source P0 through P1e and their numerical dependencies before P1f."
  )
  invisible(TRUE)
}

mfrmr_gsrc_p1f_rates_to_weights <- function(normalized_rates) {
  normalized_rates <- as.numeric(normalized_rates)
  mfrmr_gsrc_p1f_assert(
    length(normalized_rates) >= 2L && all(is.finite(normalized_rates)),
    "P1f normalized rates must be a finite vector of length at least two."
  )
  (1 - normalized_rates) / length(normalized_rates)
}

mfrmr_gsrc_p1f_weights_to_rates <- function(simplex_weights) {
  simplex_weights <- as.numeric(simplex_weights)
  mfrmr_gsrc_p1f_assert(
    length(simplex_weights) >= 2L && all(is.finite(simplex_weights)),
    "P1f simplex weights must be a finite vector of length at least two."
  )
  1 - length(simplex_weights) * simplex_weights
}

mfrmr_gsrc_p1f_classify_rates <- function(
    normalized_rates,
    tolerance = 1e-10) {
  normalized_rates <- as.numeric(normalized_rates)
  tolerance <- as.numeric(tolerance)[1L]
  mfrmr_gsrc_p1f_assert(
    length(normalized_rates) >= 2L && all(is.finite(normalized_rates)) &&
      is.finite(tolerance) && tolerance >= 0,
    "P1f rate classification requires finite rates and tolerance."
  )
  weights <- mfrmr_gsrc_p1f_rates_to_weights(normalized_rates)
  sum_residual <- sum(normalized_rates)
  upper_excess <- max(normalized_rates - 1)
  admissible <- abs(sum_residual) <= tolerance && upper_excess <= tolerance
  target <- if (admissible) {
    which(abs(normalized_rates - 1) <= tolerance)
  } else integer(0)
  status <- if (!admissible) {
    "outside_finite_random_coefficient_rate_simplex"
  } else if (length(target) == 0L) {
    "admissible_no_random_product_retained"
  } else if (length(target) == length(normalized_rates)) {
    "infeasible_all_target_numerical_tolerance_conflict"
  } else {
    "admissible_nonempty_random_target_face"
  }
  list(
    normalized_rates = normalized_rates,
    simplex_weights = weights,
    target_indices = as.integer(target),
    target_count = length(target),
    sum_residual = sum_residual,
    maximum_upper_excess = upper_excess,
    admissible = admissible,
    status = status,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gsrc_p1f_target_sets <- function(levels) {
  levels <- as.character(levels)
  j <- length(levels)
  mfrmr_gsrc_p1f_assert(
    j >= 2L && all(nzchar(levels)) && !anyDuplicated(levels),
    "P1f target levels must be unique nonempty labels."
  )
  rows <- list()
  row_index <- 1L
  for (size in seq_len(j - 1L)) {
    combinations <- utils::combn(seq_len(j), size, simplify = FALSE)
    for (target in combinations) {
      rates <- rep(-size / (j - size), j)
      rates[target] <- 1
      weights <- mfrmr_gsrc_p1f_rates_to_weights(rates)
      rows[[row_index]] <- data.frame(
        TargetSetId = paste(levels[target], collapse = "+"),
        TargetIndices = paste(target, collapse = ","),
        TargetLevels = paste(levels[target], collapse = "+"),
        TargetCount = size,
        FaceDimension = j - size - 1L,
        IsRateSimplexVertex = size == j - 1L,
        BarycenterNormalizedRates = paste(
          formatC(rates, digits = 16L, format = "fg", flag = "#"),
          collapse = ","
        ),
        BarycenterSimplexWeights = paste(
          formatC(weights, digits = 16L, format = "fg", flag = "#"),
          collapse = ","
        ),
        RandomProductsRetained = size,
        ReducedLikelihoodDerived = TRUE,
        TargetSetOptimized = FALSE,
        GlobalJointBoundaryProfileCertified = FALSE,
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
      rows[[row_index]]$target_indices <- list(as.integer(target))
      rows[[row_index]]$barycenter_rates <- list(as.numeric(rates))
      rows[[row_index]]$simplex_weights <- list(as.numeric(weights))
      row_index <- row_index + 1L
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_gsrc_p1f_polytope_contract <- function(levels) {
  levels <- as.character(levels)
  j <- length(levels)
  target_sets <- mfrmr_gsrc_p1f_target_sets(levels)
  vertices <- lapply(seq_len(j), function(low_index) {
    rates <- rep(1, j)
    rates[low_index] <- -(j - 1L)
    weights <- mfrmr_gsrc_p1f_rates_to_weights(rates)
    data.frame(
      VertexId = paste0("V", low_index),
      LowRateIndex = low_index,
      LowRateLevel = levels[low_index],
      TargetSetId = paste(levels[-low_index], collapse = "+"),
      NormalizedRates = paste(rates, collapse = ","),
      SimplexWeights = paste(weights, collapse = ","),
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  vertices <- do.call(rbind, vertices)
  rownames(vertices) <- NULL
  list(
    n_criteria = j,
    normalized_rate_constraints =
      "sum(u_c)=0 and u_c<=1 for every criterion",
    affine_simplex_map = "w_c=(1-u_c)/J; u_c=1-J*w_c",
    target_set_definition = "T={c:u_c=1}={c:w_c=0}",
    target_sets = target_sets,
    vertices = vertices,
    number_nonempty_proper_target_sets = 2^j - 2L,
    no_random_product_stratum =
      "T_empty_requires_separate_deterministic_rater_rate_hierarchy",
    curved_or_rate_nonconvergent_paths = "not_classified",
    RateConeClassifiedForFiniteRandomProducts = TRUE,
    GlobalJointBoundaryProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gsrc_p1f_layout <- function(context, target_indices) {
  n_rater <- length(context$config$facet_levels[["Rater"]])
  n_criterion <- length(context$config$facet_levels[["Criterion"]])
  target_indices <- sort(unique(as.integer(target_indices)))
  mfrmr_gsrc_p1f_assert(
    length(target_indices) >= 1L && length(target_indices) < n_criterion &&
      all(target_indices >= 1L & target_indices <= n_criterion),
    "P1f canonical random-target likelihood requires a nonempty proper target set."
  )
  step_free_per_criterion <- context$sizes$steps / n_criterion
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
    log_lambda = allocate(length(target_indices)),
    n_rater = n_rater,
    n_criterion = n_criterion,
    step_free_per_criterion = step_free_per_criterion,
    target_indices = target_indices,
    dimension = position - 1L
  )
}

mfrmr_gsrc_p1f_unpack <- function(y, context, target_indices) {
  layout <- mfrmr_gsrc_p1f_layout(context, target_indices)
  y <- as.numeric(y)
  mfrmr_gsrc_p1f_assert(
    length(y) == layout$dimension && all(is.finite(y)),
    "P1f canonical limit vector has invalid dimension or values."
  )
  rater <- mfrmr_gss_get("expand_facet")(
    y[layout$rater], layout$n_rater
  )
  step_free <- matrix(
    y[layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  step_matrix <- t(vapply(seq_len(layout$n_criterion), function(index) {
    mfrmr_gss_get("expand_sum_zero_vector")(
      step_free[index, ], context$config$n_cat - 1L
    )
  }, numeric(context$config$n_cat - 1L)))
  step_cumulative <- t(apply(
    step_matrix, 1L, function(value) c(0, cumsum(value))
  ))
  lambda <- exp(y[layout$log_lambda])
  mfrmr_gsrc_p1f_assert(
    all(is.finite(lambda) & lambda > 0),
    "P1f finite target coefficients must be positive and finite."
  )
  list(
    layout = layout,
    rater = rater,
    location = y[layout$location],
    step_free = step_free,
    step_matrix = step_matrix,
    step_cumulative = step_cumulative,
    log_lambda = y[layout$log_lambda],
    lambda = lambda
  )
}

mfrmr_gsrc_p1f_limit_bundle <- function(
    y,
    context,
    target_indices,
    include_gradient = TRUE) {
  unpacked <- mfrmr_gsrc_p1f_unpack(y, context, target_indices)
  layout <- unpacked$layout
  idx <- context$idx
  n <- length(idx$score_k)
  n_nodes <- length(context$quad$nodes)
  k_values <- 0:(context$config$n_cat - 1L)
  observed_index <- cbind(seq_len(n), idx$score_k + 1L)
  criterion <- as.integer(idx$slope_idx)
  rater_index <- as.integer(idx$facets[["Rater"]])
  target_position <- match(criterion, layout$target_indices)
  target_observation <- !is.na(target_position)
  discrimination <- rep(1, n)
  discrimination[target_observation] <-
    unpacked$lambda[target_position[target_observation]]
  log_probability <- matrix(0, nrow = n, ncol = n_nodes)
  probability <- vector("list", n_nodes)
  log_numerator <- vector("list", n_nodes)
  for (q in seq_len(n_nodes)) {
    eta <- unpacked$location[criterion]
    eta[target_observation] <- eta[target_observation] -
      unpacked$rater[rater_index[target_observation]] +
      context$quad$nodes[q]
    base <- outer(eta, k_values) -
      unpacked$step_cumulative[criterion, , drop = FALSE]
    log_num <- base * matrix(
      discrimination, nrow = n, ncol = length(k_values)
    )
    softmax <- mfrmr_gcl_p1e_softmax(log_num)
    lp <- log_num[observed_index] - softmax$log_denom
    if (!is.null(idx$weight)) lp <- lp * idx$weight
    log_probability[, q] <- lp
    probability[[q]] <- softmax$probs
    log_numerator[[q]] <- log_num
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
  score_log_lambda <- numeric(length(layout$target_indices))
  indicator_geq <- outer(
    idx$score_k, seq_len(context$config$n_cat - 1L), ">="
  ) * 1
  for (q in seq_len(n_nodes)) {
    probs <- probability[[q]]
    log_num <- log_numerator[[q]]
    expected <- as.vector(probs %*% k_values)
    residual <- discrimination * (idx$score_k - expected)
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
      discrimination * observation_posterior[, q]
    if (!is.null(idx$weight)) step_score <- step_score * idx$weight
    step_sum <- rowsum(step_score, criterion, reorder = FALSE)
    step_ids <- as.integer(rownames(step_sum))
    score_step[step_ids, ] <- score_step[step_ids, , drop = FALSE] +
      step_sum

    lambda_score_observation <- log_num[observed_index] -
      rowSums(probs * log_num)
    lambda_score_observation <- lambda_score_observation *
      observation_posterior[, q]
    if (!is.null(idx$weight)) {
      lambda_score_observation <- lambda_score_observation * idx$weight
    }
    lambda_sum <- rowsum(
      matrix(
        lambda_score_observation[target_observation], ncol = 1L
      ),
      target_position[target_observation], reorder = FALSE
    )
    lambda_ids <- as.integer(rownames(lambda_sum))
    score_log_lambda[lambda_ids] <- score_log_lambda[lambda_ids] +
      as.vector(lambda_sum)
  }
  gradient <- c(
    -mfrmr_gss_get("project_sum_zero_gradient")(score_rater),
    -score_location,
    -mfrmr_gss_get("project_step_matrix_gradient")(score_step),
    -score_log_lambda
  )
  mfrmr_gsrc_p1f_assert(
    length(gradient) == layout$dimension && all(is.finite(gradient)),
    "P1f canonical reduced-limit gradient is invalid."
  )
  list(
    objective = objective,
    gradient = gradient,
    log_probability = log_probability,
    posterior = posterior,
    lambda = unpacked$lambda
  )
}

mfrmr_gsrc_p1f_from_p1e <- function(y_p1e, transform) {
  y_p1e <- as.numeric(y_p1e)
  p1e_layout <- transform$layout
  target <- as.integer(transform$target_index)
  context <- transform$context
  layout <- mfrmr_gsrc_p1f_layout(context, target)
  mfrmr_gsrc_p1f_assert(
    length(y_p1e) == p1e_layout$dimension &&
      layout$dimension == p1e_layout$dimension + 1L &&
      is.finite(transform$anchor_sigma) && transform$anchor_sigma > 0 &&
      all(is.finite(transform$anchor_slopes) & transform$anchor_slopes > 0),
    "P1f requires one valid single-target P1e coordinate vector."
  )
  out <- numeric(layout$dimension)
  out[layout$rater] <- y_p1e[p1e_layout$rater] / transform$anchor_sigma
  p1e_location <- y_p1e[p1e_layout$location]
  canonical_location <- transform$anchor_slopes * p1e_location
  canonical_location[target] <-
    p1e_location[target] / transform$anchor_sigma
  out[layout$location] <- canonical_location
  p1e_steps <- matrix(
    y_p1e[p1e_layout$steps],
    nrow = layout$n_criterion, byrow = TRUE
  )
  canonical_steps <- p1e_steps * transform$anchor_slopes
  canonical_steps[target, ] <-
    p1e_steps[target, ] / transform$anchor_sigma
  out[layout$steps] <- as.numeric(t(canonical_steps))
  out[layout$log_lambda] <- log(
    transform$anchor_slopes[target] * transform$anchor_sigma
  )
  out
}

mfrmr_gsrc_p1f_nested_evaluation <- function(
    scenario_id,
    route_id,
    y_p1e,
    transform,
    contexts) {
  canonical <- mfrmr_gsrc_p1f_from_p1e(y_p1e, transform)
  target <- transform$target_index
  p1e_objectives <- vapply(contexts, function(context) {
    local_transform <- transform
    local_transform$context <- context
    mfrmr_gcl_p1e_limit_bundle(
      y_p1e, local_transform, context, include_gradient = FALSE
    )$objective
  }, numeric(1L))
  p1f_objectives <- vapply(contexts, function(context) {
    mfrmr_gsrc_p1f_limit_bundle(
      canonical, context, target, include_gradient = FALSE
    )$objective
  }, numeric(1L))
  bundle <- mfrmr_gsrc_p1f_limit_bundle(
    canonical, contexts[["121"]], target, include_gradient = TRUE
  )
  numeric_gradient <- mfrmr_num_central_gradient(
    function(value) mfrmr_gsrc_p1f_limit_bundle(
      value, contexts[["121"]], target, include_gradient = FALSE
    )$objective,
    canonical,
    mfrmr_gsrc_p1f_derivative_step
  )
  layout <- mfrmr_gsrc_p1f_layout(contexts[["121"]], target)
  lambda_gradient <- bundle$gradient[layout$log_lambda]
  descent <- canonical
  descent[layout$log_lambda] <- descent[layout$log_lambda] -
    sign(lambda_gradient) * mfrmr_gsrc_p1f_directional_probe_step
  descent_objective <- mfrmr_gsrc_p1f_limit_bundle(
    descent, contexts[["121"]], target, include_gradient = FALSE
  )$objective
  derivative_resolved <- abs(lambda_gradient) > max(
    1e-5,
    100 * max(abs(bundle$gradient - numeric_gradient))
  )
  nested_difference <- max(abs(p1e_objectives - p1f_objectives))
  gradient_difference <- max(abs(bundle$gradient - numeric_gradient))
  nested_complete <- all(is.finite(c(
    p1e_objectives, p1f_objectives, bundle$gradient, numeric_gradient
  ))) &&
    nested_difference <= mfrmr_gsrc_p1f_nested_objective_tolerance &&
    gradient_difference <= mfrmr_gsrc_p1f_gradient_check_tolerance
  data.frame(
    ScenarioId = scenario_id,
    RouteId = route_id,
    TargetSetId = as.character(
      contexts[["121"]]$config$facet_levels[["Criterion"]][target]
    ),
    TargetCount = 1L,
    P1eObjectiveQ121 = as.numeric(p1e_objectives[["121"]]),
    P1fObjectiveQ121 = as.numeric(p1f_objectives[["121"]]),
    NestedObjectiveMaxAbsDifference = nested_difference,
    NestedObjectiveTolerance = mfrmr_gsrc_p1f_nested_objective_tolerance,
    P1fQuadratureObjectiveRange = diff(range(p1f_objectives)),
    P1fAnalyticNumericGradientMaxAbsDifference = gradient_difference,
    GradientCheckTolerance = mfrmr_gsrc_p1f_gradient_check_tolerance,
    FixedLogLambda = canonical[layout$log_lambda],
    FixedLambda = bundle$lambda,
    FreeLogLambdaGradient = lambda_gradient,
    FreeLogLambdaGradientMaxAbs = max(abs(lambda_gradient)),
    DirectionalProbeStep = mfrmr_gsrc_p1f_directional_probe_step,
    DirectionalProbeObjectiveDifference =
      descent_objective - bundle$objective,
    FreeLogLambdaDerivativeResolvedNonzero = derivative_resolved,
    P1eFixedCoefficientStationarityStatus = if (derivative_resolved) {
      "resolved_nonstationary_free_log_lambda_direction"
    } else {
      "not_resolved"
    },
    P1eNestedIdentityComplete = nested_complete,
    P1eFaceCoefficientOptimized = FALSE,
    AllTargetSetsOptimized = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    CanonicalVectorSHA256 = mfrmr_gss_hash_vector(canonical),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsrc_p1f_decision <- function(target_sets, nested_rows) {
  expected <- 2^4L - 2L
  classification_complete <- nrow(target_sets) == expected &&
    all(target_sets$ReducedLikelihoodDerived) &&
    identical(
      as.integer(table(factor(target_sets$TargetCount, levels = 1:3))),
      c(4L, 6L, 4L)
    )
  nested_complete <- nrow(nested_rows) == 8L &&
    all(nested_rows$P1eNestedIdentityComplete) &&
    all(is.finite(nested_rows$NestedObjectiveMaxAbsDifference)) &&
    all(is.finite(nested_rows$P1fAnalyticNumericGradientMaxAbsDifference))
  data.frame(
    RateSimplexClassificationComplete = classification_complete,
    NonemptyProperTargetSetCount = nrow(target_sets),
    CanonicalReducedLikelihoodDerived = TRUE,
    P1eSingleTargetNestedIdentityComplete = nested_complete,
    P1eFixedCoefficientDerivativeResolvedNonzero = nested_complete &&
      all(nested_rows$FreeLogLambdaDerivativeResolvedNonzero) &&
      all(nested_rows$DirectionalProbeObjectiveDifference < 0),
    P1eFaceCoefficientOptimized = FALSE,
    AllTargetSetsOptimized = FALSE,
    NoRandomProductStratumClassified = FALSE,
    CurvedOrRateNonconvergentPathsClassified = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    UpperVarianceJointPathStatus = "not_evaluated",
    SourceSolutionDecision =
      "blocked_target_faces_unoptimized_empty_target_stratum_and_upper_boundary_open",
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsrc_p1f_signature <- function(decision) {
  data.frame(
    Metric = c(
      "finite_random_rate_cone", "nonempty_target_sets",
      "canonical_reduced_likelihood", "p1e_embedding",
      "target_face_optimization", "empty_target_stratum",
      "curved_or_nonconvergent_rates", "upper_joint_variance_boundary",
      "source_solution_selection", "hessian", "dff_fit_rank", "overall"
    ),
    State = c(
      if (isTRUE(decision$RateSimplexClassificationComplete)) {
        "classified_as_standard_simplex"
      } else "blocked",
      paste0(decision$NonemptyProperTargetSetCount, "_enumerated"),
      "derived_with_free_positive_target_coefficients",
      if (isTRUE(decision$P1eSingleTargetNestedIdentityComplete)) {
        if (isTRUE(decision$P1eFixedCoefficientDerivativeResolvedNonzero)) {
          "exact_single_target_fixed_coefficient_submodel_nonstationary_in_free_coefficient"
        } else {
          "exact_single_target_fixed_coefficient_submodel"
        }
      } else "blocked",
      "not_executed", "not_classified", "not_classified",
      "not_evaluated", "blocked", "not_evaluated", "not_evaluated",
      "review"
    ),
    Eligibility = c(
      rep("analytic_classification_complete", 4L),
      rep("not_selection_eligible", 8L)
    ),
    Reason = c(
      "u_equals_one_minus_Jw_is_an_affine_bijection",
      "all_nonempty_proper_zero_coordinate_simplex_faces_enumerated",
      "target_random_and_rater_terms_retained_non_targets_deterministic",
      "p1e_objective_recovered_but_free_log_lambda_direction_is_nonstationary",
      "free_lambda_and_all_target_sets_require_multistart_optimization",
      "deterministic_rater_rate_hierarchy_is_separate",
      "absence_of_a_linear_rate_limit_is_not_covered",
      "large_variance_joint_path_remains_separate",
      "global_boundary_work_remains_open",
      "source_solution_not_selected",
      "source_solution_not_selected",
      "p1f_rate_cone_derivation_only"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_slope_rate_cone_p1f <- function(
    progress = FALSE,
    p1e = NULL) {
  mfrmr_gsrc_p1f_require_sources()
  if (is.null(p1e)) {
    p1e <- mfrmr_run_gpcm_coordinate_scaled_joint_limit_p1e(
      progress = progress
    )
  }
  mfrmr_gsrc_p1f_assert(
    is.list(p1e) && identical(
      p1e$contract, mfrmr_gsrc_p1f_dependency_contract
    ),
    "P1f requires one complete P1e dependency result."
  )
  first_source <- p1e$p1d$p1c$p0b$scenario_results[[
    mfrmr_gcl_p1e_scenarios[1L]
  ]]
  levels <- as.character(first_source$fit$config$facet_levels[["Criterion"]])
  polytope <- mfrmr_gsrc_p1f_polytope_contract(levels)
  nested <- list()
  row_index <- 1L
  for (scenario_id in mfrmr_gcl_p1e_scenarios) {
    source <- p1e$p1d$p1c$p0b$scenario_results[[scenario_id]]
    contexts <- lapply(mfrmr_gcl_p1e_quadrature, function(q) {
      mfrmr_gqi_p1b_context(source$fit, q)
    })
    names(contexts) <- as.character(mfrmr_gcl_p1e_quadrature)
    geometry <- p1e$p1d$geometry[
      p1e$p1d$geometry$ScenarioId == scenario_id, , drop = FALSE
    ]
    target <- as.integer(geometry$TargetSlopeIndex)
    anchor <- p1e$p1d$p1c$interior_candidate_objects[[scenario_id]]$opt$par
    transform <- mfrmr_gcl_p1e_transform(
      contexts[["121"]], anchor, target,
      max(mfrmr_gcl_p1e_t_ladder)
    )
    for (route_id in mfrmr_gcl_p1e_routes) {
      if (isTRUE(progress)) message(
        "Slope-rate cone P1f: ", scenario_id, " / ", route_id
      )
      candidate <- p1e$reduced_limit_candidate_objects[[paste(
        scenario_id, route_id, sep = "::"
      )]]
      nested[[row_index]] <- mfrmr_gsrc_p1f_nested_evaluation(
        scenario_id, route_id, candidate$y, transform, contexts
      )
      row_index <- row_index + 1L
    }
  }
  nested <- do.call(rbind, nested)
  rownames(nested) <- NULL
  decision <- mfrmr_gsrc_p1f_decision(polytope$target_sets, nested)
  signature <- mfrmr_gsrc_p1f_signature(decision)
  structure(
    list(
      contract = mfrmr_gsrc_p1f_contract,
      specification = mfrmr_gsrc_p1f_specification,
      dependency_contract = mfrmr_gsrc_p1f_dependency_contract,
      dependency_sha256 = mfrmr_gsrc_p1f_dependency_sha256,
      polytope = polytope,
      nested_p1e_evaluations = nested,
      decision = decision,
      decision_signature = signature,
      p1e = p1e,
      RateConeClassifiedForFiniteRandomProducts = TRUE,
      AllTargetSetsOptimized = FALSE,
      NoRandomProductStratumClassified = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      UpperVarianceJointPathStatus = "not_evaluated",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_slope_rate_cone_p1f"
  )
}
