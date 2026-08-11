# Draft.83d2b2b1g19 response-free hardened reserved-lineage rebase.
#
# Repository-internal only. This file rebuilds prospective identities for the
# reserved calibration assignment. It cannot generate responses, fit models,
# create an output root, or authorize execution.

mfrmr_gtwan_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwaa_manifest_hash_valid",
    "mfrmr_gtwag_sealed_units", "mfrmr_gtwah_reserved_manifest_hash_valid",
    "mfrmr_gtwam_adapter_hashes", "mfrmr_gtwam_dependency_hashes"
  )
  audit_environment <- environment(mfrmr_gtwan_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g18 chain before the b1g19 lineage rebase: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwan_parent_receipt <- function() {
  identity <- list(
    Contract = "hardened_adapter_evidence_receipt_b1g19_v1",
    HardenedAdapterContractHash =
      "0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64",
    HardenedGeneratorContractHash =
      "90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2",
    HardenedGeneratorAuditHash =
      "918e7da5e0ba484bbdef4251965c25ff31c5d4a39be237c3d218ed47fceae397",
    HardenedDryManifestHash =
      "090b761a835098b037b3f65021ebe22eeae9df822628df6898685b1f84e99d15",
    ParentExecutionHash =
      "b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae",
    HardenedExecutionHash =
      "14a44a4382e50ba2819d57072288bd213789935d4ed6d78fba674a8081b62aeb",
    HardenedAdapterAuditHash =
      "1e8461eca060b00215240d65c506873d6f082f66b6216fb1ff30761df7dfdb63",
    AdapterHashes = c(
      CandidateEvaluator =
        "94713fabb2ba12301984912560ac8017d6d22c2c3d66525c67016326ff1ab7c9",
      ReferenceEvaluator =
        "91770297261211cdca1eb9ad760e5ebc7b726a9bdb2730af9d3dd4633940e6db"
    ),
    AdapterDependencyHashes = c(
      prepare_unit =
        "b29dc10cbc2e63628222579de2b248da43653cbe47d6ed92450548933a93a4e7",
      hardened_generate =
        "428c98d225abc51e13b8e07e625d242d3a94c1e2a2d54e34f98b429b00785612",
      generation_validator =
        "418f3ff0be16c6155ad053a04f31f7f9a431fe2053962f485278e1158b44639b",
      lme4_fit =
        "ac3b6cc668aa0d2d1c6e93a3ca0c8017f53cb750f4d7bc092d7b3a0a87aa4ff4",
      glmmtmb_fit =
        "f3ae19ca1fef497ac829d3c42ea86adbafd3dc28d9da9fb7dcb4a0313394f50a",
      glmmtmb_reference =
        "94f4603f16d1135948d8be3623df80c076b80da340ff757b230b4d95da0880df",
      lme4_reference =
        "525f87c1e4cd96ba3ac17c53a470e00fc57b4d0e897f1ee0e69c66d907ab0e21"
    ),
    NonreservedAdapterRebaseReady = TRUE,
    ReservedManifestRebaseDeferred = TRUE,
    ReservedAdapterEntryPointReady = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    ReceiptHash = mfrmr_gta_hash(identity), EvidenceReceiptFrozen = TRUE
  )), class = "mfrmr_gtwan_parent_receipt")
}

mfrmr_gtwan_parent_receipt_hash_valid <- function(receipt) {
  expected <- mfrmr_gtwan_parent_receipt()
  fields <- setdiff(names(expected), c("ReceiptHash", "EvidenceReceiptFrozen"))
  inherits(receipt, "mfrmr_gtwan_parent_receipt") &&
    all(fields %in% names(receipt)) &&
    identical(receipt$ReceiptHash, mfrmr_gta_hash(receipt[fields])) &&
    identical(receipt$ReceiptHash, expected$ReceiptHash) &&
    identical(receipt[fields], expected[fields]) &&
    isTRUE(receipt$EvidenceReceiptFrozen) &&
    isTRUE(receipt$NonreservedAdapterRebaseReady) &&
    isTRUE(receipt$ReservedManifestRebaseDeferred) &&
    !isTRUE(receipt$ReservedAdapterEntryPointReady) &&
    !isTRUE(receipt$CalibrationResponsesUsed) &&
    !isTRUE(receipt$ConfirmationResponsesUsed)
}

