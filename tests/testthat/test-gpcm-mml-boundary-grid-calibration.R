mml_boundary_grid_runner_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-grid-calibration-0.2.3.R"
  )
}

mml_boundary_grid_validator_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-grid-completion-validator-0.2.3.R"
  )
}

test_that("MML boundary/grid calibration pins retrospective scope", {
  runner <- mml_boundary_grid_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  contract <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-grid-calibration-contract-0.2.3.md"
  )
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-grid-calibration-record-0.2.3.md"
  )
  expect_true(file.exists(contract))
  expect_true(file.exists(record))

  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  expect_identical(
    env$mfrmr_gpcm_mml_boundary_grid_quad_points, c(31L, 61L, 91L)
  )
  expect_identical(
    env$mfrmr_gpcm_mml_boundary_grid_runtime_sha256,
    "2a6344a815dadee12dc50eeac339e2f5774cf43cce2b86771a24aa8c132aa0e3"
  )
  expect_identical(
    env$mfrmr_gpcm_mml_boundary_grid_source_execution_sha256,
    "d993825cc8a58a3e3e1d17c6e4a8a6e2cc4fb16611c0429acd32296b81f70e70"
  )

  contract_text <- paste(readLines(contract, warn = FALSE), collapse = "\n")
  expect_match(contract_text, "retrospective calibration only", fixed = TRUE)
  expect_match(contract_text, "q91-minus-q61", fixed = TRUE)
  expect_match(contract_text, "cannot test, freeze, or confirm", fixed = TRUE)
  expect_match(contract_text, "no operating-characteristic estimate", fixed = TRUE)
})

test_that("MML boundary/grid extraction preserves certificate semantics", {
  runner <- mml_boundary_grid_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  fit <- list(config = list(boundary_audit = list(
    gpcm_slope_boundary = list(
      state = "certified_fixed_quadrature_marginal",
      complete = TRUE,
      scope_complete = TRUE,
      fixed_quadrature_certificate = TRUE,
      continuous_integral_certificate = FALSE,
      readiness_effect = "none_instrumentation_only",
      likelihood_difference = 0,
      certificates = data.frame(
        PairId = "A>B", PositiveLevel = "A", NegativeLevel = "B",
        Certified = TRUE, BoundaryImprovement = 0.2,
        stringsAsFactors = FALSE
      ),
      target_status = data.frame(
        Level = c("A", "B"), CandidateStatus = c("high", "low"),
        stringsAsFactors = FALSE
      )
    )
  )))
  row <- env$mfrmr_gpcm_mml_boundary_grid_audit_row(fit)
  expect_true(row$AuditComplete)
  expect_true(row$AuditScopeComplete)
  expect_true(row$FixedQuadratureCertificate)
  expect_false(row$ContinuousIntegralCertificate)
  expect_identical(row$CertifiedPairs, 1L)
  expect_identical(row$CertifiedDirections, "A>B")
  expect_equal(row$MaximumBoundaryImprovement, 0.2)
  expect_identical(row$ReadinessEffect, "none_instrumentation_only")
})

test_that("MML boundary/grid summaries retain finite denominators", {
  runner <- mml_boundary_grid_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  rows <- data.frame(
    SlopeOwner = rep("Criterion", 5),
    DesignId = rep("core", 5),
    stringsAsFactors = FALSE
  )
  metrics <- c(
    "Q61CommonQ91Regret", "Q61Q91SlopeLogRMSE",
    "Q61Q91SlopeLogMaxAbs", "Q61Q91FacetRMSE", "Q61Q91FacetMaxAbs",
    "Q61Q91StepRMSE", "Q61Q91StepMaxAbs", "Q61Q91EAPRMSE",
    "Q61Q91EAPMaxAbs", "Q61Q91PosteriorSDRMSE",
    "Q61Q91PosteriorSDMaxAbs",
    "MaximumOwnGridNLLDifferenceFromDraft68",
    "MaximumCommonQ91NLLDifferenceFromDraft68"
  )
  for (metric in metrics) rows[[metric]] <- seq_len(5) / 100
  rows$Q61Q91StepMaxAbs[1] <- NA_real_
  summary <- env$mfrmr_gpcm_mml_boundary_grid_numeric_summary(rows)
  step <- summary[summary$Metric == "Q61Q91StepMaxAbs", , drop = FALSE]
  expect_identical(step$Planned, 5L)
  expect_identical(step$Finite, 4L)
  expect_identical(step$Missing, 1L)
  expect_true(is.finite(step$MCSE))
  expect_false(step$ThresholdFrozen)
})

test_that("MML boundary/grid completion validator pins the completed identity", {
  validator <- mml_boundary_grid_validator_path()
  skip_if_not(file.exists(validator),
              "repository-internal validation artifacts are excluded")
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-grid-calibration-record-0.2.3.md"
  )
  env <- new.env(parent = globalenv())
  sys.source(validator, envir = env)
  expect_true(is.function(
    env$mfrmr_validate_gpcm_mml_boundary_grid_completion
  ))
  expect_identical(
    eval(formals(
      env$mfrmr_validate_gpcm_mml_boundary_grid_completion
    )$expected_execution_sha256),
    "63a40b54a84d2c4f5c9bd9bb57deff73d1e91447dbb151cde022ce059f402ab7"
  )
  record_text <- paste(readLines(record, warn = FALSE), collapse = "\n")
  expect_match(
    record_text,
    "2164b1a9fe8cddfc4acb4bfc9a2675e4c628749181b6810718a46b59ebefdc82",
    fixed = TRUE
  )
})
