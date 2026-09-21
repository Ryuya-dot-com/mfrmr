gtheory_dsim3u_paths <- function() {
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
    "gtheory-multivariate-dsim3-resource-controller-0.2.4.R"
  ))
}

gtheory_dsim3u_worker_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-dsim3-resource-probe-worker-0.2.4.R"
  )
}

load_gtheory_dsim3u <- local({
  environment <- NULL
  function() {
    mfrmr_skip_if_not_gtheory_slow()
    paths <- c(gtheory_dsim3u_paths(), gtheory_dsim3u_worker_path())
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 resource controller excluded")
    skip_if_not_installed("digest")
    skip_if_not_installed("processx")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in gtheory_dsim3u_paths()) {
        sys.source(path, envir = environment)
      }
    }
    environment
  }
})

gtheory_dsim3u_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) {
      manifest <<- environment$mfrmr_gtds3u_manifest(
        gtheory_dsim3u_worker_path()
      )
    }
    manifest
  }
})

test_that("five-scope resource contract is bound and reproducible", {
  env <- load_gtheory_dsim3u()
  manifest <- gtheory_dsim3u_manifest(env)
  contract <- manifest$Contract
  expect_invisible(env$mfrmr_gtds3u_assert_manifest(
    manifest, gtheory_dsim3u_worker_path()
  ))
  expect_identical(
    contract$ContractHash,
    "535ab118a335a66bf0fd264ecc609249dc4e5042ffa1ac64aee1fdc846c94919"
  )
  expect_identical(
    manifest$ManifestHash,
    "2a752382b94d0eb0b488c1e7b96029f0f6cc786738997e2dc7c27f28c4051f9d"
  )
  expect_identical(
    contract$WorkerSHA256,
    "44c2a2eb527b53d220cdb8f2e52c34e89651a005ed475331ddac15a868b0a4d0"
  )
  scopes <- manifest$ResourceScopeQualificationRegistry
  expect_identical(scopes$ScopeId, c(
    "dataset_generation", "one_route_fit", "one_route_metric",
    "one_dataset_pipeline", "complete_exploratory_run"
  ))
  expect_identical(
    scopes$MaximumWallSeconds,
    c(300L, 1200L, 120L, 7200L, 172800L)
  )
  expect_identical(
    scopes$MaximumPeakRssMiB,
    c(2048L, 8192L, 2048L, 8192L, 8192L)
  )
  expect_identical(scopes$MaximumConcurrentWorkers, rep(1L, 5L))
  expect_true(all(scopes$ResourceScopeQualified))
})

test_that("success, wall, and RSS mechanics qualify every scope", {
  env <- load_gtheory_dsim3u()
  manifest <- gtheory_dsim3u_manifest(env)
  probes <- manifest$ProcessProbeRegistry
  expect_identical(nrow(probes), 15L)
  expect_identical(
    unname(table(probes$ProbeKind)),
    rep(5L, 3L)
  )
  expect_true(all(probes$ExpectedOutcome == probes$ObservedOutcome))
  expect_true(all(probes$ProcessStarted))
  expect_true(all(probes$ProcessTerminated))
  expect_true(all(probes$WallMeasurementObserved))
  expect_true(all(probes$PeakRssMeasurementObserved))
  expect_true(all(probes$ProbeQualified))
  expect_true(all(probes$CompletionMarkerObserved[
    probes$ProbeKind == "success"
  ]))
  expect_true(all(probes$LimitSignalSent[
    probes$ProbeKind != "success"
  ]))
  expect_false(any(probes$ExactRuntimeMeasurementsRetained))
  expect_false(any(c(
    "ElapsedMilliseconds", "PeakRssMiB", "Stdout", "Stderr"
  ) %in% names(probes)))
  expect_false(manifest$Summary$ProbeBudgetsAreProductionCapacityClaims)
  expect_true(manifest$Summary$SameControllerPathUsedForProductionLimits)
})

