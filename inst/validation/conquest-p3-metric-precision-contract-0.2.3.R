# Repository-only P3 metric, precision, integration, and denominator contract.
#
# This contract is prospective and side-effect free. P2/Candidate-003 budgets
# are not transferred across the changed GPCM estimand and identification map.
# Raw decimal tokens are compared as resolution intervals, the q=31 snapshot
# is diagnostic rather than a stopping target, and q=61 -> q=121 plus the
# continuous target jointly govern integration eligibility. This file never
# launches ConQuest, opens candidate output, or authorizes equivalence.

mfrmr_cq_p3m_specification <-
  "0.2.3-conquest-p3-metric-precision-contract-v1"
mfrmr_cq_p3m_contract <- "mfrmr_conquest_p3_metric_precision_contract_v1"

mfrmr_cq_p3m_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p3m_require_contracts <- function() {
  target <- environment(mfrmr_cq_p3m_require_contracts)
  required <- c(
    "mfrmr_cq_ssr_registry", "mfrmr_cq_p3_fixture_registry",
    "mfrmr_cq_p3_matrix_contract", "mfrmr_cq_p3_review"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- c(
    exists("mfrmr_cq_ssr_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_ssr_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_successor_semantic_registry_v1"
      ),
    exists("mfrmr_cq_p3_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p3_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p3_item_only_adversarial_fixtures_v1"
      )
  )
  mfrmr_cq_p3m_assert(
    all(available) && all(identity),
    paste(
      "Source the exact successor registry and P3 item-only fixture",
      "contract before the P3 metric-precision contract."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_p3m_budget_registry <- function() {
  data.frame(
    BudgetId = c(
      "P3-MAPPED-KERNEL-COORDINATE",
      "P3-POPULATION-LOCATION",
      "P3-LOG-POPULATION-SCALE",
      "P3-REGRESSION",
      "P3-ITEM-LOCATION",
      "P3-LOG-RELATIVE-SLOPE",
      "P3-TRANSITION-STEP",
      "P3-CROSS-ENGINE-DEVIANCE",
      "P3-FINAL-Q-COORDINATE",
      "P3-FINAL-Q-DEVIANCE",
      "P3-Q121-CONTINUOUS-DEVIANCE"
    ),
    Units = c(
      "mapped_common_coordinate", "latent_trait_coordinate",
      "log_standard_deviation", "latent_trait_per_X_unit",
      "latent_trait_coordinate", "centered_log_slope",
      "latent_trait_transition", "positive_deviance",
      "mapped_common_coordinate", "positive_deviance",
      "positive_deviance"
    ),
    AbsoluteTolerance = c(rep(1e-5, 10L), 1e-7),
    SourceBasis = c(
      rep(
        paste0(
          "prospective_engineering_budget_from_parameter_convergence_1e-8_",
          "with_1000x_separation_no_candidate_output"
        ),
        8L
      ),
      "same_prospective_coordinate_budget_on_q61_to_q121",
      paste0(
        "preoutput_fixture_q61_q121_deviance_envelope_6.62e-6_",
        "rounded_outward"
      ),
      paste0(
        "preoutput_q121_continuous_deviance_envelope_1.43e-9_",
        "rounded_outward"
      )
    ),
    CandidateOutputInformed = FALSE,
    OpenedCalibrationTransferred = FALSE,
    Frozen = TRUE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p3m_budget <- function(budget_id) {
  budget <- mfrmr_cq_p3m_budget_registry()
  row <- budget[budget$BudgetId == budget_id, , drop = FALSE]
  mfrmr_cq_p3m_assert(
    nrow(row) == 1L && isTRUE(row$Frozen) &&
      !isTRUE(row$CandidateOutputInformed) &&
      !isTRUE(row$OpenedCalibrationTransferred) &&
      is.finite(row$AbsoluteTolerance) && row$AbsoluteTolerance > 0,
    "The requested P3 prospective numerical budget is invalid."
  )
  as.numeric(row$AbsoluteTolerance)
}

mfrmr_cq_p3m_probability_budget <- function(family) {
  mfrmr_cq_p3m_require_contracts()
  family <- toupper(as.character(family)[1L])
  mfrmr_cq_p3m_assert(
    family %in% c("PCM", "GPCM"), "`family` must be PCM or GPCM."
  )
  contract <- mfrmr_cq_p3_matrix_contract(family, 0L)
  coordinate_budget <- mfrmr_cq_p3m_budget(
    "P3-MAPPED-KERNEL-COORDINATE"
  )
  z_grid <- c(-3, -1, 0, 1, 3)
  item_rows <- split(seq_len(nrow(contract$A)), rep(1:4, each = 4L))
  pairwise_l1 <- vapply(z_grid, function(z) {
    max(vapply(item_rows, function(index) {
      pair <- utils::combn(index, 2L, simplify = FALSE)
      max(vapply(pair, function(rows) {
        a_span <- sum(abs(
          contract$A[rows[1L], ] - contract$A[rows[2L], ]
        ))
        c_span <- if (family == "GPCM") {
          abs(z) * sum(abs(
            contract$C[rows[1L], ] - contract$C[rows[2L], ]
          ))
        } else {
          0
        }
        a_span + c_span
      }, numeric(1L)))
    }, numeric(1L)))
  }, numeric(1L))
  maximum_l1 <- max(pairwise_l1)
  log_kernel_span <- maximum_l1 * coordinate_budget
  data.frame(
    Family = family,
    FreeMappedCoordinateAbsoluteBudget = coordinate_budget,
    StandardLatentGrid = paste(z_grid, collapse = ";"),
    MaximumPairwiseCoefficientL1 = maximum_l1,
    MaximumLogKernelDifferenceSpan = log_kernel_span,
    AbsoluteProbabilityTolerance = expm1(log_kernel_span),
    BoundType = "softmax_likelihood_ratio_conservative_upper_bound",
    ExpectedCells = 5L * 4L * 4L,
    CandidateOutputInformed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p3m_raw_token_state_registry <- function() {
  data.frame(
    TokenState = c(
      "raw_decimal", "raw_token_missing", "raw_token_unparsable",
      "raw_token_nonfinite", "display_reconstruction_only"
    ),
    IntervalAvailable = c(TRUE, rep(FALSE, 4L)),
    NumericComparisonConditionallyEligible = c(TRUE, rep(FALSE, 4L)),
    FailureOutcome = c(
      "none", "semantic_execution_failure", "implementation_defect",
      "implementation_defect", "reported_resolution_limited"
    ),
    RequiredAction = c(
      "use_value_plus_half_unit_last_place_interval",
      "retain_missing_output_and_stop_affected_arm",
      "repair_parser_or_export_before_numeric_comparison",
      "retain_nonfinite_token_and_diagnose_source",
      "recover_raw_export_token_or_retain_resolution_limited_state"
    ),
    HiddenDigitsImputed = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p3m_parse_raw_token <- function(token) {
  if (length(token) != 1L || is.null(token) ||
      (is.atomic(token) && is.na(token))) {
    return(data.frame(
      Token = NA_character_, State = "raw_token_missing", Value = NA_real_,
      HalfUnitLastPlace = NA_real_, DecimalPlaces = NA_integer_,
      Exponent = NA_integer_, stringsAsFactors = FALSE
    ))
  }
  if (!is.character(token)) {
    return(data.frame(
      Token = as.character(token)[1L], State = "display_reconstruction_only",
      Value = suppressWarnings(as.numeric(token)[1L]),
      HalfUnitLastPlace = NA_real_, DecimalPlaces = NA_integer_,
      Exponent = NA_integer_, stringsAsFactors = FALSE
    ))
  }
  value <- trimws(token)
  pattern <- paste0(
    "^[+-]?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)",
    "([eE][+-]?[0-9]+)?$"
  )
  if (!nzchar(value) || !grepl(pattern, value, perl = TRUE)) {
    return(data.frame(
      Token = value, State = "raw_token_unparsable", Value = NA_real_,
      HalfUnitLastPlace = NA_real_, DecimalPlaces = NA_integer_,
      Exponent = NA_integer_, stringsAsFactors = FALSE
    ))
  }
  numeric_value <- suppressWarnings(as.numeric(value))
  if (!is.finite(numeric_value)) {
    return(data.frame(
      Token = value, State = "raw_token_nonfinite", Value = numeric_value,
      HalfUnitLastPlace = NA_real_, DecimalPlaces = NA_integer_,
      Exponent = NA_integer_, stringsAsFactors = FALSE
    ))
  }
  mantissa <- sub("[eE].*$", "", value)
  exponent <- if (grepl("[eE]", value)) {
    as.integer(sub("^.*[eE]", "", value))
  } else {
    0L
  }
  decimal_places <- if (grepl("\\.", mantissa)) {
    nchar(sub("^.*\\.", "", mantissa))
  } else {
    0L
  }
  half_ulp <- 0.5 * 10^(exponent - decimal_places)
  data.frame(
    Token = value, State = "raw_decimal", Value = numeric_value,
    HalfUnitLastPlace = half_ulp,
    DecimalPlaces = as.integer(decimal_places), Exponent = exponent,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p3m_compare_raw_tokens <- function(left, right, tolerance) {
  tolerance <- as.numeric(tolerance)[1L]
  mfrmr_cq_p3m_assert(
    is.finite(tolerance) && tolerance > 0,
    "Raw-token comparison requires one positive finite tolerance."
  )
  parsed <- rbind(
    Left = mfrmr_cq_p3m_parse_raw_token(left),
    Right = mfrmr_cq_p3m_parse_raw_token(right)
  )
  if (!all(parsed$State == "raw_decimal")) {
    states <- mfrmr_cq_p3m_raw_token_state_registry()
    failure <- states$FailureOutcome[
      match(parsed$State[parsed$State != "raw_decimal"], states$TokenState)
    ]
    classification <- if ("implementation_defect" %in% failure) {
      "implementation_defect"
    } else if ("semantic_execution_failure" %in% failure) {
      "semantic_execution_failure"
    } else {
      "reported_resolution_limited"
    }
    return(list(
      Classification = classification, NumericPass = FALSE,
      Parsed = parsed, CenterDifference = NA_real_,
      MinimumPossibleAbsoluteDifference = NA_real_,
      MaximumPossibleAbsoluteDifference = NA_real_, Tolerance = tolerance,
      HiddenDigitsImputed = FALSE
    ))
  }
  center <- parsed$Value[1L] - parsed$Value[2L]
  radius <- sum(parsed$HalfUnitLastPlace)
  minimum <- max(0, abs(center) - radius)
  maximum <- abs(center) + radius
  classification <- if (maximum <= tolerance) {
    "eligible"
  } else if (minimum > tolerance) {
    "numerical_disagreement"
  } else {
    "reported_resolution_limited"
  }
  list(
    Classification = classification,
    NumericPass = identical(classification, "eligible"), Parsed = parsed,
    CenterDifference = center,
    MinimumPossibleAbsoluteDifference = minimum,
    MaximumPossibleAbsoluteDifference = maximum, Tolerance = tolerance,
    HiddenDigitsImputed = FALSE
  )
}

mfrmr_cq_p3m_integration_state_registry <- function() {
  data.frame(
    IntegrationState = c(
      "integration_eligible", "q31_q61_diagnostic_missing",
      "q61_q121_coordinate_unresolved", "q61_q121_deviance_unresolved",
      "q121_continuous_target_unresolved", "nonfinite_integration_value"
    ),
    CrossEngineNumericEligible = c(TRUE, rep(FALSE, 5L)),
    ObservedOutcome = c("eligible", rep("integration_unresolved", 5L)),
    PermittedNextAction = c(
      "evaluate_frozen_cross_engine_metrics",
      "recover_declared_q_snapshot_without_wider_design_expansion",
      "diagnose_prespecified_q_ladder_only",
      "diagnose_prespecified_q_ladder_only",
      "diagnose_quadrature_or_continuous_oracle_implementation",
      "retain_nonfinite_state_and_diagnose_integration"
    ),
    OptimizerDisagreementInferred = FALSE,
    CrossEngineDisagreementInferred = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p3m_classify_integration <- function(
    q31_q61_coordinate, q31_q61_deviance,
    q61_q121_coordinate, q61_q121_deviance,
    q121_continuous_deviance) {
  value <- c(
    q31_q61_coordinate, q31_q61_deviance,
    q61_q121_coordinate, q61_q121_deviance,
    q121_continuous_deviance
  )
  if (length(value) != 5L || anyNA(value)) {
    state <- "q31_q61_diagnostic_missing"
  } else if (any(!is.finite(value))) {
    state <- "nonfinite_integration_value"
  } else if (abs(q61_q121_coordinate) >
      mfrmr_cq_p3m_budget("P3-FINAL-Q-COORDINATE")) {
    state <- "q61_q121_coordinate_unresolved"
  } else if (abs(q61_q121_deviance) >
      mfrmr_cq_p3m_budget("P3-FINAL-Q-DEVIANCE")) {
    state <- "q61_q121_deviance_unresolved"
  } else if (abs(q121_continuous_deviance) >
      mfrmr_cq_p3m_budget("P3-Q121-CONTINUOUS-DEVIANCE")) {
    state <- "q121_continuous_target_unresolved"
  } else {
    state <- "integration_eligible"
  }
  registry <- mfrmr_cq_p3m_integration_state_registry()
  row <- registry[registry$IntegrationState == state, , drop = FALSE]
  list(
    State = state,
    ObservedOutcome = row$ObservedOutcome,
    CrossEngineNumericEligible = row$CrossEngineNumericEligible,
    Q31Q61DiagnosticThresholdApplied = FALSE,
    Q31Q61Coordinate = q31_q61_coordinate,
    Q31Q61Deviance = q31_q61_deviance,
    Q61Q121Coordinate = q61_q121_coordinate,
    Q61Q121Deviance = q61_q121_deviance,
    Q121ContinuousDeviance = q121_continuous_deviance
  )
}

mfrmr_cq_p3m_metric_rule_registry <- function() {
  pcm_probability <- mfrmr_cq_p3m_probability_budget("PCM")
  gpcm_probability <- mfrmr_cq_p3m_probability_budget("GPCM")
  rule_id <- c(
    "P3-XENG-MAPPED-KERNEL-COORDINATE",
    "P3-XENG-POPULATION-LOCATION",
    "P3-XENG-LOG-POPULATION-SCALE",
    "P3-XENG-REGRESSION",
    "P3-XENG-ITEM-LOCATION",
    "P3-XENG-LOG-RELATIVE-SLOPE",
    "P3-PCM-UNIT-SLOPE-STATE",
    "P3-XENG-TRANSITION-STEP",
    "P3-XENG-DEVIANCE",
    "P3-PCM-CONDITIONAL-PROBABILITY",
    "P3-GPCM-CONDITIONAL-PROBABILITY",
    "P3-CONQUEST-Q31-Q61-DIAGNOSTIC",
    "P3-MFRMR-Q31-Q61-DIAGNOSTIC",
    "P3-CONQUEST-Q61-Q121-COORDINATE",
    "P3-MFRMR-Q61-Q121-COORDINATE",
    "P3-CONQUEST-Q61-Q121-DEVIANCE",
    "P3-MFRMR-Q61-Q121-DEVIANCE",
    "P3-CONQUEST-Q121-CONTINUOUS-DEVIANCE",
    "P3-MFRMR-Q121-CONTINUOUS-DEVIANCE",
    "P3-RAW-TOKEN-RESOLUTION",
    "P3-SEMANTIC-IDENTITY-GATE",
    "P3-DECISION-CONSEQUENCE",
    "P3-NONOVERLAP-DISPOSITION"
  )
  absolute <- c(
    mfrmr_cq_p3m_budget("P3-MAPPED-KERNEL-COORDINATE"),
    mfrmr_cq_p3m_budget("P3-POPULATION-LOCATION"),
    mfrmr_cq_p3m_budget("P3-LOG-POPULATION-SCALE"),
    mfrmr_cq_p3m_budget("P3-REGRESSION"),
    mfrmr_cq_p3m_budget("P3-ITEM-LOCATION"),
    mfrmr_cq_p3m_budget("P3-LOG-RELATIVE-SLOPE"),
    NA_real_, mfrmr_cq_p3m_budget("P3-TRANSITION-STEP"),
    mfrmr_cq_p3m_budget("P3-CROSS-ENGINE-DEVIANCE"),
    pcm_probability$AbsoluteProbabilityTolerance,
    gpcm_probability$AbsoluteProbabilityTolerance,
    NA_real_, NA_real_,
    mfrmr_cq_p3m_budget("P3-FINAL-Q-COORDINATE"),
    mfrmr_cq_p3m_budget("P3-FINAL-Q-COORDINATE"),
    mfrmr_cq_p3m_budget("P3-FINAL-Q-DEVIANCE"),
    mfrmr_cq_p3m_budget("P3-FINAL-Q-DEVIANCE"),
    mfrmr_cq_p3m_budget("P3-Q121-CONTINUOUS-DEVIANCE"),
    mfrmr_cq_p3m_budget("P3-Q121-CONTINUOUS-DEVIANCE"),
    rep(NA_real_, 4L)
  )
  numeric_pass <- c(
    rep(TRUE, 6L), FALSE, rep(TRUE, 4L), FALSE, FALSE,
    rep(TRUE, 6L), rep(FALSE, 4L)
  )
  out <- data.frame(
    RuleId = rule_id,
    MetricClass = c(
      "mapped_kernel_coordinate", "population_location",
      "log_population_scale", "population_regression", "item_location",
      "log_relative_slope", "fixed_unit_slope_state", "transition_step",
      "matched_constant_deviance", rep("conditional_probability", 2L),
      rep("q31_q61_diagnostic", 2L), rep("q61_q121_coordinate", 2L),
      rep("q61_q121_deviance", 2L),
      rep("q121_continuous_deviance", 2L), "raw_token_precision",
      "semantic_identity", "decision_consequence", "nonoverlap_disposition"
    ),
    AppliesTo = c(
      rep("all_P3_numeric_rows", 3L), "P3_covariate_row",
      "all_P3_numeric_rows", "P3_GPCM_rows", "P3_PCM_row",
      rep("all_P3_numeric_rows", 2L), "P3_PCM_row", "P3_GPCM_rows",
      rep("all_P3_numeric_rows", 11L), "P3_nonoverlap_rows"
    ),
    Units = c(
      "mapped_common_coordinate", "latent_trait_coordinate",
      "log_standard_deviation", "latent_trait_per_X_unit",
      "latent_trait_coordinate", "centered_log_slope", "exact_fixed_state",
      "latent_trait_transition", "positive_deviance",
      "absolute_probability", "absolute_probability",
      "diagnostic_coordinate_and_deviance", "diagnostic_coordinate_and_deviance",
      "mapped_common_coordinate", "mapped_common_coordinate",
      rep("positive_deviance", 4L), "raw_decimal_interval", "typed_gate",
      "typed_decision", "typed_nonoverlap"
    ),
    DifferenceOrientation = c(
      rep("conquest_minus_mfrmr", 6L), "exact_fixed_state",
      rep("conquest_minus_mfrmr", 4L),
      "q061_minus_q031_record_only", "q061_minus_q031_record_only",
      rep("q121_minus_q061", 4L), rep("q121_minus_continuous", 2L),
      "interval_enclosure", "exact_semantic_gate", "exact_decision",
      "exact_documented_disposition"
    ),
    ComparisonTransform = c(
      "declared_P3_mapped_A_C_and_regression_orientation",
      "inverse_item_only_map_to_mfrmr_population_intercept",
      "log_of_inverse_mapped_population_standard_deviation",
      "inverse_map_beta_X_equals_sigma_times_beta_CQ",
      "inverse_map_to_all_four_sumzero_item_locations",
      "center_log_of_all_four_positive_item_slopes",
      "exact_all_four_item_slopes_equal_one",
      "inverse_map_to_all_twelve_sumzero_item_transition_steps",
      "positive_deviance_after_proving_declared_additive_constant",
      rep("softmax_on_standard_latent_grid_minus3_minus1_0_1_3", 2L),
      rep("maximum_common_coordinate_plus_deviance_snapshot", 2L),
      rep("maximum_absolute_common_coordinate_movement", 2L),
      rep("positive_deviance_movement", 2L),
      rep("q121_deviance_minus_independent_continuous_deviance", 2L),
      "decimal_value_plus_or_minus_half_unit_last_reported_place",
      "exact_C0_C1_signature_matrix_dimension_and_constraint_bundle",
      "exact_declared_support_decision",
      "exact_successor_registry_nonoverlap_disposition"
    ),
    AcceptanceMode = c(
      rep("symmetric_numeric_interval", 6L), "categorical_exact",
      "symmetric_numeric_interval", "symmetric_numeric_interval",
      rep("derived_probability_upper_bound", 2L),
      rep("diagnostic_required_no_magnitude_threshold", 2L),
      rep("symmetric_numeric_interval", 6L),
      "three_way_interval_classification", rep("categorical_exact", 3L)
    ),
    AbsoluteTolerance = absolute,
    SignedLower = ifelse(numeric_pass, -absolute, NA_real_),
    SignedUpper = ifelse(numeric_pass, absolute, NA_real_),
    RequiredOutcome = c(
      "every_free_mapped_A_C_or_regression_coordinate_present_and_within_budget",
      "recovered_population_location_present_and_within_budget",
      "recovered_log_population_scale_present_and_within_budget",
      "recovered_X_slope_present_and_within_budget",
      "all_four_sumzero_item_locations_present_and_within_budget",
      "all_four_centered_log_slopes_present_and_within_budget",
      "all_four_PCM_slopes_fixed_exactly_at_one",
      "all_twelve_sumzero_transition_steps_present_and_within_budget",
      "matched_constant_proven_and_q121_deviance_within_budget",
      "all_80_PCM_cells_present_normalized_and_within_derived_bound",
      "all_80_GPCM_cells_present_normalized_and_within_derived_bound",
      rep("complete_finite_q31_q61_snapshot_recorded_without_pass_threshold", 2L),
      rep("every_q61_q121_coordinate_present_and_within_budget", 2L),
      rep("q61_q121_deviance_present_and_within_budget", 2L),
      rep("q121_minus_continuous_deviance_present_and_within_budget", 2L),
      "every_required_native_token_classified_without_hidden_digits",
      "C0_C1_output_schema_category_matrix_dimension_and_constraint_gate_passed",
      "exact_retained_support_decision_agreement",
      "documented_nonoverlap_or_unsupported_without_numeric_substitution"
    ),
    FailureOutcome = c(
      rep("numerical_disagreement", 6L), "model_identity_mismatch",
      rep("numerical_disagreement", 4L), rep("integration_unresolved", 8L),
      "reported_resolution_limited", "model_identity_mismatch",
      "numerical_disagreement", "implementation_defect"
    ),
    FailureDetail = c(
      "mapped_kernel_coordinate_disagreement",
      "population_location_disagreement",
      "population_scale_disagreement", "population_regression_disagreement",
      "item_location_disagreement", "relative_slope_disagreement",
      "unit_slope_state_mismatch", "transition_step_disagreement",
      "matched_constant_or_deviance_disagreement",
      "PCM_probability_disagreement", "GPCM_probability_disagreement",
      rep("q31_q61_snapshot_missing_or_nonfinite", 2L),
      rep("q61_q121_coordinate_unresolved", 2L),
      rep("q61_q121_deviance_unresolved", 2L),
      rep("q121_continuous_target_unresolved", 2L),
      "raw_token_missing_invalid_or_resolution_limited",
      "semantic_identity_gate_failed", "decision_consequence_disagreement",
      "unexpected_numeric_nonoverlap_promotion"
    ),
    RawTokenRequirement = c(
      rep("raw_tokens_and_resolution_intervals_required", 6L),
      "typed_fixed_state_required",
      rep("raw_tokens_and_resolution_intervals_required", 4L),
      rep("all_q_snapshot_raw_tokens_required", 8L),
      "raw_tokens_required_no_display_reconstruction",
      "typed_source_evidence_required", "typed_source_decision_required",
      "typed_registry_disposition_required"
    ),
    NumericPassAuthorized = numeric_pass,
    RetainEveryAtomicOutcome = TRUE,
    CanPassOnCorrelation = FALSE,
    ThirdEngineRole = "optional_pairwise_separate_no_vote",
    CanUseTwoAgainstOneVote = FALSE,
    Frozen = TRUE,
    CanPromoteMfrmrReadiness = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  out
}

mfrmr_cq_p3m_rule_ids_for_row <- function(registry_row) {
  common <- c(
    "P3-XENG-MAPPED-KERNEL-COORDINATE",
    "P3-XENG-POPULATION-LOCATION",
    "P3-XENG-LOG-POPULATION-SCALE",
    "P3-XENG-ITEM-LOCATION",
    "P3-XENG-TRANSITION-STEP",
    "P3-XENG-DEVIANCE",
    if (registry_row$Family == "PCM") {
      "P3-PCM-CONDITIONAL-PROBABILITY"
    } else {
      "P3-GPCM-CONDITIONAL-PROBABILITY"
    },
    "P3-CONQUEST-Q31-Q61-DIAGNOSTIC",
    "P3-MFRMR-Q31-Q61-DIAGNOSTIC",
    "P3-CONQUEST-Q61-Q121-COORDINATE",
    "P3-MFRMR-Q61-Q121-COORDINATE",
    "P3-CONQUEST-Q61-Q121-DEVIANCE",
    "P3-MFRMR-Q61-Q121-DEVIANCE",
    "P3-CONQUEST-Q121-CONTINUOUS-DEVIANCE",
    "P3-MFRMR-Q121-CONTINUOUS-DEVIANCE",
    "P3-RAW-TOKEN-RESOLUTION",
    "P3-SEMANTIC-IDENTITY-GATE",
    "P3-DECISION-CONSEQUENCE"
  )
  slope <- if (registry_row$Family == "PCM") {
    "P3-PCM-UNIT-SLOPE-STATE"
  } else {
    "P3-XENG-LOG-RELATIVE-SLOPE"
  }
  regression <- if (registry_row$PopulationFormula == "~1+X") {
    "P3-XENG-REGRESSION"
  } else {
    character(0)
  }
  c(common[1:5], slope, regression, common[6:length(common)])
}

mfrmr_cq_p3m_atomic_count <- function(rule_id, registry_row) {
  dimension <- as.integer(registry_row$ExpectedFreeDimension)
  family <- registry_row$Family
  if (rule_id == "P3-XENG-MAPPED-KERNEL-COORDINATE") return(dimension)
  if (rule_id %in% c(
      "P3-XENG-POPULATION-LOCATION", "P3-XENG-LOG-POPULATION-SCALE",
      "P3-XENG-REGRESSION", "P3-XENG-DEVIANCE",
      "P3-CONQUEST-Q61-Q121-DEVIANCE", "P3-MFRMR-Q61-Q121-DEVIANCE",
      "P3-CONQUEST-Q121-CONTINUOUS-DEVIANCE",
      "P3-MFRMR-Q121-CONTINUOUS-DEVIANCE",
      "P3-SEMANTIC-IDENTITY-GATE", "P3-DECISION-CONSEQUENCE"
  )) return(1L)
  if (rule_id == "P3-XENG-ITEM-LOCATION") return(4L)
  if (rule_id %in% c(
      "P3-XENG-LOG-RELATIVE-SLOPE", "P3-PCM-UNIT-SLOPE-STATE"
  )) return(4L)
  if (rule_id == "P3-XENG-TRANSITION-STEP") return(12L)
  if (grepl("CONDITIONAL-PROBABILITY", rule_id, fixed = TRUE)) return(80L)
  if (rule_id %in% c(
      "P3-CONQUEST-Q31-Q61-DIAGNOSTIC",
      "P3-MFRMR-Q31-Q61-DIAGNOSTIC"
  )) return(dimension + 1L)
  if (rule_id %in% c(
      "P3-CONQUEST-Q61-Q121-COORDINATE",
      "P3-MFRMR-Q61-Q121-COORDINATE"
  )) return(dimension)
  if (rule_id == "P3-RAW-TOKEN-RESOLUTION") {
    return(2L * 3L * (dimension + 1L))
  }
  mfrmr_cq_p3m_assert(
    FALSE,
    paste0("Unknown P3 atomic-count rule for family ", family, ": ", rule_id)
  )
}

mfrmr_cq_p3m_denominator_registry <- function() {
  mfrmr_cq_p3m_require_contracts()
  registry <- mfrmr_cq_ssr_registry()
  numeric <- registry[
    registry$Priority == "P3" &
      registry$ExpectedDisposition == "prospective_numeric_comparison", ,
    drop = FALSE
  ]
  core <- do.call(rbind, lapply(seq_len(nrow(numeric)), function(index) {
    row <- numeric[index, , drop = FALSE]
    rule_id <- mfrmr_cq_p3m_rule_ids_for_row(row)
    data.frame(
      RegistryScope = row$RegistryRowId,
      Family = row$Family,
      RuleId = rule_id,
      ExpectedAtomicCount = vapply(
        rule_id, mfrmr_cq_p3m_atomic_count, integer(1L), registry_row = row
      ),
      ExpectedResultState = ifelse(
        grepl("Q31-Q61-DIAGNOSTIC", rule_id, fixed = TRUE),
        "diagnostic_required_no_magnitude_threshold",
        ifelse(
          rule_id == "P3-RAW-TOKEN-RESOLUTION",
          "eligible_or_reported_resolution_limited_or_typed_failure",
          "eligible_or_typed_failure"
        )
      ),
      stringsAsFactors = FALSE
    )
  }))
  excluded <- registry[
    registry$Priority == "P3" &
      registry$ExpectedDisposition ==
        "document_nonoverlap_no_numeric_comparison", ,
    drop = FALSE
  ]
  nonoverlap <- data.frame(
    RegistryScope = excluded$RegistryRowId,
    Family = excluded$Family,
    RuleId = "P3-NONOVERLAP-DISPOSITION",
    ExpectedAtomicCount = 1L,
    ExpectedResultState = "documented_nonoverlap_or_unsupported",
    stringsAsFactors = FALSE
  )
  out <- rbind(core, nonoverlap)
  out$MetricRowId <- paste(out$RegistryScope, out$RuleId, sep = "::")
  out$FailureDenominator <- ifelse(
    out$RuleId == "P3-NONOVERLAP-DISPOSITION",
    "P3_NONOVERLAP_DENOMINATOR", "P3_ITEM_ONLY_FULL_DENOMINATOR"
  )
  out$RetainFailedOrIneligible <- TRUE
  out$ExternalExecutionAuthorized <- FALSE
  out$ComparisonPassed <- FALSE
  out <- out[, c(
    "MetricRowId", "RegistryScope", "Family", "RuleId",
    "ExpectedAtomicCount", "ExpectedResultState", "FailureDenominator",
    "RetainFailedOrIneligible", "ExternalExecutionAuthorized",
    "ComparisonPassed"
  )]
  rownames(out) <- NULL
  out
}

mfrmr_cq_p3m_stop_rule_registry <- function() {
  mfrmr_cq_p3m_require_contracts()
  registry <- mfrmr_cq_ssr_registry()
  allowed <- unique(unlist(strsplit(
    registry$AllowedObservedOutcomes[registry$Priority == "P3"],
    ";", fixed = TRUE
  )))
  required_action <- c(
    eligible = "complete_all_frozen_metrics_then_independent_review",
    runtime_unavailable_or_expired =
      "replace_or_revalidate_runtime_without_reclassifying_prior_evidence",
    semantic_execution_failure =
      "diagnose_transcript_schema_and_terminal_semantics_before_rerun",
    model_identity_mismatch =
      "repair_C1_mapping_before_any_numeric_comparison",
    structurally_unidentified =
      "retain_structural_failure_without_numeric_substitution",
    external_nonconvergence =
      "diagnose_native_history_without_dropping_the_row",
    mfrmr_optimizer_or_readiness_review =
      "retain_mfrmr_review_state_external_agreement_cannot_promote",
    boundary_convention_mismatch =
      "type_boundary_state_and_compare_only_like_with_like",
    reported_resolution_limited =
      "recover_raw_tokens_or_retain_indeterminate_resolution_state",
    integration_unresolved =
      "use_only_q31_q61_q121_and_continuous_target_diagnostics",
    numerical_disagreement =
      "diagnose_transform_optimizer_precision_and_oracle_layers",
    implementation_defect =
      "stop_entire_slice_and_repair_before_new_execution",
    unknown = "classify_cause_before_metric_or_rerun_decision",
    documented_nonoverlap_or_unsupported =
      "retain_nonoverlap_without_numeric_comparison"
  )
  narrow <- c(
    eligible = "none_until_independent_review",
    runtime_unavailable_or_expired = "runtime_sentinel_only",
    semantic_execution_failure = "same_arm_semantic_diagnostic_only",
    model_identity_mismatch = "none",
    structurally_unidentified = "none",
    external_nonconvergence = "same_arm_optimizer_diagnostic_only",
    mfrmr_optimizer_or_readiness_review = "none",
    boundary_convention_mismatch = "same_quantity_layer_diagnostic_only",
    reported_resolution_limited = "precision_diagnostic_only",
    integration_unresolved = "prespecified_q_ladder_only",
    numerical_disagreement = "same_fixture_diagnostic_only",
    implementation_defect = "none",
    unknown = "classification_only",
    documented_nonoverlap_or_unsupported = "none"
  )
  invalidation <- c(
    eligible = "none", runtime_unavailable_or_expired = "current_runtime_slice",
    semantic_execution_failure = "affected_arm",
    model_identity_mismatch = "affected_row",
    structurally_unidentified = "affected_row",
    external_nonconvergence = "affected_row",
    mfrmr_optimizer_or_readiness_review = "affected_row",
    boundary_convention_mismatch = "affected_metric",
    reported_resolution_limited = "affected_metric",
    integration_unresolved = "affected_engine_row",
    numerical_disagreement = "affected_metric",
    implementation_defect = "entire_execution_slice",
    unknown = "affected_row",
    documented_nonoverlap_or_unsupported = "none"
  )
  data.frame(
    ObservedOutcome = allowed,
    NumericMetricsEligible = allowed == "eligible",
    RetainInCompleteDenominator = TRUE,
    RequiredNextAction = unname(required_action[allowed]),
    PermittedNarrowExpansion = unname(narrow[allowed]),
    WiderDesignExpansionAllowed = FALSE,
    InvalidationScope = unname(invalidation[allowed]),
    CanUseTwoAgainstOneVote = FALSE,
    CanPromoteMfrmrReadiness = FALSE,
    CanInferScientificEquivalence = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p3m_classify_numeric_gate <- function(
    semantic_identity_ready, optimizer_ready, raw_token_classification,
    integration_state, all_numeric_metrics_passed) {
  integration <- mfrmr_cq_p3m_integration_state_registry()
  raw_allowed <- c(
    "eligible", "reported_resolution_limited", "semantic_execution_failure",
    "implementation_defect", "numerical_disagreement"
  )
  mfrmr_cq_p3m_assert(
    length(raw_token_classification) == 1L &&
      length(integration_state) == 1L &&
      raw_token_classification %in% raw_allowed &&
      integration_state %in% integration$IntegrationState,
    "Numeric gate classification received an unknown precision or integration state."
  )
  if (!isTRUE(semantic_identity_ready)) return("model_identity_mismatch")
  if (!isTRUE(optimizer_ready)) return("mfrmr_optimizer_or_readiness_review")
  if (raw_token_classification %in% c(
      "reported_resolution_limited", "semantic_execution_failure",
      "implementation_defect"
  )) {
    return(raw_token_classification)
  }
  if (!identical(integration_state, "integration_eligible")) {
    return("integration_unresolved")
  }
  if (identical(raw_token_classification, "numerical_disagreement") ||
      !isTRUE(all_numeric_metrics_passed)) return("numerical_disagreement")
  "eligible"
}

mfrmr_cq_p3m_semantic_identical <- function(actual, canonical, id) {
  if (!is.data.frame(actual) || !all(names(canonical) %in% names(actual))) {
    return(FALSE)
  }
  x <- actual[, names(canonical), drop = FALSE]
  x <- x[order(as.character(x[[id]]), method = "radix"), , drop = FALSE]
  y <- canonical[order(
    as.character(canonical[[id]]), method = "radix"
  ), , drop = FALSE]
  rownames(x) <- NULL
  rownames(y) <- NULL
  identical(x, y)
}

mfrmr_cq_p3m_validate <- function(
    budgets = mfrmr_cq_p3m_budget_registry(),
    raw_states = mfrmr_cq_p3m_raw_token_state_registry(),
    integration_states = mfrmr_cq_p3m_integration_state_registry(),
    metric_rules = mfrmr_cq_p3m_metric_rule_registry(),
    denominator = mfrmr_cq_p3m_denominator_registry(),
    stop_rules = mfrmr_cq_p3m_stop_rule_registry()) {
  canonical_budget <- mfrmr_cq_p3m_budget_registry()
  canonical_raw <- mfrmr_cq_p3m_raw_token_state_registry()
  canonical_integration <- mfrmr_cq_p3m_integration_state_registry()
  canonical_metric <- mfrmr_cq_p3m_metric_rule_registry()
  canonical_denominator <- mfrmr_cq_p3m_denominator_registry()
  canonical_stop <- mfrmr_cq_p3m_stop_rule_registry()
  budget_ok <- mfrmr_cq_p3m_semantic_identical(
    budgets, canonical_budget, "BudgetId"
  ) && nrow(budgets) == 11L && all(budgets$Frozen) &&
    !any(budgets$CandidateOutputInformed) &&
    !any(budgets$OpenedCalibrationTransferred) &&
    !any(budgets$ScientificEquivalenceInferred)
  raw_ok <- mfrmr_cq_p3m_semantic_identical(
    raw_states, canonical_raw, "TokenState"
  ) && nrow(raw_states) == 5L && !any(raw_states$HiddenDigitsImputed) &&
    !any(raw_states$ScientificEquivalenceInferred)
  integration_ok <- mfrmr_cq_p3m_semantic_identical(
    integration_states, canonical_integration, "IntegrationState"
  ) && nrow(integration_states) == 6L &&
    !any(integration_states$OptimizerDisagreementInferred) &&
    !any(integration_states$CrossEngineDisagreementInferred) &&
    !any(integration_states$ScientificEquivalenceInferred)
  metric_ok <- mfrmr_cq_p3m_semantic_identical(
    metric_rules, canonical_metric, "RuleId"
  ) && nrow(metric_rules) == 23L && all(metric_rules$Frozen) &&
    all(metric_rules$RetainEveryAtomicOutcome) &&
    all(metric_rules$FailureOutcome %in% canonical_stop$ObservedOutcome) &&
    all(nzchar(metric_rules$FailureDetail)) &&
    !any(metric_rules$CanPassOnCorrelation) &&
    !any(metric_rules$CanUseTwoAgainstOneVote) &&
    !any(metric_rules$CanPromoteMfrmrReadiness) &&
    !any(metric_rules$ScientificEquivalenceInferred)
  denominator_ok <- mfrmr_cq_p3m_semantic_identical(
    denominator, canonical_denominator, "MetricRowId"
  ) && nrow(denominator) == 61L &&
    sum(denominator$ExpectedAtomicCount) == 861L &&
    all(denominator$RetainFailedOrIneligible) &&
    !any(denominator$ExternalExecutionAuthorized) &&
    !any(denominator$ComparisonPassed)
  stop_ok <- mfrmr_cq_p3m_semantic_identical(
    stop_rules, canonical_stop, "ObservedOutcome"
  ) && nrow(stop_rules) == 14L &&
    all(stop_rules$RetainInCompleteDenominator) &&
    !anyNA(stop_rules$RequiredNextAction) &&
    !anyNA(stop_rules$PermittedNarrowExpansion) &&
    !anyNA(stop_rules$InvalidationScope) &&
    !any(stop_rules$WiderDesignExpansionAllowed) &&
    !any(stop_rules$CanUseTwoAgainstOneVote) &&
    !any(stop_rules$CanPromoteMfrmrReadiness) &&
    !any(stop_rules$CanInferScientificEquivalence)
  all_ready <- budget_ok && raw_ok && integration_ok && metric_ok &&
    denominator_ok && stop_ok
  list(
    specification = mfrmr_cq_p3m_specification,
    contract_version = mfrmr_cq_p3m_contract,
    status = if (all_ready) {
      "P3_metric_precision_integration_and_denominator_contract_frozen_for_review"
    } else {
      "P3_metric_precision_or_denominator_contract_invalid"
    },
    budget_registry_ready = budget_ok,
    raw_token_registry_ready = raw_ok,
    integration_state_registry_ready = integration_ok,
    metric_rule_registry_ready = metric_ok,
    complete_denominator_ready = denominator_ok,
    stop_rule_registry_ready = stop_ok,
    all_contract_layers_ready = all_ready,
    independent_review_passed = FALSE,
    external_execution_authorized = FALSE,
    comparison_passed = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_p3m_review <- function() {
  mfrmr_cq_p3m_require_contracts()
  fixture <- mfrmr_cq_p3_review(run_continuous_oracles = FALSE)
  contract <- mfrmr_cq_p3m_validate()
  ready <- isTRUE(fixture$fixture_and_matrix_ready) &&
    isTRUE(fixture$finite_integration_ladder_ready) &&
    isTRUE(contract$all_contract_layers_ready)
  list(
    specification = mfrmr_cq_p3m_specification,
    contract_version = mfrmr_cq_p3m_contract,
    status = if (ready) {
      "P3_fixtures_metrics_precision_and_denominator_ready_for_independent_offline_review"
    } else {
      "P3_fixture_or_metric_precision_contract_invalid"
    },
    fixture_contract = fixture,
    contract_validation = contract,
    budgets = mfrmr_cq_p3m_budget_registry(),
    raw_token_states = mfrmr_cq_p3m_raw_token_state_registry(),
    integration_states = mfrmr_cq_p3m_integration_state_registry(),
    metric_rules = mfrmr_cq_p3m_metric_rule_registry(),
    denominator = mfrmr_cq_p3m_denominator_registry(),
    stop_rules = mfrmr_cq_p3m_stop_rule_registry(),
    metric_specific_rules_frozen = isTRUE(contract$metric_rule_registry_ready),
    raw_token_rules_frozen = isTRUE(contract$raw_token_registry_ready),
    integration_rules_frozen = isTRUE(
      contract$integration_state_registry_ready
    ),
    complete_denominator_frozen = isTRUE(
      contract$complete_denominator_ready
    ),
    stop_and_invalidation_rules_frozen = isTRUE(
      contract$stop_rule_registry_ready
    ),
    independent_review_passed = FALSE,
    external_execution_authorized = FALSE,
    comparison_passed = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
