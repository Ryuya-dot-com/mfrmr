gpcm_q_p1b_paths <- function() {
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
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-low-basin-quadrature-p1b-record-0.2.3.md"
    )
  )
}

gpcm_q_p1b_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_q_p1b_paths()
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
    sys.source(paths[["p1b"]], envir = value)
    value
  }
})

gpcm_q_p1b_fake_semantic <- function(offset = 0) {
  data.frame(
    SemanticKey = c(
      "facet::Rater::R1", "step::C1::transition1",
      "log_slope::C1", "slope::C1", "population_beta::(Intercept)",
      "population::log_sigma2", "population::sigma2"
    ),
    ParameterClass = c(
      "facet:Rater", "step", "log_slope", "slope", "population_beta",
      "population_log_sigma2", "population_sigma2"
    ),
    CoordinateSystem = c(
      "additive", "step", "log_slope", "slope", "population_beta",
      "population_log_sigma2", "population_sigma2"
    ),
    Value = seq_len(7L) / 10 + offset,
    stringsAsFactors = FALSE
  )
}

gpcm_q_p1b_fake_candidate <- function(
    scenario_id,
    lane,
    q,
    offset = 0,
    high = TRUE) {
  eap <- c(0.2, 0.4) + offset
  if (!high) eap <- -eap
  eligible <- identical(lane, "qualified_low")
  list(
    row = data.frame(
      ScenarioId = scenario_id,
      Lane = lane,
      QuadPoints = as.integer(q),
      P1BComparisonEligible = eligible,
      CommonDenseObjective = 10 + offset,
      PopulationSigma2 = 0.03 + offset,
      stringsAsFactors = FALSE
    ),
    semantic = gpcm_q_p1b_fake_semantic(offset),
    common_posterior = data.frame(
      Person = c("P01", "P02"),
      EAP = eap,
      PosteriorSD = c(0.1, 0.2),
      stringsAsFactors = FALSE
    )
  )
}

test_that("P1b pins the two-lane q plan and P1a dependency", {
  env <- gpcm_q_p1b_environment()
  paths <- gpcm_q_p1b_paths()
  plan <- env$mfrmr_gqi_p1b_plan()

  expect_identical(
    env$mfrmr_gqi_p1b_contract,
    "mfrmr_gpcm_low_basin_quadrature_p1b_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1a"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gqi_p1b_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1b"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "80a53048c687d10011bdf9a5e389abc9b29458b60277ec28e75ad94a05aafd9a"
  )
  expect_identical(env$mfrmr_gqi_p1b_quad_points, c(31L, 61L, 91L))
  expect_identical(env$mfrmr_gqi_p1b_common_quad_points, 121L)
  expect_identical(
    env$mfrmr_gqi_p1b_lanes,
    c("qualified_low", "diagnostic_default")
  )
  expect_identical(nrow(plan), 24L)
  expect_true(all(table(plan$ScenarioId, plan$Lane) == 3L))
  expect_true(all(
    plan$StartId[plan$Lane == "qualified_low"] == "variance_low"
  ))
  expect_true(all(
    plan$StartId[plan$Lane == "diagnostic_default"] == "default"
  ))
  expect_true(all(plan$SourceLaneEligible == (plan$Lane == "qualified_low")))
  expect_true(all(plan$CommonEvaluationQuadrature == 121L))
  expect_true(all(!plan$SelectionAuthorized))
  expect_true(all(!plan$ConfirmationAuthorized))
})

test_that("P1b candidate failure remains typed and ineligible", {
  env <- gpcm_q_p1b_environment()
  context <- list(
    coordinates = data.frame(CoordinateIndex = 1:3),
    quad_points = 31L
  )
  common <- context
  common$quad_points <- 121L
  run <- list(
    scenario_id = "MOCK",
    lane = "qualified_low",
    start_id = "variance_low",
    source_par = c(0, 0, 0),
    opt = NULL,
    warnings = "declared warning",
    error = "declared failure",
    elapsed = 0,
    fit = list(),
    native_context = context,
    common_context = common
  )
  candidate <- env$mfrmr_gqi_p1b_candidate(run)
  row <- candidate$row

  expect_false(row$FitReturned)
  expect_false(row$NativeEvaluationComplete)
  expect_false(row$CommonDenseEvaluationComplete)
  expect_false(row$PosteriorEvaluationComplete)
  expect_false(row$DimensionIdentity)
  expect_identical(row$ConvergenceSeverity, "fail")
  expect_false(row$ExistingNativeOptimizerPass)
  expect_false(row$P1BComparisonEligible)
  expect_false(row$P1BStabilityEligible)
  expect_match(row$P1BEligibilityReason, "incomplete", fixed = TRUE)
  expect_identical(row$WarningCount, 1L)
  expect_identical(row$ErrorText, "declared failure")
  expect_false(row$SelectionAuthorized)
  expect_false(row$ConfirmationAuthorized)
})

