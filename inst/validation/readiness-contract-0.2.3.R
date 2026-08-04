# Internal mfrmr 0.2.3 readiness contract
#
# Repository-only schema and fixture validator. This file deliberately does
# not alter package fitting or exported APIs. Runtime integration belongs to
# WP1--WP5 in internal-roadmap-0.2.3.md.

mfrmr_readiness_contract_version <- function() {
  "mfrmr-readiness-0.2.3-v3"
}

mfrmr_readiness_contract_states <- function() {
  list(
    ReadinessScope = c("fit", "parameter", "comparison"),
    InputState = c("pass", "review", "blocked", "legacy_unknown"),
    EstimabilityState = c(
      "identified", "population_assumption_linked", "weak_information",
      "structurally_unidentified", "not_evaluated", "legacy_unknown"
    ),
    CategoryState = c(
      "adequate", "weak_information", "unsupported_coordinate",
      "not_applicable", "not_evaluated", "legacy_unknown"
    ),
    BoundaryState = c(
      "finite", "has_exclusions", "not_applicable", "not_evaluated",
      "legacy_unknown"
    ),
    NumericalState = c(
      "ready", "review", "failed", "not_run", "legacy_unknown"
    ),
    FitReadiness = c(
      "ready", "ready_with_exclusions", "review", "blocked",
      "legacy_unknown"
    ),
    ParameterStatus = c(
      "estimable", "fixed", "weak_information", "unbounded_low",
      "unbounded_high", "unbounded_both", "aliased", "unsupported",
      "not_estimated", "not_evaluated", "legacy_unknown"
    ),
    ComparisonEligibility = c(
      "eligible", "ineligible", "missing", "failed", "not_applicable"
    ),
    ExpectedAction = c(
      "return_ready_fit", "return_review_fit", "return_partial_fit",
      "return_blocked_diagnostic", "stop_before_fit", "retain_parameter",
      "label_legacy", "include_metric", "exclude_metric", "report_missing",
      "report_failed"
    ),
    EvidenceRole = c(
      "unit_positive", "unit_negative", "migration",
      "comparison_positive", "comparison_negative"
    )
  )
}

