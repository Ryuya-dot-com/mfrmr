# No-top-level-execution ConQuest launch-tier adjudication and successor guard.
#
# This artifact separates a restricted-host launch failure from native-runtime
# availability. Sourcing it launches no external program. Its opt-in live guard
# can run only the same-process semantic `quit;` preflight needed for a future
# successor token; a caller-supplied execution-tier label is not evidence.

mfrmr_cq_alt_specification <-
  "0.2.3-conquest-adversarial-simulation-launch-tier-contract-v1"
mfrmr_cq_alt_contract <-
  "mfrmr_conquest_adversarial_simulation_launch_tier_contract_v1"
mfrmr_cq_alt_observed_executable <- "/Applications/ConQuest/ConQuest"
mfrmr_cq_alt_observed_launcher <- "/usr/bin/arch"

mfrmr_cq_alt_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_alt_observations <- function() {
  data.frame(
    ObservationOrder = 1:3,
    ObservationId = c(
      "G4M_RESTRICTED_FILE_STDIN",
      "DIAGNOSTIC_UNSANDBOXED_TTY",
      "DIAGNOSTIC_UNSANDBOXED_FILE_STDIN"
    ),
    ExecutionTier = c(
      "restricted_codex_filesystem_sandbox",
      "unsandboxed_host",
      "unsandboxed_host"
    ),
    InputRoute = c("file_stdin", "interactive_tty", "file_stdin"),
    ExecutablePath = rep(mfrmr_cq_alt_observed_executable, 3L),
    LauncherPath = rep(mfrmr_cq_alt_observed_launcher, 3L),
    LauncherArchitecture = rep("x86_64", 3L),
    Command = rep("quit;", 3L),
    RunDate = rep(as.Date("2026-08-16"), 3L),
    ExitStatus = c(NA_integer_, 0L, 0L),
    NativeSignal = c(11L, NA_integer_, NA_integer_),
    TerminalMarkerPresent = c(FALSE, TRUE, TRUE),
    RuntimeVersion = c(NA_character_, "5.47.5", "5.47.5"),
    RuntimeEdition = c(
      NA_character_, "Demonstration Version", "Demonstration Version"
    ),
    ExpiryDate = as.Date(c(NA, "2026-09-01", "2026-09-01")),
    ModelDataSupplied = FALSE,
    ModelEstimationAttempted = FALSE,
    NumericAgreementInspected = FALSE,
    PublicClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_alt_validate_observations <- function(observations) {
  required <- names(mfrmr_cq_alt_observations())
  mfrmr_cq_alt_assert(
    is.data.frame(observations) && identical(names(observations), required),
    "Launch-tier observations do not match the frozen schema."
  )
  mfrmr_cq_alt_assert(
    nrow(observations) == 3L &&
      identical(observations$ObservationOrder, 1:3) &&
      identical(observations$ObservationId, c(
        "G4M_RESTRICTED_FILE_STDIN",
        "DIAGNOSTIC_UNSANDBOXED_TTY",
        "DIAGNOSTIC_UNSANDBOXED_FILE_STDIN"
      )),
    "The exact three launch-tier observations are required."
  )
  mfrmr_cq_alt_assert(
    !anyDuplicated(observations$ObservationId) &&
      all(observations$ExecutablePath == mfrmr_cq_alt_observed_executable) &&
      all(observations$LauncherPath == mfrmr_cq_alt_observed_launcher) &&
      all(observations$LauncherArchitecture == "x86_64") &&
      all(observations$Command == "quit;") &&
      all(observations$RunDate == as.Date("2026-08-16")),
    "The path, launcher, data-free command, or date boundary drifted."
  )
  mfrmr_cq_alt_assert(
    !any(observations$ModelDataSupplied) &&
      !any(observations$ModelEstimationAttempted) &&
      !any(observations$NumericAgreementInspected) &&
      !any(observations$PublicClaimAuthorized),
    "Launch-tier evidence cannot contain model or comparison work."
  )
  invisible(observations)
}

mfrmr_cq_alt_review <- function(
    observations = mfrmr_cq_alt_observations()) {
  mfrmr_cq_alt_validate_observations(observations)
  restricted <- observations[1L, , drop = FALSE]
  tty <- observations[2L, , drop = FALSE]
  file_stdin <- observations[3L, , drop = FALSE]
  exact_runtime <- function(row) {
    identical(row$ExecutionTier, "unsandboxed_host") &&
      identical(row$ExitStatus, 0L) && is.na(row$NativeSignal) &&
      isTRUE(row$TerminalMarkerPresent) &&
      identical(row$RuntimeVersion, "5.47.5") &&
      identical(row$RuntimeEdition, "Demonstration Version") &&
      identical(row$ExpiryDate, as.Date("2026-09-01"))
  }
  restricted_failure <- identical(
    restricted$ExecutionTier, "restricted_codex_filesystem_sandbox"
  ) && identical(restricted$InputRoute, "file_stdin") &&
    is.na(restricted$ExitStatus) &&
    identical(restricted$NativeSignal, 11L) &&
    !isTRUE(restricted$TerminalMarkerPresent)
  tty_pass <- identical(tty$InputRoute, "interactive_tty") &&
    exact_runtime(tty)
  file_stdin_pass <- identical(file_stdin$InputRoute, "file_stdin") &&
    exact_runtime(file_stdin)
  route_contrast_complete <- restricted_failure && tty_pass && file_stdin_pass
  classification <- if (route_contrast_complete) {
    "runtime_available_unsandboxed_restricted_route_ineligible"
  } else if (tty_pass || file_stdin_pass) {
    "runtime_available_unsandboxed_route_contrast_incomplete"
  } else {
    "runtime_availability_not_established_by_this_contract"
  }
  data.frame(
    Specification = mfrmr_cq_alt_specification,
    ContractVersion = mfrmr_cq_alt_contract,
    Status = classification,
    RestrictedRouteFailureObserved = restricted_failure,
    UnsandboxedTtyPassed = tty_pass,
    UnsandboxedFileStdinPassed = file_stdin_pass,
    RouteContrastComplete = route_contrast_complete,
    ConQuestPathUsableUnsandboxed = tty_pass && file_stdin_pass,
    TtyRequired = FALSE,
    FileStdinCompatible = file_stdin_pass,
    RestrictedRouteEligibleForSuccessor = FALSE,
    RegistryWriteCrashLocusObserved = restricted_failure,
    RegistryWriteMechanismCausallyProven = FALSE,
    ProductFailureInferred = FALSE,
    ConsumedG4MAuthorizationReopened = FALSE,
    SuccessorExecutionReady = FALSE,
    ScientificAgreementInferred = FALSE,
    PublicClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_alt_successor_requirements <- function() {
  data.frame(
    RequirementOrder = 1:13,
    RequirementId = c(
      "CONSUMED_G4M_REMAINS_QUARANTINED",
      "RESTRICTED_LAUNCH_ROUTE_REJECTED",
      "NEW_SUCCESSOR_SPECIFICATION_FROZEN",
      "NEW_ABSENT_TARGET_FROZEN",
      "NEW_RUN_ONCE_AUTHORITY_FROZEN",
      "EXPLICIT_NEW_USER_APPROVAL_RECEIVED",
      "PREISSUE_DATA_FREE_PROBE_IN_SAME_PROCESS",
      "PREISSUE_PROBE_PASSES_BEFORE_AUTHORITY_CONSUMPTION",
      "ALL_CONQUEST_LAUNCHES_SHARE_PROVEN_PROCESS_CONTEXT",
      "POSTCONSUMPTION_FRESH_SENTINEL_PASSES",
      "EVERY_EXTERNAL_CONSOLE_RETAINED",
      "NO_AUTOMATIC_RETRY_AFTER_ANY_OPENED_LAUNCH",
      "RUN_COMPLETES_BEFORE_DEMONSTRATION_EXPIRY"
    ),
    SatisfiedNow = c(
      TRUE, TRUE, rep(FALSE, 9L), TRUE, FALSE
    ),
    BlocksSuccessorExecution = TRUE,
    MayBeSatisfiedByCallerLabelOnly = FALSE,
    MayBeSatisfiedByFileHashOnly = FALSE,
    EvidenceRule = c(
      "retain consumed incomplete target; never replay v1",
      "route contrast rejects the restricted filesystem sandbox",
      "commit a new immutable specification before any live session",
      "bind one new canonical target and verify final and incomplete absence",
      "bind the new specification, target, process, scope, and time window",
      "receive approval for the new run, not reuse of the consumed approval",
      "run the semantic quit preflight in the future live R process",
      "require semantic success before issuing or consuming run authority",
      "bind the successful probe token to current PID and exact launch route",
      "repeat the fresh sentinel after run-once authority is consumed",
      "retain stdout and stderr for probe, sentinel, and every fit attempt",
      "an opened launch consumes its authority regardless of outcome",
      "verify the live date against the runtime-reported expiry"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_alt_issue_preissue_token <- function(
    preflight_result,
    expected_executable_path,
    expected_launcher_path,
    run_not_after,
    retained_console_path,
    authorize = FALSE) {
  mfrmr_cq_alt_assert(
    identical(authorize, TRUE),
    "The pre-issue launch-tier token requires explicit data-free opt-in."
  )
  mfrmr_cq_alt_assert(
    is.list(preflight_result) && is.data.frame(preflight_result$summary) &&
      nrow(preflight_result$summary) == 1L,
    "A single semantic-preflight result is required."
  )
  mfrmr_cq_alt_assert(
    is.character(expected_executable_path) &&
      length(expected_executable_path) == 1L &&
      !is.na(expected_executable_path) && nzchar(expected_executable_path) &&
      is.character(expected_launcher_path) &&
      length(expected_launcher_path) == 1L &&
      !is.na(expected_launcher_path) && nzchar(expected_launcher_path),
    "The successor must supply explicit executable and launcher paths."
  )
  expected_executable_path <- normalizePath(
    expected_executable_path, winslash = "/", mustWork = FALSE
  )
  expected_launcher_path <- normalizePath(
    expected_launcher_path, winslash = "/", mustWork = FALSE
  )
  run_not_after <- as.Date(run_not_after)[1L]
  mfrmr_cq_alt_assert(
    !is.na(run_not_after) && run_not_after < as.Date("2026-09-01"),
    "The successor run window must end before the observed runtime expiry."
  )
  mfrmr_cq_alt_assert(
    is.character(retained_console_path) &&
      length(retained_console_path) == 1L &&
      !is.na(retained_console_path) && file.exists(retained_console_path),
    "The successful pre-issue console must already be retained."
  )
  retained_console_path <- normalizePath(
    retained_console_path, winslash = "/", mustWork = TRUE
  )
  retained_console <- enc2utf8(readLines(retained_console_path, warn = FALSE))
  summary <- preflight_result$summary
  exact <- identical(summary$Status, "runtime_semantic_ready") &&
    is.character(preflight_result$transcript) &&
    identical(enc2utf8(preflight_result$transcript), retained_console) &&
    isTRUE(summary$SemanticSuccess) &&
    identical(
      normalizePath(
        summary$ExecutablePath, winslash = "/", mustWork = FALSE
      ),
      expected_executable_path
    ) &&
    identical(summary$RuntimeVersion, "5.47.5") &&
    identical(summary$RuntimeEdition, "Demonstration Version") &&
    identical(summary$ExpiryDate, as.Date("2026-09-01")) &&
    identical(summary$ExitStatus, 0L) &&
    isTRUE(summary$TerminalMarkerPresent) &&
    isTRUE(summary$CommandIsDataFreeQuit) &&
    !isTRUE(summary$ModelEstimationAttempted) &&
    !isTRUE(summary$ScientificComparisonAuthorized) &&
    !is.na(summary$RunDate) &&
    summary$RunDate >= as.Date("2026-08-16") &&
    summary$RunDate <= run_not_after &&
    grepl("Mach-O.*x86_64", summary$Architecture) &&
    startsWith(
      summary$InvocationRoute,
      paste0(expected_launcher_path, " -x86_64 ")
    )
  mfrmr_cq_alt_assert(
    exact,
    "The pre-issue launch-tier token requires an exact semantic success."
  )
  token <- new.env(parent = emptyenv())
  token$ContractVersion <- mfrmr_cq_alt_contract
  token$ProcessId <- as.integer(Sys.getpid())
  token$ExecutablePath <- expected_executable_path
  token$LauncherPath <- expected_launcher_path
  token$InvocationRoute <- summary$InvocationRoute
  token$RunDate <- summary$RunDate
  token$RunNotAfter <- run_not_after
  token$ConsolePath <- retained_console_path
  token$ConsoleLines <- retained_console
  token$SemanticReady <- TRUE
  token$CommandIsDataFreeQuit <- TRUE
  token$ModelEstimationAttempted <- FALSE
  token$Consumed <- FALSE
  token$ConfirmationOrPublicUsePermitted <- FALSE
  class(token) <- "mfrmr_cq_alt_preissue_token"
  token
}

mfrmr_cq_alt_preissue_probe <- function(
    executable_path,
    launcher_path,
    run_not_after,
    working_dir,
    run_date = Sys.Date(),
    timeout = 30L,
    authorize = FALSE) {
  mfrmr_cq_alt_assert(
    identical(authorize, TRUE),
    "The live pre-issue probe requires explicit data-free opt-in."
  )
  mfrmr_cq_alt_assert(
    exists("mfrmr_cq_srp_preflight", mode = "function", inherits = TRUE),
    "Source the semantic runtime preflight before the launch-tier guard."
  )
  result <- mfrmr_cq_srp_preflight(
    conquest_exe = executable_path,
    launcher = launcher_path,
    launcher_args = "-x86_64",
    working_dir = working_dir,
    timeout = timeout,
    run_date = run_date
  )
  console_path <- file.path(
    normalizePath(working_dir, winslash = "/", mustWork = TRUE),
    "preissue_runtime_console.log"
  )
  writeLines(result$transcript, console_path, useBytes = TRUE)
  token <- mfrmr_cq_alt_issue_preissue_token(
    preflight_result = result,
    expected_executable_path = executable_path,
    expected_launcher_path = launcher_path,
    run_not_after = run_not_after,
    retained_console_path = console_path,
    authorize = TRUE
  )
  list(
    preflight = result,
    token = token,
    console_path = console_path,
    run_authority_issued = FALSE,
    run_authority_consumed = FALSE,
    model_estimation_attempted = FALSE,
    scientific_comparison_authorized = FALSE
  )
}

mfrmr_cq_alt_validate_preissue_token <- function(
    token, expected_executable_path, expected_launcher_path, run_date) {
  fields <- c(
    "ContractVersion", "ProcessId", "ExecutablePath", "LauncherPath",
    "InvocationRoute", "RunDate", "RunNotAfter", "ConsolePath",
    "ConsoleLines", "SemanticReady", "CommandIsDataFreeQuit",
    "ModelEstimationAttempted", "Consumed",
    "ConfirmationOrPublicUsePermitted"
  )
  expected_executable_path <- normalizePath(
    as.character(expected_executable_path)[1L],
    winslash = "/", mustWork = FALSE
  )
  expected_launcher_path <- normalizePath(
    as.character(expected_launcher_path)[1L],
    winslash = "/", mustWork = FALSE
  )
  run_date <- as.Date(run_date)[1L]
  is.environment(token) &&
    inherits(token, "mfrmr_cq_alt_preissue_token") &&
    setequal(ls(token, all.names = TRUE), fields) &&
    identical(token$ContractVersion, mfrmr_cq_alt_contract) &&
    identical(token$ProcessId, as.integer(Sys.getpid())) &&
    identical(token$ExecutablePath, expected_executable_path) &&
    identical(token$LauncherPath, expected_launcher_path) &&
    startsWith(
      token$InvocationRoute, paste0(expected_launcher_path, " -x86_64 ")
    ) && !is.na(run_date) && identical(token$RunDate, run_date) &&
    token$RunDate >= as.Date("2026-08-16") &&
    token$RunDate <= token$RunNotAfter &&
    token$RunNotAfter < as.Date("2026-09-01") &&
    file.exists(token$ConsolePath) &&
    identical(
      enc2utf8(readLines(token$ConsolePath, warn = FALSE)),
      token$ConsoleLines
    ) &&
    isTRUE(token$SemanticReady) && isTRUE(token$CommandIsDataFreeQuit) &&
    !isTRUE(token$ModelEstimationAttempted) && !isTRUE(token$Consumed) &&
    !isTRUE(token$ConfirmationOrPublicUsePermitted)
}
