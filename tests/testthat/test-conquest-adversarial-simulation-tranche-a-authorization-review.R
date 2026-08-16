load_conquest_adversarial_simulation_tranche_a_authorization_review <-
  function() {
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
      "conquest-adversarial-simulation-post-mechanics-calibration-review-0.2.3.R",
      paste0(
        "conquest-adversarial-simulation-diagnostic-numeric-",
        "eligibility-addendum-0.2.3.R"
      ),
      "conquest-adversarial-simulation-tranche-a-authorization-review-0.2.3.R"
    ))
    skip_if_not(all(file.exists(paths)), "ConQuest ASP G4A files are excluded.")
    pkgload::load_all(root, quiet = TRUE)
    env <- new.env(parent = globalenv())
    for (path in paths) sys.source(path, envir = env)
    g4x_output <- file.path(
      root, "validation-results", env$mfrmr_cq_amea_output_basename
    )
    calibration_output <- file.path(
      root, "validation-results", env$mfrmr_cq_ataa_output_basename
    )
    skip_if_not(
      dir.exists(g4x_output), "The retained run-once G4X output is absent."
    )
    list(
      root = root, validation = validation, paths = paths, env = env,
      g4x_output = g4x_output, calibration_output = calibration_output
    )
  }

test_that("G4A binds the exact unopened tranche-A denominator", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  audit <- ctx$env$mfrmr_cq_ataa_identity_audit(
    ctx$g4x_output, ctx$calibration_output
  )
  seed <- audit$tranche_seed_registry
  workload <- audit$tranche_workload
  budget <- audit$tranche_budget

  expect_true(audit$frozen_identity_complete)
  expect_identical(nrow(seed), 90L)
  expect_identical(sum(seed$PrimaryQ61FitRequired), 70L)
  expect_identical(
    sum(seed$ExpectedStructuralDisposition ==
          "reject_before_numeric_comparison"),
    20L
  )
  expect_identical(sum(seed$PairedRepresentationComparisonRequired), 10L)
  expect_identical(sum(seed$SelectiveQ121FitRequired), 20L)
  expect_false(any(seed$Generated))
  expect_false(any(seed$ResultOpened))
  expect_identical(nrow(workload), 8L)
  expect_identical(sum(workload$PlannedAttemptCount), 190L)
  expect_identical(sum(workload$Engine == "mfrmr" & workload$Nodes == 61L), 2L)
  expect_identical(sum(
    workload$PlannedAttemptCount[workload$Engine == "mfrmr"]
  ), 100L)
  expect_identical(sum(
    workload$PlannedAttemptCount[workload$Engine == "ConQuest"]
  ), 90L)
  expect_identical(budget$ScheduledOutcomeRowCap, 230L)
  expect_true(audit$output_boundary$BasenameMatches)
  expect_true(audit$output_boundary$OutputTargetAbsent)
  expect_false(audit$response_generation_observed)
  expect_false(audit$numeric_agreement_inspected)
})

test_that("G4A values calibration but forbids precision inflation", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  value <- ctx$env$mfrmr_cq_ataa_information_value_registry()

  expect_identical(nrow(value), 8L)
  expect_identical(
    sum(value$Decision == "supports_bounded_calibration"), 4L
  )
  expect_identical(
    value$Decision[value$QuestionId == "five_replicates_per_arm_precision"],
    "diagnostic_only_not_precision_or_threshold_setting"
  )
  expect_identical(
    value$Decision[value$QuestionId ==
                     "independent_third_party_recalculation"],
    "not_a_prerequisite"
  )
  expect_identical(
    value$Decision[value$QuestionId ==
                     "execution_without_calibration_harness"],
    "blocks_generation_and_execution"
  )
  expect_false(any(value$MaySetThresholdOrConfirmationRule))
  expect_false(any(value$MaySupportPublicClaim))
  expect_false(any(value$NumericAgreementInspected))
})

test_that("G4X resources support only a preliminary feasibility inference", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  identity <- ctx$env$mfrmr_cq_ataa_identity_audit(
    ctx$g4x_output, ctx$calibration_output
  )
  resource <- ctx$env$mfrmr_cq_ataa_resource_audit(identity)

  expect_identical(resource$G4XObservedAttempts, 30L)
  expect_identical(resource$TrancheAPlannedAttempts, 190L)
  expect_equal(resource$G4XObservedElapsedSeconds, 26.487, tolerance = 1e-12)
  expect_equal(
    resource$SimpleLinearElapsedProjectionSeconds, 167.751,
    tolerance = 1e-12
  )
  expect_equal(resource$SimpleLinearStorageProjectionBytes, 73160608.3333333)
  expect_true(resource$GlobalCapRequired)
  expect_false(resource$Q121MechanicsObserved)
  expect_false(resource$DatasetGenerationCostObserved)
  expect_false(resource$CalibrationScenarioTailRuntimeObserved)
  expect_true(resource$ResourceFeasibilityPreliminary)
  expect_false(resource$ResourceEvidenceSufficientForExecutionAuthorization)
  expect_false(resource$NumericAgreementInspected)
})

