gtheory_weak_information_paths <- function() {
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
      "gtheory-weak-information-calibration-prototype-0.2.3.R"
    )
  )
}

load_gtheory_weak_information <- function() {
  paths <- gtheory_weak_information_paths()
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

test_that("Draft.83d2b2a freezes the calibration registry, not a rule", {
  env <- load_gtheory_weak_information()
  registry <- env$mfrmr_gtw_registry()
  manifest <- env$mfrmr_gtw_manifest(registry)
  roles <- table(registry$Cells$EvaluationRole)
  diagnostics <- table(registry$Diagnostics$Availability)

  expect_s3_class(registry, "mfrmr_gtw_registry")
  expect_equal(nrow(registry$Cells), 30L)
  expect_equal(nrow(manifest), 120L)
  expect_equal(length(unique(registry$Cells$DesignId)), 5L)
  expect_equal(length(unique(registry$Cells$VarianceId)), 6L)
  expect_true(all(table(registry$Cells$DesignId) == 6L))
  expect_true(all(table(registry$Cells$VarianceId) == 5L))
  expect_equal(unname(roles[["negative_control_not_resolved"]]), 10L)
  expect_equal(unname(roles[["positive_control_resolved"]]), 3L)
  expect_equal(unname(roles[["transition_no_binary_requirement"]]), 17L)
  expect_equal(sum(manifest$EvaluationRole ==
                     "negative_control_not_resolved"), 40L)
  expect_equal(sum(manifest$EvaluationRole ==
                     "positive_control_resolved"), 12L)
  expect_equal(nrow(registry$Diagnostics), 12L)
  expect_equal(unname(diagnostics[["implemented_smoke"]]), 10L)
  expect_identical(
    registry$RegistryHash,
    "8a1c165d5497519f14f9839a22eed7b9e918b5120da83985613d01fd76a8be01"
  )
  expect_true(all(is.na(registry$Cells$PilotReplications)))
  expect_true(all(is.na(registry$Cells$ConfirmationReplications)))
  expect_true(all(registry$Cells$ThresholdState == "not_frozen"))
  expect_false(registry$CalibrationEvidenceReady)
  expect_false(registry$ConfirmationAuthorized)
  expect_false(registry$DecisionReady)
})

test_that("Draft.83d2b2a generation is deterministic and truth-separated", {
  env <- load_gtheory_weak_information()
  registry <- env$mfrmr_gtw_registry()
  zero_id <- "GT-WI-baseline_complete-exact_zero"
  positive_id <- "GT-WI-baseline_complete-reference_1200"
  zero_a <- env$mfrmr_gtw_generate(registry, zero_id)
  zero_b <- env$mfrmr_gtw_generate(registry, zero_id)
  positive <- env$mfrmr_gtw_generate(registry, positive_id)

  expect_identical(zero_a$GeneratorHash, zero_b$GeneratorHash)
  expect_identical(zero_a$AnalysisData, zero_b$AnalysisData)
  expect_equal(unname(zero_a$NominalTruth[["Rater"]]), 0)
  expect_equal(unname(positive$NominalTruth[["Rater"]]), 0.12)
  expect_false(identical(zero_a$GeneratorHash, positive$GeneratorHash))
  expect_false(identical(zero_a$AnalysisData$Score,
                         positive$AnalysisData$Score))
  expect_false(any(c("TargetVariance", "TruthRegion", "EvaluationRole") %in%
                     names(zero_a$AnalysisData)))
  expect_false(zero_a$EstimationReady)
  expect_false(zero_a$InferenceReady)
  expect_false(zero_a$DecisionReady)
})

test_that("Draft.83d2b2a design strata pass structural pre-fit", {
  env <- load_gtheory_weak_information()
  registry <- env$mfrmr_gtw_registry()
  cells <- registry$Cells[!duplicated(registry$Cells$DesignId), , drop = FALSE]
  audits <- lapply(cells$ScenarioId, function(id) {
    generation <- env$mfrmr_gtw_generate(registry, id)
    env$mfrmr_gtd3_prefit_one(generation)
  })

  expect_equal(length(audits), 5L)
  expect_true(all(vapply(audits, `[[`, logical(1L), "PreFitEligible")))
  expect_true(all(vapply(audits, function(x) {
    x$StructuralRankAudit$StructuralRankFull
  }, logical(1L))))
  expect_true(all(vapply(audits, function(x) {
    identical(x$PreFitState, "eligible_point_fit_information_pending")
  }, logical(1L))))
})

test_that("Draft.83d2b2a representative controls expose observables", {
  env <- load_gtheory_weak_information()
  registry <- env$mfrmr_gtw_registry()
  scenario_ids <- paste0(
    "GT-WI-baseline_complete-",
    c("exact_zero", "numerical_near_zero", "reference_1200")
  )
  result <- env$mfrmr_gtw_execute_smoke(
    registry, scenario_ids = scenario_ids, progress = FALSE
  )
  candidate_columns <- c(
    "TargetEstimate", "TargetFractionTotal", "TargetToResidualRatio",
    "TargetGroupingLevels", "ObservationsPerTargetLevel",
    "BasePointGatePassed", "BoundaryComponentCount", "CurvatureState"
  )

  expect_s3_class(result, "mfrmr_gtw_smoke")
  expect_equal(result$PlannedUnits, 12L)
  expect_equal(result$FitAttemptCount, 12L)
  expect_equal(result$FitReturnCount, 12L)
  expect_equal(result$BasePointGatePassCount, 4L)
  expect_equal(result$NegativeControlFalseReadyCount, 0L)
  expect_equal(result$PositiveControlFalseBlockCount, 0L)
  expect_true(result$AtomicAccountingPassed)
  expect_true(all(candidate_columns %in% names(result$ObservableRows)))
  expect_equal(nrow(result$MethodContrasts), 3L)
  expect_true(all(is.finite(
    unlist(result$MethodContrasts[
      result$MethodContrasts$VarianceId == "reference_1200",
      c("BackendRelativeDifferenceREML", "BackendRelativeDifferenceML",
        "MLREMLRelativeDifferenceLme4",
        "MLREMLRelativeDifferenceGlmmTMB")
    ])
  )))
  expect_false(result$ThresholdFrozen)
  expect_false(result$CalibrationEvidenceReady)
  expect_false(result$ConfirmationAuthorized)
  expect_false(result$DecisionReady)
})

test_that("Draft.83d2b2a full smoke is exact and explicitly opt-in", {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_GTHEORY_WEAK_INFO_SMOKE"), "true"),
    "the 120-unit backend smoke is an explicit repository validation tier"
  )
  env <- load_gtheory_weak_information()
  registry <- env$mfrmr_gtw_registry()
  methods <- registry$Methods$MethodId
  runs <- parallel::mclapply(methods, function(method) {
    env$mfrmr_gtw_execute_smoke(
      registry, method_ids = method, progress = FALSE
    )
  }, mc.cores = min(4L, length(methods)))
  result <- env$mfrmr_gtw_combine_strata(runs, registry)

  expect_s3_class(result, "mfrmr_gtw_stratified_smoke")
  expect_equal(result$PlannedUnits, 120L)
  expect_equal(result$FitAttemptCount, 120L)
  expect_equal(result$FitReturnCount, 120L)
  expect_equal(result$BasePointGatePassCount, 82L)
  expect_equal(result$NegativeControlFalseReadyCount, 27L)
  expect_equal(result$PositiveControlFalseBlockCount, 3L)
  expect_true(result$AtomicAccountingPassed)
  expect_identical(
    result$StratifiedSmokeHash,
    "71978d3ea5bd747ae53526f8bbfe3bfde5a086e0267f6e9530b088cfb4f9f336"
  )
  expect_identical(unname(result$StratumHashes), c(
    "f39a49f65038fa6d4df7df2a81c9d2715cf5d9f64e04127843cbc406f4101104",
    "19959e174c87bdcce6a8adeb4b3883884d57f90dfd1b684ded724026dcc91ea8",
    "27836df498b6b4a9e1ce48e51a93017661539d106ddb7acb626d2ac5adbef3ea",
    "ea8006eaca77294c3e90851c05683b96310ef838ea071d422854aea23c962555"
  ))
  expect_false(result$ThresholdFrozen)
  expect_false(result$CalibrationEvidenceReady)
  expect_false(result$ConfirmationAuthorized)
  expect_false(result$DecisionReady)
})

test_that("Draft.83d2b2a fails closed on malformed selections and strata", {
  env <- load_gtheory_weak_information()
  registry <- env$mfrmr_gtw_registry()

  expect_error(env$mfrmr_gtw_manifest(list()), "must be a Draft.83d2b2a")
  expect_error(
    env$mfrmr_gtw_generate(registry, "unknown-scenario"),
    "Unknown weak-information"
  )
  expect_error(
    env$mfrmr_gtw_execute_smoke(registry, method_ids = "unknown-method"),
    "Unknown weak-information"
  )
  expect_error(
    env$mfrmr_gtw_prepare_unit(registry, data.frame()),
    "must contain one"
  )
  expect_error(env$mfrmr_gtw_combine_strata(list(), registry),
               "must contain")

  one <- env$mfrmr_gtw_execute_smoke(
    registry,
    scenario_ids = "GT-WI-baseline_complete-exact_zero",
    method_ids = "lme4_reml", progress = FALSE
  )
  expect_error(
    env$mfrmr_gtw_combine_strata(list(one, one), registry),
    "partition the four"
  )
})
