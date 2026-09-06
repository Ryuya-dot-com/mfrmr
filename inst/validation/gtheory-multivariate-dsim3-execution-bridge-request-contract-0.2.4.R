# Internal D-SIM-3 execution-bridge request contract.
#
# This artifact freezes route semantics and compiles every identity-bound
# generation, backend, metric, terminal, and resource request required by the
# superseding 856 plan. It does not authorize or execute any request.

mfrmr_gtds3x_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3_manifest",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds3p_plan",
    "mfrmr_gtds3p_assert_plan"
  )
  target <- environment(mfrmr_gtds3x_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 coverage and superseding-plan chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3x_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3x_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-EXECUTION-BRIDGE-REQUEST-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentSupersedingPlanContractHash =
      "23469d19faab020974a15d0b874ec1b0dac34eda8d6440d0db198b6452f08297",
    ParentSupersedingPlanHash =
      "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a",
    ParentCoverageManifestHash =
      "4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197",
    ParentTruthManifestHash =
      "97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5",
    ParentOperatorManifestHash =
      "526298d0c598e34a92e98b96b7bc59c0714fc053636bc25ea423d4c87c895093",
    ParentTruthMetricManifestHash =
      "969afca1d3fb23a68d58500cd6959152b385b0e9b2e64c25cc75a3cd79feb37c",
    MechanicalRouteReceiptContractHash =
      "0b74d833dc9bff44e3eded32261258b8dbd5ca6a2a30805c871d2cc22c9d0129",
    MechanicalResourceContractHash =
      "535ab118a335a66bf0fd264ecc609249dc4e5042ffa1ac64aee1fdc846c94919",
    MechanicalResourceManifestHash =
      "2a752382b94d0eb0b488c1e7b96029f0f6cc786738997e2dc7c27f28c4051f9d"
  )
}

