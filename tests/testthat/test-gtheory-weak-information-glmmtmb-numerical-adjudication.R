gtheory_glmmtmb_numerical_adjudication_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
      "gtheory-weak-information-glmmtmb-numerical-adjudication-0.2.3.R"
    )
  )
}

load_gtheory_glmmtmb_numerical_adjudication <- function() {
  paths <- gtheory_glmmtmb_numerical_adjudication_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c("digest", "glmmTMB", "TMB", "numDeriv")) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_glmmtmb_numerical_adjudication_rows <- function() {
  profiles <- c(
    "glmmTMB_cold_nlminb",
    "glmmTMB_restart_nlminb_from_nlminb",
    "glmmTMB_warm_bfgs_from_nlminb", "glmmTMB_cold_bfgs",
    "glmmTMB_restart_bfgs_from_bfgs", "glmmTMB_warm_nlminb_from_bfgs"
  )
  route <- rep(sprintf("synthetic-route-%02d", seq_len(20L)), each = 6L)
  profile <- rep(profiles, times = 20L)
  full_objective <- rep(c(100, 99.9, 99.8, 100.1, 99.7, 99.85), 20L)
  reduced_objective <- rep(c(101, 100.9, 100.8, 101.1, 100.7, 100.85), 20L)
  data.frame(
    StabilizationRouteId = paste(route, profile, sep = "::"),
    RouteId = route, DatasetId = sub("route", "dataset", route),
    DesignId = rep(sprintf("design-%02d", rep(seq_len(10L), each = 12L)),
                   length.out = 120L),
    VarianceId = rep(c("exact_zero", "reference_1200"), each = 60L),
    MethodId = rep(rep(c("glmmTMB_ml", "glmmTMB_reml"), each = 6L), 10L),
    Likelihood = rep(rep(c("ML", "REML"), each = 6L), 10L),
    ProfileId = profile, PairReturned = TRUE, FullReturned = TRUE,
    ReducedReturned = TRUE, SameRows = TRUE,
    LikelihoodDfDifference = 1L, FullOptimizerCode = 0L,
    ReducedOptimizerCode = 0L, FullObjective = full_objective,
    ReducedObjective = reduced_objective,
    FullLogLikelihood = -full_objective,
    ReducedLogLikelihood = -reduced_objective,
    RawLikelihoodDrop = 2 * (-full_objective + reduced_objective),
    FullSdreportPositiveDefiniteHessian = TRUE,
    ReducedSdreportPositiveDefiniteHessian = TRUE,
    FullRichardsonAvailable = TRUE, ReducedRichardsonAvailable = TRUE,
    FullRichardsonPositiveDefinite = TRUE,
    ReducedRichardsonPositiveDefinite = TRUE,
    FullOuterGradientAvailable = TRUE, ReducedOuterGradientAvailable = TRUE,
    FullSdGradientAvailable = TRUE, ReducedSdGradientAvailable = TRUE,
    FullOuterGradientHash = "full-gradient",
    ReducedOuterGradientHash = "reduced-gradient",
    FullSdGradientHash = "full-gradient",
    ReducedSdGradientHash = "reduced-gradient",
    FullOuterGradientMaximumAbsolute = 1e-4,
    ReducedOuterGradientMaximumAbsolute = 2e-4,
    FullSdGradientMaximumAbsolute = 1e-4,
    ReducedSdGradientMaximumAbsolute = 2e-4,
    stringsAsFactors = FALSE
  )
}

