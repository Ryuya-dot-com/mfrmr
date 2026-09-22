# Repository-only target-scale positive-cone calibration for mfrmr 0.2.3.
# This runner cannot alter a fit, select a solver, authorize normalization in
# production, freeze a supported envelope, or authorize confirmation.

mfrmr_target_cone_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-target-positive-cone-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) return(dirname(normalizePath(
    hit[length(hit)], winslash = "/", mustWork = FALSE
  )))
  candidates <- c(
    file.path(
      "inst", "validation", "jml-target-positive-cone-pilot-0.2.3.R"
    ),
    "jml-target-positive-cone-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else dirname(normalizePath(
    path, winslash = "/", mustWork = TRUE
  ))
})

mfrmr_target_cone_or <- function(x, replacement) {
  if (is.null(x)) replacement else x
}

mfrmr_target_cone_source <- function(file, target_env) {
  candidates <- c(
    if (!is.na(mfrmr_target_cone_source_dir)) {
      file.path(mfrmr_target_cone_source_dir, file)
    } else character(0),
    file.path("inst", "validation", file), file
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) stop("Cannot locate target-cone support: ", file,
                        call. = FALSE)
  sys.source(path, envir = target_env)
  invisible(path)
}

mfrmr_target_cone_require_support <- function() {
  target_env <- environment(mfrmr_target_cone_require_support)
  if (!exists(
    "mfrmr_target_bridge_require_support", envir = target_env,
    mode = "function", inherits = TRUE
  )) mfrmr_target_cone_source(
    "target-scale-baseline-bridge-pilot-0.2.3.R", target_env
  )
  mfrmr_target_bridge_require_support()
  if (!exists(
    "mfrmr_normalization_require_support", envir = target_env,
    mode = "function", inherits = TRUE
  )) mfrmr_target_cone_source(
    "jml-solver-normalization-pilot-0.2.3.R", target_env
  )
  mfrmr_normalization_require_support()
  required <- c(
    "mfrmr_target_bridge_thresholds", "mfrmr_target_bridge_slopes",
    "mfrmr_target_bridge_readiness", "mfrmr_target_scale_artifact_inventory",
    "mfrmr_gpcm_stress_fun", "mfrmr_gpcm_stress_support",
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_package_content_identity",
    "mfrmr_solver_capture_start", "mfrmr_solver_empty_capture",
    "mfrmr_jml_phase_semantic_hash",
    "mfrmr_jml_phase_structural_status_hash",
    "mfrmr_normalization_evaluate_case"
  )
  if (!all(vapply(
    required, exists, logical(1), envir = target_env,
    mode = "function", inherits = TRUE
  ))) stop("Target-cone support did not load completely.", call. = FALSE)
  invisible(TRUE)
}

