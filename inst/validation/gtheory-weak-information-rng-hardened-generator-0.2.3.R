# Draft.83d2b2b1g17 reserved-response-free RNG-hardened generator replay.
#
# Repository-internal only. This artifact preserves the historical b1g2a
# generator and wraps it in an explicit, recorded RNG contract. It permits
# nonreserved validation only; reserved calibration and confirmation access
# remain disabled until a later authorized adapter rebase.

mfrmr_gtwal_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtd2_hash_data", "mfrmr_gtw_registry",
    "mfrmr_gtw_generate", "mfrmr_gtwak_policy_hash_valid",
    "mfrmr_gtwak_contract_hash_valid", "mfrmr_gtwak_audit_hash_valid",
    "mfrmr_gtwak_rng_probe", "mfrmr_gtwak_rng_probe_hash_valid"
  )
  audit_environment <- environment(mfrmr_gtwal_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g16 chain before the b1g17 hardened generator: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwal_function_hash <- function(fun) {
  mfrmr_gta_hash(list(
    Formals = paste(deparse(formals(fun), width.cutoff = 500L), collapse = "\n"),
    Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  ))
}

mfrmr_gtwal_source_registry <- function() {
  data.frame(
    SourceId = c("r_random_current", "r_rngkind_current"),
    Locator = c(
      "https://stat.ethz.ch/R-manual/R-devel/library/base/help/Random.html",
      "https://stat.ethz.ch/R-manual/R-devel/library/base/html/Random.html"
    ),
    ContractRole = c(
      "set.seed reproducibility depends on uniform normal and sample kinds",
      "RNGkind exposes and sets all three generator-kind coordinates"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwal_policy <- function() {
  mfrmr_gtwal_require_primitives()
  identity <- list(
    Contract = "rng_hardened_generator_policy_b1g17_v1",
    HistoricalGeneratorVersion =
      "gtheory_weak_information_generator_draft83d2b2a_v1",
    HardenedGeneratorVersion =
      "gtheory_weak_information_rng_hardened_generator_b1g17_v1",
    RequiredRNGKind = c("Mersenne-Twister", "Inversion", "Rejection"),
    AlternateAmbientRNGKind = c(
      "Wichmann-Hill", "Inversion", "Rejection"
    ),
    NonreservedReplayReplicate = 901L,
    ReservedCalibrationReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    HistoricalGeneratorMustRemainUnmodified = TRUE,
    CallerRNGKindAndStateMustBeRestored = TRUE,
    GeneratorIdentityMustRecordAllRNGKinds = TRUE,
    AllRegistryScenariosMustReplayAcrossAmbientKinds = TRUE,
    ReservedAccessEnabled = FALSE,
    DownstreamAdapterRebaseRequired = TRUE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE,
    Sources = mfrmr_gtwal_source_registry()
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwal_policy")
}

mfrmr_gtwal_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwal_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity)) &&
    identical(policy$Contract,
              "rng_hardened_generator_policy_b1g17_v1") &&
    identical(policy$HistoricalGeneratorVersion,
              "gtheory_weak_information_generator_draft83d2b2a_v1") &&
    identical(policy$HardenedGeneratorVersion,
              paste0("gtheory_weak_information_rng_hardened_",
                     "generator_b1g17_v1")) &&
    identical(policy$RequiredRNGKind,
              c("Mersenne-Twister", "Inversion", "Rejection")) &&
    identical(policy$AlternateAmbientRNGKind,
              c("Wichmann-Hill", "Inversion", "Rejection")) &&
    identical(policy$NonreservedReplayReplicate, 901L) &&
    identical(policy$ReservedCalibrationReplicates, 201:300) &&
    identical(policy$ConfirmationReplicates, 501:700) &&
    isTRUE(policy$HistoricalGeneratorMustRemainUnmodified) &&
    isTRUE(policy$CallerRNGKindAndStateMustBeRestored) &&
    isTRUE(policy$GeneratorIdentityMustRecordAllRNGKinds) &&
    isTRUE(policy$AllRegistryScenariosMustReplayAcrossAmbientKinds) &&
    isTRUE(policy$DownstreamAdapterRebaseRequired) &&
    !isTRUE(policy$ReservedAccessEnabled) &&
    !isTRUE(policy$CalibrationResponsesUsed) &&
    !isTRUE(policy$ConfirmationResponsesUsed)
}

mfrmr_gtwal_reserved_replicate <- function(replicate, policy) {
  replicate %in% c(
    policy$ReservedCalibrationReplicates, policy$ConfirmationReplicates
  )
}

mfrmr_gtwal_generate <- function(
    registry = mfrmr_gtw_registry(), scenario_id,
    replicate = mfrmr_gtwal_policy()$NonreservedReplayReplicate,
    policy = mfrmr_gtwal_policy()) {
  mfrmr_gtwal_require_primitives()
  if (!inherits(registry, "mfrmr_gtw_registry") ||
      !mfrmr_gtwal_policy_hash_valid(policy)) {
    stop("The exact weak-information registry and b1g17 policy are required.",
         call. = FALSE)
  }
  replicate <- as.integer(replicate)
  if (length(replicate) != 1L || is.na(replicate) || replicate < 1L) {
    stop("`replicate` must be one positive integer.", call. = FALSE)
  }
  if (mfrmr_gtwal_reserved_replicate(replicate, policy)) {
    stop(
      "b1g17 cannot open reserved calibration or confirmation replicates; ",
      "an authorization-bound adapter rebase is required.", call. = FALSE
    )
  }
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else NULL
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(
      ".Random.seed", envir = .GlobalEnv, inherits = FALSE
    )) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)

  do.call(RNGkind, as.list(policy$RequiredRNGKind))
  historical <- mfrmr_gtw_generate(registry, scenario_id, replicate)
  if (!identical(unname(RNGkind()), policy$RequiredRNGKind)) {
    stop("The required RNG kinds changed during historical generation.",
         call. = FALSE)
  }
  historical_identity <- historical$GeneratorIdentity
  historical_hash <- historical$GeneratorHash
  identity <- list(
    Version = policy$HardenedGeneratorVersion,
    PolicyHash = policy$PolicyHash,
    RequiredRNGKind = policy$RequiredRNGKind,
    HistoricalGeneratorVersion = historical$ContractVersion,
    HistoricalGeneratorHash = historical_hash,
    HistoricalGeneratorIdentityHash = mfrmr_gta_hash(historical_identity),
    RegistryHash = historical$RegistryHash,
    ScenarioId = historical$ScenarioId,
    Replicate = historical$Replicate,
    Seed = historical$Seed,
    ScenarioRowHash = historical_identity$ScenarioRowHash,
    DesignHash = historical_identity$DesignHash,
    FullPotentialDataHash = historical_identity$FullPotentialDataHash,
    AssignedDataHash = historical_identity$AssignedDataHash,
    AnalysisDataHash = historical_identity$AnalysisDataHash,
    NominalTruthHash = historical_identity$NominalTruthHash,
    HistoricalFunctionHashes = historical_identity$FunctionHashes,
    HardenedGeneratorFunctionHash =
      mfrmr_gtwal_function_hash(mfrmr_gtwal_generate)
  )
  historical$ContractVersion <- identity$Version
  historical$HistoricalGeneratorIdentity <- historical_identity
  historical$HistoricalGeneratorHash <- historical_hash
  historical$RequiredRNGKind <- policy$RequiredRNGKind
  historical$RNGSelfContained <- TRUE
  historical$ReservedAccessEnabled <- FALSE
  historical$GeneratorIdentity <- identity
  historical$GeneratorHash <- mfrmr_gta_hash(identity)
  class(historical) <- c("mfrmr_gtwal_generation", class(historical))
  historical
}

