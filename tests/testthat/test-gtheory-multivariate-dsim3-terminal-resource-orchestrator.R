gtheory_dsim3y_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  file.path(validation, c(
    "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
    "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
    "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
    "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
    "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
    "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R",
    "gtheory-multivariate-dsim3-covariance-distribution-binding-0.2.4.R",
    "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R",
    "gtheory-multivariate-dsim3-route-receipt-adapter-0.2.4.R",
    "gtheory-multivariate-dsim3-resource-controller-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-semantics-audit-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-design-dependent-truth-projection-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-incidence-allocation-operator-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-truth-",
      "coefficient-0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-superseding-unopened-plan-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-execution-bridge-request-contract-",
      "0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-fit-metric-worker-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-terminal-resource-orchestrator-",
      "0.2.4.R"
    )
  ))
}

gtheory_dsim3y_worker_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-dsim3-resource-probe-worker-0.2.4.R"
  )
}

load_gtheory_dsim3y <- local({
  environment <- NULL
  function() {
    paths <- c(gtheory_dsim3y_paths(), gtheory_dsim3y_worker_path())
    skip_if_not(
      all(file.exists(paths)),
      "repository-internal D-SIM-3 terminal/resource orchestrator excluded"
    )
    skip_if_not_installed("digest")
    skip_if_not_installed("lme4")
    skip_if_not_installed("processx")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in gtheory_dsim3y_paths()) {
        sys.source(path, envir = environment)
      }
    }
    environment
  }
})

gtheory_dsim3y_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) {
      manifest <<- environment$mfrmr_gtds3y_manifest(
        gtheory_dsim3y_worker_path()
      )
    }
    manifest
  }
})

test_that("terminal/resource contract preserves the unopened boundary", {
  env <- load_gtheory_dsim3y()
  contract <- env$mfrmr_gtds3y_contract()
  expect_invisible(env$mfrmr_gtds3y_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "5582fa0069d8760fffb5000bb20ffe972f135c22dce5e17e2eaf105bbd365ec4"
  )
  expect_identical(contract$ExpectedTemplateSuccessReceiptCount, 25L)
  expect_identical(contract$ExpectedFaultProbeCount, 4L)
  expect_identical(contract$ExpectedTerminalStateRebindingCount, 13L)
  expect_identical(contract$ExpectedExactTerminalRequestCoverageCount, 92L)
  expect_identical(contract$ExpectedResourceRebindingCount, 5L)
  expect_false(contract$QualificationReceiptsCountIn856Denominator)
  expect_false(contract$PlannedTerminalReceiptIssuanceAllowed)
  expect_false(contract$IntegratedWorkloadCapacityClaimAllowed)
  expect_false(contract$UnlaunchedUnitTerminalReceiptAllowed)
  expect_false(contract$UnlaunchedUnitFailureImputationAllowed)
  expect_false(contract$ReplacementLaunchAllowed)
  expect_false(contract$Planned856RngStreamMayOpen)
})

test_that("success faults terminals and resources qualify exactly", {
  env <- load_gtheory_dsim3y()
  set.seed(240831L)
  caller_state <- .Random.seed
  manifest <- gtheory_dsim3y_manifest(env)
  expect_identical(.Random.seed, caller_state)
  expect_invisible(env$mfrmr_gtds3y_assert_manifest(
    manifest, gtheory_dsim3y_worker_path()
  ))
  expect_identical(
    manifest$ManifestHash,
    "bffb82e3155bf12597b686f47c7762cdce802c1ac4666c1c4572f2cb1f25c724"
  )
  summary <- manifest$Summary
  expect_identical(
    unname(unlist(summary[c(
      "TemplateSuccessReceiptCount",
      "QualifiedTemplateSuccessReceiptCount", "SingularFitCountRetained",
      "FaultProbeCount", "QualifiedFaultProbeCount",
      "TerminalStateRebindingCount",
      "QualifiedTerminalStateRebindingCount",
      "ObservedTerminalStateRebindingCount",
      "ExactTerminalRequestCoverageCount",
      "QualifiedExactTerminalRequestCoverageCount",
      "DatasetTerminalRequestCoverageCount",
      "RouteTerminalRequestCoverageCount", "ResourceRebindingCount",
      "QualifiedResourceRebindingCount",
      "IntegratedWorkloadCapacityQualifiedCount",
      "PassingReadinessGateCount", "BlockingReadinessGateCount"
    )])),
    c(25L, 25L, 12L, 4L, 4L, 13L, 13L, 9L, 92L, 92L,
      42L, 50L, 5L, 5L, 0L, 9L, 1L)
  )
})

