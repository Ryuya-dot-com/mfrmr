mml_integration_runner_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-integration-sensitivity-0.2.3.R"
  )
}

mml_integration_validator_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-integration-completion-validator-0.2.3.R"
  )
}

test_that("MML integration sensitivity pins its grids and source execution", {
  runner <- mml_integration_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  contract <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-integration-sensitivity-contract-0.2.3.md"
  )
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-integration-sensitivity-record-0.2.3.md"
  )
  expect_true(file.exists(runner))
  expect_true(file.exists(contract))
  expect_true(file.exists(record))

  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  expect_identical(env$mfrmr_gpcm_mml_quad_points, c(31L, 61L, 91L))
  expect_identical(
    env$mfrmr_gpcm_mml_runtime_sha256,
    "31c87d7a888ca760afa02476f1c226bae148403475e34b75eefaaa9679522920"
  )
  expect_identical(
    env$mfrmr_gpcm_mml_owner_execution_sha256,
    "f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037"
  )

  contract_text <- paste(readLines(contract, warn = FALSE), collapse = "\n")
  expect_match(contract_text, "q=31, q=61, and q=91", fixed = TRUE)
  expect_match(contract_text, "common q=91 grid", fixed = TRUE)
  expect_match(contract_text, "no adaptive node addition", fixed = TRUE)
  expect_match(contract_text, "Zero-common-Person MML rows remain", fixed = TRUE)
})

test_that("MML integration vector comparisons preserve identified coordinates", {
  skip_if_not(file.exists(mml_integration_runner_path()),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(mml_integration_runner_path(), envir = env)
  make_fit <- function(offset = 0) {
    list(
      slopes = data.frame(
        SlopeFacet = c("A", "B"),
        OptimizerLogEstimate = c(-0.2, 0.2) + offset
      ),
      steps = data.frame(
        StepFacet = c("A", "A"), Step = c("S1", "S2"),
        Estimate = c(-0.5, 0.5) + offset
      ),
      facets = list(
        others = data.frame(
          Facet = c("Rater", "Rater"), Level = c("R1", "R2"),
          Estimate = c(-0.1, 0.1) + offset
        ),
        person = data.frame(
          Person = c("P1", "P2"), Estimate = c(-0.3, 0.3) + offset,
          PosteriorSD = c(0.4, 0.5) + offset
        )
      )
    )
  }

  baseline <- make_fit(0)
  candidate <- make_fit(0.05)
  for (component in c(
    "log_slope", "facet", "step", "eap", "posterior_sd"
  )) {
    difference <- env$mfrmr_gpcm_mml_difference(
      candidate, baseline, component
    )
    expect_identical(as.integer(difference[["N"]]), 2L)
    expect_equal(unname(difference[["RMSE"]]), 0.05)
    expect_equal(unname(difference[["MaxAbs"]]), 0.05)
  }
})

test_that("MML sensitivity summaries retain planned and finite denominators", {
  skip_if_not(file.exists(mml_integration_runner_path()),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(mml_integration_runner_path(), envir = env)
  assign(
    "mfrmr_gpcm_repilot_wilson",
    function(successes, trials) c(Lower = 0, Upper = 1),
    envir = env
  )
  rows <- expand.grid(
    SlopeOwner = "Criterion", DesignId = "core",
    QuadraturePoints = c(31L, 61L), Replicate = 1:5,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  rows$FitSucceeded <- TRUE
  rows$ConvergenceSeverity <- "pass"
  rows$EvidenceInferenceReady <- FALSE
  numeric_metrics <- c(
    "CommonQ91Regret", "SlopeLogRMSETruth", "SlopeLogDeltaRMSE",
    "SlopeLogDeltaMaxAbs", "FacetDeltaMaxAbs", "StepDeltaMaxAbs",
    "EAPDeltaRMSE", "EAPDeltaMaxAbs", "PosteriorSDDeltaRMSE",
    "PosteriorSDDeltaMaxAbs"
  )
  for (metric in numeric_metrics) rows[[metric]] <- seq_len(nrow(rows)) / 100
  rows$CommonQ91Regret[1] <- NA_real_

  rate <- env$mfrmr_gpcm_mml_rate_summary(rows)
  numeric <- env$mfrmr_gpcm_mml_numeric_summary(rows)
  expect_true(all(rate$Planned == 5L))
  expect_true(all(rate$FitCount == 5L))
  expect_true(all(rate$EvidenceReadyCount == 0L))
  regret31 <- numeric[
    numeric$QuadraturePoints == 31L &
      numeric$Metric == "CommonQ91Regret", , drop = FALSE
  ]
  expect_identical(regret31$Planned, 5L)
  expect_identical(regret31$Finite, 4L)
  expect_identical(regret31$Missing, 1L)
  expect_true(is.finite(regret31$MCSE))
  expect_false(regret31$ThresholdFrozen)
})

test_that("MML completion validator pins identity and is independently registered", {
  validator <- mml_integration_validator_path()
  skip_if_not(file.exists(validator),
              "repository-internal validation artifacts are excluded")
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-integration-sensitivity-record-0.2.3.md"
  )
  expect_true(file.exists(validator))
  env <- new.env(parent = globalenv())
  sys.source(validator, envir = env)
  expect_true(is.function(
    env$mfrmr_validate_gpcm_mml_integration_completion
  ))
  expect_identical(
    eval(formals(
      env$mfrmr_validate_gpcm_mml_integration_completion
    )$expected_execution_sha256),
    "d993825cc8a58a3e3e1d17c6e4a8a6e2cc4fb16611c0429acd32296b81f70e70"
  )
  record_text <- paste(readLines(record, warn = FALSE), collapse = "\n")
  expect_match(
    record_text,
    "94402103a41e7461f4d419ca68dafc87070b809bf043117649af65b8dbb80f8a",
    fixed = TRUE
  )
})
