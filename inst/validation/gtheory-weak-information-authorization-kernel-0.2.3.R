# Draft.83d2b2b1g20 reusable response-free authorization kernel.
#
# This is infrastructure shared by future calibration shards. It validates an
# isolated runtime, an atomic lock/root lifecycle, and a fresh site-capacity
# probe. It cannot generate responses or issue an authorization record.

mfrmr_gtwao_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash",
    "mfrmr_gtwan_contract_hash_valid",
    "mfrmr_gtwan_reserved_manifest_hash_valid",
    "mfrmr_gtwan_shard_bundle_hash_valid", "mfrmr_gtwan_audit_hash_valid"
  )
  audit_environment <- environment(mfrmr_gtwao_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g19 chain before the b1g20 authorization kernel: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwao_parse_df <- function(output) {
  output <- as.character(output)
  output <- output[nzchar(trimws(output))]
  if (length(output) < 2L) stop("`df -Pk` output is incomplete.",
                                call. = FALSE)
  tokens <- strsplit(trimws(tail(output, 1L)), "[[:space:]]+")[[1L]]
  numeric_tokens <- suppressWarnings(as.numeric(tokens[2:4]))
  if (length(tokens) < 6L || anyNA(numeric_tokens) ||
      any(numeric_tokens < 0)) {
    stop("`df -Pk` output is malformed.", call. = FALSE)
  }
  list(
    AvailableKiB = numeric_tokens[[3L]], Filesystem = tokens[[1L]],
    MountPoint = paste(tokens[6:length(tokens)], collapse = " ")
  )
}

mfrmr_gtwao_sha256_file <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  unname(digest::digest(file = path, algo = "sha256", serialize = FALSE))
}

mfrmr_gtwao_lineage_receipt <- function() {
  identity <- list(
    Contract = "hardened_reserved_lineage_receipt_b1g20_v1",
    LineageContractHash =
      "5075f23a5af8edb7d77ff3cd4c4efaad4d7a624995c3ee04a62ed04a2bee49f5",
    ReservedManifestHash =
      "da3905e9b9a605f42e877f695226a0c5ee7089cc04f68ad7ee6350de25c9cbd6",
    ShardBundleHash =
      "634159d6d85ea04ecf9447330af122c01284644211aa2dd78d85ab34a92661df",
    LineageAuditHash =
      "9bc4d4dafbeec602f7718c7249bf15f4aeb5a6dbd5862b46e4d8889dc2540d7a",
    HardenedAdapterContractHash =
      "0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64",
    HardenedGeneratorContractHash =
      "90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2",
    OutputRoot =
      "validation-results/gtheory-stationarity-calibration-draft83d2b2b1g19",
    ReservedManifestRebaseReady = TRUE,
    ExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    ConfirmationAuthorized = FALSE
  )
  structure(c(identity, list(
    ReceiptHash = mfrmr_gta_hash(identity), ReceiptFrozen = TRUE
  )), class = "mfrmr_gtwao_lineage_receipt")
}

mfrmr_gtwao_lineage_receipt_hash_valid <- function(receipt) {
  expected <- mfrmr_gtwao_lineage_receipt()
  fields <- setdiff(names(expected), c("ReceiptHash", "ReceiptFrozen"))
  inherits(receipt, "mfrmr_gtwao_lineage_receipt") &&
    all(fields %in% names(receipt)) &&
    identical(receipt$ReceiptHash, mfrmr_gta_hash(receipt[fields])) &&
    identical(receipt$ReceiptHash, expected$ReceiptHash) &&
    identical(receipt[fields], expected[fields]) &&
    isTRUE(receipt$ReceiptFrozen) &&
    isTRUE(receipt$ReservedManifestRebaseReady) &&
    !isTRUE(receipt$ExecutionAuthorized) &&
    !isTRUE(receipt$CalibrationDataGenerated) &&
    !isTRUE(receipt$ConfirmationAuthorized)
}

