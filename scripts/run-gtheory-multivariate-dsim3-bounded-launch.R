args <- commandArgs(trailingOnly = TRUE)
mode <- if (length(args) >= 1L) args[[1L]] else "preflight"
if (!mode %in% c("preflight", "run")) {
  stop("Mode must be `preflight` or `run`.", call. = FALSE)
}
source_root <- normalizePath(".", mustWork = TRUE)
validation <- file.path(source_root, "inst", "validation")
output_dir <- if (length(args) >= 2L) args[[2L]] else file.path(
  source_root, "validation-results",
  "gtheory-multivariate-dsim3-bounded-exploratory-launch-0.2.4"
)

source_files <- c(
  "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
  "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
  "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
  "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
  "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
  "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R",
  "gtheory-multivariate-dsim3-covariance-distribution-binding-0.2.4.R",
  "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R",
  "gtheory-multivariate-dsim3-route-receipt-adapter-0.2.4.R",
  paste0(
    "gtheory-multivariate-dsim3-separate-univariate-semantics-audit-",
    "0.2.4.R"
  ),
  paste0(
    "gtheory-multivariate-dsim3-design-dependent-truth-projection-",
    "0.2.4.R"
  ),
  "gtheory-multivariate-dsim3-incidence-allocation-operator-0.2.4.R",
  paste0(
    "gtheory-multivariate-dsim3-separate-univariate-truth-",
    "coefficient-0.2.4.R"
  ),
  "gtheory-multivariate-dsim3-superseding-unopened-plan-0.2.4.R",
  paste0(
    "gtheory-multivariate-dsim3-execution-bridge-request-contract-",
    "0.2.4.R"
  ),
  "gtheory-multivariate-dsim3-fit-metric-worker-0.2.4.R",
  paste0(
    "gtheory-multivariate-dsim3-planned-seed-generation-adapter-",
    "0.2.4.R"
  ),
  paste0(
    "gtheory-multivariate-dsim3-final-launch-readiness-",
    "reconciliation-0.2.4.R"
  ),
  paste0(
    "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
    "controller-0.2.4.R"
  )
)
for (file in source_files) {
  sys.source(
    file.path(validation, file), envir = .GlobalEnv, keep.source = FALSE
  )
}

contract <- mfrmr_gtds3ac_contract()
mfrmr_gtds3ac_validate_contract(contract)
if (identical(mode, "preflight")) {
  request <- mfrmr_gtds3x_manifest()
  qualification <- mfrmr_gtds3ac_shadow_bridge_qualification(
    request_manifest = request
  )
  sources <- mfrmr_gtds3ac_source_registry(source_root, contract)
  cat("contract=", contract$ContractHash, "\n", sep = "")
  cat("sources=", nrow(sources), "/20\n", sep = "")
  cat("worker_identity=", all(sources$FrozenWorkerIdentityMatch), "\n",
      sep = "")
  cat("shadow_seed=", qualification$ShadowSeed, "\n", sep = "")
  cat("shadow_fit_calls=", qualification$FitCallCount, "\n", sep = "")
  cat("shadow_metric_vectors=", qualification$MetricVectorCount, "\n",
      sep = "")
  cat("shadow_metrics_ready=", qualification$AllMetricsReady, "\n",
      sep = "")
  cat("opened856=", qualification$Planned856RngStreamOpened, "\n",
      sep = "")
  quit(save = "no", status = 0L)
}

input_path <- file.path(output_dir, "launch-input.rds")
if (file.exists(input_path)) {
  input <- readRDS(input_path)
  mfrmr_gtds3ac_assert_launch_input(input, source_root)
} else {
  request <- mfrmr_gtds3x_manifest()
  generator <- mfrmr_gtds3g_manifest()
  paths <- mfrmr_gtds3ac_evidence_paths(source_root)
  adapter <- mfrmr_gtds3aa_manifest(
    paths[["generator"]], request_manifest = request,
    generator_manifest = generator
  )
  readiness <- mfrmr_gtds3ab_manifest(
    adapter, paths[["generator"]], paths[["prior_source"]],
    paths[["prior_record"]], paths[["adapter_source"]],
    paths[["adapter_record"]]
  )
  input <- mfrmr_gtds3ac_launch_input(
    request, adapter, readiness, source_root, contract
  )
}
result <- mfrmr_gtds3ac_run(input, output_dir, source_root)
summary <- result$Manifest$Summary
cat("manifest=", result$Manifest$ManifestHash, "\n", sep = "")
cat("datasets=", summary$DatasetAttemptCount, "/42\n", sep = "")
cat("generation_complete=", summary$DatasetGenerationCompleteCount,
    "\n", sep = "")
cat("routes_complete=", summary$CandidateRouteCompleteCount, "/50\n",
    sep = "")
cat("metrics_computed=", summary$ComputedMetricRequestCount, "/100\n",
    sep = "")
cat("terminal_receipts=", summary$TerminalReceiptCount, "/92\n",
    sep = "")
cat("recovery_computed=", summary$RecoveryEvidenceComputed, "\n",
    sep = "")
