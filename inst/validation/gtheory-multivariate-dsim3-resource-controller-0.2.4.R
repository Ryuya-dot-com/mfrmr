# Internal D-SIM-3 five-scope resource-controller qualification.
#
# This fifth shared-substrate layer executes nonreserved mechanics probes in
# isolated R subprocesses. It qualifies enforcement and receipting only; it
# does not open an 855 identity, generate an exploratory response, call a model
# backend, fit a model, compute a metric, or authorize exploration.

mfrmr_gtds3u_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3e_plan",
    "mfrmr_gtds3e_assert_plan", "mfrmr_gtds3r_manifest",
    "mfrmr_gtds3r_assert_manifest"
  )
  target <- environment(mfrmr_gtds3u_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 execution and route/receipt chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3u_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3u_file_hash <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("D-SIM-3 resource qualification requires `digest`.", call. = FALSE)
  }
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) stop("A worker file is required.", call. = FALSE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtds3u_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-RESOURCE-CONTROLLER-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentRouteReceiptContractId =
      "MFRMR-GTHEORY-MV-DSIM3-ROUTE-RECEIPT-ADAPTER-V1",
    ParentRouteReceiptContractHash =
      "0b74d833dc9bff44e3eded32261258b8dbd5ca6a2a30805c871d2cc22c9d0129",
    ParentRouteReceiptManifestHash =
      "6a59dc1a7874f731554baff7a134b8b52ad18614e26ee80470d08ffbd8372e9f",
    ParentExecutionPlanHash =
      "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7",
    ParentResourceRegistryHash =
      "0d9cdfa0cd36b6750ac34aa09e9cd196127cda0718a6d525788fadc673c19195",
    WorkerFile =
      "gtheory-multivariate-dsim3-resource-probe-worker-0.2.4.R",
    WorkerSHA256 =
      "44c2a2eb527b53d220cdb8f2e52c34e89651a005ed475331ddac15a868b0a4d0",
    ParentRouteReceiptRecord = paste0(
      "gtheory-multivariate-dsim3-route-receipt-adapter-record-0.2.4.md"
    )
  )
}

mfrmr_gtds3u_contract <- function() {
  mfrmr_gtds3u_require_primitives()
  identity <- mfrmr_gtds3u_identity()
  payload <- c(identity, list(
    ExpectedResourceScopeCount = 5L,
    ExpectedProcessProbeCount = 15L,
    ExpectedProbeKindsPerScope = c("success", "wall_timeout", "peak_rss"),
    ExpectedConcurrencyProbeCount = 1L,
    ConcurrencyProbeRequiresLiveWorker = TRUE,
    ExpectedCompositeStopProbeCount = 2L,
    SuccessProbeWallMilliseconds = 5000L,
    SuccessProbePeakRssMiB = 512L,
    SuccessProbeDurationMilliseconds = 20L,
    WallProbeWallMilliseconds = 200L,
    WallProbePeakRssMiB = 512L,
    WallProbeDurationMilliseconds = 2000L,
    MemoryProbeWallMilliseconds = 5000L,
    MemoryProbePeakRssMiB = 160L,
    MemoryProbeAllocationMiB = 192L,
    MemoryProbeHoldMilliseconds = 2000L,
    PollIntervalMilliseconds = 20L,
    TerminationGraceMilliseconds = 2000L,
    ConcurrencyHoldMilliseconds = 2000L,
    RegisteredCompositeProbeUnitCount = 3L,
    ExactRuntimeMeasurementsRetained = FALSE,
    ProbeBudgetsAreProductionCapacityClaims = FALSE,
    SameControllerPathUsedForProductionLimits = TRUE,
    AtomicResourceScopes = c(
      "dataset_generation", "one_route_fit", "one_route_metric"
    ),
    CompositeStopScopes = c(
      "one_dataset_pipeline", "complete_exploratory_run"
    ),
    AtomicTerminalProjection = c(
      dataset_generation = "generation_resource_limit",
      one_route_fit = "fit_resource_limit",
      one_route_metric = "metric_resource_limit"
    ),
    CompositeStopCreatesUnitTerminalReceipt = FALSE,
    UnlaunchedUnitFailureImputationAllowed = FALSE,
    PeerSuppressionAfterAtomicFailureAllowed = FALSE,
    RegisteredUnitDeletionAllowed = FALSE,
    ReplacementLaunchAllowed = FALSE,
    Planned855RngStreamAllowed = FALSE,
    BackendCallAllowed = FALSE,
    FitAllowed = FALSE,
    MetricAllowed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3u_hash(payload)
  )), class = c("mfrmr_gtds3u_contract", "list"))
}

mfrmr_gtds3u_worker_functions <- function() {
  c(
    "mfrmr_gtds3uw_stop", "mfrmr_gtds3uw_args",
    "mfrmr_gtds3uw_touch_memory", "mfrmr_gtds3uw_main"
  )
}

