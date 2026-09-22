gpcm_endpoint_p0b_paths <- function() {
  c(
    numerical = testthat::test_path(
      "..", "..", "inst", "validation",
      "numerical-stationarity-pilot-0.2.3.R"
    ),
    p0 = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-solution-stability-p0-0.2.3.R"
    ),
    p0b = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-endpoint-solution-stability-p0b-0.2.3.R"
    )
  )
}

gpcm_endpoint_p0b_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_endpoint_p0b_paths()
    testthat::skip_if_not(
      all(file.exists(paths)),
      "repository-internal validation artifacts are excluded"
    )
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["numerical"]], envir = value)
    sys.source(paths[["p0"]], envir = value)
    sys.source(paths[["p0b"]], envir = value)
    value
  }
})

gpcm_endpoint_p0b_result <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    testthat::skip_on_cran()
    env <- gpcm_endpoint_p0b_environment()
    value <<- env$mfrmr_run_gpcm_endpoint_solution_stability_p0b()
    value
  }
})

test_that("endpoint P0b pins its dependency and bounded plan", {
  env <- gpcm_endpoint_p0b_environment()
  paths <- gpcm_endpoint_p0b_paths()
  plan <- env$mfrmr_gss_p0b_plan()
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-endpoint-solution-stability-p0b-record-0.2.3.md"
  )

  expect_true(file.exists(record))
  expect_identical(
    digest::digest(
      paths[["p0b"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "63dbb2ae1ec6b9df56e252d8d7bf55a2ff61870c17d2c366da6ddedd46ca8364"
  )
  expect_identical(
    env$mfrmr_gss_p0b_contract,
    "mfrmr_gpcm_endpoint_solution_stability_p0b_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p0"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gss_p0b_dependency_sha256
  )
  expect_identical(plan$ScenarioId, c(
    "EXT5-P-HI", "EXT5-P-LO", "EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO"
  ))
  expect_identical(plan$EndpointResponses, c(20L, 20L, 19L, 19L))
  expect_equal(plan$EndpointRate, c(1, 1, 0.95, 0.95), tolerance = 0)
  expect_true(all(plan$Model == "GPCM"))
  expect_true(all(plan$Method == "MML"))
  expect_true(all(plan$Identification == "free_population"))
  expect_true(all(plan$QuadPoints == 31L))
  expect_identical(
    env$mfrmr_gss_p0b_gradient_steps,
    c(1e-5, 1e-6, 1e-7, 1e-8, 1e-9)
  )
  expect_true(all(!plan$SelectionAuthorized))
  expect_true(all(!plan$ConfirmationAuthorized))
})

test_that("endpoint fixtures preserve support and exact score reflection", {
  env <- gpcm_endpoint_p0b_environment()
  fixtures <- lapply(
    env$mfrmr_gss_p0b_scenarios,
    env$mfrmr_gss_p0b_fixture
  )
  names(fixtures) <- env$mfrmr_gss_p0b_scenarios

  expect_true(all(vapply(fixtures, function(value) {
    nrow(value$data) == 400L && all(value$category_support > 0L)
  }, logical(1))))
  expect_length(unique(vapply(fixtures, `[[`, character(1), "sha256")), 4L)

  reflection <- env$mfrmr_gss_p0b_reflection_audit()
  expect_identical(nrow(reflection), 2L)
  expect_true(all(reflection$RowIdentity))
  expect_true(all(reflection$ExactScoreReflection))
  expect_true(all(reflection$Rows == 400L))
  expect_true(all(!reflection$SelectionAuthorized))
  expect_true(all(!reflection$ConfirmationAuthorized))

  high <- fixtures[["EXT5-P-HI"]]$data
  near_high <- fixtures[["EXT5-P-NEAR-HI"]]$data
  expect_identical(sum(high$Person == "P01" & high$Score == 5L), 20L)
  expect_identical(
    sum(near_high$Person == "P01" & near_high$Score == 5L),
    19L
  )
})

test_that("exact and near endpoint MML provenance remain distinct", {
  result <- gpcm_endpoint_p0b_result()
  endpoints <- result$endpoints

  expect_identical(endpoints$ScenarioId, result$plan$ScenarioId)
  expect_true(all(endpoints$FitReturned))
  expect_true(all(endpoints$EndpointContractPassed))
  expect_true(all(is.finite(endpoints$PrimaryEstimate)))
  expect_true(all(is.finite(endpoints$PosteriorSD)))
  expect_true(all(is.finite(endpoints$PopulationSigma2)))
  expect_true(all(endpoints$PopulationSigma2 > 0))
  expect_true(all(endpoints$PrimaryEstimateBasis == "posterior_eap"))
  expect_identical(
    endpoints$ResponseExtreme,
    c("high", "low", "none", "none")
  )
  expect_identical(
    endpoints$BoundaryDirection,
    c("high", "low", "none", "none")
  )
  expect_identical(
    endpoints$ReasonCodes,
    c(
      "mml_extreme_response_prior_regularized",
      "mml_extreme_response_prior_regularized",
      "", ""
    )
  )
  expect_true(endpoints$PrimaryEstimate[1L] > 0)
  expect_true(endpoints$PrimaryEstimate[2L] < 0)
  expect_true(endpoints$PrimaryEstimate[3L] > 0)
  expect_true(endpoints$PrimaryEstimate[4L] < 0)
  expect_true(all(!endpoints$PopulationConverged))
  expect_true(all(endpoints$ConvergenceSeverity == "review"))
  expect_true(all(endpoints$FitReadiness == "review"))
  expect_true(all(!endpoints$InferenceReady))
  expect_true(all(endpoints$FitBoundaryState == "not_evaluated"))
  expect_true(all(endpoints$SlopeBoundaryAuditComplete))
  expect_true(all(endpoints$SlopeBoundaryScopeComplete))
  expect_true(all(!endpoints$ContinuousIntegralCertificate))
  expect_true(all(!endpoints$SelectionAuthorized))
  expect_true(all(!endpoints$ConfirmationAuthorized))
})

test_that("endpoint P0b retains every start and exposes optimizer sensitivity", {
  env <- gpcm_endpoint_p0b_environment()
  result <- gpcm_endpoint_p0b_result()
  candidates <- result$candidates
  summary <- result$scenario_summary

  expect_identical(nrow(candidates), 28L)
  expect_true(all(table(candidates$ScenarioId) == 7L))
  expect_true(all(candidates$FitReturned))
  expect_true(all(candidates$FreeDimensionReturned == 24L))
  expect_true(all(candidates$FreeDimensionSizes == 24L))
  expect_true(all(candidates$FreeDimensionCoordinates == 24L))
  expect_true(all(candidates$FreeDimensionOptimizerMap == 24L))
  expect_true(all(candidates$FreeDimensionScoreAudit == 24L))
  expect_true(all(candidates$DimensionIdentity))
  expect_true(all(candidates$CommonEvaluationComplete))
  expect_true(all(!candidates$P0StabilityEligible))
  expect_true(all(candidates$P0StabilityEligibilityReason ==
    "population_boundary_solution_tolerance_and_integration_rules_not_frozen"))
  expect_true(all(!candidates$SelectionAuthorized))
  expect_true(all(!candidates$ConfirmationAuthorized))

  expect_true(all(summary$FitReturned))
  expect_true(all(summary$EndpointContractPassed))
  expect_true(all(summary$DeclaredStarts == 7L))
  expect_true(all(summary$ReturnedStarts == 7L))
  expect_true(all(summary$ExistingOptimizerPassStarts == 1L))
  expect_true(all(summary$P0ComparisonEligibleStarts == 1L))
  expect_true(all(summary$P0StabilityEligibleStarts == 0L))
  expect_true(all(summary$DefaultStartSeverity == "review"))
  expect_true(all(summary$DiagnosticLowestObjectiveStart == "variance_low"))
  expect_true(all(summary$DiagnosticLowestObjectiveSeverity == "pass"))
  expect_true(all(summary$DiagnosticLowestExistingPassStart == "variance_low"))
  expect_true(all(summary$DiagnosticObjectiveImprovementFromDefault > 0))
  expect_true(all(summary$CommonObjectiveRange > 0))
  expect_true(all(is.finite(summary$DiagnosticBestPopulationSigma2)))
  expect_true(all(summary$DiagnosticBestPopulationSigma2 > 0))
  expect_true(all(is.finite(summary$MaximumAnalyticNumericGradientDifference)))
  expect_true(all(is.finite(
    summary$DefaultGradientLadderMinimumDifference
  )))
  expect_true(all(is.finite(
    summary$DiagnosticBestGradientLadderMinimumDifference
  )))
  expect_true(all(summary$DefaultGradientLadderDiagnosticStep %in%
                    env$mfrmr_gss_p0b_gradient_steps))
  expect_true(all(summary$DiagnosticBestGradientLadderDiagnosticStep %in%
                    env$mfrmr_gss_p0b_gradient_steps))
  expect_true(all(summary$GradientToleranceStatus ==
                    "not_frozen_calibration_ladder"))
  expect_true(all(summary$ComparisonError == ""))
  expect_gte(sum(summary$FailedSeverityStarts), 1L)
  expect_true(all(!summary$SelectionAuthorized))
  expect_true(all(!summary$ConfirmationAuthorized))

  expect_identical(nrow(result$pairwise), 4L * as.integer(choose(7L, 2L)))
  expect_identical(
    nrow(result$semantic_differences),
    4L * as.integer(choose(7L, 2L)) * 8L
  )
  expect_true(all(!result$pairwise$SelectionAuthorized))
  expect_true(all(!result$pairwise$ConfirmationAuthorized))
  expect_identical(nrow(result$gradient_ladder), 40L)
  expect_true(all(result$gradient_ladder$EvaluationComplete))
  expect_true(all(result$gradient_ladder$ToleranceStatus ==
                    "not_frozen_calibration_ladder"))
  expect_true(all(!result$gradient_ladder$StepSelectionAuthorized))
  expect_true(all(!result$gradient_ladder$SelectionAuthorized))
  expect_true(all(!result$gradient_ladder$ConfirmationAuthorized))
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("endpoint P0b decision signatures fail closed", {
  env <- gpcm_endpoint_p0b_environment()
  result <- gpcm_endpoint_p0b_result()
  signature <- result$decision_signatures[["EXT5-P-HI"]]

  expect_identical(
    signature$State[signature$Metric == "endpoint_contract"],
    "pass"
  )
  expect_identical(
    signature$State[signature$Metric == "person_response_class"],
    "exact_high"
  )
  expect_identical(
    signature$State[signature$Metric == "population_convergence"],
    "review"
  )
  expect_identical(
    signature$State[signature$Metric == "optimizer_numerical_panel"],
    "review"
  )
  expect_identical(signature$State[signature$Metric == "overall"], "review")
  pending <- c(
    "population_boundary", "continuous_integration", "candidate_eap",
    "dff", "fit", "person_rank", "rater_rank", "facet_separation"
  )
  expect_true(all(
    signature$State[signature$Metric %in% pending] == "not_evaluated"
  ))

  changed <- signature
  changed$State[changed$Metric == "population_boundary"] <- "flagged"
  changed$Reason[changed$Metric == "population_boundary"] <- "mutation_test"
  comparison <- env$mfrmr_gss_compare_signatures(signature, changed)
  expect_false(comparison$DecisionInvariant)
  expect_identical(comparison$ChangedMetricCount, 1L)
  expect_identical(comparison$ChangedMetrics, "population_boundary")

  near <- result$decision_signatures[["EXT5-P-NEAR-HI"]]
  expect_true(all(nzchar(near$Reason)))
  expect_identical(
    near$Reason[near$Metric == "person_estimate_basis"],
    "no_exact_response_boundary_reason_near_endpoint"
  )
})

test_that("endpoint P0b retains a typed failed source-fit row", {
  env <- gpcm_endpoint_p0b_environment()
  fixture <- env$mfrmr_gss_p0b_fixture("EXT5-P-HI")
  failed <- env$mfrmr_gss_p0b_endpoint_row(
    fixture,
    list(
      fit = NULL,
      warnings = "declared warning",
      error = "declared failure"
    )
  )

  expect_false(failed$FitReturned)
  expect_false(failed$EndpointContractPassed)
  expect_false(failed$PopulationConverged)
  expect_identical(failed$ConvergenceSeverity, "fail")
  expect_identical(failed$FitReadiness, "blocked")
  expect_identical(failed$P0BStatus, "blocked_source_fit_failed")
  expect_identical(failed$WarningCount, 1L)
  expect_identical(failed$ErrorText, "declared failure")
  expect_false(failed$SelectionAuthorized)
  expect_false(failed$ConfirmationAuthorized)

  failed_signature <- env$mfrmr_gss_p0b_signature(failed, data.frame())
  expect_identical(
    failed_signature$State[failed_signature$Metric ==
                             "optimizer_numerical_panel"],
    "fail"
  )
  expect_identical(
    failed_signature$State[failed_signature$Metric == "overall"],
    "blocked"
  )
  expect_true(all(nzchar(failed_signature$Reason)))
})
