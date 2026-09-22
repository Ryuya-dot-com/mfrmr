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
  dimensions <- env$mfrmr_cq_cb_model_dimension_registry()
  dimension_status <- env$mfrmr_cq_cb_model_dimension_status()
  outputs <- env$mfrmr_cq_cb_output_registry()
  hashes <- env$mfrmr_cq_cb_bundle_hashes()

  expect_identical(nrow(arms), 6L)
  expect_identical(arms$Family, c("Binary", "Binary", "RSM", "RSM", "PCM", "PCM"))
  expect_identical(arms$Nodes, c(31L, 61L, 31L, 61L, 31L, 61L))
  expect_false(anyDuplicated(arms$ArmId) > 0L)
  expect_true(all(grepl("^[[:xdigit:]]{64}$", arms$CommandSHA256)))
  expect_true(all(grepl("^[[:xdigit:]]{64}$", arms$InputSHA256)))
  expect_identical(length(unique(arms$InputSHA256)), 2L)
  expect_identical(nrow(dimensions), 6L)
  expect_true(all(dimensions$RaterDimension[dimensions$Family != "Binary"]))
  expect_true(all(dimensions$CriterionDimension[dimensions$Family != "Binary"]))
  expect_identical(
    dimensions$ExpectedFreeDimension, c(8L, 8L, 7L, 7L, 9L, 9L)
  )
  expect_true(dimension_status$estimand_coverage_ok)
  expect_true(dimension_status$hash_frozen)
  expect_true(dimension_status$model_dimension_ready)
  expect_identical(nrow(outputs), 50L)
  expect_false(anyDuplicated(outputs$RelativePath) > 0L)
  expect_true(all(outputs$ExpectedAbsentAtBinding))
  expect_identical(
    hashes$Bundle,
    c("command", "input", "model_dimension", "expected_empty_outputs")
  )
  expect_identical(hashes$SHA256, hashes$ExpectedSHA256)
  expect_identical(
    hashes$SHA256,
    c(
      "bc0a3cce17f536306c09dc2883d30c1c2852cbff636a40bafe32fede36268fd7",
      "cd595bc5a914297ea57f13b1f1fc5d8e6d4d9baacd3f7cadcf380a62806fddcb",
      "12dafad2ac6e622288717ec60062f1eeb42c159db253dd46757834335b9e40f5",
      "161488319712d87f720ef6dce8b1a3b5ae1dd0c2e40eea3897189655870d6d8a"
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
  expect_true(status$model_dimension$model_dimension_ready)
  expect_identical(binding$CandidateId, env$mfrmr_cq_cb_candidate_id)
  expect_identical(binding$SourceCommit, env$mfrmr_cq_cb_source_commit)
  expect_identical(
    binding$SourceTreeSHA256, env$mfrmr_cq_cb_source_tree_sha256
  )
  expect_identical(
    binding$ModelDimensionBundleSHA256,
    env$mfrmr_cq_cb_model_dimension_bundle_sha256
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
    "corrected_many_facet_candidate_reference_and_execution_preflight_pending"
  )
  expect_identical(
    review$numerical_reference_state,
    "pending_corrected_candidate_preflight"
  )
  expect_false(review$inference_readiness_required_for_numerical_reference)
  expect_false(review$opened_calibration_reclassification_authorized)
  expect_false(review$hidden_solution_equivalence_eligible)
  expect_false(review$scientific_equivalence_inferred)
  expect_false(review$confirmation_authorized)
})

test_that("the pre-binding source tree is hash-bound when git is available", {
  ctx <- load_conquest_six_arm_candidate_binding()
  source <- ctx$env$mfrmr_cq_cb_source_status(ctx$root)

  expect_identical(
    source$ExpectedCommit, "8ee7958f7af08141df156b333fe1fc732e2b2bc6"
  )
  expect_identical(
    source$ExpectedTreeSHA256,
    "d435e745130fd4eaded7898b31504f1fced8af9e6ac12ff13f43a437dfb48bd9"
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
    expect_true(audit$all_model_dimensions_ready)
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

test_that("candidate 001 is invalidated by its item-only polytomous models", {
  ctx <- load_conquest_six_arm_candidate_binding()
  old_root <- file.path(
    ctx$root, "validation-results/conquest-six-arm-candidate-001-core"
  )
  review <- ctx$env$mfrmr_cq_cb_invalid_candidate_review(
    if (dir.exists(old_root)) old_root else NULL
  )

  expect_identical(review$status, "invalid_model_dimension_contract")
  expect_identical(
    review$registry$InvalidReason,
    "rsm_pcm_item_only_model_dimension_mismatch"
  )
  expect_false(review$registry$RaterDimensionPresent)
  expect_false(review$registry$CriterionDimensionPresent)
  expect_false(review$registry$FrozenToleranceEstimandsCovered)
  expect_false(review$candidate_binding_ready)
  expect_false(review$candidate_execution_authorized)
  expect_false(review$scientific_equivalence_inferred)
  if (dir.exists(old_root)) {
    expect_identical(
      unname(review$observed_model_statements),
      c(
        "model item + step;", "model item + step;",
        "model item + item*step;", "model item + item*step;"
      )
    )
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
  expect_false(audit$all_model_dimensions_ready)
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
    ctx$env$mfrmr_cq_cb_model_dimension_bundle_sha256,
    ctx$env$mfrmr_cq_cb_expected_empty_outputs_sha256,
    ctx$env$mfrmr_cq_cb_execution_hold_reason,
    ctx$env$mfrmr_cq_cb_invalid_candidate_id,
    ctx$env$mfrmr_cq_cb_invalid_candidate_reason
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("CandidateExecutionAuthorized.*FALSE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
})
