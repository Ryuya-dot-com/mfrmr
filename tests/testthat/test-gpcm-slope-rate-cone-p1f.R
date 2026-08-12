gpcm_src_p1f_paths <- function() {
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
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-slope-rate-cone-p1f-record-0.2.3.md"
    )
  )
}

gpcm_src_p1f_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_src_p1f_paths()
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

gpcm_src_p1f_synthetic_context <- function() {
  list(
    config = list(
      facet_levels = list(
        Rater = c("R1", "R2"),
        Criterion = c("C1", "C2")
      ),
      n_cat = 3L,
      n_person = 2L
    ),
    sizes = list(steps = 2L),
    idx = list(
      score_k = c(0L, 1L, 2L, 1L, 2L, 1L, 0L, 1L),
      person = rep(1:2, each = 4L),
      slope_idx = rep(c(1L, 2L), 4L),
      facets = list(
        Rater = rep(c(1L, 2L, 2L, 1L), 2L),
        Criterion = rep(c(1L, 2L), 4L)
      ),
      weight = rep(1, 8L)
    ),
    quad = list(
      nodes = c(-1, 0, 1),
      weights = c(0.25, 0.5, 0.25)
    )
  )
}

test_that("P1f freezes the P1e dependency and analytic scope", {
  env <- gpcm_src_p1f_environment()
  paths <- gpcm_src_p1f_paths()

  expect_identical(
    env$mfrmr_gsrc_p1f_contract,
    "mfrmr_gpcm_slope_rate_cone_p1f_v1"
  )
  expect_identical(
    env$mfrmr_gsrc_p1f_dependency_contract,
    "mfrmr_gpcm_coordinate_scaled_joint_limit_p1e_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1e"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gsrc_p1f_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1f"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "01e6b04af33565a4dc350fdd24285e619a5cc2cbaec35f8ce5d2ab49d99d59d9"
  )
})

test_that("P1f rate coordinates are affinely equivalent to a simplex", {
  env <- gpcm_src_p1f_environment()
  rates <- c(1, 0.25, -0.5, -0.75)
  weights <- env$mfrmr_gsrc_p1f_rates_to_weights(rates)
  recovered <- env$mfrmr_gsrc_p1f_weights_to_rates(weights)
  classification <- env$mfrmr_gsrc_p1f_classify_rates(rates)

  expect_equal(sum(rates), 0, tolerance = 1e-15)
  expect_true(all(weights >= 0))
  expect_equal(sum(weights), 1, tolerance = 1e-15)
  expect_equal(recovered, rates, tolerance = 1e-15)
  expect_true(classification$admissible)
  expect_identical(classification$target_indices, 1L)
  expect_identical(
    classification$status,
    "admissible_nonempty_random_target_face"
  )

  outside <- env$mfrmr_gsrc_p1f_classify_rates(c(1.1, -0.1, 0, -1))
  expect_false(outside$admissible)
  expect_identical(
    outside$status,
    "outside_finite_random_coefficient_rate_simplex"
  )
  empty <- env$mfrmr_gsrc_p1f_classify_rates(c(0.3, 0.2, -0.1, -0.4))
  expect_true(empty$admissible)
  expect_length(empty$target_indices, 0L)
  expect_identical(
    empty$status,
    "admissible_no_random_product_retained"
  )
})

test_that("P1f enumerates every nonempty proper four-criterion target set", {
  env <- gpcm_src_p1f_environment()
  contract <- env$mfrmr_gsrc_p1f_polytope_contract(
    paste0("C", 1:4)
  )
  sets <- contract$target_sets

  expect_equal(nrow(sets), 14L)
  expect_equal(
    as.integer(table(factor(sets$TargetCount, levels = 1:3))),
    c(4L, 6L, 4L)
  )
  expect_equal(nrow(contract$vertices), 4L)
  expect_true(all(sets$FaceDimension == 3L - sets$TargetCount))
  expect_true(all(sets$IsRateSimplexVertex == (sets$TargetCount == 3L)))
  expect_true(all(!sets$TargetSetOptimized))
  expect_false(contract$GlobalJointBoundaryProfileCertified)

  c4 <- sets[sets$TargetSetId == "C4", , drop = FALSE]
  expect_equal(
    unlist(c4$barycenter_rates),
    c(-1 / 3, -1 / 3, -1 / 3, 1),
    tolerance = 1e-15
  )
  expect_equal(
    unlist(c4$simplex_weights),
    c(1 / 3, 1 / 3, 1 / 3, 0),
    tolerance = 1e-15
  )
})

test_that("P1f canonical reduced likelihood has the declared free dimension", {
  env <- gpcm_src_p1f_environment()
  context <- gpcm_src_p1f_synthetic_context()
  layout_one <- env$mfrmr_gsrc_p1f_layout(context, 1L)

  expect_equal(layout_one$dimension, 6L)
  expect_equal(length(layout_one$rater), 1L)
  expect_equal(length(layout_one$location), 2L)
  expect_equal(length(layout_one$steps), 2L)
  expect_equal(length(layout_one$log_lambda), 1L)
  expect_error(
    env$mfrmr_gsrc_p1f_layout(context, integer(0)),
    "nonempty proper target set"
  )
  expect_error(
    env$mfrmr_gsrc_p1f_layout(context, 1:2),
    "nonempty proper target set"
  )
})

