# Internal D-SIM-4 interval/attempt worker qualification.
#
# The only executed data are the existing nonreserved D3-S001 shadow fixture.
# Planned 857/858 seeds remain unopened and D-SIM-5 remains unauthorized.

mfrmr_gtds4w_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds4_hash", "mfrmr_gtds4_contract",
    "mfrmr_gtds4_assert_manifest", "mfrmr_gtds4_reference_coefficient",
    "mfrmr_gtds3g_generate_profile", "mfrmr_gtds3g_assert_generation",
    "mfrmr_gtds3w_contract", "mfrmr_gtds3w_formula",
    "mfrmr_gtds3w_prepare_data", "mfrmr_gtds3w_capture_lmer",
    "mfrmr_gtds3w_scalar_variance", "mfrmr_gtds3w_block_rows",
    "mfrmr_gtds3w_coefficients"
  )
  target <- environment(mfrmr_gtds4w_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 generator/fit worker and D-SIM-4 freeze first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  if (!requireNamespace("lme4", quietly = TRUE)) {
    stop("The D-SIM-4 worker qualification requires `lme4`.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds4w_hash <- function(value) mfrmr_gtds4_hash(value)

mfrmr_gtds4w_canonical_code <- function(value) {
  paste(deparse(value, width.cutoff = 500L, control = "all"),
        collapse = "\n")
}

mfrmr_gtds4w_function_hash <- function(fun) {
  mfrmr_gtds4w_hash(list(
    Formals = mfrmr_gtds4w_canonical_code(formals(fun)),
    Body = mfrmr_gtds4w_canonical_code(body(fun))
  ))
}

mfrmr_gtds4w_contract <- function() {
  mfrmr_gtds4w_require_primitives()
  freeze <- mfrmr_gtds4_contract()
  payload <- list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM4-WORKER-QUALIFICATION-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentFreezeContractHash = freeze$ContractHash,
    ParentFreezeManifestHash =
      "8e8b4b3d4f28a1ac9c94a42fbbdb193aa4979c57bf8a6f2d1a5ecb24ee4d713e",
    ParentGeneratorContractHash =
      "92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4",
    ParentFitWorkerContractHash = freeze$ParentFitWorkerContractHash,
    RouteId = "separate_univariate",
    Backend = "lme4",
    Criterion = "REML",
    IntervalMethodId = freeze$IntervalContract$MethodId,
    ConfidenceLevel = freeze$IntervalContract$ConfidenceLevel,
    BootstrapReplicateCount = freeze$IntervalContract$BootstrapReplicateCount,
    QuantileType = freeze$IntervalContract$QuantileType,
    SimulationArguments = list(nsim = 1L, re.form = NA),
    BootstrapOrder = "replicate_then_stratum_lexicographic",
    RngKind = c("Mersenne-Twister", "Inversion", "Rejection"),
    ExpectedOuterRequestCount = freeze$ExpectedOuterAttemptCount,
    ExpectedIntervalOuterCount =
      freeze$ExpectedIntervalEligibleOuterAttemptCount,
    ExpectedInnerAttemptCount = freeze$ExpectedInnerBootstrapAttemptCount,
    QualificationScenarioId = "D3-S001",
    QualificationBootstrapSeed = 854900001L,
    QualificationCountsAsDsim5Attempt = FALSE,
    Planned857SeedMayOpen = FALSE,
    Planned858SeedMayOpen = FALSE,
    Dsim5ExecutionAuthorized = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE,
    BackendFunctionIdentity = c(
      simulate_merMod = mfrmr_gtds4w_function_hash(
        getFromNamespace("simulate.merMod", "lme4")
      ),
      refit_merMod = mfrmr_gtds4w_function_hash(
        getFromNamespace("refit.merMod", "lme4")
      ),
      quantile_default = mfrmr_gtds4w_function_hash(
        getFromNamespace("quantile.default", "stats")
      )
    )
  )
  structure(c(payload, list(
    ContractHash = mfrmr_gtds4w_hash(payload)
  )), class = c("mfrmr_gtds4w_contract", "list"))
}

mfrmr_gtds4w_validate_contract <- function(
    contract = mfrmr_gtds4w_contract()) {
  canonical <- mfrmr_gtds4w_contract()
  valid <- inherits(contract, "mfrmr_gtds4w_contract") &&
    identical(contract, canonical) &&
    identical(contract$BootstrapReplicateCount, 199L) &&
    identical(contract$QuantileType, 7L) &&
    identical(contract$ExpectedOuterRequestCount, 15000L) &&
    identical(contract$ExpectedIntervalOuterCount, 5000L) &&
    identical(contract$ExpectedInnerAttemptCount, 995000L) &&
    !isTRUE(contract$QualificationCountsAsDsim5Attempt) &&
    !isTRUE(contract$Planned857SeedMayOpen) &&
    !isTRUE(contract$Planned858SeedMayOpen) &&
    !isTRUE(contract$Dsim5ExecutionAuthorized) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-4 worker contract is invalid or altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds4w_outer_requests <- function(freeze_manifest,
                                         contract = mfrmr_gtds4w_contract()) {
  mfrmr_gtds4w_validate_contract(contract)
  mfrmr_gtds4_assert_manifest(freeze_manifest)
  if (!identical(freeze_manifest$Contract$ContractHash,
                 contract$ParentFreezeContractHash) ||
      !identical(freeze_manifest$ManifestHash,
                 contract$ParentFreezeManifestHash)) {
    stop("The frozen D-SIM-4 identity changed.", call. = FALSE)
  }
  attempts <- freeze_manifest$AttemptRegistry
  scenarios <- freeze_manifest$ScenarioRegistry
  index <- match(attempts$ConfirmationScenarioId,
                 scenarios$ConfirmationScenarioId)
  stratum_count <- c(one = 1L, two = 2L, three = 3L)[
    scenarios$stratum_count[index]
  ]
  crossing <- ifelse(
    scenarios$crossing[index] == "nested", "nested", "crossed"
  )
  repeat_representation <- ifelse(
    as.integer(scenarios$repeat_count[index]) > 1L,
    "separate_error", "combined_error"
  )
  requests <- attempts[c(
    "AttemptOrdinal", "AttemptId", "ConfirmationScenarioOrdinal",
    "ConfirmationScenarioId", "ParentScenarioId", "ScenarioRole",
    "Replicate", "DataSeed", "IntervalEligible", "BootstrapSeed",
    "InnerBootstrapAttemptCount"
  )]
  requests$ExpectedPrimaryFitCallCount <- as.integer(stratum_count)
  requests$ExpectedInnerRefitCallCount <- as.integer(
    requests$InnerBootstrapAttemptCount * stratum_count
  )
  requests$ModelSpecificationId <- paste(
    "separate_univariate", crossing, repeat_representation, sep = "::"
  )
  requests$ExpectedIntervalTargetCount <- as.integer(
    ifelse(requests$IntervalEligible, stratum_count * 2L, 0L)
  )
  requests$RouteId <- contract$RouteId
  requests$Backend <- contract$Backend
  requests$Criterion <- contract$Criterion
  requests$DataSeedAccessAuthorized <- FALSE
  requests$BootstrapSeedAccessAuthorized <- FALSE
  requests$ExecutionAuthorized <- FALSE
  hash_fields <- names(requests)
  requests$RequestHash <- vapply(seq_len(nrow(requests)), function(index) {
    mfrmr_gtds4w_hash(as.list(requests[index, hash_fields, drop = FALSE]))
  }, character(1L))
  requests
}

mfrmr_gtds4w_inner_blocks <- function(
    outer_requests, contract = mfrmr_gtds4w_contract()) {
  eligible <- outer_requests[outer_requests$IntervalEligible, , drop = FALSE]
  count <- eligible$InnerBootstrapAttemptCount
  last <- cumsum(count)
  first <- last - count + 1L
  blocks <- data.frame(
    BlockOrdinal = seq_len(nrow(eligible)),
    AttemptId = eligible$AttemptId,
    OuterRequestHash = eligible$RequestHash,
    BootstrapSeed = eligible$BootstrapSeed,
    InnerAttemptCount = count,
    FirstInnerOrdinal = first,
    LastInnerOrdinal = last,
    FirstInnerId = paste0(eligible$AttemptId, "/PB001"),
    LastInnerId = paste0(
      eligible$AttemptId, "/PB",
      sprintf("%03d", contract$BootstrapReplicateCount)
    ),
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  blocks$InnerBlockHash <- vapply(seq_len(nrow(blocks)), function(index) {
    block <- blocks[index, , drop = FALSE]
    mfrmr_gtds4w_hash(list(
      AttemptId = block$AttemptId[[1L]],
      OuterRequestHash = block$OuterRequestHash[[1L]],
      BootstrapSeed = block$BootstrapSeed[[1L]],
      BootstrapReplicate = seq_len(contract$BootstrapReplicateCount),
      InnerOrdinal = seq.int(
        block$FirstInnerOrdinal[[1L]], block$LastInnerOrdinal[[1L]]
      ),
      InnerIdFormat = "<AttemptId>/PB%03d"
    ))
  }, character(1L))
  blocks
}

mfrmr_gtds4w_with_seed <- function(seed, contract, code) {
  seed <- as.integer(seed)
  if (length(seed) != 1L || is.na(seed) || seed <= 0L) {
    stop("One positive bootstrap seed is required.", call. = FALSE)
  }
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv,
                      inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  do.call(RNGkind, as.list(contract$RngKind))
  set.seed(seed)
  force(code)
}

mfrmr_gtds4w_fixture_operators <- function(strata) {
  diagonal <- c(
    Object = 1, Rater = 1 / 4, `Object:Rater` = 1 / 4,
    Residual = 1 / 8
  )
  stats::setNames(lapply(names(diagonal), function(component) {
    matrix <- diag(diagonal[[component]], length(strata), length(strata))
    dimnames(matrix) <- list(strata, strata)
    list(
      OperatorMatrix = matrix,
      OperatorHash = mfrmr_gtds4w_hash(list(
        ScenarioId = "D3-S001", ComponentId = component,
        OperatorMatrix = matrix
      ))
    )
  }), names(diagonal))
}

mfrmr_gtds4w_shadow_fixture <- function(coverage = mfrmr_gtds3_manifest()) {
  generation <- mfrmr_gtds3g_generate_profile(
    "D3-S001", coverage = coverage, validate = FALSE
  )
  mfrmr_gtds3g_assert_generation(
    generation, coverage = coverage, validate = FALSE, replay = FALSE
  )
  data <- generation$GeneratedData[generation$GeneratedData$ResponseGenerated,
                                   , drop = FALSE]
  data$ObjectConditionId <- interaction(
    data$ObjectId, data$ConditionId, drop = TRUE
  )
  strata <- sort(unique(as.character(data$Stratum)), method = "radix")
  partitions <- stats::setNames(lapply(strata, function(stratum) {
    mfrmr_gtds3w_prepare_data(
      data[as.character(data$Stratum) == stratum, , drop = FALSE]
    )
  }), strata)
  list(
    ScenarioId = generation$ScenarioId,
    ShadowSeed = generation$ShadowSeed,
    GenerationHash = generation$GenerationHash,
    Profile = unlist(generation$Profile, use.names = TRUE),
    Partitions = partitions,
    Operators = mfrmr_gtds4w_fixture_operators(strata),
    CountsAsDsim5Attempt = FALSE
  )
}

mfrmr_gtds4w_model_specification <- function(profile) {
  crossing <- if (identical(as.character(profile[["crossing"]]), "nested")) {
    "nested"
  } else "crossed"
  repeat_representation <- if (as.integer(profile[["repeat_count"]]) > 1L) {
    "separate_error"
  } else "combined_error"
  paste("separate_univariate", crossing, repeat_representation, sep = "::")
}

mfrmr_gtds4w_capture_refit <- function(fit, response) {
  warnings <- messages <- character()
  value <- tryCatch(withCallingHandlers(
    lme4::refit(fit, response),
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    },
    message = function(condition) {
      messages <<- c(messages, conditionMessage(condition))
      invokeRestart("muffleMessage")
    }
  ), error = function(condition) condition)
  list(Fit = value, Warnings = warnings, Messages = messages)
}

mfrmr_gtds4w_coefficient <- function(
    fit, scenario_id, attempt_id, stratum, profile, operators) {
  groups <- names(lme4::VarCorr(fit))
  object <- stats::setNames(
    mfrmr_gtds3w_scalar_variance(fit, "ObjectId"), stratum
  )
  condition <- if ("ConditionId" %in% groups) stats::setNames(
    mfrmr_gtds3w_scalar_variance(fit, "ConditionId"), stratum
  ) else NULL
  interaction <- if ("ObjectConditionId" %in% groups) stats::setNames(
    mfrmr_gtds3w_scalar_variance(fit, "ObjectConditionId"), stratum
  ) else NULL
  residual <- stats::setNames(as.numeric(stats::sigma(fit))^2, stratum)
  crossing <- if (identical(as.character(profile[["crossing"]]), "nested")) {
    "nested"
  } else "crossed"
  blocks <- mfrmr_gtds3w_block_rows(
    scenario_id, "separate_univariate", attempt_id, crossing,
    as.integer(profile[["repeat_count"]]), stratum, object, condition,
    interaction, residual, operators
  )
  coefficient <- mfrmr_gtds3w_coefficients(blocks)
  reference <- mfrmr_gtds4_reference_coefficient(
    coefficient$UniverseVariance[[1L]],
    coefficient$RelativeErrorVariance[[1L]],
    coefficient$AbsoluteOnlyVariance[[1L]]
  )
  coefficient$ReferencePhi <- reference[["ABS-PHI"]]
  coefficient$ReferenceG <- reference[["REL-G"]]
  coefficient$ReferenceMaximumError <- max(
    abs(c(coefficient$Phi - coefficient$ReferencePhi,
          coefficient$G - coefficient$ReferenceG))
  )
  coefficient
}

mfrmr_gtds4w_interval_bounds <- function(
    receipts, metrics, contract = mfrmr_gtds4w_contract()) {
  expected <- contract$BootstrapReplicateCount
  complete <- nrow(receipts) == expected &&
    identical(receipts$BootstrapReplicate, seq_len(expected)) &&
    all(receipts$TerminalState == "success") &&
    all(receipts$AllTargetsFinite)
  keys <- unique(metrics[c("Stratum", "EstimandId")])
  rows <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    values <- metrics$Value[
      metrics$Stratum == key$Stratum &
        metrics$EstimandId == key$EstimandId
    ]
    available <- complete && length(values) == expected &&
      all(is.finite(values))
    endpoint <- if (available) stats::quantile(
      values, probs = c((1 - contract$ConfidenceLevel) / 2,
                        1 - (1 - contract$ConfidenceLevel) / 2),
      type = contract$QuantileType, names = FALSE
    ) else c(NA_real_, NA_real_)
    data.frame(
      key, PlannedBootstrapReplicateCount = expected,
      AvailableBootstrapReplicateCount = sum(is.finite(values)),
      IntervalAvailable = available,
      Lower = endpoint[[1L]], Upper = endpoint[[2L]],
      QuantileType = contract$QuantileType,
      FailedBootstrapRule = if (available) "not_triggered" else
        "interval_unavailable_outer_attempt_retained",
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds4w_shadow_qualification <- function(
    coverage = mfrmr_gtds3_manifest(),
    contract = mfrmr_gtds4w_contract()) {
  mfrmr_gtds4w_validate_contract(contract)
  fixture <- mfrmr_gtds4w_shadow_fixture(coverage)
  if (!identical(fixture$ScenarioId, contract$QualificationScenarioId)) {
    stop("The qualification fixture changed.", call. = FALSE)
  }
  model_id <- mfrmr_gtds4w_model_specification(fixture$Profile)
  formula <- mfrmr_gtds3w_formula(model_id, mfrmr_gtds3w_contract())
  strata <- names(fixture$Partitions)
  fits <- vector("list", length(strata)); names(fits) <- strata
  primary <- vector("list", length(strata))
  primary_receipts <- vector("list", length(strata))
  for (index in seq_along(strata)) {
    stratum <- strata[[index]]
    captured <- mfrmr_gtds3w_capture_lmer(
      formula, fixture$Partitions[[stratum]]
    )
    if (inherits(captured$Fit, "error")) {
      stop("The qualification primary fit failed: ",
           conditionMessage(captured$Fit), call. = FALSE)
    }
    fits[[stratum]] <- captured$Fit
    primary[[index]] <- mfrmr_gtds4w_coefficient(
      captured$Fit, fixture$ScenarioId, "D4W-Q-S001", stratum,
      fixture$Profile, fixture$Operators
    )
    primary_receipts[[index]] <- data.frame(
      Stratum = stratum,
      ObservationCount = as.integer(stats::nobs(captured$Fit)),
      FitReturned = TRUE,
      WarningCount = length(captured$Warnings),
      MessageCount = length(captured$Messages),
      Singular = lme4::isSingular(captured$Fit),
      stringsAsFactors = FALSE
    )
  }
  primary <- do.call(rbind, primary)
  primary_receipts <- do.call(rbind, primary_receipts)
  fit_rows <- vector("list", contract$BootstrapReplicateCount * length(strata))
  metric_rows <- vector(
    "list", contract$BootstrapReplicateCount * length(strata) * 2L
  )
  receipt_rows <- vector("list", contract$BootstrapReplicateCount)
  fit_cursor <- metric_cursor <- 0L
  before_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) before_seed <- get(".Random.seed", envir = .GlobalEnv)
  mfrmr_gtds4w_with_seed(
    contract$QualificationBootstrapSeed, contract, {
      for (bootstrap in seq_len(contract$BootstrapReplicateCount)) {
        success <- finite <- logical(length(strata))
        for (index in seq_along(strata)) {
          stratum <- strata[[index]]
          data <- fixture$Partitions[[stratum]]
          design_hash <- mfrmr_gtds4w_hash(
            data[setdiff(names(data), "Score")]
          )
          simulated <- tryCatch(
            as.numeric(stats::simulate(
              fits[[stratum]], nsim = 1L, re.form = NA
            )[[1L]]),
            error = function(condition) condition
          )
          if (inherits(simulated, "error")) {
            captured <- list(Fit = simulated, Warnings = character(),
                             Messages = character())
          } else {
            captured <- mfrmr_gtds4w_capture_refit(
              fits[[stratum]], simulated
            )
          }
          success[[index]] <- !inherits(captured$Fit, "error") &&
            !inherits(simulated, "error") && length(simulated) == nrow(data) &&
            all(is.finite(simulated))
          fit_cursor <- fit_cursor + 1L
          fit_rows[[fit_cursor]] <- data.frame(
            BootstrapReplicate = bootstrap, Stratum = stratum,
            ResponseLength = if (inherits(simulated, "error")) NA_integer_
              else length(simulated),
            ExpectedResponseLength = nrow(data),
            UnconditionalNewRandomEffectsAndResiduals = TRUE,
            DesignHash = design_hash,
            DesignIdentityPreserved = success[[index]] && identical(
              design_hash,
              mfrmr_gtds4w_hash(data[setdiff(names(data), "Score")])
            ),
            FitReturned = success[[index]],
            WarningCount = length(captured$Warnings),
            MessageCount = length(captured$Messages),
            ErrorText = if (inherits(captured$Fit, "error"))
              conditionMessage(captured$Fit) else "",
            stringsAsFactors = FALSE
          )
          coefficient <- if (success[[index]]) tryCatch(
            mfrmr_gtds4w_coefficient(
              captured$Fit, fixture$ScenarioId, "D4W-Q-S001", stratum,
              fixture$Profile, fixture$Operators
            ), error = function(condition) condition
          ) else captured$Fit
          coefficient_ready <- !inherits(coefficient, "error") &&
            isTRUE(coefficient$CoefficientReady[[1L]]) &&
            coefficient$ReferenceMaximumError[[1L]] <= 1e-10
          finite[[index]] <- coefficient_ready
          values <- if (coefficient_ready) c(
            `ABS-PHI` = coefficient$Phi[[1L]],
            `REL-G` = coefficient$G[[1L]]
          ) else c(`ABS-PHI` = NA_real_, `REL-G` = NA_real_)
          for (estimand in names(values)) {
            metric_cursor <- metric_cursor + 1L
            metric_rows[[metric_cursor]] <- data.frame(
              BootstrapReplicate = bootstrap, Stratum = stratum,
              EstimandId = estimand, Value = values[[estimand]],
              TargetFinite = is.finite(values[[estimand]]),
              ScalarPoolingApplied = FALSE,
              CountsAsDsim5Attempt = FALSE,
              stringsAsFactors = FALSE
            )
          }
        }
        receipt_rows[[bootstrap]] <- data.frame(
          BootstrapReplicate = bootstrap,
          InnerAttemptId = sprintf("D4W-Q-S001/PB%03d", bootstrap),
          PlannedStratumFitCount = length(strata),
          SuccessfulStratumFitCount = sum(success),
          AllTargetsFinite = all(finite),
          TerminalState = if (all(success) && all(finite)) "success" else
            "refit_or_target_failure",
          CountsAsDsim5Attempt = FALSE,
          ReplacementAllowed = FALSE,
          stringsAsFactors = FALSE
        )
      }
    }
  )
  fit_receipts <- do.call(rbind, fit_rows)
  metrics <- do.call(rbind, metric_rows)
  receipts <- do.call(rbind, receipt_rows)
  intervals <- mfrmr_gtds4w_interval_bounds(receipts, metrics, contract)
  caller_rng_restored <- identical(RNGkind(), before_kind) &&
    identical(
      exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE),
      had_seed
    ) && (!had_seed || identical(
      get(".Random.seed", envir = .GlobalEnv), before_seed
    ))
  list(
    ScenarioId = fixture$ScenarioId,
    ShadowSeed = fixture$ShadowSeed,
    BootstrapSeed = contract$QualificationBootstrapSeed,
    GenerationHash = fixture$GenerationHash,
    ModelSpecificationId = model_id,
    PrimaryFitReceipts = primary_receipts,
    PrimaryCoefficients = primary,
    BootstrapFitReceipts = fit_receipts,
    BootstrapMetricRegistry = metrics,
    InnerReceiptRegistry = receipts,
    IntervalRegistry = intervals,
    CallerRngStateRestored = caller_rng_restored,
    CountsAsDsim5Attempt = FALSE
  )
}

mfrmr_gtds4w_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds4w_require_primitives", "mfrmr_gtds4w_hash",
    "mfrmr_gtds4w_canonical_code", "mfrmr_gtds4w_function_hash",
    "mfrmr_gtds4w_contract",
    "mfrmr_gtds4w_validate_contract", "mfrmr_gtds4w_outer_requests",
    "mfrmr_gtds4w_inner_blocks", "mfrmr_gtds4w_with_seed",
    "mfrmr_gtds4w_fixture_operators", "mfrmr_gtds4w_shadow_fixture",
    "mfrmr_gtds4w_model_specification", "mfrmr_gtds4w_capture_refit",
    "mfrmr_gtds4w_coefficient", "mfrmr_gtds4w_interval_bounds",
    "mfrmr_gtds4w_shadow_qualification",
    "mfrmr_gtds4w_implementation_identity", "mfrmr_gtds4w_manifest",
    "mfrmr_gtds4w_assert_manifest"
  )
  target <- environment(mfrmr_gtds4w_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions),
    FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      mfrmr_gtds4w_function_hash(
        get(name, envir = target, inherits = FALSE)
      )
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4w_manifest <- function(
    freeze_manifest, coverage = mfrmr_gtds3_manifest(),
    contract = mfrmr_gtds4w_contract()) {
  requests <- mfrmr_gtds4w_outer_requests(freeze_manifest, contract)
  blocks <- mfrmr_gtds4w_inner_blocks(requests, contract)
  shadow <- mfrmr_gtds4w_shadow_qualification(coverage, contract)
  failed_receipts <- shadow$InnerReceiptRegistry
  failed_receipts$TerminalState[[1L]] <- "injected_refit_failure"
  failure_intervals <- mfrmr_gtds4w_interval_bounds(
    failed_receipts, shadow$BootstrapMetricRegistry, contract
  )
  gates <- c(
    identical(freeze_manifest$ManifestHash,
              contract$ParentFreezeManifestHash),
    nrow(requests) == contract$ExpectedOuterRequestCount &&
      !anyDuplicated(requests$RequestHash) &&
      all(requests$ModelSpecificationId %in%
            mfrmr_gtds3w_contract()$FormulaRegistry$ModelSpecificationId),
    nrow(blocks) == contract$ExpectedIntervalOuterCount &&
      sum(blocks$InnerAttemptCount) == contract$ExpectedInnerAttemptCount &&
      blocks$FirstInnerOrdinal[[1L]] == 1L &&
      tail(blocks$LastInnerOrdinal, 1L) == contract$ExpectedInnerAttemptCount &&
      all(blocks$FirstInnerOrdinal[-1L] ==
            head(blocks$LastInnerOrdinal, -1L) + 1L),
    all(!requests$DataSeedAccessAuthorized) &&
      all(!requests$BootstrapSeedAccessAuthorized) &&
      all(!requests$ExecutionAuthorized) &&
      all(!blocks$ExecutionAuthorized),
    nrow(shadow$InnerReceiptRegistry) == 199L &&
      nrow(shadow$BootstrapFitReceipts) == 398L &&
      nrow(shadow$BootstrapMetricRegistry) == 796L,
    all(shadow$BootstrapFitReceipts$FitReturned) &&
      all(shadow$BootstrapFitReceipts$DesignIdentityPreserved) &&
      isTRUE(shadow$CallerRngStateRestored),
    all(shadow$InnerReceiptRegistry$TerminalState == "success") &&
      all(shadow$InnerReceiptRegistry$AllTargetsFinite),
    all(shadow$PrimaryCoefficients$ReferenceMaximumError <= 1e-10) &&
      all(shadow$IntervalRegistry$IntervalAvailable) &&
      all(shadow$IntervalRegistry$QuantileType == 7L),
    all(!failure_intervals$IntervalAvailable) &&
      all(failure_intervals$FailedBootstrapRule ==
            "interval_unavailable_outer_attempt_retained"),
    !isTRUE(shadow$CountsAsDsim5Attempt) &&
      !isTRUE(contract$Dsim5ExecutionAuthorized)
  )
  gate_registry <- data.frame(
    GateOrdinal = seq_len(10L),
    GateId = c(
      "parent_freeze_identity", "outer_request_identity",
      "inner_attempt_identity", "planned_seed_closed",
      "full_refit_cardinality", "same_design_refit",
      "all_shadow_attempts_terminal", "interval_and_reference",
      "failure_denominator", "execution_boundary"
    ),
    Passed = gates,
    stringsAsFactors = FALSE
  )
  summary <- list(
    OuterRequestCount = nrow(requests),
    IntervalOuterBlockCount = nrow(blocks),
    InnerAttemptCount = sum(blocks$InnerAttemptCount),
    ExpectedPrimaryFitCallCount = sum(requests$ExpectedPrimaryFitCallCount),
    ExpectedInnerRefitCallCount = sum(requests$ExpectedInnerRefitCallCount),
    ExpectedTotalBackendFitCallCount = sum(
      requests$ExpectedPrimaryFitCallCount +
        requests$ExpectedInnerRefitCallCount
    ),
    ShadowBootstrapAttemptCount = nrow(shadow$InnerReceiptRegistry),
    ShadowRefitCallCount = nrow(shadow$BootstrapFitReceipts),
    ShadowMetricCount = nrow(shadow$BootstrapMetricRegistry),
    GateCount = nrow(gate_registry),
    PassedGateCount = sum(gate_registry$Passed),
    WorkerQualified = all(gate_registry$Passed),
    StaticReconciliationReady = all(gate_registry$Passed),
    Planned857SeedOpened = FALSE,
    Planned858SeedOpened = FALSE,
    Dsim5ExecutionAuthorized = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    CurrentDisposition =
      "dsim4_worker_qualified_static_reconciliation_passed_dsim5_closed",
    NextAction = paste(
      "prepare a shardable D-SIM-5 launch input from the exact reconciled",
      "requests without changing the frozen interval or attempt identities"
    )
  )
  payload <- list(
    Contract = contract,
    ParentFreezeManifestHash = freeze_manifest$ManifestHash,
    OuterRequestRegistry = requests,
    InnerBlockRegistry = blocks,
    InnerIdentityHash = mfrmr_gtds4w_hash(blocks),
    ShadowQualification = shadow,
    FailureProbeIntervalRegistry = failure_intervals,
    GateRegistry = gate_registry,
    ImplementationIdentity = mfrmr_gtds4w_implementation_identity(),
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds4w_hash(payload)
  )), class = c("mfrmr_gtds4w_manifest", "list"))
  mfrmr_gtds4w_assert_manifest(manifest)
  manifest
}

