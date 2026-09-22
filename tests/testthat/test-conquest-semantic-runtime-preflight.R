load_conquest_semantic_runtime_preflight <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  path <- file.path(
    validation, "conquest-semantic-runtime-preflight-0.2.3.R"
  )
  skip_if_not(
    file.exists(path),
    "Repository-only ConQuest semantic runtime preflight is excluded."
  )
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  list(root = root, validation = validation, path = path, env = env)
}

test_that("clean data-free transcript passes the typed C0 boundary", {
  ctx <- load_conquest_semantic_runtime_preflight()
  transcript <- ctx$env$mfrmr_cq_srp_fixture_transcripts()$clean_demo
  result <- ctx$env$mfrmr_cq_srp_assess(
    console_lines = transcript,
    exit_status = 0L,
    executable_path = "/explicit/test/path",
    architecture = "Mach-O 64-bit executable x86_64",
    invocation_route = "/explicit/arch -x86_64 /explicit/test/path",
    locale = "C",
    run_date = as.Date("2026-08-15")
  )

  expect_identical(result$summary$Status, "runtime_semantic_ready")
  expect_identical(result$summary$RuntimeVersion, "5.47.5")
  expect_identical(result$summary$RuntimeEdition, "Demonstration Version")
  expect_identical(result$summary$ExpiryDate, as.Date("2026-09-01"))
  expect_true(result$summary$TerminalMarkerPresent)
  expect_true(result$summary$CompleteOutputSet)
  expect_true(result$summary$CommandIsDataFreeQuit)
  expect_false(result$summary$ModelEstimationAttempted)
  expect_true(is.na(result$summary$ModelEstimationSuccess))
  expect_true(result$summary$SemanticSuccess)
  expect_false(result$summary$ScientificComparisonAuthorized)
  expect_identical(nrow(result$observed_failures), 0L)
})

test_that("status-zero semantic failures fail closed by primary class", {
  ctx <- load_conquest_semantic_runtime_preflight()
  fixtures <- ctx$env$mfrmr_cq_srp_fixture_transcripts()
  assess <- function(lines) ctx$env$mfrmr_cq_srp_assess(
    console_lines = lines,
    exit_status = 0L,
    executable_path = "/explicit/test/path",
    architecture = "Mach-O 64-bit executable x86_64",
    invocation_route = "explicit-test-route",
    locale = "C",
    run_date = as.Date("2026-08-15")
  )

  unknown <- assess(fixtures$status_zero_unknown_command)
  expect_identical(unknown$summary$Status, "semantic_execution_failure")
  expect_match(unknown$summary$FailureCodes, "unknown_command", fixed = TRUE)
  expect_false(unknown$summary$SemanticSuccess)

  missing <- assess(fixtures$status_zero_missing_data)
  expect_identical(missing$summary$Status, "semantic_execution_failure")
  expect_match(
    missing$summary$FailureCodes,
    "datafile_missing_or_unreadable",
    fixed = TRUE
  )
  expect_false(missing$summary$SemanticSuccess)

  incomplete <- assess(fixtures$incomplete_console)
  expect_identical(incomplete$summary$Status, "semantic_execution_failure")
  expect_match(
    incomplete$summary$FailureCodes, "terminal_marker_missing", fixed = TRUE
  )
  expect_false(incomplete$summary$SemanticSuccess)
})

test_that("expiry and process failure remain distinct typed states", {
  ctx <- load_conquest_semantic_runtime_preflight()
  fixtures <- ctx$env$mfrmr_cq_srp_fixture_transcripts()
  common <- list(
    executable_path = "/explicit/test/path",
    architecture = "Mach-O 64-bit executable x86_64",
    invocation_route = "explicit-test-route",
    locale = "C"
  )
  expired <- do.call(ctx$env$mfrmr_cq_srp_assess, c(list(
    console_lines = fixtures$expired_demo,
    exit_status = 0L,
    run_date = as.Date("2026-09-02")
  ), common))
  expect_identical(
    expired$summary$Status, "runtime_unavailable_or_expired"
  )
  expect_true(expired$summary$ExpiredByDate)
  expect_match(expired$summary$FailureCodes, "runtime_expired", fixed = TRUE)

  nonzero <- do.call(ctx$env$mfrmr_cq_srp_assess, c(list(
    console_lines = fixtures$clean_demo,
    exit_status = 17L,
    run_date = as.Date("2026-08-15")
  ), common))
  expect_identical(nonzero$summary$Status, "semantic_execution_failure")
  expect_match(
    nonzero$summary$FailureCodes, "process_exit_nonzero", fixed = TRUE
  )
  expect_false(nonzero$summary$SemanticSuccess)
})

