# Deterministic row-level eligibility contract for external comparisons.
# This repository-only contract runs no external program and sets no tolerance.

mfrmr_ecec_required_columns <- function() {
  c(
    "ComparisonRowId", "ScenarioId", "Program",
    "ExpectedFamily", "ObservedFamily",
    "ExpectedEstimator", "ObservedEstimator",
    "ExpectedCorrectionMode", "ObservedCorrectionMode",
    "Metric", "ParameterClass", "ExpectedRow", "ObservedRow",
    "FitSucceeded", "MetricValue",
    "ObservationsStatus", "WeightsStatus", "ActiveFacetsStatus",
    "SignOrientationStatus", "CategoryMapStatus", "StepDimensionStatus",
    "AnchorsStatus", "ConstraintsStatus", "CoordinatesStatus",
    "IdentificationStatus", "ConditioningStatus",
    "BoundaryConventionStatus"
  )
}

mfrmr_ecec_status_columns <- function() {
  c(
    ObservationsStatus = "observations",
    WeightsStatus = "weights",
    ActiveFacetsStatus = "active_facets",
    SignOrientationStatus = "sign_orientation",
    CategoryMapStatus = "category_map",
    StepDimensionStatus = "step_dimension",
    AnchorsStatus = "anchors",
    ConstraintsStatus = "constraints",
    CoordinatesStatus = "coordinates",
    IdentificationStatus = "identification",
    ConditioningStatus = "conditioning",
    BoundaryConventionStatus = "boundary_convention"
  )
}

mfrmr_ecec_stratum_columns <- function() {
  c(
    "ScenarioId", "Program", "ExpectedFamily", "ExpectedEstimator",
    "ExpectedCorrectionMode", "Metric", "ParameterClass"
  )
}

mfrmr_ecec_character <- function(x) {
  out <- enc2utf8(as.character(x))
  out[is.na(x)] <- ""
  trimws(out)
}

mfrmr_ecec_assert_input <- function(rows) {
  if (!is.data.frame(rows)) stop("rows must be a data frame", call. = FALSE)
  required <- mfrmr_ecec_required_columns()
  missing <- setdiff(required, names(rows))
  if (length(missing) > 0L) {
    stop(
      paste("missing required comparison columns:", paste(missing, collapse = ", ")),
      call. = FALSE
    )
  }
  if (nrow(rows) == 0L) stop("comparison registry is empty", call. = FALSE)

  text_columns <- c(
    "ComparisonRowId", "ScenarioId", "Program", "ExpectedFamily",
    "ExpectedEstimator", "ExpectedCorrectionMode", "Metric",
    "ParameterClass"
  )
  for (column in text_columns) {
    if (any(!nzchar(mfrmr_ecec_character(rows[[column]])))) {
      stop(paste(column, "must be non-empty"), call. = FALSE)
    }
  }
  ids <- mfrmr_ecec_character(rows$ComparisonRowId)
  if (anyDuplicated(ids)) {
    stop("ComparisonRowId must be unique", call. = FALSE)
  }
  if (any(grepl("\037", unlist(rows[required]), fixed = TRUE))) {
    stop("comparison fields contain the reserved unit separator", call. = FALSE)
  }
  allowed_programs <- c("ConQuest", "FACETS", "TAM", "immer")
  programs <- mfrmr_ecec_character(rows$Program)
  if (any(!programs %in% allowed_programs)) {
    stop("Program contains an unsupported external engine", call. = FALSE)
  }

  logical_columns <- c("ExpectedRow", "ObservedRow", "FitSucceeded")
  for (column in logical_columns) {
    if (!is.logical(rows[[column]]) || anyNA(rows[[column]])) {
      stop(paste(column, "must contain non-missing logical values"),
           call. = FALSE)
    }
  }
  if (any(!rows$ExpectedRow & !rows$ObservedRow)) {
    stop("a row cannot be neither expected nor observed", call. = FALSE)
  }
  if (any(rows$FitSucceeded & !rows$ObservedRow)) {
    stop("an unobserved row cannot have FitSucceeded = TRUE", call. = FALSE)
  }
  observed_identity <- c(
    "ObservedFamily", "ObservedEstimator", "ObservedCorrectionMode"
  )
  for (column in observed_identity) {
    value <- mfrmr_ecec_character(rows[[column]])
    if (any(rows$ObservedRow & !nzchar(value))) {
      stop(paste(column, "must be non-empty for observed rows"),
           call. = FALSE)
    }
  }

  allowed_status <- c("match", "not_applicable", "mismatch", "unknown")
  for (column in names(mfrmr_ecec_status_columns())) {
    value <- mfrmr_ecec_character(rows[[column]])
    if (any(!value %in% allowed_status)) {
      stop(
        paste(column, "must be match, not_applicable, mismatch, or unknown"),
        call. = FALSE
      )
    }
  }
  invisible(TRUE)
}