mfrmr_gtwal_generation_hash_valid <- function(generation) {
  identity <- generation$GeneratorIdentity
  policy <- mfrmr_gtwal_policy()
  required_identity_fields <- c(
    "Version", "PolicyHash", "RequiredRNGKind",
    "HistoricalGeneratorVersion", "HistoricalGeneratorHash",
    "HistoricalGeneratorIdentityHash", "RegistryHash", "ScenarioId",
    "Replicate", "Seed", "ScenarioRowHash", "DesignHash",
    "FullPotentialDataHash", "AssignedDataHash", "AnalysisDataHash",
    "NominalTruthHash", "HistoricalFunctionHashes",
    "HardenedGeneratorFunctionHash"
  )
  inherits(generation, "mfrmr_gtwal_generation") &&
    is.list(identity) && all(required_identity_fields %in% names(identity)) &&
    identical(identity$Version, policy$HardenedGeneratorVersion) &&
    identical(identity$PolicyHash, policy$PolicyHash) &&
    identical(identity$RequiredRNGKind, policy$RequiredRNGKind) &&
    identical(identity$HistoricalGeneratorVersion,
              policy$HistoricalGeneratorVersion) &&
    identical(identity$HardenedGeneratorFunctionHash,
              mfrmr_gtwal_function_hash(mfrmr_gtwal_generate)) &&
    identical(generation$ContractVersion, identity$Version) &&
    identical(generation$RegistryHash, identity$RegistryHash) &&
    identical(generation$ScenarioId, identity$ScenarioId) &&
    identical(generation$Replicate, identity$Replicate) &&
    identical(generation$Seed, identity$Seed) &&
    identical(generation$RequiredRNGKind, identity$RequiredRNGKind) &&
    identical(generation$GeneratorHash, mfrmr_gta_hash(identity)) &&
    identical(generation$HistoricalGeneratorHash,
              identity$HistoricalGeneratorHash) &&
    identical(mfrmr_gta_hash(generation$HistoricalGeneratorIdentity),
              identity$HistoricalGeneratorIdentityHash) &&
    identical(identity$HistoricalGeneratorHash,
              identity$HistoricalGeneratorIdentityHash) &&
    identical(generation$HistoricalGeneratorIdentity$Version,
              identity$HistoricalGeneratorVersion) &&
    identical(generation$HistoricalGeneratorIdentity$RegistryHash,
              identity$RegistryHash) &&
    identical(generation$HistoricalGeneratorIdentity$ScenarioId,
              identity$ScenarioId) &&
    identical(generation$HistoricalGeneratorIdentity$Replicate,
              identity$Replicate) &&
    identical(generation$HistoricalGeneratorIdentity$Seed,
              identity$Seed) &&
    identical(mfrmr_gtd2_hash_data(generation$FullPotentialData),
              identity$FullPotentialDataHash) &&
    identical(mfrmr_gtd2_hash_data(generation$AssignedData),
              identity$AssignedDataHash) &&
    identical(mfrmr_gtd2_hash_data(generation$AnalysisData),
              identity$AnalysisDataHash) &&
    identical(mfrmr_gta_hash(generation$NominalTruth),
              identity$NominalTruthHash) &&
    isTRUE(generation$RNGSelfContained) &&
    !isTRUE(generation$ReservedAccessEnabled) &&
    !isTRUE(generation$EstimationReady) &&
    !isTRUE(generation$InferenceReady) &&
    !isTRUE(generation$DecisionReady)
}

