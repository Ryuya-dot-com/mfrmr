gpcm_c4_p1g_paths <- function() {
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
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-c4-face-to-deterministic-rater-p1g-record-0.2.3.md"
    )
  )
}

gpcm_c4_p1g_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_c4_p1g_paths()
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

gpcm_c4_p1g_synthetic_context <- function() {
  n_person <- 3L
  n_criterion <- 4L
  n_rater <- 2L
  person <- rep(seq_len(n_person), each = n_criterion * n_rater)
  criterion <- rep(rep(seq_len(n_criterion), each = n_rater), n_person)
  rater <- rep(rep(seq_len(n_rater), n_criterion), n_person)
  score <- (person + criterion + rater) %% 3L
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

test_that("P1g freezes the P1f dependency and C4-only plan", {
  env <- gpcm_c4_p1g_environment()
  paths <- gpcm_c4_p1g_paths()
  plan <- env$mfrmr_gc4_p1g_plan()

  expect_identical(
    env$mfrmr_gc4_p1g_contract,
    "mfrmr_gpcm_c4_face_to_deterministic_rater_p1g_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1f"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gc4_p1g_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1g"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "210bba683ab154d9684db9bb2fab67b7f56d8478cf950e0de742db2563f239f3"
  )
  expect_equal(nrow(plan$profile), 56L)
  expect_equal(sort(unique(plan$profile$Lambda)), env$mfrmr_gc4_p1g_lambda_grid)
  expect_identical(
    unique(plan$profile$RouteId), env$mfrmr_gc4_p1g_routes
  )
  expect_equal(sum(plan$profile$IndependentDerivativeScheduled), 16L)
  expect_true(all(!plan$profile$SelectionAuthorized))
  expect_true(all(!plan$profile$ConfirmationAuthorized))
  expect_false(plan$FullC4FaceGloballyCertified)
})

test_that("P1g scaled coordinates round trip exactly for lambda positive", {
  env <- gpcm_c4_p1g_environment()
  context <- gpcm_c4_p1g_synthetic_context()
  p1f_layout <- env$mfrmr_gsrc_p1f_layout(context, 4L)
  y <- seq(-0.4, 0.5, length.out = p1f_layout$dimension)
  y[p1f_layout$log_lambda] <- log(0.17)
  converted <- env$mfrmr_gc4_p1g_from_p1f(y, context, 4L)
  recovered <- env$mfrmr_gc4_p1g_to_p1f(
    converted$z, converted$lambda, context, 4L
  )

  expect_equal(converted$lambda, 0.17, tolerance = 1e-15)
  expect_equal(length(converted$z), length(y) - 1L)
  expect_equal(recovered, y, tolerance = 1e-15)
  expect_error(
    env$mfrmr_gc4_p1g_to_p1f(converted$z, 0, context, 4L),
    "lambda > 0"
  )
  expect_error(
    env$mfrmr_gc4_p1g_from_p1f(y, context, 3L),
    "single-target C4"
  )
})

test_that("P1g likelihood equals P1f at finite lambda", {
  env <- gpcm_c4_p1g_environment()
  context <- gpcm_c4_p1g_synthetic_context()
  p1f_layout <- env$mfrmr_gsrc_p1f_layout(context, 4L)
  y <- seq(-0.2, 0.25, length.out = p1f_layout$dimension)
  y[p1f_layout$log_lambda] <- log(0.13)
  converted <- env$mfrmr_gc4_p1g_from_p1f(y, context, 4L)
  p1f <- env$mfrmr_gsrc_p1f_limit_bundle(
    y, context, 4L, include_gradient = FALSE
  )
  p1g <- env$mfrmr_gc4_p1g_limit_bundle(
    converted$z, converted$lambda, context, 4L,
    include_gradient = FALSE
  )

  expect_equal(p1g$objective, p1f$objective, tolerance = 1e-12)
})

test_that("P1g scaled and lambda derivatives are independently correct", {
  env <- gpcm_c4_p1g_environment()
  context <- gpcm_c4_p1g_synthetic_context()
  layout <- env$mfrmr_gc4_p1g_layout(context)
  z <- seq(-0.25, 0.3, length.out = layout$dimension)
  lambda <- 0.2
  bundle <- env$mfrmr_gc4_p1g_limit_bundle(
    z, lambda, context, 4L, include_gradient = TRUE
  )
  numeric_gradient <- env$mfrmr_num_central_gradient(
    function(value) env$mfrmr_gc4_p1g_limit_bundle(
      value, lambda, context, 4L, include_gradient = FALSE
    )$objective,
    z,
    env$mfrmr_gc4_p1g_derivative_step
  )
  h <- env$mfrmr_gc4_p1g_derivative_step
  numeric_lambda <- (
    env$mfrmr_gc4_p1g_limit_bundle(
      z, lambda + h, context, 4L, include_gradient = FALSE
    )$objective -
      env$mfrmr_gc4_p1g_limit_bundle(
        z, lambda - h, context, 4L, include_gradient = FALSE
      )$objective
  ) / (2 * h)

  expect_true(is.finite(bundle$objective))
  expect_equal(length(bundle$gradient), layout$dimension)
  expect_lt(max(abs(bundle$gradient - numeric_gradient)), 1e-6)
  expect_equal(bundle$lambda_gradient, numeric_lambda, tolerance = 1e-6)
  expect_equal(
    unname(rowSums(bundle$posterior)), rep(1, 3), tolerance = 1e-15
  )
})

test_that("P1g lambda-zero likelihood is the direct conditional oracle", {
  env <- gpcm_c4_p1g_environment()
  context <- gpcm_c4_p1g_synthetic_context()
  layout <- env$mfrmr_gc4_p1g_layout(context)
  z <- seq(-0.1, 0.2, length.out = layout$dimension)
  direct <- env$mfrmr_gc4_p1g_limit_bundle(
    z, 0, context, 4L, include_gradient = TRUE
  )
  oracle <- env$mfrmr_gc4_p1g_conditional_oracle(z, context, 4L)

  expect_equal(direct$objective, oracle$objective, tolerance = 1e-12)
  expect_lt(abs(direct$lambda_gradient), 1e-12)
  expect_lt(
    max(abs(apply(direct$log_probability, 1L, diff))), 1e-15
  )
})

test_that("P1g decision closes only the declared grid and endpoint", {
  env <- gpcm_c4_p1g_environment()
  rows <- expand.grid(
    ScenarioId = "A",
    RouteId = env$mfrmr_gc4_p1g_routes,
    Lambda = env$mfrmr_gc4_p1g_lambda_grid,
    stringsAsFactors = FALSE
  )
  rows$ObjectiveQ121 <- 10 + rows$Lambda^2
  rows$ProfileMinusInteriorObjective <- 2 + rows$Lambda^2
  rows$LambdaObjectiveDerivative <- 2 * rows$Lambda
  rows$ProfileCandidateEligible <- TRUE
  pairwise <- unique(rows[c("ScenarioId", "Lambda")])
  pairwise$BothRoutesEligible <- TRUE
  pairwise$RouteAgreementWithinCalibrationTolerance <- TRUE
  decision <- env$mfrmr_gc4_p1g_decision("A", rows, pairwise)
  signature <- env$mfrmr_gc4_p1g_signature(decision)

  expect_true(decision$AllScaledProfilePointsEligible)
  expect_true(decision$BothRoutesMonotoneFromLambdaZero)
  expect_true(decision$AllPositiveLambdaGridDerivativesNonnegative)
  expect_true(decision$BothEndpointLambdaDerivativesNumericallyZero)
  expect_true(decision$BothDeterministicRaterEndpointsEligible)
  expect_true(decision$BothEndpointObjectivesAboveInterior)
  expect_true(decision$DeclaredC4FaceGridLocallyAdjudicated)
  expect_true(decision$C4DeterministicRaterLimitAdjudicated)
  expect_false(decision$FullC4FaceGloballyCertified)
  expect_false(decision$OtherRandomTargetFacesEvaluated)
  expect_false(decision$EmptyRandomProductHierarchyComplete)
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
  expect_identical(
    signature$State[signature$Metric == "c4_deterministic_rater_limit"],
    "stationary_direct_conditional_limit"
  )
  expect_identical(
    signature$State[signature$Metric == "full_c4_face"],
    "not_globally_certified"
  )
})

test_that("P1g dependency-complete profile remains explicitly opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the P1g C4-face audit"
  )
  env <- gpcm_c4_p1g_environment()
  result <- env$mfrmr_run_gpcm_c4_face_to_deterministic_rater_p1g(
    progress = FALSE
  )

  expect_s3_class(
    result, "mfrmr_gpcm_c4_face_to_deterministic_rater_p1g"
  )
  expect_equal(nrow(result$profile), 56L)
  expect_equal(nrow(result$pairwise), 28L)
  expect_true(all(result$profile$ProfileCandidateEligible))
  expect_true(all(result$pairwise$RouteAgreementWithinCalibrationTolerance))
  expect_true(all(result$decisions$BothRoutesMonotoneFromLambdaZero))
  expect_true(all(
    result$decisions$AllPositiveLambdaGridDerivativesNonnegative
  ))
  expect_true(all(result$decisions$BothEndpointObjectivesAboveInterior))
  expect_true(result$DeclaredC4FaceGridLocallyAdjudicated)
  expect_true(result$C4DeterministicRaterLimitAdjudicated)
  expect_false(result$FullC4FaceGloballyCertified)
  expect_false(result$OtherRandomTargetFacesEvaluated)
  expect_false(result$EmptyRandomProductHierarchyComplete)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1g record preserves the local grid and global blockers", {
  paths <- gpcm_c4_p1g_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(text, "B_r = lambda q_r", fixed = TRUE)
  expect_match(text, "56/56", fixed = TRUE)
  expect_match(text, "deterministic-Rater", fixed = TRUE)
  expect_match(text, "not a global C4-face certificate", fixed = TRUE)
  expect_match(text, "OtherRandomTargetFacesEvaluated = FALSE", fixed = TRUE)
  expect_match(text, "EmptyRandomProductHierarchyComplete = FALSE", fixed = TRUE)
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
