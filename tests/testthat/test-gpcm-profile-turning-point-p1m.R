gpcm_pt_p1m_paths <- function() {
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
    p1i = "gpcm-two-target-radial-screen-p1i-0.2.3.R",
    p1j = "gpcm-ordered-ratio-boundary-p1j-0.2.3.R",
    p1k = "gpcm-fixed-mu-ratio-profile-p1k-0.2.3.R",
    p1l = "gpcm-fixed-rho-basin-continuation-p1l-0.2.3.R",
    p1m = "gpcm-profile-turning-point-p1m-0.2.3.R"
  )
  paths <- vapply(files, function(file) testthat::test_path(
    "..", "..", "inst", "validation", file
  ), character(1L))
  c(
    paths,
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-profile-turning-point-p1m-record-0.2.3.md"
    )
  )
}

gpcm_pt_p1m_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_pt_p1m_paths()
    testthat::skip_if_not(
      all(file.exists(paths)),
      "internal validation artifacts are excluded"
    )
    testthat::skip_if_not_installed("digest")
    testthat::skip_if_not_installed("numDeriv")
    value <<- new.env(parent = globalenv())
    for (path in paths[!names(paths) %in% "record"]) {
      sys.source(path, envir = value)
    }
    value
  }
})

test_that("P1m freezes P1l and a four-representative local audit", {
  env <- gpcm_pt_p1m_environment()
  paths <- gpcm_pt_p1m_paths()

  expect_identical(
    env$mfrmr_gpt_p1m_contract,
    "mfrmr_gpcm_profile_turning_point_p1m_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1l"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gpt_p1m_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1m"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "7056ea9d3e51aac91103aef570557a60dac018f989adaff4d6061d1425a1449c"
  )
  expect_equal(length(env$mfrmr_gpt_p1m_expected_representatives), 4L)
  expect_identical(
    unname(env$mfrmr_gpt_p1m_expected_representatives),
    c(
      "EXT5-P-NEAR-HI::C4_fast__C3_slow::0",
      "EXT5-P-HI::C1_fast__C4_slow::0",
      "EXT5-P-HI::C1_fast__C2_slow::0",
      "EXT5-P-HI::C4_fast__C1_slow::0.003"
    )
  )
  expect_equal(env$mfrmr_gpt_p1m_gradient_tolerance, 2e-6)
  expect_equal(env$mfrmr_gpt_p1m_bracket_width_tolerance, 1e-7)
  expect_equal(env$mfrmr_gpt_p1m_monotone_grid, seq(0, 1, by = 0.125))
})

test_that("P1m representative tie breaking is deterministic", {
  env <- gpcm_pt_p1m_environment()
  cells <- data.frame(
    CellId = c("z", "a", "m"),
    MechanismClass = rep("target", 3L),
    Metric = c(1, 1 - 5e-9, 0.5),
    stringsAsFactors = FALSE
  )
  selected <- env$mfrmr_gpt_p1m_select_one(
    cells, "target", "Metric", "representative"
  )

  expect_identical(selected$CellId, "a")
  expect_identical(selected$RepresentativeId, "representative")
  expect_identical(selected$SelectionMetric, "Metric")
  expect_equal(selected$SelectionMetricValue, 1 - 5e-9)
  expect_match(selected$SelectionRule, "largest_Metric", fixed = TRUE)
})

test_that("P1m selects the narrowest robust derivative bracket", {
  env <- gpcm_pt_p1m_environment()
  maximum <- data.frame(
    Rho = c(0, 0.25, 0.5, 0.75, 1),
    MeanRhoObjectiveDerivative = c(1, 0.4, 0, -0.2, -1)
  )
  minimum <- transform(
    maximum,
    MeanRhoObjectiveDerivative = -MeanRhoObjectiveDerivative
  )
  maximum_bracket <- env$mfrmr_gpt_p1m_choose_bracket(
    maximum, "route_coalescence_profile_maximum_bracket"
  )
  minimum_bracket <- env$mfrmr_gpt_p1m_choose_bracket(
    minimum, "route_coalescence_profile_minimum_bracket"
  )

  expect_equal(maximum_bracket$LeftRho, 0.25)
  expect_equal(maximum_bracket$RightRho, 0.75)
  expect_equal(maximum_bracket$LeftSign, 1L)
  expect_equal(maximum_bracket$RightSign, -1L)
  expect_equal(minimum_bracket$LeftRho, 0.25)
  expect_equal(minimum_bracket$RightRho, 0.75)
  expect_equal(minimum_bracket$LeftSign, -1L)
  expect_equal(minimum_bracket$RightSign, 1L)
})

