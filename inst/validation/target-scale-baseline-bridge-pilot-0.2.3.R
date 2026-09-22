# Repository-only balanced-baseline and bridge-gradient feasibility runner for
# mfrmr 0.2.3. This is calibration instrumentation, not confirmation,
# operating-characteristic evidence, or a FACETS capacity comparison.

mfrmr_target_bridge_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "target-scale-baseline-bridge-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path(
      "inst", "validation",
      "target-scale-baseline-bridge-pilot-0.2.3.R"
    ),
    "target-scale-baseline-bridge-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_target_bridge_require_support <- function() {
  target_env <- environment(mfrmr_target_bridge_require_support)
  required <- c(
    "mfrmr_target_scale_require_support",
    "mfrmr_target_scale_memory",
    "mfrmr_target_scale_artifact_inventory",
    "mfrmr_gpcm_stress_fun",
    "mfrmr_gpcm_stress_capture",
    "mfrmr_gpcm_stress_support",
    "mfrmr_gpcm_repilot_hash_object",
    "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_runtime_package_identity",
    "mfrmr_gpcm_repilot_capability_manifest",
    "mfrmr_gpcm_repilot_package_content_identity"
  )
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    candidates <- c(
      if (!is.na(mfrmr_target_bridge_source_dir)) {
        file.path(
          mfrmr_target_bridge_source_dir,
          "target-scale-sparse-stress-pilot-0.2.3.R"
        )
      } else character(0),
      file.path(
        "inst", "validation", "target-scale-sparse-stress-pilot-0.2.3.R"
      ),
      "target-scale-sparse-stress-pilot-0.2.3.R"
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("Cannot locate target-scale identity support.", call. = FALSE)
    }
    sys.source(path, envir = target_env)
    mfrmr_target_scale_require_support()
  }
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("Target-scale baseline support did not load completely.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_target_bridge_data_cells <- function() {
  base <- data.frame(
    DataCellId = c(
      paste0("TSB-COMPLETE-", c("RSM", "PCM", "GPCM")),
      paste0("TSB-SPARSE40-", c("RSM", "PCM", "GPCM"))
    ),
    Design = rep(c("complete_balanced", "sparse40_matched"), each = 3L),
    Model = rep(c("RSM", "PCM", "GPCM"), 2L),
    NPersons = 400L,
    NRaters = rep(c(3L, 12L), each = 3L),
    NCriteria = rep(c(4L, 12L), each = 3L),
    NCategories = rep(c(5L, 7L), each = 3L),
    LinkPersons = rep(c(NA_integer_, 40L), each = 3L),
    SlopeRegime = rep(c("mild", "strong"), each = 3L),
    stringsAsFactors = FALSE
  )
  bridge_levels <- c(0L, 1L, 2L, 5L, 10L, 20L, 40L)
  bridge <- data.frame(
    DataCellId = sprintf("TSB-BRIDGE%02d-PCM", bridge_levels),
    Design = "two_rater_bridge_gradient",
    Model = "PCM",
    NPersons = 400L,
    NRaters = 2L,
    NCriteria = 4L,
    NCategories = 5L,
    LinkPersons = bridge_levels,
    SlopeRegime = "fixed_unit",
    stringsAsFactors = FALSE
  )
  out <- rbind(base, bridge)
  out$Seed <- c(248001L + seq_len(nrow(base)) - 1L, rep(248007L, nrow(bridge)))
  out$TruthSeedGroup <- c(
    paste0("baseline_", seq_len(nrow(base))),
    rep("bridge_common_truth", nrow(bridge))
  )
  out$DataRole <- c(
    rep("balanced_complete_scale_baseline", 3L),
    rep("clean_matched_sparse_dimension_baseline", 3L),
    rep("two_rater_common_person_gradient", nrow(bridge))
  )
  out$ExpectedDataState <- ifelse(
    out$Design == "two_rater_bridge_gradient" & out$LinkPersons == 0L,
    "zero_overlap_negative_control", "review_recovery_trace"
  )
  out$ConfirmationAuthorized <- FALSE
  out$EvidenceUse <- "capacity_and_bridge_calibration_only"
  row.names(out) <- NULL
  out
}

