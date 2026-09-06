gtheory_dsim3ab_paths <- function() {
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
    paste0(
      "gtheory-multivariate-dsim3-planned-seed-generation-adapter-",
      "0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-fit-metric-worker-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-final-launch-readiness-",
      "reconciliation-0.2.4.R"
    )
  ))
}

gtheory_dsim3ab_evidence_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  file.path(validation, c(
    generator =
      "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R",
    prior_source = paste0(
      "gtheory-multivariate-dsim3-superseding-launch-readiness-",
      "reconciliation-0.2.4.R"
    ),
    prior_record = paste0(
      "gtheory-multivariate-dsim3-superseding-launch-readiness-",
      "reconciliation-record-0.2.4.md"
    ),
    adapter_source = paste0(
      "gtheory-multivariate-dsim3-planned-seed-generation-adapter-",
      "0.2.4.R"
    ),
    adapter_record = paste0(
      "gtheory-multivariate-dsim3-planned-seed-generation-adapter-",
      "record-0.2.4.md"
    )
  ))
}

load_gtheory_dsim3ab <- local({
  environment <- NULL
  function() {
    paths <- c(gtheory_dsim3ab_paths(),
               gtheory_dsim3ab_evidence_paths())
    skip_if_not(
      all(file.exists(paths)),
      "repository-internal final D-SIM-3 reconciliation excluded"
    )
    for (package in c("digest", "lme4", "processx")) {
      skip_if_not_installed(package)
    }
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in gtheory_dsim3ab_paths()) {
        sys.source(path, envir = environment, keep.source = FALSE)
      }
    }
    environment
  }
})

gtheory_dsim3ab_bundle <- local({
  bundle <- NULL
  function(environment) {
    if (is.null(bundle)) {
      paths <- gtheory_dsim3ab_evidence_paths()
      request <- environment$mfrmr_gtds3x_manifest()
      generator <- environment$mfrmr_gtds3g_manifest()
      adapter <- environment$mfrmr_gtds3aa_manifest(
        paths[["generator"]], request_manifest = request,
        generator_manifest = generator
      )
      readiness <- environment$mfrmr_gtds3ab_manifest(
        adapter, paths[["generator"]], paths[["prior_source"]],
        paths[["prior_record"]], paths[["adapter_source"]],
        paths[["adapter_record"]]
      )
      bundle <<- list(
        Request = request, Generator = generator, Adapter = adapter,
        Readiness = readiness
      )
    }
    bundle
  }
})

