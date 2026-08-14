load_gpcm_slope_action_projection <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  source_path <- file.path(
    root, "inst", "validation",
    "gpcm-slope-action-projection-p3a-0.2.3.R"
  )
  record_path <- file.path(
    root, "inst", "validation",
    "gpcm-slope-action-projection-p3a-record-0.2.3.md"
  )
  expect_true(file.exists(source_path))
  expect_true(file.exists(record_path))
  env <- new.env(parent = globalenv())
  sys.source(source_path, envir = env)
  list(env = env, source_path = source_path, record_path = record_path)
}

test_that("slope-action cross-difference identifies the two model families", {
  context <- load_gpcm_slope_action_projection()
  scenarios <- context$env$mfrmr_gsap_scenarios()

  for (scenario_name in names(scenarios)) {
    parameters <- scenarios[[scenario_name]]$parameters
    loading <- context$env$mfrmr_gsap_cross_difference(
      parameters, "loading_only"
    )
    complete <- context$env$mfrmr_gsap_cross_difference(
      parameters, "complete_predictor"
    )
    expected <- -(
      parameters$slopes[1L] - parameters$slopes[4L]
    ) * (
      parameters$severities[1L] - parameters$severities[4L]
    )
    expect_equal(loading, 0, tolerance = 1e-14, info = scenario_name)
    expect_equal(complete, expected, tolerance = 1e-14,
                 info = scenario_name)
  }
})

test_that("population projection separates exact reductions from misspecification", {
  context <- load_gpcm_slope_action_projection()
  result <- context$env$mfrmr_run_gpcm_slope_action_projection()

  expect_identical(
    result$status,
    "gpcm_slope_action_population_projection_complete"
  )
  expect_identical(nrow(result$projections), 16L)
  expect_identical(nrow(result$invariants), 4L)
  expect_identical(nrow(result$stability), 8L)
  expect_identical(sort(unique(result$projections$Nodes)), c(31L, 41L))
  expect_true(all(result$projections$OptimizerConvergence == 0L))

  reductions <- result$projections$ExactEquivalenceExpected
  crossed <- !reductions
  expect_true(all(result$projections$ProjectedKLPerResponse[reductions] < 1e-10))
  expect_true(all(
    result$projections$MaxProbabilityDifference[reductions] < 1e-5
  ))
  expect_true(all(result$projections$ProjectedKLPerResponse[crossed] > 1e-7))
  expect_true(all(
    result$projections$MaxProbabilityDifference[crossed] > 1e-4
  ))
  expect_true(all(
    result$projections$ProjectedKLPerResponse <=
      result$projections$StartKLPerResponse + 1e-12
  ))
  expect_true(all(result$stability$ProjectedKLAbsQ41MinusQ31 < 1e-6))
  expect_true(all(
    result$stability$MaxProbabilityDifferenceAbsQ41MinusQ31 < 1e-5
  ))

  expect_false(result$implemented_family_changed)
  expect_false(result$loading_only_public_family_added)
  expect_false(result$readiness_overridden)
  expect_false(result$scientific_threshold_frozen)
  expect_false(result$release_authorized)

  source_text <- paste(readLines(context$source_path), collapse = "\n")
  record_text <- paste(readLines(context$record_path), collapse = "\n")
  cryptographic_term <- "\\bSHA(?:-[0-9]+)?\\b|digest::|\\bmd5\\b"
  expect_false(grepl(
    cryptographic_term, source_text, ignore.case = TRUE, perl = TRUE
  ))
  expect_false(grepl(
    cryptographic_term, record_text, ignore.case = TRUE, perl = TRUE
  ))
  expect_match(record_text, "LoadingOnlyPublicFamilyAdded = FALSE", fixed = TRUE)
  expect_match(record_text, "ReadinessOverridden = FALSE", fixed = TRUE)
})