test_that("P1m strict optimizer and Hessian recover a convex control", {
  env <- gpcm_pt_p1m_environment()
  center <- c(0.2, -0.4)
  curvature <- diag(c(2, 6))
  fn <- function(value) {
    delta <- value - center
    drop(crossprod(delta, curvature %*% delta) / 2)
  }
  gr <- function(value) curvature %*% (value - center)
  optimized <- env$mfrmr_gpt_p1m_optimize(c(3, -2), fn, gr)
  hessian <- env$mfrmr_gpt_p1m_hessian(
    fn, gr, optimized$par, independent = TRUE
  )

  expect_true(optimized$returned)
  expect_equal(optimized$selected$opt$convergence, 0L)
  expect_lte(optimized$selected$gradient_sup, 2e-6)
  expect_equal(optimized$par, center, tolerance = 1e-7)
  expect_true(hessian$available)
  expect_true(hessian$independent_available)
  expect_equal(hessian$minimum_eigenvalue, 2, tolerance = 1e-6)
  expect_equal(hessian$maximum_eigenvalue, 6, tolerance = 1e-6)
  expect_equal(hessian$condition_number, 3, tolerance = 1e-6)
  expect_true(hessian$positive_definite)
  expect_true(hessian$symmetry_pass)
  expect_true(hessian$independent_agreement_pass)
  expect_lte(hessian$agreement_max_abs_difference, 1e-6)
  expect_lte(hessian$agreement_relative_difference, 1e-6)
  expect_equal(hessian$independent_minimum_eigenvalue, 2, tolerance = 1e-6)
  expect_lte(hessian$spectral_perturbation_ratio, 1e-6)
  expect_lte(hessian$minimum_eigen_relative_difference, 1e-6)
})

test_that("P1m overall decision keeps local and global claims separate", {
  env <- gpcm_pt_p1m_environment()
  turning <- data.frame(
    LocalTurningPointMechanismSupported = rep(TRUE, 3L)
  )
  monotone <- data.frame(AdaptiveGridMonotonicitySupported = TRUE)
  decision <- env$mfrmr_gpt_p1m_overall(turning, monotone)

  expect_equal(decision$RepresentativeMechanismCount, 4L)
  expect_true(decision$AllThreeTurningPointRepresentativesLocallySupported)
  expect_true(decision$MonotoneRepresentativeAdaptiveGridSupported)
  expect_true(decision$AllRepresentativeLocalMechanismsSupported)
  expect_false(decision$ContinuousMonotonicityCertified)
  expect_false(decision$ContinuousGlobalProfileCertified)
  expect_false(decision$ReflectedFixturesEvaluated)
  expect_false(decision$CoefficientRatioProfilesCompleted)
  expect_false(decision$AllSixTwoTargetFacesGloballyCertified)
  expect_false(decision$ThreeTargetFacesEvaluated)
  expect_false(decision$HessianInferenceAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1m chained local audit remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1M_PILOT"), "true"),
    "set MFRMR_RUN_P1M_PILOT=true for the chained P1m pilot"
  )
  env <- gpcm_pt_p1m_environment()
  p1j <- env$mfrmr_run_gpcm_ordered_ratio_boundary_p1j(
    allow_dependency_rebuild = TRUE,
    progress = FALSE
  )
  p1k <- env$mfrmr_run_gpcm_fixed_mu_ratio_profile_p1k(
    p1j, progress = FALSE
  )
  objective <- env$mfrmr_run_gpcm_fixed_rho_basin_continuation_p1l(
    p1k, registry_scope = "objective_discordant", progress = FALSE
  )
  coordinate <- env$mfrmr_run_gpcm_fixed_rho_basin_continuation_p1l(
    p1k, registry_scope = "coordinate_only", progress = FALSE
  )
  result <- env$mfrmr_run_gpcm_profile_turning_point_p1m(
    objective, coordinate, progress = FALSE
  )

  expect_s3_class(result, "mfrmr_gpcm_profile_turning_point_p1m")
  expect_equal(nrow(result$representatives), 4L)
  expect_equal(nrow(result$turning), 3L)
  expect_equal(nrow(result$monotone), 1L)
  expect_true(result$AllRepresentativeLocalMechanismsSupported)
  expect_false(result$ContinuousMonotonicityCertified)
  expect_false(result$ContinuousGlobalProfileCertified)
  expect_false(result$ReflectedFixturesEvaluated)
  expect_false(result$CoefficientRatioProfilesCompleted)
  expect_false(result$HessianInferenceAuthorized)
  expect_false(result$DFFFitRankAuthorized)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1m record preserves local support and global fail closure", {
  paths <- gpcm_pt_p1m_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(text, "objective_profile_maximum", fixed = TRUE)
  expect_match(text, "objective_profile_minimum", fixed = TRUE)
  expect_match(text, "objective_monotone_increasing", fixed = TRUE)
  expect_match(text, "coordinate_profile_minimum", fixed = TRUE)
  expect_match(
    text, "AllRepresentativeLocalMechanismsSupported = TRUE", fixed = TRUE
  )
  expect_match(
    text, "ContinuousMonotonicityCertified = FALSE", fixed = TRUE
  )
  expect_match(
    text, "ContinuousGlobalProfileCertified = FALSE", fixed = TRUE
  )
  expect_match(text, "ReflectedFixturesEvaluated = FALSE", fixed = TRUE)
  expect_match(
    text, "CoefficientRatioProfilesCompleted = FALSE", fixed = TRUE
  )
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
