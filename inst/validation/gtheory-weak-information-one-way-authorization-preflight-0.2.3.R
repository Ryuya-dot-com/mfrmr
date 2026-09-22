# Draft.83d2b2b1g15 response-free one-way authorization preflight.
#
# Repository-internal only. This file freezes prospective per-replicate shard
# manifests, performs an output-filesystem probe, and audits conservative disk
# and serial-time planning. It does not authorize execution and does not
# generate or inspect calibration replicates 201--300 or confirmation
# replicates 501--700.

mfrmr_gtwai_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwaa_manifest_hash_valid",
    "mfrmr_gtwag_sealed_units", "mfrmr_gtwah_runtime_identity",
    "mfrmr_gtwah_reserved_manifest_hash_valid"
  )
  preflight_environment <- environment(mfrmr_gtwai_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = preflight_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g14 production-adapter chain before b1g15: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwai_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwai_policy <- function() {
  identity <- list(
    Contract = "one_way_authorization_preflight_policy_b1g15_v1",
    ReservedReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    ShardOrder = sprintf("R%04d", 201:300),
    ShardExecutionUnit = "one_replicate_all_30_datasets_all_four_methods",
    ShardCount = 100L,
    AtomicUnitsPerShard = 120L,
    CandidateFitsPerShard = 1080L,
    CandidateDecisionsPerShard = 5760L,
    ReferencesPerShard = 240L,
    MaxConcurrentShards = 1L,
    RestartUnit = "one_dataset_method_atomic_checkpoint",
    EarlyStoppingPermitted = FALSE,
    ConfirmationAccessPermitted = FALSE,
    OutputRootMustBeAbsentBeforeActivation = TRUE,
    ProbeMustUseOutputParent = TRUE,
    AtomicInstall = "same_directory_file_rename_checked",
    DiskSafetyMultiplier = 32,
    MinimumResidualFreeBytes = 32 * 1024^3,
    RuntimePlanningMultiplier = 4,
    MaximumPlanningSerialHours = 400,
    MaximumPlanningShardHours = 4,
    FilesystemMustBeRecheckedAtActivation = TRUE,
    RuntimeMustBeRecheckedAtActivation = TRUE,
    ManualActivationArtifactRequired = TRUE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwai_policy")
}

mfrmr_gtwai_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwai_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity))
}

