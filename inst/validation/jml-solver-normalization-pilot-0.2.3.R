mfrmr_normalization_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-solver-normalization-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) return(dirname(normalizePath(
    hit[length(hit)], winslash = "/", mustWork = FALSE
  )))
  candidates <- c(
    file.path(
      "inst", "validation", "jml-solver-normalization-pilot-0.2.3.R"
    ),
    "jml-solver-normalization-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else dirname(normalizePath(
    path, winslash = "/", mustWork = TRUE
  ))
})

mfrmr_normalization_or <- function(x, replacement) {
  if (is.null(x)) replacement else x
}

mfrmr_normalization_require_support <- function() {
  target_env <- environment(mfrmr_normalization_require_support)
  required <- c(
    "mfrmr_solver_require_support", "mfrmr_solver_run_target",
    "mfrmr_solver_compact_result", "mfrmr_solver_base_sha256",
    "mfrmr_solver_problem_sha256", "mfrmr_jml_lp_glpk_run",
    "mfrmr_jml_lp_result_parity", "mfrmr_target_scale_artifact_inventory",
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_package_content_identity"
  )
  if (!all(vapply(
    required, exists, logical(1), envir = target_env,
    mode = "function", inherits = TRUE
  ))) {
    candidates <- c(
      if (!is.na(mfrmr_normalization_source_dir)) file.path(
        mfrmr_normalization_source_dir,
        "jml-solver-qualification-pilot-0.2.3.R"
      ) else character(0),
      file.path(
        "inst", "validation", "jml-solver-qualification-pilot-0.2.3.R"
      ),
      "jml-solver-qualification-pilot-0.2.3.R"
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("Cannot locate Draft.57 solver-qualification support.",
           call. = FALSE)
    }
    sys.source(path, envir = target_env)
    mfrmr_solver_require_support()
  }
  if (!all(vapply(
    required, exists, logical(1), envir = target_env,
    mode = "function", inherits = TRUE
  ))) {
    stop("Solver-normalization support did not load completely.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_normalization_capabilities <- function() {
  mfrmr_normalization_require_support()
  packages <- c(
    "mfrmr", "Matrix", "digest", "lpSolve", "slam", "Rglpk",
    "processx"
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
      "isolated_process_deadline"
    ),
    RequiredForLivePilot = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_normalization_validate_evidence <- function(evidence_dir) {
  mfrmr_normalization_require_support()
  evidence_dir <- normalizePath(evidence_dir, winslash = "/", mustWork = TRUE)
  marker_path <- file.path(evidence_dir, "run-complete.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(e) e)
  if (inherits(marker, "error") || !identical(
    marker$schema, "mfrmr-jml-solver-qualification-completion-v1"
  )) stop("Draft.57 evidence marker is invalid.", call. = FALSE)
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
  if (!valid || !identical(marker$candidate_qualified, FALSE) ||
      !identical(marker$solver_dispatch_eligible, FALSE) ||
      !identical(marker$confirmation_authorized, FALSE)) {
    stop("Draft.57 evidence inventory or decision boundary is invalid.",
         call. = FALSE)
  }
  problems_path <- file.path(evidence_dir, "solver-problems.rds")
  problems <- readRDS(problems_path)
  registry <- utils::read.csv(
    file.path(evidence_dir, "problem-registry.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  if (length(problems) != 40L || nrow(registry) != 40L ||
      !identical(
        vapply(problems, function(x) x$ProblemSHA256, character(1)),
        registry$ProblemSHA256
      )) stop("Draft.57 serialized problem registry is invalid.", call. = FALSE)
  list(
    directory = evidence_dir, marker = marker, problems = problems,
    registry = registry,
    marker_sha256 = mfrmr_gpcm_repilot_hash_file(marker_path),
    problems_sha256 = mfrmr_gpcm_repilot_hash_file(problems_path)
  )
}

mfrmr_normalization_source_problems <- function(problems) {
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
    stop("The six frozen Draft.57 source problems are unavailable.",
         call. = FALSE)
  }
  problems[selected]
}

mfrmr_normalization_prespecification <- function() {
  list(
    schema = "mfrmr-jml-solver-normalization-prespec-v1",
    source_rule = paste(
      "first captured positive and negative target within PCM RSM and GPCM"
    ),
    scale_exponents = c(0, 1, 2, 3, 4, 6),
    row_pattern = "cycle(10^-exponent,1,10^exponent)",
    formulations = c("raw", "l1_row_normalized"),
    solvers = c("lpSolve", "GLPK"),
    normalization = paste(
      "divide each nonzero contrast constraint row by its original L1 norm;",
      "box constraints target strict objective and postsolve contrast remain",
      "on the original transformed scale"
    ),
    fresh_process_source = paste(
      "positive RSM source at exponent 3 under both formulations and solvers"
    ),
    fresh_process_repetitions = 3L,
    deadline_source = "normalized positive RSM source at exponent 3",
    deadline_after_started_ms = 250L,
    deadline_solver_repetitions = 100000L,
    success_deadline_ms = 30000L,
    confirmation_authorized = FALSE
  )
}

mfrmr_normalization_scale_problem <- function(problem, exponent) {
  exponent <- as.numeric(exponent)
  contrast <- problem$lp_base$contrast_design
  factors <- rep(
    c(10^(-exponent), 1, 10^exponent), length.out = nrow(contrast)
  )
  scaled_contrast <- Matrix::Diagonal(x = factors) %*% contrast
  base_fun <- get(
    "mfrmr_jml_recession_lp_base", asNamespace("mfrmr"), inherits = FALSE
  )
  out <- problem
  out$SourceProblemSHA256 <- problem$ProblemSHA256
  out$ScaleExponent <- exponent
  out$RowScaleMinimum <- min(factors)
  out$RowScaleMaximum <- max(factors)
  out$RowScaleSHA256 <- mfrmr_gpcm_repilot_hash_object(factors)
  out$lp_base <- base_fun(
    scaled_contrast, representation = problem$lp_base$representation
  )
  out$ProblemSHA256 <- mfrmr_solver_problem_sha256(
    out$lp_base, out$target, out$objective_tolerance,
    out$certificate_tolerance
  )
  out
}

mfrmr_normalization_solver_base <- function(lp_base) {
  contrast <- lp_base$contrast_design
  norms <- as.numeric(Matrix::rowSums(abs(contrast)))
  factors <- ifelse(norms > 0, 1 / norms, 1)
  n_contrasts <- nrow(contrast)
  out <- lp_base
  if (identical(lp_base$representation, "dense_reference")) {
    matrix <- lp_base$constraint_matrix
    if (n_contrasts > 0L) {
      matrix[seq_len(n_contrasts), ] <-
        factors * matrix[seq_len(n_contrasts), , drop = FALSE]
    }
    out$constraint_matrix <- matrix
  } else {
    triplet <- lp_base$constraint_triplet
    rows <- as.integer(triplet[, 1L])
    contrast_entries <- rows <= n_contrasts
    triplet[contrast_entries, 3L] <-
      triplet[contrast_entries, 3L] * factors[rows[contrast_entries]]
    out$constraint_triplet <- triplet
  }
  attr(out, "mfrmr_normalization_contract") <-
    "mfrmr-jml-solver-row-l1-normalization-v1"
  attr(out, "mfrmr_normalization_sha256") <-
    mfrmr_gpcm_repilot_hash_object(list(
      schema = "mfrmr-jml-solver-row-l1-normalization-v1",
      original_base_sha256 = mfrmr_solver_base_sha256(lp_base),
      row_norm_sha256 = mfrmr_gpcm_repilot_hash_object(norms),
      row_factor_sha256 = mfrmr_gpcm_repilot_hash_object(factors),
      zero_rows = sum(norms == 0), minimum_positive_norm = if (any(norms > 0)) {
        min(norms[norms > 0])
      } else NA_real_, maximum_norm = max(c(0, norms))
    ))
  out
}

mfrmr_normalization_formulation_sha256 <- function(problem, formulation,
                                                    solver_base) {
  constraint <- if (identical(
    solver_base$representation, "dense_reference"
  )) solver_base$constraint_matrix else solver_base$constraint_triplet
  mfrmr_gpcm_repilot_hash_object(list(
    schema = "mfrmr-jml-solver-formulation-v1",
    original_problem_sha256 = problem$ProblemSHA256,
    formulation = formulation,
    normalization_sha256 = mfrmr_normalization_or(
      attr(solver_base, "mfrmr_normalization_sha256"), NA_character_
    ),
    representation = solver_base$representation,
    constraint = constraint,
    direction = solver_base$constraint_direction,
    rhs = solver_base$constraint_rhs,
    original_contrast_sha256 = mfrmr_gpcm_repilot_hash_object(list(
      p = solver_base$contrast_design@p,
      i = solver_base$contrast_design@i,
      x = solver_base$contrast_design@x
    ))
  ))
}

mfrmr_normalization_raw_capacity <- function(problem, solver) {
  objective <- c(problem$target, -problem$target)
  value <- tryCatch(
    if (identical(solver, "lpSolve")) {
      run_fun <- get(
        "mfrmr_jml_recession_run_lp", asNamespace("mfrmr"), inherits = FALSE
      )
      run_fun(
        lp_base = problem$lp_base, objective = objective,
        timeout = problem$timeout
      )
    } else {
      mfrmr_jml_lp_glpk_run(
        lp_base = problem$lp_base, objective = objective,
        timeout = problem$timeout
      )
    },
    error = function(e) e
  )
  n <- length(problem$target)
  upper <- sum(abs(problem$target))
  if (inherits(value, "error")) return(data.frame(
    RawError = conditionMessage(value), RawStatus = NA_integer_,
    RawObjective = NA_real_, RawObjectiveFinite = FALSE,
    RawObjectiveWithinTheoreticalBound = FALSE,
    RawSolutionFinite = FALSE, RawSplitBoxValid = FALSE,
    RawOriginalPrimalMargin = NA_real_, RawOriginalPrimalValid = FALSE,
    RawObjectiveReconstruction = NA_real_,
    RawObjectiveReconstructionValid = FALSE,
    RawCapacityAccepted = FALSE, TheoreticalCapacityUpperBound = upper,
    stringsAsFactors = FALSE
  ))
  status <- as.integer(value$status)
  objective_value <- if (identical(solver, "lpSolve")) {
    as.numeric(value$objval)
  } else as.numeric(value$objval)
  solution <- as.numeric(value$solution)
  solution_finite <- length(solution) == 2L * n && all(is.finite(solution))
  if (solution_finite) {
    plus <- solution[seq_len(n)]
    minus <- solution[n + seq_len(n)]
    direction <- plus - minus
    margins <- as.numeric(problem$lp_base$contrast_design %*% direction)
    split_box <- all(plus >= -1e-8) && all(minus >= -1e-8) &&
      all(plus + minus <= 1 + 1e-7)
    primal_margin <- if (length(margins) > 0L) min(margins) else Inf
    primal_valid <- is.finite(primal_margin) &&
      primal_margin >= -problem$certificate_tolerance
    reconstruction <- sum(problem$target * direction)
    reconstruction_valid <- is.finite(objective_value) &&
      abs(reconstruction - objective_value) <=
        1e-7 * (1 + abs(objective_value))
  } else {
    split_box <- FALSE; primal_margin <- NA_real_; primal_valid <- FALSE
    reconstruction <- NA_real_; reconstruction_valid <- FALSE
  }
  objective_bound <- is.finite(objective_value) &&
    objective_value >= -1e-8 &&
    objective_value <= upper + 1e-7 * (1 + upper)
  accepted <- identical(status, 0L) && is.finite(objective_value) &&
    objective_bound && solution_finite && split_box && primal_valid &&
    reconstruction_valid
  data.frame(
    RawError = NA_character_, RawStatus = status,
    RawObjective = objective_value,
    RawObjectiveFinite = is.finite(objective_value),
    RawObjectiveWithinTheoreticalBound = objective_bound,
    RawSolutionFinite = solution_finite, RawSplitBoxValid = split_box,
    RawOriginalPrimalMargin = primal_margin,
    RawOriginalPrimalValid = primal_valid,
    RawObjectiveReconstruction = reconstruction,
    RawObjectiveReconstructionValid = reconstruction_valid,
    RawCapacityAccepted = accepted,
    TheoreticalCapacityUpperBound = upper,
    stringsAsFactors = FALSE
  )
}

mfrmr_normalization_evaluate_case <- function(problem, solver, formulation,
                                              expected = NULL) {
  solver <- match.arg(solver, c("lpSolve", "GLPK"))
  formulation <- match.arg(formulation, c("raw", "l1_row_normalized"))
  original_base <- problem$lp_base
  solver_base <- if (identical(formulation, "raw")) {
    original_base
  } else mfrmr_normalization_solver_base(original_base)
  solver_problem <- problem
  solver_problem$lp_base <- solver_base
  formulation_sha <- mfrmr_normalization_formulation_sha256(
    problem, formulation, solver_base
  )
  raw <- mfrmr_normalization_raw_capacity(solver_problem, solver)
  target <- tryCatch(
    mfrmr_solver_run_target(solver_problem, solver), error = function(e) e
  )
  if (inherits(target, "error")) {
    target_value <- list(
      evaluated = FALSE, certified = FALSE,
      reason = paste0("solver_error: ", conditionMessage(target)),
      solver_status = NA_integer_, target_capacity = NA_real_
    )
  } else target_value <- target
  compact <- mfrmr_solver_compact_result(solver_problem, target_value)
  if (is.null(expected)) expected <- problem$production
  expected_match <- !inherits(target, "error") &&
    mfrmr_jml_lp_result_parity(expected, target)
  fail_closed <- !compact$Evaluated && !compact$Certified &&
    !raw$RawCapacityAccepted
  provenance_safe <- compact$SafeResult &&
    ((compact$Evaluated && raw$RawCapacityAccepted) || fail_closed)
  data.frame(
    SourceProblemSHA256 = as.character(problem$SourceProblemSHA256),
    OriginalScaleProblemSHA256 = as.character(problem$ProblemSHA256),
    SolverFormulationSHA256 = formulation_sha,
    NormalizationSHA256 = as.character(mfrmr_normalization_or(
      attr(solver_base, "mfrmr_normalization_sha256"), NA_character_
    )),
    ProblemId = problem$ProblemId, ScenarioId = problem$ScenarioId,
    Model = problem$Model, Scope = problem$Scope,
    SourceReason = as.character(expected$reason),
    ScaleExponent = problem$ScaleExponent,
    RowScaleMinimum = problem$RowScaleMinimum,
    RowScaleMaximum = problem$RowScaleMaximum,
    RowScaleSHA256 = problem$RowScaleSHA256,
    Formulation = formulation, Solver = solver,
    ExpectedMatch = expected_match,
    ProvenanceSafe = provenance_safe,
    FormulationQualified = expected_match && provenance_safe &&
      raw$RawCapacityAccepted,
    stringsAsFactors = FALSE
  ) |>
    cbind(raw, compact)
}

mfrmr_normalization_scale_ladder <- function(problems,
                                             progress = interactive()) {
  prespec <- mfrmr_normalization_prespecification()
  rows <- list(); cursor <- 0L
  for (source in mfrmr_normalization_source_problems(problems)) {
    for (exponent in prespec$scale_exponents) {
      problem <- mfrmr_normalization_scale_problem(source, exponent)
      for (formulation in prespec$formulations) {
        for (solver in prespec$solvers) {
          cursor <- cursor + 1L
          if (isTRUE(progress)) message(
            "[scale] ", source$Model, " / ", source$production$reason,
            " / e", exponent, " / ", formulation, " / ", solver
          )
          rows[[cursor]] <- mfrmr_normalization_evaluate_case(
            problem, solver, formulation, source$production
          )
        }
      }
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_normalization_worker_paths <- function(staging, id) {
  list(
    job = file.path(staging, paste0("worker-job-", id, ".rds")),
    output = file.path(staging, paste0("worker-output-", id, ".rds")),
    started = file.path(staging, paste0("worker-started-", id, ".rds")),
    stdout = file.path(staging, paste0("worker-stdout-", id, ".txt")),
    stderr = file.path(staging, paste0("worker-stderr-", id, ".txt"))
  )
}

mfrmr_normalization_worker_job <- function(problem, solver, formulation,
                                           repetitions, paths) {
  list(
    lib_paths = .libPaths(), mfrmr_lib = dirname(system.file(package = "mfrmr")),
    runner_path = file.path(
      mfrmr_normalization_source_dir,
      "jml-solver-normalization-pilot-0.2.3.R"
    ),
    problem = problem, expected = problem$production,
    solver = solver, formulation = formulation,
    repetitions = as.integer(repetitions), output_path = paths$output,
    started_path = paths$started
  )
}

mfrmr_normalization_run_worker <- function(job, paths, timeout_ms = 30000L) {
  saveRDS(job, paths$job)
  worker <- file.path(
    mfrmr_normalization_source_dir,
    "jml-solver-normalization-worker-0.2.3.R"
  )
  rscript <- file.path(R.home("bin"), "Rscript.exe")
  if (!file.exists(rscript)) rscript <- file.path(R.home("bin"), "Rscript")
  result <- processx::run(
    rscript, c(worker, paths$job),
    stdout = paths$stdout, stderr = paths$stderr,
    timeout = as.integer(timeout_ms), error_on_status = FALSE,
    cleanup_tree = TRUE
  )
  value <- if (identical(result$status, 0L) && file.exists(paths$output)) {
    tryCatch(readRDS(paths$output), error = function(e) e)
  } else structure(list(message = paste(
    c(
      result$stdout, result$stderr,
      if (file.exists(paths$stdout)) readLines(paths$stdout, warn = FALSE),
      if (file.exists(paths$stderr)) readLines(paths$stderr, warn = FALSE)
    ), collapse = " | "
  )), class = c("worker_error", "error", "condition"))
  list(process = result, value = value)
}

mfrmr_normalization_fresh_process <- function(problems, staging,
                                              progress = interactive()) {
  source <- mfrmr_normalization_source_problems(problems)
  source <- source[vapply(source, function(x) {
    identical(x$Model, "RSM") && identical(
      x$production$reason, "certified_additive_recession_direction"
    )
  }, logical(1))][[1L]]
  problem <- mfrmr_normalization_scale_problem(source, 3)
  rows <- list(); cursor <- 0L
  for (formulation in c("raw", "l1_row_normalized")) {
    for (solver in c("lpSolve", "GLPK")) {
      parent <- mfrmr_normalization_evaluate_case(
        problem, solver, formulation, source$production
      )
      for (replicate in 1:3) {
        cursor <- cursor + 1L
        if (isTRUE(progress)) message(
          "[fresh] ", formulation, " / ", solver, " / ", replicate
        )
        paths <- mfrmr_normalization_worker_paths(staging, paste0("f", cursor))
        run <- tryCatch(mfrmr_normalization_run_worker(
          mfrmr_normalization_worker_job(
            problem, solver, formulation, 1L, paths
          ), paths
        ), error = function(e) e)
        valid <- !inherits(run, "error") && !inherits(run$value, "error") &&
          identical(run$value$schema, "mfrmr-jml-normalization-worker-v1") &&
          nrow(run$value$results) == 1L
        child <- if (valid) run$value$results else parent[0, , drop = FALSE]
        observed_match <- valid &&
          identical(child$ExpectedMatch, parent$ExpectedMatch) &&
          identical(child$ProvenanceSafe, parent$ProvenanceSafe) &&
          identical(child$FormulationQualified, parent$FormulationQualified) &&
          identical(child$Reason, parent$Reason) &&
          identical(child$SolverStatus, parent$SolverStatus)
        rows[[cursor]] <- data.frame(
          Formulation = formulation, Solver = solver, Replicate = replicate,
          ProcessStatus = if (inherits(run, "error")) NA_integer_ else {
            as.integer(run$process$status)
          },
          ParentExpectedMatch = parent$ExpectedMatch,
          ParentProvenanceSafe = parent$ProvenanceSafe,
          ParentFormulationQualified = parent$FormulationQualified,
          ChildResultRead = valid, ObservedMatchParent = observed_match,
          ChildReason = if (valid) child$Reason else NA_character_,
          ChildSolverStatus = if (valid) child$SolverStatus else NA_integer_,
          Error = if (inherits(run, "error")) conditionMessage(run) else if (
            inherits(run$value, "error")
          ) conditionMessage(run$value) else NA_character_,
          stringsAsFactors = FALSE
        )
        unlink(unlist(paths), force = TRUE)
      }
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_normalization_deadline_one <- function(problem, solver, mode, staging,
                                             id, progress = interactive()) {
  mode <- match.arg(mode, c("success", "forced_deadline"))
  paths <- mfrmr_normalization_worker_paths(staging, paste0("d", id))
  repetitions <- if (identical(mode, "success")) 1L else 100000L
  job <- mfrmr_normalization_worker_job(
    problem, solver, "l1_row_normalized", repetitions, paths
  )
  saveRDS(job, paths$job)
  worker <- file.path(
    mfrmr_normalization_source_dir,
    "jml-solver-normalization-worker-0.2.3.R"
  )
  rscript <- file.path(R.home("bin"), "Rscript.exe")
  if (!file.exists(rscript)) rscript <- file.path(R.home("bin"), "Rscript")
  process <- processx::process$new(
    rscript, c(worker, paths$job), stdout = paths$stdout,
    stderr = paths$stderr, cleanup_tree = TRUE
  )
  started_at <- Sys.time()
  while (process$is_alive() && !file.exists(paths$started) &&
         as.numeric(difftime(Sys.time(), started_at, units = "secs")) < 30) {
    Sys.sleep(0.05)
  }
  started <- file.exists(paths$started)
  killed <- FALSE
  deadline_ms <- if (identical(mode, "success")) 30000L else 250L
  if (started && process$is_alive()) {
    process$wait(timeout = deadline_ms)
  }
  if (identical(mode, "forced_deadline") && process$is_alive()) {
    process$kill_tree()
    killed <- TRUE
    process$wait(timeout = 5000L)
  }
  if (identical(mode, "success") && process$is_alive()) {
    process$kill_tree()
    killed <- TRUE
    process$wait(timeout = 5000L)
  }
  exit_status <- process$get_exit_status()
  output_produced <- file.exists(paths$output)
  value <- if (output_produced) tryCatch(
    readRDS(paths$output), error = function(e) e
  ) else NULL
  result_valid <- !inherits(value, "error") && !is.null(value) &&
    identical(value$schema, "mfrmr-jml-normalization-worker-v1") &&
    nrow(value$results) == repetitions
  control_valid <- if (identical(mode, "success")) {
    started && !killed && identical(exit_status, 0L) && result_valid &&
      all(value$results$ProvenanceSafe)
  } else started && killed && !output_produced &&
    !identical(exit_status, 0L)
  logs <- paste(
    c(
      if (file.exists(paths$stdout)) readLines(paths$stdout, warn = FALSE),
      if (file.exists(paths$stderr)) readLines(paths$stderr, warn = FALSE)
    ),
    collapse = " | "
  )
  out <- data.frame(
    Solver = solver, Mode = mode, DeadlineAfterStartedMs = deadline_ms,
    RequestedRepetitions = repetitions, StartedMarkerObserved = started,
    KilledByParent = killed,
    ExitStatus = as.integer(mfrmr_normalization_or(exit_status, NA_integer_)),
    OutputProduced = output_produced, ResultValid = result_valid,
    ControlValid = control_valid,
    ExitReason = if (killed) "os_deadline_parent_kill_tree" else if (
      identical(exit_status, 0L)
    ) "completed" else "child_nonzero_exit",
    Logs = logs, stringsAsFactors = FALSE
  )
  unlink(unlist(paths), force = TRUE)
  out
}

mfrmr_normalization_deadline_controls <- function(problems, staging,
                                                  progress = interactive()) {
  source <- mfrmr_normalization_source_problems(problems)
  source <- source[vapply(source, function(x) {
    identical(x$Model, "RSM") && identical(
      x$production$reason, "certified_additive_recession_direction"
    )
  }, logical(1))][[1L]]
  problem <- mfrmr_normalization_scale_problem(source, 3)
  rows <- list(); cursor <- 0L
  for (solver in c("lpSolve", "GLPK")) {
    for (mode in c("success", "forced_deadline")) {
      cursor <- cursor + 1L
      if (isTRUE(progress)) message("[deadline] ", solver, " / ", mode)
      rows[[cursor]] <- mfrmr_normalization_deadline_one(
        problem, solver, mode, staging, cursor, progress
      )
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_run_jml_solver_normalization <- function(
    dry_run = TRUE, authorize = FALSE, evidence_dir = NULL,
    output_dir = NULL, progress = interactive()) {
  mfrmr_normalization_require_support()
  capabilities <- mfrmr_normalization_capabilities()
  prespec <- mfrmr_normalization_prespecification()
  runner_path <- file.path(
    mfrmr_normalization_source_dir,
    "jml-solver-normalization-pilot-0.2.3.R"
  )
  worker_path <- file.path(
    mfrmr_normalization_source_dir,
    "jml-solver-normalization-worker-0.2.3.R"
  )
  source_identity <- data.frame(
    Component = c("normalization_runner", "isolated_worker", "draft57_runner"),
    File = c(
      basename(runner_path), basename(worker_path),
      "jml-solver-qualification-pilot-0.2.3.R"
    ),
    SHA256 = vapply(c(
      runner_path, worker_path,
      file.path(
        mfrmr_normalization_source_dir,
        "jml-solver-qualification-pilot-0.2.3.R"
      )
    ), mfrmr_gpcm_repilot_hash_file, character(1)),
    stringsAsFactors = FALSE
  )
  if (isTRUE(dry_run)) return(list(
    schema = "mfrmr-jml-solver-normalization-pilot-v1",
    prespecification = prespec, capabilities = capabilities,
    source_identity = source_identity,
    production_change_authorized = FALSE,
    solver_dispatch_eligible = FALSE,
    confirmation_authorized = FALSE
  ))
  if (!isTRUE(authorize)) stop(
    "Live solver-normalization execution requires `authorize = TRUE`.",
    call. = FALSE
  )
  if (any(!capabilities$Available)) stop(
    "Live solver-normalization execution lacks required capabilities: ",
    paste(capabilities$Capability[!capabilities$Available], collapse = ", "),
    call. = FALSE
  )
  if (is.null(evidence_dir) || length(evidence_dir) != 1L ||
      is.na(evidence_dir) || !nzchar(evidence_dir)) stop(
    "Live solver-normalization execution requires one `evidence_dir`.",
    call. = FALSE
  )
  evidence <- mfrmr_normalization_validate_evidence(evidence_dir)
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) stop(
    "Live solver-normalization execution requires one `output_dir`.",
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

  ladder <- mfrmr_normalization_scale_ladder(
    evidence$problems, progress = progress
  )
  fresh <- mfrmr_normalization_fresh_process(
    evidence$problems, staging, progress
  )
  deadlines <- mfrmr_normalization_deadline_controls(
    evidence$problems, staging, progress
  )
  normalized <- ladder[ladder$Formulation == "l1_row_normalized", ]
  raw <- ladder[ladder$Formulation == "raw", ]
  normalized_fresh <- fresh[fresh$Formulation == "l1_row_normalized", ]
  normalization_candidate_qualified <-
    nrow(normalized) == 72L && all(normalized$FormulationQualified) &&
    all(normalized_fresh$ObservedMatchParent) &&
    all(normalized_fresh$ParentFormulationQualified)
  solver_candidate_qualified <- FALSE
  production_change_authorized <- FALSE
  solver_dispatch_eligible <- FALSE
  completion_valid <- nrow(ladder) == 144L &&
    all(ladder$ProvenanceSafe) && nrow(fresh) == 12L &&
    all(fresh$ObservedMatchParent) && nrow(deadlines) == 4L &&
    all(deadlines$ControlValid) &&
    !production_change_authorized && !solver_dispatch_eligible
  if (!completion_valid) {
    message(
      "[normalization-diagnostic] ladder=", nrow(ladder),
      "; safe=", sum(ladder$ProvenanceSafe),
      "; normalized=", sum(normalized$FormulationQualified), "/", nrow(normalized),
      "; raw=", sum(raw$FormulationQualified), "/", nrow(raw),
      "; fresh=", sum(fresh$ObservedMatchParent), "/", nrow(fresh),
      "; deadlines=", sum(deadlines$ControlValid), "/", nrow(deadlines)
    )
    stop("Solver-normalization evidence did not complete safely.",
         call. = FALSE)
  }
  package_identity <- mfrmr_gpcm_repilot_package_content_identity("mfrmr")
  execution_identity <- data.frame(
    Schema = "mfrmr-jml-solver-normalization-identity-v1",
    PrespecificationSHA256 = mfrmr_gpcm_repilot_hash_object(prespec),
    SourceIdentitySHA256 = mfrmr_gpcm_repilot_hash_object(source_identity),
    CapabilityManifestSHA256 = mfrmr_gpcm_repilot_hash_object(capabilities),
    Draft57CompletionSHA256 = evidence$marker_sha256,
    Draft57ProblemsSHA256 = evidence$problems_sha256,
    LadderSHA256 = mfrmr_gpcm_repilot_hash_object(ladder),
    InstalledPackageSHA256 = package_identity$PackageSHA256,
    NormalizationCandidateQualified = normalization_candidate_qualified,
    SolverCandidateQualified = solver_candidate_qualified,
    ProductionChangeAuthorized = production_change_authorized,
    SolverDispatchEligible = solver_dispatch_eligible,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution_identity$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(
    execution_identity
  )
  run_summary <- data.frame(
    Schema = "mfrmr-jml-solver-normalization-pilot-v1",
    SourceProblems = 6L, ScaleExponents = 6L,
    LadderRows = nrow(ladder), ProvenanceSafeRows = sum(ladder$ProvenanceSafe),
    RawRows = nrow(raw), RawQualifiedRows = sum(raw$FormulationQualified),
    NormalizedRows = nrow(normalized),
    NormalizedQualifiedRows = sum(normalized$FormulationQualified),
    FreshProcesses = nrow(fresh),
    FreshProcessesMatched = sum(fresh$ObservedMatchParent),
    DeadlineControls = nrow(deadlines),
    DeadlineControlsPassed = sum(deadlines$ControlValid),
    NormalizationCandidateQualified = normalization_candidate_qualified,
    SolverCandidateQualified = solver_candidate_qualified,
    ProductionChangeAuthorized = production_change_authorized,
    SolverDispatchEligible = solver_dispatch_eligible,
    RuntimeCriterionFrozen = FALSE, ConfirmationAuthorized = FALSE,
    EvidenceUse = "solver_normalization_calibration_only",
    stringsAsFactors = FALSE
  )
  out <- list(
    schema = "mfrmr-jml-solver-normalization-pilot-v1",
    prespecification = prespec, ladder = ladder,
    fresh_process = fresh, deadline_controls = deadlines,
    capabilities = capabilities, source_identity = source_identity,
    package_identity = package_identity,
    execution_identity = execution_identity, run_summary = run_summary,
    normalization_candidate_qualified = normalization_candidate_qualified,
    solver_candidate_qualified = solver_candidate_qualified,
    production_change_authorized = production_change_authorized,
    solver_dispatch_eligible = solver_dispatch_eligible,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    `scale-ladder.csv` = ladder, `fresh-process.csv` = fresh,
    `deadline-controls.csv` = deadlines,
    `capabilities.csv` = capabilities,
    `source-identity.csv` = source_identity,
    `package-identity.csv` = package_identity,
    `execution-identity.csv` = execution_identity,
    `run-summary.csv` = run_summary
  )
  for (name in names(files)) utils::write.csv(
    files[[name]], file.path(staging, name), row.names = FALSE, na = ""
  )
  saveRDS(out, file.path(staging, "jml-solver-normalization-pilot.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  marker <- list(
    schema = "mfrmr-jml-solver-normalization-completion-v1",
    execution_sha256 = execution_identity$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    normalization_candidate_qualified = normalization_candidate_qualified,
    solver_candidate_qualified = solver_candidate_qualified,
    production_change_authorized = production_change_authorized,
    solver_dispatch_eligible = solver_dispatch_eligible,
    confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) stop(
    "Completed solver-normalization evidence could not be promoted.",
    call. = FALSE
  )
  promoted <- TRUE
  invisible(out)
}
