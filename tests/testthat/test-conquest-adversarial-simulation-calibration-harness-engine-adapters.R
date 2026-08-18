load_conquest_adversarial_simulation_calibration_p3 <- function() {
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
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G4C-P3 files excluded.")
  .mfrmr_test_ensure_source_namespace(root)
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(
    root = root,
    validation = validation,
    paths = paths,
    env = env,
    smoke_output = file.path(
      root, "validation-results", env$mfrmr_cq_ase_output_basename
    ),
    g4x_output = file.path(
      root, "validation-results", env$mfrmr_cq_amea_output_basename
    ),
    calibration_output = file.path(
      root, "validation-results", env$mfrmr_cq_ataa_output_basename
    )
  )
}

test_that("P3 freezes all 190 adapter attempts and both quadratures", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]

  expect_identical(nrow(plan), 230L)
  expect_identical(nrow(attempt), 190L)
  expect_identical(sum(attempt$Engine == "mfrmr"), 100L)
  expect_identical(sum(attempt$Engine == "ConQuest"), 90L)
  expect_identical(sum(attempt$Nodes == 61L), 150L)
  expect_identical(sum(attempt$Nodes == 121L), 40L)
  expect_identical(
    as.integer(table(attempt$Engine, attempt$Nodes)["mfrmr", ]),
    c(80L, 20L)
  )
  expect_identical(
    as.integer(table(attempt$Engine, attempt$Nodes)["ConQuest", ]),
    c(70L, 20L)
  )
  expect_identical(anyDuplicated(attempt$RunId), 0L)
  expect_identical(anyDuplicated(attempt$Prefix), 0L)
  expect_true(all(attempt$PerFitTimeoutSeconds == 600L))
  expect_true(all(attempt$FreshSentinelTokenRequired))
  expect_false(any(plan$ExecutionAuthorizedByP3))
})

test_that("P3 ConQuest commands preserve family identity at q61 and q121", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  command <- ctx$env$mfrmr_cq_ach_conquest_command
  cases <- expand.grid(
    Family = c("RSM", "PCM"), Nodes = c(61L, 121L),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  for (index in seq_len(nrow(cases))) {
    prefix <- paste0("p3_case_", index)
    observed <- command(prefix, cases$Family[index], cases$Nodes[index])
    expect_identical(length(observed), 22L)
    expect_true(any(grepl(
      paste0("nodes=", cases$Nodes[index]), observed, fixed = TRUE
    )))
    expect_true(any(grepl(
      paste0("title mfrmr ASP calibration ", cases$Family[index], " q"),
      observed, fixed = TRUE
    )))
    expected_model <- if (cases$Family[index] == "RSM") {
      "model rater + criterion + step;"
    } else {
      "model rater + criterion + criterion*step;"
    }
    expect_true(expected_model %in% observed)
    expect_identical(tail(observed, 1L), "quit;")
  }
  expect_error(command("bad", "RSM", 31L), "exactly q61 or q121")
  expect_error(command("bad", "GPCM", 61L), "exactly q61 or q121")
})

test_that("P3 mfrmr arguments bind direct MML and the scheduled q", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  tables <- ctx$env$mfrmr_cq_ase_read_tables(ctx$smoke_output)
  manifest <- tables$dataset_manifest
  dataset_id <- manifest$DatasetId[
    manifest$ScenarioClassId == "ASP-POS-COMPLETE" &
      manifest$Family == "PCM"
  ][1L]
  input <- ctx$env$mfrmr_cq_ach_dataset_input(
    tables, dataset_id, "observed_rows_only"
  )
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  q61 <- plan[
    plan$Engine == "mfrmr" & plan$Family == "PCM" &
      plan$Nodes == 61L & plan$AttemptCap == 1L,
    , drop = FALSE
  ][1L, ]
  q121 <- plan[
    plan$Engine == "mfrmr" & plan$Family == "PCM" &
      plan$Nodes == 121L & plan$AttemptCap == 1L,
    , drop = FALSE
  ][1L, ]
  args61 <- ctx$env$mfrmr_cq_ach_mfrmr_arguments(
    input$long, input$person, q61
  )
  args121 <- ctx$env$mfrmr_cq_ach_mfrmr_arguments(
    input$long, input$person, q121
  )

  expect_identical(args61$quad_points, 61L)
  expect_identical(args121$quad_points, 121L)
  expect_identical(args61$method, "MML")
  expect_identical(args61$mml_engine, "direct")
  expect_identical(args61$model, "PCM")
  expect_identical(args61$step_facet, "Criterion")
  expect_identical(args61$maxit, 2000L)
  expect_identical(args61$reltol, 1e-12)
  expect_false("Response" %in% names(args61$data))
  expect_true("Score" %in% names(args61$data))
})

