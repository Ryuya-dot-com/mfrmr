# Draft.85c4h qualification-refusal capability worker.
#
# Executed by the direct R binary under a default-deny sandbox-exec profile.
# The controller stages this wrapper, the c4g refusal worker, and one hash-only
# request outside the repository. No fit specification, response, or backend
# authority is accepted.

mfrmr_gtvow_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4h capability worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvow_attempt <- function(expression) {
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

mfrmr_gtvow_probe <- function(mode, input_path, target) {
  if (identical(mode, "probe_vault_read")) {
    return(mfrmr_gtvow_attempt(readRDS(target)))
  }
  if (identical(mode, "probe_source_read")) {
    return(mfrmr_gtvow_attempt(readLines(target, n = 1L, warn = FALSE)))
  }
  if (identical(mode, "probe_outside_write")) {
    return(mfrmr_gtvow_attempt(saveRDS("forbidden", target)))
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
    attempt <- mfrmr_gtvow_attempt(suppressWarnings(system2(
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
  stop("Unknown Draft.85c4h capability-control mode.", call. = FALSE)
}

mfrmr_gtvow_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (!is.character(arguments) || length(arguments) != 6L ||
      anyNA(arguments) || any(!nzchar(arguments))) {
    stop(
      "Expected mode, refusal worker, input, output, target, and run token.",
      call. = FALSE
    )
  }
  mode <- arguments[[1L]]
  refusal_worker_path <- arguments[[2L]]
  input_path <- arguments[[3L]]
  output_path <- arguments[[4L]]
  target <- arguments[[5L]]
  run_token <- arguments[[6L]]
  allowed_modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  if (!mode %in% allowed_modes || !grepl("^C4H-[0-9a-f]{24}$", run_token)) {
    stop("The Draft.85c4h mode or run token is invalid.", call. = FALSE)
  }
  source(refusal_worker_path, local = .GlobalEnv)
  required_refusal_functions <- c(
    "mfrmr_gtvnw_hash", "mfrmr_gtvnw_exact_object", "mfrmr_gtvnw_sha256",
    "mfrmr_gtvnw_assert_request", "mfrmr_gtvnw_refusal_receipt",
    "mfrmr_gtvnw_assert_receipt", "mfrmr_gtvnw_main"
  )
  observed_refusal_functions <- sort(ls(
    .GlobalEnv, pattern = "^mfrmr_gtvnw_", all.names = TRUE
  ), method = "radix")
  if (!identical(
    observed_refusal_functions,
    sort(required_refusal_functions, method = "radix")
  ) || !all(vapply(
    required_refusal_functions, exists, logical(1L),
    envir = .GlobalEnv, inherits = FALSE
  ))) {
    stop("The staged Draft.85c4g refusal worker is incomplete.",
         call. = FALSE)
  }
  request <- readRDS(input_path)
  mfrmr_gtvnw_assert_request(request)
  environment_names <- sort(names(Sys.getenv()), method = "radix")
  common <- list(
    Contract =
      "gtheory_multivariate_qualification_capability_worker_draft85c4h_v1",
    Mode = mode,
    RunToken = run_token,
    RequestHash = request$RequestHash,
    ProtocolManifestHash = request$ProtocolManifestHash,
    EnvironmentIdentityHash = request$EnvironmentIdentityHash,
    EnvironmentNames = environment_names,
    EnvironmentNamesHash = mfrmr_gtvow_hash(environment_names),
    ParentSecretVisible = !is.na(Sys.getenv(
      "MFRMR_C4H_PARENT_SECRET", unset = NA_character_
    ))
  )
  if (identical(mode, "normal")) {
    refusal_receipt <- mfrmr_gtvnw_refusal_receipt(request)
    action_succeeded <- TRUE
    action_message <- "refusal_receipt_created"
    refusal_receipt_hash <- refusal_receipt$ReceiptHash
  } else {
    probe <- mfrmr_gtvow_probe(mode, input_path, target)
    action_succeeded <- isTRUE(probe$Succeeded)
    action_message <- probe$Message
    refusal_receipt <- NULL
    refusal_receipt_hash <- NA_character_
  }
  control_passed <- if (identical(mode, "normal")) {
    isTRUE(action_succeeded) && !common$ParentSecretVisible
  } else {
    !isTRUE(action_succeeded) && !common$ParentSecretVisible
  }
  payload <- c(common, list(
    ActionSucceeded = action_succeeded,
    ActionMessage = action_message,
    RefusalReceipt = refusal_receipt,
    RefusalReceiptHash = refusal_receipt_hash,
    ControlPassed = control_passed
  ))
  output <- structure(c(payload, list(
    ResultHash = mfrmr_gtvow_hash(payload),
    FullB1ObjectsReceived = FALSE,
    BackendExecutionOccurred = FALSE,
    TrustedReceiptProduced = FALSE,
    QualificationWorkerImplemented = FALSE,
    QualificationEvidenceReady = FALSE,
    BackendQualificationReady = FALSE,
    ExecutionAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvo_worker_result", "list"))
  saveRDS(output, output_path, version = 3L)
  invisible(output)
}

if (sys.nframe() == 0L) {
  mfrmr_gtvow_main()
}