mfrmr_ecec_reason_codes <- function(row) {
  if (!row$ExpectedRow) return("unexpected_row_not_in_registry")
  if (!row$ObservedRow) return("missing_expected_row")
  if (!row$FitSucceeded) return("external_fit_failed")

  reasons <- character(0)
  identity_fields <- list(
    family = c("ExpectedFamily", "ObservedFamily"),
    estimator = c("ExpectedEstimator", "ObservedEstimator"),
    correction_mode = c("ExpectedCorrectionMode", "ObservedCorrectionMode")
  )
  for (label in names(identity_fields)) {
    fields <- identity_fields[[label]]
    expected <- mfrmr_ecec_character(row[[fields[1L]]])
    observed <- mfrmr_ecec_character(row[[fields[2L]]])
    if (!identical(expected, observed)) {
      reasons <- c(reasons, paste0(label, "_mismatch"))
    }
  }
  status_fields <- mfrmr_ecec_status_columns()
  for (column in names(status_fields)) {
    status <- mfrmr_ecec_character(row[[column]])
    if (status %in% c("mismatch", "unknown")) {
      reasons <- c(reasons, paste0(status_fields[[column]], "_", status))
    }
  }
  metric_value <- suppressWarnings(
    as.numeric(mfrmr_ecec_character(row$MetricValue))
  )
  if (length(metric_value) != 1L || !is.finite(metric_value)) {
    reasons <- c(reasons, "metric_value_missing_or_nonfinite")
  }
  paste(reasons, collapse = ";")
}

