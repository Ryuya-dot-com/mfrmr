gpcm_score_v3_replay_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_gpcm_score_v3_replay_runner <- function() {
  validation_dir <- gpcm_score_v3_replay_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only GPCM score v3 replay runner is unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir, "gpcm-score-v3-replay-runner-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

gpcm_score_v3_replay_artifacts_available <- function(env) {
  all(file.exists(env$mfrmr_gsv3r_default_artifacts()))
}

test_that("v3 replay rejects immutable evidence after payload drift", {
  testthat::skip_if_not_installed("digest")
  env <- load_gpcm_score_v3_replay_runner()$env
  testthat::skip_if_not(
    gpcm_score_v3_replay_artifacts_available(env),
    "Immutable local v2 replay artifacts are unavailable."
  )
  expect_error(
    env$mfrmr_run_gpcm_score_v3_replay(
      dry_run = TRUE, progress = FALSE
    ),
    "The current package payload differs from the immutable v2 payload.",
    fixed = TRUE
  )
})

test_that("v3 replay requires the exact development namespace", {
  env <- load_gpcm_score_v3_replay_runner()$env
  runtime <- env$mfrmr_gsv3r_runtime_identity()

  expect_true(runtime$DevelopmentSourceLoaded)
  expect_identical(runtime$SourceVersion, runtime$NamespaceVersion)
  expect_true(runtime$FreshSessionRequired)
  unrelated <- tempfile("not-mfrmr-source-")
  dir.create(unrelated)
  file.copy(
    file.path(runtime$ExpectedSourceRoot, "DESCRIPTION"),
    file.path(unrelated, "DESCRIPTION")
  )
  expect_error(
    env$mfrmr_gsv3r_runtime_identity(unrelated),
    "not the exact development source",
    fixed = TRUE
  )
})

test_that("v3 replay rejects changed artifact identity", {
  testthat::skip_if_not_installed("digest")
  env <- load_gpcm_score_v3_replay_runner()$env
  testthat::skip_if_not(
    gpcm_score_v3_replay_artifacts_available(env),
    "Immutable local v2 replay artifacts are unavailable."
  )
  source <- env$mfrmr_gsv3r_default_artifacts()
  changed <- tempfile(fileext = ".rds")
  saveRDS(list(changed = TRUE), changed)
  artifacts <- c(V2 = changed, Attribution = unname(source["Attribution"]))
  expect_error(
    env$mfrmr_gsv3r_validate_artifacts(artifacts),
    "artifact identity changed",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_gsv3r_validate_artifacts(c(V2 = changed)),
    "name exactly `V2` and `Attribution`",
    fixed = TRUE
  )
})

test_that("v3 failed replay retains every denominator and rejects", {
  env <- load_gpcm_score_v3_replay_runner()$env
  env$mfrmr_gsv3r_require_sources()
  scenario <- env$mfrmr_gscr_manifest()[1, , drop = FALSE]
  failed <- env$mfrmr_gsv3r_failed_evidence(scenario)

  expect_identical(nrow(failed), 16L)
  expect_identical(anyDuplicated(paste(
    failed$Point, failed$ParameterClass, sep = "::"
  )), 0L)
  expect_true(all(failed$SlopeRegion == "not_evaluable"))
  expect_true(all(!failed$StructuralOraclePass))
  expect_true(all(!failed$AnalyticScorePass))
  expect_true(all(!failed$EvaluationComplete))
  expect_true(all(!failed$ExtremeSlopeReviewHandoff))
  expected <- env$mfrmr_gsv3_expected_scenarios
  grid <- do.call(rbind, lapply(seq_along(expected), function(index) {
    row <- scenario
    row$ScenarioId <- expected[index]
    env$mfrmr_gsv3r_failed_evidence(row)
  }))
  expect_identical(env$mfrmr_gsv3_decision(grid)$Status, "rejected")
})

test_that("v3 point audit evaluates finite differences only in finite region", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("digest")
  skip_if_frozen_gpcm_payload_drifted()
  env <- load_gpcm_score_v3_replay_runner()$env
  env$mfrmr_gsv3r_require_sources()
  scenario <- env$mfrmr_gscr_manifest()
  scenario <- scenario[
    scenario$ScenarioId == "NUM-GPCM-SCORE-CAL-C-CORE5", , drop = FALSE
  ]
  fitted <- env$mfrmr_gscr_fit(scenario)
  expect_true(is.na(fitted$error))
  expect_false(is.null(fitted$fit))
  audit <- env$mfrmr_gsv3r_point_audit(
    fitted$fit, scenario, "finite_slope_stress_forward"
  )

  expect_identical(nrow(audit$evidence), 4L)
  expect_true(all(audit$evidence$SlopeRegion == "finite_slope_region"))
  expect_true(all(audit$evidence$StructuralOraclePass))
  expect_true(all(audit$evidence$AnalyticScorePass))
  expect_true(all(audit$evidence$FiniteDifferenceStatus == "pass"))
  expect_true(all(is.finite(
    audit$evidence$FiniteDifferenceCombinedRatio
  )))
  expect_true(all(is.finite(audit$jacobian$LogCombinedRatio)))
  expect_true(all(is.finite(audit$jacobian$SlopeCombinedRatio)))
  expect_identical(nrow(audit$jacobian), 12L)
  expect_false(audit$point_summary$BoundaryProven)
  expect_false(audit$point_summary$ConfirmationAuthorized)
})

test_that("near-tie GPCM optimization is deterministic and RNG-neutral", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("digest")
  skip_if_frozen_gpcm_payload_drifted()
  env <- load_gpcm_score_v3_replay_runner()$env
  env$mfrmr_gsv3r_require_sources()
  scenario <- env$mfrmr_gscr_manifest()
  scenario <- scenario[
    scenario$ScenarioId == "NUM-GPCM-SCORE-CAL-C-WEAK5", , drop = FALSE
  ]
  set.seed(230811)
  rng_before <- .Random.seed
  first <- env$mfrmr_gscr_fit(scenario)$fit
  rng_after_first <- .Random.seed
  second <- env$mfrmr_gscr_fit(scenario)$fit
  rng_after_second <- .Random.seed

  expect_false(is.null(first))
  expect_false(is.null(second))
  expect_identical(rng_after_first, rng_before)
  expect_identical(rng_after_second, rng_before)
  expect_identical(first$opt$convergence, second$opt$convergence)
  expect_identical(first$opt$value, second$opt$value)
  expect_identical(first$opt$par, second$opt$par)
  semantic_stage_columns <- setdiff(
    names(first$opt$optimizer_polish$Stages), "ElapsedSeconds"
  )
  expect_identical(
    first$opt$optimizer_polish$Stages[, semantic_stage_columns, drop = FALSE],
    second$opt$optimizer_polish$Stages[, semantic_stage_columns, drop = FALSE]
  )
})
