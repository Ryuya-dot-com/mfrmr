# JML GPCM joint additive/log-slope boundary-path audit
# ==============================================================================
#
# This audit certifies a deliberately bounded family of nonlinear paths.  For
# an ordered pair of slope levels, expanded log slopes move at rates +1 and -1
# while all remaining expanded log slopes stay fixed.  The free additive
# coordinates move linearly along a constrained direction d.  If
#
# * every positive-rate observation uniquely favors its observed category in
#   the cumulative additive direction,
# * every zero-rate observation weakly favors its observed category, and
# * the negative-rate observations have a strictly favorable aggregate
#   leading term as their slope tends to zero,
#
# then the likelihood derivative is positive on an asymptotic tail.  A path is
# retained as a competitive boundary candidate only when its analytic boundary
# likelihood is no worse than the retained likelihood.  These sufficient
# conditions detect joint paths missed by both additive-only and slope-only
# audits.  Failure to certify this path family is not evidence of a finite MLE,
# and a positive candidate is not a global nonlinear identification proof.

mfrmr_jml_gpcm_joint_empty_pair_table <- function() {
  data.frame(
    PairId = character(0),
    PositiveLevel = character(0),
    NegativeLevel = character(0),
    PositiveIndex = integer(0),
    NegativeIndex = integer(0),
    SolverStatus = integer(0),
    MarginCapacity = numeric(0),
    PositiveMinimumMargin = numeric(0),
    NeutralMinimumMargin = numeric(0),
    NegativeLeadingCoefficient = numeric(0),
    AdditiveDirectionL1 = numeric(0),
    CurrentLogLikelihood = numeric(0),
    BoundaryLogLikelihood = numeric(0),
    BoundaryImprovement = numeric(0),
    AnalyticTailCertified = logical(0),
    CompetitiveBoundary = logical(0),
    Certified = logical(0),
    EvaluationState = character(0),
    ReasonCodes = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_gpcm_joint_empty_target_table <- function() {
  data.frame(
    ParameterId = character(0),
    ParameterClass = character(0),
    Facet = character(0),
    Level = character(0),
    PositiveBoundaryCandidate = logical(0),
    NegativeBoundaryCandidate = logical(0),
    CandidateStatus = character(0),
    EvaluationState = character(0),
    ReasonCodes = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_gpcm_joint_empty_loading_table <- function() {
  data.frame(
    PairId = character(0),
    CoordinateType = character(0),
    OptimizerIndex = integer(0),
    Coordinate = character(0),
    Level = character(0),
    Loading = numeric(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_gpcm_joint_targets <- function(levels, slope_facet,
                                          positive = NULL,
                                          negative = NULL,
                                          evaluation_state = "evaluated",
                                          reason = "no_joint_pair_path_certified") {
  levels <- as.character(levels)
  if (length(levels) == 0L) {
    return(mfrmr_jml_gpcm_joint_empty_target_table())
  }
  positive <- as.logical(positive %||% rep(FALSE, length(levels)))
  negative <- as.logical(negative %||% rep(FALSE, length(levels)))
  status <- rep("none_certified_in_joint_pair_paths", length(levels))
  status[positive & !negative] <- "joint_boundary_path_high"
  status[!positive & negative] <- "joint_boundary_path_low"
  status[positive & negative] <- "joint_boundary_path_both"
  data.frame(
    ParameterId = paste0("Slope:", slope_facet, ":", levels),
    ParameterClass = rep("log_slope", length(levels)),
    Facet = rep(as.character(slope_facet), length(levels)),
    Level = levels,
    PositiveBoundaryCandidate = positive,
    NegativeBoundaryCandidate = negative,
    CandidateStatus = status,
    EvaluationState = rep(evaluation_state, length(levels)),
    ReasonCodes = ifelse(positive | negative,
                         "certified_joint_nonlinear_boundary_candidate",
                         reason),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_gpcm_joint_pair_lp <- function(
    contrast,
    contrast_observation,
    slope_index,
    weight,
    n_categories,
    positive_index,
    negative_index,
    max_lp_nonzeros,
    lp_timeout,
    certificate_tolerance) {
  contrast <- methods::as(contrast, "dgCMatrix")
  contrast_observation <- as.integer(contrast_observation)
  n_parameters <- ncol(contrast)
  effective_contrast <- weight[contrast_observation] > 0
  positive_rows <- which(
    effective_contrast & slope_index[contrast_observation] == positive_index
  )
  negative_rows <- which(
    effective_contrast & slope_index[contrast_observation] == negative_index
  )
  neutral_rows <- which(
    effective_contrast &
      !slope_index[contrast_observation] %in%
        c(positive_index, negative_index)
  )
  empty_result <- list(
    evaluated = TRUE,
    certified = FALSE,
    solver_status = NA_integer_,
    margin_capacity = NA_real_,
    positive_minimum_margin = NA_real_,
    neutral_minimum_margin = NA_real_,
    negative_leading_coefficient = NA_real_,
    direction_l1 = NA_real_,
    direction = rep(NA_real_, n_parameters),
    lp_constraints = 0L,
    lp_variables = as.integer(2L * n_parameters + 1L),
    lp_nonzeros = 0,
    reason = "not_evaluated"
  )
  if (length(positive_rows) == 0L || length(negative_rows) == 0L) {
    empty_result$reason <- "slope_pair_lacks_positive_weight_support"
    return(empty_result)
  }

  positive <- contrast[positive_rows, , drop = FALSE]
  neutral <- contrast[neutral_rows, , drop = FALSE]
  negative <- contrast[negative_rows, , drop = FALSE]
  negative_weight <- weight[contrast_observation[negative_rows]] /
    as.numeric(n_categories)
  negative_vector <- as.numeric(Matrix::colSums(
    Matrix::Diagonal(x = negative_weight) %*% negative
  ))

  n_positive <- nrow(positive)
  n_neutral <- nrow(neutral)
  negative_constraint_row <- n_positive + n_neutral + 1L
  bound_row_offset <- negative_constraint_row
  n_constraints <- n_positive + n_neutral + 1L + n_parameters
  n_variables <- 2L * n_parameters + 1L
  margin_index <- n_variables

  support <- rbind(positive, neutral)
  support_triplet <- Matrix::summary(support)
  triplet <- matrix(numeric(0), nrow = 0L, ncol = 3L)
  if (nrow(support_triplet) > 0L) {
    triplet <- rbind(
      triplet,
      cbind(support_triplet$i, support_triplet$j, support_triplet$x),
      cbind(support_triplet$i,
            n_parameters + support_triplet$j,
            -support_triplet$x)
    )
  }
  if (n_positive > 0L) {
    triplet <- rbind(
      triplet,
      cbind(seq_len(n_positive), margin_index, -1)
    )
  }
  negative_keep <- which(negative_vector != 0)
  if (length(negative_keep) > 0L) {
    triplet <- rbind(
      triplet,
      cbind(negative_constraint_row, negative_keep,
            -negative_vector[negative_keep]),
      cbind(negative_constraint_row,
            n_parameters + negative_keep,
            negative_vector[negative_keep])
    )
  }
  triplet <- rbind(
    triplet,
    c(negative_constraint_row, margin_index, -1),
    cbind(bound_row_offset + seq_len(n_parameters),
          seq_len(n_parameters), 1),
    cbind(bound_row_offset + seq_len(n_parameters),
          n_parameters + seq_len(n_parameters), 1)
  )
  storage.mode(triplet) <- "double"
  empty_result$lp_constraints <- as.integer(n_constraints)
  empty_result$lp_nonzeros <- as.double(nrow(triplet))
  if (nrow(triplet) > max_lp_nonzeros) {
    empty_result$evaluated <- FALSE
    empty_result$reason <- "joint_pair_lp_nonzero_limit"
    return(empty_result)
  }

  fit <- tryCatch(
    lpSolve::lp(
      direction = "max",
      objective.in = c(rep(0, 2L * n_parameters), 1),
      const.dir = c(
        rep(">=", n_positive + n_neutral + 1L),
        rep("<=", n_parameters)
      ),
      const.rhs = c(
        rep(0, n_positive + n_neutral + 1L),
        rep(1, n_parameters)
      ),
      dense.const = triplet,
      timeout = as.integer(lp_timeout)
    ),
    error = function(e) e
  )
  if (inherits(fit, "error") ||
      !identical(as.integer(fit$status %||% -1L), 0L)) {
    empty_result$evaluated <- FALSE
    empty_result$solver_status <- if (inherits(fit, "error")) {
      NA_integer_
    } else {
      as.integer(fit$status)
    }
    empty_result$reason <- "joint_pair_linear_program_failed"
    return(empty_result)
  }

  solution <- as.numeric(fit$solution)
  direction <- solution[seq_len(n_parameters)] -
    solution[n_parameters + seq_len(n_parameters)]
  positive_margin <- as.numeric(positive %*% direction)
  neutral_margin <- if (n_neutral > 0L) {
    as.numeric(neutral %*% direction)
  } else {
    numeric(0)
  }
  negative_leading <- -sum(negative_vector * direction)
  margin_capacity <- as.numeric(fit$objval)
  positive_minimum <- min(positive_margin)
  neutral_minimum <- if (length(neutral_margin) > 0L) {
    min(neutral_margin)
  } else {
    NA_real_
  }
  certified <- is.finite(margin_capacity) &&
    margin_capacity > certificate_tolerance &&
    is.finite(positive_minimum) &&
    positive_minimum > certificate_tolerance &&
    (length(neutral_margin) == 0L ||
       (is.finite(neutral_minimum) &&
        neutral_minimum >= -certificate_tolerance)) &&
    is.finite(negative_leading) &&
    negative_leading > certificate_tolerance

  list(
    evaluated = TRUE,
    certified = isTRUE(certified),
    solver_status = as.integer(fit$status),
    margin_capacity = margin_capacity,
    positive_minimum_margin = positive_minimum,
    neutral_minimum_margin = neutral_minimum,
    negative_leading_coefficient = negative_leading,
    direction_l1 = sum(abs(direction)),
    direction = direction,
    lp_constraints = as.integer(n_constraints),
    lp_variables = as.integer(n_variables),
    lp_nonzeros = as.double(nrow(triplet)),
    reason = if (isTRUE(certified)) {
      "certified_joint_pair_asymptotic_tail"
    } else {
      "joint_pair_failed_postsolve_certificate"
    }
  )
}

mfrmr_jml_gpcm_joint_boundary_limit <- function(
    utilities,
    category_direction,
    score_k,
    slope_index,
    slopes,
    weight,
    positive_index,
    negative_index,
    tolerance) {
  n_obs <- nrow(utilities)
  n_categories <- ncol(utilities)
  row_limit <- numeric(n_obs)
  valid <- TRUE
  for (observation in seq_len(n_obs)) {
    if (weight[observation] <= 0) next
    group <- slope_index[observation]
    observed <- score_k[observation] + 1L
    if (group == positive_index) {
      row_limit[observation] <- 0
    } else if (group == negative_index) {
      row_limit[observation] <- -log(n_categories)
    } else {
      maximum <- max(category_direction[observation, ])
      top <- which(
        category_direction[observation, ] >= maximum - tolerance
      )
      if (!observed %in% top) {
        valid <- FALSE
        row_limit[observation] <- NA_real_
        next
      }
      scaled <- slopes[group] * utilities[observation, top]
      scaled_max <- max(scaled)
      denominator <- scaled_max + log(sum(exp(scaled - scaled_max)))
      row_limit[observation] <-
        slopes[group] * utilities[observation, observed] - denominator
    }
  }
  list(
    valid = isTRUE(valid) && all(is.finite(row_limit[weight > 0])),
    row_limit = row_limit,
    log_likelihood = if (isTRUE(valid)) {
      sum(weight * row_limit)
    } else {
      NA_real_
    }
  )
}

audit_mfrm_jml_gpcm_joint_boundary <- function(
    prep,
    idx,
    config,
    sizes,
    par,
    max_observations = 20000L,
    max_contrast_rows = 100000L,
    max_additive_coordinates = 250L,
    max_direction_pairs = 200L,
    max_lp_nonzeros = 2e6,
    lp_timeout = 2L,
    certificate_tolerance = 1e-7,
    likelihood_tolerance = 1e-8) {
  method <- as.character(config$method %||% NA_character_)
  model <- as.character(config$model %||% NA_character_)
  slope_facet <- as.character(config$slope_facet %||% NA_character_)
  empty_pairs <- mfrmr_jml_gpcm_joint_empty_pair_table()
  empty_targets <- mfrmr_jml_gpcm_joint_empty_target_table()
  empty_loadings <- mfrmr_jml_gpcm_joint_empty_loading_table()

  finish <- function(state, complete, scope_complete, detail,
                     target_status = empty_targets,
                     certificates = empty_pairs,
                     direction_loadings = empty_loadings,
                     dimensions = data.frame(),
                     retained_log_likelihood = NA_real_,
                     optimizer_log_likelihood = NA_real_,
                     likelihood_difference = NA_real_) {
    list(
      contract_version = mfrmr_boundary_contract_version(),
      method = method,
      model = model,
      scope = paste(
        "JML GPCM ordered two-slope joint linear-additive and",
        "constant-log-slope asymptotic paths"
      ),
      state = state,
      complete = isTRUE(complete),
      scope_complete = isTRUE(scope_complete),
      structural_identification_complete = FALSE,
      target_status = target_status,
      certificates = certificates,
      direction_loadings = direction_loadings,
      dimensions = dimensions,
      retained_log_likelihood = as.numeric(retained_log_likelihood),
      optimizer_log_likelihood = as.numeric(optimizer_log_likelihood),
      likelihood_difference = as.numeric(likelihood_difference),
      detail = detail,
      limitations = paste(
        "This is a sufficient certificate for ordered pair paths with",
        "linear additive movement and constant expanded log-slope rates",
        "+1 and -1. A positive competitive path is a boundary candidate,",
        "not a proof that no better finite maximum exists in the globally",
        "non-concave GPCM likelihood. A negative result does not establish",
        "finite slopes or nonlinear structural identification. MML requires",
        "a separate marginal-likelihood argument."
      )
    )
  }

  if (!identical(model, "GPCM")) {
    return(finish(
      "not_applicable_model", TRUE, FALSE,
      "The joint nonlinear slope-path audit applies only to GPCM."
    ))
  }
  if (!identical(method, "JML")) {
    return(finish(
      "not_applicable_mml", TRUE, FALSE,
      "The conditional joint JML path is not reused for marginal MML."
    ))
  }
  if (!requireNamespace("lpSolve", quietly = TRUE)) {
    return(finish(
      "not_evaluated_dependency", FALSE, FALSE,
      "Package 'lpSolve' is required for the bounded joint-path audit."
    ))
  }

  levels <- as.character(config$gpcm_spec$levels %||% character(0))
  n_levels <- length(levels)
  n_observations <- length(idx$score_k %||% integer(0))
  n_categories <- as.integer(config$n_cat %||% 0L)
  n_steps <- max(n_categories - 1L, 0L)
  n_pairs <- as.double(n_levels) * as.double(max(n_levels - 1L, 0L))
  controls <- list(
    max_observations, max_contrast_rows, max_additive_coordinates,
    max_direction_pairs, max_lp_nonzeros, lp_timeout,
    certificate_tolerance, likelihood_tolerance
  )
  valid_controls <- all(vapply(controls, function(value) {
    length(value) == 1L && !is.na(value) && is.finite(value) && value >= 0
  }, logical(1)))
  if (!valid_controls) {
    return(finish(
      "not_evaluated_control", FALSE, FALSE,
      "Joint-path execution limits and tolerances must be finite nonnegative scalars."
    ))
  }

  params <- tryCatch(expand_params(par, sizes, config), error = function(e) e)
  if (inherits(params, "error") || n_levels < 1L ||
      length(params$slopes) != n_levels ||
      any(!is.finite(params$slopes)) || any(params$slopes <= 0)) {
    return(finish(
      "not_evaluated_mapping", FALSE, FALSE,
      if (inherits(params, "error")) {
        paste0("Joint GPCM parameter expansion failed: ",
               conditionMessage(params))
      } else {
        "Expanded slope coordinates did not match the declared levels."
      }
    ))
  }
  if (n_levels <= 1L || as.integer(sizes$log_slopes %||% 0L) == 0L) {
    return(finish(
      "no_free_log_slope_coordinates", TRUE, TRUE,
      "The unit-slope GPCM reduction has no joint log-slope pair path.",
      target_status = mfrmr_jml_gpcm_joint_targets(
        levels, slope_facet, reason = "no_free_log_slope_coordinate"
      )
    ))
  }

  adjacent <- tryCatch(
    mfrmr_estimability_adjacent_design(
      prep, idx, config, sizes,
      include_person = TRUE, include_population_beta = FALSE
    ),
    error = function(e) e
  )
  if (inherits(adjacent, "error")) {
    return(finish(
      "not_evaluated_design", FALSE, FALSE,
      paste0("Joint adjacent-design construction failed: ",
             conditionMessage(adjacent))
    ))
  }
  additive_coordinates <- ncol(adjacent$design)
  contrast_rows <- as.double(n_observations) * as.double(n_steps)
  dimensions <- data.frame(
    Observations = as.integer(n_observations),
    EffectiveObservations = NA_integer_,
    Categories = as.integer(n_categories),
    ContrastRows = as.double(contrast_rows),
    AdditiveFreeCoordinates = as.integer(additive_coordinates),
    SlopeLevels = as.integer(n_levels),
    OrderedDirectionPairs = as.double(n_pairs),
    EvaluatedPairs = 0L,
    CertifiedPairs = 0L,
    MaximumLPVariables = 0L,
    MaximumLPConstraints = 0L,
    MaximumLPNonzeros = 0,
    stringsAsFactors = FALSE
  )
  not_evaluated_targets <- mfrmr_jml_gpcm_joint_targets(
    levels, slope_facet,
    evaluation_state = "not_evaluated",
    reason = "joint_pair_path_not_evaluated"
  )
  not_evaluated_targets$CandidateStatus <- "not_evaluated"
  if (n_observations > max_observations ||
      contrast_rows > max_contrast_rows ||
      additive_coordinates > max_additive_coordinates ||
      n_pairs > max_direction_pairs) {
    return(finish(
      "not_evaluated_size_limit", FALSE, FALSE,
      paste0(
        "The joint GPCM path audit exceeded its bounded workload (",
        n_observations, " observations; ", contrast_rows,
        " contrasts; ", additive_coordinates,
        " additive coordinates; ", n_pairs, " ordered slope pairs)."
      ),
      target_status = not_evaluated_targets,
      dimensions = dimensions
    ))
  }
  if (additive_coordinates == 0L) {
    return(finish(
      "no_free_additive_coordinates", TRUE, TRUE,
      "No free additive coordinate was available for a joint path.",
      target_status = mfrmr_jml_gpcm_joint_targets(levels, slope_facet),
      dimensions = dimensions
    ))
  }

  score_k <- suppressWarnings(as.integer(idx$score_k))
  slope_index <- suppressWarnings(as.integer(idx$slope_idx))
  weight <- as.numeric(idx$weight %||% rep(1, n_observations))
  valid_map <- length(score_k) == n_observations &&
    length(slope_index) == n_observations &&
    length(weight) == n_observations &&
    !anyNA(score_k) && !anyNA(slope_index) && !anyNA(weight) &&
    all(score_k >= 0L & score_k < n_categories) &&
    all(slope_index >= 1L & slope_index <= n_levels) &&
    all(is.finite(weight)) && all(weight >= 0)
  if (!valid_map || n_observations < 1L || n_categories < 2L) {
    return(finish(
      "not_evaluated_design", FALSE, FALSE,
      "The retained score, slope-index, weight, or category map was malformed.",
      target_status = not_evaluated_targets,
      dimensions = dimensions
    ))
  }
  dimensions$EffectiveObservations <- sum(weight > 0)
  if (!any(weight > 0)) {
    return(finish(
      "not_evaluated_no_positive_weight", FALSE, FALSE,
      "No retained observation had positive likelihood weight.",
      target_status = not_evaluated_targets,
      dimensions = dimensions
    ))
  }

  contrast <- tryCatch(
    mfrmr_jml_observed_contrast_design(
      adjacent$design, score_k, n_observations, n_steps
    ),
    error = function(e) e
  )
  built <- tryCatch(
    mfrmr_gpcm_response_kernel_design(prep, idx, config, sizes, par),
    error = function(e) e
  )
  if (inherits(contrast, "error") || inherits(built, "error")) {
    failure <- if (inherits(contrast, "error")) contrast else built
    return(finish(
      "not_evaluated_design", FALSE, FALSE,
      paste0("Joint GPCM response construction failed: ",
             conditionMessage(failure)),
      target_status = not_evaluated_targets,
      dimensions = dimensions
    ))
  }
  optimizer_index <- as.integer(adjacent$map$OptimizerIndex)
  if (length(optimizer_index) != additive_coordinates ||
      anyNA(optimizer_index) || anyDuplicated(optimizer_index)) {
    return(finish(
      "not_evaluated_mapping", FALSE, FALSE,
      "The additive optimizer-coordinate map was incomplete or duplicated.",
      target_status = not_evaluated_targets,
      dimensions = dimensions
    ))
  }

  adjacent_base <- matrix(
    as.numeric(built$eta_minus_step),
    nrow = n_observations, ncol = n_steps
  )
  utilities <- matrix(0, nrow = n_observations, ncol = n_categories)
  for (transition in seq_len(n_steps)) {
    utilities[, transition + 1L] <-
      utilities[, transition] + adjacent_base[, transition]
  }
  scaled <- utilities * matrix(
    params$slopes[slope_index],
    nrow = n_observations, ncol = n_categories
  )
  row_max <- apply(scaled, 1L, max)
  log_denominator <- row_max + log(rowSums(exp(
    scaled - matrix(row_max, nrow = n_observations,
                    ncol = n_categories)
  )))
  observed_scaled <- scaled[cbind(seq_len(n_observations), score_k + 1L)]
  retained_log_likelihood <- sum(weight * (observed_scaled - log_denominator))
  optimizer_log_likelihood <- tryCatch(
    -mfrm_loglik_jml(par, idx, config, sizes),
    error = function(e) NA_real_
  )
  likelihood_difference <- retained_log_likelihood - optimizer_log_likelihood
  likelihood_scale <- max(
    1, abs(retained_log_likelihood), abs(optimizer_log_likelihood)
  )
  if (!is.finite(retained_log_likelihood) ||
      !is.finite(optimizer_log_likelihood) ||
      !is.finite(likelihood_difference) ||
      abs(likelihood_difference) > likelihood_tolerance * likelihood_scale) {
    return(finish(
      "not_evaluated_likelihood_mismatch", FALSE, FALSE,
      "The reconstructed retained likelihood did not match the optimizer objective.",
      target_status = not_evaluated_targets,
      dimensions = dimensions,
      retained_log_likelihood = retained_log_likelihood,
      optimizer_log_likelihood = optimizer_log_likelihood,
      likelihood_difference = likelihood_difference
    ))
  }

  contrast_observation <- rep(seq_len(n_observations), each = n_steps)
  pair_grid <- expand.grid(
    PositiveIndex = seq_len(n_levels),
    NegativeIndex = seq_len(n_levels),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  pair_grid <- pair_grid[
    pair_grid$PositiveIndex != pair_grid$NegativeIndex, , drop = FALSE
  ]
  pair_rows <- vector("list", nrow(pair_grid))
  pair_directions <- vector("list", nrow(pair_grid))
  for (pair_position in seq_len(nrow(pair_grid))) {
    positive_index <- pair_grid$PositiveIndex[pair_position]
    negative_index <- pair_grid$NegativeIndex[pair_position]
    solved <- mfrmr_jml_gpcm_joint_pair_lp(
      contrast = contrast,
      contrast_observation = contrast_observation,
      slope_index = slope_index,
      weight = weight,
      n_categories = n_categories,
      positive_index = positive_index,
      negative_index = negative_index,
      max_lp_nonzeros = max_lp_nonzeros,
      lp_timeout = lp_timeout,
      certificate_tolerance = certificate_tolerance
    )
    dimensions$MaximumLPVariables <- max(
      dimensions$MaximumLPVariables, solved$lp_variables
    )
    dimensions$MaximumLPConstraints <- max(
      dimensions$MaximumLPConstraints, solved$lp_constraints
    )
    dimensions$MaximumLPNonzeros <- max(
      dimensions$MaximumLPNonzeros, solved$lp_nonzeros
    )
    boundary <- list(valid = FALSE, log_likelihood = NA_real_)
    if (isTRUE(solved$certified)) {
      adjacent_direction <- matrix(
        as.numeric(adjacent$design %*% solved$direction),
        nrow = n_observations, ncol = n_steps
      )
      category_direction <- matrix(
        0, nrow = n_observations, ncol = n_categories
      )
      for (transition in seq_len(n_steps)) {
        category_direction[, transition + 1L] <-
          category_direction[, transition] +
          adjacent_direction[, transition]
      }
      boundary <- mfrmr_jml_gpcm_joint_boundary_limit(
        utilities = utilities,
        category_direction = category_direction,
        score_k = score_k,
        slope_index = slope_index,
        slopes = params$slopes,
        weight = weight,
        positive_index = positive_index,
        negative_index = negative_index,
        tolerance = certificate_tolerance
      )
    }
    improvement <- boundary$log_likelihood - retained_log_likelihood
    competitive <- isTRUE(boundary$valid) && is.finite(improvement) &&
      improvement >= -likelihood_tolerance * likelihood_scale
    certified <- isTRUE(solved$certified) && isTRUE(competitive)
    reason <- if (isTRUE(certified)) {
      "certified_competitive_joint_nonlinear_boundary_candidate"
    } else if (isTRUE(solved$certified)) {
      "joint_tail_boundary_not_competitive_with_retained_fit"
    } else {
      solved$reason
    }
    pair_rows[[pair_position]] <- data.frame(
      PairId = sprintf("JP%05d", pair_position),
      PositiveLevel = levels[positive_index],
      NegativeLevel = levels[negative_index],
      PositiveIndex = as.integer(positive_index),
      NegativeIndex = as.integer(negative_index),
      SolverStatus = as.integer(solved$solver_status),
      MarginCapacity = as.numeric(solved$margin_capacity),
      PositiveMinimumMargin = as.numeric(solved$positive_minimum_margin),
      NeutralMinimumMargin = as.numeric(solved$neutral_minimum_margin),
      NegativeLeadingCoefficient =
        as.numeric(solved$negative_leading_coefficient),
      AdditiveDirectionL1 = as.numeric(solved$direction_l1),
      CurrentLogLikelihood = retained_log_likelihood,
      BoundaryLogLikelihood = as.numeric(boundary$log_likelihood),
      BoundaryImprovement = as.numeric(improvement),
      AnalyticTailCertified = isTRUE(solved$certified),
      CompetitiveBoundary = isTRUE(competitive),
      Certified = isTRUE(certified),
      EvaluationState = if (isTRUE(solved$evaluated)) {
        "evaluated"
      } else {
        "not_evaluated"
      },
      ReasonCodes = reason,
      stringsAsFactors = FALSE
    )
    pair_directions[[pair_position]] <- solved$direction
  }
  certificates <- do.call(rbind, pair_rows)
  evaluated <- certificates$EvaluationState == "evaluated"
  certified_rows <- which(certificates$Certified)
  dimensions$EvaluatedPairs <- sum(evaluated)
  dimensions$CertifiedPairs <- length(certified_rows)
  if (any(!evaluated)) {
    return(finish(
      "not_evaluated_pair_solver", FALSE, FALSE,
      "At least one ordered joint GPCM pair path was not evaluated.",
      target_status = not_evaluated_targets,
      certificates = certificates,
      dimensions = dimensions,
      retained_log_likelihood = retained_log_likelihood,
      optimizer_log_likelihood = optimizer_log_likelihood,
      likelihood_difference = likelihood_difference
    ))
  }

  positive <- seq_len(n_levels) %in%
    certificates$PositiveIndex[certified_rows]
  negative <- seq_len(n_levels) %in%
    certificates$NegativeIndex[certified_rows]
  targets <- mfrmr_jml_gpcm_joint_targets(
    levels, slope_facet, positive = positive, negative = negative
  )

  slices <- build_param_slices(sizes)
  optimizer_log_slope_index <- as.integer(slices$log_slopes %||% integer(0))
  loading_rows <- list()
  loading_cursor <- 0L
  for (certificate_row in certified_rows) {
    pair <- certificates[certificate_row, , drop = FALSE]
    direction <- pair_directions[[certificate_row]]
    additive_keep <- which(abs(direction) > certificate_tolerance)
    if (length(additive_keep) > 0L) {
      loading_cursor <- loading_cursor + 1L
      loading_rows[[loading_cursor]] <- data.frame(
        PairId = pair$PairId,
        CoordinateType = "optimizer_additive",
        OptimizerIndex = optimizer_index[additive_keep],
        Coordinate = as.character(adjacent$map$Coordinate[additive_keep]),
        Level = as.character(adjacent$map$Level[additive_keep]),
        Loading = direction[additive_keep],
        stringsAsFactors = FALSE
      )
    }
    expanded_direction <- rep(0, n_levels)
    expanded_direction[pair$PositiveIndex] <- 1
    expanded_direction[pair$NegativeIndex] <- -1
    expanded_keep <- which(expanded_direction != 0)
    loading_cursor <- loading_cursor + 1L
    loading_rows[[loading_cursor]] <- data.frame(
      PairId = pair$PairId,
      CoordinateType = "expanded_log_slope",
      OptimizerIndex = rep(NA_integer_, length(expanded_keep)),
      Coordinate = paste0("expanded_log_slope:", levels[expanded_keep]),
      Level = levels[expanded_keep],
      Loading = expanded_direction[expanded_keep],
      stringsAsFactors = FALSE
    )
    free_direction <- expanded_direction[seq_len(n_levels - 1L)]
    free_keep <- which(free_direction != 0)
    if (length(free_keep) > 0L) {
      loading_cursor <- loading_cursor + 1L
      loading_rows[[loading_cursor]] <- data.frame(
        PairId = pair$PairId,
        CoordinateType = "optimizer_log_slope",
        OptimizerIndex = optimizer_log_slope_index[free_keep],
        Coordinate = paste0("log_slopes:", levels[free_keep]),
        Level = levels[free_keep],
        Loading = free_direction[free_keep],
        stringsAsFactors = FALSE
      )
    }
  }
  direction_loadings <- if (length(loading_rows) > 0L) {
    do.call(rbind, loading_rows)
  } else {
    empty_loadings
  }

  finish(
    state = if (length(certified_rows) > 0L) {
      "certified_competitive_joint_boundary_path"
    } else {
      "none_certified"
    },
    complete = TRUE,
    scope_complete = TRUE,
    detail = if (length(certified_rows) > 0L) {
      paste0(
        "Certified ", length(certified_rows), " of ", nrow(certificates),
        " ordered slope pairs as competitive joint nonlinear asymptotic",
        " boundary candidates."
      )
    } else {
      paste0(
        "No competitive path was certified among ", nrow(certificates),
        " ordered joint additive/log-slope pairs."
      )
    },
    target_status = targets,
    certificates = certificates,
    direction_loadings = direction_loadings,
    dimensions = dimensions,
    retained_log_likelihood = retained_log_likelihood,
    optimizer_log_likelihood = optimizer_log_likelihood,
    likelihood_difference = likelihood_difference
  )
}
