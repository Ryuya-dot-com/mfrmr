# Repository-only execution-phase profile for mfrmr 0.2.3.
#
# This pilot instruments a fixed subset of the Draft49 JML bottleneck grid.
# Elapsed time is diagnostic-only: it does not enter optimization, readiness,
# recovery eligibility, or any release decision. The pilot estimates neither
# operating characteristics nor a frozen runtime envelope.

mfrmr_jml_phase_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("jml-phase-profile-pilot-0\\.2\\.3\\.R$", files)]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path("inst", "validation", "jml-phase-profile-pilot-0.2.3.R"),
    "jml-phase-profile-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_jml_phase_require_support <- function() {
  target_env <- environment(mfrmr_jml_phase_require_support)
  required <- c(
    "mfrmr_jml_profile_cells", "mfrmr_jml_profile_registry",
    "mfrmr_jml_profile_build", "mfrmr_jml_profile_take",
    "mfrmr_target_bridge_readiness", "mfrmr_gpcm_stress_capture",
    "mfrmr_gpcm_stress_fun", "mfrmr_gpcm_repilot_hash_object",
    "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_runtime_package_identity",
    "mfrmr_target_scale_artifact_inventory"
  )
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    candidates <- c(
      if (!is.na(mfrmr_jml_phase_source_dir)) {
        file.path(
          mfrmr_jml_phase_source_dir,
          "jml-bottleneck-decomposition-pilot-0.2.3.R"
        )
      } else character(0),
      file.path(
        "inst", "validation",
        "jml-bottleneck-decomposition-pilot-0.2.3.R"
      ),
      "jml-bottleneck-decomposition-pilot-0.2.3.R"
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("Cannot locate the Draft49 JML profile support.", call. = FALSE)
    }
    sys.source(path, envir = target_env)
    mfrmr_jml_profile_require_support()
  }
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("JML phase-profile support did not load completely.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_jml_phase_registry <- function() {
  mfrmr_jml_phase_require_support()
  registry <- mfrmr_jml_profile_registry()
  selected <- c(
    "JBP-P200-JML-auto", "JBP-P200-JML-BFGS", "JBP-P200-MML-auto",
    "JBP-P400-JML-auto", "JBP-P400-JML-BFGS", "JBP-P400-MML-auto",
    "JBP-R12-JML-auto", "JBP-R12-JML-BFGS", "JBP-R12-MML-auto",
    "JBP-C12-E04-JML-auto", "JBP-C12-E04-JML-BFGS",
    "JBP-C12-E04-MML-auto",
    "JBP-C12-E02-JML-auto", "JBP-C12-E02-MML-auto",
    "JBP-C12-E12-JML-auto", "JBP-C12-E12-MML-auto",
    "JBP-P200-X20-JML-auto", "JBP-P200-X20-JML-BFGS",
    "JBP-P200-X20-MML-auto"
  )
  idx <- match(selected, registry$ScenarioId)
  if (anyNA(idx)) {
    stop("The fixed phase-profile registry does not match Draft49.",
         call. = FALSE)
  }
  out <- registry[idx, , drop = FALSE]
  out$DataRole <- "decision_nonintervening_phase_profile"
  out$EvidenceUse <- "phase_decomposition_calibration_only"
  out$ConfirmationAuthorized <- FALSE
  canonical <- out[, setdiff(
    names(out), c("ScenarioId", "DeclaredManifestSHA256")
  ), drop = FALSE]
  out$PhaseManifestSHA256 <- mfrmr_gpcm_repilot_hash_object(canonical)
  row.names(out) <- NULL
  out
}

