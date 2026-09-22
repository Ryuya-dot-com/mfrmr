# mfrmr 0.2.3 ConQuest reported-output precision contract
#
# ConQuest 5.47.5 documents that the `decimals` option is ignored for file
# output, but it does not document a CSV rounding mode or hidden precision.
# This repository-only contract therefore treats each retained decimal token
# as an exact reported-output estimand while keeping the unprinted optimizer
# solution in a separate, ineligible stratum. It never launches ConQuest.

mfrmr_cq_rop_specification <-
  "0.2.3-wave-c-reported-output-precision-v1"
mfrmr_cq_rop_contract <-
  "mfrmr_conquest_reported_output_precision_v1"
mfrmr_cq_rop_policy_id <-
  "conquest-reported-decimal-estimand-v1"
mfrmr_cq_rop_manual_sha256 <-
  "60bce1a39f5430fd304178356fb943721f9f72c0ddee70a9866c28c87017459f"
mfrmr_cq_rop_manual_pdf_page <- 394L
mfrmr_cq_rop_executable_sha256 <-
  "61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48"

mfrmr_cq_rop_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_rop_hash_file <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The ConQuest reported-output contract requires `digest`.",
         call. = FALSE)
  }
  unname(digest::digest(file = path, algo = "sha256", serialize = FALSE))
}