mfrmr_gtds3x_route_semantics_registry <- function() {
  data.frame(
    RouteFamilyOrdinal = 1:2,
    RouteId = c(
      "multivariate_lme4_restricted", "separate_univariate"
    ),
    Backend = "lme4",
    Criterion = "REML",
    FitScope = c(
      "joint_stratum_model_design_dependent_target_components",
      "one_independent_fit_per_registered_stratum"
    ),
    MetricOutputShape = "named_per_stratum_G_Phi_vectors",
    AllRegisteredStrataRequired = TRUE,
    ScalarPoolingAcrossStrataAllowed = FALSE,
    DecisionWeightVectorDefined = FALSE,
    CrossStratumCovarianceFitted = c(TRUE, FALSE),
    CrossStratumCovarianceUsedInCoefficient = FALSE,
    MarginalComponentDiagonalUsed = TRUE,
    RepeatOneCombinedErrorRepresentationRequired = TRUE,
    DiagnosticOverrideAllowed = FALSE,
    RouteOutcomeVotes = FALSE,
    TruthComparisonShapeQualified = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3x_environment_requirement_registry <- function() {
  data.frame(
    RequirementOrdinal = 1:6,
    RequirementId = c(
      "R_runtime", "Matrix_namespace", "lme4_namespace",
      "digest_namespace", "processx_namespace", "worker_source_identity"
    ),
    Required = TRUE,
    ExactIdentityFrozen = FALSE,
    ExecutionCurrentlyAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3x_contract <- function() {
  mfrmr_gtds3x_require_primitives()
  identity <- mfrmr_gtds3x_identity()
  payload <- c(identity, list(
    ExpectedScenarioCount = 21L,
    ExpectedGenerationRequestCount = 42L,
    ExpectedBackendRequestCount = 50L,
    ExpectedMetricRequestCount = 100L,
    ExpectedTerminalOrchestrationRequestCount = 92L,
    ExpectedResourceBindingCount = 5L,
    ExpectedCandidateRouteFamilyCount = 2L,
    ExpectedRestrictedMultivariateRequestCount = 8L,
    ExpectedSeparateUnivariateRequestCount = 42L,
    RouteSemanticsRegistry = mfrmr_gtds3x_route_semantics_registry(),
    EnvironmentRequirementRegistry =
      mfrmr_gtds3x_environment_requirement_registry(),
    MetricEstimandIds = c("ABS-PHI", "REL-G"),
    MetricOutputShape = "named_per_stratum_G_Phi_vectors",
    ScalarPoolingAcrossStrataAllowed = FALSE,
    OutcomeAdaptiveWeightSelectionAllowed = FALSE,
    UserDecisionWeightRequiredForCurrentMetric = FALSE,
    ExactRequestCompilationMayUseRng = FALSE,
    ExactRequestCompilationMayInspectResponse = FALSE,
    ExactRequestCompilationMayCallBackend = FALSE,
    ExactRequestCompilationMayFit = FALSE,
    ExactRequestCompilationMayComputeFittedMetric = FALSE,
    RequestExecutionAuthorizationAllowed = FALSE,
    Planned856RngStreamAccessAllowed = FALSE,
    PartialLaunchAllowed = FALSE,
    ScenarioSpecificExecutionPatchAllowed = FALSE,
    HistoricalReceiptInheritanceAllowed = FALSE,
    HistoricalQualificationInheritanceAllowed = FALSE,
    FitMetricWorkerQualified = FALSE,
    TerminalResourceOrchestratorQualified = FALSE,
    ShadowExecutionQualificationReady = FALSE,
    LaunchReconciliationReady = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3x_hash(payload)
  )), class = c("mfrmr_gtds3x_contract", "list"))
}

mfrmr_gtds3x_validate_contract <- function(
    contract = mfrmr_gtds3x_contract()) {
  mfrmr_gtds3x_require_primitives()
  canonical <- mfrmr_gtds3x_contract()
  routes <- contract$RouteSemanticsRegistry
  environment <- contract$EnvironmentRequirementRegistry
  valid <- inherits(contract, "mfrmr_gtds3x_contract") &&
    identical(contract, canonical) &&
    identical(nrow(routes), 2L) &&
    identical(routes$RouteId, c(
      "multivariate_lme4_restricted", "separate_univariate"
    )) &&
    all(routes$Backend == "lme4") && all(routes$Criterion == "REML") &&
    all(routes$MetricOutputShape == contract$MetricOutputShape) &&
    all(routes$AllRegisteredStrataRequired) &&
    all(!routes$ScalarPoolingAcrossStrataAllowed) &&
    all(!routes$DecisionWeightVectorDefined) &&
    identical(routes$CrossStratumCovarianceFitted, c(TRUE, FALSE)) &&
    all(!routes$CrossStratumCovarianceUsedInCoefficient) &&
    all(routes$MarginalComponentDiagonalUsed) &&
    all(routes$RepeatOneCombinedErrorRepresentationRequired) &&
    all(!routes$DiagnosticOverrideAllowed) &&
    all(!routes$RouteOutcomeVotes) &&
    all(routes$TruthComparisonShapeQualified) &&
    identical(nrow(environment), 6L) && all(environment$Required) &&
    all(!environment$ExactIdentityFrozen) &&
    all(!environment$ExecutionCurrentlyAllowed) &&
    identical(contract$ExpectedGenerationRequestCount, 42L) &&
    identical(contract$ExpectedBackendRequestCount, 50L) &&
    identical(contract$ExpectedMetricRequestCount, 100L) &&
    identical(contract$ExpectedTerminalOrchestrationRequestCount, 92L) &&
    identical(contract$ExpectedResourceBindingCount, 5L) &&
    !isTRUE(contract$ScalarPoolingAcrossStrataAllowed) &&
    !isTRUE(contract$OutcomeAdaptiveWeightSelectionAllowed) &&
    !isTRUE(contract$UserDecisionWeightRequiredForCurrentMetric) &&
    !isTRUE(contract$ExactRequestCompilationMayUseRng) &&
    !isTRUE(contract$ExactRequestCompilationMayInspectResponse) &&
    !isTRUE(contract$ExactRequestCompilationMayCallBackend) &&
    !isTRUE(contract$ExactRequestCompilationMayFit) &&
    !isTRUE(contract$ExactRequestCompilationMayComputeFittedMetric) &&
    !isTRUE(contract$RequestExecutionAuthorizationAllowed) &&
    !isTRUE(contract$Planned856RngStreamAccessAllowed) &&
    !isTRUE(contract$PartialLaunchAllowed) &&
    !isTRUE(contract$ScenarioSpecificExecutionPatchAllowed) &&
    !isTRUE(contract$HistoricalReceiptInheritanceAllowed) &&
    !isTRUE(contract$HistoricalQualificationInheritanceAllowed) &&
    !isTRUE(contract$FitMetricWorkerQualified) &&
    !isTRUE(contract$TerminalResourceOrchestratorQualified) &&
    !isTRUE(contract$ShadowExecutionQualificationReady) &&
    !isTRUE(contract$LaunchReconciliationReady) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 execution-bridge request contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3x_profile_registry <- function(plan, coverage, contract) {
  scenarios <- coverage$ScenarioRegistry
  bindings <- plan$ProfileBindingRegistry
  index <- match(scenarios$ScenarioId, bindings$ScenarioId)
  output <- data.frame(
    ProfileRequestOrdinal = scenarios$ScenarioOrdinal,
    ScenarioId = scenarios$ScenarioId,
    ScenarioHash = scenarios$ScenarioHash,
    StratumCount = scenarios$stratum_count,
    Crossing = scenarios$crossing,
    RepeatCount = as.integer(scenarios$repeat_count),
    TruthProjectionHash = bindings$TruthProjectionHash[index],
    ProfileOperatorHash = bindings$ProfileOperatorHash[index],
    ProfileTruthCoefficientHash =
      bindings$ProfileTruthCoefficientHash[index],
    QualifiedReferenceBundleHash =
      bindings$QualifiedReferenceBundleHash[index],
    ResponseInspected = FALSE,
    stringsAsFactors = FALSE
  )
  output$ProfileRequestSemanticsHash <- vapply(
    seq_len(nrow(output)), function(row) {
      mfrmr_gtds3x_hash(list(
        ContractHash = contract$ContractHash,
        PlanHash = plan$PlanHash,
        ScenarioId = output$ScenarioId[[row]],
        ScenarioHash = output$ScenarioHash[[row]],
        StratumCount = output$StratumCount[[row]],
        Crossing = output$Crossing[[row]],
        RepeatCount = output$RepeatCount[[row]],
        QualifiedReferenceBundleHash =
          output$QualifiedReferenceBundleHash[[row]]
      ))
    }, character(1L)
  )
  output
}

mfrmr_gtds3x_request_id <- function(prefix, ordinal, payload) {
  paste0(
    prefix, sprintf("%03d", ordinal), "-",
    substr(mfrmr_gtds3x_hash(payload), 1L, 16L)
  )
}

mfrmr_gtds3x_generation_requests <- function(
    plan, profiles, contract) {
  datasets <- plan$DatasetAttemptRegistry
  profile_index <- match(datasets$ScenarioId, profiles$ScenarioId)
  rows <- lapply(seq_len(nrow(datasets)), function(index) {
    payload <- list(
      ContractHash = contract$ContractHash,
      PlanHash = plan$PlanHash,
      DatasetId = datasets$DatasetId[[index]],
      ScenarioId = datasets$ScenarioId[[index]],
      ScenarioHash = datasets$ScenarioHash[[index]],
      Replicate = datasets$Replicate[[index]],
      DataSeed = datasets$DataSeed[[index]],
      SeedBandId = datasets$SeedBandId[[index]],
      ProfileRequestSemanticsHash =
        profiles$ProfileRequestSemanticsHash[[profile_index[[index]]]],
      QualifiedReferenceBundleHash =
        datasets$QualifiedReferenceBundleHash[[index]]
    )
    data.frame(
      GenerationRequestOrdinal = as.integer(index),
      GenerationRequestId = mfrmr_gtds3x_request_id(
        "D3X-G", index, payload
      ),
      PlanHash = plan$PlanHash,
      DatasetId = datasets$DatasetId[[index]],
      ScenarioId = datasets$ScenarioId[[index]],
      Replicate = datasets$Replicate[[index]],
      DataSeed = datasets$DataSeed[[index]],
      SeedBandId = datasets$SeedBandId[[index]],
      ProfileRequestSemanticsHash =
        profiles$ProfileRequestSemanticsHash[[profile_index[[index]]]],
      QualifiedReferenceBundleHash =
        datasets$QualifiedReferenceBundleHash[[index]],
      RequestHash = mfrmr_gtds3x_hash(payload),
      RequestCompiled = TRUE,
      RngStreamOpened = FALSE,
      ResponseGenerated = FALSE,
      ExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3x_model_specification_id <- function(
    route_id, crossing, repeat_count) {
  crossing_id <- switch(
    crossing,
    fully_crossed = "crossed",
    partially_crossed = "crossed",
    nested = "nested",
    stop("An executable crossing is required.", call. = FALSE)
  )
  repeat_id <- if (as.integer(repeat_count) == 1L) {
    "combined_error"
  } else "separate_error"
  paste(route_id, crossing_id, repeat_id, sep = "::")
}

mfrmr_gtds3x_backend_requests <- function(
    plan, profiles, generation, contract) {
  routes <- plan$RouteUnitRegistry
  routes <- routes[
    routes$PlannedDisposition == "qualification_candidate", , drop = FALSE
  ]
  semantics <- contract$RouteSemanticsRegistry
  profile_index <- match(routes$ScenarioId, profiles$ScenarioId)
  generation_key <- paste(
    generation$DatasetId, generation$PlanHash, sep = "::"
  )
  rows <- lapply(seq_len(nrow(routes)), function(index) {
    semantic_index <- match(routes$RouteId[[index]], semantics$RouteId)
    generation_index <- match(
      paste(routes$DatasetId[[index]], plan$PlanHash, sep = "::"),
      generation_key
    )
    model_id <- mfrmr_gtds3x_model_specification_id(
      routes$RouteId[[index]],
      profiles$Crossing[[profile_index[[index]]]],
      profiles$RepeatCount[[profile_index[[index]]]]
    )
    metric_semantics_hash <- mfrmr_gtds3x_hash(list(
      RouteSemantics = semantics[semantic_index, , drop = FALSE],
      ProfileRequestSemanticsHash =
        profiles$ProfileRequestSemanticsHash[[profile_index[[index]]]]
    ))
    payload <- list(
      ContractHash = contract$ContractHash,
      PlanHash = plan$PlanHash,
      RouteUnitId = routes$RouteUnitId[[index]],
      DatasetId = routes$DatasetId[[index]],
      GenerationRequestHash = generation$RequestHash[[generation_index]],
      ScenarioId = routes$ScenarioId[[index]],
      Replicate = routes$Replicate[[index]],
      RouteId = routes$RouteId[[index]],
      Backend = semantics$Backend[[semantic_index]],
      Criterion = semantics$Criterion[[semantic_index]],
      ModelSpecificationId = model_id,
      MetricSemanticsHash = metric_semantics_hash
    )
    data.frame(
      BackendRequestOrdinal = as.integer(index),
      BackendRequestId = mfrmr_gtds3x_request_id(
        "D3X-B", index, payload
      ),
      PlanHash = plan$PlanHash,
      RouteUnitId = routes$RouteUnitId[[index]],
      DatasetId = routes$DatasetId[[index]],
      GenerationRequestId =
        generation$GenerationRequestId[[generation_index]],
      GenerationRequestHash = generation$RequestHash[[generation_index]],
      ScenarioId = routes$ScenarioId[[index]],
      Replicate = routes$Replicate[[index]],
      RouteId = routes$RouteId[[index]],
      Backend = semantics$Backend[[semantic_index]],
      Criterion = semantics$Criterion[[semantic_index]],
      ModelSpecificationId = model_id,
      MetricOutputShape = semantics$MetricOutputShape[[semantic_index]],
      ScalarPoolingAcrossStrataAllowed = FALSE,
      CrossStratumCovarianceFitted =
        semantics$CrossStratumCovarianceFitted[[semantic_index]],
      CrossStratumCovarianceUsedInCoefficient = FALSE,
      MetricSemanticsHash = metric_semantics_hash,
      RequestHash = mfrmr_gtds3x_hash(payload),
      RequestCompiled = TRUE,
      BackendCallMade = FALSE,
      FitReturned = FALSE,
      ExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3x_metric_requests <- function(
    plan, backend, contract) {
  coordinates <- plan$RouteEstimandCoordinateRegistry
  coordinates <- coordinates[
    coordinates$RouteUnitId %in% backend$RouteUnitId, , drop = FALSE
  ]
  backend_index <- match(coordinates$RouteUnitId, backend$RouteUnitId)
  rows <- lapply(seq_len(nrow(coordinates)), function(index) {
    payload <- list(
      ContractHash = contract$ContractHash,
      PlanHash = plan$PlanHash,
      CoordinateId = coordinates$CoordinateId[[index]],
      RouteUnitId = coordinates$RouteUnitId[[index]],
      BackendRequestHash = backend$RequestHash[[backend_index[[index]]]],
      ScenarioId = coordinates$ScenarioId[[index]],
      Replicate = coordinates$Replicate[[index]],
      RouteId = coordinates$RouteId[[index]],
      EstimandId = coordinates$EstimandId[[index]],
      ProfileTruthCoefficientHash =
        coordinates$ProfileTruthCoefficientHash[[index]],
      MetricSemanticsHash =
        backend$MetricSemanticsHash[[backend_index[[index]]]]
    )
    data.frame(
      MetricRequestOrdinal = as.integer(index),
      MetricRequestId = mfrmr_gtds3x_request_id(
        "D3X-M", index, payload
      ),
      PlanHash = plan$PlanHash,
      CoordinateId = coordinates$CoordinateId[[index]],
      RouteUnitId = coordinates$RouteUnitId[[index]],
      BackendRequestId =
        backend$BackendRequestId[[backend_index[[index]]]],
      BackendRequestHash = backend$RequestHash[[backend_index[[index]]]],
      ScenarioId = coordinates$ScenarioId[[index]],
      Replicate = coordinates$Replicate[[index]],
      RouteId = coordinates$RouteId[[index]],
      EstimandId = coordinates$EstimandId[[index]],
      MetricOutputShape = contract$MetricOutputShape,
      ScalarPoolingAcrossStrataAllowed = FALSE,
      ProfileTruthCoefficientHash =
        coordinates$ProfileTruthCoefficientHash[[index]],
      MetricSemanticsHash =
        backend$MetricSemanticsHash[[backend_index[[index]]]],
      RequestHash = mfrmr_gtds3x_hash(payload),
      RequestCompiled = TRUE,
      FitInspected = FALSE,
      MetricComputed = FALSE,
      ExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3x_terminal_requests <- function(
    plan, generation, backend, contract) {
  terminal_hash <- mfrmr_gtds3x_hash(
    plan$Contract$InheritedTerminalStateRegistry
  )
  dataset <- data.frame(
    UnitNamespace = "planned_dataset",
    UnitType = "dataset",
    UnitId = generation$DatasetId,
    ScenarioId = generation$ScenarioId,
    Replicate = generation$Replicate,
    ParentRequestId = generation$GenerationRequestId,
    ParentRequestHash = generation$RequestHash,
    AllowedTerminalStates = paste(
      c("generation_complete", "generation_failure",
        "generation_resource_limit"), collapse = "|"
    ),
    AtomicResourceScopes = "dataset_generation",
    stringsAsFactors = FALSE
  )
  route <- data.frame(
    UnitNamespace = "planned_route",
    UnitType = "route",
    UnitId = backend$RouteUnitId,
    ScenarioId = backend$ScenarioId,
    Replicate = backend$Replicate,
    ParentRequestId = backend$BackendRequestId,
    ParentRequestHash = backend$RequestHash,
    AllowedTerminalStates = paste(
      c(
        "not_attempted_generation_dependency", "fit_failure",
        "fit_resource_limit", "metric_failure", "metric_resource_limit",
        "complete_nonpromoting"
      ), collapse = "|"
    ),
    AtomicResourceScopes = "one_route_fit|one_route_metric",
    stringsAsFactors = FALSE
  )
  units <- rbind(dataset, route)
  rows <- lapply(seq_len(nrow(units)), function(index) {
    payload <- list(
      ContractHash = contract$ContractHash,
      PlanHash = plan$PlanHash,
      UnitNamespace = units$UnitNamespace[[index]],
      UnitType = units$UnitType[[index]],
      UnitId = units$UnitId[[index]],
      ParentRequestHash = units$ParentRequestHash[[index]],
      TerminalStateRegistryHash = terminal_hash,
      AllowedTerminalStates = units$AllowedTerminalStates[[index]],
      AtomicResourceScopes = units$AtomicResourceScopes[[index]]
    )
    data.frame(
      TerminalRequestOrdinal = as.integer(index),
      TerminalRequestId = mfrmr_gtds3x_request_id(
        "D3X-T", index, payload
      ),
      PlanHash = plan$PlanHash,
      UnitNamespace = units$UnitNamespace[[index]],
      UnitType = units$UnitType[[index]],
      UnitId = units$UnitId[[index]],
      ScenarioId = units$ScenarioId[[index]],
      Replicate = units$Replicate[[index]],
      ParentRequestId = units$ParentRequestId[[index]],
      ParentRequestHash = units$ParentRequestHash[[index]],
      TerminalStateRegistryHash = terminal_hash,
      AllowedTerminalStates = units$AllowedTerminalStates[[index]],
      AtomicResourceScopes = units$AtomicResourceScopes[[index]],
      RequestHash = mfrmr_gtds3x_hash(payload),
      RequestCompiled = TRUE,
      ExactlyOneTerminalReceiptRequiredAfterAttempt = TRUE,
      TerminalReceiptIssued = FALSE,
      HistoricalReceiptInherited = FALSE,
      ExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3x_resource_bindings <- function(plan, contract) {
  resources <- plan$Contract$InheritedResourceLimitRegistry
  rows <- lapply(seq_len(nrow(resources)), function(index) {
    payload <- list(
      ContractHash = contract$ContractHash,
      PlanHash = plan$PlanHash,
      ScopeId = resources$ScopeId[[index]],
      MaximumWallSeconds = resources$MaximumWallSeconds[[index]],
      MaximumPeakRssMiB = resources$MaximumPeakRssMiB[[index]],
      MaximumConcurrentWorkers =
        resources$MaximumConcurrentWorkers[[index]],
      ExceedanceDisposition = resources$ExceedanceDisposition[[index]],
      MechanicalResourceManifestHash =
        contract$MechanicalResourceManifestHash
    )
    data.frame(
      ResourceBindingOrdinal = as.integer(index),
      ResourceBindingId = mfrmr_gtds3x_request_id(
        "D3X-R", index, payload
      ),
      PlanHash = plan$PlanHash,
      ScopeId = resources$ScopeId[[index]],
      MaximumWallSeconds = resources$MaximumWallSeconds[[index]],
      MaximumPeakRssMiB = resources$MaximumPeakRssMiB[[index]],
      MaximumConcurrentWorkers =
        resources$MaximumConcurrentWorkers[[index]],
      ExceedanceDisposition = resources$ExceedanceDisposition[[index]],
      MechanicalResourceContractHash =
        contract$MechanicalResourceContractHash,
      MechanicalResourceManifestHash =
        contract$MechanicalResourceManifestHash,
      BindingHash = mfrmr_gtds3x_hash(payload),
      RebindingRequestCompiled = TRUE,
      MechanicsReceiptInherited = FALSE,
      QualifiedForSupersedingIdentity = FALSE,
      ExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3x_gate_registry <- function() {
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "superseding_plan_identity_bound",
      "truth_operator_metric_reference_bound",
      "two_route_family_semantics_frozen",
      "generation_request_denominator_complete",
      "backend_request_denominator_complete",
      "metric_request_denominator_complete",
      "terminal_request_denominator_complete",
      "resource_request_denominator_complete",
      "fit_metric_worker_and_orchestrator_shadow_qualified",
      "launch_readiness_reconciled"
    ),
    GatePassed = c(rep(TRUE, 8L), FALSE, FALSE),
    Blocking = c(rep(FALSE, 8L), TRUE, TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3x_gap_registry <- function() {
  data.frame(
    GapOrdinal = 1:2,
    GapId = c(
      "fit_metric_worker_and_terminal_resource_orchestrator",
      "identity_bound_launch_readiness_reconciliation"
    ),
    RequiredResolution = c(
      paste(
        "implement_one_common_worker_and_orchestrator_then_qualify_both",
        "route_families_on_nonreserved_shadow_fixtures", sep = "_"
      ),
      paste(
        "rerun_nonexecuting_reconciliation_against_exact_environment_and",
        "all_compiled_request_hashes", sep = "_"
      )
    ),
    GapOpen = TRUE,
    ExecutionMayProceed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3x_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3x_require_primitives", "mfrmr_gtds3x_hash",
    "mfrmr_gtds3x_identity", "mfrmr_gtds3x_route_semantics_registry",
    "mfrmr_gtds3x_environment_requirement_registry",
    "mfrmr_gtds3x_contract", "mfrmr_gtds3x_validate_contract",
    "mfrmr_gtds3x_profile_registry", "mfrmr_gtds3x_request_id",
    "mfrmr_gtds3x_generation_requests",
    "mfrmr_gtds3x_model_specification_id",
    "mfrmr_gtds3x_backend_requests", "mfrmr_gtds3x_metric_requests",
    "mfrmr_gtds3x_terminal_requests", "mfrmr_gtds3x_resource_bindings",
    "mfrmr_gtds3x_gate_registry", "mfrmr_gtds3x_gap_registry",
    "mfrmr_gtds3x_implementation_identity",
    "mfrmr_gtds3x_manifest_fields", "mfrmr_gtds3x_manifest",
    "mfrmr_gtds3x_assert_manifest"
  )
  target <- environment(mfrmr_gtds3x_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions),
    FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3x_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3x_manifest_fields <- function() {
  c(
    "Contract", "ParentSupersedingPlanHash", "ProfileRequestRegistry",
    "GenerationRequestRegistry", "BackendRequestRegistry",
    "MetricRequestRegistry", "TerminalOrchestrationRequestRegistry",
    "ResourceBindingRegistry", "ReadinessGateRegistry", "OpenGapRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3x_manifest <- function(
    contract = mfrmr_gtds3x_contract(),
    plan = mfrmr_gtds3p_plan(),
    coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3x_validate_contract(contract)
  mfrmr_gtds3p_assert_plan(plan)
  mfrmr_gtds3_assert_manifest(coverage)
  if (!identical(plan$Contract$ContractHash,
                 contract$ParentSupersedingPlanContractHash) ||
      !identical(plan$PlanHash,
                 contract$ParentSupersedingPlanHash) ||
      !identical(coverage$ManifestHash,
                 contract$ParentCoverageManifestHash) ||
      !identical(plan$ParentTruthManifestHash,
                 contract$ParentTruthManifestHash) ||
      !identical(plan$ParentOperatorManifestHash,
                 contract$ParentOperatorManifestHash) ||
      !identical(plan$ParentTruthMetricManifestHash,
                 contract$ParentTruthMetricManifestHash)) {
    stop("An execution-bridge parent identity changed.", call. = FALSE)
  }
  profiles <- mfrmr_gtds3x_profile_registry(plan, coverage, contract)
  generation <- mfrmr_gtds3x_generation_requests(
    plan, profiles, contract
  )
  backend <- mfrmr_gtds3x_backend_requests(
    plan, profiles, generation, contract
  )
  metric <- mfrmr_gtds3x_metric_requests(plan, backend, contract)
  terminal <- mfrmr_gtds3x_terminal_requests(
    plan, generation, backend, contract
  )
  resource <- mfrmr_gtds3x_resource_bindings(plan, contract)
  gates <- mfrmr_gtds3x_gate_registry()
  gaps <- mfrmr_gtds3x_gap_registry()
  implementation <- mfrmr_gtds3x_implementation_identity()
  route_counts <- table(factor(
    backend$RouteId,
    levels = contract$RouteSemanticsRegistry$RouteId
  ))
  summary <- list(
    ScenarioCount = nrow(profiles),
    GenerationRequestCount = nrow(generation),
    BackendRequestCount = nrow(backend),
    MetricRequestCount = nrow(metric),
    TerminalOrchestrationRequestCount = nrow(terminal),
    ResourceBindingCount = nrow(resource),
    RestrictedMultivariateRequestCount = as.integer(route_counts[[1L]]),
    SeparateUnivariateRequestCount = as.integer(route_counts[[2L]]),
    RouteFamilySemanticsFrozenCount =
      nrow(contract$RouteSemanticsRegistry),
    ScalarPoolingAcrossStrataAllowed = FALSE,
    DecisionWeightVectorDefined = FALSE,
    ExactRequestCount =
      nrow(generation) + nrow(backend) + nrow(metric) +
        nrow(terminal) + nrow(resource),
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    OpenGapCount = sum(gaps$GapOpen),
    CurrentDisposition =
      "identity_bound_requests_compiled_worker_and_reconciliation_required",
    RngStreamOpened = FALSE,
    ResponseInspected = FALSE,
    BackendCallMade = FALSE,
    FitReturned = FALSE,
    FittedMetricComputed = FALSE,
    TerminalReceiptIssued = FALSE,
    FitMetricWorkerQualified = FALSE,
    TerminalResourceOrchestratorQualified = FALSE,
    ShadowExecutionQualificationReady = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "implement one common fit metric worker and terminal resource",
      "orchestrator then qualify all profile route-family templates on",
      "nonreserved shadow fixtures before rerunning reconciliation"
    )
  )
  payload <- list(
    Contract = contract,
    ParentSupersedingPlanHash = plan$PlanHash,
    ProfileRequestRegistry = profiles,
    GenerationRequestRegistry = generation,
    BackendRequestRegistry = backend,
    MetricRequestRegistry = metric,
    TerminalOrchestrationRequestRegistry = terminal,
    ResourceBindingRegistry = resource,
    ReadinessGateRegistry = gates,
    OpenGapRegistry = gaps,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3x_hash(payload)
  )), class = c("mfrmr_gtds3x_manifest", "list"))
  mfrmr_gtds3x_assert_manifest(manifest)
  manifest
}

mfrmr_gtds3x_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3x_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3x_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 execution-bridge request manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  profiles <- manifest$ProfileRequestRegistry
  generation <- manifest$GenerationRequestRegistry
  backend <- manifest$BackendRequestRegistry
  metric <- manifest$MetricRequestRegistry
  terminal <- manifest$TerminalOrchestrationRequestRegistry
  resource <- manifest$ResourceBindingRegistry
  gates <- manifest$ReadinessGateRegistry
  gaps <- manifest$OpenGapRegistry
  route_counts <- table(factor(
    backend$RouteId, levels = contract$RouteSemanticsRegistry$RouteId
  ))
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3x_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3x_contract()) &&
    identical(manifest$ParentSupersedingPlanHash,
              contract$ParentSupersedingPlanHash) &&
    identical(
      manifest$ImplementationIdentity,
      mfrmr_gtds3x_implementation_identity()
    ) &&
    identical(nrow(profiles), 21L) &&
    identical(profiles$ScenarioId, sprintf("D3-S%03d", 1:21)) &&
    !anyDuplicated(profiles$ProfileRequestSemanticsHash) &&
    all(!profiles$ResponseInspected) &&
    identical(nrow(generation), 42L) &&
    !anyDuplicated(generation$GenerationRequestId) &&
    !anyDuplicated(generation$RequestHash) &&
    all(generation$PlanHash == contract$ParentSupersedingPlanHash) &&
    all(generation$RequestCompiled) &&
    all(!generation$RngStreamOpened) &&
    all(!generation$ResponseGenerated) &&
    all(!generation$ExecutionAuthorized) &&
    identical(nrow(backend), 50L) &&
    !anyDuplicated(backend$BackendRequestId) &&
    !anyDuplicated(backend$RequestHash) &&
    identical(as.integer(route_counts), c(8L, 42L)) &&
    all(backend$PlanHash == contract$ParentSupersedingPlanHash) &&
    all(backend$Backend == "lme4") && all(backend$Criterion == "REML") &&
    all(backend$MetricOutputShape == contract$MetricOutputShape) &&
    all(!backend$ScalarPoolingAcrossStrataAllowed) &&
    identical(sum(backend$CrossStratumCovarianceFitted), 8L) &&
    all(!backend$CrossStratumCovarianceUsedInCoefficient) &&
    all(backend$RequestCompiled) && all(!backend$BackendCallMade) &&
    all(!backend$FitReturned) && all(!backend$ExecutionAuthorized) &&
    identical(nrow(metric), 100L) &&
    !anyDuplicated(metric$MetricRequestId) &&
    !anyDuplicated(metric$RequestHash) &&
    all(table(metric$RouteUnitId) == 2L) &&
    identical(sort(unique(metric$EstimandId)),
              sort(contract$MetricEstimandIds)) &&
    all(metric$MetricOutputShape == contract$MetricOutputShape) &&
    all(!metric$ScalarPoolingAcrossStrataAllowed) &&
    all(metric$RequestCompiled) && all(!metric$FitInspected) &&
    all(!metric$MetricComputed) && all(!metric$ExecutionAuthorized) &&
    identical(nrow(terminal), 92L) &&
    !anyDuplicated(terminal$TerminalRequestId) &&
    !anyDuplicated(paste(
      terminal$UnitNamespace, terminal$UnitId, sep = "::"
    )) &&
    identical(sum(terminal$UnitType == "dataset"), 42L) &&
    identical(sum(terminal$UnitType == "route"), 50L) &&
    all(terminal$RequestCompiled) &&
    all(terminal$ExactlyOneTerminalReceiptRequiredAfterAttempt) &&
    all(!terminal$TerminalReceiptIssued) &&
    all(!terminal$HistoricalReceiptInherited) &&
    all(!terminal$ExecutionAuthorized) &&
    identical(nrow(resource), 5L) &&
    identical(resource$ScopeId, c(
      "dataset_generation", "one_route_fit", "one_route_metric",
      "one_dataset_pipeline", "complete_exploratory_run"
    )) &&
    all(resource$RebindingRequestCompiled) &&
    all(!resource$MechanicsReceiptInherited) &&
    all(!resource$QualifiedForSupersedingIdentity) &&
    all(!resource$ExecutionAuthorized) &&
    identical(nrow(gates), 10L) &&
    identical(sum(gates$GatePassed), 8L) &&
    identical(sum(gates$Blocking), 2L) &&
    identical(nrow(gaps), 2L) && all(gaps$GapOpen) &&
    all(!gaps$ExecutionMayProceed) &&
    identical(manifest$Summary$ExactRequestCount, 289L) &&
    identical(manifest$Summary$PassingReadinessGateCount, 8L) &&
    identical(manifest$Summary$BlockingReadinessGateCount, 2L) &&
    identical(
      manifest$Summary$CurrentDisposition,
      "identity_bound_requests_compiled_worker_and_reconciliation_required"
    ) &&
    !isTRUE(manifest$Summary$ScalarPoolingAcrossStrataAllowed) &&
    !isTRUE(manifest$Summary$DecisionWeightVectorDefined) &&
    !isTRUE(manifest$Summary$RngStreamOpened) &&
    !isTRUE(manifest$Summary$ResponseInspected) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitReturned) &&
    !isTRUE(manifest$Summary$FittedMetricComputed) &&
    !isTRUE(manifest$Summary$TerminalReceiptIssued) &&
    !isTRUE(manifest$Summary$FitMetricWorkerQualified) &&
    !isTRUE(manifest$Summary$TerminalResourceOrchestratorQualified) &&
    !isTRUE(manifest$Summary$ShadowExecutionQualificationReady) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-3 execution-bridge requests or boundary were altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
