# Draft.83d2b2b1g23 response-free record-bound reserved entry point.
#
# Repository-internal only. This file implements the missing reserved-capable
# entry mechanics but issues no production authorization record and opens no
# reserved response. The exact b1g13 checkpoint loop and b1g18 preparation
# body are reused after one audited admission expression is removed from each.

mfrmr_gtwar_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwag_function_hash",
    "mfrmr_gtwag_manifest_hash_valid", "mfrmr_gtwag_execute",
    "mfrmr_gtwag_acceptance_ledger", "mfrmr_gtwae_cell_summary",
    "mfrmr_gtwal_generate", "mfrmr_gtwal_generation_hash_valid",
    "mfrmr_gtwam_prepare_unit", "mfrmr_gtwam_candidate_evaluator",
    "mfrmr_gtwam_reference_evaluator", "mfrmr_gtwan_shard_manifest_hash_valid",
    "mfrmr_gtwap_contract_hash_valid", "mfrmr_gtwap_fixture_manifest_hash_valid",
    "mfrmr_gtwaq_decision_hash_valid",
    "mfrmr_gtwaq_source_audit_hash_valid", "mfrmr_gtwao_sha256_file",
    "mfrmr_gtwao_policy_hash_valid", "mfrmr_gtwao_runtime_probe_hash_valid",
    "mfrmr_gtwao_site_probe_hash_valid", "mfrmr_gtwao_safe_target",
    "mfrmr_gtwao_lock_acquire", "mfrmr_gtwao_lock_release",
    "mfrmr_gtwao_activate_root"
  )
  entry_environment <- environment(mfrmr_gtwar_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = entry_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g13--b1g22 chain before the b1g23 entry point: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwar_function_hash <- function(fun) {
  mfrmr_gta_hash(list(
    Formals = formals(fun),
    Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  ))
}

mfrmr_gtwar_drop_one_admission <- function(fun, message) {
  parts <- as.list(body(fun))
  if (length(parts) < 2L || !identical(parts[[1L]], as.name("{"))) {
    stop("The parent function body is not a braced expression.", call. = FALSE)
  }
  text <- vapply(parts[-1L], function(expression) {
    paste(deparse(expression, width.cutoff = 500L), collapse = "\n")
  }, character(1L))
  hits <- which(grepl(message, text, fixed = TRUE))
  if (length(hits) != 1L) {
    stop("The exact single parent admission expression was not found.",
         call. = FALSE)
  }
  parts <- parts[-(hits[[1L]] + 1L)]
  body(fun) <- as.call(parts)
  fun
}

mfrmr_gtwar_prepare_core <- function() {
  fun <- mfrmr_gtwar_drop_one_admission(
    mfrmr_gtwam_prepare_unit,
    "The b1g18 nonreserved adapter cannot open a reserved replicate."
  )
  bridge <- new.env(parent = environment(fun))
  assign("mfrmr_gtwal_generate", mfrmr_gtwar_generate, envir = bridge)
  assign("mfrmr_gtwal_generation_hash_valid",
         mfrmr_gtwar_generation_hash_valid, envir = bridge)
  environment(fun) <- bridge
  fun
}

mfrmr_gtwar_execute_core <- function() {
  mfrmr_gtwar_drop_one_admission(
    mfrmr_gtwag_execute,
    "Only the exact nonreserved b1g13 mechanics run is authorized."
  )
}

mfrmr_gtwar_generate_core <- function() {
  mfrmr_gtwar_drop_one_admission(
    mfrmr_gtwal_generate,
    "b1g17 cannot open reserved calibration or confirmation replicates;"
  )
}

mfrmr_gtwar_policy <- function(worker_path) {
  validation_root <- dirname(worker_path)
  entry_path <- file.path(
    validation_root,
    "gtheory-weak-information-record-bound-entry-point-0.2.3.R"
  )
  guarded_path <- file.path(
    validation_root,
    "gtheory-weak-information-guarded-shard-runner-0.2.3.R"
  )
  exact_path <- file.path(
    validation_root,
    "gtheory-weak-information-stationarity-exact-resume-runner-0.2.3.R"
  )
  identity <- list(
    Contract = "record_bound_entry_policy_b1g23_v1",
    EntryFileName = basename(entry_path),
    EntrySourceHash = mfrmr_gtwao_sha256_file(entry_path),
    WorkerFileName = basename(worker_path),
    WorkerSourceHash = mfrmr_gtwao_sha256_file(worker_path),
    ParentGuardedRunnerFileName = basename(guarded_path),
    ParentGuardedRunnerSourceHash = mfrmr_gtwao_sha256_file(guarded_path),
    ParentExactRunnerFileName = basename(exact_path),
    ParentExactRunnerSourceHash = mfrmr_gtwao_sha256_file(exact_path),
    ParentPrepareFunctionHash =
      mfrmr_gtwag_function_hash(mfrmr_gtwam_prepare_unit),
    ParentGeneratorFunctionHash =
      mfrmr_gtwag_function_hash(mfrmr_gtwal_generate),
    ParentExecuteFunctionHash =
      mfrmr_gtwag_function_hash(mfrmr_gtwag_execute),
    ReusedPrepareCoreHash =
      mfrmr_gtwag_function_hash(mfrmr_gtwar_prepare_core()),
    ReusedGeneratorCoreHash =
      mfrmr_gtwag_function_hash(mfrmr_gtwar_generate_core()),
    ReusedExecuteCoreHash =
      mfrmr_gtwag_function_hash(mfrmr_gtwar_execute_core()),
    CandidateShardId = "R0201", CandidateReplicate = 201L,
    CandidateProspectiveManifestHash =
      "dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9",
    CandidateShardCounts = c(
      Datasets = 30L, AtomicUnits = 120L, CandidateFits = 1080L,
      CandidateDecisions = 5760L, References = 240L
    ),
    ReductionReplicate = 902L,
    ReservedCalibrationReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    MaximumAuthorizedShardCount = 1L,
    RequiredIssuanceDecisionContract =
      "one_shard_issuance_decision_b1g24_v1",
    RequiredIssuanceGateIds = c(
      "ENTRY-01", "ACTIVE-CONVERSION-01", "RUNTIME-01",
      "SITE-RECEIPT-01", "SCOPE-01", "CONFIRM-01"
    ),
    IssuedProductionRecordRequired = TRUE,
    ActiveManifestRequired = TRUE,
    RuntimeReceiptRequired = TRUE,
    FreshSiteReceiptRequired = TRUE,
    HeldExclusiveLockRequired = TRUE,
    ActivationMarkerRequired = TRUE,
    CompleteFailureDenominatorRequired = TRUE,
    ExactResumeRequired = TRUE,
    EarlyStoppingPermitted = FALSE,
    ConfirmationAccessPermitted = FALSE,
    ProductionIssuanceFunctionDefined = FALSE,
    ResponseGenerationPermittedDuringConstruction = FALSE,
    ModelFittingPermittedDuringConstruction = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwar_policy")
}

mfrmr_gtwar_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwar_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity)) &&
    identical(policy$CandidateShardId, "R0201") &&
    identical(policy$CandidateReplicate, 201L) &&
    identical(policy$MaximumAuthorizedShardCount, 1L) &&
    identical(policy$RequiredIssuanceDecisionContract,
              "one_shard_issuance_decision_b1g24_v1") &&
    identical(policy$RequiredIssuanceGateIds, c(
      "ENTRY-01", "ACTIVE-CONVERSION-01", "RUNTIME-01",
      "SITE-RECEIPT-01", "SCOPE-01", "CONFIRM-01"
    )) &&
    identical(policy$ReservedCalibrationReplicates, 201:300) &&
    identical(policy$ConfirmationReplicates, 501:700) &&
    isTRUE(policy$IssuedProductionRecordRequired) &&
    isTRUE(policy$ActiveManifestRequired) &&
    isTRUE(policy$RuntimeReceiptRequired) &&
    isTRUE(policy$FreshSiteReceiptRequired) &&
    isTRUE(policy$HeldExclusiveLockRequired) &&
    isTRUE(policy$ActivationMarkerRequired) &&
    isTRUE(policy$CompleteFailureDenominatorRequired) &&
    isTRUE(policy$ExactResumeRequired) &&
    !isTRUE(policy$EarlyStoppingPermitted) &&
    !isTRUE(policy$ConfirmationAccessPermitted) &&
    !isTRUE(policy$ProductionIssuanceFunctionDefined) &&
    !isTRUE(policy$ResponseGenerationPermittedDuringConstruction) &&
    !isTRUE(policy$ModelFittingPermittedDuringConstruction)
}

