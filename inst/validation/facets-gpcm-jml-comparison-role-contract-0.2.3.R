# Deterministic comparison-role contract for FACETS and mfrmr GPCM JML.
#
# This repository-only contract runs no fit and sets no numerical tolerance.
# It prevents a FACETS PCM/JMLE result or Table 7 discrimination diagnostic
# from being relabelled as a direct free-slope GPCM estimate.

mfrmr_fgjc_specification <- "0.2.3-draft.1"
mfrmr_fgjc_contract <-
  "mfrmr_facets_gpcm_jml_comparison_role_contract_v1"

mfrmr_fgjc_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_fgjc_source_registry <- function() {
  data.frame(
    SourceId = c(
      "FACETS-PRODUCT", "FACETS-MODELS", "FACETS-TABLE7",
      "FACETS-CONVERGENCE", "MURAKI-1992", "WIJAYANTO-2021",
      "HESSEN-2025", "RIRT-0.0.2"
    ),
    SourceRole = c(
      "current_version_at_review", "pcm_adjacent_logit_model",
      "postfit_discrimination_semantics", "jml_ucon_stopping_semantics",
      "gpcm_mml_em_origin", "gpcm_penalized_jml_neighbour",
      "fixed_random_effects_and_incidental_parameter_qualification",
      "finite_box_gpcm_jml_neighbour"
    ),
    VersionAtReview = c(
      "4.5.1", "4.5.1_help", "4.5.1_help", "4.5.1_help",
      "1992", "2021", "2025", "0.0.2"
    ),
    URL = c(
      "https://www.winsteps.com/facets.htm",
      "https://www.winsteps.com/facetman/models.htm",
      "https://www.winsteps.com/facetman/table7.htm",
      "https://www.winsteps.com/facetman64/convergencecriteria.htm",
      "https://doi.org/10.1177/014662169201600206",
      "https://doi.org/10.1111/bmsp.12218",
      "https://doi.org/10.1111/bmsp.12365",
      "https://stat.ethz.ch/CRAN/web/packages/Rirt/refman/Rirt.html"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fgjc_estimator_registry <- function() {
  data.frame(
    RouteId = c(
      "MFRMR-GPCM-JML", "MFRMR-PCM-JML", "FACETS-PCM-JMLE",
      "FACETS-T7-DISCRM", "WIJAYANTO-GPCM-PJML",
      "RIRT-GPCM-BOX-JML", "MURAKI-GPCM-MML-EM"
    ),
    Program = c(
      "mfrmr", "mfrmr", "FACETS", "FACETS", "Wijayanto",
      "Rirt", "Muraki"
    ),
    ResponseFamily = c(
      "aligned_single_owner_GPCM", "PCM", "PCM",
      "PCM_postfit_diagnostic", "item_GPCM", "item_GPCM", "item_GPCM"
    ),
    EstimatorFamily = c(
      "unpenalized_identified_JML", "unpenalized_identified_JML",
      "JMLE_UCON", "postfit_diagnostic", "penalized_JML",
      "finite_box_JML", "MML_EM"
    ),
    PersonTreatment = c(
      "joint_fixed_coordinates", "joint_fixed_coordinates",
      "joint_fixed_coordinates", "inherited_from_PCM_fit",
      "joint_fixed_coordinates", "joint_fixed_coordinates",
      "integrated_random_effect"
    ),
    StatisticalPenalty = c(
      "none", "none", "none_in_declared_pcm_model",
      "not_applicable", "ridge_on_person_and_log_discrimination",
      "none_inside_box", "none"
    ),
    FiniteParameterBox = c(
      "none", "none", "runtime_contract_must_be_bound",
      "not_applicable", "not_the_defining_regularizer",
      "ability_discrimination_location_and_category_bounds",
      "not_applicable"
    ),
    SlopeRole = c(
      "estimated_positive_selected_owner_relative_gm1", "fixed_unit",
      "fixed_unit", "postfit_diagnostic_does_not_update_other_estimates",
      "estimated_and_shrunk_toward_one", "estimated_inside_finite_box",
      "estimated_on_random_person_scale"
    ),
    FreeSlopeEstimatedInLikelihood = c(
      TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE
    ),
    ExactFullMfrmrGpcmIdentity = c(
      TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fgjc_lane_registry <- function() {
  data.frame(
    LaneId = c(
      "FACETS-PCM-JML-DIRECT",
      "GPCM-UNIT-SLOPE-REDUCTION",
      "GPCM-NONUNIT-TRUTH-RECOVERY",
      "FACETS-DISCRM-DIAGNOSTIC",
      "FACETS-EXTREME-PERSON-STATUS",
      "GPCM-PJML-SENSITIVITY",
      "GPCM-BOX-JML-SENSITIVITY",
      "GPCM-MML-SENSITIVITY"
    ),
    PrimaryRouteId = c(
      "MFRMR-PCM-JML", "MFRMR-GPCM-JML", "MFRMR-GPCM-JML",
      "MFRMR-GPCM-JML", "MFRMR-PCM-JML", "MFRMR-GPCM-JML",
      "MFRMR-GPCM-JML", "MFRMR-GPCM-JML"
    ),
    ComparatorRouteId = c(
      "FACETS-PCM-JMLE", "MFRMR-PCM-JML", "known_GPCM_generating_truth",
      "FACETS-T7-DISCRM", "FACETS-PCM-JMLE",
      "WIJAYANTO-GPCM-PJML", "RIRT-GPCM-BOX-JML",
      "MURAKI-GPCM-MML-EM"
    ),
    EstimandRelation = c(
      "direct_common_estimand_after_contract",
      "exact_unit_slope_kernel_reduction",
      "truth_recovery_with_facets_pcm_as_misspecification_control",
      "postfit_diagnostic_association_only",
      "boundary_status_and_matched_display_convention_only",
      "different_objective_sensitivity",
      "different_parameter_space_sensitivity",
      "different_person_treatment_sensitivity"
    ),
    EligibleOutputs = c(
      "nonextreme_common_coordinates;truth_recovery;matched_predictions",
      "probability;log_likelihood;score_at_unit_slope_point",
      "bias;rmse;failure_rate;boundary_rate_by_parameter_class",
      "diagnostic_rank;diagnostic_calibration;directional_association",
      "low_high_boundary_status;separately_matched_display_value",
      "objective_labelled_bias_rmse;penalty_sensitivity",
      "boundary_hit_rate;interior_sensitivity;objective_labelled_bias_rmse",
      "truth_recovery;person_treatment_sensitivity;information_per_person"
    ),
    ForbiddenClaim = c(
      "no_free_slope_GPCM_equivalence",
      "no_external_FACETS_GPCM_fit_claim",
      "no_FACETS_parameter_equivalence_or_model_selection_claim",
      "no_slope_estimate_equality_or_likelihood_identity",
      "no_raw_extreme_measure_equality",
      "no_same_objective_or_same_estimator_claim",
      "no_unconstrained_JML_maximum_claim",
      "no_same_person_estimand_or_universal_superiority_claim"
    ),
    FutureLaneAdmissible = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
    CurrentExternalExecutionAuthorized = FALSE,
    CurrentNumericToleranceFrozen = FALSE,
    EquivalenceClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fgjc_validate_result <- function(result) {
  sources <- result$SourceRegistry
  estimators <- result$EstimatorRegistry
  lanes <- result$LaneRegistry

  mfrmr_fgjc_assert(
    is.data.frame(sources) && nrow(sources) == 8L &&
      !anyDuplicated(sources$SourceId) &&
      all(nzchar(sources$URL)),
    "FACETS/GPCM source registry is incomplete."
  )
  mfrmr_fgjc_assert(
    is.data.frame(estimators) && nrow(estimators) == 7L &&
      !anyDuplicated(estimators$RouteId) &&
      sum(estimators$ExactFullMfrmrGpcmIdentity) == 1L &&
      estimators$ExactFullMfrmrGpcmIdentity[
        estimators$RouteId == "MFRMR-GPCM-JML"
      ],
    "Estimator-family identity registry drifted."
  )
  facets <- estimators$Program == "FACETS"
  mfrmr_fgjc_assert(
    all(!estimators$FreeSlopeEstimatedInLikelihood[facets]) &&
      identical(
        estimators$SlopeRole[estimators$RouteId == "FACETS-T7-DISCRM"],
        "postfit_diagnostic_does_not_update_other_estimates"
      ),
    "FACETS discrimination cannot be classified as a fitted GPCM slope."
  )
  mfrmr_fgjc_assert(
    is.data.frame(lanes) && nrow(lanes) == 8L &&
      !anyDuplicated(lanes$LaneId) &&
      identical(
        lanes$EstimandRelation[lanes$LaneId == "FACETS-PCM-JML-DIRECT"],
        "direct_common_estimand_after_contract"
      ) &&
      identical(
        lanes$PrimaryRouteId[lanes$LaneId == "FACETS-PCM-JML-DIRECT"],
        "MFRMR-PCM-JML"
      ) &&
      identical(
        lanes$ComparatorRouteId[lanes$LaneId == "FACETS-PCM-JML-DIRECT"],
        "FACETS-PCM-JMLE"
      ),
    "The only direct FACETS lane must remain PCM/JML."
  )
  mfrmr_fgjc_assert(
    all(!lanes$CurrentExternalExecutionAuthorized) &&
      all(!lanes$CurrentNumericToleranceFrozen) &&
      all(!lanes$EquivalenceClaimAuthorized) &&
      !isTRUE(result$FacetsDirectFreeSlopeGpcmRouteExists) &&
      identical(result$ExternalFitsRun, 0L) &&
      !isTRUE(result$GpcmCorePromotionAuthorized),
    "The comparison-role contract cannot authorize execution or promotion."
  )
  invisible(TRUE)
}

mfrmr_facets_gpcm_jml_comparison_role_contract <- function() {
  out <- list(
    Specification = mfrmr_fgjc_specification,
    Contract = mfrmr_fgjc_contract,
    ReviewDate = "2026-08-12",
    SourceRegistry = mfrmr_fgjc_source_registry(),
    EstimatorRegistry = mfrmr_fgjc_estimator_registry(),
    LaneRegistry = mfrmr_fgjc_lane_registry(),
    StructuralRoleContractComplete = TRUE,
    FacetsPcmJmlDirectLaneDefined = TRUE,
    FacetsDirectFreeSlopeGpcmRouteExists = FALSE,
    FacetsDiscriminationDiagnosticOnly = TRUE,
    MfrmrUnpenalizedJmlSeparatedFromPjml = TRUE,
    MfrmrUnpenalizedJmlSeparatedFromFiniteBoxJml = TRUE,
    ExternalFitsRun = 0L,
    ExternalExecutionAuthorized = FALSE,
    NumericToleranceFrozen = FALSE,
    BroadSimulationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    GpcmCorePromotionAuthorized = FALSE
  )
  class(out) <- c("mfrmr_facets_gpcm_jml_comparison_role_contract", "list")
  mfrmr_fgjc_validate_result(out)
  out
}