mfrmr_gtds3u_worker_identity <- function(worker_path) {
  worker_path <- normalizePath(worker_path, mustWork = TRUE)
  environment <- new.env(parent = baseenv())
  sys.source(worker_path, envir = environment)
  functions <- mfrmr_gtds3u_worker_functions()
  bindings <- sort(ls(environment, all.names = TRUE), method = "radix")
  if (!identical(bindings, sort(functions, method = "radix"))) {
    stop("The resource-probe worker namespace changed.", call. = FALSE)
  }
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = environment, inherits = FALSE)
      mfrmr_gtds3u_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3u_worker_static_audit <- function(worker_path) {
  text <- paste(readLines(
    normalizePath(worker_path, mustWork = TRUE), warn = FALSE,
    encoding = "UTF-8"
  ), collapse = "\n")
  forbidden <- c(
    "source", "sys.source", "readRDS", "download.file", "system",
    "system2", "set.seed", "rnorm", "runif", "lmer", "glmmTMB",
    "fit_mfrm", "mfrm_estimate"
  )
  present <- vapply(forbidden, function(name) {
    grepl(
      paste0("\\b", gsub("\\.", "\\\\.", name), "\\s*\\("),
      text, perl = TRUE
    )
  }, logical(1L))
  data.frame(
    ForbiddenCallOrdinal = seq_along(forbidden),
    ForbiddenCall = forbidden, Present = unname(present),
    Passed = !unname(present), stringsAsFactors = FALSE
  )
}

