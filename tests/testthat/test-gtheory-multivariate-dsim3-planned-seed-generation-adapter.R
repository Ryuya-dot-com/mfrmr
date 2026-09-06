gtheory_dsim3aa_paths <- function() {
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
    )
  ))
}

gtheory_dsim3aa_generator_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R"
  )
}

load_gtheory_dsim3aa <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3aa_paths()
    skip_if_not(
      all(file.exists(paths)),
      "repository-internal D-SIM-3 planned-seed adapter excluded"
    )
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3aa_bundle <- local({
  bundle <- NULL
  function(environment) {
    if (is.null(bundle)) {
      request <- environment$mfrmr_gtds3x_manifest()
      generator <- environment$mfrmr_gtds3g_manifest()
      adapter <- environment$mfrmr_gtds3aa_manifest(
        gtheory_dsim3aa_generator_path(),
        request_manifest = request,
        generator_manifest = generator
      )
      bundle <<- list(
        Request = request, Generator = generator, Adapter = adapter
      )
    }
    bundle
  }
})

test_that("planned-seed adapter contract reuses one stochastic core", {
  env <- load_gtheory_dsim3aa()
  contract <- env$mfrmr_gtds3aa_contract()
  expect_invisible(env$mfrmr_gtds3aa_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "b7f193e567e61b76bc19c2a9d8f559600ba4dd849e3eed57ff0aa08608721ac0"
  )
  expect_identical(
    contract$StochasticCoreFunction, "mfrmr_gtds3g_generate_profile"
  )
  expect_identical(contract$CopiedStochasticCoreFunctionCount, 0L)
  expect_true(contract$CoreReuseRequired)
  expect_true(contract$ExactSeedForwardingRequired)
  expect_false(contract$QualificationMayUsePlannedSeed)
  expect_false(contract$QualificationMayOpen856)
  expect_true(contract$PlannedExecutionRequiresFutureReadinessManifest)
  expect_false(contract$SelfAuthorizationAllowed)
  expect_false(contract$IntegratedWorkloadCapacityQualificationRequired)
})

test_that("42 exact planned requests compile without opening RNG", {
  env <- load_gtheory_dsim3aa()
  set.seed(240831L)
  caller_state <- .Random.seed
  manifest <- gtheory_dsim3aa_bundle(env)$Adapter
  expect_identical(.Random.seed, caller_state)
  expect_invisible(env$mfrmr_gtds3aa_assert_manifest(
    manifest, gtheory_dsim3aa_generator_path()
  ))
  expect_identical(
    manifest$ManifestHash,
    "2e27bdd0f5e8988adf928959607064b5cefd9e80251317837ba4b0fcca09242b"
  )
  dry_run <- manifest$PlannedSeedDryRunRegistry
  expect_identical(nrow(dry_run), 42L)
  expect_identical(range(dry_run$RequestedSeed),
                   c(856001001L, 856021002L))
  expect_identical(dry_run$RequestedSeed, dry_run$ConfiguredCoreSeed)
  expect_true(all(dry_run$RequestIdentityBound))
  expect_true(all(dry_run$PlannedSeedPolicyAccepted))
  expect_true(all(dry_run$ExactSeedForwardingReady))
  expect_true(all(dry_run$DryRunOnly))
  expect_false(any(dry_run$RngStreamOpened))
  expect_false(any(dry_run$ResponseGenerated))
  expect_false(any(dry_run$ExecutionAuthorized))
})

test_that("parameterized core exactly reproduces all shadow fixtures", {
  env <- load_gtheory_dsim3aa()
  manifest <- gtheory_dsim3aa_bundle(env)$Adapter
  equivalence <- manifest$ShadowEquivalenceRegistry
  core <- manifest$CoreReuseRegistry
  expect_identical(nrow(core), 1L)
  expect_true(core$ExistingCoreReused)
  expect_identical(core$CopiedStochasticCoreFunctionCount, 0L)
  expect_true(core$CoreReuseQualified)
  expect_identical(nrow(equivalence), 21L)
  expect_identical(equivalence$QualificationSeed, 854100000L + 1:21)
  expect_true(all(equivalence$GeneratedDataHashEquivalent))
  expect_true(all(equivalence$MissingnessMaskHashEquivalent))
  expect_true(all(equivalence$ExactSeedForwardingObserved))
  expect_true(all(equivalence$CallerRngStateRestored))
  expect_false(any(equivalence$Planned856Identity))
  expect_false(any(equivalence$CountsAsExploratoryAttempt))
})

test_that("planned generator operation is rebound without a capacity claim", {
  env <- load_gtheory_dsim3aa()
  manifest <- gtheory_dsim3aa_bundle(env)$Adapter
  resources <- manifest$ResourceRebindingRegistry
  summary <- manifest$Summary
  expect_identical(resources$ScopeId, c(
    "dataset_generation", "one_route_fit", "one_route_metric",
    "one_dataset_pipeline", "complete_exploratory_run"
  ))
  expect_identical(resources$PlannedSeedAdapterRequiredForScope,
                   c(TRUE, FALSE, FALSE, TRUE, TRUE))
  expect_true(all(resources$PlannedSeedAdapterBound))
  expect_true(all(resources$MechanicsQualified))
  expect_false(any(resources$IntegratedWorkloadCapacityQualified))
  expect_false(any(resources$ExecutionAuthorized))
  expect_identical(summary$PassingQualificationGateCount, 8L)
  expect_identical(summary$BlockingQualificationGateCount, 0L)
  expect_true(summary$PlannedSeedGenerationAdapterShadowQualified)
  expect_true(summary$FinalLaunchReadinessReconciliationRequired)
  expect_false(summary$TechnicalLaunchReady)
  expect_false(summary$Planned856RngStreamOpened)
  expect_false(summary$ExploratoryResponseGenerated)
  expect_false(summary$RecoveryEvidenceComputed)
})

test_that("planned execution fails closed before final reconciliation", {
  env <- load_gtheory_dsim3aa()
  bundle <- gtheory_dsim3aa_bundle(env)
  request_id <- bundle$Request$GenerationRequestRegistry$
    GenerationRequestId[[1L]]
  set.seed(240831L)
  caller_state <- .Random.seed
  expect_error(
    env$mfrmr_gtds3aa_execute_request(
      request_id, bundle$Request, bundle$Adapter,
      readiness_manifest = list(),
      generator_source_path = gtheory_dsim3aa_generator_path()
    ),
    "future 10/10 D-SIM-3 readiness manifest is required"
  )
  expect_identical(.Random.seed, caller_state)
})

test_that("planned-seed adapter evidence rejects promotion tampering", {
  env <- load_gtheory_dsim3aa()
  manifest <- gtheory_dsim3aa_bundle(env)$Adapter
  changed <- manifest
  changed$Summary$TechnicalLaunchReady <- TRUE
  expect_error(
    env$mfrmr_gtds3aa_assert_manifest(
      changed, gtheory_dsim3aa_generator_path()
    ),
    "adapter evidence was altered"
  )
  changed <- manifest
  changed$PlannedSeedDryRunRegistry$RngStreamOpened[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtds3aa_assert_manifest(
      changed, gtheory_dsim3aa_generator_path()
    ),
    "adapter evidence was altered"
  )
})
