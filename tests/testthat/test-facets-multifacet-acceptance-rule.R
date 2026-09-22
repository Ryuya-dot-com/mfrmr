facets_mfa_design_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "facets-multifacet-confirmation-design-0.2.3.R"
)
facets_mfa_rule_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "facets-multifacet-acceptance-rule-0.2.3.R"
)
facets_mfa_env <- new.env(parent = baseenv())
sys.source(facets_mfa_design_path, envir = facets_mfa_env)
sys.source(facets_mfa_rule_path, envir = facets_mfa_env)

test_that("FACETS agreement rule covers every frozen comparison cell", {
  env <- facets_mfa_env
  rule <- env$mfrmr_facets_mfa_rule()
  design <- env$mfrmr_facets_mfc_design()
  contract <- env$mfrmr_facets_mfa_contract(design)

  expect_true(env$mfrmr_facets_mfa_validate(rule))
  expect_s3_class(contract, "mfrmr_facets_mfa_contract")
  expect_equal(nrow(rule), 12L)
  expect_equal(sort(unique(rule$Model)), c("PCM", "RSM"))
  expect_equal(sort(unique(rule$TotalFacets)), 3:5)
  expect_equal(sort(unique(rule$ParameterClass)), c("Element", "Step"))
  expect_true(all(rule$AbsoluteDifferenceTolerance == 0.005))
  expect_true(all(rule$FACETSDocumentedPracticalIncrement == 0.01))
  expect_true(all(rule$ToleranceInclusive))
  expect_true(all(rule$CoordinatewisePassRequired))
})

test_that("agreement rule is independent of pilot, confirmation, and hashes", {
  rule <- facets_mfa_env$mfrmr_facets_mfa_rule()
  decision <- facets_mfa_env$mfrmr_facets_mfa_decision()

  expect_true(all(!rule$PilotOutcomeUsedToSetTolerance))
  expect_true(all(!rule$ConfirmationOutcomeOpened))
  expect_true(all(!rule$FileHashRequired))
  expect_true(all(!rule$ByteEqualityRequired))
  expect_true(all(!rule$Binary64EqualityRequired))
  expect_true(all(!rule$DisplayedTokenEqualityRequired))
  expect_false(decision$RuleChosenFromPilotMaximum)
  expect_false(decision$ConfirmationOutcomeOpened)
  expect_false(decision$MCSEIsNumericalAgreementTolerance)
  expect_false(decision$ExactEqualityClaimAuthorized)
  expect_false(decision$StatisticalEquivalenceClaimAuthorized)
  expect_false(decision$FACETSReplacementClaimAuthorized)
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("inclusive boundary uses only a machine-scale comparison allowance", {
  env <- facets_mfa_env
  evidence <- data.frame(
    Model = rep("RSM", 4L),
    TotalFacets = rep(3L, 4L),
    ParameterClass = rep("Element", 4L),
    AbsoluteDifference = c(
      0.0049,
      0.005,
      0.005 + .Machine$double.eps,
      0.005 + 32 * .Machine$double.eps
    ),
    stringsAsFactors = FALSE
  )
  adjudicated <- env$mfrmr_facets_mfa_adjudicate_coordinates(evidence)

  expect_equal(
    adjudicated$NumericalAgreementStatus,
    c("numeric_pass", "numeric_pass", "numeric_pass", "numeric_fail")
  )
  expect_true(all(
    adjudicated$FloatingPointComparisonAllowance < 2e-15
  ))
  expect_true(all(adjudicated$AbsoluteDifferenceTolerance == 0.005))

  scaled <- evidence[4L, , drop = FALSE]
  scaled$ComparisonScale <- 10
  scaled_adjudication <- env$mfrmr_facets_mfa_adjudicate_coordinates(scaled)
  expect_equal(scaled_adjudication$NumericalAgreementStatus, "numeric_pass")
  expect_true(scaled_adjudication$FloatingPointComparisonAllowance >
                adjudicated$FloatingPointComparisonAllowance[4L])
})

test_that("agreement rule fails closed under evidence or contract drift", {
  env <- facets_mfa_env
  mutated <- env$mfrmr_facets_mfa_rule()
  mutated$AbsoluteDifferenceTolerance[1L] <- 0.006
  unknown <- data.frame(
    Model = "GPCM", TotalFacets = 3L, ParameterClass = "Element",
    AbsoluteDifference = 0, stringsAsFactors = FALSE
  )
  invalid <- unknown
  invalid$Model <- "RSM"
  invalid$AbsoluteDifference <- NA_real_
  opened_design <- env$mfrmr_facets_mfc_design()
  opened_design$registry$ResultOpened[1L] <- TRUE

  expect_error(env$mfrmr_facets_mfa_validate(mutated), "semantic contract")
  expect_error(
    env$mfrmr_facets_mfa_adjudicate_coordinates(unknown), "outside the rule"
  )
  expect_error(
    env$mfrmr_facets_mfa_adjudicate_coordinates(invalid),
    "finite non-negative"
  )
  expect_error(
    env$mfrmr_facets_mfa_validate_design(opened_design), "incompatible"
  )
})

test_that("agreement rule is no-fit and does not require cryptographic identity", {
  text <- paste(readLines(facets_mfa_rule_path, warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(", text, perl = TRUE))
  expect_false(grepl("system2\\s*\\(", text, perl = TRUE))
  expect_false(grepl("digest::|sha256|SHA-256", text, perl = TRUE))
  expect_match(
    facets_mfa_env$mfrmr_facets_mfa_decision()$Status,
    "acceptance_rule_frozen_confirmation_execution_still_blocked",
    fixed = TRUE
  )
})
