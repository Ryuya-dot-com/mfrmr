args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 5L) {
  stop(
    "Usage: worker <launch-input.rds> <dataset-id> <result.rds> ",
    "<source-root> <progress.rds>", call. = FALSE
  )
}

input_path <- normalizePath(args[[1L]], mustWork = TRUE)
dataset_id <- args[[2L]]
result_path <- args[[3L]]
source_root <- normalizePath(args[[4L]], mustWork = TRUE)
progress_path <- args[[5L]]
input <- readRDS(input_path)

source_registry <- input$SourceRegistry
source_registry <- source_registry[source_registry$SourceRole == "sourced", ]
for (basename in source_registry$SourceBasename) {
  path <- file.path(source_root, "inst", "validation", basename)
  if (!file.exists(path)) {
    stop("A frozen D-SIM-3 launch source is missing: ", basename,
         call. = FALSE)
  }
  sys.source(path, envir = .GlobalEnv, keep.source = FALSE)
}

mfrmr_gtds3ac_assert_launch_input(input, source_root)
mfrmr_gtds3ac_write_progress(
  progress_path, input, dataset_id, "worker_started"
)
result <- mfrmr_gtds3ac_execute_dataset(
  dataset_id, input, source_root, progress_path
)
mfrmr_gtds3ac_assert_checkpoint(result, input, source_root)
mfrmr_gtds3ac_atomic_save(result, result_path)
mfrmr_gtds3ac_write_progress(
  progress_path, input, dataset_id, "worker_result_committed"
)
cat("DSIM3_BOUNDED_DATASET_COMPLETE ", dataset_id, "\n", sep = "")
