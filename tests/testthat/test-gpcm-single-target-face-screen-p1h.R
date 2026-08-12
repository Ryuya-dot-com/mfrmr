gpcm_st_p1h_paths <- function() {
  c(
    numerical = testthat::test_path(
      "..", "..", "inst", "validation",
      "numerical-stationarity-pilot-0.2.3.R"
    ),
    p0 = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-solution-stability-p0-0.2.3.R"
    ),
    p0b = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-endpoint-solution-stability-p0b-0.2.3.R"
    ),
    p1a = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-population-variance-profile-p1a-0.2.3.R"
    ),
    p1b = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-low-basin-quadrature-p1b-0.2.3.R"
    ),
    p1c = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-zero-variance-boundary-p1c-0.2.3.R"
    ),
    p1d = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-zero-variance-log-slope-path-p1d-0.2.3.R"
    ),
    p1e = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-coordinate-scaled-joint-limit-p1e-0.2.3.R"
    ),
    p1f = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-slope-rate-cone-p1f-0.2.3.R"
    ),
    p1g = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-c4-face-to-deterministic-rater-p1g-0.2.3.R"
    ),
    p1h = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-single-target-face-screen-p1h-0.2.3.R"
    ),
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-single-target-face-screen-p1h-record-0.2.3.md"
    )
  )
}

gpcm_st_p1h_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_st_p1h_paths()
    testthat::skip_if_not(
      all(file.exists(paths)),
      "internal validation artifacts are excluded"
    )
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    for (path in paths[names(paths) != "record"]) {
      sys.source(path, envir = value)
    }
    value
  }
})

gpcm_st_p1h_synthetic_context <- function() {
  n_person <- 3L
  n_criterion <- 4L
  n_rater <- 2L
  person <- rep(seq_len(n_person), each = n_criterion * n_rater)
  criterion <- rep(rep(seq_len(n_criterion), each = n_rater), n_person)
  rater <- rep(rep(seq_len(n_rater), n_criterion), n_person)
  score <- (2L * person + criterion + rater) %% 3L
  list(
    config = list(
      facet_levels = list(
        Rater = paste0("R", seq_len(n_rater)),
        Criterion = paste0("C", seq_len(n_criterion))
      ),
      n_cat = 3L,
      n_person = n_person
    ),
    sizes = list(steps = 4L),
    idx = list(
      score_k = score,
      person = person,
      slope_idx = criterion,
      facets = list(Rater = rater, Criterion = criterion),
      weight = rep(1, length(score))
    ),
    quad = list(
      nodes = c(-sqrt(3), 0, sqrt(3)),
      weights = c(1 / 6, 2 / 3, 1 / 6)
    )
  )
}

test_that("P1h freezes the P1g dependency and remaining-target plan", {
  env <- gpcm_st_p1h_environment()
  paths <- gpcm_st_p1h_paths()
  plan <- env$mfrmr_gst_p1h_plan()

  expect_identical(
    env$mfrmr_gst_p1h_contract,
    "mfrmr_gpcm_single_target_face_screen_p1h_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1g"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gst_p1h_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1h"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "860d70528718414c6f8d63f2f92410ed5269ec0319c44db44f97d66b5685524a"
  )
  expect_equal(nrow(plan$profile), 168L)
  expect_identical(unique(plan$profile$TargetIndex), 1:3)
  expect_identical(unique(plan$profile$RouteId), env$mfrmr_gst_p1h_routes)
  expect_equal(sum(plan$profile$IndependentDerivativeScheduled), 48L)
  expect_true(all(!plan$profile$SelectionAuthorized))
  expect_true(all(!plan$profile$ConfirmationAuthorized))
  expect_false(plan$AllFourSingleTargetGridsScreened)
})

