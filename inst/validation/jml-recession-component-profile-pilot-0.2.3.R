# Repository-only component attribution for the mfrmr 0.2.3 JML recession
# audits. This runner changes namespace bindings only for the duration of one
# fit, restores them before the legacy comparison in the phase runner, and
# never uses elapsed time in a statistical or readiness decision.

mfrmr_jml_component_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-recession-component-profile-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path(
      "inst", "validation",
      "jml-recession-component-profile-pilot-0.2.3.R"
    ),
    "jml-recession-component-profile-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_jml_component_require_support <- function() {
  target_env <- environment(mfrmr_jml_component_require_support)
  required <- c(
    "mfrmr_jml_phase_require_support", "mfrmr_jml_phase_registry",
    "mfrmr_jml_phase_identity", "mfrmr_jml_phase_run_route",
    "mfrmr_jml_profile_cells", "mfrmr_jml_profile_build",
    "mfrmr_target_scale_artifact_inventory",
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file"
  )
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    candidates <- c(
      if (!is.na(mfrmr_jml_component_source_dir)) {
        file.path(
          mfrmr_jml_component_source_dir,
          "jml-phase-profile-pilot-0.2.3.R"
        )
      } else character(0),
      file.path(
        "inst", "validation", "jml-phase-profile-pilot-0.2.3.R"
      ),
      "jml-phase-profile-pilot-0.2.3.R"
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("Cannot locate JML phase-profile support.", call. = FALSE)
    }
    sys.source(path, envir = target_env)
    mfrmr_jml_phase_require_support()
  }
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("JML component-profile support did not load completely.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_jml_component_function_map <- function() {
  c(
    audit_mfrm_jml_structural_recession = "scope_total",
    audit_mfrm_jml_joint_recession = "scope_total",
    audit_mfrm_jml_additive_recession = "audit_orchestration",
    mfrmr_jml_recession_shared_geometry = "shared_orchestration",
    mfrmr_estimability_adjacent_design = "adjacent_design",
    mfrmr_jml_structural_target_system = "target_mapping",
    mfrmr_jml_observed_contrast_design = "contrast_construction",
    mfrmr_jml_recession_lp_base = "lp_base_assembly",
    mfrmr_jml_recession_target_lp = "lp_evaluation",
    mfrmr_jml_recession_run_lp = "lp_solver",
    mfrmr_jml_recession_target_nullspace_screen = "nullspace_rank"
  )
}