test_that("multi-axis helpers do not collapse numerical meanings", {
  env <- load_gtheory_glmmtmb_numerical_adjudication()

  expect_identical(env$mfrmr_gtwsx_optimizer_state(0L, 0L),
                   "both_reported_success")
  expect_identical(env$mfrmr_gtwsx_optimizer_state(1L, 0L),
                   "full_nonzero")
  expect_identical(env$mfrmr_gtwsx_objective_state(1, 2), "both_finite")
  expect_identical(env$mfrmr_gtwsx_objective_state(Inf, 2),
                   "full_nonfinite")
  expect_identical(
    env$mfrmr_gtwsx_reported_state(NA_real_, -2, 1, 2, FALSE, TRUE),
    "full_curvature_masked"
  )
  expect_identical(
    env$mfrmr_gtwsx_reported_state(NA_real_, -2, 1, 2, TRUE, TRUE),
    "unexplained_nonfinite"
  )
  expect_identical(
    env$mfrmr_gtwsx_curvature_state(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
    "both_pd_agree"
  )
  expect_identical(
    env$mfrmr_gtwsx_curvature_state(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE),
    "diagnostic_disagreement"
  )
  expect_identical(env$mfrmr_gtwsx_order_state(-2e-6, 1e-6),
                   "material_negative")
  expect_identical(env$mfrmr_gtwsx_order_state(-2e-7, 1e-6),
                   "small_negative")
  expect_identical(env$mfrmr_gtwsx_order_state(0, 1e-6), "exact_zero")
  expect_identical(env$mfrmr_gtwsx_order_state(2e-7, 1e-6), "positive")
})

test_that("stored ledgers yield 120 independent axes and 20 envelopes", {
  env <- load_gtheory_glmmtmb_numerical_adjudication()
  source <- gtheory_glmmtmb_numerical_adjudication_rows()
  contract <- list(
    AdjudicationContractHash = "synthetic-contract",
    DescriptiveNegativeTolerance = 1e-6,
    ProfileOrder = unique(source$ProfileId)
  )
  atomic <- env$mfrmr_gtwsx_atomic_rows(source, contract)
  envelopes <- env$mfrmr_gtwsx_envelopes(source, atomic, contract)
  summaries <- env$mfrmr_gtwsx_summaries(atomic, envelopes)

  expect_equal(nrow(atomic), 120L)
  expect_equal(nrow(envelopes), 20L)
  expect_true(all(atomic$OptimizerState == "both_reported_success"))
  expect_true(all(atomic$ObjectiveState == "both_finite"))
  expect_true(all(atomic$ReportedLikelihoodState == "both_reported"))
  expect_true(all(atomic$CurvatureState == "both_pd_agree"))
  expect_true(all(atomic$StationarityState == "not_calibrated"))
  expect_true(all(!atomic$PairDecisionEligible))
  expect_true(all(envelopes$EnvelopeType == "best_observed_six_profile"))
  expect_true(all(!envelopes$GlobalOptimumClaim))
  expect_false(summaries$StationarityThresholdFrozen)
  expect_false(summaries$ThresholdSelected)
  expect_false(summaries$OptimizerSelected)

  masked <- source
  masked$FullLogLikelihood[[1L]] <- NA_real_
  masked$FullSdreportPositiveDefiniteHessian[[1L]] <- FALSE
  masked$FullRichardsonPositiveDefinite[[1L]] <- FALSE
  masked_atomic <- env$mfrmr_gtwsx_atomic_rows(masked, contract)
  expect_identical(masked_atomic$ReportedLikelihoodState[[1L]],
                   "full_curvature_masked")
  expect_identical(masked_atomic$CurvatureState[[1L]],
                   "reduced_only_pd_agree")

  unexplained <- masked
  unexplained$FullSdreportPositiveDefiniteHessian[[1L]] <- TRUE
  unexplained$FullRichardsonPositiveDefinite[[1L]] <- TRUE
  unexplained_atomic <- env$mfrmr_gtwsx_atomic_rows(unexplained, contract)
  expect_identical(unexplained_atomic$ReportedLikelihoodState[[1L]],
                   "unexplained_nonfinite")

  expect_error(
    env$mfrmr_gtwsx_envelopes(
      source[-1L, , drop = FALSE], atomic[-1L, , drop = FALSE], contract
    ),
    "exact six frozen profiles"
  )
})

test_that("upstream scientific hashes reject ledger mutation", {
  env <- load_gtheory_glmmtmb_numerical_adjudication()
  identity <- list(
    Contract = "x", RunnerContractHash = "x",
    UpstreamRunnerContractHash = "x", UpstreamExecutionHash = "x",
    UnderlyingExecutionHash = "x", StabilizationContractHash = "x",
    StabilizationManifestHash = "x", AtomicRows = data.frame(x = 1),
    BaseRouteCheckpointHashes = "x", DatasetMarkerHashes = "x",
    Summaries = list(x = 1), AlignmentSummary = list(x = 1)
  )
  execution <- c(identity, list(ExecutionHash = env$mfrmr_gta_hash(identity)))
  expect_true(env$mfrmr_gtwsx_alignment_execution_hash_valid(execution))
  execution$AtomicRows$x[[1L]] <- 2
  expect_false(env$mfrmr_gtwsx_alignment_execution_hash_valid(execution))

  comparison_identity <- list(
    Contract = "x", UpstreamExecutionHash = "x",
    AlignmentExecutionHash = "x", PairedRows = data.frame(x = 1),
    Summary = list(x = 1)
  )
  comparison <- c(comparison_identity, list(
    ComparisonHash = env$mfrmr_gta_hash(comparison_identity)
  ))
  expect_true(env$mfrmr_gtwsx_comparison_hash_valid(comparison))
  comparison$PairedRows$x[[1L]] <- 2
  expect_false(env$mfrmr_gtwsx_comparison_hash_valid(comparison))
})

test_that("exact b1g2 ledger reproduces the b1g3 adjudication", {
  skip_if_not(identical(
    tolower(Sys.getenv("MFRMR_RUN_GTHEORY_GLMMTMB_NUMERICAL_ADJUDICATION",
                       "false")), "true"
  ), "set MFRMR_RUN_GTHEORY_GLMMTMB_NUMERICAL_ADJUDICATION=true")
  env <- load_gtheory_glmmtmb_numerical_adjudication()
  design_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_STABILIZATION_DESIGN_RDS",
    "/private/tmp/mfrmr-gtwst-design-v2.rds"
  )
  alignment_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_ALIGNMENT_SMOKE_RDS",
    "/private/tmp/mfrmr-gtwsw-smoke-v1.rds"
  )
  comparison_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_ALIGNMENT_COMPARISON_RDS",
    "/private/tmp/mfrmr-gtwsw-comparison-v1.rds"
  )
  result_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_NUMERICAL_ADJUDICATION_RDS",
    "/private/tmp/mfrmr-gtwsx-adjudication-v1.rds"
  )
  skip_if_not(all(file.exists(c(
    design_path, alignment_path, comparison_path, result_path
  ))), "exact design, alignment, comparison, or adjudication is unavailable")
  design <- readRDS(design_path)
  alignment <- readRDS(alignment_path)
  comparison <- readRDS(comparison_path)
  retained <- readRDS(result_path)
  alignment_contract <- structure(list(
    RunnerContractHash =
      "7632a74709576c78d4e89b9fd015952dbde5be98313b99ed380af7c5436e1177",
    Profiles = design$Contract$Profiles,
    NegativeLikelihoodTolerance = 1e-6
  ), class = "mfrmr_gtwsw_contract")
  contract <- env$mfrmr_gtwsx_contract(
    alignment_contract, alignment, comparison
  )
  result <- env$mfrmr_gtwsx_adjudicate(contract, alignment)

  expect_identical(
    contract$AdjudicationContractHash,
    "934f96be6e23cd728576cfedbb44d48b68137fbbc74e84d19d7200b8ad52ccc0"
  )
  expect_identical(result$ResultHash, retained$ResultHash)
  expect_identical(result$AtomicRows, retained$AtomicRows)
  expect_identical(result$EnvelopeRows, retained$EnvelopeRows)
  expect_true(result$ExactAccountingPassed)
  expect_equal(result$PairCount, 120L)
  expect_equal(result$EnvelopeCount, 20L)
  expect_equal(unname(result$Summaries$OptimizerStateCounts[
    "both_reported_success"
  ]), 119L)
  expect_equal(unname(result$Summaries$OptimizerStateCounts[
    "full_nonzero"
  ]), 1L)
  expect_equal(unname(result$Summaries$ObjectiveStateCounts[
    "both_finite"
  ]), 120L)
  expect_equal(unname(result$Summaries$ReportedLikelihoodStateCounts[
    "both_reported"
  ]), 106L)
  expect_equal(unname(result$Summaries$ReportedLikelihoodStateCounts[
    "full_curvature_masked"
  ]), 5L)
  expect_equal(unname(result$Summaries$ReportedLikelihoodStateCounts[
    "reduced_curvature_masked"
  ]), 7L)
  expect_equal(unname(result$Summaries$ReportedLikelihoodStateCounts[
    "both_curvature_masked"
  ]), 2L)
  expect_equal(unname(result$Summaries$CurvatureStateCounts[
    "both_pd_agree"
  ]), 106L)
  expect_equal(unname(result$Summaries$ObjectiveOrderStateCounts[
    "material_negative"
  ]), 23L)
  expect_equal(unname(result$Summaries$ObjectiveOrderStateCounts[
    "small_negative"
  ]), 22L)
  expect_equal(unname(result$Summaries$ObjectiveOrderStateCounts[
    "positive"
  ]), 75L)
  expect_equal(unname(result$Summaries$RawEnvelopeOrderStateCounts[
    "small_negative"
  ]), 8L)
  expect_equal(unname(result$Summaries$RawEnvelopeOrderStateCounts[
    "positive"
  ]), 12L)
  expect_equal(unname(result$Summaries$RawEnvelopeOrderStateCounts[
    "material_negative"
  ]), 0L)
  expect_equal(result$Summaries$ReportedDropIdentityEvaluableN, 106L)
  expect_equal(result$Summaries$ReportedDropIdentityExactN, 106L)
  expect_equal(result$Summaries$FullGradientSurfaceHashMismatchN, 1L)
  expect_equal(result$Summaries$ReducedGradientSurfaceHashMismatchN, 1L)
  expect_true(result$AdjudicationSchemaReady)
  expect_true(result$ObjectiveLikelihoodSeparationReady)
  expect_false(result$StationarityCriterionReady)
  expect_false(result$NumericalEligibilitySufficientRuleFrozen)
  expect_false(result$FullExecutionAuthorized)
  expect_false(result$NumericalStabilizationReady)
  expect_false(result$InferenceReady)
  expect_false(result$DecisionReady)
})
