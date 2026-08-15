# Prospective independent-review handoff for ConQuest P2 candidate 004.
#
# This contract selects the bounded comparison claim and makes the independent
# review reproducible without reopening ConQuest. It contains no observed
# review result and cannot fit, read candidate artifacts, or promote evidence.

mfrmr_cq_p2c4irh_specification <-
  "0.2.3-conquest-p2-candidate-004-independent-review-handoff-v1"
mfrmr_cq_p2c4irh_contract <-
  "mfrmr_conquest_p2_candidate_004_independent_review_handoff_v1"
mfrmr_cq_p2c4irh_candidate_id <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004"

mfrmr_cq_p2c4irh_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4irh_evidence_registry <- function() {
  data.frame(
    EvidenceId = c(
      "raw_conquest_bundle", "raw_mfrmr_bundle", "frozen_numeric_contract",
      "reported_decimal_contract", "execution_observation",
      "same_author_numeric_observation", "rank_boundary_observation",
      "reviewer_adversarial_controls"
    ),
    RelativePath = c(
      "validation-results/conquest-p2-candidate-004-external-20260815-v1",
      "validation-results/conquest-p2-candidate-004-mfrmr-preflight-20260815-v1",
      "inst/validation/conquest-p2-candidate-004-numerical-review-contract-0.2.3.R",
      "inst/validation/conquest-reported-output-precision-contract-0.2.3.R",
      "inst/validation/conquest-p2-candidate-004-execution-observation-record-0.2.3.md",
      "inst/validation/conquest-p2-candidate-004-numerical-observation-record-0.2.3.md",
      "inst/validation/conquest-p2-candidate-004-rank-hold-observation-record-0.2.3.md",
      "inst/validation/conquest-p2-candidate-004-reviewer-adversarial-controls-record-0.2.3.md"
    ),
    StorageClass = c(
      "ignored_local_raw_artifacts", "ignored_local_raw_artifacts",
      rep("tracked_contract_or_record", 6L)
    ),
    ReviewRole = c(
      "primary_external_evidence", "primary_internal_evidence",
      "frozen_metric_rules_only", "frozen_reported_precision_rules_only",
      "execution_cross_check_only", "discrepancy_cross_check_only",
      "non_inference_ready_boundary", "reviewer_failure_mode_inventory"
    ),
    MaySupplyObservedNumericResult = c(
      TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    ),
    Required = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4irh_task_registry <- function() {
  data.frame(
    TaskId = c(
      "IR-01", "IR-02", "IR-03", "IR-04", "IR-05", "IR-06",
      "IR-07", "IR-08", "IR-09", "IR-10", "IR-11", "IR-12",
      "IR-13", "IR-14", "IR-15"
    ),
    Layer = c(
      "reviewer_independence", "artifact_boundary", "fixture_semantics",
      "command_semantics", "native_A_matrix", "execution_semantics",
      "raw_reported_tokens", "cross_engine_coordinates",
      "cross_engine_deviances", "quadrature_movement",
      "conditional_probabilities", "facet_ordering",
      "typed_ineligible_person_metrics", "readiness_and_nonclaims",
      "adversarial_controls"
    ),
    ExpectedAtomicCount = c(
      1L, 2L, 288L, 4L, 4L, 36L, 52L, 64L, 4L, 68L,
      480L, 18L, 192L, 4L, 7L
    ),
    RequiredAction = c(
      "attest no authorship or execution overlap and disclose conflicts",
      "open both retained roots read-only and stop if either is unavailable",
      "compare all long-format values semantically across the two roots",
      "derive and inspect all four model commands against the frozen design",
      "independently reconstruct all four family-and-node A matrices",
      "verify four terminal states and all thirty-two registered native outputs",
      "parse all fifty-two final parameter tokens as exact reported decimals",
      "reconstruct all sixty-four common coordinates and apply the frozen budget",
      "reconstruct four matched-constant positive deviances and apply the frozen budget",
      "recompute sixty-four coordinate and four deviance q61-to-q121 movements",
      "recompute the complete four-hundred-eighty-cell q121 probability grid",
      "recompute all eighteen frozen tie-band ordering classifications",
      "retain ninety-six EAP and ninety-six posterior-SD rows as typed ineligible",
      "retain two readiness holds and two nonpromotion decision rows",
      "exercise all seven semantic invariance or rejection classes independently"
    ),
    IndependentReconstructionRequired = c(
      TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE,
      TRUE, TRUE, FALSE, FALSE, TRUE
    ),
    RequiredForBoundedPass = TRUE,
    RerunConQuestAllowed = FALSE,
    DropFailedRowsAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4irh_nonclaim_registry <- function() {
  data.frame(
    NonclaimId = c(
      "hidden_solution_equality", "person_EAP_equivalence",
      "person_posterior_SD_equivalence", "mfrmr_inference_readiness",
      "global_marginal_identification", "continuous_integral_identification",
      "complete_P2_design_portfolio", "GPCM_or_DFF_coverage",
      "general_software_interchangeability", "public_release_claim"
    ),
    Authorized = FALSE,
    Reason = c(
      "ConQuest exposes rounded decimal tokens, not hidden optimizer intervals",
      "posterior identity and a comparison budget were not frozen",
      "posterior identity and a comparison budget were not frozen",
      "the retained mfrmr fits remain review with a design-rank hold",
      "the saved-fit local-rank result is not a global proof",
      "the fixed-quadrature local-rank result is not a continuous-integral proof",
      "candidate 004 contains only the paired RSM and PCM numerical core",
      "candidate 004 contains neither GPCM nor DFF evidence",
      "one bounded candidate cannot establish general interchangeability",
      "a passing review can only make bounded internal evidence eligible"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4irh_attestation_template <- function() {
  list(
    reviewer_id = NA_character_,
    review_date = NA_character_,
    conflicts_disclosed = NA,
    authored_candidate_004_pre_review_evidence = NA,
    participated_in_candidate_004_execution = NA,
    authored_same_author_numeric_review = NA,
    authored_this_handoff = NA,
    used_raw_artifacts_as_primary_evidence = NA,
    used_same_author_observation_as_calculation_source = NA,
    independent_implementation_description = NA_character_
  )
}

mfrmr_cq_p2c4irh_result_template <- function() {
  tasks <- mfrmr_cq_p2c4irh_task_registry()
  data.frame(
    TaskId = tasks$TaskId,
    State = "unreviewed",
    Note = "",
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4irh_independence_met <- function(attestation) {
  required <- names(mfrmr_cq_p2c4irh_attestation_template())
  if (!is.list(attestation) || !all(required %in% names(attestation))) {
    return(FALSE)
  }
  text_ready <-
    is.character(attestation$reviewer_id) &&
    length(attestation$reviewer_id) == 1L &&
    !is.na(attestation$reviewer_id) && nzchar(attestation$reviewer_id) &&
    is.character(attestation$review_date) &&
    length(attestation$review_date) == 1L &&
    !is.na(attestation$review_date) && nzchar(attestation$review_date) &&
    is.character(attestation$independent_implementation_description) &&
    length(attestation$independent_implementation_description) == 1L &&
    !is.na(attestation$independent_implementation_description) &&
    nzchar(attestation$independent_implementation_description)
  flags_ready <-
    isTRUE(attestation$conflicts_disclosed) &&
    identical(attestation$authored_candidate_004_pre_review_evidence, FALSE) &&
    identical(attestation$participated_in_candidate_004_execution, FALSE) &&
    identical(attestation$authored_same_author_numeric_review, FALSE) &&
    identical(attestation$authored_this_handoff, FALSE) &&
    isTRUE(attestation$used_raw_artifacts_as_primary_evidence) &&
    identical(
      attestation$used_same_author_observation_as_calculation_source, FALSE
    )
  isTRUE(text_ready && flags_ready)
}

mfrmr_cq_p2c4irh_adjudicate <- function(attestation, task_results) {
  tasks <- mfrmr_cq_p2c4irh_task_registry()
  mfrmr_cq_p2c4irh_assert(
    is.data.frame(task_results) &&
      all(c("TaskId", "State", "Note") %in% names(task_results)),
    "Review results must contain TaskId, State, and Note."
  )
  mfrmr_cq_p2c4irh_assert(
    nrow(task_results) == nrow(tasks) &&
      !anyDuplicated(task_results$TaskId) &&
      setequal(task_results$TaskId, tasks$TaskId),
    "Every independent-review task must appear exactly once."
  )
  task_results <- task_results[
    match(tasks$TaskId, task_results$TaskId), , drop = FALSE
  ]
  allowed <- c("pass", "fail", "blocked", "unreviewed")
  mfrmr_cq_p2c4irh_assert(
    all(task_results$State %in% allowed),
    "Review states must be pass, fail, blocked, or unreviewed."
  )
  independence <- mfrmr_cq_p2c4irh_independence_met(attestation)
  disposition <- if (!independence) {
    "independence_not_met"
  } else if (any(task_results$State == "fail")) {
    "bounded_review_failed"
  } else if (any(task_results$State %in% c("blocked", "unreviewed"))) {
    "bounded_review_incomplete"
  } else {
    "bounded_review_passed"
  }
  passed <- identical(disposition, "bounded_review_passed")
  list(
    specification = mfrmr_cq_p2c4irh_specification,
    contract_version = mfrmr_cq_p2c4irh_contract,
    candidate_id = mfrmr_cq_p2c4irh_candidate_id,
    disposition = disposition,
    reviewer_independence_met = independence,
    independent_bounded_review_passed = passed,
    bounded_internal_evidence_promotion_eligible = passed,
    candidate_rerun_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    mfrmr_inference_ready = FALSE,
    public_claim_authorized = FALSE,
    hidden_solution_equality_inferred = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_p2c4irh_plan <- function() {
  list(
    specification = mfrmr_cq_p2c4irh_specification,
    contract_version = mfrmr_cq_p2c4irh_contract,
    candidate_id = mfrmr_cq_p2c4irh_candidate_id,
    status = "candidate_004_bounded_review_handoff_frozen_unreviewed",
    selected_claim = paste(
      "bounded exact-reported-decimal ConQuest comparison for the candidate-004",
      "RSM/PCM q61/q121 numerical core"
    ),
    evidence = mfrmr_cq_p2c4irh_evidence_registry(),
    tasks = mfrmr_cq_p2c4irh_task_registry(),
    nonclaims = mfrmr_cq_p2c4irh_nonclaim_registry(),
    result_template = mfrmr_cq_p2c4irh_result_template(),
    independent_bounded_review_passed = FALSE,
    bounded_internal_evidence_promotion_eligible = FALSE,
    candidate_rerun_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
