load_conquest_adversarial_simulation_engine_mechanics_harness <- function() {
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
    "conquest-adversarial-simulation-engine-mechanics-harness-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G4H files are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

mfrmr_cq_ameh_test_smoke <- function(ctx) {
  file.path(
    ctx$root, "validation-results", ctx$env$mfrmr_cq_amea_smoke_output_basename
  )
}

test_that("G4H binds exactly 38 rows and 30 q61 attempts", {
  env <- load_conquest_adversarial_simulation_engine_mechanics_harness()$env
  plan <- env$mfrmr_cq_ameh_plan()

  expect_identical(nrow(plan), 38L)
  expect_identical(sum(plan$AttemptCap), 30L)
  expect_identical(
    sum(plan$Engine == "mfrmr" & plan$AttemptCap == 1L), 16L
  )
  expect_identical(
    sum(plan$Engine == "ConQuest" & plan$AttemptCap == 1L), 14L
  )
  expect_identical(sum(plan$QuadratureId == "prefit_stop"), 8L)
  expect_true(all(plan$QuadratureId[plan$AttemptCap == 1L] == "q61"))
  expect_identical(
    plan$AttemptOrder[!is.na(plan$AttemptOrder)], 1:30
  )
  expect_identical(
    plan$ExpectedFreeDimension[plan$Family == "RSM"], rep(10L, 19L)
  )
  expect_identical(
    plan$ExpectedFreeDimension[plan$Family == "PCM"], rep(14L, 19L)
  )
  expect_false(anyDuplicated(plan$RunId[plan$AttemptCap == 1L]) > 0L)
  expect_true(all(plan$HarnessExecutionRequiresExplicitOptIn))
  expect_false(any(plan$ExecutionAuthorizedByHarnessFreeze))
})

test_that("paired representations pass four semantic checks per family", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_harness()
  source <- ctx$env$mfrmr_cq_ameh_source_tables(mfrmr_cq_ameh_test_smoke(ctx))
  bridge <- ctx$env$mfrmr_cq_ameh_representation_bridge_audit(source$tables)

  expect_identical(nrow(bridge), 8L)
  expect_identical(
    as.integer(table(factor(bridge$Family, levels = c("RSM", "PCM")))),
    c(4L, 4L)
  )
  expect_identical(bridge$CheckOrder, rep(1:4, 2L))
  expect_true(all(bridge$Passed))
  expect_false(any(bridge$ByteEqualityRequired))
  expect_false(any(bridge$NumericAgreementInspected))

  bad <- source$tables
  index <- which(
    bad$response_data$DatasetId == "CQASP-SMOKE-09" &
      bad$response_data$RepresentationId == "explicit_missing" &
      bad$response_data$ResponseObserved
  )[1L]
  bad$response_data$Response[index] <-
    (bad$response_data$Response[index] + 1L) %% 4L
  expect_error(
    ctx$env$mfrmr_cq_ameh_representation_bridge_audit(bad),
    "failed their semantic bridge", fixed = TRUE
  )
})

test_that("retained long and canonical wide inputs preserve missingness", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_harness()
  env <- ctx$env
  source <- env$mfrmr_cq_ameh_source_tables(mfrmr_cq_ameh_test_smoke(ctx))
  planned <- env$mfrmr_cq_ameh_dataset_input(
    source$tables, "CQASP-SMOKE-09", "planned_absence"
  )
  explicit <- env$mfrmr_cq_ameh_dataset_input(
    source$tables, "CQASP-SMOKE-09", "explicit_missing"
  )
  canonical <- env$mfrmr_cq_ameh_dataset_input(
    source$tables, "CQASP-SMOKE-09", "canonical_wide_missing"
  )

  expect_identical(nrow(planned$long), 288L)
  expect_identical(nrow(explicit$long), 576L)
  expect_identical(sum(is.na(explicit$long$Response)), 288L)
  expect_identical(dim(canonical$wide), c(48L, 14L))
  expect_identical(
    sum(is.na(canonical$wide[, -(1:2), drop = FALSE])), 288L
  )
  expect_equal(planned$wide, explicit$wide, tolerance = 0)
  expect_equal(explicit$wide, canonical$wide, tolerance = 0)
})

