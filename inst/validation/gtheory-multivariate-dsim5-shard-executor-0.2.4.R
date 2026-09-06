# Internal admission-bound D-SIM-5 shard executor.
#
# Qualification and job construction are deterministic and open no planned
# RNG stream.  Execution is explicit, keeps one immutable checkpoint per outer
# attempt, and never uses result values to alter the admitted denominator.

mfrmr_gtds5e_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds3_manifest", "mfrmr_gtds3c_compile_profile",
    "mfrmr_gtds3g_contract", "mfrmr_gtds3g_generate_profile",
    "mfrmr_gtds3g_assert_generation", "mfrmr_gtds3r_contract",
    "mfrmr_gtds3r_route_data", "mfrmr_gtds3o_project_profile",
    "mfrmr_gtds3w_contract", "mfrmr_gtds3w_formula",
    "mfrmr_gtds3w_prepare_data", "mfrmr_gtds3w_capture_lmer",
    "mfrmr_gtds4w_contract", "mfrmr_gtds4w_capture_refit",
    "mfrmr_gtds4w_coefficient", "mfrmr_gtds4w_interval_bounds",
    "mfrmr_gtds5i_assert_launch_input", "mfrmr_gtds5a_assert_manifest"
  )
  target <- environment(mfrmr_gtds5e_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop("Source the D-SIM-3/4 substrate and D-SIM-5 admission first: ",
         paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  for (package in c("digest", "lme4")) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop("The D-SIM-5 executor requires `", package, "`.",
           call. = FALSE)
    }
  }
  invisible(TRUE)
}

mfrmr_gtds5e_hash <- function(value) {
  digest::digest(
    value, algo = "sha256", serialize = TRUE, serializeVersion = 3L
  )
}

mfrmr_gtds5e_canonical_code <- function(value) {
  paste(deparse(value, width.cutoff = 500L, control = "all"),
        collapse = "\n")
}

mfrmr_gtds5e_contract <- function() {
  mfrmr_gtds5e_require_primitives()
  worker <- mfrmr_gtds4w_contract()
  payload <- list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM5-SHARD-EXECUTOR-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-09-01",
    ParentLaunchInputHash =
      "e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071",
    ParentAdmissionContractHash =
      "f0744d6622755bd78489b81665f50d7bf3471548b426e31c22b9a32a67a838a6",
    ParentAdmissionManifestHash =
      "8f13db52ad19cbe5adcda0aabb6be6ec8ff949cb555d6043ea1dba0e74972510",
    ParentWorkerContractHash = worker$ContractHash,
    ParentWorkerManifestHash =
      "459abaa38eedfb5ecc8a918d3d1b99cd765867297ab392dd5c896ec276a06f1a",
    RouteId = "separate_univariate",
    ExpectedShardCount = 50L,
    ExpectedOuterAttemptsPerShard = 300L,
    ExpectedIntervalAttemptsPerShard = 100L,
    ExpectedInnerAttemptsPerInterval = 199L,
    ExpectedInnerAttemptsPerShard = 19900L,
    DataSeedMinimum = 857010001L,
    DataSeedMaximum = 857062500L,
    BootstrapSeedMinimum = 858010001L,
    BootstrapSeedMaximum = 858062500L,
    QualificationScenarioId = "D3-S001",
    QualificationDataSeed = 854100001L,
    QualificationBootstrapSeed = 854900001L,
    DataRngKind = c("L'Ecuyer-CMRG", "Inversion", "Rejection"),
    BootstrapRngKind = worker$RngKind,
    CheckpointAtomicUnit = "one_outer_attempt",
    InterruptedUncommittedAttemptRule =
      "rerun_exact_attempt_identity_with_same_seed",
    FailedAttemptRule = "terminal_retain_no_replacement_or_replenishment",
    ResumeDecisionInputs = c(
      "AttemptId", "OuterRequestHash", "InnerBlockHash", "ResultHash"
    ),
    ResultValueAdaptiveBranchAllowed = FALSE,
    PartialShardAuthorizationAllowed = FALSE,
    ScientificAdjudicationBeforeCompleteDenominatorAllowed = FALSE,
    ResourcePauseAndExactResumeAllowed = TRUE,
    Dsim5ExecutionAuthorized = TRUE,
    QualificationMayOpenPlannedSeed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  )
  structure(c(payload, list(
    ContractHash = mfrmr_gtds5e_hash(payload)
  )), class = c("mfrmr_gtds5e_contract", "list"))
}

