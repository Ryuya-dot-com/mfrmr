# Draft.83d2b2b1c replacement resolution-feasibility planning prototype.
#
# Repository-internal only. This file freezes the untouched 3,000-row
# manifest, measures serial runtime on already viewed replicate-1 data, and
# creates a narrow execution authorization. It does not run reserved data,
# select a rule, compute a bootstrap p-value, or support inference.

mfrmr_gtwf_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwp_plan",
    "mfrmr_gtwd_inference_contract", "mfrmr_gtwd_diagnostic_pair",
    "mfrmr_gtwb_contract", "mfrmr_gtwb_pair_available",
    "mfrmr_gtwb_pair_summary", "mfrmr_gtd4_lme4_components",
    "mfrmr_gtm_components"
  )
  prototype_environment <- environment(mfrmr_gtwf_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81/83c/83d/83d2b2a/83d2b2b0/83d2b2b1a/b before ",
      "Draft.83d2b2b1c: ", paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwf_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwf_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwf_contract", "mfrmr_gtwf_manifest",
    "mfrmr_gtwf_runtime_manifest", "mfrmr_gtwf_observable_row",
    "mfrmr_gtwf_runtime_projection", "mfrmr_gtwf_execute_runtime_schema",
    "mfrmr_gtwf_authorization"
  )
  prototype_environment <- environment(mfrmr_gtwf_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwf_function_hash(get(
      name, envir = prototype_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwf_contract <- function(
    registry = mfrmr_gtw_registry(),
    historical_plan = mfrmr_gtwp_plan(registry),
    diagnostic_contract = mfrmr_gtwd_inference_contract(
      registry, historical_plan
    ),
    bootstrap_contract = mfrmr_gtwb_contract(registry, diagnostic_contract)) {
  mfrmr_gtwf_require_primitives()
  if (!inherits(registry, "mfrmr_gtw_registry") ||
      !inherits(historical_plan, "mfrmr_gtwp_plan") ||
      !inherits(diagnostic_contract, "mfrmr_gtwd_contract") ||
      !inherits(bootstrap_contract, "mfrmr_gtwb_contract")) {
    stop("Draft.83d2b2b1c requires all preceding weak-information contracts.",
         call. = FALSE)
  }
  sources <- data.frame(
    SourceId = c(
      "R_system_time_current", "lme4_lmerControl_current",
      "glmmTMB_parallel_current"
    ),
    Locator = c(
      "https://stat.ethz.ch/R-manual/R-devel/library/base/help/system.time.html",
      "https://lme4.github.io/lme4/reference/lmerControl.html",
      "https://glmmtmb.github.io/glmmTMB/articles/parallel.html"
    ),
    Role = c(
      "elapsed_planning_telemetry_not_deterministic_evidence",
      "default_optimizer_and_convergence_control_identity",
      "experimental_parallel_option_excluded_from_serial_projection"
    ),
    stringsAsFactors = FALSE
  )
  identity <- list(
    Contract = "gtheory_weak_information_feasibility_draft83d2b2b1c_v1",
    CalibrationRegistryHash = registry$RegistryHash,
    SupersededHistoricalPlanHash = historical_plan$PlanHash,
    DiagnosticContractHash = diagnostic_contract$ContractHash,
    BootstrapMechanicsContractHash = bootstrap_contract$ContractHash,
    ContractArtifact =
      "gtheory-weak-information-feasibility-contract-0.2.3.md",
    TargetComponent = "Rater",
    FeasibilityReplicateStart = 101L,
    FeasibilityReplicateEnd = 125L,
    FeasibilityReplicatesPerCell = 25L,
    ScenarioCellCount = nrow(registry$Cells),
    MethodCount = nrow(registry$Methods),
    FeasibilityIndependentDatasetCount = 750L,
    FeasibilityRowCount = 3000L,
    FeasibilityBackendFitCount = 6000L,
    RuntimeReplicate = 1L,
    RuntimeScenarioCellCount = nrow(registry$Cells),
    RuntimePairCount = 120L,
    RuntimeBackendFitCount = 240L,
    BoundaryTolerance = 1e-8,
    NegativeLikelihoodTolerance = 1e-6,
    RuntimeMeasurement =
      "base_system.time_gcFirst_true_elapsed_serial_warm_packages",
    RuntimeProjectionMultipliers = c(Central = 1, SensitivityX2 = 2,
                                     SensitivityX4 = 4),
    TimingInScientificExecutionHash = FALSE,
    WithinFitParallelism =
      "unchanged_backend_default_no_parallel_speedup_credited",
    CheckpointPairUnit = "one_method_full_reduced_pair",
    DatasetCompletionUnit = "four_method_rows_same_scenario_replicate",
    ResumeMismatchAction = "recompute_or_reject_never_pool",
    CommonFeasibilityScores = c(
      "target_fraction_total", "target_to_residual_ratio",
      "raw_likelihood_drop_separate_method_likelihood"
    ),
    WithdrawnCommonScores = "target_relative_se_profiled",
    ThresholdSelectionPermitted = FALSE,
    InnerBootstrapPermitted = FALSE,
    Sources = sources,
    BackendVersions = c(
      lme4 = as.character(utils::packageVersion("lme4")),
      glmmTMB = as.character(utils::packageVersion("glmmTMB"))
    ),
    FunctionHashes = mfrmr_gtwf_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    ManifestFreezeAuthorized = TRUE,
    RuntimeSchemaAuthorized = TRUE,
    ReservedFeasibilityDataGenerated = FALSE,
    ResolutionFeasibilityAuthorized = FALSE,
    FeasibilityEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwf_contract")
}

mfrmr_gtwf_manifest <- function(contract = mfrmr_gtwf_contract(),
                                 registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwf_contract") ||
      !inherits(registry, "mfrmr_gtw_registry") ||
      !identical(contract$CalibrationRegistryHash, registry$RegistryHash) ||
      !isTRUE(contract$ManifestFreezeAuthorized)) {
    stop("Feasibility contract and registry identities differ.", call. = FALSE)
  }
  index <- expand.grid(
    Cell = seq_len(nrow(registry$Cells)),
    Replicate = seq.int(
      contract$FeasibilityReplicateStart,
      contract$FeasibilityReplicateEnd
    ),
    Method = seq_len(nrow(registry$Methods)),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  cells <- registry$Cells[index$Cell, c(
    "ScenarioId", "DesignId", "VarianceId", "TargetVariance",
    "TruthRegion", "EvaluationRole", "SeedStart"
  ), drop = FALSE]
  methods <- registry$Methods[index$Method, , drop = FALSE]
  rows <- cbind(
    cells, Replicate = as.integer(index$Replicate), methods,
    stringsAsFactors = FALSE
  )
  rows$DatasetId <- sprintf("%s/R%04d", rows$ScenarioId, rows$Replicate)
  rows$Seed <- as.integer(rows$SeedStart + rows$Replicate - 1L)
  rows$RouteId <- paste(rows$DatasetId, rows$MethodId, sep = "::")
  rows$RegistryHash <- registry$RegistryHash
  rows$FeasibilityContractHash <- contract$ContractHash
  rows$ExecutionAuthorized <- FALSE
  rows$RuleSelectionPermitted <- FALSE
  rows$InnerBootstrapPermitted <- FALSE
  rows$ConfirmationUse <- FALSE
  rows <- rows[c(
    "ScenarioId", "Replicate", "DatasetId", "Seed", "RouteId",
    "MethodId", "Backend", "Likelihood", "DesignId", "VarianceId",
    "TargetVariance", "TruthRegion", "EvaluationRole", "RegistryHash",
    "FeasibilityContractHash", "ExecutionAuthorized",
    "RuleSelectionPermitted", "InnerBootstrapPermitted", "ConfirmationUse"
  )]
  dataset_counts <- table(rows$DatasetId)
  cell_method_counts <- table(rows$ScenarioId, rows$MethodId)
  exact <- nrow(rows) == contract$FeasibilityRowCount &&
    length(unique(rows$DatasetId)) ==
      contract$FeasibilityIndependentDatasetCount &&
    all(dataset_counts == contract$MethodCount) &&
    all(cell_method_counts == contract$FeasibilityReplicatesPerCell) &&
    all(rows$Replicate >= contract$FeasibilityReplicateStart) &&
    all(rows$Replicate <= contract$FeasibilityReplicateEnd) &&
    !anyDuplicated(rows$RouteId)
  if (!exact) {
    stop("Replacement feasibility manifest accounting is not exact.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "gtheory_weak_information_feasibility_manifest_draft83d2b2b1c_v1",
    FeasibilityContractHash = contract$ContractHash,
    Rows = rows, ExactAccounting = exact
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    PlannedRows = nrow(rows),
    PlannedBackendFits = 2L * nrow(rows),
    IndependentDatasetCount = length(unique(rows$DatasetId)),
    ReservedDataGenerated = FALSE, ResultsViewed = FALSE,
    ExecutionAuthorized = FALSE, RuleSelectionPermitted = FALSE,
    InnerBootstrapPermitted = FALSE, ConfirmationUse = FALSE
  )), class = "mfrmr_gtwf_manifest")
}

mfrmr_gtwf_runtime_manifest <- function(contract = mfrmr_gtwf_contract(),
                                         registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwf_contract") ||
      !inherits(registry, "mfrmr_gtw_registry") ||
      !identical(contract$CalibrationRegistryHash, registry$RegistryHash) ||
      !isTRUE(contract$RuntimeSchemaAuthorized)) {
    stop("Runtime schema is not authorized under this contract.", call. = FALSE)
  }
  index <- expand.grid(
    Cell = seq_len(nrow(registry$Cells)),
    Method = seq_len(nrow(registry$Methods)),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  cells <- registry$Cells[index$Cell, c(
    "ScenarioId", "DesignId", "VarianceId", "TargetVariance",
    "TruthRegion", "EvaluationRole", "SeedStart"
  ), drop = FALSE]
  methods <- registry$Methods[index$Method, , drop = FALSE]
  rows <- cbind(cells, methods, stringsAsFactors = FALSE)
  rows$Replicate <- contract$RuntimeReplicate
  rows$DatasetId <- sprintf("%s/R%04d", rows$ScenarioId, rows$Replicate)
  rows$Seed <- as.integer(rows$SeedStart + rows$Replicate - 1L)
  rows$RouteId <- paste(rows$DatasetId, rows$MethodId, sep = "::")
  rows$ViewedBeforeRuntimeSchema <- TRUE
  rows$FeasibilityContractHash <- contract$ContractHash
  rows <- rows[c(
    "ScenarioId", "Replicate", "DatasetId", "Seed", "RouteId",
    "MethodId", "Backend", "Likelihood", "DesignId", "VarianceId",
    "TargetVariance", "TruthRegion", "EvaluationRole",
    "ViewedBeforeRuntimeSchema", "FeasibilityContractHash"
  )]
  if (nrow(rows) != contract$RuntimePairCount ||
      length(unique(rows$DatasetId)) != contract$RuntimeScenarioCellCount ||
      !all(table(rows$DatasetId) == contract$MethodCount) ||
      !all(rows$Replicate == contract$RuntimeReplicate) ||
      !all(rows$ViewedBeforeRuntimeSchema) || anyDuplicated(rows$RouteId)) {
    stop("Runtime manifest accounting is not exact.", call. = FALSE)
  }
  identity <- list(
    Contract = "gtheory_weak_information_runtime_manifest_draft83d2b2b1c_v1",
    FeasibilityContractHash = contract$ContractHash, Rows = rows
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity), PairCount = nrow(rows),
    BackendFitCount = 2L * nrow(rows),
    IndependentDatasetCount = length(unique(rows$DatasetId)),
    ReservedFeasibilityDataGenerated = FALSE
  )), class = "mfrmr_gtwf_runtime_manifest")
}

