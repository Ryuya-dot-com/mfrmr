gtheory_dsim3p_paths <- function() {
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
    "gtheory-multivariate-dsim3-superseding-unopened-plan-0.2.4.R"
  ))
}

load_gtheory_dsim3p <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3p_paths()
    skip_if_not(
      all(file.exists(paths)),
      "repository-internal D-SIM-3 superseding plan excluded"
    )
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3p_bundle <- local({
  bundle <- NULL
  function(environment) {
    if (is.null(bundle)) {
      truth <- environment$mfrmr_gtds3t_manifest()
      operator <- environment$mfrmr_gtds3o_manifest(
        truth_manifest = truth
      )
      metric <- environment$mfrmr_gtds3m_manifest(
        truth_manifest = truth, operator_manifest = operator
      )
      old_plan <- environment$mfrmr_gtds3e_plan()
      plan <- environment$mfrmr_gtds3p_plan(
        old_plan = old_plan, truth_manifest = truth,
        operator_manifest = operator, metric_manifest = metric
      )
      bundle <<- list(
        truth = truth, operator = operator, metric = metric,
        old_plan = old_plan, plan = plan
      )
    }
    bundle
  }
})

test_that("superseding contract assigns only a disjoint unopened namespace", {
  env <- load_gtheory_dsim3p()
  contract <- env$mfrmr_gtds3p_contract()
  expect_invisible(env$mfrmr_gtds3p_validate_contract(contract))
  expect_s3_class(contract, "mfrmr_gtds3p_contract")
  expect_identical(
    contract$ContractHash,
    "23469d19faab020974a15d0b874ec1b0dac34eda8d6440d0db198b6452f08297"
  )
  expect_identical(
    contract$SupersededExecutionPlanHash,
    "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7"
  )
  bands <- contract$SeedBandRegistry
  expect_identical(sum(bands$AssignedToCurrentContract), 1L)
  expect_identical(
    bands$BandId[bands$AssignedToCurrentContract],
    "DSIM3-SUPERSEDING-856"
  )
  expect_true(all(!bands$RngStreamOpened))
  expect_false(contract$SupersededPlanMutationAllowed)
  expect_false(contract$SupersededAttemptIdentityReuseAllowed)
  expect_false(contract$SupersededSeedReuseAllowed)
  expect_false(contract$DownstreamQualificationInheritanceAllowed)
  expect_false(contract$RngStreamAccessCurrentlyAllowed)
  expect_false(contract$ExploratoryExecutionCurrentlyAllowed)
})

test_that("qualified truth operator and metric identities bind all profiles", {
  env <- load_gtheory_dsim3p()
  set.seed(240831L)
  caller_state <- .Random.seed
  bundle <- gtheory_dsim3p_bundle(env)
  expect_identical(.Random.seed, caller_state)
  plan <- bundle$plan
  bindings <- plan$ProfileBindingRegistry
  truth <- bundle$truth$ProfileTruthRegistry
  operator <- bundle$operator$ProfileOperatorRegistry
  metric <- bundle$metric$ProfileTruthMetricRegistry
  expect_invisible(env$mfrmr_gtds3p_assert_plan(plan))
  expect_identical(
    plan$PlanHash,
    "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a"
  )
  expect_identical(nrow(bindings), 21L)
  expect_identical(bindings$ScenarioId, truth$ScenarioId)
  expect_identical(bindings$TruthProjectionHash, truth$ProjectionHash)
  expect_identical(
    bindings$ProfileOperatorHash,
    operator$ProfileOperatorHash[match(bindings$ScenarioId,
                                       operator$ScenarioId)]
  )
  expect_identical(
    bindings$ProfileTruthCoefficientHash,
    metric$ProfileTruthCoefficientHash[match(bindings$ScenarioId,
                                             metric$ScenarioId)]
  )
  expect_true(all(bindings$TruthProjectionQualified))
  expect_true(all(bindings$AllocationOperatorQualified))
  expect_true(all(bindings$TruthMetricQualified))
  expect_true(all(!bindings$ResponseInspected))
})

