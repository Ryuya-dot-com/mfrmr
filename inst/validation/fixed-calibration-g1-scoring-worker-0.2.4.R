args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) {
  stop(
    "Usage: Rscript --vanilla fixed-calibration-g1-scoring-worker-0.2.4.R ",
    "ARTIFACT_RDS INPUT_RDS OUTPUT_RDS",
    call. = FALSE
  )
}

artifact_file <- normalizePath(args[1], mustWork = TRUE)
input_file <- normalizePath(args[2], mustWork = TRUE)
output_file <- args[3]
if (file.exists(output_file)) {
  stop("The output path must not already exist.", call. = FALSE)
}

suppressPackageStartupMessages(library(mfrmr))
load_calibration <- getFromNamespace("mfrmr_load_calibration", "mfrmr")
score_calibration <- getFromNamespace("mfrmr_score_calibration", "mfrmr")

if (exists("fit", envir = .GlobalEnv, inherits = FALSE) ||
    exists("source_data", envir = .GlobalEnv, inherits = FALSE) ||
    exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
  stop("Fresh-process precondition failed.", call. = FALSE)
}

artifact <- load_calibration(artifact_file)
new_responses <- readRDS(input_file)
artifact_before <- artifact
input_before <- new_responses
result <- score_calibration(artifact, new_responses)

if (!identical(artifact, artifact_before) || !identical(new_responses, input_before)) {
  stop("Scoring mutated an input object.", call. = FALSE)
}
if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
  stop("Scoring created caller RNG state.", call. = FALSE)
}
if (!inherits(result, "mfrm_calibration_score") ||
    !identical(result$settings$lifecycle_state, "frozen") ||
    !identical(result$settings$engine_identity, "artifact_coordinates_v1") ||
    nrow(result$estimates) == 0L ||
    any(!is.finite(result$estimates$Estimate)) ||
    any(!is.finite(result$estimates$SD))) {
  stop("Fresh-process scoring result failed its output contract.", call. = FALSE)
}

saveRDS(
  list(
    status = "pass",
    artifact_id = artifact$header$calibration_id,
    family = artifact$model$family,
    estimates = result$estimates,
    row_review = result$row_review,
    settings = result$settings,
    fit_present = exists("fit", envir = .GlobalEnv, inherits = FALSE),
    source_data_present = exists("source_data", envir = .GlobalEnv, inherits = FALSE),
    rng_state_present = exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  ),
  output_file,
  version = 3
)
