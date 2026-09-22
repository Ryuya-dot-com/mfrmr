numerical_stationarity_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_numerical_stationarity_pilot <- function() {
  validation_dir <- numerical_stationarity_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only numerical-stationarity validation files are unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir,
    "numerical-stationarity-pilot-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

numerical_stationarity_score_rows <- function(run_id = "rsm_core",
                                              point = "retained_solution") {
  out <- expand.grid(
    RelativeStep = c(1e-4, 3e-5, 1e-5),
    CoordinateIndex = 1:2,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  out$RunId <- run_id
  out$ScenarioId <- "NUM-RSM-CORE"
  out$Model <- "RSM"
  out$Point <- point
  out$AnalyticScore <- c(0.2, 0.2, 0.2, -0.4, -0.4, -0.4)
  out$NumericScore <- out$AnalyticScore +
    rep(c(2e-8, -1e-8, 1e-8), times = 2L)
  out$AbsDifference <- abs(out$AnalyticScore - out$NumericScore)
  out$ScaledDifference <- out$AbsDifference
  out$MfrmrInferenceReady <- TRUE
  out
}

test_that("the numerical stationarity plan is fixed and never auto-executes", {
  loaded <- load_numerical_stationarity_pilot()
  env <- loaded$env
  plan <- env$mfrmr_num_plan()

  expect_identical(env$mfrmr_num_specification, "0.2.3-draft.12")
  expect_identical(
    env$mfrmr_num_contract,
    "mfrmr_mml_canonical_score_audit_v1"
  )
  expect_identical(env$mfrmr_num_primary_step, 3e-5)
  expect_identical(env$mfrmr_num_step_ladder, c(1e-4, 3e-5, 1e-5))
  expect_identical(
    plan$RunId,
    c("binary_rsm", "binary_pcm", "rsm_core", "pcm_core", "gpcm_core")
  )
  expect_identical(
    plan$ScenarioId,
    c(
      "NUM-BIN-REDUCE", "NUM-BIN-REDUCE", "NUM-RSM-CORE",
      "NUM-PCM-CORE", "NUM-GPCM-BOUND"
    )
  )
  expect_identical(plan$Model, c("RSM", "PCM", "RSM", "PCM", "GPCM"))
  expect_true(all(plan$QuadPoints == 31L))
  expect_true(all(plan$Maxit == 2000L))
  expect_true(all(plan$Reltol == 1e-12))
  expect_true(all(!plan$SelectionAuthorized))
  expect_true(all(!plan$ConfirmationAuthorized))
  expect_false(exists("numerical", envir = env, inherits = FALSE))
  expect_false(exists("fits", envir = env, inherits = FALSE))

  expect_error(
    env$mfrmr_run_numerical_stationarity_pilot(
      rel_steps = c(3e-5, 3e-5, 1e-5)
    ),
    "at least three positive steps",
    fixed = TRUE
  )
})

test_that("fixed stationarity fixtures preserve identity and category support", {
  testthat::skip_if_not_installed("digest")
  env <- load_numerical_stationarity_pilot()$env

  set.seed(4801)
  expected_rng <- stats::runif(2)
  set.seed(4801)
  expect_equal(stats::runif(1), expected_rng[1])
  binary <- env$mfrmr_num_fixture("binary_fixed")
  expect_equal(stats::runif(1), expected_rng[2])
  polytomous <- env$mfrmr_num_fixture("polytomous_fixed")

  expect_identical(binary$seed, 20260741L)
  expect_identical(polytomous$seed, 20260742L)
  expect_identical(nrow(binary$data), 240L)
  expect_identical(nrow(polytomous$data), 240L)
  expect_identical(binary$rating_max, 1L)
  expect_identical(polytomous$rating_max, 3L)
  expect_identical(sort(unique(binary$data$Score)), 0:1)
  expect_identical(sort(unique(polytomous$data$Score)), 0:3)
  expect_true(all(binary$category_counts$Freq > 0L))
  expect_true(all(polytomous$category_counts$Freq > 0L))
  expect_equal(
    as.numeric(tapply(
      binary$category_counts$Freq,
      binary$category_counts$Item,
      sum
    )),
    rep(60, 4L)
  )
  expect_equal(
    as.numeric(tapply(
      polytomous$category_counts$Freq,
      polytomous$category_counts$Item,
      sum
    )),
    rep(60, 4L)
  )
  expect_identical(
    binary$sha256,
    "acde9c859ad63d8b1b0736f19ae5869c72384734133eafb7602382d97b9b0f21"
  )
  expect_identical(
    polytomous$sha256,
    "383979d685be5719d2844476eeb1126dd586d070c7a1926199ac31f89867ae1e"
  )
  expect_identical(
    env$mfrmr_num_fixture("binary_fixed")$sha256,
    binary$sha256
  )
  expect_error(
    env$mfrmr_num_fixture("unknown"),
    "must be 'binary_fixed' or 'polytomous_fixed'",
    fixed = TRUE
  )
})

test_that("the independent central score uses declared free coordinates", {
  env <- load_numerical_stationarity_pilot()$env
  coordinates <- env$mfrmr_num_coordinate_table(list(
    theta = 1L,
    Item = 2L,
    steps = 0L,
    log_slopes = 3L
  ))

  expect_identical(coordinates$CoordinateIndex, 1:6)
  expect_identical(
    coordinates$CoordinateLabel,
    c(
      "theta[1]", "Item[1]", "Item[2]", "log_slopes[1]",
      "log_slopes[2]", "log_slopes[3]"
    )
  )
  expect_true(all(
    coordinates$CoordinateSystem ==
      "identified_free_optimizer_coordinates_v1"
  ))
  expect_error(
    env$mfrmr_num_coordinate_table(list(1L, 2L)),
    "named parameter-size list",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_num_coordinate_table(list(theta = 1.5)),
    "nonnegative integer",
    fixed = TRUE
  )

  center <- c(-0.3, 0.7, 1.2)
  point <- c(0.4, -1.1, 2.0)
  numeric_score <- env$mfrmr_num_central_gradient(
    function(value) sum((value - center)^2),
    point,
    rel_step = 3e-5
  )
  expect_equal(numeric_score, 2 * (point - center), tolerance = 1e-10)
  expect_error(
    env$mfrmr_num_central_gradient(sum, point, rel_step = c(1e-4, 1e-5)),
    "one finite positive value",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_num_central_gradient(sum, point, rel_step = 0),
    "one finite positive value",
    fixed = TRUE
  )
  partly_nonfinite <- env$mfrmr_num_central_gradient(
    function(value) {
      if (value[1] > 0) return(Inf)
      sum(value^2)
    },
    c(0, 0),
    rel_step = 1e-5
  )
  expect_true(is.na(partly_nonfinite[1]))
  expect_true(is.finite(partly_nonfinite[2]))
})

test_that("the positive-slope GPCM Jacobian is explicit and checked", {
  env <- load_numerical_stationarity_pilot()$env
  free <- c(-0.4, 0.1, 0.2)
  review <- env$mfrmr_num_gpcm_jacobian_from_free(
    free,
    levels = paste0("I", 1:4),
    point = "known_probe"
  )

  expect_identical(review$summary$Status, "review_complete")
  expect_identical(review$summary$FreeCoordinates, 3L)
  expect_identical(review$summary$ExpandedLevels, 4L)
  expect_lt(review$summary$GeometricMeanResidual, 1e-15)
  expect_lt(review$summary$MaxAbsLogJacobianDifference, 1e-8)
  expect_lt(review$summary$MaxAbsSlopeJacobianDifference, 1e-8)
  expect_true(all(review$table$ExpandedSlope > 0))
  expect_equal(
    review$table$ExpandedLogSlope[
      !duplicated(review$table$ExpandedLevel)
    ],
    c(free, -sum(free)),
    tolerance = 0
  )
  expect_true(all(
    review$table$CoordinateSystem ==
      "free_log_slopes_to_sum_zero_logs_to_positive_slopes_v1"
  ))
  expect_false(review$summary$SelectionAuthorized)
  expect_false(review$summary$ConfirmationAuthorized)

  expect_error(
    env$mfrmr_num_gpcm_jacobian_from_free(free, rel_step = 0),
    "finite n-1 free log slopes and n labels",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_num_gpcm_jacobian_from_free(
      free,
      levels = rep("duplicate", 4L)
    ),
    "finite n-1 free log slopes and n labels",
    fixed = TRUE
  )
})

test_that("canonical-score summaries reject incomplete step ladders", {
  env <- load_numerical_stationarity_pilot()$env
  rows <- numerical_stationarity_score_rows()
  summary <- env$mfrmr_num_score_summarize(rows)

  expect_identical(summary$ReferenceStatus, "review_complete")
  expect_identical(summary$CoordinateCount, 2L)
  expect_equal(
    summary$MaxAbsDifference,
    max(rows$AbsDifference[rows$RelativeStep == 3e-5]),
    tolerance = 0
  )
  expect_true(summary$MfrmrInferenceReady)
  expect_false(summary$SelectionAuthorized)
  expect_false(summary$ConfirmationAuthorized)

  missing_step <- rows[-1, , drop = FALSE]
  rejected <- env$mfrmr_num_score_summarize(missing_step)
  expect_identical(rejected$ReferenceStatus, "rejected")
  expect_true(is.na(rejected$MaxAbsDifference))

  duplicate <- rbind(rows, rows[1, , drop = FALSE])
  rejected_duplicate <- env$mfrmr_num_score_summarize(duplicate)
  expect_identical(rejected_duplicate$ReferenceStatus, "rejected")

  second <- numerical_stationarity_score_rows(
    run_id = "pcm_core",
    point = "deterministic_probe"
  )
  missing_primary <- rows[rows$RelativeStep != 3e-5, , drop = FALSE]
  mixed <- env$mfrmr_num_score_summarize(rbind(missing_primary, second))
  expect_identical(
    mixed$ReferenceStatus[mixed$RunId == "rsm_core"],
    "rejected"
  )
  expect_identical(
    mixed$ReferenceStatus[mixed$RunId == "pcm_core"],
    "review_complete"
  )

  nonfinite <- rows
  nonfinite$NumericScore[nonfinite$RelativeStep == 3e-5][1] <- NA_real_
  expect_identical(
    env$mfrmr_num_score_summarize(nonfinite)$ReferenceStatus,
    "rejected"
  )
  expect_error(
    env$mfrmr_num_score_summarize(rows[, setdiff(names(rows), "RunId")]),
    "does not satisfy",
    fixed = TRUE
  )
  missing_label <- rows
  missing_label$Point[1] <- NA_character_
  expect_error(
    env$mfrmr_num_score_summarize(missing_label),
    "complete run, scenario, model, and point labels",
    fixed = TRUE
  )
})

test_that("the five-run pilot records review evidence and fails closed", {
  testthat::skip_if_not_installed("digest")
  skip_if_frozen_gpcm_payload_drifted()
  env <- load_numerical_stationarity_pilot()$env
  pilot <- env$mfrmr_run_numerical_stationarity_pilot()

  expect_s3_class(pilot, "mfrmr_numerical_stationarity_pilot")
  expect_identical(pilot$specification, "0.2.3-draft.12")
  expect_identical(pilot$status, "review")
  expect_identical(nrow(pilot$fixture_manifest), 2L)
  expect_identical(nrow(pilot$score_summary), 10L)
  expect_true(all(
    pilot$score_summary$ReferenceStatus == "review_complete"
  ))
  expect_lt(max(pilot$score_summary$MaxAbsDifference), 1e-6)
  expect_lt(max(pilot$score_summary$MaxScaledDifference), 1e-6)
  expect_lt(max(pilot$score_summary$MaxNumericStepRange), 1e-5)
  expect_true(all(
    pilot$gpcm_jacobian$summary$Status == "review_complete"
  ))
  expect_lt(
    max(pilot$gpcm_jacobian$summary$MaxAbsSlopeJacobianDifference),
    1e-7
  )
  expect_identical(
    pilot$reduction_results$ReductionId,
    c("binary_rsm_equals_pcm", "unit_slope_gpcm_equals_pcm")
  )
  expect_true(all(pilot$reduction_results$ExactReductionObserved))
  expect_lte(
    max(pilot$reduction_results$LogProbabilityMaxAbsDifference),
    1e-12
  )
  expect_lte(
    max(pilot$reduction_results$ProbabilityMaxAbsDifference),
    1e-12
  )
  expect_lte(
    max(pilot$reduction_results$ObjectiveAbsDifference),
    1e-10
  )
  expect_lte(
    max(pilot$reduction_results$CommonScoreMaxAbsDifference),
    1e-10
  )
  expect_lte(
    max(pilot$reduction_results$IndependentLogProbabilityMaxAbsDifference),
    1e-12
  )
  expect_lte(
    max(pilot$reduction_results$IndependentProbabilityMaxAbsDifference),
    1e-12
  )
  expect_lte(
    max(pilot$reduction_results$IndependentObjectiveAbsDifference),
    1e-10
  )
  expect_lte(
    max(pilot$reduction_results$IndependentCommonScoreMaxAbsDifference),
    1e-6
  )
  expect_true(all(
    pilot$reduction_results$TransformReductionObserved
  ))
  expect_lte(
    max(pilot$reduction_results$CommonFreeCoordinateMaxAbsDifference),
    1e-12
  )
  expect_lte(
    max(pilot$reduction_results$ExpandedStepMaxAbsDifference),
    1e-12
  )
  gpcm_reduction <- pilot$reduction_results[
    pilot$reduction_results$ReductionId == "unit_slope_gpcm_equals_pcm",
    ,
    drop = FALSE
  ]
  expect_lte(gpcm_reduction$ExpandedLogSlopeMaxAbsDifference, 1e-12)
  expect_lte(
    gpcm_reduction$ExpandedSlopeMaxAbsDifferenceFromOne,
    1e-12
  )
  expect_true(pilot$summary$FixedFixturesComplete)
  expect_true(pilot$summary$AllScoreReferencesComplete)
  expect_true(pilot$summary$GpcmTransformationJacobianComplete)
  expect_true(pilot$summary$ExactReductionsObserved)
  expect_identical(pilot$summary$ScoreToleranceStatus, "pilot_required")
  expect_identical(pilot$summary$EngineParityStatus, "not_run")
  expect_false(pilot$summary$SelectionAuthorized)
  expect_false(pilot$summary$ConfirmationAuthorized)
  expect_false(pilot$selection_authorized)
  expect_false(pilot$confirmation_authorized)

  incomplete_score <- pilot$score_summary[-1, , drop = FALSE]
  score_fail_closed <- env$mfrmr_num_global_summary(
    incomplete_score,
    pilot$gpcm_jacobian$summary,
    pilot$reduction_results,
    pilot$fixture_manifest
  )
  expect_false(score_fail_closed$AllScoreReferencesComplete)
  expect_true(is.na(score_fail_closed$MaxAbsScoreDifference))

  rejected_jacobian <- pilot$gpcm_jacobian$summary
  rejected_jacobian$Status[1] <- "rejected"
  jacobian_fail_closed <- env$mfrmr_num_global_summary(
    pilot$score_summary,
    rejected_jacobian,
    pilot$reduction_results,
    pilot$fixture_manifest
  )
  expect_false(jacobian_fail_closed$GpcmTransformationJacobianComplete)
  expect_true(is.na(jacobian_fail_closed$MaxSlopeJacobianDifference))

  rejected_reduction <- pilot$reduction_results
  rejected_reduction$ExactReductionObserved[1] <- FALSE
  reduction_fail_closed <- env$mfrmr_num_global_summary(
    pilot$score_summary,
    pilot$gpcm_jacobian$summary,
    rejected_reduction,
    pilot$fixture_manifest
  )
  expect_false(reduction_fail_closed$ExactReductionsObserved)

  mutated_oracle <- pilot$reduction_results
  mutated_oracle$IndependentObjectiveAbsDifference[1] <- 1
  oracle_fail_closed <- env$mfrmr_num_global_summary(
    pilot$score_summary,
    pilot$gpcm_jacobian$summary,
    mutated_oracle,
    pilot$fixture_manifest
  )
  expect_false(oracle_fail_closed$ExactReductionsObserved)

  mutated_transform <- pilot$reduction_results
  mutated_transform$ExpandedSlopeMaxAbsDifferenceFromOne[
    mutated_transform$ReductionId == "unit_slope_gpcm_equals_pcm"
  ] <- 0.1
  transform_fail_closed <- env$mfrmr_num_global_summary(
    pilot$score_summary,
    pilot$gpcm_jacobian$summary,
    mutated_transform,
    pilot$fixture_manifest
  )
  expect_false(transform_fail_closed$ExactReductionsObserved)

  invalid_fixture <- pilot$fixture_manifest
  invalid_fixture$SHA256[1] <- "not-a-sha256"
  fixture_fail_closed <- env$mfrmr_num_global_summary(
    pilot$score_summary,
    pilot$gpcm_jacobian$summary,
    pilot$reduction_results,
    invalid_fixture
  )
  expect_false(fixture_fail_closed$FixedFixturesComplete)

  expect_error(
    env$mfrmr_num_global_summary(
      pilot$score_summary[, -match("Point", names(pilot$score_summary))],
      pilot$gpcm_jacobian$summary,
      pilot$reduction_results,
      pilot$fixture_manifest
    ),
    "`score_summary` is incomplete",
    fixed = TRUE
  )
})