test_that("ConQuest commands and artifact paths are exact and unique", {
  env <- load_conquest_adversarial_simulation_engine_mechanics_harness()$env
  plan <- env$mfrmr_cq_ameh_plan()
  conquest <- plan[plan$Engine == "ConQuest" & plan$AttemptCap == 1L, ,
                   drop = FALSE]
  registry <- env$mfrmr_cq_ameh_expected_artifact_registry(plan)

  expect_identical(nrow(conquest), 14L)
  for (index in seq_len(nrow(conquest))) {
    command <- env$mfrmr_cq_ameh_command(
      conquest$Prefix[index], conquest$Family[index], 61L
    )
    expected_model <- if (conquest$Family[index] == "RSM") {
      "model rater + criterion + step;"
    } else {
      "model rater + criterion + criterion*step;"
    }
    expect_true(expected_model %in% command)
    expect_true(any(grepl("nodes=61,", command, fixed = TRUE)))
    expect_true(any(grepl(
      "facets=criterion(3) rater(4)", command, fixed = TRUE
    )))
  }
  expect_identical(nrow(registry), 239L)
  expect_false(anyDuplicated(registry$RelativePath) > 0L)
  expect_identical(
    sum(registry$ArtifactKind == "fresh_runtime_sentinel_console"), 1L
  )
})

test_that("ordinary engine failures cannot suppress peer attempts", {
  env <- load_conquest_adversarial_simulation_engine_mechanics_harness()$env
  policy <- env$mfrmr_cq_ameh_execution_policy()

  expect_false(policy$StopLaterAttempts[
    policy$Event == "ordinary_mfrmr_fit_or_parse_failure"
  ])
  expect_false(policy$StopLaterAttempts[
    policy$Event == "ordinary_ConQuest_fit_or_parse_failure"
  ])
  expect_false(policy$StopLaterAttempts[
    policy$Event == "single_fit_timeout"
  ])
  expect_true(policy$StopLaterAttempts[
    policy$Event == "fresh_runtime_sentinel_failure"
  ])
  expect_true(policy$StopLaterAttempts[
    policy$Event == "global_wall_time_or_storage_cap"
  ])
  expect_true(all(policy$RetainAllScheduledRows))
  expect_false(any(policy$AutomaticRetryPermitted))
  expect_false(any(policy$NumericAgreementInspected))
  expect_false(any(policy$CalibrationAuthorized))
})

