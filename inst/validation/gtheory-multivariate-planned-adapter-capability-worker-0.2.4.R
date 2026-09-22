# Draft.85c4n planned-adapter capability worker.
#
# Executed by the direct R binary under a macOS default-deny profile. Normal
# modes source the exact c4m worker and reproduce one typed non-attempt receipt.
# Control modes probe capabilities that must remain unavailable.

mfrmr_gtvuw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4n capability worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvuw_attempt <- function(expression) {
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

mfrmr_gtvuw_probe <- function(mode, request_path, target) {
  if (identical(mode, "probe_protected_vault_read")) {
    return(mfrmr_gtvuw_attempt(readRDS(target)))
  }
  if (identical(mode, "probe_repository_read")) {
    return(mfrmr_gtvuw_attempt(readLines(target, n = 1L, warn = FALSE)))
  }
  if (identical(mode, "probe_outside_write")) {
    return(mfrmr_gtvuw_attempt(saveRDS("forbidden", target)))
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
    attempt <- mfrmr_gtvuw_attempt(suppressWarnings(system2(
      target, request_path, stdout = TRUE, stderr = TRUE
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
  if (identical(mode, "probe_network")) {
    return(mfrmr_gtvuw_attempt({
      connection <- socketConnection(
        host = target, port = 9L, server = FALSE, blocking = TRUE,
        open = "r+", timeout = 1
      )
      close(connection)
      TRUE
    }))
  }
  stop("Unknown Draft.85c4n capability-control mode.", call. = FALSE)
}

mfrmr_gtvuw_run_adapter <- function(adapter_worker_path, request) {
  worker <- new.env(parent = baseenv())
  sys.source(adapter_worker_path, envir = worker)
  required <- c(
    "mfrmr_gtvtw_hash", "mfrmr_gtvtw_exact_object",
    "mfrmr_gtvtw_candidate_unit_schema", "mfrmr_gtvtw_receive"
  )
  valid <- identical(
    sort(ls(worker, all.names = TRUE), method = "radix"),
    sort(required, method = "radix")
  ) && all(vapply(required, function(name) {
    is.function(get(name, envir = worker, inherits = FALSE))
  }, logical(1L)))
  if (!valid) {
    stop("The staged Draft.85c4m worker namespace changed.", call. = FALSE)
  }
  get("mfrmr_gtvtw_receive", envir = worker, inherits = FALSE)(request)
}

mfrmr_gtvuw_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (!is.character(arguments) || length(arguments) != 8L ||
      anyNA(arguments) || any(!nzchar(arguments))) {
    stop(
      "Expected mode, adapter worker, request, output, target, run token, ",
      "worker hash, and capability-worker hash.", call. = FALSE
    )
  }
  mode <- arguments[[1L]]
  adapter_worker_path <- arguments[[2L]]
  request_path <- arguments[[3L]]
  output_path <- arguments[[4L]]
  target <- arguments[[5L]]
  run_token <- arguments[[6L]]
  adapter_worker_hash <- arguments[[7L]]
  capability_worker_hash <- arguments[[8L]]
  allowed_modes <- c(
    "normal_pilot", "normal_confirmation", "normal_negative_control",
    "probe_protected_vault_read", "probe_repository_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec", "probe_network"
  )
  if (!mode %in% allowed_modes ||
      !grepl("^C4N-[0-9a-f]{24}$", run_token) ||
      !grepl("^[0-9a-f]{64}$", adapter_worker_hash) ||
      !grepl("^[0-9a-f]{64}$", capability_worker_hash)) {
    stop("The Draft.85c4n mode, token, or worker hash is invalid.",
         call. = FALSE)
  }
  request <- readRDS(request_path)
  if (!inherits(request, "mfrmr_gtvtw_request") ||
      !grepl("^[0-9a-f]{64}$", request$RequestHash)) {
    stop("The staged Draft.85c4m request is invalid.", call. = FALSE)
  }
  normal <- startsWith(mode, "normal_")
  environment_names <- sort(names(Sys.getenv()), method = "radix")
  common <- list(
    Contract =
      "gtheory_multivariate_planned_adapter_capability_worker_draft85c4n_v1",
    Mode = mode,
    RunToken = run_token,
    RequestHash = request$RequestHash,
    OpaqueRequestId = request$OpaqueRequestId,
    LaneOpaqueId = request$LaneOpaqueId,
    AdapterWorkerSourceSHA256 = adapter_worker_hash,
    CapabilityWorkerSourceSHA256 = capability_worker_hash,
    EnvironmentNames = environment_names,
    EnvironmentNamesHash = mfrmr_gtvuw_hash(environment_names),
    ParentSecretVisible = !is.na(Sys.getenv(
      "MFRMR_C4N_PARENT_SECRET", unset = NA_character_
    ))
  )
  if (normal) {
    attempt <- mfrmr_gtvuw_attempt(mfrmr_gtvuw_run_adapter(
      adapter_worker_path, request
    ))
    action_succeeded <- attempt$Succeeded
    action_message <- attempt$Message
    adapter_receipt <- if (attempt$Succeeded) attempt$Result else NULL
    adapter_receipt_hash <- if (attempt$Succeeded) {
      attempt$Result$ReceiptHash
    } else NA_character_
  } else {
    attempt <- mfrmr_gtvuw_probe(mode, request_path, target)
    action_succeeded <- attempt$Succeeded
    action_message <- attempt$Message
    adapter_receipt <- NULL
    adapter_receipt_hash <- NA_character_
  }
  control_passed <- if (normal) {
    isTRUE(action_succeeded) && !common$ParentSecretVisible
  } else {
    !isTRUE(action_succeeded) && !common$ParentSecretVisible
  }
  payload <- c(common, list(
    ActionSucceeded = action_succeeded,
    ActionMessage = action_message,
    AdapterReceipt = adapter_receipt,
    AdapterReceiptHash = adapter_receipt_hash,
    ControlPassed = control_passed
  ))
  output <- structure(c(payload, list(
    ResultHash = mfrmr_gtvuw_hash(payload),
    WorkerSelfReported = TRUE,
    ProcessCapabilityIsolationReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
    CandidateExecutionAuthorized = FALSE,
    CandidateExecutionOccurred = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvuw_result", "list"))
  saveRDS(output, output_path, version = 3L)
  invisible(output)
}

if (sys.nframe() == 0L) {
  mfrmr_gtvuw_main()
}
