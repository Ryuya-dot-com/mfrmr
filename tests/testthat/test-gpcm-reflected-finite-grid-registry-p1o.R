gpcm_grfg_p1o_paths <- function() {
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
    p1m = "gpcm-profile-turning-point-p1m-0.2.3.R",
    p1n = "gpcm-category-reflection-transport-p1n-0.2.3.R",
    p1o = "gpcm-reflected-finite-grid-registry-p1o-0.2.3.R"
  )
  paths <- vapply(files, function(file) testthat::test_path(
    "..", "..", "inst", "validation", file
  ), character(1L))
  c(paths, record = testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-reflected-finite-grid-registry-p1o-record-0.2.3.md"
  ))
}

gpcm_grfg_p1o_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_grfg_p1o_paths()
    testthat::skip_if_not(all(file.exists(paths)), "validation artifacts excluded")
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    for (path in paths[!names(paths) %in% "record"]) sys.source(path, value)
    value
  }
})

test_that("P1o freezes P1n and finite-grid thresholds", {
  env <- gpcm_grfg_p1o_environment()
  paths <- gpcm_grfg_p1o_paths()
  expect_identical(
    env$mfrmr_grfg_p1o_contract,
    "mfrmr_gpcm_reflected_finite_grid_registry_p1o_v1"
  )
  expect_identical(
    digest::digest(paths[["p1n"]], "sha256", file = TRUE, serialize = FALSE),
    env$mfrmr_grfg_p1o_dependency_sha256
  )
  expect_identical(
    digest::digest(paths[["p1o"]], "sha256", file = TRUE, serialize = FALSE),
    "d65d94c6e8ac2df8a94091dfcf849d556e6a9736e3798bb70f6ccbaa42342e57"
  )
  expect_equal(env$mfrmr_grfg_p1o_objective_tolerance, 1e-9)
  expect_equal(env$mfrmr_grfg_p1o_gradient_tolerance, 1e-9)
})

test_that("P1o overall decision separates finite registry from continuum", {
  env <- gpcm_grfg_p1o_environment()
  points <- data.frame(ReflectedPointIdentityVerified = rep(TRUE, 1362L))
  high <- data.frame(
    EvidenceLayer = c(rep("P1k_agreeing", 125L), rep("P1l_continuation", 43L)),
    HighFiniteGridCellClassified = rep(TRUE, 168L)
  )
  registry <- data.frame(
    ReflectionStatus = c(rep("source_high", 168L), rep("transported_low", 168L)),
    ReflectedFiniteGridCellTransported = c(rep(FALSE, 168L), rep(TRUE, 168L))
  )
  decision <- env$mfrmr_grfg_p1o_overall(points, high, registry)

  expect_equal(decision$SourceStoredPointCount, 1362L)
  expect_equal(decision$FourFixtureFiniteGridCellCount, 336L)
  expect_equal(decision$P1kAgreeingHighCellCount, 125L)
  expect_equal(decision$P1lContinuationHighCellCount, 43L)
  expect_true(decision$FullFourFixtureFiniteGridRegistryCompleted)
  expect_false(decision$RefitFallbackRequired)
  expect_true(decision$ReflectedFiniteGridFixturesEvaluated)
  expect_false(decision$ReflectedFixturesEvaluated)
  expect_false(decision$FullFourFixtureRatioProfilesCompleted)
  expect_false(decision$ContinuousGlobalProfileCertified)
  expect_false(decision$CoefficientRatioProfilesCompleted)
  expect_false(decision$HessianInferenceAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1o stored-result audit remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1O_PILOT"), "true"),
    "set MFRMR_RUN_P1O_PILOT=true and MFRMR_P1N_RESULT to a P1n RDS"
  )
  path <- Sys.getenv("MFRMR_P1N_RESULT")
  testthat::skip_if_not(file.exists(path), "MFRMR_P1N_RESULT does not exist")
  env <- gpcm_grfg_p1o_environment()
  result <- env$mfrmr_run_gpcm_reflected_finite_grid_registry_p1o(
    readRDS(path), progress = FALSE
  )
  expect_s3_class(result, "mfrmr_gpcm_reflected_finite_grid_registry_p1o")
  expect_equal(nrow(result$points), 1362L)
  expect_equal(nrow(result$four_fixture_registry), 336L)
  expect_true(result$FullFourFixtureFiniteGridRegistryCompleted)
  expect_false(result$RefitFallbackRequired)
  expect_false(result$ContinuousGlobalProfileCertified)
  expect_false(result$CoefficientRatioProfilesCompleted)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1o record preserves finite completion and global fail closure", {
  text <- paste(readLines(gpcm_grfg_p1o_paths()[["record"]], warn = FALSE),
                collapse = "\n")
  expect_match(text, "FullFourFixtureFiniteGridRegistryCompleted = TRUE", fixed = TRUE)
  expect_match(text, "RefitFallbackRequired = FALSE", fixed = TRUE)
  expect_match(text, "ReflectedFiniteGridFixturesEvaluated = TRUE", fixed = TRUE)
  expect_match(text, "ReflectedFixturesEvaluated = FALSE", fixed = TRUE)
  expect_match(text, "ContinuousGlobalProfileCertified = FALSE", fixed = TRUE)
  expect_match(text, "CoefficientRatioProfilesCompleted = FALSE", fixed = TRUE)
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
