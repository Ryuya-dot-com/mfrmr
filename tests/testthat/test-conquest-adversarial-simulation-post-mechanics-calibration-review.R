load_conquest_adversarial_simulation_post_mechanics_review <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-adversarial-simulation-program-0.2.3.R",
    "conquest-adversarial-simulation-template-contract-0.2.3.R",
    "conquest-adversarial-simulation-dgp-oracle-contract-0.2.3.R",
    "conquest-adversarial-simulation-smoke-authorization-0.2.3.R",
    "conquest-adversarial-simulation-smoke-execution-0.2.3.R",
    "conquest-adversarial-simulation-calibration-freeze-0.2.3.R",
    "conquest-adversarial-simulation-engine-mechanics-authorization-0.2.3.R",
    "conquest-adversarial-simulation-engine-mechanics-harness-0.2.3.R",
    "conquest-adversarial-simulation-post-mechanics-calibration-review-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G4R files are excluded.")
  pkgload::load_all(root, quiet = TRUE)
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  output <- file.path(
    root, "validation-results", env$mfrmr_cq_amea_output_basename
  )
  skip_if_not(dir.exists(output), "The retained run-once G4X output is absent.")
  list(root = root, validation = validation, paths = paths, env = env,
       output = output)
}

test_that("G4R reconstructs categorical readiness without numeric agreement", {
  ctx <- load_conquest_adversarial_simulation_post_mechanics_review()
  observed <- ctx$env$mfrmr_cq_amcr_readiness_audit(ctx$output)
  readiness <- observed$readiness

  expect_true(observed$mechanics$mechanics_gate_met)
  expect_identical(nrow(readiness), 16L)
  expect_identical(
    as.integer(table(factor(readiness$Family, levels = c("RSM", "PCM")))),
    c(8L, 8L)
  )
  expect_identical(sum(readiness$RepresentationId == "explicit_missing"), 2L)
  expect_true(all(readiness$ParseableResult))
  expect_true(all(readiness$ModelIdentityMatch))
  expect_true(all(
    readiness$ExpectedFreeDimension == readiness$ObservedFreeDimension
  ))
  expect_true(all(readiness$Converged))
  expect_true(all(readiness$Model == readiness$Family))
  expect_true(all(readiness$ICQuadraturePoints == 61L))
  expect_true(all(readiness$MMLEngineRequested == "direct"))
  expect_true(all(readiness$MMLEngineUsed == "direct"))
  expect_true(all(readiness$ConvergenceCode == 0L))
  expect_true(all(readiness$ConvergenceSeverity == "pass"))
  expect_false(any(readiness$ReviewableWarning))
  expect_false(any(readiness$InferenceReady))
  expect_true(all(readiness$EstimabilityState == "not_evaluated"))
  expect_false(any(readiness$NumericEstimateFieldMaterialized))
  expect_false(any(readiness$CrossEngineDifferenceComputed))
})

test_that("six frozen numeric metrics have a zero mfrmr success lane", {
  env <- load_conquest_adversarial_simulation_post_mechanics_review()$env
  audit <- env$mfrmr_cq_amcr_metric_denominator_audit()
  blocked <- audit$metric[
    audit$metric$MfrmrOrJointLaneBlockedUnderCurrentTerminalSemantics,
  ]

  expect_identical(nrow(blocked), 6L)
  expect_true(all(blocked$RequiresSuccessfulOrJointNumericFit))
  expect_true(all(blocked$DiagnosticEligibilityAddendumRequired))
  expect_false(any(blocked$InferenceReadyMayBeRelabelled))
  expect_true(audit$representation_numeric_blocked)
  expect_true(audit$zero_mfrmr_complete_numeric_outcomes_observed)
  expect_false(audit$numeric_agreement_inspected)
})

