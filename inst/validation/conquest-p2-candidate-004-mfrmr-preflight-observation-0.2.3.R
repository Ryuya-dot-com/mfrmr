# Repository-only observation of the candidate-004 mfrmr preflight.
#
# The initial six-fit phase selected q61--q121. q241 was not run. This file
# retains the outcome without fitting, reading fit artifacts, or launching an
# external executable.

mfrmr_cq_p2c4po_specification <-
  "0.2.3-conquest-p2-candidate-004-mfrmr-preflight-observation-v1"
mfrmr_cq_p2c4po_contract <-
  "mfrmr_conquest_p2_candidate_004_mfrmr_preflight_observation_v1"

mfrmr_cq_p2c4po_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4po_require_contract <- function() {
  target <- environment(mfrmr_cq_p2c4po_require_contract)
  ready <- exists(
    "mfrmr_cq_p2c4p_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2c4p_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_candidate_004_mfrmr_preflight_v1"
  )
  mfrmr_cq_p2c4po_assert(
    ready, "Source the exact candidate-004 mfrmr preflight contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4po_fit_observation <- function() {
  data.frame(
    RunId = c(
      "rsm_q031", "rsm_q061", "rsm_q121",
      "pcm_q031", "pcm_q061", "pcm_q121"
    ),
    Family = rep(c("RSM", "PCM"), each = 3L),
    Nodes = rep(c(31L, 61L, 121L), times = 2L),
    ExpectedNpar = rep(c(10L, 14L), each = 3L),
    ObservedNpar = rep(c(10L, 14L), each = 3L),
    LogLik = c(
      -353.15322612983130, -353.15321855261277, -353.15321855224079,
      -343.87263838514349, -343.87262472956019, -343.87262472860709
    ),
    Deviance = c(
      706.30645225966259, 706.30643710522554, 706.30643710448157,
      687.74527677028698, 687.74524945912037, 687.74524945721419
    ),
    PopulationVariance = c(
      0.70012129846057491, 0.70012634067603352,
      0.70012634117052264, 0.71467329891935061,
      0.71468226651978406, 0.71468226767916887
    ),
    ConvergenceStatus = "converged",
    ConvergenceSeverity = "pass",
    FitReadiness = "review",
    EstimabilityState = "not_evaluated",
    BoundaryState = "finite",
    NumericalState = "ready",
    ReadinessReasonCodes = "design_rank_not_evaluated",
    WarningCount = 0L,
    DimensionPass = TRUE,
    NumericalPass = TRUE,
    BoundaryAndVariancePass = TRUE,
    InferenceReady = FALSE,
    OnlyDesignRankNotEvaluatedHold = TRUE,
    ReadinessStateRetained = TRUE,
    StructuralNumericalPass = TRUE,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4po_diagnostic_observation <- function() {
  data.frame(
    Family = c("RSM", "PCM"),
    ExpectedCoordinateCount = c(13L, 19L),
    CompleteCoordinateDenominator = TRUE,
    MaximumAbsoluteQ31Q61CoordinateMovement = c(
      5.0422154586060586e-06, 8.9676004334515724e-06
    ),
    AbsoluteQ31Q61DevianceMovement = c(
      1.5154437051023706e-05, 2.7311166604704340e-05
    ),
    Governing = FALSE,
    ExternalExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4po_dense_observation <- function() {
  data.frame(
    ArmId = c("RSM", "PCM"),
    LowerNodes = 61L,
    UpperNodes = 121L,
    ExpectedCoordinateCount = c(13L, 19L),
    CoordinateCount = c(13L, 19L),
    CompleteCoordinateDenominator = TRUE,
    SelectedPairStructuralPass = TRUE,
    CoordinateMovement = c(
      4.9448911632055115e-10, 1.1593848103785831e-09
    ),
    DevianceMovement = c(
      7.4396666605025530e-10, 1.9061872080783360e-09
    ),
    UpperContinuousDeviance = c(
      706.30643710448066, 687.74524945721396
    ),
    UpperContinuousDevianceMovement = c(
      9.0949470177292824e-13, 2.2737367544323206e-13
    ),
    DeclaredContinuousDevianceErrorBound = c(
      1.8675759599260751e-11, 1.8717497428529870e-11
    ),
    ContinuousNumericalContractPassed = TRUE,
    Finite = TRUE,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4po_review <- function() {
  mfrmr_cq_p2c4po_require_contract()
  fits <- mfrmr_cq_p2c4po_fit_observation()
  diagnostic <- mfrmr_cq_p2c4po_diagnostic_observation()
  dense <- mfrmr_cq_p2c4po_dense_observation()
  selection <- mfrmr_cq_p2c4p_select_stage(dense)
  fit_ready <- nrow(fits) == 6L &&
    identical(fits$Family, rep(c("RSM", "PCM"), each = 3L)) &&
    identical(fits$Nodes, rep(c(31L, 61L, 121L), times = 2L)) &&
    identical(fits$ExpectedNpar, fits$ObservedNpar) &&
    all(fits$StructuralNumericalPass) &&
    all(fits$PopulationVariance >= mfrmr_cq_p2c4p_minimum_population_variance) &&
    !any(fits$InferenceReady) &&
    all(fits$OnlyDesignRankNotEvaluatedHold) &&
    !any(fits$WarningCount > 0L)
  diagnostic_retained <- nrow(diagnostic) == 2L &&
    all(diagnostic$CompleteCoordinateDenominator) &&
    !any(diagnostic$Governing) &&
    all(diagnostic$MaximumAbsoluteQ31Q61CoordinateMovement > 2e-6) &&
    all(diagnostic$AbsoluteQ31Q61DevianceMovement > 2e-6)
  dense_ready <- nrow(dense) == 2L &&
    all(dense$CompleteCoordinateDenominator) &&
    all(dense$SelectedPairStructuralPass) &&
    all(dense$CoordinateMovement <= 2e-6) &&
    all(dense$DevianceMovement <= 2e-6) &&
    all(dense$UpperContinuousDevianceMovement <= 1e-7) &&
    all(dense$DeclaredContinuousDevianceErrorBound <= 1e-8) &&
    identical(selection$selected_stage, "dense_pair_1") &&
    identical(selection$selected_lower_nodes, 61L) &&
    identical(selection$selected_upper_nodes, 121L)
  retained <- fit_ready && diagnostic_retained && dense_ready
  list(
    specification = mfrmr_cq_p2c4po_specification,
    contract_version = mfrmr_cq_p2c4po_contract,
    status = if (retained) {
      "candidate_004_mfrmr_preflight_passed_external_review_required"
    } else {
      "candidate_004_mfrmr_preflight_observation_invalid"
    },
    fit_summary = fits,
    diagnostic = diagnostic,
    dense_stage_metrics = dense,
    stage_selection = selection,
    six_initial_fits_attempted = nrow(fits) == 6L,
    q241_attempted = FALSE,
    dense_pair_1_selected = dense_ready,
    design_rank_not_evaluated_is_inference_ready = FALSE,
    eligible_for_new_external_authorization_review = retained,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    truth_recovery_authorized = FALSE,
    candidate_003_reclassified = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
