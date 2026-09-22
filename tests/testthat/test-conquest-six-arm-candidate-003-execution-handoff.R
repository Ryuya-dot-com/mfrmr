load_conquest_candidate_003_execution_handoff <- function() {
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
    "conquest-six-arm-candidate-003-execution-handoff-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only candidate-003 execution handoff is excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("candidate-003 ordered invocation and source are frozen", {
  ctx <- load_conquest_candidate_003_execution_handoff()
  invocation <- ctx$env$mfrmr_cq_c3eh_invocation_registry()
  failures <- ctx$env$mfrmr_cq_c3eh_semantic_failure_registry()
  source <- ctx$env$mfrmr_cq_c3eh_source_status(ctx$root)

  expect_identical(nrow(invocation), 6L)
  expect_identical(invocation$ExecutionOrder, 1:6)
  expect_identical(
    invocation$ArmId,
    c(
      "binary_q031", "binary_q061", "rsm_q031", "rsm_q061",
      "pcm_q031", "pcm_q061"
    )
  )
  expect_identical(
    invocation$ExpectedNativeOutputCount,
    c(6L, 6L, 8L, 8L, 8L, 8L)
  )
  expect_true(all(invocation$RequiredTerminalMarker == "End of Program"))
  expect_true(all(invocation$AdvanceOnlyAfterSemanticSuccess))
  expect_true(all(invocation$ExpectedExitStatus == 0L))
  expect_true(all(invocation$RunOnce))
  expect_identical(nrow(failures), 8L)
  expect_true(all(nzchar(failures$FixedPattern)))
  expect_identical(
    ctx$env$mfrmr_cq_c3eh_invocation_hash(),
    "a47873a976ab61e4daee1dbc72591f61d4376b86cd486aaebfd51e12a0ca912c"
  )
  if (dir.exists(file.path(ctx$root, ".git"))) {
    expect_true(source$Available)
    expect_true(source$IdentityOK)
    expect_identical(
      source$ExpectedCommit, "686485da35b325e547786f1b4eb26a53195e572d"
    )
    expect_identical(
      source$ExpectedTreeSHA256,
      "564ebcfbf90966f49b4ee7f6fff7afcd3ae689bdf1217f091c9c24c06ca2b8e5"
    )
  }
})

test_that("candidate-003 exact handoff is one-way across launch", {
  ctx <- load_conquest_candidate_003_execution_handoff()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_c3_candidate_root
  )

  if (dir.exists(candidate_root) &&
      file.exists(ctx$env$mfrmr_cq_c3eh_executable_path)) {
    review <- ctx$env$mfrmr_cq_c3eh_review(candidate_root, ctx$root)
    expect_true(review$executable$PathOK)
    expect_true(review$executable$Executable)
    expect_true(review$executable$IdentityOK)
    expect_true(review$invocation_hash_ok)
    expect_false(review$reference$inference_ready)
    if (all(review$invocation$ConsoleAbsent)) {
      expect_identical(
        review$status,
        "candidate_003_ordered_execution_authorized_semantic_gate_required"
      )
      expect_true(all(review$invocation$PathReady))
      expect_true(review$reference$numerical_reference_ready)
      expect_true(review$candidate_execution_authorized)
      expect_identical(review$authorized_arm_count, 6L)
      expect_true(review$run_once)
      expect_true(review$arm_by_arm_semantic_gate_required)
    } else {
      expect_identical(
        review$status,
        "candidate_003_execution_handoff_invalid_or_already_opened"
      )
      expect_false(all(review$invocation$PathReady))
      expect_false(review$reference$numerical_reference_ready)
      expect_false(review$candidate_execution_authorized)
      expect_identical(review$authorized_arm_count, 0L)
      expect_false(review$run_once)
      expect_false(review$arm_by_arm_semantic_gate_required)
    }
    expect_false(review$existing_output_reuse_authorized)
    expect_false(review$comparison_authorized)
    expect_false(review$scientific_equivalence_inferred)
    expect_false(review$confirmation_authorized)
    expect_false(review$sparse_extension_authorized)
    expect_false(review$gpcm_extension_authorized)
    expect_false(review$large_simulation_authorized)
  } else {
    expect_false(dir.exists(candidate_root) &&
                   file.exists(ctx$env$mfrmr_cq_c3eh_executable_path))
  }
})

