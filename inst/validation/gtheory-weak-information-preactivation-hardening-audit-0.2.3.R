# Draft.83d2b2b1g16 response-free pre-activation hardening audit.
#
# Repository-internal only. This audit checks deterministic generation,
# runtime identity, process isolation, writer exclusion, output-root lifecycle,
# and per-shard resource rechecks before any reserved calibration response is
# opened. It deliberately cannot issue an execution authorization.

mfrmr_gtwak_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwai_contract_hash_valid",
    "mfrmr_gtwai_shard_bundle_hash_valid",
    "mfrmr_gtwaj_contract_hash_valid", "mfrmr_gtwaj_audit_hash_valid",
    "mfrmr_gtw_registry", "mfrmr_gtwp_phase_table",
    "mfrmr_gtw_generate", "mfrmr_gtwag_execute",
    "mfrmr_gtwah_runtime_identity"
  )
  audit_environment <- environment(mfrmr_gtwak_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g15a chain before the b1g16 hardening audit: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwak_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwak_source_registry <- function() {
  data.frame(
    SourceId = c(
      "r_random_current", "r_session_info_current",
      "r_startup_current", "glmmtmb_parallel_current",
      "r_file_rename_current"
    ),
    Locator = c(
      "https://stat.ethz.ch/R-manual/R-devel/library/base/help/Random.html",
      paste0(
        "https://stat.ethz.ch/R-manual/R-devel/library/",
        "utils/html/sessionInfo.html"
      ),
      "https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html",
      "https://glmmtmb.github.io/glmmTMB/articles/parallel.html",
      "https://stat.ethz.ch/R-manual/R-devel/library/base/html/files.html"
    ),
    ContractRole = c(
      "set.seed reproducibility requires explicit RNG and normal kinds",
      "runtime identity includes RNG BLAS LAPACK locale and timezone",
      "vanilla child process excludes site user environment profile and restore",
      "glmmTMB optimization thread count is an explicit control",
      "same-directory checked rename installs completed checkpoints"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwak_policy <- function() {
  thread_variables <- c(
    "OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
    "VECLIB_MAXIMUM_THREADS", "BLIS_NUM_THREADS"
  )
  identity <- list(
    Contract = "preactivation_hardening_policy_b1g16_v1",
    ReservedCalibrationReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    NonreservedRNGProbeReplicate = 901L,
    NonreservedRNGProbeScenario =
      "GT-WI-baseline_complete-exact_zero",
    RequiredRNGKind = c(
      "Mersenne-Twister", "Inversion", "Rejection"
    ),
    AlternateRNGKindForNegativeControl = c(
      "Wichmann-Hill", "Inversion", "Rejection"
    ),
    RequiredGLMMTMBParallel = list(n = 1L, autopar = FALSE),
    RequiredThreadEnvironment = stats::setNames(
      rep("1", length(thread_variables)), thread_variables
    ),
    RequiredLocaleEnvironment = c(LC_ALL = "C", TZ = "UTC"),
    RequiredProcessInvocation = "Rscript --vanilla",
    StartupEnvironmentAndProfilesPermitted = FALSE,
    SavedWorkspaceRestorePermitted = FALSE,
    GeneratorMustSetExplicitUniformNormalAndSampleKinds = TRUE,
    GeneratorIdentityMustRecordRNGKind = TRUE,
    ExtendedRuntimeIdentityMustBeAuthorizationBound = TRUE,
    SingleWriterLockRequired = TRUE,
    AtomicActivationMarkerRequired = TRUE,
    InitialActivationAndResumeMustBeDistinct = TRUE,
    PerShardFilesystemAndCapacityRecheckRequired = TRUE,
    StaleLockTakeoverAutomatic = FALSE,
    MaximumConcurrentShards = 1L,
    EarlyStoppingPermitted = FALSE,
    ConfirmationAccessPermitted = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE,
    Sources = mfrmr_gtwak_source_registry()
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwak_policy")
}

mfrmr_gtwak_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwak_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity))
}

mfrmr_gtwak_runtime_identity <- function() {
  packages <- c(
    "digest", "lme4", "Matrix", "glmmTMB", "TMB", "minqa", "nloptr",
    "numDeriv"
  )
  versions <- vapply(packages, function(package) {
    as.character(utils::packageVersion(package))
  }, character(1L))
  session <- utils::sessionInfo()
  thread_variables <- c(
    "OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
    "VECLIB_MAXIMUM_THREADS", "BLIS_NUM_THREADS"
  )
  identity <- list(
    RVersion = as.character(getRversion()),
    RPlatform = R.version$platform,
    RArch = R.version$arch,
    OS = unname(Sys.info()[["sysname"]]),
    OSRelease = unname(Sys.info()[["release"]]),
    RNGKind = unname(RNGkind()),
    MatrixProducts = unname(session$matprod),
    BLAS = unname(session$BLAS),
    LAPACK = unname(session$LAPACK),
    LAVersion = unname(session$LA_version),
    Locale = unname(session$locale),
    TimeZone = unname(session$tzone),
    PackageVersions = versions,
    GLMMTMBParallel = glmmTMB::glmmTMBControl()$parallel,
    ThreadEnvironment = stats::setNames(
      Sys.getenv(thread_variables, unset = "<unset>"), thread_variables
    )
  )
  structure(c(identity, list(
    RuntimeHash = mfrmr_gta_hash(identity)
  )), class = "mfrmr_gtwak_runtime")
}

mfrmr_gtwak_runtime_hash_valid <- function(runtime) {
  fields <- c(
    "RVersion", "RPlatform", "RArch", "OS", "OSRelease", "RNGKind",
    "MatrixProducts", "BLAS", "LAPACK", "LAVersion", "Locale",
    "TimeZone", "PackageVersions", "GLMMTMBParallel",
    "ThreadEnvironment"
  )
  inherits(runtime, "mfrmr_gtwak_runtime") &&
    all(fields %in% names(runtime)) &&
    identical(runtime$RuntimeHash, mfrmr_gta_hash(runtime[fields]))
}

mfrmr_gtwak_seed_ledger <- function(
    registry = mfrmr_gtw_registry(),
    phase_table = mfrmr_gtwp_phase_table()) {
  if (!inherits(registry, "mfrmr_gtw_registry") ||
      !is.data.frame(phase_table) || !all(c(
        "PhaseId", "ReplicateStart", "ReplicateEnd", "ScenarioProfile",
        "ExecutionAuthorized", "ConfirmationUse"
      ) %in% names(phase_table))) {
    stop("The exact weak-information registry and phase table are required.",
         call. = FALSE)
  }
  rows <- lapply(seq_len(nrow(phase_table)), function(index) {
    phase <- phase_table[index, , drop = FALSE]
    scenarios <- if (identical(
      phase$ScenarioProfile[[1L]], "baseline_three_controls"
    )) {
      paste0(
        "GT-WI-baseline_complete-",
        c("exact_zero", "numerical_near_zero", "reference_1200")
      )
    } else registry$Cells$ScenarioId
    cells <- registry$Cells[match(
      scenarios, registry$Cells$ScenarioId
    ), c("ScenarioId", "SeedStart"), drop = FALSE]
    replicates <- seq.int(
      phase$ReplicateStart[[1L]], phase$ReplicateEnd[[1L]]
    )
    grid <- expand.grid(
      ScenarioIndex = seq_len(nrow(cells)), Replicate = replicates,
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    data.frame(
      PhaseId = phase$PhaseId[[1L]],
      ScenarioId = cells$ScenarioId[grid$ScenarioIndex],
      Replicate = as.integer(grid$Replicate),
      SeedStart = cells$SeedStart[grid$ScenarioIndex],
      Seed = as.integer(
        cells$SeedStart[grid$ScenarioIndex] + grid$Replicate - 1L
      ),
      ExecutionAuthorized = phase$ExecutionAuthorized[[1L]],
      ReservedCalibrationUse =
        phase$PhaseId[[1L]] == "calibration_pilot",
      ConfirmationUse = phase$ConfirmationUse[[1L]],
      stringsAsFactors = FALSE
    )
  })
  ledger <- do.call(rbind, rows)
  row.names(ledger) <- NULL
  identity <- list(
    Contract = "weak_information_seed_ledger_b1g16_v1",
    RegistryHash = registry$RegistryHash,
    PhaseTableHash = mfrmr_gta_hash(phase_table),
    Rows = ledger
  )
  structure(c(identity, list(
    LedgerHash = mfrmr_gta_hash(identity),
    DatasetCount = nrow(ledger),
    UniqueSeedCount = length(unique(ledger$Seed)),
    CalibrationDatasetCount = sum(ledger$ReservedCalibrationUse),
    ConfirmationDatasetCount = sum(ledger$ConfirmationUse),
    ResponsesGenerated = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )), class = "mfrmr_gtwak_seed_ledger")
}

mfrmr_gtwak_seed_ledger_hash_valid <- function(ledger) {
  fields <- c("Contract", "RegistryHash", "PhaseTableHash", "Rows")
  inherits(ledger, "mfrmr_gtwak_seed_ledger") &&
    all(fields %in% names(ledger)) &&
    identical(ledger$LedgerHash, mfrmr_gta_hash(ledger[fields])) &&
    identical(ledger$DatasetCount, nrow(ledger$Rows)) &&
    identical(ledger$UniqueSeedCount,
              length(unique(ledger$Rows$Seed))) &&
    identical(ledger$CalibrationDatasetCount,
              sum(ledger$Rows$ReservedCalibrationUse)) &&
    identical(ledger$ConfirmationDatasetCount,
              sum(ledger$Rows$ConfirmationUse)) &&
    !isTRUE(ledger$ResponsesGenerated) &&
    !isTRUE(ledger$CalibrationResponsesUsed) &&
    !isTRUE(ledger$ConfirmationResponsesUsed)
}

mfrmr_gtwak_seed_audit <- function(ledger) {
  if (!mfrmr_gtwak_seed_ledger_hash_valid(ledger)) {
    stop("The exact b1g16 seed ledger is required.", call. = FALSE)
  }
  rows <- ledger$Rows
  phase_counts <- table(factor(
    rows$PhaseId,
    levels = c(
      "schema_smoke", "feasibility_pilot", "calibration_pilot",
      "confirmation"
    )
  ))
  phase_counts <- stats::setNames(
    as.integer(phase_counts), names(phase_counts)
  )
  expected <- c(
    schema_smoke = 6L, feasibility_pilot = 750L,
    calibration_pilot = 3000L, confirmation = 6000L
  )
  duplicate_seed_count <- sum(duplicated(rows$Seed))
  calibration <- rows[rows$ReservedCalibrationUse, , drop = FALSE]
  confirmation <- rows[rows$ConfirmationUse, , drop = FALSE]
  exact <- identical(phase_counts, expected) &&
    identical(nrow(rows), 9756L) && duplicate_seed_count == 0L &&
    identical(range(calibration$Replicate), c(201L, 300L)) &&
    identical(range(confirmation$Replicate), c(501L, 700L)) &&
    !any(calibration$ExecutionAuthorized) &&
    !any(confirmation$ExecutionAuthorized) &&
    length(intersect(calibration$Seed, confirmation$Seed)) == 0L
  identity <- list(
    Contract = "weak_information_seed_audit_b1g16_v1",
    SeedLedgerHash = ledger$LedgerHash,
    PhaseDatasetCounts = phase_counts,
    TotalDatasetCount = nrow(rows),
    UniqueSeedCount = length(unique(rows$Seed)),
    DuplicateSeedCount = duplicate_seed_count,
    MinimumSeed = min(rows$Seed),
    MaximumSeed = max(rows$Seed),
    CalibrationReplicateRange = range(calibration$Replicate),
    ConfirmationReplicateRange = range(confirmation$Replicate),
    CalibrationConfirmationSeedOverlap =
      length(intersect(calibration$Seed, confirmation$Seed)),
    CalibrationExecutionAuthorized = any(calibration$ExecutionAuthorized),
    ConfirmationExecutionAuthorized = any(confirmation$ExecutionAuthorized),
    ResponsesGenerated = FALSE
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    SeedLedgerExact = exact,
    SeedCollisionFree = duplicate_seed_count == 0L,
    PhaseBandsDisjoint =
      length(intersect(calibration$Seed, confirmation$Seed)) == 0L,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )), class = "mfrmr_gtwak_seed_audit")
}

mfrmr_gtwak_seed_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "SeedLedgerHash", "PhaseDatasetCounts",
    "TotalDatasetCount", "UniqueSeedCount", "DuplicateSeedCount",
    "MinimumSeed", "MaximumSeed", "CalibrationReplicateRange",
    "ConfirmationReplicateRange", "CalibrationConfirmationSeedOverlap",
    "CalibrationExecutionAuthorized", "ConfirmationExecutionAuthorized",
    "ResponsesGenerated"
  )
  exact <- inherits(audit, "mfrmr_gtwak_seed_audit") &&
    identical(audit$PhaseDatasetCounts, c(
      schema_smoke = 6L, feasibility_pilot = 750L,
      calibration_pilot = 3000L, confirmation = 6000L
    )) && identical(audit$TotalDatasetCount, 9756L) &&
    identical(audit$UniqueSeedCount, 9756L) &&
    identical(audit$DuplicateSeedCount, 0L) &&
    identical(audit$CalibrationReplicateRange, c(201L, 300L)) &&
    identical(audit$ConfirmationReplicateRange, c(501L, 700L)) &&
    identical(audit$CalibrationConfirmationSeedOverlap, 0L) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$ConfirmationExecutionAuthorized) &&
    !isTRUE(audit$ResponsesGenerated)
  inherits(audit, "mfrmr_gtwak_seed_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$SeedLedgerExact, exact) &&
    identical(audit$SeedCollisionFree, TRUE) &&
    identical(audit$PhaseBandsDisjoint, TRUE) &&
    !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
}

