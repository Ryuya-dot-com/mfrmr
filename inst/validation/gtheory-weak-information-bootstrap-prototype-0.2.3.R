# Draft.83d2b2b1b exact-observed-design parametric-bootstrap prototype.
#
# Repository-internal only. The authorized B = 3 schema verifies simulation,
# refitting, identity, and failure accounting. It does not calibrate size,
# power, a decision threshold, or a production bootstrap replication count.

mfrmr_gtwb_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwd_inference_contract",
    "mfrmr_gtwd_diagnostic_pair"
  )
  prototype_environment <- environment(mfrmr_gtwb_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81/83c/83d/83d2b2a/83d2b2b0/83d2b2b1a before ",
      "Draft.83d2b2b1b: ", paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (!requireNamespace("lme4", quietly = TRUE) ||
      !requireNamespace("glmmTMB", quietly = TRUE)) {
    stop("Draft.83d2b2b1b requires lme4 and glmmTMB.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtwb_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwb_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwb_contract", "mfrmr_gtwb_manifest",
    "mfrmr_gtwb_design_hash", "mfrmr_gtwb_simulate_null",
    "mfrmr_gtwb_clone_unit", "mfrmr_gtwb_pair_available",
    "mfrmr_gtwb_p_bounds", "mfrmr_gtwb_execute_schema"
  )
  prototype_environment <- environment(mfrmr_gtwb_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwb_function_hash(get(
      name, envir = prototype_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwb_contract <- function(
    registry = mfrmr_gtw_registry(),
    diagnostic_contract = mfrmr_gtwd_inference_contract(registry)) {
  mfrmr_gtwb_require_primitives()
  if (!inherits(registry, "mfrmr_gtw_registry") ||
      !inherits(diagnostic_contract, "mfrmr_gtwd_contract")) {
    stop("Draft.83d2b2b1b requires the registered diagnostic contract.",
         call. = FALSE)
  }
  scenario_ids <- paste0(
    "GT-WI-baseline_complete-",
    c("exact_zero", "numerical_near_zero", "reference_1200")
  )
  if (!all(scenario_ids %in% registry$Cells$ScenarioId)) {
    stop("The three frozen bootstrap schema scenarios are unavailable.",
         call. = FALSE)
  }
  sources <- data.frame(
    SourceId = c(
      "lme4_bootMer_current", "glmmTMB_simulate_current",
      "Phipson_Smyth_2010", "Guedon_Baey_Kuhn_2023_preprint",
      "Stringer_Negrea_2026_preprint"
    ),
    Locator = c(
      "https://lme4.github.io/lme4/reference/bootMer.html",
      "https://glmmtmb.github.io/glmmTMB/articles/sim.html",
      "doi:10.2202/1544-6115.1585",
      "https://arxiv.org/abs/2306.10779",
      "https://arxiv.org/abs/2604.25744"
    ),
    Role = c(
      "backend_native_unconditional_parametric_simulation",
      "backend_native_random_effect_resampling",
      "nonzero_plus_one_monte_carlo_convention",
      "nuisance_boundary_warning_not_implemented_shrinked_method",
      "future_acceleration_monitor_not_dependency"
    ),
    stringsAsFactors = FALSE
  )
  identity <- list(
    Contract = "gtheory_weak_information_bootstrap_draft83d2b2b1b_v1",
    CalibrationRegistryHash = registry$RegistryHash,
    DiagnosticContractHash = diagnostic_contract$ContractHash,
    MathematicalContractArtifact =
      "gtheory-weak-information-bootstrap-contract-0.2.3.md",
    Procedure = "plain_plugin_parametric_bootstrap_fitted_reduced_model",
    ExactDesignMeaning = paste(
      "same rows, order, covariates, factor levels, incidence, missingness,",
      "fixed-effect design, and non-target random-effect terms"
    ),
    ExactFiniteSampleTest = FALSE,
    ShrinkedParametricBootstrapImplemented = FALSE,
    TargetComponent = "Rater",
    ScenarioIds = scenario_ids,
    OuterReplicate = 2L,
    MethodIds = registry$Methods$MethodId,
    BootstrapReplicates = 3L,
    BootstrapSeedBase = 832300000L,
    NegativeLikelihoodTolerance = 1e-6,
    BoundaryTolerance = 1e-8,
    ObservedRouteCount = 12L,
    BootstrapPairCount = 36L,
    SchemaFitCount = 96L,
    MonteCarloGridWidth = 0.25,
    ResolutionFeasibilityRows = 3000L,
    ResolutionFeasibilityFitCount = 6000L,
    NaiveNestedBootstrapFitCountB199 = 1200000L,
    Sources = sources,
    BackendSimulationHashes = c(
      lme4_simulate_merMod = mfrmr_gtwb_function_hash(
        getFromNamespace("simulate.merMod", "lme4")
      ),
      glmmTMB_simulate = mfrmr_gtwb_function_hash(
        getFromNamespace("simulate.glmmTMB", "glmmTMB")
      )
    ),
    BackendVersions = c(
      lme4 = as.character(utils::packageVersion("lme4")),
      glmmTMB = as.character(utils::packageVersion("glmmTMB"))
    ),
    FunctionHashes = mfrmr_gtwb_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    MechanicsSchemaAuthorized = TRUE,
    ResolutionFeasibilityAuthorized = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    FeasibilityEvidenceReady = FALSE, CalibrationEvidenceReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwb_contract")
}

mfrmr_gtwb_manifest <- function(contract = mfrmr_gtwb_contract(),
                                 registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwb_contract") ||
      !inherits(registry, "mfrmr_gtw_registry") ||
      !identical(contract$CalibrationRegistryHash, registry$RegistryHash)) {
    stop("Bootstrap contract and calibration registry identities differ.",
         call. = FALSE)
  }
  parent <- expand.grid(
    ScenarioId = contract$ScenarioIds,
    MethodId = contract$MethodIds,
    stringsAsFactors = FALSE
  )
  cell_index <- match(parent$ScenarioId, registry$Cells$ScenarioId)
  method_index <- match(parent$MethodId, registry$Methods$MethodId)
  parent$Replicate <- contract$OuterReplicate
  parent$ParentDatasetId <- sprintf("%s/R%04d", parent$ScenarioId,
                                    parent$Replicate)
  parent$Backend <- registry$Methods$Backend[method_index]
  parent$Likelihood <- registry$Methods$Likelihood[method_index]
  parent$DesignId <- registry$Cells$DesignId[cell_index]
  parent$VarianceId <- registry$Cells$VarianceId[cell_index]
  parent$TargetVariance <- registry$Cells$TargetVariance[cell_index]
  parent$TruthRegion <- registry$Cells$TruthRegion[cell_index]
  parent$EvaluationRole <- registry$Cells$EvaluationRole[cell_index]
  parent$ParentRouteId <- paste(parent$ParentDatasetId, parent$MethodId,
                                sep = "::")
  parent <- parent[c(
    "ScenarioId", "Replicate", "ParentDatasetId", "ParentRouteId",
    "MethodId", "Backend", "Likelihood", "DesignId", "VarianceId",
    "TargetVariance", "TruthRegion", "EvaluationRole"
  )]
  bootstrap <- parent[rep(seq_len(nrow(parent)),
                          each = contract$BootstrapReplicates), , drop = FALSE]
  bootstrap$BootstrapIndex <- rep(
    seq_len(contract$BootstrapReplicates), times = nrow(parent)
  )
  scenario_index <- match(bootstrap$ScenarioId, contract$ScenarioIds)
  method_index <- match(bootstrap$MethodId, contract$MethodIds)
  bootstrap$BootstrapSeed <- as.integer(
    contract$BootstrapSeedBase + scenario_index * 10000L +
      method_index * 100L + bootstrap$BootstrapIndex
  )
  bootstrap$BootstrapDatasetId <- paste0(
    bootstrap$ParentRouteId, "/PB", sprintf("%04d", bootstrap$BootstrapIndex)
  )
  bootstrap$ContractHash <- contract$ContractHash
  if (nrow(parent) != contract$ObservedRouteCount ||
      nrow(bootstrap) != contract$BootstrapPairCount ||
      anyDuplicated(parent$ParentRouteId) ||
      anyDuplicated(bootstrap$BootstrapDatasetId) ||
      anyDuplicated(bootstrap$BootstrapSeed)) {
    stop("The frozen bootstrap manifest does not have exact accounting.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "gtheory_weak_information_bootstrap_manifest_draft83d2b2b1b_v1",
    BootstrapContractHash = contract$ContractHash,
    ParentRoutes = parent, BootstrapRows = bootstrap
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    ObservedRouteCount = nrow(parent),
    BootstrapPairCount = nrow(bootstrap)
  )), class = "mfrmr_gtwb_manifest")
}

mfrmr_gtwb_design_hash <- function(data, response = "Score") {
  if (!is.data.frame(data) || length(response) != 1L ||
      !response %in% names(data)) {
    stop("Design hashing requires a data frame and one response column.",
         call. = FALSE)
  }
  mfrmr_gta_hash(list(
    RowNames = row.names(data),
    DesignData = data[setdiff(names(data), response)],
    ResponsePosition = match(response, names(data)),
    ColumnNames = names(data)
  ))
}

mfrmr_gtwb_simulate_null <- function(reduced_fit, backend, seed,
                                      expected_rows) {
  backend <- match.arg(as.character(backend), c("lme4", "glmmTMB"))
  seed <- as.integer(seed)
  expected_rows <- as.integer(expected_rows)
  if (length(seed) != 1L || is.na(seed) || seed <= 0L ||
      length(expected_rows) != 1L || is.na(expected_rows) ||
      expected_rows <= 0L) {
    stop("Simulation seed and expected row count must be positive integers.",
         call. = FALSE)
  }
  old_seed <- if (exists(".Random.seed", envir = .GlobalEnv,
                         inherits = FALSE)) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else NULL
  on.exit({
    if (is.null(old_seed)) {
      if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    } else {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(seed)
  simulated <- if (identical(backend, "lme4")) {
    stats::simulate(
      reduced_fit, nsim = 1L, re.form = NA
    )[[1L]]
  } else {
    stats::simulate(reduced_fit, nsim = 1L)[[1L]]
  }
  simulated <- as.numeric(simulated)
  if (length(simulated) != expected_rows || any(!is.finite(simulated))) {
    stop("Backend-native null simulation returned an invalid response.",
         call. = FALSE)
  }
  simulated
}

mfrmr_gtwb_clone_unit <- function(generation, prefit, response, seed,
                                   parent_route_id, bootstrap_index) {
  if (!inherits(generation, "mfrmr_gtd2_generation") ||
      !inherits(prefit, "mfrmr_gtd3_prefit") || !prefit$PreFitEligible) {
    stop("Bootstrap cloning requires an eligible generated/prefit unit.",
         call. = FALSE)
  }
  data <- prefit$StructuralRankAudit$PreparedData$Data
  response <- as.numeric(response)
  if (length(response) != nrow(data) || any(!is.finite(response))) {
    stop("Bootstrap response does not match the retained observed rows.",
         call. = FALSE)
  }
  design_hash_before <- mfrmr_gtwb_design_hash(data, generation$Spec$ScoreColumn)
  data[[generation$Spec$ScoreColumn]] <- response
  design_hash_after <- mfrmr_gtwb_design_hash(data, generation$Spec$ScoreColumn)
  if (!identical(design_hash_before, design_hash_after)) {
    stop("Replacing the response changed the observed design.", call. = FALSE)
  }
  response_hash <- mfrmr_gta_hash(list(
    ParentRouteId = parent_route_id, BootstrapIndex = bootstrap_index,
    BootstrapSeed = seed, Response = response
  ))
  data_hash <- mfrmr_gta_hash(data)
  cloned_generation <- generation
  cloned_generation$AnalysisData <- data
  cloned_generation$GeneratorHash <- mfrmr_gta_hash(list(
    ParentGeneratorHash = generation$GeneratorHash,
    BootstrapResponseHash = response_hash, BootstrapDataHash = data_hash
  ))
  cloned_prefit <- prefit
  cloned_prefit$StructuralRankAudit$PreparedData$Data <- data
  cloned_prefit$StructuralRankAudit$PreparedData$RetainedDataHash <- data_hash
  cloned_prefit$ResultHash <- mfrmr_gta_hash(list(
    ParentPreFitHash = prefit$ResultHash,
    BootstrapResponseHash = response_hash, BootstrapDataHash = data_hash,
    DesignHash = design_hash_after
  ))
  list(
    Generation = cloned_generation, PreFit = cloned_prefit,
    Data = data, ResponseHash = response_hash, DataHash = data_hash,
    DesignHash = design_hash_after, ExactDesignPreserved = TRUE
  )
}

mfrmr_gtwb_pair_available <- function(pair) {
  inherits(pair, "mfrmr_gtwd_pair") &&
    isTRUE(pair$LikelihoodDiagnosticAvailable) &&
    isTRUE(pair$NegativeDropWithinTolerance) &&
    is.finite(pair$RawLikelihoodDrop)
}

mfrmr_gtwb_p_bounds <- function(observed_statistic, bootstrap_statistics,
                                 available, planned_b) {
  planned_b <- as.integer(planned_b)
  bootstrap_statistics <- as.numeric(bootstrap_statistics)
  available <- as.logical(available)
  if (length(planned_b) != 1L || is.na(planned_b) || planned_b < 1L ||
      length(bootstrap_statistics) != planned_b ||
      length(available) != planned_b || anyNA(available)) {
    stop("Monte Carlo bounds require every planned bootstrap row.",
         call. = FALSE)
  }
  valid <- available & is.finite(bootstrap_statistics)
  failure_count <- sum(!valid)
  if (length(observed_statistic) != 1L || !is.finite(observed_statistic)) {
    return(data.frame(
      PlannedB = planned_b, ExceedanceCount = NA_integer_,
      FailureCount = failure_count, PLower = NA_real_, PUpper = NA_real_,
      PPoint = NA_real_, GridWidth = 1 / (planned_b + 1),
      BoundsState = "observed_statistic_unavailable",
      stringsAsFactors = FALSE
    ))
  }
  exceedance_count <- sum(
    bootstrap_statistics[valid] >= observed_statistic
  )
  lower <- (1 + exceedance_count) / (planned_b + 1)
  upper <- (1 + exceedance_count + failure_count) / (planned_b + 1)
  data.frame(
    PlannedB = planned_b, ExceedanceCount = exceedance_count,
    FailureCount = failure_count, PLower = lower, PUpper = upper,
    PPoint = if (failure_count == 0L) lower else NA_real_,
    GridWidth = 1 / (planned_b + 1),
    BoundsState = if (failure_count == 0L) {
      "complete_plus_one_point_mechanics_only"
    } else {
      "failure_aware_plus_one_bounds_mechanics_only"
    },
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwb_pair_summary <- function(pair, boundary_tolerance) {
  target_boundary <- isTRUE(
    pair$CoordinateDiagnostic$TargetBoundaryToleranceReached
  )
  full_count <- as.integer(pair$FullBoundaryComponentCount)
  reduced_count <- as.integer(pair$ReducedBoundaryComponentCount)
  data.frame(
    PairReturned = TRUE, PairResultHash = pair$ResultHash,
    RawLikelihoodDrop = pair$RawLikelihoodDrop,
    LikelihoodDiagnosticAvailable = pair$LikelihoodDiagnosticAvailable,
    NegativeDropWithinTolerance = pair$NegativeDropWithinTolerance,
    BootstrapStatisticAvailable = mfrmr_gtwb_pair_available(pair),
    SameRows = pair$SameRows,
    LikelihoodDfDifference = pair$LikelihoodDfDifference,
    FullBoundaryComponentCount = full_count,
    ReducedBoundaryComponentCount = reduced_count,
    TargetBoundaryToleranceReached = target_boundary,
    FullNuisanceBoundaryComponentCount = full_count - as.integer(target_boundary),
    ReducedNuisanceBoundaryComponentCount = reduced_count,
    NuisanceBoundaryPresent =
      (full_count - as.integer(target_boundary) > 0L) || reduced_count > 0L,
    BoundaryTolerance = boundary_tolerance,
    FailureStage = "none", FailureMessageDigest = "none",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwb_failure_summary <- function(message, boundary_tolerance,
                                        failure_stage) {
  data.frame(
    PairReturned = FALSE, PairResultHash = "none",
    RawLikelihoodDrop = NA_real_, LikelihoodDiagnosticAvailable = FALSE,
    NegativeDropWithinTolerance = FALSE,
    BootstrapStatisticAvailable = FALSE, SameRows = FALSE,
    LikelihoodDfDifference = NA_integer_,
    FullBoundaryComponentCount = NA_integer_,
    ReducedBoundaryComponentCount = NA_integer_,
    TargetBoundaryToleranceReached = NA,
    FullNuisanceBoundaryComponentCount = NA_integer_,
    ReducedNuisanceBoundaryComponentCount = NA_integer_,
    NuisanceBoundaryPresent = NA, BoundaryTolerance = boundary_tolerance,
    FailureStage = as.character(failure_stage),
    FailureMessageDigest = mfrmr_gta_hash(as.character(message)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwb_execute_schema <- function(
    contract = mfrmr_gtwb_contract(), progress = interactive()) {
  if (!inherits(contract, "mfrmr_gtwb_contract") ||
      !isTRUE(contract$MechanicsSchemaAuthorized)) {
    stop("Draft.83d2b2b1b mechanics schema is not authorized.", call. = FALSE)
  }
  registry <- mfrmr_gtw_registry()
  manifest <- mfrmr_gtwb_manifest(contract, registry)
  observed_rows <- vector("list", nrow(manifest$ParentRoutes))
  bootstrap_rows <- vector("list", nrow(manifest$BootstrapRows))
  pair_details <- vector("list", nrow(manifest$BootstrapRows))
  unit_cache <- list()
  observed_pair_cache <- list()

  for (index in seq_len(nrow(manifest$ParentRoutes))) {
    route <- manifest$ParentRoutes[index, , drop = FALSE]
    dataset_id <- route$ParentDatasetId[[1L]]
    if (is.null(unit_cache[[dataset_id]])) {
      generation <- mfrmr_gtw_generate(
        registry, route$ScenarioId[[1L]], route$Replicate[[1L]]
      )
      unit_cache[[dataset_id]] <- list(
        Generation = generation,
        PreFit = mfrmr_gtd3_prefit_one(generation)
      )
    }
    unit <- unit_cache[[dataset_id]]
    observed_data <- unit$PreFit$StructuralRankAudit$PreparedData$Data
    observed_data_hash <- mfrmr_gta_hash(observed_data)
    observed_design_hash <- mfrmr_gtwb_design_hash(
      observed_data, unit$Generation$Spec$ScoreColumn
    )
    if (isTRUE(progress)) {
      message(sprintf("[observed %d/%d] %s", index,
                      nrow(manifest$ParentRoutes), route$ParentRouteId[[1L]]))
    }
    observed <- tryCatch(
      mfrmr_gtwd_diagnostic_pair(
        unit$Generation, unit$PreFit, route$MethodId[[1L]],
        target_component = contract$TargetComponent,
        boundary_tolerance = contract$BoundaryTolerance,
        negative_likelihood_tolerance =
          contract$NegativeLikelihoodTolerance
      ),
      error = function(error) error
    )
    if (inherits(observed, "error")) {
      observed_summary <- mfrmr_gtwb_failure_summary(
        conditionMessage(observed), contract$BoundaryTolerance,
        "observed_refit"
      )
      observed_pair_cache[[route$ParentRouteId[[1L]]]] <- NULL
    } else {
      observed_summary <- mfrmr_gtwb_pair_summary(
        observed, contract$BoundaryTolerance
      )
      observed_pair_cache[[route$ParentRouteId[[1L]]]] <- observed
    }
    observed_rows[[index]] <- cbind(
      route, ObservedDataHash = observed_data_hash,
      ObservedDesignHash = observed_design_hash, observed_summary,
      stringsAsFactors = FALSE
    )
  }

  for (index in seq_len(nrow(manifest$BootstrapRows))) {
    row <- manifest$BootstrapRows[index, , drop = FALSE]
    unit <- unit_cache[[row$ParentDatasetId[[1L]]]]
    observed <- observed_pair_cache[[row$ParentRouteId[[1L]]]]
    observed_row <- observed_rows[[match(
      row$ParentRouteId[[1L]], manifest$ParentRoutes$ParentRouteId
    )]]
    if (isTRUE(progress)) {
      message(sprintf("[bootstrap %d/%d] %s", index,
                      nrow(manifest$BootstrapRows),
                      row$BootstrapDatasetId[[1L]]))
    }
    simulation <- tryCatch({
      if (!inherits(observed, "mfrmr_gtwd_pair")) {
        stop("Observed reduced fit is unavailable.", call. = FALSE)
      }
      response <- mfrmr_gtwb_simulate_null(
        observed$ReducedFit, row$Backend[[1L]], row$BootstrapSeed[[1L]],
        nrow(unit$PreFit$StructuralRankAudit$PreparedData$Data)
      )
      cloned <- mfrmr_gtwb_clone_unit(
        unit$Generation, unit$PreFit, response,
        row$BootstrapSeed[[1L]], row$ParentRouteId[[1L]],
        row$BootstrapIndex[[1L]]
      )
      if (!identical(cloned$DesignHash,
                     observed_row$ObservedDesignHash[[1L]]) ||
          identical(cloned$DataHash,
                    observed_row$ObservedDataHash[[1L]])) {
        stop("Generated response failed exact-design/data-identity checks.",
             call. = FALSE)
      }
      cloned
    }, error = function(error) error)
    if (inherits(simulation, "error")) {
      generated <- data.frame(
        GeneratedResponseHash = "unavailable",
        GeneratedDataHash = "unavailable", GeneratedDesignHash = "unavailable",
        ExactDesignPreserved = FALSE,
        DataIdentityDistinctFromObserved = FALSE, stringsAsFactors = FALSE
      )
      summary <- mfrmr_gtwb_failure_summary(
        paste("simulation_or_identity:", conditionMessage(simulation)),
        contract$BoundaryTolerance, "simulation_or_identity"
      )
      pair_details[[index]] <- NULL
    } else {
      generated <- data.frame(
        GeneratedResponseHash = simulation$ResponseHash,
        GeneratedDataHash = simulation$DataHash,
        GeneratedDesignHash = simulation$DesignHash,
        ExactDesignPreserved = simulation$ExactDesignPreserved &&
          identical(simulation$DesignHash,
                    observed_row$ObservedDesignHash[[1L]]),
        DataIdentityDistinctFromObserved =
          !identical(simulation$DataHash,
                     observed_row$ObservedDataHash[[1L]]),
        stringsAsFactors = FALSE
      )
      pair <- tryCatch(
        mfrmr_gtwd_diagnostic_pair(
          simulation$Generation, simulation$PreFit, row$MethodId[[1L]],
          target_component = contract$TargetComponent,
          boundary_tolerance = contract$BoundaryTolerance,
          negative_likelihood_tolerance =
            contract$NegativeLikelihoodTolerance
        ),
        error = function(error) error
      )
      if (inherits(pair, "error")) {
        summary <- mfrmr_gtwb_failure_summary(
          paste("refit:", conditionMessage(pair)), contract$BoundaryTolerance,
          "bootstrap_refit"
        )
        pair_details[[index]] <- NULL
      } else {
        summary <- mfrmr_gtwb_pair_summary(pair, contract$BoundaryTolerance)
        pair_details[[index]] <- pair
      }
    }
    bootstrap_rows[[index]] <- cbind(row, generated, summary,
                                     stringsAsFactors = FALSE)
  }
  observed_rows <- do.call(rbind, observed_rows)
  bootstrap_rows <- do.call(rbind, bootstrap_rows)
  row.names(observed_rows) <- NULL
  row.names(bootstrap_rows) <- NULL

  bounds <- lapply(seq_len(nrow(observed_rows)), function(index) {
    observed <- observed_rows[index, , drop = FALSE]
    selected <- bootstrap_rows[
      bootstrap_rows$ParentRouteId == observed$ParentRouteId[[1L]], ,
      drop = FALSE
    ]
    value <- mfrmr_gtwb_p_bounds(
      if (isTRUE(observed$BootstrapStatisticAvailable[[1L]])) {
        observed$RawLikelihoodDrop[[1L]]
      } else NA_real_,
      selected$RawLikelihoodDrop, selected$BootstrapStatisticAvailable,
      contract$BootstrapReplicates
    )
    cbind(
      observed[c(
        "ParentRouteId", "ScenarioId", "MethodId", "Backend", "Likelihood"
      )],
      value, NuisanceBoundaryObserved = observed$NuisanceBoundaryPresent,
      NuisanceBoundaryBootstrapCount = sum(
        selected$NuisanceBoundaryPresent %in% TRUE
      ), stringsAsFactors = FALSE
    )
  })
  bounds <- do.call(rbind, bounds)
  row.names(bounds) <- NULL
  exact_accounting <- nrow(observed_rows) == contract$ObservedRouteCount &&
    nrow(bootstrap_rows) == contract$BootstrapPairCount &&
    all(table(bootstrap_rows$ParentRouteId) == contract$BootstrapReplicates)
  design_passed <- all(bootstrap_rows$ExactDesignPreserved) &&
    all(bootstrap_rows$DataIdentityDistinctFromObserved)
  identity <- list(
    Contract = "gtheory_weak_information_bootstrap_schema_draft83d2b2b1b_v1",
    BootstrapContractHash = contract$ContractHash,
    BootstrapManifestHash = manifest$ManifestHash,
    FunctionHashes = mfrmr_gtwb_function_hashes(),
    ObservedRows = observed_rows, BootstrapRows = bootstrap_rows,
    MonteCarloBounds = bounds
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity), PairDetails = pair_details,
    PlannedObservedRoutes = contract$ObservedRouteCount,
    PlannedBootstrapPairs = contract$BootstrapPairCount,
    PlannedFitCount = contract$SchemaFitCount,
    ObservedPairReturnCount = sum(observed_rows$PairReturned),
    BootstrapPairReturnCount = sum(bootstrap_rows$PairReturned),
    BootstrapStatisticAvailableCount = sum(
      bootstrap_rows$BootstrapStatisticAvailable
    ),
    BootstrapFailureCount = sum(
      !bootstrap_rows$BootstrapStatisticAvailable
    ),
    ExactAccountingPassed = exact_accounting,
    ExactDesignIdentityPassed = design_passed,
    MechanicsSchemaEvidenceReady = exact_accounting && design_passed,
    ResolutionFeasibilityAuthorized = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    FeasibilityEvidenceReady = FALSE, CalibrationEvidenceReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwb_schema_execution")
}
