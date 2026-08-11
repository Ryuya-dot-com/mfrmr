# Repository-only v3 rule contract after the negative GPCM score calibration.
#
# This file defines meanings and failure behavior only. It does not rerun v2,
# classify an extreme trace as a proven boundary, freeze final NUM-SCORE-TOL,
# or authorize calibration, inference, selection, or confirmation.

mfrmr_gsv3_contract_version <- "mfrmr_gpcm_score_rule_contract_v3"
mfrmr_gsv3_log_slope_envelope <- 3
mfrmr_gsv3_expected_classes <- c(
  "owner_additive", "other_additive", "steps", "log_slopes"
)
mfrmr_gsv3_expected_points <- c(
  "retained_solution", "coupled_free_probe",
  "finite_slope_stress_forward", "finite_slope_stress_reverse"
)
mfrmr_gsv3_expected_scenarios <- c(
  "NUM-GPCM-SCORE-CAL-C-CORE5", "NUM-GPCM-SCORE-CAL-R-CORE5",
  "NUM-GPCM-SCORE-CAL-C-WEAK5", "NUM-GPCM-SCORE-CAL-R-WEAK5",
  "NUM-GPCM-SCORE-CAL-C-WORK5", "NUM-GPCM-SCORE-CAL-R-WORK5",
  "NUM-GPCM-SCORE-CAL-C-CAT5", "NUM-GPCM-SCORE-CAL-R-CAT5"
)

