gtheory_dsim3w_paths <- function() {
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
    "gtheory-multivariate-dsim3-fit-metric-worker-0.2.4.R"
  ))
}

load_gtheory_dsim3w <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3w_paths()
    skip_if_not(
      all(file.exists(paths)),
      "repository-internal D-SIM-3 fit/metric worker excluded"
    )
    skip_if_not_installed("digest")
    skip_if_not_installed("lme4")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3w_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) manifest <<- environment$mfrmr_gtds3w_manifest()
    manifest
  }
})

test_that("fit/metric worker freezes six design-dependent formula classes", {
  env <- load_gtheory_dsim3w()
  contract <- env$mfrmr_gtds3w_contract()
  expect_invisible(env$mfrmr_gtds3w_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "9e5055fc47191f4426507c352b45b72a2a40256bd227dcf464d04e7058de44c7"
  )
  expect_identical(nrow(contract$FormulaRegistry), 6L)
  expect_identical(
    sum(contract$FormulaRegistry$RouteId == "separate_univariate"), 4L
  )
  expect_identical(
    sum(contract$FormulaRegistry$RouteId ==
          "multivariate_lme4_restricted"), 2L
  )
  expect_false(contract$ScalarPoolingAcrossStrataAllowed)
  expect_false(contract$PackageSelectedDecisionWeightsAllowed)
  expect_false(contract$CrossStratumCovarianceUsedInCoefficient)
  expect_false(contract$DiagnosticOverrideAllowed)
  expect_false(contract$Planned856RngStreamMayOpen)
})

test_that("restricted multivariate formula keeps unstructured stratum coefficients", {
  env <- load_gtheory_dsim3w()
  registry <- env$mfrmr_gtds3w_contract()$FormulaRegistry
  formula <- registry$FormulaCanonical[
    registry$ModelSpecificationId ==
      "multivariate_lme4_restricted::crossed::separate_error"
  ]
  data <- expand.grid(
    ObjectId = factor(paste0("O", 1:4)),
    ConditionId = factor(paste0("C", 1:3)),
    Stratum = factor(paste0("S", 1:3)),
    Replicate = 1:2
  )
  data$ObjectConditionId <- interaction(
    data$ObjectId, data$ConditionId, drop = TRUE
  )
  data$Score <- seq_len(nrow(data))

  random <- lme4::lFormula(stats::as.formula(formula), data = data)$reTrms
  columns <- colnames(stats::model.matrix(~ 0 + Stratum, data = data))

  expect_setequal(
    names(random$cnms),
    c("ObjectId", "ConditionId", "ObjectConditionId")
  )
  expect_true(all(vapply(random$cnms, identical, logical(1), columns)))
  expect_true(all(vapply(
    random$reCovs, inherits, logical(1), "Covariance.us"
  )))
  expect_length(
    random$theta,
    length(random$cnms) * length(columns) * (length(columns) + 1L) / 2L
  )
})

test_that("all shadow templates fit and cover every exact request", {
  env <- load_gtheory_dsim3w()
  set.seed(240831L)
  caller_state <- .Random.seed
  manifest <- gtheory_dsim3w_manifest(env)
  expect_identical(.Random.seed, caller_state)
  expect_invisible(env$mfrmr_gtds3w_assert_manifest(manifest))
  expect_identical(
    manifest$ManifestHash,
    "566faa25b496f32137fc167cc26b37f172e5fe2b2be73b78a22517e9d1213eb1"
  )
  summary <- manifest$Summary
  expect_identical(
    unname(unlist(summary[c(
      "ScenarioCount", "TemplateRouteCount", "SeparateTemplateCount",
      "MultivariateTemplateCount", "FormulaClassCount", "FitCallCount",
      "SuccessfulFitCallCount", "CoefficientRowCount",
      "ReadyCoefficientRowCount", "TemplateMetricVectorCount",
      "CompleteTemplateMetricVectorCount", "BackendRequestCoverageCount",
      "QualifiedBackendRequestCoverageCount", "MetricRequestCoverageCount",
      "QualifiedMetricRequestCoverageCount",
      "DuplicateReplicateFitCountAvoided"
    )])),
    c(21L, 25L, 21L, 4L, 6L, 51L, 51L, 57L, 57L, 50L, 50L,
      50L, 50L, 100L, 100L, 25L)
  )
  expect_identical(summary$SingularFitCallCount, 12L)
  expect_identical(summary$FitCallWithConvergenceMessageCount, 12L)
  expect_identical(summary$FitCallWithWarningCount, 0L)
  expect_identical(
    c(summary$ShadowRngStreamMinimum, summary$ShadowRngStreamMaximum),
    c(854100001L, 854100021L)
  )
  expect_true(summary$FitMetricWorkerShadowQualified)
  expect_false(summary$TerminalResourceOrchestratorQualified)
  expect_false(summary$LaunchReadinessReconciled)
})

test_that("worker returns complete nonpooled vectors and retains diagnostics", {
  env <- load_gtheory_dsim3w()
  manifest <- gtheory_dsim3w_manifest(env)
  fits <- manifest$FitReceiptRegistry
  coefficients <- manifest$FittedCoefficientRegistry
  metrics <- manifest$TemplateMetricVectorRegistry
  expect_true(all(!fits$DiagnosticOverrideApplied))
  expect_true(all(!fits$CountsAsExploratoryAttempt))
  expect_identical(sum(fits$Singular), 12L)
  expect_true(all(coefficients$CoefficientReady))
  expect_true(all(coefficients$PhiNotGreaterThanG))
  expect_true(all(!coefficients$ScalarPoolingApplied))
  expect_true(all(!coefficients$CrossStratumCovarianceUsed))
  expect_true(all(table(metrics$TemplateId) == 2L))
  expect_true(all(metrics$AllStrataReturned))
  expect_true(all(!metrics$ScalarPoolingApplied))
  expect_true(all(!manifest$BackendRequestCoverageRegistry$
                  CountsAsExploratoryAttempt))
  expect_true(all(!manifest$MetricRequestCoverageRegistry$
                  CountsAsRecoveryEvidence))
})

test_that("worker evidence rejects metric and execution-boundary tampering", {
  env <- load_gtheory_dsim3w()
  manifest <- gtheory_dsim3w_manifest(env)
  changed <- manifest
  changed$FittedCoefficientRegistry$ScalarPoolingApplied[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtds3w_assert_manifest(changed),
    "worker evidence was altered"
  )
  changed <- manifest
  changed$Summary$Planned856RngStreamOpened <- TRUE
  expect_error(
    env$mfrmr_gtds3w_assert_manifest(changed),
    "worker evidence was altered"
  )
})
