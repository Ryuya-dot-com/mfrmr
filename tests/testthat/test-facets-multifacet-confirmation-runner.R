facets_mfr_validation_dir <- testthat::test_path(
  "..", "..", "inst", "validation"
)
facets_mfr_paths <- file.path(
  facets_mfr_validation_dir,
  c(
    "facets-multifacet-confirmation-design-0.2.3.R",
    "facets-multifacet-acceptance-rule-0.2.3.R",
    "facets-multifacet-confirmation-runner-0.2.3.R"
  )
)
facets_mfr_env <- new.env(parent = baseenv())
for (path in facets_mfr_paths) sys.source(path, envir = facets_mfr_env)

facets_mfr_complete_fixture <- function() {
  env <- facets_mfr_env
  preflight <- env$mfrmr_facets_mfr_preflight()
  manifest <- preflight$manifest
  manifest$ExecutionStatus <- "completed"
  manifest$ResultOpened <- TRUE
  manifest$FACETSReturnCode <- 0L
  manifest$FACETSReportedConvergenceScoreResidual <- 0.01
  manifest$FACETSReportedConvergenceLogitChange <- 0.0001
  manifest$FACETSConvergenceSpecificationPassed <- TRUE
  manifest$FACETSConvergenceAchieved <- TRUE
  manifest$FACETSFinalIteration <- 25L
  manifest$FACETSFinalElementScoreResidual <- 0.005
  manifest$FACETSFinalElementLogitChange <- 0.00005
  manifest$MfrmrFitReturned <- TRUE
  manifest$MfrmrConvergenceCode <- 0L
  manifest$MfrmrEstimationConverged <- TRUE
  manifest$MfrmrTerminalGradientSupNorm <- 0.00005
  manifest$MfrmrGradientReviewTolerance <- 0.0001
  manifest$ElementCoordinateContractPassed <- TRUE
  manifest$StepCoordinateContractPassed <- TRUE
  manifest$ComparisonEligible <- TRUE
  element <- preflight$expected_elements
  element$MfrmrEstimate <- 0.004
  element$FACETSEstimate <- 0
  element$Difference <- 0.004
  element$AbsoluteDifference <- 0.004
  step <- preflight$expected_steps
  step$MfrmrEstimate <- 0.003
  step$FACETSEstimate <- 0
  step$Difference <- 0.003
  step$AbsoluteDifference <- 0.003
  list(manifest = manifest, element = element, step = step)
}

test_that("semantic preflight fixes all unopened denominators", {
  preflight <- facets_mfr_env$mfrmr_facets_mfr_preflight()

  expect_s3_class(preflight, "mfrmr_facets_mfr_preflight")
  expect_equal(nrow(preflight$manifest), 180L)
  expect_equal(nrow(preflight$expected_elements), 9120L)
  expect_equal(nrow(preflight$expected_steps), 1350L)
  expect_true(all(preflight$manifest$ExecutionStatus == "not_run"))
  expect_true(all(!preflight$manifest$ResultOpened))
  expect_true(all(!preflight$manifest$ComparisonEligible))
  expect_false(preflight$decision$ConfirmationOutcomeOpened)
  expect_false(preflight$decision$ResponseGenerationImplemented)
  expect_false(preflight$decision$ExternalExecutionImplemented)
  expect_false(preflight$decision$FileHashRequired)
  expect_false(preflight$decision$ExecutionAuthorized)
})

test_that("complete synthetic evidence exercises the full semantic contract", {
  fixture <- facets_mfr_complete_fixture()
  review <- facets_mfr_env$mfrmr_facets_mfr_review(
    fixture$manifest, fixture$element, fixture$step
  )

  expect_equal(nrow(review$cases), 180L)
  expect_equal(nrow(review$cells), 6L)
  expect_equal(review$cells$PlannedCases, rep(30L, 6L))
  expect_equal(review$cells$EligibleCases, rep(30L, 6L))
  expect_true(all(review$cells$AllEligibleCoordinatesPassed))
  expect_true(review$decision$AllCasesExecuted)
  expect_true(review$decision$AllCasesEligible)
  expect_true(review$decision$AllCoordinatesWithinTolerance)
  expect_true(review$decision$AllMCSERulesMet)
  expect_true(review$decision$CompleteFixedCoreNumericalContractPassed)
  expect_true(all(review$element_coordinates$AbsoluteDifferenceTolerance ==
                    0.005))
  expect_true(all(review$step_coordinates$FloatingPointComparisonAllowance >
                    0))
  expect_false(review$decision$ExternalProvenanceValidated)
  expect_false(review$decision$ConfirmationClaimAuthorized)
  expect_false(review$decision$ExactEqualityClaimAuthorized)
  expect_false(review$decision$FACETSReplacementClaimAuthorized)
})

