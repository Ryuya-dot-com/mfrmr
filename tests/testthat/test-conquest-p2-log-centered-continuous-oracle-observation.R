load_conquest_p2_log_centered_continuous_oracle_observation <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-adaptive-density-contract-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "P2 oracle observation is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("all thirteen frozen log-centered qualification rows pass", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle_observation()
  review <- ctx$env$mfrmr_cq_p2coo_review()
  audit <- review$audit

  expect_identical(nrow(audit), 13L)
  expect_true(all(audit$Finite))
  expect_true(all(audit$ModesInterior))
  expect_true(all(audit$LocalMaximumChecksPassed))
  expect_true(all(audit$IntegrationsConverged))
  expect_true(all(audit$Q121LogCenteredPassed))
  expect_true(all(audit$Q241LogCenteredPassed))
  expect_true(all(audit$DeclaredErrorBoundPassed))
  expect_lt(max(audit$Q121LogCenteredDevianceMovement), 1.1e-10)
  expect_lt(max(audit$Q241LogCenteredDevianceMovement), 2.3e-12)
  expect_lt(max(audit$DeclaredDevianceErrorBound), 2.3e-11)
  expect_true(review$log_centered_continuous_oracle_qualified)
  expect_identical(
    review$status,
    "log_centered_continuous_oracle_qualified_for_future_p2_candidates"
  )
})

test_that("legacy discrepancy is retained without overstating its cause", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle_observation()
  review <- ctx$env$mfrmr_cq_p2coo_review()
  failed <- review$audit$RegistryRowId[
    !review$audit$LegacyLogCenteredPassed
  ]

  expect_identical(
    failed,
    c("P2-RSM-UNEQUAL-WORKLOAD", "P2-PCM-UNEQUAL-WORKLOAD")
  )
  expect_true(review$legacy_reference_limitation_supported)
  expect_false(review$legacy_failure_mechanism_proven)
  expect_false(review$interval_certified_error_bound)
  expect_false(review$independent_software_validation_completed)
})

test_that("qualification authorizes generation but no fit or execution", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle_observation()
  review <- ctx$env$mfrmr_cq_p2coo_review()

  expect_true(review$legacy_continuous_oracle_replaced_for_future_candidates)
  expect_true(review$candidate_004_generation_authorized)
  expect_false(review$candidate_004_fit_authorized)
  expect_false(review$candidate_003_reclassified)
  expect_false(review$consumed_predecessor_reclassified)
  expect_false(review$external_execution_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the observation cannot evaluate, fit, read, launch, or hash", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle_observation()
  source <- paste(readLines(ctx$paths[8L], warn = FALSE), collapse = "\n")

  expect_false(grepl(
    "log_centered_loglikelihood\\s*\\(|fixed_loglikelihood\\s*\\(",
    source, perl = TRUE
  ))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap retain the bounded authorization", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle_observation()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-log-centered-continuous-oracle-observation-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2coo_specification, fixed = TRUE)
  expect_match(record, "`Candidate004GenerationAuthorized=TRUE`", fixed = TRUE)
  expect_match(record, "`Candidate004FitAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "not an interval-arithmetic", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Qualify a log-centered continuous P2 oracle",
    fixed = TRUE
  )
})
