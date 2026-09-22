# Repository-only observation of the first minimum P2 diagnostic execution.
#
# The run-once candidate halted after all four mfrmr fits and the first
# ConQuest arm. This file reconstructs the engine-independent fixture signal
# diagnostics and records the retained execution state. It does not read the
# ignored candidate directory, launch a process, fit a model, compare numeric
# estimates, authorize a rerun, or promote evidence.

mfrmr_cq_mdo_specification <-
  "0.2.3-conquest-minimum-diagnostic-execution-observation-v1"
mfrmr_cq_mdo_contract <-
  "mfrmr_conquest_minimum_diagnostic_execution_observation_v1"
mfrmr_cq_mdo_candidate_id <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-001"

mfrmr_cq_mdo_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_mdo_require_contracts <- function() {
  target <- environment(mfrmr_cq_mdo_require_contracts)
  required <- c(
    "mfrmr_cq_mdh_plan", "mfrmr_cq_mdh_wide_fixture",
    "mfrmr_cq_srp_failure_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_mdh_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_mdh_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_minimum_diagnostic_harness_v1"
  )
  mfrmr_cq_mdo_assert(
    all(available) && identity,
    "Source the exact minimum diagnostic harness before its observation."
  )
  invisible(TRUE)
}

mfrmr_cq_mdo_fixture_signal <- function() {
  mfrmr_cq_mdo_require_contracts()
  data <- mfrmr_cq_mdh_wide_fixture()$long
  person <- stats::aggregate(Response ~ Person + X, data, sum)
  by_x <- stats::aggregate(Response ~ X, person, mean)
  rater_category <- xtabs(~ Rater + Response, data)
  criterion_category <- xtabs(~ Criterion + Response, data)
  score_count <- table(factor(person$Response, levels = 0:18))
  data.frame(
    Persons = nrow(person),
    ObservedRows = nrow(data),
    ResponsesPerPerson = nrow(data) / nrow(person),
    PersonScoreMinimum = min(person$Response),
    PersonScoreMaximum = max(person$Response),
    PersonScoreVariance = stats::var(person$Response),
    PersonScoreXCorrelation = stats::cor(person$Response, person$X),
    MeanScoreXNegative = by_x$Response[by_x$X == -1],
    MeanScoreXPositive = by_x$Response[by_x$X == 1],
    PersonScore8Count = unname(score_count["8"]),
    PersonScore10Count = unname(score_count["10"]),
    RaterCategoryMinimumCount = min(rater_category),
    RaterCategoryMaximumCount = max(rater_category),
    CriterionCategoryMinimumCount = min(criterion_category),
    CriterionCategoryMaximumCount = max(criterion_category),
    ExactFacetCategoryBalance =
      length(unique(as.integer(rater_category))) == 1L &&
      length(unique(as.integer(criterion_category))) == 1L,
    CovariateMeanScoreSeparation = abs(diff(by_x$Response)),
    NondegeneratePopulationSignalGatePassed = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_mdo_engine_observation <- function() {
  data.frame(
    Engine = c("mfrmr", "ConQuest"),
    AuthorizedFitCap = c(4L, 4L),
    AttemptedFits = c(4L, 1L),
    StructurallyCompleteFits = c(4L, 0L),
    ExpectedDimensionFits = c(4L, NA_integer_),
    InferenceReadyFits = c(0L, NA_integer_),
    RemainingUnattemptedFits = c(0L, 3L),
    FirstArmExitStatus = c(NA_integer_, 0L),
    FirstArmTerminalMarker = c(NA, TRUE),
    FirstArmRegisteredFailureCount = c(NA_integer_, 4L),
    FirstArmCompleteNativeOutputCount = c(NA_integer_, 2L),
    Status = c(
      "all_fixed_fits_complete_expected_dimension_not_inference_ready",
      "first_arm_estimation_abort_later_arms_not_attempted"
    ),
    EvidencePromotionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_mdo_conquest_failure_observation <- function() {
  registered <- mfrmr_cq_srp_failure_registry()
  observed_code <- c(
    "model_not_estimated", "compute_command_error",
    "print_command_error", "equation_symbol_error"
  )
  out <- registered[
    match(observed_code, registered$FailureCode),
    c("FailureCode", "PrimaryClass"), drop = FALSE
  ]
  mfrmr_cq_mdo_assert(
    !anyNA(out$FailureCode),
    "The four retained ConQuest failure codes left the semantic registry."
  )
  out$Observed <- TRUE
  out$CascadeRole <- c(
    "post_estimation_abort", "post_estimation_abort",
    "post_estimation_abort", "post_estimation_abort"
  )
  out$RootSignal <-
    "variance_estimate_became_negative_before_model_estimation_completed"
  out$EvidencePromotionAuthorized <- FALSE
  out$ScientificEquivalenceInferred <- FALSE
  out
}

mfrmr_cq_mdo_review <- function() {
  mfrmr_cq_mdo_require_contracts()
  plan <- mfrmr_cq_mdh_plan()
  signal <- mfrmr_cq_mdo_fixture_signal()
  engine <- mfrmr_cq_mdo_engine_observation()
  failure <- mfrmr_cq_mdo_conquest_failure_observation()
  signal_defect <- nrow(signal) == 1L && signal$Persons == 48L &&
    signal$ObservedRows == 288L && signal$ResponsesPerPerson == 6L &&
    signal$PersonScoreMinimum == 8L && signal$PersonScoreMaximum == 10L &&
    signal$PersonScore8Count == 24L && signal$PersonScore10Count == 24L &&
    signal$PersonScoreXCorrelation == 0 &&
    signal$MeanScoreXNegative == signal$MeanScoreXPositive &&
    signal$CovariateMeanScoreSeparation == 0 &&
    signal$RaterCategoryMinimumCount == 18L &&
    signal$RaterCategoryMaximumCount == 18L &&
    signal$CriterionCategoryMinimumCount == 24L &&
    signal$CriterionCategoryMaximumCount == 24L &&
    isTRUE(signal$ExactFacetCategoryBalance) &&
    !isTRUE(signal$NondegeneratePopulationSignalGatePassed)
  execution_retained <- nrow(engine) == 2L &&
    identical(engine$AttemptedFits, c(4L, 1L)) &&
    identical(engine$StructurallyCompleteFits, c(4L, 0L)) &&
    engine$FirstArmExitStatus[engine$Engine == "ConQuest"] == 0L &&
    isTRUE(engine$FirstArmTerminalMarker[engine$Engine == "ConQuest"]) &&
    engine$FirstArmRegisteredFailureCount[engine$Engine == "ConQuest"] == 4L &&
    engine$FirstArmCompleteNativeOutputCount[engine$Engine == "ConQuest"] == 2L &&
    nrow(failure) == 4L && all(failure$Observed)
  ready <- nrow(plan) == 4L && signal_defect && execution_retained
  list(
    specification = mfrmr_cq_mdo_specification,
    contract_version = mfrmr_cq_mdo_contract,
    candidate_id = mfrmr_cq_mdo_candidate_id,
    status = if (ready) {
      "diagnostic_halted_fixture_signal_defect_no_rerun_authorized"
    } else {
      "execution_observation_invalid_or_incomplete"
    },
    plan = plan,
    fixture_signal = signal,
    engine_observation = engine,
    conquest_failure_observation = failure,
    fixture_population_signal_defect_observed = signal_defect,
    execution_failure_retained = execution_retained,
    candidate_run_once_consumed = ready,
    exact_two_row_slice_completed = FALSE,
    current_candidate_rerun_authorized = FALSE,
    replacement_candidate_execution_authorized = FALSE,
    fixture_supersession_required = ready,
    independent_review_is_next_execution_blocker = FALSE,
    independent_review_still_blocks_evidence_promotion = TRUE,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