mfrmr_jml_component_profiler_start <- function() {
  function_map <- mfrmr_jml_component_function_map()
  instrumented <- names(function_map)
  missing <- instrumented[!vapply(
    instrumented,
    exists, logical(1), envir = asNamespace("mfrmr"),
    mode = "function", inherits = FALSE
  )]
  if (length(missing) > 0L) {
    stop(
      "The installed runtime lacks required component targets: ",
      paste(missing, collapse = ", "), call. = FALSE
    )
  }

  collector <- new.env(parent = emptyenv())
  collector$stack <- list()
  collector$rows <- list()
  collector$cursor <- 0L
  collector$stopped <- FALSE

  enter <- function(name) {
    inherited <- if (length(collector$stack) > 0L) {
      collector$stack[[length(collector$stack)]]$scope
    } else {
      "outside"
    }
    scope <- if (identical(
      name, "audit_mfrm_jml_structural_recession"
    )) {
      "structural"
    } else if (identical(name, "audit_mfrm_jml_joint_recession")) {
      "joint"
    } else if (identical(
      name, "mfrmr_jml_recession_shared_geometry"
    )) {
      "shared"
    } else {
      inherited
    }
    collector$cursor <- collector$cursor + 1L
    frame <- list(
      id = collector$cursor,
      name = name,
      component = unname(function_map[[name]]),
      scope = scope,
      started = unname(proc.time()[["elapsed"]]),
      child = 0
    )
    collector$stack[[length(collector$stack) + 1L]] <- frame
    frame$id
  }

  exit_call <- function(id) {
    depth <- length(collector$stack)
    if (depth < 1L) {
      stop("Component profiler stack underflow.", call. = FALSE)
    }
    frame <- collector$stack[[depth]]
    if (!identical(frame$id, id)) {
      stop("Component profiler call stack was not LIFO.", call. = FALSE)
    }
    elapsed <- max(
      0, unname(proc.time()[["elapsed"]]) - frame$started
    )
    collector$stack <- collector$stack[-depth]
    if (length(collector$stack) > 0L) {
      parent <- collector$stack[[length(collector$stack)]]
      parent$child <- parent$child + elapsed
      collector$stack[[length(collector$stack)]] <- parent
    }
    collector$rows[[length(collector$rows) + 1L]] <- data.frame(
      CallOrder = as.integer(length(collector$rows) + 1L),
      Scope = frame$scope,
      Component = frame$component,
      Function = frame$name,
      InclusiveSeconds = elapsed,
      ExclusiveSeconds = max(0, elapsed - frame$child),
      Clock = "proc.time.elapsed",
      DecisionUse = "diagnostic_only",
      stringsAsFactors = FALSE
    )
    invisible(NULL)
  }

  make_wrapper <- function(name, original) {
    force(name)
    force(original)
    function(...) {
      id <- enter(name)
      on.exit(exit_call(id), add = TRUE)
      original(...)
    }
  }

  originals <- setNames(lapply(
    instrumented, getFromNamespace, ns = "mfrmr"
  ), instrumented)
  for (name in instrumented) {
    assignInNamespace(
      name, make_wrapper(name, originals[[name]]), ns = "mfrmr"
    )
  }

  stop_profile <- function() {
    if (isTRUE(collector$stopped)) {
      return(collector$result)
    }
    for (name in instrumented) {
      assignInNamespace(name, originals[[name]], ns = "mfrmr")
    }
    collector$stopped <- TRUE
    if (length(collector$stack) > 0L) {
      stop("Component profiler stopped with active calls.", call. = FALSE)
    }
    rows <- if (length(collector$rows) == 0L) {
      data.frame(
        CallOrder = integer(0), Scope = character(0),
        Component = character(0), Function = character(0),
        InclusiveSeconds = numeric(0), ExclusiveSeconds = numeric(0),
        Clock = character(0), DecisionUse = character(0)
      )
    } else {
      do.call(rbind, collector$rows)
    }
    rows <- rows[rows$Scope != "outside", , drop = FALSE]
    rownames(rows) <- NULL
    collector$result <- rows
    rows
  }

  list(stop = stop_profile)
}

mfrmr_jml_component_contract <- function(calls, method) {
  calls <- as.data.frame(calls, stringsAsFactors = FALSE)
  required <- c(
    "CallOrder", "Scope", "Component", "Function", "InclusiveSeconds",
    "ExclusiveSeconds", "Clock", "DecisionUse"
  )
  schema_valid <- identical(names(calls), required) && nrow(calls) > 0L &&
    all(is.finite(calls$InclusiveSeconds)) &&
    all(is.finite(calls$ExclusiveSeconds)) &&
    all(calls$InclusiveSeconds >= 0) &&
    all(calls$ExclusiveSeconds >= 0) &&
    all(calls$ExclusiveSeconds <= calls$InclusiveSeconds + 1e-8) &&
    all(calls$Clock == "proc.time.elapsed") &&
    all(calls$DecisionUse == "diagnostic_only")
  scope_total <- function(scope) {
    value <- calls$InclusiveSeconds[
      calls$Scope == scope & calls$Component == "scope_total"
    ]
    if (length(value) == 1L) value else NA_real_
  }
  exclusive_sum <- function(scope) {
    sum(calls$ExclusiveSeconds[calls$Scope == scope])
  }
  structural_total <- scope_total("structural")
  joint_total <- scope_total("joint")
  shared_total <- calls$InclusiveSeconds[
    calls$Scope == "shared" &
      calls$Function == "mfrmr_jml_recession_shared_geometry"
  ]
  shared_total <- if (length(shared_total) == 1L) {
    shared_total
  } else if (identical(method, "MML") && length(shared_total) == 0L) {
    0
  } else {
    NA_real_
  }
  decomposition_valid <-
    is.finite(structural_total) && is.finite(joint_total) &&
    is.finite(shared_total) &&
    abs(exclusive_sum("structural") - structural_total) <= 0.05 &&
    abs(exclusive_sum("joint") - joint_total) <= 0.05 &&
    abs(exclusive_sum("shared") - shared_total) <= 0.05
  construction_calls <- function(scope, component) {
    sum(calls$Scope == scope & calls$Component == component)
  }
  shared_reuse_valid <- if (identical(method, "JML")) {
    all(vapply(
      c("adjacent_design", "target_mapping", "contrast_construction"),
      function(component) {
        construction_calls("shared", component) == 1L &&
          construction_calls("structural", component) == 0L &&
          construction_calls("joint", component) == 0L
      }, logical(1)
    ))
  } else {
    nrow(calls[calls$Scope == "shared", , drop = FALSE]) == 0L
  }
  list(
    valid = isTRUE(schema_valid && decomposition_valid && shared_reuse_valid),
    schema_valid = isTRUE(schema_valid),
    decomposition_valid = isTRUE(decomposition_valid),
    shared_reuse_valid = isTRUE(shared_reuse_valid),
    shared_seconds = as.numeric(shared_total),
    structural_seconds = as.numeric(structural_total),
    joint_seconds = as.numeric(joint_total)
  )
}

