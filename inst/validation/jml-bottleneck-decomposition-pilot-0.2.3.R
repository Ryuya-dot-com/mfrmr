# Repository-only JML bottleneck decomposition runner for mfrmr 0.2.3.
#
# This runner is one-replicate calibration instrumentation. It does not
# estimate operating characteristics, freeze a capacity envelope, authorize
# confirmation, or establish an estimator or external-software ranking.

mfrmr_jml_profile_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-bottleneck-decomposition-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path(
      "inst", "validation", "jml-bottleneck-decomposition-pilot-0.2.3.R"
    ),
    "jml-bottleneck-decomposition-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_jml_profile_require_support <- function() {
  target_env <- environment(mfrmr_jml_profile_require_support)
  required <- c(
    "mfrmr_target_bridge_require_support", "mfrmr_target_bridge_thresholds",
    "mfrmr_target_bridge_readiness", "mfrmr_target_bridge_recovery",
    "mfrmr_target_bridge_os_memory", "mfrmr_target_scale_memory",
    "mfrmr_target_scale_artifact_inventory", "mfrmr_gpcm_stress_fun",
    "mfrmr_gpcm_stress_capture", "mfrmr_gpcm_stress_support",
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_runtime_package_identity",
    "mfrmr_gpcm_repilot_capability_manifest",
    "mfrmr_gpcm_repilot_package_content_identity"
  )
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    candidates <- c(
      if (!is.na(mfrmr_jml_profile_source_dir)) {
        file.path(
          mfrmr_jml_profile_source_dir,
          "target-scale-baseline-bridge-pilot-0.2.3.R"
        )
      } else character(0),
      file.path(
        "inst", "validation", "target-scale-baseline-bridge-pilot-0.2.3.R"
      ),
      "target-scale-baseline-bridge-pilot-0.2.3.R"
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("Cannot locate target baseline profiling support.", call. = FALSE)
    }
    sys.source(path, envir = target_env)
    mfrmr_target_bridge_require_support()
  }
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("JML profiling support did not load completely.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_jml_profile_cells <- function() {
  person <- data.frame(
    DataCellId = sprintf("JBP-P%03d", c(50L, 100L, 200L, 400L)),
    PrimaryAxis = "person_and_rows",
    AxisMembership = "person_and_rows",
    MasterGroup = "person_master",
    Seed = 249001L,
    MasterPersons = 400L, MasterRaters = 3L, MasterCriteria = 4L,
    NPersons = c(50L, 100L, 200L, 400L),
    ActiveRaters = 3L, RatersPerPerson = 3L,
    ActiveCriteria = 4L, CriteriaPerPerson = 4L,
    ForcedExtremeFraction = 0,
    stringsAsFactors = FALSE
  )
  rater <- data.frame(
    DataCellId = sprintf("JBP-R%02d", c(3L, 6L, 12L)),
    PrimaryAxis = "rater_panel_topology_fixed_rows",
    AxisMembership = "rater_panel_topology_fixed_rows",
    MasterGroup = "rater_master",
    Seed = 249002L,
    MasterPersons = 200L, MasterRaters = 12L, MasterCriteria = 4L,
    NPersons = 200L,
    ActiveRaters = c(3L, 6L, 12L), RatersPerPerson = 3L,
    ActiveCriteria = 4L, CriteriaPerPerson = 4L,
    ForcedExtremeFraction = 0,
    stringsAsFactors = FALSE
  )
  criterion <- data.frame(
    DataCellId = c("JBP-C04-E04", "JBP-C08-E04", "JBP-C12-E04"),
    PrimaryAxis = "criterion_step_dimension_fixed_rows",
    AxisMembership = c(
      "criterion_step_dimension_fixed_rows",
      "criterion_step_dimension_fixed_rows",
      "criterion_step_dimension_fixed_rows;row_exposure_fixed_dimension"
    ),
    MasterGroup = "criterion_master",
    Seed = 249003L,
    MasterPersons = 200L, MasterRaters = 3L, MasterCriteria = 12L,
    NPersons = 200L,
    ActiveRaters = 3L, RatersPerPerson = 3L,
    ActiveCriteria = c(4L, 8L, 12L), CriteriaPerPerson = 4L,
    ForcedExtremeFraction = 0,
    stringsAsFactors = FALSE
  )
  exposure <- data.frame(
    DataCellId = c("JBP-C12-E02", "JBP-C12-E08", "JBP-C12-E12"),
    PrimaryAxis = "row_exposure_fixed_dimension",
    AxisMembership = "row_exposure_fixed_dimension",
    MasterGroup = "criterion_master",
    Seed = 249003L,
    MasterPersons = 200L, MasterRaters = 3L, MasterCriteria = 12L,
    NPersons = 200L,
    ActiveRaters = 3L, RatersPerPerson = 3L,
    ActiveCriteria = 12L, CriteriaPerPerson = c(2L, 8L, 12L),
    ForcedExtremeFraction = 0,
    stringsAsFactors = FALSE
  )
  extreme <- person[person$NPersons == 200L, , drop = FALSE]
  extreme$DataCellId <- "JBP-P200-X20"
  extreme$PrimaryAxis <- "forced_extreme_fixed_rows_dimension"
  extreme$AxisMembership <- "forced_extreme_fixed_rows_dimension"
  extreme$ForcedExtremeFraction <- 0.20
  out <- rbind(person, rater, criterion, exposure, extreme)
  out$Model <- "PCM"
  out$NCategories <- 5L
  out$DataRole <- "jml_computation_decomposition_calibration"
  out$ConfirmationAuthorized <- FALSE
  out$EvidenceUse <- "computation_decomposition_calibration_only"
  row.names(out) <- NULL
  out
}