test_that("an incomplete expected output set cannot disappear", {
  ctx <- load_conquest_semantic_runtime_preflight()
  outputs <- data.frame(
    OutputId = c("console", "parameters"),
    Present = c(TRUE, FALSE),
    Nonempty = c(TRUE, FALSE),
    stringsAsFactors = FALSE
  )
  result <- ctx$env$mfrmr_cq_srp_assess(
    console_lines = ctx$env$mfrmr_cq_srp_fixture_transcripts()$clean_demo,
    exit_status = 0L,
    executable_path = "/explicit/test/path",
    architecture = "Mach-O 64-bit executable x86_64",
    invocation_route = "explicit-test-route",
    locale = "C",
    run_date = as.Date("2026-08-15"),
    output_contract = outputs
  )

  expect_identical(result$summary$ExpectedOutputCount, 2L)
  expect_false(result$summary$CompleteOutputSet)
  expect_match(
    result$summary$FailureCodes, "incomplete_output_set", fixed = TRUE
  )
  expect_identical(result$summary$Status, "semantic_execution_failure")
})

test_that("the reusable preflight requires a path and never fits a model", {
  ctx <- load_conquest_semantic_runtime_preflight()
  executable <- Sys.which("R")
  skip_if_not(nzchar(executable), "An executable R front end is unavailable.")
  observed <- new.env(parent = emptyenv())
  runner <- function(command, args, stdin, working_dir, timeout) {
    observed$command <- command
    observed$args <- args
    observed$stdin <- stdin
    observed$working_dir <- working_dir
    observed$timeout <- timeout
    list(
      console_lines =
        ctx$env$mfrmr_cq_srp_fixture_transcripts()$clean_demo,
      exit_status = 0L,
      host_error = NA_character_
    )
  }
  inspector <- function(executable_path) list(
    architecture = "test executable architecture",
    raw = executable_path,
    status = 0L
  )
  result <- ctx$env$mfrmr_cq_srp_preflight(
    conquest_exe = executable,
    run_date = as.Date("2026-08-15"),
    locale = "C",
    runner = runner,
    inspector = inspector
  )

  expect_identical(observed$stdin, "quit;")
  expect_identical(observed$command, normalizePath(
    executable, winslash = "/", mustWork = TRUE
  ))
  expect_identical(observed$args, character(0))
  expect_identical(result$summary$Status, "runtime_semantic_ready")
  expect_false(result$summary$ModelEstimationAttempted)
  expect_false(result$summary$ScientificComparisonAuthorized)
  expect_false(dir.exists(observed$working_dir))
  expect_error(
    ctx$env$mfrmr_cq_srp_preflight(
      conquest_exe = character(0), runner = runner, inspector = inspector
    ),
    "explicit nonempty path",
    fixed = TRUE
  )
  source_text <- paste(readLines(ctx$path, warn = FALSE), collapse = "\n")
  expect_false(grepl("/Applications/ConQuest", source_text, fixed = TRUE))
})

test_that("an unavailable executable is typed without calling the runner", {
  ctx <- load_conquest_semantic_runtime_preflight()
  called <- FALSE
  runner <- function(...) {
    called <<- TRUE
    stop("runner must not be called")
  }
  absent <- file.path(
    tempdir(), "mfrmr-deliberately-absent-conquest-executable"
  )
  result <- ctx$env$mfrmr_cq_srp_preflight(
    conquest_exe = absent,
    run_date = as.Date("2026-08-15"),
    locale = "C",
    runner = runner,
    inspector = function(...) stop("inspector must not be called")
  )

  expect_false(called)
  expect_identical(
    result$summary$Status, "runtime_unavailable_or_expired"
  )
  expect_match(
    result$summary$FailureCodes, "executable_missing", fixed = TRUE
  )
  expect_false(result$summary$SemanticSuccess)
  expect_false(result$summary$ScientificComparisonAuthorized)
})