mfrmr_jml_phase_identity <- function(registry, maxit, quad_points, reltol) {
  package <- mfrmr_gpcm_repilot_runtime_package_identity()
  files <- data.frame(
    Component = c("phase_profile", "draft49_profile"),
    File = c(
      "jml-phase-profile-pilot-0.2.3.R",
      "jml-bottleneck-decomposition-pilot-0.2.3.R"
    ),
    stringsAsFactors = FALSE
  )
  paths <- file.path(mfrmr_jml_phase_source_dir, files$File)
  if (any(!file.exists(paths))) {
    stop("One or more phase-profile identity files are missing.",
         call. = FALSE)
  }
  files$SHA256 <- vapply(paths, mfrmr_gpcm_repilot_hash_file, character(1))
  attr(files, "CompositeSHA256") <- mfrmr_gpcm_repilot_hash_object(files)
  contract <- data.frame(
    Option = "mfrmr.phase_timing",
    EnabledValue = TRUE,
    Storage = "fit$config$phase_timing",
    Clock = "proc.time.elapsed",
    DecisionUse = "diagnostic_only",
    ExpectedPhases = 18L,
    stringsAsFactors = FALSE
  )
  contract$ContractSHA256 <- mfrmr_gpcm_repilot_hash_object(
    contract[, setdiff(names(contract), "ContractSHA256"), drop = FALSE]
  )
  execution <- data.frame(
    Schema = "mfrmr-jml-phase-profile-v3",
    DataCells = length(unique(registry$DataCellId)),
    Routes = nrow(registry),
    Maxit = as.integer(maxit), QuadPoints = as.integer(quad_points),
    Reltol = as.numeric(reltol),
    PhaseManifestSHA256 = unique(registry$PhaseManifestSHA256),
    PackageSHA256 = package$PackageSHA256,
    RunnerSHA256 = attr(files, "CompositeSHA256"),
    InstrumentationContractSHA256 = contract$ContractSHA256,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "phase_decomposition_calibration_only",
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  list(execution = execution, package = package, runners = files,
       contract = contract)
}

mfrmr_jml_phase_semantic_hash <- function(fit) {
  mfrmr_gpcm_repilot_hash_object(list(
    summary = fit$summary,
    facets = fit$facets,
    interactions = fit$interactions,
    steps = fit$steps,
    slopes = fit$slopes,
    readiness = fit$readiness,
    optimizer = list(
      par = fit$opt$par, value = fit$opt$value,
      convergence = fit$opt$convergence, message = fit$opt$message
    )
  ))
}

mfrmr_jml_phase_run_route <- function(row, generated, maxit,
                                       quad_points, reltol) {
  fit_args <- list(
    data = generated$data, person = "Person",
    facets = c("Rater", "Criterion"), score = "Score",
    model = "PCM", method = as.character(row$Method),
    rating_min = 1L, rating_max = 5L, step_facet = "Criterion",
    maxit = as.integer(maxit), reltol = as.numeric(reltol),
    optimizer = as.character(row$OptimizerRequested)
  )
  if (identical(as.character(row$Method), "MML")) {
    fit_args$quad_points <- as.integer(quad_points)
  }

  old_opt <- options(mfrmr.phase_timing = TRUE)
  on.exit(options(old_opt), add = TRUE)
  invisible(gc(reset = TRUE))
  started <- proc.time()
  capture <- mfrmr_gpcm_stress_capture(
    do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), fit_args)
  )
  outer_seconds <- unname(as.numeric(
    (proc.time() - started)[["elapsed"]]
  ))

  base <- data.frame(
    ScenarioId = as.character(row$ScenarioId),
    DataCellId = as.character(row$DataCellId),
    PrimaryAxis = as.character(row$PrimaryAxis),
    Method = as.character(row$Method),
    OptimizerRequested = as.character(row$OptimizerRequested),
    ExpectedFitState = as.character(row$ExpectedFitState),
    Rows = nrow(generated$data),
    Persons = length(unique(generated$data$Person)),
    DataHash = as.character(generated$support$RetainedDataHash),
    CellTruthHash = as.character(generated$CellTruthHash),
    Executed = TRUE, FitSucceeded = FALSE,
    Error = NA_character_, Warnings = paste(capture$warnings, collapse = " | "),
    FitReadiness = NA_character_, InferenceReady = NA,
    NumericalState = NA_character_, BoundaryState = NA_character_,
    OptimizerMethod = NA_character_, Npar = NA_integer_,
    FunctionEvaluations = NA_integer_, TerminalGradientSupNorm = NA_real_,
    StructuralAuditState = NA_character_, StructuralAuditComplete = NA,
    StructuralExpandedTargets = NA_integer_,
    StructuralFreeTargets = NA_integer_,
    StructuralTargetDirections = NA_integer_,
    StructuralLPVariables = NA_integer_, StructuralLPConstraints = NA_integer_,
    StructuralSparseLPNonzeros = NA_real_,
    StructuralCertificateRows = NA_integer_,
    JointAuditState = NA_character_, JointAuditComplete = NA,
    JointExpandedTargets = NA_integer_, JointFreeTargets = NA_integer_,
    JointTargetDirections = NA_integer_, JointLPVariables = NA_integer_,
    JointLPConstraints = NA_integer_, JointSparseLPNonzeros = NA_real_,
    JointConeCertificateRows = NA_integer_,
    JointTargetCertificateRows = NA_integer_,
    SemanticResultSHA256 = NA_character_,
    OuterFitSeconds = outer_seconds, InstrumentedTotalSeconds = NA_real_,
    PhaseSumExcludingTotal = NA_real_, PhaseCoverageRatio = NA_real_,
    OptimizationSeconds = NA_real_, OptimizationShare = NA_real_,
    PreFitAuditSeconds = NA_real_, PostFitAuditSeconds = NA_real_,
    OutputAssemblySeconds = NA_real_, UnattributedOuterSeconds = NA_real_,
    DominantPhase = NA_character_, DominantPhaseShare = NA_real_,
    TimingRows = 0L, TimingContractValid = FALSE,
    FalseReady = FALSE, ConfirmationAuthorized = FALSE,
    EvidenceUse = "phase_decomposition_calibration_only",
    stringsAsFactors = FALSE
  )
  if (inherits(capture$value, "error")) {
    base$Error <- conditionMessage(capture$value)
    return(list(result = base, phases = data.frame()))
  }

  fit <- capture$value
  timing <- as.data.frame(fit$config$phase_timing %||% data.frame(),
                          stringsAsFactors = FALSE)
  required <- c(
    "Order", "Phase", "ElapsedSeconds", "Clock", "Scope", "DecisionUse"
  )
  if (!identical(names(timing), required) || nrow(timing) != 18L ||
      any(!is.finite(timing$ElapsedSeconds)) ||
      any(timing$ElapsedSeconds < 0) ||
      any(timing$DecisionUse != "diagnostic_only")) {
    stop("A successful fit violated the phase-timing contract.", call. = FALSE)
  }
  ready <- mfrmr_target_bridge_readiness(fit)
  summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
  total <- timing$ElapsedSeconds[timing$Phase == "mfrm_estimate_total"]
  exclusive <- timing[timing$Phase != "mfrm_estimate_total", , drop = FALSE]
  if (length(total) != 1L || total + 1e-8 < max(exclusive$ElapsedSeconds)) {
    stop("The phase total does not contain each component phase.",
         call. = FALSE)
  }
  phase_sum <- sum(exclusive$ElapsedSeconds)
  exclusive$ScenarioId <- as.character(row$ScenarioId)
  exclusive$DataCellId <- as.character(row$DataCellId)
  exclusive$Method <- as.character(row$Method)
  exclusive$OptimizerRequested <- as.character(row$OptimizerRequested)
  exclusive$ShareOfEstimateTotal <- if (total > 0) {
    exclusive$ElapsedSeconds / total
  } else NA_real_
  exclusive <- exclusive[, c(
    "ScenarioId", "DataCellId", "Method", "OptimizerRequested",
    "Order", "Phase", "ElapsedSeconds", "ShareOfEstimateTotal",
    "Clock", "Scope", "DecisionUse"
  )]
  dominant <- exclusive[which.max(exclusive$ElapsedSeconds), , drop = FALSE]
  phase_value <- function(names) {
    sum(exclusive$ElapsedSeconds[exclusive$Phase %in% names])
  }

  base$FitSucceeded <- TRUE
  base$FitReadiness <- ready$FitReadiness
  base$InferenceReady <- ready$InferenceReady
  base$NumericalState <- ready$NumericalState
  base$BoundaryState <- ready$BoundaryState
  base$OptimizerMethod <- as.character(mfrmr_jml_profile_take(
    summary, "OptimizerMethod", NA_character_
  ))
  base$Npar <- as.integer(mfrmr_jml_profile_take(summary, "Npar", NA_integer_))
  base$FunctionEvaluations <- as.integer(mfrmr_jml_profile_take(
    summary, "FunctionEvaluations", NA_integer_
  ))
  base$TerminalGradientSupNorm <- as.numeric(mfrmr_jml_profile_take(
    summary, "TerminalGradientSupNorm", NA_real_
  ))
  boundary <- fit$config$boundary_audit %||% list()
  structural <- boundary$structural_additive %||% list()
  joint <- boundary$joint_additive %||% list()
  structural_dimensions <- as.data.frame(
    structural$dimensions %||% data.frame(), stringsAsFactors = FALSE
  )
  joint_dimensions <- as.data.frame(
    joint$dimensions %||% data.frame(), stringsAsFactors = FALSE
  )
  base$StructuralAuditState <- as.character(structural$state %||% NA_character_)
  base$StructuralAuditComplete <- isTRUE(structural$complete)
  base$StructuralExpandedTargets <- as.integer(mfrmr_jml_profile_take(
    structural_dimensions, "ExpandedTargets", NA_integer_
  ))
  base$StructuralFreeTargets <- as.integer(mfrmr_jml_profile_take(
    structural_dimensions, "FreeTargets", NA_integer_
  ))
  base$StructuralTargetDirections <- as.integer(mfrmr_jml_profile_take(
    structural_dimensions, "TargetDirections", NA_integer_
  ))
  base$StructuralLPVariables <- as.integer(mfrmr_jml_profile_take(
    structural_dimensions, "LPVariables", NA_integer_
  ))
  base$StructuralLPConstraints <- as.integer(mfrmr_jml_profile_take(
    structural_dimensions, "LPConstraints", NA_integer_
  ))
  base$StructuralSparseLPNonzeros <- as.numeric(mfrmr_jml_profile_take(
    structural_dimensions, "SparseLPNonzeros", NA_real_
  ))
  base$StructuralCertificateRows <- nrow(as.data.frame(
    structural$certificates %||% data.frame(), stringsAsFactors = FALSE
  ))
  base$JointAuditState <- as.character(joint$state %||% NA_character_)
  base$JointAuditComplete <- isTRUE(joint$complete)
  base$JointExpandedTargets <- as.integer(mfrmr_jml_profile_take(
    joint_dimensions, "ExpandedTargets", NA_integer_
  ))
  base$JointFreeTargets <- as.integer(mfrmr_jml_profile_take(
    joint_dimensions, "FreeTargets", NA_integer_
  ))
  base$JointTargetDirections <- as.integer(mfrmr_jml_profile_take(
    joint_dimensions, "TargetDirections", NA_integer_
  ))
  base$JointLPVariables <- as.integer(mfrmr_jml_profile_take(
    joint_dimensions, "LPVariables", NA_integer_
  ))
  base$JointLPConstraints <- as.integer(mfrmr_jml_profile_take(
    joint_dimensions, "LPConstraints", NA_integer_
  ))
  base$JointSparseLPNonzeros <- as.numeric(mfrmr_jml_profile_take(
    joint_dimensions, "SparseLPNonzeros", NA_real_
  ))
  base$JointConeCertificateRows <- nrow(as.data.frame(
    joint$cone_certificate %||% data.frame(), stringsAsFactors = FALSE
  ))
  base$JointTargetCertificateRows <- nrow(as.data.frame(
    joint$certificates %||% data.frame(), stringsAsFactors = FALSE
  ))
  base$SemanticResultSHA256 <- mfrmr_jml_phase_semantic_hash(fit)
  base$InstrumentedTotalSeconds <- total
  base$PhaseSumExcludingTotal <- phase_sum
  base$PhaseCoverageRatio <- if (total > 0) phase_sum / total else NA_real_
  base$OptimizationSeconds <- phase_value("optimization")
  base$OptimizationShare <- if (total > 0) {
    base$OptimizationSeconds / total
  } else NA_real_
  base$PreFitAuditSeconds <- phase_value(c(
    "category_support_audit", "estimability_audit", "data_review_and_guards"
  ))
  base$PostFitAuditSeconds <- phase_value(c(
    "post_optimization_audits", "person_boundary_audit",
    "structural_recession_audit", "joint_recession_audit",
    "gpcm_slope_boundary_audit", "gpcm_joint_boundary_audit"
  ))
  base$OutputAssemblySeconds <- phase_value(c(
    "parameter_and_person_tables", "readiness_assembly",
    "remaining_output_tables"
  ))
  base$UnattributedOuterSeconds <- outer_seconds - total
  base$DominantPhase <- dominant$Phase
  base$DominantPhaseShare <- dominant$ShareOfEstimateTotal
  base$TimingRows <- nrow(timing)
  base$TimingContractValid <- TRUE
  base$FalseReady <- identical(
    as.character(row$ExpectedFitState), "must_not_be_inference_ready"
  ) && isTRUE(ready$InferenceReady)
  list(result = base, phases = exclusive)
}

