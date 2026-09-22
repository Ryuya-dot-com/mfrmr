gtheory_weak_information_diagnostic_paths <- function() {
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
      "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R"
    )
  )
}

load_gtheory_weak_information_diagnostic <- function() {
  paths <- gtheory_weak_information_diagnostic_paths()
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

gtwd_input <- function(env, scenario_id, replicate = 2L) {
  registry <- env$mfrmr_gtw_registry()
  generation <- env$mfrmr_gtw_generate(registry, scenario_id, replicate)
  list(
    Generation = generation,
    PreFit = env$mfrmr_gtd3_prefit_one(generation)
  )
}

test_that("Draft.83d2b2b1a withdraws the noncommensurate common SE rule", {
  env <- load_gtheory_weak_information_diagnostic()
  contract <- env$mfrmr_gtwd_inference_contract()

  expect_s3_class(contract, "mfrmr_gtwd_contract")
  expect_true(contract$HistoricalFeasibilityExecutionSuperseded)
  expect_false(contract$FeasibilityExecutionAuthorized)
  expect_false(contract$ExactRLRsimApplicable)
  expect_false(contract$NullSeparationEqualsPositiveRecovery)
  expect_false(contract$BackendCoordinatesCommensurate)
  expect_identical(
    contract$Scores$SupersedingStatus[
      contract$Scores$ScoreId == "target_relative_se_profiled"
    ],
    "withdrawn_noncommensurate_backend_coordinates"
  )
  expect_identical(
    contract$Scores$SupersedingStatus[
      contract$Scores$ScoreId == "reduced_likelihood_drop"
    ],
    "retained_raw_separate_ml_reml_diagnostic"
  )
  expect_equal(sum(grepl("^withdrawn", contract$Rules$SupersedingStatus)), 2L)
  expect_true(all(is.na(contract$Scores$CommonCrossBackendCutpointEligible) |
                  !contract$Scores$CommonCrossBackendCutpointEligible |
                  contract$Scores$ScoreId %in%
                    c("target_fraction_total", "target_to_residual_ratio")))
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)
})

test_that("Draft.83d2b2b1a audit fixes boundary claims to primary sources", {
  audit <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-weak-information-inference-audit-0.2.3.md"
  )
  skip_if_not(file.exists(audit),
              "repository-internal validation artifacts are excluded")
  text <- paste(readLines(audit, warn = FALSE), collapse = "\n")

  expect_match(text, "10.1080/01621459.1987.10478472", fixed = TRUE)
  expect_match(text, "10.1111/j.1467-9868.2004.00438.x", fixed = TRUE)
  expect_match(text, "10.1198/106186008X386599", fixed = TRUE)
  expect_match(text, "one.*variance component")
  expect_match(text, "not silently truncated to zero", fixed = TRUE)
  expect_match(text, "custom parametric\nbootstrap under the fitted reduced model")
  expect_match(text, "must not share a numerical threshold", fixed = TRUE)
  expect_match(text, "outside that exact contract", fixed = TRUE)
  expect_match(text, "positive-control recovery", fixed = TRUE)
})

test_that("Draft.83d2b2b1a reduced formula removes only Rater", {
  env <- load_gtheory_weak_information_diagnostic()
  input <- gtwd_input(
    env, "GT-WI-baseline_complete-reference_1200", replicate = 3L
  )
  spec <- input$Generation$Spec
  reduced <- env$mfrmr_gtwd_reduced_formula(spec, "Rater")
  text <- paste(deparse(reduced, width.cutoff = 500L), collapse = " ")

  expect_false(grepl("\\(1 \\| Rater\\)", text))
  expect_true(grepl("\\(1 \\| Person\\)", text))
  expect_true(grepl("\\(1 \\| Criterion\\)", text))
  expect_true(grepl("Person:Rater", text, fixed = TRUE))
  expect_true(grepl("Rater:Criterion", text, fixed = TRUE))
  expect_equal(
    length(reformulas::findbars(reduced)),
    sum(!is.na(spec$EffectMap$FormulaTerm)) - 1L
  )
  expect_error(env$mfrmr_gtwd_reduced_formula(spec, "Residual"),
               "non-residual")
  expect_error(env$mfrmr_gtwd_reduced_formula(spec, "unknown"),
               "exactly one")
})

