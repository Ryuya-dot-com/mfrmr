source_root <- normalizePath(".", mustWork = TRUE)
validation <- file.path(source_root, "inst", "validation")
for (file in c(
  "gtheory-multivariate-dsim5-launch-input-0.2.4.R",
  "gtheory-multivariate-dsim5-execution-admission-0.2.4.R"
)) source(file.path(validation, file))

input <- readRDS(file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim5-launch-input-0.2.4", "launch-input.rds"
))
manifest <- mfrmr_gtds5a_manifest(input)
output_dir <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim5-execution-admission-0.2.4"
)
output_path <- file.path(output_dir, "admission-manifest.rds")
if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) {
  stop("The D-SIM-5 admission directory could not be created.",
       call. = FALSE)
}
if (file.exists(output_path)) {
  mfrmr_gtds5a_assert_manifest(readRDS(output_path), input)
} else {
  saveRDS(manifest, output_path, version = 3L)
}

cat("contract=", manifest$Contract$ContractHash, "\n", sep = "")
cat("manifest=", manifest$ManifestHash, "\n", sep = "")
cat("criteria=", manifest$Summary$AdmissionCriterionSatisfiedCount,
    "/", manifest$Summary$AdmissionCriterionCount, "\n", sep = "")
cat("authorized_shards=", manifest$Summary$AuthorizedShardCount,
    "\n", sep = "")
cat("execution_started=", manifest$Summary$ExecutionStarted, "\n", sep = "")
cat("rng_opened=", manifest$Summary$Planned857RngStreamOpened ||
      manifest$Summary$Planned858RngStreamOpened, "\n", sep = "")
