# mfrmr 0.2.3 prospective ConQuest tolerance-freeze contract
#
# This repository-only helper defines the estimand-level EXT-CQ-TOL and
# IC-INTEGRATION-TOL rows that must be frozen before a new candidate output is
# created or opened. It validates a future record; it neither chooses numeric
# tolerances nor retroactively evaluates the opened four-arm calibration.

mfrmr_cq_ptc_specification <-
  "0.2.3-wave-c-prospective-tolerance-freeze-v1"
mfrmr_cq_ptc_contract <-
  "mfrmr_conquest_prospective_tolerance_freeze_v1"
mfrmr_cq_ptc_executable_sha256 <-
  "61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48"

mfrmr_cq_ptc_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ptc_sha256_valid <- function(x) {
  x <- as.character(x)
  !is.na(x) & grepl("^[[:xdigit:]]{64}$", x)
}

mfrmr_cq_ptc_git_commit_valid <- function(x) {
  x <- as.character(x)
  !is.na(x) & grepl("^[[:xdigit:]]{40}$", x)
}

mfrmr_cq_ptc_relative_artifact <- function(x) {
  x <- as.character(x)
  !is.na(x) & nzchar(trimws(x)) &
    !grepl("^/|^[A-Za-z]:[/\\\\]", x) &
    !grepl("(^|[/\\\\])\\.\\.([/\\\\]|$)", x)
}

mfrmr_cq_ptc_estimand_registry <- function() {
  binary <- c(
    "population_intercept", "population_slope", "population_variance",
    "item_difficulty", "objective"
  )
  rsm <- c(
    "population_intercept", "population_slope", "population_variance",
    "rater_severity", "criterion_difficulty", "shared_step", "objective"
  )
  pcm <- c(
    "population_intercept", "population_slope", "population_variance",
    "rater_severity", "criterion_difficulty", "criterion_specific_step",
    "objective"
  )
  estimands <- rbind(
    data.frame(Family = "Binary", EstimandClass = binary),
    data.frame(Family = "RSM", EstimandClass = rsm),
    data.frame(Family = "PCM", EstimandClass = pcm)
  )
  units <- ifelse(
    estimands$EstimandClass == "objective",
    "positive_deviance",
    "common_model_coordinate"
  )
  external <- data.frame(
    CriterionId = "EXT-CQ-TOL",
    Engine = "cross_engine",
    estimands,
    DifferenceOrientation = "conquest_minus_mfrmr",
    Units = units,
    stringsAsFactors = FALSE
  )
  integration <- do.call(rbind, lapply(c("ConQuest", "mfrmr"), function(engine) {
    data.frame(
      CriterionId = "IC-INTEGRATION-TOL",
      Engine = engine,
      estimands,
      DifferenceOrientation = "q061_minus_q031",
      Units = units,
      stringsAsFactors = FALSE
    )
  }))
  out <- rbind(external, integration)
  out$ToleranceRowId <- paste(
    out$CriterionId, out$Engine, out$Family, out$EstimandClass, sep = "::"
  )
  out <- out[, c(
    "ToleranceRowId", "CriterionId", "Engine", "Family", "EstimandClass",
    "DifferenceOrientation", "Units"
  )]
  rownames(out) <- NULL
  mfrmr_cq_ptc_assert(
    nrow(out) == 57L && !anyDuplicated(out$ToleranceRowId),
    "The prospective ConQuest tolerance registry must contain 57 unique rows."
  )
  out
}

mfrmr_cq_ptc_tolerance_template <- function() {
  out <- mfrmr_cq_ptc_estimand_registry()
  out$SignedLower <- NA_real_
  out$SignedUpper <- NA_real_
  out$AbsoluteTolerance <- NA_real_
  out$RationaleType <- ""
  out$Rationale <- ""
  out$SourceArtifact <- ""
  out$SourceSHA256 <- ""
  out$CalibrationInformed <- NA
  out$OpenedCalibrationEligible <- FALSE
  out$Frozen <- FALSE
  out
}

mfrmr_cq_ptc_canonical_tolerance_text <- function(tolerances) {
  registry_columns <- names(mfrmr_cq_ptc_tolerance_template())
  mfrmr_cq_ptc_assert(
    is.data.frame(tolerances) && all(registry_columns %in% names(tolerances)),
    "The tolerance table does not satisfy the prospective freeze schema."
  )
  x <- tolerances[, registry_columns, drop = FALSE]
  x <- x[order(as.character(x$ToleranceRowId)), , drop = FALSE]
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
  rows <- vapply(seq_len(nrow(x)), function(index) {
    paste(vapply(encoded, `[[`, character(1L), index), collapse = "\t")
  }, character(1L))
  paste(c(paste(registry_columns, collapse = "\t"), rows), collapse = "\n")
}

