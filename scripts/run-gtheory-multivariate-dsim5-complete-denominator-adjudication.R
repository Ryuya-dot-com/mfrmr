source_root <- normalizePath(".", mustWork = TRUE)
validation <- file.path(source_root, "inst", "validation")
controller <- file.path(
  validation,
  "gtheory-multivariate-dsim3-bounded-exploratory-launch-controller-0.2.4.R"
)
probe <- new.env(parent = globalenv())
sys.source(controller, envir = probe, keep.source = FALSE)
for (file in head(probe$mfrmr_gtds3ac_source_basenames(), -1L)) {
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
  "gtheory-multivariate-dsim5-shard-executor-0.2.4.R",
  "gtheory-multivariate-dsim5-complete-denominator-adjudication-0.2.4.R"
)) {
  sys.source(file.path(validation, file), envir = globalenv(),
             keep.source = FALSE)
}

result_root <- file.path(source_root, "validation-results")
input <- readRDS(file.path(
  result_root, "gtheory-multivariate-dsim5-launch-input-0.2.4",
  "launch-input.rds"
))
admission <- readRDS(file.path(
  result_root, "gtheory-multivariate-dsim5-execution-admission-0.2.4",
  "admission-manifest.rds"
))
freeze <- readRDS(file.path(
  result_root, "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4",
  "freeze-manifest.rds"
))
truth <- readRDS(file.path(
  result_root, "gtheory-multivariate-dsim3-descriptive-recovery-0.2.4",
  "descriptive-recovery-manifest.rds"
))
output_dir <- file.path(
  result_root,
  "gtheory-multivariate-dsim5-complete-denominator-adjudication-0.2.4"
)
output_path <- file.path(output_dir, "adjudication.rds")
if (file.exists(output_path)) {
  artifact <- readRDS(output_path)
  valid <- inherits(artifact, "mfrmr_gtds5d_artifact") &&
    identical(names(artifact), c("Assembly", "Adjudication", "ArtifactHash")) &&
    identical(
      artifact$ArtifactHash,
      mfrmr_gtds5d_hash(artifact[c("Assembly", "Adjudication")])
    )
  if (!valid) stop("The stored D-SIM-5 adjudication was altered.",
                   call. = FALSE)
} else {
  assembly <- mfrmr_gtds5d_assemble(
    input, admission, freeze, truth,
    file.path(result_root, "gtheory-multivariate-dsim5-execution-0.2.4")
  )
  adjudication <- mfrmr_gtds5d_adjudicate(assembly, freeze)
  payload <- list(Assembly = assembly, Adjudication = adjudication)
  artifact <- structure(c(payload, list(
    ArtifactHash = mfrmr_gtds5d_hash(payload)
  )), class = c("mfrmr_gtds5d_artifact", "list"))
  if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) {
    stop("The D-SIM-5 adjudication directory could not be created.",
         call. = FALSE)
  }
  mfrmr_gtds5e_atomic_save(artifact, output_path)
  if (!identical(readRDS(output_path), artifact)) {
    stop("The D-SIM-5 adjudication did not round-trip exactly.",
         call. = FALSE)
  }
}

cat("artifact=", artifact$ArtifactHash, "\n", sep = "")
cat("assembly=", artifact$Assembly$AssemblyHash, "\n", sep = "")
cat("adjudication=", artifact$Adjudication$AdjudicationHash, "\n", sep = "")
cat("disposition=", artifact$Adjudication$OverallDisposition, "\n", sep = "")
cat("public_support_ready=", artifact$Adjudication$PublicSupportReady,
    "\n", sep = "")
