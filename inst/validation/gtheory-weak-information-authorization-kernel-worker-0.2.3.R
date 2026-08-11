args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L || !identical(args[[1L]], "--runtime-probe")) {
  stop("Usage: Rscript --vanilla worker.R --runtime-probe OUTPUT_RDS",
       call. = FALSE)
}

output <- args[[2L]]
if (!dir.exists(dirname(output))) {
  stop("The runtime-probe output parent does not exist.", call. = FALSE)
}

RNGkind("Mersenne-Twister", "Inversion", "Rejection")
thread_variables <- c(
  "OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
  "VECLIB_MAXIMUM_THREADS", "BLIS_NUM_THREADS"
)
packages <- c(
  "digest", "lme4", "Matrix", "glmmTMB", "TMB", "minqa", "nloptr",
  "numDeriv"
)
if (!all(vapply(packages, requireNamespace, logical(1L), quietly = TRUE))) {
  stop("The frozen runtime-probe package set is incomplete.", call. = FALSE)
}

session <- sessionInfo()
parallel <- glmmTMB::glmmTMBControl()$parallel
invocation <- commandArgs(trailingOnly = FALSE)
file_argument <- grepl("^--file=", invocation)
invocation[file_argument] <- paste0(
  "--file=", basename(sub("^--file=", "", invocation[file_argument]))
)
probe_argument <- match("--runtime-probe", invocation)
if (!is.na(probe_argument) && probe_argument < length(invocation)) {
  invocation[[probe_argument + 1L]] <- "<runtime-output>"
}
identity <- list(
  Contract = "isolated_runtime_probe_b1g20_v1",
  Invocation = invocation,
  RVersion = as.character(getRversion()),
  RPlatform = R.version$platform,
  RArch = R.version$arch,
  OS = unname(Sys.info()[["sysname"]]),
  OSRelease = unname(Sys.info()[["release"]]),
  RNGKind = unname(RNGkind()),
  MatrixProducts = unname(session$matprod),
  BLAS = unname(session$BLAS),
  LAPACK = unname(session$LAPACK),
  LAVersion = unname(session$LA_version),
  Locale = unname(session$locale),
  TimeZone = unname(session$tzone),
  LocaleEnvironment = Sys.getenv(c("LC_ALL", "TZ"), unset = "<unset>"),
  StartupEnvironment = Sys.getenv(
    c("R_ENVIRON_USER", "R_PROFILE_USER"), unset = "<unset>"
  ),
  PackageVersions = stats::setNames(
    vapply(packages, function(package) {
      as.character(utils::packageVersion(package))
    }, character(1L)), packages
  ),
  GLMMTMBParallel = list(
    n = as.integer(parallel$n), autopar = isTRUE(parallel$autopar)
  ),
  ThreadEnvironment = Sys.getenv(thread_variables, unset = "<unset>")
)
record <- structure(c(identity, list(
  RuntimeHash = digest::digest(identity, algo = "sha256", serialize = TRUE)
)), class = "mfrmr_gtwao_child_runtime")

temporary <- paste0(output, ".new")
saveRDS(record, temporary, version = 3L)
if (!isTRUE(file.rename(temporary, output))) {
  stop("The runtime-probe receipt could not be atomically installed.",
       call. = FALSE)
}