test_that("G4A identifies thirteen integrated harness capabilities as missing", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  capability <- ctx$env$mfrmr_cq_ataa_harness_capability_registry()

  expect_identical(nrow(capability), 18L)
  expect_identical(sum(capability$ProviderAvailable), 5L)
  expect_identical(sum(!capability$ProviderAvailable), 13L)
  expect_true(all(capability$ProviderAvailable[1:5]))
  expect_false(any(capability$ProviderAvailable[6:18]))
  expect_identical(sum(capability$RequiredBeforeResponseGeneration), 7L)
  expect_identical(sum(capability$RequiredBeforeLiveExecution), 13L)
  expect_false(any(capability$MayBeSatisfiedByG4HAlone))
  expect_false(any(capability$ExecutionAuthorizedByCapability))
})

test_that("a same-named fake provider cannot satisfy the harness boundary", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  available <- ctx$env$mfrmr_cq_ataa_provider_available
  assign(
    "mfrmr_cq_ach_generate_dataset", function(...) NULL,
    envir = ctx$env
  )

  expect_false(available(
    "mfrmr_cq_ach_generate_dataset", "mfrmr_cq_ach_contract",
    "mfrmr_conquest_adversarial_simulation_calibration_harness_v1"
  ))
  assign("mfrmr_cq_ach_contract", "wrong_contract", envir = ctx$env)
  expect_false(available(
    "mfrmr_cq_ach_generate_dataset", "mfrmr_cq_ach_contract",
    "mfrmr_conquest_adversarial_simulation_calibration_harness_v1"
  ))
  assign(
    "mfrmr_cq_ach_contract",
    "mfrmr_conquest_adversarial_simulation_calibration_harness_v1",
    envir = ctx$env
  )
  expect_true(available(
    "mfrmr_cq_ach_generate_dataset", "mfrmr_cq_ach_contract",
    "mfrmr_conquest_adversarial_simulation_calibration_harness_v1"
  ))
  capability <- ctx$env$mfrmr_cq_ataa_harness_capability_registry()
  expect_identical(sum(capability$ProviderAvailable), 6L)
  expect_identical(sum(!capability$ProviderAvailable), 12L)
  expect_false(all(capability$ProviderAvailable))
})

test_that("existing output and elapsed runtime window fail closed", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  parent <- withr::local_tempdir()
  existing <- file.path(parent, ctx$env$mfrmr_cq_ataa_output_basename)
  dir.create(existing)
  boundary <- ctx$env$mfrmr_cq_ataa_output_boundary(existing)

  expect_true(boundary$BasenameMatches)
  expect_false(boundary$OutputTargetAbsent)
  expect_false(boundary$ExistingTargetMayBeReused)
  expect_false(boundary$OverwritePermitted)
  expect_error(
    ctx$env$mfrmr_cq_ataa_identity_audit(ctx$g4x_output, existing),
    "output boundary drifted",
    fixed = TRUE
  )

  late <- ctx$env$mfrmr_cq_ataa_review(
    ctx$g4x_output, ctx$calibration_output, as.Date("2026-09-01")
  )
  expect_identical(
    late$status, "ASP_G4A_hold_identity_value_resource_or_boundary_invalid"
  )
  expect_false(late$resource_feasibility_preliminary)
  expect_false(late$calibration_response_generation_authorized)
  expect_false(late$calibration_execution_authorized)
})

test_that("G4A authorizes harness work but no data generation or execution", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  review <- ctx$env$mfrmr_cq_ataa_review(
    ctx$g4x_output, ctx$calibration_output
  )

  expect_identical(
    review$status,
    paste0(
      "ASP_G4A_scientific_value_retained_execution_hold_",
      "harness_freeze_required"
    )
  )
  expect_true(review$scientific_value_gate_met)
  expect_true(review$information_gain_exceeds_harness_investment)
  expect_false(review$tranche_A_precision_or_threshold_claim_supported)
  expect_true(review$resource_feasibility_preliminary)
  expect_false(review$resource_evidence_sufficient_for_execution)
  expect_identical(review$harness_capabilities_available, 5L)
  expect_identical(review$harness_capabilities_missing, 13L)
  expect_false(review$calibration_harness_ready)
  expect_true(review$calibration_harness_implementation_authorized)
  expect_false(review$calibration_response_generation_authorized)
  expect_false(review$calibration_execution_authorized)
  expect_false(review$fresh_tranche_A_sentinel_observed)
  expect_false(review$numeric_agreement_inspected)
  expect_false(review$confirmation_use_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_identical(
    review$next_action, "ASP-G4C-TRANCHE-A-HARNESS-FREEZE"
  )
})

test_that("G4A cannot generate responses, fit models, or launch ConQuest", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  source <- paste(readLines(ctx$paths[14L], warn = FALSE), collapse = "\n")

  expect_false(grepl("rnorm\\s*\\(|sample\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2?\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("G4A record remains historical after the G4C harness freeze", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_authorization_review()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-tranche-a-authorization-review-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_ataa_specification, fixed = TRUE)
  expect_match(record, "`CalibrationExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "`HarnessCapabilitiesMissing=13`", fixed = TRUE)
  expect_match(
    roadmap, "[x] Complete the G4A tranche-A authorization review",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Freeze the G4C tranche-A calibration harness",
    fixed = TRUE
  )
})
