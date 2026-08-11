# Draft.83d2b2b1g5 independent stationarity-calibration design.
#
# Repository-internal only. This file freezes the distinction between
# numerical stationarity, curvature, boundary escape, and statistical
# component resolution. It constructs no calibration data, fits no model,
# selects no cutoff, and authorizes no later phase.

mfrmr_gtwsz_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash",
    "mfrmr_gtwp_manifest", "mfrmr_gtwsy_scale_metrics"
  )
  design_environment <- environment(mfrmr_gtwsz_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = design_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.83d2b2b0 and b1g4 design chain before b1g5: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwsz_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwsz_source_registry <- function() {
  data.frame(
    SourceId = c(
      "kristensen_et_al_2016_tmb",
      "tmb_current_derivative_documentation",
      "lme4_current_convergence_documentation",
      "lme4_current_checkconv_source",
      "glmmtmb_current_troubleshooting",
      "nash_varadhan_2011_optimx",
      "nash_2014_best_practice",
      "self_liang_1987_boundary",
      "numderiv_current_manual"
    ),
    Locator = c(
      "https://doi.org/10.18637/jss.v070.i05",
      "https://kaskr.github.io/adcomp/Introduction.html",
      "https://lme4.github.io/lme4/reference/convergence.html",
      "https://github.com/lme4/lme4/blob/master/R/checkConv.R",
      "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html",
      "https://doi.org/10.18637/jss.v043.i09",
      "https://doi.org/10.18637/jss.v060.i02",
      "https://doi.org/10.1080/01621459.1987.10478472",
      "https://cran.r-project.org/web/packages/numDeriv/numDeriv.pdf"
    ),
    ContractRole = c(
      "Laplace objective and automatic-differentiation basis",
      "objective gradient and Hessian access",
      "gradient Hessian scaling and optimizer agreement are separate checks",
      "installed lme4 scaled-gradient implementation",
      "restart alternate optimizer and non-PD diagnostics",
      "multi-method optimization comparison and solution diagnostics",
      "optimization practice and verification",
      "variance-component boundary is nonregular",
      "independent Richardson derivative comparison"
    ),
    PrimaryOrOfficial = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwsz_state_registry <- function() {
  list(
    ReferenceState = data.frame(
      State = c(
        "finite_local_minimum", "finite_stationary_flat",
        "finite_nonstationary", "finite_saddle_or_max",
        "boundary_limit", "reference_unresolved", "not_evaluable"
      ),
      Meaning = c(
        "finite first-order stationary point with positive local curvature",
        "finite first-order stationary point with unresolved flat curvature",
        "finite point with reproducible descent evidence",
        "finite first-order point with a reproducible negative-curvature direction",
        "profiled objective improves toward a non-finite log-SD boundary",
        "reference ladder disagrees or lacks adequate numerical resolution",
        "objective or derivative reconstruction failed"
      ),
      FiniteStationarityReference = c(
        TRUE, TRUE, FALSE, FALSE, FALSE, NA, NA
      ),
      stringsAsFactors = FALSE
    ),
    ApplicationState = data.frame(
      State = c(
        "numerically_eligible", "boundary_handoff", "indeterminate",
        "numerically_ineligible", "not_evaluable"
      ),
      Meaning = c(
        "candidate rule supports a finite local numerical solution",
        "finite stationarity is not claimed; use the reduced/boundary lane",
        "available evidence lies in the prespecified uncertainty zone",
        "candidate rule rejects the finite numerical solution",
        "required objective derivative or curvature quantity is unavailable"
      ),
      stringsAsFactors = FALSE
    ),
    CurvatureState = c(
      "positive_definite_factorable", "spectral_positive_not_factorable",
      "near_singular_or_semidefinite", "indefinite", "not_evaluable"
    ),
    BoundaryState = c(
      "finite_interior_supported", "boundary_limit_supported",
      "boundary_probe_inconclusive", "not_applicable", "not_evaluable"
    )
  )
}

mfrmr_gtwsz_candidate_registry <- function() {
  scores <- data.frame(
    ScoreId = c(
      "raw_gradient_max", "objective_parameter_relative_max",
      "lme4_minimum_gradient_max", "newton_decrement",
      "newton_relative_step_max"
    ),
    RequiredCurvature = c(
      "none", "none", "positive_definite_factorable",
      "positive_definite_factorable", "stable_direct_solve"
    ),
    CoordinateProperty = c(
      "coordinate_dependent", "coordinate_dependent",
      "coordinate_and_order_dependent",
      "invariant_under_nonsingular_affine_reparameterization",
      "coordinate_dependent"
    ),
    CandidateRole = c(
      "negative_control_benchmark", "candidate", "candidate",
      "primary_candidate", "sensitivity_candidate"
    ),
    LowerMeansMoreStationary = TRUE,
    stringsAsFactors = FALSE
  )
  threshold_grid <- sort(unique(c(10^seq(-8, -1), 2e-3)))
  zones <- do.call(rbind, lapply(
    seq_len(length(threshold_grid) - 1L), function(index) {
      data.frame(
        ZoneId = sprintf("decimal_adjacent_%02d", index),
        EligibleUpper = threshold_grid[[index]],
        IneligibleLower = threshold_grid[[index + 1L]],
        GridOrigin = "prespecified_decimal_grid_plus_lme4_2e-3_anchor",
        stringsAsFactors = FALSE
      )
    }
  ))
  rules <- data.frame(
    RuleFamilyId = c(
      "objective_relative_zone", "lme4_minimum_zone",
      "newton_decrement_zone", "newton_step_zone",
      "raw_gradient_benchmark_zone"
    ),
    ScoreId = c(
      "objective_parameter_relative_max", "lme4_minimum_gradient_max",
      "newton_decrement", "newton_relative_step_max",
      "raw_gradient_max"
    ),
    PrimarySelectionEligible = c(TRUE, TRUE, TRUE, FALSE, FALSE),
    MissingRequiredQuantity = "not_evaluable_not_zero",
    NonPdPolicy = c(
      "separate_curvature_state", "not_evaluable_for_this_score",
      "not_evaluable_for_this_score", "not_evaluable_for_this_score",
      "separate_curvature_state"
    ),
    stringsAsFactors = FALSE
  )
  list(
    Scores = scores, Zones = zones, Rules = rules,
    SelectedRuleFamily = NA_character_, SelectedZoneId = NA_character_,
    ThresholdFrozen = FALSE
  )
}

mfrmr_gtwsz_reference_ladder <- function() {
  data.frame(
    Order = 1:8,
    Stage = c(
      "objective_reconstruction", "ad_richardson_derivative_agreement",
      "deterministic_multistart_envelope", "strict_solver_ladder",
      "damped_newton_polish", "curvature_inertia",
      "profiled_boundary_sequence", "reference_adjudication"
    ),
    RequiredEvidence = c(
      "same retained rows formula likelihood and fixed-coordinate objective",
      "TMB AD gradient and independent Richardson derivatives retained",
      "original restart and frozen deterministic perturbation starts",
      "prespecified nlminb BFGS and derivative-free verification routes",
      "monotone line search with every attempted step retained",
      "symmetric Hessian inertia and factorability reported separately",
      "target log-SD decreases while nuisance coordinates are reoptimized",
      "all disagreements become reference_unresolved"
    ),
    SingleStageSufficient = FALSE,
    UsesGeneratingTruth = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwsz_coordinate_fixtures <- function(dimension = 3L) {
  dimension <- as.integer(dimension)
  if (length(dimension) != 1L || is.na(dimension) || dimension < 2L) {
    stop("Coordinate fixtures require dimension >= 2.", call. = FALSE)
  }
  identity <- diag(dimension)
  diagonal <- diag(rep(c(1e-4, 1e4, 1), length.out = dimension))
  shear <- identity
  shear[1L, 2L] <- 0.75
  angle <- pi / 5
  rotation <- identity
  rotation[1:2, 1:2] <- matrix(
    c(cos(angle), sin(angle), -sin(angle), cos(angle)), nrow = 2L
  )
  list(identity = identity, diagonal_extreme = diagonal,
       shear = shear, rotation = rotation)
}

mfrmr_gtwsz_affine_transform <- function(parameter, gradient, hessian,
                                            transform, offset = NULL) {
  parameter <- as.numeric(parameter)
  gradient <- as.numeric(gradient)
  hessian <- as.matrix(hessian)
  transform <- as.matrix(transform)
  dimension <- length(parameter)
  if (is.null(offset)) offset <- rep(0, dimension)
  offset <- as.numeric(offset)
  valid <- dimension > 0L && length(gradient) == dimension &&
    length(offset) == dimension &&
    all(dim(hessian) == c(dimension, dimension)) &&
    all(dim(transform) == c(dimension, dimension)) &&
    all(is.finite(c(parameter, gradient, hessian, transform, offset))) &&
    is.finite(det(transform)) && abs(det(transform)) > 0
  if (!valid) stop("An invertible finite affine coordinate map is required.",
                   call. = FALSE)
  # Old coordinates satisfy p = A z + b.
  transformed_parameter <- as.numeric(solve(transform, parameter - offset))
  transformed_gradient <- as.numeric(t(transform) %*% gradient)
  transformed_hessian <- t(transform) %*% hessian %*% transform
  list(
    Parameter = transformed_parameter, Gradient = transformed_gradient,
    Hessian = transformed_hessian,
    GradientRule = "g_z=A_transpose_g_p",
    HessianRule = "H_z=A_transpose_H_p_A"
  )
}

mfrmr_gtwsz_affine_audit <- function(parameter, objective, gradient,
                                       hessian,
                                       fixtures = mfrmr_gtwsz_coordinate_fixtures(
                                         length(parameter)
                                       )) {
  baseline <- mfrmr_gtwsy_scale_metrics(
    parameter, objective, gradient, hessian
  )
  rows <- do.call(rbind, lapply(names(fixtures), function(fixture_id) {
    transformed <- mfrmr_gtwsz_affine_transform(
      parameter, gradient, hessian, fixtures[[fixture_id]]
    )
    metrics <- mfrmr_gtwsy_scale_metrics(
      transformed$Parameter, objective, transformed$Gradient,
      transformed$Hessian
    )
    data.frame(
      FixtureId = fixture_id,
      HessianPositiveDefinite = metrics$HessianPositiveDefinite,
      RawGradientMaximumAbsolute = metrics$RawMaximumAbsolute,
      ObjectiveRelativeMaximumAbsolute =
        metrics$ObjectiveRelativeParameterScaledMaximumAbsolute,
      Lme4ScaledMaximumAbsolute = metrics$Lme4ScaledMaximumAbsolute,
      NewtonDecrement = metrics$NewtonDecrement,
      NewtonRelativeStepMaximumAbsolute =
        metrics$NewtonRelativeStepMaximumAbsolute,
      stringsAsFactors = FALSE
    )
  }))
  list(
    Baseline = baseline, Rows = rows,
    PositiveDefinitenessPreserved = all(
      rows$HessianPositiveDefinite == baseline$HessianPositiveDefinite
    ),
    NewtonDecrementInvariant = all(
      is.finite(rows$NewtonDecrement)
    ) && max(abs(rows$NewtonDecrement - baseline$NewtonDecrement)) <=
      1e-10 * max(1, abs(baseline$NewtonDecrement)),
    RawGradientInvariant = all(
      abs(rows$RawGradientMaximumAbsolute - baseline$RawMaximumAbsolute) <=
        1e-10 * max(1, abs(baseline$RawMaximumAbsolute))
    )
  )
}

mfrmr_gtwsz_error_accounting <- function(candidate_state,
                                           reference_state) {
  candidate_state <- as.character(candidate_state)
  reference_state <- as.character(reference_state)
  if (length(candidate_state) != length(reference_state)) {
    stop("Candidate and reference states must have equal length.",
         call. = FALSE)
  }
  reference_positive <- reference_state %in% c(
    "finite_local_minimum", "finite_stationary_flat"
  )
  reference_negative <- reference_state %in% c(
    "finite_nonstationary", "finite_saddle_or_max", "boundary_limit"
  )
  unresolved <- reference_state %in% c(
    "reference_unresolved", "not_evaluable"
  )
  data.frame(
    ReferencePositive = sum(reference_positive),
    NumericalFalseUnready = sum(
      reference_positive & candidate_state == "numerically_ineligible"
    ),
    ReferenceNegative = sum(reference_negative),
    NumericalFalseReady = sum(
      reference_negative & candidate_state == "numerically_eligible"
    ),
    BoundaryHandoff = sum(candidate_state == "boundary_handoff"),
    CandidateIndeterminate = sum(candidate_state == "indeterminate"),
    CandidateNotEvaluable = sum(candidate_state == "not_evaluable"),
    ReferenceUnresolved = sum(unresolved),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwsz_b1g4_artifacts_valid <- function(execution, adjudication) {
  adjudication_fields <- c(
    "Contract", "RunnerContractHash", "ExecutionHash", "FitRows",
    "MetricSummaries", "RouteSpreadRows", "Summary"
  )
  inherits(execution, "mfrmr_gtwsy_execution") &&
    inherits(adjudication, "mfrmr_gtwsy_adjudication") &&
    mfrmr_gtwsy_execution_hash_valid(execution) &&
    identical(
      execution$RunnerContractHash,
      "97dcdd0103a3eb9a714ac56008f801af57853bc816f42e5bc9ab33dd63f3ae32"
    ) && identical(
      execution$ExecutionHash,
      "a825ab427da7e4a8160e428a7a6b00038f364b1c15049df6d5e4bf03bbbbbade"
    ) && all(adjudication_fields %in% names(adjudication)) &&
    identical(
      adjudication$ResultHash,
      mfrmr_gta_hash(adjudication[adjudication_fields])
    ) && identical(adjudication$ExecutionHash, execution$ExecutionHash) &&
    identical(
      adjudication$ResultHash,
      "40949ff311e6dbe1289cf6488aa2db3642a65ca64d6b794b47aeb5001d53acf1"
    ) && isTRUE(execution$ExactAccountingPassed) &&
    isTRUE(adjudication$ExactAccountingPassed) &&
    !isTRUE(adjudication$StationarityCriterionReady) &&
    !isTRUE(adjudication$FullExecutionAuthorized) &&
    !isTRUE(adjudication$CalibrationEvidenceReady) &&
    !isTRUE(adjudication$InferenceReady) &&
    !isTRUE(adjudication$DecisionReady)
}

mfrmr_gtwsz_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwsz_source_registry", "mfrmr_gtwsz_state_registry",
    "mfrmr_gtwsz_candidate_registry", "mfrmr_gtwsz_reference_ladder",
    "mfrmr_gtwsz_coordinate_fixtures", "mfrmr_gtwsz_affine_transform",
    "mfrmr_gtwsz_affine_audit", "mfrmr_gtwsz_error_accounting",
    "mfrmr_gtwsz_b1g4_artifacts_valid",
    "mfrmr_gtwsz_contract", "mfrmr_gtwsz_manifest",
    "mfrmr_gtwsz_manifest_hash_valid"
  )
  design_environment <- environment(mfrmr_gtwsz_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwsz_function_hash(get(
      name, envir = design_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwsz_contract <- function(pilot_plan) {
  mfrmr_gtwsz_require_primitives()
  if (!inherits(pilot_plan, "mfrmr_gtwp_plan") ||
      !identical(
        pilot_plan$PlanHash,
        "427addf42c73047e184857f52e9aa126e6d5eb346ab105827d14b3affef38cbd"
      ) || !identical(
        pilot_plan$CalibrationRegistryHash,
        "8a1c165d5497519f14f9839a22eed7b9e918b5120da83985613d01fd76a8be01"
      )) {
    stop("The exact Draft.83d2b2b0 pilot plan is required.", call. = FALSE)
  }
  calibration_manifest <- mfrmr_gtwp_manifest(
    pilot_plan, "calibration_pilot"
  )
  if (!identical(
    calibration_manifest$ManifestHash,
    "85d3ee963e93adfcc1d0bf505b1c34b1486f3eebfc605cf687a8e79240431676"
  ) || isTRUE(calibration_manifest$ExecutionAuthorized) ||
      isTRUE(calibration_manifest$DataGenerated) ||
      isTRUE(calibration_manifest$ResultsViewed)) {
    stop("The sealed calibration manifest identity changed.",
         call. = FALSE)
  }
  candidate_registry <- mfrmr_gtwsz_candidate_registry()
  states <- mfrmr_gtwsz_state_registry()
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_stationarity_",
      "calibration_design_draft83d2b2b1g5_v1"
    ),
    ContractArtifact = paste0(
      "gtheory-weak-information-glmmtmb-stationarity-calibration-",
      "design-contract-0.2.3.md"
    ),
    UpstreamPilotPlanHash = pilot_plan$PlanHash,
    UpstreamCalibrationRegistryHash = pilot_plan$CalibrationRegistryHash,
    UpstreamCalibrationManifestHash = calibration_manifest$ManifestHash,
    UpstreamB1g4ContractHash =
      "97dcdd0103a3eb9a714ac56008f801af57853bc816f42e5bc9ab33dd63f3ae32",
    UpstreamB1g4ExecutionHash =
      "a825ab427da7e4a8160e428a7a6b00038f364b1c15049df6d5e4bf03bbbbbade",
    UpstreamB1g4AdjudicationHash =
      "40949ff311e6dbe1289cf6488aa2db3642a65ca64d6b794b47aeb5001d53acf1",
    StatisticalResolutionStateSpace = c(
      "not_resolved", "indeterminate", "resolved", "not_evaluable"
    ),
    NumericalReferenceStates = states$ReferenceState,
    NumericalApplicationStates = states$ApplicationState,
    CurvatureStates = states$CurvatureState,
    BoundaryStates = states$BoundaryState,
    GateOrder = c(
      "structural_identification", "numerical_stationarity_and_boundary",
      "statistical_component_resolution", "bootstrap_inference",
      "D_study_decision"
    ),
    StatisticalResolutionCannotLabelNumericalStationarity = TRUE,
    GeneratingTruthCannotLabelNumericalStationarity = TRUE,
    FiniteLogSdCannotRepresentExactZero = TRUE,
    BoundaryLimitIsNotFiniteStationarity = TRUE,
    CandidateRegistry = candidate_registry,
    ReferenceLadder = mfrmr_gtwsz_reference_ladder(),
    CoordinateFixtures = mfrmr_gtwsz_coordinate_fixtures(3L),
    CalibrationReplicateRange = 201:300,
    CalibrationScenarioCount = 30L,
    CalibrationMethodCount = 4L,
    CalibrationBaseMethodUnits = 12000L,
    ModelRolesPerUnit = 2L, ProfilesPerModelRole = 6L,
    PlannedCandidateFits = 144000L,
    PlannedReferenceProblems = 24000L,
    CalibrationIndependentDatasetCount = 3000L,
    PrimaryErrorDenominator =
      "scenario_by_method_by_reference-resolved_fit_state",
    ReferenceUnresolvedExcludedFromBinaryErrorsButRetained = TRUE,
    B1g4ObservedMagnitudesMaySelectCutoff = FALSE,
    B1g4Use = "schema_and_metric_definition_only",
    CandidateGridMayChangeAfterCalibrationView = FALSE,
    ReferenceLadderMayChangeAfterCalibrationView = FALSE,
    ThresholdSelectionMayUseConfirmation = FALSE,
    StatisticalResolutionCalibrationIsSeparate = TRUE,
    Sources = mfrmr_gtwsz_source_registry(),
    ZoteroAudit = data.frame(
      Query = c(
        "Template Model Builder automatic differentiation Laplace approximation",
        "likelihood ratio tests variance components boundary",
        "optimx Nash Varadhan", "Generalizability theory"
      ),
      ExactNumericalReferenceMatches = c(0L, 0L, 0L, NA_integer_),
      RelevantGeneralizabilityItems = c(0L, 0L, 0L, 10L),
      LibraryUse = c(
        rep("no_exact_match_web_primary_source_used", 3L),
        "context_only_not_stationarity_reference"
      ),
      stringsAsFactors = FALSE
    ),
    FunctionHashes = mfrmr_gtwsz_function_hashes()
  )
  structure(c(identity, list(
    DesignContractHash = mfrmr_gta_hash(identity),
    DesignSchemaReady = TRUE, CandidateArchitectureFrozen = TRUE,
    ReferenceArchitectureFrozen = TRUE, CoordinateAuditReady = TRUE,
    ReferenceToleranceFrozen = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    NumericalEligibilitySufficientRuleFrozen = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    FullExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwsz_contract")
}

mfrmr_gtwsz_manifest <- function(contract, pilot_plan) {
  if (!inherits(contract, "mfrmr_gtwsz_contract") ||
      !identical(contract$UpstreamPilotPlanHash, pilot_plan$PlanHash) ||
      isTRUE(contract$CalibrationExecutionAuthorized)) {
    stop("An intact non-authorizing b1g5 design contract is required.",
         call. = FALSE)
  }
  pilot_manifest <- mfrmr_gtwp_manifest(pilot_plan, "calibration_pilot")
  rows <- pilot_manifest$Rows
  rows$ModelRoleCount <- contract$ModelRolesPerUnit
  rows$ProfileCountPerModelRole <- contract$ProfilesPerModelRole
  rows$CandidateFitCount <-
    rows$ModelRoleCount * rows$ProfileCountPerModelRole
  rows$ReferenceProblemCount <- rows$ModelRoleCount
  rows$BoundaryProfileRequired <- TRUE
  rows$NumericalCalibrationExecutionAuthorized <- FALSE
  rows$StatisticalResolutionUseAuthorized <- FALSE
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_stationarity_",
      "calibration_design_manifest_draft83d2b2b1g5_v1"
    ),
    DesignContractHash = contract$DesignContractHash,
    PilotManifestHash = pilot_manifest$ManifestHash,
    Rows = rows
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    BaseMethodUnitCount = nrow(rows),
    IndependentDatasetCount = length(unique(rows$DatasetId)),
    CandidateFitCount = sum(rows$CandidateFitCount),
    ReferenceProblemCount = sum(rows$ReferenceProblemCount),
    ExecutionAuthorized = FALSE, DataGenerated = FALSE,
    ResultsViewed = FALSE, ThresholdSelectionPermitted = FALSE
  )), class = "mfrmr_gtwsz_manifest")
}

mfrmr_gtwsz_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "DesignContractHash", "PilotManifestHash", "Rows"
  )
  inherits(manifest, "mfrmr_gtwsz_manifest") &&
    all(fields %in% names(manifest)) && identical(
      manifest$ManifestHash, mfrmr_gta_hash(manifest[fields])
    )
}
