source_root <- normalizePath(".", mustWork = TRUE)
validation <- file.path(source_root, "inst", "validation")
launch_dir <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim3-bounded-exploratory-launch-0.2.4"
)
output_dir <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim3-descriptive-recovery-0.2.4"
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

semantics <- mfrmr_gtds3s_manifest()
coverage <- mfrmr_gtds3_manifest()
truth <- mfrmr_gtds3t_manifest(semantics_manifest = semantics)
operator <- mfrmr_gtds3o_manifest(truth_manifest = truth)
truth_metric <- mfrmr_gtds3m_manifest(
  truth_manifest = truth, operator_manifest = operator,
  semantics_manifest = semantics
)
plan <- mfrmr_gtds3p_plan(
  truth_manifest = truth, operator_manifest = operator,
  metric_manifest = truth_metric
)
manifest <- mfrmr_gtds3ad_manifest(
  file.path(launch_dir, "launch-input.rds"),
  file.path(launch_dir, "launch-result.rds"),
  file.path(launch_dir, "run-complete.rds"),
  coverage, truth_metric, plan
)
if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) {
  stop("The descriptive-recovery output directory could not be created.",
       call. = FALSE)
}
mfrmr_gtds3ac_atomic_save(
  manifest, file.path(output_dir, "descriptive-recovery-manifest.rds")
)

cat("contract=", manifest$Contract$ContractHash, "\n", sep = "")
cat("manifest=", manifest$ManifestHash, "\n", sep = "")
cat(
  "direct_truth_scalars=",
  manifest$Summary$AvailableDirectTruthScalarCount, "/",
  manifest$Summary$DirectTruthScalarCount, "\n", sep = ""
)
cat(
  "parity_scalars=", manifest$Summary$AvailableParityScalarCount, "/",
  manifest$Summary$ParityScalarCount, "\n", sep = ""
)
cat("estimand_recovery\n")
print(manifest$EstimandRecoverySummaryRegistry, row.names = FALSE)
cat("within_backend_parity\n")
print(manifest$WithinBackendParitySummaryRegistry, row.names = FALSE)
cat("simulation_validation_ready=",
    manifest$Summary$SimulationValidationReady, "\n", sep = "")
