# Time the installed package's actual CRAN selector, including file-level setup.
# Rscript this-file.R library output-directory [file-name-regex]
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) %in% 2:3)
lib <- normalizePath(args[1], mustWork = TRUE)
dir.create(args[2], recursive = TRUE, showWarnings = FALSE)
out <- normalizePath(args[2], mustWork = TRUE)
.libPaths(c(lib, .libPaths()))
Sys.setenv(NOT_CRAN = "false")
library(mfrmr)
library(testthat)
stopifnot(identical(normalizePath(find.package("mfrmr")),
                    normalizePath(file.path(lib, "mfrmr"))))
tests <- system.file("tests", package = "mfrmr", mustWork = TRUE)
selection <- new.env()
for (expr in parse(file.path(tests, "testthat.R"))) {
  if (is.call(expr) && identical(expr[[1]], as.name("<-")) &&
      as.character(expr[[2]]) %in% c("cran_light_tests", "cran_light_filter")) {
    eval(expr, selection)
  }
}
filter <- if (length(args) == 3L) args[3] else selection$cran_light_filter
stopifnot(is.character(filter), length(filter) == 1L, nzchar(filter))
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
writeLines(filter, file.path(out, "selector.txt"))
saveRDS(list(package = find.package("mfrmr"),
             description = packageDescription("mfrmr"),
             threads = Sys.getenv(c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS",
                                    "VECLIB_MAXIMUM_THREADS"))),
        file.path(out, "environment.rds"))

timings <- list()
TimingReporter <- R6::R6Class("CranTimingReporter", inherit = ListReporter,
  public = list(
    file_start = NULL,
    file_name = NULL,
    start_file = function(name) {
      self$file_start <- proc.time()
      self$file_name <- name
      cat("START", name, "\n"); flush.console()
      super$start_file(name)
    },
    end_file = function() {
      super$end_file()
      elapsed <- proc.time() - self$file_start
      timings[[length(timings) + 1L]] <<- data.frame(
        File = self$file_name, Elapsed = unname(elapsed["elapsed"]),
        User = unname(elapsed["user.self"] + elapsed["user.child"]),
        System = unname(elapsed["sys.self"] + elapsed["sys.child"]))
      write.csv(do.call(rbind, timings), file.path(out, "files.csv"), row.names = FALSE)
      cat("END", self$file_name, unname(elapsed["elapsed"]), "seconds\n")
      flush.console()
    }
  ))
reporter <- TimingReporter$new()
started <- proc.time()
error <- tryCatch({
  withr::with_dir(tests, test_check("mfrmr", filter = filter, reporter = reporter,
                                  stop_on_failure = FALSE))
  NULL
}, error = identity)
elapsed <- proc.time() - started
results <- reporter$get_results()
saveRDS(list(results = results, elapsed = elapsed,
             error = if (is.null(error)) NULL else conditionMessage(error)),
        file.path(out, "results.rds"))
summary <- as.data.frame(results)
write.csv(summary[!vapply(summary, is.list, logical(1))],
          file.path(out, "tests.csv"), row.names = FALSE)
print(elapsed)
if (!is.null(error)) stop(error)
print(colSums(summary[c("failed", "skipped", "error", "warning", "passed")]))
stopifnot(!any(summary$failed > 0 | summary$error))
