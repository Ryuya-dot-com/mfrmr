# Draft.83d1 G-theory ADEMP registry and denominator prototype.
#
# Repository-internal only. This file freezes scenario, estimand, metric, and
# denominator identities before any Monte Carlo recovery result is generated.
# It fits no model and computes no release-eligible coefficient or interval.

mfrmr_gtd_require_primitives <- function() {
  if (!exists("mfrmr_gta_hash", mode = "function", inherits = TRUE)) {
    stop("Source Draft.81 before Draft.83d1: mfrmr_gta_hash is missing.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtd_factor_catalog <- function() {
  data.frame(
    FactorId = c(
      "person_count", "observations_per_person", "rater_count",
      "criterion_count", "category_count", "assignment_sparsity",
      "workload_imbalance", "endpoint_concentration", "local_dependence",
      "anchor_rate", "missingness_mechanism", "variance_state",
      "assignment_topology"
    ),
    RegisteredLevels = c(
      "30;100;300", "4;8;12;16;32;64", "2;4;6;8", "2;4;8",
      "continuous;3;5;7", "complete;0.50;0.25;0.125",
      "balanced;moderate;high", "none;moderate;high", "0;0.25;0.50",
      "0;0.25;0.50", "none;MCAR;MAR_rater_load;MNAR_score;unknown",
      "interior;near_zero;exact_zero;aliased",
      "complete;connected_cycle;connected_hub;nested;disconnected;saturated"
    ),
    ADEMPComponent = c(
      rep("Data-generating mechanism", 13L)
    ),
    Role = c(
      "sampling_information", "within_object_information", "facet_levels",
      "facet_levels", "score_support", "observed_link_density",
      "allocation_heterogeneity", "bounded_score_shape",
      "residual_covariance_misspecification",
      "calibration_linking_not_current_gstudy_operation",
      "selection_or_omission_process", "regularity",
      "incidence_and_identification"
    ),
    FullFactorial = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtd_metric_catalog <- function() {
  data.frame(
    MetricId = c(
      "component_bias", "component_rmse", "component_se_coverage",
      "component_interval_width", "person_rank_spearman",
      "facet_level_rank_spearman", "facet_level_rmse",
      "gt_effect_recovery_ratio", "g_coefficient_bias",
      "g_coefficient_rmse", "g_coefficient_coverage",
      "phi_coefficient_bias", "phi_coefficient_rmse",
      "phi_coefficient_coverage", "fit_return_rate",
      "optimizer_convergence_rate", "estimation_gate_rate",
      "false_ready_rate", "metric_availability_rate",
      "failed_cell_accounting"
    ),
    MetricFamily = c(
      rep("component_recovery", 4L), "object_rank_recovery",
      rep("facet_effect_recovery", 3L), rep("coefficient_recovery", 6L),
      rep("operating_characteristic", 6L)
    ),
    DenominatorId = c(
      "truth_defined_and_value_available", "truth_defined_and_value_available",
      "truth_defined_and_interval_available", "interval_available",
      "truth_defined_and_prediction_available",
      "truth_defined_and_prediction_available",
      "truth_defined_and_prediction_available",
      "truth_defined_and_prediction_available",
      "truth_defined_and_coefficient_available",
      "truth_defined_and_coefficient_available",
      "truth_defined_and_interval_available",
      "truth_defined_and_coefficient_available",
      "truth_defined_and_coefficient_available",
      "truth_defined_and_interval_available", "fit_attempted",
      "fit_attempted", "planned_fit_units",
      "planned_fit_units_expected_not_ready", "metric_eligible",
      "planned_fit_units"
    ),
    EarliestDraft = c(
      rep("83d2", 2L), rep("84", 2L), rep("83d2", 4L),
      rep(c("83d2", "83d2", "84"), 2L), rep("83d1", 6L)
    ),
    Interpretation = c(
      "Estimate minus the declared truth on the declared target scale.",
      "Root mean squared error on the declared target scale.",
      "Coverage is unavailable until a separately validated interval exists.",
      "Width is unavailable until a separately validated interval exists.",
      "Within-dataset rank recovery for centered object effects.",
      "Within-facet rank recovery for centered facet-level effects.",
      "RMSE for centered facet-level effects.",
      paste(
        "SD of centered true facet effects divided by their prediction RMSE;",
        "this is not Rasch/FACETS separation."
      ),
      "G-coefficient estimate minus its allocation-bound truth.",
      "G-coefficient RMSE against its allocation-bound truth.",
      "G-coefficient interval coverage, deferred to Draft.84.",
      "Phi estimate minus its allocation-bound truth.",
      "Phi RMSE against its allocation-bound truth.",
      "Phi interval coverage, deferred to Draft.84.",
      "Returned fit divided by attempted fits.",
      "Optimizer-converged fits divided by attempted fits.",
      "Passed point-estimation gates divided by planned fit units.",
      "Passed gates in an expected-not-ready stratum divided by planned units.",
      "Available metric values divided by metric-eligible units.",
      "Whether every planned unit has one success or typed failure record."
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtd_scenarios <- function() {
  scenario <- function(
      id, lane, estimand, design, n_person, n_rater, n_criterion,
      observations, topology, imbalance = "balanced",
      support = "continuous", categories = NA_integer_, endpoint = "none",
      endpoint_rate = 0, local_dependence = 0, anchor_rate = 0,
      missingness = "none", missing_rate = 0, variance = "interior",
      methods = "lme4_reml;glmmTMB_reml;lme4_ml;glmmTMB_ml",
      profile = "point_recovery", target = "generating_gaussian_components",
      expected_state = "eligible_interior", executable = "executable_smoke") {
    density <- observations / (n_rater * n_criterion)
    data.frame(
      ScenarioId = id, Lane = lane, EstimandId = estimand,
      DesignFamily = design, NPerson = as.integer(n_person),
      NRater = as.integer(n_rater), NCriterion = as.integer(n_criterion),
      ObservationsPerPerson = as.integer(observations),
      AssignmentTopology = topology, AssignmentDensity = density,
      WorkloadImbalance = imbalance, ScoreSupport = support,
      CategoryCount = as.integer(categories),
      EndpointConcentration = endpoint, EndpointRateTarget = endpoint_rate,
      LocalDependenceRho = local_dependence, AnchorRate = anchor_rate,
      MissingnessMechanism = missingness, MissingRate = missing_rate,
      VarianceState = variance, MethodSet = methods, MetricProfile = profile,
      TargetBasis = target, ExpectedDesignState = expected_state,
      ExecutionEligibility = executable, SmokeReplications = 1L,
      PilotReplications = NA_integer_, ConfirmationReplications = NA_integer_,
      PrecisionPlanState = "not_frozen", InferenceState = "point_only_no_interval",
      stringsAsFactors = FALSE
    )
  }

  rows <- list(
    scenario("GT-EXACT-N030", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "crossed_pxrxi", 30, 4, 4, 16, "complete",
             methods = paste(c("balanced_mom", "lme4_reml", "glmmTMB_reml",
                               "lme4_ml", "glmmTMB_ml"), collapse = ";")),
    scenario("GT-EXACT-N100", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "crossed_pxrxi", 100, 8, 4, 32, "complete"),
    scenario("GT-EXACT-N300", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "crossed_pxrxi", 300, 8, 8, 64, "complete"),
    scenario("GT-EXACT-R02-C02", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "crossed_pxrxi", 100, 2, 2, 4, "complete"),
    scenario("GT-SPARSE-CYCLE-LOW", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "crossed_pxrxi", 100, 8, 4, 4, "connected_cycle"),
    scenario("GT-SPARSE-CYCLE-MID", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "crossed_pxrxi", 100, 8, 4, 16, "connected_cycle"),
    scenario("GT-IMBAL-HUB-MOD", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "crossed_pxrxi", 100, 8, 4, 8, "connected_hub", "moderate"),
    scenario("GT-IMBAL-HUB-HIGH", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "crossed_pxrxi", 100, 8, 4, 8, "connected_hub", "high"),
    scenario("GT-NESTED-BAL", "gaussian_exact_recovery", "GT-GAUSS-COMP",
             "nested_site_rater", 100, 6, 2, 12, "nested"),
    scenario("GT-MISS-MCAR", "missingness_sensitivity", "GT-GAUSS-COMP-MISS",
             "crossed_pxrxi", 100, 4, 4, 16, "complete",
             missingness = "MCAR", missing_rate = 0.20,
             profile = "selection_sensitivity"),
    scenario("GT-MISS-MAR", "missingness_sensitivity", "GT-GAUSS-COMP-MISS",
             "crossed_pxrxi", 100, 8, 4, 8, "connected_hub", "moderate",
             missingness = "MAR_rater_load", missing_rate = 0.20,
             profile = "selection_sensitivity"),
    scenario("GT-MISS-MNAR", "missingness_sensitivity", "GT-GAUSS-COMP-MISS",
             "crossed_pxrxi", 100, 8, 4, 8, "connected_hub", "moderate",
             missingness = "MNAR_score", missing_rate = 0.20,
             profile = "selection_sensitivity"),
    scenario("GT-MISS-UNKNOWN", "missingness_sensitivity", "GT-GAUSS-COMP-MISS",
             "crossed_pxrxi", 100, 8, 4, 8, "connected_hub", "high",
             missingness = "unknown", missing_rate = 0.20,
             profile = "selection_sensitivity"),
    scenario("GT-BOUNDED-K03-ENDHI", "bounded_score_projection",
             "GT-OBS-PROJECTION", "crossed_pxrxi", 100, 4, 4, 16,
             "complete", support = "bounded_ordinal", categories = 3,
             endpoint = "high", endpoint_rate = 0.50,
             profile = "projection_recovery",
             target = "full_potential_observed_score_projection"),
    scenario("GT-BOUNDED-K05-ENDMOD", "bounded_score_projection",
             "GT-OBS-PROJECTION", "crossed_pxrxi", 100, 4, 4, 16,
             "complete", support = "bounded_ordinal", categories = 5,
             endpoint = "moderate", endpoint_rate = 0.25,
             profile = "projection_recovery",
             target = "full_potential_observed_score_projection"),
    scenario("GT-BOUNDED-K07-ENDNONE", "bounded_score_projection",
             "GT-OBS-PROJECTION", "crossed_pxrxi", 100, 4, 4, 16,
             "complete", support = "bounded_ordinal", categories = 7,
             endpoint = "none", endpoint_rate = 0,
             profile = "projection_recovery",
             target = "full_potential_observed_score_projection"),
    scenario("GT-LD-RHO025", "local_dependence_sensitivity", "GT-LD-REFERENCE",
             "crossed_pxrxi", 100, 4, 4, 16, "complete",
             local_dependence = 0.25, profile = "reference_deviation",
             target = "independence_model_reference_not_component_truth"),
    scenario("GT-LD-RHO050", "local_dependence_sensitivity", "GT-LD-REFERENCE",
             "crossed_pxrxi", 100, 4, 4, 16, "complete",
             local_dependence = 0.50, profile = "reference_deviation",
             target = "independence_model_reference_not_component_truth"),
    scenario("GT-BOUNDARY-NEARZERO", "boundary_recovery", "GT-GAUSS-BOUNDARY",
             "crossed_pxrxi", 100, 4, 4, 16, "complete",
             variance = "near_zero", profile = "boundary_stratified",
             expected_state = "must_fail_ready_gate"),
    scenario("GT-BOUNDARY-ZERO", "boundary_recovery", "GT-GAUSS-BOUNDARY",
             "crossed_pxrxi", 100, 4, 4, 16, "complete",
             variance = "exact_zero", profile = "boundary_stratified",
             expected_state = "must_fail_ready_gate"),
    scenario("GT-NEG-DISCONNECTED", "identification_negative_control",
             "GT-NO-ESTIMAND", "crossed_pxrxi", 100, 8, 4, 4,
             "disconnected", profile = "false_ready_only", target = "none",
             expected_state = "must_fail_ready_gate"),
    scenario("GT-NEG-ALIASED", "identification_negative_control",
             "GT-NO-ESTIMAND", "saturated_unreplicated", 100, 4, 4, 16,
             "saturated", variance = "aliased", profile = "false_ready_only",
             target = "none", expected_state = "must_fail_ready_gate"),
    scenario("GT-ANCHOR-025", "anchor_nonapplicability", "GT-NOT-APPLICABLE",
             "crossed_pxrxi", 100, 4, 4, 16, "complete",
             anchor_rate = 0.25, methods = "none", profile = "blocked_semantics",
             target = "none", expected_state = "blocked_not_applicable",
             executable = "blocked_anchor_not_gstudy_operation"),
    scenario("GT-ANCHOR-050", "anchor_nonapplicability", "GT-NOT-APPLICABLE",
             "crossed_pxrxi", 100, 4, 4, 16, "complete",
             anchor_rate = 0.50, methods = "none", profile = "blocked_semantics",
             target = "none", expected_state = "blocked_not_applicable",
             executable = "blocked_anchor_not_gstudy_operation")
  )
  scenarios <- do.call(rbind, rows)
  scenarios$SeedStart <- 830100L + seq_len(nrow(scenarios)) * 1000L
  row.names(scenarios) <- NULL
  scenarios
}

mfrmr_gtd_route_metrics <- function(scenarios, metrics) {
  routing <- merge(
    scenarios[c("ScenarioId", "Lane", "MetricProfile", "ExecutionEligibility")],
    metrics[c("MetricId", "DenominatorId", "EarliestDraft")],
    by = NULL, sort = FALSE
  )
  routing$EligibilityState <- "not_applicable"
  executable <- routing$ExecutionEligibility == "executable_smoke"
  operating <- routing$MetricId %in% c(
    "fit_return_rate", "optimizer_convergence_rate", "estimation_gate_rate",
    "metric_availability_rate", "failed_cell_accounting"
  )
  routing$EligibilityState[executable & operating] <- "eligible_draft83d1"

  negative <- routing$Lane %in% c(
    "identification_negative_control", "boundary_recovery"
  )
  routing$EligibilityState[
    executable & negative & routing$MetricId == "false_ready_rate"
  ] <- "eligible_draft83d1"

  component_point <- routing$MetricId %in% c("component_bias", "component_rmse")
  gaussian_truth <- routing$Lane %in% c(
    "gaussian_exact_recovery", "missingness_sensitivity", "boundary_recovery"
  )
  routing$EligibilityState[executable & gaussian_truth & component_point] <-
    "truth_defined_deferred_draft83d2"
  routing$EligibilityState[
    executable & routing$Lane == "bounded_score_projection" & component_point
  ] <- "projection_target_only_deferred_draft83d2"
  routing$EligibilityState[
    executable & routing$Lane == "local_dependence_sensitivity" & component_point
  ] <- "reference_deviation_only_deferred_draft83d2"

  prediction <- routing$MetricId %in% c(
    "person_rank_spearman", "facet_level_rank_spearman", "facet_level_rmse",
    "gt_effect_recovery_ratio"
  )
  interpretable_prediction <- !routing$Lane %in% c(
    "identification_negative_control", "anchor_nonapplicability"
  )
  routing$EligibilityState[
    executable & interpretable_prediction & prediction
  ] <- "prediction_extraction_deferred_draft83d2"

  coefficient_point <- routing$MetricId %in% c(
    "g_coefficient_bias", "g_coefficient_rmse",
    "phi_coefficient_bias", "phi_coefficient_rmse"
  )
  routing$EligibilityState[
    executable & routing$Lane == "gaussian_exact_recovery" & coefficient_point
  ] <- "allocation_bound_deferred_draft83d2"

  interval <- routing$MetricId %in% c(
    "component_se_coverage", "component_interval_width",
    "g_coefficient_coverage", "phi_coefficient_coverage"
  )
  interval_lane <- !routing$Lane %in% c(
    "identification_negative_control", "anchor_nonapplicability",
    "local_dependence_sensitivity"
  )
  routing$EligibilityState[executable & interval_lane & interval] <-
    "no_interval_until_draft84"

  routing$EligibilityState[
    routing$Lane == "anchor_nonapplicability"
  ] <- "blocked_not_current_gstudy_operation"
  routing <- routing[order(routing$ScenarioId, routing$MetricId), , drop = FALSE]
  row.names(routing) <- NULL
  routing
}

mfrmr_gtd_validate_registry <- function(registry) {
  required <- c("FactorCatalog", "MetricCatalog", "Scenarios", "Routing")
  if (!is.list(registry) || !all(required %in% names(registry))) {
    stop("Draft.83d1 registry is missing a required table.", call. = FALSE)
  }
  factors <- registry$FactorCatalog
  metrics <- registry$MetricCatalog
  scenarios <- registry$Scenarios
  routing <- registry$Routing
  if (anyDuplicated(factors$FactorId) || anyDuplicated(metrics$MetricId) ||
      anyDuplicated(scenarios$ScenarioId)) {
    stop("Draft.83d1 registry identifiers must be unique.", call. = FALSE)
  }
  expected_factors <- c(
    "person_count", "observations_per_person", "rater_count",
    "criterion_count", "category_count", "assignment_sparsity",
    "workload_imbalance", "endpoint_concentration", "local_dependence",
    "anchor_rate", "missingness_mechanism"
  )
  if (!all(expected_factors %in% factors$FactorId)) {
    stop("The user-requested design dimensions are not all registered.",
         call. = FALSE)
  }
  if (any(!is.finite(scenarios$AssignmentDensity)) ||
      any(scenarios$AssignmentDensity <= 0 | scenarios$AssignmentDensity > 1)) {
    stop("Assignment density must be finite and in (0, 1].", call. = FALSE)
  }
  calculated_density <- scenarios$ObservationsPerPerson /
    (scenarios$NRater * scenarios$NCriterion)
  if (!isTRUE(all.equal(scenarios$AssignmentDensity, calculated_density,
                        tolerance = 1e-15))) {
    stop("Assignment density must equal observations/(raters*criteria).",
         call. = FALSE)
  }
  coverage_checks <- list(
    NPerson = c(30L, 100L, 300L),
    ObservationsPerPerson = c(4L, 8L, 12L, 16L, 32L, 64L),
    NRater = c(2L, 4L, 6L, 8L),
    NCriterion = c(2L, 4L, 8L),
    AssignmentDensity = c(0.125, 0.25, 0.50, 1.00),
    WorkloadImbalance = c("balanced", "moderate", "high"),
    EndpointConcentration = c("none", "moderate", "high"),
    LocalDependenceRho = c(0, 0.25, 0.50),
    AnchorRate = c(0, 0.25, 0.50),
    MissingnessMechanism = c(
      "none", "MCAR", "MAR_rater_load", "MNAR_score", "unknown"
    )
  )
  for (column in names(coverage_checks)) {
    if (!all(coverage_checks[[column]] %in% scenarios[[column]])) {
      stop("A registered factor level has no scenario cell: ", column, ".",
           call. = FALSE)
    }
  }
  continuous <- scenarios$ScoreSupport == "continuous"
  if (any(!is.na(scenarios$CategoryCount[continuous]))) {
    stop("Continuous-score scenarios cannot declare a category count.",
         call. = FALSE)
  }
  bounded <- scenarios$Lane == "bounded_score_projection"
  if (any(!scenarios$CategoryCount[bounded] %in% c(3L, 5L, 7L)) ||
      any(scenarios$TargetBasis[bounded] !=
          "full_potential_observed_score_projection")) {
    stop("Bounded-score cells require 3/5/7 categories and projection truth.",
         call. = FALSE)
  }
  exact <- scenarios$Lane == "gaussian_exact_recovery"
  if (any(scenarios$ScoreSupport[exact] != "continuous") ||
      any(scenarios$EndpointRateTarget[exact] != 0) ||
      any(scenarios$LocalDependenceRho[exact] != 0) ||
      any(scenarios$AnchorRate[exact] != 0) ||
      any(scenarios$MissingnessMechanism[exact] != "none")) {
    stop("Exact Gaussian recovery cells cannot contain sensitivity factors.",
         call. = FALSE)
  }
  local_dependence <- scenarios$Lane == "local_dependence_sensitivity"
  if (any(scenarios$LocalDependenceRho[local_dependence] <= 0) ||
      any(scenarios$TargetBasis[local_dependence] ==
          "generating_gaussian_components")) {
    stop("Local-dependence cells require a non-truth reference target.",
         call. = FALSE)
  }
  anchors <- scenarios$Lane == "anchor_nonapplicability"
  if (any(scenarios$AnchorRate[anchors] <= 0) ||
      any(scenarios$MethodSet[anchors] != "none") ||
      any(scenarios$ExecutionEligibility[anchors] !=
          "blocked_anchor_not_gstudy_operation")) {
    stop("Anchor-rate cells must remain explicitly blocked.", call. = FALSE)
  }
  negative <- scenarios$Lane %in% c(
    "identification_negative_control", "boundary_recovery"
  )
  if (any(scenarios$ExpectedDesignState[negative] != "must_fail_ready_gate")) {
    stop("Boundary and identification controls must expect no ready gate.",
         call. = FALSE)
  }
  if (any(scenarios$InferenceState != "point_only_no_interval") ||
      any(!is.na(scenarios$PilotReplications)) ||
      any(!is.na(scenarios$ConfirmationReplications)) ||
      any(scenarios$PrecisionPlanState != "not_frozen")) {
    stop("Draft.83d1 cannot pre-empt interval or replication-count gates.",
         call. = FALSE)
  }
  expected_routes <- nrow(scenarios) * nrow(metrics)
  if (nrow(routing) != expected_routes ||
      anyDuplicated(paste(routing$ScenarioId, routing$MetricId))) {
    stop("Every scenario-metric pair must have exactly one routing row.",
         call. = FALSE)
  }
  coverage <- routing$MetricId %in% c(
    "component_se_coverage", "g_coefficient_coverage",
    "phi_coefficient_coverage"
  )
  if (any(grepl("eligible_draft83d1", routing$EligibilityState[coverage],
                fixed = TRUE))) {
    stop("Coverage cannot be eligible before Draft.84 intervals.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtd_registry <- function() {
  mfrmr_gtd_require_primitives()
  factors <- mfrmr_gtd_factor_catalog()
  metrics <- mfrmr_gtd_metric_catalog()
  scenarios <- mfrmr_gtd_scenarios()
  routing <- mfrmr_gtd_route_metrics(scenarios, metrics)
  registry <- list(
    ContractVersion = "mfrmr-gtheory-ademp-registry-draft83d1-v1",
    FactorCatalog = factors,
    MetricCatalog = metrics,
    Scenarios = scenarios,
    Routing = routing,
    RegistryHash = NA_character_,
    SimulationExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )
  mfrmr_gtd_validate_registry(registry)
  registry$RegistryHash <- mfrmr_gta_hash(list(
    ContractVersion = registry$ContractVersion,
    FactorCatalog = factors, MetricCatalog = metrics,
    Scenarios = scenarios, Routing = routing
  ))
  class(registry) <- c("mfrmr_gtd_registry", "list")
  registry
}

mfrmr_gtd_method_backend <- function(method) {
  ifelse(
    method == "balanced_mom", "balanced_mom",
    ifelse(grepl("^glmmTMB_", method), "glmmTMB",
           ifelse(grepl("^lme4_", method), "lme4", NA_character_))
  )
}

mfrmr_gtd_execution_manifest <- function(registry = mfrmr_gtd_registry()) {
  mfrmr_gtd_validate_registry(registry)
  scenarios <- registry$Scenarios[
    registry$Scenarios$ExecutionEligibility == "executable_smoke", ,
    drop = FALSE
  ]
  rows <- lapply(seq_len(nrow(scenarios)), function(index) {
    scenario <- scenarios[index, , drop = FALSE]
    methods <- strsplit(scenario$MethodSet, ";", fixed = TRUE)[[1L]]
    grid <- expand.grid(
      Replicate = seq_len(scenario$SmokeReplications),
      MethodId = methods, stringsAsFactors = FALSE,
      KEEP.OUT.ATTRS = FALSE
    )
    grid$ScenarioId <- scenario$ScenarioId
    grid$DatasetId <- sprintf("%s/R%04d", scenario$ScenarioId, grid$Replicate)
    grid$Seed <- scenario$SeedStart + grid$Replicate - 1L
    grid$Backend <- mfrmr_gtd_method_backend(grid$MethodId)
    grid$RegistryHash <- registry$RegistryHash
    grid[c("ScenarioId", "Replicate", "DatasetId", "Seed", "MethodId",
           "Backend", "RegistryHash")]
  })
  manifest <- do.call(rbind, rows)
  row.names(manifest) <- NULL
  if (anyNA(manifest$Backend) ||
      anyDuplicated(paste(manifest$ScenarioId, manifest$Replicate,
                          manifest$MethodId))) {
    stop("Execution manifest contains an unknown or duplicate method.",
         call. = FALSE)
  }
  manifest
}

mfrmr_gtd_result_schema <- function() {
  list(
    DatasetResults = data.frame(
      ScenarioId = character(), Replicate = integer(), DatasetId = character(),
      Seed = integer(), MethodId = character(), Backend = character(),
      Generated = logical(), PreFitEligible = logical(),
      FitAttempted = logical(), FitReturned = logical(),
      OptimizerConverged = logical(), ComponentVectorFinite = logical(),
      EstimationGatePassed = logical(), FailureStage = character(),
      FailureCode = character(), RegistryHash = character(),
      stringsAsFactors = FALSE
    ),
    MetricResults = data.frame(
      ScenarioId = character(), Replicate = integer(), DatasetId = character(),
      MethodId = character(), Backend = character(), MetricId = character(),
      TruthDefined = logical(), MetricEligible = logical(),
      ValueAvailable = logical(), Estimate = numeric(), Truth = numeric(),
      EligibilityState = character(), RegistryHash = character(),
      stringsAsFactors = FALSE
    ),
    FailureLedger = data.frame(
      ScenarioId = character(), Replicate = integer(), DatasetId = character(),
      MethodId = character(), Backend = character(), FailureStage = character(),
      FailureCode = character(), ConditionClass = character(),
      MessageDigest = character(), RegistryHash = character(),
      stringsAsFactors = FALSE
    ),
    DenominatorSummary = data.frame(
      ScenarioId = character(), MethodId = character(), Backend = character(),
      PlannedFitUnits = integer(), RecordedResults = integer(),
      Generated = integer(), PreFitEligible = integer(), FitAttempted = integer(),
      FitReturned = integer(), OptimizerConverged = integer(),
      FiniteComponentVector = integer(), EstimationGatePassed = integer(),
      FailedCellCount = integer(), ClassifiedFailureCount = integer(),
      UnrecordedCount = integer(), FitReturnRate = numeric(),
      OptimizerConvergenceRate = numeric(), EstimationGateRate = numeric(),
      FalseReadyCount = integer(), FalseReadyRate = numeric(),
      ZeroFalseReadyPassed = logical(), ExactAccountingPassed = logical(),
      RegistryHash = character(), stringsAsFactors = FALSE
    )
  )
}

mfrmr_gtd_empty_results <- function(manifest) {
  required <- c("ScenarioId", "Replicate", "DatasetId", "Seed", "MethodId",
                "Backend", "RegistryHash")
  if (!is.data.frame(manifest) || !all(required %in% names(manifest))) {
    stop("Manifest is missing required execution identities.", call. = FALSE)
  }
  data.frame(
    manifest[required], Generated = NA, PreFitEligible = NA,
    FitAttempted = NA, FitReturned = NA, OptimizerConverged = NA,
    ComponentVectorFinite = NA, EstimationGatePassed = NA,
    FailureStage = "unrecorded", FailureCode = "result_not_recorded",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtd_safe_rate <- function(numerator, denominator) {
  if (denominator <= 0L) NA_real_ else numerator / denominator
}

mfrmr_gtd_denominator_summary <- function(registry, manifest, results) {
  mfrmr_gtd_validate_registry(registry)
  manifest_required <- c(
    "ScenarioId", "Replicate", "DatasetId", "Seed", "MethodId", "Backend",
    "RegistryHash"
  )
  result_required <- c(
    manifest_required, "Generated", "PreFitEligible", "FitAttempted",
    "FitReturned", "OptimizerConverged", "ComponentVectorFinite",
    "EstimationGatePassed", "FailureStage", "FailureCode"
  )
  if (!is.data.frame(manifest) || !all(manifest_required %in% names(manifest)) ||
      !is.data.frame(results) || !all(result_required %in% names(results))) {
    stop("Manifest or dataset results do not match the Draft.83d1 schema.",
         call. = FALSE)
  }
  key <- function(x) paste(x$ScenarioId, x$Replicate, x$MethodId, sep = "\r")
  manifest_key <- key(manifest)
  result_key <- key(results)
  if (anyDuplicated(manifest_key) || anyDuplicated(result_key) ||
      any(!result_key %in% manifest_key)) {
    stop("Result identities must be unique and contained in the manifest.",
         call. = FALSE)
  }
  if (any(manifest$RegistryHash != registry$RegistryHash) ||
      any(results$RegistryHash != registry$RegistryHash)) {
    stop("Manifest and results must retain the exact registry hash.",
         call. = FALSE)
  }
  identity_columns <- c("DatasetId", "Seed", "Backend")
  matched <- match(result_key, manifest_key)
  for (column in identity_columns) {
    if (!identical(as.character(results[[column]]),
                   as.character(manifest[[column]][matched]))) {
      stop("Result identity differs from the manifest: ", column, ".",
           call. = FALSE)
    }
  }
  flags <- c(
    "Generated", "PreFitEligible", "FitAttempted", "FitReturned",
    "OptimizerConverged", "ComponentVectorFinite", "EstimationGatePassed"
  )
  for (flag in flags) {
    if (!is.logical(results[[flag]]) || anyNA(results[[flag]])) {
      stop("Recorded result flags must be non-missing logical values: ", flag,
           ".", call. = FALSE)
    }
  }
  monotone <- results$PreFitEligible <= results$Generated &
    results$FitAttempted <= results$PreFitEligible &
    results$FitReturned <= results$FitAttempted &
    results$OptimizerConverged <= results$FitReturned &
    results$ComponentVectorFinite <= results$FitReturned &
    results$EstimationGatePassed <= results$OptimizerConverged &
    results$EstimationGatePassed <= results$ComponentVectorFinite
  if (!all(monotone)) {
    stop("Result-stage flags violate the frozen denominator ordering.",
         call. = FALSE)
  }
  success_stage <- results$FailureStage == "none" & results$FailureCode == "none"
  typed_failure <- nzchar(results$FailureStage) & nzchar(results$FailureCode) &
    results$FailureStage != "none" & results$FailureCode != "none"
  if (any(results$EstimationGatePassed & !success_stage) ||
      any(!results$EstimationGatePassed & !typed_failure)) {
    stop("Every recorded unit must contain exactly one success or typed failure.",
         call. = FALSE)
  }

  full <- manifest
  position <- match(manifest_key, result_key)
  full$Recorded <- !is.na(position)
  for (flag in flags) {
    value <- rep(FALSE, nrow(full))
    value[full$Recorded] <- results[[flag]][position[full$Recorded]]
    full[[flag]] <- value
  }
  full$FailureStage <- "unrecorded"
  full$FailureCode <- "result_not_recorded"
  full$FailureStage[full$Recorded] <-
    results$FailureStage[position[full$Recorded]]
  full$FailureCode[full$Recorded] <-
    results$FailureCode[position[full$Recorded]]

  scenario_state <- stats::setNames(
    registry$Scenarios$ExpectedDesignState, registry$Scenarios$ScenarioId
  )
  groups <- split(
    seq_len(nrow(full)),
    interaction(full$ScenarioId, full$MethodId, full$Backend, drop = TRUE,
                lex.order = TRUE)
  )
  summaries <- lapply(groups, function(index) {
    x <- full[index, , drop = FALSE]
    planned <- nrow(x)
    attempted <- sum(x$FitAttempted)
    returned <- sum(x$FitReturned)
    failed <- sum(x$Recorded & !x$EstimationGatePassed)
    classified <- sum(
      x$Recorded & !x$EstimationGatePassed &
        x$FailureStage != "none" & x$FailureStage != "unrecorded" &
        nzchar(x$FailureCode) & x$FailureCode != "none"
    )
    expected_not_ready <- scenario_state[[x$ScenarioId[[1L]]]] ==
      "must_fail_ready_gate"
    false_ready <- if (expected_not_ready) sum(x$EstimationGatePassed) else 0L
    data.frame(
      ScenarioId = x$ScenarioId[[1L]], MethodId = x$MethodId[[1L]],
      Backend = x$Backend[[1L]], PlannedFitUnits = planned,
      RecordedResults = sum(x$Recorded), Generated = sum(x$Generated),
      PreFitEligible = sum(x$PreFitEligible), FitAttempted = attempted,
      FitReturned = returned, OptimizerConverged = sum(x$OptimizerConverged),
      FiniteComponentVector = sum(x$ComponentVectorFinite),
      EstimationGatePassed = sum(x$EstimationGatePassed),
      FailedCellCount = failed, ClassifiedFailureCount = classified,
      UnrecordedCount = sum(!x$Recorded),
      FitReturnRate = mfrmr_gtd_safe_rate(returned, attempted),
      OptimizerConvergenceRate = mfrmr_gtd_safe_rate(
        sum(x$OptimizerConverged), attempted
      ),
      EstimationGateRate = sum(x$EstimationGatePassed) / planned,
      FalseReadyCount = false_ready,
      FalseReadyRate = if (expected_not_ready) false_ready / planned else NA_real_,
      ZeroFalseReadyPassed = if (expected_not_ready) false_ready == 0L else NA,
      ExactAccountingPassed = sum(x$Recorded) == planned &&
        classified == failed,
      RegistryHash = registry$RegistryHash, stringsAsFactors = FALSE
    )
  })
  summary <- do.call(rbind, summaries)
  summary <- summary[order(summary$ScenarioId, summary$MethodId), , drop = FALSE]
  row.names(summary) <- NULL
  summary
}
