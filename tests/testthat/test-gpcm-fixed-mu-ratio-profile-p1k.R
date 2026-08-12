gpcm_fm_p1k_paths <- function() {
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
    p1k = "gpcm-fixed-mu-ratio-profile-p1k-0.2.3.R"
  )
  paths <- vapply(files, function(file) testthat::test_path(
    "..", "..", "inst", "validation", file
  ), character(1L))
  c(
    paths,
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-fixed-mu-ratio-profile-p1k-record-0.2.3.md"
    )
  )
}

gpcm_fm_p1k_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_fm_p1k_paths()
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

gpcm_fm_p1k_synthetic_context <- function() {
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

test_that("P1k freezes P1j and the representative pilot plan", {
  env <- gpcm_fm_p1k_environment()
  paths <- gpcm_fm_p1k_paths()
  plan <- env$mfrmr_gfmr_p1k_plan()

  expect_identical(
    env$mfrmr_gfmr_p1k_contract,
    "mfrmr_gpcm_fixed_mu_ratio_profile_p1k_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1j"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gfmr_p1k_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1k"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "7dba1c95c26ea2de644ff16f06a1c64480b77f2d47896b54d856c86358a9d1f8"
  )
  expect_equal(nrow(plan$profile), 336L)
  expect_equal(plan$fixed_mu_cell_count, 168L)
  expect_equal(plan$fit_count, 336L)
  expect_equal(plan$representative_scenario_count, 2L)
  expect_equal(plan$ordered_pair_count, 12L)
  expect_equal(sum(plan$profile$IndependentGradientScheduled), 48L)
  expect_false(plan$reflected_fixtures_evaluated)
  expect_false(plan$full_four_fixture_profile_completed)
  expect_false(plan$three_target_faces_evaluated)
  expect_false(plan$SelectionAuthorized)
  expect_false(plan$ConfirmationAuthorized)
})

test_that("P1k KKT conditions distinguish lower interior and upper", {
  env <- gpcm_fm_p1k_environment()

  lower_pass <- env$mfrmr_gfmr_p1k_kkt(c(0, 0), c(0, 0.3))
  lower_fail <- env$mfrmr_gfmr_p1k_kkt(c(0, 0), c(0, -0.3))
  interior_pass <- env$mfrmr_gfmr_p1k_kkt(c(0, 0.4), c(0, 0))
  interior_fail <- env$mfrmr_gfmr_p1k_kkt(c(0, 0.4), c(0, 0.3))
  upper_pass <- env$mfrmr_gfmr_p1k_kkt(c(0, 1), c(0, -0.3))
  upper_fail <- env$mfrmr_gfmr_p1k_kkt(c(0, 1), c(0, 0.3))

  expect_identical(lower_pass$rho_location, "lower")
  expect_true(lower_pass$kkt_pass)
  expect_false(lower_fail$kkt_pass)
  expect_equal(lower_fail$rho_kkt_violation, 0.3)
  expect_identical(interior_pass$rho_location, "interior")
  expect_true(interior_pass$kkt_pass)
  expect_false(interior_fail$kkt_pass)
  expect_identical(upper_pass$rho_location, "upper")
  expect_true(upper_pass$kkt_pass)
  expect_false(upper_fail$kkt_pass)
  expect_equal(upper_fail$rho_kkt_violation, 0.3)

  expect_equal(env$mfrmr_gfmr_p1k_clamp_rho(-1e-14), 0)
  expect_equal(env$mfrmr_gfmr_p1k_clamp_rho(1 + 1e-14), 1)
  expect_equal(env$mfrmr_gfmr_p1k_clamp_rho(0.4), 0.4)
})

test_that("P1k bounded optimizer recovers all three KKT locations", {
  env <- gpcm_fm_p1k_environment()
  targets <- c(lower = -0.4, interior = 0.4, upper = 1.4)
  for (name in names(targets)) {
    target <- targets[[name]]
    fn <- function(value) (value[1L] - 0.2)^2 + (value[2L] - target)^2
    gr <- function(value) c(
      2 * (value[1L] - 0.2),
      2 * (value[2L] - target)
    )
    result <- env$mfrmr_gfmr_p1k_optimize(
      c(0, 0.5), fn, gr, maxit = 200L, reltol = 1e-12
    )
    expect_true(result$returned)
    expect_equal(result$selected$opt$convergence, 0L)
    expect_true(result$selected$kkt$kkt_pass)
    expect_identical(result$selected$kkt$rho_location, name)
    expect_equal(result$par[1L], 0.2, tolerance = 1e-6)
    expect_equal(
      result$par[2L], min(1, max(0, target)), tolerance = 1e-6
    )
  }
})

test_that("P1k rho one is invariant to ordered-pair reversal", {
  env <- gpcm_fm_p1k_environment()
  context <- gpcm_fm_p1k_synthetic_context()
  layout <- env$mfrmr_gc4_p1g_layout(context)
  x <- seq(-0.15, 0.25, length.out = layout$dimension)
  for (targets in env$mfrmr_gtr_p1i_target_sets) {
    first <- env$mfrmr_gorb_p1j_bundle(
      x, 0.12, 1, context, targets[1L], targets[2L],
      include_gradient = TRUE
    )
    second <- env$mfrmr_gorb_p1j_bundle(
      x, 0.12, 1, context, targets[2L], targets[1L],
      include_gradient = TRUE
    )
    expect_equal(first$objective, second$objective, tolerance = 1e-12)
    expect_equal(first$gradient, second$gradient, tolerance = 1e-12)
    expect_equal(first$mu_gradient, second$mu_gradient, tolerance = 1e-12)
  }
})

test_that("P1k decisions retain multiple KKT basins and fail closed", {
  env <- gpcm_fm_p1k_environment()
  profile <- data.frame(
    ProfileCandidateEligible = rep(TRUE, 336L)
  )
  pairwise <- data.frame(
    BothRoutesEligible = rep(TRUE, 168L),
    RoutesAgreeWithinTolerance = c(rep(TRUE, 125L), rep(FALSE, 43L)),
    RouteAgreementClass = c(
      rep("same_solution", 125L),
      rep("same_objective_coordinate_distinct", 10L),
      rep("competing_kkt_solutions", 33L)
    )
  )
  portfolio <- data.frame(
    BestObservedAboveInterior = rep(TRUE, 12L)
  )
  decision <- env$mfrmr_gfmr_p1k_overall_decision(
    profile, pairwise, portfolio,
    env$mfrmr_gfmr_p1k_representative_scenarios
  )

  expect_true(decision$AllRepresentativeFitsEligible)
  expect_true(decision$AllRepresentativeCellsHaveTwoEligibleRoutes)
  expect_equal(decision$SameSolutionCellCount, 125L)
  expect_equal(decision$SameObjectiveCoordinateDistinctCellCount, 10L)
  expect_equal(decision$CompetingKktSolutionCellCount, 33L)
  expect_equal(decision$RouteIneligibleCellCount, 0L)
  expect_true(decision$AnyCompetingKktSolutions)
  expect_true(decision$AllObservedRepresentativeMinimaAboveInterior)
  expect_false(decision$RepresentativeFixedMuRatioProfilesCompleted)
  expect_false(decision$ReflectedFixturesEvaluated)
  expect_false(decision$FullFourFixtureRatioProfilesCompleted)
  expect_false(decision$CoefficientRatioProfilesCompleted)
  expect_false(decision$AllSixTwoTargetFacesGloballyCertified)
  expect_false(decision$ThreeTargetFacesEvaluated)
  expect_false(decision$GlobalJointBoundaryProfileCertified)
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1k chained representative pilot remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1K_PILOT"), "true"),
    "set MFRMR_RUN_P1K_PILOT=true for the chained P1k pilot"
  )
  env <- gpcm_fm_p1k_environment()
  p1j <- env$mfrmr_run_gpcm_ordered_ratio_boundary_p1j(
    allow_dependency_rebuild = TRUE,
    progress = FALSE
  )
  result <- env$mfrmr_run_gpcm_fixed_mu_ratio_profile_p1k(
    p1j, progress = FALSE
  )

  expect_s3_class(result, "mfrmr_gpcm_fixed_mu_ratio_profile_p1k")
  expect_equal(nrow(result$profile), 336L)
  expect_equal(nrow(result$pairwise), 168L)
  expect_equal(nrow(result$portfolio), 12L)
  expect_true(all(result$profile$ProfileCandidateEligible))
  expect_true(result$overall_decision$AllRepresentativeFitsEligible)
  expect_true(
    result$overall_decision$AllRepresentativeCellsHaveTwoEligibleRoutes
  )
  expect_equal(result$overall_decision$SameSolutionCellCount, 125L)
  expect_equal(
    result$overall_decision$SameObjectiveCoordinateDistinctCellCount, 10L
  )
  expect_equal(result$overall_decision$CompetingKktSolutionCellCount, 33L)
  expect_true(result$overall_decision$AllObservedRepresentativeMinimaAboveInterior)
  expect_false(result$RepresentativeFixedMuRatioProfilesCompleted)
  expect_false(result$ReflectedFixturesEvaluated)
  expect_false(result$FullFourFixtureRatioProfilesCompleted)
  expect_false(result$CoefficientRatioProfilesCompleted)
  expect_false(result$ThreeTargetFacesEvaluated)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1k record preserves the representative multi-basin blocker", {
  paths <- gpcm_fm_p1k_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(text, "336/336", fixed = TRUE)
  expect_match(text, "125/168", fixed = TRUE)
  expect_match(text, "10/168", fixed = TRUE)
  expect_match(text, "33/168", fixed = TRUE)
  expect_match(text, "AllRepresentativeFitsEligible = TRUE", fixed = TRUE)
  expect_match(
    text, "RepresentativeFixedMuRatioProfilesCompleted = FALSE", fixed = TRUE
  )
  expect_match(text, "ReflectedFixturesEvaluated = FALSE", fixed = TRUE)
  expect_match(
    text, "CoefficientRatioProfilesCompleted = FALSE", fixed = TRUE
  )
  expect_match(
    text, "AllSixTwoTargetFacesGloballyCertified = FALSE", fixed = TRUE
  )
  expect_match(text, "ThreeTargetFacesEvaluated = FALSE", fixed = TRUE)
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
