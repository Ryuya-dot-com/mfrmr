freeze_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v3-freeze-contract-0.2.3.R"
)
freeze_env <- new.env(parent = globalenv())
sys.source(freeze_path, envir = freeze_env)

test_that("v3 freeze seal fixes the calibrated rule without promotion", {
  rule <- freeze_env$mfrmr_gsv3f_rule()
  expect_equal(nrow(rule), 4L)
  expect_true(all(rule$FrozenForDisjointConfirmation))
  expect_false(any(rule$FinalNUMSCORETOLFrozen))
  expect_identical(unique(rule$LogSlopeEnvelope), 3)
})

test_that("v3 freeze seal binds the complete numerical source chain", {
  sources <- freeze_env$mfrmr_gsv3f_source_registry()
  expect_true("numerical-stationarity-pilot-0.2.3.R" %in% sources$File)
  expect_equal(nrow(sources), 9L)
  expect_true(all(grepl("^[0-9a-f]{64}$", sources$SHA256)))
})

test_that("the v3 freeze seal rejects an evolved package payload", {
  artifact_root <- testthat::test_path("..", "..", "validation-results")
  required <- file.path(
    artifact_root,
    freeze_env$mfrmr_gsv3f_artifact_registry()$RelativePath
  )
  skip_if_not(all(file.exists(required)), "Local ignored calibration artifacts unavailable")
  expect_error(
    freeze_env$mfrmr_validate_gpcm_score_v3_freeze(artifact_root),
    "The frozen package payload changed.",
    fixed = TRUE
  )
})
