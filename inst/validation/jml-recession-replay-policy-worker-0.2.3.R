args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop(
  "Usage: Rscript jml-recession-replay-policy-worker-0.2.3.R JOB_RDS",
  call. = FALSE
)

job <- readRDS(args[1L])
if (!identical(job$schema, "mfrmr-jml-replay-worker-job-v1")) stop(
  "Replay worker job schema is invalid.", call. = FALSE
)
.libPaths(unique(c(as.character(job$lib_paths), .libPaths())))
library(mfrmr, lib.loc = as.character(job$mfrmr_lib))
source(as.character(job$runner_path))
mfrmr_replay_require_support()

problem <- readRDS(as.character(job$problem_path))
if (!identical(problem$ProblemId, as.integer(job$problem_id)) ||
    !identical(problem$ProblemSHA256,
               as.character(job$expected_problem_sha256))) stop(
  "Replay worker problem identity mismatch.", call. = FALSE
)
dir.create(as.character(job$journal_dir), recursive = TRUE, showWarnings = FALSE)
mfrmr_replay_write_atomic_rds(list(
  schema = "mfrmr-jml-replay-worker-started-v1",
  pid = Sys.getpid(), execution_key_sha256 = job$execution_key_sha256,
  plan_sha256 = job$plan_sha256,
  started_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
), as.character(job$started_path))

value <- mfrmr_replay_run_worker_job(job, problem)
out <- list(
  schema = "mfrmr-jml-replay-worker-v1",
  execution_key_sha256 = job$execution_key_sha256,
  plan_sha256 = job$plan_sha256,
  result = value$result, attempts = value$attempts,
  confirmation_authorized = FALSE
)
mfrmr_replay_write_atomic_rds(out, as.character(job$output_path))
