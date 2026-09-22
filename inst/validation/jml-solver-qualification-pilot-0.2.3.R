mfrmr_solver_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-solver-qualification-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path(
      "inst", "validation", "jml-solver-qualification-pilot-0.2.3.R"
    ),
    "jml-solver-qualification-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else dirname(normalizePath(
    path, winslash = "/", mustWork = TRUE
  ))
})

mfrmr_solver_or <- function(x, replacement) {
  if (is.null(x)) replacement else x
}

mfrmr_solver_require_support <- function() {
  target_env <- environment(mfrmr_solver_require_support)
  required <- c(
    "mfrmr_jml_lp_require_support", "mfrmr_jml_lp_independent_target",
    "mfrmr_jml_lp_result_parity", "mfrmr_jml_phase_registry",
    "mfrmr_jml_profile_cells", "mfrmr_jml_profile_build",
    "mfrmr_jml_phase_run_route", "mfrmr_jml_component_compare_baseline",
    "mfrmr_jml_lp_model_control_registry",
    "mfrmr_jml_lp_build_model_control", "mfrmr_target_bridge_readiness",
    "mfrmr_target_scale_artifact_inventory",
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_package_content_identity"
  )
  if (!all(vapply(
    required, exists, logical(1), envir = target_env,
    mode = "function", inherits = TRUE
  ))) {
    candidates <- c(
      if (!is.na(mfrmr_solver_source_dir)) file.path(
        mfrmr_solver_source_dir, "jml-lp-attribution-pilot-0.2.3.R"
      ) else character(0),
      file.path(
        "inst", "validation", "jml-lp-attribution-pilot-0.2.3.R"
      ),
      "jml-lp-attribution-pilot-0.2.3.R"
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("Cannot locate Draft.56 LP-attribution support.", call. = FALSE)
    }
    sys.source(path, envir = target_env)
    mfrmr_jml_lp_require_support()
  }
  if (!all(vapply(
    required, exists, logical(1), envir = target_env,
    mode = "function", inherits = TRUE
  ))) {
    stop("Solver-qualification support did not load completely.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_solver_capabilities <- function() {
  mfrmr_solver_require_support()
  packages <- c(
    "mfrmr", "Matrix", "digest", "lpSolve", "slam", "Rglpk", "ps"
  )
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
      "production_lp", "independent_sparse_triplet", "candidate_glpk",
      "isolated_process_peak_memory"
    ),
    RequiredForLivePilot = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_solver_validate_evidence <- function(evidence_dir) {
  mfrmr_solver_require_support()
  evidence_dir <- normalizePath(
    evidence_dir, winslash = "/", mustWork = TRUE
  )
  marker_path <- file.path(evidence_dir, "run-complete.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(e) e)
  if (inherits(marker, "error") || !identical(
    marker$schema, "mfrmr-jml-lp-attribution-completion-v1"
  )) {
    stop("Draft.56 evidence marker is invalid.", call. = FALSE)
  }
  artifacts <- as.data.frame(marker$artifacts, stringsAsFactors = FALSE)
  valid <- nrow(artifacts) > 0L && all(vapply(
    seq_len(nrow(artifacts)), function(i) {
      path <- file.path(evidence_dir, artifacts$File[i])
      file.exists(path) &&
        identical(unname(file.info(path)$size),
                  as.numeric(artifacts$Bytes[i])) &&
        identical(mfrmr_gpcm_repilot_hash_file(path), artifacts$SHA256[i])
    }, logical(1)
  )) && identical(
    mfrmr_gpcm_repilot_hash_object(artifacts),
    marker$artifact_inventory_sha256
  )
  if (!isTRUE(valid) ||
      isTRUE(marker$independent_solver_results_affect_fit) ||
      isTRUE(marker$confirmation_authorized)) {
    stop("Draft.56 evidence inventory or decision boundary is invalid.",
         call. = FALSE)
  }
  list(
    directory = evidence_dir, marker = marker,
    marker_sha256 = mfrmr_gpcm_repilot_hash_file(marker_path),
    target_ledger = utils::read.csv(
      file.path(evidence_dir, "independent-parity.csv"),
      stringsAsFactors = FALSE, check.names = FALSE
    ),
    fixed_results = utils::read.csv(
      file.path(evidence_dir, "run-results.csv"),
      stringsAsFactors = FALSE, check.names = FALSE
    ),
    model_summary = utils::read.csv(
      file.path(evidence_dir, "model-control-summary.csv"),
      stringsAsFactors = FALSE, check.names = FALSE
    )
  )
}

mfrmr_solver_base_sha256 <- function(lp_base) {
  mfrmr_gpcm_repilot_hash_object(list(
    schema = "mfrmr-jml-lp-base-identity-v1",
    representation = lp_base$representation,
    contrast_dim = dim(lp_base$contrast_design),
    contrast_p = lp_base$contrast_design@p,
    contrast_i = lp_base$contrast_design@i,
    contrast_x = lp_base$contrast_design@x,
    direction = lp_base$constraint_direction,
    rhs = lp_base$constraint_rhs
  ))
}

mfrmr_solver_problem_sha256 <- function(lp_base, target,
                                        objective_tolerance,
                                        certificate_tolerance) {
  mfrmr_gpcm_repilot_hash_object(list(
    schema = "mfrmr-jml-solver-problem-v1",
    base_sha256 = mfrmr_solver_base_sha256(lp_base),
    target = as.numeric(target),
    objective_tolerance = as.numeric(objective_tolerance),
    certificate_tolerance = as.numeric(certificate_tolerance)
  ))
}

mfrmr_solver_empty_capture <- function() {
  data.frame(
    ProblemId = integer(0), ScenarioId = character(0), Model = character(0),
    Scope = character(0), BaseSHA256 = character(0),
    ProblemSHA256 = character(0), Parameters = integer(0),
    Constraints = integer(0), StoredNonzeros = double(0),
    ObjectiveTolerance = double(0), CertificateTolerance = double(0),
    ProductionEvaluated = logical(0), ProductionCertified = logical(0),
    ProductionReason = character(0), ProductionCapacity = double(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_solver_capture_start <- function(sink, scenario_id, model) {
  namespace <- asNamespace("mfrmr")
  originals <- list(
    structural = get(
      "audit_mfrm_jml_structural_recession", namespace, inherits = FALSE
    ),
    joint = get(
      "audit_mfrm_jml_joint_recession", namespace, inherits = FALSE
    ),
    target = get(
      "mfrmr_jml_recession_target_lp", namespace, inherits = FALSE
    )
  )
  scope <- "outside"
  rows <- list()
  stopped <- FALSE
  scope_wrapper <- function(name, original) {
    force(name); force(original)
    function(...) {
      previous <- scope
      scope <<- name
      on.exit(scope <<- previous, add = TRUE)
      original(...)
    }
  }
  target_wrapper <- function(lp_base, target,
                             objective_tolerance = 1e-7,
                             certificate_tolerance = 1e-7,
                             timeout = 5L) {
    production <- originals$target(
      lp_base = lp_base, target = target,
      objective_tolerance = objective_tolerance,
      certificate_tolerance = certificate_tolerance, timeout = timeout
    )
    id <- length(sink$problems) + 1L
    base_sha <- mfrmr_solver_base_sha256(lp_base)
    problem_sha <- mfrmr_solver_problem_sha256(
      lp_base, target, objective_tolerance, certificate_tolerance
    )
    problem <- list(
      schema = "mfrmr-jml-solver-problem-v1",
      ProblemId = id, ScenarioId = as.character(scenario_id),
      Model = as.character(model), Scope = as.character(scope),
      BaseSHA256 = base_sha, ProblemSHA256 = problem_sha,
      lp_base = lp_base, target = as.numeric(target),
      objective_tolerance = as.numeric(objective_tolerance),
      certificate_tolerance = as.numeric(certificate_tolerance),
      timeout = as.integer(timeout), production = production
    )
    sink$problems[[id]] <- problem
    rows[[length(rows) + 1L]] <<- data.frame(
      ProblemId = id, ScenarioId = as.character(scenario_id),
      Model = as.character(model), Scope = as.character(scope),
      BaseSHA256 = base_sha, ProblemSHA256 = problem_sha,
      Parameters = lp_base$n_parameters,
      Constraints = lp_base$n_constraints,
      StoredNonzeros = as.double(lp_base$stored_constraint_nonzeros),
      ObjectiveTolerance = as.numeric(objective_tolerance),
      CertificateTolerance = as.numeric(certificate_tolerance),
      ProductionEvaluated = isTRUE(production$evaluated),
      ProductionCertified = isTRUE(production$certified),
      ProductionReason = as.character(production$reason),
      ProductionCapacity = as.numeric(production$target_capacity),
      stringsAsFactors = FALSE
    )
    production
  }
  assignInNamespace(
    "audit_mfrm_jml_structural_recession",
    scope_wrapper("structural", originals$structural), ns = "mfrmr"
  )
  assignInNamespace(
    "audit_mfrm_jml_joint_recession",
    scope_wrapper("joint", originals$joint), ns = "mfrmr"
  )
  assignInNamespace(
    "mfrmr_jml_recession_target_lp", target_wrapper, ns = "mfrmr"
  )
  stop_capture <- function() {
    if (stopped) return(result)
    assignInNamespace(
      "mfrmr_jml_recession_target_lp", originals$target, ns = "mfrmr"
    )
    assignInNamespace(
      "audit_mfrm_jml_joint_recession", originals$joint, ns = "mfrmr"
    )
    assignInNamespace(
      "audit_mfrm_jml_structural_recession", originals$structural,
      ns = "mfrmr"
    )
    stopped <<- TRUE
    result <<- if (length(rows) == 0L) {
      mfrmr_solver_empty_capture()
    } else {
      value <- do.call(rbind, rows)
      rownames(value) <- NULL
      value
    }
    result
  }
  list(stop = stop_capture)
}

mfrmr_solver_acquire <- function(evidence, maxit = 60L,
                                 quad_points = 7L, reltol = 1e-9,
                                 progress = interactive()) {
  mfrmr_solver_require_support()
  sink <- new.env(parent = emptyenv())
  sink$problems <- list()
  registry <- mfrmr_jml_phase_registry()
  fixed_registry <- registry[registry$Method == "JML", , drop = FALSE]
  cells <- mfrmr_jml_profile_cells()
  fixed_results <- vector("list", nrow(fixed_registry))
  cursor <- 0L
  for (cell_id in unique(fixed_registry$DataCellId)) {
    cell <- cells[match(cell_id, cells$DataCellId), , drop = FALSE]
    generated <- mfrmr_jml_profile_build(cell)
    routes <- fixed_registry[
      fixed_registry$DataCellId == cell_id, , drop = FALSE
    ]
    for (j in seq_len(nrow(routes))) {
      cursor <- cursor + 1L
      row <- routes[j, , drop = FALSE]
      if (isTRUE(progress)) message("[acquire-fixed] ", row$ScenarioId)
      route <- mfrmr_jml_phase_run_route(
        row, generated, maxit = maxit, quad_points = quad_points,
        reltol = reltol,
        component_profiler = function() mfrmr_solver_capture_start(
          sink, row$ScenarioId, "PCM"
        )
      )
      fixed_results[[cursor]] <- route$result
    }
  }
  fixed_results <- do.call(rbind, fixed_results)
  fixed_comparison <- mfrmr_jml_component_compare_baseline(
    fixed_results, evidence$fixed_results
  )

  model_registry <- mfrmr_jml_lp_model_control_registry()
  model_rows <- vector("list", nrow(model_registry))
  for (i in seq_len(nrow(model_registry))) {
    row <- model_registry[i, , drop = FALSE]
    if (isTRUE(progress)) message("[acquire-model] ", row$ScenarioId)
    built <- mfrmr_jml_lp_build_model_control(row)
    session <- mfrmr_solver_capture_start(sink, row$ScenarioId, row$Model)
    stopped <- FALSE
    fit <- tryCatch(
      suppressWarnings(do.call(
        mfrmr_gpcm_stress_fun("fit_mfrm"), built$args
      )),
      error = function(e) e
    )
    capture <- session$stop()
    stopped <- TRUE
    expected <- evidence$model_summary[
      evidence$model_summary$ScenarioId == row$ScenarioId, , drop = FALSE
    ]
    ready <- if (inherits(fit, "error")) list() else {
      mfrmr_target_bridge_readiness(fit)
    }
    boundary <- if (inherits(fit, "error")) list() else {
      fit$config$boundary_audit
    }
    state <- function(name) {
      value <- mfrmr_solver_or(boundary[[name]], list())
      as.character(mfrmr_solver_or(value$state, NA_character_))
    }
    model_rows[[i]] <- data.frame(
      ScenarioId = row$ScenarioId, Model = row$Model,
      FitSucceeded = !inherits(fit, "error"),
      Error = if (inherits(fit, "error")) conditionMessage(fit) else NA_character_,
      CapturedProblems = nrow(capture),
      FitReadiness = as.character(mfrmr_solver_or(
        ready$FitReadiness, NA_character_
      )),
      StructuralState = state("structural_additive"),
      JointState = state("joint_additive"),
      ExpectedStructuralState = as.character(
        expected$InstrumentedStructuralState
      ),
      ExpectedJointState = as.character(expected$InstrumentedJointState),
      StateMatch = nrow(expected) == 1L &&
        identical(state("structural_additive"), as.character(
          expected$InstrumentedStructuralState
        )) && identical(state("joint_additive"), as.character(
          expected$InstrumentedJointState
        )),
      stringsAsFactors = FALSE
    )
  }
  model_results <- do.call(rbind, model_rows)
  problems <- sink$problems
  problem_registry <- do.call(rbind, lapply(problems, function(problem) {
    production <- problem$production
    data.frame(
      ProblemId = problem$ProblemId,
      ScenarioId = problem$ScenarioId, Model = problem$Model,
      Scope = problem$Scope, BaseSHA256 = problem$BaseSHA256,
      ProblemSHA256 = problem$ProblemSHA256,
      Parameters = problem$lp_base$n_parameters,
      Constraints = problem$lp_base$n_constraints,
      StoredNonzeros = as.double(
        problem$lp_base$stored_constraint_nonzeros
      ),
      ObjectiveNonzeros = sum(problem$target != 0),
      ObjectiveTolerance = problem$objective_tolerance,
      CertificateTolerance = problem$certificate_tolerance,
      ProductionEvaluated = isTRUE(production$evaluated),
      ProductionCertified = isTRUE(production$certified),
      ProductionReason = as.character(production$reason),
      ProductionCapacity = as.numeric(production$target_capacity),
      stringsAsFactors = FALSE
    )
  }))
  rownames(problem_registry) <- NULL
  expected <- evidence$target_ledger
  ledger_match <- nrow(problem_registry) == nrow(expected) &&
    identical(problem_registry$ScenarioId, as.character(expected$ScenarioId)) &&
    identical(problem_registry$Scope, as.character(expected$Scope)) &&
    identical(problem_registry$BaseSHA256, as.character(expected$BaseSHA256)) &&
    identical(problem_registry$Parameters, as.integer(expected$Parameters)) &&
    identical(problem_registry$Constraints, as.integer(expected$Constraints)) &&
    identical(
      problem_registry$ProductionReason,
      as.character(expected$ProductionReason)
    ) && identical(
      problem_registry$ProductionCertified,
      as.logical(expected$ProductionCertified)
    )
  list(
    problems = problems, registry = problem_registry,
    fixed_results = fixed_results,
    fixed_comparison = fixed_comparison,
    model_results = model_results,
    ledger_match = isTRUE(ledger_match)
  )
}

mfrmr_solver_run_target <- function(problem, solver) {
  solver <- match.arg(solver, c("lpSolve", "GLPK"))
  if (identical(solver, "lpSolve")) {
    target_fun <- get(
      "mfrmr_jml_recession_target_lp", asNamespace("mfrmr"),
      inherits = FALSE
    )
    return(target_fun(
      lp_base = problem$lp_base, target = problem$target,
      objective_tolerance = problem$objective_tolerance,
      certificate_tolerance = problem$certificate_tolerance,
      timeout = problem$timeout
    ))
  }
  mfrmr_jml_lp_independent_target(
    lp_base = problem$lp_base, target = problem$target,
    objective_tolerance = problem$objective_tolerance,
    certificate_tolerance = problem$certificate_tolerance,
    timeout = problem$timeout
  )
}

mfrmr_solver_compact_result <- function(problem, value) {
  upper <- sum(abs(as.numeric(problem$target)))
  capacity <- as.numeric(mfrmr_solver_or(value$target_capacity, NA_real_))
  bounded <- !isTRUE(value$evaluated) ||
    (is.finite(capacity) && capacity >= -1e-8 &&
       capacity <= upper + 1e-7 * (1 + upper))
  certificate <- !isTRUE(value$certified) || (
    is.finite(value$target_change) &&
      value$target_change > problem$objective_tolerance &&
      is.finite(value$minimum_margin) &&
      value$minimum_margin >= -problem$certificate_tolerance &&
      is.finite(value$positive_margin) &&
      value$positive_margin > problem$objective_tolerance &&
      is.finite(value$strict_rows) && value$strict_rows > 0
  )
  data.frame(
    Evaluated = isTRUE(value$evaluated),
    Certified = isTRUE(value$certified),
    Reason = as.character(mfrmr_solver_or(value$reason, NA_character_)),
    SolverStatus = as.integer(mfrmr_solver_or(
      value$solver_status, NA_integer_
    )),
    TargetCapacity = capacity,
    TargetChange = as.numeric(mfrmr_solver_or(
      value$target_change, NA_real_
    )),
    MinimumMargin = as.numeric(mfrmr_solver_or(
      value$minimum_margin, NA_real_
    )),
    PositiveMargin = as.numeric(mfrmr_solver_or(
      value$positive_margin, NA_real_
    )),
    StrictRows = as.integer(mfrmr_solver_or(
      value$strict_rows, NA_integer_
    )),
    CapacityUpperBound = upper,
    CapacityBoundValid = bounded,
    CertificateValid = certificate,
    SafeResult = isTRUE(bounded) && isTRUE(certificate),
    stringsAsFactors = FALSE
  )
}

mfrmr_solver_timing <- function(problems, repetitions = 7L,
                                progress = interactive()) {
  repetitions <- as.integer(repetitions)
  rows <- vector("list", length(problems) * (repetitions + 1L) * 2L)
  cursor <- 0L
  for (i in seq_along(problems)) {
    problem <- problems[[i]]
    if (isTRUE(progress)) message(
      "[timing] ", i, "/", length(problems), " ", problem$ScenarioId,
      " / ", problem$Scope
    )
    for (replicate in 0:repetitions) {
      first <- if ((i + replicate) %% 2L == 0L) "lpSolve" else "GLPK"
      order <- c(first, setdiff(c("lpSolve", "GLPK"), first))
      for (position in seq_along(order)) {
        solver <- order[position]
        started <- unname(proc.time()[["elapsed"]])
        value <- tryCatch(
          mfrmr_solver_run_target(problem, solver),
          error = function(e) e
        )
        elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
        cursor <- cursor + 1L
        if (inherits(value, "error")) {
          compact <- mfrmr_solver_compact_result(problem, list(
            evaluated = FALSE, certified = FALSE,
            reason = paste0("solver_error: ", conditionMessage(value)),
            solver_status = NA_integer_, target_capacity = NA_real_
          ))
        } else compact <- mfrmr_solver_compact_result(problem, value)
        expected_match <- !inherits(value, "error") &&
          mfrmr_jml_lp_result_parity(problem$production, value)
        rows[[cursor]] <- cbind(data.frame(
          ProblemId = problem$ProblemId,
          ProblemSHA256 = problem$ProblemSHA256,
          ScenarioId = problem$ScenarioId, Model = problem$Model,
          Scope = problem$Scope, Replicate = replicate,
          Included = replicate > 0L, Solver = solver,
          OrderPosition = position, FirstSolver = first,
          ElapsedSeconds = elapsed, ExpectedMatch = expected_match,
          stringsAsFactors = FALSE
        ), compact)
      }
    }
  }
  out <- do.call(rbind, rows[seq_len(cursor)])
  rownames(out) <- NULL
  out
}

mfrmr_solver_pair_audit <- function(timing) {
  included <- timing[timing$Included, , drop = FALSE]
  keys <- unique(included[c("ProblemId", "Replicate")])
  rows <- lapply(seq_len(nrow(keys)), function(i) {
    x <- included[
      included$ProblemId == keys$ProblemId[i] &
        included$Replicate == keys$Replicate[i], , drop = FALSE
    ]
    lp <- x[x$Solver == "lpSolve", , drop = FALSE]
    glpk <- x[x$Solver == "GLPK", , drop = FALSE]
    capacity_close <- nrow(lp) == 1L && nrow(glpk) == 1L &&
      if (is.finite(lp$TargetCapacity) && is.finite(glpk$TargetCapacity)) {
        abs(lp$TargetCapacity - glpk$TargetCapacity) <=
          1e-7 * (1 + abs(lp$TargetCapacity))
      } else identical(is.na(lp$TargetCapacity), is.na(glpk$TargetCapacity))
    data.frame(
      ProblemId = keys$ProblemId[i], Replicate = keys$Replicate[i],
      ScenarioId = lp$ScenarioId, Model = lp$Model, Scope = lp$Scope,
      ClassificationMatch = nrow(lp) == 1L && nrow(glpk) == 1L &&
        identical(lp$Evaluated, glpk$Evaluated) &&
        identical(lp$Certified, glpk$Certified) &&
        identical(lp$Reason, glpk$Reason),
      CapacityMatch = capacity_close,
      LpSolveSeconds = lp$ElapsedSeconds,
      GlpkSeconds = glpk$ElapsedSeconds,
      GlpkToLpSolveRatio = glpk$ElapsedSeconds /
        max(lp$ElapsedSeconds, .Machine$double.eps),
      PairValid = nrow(lp) == 1L && nrow(glpk) == 1L &&
        isTRUE(lp$SafeResult) && isTRUE(glpk$SafeResult) &&
        isTRUE(lp$ExpectedMatch) && isTRUE(glpk$ExpectedMatch) &&
        isTRUE(capacity_close) && identical(lp$Evaluated, glpk$Evaluated) &&
        identical(lp$Certified, glpk$Certified) &&
        identical(lp$Reason, glpk$Reason),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_solver_property_registry <- function() {
  data.frame(
    Transformation = c(
      "identity", "row_reverse", "column_rotate", "row_scale_1e-3_1e3",
      "target_scale_1e-3", "target_scale_1e3",
      "tolerance_1e-9", "tolerance_1e-5"
    ),
    TargetScale = c(1, 1, 1, 1, 1e-3, 1e3, 1, 1),
    ObjectiveTolerance = c(1e-7, 1e-7, 1e-7, 1e-7, 1e-7, 1e-7, 1e-9, 1e-5),
    CertificateTolerance = c(1e-7, 1e-7, 1e-7, 1e-7, 1e-7, 1e-7, 1e-9, 1e-5),
    EvidenceUse = "generated_metamorphic_solver_calibration_only",
    stringsAsFactors = FALSE
  )
}

mfrmr_solver_transform_problem <- function(problem, transformation_row) {
  contrast <- problem$lp_base$contrast_design
  target <- problem$target
  transformation <- as.character(transformation_row$Transformation)
  if (identical(transformation, "row_reverse") && nrow(contrast) > 1L) {
    contrast <- contrast[rev(seq_len(nrow(contrast))), , drop = FALSE]
  }
  if (identical(transformation, "column_rotate") && ncol(contrast) > 1L) {
    permutation <- c(seq.int(2L, ncol(contrast)), 1L)
    contrast <- contrast[, permutation, drop = FALSE]
    target <- target[permutation]
  }
  if (identical(transformation, "row_scale_1e-3_1e3")) {
    factors <- rep(c(1e-3, 1, 1e3), length.out = nrow(contrast))
    contrast <- Matrix::Diagonal(x = factors) %*% contrast
  }
  target <- target * as.numeric(transformation_row$TargetScale)
  base_fun <- get(
    "mfrmr_jml_recession_lp_base", asNamespace("mfrmr"), inherits = FALSE
  )
  transformed <- problem
  transformed$lp_base <- base_fun(
    contrast, representation = problem$lp_base$representation
  )
  transformed$target <- as.numeric(target)
  transformed$objective_tolerance <- as.numeric(
    transformation_row$ObjectiveTolerance
  )
  transformed$certificate_tolerance <- as.numeric(
    transformation_row$CertificateTolerance
  )
  transformed$ProblemSHA256 <- mfrmr_solver_problem_sha256(
    transformed$lp_base, transformed$target,
    transformed$objective_tolerance,
    transformed$certificate_tolerance
  )
  transformed
}

mfrmr_solver_property_controls <- function(problems,
                                           progress = interactive()) {
  registry <- do.call(rbind, lapply(problems, function(problem) data.frame(
    ProblemId = problem$ProblemId, Model = problem$Model,
    Reason = problem$production$reason,
    stringsAsFactors = FALSE
  )))
  selected <- unlist(lapply(c("PCM", "RSM", "GPCM"), function(model) {
    unlist(lapply(c(
      "no_target_recession_direction",
      "certified_additive_recession_direction"
    ), function(reason) {
      hit <- registry$ProblemId[
        registry$Model == model & registry$Reason == reason
      ]
      if (length(hit) == 0L) integer(0) else hit[1L]
    }), use.names = FALSE)
  }), use.names = FALSE)
  if (length(selected) != 6L) {
    stop("The six prespecified cross-model property controls are unavailable.",
         call. = FALSE)
  }
  transformations <- mfrmr_solver_property_registry()
  rows <- list(); cursor <- 0L
  for (problem_id in selected) {
    reference <- problems[[problem_id]]
    for (j in seq_len(nrow(transformations))) {
      transformed <- mfrmr_solver_transform_problem(
        reference, transformations[j, , drop = FALSE]
      )
      values <- list()
      for (solver in c("lpSolve", "GLPK")) {
        if (isTRUE(progress)) message(
          "[property] ", reference$Model, " / ",
          reference$production$reason, " / ",
          transformations$Transformation[j], " / ", solver
        )
        value <- tryCatch(
          mfrmr_solver_run_target(transformed, solver),
          error = function(e) e
        )
        values[[solver]] <- value
        cursor <- cursor + 1L
        compact <- if (inherits(value, "error")) {
          mfrmr_solver_compact_result(transformed, list(
            evaluated = FALSE, certified = FALSE,
            reason = paste0("solver_error: ", conditionMessage(value)),
            solver_status = NA_integer_, target_capacity = NA_real_
          ))
        } else mfrmr_solver_compact_result(transformed, value)
        expected_capacity <- as.numeric(reference$production$target_capacity) *
          transformations$TargetScale[j]
        expected_capacity_match <- is.finite(compact$TargetCapacity) &&
          is.finite(expected_capacity) &&
          abs(compact$TargetCapacity - expected_capacity) <=
            1e-6 * (1 + abs(expected_capacity))
        cursor_row <- data.frame(
          SourceProblemId = problem_id,
          SourceProblemSHA256 = reference$ProblemSHA256,
          TransformedProblemSHA256 = transformed$ProblemSHA256,
          ScenarioId = reference$ScenarioId, Model = reference$Model,
          Scope = reference$Scope,
          SourceReason = reference$production$reason,
          Transformation = transformations$Transformation[j],
          Solver = solver,
          ExpectedCapacity = expected_capacity,
          ExpectedClassificationMatch = !inherits(value, "error") &&
            identical(isTRUE(value$evaluated),
                      isTRUE(reference$production$evaluated)) &&
            identical(isTRUE(value$certified),
                      isTRUE(reference$production$certified)) &&
            identical(as.character(value$reason),
                      as.character(reference$production$reason)),
          ExpectedCapacityMatch = expected_capacity_match,
          stringsAsFactors = FALSE
        )
        rows[[cursor]] <- cbind(cursor_row, compact)
      }
      pair_valid <- !inherits(values$lpSolve, "error") &&
        !inherits(values$GLPK, "error") &&
        mfrmr_jml_lp_result_parity(values$lpSolve, values$GLPK)
      rows[[cursor - 1L]]$CrossSolverMatch <- pair_valid
      rows[[cursor]]$CrossSolverMatch <- pair_valid
    }
  }
  out <- do.call(rbind, rows)
  out$PropertyValid <- out$SafeResult &
    out$ExpectedClassificationMatch & out$ExpectedCapacityMatch &
    out$CrossSolverMatch
  rownames(out) <- NULL
  out
}

mfrmr_solver_status_normalize <- function(solver, case, value) {
  if (inherits(value, "error")) {
    return(list(
      State = "numeric_input_error", Accepted = FALSE,
      RawStatus = NA_integer_, Objective = NA_real_, SolutionFinite = FALSE,
      Detail = conditionMessage(value)
    ))
  }
  status <- as.integer(value$status)
  objective <- if (identical(solver, "lpSolve")) {
    as.numeric(value$objval)
  } else as.numeric(value$optimum)
  solution_finite <- all(is.finite(as.numeric(value$solution)))
  if (status != 0L) {
    state <- if (identical(solver, "lpSolve")) {
      switch(
        as.character(status), `2` = "infeasible", `3` = "unbounded",
        `5` = "numeric_failure", `6` = "aborted", `7` = "timeout",
        "other_nonoptimal"
      )
    } else "undifferentiated_nonoptimal"
    return(list(
      State = state, Accepted = FALSE, RawStatus = status,
      Objective = objective, SolutionFinite = solution_finite,
      Detail = "nonzero_raw_status"
    ))
  }
  if (!is.finite(objective) || !solution_finite) {
    return(list(
      State = "invalid_numeric_result", Accepted = FALSE,
      RawStatus = status, Objective = objective,
      SolutionFinite = solution_finite,
      Detail = "status_zero_with_nonfinite_result"
    ))
  }
  if (!identical(case, "optimal")) {
    return(list(
      State = "unverified_success_without_problem_certificate",
      Accepted = FALSE, RawStatus = status, Objective = objective,
      SolutionFinite = solution_finite,
      Detail = "status_zero_is_insufficient_without_bounded_primal_certificate"
    ))
  }
  list(
    State = "optimal", Accepted = TRUE, RawStatus = status,
    Objective = objective, SolutionFinite = solution_finite,
    Detail = "bounded_fixture_primal_and_objective_verified"
  )
}

mfrmr_solver_status_raw <- function(solver, case) {
  if (identical(solver, "lpSolve")) {
    if (identical(case, "optimal")) {
      return(lpSolve::lp("max", 1, matrix(1, 1L, 1L), "<=", 1))
    }
    if (identical(case, "infeasible")) {
      return(lpSolve::lp(
        "max", 1, matrix(c(1, 1), 2L, 1L),
        c("<=", ">="), c(0, 1)
      ))
    }
    if (identical(case, "unbounded")) {
      return(lpSolve::lp("max", 1, matrix(0, 1L, 1L), "<=", 0))
    }
    return(lpSolve::lp(
      "max", NA_real_, matrix(1, 1L, 1L), "<=", 1
    ))
  }
  if (identical(case, "optimal")) {
    mat <- matrix(1, 1L, 1L); dir <- "<="; rhs <- 1; obj <- 1
  } else if (identical(case, "infeasible")) {
    mat <- matrix(c(1, 1), 2L, 1L)
    dir <- c("<=", ">="); rhs <- c(0, 1); obj <- 1
  } else if (identical(case, "unbounded")) {
    mat <- matrix(0, 1L, 1L); dir <- "<="; rhs <- 0; obj <- 1
  } else {
    mat <- matrix(1, 1L, 1L); dir <- "<="; rhs <- 1; obj <- NA_real_
  }
  Rglpk::Rglpk_solve_LP(obj, mat, dir, rhs, max = TRUE)
}

mfrmr_solver_status_controls <- function() {
  rows <- list(); cursor <- 0L
  for (solver in c("lpSolve", "GLPK")) {
    for (case in c("optimal", "infeasible", "unbounded", "numeric_error")) {
      value <- tryCatch(
        mfrmr_solver_status_raw(solver, case), error = function(e) e
      )
      normalized <- mfrmr_solver_status_normalize(solver, case, value)
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        Solver = solver, Case = case, ObservationType = "actual_solve",
        RawStatus = normalized$RawStatus,
        NormalizedState = normalized$State,
        Objective = normalized$Objective,
        SolutionFinite = normalized$SolutionFinite,
        AcceptedForMfrmr = normalized$Accepted,
        SafeAcceptance = identical(case, "optimal") == normalized$Accepted,
        FailureClassSpecific = normalized$State %in% c(
          "infeasible", "unbounded", "numeric_failure", "timeout"
        ),
        Detail = normalized$Detail,
        stringsAsFactors = FALSE
      )
    }
  }
  forced <- data.frame(
    Solver = c("lpSolve", "GLPK", "lpSolve", "GLPK"),
    Case = c("timeout", "timeout", "numeric_failure", "numeric_failure"),
    ObservationType = "injected_mapper_only",
    RawStatus = c(7L, 1L, 5L, 1L),
    NormalizedState = c(
      "timeout", "undifferentiated_nonoptimal",
      "numeric_failure", "undifferentiated_nonoptimal"
    ),
    Objective = NA_real_, SolutionFinite = FALSE,
    AcceptedForMfrmr = FALSE, SafeAcceptance = TRUE,
    FailureClassSpecific = c(TRUE, FALSE, TRUE, FALSE),
    Detail = "mapping_only_not_observed_timeout_or_numeric_solve",
    stringsAsFactors = FALSE
  )
  out <- rbind(do.call(rbind, rows), forced)
  out$StatusControlValid <- out$SafeAcceptance & !out$AcceptedForMfrmr |
    (out$Case == "optimal" & out$AcceptedForMfrmr)
  rownames(out) <- NULL
  out
}

mfrmr_solver_isolated_memory <- function(problems, staging,
                                         repetitions = 3L,
                                         progress = interactive()) {
  registry <- do.call(rbind, lapply(problems, function(problem) data.frame(
    ProblemId = problem$ProblemId, Model = problem$Model,
    Constraints = problem$lp_base$n_constraints,
    stringsAsFactors = FALSE
  )))
  selected <- unlist(lapply(c("PCM", "RSM", "GPCM"), function(model) {
    rows <- registry[registry$Model == model, , drop = FALSE]
    rows$ProblemId[which.max(rows$Constraints)]
  }), use.names = FALSE)
  worker <- file.path(
    mfrmr_solver_source_dir, "jml-solver-qualification-worker-0.2.3.R"
  )
  runner <- file.path(
    mfrmr_solver_source_dir, "jml-solver-qualification-pilot-0.2.3.R"
  )
  rscript <- file.path(R.home("bin"), "Rscript.exe")
  if (!file.exists(rscript)) rscript <- file.path(R.home("bin"), "Rscript")
  mfrmr_lib <- dirname(system.file(package = "mfrmr"))
  rows <- list(); cursor <- 0L
  for (problem_id in selected) {
    problem <- problems[[problem_id]]
    for (solver in c("lpSolve", "GLPK")) {
      cursor <- cursor + 1L
      if (isTRUE(progress)) message(
        "[isolated-memory] ", problem$Model, " / ", solver
      )
      job_path <- file.path(staging, paste0("worker-job-", cursor, ".rds"))
      output_path <- file.path(
        staging, paste0("worker-output-", cursor, ".rds")
      )
      saveRDS(list(
        lib_paths = .libPaths(), mfrmr_lib = mfrmr_lib,
        runner_path = runner, problem = problem, solver = solver,
        repetitions = as.integer(repetitions), output_path = output_path
      ), job_path)
      log_path <- file.path(staging, paste0("worker-log-", cursor, ".txt"))
      status <- system2(
        rscript, args = c(shQuote(worker), shQuote(job_path)),
        stdout = log_path, stderr = log_path, wait = TRUE
      )
      value <- if (identical(status, 0L) && file.exists(output_path)) {
        tryCatch(readRDS(output_path), error = function(e) e)
      } else structure(list(message = paste(
        readLines(log_path, warn = FALSE), collapse = " | "
      )), class = c("worker_error", "error", "condition"))
      valid <- !inherits(value, "error") &&
        identical(value$schema, "mfrmr-jml-solver-isolated-worker-v1") &&
        all(value$repetitions$SafeResult) &&
        all(is.finite(c(value$initial, value$final)))
      rows[[cursor]] <- data.frame(
        ProblemId = problem_id, ProblemSHA256 = problem$ProblemSHA256,
        ScenarioId = problem$ScenarioId, Model = problem$Model,
        Scope = problem$Scope, Solver = solver,
        Repetitions = as.integer(repetitions), ExitStatus = as.integer(status),
        InitialPeakWorkingSetMB = if (valid) {
          value$initial[["PeakWorkingSetMB"]]
        } else NA_real_,
        InitialWorkingSetMB = if (valid) {
          value$initial[["WorkingSetMB"]]
        } else NA_real_,
        FinalPeakWorkingSetMB = if (valid) {
          value$final[["PeakWorkingSetMB"]]
        } else NA_real_,
        FinalWorkingSetMB = if (valid) {
          value$final[["WorkingSetMB"]]
        } else NA_real_,
        PeakIncreaseAboveInitialPeakMB = if (valid) {
          value$peak_increase_above_initial_peak_mb
        } else NA_real_,
        MedianElapsedSeconds = if (valid) {
          stats::median(value$repetitions$ElapsedSeconds)
        } else NA_real_,
        Valid = valid,
        Error = if (valid) NA_character_ else if (inherits(value, "error")) {
          conditionMessage(value)
        } else "invalid_worker_result",
        MemoryInterpretation = paste(
          "process_lifetime_peak_after_runtime_load;",
          "difference_from_initial_peak_is_not_solver-only_allocation"
        ),
        stringsAsFactors = FALSE
      )
      unlink(c(job_path, output_path, log_path), force = TRUE)
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_solver_prespecification <- function(repetitions = 7L,
                                          memory_repetitions = 3L) {
  list(
    schema = "mfrmr-jml-solver-qualification-prespec-v1",
    solvers = c("lpSolve", "GLPK"),
    timing_repetitions = as.integer(repetitions),
    timing_order = "balanced_by_problem_and_replicate_parity",
    warmups_per_problem_solver = 1L,
    property_source_rule = paste(
      "first captured positive and negative target within each of",
      "PCM RSM and GPCM"
    ),
    properties = mfrmr_solver_property_registry(),
    status_cases = c(
      "optimal", "infeasible", "unbounded", "numeric_error",
      "timeout_mapper", "numeric_failure_mapper"
    ),
    memory_selection = "maximum constraints within PCM RSM and GPCM",
    memory_repetitions = as.integer(memory_repetitions),
    dispatch_eligibility_requires_specific_failure_status = TRUE,
    confirmation_authorized = FALSE
  )
}

mfrmr_run_jml_solver_qualification <- function(
    dry_run = TRUE, authorize = FALSE, repetitions = 7L,
    memory_repetitions = 3L, maxit = 60L, quad_points = 7L,
    reltol = 1e-9, evidence_dir = NULL, output_dir = NULL,
    progress = interactive()) {
  mfrmr_solver_require_support()
  capabilities <- mfrmr_solver_capabilities()
  prespec <- mfrmr_solver_prespecification(
    repetitions, memory_repetitions
  )
  runner_path <- file.path(
    mfrmr_solver_source_dir, "jml-solver-qualification-pilot-0.2.3.R"
  )
  worker_path <- file.path(
    mfrmr_solver_source_dir, "jml-solver-qualification-worker-0.2.3.R"
  )
  source_identity <- data.frame(
    Component = c("qualification_runner", "isolated_worker", "draft56_runner"),
    File = c(
      basename(runner_path), basename(worker_path),
      "jml-lp-attribution-pilot-0.2.3.R"
    ),
    SHA256 = vapply(c(
      runner_path, worker_path,
      file.path(mfrmr_solver_source_dir, "jml-lp-attribution-pilot-0.2.3.R")
    ), mfrmr_gpcm_repilot_hash_file, character(1)),
    stringsAsFactors = FALSE
  )
  if (isTRUE(dry_run)) {
    return(list(
      schema = "mfrmr-jml-solver-qualification-pilot-v1",
      prespecification = prespec, capabilities = capabilities,
      source_identity = source_identity,
      solver_dispatch_eligible = FALSE,
      confirmation_authorized = FALSE
    ))
  }
  if (!isTRUE(authorize)) {
    stop("Live solver qualification requires `authorize = TRUE`.",
         call. = FALSE)
  }
  if (any(!capabilities$Available)) {
    stop("Live solver qualification lacks required capabilities: ",
         paste(capabilities$Capability[!capabilities$Available], collapse = ", "),
         call. = FALSE)
  }
  if (is.null(evidence_dir) || length(evidence_dir) != 1L ||
      is.na(evidence_dir) || !nzchar(evidence_dir)) {
    stop("Live solver qualification requires one `evidence_dir`.",
         call. = FALSE)
  }
  evidence <- mfrmr_solver_validate_evidence(evidence_dir)
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("Live solver qualification requires one `output_dir`.",
         call. = FALSE)
  }
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
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

  acquisition <- mfrmr_solver_acquire(
    evidence, maxit = maxit, quad_points = quad_points,
    reltol = reltol, progress = progress
  )
  if (!acquisition$ledger_match ||
      !all(acquisition$fixed_results$FitSucceeded) ||
      !all(acquisition$fixed_comparison$AllEquivalent) ||
      !all(acquisition$model_results$FitSucceeded) ||
      !all(acquisition$model_results$StateMatch)) {
    stop("Captured solver problems do not reproduce Draft.56 evidence.",
         call. = FALSE)
  }
  saveRDS(acquisition$problems, file.path(staging, "solver-problems.rds"))
  timing <- mfrmr_solver_timing(
    acquisition$problems, repetitions = repetitions, progress = progress
  )
  pairs <- mfrmr_solver_pair_audit(timing)
  properties <- mfrmr_solver_property_controls(
    acquisition$problems, progress = progress
  )
  statuses <- mfrmr_solver_status_controls()
  memory <- mfrmr_solver_isolated_memory(
    acquisition$problems, staging,
    repetitions = memory_repetitions, progress = progress
  )
  included <- timing[timing$Included, , drop = FALSE]
  timing_summary <- do.call(rbind, lapply(
    split(included, included$Solver), function(x) data.frame(
      Solver = x$Solver[1L], Calls = nrow(x),
      TotalSeconds = sum(x$ElapsedSeconds),
      MedianSeconds = stats::median(x$ElapsedSeconds),
      P90Seconds = as.numeric(stats::quantile(
        x$ElapsedSeconds, 0.9, names = FALSE
      )),
      FirstPositionCalls = sum(x$OrderPosition == 1L),
      SecondPositionCalls = sum(x$OrderPosition == 2L),
      ExpectedMatches = sum(x$ExpectedMatch),
      SafeResults = sum(x$SafeResult),
      stringsAsFactors = FALSE
    )
  ))
  rownames(timing_summary) <- NULL
  failure_statuses <- statuses[statuses$Case != "optimal", , drop = FALSE]
  status_specific <- aggregate(
    failure_statuses$FailureClassSpecific,
    list(Solver = failure_statuses$Solver), all
  )
  names(status_specific)[2L] <- "AllFailureClassesSpecific"
  candidate_qualified <- all(pairs$PairValid) &&
    all(properties$PropertyValid) &&
    all(statuses$StatusControlValid) &&
    all(status_specific$AllFailureClassesSpecific) && all(memory$Valid)
  solver_dispatch_eligible <- FALSE
  completion_valid <- nrow(acquisition$registry) == 40L &&
    all(included$ExpectedMatch) && all(included$SafeResult) &&
    nrow(pairs) == 40L * as.integer(repetitions) && all(pairs$PairValid) &&
    nrow(properties) == 96L && all(properties$SafeResult) &&
    nrow(statuses) == 12L && all(statuses$StatusControlValid) &&
    all(memory$Valid) && !solver_dispatch_eligible
  if (!isTRUE(completion_valid)) {
    message(
      "[qualification-diagnostic] problems=", nrow(acquisition$registry),
      "; timing_expected=", sum(included$ExpectedMatch), "/", nrow(included),
      "; timing_safe=", sum(included$SafeResult), "/", nrow(included),
      "; pairs=", sum(pairs$PairValid), "/", nrow(pairs),
      "; properties=", sum(properties$PropertyValid), "/", nrow(properties),
      "; statuses=", sum(statuses$StatusControlValid), "/", nrow(statuses),
      "; memory=", sum(memory$Valid), "/", nrow(memory)
    )
    if (any(!properties$PropertyValid)) {
      failed_properties <- unique(properties[
        !properties$PropertyValid,
        c("Model", "SourceReason", "Transformation", "Solver", "Reason",
          "ExpectedClassificationMatch", "ExpectedCapacityMatch",
          "CrossSolverMatch", "SafeResult"),
        drop = FALSE
      ])
      message("[qualification-diagnostic] failed properties:\n",
              paste(capture.output(print(failed_properties)), collapse = "\n"))
    }
    if (any(!memory$Valid)) {
      message("[qualification-diagnostic] failed memory workers:\n",
              paste(capture.output(print(memory[!memory$Valid, ])),
                    collapse = "\n"))
    }
    stop("Solver qualification did not satisfy its calibration contract.",
         call. = FALSE)
  }
  if (!candidate_qualified && isTRUE(progress)) {
    message(
      "[qualification-result] candidate not qualified: properties=",
      sum(properties$PropertyValid), "/", nrow(properties),
      "; failure-status-specific solvers=",
      sum(status_specific$AllFailureClassesSpecific), "/",
      nrow(status_specific), "; dispatch remains ineligible"
    )
  }
  package_identity <- mfrmr_gpcm_repilot_package_content_identity("mfrmr")
  execution_identity <- data.frame(
    Schema = "mfrmr-jml-solver-qualification-identity-v1",
    PrespecificationSHA256 = mfrmr_gpcm_repilot_hash_object(prespec),
    ProblemRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(
      acquisition$registry
    ),
    SourceIdentitySHA256 = mfrmr_gpcm_repilot_hash_object(source_identity),
    CapabilityManifestSHA256 = mfrmr_gpcm_repilot_hash_object(capabilities),
    Draft56CompletionSHA256 = evidence$marker_sha256,
    InstalledPackageSHA256 = package_identity$PackageSHA256,
    ConfirmationAuthorized = FALSE,
    CandidateQualified = candidate_qualified,
    SolverDispatchEligible = solver_dispatch_eligible,
    stringsAsFactors = FALSE
  )
  execution_identity$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(
    execution_identity
  )
  run_summary <- data.frame(
    Schema = "mfrmr-jml-solver-qualification-pilot-v1",
    CapturedProblems = nrow(acquisition$registry),
    UniqueProblems = length(unique(acquisition$registry$ProblemSHA256)),
    TimingRepetitions = as.integer(repetitions),
    IncludedTimingCalls = nrow(included),
    PairComparisons = nrow(pairs), PairComparisonsPassed = sum(pairs$PairValid),
    PropertyControls = nrow(properties),
    PropertyControlsPassed = sum(properties$PropertyValid),
    StatusControls = nrow(statuses),
    StatusControlsPassed = sum(statuses$StatusControlValid),
    IsolatedMemoryProcesses = nrow(memory),
    IsolatedMemoryProcessesPassed = sum(memory$Valid),
    CandidateQualified = candidate_qualified,
    SolverDispatchEligible = solver_dispatch_eligible,
    RuntimeCriterionFrozen = FALSE, MemoryCriterionFrozen = FALSE,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "solver_qualification_calibration_only",
    stringsAsFactors = FALSE
  )
  out <- list(
    schema = "mfrmr-jml-solver-qualification-pilot-v1",
    prespecification = prespec,
    problems = acquisition$problems,
    problem_registry = acquisition$registry,
    fixed_comparison = acquisition$fixed_comparison,
    model_results = acquisition$model_results,
    timing = timing, pair_audit = pairs,
    timing_summary = timing_summary,
    properties = properties, statuses = statuses,
    status_specificity = status_specific, isolated_memory = memory,
    capabilities = capabilities, source_identity = source_identity,
    package_identity = package_identity,
    execution_identity = execution_identity, run_summary = run_summary,
    candidate_qualified = candidate_qualified,
    solver_dispatch_eligible = solver_dispatch_eligible,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    `problem-registry.csv` = acquisition$registry,
    `fixed-comparison.csv` = acquisition$fixed_comparison,
    `model-results.csv` = acquisition$model_results,
    `timing-raw.csv` = timing, `pair-audit.csv` = pairs,
    `timing-summary.csv` = timing_summary,
    `property-controls.csv` = properties,
    `status-controls.csv` = statuses,
    `status-specificity.csv` = status_specific,
    `isolated-memory.csv` = memory,
    `capabilities.csv` = capabilities,
    `source-identity.csv` = source_identity,
    `package-identity.csv` = package_identity,
    `execution-identity.csv` = execution_identity,
    `run-summary.csv` = run_summary
  )
  for (name in names(files)) utils::write.csv(
    files[[name]], file.path(staging, name), row.names = FALSE, na = ""
  )
  saveRDS(out, file.path(staging, "jml-solver-qualification-pilot.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  completion <- list(
    schema = "mfrmr-jml-solver-qualification-completion-v1",
    execution_sha256 = execution_identity$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    candidate_qualified = candidate_qualified,
    solver_dispatch_eligible = solver_dispatch_eligible,
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) {
    stop("Completed solver evidence could not be promoted.", call. = FALSE)
  }
  promoted <- TRUE
  invisible(out)
}
