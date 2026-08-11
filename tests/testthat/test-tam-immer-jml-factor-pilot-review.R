load_tam_immer_factor_review <- function() {
  skip_if_not_installed("dplyr")
  runner <- testthat::test_path(
    "..", "..", "inst", "validation",
    "tam-immer-jml-factor-stress-0.2.3.R"
  )
  review <- testthat::test_path(
    "..", "..", "inst", "validation",
    "tam-immer-jml-factor-pilot-review-0.2.3.R"
  )
  skip_if_not(all(file.exists(c(runner, review))),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  sys.source(review, envir = env)
  env
}

test_that("factor-pilot review requires the exact pilot identity", {
  env <- load_tam_immer_factor_review()
  result <- list(
    Tier = "pilot",
    Manifest = data.frame(Row = seq_len(290L)),
    Datasets = data.frame(), DesignAudit = data.frame(),
    Modes = data.frame(), Metrics = data.frame(),
    CheckpointLedger = data.frame(),
    ContractPassed = TRUE, EvidenceReady = FALSE
  )
  expect_no_error(env$mfrmr_tif_review_validate(result))
  result$Manifest <- result$Manifest[-1L, , drop = FALSE]
  expect_error(
    env$mfrmr_tif_review_validate(result),
    "declared 290-dataset pilot"
  )
})

test_that("bias-correction review uses common eligible raw datasets", {
  env <- load_tam_immer_factor_review()
  result <- list(
    Modes = data.frame(
      DatasetId = rep(c("D1", "D2"), each = 2L),
      ModeId = rep(c("TAM_RAW", "TAM_BC"), 2L),
      FitReturned = TRUE,
      OriginalRawEligible = c(TRUE, FALSE, FALSE, FALSE),
      stringsAsFactors = FALSE
    ),
    Metrics = data.frame(
      DatasetId = rep(c("D1", "D2"), each = 4L),
      Facet = "CumulativeDifficultySurface",
      Metric = rep(c("Bias", "RMSE"), times = 4L),
      Eligible = TRUE,
      ModeId = rep(c("TAM_RAW", "TAM_RAW", "TAM_BC", "TAM_BC"), 2L),
      Value = c(-0.10, 0.40, -0.04, 0.30,
                -0.20, 0.50, -0.08, 0.35),
      stringsAsFactors = FALSE
    )
  )
  comparison <- env$mfrmr_tif_bias_correction_comparison(
    result, "TAM_RAW", "TAM_BC", require_original_raw = TRUE
  )
  expect_equal(comparison$CommonDatasets, c(1L, 1L))
  expect_true(all(comparison$ImprovedFraction == 1))
  expect_equal(comparison$CorrectedMean, c(-0.04, 0.30))
})