mfrmr_jml_phase_summarize <- function(phases) {
  groups <- split(
    phases,
    interaction(
      phases$Method, phases$OptimizerRequested, phases$Phase,
      drop = TRUE, lex.order = TRUE
    )
  )
  out <- do.call(rbind, lapply(groups, function(x) {
    data.frame(
      Method = x$Method[1L],
      OptimizerRequested = x$OptimizerRequested[1L],
      Phase = x$Phase[1L], Routes = nrow(x),
      TotalSeconds = sum(x$ElapsedSeconds),
      MedianSeconds = stats::median(x$ElapsedSeconds),
      MaxSeconds = max(x$ElapsedSeconds),
      MedianShareOfEstimateTotal = stats::median(
        x$ShareOfEstimateTotal, na.rm = TRUE
      ),
      MaxShareOfEstimateTotal = max(x$ShareOfEstimateTotal, na.rm = TRUE),
      DecisionUse = "diagnostic_only",
      stringsAsFactors = FALSE
    )
  }))
  row.names(out) <- NULL
  out[order(
    match(out$Method, c("JML", "MML")),
    out$OptimizerRequested, out$Phase
  ), , drop = FALSE]
}

mfrmr_run_jml_phase_profile <- function(
    dry_run = TRUE, authorize = FALSE, maxit = 60L, quad_points = 7L,
    reltol = 1e-9, output_dir = NULL, progress = interactive()) {
  mfrmr_jml_phase_require_support()
  registry <- mfrmr_jml_phase_registry()
  identity <- mfrmr_jml_phase_identity(
    registry, maxit = maxit, quad_points = quad_points, reltol = reltol
  )
  if (isTRUE(dry_run)) {
    return(list(
      registry = registry, execution_identity = identity$execution,
      package_identity = identity$package, runner_identity = identity$runners,
      instrumentation_contract = identity$contract,
      confirmation_authorized = FALSE
    ))
  }
  if (!isTRUE(authorize)) {
    stop("Live phase profiling requires `authorize = TRUE`.", call. = FALSE)
  }
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("Live phase profiling requires one `output_dir`.", call. = FALSE)
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
  dir.create(staging, recursive = TRUE)
  promoted <- FALSE
  on.exit({
    if (!promoted && dir.exists(staging)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
  }, add = TRUE)

  cells <- mfrmr_jml_profile_cells()
  selected_cells <- unique(registry$DataCellId)
  results <- vector("list", nrow(registry))
  phases <- vector("list", nrow(registry))
  cursor <- 0L
  for (cell_id in selected_cells) {
    cell <- cells[match(cell_id, cells$DataCellId), , drop = FALSE]
    if (isTRUE(progress)) message("[phase] ", cell_id)
    generated <- mfrmr_jml_profile_build(cell)
    routes <- registry[registry$DataCellId == cell_id, , drop = FALSE]
    for (j in seq_len(nrow(routes))) {
      cursor <- cursor + 1L
      if (isTRUE(progress)) {
        message("  ", routes$Method[j], " / ", routes$OptimizerRequested[j])
      }
      route <- mfrmr_jml_phase_run_route(
        routes[j, , drop = FALSE], generated,
        maxit = maxit, quad_points = quad_points, reltol = reltol
      )
      results[[cursor]] <- route$result
      phases[[cursor]] <- route$phases
      utils::write.csv(
        do.call(rbind, results[seq_len(cursor)]),
        file.path(staging, "run-progress.csv"), row.names = FALSE, na = ""
      )
    }
  }
  results <- do.call(rbind, results)
  phases <- do.call(rbind, phases)
  row.names(results) <- NULL
  row.names(phases) <- NULL
  if (!identical(results$ScenarioId, registry$ScenarioId) ||
      any(!results$FitSucceeded) || any(!results$TimingContractValid) ||
      any(results$FalseReady)) {
    stop("Phase-profile completion or fail-closed invariant failed.",
         call. = FALSE)
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
  if (any(!data_audit$SameData) || any(!data_audit$SameCellTruth)) {
    stop("Phase-profile paired-data invariant failed.", call. = FALSE)
  }
  phase_summary <- mfrmr_jml_phase_summarize(phases)
  summary <- data.frame(
    Schema = "mfrmr-jml-phase-profile-summary-v3",
    DataCells = length(unique(results$DataCellId)), Routes = nrow(results),
    SuccessfulRoutes = sum(results$FitSucceeded),
    TimingContractRoutes = sum(results$TimingContractValid),
    FalseReadyRoutes = sum(results$FalseReady),
    InferenceReadyRoutes = sum(results$InferenceReady, na.rm = TRUE),
    TotalOuterFitSeconds = sum(results$OuterFitSeconds),
    MaxOuterFitSeconds = max(results$OuterFitSeconds),
    MedianJMLOptimizationShare = stats::median(
      results$OptimizationShare[results$Method == "JML"], na.rm = TRUE
    ),
    MedianMMLOptimizationShare = stats::median(
      results$OptimizationShare[results$Method == "MML"], na.rm = TRUE
    ),
    StatisticalOperatingCharacteristicsEstimated = FALSE,
    RuntimeCriteriaFrozen = FALSE, ConfirmationAuthorized = FALSE,
    EvidenceUse = "phase_decomposition_calibration_only",
    stringsAsFactors = FALSE
  )
  out <- list(
    registry = registry, results = results, phases = phases,
    phase_summary = phase_summary, data_audit = data_audit, summary = summary,
    execution_identity = identity$execution,
    package_identity = identity$package,
    runner_identity = identity$runners,
    instrumentation_contract = identity$contract,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    "registry.csv" = registry, "run-results.csv" = results,
    "phase-timings.csv" = phases, "phase-summary.csv" = phase_summary,
    "data-audit.csv" = data_audit, "run-summary.csv" = summary,
    "execution-identity.csv" = identity$execution,
    "package-identity.csv" = identity$package,
    "runner-identity.csv" = identity$runners,
    "instrumentation-contract.csv" = identity$contract
  )
  for (name in names(files)) {
    utils::write.csv(files[[name]], file.path(staging, name),
                     row.names = FALSE, na = "")
  }
  saveRDS(out, file.path(staging, "jml-phase-profile.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  completion <- list(
    schema = "mfrmr-jml-phase-profile-completion-v3",
    execution_sha256 = identity$execution$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) {
    stop("Completed phase-profile evidence could not be promoted.",
         call. = FALSE)
  }
  promoted <- TRUE
  invisible(out)
}
