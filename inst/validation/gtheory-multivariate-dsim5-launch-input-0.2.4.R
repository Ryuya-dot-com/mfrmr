# Internal shardable D-SIM-5 launch input.
#
# This file partitions the frozen D-SIM-4 requests without opening an RNG
# stream, generating a response, calling a backend, or authorizing execution.

mfrmr_gtds5i_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The D-SIM-5 launch input requires `digest`.", call. = FALSE)
  }
  digest::digest(
    value, algo = "sha256", serialize = TRUE, serializeVersion = 3L
  )
}

mfrmr_gtds5i_contract <- function() {
  payload <- list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM5-LAUNCH-INPUT-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-09-01",
    ParentWorkerContractHash =
      "999e23abd17f017e03f3b2c627d79ddab146dedb9a602feacb08c741350c1999",
    ParentWorkerManifestHash =
      "459abaa38eedfb5ecc8a918d3d1b99cd765867297ab392dd5c896ec276a06f1a",
    ParentInnerIdentityHash =
      "fe14e64b42fadce5a7f47d0706fc04cb38298adafa8a8b5313fb63e9a5759bd8",
    ShardCount = 50L,
    ReplicatesPerShard = 50L,
    ExpectedScenarioCount = 6L,
    ExpectedOuterRequestCount = 15000L,
    ExpectedIntervalOuterCount = 5000L,
    ExpectedInnerAttemptCount = 995000L,
    ExpectedBackendFitCallCount = 2022500L,
    OuterAttemptAtomic = TRUE,
    BootstrapBlockAtomic = TRUE,
    Planned857SeedMayOpen = FALSE,
    Planned858SeedMayOpen = FALSE,
    Dsim5ExecutionAuthorized = FALSE
  )
  structure(c(payload, list(
    ContractHash = mfrmr_gtds5i_hash(payload)
  )), class = c("mfrmr_gtds5i_contract", "list"))
}

