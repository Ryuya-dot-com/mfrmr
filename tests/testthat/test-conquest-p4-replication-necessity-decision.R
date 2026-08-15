load_conquest_p4_replication_necessity_decision <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "conquest-p4-replication-necessity-decision-0.2.3.R"
  )
  skip_if_not(file.exists(script), "ConQuest P4 necessity decision is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

test_that("only the fixed-artifact bounded claim is selected", {
  env <- load_conquest_p4_replication_necessity_decision()$env
  claims <- env$mfrmr_cq_p4rnd_claim_registry()
  selected <- claims[claims$CurrentClaimSelected, , drop = FALSE]

  expect_identical(nrow(claims), 8L)
  expect_identical(anyDuplicated(claims$ClaimId), 0L)
  expect_identical(nrow(selected), 1L)
  expect_identical(
    selected$ClaimId, "candidate_004_fixed_artifact_bounded_comparison"
  )
  expect_identical(selected$Disposition, "replication_not_needed")
  expect_true(selected$DeterministicGateComplete)
})

test_that("broader claims cannot inherit the fixed-candidate decision", {
  env <- load_conquest_p4_replication_necessity_decision()$env
  claims <- env$mfrmr_cq_p4rnd_claim_registry()

  expect_identical(
    as.integer(table(factor(
      claims$Disposition,
      levels = c(
        "replication_not_needed",
        "replication_not_needed_for_historical_retention",
        "deterministic_gate_first", "claim_not_selected"
      )
    ))),
    c(1L, 1L, 2L, 4L)
  )
  expect_false(any(claims$ReplicationAuthorized))
  expect_false(any(claims$IndependentReviewSubstitutedByReplication))
  expect_false(any(claims$PublicPromotionAuthorized))
})

test_that("replication design fields stay typed not applicable", {
  env <- load_conquest_p4_replication_necessity_decision()$env
  design <- env$mfrmr_cq_p4rnd_conditional_design_state()

  expect_identical(nrow(design), 7L)
  expect_true(all(
    design$State ==
      "not_applicable_replication_not_needed_for_selected_claim"
  ))
  expect_true(all(is.na(design$Value)))
  expect_true(all(design$ProspectiveFreezeRequiredIfFutureClaimSelected))
})

test_that("P4 closes narrowly without replacing independent review", {
  env <- load_conquest_p4_replication_necessity_decision()$env
  review <- env$mfrmr_cq_p4rnd_review()

  expect_identical(
    review$status,
    "P4_closed_replication_not_needed_for_selected_bounded_claim"
  )
  expect_false(review$selected_claim_replication_needed)
  expect_true(review$independent_review_still_required)
  expect_false(review$independent_review_is_sampling_replication)
  expect_false(review$new_data_generated)
  expect_false(review$new_fit_attempted)
  expect_false(review$ConQuest_execution_attempted)
  expect_false(review$large_simulation_authorized)
  expect_false(review$candidate_004_rerun_authorized)
  expect_false(review$wider_P2_authorized)
  expect_false(review$P3_authorized)
  expect_false(review$release_spine_update_authorized)
  expect_false(review$public_text_change_authorized)
})

test_that("the decision cannot fit, generate data, or launch", {
  ctx <- load_conquest_p4_replication_necessity_decision()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")

  expect_false(grepl("simulate_|rnorm\\s*\\(|runif\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap close only the selected P4 path", {
  ctx <- load_conquest_p4_replication_necessity_decision()
  record <- paste(readLines(file.path(
    ctx$validation, "conquest-p4-replication-necessity-decision-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p4rnd_specification, fixed = TRUE)
  expect_match(record, "`SelectedClaimReplicationNeeded=FALSE`", fixed = TRUE)
  expect_match(record, "`IndependentReviewStillRequired=TRUE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Decide from P2/P3 deterministic evidence",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Close P4 for the selected bounded claim",
    fixed = TRUE
  )
})
