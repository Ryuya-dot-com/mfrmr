# Internal D-SIM-3 terminal/resource shadow orchestrator.
#
# This layer rebinds the qualified fit/metric worker and the mechanically
# qualified five-scope controller to the superseding request identities. It
# issues qualification receipts only. It never issues a planned 856 terminal
# receipt or opens a reserved RNG stream.

mfrmr_gtds3y_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3x_manifest",
    "mfrmr_gtds3x_assert_manifest", "mfrmr_gtds3w_manifest",
    "mfrmr_gtds3w_assert_manifest", "mfrmr_gtds3u_manifest",
    "mfrmr_gtds3u_assert_manifest", "mfrmr_gtds3g_generate_profile",
    "mfrmr_gtds3p_plan", "mfrmr_gtds3w_capture_lmer"
  )
  target <- environment(mfrmr_gtds3y_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 request, worker, and resource chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3y_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3y_identity <- function() {
  list(
    ContractId =
      "MFRMR-GTHEORY-MV-DSIM3-TERMINAL-RESOURCE-ORCHESTRATOR-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentRequestContractHash =
      "c37fbedb03f0535d2e8aab1380949385ba10b0fc32b205f77df17074d52fd67e",
    ParentRequestManifestHash =
      "69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef",
    ParentWorkerContractHash =
      "9e5055fc47191f4426507c352b45b72a2a40256bd227dcf464d04e7058de44c7",
    ParentWorkerManifestHash =
      "566faa25b496f32137fc167cc26b37f172e5fe2b2be73b78a22517e9d1213eb1",
    ParentResourceContractHash =
      "535ab118a335a66bf0fd264ecc609249dc4e5042ffa1ac64aee1fdc846c94919",
    ParentResourceManifestHash =
      "2a752382b94d0eb0b488c1e7b96029f0f6cc786738997e2dc7c27f28c4051f9d",
    ParentSupersedingPlanHash =
      "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a"
  )
}

mfrmr_gtds3y_contract <- function() {
  mfrmr_gtds3y_require_primitives()
  identity <- mfrmr_gtds3y_identity()
  payload <- c(identity, list(
    ExpectedTemplateSuccessReceiptCount = 25L,
    ExpectedFaultProbeCount = 4L,
    ExpectedTerminalStateRebindingCount = 13L,
    ExpectedExactTerminalRequestCoverageCount = 92L,
    ExpectedDatasetTerminalRequestCoverageCount = 42L,
    ExpectedRouteTerminalRequestCoverageCount = 50L,
    ExpectedResourceRebindingCount = 5L,
    ExpectedReadinessGateCount = 10L,
    ExpectedPassingReadinessGateCount = 9L,
    ExpectedBlockingReadinessGateCount = 1L,
    FaultProbeIds = c(
      "generation_failure", "not_attempted_generation_dependency",
      "fit_failure", "metric_failure"
    ),
    AtomicResourceTerminalMap = c(
      dataset_generation = "generation_resource_limit",
      one_route_fit = "fit_resource_limit",
      one_route_metric = "metric_resource_limit"
    ),
    QualificationReceiptNamespace = "shadow_route_template",
    PlannedReceiptNamespace = "planned_856_unit",
    QualificationReceiptsCountIn856Denominator = FALSE,
    PlannedTerminalReceiptIssuanceAllowed = FALSE,
    HistoricalReceiptInheritanceAllowed = FALSE,
    HistoricalQualificationInheritanceAllowed = FALSE,
    FaultInjectionCountsAsExploratoryAttempt = FALSE,
    IntegratedWorkloadCapacityClaimAllowed = FALSE,
    ResourceMechanicsAreCapacityEvidence = FALSE,
    DiagnosticOverrideAllowed = FALSE,
    ScalarPoolingAcrossStrataAllowed = FALSE,
    PackageSelectedDecisionWeightsAllowed = FALSE,
    UnlaunchedUnitTerminalReceiptAllowed = FALSE,
    UnlaunchedUnitFailureImputationAllowed = FALSE,
    ReplacementLaunchAllowed = FALSE,
    Planned856RngStreamMayOpen = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    RecoveryClaimAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3y_hash(payload)
  )), class = c("mfrmr_gtds3y_contract", "list"))
}

