gpcm_zb_p1c_paths <- function() {
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
    ),
    p1a = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-population-variance-profile-p1a-0.2.3.R"
    ),
    p1b = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-low-basin-quadrature-p1b-0.2.3.R"
    ),
    p1c = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-zero-variance-boundary-p1c-0.2.3.R"
    ),
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-zero-variance-boundary-p1c-record-0.2.3.md"
    )
  )
}

gpcm_zb_p1c_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_zb_p1c_paths()
    testthat::skip_if_not(
      all(file.exists(paths)),
      "internal validation artifacts are excluded"
    )
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    for (path in paths[names(paths) != "record"]) {
      sys.source(path, envir = value)
    }
    value
  }
})

gpcm_zb_p1c_fake_semantic <- function(offset = 0) {
  data.frame(
    SemanticKey = c(
      "facet::Rater::R1", "log_slope::Criterion::C1",
      "slope::Criterion::C1", "population::log_sigma2",
      "population::sigma2"
    ),
    ParameterClass = c(
      "facet:Rater", "log_slope", "slope",
      "population_log_sigma2", "population_sigma2"
    ),
    CoordinateSystem = c(
      "additive", "log_slope", "slope",
      "population_log_sigma2", "population_sigma2"
    ),
    Value = seq_len(5L) + offset,
    stringsAsFactors = FALSE
  )
}

gpcm_zb_p1c_fake_boundary_candidate <- function(
    scenario_id,
    start_id,
    objective,
    eligible = TRUE,
    semantic = gpcm_zb_p1c_fake_semantic()) {
  list(
    row = data.frame(
      ScenarioId = scenario_id,
      StartId = start_id,
      BoundaryComparisonEligible = eligible,
      BoundaryObjective = objective,
      stringsAsFactors = FALSE
    ),
    semantic = semantic,
    path = data.frame(
      Sigma2 = c(1e-6, 1e-8),
      Objective = objective + c(-1e-3, -1e-5),
      NaturalVarianceDifferenceQuotient = c(-1000, -1000),
      stringsAsFactors = FALSE
    )
  )
}

test_that("P1c pins exact zero-limit and bounded execution plans", {
  env <- gpcm_zb_p1c_environment()
  paths <- gpcm_zb_p1c_paths()
  plan <- env$mfrmr_gzb_p1c_plan()
  zero <- env$mfrmr_gzb_p1c_zero_limit_contract()

  expect_identical(
    env$mfrmr_gzb_p1c_contract,
    "mfrmr_gpcm_zero_variance_boundary_p1c_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1b"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gzb_p1c_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1c"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "9feeabfc715d32bc7056e116c58273dcc82363e2111363c1df42d485f6afd8f5"
  )
  expect_identical(nrow(plan$boundary), 12L)
  expect_identical(nrow(plan$interior), 4L)
  expect_true(all(table(plan$boundary$ScenarioId) == 3L))
  expect_identical(
    unique(plan$boundary$StartId),
    c("variance_low", "default", "zero_nuisance")
  )
  expect_true(all(plan$boundary$BoundaryQuadrature == 1L))
  expect_true(all(plan$boundary$PathQuadrature == 121L))
  expect_true(all(plan$interior$NativeQuadrature == 61L))
  expect_true(all(plan$interior$CommonEvaluationQuadrature == 121L))
  expect_equal(zero$BoundaryNode, 0)
  expect_equal(zero$BoundaryWeight, 1)
  expect_true(zero$ConditionalLikelihoodContinuous)
  expect_true(zero$ConditionalLikelihoodBounded)
  expect_true(zero$ExactDegenerateLikelihood)
  expect_false(zero$NuisanceGlobalOptimumCertified)
  expect_false(zero$UpperVarianceBoundaryEvaluated)
  expect_false(zero$SelectionAuthorized)
  expect_false(zero$ConfirmationAuthorized)
})

test_that("P1c boundary envelope excludes nonstationary finite rows", {
  env <- gpcm_zb_p1c_environment()
  rows <- data.frame(
    ScenarioId = rep(c("A", "B"), each = 3L),
    StartId = rep(c("variance_low", "default", "zero_nuisance"), 2L),
    FitReturned = TRUE,
    ExistingBoundaryNuisancePass = c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE),
    BoundaryComparisonEligible = c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE),
    BoundaryObjective = c(10, 9, 11, 20, 19, 18),
    BoundaryOracleAbsDifference = 0,
    Q1LogSigma2InvarianceRange = 0,
    MaximumExpandedSlope = 4,
    ExpandedSlopeRatio = 8,
    stringsAsFactors = FALSE
  )
  out <- env$mfrmr_gzb_p1c_boundary_summary(rows)

  expect_identical(nrow(out), 2L)
  expect_identical(out$EligibleBoundaryStarts, c(2L, 0L))
  expect_identical(out$DiagnosticBoundaryEnvelopeStart, c("variance_low", NA))
  expect_equal(out$DiagnosticBoundaryEnvelopeObjective, c(10, NA))
  expect_equal(out$BoundaryObjectiveRangeAcrossEligibleStarts, c(1, NA))
  expect_true(all(out$ZeroVarianceLikelihoodLimitImplemented))
  expect_true(all(!out$NuisanceGlobalOptimumCertified))
  expect_true(all(!out$SelectionAuthorized))
  expect_true(all(!out$ConfirmationAuthorized))
})