mfrmr_gtwan_policy <- function() {
  identity <- list(
    Contract = "hardened_reserved_lineage_policy_b1g19_v1",
    HistoricalAdapterContractHash =
      "baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1",
    HistoricalReservedManifestHash =
      "019fedf063ce90c3492f9eb37f6dbec43a42474ce9096e7cc2891491d7a158c8",
    SealedCalibrationManifestHash =
      "7cce9d42faccfbbdf928c9ec4978fef25c50aa562750141fbab45a53b75885f8",
    HardenedAdapterContractHash =
      "0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64",
    HardenedGeneratorContractHash =
      "90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2",
    OutputRoot =
      "validation-results/gtheory-stationarity-calibration-draft83d2b2b1g19",
    ReservedReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    ShardOrder = sprintf("R%04d", 201:300),
    RequiredMethodIds = c(
      "glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml"
    ),
    ScenarioCount = 30L, MethodsPerDataset = 4L,
    DatasetCount = 3000L, AtomicUnitCount = 12000L,
    CandidateFitRowCount = 108000L,
    CandidateDecisionRowCount = 576000L,
    ReferenceRowCount = 24000L, ShardCount = 100L,
    DatasetsPerShard = 30L, AtomicUnitsPerShard = 120L,
    CandidateFitsPerShard = 1080L,
    CandidateDecisionsPerShard = 5760L,
    ReferencesPerShard = 240L,
    HistoricalLineageRetainedAsProvenanceOnly = TRUE,
    ActiveIdentityMustExcludeHistoricalScientificHashes = TRUE,
    ResponseGenerationPermitted = FALSE,
    ModelFittingPermitted = FALSE,
    OutputRootCreationPermitted = FALSE,
    EarlyStoppingPermitted = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    ConfirmationUse = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwan_policy")
}

mfrmr_gtwan_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwan_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity)) &&
    identical(policy$Contract, "hardened_reserved_lineage_policy_b1g19_v1") &&
    identical(policy$ReservedReplicates, 201:300) &&
    identical(policy$ConfirmationReplicates, 501:700) &&
    identical(policy$ShardOrder, sprintf("R%04d", 201:300)) &&
    identical(policy$ShardCount, 100L) &&
    isTRUE(policy$HistoricalLineageRetainedAsProvenanceOnly) &&
    isTRUE(policy$ActiveIdentityMustExcludeHistoricalScientificHashes) &&
    !isTRUE(policy$ResponseGenerationPermitted) &&
    !isTRUE(policy$ModelFittingPermitted) &&
    !isTRUE(policy$OutputRootCreationPermitted) &&
    !isTRUE(policy$EarlyStoppingPermitted) &&
    !isTRUE(policy$CalibrationExecutionAuthorized) &&
    !isTRUE(policy$ConfirmationUse)
}

mfrmr_gtwan_contract <- function(historical_adapter_contract,
                                  historical_reserved_manifest,
                                  sealed_manifest,
                                  parent_receipt =
                                    mfrmr_gtwan_parent_receipt()) {
  mfrmr_gtwan_require_primitives()
  policy <- mfrmr_gtwan_policy()
  if (!inherits(historical_adapter_contract, "mfrmr_gtwah_contract") ||
      !identical(historical_adapter_contract$ContractHash,
                 policy$HistoricalAdapterContractHash) ||
      !mfrmr_gtwah_reserved_manifest_hash_valid(
        historical_reserved_manifest
      ) ||
      !identical(historical_reserved_manifest$ManifestHash,
                 policy$HistoricalReservedManifestHash) ||
      !inherits(sealed_manifest, "mfrmr_gtwaa_manifest") ||
      !mfrmr_gtwaa_manifest_hash_valid(sealed_manifest) ||
      !identical(sealed_manifest$ManifestHash,
                 policy$SealedCalibrationManifestHash) ||
      !mfrmr_gtwan_parent_receipt_hash_valid(parent_receipt)) {
    stop("Exact non-authorizing b1g7, b1g14, and b1g18 evidence is required.",
         call. = FALSE)
  }
  adapter_hashes <- mfrmr_gtwam_adapter_hashes()
  dependency_hashes <- mfrmr_gtwam_dependency_hashes()
  if (!identical(adapter_hashes, parent_receipt$AdapterHashes) ||
      !identical(dependency_hashes,
                 parent_receipt$AdapterDependencyHashes)) {
    stop("The current hardened adapter implementation changed.",
         call. = FALSE)
  }
  historical_registry <- list(
    AdapterContractHash = historical_adapter_contract$ContractHash,
    ReservedManifestHash = historical_reserved_manifest$ManifestHash,
    AdapterHashes = historical_reserved_manifest$AdapterHashes,
    AdapterDependencyHashes =
      historical_reserved_manifest$AdapterDependencyHashes,
    AtomicUnitIdentityHashes =
      historical_reserved_manifest$UnitAssignments$AtomicUnitIdentityHash,
    ShardIdentityHashes = historical_reserved_manifest$Shards$ShardIdentityHash
  )
  identity <- list(
    Contract = "hardened_reserved_lineage_contract_b1g19_v1",
    LineagePolicy = policy,
    ParentEvidenceReceiptHash = parent_receipt$ReceiptHash,
    HistoricalAdapterContractHash = historical_adapter_contract$ContractHash,
    HistoricalReservedManifestHash = historical_reserved_manifest$ManifestHash,
    SealedCalibrationManifestHash = sealed_manifest$ManifestHash,
    HardenedAdapterContractHash = parent_receipt$HardenedAdapterContractHash,
    HardenedGeneratorContractHash =
      parent_receipt$HardenedGeneratorContractHash,
    AdapterHashes = adapter_hashes,
    AdapterDependencyHashes = dependency_hashes,
    InheritedRuntimeHash = historical_adapter_contract$Runtime$RuntimeHash,
    HistoricalIdentityRegistryHash = mfrmr_gta_hash(historical_registry)
  )
  base <- unclass(historical_adapter_contract)
  for (name in unique(c(
    names(identity), "Contract", "ContractHash", "AdapterHashes",
    "AdapterDependencyHashes", "ReservedRunManifestFrozen",
    "ReservedManifestRebaseReady", "ReservedAdapterEntryPointReady",
    "AuthorizationRNG01Closed", "CalibrationAuthorizationReady",
    "CalibrationExecutionAuthorized", "CalibrationDataGenerated",
    "CalibrationResultsViewed", "ConfirmationAuthorized", "InferenceReady",
    "CoefficientEligible", "DecisionReady"
  ))) base[[name]] <- NULL
  structure(c(base, identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    HardenedReservedLineageContractFrozen = TRUE,
    HistoricalEvidencePreserved = TRUE,
    ResponseFreeConstruction = TRUE,
    ReservedRunManifestFrozen = FALSE,
    ReservedManifestRebaseReady = FALSE,
    ReservedAdapterEntryPointReady = FALSE,
    RuntimeContractExtensionReady = FALSE,
    AuthorizedSingleShardRunnerReady = FALSE,
    AuthorizationRNG01Closed = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = c(
    "mfrmr_gtwan_contract", "mfrmr_gtwag_contract"
  ))
}

mfrmr_gtwan_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "LineagePolicy", "ParentEvidenceReceiptHash",
    "HistoricalAdapterContractHash", "HistoricalReservedManifestHash",
    "SealedCalibrationManifestHash", "HardenedAdapterContractHash",
    "HardenedGeneratorContractHash", "AdapterHashes",
    "AdapterDependencyHashes", "InheritedRuntimeHash",
    "HistoricalIdentityRegistryHash"
  )
  inherits(contract, "mfrmr_gtwan_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwan_policy_hash_valid(contract$LineagePolicy) &&
    identical(contract$AdapterHashes, mfrmr_gtwam_adapter_hashes()) &&
    identical(contract$AdapterDependencyHashes,
              mfrmr_gtwam_dependency_hashes()) &&
    isTRUE(contract$HardenedReservedLineageContractFrozen) &&
    isTRUE(contract$HistoricalEvidencePreserved) &&
    isTRUE(contract$ResponseFreeConstruction) &&
    !isTRUE(contract$ReservedRunManifestFrozen) &&
    !isTRUE(contract$ReservedManifestRebaseReady) &&
    !isTRUE(contract$ReservedAdapterEntryPointReady) &&
    !isTRUE(contract$RuntimeContractExtensionReady) &&
    !isTRUE(contract$AuthorizedSingleShardRunnerReady) &&
    !isTRUE(contract$AuthorizationRNG01Closed) &&
    !isTRUE(contract$CalibrationExecutionAuthorized) &&
    !isTRUE(contract$ConfirmationAuthorized) &&
    !isTRUE(contract$InferenceReady) && !isTRUE(contract$DecisionReady)
}

