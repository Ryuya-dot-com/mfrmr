# Run against an installed copy of the same package sources.
# Rscript scripts/run-regression.R SOURCE cran|extended|reference|all OUTPUT
args <- commandArgs(TRUE)
if (length(args) != 3L || !args[2L] %in% c("cran", "extended", "reference", "all"))
  stop("Usage: Rscript run-regression.R SOURCE cran|extended|reference|all OUTPUT")
source_dir <- normalizePath(args[1L], winslash = "/", mustWork = TRUE)
mode <- args[2L]
dir.create(args[3L], recursive = TRUE, showWarnings = FALSE)
output <- normalizePath(args[3L], winslash = "/", mustWork = TRUE)
selection <- new.env(parent = baseenv())
for (expr in parse(file.path(source_dir, "tests", "testthat.R"))) {
  if (is.call(expr) && identical(expr[[1L]], as.name("<-")) &&
      as.character(expr[[2L]]) %in%
        c("cran_light_tests", "extended_regression_tests", "reference_tests"))
    eval(expr, selection)
}
stopifnot(length(selection$cran_light_tests) > 0L,
          length(selection$extended_regression_tests) > 0L,
          length(selection$reference_tests) > 0L)
selected <- switch(mode, cran = selection$cran_light_tests,
  extended = c(selection$cran_light_tests, selection$extended_regression_tests),
  reference = selection$reference_tests,
  all = NULL)
if (!is.null(selected)) {
  stopifnot(!anyDuplicated(selected), all(file.exists(file.path(source_dir,
    "tests", "testthat", paste0("test-", selected, ".R")))))
}
filter <- if (is.null(selected)) NULL else paste0("^(", paste(selected, collapse="|"), ")$")
Sys.setenv(NOT_CRAN = if (mode == "cran") "false" else "true",
  TESTTHAT_PARALLEL = if (mode == "cran") "false" else "true",
  TESTTHAT_CPUS = if (mode == "cran") "1" else "2",
  OMP_NUM_THREADS = "1", OPENBLAS_NUM_THREADS = "1", MKL_NUM_THREADS = "1")
options(Ncpus = if (mode == "cran") 1L else 2L)
started <- proc.time()[["elapsed"]]
result <- testthat::test_dir(file.path(source_dir, "tests", "testthat"),
  package = "mfrmr", load_package = "installed", filter = filter,
  reporter = "summary", stop_on_failure = FALSE)
elapsed <- proc.time()[["elapsed"]] - started
tab <- as.data.frame(result)
saveRDS(result, file.path(output, paste0(mode, "-results.rds")))
write.csv(tab[setdiff(names(tab), "result")],
  file.path(output, paste0(mode, "-results.csv")), row.names = FALSE)
counts <- colSums(tab[c("failed", "skipped", "warning", "passed")])
print(counts)
cat("Mode:", mode, "\nTest files:", length(unique(tab$file)),
    "\nElapsed seconds:", elapsed, "\n")
writeLines(c(capture.output(print(counts)), paste("Elapsed seconds:", elapsed),
  capture.output(sessionInfo())), file.path(output, paste0(mode, "-session.txt")))
if (any(tab$failed > 0L | tab$error)) quit(status = 1L)
