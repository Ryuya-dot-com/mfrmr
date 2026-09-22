# Draft.83d2b2b1g24 fresh-site one-shard issuance decision.
#
# Repository-internal only. This layer refreshes the b1g20 runtime/site
# evidence and either refuses issuance or creates one immutable R0201 record
# plus its still-unexecuted active manifest. It cannot generate responses.

mfrmr_gtwas_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwao_sha256_file",
    "mfrmr_gtwao_contract_hash_valid", "mfrmr_gtwao_isolated_runtime_probe",
    "mfrmr_gtwao_runtime_probe_hash_valid", "mfrmr_gtwao_site_probe",
    "mfrmr_gtwao_site_probe_hash_valid", "mfrmr_gtwao_safe_target",
    "mfrmr_gtwan_shard_manifest_hash_valid",
    "mfrmr_gtwar_contract_hash_valid",
    "mfrmr_gtwar_issuance_decision_hash_valid",
    "mfrmr_gtwar_authorization_record_hash_valid",
    "mfrmr_gtwar_active_manifest", "mfrmr_gtwar_active_manifest_hash_valid"
  )
  issuance_environment <- environment(mfrmr_gtwas_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = issuance_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g19--b1g23 chain before the b1g24 issuance layer: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwas_function_hash <- function(fun) {
  mfrmr_gta_hash(list(
    Formals = formals(fun),
    Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  ))
}

mfrmr_gtwas_policy <- function(validation_root) {
  source_path <- file.path(
    validation_root,
    "gtheory-weak-information-one-shard-issuance-0.2.3.R"
  )
  identity <- list(
    Contract = "one_shard_issuance_policy_b1g24_v1",
    SourceFileName = basename(source_path),
    SourceHash = mfrmr_gtwao_sha256_file(source_path),
    ParentEntrySourceHash =
      "eec3a92a69aa1d1378137342094e536c4c71c3674b15c7a1260869cbcb0d1394",
    ParentEntryWorkerHash =
      "a2ed1788b2ad96f3feb298beee67bff2aa99e8d97f3a874f6ed2bd32c3e799cd",
    ParentEntryPolicyHash =
      "61ee07c4ea86087a7ad8731ef374b38ec7f12621cc8e818501f4e4bab85abd07",
    ParentEntryContractHash =
      "0dca57ff5546d49c2ef49b27e89bd571d19fbbe93ea3698dbdb7d87b69abfd3a",
    CandidateShardId = "R0201", CandidateReplicate = 201L,
    CandidateProspectiveManifestHash =
      "dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9",
    CandidateShardCounts = c(
      Datasets = 30L, AtomicUnits = 120L, CandidateFits = 1080L,
      CandidateDecisions = 5760L, References = 240L
    ),
    RequiredGateIds = c(
      "ENTRY-01", "ACTIVE-CONVERSION-01", "RUNTIME-01",
      "SITE-RECEIPT-01", "SCOPE-01", "CONFIRM-01"
    ),
    MaximumAuthorizedShardCount = 1L,
    CompleteFailureDenominatorRequired = TRUE,
    ExactResumeRequired = TRUE,
    HeldExclusiveLockRequiredAtExecution = TRUE,
    ActivationMarkerRequiredAtExecution = TRUE,
    EarlyStoppingPermitted = FALSE,
    ConfirmationAccessPermitted = FALSE,
    ResponseGenerationPermittedDuringIssuance = FALSE,
    ModelFittingPermittedDuringIssuance = FALSE,
    LargeSimulationPermittedByRecord = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwas_policy")
}

mfrmr_gtwas_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwas_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity)) &&
    identical(policy$ParentEntrySourceHash,
              "eec3a92a69aa1d1378137342094e536c4c71c3674b15c7a1260869cbcb0d1394") &&
    identical(policy$ParentEntryWorkerHash,
              "a2ed1788b2ad96f3feb298beee67bff2aa99e8d97f3a874f6ed2bd32c3e799cd") &&
    identical(policy$ParentEntryPolicyHash,
              "61ee07c4ea86087a7ad8731ef374b38ec7f12621cc8e818501f4e4bab85abd07") &&
    identical(policy$ParentEntryContractHash,
              "0dca57ff5546d49c2ef49b27e89bd571d19fbbe93ea3698dbdb7d87b69abfd3a") &&
    identical(policy$CandidateShardId, "R0201") &&
    identical(policy$CandidateReplicate, 201L) &&
    identical(policy$MaximumAuthorizedShardCount, 1L) &&
    identical(policy$RequiredGateIds, c(
      "ENTRY-01", "ACTIVE-CONVERSION-01", "RUNTIME-01",
      "SITE-RECEIPT-01", "SCOPE-01", "CONFIRM-01"
    )) &&
    isTRUE(policy$CompleteFailureDenominatorRequired) &&
    isTRUE(policy$ExactResumeRequired) &&
    isTRUE(policy$HeldExclusiveLockRequiredAtExecution) &&
    isTRUE(policy$ActivationMarkerRequiredAtExecution) &&
    !isTRUE(policy$EarlyStoppingPermitted) &&
    !isTRUE(policy$ConfirmationAccessPermitted) &&
    !isTRUE(policy$ResponseGenerationPermittedDuringIssuance) &&
    !isTRUE(policy$ModelFittingPermittedDuringIssuance) &&
    !isTRUE(policy$LargeSimulationPermittedByRecord)
}