mfrmr_gtwan_units <- function(contract, sealed_manifest) {
  if (!mfrmr_gtwan_contract_hash_valid(contract) ||
      !inherits(sealed_manifest, "mfrmr_gtwaa_manifest") ||
      !mfrmr_gtwaa_manifest_hash_valid(sealed_manifest) ||
      !identical(sealed_manifest$ManifestHash,
                 contract$SealedCalibrationManifestHash)) {
    stop("The exact b1g19 contract and sealed manifest are required.",
         call. = FALSE)
  }
  units <- mfrmr_gtwag_sealed_units(contract, sealed_manifest)
  units$HistoricalAtomicUnitIdentityHash <- units$AtomicUnitIdentityHash
  units$AtomicUnitIdentityHash <- NULL
  units$HardenedAdapterContractHash <- contract$HardenedAdapterContractHash
  units$HardenedGeneratorContractHash <- contract$HardenedGeneratorContractHash
  units$LineagePolicyHash <- contract$LineagePolicy$PolicyHash
  units$ResponseGenerated <- FALSE
  units$PreFitComputed <- FALSE
  units$CheckpointCreated <- FALSE
  units$AtomicUnitIdentityHash <- vapply(seq_len(nrow(units)), function(index) {
    mfrmr_gta_hash(units[index, setdiff(
      names(units), "AtomicUnitIdentityHash"
    ), drop = FALSE])
  }, character(1L))
  policy <- contract$LineagePolicy
  exact <- nrow(units) == policy$AtomicUnitCount &&
    length(unique(units$DatasetId)) == policy$DatasetCount &&
    !anyDuplicated(units$AtomicUnitId) &&
    !anyDuplicated(units$AtomicUnitIdentityHash) &&
    all(units$Replicate %in% policy$ReservedReplicates) &&
    !any(units$Replicate %in% policy$ConfirmationReplicates) &&
    setequal(unique(units$MethodId), policy$RequiredMethodIds) &&
    all(table(units$DatasetId) == policy$MethodsPerDataset) &&
    sum(units$ExpectedCandidateFitRows) == policy$CandidateFitRowCount &&
    sum(units$ExpectedCandidateDecisionRows) ==
      policy$CandidateDecisionRowCount &&
    sum(units$ExpectedReferenceRows) == policy$ReferenceRowCount &&
    all(units$AtomicUnitIdentityHash !=
          units$HistoricalAtomicUnitIdentityHash) &&
    !any(units$ExecutionAuthorized) && !any(units$ResponseGenerated) &&
    !any(units$PreFitComputed) && !any(units$CheckpointCreated)
  if (!exact) stop("The hardened reserved-unit ledger is not exact.",
                   call. = FALSE)
  units
}