mfrmr_gtds4w_assert_manifest <- function(manifest) {
  fields <- c(
    "Contract", "ParentFreezeManifestHash", "OuterRequestRegistry",
    "InnerBlockRegistry", "InnerIdentityHash", "ShadowQualification",
    "FailureProbeIntervalRegistry", "GateRegistry",
    "ImplementationIdentity", "Summary"
  )
  requests <- manifest$OuterRequestRegistry
  blocks <- manifest$InnerBlockRegistry
  shadow <- manifest$ShadowQualification
  summary <- manifest$Summary
  valid <- inherits(manifest, "mfrmr_gtds4w_manifest") &&
    identical(names(manifest), c(fields, "ManifestHash")) &&
    identical(manifest$ManifestHash,
              mfrmr_gtds4w_hash(manifest[fields])) &&
    identical(manifest$Contract, mfrmr_gtds4w_contract()) &&
    identical(nrow(requests), 15000L) && !anyDuplicated(requests$RequestHash) &&
    all(requests$ModelSpecificationId %in%
          mfrmr_gtds3w_contract()$FormulaRegistry$ModelSpecificationId) &&
    identical(nrow(blocks), 5000L) && !anyDuplicated(blocks$InnerBlockHash) &&
    identical(sum(blocks$InnerAttemptCount), 995000L) &&
    all(blocks$FirstInnerOrdinal[-1L] ==
          head(blocks$LastInnerOrdinal, -1L) + 1L) &&
    identical(manifest$InnerIdentityHash, mfrmr_gtds4w_hash(blocks)) &&
    identical(nrow(shadow$InnerReceiptRegistry), 199L) &&
    identical(nrow(shadow$BootstrapFitReceipts), 398L) &&
    identical(nrow(shadow$BootstrapMetricRegistry), 796L) &&
    all(shadow$InnerReceiptRegistry$TerminalState == "success") &&
    all(shadow$IntervalRegistry$IntervalAvailable) &&
    isTRUE(shadow$CallerRngStateRestored) &&
    all(manifest$GateRegistry$Passed) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds4w_implementation_identity()) &&
    identical(summary$OuterRequestCount, 15000L) &&
    identical(summary$InnerAttemptCount, 995000L) &&
    identical(summary$ExpectedPrimaryFitCallCount, 32500L) &&
    identical(summary$ExpectedInnerRefitCallCount, 1990000L) &&
    identical(summary$ExpectedTotalBackendFitCallCount, 2022500L) &&
    identical(summary$PassedGateCount, 10L) &&
    isTRUE(summary$WorkerQualified) &&
    isTRUE(summary$StaticReconciliationReady) &&
    !isTRUE(summary$Planned857SeedOpened) &&
    !isTRUE(summary$Planned858SeedOpened) &&
    !isTRUE(summary$Dsim5ExecutionAuthorized) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-4 worker qualification manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
