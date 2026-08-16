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
    "conquest-adversarial-simulation-calibration-harness-0.2.3.R",
    paste0(
      "conquest-adversarial-simulation-calibration-harness-engine-",
      "adapters-0.2.3.R"
    )
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
  smoke_output <- file.path(
    root, "validation-results", env$mfrmr_cq_ase_output_basename
  )
  skip_if_not(
    dir.exists(g4x_output), "The retained run-once G4X output is absent."
  )
  list(
    root = root, validation = validation, paths = paths, env = env,
    g4x_output = g4x_output, calibration_output = calibration_output,
    smoke_output = smoke_output
  )
}

synthetic_calibration_generation_authority <- function(
    ctx, allocation, generation_authorized = FALSE) {
  authority <- new.env(parent = emptyenv())
  values <- list(
    AuthorizationIdentity = paste(
      allocation$DatasetId, allocation$Seed, "tranche_A_generation",
      sep = "::"
    ),
    AuthorizationContract =
      ctx$env$mfrmr_cq_ach_generation_authority_contract,
    HarnessContract = ctx$env$mfrmr_cq_ach_contract,
    DatasetId = allocation$DatasetId,
    Seed = allocation$Seed,
    CalibrationOutputDir = ctx$calibration_output,
    GenerationAuthorized = generation_authorized,
    GenerationConsumed = FALSE,
    OneDatasetOnly = TRUE,
    OneTimeAuthorization = TRUE,
    FreshRuntimeSentinelPassed = TRUE,
    SentinelObservedInCurrentProcess = TRUE,
    FreshSentinelToken = structure(
      list(source = "synthetic_test_only"),
      class = "unvalidated_tranche_A_sentinel_token"
    ),
    OutputTargetAbsentAtAuthorization = TRUE,
    ResultOpened = FALSE,
    ConfirmationOrPublicUsePermitted = FALSE
  )
  list2env(values, envir = authority)
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
  review <- ctx$env$mfrmr_cq_ach_p1_review(
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

test_that("P2 binds every generation request to an exact sealed registry row", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  registry <- ctx$env$mfrmr_cq_acf_seed_registry()
  allocation <- registry[registry$Tranche == "A", , drop = FALSE][1L, ]
  observed <- ctx$env$mfrmr_cq_ach_registered_tranche_row(allocation)

  expect_identical(observed$DatasetId, allocation$DatasetId)
  expect_identical(observed$Seed, allocation$Seed)

  mutations <- list(
    seed = function(x) { x$Seed <- x$Seed + 1L; x },
    arm = function(x) { x$ArmId <- "ASP-POS-COMPLETE::PCM"; x },
    opened = function(x) { x$ResultOpened <- TRUE; x },
    tuning = function(x) { x$MayTuneMetricThreshold <- TRUE; x },
    confirmation = function(x) { x$MayEnterConfirmation <- TRUE; x },
    public = function(x) { x$MaySupportPublicClaim <- TRUE; x }
  )
  for (name in names(mutations)) {
    expect_error(
      ctx$env$mfrmr_cq_ach_registered_tranche_row(
        mutations[[name]](allocation)
      ),
      "differs from the frozen registry",
      info = name
    )
  }
})

test_that("P2 authority failures stop before the response generator", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  registry <- ctx$env$mfrmr_cq_acf_seed_registry()
  allocation <- registry[registry$Tranche == "A", , drop = FALSE][1L, ]
  called <- new.env(parent = emptyenv())
  called$value <- FALSE
  original <- ctx$env$mfrmr_cq_ase_generate_arm
  on.exit(assign("mfrmr_cq_ase_generate_arm", original, envir = ctx$env))
  assign(
    "mfrmr_cq_ase_generate_arm",
    function(allocation) {
      called$value <- TRUE
      stop("generator stub must remain unreachable")
    },
    envir = ctx$env
  )

  expect_error(
    ctx$env$mfrmr_cq_ach_generate_dataset(
      allocation, new.env(parent = emptyenv()), ctx$calibration_output
    ),
    "target-bound mutable generation authority"
  )
  expect_false(called$value)

  authority <- synthetic_calibration_generation_authority(
    ctx, allocation, generation_authorized = FALSE
  )
  expect_error(
    ctx$env$mfrmr_cq_ach_generate_dataset(
      allocation, authority, ctx$calibration_output
    ),
    "Generation authority is absent"
  )
  expect_false(called$value)
  expect_false(authority$GenerationConsumed)

  authority$GenerationAuthorized <- TRUE
  authority$FreshRuntimeSentinelPassed <- FALSE
  expect_error(
    ctx$env$mfrmr_cq_ach_generate_dataset(
      allocation, authority, ctx$calibration_output
    ),
    "Generation authority is absent"
  )
  expect_false(called$value)
  expect_false(authority$GenerationConsumed)

  authority$FreshRuntimeSentinelPassed <- TRUE
  expect_error(
    ctx$env$mfrmr_cq_ach_generate_dataset(
      allocation, authority, ctx$calibration_output
    ),
    "sentinel booleans alone are insufficient"
  )
  expect_false(called$value)
  expect_false(authority$GenerationConsumed)
})

