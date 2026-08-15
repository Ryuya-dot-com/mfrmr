# Repository-only fail-closed harness for the minimum P2 ConQuest diagnostic.
#
# The harness prepares and can execute only the two frozen connected-
# multibridge rows at q=31/61. Preparation and review are runtime-free. The
# execution entry point requires the dated live authorization, an explicit
# opt-in, a previously prepared run-once bundle, and the exact executable path.
# It retains failures and never promotes evidence or makes a public claim.

mfrmr_cq_mdh_specification <-
  "0.2.3-conquest-minimum-diagnostic-harness-v1"
mfrmr_cq_mdh_contract <- "mfrmr_conquest_minimum_diagnostic_harness_v1"

mfrmr_cq_mdh_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_mdh_require_contracts <- function() {
  target <- environment(mfrmr_cq_mdh_require_contracts)
  required <- c(
    "mfrmr_cq_mdal_review", "mfrmr_cq_mda_slice_registry",
    "mfrmr_cq_p2_fixture", "mfrmr_cq_p2_observed_data",
    "mfrmr_cq_srp_failure_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- c(
    exists("mfrmr_cq_mdal_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_mdal_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_minimum_diagnostic_live_authorization_v1"
      ),
    exists("mfrmr_cq_mda_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_mda_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_minimum_diagnostic_authorization_v1"
      ),
    exists("mfrmr_cq_p2_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"
      )
  )
  mfrmr_cq_mdh_assert(
    all(available) && all(identity),
    paste(
      "Source the exact runtime, P2 fixture, minimum authorization, and",
      "live-authorization contracts before the diagnostic harness."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_mdh_response_layout <- function() {
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

mfrmr_cq_mdh_plan <- function() {
  mfrmr_cq_mdh_require_contracts()
  slice <- mfrmr_cq_mda_slice_registry()
  family <- rep(slice$Family, each = 2L)
  nodes <- rep(c(31L, 61L), times = nrow(slice))
  row_index <- rep(seq_len(nrow(slice)), each = 2L)
  run_id <- paste0(tolower(family), "_q", sprintf("%03d", nodes))
  prefix <- paste0("cq_p2md_", run_id)
  out <- data.frame(
    ExecutionOrder = seq_along(run_id),
    ExecutionIdentity = slice$ExecutionIdentity[row_index],
    RegistryRowId = slice$RegistryRowId[row_index],
    SemanticFixtureId = slice$SemanticFixtureId[row_index],
    Family = family,
    Nodes = nodes,
    ExpectedFreeDimension = slice$ExpectedFreeDimension[row_index],
    ExpectedNativeOutputCount =
      slice$ExpectedNativeOutputsPerFit[row_index],
    RunId = run_id,
    RunDirectory = run_id,
    Prefix = prefix,
    WideFile = file.path(run_id, paste0(prefix, "_wide.csv")),
    CommandFile = file.path(run_id, paste0(prefix, ".cqc")),
    ConsoleFile = file.path(run_id, paste0(prefix, "_console.log")),
    MfrmrFitFile = file.path(run_id, paste0(prefix, "_mfrmr_fit.rds")),
    RunOnce = TRUE,
    EvidencePromotionAuthorized = FALSE,
    WiderExecutionAuthorized = FALSE,
    P3ExecutionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_mdh_assert(
    nrow(out) == 4L &&
      identical(out$RegistryRowId, rep(slice$RegistryRowId, each = 2L)) &&
      identical(out$Family, c("RSM", "RSM", "PCM", "PCM")) &&
      identical(out$Nodes, c(31L, 61L, 31L, 61L)) &&
      identical(out$ExpectedFreeDimension, c(10L, 10L, 14L, 14L)) &&
      all(out$ExpectedNativeOutputCount == 8L) &&
      !anyDuplicated(out$Prefix) && all(out$RunOnce) &&
      !any(out$EvidencePromotionAuthorized) &&
      !any(out$ScientificEquivalenceInferred),
    "The minimum diagnostic plan drifted beyond the authorized four arms."
  )
  out
}

mfrmr_cq_mdh_wide_fixture <- function() {
  mfrmr_cq_mdh_require_contracts()
  rsm <- mfrmr_cq_p2_fixture("P2-RSM-CONNECTED-MULTIBRIDGE")
  pcm <- mfrmr_cq_p2_fixture("P2-PCM-CONNECTED-MULTIBRIDGE")
  mfrmr_cq_mdh_assert(
    identical(rsm$Data, pcm$Data),
    "The authorized RSM and PCM rows no longer share one semantic fixture."
  )
  observed <- mfrmr_cq_p2_observed_data(rsm)
  layout <- mfrmr_cq_mdh_response_layout()
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
  mfrmr_cq_mdh_assert(
    !anyNA(c(person_index, response_index)) &&
      !anyDuplicated(paste(person_index, response_index, sep = "::")),
    "The minimum diagnostic fixture cannot be mapped uniquely to wide data."
  )
  value[cbind(person_index, response_index)] <- observed$Response
  wide <- data.frame(
    Person = persons$Person, X = persons$X, value,
    check.names = FALSE, stringsAsFactors = FALSE
  )
  mfrmr_cq_mdh_assert(
    nrow(wide) == 48L && ncol(wide) == 14L &&
      sum(!is.na(value)) == 288L && sum(is.na(value)) == 288L &&
      all(rowSums(!is.na(value)) == 6L) &&
      identical(names(wide), c("Person", "X", layout$ResponseName)),
    "The wide minimum diagnostic fixture violates its 48x12 sparse design."
  )
  list(wide = wide, long = observed, layout = layout)
}

mfrmr_cq_mdh_command <- function(prefix, family, nodes) {
  family <- toupper(as.character(family)[1L])
  nodes <- as.integer(nodes)[1L]
  layout <- mfrmr_cq_mdh_response_layout()
  mfrmr_cq_mdh_assert(
    family %in% c("RSM", "PCM") && nodes %in% c(31L, 61L) &&
      length(prefix) == 1L && !is.na(prefix) && nzchar(prefix),
    "A diagnostic command must use one frozen family, node count, and prefix."
  )
  model <- if (family == "RSM") {
    "rater + criterion + step"
  } else {
    "rater + criterion + criterion*step"
  }
  c(
    paste0("title mfrmr P2 minimum diagnostic ", family, ";"),
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

mfrmr_cq_mdh_native_output_registry <- function(plan = mfrmr_cq_mdh_plan()) {
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
  rows <- lapply(seq_len(nrow(plan)), function(index) {
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
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  mfrmr_cq_mdh_assert(
    nrow(out) == 32L && !anyDuplicated(out$RelativePath),
    "Each diagnostic arm must have eight unique native output paths."
  )
  out
}

mfrmr_cq_mdh_journal_template <- function(plan = mfrmr_cq_mdh_plan()) {
  data.frame(
    ExecutionOrder = plan$ExecutionOrder,
    RunId = plan$RunId,
    Family = plan$Family,
    Nodes = plan$Nodes,
    MfrmrAttemptCount = 0L,
    MfrmrStatus = "not_attempted",
    MfrmrExpectedDimensionObserved = FALSE,
    MfrmrInferenceReady = FALSE,
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

mfrmr_cq_mdh_write_csv <- function(value, path) {
  utils::write.csv(value, path, row.names = FALSE, na = "")
  mfrmr_cq_mdh_assert(file.exists(path), paste0("Could not write `", path, "`."))
  invisible(path)
}

mfrmr_cq_mdh_prepare <- function(
    output_dir, authorization_date = Sys.Date(), authorize = FALSE) {
  mfrmr_cq_mdh_require_contracts()
  mfrmr_cq_mdh_assert(
    identical(authorize, TRUE),
    "Preparation is held; set `authorize = TRUE` only for the frozen diagnostic."
  )
  live <- mfrmr_cq_mdal_review(authorization_date)
  mfrmr_cq_mdh_assert(
    isTRUE(live$smallest_P2_diagnostic_execution_authorized) &&
      !isTRUE(live$evidence_promotion_authorized),
    "The dated minimum P2 diagnostic live authorization is inactive or widened."
  )
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_mdh_assert(
    length(output_dir) == 1L && !is.na(output_dir) && nzchar(output_dir) &&
      !file.exists(output_dir) && !dir.exists(output_dir),
    "The diagnostic output directory must not already exist."
  )
  mfrmr_cq_mdh_assert(
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE),
    "The new diagnostic output directory could not be created."
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_mdh_plan()
  fixture <- mfrmr_cq_mdh_wide_fixture()
  native <- mfrmr_cq_mdh_native_output_registry(plan)
  journal <- mfrmr_cq_mdh_journal_template(plan)

  for (index in seq_len(nrow(plan))) {
    run_dir <- file.path(output_dir, plan$RunDirectory[index])
    mfrmr_cq_mdh_assert(
      dir.create(run_dir, recursive = FALSE, showWarnings = FALSE),
      paste0("Could not create run directory `", plan$RunId[index], "`.")
    )
    mfrmr_cq_mdh_write_csv(
      fixture$wide, file.path(output_dir, plan$WideFile[index])
    )
    writeLines(
      mfrmr_cq_mdh_command(
        plan$Prefix[index], plan$Family[index], plan$Nodes[index]
      ),
      file.path(output_dir, plan$CommandFile[index]), useBytes = TRUE
    )
  }
  mfrmr_cq_mdh_write_csv(
    fixture$long, file.path(output_dir, "sealed_fixture_long.csv")
  )
  mfrmr_cq_mdh_write_csv(
    fixture$layout, file.path(output_dir, "response_layout.csv")
  )
  mfrmr_cq_mdh_write_csv(plan, file.path(output_dir, "execution_plan.csv"))
  mfrmr_cq_mdh_write_csv(
    native, file.path(output_dir, "native_output_registry.csv")
  )
  mfrmr_cq_mdh_write_csv(
    journal, file.path(output_dir, "execution_journal.csv")
  )
  authority <- data.frame(
    Specification = mfrmr_cq_mdh_specification,
    ContractVersion = mfrmr_cq_mdh_contract,
    AuthorizationDate = as.Date(authorization_date)[1L],
    RunNotAfter = live$run_not_after,
    ExecutablePath = live$executable_path,
    AllFifteenFatalGatesPassed = live$all_fifteen_fatal_gates_passed,
    SmallestP2DiagnosticExecutionAuthorized =
      live$smallest_P2_diagnostic_execution_authorized,
    EvidencePromotionAuthorized = FALSE,
    WiderExecutionAuthorized = FALSE,
    P3ExecutionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_mdh_write_csv(
    authority, file.path(output_dir, "authority_snapshot.csv")
  )
  reviewed <- mfrmr_cq_mdh_validate_prepared(output_dir)
  mfrmr_cq_mdh_assert(
    isTRUE(reviewed$execution_ready),
    "The newly prepared minimum diagnostic bundle failed validation."
  )
  reviewed
}

mfrmr_cq_mdh_validate_prepared <- function(output_dir) {
  mfrmr_cq_mdh_require_contracts()
  root <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_mdh_plan()
  manifest_path <- file.path(root, "execution_plan.csv")
  journal_path <- file.path(root, "execution_journal.csv")
  native_path <- file.path(root, "native_output_registry.csv")
  authority_path <- file.path(root, "authority_snapshot.csv")
  required_root <- c(
    manifest_path, journal_path, native_path, authority_path,
    file.path(root, "sealed_fixture_long.csv"),
    file.path(root, "response_layout.csv")
  )
  mfrmr_cq_mdh_assert(
    all(file.exists(required_root)),
    "The prepared diagnostic bundle is incomplete."
  )
  manifest <- utils::read.csv(
    manifest_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  journal <- utils::read.csv(
    journal_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  native <- utils::read.csv(
    native_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  authority <- utils::read.csv(
    authority_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  plan_ok <- nrow(manifest) == 4L &&
    identical(as.character(manifest$RunId), plan$RunId) &&
    identical(as.character(manifest$RegistryRowId), plan$RegistryRowId) &&
    identical(as.character(manifest$Family), plan$Family) &&
    identical(as.integer(manifest$Nodes), plan$Nodes) &&
    identical(
      as.integer(manifest$ExpectedFreeDimension),
      plan$ExpectedFreeDimension
    ) && !anyDuplicated(manifest$Prefix) &&
    all(as.logical(manifest$RunOnce)) &&
    !any(as.logical(manifest$EvidencePromotionAuthorized)) &&
    !any(as.logical(manifest$WiderExecutionAuthorized)) &&
    !any(as.logical(manifest$P3ExecutionAuthorized)) &&
    !any(as.logical(manifest$PublicClaimAuthorized)) &&
    !any(as.logical(manifest$ScientificEquivalenceInferred))
  journal_clean <- nrow(journal) == 4L &&
    all(journal$MfrmrAttemptCount == 0L) &&
    all(journal$ConQuestAttemptCount == 0L) &&
    all(journal$MfrmrStatus == "not_attempted") &&
    all(journal$ConQuestStatus == "not_attempted")
  native_ok <- nrow(native) == 32L &&
    all(native$Required) && !anyDuplicated(native$RelativePath)
  authority_narrow <- nrow(authority) == 1L &&
    isTRUE(authority$AllFifteenFatalGatesPassed) &&
    isTRUE(authority$SmallestP2DiagnosticExecutionAuthorized) &&
    !isTRUE(authority$EvidencePromotionAuthorized) &&
    !isTRUE(authority$WiderExecutionAuthorized) &&
    !isTRUE(authority$P3ExecutionAuthorized) &&
    !isTRUE(authority$PublicClaimAuthorized) &&
    !isTRUE(authority$ScientificEquivalenceInferred)
  fixture <- mfrmr_cq_mdh_wide_fixture()
  artifact_ok <- logical(nrow(plan))
  command_ok <- logical(nrow(plan))
  for (index in seq_len(nrow(plan))) {
    wide_path <- file.path(root, plan$WideFile[index])
    command_path <- file.path(root, plan$CommandFile[index])
    artifact_ok[index] <- file.exists(wide_path) && file.exists(command_path)
    if (!artifact_ok[index]) next
    wide <- utils::read.csv(
      wide_path, stringsAsFactors = FALSE, check.names = FALSE,
      na.strings = ""
    )
    artifact_ok[index] <- identical(names(wide), names(fixture$wide)) &&
      identical(as.character(wide$Person), fixture$wide$Person) &&
      identical(as.numeric(wide$X), as.numeric(fixture$wide$X)) &&
      identical(
        unname(as.matrix(wide[, -(1:2), drop = FALSE])),
        unname(as.matrix(fixture$wide[, -(1:2), drop = FALSE]))
      )
    command <- readLines(command_path, warn = FALSE)
    command_ok[index] <- identical(
      command,
      mfrmr_cq_mdh_command(
        plan$Prefix[index], plan$Family[index], plan$Nodes[index]
      )
    )
  }
  expected_preexecution_files <- sort(c(
    "authority_snapshot.csv", "execution_journal.csv", "execution_plan.csv",
    "native_output_registry.csv", "response_layout.csv",
    "sealed_fixture_long.csv", plan$WideFile, plan$CommandFile
  ))
  observed_preexecution_files <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE
  ))
  exact_preexecution_boundary <- identical(
    observed_preexecution_files, expected_preexecution_files
  )
  declared_output <- c(
    file.path(root, native$RelativePath),
    file.path(root, plan$ConsoleFile),
    file.path(root, plan$MfrmrFitFile),
    file.path(root, plan$RunDirectory,
              paste0(plan$Prefix, "_mfrmr_failure.txt"))
  )
  outputs_absent <- !any(file.exists(declared_output))
  ready <- plan_ok && journal_clean && native_ok && authority_narrow &&
    all(artifact_ok) && all(command_ok) && exact_preexecution_boundary &&
    outputs_absent
  list(
    specification = mfrmr_cq_mdh_specification,
    contract_version = mfrmr_cq_mdh_contract,
    status = if (ready) {
      "minimum_P2_diagnostic_bundle_prepared_execution_unopened"
    } else {
      "minimum_P2_diagnostic_bundle_invalid_or_already_opened"
    },
    output_dir = root,
    plan = plan,
    journal = journal,
    native_outputs = native,
    authority = authority,
    exact_plan_ready = plan_ok,
    semantic_fixture_ready = all(artifact_ok),
    command_semantics_ready = all(command_ok),
    exact_preexecution_file_boundary = exact_preexecution_boundary,
    all_candidate_outputs_absent = outputs_absent,
    execution_ready = ready,
    execution_attempted = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_mdh_system_runner <- function(
    executable_path, command_file, working_dir, timeout = 1800L) {
  previous <- getwd()
  on.exit(setwd(previous), add = TRUE)
  setwd(working_dir)
  command_lines <- readLines(command_file, warn = FALSE)
  output <- tryCatch(
    suppressWarnings(system2(
      "/usr/bin/arch",
      args = c("-x86_64", shQuote(executable_path)),
      stdout = TRUE, stderr = TRUE, input = command_lines,
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

mfrmr_cq_mdh_conquest_status <- function(
    root, arm, native_registry, execution) {
  console_path <- file.path(root, arm$ConsoleFile)
  writeLines(execution$console_lines, console_path, useBytes = TRUE)
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
  terminal <- any(grepl(
    "End of Program", execution$console_lines, fixed = TRUE
  ))
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
    native_outputs_present = present,
    native_outputs_nonempty = nonempty,
    host_error = execution$host_error,
    evidence_promotion_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_mdh_mfrmr_fit <- function(root, arm, long_data) {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    return(list(success = FALSE, error = "The mfrmr namespace is not loaded."))
  }
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  person_data <- unique(long_data[, c("Person", "X")])
  warnings <- character(0)
  args <- list(
    data = transform(long_data, Score = Response),
    person = "Person", facets = c("Rater", "Criterion"), score = "Score",
    rating_min = 0, rating_max = 3, method = "MML", model = arm$Family,
    population_formula = ~ X, person_data = person_data,
    quad_points = arm$Nodes, maxit = 2000L, reltol = 1e-12,
    mml_engine = "direct"
  )
  args$data$Response <- NULL
  if (arm$Family == "PCM") args$step_facet <- "Criterion"
  fit <- tryCatch(
    withCallingHandlers(
      do.call(fit_fun, args),
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(error) error
  )
  run_dir <- file.path(root, arm$RunDirectory)
  failure_path <- file.path(
    run_dir, paste0(arm$Prefix, "_mfrmr_failure.txt")
  )
  if (inherits(fit, "error")) {
    writeLines(conditionMessage(fit), failure_path, useBytes = TRUE)
    return(list(success = FALSE, error = conditionMessage(fit)))
  }
  tryCatch({
    saveRDS(fit, file.path(root, arm$MfrmrFitFile))
    summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
    population <- data.frame(
      Parameter = c(names(fit$population$coefficients), "sigma2"),
      Estimate = c(
        as.numeric(fit$population$coefficients),
        as.numeric(fit$population$sigma2)
      ),
      stringsAsFactors = FALSE
    )
    facets <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
    steps <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
    mfrmr_cq_mdh_write_csv(
      summary, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_summary.csv"))
    )
    mfrmr_cq_mdh_write_csv(
      population,
      file.path(run_dir, paste0(arm$Prefix, "_mfrmr_population.csv"))
    )
    mfrmr_cq_mdh_write_csv(
      facets, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_facets.csv"))
    )
    mfrmr_cq_mdh_write_csv(
      steps, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_steps.csv"))
    )
    writeLines(
      if (length(warnings) == 0L) "none" else unique(warnings),
      file.path(run_dir, paste0(arm$Prefix, "_mfrmr_warnings.txt")),
      useBytes = TRUE
    )
    observed_npar <- if (nrow(summary) > 0L && "Npar" %in% names(summary)) {
      as.integer(summary$Npar[1L])
    } else {
      NA_integer_
    }
    inference_ready <- nrow(summary) > 0L &&
      "InferenceReady" %in% names(summary) &&
      isTRUE(summary$InferenceReady[1L])
    list(
      success = identical(
        observed_npar, as.integer(arm$ExpectedFreeDimension)
      ),
      observed_npar = observed_npar,
      inference_ready = inference_ready,
      warnings = unique(warnings),
      error = NA_character_
    )
  }, error = function(error) {
    writeLines(conditionMessage(error), failure_path, useBytes = TRUE)
    list(
      success = FALSE, observed_npar = NA_integer_,
      inference_ready = FALSE, warnings = unique(warnings),
      error = conditionMessage(error)
    )
  })
}

mfrmr_cq_mdh_execute <- function(
    output_dir, authorization_date = Sys.Date(), authorize = FALSE,
    executable_path = "/Applications/ConQuest/ConQuest", timeout = 1800L) {
  mfrmr_cq_mdh_assert(
    identical(authorize, TRUE),
    "Execution is held; set `authorize = TRUE` only for the frozen diagnostic."
  )
  mfrmr_cq_mdh_assert(
    length(timeout) == 1L && is.finite(timeout) && timeout > 0,
    "`timeout` must be one positive finite number of seconds."
  )
  prepared <- mfrmr_cq_mdh_validate_prepared(output_dir)
  mfrmr_cq_mdh_assert(
    isTRUE(prepared$execution_ready),
    "The run-once diagnostic bundle is invalid, incomplete, or already opened."
  )
  live <- mfrmr_cq_mdal_review(authorization_date)
  mfrmr_cq_mdh_assert(
    isTRUE(live$smallest_P2_diagnostic_execution_authorized) &&
      identical(
        normalizePath(executable_path, winslash = "/", mustWork = FALSE),
        live$executable_path
      ) && file.exists(executable_path) &&
      file.access(executable_path, mode = 1L) == 0L,
    "The live authorization or exact executable-path gate is not satisfied."
  )
  root <- prepared$output_dir
  plan <- prepared$plan
  journal <- prepared$journal
  journal_path <- file.path(root, "execution_journal.csv")
  long_data <- utils::read.csv(
    file.path(root, "sealed_fixture_long.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )

  mfrmr_hard_failure <- FALSE
  for (index in seq_len(nrow(plan))) {
    journal$MfrmrAttemptCount[index] <- 1L
    mfrmr_cq_mdh_write_csv(journal, journal_path)
    result <- mfrmr_cq_mdh_mfrmr_fit(root, plan[index, , drop = FALSE], long_data)
    journal$MfrmrStatus[index] <- if (isTRUE(result$success)) {
      if (isTRUE(result$inference_ready)) {
        "fit_complete_inference_ready"
      } else {
        "fit_complete_not_inference_ready"
      }
    } else {
      "fit_failed_or_dimension_mismatch"
    }
    journal$MfrmrExpectedDimensionObserved[index] <- isTRUE(result$success)
    journal$MfrmrInferenceReady[index] <- isTRUE(result$inference_ready)
    mfrmr_cq_mdh_write_csv(journal, journal_path)
    mfrmr_hard_failure <- mfrmr_hard_failure || !isTRUE(result$success)
  }

  if (!mfrmr_hard_failure) {
    for (index in seq_len(nrow(plan))) {
      arm <- plan[index, , drop = FALSE]
      journal$ConQuestAttemptCount[index] <- 1L
      mfrmr_cq_mdh_write_csv(journal, journal_path)
      run_dir <- file.path(root, arm$RunDirectory)
      execution <- mfrmr_cq_mdh_system_runner(
        executable_path = executable_path,
        command_file = basename(arm$CommandFile),
        working_dir = run_dir,
        timeout = timeout
      )
      semantic <- mfrmr_cq_mdh_conquest_status(
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
      mfrmr_cq_mdh_write_csv(journal, journal_path)
      if (!semantic$semantic_success) break
    }
  }

  all_mfrmr <- all(journal$MfrmrExpectedDimensionObserved)
  all_conquest <- all(
    journal$ConQuestStatus == "semantic_success_complete_native_output_set"
  )
  completed <- all_mfrmr && all_conquest
  summary <- data.frame(
    Specification = mfrmr_cq_mdh_specification,
    ContractVersion = mfrmr_cq_mdh_contract,
    Status = if (completed) {
      "diagnostic_execution_complete_independent_review_required"
    } else {
      "diagnostic_execution_halted_failure_retained"
    },
    MfrmrAttemptCount = sum(journal$MfrmrAttemptCount),
    ConQuestAttemptCount = sum(journal$ConQuestAttemptCount),
    CompleteMfrmrFitCount = sum(journal$MfrmrExpectedDimensionObserved),
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
  mfrmr_cq_mdh_write_csv(
    summary, file.path(root, "execution_summary.csv")
  )
  list(
    status = summary$Status,
    output_dir = root,
    journal = journal,
    summary = summary,
    diagnostic_execution_complete = completed,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
