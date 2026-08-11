v4_boundary_design_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-boundary-completion-design-0.2.3.R"
)
v4_boundary_design_env <- new.env(parent = globalenv())
sys.source(v4_boundary_design_path, envir = v4_boundary_design_env)

test_that("v4 completion fixture is deterministic and fully supported", {
  fixture <- v4_boundary_design_env$mfrmr_gsv4b_fixture()
  expect_equal(nrow(fixture$data), 558L)
  expect_identical(
    fixture$sha256, v4_boundary_design_env$mfrmr_gsv4b_fixture_sha256
  )
  expect_true(all(vapply(fixture$support, function(x) all(x > 0), logical(1))))
  expect_false(fixture$stochastic)
  expect_true(fixture$calibration_only)
  expect_false(fixture$confirmation_eligible)
  expect_false(fixture$fit_opened)
})

test_that("v4 completion design seals the exact missing denominator", {
  contract <- v4_boundary_design_env$mfrmr_gsv4b_contract()
  expect_identical(contract$decision$ExpectedEvidenceRows, 4L)
  expect_identical(contract$decision$ExpectedCoordinateRows, 24L)
  expect_identical(contract$decision$ExpectedPointRows, 1L)
  expect_identical(contract$decision$ExpectedJacobianRows, 30L)
  expect_true(contract$decision$RawBoundaryExcess > 0)
  expect_lte(
    contract$decision$RawBoundaryExcess,
    contract$decision$ConstructionAllowance
  )
})

test_that("v4 completion design cannot become confirmation or execute", {
  decision <- v4_boundary_design_env$mfrmr_gsv4b_design_decision()
  expect_identical(
    decision$Status,
    "boundary_completion_design_sealed_execution_not_authorized"
  )
  expect_true(decision$CalibrationOnly)
  expect_false(decision$ConfirmationEligible)
  expect_false(decision$FitOpened)
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$GeneralNUMSCORETOLFrozen)
  expect_false(decision$InferenceAuthorized)
})
