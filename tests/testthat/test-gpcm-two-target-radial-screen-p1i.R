gpcm_tr_p1i_paths <- function() {
  files <- c(
    numerical = "numerical-stationarity-pilot-0.2.3.R",
    p0 = "gpcm-solution-stability-p0-0.2.3.R",
    p0b = "gpcm-endpoint-solution-stability-p0b-0.2.3.R",
    p1a = "gpcm-population-variance-profile-p1a-0.2.3.R",
    p1b = "gpcm-low-basin-quadrature-p1b-0.2.3.R",
    p1c = "gpcm-zero-variance-boundary-p1c-0.2.3.R",
    p1d = "gpcm-zero-variance-log-slope-path-p1d-0.2.3.R",
    p1e = "gpcm-coordinate-scaled-joint-limit-p1e-0.2.3.R",
    p1f = "gpcm-slope-rate-cone-p1f-0.2.3.R",
    p1g = "gpcm-c4-face-to-deterministic-rater-p1g-0.2.3.R",
    p1h = "gpcm-single-target-face-screen-p1h-0.2.3.R",
    p1i = "gpcm-two-target-radial-screen-p1i-0.2.3.R"
  )
  paths <- vapply(files, function(file) testthat::test_path(
    "..", "..", "inst", "validation", file
  ), character(1L))
  c(
    paths,
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-two-target-radial-screen-p1i-record-0.2.3.md"
    )
  )
}

gpcm_tr_p1i_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_tr_p1i_paths()
    testthat::skip_if_not(
      all(file.exists(paths)),
      "internal validation artifacts are excluded"
    )
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    for (path in paths[!names(paths) %in% "record"]) {
      sys.source(path, envir = value)
    }
    value
  }
})

