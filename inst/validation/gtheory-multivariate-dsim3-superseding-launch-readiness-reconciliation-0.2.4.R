# Internal D-SIM-3 superseding launch-readiness reconciliation.
#
# This audit consumes already-qualified manifests and performs no stochastic
# generation, model fit, metric calculation, or process launch. It distinguishes
# request compilation from an executable planned-seed generator boundary.

mfrmr_gtds3z_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3p_plan",
    "mfrmr_gtds3p_assert_plan", "mfrmr_gtds3g_contract",
    "mfrmr_gtds3x_assert_manifest", "mfrmr_gtds3w_assert_manifest",
    "mfrmr_gtds3y_assert_manifest"
  )
  target <- environment(mfrmr_gtds3z_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the complete superseding D-SIM-3 bridge chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3z_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3z_identity <- function() {
  list(
    ContractId =
      "MFRMR-GTHEORY-MV-DSIM3-SUPERSEDING-LAUNCH-READINESS-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentSupersedingPlanHash =
      "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a",
    ParentGeneratorContractHash =
      "92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4",
    ParentRequestContractHash =
      "c37fbedb03f0535d2e8aab1380949385ba10b0fc32b205f77df17074d52fd67e",
    ParentRequestManifestHash =
      "69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef",
    ParentWorkerContractHash =
      "9e5055fc47191f4426507c352b45b72a2a40256bd227dcf464d04e7058de44c7",
    ParentWorkerManifestHash =
      "566faa25b496f32137fc167cc26b37f172e5fe2b2be73b78a22517e9d1213eb1",
    ParentOrchestratorContractHash =
      "5582fa0069d8760fffb5000bb20ffe972f135c22dce5e17e2eaf105bbd365ec4",
    ParentOrchestratorManifestHash =
      "bffb82e3155bf12597b686f47c7762cdce802c1ac4666c1c4572f2cb1f25c724",
    ParentWorkerEnvironmentHash =
      "93fccafffc8aeb84fb1b540308870fd1f044a79a6ebaf5359d2bd6fd3206c3a4",
    ExpectedProcessxVersion = "3.9.0"
  )
}

mfrmr_gtds3z_contract <- function() {
  mfrmr_gtds3z_require_primitives()
  identity <- mfrmr_gtds3z_identity()
  payload <- c(identity, list(
    ExpectedReadinessGateCount = 10L,
    ExpectedPassingReadinessGateCount = 9L,
    ExpectedBlockingReadinessGateCount = 1L,
    ExpectedGenerationRequestCount = 42L,
    ExpectedBackendRequestCount = 50L,
    ExpectedMetricRequestCount = 100L,
    ExpectedTerminalRequestCount = 92L,
    ExpectedResourceBindingCount = 5L,
    ExpectedExactRequestCount = 289L,
    ExpectedEnvironmentIdentityCount = 8L,
    PlannedSeedBandId = "DSIM3-SUPERSEDING-856",
    PlannedSeedMinimum = 856001001L,
    PlannedSeedMaximum = 856021002L,
    ShadowSeedMinimum = 854100001L,
    ShadowSeedMaximum = 854100021L,
    IntegratedWorkloadCapacityQualificationRequired = FALSE,
    PlannedSeedGenerationAdapterRequired = TRUE,
    RequestCompilationConfersExecutionAuthority = FALSE,
    ShadowQualificationConfersPlannedReceipt = FALSE,
    PartialLaunchAllowed = FALSE,
    HistoricalReceiptInheritanceAllowed = FALSE,
    ReconciliationMayUseRng = FALSE,
    ReconciliationMayGenerateResponse = FALSE,
    ReconciliationMayCallBackend = FALSE,
    ReconciliationMayFit = FALSE,
    ReconciliationMayComputeMetric = FALSE,
    ReconciliationMayLaunchProcess = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    RecoveryClaimAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3z_hash(payload)
  )), class = c("mfrmr_gtds3z_contract", "list"))
}

