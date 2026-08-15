load_conquest_minimum_diagnostic_live_authorization <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-minimum-diagnostic-authorization-0.2.3.R",
    "conquest-minimum-diagnostic-live-authorization-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only live diagnostic-authorization files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("the live binding reproduces the data-free runtime observation", {
  ctx <- load_conquest_minimum_diagnostic_live_authorization()
  env <- ctx$env
  runtime <- env$mfrmr_cq_mdal_runtime_observation()
  summary <- runtime$summary

  expect_identical(summary$Status, "runtime_semantic_ready")
  expect_true(summary$RuntimeAvailable)
  expect_true(summary$SemanticSuccess)
  expect_false(summary$ExpiredByDate)
  expect_identical(summary$RegisteredFailureCount, 0L)
  expect_identical(summary$ExpectedOutputCount, 0L)
  expect_true(summary$CompleteOutputSet)
  expect_true(summary$CommandIsDataFreeQuit)
  expect_false(summary$ModelEstimationAttempted)
  expect_true(is.na(summary$ModelEstimationSuccess))
  expect_false(summary$ScientificComparisonAuthorized)
  expect_identical(summary$RuntimeVersion, "5.47.5")
  expect_identical(summary$ExpiryDate, as.Date("2026-09-01"))
  expect_identical(
    runtime$transcript,
    c(
      "ConQuest version: 5.47.5", "Demonstration Version",
      "This version expires 1 September 2026", "<End of Program"
    )
  )
})

test_that("the maintainer attestation discloses overlap and forbids claims", {
  ctx <- load_conquest_minimum_diagnostic_live_authorization()
  attestation <- ctx$env$mfrmr_cq_mdal_attestation()

  expect_identical(attestation$ReviewerRole, "maintainer")
  expect_true(attestation$AuthorOverlapDeclared)
  expect_true(attestation$FatalGateChecklistCompleted)
  expect_true(attestation$ExactSliceAndCapAccepted)
  expect_true(attestation$NoInterpretiveClaimAccepted)
  expect_false(attestation$IndependentComprehensiveReviewPassed)
})

test_that("live authorization is narrow, dated, and non-promotional", {
  ctx <- load_conquest_minimum_diagnostic_live_authorization()
  env <- ctx$env
  active <- env$mfrmr_cq_mdal_review(as.Date("2026-08-15"))
  last_day <- env$mfrmr_cq_mdal_review(as.Date("2026-08-16"))
  stale <- env$mfrmr_cq_mdal_review(as.Date("2026-08-17"))

  expect_identical(
    active$status, "minimum_P2_diagnostic_live_authorization_active"
  )
  expect_true(active$all_fifteen_fatal_gates_passed)
  expect_true(active$smallest_P2_diagnostic_execution_authorized)
  expect_true(last_day$smallest_P2_diagnostic_execution_authorized)
  expect_identical(
    stale$status, "minimum_P2_diagnostic_live_authorization_inactive"
  )
  expect_false(stale$smallest_P2_diagnostic_execution_authorized)
  expect_identical(active$run_not_after, as.Date("2026-08-16"))
  expect_false(active$independent_comprehensive_review_passed)
  expect_false(active$evidence_promotion_authorized)
  expect_false(active$wider_execution_authorized)
  expect_false(active$P3_execution_authorized)
  expect_false(active$public_claim_authorized)
  expect_false(active$scientific_equivalence_inferred)
})

test_that("the live binding records evidence but cannot execute an engine", {
  ctx <- load_conquest_minimum_diagnostic_live_authorization()
  source <- paste(readLines(ctx$paths[7L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256", source, fixed = TRUE))
})

test_that("the live record preserves downstream review gates", {
  ctx <- load_conquest_minimum_diagnostic_live_authorization()
  record_path <- file.path(
    ctx$validation,
    "conquest-minimum-diagnostic-live-authorization-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expected <- c(
    ctx$env$mfrmr_cq_mdal_specification,
    ctx$env$mfrmr_cq_mdal_contract,
    "minimum_P2_diagnostic_live_authorization_active",
    "`AllFifteenFatalGatesPassed` | `TRUE`",
    "`SmallestP2DiagnosticExecutionAuthorized` | `TRUE`",
    "`IndependentComprehensiveReviewPassed` | `FALSE`",
    "`EvidencePromotionAuthorized` | `FALSE`",
    "`P3ExecutionAuthorized` | `FALSE`",
    "`PublicClaimAuthorized` | `FALSE`"
  )
  expect_true(all(vapply(
    expected, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_match(
    roadmap,
    "[x] Bind a current data-free runtime sentinel and completed minimum audit",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Launch exactly the authorized two-row P2 diagnostic candidate",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Supersede the deterministic response generator",
    fixed = TRUE
  )
})
