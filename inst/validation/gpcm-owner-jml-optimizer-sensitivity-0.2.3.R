# Owner-specific GPCM JML optimizer sensitivity for mfrmr 0.2.3.
#
# This is a calibration-only attribution lane. It replays the 40 non-negative
# JML rows from the completed Draft.66 owner pilot under two fixed optimizer
# policies on the same generated data. It cannot authorize confirmation,
# freeze a numerical threshold, or promote a release gate.

mfrmr_gpcm_jml_source_dir <- local({
  frames <- sys.frames()
  files <- vapply(frames, function(frame) {
    value <- frame$ofile
    if (is.null(value)) NA_character_ else as.character(value)[1]
  }, character(1))
  files <- files[!is.na(files) & nzchar(files)]
  if (length(files) == 0L) NA_character_ else dirname(normalizePath(tail(files, 1L)))
})

mfrmr_gpcm_jml_source_execution_sha256 <-
  "f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037"
mfrmr_gpcm_jml_source_runner_sha256 <-
  "b71ee33aa39d07431f43505d70dc531f0abb9db2529ff9a433ea74b4b1dbfb16"
mfrmr_gpcm_jml_source_runtime_sha256 <-
  "ebd9e8eb219ece646adfd37301eba997392637749513191ca7c52d33ce77356d"

mfrmr_gpcm_jml_source_owner_runner <- function() {
  if (is.na(mfrmr_gpcm_jml_source_dir)) {
    stop("Cannot resolve the optimizer-sensitivity source directory.",
         call. = FALSE)
  }
  file.path(
    mfrmr_gpcm_jml_source_dir,
    "gpcm-owner-specific-pilot-0.2.3.R"
  )
}

mfrmr_gpcm_jml_require_source <- function() {
  owner_runner <- mfrmr_gpcm_jml_source_owner_runner()
  if (!file.exists(owner_runner)) {
    stop("The Draft.66 owner runner is unavailable.", call. = FALSE)
  }
  if (!exists(
    "mfrmr_gpcm_owner_manifest", envir = .GlobalEnv,
    mode = "function", inherits = FALSE
  ) || !exists(
    "mfrmr_gpcm_repilot_hash_file", envir = .GlobalEnv,
    mode = "function", inherits = FALSE
  )) {
    source(owner_runner, local = .GlobalEnv)
  }
  mfrmr_gpcm_owner_require_support()
  actual_runner <- mfrmr_gpcm_repilot_hash_file(owner_runner)
  if (!identical(actual_runner, mfrmr_gpcm_jml_source_runner_sha256)) {
    stop(
      "The owner-runner hash no longer matches the completed Draft.66 source run.",
      call. = FALSE
    )
  }
  runtime <- mfrmr_gpcm_repilot_runtime_package_identity()
  if (!identical(
    as.character(runtime$PackageSHA256),
    mfrmr_gpcm_jml_source_runtime_sha256
  )) {
    stop(
      "The loaded mfrmr runtime does not match the completed Draft.66 source run.",
      call. = FALSE
    )
  }
  invisible(runtime)
}

mfrmr_gpcm_jml_manifest <- function(profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  mfrmr_gpcm_jml_require_source()
  owner <- mfrmr_gpcm_owner_manifest(profile)
  retained_designs <- c(
    "core", "weak_bridge", "workload_imbalance", "range_restricted"
  )
  owner <- owner[
    owner$Estimator == "JML" & owner$DesignId %in% retained_designs,
    , drop = FALSE
  ]
  policies <- data.frame(
    OptimizerPolicy = c("BFGS", "L-BFGS-B"),
    PolicyRole = c("draft66_reference", "fixed_sensitivity"),
    stringsAsFactors = FALSE
  )
  out <- merge(owner, policies, all = TRUE)
  out <- out[order(
    match(out$SlopeOwner, c("Criterion", "Rater")),
    match(out$DesignId, retained_designs),
    out$Replicate,
    match(out$OptimizerPolicy, policies$OptimizerPolicy)
  ), , drop = FALSE]
  row.names(out) <- NULL
  out$SourceScenarioId <- out$ScenarioId
  out$AnalysisId <- paste(out$ScenarioId, out$OptimizerPolicy, sep = "--")
  out$SensitivitySchema <- "mfrmr-gpcm-owner-jml-optimizer-sensitivity-v1"
  out$SourceExecutionSHA256 <- mfrmr_gpcm_jml_source_execution_sha256
  out$ConfirmationAuthorized <- FALSE
  out$ConfirmationEvidence <- FALSE
  out$ThresholdStatus <- "sensitivity_only_not_frozen"
  out$ReleaseUse <- "calibration_attribution_only"
  out
}

