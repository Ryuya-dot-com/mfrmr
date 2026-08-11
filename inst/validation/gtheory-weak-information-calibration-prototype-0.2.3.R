# Draft.83d2b2a G-theory weak-information calibration registry/prototype.
#
# Repository-internal only. This file registers truth-blind observable
# diagnostics and generates zero/near-zero/small/ordinary positive controls.
# It does not freeze a weak-information threshold or promote recovery.

mfrmr_gtw_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtd_method_backend", "mfrmr_gtd2_spec",
    "mfrmr_gtd2_full_design", "mfrmr_gtd2_component_variance",
    "mfrmr_gtd2_effect_key", "mfrmr_gtd2_residual",
    "mfrmr_gtd2_assignment_indices", "mfrmr_gtd2_hash_data",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtd4_execute_one"
  )
  prototype_environment <- environment(mfrmr_gtw_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81/82/83a/c1/c2/d1/d2a/d2b0/d2b1 before ",
      "Draft.83d2b2a: ", paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtw_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtw_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtw_manifest", "mfrmr_gtw_prepare_unit",
    "mfrmr_gtw_extract_observables", "mfrmr_gtw_method_contrasts",
    "mfrmr_gtw_execute_smoke", "mfrmr_gtw_combine_strata"
  )
  environment <- environment(mfrmr_gtw_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtw_function_hash(get(name, envir = environment, inherits = TRUE))
  }, character(1L)), functions)
}

