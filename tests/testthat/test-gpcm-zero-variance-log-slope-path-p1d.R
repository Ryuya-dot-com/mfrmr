gpcm_js_p1d_paths <- function() {
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
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-zero-variance-log-slope-path-p1d-record-0.2.3.md"
    )
  )
}

gpcm_js_p1d_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_js_p1d_paths()
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

gpcm_js_p1d_fake_points <- function(
    scenario_id = "A",
    route_id = "interior_forward",
    objectives = c(10, 9, 8, 7, 6, 5),
    derivative = -1,
    eligible = TRUE) {
  data.frame(
    ScenarioId = scenario_id,
    RouteId = route_id,
    T = c(0, 2, 4, 6, 8, 10),
    PathPointEligible = rep(eligible, 6L),
    FitReturned = TRUE,
    ObjectiveQ121 = objectives,
    AnalyticProfilePathDerivative = rep(derivative, 6L),
    QuadratureObjectiveRange = seq_len(6L) * 1e-8,
    NuisanceGradientMaxAbs = seq_len(6L) * 1e-6,
    TargetEffectiveLogScale = rep(0.5, 6L),
    MaximumPrescribedSlope = exp(c(0, 2, 4, 6, 8, 10)),
    PrescribedSlopeRatio = exp(4 * c(0, 2, 4, 6, 8, 10) / 3),
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

test_that("P1d pins a bounded non-uniform joint-path contract", {
  env <- gpcm_js_p1d_environment()
  paths <- gpcm_js_p1d_paths()
  plan <- env$mfrmr_gjs_p1d_plan()
  contract <- env$mfrmr_gjs_p1d_limit_contract()

  expect_identical(
    env$mfrmr_gjs_p1d_contract,
    "mfrmr_gpcm_zero_variance_log_slope_path_p1d_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1c"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gjs_p1d_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1d"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "5480c1e9c1ff04e208df9e375dd54b99395b25df28b11b5ba96625259338af51"
  )
  expect_identical(nrow(plan$path), 48L)
  expect_identical(unique(plan$path$T), c(0, 2, 4, 6, 8, 10))
  expect_identical(
    unique(plan$path$RouteId),
    c("interior_forward", "boundary_reverse")
  )
  expect_true(all(plan$path$OptimizationQuadrature == 121L))
  expect_equal(contract$ExpandedLogSlopeRateSum, 0, tolerance = 1e-15)
  expect_equal(contract$TargetLogEffectiveSdRate, 0)
  expect_lt(contract$OtherLogEffectiveSdRate, 0)
  expect_true(contract$SumZeroIdentificationPreserved)
  expect_true(contract$TargetSlopeTimesSdInvariant)
  expect_false(contract$FixedFiniteNuisanceAssumptionPreserved)
  expect_false(contract$FixedNuisanceQ1LimitTransportAuthorized)
  expect_true(contract$StandardNormalQuadratureRetained)
  expect_false(contract$GlobalJointBoundaryProfileCertified)
  expect_false(contract$SelectionAuthorized)
  expect_false(contract$ConfirmationAuthorized)
})

test_that("P1d directions preserve geometric-mean-one identification", {
  env <- gpcm_js_p1d_environment()
  for (target in seq_len(4L)) {
    direction <- env$mfrmr_gjs_p1d_direction(4L, target)
    expect_equal(sum(direction), 0, tolerance = 1e-15)
    expect_equal(direction[target], 1)
    expect_true(all(direction[-target] == -1 / 3))
    expect_equal(prod(exp(direction)), 1, tolerance = 1e-15)
  }
  expect_error(
    env$mfrmr_gjs_p1d_direction(1L, 1L),
    "at least two slope levels"
  )
  expect_error(
    env$mfrmr_gjs_p1d_direction(4L, 5L),
    "valid target"
  )
})

test_that("P1d route summary separates recession, turnback, and failure", {
  env <- gpcm_js_p1d_environment()
  recession <- env$mfrmr_gjs_p1d_route_summary(
    gpcm_js_p1d_fake_points()
  )
  expect_true(recession$AllPointsEligible)
  expect_true(recession$StrictlyDecreasingObserved)
  expect_identical(
    recession$RouteStatus,
    "recession_signal_observed_not_certified"
  )

  turnback <- env$mfrmr_gjs_p1d_route_summary(
    gpcm_js_p1d_fake_points(
      objectives = c(10, 9, 8, 8.5, 9, 10), derivative = 1
    )
  )
  expect_true(turnback$AllPointsEligible)
  expect_identical(
    turnback$RouteStatus,
    "finite_turnback_signal_observed_not_certified"
  )

  blocked <- env$mfrmr_gjs_p1d_route_summary(
    gpcm_js_p1d_fake_points(eligible = FALSE)
  )
  expect_false(blocked$AllPointsEligible)
  expect_identical(blocked$RouteStatus, "joint_path_inconclusive")
  expect_false(blocked$SelectionAuthorized)
  expect_false(blocked$ConfirmationAuthorized)
})

test_that("P1d route pairing fails closed when one route is missing", {
  env <- gpcm_js_p1d_environment()
  only_forward <- gpcm_js_p1d_fake_points()
  out <- env$mfrmr_gjs_p1d_route_pairwise(only_forward)

  expect_identical(nrow(out), 6L)
  expect_true(all(!out$BothRoutesPresent))
  expect_true(all(!out$BothRoutesEligible))
  expect_true(all(is.na(out$ObjectiveAbsDifference)))
  expect_true(all(is.na(out$PathDerivativeAbsDifference)))
  expect_true(all(!out$SelectionAuthorized))
  expect_true(all(!out$ConfirmationAuthorized))
})

test_that("P1d decision remains local and blocks downstream inference", {
  env <- gpcm_js_p1d_environment()
  points <- rbind(
    gpcm_js_p1d_fake_points(route_id = "interior_forward"),
    gpcm_js_p1d_fake_points(route_id = "boundary_reverse")
  )
  summary <- env$mfrmr_gjs_p1d_route_summary(points)
  decision <- env$mfrmr_gjs_p1d_decision("A", summary)

  expect_true(decision$BothRoutesCompleteAndEligible)
  expect_identical(
    decision$JointZeroVarianceLogSlopePathStatus,
    "bounded_recession_signal_observed_not_certified"
  )
  expect_false(decision$FixedNuisanceQ1TransportAuthorized)
  expect_false(decision$GlobalJointBoundaryProfileCertified)
  expect_identical(decision$UpperVarianceJointPathStatus, "not_evaluated")
  expect_identical(decision$SolutionToleranceStatus, "not_frozen")
  expect_identical(
    decision$SourceSolutionDecision,
    "blocked_global_joint_boundary_upper_boundary_and_selection_rule_unresolved"
  )
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1d signatures expose a non-uniform-limit mutation", {
  env <- gpcm_js_p1d_environment()
  points <- rbind(
    gpcm_js_p1d_fake_points(route_id = "interior_forward"),
    gpcm_js_p1d_fake_points(route_id = "boundary_reverse")
  )
  decision <- env$mfrmr_gjs_p1d_decision(
    "A", env$mfrmr_gjs_p1d_route_summary(points)
  )
  signature <- env$mfrmr_gjs_p1d_signature(decision)

  expect_identical(
    signature$State[
      signature$Metric == "fixed_nuisance_q1_transport"
    ],
    "prohibited_nonuniform_limit"
  )
  expect_identical(
    signature$State[
      signature$Metric == "global_joint_boundary_profile"
    ],
    "not_certified"
  )
  changed <- signature
  changed$State[
    changed$Metric == "fixed_nuisance_q1_transport"
  ] <- "incorrectly_transported"
  comparison <- env$mfrmr_gss_compare_signatures(signature, changed)
  expect_false(comparison$DecisionInvariant)
  expect_identical(
    comparison$ChangedMetrics,
    "fixed_nuisance_q1_transport"
  )
  expect_true(all(nzchar(signature$Reason)))
})

test_that("P1d full four-scenario joint-path audit remains explicitly opt-in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the P1d joint-path audit"
  )
  testthat::skip_on_cran()
  env <- gpcm_js_p1d_environment()
  result <- env$mfrmr_run_gpcm_zero_variance_log_slope_path_p1d()

  expect_identical(nrow(result$geometry), 4L)
  expect_identical(nrow(result$path_points), 48L)
  expect_identical(nrow(result$path_derivative_audit), 144L)
  expect_identical(nrow(result$route_summary), 8L)
  expect_identical(nrow(result$route_pairwise), 24L)
  expect_identical(nrow(result$decisions), 4L)
  expect_identical(nrow(result$signature_comparisons), 2L)
  expect_true(result$limit_contract$SumZeroIdentificationPreserved)
  expect_true(result$limit_contract$TargetSlopeTimesSdInvariant)
  expect_true(all(!result$geometry$GeometrySourceBoundaryEligible))
  expect_true(all(
    result$geometry$TargetSlopeKey == "log_slope::Criterion::C4"
  ))
  expect_true(all(result$path_points$FixedCoordinatesExact))
  expect_identical(sum(result$path_points$PathPointEligible), 14L)
  expect_true(all(result$path_points$PathPointEligible[
    result$path_points$T == 0
  ]))
  expect_true(all(!result$path_points$PathPointEligible[
    result$path_points$T >= 4
  ]))
  expect_true(all(is.finite(result$path_points$QuadratureObjectiveRange)))
  expect_true(all(
    result$route_summary$TargetEffectiveLogScaleRange < 1e-12
  ))
  expect_true(all(
    result$route_summary$ObjectiveAtTMax > result$route_summary$ObjectiveAtT0
  ))
  expect_true(all(
    result$route_summary$RouteStatus == "joint_path_inconclusive"
  ))
  expect_true(all(
    result$decisions$JointZeroVarianceLogSlopePathStatus ==
      "bounded_joint_path_inconclusive"
  ))
  expect_true(all(result$signature_comparisons$DecisionInvariant))
  expect_true(all(!result$path_points$FixedNuisanceQ1TransportAuthorized))
  expect_true(all(!result$decisions$GlobalJointBoundaryProfileCertified))
  expect_identical(result$UpperVarianceJointPathStatus, "not_evaluated")
  expect_identical(result$SolutionToleranceStatus, "not_frozen")
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})
