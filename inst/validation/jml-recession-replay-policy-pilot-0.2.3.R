# Internal calibration runner for the mfrmr 0.2.3 JML recession replay policy.
# It cannot alter production, select a solver, or authorize confirmation.

mfrmr_replay_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-recession-replay-policy-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) return(dirname(normalizePath(
    hit[length(hit)], winslash = "/", mustWork = FALSE
  )))
  candidates <- c(
    file.path(
      "inst", "validation", "jml-recession-replay-policy-pilot-0.2.3.R"
    ),
    "jml-recession-replay-policy-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else dirname(normalizePath(
    path, winslash = "/", mustWork = TRUE
  ))
})

mfrmr_replay_or <- function(x, replacement) {
  if (is.null(x)) replacement else x
}

mfrmr_replay_source <- function(file, target_env) {
  candidates <- c(
    if (!is.na(mfrmr_replay_source_dir)) {
      file.path(mfrmr_replay_source_dir, file)
    } else character(0),
    file.path("inst", "validation", file), file
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) stop("Cannot locate replay support: ", file, call. = FALSE)
  sys.source(path, envir = target_env)
  invisible(path)
}

mfrmr_replay_require_support <- function() {
  target_env <- environment(mfrmr_replay_require_support)
  if (!exists(
    "mfrmr_target_cone_require_support", envir = target_env,
    mode = "function", inherits = TRUE
  )) mfrmr_replay_source(
    "jml-target-positive-cone-pilot-0.2.3.R", target_env
  )
  mfrmr_target_cone_require_support()
  required <- c(
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_package_content_identity",
    "mfrmr_target_scale_artifact_inventory"
  )
  if (!all(vapply(
    required, exists, logical(1), envir = target_env,
    mode = "function", inherits = TRUE
  ))) stop("Replay support did not load completely.", call. = FALSE)
  invisible(TRUE)
}

