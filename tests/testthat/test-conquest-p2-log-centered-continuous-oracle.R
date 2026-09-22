load_conquest_p2_log_centered_continuous_oracle <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-adaptive-density-contract-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "P2 log-centered oracle is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("qualification budgets and numerical controls are prospective", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle()
  review <- ctx$env$mfrmr_cq_p2co_review()
  budget <- review$budgets
  numerical <- review$numerical_contract

  expect_identical(
    review$status,
    "log_centered_continuous_oracle_contract_frozen_audit_unopened"
  )
  expect_identical(budget$AbsoluteTolerance, c(1e-7, 1e-7, 1e-8))
  expect_true(all(budget$Frozen))
  expect_false(any(budget$Candidate003OutputInformed))
  expect_false(any(budget$LegacyContinuousOutputTuned))
  expect_false(any(budget$CanReclassifyConsumedContract))
  expect_identical(numerical$TailLower, -12)
  expect_identical(numerical$TailUpper, 12)
  expect_identical(numerical$RelativeTolerance, 1e-12)
  expect_identical(numerical$AbsoluteTolerance, 1e-14)
  expect_identical(numerical$Subdivisions, 1000L)
  expect_true(review$contract_ready)
  expect_false(review$oracle_audit_run)
  expect_false(review$oracle_qualified)
  expect_false(review$candidate_004_generation_authorized)
})

test_that("qualification requires the complete denominator and every gate", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle()
  qualify <- ctx$env$mfrmr_cq_p2co_qualify
  ids <- c("A", "B")
  audit <- data.frame(
    RegistryRowId = ids,
    Q121LogCenteredDevianceMovement = c(1e-8, 2e-8),
    Q241LogCenteredDevianceMovement = c(1e-8, 2e-8),
    DeclaredDevianceErrorBound = c(1e-9, 2e-9),
    ModesInterior = TRUE, LocalMaximumChecksPassed = TRUE,
    IntegrationsConverged = TRUE, Finite = TRUE,
    stringsAsFactors = FALSE
  )
  passed <- qualify(audit, ids)
  expect_true(passed$complete_denominator)
  expect_true(passed$passed)
  expect_false(passed$candidate_003_reclassified)
  expect_false(passed$consumed_predecessor_reclassified)
  expect_false(passed$external_execution_authorized)

  missing <- qualify(audit[1L, ], ids)
  expect_false(missing$complete_denominator)
  expect_false(missing$passed)
  changed <- audit
  changed$DeclaredDevianceErrorBound[2L] <- 2e-8
  expect_false(qualify(changed, ids)$passed)
  changed <- audit
  changed$ModesInterior[2L] <- FALSE
  expect_false(qualify(changed, ids)$passed)
})

test_that("the tail bound is finite without running the fixture audit", {
  tail_log_mass <- log(2) + stats::pnorm(-12, log.p = TRUE)
  expect_true(is.finite(tail_log_mass))
  expect_lt(exp(tail_log_mass), 4e-33)
  expect_gt(exp(tail_log_mass), 3e-33)
})

test_that("the qualification contract fits, reads, and launches nothing", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle()
  source <- paste(readLines(ctx$paths[7L], warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("the frozen record stays pre-audit while the roadmap records outcome", {
  ctx <- load_conquest_p2_log_centered_continuous_oracle()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-log-centered-continuous-oracle-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2co_specification, fixed = TRUE)
  expect_match(record, "`[-12,12]`", fixed = TRUE)
  expect_match(record, "`OracleAuditOpened=FALSE`", fixed = TRUE)
  expect_match(record, "`Candidate004GenerationAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Qualify a log-centered continuous P2 oracle",
    fixed = TRUE
  )
})
