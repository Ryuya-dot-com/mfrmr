load_conquest_p2_successor_integration_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "P2 successor integration is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("the successor budgets do not rescue candidate 003 or copy P3", {
  ctx <- load_conquest_p2_successor_integration_contract()
  review <- ctx$env$mfrmr_cq_p2si_review()
  budget <- review$budgets

  expect_identical(
    review$status,
    "P2_successor_integration_contract_frozen_truth_oracles_unopened"
  )
  expect_identical(nrow(budget), 3L)
  expect_identical(budget$AbsoluteTolerance, c(2e-6, 2e-6, 1e-7))
  expect_true(all(budget$Frozen))
  expect_false(any(budget$Candidate003OutputInformed))
  expect_false(any(budget$P3NumericBudgetTransferred))
  expect_false(any(budget$CanReclassifyCandidate003))
  expect_true(review$contract_ready)
  expect_false(review$truth_oracles_run)
  expect_false(review$truth_oracle_ready)
  expect_false(review$candidate_003_reclassified)
  expect_false(review$candidate_004_generation_authorized)
  expect_false(review$external_execution_authorized)
})

test_that("q31 is required diagnostic and both later layers govern", {
  ctx <- load_conquest_p2_successor_integration_contract()
  ladder <- ctx$env$mfrmr_cq_p2si_ladder_registry()

  expect_identical(ladder$To[1:3], c(31, 61, 121))
  expect_identical(
    ladder$Role[4L], "finite_required_diagnostic_no_pass_threshold"
  )
  expect_false(ladder$Governing[4L])
  expect_true(all(ladder$Governing[5:6]))
  expect_identical(ladder$CoordinateTolerance[5L], 2e-6)
  expect_identical(ladder$DevianceTolerance[5L], 2e-6)
  expect_identical(ladder$DevianceTolerance[6L], 1e-7)
  expect_false(any(ladder$Candidate003CanBeReclassified))
  expect_false(any(ladder$ExternalExecutionAuthorized))
})

test_that("integration precedence keeps the starting movement diagnostic", {
  ctx <- load_conquest_p2_successor_integration_contract()
  classify <- ctx$env$mfrmr_cq_p2si_classify_integration

  passed <- classify(100, 100, 1e-6, 1e-6, 1e-8)
  expect_identical(passed$State, "integration_eligible")
  expect_true(passed$FutureCrossEngineNumericEligible)
  expect_false(passed$Q31Q61DiagnosticThresholdApplied)
  expect_false(passed$Candidate003Reclassified)

  expect_identical(
    classify(NA_real_, 1, 1e-6, 1e-6, 1e-8)$State,
    "q31_q61_diagnostic_missing"
  )
  expect_identical(
    classify(1, 1, 3e-6, 1e-6, 1e-8)$State,
    "q61_q121_coordinate_unresolved"
  )
  expect_identical(
    classify(1, 1, 1e-6, 3e-6, 1e-8)$State,
    "q61_q121_deviance_unresolved"
  )
  expect_identical(
    classify(1, 1, 1e-6, 1e-6, 2e-7)$State,
    "q121_continuous_target_unresolved"
  )
})

test_that("the finite truth oracle is normalized and deterministic", {
  ctx <- load_conquest_p2_successor_integration_contract()
  env <- ctx$env
  fixture <- env$mfrmr_cq_p2_fixture("P2-RSM-CONNECTED-MULTIBRIDGE")
  first <- env$mfrmr_cq_p2si_fixed_loglikelihood(fixture, 31L)
  second <- env$mfrmr_cq_p2si_fixed_loglikelihood(fixture, 31L)

  expect_identical(first, second)
  expect_identical(first$Persons, 48L)
  expect_true(is.finite(first$LogLikelihood))
  expect_equal(first$Deviance, -2 * first$LogLikelihood, tolerance = 0)
  expect_lte(first$QuadratureWeightSumDifference, 1e-13)
  expect_false(first$ExternalExecutionAuthorized)
  expect_false(first$ScientificEquivalenceInferred)
  expect_error(
    env$mfrmr_cq_p2si_fixed_loglikelihood(fixture, 91L),
    "only q=31, q=61, or q=121",
    fixed = TRUE
  )
})

test_that("the contract fits and launches nothing", {
  ctx <- load_conquest_p2_successor_integration_contract()
  source <- paste(readLines(ctx$paths[5L], warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("the record retains the consumed failed audit and candidate hold", {
  ctx <- load_conquest_p2_successor_integration_contract()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-successor-integration-contract-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2si_specification, fixed = TRUE)
  expect_match(record, "Candidate 003 reclassification: prohibited", fixed = TRUE)
  expect_match(record, "`TruthOracleAuditOpened=TRUE`", fixed = TRUE)
  expect_match(record, "`TruthOracleAuditPassed=FALSE`", fixed = TRUE)
  expect_match(record, "`Candidate004GenerationAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze and test a first successor integration ladder before generating",
    fixed = TRUE
  )
})
