gtheory_ademp_fit_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R",
      "gtheory-glmmtmb-parity-prototype-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R",
      "gtheory-ademp-generator-prototype-0.2.3.R",
      "gtheory-ademp-prefit-prototype-0.2.3.R",
      "gtheory-ademp-fit-prototype-0.2.3.R"
    )
  )
}

load_gtheory_ademp_fit <- function() {
  paths <- gtheory_ademp_fit_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  skip_if_not_installed("lme4")
  skip_if_not_installed("glmmTMB")
  skip_if_not_installed("TMB")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtd4_inputs <- function(env, scenario_id, method_id) {
  registry <- env$mfrmr_gtd_registry()
  generation <- env$mfrmr_gtd2_generate(
    registry, scenario_id, replicate = 1L
  )
  prefit <- env$mfrmr_gtd3_prefit_one(generation)
  row <- env$mfrmr_gtd_execution_manifest(registry)
  row <- row[
    row$ScenarioId == scenario_id & row$MethodId == method_id, , drop = FALSE
  ]
  row$GeneratorHash <- generation$GeneratorHash
  row$IncidenceAuditHash <- prefit$IncidenceAuditHash
  row$StructuralRankHash <- prefit$ScalableStructuralRankHash
  row$PreFitState <- prefit$PreFitState
  row$PreFitEligible <- prefit$PreFitEligible
  row$MethodEligibilityState <- if (prefit$PreFitEligible) {
    "eligible_adapter_pending_execution"
  } else prefit$PreFitState
  row$FitAttemptAuthorized <- FALSE
  row$AtomicResultRecorded <- FALSE
  list(
    Row = row, Generation = generation, PreFit = prefit
  )
}

test_that("Draft.83d2b1 local curvature distinguishes full and deficient", {
  env <- load_gtheory_ademp_fit()
  full <- env$mfrmr_gtd4_curvature(diag(c(2, 1)), 2L)
  deficient <- env$mfrmr_gtd4_curvature(diag(c(1, 0)), 2L)
  covariance <- env$mfrmr_gtd4_curvature(
    diag(c(0.5, 2)), 2L, matrix_is_covariance = TRUE
  )
  unavailable <- env$mfrmr_gtd4_curvature(NULL, 2L)

  expect_identical(full$CurvatureState, "positive_full_rank")
  expect_true(full$CurvatureRankFull)
  expect_identical(full$CurvatureRank, 2L)
  expect_identical(deficient$CurvatureState,
                   "nonpositive_or_rank_deficient")
  expect_false(deficient$CurvatureRankFull)
  expect_true(covariance$CurvatureRankFull)
  expect_equal(covariance$MinimumCurvatureEigenvalue, 0.5, tolerance = 1e-12)
  expect_identical(unavailable$CurvatureState, "unavailable")
})

test_that("Draft.83d2b1 records a blocked row without calling a backend", {
  env <- load_gtheory_ademp_fit()
  input <- gtd4_inputs(env, "GT-SPARSE-CYCLE-LOW", "lme4_reml")
  env$mfrmr_gtd4_fit_lme4 <- function(...) {
    stop("backend must not be called")
  }
  result <- env$mfrmr_gtd4_execute_one(
    input$Row, input$Generation, input$PreFit
  )

  expect_false(result$Row$FitAttemptAuthorized)
  expect_true(result$Row$AtomicResultRecorded)
  expect_false(result$Row$FitAttempted)
  expect_false(result$Row$FitReturned)
  expect_identical(result$Row$FailureStage, "pre_fit")
  expect_identical(
    result$Row$FailureCode,
    "blocked_structural_covariance_confounding"
  )
  expect_identical(result$Row$PointResultHash, "none")
})

test_that("Draft.83d2b1 retains finite negative raw MoM output", {
  env <- load_gtheory_ademp_fit()
  input <- gtd4_inputs(env, "GT-EXACT-N030", "balanced_mom")
  result <- env$mfrmr_gtd4_execute_one(
    input$Row, input$Generation, input$PreFit
  )

  expect_true(result$Row$FitAttempted)
  expect_true(result$Row$FitReturned)
  expect_true(result$Row$OptimizerConverged)
  expect_true(result$Row$ComponentVectorFinite)
  expect_true(result$Row$EstimationGatePassed)
  expect_identical(result$Row$FailureStage, "none")
  expect_true(any(result$Detail$Components$BoundaryState == "negative_raw"))
  expect_identical(
    result$Row$CurvatureState,
    "not_applicable_nonlikelihood_mom"
  )
})

test_that("Draft.83d2b1 interior lme4 and glmmTMB routes pass locally", {
  env <- load_gtheory_ademp_fit()
  for (method in c("lme4_reml", "glmmTMB_reml", "lme4_ml", "glmmTMB_ml")) {
    input <- gtd4_inputs(env, "GT-EXACT-N100", method)
    result <- env$mfrmr_gtd4_execute_one(
      input$Row, input$Generation, input$PreFit
    )
    expect_true(result$Row$FitAttempted, info = method)
    expect_true(result$Row$FitReturned, info = method)
    expect_true(result$Row$OptimizerConverged, info = method)
    expect_true(result$Row$ComponentVectorFinite, info = method)
    expect_true(result$Row$RegularInterior, info = method)
    expect_identical(result$Row$CurvatureState,
                     "positive_full_rank", info = method)
    expect_true(result$Row$EstimationGatePassed, info = method)
    expect_identical(result$Row$FailureStage, "none", info = method)
  }
})

test_that("Draft.83d2b1 executes all 89 units and retains false readiness", {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_GTHEORY_ADEMP_FIT_SMOKE"), "true"),
    "the 89-unit backend smoke is an explicit repository validation tier"
  )
  env <- load_gtheory_ademp_fit()
  result <- env$mfrmr_gtd4_execute_registry(progress = FALSE)
  near <- result$AtomicRows[
    result$AtomicRows$ScenarioId == "GT-BOUNDARY-NEARZERO", , drop = FALSE
  ]
  exact_zero <- result$AtomicRows[
    result$AtomicRows$ScenarioId == "GT-BOUNDARY-ZERO", , drop = FALSE
  ]

  expect_s3_class(result, "mfrmr_gtd4_execution")
  expect_equal(result$PlannedFitUnits, 89L)
  expect_equal(result$FitAttemptCount, 77L)
  expect_equal(result$FitReturnCount, 77L)
  expect_equal(result$PointGatePassCount, 57L)
  expect_equal(result$TypedFailureCount, 32L)
  expect_true(result$AtomicCompletionPassed)
  expect_false(result$ZeroFalseReadyPassed)
  expect_true(all(result$DenominatorSummary$ExactAccountingPassed))
  expect_equal(sum(result$AtomicRows$FailureStage == "pre_fit"), 12L)
  expect_equal(sum(result$AtomicRows$FailureStage == "regularity"), 15L)
  expect_equal(sum(result$AtomicRows$FailureStage == "local_curvature"), 5L)
  expect_equal(sum(near$EstimationGatePassed), 4L)
  expect_equal(sum(exact_zero$EstimationGatePassed), 0L)
  expect_identical(
    result$ExecutionHash,
    "1b0fa928f1aba1a9ac09bc3ec1c790f7fb94911a92cc6ea13ee7ad92d4884d49"
  )
  expect_false(result$RecoveryEvidenceReady)
  expect_false(result$InferenceReady)
  expect_false(result$CoefficientEligible)
  expect_false(result$DecisionReady)
})

test_that("Draft.83d2b1 fails closed on execution identity changes", {
  env <- load_gtheory_ademp_fit()
  input <- gtd4_inputs(env, "GT-EXACT-N100", "lme4_reml")
  bad <- input$Row
  bad$GeneratorHash <- paste(rep("0", 64L), collapse = "")

  expect_error(
    env$mfrmr_gtd4_execute_one(bad, input$Generation, input$PreFit),
    "identities differ"
  )
  expect_error(
    env$mfrmr_gtd4_execute_one(
      input$Row[0, , drop = FALSE], input$Generation, input$PreFit
    ),
    "requires one manifest row"
  )
  expect_error(
    env$mfrmr_gtd4_execute_registry(prefit_registry = list()),
    "must be a Draft.83d2b0"
  )
})
