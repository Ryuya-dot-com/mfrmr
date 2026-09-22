# mfrmr 0.2.3 GPCM fixed-rho nuisance-basin continuation P1l pilot
#
# P1l follows only the 33 objective-discordant P1k cells. At each scheduled
# rho it reoptimizes all nuisance coordinates from a low-end continuation and
# a high-end continuation. The finite grid can expose route merger, objective
# ordering reversal, or persistent grid separation; it cannot certify a
# continuous barrier or the full two-target face.

mfrmr_gfrb_p1l_specification <- "0.2.3-draft.1"
mfrmr_gfrb_p1l_contract <-
  "mfrmr_gpcm_fixed_rho_basin_continuation_p1l_v1"
mfrmr_gfrb_p1l_dependency_contract <-
  "mfrmr_gpcm_fixed_mu_ratio_profile_p1k_v1"
mfrmr_gfrb_p1l_dependency_sha256 <-
  "7dba1c95c26ea2de644ff16f06a1c64480b77f2d47896b54d856c86358a9d1f8"
mfrmr_gfrb_p1l_rho_grid <-
  c(0, 0.01, 0.03, 0.10, 0.25, 0.50, 0.75, 0.90, 0.97, 0.99, 1)
mfrmr_gfrb_p1l_routes <- c("low_to_high", "high_to_low")
mfrmr_gfrb_p1l_route_tolerance <- 5e-6
mfrmr_gfrb_p1l_coordinate_tolerance <- 5e-5
mfrmr_gfrb_p1l_gradient_tolerance <- 1e-4
mfrmr_gfrb_p1l_numeric_gradient_tolerance <- 5e-5
mfrmr_gfrb_p1l_numeric_gradient_step <- 1e-5
mfrmr_gfrb_p1l_profile_derivative_sign_tolerance <- 5e-6
mfrmr_gfrb_p1l_expected_objective_discordant_cells <- 33L
mfrmr_gfrb_p1l_expected_coordinate_only_cells <- 10L

mfrmr_gfrb_p1l_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gfrb_p1l_require_sources <- function() {
  target <- environment(mfrmr_gfrb_p1l_require_sources)
  required <- c(
    "mfrmr_gfmr_p1k_contract", "mfrmr_gfmr_p1k_pairwise",
    "mfrmr_gorb_p1j_bundle", "mfrmr_gorb_p1j_contexts",
    "mfrmr_gc4_p1g_layout", "mfrmr_gcl_p1e_optimize",
    "mfrmr_num_central_gradient", "mfrmr_gss_hash_vector"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )
  mfrmr_gfrb_p1l_assert(
    all(available) && identical(
      get("mfrmr_gfmr_p1k_contract", envir = target, inherits = TRUE),
      mfrmr_gfrb_p1l_dependency_contract
    ),
    "Source P0 through P1k and their numerical dependencies before P1l."
  )
  invisible(TRUE)
}