mfrmr_target_bridge_registry <- function() {
  mfrmr_target_bridge_require_support()
  cells <- mfrmr_target_bridge_data_cells()
  routes <- merge(
    cells,
    data.frame(Method = c("JML", "MML"), stringsAsFactors = FALSE),
    by = NULL, sort = FALSE
  )
  routes <- routes[order(
    match(routes$DataCellId, cells$DataCellId),
    match(routes$Method, c("JML", "MML"))
  ), , drop = FALSE]
  row.names(routes) <- NULL
  routes$ScenarioId <- paste(routes$DataCellId, routes$Method, sep = "-")
  routes$ExpectedFitState <- ifelse(
    routes$Design == "two_rater_bridge_gradient" &
      routes$LinkPersons == 0L,
    ifelse(routes$Method == "JML", "must_fail_closed",
           "must_not_be_unqualified_ready"),
    "review_recovery_trace"
  )
  routes$ExecutedReplicates <- 1L
  routes$PCAState <- "not_run_pending_computability_contract"
  routes$NumericExternalEligible <- FALSE
  routes$ExternalReason <- "internal_truth_first_feasibility_not_matched_external"
  routes$ConfirmationAuthorized <- FALSE
  routes$EvidenceUse <- "capacity_and_bridge_calibration_only"
  canonical <- routes[, setdiff(names(routes), "ScenarioId"), drop = FALSE]
  routes$DeclaredManifestSHA256 <- mfrmr_gpcm_repilot_hash_object(canonical)
  routes
}

mfrmr_target_bridge_thresholds <- function(model, criteria, n_categories) {
  base <- if (n_categories == 2L) 0 else {
    seq(-1.35, 1.35, length.out = n_categories - 1L)
  }
  if (identical(model, "RSM")) return(base)
  offsets <- seq(-0.20, 0.20, length.out = length(criteria))
  do.call(rbind, lapply(seq_along(criteria), function(i) {
    data.frame(
      StepFacet = criteria[i], StepIndex = seq_along(base),
      Estimate = base + offsets[i], stringsAsFactors = FALSE
    )
  }))
}

mfrmr_target_bridge_slopes <- function(model, criteria, regime) {
  if (!identical(model, "GPCM")) return(NULL)
  bound <- switch(
    as.character(regime), mild = 0.25, strong = 0.85,
    stop("Unknown target-scale slope regime: ", regime, call. = FALSE)
  )
  log_slope <- seq(-bound, bound, length.out = length(criteria))
  stats::setNames(exp(log_slope - mean(log_slope)), criteria)
}

