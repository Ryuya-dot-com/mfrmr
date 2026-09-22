# mfrmr 0.2.3 repository-only ConQuest tolerance adjudication
#
# This helper consumes an opened four-arm calibration review. It separates
# representation, optimizer, integration, scientific-acceptance, and candidate
# gates. Calibration may inform a prospective rule for a disjoint candidate,
# but it cannot manufacture a threshold and then pass itself under that rule.

mfrmr_cq_tolerance_adjudication_specification <-
  "0.2.3-wave-c-tolerance-adjudication-v1"
mfrmr_cq_tolerance_adjudication_contract <-
  "mfrmr_conquest_tolerance_adjudication_v1"

mfrmr_cq_tolerance_adjudication_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_tolerance_gate_requirements <- function() {
  data.frame(
    Layer = c(
      "representation", "representation", "optimizer", "optimizer",
      "integration", "integration", "scientific_acceptance",
      "scientific_acceptance", "candidate_binding", "candidate_binding"
    ),
    RequirementId = sprintf("EXT-CQ-GATE-%02d", seq_len(10L)),
    Requirement = c(
      "Retain native numeric tokens and complete-file hashes before conversion.",
      "Establish any rounding rule independently; written decimal places alone are descriptive.",
      "Fix convergence, deviance-change, and iteration-limit controls before execution.",
      "Retain the full transcript, stopping evidence, final history row, and native exports.",
      "Use a prespecified q31/q61 ladder and keep low-node exploratory arms outside confirmation.",
      "Freeze IC-INTEGRATION-TOL independently of the confirmatory candidate result.",
      "Freeze signed and absolute EXT-CQ-TOL values by common estimand before confirmation.",
      "Keep token equality, tolerance passage, and scientific equivalence as separate decisions.",
      "Bind package source, executable, commands, inputs, and expected empty outputs to one candidate manifest.",
      "Run the six Binary/RSM/PCM by q31/q61 arms freshly before any sparse or large-simulation extension."
    ),
    RequiredForEquivalence = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_adjudicate_conquest_additive_tolerance <- function(four_arm_review) {
  required <- c(
    "decision", "four_arms_complete", "complete_console_transcripts",
    "native_design_matrices_exact",
    "q31_q61_printed_final_coordinates_identical", "raw_token_status",
    "acceptance_threshold_specified", "candidate_bound",
    "comparison_ready", "scientific_equivalence_inferred",
    "confirmation_authorized"
  )
  mfrmr_cq_tolerance_adjudication_assert(
    is.list(four_arm_review) && all(required %in% names(four_arm_review)),
    "`four_arm_review` does not satisfy the opened four-arm review contract."
  )
  mfrmr_cq_tolerance_adjudication_assert(
    identical(
      four_arm_review$decision,
      "four_arm_native_outputs_ready_tolerance_and_candidate_missing"
    ) && isTRUE(four_arm_review$four_arms_complete) &&
      isTRUE(four_arm_review$complete_console_transcripts) &&
      isTRUE(four_arm_review$native_design_matrices_exact) &&
      isTRUE(four_arm_review$q31_q61_printed_final_coordinates_identical),
    "The four-arm calibration is incomplete or has changed state."
  )
  mfrmr_cq_tolerance_adjudication_assert(
    identical(
      four_arm_review$raw_token_status,
      "raw_tokens_retained_rounding_unestablished"
    ) && !isTRUE(four_arm_review$acceptance_threshold_specified) &&
      !isTRUE(four_arm_review$candidate_bound) &&
      !isTRUE(four_arm_review$comparison_ready) &&
      !isTRUE(four_arm_review$scientific_equivalence_inferred) &&
      !isTRUE(four_arm_review$confirmation_authorized),
    "The opened calibration must retain its unknown-rounding, no-threshold, and no-candidate state."
  )

  layer_review <- data.frame(
    Layer = c(
      "representation", "optimizer", "integration",
      "scientific_acceptance", "candidate_binding"
    ),
    CalibrationEvidence = c(
      "raw_tokens_and_sha256_retained_rounding_unknown",
      "strict_controls_complete_transcripts_and_native_exports_retained",
      "q31_q61_coordinates_identical_at_retained_tokens",
      "displayed_differences_observed_without_threshold",
      "no_exact_release_candidate_manifest"
    ),
    CalibrationStatus = c(
      "review", "calibration_complete", "calibration_stable",
      "not_adjudicated", "missing"
    ),
    ReleaseGatePassed = FALSE,
    Reason = c(
      "The manual does not define CSV significant digits or rounding mode.",
      "Calibration completion does not establish candidate convergence.",
      "Token stability is not a frozen integration tolerance.",
      "Calibration may inform a future rule, but cannot pass itself under a newly selected EXT-CQ-TOL.",
      "No source/output identity is bound to a release candidate."
    ),
    stringsAsFactors = FALSE
  )

  out <- list(
    specification = mfrmr_cq_tolerance_adjudication_specification,
    contract_version = mfrmr_cq_tolerance_adjudication_contract,
    decision = "hold_no_post_hoc_tolerance_freeze",
    status = "review",
    calibration_results_opened = TRUE,
    official_file_rounding_rule_established = FALSE,
    lexical_unit_is_uncertainty_interval = FALSE,
    internal_handoff_tolerance_is_export_resolution = FALSE,
    internal_handoff_tolerance_is_ext_cq_tol = FALSE,
    q31_q61_token_identity_is_scientific_equivalence = FALSE,
    calibration_may_inform_future_tolerance = TRUE,
    calibration_may_pass_its_own_new_tolerance = FALSE,
    package_manual_cross_engine_tolerance_found = FALSE,
    tolerance_source_audit_id =
      "conquest-tam-immer-tolerance-source-audit-20260811-v1",
    ext_cq_tolerance_frozen = FALSE,
    ic_integration_tolerance_frozen = FALSE,
    broad_external_claim_retained_as_future_gate = TRUE,
    current_public_claim = "descriptive_calibration_only",
    candidate_run_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    large_simulation_authorized = FALSE,
    next_action = paste(
      "obtain an independently justified pre-result EXT-CQ-TOL and",
      "IC-INTEGRATION-TOL record, complete the Binary normalizer, bind",
      "the exact candidate, then run all six family-by-node arms freshly"
    ),
    layer_review = layer_review,
    gate_requirements = mfrmr_cq_tolerance_gate_requirements()
  )
  class(out) <- c(
    "mfrmr_conquest_tolerance_adjudication", class(out)
  )
  out
}