test_that("final reconciliation contract separates readiness from execution", {
  env <- load_gtheory_dsim3ab()
  contract <- env$mfrmr_gtds3ab_contract()
  expect_invisible(env$mfrmr_gtds3ab_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "5ddc86af39a8681c97fa916fbd7fc66e45dcb0278cad1d3248f1f1657c824419"
  )
  expect_true(contract$StaticReconciliationMayDeclareTechnicalReadiness)
  expect_true(contract$ReadinessManifestMayAuthorizeLaterExploratoryExecution)
  expect_false(contract$ReconciliationMayAuthorizeItself)
  expect_false(contract$ReconciliationMayUseRng)
  expect_false(contract$IntegratedWorkloadCapacityQualificationRequired)
  expect_false(contract$RecoveryClaimAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
})

test_that("final readiness implementation identity ignores source references", {
  env <- load_gtheory_dsim3ab()
  original <- body(env$mfrmr_gtds3ab_gate_registry)
  tagged <- original
  attr(tagged, "srcref") <- list(1L, 2L, 3L)
  expect_identical(
    env$mfrmr_gtds3ab_canonical_code(original),
    env$mfrmr_gtds3ab_canonical_code(tagged)
  )
  expect_identical(
    nrow(env$mfrmr_gtds3ab_implementation_identity()), 15L
  )
})

test_that("all ten launch-readiness gates reconcile without opening 856", {
  env <- load_gtheory_dsim3ab()
  paths <- gtheory_dsim3ab_evidence_paths()
  set.seed(240831L)
  caller_state <- .Random.seed
  bundle <- gtheory_dsim3ab_bundle(env)
  manifest <- bundle$Readiness
  expect_identical(.Random.seed, caller_state)
  expect_invisible(env$mfrmr_gtds3ab_assert_manifest(
    manifest, bundle$Adapter, paths[["generator"]],
    paths[["prior_source"]], paths[["prior_record"]],
    paths[["adapter_source"]], paths[["adapter_record"]]
  ))
  expect_identical(
    manifest$ManifestHash,
    "3e3106fa3550c83696235b95b4e9e2ea30b512d5e6c670f39eeb30e6aee82a81"
  )
  expect_identical(nrow(manifest$ArtifactIdentityRegistry), 5L)
  expect_true(all(manifest$ArtifactIdentityRegistry$ArtifactQualified))
  expect_identical(nrow(manifest$EnvironmentIdentityRegistry), 8L)
  expect_true(all(manifest$EnvironmentIdentityRegistry$ExactIdentityMatch))
  expect_identical(nrow(manifest$LaunchReadinessGateRegistry), 10L)
  expect_true(all(manifest$LaunchReadinessGateRegistry$GatePassed))
  expect_false(any(manifest$LaunchReadinessGateRegistry$Blocking))
  expect_false(any(manifest$LaunchReadinessGateRegistry$ExecutionAttempted))
})

test_that("technical readiness covers exact requests but claims no results", {
  env <- load_gtheory_dsim3ab()
  bundle <- gtheory_dsim3ab_bundle(env)
  manifest <- bundle$Readiness
  coverage <- manifest$RequestCoverageRegistry
  summary <- manifest$Summary
  expect_identical(coverage$ExpectedRequestCount,
                   c(42L, 50L, 100L, 92L, 5L))
  expect_identical(coverage$IdentityBoundRequestCount,
                   coverage$ExpectedRequestCount)
  expect_true(all(coverage$PlannedExecutionPathReady))
  expect_false(any(coverage$ExecutionAttempted))
  expect_true(summary$ReconciliationComplete)
  expect_true(summary$TechnicalLaunchReady)
  expect_true(summary$PlannedSeedGenerationAdapterQualified)
  expect_false(summary$ExploratoryLaunchExecuted)
  expect_false(summary$IntegratedWorkloadCapacityQualified)
  expect_false(summary$IntegratedWorkloadCapacityRequiredForExploratoryLaunch)
  expect_false(summary$Planned856RngStreamOpened)
  expect_false(summary$ExploratoryResponseGenerated)
  expect_false(summary$ExploratoryBackendCallMade)
  expect_false(summary$ExploratoryFitReturned)
  expect_false(summary$ExploratoryMetricComputed)
  expect_false(summary$PlannedTerminalReceiptIssued)
  expect_false(summary$RecoveryEvidenceComputed)
  expect_false(summary$SimulationValidationReady)
  expect_false(summary$PublicSupportReady)
  expect_identical(
    summary$CurrentDisposition,
    "internal_exploratory_launch_ready_unopened"
  )
})

test_that("adapter accepts final readiness without executing a request", {
  env <- load_gtheory_dsim3ab()
  bundle <- gtheory_dsim3ab_bundle(env)
  set.seed(240831L)
  caller_state <- .Random.seed
  expect_invisible(env$mfrmr_gtds3aa_validate_readiness_manifest(
    bundle$Readiness, bundle$Adapter
  ))
  expect_identical(.Random.seed, caller_state)
  expect_false(bundle$Readiness$Summary$Planned856RngStreamOpened)
})

test_that("final reconciliation rejects promotion and artifact tampering", {
  env <- load_gtheory_dsim3ab()
  paths <- gtheory_dsim3ab_evidence_paths()
  bundle <- gtheory_dsim3ab_bundle(env)
  changed <- bundle$Readiness
  changed$Summary$ExploratoryLaunchExecuted <- TRUE
  expect_error(
    env$mfrmr_gtds3ab_assert_manifest(
      changed, bundle$Adapter, paths[["generator"]],
      paths[["prior_source"]], paths[["prior_record"]],
      paths[["adapter_source"]], paths[["adapter_record"]]
    ),
    "readiness evidence was altered"
  )
  changed <- bundle$Readiness
  changed$ArtifactIdentityRegistry$ArtifactQualified[[1L]] <- FALSE
  expect_error(
    env$mfrmr_gtds3ab_assert_manifest(
      changed, bundle$Adapter, paths[["generator"]],
      paths[["prior_source"]], paths[["prior_record"]],
      paths[["adapter_source"]], paths[["adapter_record"]]
    ),
    "readiness evidence was altered"
  )
})