mfrmr_gpcm_jml_empty_trace <- function() {
  list(
    ExpandCalls = 0L,
    FaultCall = NA_integer_,
    FaultExpandedLogSlopeMin = NA_real_,
    FaultExpandedLogSlopeMax = NA_real_,
    FaultFreeLogSlopeAbsMax = NA_real_,
    FaultParameterAbsMax = NA_real_,
    PreFaultExpandedLogSlopeMin = NA_real_,
    PreFaultExpandedLogSlopeMax = NA_real_,
    MaxRepresentableAbsLogSlope = NA_real_
  )
}

mfrmr_gpcm_jml_fit_with_trace <- function(fit_args, trace_expansion = FALSE) {
  trace_state <- new.env(parent = emptyenv())
  trace_state$calls <- 0L
  trace_state$fault <- NULL
  trace_state$previous <- NULL
  trace_state$max_representable_abs <- NA_real_
  trace_name <- ".mfrmr_gpcm_jml_optimizer_trace_state"
  traced <- FALSE

  if (isTRUE(trace_expansion)) {
    assign(trace_name, trace_state, envir = .GlobalEnv)
    suppressMessages(suppressWarnings(trace(
      "expand_params",
      where = asNamespace("mfrmr"),
      tracer = quote({
        if (identical(config$model, "GPCM")) {
          state <- get(
            ".mfrmr_gpcm_jml_optimizer_trace_state",
            envir = .GlobalEnv,
            inherits = FALSE
          )
          state$calls <- state$calls + 1L
          free_log <- split_params(par, sizes)$log_slopes
          expanded_log <- if (length(free_log) > 0L) {
            c(free_log, -sum(free_log))
          } else {
            0
          }
          represented <- suppressWarnings(exp(expanded_log))
          representable <- all(is.finite(represented)) &&
            all(represented > 0)
          current <- list(
            call = state$calls,
            min = min(expanded_log),
            max = max(expanded_log),
            free_abs_max = if (length(free_log) > 0L) {
              max(abs(free_log))
            } else {
              0
            },
            par_abs_max = if (length(par) > 0L) max(abs(par)) else 0
          )
          if (isTRUE(representable)) {
            state$previous <- current
            candidate <- max(abs(expanded_log))
            state$max_representable_abs <- if (
              is.finite(state$max_representable_abs)
            ) {
              max(state$max_representable_abs, candidate)
            } else {
              candidate
            }
          } else if (is.null(state$fault)) {
            state$fault <- current
            state$fault$previous <- state$previous
          }
        }
      }),
      print = FALSE
    )))
    traced <- TRUE
  }

  cleanup <- function() {
    if (isTRUE(traced)) {
      suppressMessages(suppressWarnings(untrace(
        "expand_params", where = asNamespace("mfrmr")
      )))
    }
    if (exists(trace_name, envir = .GlobalEnv, inherits = FALSE)) {
      rm(list = trace_name, envir = .GlobalEnv)
    }
  }
  on.exit(cleanup(), add = TRUE)

  warnings <- character(0)
  fitted <- withCallingHandlers(
    tryCatch(
      do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), fit_args),
      error = function(error) error
    ),
    warning = function(warning) {
      warnings <<- c(warnings, conditionMessage(warning))
      invokeRestart("muffleWarning")
    }
  )

  trace <- mfrmr_gpcm_jml_empty_trace()
  if (isTRUE(trace_expansion)) {
    trace$ExpandCalls <- as.integer(trace_state$calls)
    trace$MaxRepresentableAbsLogSlope <- as.numeric(
      trace_state$max_representable_abs
    )
    fault <- trace_state$fault
    if (!is.null(fault)) {
      trace$FaultCall <- as.integer(fault$call)
      trace$FaultExpandedLogSlopeMin <- as.numeric(fault$min)
      trace$FaultExpandedLogSlopeMax <- as.numeric(fault$max)
      trace$FaultFreeLogSlopeAbsMax <- as.numeric(fault$free_abs_max)
      trace$FaultParameterAbsMax <- as.numeric(fault$par_abs_max)
      if (!is.null(fault$previous)) {
        trace$PreFaultExpandedLogSlopeMin <- as.numeric(fault$previous$min)
        trace$PreFaultExpandedLogSlopeMax <- as.numeric(fault$previous$max)
      }
    }
  }
  list(fit = fitted, warnings = unique(warnings), trace = trace)
}

