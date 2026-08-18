load_conquest_candidate_003_binding <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-prospective-tolerance-contract-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-six-arm-candidate-binding-0.2.3.R",
    "conquest-six-arm-candidate-003-binding-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "Repository-only candidate-003 binding is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("candidate 003 freezes corrected Binary command identities", {
  env <- load_conquest_candidate_003_binding()$env
  arms <- env$mfrmr_cq_c3_arm_registry()
  hashes <- env$mfrmr_cq_c3_bundle_hashes()

  expect_identical(nrow(arms), 6L)
  expect_identical(arms$Family, c("Binary", "Binary", "RSM", "RSM", "PCM", "PCM"))
  expect_identical(arms$Nodes, c(31L, 61L, 31L, 61L, 31L, 61L))
  expect_identical(
    arms$CommandSHA256[1:2],
    c(
      "9212b6bc128fdeb3117bc992d15afeeb88c37143bf76d996ecf7a007f9fb0a8d",
      "ab343e081469b40370a979a02662d80996ede8ae22ef46e6319a34da97850a7c"
    )
  )
  expect_false(any(arms$CommandSHA256[1:2] %in% c(
    "61a7e9c9c4f8303deb4eff40027c245d66442eb63021a4109f5ec6c69c2bee6a",
    "f0a2d1d5f9c8d30114088da3e61c29b6380e02e769513cb951b08296d72c45ea"
  )))
  expect_identical(
    hashes$Bundle,
    c("command", "input", "model_dimension", "expected_empty_outputs")
  )
  expect_identical(hashes$SHA256, hashes$ExpectedSHA256)
  expect_identical(
    hashes$SHA256,
    c(
      "dd273c52bf58edc2f9e96253bcdc2694a29d2cb59d2bc4b45759066c35bb2666",
      "cd595bc5a914297ea57f13b1f1fc5d8e6d4d9baacd3f7cadcf380a62806fddcb",
      "12dafad2ac6e622288717ec60062f1eeb42c159db253dd46757834335b9e40f5",
      "161488319712d87f720ef6dce8b1a3b5ae1dd0c2e40eea3897189655870d6d8a"
    )
  )
})

test_that("candidate 003 local bundle audit respects one-way execution state", {
  ctx <- load_conquest_candidate_003_binding()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_c3_candidate_root
  )

  if (dir.exists(candidate_root)) {
    audit <- ctx$env$mfrmr_cq_c3_file_audit(candidate_root)
    review <- ctx$env$mfrmr_cq_c3_review(candidate_root)
    expect_true(audit$all_commands_ready)
    expect_true(audit$all_inputs_ready)
    expect_true(audit$all_model_dimensions_ready)
    expect_true(audit$all_commands_executable_input_only)
    expect_true(all(audit$command_only))
    expect_true(review$candidate_binding_ready)
    if (isTRUE(audit$all_outputs_absent)) {
      expect_true(audit$local_bundle_verified)
      expect_identical(
        review$status,
        "candidate_003_binding_and_local_bundle_ready_execution_held"
      )
      expect_true(review$local_bundle_verified)
      expect_true(review$candidate_core_structurally_authorized)
    } else {
      # Candidate 003 is a one-way gate. Once any bound output exists, the
      # pre-execution bundle must remain closed even when command and input
      # identities are still intact; downstream result contracts audit the
      # completed execution separately.
      expect_true(any(audit$outputs$ObservedPresent))
      expect_false(audit$local_bundle_verified)
      expect_identical(
        review$status,
        "candidate_003_local_bundle_invalid_or_opened"
      )
      expect_false(review$local_bundle_verified)
      expect_false(review$candidate_core_structurally_authorized)
    }
    expect_false(review$numerical_reference_ready)
    expect_false(review$candidate_execution_authorized)
    expect_identical(
      review$execution_hold_reason,
      "candidate_003_reference_preflight_pending"
    )
    expect_false(review$comparison_authorized)
    expect_false(review$scientific_equivalence_inferred)
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("candidate 003 is bound to the post-incident source commit", {
  ctx <- load_conquest_candidate_003_binding()
  source <- ctx$env$mfrmr_cq_c3_source_status(ctx$root)
  expect_identical(
    source$ExpectedCommit, "4f86fa187e010d3c9faff647c88abc38ddcf5b0f"
  )
  expect_identical(
    source$ExpectedTreeSHA256,
    "b1b692bd533cce481d87ed75917070691963ba2abf3caceb0c70ec59299d898f"
  )
  if (dir.exists(file.path(ctx$root, ".git"))) {
    expect_true(source$Available)
    expect_true(source$IdentityOK)
  }
})

test_that("candidate 003 binding drift fails closed", {
  env <- load_conquest_candidate_003_binding()$env
  original <- env$mfrmr_cq_c3_command_bundle_sha256
  env$mfrmr_cq_c3_command_bundle_sha256 <- paste(rep("0", 64L), collapse = "")
  review <- env$mfrmr_cq_c3_review()
  expect_identical(review$status, "candidate_003_binding_invalid")
  expect_false(review$candidate_binding_ready)
  expect_false(review$candidate_execution_authorized)
  env$mfrmr_cq_c3_command_bundle_sha256 <- original
  expect_true(env$mfrmr_cq_c3_review()$candidate_binding_ready)
})

test_that("the candidate-003 binding record is source-bound", {
  ctx <- load_conquest_candidate_003_binding()
  record_path <- file.path(
    ctx$validation, "conquest-six-arm-candidate-003-binding-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  # The frozen record binds the executable validation contract. The mutable
  # test harness is deliberately not part of its own provenance requirement.
  artifacts <- c(
    file.path(
      ctx$validation, "conquest-six-arm-candidate-003-binding-0.2.3.R"
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
    ctx$env$mfrmr_cq_c3_candidate_id,
    ctx$env$mfrmr_cq_c3_source_commit,
    ctx$env$mfrmr_cq_c3_source_tree_sha256,
    ctx$env$mfrmr_cq_c3_command_bundle_sha256
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("CandidateExecutionAuthorized.*FALSE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
})