mfrmr_gtwal_replay_manifest <- function(
    registry = mfrmr_gtw_registry(), policy = mfrmr_gtwal_policy(),
    replicate = policy$NonreservedReplayReplicate) {
  if (!inherits(registry, "mfrmr_gtw_registry") ||
      !mfrmr_gtwal_policy_hash_valid(policy)) {
    stop("The exact weak-information registry and b1g17 policy are required.",
         call. = FALSE)
  }
  replicate <- as.integer(replicate)
  if (length(replicate) != 1L || is.na(replicate) || replicate < 1L ||
      mfrmr_gtwal_reserved_replicate(replicate, policy)) {
    stop("The replay manifest requires one nonreserved replicate.",
         call. = FALSE)
  }
  rows <- registry$Cells[c("ScenarioId", "SeedStart")]
  rows$Replicate <- replicate
  rows$Seed <- as.integer(rows$SeedStart + replicate - 1L)
  rows$CalibrationUse <- FALSE
  rows$ConfirmationUse <- FALSE
  rows <- rows[c(
    "ScenarioId", "Replicate", "SeedStart", "Seed",
    "CalibrationUse", "ConfirmationUse"
  )]
  identity <- list(
    Contract = "rng_hardened_replay_manifest_b1g17_v1",
    PolicyHash = policy$PolicyHash,
    RegistryHash = registry$RegistryHash,
    RequiredRNGKind = policy$RequiredRNGKind,
    AlternateAmbientRNGKind = policy$AlternateAmbientRNGKind,
    Rows = rows
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    ScenarioCount = nrow(rows), ResponsesGenerated = FALSE,
    CalibrationResponsesUsed = FALSE, ConfirmationResponsesUsed = FALSE
  )), class = "mfrmr_gtwal_manifest")
}

