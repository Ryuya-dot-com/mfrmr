# Repository-only ConQuest adapter for the external-comparison eligibility
# contract. It consumes a completed additive native-review object, never
# launches ConQuest, never chooses a tolerance, and never authorizes a claim.

mfrmr_cq_ecec_normalizer_version <-
  "mfrmr_conquest_external_comparison_normalizer_v1"

mfrmr_cq_ecec_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ecec_require_helpers <- function(include_eligibility = FALSE) {
  helper_environment <- environment(mfrmr_cq_ecec_require_helpers)
  required <- c(
    "mfrmr_cq_additive_plan",
    "mfrmr_cq_additive_parameter_map"
  )
  if (isTRUE(include_eligibility)) {
    required <- c(required, "mfrmr_external_comparison_eligibility")
  }
  mfrmr_cq_ecec_assert(
    all(vapply(
      required, exists, logical(1), envir = helper_environment,
      mode = "function", inherits = TRUE
    )),
    paste(
      "Source the additive design and external-comparison eligibility",
      "contracts before using the ConQuest normalizer."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_ecec_coordinate_registry <- function(model) {
  map <- mfrmr_cq_additive_parameter_map(model)
  free <- map[!is.na(map$FreeOrder), , drop = FALSE]
  free <- free[order(free$FreeOrder), , drop = FALSE]
  coordinate <- ifelse(
    free$Component == "Population",
    as.character(free$MfrmrRole),
    as.character(free$Level)
  )
  out <- data.frame(
    Coordinate = c(coordinate, "deviance"),
    ParameterClass = c(as.character(free$MfrmrRole), "objective"),
    stringsAsFactors = FALSE
  )
  mfrmr_cq_ecec_assert(
    !anyDuplicated(out$Coordinate) && all(nzchar(out$Coordinate)) &&
      all(nzchar(out$ParameterClass)),
    "The ConQuest expected-coordinate registry is malformed."
  )
  out
}

mfrmr_cq_ecec_expected_registry <- function() {
  mfrmr_cq_ecec_require_helpers(include_eligibility = FALSE)
  plan <- mfrmr_cq_additive_plan()
  expected_plan <- data.frame(
    RunId = c("rsm_q031", "rsm_q061", "pcm_q031", "pcm_q061"),
    Model = c("RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L),
    ExpectedNpar = c(7L, 7L, 9L, 9L),
    stringsAsFactors = FALSE
  )
  mfrmr_cq_ecec_assert(
    all(names(expected_plan) %in% names(plan)) &&
      identical(plan[, names(expected_plan), drop = FALSE], expected_plan),
    "The additive ConQuest plan changed; define a new normalizer contract."
  )

  status_columns <- c(
    "ObservationsStatus", "WeightsStatus", "ActiveFacetsStatus",
    "SignOrientationStatus", "CategoryMapStatus", "StepDimensionStatus",
    "AnchorsStatus", "ConstraintsStatus", "CoordinatesStatus",
    "IdentificationStatus", "ConditioningStatus",
    "BoundaryConventionStatus", "SourcePrecisionStatus"
  )
  rows <- lapply(seq_len(nrow(plan)), function(index) {
    arm <- plan[index, , drop = FALSE]
    coordinate <- mfrmr_cq_ecec_coordinate_registry(arm$Model)
    row <- data.frame(
      ComparisonRowId = paste(arm$RunId, coordinate$Coordinate, sep = "::"),
      ScenarioId = paste0(
        "EXT-CQ-", arm$Model, "-Q", sprintf("%03d", arm$Nodes)
      ),
      Program = "ConQuest",
      ExpectedFamily = as.character(arm$Model),
      ObservedFamily = "",
      ExpectedEstimator = "MML",
      ObservedEstimator = "",
      ExpectedCorrectionMode = "none",
      ObservedCorrectionMode = "",
      ExpectedPenaltyMode = "none",
      ObservedPenaltyMode = "",
      ExpectedFiniteParameterBox = "none",
      ObservedFiniteParameterBox = "",
      Metric = "absolute_coordinate_difference",
      ParameterClass = coordinate$ParameterClass,
      ExpectedRow = TRUE,
      ObservedRow = FALSE,
      FitSucceeded = FALSE,
      MetricValue = NA_real_,
      RunId = as.character(arm$RunId),
      Model = as.character(arm$Model),
      Nodes = as.integer(arm$Nodes),
      Coordinate = coordinate$Coordinate,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    for (column in status_columns) row[[column]] <- "unknown"
    row
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  mfrmr_cq_ecec_assert(
    nrow(out) == 36L && !anyDuplicated(out$ComparisonRowId),
    "The ConQuest expected registry must contain exactly 36 unique rows."
  )
  out
}

mfrmr_cq_ecec_source_precision_status <- function(raw_token_status) {
  value <- unique(trimws(as.character(raw_token_status)))
  value <- value[!is.na(value) & nzchar(value)]
  if (length(value) != 1L) return("unknown")
  if (identical(value, "raw_tokens_retained_rounding_unestablished")) {
    return("mismatch")
  }
  # This v1 normalizer has no audited state that licenses full-precision
  # aggregation. A future positive state requires a new source-bound contract.
  "unknown"
}

mfrmr_cq_ecec_review_identity <- function(review, summary) {
  plan_match <- isTRUE(review$cross_manifest_plan_identical)
  input_match <- isTRUE(review$cross_manifest_wide_sha256_identical)
  unit_weights <- isTRUE(review$unit_weights_contract)
  matrix_match <- isTRUE(review$native_design_matrices_exact) &&
    all(as.logical(summary$NativeDesignMatrixExact))
  match_or_mismatch <- function(value) {
    if (isTRUE(value)) "match" else "mismatch"
  }
  data.frame(
    RunId = as.character(summary$RunId),
    ObservationsStatus = match_or_mismatch(input_match),
    WeightsStatus = match_or_mismatch(input_match && unit_weights),
    ActiveFacetsStatus = match_or_mismatch(plan_match && matrix_match),
    SignOrientationStatus = match_or_mismatch(plan_match && matrix_match),
    CategoryMapStatus = match_or_mismatch(plan_match && matrix_match),
    StepDimensionStatus = match_or_mismatch(plan_match && matrix_match),
    AnchorsStatus = "not_applicable",
    ConstraintsStatus = match_or_mismatch(plan_match && matrix_match),
    CoordinatesStatus = match_or_mismatch(plan_match && matrix_match),
    IdentificationStatus = match_or_mismatch(plan_match && matrix_match),
    ConditioningStatus = match_or_mismatch(plan_match),
    BoundaryConventionStatus = "not_applicable",
    SourcePrecisionStatus = mfrmr_cq_ecec_source_precision_status(
      summary$RawTokenStatus
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_normalize_conquest_native_four_arm_eligibility <- function(
    review,
    expected_registry = mfrmr_cq_ecec_expected_registry()) {
  mfrmr_cq_ecec_require_helpers(include_eligibility = TRUE)
  mfrmr_cq_ecec_assert(
    inherits(review, "mfrmr_conquest_native_four_arm_review"),
    "review must be a completed ConQuest native four-arm review object."
  )
  mfrmr_cq_ecec_assert(
    identical(
      as.character(review$specification),
      "0.2.3-wave-c-native-four-arm-review-v1"
    ) && identical(
      as.character(review$contract_version),
      "mfrmr_conquest_native_four_arm_review_v1"
    ),
    "The ConQuest review identity changed; define a new normalizer contract."
  )
  registry <- as.data.frame(
    expected_registry, stringsAsFactors = FALSE, check.names = FALSE
  )
  required_registry <- c("RunId", "Model", "Nodes", "Coordinate")
  mfrmr_cq_ecec_assert(
    all(required_registry %in% names(registry)) && nrow(registry) > 0L &&
      all(registry$ExpectedRow) && !any(registry$ObservedRow) &&
      !anyDuplicated(registry$ComparisonRowId),
    "expected_registry must be an untouched expected-only registry."
  )

  summary <- as.data.frame(
    review$summary, stringsAsFactors = FALSE, check.names = FALSE
  )
  differences <- as.data.frame(
    review$descriptive_differences,
    stringsAsFactors = FALSE, check.names = FALSE
  )
  required_summary <- c(
    "RunId", "Model", "Nodes", "NativeDesignMatrixExact",
    "RawTokenStatus", "ConsoleEndOfProgramObserved"
  )
  required_differences <- c("RunId", "Model", "Coordinate", "AbsDifference")
  mfrmr_cq_ecec_assert(
    all(required_summary %in% names(summary)) &&
      all(required_differences %in% names(differences)) &&
      !anyDuplicated(summary$RunId),
    "The ConQuest review summary or difference ledger is malformed."
  )
  mfrmr_cq_ecec_assert(
    identical(
      unique(as.character(summary$RawTokenStatus)),
      as.character(review$raw_token_status)
    ),
    "The ConQuest review and per-run raw-token states disagree."
  )
  expected_plan <- unique(registry[, c("RunId", "Model", "Nodes"), drop = FALSE])
  expected_plan <- expected_plan[order(expected_plan$RunId), , drop = FALSE]
  observed_plan <- summary[, c("RunId", "Model", "Nodes"), drop = FALSE]
  observed_plan <- observed_plan[order(observed_plan$RunId), , drop = FALSE]
  rownames(expected_plan) <- NULL
  rownames(observed_plan) <- NULL
  mfrmr_cq_ecec_assert(
    identical(expected_plan, observed_plan),
    "The ConQuest review plan does not match the pre-result registry."
  )

  difference_key <- paste(
    differences$RunId, differences$Coordinate, sep = "\037"
  )
  mfrmr_cq_ecec_assert(
    !anyDuplicated(difference_key),
    "The ConQuest difference ledger contains duplicate run/coordinate rows."
  )
  summary_model <- stats::setNames(
    as.character(summary$Model), as.character(summary$RunId)
  )
  mfrmr_cq_ecec_assert(
    all(as.character(differences$RunId) %in% names(summary_model)) &&
      all(
        as.character(differences$Model) ==
          unname(summary_model[as.character(differences$RunId)])
      ),
    "The ConQuest difference ledger conflicts with its run/model summary."
  )

  identity <- mfrmr_cq_ecec_review_identity(review, summary)
  registry_key <- paste(registry$RunId, registry$Coordinate, sep = "\037")
  result_match <- match(registry_key, difference_key)
  observed <- !is.na(result_match)
  run_match <- match(registry$RunId, summary$RunId)
  identity_match <- match(registry$RunId, identity$RunId)
  registry$ObservedRow <- observed
  registry$FitSucceeded <- observed &
    as.logical(summary$ConsoleEndOfProgramObserved[run_match])
  registry$MetricValue[observed] <- suppressWarnings(as.numeric(
    differences$AbsDifference[result_match[observed]]
  ))
  registry$ObservedFamily[observed] <- as.character(
    differences$Model[result_match[observed]]
  )
  registry$ObservedEstimator[observed] <- "MML"
  registry$ObservedCorrectionMode[observed] <- "none"
  registry$ObservedPenaltyMode[observed] <- "none"
  registry$ObservedFiniteParameterBox[observed] <- "none"

  status_columns <- setdiff(names(identity), "RunId")
  for (column in status_columns) {
    registry[[column]][observed] <- identity[[column]][
      identity_match[observed]
    ]
  }

  unexpected_index <- which(!difference_key %in% registry_key)
  if (length(unexpected_index) > 0L) {
    unexpected <- differences[unexpected_index, , drop = FALSE]
    unexpected_run <- match(unexpected$RunId, summary$RunId)
    unexpected_identity <- match(unexpected$RunId, identity$RunId)
    extra <- registry[rep(1L, nrow(unexpected)), , drop = FALSE]
    extra$ComparisonRowId <- paste(
      "UNEXPECTED", unexpected$RunId, unexpected$Coordinate, sep = "::"
    )
    extra$ScenarioId <- paste0(
      "EXT-CQ-", unexpected$Model, "-Q",
      sprintf("%03d", summary$Nodes[unexpected_run])
    )
    extra$ExpectedFamily <- as.character(unexpected$Model)
    extra$ObservedFamily <- as.character(unexpected$Model)
    extra$ExpectedEstimator <- "MML"
    extra$ObservedEstimator <- "MML"
    extra$ExpectedCorrectionMode <- "none"
    extra$ObservedCorrectionMode <- "none"
    extra$ExpectedPenaltyMode <- "none"
    extra$ObservedPenaltyMode <- "none"
    extra$ExpectedFiniteParameterBox <- "none"
    extra$ObservedFiniteParameterBox <- "none"
    extra$ParameterClass <- "unexpected_coordinate"
    extra$ExpectedRow <- FALSE
    extra$ObservedRow <- TRUE
    extra$FitSucceeded <- as.logical(
      summary$ConsoleEndOfProgramObserved[unexpected_run]
    )
    extra$MetricValue <- suppressWarnings(as.numeric(unexpected$AbsDifference))
    extra$RunId <- as.character(unexpected$RunId)
    extra$Model <- as.character(unexpected$Model)
    extra$Nodes <- as.integer(summary$Nodes[unexpected_run])
    extra$Coordinate <- as.character(unexpected$Coordinate)
    for (column in status_columns) {
      extra[[column]] <- identity[[column]][unexpected_identity]
    }
    registry <- rbind(registry, extra)
  }

  ledger <- mfrmr_external_comparison_eligibility(registry)
  eligible_rows <- sum(ledger$Rows$Eligible)
  included_rows <- sum(ledger$Rows$IncludeInAggregate)
  observed_any <- any(ledger$Rows$ObservedRow)
  source_ready <- observed_any && all(
    ledger$Rows$SourcePrecisionStatus[ledger$Rows$ObservedRow] == "match"
  )
  ledger$Binding <- data.frame(
    NormalizerVersion = mfrmr_cq_ecec_normalizer_version,
    ExpectedRows = sum(ledger$Rows$ExpectedRow),
    ObservedRows = sum(ledger$Rows$ObservedRow),
    EligibleRows = eligible_rows,
    IncludedRows = included_rows,
    IneligibleIncludedRows = sum(
      ledger$Rows$IncludeInAggregate & !ledger$Rows$Eligible
    ),
    SourcePrecisionReady = source_ready,
    CandidateBound = isTRUE(review$candidate_bound),
    ComparisonReady = isTRUE(review$comparison_ready),
    Decision = if (
      eligible_rows == 0L && included_rows == 0L && !source_ready
    ) {
      "conquest_binding_complete_numeric_rows_excluded_source_precision"
    } else {
      "conquest_binding_requires_review"
    },
    stringsAsFactors = FALSE
  )
  ledger
}