mfrmr_gtwan_reserved_manifest <- function(contract, historical_manifest,
                                            sealed_manifest) {
  if (!mfrmr_gtwan_contract_hash_valid(contract) ||
      !mfrmr_gtwah_reserved_manifest_hash_valid(historical_manifest) ||
      !identical(historical_manifest$ManifestHash,
                 contract$HistoricalReservedManifestHash)) {
    stop("The exact b1g19 contract and historical manifest are required.",
         call. = FALSE)
  }
  units <- mfrmr_gtwan_units(contract, sealed_manifest)
  assignment <- data.frame(
    AtomicUnitId = units$AtomicUnitId,
    HistoricalAtomicUnitIdentityHash =
      units$HistoricalAtomicUnitIdentityHash,
    AtomicUnitIdentityHash = units$AtomicUnitIdentityHash,
    ShardId = sprintf("R%04d", units$Replicate),
    stringsAsFactors = FALSE
  )
  shard_ids <- contract$LineagePolicy$ShardOrder
  shards <- do.call(rbind, lapply(shard_ids, function(shard_id) {
    index <- which(assignment$ShardId == shard_id)
    old <- historical_manifest$Shards[
      historical_manifest$Shards$ShardId == shard_id, , drop = FALSE
    ]
    data.frame(
      ShardId = shard_id,
      Replicate = as.integer(sub("^R", "", shard_id)),
      AtomicUnitCount = length(index),
      CandidateFitRowCount = sum(units$ExpectedCandidateFitRows[index]),
      CandidateDecisionRowCount =
        sum(units$ExpectedCandidateDecisionRows[index]),
      ReferenceRowCount = sum(units$ExpectedReferenceRows[index]),
      HistoricalShardIdentityHash = old$ShardIdentityHash,
      ShardIdentityHash = mfrmr_gta_hash(assignment[index, , drop = FALSE]),
      stringsAsFactors = FALSE
    )
  }))
  active_registry <- list(
    LineageContractHash = contract$ContractHash,
    LineagePolicyHash = contract$LineagePolicy$PolicyHash,
    HardenedAdapterContractHash = contract$HardenedAdapterContractHash,
    HardenedGeneratorContractHash = contract$HardenedGeneratorContractHash,
    AdapterHashes = contract$AdapterHashes,
    AdapterDependencyHashes = contract$AdapterDependencyHashes,
    AtomicUnitIdentityRegistryHash = mfrmr_gta_hash(assignment[c(
      "AtomicUnitId", "AtomicUnitIdentityHash", "ShardId"
    )]),
    ShardIdentityHashes = shards$ShardIdentityHash
  )
  historical_registry <- list(
    HistoricalAdapterContractHash = contract$HistoricalAdapterContractHash,
    HistoricalReservedManifestHash = contract$HistoricalReservedManifestHash,
    HistoricalIdentityRegistryHash = contract$HistoricalIdentityRegistryHash,
    HistoricalAtomicUnitIdentityRegistryHash = mfrmr_gta_hash(assignment[c(
      "AtomicUnitId", "HistoricalAtomicUnitIdentityHash", "ShardId"
    )]),
    HistoricalShardIdentityHashes = shards$HistoricalShardIdentityHash
  )
  identity <- list(
    Contract = "hardened_reserved_run_manifest_b1g19_v1",
    HardenedLineageContractHash = contract$ContractHash,
    ParentEvidenceReceiptHash = contract$ParentEvidenceReceiptHash,
    HistoricalReservedManifestHash = historical_manifest$ManifestHash,
    UpstreamSealedManifestHash = sealed_manifest$ManifestHash,
    OutputRoot = contract$LineagePolicy$OutputRoot,
    InheritedRuntimeHash = contract$InheritedRuntimeHash,
    ActiveIdentityRegistry = active_registry,
    HistoricalProvenanceRegistry = historical_registry,
    UnitAssignments = assignment,
    Shards = shards,
    ScientificHashExclusions = c(
      "timing", "computed_or_reused", "progress_frequency"
    ),
    ResponseGenerationPermitted = FALSE,
    ModelFittingPermitted = FALSE,
    OutputRootCreationPermitted = FALSE,
    EarlyStoppingPermitted = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    ConfirmationUse = FALSE
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    DatasetCount = length(unique(units$DatasetId)),
    AtomicUnitCount = nrow(units),
    CandidateFitRowCount = sum(units$ExpectedCandidateFitRows),
    CandidateDecisionRowCount =
      sum(units$ExpectedCandidateDecisionRows),
    ReferenceRowCount = sum(units$ExpectedReferenceRows),
    ShardCount = nrow(shards),
    HardenedReservedRunManifestFrozen = TRUE,
    ExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwan_reserved_manifest")
}

mfrmr_gtwan_reserved_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "HardenedLineageContractHash",
    "ParentEvidenceReceiptHash", "HistoricalReservedManifestHash",
    "UpstreamSealedManifestHash", "OutputRoot", "InheritedRuntimeHash",
    "ActiveIdentityRegistry", "HistoricalProvenanceRegistry",
    "UnitAssignments", "Shards", "ScientificHashExclusions",
    "ResponseGenerationPermitted", "ModelFittingPermitted",
    "OutputRootCreationPermitted", "EarlyStoppingPermitted",
    "CalibrationExecutionAuthorized", "ConfirmationUse"
  )
  if (!inherits(manifest, "mfrmr_gtwan_reserved_manifest") ||
      !all(fields %in% names(manifest)) ||
      !is.data.frame(manifest$UnitAssignments) ||
      !is.data.frame(manifest$Shards)) return(FALSE)
  assignment <- manifest$UnitAssignments
  shards <- manifest$Shards
  assignment_fields <- c(
    "AtomicUnitId", "HistoricalAtomicUnitIdentityHash",
    "AtomicUnitIdentityHash", "ShardId"
  )
  shard_fields <- c(
    "ShardId", "Replicate", "AtomicUnitCount", "CandidateFitRowCount",
    "CandidateDecisionRowCount", "ReferenceRowCount",
    "HistoricalShardIdentityHash", "ShardIdentityHash"
  )
  if (!all(assignment_fields %in% names(assignment)) ||
      !all(shard_fields %in% names(shards)) ||
      anyDuplicated(assignment$AtomicUnitId) ||
      anyDuplicated(assignment$AtomicUnitIdentityHash) ||
      anyDuplicated(shards$ShardId) ||
      !setequal(unique(assignment$ShardId), shards$ShardId)) return(FALSE)
  computed_shards <- vapply(shards$ShardId, function(shard_id) {
    mfrmr_gta_hash(assignment[
      assignment$ShardId == shard_id, , drop = FALSE
    ])
  }, character(1L))
  registry_exact <- identical(
    manifest$ActiveIdentityRegistry$AtomicUnitIdentityRegistryHash,
    mfrmr_gta_hash(assignment[c(
      "AtomicUnitId", "AtomicUnitIdentityHash", "ShardId"
    )])
  ) && identical(
    unname(manifest$ActiveIdentityRegistry$ShardIdentityHashes),
    unname(shards$ShardIdentityHash)
  ) && identical(unname(computed_shards), unname(shards$ShardIdentityHash)) &&
    identical(
      manifest$HistoricalProvenanceRegistry$
        HistoricalAtomicUnitIdentityRegistryHash,
      mfrmr_gta_hash(assignment[c(
        "AtomicUnitId", "HistoricalAtomicUnitIdentityHash", "ShardId"
      )])
    ) && identical(
      unname(manifest$HistoricalProvenanceRegistry$
               HistoricalShardIdentityHashes),
      unname(shards$HistoricalShardIdentityHash)
    )
  inherits(manifest, "mfrmr_gtwan_reserved_manifest") &&
    all(fields %in% names(manifest)) &&
    identical(manifest$ManifestHash, mfrmr_gta_hash(manifest[fields])) &&
    registry_exact &&
    identical(manifest$AtomicUnitCount, nrow(assignment)) &&
    identical(manifest$ShardCount, nrow(shards)) &&
    all(assignment$AtomicUnitIdentityHash !=
          assignment$HistoricalAtomicUnitIdentityHash) &&
    isTRUE(manifest$HardenedReservedRunManifestFrozen) &&
    !isTRUE(manifest$ExecutionAuthorized) &&
    !isTRUE(manifest$ResponseGenerationPermitted) &&
    !isTRUE(manifest$ModelFittingPermitted) &&
    !isTRUE(manifest$OutputRootCreationPermitted) &&
    !isTRUE(manifest$EarlyStoppingPermitted) &&
    !isTRUE(manifest$CalibrationExecutionAuthorized) &&
    !isTRUE(manifest$ConfirmationUse) &&
    !isTRUE(manifest$CalibrationDataGenerated) &&
    !isTRUE(manifest$CalibrationResultsViewed)
}

