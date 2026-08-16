load_conquest_adversarial_simulation_launch_tier_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-adversarial-simulation-launch-tier-contract-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest launch-tier files excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("paired data-free controls isolate the restricted launch route", {
  ctx <- load_conquest_adversarial_simulation_launch_tier_contract()
  observations <- ctx$env$mfrmr_cq_alt_observations()
  review <- ctx$env$mfrmr_cq_alt_review(observations)

  expect_identical(nrow(observations), 3L)
  expect_identical(
    review$Status,
    "runtime_available_unsandboxed_restricted_route_ineligible"
  )
  expect_true(review$RestrictedRouteFailureObserved)
  expect_true(review$UnsandboxedTtyPassed)
  expect_true(review$UnsandboxedFileStdinPassed)
  expect_true(review$RouteContrastComplete)
  expect_true(review$ConQuestPathUsableUnsandboxed)
  expect_false(review$TtyRequired)
  expect_true(review$FileStdinCompatible)
  expect_false(review$RestrictedRouteEligibleForSuccessor)
  expect_true(review$RegistryWriteCrashLocusObserved)
  expect_false(review$RegistryWriteMechanismCausallyProven)
  expect_false(review$ProductFailureInferred)
  expect_false(review$ConsumedG4MAuthorizationReopened)
  expect_false(review$SuccessorExecutionReady)
  expect_false(review$ScientificAgreementInferred)
  expect_false(review$PublicClaimAuthorized)
})

test_that("missing unsandboxed controls weaken diagnosis without widening use", {
  ctx <- load_conquest_adversarial_simulation_launch_tier_contract()
  observations <- ctx$env$mfrmr_cq_alt_observations()
  observations$ExitStatus[observations$InputRoute == "file_stdin" &
                            observations$ExecutionTier == "unsandboxed_host"] <- 9L
  review <- ctx$env$mfrmr_cq_alt_review(observations)

  expect_identical(
    review$Status,
    "runtime_available_unsandboxed_route_contrast_incomplete"
  )
  expect_false(review$UnsandboxedFileStdinPassed)
  expect_false(review$RouteContrastComplete)
  expect_false(review$ConQuestPathUsableUnsandboxed)
  expect_false(review$ProductFailureInferred)
  expect_false(review$SuccessorExecutionReady)

  contaminated <- ctx$env$mfrmr_cq_alt_observations()
  contaminated$ModelDataSupplied[[2L]] <- TRUE
  expect_error(
    ctx$env$mfrmr_cq_alt_review(contaminated),
    "cannot contain model or comparison work"
  )
})

test_that("successor requirements cannot be satisfied by labels or hashes", {
  ctx <- load_conquest_adversarial_simulation_launch_tier_contract()
  requirements <- ctx$env$mfrmr_cq_alt_successor_requirements()

  expect_identical(nrow(requirements), 13L)
  expect_identical(requirements$RequirementOrder, 1:13)
  expect_true(all(requirements$BlocksSuccessorExecution))
  expect_false(any(requirements$MayBeSatisfiedByCallerLabelOnly))
  expect_false(any(requirements$MayBeSatisfiedByFileHashOnly))
  expect_true(requirements$SatisfiedNow[
    requirements$RequirementId == "CONSUMED_G4M_REMAINS_QUARANTINED"
  ])
  expect_true(requirements$SatisfiedNow[
    requirements$RequirementId == "RESTRICTED_LAUNCH_ROUTE_REJECTED"
  ])
  expect_false(requirements$SatisfiedNow[
    requirements$RequirementId == "EXPLICIT_NEW_USER_APPROVAL_RECEIVED"
  ])
  expect_false(requirements$SatisfiedNow[
    requirements$RequirementId ==
      "PREISSUE_DATA_FREE_PROBE_IN_SAME_PROCESS"
  ])
})