mfrmr_replay_capabilities <- function() {
  mfrmr_replay_require_support()
  packages <- c("mfrmr", "Matrix", "digest", "lpSolve", "processx")
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
      "production_lp", "fresh_process_and_parent_deadline"
    ),
    RequiredForLivePilot = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_replay_problem_registry <- function() {
  data.frame(
    ProblemId = c(2L, 5L, 8L, 10L, 13L, 14L, 16L),
    ProblemRole = c(
      "complete_rsm_positive", "complete_gpcm_positive",
      "balanced_sparse_rsm_strictness_failed",
      "balanced_sparse_gpcm_positive", "random_sparse_rsm_positive",
      "random_sparse_rsm_negative", "random_sparse_gpcm_negative"
    ),
    ExpectedScenarioId = c(
      "TPC-COMPLETE-RSM", "TPC-COMPLETE-GPCM",
      "TPC-SPARSE_BALANCED-RSM", "TPC-SPARSE_BALANCED-GPCM",
      "TPC-SPARSE_RANDOM-RSM", "TPC-SPARSE_RANDOM-RSM",
      "TPC-SPARSE_RANDOM-GPCM"
    ),
    ExpectedProblemSHA256 = c(
      "faa636ff3a88b9687aa1f34404e40390e4c56461263f3abab1d9d59cd00458c9",
      "d3775362661d2053296ef5253b8cd291eaf58d59e7ba7a02fcfdb94b8d23f988",
      "182766d0857930709ae6026d2d940798e491f94a19d02d4933e882dd40c66dff",
      "7e24db016914d12603c230a45bca9a23d208033d8825252ced328666c77951f3",
      "2241fd7c113e19e033911f977d7c7d549f5f4dbd21b0b316ebeb414f3d37ea96",
      "674389c905739a9281d9c2309d1225a763d8bd8c7d7824c9b03126477d955a96",
      "7168c61a9db1ae355a7e8b3608de7add6bd5072ad03730a0bd3c223967bdf00e"
    ),
    NegativeControl = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_replay_policy_registry <- function() {
  data.frame(
    PolicyId = c(
      "production_2s", "bounded_retry_2s_8s", "bounded_single_10s",
      "os_bounded_native_zero"
    ),
    CapacityTimeoutLadder = c("2", "2,8", "10", "0"),
    StrictnessTimeoutLadder = c("2", "2,8", "10", "0"),
    RetryOnlyAfterUnacceptedStage = c(TRUE, TRUE, TRUE, TRUE),
    ParentDeadlineAfterStartMs = c(15000L, 35000L, 30000L, 30000L),
    CandidatePolicy = c(FALSE, TRUE, TRUE, FALSE),
    AttributionReference = c(FALSE, FALSE, FALSE, TRUE),
    ProductionPolicy = c(TRUE, FALSE, FALSE, FALSE),
    EvidenceUse = c(
      "production_replay_calibration", "bounded_retry_calibration",
      "bounded_single_calibration", "os_bounded_attribution_only"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_replay_prespecification <- function() {
  list(
    schema = "mfrmr-jml-recession-replay-prespec-v1",
    source_evidence_schema = "mfrmr-jml-target-positive-cone-completion-v1",
    source_execution_sha256 =
      "7cd2606e4f203cb6afa8f305bafa26a1ea323a20d4bb6408ea615422f111c34d",
    source_inventory_sha256 =
      "845b3d0f51bfd39bddb8e104f31bb71682a4584a893a147d8af7f9e1c82800aa",
    repetitions = 4L,
    isolated_process_per_problem_policy_repetition = TRUE,
    order_rule = paste(
      "four-policy cyclic order by repetition; seven-problem order rotates",
      "and reverses on even repetitions"
    ),
    capacity_and_strictness_recorded_separately = TRUE,
    retry_rule = paste(
      "advance to the next native timeout only after a stage lacks an",
      "accepted status-zero finite original-scale solution"
    ),
    certificate_rule = paste(
      "status zero is necessary but never sufficient; split-box, primal,",
      "objective reconstruction, target floor, and original-scale margin",
      "checks are all required"
    ),
    stability_rule = paste(
      "all four fresh processes complete without a parent kill, preserve one",
      "discrete outcome, and agree numerically within 1e-7*(1+maximum scale)"
    ),
    candidate_rule = paste(
      "a bounded candidate must be stable and safe on all seven problems,",
      "preserve both negative controls, and match a stable completed",
      "OS-bounded native-zero reference on every problem"
    ),
    reference_rule = paste(
      "native timeout zero is attribution only and is forcibly bounded by a",
      "30-second parent deadline after the worker start marker"
    ),
    policy_selection_authorized = FALSE,
    production_change_authorized = FALSE,
    confirmation_authorized = FALSE
  )
}

mfrmr_replay_parse_ladder <- function(x) {
  out <- as.integer(strsplit(as.character(x), ",", fixed = TRUE)[[1L]])
  if (length(out) < 1L || anyNA(out) || any(out < 0L)) stop(
    "Replay timeout ladder is invalid.", call. = FALSE
  )
  out
}

mfrmr_replay_schedule <- function(problem_registry, policy_registry,
                                  repetitions = 4L) {
  problem_ids <- problem_registry$ProblemId
  policy_ids <- policy_registry$PolicyId
  rows <- list(); cursor <- 0L
  for (replicate in seq_len(as.integer(repetitions))) {
    shift <- (replicate - 1L) %% length(problem_ids)
    problem_order <- c(
      problem_ids[(shift + 1L):length(problem_ids)],
      if (shift > 0L) problem_ids[seq_len(shift)] else integer(0)
    )
    if (replicate %% 2L == 0L) problem_order <- rev(problem_order)
    policy_shift <- (replicate - 1L) %% length(policy_ids)
    policy_order <- c(
      policy_ids[(policy_shift + 1L):length(policy_ids)],
      if (policy_shift > 0L) policy_ids[seq_len(policy_shift)] else character(0)
    )
    for (problem_id in problem_order) {
      for (policy_id in policy_order) {
        cursor <- cursor + 1L
        rows[[cursor]] <- data.frame(
          ExecutionOrdinal = cursor, Replicate = replicate,
          ProblemId = problem_id, PolicyId = policy_id,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  out <- do.call(rbind, rows)
  out$ExecutionKeySHA256 <- vapply(seq_len(nrow(out)), function(i) {
    mfrmr_gpcm_repilot_hash_object(list(
      schema = "mfrmr-jml-replay-execution-key-v1",
      replicate = out$Replicate[i], problem_id = out$ProblemId[i],
      policy_id = out$PolicyId[i]
    ))
  }, character(1))
  rownames(out) <- NULL
  out
}

mfrmr_replay_validate_source_bundle <- function(evidence_dir, prespec) {
  evidence_dir <- normalizePath(evidence_dir, winslash = "/", mustWork = TRUE)
  marker_path <- file.path(evidence_dir, "run-complete.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(e) e)
  if (inherits(marker, "error") || !identical(
    marker$schema, prespec$source_evidence_schema
  )) stop("Draft.59 completion marker is invalid.", call. = FALSE)
  if (!identical(
    as.character(marker$execution_sha256), prespec$source_execution_sha256
  ) || !identical(
    as.character(marker$artifact_inventory_sha256),
    prespec$source_inventory_sha256
  )) stop("Draft.59 evidence identity mismatch.", call. = FALSE)
  inventory <- marker$artifacts
  if (!is.data.frame(inventory) || nrow(inventory) != 14L ||
      anyDuplicated(inventory$File)) stop(
    "Draft.59 artifact inventory is invalid.", call. = FALSE
  )
  if (!identical(
    mfrmr_gpcm_repilot_hash_object(inventory),
    as.character(marker$artifact_inventory_sha256)
  )) stop("Draft.59 inventory hash mismatch.", call. = FALSE)
  relative <- gsub("\\\\", "/", as.character(inventory$File))
  unsafe <- !nzchar(relative) | grepl("^(?:[A-Za-z]:|/)", relative) |
    grepl("(?:^|/)\\.\\.(?:/|$)", relative)
  if (any(unsafe)) stop("Draft.59 inventory path is unsafe.", call. = FALSE)
  paths <- file.path(evidence_dir, relative)
  if (any(!file.exists(paths)) || any(dir.exists(paths))) stop(
    "Draft.59 artifact is missing.", call. = FALSE
  )
  observed_hash <- unname(vapply(
    paths, mfrmr_gpcm_repilot_hash_file, character(1)
  ))
  observed_size <- unname(file.info(paths)$size)
  if (!identical(observed_hash, as.character(inventory$SHA256)) ||
      !identical(as.numeric(observed_size), as.numeric(inventory$Bytes))) stop(
    "Draft.59 artifact hash or size mismatch.", call. = FALSE
  )
  problems_path <- file.path(evidence_dir, "target-problems.rds")
  pilot_path <- file.path(evidence_dir, "jml-target-positive-cone-pilot.rds")
  list(
    evidence_dir = evidence_dir, marker = marker, inventory = inventory,
    problems_path = problems_path, pilot_path = pilot_path,
    problems = readRDS(problems_path), pilot = readRDS(pilot_path)
  )
}

mfrmr_replay_select_problems <- function(source, registry) {
  problems <- source$problems
  selected <- lapply(registry$ProblemId, function(problem_id) {
    hit <- problems[vapply(
      problems, function(problem) identical(problem$ProblemId, problem_id),
      logical(1)
    )]
    if (length(hit) != 1L) stop(
      "A frozen replay problem is not unique.", call. = FALSE
    )
    hit[[1L]]
  })
  observed <- data.frame(
    ProblemId = vapply(selected, `[[`, integer(1), "ProblemId"),
    ScenarioId = vapply(selected, `[[`, character(1), "ScenarioId"),
    ProblemSHA256 = vapply(selected, `[[`, character(1), "ProblemSHA256"),
    Model = vapply(selected, `[[`, character(1), "Model"),
    Scope = vapply(selected, `[[`, character(1), "Scope"),
    Parameters = vapply(
      selected, function(problem) problem$lp_base$n_parameters, integer(1)
    ),
    Constraints = vapply(
      selected, function(problem) problem$lp_base$n_constraints, integer(1)
    ),
    StoredNonzeros = vapply(selected, function(problem) {
      as.double(problem$lp_base$stored_constraint_nonzeros)
    }, numeric(1)),
    Draft59Reason = vapply(
      selected, function(problem) as.character(problem$production$reason),
      character(1)
    ),
    Draft59Capacity = vapply(selected, function(problem) {
      as.numeric(problem$production$target_capacity)
    }, numeric(1)),
    stringsAsFactors = FALSE
  )
  if (!identical(observed$ProblemId, registry$ProblemId) ||
      !identical(observed$ScenarioId, registry$ExpectedScenarioId) ||
      !identical(observed$ProblemSHA256, registry$ExpectedProblemSHA256)) stop(
    "Frozen replay problem identity mismatch.", call. = FALSE
  )
  list(problems = selected, observed = cbind(registry, observed[, setdiff(
    names(observed), "ProblemId"
  ), drop = FALSE]))
}

mfrmr_replay_empty_attempts <- function() {
  data.frame(
    Stage = character(0), Attempt = integer(0), NativeTimeoutSeconds = integer(0),
    SolverStatus = integer(0), Objective = numeric(0), ObjectiveFinite = logical(0),
    SolutionFinite = logical(0), SplitBoxValid = logical(0),
    OriginalPrimalMargin = numeric(0), OriginalPrimalValid = logical(0),
    ObjectiveReconstruction = numeric(0),
    ObjectiveReconstructionValid = logical(0),
    CapacityBoundValid = logical(0), TargetFloor = numeric(0),
    TargetFloorValid = logical(0), AttemptAccepted = logical(0),
    DirectionSHA256 = character(0), ElapsedSeconds = numeric(0),
    Error = character(0), stringsAsFactors = FALSE
  )
}

mfrmr_replay_empty_result <- function() {
  data.frame(
    ProblemId = NA_integer_, ScenarioId = NA_character_, Model = NA_character_,
    Scope = NA_character_, ProblemSHA256 = NA_character_,
    PolicyId = NA_character_, WorkerPID = NA_integer_,
    WorkerCompleted = FALSE, ParentKilled = FALSE, ProcessExitStatus = NA_integer_,
    StartedMarkerObserved = FALSE, OutputProduced = FALSE,
    CapacityAttempts = 0L, StrictnessAttempts = 0L,
    FinalCapacityStatus = NA_integer_, FinalStrictnessStatus = NA_integer_,
    TargetCapacity = NA_real_, TargetFloor = NA_real_, Evaluated = FALSE,
    Certified = FALSE, Reason = NA_character_, TargetChange = NA_real_,
    MinimumMargin = NA_real_, PositiveMargin = NA_real_, StrictRows = NA_integer_,
    SafeResult = TRUE, OriginalScaleCertificateValid = FALSE,
    OutcomeSHA256 = NA_character_, WorkerElapsedSeconds = NA_real_,
    ParentElapsedSeconds = NA_real_, Error = NA_character_,
    stringsAsFactors = FALSE
  )
}

mfrmr_replay_write_atomic_rds <- function(value, path) {
  temporary <- paste0(path, ".tmp-", Sys.getpid())
  saveRDS(value, temporary)
  if (file.exists(path)) unlink(path, force = TRUE)
  if (!file.rename(temporary, path)) stop(
    "Atomic replay RDS promotion failed.", call. = FALSE
  )
  invisible(path)
}

mfrmr_replay_attempt <- function(problem, stage, timeout, capacity = NA_real_) {
  stage <- match.arg(stage, c("capacity", "strictness"))
  n <- length(problem$target)
  signed_target <- c(problem$target, -problem$target)
  strict_objective <- as.numeric(Matrix::colSums(
    problem$lp_base$contrast_design
  ))
  objective <- if (identical(stage, "capacity")) {
    signed_target
  } else c(strict_objective, -strict_objective)
  target_floor <- if (identical(stage, "strictness")) {
    max(problem$objective_tolerance * 2, capacity * 1e-5)
  } else NA_real_
  run_fun <- get(
    "mfrmr_jml_recession_run_lp", asNamespace("mfrmr"), inherits = FALSE
  )
  started <- unname(proc.time()[["elapsed"]])
  value <- tryCatch(
    if (identical(stage, "capacity")) {
      run_fun(
        lp_base = problem$lp_base, objective = objective,
        timeout = as.integer(timeout)
      )
    } else {
      run_fun(
        lp_base = problem$lp_base, objective = objective,
        extra_constraint = signed_target, extra_direction = ">=",
        extra_rhs = target_floor, timeout = as.integer(timeout)
      )
    },
    error = function(e) e
  )
  elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
  if (inherits(value, "error")) return(list(
    row = data.frame(
      Stage = stage, Attempt = NA_integer_, NativeTimeoutSeconds = timeout,
      SolverStatus = NA_integer_, Objective = NA_real_,
      ObjectiveFinite = FALSE, SolutionFinite = FALSE, SplitBoxValid = FALSE,
      OriginalPrimalMargin = NA_real_, OriginalPrimalValid = FALSE,
      ObjectiveReconstruction = NA_real_,
      ObjectiveReconstructionValid = FALSE, CapacityBoundValid = FALSE,
      TargetFloor = target_floor, TargetFloorValid = FALSE,
      AttemptAccepted = FALSE, DirectionSHA256 = NA_character_,
      ElapsedSeconds = elapsed, Error = conditionMessage(value),
      stringsAsFactors = FALSE
    ),
    direction = rep(NA_real_, n)
  ))
  status <- as.integer(mfrmr_replay_or(value$status, -1L))
  objective_value <- as.numeric(mfrmr_replay_or(value$objval, NA_real_))
  solution <- as.numeric(mfrmr_replay_or(value$solution, numeric(0)))
  solution_finite <- length(solution) == 2L * n && all(is.finite(solution))
  direction <- rep(NA_real_, n)
  split_box <- FALSE
  primal_margin <- NA_real_
  primal_valid <- FALSE
  reconstruction <- NA_real_
  reconstruction_valid <- FALSE
  target_floor_valid <- identical(stage, "capacity")
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
    reconstruction <- if (identical(stage, "capacity")) {
      sum(problem$target * direction)
    } else sum(strict_objective * direction)
    reconstruction_valid <- is.finite(objective_value) &&
      abs(reconstruction - objective_value) <=
        1e-7 * (1 + abs(objective_value))
    if (identical(stage, "strictness")) {
      target_floor_valid <- is.finite(target_floor) &&
        sum(problem$target * direction) >=
          target_floor - problem$certificate_tolerance
    }
  }
  upper <- sum(abs(problem$target))
  capacity_bound <- if (identical(stage, "capacity")) {
    is.finite(objective_value) && objective_value >= -1e-8 &&
      objective_value <= upper + 1e-7 * (1 + upper)
  } else TRUE
  accepted <- identical(status, 0L) && is.finite(objective_value) &&
    solution_finite && split_box && primal_valid && reconstruction_valid &&
    capacity_bound && target_floor_valid
  list(
    row = data.frame(
      Stage = stage, Attempt = NA_integer_, NativeTimeoutSeconds = timeout,
      SolverStatus = status, Objective = objective_value,
      ObjectiveFinite = is.finite(objective_value),
      SolutionFinite = solution_finite, SplitBoxValid = split_box,
      OriginalPrimalMargin = primal_margin, OriginalPrimalValid = primal_valid,
      ObjectiveReconstruction = reconstruction,
      ObjectiveReconstructionValid = reconstruction_valid,
      CapacityBoundValid = capacity_bound, TargetFloor = target_floor,
      TargetFloorValid = target_floor_valid, AttemptAccepted = accepted,
      DirectionSHA256 = if (all(is.finite(direction))) {
        mfrmr_gpcm_repilot_hash_object(direction)
      } else NA_character_,
      ElapsedSeconds = elapsed, Error = NA_character_,
      stringsAsFactors = FALSE
    ),
    direction = direction
  )
}

mfrmr_replay_write_attempt <- function(row, journal_dir, ordinal) {
  path <- file.path(journal_dir, sprintf("attempt-%03d.rds", ordinal))
  mfrmr_replay_write_atomic_rds(row, path)
}

mfrmr_replay_stage <- function(problem, stage, ladder, journal_dir,
                               attempt_offset = 0L, capacity = NA_real_) {
  rows <- list(); accepted <- NULL
  for (attempt in seq_along(ladder)) {
    value <- mfrmr_replay_attempt(
      problem, stage, ladder[attempt], capacity = capacity
    )
    value$row$Attempt <- attempt
    rows[[attempt]] <- value$row
    mfrmr_replay_write_attempt(
      value$row, journal_dir, attempt_offset + attempt
    )
    if (isTRUE(value$row$AttemptAccepted)) {
      accepted <- value
      break
    }
  }
  list(
    rows = do.call(rbind, rows), accepted = accepted,
    attempted = length(rows)
  )
}

mfrmr_replay_run_worker_job <- function(job, problem) {
  policy <- job$policy
  capacity_ladder <- mfrmr_replay_parse_ladder(
    policy$CapacityTimeoutLadder
  )
  strict_ladder <- mfrmr_replay_parse_ladder(
    policy$StrictnessTimeoutLadder
  )
  started <- unname(proc.time()[["elapsed"]])
  capacity <- mfrmr_replay_stage(
    problem, "capacity", capacity_ladder, job$journal_dir
  )
  attempts <- capacity$rows
  capacity_value <- capacity$accepted
  strict <- NULL
  if (is.null(capacity_value)) {
    evaluated <- FALSE; certified <- FALSE
    reason <- "linear_program_capacity_failed"
    capacity_objective <- NA_real_; target_floor <- NA_real_
    target_change <- NA_real_; minimum_margin <- NA_real_
    positive_margin <- NA_real_; strict_rows <- NA_integer_
    final_capacity_status <- tail(capacity$rows$SolverStatus, 1L)
    final_strict_status <- NA_integer_; certificate_valid <- FALSE
  } else {
    capacity_objective <- capacity_value$row$Objective
    final_capacity_status <- capacity_value$row$SolverStatus
    if (capacity_objective <= 10 * problem$objective_tolerance) {
      evaluated <- TRUE; certified <- FALSE
      reason <- "no_target_recession_direction"
      target_floor <- NA_real_; target_change <- 0
      minimum_margin <- 0; positive_margin <- 0; strict_rows <- 0L
      final_strict_status <- NA_integer_; certificate_valid <- TRUE
    } else {
      target_floor <- max(
        problem$objective_tolerance * 2, capacity_objective * 1e-5
      )
      strict <- mfrmr_replay_stage(
        problem, "strictness", strict_ladder, job$journal_dir,
        attempt_offset = capacity$attempted, capacity = capacity_objective
      )
      attempts <- rbind(attempts, strict$rows)
      if (is.null(strict$accepted)) {
        evaluated <- FALSE; certified <- FALSE
        reason <- "linear_program_strictness_failed"
        target_change <- NA_real_; minimum_margin <- NA_real_
        positive_margin <- NA_real_; strict_rows <- NA_integer_
        final_strict_status <- tail(strict$rows$SolverStatus, 1L)
        certificate_valid <- FALSE
      } else {
        direction <- strict$accepted$direction
        margins <- as.numeric(problem$lp_base$contrast_design %*% direction)
        target_change <- sum(problem$target * direction)
        minimum_margin <- min(margins)
        positive_margin <- sum(pmax(margins, 0))
        strict_rows <- sum(margins > problem$certificate_tolerance)
        certified <- is.finite(target_change) &&
          target_change > problem$objective_tolerance &&
          is.finite(minimum_margin) &&
          minimum_margin >= -problem$certificate_tolerance &&
          is.finite(positive_margin) &&
          positive_margin > problem$objective_tolerance && strict_rows > 0L
        evaluated <- TRUE
        reason <- if (certified) {
          "certified_additive_recession_direction"
        } else "candidate_failed_postsolve_certificate"
        final_strict_status <- strict$accepted$row$SolverStatus
        certificate_valid <- isTRUE(certified)
      }
    }
  }
  result <- mfrmr_replay_empty_result()
  result$ProblemId <- problem$ProblemId
  result$ScenarioId <- problem$ScenarioId
  result$Model <- problem$Model
  result$Scope <- problem$Scope
  result$ProblemSHA256 <- problem$ProblemSHA256
  result$PolicyId <- as.character(policy$PolicyId)
  result$WorkerPID <- Sys.getpid()
  result$WorkerCompleted <- TRUE
  result$CapacityAttempts <- capacity$attempted
  result$StrictnessAttempts <- if (is.null(strict)) 0L else strict$attempted
  result$FinalCapacityStatus <- final_capacity_status
  result$FinalStrictnessStatus <- final_strict_status
  result$TargetCapacity <- capacity_objective
  result$TargetFloor <- target_floor
  result$Evaluated <- evaluated
  result$Certified <- certified
  result$Reason <- reason
  result$TargetChange <- target_change
  result$MinimumMargin <- minimum_margin
  result$PositiveMargin <- positive_margin
  result$StrictRows <- strict_rows
  result$SafeResult <- !isTRUE(certified) || isTRUE(certificate_valid)
  result$OriginalScaleCertificateValid <- certificate_valid
  result$WorkerElapsedSeconds <- max(
    0, unname(proc.time()[["elapsed"]]) - started
  )
  result$OutcomeSHA256 <- mfrmr_gpcm_repilot_hash_object(list(
    schema = "mfrmr-jml-replay-outcome-v1", evaluated = evaluated,
    certified = certified, reason = reason,
    capacity = if (is.finite(capacity_objective)) capacity_objective else NA_real_,
    target_change = if (is.finite(target_change)) target_change else NA_real_,
    minimum_margin = if (is.finite(minimum_margin)) minimum_margin else NA_real_,
    positive_margin = if (is.finite(positive_margin)) positive_margin else NA_real_,
    strict_rows = strict_rows
  ))
  list(result = result, attempts = attempts)
}

mfrmr_replay_worker_paths <- function(work_dir, ordinal) {
  root <- file.path(work_dir, sprintf("execution-%04d", ordinal))
  list(
    root = root, job = file.path(root, "job.rds"),
    output = file.path(root, "output.rds"),
    started = file.path(root, "started.rds"),
    journal = file.path(root, "journal"),
    stdout = file.path(root, "stdout.txt"),
    stderr = file.path(root, "stderr.txt"),
    checkpoint = file.path(work_dir, sprintf("checkpoint-%04d.rds", ordinal))
  )
}

mfrmr_replay_worker_job <- function(schedule_row, policy_row, problem_path,
                                    paths, plan_sha256) {
  list(
    schema = "mfrmr-jml-replay-worker-job-v1",
    execution_key_sha256 = schedule_row$ExecutionKeySHA256,
    execution_ordinal = schedule_row$ExecutionOrdinal,
    replicate = schedule_row$Replicate,
    problem_id = schedule_row$ProblemId,
    problem_path = problem_path,
    expected_problem_sha256 = schedule_row$ProblemSHA256,
    policy = policy_row,
    plan_sha256 = plan_sha256,
    lib_paths = .libPaths(),
    mfrmr_lib = dirname(system.file(package = "mfrmr")),
    runner_path = file.path(
      mfrmr_replay_source_dir,
      "jml-recession-replay-policy-pilot-0.2.3.R"
    ),
    output_path = paths$output, started_path = paths$started,
    journal_dir = paths$journal
  )
}

mfrmr_replay_collect_journal <- function(paths) {
  files <- sort(list.files(
    paths$journal, pattern = "^attempt-[0-9]+\\.rds$", full.names = TRUE
  ))
  if (length(files) == 0L) return(mfrmr_replay_empty_attempts())
  values <- lapply(files, function(path) tryCatch(readRDS(path), error = identity))
  values <- values[!vapply(values, inherits, logical(1), "error")]
  if (length(values) == 0L) return(mfrmr_replay_empty_attempts())
  do.call(rbind, values)
}

mfrmr_replay_execute_one <- function(schedule_row, policy_row, problem_path,
                                     paths, plan_sha256) {
  dir.create(paths$root, recursive = TRUE, showWarnings = FALSE)
  dir.create(paths$journal, recursive = TRUE, showWarnings = FALSE)
  job <- mfrmr_replay_worker_job(
    schedule_row, policy_row, problem_path, paths, plan_sha256
  )
  mfrmr_replay_write_atomic_rds(job, paths$job)
  worker <- file.path(
    mfrmr_replay_source_dir,
    "jml-recession-replay-policy-worker-0.2.3.R"
  )
  rscript <- file.path(R.home("bin"), "Rscript.exe")
  if (!file.exists(rscript)) rscript <- file.path(R.home("bin"), "Rscript")
  parent_started <- unname(proc.time()[["elapsed"]])
  process <- processx::process$new(
    rscript, c(worker, paths$job), stdout = paths$stdout,
    stderr = paths$stderr, cleanup_tree = TRUE
  )
  start_wait <- Sys.time()
  while (process$is_alive() && !file.exists(paths$started) &&
         as.numeric(difftime(Sys.time(), start_wait, units = "secs")) < 30) {
    Sys.sleep(0.05)
  }
  started <- file.exists(paths$started)
  if (started && process$is_alive()) process$wait(
    timeout = as.integer(policy_row$ParentDeadlineAfterStartMs)
  )
  killed <- FALSE
  if (process$is_alive()) {
    process$kill_tree()
    killed <- TRUE
    process$wait(timeout = 5000L)
  }
  exit_status <- process$get_exit_status()
  output_produced <- file.exists(paths$output)
  value <- if (output_produced) tryCatch(
    readRDS(paths$output), error = identity
  ) else NULL
  valid <- !is.null(value) && !inherits(value, "error") &&
    identical(value$schema, "mfrmr-jml-replay-worker-v1") &&
    identical(value$execution_key_sha256, schedule_row$ExecutionKeySHA256) &&
    identical(value$plan_sha256, plan_sha256) &&
    is.data.frame(value$result) && nrow(value$result) == 1L
  attempts <- if (valid) value$attempts else mfrmr_replay_collect_journal(paths)
  result <- if (valid) value$result else mfrmr_replay_empty_result()
  if (!valid) {
    result$ProblemId <- schedule_row$ProblemId
    result$ScenarioId <- schedule_row$ScenarioId
    result$Model <- schedule_row$Model
    result$Scope <- schedule_row$Scope
    result$ProblemSHA256 <- schedule_row$ProblemSHA256
    result$PolicyId <- schedule_row$PolicyId
    result$Reason <- if (killed) {
      "parent_os_deadline"
    } else if (!started) "worker_start_failed" else "worker_output_invalid"
    result$Error <- if (inherits(value, "error")) conditionMessage(value) else {
      NA_character_
    }
  }
  result$WorkerCompleted <- valid
  result$ParentKilled <- killed
  result$ProcessExitStatus <- as.integer(mfrmr_replay_or(
    exit_status, NA_integer_
  ))
  result$StartedMarkerObserved <- started
  result$OutputProduced <- output_produced
  result$ParentElapsedSeconds <- max(
    0, unname(proc.time()[["elapsed"]]) - parent_started
  )
  logs <- paste(c(
    if (file.exists(paths$stdout)) readLines(paths$stdout, warn = FALSE),
    if (file.exists(paths$stderr)) readLines(paths$stderr, warn = FALSE)
  ), collapse = " | ")
  result <- cbind(
    schedule_row[, c(
      "ExecutionOrdinal", "ExecutionKeySHA256", "Replicate"
    ), drop = FALSE],
    result
  )
  if (nrow(attempts) > 0L) attempts <- cbind(
    schedule_row[, c(
      "ExecutionOrdinal", "ExecutionKeySHA256", "Replicate", "ProblemId",
      "PolicyId"
    ), drop = FALSE][rep(1L, nrow(attempts)), , drop = FALSE],
    attempts
  )
  list(
    schema = "mfrmr-jml-replay-checkpoint-v1",
    execution_key_sha256 = schedule_row$ExecutionKeySHA256,
    plan_sha256 = plan_sha256, result = result, attempts = attempts,
    log = data.frame(
      ExecutionOrdinal = schedule_row$ExecutionOrdinal,
      ExecutionKeySHA256 = schedule_row$ExecutionKeySHA256,
      StartedMarkerObserved = started, ParentKilled = killed,
      ExitStatus = as.integer(mfrmr_replay_or(exit_status, NA_integer_)),
      OutputProduced = output_produced, WorkerResultValid = valid,
      Logs = logs, stringsAsFactors = FALSE
    )
  )
}

mfrmr_replay_numeric_stable <- function(x, tolerance = 1e-7) {
  x <- as.numeric(x)
  finite <- is.finite(x)
  if (!any(finite)) return(all(is.na(x) | is.nan(x)))
  if (!all(finite)) return(FALSE)
  diff(range(x)) <= tolerance * (1 + max(abs(x)))
}

mfrmr_replay_cell_stability <- function(results) {
  keys <- unique(results[, c("PolicyId", "ProblemId"), drop = FALSE])
  rows <- lapply(seq_len(nrow(keys)), function(i) {
    cell <- results[
      results$PolicyId == keys$PolicyId[i] &
        results$ProblemId == keys$ProblemId[i], , drop = FALSE
    ]
    discrete <- all(cell$WorkerCompleted) && !any(cell$ParentKilled) &&
      length(unique(paste(
        cell$Evaluated, cell$Certified, cell$Reason,
        cell$FinalCapacityStatus, cell$FinalStrictnessStatus, sep = "|"
      ))) == 1L
    numeric <- mfrmr_replay_numeric_stable(cell$TargetCapacity) &&
      mfrmr_replay_numeric_stable(cell$TargetChange) &&
      mfrmr_replay_numeric_stable(cell$MinimumMargin) &&
      mfrmr_replay_numeric_stable(cell$PositiveMargin)
    data.frame(
      PolicyId = keys$PolicyId[i], ProblemId = keys$ProblemId[i],
      Repetitions = nrow(cell), Completed = sum(cell$WorkerCompleted),
      ParentKills = sum(cell$ParentKilled), SafeResults = sum(cell$SafeResult),
      DiscreteStable = discrete, NumericStable = numeric,
      CellStable = nrow(cell) == 4L && discrete && numeric &&
        all(cell$SafeResult),
      OutcomeCount = length(unique(cell$OutcomeSHA256[!is.na(
        cell$OutcomeSHA256
      )])),
      RepresentativeReason = if (discrete) cell$Reason[1L] else "mixed",
      RepresentativeCapacity = if (numeric) cell$TargetCapacity[1L] else NA_real_,
      RepresentativeCertified = if (discrete) cell$Certified[1L] else FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_replay_reference_match <- function(candidate, reference) {
  if (nrow(candidate) != 1L || nrow(reference) != 1L ||
      !candidate$CellStable || !reference$CellStable) return(FALSE)
  discrete <- identical(
    as.character(candidate$RepresentativeReason),
    as.character(reference$RepresentativeReason)
  ) && identical(
    as.logical(candidate$RepresentativeCertified),
    as.logical(reference$RepresentativeCertified)
  )
  capacity <- mfrmr_replay_numeric_stable(c(
    candidate$RepresentativeCapacity, reference$RepresentativeCapacity
  ))
  discrete && capacity
}

mfrmr_replay_policy_summary <- function(results, cells, policies, problems) {
  reference_id <- policies$PolicyId[policies$AttributionReference]
  rows <- lapply(seq_len(nrow(policies)), function(i) {
    policy <- policies[i, , drop = FALSE]
    policy_results <- results[results$PolicyId == policy$PolicyId, , drop = FALSE]
    policy_cells <- cells[cells$PolicyId == policy$PolicyId, , drop = FALSE]
    reference_matches <- vapply(problems$ProblemId, function(problem_id) {
      mfrmr_replay_reference_match(
        policy_cells[policy_cells$ProblemId == problem_id, , drop = FALSE],
        cells[cells$PolicyId == reference_id & cells$ProblemId == problem_id,
              , drop = FALSE]
      )
    }, logical(1))
    negative_ids <- problems$ProblemId[problems$NegativeControl]
    negative_preserved <- all(vapply(negative_ids, function(problem_id) {
      cell_results <- policy_results[policy_results$ProblemId == problem_id,
                                     , drop = FALSE]
      nrow(cell_results) == 4L && all(cell_results$WorkerCompleted) &&
        all(cell_results$Reason == "no_target_recession_direction") &&
        !any(cell_results$Certified)
    }, logical(1)))
    all_cells_stable <- nrow(policy_cells) == nrow(problems) &&
      all(policy_cells$CellStable)
    reference_stable <- all(cells$CellStable[cells$PolicyId == reference_id])
    pilot_qualified <- isTRUE(policy$CandidatePolicy) && all_cells_stable &&
      all(policy_results$SafeResult) && negative_preserved &&
      reference_stable && all(reference_matches)
    data.frame(
      PolicyId = policy$PolicyId, Executions = nrow(policy_results),
      WorkerCompleted = sum(policy_results$WorkerCompleted),
      ParentKills = sum(policy_results$ParentKilled),
      SafeResults = sum(policy_results$SafeResult),
      StableCells = sum(policy_cells$CellStable),
      TotalCells = nrow(policy_cells),
      NegativeControlsPreserved = negative_preserved,
      ReferenceStable = reference_stable,
      ReferenceMatches = sum(reference_matches),
      CandidatePolicy = policy$CandidatePolicy,
      AttributionReference = policy$AttributionReference,
      PilotQualified = pilot_qualified,
      PolicySelectionAuthorized = FALSE,
      ProductionChangeAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_run_jml_recession_replay_policy <- function(
    dry_run = TRUE, authorize = FALSE, evidence_dir = NULL,
    output_dir = NULL, progress = interactive()) {
  mfrmr_replay_require_support()
  capabilities <- mfrmr_replay_capabilities()
  prespec <- mfrmr_replay_prespecification()
  problem_registry <- mfrmr_replay_problem_registry()
  policies <- mfrmr_replay_policy_registry()
  schedule <- mfrmr_replay_schedule(
    problem_registry, policies, prespec$repetitions
  )
  runner_files <- c(
    "jml-recession-replay-policy-pilot-0.2.3.R",
    "jml-recession-replay-policy-worker-0.2.3.R",
    "jml-target-positive-cone-pilot-0.2.3.R"
  )
  source_identity <- data.frame(
    Component = c("replay_runner", "isolated_worker", "draft59_runner"),
    File = runner_files,
    SHA256 = vapply(
      file.path(mfrmr_replay_source_dir, runner_files),
      mfrmr_gpcm_repilot_hash_file, character(1)
    ),
    stringsAsFactors = FALSE
  )
  if (isTRUE(dry_run)) return(list(
    schema = "mfrmr-jml-recession-replay-policy-pilot-v1",
    prespecification = prespec, problem_registry = problem_registry,
    policy_registry = policies, schedule = schedule,
    capabilities = capabilities, source_identity = source_identity,
    policy_selection_authorized = FALSE,
    production_change_authorized = FALSE,
    confirmation_authorized = FALSE
  ))
  if (!isTRUE(authorize)) stop(
    "Live replay-policy execution requires `authorize = TRUE`.",
    call. = FALSE
  )
  if (any(!capabilities$Available)) stop(
    "Live replay-policy execution lacks required capabilities: ",
    paste(capabilities$Capability[!capabilities$Available], collapse = ", "),
    call. = FALSE
  )
  if (is.null(evidence_dir) || length(evidence_dir) != 1L ||
      is.na(evidence_dir) || !nzchar(evidence_dir)) stop(
    "Live replay-policy execution requires one `evidence_dir`.",
    call. = FALSE
  )
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) stop(
    "Live replay-policy execution requires one `output_dir`.",
    call. = FALSE
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  if (file.exists(output_dir) || dir.exists(output_dir)) stop(
    "`output_dir` must not already exist.", call. = FALSE
  )
  source <- mfrmr_replay_validate_source_bundle(evidence_dir, prespec)
  selected <- mfrmr_replay_select_problems(source, problem_registry)
  observed_registry <- selected$observed
  schedule <- merge(
    schedule,
    observed_registry[, c(
      "ProblemId", "ScenarioId", "Model", "Scope", "ProblemSHA256"
    )],
    by = "ProblemId", all.x = TRUE, sort = FALSE
  )
  schedule <- schedule[order(schedule$ExecutionOrdinal), , drop = FALSE]
  schedule <- merge(
    schedule,
    policies[, c("PolicyId", "ParentDeadlineAfterStartMs")],
    by = "PolicyId", all.x = TRUE, sort = FALSE
  )
  schedule <- schedule[order(schedule$ExecutionOrdinal), , drop = FALSE]
  rownames(schedule) <- NULL
  package_identity <- mfrmr_gpcm_repilot_package_content_identity("mfrmr")
  source_evidence_identity <- data.frame(
    Schema = source$marker$schema,
    ExecutionSHA256 = source$marker$execution_sha256,
    ArtifactInventorySHA256 = source$marker$artifact_inventory_sha256,
    TargetProblemsSHA256 = mfrmr_gpcm_repilot_hash_file(source$problems_path),
    PilotRdsSHA256 = mfrmr_gpcm_repilot_hash_file(source$pilot_path),
    stringsAsFactors = FALSE
  )
  plan <- list(
    schema = "mfrmr-jml-recession-replay-plan-v1",
    prespecification = prespec, problem_registry = observed_registry,
    policy_registry = policies, schedule = schedule,
    source_identity = source_identity, capabilities = capabilities,
    source_evidence_identity = source_evidence_identity,
    installed_package_sha256 = package_identity$PackageSHA256,
    r_version = R.version.string, platform = R.version$platform
  )
  plan_sha256 <- mfrmr_gpcm_repilot_hash_object(plan)
  staging <- paste0(output_dir, ".incomplete")
  work_dir <- file.path(staging, "work")
  state_path <- file.path(staging, "run-state.rds")
  if (dir.exists(staging)) {
    state <- tryCatch(readRDS(state_path), error = identity)
    if (inherits(state, "error") || !identical(
      state$schema, "mfrmr-jml-recession-replay-state-v1"
    ) || !identical(state$plan_sha256, plan_sha256)) stop(
      "Existing replay checkpoint does not match this plan.", call. = FALSE
    )
  } else {
    dir.create(work_dir, recursive = TRUE)
    mfrmr_replay_write_atomic_rds(list(
      schema = "mfrmr-jml-recession-replay-state-v1",
      plan_sha256 = plan_sha256,
      created_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ), state_path)
  }
  dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)
  problem_paths <- setNames(character(length(selected$problems)),
                            observed_registry$ProblemId)
  for (i in seq_along(selected$problems)) {
    path <- file.path(
      work_dir, sprintf("problem-%03d.rds", observed_registry$ProblemId[i])
    )
    if (!file.exists(path)) mfrmr_replay_write_atomic_rds(
      selected$problems[[i]], path
    )
    problem_paths[as.character(observed_registry$ProblemId[i])] <- path
  }
  checkpoints <- vector("list", nrow(schedule))
  for (i in seq_len(nrow(schedule))) {
    schedule_row <- schedule[i, , drop = FALSE]
    policy_row <- policies[policies$PolicyId == schedule_row$PolicyId,
                           , drop = FALSE]
    paths <- mfrmr_replay_worker_paths(work_dir, schedule_row$ExecutionOrdinal)
    checkpoint <- if (file.exists(paths$checkpoint)) tryCatch(
      readRDS(paths$checkpoint), error = identity
    ) else NULL
    valid_checkpoint <- !is.null(checkpoint) && !inherits(checkpoint, "error") &&
      identical(checkpoint$schema, "mfrmr-jml-replay-checkpoint-v1") &&
      identical(checkpoint$execution_key_sha256,
                schedule_row$ExecutionKeySHA256) &&
      identical(checkpoint$plan_sha256, plan_sha256)
    if (!valid_checkpoint) {
      if (isTRUE(progress)) message(
        "[replay ", i, "/", nrow(schedule), "] rep=", schedule_row$Replicate,
        " problem=", schedule_row$ProblemId, " policy=", schedule_row$PolicyId
      )
      checkpoint <- mfrmr_replay_execute_one(
        schedule_row, policy_row,
        problem_paths[as.character(schedule_row$ProblemId)],
        paths, plan_sha256
      )
      mfrmr_replay_write_atomic_rds(checkpoint, paths$checkpoint)
    } else if (isTRUE(progress)) message(
      "[replay ", i, "/", nrow(schedule), "] checkpoint reused"
    )
    checkpoints[[i]] <- checkpoint
  }
  results <- do.call(rbind, lapply(checkpoints, `[[`, "result"))
  attempt_values <- lapply(checkpoints, `[[`, "attempts")
  attempts <- if (all(vapply(attempt_values, nrow, integer(1)) == 0L)) {
    mfrmr_replay_empty_attempts()
  } else do.call(rbind, attempt_values[vapply(
    attempt_values, nrow, integer(1)
  ) > 0L])
  logs <- do.call(rbind, lapply(checkpoints, `[[`, "log"))
  rownames(results) <- rownames(attempts) <- rownames(logs) <- NULL
  cells <- mfrmr_replay_cell_stability(results)
  policy_summary <- mfrmr_replay_policy_summary(
    results, cells, policies, observed_registry
  )
  problem_summary <- do.call(rbind, lapply(
    observed_registry$ProblemId, function(problem_id) {
      cell <- cells[cells$ProblemId == problem_id, , drop = FALSE]
      data.frame(
        ProblemId = problem_id,
        StablePolicies = sum(cell$CellStable), TotalPolicies = nrow(cell),
        ProductionStable = cell$CellStable[
          cell$PolicyId == "production_2s"
        ],
        ReferenceStable = cell$CellStable[
          cell$PolicyId == "os_bounded_native_zero"
        ],
        stringsAsFactors = FALSE
      )
    }
  ))
  rownames(problem_summary) <- NULL
  candidate_qualified <- any(policy_summary$PilotQualified)
  production <- policy_summary[
    policy_summary$PolicyId == "production_2s", , drop = FALSE
  ]
  replay_instability_reproduced <- production$StableCells <
    production$TotalCells || production$ReferenceMatches <
    production$TotalCells
  execution_identity <- data.frame(
    Schema = "mfrmr-jml-recession-replay-identity-v1",
    PlanSHA256 = plan_sha256,
    PrespecificationSHA256 = mfrmr_gpcm_repilot_hash_object(prespec),
    ProblemRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(observed_registry),
    PolicyRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(policies),
    ScheduleSHA256 = mfrmr_gpcm_repilot_hash_object(schedule),
    SourceIdentitySHA256 = mfrmr_gpcm_repilot_hash_object(source_identity),
    CapabilityManifestSHA256 = mfrmr_gpcm_repilot_hash_object(capabilities),
    SourceEvidenceIdentitySHA256 =
      mfrmr_gpcm_repilot_hash_object(source_evidence_identity),
    ResultSHA256 = mfrmr_gpcm_repilot_hash_object(results),
    AttemptSHA256 = mfrmr_gpcm_repilot_hash_object(attempts),
    CellStabilitySHA256 = mfrmr_gpcm_repilot_hash_object(cells),
    PolicySummarySHA256 = mfrmr_gpcm_repilot_hash_object(policy_summary),
    InstalledPackageSHA256 = package_identity$PackageSHA256,
    BoundedPolicyPilotQualified = candidate_qualified,
    PolicyContinuationAuthorized = candidate_qualified,
    PolicySelectionAuthorized = FALSE,
    ProductionChangeAuthorized = FALSE,
    ReplayBlockerResolved = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution_identity$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(
    execution_identity
  )
  run_summary <- data.frame(
    Schema = "mfrmr-jml-recession-replay-policy-pilot-v1",
    Problems = nrow(observed_registry), Policies = nrow(policies),
    Repetitions = prespec$repetitions, ScheduledExecutions = nrow(schedule),
    WorkerCompleted = sum(results$WorkerCompleted),
    ParentKills = sum(results$ParentKilled),
    SafeResults = sum(results$SafeResult),
    AttemptRows = nrow(attempts), StableCells = sum(cells$CellStable),
    TotalCells = nrow(cells),
    ProductionStableCells = production$StableCells,
    ProductionReferenceMatches = production$ReferenceMatches,
    QualifiedBoundedPolicies = sum(policy_summary$PilotQualified),
    ReplayInstabilityReproduced = replay_instability_reproduced,
    BoundedPolicyPilotQualified = candidate_qualified,
    PolicyContinuationAuthorized = candidate_qualified,
    PolicySelectionAuthorized = FALSE,
    ProductionChangeAuthorized = FALSE,
    ReplayBlockerResolved = FALSE,
    RuntimeCriterionFrozen = FALSE,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "fresh_process_replay_policy_calibration_only",
    stringsAsFactors = FALSE
  )
  completion_valid <- nrow(results) == nrow(schedule) &&
    nrow(cells) == nrow(observed_registry) * nrow(policies) &&
    all(results$SafeResult) &&
    !any(policy_summary$PolicySelectionAuthorized) &&
    !any(policy_summary$ProductionChangeAuthorized) &&
    !execution_identity$ReplayBlockerResolved &&
    !execution_identity$ConfirmationAuthorized
  if (!completion_valid) stop(
    "Replay-policy evidence did not complete safely.", call. = FALSE
  )
  output <- list(
    schema = "mfrmr-jml-recession-replay-policy-pilot-v1",
    prespecification = prespec, problem_registry = observed_registry,
    policy_registry = policies, schedule = schedule, results = results,
    attempts = attempts, cell_stability = cells,
    policy_summary = policy_summary, problem_summary = problem_summary,
    logs = logs, capabilities = capabilities,
    source_identity = source_identity,
    source_evidence_identity = source_evidence_identity,
    package_identity = package_identity,
    execution_identity = execution_identity, run_summary = run_summary,
    replay_instability_reproduced = replay_instability_reproduced,
    bounded_policy_pilot_qualified = candidate_qualified,
    policy_continuation_authorized = candidate_qualified,
    policy_selection_authorized = FALSE,
    production_change_authorized = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    `problem-registry.csv` = observed_registry,
    `policy-registry.csv` = policies,
    `execution-schedule.csv` = schedule,
    `replay-results.csv` = results,
    `stage-attempts.csv` = attempts,
    `cell-stability.csv` = cells,
    `policy-summary.csv` = policy_summary,
    `problem-summary.csv` = problem_summary,
    `process-logs.csv` = logs,
    `capabilities.csv` = capabilities,
    `source-identity.csv` = source_identity,
    `source-evidence-identity.csv` = source_evidence_identity,
    `package-identity.csv` = package_identity,
    `execution-identity.csv` = execution_identity,
    `run-summary.csv` = run_summary
  )
  for (name in names(files)) utils::write.csv(
    files[[name]], file.path(staging, name), row.names = FALSE, na = ""
  )
  saveRDS(output, file.path(staging, "jml-recession-replay-policy-pilot.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  work_root <- normalizePath(work_dir, winslash = "/", mustWork = TRUE)
  staging_root <- normalizePath(staging, winslash = "/", mustWork = TRUE)
  if (!startsWith(work_root, paste0(staging_root, "/"))) stop(
    "Replay work directory escaped staging.", call. = FALSE
  )
  invisible(gc())
  for (cleanup_attempt in seq_len(5L)) {
    unlink(work_root, recursive = TRUE, force = TRUE)
    if (!dir.exists(work_root) && !file.exists(work_root)) break
    Sys.sleep(0.2)
    invisible(gc())
  }
  if (dir.exists(work_root) || file.exists(work_root)) stop(
    "Replay work directory could not be removed before promotion.",
    call. = FALSE
  )
  unlink(state_path, force = TRUE)
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  marker <- list(
    schema = "mfrmr-jml-recession-replay-completion-v1",
    execution_sha256 = execution_identity$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    replay_instability_reproduced = replay_instability_reproduced,
    bounded_policy_pilot_qualified = candidate_qualified,
    policy_continuation_authorized = candidate_qualified,
    policy_selection_authorized = FALSE,
    production_change_authorized = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) stop(
    "Completed replay-policy evidence could not be promoted.", call. = FALSE
  )
  invisible(output)
}