mfrmr_gsv3_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv3_rule_registry <- function() {
  data.frame(
    Rule = c(
      "independent_analytic_score", "finite_difference_score",
      "expanded_log_jacobian", "expanded_slope_jacobian"
    ),
    Applies = c(
      "all_finite_points", "finite_slope_region_only",
      "all_finite_points", "all_finite_points"
    ),
    AbsoluteFloor = c(1e-8, 1e-7, 5e-10, 1e-9),
    RelativeRate = c(1e-10, 5e-7, 1e-9, 1e-9),
    ReferenceSpreadMultiplier = c(0, 10, 0, 0),
    RoundoffMultiplier = c(0, 10, 0, 0),
    Comparison = "difference <= absolute + relative*scale + spread + roundoff",
    Status = c(
      "attribution_rule_fixed", "retrospective_calibration_candidate",
      "retrospective_calibration_candidate",
      "retrospective_calibration_candidate"
    ),
    FinalNUMSCORETOLFrozen = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv3_classify_log_slopes <- function(expanded_log_slopes) {
  expanded_log_slopes <- suppressWarnings(as.numeric(expanded_log_slopes))
  if (length(expanded_log_slopes) < 2L || any(!is.finite(expanded_log_slopes))) {
    return("not_evaluable")
  }
  if (max(abs(expanded_log_slopes)) <= mfrmr_gsv3_log_slope_envelope) {
    "finite_slope_region"
  } else {
    "extreme_slope_review_handoff"
  }
}

mfrmr_gsv3_allowance <- function(rule, scale,
                                  reference_spread = 0,
                                  roundoff_bound = 0) {
  registry <- mfrmr_gsv3_rule_registry()
  index <- match(rule, registry$Rule)
  scale <- suppressWarnings(as.numeric(scale))
  reference_spread <- suppressWarnings(as.numeric(reference_spread))
  roundoff_bound <- suppressWarnings(as.numeric(roundoff_bound))
  mfrmr_gsv3_assert(
    !is.na(index), "Unknown v3 numerical rule."
  )
  mfrmr_gsv3_assert(
    length(scale) > 0L && all(is.finite(scale)) && all(scale >= 1) &&
      length(reference_spread) %in% c(1L, length(scale)) &&
      length(roundoff_bound) %in% c(1L, length(scale)) &&
      all(is.finite(reference_spread)) && all(reference_spread >= 0) &&
      all(is.finite(roundoff_bound)) && all(roundoff_bound >= 0),
    "Scale, reference spread, and roundoff bound must be finite and nonnegative."
  )
  registry$AbsoluteFloor[index] + registry$RelativeRate[index] * scale +
    registry$ReferenceSpreadMultiplier[index] * reference_spread +
    registry$RoundoffMultiplier[index] * roundoff_bound
}

mfrmr_gsv3_expected_grid <- function() {
  out <- expand.grid(
    ScenarioId = mfrmr_gsv3_expected_scenarios,
    Point = mfrmr_gsv3_expected_points,
    ParameterClass = mfrmr_gsv3_expected_classes,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  out$ContractVersion <- mfrmr_gsv3_contract_version
  out[, c("ContractVersion", "ScenarioId", "Point", "ParameterClass")]
}

mfrmr_gsv3_decision <- function(evidence) {
  expected <- mfrmr_gsv3_expected_grid()
  required <- c(
    names(expected), "SlopeRegion", "StructuralOraclePass",
    "AnalyticScorePass", "FiniteDifferenceStatus",
    "FiniteDifferenceCombinedRatio", "LogJacobianCombinedRatio",
    "SlopeJacobianCombinedRatio", "ExtremeSlopeReviewHandoff",
    "SourceInferenceReady", "EvaluationComplete",
    "CalibrationAuthorized", "ConfirmationAuthorized"
  )
  key <- function(data) paste(
    data$ScenarioId, data$Point, data$ParameterClass, sep = "::"
  )
  structure_complete <- is.data.frame(evidence) &&
    all(required %in% names(evidence)) && nrow(evidence) == nrow(expected) &&
    !anyDuplicated(key(evidence)) &&
    identical(sort(key(evidence)), sort(key(expected))) &&
    all(evidence$ContractVersion == mfrmr_gsv3_contract_version)
  finite_region <- if (structure_complete) {
    evidence$SlopeRegion == "finite_slope_region"
  } else {
    logical(0)
  }
  extreme_region <- if (structure_complete) {
    evidence$SlopeRegion == "extreme_slope_review_handoff"
  } else {
    logical(0)
  }
  known_region <- structure_complete && all(finite_region | extreme_region)
  constructed_points_finite <- structure_complete && all(
    evidence$SlopeRegion[evidence$Point != "retained_solution"] ==
      "finite_slope_region"
  )
  finite_pass <- known_region && all(
    evidence$FiniteDifferenceStatus[finite_region] == "pass" &
      is.finite(evidence$FiniteDifferenceCombinedRatio[finite_region]) &
      evidence$FiniteDifferenceCombinedRatio[finite_region] <= 1 &
      !evidence$ExtremeSlopeReviewHandoff[finite_region]
  )
  extreme_pass <- known_region && all(
    evidence$FiniteDifferenceStatus[extreme_region] ==
      "not_applicable_extreme_slope" &
      is.na(evidence$FiniteDifferenceCombinedRatio[extreme_region]) &
      evidence$ExtremeSlopeReviewHandoff[extreme_region] &
      !evidence$SourceInferenceReady[extreme_region]
  )
  common_pass <- structure_complete &&
    all(evidence$EvaluationComplete %in% TRUE) &&
    all(evidence$StructuralOraclePass %in% TRUE) &&
    all(evidence$AnalyticScorePass %in% TRUE) &&
    all(is.finite(evidence$LogJacobianCombinedRatio)) &&
    all(evidence$LogJacobianCombinedRatio <= 1) &&
    all(is.finite(evidence$SlopeJacobianCombinedRatio)) &&
    all(evidence$SlopeJacobianCombinedRatio <= 1) &&
    all(evidence$CalibrationAuthorized %in% FALSE) &&
    all(evidence$ConfirmationAuthorized %in% FALSE)
  passed <- structure_complete && known_region && constructed_points_finite &&
    finite_pass && extreme_pass && common_pass
  data.frame(
    ContractVersion = mfrmr_gsv3_contract_version,
    ExpectedRows = nrow(expected),
    StructureComplete = structure_complete,
    RegionClassificationComplete = known_region,
    ConstructedPointsFinite = constructed_points_finite,
    FiniteRegionRulePass = finite_pass,
    ExtremeHandoffRulePass = extreme_pass,
    CommonRulePass = common_pass,
    ContractReady = passed,
    Status = if (passed) "v3_rule_contract_ready" else "rejected",
    V2CalibrationStatus = "rejected_unchanged",
    GeneralNUMSCORETOLStatus = "pilot_required",
    BoundaryProven = FALSE,
    CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv3_contract <- function() {
  list(
    contract_version = mfrmr_gsv3_contract_version,
    slope_region = list(
      coordinate = "expanded_sum_zero_log_slopes",
      inclusive_max_abs = mfrmr_gsv3_log_slope_envelope,
      finite_region = "finite_slope_region",
      outside_region = "extreme_slope_review_handoff",
      outside_is_boundary_proof = FALSE,
      outside_can_support_finite_stationarity = FALSE
    ),
    rules = mfrmr_gsv3_rule_registry(),
    expected_grid = mfrmr_gsv3_expected_grid(),
    analytic_score_required_everywhere = TRUE,
    finite_difference_required_only_in_finite_region = TRUE,
    extreme_handoff_requires_source_inference_unready = TRUE,
    v2_calibration_status = "rejected_unchanged",
    retrospective_rule_evaluation_authorized = FALSE,
    general_num_score_tol_frozen = FALSE,
    boundary_proven = FALSE,
    confirmation_authorized = FALSE
  )
}