test_that("P2 reuses the frozen RNG stream without leaking caller state", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  contract <- ctx$env$mfrmr_cq_ach_rng_contract()
  expect_identical(contract$UniformKind, "Mersenne-Twister")
  expect_identical(contract$NormalKind, "Inversion")
  expect_identical(contract$SampleKind, "Rejection")
  expect_true(contract$CallerRNGStateRestored)
  expect_true(contract$FrozenTrancheSeedRequired)
  expect_false(contract$PositiveAuthorityIssuedByP2)
  expect_false(contract$TrancheAResponseGeneratedByP2)
  expect_true(contract$SemanticReplayRequired)
  expect_false(contract$ByteIdentityIsScientificAcceptanceCriterion)

  set.seed(2468L)
  before <- .Random.seed
  first <- ctx$env$mfrmr_cq_ase_uniform_stream(988101L, 4L, 7L)
  expect_identical(.Random.seed, before)
  second <- ctx$env$mfrmr_cq_ase_uniform_stream(988101L, 4L, 7L)
  expect_identical(.Random.seed, before)
  expect_identical(first, second)
})

test_that("P2 replays all retained semantic bridges without generation", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  replay <- ctx$env$mfrmr_cq_ach_retained_bridge_replay(ctx$smoke_output)

  expect_identical(replay$source_dataset_count, 18L)
  expect_identical(replay$paired_dataset_count, 2L)
  expect_identical(replay$bridge_check_count, 8L)
  expect_true(all(replay$bridge$Passed))
  expect_false(replay$response_generation_performed)
  expect_false(replay$numeric_agreement_inspected)
  expect_false(replay$byte_equality_inspected)
  expect_false(any(replay$bridge$ByteEqualityRequired))
  expect_false(any(replay$bridge$NumericAgreementInspected))
})

test_that("P2 bridge rejects value mask key and typed-map mutations", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  tables <- ctx$env$mfrmr_cq_ase_read_tables(ctx$smoke_output)
  manifest <- tables$dataset_manifest
  paired_id <- manifest$DatasetId[
    manifest$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS"
  ][1L]
  audit <- function(response) {
    ctx$env$mfrmr_cq_ach_representation_bridge_audit(response, manifest)
  }
  current_index <- which(tables$response_data$DatasetId == paired_id)
  planned <- current_index[
    tables$response_data$RepresentationId[current_index] == "planned_absence"
  ]
  explicit <- current_index[
    tables$response_data$RepresentationId[current_index] == "explicit_missing"
  ]
  explicit_missing <- explicit[
    !tables$response_data$ResponseObserved[explicit]
  ]

  value_mutation <- tables$response_data
  value_mutation$Response[planned[1L]] <-
    (value_mutation$Response[planned[1L]] + 1L) %% 4L
  value_audit <- audit(value_mutation)
  expect_false(value_audit$Passed[
    value_audit$DatasetId == paired_id &
      value_audit$CheckId == "observed_response_relation_equivalent"
  ])

  complement_mutation <- tables$response_data[-explicit_missing[1L], ]
  complement_audit <- audit(complement_mutation)
  expect_false(complement_audit$Passed[
    complement_audit$DatasetId == paired_id &
      complement_audit$CheckId ==
        "explicit_missing_is_exact_design_complement"
  ])

  duplicate_mutation <- rbind(
    tables$response_data,
    tables$response_data[explicit_missing[1L], , drop = FALSE]
  )
  duplicate_audit <- audit(duplicate_mutation)
  expect_false(duplicate_audit$Passed[
    duplicate_audit$DatasetId == paired_id &
      duplicate_audit$CheckId ==
        "explicit_missing_is_exact_design_complement"
  ])

  extra_representation <- tables$response_data[planned[1L], , drop = FALSE]
  extra_representation$RepresentationId <- "unregistered_representation"
  extra_audit <- audit(rbind(tables$response_data, extra_representation))
  expect_false(all(extra_audit$Passed[extra_audit$DatasetId == paired_id]))

  mask_mutation <- tables$response_data
  mask_mutation$ResponseObserved[explicit_missing[1L]] <- TRUE
  mask_mutation$Response[explicit_missing[1L]] <- 0L
  mask_audit <- audit(mask_mutation)
  expect_false(mask_audit$Passed[
    mask_audit$DatasetId == paired_id &
      mask_audit$CheckId ==
        "explicit_missing_is_exact_design_complement"
  ])

  typed_map_mutation <- tables$response_data
  explicit_observed <- explicit[
    tables$response_data$ResponseObserved[explicit]
  ][1L]
  typed_map_mutation$PersonIndex[planned[1L]] <- 99L
  typed_map_mutation$PersonIndex[explicit_observed] <- 99L
  typed_audit <- audit(typed_map_mutation)
  expect_false(typed_audit$Passed[
    typed_audit$DatasetId == paired_id &
      typed_audit$CheckId == "canonical_cell_map_equivalent"
  ])
  expect_false(all(value_audit$Passed))
  expect_false(all(complement_audit$Passed))
  expect_false(all(duplicate_audit$Passed))
  expect_false(all(extra_audit$Passed))
  expect_false(all(mask_audit$Passed))
  expect_false(all(typed_audit$Passed))
})