test_that("scientific denominator is one-to-one but attempt identity is new", {
  env <- load_gtheory_dsim3p()
  bundle <- gtheory_dsim3p_bundle(env)
  old <- bundle$old_plan
  plan <- bundle$plan
  maps <- plan$SupersessionRegistry
  expect_identical(old$PlanHash,
                   plan$Contract$SupersededExecutionPlanHash)
  expect_identical(
    unname(vapply(maps, nrow, integer(1L))),
    c(42L, 210L, 84L, 420L, 3L)
  )
  expect_identical(
    maps$DatasetAttempt[c("ScenarioId", "Replicate")],
    plan$DatasetAttemptRegistry[c("ScenarioId", "Replicate")]
  )
  expect_identical(
    maps$RouteUnit[c("ScenarioId", "Replicate", "RouteId",
                     "PlannedDisposition")],
    plan$RouteUnitRegistry[c("ScenarioId", "Replicate", "RouteId",
                             "PlannedDisposition")]
  )
  expect_identical(
    maps$DatasetEstimand[c("ScenarioId", "Replicate", "EstimandId")],
    plan$DatasetEstimandRegistry[c("ScenarioId", "Replicate", "EstimandId")]
  )
  expect_identical(
    maps$RouteEstimandCoordinate[
      c("ScenarioId", "Replicate", "RouteId", "EstimandId")
    ],
    plan$RouteEstimandCoordinateRegistry[
      c("ScenarioId", "Replicate", "RouteId", "EstimandId")
    ]
  )
  expect_length(intersect(
    maps$DatasetAttempt$SupersededDatasetId,
    maps$DatasetAttempt$SupersedingDatasetId
  ), 0L)
  expect_length(intersect(
    maps$DatasetAttempt$SupersededDataSeed,
    maps$DatasetAttempt$SupersedingDataSeed
  ), 0L)
  expect_length(intersect(
    maps$RouteUnit$SupersededRouteUnitId,
    maps$RouteUnit$SupersedingRouteUnitId
  ), 0L)
  expect_length(intersect(
    maps$DatasetEstimand$SupersededDatasetEstimandUnitId,
    maps$DatasetEstimand$SupersedingDatasetEstimandUnitId
  ), 0L)
  expect_length(intersect(
    maps$RouteEstimandCoordinate$SupersededCoordinateId,
    maps$RouteEstimandCoordinate$SupersedingCoordinateId
  ), 0L)
  expect_identical(
    range(plan$DatasetAttemptRegistry$DataSeed),
    c(856001001L, 856021002L)
  )
})

test_that("route-specific applicability does not overclaim qualification", {
  env <- load_gtheory_dsim3p()
  plan <- gtheory_dsim3p_bundle(env)$plan
  routes <- plan$RouteUnitRegistry
  coordinates <- plan$RouteEstimandCoordinateRegistry
  expect_identical(sum(routes$TruthMetricDirectlyApplicable), 42L)
  expect_true(all(
    routes$TruthMetricBindingRole[routes$TruthMetricDirectlyApplicable] ==
      "direct_route_metric_contract"
  ))
  expect_true(all(
    routes$TruthMetricBindingRole[!routes$TruthMetricDirectlyApplicable] ==
      "scenario_reference_not_route_qualified"
  ))
  expect_identical(
    sum(coordinates$DirectTruthMetricBindingRequired), 84L
  )
  expect_true(all(!routes$DownstreamQualificationInherited))
  expect_true(all(!coordinates$DownstreamQualificationInherited))
  expect_true(all(!plan$DownstreamRebindingRegistry$
                  QualifiedForSupersedingIdentity))
})

test_that("the frozen plan remains unopened and rejects identity tampering", {
  env <- load_gtheory_dsim3p()
  plan <- gtheory_dsim3p_bundle(env)$plan
  expect_identical(plan$Summary$PassingReadinessGateCount, 9L)
  expect_identical(plan$Summary$BlockingReadinessGateCount, 1L)
  expect_identical(
    plan$ReadinessGateRegistry$GateId[
      plan$ReadinessGateRegistry$Blocking
    ],
    "shared_execution_bridge_rebound"
  )
  expect_true(all(!plan$DatasetAttemptRegistry$RngStreamOpened))
  expect_true(all(!plan$DatasetAttemptRegistry$ResponseGenerated))
  expect_true(all(!plan$RouteUnitRegistry$FitExecuted))
  expect_true(all(!plan$RouteUnitRegistry$MetricComputed))
  expect_false(plan$Summary$ExploratoryExecutionAllowed)
  expect_false(plan$Summary$SimulationValidationReady)
  expect_false(plan$Summary$PublicSupportReady)

  altered <- plan
  altered$ProfileBindingRegistry$TruthProjectionHash[[1L]] <- "changed"
  expect_error(
    env$mfrmr_gtds3p_assert_plan(altered),
    "superseding unopened plan or boundary was altered",
    fixed = TRUE
  )
  altered <- plan
  altered$RouteUnitRegistry$CoverageRole[[1L]] <- "changed"
  altered$PlanHash <- env$mfrmr_gtds3p_hash(
    altered[env$mfrmr_gtds3p_payload_fields()]
  )
  expect_error(
    env$mfrmr_gtds3p_assert_plan(altered),
    "superseding unopened plan or boundary was altered",
    fixed = TRUE
  )
  altered <- plan
  altered$SupersessionRegistry$DatasetAttempt$SeedReused[[1L]] <- TRUE
  altered$PlanHash <- env$mfrmr_gtds3p_hash(
    altered[env$mfrmr_gtds3p_payload_fields()]
  )
  expect_error(
    env$mfrmr_gtds3p_assert_plan(altered),
    "superseding unopened plan or boundary was altered",
    fixed = TRUE
  )
})
