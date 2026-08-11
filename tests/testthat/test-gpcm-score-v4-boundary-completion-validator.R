v4_completion_validator_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-boundary-completion-validator-0.2.3.R"
)
v4_completion_result_path <- testthat::test_path(
  "..", "..", "validation-results",
  "gpcm-score-v4-boundary-completion-source-bound",
  "gpcm-score-v4-boundary-completion.rds"
)
v4_completion_validator_env <- new.env(parent = globalenv())
sys.source(v4_completion_validator_path, envir = v4_completion_validator_env)

test_that("v4 completion validator independently accepts the sealed artifact", {
  skip_if_not(file.exists(v4_completion_result_path),
              "repository-local completion artifact is absent")
  audit <- v4_completion_validator_env$
    mfrmr_validate_gpcm_score_v4_boundary_completion(
      v4_completion_result_path
    )
  expect_identical(audit$Status,
                   "validated_calibration_only_numerical_pass")
  expect_true(audit$ArtifactIntegrityPass)
  expect_true(audit$SourceIdentityPass)
  expect_true(audit$AuthorizationIssueHashPass)
  expect_true(audit$AuthorizationConsumedRowHashPass)
  expect_identical(audit$TargetPathForm, "repository_relative")
  expect_false(audit$AbsoluteTargetRecorded)
  expect_true(audit$TargetResolvesToArtifact)
  expect_true(audit$CompleteDenominator)
  expect_true(audit$NumericalRulePass)
  expect_identical(audit$FitReadiness, "review")
  expect_true(audit$CalibrationOnly)
  expect_false(audit$ConfirmationEligible)
  expect_true(audit$V4FreezeReviewReady)
  expect_false(audit$V4Frozen)
  expect_false(audit$GeneralNUMSCORETOLFrozen)
  expect_false(audit$InferenceAuthorized)
})

test_that("v4 completion validator rejects numerical tampering", {
  skip_if_not(file.exists(v4_completion_result_path),
              "repository-local completion artifact is absent")
  result <- readRDS(v4_completion_result_path)
  result$coordinates$FiniteDifferenceCombinedRatio[1] <- 2
  expect_error(
    v4_completion_validator_env$mfrmr_gsv4v_validate_result(result),
    "numerical denominator or coordinate rules failed",
    fixed = TRUE
  )
})

test_that("v4 completion validator rejects authorization tampering", {
  skip_if_not(file.exists(v4_completion_result_path),
              "repository-local completion artifact is absent")
  result <- readRDS(v4_completion_result_path)
  result$authorization$ConsumedAtUTC <- "changed"
  expect_error(
    v4_completion_validator_env$mfrmr_gsv4v_validate_result(result),
    "authorization cannot be verified",
    fixed = TRUE
  )
})
