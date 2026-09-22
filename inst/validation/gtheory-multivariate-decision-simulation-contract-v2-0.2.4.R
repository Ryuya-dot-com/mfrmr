# Internal D-SIM-0 v2 multivariate G-theory decision contract.
#
# Source the v1 contract first. V2 preserves v1 as immutable provisional
# history while closing its numerical, estimand, comparator, denominator, and
# sign-off-schema gaps. This file still does not authorize simulation.

mfrmr_gtds_v2_require_primitives <- function() {
  mfrmr_gtds_require_primitives()
  required <- c(
    "mfrmr_gtds_weight_registry", "mfrmr_gtds_allocation_registry"
  )
  function_environment <- environment(mfrmr_gtds_v2_require_primitives)
  available <- vapply(required, function(id) {
    exists(id, envir = function_environment, mode = "function",
           inherits = TRUE)
  }, logical(1L))
  if (!all(available)) {
    stop("Source the D-SIM-0 v1 contract before v2.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_v2_component_operator_registry <- function() {
  data.frame(
    ComponentId = c("Object", "Rater", "Object:Rater", "Residual"),
    UniverseRole = c(
      "object", "absolute_only", "relative_error", "relative_error"
    ),
    FacetUniverse = c(
      "object_of_measurement",
      "prospective_random_raters_shared_across_strata",
      "prospective_random_object_by_rater_interaction_shared_across_strata",
      "prospective_random_observation_residual_independent_across_strata"
    ),
    DiagonalOperatorFormula = c(
      "1", "1 / n_rater", "1 / n_rater",
      "1 / (n_rater * n_repeat)"
    ),
    OffDiagonalOperatorFormula = c(
      "1", "1 / n_rater", "1 / n_rater", "0"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v2_allocation_registry <- function(stratum_count = 2L) {
  registry <- mfrmr_gtds_allocation_registry(stratum_count)
  registry$FeasibilityStatus <- NULL
  registry$OperationalFeasibilityStatus <-
    "provisional_owner_confirmation_pending"
  registry$CostScope <- paste(
    "rating events only; rater recruitment, training, scheduling, and",
    "fixed overhead excluded"
  )
  registry
}

mfrmr_gtds_v2_signoff_requirements <- function() {
  data.frame(
    RequirementOrdinal = seq_len(10L),
    RequirementId = c(
      "named_owner", "absolute_not_cut_score_decision", "target_rationale",
      "score_scale_compatibility", "facet_universe_and_operators",
      "allocation_feasibility", "cost_scope", "univariate_comparator",
      "failure_endpoint", "action_mapping"
    ),
    RequiredConfirmation = c(
      "A named practical owner accepts the decision and its consequence.",
      "Phi addresses absolute-score dependability, not pass/fail accuracy.",
      "Phi=0.80 is accepted as this study's action benchmark, not universal.",
      "All strata have common direction and interpretable common score units.",
      "Fixed strata and prospective shared-rater operators are accepted.",
      "All six candidate allocations are operationally feasible.",
      "Rating-event-only cost and its exclusions are accepted.",
      "The all-strata univariate threshold comparator is current practice.",
      "Unsafe-or-unresolved over every attempt is the primary endpoint.",
      "Build, integrate, park, and kill consequences are accepted."
    ),
    Confirmed = FALSE,
    Evidence = "",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v2_contract <- function() {
  mfrmr_gtds_v2_require_primitives()
  payload <- list(
    ContractVersion = "mfrmr-gtheory-multivariate-dsim0-phi-v2",
    ContractId = "MFRMR-GTHEORY-MV-DSIM0-PHI-V2",
    SupersedesContractId = "MFRMR-GTHEORY-MV-DSIM0-PHI-V1",
    StageId = "D-SIM-0",
    Status = "technical_contract_ready_owner_signoff_pending",
    DecisionOwnerRole = "mfrmr_practical_development_owner",
    DecisionOwnerIdentity = NA_character_,
    TargetPopulation = paste(
      "objects receiving a prospective composite score on every fixed",
      "registered stratum from one shared random rater sample"
    ),
    PrimaryDecision =
      "absolute_composite_score_dependability_not_cut_score_classification",
    PrimaryCoefficient = "Phi",
    PrimaryTarget = 0.80,
    PrimaryTargetStatus =
      "provisional_action_benchmark_not_universal_adequacy_threshold",
    DecisionTolerance = 1e-12,
    DecisionComparisonRule = "value >= target - decision_tolerance",
    RoundingPolicy = "no_display_rounded_value_enters_a_decision",
    SecondarySensitivity = "G",
    StratumUniverseRole = "fixed_profile_dimensions",
    ScoreScalePolicy =
      "common_direction_common_interpretable_original_score_unit",
    ScoreStandardizationPolicy = "none",
    IncompatibleScaleAction = "ineligible_stop_before_dsim1",
    CompositeWeightPolicy = "fixed_equal_nonnegative_sum_one",
    CandidateStratumCounts = c(2L, 3L),
    MaximumCandidateAllocations = 6L,
    CandidateAllocationGrid = "raters_2_3_4_by_replicates_1_2",
    RaterSharingPolicy = "same_prospective_rater_pool_across_strata",
    ResidualSharingPolicy = "independent_across_strata_and_replicates",
    CostUnit = "rating_event_per_object",
    CostFormula =
      "stratum_count * raters_per_object * replicates_per_object_rater",
    CostScope = paste(
      "rating events only; rater recruitment, training, scheduling, and",
      "fixed overhead excluded"
    ),
    TieBreakRule = paste(
      "minimum rating-event cost; then more independent raters; then fewer",
      "repeats; then radix allocation id"
    ),
    CurrentComparator = "separate_univariate_all_strata_threshold",
    ComparatorRule = paste(
      "for the same six allocations, every separately estimated stratum Phi",
      "must meet the same target within tolerance; select by the identical",
      "cost and tie-break rule; never average stratum-specific coefficients"
    ),
    PrimaryMetric = "unsafe_or_unresolved_rate",
    PrimaryEvent = paste(
      "false_safe OR fit_failure OR extraction_failure OR",
      "projection_failure OR metric_failure OR indeterminate"
    ),
    PrimaryDenominator = "all_attempted_datasets_without_success_replacement",
    SecondaryMetrics = c(
      "false_safe_rate_among_decision_complete",
      "oracle_minimum_cost_allocation_agreement",
      "false_conservative_allocation_rate",
      "coefficient_shortfall", "safe_cost_regret",
      "terminal_state_specific_failure_rates"
    ),
    TerminalStates = c(
      "decision_complete", "fit_failure", "extraction_failure",
      "projection_failure", "metric_failure", "indeterminate"
    ),
    ResultActions = c("build", "integrate", "park", "kill"),
    ActionRule = paste(
      "build only after safer action-changing confirmation and an external",
      "integration gap; integrate when an external route gives the same safe",
      "action; park when action is unchanged or precision is insufficient;",
      "kill when the oracle has no multivariate decision contrast or",
      "confirmation violates the frozen safety threshold"
    ),
    DeterministicDecisionRuleReady = TRUE,
    ComparatorRuleReady = TRUE,
    FailureDenominatorRuleReady = TRUE,
    OwnerSignoffReady = FALSE,
    Dsim0Satisfied = FALSE,
    SimulationExecutionAllowed = FALSE,
    PlannedSeedAccessAllowed = FALSE,
    PublicSupportReady = FALSE,
    ClaimCeiling = "technical_dsim0_v2_contract_only"
  )
  payload$WeightRegistry <- mfrmr_gtds_weight_registry()
  payload$AllocationRegistry <- lapply(
    payload$CandidateStratumCounts, mfrmr_gtds_v2_allocation_registry
  )
  names(payload$AllocationRegistry) <- paste0(
    "S", payload$CandidateStratumCounts
  )
  payload$ComponentOperatorRegistry <-
    mfrmr_gtds_v2_component_operator_registry()
  payload$SignoffRequirements <- mfrmr_gtds_v2_signoff_requirements()
  payload$ContractHash <- mfrmr_gta_hash(payload)
  class(payload) <- c("mfrmr_gtds_v2_contract", "list")
  payload
}

mfrmr_gtds_v2_validate_contract <- function(
    contract = mfrmr_gtds_v2_contract()) {
  if (!inherits(contract, "mfrmr_gtds_v2_contract")) {
    stop("`contract` must be a D-SIM-0 v2 decision contract.", call. = FALSE)
  }
  stored_hash <- contract$ContractHash
  payload <- unclass(contract)
  payload$ContractHash <- NULL
  weights <- contract$WeightRegistry
  weight_sums <- tapply(weights$Weight, weights$StratumCount, sum)
  allocations_ready <- vapply(
    contract$AllocationRegistry,
    function(registry) {
      identical(nrow(registry), 6L) &&
        anyDuplicated(registry$AllocationId) == 0L &&
        all(registry$CostPerObject ==
          registry$StratumCount * registry$RatersPerObject *
            registry$ReplicatesPerObjectRater) &&
        all(registry$OperationalFeasibilityStatus ==
          "provisional_owner_confirmation_pending")
    },
    logical(1L)
  )
  operators <- contract$ComponentOperatorRegistry
  ready <- identical(contract$ContractId,
                     "MFRMR-GTHEORY-MV-DSIM0-PHI-V2") &&
    identical(contract$PrimaryDecision,
      "absolute_composite_score_dependability_not_cut_score_classification") &&
    identical(contract$PrimaryCoefficient, "Phi") &&
    identical(contract$SecondarySensitivity, "G") &&
    identical(contract$PrimaryTarget, 0.80) &&
    identical(contract$DecisionTolerance, 1e-12) &&
    identical(contract$PrimaryMetric, "unsafe_or_unresolved_rate") &&
    identical(contract$CurrentComparator,
              "separate_univariate_all_strata_threshold") &&
    identical(contract$MaximumCandidateAllocations, 6L) &&
    identical(names(contract$AllocationRegistry), c("S2", "S3")) &&
    all(abs(weight_sums - 1) <= contract$DecisionTolerance) &&
    all(weights$Weight > 0) && all(allocations_ready) &&
    identical(operators$ComponentId,
              c("Object", "Rater", "Object:Rater", "Residual")) &&
    identical(operators$OffDiagonalOperatorFormula,
              c("1", "1 / n_rater", "1 / n_rater", "0")) &&
    identical(nrow(contract$SignoffRequirements), 10L) &&
    !any(contract$SignoffRequirements$Confirmed) &&
    all(!nzchar(contract$SignoffRequirements$Evidence)) &&
    isTRUE(contract$DeterministicDecisionRuleReady) &&
    isTRUE(contract$ComparatorRuleReady) &&
    isTRUE(contract$FailureDenominatorRuleReady) &&
    !isTRUE(contract$OwnerSignoffReady) &&
    !isTRUE(contract$Dsim0Satisfied) &&
    !isTRUE(contract$SimulationExecutionAllowed) &&
    !isTRUE(contract$PlannedSeedAccessAllowed) &&
    !isTRUE(contract$PublicSupportReady) &&
    identical(stored_hash, mfrmr_gta_hash(payload))
  if (!ready) {
    stop("The D-SIM-0 v2 contract is incomplete or was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_v2_meets_target <- function(value, contract) {
  value <- as.numeric(value)
  if (any(!is.finite(value)) || any(value < 0) || any(value > 1)) {
    stop("Coefficient values must be finite and in [0, 1].", call. = FALSE)
  }
  value >= contract$PrimaryTarget - contract$DecisionTolerance
}

mfrmr_gtds_v2_projection <- function(values, stratum_count = 2L) {
  registry <- mfrmr_gtds_v2_allocation_registry(stratum_count)
  values <- as.numeric(values)
  if (length(values) != nrow(registry) || any(!is.finite(values)) ||
      any(values < 0) || any(values > 1)) {
    stop("Projection values must be six finite Phi coefficients in [0, 1].",
         call. = FALSE)
  }
  data.frame(
    AllocationId = registry$AllocationId,
    StratumCount = registry$StratumCount,
    Phi = values,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v2_validate_projection <- function(projection,
                                               stratum_count = 2L) {
  registry <- mfrmr_gtds_v2_allocation_registry(stratum_count)
  required <- c("AllocationId", "StratumCount", "Phi")
  if (!is.data.frame(projection) || !all(required %in% names(projection))) {
    stop("Projection requires AllocationId, StratumCount, and Phi columns.",
         call. = FALSE)
  }
  projection <- projection[required]
  projection$AllocationId <- as.character(projection$AllocationId)
  projection$StratumCount <- as.integer(projection$StratumCount)
  projection$Phi <- as.numeric(projection$Phi)
  if (nrow(projection) != 6L || anyNA(projection) ||
      anyDuplicated(projection$AllocationId) ||
      !setequal(projection$AllocationId, registry$AllocationId) ||
      any(projection$StratumCount != as.integer(stratum_count)) ||
      any(!is.finite(projection$Phi)) || any(projection$Phi < 0) ||
      any(projection$Phi > 1)) {
    stop("Projection does not match the exact v2 six-allocation contract.",
         call. = FALSE)
  }
  projection[match(registry$AllocationId, projection$AllocationId), ]
}

mfrmr_gtds_v2_select_allocation <- function(
    projection, stratum_count = 2L,
    contract = mfrmr_gtds_v2_contract()) {
  mfrmr_gtds_v2_validate_contract(contract)
  projection <- mfrmr_gtds_v2_validate_projection(
    projection, stratum_count
  )
  registry <- mfrmr_gtds_v2_allocation_registry(stratum_count)
  candidates <- cbind(registry, Phi = projection$Phi)
  eligible <- mfrmr_gtds_v2_meets_target(candidates$Phi, contract)
  if (!any(eligible)) {
    return(data.frame(
      SelectionStatus = "no_allocation_meets_target",
      AllocationId = NA_character_, Phi = NA_real_,
      CostPerObject = NA_integer_, RatersPerObject = NA_integer_,
      ReplicatesPerObjectRater = NA_integer_, stringsAsFactors = FALSE
    ))
  }
  candidates <- candidates[eligible, , drop = FALSE]
  selected <- candidates[order(
    candidates$CostPerObject, -candidates$RatersPerObject,
    candidates$ReplicatesPerObjectRater, candidates$AllocationId,
    method = "radix"
  )[[1L]], , drop = FALSE]
  data.frame(
    SelectionStatus = "selected", AllocationId = selected$AllocationId,
    Phi = selected$Phi, CostPerObject = selected$CostPerObject,
    RatersPerObject = selected$RatersPerObject,
    ReplicatesPerObjectRater = selected$ReplicatesPerObjectRater,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v2_univariate_projection <- function(values,
                                                 stratum_count = 2L) {
  registry <- mfrmr_gtds_v2_allocation_registry(stratum_count)
  values <- as.matrix(values)
  storage.mode(values) <- "double"
  strata <- LETTERS[seq_len(as.integer(stratum_count))]
  if (!identical(dim(values), c(6L, as.integer(stratum_count))) ||
      any(!is.finite(values)) || any(values < 0) || any(values > 1)) {
    stop("Univariate projection must be a 6 by stratum-count Phi matrix.",
         call. = FALSE)
  }
  colnames(values) <- paste0("Phi_", strata)
  data.frame(
    AllocationId = registry$AllocationId,
    StratumCount = registry$StratumCount,
    values, check.names = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v2_select_univariate_comparator <- function(
    projection, stratum_count = 2L,
    contract = mfrmr_gtds_v2_contract()) {
  mfrmr_gtds_v2_validate_contract(contract)
  registry <- mfrmr_gtds_v2_allocation_registry(stratum_count)
  phi_names <- paste0("Phi_", LETTERS[seq_len(as.integer(stratum_count))])
  required <- c("AllocationId", "StratumCount", phi_names)
  if (!is.data.frame(projection) || !all(required %in% names(projection)) ||
      nrow(projection) != 6L || anyDuplicated(projection$AllocationId) ||
      !setequal(as.character(projection$AllocationId), registry$AllocationId) ||
      anyNA(projection[required])) {
    stop("Univariate projection does not match the comparator contract.",
         call. = FALSE)
  }
  projection <- projection[match(
    registry$AllocationId, as.character(projection$AllocationId)
  ), required, drop = FALSE]
  phi <- as.matrix(projection[phi_names])
  storage.mode(phi) <- "double"
  if (any(!is.finite(phi)) || any(phi < 0) || any(phi > 1) ||
      any(as.integer(projection$StratumCount) != as.integer(stratum_count))) {
    stop("Univariate comparator Phi values are invalid.", call. = FALSE)
  }
  eligible_matrix <- mfrmr_gtds_v2_meets_target(as.numeric(phi), contract)
  dim(eligible_matrix) <- dim(phi)
  eligible <- apply(eligible_matrix, 1L, all)
  if (!any(eligible)) {
    return(data.frame(
      SelectionStatus = "no_allocation_meets_all_strata_targets",
      AllocationId = NA_character_, MinimumStratumPhi = NA_real_,
      CostPerObject = NA_integer_, stringsAsFactors = FALSE
    ))
  }
  candidates <- cbind(
    registry, MinimumStratumPhi = apply(phi, 1L, min)
  )[eligible, , drop = FALSE]
  selected <- candidates[order(
    candidates$CostPerObject, -candidates$RatersPerObject,
    candidates$ReplicatesPerObjectRater, candidates$AllocationId,
    method = "radix"
  )[[1L]], , drop = FALSE]
  data.frame(
    SelectionStatus = "selected", AllocationId = selected$AllocationId,
    MinimumStratumPhi = selected$MinimumStratumPhi,
    CostPerObject = selected$CostPerObject, stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v2_classify_decision <- function(
    truth_projection, estimated_projection, stratum_count = 2L,
    contract = mfrmr_gtds_v2_contract()) {
  mfrmr_gtds_v2_validate_contract(contract)
  truth <- mfrmr_gtds_v2_validate_projection(
    truth_projection, stratum_count
  )
  estimate <- mfrmr_gtds_v2_validate_projection(
    estimated_projection, stratum_count
  )
  truth_choice <- mfrmr_gtds_v2_select_allocation(
    truth, stratum_count, contract
  )
  estimate_choice <- mfrmr_gtds_v2_select_allocation(
    estimate, stratum_count, contract
  )
  truth_selected <- identical(truth_choice$SelectionStatus, "selected")
  estimate_selected <- identical(estimate_choice$SelectionStatus, "selected")
  truth_phi_at_estimate <- if (estimate_selected) {
    truth$Phi[match(estimate_choice$AllocationId, truth$AllocationId)]
  } else NA_real_
  false_safe <- estimate_selected &&
    !mfrmr_gtds_v2_meets_target(truth_phi_at_estimate, contract)
  false_conservative <- !estimate_selected && truth_selected
  exact <- identical(truth_choice$SelectionStatus,
                     estimate_choice$SelectionStatus) &&
    ((!truth_selected && !estimate_selected) ||
       identical(truth_choice$AllocationId, estimate_choice$AllocationId))
  safe_cost_regret <- if (estimate_selected && truth_selected && !false_safe) {
    estimate_choice$CostPerObject - truth_choice$CostPerObject
  } else if (exact && !truth_selected) 0L else NA_integer_
  shortfall <- if (estimate_selected) {
    max(contract$PrimaryTarget - truth_phi_at_estimate, 0)
  } else NA_real_
  status <- if (exact && truth_selected) {
    "exact_allocation_agreement"
  } else if (exact) {
    "exact_no_feasible_allocation"
  } else if (false_safe) {
    "false_safe"
  } else if (false_conservative) {
    "false_conservative"
  } else {
    "safe_allocation_disagreement"
  }
  output <- list(
    TerminalStatus = "decision_complete", DecisionStatus = status,
    TruthChoice = truth_choice, EstimatedChoice = estimate_choice,
    DecisionComplete = TRUE, UnsafeOrUnresolved = false_safe,
    OracleMinimumCostAllocationAgreement = exact,
    FalseSafeAllocation = false_safe,
    FalseConservativeAllocation = false_conservative,
    TruthPhiAtEstimatedChoice = truth_phi_at_estimate,
    CoefficientShortfall = shortfall, SafeCostRegret = safe_cost_regret,
    ContractHash = contract$ContractHash,
    SimulationEvidenceReady = FALSE, PublicSupportReady = FALSE
  )
  class(output) <- c("mfrmr_gtds_v2_attempt", "list")
  output
}

mfrmr_gtds_v2_classify_attempt <- function(
    truth_projection, estimated_projection = NULL, stratum_count = 2L,
    terminal_status = "decision_complete",
    contract = mfrmr_gtds_v2_contract()) {
  mfrmr_gtds_v2_validate_contract(contract)
  terminal_status <- match.arg(terminal_status, contract$TerminalStates)
  mfrmr_gtds_v2_validate_projection(truth_projection, stratum_count)
  if (identical(terminal_status, "decision_complete")) {
    if (is.null(estimated_projection)) {
      stop("A decision-complete attempt requires an estimated projection.",
           call. = FALSE)
    }
    return(mfrmr_gtds_v2_classify_decision(
      truth_projection, estimated_projection, stratum_count, contract
    ))
  }
  output <- list(
    TerminalStatus = terminal_status, DecisionStatus = terminal_status,
    TruthChoice = NULL, EstimatedChoice = NULL,
    DecisionComplete = FALSE, UnsafeOrUnresolved = TRUE,
    OracleMinimumCostAllocationAgreement = NA,
    FalseSafeAllocation = NA, FalseConservativeAllocation = NA,
    TruthPhiAtEstimatedChoice = NA_real_, CoefficientShortfall = NA_real_,
    SafeCostRegret = NA_integer_, ContractHash = contract$ContractHash,
    SimulationEvidenceReady = FALSE, PublicSupportReady = FALSE
  )
  class(output) <- c("mfrmr_gtds_v2_attempt", "list")
  output
}

mfrmr_gtds_v2_summarize_attempts <- function(attempts) {
  if (!is.list(attempts) || length(attempts) == 0L ||
      !all(vapply(attempts, inherits, logical(1L),
                  what = "mfrmr_gtds_v2_attempt"))) {
    stop("`attempts` must be a non-empty list of v2 attempt results.",
         call. = FALSE)
  }
  contract_hashes <- vapply(attempts, `[[`, character(1L), "ContractHash")
  if (anyNA(contract_hashes) || length(unique(contract_hashes)) != 1L) {
    stop("Every attempt must use one identical contract hash.", call. = FALSE)
  }
  terminal <- vapply(attempts, `[[`, character(1L), "TerminalStatus")
  complete <- vapply(attempts, `[[`, logical(1L), "DecisionComplete")
  unsafe <- vapply(attempts, `[[`, logical(1L), "UnsafeOrUnresolved")
  false_safe <- vapply(attempts, function(x) {
    if (isTRUE(x$FalseSafeAllocation)) 1L else 0L
  }, integer(1L))
  data.frame(
    AllAttemptCount = length(attempts),
    DecisionCompleteCount = sum(complete),
    UnsafeOrUnresolvedCount = sum(unsafe),
    UnsafeOrUnresolvedRate = mean(unsafe),
    FalseSafeCount = sum(false_safe),
    FalseSafeRateAmongDecisionComplete = if (any(complete)) {
      sum(false_safe) / sum(complete)
    } else NA_real_,
    FitFailureCount = sum(terminal == "fit_failure"),
    ExtractionFailureCount = sum(terminal == "extraction_failure"),
    ProjectionFailureCount = sum(terminal == "projection_failure"),
    MetricFailureCount = sum(terminal == "metric_failure"),
    IndeterminateCount = sum(terminal == "indeterminate"),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v2_signoff_candidate <- function(
    contract = mfrmr_gtds_v2_contract()) {
  mfrmr_gtds_v2_validate_contract(contract)
  payload <- list(
    ReceiptVersion = "mfrmr-gtheory-multivariate-dsim0-signoff-v1",
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    SignerId = NA_character_, SignerRole = contract$DecisionOwnerRole,
    SignedAtUtc = NA_character_,
    ExternalDecisionAnchorType = NA_character_,
    ExternalDecisionAnchor = NA_character_,
    Requirements = contract$SignoffRequirements,
    ReceiptStatus = "candidate_unsigned", Dsim0Satisfied = FALSE
  )
  payload$ReceiptHash <- mfrmr_gta_hash(payload)
  class(payload) <- c("mfrmr_gtds_v2_signoff", "list")
  payload
}

mfrmr_gtds_v2_validate_signed_receipt <- function(
    receipt, contract = mfrmr_gtds_v2_contract()) {
  mfrmr_gtds_v2_validate_contract(contract)
  if (!inherits(receipt, "mfrmr_gtds_v2_signoff")) {
    stop("`receipt` must be a D-SIM-0 v2 sign-off receipt.", call. = FALSE)
  }
  stored_hash <- receipt$ReceiptHash
  payload <- unclass(receipt)
  payload$ReceiptHash <- NULL
  timestamp_shape_ready <- length(receipt$SignedAtUtc) == 1L &&
    !is.na(receipt$SignedAtUtc) &&
    grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
          receipt$SignedAtUtc)
  parsed_timestamp <- if (timestamp_shape_ready) suppressWarnings(as.POSIXct(
    receipt$SignedAtUtc, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
  )) else as.POSIXct(NA)
  timestamp_ready <- timestamp_shape_ready && !is.na(parsed_timestamp) &&
    identical(
      format(parsed_timestamp, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      receipt$SignedAtUtc
    )
  allowed_anchor_types <- c(
    "git_commit_plus_remote_url", "osf_registration",
    "timestamped_signed_record"
  )
  ready <- identical(
      receipt$ReceiptVersion,
      "mfrmr-gtheory-multivariate-dsim0-signoff-v1"
    ) &&
    identical(receipt$ContractId, contract$ContractId) &&
    identical(receipt$ContractHash, contract$ContractHash) &&
    length(receipt$SignerId) == 1L && !is.na(receipt$SignerId) &&
    nzchar(receipt$SignerId) &&
    identical(receipt$SignerRole, contract$DecisionOwnerRole) &&
    timestamp_ready &&
    length(receipt$ExternalDecisionAnchorType) == 1L &&
    !is.na(receipt$ExternalDecisionAnchorType) &&
    receipt$ExternalDecisionAnchorType %in% allowed_anchor_types &&
    length(receipt$ExternalDecisionAnchor) == 1L &&
    !is.na(receipt$ExternalDecisionAnchor) &&
    nzchar(receipt$ExternalDecisionAnchor) &&
    identical(receipt$Requirements$RequirementId,
              contract$SignoffRequirements$RequirementId) &&
    identical(receipt$Requirements$RequiredConfirmation,
              contract$SignoffRequirements$RequiredConfirmation) &&
    all(receipt$Requirements$Confirmed) &&
    all(nzchar(receipt$Requirements$Evidence)) &&
    identical(receipt$ReceiptStatus, "owner_signed_externally_anchored") &&
    isTRUE(receipt$Dsim0Satisfied) &&
    identical(stored_hash, mfrmr_gta_hash(payload))
  if (!ready) {
    stop("The D-SIM-0 v2 sign-off receipt is unsigned or invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}
