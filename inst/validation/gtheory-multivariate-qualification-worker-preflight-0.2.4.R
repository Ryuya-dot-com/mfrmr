# Draft.85c4g multivariate G-theory qualification-worker build preflight.
#
# Repository-internal only. This controller binds the future qualification
# source bundle and executes only a hash-only refusal request in a fresh R
# process. It supplies no fit object, response, seed, backend authority, or
# trusted-receipt authority.

mfrmr_gtvn_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvm_manifest", "mfrmr_gtvm_assert_manifest",
    "mfrmr_gtvm_qualification_policy"
  )
  target <- environment(mfrmr_gtvn_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.85c4f protocol before Draft.85c4g: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvn_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4g requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvn_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvn_file_hash <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !file.exists(path) || dir.exists(path)) {
    stop("A Draft.85c4g bundle file is missing.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvn_bundle_paths <- function() {
  file.path("inst", "validation", c(
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-incidence-preflight-0.2.4.R",
    "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
    "gtheory-multivariate-execution-admission-preflight-0.2.4.R",
    paste0(
      "gtheory-multivariate-backend-qualification-admission-",
      "preflight-0.2.4.R"
    ),
    "gtheory-multivariate-four-route-qualification-protocol-0.2.4.R",
    "gtheory-multivariate-qualification-worker-0.2.4.R"
  ))
}

mfrmr_gtvn_bundle_registry <- function(repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  paths <- mfrmr_gtvn_bundle_paths()
  full_paths <- file.path(repo_root, paths)
  if (anyDuplicated(paths) || !all(file.exists(full_paths)) ||
      any(dir.exists(full_paths))) {
    stop("The Draft.85c4g worker bundle is incomplete or duplicated.",
         call. = FALSE)
  }
  data.frame(
    BundleOrdinal = seq_along(paths),
    Path = paths,
    Role = c(
      "hash_and_design_primitives", "matrix_audit_primitives",
      "incidence_validator", "fit_and_parity_validator",
      "environment_snapshot", "environment_admission",
      "qualification_protocol", "refusal_worker"
    ),
    Bytes = as.numeric(file.info(full_paths)$size),
    SHA256 = vapply(full_paths, mfrmr_gtvn_file_hash, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvn_worker_identity <- function(worker_environment) {
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv())) {
    stop("Draft.85c4g requires a worker environment with baseenv() parent.",
         call. = FALSE)
  }
  functions <- c(
    "mfrmr_gtvnw_hash", "mfrmr_gtvnw_exact_object", "mfrmr_gtvnw_sha256",
    "mfrmr_gtvnw_assert_request", "mfrmr_gtvnw_refusal_receipt",
    "mfrmr_gtvnw_assert_receipt", "mfrmr_gtvnw_main"
  )
  if (!identical(sort(ls(worker_environment, all.names = TRUE)),
                 sort(functions)) ||
      !all(vapply(functions, function(name) {
        is.function(get(name, envir = worker_environment, inherits = FALSE))
      }, logical(1L)))) {
    stop("The Draft.85c4g worker namespace was altered.", call. = FALSE)
  }
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      fun <- get(name, envir = worker_environment, inherits = FALSE)
      mfrmr_gtvn_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvn_request <- function(
    worker_environment, protocol_manifest, repo_root = ".") {
  mfrmr_gtvn_require_primitives()
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  mfrmr_gtvm_assert_manifest(protocol_manifest, repo_root)
  if (protocol_manifest$EnvironmentReadyForBackendQualification) {
    stop("Draft.85c4g refusal mode cannot accept a ready environment.",
         call. = FALSE)
  }
  bundle <- mfrmr_gtvn_bundle_registry(repo_root)
  worker_row <- bundle$Role == "refusal_worker"
  payload <- list(
    Contract =
      "gtheory_multivariate_qualification_refusal_request_draft85c4g_v1",
    ProtocolManifestHash = protocol_manifest$ManifestHash,
    QualificationPolicyHash = protocol_manifest$QualificationPolicyHash,
    EnvironmentIdentityHash = protocol_manifest$C4EEnvironmentIdentityHash,
    BundleRegistryHash = mfrmr_gtvn_hash(bundle),
    WorkerSourceSHA256 = bundle$SHA256[worker_row],
    RouteRegistryHash =
      protocol_manifest$QualificationPolicy$RouteRegistryHash,
    PairRegistryHash = protocol_manifest$QualificationPolicy$PairRegistryHash,
    Mode = "environment_refusal_preflight",
    RequiredRoutes = protocol_manifest$QualificationPolicy$RouteRegistry$RouteId,
    EnvironmentReadyForBackendQualification = FALSE,
    BackendExecutionAuthorized = FALSE,
    PlannedSeedMaterialIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  request <- structure(c(payload, list(
    RequestHash = mfrmr_gtvn_hash(payload)
  )), class = c("mfrmr_gtvn_request", "list"))
  get(
    "mfrmr_gtvnw_assert_request", envir = worker_environment,
    inherits = FALSE
  )(request)
  request
}

mfrmr_gtvn_assert_request <- function(
    request, worker_environment, protocol_manifest, repo_root = ".") {
  canonical <- mfrmr_gtvn_request(
    worker_environment, protocol_manifest, repo_root
  )
  if (!mfrmr_gtvn_exact_object(
    request, names(canonical), class(canonical)
  ) || !identical(request, canonical)) {
    stop("The Draft.85c4g refusal request or identity was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvn_process_preflight <- function(
    worker_environment, protocol_manifest, repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  request <- mfrmr_gtvn_request(
    worker_environment, protocol_manifest, repo_root
  )
  worker_path <- normalizePath(
    file.path(
      repo_root, "inst", "validation",
      "gtheory-multivariate-qualification-worker-0.2.4.R"
    ), mustWork = TRUE
  )
  rscript <- normalizePath(
    file.path(R.home("bin"), "Rscript"), mustWork = TRUE
  )
  staging <- tempfile("mfrmr-c4g-", tmpdir = tempdir())
  if (!dir.create(staging)) {
    stop("Draft.85c4g could not create temporary staging.", call. = FALSE)
  }
  on.exit(unlink(staging, recursive = TRUE), add = TRUE)
  input <- file.path(staging, "request.rds")
  output <- file.path(staging, "receipt.rds")
  saveRDS(request, input, version = 3L)
  process_output <- suppressWarnings(system2(
    rscript, c("--vanilla", worker_path, input, output),
    stdout = TRUE, stderr = TRUE
  ))
  status <- attr(process_output, "status")
  if (is.null(status)) status <- 0L
  if (status != 0L || !file.exists(output)) {
    stop(
      "Draft.85c4g refusal worker failed: ",
      paste(process_output, collapse = " | "), call. = FALSE
    )
  }
  receipt <- readRDS(output)
  get(
    "mfrmr_gtvnw_assert_receipt", envir = worker_environment,
    inherits = FALSE
  )(receipt, request)
  payload <- list(
    Contract =
      "gtheory_multivariate_qualification_worker_preflight_draft85c4g_v1",
    Request = request,
    RequestHash = request$RequestHash,
    Receipt = receipt,
    ReceiptHash = receipt$ReceiptHash,
    RscriptSHA256 = mfrmr_gtvn_file_hash(rscript),
    WorkerSourceSHA256 = request$WorkerSourceSHA256,
    WorkerExitStatus = as.integer(status),
    WorkerOutput = as.character(process_output)
  )
  structure(c(payload, list(
    EvidenceHash = mfrmr_gtvn_hash(payload),
    RefusalOnlyWorkerReady = TRUE,
    FreshProcessRefusalObserved = TRUE,
    ProcessCapabilityIsolationReady = FALSE,
    QualificationWorkerImplemented = FALSE,
    FullB1ObjectsReceived = FALSE,
    BackendExecutionOccurred = FALSE,
    TrustedReceiptProduced = FALSE,
    QualificationEvidenceReady = FALSE,
    BackendQualificationReady = FALSE,
    ExecutionAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvn_process_evidence", "list"))
}

mfrmr_gtvn_assert_process_evidence <- function(
    evidence, worker_environment, protocol_manifest, repo_root = ".") {
  canonical <- mfrmr_gtvn_process_preflight(
    worker_environment, protocol_manifest, repo_root
  )
  if (!mfrmr_gtvn_exact_object(
    evidence, names(canonical), class(canonical)
  ) || !identical(evidence, canonical)) {
    stop("The Draft.85c4g process evidence or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvn_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtvn_require_primitives", "mfrmr_gtvn_hash",
    "mfrmr_gtvn_exact_object", "mfrmr_gtvn_file_hash",
    "mfrmr_gtvn_bundle_paths", "mfrmr_gtvn_bundle_registry",
    "mfrmr_gtvn_worker_identity", "mfrmr_gtvn_request",
    "mfrmr_gtvn_assert_request", "mfrmr_gtvn_process_preflight",
    "mfrmr_gtvn_assert_process_evidence",
    "mfrmr_gtvn_implementation_identity", "mfrmr_gtvn_manifest",
    "mfrmr_gtvn_assert_manifest", "mfrmr_gtvn_dispatch_guard"
  )
  target <- environment(mfrmr_gtvn_implementation_identity)
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4g implementation function is missing: ", name,
             ".", call. = FALSE)
      }
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvn_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvn_manifest <- function(
    worker_environment, protocol_manifest, repo_root = ".",
    process_evidence = NULL) {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  mfrmr_gtvm_assert_manifest(protocol_manifest, repo_root)
  if (!identical(
    protocol_manifest$ManifestHash,
    "89044060c10c55321e61d2214fc85484aca30c4eafc413f67fc26f00edc6d1fb"
  )) {
    stop("The Draft.85c4g sealed c4f protocol root does not match.",
         call. = FALSE)
  }
  worker_identity <- mfrmr_gtvn_worker_identity(worker_environment)
  bundle <- mfrmr_gtvn_bundle_registry(repo_root)
  bundle_hash <- mfrmr_gtvn_hash(bundle)
  worker_hash <- bundle$SHA256[bundle$Role == "refusal_worker"]
  if (!identical(
    bundle_hash,
    "897579b6991f354d459725e64758edc011e1baf7f6ebbbcf1256f4a0c67911da"
  ) || !identical(
    worker_hash,
    "a13ef63611a1e96048de3fd5a4b59bf4dddc53d225c6cd3f5808c65876a21daa"
  )) {
    stop("The Draft.85c4g sealed worker bundle root does not match.",
         call. = FALSE)
  }
  request <- mfrmr_gtvn_request(
    worker_environment, protocol_manifest, repo_root
  )
  if (is.null(process_evidence)) {
    process_evidence <- mfrmr_gtvn_process_preflight(
      worker_environment, protocol_manifest, repo_root
    )
  } else {
    mfrmr_gtvn_assert_process_evidence(
      process_evidence, worker_environment, protocol_manifest, repo_root
    )
  }
  implementation <- mfrmr_gtvn_implementation_identity()
  payload <- list(
    Contract =
      "gtheory_multivariate_qualification_worker_build_draft85c4g_v1",
    ProtocolManifestHash = protocol_manifest$ManifestHash,
    QualificationPolicyHash = protocol_manifest$QualificationPolicyHash,
    EnvironmentIdentityHash = protocol_manifest$C4EEnvironmentIdentityHash,
    BundleRegistry = bundle,
    BundleRegistryHash = bundle_hash,
    WorkerIdentity = worker_identity,
    WorkerIdentityHash = mfrmr_gtvn_hash(worker_identity),
    Request = request,
    RequestHash = request$RequestHash,
    ProcessEvidence = process_evidence,
    ProcessEvidenceHash = process_evidence$EvidenceHash,
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvn_hash(implementation),
    PlannedSeedMaterialIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtvn_hash(payload),
    WorkerBundleRegistryReady = TRUE,
    RequestSchemaReady = TRUE,
    RefusalOnlyWorkerReady = TRUE,
    FreshProcessRefusalObserved = TRUE,
    EnvironmentReadyForBackendQualification = FALSE,
    RepairRequired = TRUE,
    ProcessCapabilityIsolationReady = FALSE,
    QualificationWorkerImplemented = FALSE,
    FullB1ObjectsReceived = FALSE,
    RouteReceiptsMaterialized = FALSE,
    PairReceiptsMaterialized = FALSE,
    TrustedReceiptProduced = FALSE,
    QualificationEvidenceReady = FALSE,
    BackendQualificationReady = FALSE,
    DiagnosticOverrideAllowed = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    ExecutionGateClosed = TRUE,
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvn_manifest", "list"))
}

mfrmr_gtvn_assert_manifest <- function(
    manifest, worker_environment, protocol_manifest, repo_root = ".") {
  canonical <- mfrmr_gtvn_manifest(
    worker_environment, protocol_manifest, repo_root
  )
  if (!mfrmr_gtvn_exact_object(
    manifest, names(canonical), class(canonical)
  ) || !identical(manifest, canonical)) {
    stop("The Draft.85c4g worker manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvn_dispatch_guard <- function(
    manifest, action, callback, ..., authorize = FALSE,
    worker_environment, protocol_manifest, repo_root = ".") {
  mfrmr_gtvn_assert_manifest(
    manifest, worker_environment, protocol_manifest, repo_root
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% c("qualification_worker", "backend_fit", "receipt_trust")) {
    stop("The Draft.85c4g action is outside the worker preflight.",
         call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4g has only a refusal worker; qualification remains closed.",
    call. = FALSE
  )
}
