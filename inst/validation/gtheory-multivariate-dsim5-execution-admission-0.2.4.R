# Internal all-or-none D-SIM-5 execution admission.
#
# This file authorizes the exact 50-shard set as one confirmation denominator.
# It opens no RNG stream, generates no response, and calls no backend.

mfrmr_gtds5a_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The D-SIM-5 admission requires `digest`.", call. = FALSE)
  }
  digest::digest(
    value, algo = "sha256", serialize = TRUE, serializeVersion = 3L
  )
}

mfrmr_gtds5a_contract <- function() {
  payload <- list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM5-EXECUTION-ADMISSION-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-09-01",
    ParentLaunchContractHash =
      "74716dd0fbba6ac2ceb93c225818a5b7c0e0dd33ab9a0c7440619b4e34a70cf2",
    ParentLaunchInputHash =
      "e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071",
    ParentWorkerManifestHash =
      "459abaa38eedfb5ecc8a918d3d1b99cd765867297ab392dd5c896ec276a06f1a",
    AuthorizationScope = "all_50_shards_one_confirmation_denominator",
    ExpectedAdmissionCriterionCount = 8L,
    ExpectedShardCount = 50L,
    ExpectedOuterRequestCount = 15000L,
    ExpectedInnerAttemptCount = 995000L,
    ExpectedBackendFitCallCount = 2022500L,
    PartialShardSetAuthorizationAllowed = FALSE,
    SequentialOutcomeReviewAllowed = FALSE,
    OutcomeBasedCancellationAllowed = FALSE,
    ReplacementOrReplenishmentAllowed = FALSE,
    ResourcePauseAndExactResumeAllowed = TRUE,
    CompleteDenominatorRequiredBeforeAdjudication = TRUE,
    FullDenominatorExecutionAdmitted = TRUE,
    Dsim5ExecutionAuthorized = TRUE,
    PublicSupportPromotionAllowed = FALSE
  )
  structure(c(payload, list(
    ContractHash = mfrmr_gtds5a_hash(payload)
  )), class = c("mfrmr_gtds5a_contract", "list"))
}

mfrmr_gtds5a_validate_contract <- function(
    contract = mfrmr_gtds5a_contract()) {
  valid <- inherits(contract, "mfrmr_gtds5a_contract") &&
    identical(contract, mfrmr_gtds5a_contract()) &&
    identical(contract$ExpectedAdmissionCriterionCount, 8L) &&
    identical(contract$ExpectedShardCount, 50L) &&
    !isTRUE(contract$PartialShardSetAuthorizationAllowed) &&
    !isTRUE(contract$SequentialOutcomeReviewAllowed) &&
    !isTRUE(contract$OutcomeBasedCancellationAllowed) &&
    !isTRUE(contract$ReplacementOrReplenishmentAllowed) &&
    isTRUE(contract$ResourcePauseAndExactResumeAllowed) &&
    isTRUE(contract$CompleteDenominatorRequiredBeforeAdjudication) &&
    isTRUE(contract$FullDenominatorExecutionAdmitted) &&
    isTRUE(contract$Dsim5ExecutionAuthorized) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) stop("The D-SIM-5 admission contract is invalid.",
                   call. = FALSE)
  invisible(TRUE)
}

