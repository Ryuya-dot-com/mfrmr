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
  expect_identical(
    dry$FingerprintScope, "within_run_pairing_and_provenance_only"
  )

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
  expect_true("Warnings" %in% names(result$results))
  expect_true(all(comparison$ComparisonStatus == "compared"))
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
})

test_that("fit warnings remain visible when the diagnostic fit errors", {
  env <- rater_anchor_sparse_minimal_diagnostic_environment()
  replacements <- list(
    mfrmr_rasps_apply_design = function(...) list(data = data.frame()),
    mfrmr_rasps_build_anchors = function(...) list(anchors = data.frame(
      Facet = character(), Level = character(), Anchor = numeric()
    )),
    fit_mfrm = function(...) {
      warning("fit warning retained", call. = FALSE)
      stop("fit failed", call. = FALSE)
    }
  )
  local_names <- names(replacements)[vapply(
    names(replacements), exists, logical(1), envir = env, inherits = FALSE
  )]
  originals <- mget(local_names, envir = env, inherits = FALSE)
  on.exit({
    remove_names <- setdiff(names(replacements), local_names)
    if (length(remove_names) > 0L) rm(list = remove_names, envir = env)
    if (length(originals) > 0L) list2env(originals, envir = env)
  }, add = TRUE)
  list2env(replacements, envir = env)

  expect_no_warning(fit <- env$mfrmr_rasmd_fit_complete(
    list(AnchorConfig = "warning-fixture"), generated = list(), maxit = 200L
  ))

  expect_false(fit$result$FitReturned)
  expect_identical(fit$result$Warnings, "fit warning retained")
  expect_identical(fit$result$Error, "fit failed")
})

test_that("budget comparison is indeterminate after a failed fit", {
  env <- rater_anchor_sparse_minimal_diagnostic_environment()
  results <- data.frame(
    AnchorConfig = c("exact_anchor_25", "exact_anchor_25"),
    Maxit = c(200L, 400L), FitReturned = c(FALSE, TRUE),
    InferenceReady = FALSE, Error = c("fit failed", NA_character_),
    TerminalGradientSupNorm = NA_real_, GradientReviewTolerance = NA_real_,
    LogLik = NA_real_, FreeRaterAbsoluteRMSE = NA_real_,
    PersonAbsoluteRMSE = NA_real_, PersonRankSpearman = NA_real_
  )
  parameters <- data.frame(
    AnchorConfig = character(), Maxit = integer(), ParameterId = character(),
    Block = character(), Estimate = numeric()
  )

  expect_no_warning(comparison <- env$mfrmr_rasmd_compare_budgets(
    results, parameters
  ))

  expect_identical(comparison$ComparisonStatus, "indeterminate")
  expect_identical(comparison$ComparisonReason, "fit_not_returned:maxit_200")
  expect_true(is.na(comparison$PersonMaxAbsEstimateDelta))
  expect_true(is.na(comparison$FreeRaterMaxAbsEstimateDelta))

  returned <- results
  returned$FitReturned <- TRUE
  returned$Error <- NA_character_
  missing_parameters <- env$mfrmr_rasmd_compare_budgets(returned, parameters)
  expect_identical(
    missing_parameters$ComparisonReason,
    "parameter_contract_failed"
  )

  parameters <- data.frame(
    AnchorConfig = rep("exact_anchor_25", 4L),
    Maxit = rep(c(200L, 400L), each = 2L),
    ParameterId = rep(c("Person:P1", "FreeRater:R1"), 2L),
    Block = rep(c("Person", "FreeRater"), 2L),
    Estimate = 0
  )
  unavailable <- env$mfrmr_rasmd_compare_budgets(returned, parameters)
  expect_identical(
    unavailable$ComparisonReason,
    "comparison_metric_unavailable"
  )

  block_drift <- parameters
  block_drift$Block[block_drift$Maxit == 400L][[1L]] <- "FreeRater"
  drifted <- env$mfrmr_rasmd_compare_budgets(returned, block_drift)
  expect_identical(drifted$ComparisonReason, "parameter_contract_failed")

  unknown_block <- parameters
  unknown_block$Block[[1L]] <- "Unknown"
  unknown <- env$mfrmr_rasmd_compare_budgets(returned, unknown_block)
  expect_identical(unknown$ComparisonReason, "parameter_contract_failed")
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

test_that("minimal diagnostic record documents semantic evidence", {
  paths <- rater_anchor_sparse_minimal_diagnostic_paths()
  skip_if_not(file.exists(paths[["record"]]))
  record <- paste(
    readLines(paths[["record"]], warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_match(record, "numerical tolerances", fixed = TRUE)
  expect_match(record, "not a\\s+cross-machine")
  expect_match(record, "FeasibilityHandoffAuthorized = FALSE", fixed = TRUE)
  expect_match(record, "AppropriateAnchorRateSelected = FALSE", fixed = TRUE)
})
