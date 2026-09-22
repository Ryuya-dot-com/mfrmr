load_conquest_p2_candidate_004_execution_observation <- function() {
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
    "conquest-p2-candidate-004-execution-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 observation is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("all four authorized ConQuest arms are retained as complete", {
  ctx <- load_conquest_p2_candidate_004_execution_observation()
  review <- ctx$env$mfrmr_cq_p2c4eo_review()
  observed <- review$execution_observation

  expect_identical(nrow(observed), 4L)
  expect_identical(observed$RunId, c(
    "rsm_q061", "rsm_q121", "pcm_q061", "pcm_q121"
  ))
  expect_identical(observed$ExpectedFreeDimension, c(10L, 10L, 14L, 14L))
  expect_true(all(observed$ConQuestAttemptCount == 1L))
  expect_true(all(observed$ConQuestExitStatus == 0L))
  expect_true(all(observed$ConQuestTerminalMarkerObserved))
  expect_true(all(observed$ConQuestRegisteredFailureCount == 0L))
  expect_true(all(observed$ConQuestNativeOutputCount == 8L))
  expect_true(review$exact_four_arm_identity)
  expect_true(review$all_four_semantically_complete)
  expect_identical(review$complete_native_output_count, 32L)
})

test_that("execution completion consumes the candidate without promotion", {
  ctx <- load_conquest_p2_candidate_004_execution_observation()
  review <- ctx$env$mfrmr_cq_p2c4eo_review()

  expect_identical(
    review$status,
    "candidate_004_four_arm_execution_complete_numerical_review_pending"
  )
  expect_true(review$candidate_run_once_consumed)
  expect_true(review$same_author_technical_review_authorized)
  expect_false(review$rerun_authorized)
  expect_false(review$independent_comprehensive_review_passed)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$wider_execution_authorized)
  expect_false(review$P3_execution_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the execution observation cannot read output or launch a process", {
  ctx <- load_conquest_p2_candidate_004_execution_observation()
  source <- paste(readLines(tail(ctx$paths, 1L), warn = FALSE), collapse = "\n")

  expect_false(grepl("read[.]csv\\s*\\(|readLines\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap retain the completed four-arm denominator", {
  ctx <- load_conquest_p2_candidate_004_execution_observation()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-p2-candidate-004-execution-observation-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4eo_specification, fixed = TRUE)
  expect_match(record, "`CompleteNativeOutputCount=32`", fixed = TRUE)
  expect_match(record, "`RerunAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Bind and execute fit-eligible candidate 004",
    fixed = TRUE
  )
})
