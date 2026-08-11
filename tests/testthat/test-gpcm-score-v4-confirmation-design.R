v4_confirmation_design_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-confirmation-design-0.2.3.R"
)
v4_confirmation_design_env <- new.env(parent = globalenv())
sys.source(v4_confirmation_design_path, envir = v4_confirmation_design_env)

test_that("v4 confirmation fixtures are fixed, supported, and connected", {
  expected <- c(
    braid5 = "7d751e4436ea6be7ae9bad5d1d990b527fb81f5ee5b3335dc9475225a779dbd0",
    weave6 = "53e53bdc816338008a07459d434c69a1b7acabfa41ef5dd215d2fefd8dcb2a7b",
    fan7 = "50bb1b0c48f7ee9154315d5794d9c44a60f842f6df986e57191cc7c78ddc899f"
  )
  for (id in names(expected)) {
    fixture <- v4_confirmation_design_env$mfrmr_gsv4c_fixture(id)
    expect_identical(fixture$sha256, unname(expected[id]))
    expect_false(fixture$stochastic)
    expect_false(fixture$fit_opened)
    expect_false(fixture$result_opened)
    expect_false(fixture$confirmation_executed)
    expect_true(all(fixture$support$Rater > 0))
    expect_true(all(fixture$support$Criterion > 0))
    expect_true(v4_confirmation_design_env$mfrmr_gsv4c_bipartite_connected(
      fixture$data, "Person", "Rater"
    ))
    expect_true(v4_confirmation_design_env$mfrmr_gsv4c_bipartite_connected(
      fixture$data, "Person", "Criterion"
    ))
  }
})

test_that("v4 confirmation design spans sparse and imbalanced structures", {
  scenarios <- v4_confirmation_design_env$mfrmr_gsv4c_scenarios()
  expect_equal(nrow(scenarios), 6L)
  expect_setequal(unique(scenarios$SlopeOwner), c("Criterion", "Rater"))
  expect_true(all(scenarios$SlopeOwner == scenarios$StepOwner))
  expect_setequal(unique(scenarios$NCategories), c(5L, 6L, 7L))
  expect_setequal(unique(scenarios$NPersons), c(41L, 49L, 53L))
  expect_true(all(scenarios$MissingAssignmentRate >= 0.5))
  expect_gt(max(scenarios$RaterLoadRatio), 4)
  expect_identical(sum(scenarios$CoordinatesPerPoint) * 4L, 888L)
  expect_identical(sum(scenarios$JacobianRowsPerPoint) * 4L, 688L)
  expect_false(any(scenarios$FitOpened))
  expect_false(any(scenarios$ResultOpened))
  expect_false(any(scenarios$ConfirmationExecutionAuthorized))
})

test_that("v4 confirmation identities are disjoint from opened lineages", {
  overlap <- v4_confirmation_design_env$mfrmr_gsv4c_prior_identity_overlap()
  expect_true(all(unlist(overlap, use.names = FALSE) == 0L))
  expect_false(any(
    v4_confirmation_design_env$mfrmr_gsv4c_expected_fixture_hashes %in%
      v4_confirmation_design_env$mfrmr_gsv4c_prior_fixture_hashes
  ))
})

test_that("v4 confirmation design seals denominators but not execution", {
  decision <- v4_confirmation_design_env$mfrmr_gsv4c_design_decision()
  expect_identical(
    decision$Status,
    "v4_confirmation_design_sealed_execution_not_authorized"
  )
  expect_identical(decision$ExpectedEvidenceRows, 96L)
  expect_identical(decision$ExpectedCoordinateRows, 888L)
  expect_identical(decision$ExpectedPointRows, 24L)
  expect_identical(decision$ExpectedJacobianRows, 688L)
  expect_false(decision$PriorFixtureIdentityOverlap)
  expect_false(decision$CalibrationDataReused)
  expect_false(decision$ResultOpened)
  expect_false(decision$RuleChangedAfterFreeze)
  expect_true(decision$FutureExecutionMustRecordAbsoluteTarget)
  expect_false(decision$ConfirmationExecutionAuthorized)
  expect_false(decision$GeneralNUMSCORETOLFrozen)
  expect_false(decision$InferenceAuthorized)

  text <- paste(readLines(v4_confirmation_design_path, warn = FALSE),
                collapse = "\n")
  expect_false(grepl("fit_mfrm\\s*\\(", text, perl = TRUE))
})
