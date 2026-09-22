# Draft.83d2b2b1g21 authorization-bound guarded shard runner.
#
# Repository-internal only.  This layer joins the frozen hardened evaluator
# path to the b1g20 isolated-runtime and lock/root kernel.  Its executable
# fixture is nonreserved replicate 902.  Replicates 201--300 remain sealed
# until a separate authorization record is defined and issued.

mfrmr_gtwap_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwag_function_hash",
    "mfrmr_gtwag_manifest_hash_valid", "mfrmr_gtwag_execute",
    "mfrmr_gtwam_contract_hash_valid", "mfrmr_gtwam_dry_manifest",
    "mfrmr_gtwam_prepare_unit", "mfrmr_gtwam_candidate_evaluator",
    "mfrmr_gtwam_reference_evaluator", "mfrmr_gtwan_contract_hash_valid",
    "mfrmr_gtwao_contract_hash_valid", "mfrmr_gtwao_preflight_hash_valid",
    "mfrmr_gtwao_policy_hash_valid",
    "mfrmr_gtwao_runtime_probe_hash_valid",
    "mfrmr_gtwao_mechanics_audit_hash_valid",
    "mfrmr_gtwao_sha256_file", "mfrmr_gtwao_safe_target",
    "mfrmr_gtwao_lock_acquire", "mfrmr_gtwao_lock_release",
    "mfrmr_gtwao_activate_root"
  )
  runner_environment <- environment(mfrmr_gtwap_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = runner_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g18--b1g20 chain before the b1g21 guarded runner: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwap_function_hash <- function(fun) {
  mfrmr_gta_hash(list(
    Formals = formals(fun),
    Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  ))
}

mfrmr_gtwap_policy <- function(worker_path, kernel_contract,
                                kernel_preflight) {
  worker_hash <- mfrmr_gtwao_sha256_file(worker_path)
  runner_path <- file.path(
    dirname(worker_path),
    "gtheory-weak-information-guarded-shard-runner-0.2.3.R"
  )
  runner_hash <- mfrmr_gtwao_sha256_file(runner_path)
  identity <- list(
    Contract = "guarded_shard_runner_policy_b1g21_v1",
    RunnerFileName = basename(runner_path), RunnerSourceHash = runner_hash,
    WorkerFileName = basename(worker_path), WorkerSourceHash = worker_hash,
    AuthorizationKernelContractHash = kernel_contract$ContractHash,
    IsolatedRuntimeHash = kernel_preflight$RuntimeProbe$Runtime$RuntimeHash,
    FixtureScenarioId = "GT-WI-baseline_complete-reference_1200",
    FixtureReplicate = 902L,
    ReservedCalibrationReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    RequiredMethodIds = c(
      "glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml"
    ),
    MaximumConcurrentShards = 1L,
    CompleteFailureDenominatorRequired = TRUE,
    ExactResumeRequired = TRUE,
    IsolatedChildRequired = TRUE,
    HeldExclusiveLockRequired = TRUE,
    ActivationMarkerRequired = TRUE,
    EarlyStoppingPermitted = FALSE,
    AuthorizationRecordIssued = FALSE,
    ReservedResponseGenerationPermitted = FALSE,
    ConfirmationAccessPermitted = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwap_policy")
}

mfrmr_gtwap_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwap_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity)) &&
    identical(policy$FixtureReplicate, 902L) &&
    identical(policy$ReservedCalibrationReplicates, 201:300) &&
    identical(policy$ConfirmationReplicates, 501:700) &&
    identical(policy$MaximumConcurrentShards, 1L) &&
    isTRUE(policy$CompleteFailureDenominatorRequired) &&
    isTRUE(policy$ExactResumeRequired) &&
    isTRUE(policy$IsolatedChildRequired) &&
    isTRUE(policy$HeldExclusiveLockRequired) &&
    isTRUE(policy$ActivationMarkerRequired) &&
    !isTRUE(policy$EarlyStoppingPermitted) &&
    !isTRUE(policy$AuthorizationRecordIssued) &&
    !isTRUE(policy$ReservedResponseGenerationPermitted) &&
    !isTRUE(policy$ConfirmationAccessPermitted)
}