test_that("a pre-issue token requires exact semantic evidence and current PID", {
  ctx <- load_conquest_adversarial_simulation_launch_tier_contract()
  summary <- ctx$env$mfrmr_cq_srp_assess(
    console_lines = ctx$env$mfrmr_cq_srp_fixture_transcripts()$clean_demo,
    exit_status = 0L,
    executable_path = ctx$env$mfrmr_cq_alt_observed_executable,
    architecture = "Mach-O 64-bit executable x86_64",
    invocation_route = paste(
      ctx$env$mfrmr_cq_alt_observed_launcher, "-x86_64",
      ctx$env$mfrmr_cq_alt_observed_executable
    ),
    run_date = as.Date("2026-08-16")
  )
  result <- summary
  console_dir <- withr::local_tempdir()
  console_path <- file.path(console_dir, "preissue_runtime_console.log")
  writeLines(result$transcript, console_path, useBytes = TRUE)
  issue_args <- list(
    preflight_result = result,
    expected_executable_path = ctx$env$mfrmr_cq_alt_observed_executable,
    expected_launcher_path = ctx$env$mfrmr_cq_alt_observed_launcher,
    run_not_after = as.Date("2026-08-31"),
    retained_console_path = console_path
  )
  expect_error(
    do.call(ctx$env$mfrmr_cq_alt_issue_preissue_token, issue_args),
    "explicit data-free opt-in"
  )
  token <- do.call(
    ctx$env$mfrmr_cq_alt_issue_preissue_token,
    c(issue_args, list(authorize = TRUE))
  )
  expect_true(ctx$env$mfrmr_cq_alt_validate_preissue_token(
    token,
    expected_executable_path = ctx$env$mfrmr_cq_alt_observed_executable,
    expected_launcher_path = ctx$env$mfrmr_cq_alt_observed_launcher,
    run_date = as.Date("2026-08-16")
  ))

  token$ProcessId <- token$ProcessId + 1L
  expect_false(ctx$env$mfrmr_cq_alt_validate_preissue_token(
    token,
    expected_executable_path = ctx$env$mfrmr_cq_alt_observed_executable,
    expected_launcher_path = ctx$env$mfrmr_cq_alt_observed_launcher,
    run_date = as.Date("2026-08-16")
  ))

  token$ProcessId <- as.integer(Sys.getpid())
  writeLines("mutated console", console_path)
  expect_false(ctx$env$mfrmr_cq_alt_validate_preissue_token(
    token,
    expected_executable_path = ctx$env$mfrmr_cq_alt_observed_executable,
    expected_launcher_path = ctx$env$mfrmr_cq_alt_observed_launcher,
    run_date = as.Date("2026-08-16")
  ))
  writeLines(result$transcript, console_path, useBytes = TRUE)

  bad <- result
  bad$summary$CommandIsDataFreeQuit <- FALSE
  bad_args <- issue_args
  bad_args$preflight_result <- bad
  expect_error(
    do.call(
      ctx$env$mfrmr_cq_alt_issue_preissue_token,
      c(bad_args, list(authorize = TRUE))
    ),
    "exact semantic success"
  )

  stale <- result
  stale$summary$RunDate <- as.Date("2026-09-01")
  stale_args <- issue_args
  stale_args$preflight_result <- stale
  expect_error(
    do.call(
      ctx$env$mfrmr_cq_alt_issue_preissue_token,
      c(stale_args, list(authorize = TRUE))
    ),
    "exact semantic success"
  )
})

test_that("launch-tier work remains internal and nonexecuting", {
  ctx <- load_conquest_adversarial_simulation_launch_tier_contract()
  source <- paste(readLines(ctx$paths[[2L]], warn = FALSE), collapse = "\n")
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-launch-tier-contract-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_match(record, ctx$env$mfrmr_cq_alt_specification, fixed = TRUE)
  expect_match(
    record,
    "runtime_available_unsandboxed_restricted_route_ineligible",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Isolate the consumed G4M sentinel failure as an execution-tier defect",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Freeze a successor G4M specification, target, and authority",
    fixed = TRUE
  )

  probe_body <- paste(
    deparse(body(ctx$env$mfrmr_cq_alt_preissue_probe)), collapse = "\n"
  )
  expect_match(probe_body, "mfrmr_cq_srp_preflight", fixed = TRUE)
  expect_match(probe_body, "preissue_runtime_console.log", fixed = TRUE)
  expect_lt(
    regexpr("mfrmr_cq_srp_preflight", probe_body, fixed = TRUE)[[1L]],
    regexpr("mfrmr_cq_alt_issue_preissue_token", probe_body, fixed = TRUE)[[1L]]
  )
  expect_error(
    ctx$env$mfrmr_cq_alt_preissue_probe(
      executable_path = "/not/launched",
      launcher_path = "/not/launched",
      run_not_after = as.Date("2026-08-31"),
      working_dir = tempdir()
    ),
    "explicit data-free opt-in"
  )
})