test_that("working-tree MML variance makes the readiness hold reachable", {
  ctx <- load_conquest_adversarial_simulation_post_mechanics_review()
  mechanics <- ctx$env$mfrmr_cq_ameh_review_execution(ctx$output)
  reachability <- ctx$env$mfrmr_cq_amcr_readiness_reachability(mechanics)

  expect_identical(reachability$Family, c("RSM", "PCM"))
  expect_true(all(reachability$LogSigma2FreeCoordinates == 1L))
  expect_true(all(grepl(
    "log_sigma2", reachability$NonlinearBlocks, fixed = TRUE
  )))
  expect_false(any(reachability$PreFitEstimabilityComplete))
  expect_true(all(reachability$DerivedFitReadiness == "review"))
  expect_false(any(reachability$DerivedInferenceReady))
  expect_false(any(reachability$NumericAgreementInspected))
})

test_that("G4R holds calibration and chooses a bounded next contract", {
  ctx <- load_conquest_adversarial_simulation_post_mechanics_review()
  review <- ctx$env$mfrmr_cq_amcr_review(ctx$output)

  expect_identical(
    review$status,
    "ASP_G4R_calibration_hold_diagnostic_eligibility_addendum_required"
  )
  expect_true(review$mechanics_gate_met)
  expect_identical(review$mfrmr_complete_numeric_outcomes, 0L)
  expect_identical(
    review$frozen_numeric_metrics_with_mfrmr_or_joint_lane_blocked, 6L
  )
  expect_true(review$representation_numeric_summary_blocked)
  expect_true(review$calibration_partially_informative_for_counts_and_resources)
  expect_false(review$calibration_informative_for_frozen_numeric_objective)
  expect_true(review$diagnostic_numeric_eligibility_addendum_required)
  expect_false(review$calibration_response_generation_authorized)
  expect_false(review$calibration_execution_authorized)
  expect_false(review$rerun_engine_mechanics_authorized)
  expect_false(review$numeric_agreement_inspected)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_identical(
    review$next_action,
    "ASP-G4N-DIAGNOSTIC-NUMERIC-ELIGIBILITY-ADDENDUM"
  )

  option <- review$option_registry
  recommended <- option$OptionId[
    option$Decision == "recommended_next_bounded_contract"
  ]
  expect_identical(
    recommended, "freeze_separate_diagnostic_numeric_eligibility"
  )
  expect_false(any(option$CalibrationExecutionAuthorized))
})

test_that("G4N addendum checklist cannot authorize calibration by itself", {
  env <- load_conquest_adversarial_simulation_post_mechanics_review()$env
  checklist <- env$mfrmr_cq_amcr_addendum_checklist()

  expect_identical(nrow(checklist), 12L)
  expect_identical(checklist$CheckOrder, 1:12)
  expect_true(all(checklist$RequiredBeforeCalibrationGeneration))
  expect_false(any(checklist$Complete))
  expect_false(any(checklist$NumericAgreementInspectionRequired))
  expect_false(any(checklist$MayChangeInferenceReady))
  expect_false(any(checklist$MayAuthorizeExecutionAlone))
})

test_that("G4R cannot read estimates or launch an engine", {
  ctx <- load_conquest_adversarial_simulation_post_mechanics_review()
  source <- paste(readLines(ctx$paths[12L], warn = FALSE), collapse = "\n")

  expect_false(grepl("readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2?\\s*\\(", source, perl = TRUE))
  expect_false(grepl(
    "_mfrmr_(population|facets|steps)[.]csv", source, perl = TRUE
  ))
  expect_false(grepl("_conquest_(parameters|amatrix|covariance)", source))
  expect_match(source, "colClasses = column_class", fixed = TRUE)
  expect_match(source, "rep(\"NULL\", ncol(header))", fixed = TRUE)
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("G4R record and internal roadmap retain the calibration hold", {
  ctx <- load_conquest_adversarial_simulation_post_mechanics_review()
  record <- paste(readLines(file.path(
    ctx$validation,
    paste0(
      "conquest-adversarial-simulation-post-mechanics-",
      "calibration-review-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_amcr_specification, fixed = TRUE)
  expect_match(record, "`CalibrationExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "`MfrmrCompleteNumericOutcomes=0`", fixed = TRUE)
  expect_match(
    roadmap, "[x] Complete G4R post-mechanics calibration review",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Freeze the G4N diagnostic-numeric-eligibility addendum",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Complete the G4A tranche-A authorization review",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Freeze the G4C tranche-A calibration harness",
    fixed = TRUE
  )
})