mfrmr_gtwf_observable_row <- function(route, pair, generation,
                                       boundary_tolerance = 1e-8) {
  if (!is.data.frame(route) || nrow(route) != 1L ||
      !inherits(pair, "mfrmr_gtwd_pair") ||
      !inherits(generation, "mfrmr_gtd2_generation")) {
    stop("Observable extraction requires one route and returned pair.",
         call. = FALSE)
  }
  components <- if (identical(route$Backend[[1L]], "lme4")) {
    mfrmr_gtd4_lme4_components(pair$FullFit, generation$Spec)
  } else {
    mfrmr_gtm_components(pair$FullFit, generation$Spec)
  }
  target <- unname(components[[generation$Scenario$TargetComponent[[1L]]]])
  residual <- unname(components[["Residual"]])
  total <- sum(components[is.finite(components)])
  pair_state <- mfrmr_gtwb_pair_summary(pair, boundary_tolerance)
  payload <- list(
    Contract = "gtheory_weak_information_feasibility_observable_draft83d2b2b1c_v1",
    RouteId = route$RouteId[[1L]], PairResultHash = pair$ResultHash,
    ComponentEstimates = components,
    TargetEstimate = target, ResidualEstimate = residual,
    TargetFractionTotal = if (is.finite(target) && is.finite(total) && total > 0)
      target / total else NA_real_,
    TargetToResidualRatio = if (is.finite(target) && is.finite(residual) &&
                                residual > 0) target / residual else NA_real_,
    RawLikelihoodDrop = pair$RawLikelihoodDrop,
    ComparisonState = pair$ComparisonState,
    LikelihoodDiagnosticAvailable = pair$LikelihoodDiagnosticAvailable,
    NegativeDropWithinTolerance = pair$NegativeDropWithinTolerance,
    FeasibilityScoreAvailable = mfrmr_gtwb_pair_available(pair) &&
      all(is.finite(c(target, residual, total))) && residual > 0 && total > 0,
    TargetBoundaryToleranceReached =
      pair_state$TargetBoundaryToleranceReached[[1L]],
    NuisanceBoundaryPresent = pair_state$NuisanceBoundaryPresent[[1L]],
    FullBoundaryComponentCount = pair$FullBoundaryComponentCount,
    ReducedBoundaryComponentCount = pair$ReducedBoundaryComponentCount,
    FullOptimizerPassed = pair$FullOptimizerPassed,
    ReducedOptimizerPassed = pair$ReducedOptimizerPassed,
    FullHessianPositiveDefinite = pair$FullHessianPositiveDefinite,
    ReducedHessianPositiveDefinite = pair$ReducedHessianPositiveDefinite,
    FullSingular = pair$FullSingular, ReducedSingular = pair$ReducedSingular,
    SameRows = pair$SameRows,
    LikelihoodDfDifference = pair$LikelihoodDfDifference,
    PValue = NA_real_, ResolutionState = "not_assigned",
    ThresholdApplied = FALSE
  )
  c(payload, list(ObservableHash = mfrmr_gta_hash(payload)))
}

