# mfrmr 0.2.3 GPCM category-reflection transport P1n audit
#
# P1n transports the four P1m local mechanism representatives from exact-high
# and near-high fixtures to their exact-low and near-low score reflections.
# It verifies the algebraic coordinate involution, mirrored quadrature,
# likelihood, posterior, and gradient identities without refitting. It does
# not promote representative transport to a continuous global profile or to
# completion of every coefficient-ratio face.

mfrmr_gcrt_p1n_specification <- "0.2.3-draft.1"
mfrmr_gcrt_p1n_contract <-
  "mfrmr_gpcm_category_reflection_transport_p1n_v1"
mfrmr_gcrt_p1n_dependency_contract <-
  "mfrmr_gpcm_profile_turning_point_p1m_v1"
mfrmr_gcrt_p1n_dependency_sha256 <-
  "7056ea9d3e51aac91103aef570557a60dac018f989adaff4d6061d1425a1449c"
mfrmr_gcrt_p1n_pairs <- data.frame(
  PairId = c("exact", "near"),
  HighScenarioId = c("EXT5-P-HI", "EXT5-P-NEAR-HI"),
  LowScenarioId = c("EXT5-P-LO", "EXT5-P-NEAR-LO"),
  stringsAsFactors = FALSE
)
mfrmr_gcrt_p1n_objective_tolerance <- 1e-9
mfrmr_gcrt_p1n_probability_tolerance <- 1e-9
mfrmr_gcrt_p1n_gradient_tolerance <- 1e-9
mfrmr_gcrt_p1n_coordinate_tolerance <- 1e-12
mfrmr_gcrt_p1n_quadrature_tolerance <- 1e-12
mfrmr_gcrt_p1n_numeric_gradient_step <- 1e-5
mfrmr_gcrt_p1n_numeric_gradient_tolerance <- 2e-5
mfrmr_gcrt_p1n_numeric_gradient_point_ids <-
  c("refined_turning_point", "monotone_grid_5")

mfrmr_gcrt_p1n_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gcrt_p1n_require_sources <- function() {
  target <- environment(mfrmr_gcrt_p1n_require_sources)
  required <- c(
    "mfrmr_gpt_p1m_contract", "mfrmr_gorb_p1j_bundle",
    "mfrmr_gorb_p1j_contexts", "mfrmr_gc4_p1g_layout",
    "mfrmr_gss_get", "mfrmr_num_central_gradient"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )
  mfrmr_gcrt_p1n_assert(
    all(available) && identical(
      get("mfrmr_gpt_p1m_contract", envir = target, inherits = TRUE),
      mfrmr_gcrt_p1n_dependency_contract
    ),
    "Source P0 through P1m before P1n."
  )
  invisible(TRUE)
}

mfrmr_gcrt_p1n_validate_result <- function(p1m) {
  mfrmr_gcrt_p1n_assert(
    is.list(p1m) && identical(
      p1m$contract, mfrmr_gcrt_p1n_dependency_contract
    ) && is.data.frame(p1m$representatives) &&
      nrow(p1m$representatives) == 4L && is.list(p1m$trace) &&
      is.list(p1m$objects) &&
      isTRUE(p1m$AllRepresentativeLocalMechanismsSupported),
    "P1n requires one complete locally supported P1m result."
  )
  invisible(TRUE)
}

mfrmr_gcrt_p1n_low_scenario <- function(high_scenario_id) {
  row <- mfrmr_gcrt_p1n_pairs[
    mfrmr_gcrt_p1n_pairs$HighScenarioId == high_scenario_id,
    , drop = FALSE
  ]
  mfrmr_gcrt_p1n_assert(
    nrow(row) == 1L,
    paste0("P1n has no frozen reflection pair for ", high_scenario_id, ".")
  )
  as.character(row$LowScenarioId)
}