test_that("P1f canonical reduced likelihood analytic gradient is independent", {
  env <- gpcm_src_p1f_environment()
  context <- gpcm_src_p1f_synthetic_context()
  target <- 1L
  y <- c(0.15, -0.2, 0.25, 0.1, -0.15, log(0.8))
  bundle <- env$mfrmr_gsrc_p1f_limit_bundle(
    y, context, target, include_gradient = TRUE
  )
  numeric_gradient <- env$mfrmr_num_central_gradient(
    function(value) env$mfrmr_gsrc_p1f_limit_bundle(
      value, context, target, include_gradient = FALSE
    )$objective,
    y,
    env$mfrmr_gsrc_p1f_derivative_step
  )

  expect_true(is.finite(bundle$objective))
  expect_equal(length(bundle$gradient), length(y))
  expect_true(all(is.finite(bundle$gradient)))
  expect_lt(max(abs(bundle$gradient - numeric_gradient)), 1e-6)
  expect_equal(
    unname(rowSums(bundle$posterior)), rep(1, 2), tolerance = 1e-15
  )
  expect_equal(bundle$lambda, 0.8, tolerance = 1e-15)
})

test_that("P1f decision remains fail closed after analytic classification", {
  env <- gpcm_src_p1f_environment()
  sets <- env$mfrmr_gsrc_p1f_target_sets(paste0("C", 1:4))
  nested <- data.frame(
    P1eNestedIdentityComplete = rep(TRUE, 8L),
    NestedObjectiveMaxAbsDifference = rep(0, 8L),
    P1fAnalyticNumericGradientMaxAbsDifference = rep(1e-8, 8L),
    FreeLogLambdaDerivativeResolvedNonzero = rep(TRUE, 8L),
    DirectionalProbeObjectiveDifference = rep(-1e-3, 8L),
    stringsAsFactors = FALSE
  )
  decision <- env$mfrmr_gsrc_p1f_decision(sets, nested)
  signature <- env$mfrmr_gsrc_p1f_signature(decision)

  expect_true(decision$RateSimplexClassificationComplete)
  expect_true(decision$CanonicalReducedLikelihoodDerived)
  expect_true(decision$P1eSingleTargetNestedIdentityComplete)
  expect_true(decision$P1eFixedCoefficientDerivativeResolvedNonzero)
  expect_false(decision$P1eFaceCoefficientOptimized)
  expect_false(decision$AllTargetSetsOptimized)
  expect_false(decision$NoRandomProductStratumClassified)
  expect_false(decision$GlobalJointBoundaryProfileCertified)
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
  expect_identical(
    signature$State[signature$Metric == "finite_random_rate_cone"],
    "classified_as_standard_simplex"
  )
  expect_match(
    signature$State[signature$Metric == "p1e_embedding"],
    "nonstationary"
  )
})

test_that("P1f execution reproduces P1e and exposes the free coefficient", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the dependency-complete audit"
  )
  env <- gpcm_src_p1f_environment()
  result <- env$mfrmr_run_gpcm_slope_rate_cone_p1f(progress = FALSE)

  expect_s3_class(result, "mfrmr_gpcm_slope_rate_cone_p1f")
  expect_true(result$decision$RateSimplexClassificationComplete)
  expect_equal(nrow(result$polytope$target_sets), 14L)
  expect_equal(nrow(result$nested_p1e_evaluations), 8L)
  expect_true(all(
    result$nested_p1e_evaluations$NestedObjectiveMaxAbsDifference < 2e-10
  ))
  expect_true(all(
    result$nested_p1e_evaluations$
      P1fAnalyticNumericGradientMaxAbsDifference < 5e-6
  ))
  expect_true(all(
    result$nested_p1e_evaluations$
      FreeLogLambdaDerivativeResolvedNonzero
  ))
  expect_true(all(
    result$nested_p1e_evaluations$DirectionalProbeObjectiveDifference < 0
  ))
  expect_false(result$AllTargetSetsOptimized)
  expect_false(result$NoRandomProductStratumClassified)
  expect_false(result$GlobalJointBoundaryProfileCertified)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1f record preserves the corrected scope and blockers", {
  paths <- gpcm_src_p1f_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(text, "standard simplex", fixed = TRUE)
  expect_match(text, "14", fixed = TRUE)
  expect_match(text, "fixed", ignore.case = TRUE)
  expect_match(text, "lambda", ignore.case = TRUE)
  expect_match(text, "not a global joint-boundary certificate", fixed = TRUE)
  expect_match(text, "no-random-product", fixed = TRUE)
  expect_match(text, "AllTargetSetsOptimized = FALSE", fixed = TRUE)
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