mfrmr_cq_ptc_tolerance_sha256 <- function(tolerances) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The prospective ConQuest tolerance contract requires `digest`.",
         call. = FALSE)
  }
  unname(digest::digest(
    mfrmr_cq_ptc_canonical_tolerance_text(tolerances),
    algo = "sha256", serialize = FALSE
  ))
}

mfrmr_cq_ptc_binding_template <- function() {
  data.frame(
    CandidateId = "",
    PackageVersion = "0.2.3",
    SourceCommit = "",
    SourceTreeSHA256 = "",
    ConQuestExecutableSHA256 = mfrmr_cq_ptc_executable_sha256,
    CommandBundleSHA256 = "",
    InputBundleSHA256 = "",
    ExpectedEmptyOutputsSHA256 = "",
    SourcePrecisionPolicyId = "",
    SourcePrecisionPolicySHA256 = "",
    SourcePrecisionReady = FALSE,
    SourcePrecisionIndependentOfCandidateOutput = FALSE,
    ToleranceTableSHA256 = "",
    FrozenBeforeCandidateExecution = FALSE,
    CandidateOutputsPresentAtFreeze = FALSE,
    CandidateOutputsOpenedAtFreeze = FALSE,
    CalibrationCanPassNewRule = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ptc_validate_tolerance_rows <- function(tolerances) {
  template <- mfrmr_cq_ptc_tolerance_template()
  required <- names(template)
  mfrmr_cq_ptc_assert(
    is.data.frame(tolerances), "`tolerances` must be a data frame."
  )
  missing_columns <- setdiff(required, names(tolerances))
  if (length(missing_columns) > 0L) {
    return(list(
      schema_ok = FALSE,
      identity_ok = FALSE,
      all_rows_ready = FALSE,
      missing_columns = missing_columns,
      row_review = data.frame()
    ))
  }
  x <- tolerances[, required, drop = FALSE]
  key <- as.character(x$ToleranceRowId)
  expected <- as.character(template$ToleranceRowId)
  identity_ok <- !anyNA(key) && !anyDuplicated(key) && setequal(key, expected)
  if (!identity_ok) {
    return(list(
      schema_ok = TRUE,
      identity_ok = FALSE,
      all_rows_ready = FALSE,
      missing_columns = character(0),
      row_review = data.frame()
    ))
  }
  x <- x[match(expected, key), , drop = FALSE]
  identity_columns <- c(
    "ToleranceRowId", "CriterionId", "Engine", "Family", "EstimandClass",
    "DifferenceOrientation", "Units"
  )
  registry_identity_ok <- vapply(identity_columns, function(column) {
    identical(as.character(x[[column]]), as.character(template[[column]]))
  }, logical(1L))
  lower <- suppressWarnings(as.numeric(x$SignedLower))
  upper <- suppressWarnings(as.numeric(x$SignedUpper))
  absolute <- suppressWarnings(as.numeric(x$AbsoluteTolerance))
  numeric_rule_ok <- is.finite(lower) & is.finite(upper) &
    is.finite(absolute) & lower <= 0 & upper >= 0 & absolute >= 0
  rationale_types <- c(
    "scientific_decision_rule", "independent_numerical_reference",
    "opened_calibration_future_candidate_only"
  )
  rationale_ok <- as.character(x$RationaleType) %in% rationale_types &
    nzchar(trimws(as.character(x$Rationale)))
  source_ok <- mfrmr_cq_ptc_relative_artifact(x$SourceArtifact) &
    mfrmr_cq_ptc_sha256_valid(x$SourceSHA256)
  calibration_informed <- as.logical(x$CalibrationInformed)
  basis_consistent <- !is.na(calibration_informed) &
    (calibration_informed == (
      as.character(x$RationaleType) ==
        "opened_calibration_future_candidate_only"
    ))
  opened_calibration_ineligible <-
    !is.na(as.logical(x$OpenedCalibrationEligible)) &
    !as.logical(x$OpenedCalibrationEligible)
  frozen <- !is.na(as.logical(x$Frozen)) & as.logical(x$Frozen)
  row_ready <- numeric_rule_ok & rationale_ok & source_ok &
    basis_consistent & opened_calibration_ineligible & frozen
  row_review <- data.frame(
    ToleranceRowId = expected,
    NumericRuleOK = numeric_rule_ok,
    RationaleOK = rationale_ok,
    SourceIdentityOK = source_ok,
    BasisConsistent = basis_consistent,
    OpenedCalibrationIneligible = opened_calibration_ineligible,
    Frozen = frozen,
    RowReady = row_ready,
    stringsAsFactors = FALSE
  )
  list(
    schema_ok = TRUE,
    identity_ok = all(registry_identity_ok),
    all_rows_ready = all(row_ready) && all(registry_identity_ok),
    missing_columns = character(0),
    row_review = row_review
  )
}

mfrmr_cq_ptc_validate_binding <- function(binding, tolerance_sha256) {
  template <- mfrmr_cq_ptc_binding_template()
  required <- names(template)
  mfrmr_cq_ptc_assert(
    is.data.frame(binding), "`binding` must be a data frame."
  )
  schema_ok <- nrow(binding) == 1L && all(required %in% names(binding))
  if (!schema_ok) {
    return(list(schema_ok = FALSE, binding_ready = FALSE, review = data.frame()))
  }
  x <- binding[1L, required, drop = FALSE]
  hashes <- c(
    "SourceTreeSHA256", "ConQuestExecutableSHA256", "CommandBundleSHA256",
    "InputBundleSHA256", "ExpectedEmptyOutputsSHA256",
    "SourcePrecisionPolicySHA256",
    "ToleranceTableSHA256"
  )
  hash_ok <- vapply(hashes, function(column) {
    mfrmr_cq_ptc_sha256_valid(x[[column]])
  }, logical(1L))
  strict_flag <- function(value, expected) {
    is.logical(value) && length(value) == 1L && !is.na(value) &&
      identical(value, expected)
  }
  review <- data.frame(
    CandidateIdOK = nzchar(trimws(as.character(x$CandidateId))),
    PackageVersionOK = identical(as.character(x$PackageVersion), "0.2.3"),
    SourceCommitOK = mfrmr_cq_ptc_git_commit_valid(x$SourceCommit),
    HashFieldsOK = all(hash_ok),
    ExecutableIdentityOK = identical(
      tolower(as.character(x$ConQuestExecutableSHA256)),
      mfrmr_cq_ptc_executable_sha256
    ),
    SourcePrecisionPolicyIdOK = nzchar(trimws(
      as.character(x$SourcePrecisionPolicyId)
    )),
    SourcePrecisionReady = strict_flag(x$SourcePrecisionReady, TRUE),
    SourcePrecisionProspective = strict_flag(
      x$SourcePrecisionIndependentOfCandidateOutput, TRUE
    ),
    ToleranceHashOK = identical(
      tolower(as.character(x$ToleranceTableSHA256)),
      tolower(as.character(tolerance_sha256))
    ),
    FrozenBeforeExecution = strict_flag(
      x$FrozenBeforeCandidateExecution, TRUE
    ),
    OutputsAbsentAtFreeze = strict_flag(
      x$CandidateOutputsPresentAtFreeze, FALSE
    ),
    OutputsUnopenedAtFreeze = strict_flag(
      x$CandidateOutputsOpenedAtFreeze, FALSE
    ),
    CalibrationCannotPassNewRule = strict_flag(
      x$CalibrationCanPassNewRule, FALSE
    ),
    stringsAsFactors = FALSE
  )
  list(
    schema_ok = TRUE,
    binding_ready = all(unlist(review, use.names = FALSE)),
    review = review
  )
}

mfrmr_cq_prospective_tolerance_preflight <- function(tolerances, binding) {
  row_status <- mfrmr_cq_ptc_validate_tolerance_rows(tolerances)
  tolerance_sha256 <- if (row_status$schema_ok && row_status$identity_ok) {
    mfrmr_cq_ptc_tolerance_sha256(tolerances)
  } else {
    NA_character_
  }
  binding_status <- mfrmr_cq_ptc_validate_binding(binding, tolerance_sha256)
  ready <- isTRUE(row_status$all_rows_ready) &&
    isTRUE(binding_status$binding_ready)
  out <- list(
    specification = mfrmr_cq_ptc_specification,
    contract_version = mfrmr_cq_ptc_contract,
    status = if (ready) "prospective_freeze_structurally_ready" else "pilot_required",
    decision = if (ready) {
      "candidate_core_run_structurally_authorized"
    } else {
      "hold_tolerance_or_candidate_binding_incomplete"
    },
    tolerance_table_sha256 = tolerance_sha256,
    tolerance_schema_ok = row_status$schema_ok,
    tolerance_identity_ok = row_status$identity_ok,
    all_tolerance_rows_ready = row_status$all_rows_ready,
    candidate_binding_ready = binding_status$binding_ready,
    opened_calibration_reclassification_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    large_simulation_authorized = FALSE,
    row_review = row_status$row_review,
    binding_review = binding_status$review
  )
  class(out) <- c("mfrmr_conquest_prospective_tolerance_preflight", class(out))
  out
}