mfrmr_gcrt_p1n_reflect_step_free <- function(step_free, n_threshold) {
  step_free <- as.matrix(step_free)
  n_threshold <- as.integer(n_threshold)[1L]
  mfrmr_gcrt_p1n_assert(
    ncol(step_free) == n_threshold - 1L && n_threshold >= 2L &&
      all(is.finite(step_free)),
    "P1n step reflection requires finite identified step coordinates."
  )
  full <- t(vapply(seq_len(nrow(step_free)), function(index) {
    mfrmr_gss_get("expand_sum_zero_vector")(
      step_free[index, ], n_threshold
    )
  }, numeric(n_threshold)))
  reflected_full <- -full[, n_threshold:1L, drop = FALSE]
  mfrmr_gcrt_p1n_assert(
    max(abs(rowSums(reflected_full))) <=
      mfrmr_gcrt_p1n_coordinate_tolerance,
    "P1n step reflection did not preserve the sum-zero constraint."
  )
  reflected_full[, seq_len(n_threshold - 1L), drop = FALSE]
}

mfrmr_gcrt_p1n_reflect_x <- function(x, context) {
  layout <- mfrmr_gc4_p1g_layout(context)
  x <- as.numeric(x)
  mfrmr_gcrt_p1n_assert(
    length(x) == layout$dimension && all(is.finite(x)),
    "P1n reflection requires one finite ordered-ratio nuisance vector."
  )
  reflected <- x
  reflected[layout$rater] <- -x[layout$rater]
  reflected[layout$location] <- -x[layout$location]
  step_free <- matrix(
    x[layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  reflected_steps <- mfrmr_gcrt_p1n_reflect_step_free(
    step_free, context$config$n_cat - 1L
  )
  reflected[layout$steps] <- as.numeric(t(reflected_steps))
  reflected
}

mfrmr_gcrt_p1n_reflection_matrix <- function(context) {
  dimension <- mfrmr_gc4_p1g_layout(context)$dimension
  matrix <- vapply(seq_len(dimension), function(index) {
    basis <- numeric(dimension)
    basis[index] <- 1
    mfrmr_gcrt_p1n_reflect_x(basis, context)
  }, numeric(dimension))
  mfrmr_gcrt_p1n_assert(
    identical(dim(matrix), c(dimension, dimension)),
    "P1n could not construct the free-coordinate reflection matrix."
  )
  matrix
}

mfrmr_gcrt_p1n_kernel <- function(eta, steps) {
  eta <- as.numeric(eta)[1L]
  steps <- as.numeric(steps)
  cumulative <- c(0, cumsum(steps))
  log_numerator <- (0:length(steps)) * eta - cumulative
  maximum <- max(log_numerator)
  numerator <- exp(log_numerator - maximum)
  numerator / sum(numerator)
}

mfrmr_gcrt_p1n_kernel_identity <- function(eta, steps) {
  original <- mfrmr_gcrt_p1n_kernel(eta, steps)
  reflected <- mfrmr_gcrt_p1n_kernel(-eta, -rev(steps))
  max(abs(original - rev(reflected)))
}

mfrmr_gcrt_p1n_context_audit <- function(high, low, pair_id, q) {
  n_category <- as.integer(high$config$n_cat)[1L]
  high_weight <- high$idx$weight
  low_weight <- low$idx$weight
  weight_identity <- if (is.null(high_weight) && is.null(low_weight)) {
    TRUE
  } else if (!is.null(high_weight) && !is.null(low_weight) &&
      length(high_weight) == length(low_weight)) {
    max(abs(high_weight - low_weight)) <=
      mfrmr_gcrt_p1n_coordinate_tolerance
  } else {
    FALSE
  }
  index_identity <- identical(high$idx$person, low$idx$person) &&
    identical(high$idx$slope_idx, low$idx$slope_idx) &&
    identical(high$idx$facets, low$idx$facets)
  score_reflection <- length(high$idx$score_k) == length(low$idx$score_k) &&
    all(high$idx$score_k + low$idx$score_k == n_category - 1L)
  node_difference <- if (
    length(high$quad$nodes) == length(low$quad$nodes)
  ) max(abs(high$quad$nodes + rev(low$quad$nodes))) else Inf
  quadrature_weight_difference <- if (
    length(high$quad$weights) == length(low$quad$weights)
  ) max(abs(high$quad$weights - rev(low$quad$weights))) else Inf
  pass <- identical(high$config$n_cat, low$config$n_cat) &&
    identical(high$config$facet_levels, low$config$facet_levels) &&
    index_identity && score_reflection && weight_identity &&
    node_difference <= mfrmr_gcrt_p1n_quadrature_tolerance &&
    quadrature_weight_difference <= mfrmr_gcrt_p1n_quadrature_tolerance
  data.frame(
    PairId = pair_id,
    QuadPoints = as.integer(q),
    CategoryCount = n_category,
    StructuralIndexIdentity = index_identity,
    ExactScoreReflection = score_reflection,
    ObservationWeightIdentity = weight_identity,
    MirroredNodeMaxAbsDifference = node_difference,
    MirroredWeightMaxAbsDifference = quadrature_weight_difference,
    ContextReflectionIdentityVerified = pass,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gcrt_p1n_contexts <- function(p1m) {
  p1i <- p1m$objective_p1l$p1k$p1j$p1i
  rows <- list()
  contexts <- list()
  index <- 1L
  for (pair_index in seq_len(nrow(mfrmr_gcrt_p1n_pairs))) {
    pair <- mfrmr_gcrt_p1n_pairs[pair_index, , drop = FALSE]
    high <- mfrmr_gorb_p1j_contexts(p1i, pair$HighScenarioId)
    low <- mfrmr_gorb_p1j_contexts(p1i, pair$LowScenarioId)
    mfrmr_gcrt_p1n_assert(
      identical(names(high), names(low)),
      "P1n high/low quadrature schedules differ."
    )
    for (name in names(high)) {
      rows[[index]] <- mfrmr_gcrt_p1n_context_audit(
        high[[name]], low[[name]], pair$PairId, as.integer(name)
      )
      index <- index + 1L
    }
    contexts[[pair$PairId]] <- list(high = high, low = low)
  }
  audit <- do.call(rbind, rows)
  rownames(audit) <- NULL
  mfrmr_gcrt_p1n_assert(
    all(audit$ContextReflectionIdentityVerified),
    "P1n fixture or quadrature reflection contract failed."
  )
  list(audit = audit, contexts = contexts)
}

mfrmr_gcrt_p1n_point <- function(
    representative,
    point,
    point_object,
    contexts,
    transformation) {
  pair_id <- mfrmr_gcrt_p1n_pairs$PairId[
    mfrmr_gcrt_p1n_pairs$HighScenarioId == representative$ScenarioId
  ]
  low_scenario <- mfrmr_gcrt_p1n_low_scenario(representative$ScenarioId)
  x <- as.numeric(point_object$value)
  reflected_x <- mfrmr_gcrt_p1n_reflect_x(x, contexts$high[["121"]])
  recovered_x <- mfrmr_gcrt_p1n_reflect_x(
    reflected_x, contexts$low[["121"]]
  )
  values <- lapply(names(contexts$high), function(q_name) {
    high <- mfrmr_gorb_p1j_bundle(
      x, representative$Mu, point$Rho, contexts$high[[q_name]],
      representative$FastIndex, representative$SlowIndex,
      include_gradient = TRUE
    )
    low <- mfrmr_gorb_p1j_bundle(
      reflected_x, representative$Mu, point$Rho,
      contexts$low[[q_name]], representative$FastIndex,
      representative$SlowIndex, include_gradient = TRUE
    )
    reverse_node <- ncol(low$log_probability):1L
    transformed_low_gradient <- as.vector(
      t(transformation) %*% low$gradient
    )
    numeric_scheduled <- q_name == "121" &&
      point$PointId %in% mfrmr_gcrt_p1n_numeric_gradient_point_ids
    high_numeric_difference <- low_numeric_difference <- NA_real_
    if (numeric_scheduled) {
      high_fn <- function(value) mfrmr_gorb_p1j_bundle(
        value, representative$Mu, point$Rho, contexts$high[[q_name]],
        representative$FastIndex, representative$SlowIndex,
        include_gradient = FALSE
      )$objective
      low_fn <- function(value) mfrmr_gorb_p1j_bundle(
        value, representative$Mu, point$Rho, contexts$low[[q_name]],
        representative$FastIndex, representative$SlowIndex,
        include_gradient = FALSE
      )$objective
      high_numeric <- mfrmr_num_central_gradient(
        high_fn, x, mfrmr_gcrt_p1n_numeric_gradient_step
      )
      low_numeric <- mfrmr_num_central_gradient(
        low_fn, reflected_x, mfrmr_gcrt_p1n_numeric_gradient_step
      )
      high_numeric_difference <- max(abs(high$gradient - high_numeric))
      low_numeric_difference <- max(abs(low$gradient - low_numeric))
    }
    data.frame(
      QuadPoints = as.integer(q_name),
      ObjectiveAbsDifference = abs(high$objective - low$objective),
      ObservedLogProbabilityMirrorMaxAbsDifference = max(abs(
        high$log_probability - low$log_probability[, reverse_node]
      )),
      PosteriorMirrorMaxAbsDifference = max(abs(
        high$posterior - low$posterior[, reverse_node]
      )),
      NuisanceGradientTransportMaxAbsDifference = max(abs(
        high$gradient - transformed_low_gradient
      )),
      MuGradientAbsDifference = abs(high$mu_gradient - low$mu_gradient),
      RhoGradientAbsDifference = abs(high$rho_gradient - low$rho_gradient),
      IndependentNumericGradientScheduled = numeric_scheduled,
      HighAnalyticNumericGradientMaxAbsDifference =
        high_numeric_difference,
      LowAnalyticNumericGradientMaxAbsDifference = low_numeric_difference,
      stringsAsFactors = FALSE
    )
  })
  values <- do.call(rbind, values)
  rownames(values) <- NULL
  objective_difference <- max(values$ObjectiveAbsDifference)
  probability_difference <- max(c(
    values$ObservedLogProbabilityMirrorMaxAbsDifference,
    values$PosteriorMirrorMaxAbsDifference
  ))
  gradient_difference <- max(c(
    values$NuisanceGradientTransportMaxAbsDifference,
    values$MuGradientAbsDifference,
    values$RhoGradientAbsDifference
  ))
  numeric_rows <- values$IndependentNumericGradientScheduled
  numeric_difference <- if (any(numeric_rows)) max(c(
    values$HighAnalyticNumericGradientMaxAbsDifference[numeric_rows],
    values$LowAnalyticNumericGradientMaxAbsDifference[numeric_rows]
  )) else NA_real_
  numeric_pass <- !any(numeric_rows) || (
    is.finite(numeric_difference) &&
      numeric_difference <= mfrmr_gcrt_p1n_numeric_gradient_tolerance
  )
  involution_difference <- max(abs(recovered_x - x))
  pass <- objective_difference <= mfrmr_gcrt_p1n_objective_tolerance &&
    probability_difference <= mfrmr_gcrt_p1n_probability_tolerance &&
    gradient_difference <= mfrmr_gcrt_p1n_gradient_tolerance &&
    involution_difference <= mfrmr_gcrt_p1n_coordinate_tolerance &&
    numeric_pass
  data.frame(
    RepresentativeId = representative$RepresentativeId,
    PairId = pair_id,
    HighScenarioId = representative$ScenarioId,
    LowScenarioId = low_scenario,
    CellId = representative$CellId,
    PointId = point$PointId,
    Rho = point$Rho,
    Mu = representative$Mu,
    MaximumObjectiveAbsDifference = objective_difference,
    MaximumProbabilityMirrorAbsDifference = probability_difference,
    MaximumGradientTransportAbsDifference = gradient_difference,
    IndependentNumericGradientScheduled = any(numeric_rows),
    MaximumAnalyticNumericGradientAbsDifference = numeric_difference,
    IndependentNumericGradientPass = numeric_pass,
    CoordinateInvolutionMaxAbsDifference = involution_difference,
    ReflectedPointIdentityVerified = pass,
    RefitRequired = !pass,
    ContinuousGlobalProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gcrt_p1n_points <- function(p1m, context_result) {
  rows <- list()
  index <- 1L
  transformations <- list()
  matrix_audit <- list()
  for (pair_index in seq_len(nrow(mfrmr_gcrt_p1n_pairs))) {
    pair <- mfrmr_gcrt_p1n_pairs[pair_index, , drop = FALSE]
    high <- context_result$contexts[[pair$PairId]]$high[["121"]]
    low <- context_result$contexts[[pair$PairId]]$low[["121"]]
    transformation <- mfrmr_gcrt_p1n_reflection_matrix(high)
    transformations[[pair$PairId]] <- transformation
    dimension <- nrow(transformation)
    twice_difference <- max(abs(
      transformation %*% transformation - diag(dimension)
    ))
    zero_difference <- max(abs(
      mfrmr_gcrt_p1n_reflect_x(numeric(dimension), high)
    ))
    matrix_audit[[pair_index]] <- data.frame(
      PairId = pair$PairId,
      FreeCoordinateDimension = dimension,
      TransformationRank = qr(transformation)$rank,
      TransformationDeterminant = det(transformation),
      TwiceAppliedMaxAbsDifference = twice_difference,
      ZeroMapMaxAbsDifference = zero_difference,
      LinearCoordinateInvolutionVerified =
        qr(transformation)$rank == dimension &&
        twice_difference <= mfrmr_gcrt_p1n_coordinate_tolerance &&
        zero_difference <= mfrmr_gcrt_p1n_coordinate_tolerance,
      HessianTransportRule = "H_high=t(T)%*%H_low%*%T;inertia_preserved",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
    mfrmr_gcrt_p1n_assert(
      max(abs(
        mfrmr_gcrt_p1n_reflection_matrix(low) - transformation
      )) <= mfrmr_gcrt_p1n_coordinate_tolerance,
      "P1n high/low free-coordinate reflection matrices differ."
    )
  }
  for (representative_index in seq_len(nrow(p1m$representatives))) {
    representative <- p1m$representatives[
      representative_index, , drop = FALSE
    ]
    pair_id <- mfrmr_gcrt_p1n_pairs$PairId[
      mfrmr_gcrt_p1n_pairs$HighScenarioId == representative$ScenarioId
    ]
    trace <- p1m$trace[[representative$RepresentativeId]]
    objects <- p1m$objects[[representative$RepresentativeId]]
    mfrmr_gcrt_p1n_assert(
      nrow(trace) == length(objects) &&
        identical(trace$PointId, names(objects)),
      "P1n P1m point rows and stored objects are misaligned."
    )
    for (point_index in seq_len(nrow(trace))) {
      rows[[index]] <- mfrmr_gcrt_p1n_point(
        representative,
        trace[point_index, , drop = FALSE],
        objects[[point_index]],
        context_result$contexts[[pair_id]],
        transformations[[pair_id]]
      )
      index <- index + 1L
    }
  }
  points <- do.call(rbind, rows)
  rownames(points) <- NULL
  matrix_audit <- do.call(rbind, matrix_audit)
  rownames(matrix_audit) <- NULL
  list(points = points, matrix_audit = matrix_audit)
}

mfrmr_gcrt_p1n_mechanisms <- function(p1m, points) {
  do.call(rbind, lapply(seq_len(nrow(p1m$representatives)), function(index) {
    representative <- p1m$representatives[index, , drop = FALSE]
    rows <- points[
      points$RepresentativeId == representative$RepresentativeId,
      , drop = FALSE
    ]
    source_supported <- if (
      representative$RepresentativeId == "objective_monotone_increasing"
    ) {
      isTRUE(p1m$monotone$AdaptiveGridMonotonicitySupported[
        p1m$monotone$RepresentativeId == representative$RepresentativeId
      ])
    } else {
      isTRUE(p1m$turning$LocalTurningPointMechanismSupported[
        p1m$turning$RepresentativeId == representative$RepresentativeId
      ])
    }
    identity <- nrow(rows) >= 1L &&
      all(rows$ReflectedPointIdentityVerified)
    data.frame(
      RepresentativeId = representative$RepresentativeId,
      PairId = unique(rows$PairId),
      HighScenarioId = representative$ScenarioId,
      LowScenarioId = unique(rows$LowScenarioId),
      MechanismClass = representative$MechanismClass,
      SourceLocalMechanismSupported = source_supported,
      AllStoredPointIdentitiesVerified = identity,
      ReflectedLocalMechanismTransported = source_supported && identity,
      HessianInertiaTransportedByCongruence = source_supported && identity,
      RefitRequired = !identity,
      ContinuousGlobalProfileCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_gcrt_p1n_overall <- function(
    context_audit,
    matrix_audit,
    points,
    mechanisms) {
  all_context <- nrow(context_audit) == 6L &&
    all(context_audit$ContextReflectionIdentityVerified)
  all_matrix <- nrow(matrix_audit) == 2L &&
    all(matrix_audit$LinearCoordinateInvolutionVerified)
  all_point <- nrow(points) == 87L &&
    all(points$ReflectedPointIdentityVerified)
  all_mechanism <- nrow(mechanisms) == 4L &&
    all(mechanisms$ReflectedLocalMechanismTransported)
  data.frame(
    ContextAuditCount = nrow(context_audit),
    CoordinateMapAuditCount = nrow(matrix_audit),
    ReflectedRepresentativePointCount = nrow(points),
    TransportedLocalMechanismCount = sum(
      mechanisms$ReflectedLocalMechanismTransported
    ),
    ExactAndNearFixtureScoreReflectionVerified = all_context,
    SymmetricQuadratureTransportVerified = all_context,
    LinearCoordinateInvolutionVerified = all_matrix,
    AllRepresentativePointLikelihoodAndGradientIdentitiesVerified = all_point,
    AllFourLocalMechanismsTransported = all_mechanism,
    ReflectedRepresentativeFixturesEvaluated =
      all_context && all_matrix && all_point && all_mechanism,
    RefitFallbackRequired = !(
      all_context && all_matrix && all_point && all_mechanism
    ),
    ReflectedFixturesEvaluated = FALSE,
    FullFourFixtureRatioProfilesCompleted = FALSE,
    ContinuousMonotonicityCertified = FALSE,
    ContinuousGlobalProfileCertified = FALSE,
    CoefficientRatioProfilesCompleted = FALSE,
    AllSixTwoTargetFacesGloballyCertified = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    HessianInferenceAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_category_reflection_transport_p1n <- function(
    p1m,
    progress = FALSE) {
  mfrmr_gcrt_p1n_require_sources()
  mfrmr_gcrt_p1n_validate_result(p1m)
  if (isTRUE(progress)) message("P1n: validating reflected contexts")
  context_result <- mfrmr_gcrt_p1n_contexts(p1m)
  if (isTRUE(progress)) message("P1n: transporting 87 stored points")
  point_result <- mfrmr_gcrt_p1n_points(p1m, context_result)
  mechanisms <- mfrmr_gcrt_p1n_mechanisms(p1m, point_result$points)
  overall <- mfrmr_gcrt_p1n_overall(
    context_result$audit, point_result$matrix_audit,
    point_result$points, mechanisms
  )
  structure(
    list(
      contract = mfrmr_gcrt_p1n_contract,
      specification = mfrmr_gcrt_p1n_specification,
      dependency_contract = mfrmr_gcrt_p1n_dependency_contract,
      dependency_sha256 = mfrmr_gcrt_p1n_dependency_sha256,
      pairs = mfrmr_gcrt_p1n_pairs,
      context_audit = context_result$audit,
      coordinate_map_audit = point_result$matrix_audit,
      points = point_result$points,
      mechanisms = mechanisms,
      overall_decision = overall,
      p1m = p1m,
      ReflectedRepresentativeFixturesEvaluated =
        overall$ReflectedRepresentativeFixturesEvaluated,
      RefitFallbackRequired = overall$RefitFallbackRequired,
      ReflectedFixturesEvaluated = FALSE,
      FullFourFixtureRatioProfilesCompleted = FALSE,
      ContinuousMonotonicityCertified = FALSE,
      ContinuousGlobalProfileCertified = FALSE,
      CoefficientRatioProfilesCompleted = FALSE,
      AllSixTwoTargetFacesGloballyCertified = FALSE,
      ThreeTargetFacesEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      HessianInferenceAuthorized = FALSE,
      DFFFitRankAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_category_reflection_transport_p1n"
  )
}

print.mfrmr_gpcm_category_reflection_transport_p1n <- function(
    x, ...) {
  cat("GPCM category-reflection transport P1n audit\n")
  print(x$overall_decision, row.names = FALSE)
  invisible(x)
}
