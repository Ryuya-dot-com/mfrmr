load_conquest_six_arm_candidate_binding <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-prospective-tolerance-contract-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-six-arm-candidate-binding-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "Repository-only ConQuest candidate binding is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("the candidate has exactly six bound command/input arms", {
  env <- load_conquest_six_arm_candidate_binding()$env
  arms <- env$mfrmr_cq_cb_arm_registry()
  outputs <- env$mfrmr_cq_cb_output_registry()
  hashes <- env$mfrmr_cq_cb_bundle_hashes()

  expect_identical(nrow(arms), 6L)
  expect_identical(arms$Family, c("Binary", "Binary", "RSM", "RSM", "PCM", "PCM"))
  expect_identical(arms$Nodes, c(31L, 61L, 31L, 61L, 31L, 61L))
  expect_false(anyDuplicated(arms$ArmId) > 0L)
  expect_true(all(grepl("^[[:xdigit:]]{64}$", arms$CommandSHA256)))
  expect_true(all(grepl("^[[:xdigit:]]{64}$", arms$InputSHA256)))
  expect_identical(length(unique(arms$InputSHA256)), 2L)
  expect_identical(nrow(outputs), 46L)
  expect_false(anyDuplicated(outputs$RelativePath) > 0L)
  expect_true(all(outputs$ExpectedAbsentAtBinding))
  expect_identical(
    hashes$Bundle, c("command", "input", "expected_empty_outputs")
  )
  expect_identical(hashes$SHA256, hashes$ExpectedSHA256)
  expect_identical(
    hashes$SHA256,
    c(
      "be3127562ea8011b8076b8d1f3a0a5213ba5444803ee567fcbab0941c36874e4",
      "a7d30cb32b08ccb3f50b89dfc21f14352241ff648743ba207c2c38fcbb905fa1",
      "9850792b061b1d9d5dfdfe360e65e5c6b65fd6e35d70aa3dc0a81ae8f126ce43"
    )
  )
})

test_that("the exact binding passes structural preflight but not execution", {
  env <- load_conquest_six_arm_candidate_binding()$env
  binding <- env$mfrmr_cq_cb_binding()
  status <- env$mfrmr_cq_cb_validate_binding(binding)
  review <- env$mfrmr_cq_cb_review()

  expect_true(status$binding_identical)
  expect_true(status$binding_ready)
  expect_true(status$policy$IdentityOK)
  expect_identical(binding$CandidateId, env$mfrmr_cq_cb_candidate_id)
  expect_identical(binding$SourceCommit, env$mfrmr_cq_cb_source_commit)
  expect_identical(
    binding$SourceTreeSHA256, env$mfrmr_cq_cb_source_tree_sha256
  )
  expect_identical(
    status$freeze$status,
    "tolerance_and_candidate_binding_structurally_ready"
  )
  expect_identical(
    review$status,
    "candidate_binding_frozen_external_bundle_not_locally_checked"
  )
  expect_true(review$candidate_binding_ready)
  expect_false(review$local_bundle_verified)
  expect_false(review$candidate_core_structurally_authorized)
  expect_false(review$candidate_execution_authorized)
  expect_identical(
    review$execution_hold_reason,
    "polytomous_mfrmr_reference_inference_readiness_unresolved"
  )
  expect_identical(review$polytomous_reference_fit_readiness, "review")
  expect_false(review$polytomous_reference_inference_ready)
  expect_false(review$opened_calibration_reclassification_authorized)
  expect_false(review$hidden_solution_equivalence_eligible)
  expect_false(review$scientific_equivalence_inferred)
  expect_false(review$confirmation_authorized)
})

test_that("the pre-binding source tree is hash-bound when git is available", {
  ctx <- load_conquest_six_arm_candidate_binding()
  source <- ctx$env$mfrmr_cq_cb_source_status(ctx$root)

  expect_identical(
    source$ExpectedCommit, "7a04fd4cde65d4be985aa2a908ab4d8e65fadba5"
  )
  expect_identical(
    source$ExpectedTreeSHA256,
    "bcb700d2757afab3aa1e2330210e36add4bc59cdc2f44e458762b445014a4f4b"
  )
  if (dir.exists(file.path(ctx$root, ".git"))) {
    expect_true(source$Available)
    expect_true(source$IdentityOK)
    expect_identical(source$ActualTreeSHA256, source$ExpectedTreeSHA256)
  } else {
    expect_false(source$Available)
    expect_false(source$IdentityOK)
  }
})

