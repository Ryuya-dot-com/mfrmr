# Fail-closed ASP-G4H harness for the bounded engine-mechanics smoke.
#
# Preparation consumes only the retained G3 tables and the G4E scope
# authorization. Live execution is opt-in, run-once, and must obtain a fresh
# data-free ConQuest sentinel in the same R call before any model attempt.
# Numerical cross-engine agreement is never computed by this harness.

mfrmr_cq_ameh_specification <-
  "0.2.3-conquest-adversarial-simulation-engine-mechanics-harness-v1"
mfrmr_cq_ameh_contract <-
  "mfrmr_conquest_adversarial_simulation_engine_mechanics_harness_v1"

mfrmr_cq_ameh_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ameh_require_contracts <- function() {
  target <- environment(mfrmr_cq_ameh_require_contracts)
  required <- c(
    "mfrmr_cq_amea_review", "mfrmr_cq_amea_execution_plan",
    "mfrmr_cq_amea_output_schema_registry", "mfrmr_cq_ase_review_output",
    "mfrmr_cq_ase_read_tables", "mfrmr_cq_acf_terminal_class",
    "mfrmr_cq_acf_semantic_code_map",
    "mfrmr_cq_acf_representation_bridge_registry",
    "mfrmr_cq_acf_resource_budget_registry",
    "mfrmr_cq_acf_failure_taxonomy",
    "mfrmr_cq_acf_engine_mechanics_decision",
    "mfrmr_cq_srp_assess", "mfrmr_cq_srp_observed_failures"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  required_object <- c(
    "mfrmr_cq_amea_contract", "mfrmr_cq_amea_execution_identity",
    "mfrmr_cq_amea_output_basename"
  )
  object_available <- vapply(
    required_object, exists, logical(1L), envir = target, inherits = TRUE
  )
  identity <- all(object_available) && identical(
    get("mfrmr_cq_amea_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_engine_mechanics_authorization_v1"
  )
  mfrmr_cq_ameh_assert(
    all(available) && identity,
    "Source the complete ASP-G4E dependency chain before the G4H harness."
  )
  invisible(TRUE)
}

mfrmr_cq_ameh_response_layout <- function() {
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

mfrmr_cq_ameh_source_tables <- function(smoke_output_dir) {
  mfrmr_cq_ameh_require_contracts()
  review <- mfrmr_cq_ase_review_output(smoke_output_dir)
  mfrmr_cq_ameh_assert(
    isTRUE(review$G3_complete) && isTRUE(review$semantic_replay_match) &&
      identical(review$fit_attempts, 0L),
    "The retained G3 source failed semantic replay or is no longer fit-free."
  )
  list(review = review, tables = mfrmr_cq_ase_read_tables(smoke_output_dir))
}

mfrmr_cq_ameh_relation <- function(data) {
  required <- c(
    "Person", "PersonIndex", "X", "Rater", "RaterIndex", "Criterion",
    "CriterionIndex", "Response", "ResponseObserved"
  )
  mfrmr_cq_ameh_assert(
    is.data.frame(data) && all(required %in% names(data)),
    "A response representation lacks the frozen typed relation."
  )
  out <- data[, required, drop = FALSE]
  out <- out[order(
    out$PersonIndex, out$RaterIndex, out$CriterionIndex
  ), , drop = FALSE]
  rownames(out) <- NULL
  out$Person <- as.character(out$Person)
  out$PersonIndex <- as.integer(out$PersonIndex)
  out$X <- as.numeric(out$X)
  out$Rater <- as.character(out$Rater)
  out$RaterIndex <- as.integer(out$RaterIndex)
  out$Criterion <- as.character(out$Criterion)
  out$CriterionIndex <- as.integer(out$CriterionIndex)
  out$Response <- as.integer(out$Response)
  out$ResponseObserved <- as.logical(out$ResponseObserved)
  out
}

mfrmr_cq_ameh_relation_key <- function(data) {
  paste(data$Person, data$Rater, data$Criterion, sep = "\r")
}

mfrmr_cq_ameh_canonical_from_planned <- function(planned, explicit) {
  planned <- mfrmr_cq_ameh_relation(planned)
  explicit <- mfrmr_cq_ameh_relation(explicit)
  index <- match(
    mfrmr_cq_ameh_relation_key(explicit),
    mfrmr_cq_ameh_relation_key(planned)
  )
  out <- explicit
  out$Response <- planned$Response[index]
  out$ResponseObserved <- !is.na(index)
  out
}

mfrmr_cq_ameh_wide_from_relation <- function(relation) {
  relation <- mfrmr_cq_ameh_relation(relation)
  layout <- mfrmr_cq_ameh_response_layout()
  person <- unique(relation[, c("Person", "PersonIndex", "X"), drop = FALSE])
  person <- person[order(person$PersonIndex), , drop = FALSE]
  value <- matrix(
    NA_integer_, nrow = nrow(person), ncol = nrow(layout),
    dimnames = list(person$Person, layout$ResponseName)
  )
  person_index <- match(relation$Person, person$Person)
  response_index <- match(
    paste(relation$Criterion, relation$Rater, sep = "\r"),
    paste(layout$Criterion, layout$Rater, sep = "\r")
  )
  mfrmr_cq_ameh_assert(
    !anyNA(c(person_index, response_index)) &&
      !anyDuplicated(paste(person_index, response_index, sep = "\r")),
    "A response relation cannot be mapped uniquely to ConQuest wide data."
  )
  value[cbind(person_index, response_index)] <- relation$Response
  data.frame(
    Person = person$Person, X = person$X, value,
    check.names = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_cq_ameh_relation_from_wide <- function(wide) {
  layout <- mfrmr_cq_ameh_response_layout()
  mfrmr_cq_ameh_assert(
    is.data.frame(wide) && identical(
      names(wide), c("Person", "X", layout$ResponseName)
    ),
    "A ConQuest wide table has the wrong semantic columns."
  )
  value <- as.matrix(wide[, layout$ResponseName, drop = FALSE])
  storage.mode(value) <- "integer"
  out <- expand.grid(
    ResponseIndex = seq_len(nrow(layout)),
    PersonIndex = seq_len(nrow(wide)),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  out$Person <- as.character(wide$Person[out$PersonIndex])
  out$X <- as.numeric(wide$X[out$PersonIndex])
  out$Rater <- layout$Rater[out$ResponseIndex]
  out$Criterion <- layout$Criterion[out$ResponseIndex]
  out$Response <- value[cbind(out$PersonIndex, out$ResponseIndex)]
  out$ResponseObserved <- !is.na(out$Response)
  out <- out[, c(
    "Person", "X", "Rater", "Criterion", "Response", "ResponseObserved"
  )]
  out <- out[order(out$Person, out$Rater, out$Criterion), , drop = FALSE]
  rownames(out) <- NULL
  out
}

mfrmr_cq_ameh_representation_bridge_audit <- function(tables) {
  response <- tables$response_data
  manifest <- tables$dataset_manifest
  paired_id <- manifest$DatasetId[
    manifest$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS"
  ]
  mfrmr_cq_ameh_assert(
    length(paired_id) == 2L,
    "The retained G3 source must contain two paired-missingness datasets."
  )
  bridge_contract <- mfrmr_cq_acf_representation_bridge_registry()
  out <- do.call(rbind, lapply(paired_id, function(dataset_id) {
    current <- response[response$DatasetId == dataset_id, , drop = FALSE]
    planned <- mfrmr_cq_ameh_relation(current[
      current$RepresentationId == "planned_absence", , drop = FALSE
    ])
    explicit <- mfrmr_cq_ameh_relation(current[
      current$RepresentationId == "explicit_missing", , drop = FALSE
    ])
    explicit_observed <- explicit[explicit$ResponseObserved, , drop = FALSE]
    rownames(explicit_observed) <- NULL
    observed_columns <- c(
      "Person", "PersonIndex", "X", "Rater", "RaterIndex", "Criterion",
      "CriterionIndex", "Response"
    )
    observed_equal <- identical(
      planned[, observed_columns, drop = FALSE],
      explicit_observed[, observed_columns, drop = FALSE]
    )
    planned_key <- mfrmr_cq_ameh_relation_key(planned)
    explicit_key <- mfrmr_cq_ameh_relation_key(explicit)
    missing_key <- mfrmr_cq_ameh_relation_key(
      explicit[!explicit$ResponseObserved, , drop = FALSE]
    )
    complement_equal <- setequal(setdiff(explicit_key, planned_key), missing_key) &&
      !anyDuplicated(explicit_key) && !anyDuplicated(planned_key)
    canonical_planned <- mfrmr_cq_ameh_canonical_from_planned(planned, explicit)
    canonical_columns <- c(
      "Person", "PersonIndex", "X", "Rater", "RaterIndex", "Criterion",
      "CriterionIndex", "Response", "ResponseObserved"
    )
    canonical_equal <- identical(
      canonical_planned[, canonical_columns, drop = FALSE],
      explicit[, canonical_columns, drop = FALSE]
    )
    planned_wide <- mfrmr_cq_ameh_wide_from_relation(canonical_planned)
    explicit_wide <- mfrmr_cq_ameh_wide_from_relation(explicit)
    roundtrip_equal <- isTRUE(all.equal(
      planned_wide, explicit_wide, check.attributes = FALSE
    )) && identical(
      mfrmr_cq_ameh_relation_from_wide(planned_wide),
      mfrmr_cq_ameh_relation_from_wide(explicit_wide)
    )
    passed <- c(
      observed_equal, complement_equal, canonical_equal, roundtrip_equal
    )
    family <- manifest$Family[match(dataset_id, manifest$DatasetId)]
    data.frame(
      DatasetId = dataset_id,
      Family = family,
      CheckOrder = bridge_contract$CheckOrder,
      CheckId = bridge_contract$CheckId,
      ComparisonLevel = bridge_contract$ComparisonLevel,
      Passed = passed,
      PrimaryTerminalCode = ifelse(
        passed, NA_character_, bridge_contract$TerminalCodeOnFailure
      ),
      SecondaryCode = ifelse(
        passed, NA_character_, bridge_contract$SecondaryCodeOnFailure
      ),
      ByteEqualityRequired = FALSE,
      NumericAgreementInspected = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  rownames(out) <- NULL
  mfrmr_cq_ameh_assert(
    nrow(out) == 8L && all(out$Passed) &&
      !any(out$ByteEqualityRequired) && !any(out$NumericAgreementInspected),
    "The retained paired representations failed their semantic bridge."
  )
  out
}

mfrmr_cq_ameh_dataset_input <- function(tables, dataset_id, representation_id) {
  response <- tables$response_data
  current <- response[response$DatasetId == dataset_id, , drop = FALSE]
  source_representation <- switch(
    representation_id,
    planned_absence = "planned_absence",
    explicit_missing = "explicit_missing",
    canonical_wide_missing = "explicit_missing",
    observed_rows_only = "observed_rows_only",
    stop("Unsupported mechanics representation.", call. = FALSE)
  )
  selected <- current[
    current$RepresentationId == source_representation, , drop = FALSE
  ]
  relation <- mfrmr_cq_ameh_relation(selected)
  person <- unique(relation[, c("Person", "PersonIndex", "X"), drop = FALSE])
  person <- person[order(person$PersonIndex), , drop = FALSE]
  long <- relation[, c(
    "Person", "PersonIndex", "X", "Rater", "RaterIndex", "Criterion",
    "CriterionIndex", "Response"
  )]
  mfrmr_cq_ameh_assert(
    nrow(person) == 48L && nrow(long) > 0L &&
      all(long$Response[!is.na(long$Response)] %in% 0:3),
    "A retained mechanics input has invalid Person or response support."
  )
  list(
    long = long,
    person = person[, c("Person", "X"), drop = FALSE],
    wide = mfrmr_cq_ameh_wide_from_relation(relation),
    source_representation = source_representation
  )
}

mfrmr_cq_ameh_plan <- function() {
  mfrmr_cq_ameh_require_contracts()
  out <- mfrmr_cq_amea_execution_plan()
  out$ExpectedFreeDimension <- ifelse(out$Family == "RSM", 10L, 14L)
  out$RunId <- NA_character_
  out$RunDirectory <- NA_character_
  out$Prefix <- NA_character_
  out$LongFile <- NA_character_
  out$PersonDataFile <- NA_character_
  out$WideFile <- NA_character_
  out$CommandFile <- NA_character_
  out$ConsoleFile <- NA_character_
  out$MfrmrFitFile <- NA_character_
  attempt <- which(!is.na(out$AttemptOrder))
  for (index in attempt) {
    slug <- tolower(gsub(
      "[^A-Za-z0-9]+", "_",
      paste(out$DatasetId[index], out$Engine[index], out$RepresentationId[index])
    ))
    run_id <- sprintf("%03d_%s", out$AttemptOrder[index], slug)
    prefix <- paste0("cq_asp_", run_id)
    run_dir <- file.path("runs", run_id)
    out$RunId[index] <- run_id
    out$RunDirectory[index] <- run_dir
    out$Prefix[index] <- prefix
    if (out$Engine[index] == "mfrmr") {
      out$LongFile[index] <- file.path(
        run_dir, paste0(prefix, "_long.csv")
      )
      out$PersonDataFile[index] <- file.path(
        run_dir, paste0(prefix, "_person_data.csv")
      )
      out$MfrmrFitFile[index] <- file.path(
        run_dir, paste0(prefix, "_mfrmr_fit.rds")
      )
    } else {
      out$WideFile[index] <- file.path(
        run_dir, paste0(prefix, "_wide.csv")
      )
      out$CommandFile[index] <- file.path(run_dir, paste0(prefix, ".cqc"))
      out$ConsoleFile[index] <- file.path(
        run_dir, paste0(prefix, "_conquest_console.log")
      )
    }
  }
  out$ExpectedNativeOutputCount <- ifelse(
    out$Engine == "ConQuest" & out$AttemptCap == 1L, 8L,
    ifelse(out$Engine == "mfrmr" & out$AttemptCap == 1L, 6L, 0L)
  )
  out$HarnessExecutionRequiresExplicitOptIn <- TRUE
  out$LiveSentinelMustPrecedeAttempt <- out$AttemptCap == 1L
  out$ExecutionAuthorizedByHarnessFreeze <- FALSE
  mfrmr_cq_ameh_assert(
    nrow(out) == 38L && sum(out$AttemptCap) == 30L &&
      sum(out$Engine == "mfrmr" & out$AttemptCap == 1L) == 16L &&
      sum(out$Engine == "ConQuest" & out$AttemptCap == 1L) == 14L &&
      !anyDuplicated(out$RunId[attempt]) && !anyDuplicated(out$Prefix[attempt]) &&
      all(out$HarnessExecutionRequiresExplicitOptIn) &&
      !any(out$ExecutionAuthorizedByHarnessFreeze),
    "The G4H plan is not the exact 38-row/30-attempt G4E slice."
  )
  out
}

mfrmr_cq_ameh_execution_policy <- function() {
  data.frame(
    Event = c(
      "fresh_runtime_sentinel_failure",
      "ordinary_mfrmr_fit_or_parse_failure",
      "ordinary_ConQuest_fit_or_parse_failure",
      "single_fit_timeout",
      "global_wall_time_or_storage_cap",
      "existing_or_opened_output_boundary",
      "favorable_or_unfavorable_numeric_result"
    ),
    StopLaterAttempts = c(TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE),
    RetainAllScheduledRows = TRUE,
    AutomaticRetryPermitted = FALSE,
    NumericAgreementInspected = FALSE,
    CalibrationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ameh_command <- function(prefix, family, nodes = 61L) {
  family <- toupper(as.character(family)[1L])
  nodes <- as.integer(nodes)[1L]
  layout <- mfrmr_cq_ameh_response_layout()
  mfrmr_cq_ameh_assert(
    family %in% c("RSM", "PCM") && identical(nodes, 61L) &&
      length(prefix) == 1L && !is.na(prefix) && nzchar(prefix),
    "A G4H ConQuest command must be RSM/PCM at exactly q61."
  )
  model <- if (family == "RSM") {
    "rater + criterion + step"
  } else {
    "rater + criterion + criterion*step"
  }
  c(
    paste0("title mfrmr ASP mechanics ", family, " q61;"),
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

mfrmr_cq_ameh_conquest_suffix_registry <- function() {
  data.frame(
    ArtifactKind = c(
      "internal_log", "parameters", "amatrix", "regression", "covariance",
      "cases_eap", "history", "parameter_review"
    ),
    Suffix = c(
      "_conquest_internal.log", "_conquest_parameters.csv",
      "_conquest_amatrix.csv", "_conquest_reg_coefficients.csv",
      "_conquest_covariance.csv", "_conquest_cases_eap.csv",
      "_conquest_history.csv", "_conquest_parameters_review.txt"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ameh_expected_artifact_registry <- function(
    plan = mfrmr_cq_ameh_plan()) {
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  rows <- vector("list", nrow(attempt))
  for (index in seq_len(nrow(attempt))) {
    arm <- attempt[index, , drop = FALSE]
    if (arm$Engine == "mfrmr") {
      suffix <- c(
        "_mfrmr_fit.rds", "_mfrmr_summary.csv", "_mfrmr_population.csv",
        "_mfrmr_facets.csv", "_mfrmr_steps.csv", "_mfrmr_warnings.txt",
        "_mfrmr_failure.txt"
      )
      rows[[index]] <- data.frame(
        AttemptOrder = arm$AttemptOrder,
        Engine = arm$Engine,
        ArtifactKind = c(
          "fit_rds", "summary", "population", "facets", "steps", "warnings",
          "failure_record"
        ),
        RelativePath = file.path(
          arm$RunDirectory, paste0(arm$Prefix, suffix)
        ),
        Requirement = c(rep("success", 6L), "failure"),
        stringsAsFactors = FALSE
      )
    } else {
      suffix <- mfrmr_cq_ameh_conquest_suffix_registry()
      rows[[index]] <- rbind(
        data.frame(
          AttemptOrder = arm$AttemptOrder,
          Engine = arm$Engine,
          ArtifactKind = suffix$ArtifactKind,
          RelativePath = file.path(
            arm$RunDirectory, paste0(arm$Prefix, suffix$Suffix)
          ),
          Requirement = "success",
          stringsAsFactors = FALSE
        ),
        data.frame(
          AttemptOrder = arm$AttemptOrder,
          Engine = arm$Engine,
          ArtifactKind = "console",
          RelativePath = arm$ConsoleFile,
          Requirement = "every_attempt",
          stringsAsFactors = FALSE
        )
      )
    }
  }
  out <- do.call(rbind, rows)
  out <- rbind(
    out,
    data.frame(
      AttemptOrder = NA_integer_, Engine = "ConQuest",
      ArtifactKind = "fresh_runtime_sentinel_console",
      RelativePath = "runtime_sentinel_console.log",
      Requirement = "before_any_attempt",
      stringsAsFactors = FALSE
    )
  )
  rownames(out) <- NULL
  mfrmr_cq_ameh_assert(
    nrow(out) == 239L && !anyDuplicated(out$RelativePath),
    "The G4H expected-artifact inventory drifted."
  )
  out
}

mfrmr_cq_ameh_source_audit <- function(source) {
  tables <- source$tables
  object <- c(
    "dataset_manifest", "response_data", "structural_disposition",
    "engine_outcome", "metric_outcome", "continuous_oracle",
    "smoke_result_container"
  )
  expected <- c(18L, 7032L, 18L, 36L, 216L, 36L, 1L)
  observed <- c(
    vapply(tables[object[1:6]], nrow, integer(1L)),
    as.integer(isTRUE(source$review$container_valid))
  )
  out <- data.frame(
    SourceObject = object,
    ExpectedRows = expected,
    ObservedRows = observed,
    SemanticValidationPassed = observed == expected &
      isTRUE(source$review$semantic_replay_match),
    ByteEqualityInspected = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_ameh_assert(
    nrow(out) == 7L && all(out$SemanticValidationPassed) &&
      !any(out$ByteEqualityInspected),
    "The retained G3 source-object audit failed."
  )
  out
}

mfrmr_cq_ameh_journal_template <- function(plan = mfrmr_cq_ameh_plan()) {
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  data.frame(
    AttemptOrder = attempt$AttemptOrder,
    ScheduledOutcomeOrder = attempt$ScheduledOutcomeOrder,
    DatasetId = attempt$DatasetId,
    Family = attempt$Family,
    Engine = attempt$Engine,
    RepresentationId = attempt$RepresentationId,
    AttemptCount = 0L,
    Started = FALSE,
    Completed = FALSE,
    ElapsedSeconds = NA_real_,
    ExitStatus = NA_integer_,
    TerminalMarkerObserved = NA,
    RegisteredFailureCount = NA_integer_,
    TerminalCode = "pending_not_executed",
    SecondaryCode = NA_character_,
    ParseableResult = FALSE,
    ExpectedFreeDimension = attempt$ExpectedFreeDimension,
    ObservedFreeDimension = NA_integer_,
    ModelIdentityMatch = NA,
    InferenceReady = NA,
    AutomaticRetryPermitted = FALSE,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ameh_outcome_template <- function(plan = mfrmr_cq_ameh_plan()) {
  negative <- plan$AttemptCap == 0L
  data.frame(
    ScheduledOutcomeOrder = plan$ScheduledOutcomeOrder,
    AttemptOrder = plan$AttemptOrder,
    DatasetId = plan$DatasetId,
    Family = plan$Family,
    Engine = plan$Engine,
    RepresentationId = plan$RepresentationId,
    Attempted = FALSE,
    TerminalCode = ifelse(
      negative, "expected_structural_rejection", "pending_not_executed"
    ),
    SecondaryCode = ifelse(
      negative, "retained_G3_structural_prefit_stop", NA_character_
    ),
    ParseableResult = FALSE,
    ModelIdentityMatch = ifelse(negative, NA, FALSE),
    ElapsedSeconds = ifelse(negative, 0, NA_real_),
    RowRetained = TRUE,
    NumericAgreementInspected = FALSE,
    CalibrationUsePermitted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ameh_artifact_inventory_template <- function(
    plan = mfrmr_cq_ameh_plan(),
    registry = mfrmr_cq_ameh_expected_artifact_registry(plan)) {
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  expected <- vapply(attempt$AttemptOrder, function(order) {
    paste(
      registry$ArtifactKind[
        !is.na(registry$AttemptOrder) & registry$AttemptOrder == order
      ],
      collapse = ";"
    )
  }, character(1L))
  data.frame(
    AttemptOrder = attempt$AttemptOrder,
    Engine = attempt$Engine,
    ArtifactDirectory = attempt$RunDirectory,
    ExpectedArtifactKinds = expected,
    PresentArtifactKinds = "",
    UnexpectedArtifactKinds = "",
    ArtifactSetComplete = FALSE,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ameh_resource_template <- function() {
  budget <- mfrmr_cq_acf_resource_budget_registry()
  budget <- budget[budget$Stage == "engine_mechanics_smoke", , drop = FALSE]
  data.frame(
    FitAttempts = 0L,
    ElapsedSeconds = 0,
    RetainedBytes = 0,
    WallTimeCapSeconds = budget$CumulativeWallTimeCapSeconds,
    StorageCapBytes = budget$RetainedStorageCapBytes,
    PerFitTimeoutSeconds = budget$PerFitTimeoutSeconds,
    GlobalAbortTriggered = FALSE,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ameh_execution_summary_template <- function() {
  data.frame(
    Status = "ASP_G4H_bundle_prepared_execution_unopened",
    RetainedDatasets = 18L,
    RetainedOutcomeRows = 38L,
    RetainedAttemptOutcomeRows = 0L,
    FreshRuntimeSentinelPassed = FALSE,
    MechanicsGateMet = FALSE,
    CalibrationAuthorized = FALSE,
    NumericAgreementInspected = FALSE,
    AnyFitAttempted = FALSE,
    ConQuestExecutionAttempted = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ameh_write_csv <- function(value, path) {
  utils::write.csv(value, path, row.names = FALSE, na = "")
  mfrmr_cq_ameh_assert(file.exists(path), paste0("Could not write `", path, "`."))
  invisible(path)
}

mfrmr_cq_ameh_root_table_files <- function() {
  paste0(mfrmr_cq_amea_output_schema_registry()$TableId, ".csv")
}

mfrmr_cq_ameh_output_boundary <- function(
    root,
    plan = mfrmr_cq_ameh_plan(),
    registry = mfrmr_cq_ameh_expected_artifact_registry(plan)) {
  input <- c(
    plan$LongFile, plan$PersonDataFile, plan$WideFile, plan$CommandFile
  )
  allowed <- sort(unique(c(
    mfrmr_cq_ameh_root_table_files(), "response_layout.csv",
    "expected_artifact_registry.csv", "runtime_sentinel.cqc",
    input[!is.na(input)], registry$RelativePath
  )))
  observed <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE
  ))
  unexpected <- setdiff(observed, allowed)
  list(
    passed = length(unexpected) == 0L,
    unexpected_files = unexpected,
    allowed_files = allowed,
    observed_files = observed
  )
}

mfrmr_cq_ameh_prepare <- function(
    smoke_output_dir,
    output_dir,
    authorization_date = Sys.Date(),
    authorize = FALSE,
    worktree_clean = TRUE,
    ordinary_tests_external_runtime_free = TRUE) {
  mfrmr_cq_ameh_require_contracts()
  mfrmr_cq_ameh_assert(
    identical(authorize, TRUE),
    "Preparation is held; authorize only the frozen G4H mechanics bundle."
  )
  live_scope <- mfrmr_cq_amea_review(
    smoke_output_dir = smoke_output_dir,
    output_dir = output_dir,
    authorization_date = authorization_date,
    worktree_clean = worktree_clean,
    ordinary_tests_external_runtime_free = ordinary_tests_external_runtime_free
  )
  mfrmr_cq_ameh_assert(
    isTRUE(live_scope$engine_mechanics_scope_authorized) &&
      isTRUE(live_scope$harness_preparation_authorized) &&
      !isTRUE(live_scope$live_execution_authorized),
    "The G4E scope authorization is inactive, widened, or already live."
  )
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_ameh_assert(
    identical(basename(output_dir), mfrmr_cq_amea_output_basename) &&
      !file.exists(output_dir) && !dir.exists(output_dir) &&
      !file.exists(paste0(output_dir, ".incomplete")) &&
      !dir.exists(paste0(output_dir, ".incomplete")),
    "The exact G4H output root and its incomplete sibling must be absent."
  )
  mfrmr_cq_ameh_assert(
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE),
    "The G4H output root could not be created."
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  source <- mfrmr_cq_ameh_source_tables(smoke_output_dir)
  source_audit <- mfrmr_cq_ameh_source_audit(source)
  bridge <- mfrmr_cq_ameh_representation_bridge_audit(source$tables)
  plan <- mfrmr_cq_ameh_plan()
  journal <- mfrmr_cq_ameh_journal_template(plan)
  outcome <- mfrmr_cq_ameh_outcome_template(plan)
  artifact_registry <- mfrmr_cq_ameh_expected_artifact_registry(plan)
  artifact_inventory <- mfrmr_cq_ameh_artifact_inventory_template(
    plan, artifact_registry
  )
  authority <- data.frame(
    Specification = mfrmr_cq_ameh_specification,
    ContractVersion = mfrmr_cq_ameh_contract,
    ExecutionIdentity = live_scope$execution_identity,
    AuthorizationDate = as.Date(authorization_date)[1L],
    RunNotAfter = live_scope$run_not_after,
    ExecutablePath = live_scope$runtime_contract$ExecutablePath,
    SmokeOutputDir = normalizePath(
      smoke_output_dir, winslash = "/", mustWork = TRUE
    ),
    OutputDir = output_dir,
    ScopeAuthorized = TRUE,
    HarnessPreparationAuthorized = TRUE,
    LiveSentinelObserved = FALSE,
    LiveExecutionAuthorized = FALSE,
    NumericAgreementInspectionAuthorized = FALSE,
    CalibrationAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  schema <- mfrmr_cq_amea_output_schema_registry()
  resource <- mfrmr_cq_ameh_resource_template()
  execution_summary <- mfrmr_cq_ameh_execution_summary_template()
  mfrmr_cq_ameh_write_csv(
    authority, file.path(output_dir, "authority_snapshot.csv")
  )
  mfrmr_cq_ameh_write_csv(
    source_audit, file.path(output_dir, "retained_source_audit.csv")
  )
  mfrmr_cq_ameh_write_csv(
    bridge, file.path(output_dir, "representation_bridge_audit.csv")
  )
  mfrmr_cq_ameh_write_csv(plan, file.path(output_dir, "execution_plan.csv"))
  mfrmr_cq_ameh_write_csv(
    journal, file.path(output_dir, "attempt_journal.csv")
  )
  mfrmr_cq_ameh_write_csv(
    outcome, file.path(output_dir, "engine_outcome.csv")
  )
  mfrmr_cq_ameh_write_csv(
    artifact_inventory,
    file.path(output_dir, "attempt_artifact_inventory.csv")
  )
  mfrmr_cq_ameh_write_csv(
    resource, file.path(output_dir, "resource_summary.csv")
  )
  mfrmr_cq_ameh_write_csv(
    execution_summary, file.path(output_dir, "execution_summary.csv")
  )
  mfrmr_cq_ameh_write_csv(
    mfrmr_cq_ameh_response_layout(),
    file.path(output_dir, "response_layout.csv")
  )
  mfrmr_cq_ameh_write_csv(
    artifact_registry,
    file.path(output_dir, "expected_artifact_registry.csv")
  )
  writeLines(
    "quit;", file.path(output_dir, "runtime_sentinel.cqc"), useBytes = TRUE
  )
  attempt_index <- which(plan$AttemptCap == 1L)
  for (index in attempt_index) {
    arm <- plan[index, , drop = FALSE]
    run_dir <- file.path(output_dir, arm$RunDirectory)
    mfrmr_cq_ameh_assert(
      dir.create(run_dir, recursive = TRUE, showWarnings = FALSE),
      paste0("Could not create mechanics run directory `", arm$RunId, "`.")
    )
    input <- mfrmr_cq_ameh_dataset_input(
      source$tables, arm$DatasetId, arm$RepresentationId
    )
    if (arm$Engine == "mfrmr") {
      mfrmr_cq_ameh_write_csv(input$long, file.path(output_dir, arm$LongFile))
      mfrmr_cq_ameh_write_csv(
        input$person, file.path(output_dir, arm$PersonDataFile)
      )
    } else {
      mfrmr_cq_ameh_write_csv(input$wide, file.path(output_dir, arm$WideFile))
      writeLines(
        mfrmr_cq_ameh_command(arm$Prefix, arm$Family, 61L),
        file.path(output_dir, arm$CommandFile), useBytes = TRUE
      )
    }
  }
  reviewed <- mfrmr_cq_ameh_validate_prepared(output_dir)
  mfrmr_cq_ameh_assert(
    isTRUE(reviewed$execution_ready),
    "The prepared G4H bundle failed its semantic validation."
  )
  reviewed
}

mfrmr_cq_ameh_same_frame <- function(observed, expected) {
  isTRUE(all.equal(
    observed, expected, tolerance = 0, check.attributes = FALSE
  ))
}

mfrmr_cq_ameh_validate_prepared <- function(output_dir) {
  mfrmr_cq_ameh_require_contracts()
  root <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_ameh_plan()
  root_files <- c(
    mfrmr_cq_ameh_root_table_files(), "response_layout.csv",
    "expected_artifact_registry.csv", "runtime_sentinel.cqc"
  )
  input_files <- c(
    plan$LongFile[!is.na(plan$LongFile)],
    plan$PersonDataFile[!is.na(plan$PersonDataFile)],
    plan$WideFile[!is.na(plan$WideFile)],
    plan$CommandFile[!is.na(plan$CommandFile)]
  )
  expected_files <- sort(c(root_files, input_files))
  observed_files <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE
  ))
  exact_boundary <- identical(observed_files, expected_files)
  tables_present <- all(file.exists(file.path(root, root_files)))
  mfrmr_cq_ameh_assert(
    tables_present,
    "The prepared G4H root lacks one or more required contract files."
  )
  authority <- utils::read.csv(
    file.path(root, "authority_snapshot.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  manifest <- utils::read.csv(
    file.path(root, "execution_plan.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  journal <- utils::read.csv(
    file.path(root, "attempt_journal.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  outcome <- utils::read.csv(
    file.path(root, "engine_outcome.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  bridge <- utils::read.csv(
    file.path(root, "representation_bridge_audit.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  bridge$PrimaryTerminalCode <- as.character(bridge$PrimaryTerminalCode)
  bridge$SecondaryCode <- as.character(bridge$SecondaryCode)
  source_audit <- utils::read.csv(
    file.path(root, "retained_source_audit.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  artifact_registry <- utils::read.csv(
    file.path(root, "expected_artifact_registry.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  source <- mfrmr_cq_ameh_source_tables(authority$SmokeOutputDir[1L])
  plan_ok <- nrow(manifest) == 38L &&
    identical(as.integer(manifest$ScheduledOutcomeOrder), 1:38) &&
    identical(as.character(manifest$DatasetId), plan$DatasetId) &&
    identical(as.character(manifest$Engine), plan$Engine) &&
    identical(as.character(manifest$RepresentationId), plan$RepresentationId) &&
    identical(as.integer(manifest$AttemptCap), plan$AttemptCap) &&
    sum(as.integer(manifest$AttemptCap)) == 30L
  authority_ok <- nrow(authority) == 1L &&
    identical(as.character(authority$Specification), mfrmr_cq_ameh_specification) &&
    identical(as.character(authority$ContractVersion), mfrmr_cq_ameh_contract) &&
    identical(as.character(authority$ExecutionIdentity),
              mfrmr_cq_amea_execution_identity) &&
    identical(as.character(authority$ExecutablePath),
              "/Applications/ConQuest/ConQuest") &&
    isTRUE(authority$ScopeAuthorized) &&
    isTRUE(authority$HarnessPreparationAuthorized) &&
    !isTRUE(authority$LiveSentinelObserved) &&
    !isTRUE(authority$LiveExecutionAuthorized) &&
    !isTRUE(authority$NumericAgreementInspectionAuthorized) &&
    !isTRUE(authority$CalibrationAuthorized) &&
    !isTRUE(authority$PublicClaimAuthorized)
  journal_clean <- nrow(journal) == 30L &&
    identical(as.integer(journal$AttemptOrder), 1:30) &&
    all(journal$AttemptCount == 0L) && !any(journal$Started) &&
    !any(journal$Completed) &&
    all(journal$TerminalCode == "pending_not_executed") &&
    !any(journal$AutomaticRetryPermitted) &&
    !any(journal$NumericAgreementInspected)
  negative <- outcome$TerminalCode == "expected_structural_rejection"
  outcome_clean <- nrow(outcome) == 38L && sum(negative) == 8L &&
    sum(outcome$TerminalCode == "pending_not_executed") == 30L &&
    !any(outcome$Attempted) && all(outcome$RowRetained) &&
    !any(outcome$NumericAgreementInspected) &&
    !any(outcome$CalibrationUsePermitted)
  bridge_ok <- nrow(bridge) == 8L && all(bridge$Passed) &&
    !any(bridge$ByteEqualityRequired) &&
    !any(bridge$NumericAgreementInspected) &&
    mfrmr_cq_ameh_same_frame(
      bridge, mfrmr_cq_ameh_representation_bridge_audit(source$tables)
    )
  source_ok <- nrow(source_audit) == 7L &&
    all(source_audit$SemanticValidationPassed) &&
    !any(source_audit$ByteEqualityInspected) &&
    mfrmr_cq_ameh_same_frame(source_audit, mfrmr_cq_ameh_source_audit(source))
  artifact_registry_ok <- nrow(artifact_registry) == 239L &&
    !anyDuplicated(artifact_registry$RelativePath) &&
    mfrmr_cq_ameh_same_frame(
      artifact_registry, mfrmr_cq_ameh_expected_artifact_registry(plan)
    )
  input_ok <- command_ok <- logical(sum(plan$AttemptCap))
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  for (index in seq_len(nrow(attempt))) {
    arm <- attempt[index, , drop = FALSE]
    expected <- mfrmr_cq_ameh_dataset_input(
      source$tables, arm$DatasetId, arm$RepresentationId
    )
    if (arm$Engine == "mfrmr") {
      long <- utils::read.csv(
        file.path(root, arm$LongFile), stringsAsFactors = FALSE,
        check.names = FALSE, na.strings = ""
      )
      person <- utils::read.csv(
        file.path(root, arm$PersonDataFile), stringsAsFactors = FALSE,
        check.names = FALSE, na.strings = ""
      )
      input_ok[index] <- mfrmr_cq_ameh_same_frame(long, expected$long) &&
        mfrmr_cq_ameh_same_frame(person, expected$person)
      command_ok[index] <- TRUE
    } else {
      wide <- utils::read.csv(
        file.path(root, arm$WideFile), stringsAsFactors = FALSE,
        check.names = FALSE, na.strings = ""
      )
      input_ok[index] <- mfrmr_cq_ameh_same_frame(wide, expected$wide)
      command_ok[index] <- identical(
        readLines(file.path(root, arm$CommandFile), warn = FALSE),
        mfrmr_cq_ameh_command(arm$Prefix, arm$Family, 61L)
      )
    }
  }
  outputs_absent <- !any(file.exists(file.path(
    root, artifact_registry$RelativePath
  )))
  sentinel_exact <- identical(
    readLines(file.path(root, "runtime_sentinel.cqc"), warn = FALSE), "quit;"
  )
  root_identity <- identical(basename(root), mfrmr_cq_amea_output_basename)
  ready <- root_identity && exact_boundary && plan_ok && authority_ok &&
    journal_clean && outcome_clean && bridge_ok && source_ok &&
    artifact_registry_ok && all(input_ok) && all(command_ok) &&
    outputs_absent && sentinel_exact
  list(
    specification = mfrmr_cq_ameh_specification,
    contract_version = mfrmr_cq_ameh_contract,
    status = if (ready) {
      "ASP_G4H_bundle_prepared_execution_unopened"
    } else {
      "ASP_G4H_bundle_invalid_incomplete_or_already_opened"
    },
    output_dir = root,
    authority = authority,
    plan = plan,
    journal = journal,
    outcome = outcome,
    representation_bridge = bridge,
    source_audit = source_audit,
    expected_artifacts = artifact_registry,
    exact_plan_ready = plan_ok,
    exact_preexecution_file_boundary = exact_boundary,
    semantic_source_ready = source_ok,
    representation_bridge_ready = bridge_ok,
    semantic_inputs_ready = all(input_ok),
    command_semantics_ready = all(command_ok),
    all_execution_outputs_absent = outputs_absent,
    fresh_runtime_sentinel_observed = FALSE,
    execution_ready = ready,
    execution_attempted = FALSE,
    numeric_agreement_inspected = FALSE,
    calibration_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_ameh_system_runner <- function(
    executable_path, input_lines, working_dir, timeout) {
  previous <- getwd()
  on.exit(setwd(previous), add = TRUE)
  setwd(working_dir)
  output <- tryCatch(
    suppressWarnings(system2(
      "/usr/bin/arch",
      args = c("-x86_64", shQuote(executable_path)),
      stdout = TRUE, stderr = TRUE, input = input_lines,
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

mfrmr_cq_ameh_architecture <- function(executable_path) {
  output <- tryCatch(
    suppressWarnings(system2(
      "/usr/bin/file", args = shQuote(executable_path),
      stdout = TRUE, stderr = TRUE
    )),
    error = function(error) character(0)
  )
  paste(enc2utf8(as.character(output)), collapse = " | ")
}

mfrmr_cq_ameh_assess_sentinel <- function(
    execution,
    executable_path,
    architecture,
    run_date) {
  assessment <- mfrmr_cq_srp_assess(
    console_lines = execution$console_lines,
    exit_status = execution$exit_status,
    executable_path = executable_path,
    executable_available = file.exists(executable_path),
    executable = file.exists(executable_path) &&
      file.access(executable_path, mode = 1L) == 0L,
    launcher_available = file.exists("/usr/bin/arch") &&
      file.access("/usr/bin/arch", mode = 1L) == 0L,
    architecture = architecture,
    invocation_route = paste(
      "/usr/bin/arch -x86_64", shQuote(executable_path)
    ),
    run_date = as.Date(run_date)[1L],
    command_is_data_free_quit = TRUE,
    host_error = execution$host_error
  )
  summary <- assessment$summary
  assessment$exact_runtime_ready <- identical(
    summary$Status, "runtime_semantic_ready"
  ) && isTRUE(summary$SemanticSuccess) &&
    identical(summary$RuntimeVersion, "5.47.5") &&
    identical(summary$RuntimeEdition, "Demonstration Version") &&
    identical(summary$ExpiryDate, as.Date("2026-09-01")) &&
    identical(summary$ExecutablePath, executable_path) &&
    !isTRUE(summary$ExpiredByDate) &&
    !isTRUE(summary$ModelEstimationAttempted) &&
    !isTRUE(summary$ScientificComparisonAuthorized)
  assessment
}

mfrmr_cq_ameh_fresh_sentinel <- function(
    root,
    executable_path,
    run_date,
    timeout = 30L) {
  console_path <- file.path(root, "runtime_sentinel_console.log")
  mfrmr_cq_ameh_assert(
    !file.exists(console_path),
    "A prior sentinel console exists; the run-once G4H bundle is consumed."
  )
  execution <- mfrmr_cq_ameh_system_runner(
    executable_path = executable_path,
    input_lines = readLines(
      file.path(root, "runtime_sentinel.cqc"), warn = FALSE
    ),
    working_dir = root,
    timeout = timeout
  )
  writeLines(execution$console_lines, console_path, useBytes = TRUE)
  mfrmr_cq_ameh_assess_sentinel(
    execution = execution,
    executable_path = executable_path,
    architecture = mfrmr_cq_ameh_architecture(executable_path),
    run_date = run_date
  )
}

mfrmr_cq_ameh_primary_from_secondary <- function(codes) {
  codes <- unique(as.character(codes))
  codes <- codes[!is.na(codes) & nzchar(codes)]
  if (length(codes) == 0L) return(character(0))
  map <- mfrmr_cq_acf_semantic_code_map()
  index <- match(codes, map$SecondaryCode)
  c(
    map$PrimaryTerminalCode[index[!is.na(index)]],
    codes[codes %in% mfrmr_cq_acf_failure_taxonomy()$TerminalCode]
  )
}

mfrmr_cq_ameh_terminal <- function(primary_codes) {
  primary_codes <- unique(as.character(primary_codes))
  primary_codes <- primary_codes[!is.na(primary_codes) & nzchar(primary_codes)]
  if (length(primary_codes) == 0L) return("complete_numeric_eligible")
  mfrmr_cq_acf_terminal_class(primary_codes)
}

mfrmr_cq_ameh_loaded_namespace <- function(source_root) {
  source_root <- normalizePath(
    as.character(source_root)[1L], winslash = "/", mustWork = TRUE
  )
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop("The mfrmr namespace is unavailable.", call. = FALSE)
  }
  namespace <- asNamespace("mfrmr")
  required_internal <- c("with_preserved_rng_seed", "mfrm_ic_common_panel")
  available <- vapply(
    required_internal, exists, logical(1L),
    envir = namespace, inherits = FALSE
  )
  version <- tryCatch(
    as.character(utils::packageVersion("mfrmr")),
    error = function(error) NA_character_
  )
  namespace_path <- tryCatch(
    normalizePath(
      getNamespaceInfo(namespace, "path"), winslash = "/", mustWork = TRUE
    ),
    error = function(error) NA_character_
  )
  if (!all(available) || !identical(version, "0.2.3") ||
      !identical(namespace_path, source_root)) {
    stop(
      paste(
        "The loaded mfrmr namespace is not the 0.2.3 working-tree source;",
        "use pkgload::load_all('.')."
      ),
      call. = FALSE
    )
  }
  namespace
}

mfrmr_cq_ameh_mfrmr_fit <- function(root, arm, timeout) {
  run_dir <- file.path(root, arm$RunDirectory)
  failure_path <- file.path(
    run_dir, paste0(arm$Prefix, "_mfrmr_failure.txt")
  )
  start <- proc.time()[["elapsed"]]
  warnings <- character(0)
  namespace <- tryCatch(
    {
      authority <- utils::read.csv(
        file.path(root, "authority_snapshot.csv"), stringsAsFactors = FALSE,
        check.names = FALSE, na.strings = ""
      )
      source_root <- normalizePath(
        file.path(authority$SmokeOutputDir[1L], "..", ".."),
        winslash = "/", mustWork = TRUE
      )
      mfrmr_cq_ameh_loaded_namespace(source_root)
    },
    error = function(error) error
  )
  if (inherits(namespace, "error")) {
    writeLines(conditionMessage(namespace), failure_path, useBytes = TRUE)
    return(list(
      elapsed_seconds = proc.time()[["elapsed"]] - start,
      terminal_code = "model_identity_mismatch",
      secondary_code = "mfrmr_working_tree_namespace_mismatch",
      parseable = FALSE, observed_dimension = NA_integer_,
      model_identity_match = FALSE, inference_ready = FALSE,
      exit_status = NA_integer_, terminal_marker = NA,
      registered_failure_count = 1L
    ))
  }
  fit_fun <- get("fit_mfrm", envir = namespace, inherits = FALSE)
  long <- utils::read.csv(
    file.path(root, arm$LongFile), stringsAsFactors = FALSE,
    check.names = FALSE, na.strings = ""
  )
  person <- utils::read.csv(
    file.path(root, arm$PersonDataFile), stringsAsFactors = FALSE,
    check.names = FALSE, na.strings = ""
  )
  data <- long
  data$Score <- data$Response
  data$Response <- NULL
  args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 0,
    rating_max = 3,
    method = "MML",
    model = arm$Family,
    population_formula = ~ X,
    person_data = person,
    quad_points = 61L,
    maxit = 2000L,
    reltol = 1e-12,
    mml_engine = "direct"
  )
  if (arm$Family == "PCM") args$step_facet <- "Criterion"
  mfrmr_cq_ameh_assert(
    identical(as.integer(timeout), 600L),
    "The mfrmr mechanics fit requires the frozen 600-second timeout."
  )
  on.exit(
    setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE), add = TRUE
  )
  setTimeLimit(cpu = Inf, elapsed = as.numeric(timeout), transient = TRUE)
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
  setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
  if (inherits(fit, "error")) {
    message <- conditionMessage(fit)
    timed_out <- grepl(
      "time limit|elapsed time", message, ignore.case = TRUE, perl = TRUE
    )
    writeLines(message, failure_path, useBytes = TRUE)
    return(list(
      elapsed_seconds = proc.time()[["elapsed"]] - start,
      terminal_code = if (timed_out) "fit_timeout" else "optimizer_error",
      secondary_code = if (timed_out) "mfrmr_fit_timeout" else "mfrmr_fit_error",
      parseable = FALSE, observed_dimension = NA_integer_,
      model_identity_match = FALSE, inference_ready = FALSE,
      exit_status = NA_integer_, terminal_marker = NA,
      registered_failure_count = 1L
    ))
  }
  result <- tryCatch({
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
    saveRDS(fit, file.path(root, arm$MfrmrFitFile), version = 3)
    mfrmr_cq_ameh_write_csv(
      summary, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_summary.csv"))
    )
    mfrmr_cq_ameh_write_csv(
      population,
      file.path(run_dir, paste0(arm$Prefix, "_mfrmr_population.csv"))
    )
    mfrmr_cq_ameh_write_csv(
      facets, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_facets.csv"))
    )
    mfrmr_cq_ameh_write_csv(
      steps, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_steps.csv"))
    )
    writeLines(
      if (length(warnings) == 0L) "none" else unique(warnings),
      file.path(run_dir, paste0(arm$Prefix, "_mfrmr_warnings.txt")),
      useBytes = TRUE
    )
    observed_dimension <- if (
      nrow(summary) > 0L && "Npar" %in% names(summary)
    ) as.integer(summary$Npar[1L]) else NA_integer_
    identity <- identical(
      observed_dimension, as.integer(arm$ExpectedFreeDimension)
    )
    inference_ready <- nrow(summary) > 0L &&
      "InferenceReady" %in% names(summary) &&
      isTRUE(summary$InferenceReady[1L])
    fit_numeric <- c(
      if ("Deviance" %in% names(summary)) summary$Deviance[1L] else NA_real_,
      population$Estimate,
      if ("Estimate" %in% names(facets)) facets$Estimate else NA_real_,
      if ("Estimate" %in% names(steps)) steps$Estimate else NA_real_
    )
    finite <- length(fit_numeric) > 0L && all(is.finite(fit_numeric))
    terminal <- if (!identity) {
      "model_identity_mismatch"
    } else if (!finite) {
      "nonfinite_fit_output"
    } else if (!inference_ready) {
      "optimizer_nonconvergence_or_readiness_hold"
    } else {
      "complete_numeric_eligible"
    }
    list(
      terminal_code = terminal,
      secondary_code = if (terminal == "complete_numeric_eligible") {
        NA_character_
      } else {
        paste0("mfrmr_", terminal)
      },
      parseable = identity && finite,
      observed_dimension = observed_dimension,
      model_identity_match = identity,
      inference_ready = inference_ready,
      registered_failure_count = as.integer(
        terminal != "complete_numeric_eligible"
      )
    )
  }, error = function(error) {
    writeLines(conditionMessage(error), failure_path, useBytes = TRUE)
    list(
      terminal_code = "native_output_parse_failure",
      secondary_code = "mfrmr_result_serialization_or_parse_failure",
      parseable = FALSE, observed_dimension = NA_integer_,
      model_identity_match = FALSE, inference_ready = FALSE,
      registered_failure_count = 1L
    )
  })
  result$elapsed_seconds <- proc.time()[["elapsed"]] - start
  result$exit_status <- NA_integer_
  result$terminal_marker <- NA
  result
}

mfrmr_cq_ameh_conquest_fit <- function(root, arm, executable_path, timeout) {
  run_dir <- file.path(root, arm$RunDirectory)
  start <- proc.time()[["elapsed"]]
  execution <- mfrmr_cq_ameh_system_runner(
    executable_path = executable_path,
    input_lines = readLines(file.path(root, arm$CommandFile), warn = FALSE),
    working_dir = run_dir,
    timeout = timeout
  )
  writeLines(
    execution$console_lines, file.path(root, arm$ConsoleFile), useBytes = TRUE
  )
  failure <- mfrmr_cq_srp_observed_failures(execution$console_lines)
  terminal_marker <- any(grepl(
    "End of Program", execution$console_lines, fixed = TRUE
  ))
  suffix <- mfrmr_cq_ameh_conquest_suffix_registry()
  native_path <- file.path(run_dir, paste0(arm$Prefix, suffix$Suffix))
  present <- file.exists(native_path)
  nonempty <- present
  nonempty[present] <- file.info(native_path[present])$size > 0
  secondary <- failure$FailureCode[failure$Observed]
  timed_out <- identical(execution$exit_status, 124L) ||
    (!is.na(execution$host_error) && grepl(
      "time limit|timed out|timeout", execution$host_error,
      ignore.case = TRUE, perl = TRUE
    ))
  if (timed_out) secondary <- c(secondary, "conquest_fit_timeout")
  if (is.na(execution$exit_status)) {
    secondary <- c(secondary, "exit_status_missing")
  } else if (execution$exit_status != 0L) {
    secondary <- c(secondary, "process_exit_nonzero")
  }
  if (!is.na(execution$host_error) && nzchar(execution$host_error)) {
    secondary <- c(secondary, "host_execution_error")
  }
  if (!terminal_marker) secondary <- c(secondary, "terminal_marker_missing")
  if (!all(present & nonempty)) {
    secondary <- c(secondary, "incomplete_output_set")
  }
  parseable <- FALSE
  observed_dimension <- NA_integer_
  identity <- FALSE
  finite <- FALSE
  if (length(secondary) == 0L) {
    parsed <- tryCatch({
      parameter <- utils::read.csv(
        native_path[suffix$ArtifactKind == "parameters"],
        stringsAsFactors = FALSE, check.names = FALSE
      )
      regression <- utils::read.csv(
        native_path[suffix$ArtifactKind == "regression"],
        stringsAsFactors = FALSE, check.names = FALSE
      )
      covariance <- utils::read.csv(
        native_path[suffix$ArtifactKind == "covariance"],
        stringsAsFactors = FALSE, check.names = FALSE
      )
      observed_dimension <- nrow(parameter) + nrow(regression) + nrow(covariance)
      estimate <- c(
        parameter$Estimate, regression$Estimate, covariance$Covariance
      )
      list(
        observed_dimension = as.integer(observed_dimension),
        finite = length(estimate) == observed_dimension &&
          all(is.finite(as.numeric(estimate)))
      )
    }, error = function(error) NULL)
    if (is.null(parsed)) {
      secondary <- c(secondary, "native_output_parse_failure")
    } else {
      observed_dimension <- parsed$observed_dimension
      finite <- parsed$finite
      identity <- identical(
        observed_dimension, as.integer(arm$ExpectedFreeDimension)
      )
      parseable <- finite && identity
      if (!identity) secondary <- c(secondary, "model_identity_mismatch")
      if (!finite) secondary <- c(secondary, "nonfinite_fit_output")
    }
  }
  primary <- mfrmr_cq_ameh_primary_from_secondary(secondary)
  if ("conquest_fit_timeout" %in% secondary) {
    primary <- c(primary, "fit_timeout")
  }
  if ("native_output_parse_failure" %in% secondary) {
    primary <- c(primary, "native_output_parse_failure")
  }
  if ("model_identity_mismatch" %in% secondary) {
    primary <- c(primary, "model_identity_mismatch")
  }
  if ("nonfinite_fit_output" %in% secondary) {
    primary <- c(primary, "nonfinite_fit_output")
  }
  terminal <- mfrmr_cq_ameh_terminal(primary)
  list(
    elapsed_seconds = proc.time()[["elapsed"]] - start,
    terminal_code = terminal,
    secondary_code = if (length(secondary) == 0L) {
      NA_character_
    } else {
      paste(unique(secondary), collapse = ";")
    },
    parseable = parseable,
    observed_dimension = observed_dimension,
    model_identity_match = identity,
    inference_ready = NA,
    exit_status = execution$exit_status,
    terminal_marker = terminal_marker,
    registered_failure_count = length(unique(secondary))
  )
}

mfrmr_cq_ameh_retained_bytes <- function(root) {
  path <- list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = TRUE, include.dirs = FALSE
  )
  if (length(path) == 0L) return(0)
  sum(file.info(path)$size, na.rm = TRUE)
}

mfrmr_cq_ameh_update_artifact_inventory <- function(
    root, plan, outcome, registry) {
  inventory <- mfrmr_cq_ameh_artifact_inventory_template(plan, registry)
  input_path <- c(
    plan$LongFile, plan$PersonDataFile, plan$WideFile, plan$CommandFile
  )
  input_path <- input_path[!is.na(input_path)]
  all_file <- list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE
  )
  for (index in seq_len(nrow(inventory))) {
    order <- inventory$AttemptOrder[index]
    registered <- registry[
      !is.na(registry$AttemptOrder) & registry$AttemptOrder == order, ,
      drop = FALSE
    ]
    present <- file.exists(file.path(root, registered$RelativePath))
    inventory$PresentArtifactKinds[index] <- paste(
      registered$ArtifactKind[present], collapse = ";"
    )
    arm <- plan[plan$AttemptOrder == order & !is.na(plan$AttemptOrder), ,
                drop = FALSE]
    run_files <- all_file[dirname(all_file) == arm$RunDirectory]
    unexpected <- setdiff(
      run_files, c(registered$RelativePath, input_path)
    )
    inventory$UnexpectedArtifactKinds[index] <- paste(
      basename(unexpected), collapse = ";"
    )
    terminal <- outcome$TerminalCode[outcome$AttemptOrder == order &
                                      !is.na(outcome$AttemptOrder)]
    attempted <- outcome$Attempted[outcome$AttemptOrder == order &
                                    !is.na(outcome$AttemptOrder)]
    if (!isTRUE(attempted)) {
      inventory$ArtifactSetComplete[index] <-
        !any(present) && length(unexpected) == 0L
      next
    }
    if (arm$Engine == "mfrmr") {
      failure_present <- any(
        registered$ArtifactKind[present] == "failure_record"
      )
      required_kind <- if (terminal == "complete_numeric_eligible" ||
                           (!failure_present && terminal %in% c(
        "optimizer_nonconvergence_or_readiness_hold",
        "nonfinite_fit_output", "model_identity_mismatch"
      ))) {
        c("fit_rds", "summary", "population", "facets", "steps", "warnings")
      } else {
        "failure_record"
      }
    } else {
      required_kind <- if (terminal == "complete_numeric_eligible") {
        c(mfrmr_cq_ameh_conquest_suffix_registry()$ArtifactKind, "console")
      } else {
        "console"
      }
    }
    inventory$ArtifactSetComplete[index] <-
      all(required_kind %in% registered$ArtifactKind[present]) &&
      length(unexpected) == 0L
  }
  inventory
}

mfrmr_cq_ameh_mark_unattempted <- function(
    journal, outcome, terminal_code, secondary_code) {
  pending <- !journal$Started
  journal$Completed[pending] <- TRUE
  journal$TerminalCode[pending] <- terminal_code
  journal$SecondaryCode[pending] <- secondary_code
  journal$ParseableResult[pending] <- FALSE
  journal$ModelIdentityMatch[pending] <- FALSE
  outcome_index <- match(
    journal$ScheduledOutcomeOrder[pending], outcome$ScheduledOutcomeOrder
  )
  outcome$Attempted[outcome_index] <- FALSE
  outcome$TerminalCode[outcome_index] <- terminal_code
  outcome$SecondaryCode[outcome_index] <- secondary_code
  outcome$ParseableResult[outcome_index] <- FALSE
  outcome$ModelIdentityMatch[outcome_index] <- FALSE
  list(journal = journal, outcome = outcome)
}

mfrmr_cq_ameh_accounting_complete <- function(journal, outcome, plan) {
  attempt_plan <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  negative <- plan$AttemptCap == 0L
  outcome_index <- match(
    journal$ScheduledOutcomeOrder, outcome$ScheduledOutcomeOrder
  )
  journal_bound <- nrow(journal) == 30L &&
    identical(as.integer(journal$AttemptOrder), 1:30) &&
    identical(
      as.integer(journal$ScheduledOutcomeOrder),
      as.integer(attempt_plan$ScheduledOutcomeOrder)
    ) &&
    identical(as.character(journal$DatasetId), attempt_plan$DatasetId) &&
    identical(as.character(journal$Engine), attempt_plan$Engine) &&
    identical(
      as.character(journal$RepresentationId),
      attempt_plan$RepresentationId
    )
  outcome_bound <- nrow(outcome) == 38L &&
    identical(as.integer(outcome$ScheduledOutcomeOrder), 1:38) &&
    identical(as.character(outcome$DatasetId), plan$DatasetId) &&
    identical(as.character(outcome$Engine), plan$Engine) &&
    identical(as.character(outcome$RepresentationId), plan$RepresentationId)
  aligned <- journal_bound && outcome_bound && !anyNA(outcome_index) &&
    identical(
      as.logical(outcome$Attempted[outcome_index]),
      as.logical(journal$Started)
    ) &&
    identical(
      as.character(outcome$TerminalCode[outcome_index]),
      as.character(journal$TerminalCode)
    ) &&
    identical(
      as.logical(outcome$ParseableResult[outcome_index]),
      as.logical(journal$ParseableResult)
    ) &&
    identical(
      as.logical(outcome$ModelIdentityMatch[outcome_index]),
      as.logical(journal$ModelIdentityMatch)
    )
  terminal <- mfrmr_cq_acf_failure_taxonomy()$TerminalCode
  isTRUE(aligned && all(journal$Completed) &&
    all(journal$AttemptCount == as.integer(journal$Started)) &&
    all(journal$TerminalCode %in% terminal) &&
    all(outcome$TerminalCode %in% terminal) &&
    all(outcome$RowRetained) && !any(outcome$Attempted[negative]) &&
    all(outcome$TerminalCode[negative] == "expected_structural_rejection") &&
    !any(journal$AutomaticRetryPermitted) &&
    !any(journal$NumericAgreementInspected) &&
    !any(outcome$NumericAgreementInspected) &&
    !any(outcome$CalibrationUsePermitted))
}

mfrmr_cq_ameh_mechanics_audit <- function(
    journal,
    outcome,
    bridge,
    fresh_runtime_sentinel_passed,
    global_abort_triggered) {
  parseable <- journal$ParseableResult
  cell <- unique(paste(
    journal$Engine[parseable], journal$Family[parseable], sep = "\r"
  ))
  explicit <- journal$Engine == "mfrmr" &
    journal$RepresentationId == "explicit_missing"
  explicit_cell <- unique(journal$Family[explicit & parseable])
  paired_id <- unique(bridge$DatasetId)
  paired_bridge <- vapply(paired_id, function(dataset_id) {
    all(bridge$Passed[bridge$DatasetId == dataset_id])
  }, logical(1L))
  negative <- outcome$TerminalCode == "expected_structural_rejection"
  non_global_unattempted <- !journal$Started &
    journal$TerminalCode != "global_resource_abort_unattempted"
  list(
    RetainedDatasets = length(unique(outcome$DatasetId)),
    RetainedOutcomeRows = nrow(outcome),
    ExpectedNegativeRejections = length(unique(outcome$DatasetId[negative])),
    NegativeControlFitAttempts = sum(outcome$Attempted[negative]),
    EligiblePlannedAttempts = nrow(journal),
    RetainedAttemptOutcomeRows = sum(journal$Completed),
    PeerEligibleAttemptsSuppressed = sum(
      non_global_unattempted &
        grepl("peer", journal$SecondaryCode, fixed = TRUE)
    ),
    EngineFamilyCellsWithParseableQ61 = length(cell),
    PairedRepresentationOutcomeRows = sum(
      outcome$DatasetId %in% paired_id
    ),
    ExplicitMissingMfrmrAttemptOutcomes = sum(explicit & journal$Completed),
    ExplicitMissingMfrmrParseableCells = length(explicit_cell),
    ConQuestRepresentationBridgeChecks = sum(paired_bridge),
    FreshRuntimeSentinelPassed = isTRUE(fresh_runtime_sentinel_passed),
    ModelIdentityMismatches = sum(
      journal$TerminalCode == "model_identity_mismatch"
    ),
    GlobalAbortTriggered = isTRUE(global_abort_triggered),
    RowsDropped = 38L - nrow(outcome),
    MaximumCrossEngineDifference = NA_real_
  )
}

mfrmr_cq_ameh_finalize <- function(
    root,
    plan,
    journal,
    outcome,
    bridge,
    authority,
    resource,
    registry) {
  audit <- mfrmr_cq_ameh_mechanics_audit(
    journal = journal,
    outcome = outcome,
    bridge = bridge,
    fresh_runtime_sentinel_passed = authority$LiveExecutionAuthorized,
    global_abort_triggered = resource$GlobalAbortTriggered
  )
  decision <- mfrmr_cq_acf_engine_mechanics_decision(audit)
  inventory <- mfrmr_cq_ameh_update_artifact_inventory(
    root, plan, outcome, registry
  )
  boundary <- mfrmr_cq_ameh_output_boundary(root, plan, registry)
  sentinel_consistent <- identical(
    file.exists(file.path(root, "runtime_sentinel_console.log")),
    isTRUE(authority$LiveSentinelObserved)
  )
  artifact_accounting_complete <- all(inventory$ArtifactSetComplete) &&
    isTRUE(boundary$passed) && sentinel_consistent
  mechanics_gate_met <- decision$mechanics_gate_met &&
    artifact_accounting_complete
  summary <- data.frame(
    Status = if (mechanics_gate_met) {
      "ASP_G4X_engine_mechanics_complete_calibration_review_required"
    } else {
      "ASP_G4X_engine_mechanics_hold_all_outcomes_retained"
    },
    RetainedDatasets = audit$RetainedDatasets,
    RetainedOutcomeRows = audit$RetainedOutcomeRows,
    RetainedAttemptOutcomeRows = audit$RetainedAttemptOutcomeRows,
    ExpectedNegativeRejections = audit$ExpectedNegativeRejections,
    NegativeControlFitAttempts = audit$NegativeControlFitAttempts,
    FitAttemptCount = sum(journal$AttemptCount),
    ParseableEngineFamilyCells = audit$EngineFamilyCellsWithParseableQ61,
    ExplicitMissingParseableCells = audit$ExplicitMissingMfrmrParseableCells,
    ConQuestRepresentationBridgeChecks =
      audit$ConQuestRepresentationBridgeChecks,
    FreshRuntimeSentinelPassed = audit$FreshRuntimeSentinelPassed,
    ModelIdentityMismatches = audit$ModelIdentityMismatches,
    GlobalAbortTriggered = audit$GlobalAbortTriggered,
    RowsDropped = audit$RowsDropped,
    MechanicsGateMet = mechanics_gate_met,
    CalibrationAuthorized = FALSE,
    NumericAgreementInspected = FALSE,
    AnyFitAttempted = sum(journal$AttemptCount) > 0L,
    ConQuestExecutionAttempted = any(
      journal$Engine == "ConQuest" & journal$AttemptCount == 1L
    ),
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_ameh_write_csv(
    authority, file.path(root, "authority_snapshot.csv")
  )
  mfrmr_cq_ameh_write_csv(journal, file.path(root, "attempt_journal.csv"))
  mfrmr_cq_ameh_write_csv(outcome, file.path(root, "engine_outcome.csv"))
  mfrmr_cq_ameh_write_csv(
    inventory, file.path(root, "attempt_artifact_inventory.csv")
  )
  mfrmr_cq_ameh_write_csv(
    resource, file.path(root, "resource_summary.csv")
  )
  mfrmr_cq_ameh_write_csv(
    summary, file.path(root, "execution_summary.csv")
  )
  mfrmr_cq_ameh_review_execution(root)
}

mfrmr_cq_ameh_execute <- function(
    output_dir,
    run_date = Sys.Date(),
    authorize = FALSE,
    executable_path = "/Applications/ConQuest/ConQuest",
    per_fit_timeout_seconds = 600L,
    sentinel_timeout_seconds = 30L) {
  mfrmr_cq_ameh_assert(
    identical(authorize, TRUE),
    "Execution is held; authorize only the frozen 30-attempt G4H slice."
  )
  mfrmr_cq_ameh_assert(
    identical(as.integer(per_fit_timeout_seconds), 600L) &&
      identical(as.integer(sentinel_timeout_seconds), 30L),
    "G4H requires the frozen 600-second fit and 30-second sentinel timeouts."
  )
  prepared <- mfrmr_cq_ameh_validate_prepared(output_dir)
  mfrmr_cq_ameh_assert(
    isTRUE(prepared$execution_ready),
    "The run-once G4H bundle is invalid, incomplete, or already opened."
  )
  root <- prepared$output_dir
  authority <- prepared$authority
  run_date <- as.Date(run_date)[1L]
  exact_path <- normalizePath(
    executable_path, winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_ameh_assert(
    !is.na(run_date) &&
      run_date >= as.Date(authority$AuthorizationDate) &&
      run_date <= as.Date(authority$RunNotAfter) &&
      identical(exact_path, as.character(authority$ExecutablePath)) &&
      file.exists(exact_path) && file.access(exact_path, mode = 1L) == 0L,
    "The dated authorization or exact executable-path gate is not satisfied."
  )
  plan <- prepared$plan
  journal <- prepared$journal
  outcome <- prepared$outcome
  bridge <- prepared$representation_bridge
  registry <- prepared$expected_artifacts
  resource <- utils::read.csv(
    file.path(root, "resource_summary.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  phase_start <- proc.time()[["elapsed"]]
  sentinel <- mfrmr_cq_ameh_fresh_sentinel(
    root = root,
    executable_path = exact_path,
    run_date = run_date,
    timeout = sentinel_timeout_seconds
  )
  authority$LiveSentinelObserved <- TRUE
  authority$LiveExecutionAuthorized <- isTRUE(sentinel$exact_runtime_ready)
  if (!isTRUE(sentinel$exact_runtime_ready)) {
    secondary <- as.character(sentinel$summary$FailureCodes)
    if (is.na(secondary) || !nzchar(secondary)) {
      secondary <- "fresh_runtime_sentinel_failed"
    }
    terminal <- if (identical(
      sentinel$summary$Status, "runtime_unavailable_or_expired"
    )) {
      "runtime_unavailable_or_expired"
    } else {
      "registered_semantic_execution_failure"
    }
    retained <- mfrmr_cq_ameh_mark_unattempted(
      journal, outcome, terminal, secondary
    )
    journal <- retained$journal
    outcome <- retained$outcome
    resource$ElapsedSeconds <- proc.time()[["elapsed"]] - phase_start
    resource$RetainedBytes <- mfrmr_cq_ameh_retained_bytes(root)
    return(mfrmr_cq_ameh_finalize(
      root, plan, journal, outcome, bridge, authority, resource, registry
    ))
  }
  journal_path <- file.path(root, "attempt_journal.csv")
  outcome_path <- file.path(root, "engine_outcome.csv")
  resource_path <- file.path(root, "resource_summary.csv")
  for (order in seq_len(nrow(journal))) {
    elapsed <- proc.time()[["elapsed"]] - phase_start
    retained_bytes <- mfrmr_cq_ameh_retained_bytes(root)
    if (elapsed >= resource$WallTimeCapSeconds ||
        retained_bytes >= resource$StorageCapBytes) {
      resource$GlobalAbortTriggered <- TRUE
      retained <- mfrmr_cq_ameh_mark_unattempted(
        journal, outcome, "global_resource_abort_unattempted",
        "frozen_wall_time_or_storage_cap_reached"
      )
      journal <- retained$journal
      outcome <- retained$outcome
      break
    }
    arm <- plan[
      !is.na(plan$AttemptOrder) & plan$AttemptOrder == order, , drop = FALSE
    ]
    row <- match(order, journal$AttemptOrder)
    journal$AttemptCount[row] <- 1L
    journal$Started[row] <- TRUE
    mfrmr_cq_ameh_write_csv(journal, journal_path)
    result <- if (arm$Engine == "mfrmr") {
      mfrmr_cq_ameh_mfrmr_fit(root, arm, per_fit_timeout_seconds)
    } else {
      mfrmr_cq_ameh_conquest_fit(
        root, arm, exact_path, per_fit_timeout_seconds
      )
    }
    journal$Completed[row] <- TRUE
    journal$ElapsedSeconds[row] <- result$elapsed_seconds
    journal$ExitStatus[row] <- result$exit_status
    journal$TerminalMarkerObserved[row] <- result$terminal_marker
    journal$RegisteredFailureCount[row] <- result$registered_failure_count
    journal$TerminalCode[row] <- result$terminal_code
    journal$SecondaryCode[row] <- result$secondary_code
    journal$ParseableResult[row] <- result$parseable
    journal$ObservedFreeDimension[row] <- result$observed_dimension
    journal$ModelIdentityMatch[row] <- result$model_identity_match
    journal$InferenceReady[row] <- result$inference_ready
    outcome_row <- match(
      journal$ScheduledOutcomeOrder[row], outcome$ScheduledOutcomeOrder
    )
    outcome$Attempted[outcome_row] <- TRUE
    outcome$TerminalCode[outcome_row] <- result$terminal_code
    outcome$SecondaryCode[outcome_row] <- result$secondary_code
    outcome$ParseableResult[outcome_row] <- result$parseable
    outcome$ModelIdentityMatch[outcome_row] <- result$model_identity_match
    outcome$ElapsedSeconds[outcome_row] <- result$elapsed_seconds
    resource$FitAttempts <- sum(journal$AttemptCount)
    resource$ElapsedSeconds <- proc.time()[["elapsed"]] - phase_start
    resource$RetainedBytes <- mfrmr_cq_ameh_retained_bytes(root)
    mfrmr_cq_ameh_write_csv(journal, journal_path)
    mfrmr_cq_ameh_write_csv(outcome, outcome_path)
    mfrmr_cq_ameh_write_csv(resource, resource_path)
  }
  resource$ElapsedSeconds <- proc.time()[["elapsed"]] - phase_start
  resource$RetainedBytes <- mfrmr_cq_ameh_retained_bytes(root)
  mfrmr_cq_ameh_finalize(
    root, plan, journal, outcome, bridge, authority, resource, registry
  )
}

mfrmr_cq_ameh_review_execution <- function(output_dir) {
  mfrmr_cq_ameh_require_contracts()
  root <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_ameh_plan()
  journal <- utils::read.csv(
    file.path(root, "attempt_journal.csv"), stringsAsFactors = FALSE,
    check.names = FALSE, na.strings = ""
  )
  outcome <- utils::read.csv(
    file.path(root, "engine_outcome.csv"), stringsAsFactors = FALSE,
    check.names = FALSE, na.strings = ""
  )
  bridge <- utils::read.csv(
    file.path(root, "representation_bridge_audit.csv"),
    stringsAsFactors = FALSE, check.names = FALSE, na.strings = ""
  )
  authority <- utils::read.csv(
    file.path(root, "authority_snapshot.csv"), stringsAsFactors = FALSE,
    check.names = FALSE, na.strings = ""
  )
  resource <- utils::read.csv(
    file.path(root, "resource_summary.csv"), stringsAsFactors = FALSE,
    check.names = FALSE, na.strings = ""
  )
  inventory <- utils::read.csv(
    file.path(root, "attempt_artifact_inventory.csv"),
    stringsAsFactors = FALSE, check.names = FALSE, na.strings = ""
  )
  registry <- utils::read.csv(
    file.path(root, "expected_artifact_registry.csv"),
    stringsAsFactors = FALSE, check.names = FALSE, na.strings = ""
  )
  accounting_complete <- mfrmr_cq_ameh_accounting_complete(
    journal, outcome, plan
  )
  audit <- mfrmr_cq_ameh_mechanics_audit(
    journal = journal,
    outcome = outcome,
    bridge = bridge,
    fresh_runtime_sentinel_passed = authority$LiveExecutionAuthorized,
    global_abort_triggered = resource$GlobalAbortTriggered
  )
  decision <- mfrmr_cq_acf_engine_mechanics_decision(audit)
  expected_registry <- mfrmr_cq_ameh_expected_artifact_registry(plan)
  registry_complete <- mfrmr_cq_ameh_same_frame(
    registry, expected_registry
  )
  reconstructed_inventory <- mfrmr_cq_ameh_update_artifact_inventory(
    root, plan, outcome, expected_registry
  )
  inventory_reconstructed <- mfrmr_cq_ameh_same_frame(
    inventory, reconstructed_inventory
  )
  boundary <- mfrmr_cq_ameh_output_boundary(root, plan, expected_registry)
  sentinel_consistent <- identical(
    file.exists(file.path(root, "runtime_sentinel_console.log")),
    isTRUE(authority$LiveSentinelObserved)
  )
  artifact_accounting_complete <- registry_complete &&
    inventory_reconstructed &&
    all(reconstructed_inventory$ArtifactSetComplete) &&
    isTRUE(boundary$passed) && sentinel_consistent
  result_ready <- accounting_complete && artifact_accounting_complete
  list(
    specification = mfrmr_cq_ameh_specification,
    contract_version = mfrmr_cq_ameh_contract,
    status = if (result_ready && decision$mechanics_gate_met) {
      "ASP_G4X_engine_mechanics_complete_calibration_review_required"
    } else {
      "ASP_G4X_engine_mechanics_hold_all_outcomes_retained"
    },
    output_dir = root,
    plan = plan,
    journal = journal,
    outcome = outcome,
    representation_bridge = bridge,
    authority = authority,
    resource = resource,
    artifact_inventory = reconstructed_inventory,
    mechanics_audit = audit,
    mechanics_decision = decision,
    accounting_complete = accounting_complete,
    artifact_registry_complete = registry_complete,
    artifact_inventory_reconstructed = inventory_reconstructed,
    artifact_accounting_complete = artifact_accounting_complete,
    no_unexpected_artifact = isTRUE(boundary$passed),
    unexpected_artifacts = boundary$unexpected_files,
    mechanics_gate_met = result_ready && decision$mechanics_gate_met,
    run_once_consumed = any(journal$Started) ||
      isTRUE(authority$LiveSentinelObserved),
    rerun_authorized = FALSE,
    numeric_agreement_inspected = FALSE,
    calibration_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
