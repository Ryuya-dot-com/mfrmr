load_conquest_prospective_tolerance_contract <- function() {
  skip_if_not_installed("digest")
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  validation <- candidates[dir.exists(candidates)][1L]
  skip_if(
    length(validation) == 0L || is.na(validation),
    "Repository-only ConQuest tolerance files are unavailable."
  )
  env <- new.env(parent = globalenv())
  path <- file.path(
    validation, "conquest-prospective-tolerance-contract-0.2.3.R"
  )
  skip_if_not(file.exists(path), "Prospective ConQuest contract is excluded.")
  sys.source(path, envir = env)
  env
}

complete_conquest_prospective_tolerances <- function(env) {
  out <- env$mfrmr_cq_ptc_tolerance_template()
  out$SignedLower <- -1e-4
  out$SignedUpper <- 1e-4
  out$AbsoluteTolerance <- 1e-4
  out$RationaleType <- "opened_calibration_future_candidate_only"
  out$Rationale <- paste(
    "Prospective engineering error budget for a new candidate;",
    "the opened calibration remains ineligible."
  )
  out$SourceArtifact <-
    "inst/validation/conquest-additive-tolerance-adjudication-0.2.3.md"
  out$SourceSHA256 <- paste(rep("a", 64L), collapse = "")
  out$CalibrationInformed <- TRUE
  out$OpenedCalibrationEligible <- FALSE
  out$Frozen <- TRUE
  out
}

complete_conquest_prospective_binding <- function(env, tolerances) {
  out <- env$mfrmr_cq_ptc_binding_template()
  out$CandidateId <- "mfrmr-0.2.3-candidate-001"
  out$SourceCommit <- paste(rep("b", 40L), collapse = "")
  out$SourceTreeSHA256 <- paste(rep("c", 64L), collapse = "")
  out$CommandBundleSHA256 <- paste(rep("d", 64L), collapse = "")
  out$InputBundleSHA256 <- paste(rep("e", 64L), collapse = "")
  out$ExpectedEmptyOutputsSHA256 <- paste(rep("f", 64L), collapse = "")
  out$CandidateFamilies <- env$mfrmr_cq_ptc_candidate_families
  out$CandidateQuadratureNodes <- env$mfrmr_cq_ptc_candidate_nodes
  out$CandidateArmCount <- env$mfrmr_cq_ptc_candidate_arm_count
  out$NormalizerCoverageFamilies <- env$mfrmr_cq_ptc_candidate_families
  out$NormalizerCoverageRegistrySHA256 <-
    env$mfrmr_cq_ptc_normalizer_coverage_registry_sha256
  out$SourcePrecisionPolicyId <-
    env$mfrmr_cq_ptc_source_precision_policy_id
  out$SourcePrecisionScope <- env$mfrmr_cq_ptc_source_precision_scope
  out$SourcePrecisionCoverageFamilies <-
    env$mfrmr_cq_ptc_candidate_families
  out$SourcePrecisionCoverageRegistrySHA256 <-
    env$mfrmr_cq_ptc_source_precision_coverage_registry_sha256
  out$SourcePrecisionPolicySHA256 <- paste(rep("1", 64L), collapse = "")
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

test_that("prospective ConQuest registry covers both numerical criteria", {
  env <- load_conquest_prospective_tolerance_contract()
  registry <- env$mfrmr_cq_ptc_estimand_registry()
  template <- env$mfrmr_cq_ptc_tolerance_template()

  expect_identical(nrow(registry), 57L)
  expect_identical(sum(registry$CriterionId == "EXT-CQ-TOL"), 19L)
  expect_identical(sum(registry$CriterionId == "IC-INTEGRATION-TOL"), 38L)
  expect_setequal(registry$Engine, c("cross_engine", "ConQuest", "mfrmr"))
  expect_setequal(registry$Family, c("Binary", "RSM", "PCM"))
  expect_setequal(
    registry$EstimandClass[registry$Family == "Binary"],
    c(
      "population_intercept", "population_slope", "population_variance",
      "item_difficulty", "objective"
    )
  )
  expect_false(anyDuplicated(registry$ToleranceRowId) > 0L)
  expect_true(all(is.na(template$SignedLower)))
  expect_true(all(is.na(template$AbsoluteTolerance)))
  expect_true(all(!template$Frozen))

  binding <- env$mfrmr_cq_ptc_binding_template()
  preflight <- env$mfrmr_cq_prospective_tolerance_preflight(template, binding)
  expect_identical(preflight$status, "pilot_required")
  expect_identical(
    preflight$decision, "hold_tolerance_or_candidate_binding_incomplete"
  )
  expect_false(preflight$all_tolerance_rows_ready)
  expect_false(preflight$candidate_binding_ready)
})

test_that("a complete future freeze authorizes only the small candidate core", {
  env <- load_conquest_prospective_tolerance_contract()
  tolerances <- complete_conquest_prospective_tolerances(env)
  binding <- complete_conquest_prospective_binding(env, tolerances)
  preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, binding
  )

  expect_s3_class(
    preflight, "mfrmr_conquest_prospective_tolerance_preflight"
  )
  expect_identical(preflight$status, "prospective_freeze_structurally_ready")
  expect_identical(
    preflight$decision, "candidate_core_run_structurally_authorized"
  )
  expect_true(preflight$tolerance_schema_ok)
  expect_true(preflight$tolerance_identity_ok)
  expect_true(preflight$all_tolerance_rows_ready)
  expect_true(preflight$candidate_binding_ready)
  expect_identical(preflight$required_candidate_families, "Binary;RSM;PCM")
  expect_identical(preflight$required_candidate_nodes, "31;61")
  expect_identical(preflight$required_candidate_arms, 6L)
  expect_true(all(preflight$row_review$RowReady))
  expect_true(all(unlist(preflight$binding_review, use.names = FALSE)))
  expect_match(preflight$tolerance_table_sha256, "^[[:xdigit:]]{64}$")
  expect_false(preflight$opened_calibration_reclassification_authorized)
  expect_false(preflight$scientific_equivalence_inferred)
  expect_false(preflight$confirmation_authorized)
  expect_false(preflight$sparse_extension_authorized)
  expect_false(preflight$large_simulation_authorized)
})

