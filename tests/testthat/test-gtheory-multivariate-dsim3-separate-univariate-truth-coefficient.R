gtheory_dsim3m_paths <- function() {
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
    )
  ))
}

load_gtheory_dsim3m <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3m_paths()
    skip_if_not(
      all(file.exists(paths)),
      "repository-internal D-SIM-3 truth coefficient adapter excluded"
    )
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3m_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) {
      manifest <<- environment$mfrmr_gtds3m_manifest()
    }
    manifest
  }
})

test_that("truth coefficient contract binds truth and allocation parents", {
  env <- load_gtheory_dsim3m()
  contract <- env$mfrmr_gtds3m_contract()
  manifest <- gtheory_dsim3m_manifest(env)
  expect_invisible(env$mfrmr_gtds3m_validate_contract(contract))
  expect_invisible(env$mfrmr_gtds3m_assert_manifest(manifest))
  expect_identical(
    contract$ContractHash,
    "d73dd72c8bc849597dd68342a3608b1f34b315e7f1fd1ad52a87a9e26d963cb8"
  )
  expect_identical(
    manifest$ManifestHash,
    "969afca1d3fb23a68d58500cd6959152b385b0e9b2e64c25cc75a3cd79feb37c"
  )
  expect_identical(
    manifest$ParentTruthManifestHash,
    "97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5"
  )
  expect_identical(
    manifest$ParentOperatorManifestHash,
    "526298d0c598e34a92e98b96b7bc59c0714fc053636bc25ea423d4c87c895093"
  )
})

test_that("a hand-computed stratum fixes relative and absolute formulas", {
  env <- load_gtheory_dsim3m()
  contributions <- data.frame(
    ScenarioId = "hand",
    StratumOrdinal = 1L,
    Stratum = "S",
    TargetComponentId =
      c("Object", "Rater", "Object:Rater", "Residual"),
    UniverseRole =
      c("object", "absolute_only", "relative_error", "relative_error"),
    FitRepresentationGroup =
      c("object", "separate_Rater", "separate_Object:Rater",
        "separate_Residual"),
    AllocatedVariance = c(1.2, 0.3 / 2, 0.4 / 2, 0.5 / 4),
    stringsAsFactors = FALSE
  )
  result <- env$mfrmr_gtds3m_coefficients_from_contributions(contributions)
  relative <- 0.4 / 2 + 0.5 / 4
  absolute <- relative + 0.3 / 2
  expect_equal(result$UniverseVariance, 1.2, tolerance = 1e-14)
  expect_equal(result$RelativeErrorVariance, relative, tolerance = 1e-14)
  expect_equal(result$AbsoluteErrorVariance, absolute, tolerance = 1e-14)
  expect_equal(result$G, 1.2 / (1.2 + relative), tolerance = 1e-14)
  expect_equal(result$Phi, 1.2 / (1.2 + absolute), tolerance = 1e-14)
  expect_true(result$TruthCoefficientReady)
})

test_that("all profile and stratum truth denominators are complete", {
  env <- load_gtheory_dsim3m()
  manifest <- gtheory_dsim3m_manifest(env)
  summary <- manifest$Summary
  expect_identical(summary$ProfileCount, 21L)
  expect_identical(summary$QualifiedProfileCount, 21L)
  expect_identical(summary$StratumCoefficientCount, 47L)
  expect_identical(summary$QualifiedStratumCoefficientCount, 47L)
  expect_identical(summary$CrossedStratumCoefficientCount, 32L)
  expect_identical(summary$NestedStratumCoefficientCount, 15L)
  expect_identical(summary$ComponentContributionCount, 173L)
  expect_identical(summary$FitRepresentationBlockCount, 160L)
  expect_identical(summary$OneRepeatStratumCoefficientCount, 13L)
  expect_identical(summary$ScalarOracleComparisonCount, 235L)
  expect_identical(summary$ScalarOracleQualifiedComparisonCount, 235L)
})

