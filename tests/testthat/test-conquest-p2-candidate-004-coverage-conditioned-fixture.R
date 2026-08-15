load_conquest_p2_candidate_004_fixture <- function() {
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
    "conquest-p2-candidate-004-coverage-conditioned-fixture-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "P2 candidate-004 contract is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("candidate 004 identity and generation rules are frozen prospectively", {
  ctx <- load_conquest_p2_candidate_004_fixture()
  review <- ctx$env$mfrmr_cq_p2c4_review()
  contract <- review$generation_contract

  expect_identical(contract$Seed, 2026081504L)
  expect_identical(contract$MaximumCellDraws, 10000L)
  expect_identical(
    contract$CandidateId,
    "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004"
  )
  expect_identical(contract$GateDenominator, 13L)
  expect_identical(contract$GateRegistrySource, "candidate_002_unchanged")
  expect_true(contract$DisjointLineageGateSeparate)
  expect_false(contract$SeedSearchPermitted)
  expect_false(contract$PostGenerationResponseRepairPermitted)
  expect_false(contract$Candidate003OutputTuned)
  expect_false(contract$FitPermitted)
  expect_true(review$contract_ready)
  expect_true(review$oracle_qualification_retained)
  expect_true(review$disjoint_identity_and_seed_frozen)
  expect_true(review$frozen_candidate_002_gate_identity_retained)
})

test_that("the frozen contract leaves generation unopened and fitting blocked", {
  ctx <- load_conquest_p2_candidate_004_fixture()
  review <- ctx$env$mfrmr_cq_p2c4_review()

  expect_identical(
    review$status,
    "candidate_004_generation_contract_frozen_audit_unopened"
  )
  expect_false(review$generation_audit_run)
  expect_null(review$fixture)
  expect_identical(nrow(review$signal_audit), 0L)
  expect_identical(nrow(review$gate_results), 0L)
  expect_false(review$mfrmr_fit_preflight_contract_authorized)
  expect_false(review$mfrmr_fit_authorized)
  expect_false(review$truth_recovery_authorized)
  expect_false(review$candidate_003_reclassified)
  expect_false(review$external_execution_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("candidate 004 generation contract fits and launches nothing", {
  ctx <- load_conquest_p2_candidate_004_fixture()
  source <- paste(readLines(ctx$paths[11L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("the frozen record stays unopened while the roadmap records outcome", {
  ctx <- load_conquest_p2_candidate_004_fixture()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-candidate-004-coverage-conditioned-fixture-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4_specification, fixed = TRUE)
  expect_match(record, "`GenerationAuditOpened=FALSE`", fixed = TRUE)
  expect_match(record, "separate lineage gate", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Generate one disjoint candidate-004 fixture",
    fixed = TRUE
  )
})
