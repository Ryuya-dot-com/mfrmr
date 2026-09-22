gpcm_fr_p1l_paths <- function() {
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
    p1l = "gpcm-fixed-rho-basin-continuation-p1l-0.2.3.R"
  )
  paths <- vapply(files, function(file) testthat::test_path(
    "..", "..", "inst", "validation", file
  ), character(1L))
  c(
    paths,
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-fixed-rho-basin-continuation-p1l-record-0.2.3.md"
    )
  )
}

gpcm_fr_p1l_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_fr_p1l_paths()
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

gpcm_fr_p1l_registry_row <- function(
    env,
    p1k_class = "competing_kkt_solutions",
    low_rho = 0,
    high_rho = 1) {
  data.frame(
    ScenarioId = "EXT5-P-HI",
    OrderedPairId = "C1_fast__C2_slow",
    FastIndex = 1L,
    SlowIndex = 2L,
    TargetSetId = "C1+C2",
    Mu = 0,
    P1kAgreementClass = p1k_class,
    CellId = "EXT5-P-HI::C1_fast__C2_slow::0",
    CellOrder = 1L,
    P1kLowRouteRho = low_rho,
    P1kHighRouteRho = high_rho,
    P1kLowRouteObjectiveQ121 = 5,
    P1kHighRouteObjectiveQ121 = 5,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

gpcm_fr_p1l_pairwise_control <- function(env, derivative) {
  rho <- env$mfrmr_gfrb_p1l_rho_grid
  stopifnot(length(derivative) == length(rho))
  data.frame(
    ScenarioId = "EXT5-P-HI",
    OrderedPairId = "C1_fast__C2_slow",
    FastIndex = 1L,
    SlowIndex = 2L,
    TargetSetId = "C1+C2",
    CellId = "EXT5-P-HI::C1_fast__C2_slow::0",
    Mu = 0,
    Rho = rho,
    BothRoutesPresent = TRUE,
    BothRoutesEligible = TRUE,
    LowObjectiveQ121 = 5,
    HighObjectiveQ121 = 5,
    LowMinusHighObjective = 0,
    ObjectiveAbsDifference = 0,
    LowRhoObjectiveDerivative = derivative,
    HighRhoObjectiveDerivative = derivative,
    MeanRhoObjectiveDerivative = derivative,
    RhoObjectiveDerivativeAbsDifference = 0,
    NuisanceCoordinateMaxAbsDifference = 0,
    ObjectiveAgreementWithinTolerance = TRUE,
    CoordinateAgreementWithinTolerance = TRUE,
    RouteAgreementClass = "same_fixed_rho_solution",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

test_that("P1l freezes P1k and the two scoped finite-grid plans", {
  env <- gpcm_fr_p1l_environment()
  paths <- gpcm_fr_p1l_paths()
  registry <- gpcm_fr_p1l_registry_row(
    env, low_rho = 0.257, high_rho = 0.9999
  )
  plan <- env$mfrmr_gfrb_p1l_plan(registry)

  expect_identical(
    env$mfrmr_gfrb_p1l_contract,
    "mfrmr_gpcm_fixed_rho_basin_continuation_p1l_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1k"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gfrb_p1l_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1l"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "8c2feb1938d9055e17c796b1d85632235bbeaf875145dc94b7adfe465abba318"
  )
  expect_equal(env$mfrmr_gfrb_p1l_rho_grid, c(
    0, 0.01, 0.03, 0.10, 0.25, 0.50,
    0.75, 0.90, 0.97, 0.99, 1
  ))
  expect_equal(plan$cell_count, 1L)
  expect_equal(plan$rho_point_count, 11L)
  expect_equal(plan$distinct_cell_rho_point_count, 13L)
  expect_equal(plan$fit_count, 26L)
  expect_equal(sum(plan$continuation$IndependentGradientScheduled), 3L)
  expect_equal(
    sum(plan$continuation$RhoSource == "p1k_stationary_candidate"), 4L
  )
  expect_false(plan$ReflectedFixturesEvaluated)
  expect_false(plan$FullTwoTargetFaceGloballyCertified)
  expect_false(plan$SelectionAuthorized)
  expect_false(plan$ConfirmationAuthorized)
})

test_that("P1l derivative brackets distinguish maxima minima and monotonicity", {
  env <- gpcm_fr_p1l_environment()
  registry <- gpcm_fr_p1l_registry_row(env)
  n <- length(env$mfrmr_gfrb_p1l_rho_grid)

  maximum <- env$mfrmr_gfrb_p1l_cell_classification(
    gpcm_fr_p1l_pairwise_control(
      env, c(rep(2e-4, 5L), 0, rep(-2e-4, n - 6L))
    ),
    registry
  )
  minimum <- env$mfrmr_gfrb_p1l_cell_classification(
    gpcm_fr_p1l_pairwise_control(
      env, c(rep(-2e-4, 5L), 0, rep(2e-4, n - 6L))
    ),
    registry
  )
  increasing <- env$mfrmr_gfrb_p1l_cell_classification(
    gpcm_fr_p1l_pairwise_control(env, rep(2e-4, n)),
    registry
  )

  expect_identical(
    maximum$MechanismClass,
    "route_coalescence_profile_maximum_bracket"
  )
  expect_true(maximum$PositiveToNegativeDerivativeBracketObserved)
  expect_false(maximum$NegativeToPositiveDerivativeBracketObserved)
  expect_identical(
    minimum$MechanismClass,
    "route_coalescence_profile_minimum_bracket"
  )
  expect_false(minimum$PositiveToNegativeDerivativeBracketObserved)
  expect_true(minimum$NegativeToPositiveDerivativeBracketObserved)
  expect_identical(
    increasing$MechanismClass,
    "route_coalescence_monotone_increasing_grid"
  )
  expect_true(increasing$SameObjectiveAtEveryGridPoint)
  expect_true(increasing$SameSolutionAtEveryGridPoint)
  expect_true(increasing$FiniteGridOnly)
  expect_false(increasing$ContinuousBarrierCertified)
  expect_false(increasing$SelectionAuthorized)
  expect_false(increasing$ConfirmationAuthorized)
})

test_that("P1l objective and coordinate scopes remain separate", {
  env <- gpcm_fr_p1l_environment()
  profile <- data.frame(
    ContinuationCandidateEligible = rep(TRUE, 22L)
  )
  pairwise <- data.frame(BothRoutesEligible = rep(TRUE, 11L))
  cells <- data.frame(
    AllGridPointsHaveTwoEligibleRoutes = TRUE,
    MechanismClass = "route_coalescence_profile_minimum_bracket"
  )
  portfolio <- data.frame(BestContinuationAboveInterior = TRUE)
  coordinate_registry <- gpcm_fr_p1l_registry_row(
    env, "same_objective_coordinate_distinct"
  )
  decision <- env$mfrmr_gfrb_p1l_overall_decision(
    profile, pairwise, cells, portfolio, coordinate_registry
  )

  expect_equal(decision$ObjectiveDiscordantRegistryCellCount, 0L)
  expect_equal(decision$CoordinateOnlyRegistryCellCount, 1L)
  expect_true(decision$AllContinuationFitsEligible)
  expect_false(decision$ObjectiveDiscordantFixedRhoContinuationCompleted)
  expect_false(decision$CoordinateOnlyFixedRhoContinuationCompleted)
  expect_true(decision$FiniteGridOnly)
  expect_false(decision$ContinuousBarrierCertified)
  expect_false(decision$CoefficientRatioProfilesCompleted)
  expect_false(decision$AllSixTwoTargetFacesGloballyCertified)
  expect_false(decision$ThreeTargetFacesEvaluated)
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1l chained continuation remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1L_PILOT"), "true"),
    "set MFRMR_RUN_P1L_PILOT=true for the chained P1l pilot"
  )
  env <- gpcm_fr_p1l_environment()
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

  expect_equal(nrow(objective$registry), 33L)
  expect_equal(nrow(objective$profile), 766L)
  expect_true(objective$ObjectiveDiscordantFixedRhoContinuationCompleted)
  expect_equal(nrow(coordinate$registry), 10L)
  expect_equal(nrow(coordinate$profile), 260L)
  expect_true(coordinate$CoordinateOnlyFixedRhoContinuationCompleted)
  expect_true(all(objective$profile$ContinuationCandidateEligible))
  expect_true(all(coordinate$profile$ContinuationCandidateEligible))
  expect_false(objective$ContinuousBarrierCertified)
  expect_false(coordinate$ContinuousBarrierCertified)
  expect_false(objective$SelectionAuthorized)
  expect_false(coordinate$ConfirmationAuthorized)
})

test_that("P1l record preserves coalescence without a global certificate", {
  paths <- gpcm_fr_p1l_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(text, "766/766", fixed = TRUE)
  expect_match(text, "260/260", fixed = TRUE)
  expect_match(text, "22/33", fixed = TRUE)
  expect_match(text, "6/33", fixed = TRUE)
  expect_match(text, "5/33", fixed = TRUE)
  expect_match(text, "10/10", fixed = TRUE)
  expect_match(
    text,
    "ObjectiveDiscordantFixedRhoContinuationCompleted = TRUE",
    fixed = TRUE
  )
  expect_match(
    text,
    "CoordinateOnlyFixedRhoContinuationCompleted = TRUE",
    fixed = TRUE
  )
  expect_match(text, "ContinuousBarrierCertified = FALSE", fixed = TRUE)
  expect_match(
    text, "CoefficientRatioProfilesCompleted = FALSE", fixed = TRUE
  )
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
