gtheory_v4_contract_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-package-capability-contract-v4-0.2.4.R"
  )
}

load_gtheory_v4_contract <- local({
  environment <- NULL
  function() {
    path <- gtheory_v4_contract_path()
    skip_if_not(file.exists(path), "repository-internal v4 contract excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      sys.source(path, envir = environment)
    }
    environment
  }
})

test_that("D-SIM-0 v4 assigns responsibility at package scale", {
  env <- load_gtheory_v4_contract()
  contract <- env$mfrmr_gtds_v4_contract()
  expect_invisible(env$mfrmr_gtds_v4_validate_contract(contract))
  expect_s3_class(contract, "mfrmr_gtds_v4_contract")
  expect_false(contract$OperationalOwnerGateRequired)
  expect_false(contract$UserDecisionContextPartOfPackageContract)
  package_rows <- contract$Responsibilities$AccountableLayer == "mfrmr_package"
  user_rows <- contract$Responsibilities$AccountableLayer == "package_user"
  expect_true(all(contract$Responsibilities$BlocksPackageDsim0[package_rows]))
  expect_true(all(!contract$Responsibilities$BlocksPackageDsim0[user_rows]))
  expect_true(all(
    !contract$Responsibilities$OperationalOwnerEvidenceRequired
  ))
})

test_that("both G and Phi are mandatory nonvoting validation estimands", {
  env <- load_gtheory_v4_contract()
  estimands <- env$mfrmr_gtds_v4_contract()$Estimands
  expect_identical(estimands$EstimandId, c("ABS-PHI", "REL-G"))
  expect_true(all(estimands$IncludedInValidationMultiverse))
  expect_true(all(estimands$UserSelectsSubstantiveInterpretation))
  expect_true(all(!estimands$UniversalTargetSuppliedByPackage))
  expect_true(all(!estimands$CrossEstimandPoolingAllowed))
  expect_true(all(!estimands$CrossEstimandVotingAllowed))
})

test_that("v4 freezes a broad nonadaptive design multiverse", {
  env <- load_gtheory_v4_contract()
  axes <- env$mfrmr_gtds_v4_contract()$MultiverseAxes
  expect_gte(length(unique(axes$AxisId)), 14L)
  expect_true(all(c(
    "condition_sharing", "observation_event", "crossing", "balance",
    "missingness", "variance_regime", "cross_stratum_covariance",
    "response_distribution", "analysis_route"
  ) %in% axes$AxisId))
  expect_true(all(!axes$OutcomeAdaptiveSelectionAllowed))
  expect_true(any(axes$CoverageRole == "boundary"))
  expect_true(any(axes$CoverageRole == "negative_control"))
})

test_that("v4 completes specification without opening simulation or support", {
  env <- load_gtheory_v4_contract()
  result <- env$mfrmr_gtds_v4_adjudicate()
  expect_s3_class(result, "mfrmr_gtds_v4_adjudication")
  expect_identical(
    result$Summary$GateStatus,
    "dsim0_package_scope_complete_dsim1_allowed"
  )
  expect_identical(result$Summary$IncludedEstimandCount, 2L)
  expect_true(result$Summary$Dsim0Satisfied)
  expect_true(result$Summary$Dsim1Allowed)
  expect_false(result$Summary$OperationalOwnerGateRequired)
  expect_false(result$Summary$ExploratorySimulationAllowed)
  expect_false(result$Summary$ConfirmationSimulationAllowed)
  expect_false(result$Summary$PlannedSeedAccessAllowed)
  expect_false(result$Summary$PublicSupportReady)
})

test_that("v4 rejects mutated scope and self-promotion", {
  env <- load_gtheory_v4_contract()
  changed <- env$mfrmr_gtds_v4_contract()
  changed$Estimands$IncludedInValidationMultiverse[[2L]] <- FALSE
  expect_error(
    env$mfrmr_gtds_v4_validate_contract(changed), "contract is invalid"
  )
  promoted <- env$mfrmr_gtds_v4_contract()
  promoted$PublicSupportReady <- TRUE
  expect_error(
    env$mfrmr_gtds_v4_validate_contract(promoted), "contract is invalid"
  )
})
