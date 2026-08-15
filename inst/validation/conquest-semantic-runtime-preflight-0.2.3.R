# Repository-only ConQuest semantic runtime preflight for mfrmr 0.2.3.
#
# This file owns the reusable C0 runtime boundary. Sourcing it has no side
# effects. The public entry point requires an explicit executable path, sends
# only `quit;`, fits no model, and does not authorize a numerical comparison.

mfrmr_cq_srp_specification <-
  "0.2.3-conquest-semantic-runtime-preflight-v1"
mfrmr_cq_srp_contract <- "mfrmr_conquest_semantic_runtime_preflight_v1"
mfrmr_cq_srp_terminal_marker <- "End of Program"
mfrmr_cq_srp_stdin <- "quit;"

mfrmr_cq_srp_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_srp_failure_registry <- function() {
  data.frame(
    FailureCode = c(
      "unknown_command",
      "regression_statement_error",
      "estimation_unavailable",
      "model_not_estimated",
      "compute_command_error",
      "print_command_error",
      "equation_symbol_error",
      "datafile_missing_or_unreadable",
      "runtime_expired_message",
      "licence_failure",
      "fatal_runtime_error"
    ),
    PrimaryClass = c(
      rep("semantic_execution_failure", 8L),
      "runtime_unavailable_or_expired",
      "runtime_unavailable_or_expired",
      "semantic_execution_failure"
    ),
    Regex = c(
      "Unknown command or argument:",
      "Error in Regression statement",
      "Can't do estimation",
      "A model must be estimated",
      "Compute command error",
      "Print cannot show object:",
      "Unknown symbol in equation:",
      paste0(
        "Data file name not specified|cannot open (the )?data file|",
        "can't open (the )?data file|data file[^[:cntrl:]]*not found"
      ),
      paste0(
        "(demonstration |trial )?version (has )?expired|",
        "licen[cs]e (has )?expired"
      ),
      "licen[cs]e[^[:cntrl:]]*(invalid|failed|failure|unavailable)",
      "fatal error|segmentation fault|trace/bpt trap"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_srp_fixture_transcripts <- function() {
  list(
    clean_demo = c(
      "ConQuest version: 5.47.5",
      "Demonstration Version",
      "This version expires 1 September 2026",
      "<quit;",
      "End of Program"
    ),
    status_zero_unknown_command = c(
      "ConQuest version: 5.47.5",
      "Demonstration Version",
      "This version expires 1 September 2026",
      "Unknown command or argument: deliberately_invalid_command",
      "End of Program"
    ),
    status_zero_missing_data = c(
      "ConQuest version: 5.47.5",
      "Demonstration Version",
      "This version expires 1 September 2026",
      "Cannot open data file deliberately_missing.dat",
      "End of Program"
    ),
    incomplete_console = c(
      "ConQuest version: 5.47.5",
      "Demonstration Version",
      "This version expires 1 September 2026",
      "<quit;"
    ),
    expired_demo = c(
      "ConQuest version: 5.47.5",
      "Demonstration Version",
      "This version expires 1 September 2026",
      "This demonstration version has expired"
    )
  )
}

mfrmr_cq_srp_empty_output_contract <- function() {
  data.frame(
    OutputId = character(0),
    Present = logical(0),
    Nonempty = logical(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_srp_validate_output_contract <- function(output_contract) {
  required <- c("OutputId", "Present", "Nonempty")
  mfrmr_cq_srp_assert(
    is.data.frame(output_contract) && all(required %in% names(output_contract)),
    "`output_contract` must contain OutputId, Present, and Nonempty."
  )
  mfrmr_cq_srp_assert(
    !anyNA(output_contract[, required, drop = FALSE]),
    "The output contract cannot contain missing values."
  )
  mfrmr_cq_srp_assert(
    !anyDuplicated(as.character(output_contract$OutputId)),
    "The output contract must have unique OutputId values."
  )
  mfrmr_cq_srp_assert(
    is.logical(output_contract$Present) &&
      is.logical(output_contract$Nonempty),
    "Output-contract presence fields must be logical."
  )
  output_contract[, required, drop = FALSE]
}

mfrmr_cq_srp_parse_expiry_date <- function(expiry_text) {
  if (length(expiry_text) != 1L || is.na(expiry_text) || !nzchar(expiry_text)) {
    return(as.Date(NA))
  }
  months <- c(
    january = 1L, february = 2L, march = 3L, april = 4L,
    may = 5L, june = 6L, july = 7L, august = 8L,
    september = 9L, october = 10L, november = 11L, december = 12L
  )
  match <- regexec(
    paste0(
      "([0-9]{1,2})[[:space:]]+(",
      paste(names(months), collapse = "|"),
      ")[[:space:]]+([0-9]{4})"
    ),
    expiry_text,
    ignore.case = TRUE,
    perl = TRUE
  )
  parts <- regmatches(expiry_text, match)[[1L]]
  if (length(parts) != 4L) return(as.Date(NA))
  month <- unname(months[[tolower(parts[3L])]])
  as.Date(sprintf("%04d-%02d-%02d", as.integer(parts[4L]), month,
                  as.integer(parts[2L])))
}

mfrmr_cq_srp_extract_runtime_identity <- function(console_lines) {
  lines <- enc2utf8(as.character(console_lines))
  version_index <- grep(
    "ConQuest[[:space:]]+version[[:space:]]*:", lines,
    ignore.case = TRUE
  )
  version <- if (length(version_index) > 0L) {
    trimws(sub(
      ".*ConQuest[[:space:]]+version[[:space:]]*:[[:space:]]*", "",
      lines[version_index[1L]], ignore.case = TRUE
    ))
  } else {
    NA_character_
  }
  edition_index <- grep(
    "(Demonstration|Trial|Educational|Research|Full)[[:space:]]+Version",
    lines,
    ignore.case = TRUE
  )
  edition <- if (length(edition_index) > 0L) {
    trimws(lines[edition_index[1L]])
  } else {
    "unspecified_by_runtime"
  }
  expiry_index <- grep(
    "version[[:space:]]+expires", lines,
    ignore.case = TRUE
  )
  expiry_text <- if (length(expiry_index) > 0L) {
    trimws(lines[expiry_index[1L]])
  } else {
    NA_character_
  }
  list(
    version = version,
    edition = edition,
    expiry_text = expiry_text,
    expiry_date = mfrmr_cq_srp_parse_expiry_date(expiry_text)
  )
}

mfrmr_cq_srp_observed_failures <- function(console_lines) {
  lines <- enc2utf8(as.character(console_lines))
  registry <- mfrmr_cq_srp_failure_registry()
  matches <- lapply(registry$Regex, function(pattern) {
    which(grepl(pattern, lines, ignore.case = TRUE, perl = TRUE))
  })
  registry$Observed <- lengths(matches) > 0L
  registry$LineNumbers <- vapply(
    matches, function(index) paste(index, collapse = ","), character(1L)
  )
  registry$MatchedText <- vapply(matches, function(index) {
    paste(lines[index], collapse = " | ")
  }, character(1L))
  registry
}

mfrmr_cq_srp_assess <- function(
    console_lines,
    exit_status,
    executable_path,
    executable_available = TRUE,
    executable = TRUE,
    launcher_available = TRUE,
    architecture = NA_character_,
    invocation_route = NA_character_,
    locale = Sys.getlocale(),
    run_date = Sys.Date(),
    command_is_data_free_quit = TRUE,
    host_error = NA_character_,
    output_contract = mfrmr_cq_srp_empty_output_contract()) {
  output_contract <- mfrmr_cq_srp_validate_output_contract(output_contract)
  lines <- enc2utf8(as.character(console_lines))
  exit_status <- if (length(exit_status) == 0L || is.na(exit_status[1L])) {
    NA_integer_
  } else {
    as.integer(exit_status[1L])
  }
  run_date <- as.Date(run_date)[1L]
  mfrmr_cq_srp_assert(!is.na(run_date), "`run_date` must be a valid Date.")
  identity <- mfrmr_cq_srp_extract_runtime_identity(lines)
  failures <- mfrmr_cq_srp_observed_failures(lines)
  terminal_marker_present <- any(grepl(
    paste0("(^|[^[:alnum:]])", mfrmr_cq_srp_terminal_marker,
           "[[:space:]]*$"),
    lines,
    perl = TRUE
  ))
  demonstration <- grepl(
    "Demonstration|Trial", identity$edition, ignore.case = TRUE
  )
  expiry_present <- !is.na(identity$expiry_text) &&
    nzchar(identity$expiry_text)
  expiry_parsed <- !is.na(identity$expiry_date)
  expired_by_date <- expiry_parsed && run_date > identity$expiry_date
  complete_output_set <- nrow(output_contract) == 0L ||
    all(output_contract$Present & output_contract$Nonempty)
  host_error_present <- length(host_error) == 1L && !is.na(host_error) &&
    nzchar(host_error)
  synthetic_failures <- character(0)
  if (!isTRUE(executable_available)) {
    synthetic_failures <- c(synthetic_failures, "executable_missing")
  } else if (!isTRUE(executable)) {
    synthetic_failures <- c(synthetic_failures, "executable_not_executable")
  }
  if (!isTRUE(launcher_available)) {
    synthetic_failures <- c(
      synthetic_failures, "launcher_missing_or_not_executable"
    )
  }
  if (is.na(exit_status)) {
    synthetic_failures <- c(synthetic_failures, "exit_status_missing")
  } else if (exit_status != 0L) {
    synthetic_failures <- c(synthetic_failures, "process_exit_nonzero")
  }
  if (host_error_present) {
    synthetic_failures <- c(synthetic_failures, "host_execution_error")
  }
  if (!terminal_marker_present) {
    synthetic_failures <- c(synthetic_failures, "terminal_marker_missing")
  }
  if (is.na(identity$version) || !nzchar(identity$version)) {
    synthetic_failures <- c(synthetic_failures, "runtime_version_missing")
  }
  if (length(architecture) != 1L || is.na(architecture) ||
      !nzchar(architecture)) {
    synthetic_failures <- c(synthetic_failures, "architecture_missing")
  }
  if (!isTRUE(command_is_data_free_quit)) {
    synthetic_failures <- c(synthetic_failures, "non_sentinel_input")
  }
  if (demonstration && (!expiry_present || !expiry_parsed)) {
    synthetic_failures <- c(synthetic_failures,
                             "demonstration_expiry_missing_or_unparsed")
  }
  if (expired_by_date) {
    synthetic_failures <- c(synthetic_failures, "runtime_expired_by_date")
  }
  if (!complete_output_set) {
    synthetic_failures <- c(synthetic_failures, "incomplete_output_set")
  }
  observed <- failures[failures$Observed, , drop = FALSE]
  expired_message <- any(
    observed$PrimaryClass == "runtime_unavailable_or_expired"
  )
  runtime_available <- isTRUE(executable_available) && isTRUE(executable) &&
    isTRUE(launcher_available)
  runtime_unavailable <- !runtime_available || expired_by_date ||
    expired_message
  all_failure_codes <- c(observed$FailureCode, synthetic_failures)
  semantic_success <- !runtime_unavailable && identical(exit_status, 0L) &&
    !host_error_present && terminal_marker_present && nrow(observed) == 0L &&
    !is.na(identity$version) && nzchar(identity$version) &&
    length(architecture) == 1L && !is.na(architecture) &&
    nzchar(architecture) && isTRUE(command_is_data_free_quit) &&
    (!demonstration || (expiry_present && expiry_parsed)) &&
    complete_output_set
  status <- if (runtime_unavailable) {
    "runtime_unavailable_or_expired"
  } else if (semantic_success) {
    "runtime_semantic_ready"
  } else {
    "semantic_execution_failure"
  }
  summary <- data.frame(
    Specification = mfrmr_cq_srp_specification,
    ContractVersion = mfrmr_cq_srp_contract,
    Status = status,
    PrimaryFailureClass = if (semantic_success) NA_character_ else status,
    FailureCodes = if (length(all_failure_codes) > 0L) {
      paste(unique(all_failure_codes), collapse = ";")
    } else {
      ""
    },
    ExecutablePath = as.character(executable_path)[1L],
    RuntimeAvailable = runtime_available,
    ExecutableAvailable = isTRUE(executable_available),
    Executable = isTRUE(executable),
    LauncherAvailable = isTRUE(launcher_available),
    Architecture = if (length(architecture) == 1L) {
      as.character(architecture)
    } else {
      NA_character_
    },
    InvocationRoute = if (length(invocation_route) == 1L) {
      as.character(invocation_route)
    } else {
      NA_character_
    },
    Locale = paste(as.character(locale), collapse = ";"),
    RunDate = run_date,
    ExitStatus = exit_status,
    TerminalMarkerPresent = terminal_marker_present,
    RuntimeVersion = identity$version,
    RuntimeEdition = identity$edition,
    ExpiryText = identity$expiry_text,
    ExpiryDate = identity$expiry_date,
    ExpiredByDate = expired_by_date,
    RegisteredFailureCount = nrow(observed),
    ExpectedOutputCount = nrow(output_contract),
    CompleteOutputSet = complete_output_set,
    CommandIsDataFreeQuit = isTRUE(command_is_data_free_quit),
    ModelEstimationAttempted = FALSE,
    ModelEstimationSuccess = NA,
    SemanticSuccess = semantic_success,
    ScientificComparisonAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(
    summary = summary,
    transcript = lines,
    failure_registry = failures,
    observed_failures = observed,
    output_contract = output_contract,
    host_error = if (host_error_present) host_error else NA_character_
  )
}

mfrmr_cq_srp_invocation <- function(
    conquest_exe, launcher = NULL, launcher_args = character(0)) {
  mfrmr_cq_srp_assert(
    is.character(conquest_exe) && length(conquest_exe) == 1L &&
      !is.na(conquest_exe) && nzchar(conquest_exe),
    "`conquest_exe` must be one explicit nonempty path."
  )
  executable_path <- normalizePath(
    conquest_exe, winslash = "/", mustWork = FALSE
  )
  executable_available <- file.exists(executable_path)
  executable <- executable_available &&
    file.access(executable_path, mode = 1L) == 0L
  launcher_supplied <- !is.null(launcher)
  if (launcher_supplied) {
    mfrmr_cq_srp_assert(
      is.character(launcher) && length(launcher) == 1L &&
        !is.na(launcher) && nzchar(launcher),
      "`launcher` must be NULL or one explicit nonempty path."
    )
    launcher_path <- normalizePath(
      launcher, winslash = "/", mustWork = FALSE
    )
    launcher_available <- file.exists(launcher_path) &&
      file.access(launcher_path, mode = 1L) == 0L
    command <- launcher_path
    args <- c(as.character(launcher_args), shQuote(executable_path))
    route <- paste(c(command, args), collapse = " ")
  } else {
    launcher_path <- NA_character_
    launcher_available <- TRUE
    command <- executable_path
    args <- character(0)
    route <- command
  }
  list(
    executable_path = executable_path,
    runtime_available = executable_available && executable &&
      launcher_available,
    executable_available = executable_available,
    executable = executable,
    launcher_path = launcher_path,
    launcher_available = launcher_available,
    command = command,
    args = args,
    route = route
  )
}

mfrmr_cq_srp_inspect_executable <- function(executable_path) {
  file_tool <- Sys.which("file")
  if (!nzchar(file_tool)) {
    return(list(architecture = NA_character_, raw = character(0),
                status = NA_integer_))
  }
  output <- tryCatch(
    suppressWarnings(system2(
      file_tool, shQuote(executable_path), stdout = TRUE, stderr = TRUE
    )),
    error = function(error) structure(
      conditionMessage(error), status = 1L
    )
  )
  status <- attr(output, "status", exact = TRUE)
  if (is.null(status)) status <- 0L
  raw <- enc2utf8(as.character(output))
  architecture <- if (identical(as.integer(status), 0L) && length(raw) > 0L) {
    paste(raw, collapse = " | ")
  } else {
    NA_character_
  }
  list(architecture = architecture, raw = raw, status = as.integer(status))
}

mfrmr_cq_srp_system_runner <- function(
    command, args, stdin, working_dir, timeout) {
  previous <- getwd()
  on.exit(setwd(previous), add = TRUE)
  setwd(working_dir)
  output <- tryCatch(
    suppressWarnings(system2(
      command,
      args = args,
      stdout = TRUE,
      stderr = TRUE,
      input = stdin,
      timeout = timeout
    )),
    error = function(error) structure(
      character(0),
      status = NA_integer_,
      host_error = conditionMessage(error)
    )
  )
  status <- attr(output, "status", exact = TRUE)
  if (is.null(status)) status <- 0L
  host_error <- attr(output, "host_error", exact = TRUE)
  if (is.null(host_error)) host_error <- NA_character_
  list(
    console_lines = enc2utf8(as.character(output)),
    exit_status = as.integer(status),
    host_error = as.character(host_error)[1L]
  )
}

mfrmr_cq_srp_preflight <- function(
    conquest_exe,
    launcher = NULL,
    launcher_args = character(0),
    working_dir = NULL,
    timeout = 30L,
    run_date = Sys.Date(),
    locale = Sys.getlocale(),
    runner = mfrmr_cq_srp_system_runner,
    inspector = mfrmr_cq_srp_inspect_executable) {
  mfrmr_cq_srp_assert(
    is.function(runner) && is.function(inspector),
    "`runner` and `inspector` must be functions."
  )
  mfrmr_cq_srp_assert(
    length(timeout) == 1L && is.finite(timeout) && timeout > 0,
    "`timeout` must be one positive finite number of seconds."
  )
  invocation <- mfrmr_cq_srp_invocation(
    conquest_exe, launcher = launcher, launcher_args = launcher_args
  )
  if (!invocation$runtime_available) {
    result <- mfrmr_cq_srp_assess(
      console_lines = character(0),
      exit_status = NA_integer_,
      executable_path = invocation$executable_path,
      executable_available = invocation$executable_available,
      executable = invocation$executable,
      launcher_available = invocation$launcher_available,
      architecture = NA_character_,
      invocation_route = invocation$route,
      locale = locale,
      run_date = run_date,
      command_is_data_free_quit = TRUE,
      host_error = NA_character_
    )
    result$invocation <- invocation
    result$architecture_inspection <- NULL
    return(result)
  }
  created_working_dir <- is.null(working_dir)
  if (created_working_dir) {
    working_dir <- tempfile("mfrmr-conquest-semantic-preflight-")
    mfrmr_cq_srp_assert(
      dir.create(working_dir, recursive = FALSE),
      "The isolated semantic-preflight directory could not be created."
    )
    on.exit(unlink(working_dir, recursive = TRUE, force = TRUE), add = TRUE)
  } else {
    mfrmr_cq_srp_assert(
      is.character(working_dir) && length(working_dir) == 1L &&
        dir.exists(working_dir),
      "`working_dir` must be an existing directory."
    )
    mfrmr_cq_srp_assert(
      length(list.files(working_dir, all.files = TRUE, no.. = TRUE)) == 0L,
      "`working_dir` must be empty before the semantic preflight."
    )
  }
  working_dir <- normalizePath(
    working_dir, winslash = "/", mustWork = TRUE
  )
  architecture <- tryCatch(
    inspector(invocation$executable_path),
    error = function(error) list(
      architecture = NA_character_, raw = character(0), status = NA_integer_,
      host_error = conditionMessage(error)
    )
  )
  execution <- runner(
    command = invocation$command,
    args = invocation$args,
    stdin = mfrmr_cq_srp_stdin,
    working_dir = working_dir,
    timeout = as.integer(timeout)
  )
  mfrmr_cq_srp_assert(
    is.list(execution) && all(c(
      "console_lines", "exit_status", "host_error"
    ) %in% names(execution)),
    "The semantic-preflight runner returned a malformed result."
  )
  command_is_data_free_quit <- identical(
    as.character(mfrmr_cq_srp_stdin), "quit;"
  )
  result <- mfrmr_cq_srp_assess(
    console_lines = execution$console_lines,
    exit_status = execution$exit_status,
    executable_path = invocation$executable_path,
    executable_available = invocation$executable_available,
    executable = invocation$executable,
    launcher_available = invocation$launcher_available,
    architecture = architecture$architecture,
    invocation_route = invocation$route,
    locale = locale,
    run_date = run_date,
    command_is_data_free_quit = command_is_data_free_quit,
    host_error = execution$host_error
  )
  result$invocation <- invocation
  result$architecture_inspection <- architecture
  result$working_directory_retained <- !created_working_dir
  result
}

mfrmr_cq_srp_replacement_gate <- function(
    preflight_result,
    runtime_change_declared,
    numerical_sentinel = c("not_required", "not_run", "passed", "failed")) {
  numerical_sentinel <- match.arg(numerical_sentinel)
  mfrmr_cq_srp_assert(
    is.list(preflight_result) && is.data.frame(preflight_result$summary) &&
      nrow(preflight_result$summary) == 1L,
    "`preflight_result` must contain one semantic-preflight summary row."
  )
  mfrmr_cq_srp_assert(
    is.logical(runtime_change_declared) &&
      length(runtime_change_declared) == 1L &&
      !is.na(runtime_change_declared),
    "`runtime_change_declared` must be one nonmissing logical value."
  )
  preflight_passed <- identical(
    preflight_result$summary$Status, "runtime_semantic_ready"
  ) && isTRUE(preflight_result$summary$SemanticSuccess)
  sentinel_contract_ok <- if (runtime_change_declared) {
    identical(numerical_sentinel, "passed")
  } else {
    numerical_sentinel %in% c("not_required", "passed")
  }
  eligible <- preflight_passed && sentinel_contract_ok
  status <- if (!preflight_passed) {
    "replacement_blocked_runtime_preflight_failed"
  } else if (runtime_change_declared && numerical_sentinel == "not_run") {
    "replacement_blocked_smallest_numerical_sentinel_not_run"
  } else if (runtime_change_declared && numerical_sentinel != "passed") {
    "replacement_blocked_smallest_numerical_sentinel_failed"
  } else if (!runtime_change_declared && numerical_sentinel == "not_run") {
    "unchanged_runtime_contract_error_sentinel_must_be_not_required"
  } else if (eligible && runtime_change_declared) {
    "replacement_runtime_eligible_for_prospective_evidence_reopening"
  } else if (eligible) {
    "unchanged_runtime_semantic_preflight_passed"
  } else {
    "replacement_blocked_invalid_sentinel_state"
  }
  data.frame(
    ContractVersion = mfrmr_cq_srp_contract,
    Status = status,
    RuntimeChangeDeclared = runtime_change_declared,
    RuntimePreflightPassed = preflight_passed,
    NumericalSentinelStatus = numerical_sentinel,
    BroaderProspectiveExecutionEligible = eligible,
    PriorEvidenceAutomaticallyReclassified = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}
