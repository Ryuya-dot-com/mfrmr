arguments <- commandArgs(trailingOnly = TRUE)
mode <- if (length(arguments)) arguments[[1L]] else "preflight"
if (!mode %in% c("preflight", "execute") ||
    (mode == "preflight" && length(arguments) != 0L &&
       length(arguments) != 1L) ||
    (mode == "execute" && length(arguments) != 2L)) {
  stop(
    "Usage: Rscript scripts/run-gtheory-multivariate-dsim5-shard-executor.R ",
    "[preflight | execute D5-SHARD-NNN]", call. = FALSE
  )
}

source_root <- normalizePath(".", mustWork = TRUE)
validation <- file.path(source_root, "inst", "validation")
controller <- file.path(
  validation,
  "gtheory-multivariate-dsim3-bounded-exploratory-launch-controller-0.2.4.R"
)
probe <- new.env(parent = globalenv())
sys.source(controller, envir = probe, keep.source = FALSE)
for (file in head(probe$mfrmr_gtds3ac_source_basenames(), -2L)) {
  sys.source(file.path(validation, file), envir = globalenv(),
             keep.source = FALSE)
}
for (file in c(
  "gtheory-multivariate-dsim3-descriptive-recovery-adjudication-0.2.4.R",
  "gtheory-multivariate-dsim4-admission-decision-0.2.4.R",
  "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4.R",
  "gtheory-multivariate-dsim4-worker-qualification-0.2.4.R",
  "gtheory-multivariate-dsim5-launch-input-0.2.4.R",
  "gtheory-multivariate-dsim5-execution-admission-0.2.4.R",
  "gtheory-multivariate-dsim5-shard-executor-0.2.4.R"
)) {
  sys.source(file.path(validation, file), envir = globalenv(),
             keep.source = FALSE)
}

input <- readRDS(file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim5-launch-input-0.2.4", "launch-input.rds"
))
admission <- readRDS(file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim5-execution-admission-0.2.4",
  "admission-manifest.rds"
))
qualification_dir <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim5-shard-executor-0.2.4"
)
qualification_path <- file.path(
  qualification_dir, "executor-qualification-manifest.rds"
)
if (mode == "preflight") {
  manifest <- mfrmr_gtds5e_manifest(input, admission)
  if (!dir.exists(qualification_dir) &&
      !dir.create(qualification_dir, recursive = TRUE)) {
    stop("The D-SIM-5 executor qualification directory could not be created.",
         call. = FALSE)
  }
  if (file.exists(qualification_path)) {
    existing <- readRDS(qualification_path)
    mfrmr_gtds5e_assert_manifest(existing, input, admission)
    if (!identical(existing, manifest)) {
      stop("The existing D-SIM-5 executor qualification differs.",
           call. = FALSE)
    }
  } else {
    mfrmr_gtds5e_atomic_save(manifest, qualification_path)
  }
  cat("contract=", manifest$Contract$ContractHash, "\n", sep = "")
  cat("manifest=", manifest$ManifestHash, "\n", sep = "")
  cat("qualified_shards=", manifest$Summary$QualifiedShardCount,
      "\n", sep = "")
  cat("execution_authorized=",
      manifest$Summary$Dsim5ExecutionAuthorized, "\n", sep = "")
  cat("execution_started=",
      manifest$Summary$QualificationExecutionStarted, "\n", sep = "")
  cat("rng_opened=",
      manifest$Summary$QualificationPlanned857RngStreamOpened ||
        manifest$Summary$QualificationPlanned858RngStreamOpened,
      "\n", sep = "")
  quit(status = 0L)
}

if (!file.exists(qualification_path)) {
  stop("Run D-SIM-5 executor preflight before planned execution.",
       call. = FALSE)
}
manifest <- readRDS(qualification_path)
mfrmr_gtds5e_assert_manifest(manifest, input, admission)

shard_id <- arguments[[2L]]
job <- mfrmr_gtds5e_job(shard_id, input, admission)
receipt <- mfrmr_gtds5e_run_shard(
  job, input, admission, manifest,
  file.path(
    source_root, "validation-results",
    "gtheory-multivariate-dsim5-execution-0.2.4"
  )
)
cat("DSIM5_SHARD_COMPLETE ", receipt$ShardId, " ",
    receipt$ShardReceiptHash, "\n", sep = "")
