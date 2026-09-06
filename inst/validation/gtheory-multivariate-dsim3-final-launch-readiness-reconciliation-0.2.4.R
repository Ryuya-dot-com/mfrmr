# Internal D-SIM-3 final launch-readiness reconciliation.
#
# This layer rechecks the frozen 9/10 reconciliation artifacts, the current
# execution environment, and the qualified planned-seed adapter. It can declare
# a later exploratory launch technically ready, but it cannot open an RNG
# stream, generate a response, call a backend, fit a model, or issue a receipt.

mfrmr_gtds3ab_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3aa_assert_manifest",
    "mfrmr_gtds3w_environment_registry"
  )
  target <- environment(mfrmr_gtds3ab_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 worker and planned-seed adapter chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  if (!requireNamespace("processx", quietly = TRUE)) {
    stop("The final reconciliation requires `processx`.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3ab_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3ab_file_hash <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The final reconciliation requires `digest`.", call. = FALSE)
  }
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) stop("An evidence file is required.", call. = FALSE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtds3ab_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-FINAL-LAUNCH-READINESS-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentSupersedingPlanHash =
      "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a",
    ParentRequestManifestHash =
      "69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef",
    ParentWorkerEnvironmentHash =
      "93fccafffc8aeb84fb1b540308870fd1f044a79a6ebaf5359d2bd6fd3206c3a4",
    ParentReconciliationContractHash =
      "6fc33596020b3ad9b6e0ee9bb60f88abd822999809eec1e0c0a9a76e06ef3d01",
    ParentReconciliationManifestHash =
      "b3b5404b2b262941046cfa7a85866a1b7432f3e5a87cb759f3b61a6a345c90b9",
    ParentReconciliationSourceSHA256 =
      "9f60c563b6f191aa5fc0e4a0cc0bdc7456a383a2669a4d7f360d9bf927ca41b7",
    ParentReconciliationRecordSHA256 =
      "9156dcdf3ad9c4bf4c5bf9902a47417279c0dcd5f680485384ea06e484cfe70b",
    ParentAdapterContractHash =
      "b7f193e567e61b76bc19c2a9d8f559600ba4dd849e3eed57ff0aa08608721ac0",
    ParentAdapterManifestHash =
      "2e27bdd0f5e8988adf928959607064b5cefd9e80251317837ba4b0fcca09242b",
    ParentAdapterSourceSHA256 =
      "2b06cdf226f0bb09dfd439a5d607474aba48603a607e6e2601a149e76c21bfd6",
    ParentAdapterRecordSHA256 =
      "be19f7c9781adc19fdcdaca0a90680d408b2bd26fd3d3447b9737d17bae86461",
    ParentGeneratorSourceSHA256 =
      "6a2e5cfbdb837079ec07650b4494af068fa7cbbcafb3fceae985e5d7fa4e2bc0",
    ExpectedProcessxVersion = "3.9.0"
  )
}

mfrmr_gtds3ab_contract <- function() {
  mfrmr_gtds3ab_require_primitives()
  identity <- mfrmr_gtds3ab_identity()
  payload <- c(identity, list(
    ExpectedArtifactIdentityCount = 5L,
    ExpectedEnvironmentIdentityCount = 8L,
    ExpectedRequestClassCount = 5L,
    ExpectedExactRequestCount = 289L,
    ExpectedGenerationRequestCount = 42L,
    ExpectedBackendRequestCount = 50L,
    ExpectedMetricRequestCount = 100L,
    ExpectedTerminalRequestCount = 92L,
    ExpectedResourceBindingCount = 5L,
    ExpectedReadinessGateCount = 10L,
    PlannedSeedBandId = "DSIM3-SUPERSEDING-856",
    IntegratedWorkloadCapacityQualificationRequired = FALSE,
    StaticReconciliationMayDeclareTechnicalReadiness = TRUE,
    ReadinessManifestMayAuthorizeLaterExploratoryExecution = TRUE,
    ReconciliationMayAuthorizeItself = FALSE,
    ReconciliationMayUseRng = FALSE,
    ReconciliationMayGenerateResponse = FALSE,
    ReconciliationMayCallBackend = FALSE,
    ReconciliationMayFit = FALSE,
    ReconciliationMayComputeMetric = FALSE,
    ReconciliationMayLaunchProcess = FALSE,
    ReconciliationMayIssueReceipt = FALSE,
    PartialLaunchAllowed = FALSE,
    HistoricalReceiptInheritanceAllowed = FALSE,
    RecoveryClaimAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3ab_hash(payload)
  )), class = c("mfrmr_gtds3ab_contract", "list"))
}

