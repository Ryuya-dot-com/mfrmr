gpcm_score_attribution_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_gpcm_extreme_score_attribution <- function() {
  validation_dir <- gpcm_score_attribution_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only GPCM score attribution is unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir,
    "gpcm-extreme-score-attribution-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

test_that("the attribution plan is bounded and never auto-executes", {
  testthat::skip_if_not_installed("digest")
  env <- load_gpcm_extreme_score_attribution()$env
  dry <- env$mfrmr_run_gpcm_extreme_score_attribution(
    dry_run = TRUE, progress = FALSE
  )

  expect_identical(
    dry$contract_version,
    "mfrmr_gpcm_extreme_score_attribution_v1"
  )
  expect_identical(nrow(dry$manifest), 3L)
  expect_identical(dry$manifest$ScenarioId, env$mfrmr_gsea_scenario_ids)
  expect_false(dry$executed)
  expect_identical(dry$v2_calibration_status, "rejected_unchanged")
  expect_identical(dry$general_num_score_tol_status, "pilot_required")
  expect_false(dry$confirmation_authorized)
  expect_false(exists("fits", envir = env, inherits = FALSE))
  expect_false(exists("evidence", envir = env, inherits = FALSE))
  expect_error(
    env$mfrmr_run_gpcm_extreme_score_attribution(
      dry_run = FALSE, authorize = FALSE, progress = FALSE
    ),
    "explicit `authorize = TRUE`",
    fixed = TRUE
  )
})

test_that("independent projection and cumulative probabilities are exact", {
  env <- load_gpcm_extreme_score_attribution()$env

  expect_equal(
    env$mfrmr_gsea_project_sum_zero(c(2, -1, 0.5, 3)),
    c(-1, -4, -2.5), tolerance = 0
  )
  probability <- matrix(
    c(0.1, 0.2, 0.3, 0.4, 0.4, 0.3, 0.2, 0.1),
    nrow = 2L, byrow = TRUE
  )
  expect_equal(
    env$mfrmr_gsea_p_geq(probability),
    rbind(c(0.9, 0.7, 0.4), c(0.6, 0.3, 0.1)),
    tolerance = 1e-15
  )
  expect_error(
    env$mfrmr_gsea_project_sum_zero(1),
    "at least two finite",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_gsea_p_geq(matrix(1, nrow = 1)),
    "polytomous matrix",
    fixed = TRUE
  )
})

test_that("independent analytic scores agree on a regular five-category fit", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("digest")
  skip_if_frozen_gpcm_payload_drifted()
  env <- load_gpcm_extreme_score_attribution()$env
  env$mfrmr_gsea_require_sources()
  scenario <- env$mfrmr_gscr_manifest()
  scenario <- scenario[
    scenario$ScenarioId == "NUM-GPCM-SCORE-CAL-C-CORE5", , drop = FALSE
  ]
  fitted <- env$mfrmr_gscr_fit(scenario)
  expect_true(is.na(fitted$error))
  expect_false(is.null(fitted$fit))
  context <- env$mfrmr_num_fit_context(fitted$fit)

  for (point in env$mfrmr_gsc_points()$Point) {
    par <- env$mfrmr_gscr_point(fitted$fit, point)
    package_score <- context$gr(par)
    independent <- env$mfrmr_gsea_independent_score(context, par)
    scale <- pmax(1, abs(package_score), abs(independent$score))
    allowance <- env$mfrmr_gsea_absolute_floor +
      env$mfrmr_gsea_scaled_rate * scale
    expect_true(all(abs(package_score - independent$score) <= allowance),
                info = point)
    expect_lt(independent$posterior_row_sum_residual, 1e-12)
  }
})

test_that("attribution decisions keep the rejected calibration unchanged", {
  env <- load_gpcm_extreme_score_attribution()$env
  env$mfrmr_gsea_require_sources()
  expected <- expand.grid(
    ScenarioId = env$mfrmr_gsea_scenario_ids,
    Point = env$mfrmr_gsc_points()$Point,
    ParameterClass = env$mfrmr_gsc_expected_classes,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  evidence <- data.frame(
    ContractVersion = env$mfrmr_gsea_contract_version,
    expected,
    MaxAbsDifference = 1e-12,
    MaxAllowanceRatio = 0.01,
    StructuralOraclePass = TRUE,
    EvaluationComplete = TRUE,
    CalibrationResultChanged = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  decision <- env$mfrmr_gsea_decision(evidence)

  expect_true(decision$Complete)
  expect_true(decision$AnalyticAttributionAgreement)
  expect_identical(decision$Status, "attribution_agreement")
  expect_identical(decision$V2CalibrationStatus, "rejected_unchanged")
  expect_identical(decision$GeneralNUMSCORETOLStatus, "pilot_required")
  expect_false(decision$CalibrationResultChanged)
  expect_false(decision$ConfirmationAuthorized)

  expect_identical(
    env$mfrmr_gsea_decision(evidence[-1, ])$Status,
    "rejected"
  )
  drift <- evidence
  drift$MaxAllowanceRatio[1] <- 1.01
  expect_identical(env$mfrmr_gsea_decision(drift)$Status, "rejected")
  changed <- evidence
  changed$CalibrationResultChanged[1] <- TRUE
  expect_identical(env$mfrmr_gsea_decision(changed)$Status, "rejected")
})
