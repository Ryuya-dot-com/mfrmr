source_root <- normalizePath(".", mustWork = TRUE)
validation <- file.path(source_root, "inst", "validation")
descriptive_path <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim3-descriptive-recovery-0.2.4",
  "descriptive-recovery-manifest.rds"
)
output_dir <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim4-admission-0.2.4"
)

controller <- file.path(
  validation,
  paste0(
    "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
    "controller-0.2.4.R"
  )
)
sys.source(controller, envir = .GlobalEnv, keep.source = FALSE)
for (file in head(mfrmr_gtds3ac_source_basenames(), -1L)) {
  sys.source(file.path(validation, file), envir = .GlobalEnv,
             keep.source = FALSE)
}
sys.source(
  file.path(
    validation,
    paste0(
      "gtheory-multivariate-dsim3-descriptive-recovery-",
      "adjudication-0.2.4.R"
    )
  ),
  envir = .GlobalEnv, keep.source = FALSE
)
sys.source(
  file.path(
    validation,
    "gtheory-multivariate-dsim4-admission-decision-0.2.4.R"
  ),
  envir = .GlobalEnv, keep.source = FALSE
)

if (!file.exists(descriptive_path)) {
  stop("The immutable D-SIM-3 descriptive manifest is required.",
       call. = FALSE)
}
descriptive <- readRDS(descriptive_path)
manifest <- mfrmr_gtds4a_manifest(descriptive)
if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) {
  stop("The D-SIM-4 admission output directory could not be created.",
       call. = FALSE)
}
mfrmr_gtds3ac_atomic_save(
  manifest, file.path(output_dir, "admission-manifest.rds")
)

cat("contract=", manifest$Contract$ContractHash, "\n", sep = "")
cat("manifest=", manifest$ManifestHash, "\n", sep = "")
cat(
  "admission_criteria=",
  manifest$Summary$AdmissionCriterionSatisfiedCount, "/",
  manifest$Summary$AdmissionCriterionCount, "\n", sep = ""
)
cat(
  "freeze_requirements=",
  manifest$Summary$FreezeRequirementFrozenCount, "/",
  manifest$Summary$FreezeRequirementCount, "\n", sep = ""
)
cat("decision=", manifest$Summary$DecisionOutcome, "\n", sep = "")
cat("dsim5_authorized=", manifest$Summary$Dsim5ExecutionAuthorized,
    "\n", sep = "")