test_that("the independent scalar oracle reproduces every truth metric", {
  env <- load_gtheory_dsim3m()
  manifest <- gtheory_dsim3m_manifest(env)
  comparisons <- manifest$ScalarOracleComparisonRegistry
  oracle <- manifest$IndependentScalarOracleRegistry
  expect_true(all(comparisons$OraclePassed))
  expect_lte(max(comparisons$AbsoluteError), 1e-10)
  metric_counts <- table(comparisons$MetricId)
  expect_identical(as.integer(metric_counts), rep(47L, 5L))
  expect_setequal(names(metric_counts), c(
    "UniverseVariance", "RelativeErrorVariance",
    "AbsoluteErrorVariance", "G", "Phi"
  ))
  expect_false(any(oracle$OperatorImplementationUsed))
  expect_false(any(oracle$PostMissingnessCountUsed))
})

test_that("nested and crossed estimand relations follow the frozen roles", {
  env <- load_gtheory_dsim3m()
  coefficients <- gtheory_dsim3m_manifest(env)$
    StratumTruthCoefficientRegistry
  nested <- coefficients$Crossing == "nested"
  crossed <- !nested
  expect_equal(coefficients$Phi[nested], coefficients$G[nested],
               tolerance = 1e-10)
  expect_true(all(coefficients$Phi[crossed] < coefficients$G[crossed]))
  expect_true(all(coefficients$PhiNotGreaterThanG))
  expect_true(all(coefficients$AbsoluteErrorVariance >=
                    coefficients$RelativeErrorVariance))
})

test_that("anchor profile has the hand-derived allocation truth", {
  env <- load_gtheory_dsim3m()
  coefficients <- gtheory_dsim3m_manifest(env)$
    StratumTruthCoefficientRegistry
  anchor <- coefficients[coefficients$ScenarioId == "D3-S001", ]
  relative <- 0.35 / 4 + 0.50 / (4 * 2)
  absolute <- relative + 0.20 / 4
  expect_true(nrow(anchor) == 2L)
  expect_equal(anchor$UniverseVariance, rep(1, 2L), tolerance = 1e-12)
  expect_equal(anchor$RelativeErrorVariance, rep(relative, 2L),
               tolerance = 1e-12)
  expect_equal(anchor$AbsoluteErrorVariance, rep(absolute, 2L),
               tolerance = 1e-12)
  expect_equal(anchor$G, rep(1 / (1 + relative), 2L),
               tolerance = 1e-12)
  expect_equal(anchor$Phi, rep(1 / (1 + absolute), 2L),
               tolerance = 1e-12)
})

test_that("metric invariances and one-repeat fit blocks are qualified", {
  env <- load_gtheory_dsim3m()
  manifest <- gtheory_dsim3m_manifest(env)
  profiles <- manifest$ProfileTruthMetricRegistry
  blocks <- manifest$FitRepresentationBlockRegistry
  combined <- blocks$FitRepresentationGroup ==
    manifest$Contract$OneRepeatFitRepresentation
  expect_true(all(profiles$ComponentAndStratumOrderInvariant))
  expect_true(all(profiles$CommonPositiveScaleInvariant))
  expect_true(all(profiles$OffDiagonalPerturbationInvariant))
  expect_true(all(profiles$FitRepresentationQualified))
  expect_identical(sum(combined), 13L)
  expect_true(all(blocks$ComponentCount[combined] == 2L))
  expect_true(all(grepl("Residual", blocks$TargetComponentIds[combined],
                        fixed = TRUE)))
})

test_that("truth metric qualification does not open fitted execution", {
  env <- load_gtheory_dsim3m()
  manifest <- gtheory_dsim3m_manifest(env)
  expect_identical(
    manifest$ReadinessGateRegistry$GatePassed,
    c(rep(TRUE, 8L), FALSE, FALSE)
  )
  expect_true(all(manifest$OpenGapRegistry$GapOpen))
  expect_identical(
    manifest$Summary$CurrentDisposition,
    "separate_univariate_truth_metric_qualified_plan_and_worker_required"
  )
  expect_true(manifest$Summary$TruthCoefficientComputed)
  expect_false(manifest$Summary$FittedCoefficientComputed)
  expect_false(manifest$Summary$Planned855RngStreamOpened)
  expect_false(manifest$Summary$ResponseInspected)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitReturned)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})