mfrmr_gtds3u_validate_contract <- function(
    contract = mfrmr_gtds3u_contract(), execution_plan = NULL,
    route_manifest = NULL, worker_path) {
  mfrmr_gtds3u_require_primitives()
  if (is.null(execution_plan)) execution_plan <- mfrmr_gtds3e_plan()
  if (is.null(route_manifest)) route_manifest <- mfrmr_gtds3r_manifest()
  mfrmr_gtds3e_assert_plan(execution_plan)
  mfrmr_gtds3r_assert_manifest(route_manifest)
  canonical <- mfrmr_gtds3u_contract()
  resources <- execution_plan$Contract$ResourceLimitRegistry
  valid <- inherits(contract, "mfrmr_gtds3u_contract") &&
    identical(contract, canonical) && identical(
      contract$ParentRouteReceiptContractHash,
      route_manifest$Contract$ContractHash
    ) && identical(
      contract$ParentRouteReceiptManifestHash, route_manifest$ManifestHash
    ) && identical(
      contract$ParentExecutionPlanHash, execution_plan$PlanHash
    ) && identical(
      contract$ParentResourceRegistryHash, mfrmr_gtds3u_hash(resources)
    ) && identical(
      contract$WorkerSHA256, mfrmr_gtds3u_file_hash(worker_path)
    ) && identical(nrow(resources), 5L) &&
    identical(resources$MaximumConcurrentWorkers, rep(1L, 5L)) &&
    identical(contract$ExpectedProcessProbeCount, 15L) &&
    !isTRUE(contract$ExactRuntimeMeasurementsRetained) &&
    !isTRUE(contract$ProbeBudgetsAreProductionCapacityClaims) &&
    isTRUE(contract$SameControllerPathUsedForProductionLimits) &&
    !isTRUE(contract$CompositeStopCreatesUnitTerminalReceipt) &&
    !isTRUE(contract$UnlaunchedUnitFailureImputationAllowed) &&
    !isTRUE(contract$PeerSuppressionAfterAtomicFailureAllowed) &&
    !isTRUE(contract$RegisteredUnitDeletionAllowed) &&
    !isTRUE(contract$ReplacementLaunchAllowed) &&
    !isTRUE(contract$Planned855RngStreamAllowed) &&
    !isTRUE(contract$BackendCallAllowed) && !isTRUE(contract$FitAllowed) &&
    !isTRUE(contract$MetricAllowed) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 resource-controller contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3u_scope <- function(scope_id, execution_plan) {
  rows <- execution_plan$Contract$ResourceLimitRegistry
  row <- rows[rows$ScopeId == scope_id, , drop = FALSE]
  if (nrow(row) != 1L) {
    stop("A frozen D-SIM-3 resource scope is required.", call. = FALSE)
  }
  row
}

mfrmr_gtds3u_terminal_projection <- function(scope_id, contract) {
  if (scope_id %in% names(contract$AtomicTerminalProjection)) {
    unname(contract$AtomicTerminalProjection[[scope_id]])
  } else NA_character_
}

mfrmr_gtds3u_launch_admission <- function(
    active_workers, stop_new_launches, maximum_concurrent_workers) {
  values <- c(active_workers, maximum_concurrent_workers)
  if (anyNA(values) || any(values < 0L) ||
      maximum_concurrent_workers < 1L ||
      length(stop_new_launches) != 1L || is.na(stop_new_launches)) {
    stop("Resource launch admission requires a valid controller state.",
         call. = FALSE)
  }
  reason <- if (isTRUE(stop_new_launches)) {
    "controller_stop_new_launches"
  } else if (active_workers >= maximum_concurrent_workers) {
    "maximum_concurrent_workers_reached"
  } else "admitted"
  data.frame(
    ActiveWorkers = as.integer(active_workers),
    MaximumConcurrentWorkers = as.integer(maximum_concurrent_workers),
    StopNewLaunches = isTRUE(stop_new_launches),
    LaunchAdmitted = identical(reason, "admitted"),
    AdmissionReason = reason,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3u_terminate_process <- function(process, contract) {
  if (!inherits(process, "process")) {
    stop("A processx process is required for termination.", call. = FALSE)
  }
  signal_sent <- tryCatch({
    process$kill_tree()
    TRUE
  }, error = function(condition) FALSE)
  deadline <- unname(proc.time()[["elapsed"]]) +
    contract$TerminationGraceMilliseconds / 1000
  while (process$is_alive() &&
         unname(proc.time()[["elapsed"]]) < deadline) {
    Sys.sleep(contract$PollIntervalMilliseconds / 1000)
  }
  list(
    SignalSent = signal_sent,
    ProcessTerminated = !process$is_alive()
  )
}

mfrmr_gtds3u_run_process <- function(
    scope_id, action, duration_milliseconds, allocation_mib,
    maximum_wall_milliseconds, maximum_peak_rss_mib,
    execution_plan, worker_path, contract) {
  if (!requireNamespace("processx", quietly = TRUE)) {
    stop("D-SIM-3 resource qualification requires `processx`.",
         call. = FALSE)
  }
  scope <- mfrmr_gtds3u_scope(scope_id, execution_plan)
  admission <- mfrmr_gtds3u_launch_admission(
    0L, FALSE, scope$MaximumConcurrentWorkers[[1L]]
  )
  if (!admission$LaunchAdmitted[[1L]]) {
    stop("The mechanics probe was not admitted.", call. = FALSE)
  }
  rscript <- normalizePath(
    file.path(R.home("bin"), "Rscript"), mustWork = TRUE
  )
  arguments <- c(
    "--vanilla", normalizePath(worker_path, mustWork = TRUE), action,
    format(duration_milliseconds / 1000, scientific = FALSE, trim = TRUE),
    as.character(as.integer(allocation_mib))
  )
  process <- processx::process$new(
    rscript, arguments, stdout = "|", stderr = "|", cleanup = TRUE,
    cleanup_tree = TRUE, supervise = FALSE
  )
  on.exit({
    if (process$is_alive()) {
      try(mfrmr_gtds3u_terminate_process(process, contract), silent = TRUE)
    }
  }, add = TRUE)
  started <- unname(proc.time()[["elapsed"]])
  peak_rss_mib <- 0
  memory_observed <- FALSE
  trigger <- ""
  while (process$is_alive()) {
    memory <- tryCatch(
      process$get_memory_info(), error = function(condition) NULL
    )
    if (!is.null(memory) && "rss" %in% names(memory) &&
        is.finite(memory[["rss"]])) {
      memory_observed <- TRUE
      peak_rss_mib <- max(
        peak_rss_mib, unname(memory[["rss"]]) / 1024^2
      )
    }
    elapsed_milliseconds <-
      (unname(proc.time()[["elapsed"]]) - started) * 1000
    if (memory_observed && peak_rss_mib > maximum_peak_rss_mib) {
      trigger <- "peak_rss_limit"
    } else if (elapsed_milliseconds > maximum_wall_milliseconds) {
      trigger <- "wall_time_limit"
    }
    if (nzchar(trigger)) break
    Sys.sleep(contract$PollIntervalMilliseconds / 1000)
  }
  termination <- list(SignalSent = FALSE, ProcessTerminated = FALSE)
  if (nzchar(trigger)) {
    termination <- mfrmr_gtds3u_terminate_process(process, contract)
    if (!termination$SignalSent || !termination$ProcessTerminated) {
      stop("The resource controller could not terminate its probe process.",
           call. = FALSE)
    }
  } else {
    process$wait(timeout = contract$TerminationGraceMilliseconds)
  }
  elapsed_milliseconds <- as.integer(round(
    (unname(proc.time()[["elapsed"]]) - started) * 1000
  ))
  output <- tryCatch(process$read_all_output(), error = function(condition) "")
  error <- tryCatch(process$read_all_error(), error = function(condition) "")
  exit_status <- tryCatch(
    process$get_exit_status(), error = function(condition) NA_integer_
  )
  clean <- !nzchar(trigger) && identical(as.integer(exit_status), 0L) &&
    grepl("DSIM3_RESOURCE_PROBE_COMPLETE", output, fixed = TRUE)
  observed_outcome <- if (clean) "success" else trigger
  list(
    ScopeId = scope_id, Action = action,
    MaximumWallMilliseconds = as.integer(maximum_wall_milliseconds),
    MaximumPeakRssMiB = as.integer(maximum_peak_rss_mib),
    ProcessStarted = TRUE, ObservedOutcome = observed_outcome,
    SignalSent = termination$SignalSent,
    ProcessTerminated = if (nzchar(trigger)) {
      termination$ProcessTerminated
    } else !process$is_alive(),
    ExitStatus = as.integer(exit_status),
    ElapsedMilliseconds = elapsed_milliseconds,
    PeakRssMiB = peak_rss_mib,
    MemoryObserved = memory_observed,
    CompletionMarkerObserved = grepl(
      "DSIM3_RESOURCE_PROBE_COMPLETE", output, fixed = TRUE
    ),
    Stdout = output, Stderr = error
  )
}

mfrmr_gtds3u_probe_specification <- function(contract) {
  data.frame(
    ProbeKind = c("success", "wall_timeout", "peak_rss"),
    Action = c("success", "sleep", "memory"),
    DurationMilliseconds = c(
      contract$SuccessProbeDurationMilliseconds,
      contract$WallProbeDurationMilliseconds,
      contract$MemoryProbeHoldMilliseconds
    ),
    AllocationMiB = c(0L, 0L, contract$MemoryProbeAllocationMiB),
    MaximumWallMilliseconds = c(
      contract$SuccessProbeWallMilliseconds,
      contract$WallProbeWallMilliseconds,
      contract$MemoryProbeWallMilliseconds
    ),
    MaximumPeakRssMiB = c(
      contract$SuccessProbePeakRssMiB,
      contract$WallProbePeakRssMiB,
      contract$MemoryProbePeakRssMiB
    ),
    ExpectedOutcome = c("success", "wall_time_limit", "peak_rss_limit"),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3u_normalize_process_receipt <- function(
    result, probe, scope, contract) {
  expected <- probe$ExpectedOutcome[[1L]]
  observed <- result$ObservedOutcome
  success <- identical(expected, "success")
  normalized <- list(
    ReceiptSchema = "dsim3_resource_process_receipt_v1",
    ScopeId = result$ScopeId,
    ProbeKind = probe$ProbeKind[[1L]],
    Action = result$Action,
    ExpectedOutcome = expected,
    ObservedOutcome = observed,
    ProductionMaximumWallSeconds = scope$MaximumWallSeconds[[1L]],
    ProductionMaximumPeakRssMiB = scope$MaximumPeakRssMiB[[1L]],
    ProductionMaximumConcurrentWorkers =
      scope$MaximumConcurrentWorkers[[1L]],
    ProductionExceedanceDisposition = scope$ExceedanceDisposition[[1L]],
    ProbeMaximumWallMilliseconds = result$MaximumWallMilliseconds,
    ProbeMaximumPeakRssMiB = result$MaximumPeakRssMiB,
    ProcessStarted = result$ProcessStarted,
    ProcessTerminated = result$ProcessTerminated,
    LimitSignalSent = result$SignalSent,
    CompletionMarkerObserved = result$CompletionMarkerObserved,
    WallMeasurementObserved = is.finite(result$ElapsedMilliseconds),
    PeakRssMeasurementObserved = result$MemoryObserved,
    WallRelation = if (observed == "wall_time_limit") {
      "exceeded_probe_limit"
    } else "not_controller_terminal_trigger",
    PeakRssRelation = if (observed == "peak_rss_limit") {
      "exceeded_probe_limit"
    } else "not_controller_terminal_trigger",
    ExitDisposition = if (success) "clean_exit" else
      "controller_terminated",
    ProjectedUnitTerminalState = mfrmr_gtds3u_terminal_projection(
      result$ScopeId, contract
    ),
    ControllerReceiptRequired = TRUE,
    CountsIn855Denominator = FALSE,
    Planned855Identity = FALSE,
    BackendCallMade = FALSE, FitReturned = FALSE, MetricComputed = FALSE,
    ExactRuntimeMeasurementsRetained = FALSE,
    ProbeQualified = identical(observed, expected) &&
      isTRUE(result$ProcessStarted) &&
      isTRUE(result$ProcessTerminated) &&
      isTRUE(result$MemoryObserved) &&
      (success || isTRUE(result$SignalSent)) &&
      (!success || isTRUE(result$CompletionMarkerObserved))
  )
  structure(c(normalized, list(
    ReceiptHash = mfrmr_gtds3u_hash(normalized)
  )), class = c("mfrmr_gtds3u_process_receipt", "list"))
}

mfrmr_gtds3u_run_scope_probes <- function(
    execution_plan, worker_path, contract) {
  resources <- execution_plan$Contract$ResourceLimitRegistry
  specification <- mfrmr_gtds3u_probe_specification(contract)
  rows <- vector("list", nrow(resources) * nrow(specification))
  cursor <- 0L
  for (scope_index in seq_len(nrow(resources))) {
    scope <- resources[scope_index, , drop = FALSE]
    for (probe_index in seq_len(nrow(specification))) {
      cursor <- cursor + 1L
      probe <- specification[probe_index, , drop = FALSE]
      result <- mfrmr_gtds3u_run_process(
        scope$ScopeId[[1L]], probe$Action[[1L]],
        probe$DurationMilliseconds[[1L]], probe$AllocationMiB[[1L]],
        probe$MaximumWallMilliseconds[[1L]],
        probe$MaximumPeakRssMiB[[1L]], execution_plan, worker_path,
        contract
      )
      receipt <- mfrmr_gtds3u_normalize_process_receipt(
        result, probe, scope, contract
      )
      rows[[cursor]] <- data.frame(
        ProbeOrdinal = cursor,
        ScopeId = receipt$ScopeId, ProbeKind = receipt$ProbeKind,
        Action = receipt$Action,
        ExpectedOutcome = receipt$ExpectedOutcome,
        ObservedOutcome = receipt$ObservedOutcome,
        ProductionMaximumWallSeconds =
          receipt$ProductionMaximumWallSeconds,
        ProductionMaximumPeakRssMiB =
          receipt$ProductionMaximumPeakRssMiB,
        ProductionMaximumConcurrentWorkers =
          receipt$ProductionMaximumConcurrentWorkers,
        ProductionExceedanceDisposition =
          receipt$ProductionExceedanceDisposition,
        ProbeMaximumWallMilliseconds =
          receipt$ProbeMaximumWallMilliseconds,
        ProbeMaximumPeakRssMiB = receipt$ProbeMaximumPeakRssMiB,
        ProcessStarted = receipt$ProcessStarted,
        ProcessTerminated = receipt$ProcessTerminated,
        LimitSignalSent = receipt$LimitSignalSent,
        CompletionMarkerObserved = receipt$CompletionMarkerObserved,
        WallMeasurementObserved = receipt$WallMeasurementObserved,
        PeakRssMeasurementObserved = receipt$PeakRssMeasurementObserved,
        WallRelation = receipt$WallRelation,
        PeakRssRelation = receipt$PeakRssRelation,
        ExitDisposition = receipt$ExitDisposition,
        ProjectedUnitTerminalState =
          receipt$ProjectedUnitTerminalState,
        ControllerReceiptRequired = receipt$ControllerReceiptRequired,
        CountsIn855Denominator = receipt$CountsIn855Denominator,
        Planned855Identity = receipt$Planned855Identity,
        BackendCallMade = receipt$BackendCallMade,
        FitReturned = receipt$FitReturned,
        MetricComputed = receipt$MetricComputed,
        ExactRuntimeMeasurementsRetained =
          receipt$ExactRuntimeMeasurementsRetained,
        ProbeQualified = receipt$ProbeQualified,
        ReceiptHash = receipt$ReceiptHash,
        stringsAsFactors = FALSE
      )
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3u_concurrency_probe <- function(
    execution_plan, worker_path, contract) {
  if (!requireNamespace("processx", quietly = TRUE)) {
    stop("D-SIM-3 resource qualification requires `processx`.",
         call. = FALSE)
  }
  scope <- mfrmr_gtds3u_scope("complete_exploratory_run", execution_plan)
  first <- mfrmr_gtds3u_launch_admission(
    0L, FALSE, scope$MaximumConcurrentWorkers[[1L]]
  )
  rscript <- normalizePath(
    file.path(R.home("bin"), "Rscript"), mustWork = TRUE
  )
  process <- processx::process$new(
    rscript,
    c(
      "--vanilla", normalizePath(worker_path, mustWork = TRUE), "hold",
      format(
        contract$ConcurrencyHoldMilliseconds / 1000,
        scientific = FALSE, trim = TRUE
      ), "0"
    ),
    stdout = "|", stderr = "|", cleanup = TRUE, cleanup_tree = TRUE,
    supervise = FALSE
  )
  on.exit({
    if (process$is_alive()) {
      try(mfrmr_gtds3u_terminate_process(process, contract), silent = TRUE)
    }
  }, add = TRUE)
  deadline <- unname(proc.time()[["elapsed"]]) + 1
  while (!process$is_alive() && unname(proc.time()[["elapsed"]]) < deadline) {
    Sys.sleep(contract$PollIntervalMilliseconds / 1000)
  }
  first_alive <- process$is_alive()
  second <- mfrmr_gtds3u_launch_admission(
    as.integer(first_alive), FALSE,
    scope$MaximumConcurrentWorkers[[1L]]
  )
  termination <- mfrmr_gtds3u_terminate_process(process, contract)
  payload <- list(
    ReceiptSchema = "dsim3_resource_concurrency_receipt_v1",
    ScopeId = scope$ScopeId[[1L]],
    ProductionMaximumConcurrentWorkers =
      scope$MaximumConcurrentWorkers[[1L]],
    FirstLaunchAdmitted = first$LaunchAdmitted[[1L]],
    FirstProcessAliveAtSecondAdmission = first_alive,
    SecondLaunchAdmitted = second$LaunchAdmitted[[1L]],
    SecondAdmissionReason = second$AdmissionReason[[1L]],
    FirstProcessTerminated = termination$ProcessTerminated,
    RegisteredUnitDeletionAllowed = FALSE,
    CountsIn855Denominator = FALSE,
    Planned855Identity = FALSE,
    ConcurrencyQualified = first$LaunchAdmitted[[1L]] &&
      first_alive &&
      !second$LaunchAdmitted[[1L]] && identical(
        second$AdmissionReason[[1L]],
        "maximum_concurrent_workers_reached"
      ) && termination$ProcessTerminated
  )
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtds3u_hash(payload)
  )), class = c("mfrmr_gtds3u_concurrency_receipt", "list"))
}

mfrmr_gtds3u_composite_stop_registry <- function(
    process_registry, execution_plan, contract) {
  scopes <- contract$CompositeStopScopes
  rows <- lapply(seq_along(scopes), function(index) {
    scope_id <- scopes[[index]]
    timeout <- process_registry[
      process_registry$ScopeId == scope_id &
        process_registry$ProbeKind == "wall_timeout", , drop = FALSE
    ]
    scope <- mfrmr_gtds3u_scope(scope_id, execution_plan)
    stop_new <- nrow(timeout) == 1L && timeout$ProbeQualified[[1L]]
    later <- mfrmr_gtds3u_launch_admission(
      0L, stop_new, scope$MaximumConcurrentWorkers[[1L]]
    )
    payload <- list(
      ReceiptSchema = "dsim3_resource_composite_stop_receipt_v1",
      ScopeId = scope_id,
      ProductionExceedanceDisposition =
        scope$ExceedanceDisposition[[1L]],
      TriggerProbeReceiptHash = timeout$ReceiptHash[[1L]],
      RegisteredUnitCount = contract$RegisteredCompositeProbeUnitCount,
      LaunchedUnitCount = 1L,
      LaterRegisteredUnitCount =
        contract$RegisteredCompositeProbeUnitCount - 1L,
      StopNewLaunches = stop_new,
      LaterLaunchAdmitted = later$LaunchAdmitted[[1L]],
      LaterAdmissionReason = later$AdmissionReason[[1L]],
      AllRegisteredUnitsRetained = TRUE,
      UnlaunchedUnitTerminalReceiptCreated = FALSE,
      UnlaunchedUnitFailureImputed = FALSE,
      ReplacementLaunchCreated = FALSE,
      CountsIn855Denominator = FALSE,
      Planned855Identity = FALSE,
      CompositeStopQualified = stop_new &&
        !later$LaunchAdmitted[[1L]] &&
        identical(
          later$AdmissionReason[[1L]], "controller_stop_new_launches"
        )
    )
    c(payload, list(ReceiptHash = mfrmr_gtds3u_hash(payload)))
  })
  output <- do.call(rbind, lapply(seq_along(rows), function(index) {
    as.data.frame(c(list(CompositeStopOrdinal = as.integer(index)),
                    rows[[index]]), stringsAsFactors = FALSE)
  }))
  row.names(output) <- NULL
  logical_columns <- c(
    "StopNewLaunches", "LaterLaunchAdmitted", "AllRegisteredUnitsRetained",
    "UnlaunchedUnitTerminalReceiptCreated",
    "UnlaunchedUnitFailureImputed", "ReplacementLaunchCreated",
    "CountsIn855Denominator", "Planned855Identity",
    "CompositeStopQualified"
  )
  output[logical_columns] <- lapply(output[logical_columns], as.logical)
  integer_columns <- c(
    "CompositeStopOrdinal", "RegisteredUnitCount", "LaunchedUnitCount",
    "LaterRegisteredUnitCount"
  )
  output[integer_columns] <- lapply(output[integer_columns], as.integer)
  output
}

mfrmr_gtds3u_scope_qualification <- function(
    process_registry, concurrency_receipt, composite_registry,
    execution_plan, contract) {
  resources <- execution_plan$Contract$ResourceLimitRegistry
  rows <- lapply(seq_len(nrow(resources)), function(index) {
    scope <- resources[index, , drop = FALSE]
    probes <- process_registry[
      process_registry$ScopeId == scope$ScopeId[[1L]], , drop = FALSE
    ]
    composite <- composite_registry[
      composite_registry$ScopeId == scope$ScopeId[[1L]], , drop = FALSE
    ]
    atomic <- scope$ScopeId[[1L]] %in% contract$AtomicResourceScopes
    success <- probes$ProbeQualified[probes$ProbeKind == "success"]
    wall <- probes$ProbeQualified[probes$ProbeKind == "wall_timeout"]
    memory <- probes$ProbeQualified[probes$ProbeKind == "peak_rss"]
    controller_stop <- if (atomic) TRUE else
      nrow(composite) == 1L && composite$CompositeStopQualified[[1L]]
    projection <- unique(probes$ProjectedUnitTerminalState)
    projection <- projection[!is.na(projection)]
    projection_ready <- if (atomic) {
      length(projection) == 1L && identical(
        projection, unname(contract$AtomicTerminalProjection[[
          scope$ScopeId[[1L]]
        ]])
      )
    } else NA
    data.frame(
      ResourceQualificationOrdinal = as.integer(index),
      ScopeId = scope$ScopeId,
      MaximumWallSeconds = scope$MaximumWallSeconds,
      MaximumPeakRssMiB = scope$MaximumPeakRssMiB,
      MaximumConcurrentWorkers = scope$MaximumConcurrentWorkers,
      ExceedanceDisposition = scope$ExceedanceDisposition,
      LimitContractBound = TRUE,
      SuccessProbeReady = length(success) == 1L && success,
      WallTimeoutEnforcementReady = length(wall) == 1L && wall,
      PeakRssEnforcementReady = length(memory) == 1L && memory,
      ConcurrencyEnforcementReady =
        concurrency_receipt$ConcurrencyQualified,
      ExceedanceReceiptReady = nrow(probes) == 3L &&
        all(probes$ControllerReceiptRequired),
      AtomicUnitTerminalProjectionReady = projection_ready,
      CompositeStopReceiptReady = if (atomic) NA else controller_stop,
      RegisteredUnitRetentionReady = if (atomic) TRUE else
        composite$AllRegisteredUnitsRetained[[1L]],
      ProbeBudgetsAreProductionCapacityClaims = FALSE,
      ResourceScopeQualified =
        length(success) == 1L && success &&
        length(wall) == 1L && wall &&
        length(memory) == 1L && memory &&
        concurrency_receipt$ConcurrencyQualified && controller_stop &&
        if (atomic) projection_ready else TRUE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3u_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3u_require_primitives", "mfrmr_gtds3u_hash",
    "mfrmr_gtds3u_file_hash", "mfrmr_gtds3u_identity",
    "mfrmr_gtds3u_contract", "mfrmr_gtds3u_worker_functions",
    "mfrmr_gtds3u_worker_identity", "mfrmr_gtds3u_worker_static_audit",
    "mfrmr_gtds3u_validate_contract", "mfrmr_gtds3u_scope",
    "mfrmr_gtds3u_terminal_projection",
    "mfrmr_gtds3u_launch_admission",
    "mfrmr_gtds3u_terminate_process", "mfrmr_gtds3u_run_process",
    "mfrmr_gtds3u_probe_specification",
    "mfrmr_gtds3u_normalize_process_receipt",
    "mfrmr_gtds3u_run_scope_probes",
    "mfrmr_gtds3u_concurrency_probe",
    "mfrmr_gtds3u_composite_stop_registry",
    "mfrmr_gtds3u_scope_qualification",
    "mfrmr_gtds3u_implementation_identity",
    "mfrmr_gtds3u_manifest_fields", "mfrmr_gtds3u_manifest",
    "mfrmr_gtds3u_assert_manifest"
  )
  target <- environment(mfrmr_gtds3u_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3u_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtds3u_manifest_fields <- function() {
  c(
    "Contract", "ParentRouteReceiptManifestHash", "ParentExecutionPlanHash",
    "WorkerIdentity", "WorkerStaticAudit", "ProcessProbeRegistry",
    "ConcurrencyReceipt", "CompositeStopRegistry",
    "ResourceScopeQualificationRegistry", "ImplementationIdentity",
    "Summary"
  )
}

mfrmr_gtds3u_manifest <- function(
    worker_path, contract = mfrmr_gtds3u_contract(),
    execution_plan = mfrmr_gtds3e_plan(),
    route_manifest = mfrmr_gtds3r_manifest()) {
  mfrmr_gtds3u_validate_contract(
    contract, execution_plan, route_manifest, worker_path
  )
  worker_identity <- mfrmr_gtds3u_worker_identity(worker_path)
  static_audit <- mfrmr_gtds3u_worker_static_audit(worker_path)
  if (!all(static_audit$Passed)) {
    stop("The resource-probe worker contains a forbidden call.",
         call. = FALSE)
  }
  probes <- mfrmr_gtds3u_run_scope_probes(
    execution_plan, worker_path, contract
  )
  concurrency <- mfrmr_gtds3u_concurrency_probe(
    execution_plan, worker_path, contract
  )
  composite <- mfrmr_gtds3u_composite_stop_registry(
    probes, execution_plan, contract
  )
  scopes <- mfrmr_gtds3u_scope_qualification(
    probes, concurrency, composite, execution_plan, contract
  )
  implementation <- mfrmr_gtds3u_implementation_identity()
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ParentRouteReceiptManifestHash = route_manifest$ManifestHash,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    WorkerSHA256 = contract$WorkerSHA256,
    ResourceScopeCount = nrow(scopes),
    QualifiedResourceScopeCount = sum(scopes$ResourceScopeQualified),
    ProcessProbeCount = nrow(probes),
    QualifiedProcessProbeCount = sum(probes$ProbeQualified),
    SuccessProbeCount = sum(probes$ProbeKind == "success"),
    WallTimeoutProbeCount = sum(probes$ProbeKind == "wall_timeout"),
    PeakRssProbeCount = sum(probes$ProbeKind == "peak_rss"),
    ConcurrencyProbeCount = 1L,
    QualifiedConcurrencyProbeCount =
      as.integer(concurrency$ConcurrencyQualified),
    CompositeStopProbeCount = nrow(composite),
    QualifiedCompositeStopProbeCount =
      sum(composite$CompositeStopQualified),
    RegisteredCompositeProbeUnitCount = sum(
      composite$RegisteredUnitCount
    ),
    RetainedCompositeProbeUnitCount = sum(
      ifelse(
        composite$AllRegisteredUnitsRetained,
        composite$RegisteredUnitCount, 0L
      )
    ),
    UnlaunchedUnitTerminalReceiptCount = sum(
      composite$UnlaunchedUnitTerminalReceiptCreated
    ),
    ReplacementLaunchCount = sum(composite$ReplacementLaunchCreated),
    ExactRuntimeMeasurementsRetained = FALSE,
    ProbeBudgetsAreProductionCapacityClaims = FALSE,
    SameControllerPathUsedForProductionLimits = TRUE,
    ResourceControllerQualified = all(scopes$ResourceScopeQualified),
    SharedExecutionSubstrateQualified =
      isTRUE(route_manifest$Summary$RouteAdapterQualified) &&
      isTRUE(route_manifest$Summary$TerminalReceiptAdapterQualified) &&
      all(scopes$ResourceScopeQualified),
    Planned855RngStreamOpened = FALSE,
    ExploratoryResponseGenerated = FALSE,
    BackendCallMade = FALSE, FitReturned = FALSE, MetricComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "perform one final unopened-855 launch-readiness reconciliation over",
      "the frozen plan, environment, backend requests, terminal accounting,",
      "and resource controller; do not infer launch authority from this",
      "mechanics qualification alone"
    )
  )
  payload <- list(
    Contract = contract,
    ParentRouteReceiptManifestHash = route_manifest$ManifestHash,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    WorkerIdentity = worker_identity,
    WorkerStaticAudit = static_audit,
    ProcessProbeRegistry = probes,
    ConcurrencyReceipt = concurrency,
    CompositeStopRegistry = composite,
    ResourceScopeQualificationRegistry = scopes,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3u_hash(payload)
  )), class = c("mfrmr_gtds3u_manifest", "list"))
  mfrmr_gtds3u_assert_manifest(manifest, worker_path)
  manifest
}

mfrmr_gtds3u_assert_manifest <- function(manifest, worker_path) {
  fields <- mfrmr_gtds3u_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3u_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 resource-controller manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  probes <- manifest$ProcessProbeRegistry
  concurrency <- manifest$ConcurrencyReceipt
  composite <- manifest$CompositeStopRegistry
  scopes <- manifest$ResourceScopeQualificationRegistry
  probe_counts <- table(factor(
    probes$ProbeKind, levels = contract$ExpectedProbeKindsPerScope
  ))
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3u_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3u_contract()) && identical(
    manifest$ParentRouteReceiptManifestHash,
    contract$ParentRouteReceiptManifestHash
  ) && identical(
    manifest$ParentExecutionPlanHash, contract$ParentExecutionPlanHash
  ) && identical(
    contract$WorkerSHA256, mfrmr_gtds3u_file_hash(worker_path)
  ) && identical(
    manifest$WorkerIdentity, mfrmr_gtds3u_worker_identity(worker_path)
  ) && all(manifest$WorkerStaticAudit$Passed) &&
    identical(nrow(probes), 15L) &&
    identical(as.integer(probe_counts), rep(5L, 3L)) &&
    !anyDuplicated(paste(probes$ScopeId, probes$ProbeKind, sep = "::")) &&
    all(probes$ExpectedOutcome == probes$ObservedOutcome) &&
    all(probes$ProcessStarted) && all(probes$ProcessTerminated) &&
    all(probes$WallMeasurementObserved) &&
    all(probes$PeakRssMeasurementObserved) &&
    all(probes$ControllerReceiptRequired) &&
    all(!probes$CountsIn855Denominator) &&
    all(!probes$Planned855Identity) && all(!probes$BackendCallMade) &&
    all(!probes$FitReturned) && all(!probes$MetricComputed) &&
    all(!probes$ExactRuntimeMeasurementsRetained) &&
    all(probes$ProbeQualified) &&
    isTRUE(concurrency$ConcurrencyQualified) &&
    isTRUE(concurrency$FirstProcessAliveAtSecondAdmission) &&
    !isTRUE(concurrency$SecondLaunchAdmitted) &&
    identical(
      concurrency$SecondAdmissionReason,
      "maximum_concurrent_workers_reached"
    ) && identical(nrow(composite), 2L) &&
    identical(composite$ScopeId, contract$CompositeStopScopes) &&
    all(composite$StopNewLaunches) &&
    all(!composite$LaterLaunchAdmitted) &&
    all(composite$AllRegisteredUnitsRetained) &&
    all(!composite$UnlaunchedUnitTerminalReceiptCreated) &&
    all(!composite$UnlaunchedUnitFailureImputed) &&
    all(!composite$ReplacementLaunchCreated) &&
    all(!composite$CountsIn855Denominator) &&
    all(!composite$Planned855Identity) &&
    all(composite$CompositeStopQualified) &&
    identical(nrow(scopes), 5L) &&
    identical(scopes$ScopeId, c(
      "dataset_generation", "one_route_fit", "one_route_metric",
      "one_dataset_pipeline", "complete_exploratory_run"
    )) && all(scopes$LimitContractBound) &&
    all(scopes$SuccessProbeReady) &&
    all(scopes$WallTimeoutEnforcementReady) &&
    all(scopes$PeakRssEnforcementReady) &&
    all(scopes$ConcurrencyEnforcementReady) &&
    all(scopes$ExceedanceReceiptReady) &&
    all(scopes$AtomicUnitTerminalProjectionReady[
      scopes$ScopeId %in% contract$AtomicResourceScopes
    ]) && all(is.na(scopes$AtomicUnitTerminalProjectionReady[
      scopes$ScopeId %in% contract$CompositeStopScopes
    ])) && all(is.na(scopes$CompositeStopReceiptReady[
      scopes$ScopeId %in% contract$AtomicResourceScopes
    ])) && all(scopes$CompositeStopReceiptReady[
      scopes$ScopeId %in% contract$CompositeStopScopes
    ]) &&
    all(scopes$RegisteredUnitRetentionReady) &&
    all(!scopes$ProbeBudgetsAreProductionCapacityClaims) &&
    all(scopes$ResourceScopeQualified) &&
    identical(
      manifest$ImplementationIdentity, mfrmr_gtds3u_implementation_identity()
    ) && identical(manifest$Summary$ResourceScopeCount, 5L) &&
    identical(manifest$Summary$QualifiedResourceScopeCount, 5L) &&
    identical(manifest$Summary$ProcessProbeCount, 15L) &&
    identical(manifest$Summary$QualifiedProcessProbeCount, 15L) &&
    identical(manifest$Summary$SuccessProbeCount, 5L) &&
    identical(manifest$Summary$WallTimeoutProbeCount, 5L) &&
    identical(manifest$Summary$PeakRssProbeCount, 5L) &&
    identical(manifest$Summary$ConcurrencyProbeCount, 1L) &&
    identical(manifest$Summary$QualifiedConcurrencyProbeCount, 1L) &&
    identical(manifest$Summary$CompositeStopProbeCount, 2L) &&
    identical(manifest$Summary$QualifiedCompositeStopProbeCount, 2L) &&
    identical(manifest$Summary$RegisteredCompositeProbeUnitCount, 6L) &&
    identical(manifest$Summary$RetainedCompositeProbeUnitCount, 6L) &&
    identical(manifest$Summary$UnlaunchedUnitTerminalReceiptCount, 0L) &&
    identical(manifest$Summary$ReplacementLaunchCount, 0L) &&
    !isTRUE(manifest$Summary$ExactRuntimeMeasurementsRetained) &&
    !isTRUE(manifest$Summary$ProbeBudgetsAreProductionCapacityClaims) &&
    isTRUE(manifest$Summary$SameControllerPathUsedForProductionLimits) &&
    isTRUE(manifest$Summary$ResourceControllerQualified) &&
    isTRUE(manifest$Summary$SharedExecutionSubstrateQualified) &&
    !isTRUE(manifest$Summary$Planned855RngStreamOpened) &&
    !isTRUE(manifest$Summary$ExploratoryResponseGenerated) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitReturned) &&
    !isTRUE(manifest$Summary$MetricComputed) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady) &&
    identical(manifest$Summary$FeatureMaturity, "specified")
  if (!valid) {
    stop("The D-SIM-3 resource-controller manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
