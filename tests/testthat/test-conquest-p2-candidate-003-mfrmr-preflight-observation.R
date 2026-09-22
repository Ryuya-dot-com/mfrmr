load_conquest_p2_candidate_003_mfrmr_observation <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-replacement-nondegenerate-fixture-0.2.3.R",
    "conquest-p2-candidate-003-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-003-mfrmr-preflight-0.2.3.R",
    "conquest-p2-candidate-003-mfrmr-preflight-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-003 observation is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("all four interior fits and readiness holds are retained", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_observation()
  review <- ctx$env$mfrmr_cq_p2c3o_review()
  fit <- review$fit_observation

  expect_identical(nrow(fit), 4L)
  expect_identical(fit$ObservedNpar, c(10L, 10L, 14L, 14L))
  expect_identical(fit$ObservedNpar, fit$ExpectedNpar)
  expect_true(all(fit$PopulationVariance > 0.63))
  expect_true(all(fit$PopulationVariance < 0.64))
  expect_true(all(fit$StructuralNumericalPass))
  expect_false(any(fit$InferenceReady))
  expect_true(all(fit$OnlyDesignRankNotEvaluatedHold))
  expect_identical(unique(fit$ReadinessReasonCodes),
                   "design_rank_not_evaluated")
  expect_true(review$all_four_structural_numerical_fit_gates_passed)
  expect_false(review$all_four_inference_ready)
  expect_true(review$design_rank_holds_retained)
})

test_that("both complete q comparisons retain their prospective failures", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_observation()
  review <- ctx$env$mfrmr_cq_p2c3o_review()
  q <- review$q_observation

  expect_identical(q$ExpectedCoordinateCount, c(13L, 19L))
  expect_identical(q$CoordinateCount, q$ExpectedCoordinateCount)
  expect_true(all(q$CompleteCoordinateDenominator))
  expect_true(all(q$MaximumAbsoluteQ31Q61CoordinateMovement > 2e-6))
  expect_true(all(q$AbsoluteQ31Q61DevianceMovement > 2e-6))
  expect_false(any(q$Passed))
  expect_identical(q$FailureOutcome, rep("integration_unresolved", 2L))
  expect_true(review$both_q31_q61_pairs_failed)
  expect_identical(
    review$status,
    "candidate_003_mfrmr_preflight_consumed_integration_unresolved"
  )
})

test_that("failure consumes candidate 003 without opening a rescue path", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_observation()
  review <- ctx$env$mfrmr_cq_p2c3o_review()

  expect_true(review$candidate_mfrmr_preflight_consumed)
  expect_false(review$candidate_mfrmr_preflight_rerun_authorized)
  expect_false(review$candidate_external_execution_authorized)
  expect_false(review$eligible_for_new_external_authorization_review)
  expect_true(review$successor_integration_contract_required_before_new_candidate)
  expect_false(review$threshold_change_authorized)
  expect_false(review$seed_search_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$truth_recovery_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the repository observation cannot read results, fit, or launch", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_observation()
  source <- paste(readLines(ctx$paths[8L], warn = FALSE), collapse = "\n")

  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("internal records retain failure and successor ordering", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_observation()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-candidate-003-mfrmr-preflight-observation-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c3o_specification, fixed = TRUE)
  expect_match(record, "but both prospectively", fixed = TRUE)
  expect_match(record, "frozen q31--q61 movement gates failed", fixed = TRUE)
  expect_match(record, "`ThresholdChangeAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Run a separate mfrmr-only candidate-003 preflight",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze and test a first successor integration ladder before generating",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze and test a bounded design-adaptive density ladder",
    fixed = TRUE
  )
})
