# Internal D-SIM-3 separate-univariate incidence-aware allocation operator.
#
# The route returns one coefficient per stratum and does not recover
# cross-stratum covariance.  Its D-study operator is therefore diagonal.  Each
# diagonal is derived from registered structural assignments before any
# missingness: equal weights within object, then the mean squared-weight norm
# across objects.  No response, fitted value, or backend result is inspected.

mfrmr_gtds3o_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3c_compile_profile",
    "mfrmr_gtds3b_matrix_audit", "mfrmr_gtds3s_manifest",
    "mfrmr_gtds3s_assert_manifest", "mfrmr_gtds3t_contract",
    "mfrmr_gtds3t_manifest", "mfrmr_gtds3t_assert_manifest",
    "mfrmr_gtds3t_project_profile"
  )
  target <- environment(mfrmr_gtds3o_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 compiler, semantics, and truth chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3o_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3o_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-SEPARATE-UNIV-ALLOCATION-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentTruthContractHash =
      "fb66bd15526afa1f18f613dcbc4b0d470350bcf803a642fcde537602d017f327",
    ParentTruthManifestHash =
      "97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5",
    ParentSemanticsContractHash =
      "ed0eda8a02cd4ea4dc46084f56f6683ac967da0705c08e8fb4f804cf6ed94adf",
    ParentSemanticsManifestHash =
      "815d29f76640f2886b572ffda418582a02135d51cd50dadbab5ff6e4308bbb2f"
  )
}

