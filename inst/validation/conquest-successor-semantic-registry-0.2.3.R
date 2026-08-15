# Repository-only semantic registry for successor ConQuest comparisons.
#
# The registry is prospective and side-effect free. It fixes comparison
# strata, model signatures, denominators, negative controls, and claim ceilings
# before fixture data or external output exists. It does not launch ConQuest,
# freeze numerical tolerances, or authorize a comparison.

mfrmr_cq_ssr_specification <-
  "0.2.3-conquest-successor-semantic-registry-v1"
mfrmr_cq_ssr_contract <- "mfrmr_conquest_successor_semantic_registry_v1"

mfrmr_cq_ssr_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ssr_expected_free_dimension <- function(
    stratum, family, raters, criteria, items, categories,
    nonintercept_covariates) {
  stratum <- as.character(stratum)
  family <- as.character(family)
  raters <- as.integer(raters)
  criteria <- as.integer(criteria)
  items <- as.integer(items)
  categories <- as.integer(categories)
  nonintercept_covariates <- as.integer(nonintercept_covariates)
  result <- rep(NA_integer_, length(stratum))
  for (index in seq_along(stratum)) {
    if (stratum[index] == "additive_rsm_pcm_mml") {
      population <- nonintercept_covariates[index] + 2L
      facet <- raters[index] - 1L + criteria[index] - 1L
      step <- if (family[index] == "RSM") {
        categories[index] - 2L
      } else if (family[index] == "PCM") {
        criteria[index] * (categories[index] - 2L)
      } else {
        NA_integer_
      }
      result[index] <- population + facet + step
    } else if (stratum[index] == "item_only_pcm_mml") {
      result[index] <- nonintercept_covariates[index] + 2L +
        (items[index] - 1L) + items[index] * (categories[index] - 2L)
    } else if (stratum[index] == "item_only_gpcm_mml") {
      result[index] <- nonintercept_covariates[index] + 2L +
        (items[index] - 1L) + (items[index] - 1L) +
        items[index] * (categories[index] - 2L)
    }
  }
  result
}