mfrmr_gfrb_p1l_registry <- function(
    p1k,
    registry_scope = c(
      "objective_discordant", "coordinate_only", "all"
    )) {
  registry_scope <- match.arg(registry_scope)
  mfrmr_gfrb_p1l_assert(
    is.list(p1k) && identical(
      p1k$contract, mfrmr_gfrb_p1l_dependency_contract
    ),
    "P1l requires one complete P1k dependency result."
  )
  pairwise <- mfrmr_gfmr_p1k_pairwise(p1k$profile)
  retained_classes <- switch(
    registry_scope,
    objective_discordant = "competing_kkt_solutions",
    coordinate_only = "same_objective_coordinate_distinct",
    all = c(
      "competing_kkt_solutions", "same_objective_coordinate_distinct"
    )
  )
  registry <- pairwise[
    pairwise$RouteAgreementClass %in% retained_classes, , drop = FALSE
  ]
  registry$P1kAgreementClass <- registry$RouteAgreementClass
  registry$CellId <- paste(
    registry$ScenarioId, registry$OrderedPairId, registry$Mu, sep = "::"
  )
  route_key <- function(value) paste(
    value$ScenarioId, value$OrderedPairId, value$Mu, sep = "::"
  )
  low <- p1k$profile[
    p1k$profile$RouteId == "singleton_boundary", , drop = FALSE
  ]
  high <- p1k$profile[
    p1k$profile$RouteId == "p1i_equal_side", , drop = FALSE
  ]
  low_index <- match(registry$CellId, route_key(low))
  high_index <- match(registry$CellId, route_key(high))
  mfrmr_gfrb_p1l_assert(
    all(!is.na(c(low_index, high_index))),
    "P1l registry could not recover both P1k route candidates."
  )
  registry$P1kLowRouteRho <- low$Rho[low_index]
  registry$P1kHighRouteRho <- high$Rho[high_index]
  registry$P1kLowRouteObjectiveQ121 <- low$ObjectiveQ121[low_index]
  registry$P1kHighRouteObjectiveQ121 <- high$ObjectiveQ121[high_index]
  registry$CellOrder <- seq_len(nrow(registry))
  registry$SelectionAuthorized <- FALSE
  registry$ConfirmationAuthorized <- FALSE
  rownames(registry) <- NULL
  objective_count <- sum(
    registry$P1kAgreementClass == "competing_kkt_solutions"
  )
  coordinate_count <- sum(
    registry$P1kAgreementClass == "same_objective_coordinate_distinct"
  )
  if (registry_scope %in% c("objective_discordant", "all")) {
    mfrmr_gfrb_p1l_assert(
    objective_count == mfrmr_gfrb_p1l_expected_objective_discordant_cells,
    "P1l objective-discordant registry no longer contains 33 P1k cells."
    )
  }
  if (registry_scope %in% c("coordinate_only", "all")) {
    mfrmr_gfrb_p1l_assert(
      coordinate_count == mfrmr_gfrb_p1l_expected_coordinate_only_cells,
      "P1l coordinate-only registry no longer contains 10 P1k cells."
    )
  }
  registry$RegistryScope <- registry_scope
  registry
}

