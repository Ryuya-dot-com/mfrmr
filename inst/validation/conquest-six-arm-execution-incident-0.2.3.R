# Repository-only incident review for candidate 002. The first authorized
# Binary arm returned process status zero but ConQuest reported command/model
# errors. The remaining five arms were not launched.

mfrmr_cq_ei_specification <-
  "0.2.3-wave-c-conquest-candidate-002-execution-incident-v1"
mfrmr_cq_ei_contract <- "mfrmr_conquest_execution_incident_v1"
mfrmr_cq_ei_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-002"
mfrmr_cq_ei_arm_id <- "binary_q031"
mfrmr_cq_ei_process_exit_status <- 0L
mfrmr_cq_ei_command_sha256 <-
  "61a7e9c9c4f8303deb4eff40027c245d66442eb63021a4109f5ec6c69c2bee6a"
mfrmr_cq_ei_console_sha256 <-
  "dcf096bb9bbefd9ce4f179123eae26eda0aa17a226650a653dfe47451e40b083"
mfrmr_cq_ei_failure_reason <- "unsupported_c_style_prose_command_preamble"

mfrmr_cq_ei_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ei_require_binding <- function() {
  target <- environment(mfrmr_cq_ei_require_binding)
  required <- c(
    "mfrmr_cq_cb_file_audit", "mfrmr_cq_cb_file_sha256",
    "mfrmr_cq_cb_output_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  mfrmr_cq_ei_assert(
    all(available), "Source the candidate-002 binding before incident review."
  )
  invisible(TRUE)
}

mfrmr_cq_ei_review <- function(candidate_root) {
  mfrmr_cq_ei_require_binding()
  root <- normalizePath(
    as.character(candidate_root)[1L], winslash = "/", mustWork = TRUE
  )
  command_path <- file.path(root, "binary/q031a/cq_q031a.cqc")
  console_path <- file.path(root, "binary/q031a/cq_q031a_run.log")
  mfrmr_cq_ei_assert(
    all(file.exists(c(command_path, console_path))),
    "The candidate-002 incident command/console pair is missing."
  )
  command <- trimws(readLines(command_path, warn = FALSE))
  console <- trimws(readLines(console_path, warn = FALSE))
  audit <- mfrmr_cq_cb_file_audit(root)
  present <- audit$outputs[audit$outputs$ObservedPresent, , drop = FALSE]
  marker <- c(
    unknown_preamble = "Unknown command or argument: /*Generated",
    regression_error = "Error in Regression statement",
    estimation_error = "Can't do estimation",
    missing_model = "A model must be estimated",
    end_marker = "End of Program"
  )
  marker_present <- vapply(
    marker,
    function(value) any(grepl(value, console, fixed = TRUE)),
    logical(1L)
  )
  exact_identity <- identical(
    mfrmr_cq_cb_file_sha256(command_path), mfrmr_cq_ei_command_sha256
  ) && identical(
    mfrmr_cq_cb_file_sha256(console_path), mfrmr_cq_ei_console_sha256
  )
  exact_output_state <- nrow(present) == 1L &&
    present$ArmId == mfrmr_cq_ei_arm_id &&
    present$OutputKind == "console_log" &&
    sum(!audit$outputs$ObservedPresent) == 49L
  incident_confirmed <- exact_identity && exact_output_state &&
    all(marker_present) && identical(command[1L], "/*")
  list(
    specification = mfrmr_cq_ei_specification,
    contract_version = mfrmr_cq_ei_contract,
    status = if (incident_confirmed) {
      "candidate_002_execution_failed_semantically_after_zero_process_exit"
    } else {
      "candidate_002_incident_identity_or_state_mismatch"
    },
    candidate_id = mfrmr_cq_ei_candidate_id,
    arm_id = mfrmr_cq_ei_arm_id,
    process_exit_status = mfrmr_cq_ei_process_exit_status,
    command_sha256 = mfrmr_cq_cb_file_sha256(command_path),
    console_sha256 = mfrmr_cq_cb_file_sha256(console_path),
    failure_reason = mfrmr_cq_ei_failure_reason,
    marker_present = marker_present,
    present_outputs = present,
    absent_output_count = sum(!audit$outputs$ObservedPresent),
    incident_confirmed = incident_confirmed,
    remaining_five_arms_launched = FALSE,
    candidate_binding_ready = FALSE,
    candidate_execution_authorized = FALSE,
    candidate_reuse_authorized = FALSE,
    candidate_003_required = incident_confirmed,
    comparison_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE
  )
}