mfrmr_gtds5i_validate_worker <- function(
    worker, contract = mfrmr_gtds5i_contract()) {
  fields <- setdiff(names(worker), "ManifestHash")
  valid <- inherits(worker, "mfrmr_gtds4w_manifest") &&
    identical(worker$ManifestHash, mfrmr_gtds5i_hash(worker[fields])) &&
    identical(worker$ManifestHash, contract$ParentWorkerManifestHash) &&
    identical(worker$Contract$ContractHash,
              contract$ParentWorkerContractHash) &&
    identical(worker$InnerIdentityHash, contract$ParentInnerIdentityHash) &&
    identical(nrow(worker$OuterRequestRegistry),
              contract$ExpectedOuterRequestCount) &&
    identical(nrow(worker$InnerBlockRegistry),
              contract$ExpectedIntervalOuterCount) &&
    isTRUE(worker$Summary$WorkerQualified) &&
    isTRUE(worker$Summary$StaticReconciliationReady) &&
    !isTRUE(worker$Summary$Dsim5ExecutionAuthorized) &&
    all(!worker$OuterRequestRegistry$ExecutionAuthorized) &&
    all(!worker$InnerBlockRegistry$ExecutionAuthorized)
  if (!valid) {
    stop("The frozen D-SIM-4 worker manifest changed.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds5i_assignments <- function(
    worker, contract = mfrmr_gtds5i_contract()) {
  mfrmr_gtds5i_validate_worker(worker, contract)
  requests <- worker$OuterRequestRegistry
  blocks <- worker$InnerBlockRegistry
  block_index <- match(requests$AttemptId, blocks$AttemptId)
  shard <- as.integer((requests$Replicate - 1L) %/%
                        contract$ReplicatesPerShard + 1L)
  assignments <- data.frame(
    ShardOrdinal = shard,
    ShardId = sprintf("D5-SHARD-%03d", shard),
    AttemptOrdinal = requests$AttemptOrdinal,
    AttemptId = requests$AttemptId,
    ConfirmationScenarioId = requests$ConfirmationScenarioId,
    ScenarioRole = requests$ScenarioRole,
    Replicate = requests$Replicate,
    DataSeed = requests$DataSeed,
    BootstrapSeed = requests$BootstrapSeed,
    IntervalEligible = requests$IntervalEligible,
    InnerBootstrapAttemptCount = requests$InnerBootstrapAttemptCount,
    ExpectedPrimaryFitCallCount = requests$ExpectedPrimaryFitCallCount,
    ExpectedInnerRefitCallCount = requests$ExpectedInnerRefitCallCount,
    OuterRequestHash = requests$RequestHash,
    InnerBlockHash = blocks$InnerBlockHash[block_index],
    RngStreamOpened = FALSE,
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  row.names(assignments) <- NULL
  assignments
}

mfrmr_gtds5i_shards <- function(
    assignments, contract = mfrmr_gtds5i_contract()) {
  rows <- lapply(seq_len(contract$ShardCount), function(index) {
    shard <- assignments[assignments$ShardOrdinal == index, , drop = FALSE]
    payload <- list(
      ParentWorkerManifestHash = contract$ParentWorkerManifestHash,
      ShardOrdinal = index,
      ShardId = sprintf("D5-SHARD-%03d", index),
      AttemptId = shard$AttemptId,
      OuterRequestHash = shard$OuterRequestHash,
      InnerBlockHash = shard$InnerBlockHash
    )
    data.frame(
      ShardOrdinal = index,
      ShardId = payload$ShardId,
      ReplicateFirst = min(shard$Replicate),
      ReplicateLast = max(shard$Replicate),
      ScenarioCount = length(unique(shard$ConfirmationScenarioId)),
      OuterRequestCount = nrow(shard),
      IntervalOuterRequestCount = sum(shard$IntervalEligible),
      InnerAttemptCount = sum(shard$InnerBootstrapAttemptCount),
      ExpectedPrimaryFitCallCount = sum(shard$ExpectedPrimaryFitCallCount),
      ExpectedInnerRefitCallCount = sum(shard$ExpectedInnerRefitCallCount),
      ExpectedBackendFitCallCount = sum(
        shard$ExpectedPrimaryFitCallCount +
          shard$ExpectedInnerRefitCallCount
      ),
      ShardHash = mfrmr_gtds5i_hash(payload),
      RngStreamOpened = FALSE,
      ExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  shards <- do.call(rbind, rows)
  row.names(shards) <- NULL
  shards
}

mfrmr_gtds5i_launch_input <- function(
    worker, contract = mfrmr_gtds5i_contract()) {
  assignments <- mfrmr_gtds5i_assignments(worker, contract)
  shards <- mfrmr_gtds5i_shards(assignments, contract)
  summary <- list(
    ShardCount = nrow(shards),
    ScenarioCount = length(unique(assignments$ConfirmationScenarioId)),
    OuterRequestCount = nrow(assignments),
    IntervalOuterRequestCount = sum(assignments$IntervalEligible),
    InnerAttemptCount = sum(assignments$InnerBootstrapAttemptCount),
    ExpectedPrimaryFitCallCount =
      sum(assignments$ExpectedPrimaryFitCallCount),
    ExpectedInnerRefitCallCount =
      sum(assignments$ExpectedInnerRefitCallCount),
    ExpectedBackendFitCallCount = sum(
      assignments$ExpectedPrimaryFitCallCount +
        assignments$ExpectedInnerRefitCallCount
    ),
    OuterAttemptAtomic = TRUE,
    BootstrapBlockAtomic = TRUE,
    BalancedBackendFitCalls = length(unique(
      shards$ExpectedBackendFitCallCount
    )) == 1L,
    AllScenariosPresentPerShard = all(
      shards$ScenarioCount == contract$ExpectedScenarioCount
    ),
    LaunchInputReady = TRUE,
    Planned857RngStreamOpened = FALSE,
    Planned858RngStreamOpened = FALSE,
    Dsim5ExecutionAuthorized = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE
  )
  payload <- list(
    Contract = contract,
    ParentWorkerManifest = worker,
    AssignmentRegistry = assignments,
    ShardRegistry = shards,
    Summary = summary
  )
  input <- structure(c(payload, list(
    LaunchInputHash = mfrmr_gtds5i_hash(payload)
  )), class = c("mfrmr_gtds5i_launch_input", "list"))
  mfrmr_gtds5i_assert_launch_input(input)
  input
}

mfrmr_gtds5i_assert_launch_input <- function(input) {
  fields <- c(
    "Contract", "ParentWorkerManifest", "AssignmentRegistry",
    "ShardRegistry", "Summary"
  )
  if (!inherits(input, "mfrmr_gtds5i_launch_input") ||
      !identical(names(input), c(fields, "LaunchInputHash"))) {
    stop("A typed D-SIM-5 launch input is required.", call. = FALSE)
  }
  contract <- mfrmr_gtds5i_contract()
  mfrmr_gtds5i_validate_worker(input$ParentWorkerManifest, contract)
  assignments <- mfrmr_gtds5i_assignments(
    input$ParentWorkerManifest, contract
  )
  shards <- mfrmr_gtds5i_shards(assignments, contract)
  summary <- input$Summary
  valid <- identical(input$Contract, contract) &&
    identical(input$LaunchInputHash, mfrmr_gtds5i_hash(input[fields])) &&
    identical(input$AssignmentRegistry, assignments) &&
    identical(input$ShardRegistry, shards) &&
    identical(summary$ShardCount, 50L) &&
    identical(summary$ScenarioCount, 6L) &&
    identical(summary$OuterRequestCount, 15000L) &&
    identical(summary$IntervalOuterRequestCount, 5000L) &&
    identical(summary$InnerAttemptCount, 995000L) &&
    identical(summary$ExpectedPrimaryFitCallCount, 32500L) &&
    identical(summary$ExpectedInnerRefitCallCount, 1990000L) &&
    identical(summary$ExpectedBackendFitCallCount, 2022500L) &&
    isTRUE(summary$OuterAttemptAtomic) &&
    isTRUE(summary$BootstrapBlockAtomic) &&
    isTRUE(summary$BalancedBackendFitCalls) &&
    isTRUE(summary$AllScenariosPresentPerShard) &&
    isTRUE(summary$LaunchInputReady) &&
    all(shards$OuterRequestCount == 300L) &&
    all(shards$IntervalOuterRequestCount == 100L) &&
    all(shards$InnerAttemptCount == 19900L) &&
    all(shards$ExpectedBackendFitCallCount == 40450L) &&
    !any(assignments$RngStreamOpened) &&
    !any(assignments$ExecutionAuthorized) &&
    !any(shards$RngStreamOpened) &&
    !any(shards$ExecutionAuthorized) &&
    !isTRUE(summary$Planned857RngStreamOpened) &&
    !isTRUE(summary$Planned858RngStreamOpened) &&
    !isTRUE(summary$Dsim5ExecutionAuthorized) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-5 launch input was altered.", call. = FALSE)
  }
  invisible(TRUE)
}
