# Draft.85c4k full-object qualification capability worker.
#
# Executed by the direct R binary under a default-deny macOS sandbox profile.
# Normal mode launches the exact Draft.85c4j qualification worker as a child;
# five control modes probe capabilities that must remain unavailable.

mfrmr_gtvrw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4k capability worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvrw_attempt <- function(expression) {
  warnings <- character()
  result <- tryCatch(withCallingHandlers(
    expression,
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    }
  ), error = function(condition) condition)
  list(
    Succeeded = !inherits(result, "condition"),
    Result = result,
    Warnings = warnings,
    Message = if (inherits(result, "condition")) {
      paste(c(conditionMessage(result), warnings), collapse = " | ")
    } else if (length(warnings) > 0L) {
      paste(warnings, collapse = " | ")
    } else "none"
  )
}

mfrmr_gtvrw_probe <- function(mode, input_path, target) {
  if (identical(mode, "probe_vault_read")) {
    return(mfrmr_gtvrw_attempt(readRDS(target)))
  }
  if (identical(mode, "probe_source_read")) {
    return(mfrmr_gtvrw_attempt(readLines(target, n = 1L, warn = FALSE)))
  }
  if (identical(mode, "probe_outside_write")) {
    return(mfrmr_gtvrw_attempt(saveRDS("forbidden", target)))
  }
  if (identical(mode, "probe_parent_environment")) {
    value <- Sys.getenv(target, unset = NA_character_)
    return(list(
      Succeeded = !is.na(value), Result = value, Warnings = character(),
      Message = if (is.na(value)) "environment_variable_absent" else
        "environment_variable_visible"
    ))
  }
  if (identical(mode, "probe_unlisted_exec")) {
    attempt <- mfrmr_gtvrw_attempt(suppressWarnings(system2(
      target, input_path, stdout = TRUE, stderr = TRUE
    )))
    if (isTRUE(attempt$Succeeded)) {
      status <- attr(attempt$Result, "status")
      if (is.null(status)) status <- 0L
      attempt$Succeeded <- identical(as.integer(status), 0L)
      if (!attempt$Succeeded) {
        attempt$Message <- paste0(
          "sandbox_exec_status_", as.integer(status), ": ",
          paste(attempt$Result, collapse = " | ")
        )
      }
    }
    return(attempt)
  }
  stop("Unknown Draft.85c4k capability-control mode.", call. = FALSE)
}

mfrmr_gtvrw_run_qualification <- function(
    r_executable, qualification_worker_path, request_path, source_dir,
    overlay, output_path) {
  inner_path <- paste0(output_path, ".qualification.rds")
  process_output <- suppressWarnings(system2(
    r_executable,
    c(
      "--vanilla", "--slave",
      paste0("--file=", shQuote(qualification_worker_path)), "--args",
      shQuote(request_path), shQuote(source_dir), shQuote(overlay),
      shQuote(inner_path)
    ), stdout = TRUE, stderr = TRUE
  ))
  status <- attr(process_output, "status")
  if (is.null(status)) status <- 0L
  success <- identical(as.integer(status), 0L) &&
    file.exists(inner_path) && length(process_output) == 0L
  list(
    Succeeded = success,
    Status = as.integer(status),
    ProcessOutput = as.character(process_output),
    Receipt = if (success) readRDS(inner_path) else NULL,
    Message = if (success) "qualification_receipt_created" else paste(
      c(paste0("qualification_status_", as.integer(status)), process_output),
      collapse = " | "
    )
  )
}

mfrmr_gtvrw_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (!is.character(arguments) || length(arguments) != 9L ||
      anyNA(arguments) || any(!nzchar(arguments))) {
    stop(
      "Expected mode, worker, request, source, overlay, output, target, ",
      "run token, and R executable.", call. = FALSE
    )
  }
  mode <- arguments[[1L]]
  qualification_worker_path <- arguments[[2L]]
  request_path <- arguments[[3L]]
  source_dir <- arguments[[4L]]
  overlay <- arguments[[5L]]
  output_path <- arguments[[6L]]
  target <- arguments[[7L]]
  run_token <- arguments[[8L]]
  r_executable <- arguments[[9L]]
  allowed_modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  if (!mode %in% allowed_modes || !grepl("^C4K-[0-9a-f]{24}$", run_token)) {
    stop("The Draft.85c4k mode or run token is invalid.", call. = FALSE)
  }
  request <- readRDS(request_path)
  if (!inherits(request, "mfrmr_gtvqw_request") ||
      !is.character(request$RequestHash) ||
      !grepl("^[0-9a-f]{64}$", request$RequestHash)) {
    stop("The staged Draft.85c4j request is invalid.", call. = FALSE)
  }
  environment_names <- sort(names(Sys.getenv()), method = "radix")
  common <- list(
    Contract =
      "gtheory_multivariate_full_object_capability_worker_draft85c4k_v1",
    Mode = mode,
    RunToken = run_token,
    RequestHash = request$RequestHash,
    WorkerSourceSHA256 = request$WorkerSourceSHA256,
    SourceRegistryHash = request$SourceRegistryHash,
    EnvironmentNames = environment_names,
    EnvironmentNamesHash = mfrmr_gtvrw_hash(environment_names),
    ParentSecretVisible = !is.na(Sys.getenv(
      "MFRMR_C4K_PARENT_SECRET", unset = NA_character_
    ))
  )
  if (identical(mode, "normal")) {
    qualification <- mfrmr_gtvrw_run_qualification(
      r_executable, qualification_worker_path, request_path, source_dir,
      overlay, output_path
    )
    action_succeeded <- qualification$Succeeded
    action_message <- qualification$Message
    qualification_receipt <- qualification$Receipt
    qualification_receipt_hash <- if (qualification$Succeeded) {
      qualification$Receipt$ReceiptHash
    } else NA_character_
    qualification_status <- qualification$Status
    qualification_output <- qualification$ProcessOutput
  } else {
    probe <- mfrmr_gtvrw_probe(mode, request_path, target)
    action_succeeded <- isTRUE(probe$Succeeded)
    action_message <- probe$Message
    qualification_receipt <- NULL
    qualification_receipt_hash <- NA_character_
    qualification_status <- NA_integer_
    qualification_output <- character()
  }
  control_passed <- if (identical(mode, "normal")) {
    isTRUE(action_succeeded) && !common$ParentSecretVisible
  } else {
    !isTRUE(action_succeeded) && !common$ParentSecretVisible
  }
  payload <- c(common, list(
    ActionSucceeded = action_succeeded,
    ActionMessage = action_message,
    QualificationExitStatus = qualification_status,
    QualificationProcessOutput = qualification_output,
    QualificationReceipt = qualification_receipt,
    QualificationReceiptHash = qualification_receipt_hash,
    ControlPassed = control_passed
  ))
  output <- structure(c(payload, list(
    ResultHash = mfrmr_gtvrw_hash(payload),
    WorkerSelfReported = TRUE,
    ProcessCapabilityIsolationReady = FALSE,
    TrustedReceiptProduced = FALSE,
    QualificationEvidenceReady = FALSE,
    BackendQualificationReady = FALSE,
    PlannedExecutionAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvrw_result", "list"))
  saveRDS(output, output_path, version = 3L)
  invisible(output)
}

if (sys.nframe() == 0L) {
  mfrmr_gtvrw_main()
}