test_that("runtime availability and estimation success are never conflated", {
  ctx <- load_conquest_semantic_runtime_preflight()
  fields <- names(ctx$env$mfrmr_cq_srp_assess(
    console_lines = ctx$env$mfrmr_cq_srp_fixture_transcripts()$clean_demo,
    exit_status = 0L,
    executable_path = "/explicit/test/path",
    architecture = "test architecture",
    invocation_route = "test route",
    locale = "C",
    run_date = as.Date("2026-08-15")
  )$summary)
  expect_true(all(c(
    "RuntimeAvailable", "SemanticSuccess", "ModelEstimationAttempted",
    "ModelEstimationSuccess", "ScientificComparisonAuthorized"
  ) %in% fields))
})

test_that("a missing explicit launcher is not mislabelled as engine success", {
  ctx <- load_conquest_semantic_runtime_preflight()
  executable <- Sys.which("R")
  skip_if_not(nzchar(executable), "An executable R front end is unavailable.")
  result <- ctx$env$mfrmr_cq_srp_preflight(
    conquest_exe = executable,
    launcher = file.path(tempdir(), "deliberately-absent-launcher"),
    run_date = as.Date("2026-08-15"),
    runner = function(...) stop("runner must not be called"),
    inspector = function(...) stop("inspector must not be called")
  )

  expect_false(result$summary$RuntimeAvailable)
  expect_true(result$summary$ExecutableAvailable)
  expect_false(result$summary$LauncherAvailable)
  expect_match(
    result$summary$FailureCodes,
    "launcher_missing_or_not_executable",
    fixed = TRUE
  )
  expect_identical(
    result$summary$Status, "runtime_unavailable_or_expired"
  )
})

test_that("a replacement runtime requires the smallest numerical sentinel", {
  ctx <- load_conquest_semantic_runtime_preflight()
  preflight <- ctx$env$mfrmr_cq_srp_assess(
    console_lines = ctx$env$mfrmr_cq_srp_fixture_transcripts()$clean_demo,
    exit_status = 0L,
    executable_path = "/explicit/test/path",
    architecture = "test architecture",
    invocation_route = "test route",
    locale = "C",
    run_date = as.Date("2026-08-15")
  )
  blocked <- ctx$env$mfrmr_cq_srp_replacement_gate(
    preflight,
    runtime_change_declared = TRUE,
    numerical_sentinel = "not_run"
  )
  expect_false(blocked$BroaderProspectiveExecutionEligible)
  expect_match(blocked$Status, "sentinel_not_run", fixed = TRUE)
  expect_false(blocked$PriorEvidenceAutomaticallyReclassified)

  eligible <- ctx$env$mfrmr_cq_srp_replacement_gate(
    preflight,
    runtime_change_declared = TRUE,
    numerical_sentinel = "passed"
  )
  expect_true(eligible$BroaderProspectiveExecutionEligible)
  expect_false(eligible$PriorEvidenceAutomaticallyReclassified)
  expect_false(eligible$ScientificEquivalenceInferred)

  unchanged <- ctx$env$mfrmr_cq_srp_replacement_gate(
    preflight,
    runtime_change_declared = FALSE,
    numerical_sentinel = "not_required"
  )
  expect_true(unchanged$BroaderProspectiveExecutionEligible)
  expect_identical(
    unchanged$Status, "unchanged_runtime_semantic_preflight_passed"
  )
})

test_that("the P0 record preserves semantics without claiming a fit", {
  ctx <- load_conquest_semantic_runtime_preflight()
  record_path <- file.path(
    ctx$validation,
    "conquest-semantic-runtime-preflight-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  expected <- c(
    ctx$env$mfrmr_cq_srp_specification,
    ctx$env$mfrmr_cq_srp_contract,
    "runtime_semantic_ready",
    "ConQuest version: 5.47.5",
    "Demonstration Version",
    "This version expires 1 September 2026",
    "<End of Program",
    "Model estimation attempted | `FALSE`",
    "Scientific comparison authorized | `FALSE`"
  )
  expect_true(all(vapply(
    expected, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_match(
    record,
    "test-conquest-semantic-runtime-preflight.R",
    fixed = TRUE
  )
  expect_match(
    record,
    "ordinary package tests do not require ConQuest",
    fixed = TRUE
  )
  expect_match(record, "independent[[:space:]]+review pending")
})
