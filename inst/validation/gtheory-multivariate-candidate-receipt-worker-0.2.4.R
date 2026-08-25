# Draft.85c4a candidate-only receipt worker.
#
# This standalone worker is sourced into an environment whose parent is
# baseenv(). It accepts only a candidate envelope, performs no fit, and returns
# a typed non-attempt receipt. It must not source or discover the c1/c2 plan,
# generator, seed, reference vault, truth, or accuracy rule.

mfrmr_gtvgw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The candidate receipt worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvgw_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvgw_candidate_schema <- function(data) {
  list(
    Names = names(data),
    Classes = unname(vapply(data, function(value) class(value)[[1L]],
                            character(1L))),
    RowNames = row.names(data)
  )
}

mfrmr_gtvgw_receive <- function(envelope) {
  payload_fields <- c(
    "Contract", "OpaqueCandidateId", "EvidenceUse", "CandidateData",
    "CandidateDataHash", "CandidateSchemaHash", "ExpectedRows"
  )
  suffix_fields <- c(
    "EnvelopeHash", "CandidatePayloadOnly", "BackendExecutionAuthorized",
    "RecoveryDenominatorEligible", "PublicSupportReady"
  )
  if (!mfrmr_gtvgw_exact_object(
    envelope, c(payload_fields, suffix_fields),
    c("mfrmr_gtvg_candidate_envelope", "list")
  )) {
    stop("A typed Draft.85c4a candidate envelope is required.",
         call. = FALSE)
  }
  expected_columns <- c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate",
    "Score"
  )
  data <- envelope$CandidateData
  schema <- mfrmr_gtvgw_candidate_schema(data)
  expected_opaque_id <- paste0("C4A-", substr(mfrmr_gtvgw_hash(list(
    Namespace = "gtheory_multivariate_candidate_draft85c4a_v1",
    CandidateDataHash = mfrmr_gtvgw_hash(data),
    CandidateSchemaHash = mfrmr_gtvgw_hash(schema)
  )), 1L, 24L))
  valid <-
    identical(envelope$Contract,
              "gtheory_multivariate_candidate_envelope_draft85c4a_v1") &&
    is.character(envelope$OpaqueCandidateId) &&
      length(envelope$OpaqueCandidateId) == 1L &&
      !is.na(envelope$OpaqueCandidateId) &&
      grepl("^C4A-[0-9a-f]{24}$", envelope$OpaqueCandidateId) &&
      identical(envelope$OpaqueCandidateId, expected_opaque_id) &&
    identical(envelope$EvidenceUse, "nonreserved_fixture_schema_only") &&
    is.data.frame(data) && identical(names(data), expected_columns) &&
    all(vapply(data[expected_columns[1:5]], is.character, logical(1L))) &&
    is.integer(data$Replicate) && is.numeric(data$Score) &&
    nrow(data) > 0L && !anyNA(data) && all(is.finite(data$Score)) &&
    identical(envelope$ExpectedRows, as.integer(nrow(data))) &&
    identical(envelope$CandidateDataHash, mfrmr_gtvgw_hash(data)) &&
    identical(envelope$CandidateSchemaHash, mfrmr_gtvgw_hash(schema)) &&
    identical(
      envelope$EnvelopeHash,
      mfrmr_gtvgw_hash(unclass(envelope[payload_fields]))
    ) &&
    isTRUE(envelope$CandidatePayloadOnly) &&
    !isTRUE(envelope$BackendExecutionAuthorized) &&
    !isTRUE(envelope$RecoveryDenominatorEligible) &&
    !isTRUE(envelope$PublicSupportReady)
  if (!valid) {
    stop("The Draft.85c4a candidate envelope failed schema or identity checks.",
         call. = FALSE)
  }
  payload <- list(
    Contract = "gtheory_multivariate_candidate_receipt_draft85c4a_v1",
    OpaqueCandidateId = envelope$OpaqueCandidateId,
    EvidenceUse = envelope$EvidenceUse,
    EnvelopeHash = envelope$EnvelopeHash,
    CandidateDataHash = envelope$CandidateDataHash,
    CandidateSchemaHash = envelope$CandidateSchemaHash,
    ObservedRows = as.integer(nrow(data)),
    Attempted = FALSE,
    FitReturned = FALSE,
    EstimateAvailable = FALSE,
    PointGatePassed = FALSE,
    FailureStage = "backend_not_invoked_fixture_schema_preflight",
    FailureCode = "C4A-CANDIDATE-RECEIPT-SCHEMA-ONLY"
  )
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtvgw_hash(payload),
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvg_candidate_receipt", "list"))
}
