# Claim-specific P4 replication-necessity decision for ConQuest evidence.
#
# The selected candidate-004 claim is a fixed-artifact technical comparison.
# Replication cannot change that claim. Independent human review is optional
# assurance rather than a 0.2.3 release or promotion requirement. Broader
# frequency, recovery, coverage, and portability claims are not silently
# imported into the current scope.

mfrmr_cq_p4rnd_specification <-
  "0.2.3-conquest-p4-replication-necessity-decision-v1"
mfrmr_cq_p4rnd_contract <-
  "mfrmr_conquest_p4_replication_necessity_decision_v1"

mfrmr_cq_p4rnd_claim_registry <- function() {
  data.frame(
    ClaimId = c(
      "candidate_004_fixed_artifact_bounded_comparison",
      "six_arm_candidate_003_historical_retention",
      "full_P2_design_portfolio",
      "P3_item_only_GPCM",
      "cross_dataset_disagreement_rate",
      "recovery_bias_or_RMSE",
      "uncertainty_coverage",
      "cross_runtime_or_platform_portability"
    ),
    CurrentClaimSelected = c(TRUE, FALSE, rep(FALSE, 6L)),
    DeterministicGateComplete = c(TRUE, TRUE, FALSE, FALSE, rep(FALSE, 4L)),
    Disposition = c(
      "replication_not_needed",
      "replication_not_needed_for_historical_retention",
      "deterministic_gate_first", "deterministic_gate_first",
      rep("claim_not_selected", 4L)
    ),
    Reason = c(
      "The claim concerns one fixed candidate and retained raw outputs; another sampled data set would answer a different claim.",
      "The versioned same-platform result is retained without a current promotion target.",
      "The frozen wider denominator has not been deterministically executed or classified.",
      "No external P3 candidate is authorized and C0-C5 are incomplete.",
      "No population of data sets, target rate, or precision decision is claimed.",
      "No recovery estimand, generating distribution, or precision target is claimed.",
      "No interval procedure or coverage precision target is claimed.",
      "Only ConQuest 5.47.5 Demo on x86_64/Rosetta was observed."
    ),
    ReplicationAuthorized = FALSE,
    IndependentReviewSubstitutedByReplication = FALSE,
    PublicPromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p4rnd_conditional_design_state <- function() {
  data.frame(
    Field = c(
      "independent_sampling_unit", "target_failure_or_disagreement_rate",
      "confidence_or_MCSE_precision", "metric_specific_replication_count",
      "sequential_stop_expand_abort_rule", "failed_ineligible_fit_handling",
      "maximum_claim_after_pass"
    ),
    State = "not_applicable_replication_not_needed_for_selected_claim",
    Value = NA_character_,
    ProspectiveFreezeRequiredIfFutureClaimSelected = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p4rnd_review <- function() {
  claims <- mfrmr_cq_p4rnd_claim_registry()
  conditional <- mfrmr_cq_p4rnd_conditional_design_state()
  selected <- claims[claims$CurrentClaimSelected, , drop = FALSE]
  valid <-
    nrow(claims) == 8L && !anyDuplicated(claims$ClaimId) &&
    nrow(selected) == 1L &&
    identical(selected$Disposition, "replication_not_needed") &&
    isTRUE(selected$DeterministicGateComplete) &&
    !any(claims$ReplicationAuthorized) &&
    !any(claims$IndependentReviewSubstitutedByReplication) &&
    !any(claims$PublicPromotionAuthorized) &&
    nrow(conditional) == 7L && all(is.na(conditional$Value)) &&
    all(conditional$ProspectiveFreezeRequiredIfFutureClaimSelected)
  list(
    specification = mfrmr_cq_p4rnd_specification,
    contract_version = mfrmr_cq_p4rnd_contract,
    status = if (valid) {
      "P4_closed_replication_not_needed_for_selected_bounded_claim"
    } else {
      "P4_replication_necessity_decision_invalid"
    },
    claims = claims,
    conditional_design = conditional,
    selected_claim = selected$ClaimId,
    selected_claim_replication_needed = FALSE,
    independent_review_still_required = FALSE,
    independent_review_required_before_public_promotion = FALSE,
    independent_review_blocks_0_2_3_release = FALSE,
    independent_review_optional_quality_enhancement = TRUE,
    independent_review_is_sampling_replication = FALSE,
    new_data_generated = FALSE,
    new_fit_attempted = FALSE,
    ConQuest_execution_attempted = FALSE,
    large_simulation_authorized = FALSE,
    candidate_004_rerun_authorized = FALSE,
    wider_P2_authorized = FALSE,
    P3_authorized = FALSE,
    release_spine_update_authorized = FALSE,
    public_text_change_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
