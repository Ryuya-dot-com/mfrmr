# Prospective ADEMP contract for paired PCM/GPCM comparison simulation.
#
# Repository-only: this freezes aims, data-generating strata, estimands,
# methods, performance measures, paired identities, and failure denominators.
# It runs no fit and authorizes neither the feasibility pilot nor confirmation.

mfrmr_pgac_specification <- "0.2.3-draft.2"
mfrmr_pgac_contract <- "mfrmr_pcm_gpcm_comparison_ademp_contract_v1"

mfrmr_pgac_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_pgac_require_digest <- function() {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for the ADEMP registry identity.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_pgac_factor_catalog <- function() {
  data.frame(
    FactorId = c(
      "slope_owner", "slope_regime", "person_count", "rater_count",
      "criterion_count", "category_count", "assignment_topology",
      "workload_balance", "ability_range", "category_support",
      "estimator_lane"
    ),
    RegisteredLevels = c(
      "Criterion;Rater", "unit_slopes;near_flat;moderate;strong",
      "40;100;300", "4", "4", "4",
      "complete;sparse_linked;complete_postdrop",
      "balanced;moderate_imbalance", "ordinary;restricted",
      "ordinary;rare_endpoint", "JML;MML"
    ),
    ADEMPComponent = c(rep("Data-generating mechanism", 10L), "Methods"),
    FullFactorial = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_pgac_truth_registry <- function() {
  data.frame(
    SlopeRegime = c("unit_slopes", "near_flat", "moderate", "strong"),
    CenteredLogSlopeRule = c(
      "all_zero", "equally_spaced_plus_minus_log_1.04",
      "equally_spaced_plus_minus_0.25",
      "equally_spaced_plus_minus_0.60"
    ),
    MaxAbsCenteredLogSlope = c(0, log(1.04), 0.25, 0.60),
    KernelTruthModel = c("PCM", "GPCM", "GPCM", "GPCM"),
    PracticalDecisionTarget = c(
      "PCM", "indifference_band", "GPCM", "GPCM"
    ),
    ExactTruthSelectionScored = c(TRUE, FALSE, TRUE, TRUE),
    PracticalSelectionScored = c(TRUE, FALSE, TRUE, TRUE),
    Interpretation = c(
      "Exact unit-slope PCM reduction; extra fitted slope dispersion is false structure.",
      "Mathematically non-unit GPCM but inside the declared five-percent practical indifference band.",
      "Material non-unit GPCM weighting condition.",
      "Strong non-unit GPCM weighting stress condition."
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_pgac_method_registry <- function() {
  data.frame(
    EstimatorLane = c("JML", "MML"),
    PCMMethodId = c("PCM-JML", "PCM-MML-DIRECT-Q61"),
    GPCMMethodId = c("GPCM-JML", "GPCM-MML-DIRECT-Q61"),
    PersonTreatment = c("joint_fixed_coordinates", "integrated_random_effect"),
    Maxit = 400L,
    FitQuadPoints = c(NA_integer_, 61L),
    CommonEvaluationQuadPoints = c(NA_integer_, 91L),
    DescriptiveLikelihoodDifferenceEligible = TRUE,
    InformationCriterionMetricsPlanned = c(FALSE, TRUE),
    CurrentInformationCriterionMetricsEligible = FALSE,
    LRTEligible = FALSE,
    SelectionGate = c(
      "structurally_withheld_for_JML",
      "blocked_pending_q61_q91_parameter_and_common_grid_stability"
    ),
    PrimaryUse = c(
      "readiness_recovery_within_person_prediction_and_consequence",
      "readiness_recovery_prediction_consequence_then_gated_information_criteria"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_pgac_metric_catalog <- function() {
  metric <- function(id, family, denominator, estimator = "both",
                     truth = "none", interpretation) {
    data.frame(
      MetricId = id, MetricFamily = family, DenominatorId = denominator,
      EstimatorEligibility = estimator, TruthRequirement = truth,
      Interpretation = interpretation, stringsAsFactors = FALSE
    )
  }
  do.call(rbind, list(
    metric("pair_fit_return_rate", "execution", "all_planned_pairs",
           interpretation = "Both model fits returned, divided by every planned pair."),
    metric("pcm_inference_ready_rate", "readiness", "all_planned_pairs",
           interpretation = "Inference-ready PCM arms divided by every planned pair."),
    metric("gpcm_inference_ready_rate", "readiness", "all_planned_pairs",
           interpretation = "Inference-ready GPCM arms divided by every planned pair."),
    metric("pair_inference_ready_rate", "readiness", "all_planned_pairs",
           interpretation = "Pairs with both arms ready, divided by every planned pair."),
    metric("metric_availability_rate", "execution", "metric_eligible_pairs",
           interpretation = "Finite metric values divided by all pairs eligible for that metric."),
    metric("descriptive_loglik_difference", "model_evidence", "returned_pairs",
           interpretation = "GPCM minus PCM objective; JML values are descriptive and never selection."),
    metric("aic_exact_truth_support", "model_selection", "selection_eligible_pairs",
           "MML", "exact_model_truth",
           "AIC preference agrees with the exact kernel truth; unavailable in the indifference band."),
    metric("person_bic_exact_truth_support", "model_selection", "selection_eligible_pairs",
           "MML", "exact_model_truth",
           "Person-BIC preference agrees with exact kernel truth after all MML gates."),
    metric("sabic_exact_truth_support", "model_selection", "selection_eligible_pairs",
           "MML", "exact_model_truth",
           "Sclove SABIC preference agrees with exact kernel truth after all MML gates."),
    metric("practical_decision_support", "model_selection", "selection_eligible_pairs",
           "MML", "practical_truth",
           "Information-criterion decision supports PCM or material GPCM; near-flat is not scored."),
    metric("indifference_selection_instability", "model_selection", "pair_ready_pairs",
           "MML", "indifference_band",
           "Variation of preferences inside the near-flat band; neither model is labelled correct."),
    metric("slope_log_bias", "parameter_recovery", "truth_and_value_available",
           truth = "slope_truth",
           interpretation = "Centered fitted minus true log slope, retained by owner level."),
    metric("slope_log_rmse", "parameter_recovery", "truth_and_value_available",
           truth = "slope_truth",
           interpretation = "RMSE of centered log slopes, including unit-slope truth."),
    metric("slope_rank_spearman", "parameter_recovery", "truth_and_value_available",
           truth = "nonconstant_slope_truth",
           interpretation = "Owner-level slope rank recovery; undefined under unit slopes."),
    metric("person_location_bias", "parameter_recovery", "truth_and_value_available",
           truth = "person_truth",
           interpretation = "Mean centered ability error on the generating logit scale."),
    metric("person_location_rmse", "parameter_recovery", "truth_and_value_available",
           truth = "person_truth",
           interpretation = "Centered Person ability RMSE; availability includes extreme-Person handling."),
    metric("person_rank_spearman", "parameter_recovery", "truth_and_value_available",
           truth = "person_truth",
           interpretation = "Within-replicate ability rank recovery."),
    metric("rater_location_rmse", "parameter_recovery", "truth_and_value_available",
           truth = "rater_truth",
           interpretation = "Centered rater severity RMSE."),
    metric("criterion_location_rmse", "parameter_recovery", "truth_and_value_available",
           truth = "criterion_truth",
           interpretation = "Centered criterion difficulty RMSE."),
    metric("threshold_rmse", "parameter_recovery", "truth_and_value_available",
           truth = "threshold_truth",
           interpretation = "Owner-aligned adjacent-step RMSE after the declared constraints."),
    metric("heldout_log_loss", "prediction", "heldout_scored_rows",
           interpretation = "Prespecified within-Person held-out ordered-response log loss."),
    metric("heldout_brier_score", "prediction", "heldout_scored_rows",
           interpretation = "Multicategory Brier score on the same held-out rows."),
    metric("heldout_calibration_error", "prediction", "heldout_scored_rows",
           interpretation = "Declared-bin absolute calibration error on held-out category probabilities."),
    metric("pcm_gpcm_person_rank_agreement", "substantive_consequence", "pair_ready_pairs",
           interpretation = "Spearman agreement of paired PCM and GPCM Person estimates."),
    metric("ability_cut_decision_flip_rate", "substantive_consequence", "scored_persons",
           truth = "ability_cut_zero",
           interpretation = "Fraction whose above/below theta=0 decision differs between fitted models."),
    metric("truth_classification_error", "substantive_consequence", "scored_persons",
           truth = "ability_cut_zero",
           interpretation = "Model-specific classification error against true theta above/below zero."),
    metric("criterion_information_share_rmse", "substantive_consequence", "truth_and_value_available",
           truth = "generating_information_share",
           interpretation = "RMSE of design-weighted criterion information shares against truth.")
  ))
}

mfrmr_pgac_scenario_registry <- function() {
  scenario <- function(id, owner, regime, n_person = 100L,
                       topology = "complete", stress = "none",
                       smoke = FALSE) {
    truth <- mfrmr_pgac_truth_registry()
    truth <- truth[truth$SlopeRegime == regime, , drop = FALSE]
    data.frame(
      ScenarioId = id,
      SlopeOwner = owner,
      StepOwner = owner,
      SlopeRegime = regime,
      KernelTruthModel = truth$KernelTruthModel,
      PracticalDecisionTarget = truth$PracticalDecisionTarget,
      NPerson = as.integer(n_person),
      NRater = 4L,
      NCriterion = 4L,
      NCategory = 4L,
      AssignmentTopology = topology,
      StressMechanism = stress,
      SmokeEligible = smoke,
      FeasibilityPilotReplications = 5L,
      ConfirmationReplications = NA_integer_,
      PrecisionPlanState = "confirmation_count_not_frozen",
      stringsAsFactors = FALSE
    )
  }
  rows <- list(
    scenario("PGAC-C-UNIT-N100", "Criterion", "unit_slopes", smoke = TRUE),
    scenario("PGAC-C-NEAR-N100", "Criterion", "near_flat"),
    scenario("PGAC-C-MOD-N100", "Criterion", "moderate", smoke = TRUE),
    scenario("PGAC-C-STRONG-N100", "Criterion", "strong"),
    scenario("PGAC-R-UNIT-N100", "Rater", "unit_slopes", smoke = TRUE),
    scenario("PGAC-R-NEAR-N100", "Rater", "near_flat"),
    scenario("PGAC-R-MOD-N100", "Rater", "moderate", smoke = TRUE),
    scenario("PGAC-R-STRONG-N100", "Rater", "strong"),
    scenario("PGAC-C-UNIT-N040", "Criterion", "unit_slopes", 40L),
    scenario("PGAC-C-MOD-N040", "Criterion", "moderate", 40L),
    scenario("PGAC-C-UNIT-N300", "Criterion", "unit_slopes", 300L),
    scenario("PGAC-C-MOD-N300", "Criterion", "moderate", 300L),
    scenario("PGAC-C-MOD-SPARSE", "Criterion", "moderate", 100L,
             "sparse_linked", "weak_link"),
    scenario("PGAC-R-MOD-WORKLOAD", "Rater", "moderate", 100L,
             "complete_postdrop", "moderate_rater_workload_imbalance"),
    scenario("PGAC-C-UNIT-RARE", "Criterion", "unit_slopes", 100L,
             "complete_postdrop", "rare_endpoint_category"),
    scenario("PGAC-C-STRONG-RANGE", "Criterion", "strong", 100L,
             "complete_postdrop", "ability_range_restriction")
  )
  out <- do.call(rbind, rows)
  out$SeedStart <- 614000L + seq_len(nrow(out)) * 100L
  row.names(out) <- NULL
  out
}

mfrmr_pgac_route_metrics <- function(scenarios, methods, metrics) {
  route <- merge(
    merge(
      scenarios[c("ScenarioId", "SlopeRegime")],
      methods[c(
        "EstimatorLane", "InformationCriterionMetricsPlanned",
        "CurrentInformationCriterionMetricsEligible", "SelectionGate"
      )],
      by = NULL
    ),
    metrics[c(
      "MetricId", "MetricFamily", "EstimatorEligibility", "TruthRequirement"
    )],
    by = NULL
  )
  route$EligibilityState <- "eligible_after_execution"
  mml_ic <- route$EstimatorLane == "MML" &
    route$MetricId %in% c(
      "aic_exact_truth_support", "person_bic_exact_truth_support",
      "sabic_exact_truth_support", "practical_decision_support"
    )
  route$EligibilityState[mml_ic] <-
    "blocked_pending_mml_integration_stability"
  near_exact <- route$SlopeRegime == "near_flat" &
    route$MetricId %in% c(
      "aic_exact_truth_support", "person_bic_exact_truth_support",
      "sabic_exact_truth_support", "practical_decision_support"
    )
  route$EligibilityState[near_exact] <- "not_scored_practical_indifference_band"
  not_near_instability <- route$SlopeRegime != "near_flat" &
    route$MetricId == "indifference_selection_instability"
  route$EligibilityState[not_near_instability] <-
    "not_applicable_outside_indifference_band"
  unit_rank <- route$SlopeRegime == "unit_slopes" &
    route$MetricId == "slope_rank_spearman"
  route$EligibilityState[unit_rank] <- "undefined_constant_slope_truth"
  jml_selection <- route$EstimatorLane == "JML" &
    route$MetricFamily == "model_selection"
  route$EligibilityState[jml_selection] <-
    "structurally_ineligible_JML_model_selection"
  route <- route[order(
    route$ScenarioId, match(route$EstimatorLane, c("JML", "MML")),
    route$MetricId
  ), , drop = FALSE]
  row.names(route) <- NULL
  route
}

mfrmr_pgac_registry_hash <- function(registry) {
  mfrmr_pgac_require_digest()
  digest::digest(
    registry[c(
      "FactorCatalog", "TruthRegistry", "MethodRegistry", "MetricCatalog",
      "ScenarioRegistry", "MetricRouting", "PrecisionPlan"
    )],
    algo = "sha256"
  )
}

mfrmr_pgac_precision_plan <- function() {
  data.frame(
    Stage = c("smoke", "feasibility_pilot", "confirmation"),
    ReplicationsPerScenario = c(1L, 5L, NA_integer_),
    Purpose = c(
      "software_schema_and_pairing_only",
      "runtime_failure_and_dispersion_calibration_only",
      "operating_characteristics_after_separate_authorization"
    ),
    PrecisionRule = c(
      "none", "estimate_metric_dispersion_without_selection_claim",
      "rate_MCSE_at_most_0.025_and_metric_specific_MCSE_plan"
    ),
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_pgac_registry <- function() {
  factors <- mfrmr_pgac_factor_catalog()
  truth <- mfrmr_pgac_truth_registry()
  methods <- mfrmr_pgac_method_registry()
  metrics <- mfrmr_pgac_metric_catalog()
  scenarios <- mfrmr_pgac_scenario_registry()
  out <- list(
    Specification = mfrmr_pgac_specification,
    Contract = mfrmr_pgac_contract,
    FactorCatalog = factors,
    TruthRegistry = truth,
    MethodRegistry = methods,
    MetricCatalog = metrics,
    ScenarioRegistry = scenarios,
    MetricRouting = mfrmr_pgac_route_metrics(scenarios, methods, metrics),
    PrecisionPlan = mfrmr_pgac_precision_plan(),
    SimulationExecuted = FALSE,
    SmokeExecutionAuthorized = FALSE,
    FeasibilityPilotAuthorized = FALSE,
    BroadSimulationAuthorized = FALSE,
    ModelSelectionEvidenceReady = FALSE,
    ConfirmationAuthorized = FALSE,
    FACETSExternalFitsIncluded = FALSE
  )
  out$RegistrySHA256 <- mfrmr_pgac_registry_hash(out)
  class(out) <- c("mfrmr_pgac_registry", "list")
  mfrmr_pgac_validate_registry(out)
  out
}

mfrmr_pgac_validate_registry <- function(registry) {
  factors <- registry$FactorCatalog
  truth <- registry$TruthRegistry
  methods <- registry$MethodRegistry
  scenarios <- registry$ScenarioRegistry
  routing <- registry$MetricRouting
  mfrmr_pgac_assert(
    is.data.frame(factors) && nrow(factors) == 11L &&
      !anyDuplicated(factors$FactorId) && all(!factors$FullFactorial),
    "The ADEMP factor catalog is incomplete or was expanded factorially."
  )
  mfrmr_pgac_assert(
    is.data.frame(truth) && nrow(truth) == 4L &&
      truth$KernelTruthModel[truth$SlopeRegime == "unit_slopes"] == "PCM" &&
      truth$PracticalDecisionTarget[truth$SlopeRegime == "near_flat"] ==
        "indifference_band",
    "Slope truth or the practical indifference band drifted."
  )
  mfrmr_pgac_assert(
    is.data.frame(methods) && nrow(methods) == 2L &&
      setequal(methods$EstimatorLane, c("JML", "MML")) &&
      all(!methods$CurrentInformationCriterionMetricsEligible) &&
      all(!methods$LRTEligible),
    "Estimator separation or the current selection gate drifted."
  )
  mfrmr_pgac_assert(
    is.data.frame(scenarios) && nrow(scenarios) == 16L &&
      !anyDuplicated(scenarios$ScenarioId) &&
      setequal(scenarios$SlopeOwner, c("Criterion", "Rater")) &&
      all(scenarios$SlopeOwner == scenarios$StepOwner) &&
      all(is.na(scenarios$ConfirmationReplications)),
    "Scenario identities, aligned ownership, or replication policy drifted."
  )
  selection <- routing$MetricFamily == "model_selection"
  mfrmr_pgac_assert(
    all(routing$EligibilityState[
      selection & routing$EstimatorLane == "JML"
    ] == "structurally_ineligible_JML_model_selection") &&
      !any(routing$EligibilityState == "eligible_model_selection"),
    "JML or ungated MML model selection was incorrectly made eligible."
  )
  mfrmr_pgac_assert(
    all(!registry$PrecisionPlan$ExecutionAuthorized) &&
      !isTRUE(registry$SimulationExecuted) &&
      !isTRUE(registry$SmokeExecutionAuthorized) &&
      !isTRUE(registry$FeasibilityPilotAuthorized) &&
      !isTRUE(registry$BroadSimulationAuthorized) &&
      !isTRUE(registry$ModelSelectionEvidenceReady) &&
      !isTRUE(registry$ConfirmationAuthorized) &&
      !isTRUE(registry$FACETSExternalFitsIncluded),
    "A design contract cannot authorize execution, selection evidence, or confirmation."
  )
  mfrmr_pgac_assert(
    identical(registry$RegistrySHA256, mfrmr_pgac_registry_hash(registry)),
    "The ADEMP registry SHA-256 identity does not match its payload."
  )
  invisible(TRUE)
}

mfrmr_pgac_execution_manifest <- function(
    registry = mfrmr_pgac_registry(), profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  scenarios <- registry$ScenarioRegistry
  if (identical(profile, "smoke")) {
    scenarios <- scenarios[scenarios$SmokeEligible, , drop = FALSE]
    repetitions <- 1L
  } else {
    repetitions <- unique(scenarios$FeasibilityPilotReplications)
    mfrmr_pgac_assert(length(repetitions) == 1L,
                      "Pilot replication counts must be common and fixed.")
  }
  base <- do.call(rbind, lapply(seq_len(nrow(scenarios)), function(i) {
    data.frame(
      ScenarioId = scenarios$ScenarioId[[i]],
      Replicate = seq_len(repetitions),
      DatasetId = sprintf(
        "%s/R%03d", scenarios$ScenarioId[[i]], seq_len(repetitions)
      ),
      Seed = scenarios$SeedStart[[i]] + seq_len(repetitions),
      stringsAsFactors = FALSE
    )
  }))
  out <- merge(
    base,
    registry$MethodRegistry[c(
      "EstimatorLane", "PCMMethodId", "GPCMMethodId", "Maxit",
      "FitQuadPoints", "CommonEvaluationQuadPoints", "SelectionGate"
    )],
    by = NULL
  )
  out$PairId <- paste(out$DatasetId, out$EstimatorLane, sep = "/")
  out$Profile <- profile
  out$RegistrySHA256 <- registry$RegistrySHA256
  out <- out[order(
    match(out$ScenarioId, scenarios$ScenarioId), out$Replicate,
    match(out$EstimatorLane, c("JML", "MML"))
  ), , drop = FALSE]
  row.names(out) <- NULL
  out
}

mfrmr_pgac_result_schema <- function() {
  list(
    PairResults = data.frame(
      PairId = character(), ScenarioId = character(), Replicate = integer(),
      DatasetId = character(), EstimatorLane = character(),
      RegistrySHA256 = character(), Generated = logical(),
      SupportAuditPassed = logical(), PCMFitAttempted = logical(),
      PCMFitReturned = logical(), PCMInferenceReady = logical(),
      GPCMFitAttempted = logical(), GPCMFitReturned = logical(),
      GPCMInferenceReady = logical(), PairComparisonBuilt = logical(),
      ICComparable = logical(), IntegrationStabilityPassed = logical(),
      FormalModelSelectionAvailable = logical(), FailureStage = character(),
      FailureCode = character(), stringsAsFactors = FALSE
    ),
    MetricResults = data.frame(
      PairId = character(), MetricId = character(), ModelArm = character(),
      TruthDefined = logical(), MetricEligible = logical(),
      ValueAvailable = logical(), Estimate = numeric(), Truth = numeric(),
      Value = numeric(), EligibilityState = character(),
      stringsAsFactors = FALSE
    ),
    FailureLedger = data.frame(
      PairId = character(), FailureStage = character(), FailureCode = character(),
      Detail = character(), stringsAsFactors = FALSE
    ),
    DenominatorSummary = data.frame(
      EstimatorLane = character(), PlannedPairs = integer(),
      RecordedPairs = integer(), UnrecordedPairs = integer(),
      GeneratedPairs = integer(), ReturnedPairs = integer(),
      PCMReadyPairs = integer(), GPCMReadyPairs = integer(),
      BothReadyPairs = integer(), ComparisonBuiltPairs = integer(),
      FormalSelectionPairs = integer(), ClassifiedFailures = integer(),
      ExactAccountingPassed = logical(), stringsAsFactors = FALSE
    )
  )
}

mfrmr_pgac_empty_pair_results <- function(manifest) {
  out <- mfrmr_pgac_result_schema()$PairResults
  out <- manifest[c(
    "PairId", "ScenarioId", "Replicate", "DatasetId", "EstimatorLane",
    "RegistrySHA256"
  )]
  out$Generated <- FALSE
  out$SupportAuditPassed <- FALSE
  out$PCMFitAttempted <- FALSE
  out$PCMFitReturned <- FALSE
  out$PCMInferenceReady <- FALSE
  out$GPCMFitAttempted <- FALSE
  out$GPCMFitReturned <- FALSE
  out$GPCMInferenceReady <- FALSE
  out$PairComparisonBuilt <- FALSE
  out$ICComparable <- FALSE
  out$IntegrationStabilityPassed <- FALSE
  out$FormalModelSelectionAvailable <- FALSE
  out$FailureStage <- "unrecorded"
  out$FailureCode <- "unrecorded"
  out
}

mfrmr_pgac_denominator_summary <- function(registry, manifest, results) {
  mfrmr_pgac_validate_registry(registry)
  mfrmr_pgac_assert(!anyDuplicated(manifest$PairId),
                    "Execution manifest contains duplicate pair identities.")
  mfrmr_pgac_assert(!anyDuplicated(results$PairId),
                    "Pair results contain duplicate identities.")
  mfrmr_pgac_assert(all(results$PairId %in% manifest$PairId),
                    "Pair results contain identities outside the manifest.")
  mfrmr_pgac_assert(
    all(results$RegistrySHA256 == registry$RegistrySHA256),
    "Pair results do not carry the exact registry hash."
  )
  monotone <-
    (!results$SupportAuditPassed | results$Generated) &
    (!results$PCMFitAttempted | results$SupportAuditPassed) &
    (!results$GPCMFitAttempted | results$SupportAuditPassed) &
    (!results$PCMFitReturned | results$PCMFitAttempted) &
    (!results$GPCMFitReturned | results$GPCMFitAttempted) &
    (!results$PCMInferenceReady | results$PCMFitReturned) &
    (!results$GPCMInferenceReady | results$GPCMFitReturned) &
    (!results$PairComparisonBuilt |
       (results$PCMFitReturned & results$GPCMFitReturned))
  mfrmr_pgac_assert(all(monotone),
                    "Pair result stages violate monotone failure accounting.")
  formal_ok <- !results$FormalModelSelectionAvailable |
    (results$EstimatorLane == "MML" & results$PCMInferenceReady &
       results$GPCMInferenceReady & results$ICComparable &
       results$IntegrationStabilityPassed)
  mfrmr_pgac_assert(all(formal_ok),
                    "Formal selection bypassed estimator, readiness, or integration gates.")
  lanes <- c("JML", "MML")
  rows <- lapply(lanes, function(lane) {
    planned <- manifest[manifest$EstimatorLane == lane, , drop = FALSE]
    observed <- results[results$EstimatorLane == lane, , drop = FALSE]
    matched <- match(planned$PairId, observed$PairId)
    recorded <- !is.na(matched)
    x <- observed[stats::na.omit(matched), , drop = FALSE]
    returned <- x$PCMFitReturned & x$GPCMFitReturned
    classified <- x$FailureStage != "none" & x$FailureCode != "none"
    data.frame(
      EstimatorLane = lane,
      PlannedPairs = nrow(planned),
      RecordedPairs = sum(recorded),
      UnrecordedPairs = sum(!recorded),
      GeneratedPairs = sum(x$Generated),
      ReturnedPairs = sum(returned),
      PCMReadyPairs = sum(x$PCMInferenceReady),
      GPCMReadyPairs = sum(x$GPCMInferenceReady),
      BothReadyPairs = sum(x$PCMInferenceReady & x$GPCMInferenceReady),
      ComparisonBuiltPairs = sum(x$PairComparisonBuilt),
      FormalSelectionPairs = sum(x$FormalModelSelectionAvailable),
      ClassifiedFailures = sum(classified),
      ExactAccountingPassed = sum(recorded) == nrow(planned) &&
        all((x$FailureStage == "none" & x$FailureCode == "none") |
              classified),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}
