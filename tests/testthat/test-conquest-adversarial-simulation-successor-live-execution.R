load_conquest_adversarial_simulation_successor <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  path <- file.path(
    root, "inst", "validation",
    "conquest-adversarial-simulation-successor-live-execution-0.2.3.R"
  )
  skip_if_not(file.exists(path), "ConQuest ASP G4O file excluded.")
  pkgload::load_all(root, quiet = TRUE)
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env$mfrmr_cq_ag4o_source_contracts(root, env)
  list(
    root = root, path = path, env = env,
    smoke_output = file.path(
      root, "validation-results", env$mfrmr_cq_ase_output_basename
    ),
    g4x_output = file.path(
      root, "validation-results", env$mfrmr_cq_amea_output_basename
    ),
    output = file.path(
      root, "validation-results", env$mfrmr_cq_ag4o_output_basename
    )
  )
}

test_that("G4O binds a new target and issuer without reopening v1", {
  ctx <- load_conquest_adversarial_simulation_successor()
  expect_no_error(ctx$env$mfrmr_cq_ag4m_require_contracts())
  skip_if(
    any(file.exists(c(
      ctx$output, paste0(ctx$output, ".incomplete"),
      paste0(ctx$output, ".preissue")
    ))),
    "G4O successor output has been opened."
  )
  review <- ctx$env$mfrmr_cq_ag4o_review(
    ctx$g4x_output, ctx$smoke_output,
    run_date = as.Date("2026-08-16"),
    worktree_clean_attested = TRUE,
    approval_id = ctx$env$mfrmr_cq_ag4o_approval_id
  )

  expect_identical(
    basename(review$output_dir),
    "conquest-adversarial-simulation-calibration-tranche-a-20260816-v2"
  )
  expect_false(grepl("-v1$", review$output_dir))
  expect_identical(
    review$authorization_contract,
    ctx$env$mfrmr_cq_ag4o_authorization_contract
  )
  expect_true(review$user_approval_received)
  expect_true(review$all_successor_paths_absent)
  expect_true(review$ready_for_live_preissue)
  expect_false(review$preissue_probe_attempted)
  expect_false(review$run_authority_issued)
  expect_false(review$model_estimation_attempted)
  expect_false(review$public_claim_authorized)
})

