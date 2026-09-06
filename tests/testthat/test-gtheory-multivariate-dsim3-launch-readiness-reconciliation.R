gtheory_dsim3l_paths <- function() {
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
      "gtheory-multivariate-dsim3-launch-readiness-reconciliation-",
      "0.2.4.R"
    )
  ))
}

gtheory_dsim3l_root <- function() {
  testthat::test_path("..", "..")
}

load_gtheory_dsim3l <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3l_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 launch audit excluded")
    for (package in c("digest", "processx", "Matrix", "lme4")) {
      skip_if_not_installed(package)
    }
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3l_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) {
      manifest <<- environment$mfrmr_gtds3l_manifest(gtheory_dsim3l_root())
    }
    manifest
  }
})

test_that("launch reconciliation binds the qualified parent evidence", {
  env <- load_gtheory_dsim3l()
  manifest <- gtheory_dsim3l_manifest(env)
  expect_invisible(env$mfrmr_gtds3l_assert_manifest(
    manifest, gtheory_dsim3l_root()
  ))
  expect_identical(
    manifest$Contract$ContractHash,
    "29e2fabfb57bbb7af34f4c080b07a952c765e55220d48b1ce9ea1bfd2c99802a"
  )
  expect_identical(
    manifest$ManifestHash,
    "1bfa0e6ce643582eab73ddf162c811f8f3f892d8bb9d5fb411343c97c02446cc"
  )
  expect_identical(
    manifest$ParentExecutionPlanHash,
    "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7"
  )
  expect_identical(
    manifest$ParentResourceManifestHash,
    "2a752382b94d0eb0b488c1e7b96029f0f6cc786738997e2dc7c27f28c4051f9d"
  )
  expect_true(all(manifest$ParentEvidenceRegistry$EvidenceBound))
  expect_true(manifest$Summary$SharedExecutionSubstrateQualified)
})

test_that("current dependencies do not substitute for an environment freeze", {
  env <- load_gtheory_dsim3l()
  registry <- gtheory_dsim3l_manifest(env)$EnvironmentRegistry
  expect_identical(
    registry$Dependency, c("R", "Matrix", "lme4", "processx", "digest")
  )
  expect_identical(
    registry$DeclarationRole,
    c(
      "Depends", "Imports", "Suggests",
      "undeclared_internal_validation_dependency",
      "undeclared_internal_validation_dependency"
    )
  )
  expect_true(all(registry$CurrentDependencyAvailable))
  expect_false(any(registry$ExactVersionIdentityFrozen))
  expect_false(any(registry$SourceArtifactIdentityFrozen))
  expect_false(any(registry$LaunchEnvironmentReady))
})

test_that("route semantics remain unresolved at the executable boundary", {
  env <- load_gtheory_dsim3l()
  routes <- gtheory_dsim3l_manifest(env)$CandidateRouteReadinessRegistry
  expect_identical(
    routes$RouteId,
    c("multivariate_lme4_restricted", "separate_univariate")
  )
  expect_identical(routes$CandidateRouteUnitCount, c(8L, 42L))
  expect_identical(routes$RequestedBackend, c("lme4", "unresolved"))
  expect_identical(routes$RequestedCriterion, c("REML", "unresolved"))
  expect_identical(routes$BackendCriterionFrozen, c(TRUE, FALSE))
  expect_true(all(routes$SharedDatasetPayloadQualified))
  expect_false(any(routes$ExactBackendRequestCompiled))
  expect_false(any(routes$FitMetricWorkerBound))
  expect_false(any(routes$MetricAdapterBound))
  expect_false(any(routes$RouteFamilyLaunchReady))
})

