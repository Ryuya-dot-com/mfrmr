# Repository-only LP attribution and independent-solver parity pilot for the
# mfrmr 0.2.3 JML additive recession audits. Independent GLPK results are
# diagnostic only and are never returned to a fit or readiness decision.

mfrmr_jml_lp_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("jml-lp-attribution-pilot-0\\.2\\.3\\.R$", files)]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path("inst", "validation", "jml-lp-attribution-pilot-0.2.3.R"),
    "jml-lp-attribution-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_jml_lp_or <- function(x, replacement) {
  if (is.null(x)) replacement else x
}

mfrmr_jml_lp_require_support <- function() {
  target_env <- environment(mfrmr_jml_lp_require_support)
  required <- c(
    "mfrmr_jml_phase_require_support", "mfrmr_jml_phase_registry",
    "mfrmr_jml_phase_identity", "mfrmr_jml_phase_run_route",
    "mfrmr_jml_profile_cells", "mfrmr_jml_profile_build",
    "mfrmr_jml_component_compare_baseline",
    "mfrmr_target_scale_artifact_inventory",
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file"
  )
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    phase_candidates <- c(
      if (!is.na(mfrmr_jml_lp_source_dir)) {
        file.path(
          mfrmr_jml_lp_source_dir,
          "jml-phase-profile-pilot-0.2.3.R"
        )
      } else character(0),
      file.path(
        "inst", "validation",
        "jml-phase-profile-pilot-0.2.3.R"
      ),
      "jml-phase-profile-pilot-0.2.3.R"
    )
    phase_path <- phase_candidates[file.exists(phase_candidates)][1L]
    if (is.na(phase_path)) {
      stop("Cannot locate JML phase-profile support.", call. = FALSE)
    }
    sys.source(phase_path, envir = target_env)
    mfrmr_jml_phase_require_support()

    component_candidates <- c(
      if (!is.na(mfrmr_jml_lp_source_dir)) {
        file.path(
          mfrmr_jml_lp_source_dir,
          "jml-recession-component-profile-pilot-0.2.3.R"
        )
      } else character(0),
      file.path(
        "inst", "validation",
        "jml-recession-component-profile-pilot-0.2.3.R"
      ),
      "jml-recession-component-profile-pilot-0.2.3.R"
    )
    component_path <- component_candidates[
      file.exists(component_candidates)
    ][1L]
    if (is.na(component_path)) {
      stop("Cannot locate JML component-profile support.", call. = FALSE)
    }
    sys.source(component_path, envir = target_env)
    mfrmr_jml_component_require_support()
  }
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("JML LP-attribution support did not load completely.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_jml_lp_capabilities <- function() {
  packages <- c("mfrmr", "Matrix", "digest", "lpSolve", "slam", "Rglpk")
  available <- vapply(
    packages, requireNamespace, logical(1), quietly = TRUE
  )
  data.frame(
    Capability = packages,
    Available = available,
    Version = vapply(packages, function(package) {
      if (requireNamespace(package, quietly = TRUE)) {
        as.character(utils::packageVersion(package))
      } else {
        NA_character_
      }
    }, character(1)),
    RuntimeSHA256 = vapply(seq_along(packages), function(i) {
      if (available[i]) {
        mfrmr_gpcm_repilot_package_content_identity(
          packages[i]
        )$PackageSHA256
      } else {
        NA_character_
      }
    }, character(1)),
    Role = c(
      "runtime_under_review", "sparse_geometry", "artifact_identity",
      "production_lp", "independent_sparse_triplet", "independent_glpk"
    ),
    RequiredForLivePilot = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_lp_validate_baseline <- function(baseline_dir) {
  marker_path <- file.path(baseline_dir, "run-complete.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(e) e)
  if (inherits(marker, "error") || !identical(
    marker$schema, "mfrmr-jml-recession-component-profile-completion-v1"
  )) {
    stop("The Draft.55 component baseline marker is invalid.",
         call. = FALSE)
  }
  artifacts <- as.data.frame(marker$artifacts, stringsAsFactors = FALSE)
  valid <- nrow(artifacts) > 0L && all(vapply(
    seq_len(nrow(artifacts)), function(i) {
      path <- file.path(baseline_dir, artifacts$File[i])
      file.exists(path) && identical(
        unname(file.info(path)$size), as.numeric(artifacts$Bytes[i])
      ) && identical(
        mfrmr_gpcm_repilot_hash_file(path), artifacts$SHA256[i]
      )
    }, logical(1)
  )) && identical(
    mfrmr_gpcm_repilot_hash_object(artifacts),
    marker$artifact_inventory_sha256
  )
  if (!isTRUE(valid)) {
    stop("The Draft.55 component baseline artifact inventory changed.",
         call. = FALSE)
  }
  results <- utils::read.csv(
    file.path(baseline_dir, "run-results.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  if (nrow(results) != 19L || anyDuplicated(results$ScenarioId)) {
    stop("The Draft.55 component baseline ledger is malformed.",
         call. = FALSE)
  }
  list(
    marker = marker, results = results,
    marker_sha256 = mfrmr_gpcm_repilot_hash_file(marker_path)
  )
}

mfrmr_jml_lp_glpk_run <- function(lp_base, objective,
                                   extra_constraint = NULL,
                                   extra_direction = NULL,
                                   extra_rhs = NULL,
                                   timeout = 5L) {
  objective <- as.numeric(objective)
  directions <- lp_base$constraint_direction
  rhs <- lp_base$constraint_rhs
  n_constraints <- lp_base$n_constraints
  if (!is.null(extra_constraint)) {
    extra_constraint <- as.numeric(extra_constraint)
    if (length(extra_constraint) != length(objective) ||
        length(extra_direction) != 1L || length(extra_rhs) != 1L) {
      stop("Independent JML recession LP augmentation is malformed.",
           call. = FALSE)
    }
    directions <- c(directions, as.character(extra_direction))
    rhs <- c(rhs, as.numeric(extra_rhs))
    n_constraints <- n_constraints + 1L
  }

  if (identical(lp_base$representation, "dense_reference")) {
    constraints <- lp_base$constraint_matrix
    if (!is.null(extra_constraint)) {
      constraints <- rbind(constraints, extra_constraint)
    }
  } else {
    triplet <- lp_base$constraint_triplet
    if (!is.null(extra_constraint)) {
      keep <- which(extra_constraint != 0)
      if (length(keep) > 0L) {
        addition <- cbind(
          n_constraints, keep, extra_constraint[keep]
        )
        storage.mode(addition) <- "double"
        triplet <- rbind(triplet, addition)
      }
    }
    constraints <- slam::simple_triplet_matrix(
      i = as.integer(triplet[, 1L]),
      j = as.integer(triplet[, 2L]),
      v = as.numeric(triplet[, 3L]),
      nrow = as.integer(n_constraints),
      ncol = length(objective)
    )
  }

  fit <- Rglpk::Rglpk_solve_LP(
    obj = objective,
    mat = constraints,
    dir = directions,
    rhs = rhs,
    max = TRUE,
    control = list(tm_limit = as.integer(timeout) * 1000L)
  )
  list(
    status = as.integer(fit$status),
    objval = as.numeric(fit$optimum),
    solution = as.numeric(fit$solution)
  )
}

mfrmr_jml_lp_independent_target <- function(
    lp_base, target, objective_tolerance = 1e-7,
    certificate_tolerance = 1e-7, timeout = 5L,
    run_solver = mfrmr_jml_lp_glpk_run) {
  target <- as.numeric(target)
  n_parameters <- length(target)
  failed <- function(stage, status = NA_integer_, capacity = NA_real_,
                     calls = 1L) {
    list(
      evaluated = FALSE, certified = FALSE,
      solver_status = as.integer(status), target_capacity = capacity,
      target_change = NA_real_, minimum_margin = NA_real_,
      positive_margin = NA_real_, strict_rows = NA_integer_,
      direction = rep(NA_real_, n_parameters), lp_calls = as.integer(calls),
      reason = paste0("linear_program_", stage, "_failed")
    )
  }
  signed_target <- c(target, -target)
  capacity_fit <- tryCatch(
    run_solver(
      lp_base = lp_base, objective = signed_target,
      timeout = as.integer(timeout)
    ),
    error = function(e) e
  )
  if (inherits(capacity_fit, "error") ||
      !identical(as.integer(mfrmr_jml_lp_or(
        capacity_fit$status, -1L
      )), 0L)) {
    return(failed(
      "capacity",
      if (inherits(capacity_fit, "error")) NA_integer_ else {
        as.integer(capacity_fit$status)
      }
    ))
  }

  capacity <- as.numeric(capacity_fit$objval)
  if (!is.finite(capacity) || capacity <= 10 * objective_tolerance) {
    return(list(
      evaluated = TRUE, certified = FALSE,
      solver_status = as.integer(capacity_fit$status),
      target_capacity = capacity, target_change = 0,
      minimum_margin = 0, positive_margin = 0, strict_rows = 0L,
      direction = rep(0, n_parameters), lp_calls = 1L,
      reason = "no_target_recession_direction"
    ))
  }

  target_floor <- max(objective_tolerance * 2, capacity * 1e-5)
  strict_objective <- as.numeric(Matrix::colSums(lp_base$contrast_design))
  strict_fit <- tryCatch(
    run_solver(
      lp_base = lp_base,
      objective = c(strict_objective, -strict_objective),
      extra_constraint = signed_target,
      extra_direction = ">=", extra_rhs = target_floor,
      timeout = as.integer(timeout)
    ),
    error = function(e) e
  )
  if (inherits(strict_fit, "error") ||
      !identical(as.integer(mfrmr_jml_lp_or(
        strict_fit$status, -1L
      )), 0L)) {
    return(failed(
      "strictness",
      if (inherits(strict_fit, "error")) NA_integer_ else {
        as.integer(strict_fit$status)
      }, capacity = capacity, calls = 2L
    ))
  }

  solution <- as.numeric(strict_fit$solution)
  direction <- solution[seq_len(n_parameters)] -
    solution[n_parameters + seq_len(n_parameters)]
  margins <- as.numeric(lp_base$contrast_design %*% direction)
  target_change <- sum(target * direction)
  minimum_margin <- min(margins)
  positive_margin <- sum(pmax(margins, 0))
  strict_rows <- sum(margins > certificate_tolerance)
  certified <- is.finite(target_change) &&
    target_change > objective_tolerance &&
    is.finite(minimum_margin) &&
    minimum_margin >= -certificate_tolerance &&
    is.finite(positive_margin) &&
    positive_margin > objective_tolerance && strict_rows > 0L
  list(
    evaluated = TRUE, certified = isTRUE(certified),
    solver_status = as.integer(strict_fit$status),
    target_capacity = capacity, target_change = target_change,
    minimum_margin = minimum_margin, positive_margin = positive_margin,
    strict_rows = as.integer(strict_rows), direction = direction,
    lp_calls = 2L,
    reason = if (isTRUE(certified)) {
      "certified_additive_recession_direction"
    } else {
      "candidate_failed_postsolve_certificate"
    }
  )
}

mfrmr_jml_lp_result_parity <- function(production, independent,
                                       tolerance = 1e-7) {
  close_capacity <- if (is.finite(production$target_capacity) &&
      is.finite(independent$target_capacity)) {
    abs(production$target_capacity - independent$target_capacity) <=
      tolerance * (1 + abs(production$target_capacity))
  } else {
    identical(
      is.na(production$target_capacity),
      is.na(independent$target_capacity)
    )
  }
  identical(isTRUE(production$evaluated), isTRUE(independent$evaluated)) &&
    identical(isTRUE(production$certified), isTRUE(independent$certified)) &&
    identical(as.character(production$reason),
              as.character(independent$reason)) && isTRUE(close_capacity)
}

mfrmr_jml_lp_empty_events <- function() {
  data.frame(
    EventId = integer(0), EventType = character(0), Scope = character(0),
    BaseId = integer(0), BaseSHA256 = character(0),
    Representation = character(0), Parameters = integer(0),
    Variables = integer(0), Constraints = integer(0),
    StoredNonzeros = double(0), ObjectiveNonzeros = integer(0),
    ExtraConstraint = logical(0), ExtraNonzeros = integer(0),
    ProductionSeconds = double(0), SolverSeconds = double(0),
    AssemblyDispatchSeconds = double(0), ProductionStatus = integer(0),
    ProductionObjective = double(0), IndependentSeconds = double(0),
    IndependentStatus = integer(0), IndependentObjective = double(0),
    ObjectiveAbsDifference = double(0), ProductionEvaluated = logical(0),
    IndependentEvaluated = logical(0), ProductionCertified = logical(0),
    IndependentCertified = logical(0), ProductionReason = character(0),
    IndependentReason = character(0), ParityValid = logical(0),
    Clock = character(0), DecisionUse = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_lp_profiler_start <- function() {
  namespace <- asNamespace("mfrmr")
  lp_namespace <- asNamespace("lpSolve")
  collector <- new.env(parent = emptyenv())
  collector$scope <- "outside"
  collector$event_id <- 0L
  collector$base_id <- 0L
  collector$current_run <- NA_integer_
  collector$events <- list()
  collector$solver <- new.env(parent = emptyenv())
  collector$stopped <- FALSE

  originals <- list(
    structural = get(
      "audit_mfrm_jml_structural_recession", namespace, inherits = FALSE
    ),
    joint = get(
      "audit_mfrm_jml_joint_recession", namespace, inherits = FALSE
    ),
    base = get("mfrmr_jml_recession_lp_base", namespace, inherits = FALSE),
    target = get(
      "mfrmr_jml_recession_target_lp", namespace, inherits = FALSE
    ),
    run = get("mfrmr_jml_recession_run_lp", namespace, inherits = FALSE),
    lp = get("lp", lp_namespace, inherits = FALSE)
  )

  add_event <- function(event_type, lp_base = NULL, ...) {
    collector$event_id <- collector$event_id + 1L
    fields <- list(...)
    row <- mfrmr_jml_lp_empty_events()[0, , drop = FALSE]
    base_id <- if (is.null(lp_base)) NA_integer_ else {
      as.integer(mfrmr_jml_lp_or(
        attr(lp_base, "mfrmr_lp_attribution_id"), NA_integer_
      ))
    }
    base_sha <- if (is.null(lp_base)) NA_character_ else {
      as.character(mfrmr_jml_lp_or(attr(
        lp_base, "mfrmr_lp_attribution_sha256"
      ), NA_character_))
    }
    defaults <- list(
      EventId = collector$event_id, EventType = event_type,
      Scope = collector$scope, BaseId = base_id, BaseSHA256 = base_sha,
      Representation = if (is.null(lp_base)) NA_character_ else {
        lp_base$representation
      },
      Parameters = if (is.null(lp_base)) NA_integer_ else {
        lp_base$n_parameters
      },
      Variables = if (is.null(lp_base)) NA_integer_ else {
        2L * lp_base$n_parameters
      },
      Constraints = if (is.null(lp_base)) NA_integer_ else {
        lp_base$n_constraints
      },
      StoredNonzeros = if (is.null(lp_base)) NA_real_ else {
        as.double(lp_base$stored_constraint_nonzeros)
      },
      ObjectiveNonzeros = NA_integer_, ExtraConstraint = NA,
      ExtraNonzeros = NA_integer_, ProductionSeconds = NA_real_,
      SolverSeconds = NA_real_, AssemblyDispatchSeconds = NA_real_,
      ProductionStatus = NA_integer_, ProductionObjective = NA_real_,
      IndependentSeconds = NA_real_, IndependentStatus = NA_integer_,
      IndependentObjective = NA_real_, ObjectiveAbsDifference = NA_real_,
      ProductionEvaluated = NA, IndependentEvaluated = NA,
      ProductionCertified = NA, IndependentCertified = NA,
      ProductionReason = NA_character_, IndependentReason = NA_character_,
      ParityValid = NA, Clock = "proc.time.elapsed",
      DecisionUse = "diagnostic_only"
    )
    defaults[names(fields)] <- fields
    collector$events[[length(collector$events) + 1L]] <-
      as.data.frame(defaults, stringsAsFactors = FALSE)
    invisible(NULL)
  }

  scope_wrapper <- function(scope, original) {
    force(scope)
    force(original)
    function(...) {
      previous <- collector$scope
      collector$scope <- scope
      on.exit(collector$scope <- previous, add = TRUE)
      original(...)
    }
  }

  base_wrapper <- function(...) {
    started <- unname(proc.time()[["elapsed"]])
    value <- originals$base(...)
    elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
    collector$base_id <- collector$base_id + 1L
    identity <- list(
      schema = "mfrmr-jml-lp-base-identity-v1",
      representation = value$representation,
      contrast_dim = dim(value$contrast_design),
      contrast_p = value$contrast_design@p,
      contrast_i = value$contrast_design@i,
      contrast_x = value$contrast_design@x,
      direction = value$constraint_direction,
      rhs = value$constraint_rhs
    )
    attr(value, "mfrmr_lp_attribution_id") <- collector$base_id
    attr(value, "mfrmr_lp_attribution_sha256") <-
      mfrmr_gpcm_repilot_hash_object(identity)
    add_event(
      "base_assembly", value,
      ProductionSeconds = elapsed, AssemblyDispatchSeconds = elapsed
    )
    value
  }

  lp_wrapper <- function(...) {
    run_id <- collector$current_run
    started <- unname(proc.time()[["elapsed"]])
    value <- tryCatch(originals$lp(...), error = function(e) e)
    elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
    record <- list(
      seconds = elapsed,
      status = if (inherits(value, "error")) NA_integer_ else {
        as.integer(mfrmr_jml_lp_or(value$status, NA_integer_))
      },
      objective = if (inherits(value, "error")) NA_real_ else {
        as.numeric(mfrmr_jml_lp_or(value$objval, NA_real_))
      }
    )
    assign(as.character(run_id), record, envir = collector$solver)
    if (inherits(value, "error")) stop(value)
    value
  }

  run_wrapper <- function(lp_base, objective, extra_constraint = NULL,
                          extra_direction = NULL, extra_rhs = NULL,
                          timeout = 2L) {
    collector$current_run <- collector$event_id + 1L
    run_id <- collector$current_run
    on.exit(collector$current_run <- NA_integer_, add = TRUE)
    started <- unname(proc.time()[["elapsed"]])
    value <- tryCatch(
      originals$run(
        lp_base = lp_base, objective = objective,
        extra_constraint = extra_constraint,
        extra_direction = extra_direction, extra_rhs = extra_rhs,
        timeout = timeout
      ),
      error = function(e) e
    )
    elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
    solver <- get0(
      as.character(run_id), envir = collector$solver, inherits = FALSE,
      ifnotfound = list(
        seconds = NA_real_, status = NA_integer_, objective = NA_real_
      )
    )
    add_event(
      "lp_call", lp_base,
      ObjectiveNonzeros = sum(as.numeric(objective) != 0),
      ExtraConstraint = !is.null(extra_constraint),
      ExtraNonzeros = if (is.null(extra_constraint)) 0L else {
        sum(as.numeric(extra_constraint) != 0)
      },
      ProductionSeconds = elapsed, SolverSeconds = solver$seconds,
      AssemblyDispatchSeconds = max(0, elapsed - solver$seconds),
      ProductionStatus = solver$status,
      ProductionObjective = solver$objective
    )
    if (inherits(value, "error")) stop(value)
    value
  }

  target_wrapper <- function(lp_base, target,
                             objective_tolerance = 1e-7,
                             certificate_tolerance = 1e-7,
                             timeout = 5L) {
    started <- unname(proc.time()[["elapsed"]])
    production <- originals$target(
      lp_base = lp_base, target = target,
      objective_tolerance = objective_tolerance,
      certificate_tolerance = certificate_tolerance,
      timeout = timeout
    )
    production_seconds <- max(
      0, unname(proc.time()[["elapsed"]]) - started
    )
    independent_started <- unname(proc.time()[["elapsed"]])
    independent <- tryCatch(
      mfrmr_jml_lp_independent_target(
        lp_base = lp_base, target = target,
        objective_tolerance = objective_tolerance,
        certificate_tolerance = certificate_tolerance,
        timeout = timeout
      ),
      error = function(e) e
    )
    independent_seconds <- max(
      0, unname(proc.time()[["elapsed"]]) - independent_started
    )
    independent_error <- inherits(independent, "error")
    parity <- !independent_error && mfrmr_jml_lp_result_parity(
      production, independent
    )
    capacity_difference <- if (!independent_error &&
        is.finite(production$target_capacity) &&
        is.finite(independent$target_capacity)) {
      abs(production$target_capacity - independent$target_capacity)
    } else NA_real_
    add_event(
      "target_parity", lp_base,
      ObjectiveNonzeros = sum(as.numeric(target) != 0),
      ProductionSeconds = production_seconds,
      ProductionStatus = production$solver_status,
      ProductionObjective = production$target_capacity,
      IndependentSeconds = independent_seconds,
      IndependentStatus = if (independent_error) NA_integer_ else {
        independent$solver_status
      },
      IndependentObjective = if (independent_error) NA_real_ else {
        independent$target_capacity
      },
      ObjectiveAbsDifference = capacity_difference,
      ProductionEvaluated = production$evaluated,
      IndependentEvaluated = if (independent_error) FALSE else {
        independent$evaluated
      },
      ProductionCertified = production$certified,
      IndependentCertified = if (independent_error) FALSE else {
        independent$certified
      },
      ProductionReason = production$reason,
      IndependentReason = if (independent_error) {
        paste0("independent_error: ", conditionMessage(independent))
      } else independent$reason,
      ParityValid = parity
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
  assignInNamespace("mfrmr_jml_recession_lp_base", base_wrapper, ns = "mfrmr")
  assignInNamespace(
    "mfrmr_jml_recession_target_lp", target_wrapper, ns = "mfrmr"
  )
  assignInNamespace("mfrmr_jml_recession_run_lp", run_wrapper, ns = "mfrmr")
  assignInNamespace("lp", lp_wrapper, ns = "lpSolve")

  stop_profile <- function() {
    if (isTRUE(collector$stopped)) return(collector$result)
    assignInNamespace("lp", originals$lp, ns = "lpSolve")
    assignInNamespace("mfrmr_jml_recession_run_lp", originals$run,
                      ns = "mfrmr")
    assignInNamespace("mfrmr_jml_recession_target_lp", originals$target,
                      ns = "mfrmr")
    assignInNamespace("mfrmr_jml_recession_lp_base", originals$base,
                      ns = "mfrmr")
    assignInNamespace("audit_mfrm_jml_joint_recession", originals$joint,
                      ns = "mfrmr")
    assignInNamespace("audit_mfrm_jml_structural_recession",
                      originals$structural, ns = "mfrmr")
    collector$stopped <- TRUE
    collector$result <- if (length(collector$events) == 0L) {
      mfrmr_jml_lp_empty_events()
    } else {
      out <- do.call(rbind, collector$events)
      rownames(out) <- NULL
      out[order(out$EventId), , drop = FALSE]
    }
    collector$result
  }
  list(stop = stop_profile)
}

mfrmr_jml_lp_adversarial_controls <- function() {
  cases <- list(
    positive = list(
      contrast = Matrix::sparseMatrix(
        i = 1L, j = 1L, x = 1, dims = c(1L, 1L)
      ), target = 1, objective = 1e-7, certificate = 1e-7,
      expected = TRUE
    ),
    empty_cone = list(
      contrast = Matrix::sparseMatrix(
        i = c(1L, 2L), j = c(1L, 1L), x = c(1, -1),
        dims = c(2L, 1L)
      ), target = 1, objective = 1e-7, certificate = 1e-7,
      expected = FALSE
    ),
    guarded_near_boundary = list(
      contrast = Matrix::sparseMatrix(
        i = 1L, j = 1L, x = 5e-7, dims = c(1L, 1L)
      ), target = 5e-7, objective = 1e-10, certificate = 1e-7,
      expected = TRUE
    ),
    default_near_boundary = list(
      contrast = Matrix::sparseMatrix(
        i = 1L, j = 1L, x = 5e-7, dims = c(1L, 1L)
      ), target = 5e-7, objective = 1e-7, certificate = 1e-7,
      expected = FALSE
    ),
    flat_target = list(
      contrast = Matrix::sparseMatrix(
        i = c(1L, 2L, 3L), j = c(1L, 2L, 2L),
        x = c(1, 1, -1), dims = c(3L, 3L)
      ), target = c(0, 0, 1), objective = 1e-7,
      certificate = 1e-7, expected = TRUE
    )
  )
  rows <- list()
  cursor <- 0L
  for (case_id in names(cases)) {
    case <- cases[[case_id]]
    for (representation in c("sparse_triplet", "dense_reference")) {
      cursor <- cursor + 1L
      base <- mfrmr:::mfrmr_jml_recession_lp_base(
        case$contrast, representation = representation
      )
      production <- mfrmr:::mfrmr_jml_recession_target_lp(
        base, case$target,
        objective_tolerance = case$objective,
        certificate_tolerance = case$certificate
      )
      independent <- mfrmr_jml_lp_independent_target(
        base, case$target,
        objective_tolerance = case$objective,
        certificate_tolerance = case$certificate
      )
      rows[[cursor]] <- data.frame(
        Control = case_id, Representation = representation,
        ProductionEvaluated = production$evaluated,
        IndependentEvaluated = independent$evaluated,
        ProductionCertified = production$certified,
        IndependentCertified = independent$certified,
        ExpectedCertified = case$expected,
        ProductionCapacity = production$target_capacity,
        IndependentCapacity = independent$target_capacity,
        ProductionReason = production$reason,
        IndependentReason = independent$reason,
        ParityValid = mfrmr_jml_lp_result_parity(production, independent) &&
          identical(isTRUE(production$certified), case$expected),
        stringsAsFactors = FALSE
      )
    }
  }

  base <- mfrmr:::mfrmr_jml_recession_lp_base(cases$positive$contrast)
  forced_error <- mfrmr_jml_lp_independent_target(
    base, 1, run_solver = function(...) stop("forced independent failure")
  )
  forced_status <- mfrmr_jml_lp_independent_target(
    base, 1, run_solver = function(...) {
      list(status = 5L, objval = NA_real_, solution = rep(NA_real_, 2L))
    }
  )
  call_count <- 0L
  strict_failure_solver <- function(...) {
    call_count <<- call_count + 1L
    if (call_count == 1L) {
      mfrmr_jml_lp_glpk_run(...)
    } else {
      list(status = 5L, objval = NA_real_, solution = rep(NA_real_, 2L))
    }
  }
  strict_failure <- mfrmr_jml_lp_independent_target(
    base, 1, run_solver = strict_failure_solver
  )
  failure_rows <- data.frame(
    Control = c(
      "forced_capacity_error", "forced_capacity_status",
      "forced_strictness_status"
    ),
    Representation = "sparse_triplet",
    ProductionEvaluated = NA, IndependentEvaluated = c(
      forced_error$evaluated, forced_status$evaluated,
      strict_failure$evaluated
    ),
    ProductionCertified = NA, IndependentCertified = c(
      forced_error$certified, forced_status$certified,
      strict_failure$certified
    ),
    ExpectedCertified = FALSE,
    ProductionCapacity = NA_real_, IndependentCapacity = c(
      forced_error$target_capacity, forced_status$target_capacity,
      strict_failure$target_capacity
    ),
    ProductionReason = NA_character_, IndependentReason = c(
      forced_error$reason, forced_status$reason, strict_failure$reason
    ),
    ParityValid = c(
      identical(forced_error$reason, "linear_program_capacity_failed") &&
        !isTRUE(forced_error$evaluated),
      identical(forced_status$reason, "linear_program_capacity_failed") &&
        !isTRUE(forced_status$evaluated),
      identical(
        strict_failure$reason, "linear_program_strictness_failed"
      ) && !isTRUE(strict_failure$evaluated) &&
        is.finite(strict_failure$target_capacity)
    ),
    stringsAsFactors = FALSE
  )
  out <- rbind(do.call(rbind, rows), failure_rows)
  rownames(out) <- NULL
  out
}

mfrmr_jml_lp_model_control_registry <- function() {
  data.frame(
    ScenarioId = c(
      "LP-RSM-TWO-RATER-MISSING",
      "LP-RSM-INTERACTION",
      "LP-GPCM-TWO-RATER-IMBALANCED",
      "LP-GPCM-SPARSE-PANEL"
    ),
    Model = c("RSM", "RSM", "GPCM", "GPCM"),
    Persons = c(70L, 60L, 70L, 80L),
    Raters = c(2L, 3L, 2L, 8L),
    Criteria = c(4L, 3L, 4L, 4L),
    RatersPerPerson = c(2L, 2L, 2L, 2L),
    ScoreLevels = c(6L, 5L, 6L, 5L),
    Seed = 256101:256104,
    MissingAndWeight = c(TRUE, TRUE, TRUE, FALSE),
    CategoryImbalance = c(TRUE, FALSE, TRUE, FALSE),
    Interaction = c(FALSE, TRUE, FALSE, FALSE),
    EvidenceUse = "cross_model_solver_parity_calibration_only",
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_lp_build_model_control <- function(row) {
  data <- mfrmr_gpcm_stress_fun("simulate_mfrm_data")(
    n_person = as.integer(row$Persons),
    n_rater = as.integer(row$Raters),
    n_criterion = as.integer(row$Criteria),
    raters_per_person = as.integer(row$RatersPerPerson),
    score_levels = as.integer(row$ScoreLevels),
    seed = as.integer(row$Seed), model = as.character(row$Model),
    step_facet = if (identical(as.character(row$Model), "GPCM")) {
      "Criterion"
    } else NULL,
    slope_facet = if (identical(as.character(row$Model), "GPCM")) {
      "Criterion"
    } else NULL
  )
  support_rows <- integer(0)
  if (isTRUE(row$CategoryImbalance)) {
    support_rows <- unlist(lapply(
      split(seq_len(nrow(data)), data$Criterion), function(index) {
        head(index, as.integer(row$ScoreLevels))
      }
    ), use.names = FALSE)
    support_scores <- rep(
      0:(as.integer(row$ScoreLevels) - 1L),
      length.out = length(support_rows)
    )
    eligible <- setdiff(seq_len(nrow(data)), support_rows)
    set.seed(as.integer(row$Seed) + 9000L)
    forced_low <- sample(
      eligible, floor(0.55 * length(eligible)), replace = FALSE
    )
    data$Score[forced_low] <- 0L
    data$Score[seq(7L, nrow(data), by = 37L)] <-
      as.integer(row$ScoreLevels) - 1L
    data$Score[support_rows] <- support_scores
  }
  if (isTRUE(row$MissingAndWeight)) {
    data$Weight <- 1
    data$Weight[seq(1L, nrow(data), by = 23L)] <- 0
    data$Weight[seq(5L, nrow(data), by = 31L)] <- 2
    data$Score[seq(11L, nrow(data), by = 41L)] <- NA
    if (length(support_rows) > 0L) {
      data$Weight[support_rows] <- 1
      data$Score[support_rows] <- rep(
        0:(as.integer(row$ScoreLevels) - 1L),
        length.out = length(support_rows)
      )
    }
  }
  args <- list(
    data = data, person = "Person", facets = c("Rater", "Criterion"),
    score = "Score", model = as.character(row$Model), method = "JML",
    maxit = 40L
  )
  if (isTRUE(row$MissingAndWeight)) args$weight <- "Weight"
  if (identical(as.character(row$Model), "GPCM")) {
    args$step_facet <- "Criterion"
    args$slope_facet <- "Criterion"
  }
  if (isTRUE(row$Interaction)) {
    args$facet_interactions <- "Rater:Criterion"
    args$min_obs_per_interaction <- 1L
  }
  list(data = data, args = args)
}

mfrmr_jml_lp_fit_model_control <- function(args, instrument = FALSE) {
  session <- if (isTRUE(instrument)) mfrmr_jml_lp_profiler_start() else NULL
  stopped <- FALSE
  on.exit({
    if (!is.null(session) && !stopped) session$stop()
  }, add = TRUE)
  fit <- tryCatch(
    suppressWarnings(do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), args)),
    error = function(e) e
  )
  events <- if (is.null(session)) {
    mfrmr_jml_lp_empty_events()
  } else {
    value <- session$stop()
    stopped <- TRUE
    value
  }
  list(fit = fit, events = events)
}

mfrmr_jml_lp_model_controls <- function(progress = interactive()) {
  registry <- mfrmr_jml_lp_model_control_registry()
  rows <- vector("list", nrow(registry))
  events <- vector("list", nrow(registry))
  for (i in seq_len(nrow(registry))) {
    row <- registry[i, , drop = FALSE]
    if (isTRUE(progress)) message("[lp-model] ", row$ScenarioId)
    problem <- mfrmr_jml_lp_build_model_control(row)
    baseline <- mfrmr_jml_lp_fit_model_control(problem$args, FALSE)
    instrumented <- mfrmr_jml_lp_fit_model_control(problem$args, TRUE)
    baseline_ok <- !inherits(baseline$fit, "error")
    instrumented_ok <- !inherits(instrumented$fit, "error")
    semantic_match <- baseline_ok && instrumented_ok && identical(
      mfrmr_jml_phase_semantic_hash(baseline$fit),
      mfrmr_jml_phase_semantic_hash(instrumented$fit)
    )
    readiness_match <- baseline_ok && instrumented_ok && identical(
      mfrmr_target_bridge_readiness(baseline$fit),
      mfrmr_target_bridge_readiness(instrumented$fit)
    )
    baseline_boundary <- if (baseline_ok) {
      baseline$fit$config$boundary_audit
    } else list()
    instrumented_boundary <- if (instrumented_ok) {
      instrumented$fit$config$boundary_audit
    } else list()
    state <- function(boundary, name) {
      value <- mfrmr_jml_lp_or(boundary[[name]], list())
      as.character(mfrmr_jml_lp_or(value$state, NA_character_))
    }
    route_events <- instrumented$events
    route_parity <- route_events[
      route_events$EventType == "target_parity", , drop = FALSE
    ]
    rows[[i]] <- data.frame(
      ScenarioId = row$ScenarioId, Model = row$Model,
      Rows = nrow(problem$data), Persons = row$Persons,
      Raters = row$Raters, Criteria = row$Criteria,
      BaselineFitSucceeded = baseline_ok,
      InstrumentedFitSucceeded = instrumented_ok,
      BaselineError = if (baseline_ok) NA_character_ else {
        conditionMessage(baseline$fit)
      },
      InstrumentedError = if (instrumented_ok) NA_character_ else {
        conditionMessage(instrumented$fit)
      },
      SemanticHashMatch = semantic_match,
      ReadinessMatch = readiness_match,
      BaselineStructuralState = state(
        baseline_boundary, "structural_additive"
      ),
      InstrumentedStructuralState = state(
        instrumented_boundary, "structural_additive"
      ),
      BaselineJointState = state(baseline_boundary, "joint_additive"),
      InstrumentedJointState = state(
        instrumented_boundary, "joint_additive"
      ),
      LPEvents = nrow(route_events),
      TargetComparisons = nrow(route_parity),
      IndependentParityPassed = sum(route_parity$ParityValid %in% TRUE),
      IndependentParityFailed = sum(route_parity$ParityValid %in% FALSE),
      Valid = baseline_ok && instrumented_ok && semantic_match &&
        readiness_match && nrow(route_events) > 0L &&
        nrow(route_parity) > 0L && all(route_parity$ParityValid),
      EvidenceUse = "cross_model_solver_parity_calibration_only",
      stringsAsFactors = FALSE
    )
    route_events$ScenarioId <- rep.int(
      as.character(row$ScenarioId), nrow(route_events)
    )
    route_events$DataCellId <- rep.int(
      as.character(row$ScenarioId), nrow(route_events)
    )
    route_events$Method <- rep.int("JML", nrow(route_events))
    route_events$OptimizerRequested <- rep.int(
      "auto", nrow(route_events)
    )
    events[[i]] <- route_events[, c(
      "ScenarioId", "DataCellId", "Method", "OptimizerRequested",
      setdiff(names(route_events), c(
        "ScenarioId", "DataCellId", "Method", "OptimizerRequested"
      ))
    )]
  }
  summary <- do.call(rbind, rows)
  events <- do.call(rbind, events)
  rownames(summary) <- rownames(events) <- NULL
  list(registry = registry, summary = summary, events = events)
}

mfrmr_jml_lp_summaries <- function(events) {
  lp_calls <- events[events$EventType == "lp_call", , drop = FALSE]
  base_calls <- events[events$EventType == "base_assembly", , drop = FALSE]
  parity <- events[events$EventType == "target_parity", , drop = FALSE]
  overall <- data.frame(
    LPBaseAssemblies = nrow(base_calls), LPCalls = nrow(lp_calls),
    TargetComparisons = nrow(parity),
    LPBaseAssemblySeconds = sum(base_calls$ProductionSeconds),
    RunLPSeconds = sum(lp_calls$ProductionSeconds),
    LPSolverSeconds = sum(lp_calls$SolverSeconds),
    AssemblyDispatchSeconds = sum(lp_calls$AssemblyDispatchSeconds),
    SolverShare = sum(lp_calls$SolverSeconds) /
      max(sum(lp_calls$ProductionSeconds), .Machine$double.eps),
    IndependentTargetSeconds = sum(parity$IndependentSeconds),
    ParityPassed = sum(parity$ParityValid %in% TRUE),
    ParityFailed = sum(parity$ParityValid %in% FALSE),
    MaxCapacityDifference = max(c(0, parity$ObjectiveAbsDifference),
                                na.rm = TRUE),
    DecisionUse = "diagnostic_only",
    stringsAsFactors = FALSE
  )
  keys <- interaction(
    lp_calls$Scope, lp_calls$Representation, drop = TRUE, lex.order = TRUE
  )
  by_scope <- do.call(rbind, lapply(split(lp_calls, keys), function(x) {
    data.frame(
      Scope = x$Scope[1L], Representation = x$Representation[1L],
      Calls = nrow(x), CapacityCalls = sum(!x$ExtraConstraint),
      StrictnessCalls = sum(x$ExtraConstraint),
      MinParameters = min(x$Parameters), MaxParameters = max(x$Parameters),
      MinConstraints = min(x$Constraints), MaxConstraints = max(x$Constraints),
      StoredNonzeros = sum(x$StoredNonzeros),
      RunLPSeconds = sum(x$ProductionSeconds),
      LPSolverSeconds = sum(x$SolverSeconds),
      AssemblyDispatchSeconds = sum(x$AssemblyDispatchSeconds),
      SolverShare = sum(x$SolverSeconds) /
        max(sum(x$ProductionSeconds), .Machine$double.eps),
      stringsAsFactors = FALSE
    )
  }))
  rownames(by_scope) <- NULL
  repeated <- do.call(rbind, lapply(
    split(lp_calls, interaction(
      lp_calls$ScenarioId, lp_calls$Scope, lp_calls$BaseSHA256,
      drop = TRUE, lex.order = TRUE
    )),
    function(x) data.frame(
      ScenarioId = x$ScenarioId[1L], Scope = x$Scope[1L],
      BaseSHA256 = x$BaseSHA256[1L], Parameters = x$Parameters[1L],
      Constraints = x$Constraints[1L], Calls = nrow(x),
      CapacityCalls = sum(!x$ExtraConstraint),
      StrictnessCalls = sum(x$ExtraConstraint),
      stringsAsFactors = FALSE
    )
  ))
  rownames(repeated) <- NULL
  list(overall = overall, by_scope = by_scope, repeated = repeated)
}

mfrmr_run_jml_lp_attribution_pilot <- function(
    dry_run = TRUE, authorize = FALSE, maxit = 60L, quad_points = 7L,
    reltol = 1e-9, baseline_dir = NULL, output_dir = NULL,
    progress = interactive()) {
  mfrmr_jml_lp_require_support()
  capabilities <- mfrmr_jml_lp_capabilities()
  registry <- mfrmr_jml_phase_registry()
  phase_identity <- mfrmr_jml_phase_identity(
    registry, maxit = maxit, quad_points = quad_points, reltol = reltol
  )
  if (isTRUE(dry_run)) {
    return(list(
      schema = "mfrmr-jml-lp-attribution-pilot-v1",
      registry = registry, capabilities = capabilities,
      phase_identity = phase_identity,
      independent_solver_results_affect_fit = FALSE,
      confirmation_authorized = FALSE
    ))
  }
  if (!isTRUE(authorize)) {
    stop("Live LP attribution requires `authorize = TRUE`.",
         call. = FALSE)
  }
  if (any(!capabilities$Available)) {
    stop(
      "Live LP attribution lacks required capabilities: ",
      paste(capabilities$Capability[!capabilities$Available], collapse = ", "),
      call. = FALSE
    )
  }
  required_path <- function(x, name, must_exist) {
    if (is.null(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
      stop(name, " must be one non-empty path.", call. = FALSE)
    }
    normalizePath(x, winslash = "/", mustWork = must_exist)
  }
  baseline_dir <- required_path(baseline_dir, "`baseline_dir`", TRUE)
  output_dir <- required_path(output_dir, "`output_dir`", FALSE)
  if (file.exists(output_dir) || dir.exists(output_dir)) {
    stop("`output_dir` must not already exist.", call. = FALSE)
  }
  baseline <- mfrmr_jml_lp_validate_baseline(baseline_dir)
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
  results <- vector("list", nrow(registry))
  phases <- vector("list", nrow(registry))
  events <- vector("list", nrow(registry))
  cursor <- 0L
  for (cell_id in unique(registry$DataCellId)) {
    cell <- cells[match(cell_id, cells$DataCellId), , drop = FALSE]
    generated <- mfrmr_jml_profile_build(cell)
    routes <- registry[registry$DataCellId == cell_id, , drop = FALSE]
    if (isTRUE(progress)) message("[lp-attribution] ", cell_id)
    for (j in seq_len(nrow(routes))) {
      cursor <- cursor + 1L
      route_row <- routes[j, , drop = FALSE]
      if (isTRUE(progress)) {
        message("  ", route_row$Method, " / ",
                route_row$OptimizerRequested)
      }
      route <- mfrmr_jml_phase_run_route(
        route_row, generated, maxit = maxit,
        quad_points = quad_points, reltol = reltol,
        component_profiler = mfrmr_jml_lp_profiler_start
      )
      route_events <- route$components
      route_events$ScenarioId <- rep.int(
        as.character(route_row$ScenarioId), nrow(route_events)
      )
      route_events$DataCellId <- rep.int(
        as.character(route_row$DataCellId), nrow(route_events)
      )
      route_events$Method <- rep.int(
        as.character(route_row$Method), nrow(route_events)
      )
      route_events$OptimizerRequested <- rep.int(
        as.character(route_row$OptimizerRequested), nrow(route_events)
      )
      route_events <- route_events[, c(
        "ScenarioId", "DataCellId", "Method", "OptimizerRequested",
        setdiff(names(route_events), c(
          "ScenarioId", "DataCellId", "Method", "OptimizerRequested"
        ))
      )]
      results[[cursor]] <- route$result
      phases[[cursor]] <- route$phases
      events[[cursor]] <- route_events
      utils::write.csv(
        do.call(rbind, results[seq_len(cursor)]),
        file.path(staging, "run-progress.csv"),
        row.names = FALSE, na = ""
      )
    }
  }
  results <- do.call(rbind, results)
  phases <- do.call(rbind, phases)
  events <- do.call(rbind, events)
  rownames(results) <- rownames(phases) <- rownames(events) <- NULL
  comparison <- mfrmr_jml_component_compare_baseline(
    results, baseline$results
  )
  controls <- mfrmr_jml_lp_adversarial_controls()
  model_controls <- mfrmr_jml_lp_model_controls(progress = progress)
  events <- rbind(events, model_controls$events)
  rownames(events) <- NULL
  summaries <- mfrmr_jml_lp_summaries(events)
  parity <- events[events$EventType == "target_parity", , drop = FALSE]
  lp_calls <- events[events$EventType == "lp_call", , drop = FALSE]
  fixed_jml <- results$ScenarioId[results$Method == "JML"]
  fixed_mml <- results$ScenarioId[results$Method == "MML"]
  jml_event_counts <- table(events$ScenarioId[
    events$ScenarioId %in% fixed_jml
  ])
  mml_event_count <- sum(events$ScenarioId %in% fixed_mml)
  completion_valid <- identical(results$ScenarioId, registry$ScenarioId) &&
    all(results$FitSucceeded) && all(results$TimingContractValid) &&
    !any(results$FalseReady) && all(comparison$AllEquivalent) &&
    length(jml_event_counts) == sum(results$Method == "JML") &&
    all(jml_event_counts > 0L) && mml_event_count == 0L &&
    nrow(parity) > 0L && all(parity$ParityValid) &&
    nrow(lp_calls) > 0L && all(lp_calls$ProductionStatus == 0L) &&
    all(is.finite(lp_calls$SolverSeconds)) &&
    all(controls$ParityValid) && all(model_controls$summary$Valid)
  if (!isTRUE(completion_valid)) {
    stop("LP attribution, independent parity, or baseline equivalence failed.",
         call. = FALSE)
  }

  runner_path <- file.path(
    mfrmr_jml_lp_source_dir, "jml-lp-attribution-pilot-0.2.3.R"
  )
  identity <- data.frame(
    Schema = "mfrmr-jml-lp-attribution-identity-v1",
    PhaseExecutionSHA256 = phase_identity$execution$ExecutionSHA256,
    InstalledPackageSHA256 = phase_identity$package$PackageSHA256,
    RunnerSHA256 = mfrmr_gpcm_repilot_hash_file(runner_path),
    BaselineCompletionSHA256 = baseline$marker_sha256,
    BaselineArtifactInventorySHA256 =
      baseline$marker$artifact_inventory_sha256,
    LpSolveVersion = capabilities$Version[
      capabilities$Capability == "lpSolve"
    ],
    RglpkVersion = capabilities$Version[
      capabilities$Capability == "Rglpk"
    ],
    SlamVersion = capabilities$Version[
      capabilities$Capability == "slam"
    ],
    ModelControlRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(
      model_controls$registry
    ),
    CapabilityManifestSHA256 = mfrmr_gpcm_repilot_hash_object(
      capabilities
    ),
    stringsAsFactors = FALSE
  )
  identity$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(identity)
  run_summary <- data.frame(
    Schema = "mfrmr-jml-lp-attribution-pilot-v1",
    Routes = nrow(results), JMLRoutes = sum(results$Method == "JML"),
    MMLRoutes = sum(results$Method == "MML"),
    FitsSucceeded = sum(results$FitSucceeded),
    BaselineEquivalentRoutes = sum(comparison$AllEquivalent),
    FalseReady = sum(results$FalseReady),
    LPCalls = summaries$overall$LPCalls,
    TargetComparisons = summaries$overall$TargetComparisons,
    IndependentParityPassed = summaries$overall$ParityPassed,
    IndependentParityFailed = summaries$overall$ParityFailed,
    AdversarialControls = nrow(controls),
    AdversarialControlsPassed = sum(controls$ParityValid),
    ModelControls = nrow(model_controls$summary),
    ModelControlsPassed = sum(model_controls$summary$Valid),
    ConfirmationAuthorized = FALSE, RuntimeCriteriaFrozen = FALSE,
    SolverDispatchChanged = FALSE,
    EvidenceUse = "lp_attribution_calibration_only",
    stringsAsFactors = FALSE
  )
  out <- list(
    registry = registry, results = results, phases = phases,
    lp_events = events, attribution_overall = summaries$overall,
    attribution_by_scope = summaries$by_scope,
    repeated_base_calls = summaries$repeated,
    independent_parity = parity, adversarial_controls = controls,
    model_control_registry = model_controls$registry,
    model_control_summary = model_controls$summary,
    baseline_comparison = comparison, capabilities = capabilities,
    run_summary = run_summary, identity = identity,
    package_identity = phase_identity$package,
    independent_solver_results_affect_fit = FALSE,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    "registry.csv" = registry, "run-results.csv" = results,
    "phase-timings.csv" = phases, "lp-events.csv" = events,
    "attribution-overall.csv" = summaries$overall,
    "attribution-by-scope.csv" = summaries$by_scope,
    "repeated-base-calls.csv" = summaries$repeated,
    "independent-parity.csv" = parity,
    "adversarial-controls.csv" = controls,
    "model-control-registry.csv" = model_controls$registry,
    "model-control-summary.csv" = model_controls$summary,
    "baseline-comparison.csv" = comparison,
    "capabilities.csv" = capabilities, "run-summary.csv" = run_summary,
    "execution-identity.csv" = identity,
    "package-identity.csv" = phase_identity$package
  )
  for (name in names(files)) {
    utils::write.csv(
      files[[name]], file.path(staging, name), row.names = FALSE, na = ""
    )
  }
  saveRDS(out, file.path(staging, "jml-lp-attribution-pilot.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  unlink(file.path(staging, "run-progress.csv"), force = TRUE)
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  completion <- list(
    schema = "mfrmr-jml-lp-attribution-completion-v1",
    execution_sha256 = identity$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    independent_solver_results_affect_fit = FALSE,
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) {
    stop("Completed LP-attribution evidence could not be promoted.",
         call. = FALSE)
  }
  promoted <- TRUE
  invisible(out)
}
