load_conquest_adversarial_simulation_tranche_a_live_authorization <- function() {
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
    ),
    paste0(
      "conquest-adversarial-simulation-calibration-harness-",
      "finalization-0.2.3.R"
    ),
    paste0(
      "conquest-adversarial-simulation-tranche-a-live-",
      "authorization-0.2.3.R"
    )
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G4L files excluded.")
  .mfrmr_test_ensure_source_namespace(root)
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(
    root = root, validation = validation, paths = paths, env = env,
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

g4l_review <- function(
    ctx, output = ctx$calibration_output, worktree_clean = TRUE, ...) {
  ctx$env$mfrmr_cq_atla_review(
    g4x_output_dir = ctx$g4x_output,
    calibration_output_dir = output,
    smoke_output_dir = ctx$smoke_output,
    worktree_clean = worktree_clean,
    ...
  )
}

test_that("G4L freezes 32 nonwaivable gates without issuing authority", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_authorization()
  review <- g4l_review(ctx)
  target_opened <- dir.exists(ctx$calibration_output) ||
    dir.exists(paste0(ctx$calibration_output, ".incomplete"))

  expect_identical(nrow(review$gates), 32L)
  expect_identical(review$gates$GateOrder, 1:32)
  expect_false(any(review$gates$CanBeWaivedForExpiryPressure))
  expect_false(any(review$gates$FailureMayTuneSeedDGPMetricOrThreshold))
  expect_false(any(review$gates$FileHashMaySatisfyGate))
  if (target_opened) {
    expect_identical(review$status, "ASP_G4L_live_authorization_issue_blocked")
    expect_false(review$all_thirty_two_fatal_gates_passed)
    expect_false(review$authorization_issue_ready)
    boundary_gate <- if (dir.exists(ctx$calibration_output)) {
      "CALIBRATION_OUTPUT_TARGET_ABSENT"
    } else {
      "INCOMPLETE_OUTPUT_SIBLING_ABSENT"
    }
    expect_false(review$gates$Passed[review$gates$GateId == boundary_gate])
  } else {
    expect_identical(
      review$status,
      "ASP_G4L_run_once_live_authorization_ready_for_same_process_issue"
    )
    expect_true(all(review$gates$Passed))
    expect_true(review$all_thirty_two_fatal_gates_passed)
    expect_true(review$authorization_issue_ready)
  }
  expect_false(review$positive_authorization_issued)
  expect_false(review$authorization_consumed)
  expect_false(review$fresh_runtime_sentinel_observed)
  expect_false(review$response_generation_authorized_by_review)
  expect_false(review$execution_authorized_by_review)
  expect_false(review$response_generated)
  expect_identical(review$fit_attempts, 0L)
  expect_false(review$ConQuest_execution_attempted)
  expect_false(review$numeric_agreement_inspected)
  expect_false(review$threshold_selected)
  expect_false(review$confirmation_use_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_identical(
    review$next_action,
    "ASP-G4M-SAME-PROCESS-ISSUE-CONSUME-SENTINEL-AND-RUN"
  )
})

test_that("G4L date and local-state gates fail closed", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_authorization()
  dirty <- g4l_review(ctx, worktree_clean = FALSE)
  runtime_dependent <- g4l_review(
    ctx, ordinary_tests_external_runtime_free = FALSE
  )
  early <- g4l_review(ctx, authorization_date = as.Date("2026-08-15"))
  stale <- g4l_review(ctx, authorization_date = as.Date("2026-09-01"))

  expect_identical(dirty$status, "ASP_G4L_live_authorization_issue_blocked")
  expect_false(dirty$gates$Passed[
    dirty$gates$GateId == "WORKTREE_CLEAN_AT_ISSUE_REVIEW"
  ])
  expect_false(runtime_dependent$gates$Passed[
    runtime_dependent$gates$GateId == "ORDINARY_TESTS_EXTERNAL_RUNTIME_FREE"
  ])
  expect_false(early$gates$Passed[
    early$gates$GateId ==
      "AUTHORIZATION_NOT_BEFORE_FROZEN_REVIEW_DATE"
  ])
  expect_false(stale$gates$Passed[
    stale$gates$GateId == "AUTHORIZATION_NOT_AFTER_FROZEN_RUN_DATE"
  ])
  expect_false(stale$gates$Passed[
    stale$gates$GateId == "AUTHORIZATION_PRECEDES_DEMONSTRATION_EXPIRY"
  ])
  expect_false(any(c(
    dirty$positive_authorization_issued,
    runtime_dependent$positive_authorization_issued,
    early$positive_authorization_issued,
    stale$positive_authorization_issued
  )))
})

