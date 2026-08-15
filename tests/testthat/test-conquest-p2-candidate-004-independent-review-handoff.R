load_conquest_p2_candidate_004_independent_review_handoff <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation,
    "conquest-p2-candidate-004-independent-review-handoff-0.2.3.R"
  )
  skip_if_not(file.exists(script), "Candidate-004 review handoff is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

candidate_004_independent_attestation <- function(env) {
  out <- env$mfrmr_cq_p2c4irh_attestation_template()
  out$reviewer_id <- "independent-reviewer-example"
  out$review_date <- "2026-08-16"
  out$conflicts_disclosed <- TRUE
  out$authored_candidate_004_pre_review_evidence <- FALSE
  out$participated_in_candidate_004_execution <- FALSE
  out$authored_same_author_numeric_review <- FALSE
  out$authored_this_handoff <- FALSE
  out$used_raw_artifacts_as_primary_evidence <- TRUE
  out$used_same_author_observation_as_calculation_source <- FALSE
  out$independent_implementation_description <-
    "Separate parser and direct probability reconstruction"
  out
}

test_that("handoff selects one bounded claim without opening review", {
  env <- load_conquest_p2_candidate_004_independent_review_handoff()$env
  plan <- env$mfrmr_cq_p2c4irh_plan()

  expect_identical(
    plan$status, "candidate_004_bounded_review_handoff_frozen_unreviewed"
  )
  expect_match(plan$selected_claim, "RSM/PCM q61/q121", fixed = TRUE)
  expect_false(plan$independent_bounded_review_passed)
  expect_false(plan$bounded_internal_evidence_promotion_eligible)
  expect_false(plan$candidate_rerun_authorized)
  expect_false(plan$public_claim_authorized)
  expect_false(plan$scientific_equivalence_inferred)
})

test_that("raw roots are primary and same-author records cannot be oracles", {
  env <- load_conquest_p2_candidate_004_independent_review_handoff()$env
  evidence <- env$mfrmr_cq_p2c4irh_evidence_registry()

  expect_identical(nrow(evidence), 8L)
  expect_identical(sum(evidence$StorageClass == "ignored_local_raw_artifacts"), 2L)
  expect_identical(sum(evidence$MaySupplyObservedNumericResult), 2L)
  expect_true(all(evidence$Required))
  expect_false(evidence$MaySupplyObservedNumericResult[
    evidence$EvidenceId == "same_author_numeric_observation"
  ])
  expect_false(any(grepl("^/", evidence$RelativePath)))
})

test_that("all review denominators and stop rules are closed", {
  env <- load_conquest_p2_candidate_004_independent_review_handoff()$env
  tasks <- env$mfrmr_cq_p2c4irh_task_registry()

  expect_identical(nrow(tasks), 15L)
  expect_identical(anyDuplicated(tasks$TaskId), 0L)
  expect_identical(
    tasks$ExpectedAtomicCount,
    c(1L, 2L, 288L, 4L, 4L, 36L, 52L, 64L, 4L, 68L,
      480L, 18L, 192L, 4L, 7L)
  )
  expect_true(all(tasks$RequiredForBoundedPass))
  expect_false(any(tasks$RerunConQuestAllowed))
  expect_false(any(tasks$DropFailedRowsAllowed))
  expect_true(sum(tasks$IndependentReconstructionRequired) >= 10L)
})

test_that("nonclaims cannot be promoted through bounded review", {
  env <- load_conquest_p2_candidate_004_independent_review_handoff()$env
  nonclaims <- env$mfrmr_cq_p2c4irh_nonclaim_registry()

  expect_identical(nrow(nonclaims), 10L)
  expect_false(any(nonclaims$Authorized))
  expect_true(all(c(
    "mfrmr_inference_readiness", "global_marginal_identification",
    "GPCM_or_DFF_coverage", "general_software_interchangeability",
    "public_release_claim"
  ) %in% nonclaims$NonclaimId))
})

test_that("reviewer overlap and incomplete work fail closed", {
  env <- load_conquest_p2_candidate_004_independent_review_handoff()$env
  attestation <- candidate_004_independent_attestation(env)
  results <- env$mfrmr_cq_p2c4irh_result_template()

  incomplete <- env$mfrmr_cq_p2c4irh_adjudicate(attestation, results)
  expect_identical(incomplete$disposition, "bounded_review_incomplete")
  expect_false(incomplete$bounded_internal_evidence_promotion_eligible)

  results$State <- "pass"
  attestation$authored_same_author_numeric_review <- TRUE
  overlap <- env$mfrmr_cq_p2c4irh_adjudicate(attestation, results)
  expect_identical(overlap$disposition, "independence_not_met")
  expect_false(overlap$independent_bounded_review_passed)
})

test_that("even a bounded pass cannot widen its claim", {
  env <- load_conquest_p2_candidate_004_independent_review_handoff()$env
  attestation <- candidate_004_independent_attestation(env)
  results <- env$mfrmr_cq_p2c4irh_result_template()
  results$State <- "pass"
  decision <- env$mfrmr_cq_p2c4irh_adjudicate(attestation, results)

  expect_identical(decision$disposition, "bounded_review_passed")
  expect_true(decision$independent_bounded_review_passed)
  expect_true(decision$bounded_internal_evidence_promotion_eligible)
  expect_false(decision$candidate_rerun_authorized)
  expect_false(decision$wider_execution_authorized)
  expect_false(decision$P3_execution_authorized)
  expect_false(decision$mfrmr_inference_ready)
  expect_false(decision$public_claim_authorized)
  expect_false(decision$hidden_solution_equality_inferred)
  expect_false(decision$scientific_equivalence_inferred)
})

test_that("the handoff cannot inspect artifacts, fit, or launch", {
  ctx <- load_conquest_p2_candidate_004_independent_review_handoff()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")

  expect_false(grepl("read[.]csv\\s*\\(|readLines\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap retain the unreviewed claim-dependent gate", {
  ctx <- load_conquest_p2_candidate_004_independent_review_handoff()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-p2-candidate-004-independent-review-handoff-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4irh_specification, fixed = TRUE)
  expect_match(record, "- [ ] Record reviewer identity", fixed = TRUE)
  expect_match(record, "`IndependentBoundedReviewPassed=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Choose the next gate by claim, not by ritual",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Complete the independent post-output evidence review",
    fixed = TRUE
  )
})
