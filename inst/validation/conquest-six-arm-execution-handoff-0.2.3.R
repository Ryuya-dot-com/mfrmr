# Repository-only execution handoff for corrected ConQuest candidate 002.
# This is the first layer permitted to authorize the exact six native runs. It
# never launches ConQuest, accepts no existing output, and authorizes no
# comparison, equivalence, sparse extension, simulation, or confirmation.

mfrmr_cq_eh_specification <-
  "0.2.3-wave-c-conquest-six-arm-execution-handoff-v1"
mfrmr_cq_eh_contract <- "mfrmr_conquest_six_arm_execution_handoff_v1"
mfrmr_cq_eh_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-002"
mfrmr_cq_eh_source_commit <- "af7bbb546195d19159e071b292d087709c9753b3"
mfrmr_cq_eh_source_tree_sha256 <-
  "614bf443b178e4c6104228b2d0b798086cd271fb589ee95ff21ab14b42704982"
mfrmr_cq_eh_executable_path <- "/Applications/ConQuest/ConQuest"
mfrmr_cq_eh_executable_sha256 <-
  "61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48"
mfrmr_cq_eh_invocation_bundle_sha256 <-
  "6a7168df4c782ec9d746977cf6d6fcfd27ed7c8c876996a51c8b3ed9a156d066"