test_that("G4L rejects opened and incomplete output boundaries", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_authorization()
  parent <- withr::local_tempdir()
  target <- file.path(parent, ctx$env$mfrmr_cq_ataa_output_basename)
  expect_true(dir.create(target))
  opened <- g4l_review(ctx, output = target)
  expect_identical(opened$status, "ASP_G4L_live_authorization_issue_blocked")
  expect_false(opened$gates$Passed[
    opened$gates$GateId == "CALIBRATION_OUTPUT_TARGET_ABSENT"
  ])
  expect_false(opened$gates$Passed[
    opened$gates$GateId == "EXACT_CALIBRATION_OUTPUT_TARGET"
  ])

  parent2 <- withr::local_tempdir()
  target2 <- file.path(parent2, ctx$env$mfrmr_cq_ataa_output_basename)
  expect_true(dir.create(paste0(target2, ".incomplete")))
  incomplete <- g4l_review(ctx, output = target2)
  expect_false(incomplete$gates$Passed[
    incomplete$gates$GateId == "INCOMPLETE_OUTPUT_SIBLING_ABSENT"
  ])
  expect_false(opened$positive_authorization_issued)
  expect_false(incomplete$positive_authorization_issued)
})

test_that("G4L worktree evidence comes from one exact fail-closed Git query", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_authorization()
  call <- new.env(parent = emptyenv())
  clean_runner <- function(command, args, stdout, stderr) {
    call$command <- command
    call$args <- args
    call$stdout <- stdout
    call$stderr <- stderr
    character()
  }
  clean <- ctx$env$mfrmr_cq_atla_git_worktree_review(
    ctx$root, runner = clean_runner
  )
  expect_true(clean$clean)
  expect_identical(clean$exit_status, 0L)
  expect_identical(clean$status_lines, character())
  expect_identical(call$command, "git")
  expect_identical(
    call$args,
    c(
      "-C", shQuote(normalizePath(ctx$root, winslash = "/")),
      "status", "--porcelain=v1", "--untracked-files=all"
    )
  )
  expect_true(call$stdout)
  expect_true(call$stderr)

  dirty <- ctx$env$mfrmr_cq_atla_git_worktree_review(
    ctx$root, runner = function(...) " M tracked-file"
  )
  failed <- ctx$env$mfrmr_cq_atla_git_worktree_review(
    ctx$root,
    runner = function(...) {
      value <- "fatal: not a repository"
      attr(value, "status") <- 128L
      value
    }
  )
  expect_false(dirty$clean)
  expect_identical(dirty$exit_status, 0L)
  expect_false(failed$clean)
  expect_identical(failed$exit_status, 128L)
})

test_that("G4L is the exact P4 issuer but remains opt-in and uncalled", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_authorization()
  schema <- ctx$env$mfrmr_cq_ach_authorization_schema()
  expect_identical(nrow(schema), 28L)
  expect_identical(
    schema$P4RequiredValue[schema$Field == "AuthorizationIssuerContract"],
    ctx$env$mfrmr_cq_atla_contract
  )
  expect_identical(
    ctx$env$mfrmr_cq_atla_contract,
    ctx$env$mfrmr_cq_ach_required_authorization_issuer_contract
  )
  expect_error(
    ctx$env$mfrmr_cq_atla_issue(
      ctx$g4x_output, ctx$calibration_output, ctx$smoke_output
    ),
    "held without explicit same-process opt-in"
  )
  expect_error(
    ctx$env$mfrmr_cq_atla_issue(
      ctx$g4x_output, ctx$calibration_output, ctx$smoke_output,
      authorization_date = as.Date("2026-09-01"),
      ordinary_tests_external_runtime_free = TRUE,
      authorize = TRUE
    ),
    "blocked by one or more fatal gates"
  )

  source <- paste(readLines(ctx$paths[18L], warn = FALSE), collapse = "\n")
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  system2_hits <- gregexpr("base::system2", source, fixed = TRUE)[[1L]]
  expect_identical(sum(system2_hits > 0L), 1L)
  expect_false(grepl(
    "mfrmr_cq_atla_issue\\s*\\([^)]*authorize\\s*=\\s*TRUE",
    source, perl = TRUE
  ))
  expect_false(grepl(
    "mfrmr_cq_ach_(fresh_sentinel|generate_dataset|execute)\\s*\\(",
    source, perl = TRUE
  ))
})

test_that("G4L record advances only the internal execution checklist", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_authorization()
  record <- paste(readLines(file.path(
    ctx$validation,
    paste0(
      "conquest-adversarial-simulation-tranche-a-live-",
      "authorization-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_atla_specification, fixed = TRUE)
  expect_match(record, "`AllThirtyTwoFatalGatesPassed=TRUE`", fixed = TRUE)
  expect_match(record, "`PositiveAuthorizationIssued=FALSE`", fixed = TRUE)
  expect_match(record, "file-byte or hash equality", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze a separate target-bound G4L run-once live authorization",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Run the frozen disjoint calibration band",
    fixed = TRUE
  )
})