mfrmr_gtwan_shard_manifest <- function(contract, reserved_manifest,
                                        sealed_manifest, shard_id,
                                        units = NULL) {
  if (!mfrmr_gtwan_contract_hash_valid(contract) ||
      !mfrmr_gtwan_reserved_manifest_hash_valid(reserved_manifest) ||
      !identical(reserved_manifest$HardenedLineageContractHash,
                 contract$ContractHash) ||
      !inherits(sealed_manifest, "mfrmr_gtwaa_manifest") ||
      !mfrmr_gtwaa_manifest_hash_valid(sealed_manifest)) {
    stop("Exact b1g19 lineage inputs are required.", call. = FALSE)
  }
  shard_id <- as.character(shard_id)
  if (length(shard_id) != 1L ||
      !shard_id %in% contract$LineagePolicy$ShardOrder) {
    stop("One registered reserved shard is required.", call. = FALSE)
  }
  if (is.null(units)) units <- mfrmr_gtwan_units(contract, sealed_manifest)
  assignment <- reserved_manifest$UnitAssignments
  assigned <- assignment[assignment$ShardId == shard_id, , drop = FALSE]
  index <- match(assigned$AtomicUnitId, units$AtomicUnitId)
  if (anyNA(index)) stop("A hardened shard assignment is missing.",
                         call. = FALSE)
  shard_units <- units[index, , drop = FALSE]
  if (!identical(shard_units$AtomicUnitIdentityHash,
                 assigned$AtomicUnitIdentityHash) ||
      !identical(shard_units$HistoricalAtomicUnitIdentityHash,
                 assigned$HistoricalAtomicUnitIdentityHash) ||
      any(shard_units$ExecutionAuthorized) ||
      any(shard_units$ResponseGenerated) || any(shard_units$PreFitComputed) ||
      any(shard_units$CheckpointCreated)) {
    stop("A hardened shard identity changed or became active.",
         call. = FALSE)
  }
  replicate <- as.integer(sub("^R", "", shard_id))
  identity <- list(
    Contract = "prospective_hardened_shard_manifest_b1g19_v1",
    HardenedLineageContractHash = contract$ContractHash,
    ReservedManifestHash = reserved_manifest$ManifestHash,
    HardenedAdapterContractHash = contract$HardenedAdapterContractHash,
    HardenedGeneratorContractHash = contract$HardenedGeneratorContractHash,
    ShardId = shard_id, Replicate = replicate,
    Units = shard_units,
    CandidateEvaluatorHash = contract$AdapterHashes[["CandidateEvaluator"]],
    ReferenceEvaluatorHash = contract$AdapterHashes[["ReferenceEvaluator"]],
    OutputSubdirectory = file.path(
      contract$LineagePolicy$OutputRoot, "shards", shard_id
    ),
    ReservedCalibrationUse = TRUE,
    ConfirmationUse = FALSE,
    ResponseGenerationPermitted = FALSE,
    ModelFittingPermitted = FALSE,
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
  )), class = "mfrmr_gtwan_shard_manifest")
}