test_that("P3 registers every output and rejects unexpected files", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  inventory <- ctx$env$mfrmr_cq_ach_artifact_inventory(plan = plan)

  expect_identical(nrow(inventory$registry), 1511L)
  expect_identical(nrow(inventory$allowed_path_registry), 1910L)
  expect_identical(anyDuplicated(inventory$registry$RelativePath), 0L)
  expect_identical(
    sum(inventory$registry$Engine == "mfrmr"), 700L
  )
  expect_identical(
    sum(inventory$registry$Engine == "ConQuest"), 811L
  )
  expect_false(any(inventory$registry$Present))
  expect_false(inventory$output_boundary_inspected)
  expect_true(is.na(inventory$unexpected_file_guard_passed))
  expect_false(any(inventory$registry$ByteEqualityInspected))
  expect_false(any(inventory$registry$NumericAgreementInspected))

  root <- withr::local_tempdir()
  writeLines("registered", file.path(root, "response_layout.csv"))
  clean <- ctx$env$mfrmr_cq_ach_artifact_inventory(root, plan)
  expect_true(clean$output_boundary_inspected)
  expect_true(clean$unexpected_file_guard_passed)
  expect_length(clean$unexpected_files, 0L)
  writeLines("unregistered", file.path(root, "unregistered.tmp"))
  blocked <- ctx$env$mfrmr_cq_ach_artifact_inventory(root, plan)
  expect_false(blocked$unexpected_file_guard_passed)
  expect_identical(blocked$unexpected_files, "unregistered.tmp")
})

test_that("P3 resource caps stop globally but ordinary failures do not", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  q61 <- plan[plan$AttemptCap == 1L & plan$Nodes == 61L, , drop = FALSE][1L, ]
  q121 <- plan[
    plan$AttemptCap == 1L & plan$Nodes == 121L, , drop = FALSE
  ][1L, ]
  state <- ctx$env$mfrmr_cq_ach_resource_state()

  expect_true(ctx$env$mfrmr_cq_ach_resource_controller(
    state, q61
  )$AttemptPermitted)
  expect_true(ctx$env$mfrmr_cq_ach_resource_controller(
    state, q121
  )$AttemptPermitted)
  timeout <- ctx$env$mfrmr_cq_ach_resource_controller(
    state, terminal_code = "fit_timeout"
  )
  expect_true(timeout$OrdinaryFailureObserved)
  expect_false(timeout$StopLaterAttempts)
  expect_false(timeout$OrdinaryFailureMaySuppressPeer)
  expect_false(timeout$SingleFitTimeoutMaySuppressPeer)
  expect_false(timeout$AutomaticRetryPermitted)

  q_cap <- state
  q_cap$FitAttempts <- 150L
  q_cap$Q61FitAttempts <- 150L
  expect_false(ctx$env$mfrmr_cq_ach_resource_controller(
    q_cap, q61
  )$AttemptPermitted)
  expect_true(ctx$env$mfrmr_cq_ach_resource_controller(
    q_cap, q121
  )$AttemptPermitted)

  wall <- state
  wall$ElapsedSeconds <- wall$WallTimeCapSeconds
  expect_true(ctx$env$mfrmr_cq_ach_resource_controller(
    wall, q61
  )$StopLaterAttempts)
  storage <- state
  storage$RetainedBytes <- storage$StorageCapBytes
  expect_true(ctx$env$mfrmr_cq_ach_resource_controller(
    storage, q61
  )$StopLaterAttempts)
  total <- state
  total$FitAttempts <- total$TotalFitAttemptCap
  expect_true(ctx$env$mfrmr_cq_ach_resource_controller(
    total, q61
  )$StopLaterAttempts)

  mutated <- state
  mutated$PerFitTimeoutSeconds <- 601L
  expect_error(
    ctx$env$mfrmr_cq_ach_resource_controller(mutated, q61),
    "outside its freeze"
  )
})