test_that("semantic gate rejects false host success and permits clean output", {
  ctx <- load_conquest_candidate_003_execution_handoff()
  root <- tempfile("mfrmr-cq-c3-semantic-")
  dir.create(root)
  output <- ctx$env$mfrmr_cq_cb_output_registry()
  arm <- output[output$ArmId == "binary_q031", , drop = FALSE]
  for (path in file.path(root, arm$RelativePath)) {
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    writeLines("native evidence", path)
  }
  console_path <- file.path(
    root, arm$RelativePath[arm$OutputKind == "console_log"]
  )
  writeLines(c("ConQuest version: 5.47.5", "<End of Program"), console_path)
  clean <- ctx$env$mfrmr_cq_c3eh_semantic_status(
    root, "binary_q031", 0L
  )
  expect_true(clean$console_exists)
  expect_true(clean$exit_status_ok)
  expect_true(clean$terminal_marker_present)
  expect_false(any(clean$failure_patterns$Observed))
  expect_identical(clean$native_output_count, 6L)
  expect_true(all(clean$native_outputs_exist))
  expect_true(all(clean$native_outputs_nonempty))
  expect_true(clean$semantic_success)
  expect_true(clean$next_arm_authorized)
  expect_false(clean$comparison_authorized)
  expect_false(clean$scientific_equivalence_inferred)

  writeLines(c(
    "Unknown command or argument: /*Generated", "<End of Program"
  ), console_path)
  false_success <- ctx$env$mfrmr_cq_c3eh_semantic_status(
    root, "binary_q031", 0L
  )
  expect_true(false_success$exit_status_ok)
  expect_true(false_success$terminal_marker_present)
  expect_true(any(false_success$failure_patterns$Observed))
  expect_false(false_success$semantic_success)
  expect_false(false_success$next_arm_authorized)
})

test_that("opened output and identity drift invalidate the handoff", {
  ctx <- load_conquest_candidate_003_execution_handoff()
  root <- tempfile("mfrmr-cq-c3-handoff-")
  dir.create(root)
  invocation <- ctx$env$mfrmr_cq_c3eh_invocation_registry()
  for (index in seq_len(nrow(invocation))) {
    run_dir <- file.path(root, invocation$WorkingDirectory[index])
    dir.create(run_dir, recursive = TRUE)
    writeLines("quit;", file.path(run_dir, invocation$CommandFile[index]))
  }
  ready <- ctx$env$mfrmr_cq_c3eh_path_status(root)
  expect_true(all(ready$PathReady))
  writeLines(
    "opened",
    file.path(
      root, invocation$WorkingDirectory[1L], invocation$ConsoleFile[1L]
    )
  )
  opened <- ctx$env$mfrmr_cq_c3eh_path_status(root)
  expect_false(opened$ConsoleAbsent[1L])
  expect_false(opened$PathReady[1L])
  expect_false(all(opened$PathReady))

  original <- ctx$env$mfrmr_cq_c3eh_invocation_bundle_sha256
  ctx$env$mfrmr_cq_c3eh_invocation_bundle_sha256 <-
    paste(rep("0", 64L), collapse = "")
  expect_false(identical(
    ctx$env$mfrmr_cq_c3eh_invocation_hash(),
    ctx$env$mfrmr_cq_c3eh_invocation_bundle_sha256
  ))
  ctx$env$mfrmr_cq_c3eh_invocation_bundle_sha256 <- original
  expect_identical(
    ctx$env$mfrmr_cq_c3eh_invocation_hash(),
    ctx$env$mfrmr_cq_c3eh_invocation_bundle_sha256
  )
})

test_that("candidate-003 handoff record retains its historical source binding", {
  ctx <- load_conquest_candidate_003_execution_handoff()
  record_path <- file.path(
    ctx$validation,
    "conquest-six-arm-candidate-003-execution-handoff-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  immutable_artifacts <- file.path(
    ctx$validation,
    c(
      "conquest-six-arm-candidate-003-execution-handoff-0.2.3.R",
      "conquest-six-arm-candidate-003-reference-preflight-0.2.3.R"
    )
  )
  hashes <- vapply(
    immutable_artifacts, digest::digest, character(1L),
    algo = "sha256", file = TRUE, serialize = FALSE
  )
  expect_true(all(vapply(
    hashes, grepl, logical(1L), x = record, fixed = TRUE
  )))
  historical_test_sha256 <-
    "aa7a95a18df51d4a64a9d1874deaba8e1329a712562a3dea6bff9104bbc70d3c"
  active_test_path <- file.path(
    ctx$root, "tests", "testthat",
    "test-conquest-six-arm-candidate-003-execution-handoff.R"
  )
  active_test_sha256 <- digest::digest(
    active_test_path, algo = "sha256", file = TRUE, serialize = FALSE
  )
  expect_match(record, historical_test_sha256, fixed = TRUE)
  expect_false(identical(active_test_sha256, historical_test_sha256))
  identities <- c(
    ctx$env$mfrmr_cq_c3eh_candidate_id,
    ctx$env$mfrmr_cq_c3eh_source_commit,
    ctx$env$mfrmr_cq_c3eh_source_tree_sha256,
    ctx$env$mfrmr_cq_c3eh_executable_sha256,
    ctx$env$mfrmr_cq_c3eh_invocation_bundle_sha256
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("CandidateExecutionAuthorized.*TRUE", record))
  expect_true(grepl("ArmByArmSemanticGateRequired.*TRUE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
})
