v4_freeze_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-freeze-contract-0.2.3.R"
)
v4_freeze_env <- new.env(parent = globalenv())
sys.source(v4_freeze_path, envir = v4_freeze_env)

test_that("v4 freeze fixes only the bounded calibration rule", {
  rule <- v4_freeze_env$mfrmr_gsv4f_rule()
  expect_equal(nrow(rule), 4L)
  expect_true(all(rule$FrozenForDisjointConfirmation))
  expect_false(any(rule$GeneralNUMSCORETOLFrozen))
  expect_identical(unique(rule$ConstructedLogSlopeEnvelope), 3)
  expect_identical(unique(rule$RetainedSolutionAllowance), 0)
})

test_that("v4 freeze binds the complete executable source and artifact chain", {
  sources <- v4_freeze_env$mfrmr_gsv4f_source_registry()
  artifacts <- v4_freeze_env$mfrmr_gsv4f_artifact_registry()
  expect_equal(nrow(sources), 6L)
  expect_equal(nrow(artifacts), 2L)
  expect_true(all(grepl("^[0-9a-f]{64}$", sources$SHA256)))
  expect_true(all(grepl("^[0-9a-f]{64}$", artifacts$SHA256)))
  expect_true("gpcm-score-v4-boundary-completion-validator-0.2.3.R" %in%
                sources$File)
})

test_that("the v4 freeze seal rejects an evolved package payload", {
  artifact_root <- testthat::test_path("..", "..", "validation-results")
  required <- file.path(
    artifact_root,
    v4_freeze_env$mfrmr_gsv4f_artifact_registry()$RelativePath
  )
  skip_if_not(all(file.exists(required)),
              "repository-local v3/v4 artifacts are absent")
  expect_error(
    v4_freeze_env$mfrmr_validate_gpcm_score_v4_freeze(artifact_root),
    "The sealed v4 package payload changed.",
    fixed = TRUE
  )
})