test_that("P3 sentinel tokens bind process target runtime and all seed pairs", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  assessment <- list(
    exact_runtime_ready = TRUE,
    summary = data.frame(
      RuntimeVersion = "5.47.5",
      RuntimeEdition = "Demonstration Version",
      ExpiryDate = as.Date("2026-09-01"),
      ModelEstimationAttempted = FALSE,
      ScientificComparisonAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  )
  token <- ctx$env$mfrmr_cq_ach_sentinel_token_from_assessment(
    assessment,
    ctx$calibration_output,
    "/Applications/ConQuest/ConQuest",
    as.Date("2026-08-16")
  )
  seed <- ctx$env$mfrmr_cq_acf_seed_registry()
  seed <- seed[seed$Tranche == "A", , drop = FALSE][1L, ]
  validate <- ctx$env$mfrmr_cq_ach_validate_fresh_sentinel_token

  expect_true(validate(
    token, seed$DatasetId, seed$Seed, ctx$calibration_output
  ))
  expect_false(validate(
    token, seed$DatasetId, seed$Seed + 1L, ctx$calibration_output
  ))
  token$ProcessId <- token$ProcessId + 1L
  expect_false(validate(
    token, seed$DatasetId, seed$Seed, ctx$calibration_output
  ))

  parent <- withr::local_tempdir()
  execution_root <- file.path(parent, ctx$env$mfrmr_cq_ataa_output_basename)
  dir.create(execution_root)
  execution_token <- ctx$env$mfrmr_cq_ach_sentinel_token_from_assessment(
    assessment,
    execution_root,
    "/Applications/ConQuest/ConQuest",
    as.Date("2026-08-16")
  )
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  arm <- plan[plan$AttemptCap == 1L, , drop = FALSE][1L, ]
  permit <- ctx$env$mfrmr_cq_ach_attempt_permit(
    arm, execution_root, execution_token
  )
  expect_true(ctx$env$mfrmr_cq_ach_validate_attempt_permit(
    permit, arm, execution_root
  ))
  mutated_arm <- arm
  mutated_arm$RunDirectory <- file.path("runs", "redirected")
  expect_false(ctx$env$mfrmr_cq_ach_validate_attempt_permit(
    permit, mutated_arm, execution_root
  ))
  expect_error(
    ctx$env$mfrmr_cq_ach_attempt_permit(
      mutated_arm, execution_root, execution_token
    ),
    "registered arm"
  )
  permit$Consumed <- TRUE
  expect_false(ctx$env$mfrmr_cq_ach_validate_attempt_permit(
    permit, arm, execution_root
  ))
  expect_error(
    ctx$env$mfrmr_cq_ach_sentinel_token_from_assessment(
      assessment,
      ctx$calibration_output,
      "/Applications/ConQuest/ConQuest",
      as.Date("2026-09-01")
    ),
    "exact fresh data-free runtime assessment"
  )
  token$ProcessId <- as.integer(Sys.getpid())
  token$NumericAgreementInspected <- TRUE
  expect_false(validate(
    token, seed$DatasetId, seed$Seed, ctx$calibration_output
  ))
})