mfrmr_gtwao_policy <- function() {
  thread_variables <- c(
    "OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
    "VECLIB_MAXIMUM_THREADS", "BLIS_NUM_THREADS"
  )
  identity <- list(
    Contract = "authorization_kernel_policy_b1g20_v1",
    WorkerSourceHash =
      "6c1138afe41995a7a14fdb1fa6bf91e62cc4b667187a18f21bdf2a52860959f0",
    RequiredInvocationFlag = "--vanilla",
    RequiredRNGKind = c("Mersenne-Twister", "Inversion", "Rejection"),
    RequiredGLMMTMBParallel = list(n = 1L, autopar = FALSE),
    RequiredThreadEnvironment = stats::setNames(
      rep("1", length(thread_variables)), thread_variables
    ),
    RequiredLocaleEnvironment = c(LC_ALL = "C", TZ = "UTC"),
    RequiredStartupEnvironment = c(
      R_ENVIRON_USER = "/dev/null", R_PROFILE_USER = "/dev/null"
    ),
    ObservedStartupEnvironmentAfterVanilla = c(
      R_ENVIRON_USER = "", R_PROFILE_USER = ""
    ),
    RequiredAvailableBytes = 47775834368,
    MaximumConcurrentShards = 1L,
    LockDirectorySuffix = ".mfrmr-lock",
    ActivationMarkerName = "activation-marker.rds",
    StaleLockTakeoverAutomatic = FALSE,
    ExistingUnmarkedRootPermitted = FALSE,
    ResponseGenerationPermitted = FALSE,
    ModelFittingPermitted = FALSE,
    AuthorizationRecordIssuancePermitted = FALSE,
    ConfirmationAccessPermitted = FALSE,
    EarlyStoppingPermitted = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwao_policy")
}

mfrmr_gtwao_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwao_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity)) &&
    identical(policy$RequiredInvocationFlag, "--vanilla") &&
    identical(policy$RequiredRNGKind,
              c("Mersenne-Twister", "Inversion", "Rejection")) &&
    identical(policy$MaximumConcurrentShards, 1L) &&
    !isTRUE(policy$StaleLockTakeoverAutomatic) &&
    !isTRUE(policy$ExistingUnmarkedRootPermitted) &&
    !isTRUE(policy$ResponseGenerationPermitted) &&
    !isTRUE(policy$ModelFittingPermitted) &&
    !isTRUE(policy$AuthorizationRecordIssuancePermitted) &&
    !isTRUE(policy$ConfirmationAccessPermitted) &&
    !isTRUE(policy$EarlyStoppingPermitted)
}

