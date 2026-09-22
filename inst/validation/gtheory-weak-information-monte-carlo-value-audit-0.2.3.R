# Draft.83d2b2b1g15a response-free Monte Carlo value and precision audit.
#
# Repository-internal only. This audit distinguishes independent simulation
# replications from optimizer/reference/decision rows and limits the 100-per-
# cell calibration to numerical-rule selection. It neither authorizes nor
# executes calibration or confirmation.

mfrmr_gtwaj_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwai_contract_hash_valid",
    "mfrmr_gtwae_policy"
  )
  audit_environment <- environment(mfrmr_gtwaj_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g15 authorization-preflight chain before b1g15a: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwaj_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwaj_probability <- function(value, name = "probability") {
  value <- as.numeric(value)
  if (length(value) == 0L || anyNA(value) || any(!is.finite(value)) ||
      any(value < 0 | value > 1)) {
    stop(sprintf("`%s` must contain finite probabilities.", name),
         call. = FALSE)
  }
  value
}

mfrmr_gtwaj_positive_integer <- function(value, name = "n") {
  raw <- value
  value <- suppressWarnings(as.integer(value))
  if (length(value) != 1L || is.na(value) || value < 1L ||
      !isTRUE(all.equal(as.numeric(raw), as.numeric(value)))) {
    stop(sprintf("`%s` must be one positive integer.", name), call. = FALSE)
  }
  value
}

mfrmr_gtwaj_binomial_mcse <- function(probability, n) {
  probability <- mfrmr_gtwaj_probability(probability)
  n <- mfrmr_gtwaj_positive_integer(n)
  sqrt(probability * (1 - probability) / n)
}

mfrmr_gtwaj_zero_event_upper <- function(n, confidence = 0.95) {
  n <- mfrmr_gtwaj_positive_integer(n)
  confidence <- mfrmr_gtwaj_probability(confidence, "confidence")
  if (length(confidence) != 1L || confidence <= 0 || confidence >= 1) {
    stop("`confidence` must be strictly between zero and one.",
         call. = FALSE)
  }
  1 - (1 - confidence)^(1 / n)
}

mfrmr_gtwaj_detection_probability <- function(event_probability, n) {
  event_probability <- mfrmr_gtwaj_probability(
    event_probability, "event_probability"
  )
  n <- mfrmr_gtwaj_positive_integer(n)
  1 - (1 - event_probability)^n
}

mfrmr_gtwaj_minimum_n_zero_upper <- function(target_upper,
                                               confidence = 0.95) {
  target_upper <- mfrmr_gtwaj_probability(target_upper, "target_upper")
  confidence <- mfrmr_gtwaj_probability(confidence, "confidence")
  if (length(target_upper) != 1L || target_upper <= 0 || target_upper >= 1 ||
      length(confidence) != 1L || confidence <= 0 || confidence >= 1) {
    stop("Strictly interior scalar probabilities are required.",
         call. = FALSE)
  }
  as.integer(ceiling(log(1 - confidence) / log(1 - target_upper)))
}

mfrmr_gtwaj_minimum_n_mcse <- function(probability, target_mcse) {
  probability <- mfrmr_gtwaj_probability(probability)
  target_mcse <- as.numeric(target_mcse)
  if (length(target_mcse) != 1L || is.na(target_mcse) ||
      !is.finite(target_mcse) || target_mcse <= 0) {
    stop("`target_mcse` must be one finite positive number.",
         call. = FALSE)
  }
  raw <- probability * (1 - probability) / target_mcse^2
  as.integer(ceiling(raw - sqrt(.Machine$double.eps)))
}

mfrmr_gtwaj_minimum_n_half_width <- function(probability, half_width,
                                              confidence = 0.95) {
  probability <- mfrmr_gtwaj_probability(probability)
  half_width <- as.numeric(half_width)
  confidence <- mfrmr_gtwaj_probability(confidence, "confidence")
  if (length(half_width) != 1L || is.na(half_width) ||
      !is.finite(half_width) || half_width <= 0 ||
      length(confidence) != 1L || confidence <= 0 || confidence >= 1) {
    stop("A positive half-width and interior confidence are required.",
         call. = FALSE)
  }
  z <- stats::qnorm((1 + confidence) / 2)
  raw <- z^2 * probability * (1 - probability) / half_width^2
  as.integer(ceiling(raw - sqrt(.Machine$double.eps)))
}

mfrmr_gtwaj_paired_difference_mcse <- function(p10, p01, n) {
  p10 <- mfrmr_gtwaj_probability(p10, "p10")
  p01 <- mfrmr_gtwaj_probability(p01, "p01")
  n <- mfrmr_gtwaj_positive_integer(n)
  if (length(p10) != 1L || length(p01) != 1L || p10 + p01 > 1) {
    stop("`p10` and `p01` must define one valid discordance distribution.",
         call. = FALSE)
  }
  sqrt((p10 + p01 - (p10 - p01)^2) / n)
}

mfrmr_gtwaj_source_registry <- function() {
  data.frame(
    SourceId = c(
      "morris_white_crowther_2019", "koehler_brown_haneuse_2009",
      "white_2010"
    ),
    Locator = c(
      "https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/",
      "https://pmc.ncbi.nlm.nih.gov/articles/PMC3337209/",
      "https://doi.org/10.1177/1536867X1001000305"
    ),
    ContractRole = c(
      "ADEMP purpose and metric-specific Monte Carlo error planning",
      "replication justified by desired Monte Carlo accuracy",
      "bias coverage power precision and their Monte Carlo errors remain distinct"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwaj_policy <- function() {
  identity <- list(
    Contract = "monte_carlo_value_policy_b1g15a_v1",
    UpstreamAuthorizationPreflightContractHash =
      "44a6d4e2677af111e6eeeae8b7b3143ce8521db34da1769a86b85f32c63ca551",
    UpstreamAcceptancePolicyHash =
      "7962e47df285812d8c785f206d51925b44a13d02037b7b40a619cb80ce833a62",
    Confidence = 0.95,
    DesignCount = 5L,
    VarianceRegionCount = 6L,
    ScenarioCount = 30L,
    MethodCount = 4L,
    ModelRoleCount = 2L,
    CandidateCount = 24L,
    CalibrationReplicatesPerScenario = 100L,
    ConfirmationReplicatesPerScenario = 200L,
    CalibrationIndependentDatasetCount = 3000L,
    ConfirmationIndependentDatasetCount = 6000L,
    CandidateFitsPerCalibrationDataset = 36L,
    CandidateDecisionsPerCalibrationDataset = 192L,
    ReferenceProblemsPerCalibrationDataset = 8L,
    IndependentMonteCarloUnit = "scenario_by_replicate_dataset",
    PrimaryCell = "scenario_method_model_role",
    MethodsArePairedWithinDataset = TRUE,
    ModelRolesAreRepeatedWithinDataset = TRUE,
    OptimizerFitsAreIndependentReplicates = FALSE,
    CandidateDecisionsAreIndependentReplicates = FALSE,
    ReferencesAreIndependentReplicates = FALSE,
    CrossScenarioPoolingForPrimaryPrecisionAllowed = FALSE,
    CandidateSelectionUsesCalibration = TRUE,
    PostSelectionCoverageClaimAllowed = FALSE,
    ConfirmationRemainsIndependentAndSealed = TRUE,
    PurposeAuditEventRate = 0.03,
    PurposeAuditCompleteDenominatorZeroEventUpperBenchmark = 0.03,
    PurposeAuditDetectionProbabilityBenchmark = 0.95,
    PurposeAuditBenchmarkEntersCandidateSelection = FALSE,
    CalibrationPurpose =
      "numerical_stationarity_candidate_selection_and_negative_result",
    CalibrationBroadPerformancePurpose = FALSE,
    EarlyStoppingPermitted = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE,
    Sources = mfrmr_gtwaj_source_registry()
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwaj_policy")
}

mfrmr_gtwaj_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwaj_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity))
}

mfrmr_gtwaj_phase_precision <- function(policy = mfrmr_gtwaj_policy()) {
  if (!mfrmr_gtwaj_policy_hash_valid(policy)) {
    stop("The exact b1g15a precision policy is required.", call. = FALSE)
  }
  n <- c(
    feasibility = 25L,
    calibration = policy$CalibrationReplicatesPerScenario,
    confirmation = policy$ConfirmationReplicatesPerScenario
  )
  data.frame(
    Phase = names(n), ReplicatesPerPrimaryCell = unname(n),
    WorstCaseBernoulliMCSE = 0.5 / sqrt(n),
    MCSEAtRate005 = vapply(
      n, function(value) mfrmr_gtwaj_binomial_mcse(0.05, value), numeric(1L)
    ),
    MCSEAtRate080 = vapply(
      n, function(value) mfrmr_gtwaj_binomial_mcse(0.80, value), numeric(1L)
    ),
    MCSEAtRate095 = vapply(
      n, function(value) mfrmr_gtwaj_binomial_mcse(0.95, value), numeric(1L)
    ),
    ZeroEventUpper95 = vapply(
      n, mfrmr_gtwaj_zero_event_upper, numeric(1L),
      confidence = policy$Confidence
    ),
    stringsAsFactors = FALSE, row.names = NULL
  )
}

mfrmr_gtwaj_detection_table <- function(policy = mfrmr_gtwaj_policy()) {
  if (!mfrmr_gtwaj_policy_hash_valid(policy)) {
    stop("The exact b1g15a precision policy is required.", call. = FALSE)
  }
  event_probability <- c(0.005, 0.01, 0.02, 0.03, 0.05)
  data.frame(
    EventProbability = event_probability,
    CalibrationDetectAtLeastOne = mfrmr_gtwaj_detection_probability(
      event_probability, policy$CalibrationReplicatesPerScenario
    ),
    ConfirmationDetectAtLeastOne = mfrmr_gtwaj_detection_probability(
      event_probability, policy$ConfirmationReplicatesPerScenario
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwaj_future_precision_requirements <- function(
    policy = mfrmr_gtwaj_policy()) {
  if (!mfrmr_gtwaj_policy_hash_valid(policy)) {
    stop("The exact b1g15a precision policy is required.", call. = FALSE)
  }
  binary <- data.frame(
    PerformanceMeasure = c(
      "type_I_error_or_noncoverage", "coverage",
      "power", "worst_case_binary_rate"
    ),
    PlanningProbability = c(0.05, 0.95, 0.80, 0.50),
    stringsAsFactors = FALSE
  )
  binary$NForMCSE001 <- mfrmr_gtwaj_minimum_n_mcse(
    binary$PlanningProbability, 0.01
  )
  binary$NForMCSE0005 <- mfrmr_gtwaj_minimum_n_mcse(
    binary$PlanningProbability, 0.005
  )
  binary$NFor95HalfWidth002 <- mfrmr_gtwaj_minimum_n_half_width(
    binary$PlanningProbability, 0.02, policy$Confidence
  )
  binary$NFor95HalfWidth001 <- mfrmr_gtwaj_minimum_n_half_width(
    binary$PlanningProbability, 0.01, policy$Confidence
  )
  binary
}

mfrmr_gtwaj_zero_upper_requirements <- function(
    policy = mfrmr_gtwaj_policy()) {
  if (!mfrmr_gtwaj_policy_hash_valid(policy)) {
    stop("The exact b1g15a precision policy is required.", call. = FALSE)
  }
  target <- c(0.05, 0.03, 0.02, 0.01, 0.005)
  data.frame(
    TargetZeroEventUpper = target,
    MinimumZeroEventTrials = vapply(
      target, mfrmr_gtwaj_minimum_n_zero_upper, integer(1L),
      confidence = policy$Confidence
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwaj_contract <- function(authorization_preflight_contract,
                                  acceptance_policy = mfrmr_gtwae_policy()) {
  mfrmr_gtwaj_require_primitives()
  policy <- mfrmr_gtwaj_policy()
  if (!mfrmr_gtwai_contract_hash_valid(authorization_preflight_contract) ||
      !identical(
        authorization_preflight_contract$ContractHash,
        policy$UpstreamAuthorizationPreflightContractHash
      ) || !inherits(acceptance_policy, "mfrmr_gtwae_policy") ||
      !identical(acceptance_policy, mfrmr_gtwae_policy()) ||
      !identical(
        acceptance_policy$PolicyHash,
        policy$UpstreamAcceptancePolicyHash
      ) || !identical(
        authorization_preflight_contract$AcceptancePolicyHash,
        acceptance_policy$PolicyHash
      ) || !identical(nrow(acceptance_policy$CandidateGrid),
                      policy$CandidateCount)) {
    stop("Exact non-authorizing b1g15 and b1g11 inputs are required.",
         call. = FALSE)
  }
  phase_precision <- mfrmr_gtwaj_phase_precision(policy)
  detection <- mfrmr_gtwaj_detection_table(policy)
  future <- mfrmr_gtwaj_future_precision_requirements(policy)
  zero_upper <- mfrmr_gtwaj_zero_upper_requirements(policy)
  identity <- list(
    Contract = "monte_carlo_value_contract_b1g15a_v1",
    UpstreamAuthorizationPreflightContractHash =
      authorization_preflight_contract$ContractHash,
    UpstreamReservedManifestHash =
      authorization_preflight_contract$UpstreamReservedManifestHash,
    UpstreamRuntimeHash = authorization_preflight_contract$UpstreamRuntimeHash,
    AcceptancePolicyHash = acceptance_policy$PolicyHash,
    CandidateGridHash = mfrmr_gta_hash(acceptance_policy$CandidateGrid),
    Policy = policy,
    PhasePrecision = phase_precision,
    EventDetection = detection,
    ZeroEventRequirements = zero_upper,
    FuturePrecisionRequirements = future,
    FunctionHashes = mfrmr_gtwaj_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    PrecisionPurposeContractFrozen = TRUE,
    PlannedIndependentCalibrationReplicatesPerPrimaryCell = 100L,
    CompleteDenominatorCalibrationZeroEventUpper95 =
      phase_precision$ZeroEventUpper95[
      phase_precision$Phase == "calibration"
    ],
    CompleteDenominatorConfirmationZeroEventUpper95 =
      phase_precision$ZeroEventUpper95[
      phase_precision$Phase == "confirmation"
    ],
    CompleteDenominatorCalibrationDetectAtLeastOneAt003 =
      detection$CalibrationDetectAtLeastOne[
      detection$EventProbability == 0.03
    ],
    NumericalCalibrationDesignPurposeJustified = TRUE,
    CalibrationPrecisionEvidenceReady = FALSE,
    BroadBiasRMSECoverageClaimSupported = FALSE,
    DStudyOperatingCharacteristicClaimSupported = FALSE,
    UniversalSampleSizeRuleSupported = FALSE,
    BroadClaimsRequireSeparatePrecisionDesignedStudy = TRUE,
    CurrentCalibrationDesignRetained = TRUE,
    ActivationEligibilityChanged = FALSE,
    ExecutionAuthorizationRecordIssued = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwaj_contract")
}

mfrmr_gtwaj_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "UpstreamAuthorizationPreflightContractHash",
    "UpstreamReservedManifestHash", "UpstreamRuntimeHash",
    "AcceptancePolicyHash", "CandidateGridHash", "Policy",
    "PhasePrecision", "EventDetection", "ZeroEventRequirements",
    "FuturePrecisionRequirements", "FunctionHashes"
  )
  calibration <- if (inherits(contract, "mfrmr_gtwaj_contract") &&
      is.data.frame(contract$PhasePrecision)) {
    contract$PhasePrecision[
      contract$PhasePrecision$Phase == "calibration", , drop = FALSE
    ]
  } else data.frame()
  confirmation <- if (inherits(contract, "mfrmr_gtwaj_contract") &&
      is.data.frame(contract$PhasePrecision)) {
    contract$PhasePrecision[
      contract$PhasePrecision$Phase == "confirmation", , drop = FALSE
    ]
  } else data.frame()
  detection <- if (inherits(contract, "mfrmr_gtwaj_contract") &&
      is.data.frame(contract$EventDetection)) {
    contract$EventDetection[
      contract$EventDetection$EventProbability == 0.03, , drop = FALSE
    ]
  } else data.frame()
  inherits(contract, "mfrmr_gtwaj_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwaj_policy_hash_valid(contract$Policy) &&
    nrow(calibration) == 1L && nrow(confirmation) == 1L &&
    nrow(detection) == 1L &&
    identical(contract$PlannedIndependentCalibrationReplicatesPerPrimaryCell,
              100L) &&
    identical(contract$CompleteDenominatorCalibrationZeroEventUpper95,
              calibration$ZeroEventUpper95) &&
    identical(contract$CompleteDenominatorConfirmationZeroEventUpper95,
              confirmation$ZeroEventUpper95) &&
    identical(contract$CompleteDenominatorCalibrationDetectAtLeastOneAt003,
              detection$CalibrationDetectAtLeastOne) &&
    isTRUE(contract$PrecisionPurposeContractFrozen) &&
    isTRUE(contract$NumericalCalibrationDesignPurposeJustified) &&
    !isTRUE(contract$CalibrationPrecisionEvidenceReady) &&
    !isTRUE(contract$BroadBiasRMSECoverageClaimSupported) &&
    !isTRUE(contract$DStudyOperatingCharacteristicClaimSupported) &&
    !isTRUE(contract$UniversalSampleSizeRuleSupported) &&
    isTRUE(contract$BroadClaimsRequireSeparatePrecisionDesignedStudy) &&
    isTRUE(contract$CurrentCalibrationDesignRetained) &&
    !isTRUE(contract$ActivationEligibilityChanged) &&
    !isTRUE(contract$ExecutionAuthorizationRecordIssued) &&
    !isTRUE(contract$CalibrationExecutionAuthorized) &&
    !isTRUE(contract$CalibrationDataGenerated) &&
    !isTRUE(contract$CalibrationResultsViewed) &&
    !isTRUE(contract$ConfirmationAuthorized) &&
    !isTRUE(contract$InferenceReady) && !isTRUE(contract$DecisionReady)
}

mfrmr_gtwaj_audit <- function(contract) {
  if (!mfrmr_gtwaj_contract_hash_valid(contract)) {
    stop("The exact b1g15a Monte Carlo value contract is required.",
         call. = FALSE)
  }
  policy <- contract$Policy
  counts <- c(
    IndependentDatasets = policy$CalibrationIndependentDatasetCount,
    CandidateFits = policy$CalibrationIndependentDatasetCount *
      policy$CandidateFitsPerCalibrationDataset,
    CandidateDecisions = policy$CalibrationIndependentDatasetCount *
      policy$CandidateDecisionsPerCalibrationDataset,
    References = policy$CalibrationIndependentDatasetCount *
      policy$ReferenceProblemsPerCalibrationDataset
  )
  expected <- c(
    IndependentDatasets = 3000L, CandidateFits = 108000L,
    CandidateDecisions = 576000L, References = 24000L
  )
  exact_counts <- identical(counts, expected)
  calibration_row <- contract$PhasePrecision[
    contract$PhasePrecision$Phase == "calibration", , drop = FALSE
  ]
  confirmation_row <- contract$PhasePrecision[
    contract$PhasePrecision$Phase == "confirmation", , drop = FALSE
  ]
  purpose_ready <- exact_counts &&
    identical(calibration_row$ReplicatesPerPrimaryCell, 100L) &&
    calibration_row$ZeroEventUpper95 <
      policy$PurposeAuditCompleteDenominatorZeroEventUpperBenchmark &&
    contract$CompleteDenominatorCalibrationDetectAtLeastOneAt003 >=
      policy$PurposeAuditDetectionProbabilityBenchmark &&
    identical(confirmation_row$ReplicatesPerPrimaryCell, 200L) &&
    confirmation_row$ZeroEventUpper95 <
      calibration_row$ZeroEventUpper95 &&
    !policy$CrossScenarioPoolingForPrimaryPrecisionAllowed &&
    policy$MethodsArePairedWithinDataset &&
    !policy$OptimizerFitsAreIndependentReplicates &&
    !policy$CandidateDecisionsAreIndependentReplicates &&
    !policy$ReferencesAreIndependentReplicates &&
    !policy$PostSelectionCoverageClaimAllowed &&
    !policy$PurposeAuditBenchmarkEntersCandidateSelection &&
    policy$ConfirmationRemainsIndependentAndSealed
  identity <- list(
    Contract = "monte_carlo_value_audit_b1g15a_v1",
    MonteCarloValueContractHash = contract$ContractHash,
    ExactWorkloadCounts = counts,
    IndependentReplicateFractionOfCandidateFits =
      counts[["IndependentDatasets"]] / counts[["CandidateFits"]],
    PlannedCalibrationReplicatesPerPrimaryCell =
      calibration_row$ReplicatesPerPrimaryCell,
    CompleteDenominatorCalibrationWorstCaseBernoulliMCSE =
      calibration_row$WorstCaseBernoulliMCSE,
    CompleteDenominatorCalibrationMCSEAtRate005 =
      calibration_row$MCSEAtRate005,
    CompleteDenominatorCalibrationMCSEAtRate080 =
      calibration_row$MCSEAtRate080,
    CompleteDenominatorCalibrationMCSEAtRate095 =
      calibration_row$MCSEAtRate095,
    CompleteDenominatorCalibrationZeroEventUpper95 =
      calibration_row$ZeroEventUpper95,
    CompleteDenominatorConfirmationZeroEventUpper95 =
      confirmation_row$ZeroEventUpper95,
    CompleteDenominatorCalibrationDetectAtLeastOneAt003 =
      contract$CompleteDenominatorCalibrationDetectAtLeastOneAt003,
    PurposeAuditEventRate = policy$PurposeAuditEventRate,
    PurposeAuditCompleteDenominatorZeroEventUpperBenchmark =
      policy$PurposeAuditCompleteDenominatorZeroEventUpperBenchmark,
    PurposeAuditDetectionProbabilityBenchmark =
      policy$PurposeAuditDetectionProbabilityBenchmark,
    PurposeAuditBenchmarkEntersCandidateSelection =
      policy$PurposeAuditBenchmarkEntersCandidateSelection,
    NumericalCalibrationDesignPurposeJustified = purpose_ready,
    CalibrationPrecisionEvidenceReady = FALSE,
    BroadBiasRMSECoverageClaimSupported = FALSE,
    DStudyOperatingCharacteristicClaimSupported = FALSE,
    UniversalSampleSizeRuleSupported = FALSE,
    BroadClaimsRequireSeparatePrecisionDesignedStudy = TRUE,
    ExecutionValueConclusion =
      "proportionate_for_numerical_calibration_only_not_broad_validation",
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    MonteCarloValueAuditReady = purpose_ready,
    CurrentCalibrationDesignRetained = purpose_ready,
    ActivationEligibilityChanged = FALSE,
    ExecutionAuthorizationRecordIssued = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwaj_audit")
}

mfrmr_gtwaj_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "MonteCarloValueContractHash", "ExactWorkloadCounts",
    "IndependentReplicateFractionOfCandidateFits",
    "PlannedCalibrationReplicatesPerPrimaryCell",
    "CompleteDenominatorCalibrationWorstCaseBernoulliMCSE",
    "CompleteDenominatorCalibrationMCSEAtRate005",
    "CompleteDenominatorCalibrationMCSEAtRate080",
    "CompleteDenominatorCalibrationMCSEAtRate095",
    "CompleteDenominatorCalibrationZeroEventUpper95",
    "CompleteDenominatorConfirmationZeroEventUpper95",
    "CompleteDenominatorCalibrationDetectAtLeastOneAt003",
    "PurposeAuditEventRate",
    "PurposeAuditCompleteDenominatorZeroEventUpperBenchmark",
    "PurposeAuditDetectionProbabilityBenchmark",
    "PurposeAuditBenchmarkEntersCandidateSelection",
    "NumericalCalibrationDesignPurposeJustified",
    "CalibrationPrecisionEvidenceReady",
    "BroadBiasRMSECoverageClaimSupported",
    "DStudyOperatingCharacteristicClaimSupported",
    "UniversalSampleSizeRuleSupported",
    "BroadClaimsRequireSeparatePrecisionDesignedStudy",
    "ExecutionValueConclusion", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  ready <- inherits(audit, "mfrmr_gtwaj_audit") &&
    identical(audit$ExactWorkloadCounts, c(
      IndependentDatasets = 3000L, CandidateFits = 108000L,
      CandidateDecisions = 576000L, References = 24000L
    )) &&
    identical(audit$PlannedCalibrationReplicatesPerPrimaryCell, 100L) &&
    audit$CompleteDenominatorCalibrationZeroEventUpper95 <
      audit$PurposeAuditCompleteDenominatorZeroEventUpperBenchmark &&
    audit$CompleteDenominatorCalibrationDetectAtLeastOneAt003 >=
      audit$PurposeAuditDetectionProbabilityBenchmark &&
    identical(audit$PurposeAuditEventRate, 0.03) &&
    !isTRUE(audit$PurposeAuditBenchmarkEntersCandidateSelection) &&
    audit$CompleteDenominatorConfirmationZeroEventUpper95 <
      audit$CompleteDenominatorCalibrationZeroEventUpper95 &&
    isTRUE(audit$NumericalCalibrationDesignPurposeJustified) &&
    !isTRUE(audit$CalibrationPrecisionEvidenceReady) &&
    !isTRUE(audit$BroadBiasRMSECoverageClaimSupported) &&
    !isTRUE(audit$DStudyOperatingCharacteristicClaimSupported) &&
    !isTRUE(audit$UniversalSampleSizeRuleSupported) &&
    isTRUE(audit$BroadClaimsRequireSeparatePrecisionDesignedStudy) &&
    identical(
      audit$ExecutionValueConclusion,
      "proportionate_for_numerical_calibration_only_not_broad_validation"
    ) && !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
  inherits(audit, "mfrmr_gtwaj_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$MonteCarloValueAuditReady, ready) &&
    identical(audit$CurrentCalibrationDesignRetained, ready) &&
    !isTRUE(audit$ActivationEligibilityChanged) &&
    !isTRUE(audit$ExecutionAuthorizationRecordIssued) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed) &&
    !isTRUE(audit$ConfirmationAuthorized) &&
    !isTRUE(audit$InferenceReady) && !isTRUE(audit$DecisionReady)
}

mfrmr_gtwaj_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwaj_probability", "mfrmr_gtwaj_positive_integer",
    "mfrmr_gtwaj_binomial_mcse", "mfrmr_gtwaj_zero_event_upper",
    "mfrmr_gtwaj_detection_probability",
    "mfrmr_gtwaj_minimum_n_zero_upper", "mfrmr_gtwaj_minimum_n_mcse",
    "mfrmr_gtwaj_minimum_n_half_width",
    "mfrmr_gtwaj_paired_difference_mcse",
    "mfrmr_gtwaj_source_registry", "mfrmr_gtwaj_policy",
    "mfrmr_gtwaj_policy_hash_valid", "mfrmr_gtwaj_phase_precision",
    "mfrmr_gtwaj_detection_table",
    "mfrmr_gtwaj_future_precision_requirements",
    "mfrmr_gtwaj_zero_upper_requirements", "mfrmr_gtwaj_contract",
    "mfrmr_gtwaj_contract_hash_valid", "mfrmr_gtwaj_audit",
    "mfrmr_gtwaj_audit_hash_valid"
  )
  audit_environment <- environment(mfrmr_gtwaj_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwaj_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
