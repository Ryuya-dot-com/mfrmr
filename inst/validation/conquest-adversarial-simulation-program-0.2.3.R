# Prospective architecture for the successor ConQuest adversarial simulation.
#
# Candidate 004 remains a bounded, retained fixed-artifact comparison. Its
# dormant independent-review handoff is not a prerequisite for designing or
# running a distinct population-level simulation. This file fixes the claim
# order, failure-mode coverage, denominator rules, and remaining design work.
# It does not generate data, fit either implementation, or launch ConQuest.

mfrmr_cq_asp_specification <-
  "0.2.3-conquest-adversarial-simulation-program-v1"
mfrmr_cq_asp_contract <-
  "mfrmr_conquest_adversarial_simulation_program_v1"

mfrmr_cq_asp_priority_registry <- function() {
  data.frame(
    WorkstreamId = c(
      "candidate_004_fixed_artifact_retention",
      "adversarial_simulation_architecture",
      "P2_RSM_PCM_transport_envelope",
      "P3_item_only_GPCM_transport_envelope",
      "many_facet_free_slope_GPCM",
      "public_general_software_equivalence"
    ),
    Sequence = c(0L, 1L, 2L, 3L, NA_integer_, NA_integer_),
    State = c(
      "retained_without_active_promotion_target",
      "selected_design_workstream",
      "first_execution_stratum_after_exact_design_freeze",
      "second_stratum_after_P2_classification",
      "excluded_pending_separate_model_identity_proof",
      "not_selected"
    ),
    CurrentWorkstreamSelected = c(FALSE, TRUE, rep(FALSE, 4L)),
    Candidate004IndependentReviewPrerequisite = FALSE,
    ExternalAuditRole = c(
      "optional_only_if_fixed_artifact_promotion_is_reopened",
      "optional_adversarial_design_challenge",
      "optional_final_evidence_audit",
      "optional_final_evidence_audit",
      "not_applicable_while_excluded",
      "not_applicable_without_a_selected_public_claim"
    ),
    ExecutionAuthorized = FALSE,
    PublicPromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asp_scenario_registry <- function() {
  data.frame(
    ScenarioClassId = c(
      "ASP-POS-COMPLETE",
      "ASP-POS-SPARSE-MULTIBRIDGE",
      "ASP-SENS-WEAK-SINGLE-BRIDGE",
      "ASP-SENS-UNEQUAL-WORKLOAD",
      "ASP-INV-PAIRED-MISSINGNESS",
      "ASP-SENS-RARE-BOUNDARY-CATEGORY",
      "ASP-SENS-EXTREME-PERSON",
      "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY",
      "ASP-NEG-DISCONNECTED-DESIGN"
    ),
    FamilyCoverage = "RSM;PCM",
    AnalysisRole = c(
      "positive_reference", "positive_transport",
      "sensitivity", "sensitivity", "representation_invariance",
      "sensitivity", "typed_boundary_sensitivity",
      "structural_negative_control", "structural_negative_control"
    ),
    FailureMechanism = c(
      "baseline_estimation_and_recovery",
      "connected_sparse_transport",
      "single_graph_bridge_weak_information",
      "rater_workload_imbalance",
      "absent_rows_versus_explicit_missing_values",
      "rare_minimum_and_maximum_categories",
      "minimum_or_maximum_observed_person_scores",
      "declared_but_globally_unused_intermediate_category",
      "disconnected_rater_assignment_graph"
    ),
    ExpectedStructuralDisposition = c(
      rep("eligible_numeric_comparison", 6L),
      "eligible_fit_with_typed_person_boundary",
      rep("reject_before_numeric_comparison", 2L)
    ),
    DeterministicTemplateState = c(
      "new_disjoint_template_required",
      rep("available_for_RSM_and_PCM", 3L),
      "PCM_extension_required",
      "RSM_extension_required",
      "PCM_extension_required",
      "cross_family_extension_required",
      "cross_family_extension_required"
    ),
    DisjointFromOpenedCandidateData = TRUE,
    IndependentDatasetIsSamplingUnit = TRUE,
    AllGeneratedDatasetsRetainedInDenominator = TRUE,
    PilotEligible = FALSE,
    ConfirmationEligible = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asp_metric_registry <- function() {
  data.frame(
    MetricId = c(
      "ASP-STRUCTURAL-DISPOSITION",
      "ASP-CONQUEST-EXECUTION",
      "ASP-MFRMR-EXECUTION",
      "ASP-JOINT-NUMERIC-ELIGIBILITY",
      "ASP-PROBABILITY-TRUTH-ERROR",
      "ASP-CONTINUOUS-TARGET-ORACLE-ERROR",
      "ASP-PARAMETER-BIAS",
      "ASP-PARAMETER-RMSE",
      "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE",
      "ASP-QUADRATURE-SENSITIVITY",
      "ASP-FALSE-READY-OR-FALSE-PASS",
      "ASP-UNCERTAINTY-COVERAGE"
    ),
    Perspective = c(
      "structural", "execution", "execution", "execution",
      "truth", "independent_oracle", "truth", "truth",
      "cross_engine", "numerical_stability", "decision_safety",
      "uncertainty"
    ),
    AnalysisState = c(rep("active_design", 11L),
                      "deferred_until_covariance_estimand_is_proven"),
    PrimaryDenominator = c(
      rep("all_generated_scenario_family_replicate_arms", 4L),
      rep("structurally_eligible_successful_fit_arms", 4L),
      "jointly_eligible_scenario_family_replicates",
      "successful_fit_arms_with_complete_q_ladder",
      "all_generated_scenario_family_replicate_arms",
      "not_applicable_until_activated"
    ),
    MandatoryUnconditionalCompanion = c(
      rep(FALSE, 4L), rep(TRUE, 6L), FALSE, TRUE
    ),
    PrecisionRuleState = c(
      "exact_expected_disposition",
      rep("pending_rate_decision_loss", 3L),
      rep("pending_continuous_MCSE_target", 6L),
      "pending_false_safety_rate_decision_loss",
      "not_applicable_until_activated"
    ),
    Candidate004ThresholdInherited = FALSE,
    FailureRowsDroppable = FALSE,
    PublicClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asp_design_field_registry <- function() {
  field <- c(
    "population_level_question",
    "independent_sampling_unit",
    "family_execution_order",
    "failure_mode_scenario_classes",
    "negative_control_policy",
    "calibration_confirmation_separation",
    "complete_denominator_policy",
    "candidate_004_review_dependency",
    "candidate_004_data_reuse",
    "uncertainty_coverage_activation",
    "exact_DGP_parameter_values",
    "neutral_generator_and_oracle_implementation",
    "non_evaluative_smoke_seed_band",
    "calibration_seed_band",
    "confirmation_seed_band",
    "metric_specific_precision_targets_and_replication_counts",
    "sequential_stop_expand_abort_and_runtime_cap"
  )
  state <- c(rep("frozen", 10L), rep("pending_before_generation", 7L))
  value <- c(
    paste(
      "Within a frozen RSM/PCM design population, estimate where mfrmr and",
      "ConQuest are each correct against truth and independent oracles, and",
      "where either fails or the pair disagrees."
    ),
    "one independently generated scenario-by-family dataset",
    "P2 RSM/PCM first; P3 item-only GPCM only after P2 classification",
    "nine registered positive, sensitivity, invariance, and negative classes",
    "expected rejection is evaluated before numerical agreement",
    "smoke, calibration, and untouched confirmation data are disjoint",
    "every generated dataset remains in an unconditional outcome ledger",
    "not_a_prerequisite_for_the_successor_simulation",
    "forbidden",
    "deferred_until_a_common_covariance_estimand_and_interval_rule_are_proven",
    rep(NA_character_, 7L)
  )
  data.frame(
    Field = field,
    State = state,
    Value = value,
    BlocksGenerationWhenPending = state == "pending_before_generation",
    CandidateOutputInformed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asp_gate_registry <- function() {
  data.frame(
    GateId = c(
      "ASP-G0-PRIORITY",
      "ASP-G1-TEMPLATE-COMPLETION",
      "ASP-G2-DGP-ORACLE-SEPARATION",
      "ASP-G3-NONEVALUATIVE-SMOKE",
      "ASP-G4-CALIBRATION-FREEZE",
      "ASP-G5-CALIBRATION-RUN",
      "ASP-G6-CONFIRMATION-FREEZE",
      "ASP-G7-CONFIRMATION-RUN",
      "ASP-G8-EVIDENCE-CLASSIFICATION"
    ),
    State = c("complete", rep("pending", 8L)),
    CurrentGate = c(FALSE, TRUE, rep(FALSE, 7L)),
    RequiredResult = c(
      "population_claim_selected_and_candidate_004_review_made_nonblocking",
      "all_cross_family_templates_and_negative_controls_validate",
      "generator_probability_oracle_and_fit_paths_are_semantically_separate",
      "one_disjoint_mechanics_dataset_per_scenario_family_has_complete_schema",
      "calibration_seeds_metrics_failure_taxonomy_and_cap_are_frozen",
      "calibration_is_classified_without_reuse_for_confirmation",
      "precision_targets_replication_counts_stop_rules_and_seeds_are_frozen",
      "all_confirmation_rows_are_retained_and_classified",
      "claim_is_narrowed_to_the_observed_design_and_failure_envelope"
    ),
    Candidate004IndependentReviewPrerequisite = FALSE,
    ExecutionAuthorizedByThisGateRecord = FALSE,
    PublicPromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asp_review <- function() {
  priority <- mfrmr_cq_asp_priority_registry()
  scenarios <- mfrmr_cq_asp_scenario_registry()
  metrics <- mfrmr_cq_asp_metric_registry()
  fields <- mfrmr_cq_asp_design_field_registry()
  gates <- mfrmr_cq_asp_gate_registry()
  selected <- priority[priority$CurrentWorkstreamSelected, , drop = FALSE]
  valid <-
    nrow(priority) == 6L && !anyDuplicated(priority$WorkstreamId) &&
    nrow(selected) == 1L &&
    identical(selected$WorkstreamId,
              "adversarial_simulation_architecture") &&
    nrow(scenarios) == 9L && !anyDuplicated(scenarios$ScenarioClassId) &&
    all(scenarios$AllGeneratedDatasetsRetainedInDenominator) &&
    !any(scenarios$PilotEligible) && !any(scenarios$ConfirmationEligible) &&
    nrow(metrics) == 12L && !anyDuplicated(metrics$MetricId) &&
    !any(metrics$Candidate004ThresholdInherited) &&
    !any(metrics$FailureRowsDroppable) &&
    nrow(fields) == 17L &&
    sum(fields$State == "pending_before_generation") == 7L &&
    all(fields$BlocksGenerationWhenPending ==
          (fields$State == "pending_before_generation")) &&
    nrow(gates) == 9L && sum(gates$CurrentGate) == 1L &&
    !any(gates$Candidate004IndependentReviewPrerequisite) &&
    !any(gates$ExecutionAuthorizedByThisGateRecord) &&
    !any(priority$ExecutionAuthorized) &&
    !any(priority$PublicPromotionAuthorized)
  list(
    specification = mfrmr_cq_asp_specification,
    contract_version = mfrmr_cq_asp_contract,
    status = if (valid) {
      "prospective_architecture_frozen_execution_closed"
    } else {
      "prospective_architecture_invalid"
    },
    priority = priority,
    scenarios = scenarios,
    metrics = metrics,
    design_fields = fields,
    gates = gates,
    candidate_004_historical_records_mutated = FALSE,
    candidate_004_handoff_cancelled = FALSE,
    candidate_004_active_promotion_target = FALSE,
    candidate_004_independent_review_blocks_program = FALSE,
    external_review_required_to_start_program = FALSE,
    optional_later_external_audit_retained = TRUE,
    population_simulation_claim_selected = TRUE,
    P2_RSM_PCM_first = TRUE,
    P3_item_only_GPCM_deferred_until_P2_classified = TRUE,
    many_facet_free_slope_GPCM_excluded = TRUE,
    exact_design_complete = FALSE,
    any_data_generation_authorized = FALSE,
    any_fit_authorized = FALSE,
    ConQuest_execution_authorized = FALSE,
    public_text_change_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
