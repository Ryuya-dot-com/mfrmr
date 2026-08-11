gtheory_glmmtmb_stationarity_reference_paths <- function() {
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
      "gtheory-ademp-fit-prototype-0.2.3.R",
      "gtheory-weak-information-calibration-prototype-0.2.3.R",
      "gtheory-weak-information-pilot-prototype-0.2.3.R",
      "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stationarity-instrumentation-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stationarity-calibration-design-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stationarity-reference-calibration-0.2.3.R"
    )
  )
}

load_gtheory_glmmtmb_stationarity_reference <- function() {
  paths <- gtheory_glmmtmb_stationarity_reference_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c("digest", "lme4", "glmmTMB", "TMB", "numDeriv")) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("b1g6 tolerances derive from binary64 error scales", {
  env <- load_gtheory_glmmtmb_stationarity_reference()
  policy <- env$mfrmr_gtwta_tolerance_policy()
  epsilon <- .Machine$double.eps

  expect_equal(policy$CentralDifferenceBalancingScale, epsilon^(1 / 3))
  expect_equal(policy$CentralDifferenceErrorScale, epsilon^(2 / 3))
  expect_equal(
    policy$DerivativeRelativeTolerance, 2^12 * epsilon^(2 / 3)
  )
  expect_identical(policy$DerivativeStepExponents, -4L:8L)
  expect_identical(policy$DerivativeStabilityMultiplier, 4)
  expect_false(policy$DerivativeStepSelectionUsesAutomaticGradient)
  expect_true(policy$DerivativeResolutionIsComponentwise)
  expect_equal(
    policy$ObjectiveConsensusRelativeTolerance,
    2^8 * epsilon^(2 / 3)
  )
  expect_equal(policy$NewtonDecrementTolerance, 2^10 * sqrt(epsilon))
  expect_true(policy$ToleranceContractFrozen)
  expect_false(policy$CandidateCutoffUse)
  expect_false(policy$Lme4DefaultCutoffUse)
})

test_that("finite-difference step selection is independent of the AD gradient", {
  env <- load_gtheory_glmmtmb_stationarity_reference()
  policy <- env$mfrmr_gtwta_tolerance_policy()
  fn <- function(parameter) env$mfrmr_gtwta_analytic_eval(
    "pd_quadratic", parameter
  )$Objective
  gr <- function(parameter) env$mfrmr_gtwta_analytic_eval(
    "pd_quadratic", parameter
  )$Gradient
  parameter <- c(1, -2, 0.5)
  correct <- env$mfrmr_gtwta_derivative_audit(fn, gr, parameter, policy)
  incorrect <- env$mfrmr_gtwta_derivative_audit(
    fn, function(value) gr(value) + c(1e-3, 0, 0), parameter, policy
  )

  expect_true(correct$DerivativeAgreementPassed)
  expect_false(incorrect$DerivativeAgreementPassed)
  expect_identical(correct$SelectedStepIndex, incorrect$SelectedStepIndex)
  expect_identical(
    correct$CentralDifferenceGradients,
    incorrect$CentralDifferenceGradients
  )
  expect_false(correct$StepSelectionUsesAutomaticGradient)
  expect_length(correct$FiniteDifferenceResolution, length(parameter))
  expect_true(correct$HessianSymmetryPassed)
})

test_that("the TMB random-start anchor removes evaluation-order dependence", {
  env <- load_gtheory_glmmtmb_stationarity_reference()
  state <- new.env(parent = emptyenv())
  state$last.par.best <- c(0, 0, 0)
  state$random <- 2L
  state$random.start <- expression(last.par.best[random])
  state$inner.method <- "newton"
  state$inner.control <- list(maxit = 1000, trace = FALSE)
  fn <- function(parameter) {
    value <- sum(parameter^2) + state$last.par.best[[2L]]
    state$last.par.best <- c(parameter[[1L]],
                             state$last.par.best[[2L]] + 1,
                             parameter[[2L]])
    value
  }
  gr <- function(parameter) {
    state$last.par.best <- c(parameter[[1L]],
                             state$last.par.best[[2L]] + 1,
                             parameter[[2L]])
    2 * parameter
  }
  fit <- list(
    obj = list(fn = fn, gr = gr, env = state),
    fit = list(par = c(1, 2))
  )
  objective <- env$mfrmr_gtwta_anchored_objective(fit)
  first <- objective$Fn(c(2, 3))
  objective$Fn(c(4, 5))
  second <- objective$Fn(c(2, 3))

  expect_identical(first, second)
  expect_equal(objective$Gr(c(2, 3)), c(4, 6))
  expect_true(objective$ResetBeforeEveryObjectiveEvaluation)
  expect_true(objective$ResetBeforeEveryGradientEvaluation)
  expect_identical(objective$RandomEffectDimension, 1L)
  expect_identical(objective$InnerMethod, "newton")
  expect_identical(objective$InnerControl,
                   list(maxit = 1000, trace = FALSE))
})

