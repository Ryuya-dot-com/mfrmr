args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
  stop("Usage: Rscript jml-solver-qualification-worker-0.2.3.R JOB_RDS",
       call. = FALSE)
}

job <- readRDS(args[1L])
.libPaths(unique(c(as.character(job$lib_paths), .libPaths())))
library(mfrmr, lib.loc = as.character(job$mfrmr_lib))
source(as.character(job$runner_path))
mfrmr_solver_require_support()

if (!requireNamespace("ps", quietly = TRUE)) {
  stop("The isolated solver worker requires package `ps`.", call. = FALSE)
}

memory <- function() {
  info <- ps::ps_memory_info(ps::ps_handle())
  c(
    PeakWorkingSetMB = unname(info[["peak_wset"]]) / 1024^2,
    WorkingSetMB = unname(info[["wset"]]) / 1024^2,
    PeakPagefileMB = unname(info[["peak_pagefile"]]) / 1024^2,
    PrivateMemoryMB = unname(info[["mem_private"]]) / 1024^2,
    PageFaults = unname(info[["num_page_faults"]])
  )
}

invisible(gc(reset = TRUE))
initial <- memory()
rows <- vector("list", as.integer(job$repetitions))
for (i in seq_len(as.integer(job$repetitions))) {
  started <- unname(proc.time()[["elapsed"]])
  value <- mfrmr_solver_run_target(
    job$problem, as.character(job$solver)
  )
  elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
  compact <- mfrmr_solver_compact_result(job$problem, value)
  rows[[i]] <- data.frame(
    Repetition = i, ElapsedSeconds = elapsed,
    SafeResult = compact$SafeResult,
    Evaluated = compact$Evaluated,
    Certified = compact$Certified,
    Reason = compact$Reason,
    TargetCapacity = compact$TargetCapacity,
    stringsAsFactors = FALSE
  )
}
final <- memory()
out <- list(
  schema = "mfrmr-jml-solver-isolated-worker-v1",
  solver = as.character(job$solver),
  problem_sha256 = as.character(job$problem$ProblemSHA256),
  repetitions = do.call(rbind, rows),
  initial = initial,
  final = final,
  peak_increase_above_initial_peak_mb = max(
    0, final[["PeakWorkingSetMB"]] - initial[["PeakWorkingSetMB"]]
  ),
  confirmation_authorized = FALSE
)
saveRDS(out, as.character(job$output_path))
