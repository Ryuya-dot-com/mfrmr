source_root <- normalizePath(".", mustWork = TRUE)
validation <- file.path(source_root, "inst", "validation")
output_dir <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim4-worker-qualification-0.2.4"
)

controller <- file.path(
  validation,
  "gtheory-multivariate-dsim3-bounded-exploratory-launch-controller-0.2.4.R"
)
sys.source(controller, envir = .GlobalEnv, keep.source = FALSE)
for (file in head(mfrmr_gtds3ac_source_basenames(), -1L)) {
  sys.source(file.path(validation, file), envir = .GlobalEnv,
             keep.source = FALSE)
}
for (file in c(
  "gtheory-multivariate-dsim3-descriptive-recovery-adjudication-0.2.4.R",
  "gtheory-multivariate-dsim4-admission-decision-0.2.4.R",
  "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4.R",
  "gtheory-multivariate-dsim4-worker-qualification-0.2.4.R"
)) {
  sys.source(file.path(validation, file), envir = .GlobalEnv,
             keep.source = FALSE)
}

freeze_path <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4",
  "freeze-manifest.rds"
)
freeze <- if (file.exists(freeze_path)) {
  readRDS(freeze_path)
} else {
  mfrmr_gtds4_manifest(mfrmr_gtds3_manifest(), source_root)
}
manifest <- mfrmr_gtds4w_manifest(freeze)
if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) {
  stop("The D-SIM-4 worker output directory could not be created.",
       call. = FALSE)
}
mfrmr_gtds3ac_atomic_save(
  manifest, file.path(output_dir, "worker-qualification-manifest.rds")
)

cat("contract=", manifest$Contract$ContractHash, "\n", sep = "")
cat("manifest=", manifest$ManifestHash, "\n", sep = "")
cat("inner_identity=", manifest$InnerIdentityHash, "\n", sep = "")
cat("gates=", manifest$Summary$PassedGateCount, "/",
    manifest$Summary$GateCount, "\n", sep = "")
cat("outer_requests=", manifest$Summary$OuterRequestCount, "\n", sep = "")
cat("inner_attempts=", manifest$Summary$InnerAttemptCount, "\n", sep = "")
cat("backend_fit_calls=",
    manifest$Summary$ExpectedTotalBackendFitCallCount, "\n", sep = "")
cat("shadow_refits=", manifest$Summary$ShadowRefitCallCount, "\n", sep = "")
cat("dsim5_authorized=", manifest$Summary$Dsim5ExecutionAuthorized,
    "\n", sep = "")