mfrmr_gtds5a_admission_criteria <- function(
    input, contract = mfrmr_gtds5a_contract()) {
  mfrmr_gtds5i_assert_launch_input(input)
  summary <- input$Summary
  shards <- input$ShardRegistry
  satisfied <- c(
    identical(input$Contract$ContractHash,
              contract$ParentLaunchContractHash) &&
      identical(input$LaunchInputHash, contract$ParentLaunchInputHash),
    identical(input$ParentWorkerManifest$ManifestHash,
              contract$ParentWorkerManifestHash) &&
      isTRUE(input$ParentWorkerManifest$Summary$WorkerQualified),
    identical(summary$ShardCount, contract$ExpectedShardCount) &&
      identical(summary$OuterRequestCount,
                contract$ExpectedOuterRequestCount) &&
      identical(summary$InnerAttemptCount,
                contract$ExpectedInnerAttemptCount),
    isTRUE(summary$BalancedBackendFitCalls) &&
      isTRUE(summary$AllScenariosPresentPerShard) &&
      all(shards$ExpectedBackendFitCallCount == 40450L),
    isTRUE(summary$OuterAttemptAtomic) &&
      isTRUE(summary$BootstrapBlockAtomic),
    !isTRUE(summary$Planned857RngStreamOpened) &&
      !isTRUE(summary$Planned858RngStreamOpened) &&
      !any(input$AssignmentRegistry$RngStreamOpened),
    !isTRUE(contract$SequentialOutcomeReviewAllowed) &&
      !isTRUE(contract$OutcomeBasedCancellationAllowed) &&
      isTRUE(contract$CompleteDenominatorRequiredBeforeAdjudication),
    !isTRUE(summary$SimulationValidationReady) &&
      !isTRUE(summary$PublicSupportReady) &&
      !isTRUE(contract$PublicSupportPromotionAllowed)
  )
  data.frame(
    CriterionOrdinal = seq_len(8L),
    CriterionId = c(
      "launch_input_identity", "qualified_worker_identity",
      "complete_denominator", "balanced_role_complete_shards",
      "attempt_and_bootstrap_atomicity", "planned_rng_unopened",
      "all_or_none_outcome_blind_commitment", "claim_ceiling_preserved"
    ),
    Required = TRUE,
    Satisfied = satisfied,
    ResultAdaptiveRevisionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds5a_authorized_shards <- function(input) {
  shards <- input$ShardRegistry
  data.frame(
    ShardOrdinal = shards$ShardOrdinal,
    ShardId = shards$ShardId,
    ShardHash = shards$ShardHash,
    ReplicateFirst = shards$ReplicateFirst,
    ReplicateLast = shards$ReplicateLast,
    OuterRequestCount = shards$OuterRequestCount,
    InnerAttemptCount = shards$InnerAttemptCount,
    ExpectedBackendFitCallCount = shards$ExpectedBackendFitCallCount,
    ExecutionAuthorized = TRUE,
    ExecutionStarted = FALSE,
    RngStreamOpened = FALSE,
    TerminalOuterAttemptCount = 0L,
    ResultViewed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds5a_canonical_code <- function(value) {
  paste(deparse(value, width.cutoff = 500L, control = "all"),
        collapse = "\n")
}

mfrmr_gtds5a_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds5a_hash", "mfrmr_gtds5a_contract",
    "mfrmr_gtds5a_validate_contract", "mfrmr_gtds5a_admission_criteria",
    "mfrmr_gtds5a_authorized_shards", "mfrmr_gtds5a_canonical_code",
    "mfrmr_gtds5a_implementation_identity", "mfrmr_gtds5a_manifest",
    "mfrmr_gtds5a_assert_manifest"
  )
  target <- environment(mfrmr_gtds5a_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions),
    FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds5a_hash(list(
        Formals = mfrmr_gtds5a_canonical_code(formals(fun)),
        Body = mfrmr_gtds5a_canonical_code(body(fun))
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds5a_manifest <- function(
    input, contract = mfrmr_gtds5a_contract()) {
  mfrmr_gtds5a_validate_contract(contract)
  criteria <- mfrmr_gtds5a_admission_criteria(input, contract)
  if (!all(criteria$Satisfied)) {
    stop("The D-SIM-5 execution denominator is not admissible.",
         call. = FALSE)
  }
  shards <- mfrmr_gtds5a_authorized_shards(input)
  summary <- list(
    AdmissionCriterionCount = nrow(criteria),
    AdmissionCriterionSatisfiedCount = sum(criteria$Satisfied),
    AuthorizedShardCount = sum(shards$ExecutionAuthorized),
    AuthorizedOuterRequestCount = sum(shards$OuterRequestCount),
    AuthorizedInnerAttemptCount = sum(shards$InnerAttemptCount),
    AuthorizedBackendFitCallCount =
      sum(shards$ExpectedBackendFitCallCount),
    AuthorizationScope = contract$AuthorizationScope,
    FullDenominatorExecutionAdmitted = TRUE,
    Dsim5ExecutionAuthorized = TRUE,
    ExecutionStarted = FALSE,
    Planned857RngStreamOpened = FALSE,
    Planned858RngStreamOpened = FALSE,
    ResultViewed = FALSE,
    InterimScientificAdjudicationAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    CurrentDisposition =
      "dsim5_full_denominator_execution_admitted_not_started"
  )
  payload <- list(
    Contract = contract,
    ParentLaunchInputHash = input$LaunchInputHash,
    AdmissionCriterionRegistry = criteria,
    AuthorizedShardRegistry = shards,
    ImplementationIdentity = mfrmr_gtds5a_implementation_identity(),
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds5a_hash(payload)
  )), class = c("mfrmr_gtds5a_manifest", "list"))
  mfrmr_gtds5a_assert_manifest(manifest, input)
  manifest
}

mfrmr_gtds5a_assert_manifest <- function(manifest, input) {
  fields <- c(
    "Contract", "ParentLaunchInputHash", "AdmissionCriterionRegistry",
    "AuthorizedShardRegistry", "ImplementationIdentity", "Summary"
  )
  if (!inherits(manifest, "mfrmr_gtds5a_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-5 admission manifest is required.", call. = FALSE)
  }
  mfrmr_gtds5i_assert_launch_input(input)
  contract <- mfrmr_gtds5a_contract()
  criteria <- mfrmr_gtds5a_admission_criteria(input, contract)
  shards <- mfrmr_gtds5a_authorized_shards(input)
  summary <- manifest$Summary
  valid <- identical(manifest$Contract, contract) &&
    identical(manifest$ManifestHash, mfrmr_gtds5a_hash(manifest[fields])) &&
    identical(manifest$ParentLaunchInputHash, input$LaunchInputHash) &&
    identical(manifest$AdmissionCriterionRegistry, criteria) &&
    identical(manifest$AuthorizedShardRegistry, shards) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds5a_implementation_identity()) &&
    identical(summary$AdmissionCriterionCount, 8L) &&
    identical(summary$AdmissionCriterionSatisfiedCount, 8L) &&
    identical(summary$AuthorizedShardCount, 50L) &&
    identical(summary$AuthorizedOuterRequestCount, 15000L) &&
    identical(summary$AuthorizedInnerAttemptCount, 995000L) &&
    identical(summary$AuthorizedBackendFitCallCount, 2022500L) &&
    isTRUE(summary$FullDenominatorExecutionAdmitted) &&
    isTRUE(summary$Dsim5ExecutionAuthorized) &&
    !isTRUE(summary$ExecutionStarted) &&
    !isTRUE(summary$Planned857RngStreamOpened) &&
    !isTRUE(summary$Planned858RngStreamOpened) &&
    !isTRUE(summary$ResultViewed) &&
    !isTRUE(summary$InterimScientificAdjudicationAllowed) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady) &&
    all(shards$ExecutionAuthorized) &&
    all(!shards$ExecutionStarted) &&
    all(!shards$RngStreamOpened) &&
    all(shards$TerminalOuterAttemptCount == 0L) &&
    all(!shards$ResultViewed)
  if (!valid) {
    stop("The D-SIM-5 admission manifest was altered.", call. = FALSE)
  }
  invisible(TRUE)
}
