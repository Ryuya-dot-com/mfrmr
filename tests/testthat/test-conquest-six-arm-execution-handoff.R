load_conquest_execution_handoff <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-prospective-tolerance-contract-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-six-arm-candidate-binding-0.2.3.R",
    "conquest-six-arm-candidate-reference-preflight-0.2.3.R",
    "conquest-six-arm-execution-handoff-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "Repository-only ConQuest execution handoff is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("the execution invocation and pre-handoff source are frozen", {
  ctx <- load_conquest_execution_handoff()
  invocation <- ctx$env$mfrmr_cq_eh_invocation_registry()
  source <- ctx$env$mfrmr_cq_eh_source_status(ctx$root)

  expect_identical(nrow(invocation), 6L)
  expect_identical(invocation$ExecutionOrder, 1:6)
  expect_identical(
    invocation$ArmId,
    c(
      "binary_q031", "binary_q061", "rsm_q031", "rsm_q061",
      "pcm_q031", "pcm_q061"
    )
  )
  expect_true(all(
    invocation$InvocationMode ==
      "stdin_command_file_stdout_stderr_single_console"
  ))
  expect_true(all(invocation$ExpectedExitStatus == 0L))
  expect_true(all(invocation$RunOnce))
  expect_identical(
    ctx$env$mfrmr_cq_eh_invocation_hash(),
    "6a7168df4c782ec9d746977cf6d6fcfd27ed7c8c876996a51c8b3ed9a156d066"
  )
  if (dir.exists(file.path(ctx$root, ".git"))) {
    expect_true(source$Available)
    expect_true(source$IdentityOK)
    expect_identical(
      source$ExpectedCommit, "af7bbb546195d19159e071b292d087709c9753b3"
    )
    expect_identical(
      source$ExpectedTreeSHA256,
      "614bf443b178e4c6104228b2d0b798086cd271fb589ee95ff21ab14b42704982"
    )
  }
})

test_that("the local executable and exact six-arm handoff are ready", {
  ctx <- load_conquest_execution_handoff()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_cb_candidate_root
  )

  if (dir.exists(candidate_root) &&
      file.exists(ctx$env$mfrmr_cq_eh_executable_path)) {
    review <- ctx$env$mfrmr_cq_eh_review(candidate_root, ctx$root)
    expect_identical(
      review$status,
      "exact_six_arm_execution_authorized_outputs_must_remain_unopened_until_launch"
    )
    expect_true(review$executable$PathOK)
    expect_true(review$executable$Executable)
    expect_true(review$executable$IdentityOK)
    expect_true(review$invocation_hash_ok)
    expect_true(all(review$invocation$PathReady))
    expect_true(review$reference$numerical_reference_ready)
    expect_false(review$reference$inference_ready)
    expect_true(review$candidate_execution_authorized)
    expect_identical(review$authorized_arm_count, 6L)
    expect_true(review$run_once)
    expect_false(review$existing_output_reuse_authorized)
    expect_false(review$comparison_authorized)
    expect_false(review$scientific_equivalence_inferred)
    expect_false(review$confirmation_authorized)
    expect_false(review$sparse_extension_authorized)
    expect_false(review$gpcm_extension_authorized)
    expect_false(review$large_simulation_authorized)
  } else {
    expect_false(dir.exists(candidate_root) &&
                   file.exists(ctx$env$mfrmr_cq_eh_executable_path))
  }
})

test_that("wrong executable or invocation identity fails closed", {
  ctx <- load_conquest_execution_handoff()
  executable <- ctx$env$mfrmr_cq_eh_executable_status(tempfile("not-cq-"))
  expect_false(executable$PathOK)
  expect_false(executable$Exists)
  expect_false(executable$Executable)
  expect_false(executable$IdentityOK)

  original <- ctx$env$mfrmr_cq_eh_invocation_bundle_sha256
  ctx$env$mfrmr_cq_eh_invocation_bundle_sha256 <- paste(
    rep("0", 64L), collapse = ""
  )
  expect_false(identical(
    ctx$env$mfrmr_cq_eh_invocation_hash(),
    ctx$env$mfrmr_cq_eh_invocation_bundle_sha256
  ))
  ctx$env$mfrmr_cq_eh_invocation_bundle_sha256 <- original
  expect_identical(
    ctx$env$mfrmr_cq_eh_invocation_hash(),
    ctx$env$mfrmr_cq_eh_invocation_bundle_sha256
  )
})

test_that("an existing console output invalidates the path handoff", {
  ctx <- load_conquest_execution_handoff()
  root <- tempfile("mfrmr-cq-handoff-")
  dir.create(root)
  invocation <- ctx$env$mfrmr_cq_eh_invocation_registry()
  for (index in seq_len(nrow(invocation))) {
    run_dir <- file.path(root, invocation$WorkingDirectory[index])
    dir.create(run_dir, recursive = TRUE)
    writeLines("quit;", file.path(run_dir, invocation$CommandFile[index]))
  }
  ready <- ctx$env$mfrmr_cq_eh_path_status(root)
  expect_true(all(ready$PathReady))
  writeLines(
    "opened",
    file.path(
      root, invocation$WorkingDirectory[1L], invocation$ConsoleFile[1L]
    )
  )
  opened <- ctx$env$mfrmr_cq_eh_path_status(root)
  expect_false(opened$ConsoleAbsent[1L])
  expect_false(opened$PathReady[1L])
  expect_false(all(opened$PathReady))
})

test_that("the execution-handoff record is source-bound", {
  ctx <- load_conquest_execution_handoff()
  record_path <- file.path(
    ctx$validation, "conquest-six-arm-execution-handoff-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  artifacts <- c(
    file.path(
      ctx$validation,
      c(
        "conquest-six-arm-execution-handoff-0.2.3.R",
        "conquest-six-arm-candidate-reference-preflight-0.2.3.R"
      )
    ),
    file.path(
      ctx$root, "tests", "testthat",
      "test-conquest-six-arm-execution-handoff.R"
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
    ctx$env$mfrmr_cq_eh_candidate_id,
    ctx$env$mfrmr_cq_eh_source_commit,
    ctx$env$mfrmr_cq_eh_source_tree_sha256,
    ctx$env$mfrmr_cq_eh_executable_sha256,
    ctx$env$mfrmr_cq_eh_invocation_bundle_sha256
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("CandidateExecutionAuthorized.*TRUE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
})