test_that("opened calibration can inform but cannot pass its new rule", {
  env <- load_conquest_prospective_tolerance_contract()
  tolerances <- complete_conquest_prospective_tolerances(env)
  binding <- complete_conquest_prospective_binding(env, tolerances)

  self_pass <- tolerances
  self_pass$OpenedCalibrationEligible[1L] <- TRUE
  self_binding <- complete_conquest_prospective_binding(env, self_pass)
  rejected_row <- env$mfrmr_cq_prospective_tolerance_preflight(
    self_pass, self_binding
  )
  expect_identical(rejected_row$status, "pilot_required")
  expect_false(rejected_row$all_tolerance_rows_ready)
  expect_false(rejected_row$row_review$OpenedCalibrationIneligible[1L])
  expect_false(rejected_row$opened_calibration_reclassification_authorized)

  promoted_binding <- binding
  promoted_binding$CalibrationCanPassNewRule <- TRUE
  rejected_binding <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, promoted_binding
  )
  expect_false(rejected_binding$candidate_binding_ready)
  expect_false(
    rejected_binding$binding_review$CalibrationCannotPassNewRule
  )
})

test_that("candidate output timing and tolerance hash fail closed", {
  env <- load_conquest_prospective_tolerance_contract()
  tolerances <- complete_conquest_prospective_tolerances(env)
  binding <- complete_conquest_prospective_binding(env, tolerances)

  opened <- binding
  opened$CandidateOutputsPresentAtFreeze <- TRUE
  opened$CandidateOutputsOpenedAtFreeze <- TRUE
  opened_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, opened
  )
  expect_false(opened_preflight$candidate_binding_ready)
  expect_false(opened_preflight$binding_review$OutputsAbsentAtFreeze)
  expect_false(opened_preflight$binding_review$OutputsUnopenedAtFreeze)

  malformed <- binding
  malformed$CandidateOutputsOpenedAtFreeze <- "FALSE"
  malformed_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, malformed
  )
  expect_false(malformed_preflight$candidate_binding_ready)
  expect_false(malformed_preflight$binding_review$OutputsUnopenedAtFreeze)

  no_precision <- binding
  no_precision$SourcePrecisionReady <- FALSE
  precision_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, no_precision
  )
  expect_false(precision_preflight$candidate_binding_ready)
  expect_false(precision_preflight$binding_review$SourcePrecisionReady)

  hidden_scope <- binding
  hidden_scope$SourcePrecisionScope <- "hidden_solution"
  hidden_scope$HiddenSolutionEquivalenceEligible <- TRUE
  hidden_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, hidden_scope
  )
  expect_false(hidden_preflight$candidate_binding_ready)
  expect_false(hidden_preflight$binding_review$SourcePrecisionScopeOK)
  expect_false(hidden_preflight$binding_review$HiddenSolutionNotPromoted)

  generic_policy <- binding
  generic_policy$SourcePrecisionPolicyId <- "cq-raw-token-policy-v1"
  generic_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, generic_policy
  )
  expect_false(generic_preflight$candidate_binding_ready)
  expect_false(generic_preflight$binding_review$SourcePrecisionPolicyIdOK)

  partial_core <- binding
  partial_core$CandidateFamilies <- "RSM;PCM"
  partial_core$CandidateArmCount <- 4L
  partial_core$NormalizerCoverageFamilies <- "RSM;PCM"
  partial_core$SourcePrecisionCoverageFamilies <- "RSM;PCM"
  partial_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, partial_core
  )
  expect_false(partial_preflight$candidate_binding_ready)
  expect_false(partial_preflight$binding_review$CandidateFamiliesComplete)
  expect_false(partial_preflight$binding_review$CandidateArmCountOK)
  expect_false(partial_preflight$binding_review$NormalizerCoverageComplete)
  expect_false(
    partial_preflight$binding_review$SourcePrecisionCoverageComplete
  )

  wrong_coverage <- binding
  wrong_coverage$NormalizerCoverageRegistrySHA256 <-
    paste(rep("9", 64L), collapse = "")
  wrong_coverage$SourcePrecisionCoverageRegistrySHA256 <-
    paste(rep("8", 64L), collapse = "")
  coverage_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, wrong_coverage
  )
  expect_false(coverage_preflight$candidate_binding_ready)
  expect_false(
    coverage_preflight$binding_review$NormalizerCoverageRegistryIdentityOK
  )
  expect_false(
    coverage_preflight$binding_review$SourcePrecisionCoverageRegistryIdentityOK
  )

  wrong_hash <- binding
  wrong_hash$ToleranceTableSHA256 <- paste(rep("0", 64L), collapse = "")
  hash_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    tolerances, wrong_hash
  )
  expect_false(hash_preflight$candidate_binding_ready)
  expect_false(hash_preflight$binding_review$ToleranceHashOK)
})

test_that("registry drift and unsupported tolerance sources are rejected", {
  env <- load_conquest_prospective_tolerance_contract()
  tolerances <- complete_conquest_prospective_tolerances(env)

  missing <- tolerances[-1L, , drop = FALSE]
  missing_binding <- env$mfrmr_cq_ptc_binding_template()
  missing_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    missing, missing_binding
  )
  expect_false(missing_preflight$tolerance_identity_ok)
  expect_false(missing_preflight$all_tolerance_rows_ready)

  bad_source <- tolerances
  bad_source$SourceArtifact[2L] <- "../opened-candidate-output.csv"
  bad_source$RationaleType[3L] <- "optimizer_stopping_tolerance"
  bad_source$CalibrationInformed[3L] <- FALSE
  bad_binding <- complete_conquest_prospective_binding(env, bad_source)
  bad_preflight <- env$mfrmr_cq_prospective_tolerance_preflight(
    bad_source, bad_binding
  )
  expect_false(bad_preflight$all_tolerance_rows_ready)
  expect_false(bad_preflight$row_review$SourceIdentityOK[2L])
  expect_false(bad_preflight$row_review$RationaleOK[3L])
})