mfrmr_gtwai_source_registry <- function() {
  data.frame(
    SourceId = c(
      "morris_white_crowther_2019", "r_file_access_current",
      "r_file_rename_current", "r_system2_current"
    ),
    Locator = c(
      "https://doi.org/10.1002/sim.8086",
      paste0(
        "https://stat.ethz.ch/R-manual/R-devel/library/",
        "base/help/file.access.html"
      ),
      "https://stat.ethz.ch/R-manual/R-devel/library/base/html/files.html",
      "https://stat.ethz.ch/R-manual/R-devel/library/base/html/system2.html"
    ),
    ContractRole = c(
      "prospective ADEMP execution and complete failure accounting",
      "permission result is advisory and must be followed by an actual write",
      "checked same-directory rename rather than cross-filesystem installation",
      "captured df command status and output for site-specific free space"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwai_b1g14_receipt <- function() {
  identity <- list(
    AdapterContractHash =
      "baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1",
    ReservedManifestHash =
      "019fedf063ce90c3492f9eb37f6dbec43a42474ce9096e7cc2891491d7a158c8",
    DryManifestHash =
      "cb9fe43e82be6ed64dc08db94998114b5a3f1f420914e1e5491cee3c79f2554c",
    DryExecutionHash =
      "b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae",
    AdapterPreflightHash =
      "eddbe9cb3e1ab56d3389f9f896524f0bf0ae92b224b2997f4e5f6014219a31cf",
    RuntimeHash =
      "94cb18393b87ef8409f231b2e62c507f43fb3294cdefeb0f3e8c19c8235e7753",
    ProductionAdapterPreflightReady = TRUE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE
  )
  c(identity, list(ReceiptHash = mfrmr_gta_hash(identity)))
}

mfrmr_gtwai_measurement_receipt <- function() {
  identity <- list(
    Contract = "nonreserved_resource_measurement_b1g15_v1",
    DryExecutionHash = mfrmr_gtwai_b1g14_receipt()$DryExecutionHash,
    ScenarioId = "GT-WI-baseline_complete-reference_1200",
    Replicate = 902L,
    DatasetCount = 1L,
    AtomicUnitCount = 4L,
    CandidateFitRowCount = 36L,
    CandidateDecisionRowCount = 192L,
    ReferenceRowCount = 8L,
    CheckpointBytes = c(2955, 2969, 3573, 3588),
    DatasetMarkerBytes = 671,
    CombinedLedgerObjectBytes = 124728,
    ElapsedSecondsByMethod = c(
      glmmTMB_ml = 22.810, glmmTMB_reml = 14.539,
      lme4_ml = 27.726, lme4_reml = 23.972
    ),
    MeasurementScope = "single_nonreserved_dataset_planning_only",
    RuntimeGuarantee = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    MeasurementHash = mfrmr_gta_hash(identity), MeasurementFrozen = TRUE
  )), class = "mfrmr_gtwai_measurement")
}

mfrmr_gtwai_measurement_hash_valid <- function(measurement) {
  if (!inherits(measurement, "mfrmr_gtwai_measurement") ||
      !isTRUE(measurement$MeasurementFrozen) ||
      is.null(measurement$MeasurementHash)) return(FALSE)
  identity <- unclass(measurement)
  identity$MeasurementHash <- NULL
  identity$MeasurementFrozen <- NULL
  identical(measurement$MeasurementHash, mfrmr_gta_hash(identity))
}

mfrmr_gtwai_contract <- function(adapter_contract, reserved_manifest) {
  mfrmr_gtwai_require_primitives()
  receipt <- mfrmr_gtwai_b1g14_receipt()
  if (!inherits(adapter_contract, "mfrmr_gtwah_contract") ||
      !identical(adapter_contract$ContractHash,
                 receipt$AdapterContractHash) ||
      !isTRUE(adapter_contract$ProductionEvaluatorAdaptersFrozen) ||
      isTRUE(adapter_contract$CalibrationExecutionAuthorized) ||
      !mfrmr_gtwah_reserved_manifest_hash_valid(reserved_manifest) ||
      !identical(reserved_manifest$ManifestHash,
                 receipt$ReservedManifestHash) ||
      isTRUE(reserved_manifest$ExecutionAuthorized) ||
      isTRUE(reserved_manifest$CalibrationDataGenerated) ||
      isTRUE(reserved_manifest$CalibrationResultsViewed)) {
    stop("The exact non-authorizing b1g14 artifacts are required.",
         call. = FALSE)
  }
  current_runtime <- mfrmr_gtwah_runtime_identity()
  if (!identical(current_runtime$RuntimeHash, receipt$RuntimeHash) ||
      !identical(current_runtime$RuntimeHash,
                 adapter_contract$Runtime$RuntimeHash)) {
    stop("The installed runtime no longer matches b1g14.", call. = FALSE)
  }
  policy <- mfrmr_gtwai_policy()
  measurement <- mfrmr_gtwai_measurement_receipt()
  identity <- list(
    Contract = "one_way_authorization_preflight_contract_b1g15_v1",
    UpstreamAdapterContractHash = adapter_contract$ContractHash,
    UpstreamReservedManifestHash = reserved_manifest$ManifestHash,
    UpstreamAdapterPreflightHash = receipt$AdapterPreflightHash,
    UpstreamDryExecutionHash = receipt$DryExecutionHash,
    UpstreamRuntimeHash = receipt$RuntimeHash,
    UpstreamSealedManifestHash =
      reserved_manifest$UpstreamSealedManifestHash,
    AdapterHashes = adapter_contract$AdapterHashes,
    AdapterDependencyHashes = adapter_contract$AdapterDependencyHashes,
    OutputRoot = reserved_manifest$OutputRoot,
    AuthorizationPolicy = policy,
    Measurement = measurement,
    Sources = mfrmr_gtwai_source_registry(),
    FunctionHashes = mfrmr_gtwai_function_hashes()
  )
  base <- unclass(adapter_contract)
  for (name in unique(c(
    names(identity), "Contract", "ContractHash",
    "AuthorizationPreflightContractFrozen",
    "ProspectiveShardManifestsFrozen", "FilesystemPreflightReady",
    "CapacityPreflightReady", "SchedulingPlanFrozen",
    "AuthorizationReadinessAuditReady", "AuthorizationActivationEligible",
    "ExecutionAuthorizationRecordIssued", "CalibrationAuthorizationReady",
    "CalibrationExecutionAuthorized", "CalibrationDataGenerated",
    "CalibrationResultsViewed", "StationarityThresholdFrozen",
    "StationarityCriterionReady", "ConfirmationAuthorized",
    "InferenceReady", "CoefficientEligible", "DecisionReady"
  ))) base[[name]] <- NULL
  structure(c(base, identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    AuthorizationPreflightContractFrozen = TRUE,
    ProspectiveShardManifestsFrozen = FALSE,
    FilesystemPreflightReady = FALSE,
    CapacityPreflightReady = FALSE,
    SchedulingPlanFrozen = FALSE,
    AuthorizationReadinessAuditReady = FALSE,
    AuthorizationActivationEligible = FALSE,
    ExecutionAuthorizationRecordIssued = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = c(
    "mfrmr_gtwai_contract", "mfrmr_gtwah_contract", "mfrmr_gtwag_contract"
  ))
}

mfrmr_gtwai_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "UpstreamAdapterContractHash",
    "UpstreamReservedManifestHash", "UpstreamAdapterPreflightHash",
    "UpstreamDryExecutionHash", "UpstreamRuntimeHash",
    "UpstreamSealedManifestHash", "AdapterHashes",
    "AdapterDependencyHashes", "OutputRoot", "AuthorizationPolicy",
    "Measurement", "Sources", "FunctionHashes"
  )
  inherits(contract, "mfrmr_gtwai_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwai_policy_hash_valid(contract$AuthorizationPolicy) &&
    mfrmr_gtwai_measurement_hash_valid(contract$Measurement) &&
    isTRUE(contract$AuthorizationPreflightContractFrozen) &&
    !isTRUE(contract$ExecutionAuthorizationRecordIssued) &&
    !isTRUE(contract$CalibrationAuthorizationReady) &&
    !isTRUE(contract$CalibrationExecutionAuthorized)
}

mfrmr_gtwai_shard_manifest <- function(contract, reserved_manifest,
                                         sealed_manifest, shard_id,
                                         sealed_units = NULL) {
  if (!mfrmr_gtwai_contract_hash_valid(contract) ||
      !mfrmr_gtwah_reserved_manifest_hash_valid(reserved_manifest) ||
      !inherits(sealed_manifest, "mfrmr_gtwaa_manifest") ||
      !mfrmr_gtwaa_manifest_hash_valid(sealed_manifest) ||
      !identical(sealed_manifest$ManifestHash,
                 contract$UpstreamSealedManifestHash) ||
      !identical(reserved_manifest$ManifestHash,
                 contract$UpstreamReservedManifestHash)) {
    stop("Exact b1g15, reserved, and sealed inputs are required.",
         call. = FALSE)
  }
  shard_id <- as.character(shard_id)
  if (length(shard_id) != 1L ||
      !shard_id %in% contract$AuthorizationPolicy$ShardOrder) {
    stop("One registered reserved shard is required.", call. = FALSE)
  }
  if (is.null(sealed_units)) {
    units <- mfrmr_gtwag_sealed_units(contract, sealed_manifest)
  } else {
    units <- sealed_units
    required <- c(
      "AtomicUnitId", "AtomicUnitIdentityHash", "DatasetId", "Replicate",
      "ExpectedCandidateFitRows", "ExpectedCandidateDecisionRows",
      "ExpectedReferenceRows", "ExecutionAuthorized"
    )
    if (!is.data.frame(units) || !all(required %in% names(units)) ||
        nrow(units) != reserved_manifest$AtomicUnitCount ||
        anyDuplicated(units$AtomicUnitId)) {
      stop("The prevalidated sealed-unit ledger is malformed.",
           call. = FALSE)
    }
  }
  assignment <- reserved_manifest$UnitAssignments
  assigned <- assignment[assignment$ShardId == shard_id, , drop = FALSE]
  index <- match(assigned$AtomicUnitId, units$AtomicUnitId)
  if (anyNA(index)) stop("A reserved shard assignment is missing.",
                         call. = FALSE)
  shard_units <- units[index, , drop = FALSE]
  if (!identical(shard_units$AtomicUnitIdentityHash,
                 assigned$AtomicUnitIdentityHash) ||
      any(shard_units$ExecutionAuthorized)) {
    stop("A reserved shard identity changed or became executable.",
         call. = FALSE)
  }
  replicate <- as.integer(sub("^R", "", shard_id))
  identity <- list(
    Contract = "prospective_stationarity_shard_manifest_b1g15_v1",
    AuthorizationPreflightContractHash = contract$ContractHash,
    AdapterContractHash = contract$UpstreamAdapterContractHash,
    ReservedManifestHash = reserved_manifest$ManifestHash,
    ShardId = shard_id,
    Replicate = replicate,
    Units = shard_units,
    CandidateEvaluatorHash =
      contract$AdapterHashes[["CandidateEvaluator"]],
    ReferenceEvaluatorHash =
      contract$AdapterHashes[["ReferenceEvaluator"]],
    OutputSubdirectory = file.path(
      contract$OutputRoot, "shards", shard_id
    ),
    ReservedCalibrationUse = TRUE,
    ConfirmationUse = FALSE,
    EarlyStoppingPermitted = FALSE
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    DatasetCount = length(unique(shard_units$DatasetId)),
    AtomicUnitCount = nrow(shard_units),
    CandidateFitRowCount = sum(shard_units$ExpectedCandidateFitRows),
    CandidateDecisionRowCount =
      sum(shard_units$ExpectedCandidateDecisionRows),
    ReferenceRowCount = sum(shard_units$ExpectedReferenceRows),
    ProspectiveManifestFrozen = TRUE,
    ExecutionAuthorized = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwai_shard_manifest")
}

mfrmr_gtwai_shard_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "AuthorizationPreflightContractHash",
    "AdapterContractHash", "ReservedManifestHash", "ShardId",
    "Replicate", "Units", "CandidateEvaluatorHash",
    "ReferenceEvaluatorHash", "OutputSubdirectory",
    "ReservedCalibrationUse", "ConfirmationUse",
    "EarlyStoppingPermitted"
  )
  inherits(manifest, "mfrmr_gtwai_shard_manifest") &&
    all(fields %in% names(manifest)) &&
    identical(manifest$ManifestHash, mfrmr_gta_hash(manifest[fields])) &&
    isTRUE(manifest$ProspectiveManifestFrozen) &&
    !isTRUE(manifest$ExecutionAuthorized) &&
    !isTRUE(manifest$CalibrationExecutionAuthorized) &&
    !isTRUE(manifest$CalibrationDataGenerated) &&
    !isTRUE(manifest$CalibrationResultsViewed) &&
    isTRUE(manifest$ReservedCalibrationUse) &&
    !isTRUE(manifest$ConfirmationUse) &&
    !isTRUE(manifest$EarlyStoppingPermitted) &&
    all(!manifest$Units$ExecutionAuthorized)
}

