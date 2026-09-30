# Run with testthat::test_file() from the package root; no package fit/check.
testthat::test_that("timing runner preserves evidence before failing an over-budget check", {
  root <- normalizePath(file.path("..", ".."))
  env <- new.env(parent = globalenv())
  sys.source(file.path(root, "inst/validation/release-check-runner-0.2.4.R"), env)
  testthat::skip_if_not_installed("RTMB", "2.0")
  testthat::skip_if_not_installed("nleqslv")
  withr::local_envvar(c(MFRMR_CHECK_PROFILE = "cran-timing", GITHUB_SHA = NA,
    NOT_CRAN = "true"))
  env$mfrmr_release_check_git_scalar <- function(...) paste(rep("a", 40), collapse = "")
  testthat::local_mocked_bindings(build = function(path, dest_path, ...) {
    result <- file.path(dest_path, "mfrmr.tar.gz")
    writeLines("Mock archive for runner-control testing only", result)
    result
  }, .package = "pkgbuild")
  duration <- 500
  warnings <- character()
  testthat::local_mocked_bindings(rcmdcheck = function(path, args, check_dir, error_on, ...) {
    testthat::expect_identical(args, c("--as-cran", "--timings"))
    testthat::expect_identical(error_on, "never")
    testthat::expect_identical(Sys.getenv("NOT_CRAN"), "false")
    dir.create(file.path(check_dir, "mfrmr.Rcheck"), recursive = TRUE)
    phases <- c("R code for possible problems", "examples", "tests",
      "re-building of vignette outputs", "PDF version of manual", "HTML version of manual")
    writeLines(c("* checking whether package 'mfrmr' can be installed ... [100s] OK",
      paste0("* checking ", phases, " ... [10s] OK"), "Status: 1 NOTE"),
      file.path(check_dir, "mfrmr.Rcheck", "00check.log"))
    list(duration = duration, errors = character(), warnings = warnings, notes = "Development version")
  }, .package = "rcmdcheck")
  out <- tempfile(); withr::defer(unlink(out, recursive = TRUE))
  capture.output(receipt <- env$mfrmr_release_check_main(root, file.path(out, "pass")))
  testthat::expect_identical(receipt$CheckProfile, "cran-timing")
  testthat::expect_false(receipt$G4EvidenceIssued)
  testthat::expect_identical(Sys.getenv("NOT_CRAN"), "true")
  duration <- 900
  testthat::expect_error(capture.output(env$mfrmr_release_check_main(root, file.path(out, "over"))),
    "below 600 seconds")
  evidence <- readRDS(file.path(out, "over", "check-timing.rds"))
  testthat::expect_false(evidence$Timing$UnderTenMinutes)
  testthat::expect_equal(evidence$Timing$CheckElapsedSeconds, 800)
  testthat::expect_identical(evidence$Environment[["OMP_NUM_THREADS"]], "1")
  testthat::expect_true(file.exists(file.path(out, "over", "check-phases.csv")))
  testthat::expect_identical(Sys.getenv("NOT_CRAN"), "true")
  duration <- 500
  warnings <- "Deliberate mock check warning"
  testthat::expect_error(capture.output(env$mfrmr_release_check_main(root, file.path(out, "warning"))),
    "did not pass R CMD check")
  evidence <- readRDS(file.path(out, "warning", "check-timing.rds"))
  testthat::expect_identical(evidence$Warnings, warnings)
  testthat::expect_false(file.exists(file.path(out, "warning", "release-check-receipt.rds")))
  testthat::expect_identical(Sys.getenv("NOT_CRAN"), "true")
})