mfrmr_gtwak_rng_probe <- function(
    policy = mfrmr_gtwak_policy(), registry = mfrmr_gtw_registry()) {
  if (!mfrmr_gtwak_policy_hash_valid(policy) ||
      !inherits(registry, "mfrmr_gtw_registry")) {
    stop("The exact b1g16 policy and weak-information registry are required.",
         call. = FALSE)
  }
  replicate <- policy$NonreservedRNGProbeReplicate
  if (replicate %in% c(
    policy$ReservedCalibrationReplicates, policy$ConfirmationReplicates
  )) stop("The RNG probe must remain outside every reserved band.",
           call. = FALSE)
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
    )) rm(".Random.seed", envir = .GlobalEnv)
  }, add = TRUE)
  do.call(RNGkind, as.list(policy$RequiredRNGKind))
  required <- mfrmr_gtw_generate(
    registry, policy$NonreservedRNGProbeScenario, replicate
  )
  do.call(RNGkind, as.list(policy$AlternateRNGKindForNegativeControl))
  alternate <- mfrmr_gtw_generate(
    registry, policy$NonreservedRNGProbeScenario, replicate
  )
  generator_body <- paste(
    deparse(body(mfrmr_gtw_generate)), collapse = "\n"
  )
  compact_body <- gsub("[[:space:]]+", "", generator_body)
  explicit_kinds <- grepl("set.seed(seed,kind=", compact_body, fixed = TRUE) &&
    grepl("normal.kind=", compact_body, fixed = TRUE) &&
    grepl("sample.kind=", compact_body, fixed = TRUE)
  rng_identity_recorded <- grepl("RNGKind", generator_body, fixed = TRUE)
  data_equal <- identical(
    required$AnalysisData$Score, alternate$AnalysisData$Score
  )
  identity <- list(
    Contract = "ambient_rng_negative_control_b1g16_v1",
    PolicyHash = policy$PolicyHash,
    RegistryHash = registry$RegistryHash,
    ScenarioId = policy$NonreservedRNGProbeScenario,
    Replicate = replicate,
    Seed = required$Seed,
    RequiredRNGKind = policy$RequiredRNGKind,
    AlternateRNGKind = policy$AlternateRNGKindForNegativeControl,
    RequiredGeneratorHash = required$GeneratorHash,
    AlternateGeneratorHash = alternate$GeneratorHash,
    RequiredScoreHash = mfrmr_gta_hash(required$AnalysisData$Score),
    AlternateScoreHash = mfrmr_gta_hash(alternate$AnalysisData$Score),
    DataHashEqualAcrossAmbientRNGKinds = data_equal,
    GeneratorCallsSetSeedWithExplicitKinds = explicit_kinds,
    GeneratorIdentityRecordsRNGKind = rng_identity_recorded,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    ProbeHash = mfrmr_gta_hash(identity),
    AmbientRNGAffectsGeneration = !data_equal,
    GeneratorRNGSelfContained =
      explicit_kinds && rng_identity_recorded && data_equal,
    ReservedResponseOpened = FALSE
  )), class = "mfrmr_gtwak_rng_probe")
}