mfrmr_cq_eh_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_eh_require_reference <- function() {
  target <- environment(mfrmr_cq_eh_require_reference)
  required <- c(
    "mfrmr_cq_crp_review", "mfrmr_cq_cb_output_registry",
    "mfrmr_cq_cb_canonical_text", "mfrmr_cq_cb_file_sha256"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity_ok <- exists(
    "mfrmr_cq_crp_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_crp_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_six_arm_candidate_reference_v1"
  ) && identical(
    get("mfrmr_cq_crp_candidate_id", envir = target, inherits = TRUE),
    mfrmr_cq_eh_candidate_id
  )
  mfrmr_cq_eh_assert(
    all(available) && identity_ok,
    "Source the candidate-002 reference preflight before the execution handoff."
  )
  invisible(TRUE)
}

mfrmr_cq_eh_invocation_registry <- function() {
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
    InvocationMode = "stdin_command_file_stdout_stderr_single_console",
    ExpectedExitStatus = 0L,
    RunOnce = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_eh_invocation_hash <- function() {
  mfrmr_cq_eh_require_reference()
  mfrmr_cq_eh_assert(
    requireNamespace("digest", quietly = TRUE),
    "The execution handoff requires `digest`."
  )
  digest::digest(
    mfrmr_cq_cb_canonical_text(
      mfrmr_cq_eh_invocation_registry(), "ExecutionOrder"
    ),
    algo = "sha256", serialize = FALSE
  )
}

mfrmr_cq_eh_source_status <- function(repo_root = ".") {
  root <- normalizePath(repo_root, winslash = "/", mustWork = FALSE)
  if (!dir.exists(file.path(root, ".git"))) {
    return(data.frame(
      Available = FALSE,
      ExpectedCommit = mfrmr_cq_eh_source_commit,
      ActualTreeSHA256 = NA_character_,
      ExpectedTreeSHA256 = mfrmr_cq_eh_source_tree_sha256,
      IdentityOK = FALSE,
      stringsAsFactors = FALSE
    ))
  }
  lines <- tryCatch(
    system2(
      "git", c(
        "-C", root, "ls-tree", "-r", "--full-tree",
        mfrmr_cq_eh_source_commit
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
    ExpectedCommit = mfrmr_cq_eh_source_commit,
    ActualTreeSHA256 = actual,
    ExpectedTreeSHA256 = mfrmr_cq_eh_source_tree_sha256,
    IdentityOK = identical(actual, mfrmr_cq_eh_source_tree_sha256),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_eh_executable_status <- function(
    executable_path = mfrmr_cq_eh_executable_path) {
  path <- normalizePath(
    as.character(executable_path)[1L], winslash = "/", mustWork = FALSE
  )
  exists <- file.exists(path)
  actual <- if (exists) mfrmr_cq_cb_file_sha256(path) else NA_character_
  data.frame(
    ExpectedPath = mfrmr_cq_eh_executable_path,
    ObservedPath = path,
    PathOK = identical(path, mfrmr_cq_eh_executable_path),
    Exists = exists,
    Executable = exists && file.access(path, mode = 1L) == 0L,
    ExpectedSHA256 = mfrmr_cq_eh_executable_sha256,
    ActualSHA256 = actual,
    IdentityOK = identical(actual, mfrmr_cq_eh_executable_sha256),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_eh_path_status <- function(candidate_root) {
  root <- normalizePath(
    as.character(candidate_root)[1L], winslash = "/", mustWork = TRUE
  )
  invocation <- mfrmr_cq_eh_invocation_registry()
  output <- mfrmr_cq_cb_output_registry()
  output_console <- output[
    output$OutputKind == "console_log",
    c("ArmId", "RelativePath"), drop = FALSE
  ]
  output_console <- output_console[
    match(invocation$ArmId, output_console$ArmId), , drop = FALSE
  ]
  expected_console <- file.path(
    invocation$WorkingDirectory, invocation$ConsoleFile
  )
  command_path <- file.path(
    root, invocation$WorkingDirectory, invocation$CommandFile
  )
  console_path <- file.path(root, expected_console)
  working_path <- file.path(root, invocation$WorkingDirectory)
  out <- data.frame(
    invocation,
    WorkingDirectoryExists = dir.exists(working_path),
    CommandExists = file.exists(command_path),
    ConsoleMappingOK = identical(
      as.character(expected_console), as.character(output_console$RelativePath)
    ),
    ConsoleAbsent = !file.exists(console_path),
    stringsAsFactors = FALSE
  )
  out$PathReady <- out$WorkingDirectoryExists & out$CommandExists &
    out$ConsoleMappingOK & out$ConsoleAbsent
  out
}

mfrmr_cq_eh_review <- function(
    candidate_root, repo_root = ".",
    executable_path = mfrmr_cq_eh_executable_path) {
  mfrmr_cq_eh_require_reference()
  root <- normalizePath(
    as.character(candidate_root)[1L], winslash = "/", mustWork = TRUE
  )
  reference <- mfrmr_cq_crp_review(root, repo_root)
  source <- mfrmr_cq_eh_source_status(repo_root)
  executable <- mfrmr_cq_eh_executable_status(executable_path)
  path <- mfrmr_cq_eh_path_status(root)
  invocation_sha256 <- mfrmr_cq_eh_invocation_hash()
  invocation_hash_ok <- identical(
    invocation_sha256, mfrmr_cq_eh_invocation_bundle_sha256
  )
  ready <- isTRUE(reference$numerical_reference_ready) &&
    !isTRUE(reference$candidate_execution_authorized) &&
    isTRUE(source$IdentityOK) && isTRUE(executable$PathOK) &&
    isTRUE(executable$Exists) && isTRUE(executable$Executable) &&
    isTRUE(executable$IdentityOK) && all(path$PathReady) &&
    invocation_hash_ok &&
    isTRUE(reference$candidate_binding$local_audit$all_outputs_absent)
  out <- list(
    specification = mfrmr_cq_eh_specification,
    contract_version = mfrmr_cq_eh_contract,
    status = if (ready) {
      "exact_six_arm_execution_authorized_outputs_must_remain_unopened_until_launch"
    } else {
      "execution_handoff_invalid_or_already_opened"
    },
    candidate_id = mfrmr_cq_eh_candidate_id,
    source = source,
    executable = executable,
    invocation = path,
    invocation_bundle_sha256 = invocation_sha256,
    expected_invocation_bundle_sha256 =
      mfrmr_cq_eh_invocation_bundle_sha256,
    invocation_hash_ok = invocation_hash_ok,
    reference = reference,
    candidate_execution_authorized = ready,
    authorized_arm_count = if (ready) 6L else 0L,
    run_once = ready,
    existing_output_reuse_authorized = FALSE,
    comparison_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    gpcm_extension_authorized = FALSE,
    large_simulation_authorized = FALSE
  )
  class(out) <- c("mfrmr_conquest_execution_handoff_review", class(out))
  out
}