mfrmr_gtwas_dependency_hashes <- function() {
  functions <- list(
    runtime_probe = mfrmr_gtwao_isolated_runtime_probe,
    runtime_validator = mfrmr_gtwao_runtime_probe_hash_valid,
    site_probe = mfrmr_gtwao_site_probe,
    site_validator = mfrmr_gtwao_site_probe_hash_valid,
    issuance_decision = mfrmr_gtwas_decision,
    decision_validator = mfrmr_gtwas_decision_hash_valid,
    parent_go_decision_validator =
      mfrmr_gtwar_issuance_decision_hash_valid,
    record_validator = mfrmr_gtwar_authorization_record_hash_valid,
    active_manifest = mfrmr_gtwar_active_manifest,
    active_manifest_validator = mfrmr_gtwar_active_manifest_hash_valid
  )
  vapply(functions, mfrmr_gtwas_function_hash, character(1L))
}

mfrmr_gtwas_contract <- function(entry_contract, prospective_manifest,
                                  kernel_contract, validation_root) {
  mfrmr_gtwas_require_primitives()
  policy <- mfrmr_gtwas_policy(validation_root)
  if (!mfrmr_gtwar_contract_hash_valid(entry_contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !mfrmr_gtwao_contract_hash_valid(kernel_contract) ||
      !identical(entry_contract$ContractHash,
                 policy$ParentEntryContractHash) ||
      !identical(entry_contract$RecordBoundEntryPolicy$PolicyHash,
                 policy$ParentEntryPolicyHash) ||
      !identical(entry_contract$RecordBoundEntryPolicy$EntrySourceHash,
                 policy$ParentEntrySourceHash) ||
      !identical(entry_contract$RecordBoundEntryPolicy$WorkerSourceHash,
                 policy$ParentEntryWorkerHash) ||
      !identical(prospective_manifest$ManifestHash,
                 policy$CandidateProspectiveManifestHash) ||
      !identical(entry_contract$AuthorizationKernelContractHash,
                 kernel_contract$ContractHash) ||
      !identical(c(
        Datasets = prospective_manifest$DatasetCount,
        AtomicUnits = prospective_manifest$AtomicUnitCount,
        CandidateFits = prospective_manifest$CandidateFitRowCount,
        CandidateDecisions = prospective_manifest$CandidateDecisionRowCount,
        References = prospective_manifest$ReferenceRowCount
      ), policy$CandidateShardCounts)) {
    stop("Exact b1g20 and b1g23 one-shard inputs are required.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "one_shard_issuance_contract_b1g24_v1",
    EntryContractHash = entry_contract$ContractHash,
    ProspectiveManifestHash = prospective_manifest$ManifestHash,
    AuthorizationKernelContractHash = kernel_contract$ContractHash,
    IsolatedRuntimeHash = entry_contract$IsolatedRuntimeHash,
    OutputRoot = kernel_contract$OutputRoot,
    IssuancePolicy = policy,
    DependencyHashes = mfrmr_gtwas_dependency_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity), ContractFrozen = TRUE,
    ResponseFreeIssuanceOnly = TRUE,
    MaximumAuthorizedShardCount = 1L,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE,
    LargeSimulationMayStart = FALSE
  )), class = "mfrmr_gtwas_contract")
}