test_that("mechanics completion rewards coverage but rejects hidden loss", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_harness()
  env <- ctx$env
  source <- env$mfrmr_cq_ameh_source_tables(mfrmr_cq_ameh_test_smoke(ctx))
  bridge <- env$mfrmr_cq_ameh_representation_bridge_audit(source$tables)
  plan <- env$mfrmr_cq_ameh_plan()
  journal <- env$mfrmr_cq_ameh_journal_template(plan)
  outcome <- env$mfrmr_cq_ameh_outcome_template(plan)

  journal$AttemptCount <- 1L
  journal$Started <- TRUE
  journal$Completed <- TRUE
  journal$ElapsedSeconds <- 1
  journal$RegisteredFailureCount <- 0L
  journal$TerminalCode <- "complete_numeric_eligible"
  journal$ParseableResult <- TRUE
  journal$ObservedFreeDimension <- journal$ExpectedFreeDimension
  journal$ModelIdentityMatch <- TRUE
  journal$InferenceReady <- TRUE
  attempted <- !is.na(outcome$AttemptOrder)
  outcome$Attempted[attempted] <- TRUE
  outcome$TerminalCode[attempted] <- "complete_numeric_eligible"
  outcome$ParseableResult[attempted] <- TRUE
  outcome$ModelIdentityMatch[attempted] <- TRUE
  outcome$ElapsedSeconds[attempted] <- 1

  audit <- env$mfrmr_cq_ameh_mechanics_audit(
    journal, outcome, bridge,
    fresh_runtime_sentinel_passed = TRUE,
    global_abort_triggered = FALSE
  )
  decision <- env$mfrmr_cq_acf_engine_mechanics_decision(audit)
  expect_true(decision$mechanics_gate_met)
  expect_true(env$mfrmr_cq_ameh_accounting_complete(
    journal, outcome, plan
  ))
  expect_false(decision$all_fit_attempts_required_to_succeed)
  expect_false(decision$calibration_generation_authorized)
  expect_false(decision$scientific_equivalence_inferred)

  redundant_failure_journal <- journal
  redundant_failure_outcome <- outcome
  redundant <- which(
    redundant_failure_journal$RepresentationId == "observed_rows_only"
  )[1L]
  redundant_failure_journal$TerminalCode[redundant] <-
    "optimizer_nonconvergence_or_readiness_hold"
  redundant_failure_journal$SecondaryCode[redundant] <-
    "synthetic_registered_ordinary_failure"
  redundant_failure_journal$ParseableResult[redundant] <- FALSE
  redundant_failure_journal$InferenceReady[redundant] <- FALSE
  outcome_row <- match(
    redundant_failure_journal$ScheduledOutcomeOrder[redundant],
    redundant_failure_outcome$ScheduledOutcomeOrder
  )
  redundant_failure_outcome$TerminalCode[outcome_row] <-
    "optimizer_nonconvergence_or_readiness_hold"
  redundant_failure_outcome$SecondaryCode[outcome_row] <-
    "synthetic_registered_ordinary_failure"
  redundant_failure_outcome$ParseableResult[outcome_row] <- FALSE
  redundant_audit <- env$mfrmr_cq_ameh_mechanics_audit(
    redundant_failure_journal, redundant_failure_outcome, bridge,
    fresh_runtime_sentinel_passed = TRUE,
    global_abort_triggered = FALSE
  )
  expect_true(env$mfrmr_cq_acf_engine_mechanics_decision(
    redundant_audit
  )$mechanics_gate_met)
  expect_true(env$mfrmr_cq_ameh_accounting_complete(
    redundant_failure_journal, redundant_failure_outcome, plan
  ))

  parser_loss <- journal
  parser_loss$ParseableResult[
    parser_loss$Engine == "ConQuest" & parser_loss$Family == "PCM"
  ] <- FALSE
  expect_false(env$mfrmr_cq_acf_engine_mechanics_decision(
    env$mfrmr_cq_ameh_mechanics_audit(
      parser_loss, outcome, bridge, TRUE, FALSE
    )
  )$mechanics_gate_met)

  peer_suppressed <- journal
  peer_suppressed$Started[1L] <- FALSE
  peer_suppressed$SecondaryCode[1L] <- "peer_failure_suppressed_attempt"
  expect_false(env$mfrmr_cq_ameh_accounting_complete(
    peer_suppressed, outcome, plan
  ))
  expect_false(env$mfrmr_cq_acf_engine_mechanics_decision(
    env$mfrmr_cq_ameh_mechanics_audit(
      peer_suppressed, outcome, bridge, TRUE, FALSE
    )
  )$mechanics_gate_met)

  identity_loss <- journal
  identity_loss$TerminalCode[1L] <- "model_identity_mismatch"
  identity_loss$ModelIdentityMatch[1L] <- FALSE
  expect_false(env$mfrmr_cq_acf_engine_mechanics_decision(
    env$mfrmr_cq_ameh_mechanics_audit(
      identity_loss, outcome, bridge, TRUE, FALSE
    )
  )$mechanics_gate_met)
})