test_that("P1h exact coordinates round trip for each new target", {
  env <- gpcm_st_p1h_environment()
  context <- gpcm_st_p1h_synthetic_context()
  for (target in 1:3) {
    p1f_layout <- env$mfrmr_gsrc_p1f_layout(context, target)
    y <- seq(-0.35, 0.45, length.out = p1f_layout$dimension)
    y[p1f_layout$log_lambda] <- log(0.16 + target / 100)
    converted <- env$mfrmr_gst_p1h_from_p1f(y, context, target)
    recovered <- env$mfrmr_gst_p1h_to_p1f(
      converted$z, converted$lambda, context, target
    )
    expect_equal(recovered, y, tolerance = 1e-15)
    expect_equal(converted$lambda, 0.16 + target / 100, tolerance = 1e-15)
  }
  layout <- env$mfrmr_gc4_p1g_layout(context)
  expect_error(
    env$mfrmr_gst_p1h_to_p1f(
      numeric(layout$dimension), 0.1, context, 4L
    ),
    "new single target"
  )
})

test_that("P1h equals P1f and has an independent analytic gradient", {
  env <- gpcm_st_p1h_environment()
  context <- gpcm_st_p1h_synthetic_context()
  for (target in 1:3) {
    p1f_layout <- env$mfrmr_gsrc_p1f_layout(context, target)
    y <- seq(-0.2, 0.25, length.out = p1f_layout$dimension)
    y[p1f_layout$log_lambda] <- log(0.12 + target / 100)
    converted <- env$mfrmr_gst_p1h_from_p1f(y, context, target)
    p1f <- env$mfrmr_gsrc_p1f_limit_bundle(
      y, context, target, include_gradient = FALSE
    )
    p1h <- env$mfrmr_gst_p1h_bundle(
      converted$z, converted$lambda, context, target,
      include_gradient = TRUE
    )
    numeric_gradient <- env$mfrmr_num_central_gradient(
      function(value) env$mfrmr_gst_p1h_bundle(
        value, converted$lambda, context, target,
        include_gradient = FALSE
      )$objective,
      converted$z,
      env$mfrmr_gst_p1h_derivative_step
    )
    expect_equal(p1h$objective, p1f$objective, tolerance = 1e-12)
    expect_lt(max(abs(p1h$gradient - numeric_gradient)), 1e-6)
  }
})

test_that("P1h natural lambda derivative is independently correct", {
  env <- gpcm_st_p1h_environment()
  context <- gpcm_st_p1h_synthetic_context()
  layout <- env$mfrmr_gc4_p1g_layout(context)
  z <- seq(-0.15, 0.25, length.out = layout$dimension)
  lambda <- 0.18
  h <- env$mfrmr_gst_p1h_derivative_step
  for (target in 1:3) {
    bundle <- env$mfrmr_gst_p1h_bundle(
      z, lambda, context, target, include_gradient = TRUE
    )
    numeric_lambda <- (
      env$mfrmr_gst_p1h_bundle(
        z, lambda + h, context, target, include_gradient = FALSE
      )$objective -
        env$mfrmr_gst_p1h_bundle(
          z, lambda - h, context, target, include_gradient = FALSE
        )$objective
    ) / (2 * h)
    expect_equal(bundle$lambda_gradient, numeric_lambda, tolerance = 1e-6)
  }
})

test_that("P1h singleton endpoints equal direct conditional oracles", {
  env <- gpcm_st_p1h_environment()
  context <- gpcm_st_p1h_synthetic_context()
  layout <- env$mfrmr_gc4_p1g_layout(context)
  z <- seq(-0.1, 0.2, length.out = layout$dimension)
  for (target in 1:3) {
    direct <- env$mfrmr_gst_p1h_bundle(
      z, 0, context, target, include_gradient = TRUE
    )
    oracle <- env$mfrmr_gst_p1h_conditional_oracle(z, context, target)
    expect_equal(direct$objective, oracle$objective, tolerance = 1e-12)
    expect_lt(abs(direct$lambda_gradient), 1e-12)
    expect_lt(
      max(abs(apply(direct$log_probability, 1L, diff))), 1e-15
    )
  }
})

