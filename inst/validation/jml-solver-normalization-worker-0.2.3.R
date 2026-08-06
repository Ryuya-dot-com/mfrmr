args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
  stop("Usage: Rscript jml-solver-normalization-worker-0.2.3.R JOB_RDS",
       call. = FALSE)
}

job <- readRDS(args[1L])
.libPaths(unique(c(as.character(job$lib_paths), .libPaths())))
library(mfrmr, lib.loc = as.character(job$mfrmr_lib))
source(as.character(job$runner_path))
mfrmr_normalization_require_support()
if (!requireNamespace("Matrix", quietly = TRUE)) {
  stop("The normalization worker requires package `Matrix`.", call. = FALSE)
}

if (!is.null(job$started_path) && nzchar(job$started_path)) {
  saveRDS(list(
    schema = "mfrmr-jml-normalization-worker-started-v1",
    pid = Sys.getpid(), started_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    solver = job$solver, formulation = job$formulation,
    problem_sha256 = job$problem$ProblemSHA256
  ), job$started_path)
}

rows <- vector("list", as.integer(job$repetitions))
for (i in seq_len(as.integer(job$repetitions))) {
  started <- unname(proc.time()[["elapsed"]])
  value <- mfrmr_normalization_evaluate_case(
    job$problem, solver = as.character(job$solver),
    formulation = as.character(job$formulation),
    expected = job$expected
  )
  value$Repetition <- i
  value$ElapsedSeconds <- max(
    0, unname(proc.time()[["elapsed"]]) - started
  )
  rows[[i]] <- value
}

out <- list(
  schema = "mfrmr-jml-normalization-worker-v1",
  solver = as.character(job$solver),
  formulation = as.character(job$formulation),
  problem_sha256 = as.character(job$problem$ProblemSHA256),
  results = do.call(rbind, rows),
  confirmation_authorized = FALSE
)
saveRDS(out, as.character(job$output_path))
