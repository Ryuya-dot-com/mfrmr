gtheory_ademp_registry_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R"
    )
  )
}

load_gtheory_ademp_registry <- function() {
  paths <- gtheory_ademp_registry_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("Draft.83d1 registers every requested design dimension", {
  env <- load_gtheory_ademp_registry()
  registry <- env$mfrmr_gtd_registry()

  expect_s3_class(registry, "mfrmr_gtd_registry")
  expect_equal(nrow(registry$FactorCatalog), 13L)
  expect_equal(nrow(registry$Scenarios), 24L)
  expect_equal(nrow(registry$Routing), 480L)
  expect_true(all(c(
    "person_count", "observations_per_person", "rater_count",
    "criterion_count", "category_count", "assignment_sparsity",
    "workload_imbalance", "endpoint_concentration", "local_dependence",
    "anchor_rate", "missingness_mechanism"
  ) %in% registry$FactorCatalog$FactorId))
  expect_true(all(!registry$FactorCatalog$FullFactorial))
  expect_true(any(registry$Scenarios$NPerson == 30L))
  expect_true(any(registry$Scenarios$NPerson == 300L))
  expect_true(all(c(2L, 4L, 6L, 8L) %in% registry$Scenarios$NRater))
  expect_true(all(c(2L, 4L, 8L) %in% registry$Scenarios$NCriterion))
  expect_true(all(c(4L, 8L, 12L, 16L, 32L, 64L) %in%
                    registry$Scenarios$ObservationsPerPerson))
  expect_true(all(c(0.125, 0.25, 0.50, 1.00) %in%
                    registry$Scenarios$AssignmentDensity))
})

test_that("Draft.83d1 separates Gaussian truth from sensitivity targets", {
  env <- load_gtheory_ademp_registry()
  scenarios <- env$mfrmr_gtd_registry()$Scenarios
  exact <- scenarios$Lane == "gaussian_exact_recovery"
  bounded <- scenarios$Lane == "bounded_score_projection"
  dependent <- scenarios$Lane == "local_dependence_sensitivity"

  expect_true(all(scenarios$ScoreSupport[exact] == "continuous"))
  expect_true(all(is.na(scenarios$CategoryCount[exact])))
  expect_true(all(scenarios$EndpointRateTarget[exact] == 0))
  expect_true(all(scenarios$LocalDependenceRho[exact] == 0))
  expect_equal(sort(scenarios$CategoryCount[bounded]), c(3L, 5L, 7L))
  expect_true(all(
    scenarios$TargetBasis[bounded] ==
      "full_potential_observed_score_projection"
  ))
  expect_true(all(scenarios$LocalDependenceRho[dependent] > 0))
  expect_true(all(
    scenarios$TargetBasis[dependent] ==
      "independence_model_reference_not_component_truth"
  ))
})

test_that("Draft.83d1 blocks anchor rate instead of inventing a G-study factor", {
  env <- load_gtheory_ademp_registry()
  registry <- env$mfrmr_gtd_registry()
  anchors <- registry$Scenarios$Lane == "anchor_nonapplicability"
  anchor_routes <- registry$Routing$Lane == "anchor_nonapplicability"

  expect_equal(sort(registry$Scenarios$AnchorRate[anchors]), c(0.25, 0.50))
  expect_true(all(registry$Scenarios$MethodSet[anchors] == "none"))
  expect_true(all(
    registry$Scenarios$ExecutionEligibility[anchors] ==
      "blocked_anchor_not_gstudy_operation"
  ))
  expect_true(all(
    registry$Routing$EligibilityState[anchor_routes] ==
      "blocked_not_current_gstudy_operation"
  ))
  manifest <- env$mfrmr_gtd_execution_manifest(registry)
  expect_false(any(manifest$ScenarioId %in%
                     registry$Scenarios$ScenarioId[anchors]))
})

test_that("Draft.83d1 routes coverage and facet recovery without conflation", {
  env <- load_gtheory_ademp_registry()
  registry <- env$mfrmr_gtd_registry()
  routing <- registry$Routing
  coverage <- routing$MetricId %in% c(
    "component_se_coverage", "g_coefficient_coverage",
    "phi_coefficient_coverage"
  )

  expect_false(any(
    routing$EligibilityState[coverage] == "eligible_draft83d1"
  ))
  expect_true(any(
    routing$EligibilityState[coverage] == "no_interval_until_draft84"
  ))
  expect_true(all(c(
    "facet_level_rank_spearman", "facet_level_rmse",
    "gt_effect_recovery_ratio"
  ) %in% registry$MetricCatalog$MetricId))
  separation <- registry$MetricCatalog$Interpretation[
    registry$MetricCatalog$MetricId == "gt_effect_recovery_ratio"
  ]
  expect_match(separation, "not Rasch/FACETS separation", fixed = TRUE)
  false_ready <- routing[
    routing$MetricId == "false_ready_rate" &
      routing$EligibilityState == "eligible_draft83d1", , drop = FALSE
  ]
  expect_true(all(false_ready$Lane %in% c(
    "identification_negative_control", "boundary_recovery"
  )))
})

test_that("Draft.83d1 execution manifest preserves paired data identities", {
  env <- load_gtheory_ademp_registry()
  registry <- env$mfrmr_gtd_registry()
  manifest <- env$mfrmr_gtd_execution_manifest(registry)

  expect_equal(nrow(manifest), 89L)
  expect_identical(
    anyDuplicated(paste(manifest$ScenarioId, manifest$Replicate,
                        manifest$MethodId)),
    0L
  )
  expect_true(all(manifest$RegistryHash == registry$RegistryHash))
  expect_false(anyNA(manifest$Backend))
  first <- manifest[manifest$ScenarioId == "GT-EXACT-N030", , drop = FALSE]
  expect_equal(nrow(first), 5L)
  expect_equal(length(unique(first$DatasetId)), 1L)
  expect_equal(length(unique(first$Seed)), 1L)
  expect_true(all(c("balanced_mom", "lme4", "glmmTMB") %in% first$Backend))
})

test_that("Draft.83d1 result schema keeps failures and metrics separate", {
  env <- load_gtheory_ademp_registry()
  schema <- env$mfrmr_gtd_result_schema()

  expect_named(schema, c(
    "DatasetResults", "MetricResults", "FailureLedger", "DenominatorSummary"
  ))
  expect_true(all(c(
    "Generated", "PreFitEligible", "FitAttempted", "FitReturned",
    "OptimizerConverged", "ComponentVectorFinite", "EstimationGatePassed",
    "FailureStage", "FailureCode"
  ) %in% names(schema$DatasetResults)))
  expect_true(all(c(
    "TruthDefined", "MetricEligible", "ValueAvailable", "Estimate", "Truth",
    "EligibilityState"
  ) %in% names(schema$MetricResults)))
  expect_true(all(c(
    "PlannedFitUnits", "UnrecordedCount", "FalseReadyCount",
    "ExactAccountingPassed"
  ) %in% names(schema$DenominatorSummary)))
  expect_equal(nrow(schema$DatasetResults), 0L)
  expect_equal(nrow(schema$MetricResults), 0L)
})

gtd_denominator_fixture <- function(env) {
  registry <- env$mfrmr_gtd_registry()
  scenario <- "GT-BOUNDARY-ZERO"
  manifest <- data.frame(
    ScenarioId = rep(scenario, 4L), Replicate = 1:4,
    DatasetId = sprintf("%s/R%04d", scenario, 1:4),
    Seed = 9001:9004, MethodId = "lme4_reml", Backend = "lme4",
    RegistryHash = registry$RegistryHash, stringsAsFactors = FALSE
  )
  results <- env$mfrmr_gtd_empty_results(manifest)
  results$Generated <- TRUE
  results$PreFitEligible <- c(TRUE, FALSE, TRUE, TRUE)
  results$FitAttempted <- c(TRUE, FALSE, TRUE, TRUE)
  results$FitReturned <- c(TRUE, FALSE, FALSE, TRUE)
  results$OptimizerConverged <- c(TRUE, FALSE, FALSE, TRUE)
  results$ComponentVectorFinite <- c(TRUE, FALSE, FALSE, TRUE)
  results$EstimationGatePassed <- c(TRUE, FALSE, FALSE, FALSE)
  results$FailureStage <- c("none", "prefit", "fit", "regularity")
  results$FailureCode <- c(
    "none", "incidence_screen_failed", "backend_error", "boundary_nonregular"
  )
  list(Registry = registry, Manifest = manifest, Results = results)
}

test_that("Draft.83d1 denominator accounting exposes false readiness", {
  env <- load_gtheory_ademp_registry()
  fixture <- gtd_denominator_fixture(env)
  summary <- env$mfrmr_gtd_denominator_summary(
    fixture$Registry, fixture$Manifest, fixture$Results
  )

  expect_equal(nrow(summary), 1L)
  expect_equal(summary$PlannedFitUnits, 4L)
  expect_equal(summary$RecordedResults, 4L)
  expect_equal(summary$Generated, 4L)
  expect_equal(summary$PreFitEligible, 3L)
  expect_equal(summary$FitAttempted, 3L)
  expect_equal(summary$FitReturned, 2L)
  expect_equal(summary$OptimizerConverged, 2L)
  expect_equal(summary$FiniteComponentVector, 2L)
  expect_equal(summary$EstimationGatePassed, 1L)
  expect_equal(summary$FailedCellCount, 3L)
  expect_equal(summary$ClassifiedFailureCount, 3L)
  expect_equal(summary$FitReturnRate, 2 / 3)
  expect_equal(summary$OptimizerConvergenceRate, 2 / 3)
  expect_equal(summary$EstimationGateRate, 1 / 4)
  expect_equal(summary$FalseReadyCount, 1L)
  expect_equal(summary$FalseReadyRate, 1 / 4)
  expect_false(summary$ZeroFalseReadyPassed)
  expect_true(summary$ExactAccountingPassed)
})

test_that("Draft.83d1 distinguishes missing records from typed failures", {
  env <- load_gtheory_ademp_registry()
  fixture <- gtd_denominator_fixture(env)
  partial <- fixture$Results[-4L, , drop = FALSE]
  summary <- env$mfrmr_gtd_denominator_summary(
    fixture$Registry, fixture$Manifest, partial
  )

  expect_equal(summary$RecordedResults, 3L)
  expect_equal(summary$UnrecordedCount, 1L)
  expect_false(summary$ExactAccountingPassed)

  malformed <- fixture$Results
  malformed$FitReturned[[2L]] <- TRUE
  expect_error(
    env$mfrmr_gtd_denominator_summary(
      fixture$Registry, fixture$Manifest, malformed
    ),
    "denominator ordering"
  )
  wrong_hash <- fixture$Results
  wrong_hash$RegistryHash[[1L]] <- "changed"
  expect_error(
    env$mfrmr_gtd_denominator_summary(
      fixture$Registry, fixture$Manifest, wrong_hash
    ),
    "exact registry hash"
  )
})

test_that("Draft.83d1 registry replays but claims no simulation evidence", {
  env <- load_gtheory_ademp_registry()
  first <- env$mfrmr_gtd_registry()
  second <- env$mfrmr_gtd_registry()

  expect_identical(first$RegistryHash, second$RegistryHash)
  expect_identical(first$Scenarios, second$Scenarios)
  expect_identical(first$Routing, second$Routing)
  expect_false(first$SimulationExecuted)
  expect_false(first$RecoveryEvidenceReady)
  expect_false(first$InferenceReady)
  expect_false(first$CoefficientEligible)
  expect_false(first$DecisionReady)

  changed <- first
  changed$Scenarios$CategoryCount[
    changed$Scenarios$ScenarioId == "GT-EXACT-N030"
  ] <- 5L
  expect_error(
    env$mfrmr_gtd_validate_registry(changed),
    "Continuous-score scenarios"
  )
})
