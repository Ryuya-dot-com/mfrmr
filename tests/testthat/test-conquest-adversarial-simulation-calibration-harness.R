load_conquest_adversarial_simulation_calibration_harness <- function() {
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
    "conquest-adversarial-simulation-tranche-a-authorization-review-0.2.3.R",
    "conquest-adversarial-simulation-calibration-harness-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G4C files are excluded.")
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

test_that("G4C P1 materializes the exact 230-row plan before generation", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  plan <- ctx$env$mfrmr_cq_ach_plan()
  attempted <- plan$AttemptCap == 1L
  negative <- plan$ExpectedStructuralDisposition ==
    "reject_before_numeric_comparison"

  expect_identical(nrow(plan), 230L)
  expect_identical(plan$ScheduledOutcomeOrder, 1:230)
  expect_identical(anyDuplicated(plan$ScheduledOutcomeOrder), 0L)
  expect_identical(length(unique(plan$DatasetId)), 90L)
  expect_identical(length(unique(plan$Seed)), 90L)
  expect_identical(sum(plan$AttemptCap), 190L)
  expect_identical(plan$AttemptOrder[attempted], 1:190)
  expect_true(all(is.na(plan$AttemptOrder[!attempted])))
  expect_identical(sum(attempted & plan$Engine == "mfrmr"), 100L)
  expect_identical(sum(attempted & plan$Engine == "ConQuest"), 90L)
  expect_identical(sum(attempted & plan$Nodes == 61L), 150L)
  expect_identical(sum(attempted & plan$Nodes == 121L), 40L)
  expect_identical(length(unique(plan$DatasetId[negative])), 20L)
  expect_identical(sum(negative), 40L)
  expect_false(any(attempted[negative]))
  expect_true(all(plan$RetainedInUnconditionalDenominator))
  expect_false(any(plan$AutomaticRetryPermitted))
  expect_false(any(plan$PeerFailureMaySuppressAttempt))
  expect_false(any(plan$ResultMayChangeAttemptOrder))
  expect_false(any(plan$ResponseGenerationAuthorizedByPlan))
  expect_false(any(plan$ExecutionAuthorizedByPlan))
  expect_false(any(plan$ConfirmationUsePermitted))
  expect_false(any(plan$PublicClaimPermitted))
})

test_that("dataset row shape follows only frozen paired and q121 roles", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  plan <- ctx$env$mfrmr_cq_ach_plan()
  shape <- table(as.integer(table(plan$DatasetId)))

  expect_identical(
    as.integer(shape[as.character(2:4)]), c(60L, 10L, 20L)
  )
  three <- names(which(table(plan$DatasetId) == 3L))
  four <- names(which(table(plan$DatasetId) == 4L))
  expect_true(all(plan$ScenarioClassId[plan$DatasetId %in% three] ==
                    "ASP-INV-PAIRED-MISSINGNESS"))
  expect_true(all(plan$Nodes[plan$DatasetId %in% four] %in% c(61L, 121L)))
  expect_true(all(plan$PrimaryAnalysisRole[
    plan$RepresentationFitRole == "quadrature_sensitivity"
  ]))
  expect_false(any(plan$PrimaryAnalysisRole[
    plan$RepresentationFitRole == "invariance_companion"
  ]))
  expect_identical(
    sum(plan$TruthMetricEligibleOnlyIfDiagnostic & plan$AttemptCap == 1L),
    180L
  )
})

test_that("cross-engine q and representation pair keys are exact", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  plan <- ctx$env$mfrmr_cq_ach_plan()
  cross <- split(
    plan[!is.na(plan$CrossEnginePairId), ],
    plan$CrossEnginePairId[!is.na(plan$CrossEnginePairId)]
  )
  quadrature <- split(
    plan[!is.na(plan$QuadraturePairId), ],
    plan$QuadraturePairId[!is.na(plan$QuadraturePairId)]
  )
  representation <- split(
    plan[!is.na(plan$RepresentationPairId), ],
    plan$RepresentationPairId[!is.na(plan$RepresentationPairId)]
  )

  expect_identical(length(cross), 90L)
  expect_true(all(vapply(cross, nrow, integer(1L)) == 2L))
  expect_true(all(vapply(
    cross, function(x) setequal(x$Engine, c("mfrmr", "ConQuest")),
    logical(1L)
  )))
  expect_true(all(vapply(
    cross, function(x) length(unique(x$DatasetId)) == 1L &&
      length(unique(x$Family)) == 1L &&
      length(unique(x$QuadratureId)) == 1L,
    logical(1L)
  )))
  expect_identical(length(quadrature), 40L)
  expect_true(all(vapply(quadrature, nrow, integer(1L)) == 2L))
  expect_true(all(vapply(
    quadrature, function(x) setequal(x$Nodes, c(61L, 121L)), logical(1L)
  )))
  expect_true(all(vapply(
    quadrature, function(x) length(unique(x$Engine)) == 1L,
    logical(1L)
  )))
  expect_identical(length(representation), 10L)
  expect_true(all(vapply(representation, nrow, integer(1L)) == 2L))
  expect_true(all(vapply(
    representation,
    function(x) setequal(
      x$RepresentationId, c("planned_absence", "explicit_missing")
    ) && all(x$Engine == "mfrmr") && all(x$Nodes == 61L),
    logical(1L)
  )))
})