mfrmr_jml_component_validate_baseline <- function(baseline_dir) {
  marker_path <- file.path(baseline_dir, "run-complete.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(e) e)
  if (inherits(marker, "error") || !identical(
    marker$schema, "mfrmr-jml-phase-profile-completion-v8"
  )) {
    stop("The Draft.53 v8 baseline marker is invalid.", call. = FALSE)
  }
  artifacts <- as.data.frame(marker$artifacts, stringsAsFactors = FALSE)
  valid <- nrow(artifacts) > 0L && all(vapply(
    seq_len(nrow(artifacts)), function(i) {
      path <- file.path(baseline_dir, artifacts$File[i])
      file.exists(path) &&
        identical(
          unname(file.info(path)$size), as.numeric(artifacts$Bytes[i])
        ) &&
        identical(
          mfrmr_gpcm_repilot_hash_file(path), artifacts$SHA256[i]
        )
    }, logical(1)
  )) && identical(
    mfrmr_gpcm_repilot_hash_object(artifacts),
    marker$artifact_inventory_sha256
  )
  if (!isTRUE(valid)) {
    stop("The Draft.53 v8 baseline artifact inventory changed.",
         call. = FALSE)
  }
  results <- utils::read.csv(
    file.path(baseline_dir, "run-results.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  if (nrow(results) != 19L || anyDuplicated(results$ScenarioId)) {
    stop("The Draft.53 v8 baseline result ledger is malformed.",
         call. = FALSE)
  }
  list(marker = marker, results = results,
       marker_sha256 = mfrmr_gpcm_repilot_hash_file(marker_path))
}

mfrmr_jml_component_compare_baseline <- function(results, baseline) {
  fields <- c(
    "DataHash", "CellTruthHash", "SemanticResultSHA256", "FitReadiness",
    "InferenceReady", "NumericalState", "BoundaryState", "OptimizerMethod",
    "StructuralAuditState", "StructuralAuditComplete",
    "StructuralTargetStatusSHA256", "JointAuditState", "JointAuditComplete",
    "JointTargetStatusSHA256", "JointRelevanceState", "JointNullspaceState"
  )
  baseline <- baseline[match(results$ScenarioId, baseline$ScenarioId), ]
  same_value <- function(x, y) {
    x <- as.character(x)
    y <- as.character(y)
    x[is.na(x) | !nzchar(x)] <- "<not_applicable>"
    y[is.na(y) | !nzchar(y)] <- "<not_applicable>"
    x == y
  }
  comparison <- data.frame(
    ScenarioId = results$ScenarioId,
    stringsAsFactors = FALSE
  )
  for (field in fields) {
    comparison[[paste0(field, "Match")]] <- same_value(
      results[[field]], baseline[[field]]
    )
  }
  comparison$AllEquivalent <- apply(
    comparison[, -1L, drop = FALSE], 1L, all
  )
  comparison
}

mfrmr_jml_component_summarize <- function(calls) {
  keys <- calls[c(
    "Method", "OptimizerRequested", "Scope", "Component", "Function"
  )]
  seconds <- aggregate(
    calls[c("InclusiveSeconds", "ExclusiveSeconds")], keys, sum
  )
  count <- aggregate(rep(1L, nrow(calls)), keys, sum)
  names(count)[ncol(count)] <- "Calls"
  merge(seconds, count, by = names(keys), sort = FALSE)
}

mfrmr_run_jml_recession_component_profile <- function(
    dry_run = TRUE, authorize = FALSE, maxit = 60L, quad_points = 7L,
    reltol = 1e-9, baseline_dir = NULL, output_dir = NULL,
    progress = interactive()) {
  mfrmr_jml_component_require_support()
  registry <- mfrmr_jml_phase_registry()
  phase_identity <- mfrmr_jml_phase_identity(
    registry, maxit = maxit, quad_points = quad_points, reltol = reltol
  )
  if (isTRUE(dry_run)) {
    return(list(
      schema = "mfrmr-jml-recession-component-profile-v1",
      registry = registry,
      phase_identity = phase_identity,
      component_functions = mfrmr_jml_component_function_map(),
      confirmation_authorized = FALSE
    ))
  }
  if (!isTRUE(authorize)) {
    stop("Live component profiling requires `authorize = TRUE`.",
         call. = FALSE)
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
  baseline <- mfrmr_jml_component_validate_baseline(baseline_dir)

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
  components <- vector("list", nrow(registry))
  cursor <- 0L
  for (cell_id in unique(registry$DataCellId)) {
    cell <- cells[match(cell_id, cells$DataCellId), , drop = FALSE]
    generated <- mfrmr_jml_profile_build(cell)
    routes <- registry[registry$DataCellId == cell_id, , drop = FALSE]
    if (isTRUE(progress)) message("[component] ", cell_id)
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
        component_profiler = mfrmr_jml_component_profiler_start
      )
      calls <- route$components
      contract <- mfrmr_jml_component_contract(
        calls, as.character(route_row$Method)
      )
      route$result$ComponentTimingContractValid <- contract$valid
      route$result$ComponentTimingRows <- nrow(calls)
      route$result$SharedGeometrySeconds <- contract$shared_seconds
      route$result$StructuralComponentSeconds <- contract$structural_seconds
      route$result$JointComponentSeconds <- contract$joint_seconds
      calls$ScenarioId <- as.character(route_row$ScenarioId)
      calls$DataCellId <- as.character(route_row$DataCellId)
      calls$Method <- as.character(route_row$Method)
      calls$OptimizerRequested <- as.character(
        route_row$OptimizerRequested
      )
      calls <- calls[, c(
        "ScenarioId", "DataCellId", "Method", "OptimizerRequested",
        "CallOrder", "Scope", "Component", "Function",
        "InclusiveSeconds", "ExclusiveSeconds", "Clock", "DecisionUse"
      )]
      results[[cursor]] <- route$result
      phases[[cursor]] <- route$phases
      components[[cursor]] <- calls
    }
  }
  results <- do.call(rbind, results)
  phases <- do.call(rbind, phases)
  components <- do.call(rbind, components)
  rownames(results) <- rownames(phases) <- rownames(components) <- NULL
  comparison <- mfrmr_jml_component_compare_baseline(
    results, baseline$results
  )
  registry_valid <- identical(results$ScenarioId, registry$ScenarioId)
  completion_valid <- registry_valid &&
    all(results$FitSucceeded) && all(results$TimingContractValid) &&
    all(results$ComponentTimingContractValid) && !any(results$FalseReady) &&
    all(comparison$AllEquivalent)
  if (!isTRUE(completion_valid)) {
    failed <- c(
      if (!registry_valid) "registry_order" else character(0),
      if (any(!results$FitSucceeded)) paste0(
        "fit:", results$ScenarioId[!results$FitSucceeded]
      ) else character(0),
      if (any(!results$TimingContractValid)) paste0(
        "phase:", results$ScenarioId[!results$TimingContractValid]
      ) else character(0),
      if (any(!results$ComponentTimingContractValid)) paste0(
        "component:",
        results$ScenarioId[!results$ComponentTimingContractValid]
      ) else character(0),
      if (any(results$FalseReady)) paste0(
        "false_ready:", results$ScenarioId[results$FalseReady]
      ) else character(0),
      if (any(!comparison$AllEquivalent)) paste0(
        "baseline:", comparison$ScenarioId[!comparison$AllEquivalent]
      ) else character(0)
    )
    stop(
      "Component-profile completion or equivalence failed: ",
      paste(failed, collapse = "; "), call. = FALSE
    )
  }
  component_summary <- mfrmr_jml_component_summarize(components)
  run_summary <- data.frame(
    Schema = "mfrmr-jml-recession-component-profile-v1",
    Routes = nrow(results), JMLRoutes = sum(results$Method == "JML"),
    MMLRoutes = sum(results$Method == "MML"),
    FitsSucceeded = sum(results$FitSucceeded),
    TimingContractsPassed = sum(results$TimingContractValid),
    ComponentContractsPassed = sum(results$ComponentTimingContractValid),
    BaselineEquivalentRoutes = sum(comparison$AllEquivalent),
    FalseReady = sum(results$FalseReady),
    SharedGeometrySeconds = sum(
      results$SharedGeometrySeconds[results$Method == "JML"]
    ),
    StructuralComponentSeconds = sum(
      results$StructuralComponentSeconds[results$Method == "JML"]
    ),
    JointComponentSeconds = sum(
      results$JointComponentSeconds[results$Method == "JML"]
    ),
    ConfirmationAuthorized = FALSE,
    RuntimeCriteriaFrozen = FALSE,
    EvidenceUse = "component_attribution_calibration_only",
    stringsAsFactors = FALSE
  )

  runner_path <- file.path(
    mfrmr_jml_component_source_dir,
    "jml-recession-component-profile-pilot-0.2.3.R"
  )
  identity <- data.frame(
    Schema = "mfrmr-jml-recession-component-profile-identity-v1",
    PhaseExecutionSHA256 = phase_identity$execution$ExecutionSHA256,
    InstalledPackageSHA256 = phase_identity$package$PackageSHA256,
    RunnerSHA256 = mfrmr_gpcm_repilot_hash_file(runner_path),
    BaselineCompletionSHA256 = baseline$marker_sha256,
    BaselineArtifactInventorySHA256 =
      baseline$marker$artifact_inventory_sha256,
    stringsAsFactors = FALSE
  )
  identity$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(identity)

  out <- list(
    registry = registry, results = results, phases = phases,
    components = components, component_summary = component_summary,
    comparison = comparison, run_summary = run_summary,
    identity = identity, package_identity = phase_identity$package,
    confirmation_authorized = FALSE, session_info = utils::sessionInfo()
  )
  files <- list(
    "registry.csv" = registry,
    "run-results.csv" = results,
    "phase-timings.csv" = phases,
    "component-calls.csv" = components,
    "component-summary.csv" = component_summary,
    "baseline-comparison.csv" = comparison,
    "run-summary.csv" = run_summary,
    "execution-identity.csv" = identity,
    "package-identity.csv" = phase_identity$package
  )
  for (name in names(files)) {
    utils::write.csv(
      files[[name]], file.path(staging, name), row.names = FALSE, na = ""
    )
  }
  saveRDS(out, file.path(staging, "jml-recession-component-profile.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  completion <- list(
    schema = "mfrmr-jml-recession-component-profile-completion-v1",
    execution_sha256 = identity$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) {
    stop("Completed component-profile evidence could not be promoted.",
         call. = FALSE)
  }
  promoted <- TRUE
  invisible(out)
}