mfrmr_gpcm_jml_run_one <- function(row, maxit = 400L) {
  built <- mfrmr_gpcm_owner_build(row)
  data <- built$data
  owner <- as.character(row$SlopeOwner)
  support <- mfrmr_gpcm_owner_support(data, row)
  score_counts <- tabulate(as.integer(data$Score), nbins = 4L)
  person_split <- split(as.integer(data$Score), as.character(data$Person))
  extreme_persons <- sum(vapply(person_split, function(score) {
    all(score == 1L) || all(score == 4L)
  }, logical(1)))
  truth_slopes <- as.numeric(built$truth$slope_table$Estimate)
  fit_args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    keep_original = TRUE,
    model = "GPCM",
    method = "JML",
    step_facet = owner,
    slope_facet = owner,
    rating_min = 1L,
    rating_max = 4L,
    maxit = as.integer(maxit),
    optimizer = as.character(row$OptimizerPolicy)
  )
  captured <- mfrmr_gpcm_jml_fit_with_trace(
    fit_args,
    trace_expansion = identical(as.character(row$OptimizerPolicy), "BFGS")
  )
  fitted <- captured$fit
  base <- data.frame(
    AnalysisId = as.character(row$AnalysisId),
    SourceScenarioId = as.character(row$SourceScenarioId),
    SlopeOwner = owner,
    DesignId = as.character(row$DesignId),
    Replicate = as.integer(row$Replicate),
    Seed = as.integer(row$Seed),
    OptimizerPolicy = as.character(row$OptimizerPolicy),
    PolicyRole = as.character(row$PolicyRole),
    DataSHA256 = mfrmr_gpcm_repilot_hash_object(data),
    Rows = nrow(data),
    Persons = length(person_split),
    ExtremePersons = extreme_persons,
    Score1 = score_counts[1L],
    Score2 = score_counts[2L],
    Score3 = score_counts[3L],
    Score4 = score_counts[4L],
    TruthSlopeMin = min(truth_slopes),
    TruthSlopeMax = max(truth_slopes),
    FitSucceeded = !inherits(fitted, "error"),
    Error = if (inherits(fitted, "error")) conditionMessage(fitted) else "",
    Warnings = paste(captured$warnings, collapse = " | "),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "sensitivity_only_not_frozen",
    stringsAsFactors = FALSE
  )
  base[names(support)] <- support
  base[names(captured$trace)] <- captured$trace
  base$ConvergenceCode <- NA_integer_
  base$ConvergenceSeverity <- NA_character_
  base$RawFitReadiness <- NA_character_
  base$RawInferenceReady <- FALSE
  base$Objective <- NA_real_
  base$SlopeLogRMSE <- NA_real_
  base$MinOptimizerSlope <- NA_real_
  base$MaxOptimizerSlope <- NA_real_
  base$OptimizerStages <- NA_integer_
  if (!inherits(fitted, "error")) {
    readiness <- mfrmr_gpcm_owner_readiness(fitted)
    recovery <- mfrmr_gpcm_owner_slope_recovery(fitted, built$truth)
    slopes <- as.numeric(fitted$slopes$OptimizerEstimate)
    base$ConvergenceCode <- as.integer(
      fitted$summary$ConvergenceCode[1] %||% NA_integer_
    )
    base$ConvergenceSeverity <- as.character(
      fitted$summary$ConvergenceSeverity[1] %||% NA_character_
    )
    base$RawFitReadiness <- readiness$state
    base$RawInferenceReady <- isTRUE(readiness$ready)
    base$Objective <- as.numeric(fitted$opt$value)
    base$SlopeLogRMSE <- as.numeric(recovery[["LogRMSE"]])
    base$MinOptimizerSlope <- min(slopes)
    base$MaxOptimizerSlope <- max(slopes)
    base$OptimizerStages <- nrow(as.data.frame(
      fitted$opt$optimizer_polish$Stages %||% data.frame()
    ))
  }
  base
}