test_that("mfrmr execution binds to the 0.2.3 working-tree namespace", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_harness()
  pkgload::load_all(ctx$root, quiet = TRUE)
  namespace <- ctx$env$mfrmr_cq_ameh_loaded_namespace(ctx$root)

  expect_identical(unname(getNamespaceName(namespace)), "mfrmr")
  expect_identical(as.character(utils::packageVersion("mfrmr")), "0.2.3")
  expect_true(exists(
    "with_preserved_rng_seed", envir = namespace, inherits = FALSE
  ))
  expect_true(exists(
    "mfrm_ic_common_panel", envir = namespace, inherits = FALSE
  ))
  expect_error(
    ctx$env$mfrmr_cq_ameh_loaded_namespace(dirname(ctx$root)),
    "not the 0.2.3 working-tree source", fixed = TRUE
  )
})

test_that("all-empty artifact columns survive CSV type inference semantically", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_harness()
  env <- ctx$env
  inventory <- env$mfrmr_cq_ameh_artifact_inventory_template()
  path <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(inventory, path, row.names = FALSE, na = "")
  observed <- utils::read.csv(
    path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = ""
  )

  expect_type(observed$PresentArtifactKinds, "logical")
  expect_type(observed$UnexpectedArtifactKinds, "logical")
  expect_false(env$mfrmr_cq_ameh_same_frame(observed, inventory))
  expect_true(env$mfrmr_cq_ameh_same_frame(
    env$mfrmr_cq_ameh_normalize_artifact_inventory(observed),
    env$mfrmr_cq_ameh_normalize_artifact_inventory(inventory)
  ))
})

test_that("dry preparation is opt-in, semantic, exact, and execution-free", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_harness()
  env <- ctx$env
  parent <- withr::local_tempdir()
  output <- file.path(parent, env$mfrmr_cq_amea_output_basename)
  smoke <- mfrmr_cq_ameh_test_smoke(ctx)

  expect_error(
    env$mfrmr_cq_ameh_prepare(
      smoke, output, as.Date("2026-08-16"), authorize = FALSE
    ),
    "Preparation is held", fixed = TRUE
  )
  expect_false(dir.exists(output))
  prepared <- env$mfrmr_cq_ameh_prepare(
    smoke, output, as.Date("2026-08-16"), authorize = TRUE
  )
  expect_identical(
    prepared$status, "ASP_G4H_bundle_prepared_execution_unopened"
  )
  expect_true(prepared$exact_plan_ready)
  expect_true(prepared$exact_preexecution_file_boundary)
  expect_true(prepared$semantic_source_ready)
  expect_true(prepared$representation_bridge_ready)
  expect_true(prepared$semantic_inputs_ready)
  expect_true(prepared$command_semantics_ready)
  expect_true(prepared$all_execution_outputs_absent)
  expect_true(prepared$execution_ready)
  expect_false(prepared$execution_attempted)
  expect_identical(sum(prepared$journal$AttemptCount), 0L)
  expect_identical(
    length(list.files(output, recursive = TRUE, all.files = TRUE, no.. = TRUE)),
    72L
  )
  expect_false(file.exists(file.path(output, "runtime_sentinel_console.log")))
  expect_true(env$mfrmr_cq_ameh_output_boundary(
    output, prepared$plan, prepared$expected_artifacts
  )$passed)
  expect_true(all(env$mfrmr_cq_ameh_update_artifact_inventory(
    output, prepared$plan, prepared$outcome, prepared$expected_artifacts
  )$ArtifactSetComplete))
  expect_error(
    env$mfrmr_cq_ameh_execute(output, authorize = FALSE),
    "Execution is held", fixed = TRUE
  )
  expect_false(file.exists(file.path(output, "runtime_sentinel_console.log")))

  writeLines(
    "opened sentinel placeholder",
    file.path(output, "runtime_sentinel_console.log"), useBytes = TRUE
  )
  opened <- env$mfrmr_cq_ameh_validate_prepared(output)
  expect_false(opened$all_execution_outputs_absent)
  expect_false(opened$execution_ready)
  writeLines("unregistered", file.path(output, "unregistered.tmp"))
  boundary <- env$mfrmr_cq_ameh_output_boundary(
    output, prepared$plan, prepared$expected_artifacts
  )
  expect_false(boundary$passed)
  expect_identical(boundary$unexpected_files, "unregistered.tmp")
})

