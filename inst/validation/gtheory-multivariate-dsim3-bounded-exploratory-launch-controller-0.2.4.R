# Internal D-SIM-3 bounded exploratory launch controller.
#
# This is the first layer allowed to open the frozen 856 seed identities. It
# executes one isolated dataset pipeline at a time, writes one immutable atomic
# checkpoint per registered dataset, and emits exactly one terminal receipt for
# every attempted dataset and candidate route. It computes no recovery claim.

mfrmr_gtds3ac_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3x_assert_manifest",
    "mfrmr_gtds3aa_assert_manifest", "mfrmr_gtds3aa_execute_request",
    "mfrmr_gtds3aa_assert_planned_generation",
    "mfrmr_gtds3ab_assert_manifest", "mfrmr_gtds3p_plan",
    "mfrmr_gtds3p_assert_plan", "mfrmr_gtds3b_bind_profile",
    "mfrmr_gtds3s_manifest", "mfrmr_gtds3t_manifest",
    "mfrmr_gtds3o_project_profile", "mfrmr_gtds3w_fit_template",
    "mfrmr_gtds3w_metric_vectors"
  )
  target <- environment(mfrmr_gtds3ac_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the complete D-SIM-3 launch chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3ac_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3ac_file_hash <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The bounded launch requires `digest`.", call. = FALSE)
  }
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) stop("A source file is required.", call. = FALSE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtds3ac_source_basenames <- function() {
  c(
    "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
    "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
    "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
    "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
    "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
    "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R",
    "gtheory-multivariate-dsim3-covariance-distribution-binding-0.2.4.R",
    "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R",
    "gtheory-multivariate-dsim3-route-receipt-adapter-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-semantics-audit-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-design-dependent-truth-projection-",
      "0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-incidence-allocation-operator-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-truth-",
      "coefficient-0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-superseding-unopened-plan-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-execution-bridge-request-contract-",
      "0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-fit-metric-worker-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-planned-seed-generation-adapter-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-final-launch-readiness-",
      "reconciliation-0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
      "controller-0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
      "worker-0.2.4.R"
    )
  )
}

mfrmr_gtds3ac_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-BOUNDED-LAUNCH-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentSupersedingPlanHash =
      "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a",
    ParentRequestContractHash =
      "c37fbedb03f0535d2e8aab1380949385ba10b0fc32b205f77df17074d52fd67e",
    ParentRequestManifestHash =
      "69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef",
    ParentWorkerContractHash =
      "9e5055fc47191f4426507c352b45b72a2a40256bd227dcf464d04e7058de44c7",
    ParentAdapterContractHash =
      "b7f193e567e61b76bc19c2a9d8f559600ba4dd849e3eed57ff0aa08608721ac0",
    ParentAdapterManifestHash =
      "2e27bdd0f5e8988adf928959607064b5cefd9e80251317837ba4b0fcca09242b",
    ParentReadinessContractHash =
      "5ddc86af39a8681c97fa916fbd7fc66e45dcb0278cad1d3248f1f1657c824419",
    ParentReadinessManifestHash =
      "3e3106fa3550c83696235b95b4e9e2ea30b512d5e6c670f39eeb30e6aee82a81",
    WorkerSourceSHA256 =
      "cc3239a00235a2d9eb9d47e2c6d4a18d2172b5d7290ba5a0922ce32256aa0e27"
  )
}