mfrmr_gtwal_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "PolicyHash", "RegistryHash", "RequiredRNGKind",
    "AlternateAmbientRNGKind", "Rows"
  )
  inherits(manifest, "mfrmr_gtwal_manifest") &&
    all(fields %in% names(manifest)) &&
    identical(manifest$ManifestHash, mfrmr_gta_hash(manifest[fields])) &&
    identical(manifest$ScenarioCount, nrow(manifest$Rows)) &&
    !any(manifest$Rows$CalibrationUse) &&
    !any(manifest$Rows$ConfirmationUse) &&
    !isTRUE(manifest$ResponsesGenerated) &&
    !isTRUE(manifest$CalibrationResponsesUsed) &&
    !isTRUE(manifest$ConfirmationResponsesUsed)
}

mfrmr_gtwal_generate_under_ambient <- function(
    registry, scenario_id, replicate, ambient_kind, policy) {
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else NULL
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(
      ".Random.seed", envir = .GlobalEnv, inherits = FALSE
    )) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  do.call(RNGkind, as.list(ambient_kind))
  set.seed(170017L)
  before_kind <- unname(RNGkind())
  before_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  generation <- mfrmr_gtwal_generate(
    registry, scenario_id, replicate, policy
  )
  after_kind <- unname(RNGkind())
  after_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  list(
    Generation = generation,
    CallerStateRestored = identical(before_kind, after_kind) &&
      identical(before_seed, after_seed)
  )
}

mfrmr_gtwal_replay <- function(
    manifest = mfrmr_gtwal_replay_manifest(),
    registry = mfrmr_gtw_registry(), policy = mfrmr_gtwal_policy()) {
  if (!mfrmr_gtwal_manifest_hash_valid(manifest) ||
      !inherits(registry, "mfrmr_gtw_registry") ||
      !mfrmr_gtwal_policy_hash_valid(policy) ||
      !identical(manifest$PolicyHash, policy$PolicyHash) ||
      !identical(manifest$RegistryHash, registry$RegistryHash)) {
    stop("The exact b1g17 manifest, registry, and policy are required.",
         call. = FALSE)
  }
  rows <- lapply(seq_len(nrow(manifest$Rows)), function(index) {
    unit <- manifest$Rows[index, , drop = FALSE]
    required <- mfrmr_gtwal_generate_under_ambient(
      registry, unit$ScenarioId[[1L]], unit$Replicate[[1L]],
      policy$RequiredRNGKind, policy
    )
    alternate <- mfrmr_gtwal_generate_under_ambient(
      registry, unit$ScenarioId[[1L]], unit$Replicate[[1L]],
      policy$AlternateAmbientRNGKind, policy
    )
    a <- required$Generation
    b <- alternate$Generation
    data.frame(
      ScenarioId = unit$ScenarioId,
      Replicate = unit$Replicate,
      Seed = unit$Seed,
      RequiredGeneratorHash = a$GeneratorHash,
      AlternateGeneratorHash = b$GeneratorHash,
      RequiredAnalysisDataHash = a$GeneratorIdentity$AnalysisDataHash,
      AlternateAnalysisDataHash = b$GeneratorIdentity$AnalysisDataHash,
      RequiredHistoricalGeneratorHash = a$HistoricalGeneratorHash,
      AlternateHistoricalGeneratorHash = b$HistoricalGeneratorHash,
      RequiredGenerationHashValid =
        mfrmr_gtwal_generation_hash_valid(a),
      AlternateGenerationHashValid =
        mfrmr_gtwal_generation_hash_valid(b),
      RequiredCallerStateRestored = required$CallerStateRestored,
      AlternateCallerStateRestored = alternate$CallerStateRestored,
      GeneratorHashEqualAcrossAmbientKinds =
        identical(a$GeneratorHash, b$GeneratorHash),
      AnalysisDataHashEqualAcrossAmbientKinds = identical(
        a$GeneratorIdentity$AnalysisDataHash,
        b$GeneratorIdentity$AnalysisDataHash
      ),
      HistoricalHashEqualAcrossWrappedAmbientKinds = identical(
        a$HistoricalGeneratorHash, b$HistoricalGeneratorHash
      ),
      CalibrationUse = FALSE,
      ConfirmationUse = FALSE,
      stringsAsFactors = FALSE
    )
  })
  rows <- do.call(rbind, rows)
  row.names(rows) <- NULL
  identity <- list(
    Contract = "rng_hardened_cross_ambient_replay_b1g17_v1",
    ManifestHash = manifest$ManifestHash,
    PolicyHash = policy$PolicyHash,
    RegistryHash = registry$RegistryHash,
    Rows = rows
  )
  structure(c(identity, list(
    ReplayHash = mfrmr_gta_hash(identity),
    ScenarioCount = nrow(rows), ResponsesGenerated = TRUE,
    ReservedResponseOpened = FALSE, CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )), class = "mfrmr_gtwal_replay")
}