mfrmr_gtwar_capability_store <- new.env(parent = emptyenv())

mfrmr_gtwar_capability_activate <- function(contract, manifest, record) {
  if (exists("active", envir = mfrmr_gtwar_capability_store,
             inherits = FALSE)) {
    stop("A record-bound execution capability is already active.",
         call. = FALSE)
  }
  if (!mfrmr_gtwar_contract_hash_valid(contract) ||
      !mfrmr_gtwar_active_manifest_hash_valid(manifest, contract) ||
      !identical(record$AuthorizationRecordHash,
                 manifest$AuthorizationRecordHash)) {
    stop("Exact record-bound inputs are required to create a capability.",
         call. = FALSE)
  }
  if (identical(manifest$ExecutionMode,
                "authorized_reserved_single_shard")) {
    if (!mfrmr_gtwar_authorization_record_hash_valid(
      record, contract, manifest$SourceManifestObject
    )) stop("A valid issued production record is required.", call. = FALSE)
  } else if (!mfrmr_gtwar_reduction_record_hash_valid(
    record, contract, manifest$SourceManifestObject
  )) stop("A valid nonreserved reduction record is required.", call. = FALSE)
  identity <- list(
    Contract = "ephemeral_execution_capability_b1g23_v1",
    EntryContractHash = contract$ContractHash,
    ActiveManifestHash = manifest$ActiveManifestHash,
    AuthorizationRecordHash = record$AuthorizationRecordHash,
    ExecutionMode = manifest$ExecutionMode
  )
  capability <- structure(c(identity, list(
    CapabilityHash = mfrmr_gta_hash(identity)
  )), class = "mfrmr_gtwar_capability")
  assign("active", capability, envir = mfrmr_gtwar_capability_store)
  capability
}

mfrmr_gtwar_capability_hash_valid <- function(capability) {
  fields <- c(
    "Contract", "EntryContractHash", "ActiveManifestHash",
    "AuthorizationRecordHash", "ExecutionMode"
  )
  inherits(capability, "mfrmr_gtwar_capability") &&
    all(fields %in% names(capability)) &&
    identical(capability$CapabilityHash,
              mfrmr_gta_hash(capability[fields])) &&
    capability$ExecutionMode %in% c(
      "nonreserved_entry_reduction", "authorized_reserved_single_shard"
    )
}

mfrmr_gtwar_capability_release <- function(capability) {
  active <- get0("active", envir = mfrmr_gtwar_capability_store,
                 inherits = FALSE)
  if (is.null(active) || !mfrmr_gtwar_capability_hash_valid(active) ||
      !identical(active$CapabilityHash,
                                    capability$CapabilityHash)) {
    stop("The active execution capability changed.", call. = FALSE)
  }
  rm("active", envir = mfrmr_gtwar_capability_store)
  invisible(TRUE)
}

mfrmr_gtwar_capability_current <- function() {
  get0("active", envir = mfrmr_gtwar_capability_store, inherits = FALSE)
}

mfrmr_gtwar_generate <- function(
    registry = mfrmr_gtw_registry(), scenario_id,
    replicate = mfrmr_gtwal_policy()$NonreservedReplayReplicate,
    policy = mfrmr_gtwal_policy()) {
  capability <- mfrmr_gtwar_capability_current()
  if (!mfrmr_gtwar_capability_hash_valid(capability)) {
    stop("An active record-bound generator capability is required.",
         call. = FALSE)
  }
  replicate <- as.integer(replicate)
  production <- identical(
    capability$ExecutionMode, "authorized_reserved_single_shard"
  )
  if (replicate %in% 501:700 ||
      (production && !identical(replicate, 201L)) ||
      (!production && (!identical(
        capability$ExecutionMode, "nonreserved_entry_reduction"
      ) || !identical(replicate, 902L)))) {
    stop("The generator capability does not cover this replicate.",
         call. = FALSE)
  }
  core <- mfrmr_gtwar_generate_core()
  generation <- core(registry, scenario_id, replicate, policy)
  if (!mfrmr_gtwal_generation_hash_valid(generation)) {
    stop("The reused hardened generator core failed validation.",
         call. = FALSE)
  }
  if (!production) return(generation)
  parent_identity <- generation$GeneratorIdentity
  parent_hash <- generation$GeneratorHash
  identity <- list(
    Version = "record_bound_reserved_generator_b1g23_v1",
    EntryContractHash = capability$EntryContractHash,
    ActiveManifestHash = capability$ActiveManifestHash,
    AuthorizationRecordHash = capability$AuthorizationRecordHash,
    ParentHardenedGeneratorHash = parent_hash,
    ParentHardenedGeneratorIdentityHash = mfrmr_gta_hash(parent_identity),
    RegistryHash = generation$RegistryHash,
    ScenarioId = generation$ScenarioId,
    Replicate = generation$Replicate, Seed = generation$Seed,
    ScenarioRowHash = parent_identity$ScenarioRowHash,
    DesignHash = parent_identity$DesignHash,
    FullPotentialDataHash = parent_identity$FullPotentialDataHash,
    AssignedDataHash = parent_identity$AssignedDataHash,
    AnalysisDataHash = parent_identity$AnalysisDataHash,
    NominalTruthHash = parent_identity$NominalTruthHash,
    RequiredRNGKind = generation$RequiredRNGKind
  )
  generation$ContractVersion <- identity$Version
  generation$ParentHardenedGeneratorIdentity <- parent_identity
  generation$ParentHardenedGeneratorHash <- parent_hash
  generation$GeneratorIdentity <- identity
  generation$GeneratorHash <- mfrmr_gta_hash(identity)
  generation$ReservedAccessEnabled <- TRUE
  generation$AuthorizationRecordHash <- capability$AuthorizationRecordHash
  generation$ActiveManifestHash <- capability$ActiveManifestHash
  class(generation) <- c(
    "mfrmr_gtwar_generation",
    setdiff(class(generation), "mfrmr_gtwar_generation")
  )
  generation
}

mfrmr_gtwar_generation_hash_valid <- function(generation) {
  if (!inherits(generation, "mfrmr_gtwar_generation")) {
    return(mfrmr_gtwal_generation_hash_valid(generation))
  }
  identity <- generation$GeneratorIdentity
  fields <- c(
    "Version", "EntryContractHash", "ActiveManifestHash",
    "AuthorizationRecordHash", "ParentHardenedGeneratorHash",
    "ParentHardenedGeneratorIdentityHash", "RegistryHash", "ScenarioId",
    "Replicate", "Seed", "ScenarioRowHash", "DesignHash",
    "FullPotentialDataHash", "AssignedDataHash", "AnalysisDataHash",
    "NominalTruthHash", "RequiredRNGKind"
  )
  parent <- generation
  parent$ContractVersion <-
    generation$ParentHardenedGeneratorIdentity$Version
  parent$GeneratorIdentity <- generation$ParentHardenedGeneratorIdentity
  parent$GeneratorHash <- generation$ParentHardenedGeneratorHash
  parent$ReservedAccessEnabled <- FALSE
  parent$AuthorizationRecordHash <- NULL
  parent$ActiveManifestHash <- NULL
  parent$ParentHardenedGeneratorIdentity <- NULL
  parent$ParentHardenedGeneratorHash <- NULL
  class(parent) <- setdiff(class(parent), "mfrmr_gtwar_generation")
  is.list(identity) && all(fields %in% names(identity)) &&
    identical(generation$ContractVersion, identity$Version) &&
    identical(generation$GeneratorHash, mfrmr_gta_hash(identity)) &&
    identical(generation$AuthorizationRecordHash,
              identity$AuthorizationRecordHash) &&
    identical(generation$ActiveManifestHash, identity$ActiveManifestHash) &&
    identical(identity$ParentHardenedGeneratorHash,
              generation$ParentHardenedGeneratorHash) &&
    identical(identity$ParentHardenedGeneratorIdentityHash,
              mfrmr_gta_hash(generation$ParentHardenedGeneratorIdentity)) &&
    identical(identity$RegistryHash, generation$RegistryHash) &&
    identical(identity$ScenarioId, generation$ScenarioId) &&
    identical(identity$Replicate, generation$Replicate) &&
    identical(identity$Seed, generation$Seed) &&
    identical(mfrmr_gtd2_hash_data(generation$FullPotentialData),
              identity$FullPotentialDataHash) &&
    identical(mfrmr_gtd2_hash_data(generation$AssignedData),
              identity$AssignedDataHash) &&
    identical(mfrmr_gtd2_hash_data(generation$AnalysisData),
              identity$AnalysisDataHash) &&
    identical(mfrmr_gta_hash(generation$NominalTruth),
              identity$NominalTruthHash) &&
    isTRUE(generation$ReservedAccessEnabled) &&
    mfrmr_gtwal_generation_hash_valid(parent)
}