mfrmr_target_bridge_build <- function(cell) {
  cell <- as.list(cell)
  model <- as.character(cell$Model)
  n_rater <- as.integer(cell$NRaters)
  n_criterion <- as.integer(cell$NCriteria)
  criteria <- sprintf("C%02d", seq_len(n_criterion))
  complete <- identical(cell$Design, "complete_balanced")
  assignment <- if (complete) "crossed" else "sparse_linked"
  link_persons <- if (complete) NA_integer_ else as.integer(cell$LinkPersons)
  sparse_controls <- if (complete) NULL else list(
    link_persons = link_persons,
    link_raters_per_person = n_rater,
    assignment_mode = "balanced",
    min_common_persons_per_rater_pair = if (link_persons == 0L) {
      1L
    } else {
      link_persons
    }
  )
  args <- list(
    n_person = as.integer(cell$NPersons),
    n_rater = n_rater,
    n_criterion = n_criterion,
    raters_per_person = if (complete) n_rater else 1L,
    score_levels = as.integer(cell$NCategories),
    theta_sd = 1,
    rater_sd = 0.55,
    criterion_sd = 0.35,
    thresholds = mfrmr_target_bridge_thresholds(
      model, criteria, as.integer(cell$NCategories)
    ),
    model = model,
    assignment = assignment,
    sparse_controls = sparse_controls
  )
  if (model %in% c("PCM", "GPCM")) args$step_facet <- "Criterion"
  if (identical(model, "GPCM")) {
    args$slope_facet <- "Criterion"
    args$slopes <- mfrmr_target_bridge_slopes(
      model, criteria, as.character(cell$SlopeRegime)
    )
  }
  spec <- do.call(mfrmr_gpcm_stress_fun("build_mfrm_sim_spec"), args)
  data <- mfrmr_gpcm_stress_fun("simulate_mfrm_data")(
    sim_spec = spec, seed = as.integer(cell$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  truth_hash <- mfrmr_gpcm_repilot_hash_object(list(
    person = truth$person,
    facets = truth$facets,
    step_table = truth$step_table,
    slope_table = truth$slope_table,
    population = truth$population
  ))
  list(
    data = data, spec = spec, truth = truth, TruthHash = truth_hash,
    support = mfrmr_gpcm_stress_support(
      data, as.integer(cell$NCategories)
    )
  )
}

mfrmr_target_bridge_readiness <- function(fit) {
  readiness <- as.data.frame(fit$readiness$fit %||% data.frame(),
                             stringsAsFactors = FALSE)
  summary <- as.data.frame(fit$summary %||% data.frame(),
                           stringsAsFactors = FALSE)
  take <- function(name, default = NA) {
    if (nrow(readiness) == 1L && name %in% names(readiness)) {
      return(readiness[[name]][1L])
    }
    if (nrow(summary) == 1L && name %in% names(summary)) {
      return(summary[[name]][1L])
    }
    default
  }
  list(
    FitReadiness = as.character(take("FitReadiness", "legacy_unknown")),
    InferenceReady = isTRUE(take("InferenceReady", FALSE)),
    ReasonCodes = as.character(take("ReasonCodes", "legacy_contract_missing")),
    InputState = as.character(take("InputState", NA_character_)),
    EstimabilityState = as.character(take("EstimabilityState", NA_character_)),
    CategoryState = as.character(take("CategoryState", NA_character_)),
    BoundaryState = as.character(take("BoundaryState", NA_character_)),
    NumericalState = as.character(take("NumericalState", NA_character_))
  )
}

mfrmr_target_bridge_centered_rmse <- function(estimate, truth, key) {
  estimate <- estimate[is.finite(estimate[["Estimate"]]), , drop = FALSE]
  truth <- truth[is.finite(truth[["Truth"]]), , drop = FALSE]
  matched <- merge(estimate, truth, by = key)
  if (nrow(matched) == 0L) return(NA_real_)
  matched$Estimate <- matched$Estimate - mean(matched$Estimate)
  matched$Truth <- matched$Truth - mean(matched$Truth)
  sqrt(mean((matched$Estimate - matched$Truth)^2))
}

mfrmr_target_bridge_recovery <- function(fit, truth) {
  others <- as.data.frame(fit$facets$others %||% data.frame(),
                          stringsAsFactors = FALSE)
  facet_rows <- lapply(c("Rater", "Criterion"), function(facet) {
    if (!all(c("Facet", "Level", "Estimate") %in% names(others)) ||
        is.null(truth$facets[[facet]])) return(NA_real_)
    estimate <- others[others$Facet == facet, c("Level", "Estimate"),
                       drop = FALSE]
    truth_table <- data.frame(
      Level = names(truth$facets[[facet]]),
      Truth = as.numeric(truth$facets[[facet]]),
      stringsAsFactors = FALSE
    )
    mfrmr_target_bridge_centered_rmse(estimate, truth_table, "Level")
  })
  steps <- as.data.frame(fit$steps %||% data.frame(), stringsAsFactors = FALSE)
  truth_steps <- as.data.frame(truth$step_table %||% data.frame(),
                               stringsAsFactors = FALSE)
  step_rmse <- NA_real_
  if (nrow(steps) > 0L &&
      all(c("Step", "Estimate") %in% names(steps)) &&
      !"StepFacet" %in% names(steps)) {
    steps$StepFacet <- "Common"
  }
  if (nrow(steps) > 0L && nrow(truth_steps) > 0L &&
      all(c("StepFacet", "Step", "Estimate") %in% names(steps)) &&
      all(c("StepFacet", "StepIndex", "Estimate") %in% names(truth_steps))) {
    if (length(unique(steps$StepFacet)) == 1L &&
        length(unique(truth_steps$StepFacet)) == 1L) {
      steps$StepFacet <- "Common"
      truth_steps$StepFacet <- "Common"
    }
    steps$StepIndex <- suppressWarnings(as.integer(gsub(
      "[^0-9]+", "", as.character(steps$Step)
    )))
    truth_steps$Truth <- truth_steps$Estimate
    matched <- merge(
      steps[, c("StepFacet", "StepIndex", "Estimate")],
      truth_steps[, c("StepFacet", "StepIndex", "Truth")],
      by = c("StepFacet", "StepIndex")
    )
    if (nrow(matched) > 0L) {
      matched$EstimateCentered <- ave(
        matched$Estimate, matched$StepFacet, FUN = function(x) x - mean(x)
      )
      matched$TruthCentered <- ave(
        matched$Truth, matched$StepFacet, FUN = function(x) x - mean(x)
      )
      step_rmse <- sqrt(mean(
        (matched$EstimateCentered - matched$TruthCentered)^2
      ))
    }
  }
  slopes <- as.data.frame(fit$slopes %||% data.frame(), stringsAsFactors = FALSE)
  truth_slopes <- as.data.frame(truth$slope_table %||% data.frame(),
                                stringsAsFactors = FALSE)
  log_slope_rmse <- NA_real_
  if (nrow(slopes) > 0L && nrow(truth_slopes) > 0L &&
      all(c("SlopeFacet", "Estimate") %in% names(slopes)) &&
      all(c("SlopeFacet", "Estimate") %in% names(truth_slopes))) {
    matched <- merge(
      slopes[, c("SlopeFacet", "Estimate")],
      truth_slopes[, c("SlopeFacet", "Estimate")],
      by = "SlopeFacet", suffixes = c(".Fit", ".Truth")
    )
    ok <- matched$Estimate.Fit > 0 & matched$Estimate.Truth > 0 &
      is.finite(matched$Estimate.Fit) & is.finite(matched$Estimate.Truth)
    if (any(ok)) {
      log_slope_rmse <- sqrt(mean(
        (log(matched$Estimate.Fit[ok]) - log(matched$Estimate.Truth[ok]))^2
      ))
    }
  }
  data.frame(
    RaterCenteredRMSE = as.numeric(facet_rows[[1L]]),
    CriterionCenteredRMSE = as.numeric(facet_rows[[2L]]),
    StepContrastRMSE = step_rmse,
    OptimizerLogSlopeRMSE = log_slope_rmse,
    stringsAsFactors = FALSE
  )
}

mfrmr_target_bridge_os_memory <- function() {
  if (!requireNamespace("ps", quietly = TRUE)) {
    return(stats::setNames(rep(NA_real_, 5L), c(
      "PeakWorkingSetMB", "WorkingSetMB", "PeakPagefileMB",
      "PrivateMemoryMB", "PageFaults"
    )))
  }
  info <- ps::ps_memory_info(ps::ps_handle())
  c(
    PeakWorkingSetMB = unname(info[["peak_wset"]]) / 1024^2,
    WorkingSetMB = unname(info[["wset"]]) / 1024^2,
    PeakPagefileMB = unname(info[["peak_pagefile"]]) / 1024^2,
    PrivateMemoryMB = unname(info[["mem_private"]]) / 1024^2,
    PageFaults = unname(info[["num_page_faults"]])
  )
}

mfrmr_target_bridge_empty_result <- function(row, state, error = NA_character_) {
  data.frame(
    ScenarioId = as.character(row$ScenarioId),
    DataCellId = as.character(row$DataCellId),
    Design = as.character(row$Design), Model = as.character(row$Model),
    Method = as.character(row$Method), Seed = as.integer(row$Seed),
    LinkPersons = as.integer(row$LinkPersons),
    ExpectedFitState = as.character(row$ExpectedFitState),
    Executed = FALSE, RunState = state, Error = error,
    Warnings = NA_character_, DataHash = NA_character_,
    TruthHash = NA_character_,
    RetainedDataHash = NA_character_,
    Rows = NA_integer_, PositiveWeightRows = NA_integer_,
    Persons = NA_integer_, Raters = NA_integer_, Criteria = NA_integer_,
    CategoryCounts = NA_character_, ObservedCategories = NA_integer_,
    ZeroCategories = NA_integer_, MinCategoryCount = NA_integer_,
    MaxCategoryFraction = NA_real_, NormalizedCategoryEntropy = NA_real_,
    MinCommonPersons = NA_integer_, ZeroCommonRaterPairs = NA_integer_,
    ExactCellDuplicates = NA_integer_, DistinguishedCellDuplicates = NA_integer_,
    FitReadiness = NA_character_, InferenceReady = NA,
    ReasonCodes = NA_character_, InputState = NA_character_,
    EstimabilityState = NA_character_, CategoryState = NA_character_,
    BoundaryState = NA_character_, NumericalState = NA_character_,
    FalseReady = FALSE, RecoveryTraceEligible = FALSE,
    RaterCenteredRMSE = NA_real_, CriterionCenteredRMSE = NA_real_,
    StepContrastRMSE = NA_real_, OptimizerLogSlopeRMSE = NA_real_,
    PCAState = "not_run_pending_computability_contract",
    FitElapsedSeconds = NA_real_, GenerationSeconds = NA_real_,
    PeakVcellsMB = NA_real_, PeakNcellsMB = NA_real_,
    OSPeakWorkingSetMB = NA_real_, OSWorkingSetAfterMB = NA_real_,
    OSPeakPagefileMB = NA_real_, OSPrivateMemoryAfterMB = NA_real_,
    OSPageFaults = NA_real_,
    NumericExternalEligible = FALSE,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "capacity_and_bridge_calibration_only",
    stringsAsFactors = FALSE
  )
}

mfrmr_target_bridge_run_route <- function(row, generated, generation_seconds,
                                          maxit, quad_points) {
  support <- generated$support
  fit_args <- list(
    data = generated$data, person = "Person",
    facets = c("Rater", "Criterion"), score = "Score",
    model = as.character(row$Model), method = as.character(row$Method),
    rating_min = 1L, rating_max = as.integer(row$NCategories),
    maxit = as.integer(maxit)
  )
  if (row$Model %in% c("PCM", "GPCM")) fit_args$step_facet <- "Criterion"
  if (identical(row$Model, "GPCM")) fit_args$slope_facet <- "Criterion"
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
  if (inherits(capture$value, "error")) {
    state <- if (row$ExpectedFitState %in% c(
      "must_fail_closed", "must_not_be_unqualified_ready"
    )) {
      "expected_fail_closed"
    } else {
      "fit_failed"
    }
    out <- mfrmr_target_bridge_empty_result(
      row, state, conditionMessage(capture$value)
    )
  } else {
    fit <- capture$value
    ready <- mfrmr_target_bridge_readiness(fit)
    recovery <- mfrmr_target_bridge_recovery(fit, generated$truth)
    false_ready <- row$ExpectedFitState %in% c(
      "must_fail_closed", "must_not_be_unqualified_ready"
    ) && isTRUE(ready$InferenceReady)
    out <- mfrmr_target_bridge_empty_result(
      row,
      if (false_ready) "false_ready" else if (
        row$ExpectedFitState %in% c(
          "must_fail_closed", "must_not_be_unqualified_ready"
        )
      ) "expected_review_or_block" else "completed_calibration"
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
      !identical(row$ExpectedDataState, "zero_overlap_negative_control")
    out[names(recovery)] <- recovery
  }
  out[names(support)] <- support
  out$DataHash <- support$RetainedDataHash
  out$TruthHash <- generated$TruthHash
  out$Warnings <- paste(capture$warnings, collapse = " | ")
  out$Executed <- TRUE
  out$GenerationSeconds <- generation_seconds
  out$FitElapsedSeconds <- unname(as.numeric(timing[["elapsed"]]))
  out$PeakVcellsMB <- mfrmr_target_scale_memory(heap, "Vcells")
  out$PeakNcellsMB <- mfrmr_target_scale_memory(heap, "Ncells")
  out$OSPeakWorkingSetMB <- os[["PeakWorkingSetMB"]]
  out$OSWorkingSetAfterMB <- os[["WorkingSetMB"]]
  out$OSPeakPagefileMB <- os[["PeakPagefileMB"]]
  out$OSPrivateMemoryAfterMB <- os[["PrivateMemoryMB"]]
  out$OSPageFaults <- os[["PageFaults"]]
  out
}

mfrmr_target_bridge_capabilities <- function() {
  base <- mfrmr_gpcm_repilot_capability_manifest()
  ps_available <- requireNamespace("ps", quietly = TRUE)
  ps_row <- data.frame(
    Capability = "ps", Role = "windows_process_peak_memory",
    Available = ps_available,
    Version = if (ps_available) as.character(utils::packageVersion("ps")) else NA_character_,
    RuntimeSHA256 = if (ps_available) {
      mfrmr_gpcm_repilot_package_content_identity("ps")$PackageSHA256
    } else NA_character_,
    Platform = R.version$platform,
    stringsAsFactors = FALSE
  )
  out <- rbind(base, ps_row)
  row.names(out) <- NULL
  attr(out, "CompositeSHA256") <- mfrmr_gpcm_repilot_hash_object(out)
  out
}

mfrmr_target_bridge_runner_identity <- function() {
  if (is.na(mfrmr_target_bridge_source_dir)) {
    stop("Cannot identify the target baseline runner directory.",
         call. = FALSE)
  }
  components <- c(
    baseline_bridge = "target-scale-baseline-bridge-pilot-0.2.3.R",
    target_support = "target-scale-sparse-stress-pilot-0.2.3.R",
    covering_grid = "gpcm-stress-covering-grid-0.2.3.R",
    identity_support = "gpcm-attribution-replicated-pilot-0.2.3.R",
    attribution_support = "gpcm-isolated-attribution-pilot-0.2.3.R"
  )
  paths <- file.path(mfrmr_target_bridge_source_dir, unname(components))
  if (any(!file.exists(paths))) {
    stop("One or more target baseline identity files are missing.",
         call. = FALSE)
  }
  out <- data.frame(
    Component = names(components), File = unname(components),
    SHA256 = unname(vapply(
      paths, mfrmr_gpcm_repilot_hash_file, character(1)
    )),
    stringsAsFactors = FALSE
  )
  attr(out, "CompositeSHA256") <- mfrmr_gpcm_repilot_hash_object(out)
  out
}

mfrmr_target_bridge_identity <- function(registry, maxit, quad_points) {
  package <- mfrmr_gpcm_repilot_runtime_package_identity()
  runners <- mfrmr_target_bridge_runner_identity()
  capabilities <- mfrmr_target_bridge_capabilities()
  execution <- data.frame(
    Schema = "mfrmr-target-baseline-bridge-v1",
    DataCells = length(unique(registry$DataCellId)),
    Routes = nrow(registry), ReplicatesPerCell = 1L,
    Maxit = as.integer(maxit), QuadPoints = as.integer(quad_points),
    PCARun = FALSE,
    PCAReason = "pending_fail_closed_computability_contract",
    OSPeakMemorySource = "ps_peak_wset_process_lifetime_windows",
    DeclaredManifestSHA256 = unique(registry$DeclaredManifestSHA256),
    SelectedManifestSHA256 = mfrmr_gpcm_repilot_hash_object(registry),
    PackageSHA256 = package$PackageSHA256,
    RunnerSHA256 = attr(runners, "CompositeSHA256"),
    CapabilitySHA256 = attr(capabilities, "CompositeSHA256"),
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "capacity_and_bridge_calibration_only",
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  list(
    execution = execution, package = package, runners = runners,
    capabilities = capabilities
  )
}

mfrmr_target_bridge_validate_completion <- function(
    output_dir, expected_execution_sha256 = NULL) {
  mfrmr_target_bridge_require_support()
  marker <- tryCatch(
    readRDS(file.path(output_dir, "run-complete.rds")),
    error = function(e) e
  )
  if (inherits(marker, "error") ||
      !identical(marker$schema,
                 "mfrmr-target-baseline-bridge-completion-v1")) {
    stop("Target baseline completion marker is unreadable or invalid.",
         call. = FALSE)
  }
  if (!is.null(expected_execution_sha256) &&
      !identical(as.character(marker$execution_sha256),
                 as.character(expected_execution_sha256))) {
    stop("Target baseline execution identity mismatch.", call. = FALSE)
  }
  inventory <- marker$artifacts
  if (!is.data.frame(inventory) ||
      !all(c("File", "Bytes", "SHA256") %in% names(inventory)) ||
      nrow(inventory) < 1L || anyDuplicated(inventory$File)) {
    stop("Target baseline artifact inventory schema mismatch.",
         call. = FALSE)
  }
  if (!identical(
    as.character(marker$artifact_inventory_sha256),
    mfrmr_gpcm_repilot_hash_object(inventory)
  )) {
    stop("Target baseline artifact inventory hash mismatch.",
         call. = FALSE)
  }
  relative <- gsub("\\\\", "/", as.character(inventory$File))
  unsafe <- !nzchar(relative) |
    grepl("^(?:[A-Za-z]:|/)", relative, perl = TRUE) |
    grepl("(?:^|/)\\.\\.(?:/|$)", relative, perl = TRUE)
  if (any(unsafe)) stop("Unsafe target baseline artifact path.", call. = FALSE)
  paths <- file.path(output_dir, relative)
  if (any(!file.exists(paths)) || any(dir.exists(paths))) {
    stop("Target baseline artifact is missing.", call. = FALSE)
  }
  hashes <- unname(vapply(
    paths, mfrmr_gpcm_repilot_hash_file, character(1)
  ))
  sizes <- unname(file.info(paths)$size)
  if (!identical(hashes, as.character(inventory$SHA256)) ||
      !identical(as.numeric(sizes), as.numeric(inventory$Bytes))) {
    stop("Target baseline artifact hash or size mismatch.", call. = FALSE)
  }
  if (isTRUE(marker$confirmation_authorized)) {
    stop("A target baseline pilot cannot authorize confirmation.",
         call. = FALSE)
  }
  invisible(marker)
}

mfrmr_run_target_scale_baseline_bridge <- function(
    dry_run = TRUE, authorize = FALSE, maxit = 180L,
    quad_points = 7L, output_dir = NULL, progress = interactive()) {
  mfrmr_target_bridge_require_support()
  maxit <- as.integer(maxit)
  quad_points <- as.integer(quad_points)
  if (length(maxit) != 1L || is.na(maxit) || maxit < 1L) {
    stop("`maxit` must be one positive integer.", call. = FALSE)
  }
  if (length(quad_points) != 1L || is.na(quad_points) ||
      quad_points < 3L) {
    stop("`quad_points` must be one integer of at least three.",
         call. = FALSE)
  }
  registry <- mfrmr_target_bridge_registry()
  identity <- mfrmr_target_bridge_identity(registry, maxit, quad_points)
  if (isTRUE(dry_run)) {
    return(structure(list(
      registry = registry, results = NULL,
      execution_identity = identity$execution,
      package_identity = identity$package,
      runner_identity = identity$runners,
      capability_manifest = identity$capabilities,
      confirmation_authorized = FALSE
    ), class = "mfrmr_target_scale_baseline_bridge"))
  }
  if (!isTRUE(authorize)) {
    stop("Live target baseline execution requires `authorize = TRUE`.",
         call. = FALSE)
  }
  if (!requireNamespace("ps", quietly = TRUE)) {
    stop("Live target baseline execution requires package `ps` for OS peak memory.",
         call. = FALSE)
  }
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("Live target baseline execution requires one `output_dir`.",
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
  dir.create(staging, recursive = FALSE)
  started <- Sys.time()
  cell_ids <- unique(registry$DataCellId)
  rows <- vector("list", nrow(registry))
  cursor <- 0L
  for (cell_index in seq_along(cell_ids)) {
    data_cell_id <- cell_ids[cell_index]
    cell_rows <- registry[registry$DataCellId == data_cell_id, , drop = FALSE]
    build_start <- proc.time()
    generated_capture <- mfrmr_gpcm_stress_capture(
      mfrmr_target_bridge_build(cell_rows[1L, , drop = FALSE])
    )
    generation_seconds <- unname(as.numeric(
      (proc.time() - build_start)[["elapsed"]]
    ))
    for (route_index in seq_len(nrow(cell_rows))) {
      cursor <- cursor + 1L
      row <- cell_rows[route_index, , drop = FALSE]
      if (isTRUE(progress)) {
        message("[", cursor, "/", nrow(registry), "] ", row$ScenarioId)
      }
      if (inherits(generated_capture$value, "error")) {
        rows[[cursor]] <- mfrmr_target_bridge_empty_result(
          row, "generation_failed", conditionMessage(generated_capture$value)
        )
        rows[[cursor]]$Warnings <- paste(
          generated_capture$warnings, collapse = " | "
        )
        rows[[cursor]]$GenerationSeconds <- generation_seconds
      } else {
        rows[[cursor]] <- mfrmr_target_bridge_run_route(
          row, generated_capture$value, generation_seconds,
          maxit, quad_points
        )
        rows[[cursor]]$Warnings <- paste(
          unique(c(
            generated_capture$warnings, rows[[cursor]]$Warnings
          )),
          collapse = " | "
        )
      }
      partial <- do.call(rbind, rows[seq_len(cursor)])
      utils::write.csv(
        partial, file.path(staging, "run-progress.csv"),
        row.names = FALSE, na = ""
      )
    }
  }
  results <- do.call(rbind, rows)
  completed <- Sys.time()
  bridge_truth_hashes <- unique(results$TruthHash[
    results$Design == "two_rater_bridge_gradient" &
      !is.na(results$TruthHash)
  ])
  if (length(bridge_truth_hashes) != 1L) {
    stop(
      "The bridge gradient did not retain one common truth identity.",
      call. = FALSE
    )
  }
  pair_audit <- do.call(rbind, lapply(split(results, results$DataCellId),
                                      function(x) {
    data.frame(
      DataCellId = x$DataCellId[1L], Routes = nrow(x),
      DataHashes = length(unique(x$DataHash[!is.na(x$DataHash)])),
      SameData = nrow(x) == 2L &&
        length(unique(x$DataHash[!is.na(x$DataHash)])) == 1L,
      stringsAsFactors = FALSE
    )
  }))
  summary <- data.frame(
    Schema = "mfrmr-target-baseline-bridge-summary-v1",
    DataCells = length(cell_ids), Routes = nrow(results),
    ExecutedRoutes = sum(results$Executed),
    FailedRoutes = sum(results$RunState %in% c(
      "generation_failed", "fit_failed"
    )),
    ExpectedFailClosedRoutes = sum(
      results$RunState == "expected_fail_closed"
    ),
    FalseReadyRoutes = sum(results$FalseReady %in% TRUE, na.rm = TRUE),
    InferenceReadyRoutes = sum(
      results$InferenceReady %in% TRUE, na.rm = TRUE
    ),
    SameDataPairs = sum(pair_audit$SameData),
    BridgeTruthHashes = length(bridge_truth_hashes),
    TotalFitSeconds = sum(results$FitElapsedSeconds, na.rm = TRUE),
    MaxFitSeconds = max(results$FitElapsedSeconds, na.rm = TRUE),
    OSPeakWorkingSetMB = max(results$OSPeakWorkingSetMB, na.rm = TRUE),
    OSPeakPagefileMB = max(results$OSPeakPagefileMB, na.rm = TRUE),
    StatisticalOperatingCharacteristicsEstimated = FALSE,
    RecoveryCriteriaFrozen = FALSE, PCARun = FALSE,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "capacity_and_bridge_calibration_only",
    stringsAsFactors = FALSE
  )
  out <- structure(list(
    registry = registry, results = results, pair_audit = pair_audit,
    summary = summary, execution_identity = identity$execution,
    package_identity = identity$package,
    runner_identity = identity$runners,
    capability_manifest = identity$capabilities,
    started_at = started, completed_at = completed,
    confirmation_authorized = FALSE, session_info = utils::sessionInfo()
  ), class = "mfrmr_target_scale_baseline_bridge")
  utils::write.csv(registry, file.path(staging, "registry.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(results, file.path(staging, "run-results.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(pair_audit, file.path(staging, "pair-audit.csv"),
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
  saveRDS(out, file.path(staging, "target-baseline-bridge.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  completion <- list(
    schema = "mfrmr-target-baseline-bridge-completion-v1",
    execution_sha256 = identity$execution$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(completed, tz = "UTC", usetz = TRUE),
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  mfrmr_target_bridge_validate_completion(
    staging, identity$execution$ExecutionSHA256
  )
  if (!file.rename(staging, output_dir)) {
    stop("Completed target baseline evidence could not be promoted.",
         call. = FALSE)
  }
  mfrmr_target_bridge_validate_completion(
    output_dir, identity$execution$ExecutionSHA256
  )
  out
}
