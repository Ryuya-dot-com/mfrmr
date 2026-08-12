load_conquest_candidate_003_execution_result <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-prospective-tolerance-contract-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-six-arm-candidate-binding-0.2.3.R",
    "conquest-six-arm-candidate-reference-preflight-0.2.3.R",
    "conquest-six-arm-candidate-003-binding-0.2.3.R",
    "conquest-six-arm-candidate-003-reference-preflight-0.2.3.R",
    "conquest-six-arm-candidate-003-execution-handoff-0.2.3.R",
    "conquest-six-arm-candidate-003-execution-result-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only candidate-003 execution result is excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("candidate-003 execution summary identity is frozen", {
  env <- load_conquest_candidate_003_execution_result()$env
  execution <- env$mfrmr_cq_c3er_execution_registry()
  expect_identical(nrow(execution), 6L)
  expect_identical(execution$ExecutionOrder, 1:6)
  expect_true(all(execution$ProcessExitStatus == 0L))
  expect_true(all(execution$SemanticSuccess))
  expect_identical(
    execution$ExpectedNativeOutputCount,
    c(6L, 6L, 8L, 8L, 8L, 8L)
  )
  expect_true(all(grepl("^[[:xdigit:]]{64}$", execution$ConsoleSHA256)))
  expect_identical(
    env$mfrmr_cq_c3er_execution_summary_hash(),
    "f7bc74ce4cf4fa121333c4de101f37c4d2446d88f30d666ec8f781bdcf58fdc7"
  )
})

test_that("all 50 candidate-003 outputs are bound and semantic", {
  ctx <- load_conquest_candidate_003_execution_result()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_c3_candidate_root
  )
  if (dir.exists(candidate_root)) {
    review <- ctx$env$mfrmr_cq_c3er_review(candidate_root)
    expect_identical(
      review$status,
      "candidate_003_execution_complete_native_comparison_review_pending"
    )
    expect_true(review$execution_summary_identity_ok)
    expect_true(review$semantic_identity_ok)
    expect_true(review$output_audit$output_bundle_identity_ok)
    expect_identical(nrow(review$output_audit$registry), 50L)
    expect_true(review$output_audit$all_50_present)
    expect_true(review$output_audit$all_50_nonempty)
    expect_true(all(review$semantic_summary$ExitStatusOK))
    expect_true(all(review$semantic_summary$TerminalMarkerPresent))
    expect_true(all(review$semantic_summary$FailurePatternCount == 0L))
    expect_true(all(review$semantic_summary$SemanticSuccess))
    expect_true(review$execution_complete)
    expect_true(review$execution_handoff_consumed)
    expect_false(review$rerun_authorized)
    expect_true(review$numerical_comparison_review_authorized)
    expect_false(review$comparison_passed)
    expect_false(review$scientific_equivalence_inferred)
    expect_false(review$inference_ready)
    expect_false(review$confirmation_authorized)
    expect_false(review$sparse_extension_authorized)
    expect_false(review$gpcm_extension_authorized)
    expect_false(review$large_simulation_authorized)
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("execution-result identity drift fails closed", {
  ctx <- load_conquest_candidate_003_execution_result()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_c3_candidate_root
  )
  if (dir.exists(candidate_root)) {
    original <- ctx$env$mfrmr_cq_c3er_output_bundle_sha256
    ctx$env$mfrmr_cq_c3er_output_bundle_sha256 <-
      paste(rep("0", 64L), collapse = "")
    drift <- ctx$env$mfrmr_cq_c3er_review(candidate_root)
    expect_identical(drift$status, "candidate_003_execution_result_invalid")
    expect_false(drift$output_audit$output_bundle_identity_ok)
    expect_false(drift$execution_complete)
    expect_false(drift$numerical_comparison_review_authorized)
    expect_false(drift$rerun_authorized)
    ctx$env$mfrmr_cq_c3er_output_bundle_sha256 <- original
    expect_true(ctx$env$mfrmr_cq_c3er_review(candidate_root)$execution_complete)
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("candidate-003 execution-result record is source-bound", {
  ctx <- load_conquest_candidate_003_execution_result()
  record_path <- file.path(
    ctx$validation,
    "conquest-six-arm-candidate-003-execution-result-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  artifacts <- c(
    file.path(
      ctx$validation,
      c(
        "conquest-six-arm-candidate-003-execution-result-0.2.3.R",
        "conquest-six-arm-candidate-003-execution-handoff-0.2.3.R"
      )
    ),
    file.path(
      ctx$root, "tests", "testthat",
      "test-conquest-six-arm-candidate-003-execution-result.R"
    )
  )
  hashes <- vapply(
    artifacts, digest::digest, character(1L),
    algo = "sha256", file = TRUE, serialize = FALSE
  )
  expect_true(all(vapply(
    hashes, grepl, logical(1L), x = record, fixed = TRUE
  )))
  identities <- c(
    ctx$env$mfrmr_cq_c3er_candidate_id,
    ctx$env$mfrmr_cq_c3er_output_bundle_sha256,
    ctx$env$mfrmr_cq_c3er_execution_summary_sha256
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("ExecutionComplete.*TRUE", record))
  expect_true(grepl("RerunAuthorized.*FALSE", record))
  expect_true(grepl("ComparisonPassed.*FALSE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
})
