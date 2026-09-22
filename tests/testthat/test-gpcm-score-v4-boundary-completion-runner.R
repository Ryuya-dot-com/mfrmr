v4_completion_runner_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-boundary-completion-runner-0.2.3.R"
)
v4_completion_runner_env <- new.env(parent = globalenv())
sys.source(v4_completion_runner_path, envir = v4_completion_runner_env)

test_that("v4 completion runner defaults to a no-fit dry-run", {
  dry <- v4_completion_runner_env$mfrmr_run_gpcm_score_v4_boundary_completion(
    progress = FALSE
  )
  expect_false(dry$executed)
  expect_false(dry$fit_opened)
  expect_false(dry$authorization_embedded)
  expect_equal(nrow(dry$manifest), 1L)
  expect_identical(dry$design$ExpectedEvidenceRows, 4L)
  expect_true(dry$identity$DevelopmentSourceLoaded)
  expect_true(dry$identity$FreshProcessRequired)
})

test_that("v4 completion runner refuses missing authorization", {
  expect_error(
    v4_completion_runner_env$mfrmr_run_gpcm_score_v4_boundary_completion(
      dry_run = FALSE, authorize = FALSE, progress = FALSE
    ), "explicit `authorize = TRUE`", fixed = TRUE
  )
  expect_error(
    v4_completion_runner_env$mfrmr_run_gpcm_score_v4_boundary_completion(
      dry_run = FALSE, authorize = TRUE,
      output_path = tempfile(fileext = ".rds"), progress = FALSE
    ), "exact v4 completion authorization row", fixed = TRUE
  )
})

test_that("v4 completion decision fails closed without exact denominator", {
  empty <- list(evidence = data.frame(), coordinates = data.frame(),
                point_summary = data.frame(), jacobian = data.frame())
  decision <- v4_completion_runner_env$mfrmr_gsv4x_decision(
    empty, authorization_embedded = FALSE
  )
  expect_identical(decision$Status, "rejected")
  expect_false(decision$CompleteDenominator)
  expect_false(decision$NumericalRulePass)
  expect_false(decision$ConsumedAuthorizationEmbedded)
  expect_false(decision$V4FreezeReady)
  expect_false(decision$ConfirmationEligible)
  expect_false(decision$V4ConfirmationAuthorized)
})
