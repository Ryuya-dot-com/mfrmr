# Internal D-SIM-3 shared-dataset route and terminal-receipt adapter.
#
# This fourth shared-substrate layer binds the 21 nonpromoting shadow fixtures
# to the 50 frozen candidate route units, and materializes only terminal states
# that are already knowable without exploratory generation or a backend call.
# Admission is deliberately not represented as a terminal outcome.

mfrmr_gtds3r_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3_manifest",
    "mfrmr_gtds3e_plan", "mfrmr_gtds3e_assert_plan",
    "mfrmr_gtds3g_contract", "mfrmr_gtds3g_manifest",
    "mfrmr_gtds3g_assert_manifest", "mfrmr_gtds3g_generate_profile",
    "mfrmr_gtds3g_assert_generation"
  )
  target <- environment(mfrmr_gtds3r_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 execution-plan and generator chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3r_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3r_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-ROUTE-RECEIPT-ADAPTER-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentGeneratorContractId =
      "MFRMR-GTHEORY-MV-DSIM3-RESPONSE-GENERATOR-ADAPTER-V1",
    ParentGeneratorContractHash =
      "92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4",
    ParentGeneratorManifestHash =
      "c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a",
    ParentExecutionContractHash =
      "1e26cdf45218c7a28a260e519a376346d99d76a69772382ef5b0787e130f8b85",
    ParentExecutionPlanHash =
      "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7",
    ParentGeneratorRecord = paste0(
      "gtheory-multivariate-dsim3-response-generator-adapter-record-",
      "0.2.4.md"
    )
  )
}

mfrmr_gtds3r_contract <- function() {
  mfrmr_gtds3r_require_primitives()
  identity <- mfrmr_gtds3r_identity()
  payload <- c(identity, list(
    ExpectedShadowFixtureCount = 21L,
    ExpectedPlannedDatasetCount = 42L,
    ExpectedPlannedRouteCount = 210L,
    ExpectedCandidateRouteCount = 50L,
    ExpectedRestrictedLme4CandidateCount = 8L,
    ExpectedSeparateUnivariateCandidateCount = 42L,
    ExpectedFrozenNoCallRouteCount = 160L,
    ExpectedShadowDatasetTerminalCount = 21L,
    ExpectedCurrentTerminalReceiptCount = 181L,
    ExpectedCurrentlyOpenUnitCount = 92L,
    ExpectedTerminalStateSemanticCount = 13L,
    RoutePayloadColumns = c(
      "RowId", "Stratum", "ObjectId", "ConditionId",
      "ObjectConditionId", "EventId", "Score"
    ),
    CandidateAdmissionState =
      "adapter_qualified_backend_call_withheld",
    AdmissionIsTerminalState = FALSE,
    CandidateTerminalReceiptRequiredBeforeBackendAttempt = FALSE,
    FrozenNoCallTerminalReceiptRequiredNow = TRUE,
    ShadowDatasetTerminalReceiptRequiredNow = TRUE,
    PlannedDatasetTerminalReceiptRequiredBefore855Attempt = FALSE,
    ExactlyOneRule = paste(
      "one_terminal_receipt_for_each_currently_terminal_unit_and_zero_for",
      "each_open_unit; admission_is_not_terminal", sep = "_"
    ),
    CandidatePayloadCountsInExploratoryDenominator = FALSE,
    FrozenNoCallReceiptCountsInExploratoryDenominator = TRUE,
    ShadowReceiptCountsInExploratoryDenominator = FALSE,
    TerminalStateSchemaProbeCountsAsReceipt = FALSE,
    Planned855RngStreamAllowed = FALSE,
    BackendCallAllowed = FALSE,
    FitAllowed = FALSE,
    MetricAllowed = FALSE,
    ResourceControllerQualified = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3r_hash(payload)
  )), class = c("mfrmr_gtds3r_contract", "list"))
}

