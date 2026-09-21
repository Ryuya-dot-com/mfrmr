# Internal D-SIM-3 two-family fit/metric shadow worker.
#
# This worker executes only the existing nonreserved 854 shadow fixtures. It
# qualifies design-template execution and maps that evidence to every exact
# 856 request identity without opening an 856 RNG stream or counting a shadow
# fit as exploratory recovery evidence.

mfrmr_gtds3w_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3x_manifest",
    "mfrmr_gtds3x_assert_manifest", "mfrmr_gtds3g_generate_profile",
    "mfrmr_gtds3g_assert_generation", "mfrmr_gtds3r_route_payload",
    "mfrmr_gtds3r_assert_route_payload", "mfrmr_gtds3o_project_profile",
    "mfrmr_gtds3p_plan"
  )
  target <- environment(mfrmr_gtds3w_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 request, generator, route, and operator chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  if (!requireNamespace("lme4", quietly = TRUE)) {
    stop("The D-SIM-3 shadow worker requires `lme4`.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3w_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3w_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-FIT-METRIC-SHADOW-WORKER-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentRequestContractHash =
      "c37fbedb03f0535d2e8aab1380949385ba10b0fc32b205f77df17074d52fd67e",
    ParentRequestManifestHash =
      "69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef",
    ParentGeneratorContractHash =
      "92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4",
    ParentRouteContractHash =
      "0b74d833dc9bff44e3eded32261258b8dbd5ca6a2a30805c871d2cc22c9d0129",
    ParentOperatorContractHash =
      "89b158391acf18c090ab708d39780499f3fbf3882ec912e04a3e8d775263693a",
    ParentSupersedingPlanHash =
      "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a"
  )
}

mfrmr_gtds3w_environment_registry <- function() {
  lmer <- getFromNamespace("lmer", "lme4")
  varcorr <- getFromNamespace("VarCorr.merMod", "lme4")
  data.frame(
    IdentityOrdinal = 1:7,
    IdentityId = c(
      "R_version", "platform", "Matrix_version", "lme4_version",
      "digest_version", "lmer_function", "VarCorr_function"
    ),
    IdentityValue = c(
      as.character(getRversion()), R.version$platform,
      as.character(utils::packageVersion("Matrix")),
      as.character(utils::packageVersion("lme4")),
      as.character(utils::packageVersion("digest")),
      mfrmr_gtds3w_hash(list(Formals = formals(lmer), Body = body(lmer))),
      mfrmr_gtds3w_hash(list(
        Formals = formals(varcorr), Body = body(varcorr)
      ))
    ),
    ExactIdentityObserved = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3w_formula_registry <- function() {
  data.frame(
    FormulaClassOrdinal = 1:6,
    ModelSpecificationId = c(
      "separate_univariate::crossed::separate_error",
      "separate_univariate::crossed::combined_error",
      "separate_univariate::nested::separate_error",
      "separate_univariate::nested::combined_error",
      "multivariate_lme4_restricted::crossed::separate_error",
      "multivariate_lme4_restricted::nested::combined_error"
    ),
    RouteId = c(rep("separate_univariate", 4L),
                rep("multivariate_lme4_restricted", 2L)),
    CrossingClass = c("crossed", "crossed", "nested", "nested",
                      "crossed", "nested"),
    RepeatRepresentation = c(
      "separate_error", "combined_error", "separate_error",
      "combined_error", "separate_error", "combined_error"
    ),
    FormulaCanonical = c(
      "Score ~ 1 + (1 | ObjectId) + (1 | ConditionId) + (1 | ObjectConditionId)",
      "Score ~ 1 + (1 | ObjectId) + (1 | ConditionId)",
      "Score ~ 1 + (1 | ObjectId) + (1 | ConditionId)",
      "Score ~ 1 + (1 | ObjectId)",
      paste(
        "Score ~ 0 + Stratum + (0 + Stratum | ObjectId) +",
        "(0 + Stratum | ConditionId) +",
        "(0 + Stratum | ObjectConditionId)"
      ),
      "Score ~ 0 + Stratum + (0 + Stratum | ObjectId)"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3w_contract <- function() {
  mfrmr_gtds3w_require_primitives()
  identity <- mfrmr_gtds3w_identity()
  payload <- c(identity, list(
    ExpectedScenarioCount = 21L,
    ExpectedTemplateRouteCount = 25L,
    ExpectedSeparateTemplateCount = 21L,
    ExpectedMultivariateTemplateCount = 4L,
    ExpectedFormulaClassCount = 6L,
    ExpectedFitCallCount = 51L,
    ExpectedCoefficientRowCount = 57L,
    ExpectedTemplateMetricVectorCount = 50L,
    ExpectedBackendRequestCoverageCount = 50L,
    ExpectedMetricRequestCoverageCount = 100L,
    EnvironmentRegistry = mfrmr_gtds3w_environment_registry(),
    FormulaRegistry = mfrmr_gtds3w_formula_registry(),
    Backend = "lme4",
    Criterion = "REML",
    MetricOutputShape = "named_per_stratum_G_Phi_vectors",
    ScalarPoolingAcrossStrataAllowed = FALSE,
    PackageSelectedDecisionWeightsAllowed = FALSE,
    CrossRouteVotingAllowed = FALSE,
    CrossStratumCovarianceUsedInCoefficient = FALSE,
    DiagnosticOverrideAllowed = FALSE,
    TemplateEvidenceMayCoverDuplicateReplicateRequests = TRUE,
    TemplateEvidenceCountsAsExploratoryAttempt = FALSE,
    ShadowSeedMinimum = 854100001L,
    ShadowSeedMaximum = 854100021L,
    ReservedSeedLowerInclusive = 855000000L,
    Planned856RngStreamMayOpen = FALSE,
    ScenarioSpecificPatchCount = 0L,
    RecoveryClaimAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3w_hash(payload)
  )), class = c("mfrmr_gtds3w_contract", "list"))
}

mfrmr_gtds3w_validate_contract <- function(
    contract = mfrmr_gtds3w_contract()) {
  canonical <- mfrmr_gtds3w_contract()
  formulas <- contract$FormulaRegistry
  valid <- inherits(contract, "mfrmr_gtds3w_contract") &&
    identical(contract, canonical) && nrow(formulas) == 6L &&
    !anyDuplicated(formulas$ModelSpecificationId) &&
    identical(contract$ExpectedFitCallCount, 51L) &&
    identical(contract$ExpectedCoefficientRowCount, 57L) &&
    identical(contract$Backend, "lme4") &&
    identical(contract$Criterion, "REML") &&
    identical(contract$MetricOutputShape,
              "named_per_stratum_G_Phi_vectors") &&
    !isTRUE(contract$ScalarPoolingAcrossStrataAllowed) &&
    !isTRUE(contract$PackageSelectedDecisionWeightsAllowed) &&
    !isTRUE(contract$CrossRouteVotingAllowed) &&
    !isTRUE(contract$CrossStratumCovarianceUsedInCoefficient) &&
    !isTRUE(contract$DiagnosticOverrideAllowed) &&
    isTRUE(contract$TemplateEvidenceMayCoverDuplicateReplicateRequests) &&
    !isTRUE(contract$TemplateEvidenceCountsAsExploratoryAttempt) &&
    contract$ShadowSeedMaximum < contract$ReservedSeedLowerInclusive &&
    !isTRUE(contract$Planned856RngStreamMayOpen) &&
    identical(contract$ScenarioSpecificPatchCount, 0L) &&
    !isTRUE(contract$RecoveryClaimAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 fit/metric shadow-worker contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3w_formula <- function(model_specification_id, contract) {
  row <- contract$FormulaRegistry[
    contract$FormulaRegistry$ModelSpecificationId == model_specification_id,
    , drop = FALSE
  ]
  if (nrow(row) != 1L) {
    stop("The worker model specification is not frozen.", call. = FALSE)
  }
  stats::as.formula(row$FormulaCanonical[[1L]])
}

mfrmr_gtds3w_capture_lmer <- function(formula, data) {
  warnings <- character()
  messages <- character()
  fit <- tryCatch(withCallingHandlers(
    lme4::lmer(
      formula, data = data, REML = TRUE,
      control = lme4::lmerControl(), na.action = stats::na.fail
    ),
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    },
    message = function(condition) {
      messages <<- c(messages, conditionMessage(condition))
      invokeRestart("muffleMessage")
    }
  ), error = function(condition) condition)
  list(Fit = fit, Warnings = warnings, Messages = messages)
}

mfrmr_gtds3w_prepare_data <- function(data, strata = NULL) {
  output <- data
  for (column in c(
    "Stratum", "ObjectId", "ConditionId", "ObjectConditionId", "EventId"
  )) {
    output[[column]] <- factor(output[[column]])
  }
  if (!is.null(strata)) {
    output$Stratum <- factor(as.character(output$Stratum), levels = strata)
  }
  output
}

mfrmr_gtds3w_scalar_variance <- function(fit, group) {
  table <- as.data.frame(lme4::VarCorr(fit))
  row <- table$grp == group & table$var1 == "(Intercept)" &
    is.na(table$var2)
  if (sum(row) != 1L || !is.finite(table$vcov[row]) ||
      table$vcov[row] < 0) {
    stop("A scalar fitted variance component is missing.", call. = FALSE)
  }
  as.numeric(table$vcov[row])
}

mfrmr_gtds3w_multivariate_diagonal <- function(fit, group, data, strata) {
  variance <- lme4::VarCorr(fit)
  if (!group %in% names(variance)) {
    stop("A multivariate fitted covariance block is missing.", call. = FALSE)
  }
  design <- stats::model.matrix(~ 0 + Stratum, data = data)
  columns <- colnames(design)
  if (length(columns) != length(strata) ||
      !all(columns %in% rownames(variance[[group]]))) {
    stop("A multivariate covariance block lost its stratum names.",
         call. = FALSE)
  }
  values <- diag(as.matrix(variance[[group]])[columns, columns, drop = FALSE])
  if (any(!is.finite(values)) || any(values < 0)) {
    stop("A multivariate covariance diagonal is invalid.", call. = FALSE)
  }
  stats::setNames(as.numeric(values), strata)
}

mfrmr_gtds3w_diagnostic_text <- function(value) {
  if (is.null(value) || length(value) == 0L) return("")
  paste(as.character(value), collapse = " | ")
}

mfrmr_gtds3w_fit_receipt <- function(
    fit, capture, template_id, fit_call_id, scenario_id, route_id,
    model_specification_id, stratum, formula, data, variance_payload) {
  convergence <- mfrmr_gtds3w_diagnostic_text(
    fit@optinfo$conv$lme4$messages
  )
  payload <- list(
    TemplateId = template_id, FitCallId = fit_call_id,
    ScenarioId = scenario_id, RouteId = route_id,
    ModelSpecificationId = model_specification_id, Stratum = stratum,
    FormulaCanonical = paste(deparse(formula, width.cutoff = 500L),
                             collapse = " "),
    ObservationCount = as.integer(stats::nobs(fit)),
    LogLikelihood = as.numeric(stats::logLik(fit)),
    VariancePayload = variance_payload,
    Singular = lme4::isSingular(fit),
    ConvergenceMessage = convergence,
    WarningText = mfrmr_gtds3w_diagnostic_text(capture$Warnings),
    MessageText = mfrmr_gtds3w_diagnostic_text(capture$Messages)
  )
  data.frame(
    TemplateId = template_id,
    FitCallId = fit_call_id,
    ScenarioId = scenario_id,
    RouteId = route_id,
    ModelSpecificationId = model_specification_id,
    Stratum = stratum,
    FormulaCanonical = payload$FormulaCanonical,
    ObservationCount = payload$ObservationCount,
    LogLikelihood = payload$LogLikelihood,
    Singular = payload$Singular,
    ConvergenceMessage = convergence,
    WarningCount = length(capture$Warnings),
    WarningText = payload$WarningText,
    MessageCount = length(capture$Messages),
    MessageText = payload$MessageText,
    FitReceiptHash = mfrmr_gtds3w_hash(payload),
    BackendCallMade = TRUE,
    FitReturned = TRUE,
    DiagnosticOverrideApplied = FALSE,
    CountsAsExploratoryAttempt = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3w_block_rows <- function(
    scenario_id, route_id, template_id, crossing, repeat_count, strata,
    object, condition = NULL, object_condition = NULL, residual,
    operators) {
  rows <- list()
  cursor <- 0L
  add <- function(stratum, block_id, role, value, operator_id) {
    cursor <<- cursor + 1L
    diagonal <- operators[[operator_id]]$OperatorMatrix[stratum, stratum]
    rows[[cursor]] <<- data.frame(
      TemplateId = template_id, ScenarioId = scenario_id,
      RouteId = route_id, Stratum = stratum,
      FitBlockId = block_id, UniverseRole = role,
      UnitVariance = as.numeric(value),
      OperatorDiagonal = as.numeric(diagonal),
      AllocatedVariance = as.numeric(value * diagonal),
      OperatorId = operator_id,
      OperatorHash = operators[[operator_id]]$OperatorHash,
      CrossStratumCovarianceUsed = FALSE,
      stringsAsFactors = FALSE
    )
  }
  for (stratum in strata) {
    add(stratum, "object", "object", object[[stratum]], "Object")
    if (crossing == "nested") {
      if (repeat_count > 1L) {
        add(stratum, "nested_condition", "relative_error",
            condition[[stratum]], "NestedCondition")
        add(stratum, "event_residual", "relative_error",
            residual[[stratum]], "Residual")
      } else {
        add(stratum, "combined_nested_condition_event_residual",
            "relative_error", residual[[stratum]], "Residual")
      }
    } else {
      add(stratum, "condition", "absolute_only",
          condition[[stratum]], "Rater")
      if (repeat_count > 1L) {
        add(stratum, "object_condition", "relative_error",
            object_condition[[stratum]], "Object:Rater")
        add(stratum, "event_residual", "relative_error",
            residual[[stratum]], "Residual")
      } else {
        add(stratum, "combined_object_condition_event_residual",
            "relative_error", residual[[stratum]], "Residual")
      }
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3w_coefficients <- function(blocks) {
  keys <- unique(blocks[c("TemplateId", "ScenarioId", "RouteId", "Stratum")])
  rows <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    part <- blocks[
      blocks$TemplateId == key$TemplateId & blocks$Stratum == key$Stratum,
      , drop = FALSE
    ]
    universe <- sum(part$AllocatedVariance[part$UniverseRole == "object"])
    relative <- sum(
      part$AllocatedVariance[part$UniverseRole == "relative_error"]
    )
    absolute_only <- sum(
      part$AllocatedVariance[part$UniverseRole == "absolute_only"]
    )
    denominator_g <- universe + relative
    denominator_phi <- universe + relative + absolute_only
    ready <- is.finite(universe) && universe > 0 &&
      is.finite(denominator_g) && denominator_g > 0 &&
      is.finite(denominator_phi) && denominator_phi > 0 &&
      all(part$AllocatedVariance >= 0)
    g <- if (ready) universe / denominator_g else NA_real_
    phi <- if (ready) universe / denominator_phi else NA_real_
    payload <- list(
      TemplateId = key$TemplateId, ScenarioId = key$ScenarioId,
      RouteId = key$RouteId, Stratum = key$Stratum,
      UniverseVariance = universe, RelativeErrorVariance = relative,
      AbsoluteOnlyVariance = absolute_only, G = g, Phi = phi,
      BlockHashes = part$OperatorHash,
      BlockValues = part$AllocatedVariance
    )
    data.frame(
      key,
      UniverseVariance = universe,
      RelativeErrorVariance = relative,
      AbsoluteOnlyVariance = absolute_only,
      AbsoluteErrorVariance = relative + absolute_only,
      G = g, Phi = phi,
      CoefficientReady = ready,
      PhiNotGreaterThanG = ready && phi <= g + 1e-12,
      CoefficientHash = mfrmr_gtds3w_hash(payload),
      ScalarPoolingApplied = FALSE,
      CrossStratumCovarianceUsed = FALSE,
      CountsAsRecoveryEvidence = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3w_fit_template <- function(
    generation, route_unit, backend_request, operator_profile,
    contract = mfrmr_gtds3w_contract(),
    route_contract = mfrmr_gtds3r_contract()) {
  payload <- mfrmr_gtds3r_route_payload(
    generation, route_unit, route_contract
  )
  mfrmr_gtds3r_assert_route_payload(
    payload, generation, route_unit, route_contract
  )
  profile <- unlist(generation$Profile, use.names = TRUE)
  crossing <- as.character(profile[["crossing"]])
  crossing_class <- if (crossing == "nested") "nested" else "crossed"
  repeat_count <- as.integer(profile[["repeat_count"]])
  model_id <- backend_request$ModelSpecificationId[[1L]]
  formula <- mfrmr_gtds3w_formula(model_id, contract)
  template_id <- paste0(
    "D3W-T-", backend_request$ScenarioId[[1L]], "-",
    if (backend_request$RouteId[[1L]] == "separate_univariate") "SU" else "MV"
  )
  strata <- names(operator_profile$Operators[[1L]]$Strata)
  if (is.null(strata)) strata <- operator_profile$Operators[[1L]]$Strata
  route_id <- backend_request$RouteId[[1L]]
  receipts <- list()
  if (route_id == "separate_univariate") {
    block_parts <- list()
    for (index in seq_along(payload$PayloadPartitions)) {
      stratum <- names(payload$PayloadPartitions)[[index]]
      data <- mfrmr_gtds3w_prepare_data(payload$PayloadPartitions[[index]])
      captured <- mfrmr_gtds3w_capture_lmer(formula, data)
      if (inherits(captured$Fit, "error")) {
        stop("A separate-univariate shadow fit failed for ",
             generation$ScenarioId, "/", stratum, ": ",
             conditionMessage(captured$Fit), call. = FALSE)
      }
      fit <- captured$Fit
      object <- stats::setNames(
        mfrmr_gtds3w_scalar_variance(fit, "ObjectId"), stratum
      )
      condition <- if ("ConditionId" %in% names(lme4::VarCorr(fit))) {
        stats::setNames(
          mfrmr_gtds3w_scalar_variance(fit, "ConditionId"), stratum
        )
      } else NULL
      interaction <- if ("ObjectConditionId" %in%
                         names(lme4::VarCorr(fit))) {
        stats::setNames(
          mfrmr_gtds3w_scalar_variance(fit, "ObjectConditionId"), stratum
        )
      } else NULL
      residual <- stats::setNames(as.numeric(stats::sigma(fit))^2, stratum)
      variance_payload <- list(
        Object = object, Condition = condition,
        ObjectCondition = interaction, Residual = residual
      )
      fit_call_id <- paste0(template_id, "-", stratum)
      receipts[[index]] <- mfrmr_gtds3w_fit_receipt(
        fit, captured, template_id, fit_call_id, generation$ScenarioId,
        route_id, model_id, stratum, formula, data, variance_payload
      )
      block_parts[[index]] <- mfrmr_gtds3w_block_rows(
        generation$ScenarioId, route_id, template_id, crossing_class,
        repeat_count, stratum, object, condition, interaction, residual,
        operator_profile$Operators
      )
    }
    fit_receipts <- do.call(rbind, receipts)
    blocks <- do.call(rbind, block_parts)
  } else {
    data <- mfrmr_gtds3w_prepare_data(
      payload$PayloadPartitions$joint, strata
    )
    captured <- mfrmr_gtds3w_capture_lmer(formula, data)
    if (inherits(captured$Fit, "error")) {
      stop("A restricted-multivariate shadow fit failed for ",
           generation$ScenarioId, ": ", conditionMessage(captured$Fit),
           call. = FALSE)
    }
    fit <- captured$Fit
    object <- mfrmr_gtds3w_multivariate_diagonal(
      fit, "ObjectId", data, strata
    )
    condition <- if ("ConditionId" %in% names(lme4::VarCorr(fit))) {
      mfrmr_gtds3w_multivariate_diagonal(
        fit, "ConditionId", data, strata
      )
    } else NULL
    interaction <- if ("ObjectConditionId" %in%
                       names(lme4::VarCorr(fit))) {
      mfrmr_gtds3w_multivariate_diagonal(
        fit, "ObjectConditionId", data, strata
      )
    } else NULL
    residual <- stats::setNames(
      rep(as.numeric(stats::sigma(fit))^2, length(strata)), strata
    )
    variance_payload <- list(
      Object = object, Condition = condition,
      ObjectCondition = interaction, Residual = residual
    )
    fit_receipts <- mfrmr_gtds3w_fit_receipt(
      fit, captured, template_id, paste0(template_id, "-joint"),
      generation$ScenarioId, route_id, model_id, "<joint>", formula,
      data, variance_payload
    )
    blocks <- mfrmr_gtds3w_block_rows(
      generation$ScenarioId, route_id, template_id, crossing_class,
      repeat_count, strata, object, condition, interaction, residual,
      operator_profile$Operators
    )
  }
  coefficients <- mfrmr_gtds3w_coefficients(blocks)
  list(
    TemplateId = template_id, RoutePayloadHash = payload$PayloadHash,
    ShadowSeed = generation$ShadowSeed,
    ShadowGenerationHash = generation$GenerationHash,
    FitReceipts = fit_receipts, FittedBlocks = blocks,
    Coefficients = coefficients
  )
}

mfrmr_gtds3w_template_registry <- function(request_manifest) {
  backend <- request_manifest$BackendRequestRegistry
  key <- paste(backend$ScenarioId, backend$RouteId, sep = "::")
  selected <- !duplicated(key)
  templates <- backend[selected, , drop = FALSE]
  templates$TemplateOrdinal <- seq_len(nrow(templates))
  templates$TemplateId <- paste0(
    "D3W-T-", templates$ScenarioId, "-",
    ifelse(templates$RouteId == "separate_univariate", "SU", "MV")
  )
  templates$TemplateReplicate <- templates$Replicate
  templates$CountsAsExploratoryAttempt <- FALSE
  row.names(templates) <- NULL
  templates
}

mfrmr_gtds3w_metric_vectors <- function(coefficients) {
  templates <- unique(coefficients[c("TemplateId", "ScenarioId", "RouteId")])
  rows <- list()
  cursor <- 0L
  for (index in seq_len(nrow(templates))) {
    template <- templates[index, , drop = FALSE]
    part <- coefficients[
      coefficients$TemplateId == template$TemplateId, , drop = FALSE
    ]
    part <- part[order(part$Stratum, method = "radix"), , drop = FALSE]
    for (estimand in c("ABS-PHI", "REL-G")) {
      cursor <- cursor + 1L
      coefficient <- if (estimand == "ABS-PHI") "Phi" else "G"
      values <- part[[coefficient]]
      names(values) <- part$Stratum
      rows[[cursor]] <- data.frame(
        TemplateMetricOrdinal = cursor,
        TemplateId = template$TemplateId,
        ScenarioId = template$ScenarioId,
        RouteId = template$RouteId,
        EstimandId = estimand,
        Coefficient = coefficient,
        StratumCount = length(values),
        StratumNames = paste(names(values), collapse = "|"),
        MinimumValue = min(values), MaximumValue = max(values),
        MetricVectorHash = mfrmr_gtds3w_hash(list(
          TemplateId = template$TemplateId, EstimandId = estimand,
          Values = values, CoefficientHashes = part$CoefficientHash
        )),
        AllStrataReturned = all(is.finite(values)),
        ScalarPoolingApplied = FALSE,
        CountsAsRecoveryEvidence = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3w_request_coverage <- function(
    request_manifest, templates, metrics) {
  backend <- request_manifest$BackendRequestRegistry
  template_key <- paste(templates$ScenarioId, templates$RouteId, sep = "::")
  backend_index <- match(
    paste(backend$ScenarioId, backend$RouteId, sep = "::"), template_key
  )
  backend_coverage <- data.frame(
    BackendRequestCoverageOrdinal = seq_len(nrow(backend)),
    BackendRequestId = backend$BackendRequestId,
    BackendRequestHash = backend$RequestHash,
    RouteUnitId = backend$RouteUnitId,
    ScenarioId = backend$ScenarioId,
    Replicate = backend$Replicate,
    RouteId = backend$RouteId,
    TemplateId = templates$TemplateId[backend_index],
    FormulaClassMatched = backend$ModelSpecificationId ==
      templates$ModelSpecificationId[backend_index],
    ShadowTemplateQualified = TRUE,
    DuplicateReplicateExecutionAvoided = backend$Replicate !=
      templates$TemplateReplicate[backend_index],
    CountsAsExploratoryAttempt = FALSE,
    stringsAsFactors = FALSE
  )
  exact_metric <- request_manifest$MetricRequestRegistry
  metric_key <- paste(
    metrics$ScenarioId, metrics$RouteId, metrics$EstimandId, sep = "::"
  )
  metric_index <- match(
    paste(
      exact_metric$ScenarioId, exact_metric$RouteId,
      exact_metric$EstimandId, sep = "::"
    ), metric_key
  )
  metric_coverage <- data.frame(
    MetricRequestCoverageOrdinal = seq_len(nrow(exact_metric)),
    MetricRequestId = exact_metric$MetricRequestId,
    MetricRequestHash = exact_metric$RequestHash,
    CoordinateId = exact_metric$CoordinateId,
    ScenarioId = exact_metric$ScenarioId,
    Replicate = exact_metric$Replicate,
    RouteId = exact_metric$RouteId,
    EstimandId = exact_metric$EstimandId,
    TemplateId = metrics$TemplateId[metric_index],
    MetricVectorHash = metrics$MetricVectorHash[metric_index],
    AllStrataReturned = metrics$AllStrataReturned[metric_index],
    ScalarPoolingApplied = FALSE,
    CountsAsRecoveryEvidence = FALSE,
    stringsAsFactors = FALSE
  )
  list(Backend = backend_coverage, Metric = metric_coverage)
}

mfrmr_gtds3w_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3w_require_primitives", "mfrmr_gtds3w_hash",
    "mfrmr_gtds3w_identity", "mfrmr_gtds3w_environment_registry",
    "mfrmr_gtds3w_formula_registry", "mfrmr_gtds3w_contract",
    "mfrmr_gtds3w_validate_contract", "mfrmr_gtds3w_formula",
    "mfrmr_gtds3w_capture_lmer", "mfrmr_gtds3w_prepare_data",
    "mfrmr_gtds3w_scalar_variance",
    "mfrmr_gtds3w_multivariate_diagonal",
    "mfrmr_gtds3w_diagnostic_text", "mfrmr_gtds3w_fit_receipt",
    "mfrmr_gtds3w_block_rows", "mfrmr_gtds3w_coefficients",
    "mfrmr_gtds3w_fit_template", "mfrmr_gtds3w_template_registry",
    "mfrmr_gtds3w_metric_vectors", "mfrmr_gtds3w_request_coverage",
    "mfrmr_gtds3w_implementation_identity", "mfrmr_gtds3w_manifest_fields",
    "mfrmr_gtds3w_manifest", "mfrmr_gtds3w_assert_manifest"
  )
  target <- environment(mfrmr_gtds3w_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3w_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3w_manifest_fields <- function() {
  c(
    "Contract", "ParentRequestManifestHash", "EnvironmentIdentityRegistry",
    "TemplateRegistry", "FitReceiptRegistry", "FittedBlockRegistry",
    "FittedCoefficientRegistry", "TemplateMetricVectorRegistry",
    "BackendRequestCoverageRegistry", "MetricRequestCoverageRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3w_manifest <- function(
    contract = mfrmr_gtds3w_contract(),
    request_manifest = mfrmr_gtds3x_manifest(),
    plan = mfrmr_gtds3p_plan(), coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3w_validate_contract(contract)
  mfrmr_gtds3x_assert_manifest(request_manifest)
  if (!identical(request_manifest$Contract$ContractHash,
                 contract$ParentRequestContractHash) ||
      !identical(request_manifest$ManifestHash,
                 contract$ParentRequestManifestHash) ||
      !identical(mfrmr_gtds3g_contract()$ContractHash,
                 contract$ParentGeneratorContractHash) ||
      !identical(mfrmr_gtds3r_contract()$ContractHash,
                 contract$ParentRouteContractHash) ||
      !identical(mfrmr_gtds3o_contract()$ContractHash,
                 contract$ParentOperatorContractHash) ||
      !identical(plan$PlanHash, contract$ParentSupersedingPlanHash)) {
    stop("A D-SIM-3 shadow-worker parent identity changed.", call. = FALSE)
  }
  templates <- mfrmr_gtds3w_template_registry(request_manifest)
  semantics_manifest <- mfrmr_gtds3s_manifest()
  truth_manifest <- mfrmr_gtds3t_manifest(
    semantics_manifest = semantics_manifest
  )
  fit_rows <- list(); block_rows <- list(); coefficient_rows <- list()
  route_payload_hash <- character(nrow(templates))
  shadow_seed <- integer(nrow(templates))
  shadow_generation_hash <- character(nrow(templates))
  fit_cursor <- block_cursor <- coefficient_cursor <- 0L
  for (scenario_id in coverage$ScenarioRegistry$ScenarioId) {
    generation <- mfrmr_gtds3g_generate_profile(
      scenario_id, coverage = coverage, validate = FALSE
    )
    mfrmr_gtds3g_assert_generation(
      generation, coverage = coverage, validate = FALSE, replay = FALSE
    )
    operator <- mfrmr_gtds3o_project_profile(
      scenario_id, truth_manifest = truth_manifest,
      semantics_manifest = semantics_manifest,
      coverage = coverage, validate = FALSE
    )
    scenario_templates <- which(templates$ScenarioId == scenario_id)
    for (template_index in scenario_templates) {
      backend_request <- templates[template_index, , drop = FALSE]
      route_unit <- plan$RouteUnitRegistry[
        plan$RouteUnitRegistry$RouteUnitId ==
          backend_request$RouteUnitId[[1L]], , drop = FALSE
      ]
      result <- mfrmr_gtds3w_fit_template(
        generation, route_unit, backend_request, operator, contract
      )
      route_payload_hash[[template_index]] <- result$RoutePayloadHash
      shadow_seed[[template_index]] <- result$ShadowSeed
      shadow_generation_hash[[template_index]] <-
        result$ShadowGenerationHash
      for (index in seq_len(nrow(result$FitReceipts))) {
        fit_cursor <- fit_cursor + 1L
        fit_rows[[fit_cursor]] <- result$FitReceipts[index, , drop = FALSE]
      }
      for (index in seq_len(nrow(result$FittedBlocks))) {
        block_cursor <- block_cursor + 1L
        block_rows[[block_cursor]] <- result$FittedBlocks[index, , drop = FALSE]
      }
      for (index in seq_len(nrow(result$Coefficients))) {
        coefficient_cursor <- coefficient_cursor + 1L
        coefficient_rows[[coefficient_cursor]] <-
          result$Coefficients[index, , drop = FALSE]
      }
    }
  }
  templates$RoutePayloadHash <- route_payload_hash
  templates$ShadowSeed <- shadow_seed
  templates$ShadowGenerationHash <- shadow_generation_hash
  templates$TemplateShadowQualified <- TRUE
  templates$ExploratoryExecutionOpened <- FALSE
  fits <- do.call(rbind, fit_rows)
  blocks <- do.call(rbind, block_rows)
  coefficients <- do.call(rbind, coefficient_rows)
  row.names(templates) <- row.names(fits) <- row.names(blocks) <-
    row.names(coefficients) <- NULL
  metrics <- mfrmr_gtds3w_metric_vectors(coefficients)
  coverage_map <- mfrmr_gtds3w_request_coverage(
    request_manifest, templates, metrics
  )
  implementation <- mfrmr_gtds3w_implementation_identity()
  environment <- mfrmr_gtds3w_environment_registry()
  summary <- list(
    ScenarioCount = length(unique(templates$ScenarioId)),
    TemplateRouteCount = nrow(templates),
    SeparateTemplateCount = sum(
      templates$RouteId == "separate_univariate"
    ),
    MultivariateTemplateCount = sum(
      templates$RouteId == "multivariate_lme4_restricted"
    ),
    FormulaClassCount = length(unique(templates$ModelSpecificationId)),
    FitCallCount = nrow(fits),
    SuccessfulFitCallCount = sum(fits$FitReturned),
    SingularFitCallCount = sum(fits$Singular),
    FitCallWithWarningCount = sum(fits$WarningCount > 0L),
    FitCallWithConvergenceMessageCount = sum(
      nzchar(fits$ConvergenceMessage)
    ),
    CoefficientRowCount = nrow(coefficients),
    ReadyCoefficientRowCount = sum(coefficients$CoefficientReady),
    TemplateMetricVectorCount = nrow(metrics),
    CompleteTemplateMetricVectorCount = sum(metrics$AllStrataReturned),
    BackendRequestCoverageCount = nrow(coverage_map$Backend),
    QualifiedBackendRequestCoverageCount = sum(
      coverage_map$Backend$ShadowTemplateQualified
    ),
    MetricRequestCoverageCount = nrow(coverage_map$Metric),
    QualifiedMetricRequestCoverageCount = sum(
      coverage_map$Metric$AllStrataReturned
    ),
    DuplicateReplicateFitCountAvoided = sum(
      coverage_map$Backend$DuplicateReplicateExecutionAvoided
    ),
    EnvironmentIdentityFrozen = TRUE,
    FitMetricWorkerShadowQualified = TRUE,
    TerminalResourceOrchestratorQualified = FALSE,
    LaunchReadinessReconciled = FALSE,
    ShadowRngStreamMinimum = min(templates$ShadowSeed),
    ShadowRngStreamMaximum = max(templates$ShadowSeed),
    Planned855RngStreamOpened = FALSE,
    Planned856RngStreamOpened = FALSE,
    ExploratoryResponseGenerated = FALSE,
    ExploratoryBackendCallMade = FALSE,
    RecoveryEvidenceComputed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "bind the qualified worker to terminal and resource orchestration on",
      "nonreserved shadow fixtures then rerun identity-bound reconciliation"
    )
  )
  payload <- list(
    Contract = contract,
    ParentRequestManifestHash = request_manifest$ManifestHash,
    EnvironmentIdentityRegistry = environment,
    TemplateRegistry = templates,
    FitReceiptRegistry = fits,
    FittedBlockRegistry = blocks,
    FittedCoefficientRegistry = coefficients,
    TemplateMetricVectorRegistry = metrics,
    BackendRequestCoverageRegistry = coverage_map$Backend,
    MetricRequestCoverageRegistry = coverage_map$Metric,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3w_hash(payload)
  )), class = c("mfrmr_gtds3w_manifest", "list"))
  mfrmr_gtds3w_assert_manifest(manifest)
  manifest
}

mfrmr_gtds3w_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3w_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3w_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 fit/metric worker manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  templates <- manifest$TemplateRegistry
  fits <- manifest$FitReceiptRegistry
  blocks <- manifest$FittedBlockRegistry
  coefficients <- manifest$FittedCoefficientRegistry
  metrics <- manifest$TemplateMetricVectorRegistry
  backend <- manifest$BackendRequestCoverageRegistry
  metric <- manifest$MetricRequestCoverageRegistry
  summary <- manifest$Summary
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3w_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3w_contract()) &&
    identical(manifest$EnvironmentIdentityRegistry,
              mfrmr_gtds3w_environment_registry()) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds3w_implementation_identity()) &&
    identical(nrow(templates), 25L) &&
    identical(sum(templates$RouteId == "separate_univariate"), 21L) &&
    identical(sum(
      templates$RouteId == "multivariate_lme4_restricted"
    ), 4L) &&
    !anyDuplicated(templates$TemplateId) &&
    all(templates$TemplateShadowQualified) &&
    all(!templates$ExploratoryExecutionOpened) &&
    identical(range(templates$ShadowSeed), c(854100001L, 854100021L)) &&
    all(templates$ShadowSeed < contract$ReservedSeedLowerInclusive) &&
    identical(length(unique(templates$ModelSpecificationId)), 6L) &&
    identical(nrow(fits), 51L) && !anyDuplicated(fits$FitCallId) &&
    all(fits$BackendCallMade) && all(fits$FitReturned) &&
    all(!fits$DiagnosticOverrideApplied) &&
    all(!fits$CountsAsExploratoryAttempt) &&
    all(is.finite(fits$LogLikelihood)) &&
    identical(nrow(coefficients), 57L) &&
    !anyDuplicated(paste(coefficients$TemplateId, coefficients$Stratum)) &&
    all(coefficients$CoefficientReady) &&
    all(coefficients$PhiNotGreaterThanG) &&
    all(is.finite(coefficients$G)) && all(is.finite(coefficients$Phi)) &&
    all(coefficients$G >= 0 & coefficients$G <= 1) &&
    all(coefficients$Phi >= 0 & coefficients$Phi <= 1) &&
    all(!coefficients$ScalarPoolingApplied) &&
    all(!coefficients$CrossStratumCovarianceUsed) &&
    all(!coefficients$CountsAsRecoveryEvidence) &&
    nrow(blocks) > nrow(coefficients) &&
    all(blocks$UnitVariance >= 0) &&
    all(blocks$OperatorDiagonal > 0) &&
    all(!blocks$CrossStratumCovarianceUsed) &&
    identical(nrow(metrics), 50L) &&
    all(table(metrics$TemplateId) == 2L) &&
    all(metrics$AllStrataReturned) &&
    all(!metrics$ScalarPoolingApplied) &&
    all(!metrics$CountsAsRecoveryEvidence) &&
    identical(nrow(backend), 50L) &&
    !anyDuplicated(backend$BackendRequestId) &&
    all(backend$FormulaClassMatched) &&
    all(backend$ShadowTemplateQualified) &&
    identical(sum(backend$DuplicateReplicateExecutionAvoided), 25L) &&
    all(!backend$CountsAsExploratoryAttempt) &&
    identical(nrow(metric), 100L) &&
    !anyDuplicated(metric$MetricRequestId) &&
    all(metric$AllStrataReturned) &&
    all(!metric$ScalarPoolingApplied) &&
    all(!metric$CountsAsRecoveryEvidence) &&
    identical(summary$ScenarioCount, 21L) &&
    identical(summary$TemplateRouteCount, 25L) &&
    identical(summary$FormulaClassCount, 6L) &&
    identical(summary$FitCallCount, 51L) &&
    identical(summary$SuccessfulFitCallCount, 51L) &&
    identical(summary$CoefficientRowCount, 57L) &&
    identical(summary$ReadyCoefficientRowCount, 57L) &&
    identical(summary$TemplateMetricVectorCount, 50L) &&
    identical(summary$CompleteTemplateMetricVectorCount, 50L) &&
    identical(summary$BackendRequestCoverageCount, 50L) &&
    identical(summary$QualifiedBackendRequestCoverageCount, 50L) &&
    identical(summary$MetricRequestCoverageCount, 100L) &&
    identical(summary$QualifiedMetricRequestCoverageCount, 100L) &&
    identical(summary$DuplicateReplicateFitCountAvoided, 25L) &&
    isTRUE(summary$EnvironmentIdentityFrozen) &&
    isTRUE(summary$FitMetricWorkerShadowQualified) &&
    !isTRUE(summary$TerminalResourceOrchestratorQualified) &&
    !isTRUE(summary$LaunchReadinessReconciled) &&
    !isTRUE(summary$Planned855RngStreamOpened) &&
    !isTRUE(summary$Planned856RngStreamOpened) &&
    !isTRUE(summary$ExploratoryResponseGenerated) &&
    !isTRUE(summary$ExploratoryBackendCallMade) &&
    !isTRUE(summary$RecoveryEvidenceComputed) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-3 fit/metric shadow-worker evidence was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
