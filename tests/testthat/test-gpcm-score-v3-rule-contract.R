gpcm_score_v3_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_gpcm_score_v3_contract <- function() {
  validation_dir <- gpcm_score_v3_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only GPCM score v3 contract is unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir,
    "gpcm-score-v3-rule-contract-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

gpcm_score_v3_passing_evidence <- function(env) {
  out <- env$mfrmr_gsv3_expected_grid()
  retained_extreme <- out$Point == "retained_solution" &
    grepl("C-WEAK5|R-WEAK5|R-WORK5", out$ScenarioId)
  out$SlopeRegion <- ifelse(
    retained_extreme,
    "extreme_slope_review_handoff", "finite_slope_region"
  )
  out$StructuralOraclePass <- TRUE
  out$AnalyticScorePass <- TRUE
  out$FiniteDifferenceStatus <- ifelse(
    retained_extreme, "not_applicable_extreme_slope", "pass"
  )
  out$FiniteDifferenceCombinedRatio <- ifelse(
    retained_extreme, NA_real_, 0.2
  )
  out$LogJacobianCombinedRatio <- 0.1
  out$SlopeJacobianCombinedRatio <- 0.1
  out$ExtremeSlopeReviewHandoff <- retained_extreme
  out$SourceInferenceReady <- FALSE
  out$EvaluationComplete <- TRUE
  out$CalibrationAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  out
}

test_that("v3 separates finite slopes from non-promoting extreme handoff", {
  env <- load_gpcm_score_v3_contract()$env
  contract <- env$mfrmr_gsv3_contract()

  expect_identical(
    contract$contract_version,
    "mfrmr_gpcm_score_rule_contract_v3"
  )
  expect_identical(contract$slope_region$inclusive_max_abs, 3)
  expect_identical(
    env$mfrmr_gsv3_classify_log_slopes(c(-3, -1, 1, 3)),
    "finite_slope_region"
  )
  expect_identical(
    env$mfrmr_gsv3_classify_log_slopes(c(-3.01, 0, 1, 2.01)),
    "extreme_slope_review_handoff"
  )
  expect_identical(
    env$mfrmr_gsv3_classify_log_slopes(c(0, NA_real_)),
    "not_evaluable"
  )
  expect_false(contract$slope_region$outside_is_boundary_proof)
  expect_false(contract$slope_region$outside_can_support_finite_stationarity)
  expect_true(contract$analytic_score_required_everywhere)
  expect_true(contract$finite_difference_required_only_in_finite_region)
  expect_true(contract$extreme_handoff_requires_source_inference_unready)
  expect_identical(nrow(contract$expected_grid), 128L)
  expect_false(contract$retrospective_rule_evaluation_authorized)
  expect_false(contract$general_num_score_tol_frozen)
  expect_false(contract$boundary_proven)
  expect_false(contract$confirmation_authorized)
  expect_false(exists("evidence", envir = env, inherits = FALSE))
  expect_false(exists("result", envir = env, inherits = FALSE))
})

test_that("v3 uses one combined scale-aware allowance", {
  env <- load_gpcm_score_v3_contract()$env
  registry <- env$mfrmr_gsv3_rule_registry()

  expect_identical(nrow(registry), 4L)
  expect_identical(anyDuplicated(registry$Rule), 0L)
  expect_true(all(!registry$FinalNUMSCORETOLFrozen))
  expect_true(all(!registry$ConfirmationAuthorized))
  analytic <- env$mfrmr_gsv3_allowance(
    "independent_analytic_score", c(1, 1e6)
  )
  expect_equal(analytic, c(1.01e-8, 1.0001e-4), tolerance = 1e-15)
  finite <- env$mfrmr_gsv3_allowance(
    "finite_difference_score", c(1, 100),
    reference_spread = c(1e-8, 2e-8),
    roundoff_bound = c(1e-9, 2e-9)
  )
  expect_equal(
    finite,
    1e-7 + 5e-7 * c(1, 100) +
      10 * c(1e-8, 2e-8) + 10 * c(1e-9, 2e-9),
    tolerance = 1e-15
  )
  expect_error(
    env$mfrmr_gsv3_allowance("unknown", 1),
    "Unknown v3 numerical rule",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_gsv3_allowance("finite_difference_score", 0),
    "must be finite and nonnegative",
    fixed = TRUE
  )
})

test_that("v3 decision requires finite checks and exact extreme handoff", {
  env <- load_gpcm_score_v3_contract()$env
  evidence <- gpcm_score_v3_passing_evidence(env)
  decision <- env$mfrmr_gsv3_decision(evidence)

  expect_true(decision$StructureComplete)
  expect_true(decision$RegionClassificationComplete)
  expect_true(decision$ConstructedPointsFinite)
  expect_true(decision$FiniteRegionRulePass)
  expect_true(decision$ExtremeHandoffRulePass)
  expect_true(decision$CommonRulePass)
  expect_true(decision$ContractReady)
  expect_identical(decision$Status, "v3_rule_contract_ready")
  expect_identical(decision$V2CalibrationStatus, "rejected_unchanged")
  expect_identical(decision$GeneralNUMSCORETOLStatus, "pilot_required")
  expect_false(decision$BoundaryProven)
  expect_false(decision$CalibrationAuthorized)
  expect_false(decision$ConfirmationAuthorized)

  expect_identical(
    env$mfrmr_gsv3_decision(evidence[-1, ])$Status,
    "rejected"
  )
  finite_skipped <- evidence
  row <- which(finite_skipped$SlopeRegion == "finite_slope_region")[1]
  finite_skipped$FiniteDifferenceStatus[row] <-
    "not_applicable_extreme_slope"
  finite_skipped$FiniteDifferenceCombinedRatio[row] <- NA_real_
  expect_identical(
    env$mfrmr_gsv3_decision(finite_skipped)$Status,
    "rejected"
  )
  false_ready <- evidence
  row <- which(false_ready$SlopeRegion ==
                 "extreme_slope_review_handoff")[1]
  false_ready$SourceInferenceReady[row] <- TRUE
  expect_identical(env$mfrmr_gsv3_decision(false_ready)$Status, "rejected")
  false_boundary <- evidence
  false_boundary$ExtremeSlopeReviewHandoff[row] <- FALSE
  expect_identical(env$mfrmr_gsv3_decision(false_boundary)$Status, "rejected")
  constructed_extreme <- evidence
  row <- which(constructed_extreme$Point == "coupled_free_probe")[1]
  constructed_extreme$SlopeRegion[row] <- "extreme_slope_review_handoff"
  constructed_extreme$FiniteDifferenceStatus[row] <-
    "not_applicable_extreme_slope"
  constructed_extreme$FiniteDifferenceCombinedRatio[row] <- NA_real_
  constructed_extreme$ExtremeSlopeReviewHandoff[row] <- TRUE
  expect_identical(
    env$mfrmr_gsv3_decision(constructed_extreme)$Status,
    "rejected"
  )
})
