gpcm_variance_p1a_paths <- function() {
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
    )
  )
}

gpcm_variance_p1a_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_variance_p1a_paths()
    testthat::skip_if_not(
      all(file.exists(paths)),
      "internal validation artifacts are excluded"
    )
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["numerical"]], envir = value)
    sys.source(paths[["p0"]], envir = value)
    sys.source(paths[["p0b"]], envir = value)
    sys.source(paths[["p1a"]], envir = value)
    value
  }
})

gpcm_variance_p1a_mock_context <- function() {
  list(
    coordinates = data.frame(CoordinateIndex = 1:3),
    slices = list(log_sigma2 = 3L),
    fn = function(par) {
      (par[1] - 1)^2 + (par[2] + 2)^2 + (par[3] - 0.5)^2
    },
    gr = function(par) {
      2 * c(par[1] - 1, par[2] + 2, par[3] - 0.5)
    }
  )
}

gpcm_variance_p1a_mock_scenario <- function() {
  context <- gpcm_variance_p1a_mock_context()
  list(
    context = context,
    candidate_objects = list(
      default = list(par = c(4, 3, 6)),
      variance_low = list(par = c(-4, -3, -3.5))
    )
  )
}

test_that("P1a pins its P0b dependency and finite-grid contract", {
  env <- gpcm_variance_p1a_environment()
  paths <- gpcm_variance_p1a_paths()
  grid <- env$mfrmr_gvp_p1a_grid(gpcm_variance_p1a_mock_scenario())
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-population-variance-profile-p1a-record-0.2.3.md"
  )

  expect_true(file.exists(record))
  expect_identical(
    digest::digest(
      paths[["p1a"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "dc085c99f068ee5854ae67899c265b5f6a9e0fc7634ef31c064bdb0dc945064b"
  )
  expect_identical(
    env$mfrmr_gvp_p1a_contract,
    "mfrmr_gpcm_population_variance_profile_p1a_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p0b"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gvp_p1a_dependency_sha256
  )
  expect_identical(nrow(grid), 10L)
  expect_identical(grid$GridRole, env$mfrmr_gvp_p1a_grid_roles)
  expect_true(all(diff(grid$LogSigma2) > 0))
  expect_equal(grid$LogSigma2[c(1, 2, 3)], c(-16, -12, -8), tolerance = 0)
  expect_equal(
    grid$LogSigma2[grid$GridRole == "low_basin_anchor"],
    -3.5,
    tolerance = 0
  )
  expect_equal(
    grid$LogSigma2[grid$GridRole == "default_basin_anchor"],
    6,
    tolerance = 0
  )
  expect_length(unique(grid$GridSHA256), 1L)
  expect_true(all(!grid$BoundaryLimitCertified))
  expect_true(all(!grid$SelectionAuthorized))
  expect_true(all(!grid$ConfirmationAuthorized))
})

test_that("P1a reoptimizes nuisance coordinates at a fixed variance", {
  env <- gpcm_variance_p1a_environment()
  context <- gpcm_variance_p1a_mock_context()
  grid_row <- data.frame(
    GridOrder = 1L,
    GridRole = "declared_mock_interior",
    GridSHA256 = paste(rep("a", 64L), collapse = ""),
    LogSigma2 = 0.5,
    Sigma2 = exp(0.5),
    QuadPoints = 31L,
    stringsAsFactors = FALSE
  )
  row <- env$mfrmr_gvp_p1a_profile_row(
    scenario_id = "MOCK",
    context = context,
    anchor_id = "default",
    anchor_object = list(par = c(5, 5, 6)),
    grid_row = grid_row,
    maxit = 200L,
    reltol = 1e-10
  )

  expect_true(row$FitReturned)
  expect_true(row$CommonEvaluationComplete)
  expect_true(row$DimensionIdentity)
  expect_identical(row$TotalFreeDimension, 3L)
  expect_identical(row$FixedDimension, 1L)
  expect_identical(row$NuisanceDimension, 2L)
  expect_lt(row$CommonObjective, 1e-16)
  expect_lt(row$NuisanceGradientMaxAbs, 1e-6)
  expect_lt(abs(row$FixedAnalyticGradient), 1e-12)
  expect_lt(row$FixedGradientAbsDifference, 1e-8)
  expect_true(row$ExistingNuisanceOptimizerPass)
  expect_identical(
    row$ProfileStatus,
    "finite_grid_local_nuisance_profile_existing_pass"
  )
  expect_false(row$BoundaryLimitCertified)
  expect_false(row$ContinuousIntegralCertificate)
  expect_false(row$ProfileSelectionAuthorized)
  expect_false(row$SelectionAuthorized)
  expect_false(row$ConfirmationAuthorized)
})

test_that("P1a diagnostic envelopes distinguish finite and qualified rows", {
  env <- gpcm_variance_p1a_environment()
  context <- gpcm_variance_p1a_mock_context()
  grid_row <- data.frame(
    GridOrder = 1L,
    GridRole = "declared_mock_interior",
    GridSHA256 = paste(rep("b", 64L), collapse = ""),
    LogSigma2 = 0.5,
    Sigma2 = exp(0.5),
    QuadPoints = 31L,
    stringsAsFactors = FALSE
  )
  left <- env$mfrmr_gvp_p1a_profile_row(
    "MOCK", context, "default", list(par = c(5, 5, 6)),
    grid_row, 200L, 1e-10
  )
  right <- env$mfrmr_gvp_p1a_profile_row(
    "MOCK", context, "variance_low", list(par = c(-5, -5, -3)),
    grid_row, 200L, 1e-10
  )
  envelope <- env$mfrmr_gvp_p1a_envelope(rbind(left, right))

  expect_identical(nrow(envelope), 1L)
  expect_identical(envelope$DeclaredBasins, 2L)
  expect_identical(envelope$ReturnedBasins, 2L)
  expect_identical(envelope$ExistingPassBasins, 2L)
  expect_true(envelope$DiagnosticEnvelopeExistingPass)
  expect_true(envelope$GridProfileQualified)
  expect_true(is.finite(envelope$DiagnosticEnvelopeObjective))
  expect_true(is.finite(envelope$ExistingPassEnvelopeObjective))
  expect_false(envelope$BoundaryLimitCertified)
  expect_false(envelope$ContinuousIntegralCertificate)
  expect_false(envelope$ProfileSelectionAuthorized)
  expect_false(envelope$SelectionAuthorized)
  expect_false(envelope$ConfirmationAuthorized)
})

test_that("P1a retains typed failure rows and fail-closed signatures", {
  env <- gpcm_variance_p1a_environment()
  context <- gpcm_variance_p1a_mock_context()
  grid_row <- data.frame(
    GridOrder = 1L,
    GridRole = "declared_mock_failure",
    GridSHA256 = paste(rep("c", 64L), collapse = ""),
    LogSigma2 = 0.5,
    Sigma2 = exp(0.5),
    QuadPoints = 31L,
    stringsAsFactors = FALSE
  )
  failed <- env$mfrmr_gvp_p1a_profile_row(
    "MOCK", context, "default", NULL, grid_row, 10L, 1e-10
  )
  expect_false(failed$FitReturned)
  expect_false(failed$CommonEvaluationComplete)
  expect_false(failed$DimensionIdentity)
  expect_false(failed$ExistingNuisanceOptimizerPass)
  expect_identical(failed$ConvergenceSeverity, "fail")
  expect_identical(failed$ProfileStatus, "blocked_profile_fit_failed")
  expect_true(nzchar(failed$ErrorText))

  summary <- data.frame(
    AllProfileRowsReturned = FALSE,
    AllProfileRowsExistingPass = FALSE
  )
  signature <- env$mfrmr_gvp_p1a_signature(summary)
  expect_identical(
    signature$State[signature$Metric == "profile_return"],
    "review"
  )
  expect_identical(
    signature$State[signature$Metric == "small_variance_limit"],
    "not_evaluated"
  )
  expect_identical(
    signature$State[signature$Metric == "overall"],
    "blocked"
  )
  expect_true(all(nzchar(signature$Reason)))
  changed <- signature
  changed$State[changed$Metric == "small_variance_limit"] <- "flagged"
  comparison <- env$mfrmr_gss_compare_signatures(signature, changed)
  expect_false(comparison$DecisionInvariant)
  expect_identical(comparison$ChangedMetrics, "small_variance_limit")
})

test_that("P1a long four-scenario profile remains explicitly opt-in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the 80-row polished profile"
  )
  testthat::skip_on_cran()
  env <- gpcm_variance_p1a_environment()
  result <- env$mfrmr_run_gpcm_population_variance_profile_p1a()

  expect_identical(nrow(result$profiles), 80L)
  expect_identical(nrow(result$diagnostic_envelope), 40L)
  expect_true(all(result$scenario_summary$AllProfileRowsReturned))
  expect_identical(
    result$scenario_summary$DiagnosticEnvelopeMinimumRole,
    rep("low_basin_anchor", 4L)
  )
  expect_true(all(
    result$scenario_summary$DiagnosticEnvelopeMinimumExistingPass
  ))
  expect_true(all(result$scenario_summary$DiagnosticMinimumInteriorToFiniteGrid))
  expect_true(all(!result$scenario_summary$BoundaryLimitCertified))
  expect_true(all(!result$scenario_summary$ContinuousIntegralCertificate))
  expect_true(all(!result$scenario_summary$SelectionAuthorized))
  expect_false(result$ProfileSelectionAuthorized)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})