test_that("P1 schema and ledgers exist fully before any fit", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  plan <- ctx$env$mfrmr_cq_ach_plan()
  schema <- ctx$env$mfrmr_cq_ach_schema_registry()
  generation <- ctx$env$mfrmr_cq_ach_generation_journal_template(plan)
  journal <- ctx$env$mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- ctx$env$mfrmr_cq_ach_outcome_template(plan)

  expect_identical(nrow(schema), 14L)
  expect_identical(schema$TableOrder, 1:14)
  expect_false(any(schema$RowDroppable))
  expect_false(any(schema$ResultMayChangeSchema))
  expect_false(any(schema$ConfirmationUsePermitted))
  expect_false(any(schema$PublicClaimPermitted))
  expect_identical(nrow(generation), 90L)
  expect_false(any(generation$GenerationStarted))
  expect_false(any(generation$Generated))
  expect_true(all(generation$RowRetained))
  expect_false(any(generation$ResultOpened))
  expect_identical(nrow(journal), 190L)
  expect_identical(journal$AttemptOrder, 1:190)
  expect_false(any(journal$Started))
  expect_false(any(journal$Completed))
  expect_true(all(journal$TerminalCode == "pending_not_executed"))
  expect_false(any(journal$DiagnosticNumericEligible))
  expect_false(any(journal$NumericAgreementInspected))
  expect_identical(nrow(outcome), 230L)
  expect_identical(
    sum(outcome$TerminalCode == "expected_structural_rejection"), 40L
  )
  expect_identical(
    sum(outcome$TerminalCode == "pending_not_executed"), 190L
  )
  expect_false(any(outcome$Attempted))
  expect_true(all(outcome$RowRetained))
  expect_false(any(outcome$CalibrationMetricUsePermitted))
  expect_false(any(outcome$NumericAgreementInspected))
})

test_that("P1 plan audit rejects denominator and authorization mutations", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  audit <- ctx$env$mfrmr_cq_ach_plan_audit
  plan <- ctx$env$mfrmr_cq_ach_plan()
  expect_true(all(audit(plan)$Passed))

  cases <- list(
    duplicate_order = function(x) {
      x$ScheduledOutcomeOrder[2L] <- x$ScheduledOutcomeOrder[1L]
      x
    },
    dropped_attempt = function(x) {
      x$AttemptCap[which(x$AttemptCap == 1L)[1L]] <- 0L
      x
    },
    missing_cross_pair = function(x) {
      x$CrossEnginePairId[which(!is.na(x$CrossEnginePairId))[1L]] <- NA
      x
    },
    inflated_primary = function(x) {
      x$TruthMetricEligibleOnlyIfDiagnostic[
        x$RepresentationFitRole == "invariance_companion"
      ] <- TRUE
      x
    },
    retry = function(x) {
      x$AutomaticRetryPermitted[1L] <- TRUE
      x
    },
    peer_suppression = function(x) {
      x$PeerFailureMaySuppressAttempt[1L] <- TRUE
      x
    },
    result_ordering = function(x) {
      x$ResultMayChangeAttemptOrder[1L] <- TRUE
      x
    },
    generation_authority = function(x) {
      x$ResponseGenerationAuthorizedByPlan[1L] <- TRUE
      x
    },
    execution_authority = function(x) {
      x$ExecutionAuthorizedByPlan[1L] <- TRUE
      x
    }
  )
  for (name in names(cases)) {
    observed <- audit(cases[[name]](plan))
    expect_false(all(observed$Passed), info = name)
  }
})

test_that("G4C P1 advances one capability and remains execution-incomplete", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  review <- ctx$env$mfrmr_cq_ach_dry_run_review(
    ctx$g4x_output, ctx$calibration_output
  )

  expect_identical(
    review$status,
    "ASP_G4C_P1_plan_schema_frozen_integrated_harness_incomplete"
  )
  expect_true(review$exact_outcome_ledger_materialization_ready)
  expect_identical(review$upstream_and_harness_capabilities_available, 6L)
  expect_identical(review$harness_capabilities_still_missing, 12L)
  expect_false(review$deterministic_generation_implemented)
  expect_false(review$engine_adapters_implemented)
  expect_false(review$finalizer_and_metric_summary_implemented)
  expect_false(review$response_generation_authorized)
  expect_false(review$execution_authorized)
  expect_false(review$fresh_tranche_A_sentinel_observed)
  expect_false(review$numeric_agreement_inspected)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_identical(
    review$next_action,
    "ASP-G4C-P2-DETERMINISTIC-GENERATION-AND-BRIDGE"
  )
})

test_that("G4C P1 cannot generate, fit, write, or launch an engine", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  source <- paste(readLines(ctx$paths[15L], warn = FALSE), collapse = "\n")

  expect_false(grepl("runif\\s*\\(|rnorm\\s*\\(|sample\\s*\\(", source,
                     perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2?\\s*\\(", source, perl = TRUE))
  expect_false(grepl("write[.]csv|writeLines|saveRDS", source))
  expect_false(grepl("readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("G4C P1 record keeps the integrated harness checklist open", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-calibration-harness-plan-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_ach_specification, fixed = TRUE)
  expect_match(record, "`ExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "`HarnessCapabilitiesStillMissing=12`", fixed = TRUE)
  expect_match(
    roadmap, "[ ] Freeze the G4C tranche-A calibration harness",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] G4C-P1: freeze the exact plan, schema, and empty ledgers",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[ ] G4C-P2: implement deterministic generation and bridges",
    fixed = TRUE
  )
})