test_that("P1b pairwise comparisons use only the qualified lane", {
  env <- gpcm_q_p1b_environment()
  candidates <- list()
  for (q in c(31L, 61L, 91L)) {
    key <- paste("MOCK", "qualified_low", q, sep = "::")
    candidates[[key]] <- gpcm_q_p1b_fake_candidate(
      "MOCK",
      "qualified_low",
      q,
      offset = q / 1000,
      high = TRUE
    )
    diagnostic_key <- paste("MOCK", "diagnostic_default", q, sep = "::")
    candidates[[diagnostic_key]] <- gpcm_q_p1b_fake_candidate(
      "MOCK",
      "diagnostic_default",
      q,
      offset = q,
      high = TRUE
    )
  }
  comparison <- env$mfrmr_gqi_p1b_pairwise(candidates)

  expect_identical(nrow(comparison$summary), 3L)
  expect_identical(nrow(comparison$semantic), 21L)
  expect_true(all(comparison$summary$BothComparisonEligible))
  expect_true(all(comparison$summary$CommonPosteriorPersons == 2L))
  expect_true(all(is.finite(comparison$summary$CommonDenseObjectiveAbsDifference)))
  expect_true(all(is.finite(comparison$summary$CommonEAPRMSE)))
  expect_true(all(is.finite(comparison$summary$CommonPosteriorSDRMSE)))
  expect_true(all(
    comparison$summary$ToleranceStatus == "not_frozen_calibration_only"
  ))
  expect_true(all(!comparison$summary$SelectionAuthorized))
  expect_true(all(!comparison$summary$ConfirmationAuthorized))

  broken <- candidates
  broken_key <- paste("MOCK", "qualified_low", 31L, sep = "::")
  broken[[broken_key]]$row$P1BComparisonEligible <- FALSE
  broken[[broken_key]]$row$CommonDenseObjective <- NA_real_
  broken[[broken_key]]$semantic <- data.frame()
  broken[[broken_key]]$common_posterior <- data.frame()
  fail_closed <- env$mfrmr_gqi_p1b_pairwise(broken)
  expect_identical(nrow(fail_closed$summary), 3L)
  expect_identical(sum(fail_closed$summary$BothComparisonEligible), 1L)
  expect_identical(nrow(fail_closed$semantic), 7L)
  expect_identical(
    sum(is.na(fail_closed$summary$CommonDenseObjectiveAbsDifference)),
    2L
  )
})

test_that("P1b reflection audit preserves lane eligibility", {
  env <- gpcm_q_p1b_environment()
  pairs <- list(
    c("EXT5-P-HI", "EXT5-P-LO"),
    c("EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO")
  )
  candidates <- list()
  for (pair in pairs) {
    for (lane in env$mfrmr_gqi_p1b_lanes) {
      for (q in env$mfrmr_gqi_p1b_quad_points) {
        high_key <- paste(pair[1L], lane, q, sep = "::")
        low_key <- paste(pair[2L], lane, q, sep = "::")
        candidates[[high_key]] <- gpcm_q_p1b_fake_candidate(
          pair[1L], lane, q, high = TRUE
        )
        candidates[[low_key]] <- gpcm_q_p1b_fake_candidate(
          pair[2L], lane, q, high = FALSE
        )
      }
    }
  }
  reflection <- env$mfrmr_gqi_p1b_reflection(candidates)

  expect_identical(nrow(reflection), 12L)
  expect_true(all(
    reflection$BothComparisonEligible ==
      (reflection$Lane == "qualified_low")
  ))
  expect_equal(reflection$CommonDenseObjectiveAbsDifference, rep(0, 12L))
  expect_equal(reflection$PopulationSigma2AbsDifference, rep(0, 12L))
  expect_equal(reflection$EAPSignReflectionRMSE, rep(0, 12L))
  expect_equal(reflection$EAPSignReflectionMaxAbs, rep(0, 12L))
  expect_equal(reflection$PosteriorSDReflectionRMSE, rep(0, 12L))
  expect_equal(reflection$PosteriorSDReflectionMaxAbs, rep(0, 12L))
  expect_true(all(!reflection$SelectionAuthorized))
  expect_true(all(!reflection$ConfirmationAuthorized))

  broken <- candidates
  broken_key <- paste("EXT5-P-HI", "qualified_low", 31L, sep = "::")
  broken[[broken_key]]$row$P1BComparisonEligible <- FALSE
  broken[[broken_key]]$row$CommonDenseObjective <- NA_real_
  broken[[broken_key]]$row$PopulationSigma2 <- NA_real_
  broken[[broken_key]]$common_posterior <- data.frame()
  fail_closed <- env$mfrmr_gqi_p1b_reflection(broken)
  selected <- fail_closed$Pair == "exact" &
    fail_closed$Lane == "qualified_low" & fail_closed$QuadPoints == 31L
  expect_false(fail_closed$BothComparisonEligible[selected])
  expect_true(is.na(fail_closed$CommonDenseObjectiveAbsDifference[selected]))
  expect_true(is.na(fail_closed$PopulationSigma2AbsDifference[selected]))
  expect_identical(fail_closed$CommonPersons[selected], 0L)
})

