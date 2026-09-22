args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop(
  "Usage: Rscript jml-recession-fit-policy-worker-0.2.3.R JOB_RDS",
  call. = FALSE
)

job <- readRDS(args[1L])
if (!identical(job$schema, "mfrmr-jml-fit-policy-worker-job-v1")) stop(
  "Fit-policy worker job schema is invalid.", call. = FALSE
)
.libPaths(unique(c(as.character(job$lib_paths), .libPaths())))
library(mfrmr, lib.loc = as.character(job$mfrmr_lib))
source(as.character(job$runner_path))
mfrmr_fit_policy_require_support()

value <- mfrmr_fit_policy_run_worker_job(job)
out <- list(
  schema = "mfrmr-jml-fit-policy-worker-v1",
  execution_key_sha256 = job$execution_key_sha256,
  plan_sha256 = job$plan_sha256,
  result = value$result, calls = value$calls,
  attempts = value$attempts, confirmation_authorized = FALSE
)
mfrmr_replay_write_atomic_rds(out, as.character(job$output_path))
