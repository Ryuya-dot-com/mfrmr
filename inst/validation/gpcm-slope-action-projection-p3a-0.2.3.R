# Repository-only population projection for two many-facet GPCM slope actions.
#
# `complete_predictor` is the implemented mfrmr kernel
#   alpha_c * (theta - severity_r - boundary_ck).
# `loading_only` is the comparison kernel
#   alpha_c * theta - severity_r - boundary_ck.
#
# The audit holds the standard-normal trait distribution and a balanced fully
# crossed Criterion-by-Rater design fixed.  It studies model identity, not
# finite-sample estimator performance or release readiness.

mfrmr_gsap_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsap_actions <- function() {
  c("complete_predictor", "loading_only")
}

mfrmr_gsap_geometric_mean <- function(x) {
  exp(mean(log(as.numeric(x))))
}

mfrmr_gsap_sum_zero_expand <- function(free, total) {
  total <- as.integer(total)[1L]
  free <- as.numeric(free)
  mfrmr_gsap_assert(
    total >= 1L && length(free) == total - 1L && all(is.finite(free)),
    "A sum-zero block requires exactly `total - 1` finite coordinates."
  )
  c(free, -sum(free))
}

mfrmr_gsap_parameters <- function(slopes, severities, boundaries) {
  slopes <- as.numeric(slopes)
  severities <- as.numeric(severities)
  boundaries <- as.matrix(boundaries)
  storage.mode(boundaries) <- "double"
  mfrmr_gsap_assert(
    length(slopes) >= 2L && all(is.finite(slopes)) && all(slopes > 0),
    "`slopes` must contain at least two finite positive values."
  )
  mfrmr_gsap_assert(
    length(severities) >= 2L && all(is.finite(severities)),
    "`severities` must contain at least two finite values."
  )
  mfrmr_gsap_assert(
    nrow(boundaries) == length(slopes) && ncol(boundaries) >= 1L &&
      all(is.finite(boundaries)),
    "`boundaries` must have one finite row per Criterion slope."
  )
  mfrmr_gsap_assert(
    abs(log(mfrmr_gsap_geometric_mean(slopes))) < 1e-10,
    "Criterion slopes must have geometric mean one."
  )
  mfrmr_gsap_assert(
    abs(sum(severities)) < 1e-10,
    "Rater severities must sum to zero."
  )
  list(
    slopes = slopes,
    severities = severities,
    boundaries = boundaries
  )
}

mfrmr_gsap_pack <- function(parameters) {
  parameters <- mfrmr_gsap_parameters(
    parameters$slopes,
    parameters$severities,
    parameters$boundaries
  )
  c(
    log(parameters$slopes)[-length(parameters$slopes)],
    parameters$severities[-length(parameters$severities)],
    as.numeric(t(parameters$boundaries))
  )
}

mfrmr_gsap_unpack <- function(vector, criterion_count, rater_count,
                              transition_count) {
  criterion_count <- as.integer(criterion_count)[1L]
  rater_count <- as.integer(rater_count)[1L]
  transition_count <- as.integer(transition_count)[1L]
  expected <- criterion_count - 1L + rater_count - 1L +
    criterion_count * transition_count
  vector <- as.numeric(vector)
  mfrmr_gsap_assert(
    length(vector) == expected && all(is.finite(vector)),
    "The projection parameter vector has the wrong length or non-finite values."
  )
  slope_end <- criterion_count - 1L
  rater_end <- slope_end + rater_count - 1L
  log_slopes <- mfrmr_gsap_sum_zero_expand(
    vector[seq_len(slope_end)], criterion_count
  )
  severities <- mfrmr_gsap_sum_zero_expand(
    vector[seq.int(slope_end + 1L, rater_end)], rater_count
  )
  boundaries <- matrix(
    vector[seq.int(rater_end + 1L, expected)],
    nrow = criterion_count,
    ncol = transition_count,
    byrow = TRUE
  )
  mfrmr_gsap_parameters(exp(log_slopes), severities, boundaries)
}