mfrmr_gtwan_shard_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "HardenedLineageContractHash", "ReservedManifestHash",
    "HardenedAdapterContractHash", "HardenedGeneratorContractHash",
    "ShardId", "Replicate", "Units", "CandidateEvaluatorHash",
    "ReferenceEvaluatorHash", "OutputSubdirectory",
    "ReservedCalibrationUse", "ConfirmationUse",
    "ResponseGenerationPermitted", "ModelFittingPermitted",
    "EarlyStoppingPermitted"
  )
  if (!inherits(manifest, "mfrmr_gtwan_shard_manifest") ||
      !all(fields %in% names(manifest)) ||
      !is.data.frame(manifest$Units)) return(FALSE)
  units <- manifest$Units
  unit_fields <- c(
    "AtomicUnitIdentityHash", "HistoricalAtomicUnitIdentityHash",
    "HardenedAdapterContractHash", "HardenedGeneratorContractHash",
    "ExecutionAuthorized", "ResponseGenerated", "PreFitComputed",
    "CheckpointCreated"
  )
  if (!all(unit_fields %in% names(units)) ||
      anyDuplicated(units$AtomicUnitId) ||
      anyDuplicated(units$AtomicUnitIdentityHash)) return(FALSE)
  computed_unit_hashes <- vapply(seq_len(nrow(units)), function(index) {
    mfrmr_gta_hash(units[index, setdiff(
      names(units), "AtomicUnitIdentityHash"
    ), drop = FALSE])
  }, character(1L))
  inherits(manifest, "mfrmr_gtwan_shard_manifest") &&
    all(fields %in% names(manifest)) &&
    identical(manifest$ManifestHash, mfrmr_gta_hash(manifest[fields])) &&
    identical(unname(computed_unit_hashes),
              unname(units$AtomicUnitIdentityHash)) &&
    all(units$HardenedAdapterContractHash ==
          manifest$HardenedAdapterContractHash) &&
    all(units$HardenedGeneratorContractHash ==
          manifest$HardenedGeneratorContractHash) &&
    all(units$Replicate == manifest$Replicate) &&
    identical(manifest$AtomicUnitCount, nrow(units)) &&
    isTRUE(manifest$ProspectiveManifestFrozen) &&
    isTRUE(manifest$ReservedCalibrationUse) &&
    !isTRUE(manifest$ConfirmationUse) &&
    !isTRUE(manifest$ResponseGenerationPermitted) &&
    !isTRUE(manifest$ModelFittingPermitted) &&
    !isTRUE(manifest$EarlyStoppingPermitted) &&
    !isTRUE(manifest$ExecutionAuthorized) &&
    !isTRUE(manifest$CalibrationExecutionAuthorized) &&
    !isTRUE(manifest$CalibrationDataGenerated) &&
    !isTRUE(manifest$CalibrationResultsViewed) &&
    !any(manifest$Units$ExecutionAuthorized) &&
    !any(manifest$Units$ResponseGenerated) &&
    !any(manifest$Units$PreFitComputed) &&
    !any(manifest$Units$CheckpointCreated)
}

