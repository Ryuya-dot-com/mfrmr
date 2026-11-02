# Run from the package root; this gate requires actual execution, with no skips.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("Usage: Rscript scripts/check-stan-live.R OUTPUT_DIRECTORY")
out <- args[1L]
if (dir.exists(out)) stop("Use a new output directory to preserve earlier evidence.")
for (pkg in c("cmdstanr", "posterior", "jsonlite", "pkgload", "testthat")) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Required live-check package missing: ", pkg)
}
cmdstanr::cmdstan_path() # Error, rather than a skipped test, if unconfigured.
version <- cmdstanr::cmdstan_version(error_on_NA = TRUE)
dir.create(out, recursive = TRUE)
out <- normalizePath(out)
sources <- sort(unique(c("DESCRIPTION", "NAMESPACE", "scripts/check-stan-live.R",
  list.files(c("R", "src", "inst/model-export", "inst/extdata", "tests/testthat"),
             pattern = "[.](R|cpp|h|hpp|stan|rds|txt|json)$", recursive = TRUE, full.names = TRUE))))
before <- tools::md5sum(sources)
utils::write.csv(data.frame(File = names(before), MD5 = unname(before)),
                 file.path(out, "source-md5.csv"), row.names = FALSE)
Sys.setenv(NOT_CRAN = "true")
pkgload::load_all(".", quiet = TRUE)
files <- c("tests/testthat/test-posterior-contrasts-live.R",
           "tests/testthat/test-posterior-scoring-live.R")
started <- Sys.time()
results <- lapply(files, function(path) {
  as.data.frame(testthat::test_file(path, reporter = "summary", stop_on_failure = FALSE))
})
results <- do.call(rbind, results)
counts <- vapply(c("passed", "failed", "error", "warning", "skipped"),
                 function(key) sum(results[[key]]), numeric(1))
unchanged <- identical(before, tools::md5sum(sources))
receipt <- list(
  scope = "Short-chain export, sampling, saved-draw reload, contrasts and new-Person scoring; not finite-sample calibration",
  git_commit = system2("git", c("rev-parse", "HEAD"), stdout = TRUE),
  dirty_worktree = length(system2("git", c("status", "--porcelain"), stdout = TRUE)) > 0L,
  source_manifest = "source-md5.csv", source_unchanged_during_check = unchanged,
  R = R.version.string, platform = R.version$platform,
  cmdstan = as.character(version),
  packages = setNames(lapply(c("cmdstanr", "posterior", "testthat"),
                            function(p) as.character(utils::packageVersion(p))),
                      c("cmdstanr", "posterior", "testthat")),
  build_environment = as.list(Sys.getenv(c("PRECOMPILED_HEADERS", "CXX", "CXXFLAGS"), unset = NA_character_)),
  counts = as.list(counts), elapsed_seconds = as.numeric(difftime(Sys.time(), started, units = "secs"))
)
jsonlite::write_json(receipt, file.path(out, "receipt.json"), pretty = TRUE, auto_unbox = TRUE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
if (!unchanged || any(counts[c("failed", "error", "warning", "skipped")] > 0) || counts["passed"] == 0)
  stop("Live Stan gate failed; inspect the recorded counts and source identity.")
cat("Live Stan gate passed with no skips; evidence: ", out, "\n", sep = "")