mfrmr_gtwal_replay_hash_valid <- function(replay) {
  fields <- c("Contract", "ManifestHash", "PolicyHash", "RegistryHash", "Rows")
  boolean_fields <- c(
    "RequiredGenerationHashValid", "AlternateGenerationHashValid",
    "RequiredCallerStateRestored", "AlternateCallerStateRestored",
    "GeneratorHashEqualAcrossAmbientKinds",
    "AnalysisDataHashEqualAcrossAmbientKinds",
    "HistoricalHashEqualAcrossWrappedAmbientKinds"
  )
  inherits(replay, "mfrmr_gtwal_replay") &&
    all(fields %in% names(replay)) &&
    all(boolean_fields %in% names(replay$Rows)) &&
    identical(replay$ReplayHash, mfrmr_gta_hash(replay[fields])) &&
    identical(replay$ScenarioCount, nrow(replay$Rows)) &&
    all(vapply(replay$Rows[boolean_fields], all, logical(1L))) &&
    !any(replay$Rows$CalibrationUse) &&
    !any(replay$Rows$ConfirmationUse) &&
    isTRUE(replay$ResponsesGenerated) &&
    !isTRUE(replay$ReservedResponseOpened) &&
    !isTRUE(replay$CalibrationResponsesUsed) &&
    !isTRUE(replay$ConfirmationResponsesUsed)
}

mfrmr_gtwal_function_hashes <- function() {
  functions <- list(
    require_primitives = mfrmr_gtwal_require_primitives,
    function_hash = mfrmr_gtwal_function_hash,
    source_registry = mfrmr_gtwal_source_registry,
    policy = mfrmr_gtwal_policy,
    policy_hash_valid = mfrmr_gtwal_policy_hash_valid,
    reserved_replicate = mfrmr_gtwal_reserved_replicate,
    generate = mfrmr_gtwal_generate,
    generation_hash_valid = mfrmr_gtwal_generation_hash_valid,
    replay_manifest = mfrmr_gtwal_replay_manifest,
    manifest_hash_valid = mfrmr_gtwal_manifest_hash_valid,
    generate_under_ambient = mfrmr_gtwal_generate_under_ambient,
    replay = mfrmr_gtwal_replay,
    replay_hash_valid = mfrmr_gtwal_replay_hash_valid,
    contract = mfrmr_gtwal_contract,
    contract_hash_valid = mfrmr_gtwal_contract_hash_valid,
    audit = mfrmr_gtwal_audit,
    audit_hash_valid = mfrmr_gtwal_audit_hash_valid
  )
  vapply(functions, mfrmr_gtwal_function_hash, character(1L))
}

