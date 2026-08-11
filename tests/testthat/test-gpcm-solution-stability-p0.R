gpcm_solution_stability_paths <- function() {
  c(
    numerical = testthat::test_path(
      "..", "..", "inst", "validation",
      "numerical-stationarity-pilot-0.2.3.R"
    ),
    stability = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-solution-stability-p0-0.2.3.R"
    )
  )
}

gpcm_solution_stability_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_solution_stability_paths()
    testthat::skip_if_not(
      all(file.exists(paths)),
      "repository-internal validation artifacts are excluded"
    )
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["numerical"]], envir = value)
    sys.source(paths[["stability"]], envir = value)
    value
  }
})

gpcm_solution_stability_result <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    testthat::skip_on_cran()
    env <- gpcm_solution_stability_environment()
    value <<- env$mfrmr_run_gpcm_solution_stability_p0()
    value
  }
})

test_that("GPCM solution-stability P0 pins scope and start registry", {
  env <- gpcm_solution_stability_environment()
  result <- gpcm_solution_stability_result()
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-solution-stability-p0-record-0.2.3.md"
  )

  expect_true(file.exists(record))
  expect_identical(
    digest::digest(
      gpcm_solution_stability_paths()[["stability"]],
      algo = "sha256",
      file = TRUE,
      serialize = FALSE
    ),
    "89b20f7185ca3eaf06920cd5468711d47429df9f6d6841f59ef7a425e5e51c6f"
  )
  expect_identical(
    env$mfrmr_gss_contract,
    "mfrmr_gpcm_solution_stability_p0_v1"
  )
  expect_identical(
    result$registry$StartId,
    c(
      "default", "retained_restart", "zero_null", "slope_low_high",
      "variance_low", "variance_high", "seeded_perturbation"
    )
  )
  expect_identical(result$registry$StartOrder, seq_len(7L))
  expect_true(all(result$registry$Model == "GPCM"))
  expect_true(all(result$registry$Method == "MML"))
  expect_true(all(result$registry$Identification == "free_population"))
  expect_true(all(result$registry$QuadPoints == 31L))
  expect_true(all(!result$registry$SelectionAuthorized))
  expect_true(all(!result$registry$ConfirmationAuthorized))
  expect_length(unique(result$registry$ContextSHA256), 1L)
  expect_length(unique(result$registry$FixtureSHA256), 1L)

  set.seed(91)
  before <- .Random.seed
  rebuilt <- env$mfrmr_gss_build_registry(
    result$baseline_fit,
    list(
      fixture_id = result$fixture_manifest$FixtureId,
      sha256 = result$fixture_manifest$SHA256
    ),
    result$context,
    maxit = result$registry$Maxit[1L],
    reltol = result$registry$Reltol[1L]
  )
  after <- .Random.seed
  expect_identical(after, before)
  expect_identical(
    rebuilt$StartVectorSHA256,
    result$registry$StartVectorSHA256
  )
})

test_that("P0 rejects mutated or mixed start registries", {
  env <- gpcm_solution_stability_environment()
  result <- gpcm_solution_stability_result()
  fixture <- list(
    fixture_id = result$fixture_manifest$FixtureId,
    sha256 = result$fixture_manifest$SHA256
  )

  changed_vector <- result$registry
  changed_vector$StartVector[[1L]][1L] <-
    changed_vector$StartVector[[1L]][1L] + 0.1
  expect_error(
    env$mfrmr_gss_validate_registry(
      changed_vector, result$context, fixture
    ),
    "fingerprint"
  )

  duplicate_id <- result$registry
  duplicate_id$StartId[2L] <- duplicate_id$StartId[1L]
  expect_error(
    env$mfrmr_gss_validate_registry(
      duplicate_id, result$context, fixture
    ),
    "exact prespecified IDs and order"
  )

  mixed_quadrature <- result$registry
  mixed_quadrature$QuadPoints[7L] <- 61L
  expect_error(
    env$mfrmr_gss_validate_registry(
      mixed_quadrature, result$context, fixture
    ),
    "mixes fixtures"
  )

  unauthorized <- result$registry
  unauthorized$SelectionAuthorized[1L] <- TRUE
  expect_error(
    env$mfrmr_gss_validate_registry(
      unauthorized, result$context, fixture
    ),
    "cannot authorize selection"
  )
})

