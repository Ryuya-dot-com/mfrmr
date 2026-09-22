# Draft.85c4m planned-study adapter refusal worker.
#
# This standalone worker accepts one opaque c1 handoff projection, verifies
# only its allowlisted topology and bound backend-qualification hashes, and
# returns a typed non-attempt receipt. It receives no stage name, scenario,
# seed, reference identity, truth, threshold, response, or fit object.

mfrmr_gtvtw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The Draft.85c4m adapter worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvtw_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvtw_candidate_unit_schema <- function(units) {
  list(
    Names = names(units),
    Classes = unname(vapply(
      units, function(value) class(value)[[1L]], character(1L)
    ))
  )
}

mfrmr_gtvtw_receive <- function(request) {
  payload_fields <- c(
    "Contract", "OpaqueRequestId", "LaneOpaqueId", "PlanHash",
    "HandoffPreviewHash", "CandidateUnits", "CandidateUnitHash",
    "CandidateUnitSchema", "CandidateUnitSchemaHash", "ExpectedUnits",
    "BackendQualificationReceiptHash",
    "BackendQualificationRouteRegistryHash", "RequestPurpose"
  )
  suffix_fields <- c(
    "RequestHash", "CandidateColumnAllowlistReady",
    "BackendQualificationBound", "ProtectedMaterialIncluded",
    "ExecutionAuthorized", "CandidateExecutionOccurred",
    "PublicSupportReady"
  )
  if (!mfrmr_gtvtw_exact_object(
    request, c(payload_fields, suffix_fields),
    c("mfrmr_gtvtw_request", "list")
  )) {
    stop("A typed Draft.85c4m adapter request is required.",
         call. = FALSE)
  }
  units <- request$CandidateUnits
  expected_columns <- c(
    "OpaqueUnitId", "OpaqueDatasetId", "MethodId", "MethodControlHash",
    "CoordinateLayoutId", "CoordinateCount"
  )
  schema <- mfrmr_gtvtw_candidate_unit_schema(units)
  expected_request_id <- paste0("C4M-", substr(mfrmr_gtvtw_hash(list(
    Namespace = "gtheory_multivariate_planned_adapter_request_draft85c4m_v1",
    PlanHash = request$PlanHash,
    LaneOpaqueId = request$LaneOpaqueId,
    HandoffPreviewHash = request$HandoffPreviewHash,
    CandidateUnitHash = request$CandidateUnitHash,
    BackendQualificationReceiptHash =
      request$BackendQualificationReceiptHash
  )), 1L, 24L))
  character_columns <- expected_columns[1:5]
  valid <-
    identical(
      request$Contract,
      "gtheory_multivariate_planned_adapter_request_draft85c4m_v1"
    ) && identical(request$OpaqueRequestId, expected_request_id) &&
    grepl("^C4M-[0-9a-f]{24}$", request$OpaqueRequestId) &&
    grepl("^[0-9a-f]{32}$", request$LaneOpaqueId) &&
    all(nchar(c(
      request$PlanHash, request$HandoffPreviewHash,
      request$CandidateUnitHash, request$CandidateUnitSchemaHash,
      request$BackendQualificationReceiptHash,
      request$BackendQualificationRouteRegistryHash
    )) == 64L) &&
    is.data.frame(units) && identical(names(units), expected_columns) &&
    nrow(units) > 0L && !anyNA(units) &&
    all(vapply(units[character_columns], is.character, logical(1L))) &&
    is.integer(units$CoordinateCount) &&
    all(units$CoordinateCount > 0L) && !anyDuplicated(units$OpaqueUnitId) &&
    all(grepl("^U-[0-9a-f]{24}$", units$OpaqueUnitId)) &&
    all(grepl("^D-[0-9a-f]{24}$", units$OpaqueDatasetId)) &&
    all(grepl("^[0-9a-f]{64}$", units$MethodControlHash)) &&
    identical(request$CandidateUnitHash, mfrmr_gtvtw_hash(units)) &&
    identical(request$CandidateUnitSchema, schema) &&
    identical(request$CandidateUnitSchemaHash, mfrmr_gtvtw_hash(schema)) &&
    identical(request$ExpectedUnits, as.integer(nrow(units))) &&
    identical(request$RequestPurpose, "planned_adapter_schema_only") &&
    identical(
      request$RequestHash,
      mfrmr_gtvtw_hash(unclass(request[payload_fields]))
    ) &&
    isTRUE(request$CandidateColumnAllowlistReady) &&
    isTRUE(request$BackendQualificationBound) &&
    !isTRUE(request$ProtectedMaterialIncluded) &&
    !isTRUE(request$ExecutionAuthorized) &&
    !isTRUE(request$CandidateExecutionOccurred) &&
    !isTRUE(request$PublicSupportReady)
  if (!valid) {
    stop("The Draft.85c4m adapter request failed its sealed schema.",
         call. = FALSE)
  }
  payload <- list(
    Contract =
      "gtheory_multivariate_planned_adapter_receipt_draft85c4m_v1",
    OpaqueRequestId = request$OpaqueRequestId,
    LaneOpaqueId = request$LaneOpaqueId,
    RequestHash = request$RequestHash,
    CandidateUnitHash = request$CandidateUnitHash,
    CandidateUnitSchemaHash = request$CandidateUnitSchemaHash,
    ExpectedUnits = request$ExpectedUnits,
    ObservedUnits = as.integer(nrow(units)),
    BackendQualificationReceiptHash =
      request$BackendQualificationReceiptHash,
    Attempted = FALSE,
    CandidateDataReceived = FALSE,
    BackendInvoked = FALSE,
    FailureStage = "planned_adapter_not_executed_schema_preflight",
    FailureCode = "C4M-PLANNED-ADAPTER-SCHEMA-ONLY"
  )
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtvtw_hash(payload),
    AdapterRequestAccepted = TRUE,
    ExecutionAuthorized = FALSE,
    CandidateExecutionOccurred = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvtw_receipt", "list"))
}