mfrmr_gtwal_contract <- function(parent_contract, parent_audit) {
  if (!mfrmr_gtwak_contract_hash_valid(parent_contract) ||
      !mfrmr_gtwak_audit_hash_valid(parent_audit) ||
      !identical(parent_audit$PreactivationHardeningContractHash,
                 parent_contract$ContractHash) ||
      isTRUE(parent_audit$AuthorizationActivationEligible)) {
    stop("The exact non-authorizing b1g16 contract and audit are required.",
         call. = FALSE)
  }
  policy <- mfrmr_gtwal_policy()
  identity <- list(
    Contract = "rng_hardened_generator_contract_b1g17_v1",
    ParentHardeningContractHash = parent_contract$ContractHash,
    ParentHardeningDecisionHash = parent_audit$DecisionHash,
    ParentBlockerIds = parent_audit$BlockerIds,
    HistoricalGeneratorFunctionHash =
      parent_contract$GeneratorFunctionHash,
    HardenedGeneratorFunctionHash =
      mfrmr_gtwal_function_hash(mfrmr_gtwal_generate),
    Policy = policy,
    Sources = mfrmr_gtwal_source_registry(),
    FunctionHashes = mfrmr_gtwal_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    HistoricalGeneratorPreserved = TRUE,
    HardenedGeneratorContractFrozen = TRUE,
    ReservedAccessEnabled = FALSE,
    DownstreamAdaptersRebased = FALSE,
    ExecutionAuthorizationRecordIssued = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwal_contract")
}

mfrmr_gtwal_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "ParentHardeningContractHash", "ParentHardeningDecisionHash",
    "ParentBlockerIds", "HistoricalGeneratorFunctionHash",
    "HardenedGeneratorFunctionHash", "Policy", "Sources", "FunctionHashes"
  )
  inherits(contract, "mfrmr_gtwal_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    identical(contract$ParentHardeningContractHash,
              "9ea428bfec87509cacdadba6250d837aef5090c07550f2c0603b79164f2c58c0") &&
    identical(contract$ParentHardeningDecisionHash,
              "e4e32bc3fc93c4469ce88ccf46e91866b6a22ef3e81d71a9a3dc483d767f1799") &&
    identical(contract$ParentBlockerIds, c(
      "RNG-01", "RUNTIME-01", "THREAD-01", "PROCESS-01", "RUNNER-01",
      "LOCK-01", "ROOT-01", "CAPACITY-01"
    )) &&
    identical(contract$HistoricalGeneratorFunctionHash,
              "555b3ebc6c1b0b5d97f436570e7ca1ccef027e6bed38e4724ef4c0055f71e65f") &&
    identical(contract$HardenedGeneratorFunctionHash,
              mfrmr_gtwal_function_hash(mfrmr_gtwal_generate)) &&
    mfrmr_gtwal_policy_hash_valid(contract$Policy) &&
    isTRUE(contract$HistoricalGeneratorPreserved) &&
    isTRUE(contract$HardenedGeneratorContractFrozen) &&
    !isTRUE(contract$ReservedAccessEnabled) &&
    !isTRUE(contract$DownstreamAdaptersRebased) &&
    !isTRUE(contract$ExecutionAuthorizationRecordIssued) &&
    !isTRUE(contract$CalibrationExecutionAuthorized) &&
    !isTRUE(contract$ConfirmationAuthorized) &&
    !isTRUE(contract$InferenceReady) && !isTRUE(contract$DecisionReady)
}