mfrmr_gtds3y_validate_contract <- function(
    contract = mfrmr_gtds3y_contract()) {
  canonical <- mfrmr_gtds3y_contract()
  valid <- inherits(contract, "mfrmr_gtds3y_contract") &&
    identical(contract, canonical) &&
    identical(contract$ExpectedTemplateSuccessReceiptCount, 25L) &&
    identical(contract$ExpectedExactTerminalRequestCoverageCount, 92L) &&
    identical(contract$ExpectedResourceRebindingCount, 5L) &&
    identical(contract$ExpectedPassingReadinessGateCount, 9L) &&
    identical(contract$ExpectedBlockingReadinessGateCount, 1L) &&
    !isTRUE(contract$QualificationReceiptsCountIn856Denominator) &&
    !isTRUE(contract$PlannedTerminalReceiptIssuanceAllowed) &&
    !isTRUE(contract$HistoricalReceiptInheritanceAllowed) &&
    !isTRUE(contract$HistoricalQualificationInheritanceAllowed) &&
    !isTRUE(contract$FaultInjectionCountsAsExploratoryAttempt) &&
    !isTRUE(contract$IntegratedWorkloadCapacityClaimAllowed) &&
    !isTRUE(contract$ResourceMechanicsAreCapacityEvidence) &&
    !isTRUE(contract$DiagnosticOverrideAllowed) &&
    !isTRUE(contract$ScalarPoolingAcrossStrataAllowed) &&
    !isTRUE(contract$PackageSelectedDecisionWeightsAllowed) &&
    !isTRUE(contract$UnlaunchedUnitTerminalReceiptAllowed) &&
    !isTRUE(contract$UnlaunchedUnitFailureImputationAllowed) &&
    !isTRUE(contract$ReplacementLaunchAllowed) &&
    !isTRUE(contract$Planned856RngStreamMayOpen) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$RecoveryClaimAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 terminal/resource orchestrator contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3y_template_success_receipts <- function(
    worker_manifest, contract) {
  templates <- worker_manifest$TemplateRegistry
  fits <- worker_manifest$FitReceiptRegistry
  metrics <- worker_manifest$TemplateMetricVectorRegistry
  rows <- lapply(seq_len(nrow(templates)), function(index) {
    template <- templates[index, , drop = FALSE]
    fit_part <- fits[fits$TemplateId == template$TemplateId, , drop = FALSE]
    metric_part <- metrics[
      metrics$TemplateId == template$TemplateId, , drop = FALSE
    ]
    payload <- list(
      ContractHash = contract$ContractHash,
      ParentWorkerManifestHash = worker_manifest$ManifestHash,
      QualificationNamespace = contract$QualificationReceiptNamespace,
      TemplateId = template$TemplateId,
      ScenarioId = template$ScenarioId,
      RouteId = template$RouteId,
      ExemplarRouteUnitId = template$RouteUnitId,
      ShadowSeed = template$ShadowSeed,
      ShadowGenerationHash = template$ShadowGenerationHash,
      FitReceiptHashes = fit_part$FitReceiptHash,
      MetricVectorHashes = metric_part$MetricVectorHash,
      TerminalState = "complete_nonpromoting"
    )
    data.frame(
      QualificationReceiptOrdinal = as.integer(index),
      QualificationReceiptId = paste0(
        "D3Y-QS-", sprintf("%03d", index), "-",
        substr(mfrmr_gtds3y_hash(payload), 1L, 16L)
      ),
      QualificationNamespace = contract$QualificationReceiptNamespace,
      TemplateId = template$TemplateId,
      ScenarioId = template$ScenarioId,
      RouteId = template$RouteId,
      ExemplarRouteUnitId = template$RouteUnitId,
      ShadowSeed = template$ShadowSeed,
      ShadowGenerationHash = template$ShadowGenerationHash,
      FitReceiptCount = nrow(fit_part),
      MetricVectorCount = nrow(metric_part),
      SingularFitCount = sum(fit_part$Singular),
      TerminalState = "complete_nonpromoting",
      EvidenceHash = mfrmr_gtds3y_hash(payload),
      ResponseGenerated = TRUE,
      BackendCallMade = TRUE,
      FitReturned = TRUE,
      MetricComputed = TRUE,
      DiagnosticOverrideApplied = FALSE,
      QualificationReceiptIssued = TRUE,
      PlannedTerminalReceiptIssued = FALSE,
      CountsIn856Denominator = FALSE,
      PromotesSupport = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3y_generation_failure_probe <- function(coverage) {
  error <- tryCatch({
    mfrmr_gtds3g_generate_profile(
      "D3-UNKNOWN-SCENARIO", coverage = coverage, validate = FALSE
    )
    NULL
  }, error = function(condition) condition)
  list(
    FaultObserved = inherits(error, "error"),
    Evidence = if (inherits(error, "error")) conditionMessage(error) else "",
    BackendCallMade = FALSE, FitReturned = FALSE, MetricComputed = FALSE
  )
}

mfrmr_gtds3y_fit_failure_probe <- function() {
  data <- data.frame(
    Score = c(NA_real_, NA_real_),
    ObjectId = factor(c("O1", "O2")),
    ConditionId = factor(c("C1", "C2")),
    ObjectConditionId = factor(c("O1/C1", "O2/C2")),
    Stratum = factor(c("S1", "S1")),
    EventId = factor(c("E1", "E2"))
  )
  captured <- mfrmr_gtds3w_capture_lmer(
    Score ~ 1 + (1 | ObjectId), data
  )
  list(
    FaultObserved = inherits(captured$Fit, "error"),
    Evidence = if (inherits(captured$Fit, "error")) {
      conditionMessage(captured$Fit)
    } else "",
    BackendCallMade = TRUE,
    FitReturned = !inherits(captured$Fit, "error"),
    MetricComputed = FALSE
  )
}

mfrmr_gtds3y_metric_shape_ready <- function(
    coefficients, expected_strata) {
  observed <- sort(unique(as.character(coefficients$Stratum)), method = "radix")
  expected <- sort(as.character(expected_strata), method = "radix")
  identical(observed, expected) && nrow(coefficients) == length(expected) &&
    all(coefficients$CoefficientReady) &&
    all(is.finite(coefficients$G)) && all(is.finite(coefficients$Phi))
}

mfrmr_gtds3y_metric_failure_probe <- function(worker_manifest) {
  metrics <- worker_manifest$TemplateMetricVectorRegistry
  candidate <- metrics$TemplateId[metrics$StratumCount > 1L][[1L]]
  coefficients <- worker_manifest$FittedCoefficientRegistry[
    worker_manifest$FittedCoefficientRegistry$TemplateId == candidate,
    , drop = FALSE
  ]
  expected <- coefficients$Stratum
  incomplete <- coefficients[-nrow(coefficients), , drop = FALSE]
  ready <- mfrmr_gtds3y_metric_shape_ready(incomplete, expected)
  list(
    FaultObserved = !ready,
    Evidence = paste0(
      "missing_registered_stratum:", expected[[length(expected)]]
    ),
    BackendCallMade = TRUE, FitReturned = TRUE,
    MetricComputed = ready
  )
}

mfrmr_gtds3y_fault_probe_registry <- function(
    worker_manifest, coverage, contract) {
  generation <- mfrmr_gtds3y_generation_failure_probe(coverage)
  dependency <- list(
    FaultObserved = TRUE,
    Evidence = "generation_terminal_not_complete",
    BackendCallMade = FALSE, FitReturned = FALSE, MetricComputed = FALSE
  )
  fit <- mfrmr_gtds3y_fit_failure_probe()
  metric <- mfrmr_gtds3y_metric_failure_probe(worker_manifest)
  probes <- list(generation, dependency, fit, metric)
  terminal_states <- contract$FaultProbeIds
  rows <- lapply(seq_along(probes), function(index) {
    probe <- probes[[index]]
    payload <- list(
      ContractHash = contract$ContractHash,
      ProbeId = contract$FaultProbeIds[[index]],
      TerminalState = terminal_states[[index]],
      Evidence = probe$Evidence,
      BackendCallMade = probe$BackendCallMade,
      FitReturned = probe$FitReturned,
      MetricComputed = probe$MetricComputed
    )
    data.frame(
      FaultProbeOrdinal = as.integer(index),
      FaultProbeId = contract$FaultProbeIds[[index]],
      TerminalState = terminal_states[[index]],
      FaultObserved = probe$FaultObserved,
      EvidenceText = probe$Evidence,
      BackendCallMade = probe$BackendCallMade,
      FitReturned = probe$FitReturned,
      MetricComputed = probe$MetricComputed,
      FaultProbeHash = mfrmr_gtds3y_hash(payload),
      PlannedTerminalReceiptIssued = FALSE,
      CountsIn856Denominator = FALSE,
      CountsAsExploratoryAttempt = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3y_terminal_state_rebindings <- function(
    plan, template_receipts, faults, resource_manifest, contract) {
  states <- plan$Contract$InheritedTerminalStateRegistry
  routes <- plan$RouteUnitRegistry
  no_call <- table(factor(
    routes$FrozenNoCallTerminalState,
    levels = states$TerminalState
  ))
  resource_probes <- resource_manifest$ProcessProbeRegistry
  rows <- lapply(seq_len(nrow(states)), function(index) {
    state <- states[index, , drop = FALSE]
    state_id <- state$TerminalState[[1L]]
    fault <- faults[faults$TerminalState == state_id, , drop = FALSE]
    resource_scope <- names(contract$AtomicResourceTerminalMap)[
      contract$AtomicResourceTerminalMap == state_id
    ]
    resource <- resource_probes[
      resource_probes$ScopeId %in% resource_scope &
        resource_probes$ProbeKind %in% c("wall_timeout", "peak_rss"),
      , drop = FALSE
    ]
    evidence_kind <- if (state_id == "generation_complete") {
      "observed_shadow_generation"
    } else if (state_id == "complete_nonpromoting") {
      "observed_worker_template_success"
    } else if (nrow(fault) == 1L) {
      "observed_fault_injection"
    } else if (length(resource_scope) == 1L && nrow(resource) == 2L) {
      "observed_resource_enforcement"
    } else if (state_id %in% c(
      "prefit_rejected_as_planned", "not_applicable_as_frozen",
      "missing_contract_block_as_frozen"
    )) {
      "frozen_no_call_plan_semantics"
    } else if (state_id == "unrecorded_invalid") {
      "invalid_receipt_rejection_semantics"
    } else {
      "schema_semantics"
    }
    evidence_count <- if (state_id == "generation_complete") {
      length(unique(template_receipts$ShadowGenerationHash))
    } else if (state_id == "complete_nonpromoting") {
      nrow(template_receipts)
    } else if (nrow(fault) == 1L) {
      1L
    } else if (length(resource_scope) == 1L) {
      nrow(resource)
    } else if (state_id %in% c(
      "prefit_rejected_as_planned", "not_applicable_as_frozen",
      "missing_contract_block_as_frozen"
    )) {
      as.integer(no_call[[state_id]])
    } else 1L
    observed <- evidence_kind %in% c(
      "observed_shadow_generation", "observed_worker_template_success",
      "observed_fault_injection", "observed_resource_enforcement"
    )
    payload <- list(
      ContractHash = contract$ContractHash,
      TerminalState = state_id, UnitType = state$UnitType[[1L]],
      ValidTerminalReceipt = state$ValidTerminalReceipt[[1L]],
      EvidenceKind = evidence_kind, EvidenceCount = evidence_count,
      ExecutionObserved = observed
    )
    data.frame(
      TerminalRebindingOrdinal = as.integer(index),
      TerminalState = state_id,
      UnitType = state$UnitType,
      ValidTerminalReceipt = state$ValidTerminalReceipt,
      EvidenceKind = evidence_kind,
      EvidenceCount = as.integer(evidence_count),
      ExecutionObserved = observed,
      RebindingHash = mfrmr_gtds3y_hash(payload),
      RebindingQualified = evidence_count > 0L,
      HistoricalReceiptInherited = FALSE,
      PlannedTerminalReceiptIssued = FALSE,
      PromotesSupport = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3y_terminal_request_coverage <- function(
    request_manifest, worker_manifest, terminal_rebindings) {
  requests <- request_manifest$TerminalOrchestrationRequestRegistry
  backend <- worker_manifest$BackendRequestCoverageRegistry
  template_index <- match(requests$UnitId, backend$RouteUnitId)
  route <- requests$UnitType == "route"
  allowed <- strsplit(requests$AllowedTerminalStates, "|", fixed = TRUE)
  rebound <- terminal_rebindings$TerminalState[
    terminal_rebindings$RebindingQualified
  ]
  all_states_rebound <- vapply(allowed, function(states) {
    all(states %in% rebound)
  }, logical(1L))
  template_id <- rep(NA_character_, nrow(requests))
  template_id[route] <- backend$TemplateId[template_index[route]]
  data.frame(
    TerminalCoverageOrdinal = seq_len(nrow(requests)),
    TerminalRequestId = requests$TerminalRequestId,
    TerminalRequestHash = requests$RequestHash,
    UnitType = requests$UnitType,
    UnitId = requests$UnitId,
    ScenarioId = requests$ScenarioId,
    Replicate = requests$Replicate,
    TemplateId = template_id,
    AllowedTerminalStateCount = lengths(allowed),
    AllAllowedTerminalStatesRebound = all_states_rebound,
    OrchestratorTemplateQualified = all_states_rebound &
      (!route | !is.na(template_id)),
    QualificationReceiptIssued = FALSE,
    PlannedTerminalReceiptIssued = FALSE,
    CountsIn856DenominatorNow = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3y_resource_rebindings <- function(
    request_manifest, worker_manifest, resource_manifest, contract) {
  requests <- request_manifest$ResourceBindingRegistry
  scopes <- resource_manifest$ResourceScopeQualificationRegistry
  index <- match(requests$ScopeId, scopes$ScopeId)
  rows <- lapply(seq_len(nrow(requests)), function(row) {
    scope <- scopes[index[[row]], , drop = FALSE]
    worker_operation <- switch(
      requests$ScopeId[[row]],
      dataset_generation = "qualified_shadow_generator",
      one_route_fit = "qualified_two_family_fit_worker",
      one_route_metric = "qualified_nonpooled_metric_worker",
      one_dataset_pipeline = "qualified_generation_fit_metric_sequence",
      complete_exploratory_run = "registered_request_scheduler",
      stop("An unknown resource scope was requested.", call. = FALSE)
    )
    payload <- list(
      ContractHash = contract$ContractHash,
      ResourceBindingId = requests$ResourceBindingId[[row]],
      ResourceBindingHash = requests$BindingHash[[row]],
      ScopeId = requests$ScopeId[[row]],
      WorkerManifestHash = worker_manifest$ManifestHash,
      MechanicalResourceManifestHash = resource_manifest$ManifestHash,
      WorkerOperation = worker_operation
    )
    data.frame(
      ResourceRebindingOrdinal = as.integer(row),
      ResourceBindingId = requests$ResourceBindingId[[row]],
      ResourceBindingHash = requests$BindingHash[[row]],
      ScopeId = requests$ScopeId[[row]],
      MaximumWallSeconds = requests$MaximumWallSeconds[[row]],
      MaximumPeakRssMiB = requests$MaximumPeakRssMiB[[row]],
      MaximumConcurrentWorkers = requests$MaximumConcurrentWorkers[[row]],
      WorkerOperation = worker_operation,
      WorkerManifestHash = worker_manifest$ManifestHash,
      MechanicalResourceManifestHash = resource_manifest$ManifestHash,
      MechanicsQualified = scope$ResourceScopeQualified[[1L]],
      WorkerOperationBound = TRUE,
      IntegratedWorkloadCapacityQualified = FALSE,
      ResourceRebindingHash = mfrmr_gtds3y_hash(payload),
      QualifiedForSupersedingIdentity =
        scope$ResourceScopeQualified[[1L]],
      HistoricalMechanicsReceiptInherited = FALSE,
      ExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3y_gate_registry <- function() {
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "superseding_plan_identity_bound",
      "truth_operator_metric_reference_bound",
      "two_route_family_semantics_frozen",
      "exact_request_denominators_complete",
      "exact_environment_identity_frozen",
      "fit_metric_worker_shadow_qualified",
      "terminal_state_rebindings_qualified",
      "resource_scope_rebindings_qualified",
      "exact_terminal_request_coverage_complete",
      "launch_readiness_reconciled"
    ),
    GatePassed = c(rep(TRUE, 9L), FALSE),
    Blocking = c(rep(FALSE, 9L), TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3y_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3y_require_primitives", "mfrmr_gtds3y_hash",
    "mfrmr_gtds3y_identity", "mfrmr_gtds3y_contract",
    "mfrmr_gtds3y_validate_contract",
    "mfrmr_gtds3y_template_success_receipts",
    "mfrmr_gtds3y_generation_failure_probe",
    "mfrmr_gtds3y_fit_failure_probe",
    "mfrmr_gtds3y_metric_shape_ready",
    "mfrmr_gtds3y_metric_failure_probe",
    "mfrmr_gtds3y_fault_probe_registry",
    "mfrmr_gtds3y_terminal_state_rebindings",
    "mfrmr_gtds3y_terminal_request_coverage",
    "mfrmr_gtds3y_resource_rebindings", "mfrmr_gtds3y_gate_registry",
    "mfrmr_gtds3y_implementation_identity",
    "mfrmr_gtds3y_manifest_fields", "mfrmr_gtds3y_manifest",
    "mfrmr_gtds3y_assert_manifest"
  )
  target <- environment(mfrmr_gtds3y_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3y_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3y_manifest_fields <- function() {
  c(
    "Contract", "ParentRequestManifestHash", "ParentWorkerManifestHash",
    "ParentResourceManifestHash", "EnvironmentIdentityRegistry",
    "TemplateSuccessReceiptRegistry", "FaultProbeRegistry",
    "TerminalStateRebindingRegistry", "TerminalRequestCoverageRegistry",
    "ResourceRebindingRegistry", "ReadinessGateRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3y_manifest <- function(
    resource_worker_path, contract = mfrmr_gtds3y_contract(),
    request_manifest = mfrmr_gtds3x_manifest(),
    worker_manifest = mfrmr_gtds3w_manifest(), resource_manifest = NULL,
    plan = mfrmr_gtds3p_plan(), coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3y_validate_contract(contract)
  mfrmr_gtds3x_assert_manifest(request_manifest)
  mfrmr_gtds3w_assert_manifest(worker_manifest)
  if (is.null(resource_manifest)) {
    resource_manifest <- mfrmr_gtds3u_manifest(resource_worker_path)
  }
  mfrmr_gtds3u_assert_manifest(resource_manifest, resource_worker_path)
  if (!identical(request_manifest$Contract$ContractHash,
                 contract$ParentRequestContractHash) ||
      !identical(request_manifest$ManifestHash,
                 contract$ParentRequestManifestHash) ||
      !identical(worker_manifest$Contract$ContractHash,
                 contract$ParentWorkerContractHash) ||
      !identical(worker_manifest$ManifestHash,
                 contract$ParentWorkerManifestHash) ||
      !identical(resource_manifest$Contract$ContractHash,
                 contract$ParentResourceContractHash) ||
      !identical(resource_manifest$ManifestHash,
                 contract$ParentResourceManifestHash) ||
      !identical(plan$PlanHash, contract$ParentSupersedingPlanHash)) {
    stop("A D-SIM-3 orchestrator parent identity changed.", call. = FALSE)
  }
  success <- mfrmr_gtds3y_template_success_receipts(
    worker_manifest, contract
  )
  faults <- mfrmr_gtds3y_fault_probe_registry(
    worker_manifest, coverage, contract
  )
  terminal_states <- mfrmr_gtds3y_terminal_state_rebindings(
    plan, success, faults, resource_manifest, contract
  )
  terminal_coverage <- mfrmr_gtds3y_terminal_request_coverage(
    request_manifest, worker_manifest, terminal_states
  )
  resources <- mfrmr_gtds3y_resource_rebindings(
    request_manifest, worker_manifest, resource_manifest, contract
  )
  gates <- mfrmr_gtds3y_gate_registry()
  implementation <- mfrmr_gtds3y_implementation_identity()
  summary <- list(
    TemplateSuccessReceiptCount = nrow(success),
    QualifiedTemplateSuccessReceiptCount = sum(
      success$QualificationReceiptIssued
    ),
    SingularFitCountRetained = sum(success$SingularFitCount),
    FaultProbeCount = nrow(faults),
    QualifiedFaultProbeCount = sum(faults$FaultObserved),
    TerminalStateRebindingCount = nrow(terminal_states),
    QualifiedTerminalStateRebindingCount = sum(
      terminal_states$RebindingQualified
    ),
    ObservedTerminalStateRebindingCount = sum(
      terminal_states$ExecutionObserved
    ),
    ExactTerminalRequestCoverageCount = nrow(terminal_coverage),
    QualifiedExactTerminalRequestCoverageCount = sum(
      terminal_coverage$OrchestratorTemplateQualified
    ),
    DatasetTerminalRequestCoverageCount = sum(
      terminal_coverage$UnitType == "dataset"
    ),
    RouteTerminalRequestCoverageCount = sum(
      terminal_coverage$UnitType == "route"
    ),
    ResourceRebindingCount = nrow(resources),
    QualifiedResourceRebindingCount = sum(
      resources$QualifiedForSupersedingIdentity
    ),
    IntegratedWorkloadCapacityQualifiedCount = sum(
      resources$IntegratedWorkloadCapacityQualified
    ),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    EnvironmentIdentityFrozen = TRUE,
    FitMetricWorkerShadowQualified = TRUE,
    TerminalResourceOrchestratorQualified = TRUE,
    LaunchReadinessReconciled = FALSE,
    QualificationReceiptCount = nrow(success),
    PlannedTerminalReceiptCount = 0L,
    UnlaunchedUnitTerminalReceiptCount = 0L,
    ReplacementLaunchCount = 0L,
    Planned855RngStreamOpened = FALSE,
    Planned856RngStreamOpened = FALSE,
    ExploratoryResponseGenerated = FALSE,
    ExploratoryBackendCallMade = FALSE,
    RecoveryEvidenceComputed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    CurrentDisposition =
      "terminal_resource_orchestrator_shadow_qualified_reconciliation_required",
    NextAction = paste(
      "rerun one nonexecuting launch-readiness reconciliation against the",
      "exact environment, all 289 request hashes, the qualified worker,",
      "terminal rebindings, and five resource rebindings before any 856",
      "stream is considered"
    )
  )
  payload <- list(
    Contract = contract,
    ParentRequestManifestHash = request_manifest$ManifestHash,
    ParentWorkerManifestHash = worker_manifest$ManifestHash,
    ParentResourceManifestHash = resource_manifest$ManifestHash,
    EnvironmentIdentityRegistry = worker_manifest$EnvironmentIdentityRegistry,
    TemplateSuccessReceiptRegistry = success,
    FaultProbeRegistry = faults,
    TerminalStateRebindingRegistry = terminal_states,
    TerminalRequestCoverageRegistry = terminal_coverage,
    ResourceRebindingRegistry = resources,
    ReadinessGateRegistry = gates,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3y_hash(payload)
  )), class = c("mfrmr_gtds3y_manifest", "list"))
  mfrmr_gtds3y_assert_manifest(manifest, resource_worker_path)
  manifest
}

mfrmr_gtds3y_assert_manifest <- function(manifest, resource_worker_path) {
  fields <- mfrmr_gtds3y_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3y_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 terminal/resource orchestrator manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  success <- manifest$TemplateSuccessReceiptRegistry
  faults <- manifest$FaultProbeRegistry
  states <- manifest$TerminalStateRebindingRegistry
  terminal <- manifest$TerminalRequestCoverageRegistry
  resources <- manifest$ResourceRebindingRegistry
  gates <- manifest$ReadinessGateRegistry
  summary <- manifest$Summary
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3y_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3y_contract()) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds3y_implementation_identity()) &&
    identical(nrow(success), 25L) &&
    !anyDuplicated(success$QualificationReceiptId) &&
    !anyDuplicated(success$TemplateId) &&
    all(success$TerminalState == "complete_nonpromoting") &&
    all(success$ResponseGenerated) && all(success$BackendCallMade) &&
    all(success$FitReturned) && all(success$MetricComputed) &&
    all(!success$DiagnosticOverrideApplied) &&
    all(success$QualificationReceiptIssued) &&
    all(!success$PlannedTerminalReceiptIssued) &&
    all(!success$CountsIn856Denominator) &&
    all(!success$PromotesSupport) &&
    identical(sum(success$SingularFitCount), 12L) &&
    identical(nrow(faults), 4L) &&
    identical(faults$FaultProbeId, contract$FaultProbeIds) &&
    all(faults$FaultObserved) &&
    identical(faults$BackendCallMade, c(FALSE, FALSE, TRUE, TRUE)) &&
    identical(faults$FitReturned, c(FALSE, FALSE, FALSE, TRUE)) &&
    all(!faults$MetricComputed) &&
    all(!faults$PlannedTerminalReceiptIssued) &&
    all(!faults$CountsIn856Denominator) &&
    all(!faults$CountsAsExploratoryAttempt) &&
    identical(nrow(states), 13L) &&
    identical(states$TerminalState, c(
      "generation_complete", "generation_failure",
      "generation_resource_limit", "not_attempted_generation_dependency",
      "prefit_rejected_as_planned", "not_applicable_as_frozen",
      "missing_contract_block_as_frozen", "fit_failure",
      "fit_resource_limit", "metric_failure", "metric_resource_limit",
      "complete_nonpromoting", "unrecorded_invalid"
    )) && all(states$RebindingQualified) &&
    all(!states$HistoricalReceiptInherited) &&
    all(!states$PlannedTerminalReceiptIssued) &&
    all(!states$PromotesSupport) &&
    identical(nrow(terminal), 92L) &&
    identical(sum(terminal$UnitType == "dataset"), 42L) &&
    identical(sum(terminal$UnitType == "route"), 50L) &&
    !anyDuplicated(terminal$TerminalRequestId) &&
    all(terminal$AllAllowedTerminalStatesRebound) &&
    all(terminal$OrchestratorTemplateQualified) &&
    all(!terminal$QualificationReceiptIssued) &&
    all(!terminal$PlannedTerminalReceiptIssued) &&
    all(!terminal$CountsIn856DenominatorNow) &&
    identical(nrow(resources), 5L) &&
    identical(resources$ScopeId, c(
      "dataset_generation", "one_route_fit", "one_route_metric",
      "one_dataset_pipeline", "complete_exploratory_run"
    )) && all(resources$MechanicsQualified) &&
    all(resources$WorkerOperationBound) &&
    all(!resources$IntegratedWorkloadCapacityQualified) &&
    all(resources$QualifiedForSupersedingIdentity) &&
    all(!resources$HistoricalMechanicsReceiptInherited) &&
    all(!resources$ExecutionAuthorized) &&
    identical(nrow(gates), 10L) &&
    identical(sum(gates$GatePassed), 9L) &&
    identical(sum(gates$Blocking), 1L) &&
    identical(summary$TemplateSuccessReceiptCount, 25L) &&
    identical(summary$QualifiedTemplateSuccessReceiptCount, 25L) &&
    identical(summary$SingularFitCountRetained, 12L) &&
    identical(summary$FaultProbeCount, 4L) &&
    identical(summary$QualifiedFaultProbeCount, 4L) &&
    identical(summary$TerminalStateRebindingCount, 13L) &&
    identical(summary$QualifiedTerminalStateRebindingCount, 13L) &&
    identical(summary$ExactTerminalRequestCoverageCount, 92L) &&
    identical(summary$QualifiedExactTerminalRequestCoverageCount, 92L) &&
    identical(summary$DatasetTerminalRequestCoverageCount, 42L) &&
    identical(summary$RouteTerminalRequestCoverageCount, 50L) &&
    identical(summary$ResourceRebindingCount, 5L) &&
    identical(summary$QualifiedResourceRebindingCount, 5L) &&
    identical(summary$IntegratedWorkloadCapacityQualifiedCount, 0L) &&
    identical(summary$PassingReadinessGateCount, 9L) &&
    identical(summary$BlockingReadinessGateCount, 1L) &&
    isTRUE(summary$EnvironmentIdentityFrozen) &&
    isTRUE(summary$FitMetricWorkerShadowQualified) &&
    isTRUE(summary$TerminalResourceOrchestratorQualified) &&
    !isTRUE(summary$LaunchReadinessReconciled) &&
    identical(summary$PlannedTerminalReceiptCount, 0L) &&
    identical(summary$UnlaunchedUnitTerminalReceiptCount, 0L) &&
    identical(summary$ReplacementLaunchCount, 0L) &&
    !isTRUE(summary$Planned855RngStreamOpened) &&
    !isTRUE(summary$Planned856RngStreamOpened) &&
    !isTRUE(summary$ExploratoryResponseGenerated) &&
    !isTRUE(summary$ExploratoryBackendCallMade) &&
    !isTRUE(summary$RecoveryEvidenceComputed) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady) &&
    identical(
      summary$CurrentDisposition,
      "terminal_resource_orchestrator_shadow_qualified_reconciliation_required"
    ) && file.exists(resource_worker_path)
  if (!valid) {
    stop("The D-SIM-3 terminal/resource orchestrator evidence was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