mfrmr_cq_ssr_base_rows <- function() {
  data.frame(
    RegistryRowId = c(
      "P2-RSM-CONNECTED-MULTIBRIDGE",
      "P2-PCM-CONNECTED-MULTIBRIDGE",
      "P2-RSM-WEAK-SINGLE-BRIDGE",
      "P2-PCM-WEAK-SINGLE-BRIDGE",
      "P2-RSM-UNEQUAL-WORKLOAD",
      "P2-PCM-UNEQUAL-WORKLOAD",
      "P2-RSM-PLANNED-MISSING-ROWS",
      "P2-RSM-EXPLICIT-MISSING-VALUES",
      "P2-PCM-RARE-BOUNDARY-CATEGORIES",
      "P2-RSM-NONEXTREME-PERSON",
      "P2-RSM-EXTREME-PERSON",
      "P2-NEG-UNUSED-INTERMEDIATE-CATEGORY",
      "P2-NEG-DISCONNECTED-DESIGN",
      "P1-NEG-CATEGORY-MAP-MISMATCH",
      "P1-NEG-FREE-DIMENSION-MISMATCH",
      "P1-NEG-MISSING-OUTPUT",
      "P1-NEG-STATUS-ZERO-SEMANTIC-FAILURE",
      "P3-PCM-UNIT-SLOPE-INTERCEPT",
      "P3-GPCM-NONUNIT-INTERCEPT",
      "P3-GPCM-NONUNIT-COVARIATE",
      "P3-NONOVERLAP-MULTIFACET-OWNER",
      "P3-UNSUPPORTED-JML-SCORESFREE",
      "P3-NONOVERLAP-MULTIDIMENSIONAL"
    ),
    Priority = c(rep("P2", 13L), rep("P1", 4L), rep("P3", 6L)),
    CaseRole = c(
      rep("comparison_candidate", 11L),
      rep("negative_control", 6L),
      rep("comparison_candidate", 3L),
      rep("documented_nonoverlap", 3L)
    ),
    ComparisonStratum = c(
      rep("additive_rsm_pcm_mml", 16L),
      "runtime_semantics",
      "item_only_pcm_mml",
      "item_only_gpcm_mml",
      "item_only_gpcm_mml",
      "many_facet_gpcm_nonoverlap",
      "unsupported_jml_scoresfree",
      "multidimensional_nonoverlap"
    ),
    Family = c(
      "RSM", "PCM", "RSM", "PCM", "RSM", "PCM", "RSM", "RSM",
      "PCM", "RSM", "RSM", "PCM", "RSM", "RSM", "RSM", "RSM",
      "Runtime", "PCM", "GPCM", "GPCM", "GPCM", "GPCM", "GPCM"
    ),
    DesignCase = c(
      "connected_sparse_multiple_independent_bridges",
      "connected_sparse_multiple_independent_bridges",
      "connected_sparse_one_weak_bridge",
      "connected_sparse_one_weak_bridge",
      "connected_sparse_unequal_rater_workload",
      "connected_sparse_unequal_rater_workload",
      "planned_rows_absent",
      "same_cells_explicit_missing_values",
      "rare_minimum_and_maximum_categories_all_transitions_observed",
      "persons_with_nonextreme_observed_scores",
      "persons_with_minimum_or_maximum_observed_scores",
      "declared_0_to_3_support_with_category_1_globally_unused",
      "two_disconnected_rater_criterion_components",
      "declared_and_observed_category_maps_deliberately_differ",
      "declared_and_observed_free_dimensions_deliberately_differ",
      "one_required_native_output_deliberately_absent",
      "status_zero_with_registered_unknown_command",
      "item_only_unit_slope_pcm_reduction",
      "item_only_multiple_nonunit_slopes_intercept_population",
      "item_only_multiple_nonunit_slopes_one_covariate",
      "generalised_item_scores_do_not_equal_single_facet_owner_slopes",
      "scoresfree_requested_under_unsupported_jml",
      "more_than_one_latent_dimension"
    ),
    ExpectedDisposition = c(
      rep("prospective_numeric_comparison", 11L),
      rep("reject_before_numeric_comparison", 6L),
      rep("prospective_numeric_comparison", 3L),
      rep("document_nonoverlap_no_numeric_comparison", 3L)
    ),
    FailureDenominator = c(
      rep("P2_ADDITIVE_FULL_DENOMINATOR", 16L),
      "P0_RUNTIME_CONTROL_DENOMINATOR",
      rep("P3_ITEM_ONLY_FULL_DENOMINATOR", 3L),
      rep("P3_NONOVERLAP_DENOMINATOR", 3L)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ssr_registry <- function() {
  out <- mfrmr_cq_ssr_base_rows()
  additive <- out$ComparisonStratum == "additive_rsm_pcm_mml"
  item_pcm <- out$ComparisonStratum == "item_only_pcm_mml"
  item_gpcm <- out$ComparisonStratum == "item_only_gpcm_mml"
  item_only <- item_pcm | item_gpcm
  prospective <- out$ExpectedDisposition == "prospective_numeric_comparison"
  negative <- out$ExpectedDisposition == "reject_before_numeric_comparison"
  nonoverlap <- out$ExpectedDisposition ==
    "document_nonoverlap_no_numeric_comparison"

  out$PersonCount <- ifelse(additive, 48L, ifelse(item_only, 96L, NA_integer_))
  out$RaterLevels <- ifelse(additive, 4L, 0L)
  out$CriterionLevels <- ifelse(additive, 3L, 0L)
  out$ItemLevels <- ifelse(item_only, 4L, 0L)
  out$OrderedCategoryCount <- ifelse(additive | item_only, 4L, NA_integer_)
  out$NonInterceptCovariates <- ifelse(
    additive | out$RegistryRowId == "P3-GPCM-NONUNIT-COVARIATE",
    1L,
    0L
  )
  out$ExpectedCategoryMap <- ifelse(
    additive | item_only, "0;1;2;3", "not_applicable"
  )
  out$DeliberatelyObservedCategoryMap <- "not_applicable"
  out$DeliberatelyObservedCategoryMap[
    out$RegistryRowId == "P2-NEG-UNUSED-INTERMEDIATE-CATEGORY"
  ] <- "0;2;3"
  out$DeliberatelyObservedCategoryMap[
    out$RegistryRowId == "P1-NEG-CATEGORY-MAP-MISMATCH"
  ] <- "0;1;3;4"
  out$PersonUnit <- ifelse(
    out$ComparisonStratum == "runtime_semantics",
    "not_applicable",
    "Person"
  )
  out$ResponseRow <- ifelse(
    additive,
    "one_Person_Rater_Criterion_observation",
    ifelse(item_only, "one_Person_Item_response", "not_applicable")
  )
  out$ObservationWeightSemantics <- ifelse(
    additive | item_only,
    "unit_frequency_weight;missing_responses_not_weight_zero_rows",
    "not_applicable"
  )
  out$ActiveFacets <- ifelse(
    additive,
    "Rater(4);Criterion(3)",
    ifelse(item_only, "Item(4)", ifelse(
      out$ComparisonStratum == "many_facet_gpcm_nonoverlap",
      "Rater;Criterion;generalised_item_combination",
      "not_applicable"
    ))
  )
  out$FacetSigns <- ifelse(
    additive,
    "theta-rater_severity-criterion_difficulty",
    ifelse(item_only, "theta-item_location", "not_applicable")
  )
  out$FacetConstraints <- ifelse(
    additive,
    "sum_rater=0;sum_criterion=0",
    ifelse(item_only, "sum_item_location=0", "not_applicable")
  )
  out$StepStructure <- ifelse(
    out$Family == "RSM",
    "shared_three_transition_ladder;sum_steps=0",
    ifelse(
      additive & out$Family == "PCM",
      "criterion_specific_three_transition_ladders;sum_within_criterion=0",
      ifelse(
        item_only,
        "item_specific_three_transition_ladders;sum_within_item=0",
        "not_applicable_or_unresolved"
      )
    )
  )
  out$SlopeOwner <- ifelse(
    out$Family %in% c("RSM", "PCM"),
    "fixed_unit",
    ifelse(item_gpcm, "Item", "not_applicable_or_unresolved")
  )
  out$StepOwner <- ifelse(
    out$Family == "RSM", "Shared",
    ifelse(additive & out$Family == "PCM", "Criterion",
           ifelse(item_only, "Item", "not_applicable_or_unresolved"))
  )
  out$SlopeAction <- ifelse(
    item_gpcm,
    "item_slope_multiplies_complete_adjacent_category_predictor",
    ifelse(out$Family %in% c("RSM", "PCM"), "unit_slope", "unresolved")
  )
  out$LatentDimensionCount <- ifelse(
    out$ComparisonStratum == "multidimensional_nonoverlap", 2L,
    ifelse(out$ComparisonStratum == "runtime_semantics", 0L, 1L)
  )
  out$PopulationFormula <- ifelse(
    additive | out$RegistryRowId == "P3-GPCM-NONUNIT-COVARIATE",
    "~1+X",
    ifelse(item_only, "~1", "not_applicable_or_unresolved")
  )
  out$CovariateCoding <- ifelse(
    out$PopulationFormula == "~1+X",
    "X_numeric_balanced_minus1_plus1",
    ifelse(out$PopulationFormula == "~1", "none", "not_applicable")
  )
  out$VarianceConvention <- ifelse(
    additive,
    "free_latent_residual_variance_in_both_engines",
    ifelse(
      item_only,
      paste0(
        "mfrmr_free_population_variance_GM_slope_1;",
        "ConQuest_latent_variance_1_free_common_Tau_scale"
      ),
      "not_applicable_or_unresolved"
    )
  )
  out$PersonInclusionRule <- ifelse(
    additive | item_only,
    "include_Person_with_at_least_one_retained_response_and_complete_X_if_used",
    "not_applicable"
  )
  out$IntegrationMethod <- ifelse(
    prospective,
    "quadrature_MML_with_common_continuous_target_oracle",
    ifelse(negative & out$ComparisonStratum == "additive_rsm_pcm_mml",
           "reject_before_or_at_declared_quadrature_arm", "not_applicable")
  )
  out$IntegrationNodeLadder <- ifelse(
    prospective & out$Priority == "P3", "31;61;121",
    ifelse(prospective, "31;61", "not_applicable")
  )
  out$IntegrationBounds <- ifelse(
    prospective,
    "engine_native_Gauss_Hermite_plus_continuous_target_reconstruction",
    "not_applicable"
  )
  out$CommonEvaluationTarget <- ifelse(
    prospective,
    "same_observed_data_marginal_loglikelihood_up_to_declared_constant",
    "not_applicable"
  )
  out$ExpectedFreeDimension <- mfrmr_cq_ssr_expected_free_dimension(
    out$ComparisonStratum,
    out$Family,
    out$RaterLevels,
    out$CriterionLevels,
    out$ItemLevels,
    out$OrderedCategoryCount,
    out$NonInterceptCovariates
  )
  out$DeliberatelyObservedFreeDimension <- NA_integer_
  mismatch <- out$RegistryRowId == "P1-NEG-FREE-DIMENSION-MISMATCH"
  out$DeliberatelyObservedFreeDimension[mismatch] <-
    out$ExpectedFreeDimension[mismatch] - 1L
  out$FreeDimensionDerivation <- ifelse(
    additive & out$Family == "RSM",
    "population(3)+rater(3)+criterion(2)+shared_step(2)=10",
    ifelse(
      additive & out$Family == "PCM",
      "population(3)+rater(3)+criterion(2)+criterion_step(6)=14",
      ifelse(
        item_pcm,
        "population(2)+item_location(3)+item_step(8)=13",
        ifelse(
          item_gpcm & out$NonInterceptCovariates == 0L,
          "population(2)+item_location(3)+log_slope(3)+item_step(8)=16",
          ifelse(
            item_gpcm & out$NonInterceptCovariates == 1L,
            "population(3)+item_location(3)+log_slope(3)+item_step(8)=17",
            "not_applicable_or_unresolved"
          )
        )
      )
    )
  )
  out$DesignMatrixContract <- ifelse(
    prospective,
    "independent_A_and_C_matrix_reconstruction_required_fixture_pending",
    ifelse(negative, "negative_control_mismatch_or_rejection_required",
           "numeric_design_matrix_comparison_ineligible")
  )
  out$OptimizerControls <- ifelse(
    prospective,
    paste0(
      "iterations=2000;parameter_convergence=1e-8;",
      "deviance_change=1e-10;termination_history_required"
    ),
    "not_applicable_or_reject_before_interpretation"
  )
  out$BoundaryConvention <- ifelse(
    grepl("EXTREME-PERSON", out$RegistryRowId, fixed = TRUE),
    "type_finite_unbounded_adjusted_display_and_posterior_separately",
    ifelse(
      grepl("RARE-BOUNDARY", out$RegistryRowId, fixed = TRUE),
      "rare_observed_boundary_category_no_unobserved_transition",
      ifelse(prospective, "finite_nonboundary_primary;typed_failure_retained",
             "reject_or_document_without_finite_number_substitution")
    )
  )
  out$RawTokenPrecision <- ifelse(
    prospective,
    "retain_raw_export_token;reported_resolution_typed;no_hidden_digits",
    "not_applicable"
  )
  out$NumericalUnits <- ifelse(
    prospective,
    "common_coordinate;positive_deviance;fitted_probability",
    "not_applicable"
  )
  out$EligibleParametersAndDecisions <- ifelse(
    prospective & out$Priority == "P2",
    paste0(
      "population;rater;criterion;step;deviance;probability;eligible_EAP_SD;",
      "ordering_ties;readiness_and_reporting_consequences"
    ),
    ifelse(
      prospective & out$Priority == "P3",
      paste0(
        "population_scale;relative_slope;item_location;transition_step;",
        "deviance;probability;item_only_support_boundary"
      ),
      "none_numeric;rejection_or_nonoverlap_decision_only"
    )
  )
  out$DecisionConsequence <- c(
    "decide_connected_sparse_additive_RSM_support",
    "decide_connected_sparse_additive_PCM_support",
    "decide_weak_bridge_sensitivity_caveat_for_RSM",
    "decide_weak_bridge_sensitivity_caveat_for_PCM",
    "decide_unequal_workload_RSM_ordering_and_reporting_caveat",
    "decide_unequal_workload_PCM_ordering_and_reporting_caveat",
    "decide_planned_absence_semantics",
    "decide_explicit_missing_value_semantics_against_paired_planned_absence",
    "decide_rare_boundary_category_support_or_caveat",
    "establish_nonextreme_person_reference_stratum",
    "decide_extreme_person_status_and_reporting_compatibility",
    "prove_unused_intermediate_category_is_rejected_or_typed_ineligible",
    "prove_disconnected_design_stops_before_numerical_agreement",
    "prove_category_map_mismatch_is_ineligible",
    "prove_free_dimension_mismatch_is_ineligible",
    "prove_missing_required_output_remains_in_complete_denominator",
    "prove_status_zero_semantic_failure_is_not_runtime_success",
    "decide_exact_item_only_PCM_reduction_support",
    "decide_item_only_intercept_population_GPCM_support",
    "decide_item_only_covariate_GPCM_support",
    "retain_no_many_facet_owner_equivalence_claim",
    "retain_no_ConQuest_JML_scoresfree_claim",
    "retain_unidimensional_scope_no_dimension_transfer"
  )
  out$ClaimCeiling <- ifelse(
    prospective,
    paste0("only_this_declared_row_and_paired_metric_envelope;",
           "no_general_software_interchangeability"),
    ifelse(negative, "failure_path_only_no_numeric_claim",
           "documented_nonoverlap_or_unsupported_only")
  )
  out$ExpectedOutputCount <- ifelse(prospective, 8L, 0L)
  out$ExpectedOutputSchema <- ifelse(
    prospective,
    paste0(
      "console;parameters;regression;covariance;amatrix;cmatrix;",
      "iteration_history;case_estimates"
    ),
    "not_applicable"
  )
  out$DeliberatelyObservedOutputCount <- NA_integer_
  missing_output <- out$RegistryRowId == "P1-NEG-MISSING-OUTPUT"
  out$ExpectedOutputCount[missing_output] <- 8L
  out$ExpectedOutputSchema[missing_output] <- paste0(
    "console;parameters;regression;covariance;amatrix;cmatrix;",
    "iteration_history;case_estimates"
  )
  out$DeliberatelyObservedOutputCount[missing_output] <- 7L
  out$AcceptedTerminationEvidence <- ifelse(
    prospective,
    paste0(
      "exit_status_0;terminal_marker;no_registered_semantic_error;",
      "complete_output_schema;history_export_final_vector_consistent"
    ),
    ifelse(negative, "expected_typed_rejection", "not_applicable")
  )
  out$AllowedObservedOutcomes <- ifelse(
    prospective,
    paste(c(
      "eligible",
      "runtime_unavailable_or_expired",
      "semantic_execution_failure",
      "model_identity_mismatch",
      "structurally_unidentified",
      "external_nonconvergence",
      "mfrmr_optimizer_or_readiness_review",
      "boundary_convention_mismatch",
      "reported_resolution_limited",
      "integration_unresolved",
      "numerical_disagreement",
      "implementation_defect",
      "unknown"
    ), collapse = ";"),
    ifelse(
      negative,
      "expected_typed_rejection;unexpected_control_acceptance",
      "documented_nonoverlap_or_unsupported"
    )
  )
  out$FixtureIdentityStatus <- ifelse(
    prospective,
    "pending_disjoint_fixture_binding",
    ifelse(negative, "deterministic_negative_control_defined",
           "not_applicable")
  )
  out$MatrixReconstructionStatus <- ifelse(
    prospective,
    "pending_fixture_A_C_reconstruction",
    ifelse(negative, "negative_control_rule_defined", "not_applicable")
  )
  out$SemanticSignatureFrozen <- TRUE
  out$MetricSpecificRuleFrozen <- !prospective
  out$ExternalExecutionAuthorized <- FALSE
  out$ComparisonPassed <- FALSE
  out$ScientificEquivalenceInferred <- FALSE
  out
}

mfrmr_cq_ssr_required_negative_controls <- function() {
  c(
    "P2-NEG-UNUSED-INTERMEDIATE-CATEGORY",
    "P2-NEG-DISCONNECTED-DESIGN",
    "P1-NEG-CATEGORY-MAP-MISMATCH",
    "P1-NEG-FREE-DIMENSION-MISMATCH",
    "P1-NEG-MISSING-OUTPUT",
    "P1-NEG-STATUS-ZERO-SEMANTIC-FAILURE"
  )
}

mfrmr_cq_ssr_human_signature <- function(
    registry_row_id, registry = mfrmr_cq_ssr_registry()) {
  mfrmr_cq_ssr_assert(
    is.character(registry_row_id) && length(registry_row_id) == 1L &&
      !is.na(registry_row_id) && nzchar(registry_row_id),
    "`registry_row_id` must identify one registry row."
  )
  index <- which(registry$RegistryRowId == registry_row_id)
  mfrmr_cq_ssr_assert(
    length(index) == 1L, "`registry_row_id` is absent or duplicated."
  )
  fields <- c(
    "RegistryRowId", "ComparisonStratum", "Family", "DesignCase",
    "ExpectedCategoryMap", "PersonUnit", "ResponseRow",
    "ObservationWeightSemantics", "ActiveFacets", "FacetSigns",
    "FacetConstraints", "StepStructure", "SlopeOwner", "StepOwner",
    "SlopeAction", "LatentDimensionCount", "PopulationFormula",
    "CovariateCoding", "VarianceConvention", "PersonInclusionRule",
    "IntegrationMethod", "IntegrationNodeLadder", "IntegrationBounds",
    "CommonEvaluationTarget", "ExpectedFreeDimension",
    "FreeDimensionDerivation", "DesignMatrixContract", "OptimizerControls",
    "BoundaryConvention", "RawTokenPrecision", "NumericalUnits",
    "EligibleParametersAndDecisions", "ExpectedDisposition",
    "FailureDenominator", "ExpectedOutputCount", "ExpectedOutputSchema",
    "AcceptedTerminationEvidence", "AllowedObservedOutcomes",
    "DecisionConsequence", "ClaimCeiling"
  )
  value <- vapply(registry[index, fields, drop = FALSE], function(column) {
    if (length(column) == 0L || is.na(column[1L])) "NA" else {
      as.character(column[1L])
    }
  }, character(1L))
  data.frame(Field = fields, Value = unname(value), stringsAsFactors = FALSE)
}

mfrmr_cq_ssr_validate <- function(registry = mfrmr_cq_ssr_registry()) {
  required <- names(mfrmr_cq_ssr_registry())
  mfrmr_cq_ssr_assert(
    is.data.frame(registry) && all(required %in% names(registry)),
    "The successor semantic registry does not satisfy its schema."
  )
  x <- registry[, required, drop = FALSE]
  mfrmr_cq_ssr_assert(
    nrow(x) == 23L && !anyDuplicated(x$RegistryRowId),
    "The successor semantic registry must contain 23 unique rows."
  )
  mfrmr_cq_ssr_assert(
    all(x$SemanticSignatureFrozen) &&
      !any(x$ExternalExecutionAuthorized) &&
      !any(x$ComparisonPassed) &&
      !any(x$ScientificEquivalenceInferred),
    "The registry cannot authorize execution, a pass, or equivalence."
  )
  disposition_count <- table(x$ExpectedDisposition)
  mfrmr_cq_ssr_assert(
    identical(unname(disposition_count[
      "prospective_numeric_comparison"
    ]), 14L) &&
      identical(unname(disposition_count[
        "reject_before_numeric_comparison"
      ]), 6L) &&
      identical(unname(disposition_count[
        "document_nonoverlap_no_numeric_comparison"
      ]), 3L),
    "The candidate/negative/nonoverlap partition changed."
  )
  negative <- x[x$CaseRole == "negative_control", , drop = FALSE]
  mfrmr_cq_ssr_assert(
    setequal(negative$RegistryRowId,
             mfrmr_cq_ssr_required_negative_controls()) &&
      all(negative$ExpectedDisposition ==
            "reject_before_numeric_comparison"),
    "All six required negative controls must fail before numeric comparison."
  )
  category_control <- x[
    x$RegistryRowId == "P1-NEG-CATEGORY-MAP-MISMATCH", , drop = FALSE
  ]
  mfrmr_cq_ssr_assert(
    nrow(category_control) == 1L &&
      category_control$ExpectedCategoryMap !=
        category_control$DeliberatelyObservedCategoryMap,
    "The category-map negative control no longer contains a mismatch."
  )
  dimension_control <- x[
    x$RegistryRowId == "P1-NEG-FREE-DIMENSION-MISMATCH", , drop = FALSE
  ]
  mfrmr_cq_ssr_assert(
    nrow(dimension_control) == 1L &&
      dimension_control$ExpectedFreeDimension !=
        dimension_control$DeliberatelyObservedFreeDimension,
    "The free-dimension negative control no longer contains a mismatch."
  )
  output_control <- x[
    x$RegistryRowId == "P1-NEG-MISSING-OUTPUT", , drop = FALSE
  ]
  mfrmr_cq_ssr_assert(
    nrow(output_control) == 1L &&
      output_control$DeliberatelyObservedOutputCount <
        output_control$ExpectedOutputCount,
    "The missing-output negative control is no longer incomplete."
  )
  calculated <- mfrmr_cq_ssr_expected_free_dimension(
    x$ComparisonStratum,
    x$Family,
    x$RaterLevels,
    x$CriterionLevels,
    x$ItemLevels,
    x$OrderedCategoryCount,
    x$NonInterceptCovariates
  )
  dimension_applicable <- !is.na(x$ExpectedFreeDimension)
  mfrmr_cq_ssr_assert(
    identical(calculated[dimension_applicable],
              x$ExpectedFreeDimension[dimension_applicable]),
    "At least one expected free dimension is not independently reproducible."
  )
  mfrmr_cq_ssr_assert(
    all(nzchar(x$DecisionConsequence)) &&
      all(nzchar(x$FailureDenominator)) &&
      all(nzchar(x$ClaimCeiling)) &&
      all(nzchar(x$ExpectedOutputSchema)) &&
      all(nzchar(x$AcceptedTerminationEvidence)) &&
      all(nzchar(x$AllowedObservedOutcomes)),
    "Every registry row must retain a decision, denominator, and claim ceiling."
  )
  prospective <- x$ExpectedDisposition == "prospective_numeric_comparison"
  p1_ready <- all(x$SemanticSignatureFrozen) &&
    all(x$FixtureIdentityStatus[prospective] == "fixture_bound") &&
    all(x$MatrixReconstructionStatus[prospective] ==
          "independent_A_C_reconstruction_passed") &&
    all(x$MetricSpecificRuleFrozen[prospective])
  denominator <- as.data.frame(table(
    FailureDenominator = x$FailureDenominator,
    ExpectedDisposition = x$ExpectedDisposition
  ), stringsAsFactors = FALSE)
  denominator <- denominator[denominator$Freq > 0L, , drop = FALSE]
  rownames(denominator) <- NULL
  list(
    specification = mfrmr_cq_ssr_specification,
    contract_version = mfrmr_cq_ssr_contract,
    status = if (p1_ready) {
      "successor_semantic_registry_P1_ready"
    } else {
      "semantic_registry_ready_fixture_matrices_and_numeric_rules_pending"
    },
    registry = x,
    denominator = denominator,
    semantic_signature_ready = all(x$SemanticSignatureFrozen),
    negative_controls_ready = nrow(negative) == 6L,
    fixture_identity_ready = all(
      x$FixtureIdentityStatus[prospective] == "fixture_bound"
    ),
    matrix_reconstruction_ready = all(
      x$MatrixReconstructionStatus[prospective] ==
        "independent_A_C_reconstruction_passed"
    ),
    metric_specific_rules_ready = all(
      x$MetricSpecificRuleFrozen[prospective]
    ),
    P1_ready = p1_ready,
    external_execution_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
