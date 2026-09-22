confirmation_design_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v3-confirmation-design-0.2.3.R"
)
confirmation_design_env <- new.env(parent = globalenv())
sys.source(confirmation_design_path, envir = confirmation_design_env)

test_that("disjoint confirmation fixtures retain complete owner support", {
  for (design in c("rect4", "cyclic5", "work6")) {
    fixture <- confirmation_design_env$mfrmr_gsv3c_fixture(design)
    expect_false(fixture$stochastic)
    expect_false(fixture$fit_opened)
    expect_true(all(vapply(fixture$support, function(x) all(x > 0), logical(1))))
    expect_identical(
      fixture$sha256,
      unname(confirmation_design_env$mfrmr_gsv3c_expected_fixture_hashes[design])
    )
  }
})

test_that("confirmation design freezes complete noncalibration denominators", {
  contract <- confirmation_design_env$mfrmr_gsv3c_contract()
  expect_equal(nrow(contract$scenarios), 6L)
  expect_equal(nrow(contract$expected_evidence), 96L)
  expect_identical(contract$decision$ExpectedCoordinateRows, 560L)
  expect_identical(contract$decision$ExpectedPointRows, 24L)
  expect_identical(contract$decision$ExpectedJacobianRows, 376L)
  expect_false(any(contract$scenarios$CalibrationDataReused))
  expect_false(contract$confirmation_execution_authorized)
})

test_that("confirmation design cannot promote a numerical claim", {
  decision <- confirmation_design_env$mfrmr_gsv3c_design_decision()
  expect_identical(
    decision$Status, "confirmation_design_sealed_execution_not_authorized"
  )
  expect_false(decision$ResultOpened)
  expect_false(decision$ConfirmationExecutionAuthorized)
  expect_false(decision$GeneralNUMSCORETOLFrozen)
  expect_false(decision$InferenceAuthorized)
})