mfrmr_gtwap_bind_prepare <- function(fun) {
  bridge <- new.env(parent = environment(fun))
  assign("mfrmr_gtwam_prepare_unit", mfrmr_gtwap_prepare_unit,
         envir = bridge)
  environment(fun) <- bridge
  fun
}

mfrmr_gtwap_prepare_unit <- function(
    contract, unit, registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwap_contract") ||
      !is.data.frame(unit) || nrow(unit) != 1L ||
      !all(c(
        "AtomicUnitId", "DatasetId", "ScenarioId", "Replicate",
        "MethodId", "Backend", "Likelihood"
      ) %in% names(unit))) {
    stop("The exact b1g21 contract and one atomic unit are required.",
         call. = FALSE)
  }
  replicate <- as.integer(unit$Replicate[[1L]])
  policy <- contract$GuardedRunnerPolicy
  if (replicate %in% policy$ConfirmationReplicates) {
    stop("Confirmation replicates remain inaccessible.", call. = FALSE)
  }
  if (replicate %in% policy$ReservedCalibrationReplicates) {
    stop(
      "A reserved replicate requires a separately issued authorization record.",
      call. = FALSE
    )
  }
  if (!identical(replicate, policy$FixtureReplicate) ||
      !identical(unit$ScenarioId[[1L]], policy$FixtureScenarioId)) {
    stop("Only the exact nonreserved b1g21 reduction fixture is executable.",
         call. = FALSE)
  }
  mfrmr_gtwam_prepare_unit(contract, unit, registry)
}

mfrmr_gtwap_candidate_evaluator <- function(contract, unit) {
  evaluator <- mfrmr_gtwap_bind_prepare(mfrmr_gtwam_candidate_evaluator)
  evaluator(contract, unit)
}

mfrmr_gtwap_reference_evaluator <- function(contract, unit) {
  evaluator <- mfrmr_gtwap_bind_prepare(mfrmr_gtwam_reference_evaluator)
  evaluator(contract, unit)
}

mfrmr_gtwap_adapter_hashes <- function() {
  c(
    CandidateEvaluator =
      mfrmr_gtwag_function_hash(mfrmr_gtwap_candidate_evaluator),
    ReferenceEvaluator =
      mfrmr_gtwag_function_hash(mfrmr_gtwap_reference_evaluator)
  )
}

mfrmr_gtwap_dependency_hashes <- function() {
  functions <- list(
    prepare_unit = mfrmr_gtwap_prepare_unit,
    bind_prepare = mfrmr_gtwap_bind_prepare,
    candidate_bridge = mfrmr_gtwap_candidate_evaluator,
    reference_bridge = mfrmr_gtwap_reference_evaluator,
    parent_prepare = mfrmr_gtwam_prepare_unit,
    parent_candidate = mfrmr_gtwam_candidate_evaluator,
    parent_reference = mfrmr_gtwam_reference_evaluator,
    checkpoint_runner = mfrmr_gtwag_execute,
    lock_acquire = mfrmr_gtwao_lock_acquire,
    root_activate = mfrmr_gtwao_activate_root
  )
  vapply(functions, mfrmr_gtwap_function_hash, character(1L))
}

