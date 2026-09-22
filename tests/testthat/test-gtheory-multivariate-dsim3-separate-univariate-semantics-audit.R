gtheory_dsim3s_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  file.path(validation, c(
    "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
    "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
    "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
    "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
    "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
    "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R",
    "gtheory-multivariate-dsim3-covariance-distribution-binding-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-semantics-audit-",
      "0.2.4.R"
    )
  ))
}

load_gtheory_dsim3s <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3s_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 semantics audit excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3s_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) {
      manifest <<- environment$mfrmr_gtds3s_manifest()
    }
    manifest
  }
})

test_that("separate-univariate semantics bind the unopened parent plan", {
  env <- load_gtheory_dsim3s()
  contract <- env$mfrmr_gtds3s_contract()
  manifest <- gtheory_dsim3s_manifest(env)
  expect_invisible(env$mfrmr_gtds3s_validate_contract(contract))
  expect_invisible(env$mfrmr_gtds3s_assert_manifest(manifest))
  expect_identical(
    contract$ContractHash,
    "ed0eda8a02cd4ea4dc46084f56f6683ac967da0705c08e8fb4f804cf6ed94adf"
  )
  expect_identical(
    manifest$ManifestHash,
    "815d29f76640f2886b572ffda418582a02135d51cd50dadbab5ff6e4308bbb2f"
  )
  expect_identical(
    manifest$ParentExecutionPlanHash,
    "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7"
  )
})

test_that("backend feasibility is distinct from route semantics", {
  env <- load_gtheory_dsim3s()
  manifest <- gtheory_dsim3s_manifest(env)
  routes <- manifest$RouteUnitSemanticsRegistry
  expect_identical(nrow(routes), 42L)
  expect_identical(sum(routes$PlannedFitPartitionCount), 94L)
  expect_true(all(routes$Backend == "lme4"))
  expect_true(all(routes$EstimationCriterion == "REML"))
  expect_true(all(routes$BackendCriterionFrozen))
  expect_identical(sum(routes$CurrentRouteSemanticsReady), 20L)
  expect_false(any(routes$ExactBackendRequestCompiled))
  expect_false(any(routes$BackendCallMade))
  expect_false(any(routes$FitExecuted))
  expect_false(any(routes$MetricComputed))
  expect_false(any(routes$ExecutionAuthorized))
})

test_that("nested generated components alias incompatible error roles", {
  env <- load_gtheory_dsim3s()
  manifest <- gtheory_dsim3s_manifest(env)
  incidence <- manifest$IncidencePartitionRegistry
  nested <- incidence$Crossing == "nested"
  expect_identical(sum(nested), 15L)
  expect_true(all(incidence$RaterObjectRaterPartitionsAliased[nested]))
  expect_false(any(
    incidence$CurrentTruthRolesSeparatelyIdentifiable[nested]
  ))
  expect_false(any(incidence$CurrentMetricSemanticsReady[nested]))
  rules <- manifest$ComponentRuleRegistry
  nested_rules <- rules$Crossing == "nested"
  expect_true(all(rules$GeneratedPartitionsAliased[nested_rules]))
  expect_false(any(
    rules$GeneratedRolesSeparatelyIdentifiable[nested_rules]
  ))
  expect_match(
    unique(rules$RequiredTruthRevision[nested_rules]),
    "combined_nested_condition_component_to_relative_and_absolute_error",
    fixed = TRUE
  )
})

test_that("prospective allocation follows object incidence", {
  env <- load_gtheory_dsim3s()
  incidence <- gtheory_dsim3s_manifest(env)$IncidencePartitionRegistry
  full <- incidence$Crossing == "fully_crossed"
  partial <- incidence$Crossing == "partially_crossed"
  nested <- incidence$Crossing == "nested"
  expect_true(all(incidence$ExistingGlobalOperatorEquivalent[full]))
  expect_false(any(incidence$ExistingGlobalOperatorEquivalent[partial]))
  expect_false(any(incidence$ExistingGlobalOperatorEquivalent[nested]))
  expect_equal(
    incidence$RequiredIncidenceOperatorDiagonal[partial] /
      incidence$GlobalConditionOperatorDiagonal[partial],
    rep(2, sum(partial)), tolerance = 1e-12
  )
  expect_equal(
    incidence$RequiredIncidenceOperatorDiagonal[nested] /
      incidence$GlobalConditionOperatorDiagonal[nested],
    incidence$StructuralObjectCount[nested], tolerance = 1e-12
  )
  expect_true(all(incidence$ConnectedIncidence[full | partial]))
  expect_identical(
    incidence$IncidenceGraphComponentCount[nested],
    incidence$StructuralObjectCount[nested]
  )
})

test_that("route coordinate output remains a nonpooling vector", {
  env <- load_gtheory_dsim3s()
  output <- gtheory_dsim3s_manifest(env)$OutputRegistry
  expect_identical(output$EstimandId, c("ABS-PHI", "REL-G"))
  expect_true(all(
    output$RouteCoordinatePayload == "named_per_stratum_numeric_vector"
  ))
  expect_false(any(output$ScalarPoolingAcrossStrataAllowed))
  expect_false(any(output$CrossStratumCovarianceRecovered))
  expect_true(all(output$AllRegisteredStrataRequired))
  expect_true(all(output$RecoveryPassAggregation ==
                    "conjunctive_across_strata"))
  expect_false(any(output$CountsAsIndependentDataset))
  expect_false(any(output$CrossRouteVotingAllowed))
})

test_that("semantic audit records the upstream no-go", {
  env <- load_gtheory_dsim3s()
  manifest <- gtheory_dsim3s_manifest(env)
  profiles <- manifest$ProfileSemanticsRegistry
  expect_identical(sum(
    profiles$CurrentTruthRolesSeparatelyIdentifiable
  ), 15L)
  expect_identical(sum(
    profiles$IncidenceOperatorImplementationReady
  ), 10L)
  expect_identical(sum(profiles$CurrentRouteSemanticsReady), 10L)
  expect_identical(
    manifest$ReadinessGateRegistry$GatePassed,
    c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)
  )
  expect_true(all(manifest$OpenGapRegistry$GapOpen))
  expect_identical(
    manifest$Summary$CurrentDisposition,
    "no_go_truth_estimand_and_incidence_operator_revision_required"
  )
  expect_false(manifest$Summary$Planned855RngStreamOpened)
  expect_false(manifest$Summary$ExploratoryResponseGenerated)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitReturned)
  expect_false(manifest$Summary$EmpiricalMetricComputed)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})