mfrmr_gpcm_jml_pair_summary <- function(results) {
  split_rows <- split(results, results$SourceScenarioId)
  rows <- lapply(split_rows, function(pair) {
    bfgs <- pair[pair$OptimizerPolicy == "BFGS", , drop = FALSE]
    lbfgsb <- pair[pair$OptimizerPolicy == "L-BFGS-B", , drop = FALSE]
    if (nrow(bfgs) != 1L || nrow(lbfgsb) != 1L ||
        !identical(bfgs$DataSHA256, lbfgsb$DataSHA256)) {
      stop("Optimizer sensitivity lost its one-data/two-policy pairing.",
           call. = FALSE)
    }
    data.frame(
      SourceScenarioId = bfgs$SourceScenarioId,
      SlopeOwner = bfgs$SlopeOwner,
      DesignId = bfgs$DesignId,
      Replicate = bfgs$Replicate,
      DataSHA256 = bfgs$DataSHA256,
      BFGSFitSucceeded = bfgs$FitSucceeded,
      LBFGSBFitSucceeded = lbfgsb$FitSucceeded,
      FitRetentionGain = !bfgs$FitSucceeded && lbfgsb$FitSucceeded,
      BFGSPass = isTRUE(bfgs$ConvergenceSeverity == "pass"),
      LBFGSBPass = isTRUE(lbfgsb$ConvergenceSeverity == "pass"),
      ObjectiveDeltaLBFGSBMinusBFGS = if (
        bfgs$FitSucceeded && lbfgsb$FitSucceeded
      ) lbfgsb$Objective - bfgs$Objective else NA_real_,
      SlopeRMSEDeltaLBFGSBMinusBFGS = if (
        bfgs$FitSucceeded && lbfgsb$FitSucceeded
      ) lbfgsb$SlopeLogRMSE - bfgs$SlopeLogRMSE else NA_real_,
      BFGSNumericSlopeFault = is.finite(bfgs$FaultCall),
      ConfirmationAuthorized = FALSE,
      ThresholdStatus = "sensitivity_only_not_frozen",
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out[order(
    match(out$SlopeOwner, c("Criterion", "Rater")),
    out$DesignId,
    out$Replicate
  ), , drop = FALSE]
}

mfrmr_gpcm_jml_summary <- function(results, pairs, profile) {
  data.frame(
    Profile = profile,
    PlannedRows = nrow(results),
    PlannedPairs = nrow(pairs),
    ExecutedRows = nrow(results),
    BFGSFitSucceeded = sum(
      results$OptimizerPolicy == "BFGS" & results$FitSucceeded
    ),
    LBFGSBFitSucceeded = sum(
      results$OptimizerPolicy == "L-BFGS-B" & results$FitSucceeded
    ),
    FitRetentionGains = sum(pairs$FitRetentionGain),
    BFGSNumericSlopeFaults = sum(pairs$BFGSNumericSlopeFault),
    BFGSConvergencePass = sum(
      results$OptimizerPolicy == "BFGS" &
        results$ConvergenceSeverity == "pass", na.rm = TRUE
    ),
    LBFGSBConvergencePass = sum(
      results$OptimizerPolicy == "L-BFGS-B" &
        results$ConvergenceSeverity == "pass", na.rm = TRUE
    ),
    RawInferenceReady = sum(results$RawInferenceReady, na.rm = TRUE),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "sensitivity_only_not_frozen",
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_jml_validate_source_bundle <- function(source_dir) {
  if (is.null(source_dir) || !dir.exists(source_dir)) {
    stop("A completed Draft.66 source bundle is required.", call. = FALSE)
  }
  source_rds <- file.path(source_dir, "gpcm-owner-specific-pilot.rds")
  if (!file.exists(source_rds)) {
    stop("The Draft.66 source bundle has no pilot RDS artifact.", call. = FALSE)
  }
  source <- readRDS(source_rds)
  actual_execution <- as.character(
    source$execution_identity$ExecutionSHA256[1] %||% NA_character_
  )
  if (!identical(actual_execution, mfrmr_gpcm_jml_source_execution_sha256)) {
    stop("The source bundle is not the completed Draft.66 execution.",
         call. = FALSE)
  }
  completion <- mfrmr_gpcm_owner_validate_completion(
    source_dir, mfrmr_gpcm_jml_source_execution_sha256
  )
  list(
    completion = completion,
    source_rds_sha256 = mfrmr_gpcm_repilot_hash_file(source_rds)
  )
}

mfrmr_gpcm_jml_write <- function(result, output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  existing <- list.files(output_dir, all.files = TRUE, no.. = TRUE)
  if (length(existing) > 0L) {
    stop("Optimizer-sensitivity output directory must be empty.",
         call. = FALSE)
  }
  artifacts <- list(
    "manifest.csv" = result$manifest,
    "run-results.csv" = result$results,
    "pair-summary.csv" = result$pair_summary,
    "summary.csv" = result$summary,
    "execution-identity.csv" = result$execution_identity
  )
  for (name in names(artifacts)) {
    utils::write.csv(
      artifacts[[name]], file.path(output_dir, name), row.names = FALSE,
      na = ""
    )
  }
  mfrmr_gpcm_repilot_atomic_save_rds(
    result, file.path(output_dir, "gpcm-owner-jml-optimizer-sensitivity.rds")
  )
  inventory_files <- c(
    names(artifacts), "gpcm-owner-jml-optimizer-sensitivity.rds"
  )
  inventory <- data.frame(
    File = inventory_files,
    SHA256 = vapply(
      file.path(output_dir, inventory_files),
      mfrmr_gpcm_repilot_hash_file,
      character(1), USE.NAMES = FALSE
    ),
    stringsAsFactors = FALSE
  )
  completion <- list(
    Schema = "mfrmr-gpcm-owner-jml-optimizer-sensitivity-completion-v1",
    ExecutionSHA256 = as.character(
      result$execution_identity$ExecutionSHA256
    ),
    Inventory = inventory,
    InventorySHA256 = mfrmr_gpcm_repilot_hash_object(inventory),
    CompletedUTC = format(Sys.time(), tz = "UTC", usetz = TRUE)
  )
  mfrmr_gpcm_repilot_atomic_save_rds(
    completion, file.path(output_dir, "run-complete.rds")
  )
  invisible(completion)
}

mfrmr_run_gpcm_owner_jml_optimizer_sensitivity <- function(
    profile = c("smoke", "pilot"),
    source_dir = NULL,
    output_dir = NULL,
    authorize = FALSE,
    progress = interactive()) {
  profile <- match.arg(profile)
  mfrmr_gpcm_jml_require_source()
  if (identical(profile, "pilot") && !isTRUE(authorize)) {
    stop("The full optimizer sensitivity requires `authorize = TRUE`.",
         call. = FALSE)
  }
  source_identity <- if (identical(profile, "pilot")) {
    mfrmr_gpcm_jml_validate_source_bundle(source_dir)
  } else {
    NULL
  }
  manifest <- mfrmr_gpcm_jml_manifest(profile)
  planned_rows <- if (identical(profile, "pilot")) 80L else 8L
  if (nrow(manifest) != planned_rows || anyDuplicated(manifest$AnalysisId)) {
    stop("Optimizer-sensitivity manifest violates its frozen row contract.",
         call. = FALSE)
  }
  runner_path <- file.path(
    mfrmr_gpcm_jml_source_dir,
    "gpcm-owner-jml-optimizer-sensitivity-0.2.3.R"
  )
  maxit <- if (identical(profile, "pilot")) 400L else 20L
  execution_identity <- data.frame(
    Schema = "mfrmr-gpcm-owner-jml-optimizer-sensitivity-execution-v1",
    Profile = profile,
    PlannedRows = planned_rows,
    PlannedPairs = planned_rows %/% 2L,
    Maxit = maxit,
    SourceExecutionSHA256 = mfrmr_gpcm_jml_source_execution_sha256,
    SourcePilotRDS_SHA256 = if (is.null(source_identity)) NA_character_ else {
      source_identity$source_rds_sha256
    },
    RuntimePackageSHA256 = mfrmr_gpcm_jml_source_runtime_sha256,
    OwnerRunnerSHA256 = mfrmr_gpcm_jml_source_runner_sha256,
    RunnerSHA256 = mfrmr_gpcm_repilot_hash_file(runner_path),
    ManifestSHA256 = mfrmr_gpcm_repilot_hash_object(manifest),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "sensitivity_only_not_frozen",
    stringsAsFactors = FALSE
  )
  execution_identity$ExecutionSHA256 <-
    mfrmr_gpcm_repilot_hash_object(execution_identity)

  rows <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    if (isTRUE(progress)) {
      message(sprintf(
        "[gpcm-jml-optimizer %d/%d] %s",
        i, nrow(manifest), manifest$AnalysisId[i]
      ))
    }
    rows[[i]] <- mfrmr_gpcm_jml_run_one(
      manifest[i, , drop = FALSE], maxit = maxit
    )
  }
  results <- do.call(rbind, rows)
  row.names(results) <- NULL
  pairs <- mfrmr_gpcm_jml_pair_summary(results)
  summary <- mfrmr_gpcm_jml_summary(results, pairs, profile)
  result <- structure(
    list(
      manifest = manifest,
      results = results,
      pair_summary = pairs,
      summary = summary,
      execution_identity = execution_identity,
      source_identity = source_identity,
      confirmation_authorized = FALSE,
      session_info = utils::sessionInfo()
    ),
    class = c("mfrmr_gpcm_owner_jml_optimizer_sensitivity", "list")
  )
  if (!is.null(output_dir)) {
    mfrmr_gpcm_jml_write(result, output_dir)
  }
  result
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  profile <- if (length(args) >= 1L) args[[1L]] else "smoke"
  source_dir <- if (length(args) >= 2L) args[[2L]] else NULL
  output_dir <- if (length(args) >= 3L) args[[3L]] else NULL
  result <- mfrmr_run_gpcm_owner_jml_optimizer_sensitivity(
    profile = profile,
    source_dir = source_dir,
    output_dir = output_dir,
    authorize = identical(profile, "pilot"),
    progress = TRUE
  )
  print(result$summary)
}
