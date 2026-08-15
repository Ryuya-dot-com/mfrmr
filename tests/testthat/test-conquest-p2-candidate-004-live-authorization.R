load_conquest_p2_candidate_004_live_authorization <- function() {
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
    "conquest-p2-candidate-004-live-authorization-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 live authorization excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("fresh data-free runtime evidence remains semantic-only", {
  ctx <- load_conquest_p2_candidate_004_live_authorization()
  runtime <- ctx$env$mfrmr_cq_p2c4a_runtime_observation()
  summary <- runtime$summary

  expect_identical(summary$Status, "runtime_semantic_ready")
  expect_identical(summary$RuntimeVersion, "5.47.5")
  expect_identical(summary$ExpiryDate, as.Date("2026-09-01"))
  expect_true(summary$SemanticSuccess)
  expect_false(summary$ExpiredByDate)
  expect_identical(summary$RegisteredFailureCount, 0L)
  expect_true(summary$CommandIsDataFreeQuit)
  expect_false(summary$ModelEstimationAttempted)
  expect_false(summary$ScientificComparisonAuthorized)
})

test_that("authorization freezes exactly four q61/q121 ConQuest arms", {
  ctx <- load_conquest_p2_candidate_004_live_authorization()
  slice <- ctx$env$mfrmr_cq_p2c4a_slice_registry()

  expect_identical(slice$Family, c("RSM", "RSM", "PCM", "PCM"))
  expect_identical(slice$Nodes, c(61L, 121L, 61L, 121L))
  expect_identical(slice$ExpectedFreeDimension, c(10L, 10L, 14L, 14L))
  expect_identical(sum(slice$ConQuestFitCap), 4L)
  expect_identical(sum(slice$NewMfrmrFitCap), 0L)
  expect_true(all(slice$SharedCandidateData))
  expect_false(any(slice$EvidencePromotionAuthorized))
})

test_that("all fatal gates activate only the narrow live window", {
  ctx <- load_conquest_p2_candidate_004_live_authorization()
  env <- ctx$env
  root <- file.path(
    withr::local_tempdir(), env$mfrmr_cq_p2c4a_output_basename
  )
  active <- env$mfrmr_cq_p2c4a_review(root)
  stale <- env$mfrmr_cq_p2c4a_review(root, as.Date("2026-08-17"))

  expect_identical(
    active$status, "candidate_004_four_arm_q61_q121_live_authorization_active"
  )
  expect_identical(nrow(active$gates), 15L)
  expect_true(all(active$gates$Passed))
  expect_true(active$all_fifteen_fatal_gates_passed)
  expect_true(active$candidate_004_external_execution_authorized)
  expect_false(stale$candidate_004_external_execution_authorized)
  expect_false(active$new_mfrmr_fit_authorized)
  expect_false(active$evidence_promotion_authorized)
  expect_false(active$public_claim_authorized)
})

test_that("output, artifact, test, and worktree failures block", {
  ctx <- load_conquest_p2_candidate_004_live_authorization()
  env <- ctx$env
  parent <- withr::local_tempdir()
  root <- file.path(parent, env$mfrmr_cq_p2c4a_output_basename)

  dir.create(root)
  expect_false(env$mfrmr_cq_p2c4a_review(root)$candidate_004_external_execution_authorized)
  unlink(root, recursive = TRUE)
  expect_false(env$mfrmr_cq_p2c4a_review(
    root, preflight_artifacts_ready = FALSE
  )$candidate_004_external_execution_authorized)
  expect_false(env$mfrmr_cq_p2c4a_review(
    root, ordinary_tests_external_runtime_free = FALSE
  )$candidate_004_external_execution_authorized)
  expect_false(env$mfrmr_cq_p2c4a_review(
    root, worktree_clean = FALSE
  )$candidate_004_external_execution_authorized)
})

test_that("live authorization cannot launch, fit, or substitute hashes", {
  ctx <- load_conquest_p2_candidate_004_live_authorization()
  source <- paste(readLines(ctx$paths[17L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap retain downstream review gates", {
  ctx <- load_conquest_p2_candidate_004_live_authorization()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-candidate-004-live-authorization-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4a_specification, fixed = TRUE)
  expect_match(record, "`Candidate004ExternalExecutionAuthorized=TRUE`", fixed = TRUE)
  expect_match(record, "same-author minimum audit", fixed = TRUE)
  expect_match(
    roadmap,
    "authorization is frozen through 2026-08-16",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Complete the independent post-output evidence review",
    fixed = TRUE
  )
})