mfrmr_gtwap_contract <- function(hardened_adapter_contract,
                                  lineage_contract, kernel_contract,
                                  kernel_preflight, worker_path) {
  mfrmr_gtwap_require_primitives()
  policy <- mfrmr_gtwap_policy(
    worker_path, kernel_contract, kernel_preflight
  )
  if (!mfrmr_gtwam_contract_hash_valid(hardened_adapter_contract) ||
      !mfrmr_gtwan_contract_hash_valid(lineage_contract) ||
      !mfrmr_gtwao_contract_hash_valid(kernel_contract) ||
      !mfrmr_gtwao_preflight_hash_valid(kernel_preflight) ||
      !mfrmr_gtwao_runtime_probe_hash_valid(
        kernel_preflight$RuntimeProbe
      ) || !isTRUE(kernel_preflight$RuntimeProbe$IsolatedRuntimeReady) ||
      !mfrmr_gtwao_mechanics_audit_hash_valid(
        kernel_preflight$MechanicsAudit
      ) || !isTRUE(kernel_preflight$MechanicsAudit$LockRootKernelReady) ||
      !identical(
        lineage_contract$HardenedAdapterContractHash,
        hardened_adapter_contract$ContractHash
      ) || !identical(
        kernel_contract$LineageContractHash, lineage_contract$ContractHash
      ) || !identical(
        kernel_preflight$AuthorizationKernelContractHash,
        kernel_contract$ContractHash
      )) {
    stop("Exact b1g18--b1g20 evidence is required.", call. = FALSE)
  }
  identity <- list(
    Contract = "guarded_shard_runner_contract_b1g21_v1",
    HardenedAdapterContractHash = hardened_adapter_contract$ContractHash,
    HardenedLineageContractHash = lineage_contract$ContractHash,
    ReservedManifestHash = kernel_contract$ReservedManifestHash,
    ShardBundleHash = kernel_contract$ShardBundleHash,
    AuthorizationKernelContractHash = kernel_contract$ContractHash,
    AuthorizationKernelPolicy = kernel_contract$KernelPolicy,
    GuardedRunnerPolicy = policy,
    ParentAdapterHashes = hardened_adapter_contract$AdapterHashes,
    AdapterHashes = mfrmr_gtwap_adapter_hashes(),
    AdapterDependencyHashes = mfrmr_gtwap_dependency_hashes()
  )
  base <- unclass(hardened_adapter_contract)
  for (name in unique(c(
    names(identity), "Contract", "ContractHash", "AdapterHashes",
    "AdapterDependencyHashes", "RunnerImplementationReady",
    "ReservedAdapterEntryPointReady", "AuthorizedSingleShardRunnerReady",
    "AuthorizationRecordIssued", "AuthorizationRNG01Closed",
    "AuthorizationActivationEligible", "LargeSimulationMayStart",
    "Replicate201MayBeOpened", "CalibrationExecutionAuthorized",
    "CalibrationDataGenerated", "CalibrationResultsViewed",
    "ConfirmationAuthorized", "InferenceReady", "DecisionReady"
  ))) base[[name]] <- NULL
  structure(c(base, identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    GuardedRunnerContractFrozen = TRUE,
    AuthorizationBoundReservedEntryPointDefined = TRUE,
    NonreservedScientificReductionAuthorized = TRUE,
    GuardedSingleShardRunnerImplemented = TRUE,
    RunnerImplementationReady = TRUE,
    ReservedAdapterEntryPointReady = FALSE,
    AuthorizedSingleShardRunnerReady = FALSE,
    AuthorizationRecordIssued = FALSE,
    AuthorizationRNG01Closed = FALSE,
    AuthorizationActivationEligible = FALSE,
    LargeSimulationMayStart = FALSE, Replicate201MayBeOpened = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    DecisionReady = FALSE
  )), class = c(
    "mfrmr_gtwap_contract", "mfrmr_gtwam_contract",
    "mfrmr_gtwah_contract", "mfrmr_gtwag_contract"
  ))
}

mfrmr_gtwap_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "HardenedAdapterContractHash",
    "HardenedLineageContractHash", "ReservedManifestHash",
    "ShardBundleHash", "AuthorizationKernelContractHash",
    "AuthorizationKernelPolicy", "GuardedRunnerPolicy",
    "ParentAdapterHashes", "AdapterHashes", "AdapterDependencyHashes"
  )
  inherits(contract, "mfrmr_gtwap_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwap_policy_hash_valid(contract$GuardedRunnerPolicy) &&
    mfrmr_gtwao_policy_hash_valid(contract$AuthorizationKernelPolicy) &&
    identical(contract$AdapterHashes, mfrmr_gtwap_adapter_hashes()) &&
    identical(contract$AdapterDependencyHashes,
              mfrmr_gtwap_dependency_hashes()) &&
    isTRUE(contract$GuardedRunnerContractFrozen) &&
    isTRUE(contract$AuthorizationBoundReservedEntryPointDefined) &&
    isTRUE(contract$NonreservedScientificReductionAuthorized) &&
    isTRUE(contract$GuardedSingleShardRunnerImplemented) &&
    isTRUE(contract$RunnerImplementationReady) &&
    !isTRUE(contract$ReservedAdapterEntryPointReady) &&
    !isTRUE(contract$AuthorizedSingleShardRunnerReady) &&
    !isTRUE(contract$AuthorizationRecordIssued) &&
    !isTRUE(contract$AuthorizationRNG01Closed) &&
    !isTRUE(contract$AuthorizationActivationEligible) &&
    !isTRUE(contract$LargeSimulationMayStart) &&
    !isTRUE(contract$Replicate201MayBeOpened) &&
    !isTRUE(contract$CalibrationExecutionAuthorized) &&
    !isTRUE(contract$ConfirmationAuthorized) &&
    !isTRUE(contract$InferenceReady) && !isTRUE(contract$DecisionReady)
}