mfrmr_gtds3r_validate_contract <- function(
    contract = mfrmr_gtds3r_contract(), execution_plan = NULL,
    generator_manifest = NULL) {
  mfrmr_gtds3r_require_primitives()
  if (is.null(execution_plan)) execution_plan <- mfrmr_gtds3e_plan()
  if (is.null(generator_manifest)) generator_manifest <- mfrmr_gtds3g_manifest()
  mfrmr_gtds3e_assert_plan(execution_plan)
  mfrmr_gtds3g_assert_manifest(generator_manifest)
  canonical <- mfrmr_gtds3r_contract()
  valid <- inherits(contract, "mfrmr_gtds3r_contract") &&
    identical(contract, canonical) && identical(
      contract$ParentGeneratorContractHash,
      generator_manifest$Contract$ContractHash
    ) && identical(
      contract$ParentGeneratorManifestHash,
      generator_manifest$ManifestHash
    ) && identical(
      contract$ParentExecutionContractHash,
      execution_plan$Contract$ContractHash
    ) && identical(
      contract$ParentExecutionPlanHash, execution_plan$PlanHash
    ) && identical(contract$ExpectedShadowFixtureCount, 21L) &&
    identical(contract$ExpectedCandidateRouteCount, 50L) &&
    identical(contract$ExpectedFrozenNoCallRouteCount, 160L) &&
    !isTRUE(contract$AdmissionIsTerminalState) &&
    !isTRUE(contract$CandidateTerminalReceiptRequiredBeforeBackendAttempt) &&
    isTRUE(contract$FrozenNoCallTerminalReceiptRequiredNow) &&
    isTRUE(contract$ShadowDatasetTerminalReceiptRequiredNow) &&
    !isTRUE(contract$PlannedDatasetTerminalReceiptRequiredBefore855Attempt) &&
    !isTRUE(contract$CandidatePayloadCountsInExploratoryDenominator) &&
    isTRUE(contract$FrozenNoCallReceiptCountsInExploratoryDenominator) &&
    !isTRUE(contract$ShadowReceiptCountsInExploratoryDenominator) &&
    !isTRUE(contract$TerminalStateSchemaProbeCountsAsReceipt) &&
    !isTRUE(contract$Planned855RngStreamAllowed) &&
    !isTRUE(contract$BackendCallAllowed) && !isTRUE(contract$FitAllowed) &&
    !isTRUE(contract$MetricAllowed) &&
    !isTRUE(contract$ResourceControllerQualified) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 route/receipt contract is invalid.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3r_shadow_identity <- function(generation, contract) {
  paste0(
    "D3R-SF", sprintf("%03d", generation$ScenarioOrdinal), "-",
    substr(mfrmr_gtds3r_hash(list(
      ContractHash = contract$ContractHash,
      ScenarioId = generation$ScenarioId,
      GenerationHash = generation$GenerationHash,
      GeneratedDataHash = generation$Summary$GeneratedDataHash
    )), 1L, 16L)
  )
}

mfrmr_gtds3r_route_data <- function(generation, contract) {
  data <- generation$GeneratedData
  observed <- data[data$ResponseGenerated, , drop = FALSE]
  output <- data.frame(
    RowId = observed$RowId,
    Stratum = observed$Stratum,
    ObjectId = observed$ObjectId,
    ConditionId = observed$ConditionId,
    ObjectConditionId = paste(
      observed$ObjectId, observed$ConditionId, sep = "/"
    ),
    EventId = observed$EventId,
    Score = observed$Score,
    stringsAsFactors = FALSE
  )
  if (!identical(names(output), contract$RoutePayloadColumns) ||
      nrow(output) < 1L || anyNA(output) ||
      anyDuplicated(output$RowId) || !all(is.finite(output$Score))) {
    stop("The shadow generation cannot form a canonical route table.",
         call. = FALSE)
  }
  row.names(output) <- NULL
  output
}

mfrmr_gtds3r_route_payload_fields <- function() {
  c(
    "ContractId", "ContractHash", "PlannedRouteUnitId",
    "PlannedDatasetTemplateId", "ScenarioId", "TemplateReplicate",
    "RouteId", "ShadowFixtureId", "ShadowGenerationHash",
    "SharedDatasetHash", "PayloadKind", "PayloadPartitions",
    "PartitionRowCounts", "ObservedRowCount"
  )
}

mfrmr_gtds3r_route_payload <- function(generation, route_unit, contract) {
  if (!is.data.frame(route_unit) || nrow(route_unit) != 1L ||
      !identical(route_unit$ScenarioId[[1L]], generation$ScenarioId) ||
      !identical(route_unit$PlannedDisposition[[1L]],
                 "qualification_candidate") ||
      !route_unit$RouteId[[1L]] %in% c(
        "multivariate_lme4_restricted", "separate_univariate"
      )) {
    stop("One matching frozen candidate route unit is required.",
         call. = FALSE)
  }
  data <- mfrmr_gtds3r_route_data(generation, contract)
  route_id <- route_unit$RouteId[[1L]]
  if (identical(route_id, "multivariate_lme4_restricted")) {
    if (!identical(generation$Profile$observation_event, "distinct")) {
      stop("The restricted lme4 route received an ineligible shadow fixture.",
           call. = FALSE)
    }
    partitions <- list(joint = data)
    payload_kind <- "joint_multivariate_distinct_event_table"
  } else {
    strata <- sort(unique(data$Stratum), method = "radix")
    partitions <- stats::setNames(lapply(strata, function(stratum) {
      data[data$Stratum == stratum, , drop = FALSE]
    }), strata)
    payload_kind <- "separate_univariate_stratum_tables"
  }
  counts <- as.integer(vapply(partitions, nrow, integer(1L)))
  names(counts) <- names(partitions)
  shadow_id <- mfrmr_gtds3r_shadow_identity(generation, contract)
  payload <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    PlannedRouteUnitId = route_unit$RouteUnitId[[1L]],
    PlannedDatasetTemplateId = route_unit$DatasetId[[1L]],
    ScenarioId = generation$ScenarioId,
    TemplateReplicate = as.integer(route_unit$Replicate[[1L]]),
    RouteId = route_id,
    ShadowFixtureId = shadow_id,
    ShadowGenerationHash = generation$GenerationHash,
    SharedDatasetHash = generation$Summary$GeneratedDataHash,
    PayloadKind = payload_kind,
    PayloadPartitions = partitions,
    PartitionRowCounts = counts,
    ObservedRowCount = as.integer(nrow(data))
  )
  structure(c(payload, list(
    PayloadHash = mfrmr_gtds3r_hash(payload),
    SharedDatasetIdentityPreserved = TRUE,
    CountsInExploratoryDenominator = FALSE,
    BackendExecutionAuthorized = FALSE,
    TerminalReceiptIssued = FALSE
  )), class = c("mfrmr_gtds3r_route_payload", "list"))
}