test_that("P1c pairwise aggregation remains typed with a missing arm", {
  env <- gpcm_zb_p1c_environment()
  candidates <- list(
    `A::variance_low` = gpcm_zb_p1c_fake_boundary_candidate(
      "A", "variance_low", 10
    ),
    `A::default` = gpcm_zb_p1c_fake_boundary_candidate(
      "A", "default", 11, semantic = data.frame()
    ),
    `A::zero_nuisance` = gpcm_zb_p1c_fake_boundary_candidate(
      "A", "zero_nuisance", 12
    )
  )
  out <- env$mfrmr_gzb_p1c_boundary_pairwise(candidates)

  expect_identical(nrow(out), 3L)
  expect_true(all(out$BothBoundaryEligible))
  expect_identical(sum(out$MatchedNuisanceCoordinates > 0L), 1L)
  expect_identical(sum(is.na(out$NuisanceSemanticMaxAbsDifference)), 2L)
  expect_true(all(!out$SelectionAuthorized))
  expect_true(all(!out$ConfirmationAuthorized))
})

test_that("P1c decision fails closed without a qualified boundary fit", {
  env <- gpcm_zb_p1c_environment()
  boundary <- data.frame(
    ScenarioId = "A",
    EligibleBoundaryStarts = 0L,
    DiagnosticBoundaryEnvelopeObjective = NA_real_
  )
  interior <- data.frame(
    QuadPoints = 61L,
    CommonEvaluationQuadrature = 121L,
    P1BComparisonEligible = TRUE,
    CommonDenseObjective = 10
  )
  decision <- env$mfrmr_gzb_p1c_decision(boundary, interior, NULL)

  expect_true(decision$InteriorQualified)
  expect_false(decision$BoundaryQualified)
  expect_true(is.na(decision$BoundaryExactObjective))
  expect_true(is.na(decision$BoundarySmallestPathObjective))
  expect_identical(
    decision$NaturalVarianceDirection,
    "mixed_or_incomplete_one_sided_path"
  )
  expect_identical(decision$UpperVarianceJointPathStatus, "not_evaluated")
  expect_identical(
    decision$SourceSolutionDecision,
    "blocked_zero_profile_upper_joint_boundary_and_selection_rule_unresolved"
  )
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1c decision signatures preserve upstream blockers", {
  env <- gpcm_zb_p1c_environment()
  decision <- data.frame(
    BoundaryQualified = TRUE,
    InteriorQualified = TRUE,
    NaturalVarianceDirection =
      "negative_objective_derivative_toward_positive_variance_observed"
  )
  signature <- env$mfrmr_gzb_p1c_signature(decision)

  expect_identical(
    signature$State[signature$Metric == "zero_variance_likelihood_limit"],
    "implemented_exact_q1_and_direct_oracle"
  )
  expect_identical(
    signature$State[signature$Metric == "upper_joint_variance_boundary"],
    "not_evaluated"
  )
  expect_identical(
    signature$State[signature$Metric == "source_solution_selection"],
    "blocked"
  )
  expect_identical(signature$State[signature$Metric == "overall"], "review")
  changed <- signature
  changed$State[changed$Metric == "upper_joint_variance_boundary"] <- "pass"
  comparison <- env$mfrmr_gss_compare_signatures(signature, changed)
  expect_false(comparison$DecisionInvariant)
  expect_identical(
    comparison$ChangedMetrics,
    "upper_joint_variance_boundary"
  )
  expect_true(all(nzchar(signature$Reason)))
})

test_that("P1c full four-scenario boundary audit remains explicitly opt-in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the P1c boundary audit"
  )
  testthat::skip_on_cran()
  env <- gpcm_zb_p1c_environment()
  result <- env$mfrmr_run_gpcm_zero_variance_boundary_p1c()

  expect_identical(nrow(result$boundary_candidates), 12L)
  expect_identical(nrow(result$boundary_pairwise), 12L)
  expect_identical(nrow(result$natural_variance_paths), 132L)
  expect_identical(nrow(result$boundary_derivative_audit), 60L)
  expect_identical(nrow(result$interior_candidates), 4L)
  expect_identical(nrow(result$decisions), 4L)
  expect_identical(nrow(result$signature_comparisons), 2L)
  expect_true(result$zero_limit_contract$ExactDegenerateLikelihood)
  expect_true(all(result$boundary_candidates$FitReturned))
  expect_true(all(is.finite(
    result$boundary_candidates$BoundaryOracleAbsDifference
  )))
  expect_true(all(
    result$boundary_candidates$Q1LogSigma2InvarianceRange == 0
  ))
  expect_true(all(!result$boundary_candidates$BoundaryComparisonEligible))
  expect_true(all(result$interior_candidates$P1BComparisonEligible))
  expect_true(all(!result$decisions$BoundaryQualified))
  expect_true(all(result$signature_comparisons$DecisionInvariant))
  expect_identical(result$UpperVarianceJointPathStatus, "not_evaluated")
  expect_identical(result$SolutionToleranceStatus, "not_frozen")
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})