mfrmr_gtwal_audit <- function(
    contract, manifest = mfrmr_gtwal_replay_manifest(),
    replay = mfrmr_gtwal_replay(manifest)) {
  if (!mfrmr_gtwal_contract_hash_valid(contract) ||
      !mfrmr_gtwal_manifest_hash_valid(manifest) ||
      !mfrmr_gtwal_replay_hash_valid(replay) ||
      !identical(manifest$PolicyHash, contract$Policy$PolicyHash) ||
      !identical(replay$ManifestHash, manifest$ManifestHash)) {
    stop("The exact b1g17 contract, manifest, and replay are required.",
         call. = FALSE)
  }
  rows <- replay$Rows
  component_gates <- data.frame(
    GateId = c(
      "RNG-GEN-01", "RNG-REPLAY-01", "RNG-STATE-01",
      "RNG-IDENTITY-01", "RNG-BAND-01", "RNG-ADAPTER-01"
    ),
    Gate = c(
      "generator fixes all three RNG kinds",
      "all registry scenarios replay across ambient RNG kinds",
      "caller RNG kind and seed are restored",
      "hardened and historical generator identities are both recorded",
      "replay cannot open calibration or confirmation bands",
      "all downstream fitting and reference adapters use hardened identity"
    ),
    ObservedPass = c(
      all(rows$RequiredGenerationHashValid) &&
        all(rows$AlternateGenerationHashValid),
      nrow(rows) == manifest$ScenarioCount &&
        all(rows$GeneratorHashEqualAcrossAmbientKinds) &&
        all(rows$AnalysisDataHashEqualAcrossAmbientKinds) &&
        all(rows$HistoricalHashEqualAcrossWrappedAmbientKinds),
      all(rows$RequiredCallerStateRestored) &&
        all(rows$AlternateCallerStateRestored),
      all(nzchar(rows$RequiredHistoricalGeneratorHash)) &&
        all(nzchar(rows$RequiredGeneratorHash)),
      !replay$ReservedResponseOpened &&
        !any(rows$CalibrationUse) && !any(rows$ConfirmationUse),
      contract$DownstreamAdaptersRebased
    ),
    Evidence = c(
      contract$HardenedGeneratorFunctionHash,
      replay$ReplayHash,
      replay$ReplayHash,
      replay$ReplayHash,
      manifest$ManifestHash,
      "deferred_to_authorization_bound_adapter_rebase"
    ),
    stringsAsFactors = FALSE
  )
  blockers <- component_gates[!component_gates$ObservedPass, , drop = FALSE]
  generator_ready <- all(component_gates$ObservedPass[1:5]) &&
    identical(blockers$GateId, "RNG-ADAPTER-01")
  identity <- list(
    Contract = "rng_hardened_generator_audit_b1g17_v1",
    HardenedGeneratorContractHash = contract$ContractHash,
    ManifestHash = manifest$ManifestHash,
    ReplayHash = replay$ReplayHash,
    ScenarioCount = manifest$ScenarioCount,
    ComponentGates = component_gates,
    ComponentBlockerIds = blockers$GateId,
    ParentAuthorizationBlockerIds = contract$ParentBlockerIds,
    HistoricalGeneratorPreserved = contract$HistoricalGeneratorPreserved,
    DownstreamAdaptersRebased = contract$DownstreamAdaptersRebased,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    HardenedGeneratorAuditReady = generator_ready,
    HardenedGeneratorReady = generator_ready,
    RNG01ProspectivelyResolved = generator_ready,
    AuthorizationRNG01Closed = generator_ready &&
      isTRUE(contract$DownstreamAdaptersRebased),
    AuthorizationActivationEligible = FALSE,
    LargeSimulationMayStart = FALSE,
    Replicate201MayBeOpened = FALSE,
    ExecutionAuthorizationRecordIssued = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwal_audit")
}

mfrmr_gtwal_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "HardenedGeneratorContractHash", "ManifestHash",
    "ReplayHash", "ScenarioCount", "ComponentGates",
    "ComponentBlockerIds", "ParentAuthorizationBlockerIds",
    "HistoricalGeneratorPreserved", "DownstreamAdaptersRebased",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  blockers <- if (inherits(audit, "mfrmr_gtwal_audit") &&
      is.data.frame(audit$ComponentGates)) {
    audit$ComponentGates[!audit$ComponentGates$ObservedPass, , drop = FALSE]
  } else data.frame()
  generator_ready <- inherits(audit, "mfrmr_gtwal_audit") &&
    identical(nrow(audit$ComponentGates), 6L) &&
    identical(audit$ScenarioCount, 30L) &&
    identical(audit$ComponentGates$GateId, c(
      "RNG-GEN-01", "RNG-REPLAY-01", "RNG-STATE-01",
      "RNG-IDENTITY-01", "RNG-BAND-01", "RNG-ADAPTER-01"
    )) &&
    all(audit$ComponentGates$ObservedPass[1:5]) &&
    identical(blockers$GateId, "RNG-ADAPTER-01")
  inherits(audit, "mfrmr_gtwal_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$ComponentBlockerIds, blockers$GateId) &&
    identical(audit$ParentAuthorizationBlockerIds, c(
      "RNG-01", "RUNTIME-01", "THREAD-01", "PROCESS-01", "RUNNER-01",
      "LOCK-01", "ROOT-01", "CAPACITY-01"
    )) &&
    isTRUE(audit$HistoricalGeneratorPreserved) &&
    isTRUE(audit$HardenedGeneratorAuditReady) &&
    identical(audit$HardenedGeneratorReady, generator_ready) &&
    identical(audit$RNG01ProspectivelyResolved, generator_ready) &&
    !isTRUE(audit$AuthorizationRNG01Closed) &&
    !isTRUE(audit$DownstreamAdaptersRebased) &&
    !isTRUE(audit$AuthorizationActivationEligible) &&
    !isTRUE(audit$LargeSimulationMayStart) &&
    !isTRUE(audit$Replicate201MayBeOpened) &&
    !isTRUE(audit$ExecutionAuthorizationRecordIssued) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed) &&
    !isTRUE(audit$ConfirmationAuthorized) &&
    !isTRUE(audit$InferenceReady) && !isTRUE(audit$DecisionReady) &&
    !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
}