test_that("qualification receipts never become planned receipts", {
  env <- load_gtheory_dsim3y()
  manifest <- gtheory_dsim3y_manifest(env)
  success <- manifest$TemplateSuccessReceiptRegistry
  faults <- manifest$FaultProbeRegistry
  expect_true(all(success$QualificationNamespace == "shadow_route_template"))
  expect_true(all(success$TerminalState == "complete_nonpromoting"))
  expect_true(all(success$QualificationReceiptIssued))
  expect_true(all(!success$PlannedTerminalReceiptIssued))
  expect_true(all(!success$CountsIn856Denominator))
  expect_true(all(!success$PromotesSupport))
  expect_identical(
    faults$FaultProbeId,
    c("generation_failure", "not_attempted_generation_dependency",
      "fit_failure", "metric_failure")
  )
  expect_identical(faults$BackendCallMade, c(FALSE, FALSE, TRUE, TRUE))
  expect_identical(faults$FitReturned, c(FALSE, FALSE, FALSE, TRUE))
  expect_true(all(faults$FaultObserved))
  expect_true(all(!faults$MetricComputed))
  expect_true(all(!faults$CountsAsExploratoryAttempt))
})

test_that("all terminal requests and five resource scopes are rebound", {
  env <- load_gtheory_dsim3y()
  manifest <- gtheory_dsim3y_manifest(env)
  states <- manifest$TerminalStateRebindingRegistry
  terminal <- manifest$TerminalRequestCoverageRegistry
  resources <- manifest$ResourceRebindingRegistry
  expect_identical(nrow(states), 13L)
  expect_true(all(states$RebindingQualified))
  expect_true(all(!states$HistoricalReceiptInherited))
  expect_true(all(!states$PlannedTerminalReceiptIssued))
  expect_identical(nrow(terminal), 92L)
  expect_identical(sum(terminal$UnitType == "dataset"), 42L)
  expect_identical(sum(terminal$UnitType == "route"), 50L)
  expect_true(all(terminal$AllAllowedTerminalStatesRebound))
  expect_true(all(terminal$OrchestratorTemplateQualified))
  expect_true(all(!terminal$PlannedTerminalReceiptIssued))
  expect_identical(resources$ScopeId, c(
    "dataset_generation", "one_route_fit", "one_route_metric",
    "one_dataset_pipeline", "complete_exploratory_run"
  ))
  expect_true(all(resources$MechanicsQualified))
  expect_true(all(resources$WorkerOperationBound))
  expect_true(all(!resources$IntegratedWorkloadCapacityQualified))
  expect_true(all(!resources$ExecutionAuthorized))
})

test_that("orchestrator evidence rejects boundary tampering", {
  env <- load_gtheory_dsim3y()
  manifest <- gtheory_dsim3y_manifest(env)
  changed <- manifest
  changed$ResourceRebindingRegistry$
    IntegratedWorkloadCapacityQualified[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtds3y_assert_manifest(
      changed, gtheory_dsim3y_worker_path()
    ),
    "orchestrator evidence was altered"
  )
  changed <- manifest
  changed$Summary$Planned856RngStreamOpened <- TRUE
  expect_error(
    env$mfrmr_gtds3y_assert_manifest(
      changed, gtheory_dsim3y_worker_path()
    ),
    "orchestrator evidence was altered"
  )
})
