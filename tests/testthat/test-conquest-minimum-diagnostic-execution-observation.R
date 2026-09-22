load_conquest_minimum_diagnostic_execution_observation <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-minimum-diagnostic-authorization-0.2.3.R",
    "conquest-minimum-diagnostic-live-authorization-0.2.3.R",
    "conquest-minimum-diagnostic-harness-0.2.3.R",
    "conquest-minimum-diagnostic-execution-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only diagnostic execution-observation files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("the observed fixture lacks the prespecified population signal", {
  ctx <- load_conquest_minimum_diagnostic_execution_observation()
  signal <- ctx$env$mfrmr_cq_mdo_fixture_signal()

  expect_identical(signal$Persons, 48L)
  expect_identical(signal$ObservedRows, 288L)
  expect_identical(signal$ResponsesPerPerson, 6)
  expect_identical(signal$PersonScoreMinimum, 8L)
  expect_identical(signal$PersonScoreMaximum, 10L)
  expect_identical(signal$PersonScore8Count, 24L)
  expect_identical(signal$PersonScore10Count, 24L)
  expect_identical(signal$MeanScoreXNegative, 9)
  expect_identical(signal$MeanScoreXPositive, 9)
  expect_identical(signal$PersonScoreXCorrelation, 0)
  expect_identical(signal$CovariateMeanScoreSeparation, 0)
  expect_identical(signal$RaterCategoryMinimumCount, 18L)
  expect_identical(signal$RaterCategoryMaximumCount, 18L)
  expect_identical(signal$CriterionCategoryMinimumCount, 24L)
  expect_identical(signal$CriterionCategoryMaximumCount, 24L)
  expect_true(signal$ExactFacetCategoryBalance)
  expect_false(signal$NondegeneratePopulationSignalGatePassed)
  expect_false(signal$ScientificEquivalenceInferred)
})

test_that("the run-once attempt and semantic stop are retained exactly", {
  ctx <- load_conquest_minimum_diagnostic_execution_observation()
  engine <- ctx$env$mfrmr_cq_mdo_engine_observation()
  failure <- ctx$env$mfrmr_cq_mdo_conquest_failure_observation()

  expect_identical(engine$Engine, c("mfrmr", "ConQuest"))
  expect_identical(engine$AuthorizedFitCap, c(4L, 4L))
  expect_identical(engine$AttemptedFits, c(4L, 1L))
  expect_identical(engine$StructurallyCompleteFits, c(4L, 0L))
  expect_identical(engine$RemainingUnattemptedFits, c(0L, 3L))
  expect_identical(engine$FirstArmExitStatus[2L], 0L)
  expect_true(engine$FirstArmTerminalMarker[2L])
  expect_identical(engine$FirstArmRegisteredFailureCount[2L], 4L)
  expect_identical(engine$FirstArmCompleteNativeOutputCount[2L], 2L)
  expect_identical(
    failure$FailureCode,
    c(
      "model_not_estimated", "compute_command_error",
      "print_command_error", "equation_symbol_error"
    )
  )
  expect_true(all(failure$Observed))
  expect_true(all(failure$CascadeRole == "post_estimation_abort"))
  expect_true(all(failure$RootSignal ==
    "variance_estimate_became_negative_before_model_estimation_completed"))
  expect_false(any(failure$EvidencePromotionAuthorized))
  expect_false(any(failure$ScientificEquivalenceInferred))
})

test_that("the failed candidate cannot rerun or skip to independent review", {
  ctx <- load_conquest_minimum_diagnostic_execution_observation()
  review <- ctx$env$mfrmr_cq_mdo_review()

  expect_identical(
    review$status,
    "diagnostic_halted_fixture_signal_defect_no_rerun_authorized"
  )
  expect_true(review$fixture_population_signal_defect_observed)
  expect_true(review$execution_failure_retained)
  expect_true(review$candidate_run_once_consumed)
  expect_false(review$exact_two_row_slice_completed)
  expect_false(review$current_candidate_rerun_authorized)
  expect_false(review$replacement_candidate_execution_authorized)
  expect_true(review$fixture_supersession_required)
  expect_false(review$independent_review_is_next_execution_blocker)
  expect_true(review$independent_review_still_blocks_evidence_promotion)
  expect_false(review$independent_comprehensive_review_passed)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$wider_execution_authorized)
  expect_false(review$P3_execution_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the execution observation cannot launch or read ignored output", {
  ctx <- load_conquest_minimum_diagnostic_execution_observation()
  source <- paste(readLines(ctx$paths[9L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("validation-results", source, fixed = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5", source, ignore.case = TRUE))
})

test_that("the internal record prioritizes fixture supersession over review", {
  ctx <- load_conquest_minimum_diagnostic_execution_observation()
  record_path <- file.path(
    ctx$validation,
    "conquest-minimum-diagnostic-execution-observation-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_mdo_specification, fixed = TRUE)
  expect_match(record, ctx$env$mfrmr_cq_mdo_contract, fixed = TRUE)
  expect_match(
    record,
    "`CurrentCandidateRerunAuthorized` | `FALSE`",
    fixed = TRUE
  )
  expect_match(
    record,
    "`IndependentReviewIsNextExecutionBlocker` | `FALSE`",
    fixed = TRUE
  )
  expect_match(
    record,
    "`IndependentReviewStillBlocksEvidencePromotion` | `TRUE`",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Launch exactly the authorized two-row P2 diagnostic candidate",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Supersede the deterministic response generator",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Run a separate mfrmr-only candidate-003 preflight",
    fixed = TRUE
  )
})