test_that("sentinel assessment checks semantics without authorizing a fit", {
  env <- load_conquest_adversarial_simulation_engine_mechanics_harness()$env
  execution <- list(
    console_lines = c(
      "ConQuest version: 5.47.5", "Demonstration Version",
      "This version expires 1 September 2026", "<End of Program"
    ),
    exit_status = 0L,
    host_error = NA_character_
  )
  ready <- env$mfrmr_cq_ameh_assess_sentinel(
    execution,
    "/Applications/ConQuest/ConQuest",
    "/Applications/ConQuest/ConQuest: Mach-O 64-bit executable x86_64",
    as.Date("2026-08-16")
  )
  expect_true(ready$exact_runtime_ready)
  expect_false(ready$summary$ModelEstimationAttempted)
  expect_false(ready$summary$ScientificComparisonAuthorized)

  execution$console_lines <- c(
    execution$console_lines,
    "Unknown command or argument: model"
  )
  blocked <- env$mfrmr_cq_ameh_assess_sentinel(
    execution,
    "/Applications/ConQuest/ConQuest",
    "/Applications/ConQuest/ConQuest: Mach-O 64-bit executable x86_64",
    as.Date("2026-08-16")
  )
  expect_false(blocked$exact_runtime_ready)
})

test_that("G4H has no deletion, retry, hash, or top-level execution route", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_harness()
  source <- paste(readLines(ctx$paths[11L], warn = FALSE), collapse = "\n")

  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_match(source, "mfrmr_cq_ameh_system_runner <- function", fixed = TRUE)
  expect_match(source, "mfrmr_cq_ameh_execute <- function", fixed = TRUE)
  expect_match(source, "authorize = FALSE", fixed = TRUE)
  expect_match(source, "setTimeLimit", fixed = TRUE)
  expect_false(grepl(
    "mfrmr_cq_ameh_execute\\s*\\([^)]*authorize\\s*=\\s*TRUE",
    source, perl = TRUE
  ))
})

test_that("G4H record stays immutable while the roadmap advances through G4R", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_harness()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-engine-mechanics-harness-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  execution_record <- paste(readLines(file.path(
    ctx$validation,
    paste0(
      "conquest-adversarial-simulation-engine-mechanics-",
      "execution-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_ameh_specification, fixed = TRUE)
  expect_match(record, "`HarnessFrozen=TRUE`", fixed = TRUE)
  expect_match(record, "`LiveExecutionAttempted=FALSE`", fixed = TRUE)
  expect_match(record, "ordinary failure cannot suppress", fixed = TRUE)
  expect_match(
    roadmap, "[x] Freeze the fail-closed G4H engine-mechanics harness",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Execute the exact G4X mechanics bundle once",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Complete G4R post-mechanics calibration review",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Freeze the G4N diagnostic-numeric-eligibility addendum",
    fixed = TRUE
  )
  expect_match(
    execution_record,
    "ASP_G4X_engine_mechanics_complete_calibration_review_required",
    fixed = TRUE
  )
  expect_match(execution_record, "`FitAttemptCount=30`", fixed = TRUE)
  expect_match(execution_record, "`MechanicsGateMet=TRUE`", fixed = TRUE)
  expect_match(execution_record, "`CalibrationAuthorized=FALSE`", fixed = TRUE)
  expect_match(execution_record, "`RerunAuthorized=FALSE`", fixed = TRUE)
})