mfrmr_ecec_denominators <- function(rows) {
  keys <- mfrmr_ecec_stratum_columns()
  key_values <- lapply(rows[keys], mfrmr_ecec_character)
  group <- do.call(paste, c(key_values, sep = "\037"))
  groups <- sort(unique(group), method = "radix")
  result <- lapply(groups, function(value) {
    index <- which(group == value)
    part <- rows[index, , drop = FALSE]
    expected <- sum(part$ExpectedRow)
    eligible <- sum(part$Disposition == "eligible")
    rejected <- sum(part$Disposition == "rejected")
    missing <- sum(part$Disposition == "missing")
    failed <- sum(part$Disposition == "failed")
    unexpected <- sum(part$Disposition == "unexpected")
    included <- sum(part$IncludeInAggregate)
    ineligible_included <- sum(
      part$IncludeInAggregate & part$Disposition != "eligible"
    )
    metric <- suppressWarnings(
      as.numeric(mfrmr_ecec_character(part$MetricValue))
    )
    aggregate_value <- if (included > 0L) {
      mean(metric[part$IncludeInAggregate])
    } else {
      NA_real_
    }
    data.frame(
      part[1L, keys, drop = FALSE],
      ExpectedRows = expected,
      EligibleRows = eligible,
      RejectedRows = rejected,
      MissingRows = missing,
      FailedRows = failed,
      UnexpectedRows = unexpected,
      IncludedRows = included,
      IneligibleIncludedRows = ineligible_included,
      AggregateValue = aggregate_value,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  })
  out <- do.call(rbind, result)
  rownames(out) <- NULL
  out
}

mfrmr_ecec_reason_counts <- function(reasons) {
  keys <- c(
    mfrmr_ecec_stratum_columns(), "Disposition", "ReasonCode"
  )
  if (nrow(reasons) == 0L) {
    out <- reasons[FALSE, keys, drop = FALSE]
    out$Rows <- integer(0)
    return(out)
  }
  key_values <- lapply(reasons[keys], mfrmr_ecec_character)
  group <- do.call(paste, c(key_values, sep = "\037"))
  groups <- sort(unique(group), method = "radix")
  out <- do.call(rbind, lapply(groups, function(value) {
    index <- which(group == value)
    data.frame(
      reasons[index[1L], keys, drop = FALSE],
      Rows = length(index),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  }))
  rownames(out) <- NULL
  out
}

mfrmr_external_comparison_eligibility <- function(rows) {
  mfrmr_ecec_assert_input(rows)
  rows <- rows[order(mfrmr_ecec_character(rows$ComparisonRowId),
                     method = "radix"), , drop = FALSE]
  rownames(rows) <- NULL

  reason_codes <- vapply(
    seq_len(nrow(rows)),
    function(index) mfrmr_ecec_reason_codes(rows[index, , drop = FALSE]),
    character(1)
  )
  disposition <- ifelse(
    !rows$ExpectedRow, "unexpected",
    ifelse(
      !rows$ObservedRow, "missing",
      ifelse(!rows$FitSucceeded, "failed",
             ifelse(!nzchar(reason_codes), "eligible", "rejected"))
    )
  )
  rows$Disposition <- disposition
  rows$ReasonCodes <- reason_codes
  rows$Eligible <- disposition == "eligible"
  rows$IncludeInAggregate <- rows$Eligible

  denominators <- mfrmr_ecec_denominators(rows)
  if (any(
    denominators$ExpectedRows !=
      denominators$EligibleRows + denominators$RejectedRows +
        denominators$MissingRows + denominators$FailedRows
  )) {
    stop("expected-row denominator accounting failed", call. = FALSE)
  }
  if (any(denominators$IneligibleIncludedRows != 0L)) {
    stop("an ineligible comparison entered an aggregate", call. = FALSE)
  }

  reason_list <- strsplit(rows$ReasonCodes, ";", fixed = TRUE)
  stratum_columns <- mfrmr_ecec_stratum_columns()
  reason_rows <- do.call(rbind, lapply(seq_along(reason_list), function(i) {
    reasons <- reason_list[[i]]
    reasons <- reasons[nzchar(reasons)]
    if (length(reasons) == 0L) return(NULL)
    stratum <- rows[i, stratum_columns, drop = FALSE]
    rownames(stratum) <- NULL
    data.frame(
      ComparisonRowId = rows$ComparisonRowId[i],
      stratum,
      Disposition = rows$Disposition[i],
      ReasonCode = reasons,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  }))
  if (is.null(reason_rows)) {
    reason_rows <- rows[FALSE, c("ComparisonRowId", stratum_columns),
                        drop = FALSE]
    reason_rows$Disposition <- character(0)
    reason_rows$ReasonCode <- character(0)
  }
  rownames(reason_rows) <- NULL
  reason_counts <- mfrmr_ecec_reason_counts(reason_rows)

  list(
    Rows = rows,
    Denominators = denominators,
    Reasons = reason_rows,
    ReasonCounts = reason_counts,
    Decision = data.frame(
      StructuralContractValid = TRUE,
      EvidenceStatus = "review",
      Decision = "structural_contract_ready_external_bindings_pending",
      IneligibleIncludedRows = sum(denominators$IneligibleIncludedRows),
      stringsAsFactors = FALSE
    )
  )
}