test_that("Draft.83d2b2b1a lme4 coordinates and raw ML LRT are exact", {
  env <- load_gtheory_weak_information_diagnostic()
  input <- gtwd_input(
    env, "GT-WI-baseline_complete-reference_1200", replicate = 3L
  )
  pair <- env$mfrmr_gtwd_diagnostic_pair(
    input$Generation, input$PreFit, "lme4_ml"
  )

  expect_s3_class(pair, "mfrmr_gtwd_pair")
  expect_identical(pair$LikelihoodIdentity, "ML")
  expect_equal(pair$LikelihoodDfDifference, 1L)
  expect_true(pair$SameRows)
  expect_equal(
    pair$RawLikelihoodDrop,
    2 * (as.numeric(logLik(pair$FullFit)) -
           as.numeric(logLik(pair$ReducedFit))),
    tolerance = 1e-12
  )
  expect_true(pair$NegativeDropWithinTolerance)
  expect_true(pair$CoordinateDiagnostic$CoordinateVarianceMapExact)
  expect_identical(
    pair$CoordinateDiagnostic$CoordinateSpace,
    "lme4_profiled_relative_standard_deviation"
  )
  expect_true(pair$CoordinateDiagnostic$LocalDiagnosticAvailable)
  expect_true(is.na(pair$PValue))
  expect_identical(pair$ReferenceDistribution,
                   "none_assigned_multi_component_boundary")
  expect_false(pair$InferenceReady)
})

test_that("Draft.83d2b2b1a glmmTMB coordinates and raw RLRT stay distinct", {
  env <- load_gtheory_weak_information_diagnostic()
  input <- gtwd_input(
    env, "GT-WI-baseline_complete-reference_1200", replicate = 2L
  )
  pair <- env$mfrmr_gtwd_diagnostic_pair(
    input$Generation, input$PreFit, "glmmTMB_reml"
  )

  expect_identical(pair$LikelihoodIdentity, "REML")
  expect_equal(pair$LikelihoodDfDifference, 1L)
  expect_true(pair$SameRows)
  expect_true(pair$NegativeDropWithinTolerance)
  expect_true(pair$CoordinateDiagnostic$CoordinateVarianceMapExact)
  expect_identical(
    pair$CoordinateDiagnostic$CoordinateSpace,
    "glmmTMB_joint_log_standard_deviation"
  )
  expect_true(pair$CoordinateDiagnostic$LocalDiagnosticAvailable)
  expect_equal(
    pair$CoordinateDiagnostic$LocalRelativeScale,
    2 * pair$CoordinateDiagnostic$LocalQuadraticScale,
    tolerance = 1e-12
  )
  expect_false(grepl(
    "lme4", pair$CoordinateDiagnostic$LocalRelativeScaleMeaning,
    fixed = TRUE
  ))
  expect_false(pair$InferenceReady)
})

test_that("Draft.83d2b2b1a executes only the viewed 24-unit schema", {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_GTHEORY_DIAGNOSTIC_SCHEMA"), "true"),
    "the 48-refit diagnostic schema is an explicit repository validation tier"
  )
  env <- load_gtheory_weak_information_diagnostic()
  result <- env$mfrmr_gtwd_execute_schema(progress = FALSE)

  expect_s3_class(result, "mfrmr_gtwd_schema_execution")
  expect_equal(result$PlannedUnits, 24L)
  expect_equal(result$PairReturnCount, 24L)
  expect_true(result$ExactAccountingPassed)
  expect_true(result$SchemaEvidenceReady)
  expect_false(result$FeasibilityEvidenceReady)
  expect_false(result$ThresholdFrozen)
  expect_false(result$ConfirmationAuthorized)
  expect_false(result$InferenceReady)
  expect_false(result$DecisionReady)
  expect_true(all(result$DiagnosticRows$SameRows))
  expect_true(all(result$DiagnosticRows$LikelihoodDfDifference == 1L))
  expect_true(all(is.na(vapply(
    result$PairDetails, function(x) if (is.null(x)) NA_real_ else x$PValue,
    numeric(1L)
  ))))
})