mfrmr_gtds3z_validate_contract <- function(
    contract = mfrmr_gtds3z_contract()) {
  canonical <- mfrmr_gtds3z_contract()
  valid <- inherits(contract, "mfrmr_gtds3z_contract") &&
    identical(contract, canonical) &&
    identical(contract$ExpectedPassingReadinessGateCount, 9L) &&
    identical(contract$ExpectedBlockingReadinessGateCount, 1L) &&
    identical(contract$ExpectedExactRequestCount, 289L) &&
    !isTRUE(contract$IntegratedWorkloadCapacityQualificationRequired) &&
    isTRUE(contract$PlannedSeedGenerationAdapterRequired) &&
    !isTRUE(contract$RequestCompilationConfersExecutionAuthority) &&
    !isTRUE(contract$ShadowQualificationConfersPlannedReceipt) &&
    !isTRUE(contract$PartialLaunchAllowed) &&
    !isTRUE(contract$HistoricalReceiptInheritanceAllowed) &&
    !isTRUE(contract$ReconciliationMayUseRng) &&
    !isTRUE(contract$ReconciliationMayGenerateResponse) &&
    !isTRUE(contract$ReconciliationMayCallBackend) &&
    !isTRUE(contract$ReconciliationMayFit) &&
    !isTRUE(contract$ReconciliationMayComputeMetric) &&
    !isTRUE(contract$ReconciliationMayLaunchProcess) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$RecoveryClaimAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The superseding D-SIM-3 reconciliation contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3z_environment_registry <- function(worker_manifest, contract) {
  worker <- worker_manifest$EnvironmentIdentityRegistry
  if (!identical(mfrmr_gtds3z_hash(worker),
                 contract$ParentWorkerEnvironmentHash)) {
    stop("The frozen worker environment identity changed.", call. = FALSE)
  }
  processx_version <- if (requireNamespace("processx", quietly = TRUE)) {
    as.character(utils::packageVersion("processx"))
  } else NA_character_
  output <- rbind(
    worker[, c("IdentityId", "IdentityValue"), drop = FALSE],
    data.frame(
      IdentityId = "processx_version",
      IdentityValue = processx_version,
      stringsAsFactors = FALSE
    )
  )
  output$EnvironmentIdentityOrdinal <- seq_len(nrow(output))
  output <- output[, c(
    "EnvironmentIdentityOrdinal", "IdentityId", "IdentityValue"
  )]
  output$ExpectedIdentityValue <- c(
    worker$IdentityValue, contract$ExpectedProcessxVersion
  )
  output$ExactIdentityMatch <- !is.na(output$IdentityValue) &
    output$IdentityValue == output$ExpectedIdentityValue
  output
}

mfrmr_gtds3z_generation_adapter_registry <- function(
    plan, request_manifest, worker_manifest, orchestrator_manifest,
    generator_contract, contract) {
  requests <- request_manifest$GenerationRequestRegistry
  datasets <- plan$DatasetAttemptRegistry
  index <- match(requests$DatasetId, datasets$DatasetId)
  profiles <- unique(worker_manifest$TemplateRegistry$ScenarioId)
  resource <- orchestrator_manifest$ResourceRebindingRegistry
  generation_operation <- resource$WorkerOperation[
    resource$ScopeId == "dataset_generation"
  ]
  within_shadow_guard <- requests$DataSeed >=
    generator_contract$MinimumShadowSeed & requests$DataSeed <=
    generator_contract$MaximumShadowSeed & requests$DataSeed <
    generator_contract$ReservedExploratoryLowerInclusive
  data.frame(
    GenerationAdapterOrdinal = seq_len(nrow(requests)),
    GenerationRequestId = requests$GenerationRequestId,
    GenerationRequestHash = requests$RequestHash,
    DatasetId = requests$DatasetId,
    ScenarioId = requests$ScenarioId,
    Replicate = requests$Replicate,
    DataSeed = requests$DataSeed,
    SeedBandId = requests$SeedBandId,
    RequestIdentityBound = requests$RequestCompiled &
      !is.na(index) &
      requests$DataSeed == datasets$DataSeed[index] &
      requests$SeedBandId == datasets$SeedBandId[index],
    ProfileSemanticsShadowQualified = requests$ScenarioId %in% profiles,
    CurrentGenerationOperation = generation_operation,
    PlannedSeedWithinCurrentGeneratorGuard = within_shadow_guard,
    PlannedSeedRejectedByCurrentGeneratorGuard = !within_shadow_guard,
    PlannedSeedGenerationAdapterBound = FALSE,
    ExecutionAttempted = FALSE,
    RngStreamOpened = FALSE,
    ResponseGenerated = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3z_request_coverage_registry <- function(
    request_manifest, worker_manifest, orchestrator_manifest,
    generation_adapter) {
  backend <- worker_manifest$BackendRequestCoverageRegistry
  metric <- worker_manifest$MetricRequestCoverageRegistry
  terminal <- orchestrator_manifest$TerminalRequestCoverageRegistry
  resource <- orchestrator_manifest$ResourceRebindingRegistry
  identity_bound <- c(
    all(generation_adapter$RequestIdentityBound),
    identical(
      request_manifest$BackendRequestRegistry$RequestHash,
      backend$BackendRequestHash
    ),
    identical(
      request_manifest$MetricRequestRegistry$RequestHash,
      metric$MetricRequestHash
    ),
    identical(
      request_manifest$TerminalOrchestrationRequestRegistry$RequestHash,
      terminal$TerminalRequestHash
    ),
    identical(
      request_manifest$ResourceBindingRegistry$BindingHash,
      resource$ResourceBindingHash
    )
  )
  qualified <- c(
    all(generation_adapter$ProfileSemanticsShadowQualified),
    all(backend$ShadowTemplateQualified),
    all(metric$AllStrataReturned),
    all(terminal$OrchestratorTemplateQualified),
    all(resource$QualifiedForSupersedingIdentity)
  )
  expected <- c(42L, 50L, 100L, 92L, 5L)
  data.frame(
    RequestClassOrdinal = 1:5,
    RequestClass = c(
      "generation", "backend", "metric", "terminal", "resource"
    ),
    ExpectedRequestCount = expected,
    IdentityBoundRequestCount = ifelse(identity_bound, expected, 0L),
    ShadowImplementationQualifiedCount = ifelse(qualified, expected, 0L),
    PlannedExecutionPathReady = c(FALSE, TRUE, TRUE, TRUE, TRUE),
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3z_gate_registry <- function() {
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "superseding_plan_identity",
      "truth_operator_metric_reference_identity",
      "all_289_request_identities",
      "exact_launch_environment_identity",
      "two_family_fit_metric_worker",
      "terminal_state_and_request_orchestration",
      "five_scope_resource_mechanics",
      "receipt_and_denominator_boundary",
      "shadow_orchestrator_qualification",
      "planned_seed_generation_adapter"
    ),
    GatePassed = c(rep(TRUE, 9L), FALSE),
    Blocking = c(rep(FALSE, 9L), TRUE),
    BlockingReason = c(
      rep("", 9L),
      paste0(
        "42_compiled_856_generation_requests_are_outside_the_",
        "854_only_generator_guard"
      )
    ),
    ReconciliationOnly = TRUE,
    ExecutionAttempted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3z_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3z_require_primitives", "mfrmr_gtds3z_hash",
    "mfrmr_gtds3z_identity", "mfrmr_gtds3z_contract",
    "mfrmr_gtds3z_validate_contract",
    "mfrmr_gtds3z_environment_registry",
    "mfrmr_gtds3z_generation_adapter_registry",
    "mfrmr_gtds3z_request_coverage_registry",
    "mfrmr_gtds3z_gate_registry",
    "mfrmr_gtds3z_implementation_identity",
    "mfrmr_gtds3z_manifest_fields", "mfrmr_gtds3z_manifest",
    "mfrmr_gtds3z_assert_manifest"
  )
  target <- environment(mfrmr_gtds3z_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3z_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3z_manifest_fields <- function() {
  c(
    "Contract", "ParentSupersedingPlanHash",
    "ParentRequestManifestHash", "ParentWorkerManifestHash",
    "ParentOrchestratorManifestHash", "EnvironmentIdentityRegistry",
    "GenerationAdapterRegistry", "RequestCoverageRegistry",
    "ReadinessGateRegistry", "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3z_manifest <- function(
    request_manifest, worker_manifest, orchestrator_manifest,
    resource_worker_path, plan = mfrmr_gtds3p_plan(),
    contract = mfrmr_gtds3z_contract()) {
  mfrmr_gtds3z_validate_contract(contract)
  mfrmr_gtds3p_assert_plan(plan)
  mfrmr_gtds3x_assert_manifest(request_manifest)
  mfrmr_gtds3w_assert_manifest(worker_manifest)
  mfrmr_gtds3y_assert_manifest(orchestrator_manifest, resource_worker_path)
  generator_contract <- mfrmr_gtds3g_contract()
  if (!identical(plan$PlanHash, contract$ParentSupersedingPlanHash) ||
      !identical(generator_contract$ContractHash,
                 contract$ParentGeneratorContractHash) ||
      !identical(request_manifest$Contract$ContractHash,
                 contract$ParentRequestContractHash) ||
      !identical(request_manifest$ManifestHash,
                 contract$ParentRequestManifestHash) ||
      !identical(worker_manifest$Contract$ContractHash,
                 contract$ParentWorkerContractHash) ||
      !identical(worker_manifest$ManifestHash,
                 contract$ParentWorkerManifestHash) ||
      !identical(orchestrator_manifest$Contract$ContractHash,
                 contract$ParentOrchestratorContractHash) ||
      !identical(orchestrator_manifest$ManifestHash,
                 contract$ParentOrchestratorManifestHash)) {
    stop("A superseding D-SIM-3 reconciliation parent changed.",
         call. = FALSE)
  }
  environment <- mfrmr_gtds3z_environment_registry(
    worker_manifest, contract
  )
  generation <- mfrmr_gtds3z_generation_adapter_registry(
    plan, request_manifest, worker_manifest, orchestrator_manifest,
    generator_contract, contract
  )
  coverage <- mfrmr_gtds3z_request_coverage_registry(
    request_manifest, worker_manifest, orchestrator_manifest, generation
  )
  gates <- mfrmr_gtds3z_gate_registry()
  implementation <- mfrmr_gtds3z_implementation_identity()
  summary <- list(
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    EnvironmentIdentityCount = nrow(environment),
    ExactEnvironmentIdentityCount = sum(environment$ExactIdentityMatch),
    ExactRequestCount = sum(coverage$ExpectedRequestCount),
    IdentityBoundRequestCount = sum(coverage$IdentityBoundRequestCount),
    ShadowImplementationQualifiedRequestCount =
      sum(coverage$ShadowImplementationQualifiedCount),
    PlannedGenerationRequestCount = nrow(generation),
    PlannedSeedAdapterBoundCount =
      sum(generation$PlannedSeedGenerationAdapterBound),
    CurrentGeneratorGuardRejectionCount =
      sum(generation$PlannedSeedRejectedByCurrentGeneratorGuard),
    BackendRequestCoverageCount = coverage$IdentityBoundRequestCount[[2L]],
    MetricRequestCoverageCount = coverage$IdentityBoundRequestCount[[3L]],
    TerminalRequestCoverageCount = coverage$IdentityBoundRequestCount[[4L]],
    ResourceBindingCoverageCount = coverage$IdentityBoundRequestCount[[5L]],
    IntegratedWorkloadCapacityQualified = FALSE,
    IntegratedWorkloadCapacityRequiredForExploratoryLaunch = FALSE,
    ReconciliationComplete = TRUE,
    TechnicalLaunchReady = FALSE,
    CurrentDisposition = "no_go_planned_generation_adapter_missing",
    Planned855RngStreamOpened = FALSE,
    Planned856RngStreamOpened = FALSE,
    ExploratoryResponseGenerated = FALSE,
    ExploratoryBackendCallMade = FALSE,
    ExploratoryFitReturned = FALSE,
    ExploratoryMetricComputed = FALSE,
    PlannedTerminalReceiptIssued = FALSE,
    RecoveryEvidenceComputed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "implement one parameterized planned-seed generation adapter that",
      "reuses the qualified stochastic semantics, bind its exact operation",
      "to the dataset, pipeline, and run resource scopes, qualify it without",
      "opening 856, then rerun this reconciliation"
    )
  )
  payload <- list(
    Contract = contract,
    ParentSupersedingPlanHash = plan$PlanHash,
    ParentRequestManifestHash = request_manifest$ManifestHash,
    ParentWorkerManifestHash = worker_manifest$ManifestHash,
    ParentOrchestratorManifestHash = orchestrator_manifest$ManifestHash,
    EnvironmentIdentityRegistry = environment,
    GenerationAdapterRegistry = generation,
    RequestCoverageRegistry = coverage,
    ReadinessGateRegistry = gates,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3z_hash(payload)
  )), class = c("mfrmr_gtds3z_manifest", "list"))
  mfrmr_gtds3z_assert_manifest(manifest, resource_worker_path)
  manifest
}

mfrmr_gtds3z_assert_manifest <- function(
    manifest, resource_worker_path) {
  fields <- mfrmr_gtds3z_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3z_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed superseding D-SIM-3 reconciliation manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  environment <- manifest$EnvironmentIdentityRegistry
  generation <- manifest$GenerationAdapterRegistry
  coverage <- manifest$RequestCoverageRegistry
  gates <- manifest$ReadinessGateRegistry
  summary <- manifest$Summary
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3z_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3z_contract()) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds3z_implementation_identity()) &&
    identical(nrow(environment), 8L) &&
    all(environment$ExactIdentityMatch) &&
    identical(nrow(generation), 42L) &&
    identical(range(generation$DataSeed), c(856001001L, 856021002L)) &&
    all(generation$SeedBandId == contract$PlannedSeedBandId) &&
    all(generation$RequestIdentityBound) &&
    all(generation$ProfileSemanticsShadowQualified) &&
    all(generation$CurrentGenerationOperation ==
          "qualified_shadow_generator") &&
    all(!generation$PlannedSeedWithinCurrentGeneratorGuard) &&
    all(generation$PlannedSeedRejectedByCurrentGeneratorGuard) &&
    all(!generation$PlannedSeedGenerationAdapterBound) &&
    all(!generation$ExecutionAttempted) &&
    all(!generation$RngStreamOpened) &&
    all(!generation$ResponseGenerated) &&
    identical(coverage$ExpectedRequestCount, c(42L, 50L, 100L, 92L, 5L)) &&
    identical(coverage$IdentityBoundRequestCount,
              c(42L, 50L, 100L, 92L, 5L)) &&
    identical(coverage$ShadowImplementationQualifiedCount,
              c(42L, 50L, 100L, 92L, 5L)) &&
    identical(coverage$PlannedExecutionPathReady,
              c(FALSE, TRUE, TRUE, TRUE, TRUE)) &&
    all(!coverage$ExecutionAuthorized) &&
    identical(nrow(gates), 10L) &&
    identical(gates$GatePassed, c(rep(TRUE, 9L), FALSE)) &&
    identical(gates$Blocking, !gates$GatePassed) &&
    all(gates$ReconciliationOnly) && all(!gates$ExecutionAttempted) &&
    identical(summary$PassingReadinessGateCount, 9L) &&
    identical(summary$BlockingReadinessGateCount, 1L) &&
    identical(summary$EnvironmentIdentityCount, 8L) &&
    identical(summary$ExactEnvironmentIdentityCount, 8L) &&
    identical(summary$ExactRequestCount, 289L) &&
    identical(summary$IdentityBoundRequestCount, 289L) &&
    identical(summary$ShadowImplementationQualifiedRequestCount, 289L) &&
    identical(summary$PlannedGenerationRequestCount, 42L) &&
    identical(summary$PlannedSeedAdapterBoundCount, 0L) &&
    identical(summary$CurrentGeneratorGuardRejectionCount, 42L) &&
    isTRUE(summary$ReconciliationComplete) &&
    !isTRUE(summary$TechnicalLaunchReady) &&
    identical(summary$CurrentDisposition,
              "no_go_planned_generation_adapter_missing") &&
    !isTRUE(summary$IntegratedWorkloadCapacityQualified) &&
    !isTRUE(summary$IntegratedWorkloadCapacityRequiredForExploratoryLaunch) &&
    !isTRUE(summary$Planned855RngStreamOpened) &&
    !isTRUE(summary$Planned856RngStreamOpened) &&
    !isTRUE(summary$ExploratoryResponseGenerated) &&
    !isTRUE(summary$ExploratoryBackendCallMade) &&
    !isTRUE(summary$ExploratoryFitReturned) &&
    !isTRUE(summary$ExploratoryMetricComputed) &&
    !isTRUE(summary$PlannedTerminalReceiptIssued) &&
    !isTRUE(summary$RecoveryEvidenceComputed) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady) &&
    identical(summary$FeatureMaturity, "specified") &&
    file.exists(resource_worker_path)
  if (!valid) {
    stop("The superseding D-SIM-3 reconciliation evidence was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