mfrmr_jml_profile_registry <- function() {
  mfrmr_jml_profile_require_support()
  cells <- mfrmr_jml_profile_cells()
  base_routes <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
    cell <- cells[i, , drop = FALSE]
    rbind(
      cbind(cell, Method = "JML", OptimizerRequested = "auto"),
      cbind(cell, Method = "MML", OptimizerRequested = "auto")
    )
  }))
  bfgs_ids <- c(
    "JBP-P200", "JBP-P400", "JBP-R12", "JBP-C12-E04",
    "JBP-P200-X20"
  )
  bfgs_controls <- cells[
    match(bfgs_ids, cells$DataCellId), , drop = FALSE
  ]
  bfgs_controls$Method <- "JML"
  bfgs_controls$OptimizerRequested <- "BFGS"
  reference <- cells[cells$DataCellId == "JBP-P200", , drop = FALSE]
  controls <- rbind(
    bfgs_controls,
    cbind(reference, Method = "JML", OptimizerRequested = "L-BFGS-B")
  )
  routes <- rbind(base_routes, controls)
  routes$ScenarioId <- paste(
    routes$DataCellId, routes$Method, routes$OptimizerRequested, sep = "-"
  )
  routes$ExpectedFitState <- ifelse(
    routes$DataCellId == "JBP-P200-X20" & routes$Method == "JML",
    "must_not_be_inference_ready", "profile_only"
  )
  routes$ExecutedReplicates <- 1L
  routes$PCAState <- "not_run_pending_computability_contract"
  routes$NumericExternalEligible <- FALSE
  routes$ExternalReason <- "internal_computation_profile_not_external_validation"
  routes$ConfirmationAuthorized <- FALSE
  routes$EvidenceUse <- "computation_decomposition_calibration_only"
  routes <- routes[order(
    match(routes$DataCellId, cells$DataCellId),
    match(routes$Method, c("JML", "MML")),
    match(routes$OptimizerRequested, c("auto", "BFGS", "L-BFGS-B"))
  ), , drop = FALSE]
  row.names(routes) <- NULL
  canonical <- routes[, setdiff(names(routes), "ScenarioId"), drop = FALSE]
  routes$DeclaredManifestSHA256 <- mfrmr_gpcm_repilot_hash_object(canonical)
  routes
}

