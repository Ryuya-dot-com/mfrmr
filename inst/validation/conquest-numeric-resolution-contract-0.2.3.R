# mfrmr 0.2.3 repository-only ConQuest numeric-resolution contract
#
# This helper preserves decoded CSV numeric tokens before conversion to
# binary floating point. It describes lexical resolution but never infers a
# rounding rule, scientific equivalence, or an acceptance tolerance from the
# number of printed digits.

mfrmr_cq_resolution_specification <- "0.2.3-wave-c-resolution-v1"
mfrmr_cq_resolution_contract <- "mfrmr_conquest_numeric_resolution_v1"

mfrmr_cq_resolution_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_resolution_hash_file <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The ConQuest resolution audit requires the suggested `digest` package.",
         call. = FALSE)
  }
  unname(digest::digest(file = path, algo = "sha256", serialize = FALSE))
}

mfrmr_cq_resolution_delimiter <- function(delimiter) {
  delimiter <- as.character(delimiter)[1]
  aliases <- c(comma = ",", tab = "\t", semicolon = ";")
  if (!is.na(delimiter) && delimiter %in% names(aliases)) {
    delimiter <- unname(aliases[[delimiter]])
  }
  mfrmr_cq_resolution_assert(
    length(delimiter) == 1L && !is.na(delimiter) &&
      delimiter %in% c(",", "\t", ";"),
    "`delimiter` must be comma, tab, semicolon, or the corresponding character."
  )
  delimiter
}

mfrmr_cq_resolution_rules <- function(rule, numeric_columns) {
  numeric_columns <- as.character(numeric_columns)
  mfrmr_cq_resolution_assert(
    length(numeric_columns) > 0L && !anyNA(numeric_columns) &&
      all(nzchar(numeric_columns)) && !anyDuplicated(numeric_columns),
    "`numeric_columns` must contain unique, non-empty column names."
  )
  rule_names <- names(rule)
  rule <- as.character(rule)
  names(rule) <- rule_names
  if (length(rule) == 1L && (is.null(names(rule)) || !nzchar(names(rule)))) {
    rule <- rep(rule, length(numeric_columns))
    names(rule) <- numeric_columns
  } else {
    mfrmr_cq_resolution_assert(
      !is.null(names(rule)) && !anyNA(names(rule)) &&
        all(nzchar(names(rule))) && !anyDuplicated(names(rule)) &&
        setequal(names(rule), numeric_columns),
      "Named `rounding_rule` values must cover every numeric column exactly once."
    )
    rule <- rule[numeric_columns]
  }
  allowed <- c("unknown", "nearest", "exact")
  mfrmr_cq_resolution_assert(
    !anyNA(rule) && all(rule %in% allowed),
    "`rounding_rule` must use only `unknown`, `nearest`, or `exact`."
  )
  rule
}

