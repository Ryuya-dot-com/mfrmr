# Repository-only target-scale feasibility runner for mfrmr 0.2.3.
#
# This runner executes only the six target_sparse cells that were already
# declared executable by the draft.41 GPCM covering-grid manifest.  It records
# computation and fail-closed behavior; it does not estimate operating
# characteristics, freeze thresholds, authorize confirmation, or claim FACETS
# capacity parity.

mfrmr_target_scale_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "target-scale-sparse-stress-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path(
      "inst", "validation", "target-scale-sparse-stress-pilot-0.2.3.R"
    ),
    "target-scale-sparse-stress-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_target_scale_require_support <- function() {
  target_env <- environment(mfrmr_target_scale_require_support)
  required_covering <- c(
    "mfrmr_gpcm_stress_manifest", "mfrmr_gpcm_stress_coverage",
    "mfrmr_gpcm_stress_run_one", "mfrmr_gpcm_stress_empty_result"
  )
  required_identity <- c(
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_runtime_package_identity",
    "mfrmr_gpcm_repilot_capability_manifest"
  )
  source_one <- function(file) {
    candidates <- c(
      if (!is.na(mfrmr_target_scale_source_dir)) {
        file.path(mfrmr_target_scale_source_dir, file)
      } else character(0),
      file.path("inst", "validation", file), file
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("Cannot locate target-scale support file: ", file, call. = FALSE)
    }
    sys.source(path, envir = target_env)
  }
  if (!all(vapply(required_covering, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    source_one("gpcm-stress-covering-grid-0.2.3.R")
  }
  if (!all(vapply(required_identity, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    source_one("gpcm-attribution-replicated-pilot-0.2.3.R")
  }
  required <- c(required_covering, required_identity)
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("Target-scale support files did not load completely.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_target_scale_registry <- function() {
  mfrmr_target_scale_require_support()
  manifest <- mfrmr_gpcm_stress_manifest("pilot")
  selected <- manifest[
    manifest$SampleSize == "target_sparse" & manifest$Executable,
    , drop = FALSE
  ]
  expected <- c(
    "GPCM-P-008", "GPCM-P-018", "GPCM-P-019",
    "GPCM-P-024", "GPCM-P-031", "GPCM-P-040"
  )
  selected <- selected[match(expected, selected$ScenarioId), , drop = FALSE]
  if (anyNA(selected$ScenarioId) ||
      !identical(as.character(selected$ScenarioId), expected)) {
    stop("The declared executable target-scale cell set has drifted.",
         call. = FALSE)
  }
  selected$StressRole <- c(
    "gpcm_mixed_adversity_capacity",
    "gpcm_disconnected_negative_control",
    "pcm_jml_mcar_weighted_local_dependence",
    "pcm_mml_imbalance_rater_missingness",
    "pcm_jml_disconnected_outcome_missingness",
    "pcm_mml_two_rater_disconnected_boundary_zero"
  )
  selected$PrimaryQuestion <- c(
    "Can the free-slope MML route complete under sparse linking, rater-dependent missingness, rare interior support, zero weights, interaction, and bias contamination?",
    "Does disconnected GPCM MML remain non-ready at target scale?",
    "Can PCM JML execute with MCAR, unequal weights, and local dependence without numerical success being promoted to adequacy?",
    "Can PCM MML execute under dominant-category support, rater-dependent missingness, occasion duplication, interaction, and drift?",
    "Does disconnected PCM JML remain non-ready under outcome-dependent missingness and ceiling imbalance?",
    "Does a two-rater disconnected PCM MML design with a missing boundary category remain non-ready?"
  )
  selected$ExecutedReplicates <- 1L
  selected$DeclaredPilotReplicates <- as.integer(selected$Reps)
  selected$EvidenceUse <- "capacity_feasibility_calibration_only"
  selected$ConfirmationAuthorized <- FALSE
  row.names(selected) <- NULL
  selected
}

mfrmr_target_scale_memory <- function(gc_result, row) {
  if (!is.matrix(gc_result) || !row %in% row.names(gc_result)) {
    return(NA_real_)
  }
  preferred <- c("max used (Mb)", "max used")
  column <- preferred[preferred %in% colnames(gc_result)][1L]
  if (is.na(column)) return(NA_real_)
  value <- as.numeric(gc_result[row, column])
  if (identical(column, "max used")) {
    bytes <- if (identical(row, "Vcells")) 8 else 56
    value <- value * bytes / 1024^2
  }
  value
}

mfrmr_target_scale_runner_identity <- function() {
  if (is.na(mfrmr_target_scale_source_dir)) {
    stop("Cannot identify the target-scale runner directory.", call. = FALSE)
  }
  components <- c(
    target_scale = "target-scale-sparse-stress-pilot-0.2.3.R",
    covering_grid = "gpcm-stress-covering-grid-0.2.3.R",
    identity_support = "gpcm-attribution-replicated-pilot-0.2.3.R",
    attribution_support = "gpcm-isolated-attribution-pilot-0.2.3.R"
  )
  paths <- file.path(mfrmr_target_scale_source_dir, unname(components))
  if (any(!file.exists(paths))) {
    stop("One or more target-scale runner files are missing.", call. = FALSE)
  }
  out <- data.frame(
    Component = names(components), File = unname(components),
    SHA256 = unname(vapply(
      paths, mfrmr_gpcm_repilot_hash_file, character(1)
    )),
    stringsAsFactors = FALSE
  )
  attr(out, "CompositeSHA256") <- mfrmr_gpcm_repilot_hash_object(out)
  out
}

mfrmr_target_scale_identity <- function(manifest, maxit, quad_points,
                                         run_diagnostics) {
  package <- mfrmr_gpcm_repilot_runtime_package_identity()
  runners <- mfrmr_target_scale_runner_identity()
  capabilities <- mfrmr_gpcm_repilot_capability_manifest()
  declared <- unique(as.character(manifest$ManifestHash))
  if (length(declared) != 1L || is.na(declared) || !nzchar(declared)) {
    stop("The selected manifest does not have one declared hash.",
         call. = FALSE)
  }
  execution <- data.frame(
    Schema = "mfrmr-target-scale-feasibility-v1",
    SelectedCells = nrow(manifest),
    ExecutedReplicatesPerCell = 1L,
    DeclaredPilotReplicatesPerCell = unique(manifest$Reps),
    Maxit = as.integer(maxit), QuadPoints = as.integer(quad_points),
    RunDiagnostics = isTRUE(run_diagnostics),
    DeclaredManifestSHA256 = declared,
    SelectedManifestSHA256 = mfrmr_gpcm_repilot_hash_object(manifest),
    PackageSHA256 = package$PackageSHA256,
    RunnerSHA256 = attr(runners, "CompositeSHA256"),
    CapabilitySHA256 = attr(capabilities, "CompositeSHA256"),
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "capacity_feasibility_calibration_only",
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  list(
    execution = execution, package = package, runners = runners,
    capabilities = capabilities
  )
}

mfrmr_target_scale_run_one <- function(row, run_diagnostics, maxit,
                                       quad_points) {
  invisible(gc(reset = TRUE))
  start <- proc.time()
  result <- tryCatch(
    mfrmr_gpcm_stress_run_one(
      row, run_diagnostics = run_diagnostics, maxit = maxit,
      quad_points = quad_points
    ),
    error = function(e) {
      mfrmr_gpcm_stress_empty_result(
        row, "wrapper_failed", conditionMessage(e)
      )
    }
  )
  timing <- proc.time() - start
  memory <- gc()
  result$ElapsedSeconds <- unname(as.numeric(timing[["elapsed"]]))
  result$UserSeconds <- unname(as.numeric(timing[["user.self"]]))
  result$SystemSeconds <- unname(as.numeric(timing[["sys.self"]]))
  result$PeakVcellsMB <- mfrmr_target_scale_memory(memory, "Vcells")
  result$PeakNcellsMB <- mfrmr_target_scale_memory(memory, "Ncells")
  result$ResultBytes <- as.numeric(utils::object.size(result))
  result$StressRole <- as.character(row$StressRole)
  result$ExecutedReplicates <- 1L
  result$DeclaredPilotReplicates <- as.integer(row$Reps)
  result$ConfirmationAuthorized <- FALSE
  result
}

mfrmr_target_scale_write_csv <- function(x, path) {
  utils::write.csv(x, path, row.names = FALSE, na = "")
  invisible(path)
}

mfrmr_target_scale_artifact_inventory <- function(output_dir) {
  files <- sort(list.files(
    output_dir, recursive = TRUE, full.names = TRUE, all.files = TRUE,
    no.. = TRUE
  ))
  files <- files[!dir.exists(files)]
  root <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  relative <- substring(
    normalizePath(files, winslash = "/", mustWork = TRUE), nchar(root) + 2L
  )
  data.frame(
    File = relative,
    Bytes = unname(file.info(files)$size),
    SHA256 = unname(vapply(
      files, mfrmr_gpcm_repilot_hash_file, character(1)
    )),
    stringsAsFactors = FALSE
  )
}

mfrmr_target_scale_validate_completion <- function(
    output_dir, expected_execution_sha256 = NULL) {
  mfrmr_target_scale_require_support()
  marker_path <- file.path(output_dir, "run-complete.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(e) e)
  if (inherits(marker, "error") ||
      !identical(marker$schema,
                 "mfrmr-target-scale-feasibility-completion-v1")) {
    stop("Target-scale completion marker is unreadable or invalid.",
         call. = FALSE)
  }
  if (!is.null(expected_execution_sha256) &&
      !identical(as.character(marker$execution_sha256),
                 as.character(expected_execution_sha256))) {
    stop("Target-scale completion execution identity mismatch.",
         call. = FALSE)
  }
  inventory <- marker$artifacts
  if (!is.data.frame(inventory) ||
      !all(c("File", "Bytes", "SHA256") %in% names(inventory)) ||
      nrow(inventory) < 1L || anyDuplicated(inventory$File)) {
    stop("Target-scale completion inventory schema mismatch.",
         call. = FALSE)
  }
  if (!identical(
    as.character(marker$artifact_inventory_sha256),
    mfrmr_gpcm_repilot_hash_object(inventory)
  )) {
    stop("Target-scale completion inventory hash mismatch.",
         call. = FALSE)
  }
  relative <- gsub("\\\\", "/", as.character(inventory$File))
  unsafe <- !nzchar(relative) |
    grepl("^(?:[A-Za-z]:|/)", relative, perl = TRUE) |
    grepl("(?:^|/)\\.\\.(?:/|$)", relative, perl = TRUE)
  if (any(unsafe)) {
    stop("Target-scale completion inventory contains an unsafe path.",
         call. = FALSE)
  }
  paths <- file.path(output_dir, relative)
  if (any(!file.exists(paths)) || any(dir.exists(paths))) {
    stop("Target-scale completion inventory references a missing artifact.",
         call. = FALSE)
  }
  observed_size <- unname(file.info(paths)$size)
  observed_hash <- unname(vapply(
    paths, mfrmr_gpcm_repilot_hash_file, character(1)
  ))
  if (!identical(as.numeric(observed_size), as.numeric(inventory$Bytes)) ||
      !identical(observed_hash, as.character(inventory$SHA256))) {
    stop("Target-scale completion artifact hash or size mismatch.",
         call. = FALSE)
  }
  if (isTRUE(marker$confirmation_authorized)) {
    stop("A feasibility completion marker cannot authorize confirmation.",
         call. = FALSE)
  }
  invisible(marker)
}

mfrmr_run_target_scale_sparse_stress <- function(
    dry_run = TRUE, authorize = FALSE, run_diagnostics = FALSE,
    maxit = 180L, quad_points = 7L, output_dir = NULL,
    progress = interactive()) {
  mfrmr_target_scale_require_support()
  maxit <- as.integer(maxit)
  quad_points <- as.integer(quad_points)
  if (length(maxit) != 1L || is.na(maxit) || maxit < 1L) {
    stop("`maxit` must be one positive integer.", call. = FALSE)
  }
  if (length(quad_points) != 1L || is.na(quad_points) || quad_points < 3L) {
    stop("`quad_points` must be one integer of at least three.",
         call. = FALSE)
  }
  if (!is.logical(run_diagnostics) || length(run_diagnostics) != 1L ||
      is.na(run_diagnostics)) {
    stop("`run_diagnostics` must be one non-missing logical value.",
         call. = FALSE)
  }
  manifest <- mfrmr_target_scale_registry()
  identity <- mfrmr_target_scale_identity(
    manifest, maxit, quad_points, run_diagnostics
  )
  coverage <- mfrmr_gpcm_stress_coverage(
    mfrmr_gpcm_stress_manifest("pilot")
  )
  if (isTRUE(dry_run)) {
    return(structure(list(
      registry = manifest, results = NULL, coverage = coverage,
      execution_identity = identity$execution,
      package_identity = identity$package,
      runner_identity = identity$runners,
      capability_manifest = identity$capabilities,
      confirmation_authorized = FALSE
    ), class = "mfrmr_target_scale_sparse_stress"))
  }
  if (!isTRUE(authorize)) {
    stop("Live target-scale execution requires `authorize = TRUE`.",
         call. = FALSE)
  }
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("Live target-scale execution requires one `output_dir`.",
         call. = FALSE)
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
  if (file.exists(staging) || dir.exists(staging)) {
    stop("The generated incomplete-run directory already exists.",
         call. = FALSE)
  }
  dir.create(staging, recursive = FALSE)
  started <- Sys.time()
  rows <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    if (isTRUE(progress)) {
      message(
        "[", i, "/", nrow(manifest), "] ", manifest$ScenarioId[i], " ",
        manifest$StressRole[i]
      )
    }
    rows[[i]] <- mfrmr_target_scale_run_one(
      manifest[i, , drop = FALSE], run_diagnostics, maxit, quad_points
    )
    partial <- do.call(rbind, rows[seq_len(i)])
    mfrmr_target_scale_write_csv(
      partial, file.path(staging, "run-progress.csv")
    )
  }
  results <- do.call(rbind, rows)
  completed <- Sys.time()
  summary <- data.frame(
    Schema = "mfrmr-target-scale-feasibility-summary-v1",
    Cells = nrow(manifest), ExecutedCells = sum(results$Executed),
    FailedCells = sum(results$RunState %in% c(
      "generation_failed", "transformation_failed", "fit_failed",
      "wrapper_failed"
    )),
    FalseReadyCells = sum(results$FalseReady %in% TRUE, na.rm = TRUE),
    InferenceReadyCells = sum(results$InferenceReady %in% TRUE, na.rm = TRUE),
    TotalElapsedSeconds = sum(results$ElapsedSeconds, na.rm = TRUE),
    MaxCellElapsedSeconds = max(results$ElapsedSeconds, na.rm = TRUE),
    MaxPeakVcellsMB = max(results$PeakVcellsMB, na.rm = TRUE),
    MaxPeakNcellsMB = max(results$PeakNcellsMB, na.rm = TRUE),
    StatisticalOperatingCharacteristicsEstimated = FALSE,
    ThresholdsFrozen = FALSE, ConfirmationAuthorized = FALSE,
    EvidenceUse = "capacity_feasibility_calibration_only",
    stringsAsFactors = FALSE
  )
  out <- structure(list(
    registry = manifest, results = results, summary = summary,
    coverage = coverage, execution_identity = identity$execution,
    package_identity = identity$package,
    runner_identity = identity$runners,
    capability_manifest = identity$capabilities,
    started_at = started, completed_at = completed,
    confirmation_authorized = FALSE, session_info = utils::sessionInfo()
  ), class = "mfrmr_target_scale_sparse_stress")
  mfrmr_target_scale_write_csv(manifest, file.path(staging, "registry.csv"))
  mfrmr_target_scale_write_csv(results, file.path(staging, "run-results.csv"))
  mfrmr_target_scale_write_csv(summary, file.path(staging, "run-summary.csv"))
  mfrmr_target_scale_write_csv(
    identity$execution, file.path(staging, "execution-identity.csv")
  )
  mfrmr_target_scale_write_csv(
    identity$package, file.path(staging, "package-identity.csv")
  )
  mfrmr_target_scale_write_csv(
    identity$runners, file.path(staging, "runner-identity.csv")
  )
  mfrmr_target_scale_write_csv(
    identity$capabilities, file.path(staging, "capability-manifest.csv")
  )
  saveRDS(out, file.path(staging, "target-scale-stress.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  mfrmr_target_scale_write_csv(
    inventory, file.path(staging, "artifact-inventory.csv")
  )
  completion <- list(
    schema = "mfrmr-target-scale-feasibility-completion-v1",
    execution_sha256 = identity$execution$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(completed, tz = "UTC", usetz = TRUE),
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  mfrmr_target_scale_validate_completion(
    staging, identity$execution$ExecutionSHA256
  )
  if (!file.rename(staging, output_dir)) {
    stop("Completed evidence could not be promoted from the staging directory.",
         call. = FALSE)
  }
  mfrmr_target_scale_validate_completion(
    output_dir, identity$execution$ExecutionSHA256
  )
  out
}
