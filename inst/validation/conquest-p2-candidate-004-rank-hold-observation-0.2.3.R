# Repository-only observation of candidate 004's saved-fit rank layers.
#
# This retains the completed read-only review without loading fit artifacts or
# recomputing ranks. Local full rank is recorded without clearing global MML,
# continuous-integral, weak-information, or fit-readiness holds.

mfrmr_cq_p2c4rho_specification <-
  "0.2.3-conquest-p2-candidate-004-rank-hold-observation-v1"
mfrmr_cq_p2c4rho_contract <-
  "mfrmr_conquest_p2_candidate_004_rank_hold_observation_v1"

mfrmr_cq_p2c4rho_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4rho_require_contract <- function() {
  target <- environment(mfrmr_cq_p2c4rho_require_contract)
  ready <- exists(
    "mfrmr_cq_p2c4rh_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2c4rh_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_candidate_004_rank_hold_contract_v1"
  )
  mfrmr_cq_p2c4rho_assert(
    ready, "Source the exact candidate-004 rank-hold contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4rho_arm_observation <- function() {
  data.frame(
    RunId = c("rsm_q061", "rsm_q121", "pcm_q061", "pcm_q121"),
    Family = c("RSM", "RSM", "PCM", "PCM"),
    Nodes = c(61L, 121L, 61L, 121L),
    AdditiveRank = c(9L, 9L, 13L, 13L),
    AdditiveDimension = c(9L, 9L, 13L, 13L),
    AdditiveNullity = 0L,
    AdditiveToleranceSensitive = FALSE,
    AdditiveSmallestSingularValue = 0.5134034,
    AdditiveConditionIndex = 3.059771,
    ObservedPatternScoreRank = c(10L, 10L, 14L, 14L),
    FullFreeDimension = c(10L, 10L, 14L, 14L),
    ObservedPatternScoreNullity = 0L,
    ObservedPatternToleranceSensitive = FALSE,
    NonlinearBlock = "log_sigma2",
    LocalState = "locally_full_rank_sufficient",
    GlobalIdentificationClassified = FALSE,
    ContinuousIntegralIdentificationClassified = FALSE,
    WeakInformationClassified = FALSE,
    PropagatedEstimabilityState = "not_evaluated",
    PropagatedFitReadiness = "review",
    PropagatedInferenceReady = FALSE,
    AdditiveLayerPass = TRUE,
    TransformationLayerPass = TRUE,
    ObservedPatternLayerPass = TRUE,
    FittedInformationLayerPass = TRUE,
    LocalLayerPass = TRUE,
    GlobalHoldCorrectlyRetained = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4rho_review <- function() {
  mfrmr_cq_p2c4rho_require_contract()
  rows <- mfrmr_cq_p2c4rho_arm_observation()
  local_complete <- nrow(rows) == 4L &&
    all(rows$AdditiveRank == rows$AdditiveDimension) &&
    all(rows$AdditiveNullity == 0L) &&
    !any(rows$AdditiveToleranceSensitive) &&
    all(rows$ObservedPatternScoreRank == rows$FullFreeDimension) &&
    all(rows$ObservedPatternScoreNullity == 0L) &&
    !any(rows$ObservedPatternToleranceSensitive) &&
    all(rows$NonlinearBlock == "log_sigma2") &&
    all(rows$LocalState == "locally_full_rank_sufficient") &&
    all(rows$AdditiveLayerPass) && all(rows$TransformationLayerPass) &&
    all(rows$ObservedPatternLayerPass) &&
    all(rows$FittedInformationLayerPass) && all(rows$LocalLayerPass)
  global_hold <- local_complete &&
    !any(rows$GlobalIdentificationClassified) &&
    !any(rows$ContinuousIntegralIdentificationClassified) &&
    !any(rows$WeakInformationClassified) &&
    all(rows$PropagatedEstimabilityState == "not_evaluated") &&
    all(rows$PropagatedFitReadiness == "review") &&
    !any(rows$PropagatedInferenceReady) &&
    all(rows$GlobalHoldCorrectlyRetained)
  list(
    specification = mfrmr_cq_p2c4rho_specification,
    contract_version = mfrmr_cq_p2c4rho_contract,
    status = if (local_complete && global_hold) {
      "candidate_004_local_full_rank_global_nonlinear_identification_open"
    } else {
      "candidate_004_rank_hold_observation_invalid"
    },
    arm_observation = rows,
    all_additive_designs_full_rank = all(rows$AdditiveLayerPass),
    all_observed_pattern_scores_full_rank = all(rows$ObservedPatternLayerPass),
    all_fixed_quadrature_local_states_full_rank = all(rows$LocalLayerPass),
    global_marginal_identification_classified = FALSE,
    continuous_integral_identification_classified = FALSE,
    weak_information_classified = FALSE,
    bounded_cross_engine_claim_can_retain_hold = TRUE,
    inference_ready_claim_requires_hold_resolution = TRUE,
    design_rank_hold_resolved = FALSE,
    mfrmr_inference_ready = FALSE,
    existing_fit_readiness_rewritten = FALSE,
    new_fit_attempted = FALSE,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