mfrmr_cq_resolution_parse_tokens <- function(token) {
  token <- as.character(token)
  trimmed <- trimws(token)
  grammar <- "^[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?$"
  grammar_valid <- grepl(grammar, trimmed, perl = TRUE)
  numeric_value <- suppressWarnings(as.numeric(trimmed))
  valid <- grammar_valid & is.finite(numeric_value)

  mantissa <- sub("[eE].*$", "", trimmed)
  mantissa <- sub("^[+-]", "", mantissa)
  exponent_text <- ifelse(
    grepl("[eE]", trimmed), sub("^.*[eE]", "", trimmed), "0"
  )
  exponent <- suppressWarnings(as.integer(exponent_text))
  decimal_places <- ifelse(
    grepl("\\.", mantissa), nchar(sub("^[^.]*\\.", "", mantissa)), 0L
  )
  digits <- gsub("\\.", "", mantissa)
  significant <- sub("^0+", "", digits)
  significant_digits <- ifelse(nzchar(significant), nchar(significant), 1L)
  trailing_match <- regexpr("0*$", digits, perl = TRUE)
  trailing_zeroes <- ifelse(
    nzchar(digits), nchar(digits) - trailing_match + 1L, 0L
  )
  unit <- suppressWarnings(10^(exponent - decimal_places))
  unit[!valid | !is.finite(unit) | unit <= 0] <- NA_real_
  decimal_places[!valid] <- NA_integer_
  exponent[!valid] <- NA_integer_
  significant_digits[!valid] <- NA_integer_
  trailing_zeroes[!valid] <- NA_integer_

  data.frame(
    LexicalToken = token,
    TrimmedToken = trimmed,
    NumericValue = ifelse(valid, numeric_value, NA_real_),
    NumericGrammarValid = valid,
    DecimalPlaces = as.integer(decimal_places),
    Exponent = as.integer(exponent),
    SignificantDigits = as.integer(significant_digits),
    TrailingZeroes = as.integer(trailing_zeroes),
    LexicalUnitCandidate = unit,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_resolution_audit_file <- function(
    file,
    numeric_columns,
    file_role,
    delimiter = ",",
    rounding_rule = "unknown") {
  file <- normalizePath(as.character(file)[1], winslash = "/", mustWork = TRUE)
  file_role <- trimws(as.character(file_role)[1])
  mfrmr_cq_resolution_assert(
    !is.na(file_role) && nzchar(file_role),
    "`file_role` must be one non-empty label."
  )
  delimiter <- mfrmr_cq_resolution_delimiter(delimiter)
  numeric_columns <- as.character(numeric_columns)
  rules <- mfrmr_cq_resolution_rules(rounding_rule, numeric_columns)
  table <- utils::read.table(
    file,
    header = TRUE,
    sep = delimiter,
    quote = "\"",
    comment.char = "",
    colClasses = "character",
    na.strings = character(),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  missing <- setdiff(numeric_columns, names(table))
  mfrmr_cq_resolution_assert(
    nrow(table) > 0L && length(missing) == 0L,
    paste0(
      "The ConQuest `", file_role,
      "` CSV is empty or missing numeric column(s): ",
      paste(missing, collapse = ", "), "."
    )
  )
  sha256 <- mfrmr_cq_resolution_hash_file(file)
  ledger <- do.call(rbind, lapply(numeric_columns, function(column) {
    parsed <- mfrmr_cq_resolution_parse_tokens(table[[column]])
    rule <- unname(rules[[column]])
    established <- parsed$NumericGrammarValid & rule != "unknown" &
      (rule != "nearest" | is.finite(parsed$LexicalUnitCandidate))
    resolution_unit <- ifelse(
      !established,
      NA_real_,
      ifelse(rule == "exact", 0, parsed$LexicalUnitCandidate)
    )
    half_width <- ifelse(established, resolution_unit / 2, NA_real_)
    data.frame(
      Specification = mfrmr_cq_resolution_specification,
      ContractVersion = mfrmr_cq_resolution_contract,
      FileRole = file_role,
      FileName = basename(file),
      FileSHA256 = sha256,
      Row = seq_len(nrow(table)),
      Column = column,
      parsed,
      RoundingRule = rule,
      RoundingRuleEstablished = established,
      ResolutionUnit = resolution_unit,
      IntervalLower = parsed$NumericValue - half_width,
      IntervalUpper = parsed$NumericValue + half_width,
      ScientificEquivalenceInferred = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  rownames(ledger) <- NULL
  valid <- sum(ledger$NumericGrammarValid)
  established <- sum(ledger$RoundingRuleEstablished)
  status <- if (valid != nrow(ledger)) {
    "rejected_invalid_numeric_token"
  } else if (established == nrow(ledger)) {
    "resolution_intervals_available"
  } else {
    "raw_tokens_retained_rounding_unestablished"
  }
  summary <- data.frame(
    Specification = mfrmr_cq_resolution_specification,
    ContractVersion = mfrmr_cq_resolution_contract,
    FileRole = file_role,
    FileName = basename(file),
    FileSHA256 = sha256,
    NumericColumns = paste(numeric_columns, collapse = ";"),
    TotalNumericTokens = nrow(ledger),
    ValidNumericTokens = valid,
    RoundingRulesEstablished = established,
    AllNumericTokensValid = valid == nrow(ledger),
    AllRoundingRulesEstablished = established == nrow(ledger),
    Status = status,
    ScientificEquivalenceInferred = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  out <- list(summary = summary, tokens = ledger)
  class(out) <- c("mfrmr_conquest_resolution_audit", class(out))
  out
}

mfrmr_cq_resolution_audit_files <- function(
    files,
    numeric_columns,
    file_roles = names(files),
    delimiters = ",",
    rounding_rules = "unknown") {
  mfrmr_cq_resolution_assert(
    is.list(files) && length(files) > 0L &&
      is.list(numeric_columns) && length(numeric_columns) == length(files),
    "`files` and `numeric_columns` must be non-empty lists of equal length."
  )
  if (is.null(file_roles)) file_roles <- names(files)
  file_roles <- as.character(file_roles)
  mfrmr_cq_resolution_assert(
    length(file_roles) == length(files) && !anyNA(file_roles) &&
      all(nzchar(file_roles)) && !anyDuplicated(file_roles),
    "`file_roles` must uniquely label every file."
  )
  if (length(delimiters) == 1L) delimiters <- rep(delimiters, length(files))
  mfrmr_cq_resolution_assert(
    length(delimiters) == length(files),
    "`delimiters` must have length one or one value per file."
  )
  if (!is.list(rounding_rules)) {
    rounding_rules <- rep(list(rounding_rules), length(files))
  }
  mfrmr_cq_resolution_assert(
    length(rounding_rules) == length(files),
    "`rounding_rules` must have one entry per file."
  )
  audits <- lapply(seq_along(files), function(index) {
    mfrmr_cq_resolution_audit_file(
      file = files[[index]],
      numeric_columns = numeric_columns[[index]],
      file_role = file_roles[index],
      delimiter = delimiters[index],
      rounding_rule = rounding_rules[[index]]
    )
  })
  summary <- do.call(rbind, lapply(audits, `[[`, "summary"))
  tokens <- do.call(rbind, lapply(audits, `[[`, "tokens"))
  rownames(summary) <- NULL
  rownames(tokens) <- NULL
  out <- list(
    specification = mfrmr_cq_resolution_specification,
    contract_version = mfrmr_cq_resolution_contract,
    status = if (all(summary$AllNumericTokensValid)) {
      if (all(summary$AllRoundingRulesEstablished)) {
        "resolution_intervals_available"
      } else {
        "raw_tokens_retained_rounding_unestablished"
      }
    } else {
      "rejected_invalid_numeric_token"
    },
    confirmation_authorized = FALSE,
    summary = summary,
    tokens = tokens
  )
  class(out) <- c("mfrmr_conquest_resolution_bundle", class(out))
  out
}

mfrmr_cq_resolution_header <- function(file, delimiter = ",") {
  delimiter <- mfrmr_cq_resolution_delimiter(delimiter)
  names(utils::read.table(
    file,
    header = TRUE,
    nrows = 0L,
    sep = delimiter,
    quote = "\"",
    comment.char = "",
    check.names = FALSE
  ))
}

mfrmr_cq_resolution_audit_native_exports <- function(
    history_file,
    parameter_file,
    regression_file,
    covariance_file,
    case_file,
    delimiter = ",",
    rounding_rules = "unknown") {
  headers <- lapply(
    list(history_file, parameter_file, regression_file, covariance_file,
         case_file),
    mfrmr_cq_resolution_header,
    delimiter = delimiter
  )
  mfrmr_cq_resolution_assert(
    length(headers[[1]]) >= 5L &&
      all(c("Estimate") %in% headers[[2]]) &&
      all(c("Estimate") %in% headers[[3]]) &&
      all(c("Covariance") %in% headers[[4]]),
    "The native ConQuest export headers do not satisfy the audited core schema."
  )
  case_candidates <- intersect(
    c("EAP_1", "EAP", "Estimate", "weight_raw", "weight_scaled"),
    headers[[5]]
  )
  mfrmr_cq_resolution_assert(
    length(case_candidates) > 0L,
    "The ConQuest case export has no audited numeric estimate or weight column."
  )
  mfrmr_cq_resolution_audit_files(
    files = list(
      history = history_file,
      parameter = parameter_file,
      regression = regression_file,
      covariance = covariance_file,
      cases = case_file
    ),
    numeric_columns = list(
      headers[[1]][4:length(headers[[1]])],
      "Estimate",
      "Estimate",
      "Covariance",
      case_candidates
    ),
    file_roles = c(
      "matrixout_history", "parameter_export", "regression_export",
      "covariance_export", "case_export"
    ),
    delimiters = delimiter,
    rounding_rules = rounding_rules
  )
}

mfrmr_cq_resolution_compare <- function(
    external_tokens,
    reference,
    tolerance = NULL) {
  required_external <- c(
    "FileRole", "Row", "Column", "LexicalToken", "NumericValue",
    "NumericGrammarValid", "RoundingRule", "RoundingRuleEstablished",
    "ResolutionUnit", "IntervalLower", "IntervalUpper"
  )
  required_reference <- c("FileRole", "Row", "Column", "ReferenceValue")
  mfrmr_cq_resolution_assert(
    is.data.frame(external_tokens) &&
      all(required_external %in% names(external_tokens)),
    "`external_tokens` does not satisfy the resolution-ledger contract."
  )
  mfrmr_cq_resolution_assert(
    is.data.frame(reference) &&
      all(required_reference %in% names(reference)),
    "`reference` must contain FileRole, Row, Column, and ReferenceValue."
  )
  if (!"ReferenceToken" %in% names(reference)) {
    reference$ReferenceToken <- NA_character_
  }
  key <- function(x) paste(x$FileRole, x$Row, x$Column, sep = "\r")
  external_key <- key(external_tokens)
  reference_key <- key(reference)
  mfrmr_cq_resolution_assert(
    !anyDuplicated(external_key) && !anyDuplicated(reference_key) &&
      setequal(external_key, reference_key),
    "External and reference resolution keys must form the same unique set."
  )
  reference <- reference[match(external_key, reference_key), , drop = FALSE]
  reference_value <- suppressWarnings(as.numeric(reference$ReferenceValue))
  valid <- external_tokens$NumericGrammarValid & is.finite(reference_value)
  difference <- external_tokens$NumericValue - reference_value
  abs_difference <- abs(difference)
  exact_lexical <- ifelse(
    is.na(reference$ReferenceToken),
    NA,
    external_tokens$LexicalToken == as.character(reference$ReferenceToken)
  )
  resolution_compatible <- rep(NA, nrow(external_tokens))
  established <- valid & external_tokens$RoundingRuleEstablished
  resolution_compatible[established] <-
    reference_value[established] >= external_tokens$IntervalLower[established] &
    reference_value[established] <= external_tokens$IntervalUpper[established]
  min_difference <- rep(NA_real_, nrow(external_tokens))
  max_difference <- rep(NA_real_, nrow(external_tokens))
  min_difference[established] <- pmax(
    0,
    abs_difference[established] -
      external_tokens$ResolutionUnit[established] / 2
  )
  max_difference[established] <- abs_difference[established] +
    external_tokens$ResolutionUnit[established] / 2

  tolerance_supplied <- !is.null(tolerance)
  if (tolerance_supplied) {
    tolerance <- suppressWarnings(as.numeric(tolerance)[1])
    mfrmr_cq_resolution_assert(
      is.finite(tolerance) && tolerance >= 0,
      "`tolerance` must be one non-negative finite value when supplied."
    )
  } else {
    tolerance <- NA_real_
  }
  tolerance_passed <- if (tolerance_supplied) {
    valid & abs_difference <= tolerance
  } else {
    rep(NA, nrow(external_tokens))
  }
  comparison_state <- ifelse(
    !valid,
    "invalid_numeric_input",
    ifelse(
      exact_lexical %in% TRUE,
      "exact_lexical_equality",
      ifelse(
        abs_difference == 0,
        "numeric_equality_lexically_distinct",
        ifelse(
          is.na(resolution_compatible),
          "reported_resolution_limited",
          ifelse(
            resolution_compatible,
            "compatible_at_established_resolution",
            "incompatible_at_established_resolution"
          )
        )
      )
    )
  )
  comparison <- cbind(
    external_tokens,
    ReferenceToken = as.character(reference$ReferenceToken),
    ReferenceValue = reference_value,
    Difference = difference,
    AbsDifference = abs_difference,
    ExactLexicalEquality = as.logical(exact_lexical),
    ReportedResolutionCompatible = as.logical(resolution_compatible),
    MinCompatibleAbsDifference = min_difference,
    MaxCompatibleAbsDifference = max_difference,
    ToleranceSupplied = tolerance_supplied,
    Tolerance = tolerance,
    TolerancePassed = as.logical(tolerance_passed),
    ScientificEquivalent = NA,
    ComparisonState = comparison_state,
    stringsAsFactors = FALSE
  )
  out <- list(
    specification = mfrmr_cq_resolution_specification,
    contract_version = mfrmr_cq_resolution_contract,
    status = "review",
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    comparison = comparison
  )
  class(out) <- c("mfrmr_conquest_resolution_comparison", class(out))
  out
}