mfrmr_gtwap_fixture_manifest <- function(contract) {
  if (!mfrmr_gtwap_contract_hash_valid(contract)) {
    stop("The exact b1g21 contract is required.", call. = FALSE)
  }
  policy <- contract$GuardedRunnerPolicy
  lanes <- unique(contract$ReferenceReceipts[c("MethodId", "Backend")])
  lanes <- lanes[match(
    policy$RequiredMethodIds, lanes$MethodId
  ), , drop = FALSE]
  dataset_id <- sprintf(
    "%s/R%04d", policy$FixtureScenarioId, policy$FixtureReplicate
  )
  units <- data.frame(
    AtomicUnitId = paste(dataset_id, lanes$MethodId, sep = "::"),
    DatasetId = dataset_id, ScenarioId = policy$FixtureScenarioId,
    Replicate = policy$FixtureReplicate, MethodId = lanes$MethodId,
    Backend = lanes$Backend,
    Likelihood = ifelse(grepl("_reml$", lanes$MethodId), "REML", "ML"),
    stringsAsFactors = FALSE
  )
  counts <- table(contract$Profiles$Backend)
  units$ExpectedCandidateFitRows <- 2L * as.integer(counts[units$Backend])
  units$ExpectedCandidateDecisionRows <-
    contract$Policy$CandidateDecisionsPerAtomicUnit
  units$ExpectedReferenceRows <- 2L
  units$CalibrationUse <- FALSE
  units$MechanicsFixture <- FALSE
  units$ProductionAdapterDryRun <- TRUE
  units$ExecutionAuthorized <- TRUE
  units$GuardedRunnerFixture <- TRUE
  units$AuthorizationKernelContractHash <-
    contract$AuthorizationKernelContractHash
  units$IsolatedRuntimeHash <-
    contract$GuardedRunnerPolicy$IsolatedRuntimeHash
  units$AtomicUnitIdentityHash <- vapply(
    seq_len(nrow(units)), function(index) {
      mfrmr_gta_hash(units[index, , drop = FALSE])
    }, character(1L)
  )
  identity <- list(
    Contract = "guarded_shard_runner_fixture_manifest_b1g21_v1",
    RunnerContractHash = contract$ContractHash,
    ExecutionMode = "isolated_nonreserved_scientific_reduction",
    Units = units,
    CandidateEvaluatorHash = contract$AdapterHashes[["CandidateEvaluator"]],
    ReferenceEvaluatorHash = contract$AdapterHashes[["ReferenceEvaluator"]],
    Replicates = 902L, ReservedCalibrationUse = FALSE,
    ConfirmationUse = FALSE
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    AtomicUnitCount = nrow(units), DatasetCount = 1L,
    CandidateFitRowCount = sum(units$ExpectedCandidateFitRows),
    CandidateDecisionRowCount = sum(units$ExpectedCandidateDecisionRows),
    ReferenceRowCount = sum(units$ExpectedReferenceRows),
    ExecutionAuthorized = TRUE,
    CalibrationExecutionAuthorized = FALSE,
    DataGenerated = FALSE, ResultsViewed = FALSE
  )), class = "mfrmr_gtwag_manifest")
}

mfrmr_gtwap_fixture_manifest_hash_valid <- function(manifest, contract) {
  mfrmr_gtwap_contract_hash_valid(contract) &&
    mfrmr_gtwag_manifest_hash_valid(manifest) &&
    identical(manifest$RunnerContractHash, contract$ContractHash) &&
    identical(manifest$ExecutionMode,
              "isolated_nonreserved_scientific_reduction") &&
    identical(manifest$Replicates, 902L) &&
    identical(manifest$AtomicUnitCount, 4L) &&
    identical(manifest$DatasetCount, 1L) &&
    identical(manifest$CandidateFitRowCount, 36L) &&
    identical(manifest$CandidateDecisionRowCount, 192L) &&
    identical(manifest$ReferenceRowCount, 8L) &&
    all(manifest$Units$GuardedRunnerFixture) &&
    !isTRUE(manifest$ReservedCalibrationUse) &&
    !isTRUE(manifest$ConfirmationUse) &&
    isTRUE(manifest$ExecutionAuthorized) &&
    !isTRUE(manifest$CalibrationExecutionAuthorized)
}