mfrmr_gtds3r_assert_route_payload <- function(
    payload, generation, route_unit, contract = mfrmr_gtds3r_contract()) {
  fields <- mfrmr_gtds3r_route_payload_fields()
  suffix <- c(
    "PayloadHash", "SharedDatasetIdentityPreserved",
    "CountsInExploratoryDenominator", "BackendExecutionAuthorized",
    "TerminalReceiptIssued"
  )
  expected_names <- c(fields, suffix)
  if (!inherits(payload, "mfrmr_gtds3r_route_payload") ||
      !identical(names(payload), expected_names)) {
    stop("A typed D-SIM-3 route payload is required.", call. = FALSE)
  }
  combined <- do.call(rbind, payload$PayloadPartitions)
  row.names(combined) <- NULL
  source <- mfrmr_gtds3r_route_data(generation, contract)
  combined <- combined[match(source$RowId, combined$RowId), , drop = FALSE]
  row.names(combined) <- NULL
  valid <- identical(payload$ContractId, contract$ContractId) &&
    identical(payload$ContractHash, contract$ContractHash) &&
    identical(payload$PlannedRouteUnitId, route_unit$RouteUnitId[[1L]]) &&
    identical(payload$PlannedDatasetTemplateId, route_unit$DatasetId[[1L]]) &&
    identical(payload$ScenarioId, generation$ScenarioId) &&
    identical(payload$TemplateReplicate,
              as.integer(route_unit$Replicate[[1L]])) &&
    identical(payload$RouteId, route_unit$RouteId[[1L]]) &&
    identical(payload$ShadowFixtureId,
              mfrmr_gtds3r_shadow_identity(generation, contract)) &&
    identical(payload$ShadowGenerationHash, generation$GenerationHash) &&
    identical(payload$SharedDatasetHash,
              generation$Summary$GeneratedDataHash) &&
    identical(combined, source) &&
    identical(sum(payload$PartitionRowCounts), payload$ObservedRowCount) &&
    identical(payload$ObservedRowCount,
              as.integer(generation$Summary$GeneratedResponseCount)) &&
    identical(payload$PayloadHash, mfrmr_gtds3r_hash(payload[fields])) &&
    isTRUE(payload$SharedDatasetIdentityPreserved) &&
    !isTRUE(payload$CountsInExploratoryDenominator) &&
    !isTRUE(payload$BackendExecutionAuthorized) &&
    !isTRUE(payload$TerminalReceiptIssued)
  if (!valid) {
    stop("The D-SIM-3 route payload was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3r_resource_scope_for_state <- function(terminal_state) {
  switch(
    terminal_state,
    generation_resource_limit = "dataset_generation",
    fit_resource_limit = "one_route_fit",
    metric_resource_limit = "one_route_metric",
    NA_character_
  )
}

mfrmr_gtds3r_terminal_requirements <- function(execution_contract) {
  states <- execution_contract$TerminalStateRegistry
  data.frame(
    StateOrdinal = states$StateOrdinal,
    UnitType = states$UnitType,
    TerminalState = states$TerminalState,
    ValidTerminalReceipt = states$ValidTerminalReceipt,
    ResponseGeneratedRequired = states$TerminalState == "generation_complete",
    BackendCallRequired = states$TerminalState %in% c(
      "fit_failure", "fit_resource_limit", "metric_failure",
      "metric_resource_limit", "complete_nonpromoting"
    ),
    FitReturnedRequired = states$TerminalState %in% c(
      "metric_failure", "metric_resource_limit", "complete_nonpromoting"
    ),
    MetricComputedRequired = states$TerminalState == "complete_nonpromoting",
    ResourceScopeId = vapply(
      states$TerminalState, mfrmr_gtds3r_resource_scope_for_state,
      character(1L)
    ),
    ReplacementAllowed = FALSE,
    PromotesSupport = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3r_terminal_receipt_fields <- function() {
  c(
    "ReceiptSchema", "UnitNamespace", "UnitType", "UnitId",
    "TerminalState", "EvidenceStage", "EvidenceHash",
    "ResourceScopeId", "CountsInRegisteredDenominator",
    "ResponseGenerated", "BackendCallMade", "FitReturned",
    "MetricComputed", "ExecutionObserved", "SchemaProbe"
  )
}

mfrmr_gtds3r_terminal_receipt <- function(
    unit_namespace, unit_id, terminal_state, evidence_stage, evidence_hash,
    counts_in_denominator, response_generated = FALSE,
    backend_call_made = FALSE, fit_returned = FALSE,
    metric_computed = FALSE, execution_observed = FALSE,
    schema_probe = FALSE, execution_contract, contract) {
  requirements <- mfrmr_gtds3r_terminal_requirements(execution_contract)
  index <- match(terminal_state, requirements$TerminalState)
  if (is.na(index) || !isTRUE(requirements$ValidTerminalReceipt[[index]])) {
    stop("The requested terminal state cannot produce a valid receipt.",
         call. = FALSE)
  }
  unit_type <- requirements$UnitType[[index]]
  expected_namespace <- if (unit_type == "dataset") {
    c("shadow_dataset", "planned_dataset")
  } else if (unit_type == "route") "planned_route" else "integrity"
  resource_scope <- requirements$ResourceScopeId[[index]]
  flags <- c(
    ResponseGenerated = response_generated,
    BackendCallMade = backend_call_made,
    FitReturned = fit_returned,
    MetricComputed = metric_computed
  )
  required_flags <- c(
    ResponseGenerated = requirements$ResponseGeneratedRequired[[index]],
    BackendCallMade = requirements$BackendCallRequired[[index]],
    FitReturned = requirements$FitReturnedRequired[[index]],
    MetricComputed = requirements$MetricComputedRequired[[index]]
  )
  if (!unit_namespace %in% expected_namespace || !is.character(unit_id) ||
      length(unit_id) != 1L || is.na(unit_id) || !nzchar(unit_id) ||
      !is.character(evidence_hash) || length(evidence_hash) != 1L ||
      is.na(evidence_hash) || !grepl("^[0-9a-f]{64}$", evidence_hash) ||
      any(required_flags & !flags) ||
      (!required_flags[["BackendCallMade"]] && backend_call_made) ||
      (!backend_call_made && (fit_returned || metric_computed)) ||
      (!fit_returned && metric_computed)) {
    stop("The terminal receipt violates its state semantics.", call. = FALSE)
  }
  payload <- list(
    ReceiptSchema = "dsim3_terminal_receipt_v1",
    UnitNamespace = unit_namespace,
    UnitType = unit_type,
    UnitId = unit_id,
    TerminalState = terminal_state,
    EvidenceStage = evidence_stage,
    EvidenceHash = evidence_hash,
    ResourceScopeId = resource_scope,
    CountsInRegisteredDenominator = isTRUE(counts_in_denominator),
    ResponseGenerated = isTRUE(response_generated),
    BackendCallMade = isTRUE(backend_call_made),
    FitReturned = isTRUE(fit_returned),
    MetricComputed = isTRUE(metric_computed),
    ExecutionObserved = isTRUE(execution_observed),
    SchemaProbe = isTRUE(schema_probe)
  )
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtds3r_hash(payload),
    ReceiptIssued = !isTRUE(schema_probe),
    ReplacementAllowed = FALSE,
    PromotesSupport = FALSE
  )), class = c("mfrmr_gtds3r_terminal_receipt", "list"))
}

mfrmr_gtds3r_assert_terminal_receipt <- function(
    receipt, execution_contract, contract) {
  fields <- mfrmr_gtds3r_terminal_receipt_fields()
  if (!inherits(receipt, "mfrmr_gtds3r_terminal_receipt") ||
      !identical(
        names(receipt),
        c(fields, "ReceiptHash", "ReceiptIssued", "ReplacementAllowed",
          "PromotesSupport")
      )) {
    stop("A typed D-SIM-3 terminal receipt is required.", call. = FALSE)
  }
  replay <- mfrmr_gtds3r_terminal_receipt(
    receipt$UnitNamespace, receipt$UnitId, receipt$TerminalState,
    receipt$EvidenceStage, receipt$EvidenceHash,
    receipt$CountsInRegisteredDenominator,
    receipt$ResponseGenerated, receipt$BackendCallMade,
    receipt$FitReturned, receipt$MetricComputed,
    receipt$ExecutionObserved, receipt$SchemaProbe,
    execution_contract, contract
  )
  if (!identical(receipt, replay)) {
    stop("The D-SIM-3 terminal receipt was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3r_terminal_probe_registry <- function(execution_contract, contract) {
  requirements <- mfrmr_gtds3r_terminal_requirements(execution_contract)
  rows <- lapply(seq_len(nrow(requirements)), function(index) {
    state <- requirements[index, , drop = FALSE]
    valid <- state$ValidTerminalReceipt[[1L]]
    receipt <- NULL
    rejected <- FALSE
    error <- tryCatch({
      receipt <- mfrmr_gtds3r_terminal_receipt(
        if (state$UnitType[[1L]] == "dataset") "shadow_dataset" else
          if (state$UnitType[[1L]] == "route") "planned_route" else
            "integrity",
        paste0("D3R-PROBE-", sprintf("%02d", index)),
        state$TerminalState[[1L]], "schema_probe_only",
        mfrmr_gtds3r_hash(list(State = state$TerminalState[[1L]])),
        FALSE,
        response_generated = state$ResponseGeneratedRequired[[1L]],
        backend_call_made = state$BackendCallRequired[[1L]],
        fit_returned = state$FitReturnedRequired[[1L]],
        metric_computed = state$MetricComputedRequired[[1L]],
        execution_observed = FALSE, schema_probe = TRUE,
        execution_contract = execution_contract, contract = contract
      )
      NA_character_
    }, error = function(condition) {
      rejected <<- TRUE
      conditionMessage(condition)
    })
    qualified <- if (valid) {
      !is.null(receipt) && is.na(error) && !receipt$ReceiptIssued &&
        receipt$SchemaProbe
    } else rejected && grepl("cannot produce", error, fixed = TRUE)
    data.frame(
      TerminalQualificationOrdinal = as.integer(index),
      UnitType = state$UnitType,
      TerminalState = state$TerminalState,
      ValidTerminalReceipt = valid,
      GenericDsim3ReceiptSchemaReady = valid,
      ResourceMetadataSchemaBound = if (valid) {
        identical(
          receipt$ResourceScopeId,
          state$ResourceScopeId[[1L]]
        )
      } else TRUE,
      ExactOneReceiptValidatorReady = TRUE,
      ValidStateSchemaProbeConstructed = valid && !is.null(receipt),
      InvalidSentinelRejected = !valid && rejected,
      SchemaProbeReceiptIssued = if (is.null(receipt)) FALSE else
        receipt$ReceiptIssued,
      TerminalStateQualified = qualified,
      ProbeHash = if (is.null(receipt)) NA_character_ else
        receipt$ReceiptHash,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3r_receipt_row <- function(receipt) {
  data.frame(
    UnitNamespace = receipt$UnitNamespace,
    UnitType = receipt$UnitType,
    UnitId = receipt$UnitId,
    UnitKey = paste(receipt$UnitNamespace, receipt$UnitId, sep = "::"),
    TerminalState = receipt$TerminalState,
    EvidenceStage = receipt$EvidenceStage,
    EvidenceHash = receipt$EvidenceHash,
    ResourceScopeId = receipt$ResourceScopeId,
    CountsInRegisteredDenominator = receipt$CountsInRegisteredDenominator,
    ResponseGenerated = receipt$ResponseGenerated,
    BackendCallMade = receipt$BackendCallMade,
    FitReturned = receipt$FitReturned,
    MetricComputed = receipt$MetricComputed,
    ExecutionObserved = receipt$ExecutionObserved,
    SchemaProbe = receipt$SchemaProbe,
    ReceiptHash = receipt$ReceiptHash,
    ReceiptIssued = receipt$ReceiptIssued,
    ReplacementAllowed = receipt$ReplacementAllowed,
    PromotesSupport = receipt$PromotesSupport,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3r_accounting_registry <- function(
    execution_plan, shadow_rows, contract) {
  shadow <- data.frame(
    UnitNamespace = "shadow_dataset", UnitType = "dataset",
    UnitId = shadow_rows$ShadowFixtureId,
    UnitKey = paste("shadow_dataset", shadow_rows$ShadowFixtureId, sep = "::"),
    ScenarioId = shadow_rows$ScenarioId,
    PlannedDisposition = "nonpromoting_shadow_generation",
    RequiredTerminalCountNow = 1L,
    ExpectedTerminalStateNow = "generation_complete",
    CountsInRegisteredDenominator = FALSE,
    stringsAsFactors = FALSE
  )
  datasets <- execution_plan$DatasetAttemptRegistry
  planned_dataset <- data.frame(
    UnitNamespace = "planned_dataset", UnitType = "dataset",
    UnitId = datasets$DatasetId,
    UnitKey = paste("planned_dataset", datasets$DatasetId, sep = "::"),
    ScenarioId = datasets$ScenarioId,
    PlannedDisposition = "unopened_855_dataset_attempt",
    RequiredTerminalCountNow = 0L,
    ExpectedTerminalStateNow = "",
    CountsInRegisteredDenominator = TRUE,
    stringsAsFactors = FALSE
  )
  routes <- execution_plan$RouteUnitRegistry
  candidate <- routes$PlannedDisposition == "qualification_candidate"
  planned_route <- data.frame(
    UnitNamespace = "planned_route", UnitType = "route",
    UnitId = routes$RouteUnitId,
    UnitKey = paste("planned_route", routes$RouteUnitId, sep = "::"),
    ScenarioId = routes$ScenarioId,
    PlannedDisposition = routes$PlannedDisposition,
    RequiredTerminalCountNow = ifelse(candidate, 0L, 1L),
    ExpectedTerminalStateNow = ifelse(
      candidate, "", routes$FrozenNoCallTerminalState
    ),
    CountsInRegisteredDenominator = routes$CountsInRouteDenominator,
    stringsAsFactors = FALSE
  )
  output <- rbind(shadow, planned_dataset, planned_route)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3r_validate_accounting <- function(units, receipts) {
  required_unit <- c(
    "UnitNamespace", "UnitType", "UnitId", "UnitKey", "ScenarioId",
    "PlannedDisposition", "RequiredTerminalCountNow",
    "ExpectedTerminalStateNow", "CountsInRegisteredDenominator"
  )
  required_receipt <- c(
    "UnitNamespace", "UnitType", "UnitId", "UnitKey", "TerminalState",
    "ReceiptHash", "ReceiptIssued", "SchemaProbe"
  )
  if (!is.data.frame(units) || !all(required_unit %in% names(units)) ||
      !is.data.frame(receipts) ||
      !all(required_receipt %in% names(receipts)) ||
      anyDuplicated(units$UnitKey) || any(!receipts$ReceiptIssued) ||
      any(receipts$SchemaProbe) ||
      any(!receipts$UnitKey %in% units$UnitKey)) {
    stop("The D-SIM-3 terminal accounting inputs are invalid.",
         call. = FALSE)
  }
  counts <- tabulate(
    match(receipts$UnitKey, units$UnitKey), nbins = nrow(units)
  )
  states <- vapply(seq_len(nrow(units)), function(index) {
    value <- receipts$TerminalState[receipts$UnitKey == units$UnitKey[[index]]]
    if (length(value) == 0L) "" else paste(value, collapse = ";")
  }, character(1L))
  audit <- units
  audit$ObservedTerminalReceiptCount <- as.integer(counts)
  audit$ObservedTerminalState <- states
  audit$ReceiptCardinalityQualified <-
    audit$ObservedTerminalReceiptCount == audit$RequiredTerminalCountNow
  audit$TerminalStateQualified <- ifelse(
    audit$RequiredTerminalCountNow == 0L,
    audit$ObservedTerminalState == "",
    audit$ObservedTerminalState == audit$ExpectedTerminalStateNow
  )
  audit$ExactlyOneOrCorrectlyOpen <-
    audit$ReceiptCardinalityQualified & audit$TerminalStateQualified
  if (!all(audit$ExactlyOneOrCorrectlyOpen)) {
    stop(
      "Each currently terminal unit must have exactly one receipt and each ",
      "open unit must have zero.", call. = FALSE
    )
  }
  audit
}

mfrmr_gtds3r_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3r_require_primitives", "mfrmr_gtds3r_hash",
    "mfrmr_gtds3r_identity", "mfrmr_gtds3r_contract",
    "mfrmr_gtds3r_validate_contract", "mfrmr_gtds3r_shadow_identity",
    "mfrmr_gtds3r_route_data", "mfrmr_gtds3r_route_payload_fields",
    "mfrmr_gtds3r_route_payload", "mfrmr_gtds3r_assert_route_payload",
    "mfrmr_gtds3r_resource_scope_for_state",
    "mfrmr_gtds3r_terminal_requirements",
    "mfrmr_gtds3r_terminal_receipt_fields",
    "mfrmr_gtds3r_terminal_receipt",
    "mfrmr_gtds3r_assert_terminal_receipt",
    "mfrmr_gtds3r_terminal_probe_registry",
    "mfrmr_gtds3r_receipt_row", "mfrmr_gtds3r_accounting_registry",
    "mfrmr_gtds3r_validate_accounting",
    "mfrmr_gtds3r_implementation_identity",
    "mfrmr_gtds3r_manifest_fields", "mfrmr_gtds3r_manifest",
    "mfrmr_gtds3r_assert_manifest"
  )
  target <- environment(mfrmr_gtds3r_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3r_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtds3r_manifest_fields <- function() {
  c(
    "Contract", "ParentGeneratorManifestHash", "ParentExecutionPlanHash",
    "ShadowDatasetRegistry", "CandidateRouteAdmissionRegistry",
    "TerminalSemanticQualificationRegistry", "TerminalReceiptRegistry",
    "TerminalAccountingRegistry", "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3r_manifest <- function(
    contract = mfrmr_gtds3r_contract(),
    execution_plan = mfrmr_gtds3e_plan(),
    generator_manifest = mfrmr_gtds3g_manifest(),
    generator_contract = mfrmr_gtds3g_contract(),
    coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3r_validate_contract(
    contract, execution_plan, generator_manifest
  )
  routes <- execution_plan$RouteUnitRegistry
  candidates <- routes[
    routes$PlannedDisposition == "qualification_candidate", , drop = FALSE
  ]
  shadow_rows <- vector("list", contract$ExpectedShadowFixtureCount)
  admission_rows <- vector("list", nrow(candidates))
  shadow_receipts <- vector("list", contract$ExpectedShadowFixtureCount)
  admission_cursor <- 0L
  for (index in seq_len(nrow(coverage$ScenarioRegistry))) {
    scenario_id <- coverage$ScenarioRegistry$ScenarioId[[index]]
    generation <- mfrmr_gtds3g_generate_profile(
      scenario_id, generator_contract, coverage = coverage, validate = FALSE
    )
    mfrmr_gtds3g_assert_generation(
      generation, generator_contract, coverage = coverage,
      validate = FALSE, replay = FALSE
    )
    fixture_id <- mfrmr_gtds3r_shadow_identity(generation, contract)
    scenario_candidates <- candidates[
      candidates$ScenarioId == scenario_id, , drop = FALSE
    ]
    shadow_rows[[index]] <- data.frame(
      ShadowOrdinal = as.integer(index), ShadowFixtureId = fixture_id,
      ScenarioId = scenario_id,
      ScenarioOrdinal = generation$ScenarioOrdinal,
      ShadowSeed = generation$ShadowSeed,
      GenerationHash = generation$GenerationHash,
      GeneratedDataHash = generation$Summary$GeneratedDataHash,
      StructuralRowCount = generation$Summary$PlannedRowCount,
      ObservedRowCount = generation$Summary$GeneratedResponseCount,
      OmittedRowCount = generation$Summary$OmittedResponseCount,
      CandidateRouteTemplateCount = nrow(scenario_candidates),
      ShadowDatasetTerminalState = "generation_complete",
      CountsInExploratoryDatasetDenominator = FALSE,
      Planned855Identity = FALSE,
      BackendCallMade = FALSE, FitReturned = FALSE,
      stringsAsFactors = FALSE
    )
    shadow_receipt <- mfrmr_gtds3r_terminal_receipt(
      "shadow_dataset", fixture_id, "generation_complete",
      "qualified_shadow_generation", generation$GenerationHash,
      FALSE, response_generated = TRUE,
      execution_observed = TRUE, schema_probe = FALSE,
      execution_contract = execution_plan$Contract, contract = contract
    )
    mfrmr_gtds3r_assert_terminal_receipt(
      shadow_receipt, execution_plan$Contract, contract
    )
    shadow_receipts[[index]] <- mfrmr_gtds3r_receipt_row(shadow_receipt)
    for (route_index in seq_len(nrow(scenario_candidates))) {
      admission_cursor <- admission_cursor + 1L
      route_unit <- scenario_candidates[route_index, , drop = FALSE]
      payload <- mfrmr_gtds3r_route_payload(
        generation, route_unit, contract
      )
      mfrmr_gtds3r_assert_route_payload(
        payload, generation, route_unit, contract
      )
      admission_payload <- list(
        ContractHash = contract$ContractHash,
        PlannedRouteUnitId = route_unit$RouteUnitId[[1L]],
        PlannedDatasetTemplateId = route_unit$DatasetId[[1L]],
        ScenarioId = scenario_id,
        TemplateReplicate = route_unit$Replicate[[1L]],
        RouteId = route_unit$RouteId[[1L]],
        ShadowFixtureId = fixture_id,
        SharedDatasetHash = payload$SharedDatasetHash,
        RoutePayloadHash = payload$PayloadHash,
        AdmissionState = contract$CandidateAdmissionState
      )
      admission_rows[[admission_cursor]] <- data.frame(
        AdmissionOrdinal = admission_cursor,
        PlannedRouteUnitId = route_unit$RouteUnitId[[1L]],
        PlannedDatasetTemplateId = route_unit$DatasetId[[1L]],
        ScenarioId = scenario_id,
        TemplateReplicate = route_unit$Replicate[[1L]],
        RouteId = route_unit$RouteId[[1L]],
        QualificationStatus = route_unit$QualificationStatus[[1L]],
        ShadowFixtureId = fixture_id,
        SharedDatasetHash = payload$SharedDatasetHash,
        PayloadKind = payload$PayloadKind,
        PayloadPartitionCount = length(payload$PayloadPartitions),
        ObservedRowCount = payload$ObservedRowCount,
        RoutePayloadHash = payload$PayloadHash,
        AdmissionState = contract$CandidateAdmissionState,
        AdmissionHash = mfrmr_gtds3r_hash(admission_payload),
        ExactScenarioRouteAdapterReady = TRUE,
        SharedDatasetIdentityPreserved = TRUE,
        RouteAdmissionQualified = TRUE,
        CountsInExploratoryRouteDenominator = FALSE,
        TerminalReceiptRequiredNow = FALSE,
        TerminalReceiptIssued = FALSE,
        BackendCallCurrentlyAllowed = FALSE,
        BackendCallMade = FALSE, FitReturned = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  shadow_registry <- do.call(rbind, shadow_rows)
  admissions <- do.call(rbind, admission_rows)
  no_call <- routes[
    routes$PlannedDisposition != "qualification_candidate", , drop = FALSE
  ]
  no_call_receipts <- lapply(seq_len(nrow(no_call)), function(index) {
    unit <- no_call[index, , drop = FALSE]
    receipt <- mfrmr_gtds3r_terminal_receipt(
      "planned_route", unit$RouteUnitId[[1L]],
      unit$FrozenNoCallTerminalState[[1L]],
      "frozen_preexecution_no_call_disposition",
      mfrmr_gtds3r_hash(list(
        ExecutionPlanHash = execution_plan$PlanHash,
        RouteUnitId = unit$RouteUnitId[[1L]],
        PlannedDisposition = unit$PlannedDisposition[[1L]],
        FrozenNoCallTerminalState =
          unit$FrozenNoCallTerminalState[[1L]]
      )), TRUE, execution_observed = FALSE, schema_probe = FALSE,
      execution_contract = execution_plan$Contract, contract = contract
    )
    mfrmr_gtds3r_assert_terminal_receipt(
      receipt, execution_plan$Contract, contract
    )
    mfrmr_gtds3r_receipt_row(receipt)
  })
  receipts <- do.call(rbind, c(shadow_receipts, no_call_receipts))
  row.names(shadow_registry) <- row.names(admissions) <-
    row.names(receipts) <- NULL
  probes <- mfrmr_gtds3r_terminal_probe_registry(
    execution_plan$Contract, contract
  )
  units <- mfrmr_gtds3r_accounting_registry(
    execution_plan, shadow_registry, contract
  )
  accounting <- mfrmr_gtds3r_validate_accounting(units, receipts)
  implementation <- mfrmr_gtds3r_implementation_identity()
  route_counts <- table(factor(
    admissions$RouteId,
    levels = c("multivariate_lme4_restricted", "separate_univariate")
  ))
  state_counts <- table(factor(
    receipts$TerminalState,
    levels = execution_plan$Contract$TerminalStateRegistry$TerminalState
  ))
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ParentGeneratorManifestHash = generator_manifest$ManifestHash,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    ShadowFixtureCount = nrow(shadow_registry),
    QualifiedCandidateRouteCount = sum(admissions$RouteAdmissionQualified),
    RestrictedLme4CandidateCount = as.integer(route_counts[[1L]]),
    SeparateUnivariateCandidateCount = as.integer(route_counts[[2L]]),
    QualifiedTerminalStateSemanticCount =
      sum(probes$TerminalStateQualified),
    ValidTerminalSchemaProbeCount =
      sum(probes$ValidStateSchemaProbeConstructed),
    InvalidTerminalSentinelRejectionCount =
      sum(probes$InvalidSentinelRejected),
    ShadowDatasetTerminalReceiptCount = sum(
      receipts$UnitNamespace == "shadow_dataset"
    ),
    FrozenNoCallRouteTerminalReceiptCount = sum(
      receipts$UnitNamespace == "planned_route"
    ),
    NegativeControlPrefitRejectReceiptCount = as.integer(
      state_counts[["prefit_rejected_as_planned"]]
    ),
    FrozenNotApplicableReceiptCount = as.integer(
      state_counts[["not_applicable_as_frozen"]]
    ),
    MissingContractBlockReceiptCount = as.integer(
      state_counts[["missing_contract_block_as_frozen"]]
    ),
    CurrentTerminalReceiptCount = nrow(receipts),
    CurrentlyOpenUnitCount = sum(
      accounting$RequiredTerminalCountNow == 0L
    ),
    CandidateTerminalReceiptCount = sum(
      receipts$UnitId %in% admissions$PlannedRouteUnitId
    ),
    PlannedDatasetTerminalReceiptCount = sum(
      receipts$UnitNamespace == "planned_dataset"
    ),
    ExactlyOneCurrentTerminalOrCorrectlyOpenCount = sum(
      accounting$ExactlyOneOrCorrectlyOpen
    ),
    AccountingUnitCount = nrow(accounting),
    RouteAdapterQualified = all(admissions$RouteAdmissionQualified),
    TerminalReceiptAdapterQualified = all(probes$TerminalStateQualified) &&
      all(accounting$ExactlyOneOrCorrectlyOpen),
    AdmissionIsTerminalState = FALSE,
    Planned855RngStreamOpened = FALSE,
    ExploratoryResponseGenerated = FALSE,
    BackendCallMade = FALSE, FitReturned = FALSE, MetricComputed = FALSE,
    ResourceControllerQualified = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "qualify one enforceable five-scope resource controller over shadow",
      "success, timeout, memory, and stop-launch probes before considering",
      "the reserved 855 exploratory plan"
    )
  )
  payload <- list(
    Contract = contract,
    ParentGeneratorManifestHash = generator_manifest$ManifestHash,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    ShadowDatasetRegistry = shadow_registry,
    CandidateRouteAdmissionRegistry = admissions,
    TerminalSemanticQualificationRegistry = probes,
    TerminalReceiptRegistry = receipts,
    TerminalAccountingRegistry = accounting,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3r_hash(payload)
  )), class = c("mfrmr_gtds3r_manifest", "list"))
  mfrmr_gtds3r_assert_manifest(manifest)
  manifest
}

mfrmr_gtds3r_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3r_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3r_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 route/receipt manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  shadows <- manifest$ShadowDatasetRegistry
  admissions <- manifest$CandidateRouteAdmissionRegistry
  probes <- manifest$TerminalSemanticQualificationRegistry
  receipts <- manifest$TerminalReceiptRegistry
  accounting <- manifest$TerminalAccountingRegistry
  route_counts <- table(factor(
    admissions$RouteId,
    levels = c("multivariate_lme4_restricted", "separate_univariate")
  ))
  state_counts <- table(factor(
    receipts$TerminalState,
    levels = c(
      "generation_complete", "generation_failure",
      "generation_resource_limit", "not_attempted_generation_dependency",
      "prefit_rejected_as_planned", "not_applicable_as_frozen",
      "missing_contract_block_as_frozen", "fit_failure",
      "fit_resource_limit", "metric_failure", "metric_resource_limit",
      "complete_nonpromoting", "unrecorded_invalid"
    )
  ))
  accounting_input <- accounting[c(
    "UnitNamespace", "UnitType", "UnitId", "UnitKey", "ScenarioId",
    "PlannedDisposition", "RequiredTerminalCountNow",
    "ExpectedTerminalStateNow", "CountsInRegisteredDenominator"
  )]
  recomputed_accounting <- mfrmr_gtds3r_validate_accounting(
    accounting_input, receipts
  )
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3r_hash(manifest[fields])
  ) && inherits(contract, "mfrmr_gtds3r_contract") && identical(
    contract, mfrmr_gtds3r_contract()
  ) && identical(
    manifest$ParentGeneratorManifestHash,
    contract$ParentGeneratorManifestHash
  ) && identical(
    manifest$ParentExecutionPlanHash, contract$ParentExecutionPlanHash
  ) && identical(
    accounting, recomputed_accounting
  ) && identical(
    manifest$ImplementationIdentity, mfrmr_gtds3r_implementation_identity()
  ) && identical(nrow(shadows), 21L) &&
    identical(shadows$ScenarioId, sprintf("D3-S%03d", 1:21)) &&
    !anyDuplicated(shadows$ShadowFixtureId) &&
    all(!shadows$CountsInExploratoryDatasetDenominator) &&
    all(!shadows$Planned855Identity) && all(!shadows$BackendCallMade) &&
    identical(nrow(admissions), 50L) &&
    !anyDuplicated(admissions$PlannedRouteUnitId) &&
    identical(as.integer(route_counts), c(8L, 42L)) &&
    identical(length(unique(admissions$ShadowFixtureId)), 21L) &&
    all(admissions$ExactScenarioRouteAdapterReady) &&
    all(admissions$SharedDatasetIdentityPreserved) &&
    all(admissions$RouteAdmissionQualified) &&
    all(!admissions$CountsInExploratoryRouteDenominator) &&
    all(!admissions$TerminalReceiptRequiredNow) &&
    all(!admissions$TerminalReceiptIssued) &&
    all(!admissions$BackendCallCurrentlyAllowed) &&
    all(!admissions$BackendCallMade) && all(!admissions$FitReturned) &&
    identical(nrow(probes), 13L) && all(probes$TerminalStateQualified) &&
    identical(sum(probes$ValidStateSchemaProbeConstructed), 12L) &&
    identical(sum(probes$InvalidSentinelRejected), 1L) &&
    all(!probes$SchemaProbeReceiptIssued) &&
    identical(nrow(receipts), 181L) && !anyDuplicated(receipts$UnitKey) &&
    identical(as.integer(state_counts[["generation_complete"]]), 21L) &&
    identical(
      as.integer(state_counts[["prefit_rejected_as_planned"]]), 40L
    ) && identical(
      as.integer(state_counts[["not_applicable_as_frozen"]]), 8L
    ) && identical(
      as.integer(state_counts[["missing_contract_block_as_frozen"]]), 112L
    ) && all(receipts$ReceiptIssued) && all(!receipts$SchemaProbe) &&
    all(!receipts$BackendCallMade) && all(!receipts$FitReturned) &&
    all(!receipts$MetricComputed) && all(!receipts$ReplacementAllowed) &&
    all(!receipts$PromotesSupport) &&
    identical(nrow(accounting), 273L) &&
    identical(sum(accounting$RequiredTerminalCountNow == 1L), 181L) &&
    identical(sum(accounting$RequiredTerminalCountNow == 0L), 92L) &&
    all(accounting$ExactlyOneOrCorrectlyOpen) &&
    identical(manifest$Summary$ShadowFixtureCount, 21L) &&
    identical(manifest$Summary$QualifiedCandidateRouteCount, 50L) &&
    identical(manifest$Summary$RestrictedLme4CandidateCount, 8L) &&
    identical(manifest$Summary$SeparateUnivariateCandidateCount, 42L) &&
    identical(
      manifest$Summary$QualifiedTerminalStateSemanticCount, 13L
    ) && identical(manifest$Summary$ValidTerminalSchemaProbeCount, 12L) &&
    identical(
      manifest$Summary$InvalidTerminalSentinelRejectionCount, 1L
    ) && identical(
      manifest$Summary$ShadowDatasetTerminalReceiptCount, 21L
    ) && identical(
      manifest$Summary$FrozenNoCallRouteTerminalReceiptCount, 160L
    ) && identical(manifest$Summary$CurrentTerminalReceiptCount, 181L) &&
    identical(manifest$Summary$CurrentlyOpenUnitCount, 92L) &&
    identical(manifest$Summary$CandidateTerminalReceiptCount, 0L) &&
    identical(manifest$Summary$PlannedDatasetTerminalReceiptCount, 0L) &&
    identical(
      manifest$Summary$ExactlyOneCurrentTerminalOrCorrectlyOpenCount, 273L
    ) && identical(manifest$Summary$AccountingUnitCount, 273L) &&
    isTRUE(manifest$Summary$RouteAdapterQualified) &&
    isTRUE(manifest$Summary$TerminalReceiptAdapterQualified) &&
    !isTRUE(manifest$Summary$AdmissionIsTerminalState) &&
    !isTRUE(manifest$Summary$Planned855RngStreamOpened) &&
    !isTRUE(manifest$Summary$ExploratoryResponseGenerated) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitReturned) &&
    !isTRUE(manifest$Summary$MetricComputed) &&
    !isTRUE(manifest$Summary$ResourceControllerQualified) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady) &&
    identical(manifest$Summary$FeatureMaturity, "specified")
  if (!valid) {
    stop("The D-SIM-3 route/receipt manifest was altered.", call. = FALSE)
  }
  invisible(TRUE)
}