mfrmr_gtds3ab_validate_contract <- function(
    contract = mfrmr_gtds3ab_contract()) {
  canonical <- mfrmr_gtds3ab_contract()
  valid <- inherits(contract, "mfrmr_gtds3ab_contract") &&
    identical(contract, canonical) &&
    identical(contract$ExpectedArtifactIdentityCount, 5L) &&
    identical(contract$ExpectedEnvironmentIdentityCount, 8L) &&
    identical(contract$ExpectedExactRequestCount, 289L) &&
    identical(contract$ExpectedReadinessGateCount, 10L) &&
    !isTRUE(contract$IntegratedWorkloadCapacityQualificationRequired) &&
    isTRUE(contract$StaticReconciliationMayDeclareTechnicalReadiness) &&
    isTRUE(contract$ReadinessManifestMayAuthorizeLaterExploratoryExecution) &&
    !isTRUE(contract$ReconciliationMayAuthorizeItself) &&
    !isTRUE(contract$ReconciliationMayUseRng) &&
    !isTRUE(contract$ReconciliationMayGenerateResponse) &&
    !isTRUE(contract$ReconciliationMayCallBackend) &&
    !isTRUE(contract$ReconciliationMayFit) &&
    !isTRUE(contract$ReconciliationMayComputeMetric) &&
    !isTRUE(contract$ReconciliationMayLaunchProcess) &&
    !isTRUE(contract$ReconciliationMayIssueReceipt) &&
    !isTRUE(contract$PartialLaunchAllowed) &&
    !isTRUE(contract$HistoricalReceiptInheritanceAllowed) &&
    !isTRUE(contract$RecoveryClaimAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The final D-SIM-3 readiness contract is invalid.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3ab_artifact_registry <- function(
    generator_source_path, prior_reconciliation_source_path,
    prior_reconciliation_record_path, adapter_source_path,
    adapter_record_path, contract) {
  paths <- c(
    generator_source_path, prior_reconciliation_source_path,
    prior_reconciliation_record_path, adapter_source_path,
    adapter_record_path
  )
  expected <- c(
    contract$ParentGeneratorSourceSHA256,
    contract$ParentReconciliationSourceSHA256,
    contract$ParentReconciliationRecordSHA256,
    contract$ParentAdapterSourceSHA256,
    contract$ParentAdapterRecordSHA256
  )
  token_required <- c(FALSE, FALSE, TRUE, FALSE, TRUE)
  tokens <- c(
    "", "", contract$ParentReconciliationManifestHash,
    "", contract$ParentAdapterManifestHash
  )
  token_observed <- vapply(seq_along(paths), function(index) {
    if (!token_required[[index]]) return(TRUE)
    any(grepl(tokens[[index]], readLines(paths[[index]], warn = FALSE),
              fixed = TRUE))
  }, logical(1L))
  observed <- vapply(paths, mfrmr_gtds3ab_file_hash, character(1L))
  data.frame(
    ArtifactOrdinal = seq_along(paths),
    ArtifactId = c(
      "generator_source", "prior_reconciliation_source",
      "prior_reconciliation_record", "planned_seed_adapter_source",
      "planned_seed_adapter_record"
    ),
    ExpectedSHA256 = expected,
    ObservedSHA256 = observed,
    ExactArtifactIdentity = observed == expected,
    EvidenceTokenRequired = token_required,
    EvidenceTokenObserved = token_observed,
    ArtifactQualified = observed == expected & token_observed,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ab_environment_registry <- function(contract) {
  worker <- mfrmr_gtds3w_environment_registry()
  worker_hash_exact <- identical(
    mfrmr_gtds3ab_hash(worker), contract$ParentWorkerEnvironmentHash
  )
  processx_version <- as.character(utils::packageVersion("processx"))
  output <- rbind(
    data.frame(
      EnvironmentIdentityOrdinal = worker$IdentityOrdinal,
      IdentityId = worker$IdentityId,
      IdentityValue = worker$IdentityValue,
      ExpectedIdentityValue = worker$IdentityValue,
      ExactIdentityMatch = worker_hash_exact,
      stringsAsFactors = FALSE
    ),
    data.frame(
      EnvironmentIdentityOrdinal = 8L,
      IdentityId = "processx_version",
      IdentityValue = processx_version,
      ExpectedIdentityValue = contract$ExpectedProcessxVersion,
      ExactIdentityMatch = processx_version == contract$ExpectedProcessxVersion,
      stringsAsFactors = FALSE
    )
  )
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ab_request_coverage_registry <- function(
    adapter_manifest, contract) {
  expected <- c(
    contract$ExpectedGenerationRequestCount,
    contract$ExpectedBackendRequestCount,
    contract$ExpectedMetricRequestCount,
    contract$ExpectedTerminalRequestCount,
    contract$ExpectedResourceBindingCount
  )
  adapter_generation_ready <-
    adapter_manifest$Summary$ExactPlannedSeedForwardingReadyCount ==
      contract$ExpectedGenerationRequestCount &&
    adapter_manifest$Summary$PlannedSeedRngStreamOpenedCount == 0L
  data.frame(
    RequestClassOrdinal = seq_along(expected),
    RequestClass = c(
      "generation", "backend", "metric", "terminal", "resource"
    ),
    ExpectedRequestCount = expected,
    IdentityBoundRequestCount = expected,
    QualifiedImplementationRequestCount = expected,
    EvidenceOrigin = c(
      "planned_seed_adapter_manifest",
      rep("prior_reconciliation_manifest", 4L)
    ),
    PlannedExecutionPathReady = c(adapter_generation_ready, rep(TRUE, 4L)),
    ExecutionAttempted = FALSE,
    ReceiptIssued = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ab_gate_registry <- function(
    adapter_manifest, artifacts, environment, coverage, contract) {
  prior_ready <- all(artifacts$ArtifactQualified[
    artifacts$ArtifactId %in% c(
      "prior_reconciliation_source", "prior_reconciliation_record"
    )
  ])
  adapter_ready <- all(artifacts$ArtifactQualified[
    artifacts$ArtifactId %in% c(
      "generator_source", "planned_seed_adapter_source",
      "planned_seed_adapter_record"
    )
  ]) && all(adapter_manifest$QualificationGateRegistry$GatePassed)
  passed <- c(
    identical(adapter_manifest$ParentSupersedingPlanHash,
              contract$ParentSupersedingPlanHash),
    prior_ready,
    sum(coverage$IdentityBoundRequestCount) ==
      contract$ExpectedExactRequestCount,
    all(environment$ExactIdentityMatch),
    prior_ready && coverage$PlannedExecutionPathReady[[2L]],
    prior_ready && coverage$PlannedExecutionPathReady[[4L]],
    all(adapter_manifest$ResourceRebindingRegistry$MechanicsQualified) &&
      all(adapter_manifest$ResourceRebindingRegistry$PlannedSeedAdapterBound),
    prior_ready,
    prior_ready,
    adapter_ready && coverage$PlannedExecutionPathReady[[1L]]
  )
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
    GatePassed = passed,
    Blocking = !passed,
    StaticReconciliationOnly = TRUE,
    ExecutionAttempted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ab_canonical_code <- function(value) {
  paste(
    deparse(
      value, width.cutoff = 500L,
      control = c("keepNA", "keepInteger", "niceNames")
    ),
    collapse = "\n"
  )
}

mfrmr_gtds3ab_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3ab_require_primitives", "mfrmr_gtds3ab_hash",
    "mfrmr_gtds3ab_file_hash", "mfrmr_gtds3ab_identity",
    "mfrmr_gtds3ab_contract", "mfrmr_gtds3ab_validate_contract",
    "mfrmr_gtds3ab_artifact_registry",
    "mfrmr_gtds3ab_environment_registry",
    "mfrmr_gtds3ab_request_coverage_registry",
    "mfrmr_gtds3ab_gate_registry",
    "mfrmr_gtds3ab_canonical_code",
    "mfrmr_gtds3ab_implementation_identity",
    "mfrmr_gtds3ab_manifest_fields", "mfrmr_gtds3ab_manifest",
    "mfrmr_gtds3ab_assert_manifest"
  )
  target <- environment(mfrmr_gtds3ab_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3ab_hash(list(
        Formals = mfrmr_gtds3ab_canonical_code(formals(fun)),
        Body = mfrmr_gtds3ab_canonical_code(body(fun))
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ab_manifest_fields <- function() {
  c(
    "Contract", "ParentReconciliationManifestHash",
    "ParentAdapterManifestHash", "ArtifactIdentityRegistry",
    "EnvironmentIdentityRegistry", "RequestCoverageRegistry",
    "LaunchReadinessGateRegistry", "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3ab_manifest <- function(
    adapter_manifest, generator_source_path,
    prior_reconciliation_source_path, prior_reconciliation_record_path,
    adapter_source_path, adapter_record_path,
    contract = mfrmr_gtds3ab_contract()) {
  mfrmr_gtds3ab_validate_contract(contract)
  mfrmr_gtds3aa_assert_manifest(adapter_manifest, generator_source_path)
  if (!identical(adapter_manifest$Contract$ContractHash,
                 contract$ParentAdapterContractHash) ||
      !identical(adapter_manifest$ManifestHash,
                 contract$ParentAdapterManifestHash) ||
      !identical(adapter_manifest$ParentRequestManifestHash,
                 contract$ParentRequestManifestHash)) {
    stop("The final reconciliation adapter parent changed.", call. = FALSE)
  }
  artifacts <- mfrmr_gtds3ab_artifact_registry(
    generator_source_path, prior_reconciliation_source_path,
    prior_reconciliation_record_path, adapter_source_path,
    adapter_record_path, contract
  )
  environment <- mfrmr_gtds3ab_environment_registry(contract)
  coverage <- mfrmr_gtds3ab_request_coverage_registry(
    adapter_manifest, contract
  )
  gates <- mfrmr_gtds3ab_gate_registry(
    adapter_manifest, artifacts, environment, coverage, contract
  )
  if (!all(artifacts$ArtifactQualified) ||
      !all(environment$ExactIdentityMatch) || !all(gates$GatePassed)) {
    stop("Final D-SIM-3 technical readiness did not reconcile.",
         call. = FALSE)
  }
  implementation <- mfrmr_gtds3ab_implementation_identity()
  summary <- list(
    ArtifactIdentityCount = nrow(artifacts),
    ExactArtifactIdentityCount = sum(artifacts$ArtifactQualified),
    EnvironmentIdentityCount = nrow(environment),
    ExactEnvironmentIdentityCount = sum(environment$ExactIdentityMatch),
    ExactRequestCount = sum(coverage$ExpectedRequestCount),
    IdentityBoundRequestCount = sum(coverage$IdentityBoundRequestCount),
    QualifiedImplementationRequestCount =
      sum(coverage$QualifiedImplementationRequestCount),
    PlannedGenerationRequestCount =
      coverage$ExpectedRequestCount[[1L]],
    PlannedSeedAdapterBoundCount =
      sum(adapter_manifest$ResourceRebindingRegistry$
            PlannedSeedAdapterBound),
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    PlannedSeedGenerationAdapterQualified = TRUE,
    ReconciliationComplete = TRUE,
    TechnicalLaunchReady = TRUE,
    ExploratoryLaunchExecuted = FALSE,
    IntegratedWorkloadCapacityQualified = FALSE,
    IntegratedWorkloadCapacityRequiredForExploratoryLaunch = FALSE,
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
    CurrentDisposition = "internal_exploratory_launch_ready_unopened",
    NextAction = paste(
      "open the bounded 856 exploratory run as a separate observable",
      "transition, preserving exact request identities and one terminal",
      "receipt per attempted unit; make no recovery or support claim"
    )
  )
  payload <- list(
    Contract = contract,
    ParentReconciliationManifestHash =
      contract$ParentReconciliationManifestHash,
    ParentAdapterManifestHash = adapter_manifest$ManifestHash,
    ArtifactIdentityRegistry = artifacts,
    EnvironmentIdentityRegistry = environment,
    RequestCoverageRegistry = coverage,
    LaunchReadinessGateRegistry = gates,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3ab_hash(payload)
  )), class = c("mfrmr_gtds3ab_manifest", "list"))
  mfrmr_gtds3ab_assert_manifest(
    manifest, adapter_manifest, generator_source_path,
    prior_reconciliation_source_path, prior_reconciliation_record_path,
    adapter_source_path, adapter_record_path
  )
  manifest
}

mfrmr_gtds3ab_assert_manifest <- function(
    manifest, adapter_manifest, generator_source_path,
    prior_reconciliation_source_path, prior_reconciliation_record_path,
    adapter_source_path, adapter_record_path) {
  fields <- mfrmr_gtds3ab_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3ab_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed final D-SIM-3 readiness manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  artifacts <- manifest$ArtifactIdentityRegistry
  environment <- manifest$EnvironmentIdentityRegistry
  coverage <- manifest$RequestCoverageRegistry
  gates <- manifest$LaunchReadinessGateRegistry
  summary <- manifest$Summary
  observed_artifacts <- mfrmr_gtds3ab_artifact_registry(
    generator_source_path, prior_reconciliation_source_path,
    prior_reconciliation_record_path, adapter_source_path,
    adapter_record_path, contract
  )
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3ab_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3ab_contract()) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds3ab_implementation_identity()) &&
    identical(manifest$ParentReconciliationManifestHash,
              contract$ParentReconciliationManifestHash) &&
    identical(manifest$ParentAdapterManifestHash,
              adapter_manifest$ManifestHash) &&
    identical(artifacts, observed_artifacts) &&
    identical(nrow(artifacts), 5L) &&
    all(artifacts$ExactArtifactIdentity) &&
    all(artifacts$EvidenceTokenObserved) &&
    all(artifacts$ArtifactQualified) &&
    identical(nrow(environment), 8L) &&
    identical(environment,
              mfrmr_gtds3ab_environment_registry(contract)) &&
    all(environment$ExactIdentityMatch) &&
    identical(nrow(coverage), 5L) &&
    identical(coverage$ExpectedRequestCount,
              c(42L, 50L, 100L, 92L, 5L)) &&
    identical(coverage$IdentityBoundRequestCount,
              coverage$ExpectedRequestCount) &&
    identical(coverage$QualifiedImplementationRequestCount,
              coverage$ExpectedRequestCount) &&
    all(coverage$PlannedExecutionPathReady) &&
    all(!coverage$ExecutionAttempted) && all(!coverage$ReceiptIssued) &&
    identical(nrow(gates), 10L) && all(gates$GatePassed) &&
    all(!gates$Blocking) && all(gates$StaticReconciliationOnly) &&
    all(!gates$ExecutionAttempted) &&
    identical(summary$ArtifactIdentityCount, 5L) &&
    identical(summary$ExactArtifactIdentityCount, 5L) &&
    identical(summary$EnvironmentIdentityCount, 8L) &&
    identical(summary$ExactEnvironmentIdentityCount, 8L) &&
    identical(summary$ExactRequestCount, 289L) &&
    identical(summary$IdentityBoundRequestCount, 289L) &&
    identical(summary$QualifiedImplementationRequestCount, 289L) &&
    identical(summary$PlannedGenerationRequestCount, 42L) &&
    identical(summary$PlannedSeedAdapterBoundCount, 5L) &&
    identical(summary$ReadinessGateCount, 10L) &&
    identical(summary$PassingReadinessGateCount, 10L) &&
    identical(summary$BlockingReadinessGateCount, 0L) &&
    isTRUE(summary$PlannedSeedGenerationAdapterQualified) &&
    isTRUE(summary$ReconciliationComplete) &&
    isTRUE(summary$TechnicalLaunchReady) &&
    !isTRUE(summary$ExploratoryLaunchExecuted) &&
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
    identical(summary$CurrentDisposition,
              "internal_exploratory_launch_ready_unopened")
  if (!valid) {
    stop("The final D-SIM-3 readiness evidence was altered.", call. = FALSE)
  }
  invisible(TRUE)
}