mfrmr_cq_rop_manual_contract <- function() {
  data.frame(
    PolicyId = mfrmr_cq_rop_policy_id,
    ManualSHA256 = mfrmr_cq_rop_manual_sha256,
    ManualPDFPage = mfrmr_cq_rop_manual_pdf_page,
    ScreenDecimalsControlAppliesToFileOutput = FALSE,
    FileRoundingRuleDocumented = FALSE,
    HiddenPrecisionDocumented = FALSE,
    ReportedDecimalTokenIsExactEstimand = TRUE,
    HiddenSolutionIntervalAvailable = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_rop_rows_sha256 <- function(rows) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The ConQuest reported-output contract requires `digest`.",
         call. = FALSE)
  }
  required <- c(
    "RunId", "Model", "Coordinate", "FileRole", "FileName", "FileSHA256",
    "NativeToken", "NativeValue", "CanonicalExactDecimal",
    "MfrmrReferenceValue", "SignedReportedDifference",
    "AbsoluteReportedDifference", "Metric", "SourcePrecisionStatus"
  )
  mfrmr_cq_rop_assert(
    is.data.frame(rows) && all(required %in% names(rows)),
    "The reported-output rows do not satisfy the hash schema."
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

mfrmr_cq_rop_parse_exact_decimal <- function(token) {
  token <- as.character(token)
  trimmed <- trimws(token)
  grammar <- "^[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?$"
  valid <- grepl(grammar, trimmed, perl = TRUE)
  numeric_value <- suppressWarnings(as.numeric(trimmed))
  valid <- valid & is.finite(numeric_value)
  sign <- ifelse(startsWith(trimmed, "-"), -1L, 1L)
  unsigned <- sub("^[+-]", "", trimmed)
  exponent_text <- ifelse(
    grepl("[eE]", unsigned), sub("^.*[eE]", "", unsigned), "0"
  )
  exponent <- suppressWarnings(as.integer(exponent_text))
  valid <- valid & !is.na(exponent)
  mantissa <- sub("[eE].*$", "", unsigned)
  decimal_places <- ifelse(
    grepl("\\.", mantissa), nchar(sub("^[^.]*\\.", "", mantissa)), 0L
  )
  digits <- gsub("\\.", "", mantissa)
  digits <- sub("^0+", "", digits)
  zero <- !nzchar(digits)
  digits[zero] <- "0"
  decimal_exponent <- exponent - decimal_places
  canonical_digits <- digits
  canonical_exponent <- decimal_exponent
  for (index in which(valid & !zero)) {
    trailing <- nchar(canonical_digits[index]) -
      nchar(sub("0+$", "", canonical_digits[index]))
    if (trailing > 0L) {
      canonical_digits[index] <- sub("0+$", "", canonical_digits[index])
      canonical_exponent[index] <- canonical_exponent[index] + trailing
    }
  }
  sign[zero] <- 0L
  canonical_exponent[zero] <- 0L
  canonical <- ifelse(
    valid,
    paste0(
      ifelse(sign < 0L, "-", ""), canonical_digits, "e",
      canonical_exponent
    ),
    NA_character_
  )
  data.frame(
    LexicalToken = token,
    TrimmedToken = trimmed,
    NumericGrammarValid = valid,
    NumericValue = ifelse(valid, numeric_value, NA_real_),
    ExactSign = ifelse(valid, sign, NA_integer_),
    ExactCoefficientDigits = ifelse(valid, canonical_digits, NA_character_),
    ExactDecimalExponent = ifelse(valid, canonical_exponent, NA_integer_),
    CanonicalExactDecimal = canonical,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_rop_native_files <- function(output_dir, run_id) {
  prefix <- paste0("cq_additive_", run_id, "_conquest_")
  run_dir <- file.path(output_dir, run_id)
  list(
    history = file.path(run_dir, paste0(prefix, "history.csv")),
    parameter = file.path(run_dir, paste0(prefix, "parameters.csv")),
    regression = file.path(
      run_dir, paste0(prefix, "reg_coefficients.csv")
    ),
    covariance = file.path(run_dir, paste0(prefix, "covariance.csv"))
  )
}

mfrmr_cq_rop_read_character_csv <- function(path) {
  utils::read.csv(
    path, colClasses = "character", na.strings = character(),
    check.names = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_cq_rop_arm_token_rows <- function(output_dir, run_id, model) {
  files <- mfrmr_cq_rop_native_files(output_dir, run_id)
  mfrmr_cq_rop_assert(
    all(vapply(files, file.exists, logical(1L))),
    paste0("The native token files are incomplete for `", run_id, "`.")
  )
  history <- mfrmr_cq_rop_read_character_csv(files$history)
  parameter <- mfrmr_cq_rop_read_character_csv(files$parameter)
  regression <- mfrmr_cq_rop_read_character_csv(files$regression)
  covariance <- mfrmr_cq_rop_read_character_csv(files$covariance)
  expected_parameter_rows <- if (identical(model, "RSM")) 4L else 6L
  mfrmr_cq_rop_assert(
    nrow(history) > 0L && nrow(parameter) == expected_parameter_rows &&
      nrow(regression) == 2L && nrow(covariance) == 1L &&
      all(c("LogLikelihood") %in% names(history)) &&
      all(c("Estimate") %in% names(parameter)) &&
      all(c("Estimate") %in% names(regression)) &&
      all(c("Covariance") %in% names(covariance)),
    paste0("The native token schema changed for `", run_id, "`.")
  )
  parameter_coordinates <- if (identical(model, "RSM")) {
    c("R1", "C1", "Step1", "Step2")
  } else {
    c("R1", "C1", "C1:Step1", "C1:Step2", "C2:Step1", "C2:Step2")
  }
  token <- c(
    regression$Estimate, covariance$Covariance[1L], parameter$Estimate,
    utils::tail(history$LogLikelihood, 1L)
  )
  coordinate <- c(
    "population_intercept", "population_slope", "population_variance",
    parameter_coordinates, "deviance"
  )
  file_role <- c(
    rep("regression_export", 2L), "covariance_export",
    rep("parameter_export", expected_parameter_rows), "matrixout_history"
  )
  file_path <- c(
    rep(files$regression, 2L), files$covariance,
    rep(files$parameter, expected_parameter_rows), files$history
  )
  parsed <- mfrmr_cq_rop_parse_exact_decimal(token)
  mfrmr_cq_rop_assert(
    length(token) == length(coordinate) && all(parsed$NumericGrammarValid),
    paste0("The final native tokens are invalid for `", run_id, "`.")
  )
  data.frame(
    RunId = run_id,
    Model = model,
    Coordinate = coordinate,
    FileRole = file_role,
    FileName = basename(file_path),
    FileSHA256 = vapply(file_path, mfrmr_cq_rop_hash_file, character(1L)),
    NativeToken = token,
    NativeValue = parsed$NumericValue,
    CanonicalExactDecimal = parsed$CanonicalExactDecimal,
    ReportedOutputEstimandReady = TRUE,
    HiddenSolutionIntervalAvailable = FALSE,
    HiddenSolutionEquivalenceEligible = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_rop_review_four_arm <- function(output_dir, review) {
  mfrmr_cq_rop_assert(
    inherits(review, "mfrmr_conquest_native_four_arm_review") &&
      identical(
        as.character(review$raw_token_status),
        "raw_tokens_retained_rounding_unestablished"
      ) && is.data.frame(review$descriptive_differences),
    "The reported-output policy requires the retained native four-arm review."
  )
  plan <- data.frame(
    RunId = c("rsm_q031", "rsm_q061", "pcm_q031", "pcm_q061"),
    Model = c("RSM", "RSM", "PCM", "PCM"),
    stringsAsFactors = FALSE
  )
  rows <- do.call(rbind, lapply(seq_len(nrow(plan)), function(index) {
    mfrmr_cq_rop_arm_token_rows(
      output_dir, plan$RunId[index], plan$Model[index]
    )
  }))
  rownames(rows) <- NULL
  token_key <- paste(rows$RunId, rows$Coordinate, sep = "\r")
  difference <- review$descriptive_differences
  difference_key <- paste(difference$RunId, difference$Coordinate, sep = "\r")
  mfrmr_cq_rop_assert(
    nrow(rows) == 36L && !anyDuplicated(token_key) &&
      !anyDuplicated(difference_key) && setequal(token_key, difference_key),
    "The reported-token and four-arm coordinate identities disagree."
  )
  difference <- difference[match(token_key, difference_key), , drop = FALSE]
  mfrmr_cq_rop_assert(
    identical(as.character(rows$Model), as.character(difference$Model)) &&
      identical(as.numeric(rows$NativeValue),
                as.numeric(difference$NativeValue)),
    "The parsed exact tokens do not reproduce the reviewed native values."
  )
  rows$MfrmrReferenceValue <- as.numeric(difference$MfrmrReferenceValue)
  rows$SignedReportedDifference <-
    rows$NativeValue - rows$MfrmrReferenceValue
  rows$AbsoluteReportedDifference <- abs(rows$SignedReportedDifference)
  rows$Metric <- "absolute_difference_to_exact_reported_decimal"
  rows$SourcePrecisionStatus <- "match"
  rows_sha256 <- mfrmr_cq_rop_rows_sha256(rows)
  out <- list(
    specification = mfrmr_cq_rop_specification,
    contract_version = mfrmr_cq_rop_contract,
    policy_id = mfrmr_cq_rop_policy_id,
    rows_sha256 = rows_sha256,
    status = "reported_output_stratum_ready_hidden_solution_unresolved",
    manual_contract = mfrmr_cq_rop_manual_contract(),
    reported_output_estimand_ready = TRUE,
    hidden_solution_interval_available = FALSE,
    hidden_solution_equivalence_eligible = FALSE,
    rounding_rule_inferred = FALSE,
    tolerance_frozen = FALSE,
    candidate_bound = FALSE,
    comparison_ready = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    rows = rows
  )
  class(out) <- c("mfrmr_conquest_reported_output_precision", class(out))
  out
}

mfrmr_cq_rop_validate_policy <- function(policy) {
  mfrmr_cq_rop_assert(
    inherits(policy, "mfrmr_conquest_reported_output_precision") &&
      identical(as.character(policy$contract_version), mfrmr_cq_rop_contract) &&
      identical(as.character(policy$policy_id), mfrmr_cq_rop_policy_id) &&
      isTRUE(policy$reported_output_estimand_ready) &&
      !isTRUE(policy$hidden_solution_interval_available) &&
      !isTRUE(policy$hidden_solution_equivalence_eligible) &&
      !isTRUE(policy$rounding_rule_inferred) &&
      !isTRUE(policy$scientific_equivalence_inferred) &&
      is.data.frame(policy$rows),
    "The reported-output policy identity or scope is invalid."
  )
  rows <- policy$rows
  required <- c(
    "NativeToken", "NativeValue", "CanonicalExactDecimal", "FileSHA256",
    "ReportedOutputEstimandReady", "HiddenSolutionIntervalAvailable",
    "HiddenSolutionEquivalenceEligible", "Metric", "SourcePrecisionStatus"
  )
  mfrmr_cq_rop_assert(
    all(required %in% names(rows)) && nrow(rows) == 36L &&
      !anyDuplicated(paste(rows$RunId, rows$Coordinate, sep = "\r")),
    "The reported-output policy row schema is invalid."
  )
  parsed <- mfrmr_cq_rop_parse_exact_decimal(rows$NativeToken)
  mfrmr_cq_rop_assert(
    all(parsed$NumericGrammarValid) &&
      identical(as.numeric(parsed$NumericValue), as.numeric(rows$NativeValue)) &&
      identical(as.character(parsed$CanonicalExactDecimal),
                as.character(rows$CanonicalExactDecimal)) &&
      all(grepl("^[[:xdigit:]]{64}$", as.character(rows$FileSHA256))) &&
      all(as.logical(rows$ReportedOutputEstimandReady)) &&
      all(!as.logical(rows$HiddenSolutionIntervalAvailable)) &&
      all(!as.logical(rows$HiddenSolutionEquivalenceEligible)) &&
      all(as.character(rows$Metric) ==
            "absolute_difference_to_exact_reported_decimal") &&
      all(as.character(rows$SourcePrecisionStatus) == "match") &&
      identical(
        tolower(as.character(policy$rows_sha256)),
        mfrmr_cq_rop_rows_sha256(rows)
      ),
    "The reported-output token, file, scope, or content hash is invalid."
  )
  invisible(TRUE)
}
