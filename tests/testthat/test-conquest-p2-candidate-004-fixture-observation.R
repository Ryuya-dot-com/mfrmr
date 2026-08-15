load_conquest_p2_candidate_004_fixture_observation <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-p2-replacement-nondegenerate-fixture-0.2.3.R",
    "conquest-p2-candidate-003-coverage-conditioned-fixture-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-adaptive-density-contract-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-observation-0.2.3.R",
    "conquest-p2-candidate-004-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-004-fixture-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "P2 candidate-004 observation excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("candidate 004 retains all thirteen generation-gate passes", {
  ctx <- load_conquest_p2_candidate_004_fixture_observation()
  review <- ctx$env$mfrmr_cq_p2c4o_review()
  gates <- review$gate_results

  expect_identical(nrow(gates), 13L)
  expect_true(all(gates$Passed))
  expect_true(review$frozen_candidate_002_gate_identity_retained)
  expect_true(review$all_thirteen_prefit_gates_passed)
  expect_true(review$coverage_conditioning_ready)
  expect_true(review$disjoint_candidate_003_identity_seed_and_data)
  expect_identical(
    review$status,
    "candidate_004_prefit_fixture_ready_mfrmr_preflight_contract_required"
  )
})

test_that("conditioning observations retain the complete denominator", {
  ctx <- load_conquest_p2_candidate_004_fixture_observation()
  conditioning <- ctx$env$mfrmr_cq_p2c4o_review()$conditioning

  expect_identical(nrow(conditioning), 12L)
  expect_identical(conditioning$Persons, rep(24L, 12L))
  expect_true(all(conditioning$CoverageSatisfied))
  expect_identical(conditioning$DrawAttempts, rep(1L, 12L))
  expect_identical(conditioning$RejectedCompleteBlocks, rep(0L, 12L))
  expect_identical(
    rowSums(conditioning[, paste0("Category", 0:3)]), rep(24, 12L)
  )
  expect_identical(sum(conditioning[, paste0("Category", 0:3)]), 288L)
})

test_that("fixture pass authorizes only the next preflight contract", {
  ctx <- load_conquest_p2_candidate_004_fixture_observation()
  review <- ctx$env$mfrmr_cq_p2c4o_review()

  expect_false(review$seed_search_performed)
  expect_false(review$response_repair_performed)
  expect_true(review$mfrmr_fit_preflight_contract_authorized)
  expect_false(review$mfrmr_fit_authorized)
  expect_false(review$truth_recovery_authorized)
  expect_false(review$candidate_003_reclassified)
  expect_false(review$external_execution_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the observation cannot generate, fit, read, launch, or hash", {
  ctx <- load_conquest_p2_candidate_004_fixture_observation()
  source <- paste(readLines(ctx$paths[12L], warn = FALSE), collapse = "\n")

  expect_false(grepl("p2c4_fixture\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap keep later work blocked", {
  ctx <- load_conquest_p2_candidate_004_fixture_observation()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-candidate-004-fixture-observation-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4o_specification, fixed = TRUE)
  expect_match(record, "`AllThirteenPrefitGatesPassed=TRUE`", fixed = TRUE)
  expect_match(record, "`MfrmrFitAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Generate one disjoint candidate-004 fixture",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Freeze and run a candidate-004 mfrmr-only preflight",
    fixed = TRUE
  )
})