test_that("retained G4O v2 output is reviewable without rerunning", {
  ctx <- load_conquest_adversarial_simulation_successor()
  skip_if_not(dir.exists(ctx$output), "Retained G4O v2 output is absent.")
  review <- ctx$env$mfrmr_cq_ag4m_review(ctx$output)

  expect_true(review$p4_review$run_once_authorization_consumed)
  expect_identical(nrow(review$p4_review$tables$attempt_journal), 190L)
  expect_true(review$p4_review$metric_contract_complete)
  expect_true(review$retained_numeric_detail_reconstructed)
  expect_true(review$retained_execution_review_complete)
  expect_false(review$rerun_authorized)
  expect_false(review$confirmation_use_authorized)
  expect_false(review$public_claim_authorized)

  result_record <- paste(readLines(file.path(
    ctx$root, "inst", "validation",
    paste0(
      "conquest-adversarial-simulation-successor-live-execution-",
      "result-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  expect_match(
    result_record,
    "ASP_G4M_tranche_A_execution_retained_review_complete_exploratory_only",
    fixed = TRUE
  )
  expect_match(result_record, "`FitAttempts=190`", fixed = TRUE)
  expect_match(result_record, "`ScientificEquivalenceInferred=FALSE`", fixed = TRUE)
})

test_that("G4O review separates float roundtrip from material drift", {
  ctx <- load_conquest_adversarial_simulation_successor()
  expected <- data.frame(
    Id = c("a", "b"),
    Value = c(1, 421844.8),
    Count = c(1L, 2L),
    stringsAsFactors = FALSE
  )
  roundtrip <- expected
  roundtrip$Value[[2L]] <- roundtrip$Value[[2L]] + 5.820766091346741e-11
  material <- roundtrip
  material$Value[[2L]] <- material$Value[[2L]] + 1e-6
  relabelled <- expected
  relabelled$Id[[2L]] <- "changed"

  expect_true(ctx$env$mfrmr_cq_ag4o_same_frame(roundtrip, expected))
  expect_false(ctx$env$mfrmr_cq_ag4o_same_frame(material, expected))
  expect_false(ctx$env$mfrmr_cq_ag4o_same_frame(relabelled, expected))
})

test_that("G4O positive route requires the exact new approval", {
  ctx <- load_conquest_adversarial_simulation_successor()
  expect_error(
    ctx$env$mfrmr_cq_ag4o_execute(ctx$g4x_output),
    "exact new user approval"
  )
  expect_error(
    ctx$env$mfrmr_cq_ag4o_execute(
      ctx$g4x_output,
      approval_id = "consumed-v1-approval",
      authorize = TRUE
    ),
    "exact new user approval"
  )
})

test_that("G4O consumes a current-process preissue token before issue", {
  ctx <- load_conquest_adversarial_simulation_successor()
  console_dir <- withr::local_tempdir()
  console_path <- file.path(console_dir, "preissue_runtime_console.log")
  transcript <- ctx$env$mfrmr_cq_srp_fixture_transcripts()$clean_demo
  writeLines(transcript, console_path, useBytes = TRUE)
  preflight <- ctx$env$mfrmr_cq_srp_assess(
    console_lines = transcript,
    exit_status = 0L,
    executable_path = ctx$env$mfrmr_cq_ag4o_executable_path,
    architecture = "Mach-O 64-bit executable x86_64",
    invocation_route = paste(
      ctx$env$mfrmr_cq_ag4o_launcher_path, "-x86_64",
      ctx$env$mfrmr_cq_ag4o_executable_path
    ),
    run_date = as.Date("2026-08-16")
  )
  token <- ctx$env$mfrmr_cq_alt_issue_preissue_token(
    preflight_result = preflight,
    expected_executable_path = ctx$env$mfrmr_cq_ag4o_executable_path,
    expected_launcher_path = ctx$env$mfrmr_cq_ag4o_launcher_path,
    run_not_after = ctx$env$mfrmr_cq_ag4o_run_not_after,
    retained_console_path = console_path,
    authorize = TRUE
  )
  observed_consumed <- FALSE
  assign("mfrmr_cq_atla_issue", function(...) {
    observed_consumed <<- isTRUE(token$Consumed)
    authority <- new.env(parent = emptyenv())
    authority$AuthorizationIssuerContract <-
      ctx$env$mfrmr_cq_ag4o_authorization_contract
    authority$Consumed <- FALSE
    authority
  }, envir = ctx$env)

  authority <- ctx$env$mfrmr_cq_ag4o_issue(
    token, ctx$g4x_output, ctx$output, ctx$smoke_output,
    run_date = as.Date("2026-08-16"),
    approval_id = ctx$env$mfrmr_cq_ag4o_approval_id,
    authorize = TRUE
  )
  expect_true(observed_consumed)
  expect_true(token$Consumed)
  expect_false(authority$Consumed)
})

test_that("G4O source is nonexecuting and preserves probe ordering", {
  ctx <- load_conquest_adversarial_simulation_successor()
  source <- paste(readLines(ctx$path, warn = FALSE), collapse = "\n")
  body <- paste(deparse(body(ctx$env$mfrmr_cq_ag4o_execute)), collapse = "\n")

  expect_false(grepl("system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_lt(
    regexpr("mfrmr_cq_atla_git_worktree_review", body, fixed = TRUE)[[1L]],
    regexpr("mfrmr_cq_alt_preissue_probe", body, fixed = TRUE)[[1L]]
  )
  expect_lt(
    regexpr("mfrmr_cq_alt_preissue_probe", body, fixed = TRUE)[[1L]],
    regexpr("mfrmr_cq_ag4o_issue", body, fixed = TRUE)[[1L]]
  )
  expect_lt(
    regexpr("mfrmr_cq_ag4o_issue", body, fixed = TRUE)[[1L]],
    regexpr("mfrmr_cq_ach_consume_authorization", body, fixed = TRUE)[[1L]]
  )
  expect_lt(
    regexpr("mfrmr_cq_ach_consume_authorization", body, fixed = TRUE)[[1L]],
    regexpr("mfrmr_cq_ach_fresh_sentinel", body, fixed = TRUE)[[1L]]
  )

  record <- paste(readLines(file.path(
    ctx$root, "inst", "validation",
    "conquest-adversarial-simulation-successor-live-execution-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$root, "inst", "validation", "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  expect_match(record, ctx$env$mfrmr_cq_ag4o_specification, fixed = TRUE)
  expect_match(record, "`ExplicitNewUserApprovalReceived=TRUE`", fixed = TRUE)
  expect_match(record, "`LiveExecutionPerformedByThisRecord=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze a successor G4M specification, target, and authority",
    fixed = TRUE
  )
})
