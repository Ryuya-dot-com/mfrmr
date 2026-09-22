# Repository-only P2 metric, boundary, and complete-denominator contract.
#
# This contract is prospective and side-effect free. It reuses an existing
# exact-reported-decimal budget only where the estimand and precision stratum
# are unchanged, derives a conditional-probability transport bound from the
# independent P2 A matrix, and types nonnumeric outcomes explicitly. It does
# not launch ConQuest, inspect candidate output, or authorize execution.

mfrmr_cq_p2m_specification <-
  "0.2.3-conquest-p2-metric-boundary-contract-v1"
mfrmr_cq_p2m_contract <- "mfrmr_conquest_p2_metric_boundary_contract_v1"

mfrmr_cq_p2m_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2m_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2m_require_contracts)
  required <- c(
    "mfrmr_cq_ssr_registry",
    "mfrmr_cq_p2_fixture_registry",
    "mfrmr_cq_p2_matrix_contract",
    "mfrmr_cq_p2_review",
    "mfrmr_cq_ptf_budget_registry"
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
    exists("mfrmr_cq_p2_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"
      ),
    exists("mfrmr_cq_ptf_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_ptf_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_prospective_tolerance_table_v1"
      )
  )
  mfrmr_cq_p2m_assert(
    all(available) && all(identity),
    paste(
      "Source the exact successor registry, P2 fixture, and prospective",
      "tolerance-freeze identities before the P2 metric contract."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_p2m_reused_budget <- function(criterion_id, units) {
  mfrmr_cq_p2m_require_contracts()
  budget <- mfrmr_cq_ptf_budget_registry()
  row <- budget[
    budget$CriterionId == criterion_id & budget$Units == units, ,
    drop = FALSE
  ]
  mfrmr_cq_p2m_assert(
    nrow(row) == 1L && isTRUE(row$Frozen) &&
      !isTRUE(row$OpenedCalibrationEligible) &&
      is.finite(row$AbsoluteTolerance) && row$AbsoluteTolerance > 0,
    "The reused exact-reported-decimal budget is absent or ineligible."
  )
  as.numeric(row$AbsoluteTolerance)
}

mfrmr_cq_p2m_probability_budget <- function(model) {
  mfrmr_cq_p2m_require_contracts()
  model <- toupper(as.character(model)[1L])
  contract <- mfrmr_cq_p2_matrix_contract(model)
  coordinate_budget <- mfrmr_cq_p2m_reused_budget(
    "EXT-CQ-TOL", "common_model_coordinate"
  )
  group <- split(
    seq_len(nrow(contract$A)),
    paste(contract$C$Rater, contract$C$Criterion, sep = "::")
  )
  pairwise_l1 <- vapply(group, function(index) {
    pair <- utils::combn(index, 2L, simplify = FALSE)
    max(vapply(pair, function(rows) {
      sum(abs(contract$A[rows[1L], ] - contract$A[rows[2L], ]))
    }, numeric(1L)))
  }, numeric(1L))
  maximum_l1 <- max(pairwise_l1)
  log_kernel_span <- maximum_l1 * coordinate_budget
  data.frame(
    Model = model,
    FreeCoordinateAbsoluteBudget = coordinate_budget,
    MaximumPairwiseCoefficientL1 = maximum_l1,
    MaximumLogKernelDifferenceSpan = log_kernel_span,
    AbsoluteProbabilityTolerance = expm1(log_kernel_span),
    BoundType = "softmax_likelihood_ratio_conservative_upper_bound",
    ThetaGrid = "-2.25;-0.50;0;0.75;2.40",
    ExpectedCells = 5L * 4L * 3L * 4L,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2m_boundary_state_registry <- function() {
  data.frame(
    QuantityState = c(
      "nonextreme_raw_score",
      "minimum_raw_score",
      "maximum_raw_score",
      "finite_native_estimate",
      "unbounded_low",
      "unbounded_high",
      "unbounded_both",
      "finite_adjusted_display",
      "finite_posterior_summary",
      "not_estimated_or_missing",
      "not_applicable"
    ),
    QuantityLayer = c(
      rep("observed_score", 3L),
      "native_estimate", rep("native_estimate", 3L),
      "adjusted_display", "posterior", "any", "any"
    ),
    CoordinateMetricEligible = c(
      rep(FALSE, 3L), TRUE, rep(FALSE, 7L)
    ),
    PosteriorMetricConditionallyEligible = c(
      rep(FALSE, 8L), TRUE, FALSE, FALSE
    ),
    CategoricalStateComparable = c(
      rep(TRUE, 9L), FALSE, TRUE
    ),
    RequiredEvidence = c(
      "observed_score_strictly_between_declared_minimum_and_maximum",
      "observed_score_equals_declared_minimum_with_complete_row_count",
      "observed_score_equals_declared_maximum_with_complete_row_count",
      "same_estimand_coordinate_transform_and_raw_precision",
      "native_boundary_diagnostic_unbounded_toward_negative_infinity",
      "native_boundary_diagnostic_unbounded_toward_positive_infinity",
      "native_boundary_diagnostic_unbounded_in_both_directions",
      "display_rule_and_adjustment_label_not_native_estimate_label",
      paste0(
        "same_prior_population_response_set_weights_quadrature_or_common_",
        "continuous_reconstruction_and_summary_definition"
      ),
      "explicit_missing_or_failed_reason_retained_in_denominator",
      "quantity_role_declared_inapplicable_before_output"
    ),
    ResultIfPeerPrerequisiteFails = c(
      rep("raw_score_state_mismatch", 3L),
      "ineligible_estimand_or_precision_mismatch",
      "boundary_state_mismatch",
      "boundary_state_mismatch",
      "boundary_state_mismatch",
      "display_policy_mismatch_not_numerical_disagreement",
      "posterior_definition_mismatch",
      "missing_or_failed",
      "not_applicable"
    ),
    CrossLayerSubstitutionAllowed = FALSE,
    CanPromoteReadiness = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2m_metric_rule_registry <- function() {
  mfrmr_cq_p2m_require_contracts()
  cross_coordinate <- mfrmr_cq_p2m_reused_budget(
    "EXT-CQ-TOL", "common_model_coordinate"
  )
  cross_deviance <- mfrmr_cq_p2m_reused_budget(
    "EXT-CQ-TOL", "positive_deviance"
  )
  q_coordinate <- mfrmr_cq_p2m_reused_budget(
    "IC-INTEGRATION-TOL", "common_model_coordinate"
  )
  q_deviance <- mfrmr_cq_p2m_reused_budget(
    "IC-INTEGRATION-TOL", "positive_deviance"
  )
  rsm_probability <- mfrmr_cq_p2m_probability_budget("RSM")
  pcm_probability <- mfrmr_cq_p2m_probability_budget("PCM")
  out <- data.frame(
    RuleId = c(
      "P2-XENG-COORDINATE",
      "P2-XENG-DEVIANCE",
      "P2-CONQUEST-Q-MOVEMENT-COORDINATE",
      "P2-MFRMR-Q-MOVEMENT-COORDINATE",
      "P2-CONQUEST-Q-MOVEMENT-DEVIANCE",
      "P2-MFRMR-Q-MOVEMENT-DEVIANCE",
      "P2-RSM-CONDITIONAL-PROBABILITY",
      "P2-PCM-CONDITIONAL-PROBABILITY",
      "P2-PERSON-EAP",
      "P2-PERSON-POSTERIOR-SD",
      "P2-RATER-ORDERING",
      "P2-CRITERION-ORDERING",
      "P2-READINESS-STATE",
      "P2-DECISION-CONSEQUENCE",
      "P2-PAIRED-MISSINGNESS",
      "P2-EXTREME-QUANTITY-TYPING",
      "P2-NEG-UNUSED-CATEGORY",
      "P2-NEG-DISCONNECTED-DESIGN"
    ),
    MetricClass = c(
      "parameter_coordinate", "matched_constant_deviance",
      "within_engine_q_coordinate", "within_engine_q_coordinate",
      "within_engine_q_deviance", "within_engine_q_deviance",
      "conditional_probability", "conditional_probability",
      "person_eap", "person_posterior_sd", "rater_ordering",
      "criterion_ordering", "readiness_state", "decision_consequence",
      "missingness_representation", "boundary_quantity_inventory",
      "negative_control", "negative_control"
    ),
    AppliesTo = c(
      rep("all_P2_numeric_rows", 6L), "RSM_numeric_rows",
      "PCM_numeric_rows", rep("all_P2_numeric_rows", 6L),
      "paired_RSM_missingness_rows", "P2_RSM_extreme_person_row",
      "P2_unused_intermediate_category_control",
      "P2_disconnected_design_control"
    ),
    Units = c(
      "common_model_coordinate", "positive_deviance",
      "common_model_coordinate", "common_model_coordinate",
      "positive_deviance", "positive_deviance",
      "absolute_probability", "absolute_probability",
      "latent_trait_coordinate", "latent_trait_standard_deviation",
      "pair_classification", "pair_classification", "typed_state",
      "typed_decision", "semantic_response_row", "typed_quantity_record",
      "typed_rejection", "typed_rejection"
    ),
    DifferenceOrientation = c(
      "conquest_minus_mfrmr", "conquest_minus_mfrmr",
      "q061_minus_q031", "q061_minus_q031", "q061_minus_q031",
      "q061_minus_q031", "conquest_minus_mfrmr",
      "conquest_minus_mfrmr", "not_numerically_authorized",
      "not_numerically_authorized", "classification_comparison",
      "classification_comparison", "exact_state_comparison",
      "exact_decision_comparison", "explicit_minus_planned",
      "layer_by_layer_state_comparison", "observed_control_outcome",
      "observed_control_outcome"
    ),
    AcceptanceMode = c(
      rep("symmetric_numeric_interval", 6L),
      rep("derived_probability_upper_bound", 2L),
      rep("typed_ineligible_pending_identity_and_budget", 2L),
      rep("categorical_exact", 4L), "exact_semantic_equality",
      "complete_typed_inventory", rep("expected_rejection", 2L)
    ),
    AbsoluteTolerance = c(
      cross_coordinate, cross_deviance, q_coordinate, q_coordinate,
      q_deviance, q_deviance,
      rsm_probability$AbsoluteProbabilityTolerance,
      pcm_probability$AbsoluteProbabilityTolerance,
      rep(NA_real_, 10L)
    ),
    SignedLower = c(
      -cross_coordinate, -cross_deviance, -q_coordinate, -q_coordinate,
      -q_deviance, -q_deviance,
      -rsm_probability$AbsoluteProbabilityTolerance,
      -pcm_probability$AbsoluteProbabilityTolerance,
      rep(NA_real_, 10L)
    ),
    SignedUpper = c(
      cross_coordinate, cross_deviance, q_coordinate, q_coordinate,
      q_deviance, q_deviance,
      rsm_probability$AbsoluteProbabilityTolerance,
      pcm_probability$AbsoluteProbabilityTolerance,
      rep(NA_real_, 10L)
    ),
    TieBand = c(
      rep(NA_real_, 10L), 2 * cross_coordinate,
      2 * cross_coordinate, rep(NA_real_, 6L)
    ),
    RequiredOutcome = c(
      "every_coordinate_present_and_within_budget",
      "matched_constant_proven_and_deviance_within_budget",
      "every_coordinate_present_and_within_budget",
      "every_coordinate_present_and_within_budget",
      "matched_constant_proven_and_deviance_within_budget",
      "matched_constant_proven_and_deviance_within_budget",
      "all_240_prespecified_cells_present_normalized_and_within_bound",
      "all_240_prespecified_cells_present_normalized_and_within_bound",
      "typed_ineligible_until_posterior_contract_and_budget_are_frozen",
      "typed_ineligible_until_posterior_contract_and_budget_are_frozen",
      "all_six_pairs_share_tie_or_order_classification",
      "all_three_pairs_share_tie_or_order_classification",
      "exact_typed_state_agreement_no_external_promotion",
      "exact_retained_decision_agreement",
      "all_288_retained_rows_and_continuous_target_exactly_equal",
      "all_432_person_engine_layer_records_typed_without_substitution",
      "expected_typed_rejection_before_numeric_comparison",
      "expected_typed_rejection_before_numeric_comparison"
    ),
    FailureOutcome = c(
      "numerical_disagreement", "matched_constant_or_numerical_disagreement",
      "integration_unresolved", "integration_unresolved",
      "integration_unresolved", "integration_unresolved",
      "probability_disagreement", "probability_disagreement",
      "posterior_definition_or_budget_unresolved",
      "posterior_definition_or_budget_unresolved",
      "ordering_or_tie_disagreement", "ordering_or_tie_disagreement",
      "readiness_state_disagreement", "decision_consequence_disagreement",
      "missingness_semantics_disagreement", "boundary_convention_mismatch",
      "unexpected_control_acceptance", "unexpected_control_acceptance"
    ),
    SourceBasis = c(
      rep("reused_exact_reported_decimal_same_estimand_budget", 6L),
      rep("independent_A_pairwise_L1_softmax_transport_bound", 2L),
      rep("no_numeric_budget_until_posterior_identity_is_proven", 2L),
      rep("coordinate_budget_derived_two_estimate_tie_band", 2L),
      "readiness_contract_categorical_identity",
      "successor_registry_decision_identity", "P2_fixture_exact_pair_contract",
      "P2_boundary_state_registry", "P2_negative_control_contract",
      "P2_negative_control_contract"
    ),
    RawTokenRequirement = c(
      rep("raw_token_and_reported_resolution_required", 8L),
      rep("not_numeric_current_contract", 2L),
      rep("source_coordinates_and_classification_required", 2L),
      rep("typed_source_state_required", 6L)
    ),
    NumericPassAuthorized = c(
      rep(TRUE, 8L), rep(FALSE, 10L)
    ),
    Frozen = TRUE,
    CanPromoteMfrmrReadiness = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  out
}

mfrmr_cq_p2m_common_coordinate_count <- function(family) {
  family <- toupper(as.character(family)[1L])
  mfrmr_cq_p2m_assert(family %in% c("RSM", "PCM"),
                      "`family` must be RSM or PCM.")
  if (family == "RSM") 13L else 19L
}

mfrmr_cq_p2m_atomic_count <- function(rule_id, family) {
  coordinate_count <- mfrmr_cq_p2m_common_coordinate_count(family)
  if (rule_id %in% c(
      "P2-XENG-COORDINATE", "P2-CONQUEST-Q-MOVEMENT-COORDINATE",
      "P2-MFRMR-Q-MOVEMENT-COORDINATE")) return(coordinate_count)
  if (rule_id %in% c(
      "P2-XENG-DEVIANCE", "P2-CONQUEST-Q-MOVEMENT-DEVIANCE",
      "P2-MFRMR-Q-MOVEMENT-DEVIANCE", "P2-READINESS-STATE",
      "P2-DECISION-CONSEQUENCE")) return(1L)
  if (grepl("CONDITIONAL-PROBABILITY", rule_id, fixed = TRUE)) return(240L)
  if (rule_id %in% c("P2-PERSON-EAP", "P2-PERSON-POSTERIOR-SD")) {
    return(48L)
  }
  if (rule_id == "P2-RATER-ORDERING") return(6L)
  if (rule_id == "P2-CRITERION-ORDERING") return(3L)
  mfrmr_cq_p2m_assert(FALSE, paste0("Unknown core P2 rule: `", rule_id, "`."))
}

mfrmr_cq_p2m_denominator_registry <- function() {
  mfrmr_cq_p2m_require_contracts()
  registry <- mfrmr_cq_ssr_registry()
  p2 <- registry[
    registry$Priority == "P2" &
      registry$ComparisonStratum == "additive_rsm_pcm_mml", ,
    drop = FALSE
  ]
  numeric <- p2[
    p2$ExpectedDisposition == "prospective_numeric_comparison", ,
    drop = FALSE
  ]
  common_rules <- c(
    "P2-XENG-COORDINATE", "P2-XENG-DEVIANCE",
    "P2-CONQUEST-Q-MOVEMENT-COORDINATE",
    "P2-MFRMR-Q-MOVEMENT-COORDINATE",
    "P2-CONQUEST-Q-MOVEMENT-DEVIANCE",
    "P2-MFRMR-Q-MOVEMENT-DEVIANCE",
    "P2-PERSON-EAP", "P2-PERSON-POSTERIOR-SD",
    "P2-RATER-ORDERING", "P2-CRITERION-ORDERING",
    "P2-READINESS-STATE", "P2-DECISION-CONSEQUENCE"
  )
  core <- do.call(rbind, lapply(seq_len(nrow(numeric)), function(index) {
    row <- numeric[index, , drop = FALSE]
    probability_rule <- paste0(
      "P2-", row$Family, "-CONDITIONAL-PROBABILITY"
    )
    rule_id <- c(common_rules, probability_rule)
    data.frame(
      RegistryScope = row$RegistryRowId,
      Family = row$Family,
      RuleId = rule_id,
      ExpectedAtomicCount = vapply(
        rule_id, mfrmr_cq_p2m_atomic_count, integer(1L), family = row$Family
      ),
      ExpectedResultState = ifelse(
        rule_id %in% c("P2-PERSON-EAP", "P2-PERSON-POSTERIOR-SD"),
        "typed_ineligible_pending_posterior_identity",
        "eligible_or_typed_failure"
      ),
      stringsAsFactors = FALSE
    )
  }))
  paired <- data.frame(
    RegistryScope = paste(
      "P2-RSM-PLANNED-MISSING-ROWS",
      "P2-RSM-EXPLICIT-MISSING-VALUES", sep = ";"
    ),
    Family = "RSM",
    RuleId = "P2-PAIRED-MISSINGNESS",
    ExpectedAtomicCount = 288L,
    ExpectedResultState = "exact_semantic_equality_or_typed_failure",
    stringsAsFactors = FALSE
  )
  extreme <- data.frame(
    RegistryScope = "P2-RSM-EXTREME-PERSON",
    Family = "RSM",
    RuleId = "P2-EXTREME-QUANTITY-TYPING",
    ExpectedAtomicCount = 48L + 48L * 2L * 4L,
    ExpectedResultState = "complete_typed_inventory_or_boundary_mismatch",
    stringsAsFactors = FALSE
  )
  negative <- data.frame(
    RegistryScope = c(
      "P2-NEG-UNUSED-INTERMEDIATE-CATEGORY",
      "P2-NEG-DISCONNECTED-DESIGN"
    ),
    Family = c("PCM", "RSM"),
    RuleId = c(
      "P2-NEG-UNUSED-CATEGORY", "P2-NEG-DISCONNECTED-DESIGN"
    ),
    ExpectedAtomicCount = 1L,
    ExpectedResultState = "expected_typed_rejection",
    stringsAsFactors = FALSE
  )
  out <- rbind(core, paired, extreme, negative)
  out$MetricRowId <- paste(out$RegistryScope, out$RuleId, sep = "::")
  out$FailureDenominator <- "P2_ADDITIVE_FULL_DENOMINATOR"
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

mfrmr_cq_p2m_stop_rule_registry <- function() {
  outcome <- c(
    "eligible", "expected_typed_rejection",
    "runtime_unavailable_or_expired",
    "semantic_execution_failure", "model_identity_mismatch",
    "structurally_unidentified", "external_nonconvergence",
    "mfrmr_optimizer_or_readiness_review", "boundary_convention_mismatch",
    "reported_resolution_limited", "integration_unresolved",
    "numerical_disagreement", "implementation_defect", "unknown",
    "unexpected_control_acceptance"
  )
  data.frame(
    ObservedOutcome = outcome,
    NumericMetricsEligible = c(TRUE, rep(FALSE, 14L)),
    RetainInCompleteDenominator = TRUE,
    RequiredNextAction = c(
      "complete_all_frozen_metrics_then_independent_review",
      "record_control_rejection_and_continue_only_if_all_controls_reject",
      "replace_or_revalidate_runtime_without_reclassifying_prior_evidence",
      "diagnose_transcript_and_semantic_error_before_any_rerun",
      "repair_C1_contract_before_numeric_comparison",
      "record_structural_rejection_no_numeric_comparison",
      "diagnose_optimizer_and_history_without_dropping_row",
      "retain_mfrmr_review_state_external_agreement_cannot_promote",
      "type_each_layer_and_compare_only_like_with_like",
      "retain_resolution_limited_state_no_hidden_digits",
      "use_only_prespecified_q_ladder_then_refreeze_if_scope_changes",
      "diagnose_oracle_transform_optimizer_and_precision_layers",
      "stop_and_repair_implementation_before_any_new_execution",
      "classify_cause_before_any_metric_or_rerun_decision",
      "treat_runner_or_contract_as_defective_and_stop_slice"
    ),
    PermittedNarrowExpansion = c(
      "none_until_independent_review", "none", "runtime_sentinel_only",
      "same_arm_semantic_diagnostic_only", "none", "none",
      "same_arm_optimizer_diagnostic_only", "none", "none",
      "precision_diagnostic_only", "prespecified_q_ladder_only",
      "same_fixture_diagnostic_only", "none", "classification_only", "none"
    ),
    WiderDesignExpansionAllowed = FALSE,
    InvalidationScope = c(
      "none", "none", "current_runtime_slice", "affected_arm", "affected_row",
      "affected_row", "affected_row", "affected_row", "affected_metric",
      "affected_metric", "affected_engine_row", "affected_metric",
      "entire_execution_slice", "affected_row", "entire_execution_slice"
    ),
    CanPromoteMfrmrReadiness = FALSE,
    CanInferScientificEquivalence = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2m_semantic_identical <- function(actual, canonical, id) {
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

mfrmr_cq_p2m_validate <- function(
    boundary_states = mfrmr_cq_p2m_boundary_state_registry(),
    metric_rules = mfrmr_cq_p2m_metric_rule_registry(),
    denominator = mfrmr_cq_p2m_denominator_registry(),
    stop_rules = mfrmr_cq_p2m_stop_rule_registry()) {
  canonical_boundary <- mfrmr_cq_p2m_boundary_state_registry()
  canonical_metrics <- mfrmr_cq_p2m_metric_rule_registry()
  canonical_denominator <- mfrmr_cq_p2m_denominator_registry()
  canonical_stop <- mfrmr_cq_p2m_stop_rule_registry()
  boundary_ok <- mfrmr_cq_p2m_semantic_identical(
    boundary_states, canonical_boundary, "QuantityState"
  ) && nrow(boundary_states) == 11L &&
    !any(boundary_states$CrossLayerSubstitutionAllowed) &&
    !any(boundary_states$CanPromoteReadiness) &&
    !any(boundary_states$ScientificEquivalenceInferred)
  metric_ok <- mfrmr_cq_p2m_semantic_identical(
    metric_rules, canonical_metrics, "RuleId"
  ) && nrow(metric_rules) == 18L && all(metric_rules$Frozen) &&
    !any(metric_rules$CanPromoteMfrmrReadiness) &&
    !any(metric_rules$ScientificEquivalenceInferred)
  denominator_ok <- mfrmr_cq_p2m_semantic_identical(
    denominator, canonical_denominator, "MetricRowId"
  ) && nrow(denominator) == 147L &&
    sum(denominator$ExpectedAtomicCount) == 5073L &&
    all(denominator$RetainFailedOrIneligible) &&
    !any(denominator$ExternalExecutionAuthorized) &&
    !any(denominator$ComparisonPassed)
  stop_ok <- mfrmr_cq_p2m_semantic_identical(
    stop_rules, canonical_stop, "ObservedOutcome"
  ) && nrow(stop_rules) == 15L &&
    all(stop_rules$RetainInCompleteDenominator) &&
    !any(stop_rules$WiderDesignExpansionAllowed) &&
    !any(stop_rules$CanPromoteMfrmrReadiness) &&
    !any(stop_rules$CanInferScientificEquivalence)
  all_ready <- boundary_ok && metric_ok && denominator_ok && stop_ok
  list(
    specification = mfrmr_cq_p2m_specification,
    contract_version = mfrmr_cq_p2m_contract,
    status = if (all_ready) {
      "P2_metric_boundary_and_denominator_contract_frozen_for_review"
    } else {
      "P2_metric_boundary_or_denominator_contract_invalid"
    },
    boundary_state_registry_ready = boundary_ok,
    metric_rule_registry_ready = metric_ok,
    complete_denominator_ready = denominator_ok,
    stop_rule_registry_ready = stop_ok,
    all_contract_layers_ready = all_ready,
    external_execution_authorized = FALSE,
    comparison_passed = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_p2m_review <- function() {
  mfrmr_cq_p2m_require_contracts()
  fixture <- mfrmr_cq_p2_review(run_continuous_oracles = FALSE)
  contract <- mfrmr_cq_p2m_validate()
  ready <- isTRUE(fixture$fixture_contract_ready) &&
    isTRUE(contract$all_contract_layers_ready)
  list(
    specification = mfrmr_cq_p2m_specification,
    contract_version = mfrmr_cq_p2m_contract,
    status = if (ready) {
      "P2_fixtures_metrics_boundaries_ready_for_independent_offline_review"
    } else {
      "P2_fixture_or_metric_contract_invalid"
    },
    fixture_contract = fixture,
    contract_validation = contract,
    boundary_states = mfrmr_cq_p2m_boundary_state_registry(),
    metric_rules = mfrmr_cq_p2m_metric_rule_registry(),
    denominator = mfrmr_cq_p2m_denominator_registry(),
    stop_rules = mfrmr_cq_p2m_stop_rule_registry(),
    boundary_quantities_typed = isTRUE(
      contract$boundary_state_registry_ready
    ),
    metric_specific_rules_frozen = isTRUE(
      contract$metric_rule_registry_ready
    ),
    complete_denominator_frozen = isTRUE(
      contract$complete_denominator_ready
    ),
    stop_and_expansion_rules_frozen = isTRUE(
      contract$stop_rule_registry_ready
    ),
    independent_review_passed = FALSE,
    external_execution_authorized = FALSE,
    comparison_passed = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
