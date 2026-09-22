v4_confirmation_runner_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-confirmation-runner-0.2.3.R"
)
v4_confirmation_runner_env <- new.env(parent = globalenv())
sys.source(v4_confirmation_runner_path, envir = v4_confirmation_runner_env)

test_that("v4 confirmation runner defaults to no-fit dry-run", {
  dry <- v4_confirmation_runner_env$mfrmr_run_gpcm_score_v4_confirmation(
    progress = FALSE
  )
  expect_false(dry$executed)
  expect_false(dry$fit_opened)
  expect_false(dry$result_opened)
  expect_false(dry$authorization_embedded)
  expect_false(dry$confirmation_execution_authorized)
  expect_equal(nrow(dry$manifest), 6L)
  expect_identical(dry$design$ExpectedEvidenceRows, 96L)
  expect_identical(dry$design$ExpectedCoordinateRows, 888L)
  expect_identical(dry$design$ExpectedPointRows, 24L)
  expect_identical(dry$design$ExpectedJacobianRows, 688L)
  expect_true(dry$identity$DevelopmentSourceLoaded)
  expect_true(dry$identity$FreshProcessRequired)
  expect_true(dry$identity$AbsoluteOutputTargetRequired)
})

test_that("v4 confirmation runner rejects missing and relative authorization", {
  expect_error(
    v4_confirmation_runner_env$mfrmr_run_gpcm_score_v4_confirmation(
      dry_run = FALSE, authorize = FALSE, progress = FALSE
    ),
    "explicit `authorize = TRUE`", fixed = TRUE
  )
  expect_error(
    v4_confirmation_runner_env$mfrmr_run_gpcm_score_v4_confirmation(
      dry_run = FALSE, authorize = TRUE,
      output_path = "relative-confirmation.rds", progress = FALSE
    ),
    "exact v4 confirmation authorization row", fixed = TRUE
  )
  expect_false(v4_confirmation_runner_env$mfrmr_gsv4q_is_absolute_path(
    "relative-confirmation.rds"
  ))
  expect_true(v4_confirmation_runner_env$mfrmr_gsv4q_is_absolute_path(
    normalizePath(tempdir(), winslash = "/", mustWork = TRUE)
  ))
})

test_that("v4 confirmation expected class counts close exactly", {
  counts <- v4_confirmation_runner_env$mfrmr_gsv4q_expected_coordinate_counts()
  expect_equal(nrow(counts), 96L)
  expect_identical(sum(counts$ExpectedCount), 888L)
  expect_false(anyNA(counts))
  expect_identical(anyDuplicated(counts[c(
    "ScenarioId", "Point", "ParameterClass"
  )]), 0L)
})

test_that("v4 confirmation decision fails closed without exact denominator", {
  decision <- v4_confirmation_runner_env$mfrmr_gsv4q_decision(
    data.frame(), data.frame(), data.frame(), data.frame(),
    authorization_embedded = FALSE
  )
  expect_identical(decision$Status, "rejected")
  expect_false(decision$CompleteDenominator)
  expect_false(decision$BoundedV4RuleConfirmed)
  expect_false(decision$ConsumedAuthorizationEmbedded)
  expect_false(decision$GeneralNUMSCORETOLFrozen)
  expect_false(decision$BoundaryProven)
  expect_false(decision$InferenceAuthorized)
})