test_that("the local ignored bundle is verified when present", {
  ctx <- load_conquest_six_arm_candidate_binding()
  candidate_root <- file.path(ctx$root, ctx$env$mfrmr_cq_cb_candidate_root)

  if (dir.exists(candidate_root)) {
    audit <- ctx$env$mfrmr_cq_cb_file_audit(candidate_root)
    review <- ctx$env$mfrmr_cq_cb_review(candidate_root)
    expect_true(audit$all_commands_ready)
    expect_true(audit$all_inputs_ready)
    expect_true(audit$all_outputs_absent)
    expect_true(audit$local_bundle_verified)
    expect_identical(
      review$status,
      "candidate_binding_and_local_bundle_verified_execution_held"
    )
    expect_true(review$candidate_core_structurally_authorized)
    expect_false(review$candidate_execution_authorized)
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("binding drift and missing or opened bundle files fail closed", {
  ctx <- load_conquest_six_arm_candidate_binding()
  env <- ctx$env
  binding <- env$mfrmr_cq_cb_binding()

  changed <- binding
  changed$CommandBundleSHA256 <- paste(rep("0", 64L), collapse = "")
  changed_status <- env$mfrmr_cq_cb_validate_binding(changed)
  changed_review <- env$mfrmr_cq_cb_review(binding = changed)
  expect_false(changed_status$binding_identical)
  expect_false(changed_status$binding_ready)
  expect_identical(changed_review$status, "candidate_binding_invalid")
  expect_false(changed_review$candidate_binding_ready)
  expect_false(changed_review$candidate_execution_authorized)

  opened <- binding
  opened$CandidateOutputsPresentAtFreeze <- TRUE
  opened_status <- env$mfrmr_cq_cb_validate_binding(opened)
  expect_false(opened_status$binding_identical)
  expect_false(opened_status$binding_ready)
  expect_false(opened_status$freeze$preflight$candidate_binding_ready)

  empty_root <- tempfile("mfrmr-cq-binding-")
  dir.create(empty_root)
  audit <- env$mfrmr_cq_cb_file_audit(empty_root)
  expect_false(audit$all_commands_ready)
  expect_false(audit$all_inputs_ready)
  expect_true(audit$all_outputs_absent)
  expect_false(audit$local_bundle_verified)

  first_output <- env$mfrmr_cq_cb_output_registry()$RelativePath[1L]
  output_path <- file.path(empty_root, first_output)
  dir.create(dirname(output_path), recursive = TRUE)
  writeLines("opened-output", output_path)
  opened_audit <- env$mfrmr_cq_cb_file_audit(empty_root)
  expect_false(opened_audit$all_outputs_absent)
  expect_false(opened_audit$local_bundle_verified)
})

test_that("the candidate-binding record is source-bound", {
  ctx <- load_conquest_six_arm_candidate_binding()
  record_path <- file.path(
    ctx$validation, "conquest-six-arm-candidate-binding-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  artifacts <- c(
    file.path(ctx$validation, c(
      "conquest-six-arm-candidate-binding-0.2.3.R",
      "conquest-prospective-tolerance-contract-0.2.3.R",
      "conquest-prospective-tolerance-freeze-0.2.3.R",
      "conquest-reported-output-precision-contract-0.2.3.R"
    )),
    file.path(
      ctx$root, "tests", "testthat",
      "test-conquest-six-arm-candidate-binding.R"
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
    ctx$env$mfrmr_cq_cb_source_commit,
    ctx$env$mfrmr_cq_cb_source_tree_sha256,
    ctx$env$mfrmr_cq_cb_command_bundle_sha256,
    ctx$env$mfrmr_cq_cb_input_bundle_sha256,
    ctx$env$mfrmr_cq_cb_expected_empty_outputs_sha256,
    ctx$env$mfrmr_cq_cb_execution_hold_reason
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("CandidateExecutionAuthorized.*FALSE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
})