test_that("P0 reevaluates every returned solution in one canonical context", {
  result <- gpcm_solution_stability_result()
  candidates <- result$candidates

  expect_identical(candidates$StartId, result$registry$StartId)
  expect_true(all(candidates$FitReturned))
  expect_true(all(candidates$CommonEvaluationComplete))
  expect_true(all(candidates$DimensionIdentity))
  expect_true(all(candidates$ExistingOptimizerNumericalPass))
  expect_true(all(candidates$P0ComparisonEligible))
  expect_true(all(!candidates$P0StabilityEligible))
  expect_true(all(candidates$P0StabilityEligibilityReason ==
                    "tolerance_boundary_and_integration_rules_not_frozen"))
  expect_true(all(candidates$FreeDimensionReturned == 16L))
  expect_true(all(candidates$FreeDimensionSizes == 16L))
  expect_true(all(candidates$FreeDimensionCoordinates == 16L))
  expect_true(all(candidates$FreeDimensionOptimizerMap == 16L))
  expect_true(all(candidates$FreeDimensionScoreAudit == 16L))
  expect_true(all(is.finite(candidates$NativeObjective)))
  expect_true(all(is.finite(candidates$CommonObjective)))
  expect_true(all(is.finite(candidates$CommonGradientMaxAbs)))
  expect_true(all(candidates$IndependentGradientStep == 3e-5))
  expect_true(all(is.finite(candidates$IndependentGradientMaxAbs)))
  expect_true(all(is.finite(
    candidates$AnalyticNumericGradientMaxAbsDifference
  )))
  expect_true(all(is.finite(
    candidates$AnalyticNumericGradientMaxScaledDifference
  )))
  expect_true(all(candidates$NativeCommonObjectiveAbsDifference < 1e-8))
  expect_true(all(candidates$BoundaryStatus ==
                    "not_evaluated_p0_candidate_only"))
  expect_true(all(candidates$DecisionStatus ==
                    "review_p1_p3_dependencies_not_evaluated"))
  expect_true(all(candidates$ToleranceStatus == "not_frozen"))
  expect_true(all(!candidates$SelectionAuthorized))
  expect_true(all(!candidates$ConfirmationAuthorized))
  expect_identical(
    result$summary$OverallStatus,
    "p0_evaluated_selection_blocked"
  )
  expect_false(result$summary$SelectionAuthorized)
  expect_false(result$summary$ConfirmationAuthorized)

  expect_identical(nrow(result$pairwise), as.integer(choose(7L, 2L)))
  expect_true(all(result$pairwise$BothP0ComparisonEligible))
  expect_true(all(result$pairwise$ToleranceStatus == "not_frozen"))
  expect_true(all(!result$pairwise$SelectionAuthorized))
  expect_true(all(!result$pairwise$ConfirmationAuthorized))
})

test_that("semantic expansion labels constrained GPCM coordinates", {
  env <- gpcm_solution_stability_environment()
  result <- gpcm_solution_stability_result()
  semantic <- env$mfrmr_gss_semantic_vector(
    result$context,
    result$candidate_objects$default$par
  )

  expect_identical(anyDuplicated(semantic$SemanticKey), 0L)
  expect_true(all(is.finite(semantic$Value)))
  expect_identical(
    table(semantic$ParameterClass),
    table(factor(
      c(
        rep("facet:Item", 4L), rep("step", 12L),
        rep("log_slope", 4L), rep("slope", 4L),
        "population_beta", "population_log_sigma2", "population_sigma2"
      ),
      levels = sort(unique(semantic$ParameterClass))
    ))
  )
  log_slopes <- semantic$Value[semantic$ParameterClass == "log_slope"]
  slopes <- semantic$Value[semantic$ParameterClass == "slope"]
  expect_equal(sum(log_slopes), 0, tolerance = 1e-12)
  expect_equal(prod(slopes), 1, tolerance = 1e-12)

  step_index <- result$context$slices$steps[1L]
  changed <- result$candidate_objects$default$par
  changed[step_index] <- changed[step_index] + 0.1
  changed_semantic <- env$mfrmr_gss_semantic_vector(result$context, changed)
  delta <- abs(semantic$Value - changed_semantic$Value)
  expect_true(any(delta[semantic$ParameterClass == "step"] > 0))
  expect_true(all(delta[semantic$ParameterClass != "step"] == 0))
})

test_that("decision signatures are exact and fail closed", {
  env <- gpcm_solution_stability_environment()
  result <- gpcm_solution_stability_result()
  row <- result$candidates[1L, , drop = FALSE]
  signature <- env$mfrmr_gss_candidate_signature(row)

  expect_identical(
    signature$State[signature$Metric == "overall"],
    "review"
  )
  later_metrics <- c(
    "boundary", "hessian", "intervals", "dff", "fit", "person_rank",
    "rater_rank", "facet_separation"
  )
  expect_true(all(
    signature$State[signature$Metric %in% later_metrics] == "not_evaluated"
  ))
  expect_true(env$mfrmr_gss_compare_signatures(
    signature,
    signature[sample(seq_len(nrow(signature))), , drop = FALSE]
  )$DecisionInvariant)

  changed <- env$mfrmr_gss_candidate_signature(
    row,
    overrides = data.frame(
      Metric = "dff",
      State = "flagged",
      Eligibility = "evaluated",
      Reason = "mutation_test",
      stringsAsFactors = FALSE
    )
  )
  comparison <- env$mfrmr_gss_compare_signatures(signature, changed)
  expect_false(comparison$DecisionInvariant)
  expect_identical(comparison$ChangedMetricCount, 1L)
  expect_identical(comparison$ChangedMetrics, "dff")

  missing_key <- changed[changed$Metric != "fit", , drop = FALSE]
  expect_error(
    env$mfrmr_gss_compare_signatures(signature, missing_key),
    "different metric keys"
  )
})

test_that("failed P0 candidates remain recorded and ineligible", {
  env <- gpcm_solution_stability_environment()
  result <- gpcm_solution_stability_result()
  failed <- env$mfrmr_gss_candidate_row(
    result$registry[1L, , drop = FALSE],
    list(
      opt = NULL,
      warnings = "declared warning",
      error = "declared failure",
      elapsed = 0.01
    ),
    result$baseline_fit,
    result$context
  )

  expect_false(failed$FitReturned)
  expect_false(failed$CommonEvaluationComplete)
  expect_false(failed$DimensionIdentity)
  expect_false(failed$ExistingOptimizerNumericalPass)
  expect_false(failed$P0ComparisonEligible)
  expect_false(failed$P0StabilityEligible)
  expect_identical(failed$ConvergenceSeverity, "fail")
  expect_identical(failed$DecisionStatus,
                   "review_p1_p3_dependencies_not_evaluated")
  expect_false(failed$SelectionAuthorized)
  expect_false(failed$ConfirmationAuthorized)
  expect_identical(failed$ErrorText, "declared failure")
})