mfrmr_gfrb_p1l_plan <- function(registry) {
  mfrmr_gfrb_p1l_assert(
    is.data.frame(registry) && nrow(registry) >= 1L &&
      all(c(
        "ScenarioId", "OrderedPairId", "FastIndex", "SlowIndex",
        "TargetSetId", "Mu", "P1kAgreementClass", "CellId", "CellOrder"
      ) %in% names(registry)),
    "P1l plan requires a nonempty frozen P1k discrepancy registry."
  )
  plan <- do.call(rbind, lapply(seq_len(nrow(registry)), function(index) {
    cell <- registry[index, , drop = FALSE]
    rho <- sort(unique(c(
      mfrmr_gfrb_p1l_rho_grid,
      cell$P1kLowRouteRho,
      cell$P1kHighRouteRho
    )))
    merge(
      cell[, c(
      "ScenarioId", "OrderedPairId", "FastIndex", "SlowIndex",
      "TargetSetId", "Mu", "P1kAgreementClass", "CellId", "CellOrder",
      "P1kLowRouteRho", "P1kHighRouteRho"
      )],
      expand.grid(
        RouteId = mfrmr_gfrb_p1l_routes,
        Rho = rho,
        KEEP.OUT.ATTRS = FALSE,
        stringsAsFactors = FALSE
      ),
      by = NULL
    )
  }))
  plan$RouteOrder <- match(plan$RouteId, mfrmr_gfrb_p1l_routes)
  plan <- plan[order(
    plan$CellOrder, plan$RouteOrder, plan$Rho
  ), , drop = FALSE]
  rownames(plan) <- NULL
  plan$RhoSource <- ifelse(
    plan$Rho %in% mfrmr_gfrb_p1l_rho_grid,
    "prespecified_base_grid", "p1k_stationary_candidate"
  )
  plan$OptimizationQuadrature <- 121L
  plan$IndependentGradientScheduled <-
    plan$CellOrder == 1L & plan$RouteId == "low_to_high" &
    plan$Rho %in% c(0, 0.5, 1)
  plan$SelectionAuthorized <- FALSE
  plan$ConfirmationAuthorized <- FALSE
  list(
    continuation = plan,
    cell_count = nrow(registry),
    objective_discordant_cell_count = sum(
      registry$P1kAgreementClass == "competing_kkt_solutions"
    ),
    coordinate_only_cell_count = sum(
      registry$P1kAgreementClass == "same_objective_coordinate_distinct"
    ),
    rho_point_count = length(mfrmr_gfrb_p1l_rho_grid),
    distinct_cell_rho_point_count = nrow(plan) /
      length(mfrmr_gfrb_p1l_routes),
    route_count = length(mfrmr_gfrb_p1l_routes),
    fit_count = nrow(plan),
    ReflectedFixturesEvaluated = FALSE,
    FullTwoTargetFaceGloballyCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gfrb_p1l_p1k_candidate <- function(
    p1k,
    scenario_id,
    ordered_pair_id,
    mu,
    p1k_route_id) {
  key <- paste(
    scenario_id, ordered_pair_id, mu, p1k_route_id, sep = "::"
  )
  candidate <- p1k$profile_objects[[key]]
  mfrmr_gfrb_p1l_assert(
    is.list(candidate) && is.numeric(candidate$value) &&
      length(candidate$value) >= 2L && all(is.finite(candidate$value)),
    paste0("P1l could not recover eligible P1k candidate: ", key)
  )
  candidate
}

mfrmr_gfrb_p1l_fixed_candidate <- function(
    start,
    scenario_id,
    ordered_pair_id,
    fast_index,
    slow_index,
    target_set_id,
    mu,
    rho,
    route_id,
    contexts,
    numeric_gradient_scheduled,
    maxit,
    reltol) {
  start <- as.numeric(start)
  context <- contexts[["121"]]
  layout <- mfrmr_gc4_p1g_layout(context)
  mfrmr_gfrb_p1l_assert(
    length(start) == layout$dimension && all(is.finite(start)),
    "P1l fixed-rho start has invalid nuisance dimension or values."
  )
  fn <- function(value) mfrmr_gorb_p1j_bundle(
    value, mu, rho, context, fast_index, slow_index,
    include_gradient = FALSE
  )$objective
  gr <- function(value) mfrmr_gorb_p1j_bundle(
    value, mu, rho, context, fast_index, slow_index,
    include_gradient = TRUE
  )$gradient
  optimized <- mfrmr_gcl_p1e_optimize(
    start, fn, gr, maxit = maxit, reltol = reltol
  )
  returned <- isTRUE(optimized$returned)
  value <- optimized$par
  objective <- NA_real_
  gradient <- rep(NA_real_, length(start))
  rho_derivative <- NA_real_
  objectives <- setNames(rep(NA_real_, length(contexts)), names(contexts))
  numeric_difference <- NA_real_
  if (returned) {
    bundle <- mfrmr_gorb_p1j_bundle(
      value, mu, rho, context, fast_index, slow_index,
      include_gradient = TRUE
    )
    objective <- bundle$objective
    gradient <- bundle$gradient
    rho_derivative <- bundle$rho_gradient
    objectives <- vapply(contexts, function(candidate_context) {
      mfrmr_gorb_p1j_bundle(
        value, mu, rho, candidate_context, fast_index, slow_index,
        include_gradient = FALSE
      )$objective
    }, numeric(1L))
    if (isTRUE(numeric_gradient_scheduled)) {
      numeric_gradient <- mfrmr_num_central_gradient(
        fn, value, mfrmr_gfrb_p1l_numeric_gradient_step
      )
      numeric_difference <- max(abs(gradient - numeric_gradient))
    }
  }
  convergence_code <- if (
    returned && !is.null(optimized$selected$opt)
  ) optimized$selected$opt$convergence else NA_integer_
  convergence_severity <- if (
    returned && !is.null(optimized$selected$diagnostics)
  ) optimized$selected$diagnostics$ConvergenceSeverity else "not_returned"
  nuisance_gradient_sup <- if (
    returned && all(is.finite(gradient))
  ) max(abs(gradient)) else NA_real_
  derivative_complete <- !isTRUE(numeric_gradient_scheduled) || (
    is.finite(numeric_difference) &&
      numeric_difference <= mfrmr_gfrb_p1l_numeric_gradient_tolerance
  )
  eligible <- returned && convergence_code == 0L &&
    identical(convergence_severity, "pass") &&
    is.finite(nuisance_gradient_sup) &&
    nuisance_gradient_sup <= mfrmr_gfrb_p1l_gradient_tolerance &&
    all(is.finite(objectives)) && derivative_complete
  row <- data.frame(
    ScenarioId = scenario_id,
    OrderedPairId = ordered_pair_id,
    FastIndex = fast_index,
    SlowIndex = slow_index,
    TargetSetId = target_set_id,
    CellId = paste(scenario_id, ordered_pair_id, mu, sep = "::"),
    RouteId = route_id,
    Mu = mu,
    Rho = rho,
    FitReturned = returned,
    ObjectiveQ121 = objective,
    ObjectiveQ61 = as.numeric(objectives[["61"]]),
    ObjectiveQ91 = as.numeric(objectives[["91"]]),
    QuadratureObjectiveRange = if (all(is.finite(objectives))) {
      diff(range(objectives))
    } else NA_real_,
    RhoObjectiveDerivative = rho_derivative,
    NuisanceGradientSupNorm = nuisance_gradient_sup,
    ConvergenceCode = convergence_code,
    ConvergenceSeverity = convergence_severity,
    IndependentGradientScheduled = isTRUE(numeric_gradient_scheduled),
    AnalyticNumericGradientMaxAbsDifference = numeric_difference,
    ContinuationCandidateEligible = eligible,
    ContinuationEligibilityReason = if (eligible) {
      "stationary_fixed_rho_nuisance_solution"
    } else if (returned) {
      "fixed_rho_nuisance_solution_inference_ineligible"
    } else {
      "fixed_rho_nuisance_solution_not_returned"
    },
    FiniteGridOnly = TRUE,
    ContinuousBarrierCertified = FALSE,
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
      mfrmr_gss_hash_vector(value)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
  list(row = row, value = value, optimized = optimized)
}

mfrmr_gfrb_p1l_pairwise <- function(profile, profile_objects) {
  groups <- split(
    profile,
    interaction(profile$CellId, profile$Rho, drop = TRUE)
  )
  out <- lapply(groups, function(value) {
    low <- value[
      value$RouteId == mfrmr_gfrb_p1l_routes[1L], , drop = FALSE
    ]
    high <- value[
      value$RouteId == mfrmr_gfrb_p1l_routes[2L], , drop = FALSE
    ]
    complete <- nrow(low) == 1L && nrow(high) == 1L
    eligible <- complete && isTRUE(low$ContinuationCandidateEligible) &&
      isTRUE(high$ContinuationCandidateEligible)
    objective_difference <- if (complete) {
      low$ObjectiveQ121 - high$ObjectiveQ121
    } else NA_real_
    coordinate_difference <- NA_real_
    if (complete) {
      low_value <- profile_objects[[low$CandidateKey]]$value
      high_value <- profile_objects[[high$CandidateKey]]$value
      if (
        length(low_value) == length(high_value) &&
          all(is.finite(c(low_value, high_value)))
      ) coordinate_difference <- max(abs(low_value - high_value))
    }
    objective_agreement <- eligible && is.finite(objective_difference) &&
      abs(objective_difference) <= mfrmr_gfrb_p1l_route_tolerance
    coordinate_agreement <- eligible && is.finite(coordinate_difference) &&
      coordinate_difference <= mfrmr_gfrb_p1l_coordinate_tolerance
    agreement_class <- if (!eligible) {
      "route_ineligible"
    } else if (objective_agreement && coordinate_agreement) {
      "same_fixed_rho_solution"
    } else if (objective_agreement) {
      "same_fixed_rho_objective_coordinate_distinct"
    } else {
      "competing_fixed_rho_nuisance_solutions"
    }
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      OrderedPairId = value$OrderedPairId[1L],
      FastIndex = value$FastIndex[1L],
      SlowIndex = value$SlowIndex[1L],
      TargetSetId = value$TargetSetId[1L],
      CellId = value$CellId[1L],
      Mu = value$Mu[1L],
      Rho = value$Rho[1L],
      BothRoutesPresent = complete,
      BothRoutesEligible = eligible,
      LowObjectiveQ121 = low$ObjectiveQ121,
      HighObjectiveQ121 = high$ObjectiveQ121,
      LowMinusHighObjective = objective_difference,
      ObjectiveAbsDifference = abs(objective_difference),
      LowRhoObjectiveDerivative = low$RhoObjectiveDerivative,
      HighRhoObjectiveDerivative = high$RhoObjectiveDerivative,
      MeanRhoObjectiveDerivative = mean(c(
        low$RhoObjectiveDerivative, high$RhoObjectiveDerivative
      )),
      RhoObjectiveDerivativeAbsDifference = abs(
        low$RhoObjectiveDerivative - high$RhoObjectiveDerivative
      ),
      NuisanceCoordinateMaxAbsDifference = coordinate_difference,
      ObjectiveAgreementWithinTolerance = objective_agreement,
      CoordinateAgreementWithinTolerance = coordinate_agreement,
      RouteAgreementClass = agreement_class,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result[order(
    result$ScenarioId, result$OrderedPairId, result$Mu, result$Rho
  ), , drop = FALSE]
}

mfrmr_gfrb_p1l_cell_classification <- function(pairwise, registry) {
  groups <- split(pairwise, pairwise$CellId)
  out <- lapply(groups, function(value) {
    value <- value[order(value$Rho), , drop = FALSE]
    source <- registry[
      registry$CellId == value$CellId[1L], , drop = FALSE
    ]
    mfrmr_gfrb_p1l_assert(
      nrow(source) == 1L,
      "P1l cell classification lost its P1k registry identity."
    )
    expected_rho <- sort(unique(c(
      mfrmr_gfrb_p1l_rho_grid,
      source$P1kLowRouteRho,
      source$P1kHighRouteRho
    )))
    all_eligible <- nrow(value) == length(expected_rho) &&
      all(value$BothRoutesEligible) && all(expected_rho %in% value$Rho)
    objective_sign <- ifelse(
      value$LowMinusHighObjective > mfrmr_gfrb_p1l_route_tolerance,
      1L,
      ifelse(
        value$LowMinusHighObjective < -mfrmr_gfrb_p1l_route_tolerance,
        -1L, 0L
      )
    )
    interior <- value$Rho > 0 & value$Rho < 1
    objective_agreement <- value$ObjectiveAgreementWithinTolerance
    coordinate_agreement <- value$CoordinateAgreementWithinTolerance
    ordering_reversal <- any(objective_sign > 0L) &&
      any(objective_sign < 0L)
    merger_observed <- any(interior & objective_agreement)
    persistent_separation <- all_eligible &&
      any(interior) && all(!objective_agreement[interior])
    same_objective_all <- all_eligible && all(objective_agreement)
    same_solution_all <- same_objective_all && all(coordinate_agreement)
    derivative <- value$MeanRhoObjectiveDerivative
    derivative_sign <- ifelse(
      derivative > mfrmr_gfrb_p1l_profile_derivative_sign_tolerance,
      1L,
      ifelse(
        derivative < -mfrmr_gfrb_p1l_profile_derivative_sign_tolerance,
        -1L, 0L
      )
    )
    ordered_transition <- function(from, to) {
      from_index <- which(derivative_sign == from)
      to_index <- which(derivative_sign == to)
      length(from_index) > 0L && length(to_index) > 0L &&
        any(vapply(from_index, function(index) {
          any(to_index > index)
        }, logical(1L)))
    }
    positive_to_negative <- ordered_transition(1L, -1L)
    negative_to_positive <- ordered_transition(-1L, 1L)
    all_positive <- all(derivative_sign > 0L)
    all_negative <- all(derivative_sign < 0L)
    closest_row <- function(rho) {
      value[which.min(abs(value$Rho - rho)), , drop = FALSE]
    }
    low_rows <- closest_row(source$P1kLowRouteRho)
    high_rows <- closest_row(source$P1kHighRouteRho)
    p1k_recovery <- max(abs(c(
      low_rows$LowObjectiveQ121 - source$P1kLowRouteObjectiveQ121,
      high_rows$HighObjectiveQ121 - source$P1kHighRouteObjectiveQ121
    )))
    mechanism <- if (!all_eligible) {
      "continuation_ineligible"
    } else if (same_solution_all && positive_to_negative &&
        !negative_to_positive) {
      "route_coalescence_profile_maximum_bracket"
    } else if (same_solution_all && negative_to_positive &&
        !positive_to_negative) {
      "route_coalescence_profile_minimum_bracket"
    } else if (same_solution_all && all_positive) {
      "route_coalescence_monotone_increasing_grid"
    } else if (same_solution_all && all_negative) {
      "route_coalescence_monotone_decreasing_grid"
    } else if (same_solution_all) {
      "route_coalescence_mixed_derivative_grid"
    } else if (same_objective_all) {
      "coordinate_only_profile_on_scheduled_grid"
    } else if (ordering_reversal) {
      "objective_ordering_reversal_on_scheduled_grid"
    } else if (merger_observed) {
      "objective_merger_observed_on_scheduled_grid"
    } else if (persistent_separation) {
      "objective_separation_persists_on_scheduled_grid"
    } else {
      "mixed_finite_grid_evidence"
    }
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      OrderedPairId = value$OrderedPairId[1L],
      FastIndex = value$FastIndex[1L],
      SlowIndex = value$SlowIndex[1L],
      TargetSetId = value$TargetSetId[1L],
      CellId = value$CellId[1L],
      Mu = value$Mu[1L],
      P1kAgreementClass = source$P1kAgreementClass,
      ScheduledRhoPointCount = nrow(value),
      AllGridPointsHaveTwoEligibleRoutes = all_eligible,
      SameObjectiveAtEveryGridPoint = same_objective_all,
      SameSolutionAtEveryGridPoint = same_solution_all,
      PositiveToNegativeDerivativeBracketObserved = positive_to_negative,
      NegativeToPositiveDerivativeBracketObserved = negative_to_positive,
      AllScheduledProfileDerivativesPositive = all_positive,
      AllScheduledProfileDerivativesNegative = all_negative,
      P1kStationaryObjectiveRecoveryMaxAbsDifference = p1k_recovery,
      InteriorObjectiveMergerObserved = merger_observed,
      ObjectiveOrderingReversalObserved = ordering_reversal,
      ObjectiveSeparationPersistsOnScheduledInteriorGrid =
        persistent_separation,
      MaximumObjectiveAbsDifference = max(
        value$ObjectiveAbsDifference, na.rm = TRUE
      ),
      MaximumNuisanceCoordinateAbsDifference = max(
        value$NuisanceCoordinateMaxAbsDifference, na.rm = TRUE
      ),
      MechanismClass = mechanism,
      FiniteGridOnly = TRUE,
      ContinuousBarrierCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result[order(
    result$ScenarioId, result$OrderedPairId, result$Mu
  ), , drop = FALSE]
}

mfrmr_gfrb_p1l_portfolio <- function(profile, p1k) {
  groups <- split(
    profile,
    interaction(profile$ScenarioId, profile$TargetSetId, drop = TRUE)
  )
  out <- lapply(groups, function(value) {
    eligible <- value[
      value$ContinuationCandidateEligible, , drop = FALSE
    ]
    interior <- unique(p1k$p1j$p1i$profile$InteriorObjectiveQ121[
      p1k$p1j$p1i$profile$ScenarioId == value$ScenarioId[1L]
    ])
    mfrmr_gfrb_p1l_assert(
      length(interior) == 1L,
      "P1l portfolio requires one qualified interior objective."
    )
    best <- if (nrow(eligible) > 0L) {
      min(eligible$ObjectiveQ121)
    } else NA_real_
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      TargetSetId = value$TargetSetId[1L],
      EligibleContinuationCandidateCount = nrow(eligible),
      BestContinuationObjectiveQ121 = best,
      QualifiedInteriorObjectiveQ121 = interior,
      BestContinuationMinusInterior = best - interior,
      BestContinuationAboveInterior = is.finite(best) && best > interior,
      RatioProfileGloballyCertified = FALSE,
      FullTwoTargetFaceGloballyCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result[order(result$ScenarioId, result$TargetSetId), , drop = FALSE]
}

mfrmr_gfrb_p1l_overall_decision <- function(
    profile,
    pairwise,
    cells,
    portfolio,
    registry) {
  objective_cells <- sum(
    registry$P1kAgreementClass == "competing_kkt_solutions"
  )
  coordinate_cells <- sum(
    registry$P1kAgreementClass == "same_objective_coordinate_distinct"
  )
  expected_pairs <- sum(vapply(seq_len(nrow(registry)), function(index) {
    length(unique(c(
      mfrmr_gfrb_p1l_rho_grid,
      registry$P1kLowRouteRho[index],
      registry$P1kHighRouteRho[index]
    )))
  }, integer(1L)))
  expected_fits <- expected_pairs * length(mfrmr_gfrb_p1l_routes)
  all_fits_eligible <- nrow(profile) == expected_fits &&
    all(profile$ContinuationCandidateEligible)
  all_pairs_eligible <- nrow(pairwise) == expected_pairs &&
    all(pairwise$BothRoutesEligible)
  all_cells_mapped <- nrow(cells) == nrow(registry) &&
    all(cells$AllGridPointsHaveTwoEligibleRoutes)
  levels <- c(
    "route_coalescence_profile_maximum_bracket",
    "route_coalescence_profile_minimum_bracket",
    "route_coalescence_monotone_increasing_grid",
    "route_coalescence_monotone_decreasing_grid",
    "route_coalescence_mixed_derivative_grid",
    "coordinate_only_profile_on_scheduled_grid",
    "objective_ordering_reversal_on_scheduled_grid",
    "objective_merger_observed_on_scheduled_grid",
    "objective_separation_persists_on_scheduled_grid",
    "mixed_finite_grid_evidence", "continuation_ineligible"
  )
  counts <- table(factor(cells$MechanismClass, levels = levels))
  objective_complete <- objective_cells ==
    mfrmr_gfrb_p1l_expected_objective_discordant_cells &&
    all_fits_eligible && all_pairs_eligible && all_cells_mapped
  coordinate_complete <- coordinate_cells ==
    mfrmr_gfrb_p1l_expected_coordinate_only_cells &&
    all_fits_eligible && all_pairs_eligible && all_cells_mapped
  data.frame(
    ObjectiveDiscordantRegistryCellCount = objective_cells,
    CoordinateOnlyRegistryCellCount = coordinate_cells,
    AllContinuationFitsEligible = all_fits_eligible,
    AllScheduledRhoPairsEligible = all_pairs_eligible,
    AllRegisteredCellsMapped = all_cells_mapped,
    RouteCoalescenceProfileMaximumBracketCellCount = unname(
      counts[["route_coalescence_profile_maximum_bracket"]]
    ),
    RouteCoalescenceProfileMinimumBracketCellCount = unname(
      counts[["route_coalescence_profile_minimum_bracket"]]
    ),
    RouteCoalescenceMonotoneIncreasingGridCellCount = unname(
      counts[["route_coalescence_monotone_increasing_grid"]]
    ),
    RouteCoalescenceMonotoneDecreasingGridCellCount = unname(
      counts[["route_coalescence_monotone_decreasing_grid"]]
    ),
    RouteCoalescenceMixedDerivativeGridCellCount = unname(
      counts[["route_coalescence_mixed_derivative_grid"]]
    ),
    CoordinateOnlyProfileOnGridCellCount = unname(
      counts[["coordinate_only_profile_on_scheduled_grid"]]
    ),
    ObjectiveOrderingReversalOnGridCellCount = unname(
      counts[["objective_ordering_reversal_on_scheduled_grid"]]
    ),
    ObjectiveMergerOnGridCellCount = unname(
      counts[["objective_merger_observed_on_scheduled_grid"]]
    ),
    PersistentObjectiveSeparationOnGridCellCount = unname(
      counts[["objective_separation_persists_on_scheduled_grid"]]
    ),
    MixedFiniteGridEvidenceCellCount = unname(
      counts[["mixed_finite_grid_evidence"]]
    ),
    ContinuationIneligibleCellCount = unname(
      counts[["continuation_ineligible"]]
    ),
    ObjectiveDiscordantFixedRhoContinuationCompleted = objective_complete,
    CoordinateOnlyFixedRhoContinuationCompleted = coordinate_complete,
    AllObservedContinuationMinimaAboveInterior =
      nrow(portfolio) >= 1L && all(portfolio$BestContinuationAboveInterior),
    FiniteGridOnly = TRUE,
    ContinuousBarrierCertified = FALSE,
    ReflectedFixturesEvaluated = FALSE,
    FullFourFixtureRatioProfilesCompleted = FALSE,
    CoefficientRatioProfilesCompleted = FALSE,
    AllSixTwoTargetFacesGloballyCertified = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_fixed_rho_basin_continuation_p1l <- function(
    p1k,
    registry_scope = c(
      "objective_discordant", "coordinate_only", "all"
    ),
    maxit = 800L,
    reltol = 1e-12,
    progress = FALSE) {
  mfrmr_gfrb_p1l_require_sources()
  registry_scope <- match.arg(registry_scope)
  registry <- mfrmr_gfrb_p1l_registry(
    p1k, registry_scope = registry_scope
  )
  plan <- mfrmr_gfrb_p1l_plan(registry)
  rows <- list()
  objects <- list()
  row_index <- 1L
  contexts_by_scenario <- lapply(
    unique(registry$ScenarioId),
    function(scenario_id) mfrmr_gorb_p1j_contexts(
      p1k$p1j$p1i, scenario_id
    )
  )
  names(contexts_by_scenario) <- unique(registry$ScenarioId)
  for (cell_index in seq_len(nrow(registry))) {
    cell <- registry[cell_index, , drop = FALSE]
    contexts <- contexts_by_scenario[[cell$ScenarioId]]
    for (route_id in mfrmr_gfrb_p1l_routes) {
      p1k_route_id <- if (route_id == "low_to_high") {
        "singleton_boundary"
      } else {
        "p1i_equal_side"
      }
      source <- mfrmr_gfrb_p1l_p1k_candidate(
        p1k, cell$ScenarioId, cell$OrderedPairId, cell$Mu,
        p1k_route_id
      )
      current <- source$value[-length(source$value)]
      cell_rho <- sort(unique(plan$continuation$Rho[
        plan$continuation$CellId == cell$CellId
      ]))
      rho_path <- if (route_id == "low_to_high") {
        cell_rho
      } else {
        rev(cell_rho)
      }
      for (rho in rho_path) {
        scheduled <- cell$CellOrder == 1L &&
          route_id == "low_to_high" &&
          rho %in% c(0, 0.5, 1)
        if (isTRUE(progress)) message(
          "Fixed-rho P1l: ", cell$CellId, " / ", route_id,
          " / rho=", rho
        )
        candidate <- mfrmr_gfrb_p1l_fixed_candidate(
          start = current,
          scenario_id = cell$ScenarioId,
          ordered_pair_id = cell$OrderedPairId,
          fast_index = cell$FastIndex,
          slow_index = cell$SlowIndex,
          target_set_id = cell$TargetSetId,
          mu = cell$Mu,
          rho = rho,
          route_id = route_id,
          contexts = contexts,
          numeric_gradient_scheduled = scheduled,
          maxit = maxit,
          reltol = reltol
        )
        key <- paste(cell$CellId, rho, route_id, sep = "::")
        candidate$row$CandidateKey <- key
        rows[[row_index]] <- candidate$row
        objects[[key]] <- candidate
        row_index <- row_index + 1L
        if (isTRUE(candidate$row$ContinuationCandidateEligible)) {
          current <- candidate$value
        }
      }
    }
  }
  profile <- do.call(rbind, rows)
  rownames(profile) <- NULL
  profile <- profile[order(
    match(profile$CellId, registry$CellId),
    profile$Rho,
    match(profile$RouteId, mfrmr_gfrb_p1l_routes)
  ), , drop = FALSE]
  rownames(profile) <- NULL
  pairwise <- mfrmr_gfrb_p1l_pairwise(profile, objects)
  cells <- mfrmr_gfrb_p1l_cell_classification(pairwise, registry)
  portfolio <- mfrmr_gfrb_p1l_portfolio(profile, p1k)
  overall <- mfrmr_gfrb_p1l_overall_decision(
    profile, pairwise, cells, portfolio, registry
  )
  structure(
    list(
      contract = mfrmr_gfrb_p1l_contract,
      specification = mfrmr_gfrb_p1l_specification,
      dependency_contract = mfrmr_gfrb_p1l_dependency_contract,
      dependency_sha256 = mfrmr_gfrb_p1l_dependency_sha256,
      rho_grid = mfrmr_gfrb_p1l_rho_grid,
      registry_scope = registry_scope,
      registry = registry,
      plan = plan,
      profile = profile,
      profile_objects = objects,
      pairwise = pairwise,
      cells = cells,
      portfolio = portfolio,
      overall_decision = overall,
      p1k = p1k,
      ObjectiveDiscordantFixedRhoContinuationCompleted =
        overall$ObjectiveDiscordantFixedRhoContinuationCompleted,
      CoordinateOnlyFixedRhoContinuationCompleted =
        overall$CoordinateOnlyFixedRhoContinuationCompleted,
      FiniteGridOnly = TRUE,
      ContinuousBarrierCertified = FALSE,
      ReflectedFixturesEvaluated = FALSE,
      FullFourFixtureRatioProfilesCompleted = FALSE,
      CoefficientRatioProfilesCompleted = FALSE,
      AllSixTwoTargetFacesGloballyCertified = FALSE,
      ThreeTargetFacesEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_fixed_rho_basin_continuation_p1l"
  )
}
