gpcm_cl_p1e_paths <- function() {
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
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-coordinate-scaled-joint-limit-p1e-record-0.2.3.md"
    )
  )
}

gpcm_cl_p1e_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_cl_p1e_paths()
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

test_that("P1e freezes finite and direct-limit execution plans", {
  env <- gpcm_cl_p1e_environment()
  paths <- gpcm_cl_p1e_paths()
  plan <- env$mfrmr_gcl_p1e_plan()
  rates <- env$mfrmr_gcl_p1e_rate_contract()

  expect_identical(
    env$mfrmr_gcl_p1e_contract,
    "mfrmr_gpcm_coordinate_scaled_joint_limit_p1e_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1d"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gcl_p1e_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1e"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "38a931ab9f2de9e8c48579f4fd1bf356f013d2e14c9dc7c7993d9b2e0691915f"
  )
  expect_identical(nrow(plan$finite), 32L)
  expect_identical(nrow(plan$limit), 8L)
  expect_identical(unique(plan$finite$T), c(4, 6, 8, 10))
  expect_identical(
    unique(plan$finite$RouteId),
    c("interior_forward", "boundary_reverse")
  )
  expect_true(all(plan$finite$OptimizationQuadrature == 121L))
  expect_equal(
    rates$LogRatePerT[rates$Coordinate == "population_sd"], -1
  )
  expect_equal(
    rates$LogRatePerT[rates$Coordinate == "target_slope"], 1
  )
  expect_equal(
    rates$LogRatePerT[rates$Coordinate == "other_slope"], -1 / 3
  )
  expect_equal(
    rates$LogRatePerT[rates$Coordinate == "other_steps"], 1 / 3
  )
  expect_true(all(!rates$SelectionAuthorized))
  expect_true(all(!rates$ConfirmationAuthorized))
})

test_that("P1e stable softmax is normalized under extreme logits", {
  env <- gpcm_cl_p1e_environment()
  logits <- rbind(
    c(-1000, 0, 1000),
    c(1000, 1000, 1000),
    c(-1000, -999, -998)
  )
  out <- env$mfrmr_gcl_p1e_softmax(logits)

  expect_true(all(is.finite(out$probs)))
  expect_true(all(is.finite(out$log_denom)))
  expect_equal(rowSums(out$probs), rep(1, 3), tolerance = 1e-15)
  expect_equal(out$probs[2, ], rep(1 / 3, 3), tolerance = 1e-15)
  expect_gt(out$probs[1, 3], 1 - 1e-15)
})

test_that("P1e route comparison is typed when one route is absent", {
  env <- gpcm_cl_p1e_environment()
  rows <- data.frame(
    ScenarioId = "A",
    RouteId = "interior_forward",
    LimitObjectiveQ121 = 10,
    ReducedLimitCandidateEligible = TRUE,
    stringsAsFactors = FALSE
  )
  out <- env$mfrmr_gcl_p1e_pairwise(
    rows, "LimitObjectiveQ121", "ReducedLimitCandidateEligible"
  )

  expect_false(out$BothRoutesPresent)
  expect_false(out$BothRoutesEligible)
  expect_true(is.na(out$ObjectiveAbsDifference))
  expect_false(out$GlobalJointBoundaryProfileCertified)
  expect_false(out$SelectionAuthorized)
  expect_false(out$ConfirmationAuthorized)
})

