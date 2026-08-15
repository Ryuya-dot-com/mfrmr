load_conquest_p2_candidate_004_rank_hold_observation <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-replacement-nondegenerate-fixture-0.2.3.R",
    "conquest-p2-candidate-003-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-003-mfrmr-preflight-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-adaptive-density-contract-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-observation-0.2.3.R",
    "conquest-p2-candidate-004-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-004-fixture-observation-0.2.3.R",
    "conquest-p2-candidate-004-mfrmr-preflight-0.2.3.R",
    "conquest-p2-candidate-004-mfrmr-preflight-observation-0.2.3.R",
    "conquest-p2-candidate-004-live-authorization-0.2.3.R",
    "conquest-p2-candidate-004-harness-0.2.3.R",
    "conquest-p2-candidate-004-execution-observation-0.2.3.R",
    "conquest-reported-output-precision-contract-0.2.3.R",
    "conquest-p2-candidate-004-numerical-review-contract-0.2.3.R",
    "conquest-p2-candidate-004-numerical-observation-0.2.3.R",
    "conquest-p2-candidate-004-rank-hold-contract-0.2.3.R",
    "conquest-p2-candidate-004-rank-hold-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 rank observation is excluded.")
  env <- new.env(parent = globalenv())
  env$`%||%` <- function(x, y) if (is.null(x)) y else x
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("all four saved fits are locally full rank", {
  env <- load_conquest_p2_candidate_004_rank_hold_observation()$env
  review <- env$mfrmr_cq_p2c4rho_review()
  rows <- review$arm_observation

  expect_identical(rows$AdditiveRank, rows$AdditiveDimension)
  expect_true(all(rows$AdditiveNullity == 0L))
  expect_false(any(rows$AdditiveToleranceSensitive))
  expect_identical(rows$ObservedPatternScoreRank, rows$FullFreeDimension)
  expect_true(all(rows$ObservedPatternScoreNullity == 0L))
  expect_false(any(rows$ObservedPatternToleranceSensitive))
  expect_true(all(rows$LocalState == "locally_full_rank_sufficient"))
  expect_true(review$all_additive_designs_full_rank)
  expect_true(review$all_observed_pattern_scores_full_rank)
  expect_true(review$all_fixed_quadrature_local_states_full_rank)
})

test_that("local evidence preserves every global and readiness hold", {
  env <- load_conquest_p2_candidate_004_rank_hold_observation()$env
  review <- env$mfrmr_cq_p2c4rho_review()

  expect_identical(
    review$status,
    "candidate_004_local_full_rank_global_nonlinear_identification_open"
  )
  expect_false(review$global_marginal_identification_classified)
  expect_false(review$continuous_integral_identification_classified)
  expect_false(review$weak_information_classified)
  expect_true(review$bounded_cross_engine_claim_can_retain_hold)
  expect_true(review$inference_ready_claim_requires_hold_resolution)
  expect_false(review$design_rank_hold_resolved)
  expect_false(review$mfrmr_inference_ready)
  expect_false(review$existing_fit_readiness_rewritten)
  expect_false(review$new_fit_attempted)
  expect_false(review$independent_comprehensive_review_passed)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$public_claim_authorized)
})

test_that("the observation cannot load fits, recompute ranks, or launch", {
  ctx <- load_conquest_p2_candidate_004_rank_hold_observation()
  source <- paste(readLines(tail(ctx$paths, 1L), warn = FALSE), collapse = "\n")

  expect_false(grepl("readRDS\\s*\\(|rankMatrix\\s*\\(|svd\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap expose the claim-dependent fork", {
  ctx <- load_conquest_p2_candidate_004_rank_hold_observation()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-p2-candidate-004-rank-hold-observation-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4rho_specification, fixed = TRUE)
  expect_match(record, "`DesignRankHoldResolved=FALSE`", fixed = TRUE)
  expect_match(record, "claim-dependent fork", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Disaggregate candidate 004's internal design-rank hold",
    fixed = TRUE
  )
})
