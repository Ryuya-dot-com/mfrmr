# Repository-only ConQuest prospective numerical-budget freeze for the exact
# reported-decimal six-arm candidate. It creates and validates the canonical
# 57-row table, but does not bind a candidate or launch ConQuest.

mfrmr_cq_ptf_specification <-
  "0.2.3-wave-c-prospective-tolerance-freeze-v2"
mfrmr_cq_ptf_contract <-
  "mfrmr_conquest_prospective_tolerance_table_v1"
mfrmr_cq_ptf_basis_artifact <-
  "inst/validation/conquest-prospective-tolerance-basis-0.2.3.md"
mfrmr_cq_ptf_basis_sha256 <-
  "9b4c76add31061dcee532fcf2528e2614bd151dca75d3792fbde5364361279bd"

mfrmr_cq_ptf_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ptf_require_contract <- function() {
  target <- environment(mfrmr_cq_ptf_require_contract)
  required <- c(
    "mfrmr_cq_ptc_tolerance_template",
    "mfrmr_cq_ptc_validate_tolerance_rows",
    "mfrmr_cq_ptc_tolerance_sha256",
    "mfrmr_cq_ptc_binding_template",
    "mfrmr_cq_prospective_tolerance_preflight"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  contract_ready <- exists(
    "mfrmr_cq_ptc_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ptc_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_prospective_tolerance_freeze_v1"
  )
  mfrmr_cq_ptf_assert(
    all(available) && contract_ready,
    "Source the exact prospective ConQuest tolerance contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_ptf_validation_dir <- function() {
  source_file <- tryCatch(sys.frame(1L)$ofile, error = function(...) NULL)
  if (is.null(source_file) || !nzchar(source_file)) source_file <- ""
  roots <- c(
    getwd(), dirname(source_file), file.path(getwd(), ".."),
    file.path(getwd(), "..", ".."),
    file.path(getwd(), "..", "..", "..")
  )
  candidates <- unique(normalizePath(c(
    roots, file.path(roots, "inst", "validation")
  ), winslash = "/", mustWork = FALSE))
  hit <- candidates[file.exists(file.path(
    candidates, basename(mfrmr_cq_ptf_basis_artifact)
  ))]
  mfrmr_cq_ptf_assert(
    length(hit) >= 1L,
    "The prospective ConQuest tolerance-basis artifact is unavailable."
  )
  hit[1L]
}

mfrmr_cq_ptf_basis_status <- function() {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The prospective ConQuest tolerance freeze requires `digest`.",
         call. = FALSE)
  }
  path <- file.path(
    mfrmr_cq_ptf_validation_dir(), basename(mfrmr_cq_ptf_basis_artifact)
  )
  actual <- unname(digest::digest(
    path, algo = "sha256", file = TRUE, serialize = FALSE
  ))
  data.frame(
    SourceArtifact = mfrmr_cq_ptf_basis_artifact,
    ExpectedSHA256 = mfrmr_cq_ptf_basis_sha256,
    ActualSHA256 = actual,
    IdentityOK = identical(actual, mfrmr_cq_ptf_basis_sha256),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ptf_budget_registry <- function() {
  out <- data.frame(
    CriterionId = c(
      "EXT-CQ-TOL", "EXT-CQ-TOL",
      "IC-INTEGRATION-TOL", "IC-INTEGRATION-TOL"
    ),
    Units = rep(c("common_model_coordinate", "positive_deviance"), 2L),
    SignedLower = c(-1e-5, -2e-6, -2e-6, -2e-6),
    SignedUpper = c(1e-5, 2e-6, 2e-6, 2e-6),
    AbsoluteTolerance = c(1e-5, 2e-6, 2e-6, 2e-6),
    RationaleType = "opened_calibration_future_candidate_only",
    CalibrationInformed = TRUE,
    OpenedCalibrationEligible = FALSE,
    Frozen = TRUE,
    stringsAsFactors = FALSE
  )
  out$BudgetId <- paste(out$CriterionId, out$Units, sep = "::")
  out <- out[, c(
    "BudgetId", "CriterionId", "Units", "SignedLower", "SignedUpper",
    "AbsoluteTolerance", "RationaleType", "CalibrationInformed",
    "OpenedCalibrationEligible", "Frozen"
  )]
  mfrmr_cq_ptf_assert(
    nrow(out) == 4L && !anyDuplicated(out$BudgetId),
    "The ConQuest tolerance budget registry must contain four unique rows."
  )
  out
}

mfrmr_cq_ptf_build_tolerances <- function() {
  mfrmr_cq_ptf_require_contract()
  basis <- mfrmr_cq_ptf_basis_status()
  mfrmr_cq_ptf_assert(
    isTRUE(basis$IdentityOK),
    "The prospective ConQuest tolerance-basis SHA-256 changed."
  )
  out <- mfrmr_cq_ptc_tolerance_template()
  budgets <- mfrmr_cq_ptf_budget_registry()
  budget_key <- paste(out$CriterionId, out$Units, sep = "::")
  index <- match(budget_key, budgets$BudgetId)
  mfrmr_cq_ptf_assert(
    !anyNA(index),
    "At least one prospective ConQuest tolerance row has no typed budget."
  )
  out$SignedLower <- budgets$SignedLower[index]
  out$SignedUpper <- budgets$SignedUpper[index]
  out$AbsoluteTolerance <- budgets$AbsoluteTolerance[index]
  out$RationaleType <- budgets$RationaleType[index]
  out$Rationale <- paste(
    "Future-candidate-only symmetric engineering budget for",
    out$CriterionId, out$Family, out$EstimandClass,
    "under the exact reported-decimal six-arm contract; opened calibration",
    "and hidden-solution equivalence remain ineligible."
  )
  out$SourceArtifact <- mfrmr_cq_ptf_basis_artifact
  out$SourceSHA256 <- mfrmr_cq_ptf_basis_sha256
  out$CalibrationInformed <- budgets$CalibrationInformed[index]
  out$OpenedCalibrationEligible <- budgets$OpenedCalibrationEligible[index]
  out$Frozen <- budgets$Frozen[index]
  out
}

mfrmr_cq_ptf_expected_tolerance_sha256 <-
  "64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521"

mfrmr_cq_ptf_validate_tolerances <- function(tolerances) {
  mfrmr_cq_ptf_require_contract()
  basis <- mfrmr_cq_ptf_basis_status()
  canonical <- mfrmr_cq_ptf_build_tolerances()
  actual <- as.data.frame(tolerances, stringsAsFactors = FALSE,
                          check.names = FALSE)
  status <- mfrmr_cq_ptc_validate_tolerance_rows(actual)
  actual_sha256 <- if (isTRUE(status$schema_ok) &&
      isTRUE(status$identity_ok)) {
    mfrmr_cq_ptc_tolerance_sha256(actual)
  } else {
    NA_character_
  }
  canonical_sha256 <- mfrmr_cq_ptc_tolerance_sha256(canonical)
  table_identical <- identical(actual, canonical)
  hash_frozen <- identical(
    actual_sha256, mfrmr_cq_ptf_expected_tolerance_sha256
  ) && identical(
    canonical_sha256, mfrmr_cq_ptf_expected_tolerance_sha256
  )
  out <- list(
    specification = mfrmr_cq_ptf_specification,
    contract_version = mfrmr_cq_ptf_contract,
    status = if (
      isTRUE(basis$IdentityOK) && isTRUE(status$all_rows_ready) &&
        table_identical && hash_frozen
    ) {
      "tolerance_table_frozen_candidate_unbound"
    } else {
      "invalid_or_mutated_tolerance_table"
    },
    basis = basis,
    row_validation = status,
    table_identical = table_identical,
    tolerance_table_sha256 = actual_sha256,
    expected_tolerance_table_sha256 =
      mfrmr_cq_ptf_expected_tolerance_sha256,
    hash_frozen = hash_frozen,
    all_rows_ready = isTRUE(status$all_rows_ready) && table_identical &&
      hash_frozen && isTRUE(basis$IdentityOK),
    opened_calibration_reclassification_authorized = FALSE,
    hidden_solution_equivalence_eligible = FALSE,
    scientific_equivalence_inferred = FALSE,
    candidate_bound = FALSE,
    candidate_execution_authorized = FALSE,
    confirmation_authorized = FALSE
  )
  class(out) <- c("mfrmr_conquest_tolerance_freeze", class(out))
  out
}

mfrmr_cq_ptf_review <- function(
    binding = mfrmr_cq_ptc_binding_template()) {
  tolerances <- mfrmr_cq_ptf_build_tolerances()
  freeze <- mfrmr_cq_ptf_validate_tolerances(tolerances)
  preflight <- mfrmr_cq_prospective_tolerance_preflight(tolerances, binding)
  out <- list(
    specification = mfrmr_cq_ptf_specification,
    contract_version = mfrmr_cq_ptf_contract,
    status = if (isTRUE(freeze$all_rows_ready) &&
      !isTRUE(preflight$candidate_binding_ready)) {
      "tolerance_frozen_candidate_binding_required"
    } else if (isTRUE(freeze$all_rows_ready) &&
      isTRUE(preflight$candidate_binding_ready)) {
      "tolerance_and_candidate_binding_structurally_ready"
    } else {
      "tolerance_freeze_invalid"
    },
    freeze = freeze,
    preflight = preflight,
    tolerances = tolerances,
    tolerance_frozen = isTRUE(freeze$all_rows_ready),
    candidate_bound = isTRUE(preflight$candidate_binding_ready),
    candidate_core_structurally_authorized = isTRUE(
      freeze$all_rows_ready && preflight$candidate_binding_ready
    ),
    candidate_execution_authorized = FALSE,
    opened_calibration_reclassification_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE
  )
  class(out) <- c("mfrmr_conquest_tolerance_freeze_review", class(out))
  out
}
