# Repository-only execution handoff for ConQuest candidate 003. It authorizes
# six ordered, run-once native executions only while every output is absent.
# Each arm must pass the semantic-success gate before the next arm is launched.

mfrmr_cq_c3eh_specification <-
  "0.2.3-wave-c-conquest-six-arm-candidate-003-execution-handoff-v1"
mfrmr_cq_c3eh_contract <-
  "mfrmr_conquest_six_arm_candidate_003_execution_handoff_v1"
mfrmr_cq_c3eh_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-003"
mfrmr_cq_c3eh_source_commit <- "686485da35b325e547786f1b4eb26a53195e572d"
mfrmr_cq_c3eh_source_tree_sha256 <-
  "564ebcfbf90966f49b4ee7f6fff7afcd3ae689bdf1217f091c9c24c06ca2b8e5"
mfrmr_cq_c3eh_executable_path <- "/Applications/ConQuest/ConQuest"
mfrmr_cq_c3eh_executable_sha256 <-
  "61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48"
mfrmr_cq_c3eh_invocation_bundle_sha256 <-
  "a47873a976ab61e4daee1dbc72591f61d4376b86cd486aaebfd51e12a0ca912c"

mfrmr_cq_c3eh_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_c3eh_require_reference <- function() {
  target <- environment(mfrmr_cq_c3eh_require_reference)
  required <- c(
    "mfrmr_cq_c3rp_review", "mfrmr_cq_cb_output_registry",
    "mfrmr_cq_cb_canonical_text", "mfrmr_cq_cb_file_sha256"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity_ok <- exists(
    "mfrmr_cq_c3rp_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_c3rp_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_six_arm_candidate_003_reference_v1"
  ) && identical(
    get("mfrmr_cq_c3rp_candidate_id", envir = target, inherits = TRUE),
    mfrmr_cq_c3eh_candidate_id
  )
  mfrmr_cq_c3eh_assert(
    all(available) && identity_ok,
    "Source the candidate-003 reference preflight before this handoff."
  )
  invisible(TRUE)
}

mfrmr_cq_c3eh_semantic_failure_registry <- function() {
  data.frame(
    FailureCode = c(
      "unknown_command", "regression_error", "estimation_unavailable",
      "model_not_estimated", "compute_error", "print_error",
      "equation_symbol_error", "datafile_missing"
    ),
    FixedPattern = c(
      "Unknown command or argument:", "Error in Regression statement",
      "Can't do estimation", "A model must be estimated",
      "Compute command error", "Print cannot show object:",
      "Unknown symbol in equation:", "Data file name not specified"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3eh_invocation_registry <- function() {
  data.frame(
    ExecutionOrder = seq_len(6L),
    ArmId = c(
      "binary_q031", "binary_q061", "rsm_q031", "rsm_q061",
      "pcm_q031", "pcm_q061"
    ),
    Family = c("Binary", "Binary", "RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L, 31L, 61L),
    WorkingDirectory = c(
      "binary/q031a", "binary/q061", "additive/rsm_q031",
      "additive/rsm_q061", "additive/pcm_q031", "additive/pcm_q061"
    ),
    CommandFile = c(
      "cq_q031a.cqc", "cq_q061.cqc", "cq_additive_rsm_q031.cqc",
      "cq_additive_rsm_q061.cqc", "cq_additive_pcm_q031.cqc",
      "cq_additive_pcm_q061.cqc"
    ),
    ConsoleFile = c(
      "cq_q031a_run.log", "cq_q061_run.log",
      "cq_additive_rsm_q031_console.log",
      "cq_additive_rsm_q061_console.log",
      "cq_additive_pcm_q031_console.log",
      "cq_additive_pcm_q061_console.log"
    ),
    ExpectedNativeOutputCount = c(6L, 6L, 8L, 8L, 8L, 8L),
    RequiredTerminalMarker = "End of Program",
    SemanticFailureContract = "conquest_semantic_failure_patterns_v1",
    InvocationMode = "stdin_command_file_stdout_stderr_single_console",
    ExpectedExitStatus = 0L,
    RunOnce = TRUE,
    AdvanceOnlyAfterSemanticSuccess = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3eh_invocation_hash <- function() {
  mfrmr_cq_c3eh_require_reference()
  digest::digest(
    mfrmr_cq_cb_canonical_text(
      mfrmr_cq_c3eh_invocation_registry(), "ExecutionOrder"
    ),
    algo = "sha256", serialize = FALSE
  )
}

mfrmr_cq_c3eh_source_status <- function(repo_root = ".") {
  root <- normalizePath(repo_root, winslash = "/", mustWork = FALSE)
  if (!dir.exists(file.path(root, ".git"))) {
    return(data.frame(
      Available = FALSE, ExpectedCommit = mfrmr_cq_c3eh_source_commit,
      ActualTreeSHA256 = NA_character_,
      ExpectedTreeSHA256 = mfrmr_cq_c3eh_source_tree_sha256,
      IdentityOK = FALSE, stringsAsFactors = FALSE
    ))
  }
  lines <- tryCatch(
    system2(
      "git", c(
        "-C", root, "ls-tree", "-r", "--full-tree",
        mfrmr_cq_c3eh_source_commit
      ), stdout = TRUE, stderr = FALSE
    ),
    error = function(...) character(0)
  )
  actual <- if (length(lines) > 0L) {
    digest::digest(
      paste(c(lines, ""), collapse = "\n"),
      algo = "sha256", serialize = FALSE
    )
  } else {
    NA_character_
  }
  data.frame(
    Available = length(lines) > 0L,
    ExpectedCommit = mfrmr_cq_c3eh_source_commit,
    ActualTreeSHA256 = actual,
    ExpectedTreeSHA256 = mfrmr_cq_c3eh_source_tree_sha256,
    IdentityOK = identical(actual, mfrmr_cq_c3eh_source_tree_sha256),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3eh_executable_status <- function(
    executable_path = mfrmr_cq_c3eh_executable_path) {
  path <- normalizePath(
    as.character(executable_path)[1L], winslash = "/", mustWork = FALSE
  )
  exists <- file.exists(path)
  actual <- if (exists) mfrmr_cq_cb_file_sha256(path) else NA_character_
  data.frame(
    ExpectedPath = mfrmr_cq_c3eh_executable_path,
    ObservedPath = path,
    PathOK = identical(path, mfrmr_cq_c3eh_executable_path),
    Exists = exists,
    Executable = exists && file.access(path, mode = 1L) == 0L,
    ExpectedSHA256 = mfrmr_cq_c3eh_executable_sha256,
    ActualSHA256 = actual,
    IdentityOK = identical(actual, mfrmr_cq_c3eh_executable_sha256),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3eh_path_status <- function(candidate_root) {
  root <- normalizePath(candidate_root, winslash = "/", mustWork = TRUE)
  invocation <- mfrmr_cq_c3eh_invocation_registry()
  output <- mfrmr_cq_cb_output_registry()
  console <- output[
    output$OutputKind == "console_log",
    c("ArmId", "RelativePath"), drop = FALSE
  ]
  console <- console[match(invocation$ArmId, console$ArmId), , drop = FALSE]
  expected_console <- file.path(
    invocation$WorkingDirectory, invocation$ConsoleFile
  )
  command_path <- file.path(
    root, invocation$WorkingDirectory, invocation$CommandFile
  )
  console_path <- file.path(root, expected_console)
  out <- data.frame(
    invocation,
    WorkingDirectoryExists = dir.exists(file.path(
      root, invocation$WorkingDirectory
    )),
    CommandExists = file.exists(command_path),
    ConsoleMappingOK = identical(
      as.character(expected_console), as.character(console$RelativePath)
    ),
    ConsoleAbsent = !file.exists(console_path),
    stringsAsFactors = FALSE
  )
  out$PathReady <- out$WorkingDirectoryExists & out$CommandExists &
    out$ConsoleMappingOK & out$ConsoleAbsent
  out
}

mfrmr_cq_c3eh_semantic_status <- function(
    candidate_root, arm_id, process_exit_status) {
  mfrmr_cq_c3eh_require_reference()
  root <- normalizePath(candidate_root, winslash = "/", mustWork = TRUE)
  invocation <- mfrmr_cq_c3eh_invocation_registry()
  index <- which(invocation$ArmId == as.character(arm_id)[1L])
  mfrmr_cq_c3eh_assert(length(index) == 1L, "Unknown execution arm.")
  arm <- invocation[index, , drop = FALSE]
  output <- mfrmr_cq_cb_output_registry()
  arm_output <- output[output$ArmId == arm$ArmId, , drop = FALSE]
  console_row <- arm_output$OutputKind == "console_log"
  console_path <- file.path(root, arm_output$RelativePath[console_row])
  native_path <- file.path(root, arm_output$RelativePath[!console_row])
  console_exists <- length(console_path) == 1L && file.exists(console_path)
  lines <- if (console_exists) readLines(console_path, warn = FALSE) else {
    character(0)
  }
  failures <- mfrmr_cq_c3eh_semantic_failure_registry()
  failures$Observed <- vapply(failures$FixedPattern, function(pattern) {
    any(grepl(pattern, lines, fixed = TRUE))
  }, logical(1L))
  native_exists <- file.exists(native_path)
  native_nonempty <- native_exists & file.info(native_path)$size > 0
  terminal_marker_present <- any(grepl(
    arm$RequiredTerminalMarker, lines, fixed = TRUE
  ))
  exit_status_ok <- identical(
    as.integer(process_exit_status)[1L], as.integer(arm$ExpectedExitStatus)
  )
  success <- console_exists && exit_status_ok && terminal_marker_present &&
    !any(failures$Observed) &&
    length(native_path) == arm$ExpectedNativeOutputCount &&
    all(native_exists) && all(native_nonempty)
  list(
    arm_id = arm$ArmId,
    console_path = console_path,
    console_exists = console_exists,
    process_exit_status = as.integer(process_exit_status)[1L],
    exit_status_ok = exit_status_ok,
    terminal_marker_present = terminal_marker_present,
    failure_patterns = failures,
    native_output_count = length(native_path),
    native_outputs_exist = native_exists,
    native_outputs_nonempty = native_nonempty,
    semantic_success = success,
    next_arm_authorized = success &&
      arm$ExecutionOrder < max(invocation$ExecutionOrder),
    comparison_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_c3eh_review <- function(
    candidate_root, repo_root = ".",
    executable_path = mfrmr_cq_c3eh_executable_path) {
  mfrmr_cq_c3eh_require_reference()
  root <- normalizePath(candidate_root, winslash = "/", mustWork = TRUE)
  reference <- mfrmr_cq_c3rp_review(root, repo_root)
  source <- mfrmr_cq_c3eh_source_status(repo_root)
  executable <- mfrmr_cq_c3eh_executable_status(executable_path)
  path <- mfrmr_cq_c3eh_path_status(root)
  invocation_sha256 <- mfrmr_cq_c3eh_invocation_hash()
  invocation_hash_ok <- identical(
    invocation_sha256, mfrmr_cq_c3eh_invocation_bundle_sha256
  )
  ready <- isTRUE(reference$numerical_reference_ready) &&
    !isTRUE(reference$candidate_execution_authorized) &&
    isTRUE(source$IdentityOK) && isTRUE(executable$PathOK) &&
    isTRUE(executable$Exists) && isTRUE(executable$Executable) &&
    isTRUE(executable$IdentityOK) && all(path$PathReady) &&
    all(path$AdvanceOnlyAfterSemanticSuccess) && invocation_hash_ok &&
    isTRUE(reference$candidate_binding$local_audit$all_outputs_absent)
  list(
    specification = mfrmr_cq_c3eh_specification,
    contract_version = mfrmr_cq_c3eh_contract,
    status = if (ready) {
      "candidate_003_ordered_execution_authorized_semantic_gate_required"
    } else {
      "candidate_003_execution_handoff_invalid_or_already_opened"
    },
    candidate_id = mfrmr_cq_c3eh_candidate_id,
    source = source,
    executable = executable,
    invocation = path,
    semantic_failure_registry = mfrmr_cq_c3eh_semantic_failure_registry(),
    invocation_bundle_sha256 = invocation_sha256,
    expected_invocation_bundle_sha256 =
      mfrmr_cq_c3eh_invocation_bundle_sha256,
    invocation_hash_ok = invocation_hash_ok,
    reference = reference,
    candidate_execution_authorized = ready,
    authorized_arm_count = if (ready) 6L else 0L,
    run_once = ready,
    arm_by_arm_semantic_gate_required = ready,
    existing_output_reuse_authorized = FALSE,
    comparison_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    gpcm_extension_authorized = FALSE,
    large_simulation_authorized = FALSE
  )
}
