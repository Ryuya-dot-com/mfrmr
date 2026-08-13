pcm_gpcm_jml_paired_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    runner = file.path(
      validation, "pcm-gpcm-jml-paired-calibration-0.2.3.R"
    ),
    record = file.path(
      validation, "pcm-gpcm-jml-paired-calibration-record-0.2.3.md"
    )
  )
}

pcm_gpcm_jml_paired_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    runner <- pcm_gpcm_jml_paired_paths()[["runner"]]
    testthat::skip_if_not(file.exists(runner))
    value <<- new.env(parent = globalenv())
    sys.source(runner, envir = value)
    value
  }
})

test_that("paired JML manifest is small, fixed, and non-promoting", {
  env <- pcm_gpcm_jml_paired_environment()
  smoke <- env$mfrmr_pgjp_manifest("smoke")
  pilot <- env$mfrmr_pgjp_manifest("pilot")

  expect_identical(nrow(smoke), 2L)
  expect_identical(nrow(pilot), 6L)
  expect_identical(
    sort(unique(pilot$SlopeRegime)), c("moderate", "unit_slopes")
  )
  expect_true(all(table(pilot$SlopeRegime) == 3L))
  expect_identical(anyDuplicated(pilot$ScenarioId), 0L)
  expect_true(all(pilot$NPersons == 40L))
  expect_true(all(pilot$NRaters == 3L))
  expect_true(all(pilot$NCriteria == 4L))
  expect_true(all(pilot$NCategories == 4L))
  expect_true(all(pilot$Estimator == "JML"))
  expect_true(all(pilot$CalibrationOnly))
  expect_true(all(!pilot$ModelSelectionAuthorized))
  expect_true(all(!pilot$BroadSimulationAuthorized))
  expect_true(all(!pilot$ConfirmationAuthorized))

  dry <- env$mfrmr_run_pcm_gpcm_jml_paired_calibration(
    "pilot", execute = FALSE
  )
  expect_identical(nrow(dry$manifest), 6L)
  expect_identical(nrow(dry$results), 0L)
  expect_false(dry$ModelSelectionAuthorized)
  expect_false(dry$BroadSimulationAuthorized)
  expect_false(dry$ConfirmationAuthorized)
})

test_that("paired JML results retain likelihood gain as typed evidence", {
  env <- pcm_gpcm_jml_paired_environment()
  manifest <- env$mfrmr_pgjp_manifest("smoke")
  results <- do.call(rbind, lapply(seq_len(nrow(manifest)), function(i) {
    row <- env$mfrmr_pgjp_empty_result(
      as.list(manifest[i, , drop = FALSE]), "paired_fit_retained"
    )
    row$PairFitSucceeded <- TRUE
    row$DataSHA256 <- paste(rep(as.character(i), 64L), collapse = "")
    row$Rows <- 480L
    row$FittedSlopeCount <- 4L
    row$EvidenceTier <- "jml_optimizer_trace_only_not_inference_ready"
    row$ObservedLogLikDifference <- c(0.5, 6)[[i]]
    row$LogLikDifferenceStatus <-
      "optimizer_trace_only_not_inference_ready"
    row$SelectionRoute <-
      "withheld_JML_has_no_automatic_PCM_GPCM_selection"
    row$PCMvsGPCMLRT <- "withheld_current_scope"
    row$FACETSComparisonRole <-
      "PCM_JML_side_only_no_FACETS_free_slope_GPCM_counterpart"
    row
  }))

  expect_no_error(env$mfrmr_pgjp_validate_results(results, manifest))
  summary <- env$mfrmr_pgjp_summary(results)
  expect_identical(nrow(summary), 2L)
  expect_true(all(summary$FormalSelections == 0L))

  promoted <- results
  promoted$FormalModelSelectionAvailable[[1L]] <- TRUE
  expect_error(
    env$mfrmr_pgjp_validate_results(promoted, manifest),
    "incorrectly promoted"
  )
  facets <- results
  facets$FACETSComparisonRole[[1L]] <- "free_slope_comparator"
  expect_error(
    env$mfrmr_pgjp_validate_results(facets, manifest),
    "PCM/JML side only"
  )
})

test_that("paired JML smoke executes both slope regimes on shared data", {
  skip_on_cran()
  skip_if_not_installed("digest")
  env <- pcm_gpcm_jml_paired_environment()
  result <- env$mfrmr_run_pcm_gpcm_jml_paired_calibration(
    "smoke", progress = FALSE
  )

  expect_identical(nrow(result$results), 2L)
  expect_true(all(result$results$PairFitSucceeded))
  expect_true(all(result$results$Rows == 480L))
  expect_true(all(result$results$FittedSlopeCount == 4L))
  expect_true(all(grepl("^jml_", result$results$EvidenceTier)))
  expect_true(all(!result$results$FormalModelSelectionAvailable))
  expect_false(result$ModelSelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("paired calibration record binds runner and tests", {
  skip_if_not_installed("digest")
  paths <- pcm_gpcm_jml_paired_paths()
  skip_if_not(all(file.exists(paths)))
  runner_hash <- digest::digest(
    paths[["runner"]], algo = "sha256", file = TRUE, serialize = FALSE
  )
  test_hash <- digest::digest(
    testthat::test_path("test-pcm-gpcm-jml-paired-calibration.R"),
    algo = "sha256", file = TRUE, serialize = FALSE
  )
  record <- paste(
    readLines(paths[["record"]], warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_match(record, runner_hash, fixed = TRUE)
  expect_match(record, test_hash, fixed = TRUE)
  expect_match(record, "ModelSelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(record, "BroadSimulationAuthorized = FALSE", fixed = TRUE)
  expect_match(record, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
