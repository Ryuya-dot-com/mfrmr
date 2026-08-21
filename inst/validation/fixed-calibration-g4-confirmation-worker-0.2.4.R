args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 5L) {
  stop(
    "Usage: Rscript --vanilla fixed-calibration-g4-confirmation-worker-0.2.4.R ",
    "PACKAGE_ROOT ARTIFACT_RDS INPUT_RDS OUTPUT_RDS COLLATE_LOCALE",
    call. = FALSE
  )
}

package_root <- normalizePath(args[1], mustWork = TRUE)
artifact_file <- normalizePath(args[2], mustWork = TRUE)
input_file <- normalizePath(args[3], mustWork = TRUE)
output_file <- args[4]
collate_locale <- args[5]
if (file.exists(output_file)) {
  stop("The output path must not already exist.", call. = FALSE)
}

installed_library <- Sys.getenv("MFRMR_G4_INSTALLED_LIBRARY", unset = "")
if (nzchar(installed_library)) {
  installed_library <- normalizePath(installed_library, mustWork = TRUE)
  .libPaths(c(installed_library, .libPaths()))
  suppressPackageStartupMessages(library(mfrmr))
  load_mode <- "installed_library"
} else {
  suppressPackageStartupMessages(pkgload::load_all(package_root, quiet = TRUE))
  load_mode <- "source_tree"
}
loaded_package_path <- normalizePath(find.package("mfrmr"), mustWork = TRUE)
if (identical(load_mode, "installed_library") &&
    !identical(dirname(loaded_package_path), installed_library)) {
  stop("The worker did not load mfrmr from the isolated library.", call. = FALSE)
}
if (!identical(Sys.setlocale("LC_COLLATE", collate_locale), collate_locale)) {
  stop("Requested collation locale is unavailable.", call. = FALSE)
}
if (exists("fit", envir = .GlobalEnv, inherits = FALSE) ||
    exists("source_data", envir = .GlobalEnv, inherits = FALSE) ||
    exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
  stop("Fresh-process precondition failed.", call. = FALSE)
}

artifact <- mfrmr:::mfrmr_load_calibration(artifact_file)
new_responses <- readRDS(input_file)
artifact_before <- artifact
input_before <- new_responses
result <- mfrmr:::mfrmr_score_calibration(
  artifact, new_responses, weight = "Weight", interval_level = 0.84
)

if (!identical(artifact, artifact_before) || !identical(new_responses, input_before)) {
  stop("Scoring mutated an input object.", call. = FALSE)
}
if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
  stop("Scoring created caller RNG state.", call. = FALSE)
}

saveRDS(
  list(
    status = "pass",
    load_mode = load_mode,
    loaded_package_path = loaded_package_path,
    package_version = as.character(utils::packageVersion("mfrmr")),
    calibration_id = artifact$header$calibration_id,
    semantic_components = result$settings$semantic_components,
    estimates = result$estimates,
    row_dispositions = result$row_dispositions,
    person_dispositions = result$person_dispositions,
    fit_present = exists("fit", envir = .GlobalEnv, inherits = FALSE),
    source_data_present = exists("source_data", envir = .GlobalEnv,
                                 inherits = FALSE),
    rng_state_present = exists(".Random.seed", envir = .GlobalEnv,
                               inherits = FALSE),
    locale = Sys.getlocale()
  ),
  output_file,
  version = 3
)
