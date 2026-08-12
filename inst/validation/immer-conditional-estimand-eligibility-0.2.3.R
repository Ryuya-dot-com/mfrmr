# Deterministic estimand-eligibility contract for immer CML and CCML.
# This file runs no estimator. It keeps structural parameter compatibility
# separate from likelihood/objective and person/population compatibility.

mfrmr_icee_specification <-
  "0.2.3-wave-c-immer-conditional-estimand-eligibility-v1"
mfrmr_icee_contract <- "mfrmr_immer_conditional_estimand_eligibility_v1"
mfrmr_icee_expected_version <- "1.5.13"
mfrmr_icee_expected_function_sha256 <- c(
  CML = "4fd1943ef2929ca970df224003828d713c81bf53231dc207b5607f45c0178bc5",
  CCML = "df46616ffccb99dbda4f461ad2677b39af97468f0c744889aec040d2ad6f78b8"
)

mfrmr_icee_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_icee_function_hash <- function(fun) {
  digest::digest(
    list(formals = formals(fun), body = body(fun)),
    algo = "sha256", serialize = TRUE
  )
}

mfrmr_icee_runtime_identity <- function() {
  mfrmr_icee_assert(
    requireNamespace("immer", quietly = TRUE) &&
      requireNamespace("digest", quietly = TRUE),
    "The immer estimand contract requires `immer` and `digest`."
  )
  functions <- c(CML = "immer_cml", CCML = "immer_ccml")
  observed <- vapply(functions, function(name) {
    mfrmr_icee_function_hash(get(name, asNamespace("immer")))
  }, character(1L))
  version <- as.character(utils::packageVersion("immer"))
  data.frame(
    Route = names(functions),
    Package = "immer",
    PackageVersion = version,
    ExpectedPackageVersion = mfrmr_icee_expected_version,
    PrimaryFunction = unname(functions),
    FunctionSHA256 = unname(observed),
    ExpectedFunctionSHA256 = unname(mfrmr_icee_expected_function_sha256),
    VersionMatch = version == mfrmr_icee_expected_version,
    FunctionMatch = unname(observed) ==
      unname(mfrmr_icee_expected_function_sha256),
    HelpTopic = unname(functions),
    stringsAsFactors = FALSE
  )
}

mfrmr_icee_registry <- function() {
  route <- rep(c("CML", "CCML"), each = 11L)
  estimand <- rep(c(
    "item_location_contrast", "shared_step_contrast",
    "criterion_specific_step_contrast", "rater_severity_contrast",
    "person_ability", "population_intercept", "population_regression_slope",
    "population_variance", "free_discrimination", "objective_value",
    "structural_covariance"
  ), times = 2L)
  class <- rep(c(
    rep("structural_parameter", 4L), "person_parameter",
    rep("population_parameter", 3L), "slope_parameter", "objective",
    "uncertainty"
  ), times = 2L)
  structural <- class == "structural_parameter"
  eliminated <- class %in% c("person_parameter", "population_parameter")
  slope <- class == "slope_parameter"
  objective <- class == "objective"
  uncertainty <- class == "uncertainty"
  conditional_basis <- ifelse(
    route == "CML",
    "full_conditional_likelihood_given_person_score",
    "pairwise_composite_conditional_likelihood_given_pair_score"
  )
  availability <- ifelse(
    structural,
    "available_only_when_exact_W_or_A_coordinate_is_encoded",
    ifelse(
      eliminated, "eliminated_by_conditioning",
      ifelse(
        slope,
        ifelse(route == "CML", "fixed_integer_only_not_estimated", "fixed_unit"),
        ifelse(objective, conditional_basis,
               "reported_but_covariance_basis_requires_separate_contract")
      )
    )
  )
  exact_structural_eligible <- structural
  exact_mfrmr_objective_eligible <- rep(FALSE, length(route))
  reason <- ifelse(
    structural, "exact_design_and_constraint_map_required",
    ifelse(
      eliminated, "estimand_eliminated_by_conditioning",
      ifelse(
        slope, "free_slope_not_estimated_by_route",
        ifelse(
          objective,
          ifelse(
            route == "CML", "conditional_objective_not_mml_or_jml_objective",
            "composite_conditional_objective_not_full_likelihood"
          ),
          ifelse(
            route == "CML", "conditional_covariance_basis_not_yet_normalized",
            "composite_covariance_basis_not_yet_normalized"
          )
        )
      )
    )
  )
  data.frame(
    Route = route,
    Function = ifelse(route == "CML", "immer_cml", "immer_ccml"),
    Estimator = ifelse(
      route == "CML", "conditional_maximum_likelihood",
      "composite_conditional_maximum_likelihood"
    ),
    ConditioningBasis = conditional_basis,
    Estimand = estimand,
    EstimandClass = class,
    Availability = availability,
    ExactStructuralEstimandEligible = exact_structural_eligible,
    ExactMfrmrObjectiveEligible = exact_mfrmr_objective_eligible,
    ReasonCode = reason,
    RequiresExactDesignMatrix = structural,
    RequiresMatchedCategorySupport = structural,
    RequiresMatchedConstraintTransform = structural,
    RequiresCovarianceBasisContract = uncertainty,
    CanValidatePersonAbility = FALSE,
    CanValidatePopulationDistribution = FALSE,
    CanValidateFreeGPCMSlope = FALSE,
    CanEnterMMLOrJMLObjectiveAggregate = FALSE,
    EvidenceRole = "structural_reference_only_until_candidate",
    stringsAsFactors = FALSE
  )
}

mfrmr_icee_review <- function() {
  runtime <- mfrmr_icee_runtime_identity()
  registry <- mfrmr_icee_registry()
  identity_ok <- all(runtime$VersionMatch) && all(runtime$FunctionMatch)
  registry_ok <- nrow(registry) == 22L &&
    identical(as.integer(table(registry$Route)[c("CCML", "CML")]), c(11L, 11L)) &&
    sum(registry$ExactStructuralEstimandEligible) == 8L &&
    !any(registry$ExactStructuralEstimandEligible &
           registry$EstimandClass != "structural_parameter") &&
    !any(registry$ExactMfrmrObjectiveEligible) &&
    !any(registry$CanValidatePersonAbility) &&
    !any(registry$CanValidatePopulationDistribution) &&
    !any(registry$CanValidateFreeGPCMSlope) &&
    !any(registry$CanEnterMMLOrJMLObjectiveAggregate)
  ready <- identity_ok && registry_ok
  list(
    specification = mfrmr_icee_specification,
    contract_version = mfrmr_icee_contract,
    status = if (ready) {
      "immer_conditional_estimand_boundary_ready_candidate_missing"
    } else {
      "immer_conditional_estimand_boundary_invalid"
    },
    runtime_identity = runtime,
    registry = registry,
    boundary_ready = ready,
    structural_estimand_rows = sum(registry$ExactStructuralEstimandEligible),
    exact_objective_rows = sum(registry$ExactMfrmrObjectiveEligible),
    fitted_comparison_run = FALSE,
    tolerance_frozen = FALSE,
    candidate_bound = FALSE,
    comparison_passed = FALSE,
    scientific_equivalence_inferred = FALSE,
    native_mfrmr_cml_claim = FALSE,
    native_mfrmr_ccml_claim = FALSE,
    free_gpcm_slope_claim = FALSE,
    dff_fit_rank_invariance_evaluated = FALSE,
    large_simulation_authorized = FALSE,
    release_authorized = FALSE
  )
}
