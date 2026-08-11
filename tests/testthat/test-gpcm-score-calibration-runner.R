gpcm_score_runner_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_gpcm_score_calibration_runner <- function() {
  validation_dir <- gpcm_score_runner_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only GPCM score-calibration runner is unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir,
    "gpcm-score-calibration-runner-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

test_that("the exact runner dry-run binds identity and never executes", {
  testthat::skip_if_not_installed("digest")
  env <- load_gpcm_score_calibration_runner()$env
  dry <- env$mfrmr_run_gpcm_score_calibration(
    dry_run = TRUE, progress = FALSE
  )

  expect_identical(
    dry$contract_version,
    "mfrmr_gpcm_score_calibration_execution_v1"
  )
  expect_identical(nrow(dry$manifest), 8L)
  expect_identical(anyDuplicated(dry$manifest$ScenarioId), 0L)
  expect_true(all(nchar(dry$manifest$PackagePayloadSHA256) == 64L))
  expect_true(all(nchar(dry$manifest$DesignSHA256) == 64L))
  expect_true(all(nchar(dry$manifest$OracleSHA256) == 64L))
  expect_true(all(nchar(dry$manifest$RunnerSHA256) == 64L))
  expect_true(all(nchar(dry$manifest$ManifestSHA256) == 64L))
  expect_identical(length(unique(dry$manifest$ManifestSHA256)), 1L)
  expect_false(dry$executed)
  expect_false(dry$calibration_execution_authorized)
  expect_false(dry$general_num_score_tol_frozen)
  expect_false(dry$confirmation_authorized)
  expect_false(exists("fits", envir = env, inherits = FALSE))
  expect_false(exists("evidence", envir = env, inherits = FALSE))
  expect_error(
    env$mfrmr_run_gpcm_score_calibration(
      dry_run = FALSE, authorize = FALSE, progress = FALSE
    ),
    "explicit `authorize = TRUE`",
    fixed = TRUE
  )
})

test_that("the runner five-point bundle retains derivative diagnostics", {
  env <- load_gpcm_score_calibration_runner()$env
  point <- c(-1.2, 0.5, 2.0)
  fn <- function(value) sum(value^4 + 2 * value^2 - 3 * value)
  expected <- 4 * point^3 + 4 * point - 3
  out <- env$mfrmr_gscr_five_point_bundle(fn, point, 3e-4)

  expect_equal(out$score, expected, tolerance = 1e-9)
  expect_true(all(is.finite(out$max_abs_objective)))
  expect_equal(out$absolute_step, 3e-4 * pmax(1, abs(point)))
  expect_identical(out$relative_step, 3e-4)
  expect_error(
    env$mfrmr_gscr_five_point_bundle(sum, numeric(0), 3e-4),
    "non-empty finite numeric vector",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_gscr_five_point_bundle(sum, point, 0),
    "one finite positive value",
    fixed = TRUE
  )
  nonfinite <- env$mfrmr_gscr_five_point_bundle(
    function(value) if (value[1] > 0) Inf else sum(value^2),
    c(0, 0),
    1e-4
  )
  expect_true(is.na(nonfinite$score[1]))
  expect_true(is.finite(nonfinite$score[2]))
})

test_that("coordinate ownership maps to the frozen four classes", {
  env <- load_gpcm_score_calibration_runner()$env
  coordinates <- data.frame(
    ParameterClass = c("Rater", "Criterion", "steps", "log_slopes"),
    stringsAsFactors = FALSE
  )

  expect_identical(
    env$mfrmr_gscr_parameter_class(coordinates, "Criterion"),
    c("other_additive", "owner_additive", "steps", "log_slopes")
  )
  expect_identical(
    env$mfrmr_gscr_parameter_class(coordinates, "Rater"),
    c("owner_additive", "other_additive", "steps", "log_slopes")
  )
  malformed <- rbind(
    coordinates,
    data.frame(ParameterClass = "theta", stringsAsFactors = FALSE)
  )
  expect_error(
    env$mfrmr_gscr_parameter_class(malformed, "Rater"),
    "do not match the frozen four-class design",
    fixed = TRUE
  )
})

test_that("failed scenarios retain every required evidence denominator", {
  env <- load_gpcm_score_calibration_runner()$env
  scenario <- env$mfrmr_gscr_manifest()[1, , drop = FALSE]
  failed <- env$mfrmr_gscr_failed_evidence(scenario)

  expect_identical(nrow(failed), 16L)
  expect_identical(anyDuplicated(paste(
    failed$Point, failed$ParameterClass, sep = "::"
  )), 0L)
  expect_true(all(!failed$StepLadderComplete))
  expect_true(all(!failed$StructuralOraclePass))
  expect_true(all(!failed$EvaluationComplete))
  expect_true(all(is.na(failed$MaxAbsDifference)))
  decision_grid <- do.call(rbind, lapply(seq_len(8L), function(index) {
    row <- scenario
    row$ScenarioId <- env$mfrmr_gsc_scenarios()$ScenarioId[index]
    env$mfrmr_gscr_failed_evidence(row)
  }))
  expect_identical(env$mfrmr_gsc_decision(decision_grid)$Status, "rejected")
})
