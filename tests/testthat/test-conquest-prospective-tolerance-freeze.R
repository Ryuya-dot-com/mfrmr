load_conquest_prospective_tolerance_freeze <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-prospective-tolerance-contract-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-prospective-tolerance-basis-0.2.3.md"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "Repository-only ConQuest tolerance freeze is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(paths[1L], envir = env)
  sys.source(paths[2L], envir = env)
  list(root = root, validation = validation, env = env)
}

complete_frozen_conquest_binding <- function(env, tolerances) {
  out <- env$mfrmr_cq_ptc_binding_template()
  out$CandidateId <- "future-disjoint-six-arm-fixture"
  out$SourceCommit <- paste(rep("a", 40L), collapse = "")
  out$SourceTreeSHA256 <- paste(rep("b", 64L), collapse = "")
  out$CommandBundleSHA256 <- paste(rep("c", 64L), collapse = "")
  out$InputBundleSHA256 <- paste(rep("d", 64L), collapse = "")
  out$ExpectedEmptyOutputsSHA256 <- paste(rep("e", 64L), collapse = "")
  out$CandidateFamilies <- env$mfrmr_cq_ptc_candidate_families
  out$CandidateQuadratureNodes <- env$mfrmr_cq_ptc_candidate_nodes
  out$CandidateArmCount <- env$mfrmr_cq_ptc_candidate_arm_count
  out$NormalizerCoverageFamilies <- env$mfrmr_cq_ptc_candidate_families
  out$NormalizerCoverageRegistrySHA256 <-
    env$mfrmr_cq_ptc_normalizer_coverage_registry_sha256
  out$SourcePrecisionPolicyId <- env$mfrmr_cq_ptc_source_precision_policy_id
  out$SourcePrecisionScope <- env$mfrmr_cq_ptc_source_precision_scope
  out$SourcePrecisionCoverageFamilies <- env$mfrmr_cq_ptc_candidate_families
  out$SourcePrecisionCoverageRegistrySHA256 <-
    env$mfrmr_cq_ptc_source_precision_coverage_registry_sha256
  out$SourcePrecisionPolicySHA256 <- paste(rep("f", 64L), collapse = "")
  out$SourcePrecisionReady <- TRUE
  out$SourcePrecisionIndependentOfCandidateOutput <- TRUE
  out$HiddenSolutionEquivalenceEligible <- FALSE
  out$ToleranceTableSHA256 <- env$mfrmr_cq_ptc_tolerance_sha256(tolerances)
  out$FrozenBeforeCandidateExecution <- TRUE
  out$CandidateOutputsPresentAtFreeze <- FALSE
  out$CandidateOutputsOpenedAtFreeze <- FALSE
  out$CalibrationCanPassNewRule <- FALSE
  out
}

test_that("future-only ConQuest budgets are typed and source-bound", {
  env <- load_conquest_prospective_tolerance_freeze()$env
  basis <- env$mfrmr_cq_ptf_basis_status()
  budget <- env$mfrmr_cq_ptf_budget_registry()

  expect_true(basis$IdentityOK)
  expect_identical(
    basis$ActualSHA256,
    "9b4c76add31061dcee532fcf2528e2614bd151dca75d3792fbde5364361279bd"
  )
  expect_identical(nrow(budget), 4L)
  expect_false(anyDuplicated(budget$BudgetId) > 0L)
  expect_identical(
    budget$AbsoluteTolerance,
    c(1e-5, 2e-6, 2e-6, 2e-6)
  )
  expect_identical(budget$SignedLower, -budget$SignedUpper)
  expect_true(all(
    budget$RationaleType == "opened_calibration_future_candidate_only"
  ))
  expect_true(all(budget$CalibrationInformed))
  expect_false(any(budget$OpenedCalibrationEligible))
  expect_true(all(budget$Frozen))
})

test_that("all 57 ConQuest tolerance rows are canonically frozen", {
  env <- load_conquest_prospective_tolerance_freeze()$env
  tolerance <- env$mfrmr_cq_ptf_build_tolerances()
  review <- env$mfrmr_cq_ptf_validate_tolerances(tolerance)

  expect_identical(nrow(tolerance), 57L)
  expect_identical(sum(tolerance$CriterionId == "EXT-CQ-TOL"), 19L)
  expect_identical(
    sum(tolerance$CriterionId == "IC-INTEGRATION-TOL"), 38L
  )
  expect_true(all(tolerance$Frozen))
  expect_true(all(tolerance$CalibrationInformed))
  expect_false(any(tolerance$OpenedCalibrationEligible))
  expect_true(all(tolerance$SourceArtifact == env$mfrmr_cq_ptf_basis_artifact))
  expect_true(all(tolerance$SourceSHA256 == env$mfrmr_cq_ptf_basis_sha256))
  expect_identical(
    review$status, "tolerance_table_frozen_candidate_unbound"
  )
  expect_true(review$table_identical)
  expect_true(review$hash_frozen)
  expect_true(review$all_rows_ready)
  expect_identical(
    review$tolerance_table_sha256,
    "64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521"
  )
  expect_false(review$opened_calibration_reclassification_authorized)
  expect_false(review$hidden_solution_equivalence_eligible)
  expect_false(review$scientific_equivalence_inferred)
  expect_false(review$candidate_bound)
  expect_false(review$candidate_execution_authorized)
  expect_false(review$confirmation_authorized)
})