mfrmr_gtwar_bind_prepare <- function(fun) {
  bridge <- new.env(parent = environment(fun))
  assign("mfrmr_gtwam_prepare_unit", mfrmr_gtwar_prepare_unit, envir = bridge)
  environment(fun) <- bridge
  fun
}

mfrmr_gtwar_prepare_unit <- function(
    contract, unit, registry = mfrmr_gtw_registry()) {
  capability <- mfrmr_gtwar_capability_current()
  if (!inherits(contract, "mfrmr_gtwar_contract") ||
      !is.data.frame(unit) || nrow(unit) != 1L ||
      !all(c(
        "AtomicUnitId", "DatasetId", "ScenarioId", "Replicate",
        "MethodId", "Backend", "Likelihood", "AuthorizationRecordHash"
      ) %in% names(unit)) || !inherits(capability, "mfrmr_gtwar_capability") ||
      !mfrmr_gtwar_capability_hash_valid(capability) ||
      !identical(capability$EntryContractHash, contract$ContractHash) ||
      !identical(unit$AuthorizationRecordHash[[1L]],
                 capability$AuthorizationRecordHash)) {
    stop("An active record-bound b1g23 execution capability is required.",
         call. = FALSE)
  }
  replicate <- as.integer(unit$Replicate[[1L]])
  policy <- contract$RecordBoundEntryPolicy
  if (replicate %in% policy$ConfirmationReplicates) {
    stop("Confirmation replicates remain inaccessible.", call. = FALSE)
  }
  if (identical(capability$ExecutionMode,
                "authorized_reserved_single_shard")) {
    if (!identical(replicate, policy$CandidateReplicate) ||
        !isTRUE(unit$ReservedCalibrationUse[[1L]]) ||
        !isTRUE(unit$ExecutionAuthorized[[1L]])) {
      stop("The production capability is restricted to exact shard R0201.",
           call. = FALSE)
    }
  } else if (!identical(capability$ExecutionMode,
                        "nonreserved_entry_reduction") ||
             !identical(replicate, policy$ReductionReplicate) ||
             isTRUE(unit$ReservedCalibrationUse[[1L]])) {
    stop("The reduction capability is nonreserved-only.", call. = FALSE)
  }
  core <- mfrmr_gtwar_prepare_core()
  core(contract, unit, registry)
}

mfrmr_gtwar_candidate_evaluator <- function(contract, unit) {
  evaluator <- mfrmr_gtwar_bind_prepare(mfrmr_gtwam_candidate_evaluator)
  evaluator(contract, unit)
}

mfrmr_gtwar_reference_evaluator <- function(contract, unit) {
  evaluator <- mfrmr_gtwar_bind_prepare(mfrmr_gtwam_reference_evaluator)
  evaluator(contract, unit)
}

mfrmr_gtwar_adapter_hashes <- function() {
  c(
    CandidateEvaluator =
      mfrmr_gtwag_function_hash(mfrmr_gtwar_candidate_evaluator),
    ReferenceEvaluator =
      mfrmr_gtwag_function_hash(mfrmr_gtwar_reference_evaluator)
  )
}

mfrmr_gtwar_dependency_hashes <- function() {
  functions <- list(
    drop_one_admission = mfrmr_gtwar_drop_one_admission,
    prepare_core = mfrmr_gtwar_prepare_core,
    generator_core = mfrmr_gtwar_generate_core,
    execute_core = mfrmr_gtwar_execute_core,
    capability_activate = mfrmr_gtwar_capability_activate,
    capability_validator = mfrmr_gtwar_capability_hash_valid,
    capability_release = mfrmr_gtwar_capability_release,
    generate = mfrmr_gtwar_generate,
    generation_validator = mfrmr_gtwar_generation_hash_valid,
    prepare_unit = mfrmr_gtwar_prepare_unit,
    bind_prepare = mfrmr_gtwar_bind_prepare,
    candidate_evaluator = mfrmr_gtwar_candidate_evaluator,
    reference_evaluator = mfrmr_gtwar_reference_evaluator,
    parent_fixture_validator = mfrmr_gtwar_parent_fixture_hash_valid,
    issuance_decision_validator =
      mfrmr_gtwar_issuance_decision_hash_valid,
    parent_prepare = mfrmr_gtwam_prepare_unit,
    parent_execute = mfrmr_gtwag_execute
  )
  vapply(functions, mfrmr_gtwar_function_hash, character(1L))
}

