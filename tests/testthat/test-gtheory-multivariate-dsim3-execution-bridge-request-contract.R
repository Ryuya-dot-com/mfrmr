gtheory_dsim3x_paths <- function() {
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
    )
  ))
}

load_gtheory_dsim3x <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3x_paths()
    skip_if_not(
      all(file.exists(paths)),
      "repository-internal D-SIM-3 execution-bridge requests excluded"
    )
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3x_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) {
      manifest <<- environment$mfrmr_gtds3x_manifest()
    }
    manifest
  }
})

test_that("execution-bridge semantics freeze nonpooled stratum outputs", {
  env <- load_gtheory_dsim3x()
  contract <- env$mfrmr_gtds3x_contract()
  expect_invisible(env$mfrmr_gtds3x_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "c37fbedb03f0535d2e8aab1380949385ba10b0fc32b205f77df17074d52fd67e"
  )
  routes <- contract$RouteSemanticsRegistry
  expect_identical(
    routes$RouteId,
    c("multivariate_lme4_restricted", "separate_univariate")
  )
  expect_true(all(routes$MetricOutputShape ==
                    "named_per_stratum_G_Phi_vectors"))
  expect_true(all(routes$AllRegisteredStrataRequired))
  expect_true(all(!routes$ScalarPoolingAcrossStrataAllowed))
  expect_true(all(!routes$DecisionWeightVectorDefined))
  expect_identical(routes$CrossStratumCovarianceFitted, c(TRUE, FALSE))
  expect_true(all(!routes$CrossStratumCovarianceUsedInCoefficient))
  expect_true(all(routes$MarginalComponentDiagonalUsed))
  expect_false(contract$RequestExecutionAuthorizationAllowed)
  expect_false(contract$Planned856RngStreamAccessAllowed)
})

test_that("all exact requests are identity-bound without execution", {
  env <- load_gtheory_dsim3x()
  set.seed(240831L)
  caller_state <- .Random.seed
  manifest <- gtheory_dsim3x_manifest(env)
  expect_identical(.Random.seed, caller_state)
  expect_invisible(env$mfrmr_gtds3x_assert_manifest(manifest))
  expect_identical(
    manifest$ManifestHash,
    "69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef"
  )
  summary <- manifest$Summary
  expect_identical(
    unname(unlist(summary[c(
      "ScenarioCount", "GenerationRequestCount", "BackendRequestCount",
      "MetricRequestCount", "TerminalOrchestrationRequestCount",
      "ResourceBindingCount", "ExactRequestCount"
    )])),
    c(21L, 42L, 50L, 100L, 92L, 5L, 289L)
  )
  expect_identical(summary$RestrictedMultivariateRequestCount, 8L)
  expect_identical(summary$SeparateUnivariateRequestCount, 42L)
  expect_identical(summary$PassingReadinessGateCount, 8L)
  expect_identical(summary$BlockingReadinessGateCount, 2L)
  expect_true(all(!manifest$GenerationRequestRegistry$RngStreamOpened))
  expect_true(all(!manifest$GenerationRequestRegistry$ResponseGenerated))
  expect_true(all(!manifest$BackendRequestRegistry$BackendCallMade))
  expect_true(all(!manifest$BackendRequestRegistry$FitReturned))
  expect_true(all(!manifest$MetricRequestRegistry$MetricComputed))
  expect_true(all(!manifest$TerminalOrchestrationRequestRegistry$
                  TerminalReceiptIssued))
  expect_true(all(!manifest$ResourceBindingRegistry$
                  QualifiedForSupersedingIdentity))
})

test_that("request identities reject tampering and historical inheritance", {
  env <- load_gtheory_dsim3x()
  manifest <- gtheory_dsim3x_manifest(env)
  expect_true(all(!manifest$TerminalOrchestrationRequestRegistry$
                  HistoricalReceiptInherited))
  expect_true(all(!manifest$ResourceBindingRegistry$MechanicsReceiptInherited))
  expect_true(all(!manifest$ReadinessGateRegistry$Blocking |
                    !manifest$ReadinessGateRegistry$GatePassed))
  changed <- manifest
  changed$GenerationRequestRegistry$DataSeed[[1L]] <- 855001001L
  expect_error(
    env$mfrmr_gtds3x_assert_manifest(changed),
    "requests or boundary were altered"
  )
  changed <- manifest
  changed$Contract$ScalarPoolingAcrossStrataAllowed <- TRUE
  expect_error(
    env$mfrmr_gtds3x_assert_manifest(changed),
    "requests or boundary were altered"
  )
})