test_that("analytic references recover minima flat saddle and boundary states", {
  env <- load_gtheory_glmmtmb_stationarity_reference()
  audit <- env$mfrmr_gtwta_analytic_audit()

  expect_identical(audit$AnalyticFixtureCount, 6L)
  expect_true(audit$DerivativeAgreementReady)
  expect_true(audit$AnalyticStateRecoveryReady)
  expect_true(all(audit$Rows$DerivativeAgreementPassed))
  expect_true(all(audit$Rows$StateMatched))
  expect_setequal(
    audit$Rows$ObservedState,
    c(
      "finite_local_minimum", "finite_stationary_flat",
      "finite_saddle_or_max", "boundary_limit"
    )
  )
})

test_that("the deterministic reference ladder solves a nonlinear minimum", {
  env <- load_gtheory_glmmtmb_stationarity_reference()
  fn <- function(parameter) env$mfrmr_gtwta_analytic_eval(
    "rosenbrock_minimum", parameter
  )$Objective
  gr <- function(parameter) env$mfrmr_gtwta_analytic_eval(
    "rosenbrock_minimum", parameter
  )$Gradient
  reference <- env$mfrmr_gtwta_reference(fn, gr, c(-1.2, 1))

  expect_identical(reference$State, "finite_local_minimum")
  expect_true(reference$ConsensusPassed)
  expect_true(reference$DerivativeAgreementPassed)
  expect_lte(reference$NewtonDecrement,
             env$mfrmr_gtwta_tolerance_policy()$NewtonDecrementTolerance)
  expect_equal(reference$PolishedObjective, 0, tolerance = 1e-10)
  expect_equal(nrow(reference$Rows), 9L)
  expect_true(all(reference$Rows$Returned))
})

test_that("b1g6 manifest cannot collide with reserved phase bands", {
  env <- load_gtheory_glmmtmb_stationarity_reference()
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  contract <- env$mfrmr_gtwta_contract(design)
  manifest <- env$mfrmr_gtwta_manifest(contract)

  expect_true(contract$AnalyticReferenceReady)
  expect_true(contract$ReferenceToleranceContractFrozen)
  expect_true(contract$NonreservedReplayAuthorized)
  expect_false(contract$ReferenceToleranceFrozen)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_setequal(manifest$Rows$Replicate, c(901L, 902L))
  expect_false(any(manifest$Rows$Replicate %in% contract$ReservedReplicates))
  expect_identical(manifest$DatasetCount, 2L)
  expect_identical(manifest$ObjectiveCount, 4L)
  expect_identical(manifest$PlannedSolverRunCount, 36L)
  expect_true(manifest$ExecutionAuthorized)
  expect_false(manifest$CalibrationUse)
  expect_false(manifest$DataGenerated)
  expect_false(manifest$ResultsViewed)
  expect_identical(
    contract$ContractHash,
    "60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a"
  )
  expect_identical(
    manifest$ManifestHash,
    "87b42667d3dbeb2ecd045b23b32cf23a5f9919b0d26ac75c5771baf691770d3a"
  )
})

test_that("the retained nonreserved b1g6 replay validates when available", {
  path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwta-reference-replay-v4.rds"
  )
  skip_if_not(file.exists(path), "retained b1g6 replay is unavailable")
  env <- load_gtheory_glmmtmb_stationarity_reference()
  execution <- readRDS(path)

  expect_true(env$mfrmr_gtwta_execution_hash_valid(execution))
  expect_identical(
    execution$ExecutionHash,
    "28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72"
  )
  expect_true(execution$ExactAccountingPassed)
  expect_identical(execution$FitReturnCount, 4L)
  expect_identical(execution$ReferenceResolvedCount, 4L)
  expect_identical(execution$ConsensusPassCount, 4L)
  expect_identical(execution$DerivativeAgreementPassCount, 4L)
  expect_true(execution$SidecarValidationPassed)
  expect_true(execution$NonreservedReplayReady)
  expect_true(execution$ReferenceToleranceFrozen)
  expect_true(all(vapply(execution$Sidecars, function(sidecar) {
    identical(sidecar$InnerMethod, "newton") &&
      identical(sidecar$InnerControl, list(maxit = 1000, trace = FALSE)) &&
      identical(sidecar$RandomStartExpression,
                "expression(last.par.best[random])")
  }, logical(1L))))
  expect_true(all(vapply(execution$Sidecars, function(sidecar) {
    all(sidecar$Reference$DerivativeComponentPassed) &&
      isTRUE(sidecar$Reference$HessianSymmetryPassed) &&
      !isTRUE(sidecar$Reference$StepSelectionUsesAutomaticGradient)
  }, logical(1L))))
  full_sidecars <- execution$Sidecars[c(1L, 3L)]
  expect_true(all(vapply(full_sidecars, function(sidecar) {
    all(sidecar$BoundaryProfile$NuisanceStationarityPassed)
  }, logical(1L))))
  expect_false(execution$StationarityThresholdFrozen)
  expect_false(execution$CalibrationExecutionAuthorized)
  expect_false(execution$CalibrationDataGenerated)
  expect_false(execution$FullExecutionAuthorized)
  expect_false(execution$InferenceReady)
  expect_false(execution$DecisionReady)

  changed <- execution
  changed$Rows$PolishedObjective[[1L]] <-
    changed$Rows$PolishedObjective[[1L]] + 1e-3
  expect_false(env$mfrmr_gtwta_execution_hash_valid(changed))
})