mfrmr_gtwar_contract <- function(guarded_contract, prospective_manifest,
                                   authorization_decision,
                                   authorization_source_audit, worker_path) {
  mfrmr_gtwar_require_primitives()
  policy <- mfrmr_gtwar_policy(worker_path)
  if (!mfrmr_gtwap_contract_hash_valid(guarded_contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !mfrmr_gtwaq_decision_hash_valid(authorization_decision) ||
      !mfrmr_gtwaq_source_audit_hash_valid(authorization_source_audit) ||
      !identical(authorization_decision$SourceAuditHash,
                 authorization_source_audit$AuditHash) ||
      !identical(authorization_decision$Decision,
                 "no_go_refused_not_issued") ||
      !identical(authorization_decision$NextImplementationRequired,
                 "record_bound_reserved_entry_point_and_active_one_shard_manifest") ||
      !identical(prospective_manifest$ShardId, policy$CandidateShardId) ||
      !identical(prospective_manifest$Replicate,
                 policy$CandidateReplicate) ||
      !identical(prospective_manifest$ManifestHash,
                 policy$CandidateProspectiveManifestHash) ||
      !identical(c(
        Datasets = prospective_manifest$DatasetCount,
        AtomicUnits = prospective_manifest$AtomicUnitCount,
        CandidateFits = prospective_manifest$CandidateFitRowCount,
        CandidateDecisions = prospective_manifest$CandidateDecisionRowCount,
        References = prospective_manifest$ReferenceRowCount
      ), policy$CandidateShardCounts) ||
      !identical(policy$ParentGuardedRunnerSourceHash,
                 authorization_source_audit$GuardedRunnerSourceHash) ||
      !identical(policy$ParentExactRunnerSourceHash,
                 authorization_source_audit$ExactResumeRunnerSourceHash)) {
    stop("Exact b1g19, b1g21, and b1g22 evidence is required.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "record_bound_entry_contract_b1g23_v1",
    GuardedRunnerContractHash = guarded_contract$ContractHash,
    HardenedLineageContractHash =
      prospective_manifest$HardenedLineageContractHash,
    ProspectiveManifestHash = prospective_manifest$ManifestHash,
    AuthorizationDecisionHash = authorization_decision$DecisionHash,
    AuthorizationDecisionSourceAuditHash =
      authorization_decision$SourceAuditHash,
    AuthorizationKernelContractHash =
      guarded_contract$AuthorizationKernelContractHash,
    IsolatedRuntimeHash =
      guarded_contract$GuardedRunnerPolicy$IsolatedRuntimeHash,
    RecordBoundEntryPolicy = policy,
    ParentAdapterHashes = guarded_contract$AdapterHashes,
    AdapterHashes = mfrmr_gtwar_adapter_hashes(),
    AdapterDependencyHashes = mfrmr_gtwar_dependency_hashes()
  )
  base <- unclass(guarded_contract)
  for (name in unique(c(
    names(identity), "Contract", "ContractHash", "AdapterHashes",
    "AdapterDependencyHashes", "ReservedAdapterEntryPointReady",
    "ActiveManifestConversionReady", "AuthorizedSingleShardRunnerReady",
    "AuthorizationRecordIssued", "AuthorizationRNG01Closed",
    "AuthorizationActivationEligible", "LargeSimulationMayStart",
    "Replicate201MayBeOpened", "CalibrationExecutionAuthorized",
    "CalibrationDataGenerated", "CalibrationResultsViewed",
    "ConfirmationAuthorized", "InferenceReady", "DecisionReady"
  ))) base[[name]] <- NULL
  structure(c(base, identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    RecordBoundEntryContractFrozen = TRUE,
    ReservedEntryPointImplementationReady = TRUE,
    ActiveManifestConversionImplementationReady = TRUE,
    NonreservedEntryReductionAuthorized = TRUE,
    ProductionIssuanceFunctionDefined = FALSE,
    ReservedAdapterEntryPointReady = TRUE,
    ActiveManifestConversionReady = TRUE,
    AuthorizedSingleShardRunnerReady = FALSE,
    AuthorizationRecordIssued = FALSE,
    ActiveReservedManifestIssued = FALSE,
    FreshSiteReceiptBound = FALSE,
    AuthorizationRNG01Closed = FALSE,
    AuthorizationActivationEligible = FALSE,
    LargeSimulationMayStart = FALSE,
    Replicate201MayBeOpened = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  )), class = c(
    "mfrmr_gtwar_contract", "mfrmr_gtwap_contract",
    "mfrmr_gtwam_contract", "mfrmr_gtwah_contract",
    "mfrmr_gtwag_contract"
  ))
}

mfrmr_gtwar_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "GuardedRunnerContractHash",
    "HardenedLineageContractHash", "ProspectiveManifestHash",
    "AuthorizationDecisionHash", "AuthorizationDecisionSourceAuditHash",
    "AuthorizationKernelContractHash", "IsolatedRuntimeHash",
    "RecordBoundEntryPolicy", "ParentAdapterHashes", "AdapterHashes",
    "AdapterDependencyHashes"
  )
  inherits(contract, "mfrmr_gtwar_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwar_policy_hash_valid(contract$RecordBoundEntryPolicy) &&
    identical(contract$AdapterHashes, mfrmr_gtwar_adapter_hashes()) &&
    identical(contract$AdapterDependencyHashes,
              mfrmr_gtwar_dependency_hashes()) &&
    identical(contract$ProspectiveManifestHash,
              contract$RecordBoundEntryPolicy$CandidateProspectiveManifestHash) &&
    isTRUE(contract$RecordBoundEntryContractFrozen) &&
    isTRUE(contract$ReservedEntryPointImplementationReady) &&
    isTRUE(contract$ActiveManifestConversionImplementationReady) &&
    isTRUE(contract$NonreservedEntryReductionAuthorized) &&
    isTRUE(contract$ReservedAdapterEntryPointReady) &&
    isTRUE(contract$ActiveManifestConversionReady) &&
    !isTRUE(contract$ProductionIssuanceFunctionDefined) &&
    !isTRUE(contract$AuthorizedSingleShardRunnerReady) &&
    !isTRUE(contract$AuthorizationRecordIssued) &&
    !isTRUE(contract$ActiveReservedManifestIssued) &&
    !isTRUE(contract$FreshSiteReceiptBound) &&
    !isTRUE(contract$AuthorizationRNG01Closed) &&
    !isTRUE(contract$AuthorizationActivationEligible) &&
    !isTRUE(contract$LargeSimulationMayStart) &&
    !isTRUE(contract$Replicate201MayBeOpened) &&
    !isTRUE(contract$CalibrationExecutionAuthorized) &&
    !isTRUE(contract$ConfirmationAuthorized) &&
    !isTRUE(contract$InferenceReady) && !isTRUE(contract$DecisionReady)
}

mfrmr_gtwar_parent_fixture_hash_valid <- function(fixture_manifest, contract) {
  mfrmr_gtwar_contract_hash_valid(contract) &&
    mfrmr_gtwag_manifest_hash_valid(fixture_manifest) &&
    identical(fixture_manifest$ManifestHash,
              "0a515e0977774887094321284a723e058d9b1723f3d45f505245429dc93d6db3") &&
    identical(fixture_manifest$RunnerContractHash,
              contract$GuardedRunnerContractHash) &&
    identical(fixture_manifest$ExecutionMode,
              "isolated_nonreserved_scientific_reduction") &&
    identical(fixture_manifest$Replicates, 902L) &&
    identical(fixture_manifest$AtomicUnitCount, 4L) &&
    identical(fixture_manifest$DatasetCount, 1L) &&
    identical(fixture_manifest$CandidateFitRowCount, 36L) &&
    identical(fixture_manifest$CandidateDecisionRowCount, 192L) &&
    identical(fixture_manifest$ReferenceRowCount, 8L) &&
    isTRUE(fixture_manifest$ExecutionAuthorized) &&
    !isTRUE(fixture_manifest$ReservedCalibrationUse) &&
    !isTRUE(fixture_manifest$ConfirmationUse) &&
    !isTRUE(fixture_manifest$CalibrationExecutionAuthorized)
}

