# Internal D-SIM-2 v4 generator-to-terminal-state plumbing smoke.
#
# This runner exercises exactly one nonreserved fixture and one representable
# backend route.  It is an interface/state-propagation check, not a recovery,
# Monte Carlo, backend-comparison, inference, or public-support result.

mfrmr_gtds2_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtv_unscaled_operator",
    "mfrmr_gtv_overlap_operator", "mfrmr_gtv_spec",
    "mfrmr_gtv_composite", "mfrmr_gtvd_plan", "mfrmr_gtvd_assert_plan",
    "mfrmr_gtve_fixture_registry", "mfrmr_gtve_generate_fixture",
    "mfrmr_gtve_assert_generation", "mfrmr_gtvi_audit",
    "mfrmr_gtvb_spec", "mfrmr_gtvb_fit_lme4",
    "mfrmr_gtvb_assert_fit_integrity", "mfrmr_gtds_v4_hash",
    "mfrmr_gtds1_run"
  )
  target <- environment(mfrmr_gtds2_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the algebra, incidence, matched-backend, generator, v4, and ",
      "D-SIM-1 contracts before D-SIM-2: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds2_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds2_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM2-PLUMBING-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-30",
    ParentQualificationId =
      "MFRMR-GTHEORY-MV-DSIM1-DETERMINISTIC-V1",
    ParentQualificationHash =
      "6fd89f49fe6238a56bb5621fa07cfb2f7ddb4aba4d3323b69246a99620b937db"
  )
}

mfrmr_gtds2_contract <- function() {
  identity <- mfrmr_gtds2_identity()
  payload <- c(identity, list(
    FixtureId = "FX-C1-I2-BAL",
    FixtureSeed = 854000001L,
    FixtureStage = "nonreserved_generator_preflight",
    DesignId = "S2-SHARED-DISTINCT-C1",
    DesignRole = "matched_backend_intersection_plumbing_smoke",
    CanonicalDsim1Anchor = FALSE,
    Strata = c("A", "B"),
    ConditionSharing = "shared_rater_conditions",
    ObservationEventRelationship = "distinct_event_per_stratum_score",
    ResidualContract = "homoskedastic_independent_common_variance",
    Backend = "lme4",
    Criterion = "REML",
    RouteId = "mv_reml_lme4",
    ExpectedRows = 720L,
    ObservationLinkColumns = c("Rater", "EventId"),
    ConditionScope = c(Rater = "global", EventId = "stratum_local"),
    MetricIds = c("REL-G", "ABS-PHI"),
    MetricWeights = c(A = 0.5, B = 0.5),
    MetricWeightRole = "equal_weight_plumbing_only_nonrecommendation",
    AttemptLimit = 1L,
    AutomaticScenarioExpansionAllowed = FALSE,
    BackendComparisonAllowed = FALSE,
    TruthRecoveryComparisonAllowed = FALSE,
    PlannedRngStreamAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds2_hash(payload)
  )), class = c("mfrmr_gtds2_contract", "list"))
}

