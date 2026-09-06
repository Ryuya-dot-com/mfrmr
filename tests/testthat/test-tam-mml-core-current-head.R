load_tam_mml_core_current_head <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  .mfrmr_test_ensure_source_namespace(root)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-additive-mfrm-design-0.2.3.R",
    "conquest-additive-mfrm-reference-preflight-0.2.3.R",
    "tam-mml-core-calibration-0.2.3.R",
    "tam-mml-core-current-head-0.2.4.R"
  ))
  skip_if_not(all(file.exists(paths)), "Current-head TAM MML bridge is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("TAM MML benign core remains reproducible on the 0.2.4 source", {
  ctx <- load_tam_mml_core_current_head()
  result <- ctx$env$mfrmr_run_tam_mml_core_current_head(ctx$root)

  expect_identical(result$specification, "0.2.4-tam-mml-core-current-head-v1")
  expect_identical(result$contract_version, "mfrmr_tam_mml_core_current_head_v1")
  expect_true(startsWith(result$source_version, "0.2.4"))
  expect_true(result$calibration_complete)
  expect_identical(nrow(result$summaries), 4L)
  expect_identical(nrow(result$coordinates), 46L)
  expect_identical(nrow(result$integration), 25L)
  expect_lt(max(result$coordinates$AbsoluteDifference), 1e-5)
  expect_lt(max(abs(result$summaries$DevianceSignedDifference)), 1e-5)
  expect_true(all(result$summaries$MfrmrOracleLogLikAbsoluteDifference <= 1e-9))
  expect_true(all(
    result$summaries$MfrmrOracleProbabilityMaximumAbsoluteDifference <= 1e-13
  ))
  expect_identical(
    result$evidence_role, "current_head_engineering_regression_only"
  )
  expect_false(result$stress_envelope_evaluated)
  expect_false(result$comparison_tolerance_frozen)
  expect_false(result$comparison_passed)
  expect_false(result$inference_ready)
  expect_false(result$large_simulation_authorized)
  expect_false(result$release_authorized)
})
