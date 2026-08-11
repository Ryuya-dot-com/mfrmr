v4_rule_path <- testthat::test_path(
  "..", "..", "inst", "validation", "gpcm-score-v4-rule-contract-0.2.3.R"
)
v4_rule_env <- new.env(parent = globalenv())
sys.source(v4_rule_path, envir = v4_rule_env)

test_that("v4 leaves all calibrated numerical rules unchanged", {
  rules <- v4_rule_env$mfrmr_gsv4_rule_registry()
  expect_equal(nrow(rules), 4L)
  expect_false(any(rules$ChangedFromV3))
  expect_false(any(rules$ConfirmationAuthorized))
  expect_equal(rules$AbsoluteFloor, c(1e-8, 1e-7, 5e-10, 1e-9))
  expect_equal(rules$RelativeRate, c(1e-10, 5e-7, 1e-9, 1e-9))
})

test_that("v4 derives a positive construction bound from unit roundoff", {
  target <- seq(-3, 3, length.out = 6L)
  represented <- c(target[-6L], -sum(target[-6L]))
  bound <- v4_rule_env$mfrmr_gsv4_construction_roundoff_bound(represented)
  expect_identical(bound$UnitRoundoff, .Machine$double.eps / 2)
  expect_true(bound$GammaN > 0)
  expect_true(bound$TotalBound > 0)
  expect_lte(max(abs(represented)) - 3, bound$TotalBound)
})

test_that("v4 applies representation allowance only to constructed points", {
  target <- seq(-3, 3, length.out = 6L)
  represented <- c(target[-6L], -sum(target[-6L]))
  constructed <- v4_rule_env$mfrmr_gsv4_classify_log_slopes(
    represented, "finite_slope_stress_forward"
  )
  retained <- v4_rule_env$mfrmr_gsv4_classify_log_slopes(
    represented, "retained_solution"
  )
  expect_identical(constructed$Region, "finite_slope_region")
  expect_true(constructed$AllowanceApplied)
  expect_identical(retained$Region, "extreme_slope_review_handoff")
  expect_identical(retained$Allowance, 0)
  expect_false(retained$RetainedSolutionRescued)
})

test_that("v4 refuses material constructed-point envelope excess", {
  material <- c(-3, -1.8, -0.6, 0.6, 1.8, 3 + 1e-10)
  decision <- v4_rule_env$mfrmr_gsv4_classify_log_slopes(
    material, "finite_slope_stress_forward"
  )
  expect_identical(decision$Region, "extreme_slope_review_handoff")
  expect_true(decision$AllowanceApplied)
  expect_gt(decision$RawExcess, decision$Allowance)
})

test_that("v4 requires consumed authorization provenance in saved results", {
  contract <- v4_rule_env$mfrmr_gsv4_contract()
  expect_true(contract$exact_consumed_authorization_must_be_embedded)
  expect_true(all(contract$authorization_schema$RequiredInSavedResult))
  expect_false(any(contract$authorization_schema$PostHocReconstructionAllowed))
  expect_false(contract$confirmation_authorized)
  expect_false(contract$general_num_score_tol_frozen)
  expect_false(contract$inference_authorized)
})
