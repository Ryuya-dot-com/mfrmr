v4_confirmation_retro_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-confirmation-retrospective-audit-0.2.3.R"
)
v4_confirmation_artifact_path <- testthat::test_path(
  "..", "..", "validation-results",
  "gpcm-score-v4-confirmation-source-bound",
  "gpcm-score-v4-confirmation.rds"
)
v4_confirmation_retro_env <- new.env(parent = globalenv())
sys.source(v4_confirmation_retro_path, envir = v4_confirmation_retro_env)

test_that("v4 confirmation retrospective preserves the negative result", {
  skip_if_not(file.exists(v4_confirmation_artifact_path),
              "repository-local v4 confirmation artifact is absent")
  audit <- v4_confirmation_retro_env$mfrmr_audit_gpcm_score_v4_confirmation(
    v4_confirmation_artifact_path
  )
  expect_identical(
    audit$Status, "rejected_runner_false_positive_and_blocked_fits"
  )
  expect_true(audit$CompleteDenominator)
  expect_true(audit$NumericalAggregationPass)
  expect_true(audit$NumericalImplementationChecksPass)
  expect_false(audit$SealedValidatorAccepted)
  expect_true(audit$SealedValidatorNameAttributeDefect)
  expect_false(audit$FitGatePass)
  expect_identical(audit$BlockedFitCount, 2L)
  expect_identical(audit$ReviewFitCount, 4L)
  expect_true(audit$RunnerReportedPass)
  expect_true(audit$RunnerDecisionFalsePositive)
  expect_false(audit$ConfirmationAccepted)
  expect_false(audit$RetryAuthorized)
  expect_false(audit$RuleAdjustmentAuthorized)
  expect_false(audit$GeneralNUMSCORETOLFrozen)
  expect_false(audit$BoundaryProven)
  expect_false(audit$InferenceAuthorized)
})

test_that("v4 confirmation retrospective rejects numerical tampering", {
  skip_if_not(file.exists(v4_confirmation_artifact_path),
              "repository-local v4 confirmation artifact is absent")
  result <- readRDS(v4_confirmation_artifact_path)
  result$coordinates$AnalyticScoreCombinedRatio[[1L]] <- 2
  validator <- v4_confirmation_retro_env$mfrmr_gsv4qr_load_validator()
  audit <- v4_confirmation_retro_env$mfrmr_gsv4qr_numerical_audit(
    result, validator
  )
  expect_false(audit$rule_pass)
  expect_false(audit$numerical_pass)
})