test_that("P3 execution routes exist but remain unopened", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  mfrmr <- plan[
    plan$Engine == "mfrmr" & plan$AttemptCap == 1L, , drop = FALSE
  ][1L, ]
  conquest <- plan[
    plan$Engine == "ConQuest" & plan$AttemptCap == 1L, , drop = FALSE
  ][1L, ]
  state <- ctx$env$mfrmr_cq_ach_resource_state()

  expect_error(
    ctx$env$mfrmr_cq_ach_mfrmr_fit("missing", mfrmr),
    "execution-held"
  )
  expect_error(
    ctx$env$mfrmr_cq_ach_conquest_fit(
      "missing", conquest, "/Applications/ConQuest/ConQuest"
    ),
    "execution-held"
  )
  expect_error(
    ctx$env$mfrmr_cq_ach_conquest_fit(
      "missing", conquest, "/tmp/not-the-frozen-conquest",
      authorize = TRUE
    ),
    "one frozen q61/q121 attempt"
  )
  parent <- withr::local_tempdir()
  execution_root <- file.path(parent, ctx$env$mfrmr_cq_ataa_output_basename)
  dir.create(execution_root)
  expect_error(
    ctx$env$mfrmr_cq_ach_mfrmr_fit(
      execution_root, mfrmr, authorize = TRUE
    ),
    "controller-issued one-time attempt permit"
  )
  expect_error(
    ctx$env$mfrmr_cq_ach_conquest_fit(
      execution_root, conquest, "/Applications/ConQuest/ConQuest",
      authorize = TRUE
    ),
    "controller-issued one-time attempt permit"
  )
  expect_error(
    ctx$env$mfrmr_cq_ach_fresh_sentinel(
      "missing", ctx$calibration_output,
      "/Applications/ConQuest/ConQuest", as.Date("2026-08-16")
    ),
    "execution-held"
  )
  expect_error(
    ctx$env$mfrmr_cq_ach_execute(
      "missing", mfrmr, state, new.env(parent = emptyenv())
    ),
    "execution-held"
  )

  source <- paste(readLines(ctx$paths[16L], warn = FALSE), collapse = "\n")
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_false(grepl(
    "mfrmr_cq_ach_execute\\s*\\([^)]*authorize\\s*=\\s*TRUE",
    source, perl = TRUE
  ))
})

test_that("P3 advances exactly five capabilities and remains execution-free", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  review <- ctx$env$mfrmr_cq_ach_p3_review(
    ctx$g4x_output, ctx$calibration_output, ctx$smoke_output
  )
  capability <- ctx$env$mfrmr_cq_ataa_harness_capability_registry()

  expect_identical(
    review$status,
    paste0(
      "ASP_G4C_P3_engine_adapters_artifacts_resources_frozen_",
      "integrated_harness_incomplete"
    )
  )
  expect_identical(review$upstream_and_harness_capabilities_available, 13L)
  expect_identical(review$harness_capabilities_still_missing, 5L)
  expect_true(all(capability$ProviderAvailable[c(1:11, 13:14)]))
  expect_false(any(capability$ProviderAvailable[c(12L, 15:18)]))
  expect_true(review$q61_q121_mfrmr_adapter_implemented)
  expect_true(review$q61_q121_ConQuest_adapter_and_parser_implemented)
  expect_true(review$same_process_sentinel_controller_implemented)
  expect_true(review$artifact_inventory_and_unexpected_file_guard_implemented)
  expect_false(review$output_boundary_inspected)
  expect_true(review$resource_and_peer_continuation_controller_implemented)
  expect_false(review$tranche_A_responses_generated)
  expect_identical(review$fit_attempts, 0L)
  expect_false(review$ConQuest_execution_attempted)
  expect_false(review$response_generation_authorized)
  expect_false(review$execution_authorized)
  expect_false(review$numeric_agreement_inspected)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_identical(
    review$next_action,
    "ASP-G4C-P4-ELIGIBILITY-METRICS-FINALIZATION-REVIEW"
  )
})

test_that("P3 record advances only the internal checklist", {
  ctx <- load_conquest_adversarial_simulation_calibration_p3()
  record <- paste(readLines(file.path(
    ctx$validation,
    paste0(
      "conquest-adversarial-simulation-calibration-harness-engine-",
      "adapters-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_ach_p3_specification, fixed = TRUE)
  expect_match(record, "`HarnessCapabilitiesStillMissing=5`", fixed = TRUE)
  expect_match(record, "`TrancheAResponsesGenerated=FALSE`", fixed = TRUE)
  expect_match(record, "file-byte or hash equality", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] G4C-P3: implement q61/q121 engine adapters",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] G4C-P4: implement G4N application",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze the G4C tranche-A calibration harness",
    fixed = TRUE
  )
})
