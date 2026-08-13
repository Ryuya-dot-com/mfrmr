rater_anchor_sparse_minimal_diagnostic_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    prospective = file.path(
      validation, "rater-anchor-sparse-prospective-contract-0.2.3.R"
    ),
    helpers = file.path(
      validation, "rater-anchor-sparse-stress-pilot-0.2.3.R"
    ),
    smoke = file.path(
      validation, "rater-anchor-sparse-prospective-smoke-0.2.3.R"
    ),
    diagnostic = file.path(
      validation, "rater-anchor-sparse-smoke-minimal-diagnostic-0.2.3.R"
    ),
    record = file.path(
      validation,
      "rater-anchor-sparse-smoke-minimal-diagnostic-record-0.2.3.md"
    )
  )
}

rater_anchor_sparse_minimal_diagnostic_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- rater_anchor_sparse_minimal_diagnostic_paths()
    needed <- paths[c("prospective", "helpers", "smoke", "diagnostic")]
    testthat::skip_if_not(all(file.exists(needed)))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    for (path in needed) sys.source(path, envir = value)
    value
  }
})

rater_anchor_sparse_minimal_diagnostic_result <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    env <- rater_anchor_sparse_minimal_diagnostic_environment()
    value <<- env$mfrmr_run_rater_anchor_sparse_smoke_minimal_diagnostic(
      execute = TRUE, progress = FALSE
    )
    value
  }
})

test_that("minimal diagnostic defaults to eight-fit dry-run", {
  env <- rater_anchor_sparse_minimal_diagnostic_environment()
  dry <- env$mfrmr_run_rater_anchor_sparse_smoke_minimal_diagnostic()

  expect_identical(dry$PlannedFits, 8L)
  expect_identical(nrow(dry$results), 0L)
  expect_false(dry$DiagnosticExecuted)
  expect_false(dry$FeasibilityHandoffAuthorized)
  expect_false(dry$AppropriateAnchorRateSelected)
  expect_false(dry$ConfirmationAuthorized)
})

test_that("maxit doubling leaves the complete-design solutions unchanged", {
  skip_on_cran()
  result <- rater_anchor_sparse_minimal_diagnostic_result()
  comparison <- result$comparison

  expect_identical(nrow(result$results), 8L)
  expect_identical(nrow(comparison), 4L)
  expect_true(all(result$results$FitReturned))
  expect_true(all(!result$results$InferenceReady))
  expect_equal(comparison$Gradient400, comparison$Gradient200,
               tolerance = 0)
  expect_equal(comparison$LogLikDelta400Minus200, rep(0, 4L), tolerance = 0)
  expect_equal(comparison$PersonMaxAbsEstimateDelta, rep(0, 4L),
               tolerance = 0)
  expect_equal(comparison$FreeRaterMaxAbsEstimateDelta, rep(0, 4L),
               tolerance = 0)
  expect_true(all(!comparison$GradientPass400))
  expect_true(all(!comparison$InferenceReady400))
  expect_identical(
    result$EvidenceSHA256,
    "b6b650c358d5d97153a7c6abdd7329ef8f3a6383866c8c2edd81892b2e6a5a73"
  )
})

test_that("extra Rater information removes six of nine extreme Persons", {
  skip_on_cran()
  result <- rater_anchor_sparse_minimal_diagnostic_result()
  summary <- result$sparse$summary
  persons <- result$sparse$extreme_persons
  loads <- result$sparse$rater_load

  expect_identical(summary$ExtremeTotalN, c(9L, 3L))
  expect_identical(summary$ExtremeLinkPersonN, c(0L, 0L))
  expect_identical(summary$ExtremeNonlinkPersonN, c(9L, 3L))
  link_extreme <- persons$Person[
    persons$DesignId == "sparse_link05_range"
  ]
  pair_extreme <- persons$Person[
    persons$DesignId == "sparse_pair_cycle"
  ]
  expect_true(all(pair_extreme %in% link_extreme))
  expect_identical(length(setdiff(link_extreme, pair_extreme)), 6L)
  expect_true(all(loads$Extreme >= 0L))
  expect_identical(max(loads$Extreme), 2L)
})

test_that("minimal diagnostic cannot authorize feasibility or a rate", {
  skip_on_cran()
  result <- rater_anchor_sparse_minimal_diagnostic_result()

  expect_true(result$DiagnosticExecuted)
  expect_false(result$FeasibilityHandoffAuthorized)
  expect_false(result$AppropriateAnchorRateSelected)
  expect_false(result$ConfirmationAuthorized)
})

test_that("minimal diagnostic record binds code, test, and evidence", {
  paths <- rater_anchor_sparse_minimal_diagnostic_paths()
  skip_if_not(file.exists(paths[["record"]]))
  code_hash <- digest::digest(
    paths[["diagnostic"]], algo = "sha256", file = TRUE, serialize = FALSE
  )
  test_hash <- digest::digest(
    testthat::test_path(
      "test-rater-anchor-sparse-smoke-minimal-diagnostic.R"
    ),
    algo = "sha256", file = TRUE, serialize = FALSE
  )
  record <- paste(
    readLines(paths[["record"]], warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_match(record, code_hash, fixed = TRUE)
  expect_match(record, test_hash, fixed = TRUE)
  expect_match(
    record,
    "b6b650c358d5d97153a7c6abdd7329ef8f3a6383866c8c2edd81892b2e6a5a73",
    fixed = TRUE
  )
  expect_match(record, "FeasibilityHandoffAuthorized = FALSE", fixed = TRUE)
  expect_match(record, "AppropriateAnchorRateSelected = FALSE", fixed = TRUE)
})