mfrmr_gtwas_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "EntryContractHash", "ProspectiveManifestHash",
    "AuthorizationKernelContractHash", "IsolatedRuntimeHash", "OutputRoot",
    "IssuancePolicy", "DependencyHashes"
  )
  inherits(contract, "mfrmr_gtwas_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwas_policy_hash_valid(contract$IssuancePolicy) &&
    identical(contract$DependencyHashes, mfrmr_gtwas_dependency_hashes()) &&
    identical(contract$EntryContractHash,
              contract$IssuancePolicy$ParentEntryContractHash) &&
    identical(contract$ProspectiveManifestHash,
              contract$IssuancePolicy$CandidateProspectiveManifestHash) &&
    isTRUE(contract$ContractFrozen) &&
    isTRUE(contract$ResponseFreeIssuanceOnly) &&
    identical(contract$MaximumAuthorizedShardCount, 1L) &&
    !isTRUE(contract$CalibrationResponsesUsed) &&
    !isTRUE(contract$ConfirmationResponsesUsed) &&
    !isTRUE(contract$LargeSimulationMayStart)
}

mfrmr_gtwas_decision <- function(contract, entry_contract,
                                  prospective_manifest, runtime, site,
                                  output_target) {
  if (!mfrmr_gtwas_contract_hash_valid(contract) ||
      !mfrmr_gtwar_contract_hash_valid(entry_contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !identical(contract$EntryContractHash, entry_contract$ContractHash) ||
      !identical(contract$ProspectiveManifestHash,
                 prospective_manifest$ManifestHash)) {
    stop("Exact b1g23 and b1g24 inputs are required.", call. = FALSE)
  }
  runtime_valid <- mfrmr_gtwao_runtime_probe_hash_valid(runtime) &&
    isTRUE(runtime$IsolatedRuntimeReady) &&
    identical(runtime$Runtime$RuntimeHash, contract$IsolatedRuntimeHash)
  site_valid <- mfrmr_gtwao_site_probe_hash_valid(site) &&
    isTRUE(site$SitePreflightReady) &&
    identical(site$AuthorizationKernelContractHash,
              contract$AuthorizationKernelContractHash) &&
    identical(site$OutputTargetHash, mfrmr_gta_hash(output_target))
  counts_valid <- identical(c(
    Datasets = prospective_manifest$DatasetCount,
    AtomicUnits = prospective_manifest$AtomicUnitCount,
    CandidateFits = prospective_manifest$CandidateFitRowCount,
    CandidateDecisions = prospective_manifest$CandidateDecisionRowCount,
    References = prospective_manifest$ReferenceRowCount
  ), contract$IssuancePolicy$CandidateShardCounts)
  gates <- data.frame(
    GateId = contract$IssuancePolicy$RequiredGateIds,
    ObservedPass = c(
      isTRUE(entry_contract$ReservedEntryPointImplementationReady),
      isTRUE(entry_contract$ActiveManifestConversionImplementationReady),
      runtime_valid, site_valid,
      counts_valid && identical(prospective_manifest$ShardId, "R0201") &&
        identical(prospective_manifest$Replicate, 201L),
      !isTRUE(prospective_manifest$ConfirmationUse) &&
        !isTRUE(contract$IssuancePolicy$ConfirmationAccessPermitted)
    ),
    RequiredForIssuance = TRUE,
    stringsAsFactors = FALSE
  )
  ready <- all(gates$ObservedPass & gates$RequiredForIssuance)
  identity <- list(
    Contract = entry_contract$RecordBoundEntryPolicy$
      RequiredIssuanceDecisionContract,
    EntryContractHash = entry_contract$ContractHash,
    PolicyHash = entry_contract$RecordBoundEntryPolicy$PolicyHash,
    ProspectiveManifestHash = prospective_manifest$ManifestHash,
    RuntimeReceiptHash = runtime$ProbeHash,
    SiteReceiptHash = site$ProbeHash,
    OutputTargetHash = mfrmr_gta_hash(output_target),
    GateRegistry = gates, IssuanceReady = ready,
    Decision = if (ready) {
      "go_one_shard_record_may_be_issued"
    } else "no_go_record_must_not_be_issued",
    MaximumShardCount = 1L,
    EarlyStoppingPermitted = FALSE, ConfirmationUse = FALSE,
    CalibrationResponsesUsed = FALSE, ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    DecisionHash = mfrmr_gta_hash(identity),
    IssuanceDecisionComplete = TRUE,
    AuthorizationRecordMayBeIssued = ready,
    CalibrationExecutionStarted = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwar_issuance_decision")
}

mfrmr_gtwas_decision_hash_valid <- function(
    decision, contract, entry_contract, prospective_manifest, runtime, site,
    output_target) {
  fields <- c(
    "Contract", "EntryContractHash", "PolicyHash",
    "ProspectiveManifestHash", "RuntimeReceiptHash", "SiteReceiptHash",
    "OutputTargetHash", "GateRegistry", "IssuanceReady", "Decision",
    "MaximumShardCount", "EarlyStoppingPermitted", "ConfirmationUse",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  if (!inherits(decision, "mfrmr_gtwar_issuance_decision") ||
      !all(fields %in% names(decision)) ||
      !mfrmr_gtwas_contract_hash_valid(contract) ||
      !mfrmr_gtwar_contract_hash_valid(entry_contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !mfrmr_gtwao_runtime_probe_hash_valid(runtime) ||
      !mfrmr_gtwao_site_probe_hash_valid(site) ||
      !identical(contract$EntryContractHash,
                 entry_contract$ContractHash) ||
      !identical(contract$ProspectiveManifestHash,
                 prospective_manifest$ManifestHash) ||
      !identical(contract$AuthorizationKernelContractHash,
                 entry_contract$AuthorizationKernelContractHash) ||
      !is.data.frame(decision$GateRegistry)) return(FALSE)
  runtime_valid <- isTRUE(runtime$IsolatedRuntimeReady) &&
    identical(runtime$Runtime$RuntimeHash, contract$IsolatedRuntimeHash)
  site_valid <- isTRUE(site$SitePreflightReady) &&
    identical(site$AuthorizationKernelContractHash,
              contract$AuthorizationKernelContractHash) &&
    identical(site$OutputTargetHash, mfrmr_gta_hash(output_target))
  counts_valid <- identical(c(
    Datasets = prospective_manifest$DatasetCount,
    AtomicUnits = prospective_manifest$AtomicUnitCount,
    CandidateFits = prospective_manifest$CandidateFitRowCount,
    CandidateDecisions = prospective_manifest$CandidateDecisionRowCount,
    References = prospective_manifest$ReferenceRowCount
  ), contract$IssuancePolicy$CandidateShardCounts)
  expected_gates <- data.frame(
    GateId = contract$IssuancePolicy$RequiredGateIds,
    ObservedPass = c(
      isTRUE(entry_contract$ReservedEntryPointImplementationReady),
      isTRUE(entry_contract$ActiveManifestConversionImplementationReady),
      runtime_valid, site_valid,
      counts_valid && identical(prospective_manifest$ShardId, "R0201") &&
        identical(prospective_manifest$Replicate, 201L),
      !isTRUE(prospective_manifest$ConfirmationUse) &&
        !isTRUE(contract$IssuancePolicy$ConfirmationAccessPermitted)
    ),
    RequiredForIssuance = TRUE,
    stringsAsFactors = FALSE
  )
  ready <- all(expected_gates$ObservedPass)
  expected_decision <- if (ready) {
    "go_one_shard_record_may_be_issued"
  } else "no_go_record_must_not_be_issued"
  base_valid <-
    identical(decision$DecisionHash, mfrmr_gta_hash(decision[fields])) &&
    identical(decision$Contract,
              entry_contract$RecordBoundEntryPolicy$
                RequiredIssuanceDecisionContract) &&
    identical(decision$EntryContractHash, entry_contract$ContractHash) &&
    identical(decision$PolicyHash,
              entry_contract$RecordBoundEntryPolicy$PolicyHash) &&
    identical(decision$ProspectiveManifestHash,
              prospective_manifest$ManifestHash) &&
    identical(decision$RuntimeReceiptHash, runtime$ProbeHash) &&
    identical(decision$SiteReceiptHash, site$ProbeHash) &&
    identical(decision$OutputTargetHash, mfrmr_gta_hash(output_target)) &&
    identical(decision$GateRegistry, expected_gates) &&
    identical(decision$IssuanceReady, ready) &&
    identical(decision$Decision, expected_decision) &&
    identical(decision$MaximumShardCount, 1L) &&
    !isTRUE(decision$EarlyStoppingPermitted) &&
    !isTRUE(decision$ConfirmationUse) &&
    !isTRUE(decision$CalibrationResponsesUsed) &&
    !isTRUE(decision$ConfirmationResponsesUsed) &&
    isTRUE(decision$IssuanceDecisionComplete) &&
    identical(decision$AuthorizationRecordMayBeIssued, ready) &&
    !isTRUE(decision$CalibrationExecutionStarted) &&
    !isTRUE(decision$CalibrationDataGenerated) &&
    !isTRUE(decision$CalibrationResultsViewed)
  base_valid && (!ready || mfrmr_gtwar_issuance_decision_hash_valid(
    decision, entry_contract, prospective_manifest, runtime, site,
    output_target
  ))
}

mfrmr_gtwas_preflight <- function(contract, entry_contract,
                                   prospective_manifest, kernel_contract,
                                   kernel_worker_path, project_root) {
  if (!mfrmr_gtwas_contract_hash_valid(contract) ||
      !mfrmr_gtwar_contract_hash_valid(entry_contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !mfrmr_gtwao_contract_hash_valid(kernel_contract) ||
      !identical(contract$EntryContractHash, entry_contract$ContractHash) ||
      !identical(contract$ProspectiveManifestHash,
                 prospective_manifest$ManifestHash) ||
      !identical(contract$AuthorizationKernelContractHash,
                 kernel_contract$ContractHash)) {
    stop("Exact issuance, entry, shard, and kernel contracts are required.",
         call. = FALSE)
  }
  project_root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  runtime <- mfrmr_gtwao_isolated_runtime_probe(
    kernel_contract, kernel_worker_path
  )
  site <- mfrmr_gtwao_site_probe(kernel_contract, project_root)
  output_target <- mfrmr_gtwao_safe_target(file.path(
    project_root, kernel_contract$OutputRoot
  ))
  decision <- mfrmr_gtwas_decision(
    contract, entry_contract, prospective_manifest, runtime, site,
    output_target
  )
  decision_valid <- mfrmr_gtwas_decision_hash_valid(
    decision, contract, entry_contract, prospective_manifest, runtime, site,
    output_target
  )
  identity <- list(
    Contract = "one_shard_issuance_preflight_b1g24_v1",
    IssuanceContractHash = contract$ContractHash,
    EntryContractHash = entry_contract$ContractHash,
    ProspectiveManifestHash = prospective_manifest$ManifestHash,
    AuthorizationKernelContractHash = kernel_contract$ContractHash,
    RuntimeReceiptHash = runtime$ProbeHash,
    SiteReceiptHash = site$ProbeHash,
    OutputTarget = output_target,
    DecisionHash = decision$DecisionHash,
    DecisionValid = decision_valid,
    IssuanceReady = decision_valid && isTRUE(decision$IssuanceReady),
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    PreflightHash = mfrmr_gta_hash(identity),
    RuntimeReceipt = runtime, SiteReceipt = site, Decision = decision,
    AuthorizationRecordIssued = FALSE,
    CalibrationExecutionStarted = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    LargeSimulationMayStart = FALSE
  )), class = "mfrmr_gtwas_preflight")
}

mfrmr_gtwas_preflight_hash_valid <- function(preflight, contract,
                                              entry_contract,
                                              prospective_manifest) {
  fields <- c(
    "Contract", "IssuanceContractHash", "EntryContractHash",
    "ProspectiveManifestHash", "AuthorizationKernelContractHash",
    "RuntimeReceiptHash", "SiteReceiptHash", "OutputTarget",
    "DecisionHash", "DecisionValid", "IssuanceReady",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  if (!inherits(preflight, "mfrmr_gtwas_preflight") ||
      !all(fields %in% names(preflight)) ||
      !mfrmr_gtwas_contract_hash_valid(contract) ||
      !mfrmr_gtwar_contract_hash_valid(entry_contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !mfrmr_gtwao_runtime_probe_hash_valid(preflight$RuntimeReceipt) ||
      !mfrmr_gtwao_site_probe_hash_valid(preflight$SiteReceipt) ||
      !mfrmr_gtwas_decision_hash_valid(
        preflight$Decision, contract, entry_contract, prospective_manifest,
        preflight$RuntimeReceipt, preflight$SiteReceipt,
        preflight$OutputTarget
      )) return(FALSE)
  decision_valid <- isTRUE(mfrmr_gtwas_decision_hash_valid(
    preflight$Decision, contract, entry_contract, prospective_manifest,
    preflight$RuntimeReceipt, preflight$SiteReceipt,
    preflight$OutputTarget
  ))
  inherits(preflight, "mfrmr_gtwas_preflight") &&
    identical(preflight$PreflightHash, mfrmr_gta_hash(preflight[fields])) &&
    identical(preflight$IssuanceContractHash, contract$ContractHash) &&
    identical(preflight$EntryContractHash, entry_contract$ContractHash) &&
    identical(preflight$ProspectiveManifestHash,
              prospective_manifest$ManifestHash) &&
    identical(preflight$AuthorizationKernelContractHash,
              contract$AuthorizationKernelContractHash) &&
    identical(preflight$RuntimeReceiptHash,
              preflight$RuntimeReceipt$ProbeHash) &&
    identical(preflight$SiteReceiptHash, preflight$SiteReceipt$ProbeHash) &&
    identical(preflight$DecisionHash, preflight$Decision$DecisionHash) &&
    identical(preflight$DecisionValid, decision_valid) &&
    identical(preflight$IssuanceReady,
              decision_valid && isTRUE(preflight$Decision$IssuanceReady)) &&
    !isTRUE(preflight$AuthorizationRecordIssued) &&
    !isTRUE(preflight$CalibrationExecutionStarted) &&
    !isTRUE(preflight$CalibrationDataGenerated) &&
    !isTRUE(preflight$CalibrationResultsViewed) &&
    !isTRUE(preflight$ConfirmationAuthorized) &&
    !isTRUE(preflight$LargeSimulationMayStart) &&
    !isTRUE(preflight$CalibrationResponsesUsed) &&
    !isTRUE(preflight$ConfirmationResponsesUsed)
}

mfrmr_gtwas_issue_record <- function(contract, entry_contract,
                                      prospective_manifest, preflight) {
  if (!mfrmr_gtwas_preflight_hash_valid(
        preflight, contract, entry_contract, prospective_manifest
      ) || !isTRUE(preflight$IssuanceReady) ||
      !identical(preflight$Decision$Decision,
                 "go_one_shard_record_may_be_issued")) {
    stop("All six fresh one-shard issuance gates must pass.", call. = FALSE)
  }
  identity <- list(
    Contract = "one_shard_execution_authorization_b1g24_v1",
    EntryContractHash = entry_contract$ContractHash,
    PolicyHash = entry_contract$RecordBoundEntryPolicy$PolicyHash,
    ShardId = prospective_manifest$ShardId,
    Replicate = prospective_manifest$Replicate,
    ProspectiveManifestHash = prospective_manifest$ManifestHash,
    RuntimeReceiptHash = preflight$RuntimeReceipt$ProbeHash,
    SiteReceiptHash = preflight$SiteReceipt$ProbeHash,
    OutputTarget = preflight$OutputTarget,
    AuthorizationScope = "one_exact_reserved_shard",
    MaximumShardCount = 1L,
    CompleteFailureDenominatorRequired = TRUE,
    EarlyStoppingPermitted = FALSE,
    ConfirmationUse = FALSE,
    ProductionIssuance = TRUE,
    ExecutionAuthorized = TRUE,
    CalibrationExecutionAuthorized = TRUE,
    AuthorizationRecordIssued = TRUE,
    IssuanceDecisionHash = preflight$Decision$DecisionHash
  )
  record <- structure(c(identity, list(
    AuthorizationRecordHash = mfrmr_gta_hash(identity),
    RuntimeReceipt = preflight$RuntimeReceipt,
    SiteReceipt = preflight$SiteReceipt,
    IssuanceDecision = preflight$Decision,
    CalibrationExecutionStarted = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwar_authorization_record")
  if (!mfrmr_gtwar_authorization_record_hash_valid(
    record, entry_contract, prospective_manifest
  )) stop("The issued one-shard record failed validation.", call. = FALSE)
  record
}

mfrmr_gtwas_audit <- function(contract, entry_contract,
                               prospective_manifest, preflight, record,
                               active_manifest) {
  if (!mfrmr_gtwas_preflight_hash_valid(
        preflight, contract, entry_contract, prospective_manifest
      ) || !mfrmr_gtwar_authorization_record_hash_valid(
        record, entry_contract, prospective_manifest
      ) || !mfrmr_gtwar_active_manifest_hash_valid(
        active_manifest, entry_contract
      ) || !identical(active_manifest$AuthorizationRecordHash,
                      record$AuthorizationRecordHash) ||
      !identical(active_manifest$SourceManifestHash,
                 prospective_manifest$ManifestHash)) {
    stop("Exact preflight, record, and active R0201 manifest are required.",
         call. = FALSE)
  }
  root_absent <- !file.exists(preflight$OutputTarget) &&
    !dir.exists(preflight$OutputTarget)
  lock_path <- paste0(
    preflight$OutputTarget,
    entry_contract$AuthorizationKernelPolicy$LockDirectorySuffix
  )
  lock_absent <- !file.exists(lock_path) && !dir.exists(lock_path)
  identity <- list(
    Contract = "one_shard_issuance_audit_b1g24_v1",
    IssuanceContractHash = contract$ContractHash,
    EntryContractHash = entry_contract$ContractHash,
    ProspectiveManifestHash = prospective_manifest$ManifestHash,
    PreflightHash = preflight$PreflightHash,
    DecisionHash = preflight$Decision$DecisionHash,
    AuthorizationRecordHash = record$AuthorizationRecordHash,
    ActiveManifestHash = active_manifest$ActiveManifestHash,
    OutputTargetHash = mfrmr_gta_hash(preflight$OutputTarget),
    ReservedRootAbsentAfterIssuance = root_absent,
    ReservedLockAbsentAfterIssuance = lock_absent,
    CandidateShardCounts = c(
      Datasets = active_manifest$DatasetCount,
      AtomicUnits = active_manifest$AtomicUnitCount,
      CandidateFits = active_manifest$CandidateFitRowCount,
      CandidateDecisions = active_manifest$CandidateDecisionRowCount,
      References = active_manifest$ReferenceRowCount
    ),
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity), IssuanceAuditComplete = TRUE,
    SixGateIssuancePassed = TRUE,
    AuthorizationRecordIssued = TRUE,
    ActiveReservedManifestIssued = TRUE,
    FreshRuntimeReceiptBound = TRUE,
    FreshSiteReceiptBound = TRUE,
    AuthorizationRNG01Closed = TRUE,
    AuthorizationActivationEligible = TRUE,
    AuthorizedSingleShardRunnerReady = TRUE,
    Replicate201MayBeOpened = TRUE,
    OneShardExecutionAuthorized = TRUE,
    LargeSimulationMayStart = FALSE,
    CalibrationExecutionStarted = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwas_audit")
}

mfrmr_gtwas_audit_hash_valid <- function(audit, contract, entry_contract,
                                          prospective_manifest, preflight,
                                          record, active_manifest) {
  fields <- c(
    "Contract", "IssuanceContractHash", "EntryContractHash",
    "ProspectiveManifestHash", "PreflightHash", "DecisionHash",
    "AuthorizationRecordHash", "ActiveManifestHash", "OutputTargetHash",
    "ReservedRootAbsentAfterIssuance", "ReservedLockAbsentAfterIssuance",
    "CandidateShardCounts", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  if (!mfrmr_gtwas_contract_hash_valid(contract) ||
      !mfrmr_gtwar_contract_hash_valid(entry_contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !mfrmr_gtwas_preflight_hash_valid(
        preflight, contract, entry_contract, prospective_manifest
      ) || !mfrmr_gtwar_authorization_record_hash_valid(
        record, entry_contract, prospective_manifest
      ) || !mfrmr_gtwar_active_manifest_hash_valid(
        active_manifest, entry_contract
      )) return(FALSE)
  inherits(audit, "mfrmr_gtwas_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$IssuanceContractHash, contract$ContractHash) &&
    identical(audit$EntryContractHash, entry_contract$ContractHash) &&
    identical(audit$ProspectiveManifestHash,
              prospective_manifest$ManifestHash) &&
    identical(audit$PreflightHash, preflight$PreflightHash) &&
    identical(audit$DecisionHash, preflight$Decision$DecisionHash) &&
    identical(audit$AuthorizationRecordHash,
              record$AuthorizationRecordHash) &&
    identical(audit$ActiveManifestHash, active_manifest$ActiveManifestHash) &&
    identical(audit$CandidateShardCounts,
              contract$IssuancePolicy$CandidateShardCounts) &&
    isTRUE(audit$ReservedRootAbsentAfterIssuance) &&
    isTRUE(audit$ReservedLockAbsentAfterIssuance) &&
    isTRUE(audit$IssuanceAuditComplete) &&
    isTRUE(audit$SixGateIssuancePassed) &&
    isTRUE(audit$AuthorizationRecordIssued) &&
    isTRUE(audit$ActiveReservedManifestIssued) &&
    isTRUE(audit$FreshRuntimeReceiptBound) &&
    isTRUE(audit$FreshSiteReceiptBound) &&
    isTRUE(audit$AuthorizationRNG01Closed) &&
    isTRUE(audit$AuthorizationActivationEligible) &&
    isTRUE(audit$AuthorizedSingleShardRunnerReady) &&
    isTRUE(audit$Replicate201MayBeOpened) &&
    isTRUE(audit$OneShardExecutionAuthorized) &&
    !isTRUE(audit$LargeSimulationMayStart) &&
    !isTRUE(audit$CalibrationExecutionStarted) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed) &&
    !isTRUE(audit$ConfirmationAuthorized) &&
    !isTRUE(audit$InferenceReady) && !isTRUE(audit$DecisionReady) &&
    !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
}