gpcm_tr_p1i_synthetic_context <- function() {
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

test_that("P1i freezes the P1h dependency and six-pair radial plan", {
  env <- gpcm_tr_p1i_environment()
  paths <- gpcm_tr_p1i_paths()
  plan <- env$mfrmr_gtr_p1i_plan()

  expect_identical(
    env$mfrmr_gtr_p1i_contract,
    "mfrmr_gpcm_two_target_radial_screen_p1i_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1h"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gtr_p1i_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1i"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "2208b7d8eb5da024de8ece28acba6f3b188e2d0e8d2bea0deccf0c031f275c1e"
  )
  expect_equal(nrow(plan$profile), 336L)
  expect_equal(plan$pair_count, 6L)
  expect_identical(
    unique(plan$profile$TargetSetId),
    c("C1+C2", "C1+C3", "C1+C4", "C2+C3", "C2+C4", "C3+C4")
  )
  expect_identical(unique(plan$profile$RouteId), env$mfrmr_gtr_p1i_routes)
  expect_equal(sum(plan$profile$IndependentDerivativeScheduled), 96L)
  expect_true(all(!plan$profile$SelectionAuthorized))
  expect_true(all(!plan$profile$ConfirmationAuthorized))
  expect_false(plan$AllTwoTargetGridsScreened)
  expect_false(plan$ThreeTargetFacesEvaluated)
})

test_that("P1i radial and relative coordinates exactly round trip", {
  env <- gpcm_tr_p1i_environment()
  context <- gpcm_tr_p1i_synthetic_context()
  for (targets in env$mfrmr_gtr_p1i_target_sets) {
    layout <- env$mfrmr_gsrc_p1f_layout(context, targets)
    y <- seq(-0.35, 0.45, length.out = layout$dimension)
    y[layout$log_lambda] <- log(c(0.12, 0.18))
    converted <- env$mfrmr_gtr_p1i_from_p1f(y, context, targets)
    recovered <- env$mfrmr_gtr_p1i_to_p1f(
      converted$w, converted$tau, context, targets
    )
    expect_equal(recovered, y, tolerance = 1e-15)
    expect_equal(prod(converted$kappa), 1, tolerance = 1e-15)
    expect_equal(
      converted$tau, sqrt(prod(converted$lambda)), tolerance = 1e-15
    )
  }
})

test_that("P1i equals P1f and has an independent analytic gradient", {
  env <- gpcm_tr_p1i_environment()
  context <- gpcm_tr_p1i_synthetic_context()
  for (targets in env$mfrmr_gtr_p1i_target_sets) {
    layout <- env$mfrmr_gsrc_p1f_layout(context, targets)
    y <- seq(-0.2, 0.25, length.out = layout$dimension)
    y[layout$log_lambda] <- log(c(0.11, 0.17))
    converted <- env$mfrmr_gtr_p1i_from_p1f(y, context, targets)
    p1f <- env$mfrmr_gsrc_p1f_limit_bundle(
      y, context, targets, include_gradient = FALSE
    )
    p1i <- env$mfrmr_gtr_p1i_bundle(
      converted$w, converted$tau, context, targets,
      include_gradient = TRUE
    )
    numeric_gradient <- env$mfrmr_num_central_gradient(
      function(value) env$mfrmr_gtr_p1i_bundle(
        value, converted$tau, context, targets,
        include_gradient = FALSE
      )$objective,
      converted$w,
      env$mfrmr_gtr_p1i_derivative_step
    )
    expect_equal(p1i$objective, p1f$objective, tolerance = 1e-12)
    expect_lt(max(abs(p1i$gradient - numeric_gradient)), 1e-6)
  }
})

test_that("P1i natural radial derivative is independently correct", {
  env <- gpcm_tr_p1i_environment()
  context <- gpcm_tr_p1i_synthetic_context()
  layout <- env$mfrmr_gtr_p1i_layout(context)
  w <- seq(-0.15, 0.25, length.out = layout$dimension)
  tau <- 0.18
  h <- env$mfrmr_gtr_p1i_derivative_step
  for (targets in env$mfrmr_gtr_p1i_target_sets) {
    bundle <- env$mfrmr_gtr_p1i_bundle(
      w, tau, context, targets, include_gradient = TRUE
    )
    numeric_tau <- (
      env$mfrmr_gtr_p1i_bundle(
        w, tau + h, context, targets, include_gradient = FALSE
      )$objective -
        env$mfrmr_gtr_p1i_bundle(
          w, tau - h, context, targets, include_gradient = FALSE
        )$objective
    ) / (2 * h)
    expect_equal(bundle$tau_gradient, numeric_tau, tolerance = 1e-6)
  }
})

test_that("P1i paired endpoints equal direct conditional oracles", {
  env <- gpcm_tr_p1i_environment()
  context <- gpcm_tr_p1i_synthetic_context()
  layout <- env$mfrmr_gtr_p1i_layout(context)
  w <- seq(-0.1, 0.2, length.out = layout$dimension)
  for (targets in env$mfrmr_gtr_p1i_target_sets) {
    direct <- env$mfrmr_gtr_p1i_bundle(
      w, 0, context, targets, include_gradient = TRUE
    )
    oracle <- env$mfrmr_gtr_p1i_conditional_oracle(w, context, targets)
    expect_equal(direct$objective, oracle$objective, tolerance = 1e-12)
    expect_lt(abs(direct$tau_gradient), 1e-12)
    expect_lt(
      max(abs(apply(direct$log_probability, 1L, diff))), 1e-15
    )
  }
})

test_that("P1i local decisions keep ratio and later faces fail closed", {
  env <- gpcm_tr_p1i_environment()
  rows <- expand.grid(
    ScenarioId = "A",
    TargetSetId = "C1+C2",
    RouteId = env$mfrmr_gtr_p1i_routes,
    Tau = env$mfrmr_gtr_p1i_tau_grid,
    stringsAsFactors = FALSE
  )
  rows$ObjectiveQ121 <- 10 + rows$Tau^2
  rows$ProfileMinusInteriorObjective <- 2 + rows$Tau^2
  rows$RelativeLogKappa <- 0.2
  rows$TauObjectiveDerivative <- 2 * rows$Tau
  rows$ProfileCandidateEligible <- TRUE
  pairwise <- unique(rows[c("ScenarioId", "TargetSetId", "Tau")])
  pairwise$BothRoutesEligible <- TRUE
  pairwise$RouteAgreementWithinCalibrationTolerance <- TRUE
  decision <- env$mfrmr_gtr_p1i_decision(
    "A", "C1+C2", rows, pairwise
  )

  expect_true(decision$TwoTargetRadialGridLocallyAdjudicated)
  expect_true(decision$PairedDeterministicRaterLimitAdjudicated)
  expect_true(decision$BothEndpointObjectivesAboveInterior)
  expect_false(decision$CoefficientRatioBoundaryCertified)
  expect_false(decision$FullTwoTargetFaceGloballyCertified)
  expect_false(decision$ThreeTargetFacesEvaluated)
  expect_false(decision$EmptyRandomProductHierarchyComplete)
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)

  portfolio <- expand.grid(
    ScenarioId = paste0("S", 1:4),
    TargetSetId = vapply(
      env$mfrmr_gtr_p1i_target_sets,
      env$mfrmr_gtr_p1i_target_id,
      character(1L)
    ),
    stringsAsFactors = FALSE
  )
  portfolio$TwoTargetRadialGridLocallyAdjudicated <- TRUE
  portfolio$PairedDeterministicRaterLimitAdjudicated <- TRUE
  portfolio$EndpointMinusInteriorMinimum <- 2
  portfolio$EndpointMinusInteriorMaximum <- 2
  overall <- env$mfrmr_gtr_p1i_overall_decision(portfolio)
  expect_true(overall$AllSixTwoTargetRadialGridsScreened)
  expect_true(overall$AllSixPairedDeterministicRaterStrataScreened)
  expect_false(overall$AnyPairedEndpointBelowQualifiedInterior)
  expect_false(overall$CoefficientRatioBoundariesCertified)
  expect_false(overall$ThreeTargetFacesEvaluated)
  expect_false(overall$GlobalJointBoundaryProfileCertified)
  expect_false(overall$SelectionAuthorized)
  expect_false(overall$ConfirmationAuthorized)
})