mfrmr_gtwar_reduction_record <- function(contract, fixture_manifest) {
  if (!mfrmr_gtwar_contract_hash_valid(contract) ||
      !mfrmr_gtwar_parent_fixture_hash_valid(fixture_manifest, contract)) {
    stop("The exact b1g23 contract and b1g21 fixture are required.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "nonreserved_entry_reduction_record_b1g23_v1",
    EntryContractHash = contract$ContractHash,
    ParentFixtureManifestHash = fixture_manifest$ManifestHash,
    ShardId = "TEST-R0902", Replicate = 902L,
    ExecutionMode = "nonreserved_entry_reduction",
    ProductionIssuance = FALSE, ReservedCalibrationUse = FALSE,
    ConfirmationUse = FALSE
  )
  structure(c(identity, list(
    AuthorizationRecordHash = mfrmr_gta_hash(identity),
    ReductionRecordFrozen = TRUE,
    AuthorizationRecordIssued = FALSE,
    CalibrationExecutionAuthorized = FALSE
  )), class = "mfrmr_gtwar_reduction_record")
}

mfrmr_gtwar_reduction_record_hash_valid <- function(record, contract,
                                                      fixture_manifest) {
  fields <- c(
    "Contract", "EntryContractHash", "ParentFixtureManifestHash",
    "ShardId", "Replicate", "ExecutionMode", "ProductionIssuance",
    "ReservedCalibrationUse", "ConfirmationUse"
  )
  inherits(record, "mfrmr_gtwar_reduction_record") &&
    all(fields %in% names(record)) &&
    identical(record$AuthorizationRecordHash,
              mfrmr_gta_hash(record[fields])) &&
    identical(record$EntryContractHash, contract$ContractHash) &&
    identical(record$ParentFixtureManifestHash,
              fixture_manifest$ManifestHash) &&
    identical(record$Replicate, 902L) &&
    identical(record$ExecutionMode, "nonreserved_entry_reduction") &&
    isTRUE(record$ReductionRecordFrozen) &&
    !isTRUE(record$ProductionIssuance) &&
    !isTRUE(record$ReservedCalibrationUse) &&
    !isTRUE(record$ConfirmationUse) &&
    !isTRUE(record$AuthorizationRecordIssued) &&
    !isTRUE(record$CalibrationExecutionAuthorized)
}

mfrmr_gtwar_issuance_decision_hash_valid <- function(
    decision, contract, prospective_manifest, runtime_receipt, site_receipt,
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
      !is.data.frame(decision$GateRegistry) ||
      !mfrmr_gtwar_contract_hash_valid(contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !mfrmr_gtwao_runtime_probe_hash_valid(runtime_receipt) ||
      !mfrmr_gtwao_site_probe_hash_valid(site_receipt)) return(FALSE)
  gates <- decision$GateRegistry
  required_ids <- contract$RecordBoundEntryPolicy$RequiredIssuanceGateIds
  exact_gates <- identical(gates$GateId, required_ids) &&
    all(c("ObservedPass", "RequiredForIssuance") %in% names(gates)) &&
    all(gates$RequiredForIssuance) && all(gates$ObservedPass)
  inherits(decision, "mfrmr_gtwar_issuance_decision") &&
    identical(decision$DecisionHash, mfrmr_gta_hash(decision[fields])) &&
    identical(decision$Contract,
              contract$RecordBoundEntryPolicy$RequiredIssuanceDecisionContract) &&
    identical(decision$EntryContractHash, contract$ContractHash) &&
    identical(decision$PolicyHash,
              contract$RecordBoundEntryPolicy$PolicyHash) &&
    identical(decision$ProspectiveManifestHash,
              prospective_manifest$ManifestHash) &&
    identical(decision$RuntimeReceiptHash, runtime_receipt$ProbeHash) &&
    identical(runtime_receipt$Runtime$RuntimeHash,
              contract$IsolatedRuntimeHash) &&
    identical(decision$SiteReceiptHash, site_receipt$ProbeHash) &&
    identical(site_receipt$AuthorizationKernelContractHash,
              contract$AuthorizationKernelContractHash) &&
    identical(decision$OutputTargetHash, mfrmr_gta_hash(output_target)) &&
    identical(site_receipt$OutputTargetHash, decision$OutputTargetHash) &&
    isTRUE(site_receipt$SitePreflightReady) && exact_gates &&
    isTRUE(decision$IssuanceReady) &&
    identical(decision$Decision, "go_one_shard_record_may_be_issued") &&
    identical(decision$MaximumShardCount, 1L) &&
    !isTRUE(decision$EarlyStoppingPermitted) &&
    !isTRUE(decision$ConfirmationUse) &&
    !isTRUE(decision$CalibrationResponsesUsed) &&
    !isTRUE(decision$ConfirmationResponsesUsed)
}

mfrmr_gtwar_authorization_record_hash_valid <- function(record, contract,
                                                         prospective_manifest) {
  fields <- c(
    "Contract", "EntryContractHash", "PolicyHash", "ShardId", "Replicate",
    "ProspectiveManifestHash", "RuntimeReceiptHash", "SiteReceiptHash",
    "OutputTarget", "AuthorizationScope", "MaximumShardCount",
    "CompleteFailureDenominatorRequired", "EarlyStoppingPermitted",
    "ConfirmationUse", "ProductionIssuance", "ExecutionAuthorized",
    "CalibrationExecutionAuthorized", "AuthorizationRecordIssued",
    "IssuanceDecisionHash"
  )
  if (!inherits(record, "mfrmr_gtwar_authorization_record") ||
      !all(fields %in% names(record)) ||
      !mfrmr_gtwar_contract_hash_valid(contract) ||
      !mfrmr_gtwan_shard_manifest_hash_valid(prospective_manifest) ||
      !inherits(record$IssuanceDecision,
                "mfrmr_gtwar_issuance_decision") ||
      !inherits(record$RuntimeReceipt, "mfrmr_gtwao_runtime_probe") ||
      !inherits(record$SiteReceipt, "mfrmr_gtwao_site_probe") ||
      !mfrmr_gtwao_runtime_probe_hash_valid(record$RuntimeReceipt) ||
      !mfrmr_gtwao_site_probe_hash_valid(record$SiteReceipt) ||
      !mfrmr_gtwar_issuance_decision_hash_valid(
        record$IssuanceDecision, contract, prospective_manifest,
        record$RuntimeReceipt, record$SiteReceipt, record$OutputTarget
      )) return(FALSE)
  identical(record$AuthorizationRecordHash,
            mfrmr_gta_hash(record[fields])) &&
    identical(record$EntryContractHash, contract$ContractHash) &&
    identical(record$PolicyHash,
              contract$RecordBoundEntryPolicy$PolicyHash) &&
    identical(record$ShardId, "R0201") &&
    identical(record$Replicate, 201L) &&
    identical(record$ProspectiveManifestHash,
              prospective_manifest$ManifestHash) &&
    identical(record$RuntimeReceiptHash, record$RuntimeReceipt$ProbeHash) &&
    identical(record$RuntimeReceipt$Runtime$RuntimeHash,
              contract$IsolatedRuntimeHash) &&
    identical(record$SiteReceiptHash, record$SiteReceipt$ProbeHash) &&
    identical(record$SiteReceipt$AuthorizationKernelContractHash,
              contract$AuthorizationKernelContractHash) &&
    identical(record$SiteReceipt$OutputTargetHash,
              mfrmr_gta_hash(record$OutputTarget)) &&
    isTRUE(record$SiteReceipt$SitePreflightReady) &&
    identical(record$AuthorizationScope, "one_exact_reserved_shard") &&
    identical(record$MaximumShardCount, 1L) &&
    isTRUE(record$CompleteFailureDenominatorRequired) &&
    !isTRUE(record$EarlyStoppingPermitted) &&
    !isTRUE(record$ConfirmationUse) &&
    isTRUE(record$ProductionIssuance) &&
    isTRUE(record$ExecutionAuthorized) &&
    isTRUE(record$CalibrationExecutionAuthorized) &&
    isTRUE(record$AuthorizationRecordIssued) &&
    identical(record$IssuanceDecisionHash,
              record$IssuanceDecision$DecisionHash)
}

mfrmr_gtwar_active_manifest <- function(contract, source_manifest, record) {
  if (!mfrmr_gtwar_contract_hash_valid(contract)) {
    stop("The exact b1g23 contract is required.", call. = FALSE)
  }
  reduction <- inherits(record, "mfrmr_gtwar_reduction_record")
  if (reduction) {
    if (inherits(source_manifest, "mfrmr_gtwan_shard_manifest")) {
      stop("A nonreserved reduction record cannot activate a reserved manifest.",
           call. = FALSE)
    }
    if (!mfrmr_gtwar_parent_fixture_hash_valid(source_manifest, contract) ||
        !mfrmr_gtwar_reduction_record_hash_valid(
          record, contract, source_manifest
        )) {
      stop("The exact nonreserved reduction record is required.",
           call. = FALSE)
    }
    mode <- "nonreserved_entry_reduction"
    reserved <- FALSE
    calibration_authorized <- FALSE
    source_hash <- source_manifest$ManifestHash
    shard_id <- record$ShardId
  } else {
    if (!mfrmr_gtwar_authorization_record_hash_valid(
      record, contract, source_manifest
    )) {
      stop("A separately issued exact R0201 authorization record is required.",
           call. = FALSE)
    }
    mode <- "authorized_reserved_single_shard"
    reserved <- TRUE
    calibration_authorized <- TRUE
    source_hash <- source_manifest$ManifestHash
    shard_id <- source_manifest$ShardId
  }
  units <- source_manifest$Units
  units$PriorAtomicUnitIdentityHash <- units$AtomicUnitIdentityHash
  units$AuthorizationRecordHash <- record$AuthorizationRecordHash
  units$ReservedCalibrationUse <- reserved
  units$ExecutionAuthorized <- TRUE
  units$ResponseGenerated <- FALSE
  units$PreFitComputed <- FALSE
  units$CheckpointCreated <- FALSE
  units$AtomicUnitIdentityHash <- vapply(seq_len(nrow(units)), function(index) {
    mfrmr_gta_hash(units[index, setdiff(
      names(units), "AtomicUnitIdentityHash"
    ), drop = FALSE])
  }, character(1L))
  base_identity <- list(
    Contract = "record_bound_active_manifest_b1g23_v1",
    RunnerContractHash = contract$ContractHash,
    ExecutionMode = mode, Units = units,
    CandidateEvaluatorHash = contract$AdapterHashes[["CandidateEvaluator"]],
    ReferenceEvaluatorHash = contract$AdapterHashes[["ReferenceEvaluator"]],
    Replicates = as.integer(unique(units$Replicate)),
    ReservedCalibrationUse = reserved, ConfirmationUse = FALSE
  )
  manifest_hash <- mfrmr_gta_hash(base_identity)
  extended_identity <- c(base_identity, list(
    ManifestHash = manifest_hash,
    SourceManifestHash = source_hash,
    SourceManifestObject = source_manifest,
    AuthorizationRecordHash = record$AuthorizationRecordHash,
    AuthorizationRecordObject = record,
    ShardId = shard_id
  ))
  structure(c(extended_identity, list(
    ActiveManifestHash = mfrmr_gta_hash(extended_identity),
    AtomicUnitCount = nrow(units),
    DatasetCount = length(unique(units$DatasetId)),
    CandidateFitRowCount = sum(units$ExpectedCandidateFitRows),
    CandidateDecisionRowCount = sum(units$ExpectedCandidateDecisionRows),
    ReferenceRowCount = sum(units$ExpectedReferenceRows),
    ExecutionAuthorized = TRUE,
    CalibrationExecutionAuthorized = calibration_authorized,
    ResponseGenerationPermitted = calibration_authorized,
    ModelFittingPermitted = TRUE,
    EarlyStoppingPermitted = FALSE,
    ConfirmationAccessPermitted = FALSE,
    DataGenerated = FALSE, ResultsViewed = FALSE
  )), class = c("mfrmr_gtwar_active_manifest", "mfrmr_gtwag_manifest"))
}

mfrmr_gtwar_active_manifest_hash_valid <- function(manifest, contract) {
  extended_fields <- c(
    "Contract", "RunnerContractHash", "ExecutionMode", "Units",
    "CandidateEvaluatorHash", "ReferenceEvaluatorHash", "Replicates",
    "ReservedCalibrationUse", "ConfirmationUse", "ManifestHash",
    "SourceManifestHash", "SourceManifestObject", "AuthorizationRecordHash",
    "AuthorizationRecordObject", "ShardId"
  )
  if (!inherits(manifest, "mfrmr_gtwar_active_manifest") ||
      !all(extended_fields %in% names(manifest)) ||
      !mfrmr_gtwar_contract_hash_valid(contract) ||
      !mfrmr_gtwag_manifest_hash_valid(manifest) ||
      !identical(manifest$RunnerContractHash, contract$ContractHash) ||
      !identical(manifest$ActiveManifestHash,
                 mfrmr_gta_hash(manifest[extended_fields])) ||
      !identical(manifest$AuthorizationRecordHash,
                 manifest$AuthorizationRecordObject$AuthorizationRecordHash) ||
      !identical(manifest$AtomicUnitCount, nrow(manifest$Units)) ||
      anyDuplicated(manifest$Units$AtomicUnitId) ||
      anyDuplicated(manifest$Units$AtomicUnitIdentityHash) ||
      !all(manifest$Units$AuthorizationRecordHash ==
             manifest$AuthorizationRecordHash) ||
      !all(manifest$Units$ExecutionAuthorized) ||
      any(manifest$Units$ResponseGenerated) ||
      any(manifest$Units$PreFitComputed) ||
      any(manifest$Units$CheckpointCreated) ||
      !isTRUE(manifest$ExecutionAuthorized) ||
      !isTRUE(manifest$ModelFittingPermitted) ||
      isTRUE(manifest$EarlyStoppingPermitted) ||
      isTRUE(manifest$ConfirmationUse) ||
      isTRUE(manifest$ConfirmationAccessPermitted) ||
      isTRUE(manifest$DataGenerated) || isTRUE(manifest$ResultsViewed)) {
    return(FALSE)
  }
  computed <- vapply(seq_len(nrow(manifest$Units)), function(index) {
    mfrmr_gta_hash(manifest$Units[index, setdiff(
      names(manifest$Units), "AtomicUnitIdentityHash"
    ), drop = FALSE])
  }, character(1L))
  if (!identical(unname(computed),
                 unname(manifest$Units$AtomicUnitIdentityHash))) return(FALSE)
  if (identical(manifest$ExecutionMode, "nonreserved_entry_reduction")) {
    mfrmr_gtwar_parent_fixture_hash_valid(
      manifest$SourceManifestObject, contract
    ) && mfrmr_gtwar_reduction_record_hash_valid(
      manifest$AuthorizationRecordObject, contract,
      manifest$SourceManifestObject
    ) && identical(manifest$Replicates, 902L) &&
      identical(manifest$AtomicUnitCount, 4L) &&
      identical(manifest$DatasetCount, 1L) &&
      identical(manifest$CandidateFitRowCount, 36L) &&
      identical(manifest$CandidateDecisionRowCount, 192L) &&
      identical(manifest$ReferenceRowCount, 8L) &&
      !isTRUE(manifest$ReservedCalibrationUse) &&
      !isTRUE(manifest$CalibrationExecutionAuthorized) &&
      !isTRUE(manifest$ResponseGenerationPermitted)
  } else if (identical(manifest$ExecutionMode,
                       "authorized_reserved_single_shard")) {
    mfrmr_gtwan_shard_manifest_hash_valid(
      manifest$SourceManifestObject
    ) && mfrmr_gtwar_authorization_record_hash_valid(
      manifest$AuthorizationRecordObject, contract,
      manifest$SourceManifestObject
    ) && identical(manifest$ShardId, "R0201") &&
      identical(manifest$Replicates, 201L) &&
      identical(c(
        Datasets = manifest$DatasetCount,
        AtomicUnits = manifest$AtomicUnitCount,
        CandidateFits = manifest$CandidateFitRowCount,
        CandidateDecisions = manifest$CandidateDecisionRowCount,
        References = manifest$ReferenceRowCount
      ), contract$RecordBoundEntryPolicy$CandidateShardCounts) &&
      isTRUE(manifest$ReservedCalibrationUse) &&
      isTRUE(manifest$CalibrationExecutionAuthorized) &&
      isTRUE(manifest$ResponseGenerationPermitted)
  } else FALSE
}

mfrmr_gtwar_admit <- function(contract, manifest, record,
                               candidate_evaluator, reference_evaluator) {
  if (!mfrmr_gtwar_contract_hash_valid(contract) ||
      !mfrmr_gtwar_active_manifest_hash_valid(manifest, contract) ||
      !identical(record$AuthorizationRecordHash,
                 manifest$AuthorizationRecordHash) ||
      !identical(mfrmr_gtwag_function_hash(candidate_evaluator),
                 manifest$CandidateEvaluatorHash) ||
      !identical(mfrmr_gtwag_function_hash(reference_evaluator),
                 manifest$ReferenceEvaluatorHash)) {
    stop("Exact record-bound contract, manifest, record, and evaluators are required.",
         call. = FALSE)
  }
  if (identical(manifest$ExecutionMode,
                "authorized_reserved_single_shard")) {
    if (!mfrmr_gtwar_authorization_record_hash_valid(
      record, contract, manifest$SourceManifestObject
    )) stop("The production authorization record is invalid.", call. = FALSE)
  } else if (!mfrmr_gtwar_reduction_record_hash_valid(
    record, contract, manifest$SourceManifestObject
  )) stop("The reduction record is invalid.", call. = FALSE)
  invisible(TRUE)
}

mfrmr_gtwar_execute <- function(
    contract, manifest, record, checkpoint_root,
    candidate_evaluator = mfrmr_gtwar_candidate_evaluator,
    reference_evaluator = mfrmr_gtwar_reference_evaluator,
    interrupt_after_new_units = Inf) {
  mfrmr_gtwar_admit(
    contract, manifest, record, candidate_evaluator, reference_evaluator
  )
  if (identical(manifest$ExecutionMode,
                "authorized_reserved_single_shard") &&
      !identical(interrupt_after_new_units, Inf)) {
    stop("Production early stopping is prohibited.", call. = FALSE)
  }
  capability <- mfrmr_gtwar_capability_activate(contract, manifest, record)
  active <- TRUE
  on.exit(if (active) mfrmr_gtwar_capability_release(capability), add = TRUE)
  core <- mfrmr_gtwar_execute_core()
  legacy <- core(
    contract, manifest, checkpoint_root,
    candidate_evaluator = candidate_evaluator,
    reference_evaluator = reference_evaluator,
    interrupt_after_new_units = interrupt_after_new_units
  )
  mfrmr_gtwar_capability_release(capability)
  active <- FALSE
  if (!isTRUE(legacy$Complete)) return(legacy)
  identity <- list(
    Contract = "record_bound_shard_execution_b1g23_v1",
    EntryContractHash = contract$ContractHash,
    ActiveManifestHash = manifest$ActiveManifestHash,
    RunManifestHash = manifest$ManifestHash,
    AuthorizationRecordHash = record$AuthorizationRecordHash,
    ExecutionMode = manifest$ExecutionMode,
    CandidateFits = legacy$CandidateFits,
    CandidateDecisions = legacy$CandidateDecisions,
    References = legacy$References,
    AcceptanceLedger = legacy$AcceptanceLedger,
    AcceptanceCellSummary = legacy$AcceptanceCellSummary,
    UnitCheckpointHashes = legacy$UnitCheckpointHashes,
    DatasetMarkerHashes = legacy$DatasetMarkerHashes
  )
  production <- identical(
    manifest$ExecutionMode, "authorized_reserved_single_shard"
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity),
    LegacyExecutionHash = legacy$ExecutionHash,
    ExactAccountingPassed = TRUE,
    ValidCheckpointCount = legacy$ValidCheckpointCount,
    ReusedUnitCount = legacy$ReusedUnitCount,
    ComputedUnitCount = legacy$ComputedUnitCount,
    CandidateFitFailureCount = legacy$CandidateFitFailureCount,
    ReferenceUnresolvedCount = legacy$ReferenceUnresolvedCount,
    Complete = TRUE,
    CompletionClaim = if (production) {
      "complete_authorized_single_reserved_shard"
    } else "complete_nonreserved_entry_reduction",
    RecordBoundEntryPointUsed = TRUE,
    CalibrationExecutionAuthorized = production,
    CalibrationDataGenerated = production,
    CalibrationResultsViewed = FALSE,
    CalibrationEvidenceReady = FALSE,
    StationarityThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwar_execution")
}

mfrmr_gtwar_execution_hash_valid <- function(execution, contract,
                                               manifest, record) {
  fields <- c(
    "Contract", "EntryContractHash", "ActiveManifestHash",
    "RunManifestHash", "AuthorizationRecordHash", "ExecutionMode",
    "CandidateFits", "CandidateDecisions", "References",
    "AcceptanceLedger", "AcceptanceCellSummary", "UnitCheckpointHashes",
    "DatasetMarkerHashes"
  )
  production <- identical(manifest$ExecutionMode,
                          "authorized_reserved_single_shard")
  inherits(execution, "mfrmr_gtwar_execution") &&
    all(fields %in% names(execution)) &&
    identical(execution$ExecutionHash, mfrmr_gta_hash(execution[fields])) &&
    identical(execution$EntryContractHash, contract$ContractHash) &&
    identical(execution$ActiveManifestHash, manifest$ActiveManifestHash) &&
    identical(execution$RunManifestHash, manifest$ManifestHash) &&
    identical(execution$AuthorizationRecordHash,
              record$AuthorizationRecordHash) &&
    identical(execution$ExecutionMode, manifest$ExecutionMode) &&
    identical(nrow(execution$CandidateFits),
              manifest$CandidateFitRowCount) &&
    identical(nrow(execution$CandidateDecisions),
              manifest$CandidateDecisionRowCount) &&
    identical(nrow(execution$References), manifest$ReferenceRowCount) &&
    isTRUE(execution$ExactAccountingPassed) && isTRUE(execution$Complete) &&
    isTRUE(execution$RecordBoundEntryPointUsed) &&
    identical(execution$CalibrationExecutionAuthorized, production) &&
    identical(execution$CalibrationDataGenerated, production) &&
    !isTRUE(execution$CalibrationResultsViewed) &&
    !isTRUE(execution$CalibrationEvidenceReady) &&
    !isTRUE(execution$ConfirmationAuthorized) &&
    !isTRUE(execution$InferenceReady) && !isTRUE(execution$DecisionReady)
}

mfrmr_gtwar_job <- function(contract, manifest, record, lock_receipt,
                             activation_receipt) {
  mfrmr_gtwar_admit(
    contract, manifest, record,
    mfrmr_gtwar_candidate_evaluator, mfrmr_gtwar_reference_evaluator
  )
  if (!inherits(lock_receipt, "mfrmr_gtwao_lock_receipt") ||
      !isTRUE(lock_receipt$Acquired) ||
      !inherits(activation_receipt, "mfrmr_gtwao_activation_receipt") ||
      !identical(activation_receipt$ManifestHash,
                 manifest$ActiveManifestHash) ||
      !identical(activation_receipt$RuntimeHash,
                 contract$IsolatedRuntimeHash)) {
    stop("A held lock and exact active-manifest marker are required.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "record_bound_entry_job_b1g23_v1",
    EntryContractHash = contract$ContractHash,
    ActiveManifestHash = manifest$ActiveManifestHash,
    AuthorizationRecordHash = record$AuthorizationRecordHash,
    TargetHash = mfrmr_gta_hash(lock_receipt$Target),
    LockOwnerHash = lock_receipt$OwnerHash,
    LockHash = lock_receipt$LockHash,
    ActivationMarkerHash = activation_receipt$MarkerHash,
    RuntimeHash = activation_receipt$RuntimeHash,
    ContractObject = contract, ManifestObject = manifest,
    RecordObject = record
  )
  structure(c(identity, list(
    JobHash = mfrmr_gta_hash(identity),
    ExecutionMode = manifest$ExecutionMode,
    ConfirmationUse = FALSE
  )), class = "mfrmr_gtwar_job")
}

mfrmr_gtwar_job_hash_valid <- function(job) {
  fields <- c(
    "Contract", "EntryContractHash", "ActiveManifestHash",
    "AuthorizationRecordHash", "TargetHash", "LockOwnerHash", "LockHash",
    "ActivationMarkerHash", "RuntimeHash", "ContractObject",
    "ManifestObject", "RecordObject"
  )
  if (!inherits(job, "mfrmr_gtwar_job") ||
      !all(fields %in% names(job)) ||
      !identical(job$JobHash, mfrmr_gta_hash(job[fields])) ||
      !mfrmr_gtwar_contract_hash_valid(job$ContractObject) ||
      !mfrmr_gtwar_active_manifest_hash_valid(
        job$ManifestObject, job$ContractObject
      ) || !identical(job$EntryContractHash,
                      job$ContractObject$ContractHash) ||
      !identical(job$ActiveManifestHash,
                 job$ManifestObject$ActiveManifestHash) ||
      !identical(job$AuthorizationRecordHash,
                 job$RecordObject$AuthorizationRecordHash) ||
      !identical(job$ExecutionMode, job$ManifestObject$ExecutionMode) ||
      isTRUE(job$ConfirmationUse)) return(FALSE)
  isTRUE(tryCatch({
    mfrmr_gtwar_admit(
      job$ContractObject, job$ManifestObject, job$RecordObject,
      mfrmr_gtwar_candidate_evaluator, mfrmr_gtwar_reference_evaluator
    )
    TRUE
  }, error = function(error) FALSE))
}

mfrmr_gtwar_worker_run <- function(job, checkpoint_root, worker_path) {
  if (!mfrmr_gtwar_job_hash_valid(job)) {
    stop("The isolated child received an invalid b1g23 job.", call. = FALSE)
  }
  target <- mfrmr_gtwao_safe_target(checkpoint_root)
  contract <- job$ContractObject
  manifest <- job$ManifestObject
  policy <- contract$RecordBoundEntryPolicy
  entry_path <- file.path(dirname(worker_path), policy$EntryFileName)
  if (!identical(mfrmr_gtwao_sha256_file(worker_path),
                 policy$WorkerSourceHash) ||
      !identical(mfrmr_gtwao_sha256_file(entry_path),
                 policy$EntrySourceHash) ||
      !identical(mfrmr_gta_hash(target), job$TargetHash)) {
    stop("The isolated child source or target identity changed.",
         call. = FALSE)
  }
  kernel_policy <- contract$AuthorizationKernelPolicy
  lock_path <- paste0(target, kernel_policy$LockDirectorySuffix)
  owner <- tryCatch(readRDS(file.path(lock_path, "owner.rds")),
                    error = function(error) NULL)
  if (is.null(owner) || !identical(owner$OwnerHash, job$LockOwnerHash) ||
      !identical(owner$LockHash, job$LockHash)) {
    stop("The isolated child does not hold the expected writer lock.",
         call. = FALSE)
  }
  marker <- tryCatch(readRDS(file.path(
    target, kernel_policy$ActivationMarkerName
  )), error = function(error) NULL)
  marker_fields <- c(
    "Contract", "TargetHash", "ManifestHash", "RuntimeHash", "PolicyHash"
  )
  if (is.null(marker) || !all(marker_fields %in% names(marker)) ||
      !identical(marker$MarkerHash, mfrmr_gta_hash(marker[marker_fields])) ||
      !identical(marker$TargetHash, job$TargetHash) ||
      !identical(marker$PolicyHash, kernel_policy$PolicyHash) ||
      !identical(marker$MarkerHash, job$ActivationMarkerHash) ||
      !identical(marker$ManifestHash, manifest$ActiveManifestHash) ||
      !identical(marker$RuntimeHash, contract$IsolatedRuntimeHash)) {
    stop("The isolated child activation identity changed.", call. = FALSE)
  }
  execution <- mfrmr_gtwar_execute(
    contract, manifest, job$RecordObject, target
  )
  if (!mfrmr_gtwar_execution_hash_valid(
    execution, contract, manifest, job$RecordObject
  )) stop("The isolated child produced an invalid b1g23 ledger.",
          call. = FALSE)
  execution
}

mfrmr_gtwar_run <- function(contract, manifest, record, worker_path,
                             checkpoint_root) {
  mfrmr_gtwar_admit(
    contract, manifest, record,
    mfrmr_gtwar_candidate_evaluator, mfrmr_gtwar_reference_evaluator
  )
  policy <- contract$RecordBoundEntryPolicy
  entry_path <- file.path(dirname(worker_path), policy$EntryFileName)
  if (!identical(mfrmr_gtwao_sha256_file(worker_path),
                 policy$WorkerSourceHash) ||
      !identical(mfrmr_gtwao_sha256_file(entry_path),
                 policy$EntrySourceHash)) {
    stop("The exact b1g23 entry source and worker are required.",
         call. = FALSE)
  }
  target <- mfrmr_gtwao_safe_target(checkpoint_root)
  if (identical(manifest$ExecutionMode,
                "authorized_reserved_single_shard") &&
      !identical(mfrmr_gta_hash(target), record$SiteReceipt$OutputTargetHash)) {
    stop("The authorized output target differs from the fresh site receipt.",
         call. = FALSE)
  }
  owner_hash <- mfrmr_gta_hash(list(
    Contract = contract$ContractHash,
    ActiveManifest = manifest$ActiveManifestHash,
    AuthorizationRecord = record$AuthorizationRecordHash,
    Target = mfrmr_gta_hash(target)
  ))
  kernel_policy <- contract$AuthorizationKernelPolicy
  lock <- mfrmr_gtwao_lock_acquire(target, owner_hash, kernel_policy)
  lock_held <- TRUE
  on.exit(if (lock_held && dir.exists(lock$LockPath)) {
    mfrmr_gtwao_lock_release(lock)
  }, add = TRUE)
  activation <- mfrmr_gtwao_activate_root(
    lock, manifest$ActiveManifestHash, contract$IsolatedRuntimeHash,
    kernel_policy
  )
  job <- mfrmr_gtwar_job(contract, manifest, record, lock, activation)
  job_path <- tempfile("mfrmr-gtwar-job-", tmpdir = dirname(target),
                       fileext = ".rds")
  result_path <- tempfile("mfrmr-gtwar-result-", tmpdir = dirname(target),
                          fileext = ".rds")
  on.exit(unlink(c(job_path, result_path, paste0(result_path, ".new"))),
          add = TRUE)
  saveRDS(job, job_path, version = 3L)
  environment <- c(
    kernel_policy$RequiredThreadEnvironment,
    kernel_policy$RequiredLocaleEnvironment,
    kernel_policy$RequiredStartupEnvironment
  )
  output <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    c(
      "--vanilla", shQuote(normalizePath(
        worker_path, winslash = "/", mustWork = TRUE
      )), "--run-job", shQuote(job_path), shQuote(target),
      shQuote(result_path)
    ),
    env = paste0(names(environment), "=", unname(environment)),
    stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  status <- if (is.null(status)) 0L else as.integer(status)
  execution <- if (identical(status, 0L) && file.exists(result_path)) {
    tryCatch(readRDS(result_path), error = function(error) NULL)
  } else NULL
  if (is.null(execution) || !mfrmr_gtwar_execution_hash_valid(
    execution, contract, manifest, record
  )) stop(
    "The isolated record-bound runner failed: ", paste(output, collapse = "\n"),
    call. = FALSE
  )
  mfrmr_gtwao_lock_release(lock)
  lock_held <- FALSE
  identity <- list(
    Contract = "record_bound_entry_run_receipt_b1g23_v1",
    EntryContractHash = contract$ContractHash,
    ActiveManifestHash = manifest$ActiveManifestHash,
    AuthorizationRecordHash = record$AuthorizationRecordHash,
    JobHash = job$JobHash, ActivationState = activation$State,
    ActivationMarkerHash = activation$MarkerHash,
    ChildExitStatus = status, ChildOutputHash = mfrmr_gta_hash(output),
    ExecutionHash = execution$ExecutionHash,
    LockReleased = !dir.exists(lock$LockPath)
  )
  production <- identical(manifest$ExecutionMode,
                          "authorized_reserved_single_shard")
  structure(c(identity, list(
    ReceiptHash = mfrmr_gta_hash(identity), Job = job,
    Execution = execution, ExecutionMode = manifest$ExecutionMode,
    CalibrationExecutionAuthorized = production,
    CalibrationDataGenerated = production,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE
  )), class = "mfrmr_gtwar_run_receipt")
}

mfrmr_gtwar_run_receipt_hash_valid <- function(receipt, contract, manifest,
                                                record) {
  fields <- c(
    "Contract", "EntryContractHash", "ActiveManifestHash",
    "AuthorizationRecordHash", "JobHash", "ActivationState",
    "ActivationMarkerHash", "ChildExitStatus", "ChildOutputHash",
    "ExecutionHash", "LockReleased"
  )
  production <- identical(manifest$ExecutionMode,
                          "authorized_reserved_single_shard")
  inherits(receipt, "mfrmr_gtwar_run_receipt") &&
    all(fields %in% names(receipt)) &&
    identical(receipt$ReceiptHash, mfrmr_gta_hash(receipt[fields])) &&
    identical(receipt$EntryContractHash, contract$ContractHash) &&
    identical(receipt$ActiveManifestHash, manifest$ActiveManifestHash) &&
    identical(receipt$AuthorizationRecordHash,
              record$AuthorizationRecordHash) &&
    identical(receipt$JobHash, receipt$Job$JobHash) &&
    mfrmr_gtwar_job_hash_valid(receipt$Job) &&
    identical(receipt$ChildExitStatus, 0L) && isTRUE(receipt$LockReleased) &&
    identical(receipt$ExecutionHash, receipt$Execution$ExecutionHash) &&
    mfrmr_gtwar_execution_hash_valid(
      receipt$Execution, contract, manifest, record
    ) && identical(receipt$ExecutionMode, manifest$ExecutionMode) &&
    identical(receipt$CalibrationExecutionAuthorized, production) &&
    identical(receipt$CalibrationDataGenerated, production) &&
    !isTRUE(receipt$CalibrationResultsViewed) &&
    !isTRUE(receipt$ConfirmationAuthorized)
}

mfrmr_gtwar_run_reduction <- function(contract, manifest, record, worker_path,
                                       checkpoint_root) {
  if (!identical(manifest$ExecutionMode, "nonreserved_entry_reduction")) {
    stop("Only the b1g23 nonreserved reduction belongs in this entry point.",
         call. = FALSE)
  }
  mfrmr_gtwar_run(contract, manifest, record, worker_path, checkpoint_root)
}

mfrmr_gtwar_run_authorized_shard <- function(
    contract, manifest, record, worker_path, checkpoint_root) {
  if (!identical(manifest$ExecutionMode,
                 "authorized_reserved_single_shard") ||
      !mfrmr_gtwar_authorization_record_hash_valid(
        record, contract, manifest$SourceManifestObject
      )) {
    stop("One separately issued exact R0201 production record is required.",
         call. = FALSE)
  }
  mfrmr_gtwar_run(contract, manifest, record, worker_path, checkpoint_root)
}