mfrmr_gtwao_contract <- function(lineage_contract, reserved_manifest,
                                  shard_bundle, lineage_audit, worker_path) {
  mfrmr_gtwao_require_primitives()
  receipt <- mfrmr_gtwao_lineage_receipt()
  policy <- mfrmr_gtwao_policy()
  worker_hash <- mfrmr_gtwao_sha256_file(worker_path)
  if (!mfrmr_gtwan_contract_hash_valid(lineage_contract) ||
      !mfrmr_gtwan_reserved_manifest_hash_valid(reserved_manifest) ||
      !mfrmr_gtwan_shard_bundle_hash_valid(shard_bundle) ||
      !mfrmr_gtwan_audit_hash_valid(lineage_audit) ||
      !identical(lineage_contract$ContractHash,
                 receipt$LineageContractHash) ||
      !identical(reserved_manifest$ManifestHash,
                 receipt$ReservedManifestHash) ||
      !identical(shard_bundle$BundleHash, receipt$ShardBundleHash) ||
      !identical(lineage_audit$AuditHash, receipt$LineageAuditHash) ||
      !identical(worker_hash, policy$WorkerSourceHash)) {
    stop("Exact b1g19 lineage and b1g20 worker evidence is required.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "authorization_kernel_contract_b1g20_v1",
    KernelPolicy = policy,
    LineageReceipt = receipt,
    WorkerFileName = basename(worker_path),
    WorkerSourceHash = worker_hash,
    LineageContractHash = lineage_contract$ContractHash,
    ReservedManifestHash = reserved_manifest$ManifestHash,
    ShardBundleHash = shard_bundle$BundleHash,
    LineageAuditHash = lineage_audit$AuditHash,
    HardenedAdapterContractHash =
      lineage_contract$HardenedAdapterContractHash,
    HardenedGeneratorContractHash =
      lineage_contract$HardenedGeneratorContractHash,
    OutputRoot = reserved_manifest$OutputRoot
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    AuthorizationKernelContractFrozen = TRUE,
    ResponseFreeConstruction = TRUE,
    RuntimeContractExtensionReady = FALSE,
    LockRootKernelReady = FALSE,
    PerShardSitePreflightReady = FALSE,
    AuthorizedSingleShardRunnerReady = FALSE,
    AuthorizationRecordIssued = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwao_contract")
}

mfrmr_gtwao_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "KernelPolicy", "LineageReceipt", "WorkerFileName",
    "WorkerSourceHash", "LineageContractHash", "ReservedManifestHash",
    "ShardBundleHash", "LineageAuditHash", "HardenedAdapterContractHash",
    "HardenedGeneratorContractHash", "OutputRoot"
  )
  inherits(contract, "mfrmr_gtwao_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwao_policy_hash_valid(contract$KernelPolicy) &&
    mfrmr_gtwao_lineage_receipt_hash_valid(contract$LineageReceipt) &&
    identical(contract$WorkerSourceHash,
              contract$KernelPolicy$WorkerSourceHash) &&
    isTRUE(contract$AuthorizationKernelContractFrozen) &&
    isTRUE(contract$ResponseFreeConstruction) &&
    !isTRUE(contract$RuntimeContractExtensionReady) &&
    !isTRUE(contract$LockRootKernelReady) &&
    !isTRUE(contract$PerShardSitePreflightReady) &&
    !isTRUE(contract$AuthorizedSingleShardRunnerReady) &&
    !isTRUE(contract$AuthorizationRecordIssued) &&
    !isTRUE(contract$CalibrationExecutionAuthorized) &&
    !isTRUE(contract$CalibrationDataGenerated) &&
    !isTRUE(contract$CalibrationResultsViewed) &&
    !isTRUE(contract$ConfirmationAuthorized) &&
    !isTRUE(contract$InferenceReady) && !isTRUE(contract$DecisionReady)
}

mfrmr_gtwao_child_runtime_hash_valid <- function(runtime) {
  fields <- c(
    "Contract", "Invocation", "RVersion", "RPlatform", "RArch", "OS",
    "OSRelease", "RNGKind", "MatrixProducts", "BLAS", "LAPACK",
    "LAVersion", "Locale", "TimeZone", "LocaleEnvironment",
    "StartupEnvironment", "PackageVersions", "GLMMTMBParallel",
    "ThreadEnvironment"
  )
  inherits(runtime, "mfrmr_gtwao_child_runtime") &&
    all(fields %in% names(runtime)) &&
    identical(runtime$RuntimeHash, mfrmr_gta_hash(runtime[fields]))
}

mfrmr_gtwao_isolated_runtime_probe <- function(contract, worker_path) {
  if (!mfrmr_gtwao_contract_hash_valid(contract) ||
      !identical(mfrmr_gtwao_sha256_file(worker_path),
                 contract$WorkerSourceHash)) {
    stop("The exact b1g20 contract and worker are required.", call. = FALSE)
  }
  policy <- contract$KernelPolicy
  output <- tempfile("mfrmr-gtwao-runtime-", fileext = ".rds")
  on.exit(if (file.exists(output)) unlink(output), add = TRUE)
  environment <- c(
    policy$RequiredThreadEnvironment,
    policy$RequiredLocaleEnvironment,
    policy$RequiredStartupEnvironment
  )
  process_output <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(normalizePath(
      worker_path, winslash = "/", mustWork = TRUE
    )), "--runtime-probe", shQuote(output)),
    env = paste0(names(environment), "=", unname(environment)),
    stdout = TRUE, stderr = TRUE
  ))
  status <- attr(process_output, "status")
  status <- if (is.null(status)) 0L else as.integer(status)
  runtime <- if (identical(status, 0L) && file.exists(output)) {
    tryCatch(readRDS(output), error = function(error) NULL)
  } else NULL
  runtime_valid <- !is.null(runtime) &&
    mfrmr_gtwao_child_runtime_hash_valid(runtime)
  runtime_ready <- runtime_valid &&
    identical(runtime$RNGKind, policy$RequiredRNGKind) &&
    identical(runtime$GLMMTMBParallel,
              policy$RequiredGLMMTMBParallel) &&
    identical(runtime$ThreadEnvironment,
              policy$RequiredThreadEnvironment) &&
    identical(runtime$LocaleEnvironment,
              policy$RequiredLocaleEnvironment) &&
    identical(runtime$StartupEnvironment,
              policy$ObservedStartupEnvironmentAfterVanilla) &&
    identical(runtime$TimeZone, "UTC") &&
    policy$RequiredInvocationFlag %in% runtime$Invocation
  identity <- list(
    Contract = "isolated_runtime_preflight_b1g20_v1",
    AuthorizationKernelContractHash = contract$ContractHash,
    WorkerSourceHash = contract$WorkerSourceHash,
    ChildExitStatus = status,
    ChildOutputHash = mfrmr_gta_hash(process_output),
    ChildRuntimeHash = if (runtime_valid) runtime$RuntimeHash else "invalid",
    RuntimeRecordValid = runtime_valid,
    RNGKindExact = runtime_valid &&
      identical(runtime$RNGKind, policy$RequiredRNGKind),
    GLMMTMBSerialExact = runtime_valid &&
      identical(runtime$GLMMTMBParallel,
                policy$RequiredGLMMTMBParallel),
    ThreadEnvironmentExact = runtime_valid &&
      identical(runtime$ThreadEnvironment,
                policy$RequiredThreadEnvironment),
    LocaleEnvironmentExact = runtime_valid &&
      identical(runtime$LocaleEnvironment,
                policy$RequiredLocaleEnvironment),
    StartupEnvironmentSuppressed = runtime_valid &&
      identical(runtime$StartupEnvironment,
                policy$ObservedStartupEnvironmentAfterVanilla),
    VanillaInvocationObserved = runtime_valid &&
      policy$RequiredInvocationFlag %in% runtime$Invocation,
    IsolatedRuntimeReady = runtime_ready,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    ProbeHash = mfrmr_gta_hash(identity), Runtime = runtime,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwao_runtime_probe")
}