mfrmr_gtwak_rng_probe_hash_valid <- function(probe) {
  fields <- c(
    "Contract", "PolicyHash", "RegistryHash", "ScenarioId", "Replicate",
    "Seed", "RequiredRNGKind", "AlternateRNGKind",
    "RequiredGeneratorHash", "AlternateGeneratorHash",
    "RequiredScoreHash", "AlternateScoreHash",
    "DataHashEqualAcrossAmbientRNGKinds",
    "GeneratorCallsSetSeedWithExplicitKinds",
    "GeneratorIdentityRecordsRNGKind", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  inherits(probe, "mfrmr_gtwak_rng_probe") &&
    all(fields %in% names(probe)) &&
    identical(probe$ProbeHash, mfrmr_gta_hash(probe[fields])) &&
    identical(probe$AmbientRNGAffectsGeneration,
              !probe$DataHashEqualAcrossAmbientRNGKinds) &&
    identical(probe$GeneratorRNGSelfContained,
              probe$GeneratorCallsSetSeedWithExplicitKinds &&
                probe$GeneratorIdentityRecordsRNGKind &&
                probe$DataHashEqualAcrossAmbientRNGKinds) &&
    !isTRUE(probe$ReservedResponseOpened) &&
    !isTRUE(probe$CalibrationResponsesUsed) &&
    !isTRUE(probe$ConfirmationResponsesUsed)
}

mfrmr_gtwak_contract <- function(authorization_preflight_contract,
                                   shard_bundle, value_contract,
                                   value_audit) {
  mfrmr_gtwak_require_primitives()
  if (!mfrmr_gtwai_contract_hash_valid(authorization_preflight_contract) ||
      !identical(
        authorization_preflight_contract$ContractHash,
        "44a6d4e2677af111e6eeeae8b7b3143ce8521db34da1769a86b85f32c63ca551"
      ) || !mfrmr_gtwai_shard_bundle_hash_valid(shard_bundle) ||
      !identical(
        shard_bundle$BundleHash,
        "dfd5099b84dc8ff64b605261d957173e63b8b04645b1f90cc7262b8120d54e82"
      ) || !mfrmr_gtwaj_contract_hash_valid(value_contract) ||
      !mfrmr_gtwaj_audit_hash_valid(value_audit) ||
      !identical(value_contract$ContractHash,
                 "9695149f99885bd4647c40466fef37e99cf321aa7786e232476586730f4fa1d8") ||
      !identical(value_audit$AuditHash,
                 "67987463d2fa587441714da5b6a8fc9046f6c2cc3ec604a416a264762d868f45") ||
      isTRUE(authorization_preflight_contract$CalibrationExecutionAuthorized) ||
      isTRUE(shard_bundle$ExecutionAuthorized) ||
      isTRUE(value_audit$CalibrationExecutionAuthorized)) {
    stop("Exact non-authorizing b1g15/b1g15a artifacts are required.",
         call. = FALSE)
  }
  policy <- mfrmr_gtwak_policy()
  runtime <- mfrmr_gtwak_runtime_identity()
  upstream_runtime_fields <- names(
    authorization_preflight_contract$Runtime
  )
  required_extended_fields <- c(
    "RNGKind", "MatrixProducts", "BLAS", "LAPACK", "LAVersion",
    "Locale", "TimeZone", "GLMMTMBParallel", "ThreadEnvironment"
  )
  shard_counts <- c(
    Shards = shard_bundle$ShardCount,
    Datasets = shard_bundle$DatasetCount,
    AtomicUnits = shard_bundle$AtomicUnitCount,
    CandidateFits = shard_bundle$CandidateFitRowCount,
    CandidateDecisions = shard_bundle$CandidateDecisionRowCount,
    References = shard_bundle$ReferenceRowCount
  )
  expected_shard_counts <- c(
    Shards = 100L, Datasets = 3000L, AtomicUnits = 12000L,
    CandidateFits = 108000L, CandidateDecisions = 576000L,
    References = 24000L
  )
  identity <- list(
    Contract = "preactivation_hardening_contract_b1g16_v1",
    UpstreamAuthorizationPreflightContractHash =
      authorization_preflight_contract$ContractHash,
    UpstreamShardBundleHash = shard_bundle$BundleHash,
    UpstreamMonteCarloValueContractHash = value_contract$ContractHash,
    UpstreamMonteCarloValueAuditHash = value_audit$AuditHash,
    UpstreamRuntimeHash =
      authorization_preflight_contract$UpstreamRuntimeHash,
    UpstreamRuntimeFields = upstream_runtime_fields,
    RequiredExtendedRuntimeFields = required_extended_fields,
    MissingUpstreamRuntimeFields = setdiff(
      required_extended_fields, upstream_runtime_fields
    ),
    ShardCounts = shard_counts,
    ExpectedShardCounts = expected_shard_counts,
    UpstreamCompleteFailureAccountingRequired =
      authorization_preflight_contract$CompleteFailureAccountingRequired,
    UpstreamFailedFitRowsRetained =
      authorization_preflight_contract$Policy$FailedFitRowsRetained,
    UpstreamFailedReferenceRowsRetained =
      authorization_preflight_contract$Policy$FailedReferenceRowsRetained,
    Policy = policy,
    GeneratorFunctionHash =
      mfrmr_gtwak_function_hash(mfrmr_gtw_generate),
    ExistingRunnerFunctionHash =
      mfrmr_gtwak_function_hash(mfrmr_gtwag_execute),
    Sources = mfrmr_gtwak_source_registry(),
    FunctionHashes = mfrmr_gtwak_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    ObservedExtendedRuntime = runtime,
    PreactivationHardeningContractFrozen = TRUE,
    PriorB1g15ReadinessPreservedAsHistoricalEvidence = TRUE,
    StrongerActivationRequirementsAdded = TRUE,
    ExtendedRuntimeIdentityBoundUpstream =
      length(identity$MissingUpstreamRuntimeFields) == 0L,
    ExecutionAuthorizationRecordIssued = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwak_contract")
}

mfrmr_gtwak_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "UpstreamAuthorizationPreflightContractHash",
    "UpstreamShardBundleHash", "UpstreamMonteCarloValueContractHash",
    "UpstreamMonteCarloValueAuditHash", "UpstreamRuntimeHash",
    "UpstreamRuntimeFields", "RequiredExtendedRuntimeFields",
    "MissingUpstreamRuntimeFields", "ShardCounts", "ExpectedShardCounts",
    "UpstreamCompleteFailureAccountingRequired",
    "UpstreamFailedFitRowsRetained", "UpstreamFailedReferenceRowsRetained",
    "Policy",
    "GeneratorFunctionHash", "ExistingRunnerFunctionHash", "Sources",
    "FunctionHashes"
  )
  inherits(contract, "mfrmr_gtwak_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwak_policy_hash_valid(contract$Policy) &&
    mfrmr_gtwak_runtime_hash_valid(contract$ObservedExtendedRuntime) &&
    identical(contract$ExtendedRuntimeIdentityBoundUpstream,
              length(contract$MissingUpstreamRuntimeFields) == 0L) &&
    isTRUE(contract$PreactivationHardeningContractFrozen) &&
    isTRUE(contract$PriorB1g15ReadinessPreservedAsHistoricalEvidence) &&
    isTRUE(contract$StrongerActivationRequirementsAdded) &&
    !isTRUE(contract$ExecutionAuthorizationRecordIssued) &&
    !isTRUE(contract$CalibrationAuthorizationReady) &&
    !isTRUE(contract$CalibrationExecutionAuthorized) &&
    !isTRUE(contract$CalibrationDataGenerated) &&
    !isTRUE(contract$CalibrationResultsViewed) &&
    !isTRUE(contract$ConfirmationAuthorized) &&
    !isTRUE(contract$InferenceReady) && !isTRUE(contract$DecisionReady)
}

mfrmr_gtwak_gate_registry <- function(contract, seed_audit, rng_probe) {
  if (!mfrmr_gtwak_contract_hash_valid(contract) ||
      !mfrmr_gtwak_seed_audit_hash_valid(seed_audit) ||
      !mfrmr_gtwak_rng_probe_hash_valid(rng_probe)) {
    stop("Exact b1g16 contract, seed audit, and RNG probe are required.",
         call. = FALSE)
  }
  runtime <- contract$ObservedExtendedRuntime
  policy <- contract$Policy
  runner_body <- paste(deparse(body(mfrmr_gtwag_execute)), collapse = "\n")
  generator_ready <- isTRUE(rng_probe$GeneratorRNGSelfContained)
  runtime_ready <- isTRUE(contract$ExtendedRuntimeIdentityBoundUpstream)
  shard_ready <- identical(
    contract$ShardCounts, contract$ExpectedShardCounts
  )
  denominator_ready <-
    isTRUE(contract$UpstreamCompleteFailureAccountingRequired) &&
    isTRUE(contract$UpstreamFailedFitRowsRetained) &&
    isTRUE(contract$UpstreamFailedReferenceRowsRetained)
  thread_ready <- identical(
    runtime$GLMMTMBParallel, policy$RequiredGLMMTMBParallel
  ) && identical(
    runtime$ThreadEnvironment, policy$RequiredThreadEnvironment
  )
  authorized_runner_exists <- grepl(
    "CalibrationExecutionAuthorized", runner_body, fixed = TRUE
  ) && !grepl(
    "Only the exact nonreserved b1g13 mechanics run is authorized",
    runner_body, fixed = TRUE
  )
  data.frame(
    GateId = c(
      "SEED-01", "SHARD-01", "DENOMINATOR-01", "CONFIRM-01",
      "RNG-01", "RUNTIME-01", "THREAD-01", "PROCESS-01",
      "RUNNER-01", "LOCK-01", "ROOT-01", "CAPACITY-01"
    ),
    Gate = c(
      "phase seed ledger has no collisions",
      "prospective shards exactly partition the reserved workload",
      "failed fits and unresolved references remain in denominators",
      "confirmation remains inaccessible",
      "generator fixes and records uniform normal and sample RNG kinds",
      "authorization binds extended runtime identity",
      "backend and numerical-library thread state is explicitly serial",
      "execution uses a vanilla isolated child R process",
      "a reserved-only authorized shard runner exists",
      "an exclusive single-writer lock rejects concurrent execution",
      "atomic activation marker distinguishes first activation from resume",
      "filesystem behavior and remaining capacity are rechecked per shard"
    ),
    RequiredBeforeAuthorization = TRUE,
    ObservedPass = c(
      seed_audit$SeedLedgerExact,
      shard_ready,
      denominator_ready,
      !policy$ConfirmationAccessPermitted,
      generator_ready,
      runtime_ready,
      thread_ready,
      FALSE,
      authorized_runner_exists,
      FALSE,
      FALSE,
      FALSE
    ),
    Evidence = c(
      seed_audit$AuditHash,
      contract$UpstreamShardBundleHash,
      contract$UpstreamAuthorizationPreflightContractHash,
      policy$PolicyHash,
      rng_probe$ProbeHash,
      contract$UpstreamRuntimeHash,
      runtime$RuntimeHash,
      policy$RequiredProcessInvocation,
      contract$ExistingRunnerFunctionHash,
      "no_lock_primitive_in_current_reserved_execution_path",
      "no_activation_marker_or_typed_resume_root_contract",
      "b1g15_site_probe_is_preflight_only_not_per_shard"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwak_audit <- function(contract,
                               registry = mfrmr_gtw_registry(),
                               phase_table = mfrmr_gtwp_phase_table()) {
  if (!mfrmr_gtwak_contract_hash_valid(contract)) {
    stop("The exact b1g16 hardening contract is required.", call. = FALSE)
  }
  ledger <- mfrmr_gtwak_seed_ledger(registry, phase_table)
  seed_audit <- mfrmr_gtwak_seed_audit(ledger)
  rng_probe <- mfrmr_gtwak_rng_probe(contract$Policy, registry)
  gates <- mfrmr_gtwak_gate_registry(contract, seed_audit, rng_probe)
  blockers <- gates[
    gates$RequiredBeforeAuthorization & !gates$ObservedPass, , drop = FALSE
  ]
  identity <- list(
    Contract = "preactivation_hardening_audit_b1g16_v1",
    PreactivationHardeningContractHash = contract$ContractHash,
    SeedLedgerHash = ledger$LedgerHash,
    SeedAuditHash = seed_audit$AuditHash,
    RNGProbeHash = rng_probe$ProbeHash,
    ExtendedRuntimeHash = contract$ObservedExtendedRuntime$RuntimeHash,
    GateRegistry = gates,
    BlockerIds = blockers$GateId,
    BlockerCount = nrow(blockers),
    SeedLedgerExact = seed_audit$SeedLedgerExact,
    SeedCollisionFree = seed_audit$SeedCollisionFree,
    AmbientRNGAffectsGeneration = rng_probe$AmbientRNGAffectsGeneration,
    GeneratorRNGSelfContained = rng_probe$GeneratorRNGSelfContained,
    ExtendedRuntimeIdentityBoundUpstream =
      contract$ExtendedRuntimeIdentityBoundUpstream,
    CurrentGLMMTMBSerialObserved = identical(
      contract$ObservedExtendedRuntime$GLMMTMBParallel,
      contract$Policy$RequiredGLMMTMBParallel
    ),
    CurrentThreadEnvironmentExplicitlySerial = identical(
      contract$ObservedExtendedRuntime$ThreadEnvironment,
      contract$Policy$RequiredThreadEnvironment
    ),
    PriorB1g15ActivationEligibilitySuperseded = TRUE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  audit_ready <- isTRUE(seed_audit$SeedLedgerExact) &&
    isTRUE(rng_probe$AmbientRNGAffectsGeneration) && nrow(gates) == 12L &&
    nrow(blockers) > 0L
  activation_ready <- audit_ready && nrow(blockers) == 0L
  decision_identity <- list(
    Contract = identity$Contract,
    PreactivationHardeningContractHash = contract$ContractHash,
    SeedAuditHash = seed_audit$AuditHash,
    RNGProbeHash = rng_probe$ProbeHash,
    BlockerIds = blockers$GateId,
    BlockerCount = nrow(blockers),
    SeedLedgerExact = seed_audit$SeedLedgerExact,
    AmbientRNGAffectsGeneration = rng_probe$AmbientRNGAffectsGeneration,
    GeneratorRNGSelfContained = rng_probe$GeneratorRNGSelfContained,
    ExtendedRuntimeIdentityBoundUpstream =
      contract$ExtendedRuntimeIdentityBoundUpstream,
    PriorB1g15ActivationEligibilitySuperseded = TRUE,
    AuthorizationActivationEligible = activation_ready,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    DecisionHash = mfrmr_gta_hash(decision_identity),
    PreactivationHardeningAuditReady = audit_ready,
    AuthorizationActivationEligible = activation_ready,
    LargeSimulationMayStart = activation_ready,
    Replicate201MayBeOpened = activation_ready,
    ExecutionAuthorizationRecordIssued = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwak_audit")
}

mfrmr_gtwak_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "PreactivationHardeningContractHash", "SeedLedgerHash",
    "SeedAuditHash", "RNGProbeHash", "ExtendedRuntimeHash",
    "GateRegistry", "BlockerIds", "BlockerCount", "SeedLedgerExact",
    "SeedCollisionFree", "AmbientRNGAffectsGeneration",
    "GeneratorRNGSelfContained", "ExtendedRuntimeIdentityBoundUpstream",
    "CurrentGLMMTMBSerialObserved",
    "CurrentThreadEnvironmentExplicitlySerial",
    "PriorB1g15ActivationEligibilitySuperseded",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  blockers <- if (inherits(audit, "mfrmr_gtwak_audit") &&
      is.data.frame(audit$GateRegistry)) {
    audit$GateRegistry[
      audit$GateRegistry$RequiredBeforeAuthorization &
        !audit$GateRegistry$ObservedPass, , drop = FALSE
    ]
  } else data.frame()
  audit_ready <- inherits(audit, "mfrmr_gtwak_audit") &&
    isTRUE(audit$SeedLedgerExact) && isTRUE(audit$SeedCollisionFree) &&
    isTRUE(audit$AmbientRNGAffectsGeneration) &&
    identical(nrow(audit$GateRegistry), 12L) && nrow(blockers) > 0L &&
    identical(audit$BlockerIds, blockers$GateId) &&
    identical(audit$BlockerCount, nrow(blockers)) &&
    isTRUE(audit$PriorB1g15ActivationEligibilitySuperseded) &&
    !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
  activation_ready <- audit_ready && nrow(blockers) == 0L
  decision_fields <- c(
    "Contract", "PreactivationHardeningContractHash", "SeedAuditHash",
    "RNGProbeHash", "BlockerIds", "BlockerCount", "SeedLedgerExact",
    "AmbientRNGAffectsGeneration", "GeneratorRNGSelfContained",
    "ExtendedRuntimeIdentityBoundUpstream",
    "PriorB1g15ActivationEligibilitySuperseded",
    "AuthorizationActivationEligible", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  inherits(audit, "mfrmr_gtwak_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$DecisionHash, mfrmr_gta_hash(audit[decision_fields])) &&
    identical(audit$PreactivationHardeningAuditReady, audit_ready) &&
    identical(audit$AuthorizationActivationEligible, activation_ready) &&
    identical(audit$LargeSimulationMayStart, activation_ready) &&
    identical(audit$Replicate201MayBeOpened, activation_ready) &&
    !isTRUE(audit$ExecutionAuthorizationRecordIssued) &&
    !isTRUE(audit$CalibrationAuthorizationReady) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed) &&
    !isTRUE(audit$ConfirmationAuthorized) &&
    !isTRUE(audit$InferenceReady) && !isTRUE(audit$DecisionReady)
}

mfrmr_gtwak_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwak_source_registry", "mfrmr_gtwak_policy",
    "mfrmr_gtwak_policy_hash_valid", "mfrmr_gtwak_runtime_identity",
    "mfrmr_gtwak_runtime_hash_valid", "mfrmr_gtwak_seed_ledger",
    "mfrmr_gtwak_seed_ledger_hash_valid", "mfrmr_gtwak_seed_audit",
    "mfrmr_gtwak_seed_audit_hash_valid", "mfrmr_gtwak_rng_probe",
    "mfrmr_gtwak_rng_probe_hash_valid", "mfrmr_gtwak_contract",
    "mfrmr_gtwak_contract_hash_valid", "mfrmr_gtwak_gate_registry",
    "mfrmr_gtwak_audit", "mfrmr_gtwak_audit_hash_valid"
  )
  audit_environment <- environment(mfrmr_gtwak_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwak_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
