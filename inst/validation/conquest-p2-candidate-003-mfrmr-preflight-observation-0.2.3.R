# Repository-only observation of the consumed candidate-003 mfrmr preflight.
#
# The observation preserves the four fit states and two failed q-movement gates
# without reading the ignored run directory, fitting a model, launching a
# process, changing a threshold, or authorizing a rerun.

mfrmr_cq_p2c3o_specification <-
  "0.2.3-conquest-p2-candidate-003-mfrmr-preflight-observation-v1"
mfrmr_cq_p2c3o_contract <-
  "mfrmr_conquest_p2_candidate_003_mfrmr_preflight_observation_v1"

mfrmr_cq_p2c3o_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c3o_require_contract <- function() {
  target <- environment(mfrmr_cq_p2c3o_require_contract)
  ready <- exists(
    "mfrmr_cq_p2c3p_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2c3p_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_candidate_003_mfrmr_preflight_v1"
  )
  mfrmr_cq_p2c3o_assert(
    ready, "Source the exact candidate-003 mfrmr preflight first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c3o_fit_observation <- function() {
  data.frame(
    RunId = c("rsm_q031", "rsm_q061", "pcm_q031", "pcm_q061"),
    Family = c("RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L),
    ExpectedNpar = c(10L, 10L, 14L, 14L),
    ObservedNpar = c(10L, 10L, 14L, 14L),
    LogLik = c(
      -361.76550564695998, -361.76549887374898,
      -360.36118198469399, -360.36117552476202
    ),
    Deviance = c(
      723.53101129391905, 723.53099774749899,
      720.72236396938899, 720.72235104952404
    ),
    PopulationVariance = c(
      0.63299717398419797, 0.63300239314365003,
      0.63578100194701404, 0.63578636309340897
    ),
    ConvergenceStatus = "converged",
    ConvergenceSeverity = "pass",
    FitReadiness = "review",
    InferenceReady = FALSE,
    EstimabilityState = "not_evaluated",
    BoundaryState = "finite",
    NumericalState = "ready",
    ReadinessReasonCodes = "design_rank_not_evaluated",
    WarningCount = 0L,
    DimensionPass = TRUE,
    NumericalPass = TRUE,
    BoundaryAndVariancePass = TRUE,
    OnlyDesignRankNotEvaluatedHold = TRUE,
    ReadinessStateRetained = TRUE,
    StructuralNumericalPass = TRUE,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c3o_q_observation <- function() {
  data.frame(
    Family = c("RSM", "PCM"),
    ExpectedCoordinateCount = c(13L, 19L),
    CoordinateCount = c(13L, 19L),
    SameCoordinateSet = TRUE,
    CompleteCoordinateDenominator = TRUE,
    MaximumAbsoluteQ31Q61CoordinateMovement = c(
      5.2191594517303503e-06, 5.3611463954883501e-06
    ),
    CoordinateTolerance = 2e-06,
    AbsoluteQ31Q61DevianceMovement = c(
      1.3546420632337699e-05, 1.2919864389004900e-05
    ),
    DevianceTolerance = 2e-06,
    Passed = FALSE,
    FailureOutcome = "integration_unresolved",
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c3o_review <- function() {
  mfrmr_cq_p2c3o_require_contract()
  fit <- mfrmr_cq_p2c3o_fit_observation()
  q <- mfrmr_cq_p2c3o_q_observation()
  fit_retained <- nrow(fit) == 4L &&
    identical(fit$ObservedNpar, fit$ExpectedNpar) &&
    all(fit$StructuralNumericalPass) &&
    !any(fit$InferenceReady) &&
    all(fit$OnlyDesignRankNotEvaluatedHold) &&
    all(fit$PopulationVariance >=
          mfrmr_cq_p2c3p_minimum_population_variance)
  q_failure_retained <- nrow(q) == 2L &&
    all(q$CompleteCoordinateDenominator) && !any(q$Passed) &&
    all(q$MaximumAbsoluteQ31Q61CoordinateMovement > q$CoordinateTolerance) &&
    all(q$AbsoluteQ31Q61DevianceMovement > q$DevianceTolerance) &&
    all(q$FailureOutcome == "integration_unresolved")
  ready <- fit_retained && q_failure_retained
  list(
    specification = mfrmr_cq_p2c3o_specification,
    contract_version = mfrmr_cq_p2c3o_contract,
    candidate_id = mfrmr_cq_p2c3p_candidate_id,
    status = if (ready) {
      "candidate_003_mfrmr_preflight_consumed_integration_unresolved"
    } else {
      "candidate_003_mfrmr_preflight_observation_invalid"
    },
    fit_observation = fit,
    q_observation = q,
    all_four_structural_numerical_fit_gates_passed = fit_retained,
    all_four_inference_ready = FALSE,
    design_rank_holds_retained = fit_retained,
    both_q31_q61_pairs_failed = q_failure_retained,
    candidate_mfrmr_preflight_consumed = ready,
    candidate_mfrmr_preflight_rerun_authorized = FALSE,
    candidate_external_execution_authorized = FALSE,
    eligible_for_new_external_authorization_review = FALSE,
    successor_integration_contract_required_before_new_candidate = ready,
    threshold_change_authorized = FALSE,
    seed_search_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    truth_recovery_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