mfrmr_gtds3o_component_rule_registry <- function() {
  data.frame(
    ComponentClass = c("object", "condition", "event"),
    TargetComponentIds = c(
      "Object", "Rater|Object:Rater|NestedCondition", "Residual"
    ),
    StructuralIdentity = c(
      "ObjectId", "ObjectId_by_ConditionId", "ObjectId_by_EventId"
    ),
    WithinObjectWeight = c(
      "one", "one_over_registered_conditions",
      "one_over_registered_events"
    ),
    DiagonalDefinition = c(
      "one",
      "mean_over_objects_of_sum_squared_condition_weights",
      "mean_over_objects_of_sum_squared_event_weights"
    ),
    CrossStratumEntry = "zero_not_recovered_by_separate_univariate_route",
    PostMissingnessCountAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3o_contract <- function() {
  mfrmr_gtds3o_require_primitives()
  identity <- mfrmr_gtds3o_identity()
  payload <- c(identity, list(
    RouteId = "separate_univariate",
    ExpectedProfileCount = 21L,
    ExpectedTargetComponentOperatorCount = 78L,
    ExpectedStratumDiagonalCount = 173L,
    ExpectedLegacyComparisonCount = 94L,
    ExpectedConditionLegacyEquivalentCount = 21L,
    ExpectedConditionLegacyMismatchCount = 26L,
    ExpectedEventLegacyEquivalentCount = 0L,
    ExpectedEventLegacyMismatchCount = 47L,
    ComponentRuleRegistry = mfrmr_gtds3o_component_rule_registry(),
    StructuralAssignmentStage = "pre_missingness_registered_assignment",
    EqualWeightWithinObjectRequired = TRUE,
    MeanSquaredWeightNormAcrossObjectsRequired = TRUE,
    CrossStratumCovarianceRecovered = FALSE,
    OffDiagonalPolicy = "exact_zero_not_estimated",
    ObjectOperatorDiagonal = 1,
    ConditionOracle = "one_over_registered_rater_count",
    EventOracle =
      "one_over_registered_rater_count_times_registered_repeat_count",
    ExistingGlobalConditionOperatorMaySubstitute = FALSE,
    ExistingGlobalEventOperatorMaySubstitute = FALSE,
    RowOrderInvariantRequired = TRUE,
    IdentityLabelInvariantRequired = TRUE,
    MissingnessMaskInvariantRequired = TRUE,
    PsdRequired = TRUE,
    MatrixTolerance = 1e-10,
    ScenarioSpecificPatchCount = 0L,
    OperatorMayUseRng = FALSE,
    OperatorMayInspectResponse = FALSE,
    OperatorMayCallBackend = FALSE,
    OperatorMayFit = FALSE,
    OperatorMayComputeCoefficient = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3o_hash(payload)
  )), class = c("mfrmr_gtds3o_contract", "list"))
}

mfrmr_gtds3o_validate_contract <- function(
    contract = mfrmr_gtds3o_contract()) {
  canonical <- mfrmr_gtds3o_contract()
  rules <- contract$ComponentRuleRegistry
  valid <- inherits(contract, "mfrmr_gtds3o_contract") &&
    identical(contract, canonical) &&
    is.data.frame(rules) && nrow(rules) == 3L &&
    identical(rules$ComponentClass, c("object", "condition", "event")) &&
    !any(rules$PostMissingnessCountAllowed) &&
    identical(contract$RouteId, "separate_univariate") &&
    identical(contract$ExpectedProfileCount, 21L) &&
    identical(contract$ExpectedTargetComponentOperatorCount, 78L) &&
    identical(contract$ExpectedStratumDiagonalCount, 173L) &&
    identical(contract$ExpectedLegacyComparisonCount, 94L) &&
    isTRUE(contract$EqualWeightWithinObjectRequired) &&
    isTRUE(contract$MeanSquaredWeightNormAcrossObjectsRequired) &&
    !isTRUE(contract$CrossStratumCovarianceRecovered) &&
    !isTRUE(contract$ExistingGlobalConditionOperatorMaySubstitute) &&
    !isTRUE(contract$ExistingGlobalEventOperatorMaySubstitute) &&
    isTRUE(contract$RowOrderInvariantRequired) &&
    isTRUE(contract$IdentityLabelInvariantRequired) &&
    isTRUE(contract$MissingnessMaskInvariantRequired) &&
    isTRUE(contract$PsdRequired) &&
    identical(contract$ScenarioSpecificPatchCount, 0L) &&
    !isTRUE(contract$OperatorMayUseRng) &&
    !isTRUE(contract$OperatorMayInspectResponse) &&
    !isTRUE(contract$OperatorMayCallBackend) &&
    !isTRUE(contract$OperatorMayFit) &&
    !isTRUE(contract$OperatorMayComputeCoefficient) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 incidence-allocation contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3o_component_class <- function(target_component_id) {
  target_component_id <- as.character(target_component_id)
  if (identical(target_component_id, "Object")) return("object")
  if (target_component_id %in%
      c("Rater", "Object:Rater", "NestedCondition")) {
    return("condition")
  }
  if (identical(target_component_id, "Residual")) return("event")
  stop("The target estimand component has no allocation rule.",
       call. = FALSE)
}

mfrmr_gtds3o_stratum_weight_norm <- function(
    assignments, stratum, component_class) {
  part <- assignments[assignments$Stratum == stratum, , drop = FALSE]
  if (nrow(part) == 0L) {
    stop("Every registered stratum requires structural assignments.",
         call. = FALSE)
  }
  if (component_class == "object") {
    structural <- unique(part["ObjectId"])
    counts <- stats::setNames(rep(1L, nrow(structural)),
                              structural$ObjectId)
    identity_count <- nrow(structural)
  } else {
    identity_col <- if (component_class == "condition") {
      "ConditionId"
    } else "EventId"
    structural <- unique(part[c("ObjectId", identity_col)])
    counts <- table(structural$ObjectId)
    identity_count <- length(unique(structural[[identity_col]]))
  }
  counts <- as.integer(counts)
  if (length(counts) == 0L || any(counts < 1L)) {
    stop("Within-object structural exposure must be positive.",
         call. = FALSE)
  }
  squared_norm <- 1 / counts
  data.frame(
    Stratum = stratum,
    ComponentClass = component_class,
    StructuralObjectCount = length(counts),
    StructuralIdentityCount = identity_count,
    MinimumExposurePerObject = min(counts),
    MaximumExposurePerObject = max(counts),
    MinimumObjectSquaredWeightNorm = min(squared_norm),
    MaximumObjectSquaredWeightNorm = max(squared_norm),
    OperatorDiagonal = mean(squared_norm),
    StructuralRowCount = nrow(part),
    ScheduledRowCount = sum(part$ResponseScheduled),
    PostMissingnessCountUsed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3o_operator_from_assignments <- function(
    assignments, strata, target_component_id,
    contract = mfrmr_gtds3o_contract(), validate = TRUE) {
  if (isTRUE(validate)) mfrmr_gtds3o_validate_contract(contract)
  required <- c(
    "Stratum", "ObjectId", "ConditionId", "EventId",
    "ResponseScheduled"
  )
  if (!is.data.frame(assignments) ||
      !all(required %in% names(assignments))) {
    stop("Compiled structural assignments are required.", call. = FALSE)
  }
  strata <- as.character(strata)
  if (length(strata) == 0L || anyNA(strata) || anyDuplicated(strata)) {
    stop("Ordered unique strata are required.", call. = FALSE)
  }
  component_class <- mfrmr_gtds3o_component_class(target_component_id)
  details <- do.call(rbind, lapply(strata, function(stratum) {
    mfrmr_gtds3o_stratum_weight_norm(
      assignments, stratum, component_class
    )
  }))
  row.names(details) <- NULL
  operator <- diag(details$OperatorDiagonal, nrow = length(strata))
  dimnames(operator) <- list(strata, strata)
  audit <- mfrmr_gtds3b_matrix_audit(
    operator, paste0("SeparateUnivariateOperator/", target_component_id),
    tolerance = contract$MatrixTolerance
  )
  if (any(operator[row(operator) != col(operator)] != 0) ||
      any(diag(operator) <= 0) || !all(audit$PositiveSemidefinite)) {
    stop("The separate-univariate allocation operator is invalid.",
         call. = FALSE)
  }
  payload <- list(
    TargetComponentId = target_component_id,
    ComponentClass = component_class,
    Strata = strata,
    OperatorMatrix = operator,
    StratumWeightNormRegistry = details,
    MatrixAudit = audit,
    CrossStratumCovarianceRecovered = FALSE,
    StructuralAssignmentsUsed = TRUE,
    PostMissingnessCountUsed = FALSE
  )
  structure(c(payload, list(
    OperatorHash = mfrmr_gtds3o_hash(payload)
  )), class = c("mfrmr_gtds3o_operator", "list"))
}

mfrmr_gtds3o_direct_oracle <- function(profile, component_class) {
  rater_count <- as.integer(profile[["rater_count"]])
  repeat_count <- as.integer(profile[["repeat_count"]])
  if (component_class == "object") return(1)
  if (component_class == "condition") return(1 / rater_count)
  1 / (rater_count * repeat_count)
}

mfrmr_gtds3o_relabel_assignments <- function(assignments) {
  output <- assignments
  object_levels <- sort(unique(output$ObjectId), method = "radix")
  condition_levels <- sort(unique(output$ConditionId), method = "radix")
  event_levels <- sort(unique(output$EventId), method = "radix")
  output$ObjectId <- paste0(
    "ObjectLabel", match(output$ObjectId, rev(object_levels))
  )
  output$ConditionId <- paste0(
    "ConditionLabel", match(output$ConditionId, rev(condition_levels))
  )
  output$EventId <- paste0(
    "EventLabel", match(output$EventId, rev(event_levels))
  )
  output
}

mfrmr_gtds3o_project_profile <- function(
    scenario_id, contract = mfrmr_gtds3o_contract(),
    truth_contract = mfrmr_gtds3t_contract(),
    truth_manifest = mfrmr_gtds3t_manifest(),
    semantics_manifest = mfrmr_gtds3s_manifest(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE) {
  if (isTRUE(validate)) {
    mfrmr_gtds3o_validate_contract(contract)
    mfrmr_gtds3t_assert_manifest(truth_manifest, truth_contract)
    mfrmr_gtds3s_assert_manifest(semantics_manifest)
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
      assignments, strata, target_id, contract, validate = FALSE
    )
  }), target_ids)
  reversed <- assignments[rev(seq_len(nrow(assignments))), , drop = FALSE]
  masked <- assignments
  masked$ResponseScheduled <- !masked$ResponseScheduled
  relabelled <- mfrmr_gtds3o_relabel_assignments(assignments)
  checks <- lapply(target_ids, function(target_id) {
    operator <- operators[[target_id]]
    reversed_operator <- mfrmr_gtds3o_operator_from_assignments(
      reversed, strata, target_id, contract, validate = FALSE
    )
    masked_operator <- mfrmr_gtds3o_operator_from_assignments(
      masked, strata, target_id, contract, validate = FALSE
    )
    relabelled_operator <- mfrmr_gtds3o_operator_from_assignments(
      relabelled, strata, target_id, contract, validate = FALSE
    )
    expected <- mfrmr_gtds3o_direct_oracle(
      unlist(compilation$Profile, use.names = TRUE),
      operator$ComponentClass
    )
    data.frame(
      TargetComponentId = target_id,
      ComponentClass = operator$ComponentClass,
      DirectOracleExpected = expected,
      DirectOracleMaximumError = max(abs(
        diag(operator$OperatorMatrix) - expected
      )),
      RowOrderInvariant = identical(
        operator$OperatorMatrix, reversed_operator$OperatorMatrix
      ),
      MissingnessMaskInvariant = identical(
        operator$OperatorMatrix, masked_operator$OperatorMatrix
      ),
      IdentityLabelInvariant = identical(
        operator$OperatorMatrix, relabelled_operator$OperatorMatrix
      ),
      PositiveSemidefinite = all(
        operator$MatrixAudit$PositiveSemidefinite
      ),
      OffDiagonalExactZero = all(
        operator$OperatorMatrix[
          row(operator$OperatorMatrix) != col(operator$OperatorMatrix)
        ] == 0
      ),
      stringsAsFactors = FALSE
    )
  })
  checks <- do.call(rbind, checks)
  row.names(checks) <- NULL
  summary <- list(
    ScenarioId = scenario_id,
    Crossing = as.character(compilation$Profile$crossing),
    StratumCount = length(strata),
    TargetComponentOperatorCount = length(operators),
    StratumDiagonalCount = sum(vapply(
      operators, function(x) nrow(x$StratumWeightNormRegistry), integer(1L)
    )),
    DirectOracleQualified = all(
      checks$DirectOracleMaximumError <= contract$MatrixTolerance
    ),
    RowOrderInvariant = all(checks$RowOrderInvariant),
    MissingnessMaskInvariant = all(checks$MissingnessMaskInvariant),
    IdentityLabelInvariant = all(checks$IdentityLabelInvariant),
    PositiveSemidefinite = all(checks$PositiveSemidefinite),
    OffDiagonalExactZero = all(checks$OffDiagonalExactZero),
    SeparateUnivariateOperatorQualified = all(c(
      checks$DirectOracleMaximumError <= contract$MatrixTolerance,
      checks$RowOrderInvariant, checks$MissingnessMaskInvariant,
      checks$IdentityLabelInvariant, checks$PositiveSemidefinite,
      checks$OffDiagonalExactZero
    )),
    CoefficientComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE
  )
  payload <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ScenarioId = scenario_id,
    TruthProjectionHash = truth$ProjectionHash,
    Profile = compilation$Profile,
    Operators = operators,
    InvarianceOracleRegistry = checks,
    Summary = summary
  )
  structure(c(payload, list(
    ProfileOperatorHash = mfrmr_gtds3o_hash(payload)
  )), class = c("mfrmr_gtds3o_profile", "list"))
}

mfrmr_gtds3o_legacy_comparison <- function(
    scenario_id, compilation, condition_operator, event_operator,
    contract = mfrmr_gtds3o_contract()) {
  assignments <- compilation$AssignmentRegistry
  crossing <- as.character(compilation$Profile$crossing)
  rows <- list(); cursor <- 0L
  for (stratum in compilation$StratumRegistry$Stratum) {
    part <- assignments[assignments$Stratum == stratum, , drop = FALSE]
    object_count <- length(unique(part$ObjectId))
    desired_condition <- condition_operator$OperatorMatrix[stratum, stratum]
    desired_event <- event_operator$OperatorMatrix[stratum, stratum]
    legacy_condition <- 1 / length(unique(part$ConditionId))
    legacy_event <- 1 / length(unique(part$EventId))
    expected_condition_ratio <- switch(
      crossing, fully_crossed = 1,
      partially_crossed = 2, nested = object_count,
      stop("Unknown crossing.", call. = FALSE)
    )
    for (operator_class in c("condition", "event")) {
      cursor <- cursor + 1L
      desired <- if (operator_class == "condition") {
        desired_condition
      } else desired_event
      legacy <- if (operator_class == "condition") {
        legacy_condition
      } else legacy_event
      expected_ratio <- if (operator_class == "condition") {
        expected_condition_ratio
      } else object_count
      rows[[cursor]] <- data.frame(
        ScenarioId = scenario_id,
        Stratum = stratum,
        Crossing = crossing,
        OperatorClass = operator_class,
        StructuralObjectCount = object_count,
        IncidenceAwareDiagonal = desired,
        LegacyGlobalIdentityDiagonal = legacy,
        IncidenceToLegacyRatio = desired / legacy,
        ExpectedRatio = expected_ratio,
        RatioOracleMaximumError = abs(desired / legacy - expected_ratio),
        LegacyEquivalent = abs(desired - legacy) <= contract$MatrixTolerance,
        DiagnosisQualified =
          abs(desired / legacy - expected_ratio) <= contract$MatrixTolerance,
        stringsAsFactors = FALSE
      )
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3o_gate_registry <- function(
    profiles, operators, diagonals, legacy) {
  condition <- legacy$OperatorClass == "condition"
  event <- legacy$OperatorClass == "event"
  pass <- c(
    TRUE,
    nrow(operators) == 78L && nrow(diagonals) == 173L,
    all(diagonals$DirectOracleMaximumError <= 1e-10),
    all(operators$PositiveSemidefinite & operators$OffDiagonalExactZero),
    all(profiles$MissingnessMaskInvariant),
    all(profiles$RowOrderInvariant & profiles$IdentityLabelInvariant),
    sum(legacy$LegacyEquivalent[condition]) == 21L &&
      sum(!legacy$LegacyEquivalent[condition]) == 26L,
    !any(legacy$LegacyEquivalent[event]) && all(legacy$DiagnosisQualified),
    FALSE, FALSE
  )
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "parent_truth_identity", "target_operator_coverage",
      "independent_direct_diagonal_oracle", "psd_and_diagonal_route_scope",
      "post_missingness_invariance", "row_order_and_label_invariance",
      "legacy_condition_operator_diagnosis",
      "legacy_event_operator_diagnosis", "truth_coefficient_adapter",
      "superseding_plan_and_execution_bridge"
    ),
    GatePassed = pass,
    Blocking = !pass,
    OperatorOnly = TRUE,
    ExecutionAttempted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3o_gap_registry <- function() {
  data.frame(
    GapOrdinal = 1:3,
    GapId = c(
      "truth_coefficient_adapter", "superseding_execution_plan",
      "fit_metric_execution_bridge"
    ),
    DependencyOrder = 1:3,
    RequiredArtifact = c(
      paste(
        "deterministic_per_stratum_G_Phi_truth_adapter_with_independent",
        "scalar_formula_oracle_and_no_fitted_values", sep = "_"
      ),
      paste(
        "new_unopened_plan_binding_truth_operator_and_metric_identities",
        "without_mutating_the_current_plan", sep = "_"
      ),
      paste(
        "identity_bound_fit_metric_worker_and_terminal_resource",
        "orchestration_qualified_on_nonreserved_shadow_fixtures", sep = "_"
      )
    ),
    GapOpen = TRUE,
    ExecutionRequiredToClose = c(FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3o_manifest <- function(
    contract = mfrmr_gtds3o_contract(),
    truth_contract = mfrmr_gtds3t_contract(),
    truth_manifest = mfrmr_gtds3t_manifest(),
    semantics_manifest = mfrmr_gtds3s_manifest(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3o_validate_contract(contract)
  mfrmr_gtds3t_assert_manifest(truth_manifest, truth_contract)
  mfrmr_gtds3s_assert_manifest(semantics_manifest)
  if (!identical(truth_contract$ContractHash,
                 contract$ParentTruthContractHash) ||
      !identical(truth_manifest$ManifestHash,
                 contract$ParentTruthManifestHash) ||
      !identical(semantics_manifest$ManifestHash,
                 contract$ParentSemanticsManifestHash)) {
    stop("A parent identity of the allocation operator changed.",
         call. = FALSE)
  }
  scenarios <- coverage$ScenarioRegistry$ScenarioId
  projected <- lapply(scenarios, function(scenario_id) {
    mfrmr_gtds3o_project_profile(
      scenario_id, contract, truth_contract, truth_manifest,
      semantics_manifest, compiler_contract, coverage,
      validate = FALSE
    )
  })
  profile_rows <- list(); operator_rows <- list(); diagonal_rows <- list()
  legacy_rows <- list(); operator_cursor <- 0L; diagonal_cursor <- 0L
  legacy_cursor <- 0L
  for (index in seq_along(projected)) {
    result <- projected[[index]]
    summary <- result$Summary
    profile_rows[[index]] <- data.frame(
      ProfileOperatorOrdinal = index,
      ScenarioId = summary$ScenarioId,
      Crossing = summary$Crossing,
      StratumCount = summary$StratumCount,
      TargetComponentOperatorCount =
        summary$TargetComponentOperatorCount,
      StratumDiagonalCount = summary$StratumDiagonalCount,
      DirectOracleQualified = summary$DirectOracleQualified,
      RowOrderInvariant = summary$RowOrderInvariant,
      MissingnessMaskInvariant = summary$MissingnessMaskInvariant,
      IdentityLabelInvariant = summary$IdentityLabelInvariant,
      PositiveSemidefinite = summary$PositiveSemidefinite,
      OffDiagonalExactZero = summary$OffDiagonalExactZero,
      SeparateUnivariateOperatorQualified =
        summary$SeparateUnivariateOperatorQualified,
      CoefficientComputed = FALSE,
      ExploratoryExecutionAllowed = FALSE,
      TruthProjectionHash = result$TruthProjectionHash,
      ProfileOperatorHash = result$ProfileOperatorHash,
      stringsAsFactors = FALSE
    )
    for (target_id in names(result$Operators)) {
      operator_cursor <- operator_cursor + 1L
      operator <- result$Operators[[target_id]]
      check <- result$InvarianceOracleRegistry[
        result$InvarianceOracleRegistry$TargetComponentId == target_id,
        , drop = FALSE
      ]
      operator_rows[[operator_cursor]] <- data.frame(
        OperatorBindingOrdinal = operator_cursor,
        ScenarioId = summary$ScenarioId,
        TargetComponentId = target_id,
        ComponentClass = operator$ComponentClass,
        StratumCount = length(operator$Strata),
        MinimumDiagonal = min(diag(operator$OperatorMatrix)),
        MaximumDiagonal = max(diag(operator$OperatorMatrix)),
        PositiveSemidefinite = check$PositiveSemidefinite,
        OffDiagonalExactZero = check$OffDiagonalExactZero,
        DirectOracleMaximumError = check$DirectOracleMaximumError,
        RowOrderInvariant = check$RowOrderInvariant,
        MissingnessMaskInvariant = check$MissingnessMaskInvariant,
        IdentityLabelInvariant = check$IdentityLabelInvariant,
        OperatorHash = operator$OperatorHash,
        stringsAsFactors = FALSE
      )
      detail <- operator$StratumWeightNormRegistry
      for (row_index in seq_len(nrow(detail))) {
        diagonal_cursor <- diagonal_cursor + 1L
        diagonal_rows[[diagonal_cursor]] <- data.frame(
          DiagonalOracleOrdinal = diagonal_cursor,
          ScenarioId = summary$ScenarioId,
          TargetComponentId = target_id,
          detail[row_index, , drop = FALSE],
          DirectOracleExpected = check$DirectOracleExpected,
          DirectOracleMaximumError = abs(
            detail$OperatorDiagonal[[row_index]] -
              check$DirectOracleExpected
          ),
          stringsAsFactors = FALSE
        )
      }
    }
    compilation <- mfrmr_gtds3c_compile_profile(
      summary$ScenarioId, compiler_contract, coverage, validate = FALSE
    )
    condition_id <- if ("Rater" %in% names(result$Operators)) {
      "Rater"
    } else "NestedCondition"
    legacy <- mfrmr_gtds3o_legacy_comparison(
      summary$ScenarioId, compilation,
      result$Operators[[condition_id]], result$Operators$Residual,
      contract
    )
    for (row_index in seq_len(nrow(legacy))) {
      legacy_cursor <- legacy_cursor + 1L
      legacy_rows[[legacy_cursor]] <- data.frame(
        LegacyComparisonOrdinal = legacy_cursor,
        legacy[row_index, , drop = FALSE], stringsAsFactors = FALSE
      )
    }
  }
  profiles <- do.call(rbind, profile_rows)
  operators <- do.call(rbind, operator_rows)
  diagonals <- do.call(rbind, diagonal_rows)
  legacy <- do.call(rbind, legacy_rows)
  row.names(profiles) <- row.names(operators) <-
    row.names(diagonals) <- row.names(legacy) <- NULL
  gates <- mfrmr_gtds3o_gate_registry(
    profiles, operators, diagonals, legacy
  )
  gaps <- mfrmr_gtds3o_gap_registry()
  condition <- legacy$OperatorClass == "condition"
  event <- legacy$OperatorClass == "event"
  summary <- list(
    ProfileCount = nrow(profiles),
    QualifiedProfileCount = sum(
      profiles$SeparateUnivariateOperatorQualified
    ),
    TargetComponentOperatorCount = nrow(operators),
    QualifiedTargetComponentOperatorCount = sum(
      operators$PositiveSemidefinite & operators$OffDiagonalExactZero &
        operators$DirectOracleMaximumError <= contract$MatrixTolerance &
        operators$RowOrderInvariant & operators$MissingnessMaskInvariant &
        operators$IdentityLabelInvariant
    ),
    StratumDiagonalCount = nrow(diagonals),
    DirectOracleQualifiedDiagonalCount = sum(
      diagonals$DirectOracleMaximumError <= contract$MatrixTolerance
    ),
    LegacyComparisonCount = nrow(legacy),
    ConditionLegacyEquivalentCount = sum(
      legacy$LegacyEquivalent[condition]
    ),
    ConditionLegacyMismatchCount = sum(
      !legacy$LegacyEquivalent[condition]
    ),
    EventLegacyEquivalentCount = sum(legacy$LegacyEquivalent[event]),
    EventLegacyMismatchCount = sum(!legacy$LegacyEquivalent[event]),
    LegacyDiagnosisQualifiedCount = sum(legacy$DiagnosisQualified),
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    OpenGapCount = sum(gaps$GapOpen),
    CurrentDisposition =
      "separate_univariate_operator_qualified_metric_and_plan_required",
    NextAction = paste(
      "compile deterministic per-stratum G and Phi truth values from the",
      "qualified truth projection and allocation operators and verify them",
      "against independent scalar formulas before issuing a new plan",
      sep = "_"
    ),
    Planned855RngStreamOpened = FALSE,
    ResponseInspected = FALSE,
    BackendCallMade = FALSE,
    FitReturned = FALSE,
    CoefficientComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE
  )
  payload <- list(
    Contract = contract,
    ParentTruthManifestHash = truth_manifest$ManifestHash,
    ProfileOperatorRegistry = profiles,
    TargetComponentOperatorRegistry = operators,
    StratumDiagonalOracleRegistry = diagonals,
    LegacyOperatorComparisonRegistry = legacy,
    ReadinessGateRegistry = gates,
    OpenGapRegistry = gaps,
    Summary = summary
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtds3o_hash(payload)
  )), class = c("mfrmr_gtds3o_manifest", "list"))
}

mfrmr_gtds3o_assert_manifest <- function(
    manifest, contract = mfrmr_gtds3o_contract()) {
  if (!inherits(manifest, "mfrmr_gtds3o_manifest")) {
    stop("A typed D-SIM-3 incidence-allocation manifest is required.",
         call. = FALSE)
  }
  mfrmr_gtds3o_validate_contract(contract)
  profiles <- manifest$ProfileOperatorRegistry
  operators <- manifest$TargetComponentOperatorRegistry
  diagonals <- manifest$StratumDiagonalOracleRegistry
  legacy <- manifest$LegacyOperatorComparisonRegistry
  gates <- manifest$ReadinessGateRegistry
  condition <- legacy$OperatorClass == "condition"
  event <- legacy$OperatorClass == "event"
  valid <- identical(manifest$Contract, contract) &&
    identical(manifest$ParentTruthManifestHash,
              contract$ParentTruthManifestHash) &&
    identical(nrow(profiles), 21L) &&
    identical(nrow(operators), 78L) &&
    identical(nrow(diagonals), 173L) &&
    identical(nrow(legacy), 94L) &&
    all(profiles$SeparateUnivariateOperatorQualified) &&
    all(operators$PositiveSemidefinite) &&
    all(operators$OffDiagonalExactZero) &&
    all(operators$DirectOracleMaximumError <= contract$MatrixTolerance) &&
    all(operators$RowOrderInvariant) &&
    all(operators$MissingnessMaskInvariant) &&
    all(operators$IdentityLabelInvariant) &&
    all(diagonals$DirectOracleMaximumError <= contract$MatrixTolerance) &&
    identical(sum(legacy$LegacyEquivalent[condition]), 21L) &&
    identical(sum(!legacy$LegacyEquivalent[condition]), 26L) &&
    identical(sum(legacy$LegacyEquivalent[event]), 0L) &&
    identical(sum(!legacy$LegacyEquivalent[event]), 47L) &&
    all(legacy$DiagnosisQualified) &&
    identical(gates$GatePassed, c(rep(TRUE, 8L), FALSE, FALSE)) &&
    identical(
      manifest$Summary$CurrentDisposition,
      "separate_univariate_operator_qualified_metric_and_plan_required"
    ) &&
    !isTRUE(manifest$Summary$Planned855RngStreamOpened) &&
    !isTRUE(manifest$Summary$ResponseInspected) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitReturned) &&
    !isTRUE(manifest$Summary$CoefficientComputed) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    identical(
      manifest$ManifestHash,
      mfrmr_gtds3o_hash(manifest[setdiff(names(manifest), "ManifestHash")])
    )
  if (!valid) {
    stop("The D-SIM-3 incidence-allocation manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