test_that("all planned execution-request classes remain at zero", {
  env <- load_gtheory_dsim3l()
  manifest <- gtheory_dsim3l_manifest(env)
  requests <- manifest$RequestCoverageRegistry
  expect_identical(
    requests$RequestClass,
    c(
      "planned_dataset_generation", "candidate_route_fit",
      "candidate_route_estimand_metric", "open_unit_terminal_orchestration"
    )
  )
  expect_identical(
    requests$ExpectedRegisteredUnitCount, c(42L, 50L, 100L, 92L)
  )
  expect_identical(requests$IdentityBoundRequestCount, rep(0L, 4L))
  expect_false(any(requests$RequestCoverageReady))
  expect_true(all(requests$CountsInFrozenDenominator))
  expect_false(any(requests$ReplacementAllowed))
  expect_identical(
    manifest$Summary$BackendCriterionFrozenCandidateRouteUnitCount, 8L
  )
})

test_that("reconciliation returns an evidence-bounded no-go", {
  env <- load_gtheory_dsim3l()
  manifest <- gtheory_dsim3l_manifest(env)
  gates <- manifest$ReadinessGateRegistry
  expect_identical(nrow(gates), 10L)
  expect_identical(gates$GatePassed, c(rep(TRUE, 4L), rep(FALSE, 6L)))
  expect_identical(sum(gates$Blocking), 6L)
  expect_true(all(gates$ReconciliationOnly))
  expect_false(any(gates$ExecutionAttempted))
  expect_true(all(manifest$LaunchArtifactGapRegistry$GapOpen))
  expect_false(manifest$Summary$TechnicalLaunchReady)
  expect_identical(
    manifest$Summary$CurrentDisposition,
    "no_go_missing_execution_bridge"
  )
  expect_match(
    manifest$Summary$NextAction,
    "freeze separate-univariate backend and criterion semantics",
    fixed = TRUE
  )
})

test_that("launch audit never opens RNG, backend, fit, or metric", {
  env <- load_gtheory_dsim3l()
  manifest <- gtheory_dsim3l_manifest(env)
  contract <- manifest$Contract
  expect_false(contract$ReconciliationMayUseRng)
  expect_false(contract$ReconciliationMayGenerateResponse)
  expect_false(contract$ReconciliationMayCallBackend)
  expect_false(contract$ReconciliationMayFit)
  expect_false(contract$ReconciliationMayComputeMetric)
  expect_false(contract$ReconciliationMayLaunchProcess)
  expect_false(manifest$Summary$Planned855RngStreamOpened)
  expect_false(manifest$Summary$ExploratoryResponseGenerated)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitReturned)
  expect_false(manifest$Summary$MetricComputed)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})

test_that("launch-readiness manifest mutations fail closed", {
  env <- load_gtheory_dsim3l()
  root <- gtheory_dsim3l_root()
  manifest <- gtheory_dsim3l_manifest(env)
  fields <- env$mfrmr_gtds3l_manifest_fields()
  altered <- manifest
  altered$ReadinessGateRegistry$GatePassed[[5L]] <- TRUE
  expect_error(
    env$mfrmr_gtds3l_assert_manifest(altered, root),
    "manifest was altered"
  )
  altered <- manifest
  altered$CandidateRouteReadinessRegistry$BackendCriterionFrozen[[2L]] <- TRUE
  altered$ManifestHash <- env$mfrmr_gtds3l_hash(altered[fields])
  expect_error(
    env$mfrmr_gtds3l_assert_manifest(altered, root),
    "manifest was altered"
  )
  altered <- manifest
  altered$Summary$TechnicalLaunchReady <- TRUE
  altered$ManifestHash <- env$mfrmr_gtds3l_hash(altered[fields])
  expect_error(
    env$mfrmr_gtds3l_assert_manifest(altered, root),
    "manifest was altered"
  )
  altered <- manifest
  altered$Contract$PartialLaunchAllowed <- TRUE
  altered$Contract$ContractHash <- env$mfrmr_gtds3l_hash(
    altered$Contract[names(altered$Contract) != "ContractHash"]
  )
  altered$ManifestHash <- env$mfrmr_gtds3l_hash(altered[fields])
  expect_error(
    env$mfrmr_gtds3l_assert_manifest(altered, root),
    "manifest was altered"
  )
})
