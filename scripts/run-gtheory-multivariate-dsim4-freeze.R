source_root <- normalizePath(".", mustWork = TRUE)
validation <- file.path(source_root, "inst", "validation")
output_dir <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4"
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
sys.source(
  file.path(
    validation,
    "gtheory-multivariate-dsim3-descriptive-recovery-adjudication-0.2.4.R"
  ), envir = .GlobalEnv, keep.source = FALSE
)
sys.source(
  file.path(
    validation,
    "gtheory-multivariate-dsim4-admission-decision-0.2.4.R"
  ), envir = .GlobalEnv, keep.source = FALSE
)
sys.source(
  file.path(
    validation,
    "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4.R"
  ), envir = .GlobalEnv, keep.source = FALSE
)

manifest <- mfrmr_gtds4_manifest(mfrmr_gtds3_manifest(), source_root)
if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) {
  stop("The D-SIM-4 freeze output directory could not be created.",
       call. = FALSE)
}
mfrmr_gtds3ac_atomic_save(
  manifest, file.path(output_dir, "freeze-manifest.rds")
)

cat("contract=", manifest$Contract$ContractHash, "\n", sep = "")
cat("manifest=", manifest$ManifestHash, "\n", sep = "")
cat(
  "freeze_requirements=", manifest$Summary$FrozenRequirementCount, "/",
  manifest$Summary$FreezeRequirementCount, "\n", sep = ""
)
cat("scenarios=", manifest$Summary$SelectedScenarioCount, "\n", sep = "")
cat("outer_attempts=", manifest$Summary$OuterAttemptCount, "\n", sep = "")
cat(
  "inner_bootstrap_attempts=",
  manifest$Summary$InnerBootstrapAttemptCount, "\n", sep = ""
)
cat("dsim5_authorized=", manifest$Summary$Dsim5ExecutionAuthorized,
    "\n", sep = "")