test_that("P1b signatures distinguish finite evaluation from readiness", {
  env <- gpcm_q_p1b_environment()
  qualified <- data.frame(
    SourceLaneEligible = TRUE,
    ExistingNativeOptimizerPass = TRUE,
    CommonDenseEvaluationComplete = TRUE,
    PosteriorEvaluationComplete = TRUE
  )
  signature <- env$mfrmr_gqi_p1b_signature(qualified)
  expect_identical(
    signature$State[signature$Metric == "source_lane"],
    "qualified_local_candidate"
  )
  expect_identical(
    signature$State[signature$Metric == "native_stationarity"],
    "pass"
  )
  expect_identical(
    signature$State[signature$Metric == "common_dense_evaluation"],
    "finite"
  )
  expect_identical(
    signature$State[signature$Metric == "continuous_integration"],
    "not_evaluated"
  )
  expect_identical(
    signature$State[signature$Metric == "overall"],
    "review"
  )
  diagnostic <- qualified
  diagnostic$SourceLaneEligible <- FALSE
  diagnostic$ExistingNativeOptimizerPass <- FALSE
  diagnostic_signature <- env$mfrmr_gqi_p1b_signature(diagnostic)
  expect_identical(
    diagnostic_signature$State[diagnostic_signature$Metric == "overall"],
    "blocked"
  )
  changed <- signature
  changed$State[changed$Metric == "continuous_integration"] <- "flagged"
  comparison <- env$mfrmr_gss_compare_signatures(signature, changed)
  expect_false(comparison$DecisionInvariant)
  expect_identical(comparison$ChangedMetrics, "continuous_integration")
  expect_true(all(nzchar(signature$Reason)))
})

test_that("P1b full endpoint quadrature audit remains explicitly opt-in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_LONG_VALIDATION"), "true"),
    "set MFRMR_RUN_LONG_VALIDATION=true for the 24-arm P1b audit"
  )
  testthat::skip_on_cran()
  env <- gpcm_q_p1b_environment()
  result <- env$mfrmr_run_gpcm_low_basin_quadrature_p1b()

  expect_identical(nrow(result$candidates), 24L)
  expect_identical(nrow(result$pairwise), 12L)
  expect_identical(nrow(result$semantic_differences), 432L)
  expect_identical(nrow(result$reflection), 12L)
  expect_identical(nrow(result$signature_comparisons), 12L)
  low <- result$scenario_lane_summary[
    result$scenario_lane_summary$Lane == "qualified_low", , drop = FALSE
  ]
  diagnostic <- result$scenario_lane_summary[
    result$scenario_lane_summary$Lane == "diagnostic_default", , drop = FALSE
  ]
  expect_true(all(low$ReturnedQuadratureArms == 3L))
  expect_true(all(low$ExistingNativePassArms == 3L))
  expect_true(all(low$ComparisonEligibleArms == 3L))
  expect_true(all(diagnostic$ReturnedQuadratureArms == 3L))
  expect_true(all(diagnostic$ExistingNativePassArms == 0L))
  expect_true(all(diagnostic$ComparisonEligibleArms == 0L))
  expect_true(all(result$pairwise$BothComparisonEligible))
  expect_true(all(result$signature_comparisons$DecisionInvariant))
  expect_true(all(!result$candidates$P1BStabilityEligible))
  expect_true(all(!result$candidates$SelectionAuthorized))
  expect_false(result$ContinuousIntegralCertificate)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})
