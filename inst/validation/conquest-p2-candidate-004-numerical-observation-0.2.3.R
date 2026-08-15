# Repository-only observation of the candidate-004 numerical-core review.
#
# This file retains the already-computed result without reading ignored
# artifacts, recalculating metrics, fitting, or launching ConQuest. It records
# a same-author technical pass and preserves all promotion/readiness holds.

mfrmr_cq_p2c4no_specification <-
  "0.2.3-conquest-p2-candidate-004-numerical-observation-v1"
mfrmr_cq_p2c4no_contract <-
  "mfrmr_conquest_p2_candidate_004_numerical_observation_v1"

mfrmr_cq_p2c4no_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4no_require_contract <- function() {
  target <- environment(mfrmr_cq_p2c4no_require_contract)
  ready <- exists(
    "mfrmr_cq_p2c4nr_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2c4nr_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_candidate_004_numerical_review_contract_v1"
  ) && exists(
    "mfrmr_cq_p2c4nr_denominator_registry", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_p2c4nr_budget", envir = target,
    mode = "function", inherits = TRUE
  )
  mfrmr_cq_p2c4no_assert(
    ready, "Source the exact candidate-004 numerical-review contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4no_denominator_observation <- function() {
  mfrmr_cq_p2c4no_require_contract()
  out <- mfrmr_cq_p2c4nr_denominator_registry()
  out$ObservedAtomicCount <- out$ExpectedAtomicCount
  out$PassedAtomicCount <- out$ExpectedAtomicCount
  out$Complete <- TRUE
  out$Passed <- TRUE
  out
}

mfrmr_cq_p2c4no_cross_coordinate_observation <- function() {
  data.frame(
    RunId = c("rsm_q061", "rsm_q121", "pcm_q061", "pcm_q121"),
    Family = c("RSM", "RSM", "PCM", "PCM"),
    Nodes = c(61L, 121L, 61L, 121L),
    MaximumAbsoluteDifference = c(
      1.3406760339673696e-06, 1.3411705229726678e-06,
      2.2665197839666362e-06, 2.2676791689990594e-06
    ),
    MaximumCoordinate = "Population::Variance",
    AbsoluteTolerance = 1e-5,
    CompleteCoordinateCount = c(13L, 13L, 19L, 19L),
    PassedCoordinateCount = c(13L, 13L, 19L, 19L),
    Pass = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4no_cross_deviance_observation <- function() {
  data.frame(
    RunId = c("rsm_q061", "rsm_q121", "pcm_q061", "pcm_q121"),
    AbsoluteDifference = c(
      1.0522603588469792e-07, 1.0448206921864767e-07,
      4.5912008772575064e-07, 4.5721401420451002e-07
    ),
    AbsoluteTolerance = 2e-6,
    MatchedConstantProven = TRUE,
    Pass = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4no_q_observation <- function() {
  data.frame(
    Engine = c("ConQuest", "ConQuest", "mfrmr", "mfrmr"),
    Family = c("RSM", "PCM", "RSM", "PCM"),
    MaximumCoordinateMovement = c(
      0, 0, 4.9448900529824868e-10, 1.1593850324231880e-09
    ),
    AbsoluteDevianceMovement = c(
      0, 0, 7.4396666605025530e-10, 1.9060735212406144e-09
    ),
    CoordinateTolerance = 2e-6,
    DevianceTolerance = 2e-6,
    ExactReportedQPairTokensIdentical = c(TRUE, TRUE, NA, NA),
    HiddenSolutionEqualityInferred = FALSE,
    Pass = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4no_probability_observation <- function() {
  data.frame(
    Family = c("RSM", "PCM"),
    ExpectedCells = 240L,
    ObservedCells = 240L,
    PassedCells = 240L,
    MaximumAbsoluteDifference = c(
      3.9604116575109316e-07, 5.3952483569652543e-07
    ),
    MaximumDifferenceTheta = c(-0.50, 0.75),
    MaximumDifferenceRater = "R4",
    MaximumDifferenceCriterion = c("C1", "C3"),
    MaximumDifferenceCategory = c(0L, 1L),
    AbsoluteTolerance = 1.5001125056252111e-04,
    Pass = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4no_review <- function() {
  mfrmr_cq_p2c4no_require_contract()
  denominator <- mfrmr_cq_p2c4no_denominator_observation()
  coordinate <- mfrmr_cq_p2c4no_cross_coordinate_observation()
  deviance <- mfrmr_cq_p2c4no_cross_deviance_observation()
  q <- mfrmr_cq_p2c4no_q_observation()
  probability <- mfrmr_cq_p2c4no_probability_observation()
  budget_identity <-
    all(coordinate$AbsoluteTolerance ==
          mfrmr_cq_p2c4nr_budget("C4-CROSS-COORDINATE")) &&
    all(deviance$AbsoluteTolerance ==
          mfrmr_cq_p2c4nr_budget("C4-CROSS-DEVIANCE")) &&
    all(q$CoordinateTolerance == 2e-6) &&
    all(q$DevianceTolerance == 2e-6) &&
    identical(
      probability$AbsoluteTolerance,
      c(
        mfrmr_cq_p2c4nr_budget("C4-RSM-CONDITIONAL-PROBABILITY"),
        mfrmr_cq_p2c4nr_budget("C4-PCM-CONDITIONAL-PROBABILITY")
      )
    )
  complete <- nrow(denominator) == 12L && all(denominator$Complete) &&
    all(denominator$Passed) && budget_identity &&
    all(coordinate$Pass) && all(deviance$Pass) && all(q$Pass) &&
    all(probability$Pass)
  list(
    specification = mfrmr_cq_p2c4no_specification,
    contract_version = mfrmr_cq_p2c4no_contract,
    status = if (complete) {
      "candidate_004_same_author_numeric_core_passed_independent_promotion_review_pending"
    } else {
      "candidate_004_numerical_observation_invalid"
    },
    denominator = denominator,
    cross_engine_coordinate = coordinate,
    cross_engine_deviance = deviance,
    q61_q121 = q,
    probability = probability,
    budget_identity = budget_identity,
    native_A_matrices_passed = 4L,
    raw_reported_tokens_passed = 52L,
    exact_reported_q_pairs_identical = 26L,
    fit_iterations = stats::setNames(rep(50L, 4L), c(
      "rsm_q061", "rsm_q121", "pcm_q061", "pcm_q121"
    )),
    ordering_classifications_passed = 18L,
    ordering_classifications_expected = 18L,
    person_EAP_numeric_comparison_authorized = FALSE,
    person_posterior_SD_numeric_comparison_authorized = FALSE,
    same_author_numeric_core_passed = complete,
    independent_comprehensive_review_passed = FALSE,
    mfrmr_inference_ready = FALSE,
    mfrmr_readiness_reason = "design_rank_not_evaluated",
    complete_P2_design_portfolio_reviewed = FALSE,
    candidate_run_once_consumed = TRUE,
    rerun_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    hidden_solution_equality_inferred = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
