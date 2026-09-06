gtheory_dsim3e_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
      "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
      "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
      "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R"
    )
  )
}

load_gtheory_dsim3e <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3e_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 execution artifacts excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3e_plan <- local({
  plan <- NULL
  function(environment) {
    if (is.null(plan)) plan <<- environment$mfrmr_gtds3e_plan()
    plan
  }
})

test_that("D-SIM-3 execution contract is package-scoped and unopened", {
  env <- load_gtheory_dsim3e()
  contract <- env$mfrmr_gtds3e_contract()
  expect_invisible(env$mfrmr_gtds3e_validate_contract(contract))
  expect_s3_class(contract, "mfrmr_gtds3e_contract")
  expect_identical(
    contract$ContractHash,
    "1e26cdf45218c7a28a260e519a376346d99d76a69772382ef5b0787e130f8b85"
  )
  expect_identical(
    contract$ParentCoverageManifestHash,
    "4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197"
  )
  expect_identical(contract$DatasetReplicatesPerScenario, 2L)
  expect_identical(contract$PlannedDatasetAttemptCount, 42L)
  expect_true(contract$ContractFrozen)
  expect_true(contract$ExecutionPlanFreezeAllowed)
  expect_true(contract$PreExecutionQualificationAllowed)
  expect_false(contract$OperationalOwnerAuthorizationRequired)
  expect_false(contract$PackageUserDecisionRequired)
  expect_false(contract$ExternalFreezeReceiptRequired)
  expect_false(contract$SubstantiveTargetRequired)
  expect_false(contract$PartialExecutionAllowed)
  expect_false(contract$ResponseGenerationCurrentlyAllowed)
  expect_false(contract$RngStreamAccessCurrentlyAllowed)
  expect_false(contract$FitExecutionCurrentlyAllowed)
  expect_false(contract$ExploratoryExecutionCurrentlyAllowed)
  expect_false(contract$AccuracyThresholdSelectionAllowed)
  expect_false(contract$SimulationValidationClaimAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
})

test_that("the 855 seed band is disjoint and remains unopened", {
  env <- load_gtheory_dsim3e()
  contract <- env$mfrmr_gtds3e_contract()
  bands <- contract$SeedBandRegistry
  expect_true(all(
    bands$UpperInclusive[-nrow(bands)] < bands$LowerInclusive[-1L]
  ))
  expect_identical(sum(bands$AssignedToCurrentContract), 1L)
  expect_identical(
    bands$BandId[bands$AssignedToCurrentContract],
    "DSIM3-EXPLORATORY-855"
  )
  expect_true(all(!bands$RngStreamOpened))
  expect_false(contract$SeedPolicy$ReplacementSeedAllowed)
  expect_false(contract$SeedPolicy$EarlyStoppingAllowed)
  expect_false(contract$SeedPolicy$RngStreamOpened)

  set.seed(240830L)
  caller_state <- .Random.seed
  plan <- env$mfrmr_gtds3e_plan()
  expect_identical(.Random.seed, caller_state)
  seeds <- plan$DatasetAttemptRegistry$DataSeed
  expect_identical(range(seeds), c(855001001L, 855021002L))
  expect_identical(anyDuplicated(seeds), 0L)
  expect_true(all(seeds >= 855000000L & seeds <= 855999999L))
  expect_identical(
    head(seeds, 4L),
    c(855001001L, 855001002L, 855002001L, 855002002L)
  )
})

test_that("dataset route and estimand denominators remain distinct", {
  env <- load_gtheory_dsim3e()
  plan <- gtheory_dsim3e_plan(env)
  expect_invisible(env$mfrmr_gtds3e_assert_plan(plan))
  expect_s3_class(plan, "mfrmr_gtds3e_plan")
  expect_identical(
    plan$PlanHash,
    "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7"
  )
  expect_identical(nrow(plan$DatasetAttemptRegistry), 42L)
  expect_identical(nrow(plan$RouteUnitRegistry), 210L)
  expect_identical(nrow(plan$DatasetEstimandRegistry), 84L)
  expect_identical(nrow(plan$RouteEstimandCoordinateRegistry), 420L)
  expect_true(all(table(plan$DatasetAttemptRegistry$ScenarioId) == 2L))
  expect_true(all(table(plan$RouteUnitRegistry$DatasetId) == 5L))
  expect_true(all(table(plan$DatasetEstimandRegistry$DatasetId) == 2L))
  expect_true(all(
    table(plan$RouteEstimandCoordinateRegistry$RouteUnitId) == 2L
  ))
  expect_true(all(
    !plan$DatasetEstimandRegistry$CountsAsIndependentDataset
  ))
  expect_true(all(!plan$DatasetEstimandRegistry$CrossEstimandVotingAllowed))
  expect_true(all(
    !plan$RouteEstimandCoordinateRegistry$CountsAsIndependentDataset
  ))
  expect_true(all(
    !plan$RouteEstimandCoordinateRegistry$CrossRouteVotingAllowed
  ))
  expect_true(all(
    !plan$RouteEstimandCoordinateRegistry$CrossEstimandVotingAllowed
  ))
})

test_that("route disposition retains candidate blocked and control units", {
  env <- load_gtheory_dsim3e()
  plan <- gtheory_dsim3e_plan(env)
  disposition <- table(plan$RouteUnitRegistry$PlannedDisposition)
  expect_identical(
    as.integer(disposition[c(
      "qualification_candidate", "negative_control_prefit_reject",
      "frozen_not_applicable", "blocked_unimplemented_contract"
    )]),
    c(50L, 40L, 8L, 112L)
  )
  expect_identical(
    sum(plan$RouteUnitRegistry$BackendCallAllowedAfterQualification), 50L
  )
  expect_identical(
    sum(plan$RouteUnitRegistry$PreExecutionQualificationRequired), 50L
  )
  expect_true(all(plan$RouteUnitRegistry$CountsInRouteDenominator))
  expect_true(all(!plan$RouteUnitRegistry$ExecutionSelected))
  expect_true(all(!plan$RouteUnitRegistry$BackendCallCurrentlyAllowed))
  expect_true(all(!plan$RouteUnitRegistry$FitExecuted))
  expect_true(all(!plan$RouteUnitRegistry$MetricComputed))
  no_call <- plan$RouteUnitRegistry$PlannedDisposition !=
    "qualification_candidate"
  expect_true(all(nzchar(
    plan$RouteUnitRegistry$FrozenNoCallTerminalState[no_call]
  )))
})

test_that("terminal and resource rules preserve every failed unit", {
  env <- load_gtheory_dsim3e()
  contract <- env$mfrmr_gtds3e_contract()
  rules <- contract$DenominatorRuleRegistry
  states <- contract$TerminalStateRegistry
  resources <- contract$ResourceLimitRegistry
  expect_identical(nrow(rules), 14L)
  expect_true(all(rules$CurrentContractSatisfied))
  expect_true(all(!rules$OutcomeAdaptiveRevisionAllowed))
  expect_true(all(states$CountsInRegisteredDenominator))
  expect_true(all(!states$ReplacementAllowed))
  expect_true(all(!states$PromotesSupport))
  expect_false(states$ValidTerminalReceipt[
    states$TerminalState == "unrecorded_invalid"
  ])
  expect_true(all(resources$MaximumWallSeconds > 0L))
  expect_true(all(resources$MaximumPeakRssMiB > 0L))
  expect_true(all(resources$MaximumConcurrentWorkers == 1L))
  expect_true(all(!resources$IsStatisticalAcceptanceThreshold))
  expect_true(all(resources$EnforcementQualificationRequired))
  expect_true(all(!resources$EnforcementCurrentlyReady))
})

test_that("controls are retained without random generation", {
  env <- load_gtheory_dsim3e()
  controls <- gtheory_dsim3e_plan(env)$ControlUnitRegistry
  expect_identical(
    controls$ControlId,
    c("NC-NAIVE-POOLING", "NC-DISCONNECTED-INCIDENCE",
      "NC-INDEFINITE-COVARIANCE")
  )
  expect_true(all(controls$CountsInControlDenominator))
  expect_true(all(!controls$RngStreamRequired))
  expect_true(all(!controls$ExecutionSelected))
  expect_true(all(!controls$ObservedDispositionAvailable))
})

test_that("execution-plan replay is exact and nonpromoting", {
  env <- load_gtheory_dsim3e()
  first <- gtheory_dsim3e_plan(env)
  replay <- env$mfrmr_gtds3e_plan()
  expect_identical(replay$PlanHash, first$PlanHash)
  expect_identical(replay$DatasetAttemptRegistry,
                   first$DatasetAttemptRegistry)
  expect_identical(replay$RouteUnitRegistry, first$RouteUnitRegistry)
  expect_true(first$Summary$ContractFrozen)
  expect_true(first$Summary$ExecutionPlanFrozen)
  expect_true(first$Summary$PreExecutionQualificationAllowed)
  expect_false(first$Summary$ExecutionCurrentlyAllowed)
  expect_false(first$Summary$RngStreamOpened)
  expect_false(first$Summary$ResponseGenerated)
  expect_false(first$Summary$FitExecuted)
  expect_false(first$Summary$ExploratoryResultAvailable)
  expect_false(first$Summary$AccuracyThresholdSelected)
  expect_false(first$Summary$SimulationValidationReady)
  expect_false(first$Summary$ReferenceValidationReady)
  expect_false(first$Summary$InferenceReady)
  expect_false(first$Summary$DecisionReady)
  expect_false(first$Summary$PublicSupportReady)
  expect_identical(first$Summary$FeatureMaturity, "specified")
})

test_that("execution plan rejects denominator seed and readiness mutations", {
  env <- load_gtheory_dsim3e()
  plan <- gtheory_dsim3e_plan(env)
  dropped <- plan
  dropped$RouteUnitRegistry <- dropped$RouteUnitRegistry[-1L, , drop = FALSE]
  dropped$PlanHash <- env$mfrmr_gtds3e_hash(
    dropped[env$mfrmr_gtds3e_payload_fields()]
  )
  expect_error(env$mfrmr_gtds3e_assert_plan(dropped),
               "plan or readiness was altered")

  collided <- plan
  collided$DatasetAttemptRegistry$DataSeed[[1L]] <- 854000001L
  collided$PlanHash <- env$mfrmr_gtds3e_hash(
    collided[env$mfrmr_gtds3e_payload_fields()]
  )
  expect_error(env$mfrmr_gtds3e_assert_plan(collided),
               "plan or readiness was altered")

  promoted <- plan
  promoted$Summary$ExecutionCurrentlyAllowed <- TRUE
  promoted$PlanHash <- env$mfrmr_gtds3e_hash(
    promoted[env$mfrmr_gtds3e_payload_fields()]
  )
  expect_error(env$mfrmr_gtds3e_assert_plan(promoted),
               "plan or readiness was altered")

  changed_contract <- env$mfrmr_gtds3e_contract()
  changed_contract$DatasetReplicatesPerScenario <- 3L
  expect_error(env$mfrmr_gtds3e_validate_contract(changed_contract),
               "invalid or altered")
})

test_that("D-SIM-3 execution symbols stay outside public package surfaces", {
  public_files <- c(
    list.files(testthat::test_path("..", "..", "R"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "man"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "vignettes"),
               recursive = TRUE, full.names = TRUE),
    testthat::test_path("..", "..", "ROADMAP.md")
  )
  public_text <- unlist(lapply(public_files, function(file) {
    if (file.exists(file) && !dir.exists(file) &&
        grepl("\\.(R|Rd|Rmd|md)$", file)) {
      readLines(file, warn = FALSE, encoding = "UTF-8")
    } else character()
  }), use.names = FALSE)
  expect_false(any(grepl(
    "mfrmr_gtds3e_|MFRMR-GTHEORY-MV-DSIM3-EXPLORATORY-EXECUTION",
    public_text
  )))
})