test_that("a frozen tolerance table still requires candidate binding", {
  env <- load_conquest_prospective_tolerance_freeze()$env
  review <- env$mfrmr_cq_ptf_review()

  expect_s3_class(review, "mfrmr_conquest_tolerance_freeze_review")
  expect_identical(
    review$status, "tolerance_frozen_candidate_binding_required"
  )
  expect_true(review$tolerance_frozen)
  expect_false(review$candidate_bound)
  expect_false(review$candidate_core_structurally_authorized)
  expect_false(review$candidate_execution_authorized)
  expect_true(review$preflight$all_tolerance_rows_ready)
  expect_false(review$preflight$candidate_binding_ready)
  expect_identical(review$preflight$status, "pilot_required")
  expect_identical(
    review$preflight$decision,
    "hold_tolerance_or_candidate_binding_incomplete"
  )
  expect_false(review$opened_calibration_reclassification_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_false(review$confirmation_authorized)
})

test_that("a structurally complete future fixture cannot promote equivalence", {
  env <- load_conquest_prospective_tolerance_freeze()$env
  tolerance <- env$mfrmr_cq_ptf_build_tolerances()
  binding <- complete_frozen_conquest_binding(env, tolerance)
  review <- env$mfrmr_cq_ptf_review(binding)

  expect_identical(
    review$status, "tolerance_and_candidate_binding_structurally_ready"
  )
  expect_true(review$tolerance_frozen)
  expect_true(review$candidate_bound)
  expect_true(review$candidate_core_structurally_authorized)
  expect_false(review$candidate_execution_authorized)
  expect_identical(
    review$preflight$decision, "candidate_core_run_structurally_authorized"
  )
  expect_false(review$preflight$scientific_equivalence_inferred)
  expect_false(review$preflight$confirmation_authorized)
  expect_false(review$opened_calibration_reclassification_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_false(review$confirmation_authorized)
})

test_that("tolerance values and calibration eligibility fail closed on mutation", {
  env <- load_conquest_prospective_tolerance_freeze()$env
  tolerance <- env$mfrmr_cq_ptf_build_tolerances()

  changed_value <- tolerance
  changed_value$AbsoluteTolerance[1L] <- 1e-4
  value_review <- env$mfrmr_cq_ptf_validate_tolerances(changed_value)
  expect_identical(value_review$status, "invalid_or_mutated_tolerance_table")
  expect_false(value_review$table_identical)
  expect_false(value_review$hash_frozen)
  expect_false(value_review$all_rows_ready)

  promoted <- tolerance
  promoted$OpenedCalibrationEligible[1L] <- TRUE
  promoted_review <- env$mfrmr_cq_ptf_validate_tolerances(promoted)
  expect_identical(
    promoted_review$status, "invalid_or_mutated_tolerance_table"
  )
  expect_false(promoted_review$row_validation$all_rows_ready)
  expect_false(promoted_review$table_identical)
  expect_false(promoted_review$hash_frozen)
  expect_false(promoted_review$all_rows_ready)

  wrong_source <- tolerance
  wrong_source$SourceSHA256[1L] <- paste(rep("0", 64L), collapse = "")
  source_review <- env$mfrmr_cq_ptf_validate_tolerances(wrong_source)
  expect_identical(
    source_review$status, "invalid_or_mutated_tolerance_table"
  )
  expect_false(source_review$table_identical)
  expect_false(source_review$hash_frozen)
  expect_false(source_review$all_rows_ready)
})

test_that("the tolerance-freeze record is source-bound", {
  ctx <- load_conquest_prospective_tolerance_freeze()
  record_path <- file.path(
    ctx$validation,
    "conquest-prospective-tolerance-freeze-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  artifacts <- file.path(ctx$validation, c(
    "conquest-prospective-tolerance-basis-0.2.3.md",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-prospective-tolerance-contract-0.2.3.R"
  ))
  artifacts <- c(
    artifacts,
    file.path(
      ctx$root, "tests", "testthat",
      c(
        "test-conquest-prospective-tolerance-freeze.R",
        "test-conquest-prospective-tolerance-contract.R"
      )
    )
  )
  hashes <- vapply(artifacts, digest::digest, character(1L),
                   algo = "sha256", file = TRUE, serialize = FALSE)

  expect_true(all(vapply(
    hashes, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl(
    ctx$env$mfrmr_cq_ptf_expected_tolerance_sha256,
    record, fixed = TRUE
  ))
  expect_true(grepl(
    "tolerance_frozen_candidate_binding_required",
    record, fixed = TRUE
  ))
  expect_true(grepl(
    "candidate_execution_authorized = FALSE",
    record, fixed = TRUE
  ))
  expect_true(grepl(
    "ScientificEquivalenceInferred.*FALSE", record
  ))
})