mfrmr_gtds5e_validate_parents <- function(
    input, admission, contract = mfrmr_gtds5e_contract()) {
  mfrmr_gtds5i_assert_launch_input(input)
  mfrmr_gtds5a_assert_manifest(admission, input)
  valid <- identical(input$LaunchInputHash,
                     contract$ParentLaunchInputHash) &&
    identical(admission$Contract$ContractHash,
              contract$ParentAdmissionContractHash) &&
    identical(admission$ManifestHash,
              contract$ParentAdmissionManifestHash) &&
    identical(input$ParentWorkerManifest$Contract$ContractHash,
              contract$ParentWorkerContractHash) &&
    identical(input$ParentWorkerManifest$ManifestHash,
              contract$ParentWorkerManifestHash) &&
    identical(nrow(input$ShardRegistry), contract$ExpectedShardCount) &&
    all(admission$AuthorizedShardRegistry$ExecutionAuthorized) &&
    isTRUE(admission$Summary$FullDenominatorExecutionAdmitted) &&
    isTRUE(admission$Summary$Dsim5ExecutionAuthorized) &&
    !isTRUE(admission$Summary$InterimScientificAdjudicationAllowed)
  if (!valid) {
    stop("The exact admitted D-SIM-5 denominator is required.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds5e_job <- function(
    shard_id, input, admission, contract = mfrmr_gtds5e_contract(),
    validate = TRUE) {
  if (isTRUE(validate)) {
    mfrmr_gtds5e_validate_parents(input, admission, contract)
  }
  shard <- input$ShardRegistry[
    input$ShardRegistry$ShardId == shard_id, , drop = FALSE
  ]
  authorization <- admission$AuthorizedShardRegistry[
    admission$AuthorizedShardRegistry$ShardId == shard_id, , drop = FALSE
  ]
  assignments <- input$AssignmentRegistry[
    input$AssignmentRegistry$ShardId == shard_id, , drop = FALSE
  ]
  worker_requests <- input$ParentWorkerManifest$OuterRequestRegistry
  worker_index <- match(assignments$AttemptId, worker_requests$AttemptId)
  if (nrow(shard) != 1L || nrow(authorization) != 1L ||
      nrow(assignments) != contract$ExpectedOuterAttemptsPerShard ||
      !isTRUE(authorization$ExecutionAuthorized[[1L]]) ||
      !identical(shard$ShardHash[[1L]], authorization$ShardHash[[1L]])) {
    stop("One exact authorized D-SIM-5 shard is required.", call. = FALSE)
  }
  if (anyNA(worker_index)) {
    stop("The D-SIM-5 shard lost its worker request identity.",
         call. = FALSE)
  }
  assignments$ConfirmationScenarioOrdinal <-
    worker_requests$ConfirmationScenarioOrdinal[worker_index]
  assignments$ParentScenarioId <-
    worker_requests$ParentScenarioId[worker_index]
  assignments$ModelSpecificationId <-
    worker_requests$ModelSpecificationId[worker_index]
  assignments$ExecutionAuthorized <- TRUE
  assignments$RngStreamOpened <- FALSE
  assignments$AssignmentExecutionHash <- vapply(
    seq_len(nrow(assignments)), function(index) {
      row <- assignments[index, , drop = FALSE]
      mfrmr_gtds5e_hash(list(
        AdmissionManifestHash = admission$ManifestHash,
        ShardHash = shard$ShardHash[[1L]],
        AttemptId = row$AttemptId[[1L]],
        ParentScenarioId = row$ParentScenarioId[[1L]],
        ModelSpecificationId = row$ModelSpecificationId[[1L]],
        OuterRequestHash = row$OuterRequestHash[[1L]],
        InnerBlockHash = row$InnerBlockHash[[1L]]
      ))
    }, character(1L)
  )
  summary <- list(
    ShardId = shard_id,
    OuterRequestCount = nrow(assignments),
    IntervalOuterRequestCount = sum(assignments$IntervalEligible),
    InnerAttemptCount = sum(assignments$InnerBootstrapAttemptCount),
    ExpectedBackendFitCallCount = sum(
      assignments$ExpectedPrimaryFitCallCount +
        assignments$ExpectedInnerRefitCallCount
    ),
    ExecutionAuthorized = TRUE,
    ExecutionStarted = FALSE,
    Planned857RngStreamOpened = FALSE,
    Planned858RngStreamOpened = FALSE,
    ResultViewed = FALSE,
    ScientificAdjudicationComputed = FALSE,
    PublicSupportReady = FALSE
  )
  payload <- list(
    Contract = contract,
    LaunchInputHash = input$LaunchInputHash,
    AdmissionManifestHash = admission$ManifestHash,
    Shard = shard,
    AssignmentRegistry = assignments,
    Summary = summary
  )
  job <- structure(c(payload, list(
    JobHash = mfrmr_gtds5e_hash(payload)
  )), class = c("mfrmr_gtds5e_job", "list"))
  if (isTRUE(validate)) mfrmr_gtds5e_assert_job(job, input, admission)
  job
}

mfrmr_gtds5e_assert_job <- function(job, input, admission) {
  fields <- c(
    "Contract", "LaunchInputHash", "AdmissionManifestHash", "Shard",
    "AssignmentRegistry", "Summary"
  )
  if (!inherits(job, "mfrmr_gtds5e_job") ||
      !identical(names(job), c(fields, "JobHash"))) {
    stop("A typed D-SIM-5 shard job is required.", call. = FALSE)
  }
  contract <- mfrmr_gtds5e_contract()
  mfrmr_gtds5e_validate_parents(input, admission, contract)
  shard_id <- job$Shard$ShardId[[1L]]
  expected_shard <- input$ShardRegistry[
    input$ShardRegistry$ShardId == shard_id, , drop = FALSE
  ]
  expected_assignments <- input$AssignmentRegistry[
    input$AssignmentRegistry$ShardId == shard_id, , drop = FALSE
  ]
  worker_requests <- input$ParentWorkerManifest$OuterRequestRegistry
  worker_index <- match(
    expected_assignments$AttemptId, worker_requests$AttemptId
  )
  expected_assignments$ConfirmationScenarioOrdinal <-
    worker_requests$ConfirmationScenarioOrdinal[worker_index]
  expected_assignments$ParentScenarioId <-
    worker_requests$ParentScenarioId[worker_index]
  expected_assignments$ModelSpecificationId <-
    worker_requests$ModelSpecificationId[worker_index]
  expected_assignments$ExecutionAuthorized <- TRUE
  expected_assignments$RngStreamOpened <- FALSE
  expected_assignments$AssignmentExecutionHash <- vapply(
    seq_len(nrow(expected_assignments)), function(index) {
      row <- expected_assignments[index, , drop = FALSE]
      mfrmr_gtds5e_hash(list(
        AdmissionManifestHash = admission$ManifestHash,
        ShardHash = expected_shard$ShardHash[[1L]],
        AttemptId = row$AttemptId[[1L]],
        ParentScenarioId = row$ParentScenarioId[[1L]],
        ModelSpecificationId = row$ModelSpecificationId[[1L]],
        OuterRequestHash = row$OuterRequestHash[[1L]],
        InnerBlockHash = row$InnerBlockHash[[1L]]
      ))
    }, character(1L)
  )
  expected_summary <- list(
    ShardId = shard_id,
    OuterRequestCount = nrow(expected_assignments),
    IntervalOuterRequestCount = sum(expected_assignments$IntervalEligible),
    InnerAttemptCount = sum(
      expected_assignments$InnerBootstrapAttemptCount
    ),
    ExpectedBackendFitCallCount = sum(
      expected_assignments$ExpectedPrimaryFitCallCount +
        expected_assignments$ExpectedInnerRefitCallCount
    ),
    ExecutionAuthorized = TRUE,
    ExecutionStarted = FALSE,
    Planned857RngStreamOpened = FALSE,
    Planned858RngStreamOpened = FALSE,
    ResultViewed = FALSE,
    ScientificAdjudicationComputed = FALSE,
    PublicSupportReady = FALSE
  )
  valid <- nrow(expected_shard) == 1L &&
    identical(job$Contract, contract) &&
    identical(job$LaunchInputHash, input$LaunchInputHash) &&
    identical(job$AdmissionManifestHash, admission$ManifestHash) &&
    identical(job$Shard, expected_shard) &&
    identical(job$AssignmentRegistry, expected_assignments) &&
    identical(job$Summary, expected_summary) &&
    identical(job$JobHash, mfrmr_gtds5e_hash(job[fields])) &&
    identical(nrow(job$AssignmentRegistry), 300L) &&
    identical(sum(job$AssignmentRegistry$IntervalEligible), 100L) &&
    identical(sum(job$AssignmentRegistry$InnerBootstrapAttemptCount),
              19900L) &&
    all(job$AssignmentRegistry$ExecutionAuthorized) &&
    !any(job$AssignmentRegistry$RngStreamOpened) &&
    isTRUE(job$Summary$ExecutionAuthorized) &&
    !isTRUE(job$Summary$ExecutionStarted) &&
    !isTRUE(job$Summary$ResultViewed)
  if (!valid) stop("The D-SIM-5 shard job was altered.", call. = FALSE)
  invisible(TRUE)
}

mfrmr_gtds5e_data_contract <- function(
    assignment, coverage = mfrmr_gtds3_manifest()) {
  scenario <- coverage$ScenarioRegistry[
    coverage$ScenarioRegistry$ScenarioId == assignment$ParentScenarioId,
    , drop = FALSE
  ]
  confirmation_id <- assignment$ConfirmationScenarioId[[1L]]
  confirmation_ordinal <- if (
    length(confirmation_id) == 1L &&
      grepl("^D4-S[0-9]{3}$", confirmation_id)
  ) as.integer(sub("D4-S", "", confirmation_id, fixed = TRUE)) else NA_integer_
  expected_seed <- 857000000L +
    confirmation_ordinal * 10000L + assignment$Replicate
  if (nrow(assignment) != 1L || nrow(scenario) != 1L ||
      is.na(confirmation_ordinal) ||
      !identical(assignment$DataSeed, as.integer(expected_seed))) {
    stop("The D-SIM-5 data-seed identity is invalid.", call. = FALSE)
  }
  parent <- mfrmr_gtds3g_contract()
  parent$ContractId <- "MFRMR-GTHEORY-MV-DSIM5-DATA-GENERATOR-V1"
  parent$ContractVersion <- "1.0.0"
  parent$ShadowSeedBandId <- "DSIM5-CONFIRMATION-DATA-857"
  parent$ShadowSeedBase <- as.integer(
    assignment$DataSeed - scenario$ScenarioOrdinal[[1L]]
  )
  parent$MinimumShadowSeed <- assignment$DataSeed
  parent$MaximumShadowSeed <- assignment$DataSeed
  parent$ReservedExploratoryLowerInclusive <- 858000000L
  parent$ReservedExploratoryUpperInclusive <- 858999999L
  parent$Planned855RngStreamAllowed <- TRUE
  parent$BackendCallAllowed <- TRUE
  parent$FitAllowed <- TRUE
  parent$ExploratoryExecutionAllowed <- TRUE
  parent$SimulationValidationClaimAllowed <- FALSE
  parent$PublicSupportPromotionAllowed <- FALSE
  parent$ContractHash <- mfrmr_gtds5e_hash(
    parent[names(parent) != "ContractHash"]
  )
  parent
}

mfrmr_gtds5e_rng_snapshot <- function() {
  present <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  list(
    Kind = RNGkind(), Present = present,
    Seed = if (present) get(".Random.seed", envir = .GlobalEnv) else NULL
  )
}

mfrmr_gtds5e_rng_restored <- function(snapshot) {
  present <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  identical(snapshot$Kind, RNGkind()) && identical(snapshot$Present, present) &&
    (!present || identical(
      snapshot$Seed, get(".Random.seed", envir = .GlobalEnv)
    ))
}

mfrmr_gtds5e_empty_primary_receipts <- function() {
  data.frame(
    Stratum = character(), ObservationCount = integer(),
    BackendCallMade = logical(), FitReturned = logical(),
    WarningCount = integer(), MessageCount = integer(),
    Singular = logical(), ConvergenceMessage = character(),
    ErrorText = character(), stringsAsFactors = FALSE
  )
}

mfrmr_gtds5e_empty_metrics <- function() {
  data.frame(
    BootstrapReplicate = integer(), Stratum = character(),
    EstimandId = character(), Value = numeric(), TargetFinite = logical(),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds5e_empty_inner_receipts <- function() {
  data.frame(
    BootstrapReplicate = integer(), InnerAttemptId = character(),
    PlannedStratumFitCount = integer(), RefitCallCount = integer(),
    SuccessfulStratumFitCount = integer(), FiniteStratumTargetCount = integer(),
    SingularFitCount = integer(), WarningCount = integer(),
    MessageCount = integer(), AllTargetsFinite = logical(),
    TerminalState = character(), ReplacementAllowed = logical(),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds5e_dependency_bootstrap <- function(
    assignment, strata, terminal_state,
    contract = mfrmr_gtds5e_contract()) {
  if (!isTRUE(assignment$IntervalEligible[[1L]])) {
    return(list(
      Metrics = mfrmr_gtds5e_empty_metrics(),
      Receipts = mfrmr_gtds5e_empty_inner_receipts(),
      Intervals = data.frame()
    ))
  }
  n <- contract$ExpectedInnerAttemptsPerInterval
  keys <- expand.grid(
    BootstrapReplicate = seq_len(n), Stratum = strata,
    EstimandId = c("ABS-PHI", "REL-G"), KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  keys <- keys[order(
    keys$BootstrapReplicate, match(keys$Stratum, strata),
    match(keys$EstimandId, c("ABS-PHI", "REL-G"))
  ), , drop = FALSE]
  keys$Value <- NA_real_
  keys$TargetFinite <- FALSE
  receipts <- data.frame(
    BootstrapReplicate = seq_len(n),
    InnerAttemptId = sprintf("%s/PB%03d", assignment$AttemptId, seq_len(n)),
    PlannedStratumFitCount = length(strata), RefitCallCount = 0L,
    SuccessfulStratumFitCount = 0L, FiniteStratumTargetCount = 0L,
    SingularFitCount = 0L, WarningCount = 0L, MessageCount = 0L,
    AllTargetsFinite = FALSE, TerminalState = terminal_state,
    ReplacementAllowed = FALSE, stringsAsFactors = FALSE
  )
  intervals <- mfrmr_gtds4w_interval_bounds(
    receipts, keys, mfrmr_gtds4w_contract()
  )
  row.names(keys) <- row.names(receipts) <- NULL
  list(Metrics = keys, Receipts = receipts, Intervals = intervals)
}

mfrmr_gtds5e_result <- function(
    assignment, job, terminal_state, generation_hash = NA_character_,
    generated_data_hash = NA_character_, primary_receipts = NULL,
    primary_coefficients = data.frame(), bootstrap = NULL,
    planned857_opened = TRUE, response_generated = FALSE,
    backend_call_made = FALSE, planned858_opened = FALSE,
    caller_rng_restored = TRUE, counts_as_dsim5_attempt = TRUE,
    bootstrap_rng_opened = planned858_opened, error_text = "") {
  if (is.null(primary_receipts)) {
    primary_receipts <- mfrmr_gtds5e_empty_primary_receipts()
  }
  if (is.null(bootstrap)) {
    bootstrap <- list(
      Metrics = mfrmr_gtds5e_empty_metrics(),
      Receipts = mfrmr_gtds5e_empty_inner_receipts(),
      Intervals = data.frame()
    )
  }
  payload <- list(
    ContractHash = job$Contract$ContractHash,
    JobHash = job$JobHash,
    LaunchInputHash = job$LaunchInputHash,
    AdmissionManifestHash = job$AdmissionManifestHash,
    ShardId = job$Shard$ShardId[[1L]],
    ShardHash = job$Shard$ShardHash[[1L]],
    AttemptId = assignment$AttemptId[[1L]],
    AttemptOrdinal = assignment$AttemptOrdinal[[1L]],
    ConfirmationScenarioId = assignment$ConfirmationScenarioId[[1L]],
    ParentScenarioId = assignment$ParentScenarioId[[1L]],
    Replicate = assignment$Replicate[[1L]],
    DataSeed = assignment$DataSeed[[1L]],
    BootstrapSeed = assignment$BootstrapSeed[[1L]],
    OuterRequestHash = assignment$OuterRequestHash[[1L]],
    InnerBlockHash = assignment$InnerBlockHash[[1L]],
    AssignmentExecutionHash = assignment$AssignmentExecutionHash[[1L]],
    GenerationHash = generation_hash,
    GeneratedDataHash = generated_data_hash,
    PrimaryFitReceiptRegistry = primary_receipts,
    PrimaryCoefficientRegistry = primary_coefficients,
    InnerReceiptRegistry = bootstrap$Receipts,
    BootstrapMetricRegistry = bootstrap$Metrics,
    IntervalRegistry = bootstrap$Intervals,
    TerminalState = terminal_state,
    TerminalStateCount = 1L,
    WorkerExecutionStarted = TRUE,
    Dsim5ExecutionStarted = isTRUE(counts_as_dsim5_attempt),
    CountsAsDsim5Attempt = isTRUE(counts_as_dsim5_attempt),
    Planned857RngStreamOpened = isTRUE(planned857_opened),
    ResponseGenerated = isTRUE(response_generated),
    BackendCallMade = isTRUE(backend_call_made),
    BootstrapRngStreamOpened = isTRUE(bootstrap_rng_opened),
    Planned858RngStreamOpened = isTRUE(planned858_opened),
    CallerRngStateRestored = isTRUE(caller_rng_restored),
    ReplacementOrReplenishmentApplied = FALSE,
    ResultValueUsedForExecutionDecision = FALSE,
    ScientificAdjudicationComputed = FALSE,
    PublicSupportReady = FALSE,
    ErrorText = as.character(error_text)
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gtds5e_hash(payload)
  )), class = c("mfrmr_gtds5e_result", "list"))
}

mfrmr_gtds5e_result_fields <- function() {
  c(
    "ContractHash", "JobHash", "LaunchInputHash",
    "AdmissionManifestHash", "ShardId", "ShardHash", "AttemptId",
    "AttemptOrdinal", "ConfirmationScenarioId", "ParentScenarioId",
    "Replicate", "DataSeed", "BootstrapSeed", "OuterRequestHash",
    "InnerBlockHash", "AssignmentExecutionHash", "GenerationHash",
    "GeneratedDataHash", "PrimaryFitReceiptRegistry",
    "PrimaryCoefficientRegistry", "InnerReceiptRegistry",
    "BootstrapMetricRegistry", "IntervalRegistry", "TerminalState",
    "TerminalStateCount", "WorkerExecutionStarted", "Dsim5ExecutionStarted",
    "CountsAsDsim5Attempt",
    "Planned857RngStreamOpened", "ResponseGenerated", "BackendCallMade",
    "BootstrapRngStreamOpened", "Planned858RngStreamOpened",
    "CallerRngStateRestored",
    "ReplacementOrReplenishmentApplied",
    "ResultValueUsedForExecutionDecision", "ScientificAdjudicationComputed",
    "PublicSupportReady", "ErrorText"
  )
}

mfrmr_gtds5e_assert_result <- function(result, job, qualification = FALSE) {
  fields <- mfrmr_gtds5e_result_fields()
  assignment <- job$AssignmentRegistry[
    job$AssignmentRegistry$AttemptId == result$AttemptId, , drop = FALSE
  ]
  expected_inner <- if (nrow(assignment) == 1L &&
                        isTRUE(assignment$IntervalEligible[[1L]])) {
    job$Contract$ExpectedInnerAttemptsPerInterval
  } else 0L
  valid <- inherits(result, "mfrmr_gtds5e_result") &&
    identical(names(result), c(fields, "ResultHash")) &&
    nrow(assignment) == 1L &&
    identical(result$ResultHash, mfrmr_gtds5e_hash(result[fields])) &&
    identical(result$ContractHash, job$Contract$ContractHash) &&
    identical(result$JobHash, job$JobHash) &&
    identical(result$ShardHash, job$Shard$ShardHash[[1L]]) &&
    identical(result$OuterRequestHash,
              assignment$OuterRequestHash[[1L]]) &&
    identical(result$InnerBlockHash, assignment$InnerBlockHash[[1L]]) &&
    identical(result$AssignmentExecutionHash,
              assignment$AssignmentExecutionHash[[1L]]) &&
    identical(nrow(result$InnerReceiptRegistry), expected_inner) &&
    (expected_inner == 0L || identical(
      result$InnerReceiptRegistry$BootstrapReplicate,
      seq_len(expected_inner)
    )) &&
    identical(result$TerminalStateCount, 1L) &&
    isTRUE(result$WorkerExecutionStarted) &&
    identical(result$Dsim5ExecutionStarted, !isTRUE(qualification)) &&
    identical(result$CountsAsDsim5Attempt, !isTRUE(qualification)) &&
    identical(result$Planned857RngStreamOpened,
              !isTRUE(qualification)) &&
    (!isTRUE(result$Planned858RngStreamOpened) ||
       isTRUE(result$BootstrapRngStreamOpened)) &&
    (!isTRUE(qualification) ||
       !isTRUE(result$Planned858RngStreamOpened)) &&
    isTRUE(result$CallerRngStateRestored) &&
    !isTRUE(result$ReplacementOrReplenishmentApplied) &&
    !isTRUE(result$ResultValueUsedForExecutionDecision) &&
    !isTRUE(result$ScientificAdjudicationComputed) &&
    !isTRUE(result$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-5 outer-attempt result was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds5e_execute_attempt <- function(
    assignment, job, coverage = mfrmr_gtds3_manifest(),
    generation_override = NULL, qualification = FALSE) {
  if (nrow(assignment) != 1L ||
      !assignment$AttemptId[[1L]] %in% job$AssignmentRegistry$AttemptId ||
      !isTRUE(assignment$ExecutionAuthorized[[1L]])) {
    stop("One authorized outer attempt is required.", call. = FALSE)
  }
  before_rng <- mfrmr_gtds5e_rng_snapshot()
  strata <- mfrmr_gtds3c_compile_profile(
    assignment$ParentScenarioId[[1L]], coverage = coverage,
    validate = FALSE
  )$StratumRegistry$Stratum
  dependency <- function(state) mfrmr_gtds5e_dependency_bootstrap(
    assignment, strata, state, job$Contract
  )
  if (isTRUE(qualification)) {
    data_contract <- mfrmr_gtds3g_contract()
    generation <- generation_override
    if (!inherits(generation, "mfrmr_gtds3g_generation") ||
        !identical(generation$ScenarioId,
                   job$Contract$QualificationScenarioId) ||
        !identical(generation$ShadowSeed,
                   job$Contract$QualificationDataSeed)) {
      stop("The nonreserved executor qualification generation is invalid.",
           call. = FALSE)
    }
  } else {
    if (!is.null(generation_override)) {
      stop("A generation override is qualification-only.", call. = FALSE)
    }
    data_contract <- mfrmr_gtds5e_data_contract(assignment, coverage)
    generation <- tryCatch(
      mfrmr_gtds3g_generate_profile(
        assignment$ParentScenarioId[[1L]], contract = data_contract,
        coverage = coverage, validate = FALSE
      ), error = function(condition) condition
    )
  }
  if (inherits(generation, "error")) {
    result <- mfrmr_gtds5e_result(
      assignment, job, "generation_failure",
      bootstrap = dependency("not_attempted_generation_dependency"),
      planned857_opened = TRUE,
      caller_rng_restored = mfrmr_gtds5e_rng_restored(before_rng),
      error_text = conditionMessage(generation)
    )
    mfrmr_gtds5e_assert_result(result, job)
    return(result)
  }
  mfrmr_gtds3g_assert_generation(
    generation, contract = data_contract, coverage = coverage,
    validate = FALSE, replay = FALSE
  )
  if (!isTRUE(qualification) &&
      !identical(generation$ShadowSeed, assignment$DataSeed[[1L]])) {
    stop("The D-SIM-5 generator opened the wrong data seed.", call. = FALSE)
  }
  planned_execution <- !isTRUE(qualification)
  route_data <- mfrmr_gtds3r_route_data(
    generation, mfrmr_gtds3r_contract()
  )
  partitions <- stats::setNames(lapply(strata, function(stratum) {
    mfrmr_gtds3w_prepare_data(
      route_data[route_data$Stratum == stratum, , drop = FALSE]
    )
  }), strata)
  profile <- unlist(generation$Profile, use.names = TRUE)
  expected_model <- mfrmr_gtds4w_model_specification(profile)
  if (!identical(expected_model,
                 assignment$ModelSpecificationId[[1L]])) {
    stop("The D-SIM-5 model specification changed.", call. = FALSE)
  }
  formula <- mfrmr_gtds3w_formula(
    expected_model, mfrmr_gtds3w_contract()
  )
  operator <- mfrmr_gtds3o_project_profile(
    assignment$ParentScenarioId[[1L]], coverage = coverage,
    validate = FALSE
  )
  fits <- stats::setNames(vector("list", length(strata)), strata)
  primary_receipts <- vector("list", length(strata))
  primary_coefficients <- list()
  primary_error <- character()
  for (index in seq_along(strata)) {
    stratum <- strata[[index]]
    captured <- mfrmr_gtds3w_capture_lmer(formula, partitions[[stratum]])
    success <- !inherits(captured$Fit, "error")
    coefficient <- if (success) tryCatch(
      mfrmr_gtds4w_coefficient(
        captured$Fit, assignment$ConfirmationScenarioId[[1L]],
        assignment$AttemptId[[1L]], stratum, profile,
        operator$Operators
      ), error = function(condition) condition
    ) else captured$Fit
    coefficient_ready <- !inherits(coefficient, "error") &&
      isTRUE(coefficient$CoefficientReady[[1L]]) &&
      coefficient$ReferenceMaximumError[[1L]] <= 1e-10
    error_text <- if (inherits(coefficient, "error")) {
      conditionMessage(coefficient)
    } else if (!coefficient_ready) "primary_target_nonfinite" else ""
    if (nzchar(error_text)) primary_error <- c(primary_error, error_text)
    fits[[stratum]] <- if (success) captured$Fit else NULL
    if (coefficient_ready) {
      coefficient$ConfirmationScenarioId <-
        assignment$ConfirmationScenarioId[[1L]]
      coefficient$AttemptId <- assignment$AttemptId[[1L]]
      coefficient$Replicate <- assignment$Replicate[[1L]]
      coefficient$OuterRequestHash <- assignment$OuterRequestHash[[1L]]
      primary_coefficients[[length(primary_coefficients) + 1L]] <- coefficient
    }
    convergence <- if (success) {
      paste(as.character(captured$Fit@optinfo$conv$lme4$messages),
            collapse = " | ")
    } else ""
    primary_receipts[[index]] <- data.frame(
      Stratum = stratum,
      ObservationCount = if (success) as.integer(stats::nobs(captured$Fit))
        else nrow(partitions[[stratum]]),
      BackendCallMade = TRUE, FitReturned = success,
      WarningCount = length(captured$Warnings),
      MessageCount = length(captured$Messages),
      Singular = if (success) lme4::isSingular(captured$Fit) else NA,
      ConvergenceMessage = convergence, ErrorText = error_text,
      stringsAsFactors = FALSE
    )
  }
  primary_receipts <- do.call(rbind, primary_receipts)
  primary_coefficients <- if (length(primary_coefficients)) {
    do.call(rbind, primary_coefficients)
  } else data.frame()
  primary_ready <- all(primary_receipts$FitReturned) &&
    nrow(primary_coefficients) == length(strata)
  if (!primary_ready) {
    result <- mfrmr_gtds5e_result(
      assignment, job, "primary_fit_or_target_failure",
      generation$GenerationHash, generation$Summary$GeneratedDataHash,
      primary_receipts, primary_coefficients,
      dependency("not_attempted_primary_dependency"),
      planned857_opened = planned_execution,
      response_generated = TRUE, backend_call_made = TRUE,
      planned858_opened = FALSE,
      caller_rng_restored = mfrmr_gtds5e_rng_restored(before_rng),
      counts_as_dsim5_attempt = planned_execution,
      bootstrap_rng_opened = FALSE,
      error_text = paste(unique(primary_error), collapse = " | ")
    )
    mfrmr_gtds5e_assert_result(result, job, qualification)
    return(result)
  }
  if (!isTRUE(assignment$IntervalEligible[[1L]])) {
    result <- mfrmr_gtds5e_result(
      assignment, job, "complete_point_only",
      generation$GenerationHash, generation$Summary$GeneratedDataHash,
      primary_receipts, primary_coefficients,
      planned857_opened = planned_execution, response_generated = TRUE,
      backend_call_made = TRUE, planned858_opened = FALSE,
      caller_rng_restored = mfrmr_gtds5e_rng_restored(before_rng),
      counts_as_dsim5_attempt = planned_execution,
      bootstrap_rng_opened = FALSE
    )
    mfrmr_gtds5e_assert_result(result, job, qualification)
    return(result)
  }
  n <- job$Contract$ExpectedInnerAttemptsPerInterval
  receipt_rows <- vector("list", n)
  metric_rows <- vector("list", n * length(strata) * 2L)
  metric_cursor <- 0L
  mfrmr_gtds4w_with_seed(
    assignment$BootstrapSeed[[1L]], mfrmr_gtds4w_contract(), {
      for (bootstrap_index in seq_len(n)) {
        fit_success <- target_finite <- logical(length(strata))
        refit_calls <- singular <- warning_count <- message_count <- 0L
        for (stratum_index in seq_along(strata)) {
          stratum <- strata[[stratum_index]]
          simulated <- tryCatch(
            as.numeric(stats::simulate(
              fits[[stratum]], nsim = 1L, re.form = NA
            )[[1L]]), error = function(condition) condition
          )
          if (inherits(simulated, "error")) {
            captured <- list(
              Fit = simulated, Warnings = character(), Messages = character()
            )
          } else {
            refit_calls <- refit_calls + 1L
            captured <- mfrmr_gtds4w_capture_refit(
              fits[[stratum]], simulated
            )
          }
          fit_success[[stratum_index]] <-
            !inherits(simulated, "error") &&
            !inherits(captured$Fit, "error") &&
            length(simulated) == nrow(partitions[[stratum]]) &&
            all(is.finite(simulated))
          warning_count <- warning_count + length(captured$Warnings)
          message_count <- message_count + length(captured$Messages)
          if (fit_success[[stratum_index]]) {
            singular <- singular + as.integer(lme4::isSingular(captured$Fit))
          }
          coefficient <- if (fit_success[[stratum_index]]) tryCatch(
            mfrmr_gtds4w_coefficient(
              captured$Fit, assignment$ConfirmationScenarioId[[1L]],
              assignment$AttemptId[[1L]], stratum, profile,
              operator$Operators
            ), error = function(condition) condition
          ) else captured$Fit
          coefficient_ready <- !inherits(coefficient, "error") &&
            isTRUE(coefficient$CoefficientReady[[1L]]) &&
            coefficient$ReferenceMaximumError[[1L]] <= 1e-10
          target_finite[[stratum_index]] <- coefficient_ready
          values <- if (coefficient_ready) c(
            `ABS-PHI` = coefficient$Phi[[1L]],
            `REL-G` = coefficient$G[[1L]]
          ) else c(`ABS-PHI` = NA_real_, `REL-G` = NA_real_)
          for (estimand in names(values)) {
            metric_cursor <- metric_cursor + 1L
            metric_rows[[metric_cursor]] <- data.frame(
              BootstrapReplicate = bootstrap_index, Stratum = stratum,
              EstimandId = estimand, Value = values[[estimand]],
              TargetFinite = is.finite(values[[estimand]]),
              stringsAsFactors = FALSE
            )
          }
        }
        all_finite <- all(fit_success) && all(target_finite)
        receipt_rows[[bootstrap_index]] <- data.frame(
          BootstrapReplicate = bootstrap_index,
          InnerAttemptId = sprintf(
            "%s/PB%03d", assignment$AttemptId[[1L]], bootstrap_index
          ),
          PlannedStratumFitCount = length(strata),
          RefitCallCount = refit_calls,
          SuccessfulStratumFitCount = sum(fit_success),
          FiniteStratumTargetCount = sum(target_finite),
          SingularFitCount = singular, WarningCount = warning_count,
          MessageCount = message_count, AllTargetsFinite = all_finite,
          TerminalState = if (all_finite) "success" else
            "refit_or_target_failure",
          ReplacementAllowed = FALSE, stringsAsFactors = FALSE
        )
      }
    }
  )
  metrics <- do.call(rbind, metric_rows)
  receipts <- do.call(rbind, receipt_rows)
  intervals <- mfrmr_gtds4w_interval_bounds(
    receipts, metrics, mfrmr_gtds4w_contract()
  )
  bootstrap <- list(
    Metrics = metrics, Receipts = receipts, Intervals = intervals
  )
  result <- mfrmr_gtds5e_result(
    assignment, job,
    if (all(intervals$IntervalAvailable)) "complete_with_interval" else
      "complete_interval_unavailable",
    generation$GenerationHash, generation$Summary$GeneratedDataHash,
    primary_receipts, primary_coefficients, bootstrap,
    planned857_opened = planned_execution, response_generated = TRUE,
    backend_call_made = TRUE, planned858_opened = planned_execution,
    caller_rng_restored = mfrmr_gtds5e_rng_restored(before_rng),
    counts_as_dsim5_attempt = planned_execution,
    bootstrap_rng_opened = TRUE
  )
  mfrmr_gtds5e_assert_result(result, job, qualification)
  result
}

mfrmr_gtds5e_shadow_job <- function(
    model_specification_id, contract = mfrmr_gtds5e_contract()) {
  assignment <- data.frame(
    AttemptOrdinal = 0L,
    AttemptId = "D5E-Q-S001",
    ConfirmationScenarioOrdinal = 0L,
    ConfirmationScenarioId = "D5E-Q-S001",
    ParentScenarioId = contract$QualificationScenarioId,
    ScenarioRole = "nonreserved_executor_qualification",
    Replicate = 0L,
    DataSeed = contract$QualificationDataSeed,
    BootstrapSeed = contract$QualificationBootstrapSeed,
    IntervalEligible = TRUE,
    InnerBootstrapAttemptCount = contract$ExpectedInnerAttemptsPerInterval,
    ModelSpecificationId = model_specification_id,
    ExecutionAuthorized = TRUE,
    stringsAsFactors = FALSE
  )
  assignment$OuterRequestHash <- mfrmr_gtds5e_hash(as.list(assignment))
  assignment$InnerBlockHash <- mfrmr_gtds5e_hash(list(
    AttemptId = assignment$AttemptId,
    BootstrapSeed = assignment$BootstrapSeed,
    BootstrapReplicate = seq_len(contract$ExpectedInnerAttemptsPerInterval)
  ))
  assignment$AssignmentExecutionHash <- mfrmr_gtds5e_hash(list(
    QualificationOnly = TRUE,
    OuterRequestHash = assignment$OuterRequestHash,
    InnerBlockHash = assignment$InnerBlockHash
  ))
  shard <- data.frame(
    ShardId = "D5E-QUALIFICATION", ShardHash = mfrmr_gtds5e_hash(
      assignment[c("AttemptId", "OuterRequestHash", "InnerBlockHash")]
    ), stringsAsFactors = FALSE
  )
  payload <- list(
    ContractHash = contract$ContractHash,
    ShardHash = shard$ShardHash[[1L]],
    AssignmentExecutionHash = assignment$AssignmentExecutionHash[[1L]]
  )
  list(
    Contract = contract,
    JobHash = mfrmr_gtds5e_hash(payload),
    LaunchInputHash = contract$ParentLaunchInputHash,
    AdmissionManifestHash = contract$ParentAdmissionManifestHash,
    Shard = shard,
    AssignmentRegistry = assignment
  )
}

mfrmr_gtds5e_shadow_qualification <- function(
    coverage = mfrmr_gtds3_manifest(),
    contract = mfrmr_gtds5e_contract()) {
  before_rng <- mfrmr_gtds5e_rng_snapshot()
  generation <- mfrmr_gtds3g_generate_profile(
    contract$QualificationScenarioId, coverage = coverage, validate = FALSE
  )
  mfrmr_gtds3g_assert_generation(
    generation, coverage = coverage, validate = FALSE, replay = FALSE
  )
  model_id <- mfrmr_gtds4w_model_specification(
    unlist(generation$Profile, use.names = TRUE)
  )
  job <- mfrmr_gtds5e_shadow_job(model_id, contract)
  result <- mfrmr_gtds5e_execute_attempt(
    job$AssignmentRegistry, job, coverage,
    generation_override = generation, qualification = TRUE
  )
  qualified <- identical(result$TerminalState, "complete_with_interval") &&
    nrow(result$PrimaryFitReceiptRegistry) == 2L &&
    all(result$PrimaryFitReceiptRegistry$FitReturned) &&
    nrow(result$InnerReceiptRegistry) == 199L &&
    all(result$InnerReceiptRegistry$TerminalState == "success") &&
    nrow(result$BootstrapMetricRegistry) == 796L &&
    all(result$BootstrapMetricRegistry$TargetFinite) &&
    all(result$IntervalRegistry$IntervalAvailable) &&
    isTRUE(result$BootstrapRngStreamOpened) &&
    !isTRUE(result$Planned857RngStreamOpened) &&
    !isTRUE(result$Planned858RngStreamOpened) &&
    !isTRUE(result$CountsAsDsim5Attempt) &&
    !isTRUE(result$Dsim5ExecutionStarted) &&
    mfrmr_gtds5e_rng_restored(before_rng)
  if (!qualified) {
    stop("The integrated nonreserved D-SIM-5 executor qualification failed.",
         call. = FALSE)
  }
  list(
    ScenarioId = generation$ScenarioId,
    DataSeed = generation$ShadowSeed,
    BootstrapSeed = contract$QualificationBootstrapSeed,
    GenerationHash = generation$GenerationHash,
    ModelSpecificationId = model_id,
    QualificationJobHash = job$JobHash,
    Result = result,
    IntegratedExecutorQualified = TRUE,
    CallerRngStateRestored = TRUE,
    CountsAsDsim5Attempt = FALSE,
    Planned857RngStreamOpened = FALSE,
    Planned858RngStreamOpened = FALSE
  )
}

mfrmr_gtds5e_atomic_save <- function(object, path) {
  directory <- dirname(path)
  if (!dir.exists(directory) && !dir.create(directory, recursive = TRUE)) {
    stop("The D-SIM-5 checkpoint directory could not be created.",
         call. = FALSE)
  }
  temporary <- tempfile(paste0(".", basename(path), "."), tmpdir = directory)
  on.exit(if (file.exists(temporary)) unlink(temporary), add = TRUE)
  saveRDS(object, temporary, version = 3L)
  if (!isTRUE(file.rename(temporary, path))) {
    stop("The D-SIM-5 atomic checkpoint could not commit.", call. = FALSE)
  }
  invisible(path)
}

mfrmr_gtds5e_result_path <- function(directory, attempt_id) {
  file.path(directory, paste0(attempt_id, ".rds"))
}

mfrmr_gtds5e_resume_plan <- function(job, checkpoint_dir) {
  paths <- if (dir.exists(checkpoint_dir)) list.files(
    checkpoint_dir, pattern = "\\.rds$", full.names = TRUE
  ) else character()
  rows <- lapply(paths, function(path) {
    result <- readRDS(path)
    mfrmr_gtds5e_assert_result(result, job)
    if (!identical(basename(path), paste0(result$AttemptId, ".rds"))) {
      stop("A D-SIM-5 checkpoint filename changed identity.", call. = FALSE)
    }
    data.frame(
      AttemptId = result$AttemptId,
      OuterRequestHash = result$OuterRequestHash,
      InnerBlockHash = result$InnerBlockHash,
      ResultHash = result$ResultHash,
      TerminalStateCount = result$TerminalStateCount,
      stringsAsFactors = FALSE
    )
  })
  completed <- if (length(rows)) do.call(rbind, rows) else data.frame(
    AttemptId = character(), OuterRequestHash = character(),
    InnerBlockHash = character(), ResultHash = character(),
    TerminalStateCount = integer(), stringsAsFactors = FALSE
  )
  if (anyDuplicated(completed$AttemptId) ||
      !all(completed$AttemptId %in% job$AssignmentRegistry$AttemptId)) {
    stop("The D-SIM-5 checkpoint set is not one-to-one.", call. = FALSE)
  }
  completed <- completed[match(
    intersect(job$AssignmentRegistry$AttemptId, completed$AttemptId),
    completed$AttemptId
  ), , drop = FALSE]
  remaining <- job$AssignmentRegistry[
    !job$AssignmentRegistry$AttemptId %in% completed$AttemptId,
    , drop = FALSE
  ]
  row.names(completed) <- row.names(remaining) <- NULL
  list(
    CompletedRegistry = completed,
    RemainingAssignmentRegistry = remaining,
    CompletedCount = nrow(completed), RemainingCount = nrow(remaining),
    ResultValueUsedForResumeDecision = FALSE
  )
}

mfrmr_gtds5e_shard_receipt <- function(job, checkpoint_dir) {
  plan <- mfrmr_gtds5e_resume_plan(job, checkpoint_dir)
  if (plan$RemainingCount != 0L || plan$CompletedCount != 300L) {
    stop("All 300 exact outer checkpoints are required.", call. = FALSE)
  }
  payload <- list(
    ContractHash = job$Contract$ContractHash,
    JobHash = job$JobHash,
    AdmissionManifestHash = job$AdmissionManifestHash,
    ShardId = job$Shard$ShardId[[1L]],
    ShardHash = job$Shard$ShardHash[[1L]],
    CompletedRegistry = plan$CompletedRegistry,
    TerminalOuterAttemptCount = plan$CompletedCount,
    ExactResumeSupported = TRUE,
    ResultValueUsedForExecutionDecision = FALSE,
    ScientificAdjudicationComputed = FALSE,
    CompleteDenominatorAdjudicationReady = FALSE,
    PublicSupportReady = FALSE
  )
  structure(c(payload, list(
    ShardReceiptHash = mfrmr_gtds5e_hash(payload)
  )), class = c("mfrmr_gtds5e_shard_receipt", "list"))
}

mfrmr_gtds5e_assert_shard_receipt <- function(receipt, job) {
  fields <- c(
    "ContractHash", "JobHash", "AdmissionManifestHash", "ShardId",
    "ShardHash", "CompletedRegistry", "TerminalOuterAttemptCount",
    "ExactResumeSupported", "ResultValueUsedForExecutionDecision",
    "ScientificAdjudicationComputed", "CompleteDenominatorAdjudicationReady",
    "PublicSupportReady"
  )
  completed <- receipt$CompletedRegistry
  valid <- inherits(receipt, "mfrmr_gtds5e_shard_receipt") &&
    identical(names(receipt), c(fields, "ShardReceiptHash")) &&
    identical(receipt$ShardReceiptHash,
              mfrmr_gtds5e_hash(receipt[fields])) &&
    identical(receipt$ContractHash, job$Contract$ContractHash) &&
    identical(receipt$JobHash, job$JobHash) &&
    identical(receipt$ShardHash, job$Shard$ShardHash[[1L]]) &&
    identical(receipt$TerminalOuterAttemptCount, 300L) &&
    identical(completed$AttemptId,
              job$AssignmentRegistry$AttemptId) &&
    all(completed$TerminalStateCount == 1L) &&
    isTRUE(receipt$ExactResumeSupported) &&
    !isTRUE(receipt$ResultValueUsedForExecutionDecision) &&
    !isTRUE(receipt$ScientificAdjudicationComputed) &&
    !isTRUE(receipt$CompleteDenominatorAdjudicationReady) &&
    !isTRUE(receipt$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-5 shard receipt was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds5e_run_shard <- function(
    job, input, admission, executor_manifest, output_dir,
    coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds5e_assert_job(job, input, admission)
  mfrmr_gtds5e_assert_manifest(executor_manifest, input, admission)
  shard_dir <- file.path(output_dir, job$Shard$ShardId[[1L]])
  checkpoint_dir <- file.path(shard_dir, "outer-checkpoints")
  if (!dir.exists(checkpoint_dir) &&
      !dir.create(checkpoint_dir, recursive = TRUE)) {
    stop("The D-SIM-5 shard directory could not be created.", call. = FALSE)
  }
  job_path <- file.path(shard_dir, "job.rds")
  if (file.exists(job_path)) {
    if (!identical(readRDS(job_path), job)) {
      stop("The existing D-SIM-5 job identity differs.", call. = FALSE)
    }
  } else mfrmr_gtds5e_atomic_save(job, job_path)
  plan <- mfrmr_gtds5e_resume_plan(job, checkpoint_dir)
  for (index in seq_len(nrow(plan$RemainingAssignmentRegistry))) {
    assignment <- plan$RemainingAssignmentRegistry[index, , drop = FALSE]
    result <- mfrmr_gtds5e_execute_attempt(assignment, job, coverage)
    mfrmr_gtds5e_atomic_save(
      result,
      mfrmr_gtds5e_result_path(checkpoint_dir, result$AttemptId)
    )
    cat("DSIM5_CHECKPOINT ", plan$CompletedCount + index, "/300 ",
        result$AttemptId, "\n", sep = "")
  }
  receipt <- mfrmr_gtds5e_shard_receipt(job, checkpoint_dir)
  mfrmr_gtds5e_assert_shard_receipt(receipt, job)
  receipt_path <- file.path(shard_dir, "shard-receipt.rds")
  if (file.exists(receipt_path)) {
    if (!identical(readRDS(receipt_path), receipt)) {
      stop("The existing D-SIM-5 shard receipt differs.", call. = FALSE)
    }
  } else mfrmr_gtds5e_atomic_save(receipt, receipt_path)
  receipt
}

mfrmr_gtds5e_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds5e_require_primitives", "mfrmr_gtds5e_hash",
    "mfrmr_gtds5e_canonical_code", "mfrmr_gtds5e_contract",
    "mfrmr_gtds5e_validate_parents", "mfrmr_gtds5e_job",
    "mfrmr_gtds5e_assert_job", "mfrmr_gtds5e_data_contract",
    "mfrmr_gtds5e_rng_snapshot", "mfrmr_gtds5e_rng_restored",
    "mfrmr_gtds5e_empty_primary_receipts",
    "mfrmr_gtds5e_empty_metrics", "mfrmr_gtds5e_empty_inner_receipts",
    "mfrmr_gtds5e_dependency_bootstrap", "mfrmr_gtds5e_result",
    "mfrmr_gtds5e_result_fields", "mfrmr_gtds5e_assert_result",
    "mfrmr_gtds5e_execute_attempt", "mfrmr_gtds5e_shadow_job",
    "mfrmr_gtds5e_shadow_qualification",
    "mfrmr_gtds5e_atomic_save", "mfrmr_gtds5e_result_path",
    "mfrmr_gtds5e_resume_plan", "mfrmr_gtds5e_shard_receipt",
    "mfrmr_gtds5e_assert_shard_receipt", "mfrmr_gtds5e_run_shard",
    "mfrmr_gtds5e_implementation_identity",
    "mfrmr_gtds5e_manifest", "mfrmr_gtds5e_assert_manifest"
  )
  target <- environment(mfrmr_gtds5e_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds5e_hash(list(
        Formals = mfrmr_gtds5e_canonical_code(formals(fun)),
        Body = mfrmr_gtds5e_canonical_code(body(fun))
      ))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtds5e_manifest <- function(
    input, admission, contract = mfrmr_gtds5e_contract()) {
  mfrmr_gtds5e_validate_parents(input, admission, contract)
  before_rng <- mfrmr_gtds5e_rng_snapshot()
  jobs <- lapply(input$ShardRegistry$ShardId, function(shard_id) {
    mfrmr_gtds5e_job(
      shard_id, input, admission, contract, validate = FALSE
    )
  })
  registry <- do.call(rbind, lapply(seq_along(jobs), function(index) {
    job <- jobs[[index]]
    data.frame(
      ShardOrdinal = index, ShardId = job$Shard$ShardId[[1L]],
      ShardHash = job$Shard$ShardHash[[1L]], JobHash = job$JobHash,
      OuterRequestCount = job$Summary$OuterRequestCount,
      IntervalOuterRequestCount = job$Summary$IntervalOuterRequestCount,
      InnerAttemptCount = job$Summary$InnerAttemptCount,
      ExecutionAuthorized = TRUE, ExecutionStarted = FALSE,
      RngStreamOpened = FALSE, ResultViewed = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  shadow <- mfrmr_gtds5e_shadow_qualification(
    mfrmr_gtds3_manifest(), contract
  )
  summary <- list(
    QualifiedShardCount = nrow(registry),
    QualifiedOuterRequestCount = sum(registry$OuterRequestCount),
    QualifiedIntervalOuterRequestCount =
      sum(registry$IntervalOuterRequestCount),
    QualifiedInnerAttemptCount = sum(registry$InnerAttemptCount),
    AllJobsAdmissionBound = all(registry$ExecutionAuthorized),
    OuterAttemptCheckpointAtomic = TRUE,
    ExactResumeQualified = TRUE,
    ResultValueAdaptiveBranchPresent = FALSE,
    IntegratedShadowExecutorQualified =
      shadow$IntegratedExecutorQualified,
    QualificationExecutionStarted = FALSE,
    QualificationPlanned857RngStreamOpened = FALSE,
    QualificationPlanned858RngStreamOpened = FALSE,
    QualificationShadowBackendCallMade =
      shadow$Result$BackendCallMade,
    QualificationPlannedBackendCallMade = FALSE,
    CallerRngStateRestored = mfrmr_gtds5e_rng_restored(before_rng),
    Dsim5ExecutionAuthorized = TRUE,
    ScientificAdjudicationComputed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    CurrentDisposition =
      "dsim5_executor_qualified_authorized_execution_not_started"
  )
  payload <- list(
    Contract = contract,
    LaunchInputHash = input$LaunchInputHash,
    AdmissionManifestHash = admission$ManifestHash,
    JobRegistry = registry,
    ShadowQualification = shadow,
    ImplementationIdentity = mfrmr_gtds5e_implementation_identity(),
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds5e_hash(payload)
  )), class = c("mfrmr_gtds5e_manifest", "list"))
  mfrmr_gtds5e_assert_manifest(manifest, input, admission)
  manifest
}

mfrmr_gtds5e_assert_manifest <- function(manifest, input, admission) {
  fields <- c(
    "Contract", "LaunchInputHash", "AdmissionManifestHash", "JobRegistry",
    "ShadowQualification", "ImplementationIdentity", "Summary"
  )
  if (!inherits(manifest, "mfrmr_gtds5e_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-5 executor manifest is required.", call. = FALSE)
  }
  contract <- mfrmr_gtds5e_contract()
  mfrmr_gtds5e_validate_parents(input, admission, contract)
  jobs <- lapply(input$ShardRegistry$ShardId, function(shard_id) {
    mfrmr_gtds5e_job(
      shard_id, input, admission, contract, validate = FALSE
    )
  })
  expected_hashes <- vapply(jobs, function(job) job$JobHash, character(1L))
  registry <- manifest$JobRegistry
  shadow <- manifest$ShadowQualification
  shadow_job <- mfrmr_gtds5e_shadow_job(
    shadow$ModelSpecificationId, contract
  )
  mfrmr_gtds5e_assert_result(shadow$Result, shadow_job, qualification = TRUE)
  summary <- manifest$Summary
  valid <- identical(manifest$Contract, contract) &&
    identical(manifest$ManifestHash, mfrmr_gtds5e_hash(manifest[fields])) &&
    identical(manifest$LaunchInputHash, input$LaunchInputHash) &&
    identical(manifest$AdmissionManifestHash, admission$ManifestHash) &&
    identical(registry$ShardId, input$ShardRegistry$ShardId) &&
    identical(registry$JobHash, expected_hashes) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds5e_implementation_identity()) &&
    identical(summary$QualifiedShardCount, 50L) &&
    identical(summary$QualifiedOuterRequestCount, 15000L) &&
    identical(summary$QualifiedIntervalOuterRequestCount, 5000L) &&
    identical(summary$QualifiedInnerAttemptCount, 995000L) &&
    isTRUE(summary$AllJobsAdmissionBound) &&
    isTRUE(summary$OuterAttemptCheckpointAtomic) &&
    isTRUE(summary$ExactResumeQualified) &&
    !isTRUE(summary$ResultValueAdaptiveBranchPresent) &&
    isTRUE(summary$IntegratedShadowExecutorQualified) &&
    !isTRUE(summary$QualificationExecutionStarted) &&
    !isTRUE(summary$QualificationPlanned857RngStreamOpened) &&
    !isTRUE(summary$QualificationPlanned858RngStreamOpened) &&
    isTRUE(summary$QualificationShadowBackendCallMade) &&
    !isTRUE(summary$QualificationPlannedBackendCallMade) &&
    isTRUE(summary$CallerRngStateRestored) &&
    identical(shadow$ScenarioId, contract$QualificationScenarioId) &&
    identical(shadow$DataSeed, contract$QualificationDataSeed) &&
    identical(shadow$BootstrapSeed,
              contract$QualificationBootstrapSeed) &&
    isTRUE(shadow$IntegratedExecutorQualified) &&
    isTRUE(shadow$CallerRngStateRestored) &&
    !isTRUE(shadow$CountsAsDsim5Attempt) &&
    !isTRUE(shadow$Planned857RngStreamOpened) &&
    !isTRUE(shadow$Planned858RngStreamOpened) &&
    isTRUE(summary$Dsim5ExecutionAuthorized) &&
    !isTRUE(summary$ScientificAdjudicationComputed) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-5 executor manifest was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

# ponytail: outer-attempt checkpoints are the intentional restart-cost ceiling;
# add inner-bootstrap checkpoints only if observed interruption cost warrants it.
