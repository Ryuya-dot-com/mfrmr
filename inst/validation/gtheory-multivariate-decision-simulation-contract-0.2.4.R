# Internal D-SIM-0 multivariate G-theory decision contract.
#
# This file freezes a provisional, machine-checkable decision rule. It does
# not generate data, fit a model, authorize a simulation, or support a public
# coefficient claim. Owner sign-off must create a new immutable version before
# any planned seed is opened.

mfrmr_gtds_require_primitives <- function() {
  if (!exists("mfrmr_gta_hash", mode = "function", inherits = TRUE)) {
    stop("Source Draft.81 before the D-SIM-0 decision contract.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_weight_registry <- function() {
  do.call(rbind, lapply(c(2L, 3L), function(stratum_count) {
    data.frame(
      WeightId = paste0("equal_fixed_s", stratum_count),
      StratumCount = stratum_count,
      Stratum = LETTERS[seq_len(stratum_count)],
      Weight = rep(1 / stratum_count, stratum_count),
      WeightPolicy = "fixed_equal_nonnegative_sum_one",
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_gtds_allocation_registry <- function(stratum_count = 2L) {
  stratum_count <- as.integer(stratum_count)
  if (length(stratum_count) != 1L || is.na(stratum_count) ||
      !stratum_count %in% c(2L, 3L)) {
    stop("`stratum_count` must be exactly 2 or 3.", call. = FALSE)
  }
  raters <- c(2L, 3L, 4L, 2L, 3L, 4L)
  repeats <- c(1L, 1L, 1L, 2L, 2L, 2L)
  data.frame(
    AllocationOrdinal = seq_len(6L),
    AllocationId = sprintf("A%02d_R%d_K%d", seq_len(6L), raters, repeats),
    StratumCount = stratum_count,
    RatersPerObject = raters,
    ReplicatesPerObjectRater = repeats,
    RaterSharingPolicy = "same_prospective_rater_pool_across_strata",
    CostUnit = "rating_event_per_object",
    CostPerObject = stratum_count * raters * repeats,
    FeasibilityStatus = "provisional_owner_signoff_pending",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_contract <- function() {
  mfrmr_gtds_require_primitives()
  payload <- list(
    ContractVersion = "mfrmr-gtheory-multivariate-dsim0-phi-v1",
    ContractId = "MFRMR-GTHEORY-MV-DSIM0-PHI-V1",
    StageId = "D-SIM-0",
    Status = "provisional_owner_signoff_pending",
    DecisionOwner = "mfrmr_development_owner",
    DecisionOwnerStatus = "not_independently_signed",
    TargetPopulation = paste(
      "objects scored on every registered stratum by a prospective",
      "shared rater sample"
    ),
    PrimaryDecision = "absolute_composite_score_decision",
    PrimaryCoefficient = "Phi",
    PrimaryTarget = 0.80,
    PrimaryTargetStatus = "provisional_not_a_universal_adequacy_threshold",
    SecondarySensitivity = "G",
    CompositeWeightPolicy = "fixed_equal_nonnegative_sum_one",
    CandidateStratumCounts = c(2L, 3L),
    MaximumCandidateAllocations = 6L,
    CandidateAllocationGrid = "raters_2_3_4_by_replicates_1_2",
    RaterSharingPolicy = "same_prospective_rater_pool_across_strata",
    CostUnit = "rating_event_per_object",
    CostFormula = "stratum_count * raters_per_object * replicates_per_object_rater",
    TieBreakRule = paste(
      "minimum cost; then more independent raters; then fewer repeats;",
      "then radix allocation id"
    ),
    CurrentComparator = "separate_univariate_stratum_reports",
    PrimaryMetric = "false_safe_allocation_rate",
    OtherDecisionMetrics = c(
      "oracle_minimum_cost_allocation_agreement",
      "false_conservative_allocation_rate",
      "coefficient_shortfall", "safe_cost_regret"
    ),
    AttemptDenominator = paste(
      "all attempted datasets including fit, extraction, projection,",
      "metric failures, and indeterminate outcomes"
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
    OwnerSignoffReady = FALSE,
    SimulationExecutionAllowed = FALSE,
    PlannedSeedAccessAllowed = FALSE,
    PublicSupportReady = FALSE,
    ClaimCeiling = "provisional_deterministic_decision_contract_only"
  )
  payload$WeightRegistry <- mfrmr_gtds_weight_registry()
  payload$AllocationRegistry <- lapply(
    payload$CandidateStratumCounts, mfrmr_gtds_allocation_registry
  )
  names(payload$AllocationRegistry) <- paste0(
    "S", payload$CandidateStratumCounts
  )
  payload$ContractHash <- mfrmr_gta_hash(payload)
  class(payload) <- c("mfrmr_gtds_contract", "list")
  payload
}

mfrmr_gtds_validate_contract <- function(contract = mfrmr_gtds_contract(),
                                          tolerance = 1e-12) {
  if (!inherits(contract, "mfrmr_gtds_contract")) {
    stop("`contract` must be a D-SIM-0 decision contract.", call. = FALSE)
  }
  tolerance <- as.numeric(tolerance)
  if (length(tolerance) != 1L || !is.finite(tolerance) || tolerance < 0) {
    stop("`tolerance` must be one finite non-negative number.", call. = FALSE)
  }
  stored_hash <- contract$ContractHash
  payload <- unclass(contract)
  payload$ContractHash <- NULL
  weights <- contract$WeightRegistry
  weight_sums <- tapply(weights$Weight, weights$StratumCount, sum)
  allocation_ready <- vapply(
    contract$AllocationRegistry,
    function(registry) {
      identical(nrow(registry), contract$MaximumCandidateAllocations) &&
        anyDuplicated(registry$AllocationId) == 0L &&
        all(registry$CostPerObject ==
          registry$StratumCount * registry$RatersPerObject *
            registry$ReplicatesPerObjectRater) &&
        all(registry$FeasibilityStatus ==
          "provisional_owner_signoff_pending")
    },
    logical(1L)
  )
  ready <- identical(contract$StageId, "D-SIM-0") &&
    identical(contract$PrimaryCoefficient, "Phi") &&
    identical(contract$SecondarySensitivity, "G") &&
    identical(contract$PrimaryTarget, 0.80) &&
    identical(contract$MaximumCandidateAllocations, 6L) &&
    identical(names(contract$AllocationRegistry), c("S2", "S3")) &&
    all(abs(weight_sums - 1) <= tolerance) &&
    all(weights$Weight > 0) && all(allocation_ready) &&
    isTRUE(contract$DeterministicDecisionRuleReady) &&
    !isTRUE(contract$OwnerSignoffReady) &&
    !isTRUE(contract$SimulationExecutionAllowed) &&
    !isTRUE(contract$PlannedSeedAccessAllowed) &&
    !isTRUE(contract$PublicSupportReady) &&
    identical(stored_hash, mfrmr_gta_hash(payload))
  if (!ready) {
    stop("The D-SIM-0 contract is incomplete or was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_projection <- function(values, stratum_count = 2L,
                                   coefficient = "Phi") {
  registry <- mfrmr_gtds_allocation_registry(stratum_count)
  values <- as.numeric(values)
  coefficient <- as.character(coefficient)
  if (length(coefficient) != 1L || !identical(coefficient, "Phi")) {
    stop("D-SIM-0 permits only `Phi` as the primary coefficient.",
         call. = FALSE)
  }
  if (length(values) != nrow(registry) || any(!is.finite(values)) ||
      any(values < 0 | values > 1)) {
    stop("Projection values must be six finite coefficients in [0, 1].",
         call. = FALSE)
  }
  output <- registry[c("AllocationId", "StratumCount")]
  output[[coefficient]] <- values
  output
}

mfrmr_gtds_validate_projection <- function(projection, stratum_count = 2L) {
  registry <- mfrmr_gtds_allocation_registry(stratum_count)
  required <- c("AllocationId", "StratumCount", "Phi")
  if (!is.data.frame(projection) || !all(required %in% names(projection))) {
    stop("Projection requires AllocationId, StratumCount, and Phi columns.",
         call. = FALSE)
  }
  projection <- projection[required]
  projection$AllocationId <- as.character(projection$AllocationId)
  projection$StratumCount <- as.integer(projection$StratumCount)
  projection$Phi <- as.numeric(projection$Phi)
  if (nrow(projection) != nrow(registry) || anyNA(projection) ||
      anyDuplicated(projection$AllocationId) ||
      !setequal(projection$AllocationId, registry$AllocationId) ||
      any(projection$StratumCount != as.integer(stratum_count)) ||
      any(!is.finite(projection$Phi)) || any(projection$Phi < 0) ||
      any(projection$Phi > 1)) {
    stop("Projection does not match the exact six-allocation Phi contract.",
         call. = FALSE)
  }
  projection[match(registry$AllocationId, projection$AllocationId), ]
}

mfrmr_gtds_select_allocation <- function(
    projection, stratum_count = 2L,
    contract = mfrmr_gtds_contract()) {
  mfrmr_gtds_validate_contract(contract)
  projection <- mfrmr_gtds_validate_projection(projection, stratum_count)
  registry <- mfrmr_gtds_allocation_registry(stratum_count)
  candidates <- cbind(registry, Phi = projection$Phi)
  eligible <- candidates$Phi >= contract$PrimaryTarget
  if (!any(eligible)) {
    return(data.frame(
      SelectionStatus = "no_allocation_meets_target",
      AllocationId = NA_character_, Phi = NA_real_,
      CostPerObject = NA_integer_, RatersPerObject = NA_integer_,
      ReplicatesPerObjectRater = NA_integer_, stringsAsFactors = FALSE
    ))
  }
  candidates <- candidates[eligible, , drop = FALSE]
  order_index <- order(
    candidates$CostPerObject, -candidates$RatersPerObject,
    candidates$ReplicatesPerObjectRater, candidates$AllocationId,
    method = "radix"
  )
  selected <- candidates[order_index[[1L]], , drop = FALSE]
  data.frame(
    SelectionStatus = "selected",
    AllocationId = selected$AllocationId,
    Phi = selected$Phi,
    CostPerObject = selected$CostPerObject,
    RatersPerObject = selected$RatersPerObject,
    ReplicatesPerObjectRater = selected$ReplicatesPerObjectRater,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_classify_decision <- function(
    truth_projection, estimated_projection, stratum_count = 2L,
    contract = mfrmr_gtds_contract()) {
  mfrmr_gtds_validate_contract(contract)
  truth <- mfrmr_gtds_validate_projection(truth_projection, stratum_count)
  estimate <- mfrmr_gtds_validate_projection(
    estimated_projection, stratum_count
  )
  truth_choice <- mfrmr_gtds_select_allocation(
    truth, stratum_count, contract
  )
  estimate_choice <- mfrmr_gtds_select_allocation(
    estimate, stratum_count, contract
  )
  truth_selected <- identical(truth_choice$SelectionStatus, "selected")
  estimate_selected <- identical(estimate_choice$SelectionStatus, "selected")
  estimated_id <- estimate_choice$AllocationId
  truth_phi_at_estimate <- if (estimate_selected) {
    truth$Phi[match(estimated_id, truth$AllocationId)]
  } else NA_real_
  false_safe <- estimate_selected &&
    truth_phi_at_estimate < contract$PrimaryTarget
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
    "safe_cost_regret"
  }
  output <- list(
    DecisionStatus = status,
    TruthChoice = truth_choice,
    EstimatedChoice = estimate_choice,
    OracleMinimumCostAllocationAgreement = exact,
    FalseSafeAllocation = false_safe,
    FalseConservativeAllocation = false_conservative,
    TruthPhiAtEstimatedChoice = truth_phi_at_estimate,
    CoefficientShortfall = shortfall,
    SafeCostRegret = safe_cost_regret,
    PrimaryTarget = contract$PrimaryTarget,
    PrimaryCoefficient = contract$PrimaryCoefficient,
    ContractHash = contract$ContractHash,
    SimulationEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )
  class(output) <- c("mfrmr_gtds_decision", "list")
  output
}