test_that("P1e decision adjudicates only the declared local ray", {
  env <- gpcm_cl_p1e_environment()
  finite <- expand.grid(
    ScenarioId = "A",
    RouteId = c("interior_forward", "boundary_reverse"),
    T = c(4, 6, 8, 10),
    stringsAsFactors = FALSE
  )
  finite$CoordinateScaledCandidateEligible <- TRUE
  limit <- data.frame(
    ScenarioId = rep("A", 2L),
    RouteId = c("interior_forward", "boundary_reverse"),
    ReducedLimitCandidateEligible = TRUE,
    LimitMinusInteriorObjective = c(3, 3),
    stringsAsFactors = FALSE
  )
  pair <- data.frame(
    ScenarioId = "A",
    ObjectiveAbsDifference = 0,
    stringsAsFactors = FALSE
  )
  decision <- env$mfrmr_gcl_p1e_decision("A", finite, limit, pair)

  expect_true(decision$AllFiniteTransformedPointsEligible)
  expect_true(decision$BothReducedLimitRoutesEligible)
  expect_true(decision$BothReducedLimitObjectivesAboveInterior)
  expect_identical(
    decision$CoordinateScaledJointLimitStatus,
    "declared_c4_ray_two_route_stationary_limit_above_interior"
  )
  expect_true(decision$DeclaredC4RayLocallyAdjudicated)
  expect_false(decision$OtherSlopeRateRaysEvaluated)
  expect_false(decision$GlobalJointBoundaryProfileCertified)
  expect_identical(decision$UpperVarianceJointPathStatus, "not_evaluated")
  expect_identical(decision$SolutionToleranceStatus, "not_frozen")
  expect_identical(
    decision$SourceSolutionDecision,
    "blocked_other_joint_rays_upper_boundary_and_selection_rule_unresolved"
  )
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1e signature changes when other rays are incorrectly closed", {
  env <- gpcm_cl_p1e_environment()
  decision <- data.frame(
    AllFiniteTransformedPointsEligible = TRUE,
    BothReducedLimitRoutesEligible = TRUE,
    CoordinateScaledJointLimitStatus =
      "declared_c4_ray_two_route_stationary_limit_above_interior",
    stringsAsFactors = FALSE
  )
  signature <- env$mfrmr_gcl_p1e_signature(decision)

  expect_identical(
    signature$State[signature$Metric == "finite_coordinate_transform"],
    "stationary_exact_finite_transform"
  )
  expect_identical(
    signature$State[signature$Metric == "direct_reduced_limit"],
    "stationary_two_route_direct_limit"
  )
  expect_identical(
    signature$State[signature$Metric == "other_slope_rate_rays"],
    "not_evaluated"
  )
  changed <- signature
  changed$State[changed$Metric == "other_slope_rate_rays"] <- "closed"
  comparison <- env$mfrmr_gss_compare_signatures(signature, changed)
  expect_false(comparison$DecisionInvariant)
  expect_identical(comparison$ChangedMetrics, "other_slope_rate_rays")
  expect_true(all(nzchar(signature$Reason)))
})

test_that("P1e full coordinate-scaled audit remains explicitly opt-in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the P1e joint-limit audit"
  )
  testthat::skip_on_cran()
  env <- gpcm_cl_p1e_environment()
  result <- env$mfrmr_run_gpcm_coordinate_scaled_joint_limit_p1e()

  expect_identical(nrow(result$fixture_contracts), 4L)
  expect_identical(nrow(result$finite_candidates), 32L)
  expect_identical(nrow(result$reduced_limit_candidates), 8L)
  expect_identical(nrow(result$reduced_limit_pairwise), 4L)
  expect_identical(nrow(result$decisions), 4L)
  expect_identical(nrow(result$signature_comparisons), 2L)
  expect_true(all(result$fixture_contracts$ExactFixtureContract))
  expect_true(all(result$finite_candidates$FitReturned))
  expect_true(all(
    result$finite_candidates$CoordinateScaledCandidateEligible
  ))
  expect_identical(sum(result$finite_candidates$RawStationarityPass), 1L)
  expect_true(all(
    result$finite_candidates$RoundtripNuisanceMaxAbsDifference < 1e-15
  ))
  expect_true(all(is.finite(
    result$finite_candidates$FiniteQuadratureObjectiveRange
  )))
  finite_limit_gap <- split(
    abs(result$finite_candidates$FiniteMinusLimitObjectiveQ121),
    interaction(
      result$finite_candidates$ScenarioId,
      result$finite_candidates$RouteId,
      drop = TRUE
    )
  )
  expect_true(all(vapply(
    finite_limit_gap, function(value) all(diff(value) < 0), logical(1L)
  )))
  expect_true(all(is.finite(
    result$finite_candidates$
      AnalyticNumericTransformedGradientMaxAbsDifference
  )))
  expect_true(all(
    result$reduced_limit_candidates$ReducedLimitCandidateEligible
  ))
  expect_true(all(is.finite(
    result$reduced_limit_candidates$
      AnalyticNumericLimitGradientMaxAbsDifference
  )))
  expect_true(all(
    result$reduced_limit_candidates$LimitMinusInteriorObjective > 0
  ))
  expect_true(all(
    result$reduced_limit_pairwise$ObjectiveAbsDifference < 1e-10
  ))
  expect_true(all(
    result$decisions$CoordinateScaledJointLimitStatus ==
      "declared_c4_ray_two_route_stationary_limit_above_interior"
  ))
  expect_true(all(result$decisions$DeclaredC4RayLocallyAdjudicated))
  expect_true(all(!result$decisions$OtherSlopeRateRaysEvaluated))
  expect_true(all(!result$decisions$GlobalJointBoundaryProfileCertified))
  expect_true(all(result$signature_comparisons$DecisionInvariant))
  expect_identical(result$UpperVarianceJointPathStatus, "not_evaluated")
  expect_identical(result$SolutionToleranceStatus, "not_frozen")
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})