mfrmr_target_cone_capabilities <- function() {
  mfrmr_target_cone_require_support()
  packages <- c("mfrmr", "Matrix", "digest", "lpSolve", "slam", "Rglpk")
  available <- vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  data.frame(
    Capability = packages,
    Available = available,
    Version = vapply(packages, function(package) {
      if (requireNamespace(package, quietly = TRUE)) {
        as.character(utils::packageVersion(package))
      } else NA_character_
    }, character(1)),
    RuntimeSHA256 = vapply(seq_along(packages), function(i) {
      if (available[i]) {
        mfrmr_gpcm_repilot_package_content_identity(packages[i])$PackageSHA256
      } else NA_character_
    }, character(1)),
    Role = c(
      "runtime_under_review", "sparse_geometry", "artifact_identity",
      "production_lp", "independent_sparse_triplet", "candidate_glpk"
    ),
    RequiredForLivePilot = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_target_cone_registry <- function() {
  designs <- data.frame(
    DesignId = c("complete", "sparse_balanced", "sparse_random"),
    Design = c("complete_balanced", "sparse40_balanced", "sparse40_random"),
    NPersons = 400L,
    NRaters = c(3L, 12L, 12L),
    NCriteria = c(4L, 12L, 12L),
    NCategories = c(5L, 7L, 7L),
    LinkPersons = c(NA_integer_, 40L, 40L),
    AssignmentMode = c("not_applicable", "balanced", "random"),
    SlopeRegime = c("mild", "strong", "strong"),
    Seed = 259001:259003,
    stringsAsFactors = FALSE
  )
  out <- merge(
    designs, data.frame(Model = c("RSM", "GPCM"), stringsAsFactors = FALSE),
    by = NULL, sort = FALSE
  )
  out <- out[order(
    match(out$DesignId, designs$DesignId),
    match(out$Model, c("RSM", "GPCM"))
  ), , drop = FALSE]
  rownames(out) <- NULL
  out$ScenarioId <- paste("TPC", toupper(out$DesignId), out$Model, sep = "-")
  out$Method <- "JML"
  out$EvidenceUse <- "target_positive_cone_calibration_only"
  out$ProductionChangeAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  canonical <- out[, setdiff(names(out), "ScenarioId"), drop = FALSE]
  out$DeclaredManifestSHA256 <- mfrmr_gpcm_repilot_hash_object(canonical)
  out
}

mfrmr_target_cone_prespecification <- function(maxit, reltol) {
  list(
    schema = "mfrmr-jml-target-positive-cone-prespec-v2",
    designs = c("complete_balanced", "sparse40_balanced", "sparse40_random"),
    models = c("RSM", "GPCM"), persons = 400L,
    topology_pairing = paste(
      "same seed assignment dimensions link set row order Person Rater and",
      "Criterion within each design; response hashes must remain distinct"
    ),
    execution = paste(
      "one ordinary and one capture JML fit per route; semantic readiness",
      "and structural/joint boundary identities must match"
    ),
    lp_formulations = c("raw", "l1_row_normalized"),
    lp_solvers = c("lpSolve", "GLPK"),
    comparison_scale = "unmodified captured target-scale problem",
    diagnostic_reference = paste(
      "for every captured problem whose production reason is not",
      "no_target_recession_direction or whose recorded capacity is positive,",
      "repeat raw and normalized lpSolve with native timeout zero; this",
      "post-failure calibration cannot authorize a no-timeout production rule"
    ),
    evidence_completion = paste(
      "safe negative disagreement and non-evaluated results are retained;",
      "candidate qualification is not required for bundle completion"
    ),
    maxit = as.integer(maxit), reltol = as.numeric(reltol),
    solver_branch_continuation_authorized = FALSE,
    production_change_authorized = FALSE,
    confirmation_authorized = FALSE
  )
}

mfrmr_target_cone_topology <- function(data) {
  required <- c("Person", "Rater", "Criterion")
  if (!all(required %in% names(data))) {
    stop("Generated target-cone data lack topology columns.", call. = FALSE)
  }
  topology <- data[, required, drop = FALSE]
  rater_exposure <- table(topology$Rater)
  criterion_exposure <- table(topology$Criterion)
  person_exposure <- table(topology$Person)
  data.frame(
    Rows = nrow(topology), Persons = length(person_exposure),
    Raters = length(rater_exposure), Criteria = length(criterion_exposure),
    MinimumRaterExposure = min(rater_exposure),
    MaximumRaterExposure = max(rater_exposure),
    RaterExposureCV = stats::sd(as.numeric(rater_exposure)) /
      mean(as.numeric(rater_exposure)),
    MinimumPersonExposure = min(person_exposure),
    MaximumPersonExposure = max(person_exposure),
    MinimumCriterionExposure = min(criterion_exposure),
    MaximumCriterionExposure = max(criterion_exposure),
    TopologySHA256 = mfrmr_gpcm_repilot_hash_object(topology),
    ExposureSHA256 = mfrmr_gpcm_repilot_hash_object(list(
      rater = rater_exposure, criterion = criterion_exposure,
      person = person_exposure
    )),
    stringsAsFactors = FALSE
  )
}

mfrmr_target_cone_build <- function(row) {
  row <- as.list(row)
  model <- as.character(row$Model)
  n_rater <- as.integer(row$NRaters)
  n_criterion <- as.integer(row$NCriteria)
  criteria <- sprintf("C%02d", seq_len(n_criterion))
  complete <- identical(as.character(row$DesignId), "complete")
  sparse_controls <- if (complete) NULL else list(
    link_persons = as.integer(row$LinkPersons),
    link_raters_per_person = n_rater,
    assignment_mode = as.character(row$AssignmentMode),
    min_common_persons_per_rater_pair = as.integer(row$LinkPersons)
  )
  args <- list(
    n_person = as.integer(row$NPersons), n_rater = n_rater,
    n_criterion = n_criterion,
    raters_per_person = if (complete) n_rater else 1L,
    score_levels = as.integer(row$NCategories), theta_sd = 1,
    rater_sd = 0.55, criterion_sd = 0.35,
    thresholds = mfrmr_target_bridge_thresholds(
      model, criteria, as.integer(row$NCategories)
    ),
    model = model,
    assignment = if (complete) "crossed" else "sparse_linked",
    sparse_controls = sparse_controls
  )
  if (identical(model, "GPCM")) {
    args$step_facet <- "Criterion"
    args$slope_facet <- "Criterion"
    args$slopes <- mfrmr_target_bridge_slopes(
      model, criteria, as.character(row$SlopeRegime)
    )
  }
  spec <- do.call(mfrmr_gpcm_stress_fun("build_mfrm_sim_spec"), args)
  data <- mfrmr_gpcm_stress_fun("simulate_mfrm_data")(
    sim_spec = spec, seed = as.integer(row$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  topology <- mfrmr_target_cone_topology(data)
  support <- mfrmr_gpcm_stress_support(data, as.integer(row$NCategories))
  list(
    data = data, spec = spec, truth = truth,
    topology = topology, support = support,
    TruthSHA256 = mfrmr_gpcm_repilot_hash_object(list(
      person = truth$person, facets = truth$facets,
      step_table = truth$step_table, slope_table = truth$slope_table,
      population = truth$population
    )),
    ResponseSHA256 = mfrmr_gpcm_repilot_hash_object(data$Score)
  )
}

mfrmr_target_cone_fit_args <- function(row, generated, maxit, reltol) {
  args <- list(
    data = generated$data, person = "Person",
    facets = c("Rater", "Criterion"), score = "Score",
    model = as.character(row$Model), method = "JML",
    rating_min = 1L, rating_max = as.integer(row$NCategories),
    maxit = as.integer(maxit), reltol = as.numeric(reltol)
  )
  if (identical(as.character(row$Model), "GPCM")) {
    args$step_facet <- "Criterion"
    args$slope_facet <- "Criterion"
  }
  args
}

mfrmr_target_cone_fit <- function(args, sink = NULL, scenario_id = NULL,
                                  model = NULL) {
  capture <- !is.null(sink)
  session <- if (capture) {
    mfrmr_solver_capture_start(sink, scenario_id, model)
  } else NULL
  stopped <- FALSE
  on.exit({
    if (!is.null(session) && !stopped) session$stop()
  }, add = TRUE)
  start <- unname(proc.time()[["elapsed"]])
  fit <- tryCatch(
    suppressWarnings(do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), args)),
    error = function(e) e
  )
  elapsed <- max(0, unname(proc.time()[["elapsed"]]) - start)
  captured <- if (is.null(session)) {
    mfrmr_solver_empty_capture()
  } else {
    value <- session$stop()
    stopped <- TRUE
    value
  }
  list(fit = fit, captured = captured, elapsed = elapsed)
}

mfrmr_target_cone_boundary <- function(fit, name) {
  if (inherits(fit, "error")) return(list(
    state = NA_character_, status_sha256 = NA_character_
  ))
  audit <- mfrmr_target_cone_or(fit$config$boundary_audit[[name]], list())
  list(
    state = as.character(mfrmr_target_cone_or(audit$state, NA_character_)),
    status_sha256 = mfrmr_jml_phase_structural_status_hash(audit)
  )
}

mfrmr_target_cone_run_route <- function(row, generated, sink, maxit, reltol) {
  args <- mfrmr_target_cone_fit_args(row, generated, maxit, reltol)
  baseline <- mfrmr_target_cone_fit(args)
  instrumented <- mfrmr_target_cone_fit(
    args, sink, as.character(row$ScenarioId), as.character(row$Model)
  )
  baseline_ok <- !inherits(baseline$fit, "error")
  instrumented_ok <- !inherits(instrumented$fit, "error")
  baseline_ready <- if (baseline_ok) {
    mfrmr_target_bridge_readiness(baseline$fit)
  } else list()
  instrumented_ready <- if (instrumented_ok) {
    mfrmr_target_bridge_readiness(instrumented$fit)
  } else list()
  baseline_structural <- mfrmr_target_cone_boundary(
    baseline$fit, "structural_additive"
  )
  instrumented_structural <- mfrmr_target_cone_boundary(
    instrumented$fit, "structural_additive"
  )
  baseline_joint <- mfrmr_target_cone_boundary(baseline$fit, "joint_additive")
  instrumented_joint <- mfrmr_target_cone_boundary(
    instrumented$fit, "joint_additive"
  )
  semantic_match <- baseline_ok && instrumented_ok && identical(
    mfrmr_jml_phase_semantic_hash(baseline$fit),
    mfrmr_jml_phase_semantic_hash(instrumented$fit)
  )
  readiness_match <- baseline_ok && instrumented_ok && identical(
    baseline_ready, instrumented_ready
  )
  boundary_match <- baseline_ok && instrumented_ok &&
    identical(baseline_structural, instrumented_structural) &&
    identical(baseline_joint, instrumented_joint)
  baseline_semantic_sha <- if (baseline_ok) {
    mfrmr_jml_phase_semantic_hash(baseline$fit)
  } else NA_character_
  instrumented_semantic_sha <- if (instrumented_ok) {
    mfrmr_jml_phase_semantic_hash(instrumented$fit)
  } else NA_character_
  data.frame(
    ScenarioId = as.character(row$ScenarioId),
    DesignId = as.character(row$DesignId), Design = as.character(row$Design),
    Model = as.character(row$Model), Method = "JML",
    DataSHA256 = as.character(generated$support$RetainedDataHash),
    TruthSHA256 = generated$TruthSHA256,
    ResponseSHA256 = generated$ResponseSHA256,
    TopologySHA256 = generated$topology$TopologySHA256,
    ExposureSHA256 = generated$topology$ExposureSHA256,
    Rows = generated$topology$Rows,
    MinimumRaterExposure = generated$topology$MinimumRaterExposure,
    MaximumRaterExposure = generated$topology$MaximumRaterExposure,
    RaterExposureCV = generated$topology$RaterExposureCV,
    MinCommonPersons = generated$support$MinCommonPersons,
    ZeroCommonRaterPairs = generated$support$ZeroCommonRaterPairs,
    BaselineFitSucceeded = baseline_ok,
    InstrumentedFitSucceeded = instrumented_ok,
    BaselineError = if (baseline_ok) NA_character_ else
      conditionMessage(baseline$fit),
    InstrumentedError = if (instrumented_ok) NA_character_ else
      conditionMessage(instrumented$fit),
    SemanticHashMatch = semantic_match,
    ReadinessMatch = readiness_match,
    BoundaryMatch = boundary_match,
    BaselineSemanticSHA256 = baseline_semantic_sha,
    InstrumentedSemanticSHA256 = instrumented_semantic_sha,
    BaselineReadinessSHA256 = if (baseline_ok) {
      mfrmr_gpcm_repilot_hash_object(baseline_ready)
    } else NA_character_,
    InstrumentedReadinessSHA256 = if (instrumented_ok) {
      mfrmr_gpcm_repilot_hash_object(instrumented_ready)
    } else NA_character_,
    BaselineFitReadiness = as.character(mfrmr_target_cone_or(
      baseline_ready$FitReadiness, NA_character_
    )),
    InstrumentedFitReadiness = as.character(mfrmr_target_cone_or(
      instrumented_ready$FitReadiness, NA_character_
    )),
    BaselineReasonCodes = as.character(mfrmr_target_cone_or(
      baseline_ready$ReasonCodes, NA_character_
    )),
    InstrumentedReasonCodes = as.character(mfrmr_target_cone_or(
      instrumented_ready$ReasonCodes, NA_character_
    )),
    InferenceReady = isTRUE(instrumented_ready$InferenceReady),
    BaselineStructuralState = baseline_structural$state,
    InstrumentedStructuralState = instrumented_structural$state,
    BaselineJointState = baseline_joint$state,
    InstrumentedJointState = instrumented_joint$state,
    BaselineStructuralTargetStatusSHA256 =
      baseline_structural$status_sha256,
    StructuralTargetStatusSHA256 = instrumented_structural$status_sha256,
    BaselineJointTargetStatusSHA256 = baseline_joint$status_sha256,
    JointTargetStatusSHA256 = instrumented_joint$status_sha256,
    CapturedProblems = nrow(instrumented$captured),
    PositiveProblems = sum(
      instrumented$captured$ProductionReason ==
        "certified_additive_recession_direction"
    ),
    NegativeProblems = sum(
      instrumented$captured$ProductionReason ==
        "no_target_recession_direction"
    ),
    BaselineElapsedSeconds = baseline$elapsed,
    InstrumentedElapsedSeconds = instrumented$elapsed,
    BaselineCaptureEquivalent =
      semantic_match && readiness_match && boundary_match,
    ProductionChangeAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_target_cone_problem_registry <- function(problems) {
  out <- do.call(rbind, lapply(problems, function(problem) data.frame(
    ProblemId = problem$ProblemId, ScenarioId = problem$ScenarioId,
    Model = problem$Model, Scope = problem$Scope,
    BaseSHA256 = problem$BaseSHA256,
    ProblemSHA256 = problem$ProblemSHA256,
    Parameters = problem$lp_base$n_parameters,
    Constraints = problem$lp_base$n_constraints,
    StoredNonzeros = as.double(problem$lp_base$stored_constraint_nonzeros),
    ObjectiveNonzeros = sum(problem$target != 0),
    ObjectiveTolerance = problem$objective_tolerance,
    CertificateTolerance = problem$certificate_tolerance,
    ProductionEvaluated = isTRUE(problem$production$evaluated),
    ProductionCertified = isTRUE(problem$production$certified),
    ProductionReason = as.character(problem$production$reason),
    ProductionCapacity = as.numeric(problem$production$target_capacity),
    stringsAsFactors = FALSE
  )))
  rownames(out) <- NULL
  out
}

mfrmr_target_cone_compare_problem <- function(problem) {
  problem$SourceProblemSHA256 <- problem$ProblemSHA256
  problem$ScaleExponent <- 0
  problem$RowScaleMinimum <- 1
  problem$RowScaleMaximum <- 1
  problem$RowScaleSHA256 <- mfrmr_gpcm_repilot_hash_object(rep(
    1, nrow(problem$lp_base$contrast_design)
  ))
  rows <- list(); cursor <- 0L
  for (formulation in c("raw", "l1_row_normalized")) {
    for (solver in c("lpSolve", "GLPK")) {
      cursor <- cursor + 1L
      started <- unname(proc.time()[["elapsed"]])
      value <- mfrmr_normalization_evaluate_case(
        problem, solver, formulation, problem$production
      )
      value$EvaluationElapsedSeconds <- max(
        0, unname(proc.time()[["elapsed"]]) - started
      )
      rows[[cursor]] <- value
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_target_cone_topology_audit <- function(fits) {
  rows <- lapply(unique(fits$DesignId), function(design_id) {
    pair <- fits[fits$DesignId == design_id, , drop = FALSE]
    data.frame(
      DesignId = design_id,
      Routes = nrow(pair),
      TopologyMatched = nrow(pair) == 2L &&
        length(unique(pair$TopologySHA256)) == 1L,
      ExposureMatched = nrow(pair) == 2L &&
        length(unique(pair$ExposureSHA256)) == 1L,
      ResponseHashesDistinct = nrow(pair) == 2L &&
        length(unique(pair$ResponseSHA256)) == 2L,
      Rows = if (nrow(pair) == 2L && length(unique(pair$Rows)) == 1L) {
        pair$Rows[1L]
      } else NA_integer_,
      MinimumRaterExposure = min(pair$MinimumRaterExposure),
      MaximumRaterExposure = max(pair$MaximumRaterExposure),
      RaterExposureCV = max(pair$RaterExposureCV),
      MinCommonPersons = min(pair$MinCommonPersons),
      ZeroCommonRaterPairs = max(pair$ZeroCommonRaterPairs),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_target_cone_reference_audit <- function(problems, comparison) {
  selected <- vapply(problems, function(problem) {
    reason <- as.character(problem$production$reason)
    capacity <- as.numeric(problem$production$target_capacity)
    !identical(reason, "no_target_recession_direction") ||
      (length(capacity) == 1L && is.finite(capacity) &&
         capacity > 10 * problem$objective_tolerance)
  }, logical(1))
  selected_problems <- problems[selected]
  rows <- list(); cursor <- 0L
  for (problem in selected_problems) {
    for (formulation in c("raw", "l1_row_normalized")) {
      cursor <- cursor + 1L
      reference_problem <- problem
      reference_problem$timeout <- 0L
      reference <- mfrmr_target_cone_compare_problem(reference_problem)
      reference <- reference[
        reference$Solver == "lpSolve" &
          reference$Formulation == formulation, , drop = FALSE
      ]
      observed <- comparison[
        comparison$ProblemId == problem$ProblemId &
          comparison$Solver == "lpSolve" &
          comparison$Formulation == formulation, , drop = FALSE
      ]
      if (nrow(reference) != 1L || nrow(observed) != 1L) stop(
        "Target-cone timeout reference keys are not unique.", call. = FALSE
      )
      reference$CapturedTimeoutSeconds <- as.integer(problem$timeout)
      reference$ReferenceTimeoutSeconds <- 0L
      reference$CapturedProductionReason <-
        as.character(problem$production$reason)
      reference$TimeoutLimitedReason <- observed$Reason
      reference$TimeoutLimitedSolverStatus <- observed$SolverStatus
      reference$TimeoutLimitedCertified <- observed$Certified
      reference$TimeoutLimitedProvenanceSafe <- observed$ProvenanceSafe
      reference$OutcomeMatchesTimeoutLimited <-
        identical(reference$Reason, observed$Reason) &&
        identical(reference$Certified, observed$Certified)
      reference$ReferenceUse <- "post_failure_timeout_attribution_only"
      rows[[cursor]] <- reference
    }
  }
  out <- if (length(rows) == 0L) comparison[0, , drop = FALSE] else {
    do.call(rbind, rows)
  }
  rownames(out) <- NULL
  out
}

mfrmr_run_jml_target_positive_cones <- function(
    dry_run = TRUE, authorize = FALSE, maxit = 60L, reltol = 1e-9,
    output_dir = NULL, progress = interactive()) {
  mfrmr_target_cone_require_support()
  if (length(maxit) != 1L || is.na(maxit) || maxit < 1L ||
      maxit != as.integer(maxit)) stop(
    "`maxit` must be one positive integer.", call. = FALSE
  )
  if (length(reltol) != 1L || is.na(reltol) || !is.finite(reltol) ||
      reltol <= 0) stop("`reltol` must be finite and positive.", call. = FALSE)
  registry <- mfrmr_target_cone_registry()
  prespec <- mfrmr_target_cone_prespecification(maxit, reltol)
  capabilities <- mfrmr_target_cone_capabilities()
  runner_files <- c(
    "jml-target-positive-cone-pilot-0.2.3.R",
    "target-scale-baseline-bridge-pilot-0.2.3.R",
    "jml-solver-normalization-pilot-0.2.3.R",
    "jml-solver-qualification-pilot-0.2.3.R"
  )
  source_identity <- data.frame(
    Component = c(
      "target_cone_runner", "target_scale_generator",
      "normalization_runner", "capture_runner"
    ),
    File = runner_files,
    SHA256 = vapply(
      file.path(mfrmr_target_cone_source_dir, runner_files),
      mfrmr_gpcm_repilot_hash_file, character(1)
    ),
    stringsAsFactors = FALSE
  )
  if (isTRUE(dry_run)) return(list(
    schema = "mfrmr-jml-target-positive-cone-pilot-v1",
    registry = registry, prespecification = prespec,
    capabilities = capabilities, source_identity = source_identity,
    solver_branch_continuation_authorized = FALSE,
    production_change_authorized = FALSE,
    confirmation_authorized = FALSE
  ))
  if (!isTRUE(authorize)) stop(
    "Live target-positive-cone execution requires `authorize = TRUE`.",
    call. = FALSE
  )
  if (any(!capabilities$Available)) stop(
    "Live target-positive-cone execution lacks required capabilities: ",
    paste(capabilities$Capability[!capabilities$Available], collapse = ", "),
    call. = FALSE
  )
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) stop(
    "Live target-positive-cone execution requires one `output_dir`.",
    call. = FALSE
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  if (file.exists(output_dir) || dir.exists(output_dir)) stop(
    "`output_dir` must not already exist.", call. = FALSE
  )
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

  sink <- new.env(parent = emptyenv())
  sink$problems <- list()
  generated <- vector("list", nrow(registry))
  fits <- vector("list", nrow(registry))
  for (i in seq_len(nrow(registry))) {
    row <- registry[i, , drop = FALSE]
    if (isTRUE(progress)) message("[target-cone] ", row$ScenarioId)
    generated[[i]] <- mfrmr_target_cone_build(row)
    fits[[i]] <- mfrmr_target_cone_run_route(
      row, generated[[i]], sink, maxit, reltol
    )
  }
  fits <- do.call(rbind, fits)
  rownames(fits) <- NULL
  topology <- mfrmr_target_cone_topology_audit(fits)
  problems <- sink$problems
  problem_registry <- mfrmr_target_cone_problem_registry(problems)
  comparison <- do.call(rbind, lapply(
    problems, mfrmr_target_cone_compare_problem
  ))
  rownames(comparison) <- NULL
  reference <- mfrmr_target_cone_reference_audit(problems, comparison)

  raw_lp <- comparison[
    comparison$Formulation == "raw" & comparison$Solver == "lpSolve",
    , drop = FALSE
  ]
  normalized_lp <- comparison[
    comparison$Formulation == "l1_row_normalized" &
      comparison$Solver == "lpSolve", , drop = FALSE
  ]
  normalized_all <- comparison[
    comparison$Formulation == "l1_row_normalized", , drop = FALSE
  ]
  production_need_observed <- any(
    !raw_lp$FormulationQualified & normalized_lp$FormulationQualified
  )
  target_normalization_qualified <- nrow(normalized_all) > 0L &&
    all(normalized_all$FormulationQualified)
  timeout_instability_observed <- nrow(reference) > 0L &&
    any(!reference$OutcomeMatchesTimeoutLimited)
  recession_replay_investigation_required <-
    any(!comparison$ExpectedMatch) || any(!comparison$ProvenanceSafe) ||
    timeout_instability_observed || any(!fits$BaselineCaptureEquivalent)
  production_change_authorized <- FALSE
  solver_branch_continuation_authorized <- FALSE
  solver_dispatch_eligible <- FALSE
  confirmation_authorized <- FALSE
  completion_valid <- nrow(registry) == 6L && nrow(fits) == 6L &&
    all(topology$TopologyMatched) && all(topology$ExposureMatched) &&
    all(topology$ResponseHashesDistinct) &&
    all(fits$BaselineFitSucceeded) && all(fits$InstrumentedFitSucceeded) &&
    all(fits$CapturedProblems > 0L) && sum(fits$PositiveProblems) > 0L &&
    length(problems) == nrow(problem_registry) &&
    nrow(comparison) == 4L * length(problems) &&
    all(comparison$SafeResult) && nrow(reference) > 0L &&
    all(reference$SafeResult) &&
    !production_change_authorized &&
    !solver_branch_continuation_authorized && !solver_dispatch_eligible &&
    !confirmation_authorized
  if (!completion_valid) {
    message(
      "[target-cone-diagnostic] fits=", nrow(fits),
      "; topology=", sum(topology$TopologyMatched), "/", nrow(topology),
      "; equivalent=", sum(fits$BaselineCaptureEquivalent), "/", nrow(fits),
      "; positive_routes=", sum(fits$PositiveProblems > 0L), "/", nrow(fits),
      "; problems=", length(problems),
      "; safe_results=", sum(comparison$SafeResult), "/", nrow(comparison),
      "; provenance=", sum(comparison$ProvenanceSafe), "/", nrow(comparison),
      "; raw_lp=", sum(raw_lp$FormulationQualified), "/", nrow(raw_lp),
      "; normalized_lp=", sum(normalized_lp$FormulationQualified),
      "/", nrow(normalized_lp)
    )
    stop("Target-positive-cone evidence did not complete safely.",
         call. = FALSE)
  }

  package_identity <- mfrmr_gpcm_repilot_package_content_identity("mfrmr")
  execution_identity <- data.frame(
    Schema = "mfrmr-jml-target-positive-cone-identity-v1",
    PrespecificationSHA256 = mfrmr_gpcm_repilot_hash_object(prespec),
    RegistrySHA256 = mfrmr_gpcm_repilot_hash_object(registry),
    SourceIdentitySHA256 = mfrmr_gpcm_repilot_hash_object(source_identity),
    CapabilityManifestSHA256 = mfrmr_gpcm_repilot_hash_object(capabilities),
    TopologyAuditSHA256 = mfrmr_gpcm_repilot_hash_object(topology),
    FitAuditSHA256 = mfrmr_gpcm_repilot_hash_object(fits),
    ProblemRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(problem_registry),
    ComparisonSHA256 = mfrmr_gpcm_repilot_hash_object(comparison),
    TimeoutReferenceSHA256 = mfrmr_gpcm_repilot_hash_object(reference),
    InstalledPackageSHA256 = package_identity$PackageSHA256,
    ProductionNormalizationNeedObserved = production_need_observed,
    TargetNormalizationQualified = target_normalization_qualified,
    NativeTimeoutInstabilityObserved = timeout_instability_observed,
    RecessionReplayInvestigationRequired =
      recession_replay_investigation_required,
    ProductionChangeAuthorized = FALSE,
    SolverBranchContinuationAuthorized = FALSE,
    SolverDispatchEligible = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution_identity$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(
    execution_identity
  )
  run_summary <- data.frame(
    Schema = "mfrmr-jml-target-positive-cone-pilot-v1",
    Designs = nrow(topology), Routes = nrow(fits),
    TopologyMatchedPairs = sum(topology$TopologyMatched),
    ExposureMatchedPairs = sum(topology$ExposureMatched),
    BaselineCaptureEquivalentRoutes = sum(fits$BaselineCaptureEquivalent),
    SemanticEquivalentRoutes = sum(fits$SemanticHashMatch),
    ReadinessEquivalentRoutes = sum(fits$ReadinessMatch),
    BoundaryEquivalentRoutes = sum(fits$BoundaryMatch),
    CapturedProblems = length(problems),
    PositiveProblems = sum(problem_registry$ProductionCertified),
    NegativeProblems = sum(!problem_registry$ProductionCertified),
    ComparisonRows = nrow(comparison),
    TimeoutReferenceRows = nrow(reference),
    TimeoutReferenceOutcomeChanges = sum(
      !reference$OutcomeMatchesTimeoutLimited
    ),
    ProvenanceSafeRows = sum(comparison$ProvenanceSafe),
    SafeResultRows = sum(comparison$SafeResult),
    RawLpSolveQualified = sum(raw_lp$FormulationQualified),
    NormalizedLpSolveQualified = sum(normalized_lp$FormulationQualified),
    RawGLPKQualified = sum(
      comparison$Formulation == "raw" & comparison$Solver == "GLPK" &
        comparison$FormulationQualified
    ),
    NormalizedGLPKQualified = sum(
      comparison$Formulation == "l1_row_normalized" &
        comparison$Solver == "GLPK" & comparison$FormulationQualified
    ),
    ProductionNormalizationNeedObserved = production_need_observed,
    TargetNormalizationQualified = target_normalization_qualified,
    NativeTimeoutInstabilityObserved = timeout_instability_observed,
    RecessionReplayInvestigationRequired =
      recession_replay_investigation_required,
    ProductionChangeAuthorized = FALSE,
    SolverBranchContinuationAuthorized = FALSE,
    SolverDispatchEligible = FALSE,
    RuntimeCriterionFrozen = FALSE,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "target_positive_cone_calibration_only",
    stringsAsFactors = FALSE
  )
  out <- list(
    schema = "mfrmr-jml-target-positive-cone-pilot-v1",
    prespecification = prespec, registry = registry,
    topology_audit = topology, fit_audit = fits,
    problems = problems, problem_registry = problem_registry,
    formulation_comparison = comparison,
    timeout_reference = reference,
    capabilities = capabilities, source_identity = source_identity,
    package_identity = package_identity,
    execution_identity = execution_identity, run_summary = run_summary,
    production_normalization_need_observed = production_need_observed,
    target_normalization_qualified = target_normalization_qualified,
    native_timeout_instability_observed = timeout_instability_observed,
    recession_replay_investigation_required =
      recession_replay_investigation_required,
    production_change_authorized = FALSE,
    solver_branch_continuation_authorized = FALSE,
    solver_dispatch_eligible = FALSE, confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    `registry.csv` = registry, `topology-audit.csv` = topology,
    `fit-audit.csv` = fits, `problem-registry.csv` = problem_registry,
    `formulation-comparison.csv` = comparison,
    `timeout-reference.csv` = reference,
    `capabilities.csv` = capabilities,
    `source-identity.csv` = source_identity,
    `package-identity.csv` = package_identity,
    `execution-identity.csv` = execution_identity,
    `run-summary.csv` = run_summary
  )
  for (name in names(files)) utils::write.csv(
    files[[name]], file.path(staging, name), row.names = FALSE, na = ""
  )
  saveRDS(out, file.path(staging, "jml-target-positive-cone-pilot.rds"))
  saveRDS(problems, file.path(staging, "target-problems.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  marker <- list(
    schema = "mfrmr-jml-target-positive-cone-completion-v1",
    execution_sha256 = execution_identity$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    production_normalization_need_observed = production_need_observed,
    target_normalization_qualified = target_normalization_qualified,
    native_timeout_instability_observed = timeout_instability_observed,
    recession_replay_investigation_required =
      recession_replay_investigation_required,
    production_change_authorized = FALSE,
    solver_branch_continuation_authorized = FALSE,
    solver_dispatch_eligible = FALSE,
    confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) stop(
    "Completed target-positive-cone evidence could not be promoted.",
    call. = FALSE
  )
  promoted <- TRUE
  invisible(out)
}