mfrmr_gtwai_shard_bundle <- function(contract, reserved_manifest,
                                       sealed_manifest) {
  sealed_units <- mfrmr_gtwag_sealed_units(contract, sealed_manifest)
  manifests <- lapply(contract$AuthorizationPolicy$ShardOrder,
                      function(shard_id) {
    mfrmr_gtwai_shard_manifest(
      contract, reserved_manifest, sealed_manifest, shard_id,
      sealed_units = sealed_units
    )
  })
  names(manifests) <- contract$AuthorizationPolicy$ShardOrder
  registry <- do.call(rbind, lapply(manifests, function(manifest) {
    data.frame(
      ShardId = manifest$ShardId,
      Replicate = manifest$Replicate,
      ManifestHash = manifest$ManifestHash,
      OutputSubdirectory = manifest$OutputSubdirectory,
      DatasetCount = manifest$DatasetCount,
      AtomicUnitCount = manifest$AtomicUnitCount,
      CandidateFitRowCount = manifest$CandidateFitRowCount,
      CandidateDecisionRowCount = manifest$CandidateDecisionRowCount,
      ReferenceRowCount = manifest$ReferenceRowCount,
      ExecutionAuthorized = manifest$ExecutionAuthorized,
      stringsAsFactors = FALSE
    )
  }))
  all_units <- do.call(rbind, lapply(manifests, `[[`, "Units"))
  assignment <- reserved_manifest$UnitAssignments
  exact <- nrow(registry) == contract$AuthorizationPolicy$ShardCount &&
    identical(registry$ShardId, contract$AuthorizationPolicy$ShardOrder) &&
    !anyDuplicated(registry$ManifestHash) &&
    !anyDuplicated(registry$OutputSubdirectory) &&
    all(registry$DatasetCount == 30L) &&
    all(registry$AtomicUnitCount ==
          contract$AuthorizationPolicy$AtomicUnitsPerShard) &&
    all(registry$CandidateFitRowCount ==
          contract$AuthorizationPolicy$CandidateFitsPerShard) &&
    all(registry$CandidateDecisionRowCount ==
          contract$AuthorizationPolicy$CandidateDecisionsPerShard) &&
    all(registry$ReferenceRowCount ==
          contract$AuthorizationPolicy$ReferencesPerShard) &&
    !any(registry$ExecutionAuthorized) &&
    nrow(all_units) == reserved_manifest$AtomicUnitCount &&
    !anyDuplicated(all_units$AtomicUnitId) &&
    setequal(all_units$AtomicUnitId, assignment$AtomicUnitId) &&
    identical(
      all_units$AtomicUnitIdentityHash[
        match(assignment$AtomicUnitId, all_units$AtomicUnitId)
      ],
      assignment$AtomicUnitIdentityHash
    )
  if (!exact) stop("The prospective shard bundle is not exact.",
                   call. = FALSE)
  identity <- list(
    Contract = "prospective_stationarity_shard_bundle_b1g15_v1",
    AuthorizationPreflightContractHash = contract$ContractHash,
    ReservedManifestHash = reserved_manifest$ManifestHash,
    Registry = registry,
    ManifestHashes = stats::setNames(
      registry$ManifestHash, registry$ShardId
    ),
    AtomicUnitIdentityHash = mfrmr_gta_hash(all_units[c(
      "AtomicUnitId", "AtomicUnitIdentityHash"
    )])
  )
  structure(c(identity, list(
    BundleHash = mfrmr_gta_hash(identity), Manifests = manifests,
    ShardCount = nrow(registry), DatasetCount =
      length(unique(all_units$DatasetId)),
    AtomicUnitCount = nrow(all_units),
    CandidateFitRowCount = sum(registry$CandidateFitRowCount),
    CandidateDecisionRowCount = sum(registry$CandidateDecisionRowCount),
    ReferenceRowCount = sum(registry$ReferenceRowCount),
    ProspectiveShardManifestsFrozen = TRUE,
    ExecutionAuthorized = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwai_shard_bundle")
}

mfrmr_gtwai_shard_bundle_hash_valid <- function(bundle) {
  fields <- c(
    "Contract", "AuthorizationPreflightContractHash",
    "ReservedManifestHash", "Registry", "ManifestHashes",
    "AtomicUnitIdentityHash"
  )
  manifest_hashes <- if (inherits(bundle, "mfrmr_gtwai_shard_bundle") &&
      is.list(bundle$Manifests)) {
    vapply(bundle$Manifests, `[[`, character(1L), "ManifestHash")
  } else character()
  registry_exact <- inherits(bundle, "mfrmr_gtwai_shard_bundle") &&
    is.data.frame(bundle$Registry) &&
    length(bundle$Manifests) == nrow(bundle$Registry) &&
    identical(unname(manifest_hashes),
              unname(bundle$Registry$ManifestHash)) &&
    identical(bundle$ShardCount, nrow(bundle$Registry)) &&
    identical(bundle$DatasetCount, sum(bundle$Registry$DatasetCount)) &&
    identical(bundle$AtomicUnitCount,
              sum(bundle$Registry$AtomicUnitCount)) &&
    identical(bundle$CandidateFitRowCount,
              sum(bundle$Registry$CandidateFitRowCount)) &&
    identical(bundle$CandidateDecisionRowCount,
              sum(bundle$Registry$CandidateDecisionRowCount)) &&
    identical(bundle$ReferenceRowCount,
              sum(bundle$Registry$ReferenceRowCount)) &&
    identical(bundle$ProspectiveShardManifestsFrozen, TRUE) &&
    identical(bundle$ExecutionAuthorized, FALSE) &&
    identical(bundle$CalibrationExecutionAuthorized, FALSE)
  inherits(bundle, "mfrmr_gtwai_shard_bundle") &&
    all(fields %in% names(bundle)) &&
    identical(bundle$BundleHash, mfrmr_gta_hash(bundle[fields])) &&
    length(bundle$Manifests) == bundle$ShardCount &&
    all(vapply(
      bundle$Manifests, mfrmr_gtwai_shard_manifest_hash_valid,
      logical(1L)
    )) &&
    identical(unname(manifest_hashes), unname(bundle$ManifestHashes)) &&
    registry_exact &&
    !isTRUE(bundle$ExecutionAuthorized) &&
    !isTRUE(bundle$CalibrationExecutionAuthorized)
}

mfrmr_gtwai_parse_df <- function(output) {
  output <- as.character(output)
  output <- output[nzchar(trimws(output))]
  if (length(output) < 2L) {
    stop("`df -Pk` did not return a header and data row.", call. = FALSE)
  }
  tokens <- strsplit(trimws(tail(output, 1L)), "[[:space:]]+")[[1L]]
  if (length(tokens) < 6L) {
    stop("The `df -Pk` data row is malformed.", call. = FALSE)
  }
  numeric_tokens <- suppressWarnings(as.numeric(tokens[2:4]))
  if (anyNA(numeric_tokens) || any(numeric_tokens < 0)) {
    stop("The `df -Pk` capacity fields are invalid.", call. = FALSE)
  }
  list(
    Filesystem = tokens[[1L]], BlocksKiB = numeric_tokens[[1L]],
    UsedKiB = numeric_tokens[[2L]], AvailableKiB = numeric_tokens[[3L]],
    Capacity = tokens[[5L]], MountPoint = paste(tokens[6:length(tokens)],
                                                collapse = " ")
  )
}

mfrmr_gtwai_filesystem_probe <- function(contract, reserved_manifest,
                                           project_root,
                                           require_package_root = TRUE) {
  if (!mfrmr_gtwai_contract_hash_valid(contract) ||
      !mfrmr_gtwah_reserved_manifest_hash_valid(reserved_manifest) ||
      !identical(reserved_manifest$ManifestHash,
                 contract$UpstreamReservedManifestHash)) {
    stop("Exact b1g15 and reserved-manifest inputs are required.",
         call. = FALSE)
  }
  project_root <- as.character(project_root)
  if (length(project_root) != 1L || is.na(project_root) ||
      !dir.exists(project_root)) {
    stop("One existing project root is required.", call. = FALSE)
  }
  project_root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  if (project_root %in% c("/", normalizePath(path.expand("~"),
                                              winslash = "/",
                                              mustWork = TRUE))) {
    stop("A filesystem root or home directory cannot be probed.",
         call. = FALSE)
  }
  if (isTRUE(require_package_root) &&
      !all(file.exists(file.path(project_root, c(
        "DESCRIPTION", "inst/validation/release-gate-spec-0.2.3.md"
      ))))) {
    stop("The requested path is not the mfrmr package root.", call. = FALSE)
  }
  output_root <- reserved_manifest$OutputRoot
  components <- strsplit(output_root, "[/\\\\]")[[1L]]
  if (length(output_root) != 1L || is.na(output_root) ||
      !nzchar(output_root) || grepl("^[/\\\\]", output_root) ||
      any(components %in% c("", ".", ".."))) {
    stop("The reserved output root is not a safe relative path.",
         call. = FALSE)
  }
  target <- file.path(project_root, output_root)
  parent <- dirname(target)
  parent_ready <- dir.exists(parent) &&
    startsWith(
      paste0(normalizePath(parent, winslash = "/", mustWork = TRUE), "/"),
      paste0(project_root, "/")
    )
  if (!parent_ready) {
    stop("The reserved output parent is absent or outside the project.",
         call. = FALSE)
  }
  target_absent <- !file.exists(target) && !dir.exists(target)
  advisory_writable <- identical(unname(file.access(parent, 2L)), 0L)
  probe <- tempfile(".mfrmr-gtwai-", tmpdir = parent)
  created <- dir.create(probe, recursive = FALSE, showWarnings = FALSE)
  on.exit(if (dir.exists(probe)) unlink(probe, recursive = TRUE,
                                        force = TRUE), add = TRUE)
  source <- file.path(probe, "probe-source.rds")
  destination <- file.path(probe, "probe-installed.rds")
  sentinel <- list(
    Contract = "b1g15_filesystem_probe_v1",
    ReservedManifestHash = reserved_manifest$ManifestHash,
    Payload = seq_len(32L)
  )
  write_passed <- FALSE
  rename_passed <- FALSE
  readback_passed <- FALSE
  probe_bytes <- NA_real_
  if (created) {
    write_passed <- isTRUE(tryCatch({
      saveRDS(sentinel, source, version = 3L)
      file.exists(source)
    }, error = function(error) FALSE))
    if (write_passed) {
      rename_passed <- isTRUE(file.rename(source, destination))
    }
    if (rename_passed) {
      readback_passed <- isTRUE(tryCatch(
        identical(readRDS(destination), sentinel),
        error = function(error) FALSE
      ))
      probe_bytes <- unname(file.info(destination)$size)
    }
  }
  df_executable <- unname(Sys.which("df"))
  df_output <- character()
  df_status <- 127L
  parsed <- NULL
  if (nzchar(df_executable)) {
    df_output <- suppressWarnings(system2(
      df_executable, c("-Pk", shQuote(parent)),
      stdout = TRUE, stderr = TRUE
    ))
    status <- attr(df_output, "status")
    df_status <- if (is.null(status)) 0L else as.integer(status)
    if (identical(df_status, 0L)) {
      parsed <- tryCatch(mfrmr_gtwai_parse_df(df_output),
                         error = function(error) NULL)
    }
  }
  if (dir.exists(probe)) unlink(probe, recursive = TRUE, force = TRUE)
  cleanup_passed <- !file.exists(probe) && !dir.exists(probe)
  available_bytes <- if (is.null(parsed)) NA_real_ else
    parsed$AvailableKiB * 1024
  identity <- list(
    Contract = "output_filesystem_probe_b1g15_v1",
    AuthorizationPreflightContractHash = contract$ContractHash,
    ReservedManifestHash = reserved_manifest$ManifestHash,
    ProjectRoot = project_root,
    OutputRoot = output_root,
    OutputTargetHash = mfrmr_gta_hash(normalizePath(
      parent, winslash = "/", mustWork = TRUE
    ) |> file.path(basename(target))),
    OutputTargetAbsentBeforeProbe = target_absent,
    OutputParentExists = dir.exists(parent),
    ParentFileAccessWritable = advisory_writable,
    ProbeDirectoryCreated = created,
    ActualWritePassed = write_passed,
    SameDirectoryRename = identical(dirname(source), dirname(destination)),
    AtomicRenamePassed = rename_passed,
    ReadbackPassed = readback_passed,
    ProbeFileBytes = probe_bytes,
    ProbeCleanupPassed = cleanup_passed,
    DfExecutable = df_executable,
    DfExitStatus = df_status,
    DfOutputHash = mfrmr_gta_hash(df_output),
    Filesystem = if (is.null(parsed)) "unavailable" else parsed$Filesystem,
    MountPoint = if (is.null(parsed)) "unavailable" else parsed$MountPoint,
    AvailableBytes = available_bytes,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  ready <- target_absent && created && write_passed && rename_passed &&
    readback_passed && cleanup_passed && identical(df_status, 0L) &&
    is.finite(available_bytes) && available_bytes > 0
  structure(c(identity, list(
    ProbeHash = mfrmr_gta_hash(identity),
    FilesystemProbeReady = ready,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwai_filesystem_probe")
}

mfrmr_gtwai_filesystem_probe_hash_valid <- function(probe) {
  fields <- c(
    "Contract", "AuthorizationPreflightContractHash",
    "ReservedManifestHash", "ProjectRoot", "OutputRoot",
    "OutputTargetHash", "OutputTargetAbsentBeforeProbe",
    "OutputParentExists", "ParentFileAccessWritable",
    "ProbeDirectoryCreated", "ActualWritePassed", "SameDirectoryRename",
    "AtomicRenamePassed", "ReadbackPassed", "ProbeFileBytes",
    "ProbeCleanupPassed", "DfExecutable", "DfExitStatus",
    "DfOutputHash", "Filesystem", "MountPoint", "AvailableBytes",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  ready <- inherits(probe, "mfrmr_gtwai_filesystem_probe") &&
    isTRUE(probe$OutputTargetAbsentBeforeProbe) &&
    isTRUE(probe$ProbeDirectoryCreated) &&
    isTRUE(probe$ActualWritePassed) &&
    isTRUE(probe$SameDirectoryRename) &&
    isTRUE(probe$AtomicRenamePassed) &&
    isTRUE(probe$ReadbackPassed) &&
    isTRUE(probe$ProbeCleanupPassed) &&
    identical(probe$DfExitStatus, 0L) &&
    is.finite(probe$AvailableBytes) && probe$AvailableBytes > 0
  inherits(probe, "mfrmr_gtwai_filesystem_probe") &&
    all(fields %in% names(probe)) &&
    identical(probe$ProbeHash, mfrmr_gta_hash(probe[fields])) &&
    identical(probe$FilesystemProbeReady, ready) &&
    !isTRUE(probe$CalibrationExecutionAuthorized) &&
    !isTRUE(probe$CalibrationDataGenerated) &&
    !isTRUE(probe$CalibrationResultsViewed)
}

mfrmr_gtwai_resource_projection <- function(contract, filesystem_probe) {
  if (!mfrmr_gtwai_contract_hash_valid(contract) ||
      !mfrmr_gtwai_filesystem_probe_hash_valid(filesystem_probe)) {
    stop("Exact b1g15 contract and filesystem probe are required.",
         call. = FALSE)
  }
  measurement <- contract$Measurement
  if (!mfrmr_gtwai_measurement_hash_valid(measurement)) {
    stop("The frozen nonreserved measurement is invalid.", call. = FALSE)
  }
  max_checkpoint <- max(measurement$CheckpointBytes)
  base_checkpoint <- max_checkpoint * 12000
  base_marker <- measurement$DatasetMarkerBytes * 3000
  base_ledger <- measurement$CombinedLedgerObjectBytes * 3000
  raw_disk <- base_checkpoint + base_marker + base_ledger
  safety_disk <- ceiling(
    raw_disk * contract$AuthorizationPolicy$DiskSafetyMultiplier
  )
  required_available <- safety_disk +
    contract$AuthorizationPolicy$MinimumResidualFreeBytes
  observed_serial_seconds <-
    sum(measurement$ElapsedSecondsByMethod) * 3000
  planning_serial_hours <- observed_serial_seconds *
    contract$AuthorizationPolicy$RuntimePlanningMultiplier / 3600
  planning_shard_hours <- sum(measurement$ElapsedSecondsByMethod) * 30 *
    contract$AuthorizationPolicy$RuntimePlanningMultiplier / 3600
  identity <- list(
    Contract = "resource_projection_b1g15_v1",
    AuthorizationPreflightContractHash = contract$ContractHash,
    MeasurementHash = measurement$MeasurementHash,
    FilesystemProbeHash = filesystem_probe$ProbeHash,
    MaximumObservedCheckpointBytes = max_checkpoint,
    ObservedDatasetMarkerBytes = measurement$DatasetMarkerBytes,
    ObservedCombinedLedgerObjectBytes =
      measurement$CombinedLedgerObjectBytes,
    RawProjectedDiskBytes = raw_disk,
    DiskSafetyMultiplier =
      contract$AuthorizationPolicy$DiskSafetyMultiplier,
    SafetyProjectedDiskBytes = safety_disk,
    MinimumResidualFreeBytes =
      contract$AuthorizationPolicy$MinimumResidualFreeBytes,
    RequiredAvailableBytes = required_available,
    ObservedAvailableBytes = filesystem_probe$AvailableBytes,
    ObservedSerialHours = observed_serial_seconds / 3600,
    RuntimePlanningMultiplier =
      contract$AuthorizationPolicy$RuntimePlanningMultiplier,
    PlanningSerialHours = planning_serial_hours,
    PlanningShardHours = planning_shard_hours,
    MaximumPlanningSerialHours =
      contract$AuthorizationPolicy$MaximumPlanningSerialHours,
    MaximumPlanningShardHours =
      contract$AuthorizationPolicy$MaximumPlanningShardHours,
    MaxConcurrentShards = contract$AuthorizationPolicy$MaxConcurrentShards,
    RuntimeGuarantee = FALSE
  )
  capacity_ready <- is.finite(filesystem_probe$AvailableBytes) &&
    filesystem_probe$AvailableBytes >= required_available
  scheduling_ready <- planning_serial_hours <=
      contract$AuthorizationPolicy$MaximumPlanningSerialHours &&
    planning_shard_hours <=
      contract$AuthorizationPolicy$MaximumPlanningShardHours &&
    identical(contract$AuthorizationPolicy$MaxConcurrentShards, 1L)
  structure(c(identity, list(
    ProjectionHash = mfrmr_gta_hash(identity),
    CapacityPreflightReady = capacity_ready,
    SchedulingPlanFrozen = scheduling_ready,
    ResourceProjectionReady = capacity_ready && scheduling_ready,
    CalibrationExecutionAuthorized = FALSE
  )), class = "mfrmr_gtwai_resource_projection")
}

mfrmr_gtwai_resource_projection_hash_valid <- function(projection) {
  fields <- c(
    "Contract", "AuthorizationPreflightContractHash", "MeasurementHash",
    "FilesystemProbeHash", "MaximumObservedCheckpointBytes",
    "ObservedDatasetMarkerBytes", "ObservedCombinedLedgerObjectBytes",
    "RawProjectedDiskBytes", "DiskSafetyMultiplier",
    "SafetyProjectedDiskBytes", "MinimumResidualFreeBytes",
    "RequiredAvailableBytes", "ObservedAvailableBytes",
    "ObservedSerialHours", "RuntimePlanningMultiplier",
    "PlanningSerialHours", "PlanningShardHours",
    "MaximumPlanningSerialHours", "MaximumPlanningShardHours",
    "MaxConcurrentShards", "RuntimeGuarantee"
  )
  capacity_ready <- inherits(projection, "mfrmr_gtwai_resource_projection") &&
    is.finite(projection$ObservedAvailableBytes) &&
    projection$ObservedAvailableBytes >= projection$RequiredAvailableBytes
  scheduling_ready <- inherits(
    projection, "mfrmr_gtwai_resource_projection"
  ) && projection$PlanningSerialHours <=
      projection$MaximumPlanningSerialHours &&
    projection$PlanningShardHours <= projection$MaximumPlanningShardHours &&
    identical(projection$MaxConcurrentShards, 1L)
  inherits(projection, "mfrmr_gtwai_resource_projection") &&
    all(fields %in% names(projection)) &&
    identical(projection$ProjectionHash,
              mfrmr_gta_hash(projection[fields])) &&
    identical(projection$CapacityPreflightReady, capacity_ready) &&
    identical(projection$SchedulingPlanFrozen, scheduling_ready) &&
    identical(projection$ResourceProjectionReady,
              capacity_ready && scheduling_ready) &&
    !isTRUE(projection$CalibrationExecutionAuthorized)
}

mfrmr_gtwai_audit <- function(contract, reserved_manifest, shard_bundle,
                                filesystem_probe) {
  if (!mfrmr_gtwai_contract_hash_valid(contract) ||
      !mfrmr_gtwah_reserved_manifest_hash_valid(reserved_manifest) ||
      !mfrmr_gtwai_shard_bundle_hash_valid(shard_bundle) ||
      !mfrmr_gtwai_filesystem_probe_hash_valid(filesystem_probe) ||
      !identical(reserved_manifest$ManifestHash,
                 contract$UpstreamReservedManifestHash) ||
      !identical(shard_bundle$AuthorizationPreflightContractHash,
                 contract$ContractHash) ||
      !identical(filesystem_probe$AuthorizationPreflightContractHash,
                 contract$ContractHash)) {
    stop("Exact b1g15 audit inputs are required.", call. = FALSE)
  }
  projection <- mfrmr_gtwai_resource_projection(contract, filesystem_probe)
  runtime_match <- identical(
    mfrmr_gtwah_runtime_identity()$RuntimeHash,
    contract$UpstreamRuntimeHash
  )
  counts <- c(
    Shards = shard_bundle$ShardCount,
    Datasets = shard_bundle$DatasetCount,
    AtomicUnits = shard_bundle$AtomicUnitCount,
    CandidateFits = shard_bundle$CandidateFitRowCount,
    CandidateDecisions = shard_bundle$CandidateDecisionRowCount,
    References = shard_bundle$ReferenceRowCount
  )
  expected <- c(
    Shards = 100L, Datasets = 3000L, AtomicUnits = 12000L,
    CandidateFits = 108000L, CandidateDecisions = 576000L,
    References = 24000L
  )
  firewall <- !isTRUE(reserved_manifest$ExecutionAuthorized) &&
    !isTRUE(shard_bundle$ExecutionAuthorized) &&
    all(!shard_bundle$Registry$ExecutionAuthorized) &&
    all(vapply(shard_bundle$Manifests, function(manifest) {
      !isTRUE(manifest$ExecutionAuthorized) &&
        !isTRUE(manifest$CalibrationExecutionAuthorized) &&
        !isTRUE(manifest$CalibrationDataGenerated) &&
        !isTRUE(manifest$CalibrationResultsViewed) &&
        !isTRUE(manifest$ConfirmationUse) &&
        !isTRUE(manifest$EarlyStoppingPermitted)
    }, logical(1L)))
  ready <- identical(counts, expected) && runtime_match && firewall &&
    isTRUE(shard_bundle$ProspectiveShardManifestsFrozen) &&
    isTRUE(filesystem_probe$FilesystemProbeReady) &&
    isTRUE(projection$ResourceProjectionReady)
  identity <- list(
    Contract = "one_way_authorization_readiness_audit_b1g15_v1",
    AuthorizationPreflightContractHash = contract$ContractHash,
    ReservedManifestHash = reserved_manifest$ManifestHash,
    ShardBundleHash = shard_bundle$BundleHash,
    FilesystemProbeHash = filesystem_probe$ProbeHash,
    ResourceProjectionHash = projection$ProjectionHash,
    RuntimeHashMatch = runtime_match,
    ExactCounts = counts,
    AuthorizationFirewallIntact = firewall,
    OutputTargetAbsentBeforeActivation =
      filesystem_probe$OutputTargetAbsentBeforeProbe,
    FilesystemProbeReady = filesystem_probe$FilesystemProbeReady,
    ResourceProjectionReady = projection$ResourceProjectionReady,
    EarlyStoppingPermitted = FALSE,
    ConfirmationAccessPermitted = FALSE
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    ResourceProjection = projection,
    ProspectiveShardManifestsFrozen = TRUE,
    FilesystemPreflightReady = filesystem_probe$FilesystemProbeReady,
    CapacityPreflightReady = projection$CapacityPreflightReady,
    SchedulingPlanFrozen = projection$SchedulingPlanFrozen,
    AuthorizationReadinessAuditReady = ready,
    AuthorizationActivationEligible = ready,
    ExecutionAuthorizationRecordIssued = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwai_audit")
}

mfrmr_gtwai_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "AuthorizationPreflightContractHash",
    "ReservedManifestHash", "ShardBundleHash", "FilesystemProbeHash",
    "ResourceProjectionHash", "RuntimeHashMatch", "ExactCounts",
    "AuthorizationFirewallIntact", "OutputTargetAbsentBeforeActivation",
    "FilesystemProbeReady", "ResourceProjectionReady",
    "EarlyStoppingPermitted", "ConfirmationAccessPermitted"
  )
  expected_counts <- c(
    Shards = 100L, Datasets = 3000L, AtomicUnits = 12000L,
    CandidateFits = 108000L, CandidateDecisions = 576000L,
    References = 24000L
  )
  ready <- inherits(audit, "mfrmr_gtwai_audit") &&
    isTRUE(audit$RuntimeHashMatch) &&
    identical(audit$ExactCounts, expected_counts) &&
    isTRUE(audit$AuthorizationFirewallIntact) &&
    isTRUE(audit$OutputTargetAbsentBeforeActivation) &&
    isTRUE(audit$FilesystemProbeReady) &&
    isTRUE(audit$ResourceProjectionReady) &&
    !isTRUE(audit$EarlyStoppingPermitted) &&
    !isTRUE(audit$ConfirmationAccessPermitted)
  inherits(audit, "mfrmr_gtwai_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    mfrmr_gtwai_resource_projection_hash_valid(audit$ResourceProjection) &&
    identical(audit$AuthorizationReadinessAuditReady, ready) &&
    identical(audit$AuthorizationActivationEligible, ready) &&
    !isTRUE(audit$ExecutionAuthorizationRecordIssued) &&
    !isTRUE(audit$CalibrationAuthorizationReady) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed)
}

mfrmr_gtwai_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwai_policy", "mfrmr_gtwai_policy_hash_valid",
    "mfrmr_gtwai_source_registry", "mfrmr_gtwai_b1g14_receipt",
    "mfrmr_gtwai_measurement_receipt",
    "mfrmr_gtwai_measurement_hash_valid", "mfrmr_gtwai_contract",
    "mfrmr_gtwai_contract_hash_valid",
    "mfrmr_gtwai_shard_manifest",
    "mfrmr_gtwai_shard_manifest_hash_valid",
    "mfrmr_gtwai_shard_bundle", "mfrmr_gtwai_shard_bundle_hash_valid",
    "mfrmr_gtwai_parse_df", "mfrmr_gtwai_filesystem_probe",
    "mfrmr_gtwai_filesystem_probe_hash_valid",
    "mfrmr_gtwai_resource_projection",
    "mfrmr_gtwai_resource_projection_hash_valid", "mfrmr_gtwai_audit",
    "mfrmr_gtwai_audit_hash_valid"
  )
  preflight_environment <- environment(mfrmr_gtwai_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwai_function_hash(get(
      name, envir = preflight_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