mfrmr_gtds3ac_resource_registry <- function() {
  data.frame(
    ScopeOrdinal = 1:5,
    ScopeId = c(
      "dataset_generation", "one_route_fit", "one_route_metric",
      "one_dataset_pipeline", "complete_exploratory_run"
    ),
    MaximumWallSeconds = c(300L, 1200L, 120L, 7200L, 172800L),
    MaximumPeakRssMiB = c(2048L, 8192L, 2048L, 8192L, 8192L),
    MaximumConcurrentWorkers = 1L,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ac_contract <- function() {
  mfrmr_gtds3ac_require_primitives()
  identity <- mfrmr_gtds3ac_identity()
  payload <- c(identity, list(
    ExpectedSourceFileCount = 20L,
    ExpectedDatasetAttemptCount = 42L,
    ExpectedCandidateRouteAttemptCount = 50L,
    ExpectedMetricRequestCount = 100L,
    ExpectedTerminalReceiptCount = 92L,
    ExpectedFrozenNoCallRouteCount = 160L,
    ExpectedCompleteRouteDenominatorCount = 210L,
    ExpectedCoordinateDenominatorCount = 420L,
    PlannedSeedBandId = "DSIM3-SUPERSEDING-856",
    PlannedSeedMinimum = 856001001L,
    PlannedSeedMaximum = 856021002L,
    ResourceRegistry = mfrmr_gtds3ac_resource_registry(),
    TechnicalReadinessRequired = TRUE,
    Planned856RngStreamMayOpen = TRUE,
    ExploratoryResponseGenerationAllowed = TRUE,
    ExploratoryBackendFitMetricAllowed = TRUE,
    DatasetProcessIsolationRequired = TRUE,
    AtomicDatasetCheckpointRequired = TRUE,
    ExactCheckpointResumeAllowed = TRUE,
    InterruptedAttemptMayBeReexecuted = FALSE,
    CompletedAttemptMayBeReexecuted = FALSE,
    ReplacementSeedAllowed = FALSE,
    PartialLaunchAllowed = FALSE,
    MaximumConcurrentWorkers = 1L,
    ExactlyOneTerminalReceiptRequired = TRUE,
    FrozenNoCallUnitsMayBeExecuted = FALSE,
    HistoricalReceiptInheritanceAllowed = FALSE,
    ShadowReceiptPromotionAllowed = FALSE,
    DiagnosticOverrideAllowed = FALSE,
    ScalarPoolingAcrossStrataAllowed = FALSE,
    PackageSelectedDecisionWeightsAllowed = FALSE,
    RecoveryAnalysisDuringLaunchAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3ac_hash(payload)
  )), class = c("mfrmr_gtds3ac_contract", "list"))
}

mfrmr_gtds3ac_validate_contract <- function(
    contract = mfrmr_gtds3ac_contract()) {
  canonical <- mfrmr_gtds3ac_contract()
  valid <- inherits(contract, "mfrmr_gtds3ac_contract") &&
    identical(contract, canonical) &&
    identical(contract$ExpectedDatasetAttemptCount, 42L) &&
    identical(contract$ExpectedCandidateRouteAttemptCount, 50L) &&
    identical(contract$ExpectedMetricRequestCount, 100L) &&
    identical(contract$ExpectedTerminalReceiptCount, 92L) &&
    identical(contract$ExpectedFrozenNoCallRouteCount, 160L) &&
    isTRUE(contract$TechnicalReadinessRequired) &&
    isTRUE(contract$Planned856RngStreamMayOpen) &&
    isTRUE(contract$ExploratoryResponseGenerationAllowed) &&
    isTRUE(contract$ExploratoryBackendFitMetricAllowed) &&
    isTRUE(contract$DatasetProcessIsolationRequired) &&
    isTRUE(contract$AtomicDatasetCheckpointRequired) &&
    isTRUE(contract$ExactCheckpointResumeAllowed) &&
    !isTRUE(contract$InterruptedAttemptMayBeReexecuted) &&
    !isTRUE(contract$CompletedAttemptMayBeReexecuted) &&
    !isTRUE(contract$ReplacementSeedAllowed) &&
    !isTRUE(contract$PartialLaunchAllowed) &&
    identical(contract$MaximumConcurrentWorkers, 1L) &&
    isTRUE(contract$ExactlyOneTerminalReceiptRequired) &&
    !isTRUE(contract$FrozenNoCallUnitsMayBeExecuted) &&
    !isTRUE(contract$HistoricalReceiptInheritanceAllowed) &&
    !isTRUE(contract$ShadowReceiptPromotionAllowed) &&
    !isTRUE(contract$DiagnosticOverrideAllowed) &&
    !isTRUE(contract$ScalarPoolingAcrossStrataAllowed) &&
    !isTRUE(contract$PackageSelectedDecisionWeightsAllowed) &&
    !isTRUE(contract$RecoveryAnalysisDuringLaunchAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The bounded D-SIM-3 launch contract is invalid.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3ac_source_registry <- function(source_root, contract) {
  validation <- file.path(
    normalizePath(source_root, mustWork = TRUE), "inst", "validation"
  )
  basenames <- mfrmr_gtds3ac_source_basenames()
  paths <- file.path(validation, basenames)
  if (!all(file.exists(paths))) {
    stop("A bounded-launch source file is missing.", call. = FALSE)
  }
  roles <- c(rep("sourced", length(basenames) - 1L), "executable")
  hashes <- vapply(paths, mfrmr_gtds3ac_file_hash, character(1L))
  worker <- basenames == tail(basenames, 1L)
  data.frame(
    SourceOrdinal = seq_along(basenames),
    SourceBasename = basenames,
    SourceRole = roles,
    SourceSHA256 = hashes,
    FrozenWorkerIdentityMatch = !worker |
      hashes == contract$WorkerSourceSHA256,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ac_evidence_paths <- function(source_root) {
  validation <- file.path(
    normalizePath(source_root, mustWork = TRUE), "inst", "validation"
  )
  relative <- c(
    generator =
      "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R",
    prior_source = paste0(
      "gtheory-multivariate-dsim3-superseding-launch-readiness-",
      "reconciliation-0.2.4.R"
    ),
    prior_record = paste0(
      "gtheory-multivariate-dsim3-superseding-launch-readiness-",
      "reconciliation-record-0.2.4.md"
    ),
    adapter_source = paste0(
      "gtheory-multivariate-dsim3-planned-seed-generation-adapter-",
      "0.2.4.R"
    ),
    adapter_record = paste0(
      "gtheory-multivariate-dsim3-planned-seed-generation-adapter-",
      "record-0.2.4.md"
    )
  )
  stats::setNames(file.path(validation, relative), names(relative))
}

mfrmr_gtds3ac_launch_input_fields <- function() {
  c(
    "Contract", "RequestManifest", "AdapterManifest",
    "ReadinessManifest", "SourceRegistry", "Summary"
  )
}

mfrmr_gtds3ac_launch_input <- function(
    request_manifest, adapter_manifest, readiness_manifest, source_root,
    contract = mfrmr_gtds3ac_contract()) {
  mfrmr_gtds3ac_validate_contract(contract)
  paths <- mfrmr_gtds3ac_evidence_paths(source_root)
  mfrmr_gtds3x_assert_manifest(request_manifest)
  mfrmr_gtds3aa_assert_manifest(adapter_manifest, paths[["generator"]])
  mfrmr_gtds3ab_assert_manifest(
    readiness_manifest, adapter_manifest, paths[["generator"]],
    paths[["prior_source"]], paths[["prior_record"]],
    paths[["adapter_source"]], paths[["adapter_record"]]
  )
  if (!identical(request_manifest$ManifestHash,
                 contract$ParentRequestManifestHash) ||
      !identical(adapter_manifest$Contract$ContractHash,
                 contract$ParentAdapterContractHash) ||
      !identical(adapter_manifest$ManifestHash,
                 contract$ParentAdapterManifestHash) ||
      !identical(readiness_manifest$Contract$ContractHash,
                 contract$ParentReadinessContractHash) ||
      !identical(readiness_manifest$ManifestHash,
                 contract$ParentReadinessManifestHash) ||
      !isTRUE(readiness_manifest$Summary$TechnicalLaunchReady)) {
    stop("A frozen technically ready launch parent changed.", call. = FALSE)
  }
  sources <- mfrmr_gtds3ac_source_registry(source_root, contract)
  summary <- list(
    DatasetAttemptCount =
      nrow(request_manifest$GenerationRequestRegistry),
    CandidateRouteAttemptCount =
      nrow(request_manifest$BackendRequestRegistry),
    MetricRequestCount = nrow(request_manifest$MetricRequestRegistry),
    TerminalRequestCount =
      nrow(request_manifest$TerminalOrchestrationRequestRegistry),
    PlannedSeedMinimum =
      min(request_manifest$GenerationRequestRegistry$DataSeed),
    PlannedSeedMaximum =
      max(request_manifest$GenerationRequestRegistry$DataSeed),
    TechnicalLaunchReady = TRUE,
    LaunchStarted = FALSE,
    Planned856RngStreamOpened = FALSE,
    RecoveryEvidenceComputed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE
  )
  payload <- list(
    Contract = contract,
    RequestManifest = request_manifest,
    AdapterManifest = adapter_manifest,
    ReadinessManifest = readiness_manifest,
    SourceRegistry = sources,
    Summary = summary
  )
  input <- structure(c(payload, list(
    LaunchInputHash = mfrmr_gtds3ac_hash(payload)
  )), class = c("mfrmr_gtds3ac_launch_input", "list"))
  mfrmr_gtds3ac_assert_launch_input(input, source_root)
  input
}

mfrmr_gtds3ac_assert_launch_input <- function(input, source_root) {
  fields <- mfrmr_gtds3ac_launch_input_fields()
  if (!inherits(input, "mfrmr_gtds3ac_launch_input") ||
      !identical(names(input), c(fields, "LaunchInputHash"))) {
    stop("A typed D-SIM-3 bounded-launch input is required.", call. = FALSE)
  }
  contract <- input$Contract
  summary <- input$Summary
  sources <- input$SourceRegistry
  paths <- mfrmr_gtds3ac_evidence_paths(source_root)
  mfrmr_gtds3x_assert_manifest(input$RequestManifest)
  mfrmr_gtds3aa_assert_manifest(
    input$AdapterManifest, paths[["generator"]]
  )
  mfrmr_gtds3ab_assert_manifest(
    input$ReadinessManifest, input$AdapterManifest,
    paths[["generator"]], paths[["prior_source"]],
    paths[["prior_record"]], paths[["adapter_source"]],
    paths[["adapter_record"]]
  )
  valid <- identical(
    input$LaunchInputHash, mfrmr_gtds3ac_hash(input[fields])
  ) && identical(contract, mfrmr_gtds3ac_contract()) &&
    identical(sources, mfrmr_gtds3ac_source_registry(source_root, contract)) &&
    identical(nrow(sources), 20L) &&
    all(sources$FrozenWorkerIdentityMatch) &&
    identical(input$RequestManifest$ManifestHash,
              contract$ParentRequestManifestHash) &&
    identical(input$AdapterManifest$ManifestHash,
              contract$ParentAdapterManifestHash) &&
    identical(input$ReadinessManifest$ManifestHash,
              contract$ParentReadinessManifestHash) &&
    identical(summary$DatasetAttemptCount, 42L) &&
    identical(summary$CandidateRouteAttemptCount, 50L) &&
    identical(summary$MetricRequestCount, 100L) &&
    identical(summary$TerminalRequestCount, 92L) &&
    identical(summary$PlannedSeedMinimum, 856001001L) &&
    identical(summary$PlannedSeedMaximum, 856021002L) &&
    isTRUE(summary$TechnicalLaunchReady) && !isTRUE(summary$LaunchStarted) &&
    !isTRUE(summary$Planned856RngStreamOpened) &&
    !isTRUE(summary$RecoveryEvidenceComputed) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-3 bounded-launch input was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3ac_atomic_save <- function(object, path) {
  directory <- dirname(path)
  if (!dir.exists(directory) && !dir.create(directory, recursive = TRUE)) {
    stop("The bounded-launch output directory could not be created.",
         call. = FALSE)
  }
  temporary <- tempfile(
    paste0(".", basename(path), "."), tmpdir = directory
  )
  on.exit(if (file.exists(temporary)) unlink(temporary), add = TRUE)
  saveRDS(object, temporary, version = 3L)
  if (!isTRUE(file.rename(temporary, path))) {
    stop("The bounded-launch atomic save could not commit.", call. = FALSE)
  }
  invisible(path)
}

mfrmr_gtds3ac_write_progress <- function(
    path, input, dataset_id, stage, route_unit_id = NA_character_) {
  payload <- list(
    LaunchInputHash = input$LaunchInputHash,
    DatasetId = dataset_id,
    Stage = stage,
    RouteUnitId = route_unit_id,
    RecordedAtUtc = format(Sys.time(), tz = "UTC", usetz = TRUE)
  )
  marker <- structure(c(payload, list(
    ProgressHash = mfrmr_gtds3ac_hash(payload)
  )), class = c("mfrmr_gtds3ac_progress", "list"))
  mfrmr_gtds3ac_atomic_save(marker, path)
  invisible(marker)
}

mfrmr_gtds3ac_rng_snapshot <- function() {
  present <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  list(
    Kind = RNGkind(), Present = present,
    Seed = if (present) get(".Random.seed", envir = .GlobalEnv) else NULL
  )
}

mfrmr_gtds3ac_rng_restored <- function(snapshot) {
  present <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  identical(snapshot$Kind, RNGkind()) && identical(snapshot$Present, present) &&
    (!present || identical(
      snapshot$Seed, get(".Random.seed", envir = .GlobalEnv)
    ))
}

mfrmr_gtds3ac_execution_view <- function(
    generation, coverage = mfrmr_gtds3_manifest()) {
  scenario <- coverage$ScenarioRegistry[
    coverage$ScenarioRegistry$ScenarioId == generation$ScenarioId,
    , drop = FALSE
  ]
  if (nrow(scenario) != 1L) {
    stop("The planned generation scenario is not frozen.", call. = FALSE)
  }
  binding <- mfrmr_gtds3b_bind_profile(
    generation$ScenarioId, coverage = coverage, validate = FALSE
  )
  list(
    ScenarioId = generation$ScenarioId,
    ScenarioOrdinal = scenario$ScenarioOrdinal[[1L]],
    ShadowSeed = generation$DataSeed,
    Profile = binding$Profile,
    GeneratedData = generation$GeneratedData,
    Summary = list(
      GeneratedDataHash = generation$Summary$GeneratedDataHash,
      GeneratedResponseCount = generation$Summary$GeneratedResponseCount
    ),
    GenerationHash = generation$CoreGenerationHash
  )
}

mfrmr_gtds3ac_terminal_receipt <- function(
    terminal_request, input, terminal_state, evidence_hash,
    attempt_started, rng_opened, response_generated, backend_call_made,
    fit_returned, metric_computed, evidence_text = "") {
  allowed <- strsplit(
    terminal_request$AllowedTerminalStates[[1L]], "|", fixed = TRUE
  )[[1L]]
  if (nrow(terminal_request) != 1L || !terminal_state %in% allowed) {
    stop("The bounded-launch terminal state is not allowed.", call. = FALSE)
  }
  payload <- list(
    ContractHash = input$Contract$ContractHash,
    LaunchInputHash = input$LaunchInputHash,
    TerminalRequestId = terminal_request$TerminalRequestId[[1L]],
    TerminalRequestHash = terminal_request$RequestHash[[1L]],
    UnitType = terminal_request$UnitType[[1L]],
    UnitId = terminal_request$UnitId[[1L]],
    TerminalState = terminal_state,
    EvidenceHash = evidence_hash,
    AttemptStarted = isTRUE(attempt_started),
    Planned856RngStreamOpened = isTRUE(rng_opened),
    ExploratoryResponseGenerated = isTRUE(response_generated),
    BackendCallMade = backend_call_made,
    FitReturned = fit_returned,
    MetricComputed = metric_computed,
    EvidenceText = evidence_text
  )
  data.frame(
    TerminalReceiptId = paste0(
      "D3AC-TR-", substr(mfrmr_gtds3ac_hash(payload), 1L, 20L)
    ),
    TerminalRequestId = terminal_request$TerminalRequestId[[1L]],
    TerminalRequestHash = terminal_request$RequestHash[[1L]],
    UnitType = terminal_request$UnitType[[1L]],
    UnitId = terminal_request$UnitId[[1L]],
    ScenarioId = terminal_request$ScenarioId[[1L]],
    Replicate = terminal_request$Replicate[[1L]],
    TerminalState = terminal_state,
    EvidenceHash = evidence_hash,
    AttemptStarted = isTRUE(attempt_started),
    Planned856RngStreamOpened = isTRUE(rng_opened),
    ExploratoryResponseGenerated = isTRUE(response_generated),
    BackendCallMade = as.logical(backend_call_made),
    FitReturned = as.logical(fit_returned),
    MetricComputed = as.logical(metric_computed),
    EvidenceText = evidence_text,
    CountsIn856Denominator = TRUE,
    HistoricalReceiptInherited = FALSE,
    RecoveryEvidenceComputed = FALSE,
    PublicSupportPromoted = FALSE,
    TerminalReceiptHash = mfrmr_gtds3ac_hash(payload),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ac_failed_metric_results <- function(
    backend_request, request_manifest, terminal_state, input) {
  requests <- request_manifest$MetricRequestRegistry[
    request_manifest$MetricRequestRegistry$BackendRequestId ==
      backend_request$BackendRequestId[[1L]], , drop = FALSE
  ]
  rows <- lapply(seq_len(nrow(requests)), function(index) {
    request <- requests[index, , drop = FALSE]
    payload <- list(
      ContractHash = input$Contract$ContractHash,
      MetricRequestHash = request$RequestHash[[1L]],
      TerminalState = terminal_state, MetricComputed = FALSE
    )
    data.frame(
      MetricRequestId = request$MetricRequestId,
      MetricRequestHash = request$RequestHash,
      BackendRequestId = request$BackendRequestId,
      RouteUnitId = request$RouteUnitId,
      ScenarioId = request$ScenarioId,
      Replicate = request$Replicate,
      RouteId = request$RouteId,
      EstimandId = request$EstimandId,
      StratumCount = 0L, StratumNames = "", ValuesCanonical = "",
      MinimumValue = NA_real_, MaximumValue = NA_real_,
      MetricComputed = FALSE, TerminalState = terminal_state,
      ScalarPoolingApplied = FALSE, RecoveryEvidenceComputed = FALSE,
      MetricResultHash = mfrmr_gtds3ac_hash(payload),
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ac_success_metric_results <- function(
    backend_request, worker_result, request_manifest, input) {
  requests <- request_manifest$MetricRequestRegistry[
    request_manifest$MetricRequestRegistry$BackendRequestId ==
      backend_request$BackendRequestId[[1L]], , drop = FALSE
  ]
  vectors <- mfrmr_gtds3w_metric_vectors(worker_result$Coefficients)
  rows <- lapply(seq_len(nrow(requests)), function(index) {
    request <- requests[index, , drop = FALSE]
    vector <- vectors[vectors$EstimandId == request$EstimandId[[1L]],
                      , drop = FALSE]
    coefficient <- if (request$EstimandId[[1L]] == "ABS-PHI") "Phi" else "G"
    part <- worker_result$Coefficients[
      order(worker_result$Coefficients$Stratum, method = "radix"),
      , drop = FALSE
    ]
    values <- part[[coefficient]]
    names(values) <- part$Stratum
    ready <- nrow(vector) == 1L && vector$AllStrataReturned[[1L]] &&
      all(is.finite(values)) &&
      identical(length(values), vector$StratumCount[[1L]])
    if (!ready) stop("A planned metric vector is incomplete.", call. = FALSE)
    payload <- list(
      ContractHash = input$Contract$ContractHash,
      MetricRequestHash = request$RequestHash[[1L]],
      Values = values, CoefficientHashes = part$CoefficientHash,
      WorkerMetricVectorHash = vector$MetricVectorHash[[1L]]
    )
    data.frame(
      MetricRequestId = request$MetricRequestId,
      MetricRequestHash = request$RequestHash,
      BackendRequestId = request$BackendRequestId,
      RouteUnitId = request$RouteUnitId,
      ScenarioId = request$ScenarioId,
      Replicate = request$Replicate,
      RouteId = request$RouteId,
      EstimandId = request$EstimandId,
      StratumCount = length(values),
      StratumNames = paste(names(values), collapse = "|"),
      ValuesCanonical = paste(
        format(values, digits = 17L, scientific = TRUE, trim = TRUE),
        collapse = "|"
      ),
      MinimumValue = min(values), MaximumValue = max(values),
      MetricComputed = TRUE, TerminalState = "complete_nonpromoting",
      ScalarPoolingApplied = FALSE, RecoveryEvidenceComputed = FALSE,
      MetricResultHash = mfrmr_gtds3ac_hash(payload),
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ac_fit_result <- function(
    backend_request, worker_result = NULL, terminal_state, input,
    error_text = "") {
  success <- !is.null(worker_result)
  receipts <- if (success) worker_result$FitReceipts else NULL
  payload <- list(
    ContractHash = input$Contract$ContractHash,
    BackendRequestHash = backend_request$RequestHash[[1L]],
    TerminalState = terminal_state,
    FitReceiptHashes = if (success) receipts$FitReceiptHash else character(),
    ErrorText = error_text
  )
  data.frame(
    BackendRequestId = backend_request$BackendRequestId,
    BackendRequestHash = backend_request$RequestHash,
    RouteUnitId = backend_request$RouteUnitId,
    DatasetId = backend_request$DatasetId,
    ScenarioId = backend_request$ScenarioId,
    Replicate = backend_request$Replicate,
    RouteId = backend_request$RouteId,
    ModelSpecificationId = backend_request$ModelSpecificationId,
    BackendCallMade = terminal_state !=
      "not_attempted_generation_dependency",
    FitReturned = success,
    FitCallCount = if (success) nrow(receipts) else 0L,
    SingularFitCallCount = if (success) sum(receipts$Singular) else 0L,
    WarningFitCallCount = if (success) sum(receipts$WarningCount > 0L) else 0L,
    ConvergenceMessageFitCallCount = if (success) {
      sum(nzchar(receipts$ConvergenceMessage))
    } else 0L,
    DiagnosticOverrideApplied = FALSE,
    TerminalState = terminal_state,
    ErrorText = error_text,
    RecoveryEvidenceComputed = FALSE,
    FitResultHash = mfrmr_gtds3ac_hash(payload),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ac_checkpoint_hash <- function(checkpoint) {
  generation_hash <- if (is.null(checkpoint$PlannedGeneration)) {
    NA_character_
  } else checkpoint$PlannedGeneration$PlannedGenerationHash
  mfrmr_gtds3ac_hash(list(
    ContractHash = checkpoint$ContractHash,
    LaunchInputHash = checkpoint$LaunchInputHash,
    DatasetId = checkpoint$DatasetId,
    GenerationRequestHash = checkpoint$GenerationRequestHash,
    PlannedGenerationHash = generation_hash,
    DatasetTerminalReceiptHash =
      checkpoint$DatasetTerminalReceipt$TerminalReceiptHash,
    RouteTerminalReceiptHashes =
      checkpoint$RouteTerminalReceiptRegistry$TerminalReceiptHash,
    FitResultHashes = checkpoint$FitResultRegistry$FitResultHash,
    MetricResultHashes = checkpoint$MetricResultRegistry$MetricResultHash,
    FittedCoefficientHashes = checkpoint$FittedCoefficientRegistry$
      CoefficientHash,
    CheckpointOrigin = checkpoint$CheckpointOrigin,
    CallerRngStateRestored = checkpoint$CallerRngStateRestored,
    RecoveryEvidenceComputed = checkpoint$RecoveryEvidenceComputed
  ))
}

mfrmr_gtds3ac_failure_checkpoint <- function(
    dataset_id, input, terminal_state, evidence_text,
    checkpoint_origin = "child_complete", rng_opened = TRUE) {
  request_manifest <- input$RequestManifest
  generation_request <- request_manifest$GenerationRequestRegistry[
    request_manifest$GenerationRequestRegistry$DatasetId == dataset_id,
    , drop = FALSE
  ]
  terminal <- request_manifest$TerminalOrchestrationRequestRegistry
  dataset_terminal <- terminal[
    terminal$UnitType == "dataset" & terminal$UnitId == dataset_id,
    , drop = FALSE
  ]
  evidence_hash <- mfrmr_gtds3ac_hash(list(
    DatasetId = dataset_id, TerminalState = terminal_state,
    EvidenceText = evidence_text
  ))
  dataset_receipt <- mfrmr_gtds3ac_terminal_receipt(
    dataset_terminal, input, terminal_state, evidence_hash,
    TRUE, rng_opened, FALSE, FALSE, FALSE, FALSE, evidence_text
  )
  backend <- request_manifest$BackendRequestRegistry[
    request_manifest$BackendRequestRegistry$DatasetId == dataset_id,
    , drop = FALSE
  ]
  route_receipts <- list(); fits <- list(); metrics <- list()
  for (index in seq_len(nrow(backend))) {
    request <- backend[index, , drop = FALSE]
    route_terminal <- terminal[
      terminal$UnitType == "route" &
        terminal$UnitId == request$RouteUnitId[[1L]], , drop = FALSE
    ]
    route_receipts[[index]] <- mfrmr_gtds3ac_terminal_receipt(
      route_terminal, input, "not_attempted_generation_dependency",
      evidence_hash, FALSE, rng_opened, FALSE, FALSE, FALSE, FALSE,
      paste0("dataset_terminal:", terminal_state)
    )
    fits[[index]] <- mfrmr_gtds3ac_fit_result(
      request, terminal_state = "not_attempted_generation_dependency",
      input = input, error_text = evidence_text
    )
    metrics[[index]] <- mfrmr_gtds3ac_failed_metric_results(
      request, request_manifest, "not_attempted_generation_dependency", input
    )
  }
  route_receipts <- if (length(route_receipts)) {
    do.call(rbind, route_receipts)
  } else dataset_receipt[FALSE, ]
  fit_results <- if (length(fits)) do.call(rbind, fits) else data.frame()
  metric_results <- if (length(metrics)) do.call(rbind, metrics) else data.frame()
  checkpoint <- structure(list(
    ContractHash = input$Contract$ContractHash,
    LaunchInputHash = input$LaunchInputHash,
    DatasetId = dataset_id,
    GenerationRequestId = generation_request$GenerationRequestId[[1L]],
    GenerationRequestHash = generation_request$RequestHash[[1L]],
    DataSeed = generation_request$DataSeed[[1L]],
    PlannedGeneration = NULL,
    DatasetTerminalReceipt = dataset_receipt,
    RouteTerminalReceiptRegistry = route_receipts,
    FitResultRegistry = fit_results,
    MetricResultRegistry = metric_results,
    FittedCoefficientRegistry = data.frame(),
    CheckpointOrigin = checkpoint_origin,
    CallerRngStateRestored = if (
      checkpoint_origin == "child_complete"
    ) TRUE else NA,
    RecoveryEvidenceComputed = FALSE,
    PublicSupportReady = FALSE
  ), class = c("mfrmr_gtds3ac_checkpoint", "list"))
  checkpoint$CheckpointHash <- mfrmr_gtds3ac_checkpoint_hash(checkpoint)
  checkpoint
}

mfrmr_gtds3ac_execute_dataset <- function(
    dataset_id, input, source_root, progress_path) {
  mfrmr_gtds3ac_assert_launch_input(input, source_root)
  request_manifest <- input$RequestManifest
  generation_request <- request_manifest$GenerationRequestRegistry[
    request_manifest$GenerationRequestRegistry$DatasetId == dataset_id,
    , drop = FALSE
  ]
  if (nrow(generation_request) != 1L) {
    stop("One exact bounded-launch dataset is required.", call. = FALSE)
  }
  paths <- mfrmr_gtds3ac_evidence_paths(source_root)
  before_rng <- mfrmr_gtds3ac_rng_snapshot()
  mfrmr_gtds3ac_write_progress(
    progress_path, input, dataset_id, "generation_started"
  )
  generated <- tryCatch(
    mfrmr_gtds3aa_execute_request(
      generation_request$GenerationRequestId[[1L]], request_manifest,
      input$AdapterManifest, input$ReadinessManifest,
      paths[["generator"]]
    ),
    error = function(condition) condition
  )
  if (inherits(generated, "error")) {
    checkpoint <- mfrmr_gtds3ac_failure_checkpoint(
      dataset_id, input, "generation_failure",
      conditionMessage(generated), "child_complete", TRUE
    )
    checkpoint$CallerRngStateRestored <-
      mfrmr_gtds3ac_rng_restored(before_rng)
    checkpoint$CheckpointHash <- mfrmr_gtds3ac_checkpoint_hash(checkpoint)
    return(checkpoint)
  }
  mfrmr_gtds3aa_assert_planned_generation(
    generated, request_manifest, input$AdapterManifest,
    input$ReadinessManifest
  )
  mfrmr_gtds3ac_write_progress(
    progress_path, input, dataset_id, "generation_complete"
  )
  terminal <- request_manifest$TerminalOrchestrationRequestRegistry
  dataset_terminal <- terminal[
    terminal$UnitType == "dataset" & terminal$UnitId == dataset_id,
    , drop = FALSE
  ]
  dataset_receipt <- mfrmr_gtds3ac_terminal_receipt(
    dataset_terminal, input, "generation_complete",
    generated$PlannedGenerationHash, TRUE, TRUE, TRUE,
    FALSE, FALSE, FALSE
  )
  backend <- request_manifest$BackendRequestRegistry[
    request_manifest$BackendRequestRegistry$DatasetId == dataset_id,
    , drop = FALSE
  ]
  plan <- mfrmr_gtds3p_plan()
  view <- mfrmr_gtds3ac_execution_view(generated)
  route_receipts <- list(); fit_results <- list(); metric_results <- list()
  coefficients <- list()
  if (nrow(backend) > 0L) {
    semantics <- mfrmr_gtds3s_manifest()
    truth <- mfrmr_gtds3t_manifest(semantics_manifest = semantics)
    operator <- mfrmr_gtds3o_project_profile(
      generated$ScenarioId, truth_manifest = truth,
      semantics_manifest = semantics, validate = FALSE
    )
    for (index in seq_len(nrow(backend))) {
      request <- backend[index, , drop = FALSE]
      route_unit <- plan$RouteUnitRegistry[
        plan$RouteUnitRegistry$RouteUnitId == request$RouteUnitId[[1L]],
        , drop = FALSE
      ]
      route_terminal <- terminal[
        terminal$UnitType == "route" &
          terminal$UnitId == request$RouteUnitId[[1L]], , drop = FALSE
      ]
      mfrmr_gtds3ac_write_progress(
        progress_path, input, dataset_id, "route_fit_started",
        request$RouteUnitId[[1L]]
      )
      worker_result <- tryCatch(
        mfrmr_gtds3w_fit_template(
          view, route_unit, request, operator
        ),
        error = function(condition) condition
      )
      if (inherits(worker_result, "error")) {
        error_text <- conditionMessage(worker_result)
        fit_results[[index]] <- mfrmr_gtds3ac_fit_result(
          request, terminal_state = "fit_failure", input = input,
          error_text = error_text
        )
        metric_results[[index]] <- mfrmr_gtds3ac_failed_metric_results(
          request, request_manifest, "fit_failure", input
        )
        evidence_hash <- fit_results[[index]]$FitResultHash[[1L]]
        route_receipts[[index]] <- mfrmr_gtds3ac_terminal_receipt(
          route_terminal, input, "fit_failure", evidence_hash,
          TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, error_text
        )
        next
      }
      metrics <- tryCatch(
        mfrmr_gtds3ac_success_metric_results(
          request, worker_result, request_manifest, input
        ),
        error = function(condition) condition
      )
      if (inherits(metrics, "error")) {
        error_text <- conditionMessage(metrics)
        fit_results[[index]] <- mfrmr_gtds3ac_fit_result(
          request, worker_result, "metric_failure", input
        )
        metric_results[[index]] <- mfrmr_gtds3ac_failed_metric_results(
          request, request_manifest, "metric_failure", input
        )
        evidence_hash <- mfrmr_gtds3ac_hash(list(
          FitResultHash = fit_results[[index]]$FitResultHash[[1L]],
          ErrorText = error_text
        ))
        route_receipts[[index]] <- mfrmr_gtds3ac_terminal_receipt(
          route_terminal, input, "metric_failure", evidence_hash,
          TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, error_text
        )
        next
      }
      fit_results[[index]] <- mfrmr_gtds3ac_fit_result(
        request, worker_result, "complete_nonpromoting", input
      )
      metric_results[[index]] <- metrics
      coefficient <- worker_result$Coefficients
      coefficient$BackendRequestId <- request$BackendRequestId[[1L]]
      coefficient$BackendRequestHash <- request$RequestHash[[1L]]
      coefficient$RouteUnitId <- request$RouteUnitId[[1L]]
      coefficient$DatasetId <- request$DatasetId[[1L]]
      coefficient$Replicate <- request$Replicate[[1L]]
      coefficient$Planned856Identity <- TRUE
      coefficient$CountsAsExploratoryResult <- TRUE
      coefficient$RecoveryEvidenceComputed <- FALSE
      coefficients[[index]] <- coefficient
      evidence_hash <- mfrmr_gtds3ac_hash(list(
        FitResultHash = fit_results[[index]]$FitResultHash[[1L]],
        MetricResultHashes = metrics$MetricResultHash
      ))
      route_receipts[[index]] <- mfrmr_gtds3ac_terminal_receipt(
        route_terminal, input, "complete_nonpromoting", evidence_hash,
        TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
      )
      mfrmr_gtds3ac_write_progress(
        progress_path, input, dataset_id, "route_complete",
        request$RouteUnitId[[1L]]
      )
    }
  }
  route_receipts <- if (length(route_receipts)) {
    do.call(rbind, route_receipts)
  } else dataset_receipt[FALSE, ]
  fits <- if (length(fit_results)) do.call(rbind, fit_results) else data.frame()
  metrics <- if (length(metric_results)) {
    do.call(rbind, metric_results)
  } else data.frame()
  coefficients <- if (length(coefficients)) {
    do.call(rbind, coefficients)
  } else data.frame()
  row.names(route_receipts) <- row.names(fits) <- row.names(metrics) <-
    row.names(coefficients) <- NULL
  checkpoint <- structure(list(
    ContractHash = input$Contract$ContractHash,
    LaunchInputHash = input$LaunchInputHash,
    DatasetId = dataset_id,
    GenerationRequestId = generation_request$GenerationRequestId[[1L]],
    GenerationRequestHash = generation_request$RequestHash[[1L]],
    DataSeed = generation_request$DataSeed[[1L]],
    PlannedGeneration = generated,
    DatasetTerminalReceipt = dataset_receipt,
    RouteTerminalReceiptRegistry = route_receipts,
    FitResultRegistry = fits,
    MetricResultRegistry = metrics,
    FittedCoefficientRegistry = coefficients,
    CheckpointOrigin = "child_complete",
    CallerRngStateRestored = mfrmr_gtds3ac_rng_restored(before_rng),
    RecoveryEvidenceComputed = FALSE,
    PublicSupportReady = FALSE
  ), class = c("mfrmr_gtds3ac_checkpoint", "list"))
  checkpoint$CheckpointHash <- mfrmr_gtds3ac_checkpoint_hash(checkpoint)
  mfrmr_gtds3ac_write_progress(
    progress_path, input, dataset_id, "checkpoint_ready"
  )
  checkpoint
}

mfrmr_gtds3ac_assert_checkpoint <- function(
    checkpoint, input, source_root) {
  if (!inherits(checkpoint, "mfrmr_gtds3ac_checkpoint") ||
      !identical(names(checkpoint), c(
        "ContractHash", "LaunchInputHash", "DatasetId",
        "GenerationRequestId", "GenerationRequestHash", "DataSeed",
        "PlannedGeneration", "DatasetTerminalReceipt",
        "RouteTerminalReceiptRegistry", "FitResultRegistry",
        "MetricResultRegistry", "FittedCoefficientRegistry",
        "CheckpointOrigin", "CallerRngStateRestored",
        "RecoveryEvidenceComputed", "PublicSupportReady",
        "CheckpointHash"
      ))) {
    stop("A typed D-SIM-3 dataset checkpoint is required.", call. = FALSE)
  }
  request_manifest <- input$RequestManifest
  generation_request <- request_manifest$GenerationRequestRegistry[
    request_manifest$GenerationRequestRegistry$DatasetId ==
      checkpoint$DatasetId, , drop = FALSE
  ]
  backend <- request_manifest$BackendRequestRegistry[
    request_manifest$BackendRequestRegistry$DatasetId ==
      checkpoint$DatasetId, , drop = FALSE
  ]
  metrics_expected <- request_manifest$MetricRequestRegistry[
    request_manifest$MetricRequestRegistry$BackendRequestId %in%
      backend$BackendRequestId, , drop = FALSE
  ]
  receipts <- rbind(
    checkpoint$DatasetTerminalReceipt,
    checkpoint$RouteTerminalReceiptRegistry
  )
  terminal_expected <- request_manifest$TerminalOrchestrationRequestRegistry[
    request_manifest$TerminalOrchestrationRequestRegistry$UnitId %in%
      c(checkpoint$DatasetId, backend$RouteUnitId), , drop = FALSE
  ]
  terminal_expected <- terminal_expected[match(
    receipts$TerminalRequestId, terminal_expected$TerminalRequestId
  ), , drop = FALSE]
  allowed <- mapply(function(state, values) {
    state %in% strsplit(values, "|", fixed = TRUE)[[1L]]
  }, receipts$TerminalState, terminal_expected$AllowedTerminalStates)
  successful_generation <- identical(
    checkpoint$DatasetTerminalReceipt$TerminalState,
    "generation_complete"
  )
  generation_valid <- if (successful_generation) {
    if (is.null(checkpoint$PlannedGeneration)) FALSE else {
      paths <- mfrmr_gtds3ac_evidence_paths(source_root)
      tryCatch({
        mfrmr_gtds3aa_assert_planned_generation(
          checkpoint$PlannedGeneration, request_manifest,
          input$AdapterManifest, input$ReadinessManifest
        )
        identical(
          checkpoint$PlannedGeneration$GenerationRequestHash,
          generation_request$RequestHash[[1L]]
        ) && identical(
          checkpoint$PlannedGeneration$DataSeed,
          generation_request$DataSeed[[1L]]
        ) && file.exists(paths[["generator"]])
      }, error = function(condition) FALSE)
    }
  } else is.null(checkpoint$PlannedGeneration)
  fit_ids <- if (nrow(backend)) {
    checkpoint$FitResultRegistry$BackendRequestId
  } else character()
  metric_ids <- if (nrow(metrics_expected)) {
    checkpoint$MetricResultRegistry$MetricRequestId
  } else character()
  coefficient_valid <- nrow(checkpoint$FittedCoefficientRegistry) == 0L ||
    (all(checkpoint$FittedCoefficientRegistry$BackendRequestId %in%
           backend$BackendRequestId) &&
       all(checkpoint$FittedCoefficientRegistry$Planned856Identity) &&
       all(checkpoint$FittedCoefficientRegistry$CountsAsExploratoryResult) &&
       all(!checkpoint$FittedCoefficientRegistry$RecoveryEvidenceComputed))
  valid <- identical(checkpoint$ContractHash, input$Contract$ContractHash) &&
    identical(checkpoint$LaunchInputHash, input$LaunchInputHash) &&
    nrow(generation_request) == 1L &&
    identical(checkpoint$GenerationRequestId,
              generation_request$GenerationRequestId[[1L]]) &&
    identical(checkpoint$GenerationRequestHash,
              generation_request$RequestHash[[1L]]) &&
    identical(checkpoint$DataSeed, generation_request$DataSeed[[1L]]) &&
    checkpoint$DataSeed >= input$Contract$PlannedSeedMinimum &&
    checkpoint$DataSeed <= input$Contract$PlannedSeedMaximum &&
    generation_valid && nrow(receipts) == 1L + nrow(backend) &&
    !anyDuplicated(receipts$TerminalRequestId) &&
    identical(receipts$TerminalRequestId, terminal_expected$TerminalRequestId) &&
    all(allowed) && all(receipts$CountsIn856Denominator) &&
    all(!receipts$HistoricalReceiptInherited) &&
    all(!receipts$RecoveryEvidenceComputed) &&
    all(!receipts$PublicSupportPromoted) &&
    identical(nrow(checkpoint$FitResultRegistry), nrow(backend)) &&
    setequal(fit_ids, backend$BackendRequestId) &&
    identical(nrow(checkpoint$MetricResultRegistry), nrow(metrics_expected)) &&
    setequal(metric_ids, metrics_expected$MetricRequestId) &&
    all(!checkpoint$FitResultRegistry$DiagnosticOverrideApplied) &&
    all(!checkpoint$FitResultRegistry$RecoveryEvidenceComputed) &&
    all(!checkpoint$MetricResultRegistry$ScalarPoolingApplied) &&
    all(!checkpoint$MetricResultRegistry$RecoveryEvidenceComputed) &&
    coefficient_valid &&
    checkpoint$CheckpointOrigin %in% c(
      "child_complete", "parent_process_failure"
    ) &&
    (checkpoint$CheckpointOrigin != "child_complete" ||
       isTRUE(checkpoint$CallerRngStateRestored)) &&
    !isTRUE(checkpoint$RecoveryEvidenceComputed) &&
    !isTRUE(checkpoint$PublicSupportReady) &&
    identical(checkpoint$CheckpointHash,
              mfrmr_gtds3ac_checkpoint_hash(checkpoint))
  if (!valid) {
    stop("The D-SIM-3 dataset checkpoint was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3ac_process_receipt <- function(
    dataset_id, input, outcome, exit_status, elapsed_seconds,
    peak_rss_mib, memory_observed, completion_marker_observed,
    stdout = "", stderr = "") {
  payload <- list(
    ContractHash = input$Contract$ContractHash,
    LaunchInputHash = input$LaunchInputHash,
    DatasetId = dataset_id, Outcome = outcome,
    ExitStatus = as.integer(exit_status),
    ElapsedSeconds = as.numeric(elapsed_seconds),
    PeakRssMiB = as.numeric(peak_rss_mib),
    MemoryObserved = isTRUE(memory_observed),
    CompletionMarkerObserved = isTRUE(completion_marker_observed),
    StdoutHash = mfrmr_gtds3ac_hash(stdout),
    StderrHash = mfrmr_gtds3ac_hash(stderr)
  )
  structure(c(payload, list(
    ProcessReceiptHash = mfrmr_gtds3ac_hash(payload)
  )), class = c("mfrmr_gtds3ac_process_receipt", "list"))
}

mfrmr_gtds3ac_run_dataset_process <- function(
    dataset_id, input_path, result_path, source_root, progress_path,
    worker_path, input) {
  if (!requireNamespace("processx", quietly = TRUE)) {
    stop("The bounded launch requires `processx`.", call. = FALSE)
  }
  scope <- input$Contract$ResourceRegistry[
    input$Contract$ResourceRegistry$ScopeId == "one_dataset_pipeline",
    , drop = FALSE
  ]
  rscript <- normalizePath(
    file.path(R.home("bin"), "Rscript"), mustWork = TRUE
  )
  process <- processx::process$new(
    rscript,
    c(
      "--vanilla", normalizePath(worker_path, mustWork = TRUE),
      normalizePath(input_path, mustWork = TRUE), dataset_id, result_path,
      normalizePath(source_root, mustWork = TRUE), progress_path
    ),
    stdout = "|", stderr = "|", cleanup = TRUE, cleanup_tree = TRUE,
    supervise = FALSE
  )
  on.exit(if (process$is_alive()) try(process$kill_tree(), silent = TRUE),
          add = TRUE)
  started <- unname(proc.time()[["elapsed"]])
  peak_rss_mib <- 0
  memory_observed <- FALSE
  trigger <- ""
  while (process$is_alive()) {
    memory <- tryCatch(
      process$get_memory_info(), error = function(condition) NULL
    )
    if (!is.null(memory) && "rss" %in% names(memory) &&
        is.finite(memory[["rss"]])) {
      memory_observed <- TRUE
      peak_rss_mib <- max(peak_rss_mib, memory[["rss"]] / 1024^2)
    }
    elapsed <- unname(proc.time()[["elapsed"]]) - started
    if (memory_observed &&
        peak_rss_mib > scope$MaximumPeakRssMiB[[1L]]) {
      trigger <- "peak_rss_limit"
    } else if (elapsed > scope$MaximumWallSeconds[[1L]]) {
      trigger <- "wall_time_limit"
    }
    if (nzchar(trigger)) {
      try(process$kill_tree(), silent = TRUE)
      break
    }
    Sys.sleep(0.1)
  }
  if (process$is_alive()) process$wait(timeout = 10000L)
  elapsed <- unname(proc.time()[["elapsed"]]) - started
  stdout <- tryCatch(process$read_all_output(), error = function(condition) "")
  stderr <- tryCatch(process$read_all_error(), error = function(condition) "")
  exit_status <- tryCatch(
    process$get_exit_status(), error = function(condition) NA_integer_
  )
  marker <- grepl(
    paste0("DSIM3_BOUNDED_DATASET_COMPLETE ", dataset_id),
    stdout, fixed = TRUE
  )
  outcome <- if (nzchar(trigger)) trigger else if (
    identical(as.integer(exit_status), 0L) && marker && file.exists(result_path)
  ) "success" else "worker_failure"
  receipt <- mfrmr_gtds3ac_process_receipt(
    dataset_id, input, outcome, exit_status, elapsed,
    peak_rss_mib, memory_observed, marker, stdout, stderr
  )
  list(
    Outcome = outcome, Receipt = receipt,
    Stdout = stdout, Stderr = stderr
  )
}

mfrmr_gtds3ac_checkpoint_path <- function(directory, dataset_id) {
  file.path(directory, paste0(dataset_id, ".rds"))
}

mfrmr_gtds3ac_process_path <- function(directory, dataset_id) {
  file.path(directory, paste0(dataset_id, "-process.rds"))
}

mfrmr_gtds3ac_frozen_no_call_registry <- function(
    plan = mfrmr_gtds3p_plan()) {
  routes <- plan$RouteUnitRegistry[
    plan$RouteUnitRegistry$PlannedDisposition != "qualification_candidate",
    , drop = FALSE
  ]
  data.frame(
    RouteUnitId = routes$RouteUnitId,
    DatasetId = routes$DatasetId,
    ScenarioId = routes$ScenarioId,
    Replicate = routes$Replicate,
    RouteId = routes$RouteId,
    PlannedDisposition = routes$PlannedDisposition,
    FrozenTerminalState = routes$FrozenNoCallTerminalState,
    CountsInRouteDenominator = routes$CountsInRouteDenominator,
    ExecutionAttempted = FALSE,
    NewTerminalReceiptIssued = FALSE,
    HistoricalReceiptInherited = FALSE,
    FrozenPlanSemanticsPreserved = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ac_coordinate_registry <- function(
    metric_results, plan = mfrmr_gtds3p_plan()) {
  coordinates <- plan$RouteEstimandCoordinateRegistry
  metric_index <- match(
    paste(coordinates$RouteUnitId, coordinates$EstimandId, sep = "::"),
    paste(metric_results$RouteUnitId, metric_results$EstimandId, sep = "::")
  )
  candidate <- !is.na(metric_index)
  data.frame(
    CoordinateId = coordinates$CoordinateId,
    RouteUnitId = coordinates$RouteUnitId,
    DatasetId = coordinates$DatasetId,
    ScenarioId = coordinates$ScenarioId,
    Replicate = coordinates$Replicate,
    RouteId = coordinates$RouteId,
    EstimandId = coordinates$EstimandId,
    CandidateExecutionCoordinate = candidate,
    MetricRequestId = ifelse(
      candidate, metric_results$MetricRequestId[metric_index], NA_character_
    ),
    MetricResultHash = ifelse(
      candidate, metric_results$MetricResultHash[metric_index], NA_character_
    ),
    MetricComputed = ifelse(
      candidate, metric_results$MetricComputed[metric_index], FALSE
    ),
    FrozenNoCallCoordinate = !candidate,
    CountsInCoordinateDenominator = TRUE,
    RecoveryEvidenceComputed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ac_manifest_fields <- function() {
  c(
    "Contract", "LaunchInputHash", "CheckpointRegistry",
    "ProcessReceiptRegistry", "DatasetTerminalReceiptRegistry",
    "RouteTerminalReceiptRegistry", "FitResultRegistry",
    "MetricResultRegistry", "FittedCoefficientRegistry",
    "FrozenNoCallRouteRegistry", "CoordinateDispositionRegistry",
    "Summary"
  )
}

mfrmr_gtds3ac_finalize <- function(
    checkpoints, process_receipts, input, source_root) {
  if (length(checkpoints) != input$Contract$ExpectedDatasetAttemptCount ||
      length(process_receipts) != length(checkpoints)) {
    stop("All registered D-SIM-3 checkpoints are required.", call. = FALSE)
  }
  for (checkpoint in checkpoints) {
    mfrmr_gtds3ac_assert_checkpoint(checkpoint, input, source_root)
  }
  request <- input$RequestManifest$GenerationRequestRegistry
  checkpoint_ids <- vapply(
    checkpoints, function(value) value$DatasetId, character(1L)
  )
  checkpoints <- checkpoints[match(request$DatasetId, checkpoint_ids)]
  process_ids <- vapply(
    process_receipts, function(value) value$DatasetId, character(1L)
  )
  process_receipts <- process_receipts[
    match(request$DatasetId, process_ids)
  ]
  checkpoint_registry <- data.frame(
    CheckpointOrdinal = seq_along(checkpoints),
    DatasetId = request$DatasetId,
    GenerationRequestId = request$GenerationRequestId,
    DataSeed = request$DataSeed,
    CheckpointHash = vapply(
      checkpoints, function(value) value$CheckpointHash, character(1L)
    ),
    CheckpointOrigin = vapply(
      checkpoints, function(value) value$CheckpointOrigin, character(1L)
    ),
    stringsAsFactors = FALSE
  )
  process_registry <- data.frame(
    ProcessReceiptOrdinal = seq_along(process_receipts),
    DatasetId = request$DatasetId,
    Outcome = vapply(
      process_receipts, function(value) value$Outcome, character(1L)
    ),
    ExitStatus = vapply(
      process_receipts, function(value) value$ExitStatus, integer(1L)
    ),
    ElapsedSeconds = vapply(
      process_receipts, function(value) value$ElapsedSeconds, numeric(1L)
    ),
    PeakRssMiB = vapply(
      process_receipts, function(value) value$PeakRssMiB, numeric(1L)
    ),
    MemoryObserved = vapply(
      process_receipts, function(value) value$MemoryObserved, logical(1L)
    ),
    CompletionMarkerObserved = vapply(
      process_receipts,
      function(value) value$CompletionMarkerObserved, logical(1L)
    ),
    ProcessReceiptHash = vapply(
      process_receipts,
      function(value) value$ProcessReceiptHash, character(1L)
    ),
    stringsAsFactors = FALSE
  )
  dataset_receipts <- do.call(rbind, lapply(
    checkpoints, function(value) value$DatasetTerminalReceipt
  ))
  route_receipts <- do.call(rbind, lapply(
    checkpoints, function(value) value$RouteTerminalReceiptRegistry
  ))
  fits <- do.call(rbind, lapply(
    checkpoints, function(value) value$FitResultRegistry
  ))
  metrics <- do.call(rbind, lapply(
    checkpoints, function(value) value$MetricResultRegistry
  ))
  coefficient_parts <- lapply(
    checkpoints, function(value) value$FittedCoefficientRegistry
  )
  coefficient_parts <- coefficient_parts[
    vapply(coefficient_parts, nrow, integer(1L)) > 0L
  ]
  coefficients <- if (length(coefficient_parts)) {
    do.call(rbind, coefficient_parts)
  } else data.frame()
  for (value in list(
    dataset_receipts, route_receipts, fits, metrics, coefficients
  )) row.names(value) <- NULL
  frozen <- mfrmr_gtds3ac_frozen_no_call_registry()
  coordinates <- mfrmr_gtds3ac_coordinate_registry(metrics)
  summary <- list(
    DatasetAttemptCount = nrow(checkpoint_registry),
    DatasetGenerationCompleteCount = sum(
      dataset_receipts$TerminalState == "generation_complete"
    ),
    DatasetGenerationFailureCount = sum(
      dataset_receipts$TerminalState == "generation_failure"
    ),
    DatasetGenerationResourceLimitCount = sum(
      dataset_receipts$TerminalState == "generation_resource_limit"
    ),
    CandidateRouteAttemptCount = nrow(route_receipts),
    CandidateRouteCompleteCount = sum(
      route_receipts$TerminalState == "complete_nonpromoting"
    ),
    CandidateRouteFailureCount = sum(
      route_receipts$TerminalState != "complete_nonpromoting"
    ),
    FrozenNoCallRouteCount = nrow(frozen),
    CompleteRouteDenominatorCount = nrow(route_receipts) + nrow(frozen),
    MetricRequestCount = nrow(metrics),
    ComputedMetricRequestCount = sum(metrics$MetricComputed),
    CoordinateDenominatorCount = nrow(coordinates),
    TerminalReceiptCount = nrow(dataset_receipts) + nrow(route_receipts),
    ExactlyOneTerminalReceiptPerExactRequest = !anyDuplicated(c(
      dataset_receipts$TerminalRequestId,
      route_receipts$TerminalRequestId
    )),
    SuccessfulChildProcessCount = sum(process_registry$Outcome == "success"),
    TotalFitCallCount = sum(fits$FitCallCount),
    SingularFitCallCount = sum(fits$SingularFitCallCount),
    WarningFitCallCount = sum(fits$WarningFitCallCount),
    ConvergenceMessageFitCallCount =
      sum(fits$ConvergenceMessageFitCallCount),
    Planned856RngStreamOpened = any(
      dataset_receipts$Planned856RngStreamOpened
    ),
    ExploratoryResponseGenerated = any(
      dataset_receipts$ExploratoryResponseGenerated
    ),
    ExploratoryBackendCallMade = any(
      route_receipts$BackendCallMade %in% TRUE
    ),
    ExploratoryFitReturned = any(route_receipts$FitReturned %in% TRUE),
    ExploratoryMetricComputed = any(route_receipts$MetricComputed %in% TRUE),
    ExploratoryExecutionComplete = TRUE,
    RecoveryAnalysisInputReady = TRUE,
    RecoveryEvidenceComputed = FALSE,
    SimulationValidationReady = FALSE,
    ConfirmationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    CurrentDisposition = "bounded_exploratory_execution_complete_unadjudicated",
    NextAction = paste(
      "compute prespecified descriptive recovery and failure-denominator",
      "summaries from the immutable exploratory checkpoints without route",
      "voting, adaptive exclusion, or support promotion"
    )
  )
  payload <- list(
    Contract = input$Contract,
    LaunchInputHash = input$LaunchInputHash,
    CheckpointRegistry = checkpoint_registry,
    ProcessReceiptRegistry = process_registry,
    DatasetTerminalReceiptRegistry = dataset_receipts,
    RouteTerminalReceiptRegistry = route_receipts,
    FitResultRegistry = fits,
    MetricResultRegistry = metrics,
    FittedCoefficientRegistry = coefficients,
    FrozenNoCallRouteRegistry = frozen,
    CoordinateDispositionRegistry = coordinates,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3ac_hash(payload)
  )), class = c("mfrmr_gtds3ac_manifest", "list"))
  mfrmr_gtds3ac_assert_manifest(manifest, input)
  manifest
}

mfrmr_gtds3ac_assert_manifest <- function(manifest, input) {
  fields <- mfrmr_gtds3ac_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3ac_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 bounded-launch manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  checkpoints <- manifest$CheckpointRegistry
  processes <- manifest$ProcessReceiptRegistry
  datasets <- manifest$DatasetTerminalReceiptRegistry
  routes <- manifest$RouteTerminalReceiptRegistry
  fits <- manifest$FitResultRegistry
  metrics <- manifest$MetricResultRegistry
  frozen <- manifest$FrozenNoCallRouteRegistry
  coordinates <- manifest$CoordinateDispositionRegistry
  summary <- manifest$Summary
  terminal_ids <- c(datasets$TerminalRequestId, routes$TerminalRequestId)
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3ac_hash(manifest[fields])
  ) && identical(contract, input$Contract) &&
    identical(manifest$LaunchInputHash, input$LaunchInputHash) &&
    identical(nrow(checkpoints), 42L) &&
    !anyDuplicated(checkpoints$DatasetId) &&
    identical(nrow(processes), 42L) &&
    identical(processes$DatasetId, checkpoints$DatasetId) &&
    identical(nrow(datasets), 42L) &&
    identical(nrow(routes), 50L) && identical(nrow(fits), 50L) &&
    identical(nrow(metrics), 100L) && identical(nrow(frozen), 160L) &&
    identical(nrow(coordinates), 420L) &&
    identical(length(terminal_ids), 92L) && !anyDuplicated(terminal_ids) &&
    setequal(
      terminal_ids,
      input$RequestManifest$TerminalOrchestrationRequestRegistry$
        TerminalRequestId
    ) && all(datasets$CountsIn856Denominator) &&
    all(routes$CountsIn856Denominator) &&
    all(!datasets$HistoricalReceiptInherited) &&
    all(!routes$HistoricalReceiptInherited) &&
    setequal(
      fits$BackendRequestId,
      input$RequestManifest$BackendRequestRegistry$BackendRequestId
    ) && setequal(
      metrics$MetricRequestId,
      input$RequestManifest$MetricRequestRegistry$MetricRequestId
    ) && all(!fits$DiagnosticOverrideApplied) &&
    all(!fits$RecoveryEvidenceComputed) &&
    all(!metrics$ScalarPoolingApplied) &&
    all(!metrics$RecoveryEvidenceComputed) &&
    all(frozen$CountsInRouteDenominator) &&
    all(!frozen$ExecutionAttempted) &&
    all(!frozen$NewTerminalReceiptIssued) &&
    all(frozen$FrozenPlanSemanticsPreserved) &&
    all(coordinates$CountsInCoordinateDenominator) &&
    all(!coordinates$RecoveryEvidenceComputed) &&
    identical(summary$DatasetAttemptCount, 42L) &&
    identical(summary$CandidateRouteAttemptCount, 50L) &&
    identical(summary$FrozenNoCallRouteCount, 160L) &&
    identical(summary$CompleteRouteDenominatorCount, 210L) &&
    identical(summary$MetricRequestCount, 100L) &&
    identical(summary$CoordinateDenominatorCount, 420L) &&
    identical(summary$TerminalReceiptCount, 92L) &&
    isTRUE(summary$ExactlyOneTerminalReceiptPerExactRequest) &&
    isTRUE(summary$Planned856RngStreamOpened) &&
    isTRUE(summary$ExploratoryExecutionComplete) &&
    isTRUE(summary$RecoveryAnalysisInputReady) &&
    !isTRUE(summary$RecoveryEvidenceComputed) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$ConfirmationReady) &&
    !isTRUE(summary$PublicSupportReady) &&
    identical(summary$FeatureMaturity, "specified") &&
    identical(
      summary$CurrentDisposition,
      "bounded_exploratory_execution_complete_unadjudicated"
    )
  if (!valid) {
    stop("The D-SIM-3 bounded-launch manifest was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3ac_run <- function(input, output_dir, source_root) {
  mfrmr_gtds3ac_assert_launch_input(input, source_root)
  output_dir <- normalizePath(
    output_dir, mustWork = FALSE
  )
  if (!dir.exists(output_dir) &&
      !dir.create(output_dir, recursive = TRUE)) {
    stop("The bounded-launch directory could not be created.", call. = FALSE)
  }
  checkpoint_dir <- file.path(output_dir, "checkpoints")
  process_dir <- file.path(output_dir, "process-receipts")
  progress_dir <- file.path(output_dir, "progress")
  partial_dir <- file.path(output_dir, "partial")
  for (directory in c(
    checkpoint_dir, process_dir, progress_dir, partial_dir
  )) {
    if (!dir.exists(directory) &&
        !dir.create(directory, recursive = TRUE)) {
      stop("A bounded-launch subdirectory could not be created.",
           call. = FALSE)
    }
  }
  input_path <- file.path(output_dir, "launch-input.rds")
  if (file.exists(input_path)) {
    existing <- readRDS(input_path)
    if (!identical(existing, input)) {
      stop("The existing bounded-launch input identity differs.",
           call. = FALSE)
    }
  } else {
    mfrmr_gtds3ac_atomic_save(input, input_path)
  }
  validation <- file.path(
    normalizePath(source_root, mustWork = TRUE), "inst", "validation"
  )
  worker_path <- file.path(
    validation,
    "gtheory-multivariate-dsim3-bounded-exploratory-launch-worker-0.2.4.R"
  )
  request <- input$RequestManifest$GenerationRequestRegistry
  new_count <- resumed_count <- failure_count <- 0L
  for (index in seq_len(nrow(request))) {
    dataset_id <- request$DatasetId[[index]]
    checkpoint_path <- mfrmr_gtds3ac_checkpoint_path(
      checkpoint_dir, dataset_id
    )
    process_path <- mfrmr_gtds3ac_process_path(process_dir, dataset_id)
    progress_path <- file.path(progress_dir, paste0(dataset_id, ".rds"))
    partial_path <- file.path(partial_dir, paste0(dataset_id, ".rds"))
    if (file.exists(checkpoint_path)) {
      checkpoint <- readRDS(checkpoint_path)
      mfrmr_gtds3ac_assert_checkpoint(checkpoint, input, source_root)
      if (!file.exists(process_path)) {
        stop("A completed checkpoint lost its process receipt.",
             call. = FALSE)
      }
      resumed_count <- resumed_count + 1L
      cat("DSIM3_RESUME ", index, "/42 ", dataset_id, "\n", sep = "")
      next
    }
    if (file.exists(progress_path)) {
      if (file.exists(partial_path)) {
        partial <- readRDS(partial_path)
        mfrmr_gtds3ac_assert_checkpoint(partial, input, source_root)
        if (!file.exists(process_path)) {
          receipt <- mfrmr_gtds3ac_process_receipt(
            dataset_id, input, "recovered_completed_child", NA_integer_,
            NA_real_, NA_real_, FALSE, TRUE
          )
          mfrmr_gtds3ac_atomic_save(receipt, process_path)
        }
        mfrmr_gtds3ac_atomic_save(partial, checkpoint_path)
        resumed_count <- resumed_count + 1L
        cat("DSIM3_RECOVER_COMMITTED ", index, "/42 ", dataset_id,
            "\n", sep = "")
        next
      }
      progress <- tryCatch(readRDS(progress_path),
                           error = function(condition) NULL)
      stage <- if (is.null(progress)) {
        "unreadable_progress"
      } else progress$Stage
      checkpoint <- mfrmr_gtds3ac_failure_checkpoint(
        dataset_id, input, "generation_failure",
        paste0("interrupted_prior_attempt_at:", stage),
        "parent_process_failure", TRUE
      )
      mfrmr_gtds3ac_assert_checkpoint(checkpoint, input, source_root)
      receipt <- mfrmr_gtds3ac_process_receipt(
        dataset_id, input, "interrupted_prior_attempt", NA_integer_,
        NA_real_, NA_real_, FALSE, FALSE
      )
      mfrmr_gtds3ac_atomic_save(receipt, process_path)
      mfrmr_gtds3ac_atomic_save(checkpoint, checkpoint_path)
      failure_count <- failure_count + 1L
      cat("DSIM3_SEAL_INTERRUPTED ", index, "/42 ", dataset_id,
          "\n", sep = "")
      next
    }
    process_result <- mfrmr_gtds3ac_run_dataset_process(
      dataset_id, input_path, partial_path, source_root, progress_path,
      worker_path, input
    )
    mfrmr_gtds3ac_atomic_save(process_result$Receipt, process_path)
    partial_checkpoint <- if (file.exists(partial_path)) {
      tryCatch({
        value <- readRDS(partial_path)
        mfrmr_gtds3ac_assert_checkpoint(value, input, source_root)
        value
      }, error = function(condition) NULL)
    } else NULL
    if (identical(process_result$Outcome, "success") ||
        !is.null(partial_checkpoint)) {
      checkpoint <- partial_checkpoint
      if (is.null(checkpoint)) {
        checkpoint <- readRDS(partial_path)
        mfrmr_gtds3ac_assert_checkpoint(checkpoint, input, source_root)
      }
    } else {
      terminal_state <- if (process_result$Outcome %in% c(
        "peak_rss_limit", "wall_time_limit"
      )) "generation_resource_limit" else "generation_failure"
      evidence <- paste0(
        "dataset_process_", process_result$Outcome, ":",
        substr(process_result$Receipt$StderrHash, 1L, 16L)
      )
      checkpoint <- mfrmr_gtds3ac_failure_checkpoint(
        dataset_id, input, terminal_state, evidence,
        "parent_process_failure", TRUE
      )
      mfrmr_gtds3ac_assert_checkpoint(checkpoint, input, source_root)
      failure_count <- failure_count + 1L
    }
    mfrmr_gtds3ac_atomic_save(checkpoint, checkpoint_path)
    new_count <- new_count + 1L
    cat(
      "DSIM3_ATTEMPT ", index, "/42 ", dataset_id, " ",
      checkpoint$DatasetTerminalReceipt$TerminalState[[1L]], " routes=",
      nrow(checkpoint$RouteTerminalReceiptRegistry), "\n", sep = ""
    )
  }
  checkpoints <- lapply(request$DatasetId, function(dataset_id) {
    readRDS(mfrmr_gtds3ac_checkpoint_path(checkpoint_dir, dataset_id))
  })
  process_receipts <- lapply(request$DatasetId, function(dataset_id) {
    readRDS(mfrmr_gtds3ac_process_path(process_dir, dataset_id))
  })
  manifest <- mfrmr_gtds3ac_finalize(
    checkpoints, process_receipts, input, source_root
  )
  result_path <- file.path(output_dir, "launch-result.rds")
  marker_path <- file.path(output_dir, "run-complete.rds")
  mfrmr_gtds3ac_atomic_save(manifest, result_path)
  marker_payload <- list(
    ContractHash = input$Contract$ContractHash,
    LaunchInputHash = input$LaunchInputHash,
    ManifestHash = manifest$ManifestHash,
    CheckpointHashes = manifest$CheckpointRegistry$CheckpointHash,
    NewCheckpointCount = new_count,
    ResumedCheckpointCount = resumed_count,
    ParentFailureCheckpointCount = failure_count
  )
  marker <- structure(c(marker_payload, list(
    CompletionHash = mfrmr_gtds3ac_hash(marker_payload)
  )), class = c("mfrmr_gtds3ac_completion", "list"))
  mfrmr_gtds3ac_atomic_save(marker, marker_path)
  list(Manifest = manifest, Completion = marker)
}

mfrmr_gtds3ac_shadow_bridge_qualification <- function(
    scenario_id = "D3-S001",
    request_manifest = mfrmr_gtds3x_manifest(),
    plan = mfrmr_gtds3p_plan(), coverage = mfrmr_gtds3_manifest()) {
  generation <- mfrmr_gtds3g_generate_profile(
    scenario_id, coverage = coverage, validate = FALSE
  )
  backend <- request_manifest$BackendRequestRegistry[
    request_manifest$BackendRequestRegistry$ScenarioId == scenario_id,
    , drop = FALSE
  ]
  key <- paste(backend$ScenarioId, backend$RouteId, sep = "::")
  backend <- backend[!duplicated(key), , drop = FALSE]
  if (nrow(backend) < 1L) {
    stop("The qualification scenario has no candidate route.", call. = FALSE)
  }
  request <- backend[1L, , drop = FALSE]
  route <- plan$RouteUnitRegistry[
    plan$RouteUnitRegistry$RouteUnitId == request$RouteUnitId[[1L]],
    , drop = FALSE
  ]
  semantics <- mfrmr_gtds3s_manifest()
  truth <- mfrmr_gtds3t_manifest(semantics_manifest = semantics)
  operator <- mfrmr_gtds3o_project_profile(
    scenario_id, truth_manifest = truth,
    semantics_manifest = semantics, coverage = coverage, validate = FALSE
  )
  result <- mfrmr_gtds3w_fit_template(
    generation, route, request, operator
  )
  metrics <- mfrmr_gtds3w_metric_vectors(result$Coefficients)
  payload <- list(
    ScenarioId = scenario_id,
    ShadowSeed = generation$ShadowSeed,
    GenerationHash = generation$GenerationHash,
    RouteUnitId = request$RouteUnitId[[1L]],
    BackendRequestHash = request$RequestHash[[1L]],
    FitReceiptHashes = result$FitReceipts$FitReceiptHash,
    MetricVectorHashes = metrics$MetricVectorHash
  )
  list(
    ScenarioId = scenario_id,
    ShadowSeed = generation$ShadowSeed,
    FitCallCount = nrow(result$FitReceipts),
    MetricVectorCount = nrow(metrics),
    AllMetricsReady = all(metrics$AllStrataReturned),
    CallerCountsAs856Attempt = FALSE,
    Planned856RngStreamOpened = FALSE,
    QualificationHash = mfrmr_gtds3ac_hash(payload)
  )
}
