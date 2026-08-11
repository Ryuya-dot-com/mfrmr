gtheory_weak_information_feasibility_paths <- function() {
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
      "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-prototype-0.2.3.R"
    )
  )
}

load_gtheory_weak_information_feasibility <- function() {
  paths <- gtheory_weak_information_feasibility_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  skip_if_not_installed("lme4")
  skip_if_not_installed("glmmTMB")
  skip_if_not_installed("TMB")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("Draft.83d2b2b1c freezes a narrow replacement contract", {
  env <- load_gtheory_weak_information_feasibility()
  contract <- env$mfrmr_gtwf_contract()

  expect_s3_class(contract, "mfrmr_gtwf_contract")
  expect_true(contract$ManifestFreezeAuthorized)
  expect_true(contract$RuntimeSchemaAuthorized)
  expect_equal(contract$FeasibilityReplicateStart, 101L)
  expect_equal(contract$FeasibilityReplicateEnd, 125L)
  expect_equal(contract$FeasibilityIndependentDatasetCount, 750L)
  expect_equal(contract$FeasibilityRowCount, 3000L)
  expect_equal(contract$FeasibilityBackendFitCount, 6000L)
  expect_equal(contract$RuntimePairCount, 120L)
  expect_equal(contract$RuntimeBackendFitCount, 240L)
  expect_false(contract$TimingInScientificExecutionHash)
  expect_identical(contract$WithdrawnCommonScores,
                   "target_relative_se_profiled")
  expect_false(contract$ThresholdSelectionPermitted)
  expect_false(contract$InnerBootstrapPermitted)
  expect_false(contract$ResolutionFeasibilityAuthorized)
  expect_false(contract$FeasibilityEvidenceReady)
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)
})

test_that("Draft.83d2b2b1c manifest is exact and generates no reserved data", {
  env <- load_gtheory_weak_information_feasibility()
  contract <- env$mfrmr_gtwf_contract()
  original_generator <- env$mfrmr_gtw_generate
  on.exit(assign("mfrmr_gtw_generate", original_generator, envir = env),
          add = TRUE)
  assign(
    "mfrmr_gtw_generate",
    function(...) stop("reserved generator must not be called"),
    envir = env
  )
  manifest <- env$mfrmr_gtwf_manifest(contract)

  expect_s3_class(manifest, "mfrmr_gtwf_manifest")
  expect_equal(nrow(manifest$Rows), 3000L)
  expect_equal(length(unique(manifest$Rows$DatasetId)), 750L)
  expect_equal(length(unique(manifest$Rows$Seed)), 750L)
  expect_equal(as.integer(table(manifest$Rows$DatasetId)), rep(4L, 750L))
  expect_equal(
    as.integer(table(manifest$Rows$ScenarioId, manifest$Rows$MethodId)),
    rep(25L, 120L)
  )
  expect_true(all(manifest$Rows$Replicate %in% 101:125))
  expect_equal(anyDuplicated(manifest$Rows$RouteId), 0L)
  expect_equal(manifest$PlannedBackendFits, 6000L)
  expect_false(manifest$ReservedDataGenerated)
  expect_false(manifest$ResultsViewed)
  expect_false(manifest$ExecutionAuthorized)
  expect_false(manifest$RuleSelectionPermitted)
  expect_false(manifest$InnerBootstrapPermitted)
  expect_false(manifest$ConfirmationUse)
})

test_that("Draft.83d2b2b1c runtime schema uses all viewed covering cells", {
  env <- load_gtheory_weak_information_feasibility()
  contract <- env$mfrmr_gtwf_contract()
  manifest <- env$mfrmr_gtwf_runtime_manifest(contract)

  expect_s3_class(manifest, "mfrmr_gtwf_runtime_manifest")
  expect_equal(nrow(manifest$Rows), 120L)
  expect_equal(length(unique(manifest$Rows$DatasetId)), 30L)
  expect_equal(length(unique(manifest$Rows$DesignId)), 5L)
  expect_equal(length(unique(manifest$Rows$VarianceId)), 6L)
  expect_equal(length(unique(manifest$Rows$MethodId)), 4L)
  expect_true(all(manifest$Rows$Replicate == 1L))
  expect_true(all(manifest$Rows$ViewedBeforeRuntimeSchema))
  expect_equal(manifest$BackendFitCount, 240L)
  expect_false(manifest$ReservedFeasibilityDataGenerated)
})

test_that("Draft.83d2b2b1c runtime projection is arithmetic not a guarantee", {
  env <- load_gtheory_weak_information_feasibility()
  dataset <- data.frame(
    DatasetId = c("d1", "d2"), ElapsedSeconds = c(1, 2),
    stringsAsFactors = FALSE
  )
  pair <- data.frame(
    RouteId = paste0("r", 1:4),
    MethodId = c("a", "a", "b", "b"),
    DesignId = c("x", "y", "x", "y"),
    ElapsedSeconds = 1:4, stringsAsFactors = FALSE
  )
  result <- env$mfrmr_gtwf_runtime_projection(
    dataset, pair, feasibility_replicates = 25L,
    multipliers = c(Central = 1, SensitivityX2 = 2, SensitivityX4 = 4)
  )

  expect_equal(result$ObservedGenerationPreFitSeconds, 3)
  expect_equal(result$ObservedPairSeconds, 10)
  expect_equal(result$CentralProjectedFeasibilitySeconds, 325)
  expect_equal(result$ScenarioProjections$ProjectedSeconds,
               c(325, 650, 1300))
  expect_equal(result$ByMethod$ProjectedFeasibilityPairSeconds,
               c(75, 175))
  expect_true(result$TimingIsPlanningTelemetry)
  expect_false(result$PerformanceGuarantee)
  expect_error(
    env$mfrmr_gtwf_runtime_projection(
      dataset, transform(pair, ElapsedSeconds = c(1, 2, NA, 4))
    ),
    "complete finite nonnegative"
  )
})

