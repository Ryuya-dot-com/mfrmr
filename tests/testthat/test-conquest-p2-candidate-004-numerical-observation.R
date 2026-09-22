load_conquest_p2_candidate_004_numerical_observation <- function() {
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
    "conquest-p2-candidate-004-numerical-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 observation is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(
    root = root, validation = validation, paths = paths, env = env,
    observation = tail(paths, 1L)
  )
}

test_that("the entire candidate-004 numerical-core denominator passes", {
  env <- load_conquest_p2_candidate_004_numerical_observation()$env
  review <- env$mfrmr_cq_p2c4no_review()
  denominator <- review$denominator

  expect_identical(nrow(denominator), 12L)
  expect_true(all(denominator$Complete))
  expect_true(all(denominator$Passed))
  expect_identical(
    denominator$ObservedAtomicCount, denominator$ExpectedAtomicCount
  )
  expect_identical(
    denominator$PassedAtomicCount, denominator$ExpectedAtomicCount
  )
  expect_true(review$budget_identity)
  expect_true(review$same_author_numeric_core_passed)
})

test_that("cross-engine and q maxima remain inside frozen budgets", {
  env <- load_conquest_p2_candidate_004_numerical_observation()$env
  review <- env$mfrmr_cq_p2c4no_review()

  expect_true(all(review$cross_engine_coordinate$Pass))
  expect_true(all(
    review$cross_engine_coordinate$MaximumAbsoluteDifference <= 1e-5
  ))
  expect_true(all(review$cross_engine_deviance$Pass))
  expect_true(all(
    review$cross_engine_deviance$AbsoluteDifference <= 2e-6
  ))
  expect_true(all(review$q61_q121$Pass))
  expect_true(all(review$q61_q121$MaximumCoordinateMovement <= 2e-6))
  expect_true(all(review$q61_q121$AbsoluteDevianceMovement <= 2e-6))
  expect_identical(review$exact_reported_q_pairs_identical, 26L)
  expect_false(any(review$q61_q121$HiddenSolutionEqualityInferred))
})

test_that("probabilities and orderings retain complete counts", {
  env <- load_conquest_p2_candidate_004_numerical_observation()$env
  review <- env$mfrmr_cq_p2c4no_review()

  expect_identical(review$probability$ObservedCells, c(240L, 240L))
  expect_identical(review$probability$PassedCells, c(240L, 240L))
  expect_true(all(review$probability$Pass))
  expect_true(all(
    review$probability$MaximumAbsoluteDifference <=
      review$probability$AbsoluteTolerance
  ))
  expect_identical(review$ordering_classifications_passed, 18L)
  expect_identical(review$ordering_classifications_expected, 18L)
})

test_that("technical agreement cannot clear readiness or promotion holds", {
  env <- load_conquest_p2_candidate_004_numerical_observation()$env
  review <- env$mfrmr_cq_p2c4no_review()

  expect_identical(
    review$status,
    "candidate_004_same_author_numeric_core_passed_independent_promotion_review_pending"
  )
  expect_false(review$person_EAP_numeric_comparison_authorized)
  expect_false(review$person_posterior_SD_numeric_comparison_authorized)
  expect_false(review$independent_comprehensive_review_passed)
  expect_false(review$mfrmr_inference_ready)
  expect_identical(review$mfrmr_readiness_reason, "design_rank_not_evaluated")
  expect_false(review$complete_P2_design_portfolio_reviewed)
  expect_false(review$rerun_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$wider_execution_authorized)
  expect_false(review$P3_execution_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$hidden_solution_equality_inferred)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("observation cannot read artifacts, compute metrics, or launch", {
  ctx <- load_conquest_p2_candidate_004_numerical_observation()
  source <- paste(readLines(ctx$observation, warn = FALSE), collapse = "\n")

  expect_false(grepl("read[.]csv\\s*\\(|readLines\\s*\\(", source, perl = TRUE))
  expect_false(grepl("p2c4nr_review\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap retain the bounded same-author result", {
  ctx <- load_conquest_p2_candidate_004_numerical_observation()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-p2-candidate-004-numerical-observation-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4no_specification, fixed = TRUE)
  expect_match(record, "`SameAuthorNumericCorePassed=TRUE`", fixed = TRUE)
  expect_match(record, "`MfrmrInferenceReady=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Apply the already-frozen exact-reported-decimal",
    fixed = TRUE
  )
})
