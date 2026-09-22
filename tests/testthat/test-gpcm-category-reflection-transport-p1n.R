gpcm_crt_p1n_paths <- function() {
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
    p1n = "gpcm-category-reflection-transport-p1n-0.2.3.R"
  )
  paths <- vapply(files, function(file) testthat::test_path(
    "..", "..", "inst", "validation", file
  ), character(1L))
  c(
    paths,
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-category-reflection-transport-p1n-record-0.2.3.md"
    )
  )
}

gpcm_crt_p1n_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_crt_p1n_paths()
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

gpcm_crt_p1n_mock_context <- function() {
  list(
    config = list(
      n_cat = 5L,
      facet_levels = list(
        Rater = paste0("R", 1:5),
        Criterion = paste0("C", 1:4)
      )
    ),
    sizes = list(steps = 12L)
  )
}

test_that("P1n freezes P1m and two reflection pairs", {
  env <- gpcm_crt_p1n_environment()
  paths <- gpcm_crt_p1n_paths()

  expect_identical(
    env$mfrmr_gcrt_p1n_contract,
    "mfrmr_gpcm_category_reflection_transport_p1n_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1m"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gcrt_p1n_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1n"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "8dba2f8393837fcb54c2124ea7a01eb90ad4051d8919ebc8f65b35f380e5b357"
  )
  expect_identical(
    env$mfrmr_gcrt_p1n_pairs$HighScenarioId,
    c("EXT5-P-HI", "EXT5-P-NEAR-HI")
  )
  expect_identical(
    env$mfrmr_gcrt_p1n_pairs$LowScenarioId,
    c("EXT5-P-LO", "EXT5-P-NEAR-LO")
  )
  expect_equal(env$mfrmr_gcrt_p1n_objective_tolerance, 1e-9)
  expect_equal(env$mfrmr_gcrt_p1n_gradient_tolerance, 1e-9)
  expect_equal(env$mfrmr_gcrt_p1n_numeric_gradient_tolerance, 2e-5)
})

test_that("P1n category kernel reflection is exact", {
  env <- gpcm_crt_p1n_environment()
  eta <- 0.37
  steps <- c(-0.8, 0.15, 0.43, 0.91)
  original <- env$mfrmr_gcrt_p1n_kernel(eta, steps)
  reflected <- env$mfrmr_gcrt_p1n_kernel(-eta, -rev(steps))

  expect_equal(sum(original), 1, tolerance = 1e-14)
  expect_equal(sum(reflected), 1, tolerance = 1e-14)
  expect_equal(original, rev(reflected), tolerance = 1e-14)
  expect_lte(env$mfrmr_gcrt_p1n_kernel_identity(eta, steps), 1e-14)
})

