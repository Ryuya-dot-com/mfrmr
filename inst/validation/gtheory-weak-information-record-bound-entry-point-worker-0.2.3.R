args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 4L || !identical(args[[1L]], "--run-job")) {
  stop(
    "Usage: Rscript --vanilla worker.R --run-job JOB_RDS ROOT RESULT_RDS",
    call. = FALSE
  )
}

job_path <- normalizePath(args[[2L]], winslash = "/", mustWork = TRUE)
checkpoint_root <- normalizePath(args[[3L]], winslash = "/", mustWork = TRUE)
result_path <- args[[4L]]
invocation <- commandArgs(trailingOnly = FALSE)
file_argument <- invocation[grepl("^--file=", invocation)]
if (length(file_argument) != 1L) {
  stop("The record-bound runner must be invoked from one Rscript file.",
       call. = FALSE)
}
worker_path <- normalizePath(
  sub("^--file=", "", file_argument[[1L]]),
  winslash = "/", mustWork = TRUE
)
project_root <- normalizePath(
  file.path(dirname(worker_path), "..", ".."),
  winslash = "/", mustWork = TRUE
)
validation_root <- file.path(project_root, "inst", "validation")
sources <- c(
  "gtheory-design-algebra-prototype-0.2.3.R",
  "gtheory-balanced-estimation-prototype-0.2.3.R",
  "gtheory-design-incidence-audit-0.2.3.R",
  "gtheory-covariance-information-audit-0.2.3.R",
  "gtheory-glmmtmb-parity-prototype-0.2.3.R",
  "gtheory-ademp-registry-prototype-0.2.3.R",
  "gtheory-ademp-generator-prototype-0.2.3.R",
  "gtheory-ademp-prefit-prototype-0.2.3.R",
  "gtheory-ademp-fit-prototype-0.2.3.R",
  "gtheory-weak-information-calibration-prototype-0.2.3.R",
  "gtheory-weak-information-pilot-prototype-0.2.3.R",
  "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
  "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
  "gtheory-weak-information-feasibility-prototype-0.2.3.R",
  "gtheory-weak-information-feasibility-runner-0.2.3.R",
  "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
  "gtheory-weak-information-typed-replay-0.2.3.R",
  "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R",
  "gtheory-weak-information-glmmtmb-stabilization-runner-0.2.3.R",
  "gtheory-weak-information-glmmtmb-stationarity-instrumentation-0.2.3.R",
  "gtheory-weak-information-glmmtmb-stationarity-calibration-design-0.2.3.R",
  "gtheory-weak-information-glmmtmb-stationarity-reference-calibration-0.2.3.R",
  "gtheory-weak-information-stationarity-calibration-authorization-audit-0.2.3.R",
  "gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R",
  "gtheory-weak-information-lme4-objective-reference-preflight-0.2.3.R",
  "gtheory-weak-information-lme4-reference-coverage-0.2.3.R",
  "gtheory-weak-information-stationarity-acceptance-policy-0.2.3.R",
  "gtheory-weak-information-production-boundary-probe-0.2.3.R",
  "gtheory-weak-information-stationarity-exact-resume-runner-0.2.3.R",
  "gtheory-weak-information-production-adapter-preflight-0.2.3.R",
  "gtheory-weak-information-one-way-authorization-preflight-0.2.3.R",
  "gtheory-weak-information-monte-carlo-value-audit-0.2.3.R",
  "gtheory-weak-information-preactivation-hardening-audit-0.2.3.R",
  "gtheory-weak-information-rng-hardened-generator-0.2.3.R",
  "gtheory-weak-information-hardened-adapter-rebase-0.2.3.R",
  "gtheory-weak-information-hardened-reserved-lineage-0.2.3.R",
  "gtheory-weak-information-authorization-kernel-0.2.3.R",
  "gtheory-weak-information-guarded-shard-runner-0.2.3.R",
  "gtheory-weak-information-execution-authorization-decision-0.2.3.R",
  "gtheory-weak-information-record-bound-entry-point-0.2.3.R"
)
paths <- file.path(validation_root, sources)
if (!all(file.exists(paths))) {
  stop("The record-bound entry source chain is incomplete.", call. = FALSE)
}
environment <- new.env(parent = globalenv())
for (path in paths) sys.source(path, envir = environment)
job <- readRDS(job_path)
execution <- environment$mfrmr_gtwar_worker_run(
  job, checkpoint_root, worker_path
)
temporary <- paste0(result_path, ".new")
saveRDS(execution, temporary, version = 3L)
if (!isTRUE(file.rename(temporary, result_path))) {
  stop("The record-bound result could not be atomically installed.",
       call. = FALSE)
}