mfrmr_gtwao_runtime_probe_hash_valid <- function(probe) {
  fields <- c(
    "Contract", "AuthorizationKernelContractHash", "WorkerSourceHash",
    "ChildExitStatus", "ChildOutputHash", "ChildRuntimeHash",
    "RuntimeRecordValid", "RNGKindExact", "GLMMTMBSerialExact",
    "ThreadEnvironmentExact", "LocaleEnvironmentExact",
    "StartupEnvironmentSuppressed", "VanillaInvocationObserved",
    "IsolatedRuntimeReady", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  expected_rng <- c("Mersenne-Twister", "Inversion", "Rejection")
  thread_names <- c(
    "OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
    "VECLIB_MAXIMUM_THREADS", "BLIS_NUM_THREADS"
  )
  expected_threads <- stats::setNames(rep("1", 5L), thread_names)
  runtime_valid <- inherits(probe, "mfrmr_gtwao_runtime_probe") &&
    mfrmr_gtwao_child_runtime_hash_valid(probe$Runtime) &&
    identical(probe$ChildRuntimeHash, probe$Runtime$RuntimeHash)
  rng_exact <- runtime_valid && identical(probe$Runtime$RNGKind, expected_rng)
  glmm_exact <- runtime_valid && identical(
    probe$Runtime$GLMMTMBParallel, list(n = 1L, autopar = FALSE)
  )
  thread_exact <- runtime_valid && identical(
    probe$Runtime$ThreadEnvironment, expected_threads
  )
  locale_exact <- runtime_valid && identical(
    probe$Runtime$LocaleEnvironment, c(LC_ALL = "C", TZ = "UTC")
  )
  startup_suppressed <- runtime_valid && identical(
    probe$Runtime$StartupEnvironment,
    c(R_ENVIRON_USER = "", R_PROFILE_USER = "")
  )
  vanilla <- runtime_valid && "--vanilla" %in% probe$Runtime$Invocation
  ready <- runtime_valid && all(c(
    rng_exact, glmm_exact, thread_exact, locale_exact,
    startup_suppressed, vanilla
  )) && identical(probe$ChildExitStatus, 0L)
  inherits(probe, "mfrmr_gtwao_runtime_probe") &&
    all(fields %in% names(probe)) &&
    identical(probe$ProbeHash, mfrmr_gta_hash(probe[fields])) &&
    identical(probe$RuntimeRecordValid, runtime_valid) &&
    identical(probe$RNGKindExact, rng_exact) &&
    identical(probe$GLMMTMBSerialExact, glmm_exact) &&
    identical(probe$ThreadEnvironmentExact, thread_exact) &&
    identical(probe$LocaleEnvironmentExact, locale_exact) &&
    identical(probe$StartupEnvironmentSuppressed, startup_suppressed) &&
    identical(probe$VanillaInvocationObserved, vanilla) &&
    identical(probe$IsolatedRuntimeReady, ready) &&
    !isTRUE(probe$CalibrationExecutionAuthorized) &&
    !isTRUE(probe$CalibrationDataGenerated) &&
    !isTRUE(probe$CalibrationResultsViewed) &&
    !isTRUE(probe$CalibrationResponsesUsed) &&
    !isTRUE(probe$ConfirmationResponsesUsed)
}

mfrmr_gtwao_safe_target <- function(target) {
  target <- as.character(target)
  if (length(target) != 1L || is.na(target) || !nzchar(target)) {
    stop("One target path is required.", call. = FALSE)
  }
  parent <- dirname(target)
  if (!dir.exists(parent)) stop("The target parent must exist.", call. = FALSE)
  parent <- normalizePath(parent, winslash = "/", mustWork = TRUE)
  home <- normalizePath(path.expand("~"), winslash = "/", mustWork = TRUE)
  if (parent %in% c("/", home) || basename(target) %in% c("", ".", "..")) {
    stop("A broad or unresolved target is prohibited.", call. = FALSE)
  }
  file.path(parent, basename(target))
}

mfrmr_gtwao_site_probe <- function(contract, project_root) {
  if (!mfrmr_gtwao_contract_hash_valid(contract)) {
    stop("The exact b1g20 contract is required.", call. = FALSE)
  }
  project_root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(project_root, "DESCRIPTION"))) {
    stop("The mfrmr package root is required.", call. = FALSE)
  }
  components <- strsplit(contract$OutputRoot, "[/\\\\]")[[1L]]
  if (grepl("^[/\\\\]", contract$OutputRoot) ||
      any(components %in% c("", ".", ".."))) {
    stop("The output root must be a safe relative path.", call. = FALSE)
  }
  target <- mfrmr_gtwao_safe_target(file.path(
    project_root, contract$OutputRoot
  ))
  parent <- dirname(target)
  target_absent <- !file.exists(target) && !dir.exists(target)
  probe_dir <- tempfile(".mfrmr-gtwao-site-", tmpdir = parent)
  created <- dir.create(probe_dir, showWarnings = FALSE)
  on.exit(if (dir.exists(probe_dir)) unlink(
    probe_dir, recursive = TRUE, force = TRUE
  ), add = TRUE)
  source <- file.path(probe_dir, "source.rds")
  destination <- file.path(probe_dir, "installed.rds")
  sentinel <- list(
    Contract = "site_probe_sentinel_b1g20_v1",
    AuthorizationKernelContractHash = contract$ContractHash,
    Payload = seq_len(32L)
  )
  write_passed <- created && isTRUE(tryCatch({
    saveRDS(sentinel, source, version = 3L)
    file.exists(source)
  }, error = function(error) FALSE))
  rename_passed <- write_passed && isTRUE(file.rename(source, destination))
  readback_passed <- rename_passed && isTRUE(tryCatch(
    identical(readRDS(destination), sentinel),
    error = function(error) FALSE
  ))
  df_executable <- unname(Sys.which("df"))
  df_output <- if (nzchar(df_executable)) suppressWarnings(system2(
    df_executable, c("-Pk", shQuote(parent)), stdout = TRUE, stderr = TRUE
  )) else character()
  df_status <- attr(df_output, "status")
  df_status <- if (is.null(df_status) && nzchar(df_executable)) {
    0L
  } else if (is.null(df_status)) {
    127L
  } else {
    as.integer(df_status)
  }
  parsed <- if (identical(df_status, 0L)) tryCatch(
    mfrmr_gtwao_parse_df(df_output), error = function(error) NULL
  ) else NULL
  if (dir.exists(probe_dir)) unlink(probe_dir, recursive = TRUE, force = TRUE)
  cleanup_passed <- !file.exists(probe_dir)
  available <- if (is.null(parsed)) NA_real_ else parsed$AvailableKiB * 1024
  ready <- target_absent && created && write_passed && rename_passed &&
    readback_passed && cleanup_passed && identical(df_status, 0L) &&
    is.finite(available) &&
    available >= contract$KernelPolicy$RequiredAvailableBytes
  identity <- list(
    Contract = "per_shard_site_preflight_b1g20_v1",
    AuthorizationKernelContractHash = contract$ContractHash,
    OutputTargetHash = mfrmr_gta_hash(target),
    OutputTargetAbsent = target_absent,
    ProbeDirectoryCreated = created,
    ActualWritePassed = write_passed,
    AtomicRenamePassed = rename_passed,
    ReadbackPassed = readback_passed,
    ProbeCleanupPassed = cleanup_passed,
    DfExitStatus = df_status,
    DfOutputHash = mfrmr_gta_hash(df_output),
    AvailableBytes = available,
    RequiredAvailableBytes = contract$KernelPolicy$RequiredAvailableBytes,
    CapacityReady = is.finite(available) &&
      available >= contract$KernelPolicy$RequiredAvailableBytes,
    SitePreflightReady = ready,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    ProbeHash = mfrmr_gta_hash(identity),
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwao_site_probe")
}