mfrmr_readiness_reason_codes <- function() {
  data.frame(
    ReasonCode = c(
      "input_invalid",
      "input_review_required",
      "duplicate_cell_dependence_unmodelled",
      "legacy_contract_missing",
      "design_rank_deficient",
      "design_rank_not_evaluated",
      "disconnected_without_link",
      "population_assumption_linked",
      "single_level_facet",
      "weak_design_information",
      "declared_category_unobserved_global",
      "declared_boundary_category_unobserved",
      "step_scope_category_unobserved",
      "unsupported_step_coordinate",
      "weak_category_information",
      "jml_extreme_low",
      "jml_extreme_high",
      "fixed_extreme_response",
      "mml_extreme_response_prior_regularized",
      "boundary_candidate_not_propagated",
      "boundary_audit_incomplete",
      "jml_gpcm_slope_boundary_low",
      "jml_gpcm_slope_boundary_high",
      "jml_gpcm_slope_boundary_both",
      "jml_gpcm_joint_boundary_not_evaluated",
      "jml_gpcm_joint_boundary_candidate",
      "jml_gpcm_joint_boundary_candidate_high",
      "jml_gpcm_joint_boundary_candidate_low",
      "jml_gpcm_joint_boundary_candidate_both",
      "jml_gpcm_joint_boundary_none_certified",
      "mml_gpcm_slope_boundary_not_evaluated",
      "gpcm_unit_slope_fixed",
      "optimizer_failed",
      "iteration_limit",
      "terminal_gradient_review",
      "optimizer_review_required",
      "numerical_not_run",
      "response_family_mismatch",
      "estimator_mismatch",
      "observation_set_mismatch",
      "weight_contract_mismatch",
      "active_facet_mismatch",
      "orientation_mismatch",
      "category_map_mismatch",
      "step_dimension_mismatch",
      "anchor_constraint_mismatch",
      "coordinate_transform_mismatch",
      "parameter_not_estimable",
      "extreme_convention_mismatch",
      "external_result_missing",
      "external_run_failed"
    ),
    ReasonScope = c(
      "fit", "fit", "fit", "fit;parameter",
      "fit;parameter", "fit", "fit", "fit",
      "fit;parameter", "fit;parameter",
      "fit;parameter;comparison", "fit;parameter;comparison",
      "fit;parameter;comparison", "fit;parameter;comparison",
      "fit;parameter", "fit;parameter;comparison",
      "fit;parameter;comparison", "parameter", "parameter;comparison",
      "fit;parameter", "fit",
      "parameter;comparison", "parameter;comparison",
      "parameter;comparison", "fit;parameter",
      "fit;parameter", "parameter;comparison", "parameter;comparison",
      "parameter;comparison", "parameter;comparison", "fit;parameter",
      "parameter",
      "fit", "fit", "fit", "fit", "fit",
      "comparison", "comparison", "comparison", "comparison",
      "comparison", "comparison", "comparison", "comparison",
      "comparison", "comparison", "comparison", "comparison",
      "comparison", "comparison"
    ),
    Component = c(
      rep("input", 4L),
      rep("estimability", 6L),
      rep("category", 5L),
      rep("boundary", 17L),
      rep("numerical", 5L),
      rep("comparison", 14L)
    ),
    DefaultSeverity = c(
      "blocked", "review", "review", "legacy_unknown",
      "blocked", "review", "blocked", "review", "blocked", "review",
      "blocked", "blocked", "blocked", "blocked", "review",
      "exclusion", "exclusion", "information", "information",
      "review", "review",
      "exclusion", "exclusion", "exclusion", "review",
      "review", "review", "review", "review", "review", "review", "fixed",
      "blocked", "review", "review", "review", "blocked",
      rep("ineligible", 12L), "missing", "failed"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_readiness_condition_classes <- function() {
  data.frame(
    Component = c(
      "input", "estimability", "category", "boundary", "numerical",
      "legacy"
    ),
    BlockingClass = c(
      "mfrmr_input_readiness_error",
      "mfrmr_estimability_error",
      "mfrmr_category_readiness_error",
      NA_character_,
      NA_character_,
      NA_character_
    ),
    ReviewClass = c(
      "mfrmr_input_readiness_warning",
      "mfrmr_estimability_warning",
      "mfrmr_category_readiness_warning",
      "mfrmr_boundary_readiness_warning",
      "mfrmr_numerical_readiness_warning",
      "mfrmr_legacy_readiness_warning"
    ),
    ParentClass = c(
      "mfrmr_readiness_condition", "mfrmr_readiness_condition",
      "mfrmr_readiness_condition", "mfrmr_readiness_condition",
      "mfrmr_readiness_condition", "mfrmr_readiness_condition"
    ),
    RuntimePolicy = c(
      "invalid input stops before optimization with a structured preflight payload",
      "exact structural nonidentification stops before optimization with a structured preflight payload",
      "unsupported free category or step coordinates stop before optimization with a structured preflight payload",
      "typed exclusions remain on a partial fit and warn at first inferential use",
      "review or failure remains on the returned fit and cannot become ready from optimizer text alone",
      "objects without the contract remain legacy_unknown until explicitly re-audited or refitted"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_readiness_derive_fit <- function(InputState, EstimabilityState,
                                       CategoryState, BoundaryState,
                                       NumericalState) {
  states <- mfrmr_readiness_contract_states()
  values <- list(
    InputState = InputState,
    EstimabilityState = EstimabilityState,
    CategoryState = CategoryState,
    BoundaryState = BoundaryState,
    NumericalState = NumericalState
  )
  for (field in names(values)) {
    value <- values[[field]]
    if (length(value) != 1L || is.na(value) ||
        !value %in% states[[field]]) {
      stop(sprintf("Invalid %s: %s", field, paste(value, collapse = ", ")),
           call. = FALSE)
    }
  }

  blocked <- InputState == "blocked" ||
    EstimabilityState == "structurally_unidentified" ||
    CategoryState == "unsupported_coordinate" ||
    NumericalState %in% c("failed", "not_run")
  if (blocked) {
    return("blocked")
  }

  legacy <- InputState == "legacy_unknown" ||
    EstimabilityState == "legacy_unknown" ||
    CategoryState == "legacy_unknown" ||
    BoundaryState == "legacy_unknown" ||
    NumericalState == "legacy_unknown"
  if (legacy) {
    return("legacy_unknown")
  }

  review <- InputState == "review" ||
    EstimabilityState %in% c(
      "population_assumption_linked", "weak_information", "not_evaluated"
    ) ||
    CategoryState %in% c("weak_information", "not_evaluated") ||
    BoundaryState == "not_evaluated" ||
    NumericalState == "review"
  if (review) {
    return("review")
  }

  if (BoundaryState == "has_exclusions") {
    return("ready_with_exclusions")
  }

  "ready"
}

mfrmr_readiness_inference_ready <- function(FitReadiness) {
  states <- mfrmr_readiness_contract_states()$FitReadiness
  if (length(FitReadiness) != 1L || is.na(FitReadiness) ||
      !FitReadiness %in% states) {
    stop("`FitReadiness` must be one allowed scalar state.", call. = FALSE)
  }
  identical(FitReadiness, "ready")
}

mfrmr_readiness_legacy_map <- function(inference_ready = NA) {
  data.frame(
    SourceContract = "absent_or_pre_0.2.3",
    SourceInferenceReady = if (length(inference_ready)) {
      as.character(inference_ready[1])
    } else {
      NA_character_
    },
    FitReadiness = "legacy_unknown",
    InferenceReady = FALSE,
    ReasonCode = "legacy_contract_missing",
    UpgradePolicy = paste(
      "never infer current readiness from the legacy scalar;",
      "explicit re-audit or refit creates a new provenance-bearing record"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_readiness_split_codes <- function(x) {
  if (length(x) == 0L || is.na(x) || !nzchar(trimws(x))) {
    return(character())
  }
  unique(trimws(strsplit(x, ";", fixed = TRUE)[[1]]))
}

mfrmr_readiness_validate_fixtures <- function(path, strict = FALSE) {
  errors <- character()
  add_error <- function(...) {
    errors <<- c(errors, sprintf(...))
  }

  if (!file.exists(path)) {
    add_error("Fixture file does not exist: %s", path)
    out <- list(Valid = FALSE, Errors = errors, Rows = 0L)
    if (isTRUE(strict)) stop(errors[1], call. = FALSE)
    return(out)
  }

  fixtures <- utils::read.csv(
    path, stringsAsFactors = FALSE, check.names = FALSE,
    na.strings = c("", "NA")
  )
  required <- c(
    "ReadinessContractVersion", "FixtureId", "Method", "Model",
    "Stressor", "ReadinessScope", "Target", "InputState",
    "EstimabilityState", "CategoryState", "BoundaryState",
    "NumericalState", "FitReadiness", "InferenceReady",
    "ParameterStatus", "ComparisonEligibility", "ReasonCodes",
    "ExpectedAction", "EvidenceRole"
  )
  missing_columns <- setdiff(required, names(fixtures))
  if (length(missing_columns)) {
    add_error("Missing columns: %s", paste(missing_columns, collapse = ", "))
  }
  if (length(errors)) {
    out <- list(Valid = FALSE, Errors = errors, Rows = nrow(fixtures))
    if (isTRUE(strict)) stop(paste(errors, collapse = "\n"), call. = FALSE)
    return(out)
  }

  states <- mfrmr_readiness_contract_states()
  expected_version <- mfrmr_readiness_contract_version()
  wrong_version <- which(is.na(fixtures$ReadinessContractVersion) |
                         fixtures$ReadinessContractVersion != expected_version)
  if (length(wrong_version)) {
    add_error("Rows with an incorrect contract version: %s",
              paste(wrong_version, collapse = ", "))
  }

  key <- paste(fixtures$FixtureId, fixtures$ReadinessScope, fixtures$Target,
               sep = "::")
  duplicates <- which(duplicated(key) | duplicated(key, fromLast = TRUE))
  if (length(duplicates)) {
    add_error("Duplicate fixture scope/target keys at rows: %s",
              paste(unique(duplicates), collapse = ", "))
  }

  check_allowed <- function(field) {
    observed <- unique(stats::na.omit(fixtures[[field]]))
    invalid <- setdiff(observed, states[[field]])
    if (length(invalid)) {
      add_error("Invalid %s values: %s", field, paste(invalid, collapse = ", "))
    }
  }
  for (field in c(
    "ReadinessScope", "InputState", "EstimabilityState", "CategoryState",
    "BoundaryState", "NumericalState", "FitReadiness", "ParameterStatus",
    "ComparisonEligibility", "ExpectedAction", "EvidenceRole"
  )) {
    check_allowed(field)
  }

  fit_rows <- which(fixtures$ReadinessScope == "fit")
  fit_required <- c(
    "InputState", "EstimabilityState", "CategoryState", "BoundaryState",
    "NumericalState", "FitReadiness", "InferenceReady"
  )
  for (row in fit_rows) {
    if (any(is.na(fixtures[row, fit_required, drop = TRUE]))) {
      add_error("Fit row %s is missing a component or summary state.", row)
      next
    }
    derived <- mfrmr_readiness_derive_fit(
      fixtures$InputState[row], fixtures$EstimabilityState[row],
      fixtures$CategoryState[row], fixtures$BoundaryState[row],
      fixtures$NumericalState[row]
    )
    if (!identical(derived, fixtures$FitReadiness[row])) {
      add_error("Fit row %s derives %s, not %s.", row, derived,
                fixtures$FitReadiness[row])
    }
    expected_scalar <- mfrmr_readiness_inference_ready(derived)
    observed_scalar <- tolower(as.character(fixtures$InferenceReady[row]))
    if (!observed_scalar %in% c("true", "false") ||
        as.logical(observed_scalar) != expected_scalar) {
      add_error("Fit row %s has an incorrect InferenceReady mapping.", row)
    }
    allowed_action <- switch(
      derived,
      ready = "return_ready_fit",
      ready_with_exclusions = "return_partial_fit",
      review = "return_review_fit",
      blocked = c("stop_before_fit", "return_blocked_diagnostic"),
      legacy_unknown = "label_legacy"
    )
    if (!fixtures$ExpectedAction[row] %in% allowed_action) {
      add_error("Fit row %s has an action inconsistent with %s.", row, derived)
    }
  }

  parameter_rows <- which(fixtures$ReadinessScope == "parameter")
  if (length(parameter_rows) &&
      any(is.na(fixtures$ParameterStatus[parameter_rows]))) {
    add_error("Every parameter row must define ParameterStatus.")
  }
  for (row in parameter_rows) {
    allowed_action <- if (fixtures$ParameterStatus[row] == "legacy_unknown") {
      "label_legacy"
    } else if (fixtures$ParameterStatus[row] %in% c("aliased", "unsupported")) {
      c("stop_before_fit", "retain_parameter")
    } else {
      "retain_parameter"
    }
    if (!fixtures$ExpectedAction[row] %in% allowed_action) {
      add_error("Parameter row %s has an action inconsistent with %s.",
                row, fixtures$ParameterStatus[row])
    }
  }
  comparison_rows <- which(fixtures$ReadinessScope == "comparison")
  if (length(comparison_rows) &&
      any(is.na(fixtures$ComparisonEligibility[comparison_rows]))) {
    add_error("Every comparison row must define ComparisonEligibility.")
  }
  comparison_actions <- c(
    eligible = "include_metric",
    ineligible = "exclude_metric",
    missing = "report_missing",
    failed = "report_failed",
    not_applicable = "exclude_metric"
  )
  for (row in comparison_rows) {
    expected_action <- comparison_actions[
      fixtures$ComparisonEligibility[row]
    ]
    if (!identical(fixtures$ExpectedAction[row], unname(expected_action))) {
      add_error("Comparison row %s has an action inconsistent with %s.",
                row, fixtures$ComparisonEligibility[row])
    }
  }

  reason_catalog <- mfrmr_readiness_reason_codes()
  for (row in seq_len(nrow(fixtures))) {
    codes <- mfrmr_readiness_split_codes(fixtures$ReasonCodes[row])
    unknown <- setdiff(codes, reason_catalog$ReasonCode)
    if (length(unknown)) {
      add_error("Row %s has unknown reason codes: %s", row,
                paste(unknown, collapse = ", "))
    }
    for (code in intersect(codes, reason_catalog$ReasonCode)) {
      scopes <- mfrmr_readiness_split_codes(
        reason_catalog$ReasonScope[reason_catalog$ReasonCode == code][1]
      )
      if (!fixtures$ReadinessScope[row] %in% scopes) {
        add_error("Row %s uses %s outside its declared scope.", row, code)
      }
    }
  }

  required_fixtures <- c(
    "balanced_jml", "balanced_mml", "two_rater_no_common_jml",
    "two_rater_no_common_mml", "pcm_unsupported_step", "jml_extreme",
    "jml_anchored_extreme", "mml_extreme", "iteration_limit",
    "legacy_0.2.2", "facets_pcm_dimension_mismatch",
    "facets_extreme_convention_mismatch"
  )
  absent <- setdiff(required_fixtures, unique(fixtures$FixtureId))
  if (length(absent)) {
    add_error("Missing required fixtures: %s", paste(absent, collapse = ", "))
  }

  out <- list(
    Valid = length(errors) == 0L,
    Errors = errors,
    Rows = nrow(fixtures),
    FitRows = length(fit_rows),
    ParameterRows = length(parameter_rows),
    ComparisonRows = length(comparison_rows),
    ContractVersion = expected_version
  )
  if (isTRUE(strict) && !out$Valid) {
    stop(paste(errors, collapse = "\n"), call. = FALSE)
  }
  out
}