mfrmr_gtwan_shard_bundle <- function(contract, reserved_manifest,
                                      sealed_manifest) {
  units <- mfrmr_gtwan_units(contract, sealed_manifest)
  manifests <- lapply(contract$LineagePolicy$ShardOrder, function(shard_id) {
    mfrmr_gtwan_shard_manifest(
      contract, reserved_manifest, sealed_manifest, shard_id, units
    )
  })
  names(manifests) <- contract$LineagePolicy$ShardOrder
  registry <- do.call(rbind, lapply(manifests, function(manifest) {
    data.frame(
      ShardId = manifest$ShardId, Replicate = manifest$Replicate,
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
  policy <- contract$LineagePolicy
  exact <- nrow(registry) == policy$ShardCount &&
    identical(registry$ShardId, policy$ShardOrder) &&
    !anyDuplicated(registry$ManifestHash) &&
    !anyDuplicated(registry$OutputSubdirectory) &&
    all(registry$DatasetCount == policy$DatasetsPerShard) &&
    all(registry$AtomicUnitCount == policy$AtomicUnitsPerShard) &&
    all(registry$CandidateFitRowCount == policy$CandidateFitsPerShard) &&
    all(registry$CandidateDecisionRowCount ==
          policy$CandidateDecisionsPerShard) &&
    all(registry$ReferenceRowCount == policy$ReferencesPerShard) &&
    !any(registry$ExecutionAuthorized) &&
    nrow(all_units) == policy$AtomicUnitCount &&
    !anyDuplicated(all_units$AtomicUnitId) &&
    setequal(all_units$AtomicUnitId, assignment$AtomicUnitId) &&
    identical(
      all_units$AtomicUnitIdentityHash[
        match(assignment$AtomicUnitId, all_units$AtomicUnitId)
      ], assignment$AtomicUnitIdentityHash
    )
  if (!exact) stop("The hardened prospective shard bundle is not exact.",
                   call. = FALSE)
  identity <- list(
    Contract = "prospective_hardened_shard_bundle_b1g19_v1",
    HardenedLineageContractHash = contract$ContractHash,
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
    ShardCount = nrow(registry),
    DatasetCount = length(unique(all_units$DatasetId)),
    AtomicUnitCount = nrow(all_units),
    CandidateFitRowCount = sum(registry$CandidateFitRowCount),
    CandidateDecisionRowCount = sum(registry$CandidateDecisionRowCount),
    ReferenceRowCount = sum(registry$ReferenceRowCount),
    ProspectiveShardManifestsFrozen = TRUE,
    ExecutionAuthorized = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwan_shard_bundle")
}

mfrmr_gtwan_shard_bundle_hash_valid <- function(bundle) {
  fields <- c(
    "Contract", "HardenedLineageContractHash", "ReservedManifestHash",
    "Registry", "ManifestHashes", "AtomicUnitIdentityHash"
  )
  if (!inherits(bundle, "mfrmr_gtwan_shard_bundle") ||
      !all(fields %in% names(bundle)) || !is.list(bundle$Manifests)) {
    return(FALSE)
  }
  manifest_hashes <- vapply(
    bundle$Manifests, `[[`, character(1L), "ManifestHash"
  )
  identical(bundle$BundleHash, mfrmr_gta_hash(bundle[fields])) &&
    all(vapply(
      bundle$Manifests, mfrmr_gtwan_shard_manifest_hash_valid, logical(1L)
    )) &&
    identical(unname(manifest_hashes), unname(bundle$ManifestHashes)) &&
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
    isTRUE(bundle$ProspectiveShardManifestsFrozen) &&
    !isTRUE(bundle$ExecutionAuthorized) &&
    !isTRUE(bundle$CalibrationExecutionAuthorized) &&
    !isTRUE(bundle$CalibrationDataGenerated) &&
    !isTRUE(bundle$CalibrationResultsViewed)
}

mfrmr_gtwan_audit <- function(contract, historical_manifest,
                               reserved_manifest, shard_bundle) {
  if (!mfrmr_gtwan_contract_hash_valid(contract) ||
      !mfrmr_gtwah_reserved_manifest_hash_valid(historical_manifest) ||
      !mfrmr_gtwan_reserved_manifest_hash_valid(reserved_manifest) ||
      !mfrmr_gtwan_shard_bundle_hash_valid(shard_bundle)) {
    stop("Exact historical and hardened lineage artifacts are required.",
         call. = FALSE)
  }
  old_assignment <- historical_manifest$UnitAssignments
  new_assignment <- reserved_manifest$UnitAssignments
  old_shards <- historical_manifest$Shards
  new_shards <- reserved_manifest$Shards
  counts_old <- c(
    Datasets = historical_manifest$DatasetCount,
    AtomicUnits = historical_manifest$AtomicUnitCount,
    CandidateFits = historical_manifest$CandidateFitRowCount,
    CandidateDecisions = historical_manifest$CandidateDecisionRowCount,
    References = historical_manifest$ReferenceRowCount,
    Shards = historical_manifest$ShardCount
  )
  counts_new <- c(
    Datasets = reserved_manifest$DatasetCount,
    AtomicUnits = reserved_manifest$AtomicUnitCount,
    CandidateFits = reserved_manifest$CandidateFitRowCount,
    CandidateDecisions = reserved_manifest$CandidateDecisionRowCount,
    References = reserved_manifest$ReferenceRowCount,
    Shards = reserved_manifest$ShardCount
  )
  unit_index <- match(old_assignment$AtomicUnitId,
                      new_assignment$AtomicUnitId)
  shard_index <- match(old_shards$ShardId, new_shards$ShardId)
  unit_partition_equal <- !anyNA(unit_index) &&
    identical(old_assignment$ShardId,
              new_assignment$ShardId[unit_index])
  shard_partition_equal <- !anyNA(shard_index) && identical(
    old_shards[c(
      "ShardId", "Replicate", "AtomicUnitCount", "CandidateFitRowCount",
      "CandidateDecisionRowCount", "ReferenceRowCount"
    )],
    new_shards[shard_index, c(
      "ShardId", "Replicate", "AtomicUnitCount", "CandidateFitRowCount",
      "CandidateDecisionRowCount", "ReferenceRowCount"
    )]
  )
  all_unit_identities_rebased <- !anyNA(unit_index) && all(
    old_assignment$AtomicUnitIdentityHash !=
      new_assignment$AtomicUnitIdentityHash[unit_index]
  ) && identical(
    old_assignment$AtomicUnitIdentityHash,
    new_assignment$HistoricalAtomicUnitIdentityHash[unit_index]
  )
  all_shard_identities_rebased <- !anyNA(shard_index) && all(
    old_shards$ShardIdentityHash !=
      new_shards$ShardIdentityHash[shard_index]
  ) && identical(
    old_shards$ShardIdentityHash,
    new_shards$HistoricalShardIdentityHash[shard_index]
  )
  active <- unique(c(
    contract$ContractHash, contract$LineagePolicy$PolicyHash,
    contract$HardenedAdapterContractHash,
    contract$HardenedGeneratorContractHash, contract$AdapterHashes,
    contract$AdapterDependencyHashes,
    new_assignment$AtomicUnitIdentityHash, new_shards$ShardIdentityHash,
    reserved_manifest$ManifestHash, shard_bundle$ManifestHashes,
    shard_bundle$BundleHash
  ))
  historical <- unique(c(
    contract$HistoricalAdapterContractHash,
    contract$HistoricalReservedManifestHash,
    historical_manifest$AdapterHashes,
    historical_manifest$AdapterDependencyHashes,
    old_assignment$AtomicUnitIdentityHash, old_shards$ShardIdentityHash
  ))
  overlap <- intersect(active, historical)
  confirmation_absent <- !any(
    as.integer(sub("^R", "", new_assignment$ShardId)) %in%
      contract$LineagePolicy$ConfirmationReplicates
  )
  response_free <- !isTRUE(reserved_manifest$ResponseGenerationPermitted) &&
    !isTRUE(reserved_manifest$ModelFittingPermitted) &&
    !isTRUE(reserved_manifest$CalibrationDataGenerated) &&
    !isTRUE(reserved_manifest$CalibrationResultsViewed) &&
    all(vapply(shard_bundle$Manifests, function(manifest) {
      !isTRUE(manifest$ResponseGenerationPermitted) &&
        !isTRUE(manifest$ModelFittingPermitted) &&
        !isTRUE(manifest$CalibrationDataGenerated) &&
        !isTRUE(manifest$CalibrationResultsViewed)
    }, logical(1L)))
  identity <- list(
    Contract = "hardened_reserved_lineage_audit_b1g19_v1",
    HardenedLineageContractHash = contract$ContractHash,
    HistoricalReservedManifestHash = historical_manifest$ManifestHash,
    HardenedReservedManifestHash = reserved_manifest$ManifestHash,
    HardenedShardBundleHash = shard_bundle$BundleHash,
    HistoricalCounts = counts_old,
    HardenedCounts = counts_new,
    CountParity = identical(counts_old, counts_new),
    UnitPartitionParity = unit_partition_equal,
    ShardPartitionParity = shard_partition_equal,
    RebasedAtomicUnitIdentityCount =
      sum(old_assignment$AtomicUnitIdentityHash !=
            new_assignment$AtomicUnitIdentityHash[unit_index]),
    RebasedShardIdentityCount =
      sum(old_shards$ShardIdentityHash !=
            new_shards$ShardIdentityHash[shard_index]),
    AllAtomicUnitIdentitiesRebased = all_unit_identities_rebased,
    AllShardIdentitiesRebased = all_shard_identities_rebased,
    ActiveHistoricalIdentityOverlap = overlap,
    ActiveIdentityExclusionPassed = length(overlap) == 0L,
    ConfirmationReplicatesAbsent = confirmation_absent,
    ResponseFreeConstruction = response_free,
    OutputTargetAbsent = !file.exists(reserved_manifest$OutputRoot),
    HistoricalEvidencePreserved = TRUE
  )
  ready <- all(c(
    identity$CountParity, identity$UnitPartitionParity,
    identity$ShardPartitionParity,
    identity$AllAtomicUnitIdentitiesRebased,
    identity$AllShardIdentitiesRebased,
    identity$ActiveIdentityExclusionPassed,
    identity$ConfirmationReplicatesAbsent,
    identity$ResponseFreeConstruction, identity$OutputTargetAbsent,
    identity$HistoricalEvidencePreserved
  )) && identical(
    identity$RebasedAtomicUnitIdentityCount,
    contract$LineagePolicy$AtomicUnitCount
  ) && identical(
    identity$RebasedShardIdentityCount,
    contract$LineagePolicy$ShardCount
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    HardenedReservedLineageAuditReady = ready,
    ReservedManifestRebaseReady = ready,
    ProspectiveShardManifestsFrozen = ready,
    ReservedAdapterEntryPointReady = FALSE,
    RuntimeContractExtensionReady = FALSE,
    AuthorizedSingleShardRunnerReady = FALSE,
    AuthorizationRNG01Closed = FALSE,
    AuthorizationActivationEligible = FALSE,
    LargeSimulationMayStart = FALSE,
    Replicate201MayBeOpened = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwan_audit")
}

mfrmr_gtwan_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "HardenedLineageContractHash",
    "HistoricalReservedManifestHash", "HardenedReservedManifestHash",
    "HardenedShardBundleHash", "HistoricalCounts", "HardenedCounts",
    "CountParity", "UnitPartitionParity", "ShardPartitionParity",
    "RebasedAtomicUnitIdentityCount", "RebasedShardIdentityCount",
    "AllAtomicUnitIdentitiesRebased", "AllShardIdentitiesRebased",
    "ActiveHistoricalIdentityOverlap", "ActiveIdentityExclusionPassed",
    "ConfirmationReplicatesAbsent", "ResponseFreeConstruction",
    "OutputTargetAbsent", "HistoricalEvidencePreserved"
  )
  ready <- inherits(audit, "mfrmr_gtwan_audit") &&
    identical(audit$HistoricalCounts, audit$HardenedCounts) &&
    identical(audit$RebasedAtomicUnitIdentityCount, 12000L) &&
    identical(audit$RebasedShardIdentityCount, 100L) &&
    length(audit$ActiveHistoricalIdentityOverlap) == 0L && all(c(
      audit$CountParity, audit$UnitPartitionParity,
      audit$ShardPartitionParity, audit$AllAtomicUnitIdentitiesRebased,
      audit$AllShardIdentitiesRebased,
      audit$ActiveIdentityExclusionPassed,
      audit$ConfirmationReplicatesAbsent,
      audit$ResponseFreeConstruction, audit$OutputTargetAbsent,
      audit$HistoricalEvidencePreserved
    ))
  inherits(audit, "mfrmr_gtwan_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$HardenedReservedLineageAuditReady, ready) &&
    identical(audit$ReservedManifestRebaseReady, ready) &&
    identical(audit$ProspectiveShardManifestsFrozen, ready) &&
    !isTRUE(audit$ReservedAdapterEntryPointReady) &&
    !isTRUE(audit$RuntimeContractExtensionReady) &&
    !isTRUE(audit$AuthorizedSingleShardRunnerReady) &&
    !isTRUE(audit$AuthorizationRNG01Closed) &&
    !isTRUE(audit$AuthorizationActivationEligible) &&
    !isTRUE(audit$LargeSimulationMayStart) &&
    !isTRUE(audit$Replicate201MayBeOpened) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed) &&
    !isTRUE(audit$ConfirmationAuthorized) &&
    !isTRUE(audit$InferenceReady) && !isTRUE(audit$DecisionReady)
}
