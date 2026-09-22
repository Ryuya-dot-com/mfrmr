confirmation_runner_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v3-confirmation-runner-0.2.3.R"
)
confirmation_runner_env <- new.env(parent = globalenv())
sys.source(confirmation_runner_path, envir = confirmation_runner_env)

test_that("confirmation runner defaults to a sealed no-fit dry-run", {
  dry <- confirmation_runner_env$mfrmr_run_gpcm_score_v3_confirmation(
    progress = FALSE
  )
  expect_false(dry$executed)
  expect_false(dry$result_opened)
  expect_false(dry$confirmation_execution_authorized)
  expect_equal(nrow(dry$manifest), 6L)
  expect_identical(dry$design$ExpectedEvidenceRows, 96L)
  expect_true(dry$identity$DevelopmentSourceLoaded)
  expect_true(dry$identity$FreshProcessRequired)
})

test_that("confirmation runner fails closed without separate authorization", {
  expect_error(
    confirmation_runner_env$mfrmr_run_gpcm_score_v3_confirmation(
      dry_run = FALSE, authorize = FALSE, progress = FALSE
    ), "explicit `authorize = TRUE`", fixed = TRUE
  )
  expect_error(
    confirmation_runner_env$mfrmr_run_gpcm_score_v3_confirmation(
      dry_run = FALSE, authorize = TRUE,
      output_path = tempfile(fileext = ".rds"), progress = FALSE
    ), "separate exact confirmation authorization record", fixed = TRUE
  )
})

test_that("confirmation authorization rejects stale identities and used targets", {
  dry <- confirmation_runner_env$mfrmr_run_gpcm_score_v3_confirmation(
    progress = FALSE
  )
  target <- tempfile(fileext = ".rds")
  auth <- data.frame(
    Status = "go_issued_not_executed",
    RunnerIdentitySHA256 = "stale",
    ManifestSHA256 = dry$manifest$ManifestSHA256[1],
    OutputPath = normalizePath(target, winslash = "/", mustWork = FALSE),
    ExecutionAuthorized = TRUE, stringsAsFactors = FALSE
  )
  expect_error(
    confirmation_runner_env$mfrmr_gsv3x_validate_authorization(
      auth, dry$identity, dry$manifest, target
    ), "absent, stale, mismatched, or already consumed", fixed = TRUE
  )
  auth$RunnerIdentitySHA256 <- dry$identity$IdentitySHA256
  writeLines("occupied", target)
  expect_error(
    confirmation_runner_env$mfrmr_gsv3x_validate_authorization(
      auth, dry$identity, dry$manifest, target
    ), "absent, stale, mismatched, or already consumed", fixed = TRUE
  )
})

test_that("confirmation decision fails closed on incomplete evidence", {
  decision <- confirmation_runner_env$mfrmr_gsv3x_decision(
    data.frame(), data.frame(), data.frame(), data.frame()
  )
  expect_identical(decision$Status, "rejected")
  expect_false(decision$CompleteDenominator)
  expect_false(decision$FrozenRulePass)
  expect_false(decision$GeneralNUMSCORETOLFrozen)
  expect_false(decision$InferenceAuthorized)
})