test_that("Draft.83d2b2b1c observables retain raw likelihood identity", {
  env <- load_gtheory_weak_information_feasibility()
  registry <- env$mfrmr_gtw_registry()
  contract <- env$mfrmr_gtwf_contract(registry)
  runtime_manifest <- env$mfrmr_gtwf_runtime_manifest(contract, registry)
  route <- runtime_manifest$Rows[
    runtime_manifest$Rows$ScenarioId ==
      "GT-WI-baseline_complete-reference_1200" &
      runtime_manifest$Rows$MethodId == "lme4_ml", , drop = FALSE
  ]
  generation <- env$mfrmr_gtw_generate(
    registry, route$ScenarioId[[1L]], route$Replicate[[1L]]
  )
  prefit <- env$mfrmr_gtd3_prefit_one(generation)
  pair <- env$mfrmr_gtwd_diagnostic_pair(
    generation, prefit, route$MethodId[[1L]]
  )
  observable <- env$mfrmr_gtwf_observable_row(route, pair, generation)

  expect_true(is.finite(observable$TargetFractionTotal))
  expect_true(is.finite(observable$TargetToResidualRatio))
  expect_equal(observable$RawLikelihoodDrop, pair$RawLikelihoodDrop,
               tolerance = 1e-12)
  expect_identical(observable$LikelihoodDiagnosticAvailable,
                   pair$LikelihoodDiagnosticAvailable)
  expect_true(observable$FeasibilityScoreAvailable)
  expect_true(is.na(observable$PValue))
  expect_identical(observable$ResolutionState, "not_assigned")
  expect_false(observable$ThresholdApplied)
})

test_that("Draft.83d2b2b1c source contract separates timing and inference", {
  path <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-weak-information-feasibility-contract-0.2.3.md"
  )
  skip_if_not(file.exists(path),
              "repository-internal validation artifacts are excluded")
  text <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_match(text, "R-devel/library/base/help/system.time.html", fixed = TRUE)
  expect_match(text, "lme4/reference/lmerControl.html", fixed = TRUE)
  expect_match(text, "glmmTMB/articles/parallel.html", fixed = TRUE)
  expect_match(text, "timings can vary considerably", fixed = TRUE)
  expect_match(text, "excluded from the replayable execution hash", fixed = TRUE)
  expect_match(text, "3{,}000", fixed = TRUE)
  expect_match(text, "6,000 backend fits", fixed = TRUE)
  expect_match(text, "No data-dependent early stopping", fixed = TRUE)
})

test_that("Draft.83d2b2b1c executes only the viewed 240-fit runtime schema", {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_GTHEORY_FEASIBILITY_RUNTIME"), "true"),
    "the 240-fit runtime schema is an explicit repository validation tier"
  )
  env <- load_gtheory_weak_information_feasibility()
  contract <- env$mfrmr_gtwf_contract()
  manifest <- env$mfrmr_gtwf_manifest(contract)
  runtime <- env$mfrmr_gtwf_execute_runtime_schema(contract, progress = FALSE)
  authorization <- env$mfrmr_gtwf_authorization(
    contract, manifest, runtime
  )

  expect_s3_class(runtime, "mfrmr_gtwf_runtime_execution")
  expect_equal(runtime$PlannedPairs, 120L)
  expect_equal(nrow(runtime$DatasetTiming), 30L)
  expect_equal(nrow(runtime$PairTiming), 120L)
  expect_true(runtime$ExactAccountingPassed)
  expect_true(runtime$RuntimeTimingComplete)
  expect_true(runtime$RuntimePlanningEvidenceReady)
  expect_true(all(is.finite(runtime$PairTiming$ElapsedSeconds)))
  expect_true(all(runtime$PairTiming$ElapsedSeconds >= 0))
  expect_true(all(is.finite(
    runtime$RuntimeProjection$ScenarioProjections$ProjectedHours
  )))
  expect_false(runtime$ReservedFeasibilityDataGenerated)
  expect_false(runtime$ResolutionFeasibilityAuthorized)
  expect_s3_class(authorization, "mfrmr_gtwf_authorization")
  expect_true(all(authorization$AuthorizationGates$Passed))
  expect_true(authorization$ResolutionFeasibilityAuthorized)
  expect_false(authorization$FeasibilityEvidenceReady)
  expect_false(authorization$BootstrapOperatingCharacteristicsReady)
  expect_false(authorization$ThresholdFrozen)
  expect_false(authorization$ConfirmationAuthorized)
  expect_false(authorization$InferenceReady)
  expect_false(authorization$DecisionReady)
})