mfrmr_gtds2_validate_contract <- function(
    contract = mfrmr_gtds2_contract()) {
  mfrmr_gtds2_require_primitives()
  canonical <- mfrmr_gtds2_contract()
  parent <- mfrmr_gtds1_run()
  valid <- inherits(contract, "mfrmr_gtds2_contract") &&
    identical(contract, canonical) &&
    identical(
      contract$ParentQualificationId,
      parent$Summary$QualificationId
    ) &&
    identical(
      contract$ParentQualificationHash,
      parent$Summary$QualificationHash
    ) && isTRUE(parent$Summary$Dsim2Allowed) &&
    identical(contract$AttemptLimit, 1L) &&
    !isTRUE(contract$AutomaticScenarioExpansionAllowed) &&
    !isTRUE(contract$BackendComparisonAllowed) &&
    !isTRUE(contract$TruthRecoveryComparisonAllowed) &&
    !isTRUE(contract$PlannedRngStreamAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-2 plumbing contract is invalid or altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds2_component_map <- function() {
  data.frame(
    ComponentId = c("Object", "Rater", "Object:Rater", "Residual"),
    UniverseRole = c(
      "object", "absolute_only", "relative_error", "relative_error"
    ),
    Members = c("Object", "Rater", "Object:Rater", ""),
    CovarianceStructure = c(
      "unstructured", "unstructured", "unstructured",
      "homoskedastic_independent"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds2_eventize <- function(generation, plan, registry, contract) {
  mfrmr_gtve_assert_generation(generation, plan, registry)
  data <- generation$CandidateData
  required <- c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater",
    "Replicate", "Score"
  )
  if (!identical(names(data), required) || nrow(data) != contract$ExpectedRows ||
      anyNA(data) || any(!is.finite(data$Score)) ||
      !identical(sort(unique(data$Stratum), method = "radix"),
                 contract$Strata)) {
    stop("The D-SIM-2 generator output does not match the fixture contract.",
         call. = FALSE)
  }
  event_id <- vapply(seq_len(nrow(data)), function(index) {
    paste0("EV-", substr(mfrmr_gtds2_hash(list(
      Namespace = "mfrmr_gtheory_distinct_response_event_dsim2_v1",
      Stratum = data$Stratum[[index]],
      Rater = data$Rater[[index]],
      WithinCellReplicate = data$Replicate[[index]]
    )), 1L, 24L))
  }, character(1L))
  released <- data[c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Score"
  )]
  released$EventId <- event_id
  released <- released[c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater", "EventId",
    "Score"
  )]
  within <- paste(
    released$Stratum, released$Object, released$Rater, released$EventId,
    sep = "\036"
  )
  across <- paste(
    released$Object, released$Rater, released$EventId, sep = "\036"
  )
  if (anyDuplicated(within) || anyDuplicated(released$RowId) ||
      length(intersect(
        across[released$Stratum == contract$Strata[[1L]]],
        across[released$Stratum == contract$Strata[[2L]]]
      )) != 0L) {
    stop("The D-SIM-2 response-event identity is not distinct by stratum.",
         call. = FALSE)
  }
  released
}

mfrmr_gtds2_fit <- function(data, contract) {
  incidence <- mfrmr_gtvi_audit(
    data, object_col = "Object", stratum_col = "Stratum",
    score_col = "Score",
    condition_cols = contract$ObservationLinkColumns,
    condition_scope = contract$ConditionScope,
    strata = contract$Strata, missingness = "complete"
  )
  spec <- mfrmr_gtvb_spec(
    data, incidence, mfrmr_gtds2_component_map(),
    contract$ObservationLinkColumns
  )
  if (!isTRUE(incidence$IncidenceReady) || !isTRUE(spec$SpecReady) ||
      !isTRUE(spec$PairIdentityReady) ||
      spec$DuplicateWithinStratumObservationKeys != 0L ||
      any(spec$ObservationPairAudit$SharedObservationLinks != 0L) ||
      !identical(spec$ResidualContract, contract$ResidualContract)) {
    stop("The D-SIM-2 incidence or matched-backend specification failed.",
         call. = FALSE)
  }
  fit <- mfrmr_gtvb_fit_lme4(spec, reml = TRUE)
  mfrmr_gtvb_assert_fit_integrity(fit)
  if (!identical(fit$FitQualification, "point_estimation_gate_passed") ||
      !identical(fit$FitDiagnostics$FitStatus, "identified_point_fit")) {
    stop("The D-SIM-2 point-fit gate did not pass.", call. = FALSE)
  }
  receipt_payload <- list(
    Backend = contract$Backend,
    BackendVersion = as.character(utils::packageVersion("lme4")),
    Criterion = contract$Criterion,
    IncidenceAuditHash = incidence$AuditHash,
    SpecificationHash = spec$SpecificationHash,
    FitResultHash = fit$ResultHash,
    FitQualification = fit$FitQualification,
    FitStatus = fit$FitDiagnostics$FitStatus,
    LogLikelihood = fit$LikelihoodIdentity$Value,
    WarningCount = as.integer(length(fit$FitDiagnostics$Warnings)),
    MessageCount = as.integer(length(fit$FitDiagnostics$Messages)),
    ComponentCovarianceHash = mfrmr_gtds2_hash(fit$ComponentCovariances),
    SharedObservationLinks = as.integer(
      sum(spec$ObservationPairAudit$SharedObservationLinks)
    )
  )
  list(
    Fit = fit,
    Receipt = c(receipt_payload, list(
      ReceiptHash = mfrmr_gtds2_hash(receipt_payload)
    ))
  )
}

mfrmr_gtds2_allocation_operator <- function(
    data, condition_col, component_id, strata) {
  allocation <- unique(data[c("Stratum", condition_col)])
  names(allocation)[[2L]] <- "ConditionId"
  allocation <- allocation[order(
    match(allocation$Stratum, strata), allocation$ConditionId,
    method = "radix"
  ), , drop = FALSE]
  row.names(allocation) <- NULL
  counts <- table(allocation$Stratum)
  allocation$Weight <- 1 / as.numeric(counts[allocation$Stratum])
  mfrmr_gtv_overlap_operator(
    allocation, strata = strata, component_id = component_id
  )
}

mfrmr_gtds2_metric <- function(fit, data, contract) {
  component_map <- mfrmr_gtds2_component_map()[
    c("ComponentId", "UniverseRole")
  ]
  operators <- list(
    Object = mfrmr_gtv_unscaled_operator(contract$Strata, "Object"),
    Rater = mfrmr_gtds2_allocation_operator(
      data, "Rater", "Rater", contract$Strata
    ),
    `Object:Rater` = mfrmr_gtds2_allocation_operator(
      data, "Rater", "Object:Rater", contract$Strata
    ),
    Residual = mfrmr_gtds2_allocation_operator(
      data, "EventId", "Residual", contract$Strata
    )
  )
  algebra <- mfrmr_gtv_spec(
    contract$Strata, component_map, fit$ComponentCovariances, operators
  )
  metric <- mfrmr_gtv_composite(
    algebra, contract$MetricWeights,
    weight_id = contract$MetricWeightRole
  )
  valid <- isTRUE(metric$AlgebraReady) && is.finite(metric$G) &&
    is.finite(metric$Phi) && metric$G >= 0 && metric$G <= 1 &&
    metric$Phi >= 0 && metric$Phi <= 1 && metric$Phi <= metric$G + 1e-12
  if (!valid) {
    stop("The D-SIM-2 G/Phi plumbing metric is invalid.", call. = FALSE)
  }
  payload <- list(
    MetricIds = contract$MetricIds,
    MetricWeightRole = contract$MetricWeightRole,
    Weights = metric$Weights,
    UniverseVariance = metric$UniverseVariance,
    RelativeErrorVariance = metric$RelativeErrorVariance,
    AbsoluteErrorVariance = metric$AbsoluteErrorVariance,
    G = metric$G,
    Phi = metric$Phi,
    PhiNotGreaterThanG = metric$Phi <= metric$G + 1e-12,
    AlgebraSpecificationHash = algebra$SpecificationHash,
    AlgebraResultHash = metric$ResultHash,
    TruthCompared = FALSE,
    TargetCompared = FALSE,
    MetricPromotable = FALSE
  )
  c(payload, list(MetricReceiptHash = mfrmr_gtds2_hash(payload)))
}

mfrmr_gtds2_terminal_state <- function(stages) {
  required <- c(
    "StageOrdinal", "StageId", "StageStatus", "ArtifactHash",
    "ErrorClass", "ErrorMessage"
  )
  expected_ids <- c("generator", "fit", "metric")
  if (!is.data.frame(stages) || !identical(names(stages), required) ||
      !identical(stages$StageOrdinal, 1:3) ||
      !identical(stages$StageId, expected_ids) ||
      any(!stages$StageStatus %in% c(
        "completed", "failed", "not_attempted_dependency"
      ))) {
    stop("A canonical three-stage D-SIM-2 registry is required.",
         call. = FALSE)
  }
  status <- stages$StageStatus
  valid_sequence <- identical(status, rep("completed", 3L)) ||
    identical(status, c(
      "failed", "not_attempted_dependency", "not_attempted_dependency"
    )) || identical(status, c(
      "completed", "failed", "not_attempted_dependency"
    )) || identical(status, c("completed", "completed", "failed"))
  if (!valid_sequence) {
    stop("The D-SIM-2 stage sequence is impossible or outcome-dropped.",
         call. = FALSE)
  }
  if (identical(status[[1L]], "failed")) return("generator_failure")
  if (identical(status[[2L]], "failed")) return("fit_failure")
  if (identical(status[[3L]], "failed")) return("metric_failure")
  "plumbing_complete_nonpromoting"
}

mfrmr_gtds2_stage_row <- function(
    ordinal, stage_id, status, artifact_hash = NA_character_, error = NULL) {
  data.frame(
    StageOrdinal = as.integer(ordinal), StageId = stage_id,
    StageStatus = status, ArtifactHash = artifact_hash,
    ErrorClass = if (is.null(error)) "" else class(error)[[1L]],
    ErrorMessage = if (is.null(error)) "" else conditionMessage(error),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds2_function_identity <- function() {
  functions <- c(
    "mfrmr_gtds2_require_primitives", "mfrmr_gtds2_hash",
    "mfrmr_gtds2_identity", "mfrmr_gtds2_contract",
    "mfrmr_gtds2_validate_contract", "mfrmr_gtds2_component_map",
    "mfrmr_gtds2_eventize", "mfrmr_gtds2_fit",
    "mfrmr_gtds2_allocation_operator", "mfrmr_gtds2_metric",
    "mfrmr_gtds2_terminal_state", "mfrmr_gtds2_stage_row",
    "mfrmr_gtds2_function_identity", "mfrmr_gtds2_run_payload_fields",
    "mfrmr_gtds2_assert_run", "mfrmr_gtds2_run"
  )
  target <- environment(mfrmr_gtds2_function_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions),
    FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds2_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds2_run_payload_fields <- function() {
  c(
    "Contract", "Summary", "Stages", "GenerationReceipt", "FitReceipt",
    "MetricReceipt", "ImplementationIdentity"
  )
}

mfrmr_gtds2_assert_run <- function(result) {
  payload_fields <- mfrmr_gtds2_run_payload_fields()
  if (!inherits(result, "mfrmr_gtds2_run") ||
      !identical(names(result), c(payload_fields, "RunHash"))) {
    stop("A typed D-SIM-2 run result is required.", call. = FALSE)
  }
  mfrmr_gtds2_validate_contract(result$Contract)
  terminal <- mfrmr_gtds2_terminal_state(result$Stages[1:3, , drop = FALSE])
  success <- identical(terminal, "plumbing_complete_nonpromoting")
  false_flags <- c(
    "PlannedRngStreamOpened", "TruthRecoveryCompared",
    "BackendComparisonPerformed", "SimulationValidationReady",
    "ReferenceValidationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady", "Dsim3ExecutionAllowed"
  )
  valid <- identical(result$RunHash,
                     mfrmr_gtds2_hash(result[payload_fields])) &&
    identical(result$ImplementationIdentity,
              mfrmr_gtds2_function_identity()) &&
    identical(nrow(result$Stages), 4L) &&
    identical(result$Stages$StageOrdinal, 1:4) &&
    identical(result$Stages$StageId,
              c("generator", "fit", "metric", "terminal_state")) &&
    identical(result$Stages$StageStatus[[4L]], "completed") &&
    identical(result$Summary$TerminalState, terminal) &&
    identical(result$Summary$Dsim2Satisfied, success) &&
    identical(result$Summary$BoundedInternalRouteImplemented, success) &&
    identical(result$Summary$Dsim3DesignConstructionAllowed, success) &&
    identical(result$Summary$FeatureMaturity, "specified") &&
    !any(vapply(false_flags, function(name) {
      isTRUE(result$Summary[[name]])
    }, logical(1L)))
  if (success) {
    valid <- valid && is.list(result$GenerationReceipt) &&
      is.list(result$FitReceipt) && is.list(result$MetricReceipt) &&
      identical(result$GenerationReceipt$FixtureId,
                result$Contract$FixtureId) &&
      identical(result$GenerationReceipt$CandidateRows,
                result$Contract$ExpectedRows) &&
      !isTRUE(result$GenerationReceipt$PlanSeedCollision) &&
      identical(result$FitReceipt$FitStatus, "identified_point_fit") &&
      identical(result$FitReceipt$SharedObservationLinks, 0L) &&
      is.finite(result$MetricReceipt$G) &&
      is.finite(result$MetricReceipt$Phi) &&
      isTRUE(result$MetricReceipt$PhiNotGreaterThanG) &&
      !isTRUE(result$MetricReceipt$TruthCompared) &&
      !isTRUE(result$MetricReceipt$TargetCompared) &&
      !isTRUE(result$MetricReceipt$MetricPromotable)
  }
  if (!valid) {
    stop("The D-SIM-2 run result or readiness was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds2_run <- function(
    plan = mfrmr_gtvd_plan(),
    registry = mfrmr_gtve_fixture_registry(plan),
    contract = mfrmr_gtds2_contract()) {
  mfrmr_gtds2_require_primitives()
  mfrmr_gtds2_validate_contract(contract)
  mfrmr_gtvd_assert_plan(plan)
  fixture <- registry[registry$FixtureId == contract$FixtureId, , drop = FALSE]
  if (nrow(fixture) != 1L || fixture$FixtureSeed != contract$FixtureSeed ||
      fixture$ExpectedRows != contract$ExpectedRows ||
      isTRUE(fixture$PlanSeedCollision) ||
      isTRUE(fixture$RecoveryDenominatorEligible)) {
    stop("The D-SIM-2 nonreserved fixture registry is invalid.", call. = FALSE)
  }

  generation_receipt <- fit_receipt <- metric_receipt <- NULL
  generated <- fitted <- NULL
  stages <- list()

  generation_attempt <- tryCatch({
    generation <- mfrmr_gtve_generate_fixture(
      contract$FixtureId, plan, registry
    )
    candidate <- mfrmr_gtds2_eventize(
      generation, plan, registry, contract
    )
    payload <- list(
      FixtureId = contract$FixtureId,
      FixtureSeed = contract$FixtureSeed,
      FixtureStage = contract$FixtureStage,
      PlanSeedRegistryComparedForCollisionOnly = TRUE,
      PlanSeedCollision = isTRUE(fixture$PlanSeedCollision),
      PlannedRngStreamOpened = FALSE,
      GenerationHash = generation$GenerationHash,
      CandidateDataHash = generation$Identity$CandidateDataHash,
      EventizedDataHash = mfrmr_gtds2_hash(candidate),
      CandidateRows = as.integer(nrow(candidate)),
      ObservationEventRelationship =
        contract$ObservationEventRelationship,
      TruthReleasedDownstream = FALSE
    )
    list(
      ok = TRUE, generation = generation, candidate = candidate,
      receipt = c(payload, list(
        ReceiptHash = mfrmr_gtds2_hash(payload)
      ))
    )
  }, error = function(error) list(ok = FALSE, error = error))
  if (isTRUE(generation_attempt$ok)) {
    generated <- generation_attempt
    generation_receipt <- generated$receipt
    stages[[1L]] <- mfrmr_gtds2_stage_row(
      1L, "generator", "completed", generation_receipt$ReceiptHash
    )
  } else {
    stages[[1L]] <- mfrmr_gtds2_stage_row(
      1L, "generator", "failed", error = generation_attempt$error
    )
  }

  if (isTRUE(generation_attempt$ok)) {
    fit_attempt <- tryCatch({
      output <- mfrmr_gtds2_fit(generated$candidate, contract)
      list(ok = TRUE, output = output)
    }, error = function(error) list(ok = FALSE, error = error))
    if (isTRUE(fit_attempt$ok)) {
      fitted <- fit_attempt$output
      fit_receipt <- fitted$Receipt
      stages[[2L]] <- mfrmr_gtds2_stage_row(
        2L, "fit", "completed", fit_receipt$ReceiptHash
      )
    } else {
      stages[[2L]] <- mfrmr_gtds2_stage_row(
        2L, "fit", "failed", error = fit_attempt$error
      )
    }
  } else {
    stages[[2L]] <- mfrmr_gtds2_stage_row(
      2L, "fit", "not_attempted_dependency"
    )
  }

  if (isTRUE(generation_attempt$ok) && isTRUE(fit_attempt$ok)) {
    metric_attempt <- tryCatch({
      receipt <- mfrmr_gtds2_metric(
        fitted$Fit, generated$candidate, contract
      )
      list(ok = TRUE, receipt = receipt)
    }, error = function(error) list(ok = FALSE, error = error))
    if (isTRUE(metric_attempt$ok)) {
      metric_receipt <- metric_attempt$receipt
      stages[[3L]] <- mfrmr_gtds2_stage_row(
        3L, "metric", "completed", metric_receipt$MetricReceiptHash
      )
    } else {
      stages[[3L]] <- mfrmr_gtds2_stage_row(
        3L, "metric", "failed", error = metric_attempt$error
      )
    }
  } else {
    stages[[3L]] <- mfrmr_gtds2_stage_row(
      3L, "metric", "not_attempted_dependency"
    )
  }

  stage_registry <- do.call(rbind, stages)
  terminal <- mfrmr_gtds2_terminal_state(stage_registry)
  terminal_hash <- mfrmr_gtds2_hash(list(
    ContractHash = contract$ContractHash,
    TerminalState = terminal,
    StageRegistry = stage_registry
  ))
  stage_registry <- rbind(
    stage_registry,
    mfrmr_gtds2_stage_row(
      4L, "terminal_state", "completed", terminal_hash
    )
  )
  success <- identical(terminal, "plumbing_complete_nonpromoting")
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    TerminalState = terminal,
    AttemptCount = 1L,
    AttemptTerminallyCounted = TRUE,
    StochasticNonreservedFixtureGenerated =
      identical(stage_registry$StageStatus[[1L]], "completed"),
    FitExecuted = identical(stage_registry$StageStatus[[2L]], "completed"),
    MetricComputed = identical(stage_registry$StageStatus[[3L]], "completed"),
    Dsim2Satisfied = success,
    BoundedInternalRouteImplemented = success,
    FeatureMaturity = "specified",
    Dsim3DesignConstructionAllowed = success,
    Dsim3ExecutionAllowed = FALSE,
    PlannedRngStreamOpened = FALSE,
    TruthRecoveryCompared = FALSE,
    BackendComparisonPerformed = FALSE,
    SimulationValidationReady = FALSE,
    ReferenceValidationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE,
    NextAction = if (success) {
      paste(
        "construct the D-SIM-3 exploratory coverage manifest from the v4",
        "axes without generating its responses or opening planned RNG streams"
      )
    } else {
      "repair the failed D-SIM-2 stage before any D-SIM-3 work"
    }
  )
  implementation <- mfrmr_gtds2_function_identity()
  payload <- list(
    Contract = contract, Summary = summary, Stages = stage_registry,
    GenerationReceipt = generation_receipt, FitReceipt = fit_receipt,
    MetricReceipt = metric_receipt,
    ImplementationIdentity = implementation
  )
  result <- structure(c(payload, list(
    RunHash = mfrmr_gtds2_hash(payload)
  )), class = c("mfrmr_gtds2_run", "list"))
  mfrmr_gtds2_assert_run(result)
  result
}
