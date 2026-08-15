load_conquest_p2_successor_integration_observation <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-successor-integration-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "P2 successor observation is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("all thirteen outcomes and the two failures are retained", {
  ctx <- load_conquest_p2_successor_integration_observation()
  review <- ctx$env$mfrmr_cq_p2sio_review()
  audit <- review$audit

  expect_identical(nrow(audit), 13L)
  expect_true(all(audit$Finite))
  expect_identical(sum(audit$Q61Q121Passed), 11L)
  expect_identical(sum(audit$Q121ContinuousPassed), 11L)
  expect_identical(sum(audit$Passed), 11L)
  expect_identical(
    review$failed_registry_rows,
    c("P2-RSM-UNEQUAL-WORKLOAD", "P2-PCM-UNEQUAL-WORKLOAD")
  )
  expect_identical(
    review$status,
    "fixed_q121_successor_rejected_unequal_workload_integration_unresolved"
  )
})

test_that("passing target rows do not narrow the failed envelope", {
  ctx <- load_conquest_p2_successor_integration_observation()
  review <- ctx$env$mfrmr_cq_p2sio_review()
  target <- review$audit[grepl(
    "CONNECTED-MULTIBRIDGE", review$audit$RegistryRowId, fixed = TRUE
  ), , drop = FALSE]

  expect_true(all(target$Passed))
  expect_true(review$fixed_q121_contract_consumed)
  expect_false(review$fixed_q121_contract_passed)
  expect_false(review$candidate_003_reclassified)
  expect_false(review$candidate_004_generation_authorized)
  expect_false(review$fixed_threshold_change_authorized)
  expect_true(review$design_adaptive_density_contract_required)
  expect_false(review$external_execution_authorized)
})

test_that("the observation cannot rerun an oracle, fit, read, or launch", {
  ctx <- load_conquest_p2_successor_integration_observation()
  source <- paste(readLines(ctx$paths[6L], warn = FALSE), collapse = "\n")

  expect_false(grepl("truth_oracle_audit\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap require adaptive density before candidate 004", {
  ctx <- load_conquest_p2_successor_integration_observation()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-successor-integration-observation-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2sio_specification, fixed = TRUE)
  expect_match(record, "refutes one fixed density ceiling", fixed = TRUE)
  expect_match(record, "`FixedThresholdChangeAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze and test a bounded design-adaptive density ladder",
    fixed = TRUE
  )
})
