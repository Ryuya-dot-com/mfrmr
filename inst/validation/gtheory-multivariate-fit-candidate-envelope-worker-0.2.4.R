# Draft.85c4o fit-candidate envelope contract worker.
#
# Repository-internal only. This sealed worker validates the future
# fit-capable input contract on nonreserved candidate data and returns a typed
# non-attempt receipt. It deliberately contains no estimator implementation.

mfrmr_gtvvw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4o contract worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvvw_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvvw_candidate_schema <- function(data) {
  list(
    Names = names(data),
    Classes = unname(vapply(
      data, function(value) class(value)[[1L]], character(1L)
    )),
    RowNames = row.names(data)
  )
}

mfrmr_gtvvw_assert_envelope <- function(envelope) {
  payload_fields <- c(
    "Contract", "OpaqueExerciseId", "EvidenceUse", "MethodId",
    "QualificationRouteId", "Backend", "Criterion", "MethodControlHash",
    "CoordinateLayoutId", "CoordinateCount", "CandidateData",
    "CandidateDataHash", "CandidateSchema", "CandidateSchemaHash",
    "ExpectedRows", "BackendQualificationReceiptHash",
    "BackendQualificationRouteRegistryHash", "InputAuthority",
    "FitAuthority"
  )
  suffix_fields <- c(
    "EnvelopeHash", "CandidatePayloadOnly", "ProtectedMaterialExcluded",
    "BackendQualificationBound", "BackendExecutionAuthorized",
    "PlannedCandidate", "RecoveryDenominatorEligible", "PublicSupportReady"
  )
  if (!mfrmr_gtvvw_exact_object(
    envelope, c(payload_fields, suffix_fields),
    c("mfrmr_gtvvw_envelope", "list")
  )) {
    stop("A typed Draft.85c4o candidate envelope is required.",
         call. = FALSE)
  }
  routes <- data.frame(
    MethodId = c("lme4_reml", "glmmtmb_reml", "lme4_ml", "glmmtmb_ml"),
    QualificationRouteId = c(
      "lme4_reml", "glmmTMB_reml", "lme4_ml", "glmmTMB_ml"
    ),
    Backend = c("lme4", "glmmTMB", "lme4", "glmmTMB"),
    Criterion = c("REML", "REML", "ML", "ML"),
    MethodControlHash = c(
      "908e5593e3fad9bd59a874b3189426a5072822310f10a6510ca8374b6c7f574b",
      "b4349fd18b3441e4e20e53c5a0835698999f9a60a5e2820afc1a280b61c6f515",
      "90d1795dee4e22d08e29e8d8a98654a6ee2f93043b79d20087d0e58aece1827f",
      "723e2fc6cb94ba043cb49b10fa33939408702c61771ef8e6537e3480cb64a76c"
    ),
    stringsAsFactors = FALSE
  )
  route_index <- match(envelope$MethodId, routes$MethodId)
  data <- envelope$CandidateData
  expected_columns <- c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater",
    "ObservationLink", "Score"
  )
  schema <- mfrmr_gtvvw_candidate_schema(data)
  data_hash <- mfrmr_gtvvw_hash(data)
  schema_hash <- mfrmr_gtvvw_hash(schema)
  expected_opaque_id <- paste0("C4O-", substr(mfrmr_gtvvw_hash(list(
    Namespace = "gtheory_multivariate_fit_candidate_exercise_draft85c4o_v1",
    CandidateDataHash = data_hash,
    CandidateSchemaHash = schema_hash,
    MethodId = envelope$MethodId,
    MethodControlHash = envelope$MethodControlHash,
    BackendQualificationReceiptHash =
      envelope$BackendQualificationReceiptHash
  )), 1L, 24L))
  expected_strata <- if (identical(
    envelope$CoordinateLayoutId, "T2-GLOBAL-3C-R1"
  )) c("A", "B") else c("A", "B", "C")
  expected_coordinate_count <- if (length(expected_strata) == 2L) 10L else 19L
  hashes <- unlist(envelope[c(
    "MethodControlHash", "CandidateDataHash", "CandidateSchemaHash",
    "BackendQualificationReceiptHash",
    "BackendQualificationRouteRegistryHash", "EnvelopeHash"
  )], use.names = FALSE)
  valid <- identical(
    envelope$Contract,
    "gtheory_multivariate_fit_candidate_envelope_draft85c4o_v1"
  ) && identical(envelope$OpaqueExerciseId, expected_opaque_id) &&
    identical(envelope$EvidenceUse,
              "nonreserved_fixture_interface_only") &&
    !is.na(route_index) &&
    identical(envelope$QualificationRouteId,
              routes$QualificationRouteId[[route_index]]) &&
    identical(envelope$Backend, routes$Backend[[route_index]]) &&
    identical(envelope$Criterion, routes$Criterion[[route_index]]) &&
    identical(envelope$MethodControlHash,
              routes$MethodControlHash[[route_index]]) &&
    is.character(hashes) && length(hashes) == 6L && !anyNA(hashes) &&
    all(grepl("^[0-9a-f]{64}$", hashes)) &&
    is.character(envelope$CoordinateLayoutId) &&
    length(envelope$CoordinateLayoutId) == 1L &&
    grepl("^T[23]-GLOBAL-3C-R1$", envelope$CoordinateLayoutId) &&
    is.integer(envelope$CoordinateCount) &&
    length(envelope$CoordinateCount) == 1L &&
    envelope$CoordinateCount > 0L &&
    identical(envelope$CoordinateCount, expected_coordinate_count) &&
    is.data.frame(data) && identical(names(data), expected_columns) &&
    all(vapply(data[expected_columns[1:6]], is.character, logical(1L))) &&
    is.numeric(data$Score) && nrow(data) > 0L && !anyNA(data) &&
    all(is.finite(data$Score)) &&
    !any(!nzchar(data$RowId)) && anyDuplicated(data$RowId) == 0L &&
    identical(sort(unique(data$Stratum), method = "radix"),
              expected_strata) &&
    identical(data$ObjectRater,
              paste(data$Object, data$Rater, sep = "\036")) &&
    all(grepl("^OL-[0-9a-f]{24}$", data$ObservationLink)) &&
    !anyDuplicated(paste(
      data$Stratum, data$Object, data$ObservationLink, sep = "\036"
    )) &&
    all(vapply(
      split(data$ObjectRater, data$ObservationLink),
      function(value) length(unique(value)) == 1L,
      logical(1L)
    )) &&
    identical(envelope$ExpectedRows, as.integer(nrow(data))) &&
    identical(envelope$CandidateDataHash, data_hash) &&
    identical(envelope$CandidateSchema, schema) &&
    identical(envelope$CandidateSchemaHash, schema_hash) &&
    identical(envelope$InputAuthority,
              "generator_candidate_release_only") &&
    identical(envelope$FitAuthority,
              "separate_candidate_process_successor_contract_only") &&
    identical(envelope$EnvelopeHash,
              mfrmr_gtvvw_hash(envelope[payload_fields])) &&
    isTRUE(envelope$CandidatePayloadOnly) &&
    isTRUE(envelope$ProtectedMaterialExcluded) &&
    isTRUE(envelope$BackendQualificationBound) &&
    !isTRUE(envelope$BackendExecutionAuthorized) &&
    !isTRUE(envelope$PlannedCandidate) &&
    !isTRUE(envelope$RecoveryDenominatorEligible) &&
    !isTRUE(envelope$PublicSupportReady)
  if (!valid) {
    stop("The Draft.85c4o candidate envelope was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvvw_receive <- function(envelope) {
  mfrmr_gtvvw_assert_envelope(envelope)
  payload <- list(
    Contract =
      "gtheory_multivariate_fit_candidate_receipt_draft85c4o_v1",
    OpaqueExerciseId = envelope$OpaqueExerciseId,
    MethodId = envelope$MethodId,
    QualificationRouteId = envelope$QualificationRouteId,
    EnvelopeHash = envelope$EnvelopeHash,
    CandidateDataHash = envelope$CandidateDataHash,
    CandidateSchemaHash = envelope$CandidateSchemaHash,
    ExpectedRows = envelope$ExpectedRows,
    ObservedRows = as.integer(nrow(envelope$CandidateData)),
    BackendQualificationReceiptHash =
      envelope$BackendQualificationReceiptHash,
    BackendQualificationRouteRegistryHash =
      envelope$BackendQualificationRouteRegistryHash,
    EnvelopeAccepted = TRUE,
    Attempted = FALSE,
    BackendInvoked = FALSE,
    FitReturned = FALSE,
    FailureStage = "fit_capable_worker_not_implemented",
    FailureCode = "C4O-FIT-WORKER-NOT-IMPLEMENTED"
  )
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtvvw_hash(payload),
    WorkerSelfReported = TRUE,
    FitCapableWorkerImplemented = FALSE,
    FitCapableProcessCapabilityIsolationReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
    CandidateExecutionAuthorized = FALSE,
    CandidateExecutionOccurred = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    DenominatorAccountingReady = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvvw_receipt", "list"))
}
