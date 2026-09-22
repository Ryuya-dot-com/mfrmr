# Repository-only fail-closed harness for candidate-004 ConQuest execution.
#
# Preparation and validation are runtime-free. Execution requires the dated
# candidate-specific live authorization, exact path, explicit opt-in, and an
# unopened four-arm q61/q121 bundle. A semantic failure stops the remaining slice.

mfrmr_cq_p2c4h_specification <-
  "0.2.3-conquest-p2-candidate-004-harness-v1"
mfrmr_cq_p2c4h_contract <-
  "mfrmr_conquest_p2_candidate_004_harness_v1"

mfrmr_cq_p2c4h_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4h_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2c4h_require_contracts)
  required <- c(
    "mfrmr_cq_p2c4a_review", "mfrmr_cq_p2c4a_slice_registry",
    "mfrmr_cq_p2c4_fixture", "mfrmr_cq_srp_failure_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identities <- c(
    exists("mfrmr_cq_p2c4a_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2c4a_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_candidate_004_live_authorization_v1"
      ),
    exists("mfrmr_cq_p2c4_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2c4_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_candidate_004_coverage_conditioned_fixture_v1"
      )
  )
  mfrmr_cq_p2c4h_assert(
    all(available) && all(identities),
    "Source the exact candidate-004 fixture and live authorization first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4h_response_layout <- function() {
  out <- expand.grid(
    Criterion = paste0("C", 1:3),
    Rater = paste0("R", 1:4),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  out$ResponseName <- paste0("Y_", out$Criterion, "_", out$Rater)
  out$ResponseIndex <- seq_len(nrow(out))
  out[, c("ResponseIndex", "ResponseName", "Criterion", "Rater")]
}

mfrmr_cq_p2c4h_plan <- function() {
  mfrmr_cq_p2c4h_require_contracts()
  slice <- mfrmr_cq_p2c4a_slice_registry()
  run_id <- paste0(
    tolower(slice$Family), "_q", sprintf("%03d", slice$Nodes)
  )
  prefix <- paste0("cq_p2c4_", run_id)
  out <- data.frame(
    ExecutionOrder = slice$Sequence,
    ExecutionIdentity = slice$ExecutionIdentity,
    CandidateId = slice$CandidateId,
    Family = slice$Family,
    Nodes = slice$Nodes,
    ExpectedFreeDimension = slice$ExpectedFreeDimension,
    ExpectedNativeOutputCount = slice$ExpectedNativeOutputCount,
    RunId = run_id,
    RunDirectory = run_id,
    Prefix = prefix,
    WideFile = file.path(run_id, paste0(prefix, "_wide.csv")),
    CommandFile = file.path(run_id, paste0(prefix, ".cqc")),
    ConsoleFile = file.path(run_id, paste0(prefix, "_console.log")),
    RunOnce = TRUE,
    NewMfrmrFitAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    WiderExecutionAuthorized = FALSE,
    P3ExecutionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_p2c4h_assert(
    nrow(out) == 4L &&
      identical(out$Family, c("RSM", "RSM", "PCM", "PCM")) &&
      identical(out$Nodes, c(61L, 121L, 61L, 121L)) &&
      identical(out$ExpectedFreeDimension, c(10L, 10L, 14L, 14L)) &&
      all(out$ExpectedNativeOutputCount == 8L) &&
      !anyDuplicated(out$Prefix) && all(out$RunOnce) &&
      !any(out$NewMfrmrFitAuthorized) &&
      !any(out$EvidencePromotionAuthorized),
    "The candidate-004 harness plan drifted beyond four q61/q121 arms."
  )
  out
}

mfrmr_cq_p2c4h_wide_fixture <- function() {
  mfrmr_cq_p2c4h_require_contracts()
  source <- mfrmr_cq_p2c4_fixture()
  observed <- source$Data
  observed <- observed[order(
    observed$PersonIndex, observed$RaterIndex, observed$CriterionIndex
  ), , drop = FALSE]
  rownames(observed) <- NULL
  layout <- mfrmr_cq_p2c4h_response_layout()
  persons <- unique(observed[, c("Person", "PersonIndex", "X")])
  persons <- persons[order(persons$PersonIndex), , drop = FALSE]
  value <- matrix(
    NA_integer_, nrow = nrow(persons), ncol = nrow(layout),
    dimnames = list(persons$Person, layout$ResponseName)
  )
  person_index <- match(observed$Person, persons$Person)
  response_index <- match(
    paste(observed$Criterion, observed$Rater, sep = "::"),
    paste(layout$Criterion, layout$Rater, sep = "::")
  )
  mfrmr_cq_p2c4h_assert(
    !anyNA(c(person_index, response_index)) &&
      !anyDuplicated(paste(person_index, response_index, sep = "::")),
    "Candidate-004 rows cannot be mapped uniquely to ConQuest wide data."
  )
  value[cbind(person_index, response_index)] <- observed$Response
  wide <- data.frame(
    Person = persons$Person, X = persons$X, value,
    check.names = FALSE, stringsAsFactors = FALSE
  )
  mfrmr_cq_p2c4h_assert(
    nrow(wide) == 48L && ncol(wide) == 14L &&
      sum(!is.na(value)) == 288L && sum(is.na(value)) == 288L &&
      all(rowSums(!is.na(value)) == 6L) &&
      identical(names(wide), c("Person", "X", layout$ResponseName)),
    "Candidate-004 wide data violate the frozen 48x12 sparse design."
  )
  list(wide = wide, long = observed, layout = layout)
}

mfrmr_cq_p2c4h_command <- function(prefix, family, nodes) {
  family <- toupper(as.character(family)[1L])
  nodes <- as.integer(nodes)[1L]
  layout <- mfrmr_cq_p2c4h_response_layout()
  mfrmr_cq_p2c4h_assert(
    family %in% c("RSM", "PCM") && nodes %in% c(61L, 121L) &&
      length(prefix) == 1L && !is.na(prefix) && nzchar(prefix),
    "A candidate-004 command must use RSM/PCM, q61/q121, and one prefix."
  )
  model <- if (family == "RSM") {
    "rater + criterion + step"
  } else {
    "rater + criterion + criterion*step"
  }
  c(
    paste0("title mfrmr P2 candidate 004 ", family, " q", nodes, ";"),
    paste0("export logfile >> ", prefix, "_conquest_internal.log;"),
    paste0(
      "datafile ", prefix,
      "_wide.csv ! filetype=csv, header=yes, columnlabels=no, pid=Person, ",
      "pidwidth=16, responses=", layout$ResponseName[1L], " to ",
      layout$ResponseName[nrow(layout)],
      ", facets=criterion(3) rater(4), keeps=X, keepswidth=32;"
    ),
    "codes 0,1,2,3;",
    paste0("labels ", 1:3, " C", 1:3, " ! criterion;"),
    paste0("labels ", 1:4, " R", 1:4, " ! rater;"),
    "regression X;",
    paste0("model ", model, ";"),
    paste0(
      "estimate ! method=quadrature, nodes=", nodes,
      ", fit=no, stderr=quick, matrixout=mfrmrCQ, ",
      "convergence=0.00000001, deviancechange=0.0000000001, ",
      "iterations=2000;"
    ),
    paste0("export parameters ! filetype=csv >> ", prefix,
           "_conquest_parameters.csv;"),
    paste0("export amatrix ! filetype=csv >> ", prefix,
           "_conquest_amatrix.csv;"),
    paste0("export reg_coefficients ! filetype=csv >> ", prefix,
           "_conquest_reg_coefficients.csv;"),
    paste0("export covariance ! filetype=csv >> ", prefix,
           "_conquest_covariance.csv;"),
    paste0("show cases ! estimates=eap, filetype=csv, regressors=yes >> ",
           prefix, "_conquest_cases_eap.csv;"),
    paste0("write mfrmrCQ_history ! filetype=csv >> ", prefix,
           "_conquest_history.csv;"),
    paste0("show parameters ! tables=1:2:3:4, estimates=eap >> ", prefix,
           "_conquest_parameters_review.txt;"),
    "quit;"
  )
}

mfrmr_cq_p2c4h_native_output_registry <- function(
    plan = mfrmr_cq_p2c4h_plan()) {
  suffix <- c(
    "_conquest_internal.log", "_conquest_parameters.csv",
    "_conquest_amatrix.csv", "_conquest_reg_coefficients.csv",
    "_conquest_covariance.csv", "_conquest_cases_eap.csv",
    "_conquest_history.csv", "_conquest_parameters_review.txt"
  )
  kind <- c(
    "internal_log", "parameters", "amatrix", "regression",
    "covariance", "cases_eap", "history", "parameter_review"
  )
  out <- do.call(rbind, lapply(seq_len(nrow(plan)), function(index) {
    data.frame(
      ExecutionOrder = plan$ExecutionOrder[index],
      RunId = plan$RunId[index],
      OutputKind = kind,
      RelativePath = file.path(
        plan$RunDirectory[index], paste0(plan$Prefix[index], suffix)
      ),
      Required = TRUE,
      EvidencePromotionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  rownames(out) <- NULL
  mfrmr_cq_p2c4h_assert(
    nrow(out) == 32L && !anyDuplicated(out$RelativePath),
    "Each candidate-004 arm must have eight unique native outputs."
  )
  out
}

mfrmr_cq_p2c4h_journal_template <- function(plan = mfrmr_cq_p2c4h_plan()) {
  data.frame(
    ExecutionOrder = plan$ExecutionOrder,
    RunId = plan$RunId,
    Family = plan$Family,
    Nodes = plan$Nodes,
    ConQuestAttemptCount = 0L,
    ConQuestExitStatus = NA_integer_,
    ConQuestTerminalMarkerObserved = FALSE,
    ConQuestRegisteredFailureCount = NA_integer_,
    ConQuestNativeOutputCount = 0L,
    ConQuestStatus = "not_attempted",
    EvidencePromotionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4h_write_csv <- function(value, path) {
  utils::write.csv(value, path, row.names = FALSE, na = "")
  mfrmr_cq_p2c4h_assert(file.exists(path), paste0("Could not write `", path, "`."))
  invisible(path)
}

mfrmr_cq_p2c4h_prepare <- function(
    output_dir, authorization_date = Sys.Date(), authorize = FALSE) {
  mfrmr_cq_p2c4h_require_contracts()
  mfrmr_cq_p2c4h_assert(
    identical(authorize, TRUE),
    "Preparation is held; authorize only the frozen candidate-004 bundle."
  )
  live <- mfrmr_cq_p2c4a_review(
    output_dir = output_dir, authorization_date = authorization_date
  )
  mfrmr_cq_p2c4h_assert(
    isTRUE(live$candidate_004_external_execution_authorized) &&
      !isTRUE(live$evidence_promotion_authorized),
    "The candidate-004 live authorization is inactive or widened."
  )
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_p2c4h_assert(
    !file.exists(output_dir) && !dir.exists(output_dir),
    "The candidate-004 output directory must not already exist."
  )
  mfrmr_cq_p2c4h_assert(
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE),
    "The candidate-004 output directory could not be created."
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_p2c4h_plan()
  fixture <- mfrmr_cq_p2c4h_wide_fixture()
  native <- mfrmr_cq_p2c4h_native_output_registry(plan)
  journal <- mfrmr_cq_p2c4h_journal_template(plan)
  for (index in seq_len(nrow(plan))) {
    run_dir <- file.path(output_dir, plan$RunDirectory[index])
    mfrmr_cq_p2c4h_assert(
      dir.create(run_dir, recursive = FALSE, showWarnings = FALSE),
      paste0("Could not create run directory `", plan$RunId[index], "`.")
    )
    mfrmr_cq_p2c4h_write_csv(
      fixture$wide, file.path(output_dir, plan$WideFile[index])
    )
    writeLines(
      mfrmr_cq_p2c4h_command(
        plan$Prefix[index], plan$Family[index], plan$Nodes[index]
      ),
      file.path(output_dir, plan$CommandFile[index]), useBytes = TRUE
    )
  }
  mfrmr_cq_p2c4h_write_csv(
    fixture$long, file.path(output_dir, "sealed_fixture_long.csv")
  )
  mfrmr_cq_p2c4h_write_csv(
    fixture$layout, file.path(output_dir, "response_layout.csv")
  )
  mfrmr_cq_p2c4h_write_csv(plan, file.path(output_dir, "execution_plan.csv"))
  mfrmr_cq_p2c4h_write_csv(
    native, file.path(output_dir, "native_output_registry.csv")
  )
  mfrmr_cq_p2c4h_write_csv(
    journal, file.path(output_dir, "execution_journal.csv")
  )
  authority <- data.frame(
    Specification = mfrmr_cq_p2c4h_specification,
    ContractVersion = mfrmr_cq_p2c4h_contract,
    ExecutionIdentity = live$execution_identity,
    AuthorizationDate = as.Date(authorization_date)[1L],
    RunNotAfter = live$run_not_after,
    ExecutablePath = live$executable_path,
    AllFifteenFatalGatesPassed = live$all_fifteen_fatal_gates_passed,
    Candidate004ExternalExecutionAuthorized =
      live$candidate_004_external_execution_authorized,
    NewMfrmrFitAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    WiderExecutionAuthorized = FALSE,
    P3ExecutionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_p2c4h_write_csv(
    authority, file.path(output_dir, "authority_snapshot.csv")
  )
  reviewed <- mfrmr_cq_p2c4h_validate_prepared(output_dir)
  mfrmr_cq_p2c4h_assert(
    isTRUE(reviewed$execution_ready),
    "The prepared candidate-004 bundle failed validation."
  )
  reviewed
}

mfrmr_cq_p2c4h_validate_prepared <- function(output_dir) {
  mfrmr_cq_p2c4h_require_contracts()
  root <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_p2c4h_plan()
  root_files <- c(
    "execution_plan.csv", "execution_journal.csv",
    "native_output_registry.csv", "authority_snapshot.csv",
    "sealed_fixture_long.csv", "response_layout.csv"
  )
  mfrmr_cq_p2c4h_assert(
    all(file.exists(file.path(root, root_files))),
    "The prepared candidate-004 bundle is incomplete."
  )
  manifest <- utils::read.csv(
    file.path(root, "execution_plan.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  journal <- utils::read.csv(
    file.path(root, "execution_journal.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  native <- utils::read.csv(
    file.path(root, "native_output_registry.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  authority <- utils::read.csv(
    file.path(root, "authority_snapshot.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  plan_ok <- nrow(manifest) == 4L &&
    identical(as.character(manifest$RunId), plan$RunId) &&
    identical(as.character(manifest$Family), plan$Family) &&
    identical(as.integer(manifest$Nodes), plan$Nodes) &&
    identical(
      as.integer(manifest$ExpectedFreeDimension),
      plan$ExpectedFreeDimension
    ) && all(as.logical(manifest$RunOnce)) &&
    !any(as.logical(manifest$NewMfrmrFitAuthorized)) &&
    !any(as.logical(manifest$EvidencePromotionAuthorized))
  journal_clean <- nrow(journal) == 4L &&
    all(journal$ConQuestAttemptCount == 0L) &&
    all(journal$ConQuestStatus == "not_attempted")
  native_ok <- nrow(native) == 32L &&
    all(native$Required) && !anyDuplicated(native$RelativePath)
  authority_narrow <- nrow(authority) == 1L &&
    identical(
      as.character(authority$Specification), mfrmr_cq_p2c4h_specification
    ) && identical(
      as.character(authority$ContractVersion), mfrmr_cq_p2c4h_contract
    ) && identical(
      as.character(authority$ExecutionIdentity),
      mfrmr_cq_p2c4a_execution_identity
    ) && identical(
      as.character(authority$ExecutablePath),
      mfrmr_cq_p2c4a_executable_path
    ) &&
    isTRUE(authority$AllFifteenFatalGatesPassed) &&
    isTRUE(authority$Candidate004ExternalExecutionAuthorized) &&
    !isTRUE(authority$NewMfrmrFitAuthorized) &&
    !isTRUE(authority$EvidencePromotionAuthorized) &&
    !isTRUE(authority$WiderExecutionAuthorized) &&
    !isTRUE(authority$P3ExecutionAuthorized) &&
    !isTRUE(authority$PublicClaimAuthorized)
  fixture <- mfrmr_cq_p2c4h_wide_fixture()
  artifact_ok <- command_ok <- logical(nrow(plan))
  for (index in seq_len(nrow(plan))) {
    wide_path <- file.path(root, plan$WideFile[index])
    command_path <- file.path(root, plan$CommandFile[index])
    artifact_ok[index] <- file.exists(wide_path) && file.exists(command_path)
    if (!artifact_ok[index]) next
    wide <- utils::read.csv(
      wide_path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = ""
    )
    artifact_ok[index] <- identical(names(wide), names(fixture$wide)) &&
      identical(as.character(wide$Person), fixture$wide$Person) &&
      identical(as.numeric(wide$X), as.numeric(fixture$wide$X)) &&
      identical(
        unname(as.matrix(wide[, -(1:2), drop = FALSE])),
        unname(as.matrix(fixture$wide[, -(1:2), drop = FALSE]))
      )
    command_ok[index] <- identical(
      readLines(command_path, warn = FALSE),
      mfrmr_cq_p2c4h_command(
        plan$Prefix[index], plan$Family[index], plan$Nodes[index]
      )
    )
  }
  expected_files <- sort(c(
    root_files, plan$WideFile, plan$CommandFile
  ))
  observed_files <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE
  ))
  exact_boundary <- identical(observed_files, expected_files)
  declared_outputs <- c(
    file.path(root, native$RelativePath),
    file.path(root, plan$ConsoleFile),
    file.path(root, "execution_summary.csv")
  )
  outputs_absent <- !any(file.exists(declared_outputs))
  root_identity <- identical(
    basename(root), mfrmr_cq_p2c4a_output_basename
  )
  ready <- root_identity && plan_ok && journal_clean && native_ok && authority_narrow &&
    all(artifact_ok) && all(command_ok) && exact_boundary && outputs_absent
  list(
    specification = mfrmr_cq_p2c4h_specification,
    contract_version = mfrmr_cq_p2c4h_contract,
    status = if (ready) {
      "candidate_004_four_arm_bundle_prepared_execution_unopened"
    } else {
      "candidate_004_bundle_invalid_or_already_opened"
    },
    output_dir = root,
    plan = plan,
    journal = journal,
    native_outputs = native,
    authority = authority,
    exact_plan_ready = plan_ok,
    output_root_identity_ready = root_identity,
    semantic_fixture_ready = all(artifact_ok),
    command_semantics_ready = all(command_ok),
    exact_preexecution_file_boundary = exact_boundary,
    all_candidate_outputs_absent = outputs_absent,
    execution_ready = ready,
    execution_attempted = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_p2c4h_system_runner <- function(
    executable_path, command_file, working_dir, timeout = 1800L) {
  previous <- getwd()
  on.exit(setwd(previous), add = TRUE)
  setwd(working_dir)
  output <- tryCatch(
    suppressWarnings(system2(
      "/usr/bin/arch",
      args = c("-x86_64", shQuote(executable_path)),
      stdout = TRUE, stderr = TRUE,
      input = readLines(command_file, warn = FALSE),
      timeout = as.integer(timeout)
    )),
    error = function(error) structure(
      character(0), status = NA_integer_, host_error = conditionMessage(error)
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

mfrmr_cq_p2c4h_conquest_status <- function(
    root, arm, native_registry, execution) {
  writeLines(
    execution$console_lines, file.path(root, arm$ConsoleFile), useBytes = TRUE
  )
  failure <- mfrmr_cq_srp_failure_registry()
  failure$Observed <- vapply(failure$Regex, function(pattern) {
    any(grepl(pattern, execution$console_lines, ignore.case = TRUE, perl = TRUE))
  }, logical(1L))
  arm_native <- native_registry[
    native_registry$RunId == arm$RunId, , drop = FALSE
  ]
  paths <- file.path(root, arm_native$RelativePath)
  present <- file.exists(paths)
  nonempty <- present
  nonempty[present] <- file.info(paths[present])$size > 0
  terminal <- any(grepl("End of Program", execution$console_lines, fixed = TRUE))
  semantic_success <- identical(execution$exit_status, 0L) && terminal &&
    !any(failure$Observed) && is.na(execution$host_error) &&
    length(paths) == arm$ExpectedNativeOutputCount &&
    all(present) && all(nonempty)
  list(
    semantic_success = semantic_success,
    exit_status = execution$exit_status,
    terminal_marker_observed = terminal,
    failure_registry = failure,
    native_output_count = sum(present & nonempty),
    host_error = execution$host_error
  )
}

mfrmr_cq_p2c4h_execute <- function(
    output_dir, authorization_date = Sys.Date(), authorize = FALSE,
    executable_path = mfrmr_cq_p2c4a_executable_path, timeout = 1800L) {
  mfrmr_cq_p2c4h_assert(
    identical(authorize, TRUE),
    "Execution is held; authorize only the frozen candidate-004 slice."
  )
  mfrmr_cq_p2c4h_assert(
    length(timeout) == 1L && is.finite(timeout) && timeout > 0,
    "`timeout` must be one positive finite number of seconds."
  )
  prepared <- mfrmr_cq_p2c4h_validate_prepared(output_dir)
  mfrmr_cq_p2c4h_assert(
    isTRUE(prepared$execution_ready),
    "The run-once candidate-004 bundle is invalid or already opened."
  )
  authorization_date <- as.Date(authorization_date)[1L]
  authority <- prepared$authority
  mfrmr_cq_p2c4h_assert(
    !is.na(authorization_date) &&
      authorization_date >= as.Date(authority$AuthorizationDate) &&
      authorization_date <= as.Date(authority$RunNotAfter) &&
      identical(
        normalizePath(executable_path, winslash = "/", mustWork = FALSE),
        as.character(authority$ExecutablePath)
      ) && file.exists(executable_path) &&
      file.access(executable_path, mode = 1L) == 0L,
    "The dated authorization or exact executable-path gate is not satisfied."
  )
  root <- prepared$output_dir
  plan <- prepared$plan
  journal <- prepared$journal
  journal_path <- file.path(root, "execution_journal.csv")
  for (index in seq_len(nrow(plan))) {
    arm <- plan[index, , drop = FALSE]
    journal$ConQuestAttemptCount[index] <- 1L
    mfrmr_cq_p2c4h_write_csv(journal, journal_path)
    execution <- mfrmr_cq_p2c4h_system_runner(
      executable_path = executable_path,
      command_file = basename(arm$CommandFile),
      working_dir = file.path(root, arm$RunDirectory),
      timeout = timeout
    )
    semantic <- mfrmr_cq_p2c4h_conquest_status(
      root, arm, prepared$native_outputs, execution
    )
    journal$ConQuestExitStatus[index] <- semantic$exit_status
    journal$ConQuestTerminalMarkerObserved[index] <-
      semantic$terminal_marker_observed
    journal$ConQuestRegisteredFailureCount[index] <-
      sum(semantic$failure_registry$Observed)
    journal$ConQuestNativeOutputCount[index] <- semantic$native_output_count
    journal$ConQuestStatus[index] <- if (semantic$semantic_success) {
      "semantic_success_complete_native_output_set"
    } else {
      "semantic_failure_or_incomplete_native_output_set"
    }
    mfrmr_cq_p2c4h_write_csv(journal, journal_path)
    if (!semantic$semantic_success) break
  }
  complete <- all(
    journal$ConQuestStatus == "semantic_success_complete_native_output_set"
  )
  summary <- data.frame(
    Specification = mfrmr_cq_p2c4h_specification,
    ContractVersion = mfrmr_cq_p2c4h_contract,
    ExecutionIdentity = authority$ExecutionIdentity,
    Status = if (complete) {
      "candidate_004_external_execution_complete_independent_review_required"
    } else {
      "candidate_004_external_execution_halted_failure_retained"
    },
    ConQuestAttemptCount = sum(journal$ConQuestAttemptCount),
    CompleteConQuestFitCount = sum(
      journal$ConQuestStatus ==
        "semantic_success_complete_native_output_set"
    ),
    IndependentComprehensiveReviewPassed = FALSE,
    EvidencePromotionAuthorized = FALSE,
    WiderExecutionAuthorized = FALSE,
    P3ExecutionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_p2c4h_write_csv(
    summary, file.path(root, "execution_summary.csv")
  )
  list(
    status = summary$Status,
    output_dir = root,
    plan = plan,
    journal = journal,
    summary = summary,
    execution_complete = complete,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
