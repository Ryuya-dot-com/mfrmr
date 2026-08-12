# Repository-only six-arm ConQuest normalizer/source-precision coverage
# registry. It describes implementation coverage independently of candidate
# outputs and distinguishes retained calibration evidence from prospective
# adapter readiness.

mfrmr_cq_sacc_specification <-
  "0.2.3-wave-c-six-arm-coverage-v1"
mfrmr_cq_sacc_contract <- "mfrmr_conquest_six_arm_coverage_v1"

mfrmr_cq_sacc_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_sacc_require_helpers <- function() {
  helper_environment <- environment(mfrmr_cq_sacc_require_helpers)
  required <- c(
    "mfrmr_cq_becec_expected_registry", "mfrmr_cq_ecec_expected_registry"
  )
  mfrmr_cq_sacc_assert(
    all(vapply(
      required, exists, logical(1L), envir = helper_environment,
      mode = "function", inherits = TRUE
    )),
    paste(
      "Source the Binary and additive ConQuest external-comparison",
      "normalizers before using the six-arm coverage contract."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_sacc_base_registry <- function() {
  mfrmr_cq_sacc_require_helpers()
  binary <- mfrmr_cq_becec_expected_registry()
  additive <- mfrmr_cq_ecec_expected_registry()
  columns <- c("RunId", "Model", "Nodes", "Coordinate", "ParameterClass")
  out <- rbind(binary[, columns, drop = FALSE],
               additive[, columns, drop = FALSE])
  family_order <- match(out$Model, c("Binary", "RSM", "PCM"))
  out <- out[order(family_order, out$Nodes, out$Coordinate, method = "radix"),
             , drop = FALSE]
  rownames(out) <- NULL
  out$CoverageRowId <- paste(
    out$Model, paste0("q", sprintf("%03d", out$Nodes)), out$Coordinate,
    sep = "::"
  )
  out <- out[, c("CoverageRowId", columns), drop = FALSE]
  mfrmr_cq_sacc_assert(
    nrow(out) == 54L && !anyDuplicated(out$CoverageRowId) &&
      identical(unique(out$Model), c("Binary", "RSM", "PCM")) &&
      identical(sort(unique(out$Nodes)), c(31L, 61L)),
    "The ConQuest six-arm base registry must contain 54 unique rows."
  )
  out
}

mfrmr_cq_sacc_normalizer_registry <- function() {
  out <- mfrmr_cq_sacc_base_registry()
  binary <- out$Model == "Binary"
  out$NormalizerContract <- ifelse(
    binary,
    "mfrmr_conquest_binary_external_comparison_normalizer_v1",
    "mfrmr_conquest_external_comparison_normalizer_v1"
  )
  out$ExpectedCoordinateRegistered <- TRUE
  out$MissingResultFailClosed <- TRUE
  out$FailedFitFailClosed <- TRUE
  out$CandidateOutputObserved <- FALSE
  out$RetainedNativeCalibrationAvailable <- !binary
  out$ImplementationReady <- TRUE
  out
}

mfrmr_cq_sacc_source_precision_registry <- function() {
  out <- mfrmr_cq_sacc_base_registry()
  binary <- out$Model == "Binary"
  out$PolicyId <- "conquest-reported-decimal-estimand-v1"
  out$PolicyScope <- "exact_reported_decimal"
  out$PolicyContract <- ifelse(
    binary,
    "mfrmr_conquest_binary_reported_output_precision_v1",
    "mfrmr_conquest_reported_output_precision_v1"
  )
  out$ExactDecimalParserReady <- TRUE
  out$HiddenSolutionIntervalAvailable <- FALSE
  out$HiddenSolutionEquivalenceEligible <- FALSE
  out$RoundingRuleInferred <- FALSE
  out$CandidateTokenObserved <- FALSE
  out$RetainedNativeTokenEvidenceAvailable <- !binary
  out$ImplementationReady <- TRUE
  out
}

mfrmr_cq_sacc_canonical_text <- function(rows) {
  mfrmr_cq_sacc_assert(
    is.data.frame(rows) && nrow(rows) == 54L &&
      "CoverageRowId" %in% names(rows) && !anyDuplicated(rows$CoverageRowId),
    "The six-arm coverage registry does not satisfy the hash schema."
  )
  x <- rows[order(rows$CoverageRowId, method = "radix"), , drop = FALSE]
  encode <- function(value) {
    if (is.numeric(value)) {
      return(ifelse(is.na(value), "NA", sprintf("%.17g", value)))
    }
    if (is.logical(value)) {
      return(ifelse(is.na(value), "NA", ifelse(value, "TRUE", "FALSE")))
    }
    value <- as.character(value)
    value[is.na(value)] <- "NA"
    gsub("[\\t\\r\\n]", " ", value)
  }
  encoded <- lapply(x, encode)
  lines <- vapply(seq_len(nrow(x)), function(index) {
    paste(vapply(encoded, `[[`, character(1L), index), collapse = "\t")
  }, character(1L))
  paste(c(paste(names(x), collapse = "\t"), lines), collapse = "\n")
}

mfrmr_cq_sacc_sha256 <- function(rows) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The six-arm coverage contract requires `digest`.", call. = FALSE)
  }
  unname(digest::digest(
    mfrmr_cq_sacc_canonical_text(rows), algo = "sha256", serialize = FALSE
  ))
}

mfrmr_cq_sacc_review <- function() {
  normalizer <- mfrmr_cq_sacc_normalizer_registry()
  precision <- mfrmr_cq_sacc_source_precision_registry()
  normalizer_arms <- unique(
    normalizer[, c("Model", "Nodes", "ImplementationReady"), drop = FALSE]
  )
  precision_arms <- unique(
    precision[, c("Model", "Nodes", "ImplementationReady"), drop = FALSE]
  )
  retained_arms <- unique(normalizer[
    normalizer$RetainedNativeCalibrationAvailable,
    c("Model", "Nodes"), drop = FALSE
  ])
  summary <- data.frame(
    Specification = mfrmr_cq_sacc_specification,
    ContractVersion = mfrmr_cq_sacc_contract,
    Families = paste(unique(normalizer$Model), collapse = ";"),
    Nodes = paste(sort(unique(normalizer$Nodes)), collapse = ";"),
    Arms = nrow(unique(normalizer[, c("Model", "Nodes"), drop = FALSE])),
    CoordinateRows = nrow(normalizer),
    NormalizerImplementationComplete =
      nrow(normalizer_arms) == 6L && all(normalizer_arms$ImplementationReady),
    SourcePrecisionImplementationComplete =
      nrow(precision_arms) == 6L && all(precision_arms$ImplementationReady),
    RetainedNativeCalibrationArms = nrow(retained_arms),
    BinaryRetainedNativeEvidenceAvailable = any(
      normalizer$Model == "Binary" &
        normalizer$RetainedNativeCalibrationAvailable
    ),
    CandidateOutputsObserved = any(normalizer$CandidateOutputObserved) ||
      any(precision$CandidateTokenObserved),
    NormalizerCoverageRegistrySHA256 = mfrmr_cq_sacc_sha256(normalizer),
    SourcePrecisionCoverageRegistrySHA256 = mfrmr_cq_sacc_sha256(precision),
    ComparisonReady = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  out <- list(
    specification = mfrmr_cq_sacc_specification,
    contract_version = mfrmr_cq_sacc_contract,
    status = "six_arm_adapter_ready_binary_native_evidence_missing",
    summary = summary,
    normalizer_registry = normalizer,
    source_precision_registry = precision
  )
  class(out) <- c("mfrmr_conquest_six_arm_coverage", class(out))
  out
}
