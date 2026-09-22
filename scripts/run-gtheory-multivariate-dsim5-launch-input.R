source_root <- normalizePath(".", mustWork = TRUE)
source(file.path(
  source_root, "inst", "validation",
  "gtheory-multivariate-dsim5-launch-input-0.2.4.R"
))
parent_path <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim4-worker-qualification-0.2.4",
  "worker-qualification-manifest.rds"
)
output_dir <- file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim5-launch-input-0.2.4"
)
output_path <- file.path(output_dir, "launch-input.rds")

input <- mfrmr_gtds5i_launch_input(readRDS(parent_path))
if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) {
  stop("The D-SIM-5 launch-input directory could not be created.",
       call. = FALSE)
}
if (file.exists(output_path)) {
  mfrmr_gtds5i_assert_launch_input(readRDS(output_path))
} else {
  saveRDS(input, output_path, version = 3L)
}

cat("contract=", input$Contract$ContractHash, "\n", sep = "")
cat("launch_input=", input$LaunchInputHash, "\n", sep = "")
cat("shards=", input$Summary$ShardCount, "\n", sep = "")
cat("outer_requests=", input$Summary$OuterRequestCount, "\n", sep = "")
cat("inner_attempts=", input$Summary$InnerAttemptCount, "\n", sep = "")
cat("backend_fit_calls=", input$Summary$ExpectedBackendFitCallCount,
    "\n", sep = "")
cat("dsim5_authorized=", input$Summary$Dsim5ExecutionAuthorized,
    "\n", sep = "")