mfrmr_gtwap_execution_hash_valid <- function(execution, contract, manifest) {
  fields <- c(
    "Contract", "RunnerContractHash", "RunManifestHash", "CandidateFits",
    "CandidateDecisions", "References", "AcceptanceLedger",
    "AcceptanceCellSummary", "UnitCheckpointHashes", "DatasetMarkerHashes"
  )
  inherits(execution, "mfrmr_gtwag_execution") &&
    all(fields %in% names(execution)) &&
    identical(execution$RunnerContractHash, contract$ContractHash) &&
    identical(execution$RunManifestHash, manifest$ManifestHash) &&
    identical(execution$ExecutionHash, mfrmr_gta_hash(execution[fields])) &&
    isTRUE(execution$ExactAccountingPassed) && isTRUE(execution$Complete) &&
    identical(nrow(execution$CandidateFits), manifest$CandidateFitRowCount) &&
    identical(nrow(execution$CandidateDecisions),
              manifest$CandidateDecisionRowCount) &&
    identical(nrow(execution$References), manifest$ReferenceRowCount)
}

mfrmr_gtwap_job <- function(contract, manifest, lock_receipt,
                             activation_receipt) {
  if (!mfrmr_gtwap_fixture_manifest_hash_valid(manifest, contract) ||
      !inherits(lock_receipt, "mfrmr_gtwao_lock_receipt") ||
      !isTRUE(lock_receipt$Acquired) ||
      !inherits(activation_receipt, "mfrmr_gtwao_activation_receipt") ||
      !identical(activation_receipt$ManifestHash, manifest$ManifestHash) ||
      !identical(
        activation_receipt$RuntimeHash,
        contract$GuardedRunnerPolicy$IsolatedRuntimeHash
      )) {
    stop("A valid fixture, held lock, and activation receipt are required.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "guarded_shard_runner_job_b1g21_v1",
    GuardedRunnerContractHash = contract$ContractHash,
    ManifestHash = manifest$ManifestHash,
    TargetHash = mfrmr_gta_hash(lock_receipt$Target),
    LockOwnerHash = lock_receipt$OwnerHash,
    LockHash = lock_receipt$LockHash,
    ActivationMarkerHash = activation_receipt$MarkerHash,
    RuntimeHash = activation_receipt$RuntimeHash,
    ContractObject = contract, ManifestObject = manifest
  )
  structure(c(identity, list(
    JobHash = mfrmr_gta_hash(identity), NonreservedFixtureOnly = TRUE,
    ReservedCalibrationUse = FALSE, ConfirmationUse = FALSE
  )), class = "mfrmr_gtwap_job")
}

mfrmr_gtwap_job_hash_valid <- function(job) {
  fields <- c(
    "Contract", "GuardedRunnerContractHash", "ManifestHash", "TargetHash",
    "LockOwnerHash", "LockHash", "ActivationMarkerHash", "RuntimeHash",
    "ContractObject", "ManifestObject"
  )
  inherits(job, "mfrmr_gtwap_job") && all(fields %in% names(job)) &&
    identical(job$JobHash, mfrmr_gta_hash(job[fields])) &&
    mfrmr_gtwap_contract_hash_valid(job$ContractObject) &&
    mfrmr_gtwap_fixture_manifest_hash_valid(
      job$ManifestObject, job$ContractObject
    ) && identical(
      job$GuardedRunnerContractHash, job$ContractObject$ContractHash
    ) && identical(job$ManifestHash, job$ManifestObject$ManifestHash) &&
    isTRUE(job$NonreservedFixtureOnly) &&
    !isTRUE(job$ReservedCalibrationUse) && !isTRUE(job$ConfirmationUse)
}

mfrmr_gtwap_worker_run <- function(job, checkpoint_root, worker_path) {
  if (!mfrmr_gtwap_job_hash_valid(job)) {
    stop("The isolated child received an invalid job capsule.", call. = FALSE)
  }
  target <- mfrmr_gtwao_safe_target(checkpoint_root)
  contract <- job$ContractObject
  manifest <- job$ManifestObject
  policy <- contract$GuardedRunnerPolicy
  runner_path <- file.path(dirname(worker_path), policy$RunnerFileName)
  if (!identical(mfrmr_gtwao_sha256_file(worker_path),
                 policy$WorkerSourceHash) ||
      !identical(mfrmr_gtwao_sha256_file(runner_path),
                 policy$RunnerSourceHash)) {
    stop("The isolated child runner source identity changed.", call. = FALSE)
  }
  if (!identical(mfrmr_gta_hash(target), job$TargetHash)) {
    stop("The job target identity changed.", call. = FALSE)
  }
  lock_path <- paste0(
    target, contract$AuthorizationKernelPolicy$LockDirectorySuffix
  )
  owner <- tryCatch(readRDS(file.path(lock_path, "owner.rds")),
                    error = function(error) NULL)
  if (is.null(owner) || !identical(owner$OwnerHash, job$LockOwnerHash) ||
      !identical(owner$LockHash, job$LockHash)) {
    stop("The isolated child does not hold the expected writer lock.",
         call. = FALSE)
  }
  marker <- tryCatch(readRDS(file.path(
    target, contract$AuthorizationKernelPolicy$ActivationMarkerName
  )), error = function(error) NULL)
  marker_fields <- c(
    "Contract", "TargetHash", "ManifestHash", "RuntimeHash", "PolicyHash"
  )
  if (is.null(marker) ||
      !all(marker_fields %in% names(marker)) ||
      !identical(marker$MarkerHash, mfrmr_gta_hash(marker[marker_fields])) ||
      !identical(marker$TargetHash, job$TargetHash) ||
      !identical(marker$PolicyHash,
                 contract$AuthorizationKernelPolicy$PolicyHash) ||
      !identical(marker$MarkerHash, job$ActivationMarkerHash) ||
      !identical(marker$ManifestHash, manifest$ManifestHash) ||
      !identical(marker$RuntimeHash, policy$IsolatedRuntimeHash)) {
    stop("The isolated child activation identity changed.", call. = FALSE)
  }
  execution <- mfrmr_gtwag_execute(
    contract, manifest, target,
    candidate_evaluator = mfrmr_gtwap_candidate_evaluator,
    reference_evaluator = mfrmr_gtwap_reference_evaluator
  )
  if (!mfrmr_gtwap_execution_hash_valid(execution, contract, manifest)) {
    stop("The isolated child produced an invalid execution ledger.",
         call. = FALSE)
  }
  execution
}

mfrmr_gtwap_run_fixture <- function(contract, manifest, worker_path,
                                     checkpoint_root) {
  runner_path <- file.path(
    dirname(worker_path), contract$GuardedRunnerPolicy$RunnerFileName
  )
  if (!mfrmr_gtwap_fixture_manifest_hash_valid(manifest, contract) ||
      !identical(
        mfrmr_gtwao_sha256_file(worker_path),
        contract$GuardedRunnerPolicy$WorkerSourceHash
      ) || !identical(
        mfrmr_gtwao_sha256_file(runner_path),
        contract$GuardedRunnerPolicy$RunnerSourceHash
      )) {
    stop("The exact b1g21 fixture and worker are required.", call. = FALSE)
  }
  target <- mfrmr_gtwao_safe_target(checkpoint_root)
  owner_hash <- mfrmr_gta_hash(list(
    Contract = contract$ContractHash, Manifest = manifest$ManifestHash,
    Target = mfrmr_gta_hash(target)
  ))
  kernel_policy <- contract$AuthorizationKernelPolicy
  lock <- mfrmr_gtwao_lock_acquire(target, owner_hash, kernel_policy)
  lock_held <- TRUE
  on.exit(if (lock_held && dir.exists(lock$LockPath)) {
    mfrmr_gtwao_lock_release(lock)
  }, add = TRUE)
  activation <- mfrmr_gtwao_activate_root(
    lock, manifest$ManifestHash,
    contract$GuardedRunnerPolicy$IsolatedRuntimeHash, kernel_policy
  )
  job <- mfrmr_gtwap_job(contract, manifest, lock, activation)
  job_path <- tempfile("mfrmr-gtwap-job-", tmpdir = dirname(target),
                       fileext = ".rds")
  result_path <- tempfile("mfrmr-gtwap-result-", tmpdir = dirname(target),
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
  if (is.null(execution) ||
      !mfrmr_gtwap_execution_hash_valid(execution, contract, manifest)) {
    stop(
      "The isolated guarded runner failed: ", paste(output, collapse = "\n"),
      call. = FALSE
    )
  }
  mfrmr_gtwao_lock_release(lock)
  lock_held <- FALSE
  identity <- list(
    Contract = "guarded_shard_runner_receipt_b1g21_v1",
    GuardedRunnerContractHash = contract$ContractHash,
    ManifestHash = manifest$ManifestHash, JobHash = job$JobHash,
    ActivationState = activation$State,
    ActivationMarkerHash = activation$MarkerHash,
    ChildExitStatus = status, ChildOutputHash = mfrmr_gta_hash(output),
    ExecutionHash = execution$ExecutionHash,
    LockReleased = !dir.exists(lock$LockPath)
  )
  structure(c(identity, list(
    ReceiptHash = mfrmr_gta_hash(identity), Job = job,
    Execution = execution,
    NonreservedScientificReductionPassed = TRUE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, ConfirmationAuthorized = FALSE
  )), class = "mfrmr_gtwap_run_receipt")
}

mfrmr_gtwap_run_receipt_hash_valid <- function(receipt, contract, manifest) {
  fields <- c(
    "Contract", "GuardedRunnerContractHash", "ManifestHash", "JobHash",
    "ActivationState", "ActivationMarkerHash", "ChildExitStatus",
    "ChildOutputHash", "ExecutionHash", "LockReleased"
  )
  inherits(receipt, "mfrmr_gtwap_run_receipt") &&
    all(fields %in% names(receipt)) &&
    identical(receipt$ReceiptHash, mfrmr_gta_hash(receipt[fields])) &&
    identical(receipt$GuardedRunnerContractHash, contract$ContractHash) &&
    identical(receipt$ManifestHash, manifest$ManifestHash) &&
    identical(receipt$ChildExitStatus, 0L) && isTRUE(receipt$LockReleased) &&
    identical(receipt$JobHash, receipt$Job$JobHash) &&
    mfrmr_gtwap_job_hash_valid(receipt$Job) &&
    identical(receipt$ExecutionHash, receipt$Execution$ExecutionHash) &&
    mfrmr_gtwap_execution_hash_valid(receipt$Execution, contract, manifest) &&
    isTRUE(receipt$NonreservedScientificReductionPassed) &&
    !isTRUE(receipt$CalibrationExecutionAuthorized) &&
    !isTRUE(receipt$CalibrationDataGenerated) &&
    !isTRUE(receipt$ConfirmationAuthorized)
}

mfrmr_gtwap_semantic_rows_equal <- function(old, new, excluded) {
  common <- setdiff(intersect(names(old), names(new)), excluded)
  identical(old[common], new[common])
}

mfrmr_gtwap_audit <- function(contract, manifest, parent_execution,
                               initial_receipt, resume_receipt) {
  if (!mfrmr_gtwap_fixture_manifest_hash_valid(manifest, contract) ||
      !inherits(parent_execution, "mfrmr_gtwag_execution") ||
      !mfrmr_gtwap_run_receipt_hash_valid(
        initial_receipt, contract, manifest
      ) || !mfrmr_gtwap_run_receipt_hash_valid(
        resume_receipt, contract, manifest
      )) {
    stop("Exact parent and guarded executions are required.", call. = FALSE)
  }
  initial <- initial_receipt$Execution
  resume <- resume_receipt$Execution
  candidate_parity <- mfrmr_gtwap_semantic_rows_equal(
    parent_execution$CandidateFits, initial$CandidateFits,
    c("GeneratorHash", "PreFitHash")
  )
  decision_parity <- identical(
    parent_execution$CandidateDecisions, initial$CandidateDecisions
  )
  reference_parity <- mfrmr_gtwap_semantic_rows_equal(
    parent_execution$References, initial$References,
    c("ReferenceSidecarHash", "GeneratorHash", "PreFitHash")
  )
  exact_resume <- identical(initial$ExecutionHash, resume$ExecutionHash) &&
    identical(initial$UnitCheckpointHashes, resume$UnitCheckpointHashes) &&
    identical(initial$DatasetMarkerHashes, resume$DatasetMarkerHashes) &&
    identical(initial$ComputedUnitCount, 4L) &&
    identical(resume$ReusedUnitCount, 4L) &&
    identical(resume$ComputedUnitCount, 0L)
  identity <- list(
    Contract = "guarded_shard_runner_audit_b1g21_v1",
    GuardedRunnerContractHash = contract$ContractHash,
    FixtureManifestHash = manifest$ManifestHash,
    ParentExecutionHash = parent_execution$ExecutionHash,
    InitialReceiptHash = initial_receipt$ReceiptHash,
    ResumeReceiptHash = resume_receipt$ReceiptHash,
    CandidateSemanticParity = candidate_parity,
    CandidateDecisionParity = decision_parity,
    ReferenceSemanticParity = reference_parity,
    ExactResumePassed = exact_resume,
    InitialActivationObserved =
      identical(initial_receipt$ActivationState, "initial_activation"),
    ExactResumeActivationObserved =
      identical(resume_receipt$ActivationState, "exact_resume"),
    CompleteDenominatorsObserved = identical(c(
      nrow(initial$CandidateFits), nrow(initial$CandidateDecisions),
      nrow(initial$References)
    ), c(36L, 192L, 8L)),
    ReservedExecutionAttempted = FALSE,
    CalibrationResponsesUsed = FALSE, ConfirmationResponsesUsed = FALSE
  )
  ready <- all(c(
    identity$CandidateSemanticParity, identity$CandidateDecisionParity,
    identity$ReferenceSemanticParity, identity$ExactResumePassed,
    identity$InitialActivationObserved,
    identity$ExactResumeActivationObserved,
    identity$CompleteDenominatorsObserved
  ))
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    GuardedSingleShardRunnerReady = ready,
    Runner01Closed = ready,
    RemainingAuthorizationBlockerIds = "AUTH-RECORD-01",
    ReservedAdapterEntryPointReady = FALSE,
    AuthorizedSingleShardRunnerReady = FALSE,
    AuthorizationRecordIssued = FALSE,
    AuthorizationRNG01Closed = FALSE,
    AuthorizationActivationEligible = FALSE,
    LargeSimulationMayStart = FALSE, Replicate201MayBeOpened = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwap_audit")
}

mfrmr_gtwap_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "GuardedRunnerContractHash", "FixtureManifestHash",
    "ParentExecutionHash", "InitialReceiptHash", "ResumeReceiptHash",
    "CandidateSemanticParity", "CandidateDecisionParity",
    "ReferenceSemanticParity", "ExactResumePassed",
    "InitialActivationObserved", "ExactResumeActivationObserved",
    "CompleteDenominatorsObserved", "ReservedExecutionAttempted",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  ready <- inherits(audit, "mfrmr_gtwap_audit") && all(c(
    audit$CandidateSemanticParity, audit$CandidateDecisionParity,
    audit$ReferenceSemanticParity, audit$ExactResumePassed,
    audit$InitialActivationObserved, audit$ExactResumeActivationObserved,
    audit$CompleteDenominatorsObserved
  ))
  inherits(audit, "mfrmr_gtwap_audit") && all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$GuardedSingleShardRunnerReady, ready) &&
    identical(audit$Runner01Closed, ready) &&
    identical(audit$RemainingAuthorizationBlockerIds, "AUTH-RECORD-01") &&
    !isTRUE(audit$ReservedExecutionAttempted) &&
    !isTRUE(audit$ReservedAdapterEntryPointReady) &&
    !isTRUE(audit$AuthorizedSingleShardRunnerReady) &&
    !isTRUE(audit$AuthorizationRecordIssued) &&
    !isTRUE(audit$AuthorizationRNG01Closed) &&
    !isTRUE(audit$AuthorizationActivationEligible) &&
    !isTRUE(audit$LargeSimulationMayStart) &&
    !isTRUE(audit$Replicate201MayBeOpened) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed) &&
    !isTRUE(audit$ConfirmationAuthorized) &&
    !isTRUE(audit$InferenceReady) && !isTRUE(audit$DecisionReady) &&
    !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
}
