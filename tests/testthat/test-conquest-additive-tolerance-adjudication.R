test_that("opened ConQuest calibration cannot freeze its own tolerances", {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  validation_dir <- candidates[dir.exists(candidates)][1]
  testthat::skip_if(
    length(validation_dir) == 0L || is.na(validation_dir),
    "Repository-only validation files are not installed with the package."
  )
  env <- new.env(parent = globalenv())
  sys.source(
    file.path(
      validation_dir,
      "conquest-additive-tolerance-adjudication-0.2.3.R"
    ),
    envir = env
  )
  review <- list(
    decision =
      "four_arm_native_outputs_ready_tolerance_and_candidate_missing",
    four_arms_complete = TRUE,
    complete_console_transcripts = TRUE,
    native_design_matrices_exact = TRUE,
    q31_q61_printed_final_coordinates_identical = TRUE,
    raw_token_status =
      "raw_tokens_retained_rounding_unestablished",
    acceptance_threshold_specified = FALSE,
    candidate_bound = FALSE,
    comparison_ready = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE
  )

  audit <- env$mfrmr_adjudicate_conquest_additive_tolerance(review)
  expect_s3_class(audit, "mfrmr_conquest_tolerance_adjudication")
  expect_identical(audit$decision, "hold_no_post_hoc_tolerance_freeze")
  expect_true(audit$calibration_results_opened)
  expect_false(audit$official_file_rounding_rule_established)
  expect_false(audit$internal_handoff_tolerance_is_export_resolution)
  expect_false(audit$internal_handoff_tolerance_is_ext_cq_tol)
  expect_true(audit$calibration_may_inform_future_tolerance)
  expect_false(audit$calibration_may_pass_its_own_new_tolerance)
  expect_false(audit$package_manual_cross_engine_tolerance_found)
  expect_identical(
    audit$tolerance_source_audit_id,
    "conquest-tam-immer-tolerance-source-audit-20260811-v1"
  )
  expect_false(audit$ext_cq_tolerance_frozen)
  expect_false(audit$ic_integration_tolerance_frozen)
  expect_true(audit$broad_external_claim_retained_as_future_gate)
  expect_identical(audit$current_public_claim, "descriptive_calibration_only")
  expect_false(audit$candidate_run_authorized)
  expect_false(audit$sparse_extension_authorized)
  expect_false(audit$large_simulation_authorized)
  expect_identical(
    audit$layer_review$Layer,
    c(
      "representation", "optimizer", "integration",
      "scientific_acceptance", "candidate_binding"
    )
  )
  expect_true(all(!audit$layer_review$ReleaseGatePassed))
  expect_identical(nrow(audit$gate_requirements), 10L)
  expect_true(all(audit$gate_requirements$RequiredForEquivalence))
})

test_that("adjudication rejects a silently promoted four-arm review", {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  validation_dir <- candidates[dir.exists(candidates)][1]
  testthat::skip_if(
    length(validation_dir) == 0L || is.na(validation_dir),
    "Repository-only validation files are not installed with the package."
  )
  env <- new.env(parent = globalenv())
  sys.source(
    file.path(
      validation_dir,
      "conquest-additive-tolerance-adjudication-0.2.3.R"
    ),
    envir = env
  )
  promoted <- list(
    decision =
      "four_arm_native_outputs_ready_tolerance_and_candidate_missing",
    four_arms_complete = TRUE,
    complete_console_transcripts = TRUE,
    native_design_matrices_exact = TRUE,
    q31_q61_printed_final_coordinates_identical = TRUE,
    raw_token_status =
      "raw_tokens_retained_rounding_unestablished",
    acceptance_threshold_specified = TRUE,
    candidate_bound = FALSE,
    comparison_ready = TRUE,
    scientific_equivalence_inferred = TRUE,
    confirmation_authorized = FALSE
  )
  expect_error(
    env$mfrmr_adjudicate_conquest_additive_tolerance(promoted),
    "unknown-rounding, no-threshold, and no-candidate state",
    fixed = TRUE
  )
})
