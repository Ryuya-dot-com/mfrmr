v4_retro_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-retrospective-calibration-0.2.3.R"
)
v4_retro_env <- new.env(parent = globalenv())
sys.source(v4_retro_path, envir = v4_retro_env)

test_that("v4 retrospective dry analysis preserves the rejected v3 artifact", {
  result_path <- v4_retro_env$mfrmr_gsv4r_default_result()
  skip_if_not(file.exists(result_path), "Local immutable v3 result unavailable")
  before <- digest::digest(file = result_path, algo = "sha256", serialize = FALSE)
  result <- v4_retro_env$mfrmr_run_gpcm_score_v4_retrospective(result_path)
  after <- digest::digest(file = result_path, algo = "sha256", serialize = FALSE)
  expect_identical(before, after)
  expect_false(result$executed_fit)
  expect_false(result$confirmation_authorized)
  expect_identical(result$decision$V3Status, "rejected_unchanged")
})

test_that("v4 retrospectively changes exactly the represented boundary point", {
  result_path <- v4_retro_env$mfrmr_gsv4r_default_result()
  skip_if_not(file.exists(result_path), "Local immutable v3 result unavailable")
  result <- v4_retro_env$mfrmr_run_gpcm_score_v4_retrospective(result_path)
  changed <- result$points[result$points$RegionChanged, , drop = FALSE]
  expect_equal(nrow(result$points), 24L)
  expect_equal(nrow(changed), 1L)
  expect_identical(changed$ScenarioId, "NUM-GPCM-SCORE-CONF-WORK6-C")
  expect_identical(changed$Point, "finite_slope_stress_forward")
  expect_lte(changed$RawExcess, changed$ConstructionAllowance)
  expect_true(result$decision$ClassificationCalibrationPass)
})

test_that("v4 cannot infer missing finite differences or authorization", {
  result_path <- v4_retro_env$mfrmr_gsv4r_default_result()
  skip_if_not(file.exists(result_path), "Local immutable v3 result unavailable")
  result <- v4_retro_env$mfrmr_run_gpcm_score_v4_retrospective(result_path)
  expect_identical(
    result$decision$Status,
    "classification_calibrated_numerical_evidence_incomplete"
  )
  expect_identical(result$decision$MissingRequiredFiniteDifferencePoints, 1L)
  expect_false(result$decision$NumericalDecisionComplete)
  expect_false(result$decision$ConsumedAuthorizationEmbedded)
  expect_false(result$decision$AuthorizationSchemaComplete)
  expect_false(result$decision$V4FreezeReady)
  expect_false(result$decision$V4ConfirmationAuthorized)
  expect_false(result$decision$GeneralNUMSCORETOLFrozen)
  expect_false(result$decision$InferenceAuthorized)
})
