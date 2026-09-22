# Repository-only Binary ConQuest reported-output and external-comparison
# normalizer. It defines the q=31/q=61 coordinate registry before results are
# opened and can consume retained native CSV tokens after a binary ladder
# review. It never launches ConQuest, infers hidden precision, or freezes a
# tolerance.

mfrmr_cq_becec_specification <-
  "0.2.3-wave-c-binary-external-comparison-normalizer-v1"
mfrmr_cq_becec_contract <-
  "mfrmr_conquest_binary_external_comparison_normalizer_v1"
mfrmr_cq_becec_normalizer_version <-
  "mfrmr_conquest_binary_external_comparison_normalizer_v1"
mfrmr_cq_brop_contract <-
  "mfrmr_conquest_binary_reported_output_precision_v1"

mfrmr_cq_becec_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_becec_require_helpers <- function(include_eligibility = FALSE) {
  helper_environment <- environment(mfrmr_cq_becec_require_helpers)
  required <- c(
    "mfrmr_cq_rop_parse_exact_decimal", "mfrmr_cq_rop_rows_sha256",
    "mfrmr_cq_rop_hash_file"
  )
  if (isTRUE(include_eligibility)) {
    required <- c(required, "mfrmr_external_comparison_eligibility")
  }
  policy_id_ready <- exists(
    "mfrmr_cq_rop_policy_id", envir = helper_environment, inherits = TRUE
  ) && identical(
    get(
      "mfrmr_cq_rop_policy_id", envir = helper_environment, inherits = TRUE
    ),
    "conquest-reported-decimal-estimand-v1"
  )
  mfrmr_cq_becec_assert(
    all(vapply(
      required, exists, logical(1L), envir = helper_environment,
      mode = "function", inherits = TRUE
    )) && policy_id_ready,
    paste(
      "Source the reported-output precision and external-comparison",
      "eligibility contracts before using the Binary ConQuest normalizer."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_becec_coordinate_registry <- function() {
  data.frame(
    Coordinate = c(
      "population_intercept", "population_slope", "population_variance",
      paste0("Item", seq_len(5L)), "deviance"
    ),
    ParameterClass = c(
      "population_intercept", "population_slope", "population_variance",
      rep("item_difficulty", 5L), "objective"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_becec_expected_registry <- function() {
  plan <- data.frame(
    RunId = c("q031a", "q061"),
    Model = "Binary",
    Nodes = c(31L, 61L),
    ExpectedNpar = 8L,
    stringsAsFactors = FALSE
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
    coordinate <- mfrmr_cq_becec_coordinate_registry()
    out <- data.frame(
      ComparisonRowId = paste(arm$RunId, coordinate$Coordinate, sep = "::"),
      ScenarioId = paste0("EXT-CQ-Binary-Q", sprintf("%03d", arm$Nodes)),
      Program = "ConQuest",
      ExpectedFamily = "Binary",
      ObservedFamily = "",
      ExpectedEstimator = "MML",
      ObservedEstimator = "",
      ExpectedCorrectionMode = "none",
      ObservedCorrectionMode = "",
      ExpectedPenaltyMode = "none",
      ObservedPenaltyMode = "",
      ExpectedFiniteParameterBox = "none",
      ObservedFiniteParameterBox = "",
      Metric = "absolute_difference_to_exact_reported_decimal",
      ParameterClass = coordinate$ParameterClass,
      ExpectedRow = TRUE,
      ObservedRow = FALSE,
      FitSucceeded = FALSE,
      MetricValue = NA_real_,
      RunId = as.character(arm$RunId),
      Model = "Binary",
      Nodes = as.integer(arm$Nodes),
      Coordinate = coordinate$Coordinate,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    for (column in status_columns) out[[column]] <- "unknown"
    out
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  mfrmr_cq_becec_assert(
    nrow(out) == 18L && !anyDuplicated(out$ComparisonRowId),
    "The Binary ConQuest expected registry must contain 18 unique rows."
  )
  out
}

mfrmr_cq_becec_review_core <- function(review) {
  mfrmr_cq_becec_assert(
    inherits(review, "mfrmr_conquest_binary_ladder_review") &&
      identical(
        as.character(review$contract_version),
        "mfrmr_conquest_binary_ladder_v1"
      ) && is.data.frame(review$manifest) && is.data.frame(review$results),
    "review must satisfy the ConQuest binary ladder review contract."
  )
  expected <- data.frame(
    RunId = c("q031a", "q061"), Nodes = c(31L, 61L),
    stringsAsFactors = FALSE
  )
  manifest <- review$manifest
  results <- review$results
  manifest_index <- match(expected$RunId, as.character(manifest$RunId))
  result_index <- match(expected$RunId, as.character(results$RunId))
  mfrmr_cq_becec_assert(
    !anyNA(manifest_index) && !anyNA(result_index) &&
      !anyDuplicated(as.character(manifest$RunId)) &&
      !anyDuplicated(as.character(results$RunId)) &&
      identical(as.integer(manifest$Nodes[manifest_index]), expected$Nodes) &&
      identical(as.integer(results$Nodes[result_index]), expected$Nodes),
    "The binary review does not contain the exact q=31/q=61 core."
  )
  core_manifest <- manifest[manifest_index, , drop = FALSE]
  core_results <- results[result_index, , drop = FALSE]
  required_manifest <- c("WideMD5", "MfrmrDeviance")
  required_results <- c(
    "ExecutionComplete", "HigherLikelihoodRetained", "AdapterStatus",
    "HistoryExportMaxAbsDifference", "Npar", "Persons",
    "ArithmeticEligible", "ComparisonReady", "NativeOutputFingerprint"
  )
  mfrmr_cq_becec_assert(
    all(required_manifest %in% names(core_manifest)) &&
      all(required_results %in% names(core_results)),
    "The binary review core is missing required identity fields."
  )
  same_input <- length(unique(as.character(core_manifest$WideMD5))) == 1L &&
    all(grepl("^[[:xdigit:]]{32}$", as.character(core_manifest$WideMD5)))
  handoff_ready <- all(as.logical(core_results$ExecutionComplete)) &&
    all(!as.logical(core_results$HigherLikelihoodRetained)) &&
    all(as.character(core_results$AdapterStatus) == "accepted_arithmetic") &&
    all(as.logical(core_results$ArithmeticEligible)) &&
    all(is.finite(as.numeric(core_results$HistoryExportMaxAbsDifference))) &&
    all(as.numeric(core_results$HistoryExportMaxAbsDifference) == 0) &&
    identical(as.integer(core_results$Npar), c(8L, 8L)) &&
    length(unique(as.integer(core_results$Persons))) == 1L &&
    all(as.integer(core_results$Persons) > 0L)
  list(
    manifest = core_manifest,
    results = core_results,
    same_input = same_input,
    handoff_ready = handoff_ready
  )
}

mfrmr_cq_brop_native_files <- function(output_dir, run_id) {
  run_dir <- file.path(output_dir, run_id)
  prefix <- paste0("cq_", run_id, "_conquest_")
  list(
    history = file.path(run_dir, paste0(prefix, "history.csv")),
    parameter = file.path(run_dir, paste0(prefix, "parameters.csv")),
    regression = file.path(run_dir, paste0(prefix, "reg_coefficients.csv")),
    covariance = file.path(run_dir, paste0(prefix, "covariance.csv")),
    cases = file.path(run_dir, paste0(prefix, "cases_eap.csv")),
    reference = file.path(
      run_dir, paste0("cq_", run_id, "_mfrmr_ladder_reference.csv")
    )
  )
}

mfrmr_cq_brop_read_character_csv <- function(path) {
  utils::read.csv(
    path, colClasses = "character", na.strings = character(),
    check.names = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_cq_brop_rows_sha256 <- function(rows) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The Binary reported-output contract requires `digest`.",
         call. = FALSE)
  }
  required <- c(
    "RunId", "Model", "Coordinate", "FileRole", "FileName", "FileSHA256",
    "NativeToken", "NativeValue", "CanonicalExactDecimal",
    "MfrmrReferenceFileSHA256", "MfrmrReferenceValue",
    "SignedReportedDifference", "AbsoluteReportedDifference", "Metric",
    "SourcePrecisionStatus"
  )
  mfrmr_cq_becec_assert(
    is.data.frame(rows) && all(required %in% names(rows)),
    "The Binary reported-output rows do not satisfy the hash schema."
  )
  x <- rows[, required, drop = FALSE]
  x <- x[order(x$RunId, x$Coordinate, method = "radix"), , drop = FALSE]
  encode <- function(value) {
    if (is.numeric(value)) {
      return(ifelse(is.na(value), "NA", sprintf("%.17g", value)))
    }
    value <- as.character(value)
    value[is.na(value)] <- "NA"
    gsub("[\\t\\r\\n]", " ", value)
  }
  encoded <- lapply(x, encode)
  lines <- vapply(seq_len(nrow(x)), function(index) {
    paste(vapply(encoded, `[[`, character(1L), index), collapse = "\t")
  }, character(1L))
  text <- paste(
    c(paste(required, collapse = "\t"), lines), collapse = "\n"
  )
  unname(digest::digest(text, algo = "sha256", serialize = FALSE))
}

mfrmr_cq_brop_arm_token_rows <- function(output_dir, run_id) {
  mfrmr_cq_becec_require_helpers(include_eligibility = FALSE)
  files <- mfrmr_cq_brop_native_files(output_dir, run_id)
  mfrmr_cq_becec_assert(
    all(vapply(files, file.exists, logical(1L))),
    paste0("The binary native token files are incomplete for `", run_id, "`.")
  )
  history <- mfrmr_cq_brop_read_character_csv(files$history)
  parameter <- mfrmr_cq_brop_read_character_csv(files$parameter)
  regression <- mfrmr_cq_brop_read_character_csv(files$regression)
  covariance <- mfrmr_cq_brop_read_character_csv(files$covariance)
  reference <- mfrmr_cq_brop_read_character_csv(files$reference)
  reference_columns <- c(
    "MfrmrDeviance", "Intercept", "Slope", "Variance",
    paste0("Item", seq_len(5L))
  )
  mfrmr_cq_becec_assert(
    nrow(history) > 0L && nrow(parameter) == 5L &&
      nrow(regression) == 2L && nrow(covariance) == 1L &&
      nrow(reference) == 1L && ncol(history) == 12L &&
      identical(names(history)[1:3], c("RowLabels", "Run Number", "Iteration")) &&
      names(history)[4L] %in% c("LogLikelihood", "Deviance") &&
      all(c("P", "Estimate", "Label") %in% names(parameter)) &&
      all(c("Dimension", "Regressor", "Estimate") %in% names(regression)) &&
      all(c("Dim1", "Dim2", "Covariance") %in% names(covariance)) &&
      all(reference_columns %in% names(reference)),
    paste0("The binary native token schema changed for `", run_id, "`.")
  )
  parameter_index <- suppressWarnings(as.integer(parameter$P))
  regression_dimension <- suppressWarnings(as.integer(regression$Dimension))
  regression_index <- suppressWarnings(as.integer(regression$Regressor))
  covariance_dim1 <- suppressWarnings(as.integer(covariance$Dim1))
  covariance_dim2 <- suppressWarnings(as.integer(covariance$Dim2))
  expected_labels <- paste("item", tolower(sprintf("I%03d", seq_len(5L))))
  observed_labels <- tolower(gsub("[[:space:]]+", " ", trimws(parameter$Label)))
  mfrmr_cq_becec_assert(
    identical(parameter_index, seq_len(5L)) &&
      identical(observed_labels, expected_labels) &&
      identical(regression_dimension, c(1L, 1L)) &&
      identical(regression_index, c(1L, 2L)) &&
      identical(covariance_dim1, 1L) && identical(covariance_dim2, 1L),
    paste0("The binary native coordinate order changed for `", run_id, "`.")
  )
  token <- c(
    regression$Estimate, covariance$Covariance, parameter$Estimate,
    utils::tail(history[[4L]], 1L)
  )
  history_token <- as.character(utils::tail(history[seq.int(5L, 12L)], 1L))
  parsed <- mfrmr_cq_rop_parse_exact_decimal(token)
  parsed_history <- mfrmr_cq_rop_parse_exact_decimal(history_token)
  mfrmr_cq_becec_assert(
    all(parsed$NumericGrammarValid) && all(parsed_history$NumericGrammarValid) &&
      identical(
        parsed$CanonicalExactDecimal[seq_len(8L)],
        parsed_history$CanonicalExactDecimal
      ),
    paste0(
      "The final binary history/export exact tokens disagree for `",
      run_id, "`."
    )
  )
  coordinate <- mfrmr_cq_becec_coordinate_registry()$Coordinate
  reference_value <- suppressWarnings(as.numeric(unlist(
    reference[1L, c(
      "Intercept", "Slope", "Variance", paste0("Item", seq_len(5L)),
      "MfrmrDeviance"
    ), drop = FALSE],
    recursive = FALSE,
    use.names = FALSE
  )))
  mfrmr_cq_becec_assert(
    length(reference_value) == 9L && all(is.finite(reference_value)),
    paste0("The binary mfrmr reference is invalid for `", run_id, "`.")
  )
  file_path <- c(
    rep(files$regression, 2L), files$covariance,
    rep(files$parameter, 5L), files$history
  )
  rows <- data.frame(
    RunId = run_id,
    Model = "Binary",
    Coordinate = coordinate,
    FileRole = c(
      rep("regression_export", 2L), "covariance_export",
      rep("parameter_export", 5L), "matrixout_history"
    ),
    FileName = basename(file_path),
    FileSHA256 = vapply(file_path, mfrmr_cq_rop_hash_file, character(1L)),
    NativeToken = token,
    NativeValue = parsed$NumericValue,
    CanonicalExactDecimal = parsed$CanonicalExactDecimal,
    ReportedOutputEstimandReady = TRUE,
    HiddenSolutionIntervalAvailable = FALSE,
    HiddenSolutionEquivalenceEligible = FALSE,
    MfrmrReferenceFileSHA256 = mfrmr_cq_rop_hash_file(files$reference),
    MfrmrReferenceValue = reference_value,
    SignedReportedDifference = parsed$NumericValue - reference_value,
    AbsoluteReportedDifference = abs(parsed$NumericValue - reference_value),
    Metric = "absolute_difference_to_exact_reported_decimal",
    SourcePrecisionStatus = "match",
    stringsAsFactors = FALSE
  )
  rows
}

mfrmr_cq_brop_review_core <- function(output_dir, review) {
  core <- mfrmr_cq_becec_review_core(review)
  mfrmr_cq_becec_assert(
    isTRUE(core$same_input) && isTRUE(core$handoff_ready),
    "The binary q=31/q=61 review core is not arithmetic-handoff ready."
  )
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = TRUE
  )
  expected_fingerprint <- vapply(c("q031a", "q061"), function(run_id) {
    files <- mfrmr_cq_brop_native_files(output_dir, run_id)
    native_paths <- unlist(
      files[c("history", "parameter", "regression", "covariance", "cases")],
      use.names = FALSE
    )
    mfrmr_cq_becec_assert(
      all(file.exists(native_paths)),
      paste0("The binary native review files are incomplete for `", run_id, "`.")
    )
    paste(unname(tools::md5sum(native_paths)), collapse = ":")
  }, character(1L))
  mfrmr_cq_becec_assert(
    identical(
      unname(expected_fingerprint),
      as.character(core$results$NativeOutputFingerprint)
    ),
    "The binary native files do not match the supplied review fingerprints."
  )
  rows <- do.call(rbind, lapply(c("q031a", "q061"), function(run_id) {
    mfrmr_cq_brop_arm_token_rows(output_dir, run_id)
  }))
  rownames(rows) <- NULL
  expected <- mfrmr_cq_becec_expected_registry()
  key <- paste(rows$RunId, rows$Coordinate, sep = "\037")
  expected_key <- paste(expected$RunId, expected$Coordinate, sep = "\037")
  mfrmr_cq_becec_assert(
    nrow(rows) == 18L && !anyDuplicated(key) && setequal(key, expected_key),
    "The binary reported-output rows do not match the expected registry."
  )
  rows <- rows[match(expected_key, key), , drop = FALSE]
  rows_sha256 <- mfrmr_cq_brop_rows_sha256(rows)
  out <- list(
    specification = mfrmr_cq_becec_specification,
    contract_version = mfrmr_cq_brop_contract,
    policy_id = mfrmr_cq_rop_policy_id,
    rows_sha256 = rows_sha256,
    status = "reported_output_stratum_ready_hidden_solution_unresolved",
    reported_output_estimand_ready = TRUE,
    hidden_solution_interval_available = FALSE,
    hidden_solution_equivalence_eligible = FALSE,
    rounding_rule_inferred = FALSE,
    tolerance_frozen = FALSE,
    candidate_bound = isTRUE(review$candidate_bound),
    comparison_ready = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    rows = rows
  )
  class(out) <- c(
    "mfrmr_conquest_binary_reported_output_precision", class(out)
  )
  out
}

mfrmr_cq_brop_validate_policy <- function(policy) {
  mfrmr_cq_becec_require_helpers(include_eligibility = FALSE)
  mfrmr_cq_becec_assert(
    inherits(policy, "mfrmr_conquest_binary_reported_output_precision") &&
      identical(as.character(policy$contract_version), mfrmr_cq_brop_contract) &&
      identical(as.character(policy$policy_id), mfrmr_cq_rop_policy_id) &&
      isTRUE(policy$reported_output_estimand_ready) &&
      !isTRUE(policy$hidden_solution_interval_available) &&
      !isTRUE(policy$hidden_solution_equivalence_eligible) &&
      !isTRUE(policy$rounding_rule_inferred) &&
      !isTRUE(policy$tolerance_frozen) &&
      !isTRUE(policy$comparison_ready) &&
      !isTRUE(policy$scientific_equivalence_inferred) &&
      !isTRUE(policy$confirmation_authorized) &&
      is.data.frame(policy$rows),
    "The binary reported-output policy identity or scope is invalid."
  )
  rows <- policy$rows
  required <- c(
    "RunId", "Model", "Coordinate", "FileSHA256", "NativeToken",
    "NativeValue", "CanonicalExactDecimal", "MfrmrReferenceValue",
    "MfrmrReferenceFileSHA256",
    "SignedReportedDifference", "AbsoluteReportedDifference",
    "ReportedOutputEstimandReady", "HiddenSolutionIntervalAvailable",
    "HiddenSolutionEquivalenceEligible", "Metric", "SourcePrecisionStatus"
  )
  expected <- mfrmr_cq_becec_expected_registry()
  key <- paste(rows$RunId, rows$Coordinate, sep = "\037")
  expected_key <- paste(expected$RunId, expected$Coordinate, sep = "\037")
  parsed <- if (all(required %in% names(rows))) {
    mfrmr_cq_rop_parse_exact_decimal(rows$NativeToken)
  } else {
    data.frame(NumericGrammarValid = FALSE)
  }
  difference_ok <- if (all(required %in% names(rows)) && nrow(rows) == 18L) {
    signed <- as.numeric(rows$NativeValue) -
      as.numeric(rows$MfrmrReferenceValue)
    isTRUE(all.equal(
      signed, as.numeric(rows$SignedReportedDifference),
      tolerance = 0, check.attributes = FALSE
    )) && isTRUE(all.equal(
      abs(signed), as.numeric(rows$AbsoluteReportedDifference),
      tolerance = 0, check.attributes = FALSE
    ))
  } else {
    FALSE
  }
  mfrmr_cq_becec_assert(
    all(required %in% names(rows)) && nrow(rows) == 18L &&
      !anyDuplicated(key) && setequal(key, expected_key) &&
      all(as.character(rows$Model) == "Binary") &&
      all(parsed$NumericGrammarValid) &&
      identical(as.numeric(parsed$NumericValue), as.numeric(rows$NativeValue)) &&
      identical(
        as.character(parsed$CanonicalExactDecimal),
        as.character(rows$CanonicalExactDecimal)
      ) && all(grepl("^[[:xdigit:]]{64}$", as.character(rows$FileSHA256))) &&
      all(grepl(
        "^[[:xdigit:]]{64}$", as.character(rows$MfrmrReferenceFileSHA256)
      )) &&
      all(as.logical(rows$ReportedOutputEstimandReady)) &&
      all(!as.logical(rows$HiddenSolutionIntervalAvailable)) &&
      all(!as.logical(rows$HiddenSolutionEquivalenceEligible)) &&
      all(as.character(rows$Metric) ==
            "absolute_difference_to_exact_reported_decimal") &&
      all(as.character(rows$SourcePrecisionStatus) == "match") &&
      difference_ok && identical(
        tolower(as.character(policy$rows_sha256)),
        mfrmr_cq_brop_rows_sha256(rows)
      ),
    "The binary reported-output token, registry, scope, or content hash is invalid."
  )
  invisible(TRUE)
}

mfrmr_normalize_conquest_binary_ladder_eligibility <- function(
    review,
    expected_registry = mfrmr_cq_becec_expected_registry(),
    reported_output_precision = NULL) {
  mfrmr_cq_becec_require_helpers(include_eligibility = TRUE)
  core <- mfrmr_cq_becec_review_core(review)
  registry <- as.data.frame(
    expected_registry, stringsAsFactors = FALSE, check.names = FALSE
  )
  canonical <- mfrmr_cq_becec_expected_registry()
  mfrmr_cq_becec_assert(
    identical(registry, canonical),
    "expected_registry must be the untouched Binary pre-result registry."
  )
  reported_scope <- !is.null(reported_output_precision)
  if (reported_scope) {
    mfrmr_cq_brop_validate_policy(reported_output_precision)
    rows <- reported_output_precision$rows
    row_key <- paste(rows$RunId, rows$Coordinate, sep = "\037")
    registry_key <- paste(registry$RunId, registry$Coordinate, sep = "\037")
    rows <- rows[match(registry_key, row_key), , drop = FALSE]
    run_index <- match(registry$RunId, core$results$RunId)
    registry$ObservedRow <- TRUE
    registry$FitSucceeded <-
      as.character(core$results$AdapterStatus[run_index]) ==
        "accepted_arithmetic" &
      as.logical(core$results$ArithmeticEligible[run_index]) &
      as.logical(core$results$ExecutionComplete[run_index])
    registry$MetricValue <- as.numeric(rows$AbsoluteReportedDifference)
    registry$ObservedFamily <- "Binary"
    registry$ObservedEstimator <- "MML"
    registry$ObservedCorrectionMode <- "none"
    registry$ObservedPenaltyMode <- "none"
    registry$ObservedFiniteParameterBox <- "none"
    matched_identity <- isTRUE(core$same_input) && isTRUE(core$handoff_ready)
    match_status <- if (matched_identity) "match" else "mismatch"
    for (column in c(
      "ObservationsStatus", "WeightsStatus", "ActiveFacetsStatus",
      "SignOrientationStatus", "CategoryMapStatus", "ConstraintsStatus",
      "CoordinatesStatus", "IdentificationStatus", "ConditioningStatus"
    )) registry[[column]] <- match_status
    registry$StepDimensionStatus <- "not_applicable"
    registry$AnchorsStatus <- "not_applicable"
    registry$BoundaryConventionStatus <- "not_applicable"
    registry$SourcePrecisionStatus <- "match"
  }
  ledger <- mfrmr_external_comparison_eligibility(registry)
  eligible_rows <- sum(ledger$Rows$Eligible)
  included_rows <- sum(ledger$Rows$IncludeInAggregate)
  expected_rows <- sum(ledger$Rows$ExpectedRow)
  candidate_bound <- reported_scope &&
    isTRUE(reported_output_precision$candidate_bound) &&
    isTRUE(review$candidate_bound)
  ledger$Binding <- data.frame(
    NormalizerVersion = mfrmr_cq_becec_normalizer_version,
    SourcePrecisionScope = if (reported_scope) {
      "exact_reported_decimal"
    } else {
      "not_observed"
    },
    SourcePrecisionPolicyId = if (reported_scope) {
      as.character(reported_output_precision$policy_id)
    } else {
      ""
    },
    HiddenSolutionEquivalenceEligible = if (reported_scope) FALSE else NA,
    ExpectedRows = expected_rows,
    ObservedRows = sum(ledger$Rows$ObservedRow),
    EligibleRows = eligible_rows,
    IncludedRows = included_rows,
    IneligibleIncludedRows = sum(
      ledger$Rows$IncludeInAggregate & !ledger$Rows$Eligible
    ),
    SourcePrecisionReady = reported_scope &&
      eligible_rows == expected_rows && included_rows == eligible_rows,
    CandidateBound = candidate_bound,
    ComparisonReady = FALSE,
    Decision = if (!reported_scope) {
      "binary_native_reported_output_not_retained"
    } else if (
      eligible_rows == expected_rows && included_rows == eligible_rows &&
        !candidate_bound
    ) {
      "conquest_reported_output_rows_eligible_candidate_tolerance_missing"
    } else {
      "conquest_binary_binding_requires_review"
    },
    stringsAsFactors = FALSE
  )
  ledger
}