mfrmr_gtwao_site_probe_hash_valid <- function(probe) {
  fields <- c(
    "Contract", "AuthorizationKernelContractHash", "OutputTargetHash",
    "OutputTargetAbsent", "ProbeDirectoryCreated", "ActualWritePassed",
    "AtomicRenamePassed", "ReadbackPassed", "ProbeCleanupPassed",
    "DfExitStatus", "DfOutputHash", "AvailableBytes",
    "RequiredAvailableBytes", "CapacityReady", "SitePreflightReady",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  capacity_ready <- inherits(probe, "mfrmr_gtwao_site_probe") &&
    is.finite(probe$AvailableBytes) &&
    is.finite(probe$RequiredAvailableBytes) &&
    probe$AvailableBytes >= probe$RequiredAvailableBytes
  ready <- inherits(probe, "mfrmr_gtwao_site_probe") && all(c(
    probe$OutputTargetAbsent, probe$ProbeDirectoryCreated,
    probe$ActualWritePassed, probe$AtomicRenamePassed,
    probe$ReadbackPassed, probe$ProbeCleanupPassed, capacity_ready
  )) && identical(probe$DfExitStatus, 0L)
  inherits(probe, "mfrmr_gtwao_site_probe") &&
    all(fields %in% names(probe)) &&
    identical(probe$ProbeHash, mfrmr_gta_hash(probe[fields])) &&
    identical(probe$CapacityReady, capacity_ready) &&
    identical(probe$SitePreflightReady, ready) &&
    !isTRUE(probe$CalibrationExecutionAuthorized) &&
    !isTRUE(probe$CalibrationDataGenerated) &&
    !isTRUE(probe$CalibrationResultsViewed) &&
    !isTRUE(probe$CalibrationResponsesUsed) &&
    !isTRUE(probe$ConfirmationResponsesUsed)
}

mfrmr_gtwao_lock_acquire <- function(target, owner_hash, policy) {
  if (!mfrmr_gtwao_policy_hash_valid(policy) ||
      length(owner_hash) != 1L || !nzchar(owner_hash)) {
    stop("A frozen policy and one owner hash are required.", call. = FALSE)
  }
  target <- mfrmr_gtwao_safe_target(target)
  lock_path <- paste0(target, policy$LockDirectorySuffix)
  if (!dir.create(lock_path, recursive = FALSE, showWarnings = FALSE)) {
    stop("The exclusive writer lock is already held.", call. = FALSE)
  }
  identity <- list(
    Contract = "exclusive_writer_lock_b1g20_v1",
    TargetHash = mfrmr_gta_hash(target),
    OwnerHash = owner_hash,
    PolicyHash = policy$PolicyHash
  )
  marker <- structure(c(identity, list(
    LockHash = mfrmr_gta_hash(identity)
  )), class = "mfrmr_gtwao_lock_marker")
  installed <- tryCatch({
    temporary <- file.path(lock_path, "owner.rds.new")
    destination <- file.path(lock_path, "owner.rds")
    saveRDS(marker, temporary, version = 3L)
    isTRUE(file.rename(temporary, destination))
  }, error = function(error) FALSE)
  if (!installed) {
    unlink(lock_path, recursive = TRUE, force = TRUE)
    stop("The exclusive writer marker could not be installed.", call. = FALSE)
  }
  structure(list(
    Target = target, LockPath = lock_path, OwnerHash = owner_hash,
    LockHash = marker$LockHash, Acquired = TRUE
  ), class = "mfrmr_gtwao_lock_receipt")
}

mfrmr_gtwao_lock_release <- function(receipt) {
  if (!inherits(receipt, "mfrmr_gtwao_lock_receipt") ||
      !isTRUE(receipt$Acquired) || !dir.exists(receipt$LockPath)) {
    stop("A held b1g20 lock receipt is required.", call. = FALSE)
  }
  marker_path <- file.path(receipt$LockPath, "owner.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(error) NULL)
  if (is.null(marker) || !identical(marker$LockHash, receipt$LockHash) ||
      !identical(marker$OwnerHash, receipt$OwnerHash)) {
    stop("The lock owner marker is missing or changed.", call. = FALSE)
  }
  unlink(receipt$LockPath, recursive = TRUE, force = TRUE)
  if (dir.exists(receipt$LockPath)) {
    stop("The exclusive writer lock could not be released.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtwao_activate_root <- function(receipt, manifest_hash, runtime_hash,
                                      policy) {
  if (!inherits(receipt, "mfrmr_gtwao_lock_receipt") ||
      !isTRUE(receipt$Acquired) || !dir.exists(receipt$LockPath) ||
      !mfrmr_gtwao_policy_hash_valid(policy)) {
    stop("A held lock and frozen policy are required.", call. = FALSE)
  }
  target <- receipt$Target
  marker_path <- file.path(target, policy$ActivationMarkerName)
  identity <- list(
    Contract = "activation_marker_b1g20_v1",
    TargetHash = mfrmr_gta_hash(target),
    ManifestHash = manifest_hash,
    RuntimeHash = runtime_hash,
    PolicyHash = policy$PolicyHash
  )
  expected_hash <- mfrmr_gta_hash(identity)
  if (!file.exists(target) && !dir.exists(target)) {
    if (!dir.create(target, recursive = FALSE, showWarnings = FALSE)) {
      stop("The activation root could not be created.", call. = FALSE)
    }
    marker <- structure(c(identity, list(
      MarkerHash = expected_hash
    )), class = "mfrmr_gtwao_activation_marker")
    temporary <- paste0(marker_path, ".new")
    installed <- tryCatch({
      saveRDS(marker, temporary, version = 3L)
      isTRUE(file.rename(temporary, marker_path))
    }, error = function(error) FALSE)
    if (!installed) stop("The activation marker was not installed.",
                         call. = FALSE)
    state <- "initial_activation"
  } else {
    if (!dir.exists(target) || !file.exists(marker_path)) {
      stop("An existing unmarked activation root is prohibited.",
           call. = FALSE)
    }
    marker <- tryCatch(readRDS(marker_path), error = function(error) NULL)
    marker_identity <- if (is.null(marker)) NULL else
      unclass(marker)[names(identity)]
    if (is.null(marker) || !identical(marker$MarkerHash, expected_hash) ||
        !identical(marker_identity, identity)) {
      stop("The activation marker identity changed.", call. = FALSE)
    }
    state <- "exact_resume"
  }
  structure(list(
    State = state, TargetHash = identity$TargetHash,
    MarkerHash = expected_hash, ManifestHash = manifest_hash,
    RuntimeHash = runtime_hash
  ), class = "mfrmr_gtwao_activation_receipt")
}

mfrmr_gtwao_mechanics_audit <- function(contract) {
  if (!mfrmr_gtwao_contract_hash_valid(contract)) {
    stop("The exact b1g20 contract is required.", call. = FALSE)
  }
  fixture_parent <- tempfile("mfrmr-gtwao-kernel-")
  if (!dir.create(fixture_parent, showWarnings = FALSE)) {
    stop("The mechanics fixture parent could not be created.", call. = FALSE)
  }
  on.exit(if (dir.exists(fixture_parent)) unlink(
    fixture_parent, recursive = TRUE, force = TRUE
  ), add = TRUE)
  target <- file.path(fixture_parent, "activation-root")
  policy <- contract$KernelPolicy
  owner <- mfrmr_gta_hash(list(
    Contract = contract$ContractHash, Fixture = "lock_root_mechanics"
  ))
  runtime_hash <- mfrmr_gta_hash("isolated_runtime_fixture_b1g20_v1")
  lock <- mfrmr_gtwao_lock_acquire(target, owner, policy)
  contention_rejected <- inherits(tryCatch(
    mfrmr_gtwao_lock_acquire(target, owner, policy),
    error = function(error) error
  ), "error")
  initial <- mfrmr_gtwao_activate_root(
    lock, contract$ReservedManifestHash, runtime_hash, policy
  )
  resume <- mfrmr_gtwao_activate_root(
    lock, contract$ReservedManifestHash, runtime_hash, policy
  )
  mfrmr_gtwao_lock_release(lock)
  release_passed <- !dir.exists(lock$LockPath)
  unmarked <- file.path(fixture_parent, "unmarked-root")
  dir.create(unmarked)
  unmarked_lock <- mfrmr_gtwao_lock_acquire(unmarked, owner, policy)
  unmarked_rejected <- inherits(tryCatch(
    mfrmr_gtwao_activate_root(
      unmarked_lock, contract$ReservedManifestHash, runtime_hash, policy
    ), error = function(error) error
  ), "error")
  mfrmr_gtwao_lock_release(unmarked_lock)
  identity <- list(
    Contract = "lock_root_mechanics_audit_b1g20_v1",
    AuthorizationKernelContractHash = contract$ContractHash,
    ContentionRejected = contention_rejected,
    InitialActivationState = initial$State,
    ExactResumeState = resume$State,
    MarkerIdentityStable = identical(initial$MarkerHash, resume$MarkerHash),
    LockReleasePassed = release_passed,
    UnmarkedRootRejected = unmarked_rejected,
    StaleLockTakeoverAttempted = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  ready <- contention_rejected &&
    identical(initial$State, "initial_activation") &&
    identical(resume$State, "exact_resume") &&
    identity$MarkerIdentityStable && release_passed && unmarked_rejected
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity), LockRootKernelReady = ready,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwao_mechanics_audit")
}

mfrmr_gtwao_mechanics_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "AuthorizationKernelContractHash", "ContentionRejected",
    "InitialActivationState", "ExactResumeState", "MarkerIdentityStable",
    "LockReleasePassed", "UnmarkedRootRejected",
    "StaleLockTakeoverAttempted", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  ready <- inherits(audit, "mfrmr_gtwao_mechanics_audit") &&
    isTRUE(audit$ContentionRejected) &&
    identical(audit$InitialActivationState, "initial_activation") &&
    identical(audit$ExactResumeState, "exact_resume") &&
    isTRUE(audit$MarkerIdentityStable) &&
    isTRUE(audit$LockReleasePassed) && isTRUE(audit$UnmarkedRootRejected)
  inherits(audit, "mfrmr_gtwao_mechanics_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$LockRootKernelReady, ready) &&
    !isTRUE(audit$StaleLockTakeoverAttempted) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed) &&
    !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
}

mfrmr_gtwao_preflight <- function(contract, lineage_audit, worker_path,
                                   project_root) {
  if (!mfrmr_gtwao_contract_hash_valid(contract) ||
      !mfrmr_gtwan_audit_hash_valid(lineage_audit) ||
      !identical(lineage_audit$AuditHash, contract$LineageAuditHash)) {
    stop("Exact b1g19 and b1g20 contracts are required.", call. = FALSE)
  }
  runtime <- mfrmr_gtwao_isolated_runtime_probe(contract, worker_path)
  site <- mfrmr_gtwao_site_probe(contract, project_root)
  mechanics <- mfrmr_gtwao_mechanics_audit(contract)
  gates <- data.frame(
    GateId = c(
      "RNG-01", "LINEAGE-01", "RUNTIME-01", "THREAD-01",
      "PROCESS-01", "LOCK-01", "ROOT-01", "CAPACITY-01",
      "CONFIRM-01", "RUNNER-01", "AUTH-RECORD-01"
    ),
    ObservedPass = c(
      identical(
        contract$HardenedGeneratorContractHash,
        contract$LineageReceipt$HardenedGeneratorContractHash
      ),
      isTRUE(lineage_audit$ReservedManifestRebaseReady),
      runtime$RuntimeRecordValid && runtime$RNGKindExact,
      runtime$GLMMTMBSerialExact && runtime$ThreadEnvironmentExact,
      runtime$LocaleEnvironmentExact &&
        runtime$StartupEnvironmentSuppressed &&
        runtime$VanillaInvocationObserved,
      mechanics$ContentionRejected && mechanics$LockReleasePassed,
      mechanics$MarkerIdentityStable && mechanics$UnmarkedRootRejected,
      site$SitePreflightReady,
      lineage_audit$ConfirmationReplicatesAbsent,
      FALSE, FALSE
    ),
    RequiredForKernel = c(rep(TRUE, 9L), FALSE, FALSE),
    RequiredForAuthorization = TRUE,
    stringsAsFactors = FALSE
  )
  kernel_blockers <- gates[
    gates$RequiredForKernel & !gates$ObservedPass, , drop = FALSE
  ]
  authorization_blockers <- gates[
    gates$RequiredForAuthorization & !gates$ObservedPass, , drop = FALSE
  ]
  kernel_ready <- nrow(kernel_blockers) == 0L &&
    mfrmr_gtwao_runtime_probe_hash_valid(runtime) &&
    mfrmr_gtwao_site_probe_hash_valid(site) &&
    mfrmr_gtwao_mechanics_audit_hash_valid(mechanics)
  identity <- list(
    Contract = "authorization_kernel_preflight_b1g20_v1",
    AuthorizationKernelContractHash = contract$ContractHash,
    LineageAuditHash = lineage_audit$AuditHash,
    RuntimeProbeHash = runtime$ProbeHash,
    SiteProbeHash = site$ProbeHash,
    MechanicsAuditHash = mechanics$AuditHash,
    GateRegistry = gates,
    KernelBlockerIds = kernel_blockers$GateId,
    AuthorizationBlockerIds = authorization_blockers$GateId,
    AuthorizationKernelReady = kernel_ready,
    ReservedAdapterEntryPointReady = FALSE,
    AuthorizedSingleShardRunnerReady = FALSE,
    AuthorizationRecordIssued = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    PreflightHash = mfrmr_gta_hash(identity),
    RuntimeContractExtensionReady = kernel_ready,
    LockRootKernelReady = kernel_ready,
    PerShardSitePreflightReady = kernel_ready,
    AuthorizationRNG01Closed = FALSE,
    AuthorizationActivationEligible = FALSE,
    LargeSimulationMayStart = FALSE,
    Replicate201MayBeOpened = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE,
    RuntimeProbe = runtime, SiteProbe = site, MechanicsAudit = mechanics
  )), class = "mfrmr_gtwao_preflight")
}

mfrmr_gtwao_preflight_hash_valid <- function(preflight) {
  fields <- c(
    "Contract", "AuthorizationKernelContractHash", "LineageAuditHash",
    "RuntimeProbeHash", "SiteProbeHash", "MechanicsAuditHash",
    "GateRegistry", "KernelBlockerIds", "AuthorizationBlockerIds",
    "AuthorizationKernelReady", "ReservedAdapterEntryPointReady",
    "AuthorizedSingleShardRunnerReady", "AuthorizationRecordIssued",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  if (!inherits(preflight, "mfrmr_gtwao_preflight") ||
      !all(fields %in% names(preflight)) ||
      !is.data.frame(preflight$GateRegistry)) return(FALSE)
  gates <- preflight$GateRegistry
  kernel_blockers <- gates$GateId[
    gates$RequiredForKernel & !gates$ObservedPass
  ]
  authorization_blockers <- gates$GateId[
    gates$RequiredForAuthorization & !gates$ObservedPass
  ]
  kernel_ready <- length(kernel_blockers) == 0L &&
    mfrmr_gtwao_runtime_probe_hash_valid(preflight$RuntimeProbe) &&
    mfrmr_gtwao_site_probe_hash_valid(preflight$SiteProbe) &&
    mfrmr_gtwao_mechanics_audit_hash_valid(preflight$MechanicsAudit)
  inherits(preflight, "mfrmr_gtwao_preflight") &&
    all(fields %in% names(preflight)) &&
    identical(preflight$PreflightHash, mfrmr_gta_hash(preflight[fields])) &&
    identical(preflight$RuntimeProbeHash,
              preflight$RuntimeProbe$ProbeHash) &&
    identical(preflight$SiteProbeHash, preflight$SiteProbe$ProbeHash) &&
    identical(preflight$MechanicsAuditHash,
              preflight$MechanicsAudit$AuditHash) &&
    identical(preflight$KernelBlockerIds, kernel_blockers) &&
    identical(preflight$AuthorizationBlockerIds, authorization_blockers) &&
    identical(preflight$AuthorizationKernelReady, kernel_ready) &&
    identical(preflight$RuntimeContractExtensionReady, kernel_ready) &&
    identical(preflight$LockRootKernelReady, kernel_ready) &&
    identical(preflight$PerShardSitePreflightReady, kernel_ready) &&
    !isTRUE(preflight$ReservedAdapterEntryPointReady) &&
    !isTRUE(preflight$AuthorizedSingleShardRunnerReady) &&
    !isTRUE(preflight$AuthorizationRecordIssued) &&
    !isTRUE(preflight$AuthorizationRNG01Closed) &&
    !isTRUE(preflight$AuthorizationActivationEligible) &&
    !isTRUE(preflight$LargeSimulationMayStart) &&
    !isTRUE(preflight$Replicate201MayBeOpened) &&
    !isTRUE(preflight$CalibrationExecutionAuthorized) &&
    !isTRUE(preflight$CalibrationDataGenerated) &&
    !isTRUE(preflight$CalibrationResultsViewed) &&
    !isTRUE(preflight$ConfirmationAuthorized) &&
    !isTRUE(preflight$InferenceReady) && !isTRUE(preflight$DecisionReady) &&
    !isTRUE(preflight$CalibrationResponsesUsed) &&
    !isTRUE(preflight$ConfirmationResponsesUsed)
}