test_that("P1i dependency-complete screen preserves ratio-boundary evidence", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the P1i two-target audit"
  )
  env <- gpcm_tr_p1i_environment()
  result <- env$mfrmr_run_gpcm_two_target_radial_screen_p1i(
    progress = FALSE
  )

  expect_s3_class(result, "mfrmr_gpcm_two_target_radial_screen_p1i")
  expect_equal(nrow(result$profile), 336L)
  expect_equal(nrow(result$pairwise), 168L)
  expect_equal(nrow(result$decisions), 24L)
  expect_equal(sum(result$profile$ProfileCandidateEligible), 318L)
  expect_equal(
    sum(result$decisions$TwoTargetRadialGridLocallyAdjudicated), 10L
  )
  expect_true(all(
    result$decisions$BothEndpointObjectivesAboveInterior[
      result$decisions$TwoTargetRadialGridLocallyAdjudicated
    ]
  ))
  expect_gt(max(result$pairwise$ObjectiveAbsDifference), 0.05)
  expect_gt(max(abs(
    result$profile$RelativeLogKappa[result$profile$Tau == 0]
  )), 5)
  expect_false(result$AllSixTwoTargetRadialGridsScreened)
  expect_false(result$AllSixPairedDeterministicRaterStrataScreened)
  expect_false(result$CoefficientRatioBoundariesCertified)
  expect_false(result$ThreeTargetFacesEvaluated)
  expect_false(result$EmptyRandomProductHierarchyComplete)
  expect_false(result$GlobalJointBoundaryProfileCertified)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1i record preserves the incomplete radial closure", {
  paths <- gpcm_tr_p1i_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(text, "318/336", fixed = TRUE)
  expect_match(text, "10/24", fixed = TRUE)
  expect_match(
    text, "AllSixTwoTargetRadialGridsScreened = FALSE", fixed = TRUE
  )
  expect_match(
    text, "CoefficientRatioBoundariesCertified = FALSE", fixed = TRUE
  )
  expect_match(text, "ThreeTargetFacesEvaluated = FALSE", fixed = TRUE)
  expect_match(
    text, "EmptyRandomProductHierarchyComplete = FALSE", fixed = TRUE
  )
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