test_that("G4C P2 adds only generation and bridge capabilities", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  review <- ctx$env$mfrmr_cq_ach_p2_review(
    ctx$g4x_output, ctx$calibration_output, ctx$smoke_output
  )

  expect_identical(
    review$status,
    paste0(
      "ASP_G4C_P2_generation_and_bridge_frozen_",
      "integrated_harness_incomplete"
    )
  )
  expect_identical(review$upstream_and_harness_capabilities_available, 8L)
  expect_identical(review$harness_capabilities_still_missing, 10L)
  expect_true(review$exact_outcome_ledger_materialization_ready)
  expect_true(review$deterministic_generation_implemented)
  expect_true(review$semantic_bridge_implemented)
  expect_identical(review$retained_g3_bridge_checks, 8L)
  expect_false(review$tranche_A_responses_generated)
  expect_false(review$positive_generation_authority_issued)
  expect_false(review$fresh_sentinel_token_validator_implemented)
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
    "ASP-G4C-P3-ENGINE-ADAPTERS-ARTIFACTS-RESOURCES"
  )
})

test_that("G4C P2 has no unguarded random, fit, write, or engine path", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  source <- paste(readLines(ctx$paths[15L], warn = FALSE), collapse = "\n")

  expect_false(grepl("runif\\s*\\(|rnorm\\s*\\(|sample\\s*\\(", source,
                     perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2?\\s*\\(", source, perl = TRUE))
  expect_false(grepl("write[.]csv|writeLines|saveRDS", source))
  expect_false(grepl("readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_false(grepl(
    "mfrmr_cq_ach_issue_generation_authority\\s*<-", source, perl = TRUE
  ))
  expect_false(grepl(
    "mfrmr_cq_ach_validate_fresh_sentinel_token\\s*<-", source, perl = TRUE
  ))
})

test_that("G4C P1 and P2 records keep the integrated harness checklist open", {
  ctx <- load_conquest_adversarial_simulation_calibration_harness()
  p1_record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-calibration-harness-plan-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  p2_record <- paste(readLines(file.path(
    ctx$validation,
    paste0(
      "conquest-adversarial-simulation-calibration-harness-generation-",
      "record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(
    p1_record, ctx$env$mfrmr_cq_ach_p1_specification, fixed = TRUE
  )
  expect_match(p1_record, "`ExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    p1_record, "`HarnessCapabilitiesStillMissing=12`", fixed = TRUE
  )
  expect_match(p2_record, ctx$env$mfrmr_cq_ach_specification, fixed = TRUE)
  expect_match(p2_record, "`TrancheAResponsesGenerated=FALSE`", fixed = TRUE)
  expect_match(
    p2_record, "`PositiveGenerationAuthorityIssued=FALSE`", fixed = TRUE
  )
  expect_match(
    p2_record, "`HarnessCapabilitiesStillMissing=10`", fixed = TRUE
  )
  expect_match(p2_record, "Byte equality is false", fixed = TRUE)
  expect_match(
    roadmap, "[ ] Freeze the G4C tranche-A calibration harness",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] G4C-P1: freeze the exact plan, schema, and empty ledgers",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] G4C-P2: implement deterministic generation and bridges",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] G4C-P3: implement q61/q121 engine adapters",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[ ] G4C-P4: implement G4N application",
    fixed = TRUE
  )
})
