# Internal D-SIM-3 separate-univariate truth-coefficient adapter.
#
# This layer combines the qualified design-dependent target covariance with
# the qualified incidence-aware allocation diagonals.  It computes named
# per-stratum truth G/Phi values only.  It does not inspect responses, consume
# an RNG stream, call a backend, fit a model, or claim empirical recovery.

mfrmr_gtds3m_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3c_compile_profile",
    "mfrmr_gtds3t_contract", "mfrmr_gtds3t_manifest",
    "mfrmr_gtds3t_assert_manifest", "mfrmr_gtds3t_project_profile",
    "mfrmr_gtds3o_contract", "mfrmr_gtds3o_manifest",
    "mfrmr_gtds3o_assert_manifest", "mfrmr_gtds3o_operator_from_assignments"
  )
  target <- environment(mfrmr_gtds3m_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 truth and allocation chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3m_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3m_identity <- function() {
  list(
    ContractId =
      "MFRMR-GTHEORY-MV-DSIM3-SEPARATE-UNIV-TRUTH-COEFFICIENT-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentTruthContractHash =
      "fb66bd15526afa1f18f613dcbc4b0d470350bcf803a642fcde537602d017f327",
    ParentTruthManifestHash =
      "97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5",
    ParentOperatorContractHash =
      "89b158391acf18c090ab708d39780499f3fbf3882ec912e04a3e8d775263693a",
    ParentOperatorManifestHash =
      "526298d0c598e34a92e98b96b7bc59c0714fc053636bc25ea423d4c87c895093"
  )
}

mfrmr_gtds3m_estimand_registry <- function() {
  data.frame(
    EstimandId = c("REL-G", "ABS-PHI"),
    OutputCoefficient = c("G", "Phi"),
    Numerator = "allocated_object_universe_variance",
    ErrorRoles = c("relative_error", "relative_error_plus_absolute_only"),
    Formula = c(
      "universe_over_universe_plus_relative_error",
      "universe_over_universe_plus_absolute_error"
    ),
    OutputShape = "named_per_stratum_numeric_vector",
    CrossStratumPoolingAllowed = FALSE,
    CrossStratumCovarianceRecovered = FALSE,
    IndependentEstimandVote = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3m_contract <- function() {
  mfrmr_gtds3m_require_primitives()
  identity <- mfrmr_gtds3m_identity()
  payload <- c(identity, list(
    RouteId = "separate_univariate",
    ExpectedProfileCount = 21L,
    ExpectedStratumCoefficientCount = 47L,
    ExpectedCrossedStratumCoefficientCount = 32L,
    ExpectedNestedStratumCoefficientCount = 15L,
    ExpectedComponentContributionCount = 173L,
    ExpectedFitRepresentationBlockCount = 160L,
    ExpectedOneRepeatStratumCoefficientCount = 13L,
    ExpectedScalarOracleComparisonCount = 235L,
    EstimandRegistry = mfrmr_gtds3m_estimand_registry(),
    UniverseRole = "object",
    RelativeErrorRole = "relative_error",
    AbsoluteOnlyRole = "absolute_only",
    ObjectOperatorMustEqualOne = TRUE,
    UnitCovarianceDiagonalRequired = TRUE,
    EffectiveUnitDiagonalEquivalenceRequired = TRUE,
    IncidenceOperatorDiagonalRequired = TRUE,
    OneRepeatFitRepresentation =
      "combined_object_condition_plus_event_residual",
    RepeatedFitRepresentation = "separate_component_blocks",
    NestedPhiMustEqualG = TRUE,
    CrossedPhiMustNotExceedG = TRUE,
    CrossStratumCovarianceUsed = FALSE,
    OffDiagonalPerturbationInvariantRequired = TRUE,
    ComponentOrderInvariantRequired = TRUE,
    CommonPositiveScaleInvariantRequired = TRUE,
    IndependentScalarOracleRequired = TRUE,
    ScalarOracleMayUseOperatorImplementation = FALSE,
    ScalarOracleConditionRule = "one_over_registered_rater_count",
    ScalarOracleEventRule =
      "one_over_registered_rater_count_times_registered_repeat_count",
    MatrixTolerance = 1e-10,
    ScaleInvarianceFactor = 7,
    OffDiagonalPerturbation = 0.125,
    ScenarioSpecificPatchCount = 0L,
    TruthMetricMayUseRng = FALSE,
    TruthMetricMayInspectResponse = FALSE,
    TruthMetricMayCallBackend = FALSE,
    TruthMetricMayFit = FALSE,
    FittedCoefficientComputed = FALSE,
    ExistingUnopenedExecutionPlanMayBeMutated = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3m_hash(payload)
  )), class = c("mfrmr_gtds3m_contract", "list"))
}

mfrmr_gtds3m_validate_contract <- function(
    contract = mfrmr_gtds3m_contract()) {
  canonical <- mfrmr_gtds3m_contract()
  estimands <- contract$EstimandRegistry
  valid <- inherits(contract, "mfrmr_gtds3m_contract") &&
    identical(contract, canonical) &&
    is.data.frame(estimands) && nrow(estimands) == 2L &&
    identical(estimands$EstimandId, c("REL-G", "ABS-PHI")) &&
    !any(estimands$CrossStratumPoolingAllowed) &&
    !any(estimands$CrossStratumCovarianceRecovered) &&
    identical(contract$ExpectedProfileCount, 21L) &&
    identical(contract$ExpectedStratumCoefficientCount, 47L) &&
    identical(contract$ExpectedComponentContributionCount, 173L) &&
    identical(contract$ExpectedFitRepresentationBlockCount, 160L) &&
    identical(contract$ExpectedOneRepeatStratumCoefficientCount, 13L) &&
    identical(contract$ExpectedScalarOracleComparisonCount, 235L) &&
    isTRUE(contract$ObjectOperatorMustEqualOne) &&
    isTRUE(contract$UnitCovarianceDiagonalRequired) &&
    isTRUE(contract$EffectiveUnitDiagonalEquivalenceRequired) &&
    isTRUE(contract$IncidenceOperatorDiagonalRequired) &&
    isTRUE(contract$NestedPhiMustEqualG) &&
    isTRUE(contract$CrossedPhiMustNotExceedG) &&
    !isTRUE(contract$CrossStratumCovarianceUsed) &&
    isTRUE(contract$OffDiagonalPerturbationInvariantRequired) &&
    isTRUE(contract$ComponentOrderInvariantRequired) &&
    isTRUE(contract$CommonPositiveScaleInvariantRequired) &&
    isTRUE(contract$IndependentScalarOracleRequired) &&
    !isTRUE(contract$ScalarOracleMayUseOperatorImplementation) &&
    identical(contract$ScenarioSpecificPatchCount, 0L) &&
    !isTRUE(contract$TruthMetricMayUseRng) &&
    !isTRUE(contract$TruthMetricMayInspectResponse) &&
    !isTRUE(contract$TruthMetricMayCallBackend) &&
    !isTRUE(contract$TruthMetricMayFit) &&
    !isTRUE(contract$FittedCoefficientComputed) &&
    !isTRUE(contract$ExistingUnopenedExecutionPlanMayBeMutated) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 truth-coefficient contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3m_fit_group <- function(
    component_id, universe_role, repeat_count) {
  if (repeat_count == 1L &&
      component_id %in% c("Object:Rater", "NestedCondition", "Residual")) {
    return("combined_object_condition_plus_event_residual")
  }
  if (identical(universe_role, "object")) return("object")
  paste0("separate_", component_id)
}

mfrmr_gtds3m_component_contributions <- function(
    truth, operators, contract = mfrmr_gtds3m_contract()) {
  registry <- truth$TargetComponentRegistry
  target_ids <- registry$TargetComponentId
  if (!inherits(truth, "mfrmr_gtds3t_projection") ||
      !is.list(operators) ||
      !identical(sort(names(operators)), sort(target_ids))) {
    stop("A truth projection and its complete operator set are required.",
         call. = FALSE)
  }
  profile <- unlist(truth$Profile, use.names = TRUE)
  repeat_count <- as.integer(profile[["repeat_count"]])
  strata <- rownames(truth$TargetComponents[[target_ids[[1L]]]]$
                       UnitCovarianceMatrix)
  rows <- list()
  cursor <- 0L
  for (component_ordinal in seq_along(target_ids)) {
    target_id <- target_ids[[component_ordinal]]
    component <- truth$TargetComponents[[target_id]]
    operator <- operators[[target_id]]
    unit <- component$UnitCovarianceMatrix
    effective <- component$EffectiveCovarianceMatrix
    allocation <- operator$OperatorMatrix
    if (!identical(rownames(unit), strata) ||
        !identical(colnames(unit), strata) ||
        !identical(dimnames(allocation), list(strata, strata))) {
      stop("Truth and operator strata are not aligned.", call. = FALSE)
    }
    unit_variance <- diag(unit)
    effective_variance <- diag(effective)
    operator_diagonal <- diag(allocation)
    if (any(unit_variance <= 0) || any(operator_diagonal <= 0) ||
        max(abs(unit_variance - effective_variance)) >
          contract$MatrixTolerance) {
      stop("A component diagonal is not eligible for truth allocation.",
           call. = FALSE)
    }
    role <- component$UniverseRole
    if (identical(role, "object") &&
        max(abs(operator_diagonal - 1)) > contract$MatrixTolerance) {
      stop("Object truth requires an unscaled operator.", call. = FALSE)
    }
    for (stratum_ordinal in seq_along(strata)) {
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        ScenarioId = truth$ScenarioId,
        StratumOrdinal = stratum_ordinal,
        Stratum = strata[[stratum_ordinal]],
        TargetComponentOrdinal = component_ordinal,
        TargetComponentId = target_id,
        UniverseRole = role,
        FitRepresentationGroup = mfrmr_gtds3m_fit_group(
          target_id, role, repeat_count
        ),
        SourceComponentCount =
          length(component$SourceGeneratorComponents),
        UnitVariance = unit_variance[[stratum_ordinal]],
        EffectiveVariance = effective_variance[[stratum_ordinal]],
        UnitEffectiveDiagonalAbsoluteError = abs(
          unit_variance[[stratum_ordinal]] -
            effective_variance[[stratum_ordinal]]
        ),
        OperatorDiagonal = operator_diagonal[[stratum_ordinal]],
        AllocatedVariance =
          unit_variance[[stratum_ordinal]] *
          operator_diagonal[[stratum_ordinal]],
        CrossStratumCovarianceUsed = FALSE,
        TruthComponentHash = component$TargetComponentHash,
        OperatorHash = operator$OperatorHash,
        stringsAsFactors = FALSE
      )
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3m_coefficients_from_contributions <- function(
    contributions, tolerance = 1e-10) {
  required <- c(
    "ScenarioId", "StratumOrdinal", "Stratum", "TargetComponentId",
    "UniverseRole", "FitRepresentationGroup", "AllocatedVariance"
  )
  if (!is.data.frame(contributions) ||
      !all(required %in% names(contributions)) ||
      nrow(contributions) == 0L ||
      any(!is.finite(contributions$AllocatedVariance))) {
    stop("A finite component-contribution registry is required.",
         call. = FALSE)
  }
  strata <- unique(contributions[c(
    "ScenarioId", "StratumOrdinal", "Stratum"
  )])
  strata <- strata[order(strata$ScenarioId, strata$StratumOrdinal,
                         method = "radix"), , drop = FALSE]
  rows <- lapply(seq_len(nrow(strata)), function(index) {
    key <- strata[index, , drop = FALSE]
    part <- contributions[
      contributions$ScenarioId == key$ScenarioId &
        contributions$Stratum == key$Stratum, , drop = FALSE
    ]
    object <- part$UniverseRole == "object"
    relative_role <- part$UniverseRole == "relative_error"
    absolute_only_role <- part$UniverseRole == "absolute_only"
    universe <- sum(part$AllocatedVariance[object])
    relative <- sum(part$AllocatedVariance[relative_role])
    absolute_only <- sum(part$AllocatedVariance[absolute_only_role])
    absolute <- relative + absolute_only
    status <- if (sum(object) != 1L) {
      "object_role_not_unique"
    } else if (min(part$AllocatedVariance) < -tolerance) {
      "negative_allocated_variance"
    } else if (universe <= tolerance) {
      "nonpositive_universe_variance"
    } else if (universe + relative <= tolerance ||
               universe + absolute <= tolerance) {
      "nonpositive_coefficient_denominator"
    } else {
      "truth_coefficient_ready"
    }
    g <- if (identical(status, "truth_coefficient_ready")) {
      universe / (universe + relative)
    } else NA_real_
    phi <- if (identical(status, "truth_coefficient_ready")) {
      universe / (universe + absolute)
    } else NA_real_
    data.frame(
      ScenarioId = key$ScenarioId,
      StratumOrdinal = key$StratumOrdinal,
      Stratum = key$Stratum,
      UniverseVariance = universe,
      RelativeErrorVariance = relative,
      AbsoluteOnlyVariance = absolute_only,
      AbsoluteErrorVariance = absolute,
      G = g,
      Phi = phi,
      RelativeErrorComponentCount = sum(relative_role),
      AbsoluteOnlyComponentCount = sum(absolute_only_role),
      FitRepresentationBlockCount =
        length(unique(part$FitRepresentationGroup)),
      CoefficientStatus = status,
      PhiNotGreaterThanG =
        is.finite(g) && is.finite(phi) && phi <= g + tolerance,
      TruthCoefficientReady =
        identical(status, "truth_coefficient_ready"),
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3m_fit_blocks <- function(contributions) {
  keys <- unique(contributions[c(
    "ScenarioId", "StratumOrdinal", "Stratum",
    "FitRepresentationGroup", "UniverseRole"
  )])
  keys <- keys[order(
    keys$ScenarioId, keys$StratumOrdinal, keys$FitRepresentationGroup,
    method = "radix"
  ), , drop = FALSE]
  rows <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    part <- contributions[
      contributions$ScenarioId == key$ScenarioId &
        contributions$Stratum == key$Stratum &
        contributions$FitRepresentationGroup ==
          key$FitRepresentationGroup &
        contributions$UniverseRole == key$UniverseRole,
      , drop = FALSE
    ]
    data.frame(
      ScenarioId = key$ScenarioId,
      StratumOrdinal = key$StratumOrdinal,
      Stratum = key$Stratum,
      FitRepresentationGroup = key$FitRepresentationGroup,
      UniverseRole = key$UniverseRole,
      ComponentCount = nrow(part),
      TargetComponentIds =
        paste(part$TargetComponentId, collapse = "+"),
      AllocatedVariance = sum(part$AllocatedVariance),
      CoefficientUsesBlockSum = TRUE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3m_scalar_oracle <- function(
    truth, contract = mfrmr_gtds3m_contract()) {
  profile <- unlist(truth$Profile, use.names = TRUE)
  k <- as.integer(profile[["rater_count"]])
  repeats <- as.integer(profile[["repeat_count"]])
  registry <- truth$TargetComponentRegistry
  target_ids <- registry$TargetComponentId
  strata <- rownames(truth$TargetComponents[[target_ids[[1L]]]]$
                       UnitCovarianceMatrix)
  rows <- lapply(seq_along(strata), function(stratum_ordinal) {
    stratum <- strata[[stratum_ordinal]]
    allocated <- vapply(target_ids, function(target_id) {
      component <- truth$TargetComponents[[target_id]]
      unit_variance <-
        component$UnitCovarianceMatrix[stratum, stratum]
      direct_allocation <- if (identical(target_id, "Object")) {
        1
      } else if (identical(target_id, "Residual")) {
        1 / (k * repeats)
      } else {
        1 / k
      }
      unit_variance * direct_allocation
    }, numeric(1L))
    roles <- registry$UniverseRole[match(target_ids,
                                         registry$TargetComponentId)]
    universe <- sum(allocated[roles == "object"])
    relative <- sum(allocated[roles == "relative_error"])
    absolute_only <- sum(allocated[roles == "absolute_only"])
    absolute <- relative + absolute_only
    data.frame(
      ScenarioId = truth$ScenarioId,
      StratumOrdinal = stratum_ordinal,
      Stratum = stratum,
      UniverseVariance = universe,
      RelativeErrorVariance = relative,
      AbsoluteOnlyVariance = absolute_only,
      AbsoluteErrorVariance = absolute,
      G = universe / (universe + relative),
      Phi = universe / (universe + absolute),
      ConditionAllocation = 1 / k,
      EventAllocation = 1 / (k * repeats),
      OperatorImplementationUsed = FALSE,
      PostMissingnessCountUsed = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3m_oracle_comparison <- function(
    coefficients, oracle, tolerance = 1e-10) {
  metrics <- c(
    "UniverseVariance", "RelativeErrorVariance", "AbsoluteErrorVariance",
    "G", "Phi"
  )
  if (!identical(coefficients[c("ScenarioId", "Stratum")],
                 oracle[c("ScenarioId", "Stratum")])) {
    stop("Adapter and scalar-oracle rows are not aligned.", call. = FALSE)
  }
  rows <- list()
  cursor <- 0L
  for (index in seq_len(nrow(coefficients))) {
    for (metric in metrics) {
      cursor <- cursor + 1L
      actual <- coefficients[[metric]][[index]]
      expected <- oracle[[metric]][[index]]
      rows[[cursor]] <- data.frame(
        ScenarioId = coefficients$ScenarioId[[index]],
        StratumOrdinal = coefficients$StratumOrdinal[[index]],
        Stratum = coefficients$Stratum[[index]],
        MetricId = metric,
        AdapterValue = actual,
        ScalarOracleValue = expected,
        AbsoluteError = abs(actual - expected),
        Tolerance = tolerance,
        OraclePassed = abs(actual - expected) <= tolerance,
        stringsAsFactors = FALSE
      )
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3m_compare_coefficients <- function(left, right, tolerance) {
  order_rows <- function(x) {
    x[order(x$ScenarioId, x$StratumOrdinal, method = "radix"), ,
      drop = FALSE]
  }
  left <- order_rows(left)
  right <- order_rows(right)
  metrics <- c(
    "UniverseVariance", "RelativeErrorVariance", "AbsoluteErrorVariance",
    "G", "Phi"
  )
  identical(left[c("ScenarioId", "Stratum")],
            right[c("ScenarioId", "Stratum")]) &&
    max(abs(as.matrix(left[metrics]) - as.matrix(right[metrics]))) <=
      tolerance
}

mfrmr_gtds3m_perturb_off_diagonal <- function(truth, amount) {
  output <- truth
  for (target_id in names(output$TargetComponents)) {
    matrix <- output$TargetComponents[[target_id]]$UnitCovarianceMatrix
    if (nrow(matrix) > 1L) {
      off_diagonal <- row(matrix) != col(matrix)
      matrix[off_diagonal] <- matrix[off_diagonal] + amount
      output$TargetComponents[[target_id]]$UnitCovarianceMatrix <- matrix
    }
  }
  output
}

mfrmr_gtds3m_project_profile <- function(
    scenario_id, contract = mfrmr_gtds3m_contract(),
    truth_contract = mfrmr_gtds3t_contract(),
    truth_manifest = mfrmr_gtds3t_manifest(),
    operator_contract = mfrmr_gtds3o_contract(),
    operator_manifest = mfrmr_gtds3o_manifest(
      truth_contract = truth_contract, truth_manifest = truth_manifest
    ),
    semantics_manifest = mfrmr_gtds3s_manifest(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE) {
  if (isTRUE(validate)) {
    mfrmr_gtds3m_validate_contract(contract)
    mfrmr_gtds3t_assert_manifest(truth_manifest, truth_contract)
    mfrmr_gtds3o_assert_manifest(operator_manifest, operator_contract)
  }
  compilation <- mfrmr_gtds3c_compile_profile(
    scenario_id, compiler_contract, coverage, validate = FALSE
  )
  truth <- mfrmr_gtds3t_project_profile(
    scenario_id, truth_contract, semantics_manifest,
    mfrmr_gtds3b_contract(), compiler_contract, coverage,
    validate = FALSE
  )
  assignments <- compilation$AssignmentRegistry
  strata <- compilation$StratumRegistry$Stratum
  target_ids <- truth$TargetComponentRegistry$TargetComponentId
  operators <- stats::setNames(lapply(target_ids, function(target_id) {
    mfrmr_gtds3o_operator_from_assignments(
      assignments, strata, target_id, operator_contract,
      validate = FALSE
    )
  }), target_ids)
  truth_row <- truth_manifest$ProfileTruthRegistry[
    truth_manifest$ProfileTruthRegistry$ScenarioId == scenario_id,
    , drop = FALSE
  ]
  operator_rows <- operator_manifest$TargetComponentOperatorRegistry[
    operator_manifest$TargetComponentOperatorRegistry$ScenarioId ==
      scenario_id, , drop = FALSE
  ]
  parent_truth_match <- nrow(truth_row) == 1L &&
    identical(truth$ProjectionHash, truth_row$ProjectionHash[[1L]])
  parent_operator_match <- nrow(operator_rows) == length(target_ids) &&
    all(vapply(target_ids, function(target_id) {
      row <- operator_rows[
        operator_rows$TargetComponentId == target_id, , drop = FALSE
      ]
      nrow(row) == 1L &&
        identical(operators[[target_id]]$OperatorHash,
                  row$OperatorHash[[1L]])
    }, logical(1L)))
  contributions <- mfrmr_gtds3m_component_contributions(
    truth, operators, contract
  )
  coefficients <- mfrmr_gtds3m_coefficients_from_contributions(
    contributions, contract$MatrixTolerance
  )
  fit_blocks <- mfrmr_gtds3m_fit_blocks(contributions)
  oracle <- mfrmr_gtds3m_scalar_oracle(truth, contract)
  comparisons <- mfrmr_gtds3m_oracle_comparison(
    coefficients, oracle, contract$MatrixTolerance
  )
  reordered <- mfrmr_gtds3m_coefficients_from_contributions(
    contributions[rev(seq_len(nrow(contributions))), , drop = FALSE],
    contract$MatrixTolerance
  )
  scaled <- contributions
  scale_columns <- c("UnitVariance", "EffectiveVariance",
                     "AllocatedVariance")
  scaled[scale_columns] <- lapply(
    scaled[scale_columns], function(value) {
      value * contract$ScaleInvarianceFactor
    }
  )
  scaled_coefficients <- mfrmr_gtds3m_coefficients_from_contributions(
    scaled, contract$MatrixTolerance
  )
  perturbed_truth <- mfrmr_gtds3m_perturb_off_diagonal(
    truth, contract$OffDiagonalPerturbation
  )
  perturbed_contributions <- mfrmr_gtds3m_component_contributions(
    perturbed_truth, operators, contract
  )
  perturbed_coefficients <- mfrmr_gtds3m_coefficients_from_contributions(
    perturbed_contributions, contract$MatrixTolerance
  )
  metric_columns <- c("G", "Phi")
  scale_invariant <- max(abs(
    as.matrix(coefficients[metric_columns]) -
      as.matrix(scaled_coefficients[metric_columns])
  )) <= contract$MatrixTolerance
  variance_columns <- c(
    "UniverseVariance", "RelativeErrorVariance", "AbsoluteErrorVariance"
  )
  scale_variance_error <- max(abs(
    as.matrix(scaled_coefficients[variance_columns]) -
      contract$ScaleInvarianceFactor *
      as.matrix(coefficients[variance_columns])
  ))
  profile <- unlist(compilation$Profile, use.names = TRUE)
  nested <- identical(profile[["crossing"]], "nested")
  repeat_one <- as.integer(profile[["repeat_count"]]) == 1L
  combined <- fit_blocks$FitRepresentationGroup ==
    contract$OneRepeatFitRepresentation
  fit_representation_qualified <- if (repeat_one) {
    all(vapply(strata, function(stratum) {
      block <- fit_blocks[
        fit_blocks$Stratum == stratum & combined, , drop = FALSE
      ]
      nrow(block) == 1L && block$ComponentCount[[1L]] == 2L &&
        grepl("Residual", block$TargetComponentIds[[1L]], fixed = TRUE)
    }, logical(1L)))
  } else !any(combined)
  nested_relation <- if (nested) {
    max(abs(coefficients$Phi - coefficients$G)) <=
      contract$MatrixTolerance
  } else all(coefficients$Phi < coefficients$G)
  summary <- list(
    ScenarioId = scenario_id,
    Crossing = as.character(profile[["crossing"]]),
    RepeatCount = as.integer(profile[["repeat_count"]]),
    StratumCount = length(strata),
    ComponentContributionCount = nrow(contributions),
    FitRepresentationBlockCount = nrow(fit_blocks),
    ScalarOracleComparisonCount = nrow(comparisons),
    ParentTruthProjectionHashMatched = parent_truth_match,
    ParentOperatorHashesMatched = parent_operator_match,
    UnitEffectiveDiagonalEquivalent = all(
      contributions$UnitEffectiveDiagonalAbsoluteError <=
        contract$MatrixTolerance
    ),
    ScalarOracleQualified = all(comparisons$OraclePassed),
    ComponentAndStratumOrderInvariant =
      mfrmr_gtds3m_compare_coefficients(
        coefficients, reordered, contract$MatrixTolerance
      ),
    CommonPositiveScaleInvariant = scale_invariant &&
      scale_variance_error <= contract$MatrixTolerance,
    OffDiagonalPerturbationInvariant =
      mfrmr_gtds3m_compare_coefficients(
        coefficients, perturbed_coefficients,
        contract$MatrixTolerance
      ),
    FitRepresentationQualified = fit_representation_qualified,
    NestedPhiEqualsGOrCrossedPhiLessThanG = nested_relation,
    TruthCoefficientReady = all(coefficients$TruthCoefficientReady),
    FittedCoefficientComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE
  )
  payload <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ScenarioId = scenario_id,
    Profile = compilation$Profile,
    TruthProjectionHash = truth$ProjectionHash,
    OperatorHashes = vapply(
      operators, function(x) x$OperatorHash, character(1L)
    ),
    ComponentContributionRegistry = contributions,
    FitRepresentationBlockRegistry = fit_blocks,
    StratumCoefficientRegistry = coefficients,
    IndependentScalarOracleRegistry = oracle,
    ScalarOracleComparisonRegistry = comparisons,
    Summary = summary
  )
  structure(c(payload, list(
    ProfileTruthCoefficientHash = mfrmr_gtds3m_hash(payload)
  )), class = c("mfrmr_gtds3m_profile", "list"))
}

mfrmr_gtds3m_gate_registry <- function(
    profiles, contributions, coefficients, comparisons) {
  nested <- coefficients$Crossing == "nested"
  crossed <- !nested
  pass <- c(
    all(profiles$ParentTruthProjectionHashMatched),
    all(profiles$ParentOperatorHashesMatched),
    nrow(profiles) == 21L,
    nrow(contributions) == 173L &&
      all(contributions$UnitEffectiveDiagonalAbsoluteError <= 1e-10),
    nrow(coefficients) == 47L &&
      all(coefficients$TruthCoefficientReady),
    nrow(comparisons) == 235L && all(comparisons$OraclePassed),
    all(abs(coefficients$Phi[nested] - coefficients$G[nested]) <=
          1e-10) &&
      all(coefficients$Phi[crossed] < coefficients$G[crossed]),
    all(profiles$ComponentAndStratumOrderInvariant) &&
      all(profiles$CommonPositiveScaleInvariant) &&
      all(profiles$OffDiagonalPerturbationInvariant) &&
      all(profiles$FitRepresentationQualified),
    FALSE, FALSE
  )
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "parent_truth_identity", "parent_operator_identity",
      "all_profile_metric_coverage", "component_allocation_coverage",
      "stratum_truth_coefficient_coverage", "independent_scalar_oracle",
      "estimand_role_relationships", "metric_and_fit_block_invariance",
      "superseding_unopened_plan", "execution_bridge_and_reconciliation"
    ),
    GatePassed = pass,
    Blocking = !pass,
    TruthMetricOnly = TRUE,
    ExecutionAttempted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3m_gap_registry <- function() {
  data.frame(
    GapOrdinal = 1:2,
    GapId = c(
      "superseding_unopened_plan",
      "identity_bound_execution_bridge_and_reconciliation"
    ),
    GapReason = c(
      paste(
        "issue_a_new_unopened_plan_binding_truth_projection_operator_and",
        "truth_metric_identities_without_mutating_the_existing_plan", sep = "_"
      ),
      paste(
        "build_and_shadow_qualify_generation_fit_metric_terminal_resource",
        "orchestration_then_repeat_nonexecuting_reconciliation", sep = "_"
      )
    ),
    GapOpen = TRUE,
    ExecutionRequiredToClose = c(FALSE, TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3m_manifest <- function(
    contract = mfrmr_gtds3m_contract(),
    truth_contract = mfrmr_gtds3t_contract(),
    truth_manifest = mfrmr_gtds3t_manifest(),
    operator_contract = mfrmr_gtds3o_contract(),
    operator_manifest = mfrmr_gtds3o_manifest(
      truth_contract = truth_contract, truth_manifest = truth_manifest
    ),
    semantics_manifest = mfrmr_gtds3s_manifest(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3m_validate_contract(contract)
  mfrmr_gtds3t_assert_manifest(truth_manifest, truth_contract)
  mfrmr_gtds3o_assert_manifest(operator_manifest, operator_contract)
  if (!identical(truth_contract$ContractHash,
                 contract$ParentTruthContractHash) ||
      !identical(truth_manifest$ManifestHash,
                 contract$ParentTruthManifestHash) ||
      !identical(operator_contract$ContractHash,
                 contract$ParentOperatorContractHash) ||
      !identical(operator_manifest$ManifestHash,
                 contract$ParentOperatorManifestHash)) {
    stop("A parent identity of the truth metric changed.", call. = FALSE)
  }
  projected <- lapply(coverage$ScenarioRegistry$ScenarioId, function(id) {
    mfrmr_gtds3m_project_profile(
      id, contract, truth_contract, truth_manifest,
      operator_contract, operator_manifest, semantics_manifest,
      compiler_contract, coverage, validate = FALSE
    )
  })
  profile_rows <- lapply(seq_along(projected), function(index) {
    summary <- projected[[index]]$Summary
    data.frame(
      ProfileMetricOrdinal = index,
      ScenarioId = summary$ScenarioId,
      Crossing = summary$Crossing,
      RepeatCount = summary$RepeatCount,
      StratumCount = summary$StratumCount,
      ComponentContributionCount = summary$ComponentContributionCount,
      FitRepresentationBlockCount = summary$FitRepresentationBlockCount,
      ScalarOracleComparisonCount = summary$ScalarOracleComparisonCount,
      ParentTruthProjectionHashMatched =
        summary$ParentTruthProjectionHashMatched,
      ParentOperatorHashesMatched = summary$ParentOperatorHashesMatched,
      UnitEffectiveDiagonalEquivalent =
        summary$UnitEffectiveDiagonalEquivalent,
      ScalarOracleQualified = summary$ScalarOracleQualified,
      ComponentAndStratumOrderInvariant =
        summary$ComponentAndStratumOrderInvariant,
      CommonPositiveScaleInvariant =
        summary$CommonPositiveScaleInvariant,
      OffDiagonalPerturbationInvariant =
        summary$OffDiagonalPerturbationInvariant,
      FitRepresentationQualified =
        summary$FitRepresentationQualified,
      NestedPhiEqualsGOrCrossedPhiLessThanG =
        summary$NestedPhiEqualsGOrCrossedPhiLessThanG,
      TruthCoefficientReady = summary$TruthCoefficientReady,
      FittedCoefficientComputed = FALSE,
      ExploratoryExecutionAllowed = FALSE,
      ProfileTruthCoefficientHash =
        projected[[index]]$ProfileTruthCoefficientHash,
      stringsAsFactors = FALSE
    )
  })
  profiles <- do.call(rbind, profile_rows)
  contributions <- do.call(rbind, lapply(
    projected, function(x) x$ComponentContributionRegistry
  ))
  fit_blocks <- do.call(rbind, lapply(
    projected, function(x) x$FitRepresentationBlockRegistry
  ))
  coefficients <- do.call(rbind, lapply(seq_along(projected), function(index) {
    output <- projected[[index]]$StratumCoefficientRegistry
    output$Crossing <- projected[[index]]$Summary$Crossing
    output$RepeatCount <- projected[[index]]$Summary$RepeatCount
    output
  }))
  oracle <- do.call(rbind, lapply(
    projected, function(x) x$IndependentScalarOracleRegistry
  ))
  comparisons <- do.call(rbind, lapply(
    projected, function(x) x$ScalarOracleComparisonRegistry
  ))
  row.names(profiles) <- row.names(contributions) <-
    row.names(fit_blocks) <- row.names(coefficients) <-
    row.names(oracle) <- row.names(comparisons) <- NULL
  profiles$ProfileMetricOrdinal <- seq_len(nrow(profiles))
  contributions$ContributionOrdinal <- seq_len(nrow(contributions))
  fit_blocks$FitBlockOrdinal <- seq_len(nrow(fit_blocks))
  coefficients$StratumCoefficientOrdinal <- seq_len(nrow(coefficients))
  oracle$ScalarOracleOrdinal <- seq_len(nrow(oracle))
  comparisons$OracleComparisonOrdinal <- seq_len(nrow(comparisons))
  gates <- mfrmr_gtds3m_gate_registry(
    profiles, contributions, coefficients, comparisons
  )
  gaps <- mfrmr_gtds3m_gap_registry()
  nested <- coefficients$Crossing == "nested"
  crossed <- !nested
  repeat_one <- coefficients$RepeatCount == 1L
  summary <- list(
    ProfileCount = nrow(profiles),
    QualifiedProfileCount = sum(
      profiles$TruthCoefficientReady &
        profiles$ScalarOracleQualified &
        profiles$FitRepresentationQualified
    ),
    StratumCoefficientCount = nrow(coefficients),
    QualifiedStratumCoefficientCount =
      sum(coefficients$TruthCoefficientReady),
    CrossedStratumCoefficientCount = sum(crossed),
    NestedStratumCoefficientCount = sum(nested),
    ComponentContributionCount = nrow(contributions),
    FitRepresentationBlockCount = nrow(fit_blocks),
    OneRepeatStratumCoefficientCount = sum(repeat_one),
    ScalarOracleComparisonCount = nrow(comparisons),
    ScalarOracleQualifiedComparisonCount =
      sum(comparisons$OraclePassed),
    NestedPhiEqualsGCount = sum(
      nested & abs(coefficients$Phi - coefficients$G) <=
        contract$MatrixTolerance
    ),
    CrossedPhiLessThanGCount = sum(
      crossed & coefficients$Phi < coefficients$G
    ),
    InvarianceQualifiedProfileCount = sum(
      profiles$ComponentAndStratumOrderInvariant &
        profiles$CommonPositiveScaleInvariant &
        profiles$OffDiagonalPerturbationInvariant
    ),
    FitRepresentationQualifiedProfileCount =
      sum(profiles$FitRepresentationQualified),
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    OpenGapCount = sum(gaps$GapOpen),
    CurrentDisposition =
      "separate_univariate_truth_metric_qualified_plan_and_worker_required",
    NextAction = paste(
      "issue_a_new_unopened_plan_binding_the_qualified_truth_projection",
      "allocation_operator_and_truth_metric_identities_without_mutating",
      "the_existing_plan_then_shadow_qualify_the_execution_bridge", sep = "_"
    ),
    Planned855RngStreamOpened = FALSE,
    ResponseInspected = FALSE,
    BackendCallMade = FALSE,
    FitReturned = FALSE,
    TruthCoefficientComputed = TRUE,
    FittedCoefficientComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE
  )
  payload <- list(
    Contract = contract,
    ParentTruthManifestHash = truth_manifest$ManifestHash,
    ParentOperatorManifestHash = operator_manifest$ManifestHash,
    ProfileTruthMetricRegistry = profiles,
    ComponentContributionRegistry = contributions,
    FitRepresentationBlockRegistry = fit_blocks,
    StratumTruthCoefficientRegistry = coefficients,
    IndependentScalarOracleRegistry = oracle,
    ScalarOracleComparisonRegistry = comparisons,
    ReadinessGateRegistry = gates,
    OpenGapRegistry = gaps,
    Summary = summary
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtds3m_hash(payload)
  )), class = c("mfrmr_gtds3m_manifest", "list"))
}

mfrmr_gtds3m_assert_manifest <- function(
    manifest, contract = mfrmr_gtds3m_contract()) {
  if (!inherits(manifest, "mfrmr_gtds3m_manifest")) {
    stop("A typed D-SIM-3 truth-metric manifest is required.",
         call. = FALSE)
  }
  mfrmr_gtds3m_validate_contract(contract)
  profiles <- manifest$ProfileTruthMetricRegistry
  contributions <- manifest$ComponentContributionRegistry
  coefficients <- manifest$StratumTruthCoefficientRegistry
  comparisons <- manifest$ScalarOracleComparisonRegistry
  gates <- manifest$ReadinessGateRegistry
  nested <- coefficients$Crossing == "nested"
  crossed <- !nested
  valid <- identical(manifest$Contract, contract) &&
    identical(manifest$ParentTruthManifestHash,
              contract$ParentTruthManifestHash) &&
    identical(manifest$ParentOperatorManifestHash,
              contract$ParentOperatorManifestHash) &&
    identical(nrow(profiles), 21L) &&
    identical(nrow(contributions), 173L) &&
    identical(nrow(manifest$FitRepresentationBlockRegistry), 160L) &&
    identical(nrow(coefficients), 47L) &&
    identical(sum(crossed), 32L) &&
    identical(sum(nested), 15L) &&
    identical(sum(coefficients$RepeatCount == 1L), 13L) &&
    identical(nrow(comparisons), 235L) &&
    all(profiles$ParentTruthProjectionHashMatched) &&
    all(profiles$ParentOperatorHashesMatched) &&
    all(profiles$UnitEffectiveDiagonalEquivalent) &&
    all(profiles$ScalarOracleQualified) &&
    all(profiles$ComponentAndStratumOrderInvariant) &&
    all(profiles$CommonPositiveScaleInvariant) &&
    all(profiles$OffDiagonalPerturbationInvariant) &&
    all(profiles$FitRepresentationQualified) &&
    all(profiles$NestedPhiEqualsGOrCrossedPhiLessThanG) &&
    all(profiles$TruthCoefficientReady) &&
    !any(profiles$FittedCoefficientComputed) &&
    all(contributions$UnitEffectiveDiagonalAbsoluteError <=
          contract$MatrixTolerance) &&
    !any(contributions$CrossStratumCovarianceUsed) &&
    all(coefficients$TruthCoefficientReady) &&
    all(coefficients$PhiNotGreaterThanG) &&
    all(abs(coefficients$Phi[nested] - coefficients$G[nested]) <=
          contract$MatrixTolerance) &&
    all(coefficients$Phi[crossed] < coefficients$G[crossed]) &&
    all(comparisons$OraclePassed) &&
    identical(gates$GatePassed, c(rep(TRUE, 8L), FALSE, FALSE)) &&
    identical(
      manifest$Summary$CurrentDisposition,
      "separate_univariate_truth_metric_qualified_plan_and_worker_required"
    ) &&
    !isTRUE(manifest$Summary$Planned855RngStreamOpened) &&
    !isTRUE(manifest$Summary$ResponseInspected) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitReturned) &&
    isTRUE(manifest$Summary$TruthCoefficientComputed) &&
    !isTRUE(manifest$Summary$FittedCoefficientComputed) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady) &&
    identical(
      manifest$ManifestHash,
      mfrmr_gtds3m_hash(
        manifest[setdiff(names(manifest), "ManifestHash")]
      )
    )
  if (!valid) {
    stop("The D-SIM-3 truth-metric manifest was altered.", call. = FALSE)
  }
  invisible(TRUE)
}
