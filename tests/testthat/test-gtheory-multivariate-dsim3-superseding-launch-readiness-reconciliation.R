gtheory_dsim3z_paths <- function() {
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
    ),
    paste0(
      "gtheory-multivariate-dsim3-superseding-launch-readiness-",
      "reconciliation-0.2.4.R"
    )
  ))
}

gtheory_dsim3z_worker_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-dsim3-resource-probe-worker-0.2.4.R"
  )
}

load_gtheory_dsim3z <- local({
  environment <- NULL
  function() {
    paths <- c(gtheory_dsim3z_paths(), gtheory_dsim3z_worker_path())
    skip_if_not(
      all(file.exists(paths)),
      "repository-internal superseding D-SIM-3 reconciliation excluded"
    )
    for (package in c("digest", "lme4", "processx")) {
      skip_if_not_installed(package)
    }
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in gtheory_dsim3z_paths()) {
        sys.source(path, envir = environment)
      }
    }
    environment
  }
})

gtheory_dsim3z_bundle <- local({
  bundle <- NULL
  function(environment) {
    if (is.null(bundle)) {
      request <- environment$mfrmr_gtds3x_manifest()
      worker <- environment$mfrmr_gtds3w_manifest(
        request_manifest = request
      )
      resource <- environment$mfrmr_gtds3u_manifest(
        gtheory_dsim3z_worker_path()
      )
      orchestrator <- environment$mfrmr_gtds3y_manifest(
        gtheory_dsim3z_worker_path(),
        request_manifest = request,
        worker_manifest = worker,
        resource_manifest = resource
      )
      reconciliation <- environment$mfrmr_gtds3z_manifest(
        request, worker, orchestrator, gtheory_dsim3z_worker_path()
      )
      bundle <<- list(
        Request = request, Worker = worker, Resource = resource,
        Orchestrator = orchestrator, Reconciliation = reconciliation
      )
    }
    bundle
  }
})

test_that("superseding reconciliation contract uses a technical boundary", {
  env <- load_gtheory_dsim3z()
  contract <- env$mfrmr_gtds3z_contract()
  expect_invisible(env$mfrmr_gtds3z_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "6fc33596020b3ad9b6e0ee9bb60f88abd822999809eec1e0c0a9a76e06ef3d01"
  )
  expect_true(contract$PlannedSeedGenerationAdapterRequired)
  expect_false(contract$IntegratedWorkloadCapacityQualificationRequired)
  expect_false(contract$RequestCompilationConfersExecutionAuthority)
  expect_false(contract$ShadowQualificationConfersPlannedReceipt)
  expect_false(contract$PartialLaunchAllowed)
  expect_false(contract$ReconciliationMayUseRng)
})

test_that("exact environment and all request identities reconcile", {
  env <- load_gtheory_dsim3z()
  set.seed(240831L)
  caller_state <- .Random.seed
  manifest <- gtheory_dsim3z_bundle(env)$Reconciliation
  expect_identical(.Random.seed, caller_state)
  expect_invisible(env$mfrmr_gtds3z_assert_manifest(
    manifest, gtheory_dsim3z_worker_path()
  ))
  expect_identical(
    manifest$ManifestHash,
    "b3b5404b2b262941046cfa7a85866a1b7432f3e5a87cb759f3b61a6a345c90b9"
  )
  expect_true(all(manifest$EnvironmentIdentityRegistry$ExactIdentityMatch))
  coverage <- manifest$RequestCoverageRegistry
  expect_identical(coverage$ExpectedRequestCount,
                   c(42L, 50L, 100L, 92L, 5L))
  expect_identical(coverage$IdentityBoundRequestCount,
                   coverage$ExpectedRequestCount)
  expect_identical(coverage$ShadowImplementationQualifiedCount,
                   coverage$ExpectedRequestCount)
  expect_false(any(coverage$ExecutionAuthorized))
})

test_that("planned 856 seeds expose the one remaining executable gap", {
  env <- load_gtheory_dsim3z()
  manifest <- gtheory_dsim3z_bundle(env)$Reconciliation
  generation <- manifest$GenerationAdapterRegistry
  expect_identical(nrow(generation), 42L)
  expect_identical(range(generation$DataSeed),
                   c(856001001L, 856021002L))
  expect_true(all(generation$RequestIdentityBound))
  expect_true(all(generation$ProfileSemanticsShadowQualified))
  expect_true(all(generation$CurrentGenerationOperation ==
                    "qualified_shadow_generator"))
  expect_false(any(generation$PlannedSeedWithinCurrentGeneratorGuard))
  expect_true(all(generation$PlannedSeedRejectedByCurrentGeneratorGuard))
  expect_false(any(generation$PlannedSeedGenerationAdapterBound))
  expect_false(any(generation$ExecutionAttempted))
  expect_false(any(generation$RngStreamOpened))
  expect_false(any(generation$ResponseGenerated))
})

test_that("reconciliation is complete but technical launch stays closed", {
  env <- load_gtheory_dsim3z()
  manifest <- gtheory_dsim3z_bundle(env)$Reconciliation
  gates <- manifest$ReadinessGateRegistry
  summary <- manifest$Summary
  expect_identical(gates$GatePassed, c(rep(TRUE, 9L), FALSE))
  expect_identical(sum(gates$Blocking), 1L)
  expect_identical(gates$GateId[[10L]],
                   "planned_seed_generation_adapter")
  expect_true(summary$ReconciliationComplete)
  expect_false(summary$TechnicalLaunchReady)
  expect_identical(
    summary$CurrentDisposition,
    "no_go_planned_generation_adapter_missing"
  )
  expect_false(summary$IntegratedWorkloadCapacityQualified)
  expect_false(summary$IntegratedWorkloadCapacityRequiredForExploratoryLaunch)
  expect_false(summary$Planned856RngStreamOpened)
  expect_false(summary$ExploratoryResponseGenerated)
  expect_false(summary$RecoveryEvidenceComputed)
  expect_false(summary$PublicSupportReady)
})

test_that("superseding reconciliation rejects readiness promotion", {
  env <- load_gtheory_dsim3z()
  manifest <- gtheory_dsim3z_bundle(env)$Reconciliation
  changed <- manifest
  changed$Summary$TechnicalLaunchReady <- TRUE
  expect_error(
    env$mfrmr_gtds3z_assert_manifest(
      changed, gtheory_dsim3z_worker_path()
    ),
    "reconciliation evidence was altered"
  )
  changed <- manifest
  changed$GenerationAdapterRegistry$
    PlannedSeedGenerationAdapterBound[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtds3z_assert_manifest(
      changed, gtheory_dsim3z_worker_path()
    ),
    "reconciliation evidence was altered"
  )
})