test_that("P1n free-coordinate reflection is a constraint-preserving involution", {
  env <- gpcm_crt_p1n_environment()
  context <- gpcm_crt_p1n_mock_context()
  layout <- env$mfrmr_gc4_p1g_layout(context)
  x <- seq(-0.4, 0.55, length.out = layout$dimension)
  reflected <- env$mfrmr_gcrt_p1n_reflect_x(x, context)
  recovered <- env$mfrmr_gcrt_p1n_reflect_x(reflected, context)
  transformation <- env$mfrmr_gcrt_p1n_reflection_matrix(context)

  reflected_step_free <- matrix(
    reflected[layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  reflected_steps <- t(vapply(seq_len(layout$n_criterion), function(index) {
    env$mfrmr_gss_get("expand_sum_zero_vector")(
      reflected_step_free[index, ], context$config$n_cat - 1L
    )
  }, numeric(context$config$n_cat - 1L)))

  expect_equal(recovered, x, tolerance = 1e-14)
  expect_equal(as.vector(transformation %*% x), reflected, tolerance = 1e-14)
  expect_equal(
    transformation %*% transformation,
    diag(layout$dimension), tolerance = 1e-14
  )
  expect_equal(qr(transformation)$rank, layout$dimension)
  expect_equal(rowSums(reflected_steps), rep(0, 4L), tolerance = 1e-14)
})

test_that("P1n context audit requires scores and quadrature to mirror", {
  env <- gpcm_crt_p1n_environment()
  base <- gpcm_crt_p1n_mock_context()
  base$idx <- list(
    person = c(1L, 1L, 2L),
    slope_idx = c(1L, 2L, 1L),
    facets = list(
      Rater = c(1L, 2L, 1L),
      Criterion = c(1L, 2L, 1L)
    ),
    score_k = c(0L, 2L, 4L),
    weight = c(1, 2, 1)
  )
  base$quad <- list(nodes = c(-1, 0, 1), weights = c(0.2, 0.6, 0.2))
  low <- base
  low$idx$score_k <- 4L - base$idx$score_k
  audit <- env$mfrmr_gcrt_p1n_context_audit(base, low, "mock", 3L)

  expect_true(audit$StructuralIndexIdentity)
  expect_true(audit$ExactScoreReflection)
  expect_true(audit$ObservationWeightIdentity)
  expect_true(audit$ContextReflectionIdentityVerified)

  low$quad$nodes[1L] <- low$quad$nodes[1L] + 0.01
  failed <- env$mfrmr_gcrt_p1n_context_audit(base, low, "mock", 3L)
  expect_false(failed$ContextReflectionIdentityVerified)
})

test_that("P1n overall decision keeps local transport and global closure separate", {
  env <- gpcm_crt_p1n_environment()
  context <- data.frame(
    ContextReflectionIdentityVerified = rep(TRUE, 6L)
  )
  coordinate <- data.frame(
    LinearCoordinateInvolutionVerified = rep(TRUE, 2L)
  )
  points <- data.frame(
    ReflectedPointIdentityVerified = rep(TRUE, 87L)
  )
  mechanisms <- data.frame(
    ReflectedLocalMechanismTransported = rep(TRUE, 4L)
  )
  decision <- env$mfrmr_gcrt_p1n_overall(
    context, coordinate, points, mechanisms
  )

  expect_true(decision$ReflectedRepresentativeFixturesEvaluated)
  expect_true(decision$AllFourLocalMechanismsTransported)
  expect_false(decision$RefitFallbackRequired)
  expect_false(decision$ReflectedFixturesEvaluated)
  expect_false(decision$FullFourFixtureRatioProfilesCompleted)
  expect_false(decision$ContinuousGlobalProfileCertified)
  expect_false(decision$CoefficientRatioProfilesCompleted)
  expect_false(decision$HessianInferenceAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1n stored-result audit remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1N_PILOT"), "true"),
    "set MFRMR_RUN_P1N_PILOT=true and MFRMR_P1M_RESULT to a P1m RDS"
  )
  path <- Sys.getenv("MFRMR_P1M_RESULT")
  testthat::skip_if_not(file.exists(path), "MFRMR_P1M_RESULT does not exist")
  env <- gpcm_crt_p1n_environment()
  result <- env$mfrmr_run_gpcm_category_reflection_transport_p1n(
    readRDS(path), progress = FALSE
  )

  expect_s3_class(result, "mfrmr_gpcm_category_reflection_transport_p1n")
  expect_equal(nrow(result$points), 87L)
  expect_true(result$ReflectedRepresentativeFixturesEvaluated)
  expect_false(result$RefitFallbackRequired)
  expect_false(result$ReflectedFixturesEvaluated)
  expect_false(result$ContinuousGlobalProfileCertified)
  expect_false(result$CoefficientRatioProfilesCompleted)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1n record preserves transported local and failed-closed global claims", {
  paths <- gpcm_crt_p1n_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(
    text, "ReflectedRepresentativeFixturesEvaluated = TRUE", fixed = TRUE
  )
  expect_match(text, "RefitFallbackRequired = FALSE", fixed = TRUE)
  expect_match(text, "ReflectedFixturesEvaluated = FALSE", fixed = TRUE)
  expect_match(
    text, "FullFourFixtureRatioProfilesCompleted = FALSE", fixed = TRUE
  )
  expect_match(
    text, "ContinuousGlobalProfileCertified = FALSE", fixed = TRUE
  )
  expect_match(
    text, "CoefficientRatioProfilesCompleted = FALSE", fixed = TRUE
  )
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