mfrmr_jml_profile_master <- function(cell) {
  criteria <- sprintf("C%02d", seq_len(as.integer(cell$MasterCriteria)))
  spec <- mfrmr_gpcm_stress_fun("build_mfrm_sim_spec")(
    n_person = as.integer(cell$MasterPersons),
    n_rater = as.integer(cell$MasterRaters),
    n_criterion = as.integer(cell$MasterCriteria),
    raters_per_person = as.integer(cell$MasterRaters),
    score_levels = as.integer(cell$NCategories),
    theta_sd = 1, rater_sd = 0.55, criterion_sd = 0.35,
    thresholds = mfrmr_target_bridge_thresholds(
      "PCM", criteria, as.integer(cell$NCategories)
    ),
    model = "PCM", step_facet = "Criterion", assignment = "crossed"
  )
  data <- mfrmr_gpcm_stress_fun("simulate_mfrm_data")(
    sim_spec = spec, seed = as.integer(cell$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  master_truth_hash <- mfrmr_gpcm_repilot_hash_object(list(
    person = truth$person, facets = truth$facets,
    step_table = truth$step_table, population = truth$population
  ))
  list(data = data, spec = spec, truth = truth,
       MasterTruthHash = master_truth_hash)
}

mfrmr_jml_profile_ring_keep <- function(person_index, level_index,
                                         active_levels, take) {
  active_levels <- as.integer(active_levels)
  take <- as.integer(take)
  if (take >= active_levels) return(level_index <= active_levels)
  start <- ((person_index - 1L) %% active_levels) + 1L
  distance <- (level_index - start) %% active_levels
  level_index <= active_levels & distance < take
}

mfrmr_jml_profile_cell_truth <- function(truth, data) {
  persons <- unique(as.character(data$Person))
  raters <- unique(as.character(data$Rater))
  criteria <- unique(as.character(data$Criterion))
  steps <- as.data.frame(truth$step_table %||% data.frame(),
                         stringsAsFactors = FALSE)
  if (nrow(steps) > 0L && "StepFacet" %in% names(steps)) {
    steps <- steps[steps$StepFacet %in% criteria, , drop = FALSE]
  }
  mfrmr_gpcm_repilot_hash_object(list(
    person = truth$person[names(truth$person) %in% persons],
    Rater = truth$facets$Rater[names(truth$facets$Rater) %in% raters],
    Criterion = truth$facets$Criterion[
      names(truth$facets$Criterion) %in% criteria
    ],
    step_table = steps
  ))
}

mfrmr_jml_profile_build <- function(cell) {
  cell <- as.list(cell)
  master <- mfrmr_jml_profile_master(cell)
  data <- master$data
  person_index <- match(data$Person, sprintf(
    "P%03d", seq_len(as.integer(cell$MasterPersons))
  ))
  rater_index <- match(data$Rater, sprintf(
    "R%02d", seq_len(as.integer(cell$MasterRaters))
  ))
  criterion_index <- match(data$Criterion, sprintf(
    "C%02d", seq_len(as.integer(cell$MasterCriteria))
  ))
  keep <- person_index <= as.integer(cell$NPersons) &
    mfrmr_jml_profile_ring_keep(
      person_index, rater_index, cell$ActiveRaters, cell$RatersPerPerson
    ) &
    mfrmr_jml_profile_ring_keep(
      person_index, criterion_index,
      cell$ActiveCriteria, cell$CriteriaPerPerson
    )
  data <- data[keep, , drop = FALSE]
  forced_fraction <- as.numeric(cell$ForcedExtremeFraction)
  forced_persons <- character(0)
  if (is.finite(forced_fraction) && forced_fraction > 0) {
    n_force <- as.integer(floor(as.integer(cell$NPersons) * forced_fraction))
    forced_persons <- sprintf("P%03d", seq_len(n_force))
    split <- as.integer(ceiling(n_force / 2))
    low <- forced_persons[seq_len(split)]
    high <- setdiff(forced_persons, low)
    data$Score[data$Person %in% low] <- 1L
    data$Score[data$Person %in% high] <- as.integer(cell$NCategories)
  }
  person_rows <- table(data$Person)
  rater_rows <- table(data$Rater)
  criterion_rows <- table(data$Criterion)
  scores <- split(data$Score, data$Person)
  low_extreme <- sum(vapply(scores, function(x) all(x == 1L), logical(1)))
  high_extreme <- sum(vapply(
    scores, function(x) all(x == as.integer(cell$NCategories)), logical(1)
  ))
  expected_rows <- as.integer(cell$NPersons) *
    as.integer(cell$RatersPerPerson) *
    as.integer(cell$CriteriaPerPerson)
  if (nrow(data) != expected_rows ||
      length(unique(data$Rater)) != as.integer(cell$ActiveRaters) ||
      length(unique(data$Criterion)) != as.integer(cell$ActiveCriteria) ||
      min(person_rows) != max(person_rows)) {
    stop("JML profile construction invariant failed for ",
         cell$DataCellId, call. = FALSE)
  }
  support <- mfrmr_gpcm_stress_support(data, as.integer(cell$NCategories))
  support$ExpectedRows <- expected_rows
  support$RowsPerPersonMin <- min(person_rows)
  support$RowsPerPersonMax <- max(person_rows)
  support$RaterRowsMin <- min(rater_rows)
  support$RaterRowsMax <- max(rater_rows)
  support$CriterionRowsMin <- min(criterion_rows)
  support$CriterionRowsMax <- max(criterion_rows)
  support$DataExtremeLowN <- low_extreme
  support$DataExtremeHighN <- high_extreme
  support$ForcedExtremePersons <- length(forced_persons)
  list(
    data = data, spec = master$spec, truth = master$truth,
    MasterTruthHash = master$MasterTruthHash,
    CellTruthHash = mfrmr_jml_profile_cell_truth(master$truth, data),
    support = support
  )
}

mfrmr_jml_profile_take <- function(x, name, default = NA) {
  if (is.data.frame(x) && nrow(x) >= 1L && name %in% names(x)) {
    return(x[[name]][1L])
  }
  default
}

mfrmr_jml_profile_empty_result <- function(row, state,
                                            error = NA_character_) {
  data.frame(
    ScenarioId = as.character(row$ScenarioId),
    DataCellId = as.character(row$DataCellId),
    PrimaryAxis = as.character(row$PrimaryAxis),
    AxisMembership = as.character(row$AxisMembership),
    MasterGroup = as.character(row$MasterGroup),
    Method = as.character(row$Method),
    OptimizerRequested = as.character(row$OptimizerRequested),
    Seed = as.integer(row$Seed),
    NPersonsPlanned = as.integer(row$NPersons),
    ActiveRatersPlanned = as.integer(row$ActiveRaters),
    RatersPerPersonPlanned = as.integer(row$RatersPerPerson),
    ActiveCriteriaPlanned = as.integer(row$ActiveCriteria),
    CriteriaPerPersonPlanned = as.integer(row$CriteriaPerPerson),
    ForcedExtremeFraction = as.numeric(row$ForcedExtremeFraction),
    ExpectedFitState = as.character(row$ExpectedFitState),
    Executed = FALSE, RunState = state, Error = error,
    Warnings = NA_character_, DataHash = NA_character_,
    MasterTruthHash = NA_character_, CellTruthHash = NA_character_,
    RetainedDataHash = NA_character_,
    Rows = NA_integer_, ExpectedRows = NA_integer_,
    PositiveWeightRows = NA_integer_, Persons = NA_integer_,
    Raters = NA_integer_, Criteria = NA_integer_,
    RowsPerPersonMin = NA_integer_, RowsPerPersonMax = NA_integer_,
    RaterRowsMin = NA_integer_, RaterRowsMax = NA_integer_,
    CriterionRowsMin = NA_integer_, CriterionRowsMax = NA_integer_,
    CategoryCounts = NA_character_, ObservedCategories = NA_integer_,
    ZeroCategories = NA_integer_, MinCategoryCount = NA_integer_,
    MaxCategoryFraction = NA_real_, NormalizedCategoryEntropy = NA_real_,
    MinCommonPersons = NA_integer_, ZeroCommonRaterPairs = NA_integer_,
    ExactCellDuplicates = NA_integer_, DistinguishedCellDuplicates = NA_integer_,
    DataExtremeLowN = NA_integer_, DataExtremeHighN = NA_integer_,
    ForcedExtremePersons = NA_integer_,
    FitReadiness = NA_character_, InferenceReady = NA,
    ReasonCodes = NA_character_, InputState = NA_character_,
    EstimabilityState = NA_character_, CategoryState = NA_character_,
    BoundaryState = NA_character_, NumericalState = NA_character_,
    FalseReady = FALSE, RecoveryTraceEligible = FALSE,
    RaterCenteredRMSE = NA_real_, CriterionCenteredRMSE = NA_real_,
    StepContrastRMSE = NA_real_, OptimizerLogSlopeRMSE = NA_real_,
    Npar = NA_integer_, PersonParameterCount = NA_integer_,
    StructuralParameterCount = NA_integer_,
    OptimizerMethod = NA_character_, OptimizerInitialMethod = NA_character_,
    OptimizerPolished = NA, OptimizerPolishSucceeded = NA,
    Iterations = NA_integer_, IterationsBasis = NA_character_,
    FunctionEvaluations = NA_integer_, GradientEvaluations = NA_integer_,
    TerminalGradientSupNorm = NA_real_, TerminalGradientRMS = NA_real_,
    FitExtremeLowN = NA_integer_, FitExtremeHighN = NA_integer_,
    DesignObservationRows = NA_integer_, DesignTransitionRows = NA_integer_,
    DesignFreeDimension = NA_integer_, DesignNonzeroEntries = NA_real_,
    DesignRank = NA_integer_, DesignNullity = NA_integer_,
    DesignConditionIndex = NA_real_, DesignSmallestSingularValue = NA_real_,
    RowsPerFreeParameter = NA_real_,
    TotalElapsedPerReportedFunctionEvaluationProxy = NA_real_,
    PCAState = "not_run_pending_computability_contract",
    FitElapsedSeconds = NA_real_, GenerationSeconds = NA_real_,
    PeakVcellsMB = NA_real_, PeakNcellsMB = NA_real_,
    OSPeakWorkingSetMB = NA_real_, OSWorkingSetAfterMB = NA_real_,
    OSPeakPagefileMB = NA_real_, OSPrivateMemoryAfterMB = NA_real_,
    OSPageFaults = NA_real_,
    NumericExternalEligible = FALSE, ConfirmationAuthorized = FALSE,
    EvidenceUse = "computation_decomposition_calibration_only",
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_profile_run_route <- function(row, generated, generation_seconds,
                                         maxit, quad_points, reltol) {
  fit_args <- list(
    data = generated$data, person = "Person",
    facets = c("Rater", "Criterion"), score = "Score",
    model = "PCM", method = as.character(row$Method),
    rating_min = 1L, rating_max = 5L, step_facet = "Criterion",
    maxit = as.integer(maxit), reltol = as.numeric(reltol),
    optimizer = as.character(row$OptimizerRequested)
  )
  if (identical(row$Method, "MML")) {
    fit_args$quad_points <- as.integer(quad_points)
  }
  invisible(gc(reset = TRUE))
  start <- proc.time()
  capture <- mfrmr_gpcm_stress_capture(
    do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), fit_args)
  )
  timing <- proc.time() - start
  heap <- gc()
  os <- mfrmr_target_bridge_os_memory()
  expected_negative <- identical(
    as.character(row$ExpectedFitState), "must_not_be_inference_ready"
  )
  if (inherits(capture$value, "error")) {
    out <- mfrmr_jml_profile_empty_result(
      row, if (expected_negative) "expected_fail_closed" else "fit_failed",
      conditionMessage(capture$value)
    )
  } else {
    fit <- capture$value
    ready <- mfrmr_target_bridge_readiness(fit)
    recovery <- mfrmr_target_bridge_recovery(fit, generated$truth)
    false_ready <- expected_negative && isTRUE(ready$InferenceReady)
    out <- mfrmr_jml_profile_empty_result(
      row,
      if (false_ready) "false_ready" else if (expected_negative) {
        "expected_review_or_block"
      } else "completed_calibration"
    )
    out$FitReadiness <- ready$FitReadiness
    out$InferenceReady <- ready$InferenceReady
    out$ReasonCodes <- ready$ReasonCodes
    out$InputState <- ready$InputState
    out$EstimabilityState <- ready$EstimabilityState
    out$CategoryState <- ready$CategoryState
    out$BoundaryState <- ready$BoundaryState
    out$NumericalState <- ready$NumericalState
    out$FalseReady <- false_ready
    out$RecoveryTraceEligible <- isTRUE(ready$InferenceReady) &&
      !expected_negative
    out[names(recovery)] <- recovery

    summary <- as.data.frame(fit$summary %||% data.frame(),
                             stringsAsFactors = FALSE)
    design <- fit$config$estimability_audit$design %||% list()
    npar <- as.integer(mfrmr_jml_profile_take(summary, "Npar", NA_integer_))
    person_parameters <- if (identical(row$Method, "JML")) {
      as.integer(fit$config$theta_spec$n_params %||% NA_integer_)
    } else 0L
    out$Npar <- npar
    out$PersonParameterCount <- person_parameters
    out$StructuralParameterCount <- if (
      is.finite(npar) && is.finite(person_parameters)
    ) npar - person_parameters else NA_integer_
    out$OptimizerMethod <- as.character(mfrmr_jml_profile_take(
      summary, "OptimizerMethod", NA_character_
    ))
    out$OptimizerInitialMethod <- as.character(mfrmr_jml_profile_take(
      summary, "OptimizerInitialMethod", NA_character_
    ))
    out$OptimizerPolished <- as.logical(mfrmr_jml_profile_take(
      summary, "OptimizerPolished", NA
    ))
    out$OptimizerPolishSucceeded <- as.logical(mfrmr_jml_profile_take(
      summary, "OptimizerPolishSucceeded", NA
    ))
    out$Iterations <- as.integer(mfrmr_jml_profile_take(
      summary, "Iterations", NA_integer_
    ))
    out$IterationsBasis <- as.character(mfrmr_jml_profile_take(
      summary, "IterationsBasis", NA_character_
    ))
    out$FunctionEvaluations <- as.integer(mfrmr_jml_profile_take(
      summary, "FunctionEvaluations", NA_integer_
    ))
    out$GradientEvaluations <- as.integer(mfrmr_jml_profile_take(
      summary, "GradientEvaluations", NA_integer_
    ))
    out$TerminalGradientSupNorm <- as.numeric(mfrmr_jml_profile_take(
      summary, "TerminalGradientSupNorm", NA_real_
    ))
    out$TerminalGradientRMS <- as.numeric(mfrmr_jml_profile_take(
      summary, "TerminalGradientRMS", NA_real_
    ))
    out$FitExtremeLowN <- as.integer(mfrmr_jml_profile_take(
      summary, "ExtremeLowN", NA_integer_
    ))
    out$FitExtremeHighN <- as.integer(mfrmr_jml_profile_take(
      summary, "ExtremeHighN", NA_integer_
    ))
    out$DesignObservationRows <- as.integer(
      design$observation_rows %||% NA_integer_
    )
    out$DesignTransitionRows <- as.integer(
      design$transition_rows %||% NA_integer_
    )
    out$DesignFreeDimension <- as.integer(
      design$free_dimension %||% NA_integer_
    )
    out$DesignNonzeroEntries <- as.numeric(
      design$nonzero_entries %||% NA_real_
    )
    out$DesignRank <- as.integer(design$rank %||% NA_integer_)
    out$DesignNullity <- as.integer(design$nullity %||% NA_integer_)
    out$DesignConditionIndex <- as.numeric(
      design$condition_index %||% NA_real_
    )
    out$DesignSmallestSingularValue <- as.numeric(
      design$smallest_singular_value %||% NA_real_
    )
  }
  out[names(generated$support)] <- generated$support
  out$DataHash <- generated$support$RetainedDataHash
  out$MasterTruthHash <- generated$MasterTruthHash
  out$CellTruthHash <- generated$CellTruthHash
  out$Warnings <- paste(capture$warnings, collapse = " | ")
  out$Executed <- TRUE
  out$GenerationSeconds <- generation_seconds
  out$FitElapsedSeconds <- unname(as.numeric(timing[["elapsed"]]))
  out$RowsPerFreeParameter <- if (
    is.finite(out$Npar) && out$Npar > 0
  ) out$Rows / out$Npar else NA_real_
  out$TotalElapsedPerReportedFunctionEvaluationProxy <- if (
    is.finite(out$FunctionEvaluations) && out$FunctionEvaluations > 0
  ) out$FitElapsedSeconds / out$FunctionEvaluations else NA_real_
  out$PeakVcellsMB <- mfrmr_target_scale_memory(heap, "Vcells")
  out$PeakNcellsMB <- mfrmr_target_scale_memory(heap, "Ncells")
  out$OSPeakWorkingSetMB <- os[["PeakWorkingSetMB"]]
  out$OSWorkingSetAfterMB <- os[["WorkingSetMB"]]
  out$OSPeakPagefileMB <- os[["PeakPagefileMB"]]
  out$OSPrivateMemoryAfterMB <- os[["PrivateMemoryMB"]]
  out$OSPageFaults <- os[["PageFaults"]]
  out
}

mfrmr_jml_profile_capabilities <- function() {
  base <- mfrmr_gpcm_repilot_capability_manifest()
  ps_available <- requireNamespace("ps", quietly = TRUE)
  ps_row <- data.frame(
    Capability = "ps", Role = "windows_process_peak_memory",
    Available = ps_available,
    Version = if (ps_available) {
      as.character(utils::packageVersion("ps"))
    } else NA_character_,
    RuntimeSHA256 = if (ps_available) {
      mfrmr_gpcm_repilot_package_content_identity("ps")$PackageSHA256
    } else NA_character_,
    Platform = R.version$platform,
    stringsAsFactors = FALSE
  )
  out <- rbind(base, ps_row)
  attr(out, "CompositeSHA256") <- mfrmr_gpcm_repilot_hash_object(out)
  out
}

mfrmr_jml_profile_runner_identity <- function() {
  if (is.na(mfrmr_jml_profile_source_dir)) {
    stop("Cannot identify the JML profile runner directory.", call. = FALSE)
  }
  files <- data.frame(
    Component = c(
      "jml_profile", "baseline_bridge", "target_support", "covering_grid",
      "identity_support", "attribution_support"
    ),
    File = c(
      "jml-bottleneck-decomposition-pilot-0.2.3.R",
      "target-scale-baseline-bridge-pilot-0.2.3.R",
      "target-scale-sparse-stress-pilot-0.2.3.R",
      "gpcm-stress-covering-grid-0.2.3.R",
      "gpcm-attribution-replicated-pilot-0.2.3.R",
      "gpcm-isolated-attribution-pilot-0.2.3.R"
    ),
    stringsAsFactors = FALSE
  )
  paths <- file.path(mfrmr_jml_profile_source_dir, files$File)
  if (any(!file.exists(paths))) {
    stop("One or more JML profile identity files are missing.", call. = FALSE)
  }
  files$SHA256 <- vapply(
    paths, mfrmr_gpcm_repilot_hash_file, character(1)
  )
  attr(files, "CompositeSHA256") <- mfrmr_gpcm_repilot_hash_object(files)
  files
}

mfrmr_jml_profile_identity <- function(registry, maxit, quad_points, reltol) {
  package <- mfrmr_gpcm_repilot_runtime_package_identity()
  runners <- mfrmr_jml_profile_runner_identity()
  capabilities <- mfrmr_jml_profile_capabilities()
  execution <- data.frame(
    Schema = "mfrmr-jml-bottleneck-profile-v1",
    DataCells = length(unique(registry$DataCellId)),
    Routes = nrow(registry), ReplicatesPerCell = 1L,
    Maxit = as.integer(maxit), QuadPoints = as.integer(quad_points),
    Reltol = as.numeric(reltol), PCARun = FALSE,
    PCAReason = "pending_fail_closed_computability_contract",
    OSPeakMemorySource = "ps_peak_wset_process_lifetime_windows",
    DeclaredManifestSHA256 = unique(registry$DeclaredManifestSHA256),
    PackageSHA256 = package$PackageSHA256,
    RunnerSHA256 = attr(runners, "CompositeSHA256"),
    CapabilitySHA256 = attr(capabilities, "CompositeSHA256"),
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "computation_decomposition_calibration_only",
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  list(
    execution = execution, package = package, runners = runners,
    capabilities = capabilities
  )
}

mfrmr_jml_profile_validate_completion <- function(
    output_dir, expected_execution_sha256 = NULL) {
  mfrmr_jml_profile_require_support()
  marker <- tryCatch(
    readRDS(file.path(output_dir, "run-complete.rds")),
    error = function(e) e
  )
  if (inherits(marker, "error") ||
      !identical(marker$schema,
                 "mfrmr-jml-bottleneck-profile-completion-v1")) {
    stop("JML profile completion marker is unreadable or invalid.",
         call. = FALSE)
  }
  if (!is.null(expected_execution_sha256) &&
      !identical(as.character(marker$execution_sha256),
                 as.character(expected_execution_sha256))) {
    stop("JML profile execution identity mismatch.", call. = FALSE)
  }
  inventory <- marker$artifacts
  if (!is.data.frame(inventory) ||
      !all(c("File", "Bytes", "SHA256") %in% names(inventory)) ||
      nrow(inventory) < 1L || anyDuplicated(inventory$File)) {
    stop("JML profile artifact inventory schema mismatch.", call. = FALSE)
  }
  if (!identical(
    as.character(marker$artifact_inventory_sha256),
    mfrmr_gpcm_repilot_hash_object(inventory)
  )) {
    stop("JML profile artifact inventory hash mismatch.", call. = FALSE)
  }
  relative <- gsub("\\\\", "/", as.character(inventory$File))
  unsafe <- !nzchar(relative) |
    grepl("^(?:[A-Za-z]:|/)", relative, perl = TRUE) |
    grepl("(?:^|/)\\.\\.(?:/|$)", relative, perl = TRUE)
  if (any(unsafe)) stop("Unsafe JML profile artifact path.", call. = FALSE)
  paths <- file.path(output_dir, relative)
  if (any(!file.exists(paths)) || any(dir.exists(paths))) {
    stop("JML profile artifact is missing.", call. = FALSE)
  }
  hashes <- unname(vapply(
    paths, mfrmr_gpcm_repilot_hash_file, character(1)
  ))
  sizes <- unname(file.info(paths)$size)
  if (!identical(hashes, as.character(inventory$SHA256)) ||
      !identical(as.numeric(sizes), as.numeric(inventory$Bytes))) {
    stop("JML profile artifact hash or size mismatch.", call. = FALSE)
  }
  if (isTRUE(marker$confirmation_authorized)) {
    stop("A JML profile pilot cannot authorize confirmation.", call. = FALSE)
  }
  invisible(marker)
}

mfrmr_jml_profile_axis_audit <- function(results) {
  jml_auto <- results[
    results$Method == "JML" & results$OptimizerRequested == "auto", ,
    drop = FALSE
  ]
  path <- function(pattern, expected_rows = NULL, fixed_rows = FALSE,
                   fixed_npar = FALSE) {
    rows <- jml_auto[grepl(pattern, jml_auto$AxisMembership), , drop = FALSE]
    data.frame(
      Axis = pattern, Cells = nrow(rows),
      Executed = sum(rows$Executed), Failed = sum(rows$RunState == "fit_failed"),
      UniqueRows = length(unique(rows$Rows)),
      UniqueNpar = length(unique(rows$Npar[is.finite(rows$Npar)])),
      ExpectedRowsMatched = if (is.null(expected_rows)) {
        all(rows$Rows == rows$ExpectedRows)
      } else identical(sort(rows$Rows), sort(as.integer(expected_rows))),
      FixedRowsRequired = fixed_rows,
      FixedRowsObserved = if (nrow(rows)) length(unique(rows$Rows)) == 1L else FALSE,
      FixedNparRequired = fixed_npar,
      FixedNparObserved = if (nrow(rows)) {
        length(unique(rows$Npar[is.finite(rows$Npar)])) == 1L
      } else FALSE,
      stringsAsFactors = FALSE
    )
  }
  rbind(
    path("person_and_rows", c(600L, 1200L, 2400L, 4800L)),
    path("rater_panel_topology_fixed_rows", rep(2400L, 3L),
         fixed_rows = TRUE),
    path("criterion_step_dimension_fixed_rows", rep(2400L, 3L),
         fixed_rows = TRUE),
    path("row_exposure_fixed_dimension", c(1200L, 2400L, 4800L, 7200L),
         fixed_npar = TRUE),
    path("forced_extreme_fixed_rows_dimension", 2400L)
  )
}

mfrmr_run_jml_bottleneck_profile <- function(
    dry_run = TRUE, authorize = FALSE, maxit = 60L, quad_points = 7L,
    reltol = 1e-9, output_dir = NULL, progress = interactive()) {
  mfrmr_jml_profile_require_support()
  maxit <- as.integer(maxit)
  quad_points <- as.integer(quad_points)
  reltol <- as.numeric(reltol)
  if (length(maxit) != 1L || is.na(maxit) || maxit < 1L) {
    stop("`maxit` must be one positive integer.", call. = FALSE)
  }
  if (length(quad_points) != 1L || is.na(quad_points) || quad_points < 3L) {
    stop("`quad_points` must be one integer of at least three.", call. = FALSE)
  }
  if (length(reltol) != 1L || !is.finite(reltol) || reltol <= 0) {
    stop("`reltol` must be one positive finite number.", call. = FALSE)
  }
  registry <- mfrmr_jml_profile_registry()
  identity <- mfrmr_jml_profile_identity(
    registry, maxit, quad_points, reltol
  )
  if (isTRUE(dry_run)) {
    out <- list(
      registry = registry, results = NULL, axis_audit = NULL,
      execution_identity = identity$execution,
      package_identity = identity$package,
      runner_identity = identity$runners,
      capability_manifest = identity$capabilities,
      confirmation_authorized = FALSE
    )
    class(out) <- "mfrmr_jml_bottleneck_profile"
    return(out)
  }
  if (!isTRUE(authorize)) {
    stop("Live JML profile execution requires `authorize = TRUE`.",
         call. = FALSE)
  }
  if (!requireNamespace("ps", quietly = TRUE)) {
    stop("Live JML profile execution requires package `ps`.", call. = FALSE)
  }
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("Live JML profile execution requires one `output_dir`.",
         call. = FALSE)
  }
  if (file.exists(output_dir) || dir.exists(output_dir)) {
    stop("`output_dir` must not already exist.", call. = FALSE)
  }
  parent <- dirname(output_dir)
  if (!dir.exists(parent)) dir.create(parent, recursive = TRUE)
  staging <- paste0(
    output_dir, ".incomplete-", format(Sys.time(), "%Y%m%d%H%M%S"),
    "-", Sys.getpid()
  )
  if (file.exists(staging) || dir.exists(staging)) {
    stop("The generated incomplete-run directory already exists.",
         call. = FALSE)
  }
  dir.create(staging, recursive = TRUE)
  promoted <- FALSE
  on.exit({
    if (!promoted && dir.exists(staging)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
  }, add = TRUE)

  cells <- mfrmr_jml_profile_cells()
  results <- vector("list", nrow(registry))
  cursor <- 0L
  for (i in seq_len(nrow(cells))) {
    cell <- cells[i, , drop = FALSE]
    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] %s", i, nrow(cells), cell$DataCellId))
    }
    generation_start <- proc.time()
    generated <- mfrmr_jml_profile_build(cell)
    generation_seconds <- unname(as.numeric(
      (proc.time() - generation_start)[["elapsed"]]
    ))
    routes <- registry[registry$DataCellId == cell$DataCellId, , drop = FALSE]
    for (j in seq_len(nrow(routes))) {
      cursor <- cursor + 1L
      if (isTRUE(progress)) {
        message("  ", routes$Method[j], " / ", routes$OptimizerRequested[j])
      }
      results[[cursor]] <- mfrmr_jml_profile_run_route(
        routes[j, , drop = FALSE], generated, generation_seconds,
        maxit, quad_points, reltol
      )
      progress_result <- do.call(rbind, results[seq_len(cursor)])
      utils::write.csv(
        progress_result, file.path(staging, "run-progress.csv"),
        row.names = FALSE, na = ""
      )
    }
  }
  results <- do.call(rbind, results)
  row.names(results) <- NULL
  if (nrow(results) != nrow(registry) ||
      !identical(results$ScenarioId, registry$ScenarioId)) {
    stop("JML profile result registry alignment failed.", call. = FALSE)
  }
  data_audit <- do.call(rbind, lapply(
    split(results, results$DataCellId), function(x) {
      data.frame(
        DataCellId = x$DataCellId[1L], Routes = nrow(x),
        DataHashes = length(unique(x$DataHash)),
        CellTruthHashes = length(unique(x$CellTruthHash)),
        SameData = length(unique(x$DataHash)) == 1L,
        SameCellTruth = length(unique(x$CellTruthHash)) == 1L,
        stringsAsFactors = FALSE
      )
    }
  ))
  axis_audit <- mfrmr_jml_profile_axis_audit(results)
  if (any(!data_audit$SameData) || any(!data_audit$SameCellTruth) ||
      any(results$Rows != results$ExpectedRows) ||
      any(axis_audit$FixedRowsRequired & !axis_audit$FixedRowsObserved) ||
      any(axis_audit$FixedNparRequired & !axis_audit$FixedNparObserved)) {
    stop("JML profile pairing or axis invariant failed.", call. = FALSE)
  }
  p200_truth <- unique(results$CellTruthHash[results$DataCellId == "JBP-P200"])
  x20_truth <- unique(results$CellTruthHash[
    results$DataCellId == "JBP-P200-X20"
  ])
  if (!identical(p200_truth, x20_truth)) {
    stop("Extreme-score control did not retain the P200 truth.", call. = FALSE)
  }
  summary <- data.frame(
    Schema = "mfrmr-jml-bottleneck-profile-summary-v1",
    DataCells = length(unique(results$DataCellId)), Routes = nrow(results),
    ExecutedRoutes = sum(results$Executed),
    FailedRoutes = sum(results$RunState == "fit_failed"),
    ExpectedNegativeRoutes = sum(results$ExpectedFitState ==
                                   "must_not_be_inference_ready"),
    FalseReadyRoutes = sum(results$FalseReady),
    InferenceReadyRoutes = sum(results$InferenceReady, na.rm = TRUE),
    SameDataCells = sum(data_audit$SameData),
    TotalFitSeconds = sum(results$FitElapsedSeconds, na.rm = TRUE),
    MaxFitSeconds = max(results$FitElapsedSeconds, na.rm = TRUE),
    OSPeakWorkingSetMB = max(results$OSPeakWorkingSetMB, na.rm = TRUE),
    OSPeakPagefileMB = max(results$OSPeakPagefileMB, na.rm = TRUE),
    StatisticalOperatingCharacteristicsEstimated = FALSE,
    RuntimeCriteriaFrozen = FALSE, RecoveryCriteriaFrozen = FALSE,
    PCARun = FALSE, ConfirmationAuthorized = FALSE,
    EvidenceUse = "computation_decomposition_calibration_only",
    stringsAsFactors = FALSE
  )
  out <- list(
    registry = registry, results = results, data_audit = data_audit,
    axis_audit = axis_audit, summary = summary,
    execution_identity = identity$execution,
    package_identity = identity$package,
    runner_identity = identity$runners,
    capability_manifest = identity$capabilities,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  class(out) <- "mfrmr_jml_bottleneck_profile"
  utils::write.csv(registry, file.path(staging, "registry.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(results, file.path(staging, "run-results.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(data_audit, file.path(staging, "data-audit.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(axis_audit, file.path(staging, "axis-audit.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(summary, file.path(staging, "run-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(identity$execution,
                   file.path(staging, "execution-identity.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(identity$package,
                   file.path(staging, "package-identity.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(identity$runners,
                   file.path(staging, "runner-identity.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(identity$capabilities,
                   file.path(staging, "capability-manifest.csv"),
                   row.names = FALSE, na = "")
  saveRDS(out, file.path(staging, "jml-bottleneck-profile.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  completion <- list(
    schema = "mfrmr-jml-bottleneck-profile-completion-v1",
    execution_sha256 = identity$execution$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) {
    stop("Completed JML profile evidence could not be promoted.",
         call. = FALSE)
  }
  promoted <- TRUE
  mfrmr_jml_profile_validate_completion(
    output_dir, identity$execution$ExecutionSHA256
  )
  invisible(out)
}