mfrmr_gtwf_failure_row <- function(route, stage, message) {
  data.frame(
    route, PairReturned = FALSE, PairResultHash = "none",
    ObservableHash = "none", TargetEstimate = NA_real_,
    ResidualEstimate = NA_real_, TargetFractionTotal = NA_real_,
    TargetToResidualRatio = NA_real_, RawLikelihoodDrop = NA_real_,
    ComparisonState = "not_evaluable_route_error",
    LikelihoodDiagnosticAvailable = FALSE,
    NegativeDropWithinTolerance = FALSE,
    FeasibilityScoreAvailable = FALSE,
    TargetBoundaryToleranceReached = NA,
    NuisanceBoundaryPresent = NA,
    FullBoundaryComponentCount = NA_integer_,
    ReducedBoundaryComponentCount = NA_integer_,
    FullOptimizerPassed = FALSE, ReducedOptimizerPassed = FALSE,
    FullHessianPositiveDefinite = FALSE,
    ReducedHessianPositiveDefinite = FALSE,
    FullSingular = NA, ReducedSingular = NA, SameRows = FALSE,
    LikelihoodDfDifference = NA_integer_, PValue = NA_real_,
    ResolutionState = "not_assigned", ThresholdApplied = FALSE,
    FailureStage = as.character(stage),
    FailureMessageDigest = mfrmr_gta_hash(as.character(message)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwf_success_row <- function(route, observable) {
  data.frame(
    route, PairReturned = TRUE, PairResultHash = observable$PairResultHash,
    ObservableHash = observable$ObservableHash,
    TargetEstimate = observable$TargetEstimate,
    ResidualEstimate = observable$ResidualEstimate,
    TargetFractionTotal = observable$TargetFractionTotal,
    TargetToResidualRatio = observable$TargetToResidualRatio,
    RawLikelihoodDrop = observable$RawLikelihoodDrop,
    ComparisonState = observable$ComparisonState,
    LikelihoodDiagnosticAvailable = observable$LikelihoodDiagnosticAvailable,
    NegativeDropWithinTolerance = observable$NegativeDropWithinTolerance,
    FeasibilityScoreAvailable = observable$FeasibilityScoreAvailable,
    TargetBoundaryToleranceReached =
      observable$TargetBoundaryToleranceReached,
    NuisanceBoundaryPresent = observable$NuisanceBoundaryPresent,
    FullBoundaryComponentCount = observable$FullBoundaryComponentCount,
    ReducedBoundaryComponentCount = observable$ReducedBoundaryComponentCount,
    FullOptimizerPassed = observable$FullOptimizerPassed,
    ReducedOptimizerPassed = observable$ReducedOptimizerPassed,
    FullHessianPositiveDefinite = observable$FullHessianPositiveDefinite,
    ReducedHessianPositiveDefinite =
      observable$ReducedHessianPositiveDefinite,
    FullSingular = observable$FullSingular,
    ReducedSingular = observable$ReducedSingular,
    SameRows = observable$SameRows,
    LikelihoodDfDifference = observable$LikelihoodDfDifference,
    PValue = NA_real_, ResolutionState = "not_assigned",
    ThresholdApplied = FALSE, FailureStage = "none",
    FailureMessageDigest = "none", stringsAsFactors = FALSE
  )
}

mfrmr_gtwf_runtime_projection <- function(
    dataset_timing, pair_timing, feasibility_replicates = 25L,
    multipliers = c(Central = 1, SensitivityX2 = 2, SensitivityX4 = 4)) {
  required_dataset <- c("DatasetId", "ElapsedSeconds")
  required_pair <- c("RouteId", "MethodId", "DesignId", "ElapsedSeconds")
  if (!is.data.frame(dataset_timing) ||
      !all(required_dataset %in% names(dataset_timing)) ||
      !is.data.frame(pair_timing) ||
      !all(required_pair %in% names(pair_timing)) ||
      any(!is.finite(dataset_timing$ElapsedSeconds)) ||
      any(dataset_timing$ElapsedSeconds < 0) ||
      any(!is.finite(pair_timing$ElapsedSeconds)) ||
      any(pair_timing$ElapsedSeconds < 0) ||
      anyDuplicated(dataset_timing$DatasetId) ||
      anyDuplicated(pair_timing$RouteId)) {
    stop("Runtime projection requires complete finite nonnegative telemetry.",
         call. = FALSE)
  }
  feasibility_replicates <- as.integer(feasibility_replicates)
  if (length(feasibility_replicates) != 1L ||
      is.na(feasibility_replicates) || feasibility_replicates < 1L ||
      any(!is.finite(multipliers)) || any(multipliers <= 0)) {
    stop("Runtime projection controls are invalid.", call. = FALSE)
  }
  generation_seconds <- sum(dataset_timing$ElapsedSeconds)
  pair_seconds <- sum(pair_timing$ElapsedSeconds)
  central <- feasibility_replicates * (generation_seconds + pair_seconds)
  scenario <- data.frame(
    Projection = names(multipliers), Multiplier = as.numeric(multipliers),
    ProjectedSeconds = central * as.numeric(multipliers),
    ProjectedMinutes = central * as.numeric(multipliers) / 60,
    ProjectedHours = central * as.numeric(multipliers) / 3600,
    stringsAsFactors = FALSE
  )
  by_method <- aggregate(
    pair_timing$ElapsedSeconds,
    list(MethodId = pair_timing$MethodId), sum
  )
  names(by_method)[[2L]] <- "ObservedSchemaPairSeconds"
  by_method$ProjectedFeasibilityPairSeconds <-
    feasibility_replicates * by_method$ObservedSchemaPairSeconds
  by_method$ProjectedFeasibilityPairHours <-
    by_method$ProjectedFeasibilityPairSeconds / 3600
  by_design_method <- aggregate(
    pair_timing$ElapsedSeconds,
    list(DesignId = pair_timing$DesignId, MethodId = pair_timing$MethodId),
    sum
  )
  names(by_design_method)[[3L]] <- "ObservedSchemaPairSeconds"
  by_design_method$ProjectedFeasibilityPairSeconds <-
    feasibility_replicates * by_design_method$ObservedSchemaPairSeconds
  list(
    ObservedGenerationPreFitSeconds = generation_seconds,
    ObservedPairSeconds = pair_seconds,
    ObservedSerialSchemaSeconds = generation_seconds + pair_seconds,
    CentralProjectedFeasibilitySeconds = central,
    ScenarioProjections = scenario, ByMethod = by_method,
    ByDesignMethod = by_design_method,
    SlowestObservedRouteSeconds = max(pair_timing$ElapsedSeconds),
    SlowestObservedRouteId = pair_timing$RouteId[
      which.max(pair_timing$ElapsedSeconds)
    ],
    TimingIsPlanningTelemetry = TRUE,
    PerformanceGuarantee = FALSE
  )
}

mfrmr_gtwf_execute_runtime_schema <- function(
    contract = mfrmr_gtwf_contract(), progress = interactive()) {
  if (!inherits(contract, "mfrmr_gtwf_contract") ||
      !isTRUE(contract$RuntimeSchemaAuthorized)) {
    stop("Draft.83d2b2b1c runtime schema is not authorized.", call. = FALSE)
  }
  registry <- mfrmr_gtw_registry()
  manifest <- mfrmr_gtwf_runtime_manifest(contract, registry)
  dataset_ids <- unique(manifest$Rows$DatasetId)
  dataset_timing <- vector("list", length(dataset_ids))
  atomic_rows <- vector("list", nrow(manifest$Rows))
  pair_timing <- vector("list", nrow(manifest$Rows))
  row_index <- 0L
  for (dataset_index in seq_along(dataset_ids)) {
    dataset_id <- dataset_ids[[dataset_index]]
    routes <- manifest$Rows[
      manifest$Rows$DatasetId == dataset_id, , drop = FALSE
    ]
    if (isTRUE(progress)) {
      message(sprintf("[dataset %d/%d] %s", dataset_index,
                      length(dataset_ids), dataset_id))
    }
    unit <- NULL
    generation_error <- NULL
    timing <- system.time({
      generated <- tryCatch({
        generation <- mfrmr_gtw_generate(
          registry, routes$ScenarioId[[1L]], routes$Replicate[[1L]]
        )
        list(
          Generation = generation,
          PreFit = mfrmr_gtd3_prefit_one(generation)
        )
      }, error = function(error) error)
      if (inherits(generated, "error")) {
        generation_error <- generated
      } else {
        unit <- generated
      }
    }, gcFirst = TRUE)
    dataset_timing[[dataset_index]] <- data.frame(
      ScenarioId = routes$ScenarioId[[1L]],
      DatasetId = dataset_id, DesignId = routes$DesignId[[1L]],
      VarianceId = routes$VarianceId[[1L]],
      Replicate = routes$Replicate[[1L]], Seed = routes$Seed[[1L]],
      GenerationReturned = !is.null(unit),
      GeneratorHash = if (is.null(unit)) "none" else
        unit$Generation$GeneratorHash,
      PreFitHash = if (is.null(unit)) "none" else unit$PreFit$ResultHash,
      UserSeconds = unname(timing[["user.self"]]),
      SystemSeconds = unname(timing[["sys.self"]]),
      ElapsedSeconds = unname(timing[["elapsed"]]),
      FailureMessageDigest = if (is.null(generation_error)) "none" else
        mfrmr_gta_hash(conditionMessage(generation_error)),
      stringsAsFactors = FALSE
    )
    for (method_index in seq_len(nrow(routes))) {
      row_index <- row_index + 1L
      route <- routes[method_index, , drop = FALSE]
      result <- NULL
      pair_error <- generation_error
      pair_clock <- system.time({
        if (!is.null(unit)) {
          attempted <- tryCatch(
            mfrmr_gtwd_diagnostic_pair(
              unit$Generation, unit$PreFit, route$MethodId[[1L]],
              target_component = contract$TargetComponent
            ),
            error = function(error) error
          )
          if (inherits(attempted, "error")) {
            pair_error <- attempted
          } else {
            result <- attempted
          }
        }
      }, gcFirst = TRUE)
      if (is.null(result)) {
        stage <- if (is.null(unit)) "generation_or_prefit" else
          "diagnostic_pair"
        atomic_rows[[row_index]] <- mfrmr_gtwf_failure_row(
          route, stage, conditionMessage(pair_error)
        )
      } else {
        observable <- mfrmr_gtwf_observable_row(
          route, result, unit$Generation,
          boundary_tolerance = contract$BoundaryTolerance
        )
        atomic_rows[[row_index]] <- mfrmr_gtwf_success_row(route, observable)
      }
      pair_timing[[row_index]] <- data.frame(
        RouteId = route$RouteId[[1L]], DatasetId = route$DatasetId[[1L]],
        ScenarioId = route$ScenarioId[[1L]],
        DesignId = route$DesignId[[1L]],
        VarianceId = route$VarianceId[[1L]],
        MethodId = route$MethodId[[1L]], Backend = route$Backend[[1L]],
        Likelihood = route$Likelihood[[1L]],
        PairReturned = !is.null(result),
        UserSeconds = unname(pair_clock[["user.self"]]),
        SystemSeconds = unname(pair_clock[["sys.self"]]),
        ElapsedSeconds = unname(pair_clock[["elapsed"]]),
        stringsAsFactors = FALSE
      )
    }
  }
  dataset_timing <- do.call(rbind, dataset_timing)
  atomic_rows <- do.call(rbind, atomic_rows)
  pair_timing <- do.call(rbind, pair_timing)
  row.names(dataset_timing) <- NULL
  row.names(atomic_rows) <- NULL
  row.names(pair_timing) <- NULL
  projection <- mfrmr_gtwf_runtime_projection(
    dataset_timing, pair_timing,
    feasibility_replicates = contract$FeasibilityReplicatesPerCell,
    multipliers = contract$RuntimeProjectionMultipliers
  )
  dataset_identity <- dataset_timing[setdiff(
    names(dataset_timing), c("UserSeconds", "SystemSeconds", "ElapsedSeconds")
  )]
  atomic_identity <- atomic_rows
  pair_identity <- pair_timing[setdiff(
    names(pair_timing), c("UserSeconds", "SystemSeconds", "ElapsedSeconds")
  )]
  identity <- list(
    Contract = "gtheory_weak_information_runtime_execution_draft83d2b2b1c_v1",
    FeasibilityContractHash = contract$ContractHash,
    RuntimeManifestHash = manifest$ManifestHash,
    FunctionHashes = mfrmr_gtwf_function_hashes(),
    DatasetIdentityRows = dataset_identity,
    AtomicRows = atomic_identity,
    PairTimingIdentityRows = pair_identity
  )
  exact_accounting <- nrow(dataset_timing) ==
    contract$RuntimeScenarioCellCount &&
    nrow(atomic_rows) == contract$RuntimePairCount &&
    nrow(pair_timing) == contract$RuntimePairCount &&
    !anyDuplicated(atomic_rows$RouteId) &&
    all(table(atomic_rows$DatasetId) == contract$MethodCount)
  timing_complete <- all(is.finite(c(
    dataset_timing$ElapsedSeconds, pair_timing$ElapsedSeconds
  ))) && all(c(dataset_timing$ElapsedSeconds,
               pair_timing$ElapsedSeconds) >= 0)
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity),
    DatasetTiming = dataset_timing, PairTiming = pair_timing,
    RuntimeProjection = projection,
    PlannedPairs = contract$RuntimePairCount,
    PairReturnCount = sum(atomic_rows$PairReturned),
    FeasibilityScoreAvailableCount = sum(
      atomic_rows$FeasibilityScoreAvailable
    ),
    TypedFailureCount = sum(!atomic_rows$PairReturned),
    NuisanceBoundaryCount = sum(
      atomic_rows$NuisanceBoundaryPresent %in% TRUE
    ),
    TargetBoundaryCount = sum(
      atomic_rows$TargetBoundaryToleranceReached %in% TRUE
    ),
    SmallNegativeDropCount = sum(
      atomic_rows$FeasibilityScoreAvailable &
        atomic_rows$RawLikelihoodDrop < 0
    ),
    MaterialNegativeDropCount = sum(
      atomic_rows$PairReturned &
        !atomic_rows$NegativeDropWithinTolerance
    ),
    ExactAccountingPassed = exact_accounting,
    RuntimeTimingComplete = timing_complete,
    RuntimePlanningEvidenceReady = exact_accounting && timing_complete,
    ReservedFeasibilityDataGenerated = FALSE,
    ResolutionFeasibilityAuthorized = FALSE,
    FeasibilityEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwf_runtime_execution")
}

mfrmr_gtwf_authorization <- function(
    contract, manifest, runtime_execution) {
  if (!inherits(contract, "mfrmr_gtwf_contract") ||
      !inherits(manifest, "mfrmr_gtwf_manifest") ||
      !inherits(runtime_execution, "mfrmr_gtwf_runtime_execution") ||
      !identical(manifest$FeasibilityContractHash, contract$ContractHash) ||
      !identical(runtime_execution$FeasibilityContractHash,
                 contract$ContractHash)) {
    stop("Authorization inputs do not share one feasibility identity.",
         call. = FALSE)
  }
  gates <- data.frame(
    Gate = c(
      "manifest_exact_accounting", "reserved_data_not_generated",
      "runtime_atomic_accounting", "runtime_timing_complete",
      "checkpoint_contract_frozen", "rule_selection_disabled",
      "inner_bootstrap_disabled", "confirmation_disabled"
    ),
    Passed = c(
      manifest$PlannedRows == contract$FeasibilityRowCount &&
        manifest$IndependentDatasetCount ==
          contract$FeasibilityIndependentDatasetCount &&
        manifest$PlannedBackendFits == contract$FeasibilityBackendFitCount,
      !isTRUE(manifest$ReservedDataGenerated) &&
        !isTRUE(runtime_execution$ReservedFeasibilityDataGenerated),
      isTRUE(runtime_execution$ExactAccountingPassed),
      isTRUE(runtime_execution$RuntimeTimingComplete),
      identical(contract$CheckpointPairUnit,
                "one_method_full_reduced_pair") &&
        identical(contract$DatasetCompletionUnit,
                  "four_method_rows_same_scenario_replicate"),
      !isTRUE(manifest$RuleSelectionPermitted) &&
        !isTRUE(contract$ThresholdSelectionPermitted),
      !isTRUE(manifest$InnerBootstrapPermitted) &&
        !isTRUE(contract$InnerBootstrapPermitted),
      !isTRUE(manifest$ConfirmationUse)
    ),
    stringsAsFactors = FALSE
  )
  authorized <- all(gates$Passed)
  identity <- list(
    Contract = "gtheory_weak_information_feasibility_authorization_draft83d2b2b1c_v1",
    FeasibilityContractHash = contract$ContractHash,
    FeasibilityManifestHash = manifest$ManifestHash,
    RuntimeExecutionHash = runtime_execution$ExecutionHash,
    AuthorizationGates = gates,
    AuthorizedScope =
      "descriptive_resolution_feasibility_no_threshold_no_inner_bootstrap",
    ExecutionMode = "serial_checkpoint_every_method_pair",
    AuthorizedReplicates = c(
      contract$FeasibilityReplicateStart,
      contract$FeasibilityReplicateEnd
    )
  )
  structure(c(identity, list(
    AuthorizationHash = mfrmr_gta_hash(identity),
    ResolutionFeasibilityAuthorized = authorized,
    FeasibilityEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwf_authorization")
}
