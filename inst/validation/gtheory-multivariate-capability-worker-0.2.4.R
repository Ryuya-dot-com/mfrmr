# Draft.85c4b macOS capability-isolation worker.
#
# Executed by the R binary under a default-deny sandbox-exec profile. The
# controller stages this file and the c4a candidate-only worker outside the
# repository, passes one candidate envelope, and permits writes only to the
# declared output/scratch directories.

mfrmr_gtvhw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The capability worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvhw_attempt <- function(expression) {
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
    } else {
      "none"
    }
  )
}

mfrmr_gtvhw_probe <- function(mode, input_path, target) {
  if (identical(mode, "probe_vault_read")) {
    return(mfrmr_gtvhw_attempt(readRDS(target)))
  }
  if (identical(mode, "probe_source_read")) {
    return(mfrmr_gtvhw_attempt(readLines(target, n = 1L, warn = FALSE)))
  }
  if (identical(mode, "probe_outside_write")) {
    return(mfrmr_gtvhw_attempt(saveRDS("forbidden", target)))
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
    attempt <- mfrmr_gtvhw_attempt(suppressWarnings(system2(
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
  stop("Unknown capability negative-control mode.", call. = FALSE)
}

mfrmr_gtvhw_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (length(arguments) != 6L) {
    stop(
      "Expected mode, candidate worker, input, output, target, and run token.",
      call. = FALSE
    )
  }
  mode <- arguments[[1L]]
  candidate_worker_path <- arguments[[2L]]
  input_path <- arguments[[3L]]
  output_path <- arguments[[4L]]
  target <- arguments[[5L]]
  run_token <- arguments[[6L]]
  allowed_modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  if (!mode %in% allowed_modes || !grepl("^C4B-[0-9a-f]{24}$", run_token)) {
    stop("The capability worker mode or run token is invalid.", call. = FALSE)
  }
  source(candidate_worker_path, local = .GlobalEnv)
  required_candidate_functions <- c(
    "mfrmr_gtvgw_hash", "mfrmr_gtvgw_exact_object",
    "mfrmr_gtvgw_candidate_schema", "mfrmr_gtvgw_receive"
  )
  if (!all(vapply(
    required_candidate_functions, exists, logical(1L),
    envir = .GlobalEnv, inherits = FALSE
  ))) {
    stop("The staged c4a candidate worker is incomplete.", call. = FALSE)
  }
  envelope <- readRDS(input_path)
  environment_names <- sort(names(Sys.getenv()), method = "radix")
  common <- list(
    Contract = "gtheory_multivariate_capability_worker_draft85c4b_v1",
    Mode = mode,
    RunToken = run_token,
    OpaqueCandidateId = envelope$OpaqueCandidateId,
    EnvelopeHash = envelope$EnvelopeHash,
    CandidateDataHash = envelope$CandidateDataHash,
    EnvironmentNames = environment_names,
    EnvironmentNamesHash = mfrmr_gtvhw_hash(environment_names),
    ParentSecretVisible = !is.na(Sys.getenv(
      "MFRMR_C4B_PARENT_SECRET", unset = NA_character_
    ))
  )
  if (identical(mode, "normal")) {
    candidate_receipt <- mfrmr_gtvgw_receive(envelope)
    action_succeeded <- TRUE
    action_message <- "candidate_receipt_created"
    candidate_receipt_hash <- candidate_receipt$ReceiptHash
  } else {
    probe <- mfrmr_gtvhw_probe(mode, input_path, target)
    action_succeeded <- isTRUE(probe$Succeeded)
    action_message <- probe$Message
    candidate_receipt <- NULL
    candidate_receipt_hash <- NA_character_
  }
  control_passed <- if (identical(mode, "normal")) {
    isTRUE(action_succeeded) && !common$ParentSecretVisible
  } else {
    !isTRUE(action_succeeded) && !common$ParentSecretVisible
  }
  payload <- c(common, list(
    ActionSucceeded = action_succeeded,
    ActionMessage = action_message,
    CandidateReceipt = candidate_receipt,
    CandidateReceiptHash = candidate_receipt_hash,
    ControlPassed = control_passed
  ))
  output <- structure(c(payload, list(
    ResultHash = mfrmr_gtvhw_hash(payload),
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvh_worker_result", "list"))
  saveRDS(output, output_path, version = 3L)
  invisible(output)
}

if (sys.nframe() == 0L) {
  mfrmr_gtvhw_main()
}