test_that("a numerical failure remains visible at coordinate and case levels", {
  fixture <- facets_mfr_complete_fixture()
  fixture$element$MfrmrEstimate[1L] <- 0.006
  fixture$element$Difference[1L] <- 0.006
  fixture$element$AbsoluteDifference[1L] <- 0.006
  review <- facets_mfr_env$mfrmr_facets_mfr_review(
    fixture$manifest, fixture$element, fixture$step
  )

  expect_equal(review$element_coordinates$NumericalAgreementStatus[1L],
               "numeric_fail")
  expect_false(review$cases$ElementNumericalPass[1L])
  expect_false(review$decision$AllCoordinatesWithinTolerance)
  expect_false(review$decision$CompleteFixedCoreNumericalContractPassed)
})

test_that("FACETS nonconvergence stays in the denominator and is not comparable", {
  fixture <- facets_mfr_complete_fixture()
  failed_id <- fixture$manifest$ScenarioId[1L]
  fixture$manifest$ExecutionStatus[1L] <- "convergence_failure"
  fixture$manifest$FACETSConvergenceAchieved[1L] <- FALSE
  fixture$manifest$FACETSFinalElementScoreResidual[1L] <- 0.02
  fixture$manifest$ComparisonEligible[1L] <- FALSE
  fixture$manifest$Error[1L] <- "FACETS final residual exceeded the criterion."
  fixture$element <- fixture$element[
    fixture$element$ScenarioId != failed_id, , drop = FALSE
  ]
  fixture$step <- fixture$step[
    fixture$step$ScenarioId != failed_id, , drop = FALSE
  ]
  review <- facets_mfr_env$mfrmr_facets_mfr_review(
    fixture$manifest, fixture$element, fixture$step
  )

  expect_equal(review$decision$EligibleCases, 179L)
  expect_true(review$decision$AllCasesExecuted)
  expect_false(review$decision$AllCasesEligible)
  expect_false(review$decision$CompleteFixedCoreNumericalContractPassed)
  affected <- review$cells$Model == "RSM" & review$cells$TotalFacets == 3L
  expect_equal(review$cells$EligibleCases[affected], 29L)
  expect_equal(review$cells$ComparisonEligibilityRate[affected], 29 / 30)
})

test_that("manifest eligibility is recomputed rather than trusted", {
  fixture <- facets_mfr_complete_fixture()
  fixture$manifest$MfrmrConvergenceCode[1L] <- 1L
  fixture$manifest$MfrmrEstimationConverged[1L] <- FALSE

  expect_error(
    facets_mfr_env$mfrmr_facets_mfr_review(
      fixture$manifest, fixture$element, fixture$step
    ),
    "does not match the recomputed"
  )

  specification_drift <- facets_mfr_complete_fixture()
  specification_drift$manifest$FACETSReportedConvergenceLogitChange[1L] <-
    0.001
  expect_error(
    facets_mfr_env$mfrmr_facets_mfr_review(
      specification_drift$manifest,
      specification_drift$element,
      specification_drift$step
    ),
    "Supplied convergence flags"
  )

  nonnumeric <- facets_mfr_complete_fixture()
  nonnumeric$manifest$FACETSFinalIteration <-
    as.character(nonnumeric$manifest$FACETSFinalIteration)
  expect_error(
    facets_mfr_env$mfrmr_facets_mfr_review(
      nonnumeric$manifest, nonnumeric$element, nonnumeric$step
    ),
    "invalid status fields"
  )
})

test_that("coordinate identity and arithmetic failures fail closed", {
  fixture <- facets_mfr_complete_fixture()
  missing <- fixture$element[-1L, , drop = FALSE]
  duplicate <- rbind(fixture$step, fixture$step[1L, , drop = FALSE])
  inconsistent <- fixture$element
  inconsistent$AbsoluteDifference[1L] <- 0.002

  expect_error(
    facets_mfr_env$mfrmr_facets_mfr_review(
      fixture$manifest, missing, fixture$step
    ),
    "coordinate identities"
  )
  expect_error(
    facets_mfr_env$mfrmr_facets_mfr_review(
      fixture$manifest, fixture$element, duplicate
    ),
    "coordinate identities"
  )
  expect_error(
    facets_mfr_env$mfrmr_facets_mfr_review(
      fixture$manifest, inconsistent, fixture$step
    ),
    "arithmetic is inconsistent"
  )
})

test_that("semantic runner contains no fit or external execution path", {
  text <- paste(readLines(tail(facets_mfr_paths, 1L), warn = FALSE),
                collapse = "\n")
  isolated <- new.env(parent = baseenv())
  sys.source(tail(facets_mfr_paths, 1L), envir = isolated)

  expect_false(grepl("fit_mfrm\\s*\\(", text, perl = TRUE))
  expect_false(grepl("system2\\s*\\(", text, perl = TRUE))
  expect_false(grepl("set.seed\\s*\\(", text, perl = TRUE))
  expect_false(grepl("digest::|sha256|SHA-256", text, perl = TRUE))
  expect_error(isolated$mfrmr_facets_mfr_preflight(), "support is missing")
})