test_that("P1h decisions remain local and portfolio remains fail closed", {
  env <- gpcm_st_p1h_environment()
  rows <- expand.grid(
    ScenarioId = "A",
    TargetIndex = 1L,
    RouteId = env$mfrmr_gst_p1h_routes,
    Lambda = env$mfrmr_gst_p1h_lambda_grid,
    stringsAsFactors = FALSE
  )
  rows$TargetSetId <- "C1"
  rows$ObjectiveQ121 <- 10 + rows$Lambda^2
  rows$ProfileMinusInteriorObjective <- 2 + rows$Lambda^2
  rows$LambdaObjectiveDerivative <- 2 * rows$Lambda
  rows$ProfileCandidateEligible <- TRUE
  pairwise <- unique(rows[c(
    "ScenarioId", "TargetIndex", "TargetSetId", "Lambda"
  )])
  pairwise$BothRoutesEligible <- TRUE
  pairwise$RouteAgreementWithinCalibrationTolerance <- TRUE
  decision <- env$mfrmr_gst_p1h_decision(
    "A", 1L, rows, pairwise
  )

  expect_true(decision$SingleTargetGridLocallyAdjudicated)
  expect_true(decision$SingletonDeterministicRaterLimitAdjudicated)
  expect_true(decision$BothEndpointObjectivesAboveInterior)
  expect_false(decision$BothEndpointObjectivesBelowInterior)
  expect_false(decision$FullSingleTargetFaceGloballyCertified)
  expect_false(decision$MultipleRandomTargetFacesEvaluated)
  expect_false(decision$EmptyRandomProductHierarchyComplete)
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)

  portfolio <- expand.grid(
    ScenarioId = paste0("S", 1:4), TargetIndex = 1:4,
    stringsAsFactors = FALSE
  )
  portfolio$SingleTargetGridLocallyAdjudicated <- TRUE
  portfolio$SingletonDeterministicRaterLimitAdjudicated <- TRUE
  portfolio$EndpointMinusInteriorMinimum <- 2
  portfolio$EndpointMinusInteriorMaximum <- 2
  overall <- env$mfrmr_gst_p1h_overall_decision(portfolio)
  expect_true(overall$AllFourSingleTargetGridsScreened)
  expect_false(overall$AnySingletonEndpointBelowQualifiedInterior)
  expect_false(overall$MultipleRandomTargetFacesEvaluated)
  expect_false(overall$MultiCriterionDeterministicRaterStrataEvaluated)
  expect_false(overall$GlobalJointBoundaryProfileCertified)
  expect_false(overall$SelectionAuthorized)
  expect_false(overall$ConfirmationAuthorized)
})

test_that("P1h dependency-complete screen remains explicitly opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the P1h single-target audit"
  )
  env <- gpcm_st_p1h_environment()
  result <- env$mfrmr_run_gpcm_single_target_face_screen_p1h(
    progress = FALSE
  )

  expect_s3_class(result, "mfrmr_gpcm_single_target_face_screen_p1h")
  expect_equal(nrow(result$profile), 168L)
  expect_equal(nrow(result$pairwise), 84L)
  expect_equal(nrow(result$decisions), 12L)
  expect_equal(nrow(result$single_target_portfolio), 16L)
  expect_true(all(result$profile$ProfileCandidateEligible))
  expect_true(all(result$pairwise$RouteAgreementWithinCalibrationTolerance))
  expect_true(all(result$decisions$BothRoutesMonotoneFromLambdaZero))
  expect_true(all(
    result$decisions$AllPositiveLambdaGridDerivativesNonnegative
  ))
  expect_true(all(result$decisions$BothEndpointObjectivesAboveInterior))
  expect_true(result$AllFourSingleTargetGridsScreened)
  expect_true(result$AllFourSingletonDeterministicRaterStrataScreened)
  expect_false(result$MultipleRandomTargetFacesEvaluated)
  expect_false(result$MultiCriterionDeterministicRaterStrataEvaluated)
  expect_false(result$EmptyRandomProductHierarchyComplete)
  expect_false(result$GlobalJointBoundaryProfileCertified)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1h record preserves singleton closure and later blockers", {
  paths <- gpcm_st_p1h_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(text, "168/168", fixed = TRUE)
  expect_match(text, "AllFourSingleTargetGridsScreened = TRUE", fixed = TRUE)
  expect_match(
    text, "AllFourSingletonDeterministicRaterStrataScreened = TRUE",
    fixed = TRUE
  )
  expect_match(text, "MultipleRandomTargetFacesEvaluated = FALSE", fixed = TRUE)
  expect_match(
    text, "MultiCriterionDeterministicRaterStrataEvaluated = FALSE",
    fixed = TRUE
  )
  expect_match(text, "EmptyRandomProductHierarchyComplete = FALSE", fixed = TRUE)
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