mfrmr_gsap_design <- function(theta) {
  theta <- as.numeric(theta)
  mfrmr_gsap_assert(
    length(theta) >= 1L && all(is.finite(theta)),
    "`theta` must contain finite quadrature coordinates."
  )
  expand.grid(
    ThetaIndex = seq_along(theta),
    RaterIndex = seq_len(4L),
    CriterionIndex = seq_len(4L),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsap_adjacent_logits <- function(theta, parameters,
                                       action = mfrmr_gsap_actions()) {
  action <- match.arg(action)
  parameters <- mfrmr_gsap_parameters(
    parameters$slopes,
    parameters$severities,
    parameters$boundaries
  )
  design <- mfrmr_gsap_design(theta)
  mfrmr_gsap_assert(
    length(parameters$slopes) == 4L &&
      length(parameters$severities) == 4L,
    "The fixed projection design requires four Criteria and four Raters."
  )
  theta_row <- theta[design$ThetaIndex]
  slope_row <- parameters$slopes[design$CriterionIndex]
  severity_row <- parameters$severities[design$RaterIndex]
  boundary_row <- parameters$boundaries[
    design$CriterionIndex, , drop = FALSE
  ]
  if (identical(action, "complete_predictor")) {
    slope_row * (
      matrix(theta_row - severity_row, nrow = nrow(design),
             ncol = ncol(boundary_row)) - boundary_row
    )
  } else {
    matrix(slope_row * theta_row - severity_row, nrow = nrow(design),
           ncol = ncol(boundary_row)) - boundary_row
  }
}

mfrmr_gsap_probabilities <- function(theta, parameters,
                                     action = mfrmr_gsap_actions()) {
  adjacent <- mfrmr_gsap_adjacent_logits(theta, parameters, action)
  log_kernel <- cbind(0, t(apply(adjacent, 1L, cumsum)))
  row_max <- apply(log_kernel, 1L, max)
  unnormalized <- exp(log_kernel - row_max)
  unnormalized / rowSums(unnormalized)
}

mfrmr_gsap_cross_difference <- function(parameters,
                                        action = mfrmr_gsap_actions(),
                                        criterion = c(1L, 4L),
                                        rater = c(1L, 4L),
                                        transition = 2L) {
  action <- match.arg(action)
  criterion <- as.integer(criterion)
  rater <- as.integer(rater)
  transition <- as.integer(transition)[1L]
  mfrmr_gsap_assert(
    length(criterion) == 2L && length(rater) == 2L,
    "The cross-difference requires two Criteria and two Raters."
  )
  logits <- mfrmr_gsap_adjacent_logits(
    theta = 0,
    parameters = parameters,
    action = action
  )
  design <- mfrmr_gsap_design(0)
  value <- function(rater_index, criterion_index) {
    row <- which(
      design$RaterIndex == rater_index &
        design$CriterionIndex == criterion_index
    )
    logits[row, transition]
  }
  (value(rater[1L], criterion[1L]) -
     value(rater[2L], criterion[1L])) -
    (value(rater[1L], criterion[2L]) -
       value(rater[2L], criterion[2L]))
}

mfrmr_gsap_hermite_normal <- function(points = 31L) {
  points <- as.integer(points)[1L]
  mfrmr_gsap_assert(points >= 3L, "Use at least three quadrature points.")
  index <- seq_len(points - 1L)
  jacobi <- matrix(0, points, points)
  off_diagonal <- sqrt(index / 2)
  jacobi[cbind(index, index + 1L)] <- off_diagonal
  jacobi[cbind(index + 1L, index)] <- off_diagonal
  decomposition <- eigen(jacobi, symmetric = TRUE)
  order <- order(decomposition$values)
  nodes <- sqrt(2) * decomposition$values[order]
  weights <- decomposition$vectors[1L, order]^2
  list(nodes = nodes, weights = weights / sum(weights))
}

mfrmr_gsap_row_weights <- function(theta_weights, rater_count = 4L,
                                   criterion_count = 4L) {
  theta_weights <- as.numeric(theta_weights)
  rep(theta_weights, times = rater_count * criterion_count) /
    (rater_count * criterion_count)
}

mfrmr_gsap_kl <- function(reference, candidate, row_weights) {
  reference <- as.matrix(reference)
  candidate <- as.matrix(candidate)
  row_weights <- as.numeric(row_weights)
  mfrmr_gsap_assert(
    identical(dim(reference), dim(candidate)) &&
      nrow(reference) == length(row_weights) &&
      all(reference > 0) && all(candidate > 0),
    "KL inputs must be aligned strictly positive probability matrices."
  )
  sum(row_weights * rowSums(reference * (log(reference) - log(candidate))))
}

mfrmr_gsap_projection_start <- function(parameters, truth_action,
                                        candidate_action) {
  truth_action <- match.arg(truth_action, mfrmr_gsap_actions())
  candidate_action <- match.arg(candidate_action, mfrmr_gsap_actions())
  if (identical(truth_action, candidate_action)) return(parameters)
  slopes <- parameters$slopes
  if (identical(truth_action, "loading_only")) {
    severity_multiplier <- sum(slopes) / sum(slopes^2)
    mfrmr_gsap_parameters(
      slopes = slopes,
      severities = parameters$severities * severity_multiplier,
      boundaries = parameters$boundaries / slopes
    )
  } else {
    mfrmr_gsap_parameters(
      slopes = slopes,
      severities = parameters$severities * mean(slopes),
      boundaries = parameters$boundaries * slopes
    )
  }
}

mfrmr_gsap_project <- function(parameters, truth_action, candidate_action,
                               points = 31L) {
  truth_action <- match.arg(truth_action, mfrmr_gsap_actions())
  candidate_action <- match.arg(candidate_action, mfrmr_gsap_actions())
  quadrature <- mfrmr_gsap_hermite_normal(points)
  row_weights <- mfrmr_gsap_row_weights(quadrature$weights)
  truth <- mfrmr_gsap_probabilities(
    quadrature$nodes, parameters, truth_action
  )
  start_parameters <- mfrmr_gsap_projection_start(
    parameters, truth_action, candidate_action
  )
  start <- mfrmr_gsap_pack(start_parameters)
  objective <- function(vector) {
    candidate_parameters <- mfrmr_gsap_unpack(
      vector,
      criterion_count = length(parameters$slopes),
      rater_count = length(parameters$severities),
      transition_count = ncol(parameters$boundaries)
    )
    candidate <- mfrmr_gsap_probabilities(
      quadrature$nodes, candidate_parameters, candidate_action
    )
    mfrmr_gsap_kl(truth, candidate, row_weights)
  }
  start_kl <- objective(start)
  optimization <- stats::optim(
    par = start,
    fn = objective,
    method = "BFGS",
    control = list(maxit = 1000L, reltol = 1e-12)
  )
  fitted_parameters <- mfrmr_gsap_unpack(
    optimization$par,
    criterion_count = length(parameters$slopes),
    rater_count = length(parameters$severities),
    transition_count = ncol(parameters$boundaries)
  )
  evaluation_theta <- seq(-4, 4, length.out = 161L)
  truth_evaluation <- mfrmr_gsap_probabilities(
    evaluation_theta, parameters, truth_action
  )
  fitted_evaluation <- mfrmr_gsap_probabilities(
    evaluation_theta, fitted_parameters, candidate_action
  )
  list(
    truth_action = truth_action,
    candidate_action = candidate_action,
    start_kl = start_kl,
    projected_kl = objective(optimization$par),
    max_probability_difference = max(abs(
      truth_evaluation - fitted_evaluation
    )),
    convergence = as.integer(optimization$convergence),
    evaluations = as.integer(optimization$counts[["function"]]),
    fitted_parameters = fitted_parameters
  )
}

mfrmr_gsap_scenarios <- function() {
  base_boundaries <- outer(
    c(-0.35, -0.10, 0.15, 0.30),
    c(-0.85, 0, 0.85),
    "+"
  )
  heterogeneous_slopes <- exp(c(-0.45, -0.15, 0.15, 0.45))
  moderate_slopes <- exp(c(-0.30, -0.10, 0.10, 0.30))
  list(
    unit_slopes = list(
      parameters = mfrmr_gsap_parameters(
        rep(1, 4L), c(-0.60, -0.20, 0.20, 0.60), base_boundaries
      ),
      exact_equivalence_expected = TRUE,
      reason = "unit_slopes"
    ),
    zero_rater_contrast = list(
      parameters = mfrmr_gsap_parameters(
        heterogeneous_slopes, rep(0, 4L), base_boundaries
      ),
      exact_equivalence_expected = TRUE,
      reason = "nonowner_effect_zero"
    ),
    moderate_crossed = list(
      parameters = mfrmr_gsap_parameters(
        moderate_slopes, c(-0.45, -0.15, 0.15, 0.45), base_boundaries
      ),
      exact_equivalence_expected = FALSE,
      reason = "heterogeneous_slopes_and_crossed_rater_contrasts"
    ),
    strong_crossed = list(
      parameters = mfrmr_gsap_parameters(
        heterogeneous_slopes, c(-0.80, -0.25, 0.25, 0.80), base_boundaries
      ),
      exact_equivalence_expected = FALSE,
      reason = "stronger_heterogeneity_and_crossed_rater_contrasts"
    )
  )
}

mfrmr_run_gpcm_slope_action_projection <- function() {
  scenarios <- mfrmr_gsap_scenarios()
  projection_rows <- list()
  invariant_rows <- list()
  row_index <- 0L
  for (scenario_name in names(scenarios)) {
    scenario <- scenarios[[scenario_name]]
    parameters <- scenario$parameters
    complete_invariant <- mfrmr_gsap_cross_difference(
      parameters, "complete_predictor"
    )
    expected_complete <- -(
      parameters$slopes[1L] - parameters$slopes[4L]
    ) * (
      parameters$severities[1L] - parameters$severities[4L]
    )
    invariant_rows[[length(invariant_rows) + 1L]] <- data.frame(
      Scenario = scenario_name,
      LoadingOnlyCrossDifference = mfrmr_gsap_cross_difference(
        parameters, "loading_only"
      ),
      CompletePredictorCrossDifference = complete_invariant,
      ExpectedCompleteCrossDifference = expected_complete,
      ExactEquivalenceExpected = scenario$exact_equivalence_expected,
      Reason = scenario$reason,
      stringsAsFactors = FALSE
    )
    for (points in c(31L, 41L)) {
      for (truth_action in mfrmr_gsap_actions()) {
        candidate_action <- setdiff(mfrmr_gsap_actions(), truth_action)
        projection <- mfrmr_gsap_project(
          parameters,
          truth_action = truth_action,
          candidate_action = candidate_action,
          points = points
        )
        row_index <- row_index + 1L
        projection_rows[[row_index]] <- data.frame(
          Scenario = scenario_name,
          Nodes = points,
          TruthAction = projection$truth_action,
          CandidateAction = projection$candidate_action,
          ExactEquivalenceExpected = scenario$exact_equivalence_expected,
          StartKLPerResponse = projection$start_kl,
          ProjectedKLPerResponse = projection$projected_kl,
          MaxProbabilityDifference = projection$max_probability_difference,
          OptimizerConvergence = projection$convergence,
          FunctionEvaluations = projection$evaluations,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  projections <- do.call(rbind, projection_rows)
  invariants <- do.call(rbind, invariant_rows)
  rownames(projections) <- NULL
  rownames(invariants) <- NULL
  q31 <- projections[projections$Nodes == 31L, , drop = FALSE]
  q41 <- projections[projections$Nodes == 41L, , drop = FALSE]
  key <- function(table) {
    paste(table$Scenario, table$TruthAction, table$CandidateAction, sep = "::")
  }
  q41 <- q41[match(key(q31), key(q41)), , drop = FALSE]
  stability <- data.frame(
    Scenario = q31$Scenario,
    TruthAction = q31$TruthAction,
    CandidateAction = q31$CandidateAction,
    ProjectedKLAbsQ41MinusQ31 = abs(
      q41$ProjectedKLPerResponse - q31$ProjectedKLPerResponse
    ),
    MaxProbabilityDifferenceAbsQ41MinusQ31 = abs(
      q41$MaxProbabilityDifference - q31$MaxProbabilityDifference
    ),
    stringsAsFactors = FALSE
  )
  list(
    status = "gpcm_slope_action_population_projection_complete",
    audit_scope = "balanced_crossed_population_kl_projection",
    estimator_scope = "fixed_standard_normal_population_oracle_not_jml_or_mml_sampling",
    projections = projections,
    invariants = invariants,
    stability = stability,
    implemented_family_changed = FALSE,
    loading_only_public_family_added = FALSE,
    readiness_overridden = FALSE,
    scientific_threshold_frozen = FALSE,
    release_authorized = FALSE
  )
}
