# Draft.85c4g refusal-only qualification worker.
#
# This standalone worker validates one hash-only preflight request and returns
# a typed non-attempt receipt. It cannot receive a fit specification or
# response payload and contains no backend or package-install entry point.

mfrmr_gtvnw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4g worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvnw_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvnw_sha256 <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl("^[0-9a-f]{64}$", value)
}

mfrmr_gtvnw_assert_request <- function(request) {
  payload_fields <- c(
    "Contract", "ProtocolManifestHash", "QualificationPolicyHash",
    "EnvironmentIdentityHash", "BundleRegistryHash", "WorkerSourceSHA256",
    "RouteRegistryHash", "PairRegistryHash", "Mode", "RequiredRoutes",
    "EnvironmentReadyForBackendQualification",
    "BackendExecutionAuthorized", "PlannedSeedMaterialIncluded",
    "ConQuestRouteIncluded"
  )
  if (!mfrmr_gtvnw_exact_object(
    request, c(payload_fields, "RequestHash"),
    c("mfrmr_gtvn_request", "list")
  )) {
    stop("A typed Draft.85c4g refusal request is required.", call. = FALSE)
  }
  hash_fields <- c(
    "ProtocolManifestHash", "QualificationPolicyHash",
    "EnvironmentIdentityHash", "BundleRegistryHash", "WorkerSourceSHA256",
    "RouteRegistryHash", "PairRegistryHash"
  )
  valid <- identical(
    request$Contract,
    "gtheory_multivariate_qualification_refusal_request_draft85c4g_v1"
  ) && all(vapply(request[hash_fields], mfrmr_gtvnw_sha256, logical(1L))) &&
    identical(request$Mode, "environment_refusal_preflight") &&
    identical(request$RequiredRoutes, c(
      "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
    )) &&
    identical(request$EnvironmentReadyForBackendQualification, FALSE) &&
    identical(request$BackendExecutionAuthorized, FALSE) &&
    identical(request$PlannedSeedMaterialIncluded, FALSE) &&
    identical(request$ConQuestRouteIncluded, FALSE) &&
    identical(request$RequestHash, mfrmr_gtvnw_hash(request[payload_fields]))
  if (!valid) {
    stop("The Draft.85c4g refusal request or execution state was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvnw_refusal_receipt <- function(request) {
  mfrmr_gtvnw_assert_request(request)
  payload <- list(
    Contract =
      "gtheory_multivariate_qualification_refusal_receipt_draft85c4g_v1",
    RequestHash = request$RequestHash,
    ProtocolManifestHash = request$ProtocolManifestHash,
    QualificationPolicyHash = request$QualificationPolicyHash,
    EnvironmentIdentityHash = request$EnvironmentIdentityHash,
    BundleRegistryHash = request$BundleRegistryHash,
    WorkerSourceSHA256 = request$WorkerSourceSHA256,
    Mode = request$Mode,
    RequiredRoutes = request$RequiredRoutes,
    Disposition = "environment_not_ready_no_backend_attempt",
    WorkerRVersion = R.version.string,
    WorkerPlatform = R.version$platform,
    FullB1ObjectsReceived = FALSE,
    BackendAttempted = FALSE,
    DiagnosticOverrideUsed = FALSE,
    TrustedReceiptProduced = FALSE
  )
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtvnw_hash(payload),
    RefusalReceiptReady = TRUE,
    FreshProcessClaimedByWorker = FALSE,
    EnvironmentReadyForBackendQualification = FALSE,
    RouteReceiptsMaterialized = FALSE,
    PairReceiptsMaterialized = FALSE,
    QualificationEvidenceReady = FALSE,
    BackendQualificationReady = FALSE,
    ExecutionAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvn_refusal_receipt", "list"))
}

mfrmr_gtvnw_assert_receipt <- function(receipt, request) {
  canonical <- mfrmr_gtvnw_refusal_receipt(request)
  if (!mfrmr_gtvnw_exact_object(
    receipt, names(canonical), class(canonical)
  ) || !identical(receipt, canonical)) {
    stop("The Draft.85c4g refusal receipt or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvnw_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (!is.character(arguments) || length(arguments) != 2L ||
      anyNA(arguments) || any(!nzchar(arguments))) {
    stop("Draft.85c4g worker requires input and output RDS paths.",
         call. = FALSE)
  }
  input <- normalizePath(arguments[[1L]], mustWork = TRUE)
  output <- arguments[[2L]]
  request <- readRDS(input)
  receipt <- mfrmr_gtvnw_refusal_receipt(request)
  saveRDS(receipt, output, version = 3L)
  invisible(receipt)
}

if (sys.nframe() == 0L) {
  mfrmr_gtvnw_main()
}
