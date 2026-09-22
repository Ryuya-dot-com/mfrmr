# Draft.83d2b2b1f typed replay adjudication.
#
# Repository-internal only. This file reads exact b1d/b1e ledgers and performs
# no generation, fitting, optimization, bootstrap, or inference.

mfrmr_gtwz_require_primitives <- function() {
  required <- c("mfrmr_gta_hash", "mfrmr_gtwy_function_hash")
  audit_environment <- environment(mfrmr_gtwz_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.83d2b2b1e chain before Draft.83d2b2b1f: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwz_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwz_validate_feasibility", "mfrmr_gtwz_validate_numerical",
    "mfrmr_gtwz_nonfinite_kind", "mfrmr_gtwz_contract",
    "mfrmr_gtwz_compare_row", "mfrmr_gtwz_adjudicate"
  )
  audit_environment <- environment(mfrmr_gtwz_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwy_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwz_validate_feasibility <- function(execution) {
  inherits(execution, "mfrmr_gtwx_execution") &&
    identical(
      execution$RunnerContractHash,
      "c97b5d08c29e7a7537fe4669f938de9e978b4bb651596007af0b7ea7b9378df7"
    ) &&
    identical(
      execution$ExecutionHash,
      "04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b"
    ) &&
    isTRUE(execution$ExactAccountingPassed) &&
    isTRUE(execution$FeasibilityEvidenceReady) &&
    is.data.frame(execution$AtomicRows) &&
    nrow(execution$AtomicRows) == 3000L &&
    !anyDuplicated(execution$AtomicRows$RouteId) &&
    !isTRUE(execution$ThresholdFrozen) &&
    !isTRUE(execution$InferenceReady) &&
    !isTRUE(execution$DecisionReady)
}

mfrmr_gtwz_validate_numerical <- function(execution) {
  inherits(execution, "mfrmr_gtwy_execution") &&
    identical(
      execution$NumericalSensitivityContractHash,
      "0538eb1a7636d4d784f06c10bb17f65aa958f4e677005462d6309827292083c6"
    ) &&
    identical(
      execution$NumericalSensitivityManifestHash,
      "53880242ed7441c93516defbd840c289df32bbc6d0677e4b441bc2543eda8d2f"
    ) &&
    identical(
      execution$FeasibilityExecutionHash,
      "04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b"
    ) &&
    identical(
      execution$ExecutionHash,
      "37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94"
    ) &&
    isTRUE(execution$ExactAccountingPassed) &&
    !isTRUE(execution$DefaultReplayPassed) &&
    !isTRUE(execution$NumericalSensitivityEvidenceReady) &&
    is.data.frame(execution$AtomicRows) &&
    nrow(execution$AtomicRows) == 9000L &&
    !anyDuplicated(execution$AtomicRows$SensitivityRouteId) &&
    !isTRUE(execution$CalibrationEvidenceReady) &&
    !isTRUE(execution$ThresholdFrozen) &&
    !isTRUE(execution$InferenceReady) &&
    !isTRUE(execution$DecisionReady)
}

mfrmr_gtwz_nonfinite_kind <- function(value) {
  if (!is.numeric(value) || length(value) != 1L) {
    stop("A non-finite kind requires one numeric value.", call. = FALSE)
  }
  if (is.nan(value)) return("NaN")
  if (is.na(value)) return("NA_real")
  if (identical(value, Inf)) return("positive_infinity")
  if (identical(value, -Inf)) return("negative_infinity")
  if (is.finite(value)) return("finite")
  "other_nonfinite"
}

mfrmr_gtwz_contract <- function(feasibility_execution,
                                 numerical_execution) {
  mfrmr_gtwz_require_primitives()
  if (!mfrmr_gtwz_validate_feasibility(feasibility_execution) ||
      !mfrmr_gtwz_validate_numerical(numerical_execution)) {
    stop("The exact b1d and b1e executions are required.", call. = FALSE)
  }
  identity <- list(
    Contract = "gtheory_weak_information_typed_replay_draft83d2b2b1f_v1",
    ContractArtifact =
      "gtheory-weak-information-typed-replay-contract-0.2.3.md",
    FeasibilityRunnerContractHash = feasibility_execution$RunnerContractHash,
    FeasibilityExecutionHash = feasibility_execution$ExecutionHash,
    NumericalSensitivityContractHash =
      numerical_execution$NumericalSensitivityContractHash,
    NumericalSensitivityManifestHash =
      numerical_execution$NumericalSensitivityManifestHash,
    NumericalSensitivityExecutionHash = numerical_execution$ExecutionHash,
    OriginalRouteCount = 3000L,
    FiniteReplayTolerance = 1e-10,
    MaterialNegativeTolerance = 1e-6,
    ReplayStates = c(
      "finite_match", "same_typed_nonfinite_state", "finite_mismatch",
      "nonfinite_state_mismatch", "finite_nonfinite_mismatch"
    ),
    NonFiniteKinds = c(
      "NA_real", "NaN", "positive_infinity", "negative_infinity",
      "other_nonfinite"
    ),
    StateFields = c(
      "PairReturned", "LikelihoodDiagnosticAvailable",
      "NegativeDropWithinTolerance", "ComparisonState"
    ),
    GeneratorCallPermitted = FALSE, PreFitCallPermitted = FALSE,
    BackendFitPermitted = FALSE, OptimizerCallPermitted = FALSE,
    BootstrapPermitted = FALSE, CalibrationDataGenerationPermitted = FALSE,
    ThresholdSelectionPermitted = FALSE,
    Sources = data.frame(
      SourceId = c(
        "glmmTMB_troubleshooting_current", "glmmTMB_reference_current",
        "glmmTMB_diagnose_current"
      ),
      Locator = c(
        "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html",
        "https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html",
        "https://glmmtmb.github.io/glmmTMB/reference/diagnose.html"
      ),
      stringsAsFactors = FALSE
    ),
    FunctionHashes = mfrmr_gtwz_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    TypedReplayExecutionAuthorized = TRUE,
    TypedReplayAdjudicationReady = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwz_contract")
}

mfrmr_gtwz_compare_row <- function(baseline, default, contract) {
  if (!is.data.frame(baseline) || nrow(baseline) != 1L ||
      !is.data.frame(default) || nrow(default) != 1L ||
      !inherits(contract, "mfrmr_gtwz_contract")) {
    stop("Typed replay comparison requires two one-row ledgers.",
         call. = FALSE)
  }
  if (!identical(as.character(baseline$RouteId[[1L]]),
                 as.character(default$RouteId[[1L]]))) {
    stop("Typed replay RouteId values differ.", call. = FALSE)
  }
  baseline_value <- baseline$RawLikelihoodDrop[[1L]]
  default_value <- default$RawLikelihoodDrop[[1L]]
  baseline_finite <- is.finite(baseline_value)
  default_finite <- is.finite(default_value)
  baseline_kind <- mfrmr_gtwz_nonfinite_kind(baseline_value)
  default_kind <- mfrmr_gtwz_nonfinite_kind(default_value)
  absolute_difference <- if (baseline_finite && default_finite) {
    abs(baseline_value - default_value)
  } else NA_real_
  state_fields <- contract$StateFields
  state_equal <- all(vapply(state_fields, function(field) {
    identical(baseline[[field]][[1L]], default[[field]][[1L]])
  }, logical(1L)))
  replay_state <- if (baseline_finite && default_finite) {
    if (absolute_difference <= contract$FiniteReplayTolerance) {
      "finite_match"
    } else "finite_mismatch"
  } else if (!baseline_finite && !default_finite) {
    if (identical(baseline_kind, default_kind) && state_equal) {
      "same_typed_nonfinite_state"
    } else "nonfinite_state_mismatch"
  } else {
    "finite_nonfinite_mismatch"
  }
  baseline_material <- baseline_finite &&
    baseline_value < -contract$MaterialNegativeTolerance
  default_material <- default_finite &&
    default_value < -contract$MaterialNegativeTolerance
  data.frame(
    RouteId = as.character(baseline$RouteId[[1L]]),
    ScenarioId = as.character(baseline$ScenarioId[[1L]]),
    Replicate = as.integer(baseline$Replicate[[1L]]),
    MethodId = as.character(baseline$MethodId[[1L]]),
    Backend = as.character(baseline$Backend[[1L]]),
    Likelihood = as.character(baseline$Likelihood[[1L]]),
    BaselineRawLikelihoodDrop = baseline_value,
    DefaultRawLikelihoodDrop = default_value,
    BaselineFinite = baseline_finite, DefaultFinite = default_finite,
    BaselineNonFiniteKind = baseline_kind,
    DefaultNonFiniteKind = default_kind,
    AbsoluteDifference = absolute_difference,
    DiagnosticStateEqual = state_equal,
    ReplayState = replay_state,
    TypedReplayMatched = replay_state %in%
      c("finite_match", "same_typed_nonfinite_state"),
    BaselineMaterialNegative = baseline_material,
    DefaultMaterialNegative = default_material,
    NonFinitePromotedToAvailable = FALSE,
    CalibrationUse = FALSE, ThresholdSelected = FALSE,
    PValue = NA_real_, Interval = "none", stringsAsFactors = FALSE
  )
}

mfrmr_gtwz_adjudicate <- function(contract, feasibility_execution,
                                    numerical_execution) {
  if (!inherits(contract, "mfrmr_gtwz_contract") ||
      !isTRUE(contract$TypedReplayExecutionAuthorized) ||
      !mfrmr_gtwz_validate_feasibility(feasibility_execution) ||
      !mfrmr_gtwz_validate_numerical(numerical_execution) ||
      !identical(contract$FeasibilityExecutionHash,
                 feasibility_execution$ExecutionHash) ||
      !identical(contract$NumericalSensitivityExecutionHash,
                 numerical_execution$ExecutionHash) ||
      isTRUE(contract$BackendFitPermitted) ||
      isTRUE(contract$CalibrationDataGenerationPermitted) ||
      isTRUE(contract$ThresholdSelectionPermitted)) {
    stop("Typed replay adjudication is not authorized.", call. = FALSE)
  }
  baseline <- feasibility_execution$AtomicRows
  default <- numerical_execution$AtomicRows[
    numerical_execution$AtomicRows$IsDefault %in% TRUE, , drop = FALSE
  ]
  default <- default[match(baseline$RouteId, default$RouteId), , drop = FALSE]
  if (nrow(default) != contract$OriginalRouteCount ||
      anyNA(default$RouteId) || anyDuplicated(default$RouteId) ||
      !identical(as.character(baseline$RouteId),
                 as.character(default$RouteId))) {
    stop("Default-profile route matching is incomplete.", call. = FALSE)
  }
  rows <- lapply(seq_len(nrow(baseline)), function(index) {
    mfrmr_gtwz_compare_row(
      baseline[index, , drop = FALSE], default[index, , drop = FALSE],
      contract
    )
  })
  rows <- do.call(rbind, rows)
  row.names(rows) <- NULL
  exact <- nrow(rows) == contract$OriginalRouteCount &&
    !anyDuplicated(rows$RouteId) &&
    identical(as.character(rows$RouteId), as.character(baseline$RouteId))
  state_counts <- table(factor(
    rows$ReplayState, levels = contract$ReplayStates
  ))
  matched <- exact && all(rows$TypedReplayMatched)
  identity <- list(
    Contract =
      "gtheory_weak_information_typed_replay_execution_draft83d2b2b1f_v1",
    TypedReplayContractHash = contract$ContractHash,
    FeasibilityExecutionHash = feasibility_execution$ExecutionHash,
    NumericalSensitivityExecutionHash = numerical_execution$ExecutionHash,
    AtomicRows = rows, ReplayStateCounts = state_counts,
    ExactAccountingPassed = exact
  )
  structure(c(identity, list(
    ResultHash = mfrmr_gta_hash(identity),
    PlannedRows = contract$OriginalRouteCount,
    FiniteMatchCount = unname(state_counts[["finite_match"]]),
    SameTypedNonFiniteStateCount =
      unname(state_counts[["same_typed_nonfinite_state"]]),
    MismatchCount = sum(state_counts[c(
      "finite_mismatch", "nonfinite_state_mismatch",
      "finite_nonfinite_mismatch"
    )]),
    NonFinitePromotedToAvailableCount = sum(
      rows$NonFinitePromotedToAvailable %in% TRUE
    ),
    TypedReplayAdjudicationReady = matched,
    B1eDefaultReplayPassed = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwz_adjudication")
}