mfrmr_gtw_diagnostic_catalog <- function() {
  data.frame(
    DiagnosticId = c(
      "target_variance_estimate", "target_fraction_total",
      "target_to_residual_ratio", "target_grouping_levels",
      "observations_per_target_level", "base_point_gate",
      "boundary_or_singularity", "minimum_local_curvature",
      "backend_relative_difference", "ml_reml_relative_difference",
      "reduced_component_likelihood_drop", "component_interval"
    ),
    ObservableBasis = c(
      "semantic component estimate", "estimate / sum(component estimates)",
      "estimate / residual estimate", "retained grouping identities",
      "retained rows / grouping identities", "Draft.83d2b1 gate",
      "backend boundary/singularity diagnostics", "backend-local Hessian",
      "matched ML or REML estimate pair", "within-backend ML/REML pair",
      "full-versus-reduced component model", "full-refit component interval"
    ),
    Availability = c(
      rep("implemented_smoke", 10L),
      "planned_profile_or_bootstrap", "deferred_draft84"
    ),
    TruthBlindAtApplication = TRUE,
    ThresholdState = "not_frozen",
    InterpretationLimit = c(
      rep("candidate diagnostic, not a readiness rule", 10L),
      "nonstandard boundary law requires separate calibration",
      "coverage unavailable before Draft.84"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtw_registry <- function() {
  mfrmr_gtw_require_primitives()
  designs <- data.frame(
    DesignId = c(
      "baseline_complete", "few_levels_complete", "high_information",
      "sparse_connected", "imbalanced_hub"
    ),
    NPerson = c(100L, 100L, 300L, 100L, 100L),
    NRater = c(4L, 2L, 8L, 8L, 8L),
    NCriterion = c(4L, 2L, 4L, 4L, 4L),
    ObservationsPerPerson = c(16L, 4L, 32L, 16L, 8L),
    AssignmentTopology = c(
      "complete", "complete", "complete", "connected_cycle",
      "connected_hub"
    ),
    WorkloadImbalance = c("balanced", "balanced", "balanced", "balanced", "high"),
    stringsAsFactors = FALSE
  )
  variance <- data.frame(
    VarianceId = c(
      "exact_zero", "numerical_near_zero", "small_0025", "small_0100",
      "moderate_0400", "reference_1200"
    ),
    TargetVariance = c(0, 1e-10, 0.0025, 0.01, 0.04, 0.12),
    TruthRegion = c(
      "exact_boundary", "numerical_near_boundary",
      "small_positive_transition", "small_positive_transition",
      "moderate_positive_transition", "ordinary_positive_reference"
    ),
    stringsAsFactors = FALSE
  )
  cells <- merge(designs, variance, by = NULL, sort = FALSE)
  cells$ScenarioId <- sprintf("GT-WI-%s-%s", cells$DesignId, cells$VarianceId)
  cells$TargetComponent <- "Rater"
  cells$EvaluationRole <- "transition_no_binary_requirement"
  cells$EvaluationRole[cells$VarianceId %in%
    c("exact_zero", "numerical_near_zero")] <- "negative_control_not_resolved"
  positive <- cells$DesignId %in% c("baseline_complete", "high_information") &
    (cells$VarianceId == "reference_1200" |
       (cells$DesignId == "high_information" &
          cells$VarianceId == "moderate_0400"))
  cells$EvaluationRole[positive] <- "positive_control_resolved"
  cells$AssignmentDensity <- cells$ObservationsPerPerson /
    (cells$NRater * cells$NCriterion)
  cells$SmokeReplications <- 1L
  cells$PilotReplications <- NA_integer_
  cells$ConfirmationReplications <- NA_integer_
  cells$PrecisionPlanState <- "not_frozen"
  cells$ThresholdState <- "not_frozen"
  cells$SeedStart <- 832200L + seq_len(nrow(cells)) * 1000L
  cells <- cells[c(
    "ScenarioId", "DesignId", "NPerson", "NRater", "NCriterion",
    "ObservationsPerPerson", "AssignmentTopology", "AssignmentDensity",
    "WorkloadImbalance", "VarianceId", "TargetComponent", "TargetVariance",
    "TruthRegion", "EvaluationRole", "SeedStart", "SmokeReplications",
    "PilotReplications", "ConfirmationReplications", "PrecisionPlanState",
    "ThresholdState"
  )]
  methods <- data.frame(
    MethodId = c("lme4_reml", "glmmTMB_reml", "lme4_ml", "glmmTMB_ml"),
    Backend = c("lme4", "glmmTMB", "lme4", "glmmTMB"),
    Likelihood = c("REML", "REML", "ML", "ML"),
    stringsAsFactors = FALSE
  )
  diagnostics <- mfrmr_gtw_diagnostic_catalog()
  identity <- list(
    Contract = "gtheory_weak_information_registry_draft83d2b2a_v1",
    TargetComponent = "Rater", Designs = designs, VarianceRegions = variance,
    Cells = cells, Methods = methods, Diagnostics = diagnostics,
    PilotReplications = NA_integer_, ConfirmationReplications = NA_integer_,
    PrecisionPlanState = "not_frozen", ThresholdState = "not_frozen"
  )
  structure(c(identity, list(
    RegistryHash = mfrmr_gta_hash(identity), SimulationExecuted = FALSE,
    CalibrationEvidenceReady = FALSE, ConfirmationAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtw_registry")
}

mfrmr_gtw_scenario_row <- function(cell) {
  data.frame(
    ScenarioId = cell$ScenarioId, Lane = "weak_information_calibration",
    EstimandId = "GT-WEAK-INFO-RATER", DesignFamily = "crossed_pxrxi",
    NPerson = cell$NPerson, NRater = cell$NRater,
    NCriterion = cell$NCriterion,
    ObservationsPerPerson = cell$ObservationsPerPerson,
    AssignmentTopology = cell$AssignmentTopology,
    AssignmentDensity = cell$AssignmentDensity,
    WorkloadImbalance = cell$WorkloadImbalance,
    ScoreSupport = "continuous", CategoryCount = NA_integer_,
    EndpointConcentration = "none", EndpointRateTarget = 0,
    LocalDependenceRho = 0, AnchorRate = 0,
    MissingnessMechanism = "none", MissingRate = 0,
    VarianceState = "calibration_override",
    MethodSet = "lme4_reml;glmmTMB_reml;lme4_ml;glmmTMB_ml",
    MetricProfile = "weak_information_observables",
    TargetBasis = "generating_gaussian_components",
    ExpectedDesignState = "calibration_role_not_fit_input",
    ExecutionEligibility = "executable_smoke", SmokeReplications = 1L,
    PilotReplications = NA_integer_, ConfirmationReplications = NA_integer_,
    PrecisionPlanState = "not_frozen",
    InferenceState = "point_only_no_interval",
    SeedStart = cell$SeedStart, TargetComponent = cell$TargetComponent,
    TargetVariance = cell$TargetVariance, TruthRegion = cell$TruthRegion,
    EvaluationRole = cell$EvaluationRole, stringsAsFactors = FALSE
  )
}

mfrmr_gtw_generate <- function(registry = mfrmr_gtw_registry(), scenario_id,
                                replicate = 1L) {
  if (!inherits(registry, "mfrmr_gtw_registry")) {
    stop("`registry` must be a Draft.83d2b2a weak-information registry.",
         call. = FALSE)
  }
  scenario_id <- as.character(scenario_id)
  if (length(scenario_id) != 1L || !scenario_id %in% registry$Cells$ScenarioId) {
    stop("Unknown weak-information calibration scenario.", call. = FALSE)
  }
  replicate <- as.integer(replicate)
  if (length(replicate) != 1L || is.na(replicate) || replicate < 1L) {
    stop("`replicate` must be one positive integer.", call. = FALSE)
  }
  cell <- registry$Cells[registry$Cells$ScenarioId == scenario_id, , drop = FALSE]
  scenario <- mfrmr_gtw_scenario_row(cell)
  seed <- scenario$SeedStart[[1L]] + replicate - 1L
  old_seed <- if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else NULL
  on.exit({
    if (is.null(old_seed)) {
      if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    } else assign(".Random.seed", old_seed, envir = .GlobalEnv)
  }, add = TRUE)
  set.seed(seed)
  spec <- mfrmr_gtd2_spec(scenario)
  full <- mfrmr_gtd2_full_design(scenario)
  score <- numeric(nrow(full))
  truth <- stats::setNames(numeric(nrow(spec$EffectMap)),
                          spec$EffectMap$ComponentId)
  effects <- list()
  for (component_id in spec$EffectMap$ComponentId) {
    variance <- if (component_id == scenario$TargetComponent[[1L]]) {
      scenario$TargetVariance[[1L]]
    } else mfrmr_gtd2_component_variance(component_id, scenario)
    truth[[component_id]] <- variance
    if (component_id == "Residual") {
      value <- mfrmr_gtd2_residual(full, variance, 0)
      score <- score + value
      effects[[component_id]] <- data.frame(
        LevelId = seq_len(nrow(full)), Effect = value,
        stringsAsFactors = FALSE
      )
    } else {
      members <- strsplit(component_id, ":", fixed = TRUE)[[1L]]
      key <- mfrmr_gtd2_effect_key(full, members)
      levels <- sort(unique(key), method = "radix")
      value <- if (variance == 0) rep(0, length(levels)) else
        stats::rnorm(length(levels), 0, sqrt(variance))
      names(value) <- levels
      score <- score + value[key]
      effects[[component_id]] <- data.frame(
        LevelId = levels, Effect = as.numeric(value), stringsAsFactors = FALSE
      )
    }
  }
  full$LatentContinuousScore <- score
  full$Score <- score
  assigned <- full[mfrmr_gtd2_assignment_indices(full, scenario), , drop = FALSE]
  row.names(assigned) <- NULL
  analysis <- assigned
  generator_identity <- list(
    Version = "gtheory_weak_information_generator_draft83d2b2a_v1",
    RegistryHash = registry$RegistryHash, ScenarioId = scenario_id,
    Replicate = replicate, Seed = seed, ScenarioRowHash = mfrmr_gta_hash(scenario),
    DesignHash = spec$DesignHash,
    FullPotentialDataHash = mfrmr_gtd2_hash_data(full),
    AssignedDataHash = mfrmr_gtd2_hash_data(assigned),
    AnalysisDataHash = mfrmr_gtd2_hash_data(analysis),
    NominalTruthHash = mfrmr_gta_hash(truth),
    FunctionHashes = mfrmr_gtw_function_hashes()
  )
  structure(list(
    ContractVersion = generator_identity$Version,
    ScenarioId = scenario_id, Replicate = replicate, Seed = seed,
    RegistryHash = registry$RegistryHash, Scenario = scenario, Spec = spec,
    GenerationState = "generated_not_fitted", FullPotentialData = full,
    AssignedData = assigned, AnalysisData = analysis, NominalTruth = truth,
    ProjectionTruth = NULL, GeneratedEffects = effects,
    GeneratorIdentity = generator_identity,
    GeneratorHash = mfrmr_gta_hash(generator_identity),
    GenerationEvidenceReady = TRUE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  ), class = c("mfrmr_gtd2_generation", "list"))
}

mfrmr_gtw_manifest <- function(registry = mfrmr_gtw_registry()) {
  if (!inherits(registry, "mfrmr_gtw_registry")) {
    stop("`registry` must be a Draft.83d2b2a weak-information registry.",
         call. = FALSE)
  }
  manifest <- merge(
    registry$Cells[c(
      "ScenarioId", "DesignId", "VarianceId", "TargetVariance",
      "TruthRegion", "EvaluationRole", "SeedStart"
    )],
    registry$Methods, by = NULL, sort = FALSE
  )
  manifest$Replicate <- 1L
  manifest$DatasetId <- paste0(manifest$ScenarioId, "/R0001")
  manifest$Seed <- manifest$SeedStart
  manifest$RegistryHash <- registry$RegistryHash
  manifest <- manifest[c(
    "ScenarioId", "Replicate", "DatasetId", "Seed", "MethodId", "Backend",
    "RegistryHash", "DesignId", "VarianceId", "TargetVariance",
    "TruthRegion", "EvaluationRole", "Likelihood"
  )]
  row.names(manifest) <- NULL
  manifest
}

mfrmr_gtw_prepare_unit <- function(registry, manifest_row) {
  if (!is.data.frame(manifest_row) || nrow(manifest_row) != 1L) {
    stop("`manifest_row` must contain one weak-information unit.", call. = FALSE)
  }
  generation <- mfrmr_gtw_generate(
    registry, manifest_row$ScenarioId[[1L]], manifest_row$Replicate[[1L]]
  )
  prefit <- mfrmr_gtd3_prefit_one(generation)
  row <- manifest_row
  row$GeneratorHash <- generation$GeneratorHash
  row$IncidenceAuditHash <- prefit$IncidenceAuditHash
  row$StructuralRankHash <- prefit$ScalableStructuralRankHash
  row$PreFitState <- prefit$PreFitState
  row$PreFitEligible <- prefit$PreFitEligible
  row$MethodEligibilityState <- if (prefit$PreFitEligible) {
    "eligible_adapter_pending_execution"
  } else prefit$PreFitState
  row$FitAttemptAuthorized <- FALSE
  row$AtomicResultRecorded <- FALSE
  list(Row = row, Generation = generation, PreFit = prefit)
}

mfrmr_gtw_extract_observables <- function(execution, unit) {
  row <- execution$Row
  detail <- execution$Detail
  estimate <- NA_real_
  residual <- NA_real_
  total <- NA_real_
  if (!is.null(detail) && !is.null(detail$Components)) {
    if (is.data.frame(detail$Components)) {
      components <- stats::setNames(
        detail$Components$Estimate, detail$Components$ComponentId
      )
    } else components <- detail$Components
    estimate <- unname(components[[unit$Generation$Scenario$TargetComponent[[1L]]]])
    residual <- unname(components[["Residual"]])
    total <- sum(components[is.finite(components)])
  }
  component_audit <- unit$PreFit$StructuralRankAudit$ComponentAudit
  target <- unit$Generation$Scenario$TargetComponent[[1L]]
  levels <- component_audit$GroupingLevels[component_audit$ComponentId == target]
  data.frame(
    unit$Row[c(
      "ScenarioId", "Replicate", "DatasetId", "MethodId", "Backend",
      "RegistryHash", "DesignId", "VarianceId", "TargetVariance",
      "TruthRegion", "EvaluationRole", "Likelihood"
    )],
    GeneratorHash = unit$Generation$GeneratorHash,
    PreFitHash = unit$PreFit$ResultHash,
    AtomicResultHash = row$AtomicResultHash,
    FitReturned = row$FitReturned, BasePointGatePassed = row$EstimationGatePassed,
    FailureStage = row$FailureStage, FailureCode = row$FailureCode,
    TargetEstimate = estimate,
    TargetFractionTotal = if (is.finite(estimate) && is.finite(total) && total > 0)
      estimate / total else NA_real_,
    TargetToResidualRatio = if (is.finite(estimate) && is.finite(residual) &&
                                residual > 0) estimate / residual else NA_real_,
    TargetGroupingLevels = as.integer(levels),
    ObservationsPerTargetLevel = unit$PreFit$StructuralRankAudit$RetainedRows /
      as.numeric(levels),
    BoundaryComponentCount = row$BoundaryComponentCount,
    CurvatureState = row$CurvatureState,
    CurvatureRankFull = row$CurvatureRankFull,
    RegularInterior = row$RegularInterior,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtw_relative_difference <- function(x, y) {
  if (!is.finite(x) || !is.finite(y)) return(NA_real_)
  abs(x - y) / max(abs(x), abs(y), .Machine$double.eps)
}

mfrmr_gtw_method_contrasts <- function(observables) {
  required <- c("ScenarioId", "Replicate", "MethodId", "TargetEstimate")
  if (!is.data.frame(observables) || !all(required %in% names(observables))) {
    stop("`observables` do not match the weak-information schema.",
         call. = FALSE)
  }
  groups <- split(
    observables,
    interaction(observables$ScenarioId, observables$Replicate,
                drop = TRUE, lex.order = TRUE)
  )
  rows <- lapply(groups, function(x) {
    estimate <- stats::setNames(x$TargetEstimate, x$MethodId)
    get_estimate <- function(name) {
      if (!name %in% names(estimate)) return(NA_real_)
      as.numeric(estimate[[name]])
    }
    values <- as.numeric(estimate[is.finite(estimate)])
    data.frame(
      ScenarioId = x$ScenarioId[[1L]], Replicate = x$Replicate[[1L]],
      DesignId = x$DesignId[[1L]], VarianceId = x$VarianceId[[1L]],
      TargetVariance = x$TargetVariance[[1L]],
      TruthRegion = x$TruthRegion[[1L]], EvaluationRole = x$EvaluationRole[[1L]],
      EstimateAvailableCount = length(values),
      EstimateMinimum = if (length(values)) min(values) else NA_real_,
      EstimateMaximum = if (length(values)) max(values) else NA_real_,
      BackendRelativeDifferenceREML = mfrmr_gtw_relative_difference(
        get_estimate("lme4_reml"), get_estimate("glmmTMB_reml")
      ),
      BackendRelativeDifferenceML = mfrmr_gtw_relative_difference(
        get_estimate("lme4_ml"), get_estimate("glmmTMB_ml")
      ),
      MLREMLRelativeDifferenceLme4 = mfrmr_gtw_relative_difference(
        get_estimate("lme4_ml"), get_estimate("lme4_reml")
      ),
      MLREMLRelativeDifferenceGlmmTMB = mfrmr_gtw_relative_difference(
        get_estimate("glmmTMB_ml"), get_estimate("glmmTMB_reml")
      ),
      PassedBaseGateCount = sum(x$BasePointGatePassed),
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output[order(output$ScenarioId), , drop = FALSE]
}

mfrmr_gtw_execute_smoke <- function(
    registry = mfrmr_gtw_registry(), scenario_ids = registry$Cells$ScenarioId,
    method_ids = registry$Methods$MethodId, progress = interactive()) {
  scenario_ids <- unique(as.character(scenario_ids))
  method_ids <- unique(as.character(method_ids))
  if (any(!scenario_ids %in% registry$Cells$ScenarioId) ||
      any(!method_ids %in% registry$Methods$MethodId)) {
    stop("Unknown weak-information scenario or method selection.",
         call. = FALSE)
  }
  manifest <- mfrmr_gtw_manifest(registry)
  manifest <- manifest[
    manifest$ScenarioId %in% scenario_ids & manifest$MethodId %in% method_ids,
    , drop = FALSE
  ]
  outputs <- vector("list", nrow(manifest))
  observables <- vector("list", nrow(manifest))
  unit_cache <- list()
  for (index in seq_len(nrow(manifest))) {
    key <- manifest$ScenarioId[[index]]
    if (is.null(unit_cache[[key]])) {
      unit_cache[[key]] <- mfrmr_gtw_prepare_unit(
        registry, manifest[index, , drop = FALSE]
      )
    }
    unit <- unit_cache[[key]]
    unit$Row <- manifest[index, , drop = FALSE]
    unit$Row$GeneratorHash <- unit$Generation$GeneratorHash
    unit$Row$IncidenceAuditHash <- unit$PreFit$IncidenceAuditHash
    unit$Row$StructuralRankHash <- unit$PreFit$ScalableStructuralRankHash
    unit$Row$PreFitState <- unit$PreFit$PreFitState
    unit$Row$PreFitEligible <- unit$PreFit$PreFitEligible
    unit$Row$MethodEligibilityState <- if (unit$PreFit$PreFitEligible) {
      "eligible_adapter_pending_execution"
    } else unit$PreFit$PreFitState
    unit$Row$FitAttemptAuthorized <- FALSE
    unit$Row$AtomicResultRecorded <- FALSE
    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] %s / %s", index, nrow(manifest), key,
                      manifest$MethodId[[index]]))
    }
    outputs[[index]] <- mfrmr_gtd4_execute_one(
      unit$Row, unit$Generation, unit$PreFit
    )
    observables[[index]] <- mfrmr_gtw_extract_observables(outputs[[index]], unit)
  }
  rows <- do.call(rbind, lapply(outputs, `[[`, "Row"))
  observable_rows <- do.call(rbind, observables)
  row.names(rows) <- NULL
  row.names(observable_rows) <- NULL
  contrasts <- mfrmr_gtw_method_contrasts(observable_rows)
  negative <- observable_rows$EvaluationRole == "negative_control_not_resolved"
  positive <- observable_rows$EvaluationRole == "positive_control_resolved"
  identity <- list(
    Contract = "gtheory_weak_information_smoke_draft83d2b2a_v1",
    RegistryHash = registry$RegistryHash,
    FunctionHashes = mfrmr_gtw_function_hashes(),
    SelectedScenarioIds = scenario_ids, SelectedMethodIds = method_ids,
    AtomicRows = rows[, setdiff(names(rows), "RuntimeSeconds"), drop = FALSE],
    ObservableRows = observable_rows, MethodContrasts = contrasts
  )
  structure(c(identity, list(
    SmokeHash = mfrmr_gta_hash(identity), PlannedUnits = nrow(rows),
    FitAttemptCount = sum(rows$FitAttempted), FitReturnCount = sum(rows$FitReturned),
    BasePointGatePassCount = sum(rows$EstimationGatePassed),
    NegativeControlFalseReadyCount = sum(
      observable_rows$BasePointGatePassed[negative]
    ),
    PositiveControlFalseBlockCount = sum(
      !observable_rows$BasePointGatePassed[positive]
    ),
    AtomicAccountingPassed = all(rows$AtomicResultRecorded) &&
      all((rows$EstimationGatePassed & rows$FailureStage == "none") |
            (!rows$EstimationGatePassed & rows$FailureStage != "none")),
    ThresholdFrozen = FALSE, CalibrationEvidenceReady = FALSE,
    ConfirmationAuthorized = FALSE, RecoveryEvidenceReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtw_smoke")
}

mfrmr_gtw_combine_strata <- function(runs,
                                      registry = mfrmr_gtw_registry()) {
  if (!is.list(runs) || length(runs) < 1L ||
      any(!vapply(runs, inherits, logical(1L), what = "mfrmr_gtw_smoke"))) {
    stop("`runs` must contain Draft.83d2b2a smoke strata.", call. = FALSE)
  }
  if (any(vapply(runs, function(x) !identical(
    x$RegistryHash, registry$RegistryHash
  ), logical(1L)))) {
    stop("Weak-information stratum registry identities differ.", call. = FALSE)
  }
  methods <- unlist(lapply(runs, `[[`, "SelectedMethodIds"), use.names = FALSE)
  if (anyDuplicated(methods) || !setequal(methods, registry$Methods$MethodId)) {
    stop("Smoke strata must partition the four registered methods exactly.",
         call. = FALSE)
  }
  scenarios <- lapply(runs, `[[`, "SelectedScenarioIds")
  if (any(vapply(scenarios, function(x) !setequal(
    x, registry$Cells$ScenarioId
  ), logical(1L)))) {
    stop("Every method stratum must contain all registered scenarios.",
         call. = FALSE)
  }
  rows <- do.call(rbind, lapply(runs, `[[`, "AtomicRows"))
  observables <- do.call(rbind, lapply(runs, `[[`, "ObservableRows"))
  manifest <- mfrmr_gtw_manifest(registry)
  key <- function(x) paste(x$ScenarioId, x$Replicate, x$MethodId, sep = "\r")
  position <- match(key(manifest), key(rows))
  if (anyNA(position) || anyDuplicated(key(rows))) {
    stop("Combined weak-information atomic identities are incomplete.",
         call. = FALSE)
  }
  rows <- rows[position, , drop = FALSE]
  observables <- observables[match(key(manifest), key(observables)), , drop = FALSE]
  row.names(rows) <- NULL
  row.names(observables) <- NULL
  contrasts <- mfrmr_gtw_method_contrasts(observables)
  negative <- observables$EvaluationRole == "negative_control_not_resolved"
  positive <- observables$EvaluationRole == "positive_control_resolved"
  stratum_hashes <- stats::setNames(
    vapply(runs, `[[`, character(1L), "SmokeHash"), methods
  )
  stratum_hashes <- stratum_hashes[registry$Methods$MethodId]
  identity <- list(
    Contract = "gtheory_weak_information_stratified_smoke_draft83d2b2a_v1",
    RegistryHash = registry$RegistryHash,
    FunctionHashes = mfrmr_gtw_function_hashes(),
    StratumHashes = stratum_hashes, AtomicRows = rows,
    ObservableRows = observables, MethodContrasts = contrasts
  )
  structure(c(identity, list(
    StratifiedSmokeHash = mfrmr_gta_hash(identity),
    PlannedUnits = nrow(rows), FitAttemptCount = sum(rows$FitAttempted),
    FitReturnCount = sum(rows$FitReturned),
    BasePointGatePassCount = sum(rows$EstimationGatePassed),
    NegativeControlFalseReadyCount = sum(
      observables$BasePointGatePassed[negative]
    ),
    PositiveControlFalseBlockCount = sum(
      !observables$BasePointGatePassed[positive]
    ),
    AtomicAccountingPassed = all(
      (rows$EstimationGatePassed & rows$FailureStage == "none") |
        (!rows$EstimationGatePassed & rows$FailureStage != "none")
    ),
    ThresholdFrozen = FALSE, CalibrationEvidenceReady = FALSE,
    ConfirmationAuthorized = FALSE, RecoveryEvidenceReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtw_stratified_smoke")
}
