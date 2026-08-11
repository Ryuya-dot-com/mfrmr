# Recheck the Draft.66 JML rows after transactional slope-boundary rejection.
# Calibration attribution only; never confirmation or threshold evidence.

mfrmr_gpcm_jml_recheck_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-owner-jml-boundary-rejection-recheck-0\\.2\\.3\\.R$",
    files
  )]
  if (length(hit) == 0L) NA_character_ else {
    dirname(normalizePath(tail(hit, 1L), winslash = "/", mustWork = FALSE))
  }
})

mfrmr_gpcm_jml_recheck_runtime_sha256 <-
  "31c87d7a888ca760afa02476f1c226bae148403475e34b75eefaaa9679522920"
mfrmr_gpcm_jml_recheck_source_execution_sha256 <-
  "15aafe52e32a729bfb245895604d7ec8fc0ec7157c2db5020a607d675587882b"
mfrmr_gpcm_jml_recheck_source_inventory_sha256 <-
  "210baba78b46741ab9d1cf84dc4a31059c86b7afbb3ee961d271ce224c0751e1"

mfrmr_gpcm_jml_recheck_load_support <- function() {
  if (is.na(mfrmr_gpcm_jml_recheck_source_dir)) {
    stop("Cannot resolve the JML boundary-recheck source directory.",
         call. = FALSE)
  }
  owner_runner <- file.path(
    mfrmr_gpcm_jml_recheck_source_dir,
    "gpcm-owner-specific-pilot-0.2.3.R"
  )
  sensitivity_runner <- file.path(
    mfrmr_gpcm_jml_recheck_source_dir,
    "gpcm-owner-jml-optimizer-sensitivity-0.2.3.R"
  )
  if (!exists(
    "mfrmr_gpcm_owner_manifest", envir = .GlobalEnv,
    mode = "function", inherits = FALSE
  )) {
    sys.source(owner_runner, envir = .GlobalEnv)
  }
  mfrmr_gpcm_owner_require_support()
  if (!exists(
    "mfrmr_gpcm_jml_run_one", envir = .GlobalEnv,
    mode = "function", inherits = FALSE
  )) {
    sys.source(sensitivity_runner, envir = .GlobalEnv)
  }
  runtime <- mfrmr_gpcm_repilot_runtime_package_identity()
  if (!identical(
    as.character(runtime$PackageSHA256),
    mfrmr_gpcm_jml_recheck_runtime_sha256
  )) {
    stop("The loaded runtime is not the Draft.67 boundary-rejection build.",
         call. = FALSE)
  }
  invisible(runtime)
}

