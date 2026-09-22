# Repository-only observation of the candidate-004 ConQuest execution.
#
# This file retains the four-arm semantic execution outcome without reading the
# ignored output bundle, launching ConQuest, parsing numerical estimates, or
# deciding numerical agreement. The run-once candidate is consumed regardless
# of the later numerical-review result.

mfrmr_cq_p2c4eo_specification <-
  "0.2.3-conquest-p2-candidate-004-execution-observation-v1"
mfrmr_cq_p2c4eo_contract <-
  "mfrmr_conquest_p2_candidate_004_execution_observation_v1"

mfrmr_cq_p2c4eo_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4eo_require_harness <- function() {
  target <- environment(mfrmr_cq_p2c4eo_require_harness)
  ready <- exists(
    "mfrmr_cq_p2c4h_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2c4h_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_candidate_004_harness_v1"
  ) && exists(
    "mfrmr_cq_p2c4h_plan", envir = target, mode = "function",
    inherits = TRUE
  )
  mfrmr_cq_p2c4eo_assert(
    ready, "Source the exact candidate-004 harness before its observation."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4eo_execution_observation <- function() {
  data.frame(
    ExecutionOrder = 1:4,
    RunId = c("rsm_q061", "rsm_q121", "pcm_q061", "pcm_q121"),
    Family = c("RSM", "RSM", "PCM", "PCM"),
    Nodes = c(61L, 121L, 61L, 121L),
    ExpectedFreeDimension = c(10L, 10L, 14L, 14L),
    ConQuestAttemptCount = 1L,
    ConQuestExitStatus = 0L,
    ConQuestTerminalMarkerObserved = TRUE,
    ConQuestRegisteredFailureCount = 0L,
    ExpectedNativeOutputCount = 8L,
    ConQuestNativeOutputCount = 8L,
    ConQuestStatus = "semantic_success_complete_native_output_set",
    NumericAgreementReviewed = FALSE,
    IndependentComprehensiveReviewPassed = FALSE,
    EvidencePromotionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4eo_review <- function() {
  mfrmr_cq_p2c4eo_require_harness()
  plan <- mfrmr_cq_p2c4h_plan()
  observed <- mfrmr_cq_p2c4eo_execution_observation()
  identity <- nrow(plan) == 4L && nrow(observed) == 4L &&
    identical(observed$ExecutionOrder, plan$ExecutionOrder) &&
    identical(observed$RunId, plan$RunId) &&
    identical(observed$Family, plan$Family) &&
    identical(observed$Nodes, plan$Nodes) &&
    identical(
      observed$ExpectedFreeDimension, plan$ExpectedFreeDimension
    ) &&
    identical(
      observed$ExpectedNativeOutputCount,
      plan$ExpectedNativeOutputCount
    )
  semantic_complete <- identity &&
    all(observed$ConQuestAttemptCount == 1L) &&
    all(observed$ConQuestExitStatus == 0L) &&
    all(observed$ConQuestTerminalMarkerObserved) &&
    all(observed$ConQuestRegisteredFailureCount == 0L) &&
    identical(
      observed$ConQuestNativeOutputCount,
      observed$ExpectedNativeOutputCount
    ) &&
    all(
      observed$ConQuestStatus ==
        "semantic_success_complete_native_output_set"
    )
  list(
    specification = mfrmr_cq_p2c4eo_specification,
    contract_version = mfrmr_cq_p2c4eo_contract,
    status = if (semantic_complete) {
      "candidate_004_four_arm_execution_complete_numerical_review_pending"
    } else {
      "candidate_004_execution_observation_invalid_or_incomplete"
    },
    execution_observation = observed,
    exact_four_arm_identity = identity,
    all_four_attempted = all(observed$ConQuestAttemptCount == 1L),
    all_four_semantically_complete = semantic_complete,
    complete_native_output_count = sum(observed$ConQuestNativeOutputCount),
    candidate_run_once_consumed = semantic_complete,
    rerun_authorized = FALSE,
    same_author_technical_review_authorized = semantic_complete,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