test_that("atomic terminals and composite stops keep distinct semantics", {
  env <- load_gtheory_dsim3u()
  manifest <- gtheory_dsim3u_manifest(env)
  probes <- manifest$ProcessProbeRegistry
  scopes <- manifest$ResourceScopeQualificationRegistry
  atomic <- manifest$Contract$AtomicResourceScopes
  composite_ids <- manifest$Contract$CompositeStopScopes
  expected <- unname(manifest$Contract$AtomicTerminalProjection)
  names(expected) <- names(manifest$Contract$AtomicTerminalProjection)
  observed <- vapply(atomic, function(scope_id) {
    unique(na.omit(probes$ProjectedUnitTerminalState[
      probes$ScopeId == scope_id
    ]))
  }, character(1L))
  expect_identical(observed, expected)
  expect_true(all(scopes$AtomicUnitTerminalProjectionReady[
    scopes$ScopeId %in% atomic
  ]))
  expect_true(all(is.na(scopes$AtomicUnitTerminalProjectionReady[
    scopes$ScopeId %in% composite_ids
  ])))
  composite <- manifest$CompositeStopRegistry
  expect_identical(composite$ScopeId, composite_ids)
  expect_true(all(composite$StopNewLaunches))
  expect_false(any(composite$LaterLaunchAdmitted))
  expect_true(all(composite$AllRegisteredUnitsRetained))
  expect_identical(sum(composite$RegisteredUnitCount), 6L)
  expect_false(any(composite$UnlaunchedUnitTerminalReceiptCreated))
  expect_false(any(composite$UnlaunchedUnitFailureImputed))
  expect_false(any(composite$ReplacementLaunchCreated))
  expect_true(all(composite$CompositeStopQualified))
})

test_that("concurrency is enforced against one live worker", {
  env <- load_gtheory_dsim3u()
  receipt <- gtheory_dsim3u_manifest(env)$ConcurrencyReceipt
  expect_true(receipt$FirstLaunchAdmitted)
  expect_true(receipt$FirstProcessAliveAtSecondAdmission)
  expect_false(receipt$SecondLaunchAdmitted)
  expect_identical(
    receipt$SecondAdmissionReason,
    "maximum_concurrent_workers_reached"
  )
  expect_true(receipt$FirstProcessTerminated)
  expect_true(receipt$ConcurrencyQualified)
})

test_that("resource qualification does not open exploratory execution", {
  env <- load_gtheory_dsim3u()
  manifest <- gtheory_dsim3u_manifest(env)
  expect_true(all(manifest$WorkerStaticAudit$Passed))
  expect_false(any(manifest$ProcessProbeRegistry$CountsIn855Denominator))
  expect_false(any(manifest$ProcessProbeRegistry$Planned855Identity))
  expect_false(manifest$Summary$Planned855RngStreamOpened)
  expect_false(manifest$Summary$ExploratoryResponseGenerated)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitReturned)
  expect_false(manifest$Summary$MetricComputed)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
  expect_identical(manifest$Summary$FeatureMaturity, "specified")
})

test_that("resource manifest mutations fail closed", {
  env <- load_gtheory_dsim3u()
  worker <- gtheory_dsim3u_worker_path()
  manifest <- gtheory_dsim3u_manifest(env)
  fields <- env$mfrmr_gtds3u_manifest_fields()
  altered <- manifest
  altered$ProcessProbeRegistry$ProbeQualified[[1L]] <- FALSE
  expect_error(
    env$mfrmr_gtds3u_assert_manifest(altered, worker),
    "manifest was altered"
  )
  altered <- manifest
  altered$ConcurrencyReceipt$FirstProcessAliveAtSecondAdmission <- FALSE
  altered$ManifestHash <- env$mfrmr_gtds3u_hash(altered[fields])
  expect_error(
    env$mfrmr_gtds3u_assert_manifest(altered, worker),
    "manifest was altered"
  )
  altered <- manifest
  altered$CompositeStopRegistry$UnlaunchedUnitTerminalReceiptCreated[[1L]] <-
    TRUE
  altered$ManifestHash <- env$mfrmr_gtds3u_hash(altered[fields])
  expect_error(
    env$mfrmr_gtds3u_assert_manifest(altered, worker),
    "manifest was altered"
  )
  altered <- manifest
  altered$Contract$ParentResourceRegistryHash <- env$mfrmr_gtds3u_hash(
    "forged-resource-registry"
  )
  altered$Contract$ContractHash <- env$mfrmr_gtds3u_hash(
    altered$Contract[names(altered$Contract) != "ContractHash"]
  )
  altered$ManifestHash <- env$mfrmr_gtds3u_hash(altered[fields])
  expect_error(
    env$mfrmr_gtds3u_assert_manifest(altered, worker),
    "manifest was altered"
  )
})
