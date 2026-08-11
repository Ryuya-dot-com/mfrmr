gpcm_score_design_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_gpcm_score_calibration_design <- function() {
  validation_dir <- gpcm_score_design_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only GPCM score-calibration design is unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir,
    "gpcm-score-calibration-design-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

gpcm_score_design_passing_evidence <- function(env) {
  out <- env$mfrmr_gsc_expected_evidence_grid()
  out$MaxAbsDifference <- 1e-9
  out$MaxScaledDifference <- 1e-10
  out$MaxAdaptiveRatio <- 0.2
  out$StepLadderComplete <- TRUE
  out$StructuralOraclePass <- TRUE
  out$JacobianStatus <- ifelse(
    out$ParameterClass == "log_slopes", "pass", "not_applicable"
  )
  out$EvaluationComplete <- TRUE
  out$CalibrationAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  out
}

test_that("the bounded GPCM score design is complete and never auto-runs", {
  env <- load_gpcm_score_calibration_design()$env
  contract <- env$mfrmr_gsc_design_contract()

  expect_identical(
    contract$contract_version,
    "mfrmr_gpcm_score_calibration_design_v2"
  )
  expect_identical(nrow(contract$scenarios), 8L)
  expect_identical(anyDuplicated(contract$scenarios$ScenarioId), 0L)
  expect_identical(
    sort(unique(contract$scenarios$SlopeOwner)),
    c("Criterion", "Rater")
  )
  expect_true(all(
    contract$scenarios$SlopeOwner == contract$scenarios$StepOwner
  ))
  expect_identical(
    sort(unique(contract$scenarios$DesignId)),
    sort(c("core", "weak_bridge", "workload_imbalance", "category_imbalance"))
  )
  expect_true(all(contract$scenarios$NPersons == 40L))
  expect_true(all(contract$scenarios$NRaters == 4L))
  expect_true(all(contract$scenarios$NCriteria == 4L))
  expect_true(all(contract$scenarios$NCategories == 5L))
  expect_true(all(contract$scenarios$CalibrationRowsPerCell == 1L))
  expect_true(all(!contract$scenarios$RecoveryClaim))
  expect_true(all(!contract$scenarios$IntegrationSufficiencyClaim))
  expect_true(all(!contract$scenarios$CalibrationExecutionAuthorized))
  expect_true(all(!contract$scenarios$ConfirmationAuthorized))
  expect_identical(nrow(contract$points), 4L)
  expect_identical(nrow(contract$parameter_rules), 4L)
  slope_rule <- contract$parameter_rules[
    contract$parameter_rules$ParameterClass == "log_slopes", , drop = FALSE
  ]
  expect_identical(slope_rule$ExpandedLogJacobianAbsoluteCap, 5e-10)
  expect_identical(
    slope_rule$RuleStatus,
    "calibration_evaluation_rule_frozen_after_preflight_v2"
  )
  expect_identical(nrow(contract$expected_evidence_grid), 128L)
  expect_true(contract$design_ready)
  expect_true(contract$calibration_evaluation_rule_frozen)
  expect_false(contract$general_num_score_tol_frozen)
  expect_false(contract$calibration_execution_authorized)
  expect_false(contract$confirmation_authorized)
  expect_false(exists("fit", envir = env, inherits = FALSE))
  expect_false(exists("result", envir = env, inherits = FALSE))
})

test_that("deterministic fixtures preserve support and the declared stresses", {
  env <- load_gpcm_score_calibration_design()$env
  designs <- c(
    "core", "weak_bridge", "workload_imbalance", "category_imbalance"
  )

  set.seed(7811)
  expected_rng <- stats::runif(2)
  set.seed(7811)
  expect_equal(stats::runif(1), expected_rng[1])
  fixtures <- lapply(designs, env$mfrmr_gsc_fixture)
  expect_equal(stats::runif(1), expected_rng[2])

  expect_identical(vapply(fixtures, `[[`, "design_id", FUN.VALUE = ""), designs)
  expect_true(all(vapply(fixtures, `[[`, logical(1), "stochastic") == FALSE))
  expect_true(all(vapply(fixtures, function(x) {
    all(x$owner_support$Rater > 0L) && all(x$owner_support$Criterion > 0L)
  }, logical(1))))
  expect_identical(vapply(fixtures, function(x) nrow(x$data), integer(1)),
                   c(640L, 172L, 400L, 640L))

  weak <- fixtures[[2]]$data
  common <- table(weak$Person, weak$Rater)
  expect_true(all(common["P01", ] == 4L))
  expect_true(all(rowSums(common > 0L)[rownames(common) != "P01"] == 1L))

  workload <- table(fixtures[[3]]$data$Rater)
  expect_identical(as.integer(workload), c(160L, 120L, 80L, 40L))

  category <- prop.table(table(fixtures[[4]]$data$Score))
  expect_gt(unname(category["3"]), 0.65)
  expect_true(all(category > 0))
  expect_identical(
    fixtures[[1]]$data,
    env$mfrmr_gsc_fixture("core")$data
  )
  expect_error(env$mfrmr_gsc_fixture("unknown"), "should be one of")
})

test_that("the five-point derivative is exact on a quartic control", {
  env <- load_gpcm_score_calibration_design()$env
  point <- c(-1.25, 0.4, 2.1)
  fn <- function(value) sum(value^4 + 2 * value^2 - 3 * value)
  expected <- 4 * point^3 + 4 * point - 3
  observed <- env$mfrmr_gsc_five_point_gradient(fn, point, 3e-4)

  expect_equal(observed, expected, tolerance = 1e-9)
  expect_error(
    env$mfrmr_gsc_five_point_gradient(sum, numeric(0), 3e-4),
    "non-empty finite numeric vector",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_gsc_five_point_gradient(sum, c(1, NA), 3e-4),
    "non-empty finite numeric vector",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_gsc_five_point_gradient(sum, point, 0),
    "one finite positive value",
    fixed = TRUE
  )
  nonfinite <- env$mfrmr_gsc_five_point_gradient(
    function(value) if (value[1] > 0) Inf else sum(value^2),
    c(0, 0),
    1e-4
  )
  expect_true(is.na(nonfinite[1]))
  expect_true(is.finite(nonfinite[2]))
})

test_that("the calibration decision requires every stratum and cap", {
  env <- load_gpcm_score_calibration_design()$env
  evidence <- gpcm_score_design_passing_evidence(env)
  decision <- env$mfrmr_gsc_decision(evidence)

  expect_true(decision$StructureComplete)
  expect_true(decision$NumericComplete)
  expect_true(decision$JacobianComplete)
  expect_true(decision$CalibrationRulePass)
  expect_identical(decision$Status, "calibration_rule_pass")
  expect_identical(decision$GeneralNUMSCORETOLStatus, "pilot_required")
  expect_false(decision$CalibrationAuthorized)
  expect_false(decision$ConfirmationAuthorized)

  expect_identical(
    env$mfrmr_gsc_decision(evidence[-1, ])$Status,
    "rejected"
  )
  duplicate <- evidence
  duplicate[128, names(env$mfrmr_gsc_expected_evidence_grid())] <-
    duplicate[127, names(env$mfrmr_gsc_expected_evidence_grid())]
  expect_identical(env$mfrmr_gsc_decision(duplicate)$Status, "rejected")

  incomplete <- evidence
  incomplete$StepLadderComplete[1] <- FALSE
  expect_identical(env$mfrmr_gsc_decision(incomplete)$Status, "rejected")

  structural <- evidence
  structural$StructuralOraclePass[1] <- FALSE
  expect_identical(env$mfrmr_gsc_decision(structural)$Status, "rejected")

  absolute <- evidence
  slope_row <- which(absolute$ParameterClass == "log_slopes")[1]
  absolute$MaxAbsDifference[slope_row] <- 2e-6
  expect_identical(env$mfrmr_gsc_decision(absolute)$Status, "rejected")

  scaled <- evidence
  scaled$MaxScaledDifference[1] <- 3e-7
  expect_identical(env$mfrmr_gsc_decision(scaled)$Status, "rejected")

  adaptive <- evidence
  adaptive$MaxAdaptiveRatio[1] <- 1.01
  expect_identical(env$mfrmr_gsc_decision(adaptive)$Status, "rejected")

  jacobian <- evidence
  row <- which(jacobian$ParameterClass == "log_slopes")[1]
  jacobian$JacobianStatus[row] <- "fail"
  expect_identical(env$mfrmr_gsc_decision(jacobian)$Status, "rejected")

  unauthorized <- evidence
  unauthorized$ConfirmationAuthorized[1] <- TRUE
  expect_identical(env$mfrmr_gsc_decision(unauthorized)$Status, "rejected")
})