mfrmr_gpcm_jml_recheck_validate_source <- function(source_dir) {
  completion_path <- file.path(source_dir, "run-complete.rds")
  results_path <- file.path(source_dir, "run-results.csv")
  if (!file.exists(completion_path) || !file.exists(results_path)) {
    stop("The completed Draft.66 optimizer sensitivity is required.",
         call. = FALSE)
  }
  completion <- readRDS(completion_path)
  if (!identical(
    as.character(completion$Schema),
    "mfrmr-gpcm-owner-jml-optimizer-sensitivity-completion-v1"
  ) || !identical(
    as.character(completion$ExecutionSHA256),
    mfrmr_gpcm_jml_recheck_source_execution_sha256
  ) || !identical(
    as.character(completion$InventorySHA256),
    mfrmr_gpcm_jml_recheck_source_inventory_sha256
  )) {
    stop("The optimizer-sensitivity completion identity is not Draft.66.",
         call. = FALSE)
  }
  inventory <- as.data.frame(completion$Inventory, stringsAsFactors = FALSE)
  actual <- vapply(
    file.path(source_dir, inventory$File),
    mfrmr_gpcm_repilot_hash_file,
    character(1), USE.NAMES = FALSE
  )
  if (!identical(actual, as.character(inventory$SHA256)) ||
      !identical(
        mfrmr_gpcm_repilot_hash_object(inventory),
        mfrmr_gpcm_jml_recheck_source_inventory_sha256
      )) {
    stop("The Draft.66 optimizer-sensitivity inventory is invalid.",
         call. = FALSE)
  }
  historical <- utils::read.csv(
    results_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  historical <- historical[historical$OptimizerPolicy == "BFGS", , drop = FALSE]
  if (nrow(historical) != 40L || anyDuplicated(historical$SourceScenarioId)) {
    stop("The historical BFGS panel is incomplete.", call. = FALSE)
  }
  list(
    completion = completion,
    historical = historical,
    results_sha256 = mfrmr_gpcm_repilot_hash_file(results_path)
  )
}

mfrmr_gpcm_jml_recheck_manifest <- function() {
  owner <- mfrmr_gpcm_owner_manifest("pilot")
  owner <- owner[
    owner$Estimator == "JML" & owner$DesignId %in% c(
      "core", "weak_bridge", "workload_imbalance", "range_restricted"
    ), , drop = FALSE
  ]
  owner <- owner[order(
    match(owner$SlopeOwner, c("Criterion", "Rater")),
    owner$DesignId,
    owner$Replicate
  ), , drop = FALSE]
  row.names(owner) <- NULL
  owner$SourceScenarioId <- owner$ScenarioId
  owner$AnalysisId <- paste0(owner$ScenarioId, "--BFGS-BOUNDARY-REJECTION")
  owner$OptimizerPolicy <- "BFGS"
  owner$PolicyRole <- "draft67_boundary_rejection_recheck"
  owner$ConfirmationAuthorized <- FALSE
  owner$ConfirmationEvidence <- FALSE
  owner$ThresholdStatus <- "recheck_only_not_frozen"
  owner$ReleaseUse <- "calibration_attribution_only"
  if (nrow(owner) != 40L || anyDuplicated(owner$SourceScenarioId)) {
    stop("The Draft.67 boundary-recheck manifest is incomplete.",
         call. = FALSE)
  }
  owner
}

mfrmr_gpcm_jml_recheck_compare <- function(current, historical) {
  keep <- c(
    "SourceScenarioId", "DataSHA256", "FitSucceeded",
    "ConvergenceSeverity", "Objective", "SlopeLogRMSE",
    "MinOptimizerSlope", "MaxOptimizerSlope", "FaultCall"
  )
  old <- historical[, keep, drop = FALSE]
  new <- current[, c(
    keep,
    "MaxRepresentableAbsLogSlope",
    "FaultExpandedLogSlopeMin", "FaultExpandedLogSlopeMax"
  ), drop = FALSE]
  paired <- merge(old, new, by = "SourceScenarioId",
                  suffixes = c("Historical", "Recheck"))
  if (nrow(paired) != 40L || any(
    paired$DataSHA256Historical != paired$DataSHA256Recheck
  )) {
    stop("The boundary recheck did not retain exact Draft.66 data pairing.",
         call. = FALSE)
  }
  data.frame(
    SourceScenarioId = paired$SourceScenarioId,
    DataSHA256 = paired$DataSHA256Historical,
    HistoricalFitSucceeded = paired$FitSucceededHistorical,
    RecheckFitSucceeded = paired$FitSucceededRecheck,
    FitRetentionGain = !paired$FitSucceededHistorical &
      paired$FitSucceededRecheck,
    HistoricalPass = paired$ConvergenceSeverityHistorical == "pass",
    RecheckPass = paired$ConvergenceSeverityRecheck == "pass",
    HistoricalObjective = paired$ObjectiveHistorical,
    RecheckObjective = paired$ObjectiveRecheck,
    ObjectiveDelta = paired$ObjectiveRecheck - paired$ObjectiveHistorical,
    HistoricalSlopeLogRMSE = paired$SlopeLogRMSEHistorical,
    RecheckSlopeLogRMSE = paired$SlopeLogRMSERecheck,
    HistoricalNumericFault = is.finite(paired$FaultCallHistorical),
    RecheckRejectedProposal = is.finite(paired$FaultCallRecheck),
    RecheckMaxRepresentableAbsLogSlope =
      paired$MaxRepresentableAbsLogSlope,
    RecheckFaultExpandedLogSlopeMin = paired$FaultExpandedLogSlopeMin,
    RecheckFaultExpandedLogSlopeMax = paired$FaultExpandedLogSlopeMax,
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "recheck_only_not_frozen",
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_jml_recheck_write <- function(result, output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  if (length(list.files(output_dir, all.files = TRUE, no.. = TRUE)) > 0L) {
    stop("Boundary-recheck output directory must be empty.", call. = FALSE)
  }
  artifacts <- list(
    "manifest.csv" = result$manifest,
    "run-results.csv" = result$results,
    "paired-comparison.csv" = result$paired_comparison,
    "summary.csv" = result$summary,
    "execution-identity.csv" = result$execution_identity
  )
  for (name in names(artifacts)) {
    utils::write.csv(artifacts[[name]], file.path(output_dir, name),
                     row.names = FALSE, na = "")
  }
  result_path <- file.path(
    output_dir, "gpcm-owner-jml-boundary-rejection-recheck.rds"
  )
  mfrmr_gpcm_repilot_atomic_save_rds(result, result_path)
  inventory_files <- c(
    names(artifacts), basename(result_path)
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
    Schema = "mfrmr-gpcm-owner-jml-boundary-rejection-recheck-completion-v1",
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

mfrmr_run_gpcm_owner_jml_boundary_recheck <- function(
    source_dir,
    output_dir = NULL,
    authorize = FALSE,
    progress = interactive()) {
  if (!isTRUE(authorize)) {
    stop("The full Draft.67 boundary recheck requires `authorize = TRUE`.",
         call. = FALSE)
  }
  runtime <- mfrmr_gpcm_jml_recheck_load_support()
  source <- mfrmr_gpcm_jml_recheck_validate_source(source_dir)
  manifest <- mfrmr_gpcm_jml_recheck_manifest()
  runner_path <- file.path(
    mfrmr_gpcm_jml_recheck_source_dir,
    "gpcm-owner-jml-boundary-rejection-recheck-0.2.3.R"
  )
  execution <- data.frame(
    Schema = "mfrmr-gpcm-owner-jml-boundary-rejection-recheck-execution-v1",
    PlannedRows = 40L,
    Maxit = 400L,
    HistoricalExecutionSHA256 =
      mfrmr_gpcm_jml_recheck_source_execution_sha256,
    HistoricalInventorySHA256 =
      mfrmr_gpcm_jml_recheck_source_inventory_sha256,
    HistoricalResultsSHA256 = source$results_sha256,
    RuntimePackageSHA256 = as.character(runtime$PackageSHA256),
    RunnerSHA256 = mfrmr_gpcm_repilot_hash_file(runner_path),
    ManifestSHA256 = mfrmr_gpcm_repilot_hash_object(manifest),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "recheck_only_not_frozen",
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  rows <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    if (isTRUE(progress)) {
      message(sprintf(
        "[gpcm-jml-boundary %d/%d] %s",
        i, nrow(manifest), manifest$SourceScenarioId[i]
      ))
    }
    rows[[i]] <- mfrmr_gpcm_jml_run_one(
      manifest[i, , drop = FALSE], maxit = 400L
    )
  }
  results <- do.call(rbind, rows)
  row.names(results) <- NULL
  paired <- mfrmr_gpcm_jml_recheck_compare(results, source$historical)
  summary <- data.frame(
    PlannedRows = 40L,
    ExecutedRows = nrow(results),
    FitSucceeded = sum(results$FitSucceeded),
    FitRetentionGains = sum(paired$FitRetentionGain),
    ConvergencePass = sum(results$ConvergenceSeverity == "pass", na.rm = TRUE),
    RejectedProposalRows = sum(paired$RecheckRejectedProposal),
    RawInferenceReady = sum(results$RawInferenceReady),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "recheck_only_not_frozen",
    stringsAsFactors = FALSE
  )
  result <- structure(
    list(
      manifest = manifest,
      results = results,
      paired_comparison = paired,
      summary = summary,
      execution_identity = execution,
      historical_completion = source$completion,
      confirmation_authorized = FALSE,
      session_info = utils::sessionInfo()
    ),
    class = c("mfrmr_gpcm_owner_jml_boundary_recheck", "list")
  )
  if (!is.null(output_dir)) {
    mfrmr_gpcm_jml_recheck_write(result, output_dir)
  }
  result
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 1L) {
    stop("Supply the completed Draft.66 optimizer-sensitivity directory.",
         call. = FALSE)
  }
  result <- mfrmr_run_gpcm_owner_jml_boundary_recheck(
    source_dir = args[[1L]],
    output_dir = if (length(args) >= 2L) args[[2L]] else NULL,
    authorize = TRUE,
    progress = TRUE
  )
  print(result$summary)
}
