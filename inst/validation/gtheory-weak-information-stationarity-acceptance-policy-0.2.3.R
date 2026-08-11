# Draft.83d2b2b1g11 truth-blind stationarity acceptance policy.
#
# Repository-internal only. This file freezes how the reserved calibration
# band may compare and reject candidate numerical-stationarity rules. It does
# not implement the production boundary probe or runner, open replicate 201,
# select a score cutpoint, or authorize calibration, confirmation, inference,
# or D-study decisions.

mfrmr_gtwae_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwsz_candidate_registry",
    "mfrmr_gtwsz_state_registry", "mfrmr_gtwaa_candidate_state"
  )
  policy_environment <- environment(mfrmr_gtwae_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = policy_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g5 and b1g7 policy chain before b1g11: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwae_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwae_source_registry <- function() {
  data.frame(
    SourceId = c(
      "morris_white_crowther_2019", "r_stats_binom_test_current",
      "lme4_convergence_current", "lme4_singularity_current"
    ),
    Locator = c(
      "https://doi.org/10.1002/sim.8086",
      paste0(
        "https://stat.ethz.ch/R-manual/R-devel/library/stats/html/",
        "binom.test.html"
      ),
      "https://lme4.github.io/lme4/reference/convergence.html",
      "https://lme4.github.io/lme4/reference/isSingular.html"
    ),
    ContractRole = c(
      "ADEMP estimand method performance measure and failure accounting",
      "Clopper-Pearson exact one-sided binomial bound",
      "gradient and Hessian checks are numerical diagnostics",
      "boundary singularity is distinct from optimizer nonconvergence"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwae_reference_receipts <- function() {
  rows <- data.frame(
    MethodId = c("glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml"),
    Backend = c("glmmTMB", "glmmTMB", "lme4", "lme4"),
    Likelihood = c("ML", "REML", "ML", "REML"),
    ReferenceContractHash = c(
      "1216ae3591fc026a61b4fb6581ebe79e33d34e4e2b6bf04a969a4c93c3e06689",
      "60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a",
      rep(
        "419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0",
        2L
      )
    ),
    ReferenceExecutionHash = c(
      "46ea4be751a3c54904bac28da31f15e5e05f347b9e8f10a1194887f55557807d",
      "28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72",
      rep(
        "b84c1d53f8653bb5329a0a165e2249b36e5d12e10c26099ab15cbdfac4281e8a",
        2L
      )
    ),
    NonreservedReplicates = "901;902",
    ReferenceMechanicsReady = TRUE,
    stringsAsFactors = FALSE
  )
  if (anyDuplicated(rows$MethodId) || nrow(rows) != 4L ||
      !all(rows$ReferenceMechanicsReady)) {
    stop("The four-lane reference receipt changed.", call. = FALSE)
  }
  rows
}

mfrmr_gtwae_candidate_grid <- function() {
  mfrmr_gtwae_require_primitives()
  registry <- mfrmr_gtwsz_candidate_registry()
  rules <- registry$Rules[registry$Rules$PrimarySelectionEligible, ,
                          drop = FALSE]
  priority <- c(
    "newton_decrement_zone", "lme4_minimum_zone",
    "objective_relative_zone"
  )
  rules$RulePriority <- match(rules$RuleFamilyId, priority)
  if (nrow(rules) != 3L || anyNA(rules$RulePriority) ||
      nrow(registry$Zones) != 8L) {
    stop("The frozen primary candidate grid changed.", call. = FALSE)
  }
  rows <- do.call(rbind, lapply(
    seq_len(nrow(rules)), function(rule_index) {
      data.frame(
        RuleFamilyId = rules$RuleFamilyId[[rule_index]],
        ScoreId = rules$ScoreId[[rule_index]],
        RulePriority = rules$RulePriority[[rule_index]],
        registry$Zones,
        stringsAsFactors = FALSE
      )
    }
  ))
  rows$CandidateId <- paste(rows$RuleFamilyId, rows$ZoneId, sep = "/")
  rows <- rows[order(
    rows$RulePriority, rows$EligibleUpper, rows$IneligibleLower,
    rows$CandidateId
  ), c(
    "CandidateId", "RuleFamilyId", "ScoreId", "RulePriority", "ZoneId",
    "EligibleUpper", "IneligibleLower", "GridOrigin"
  )]
  row.names(rows) <- NULL
  if (nrow(rows) != 24L || anyDuplicated(rows$CandidateId)) {
    stop("The acceptance candidate grid is not 24 unique rules.",
         call. = FALSE)
  }
  rows
}

mfrmr_gtwae_binomial_upper <- function(events, trials,
                                          confidence = 0.95) {
  events <- as.integer(events)
  trials <- as.integer(trials)
  confidence <- as.numeric(confidence)
  if (length(events) != 1L || length(trials) != 1L ||
      length(confidence) != 1L || is.na(events) || is.na(trials) ||
      events < 0L || trials < 0L || events > trials ||
      !is.finite(confidence) || confidence <= 0 || confidence >= 1) {
    stop("Invalid exact-binomial upper-bound arguments.", call. = FALSE)
  }
  if (trials == 0L) return(NA_real_)
  if (events == trials) return(1)
  stats::qbeta(confidence, events + 1, trials - events)
}

mfrmr_gtwae_minimum_zero_event_trials <- function(rate_upper,
                                                     confidence = 0.95) {
  rate_upper <- as.numeric(rate_upper)
  confidence <- as.numeric(confidence)
  if (length(rate_upper) != 1L || !is.finite(rate_upper) ||
      rate_upper <= 0 || rate_upper >= 1 || length(confidence) != 1L ||
      !is.finite(confidence) || confidence <= 0 || confidence >= 1) {
    stop("One open-unit rate and confidence are required.", call. = FALSE)
  }
  as.integer(ceiling(log(1 - confidence) / log(1 - rate_upper)))
}

mfrmr_gtwae_policy <- function() {
  grid <- mfrmr_gtwae_candidate_grid()
  receipts <- mfrmr_gtwae_reference_receipts()
  required_classes <- rbind(
    expand.grid(
      MethodId = receipts$MethodId, ModelRole = "full",
      ReferenceClass = c("finite_accept", "finite_reject", "boundary"),
      stringsAsFactors = FALSE
    ),
    expand.grid(
      MethodId = receipts$MethodId, ModelRole = "reduced",
      ReferenceClass = c("finite_accept", "finite_reject"),
      stringsAsFactors = FALSE
    )
  )
  required_classes <- required_classes[order(
    required_classes$MethodId, required_classes$ModelRole,
    required_classes$ReferenceClass
  ), ]
  row.names(required_classes) <- NULL
  identity <- list(
    Contract = "stationarity_acceptance_policy_draft83d2b2b1g11_v1",
    CandidateGrid = grid,
    ReferenceReceipts = receipts,
    ReferenceReceiptHash = mfrmr_gta_hash(receipts),
    ReferenceMethodCoverageRequired = 4L,
    ReferenceMethodCoverageObserved = nrow(receipts),
    CalibrationReplicateRange = 201:300,
    ConfirmationReplicateRange = 501:700,
    PrimaryCell = "scenario_method_model_role",
    MethodPairingUnit = "scenario_replicate_dataset",
    RatePoolingAcrossPrimaryCellsAllowed = FALSE,
    CandidateRuleScope =
      "one_global_rule_family_and_zone_across_four_method_lanes",
    Confidence = 0.95,
    BinomialBound = "one_sided_Clopper_Pearson",
    ZeroEventPopulationRateClaimAllowed = FALSE,
    PostSelectionConfidenceCoverageClaimAllowed = FALSE,
    CandidateApplicationMayUseGeneratingTruth = FALSE,
    CandidateSelectionMayUseConfirmation = FALSE,
    CandidateSelectionMayUseViewedSmoke = FALSE,
    ReferenceUnresolvedInBinaryDenominator = FALSE,
    MissingDenominatorState = "not_informative_not_zero",
    ZeroObservedSafetyErrorRequired = TRUE,
    SafetyEvents = c("false_ready", "false_boundary_handoff"),
    SecondaryErrors = c("false_unready", "missed_boundary"),
    AbstentionStates = c("indeterminate", "not_evaluable"),
    RequiredReferenceClasses = required_classes,
    RequiredReferenceClassCount = nrow(required_classes),
    CalibrationSelectionOrder = c(
      "reject_any_observed_safety_error",
      "require_observation_and_correct_decisive_coverage_of_every_required_class",
      "minimize_worst_cell_false_ready_exact_upper",
      "minimize_worst_cell_false_boundary_handoff_exact_upper",
      "minimize_worst_cell_false_unready_exact_upper",
      "minimize_worst_cell_missed_boundary_exact_upper",
      "minimize_worst_cell_indeterminate_exact_upper",
      "minimize_worst_cell_not_evaluable_exact_upper",
      "prefer_primary_affine_invariant_rule_then_frozen_rule_priority",
      "prefer_more_conservative_zone_then_candidate_id"
    ),
    NoAdmissibleCandidateState =
      "negative_calibration_no_stationarity_threshold",
    CandidateSelectedState =
      "candidate_selected_for_immutable_confirmation_freeze",
    CandidateSelectionAutomaticallyAuthorizesConfirmation = FALSE,
    Sources = mfrmr_gtwae_source_registry()
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), AcceptancePolicyFrozen = TRUE,
    MonteCarloDecisionPolicyFrozen = TRUE,
    ReferenceMethodCoverageComplete = TRUE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    ProductionBoundaryProbeReady = FALSE, RunnerImplementationReady = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwae_policy")
}

mfrmr_gtwae_pair_classification <- function(candidate_state,
                                               reference_state) {
  candidate_state <- as.character(candidate_state)
  reference_state <- as.character(reference_state)
  if (length(candidate_state) != length(reference_state)) {
    stop("Candidate and reference states must have equal length.",
         call. = FALSE)
  }
  allowed_candidate <- c(
    "numerically_eligible", "boundary_handoff", "indeterminate",
    "numerically_ineligible", "not_evaluable"
  )
  allowed_reference <- c(
    "finite_local_minimum", "finite_box_local_minimum",
    "finite_stationary_flat", "finite_nonstationary",
    "finite_saddle_or_max", "boundary_limit", "reference_unresolved",
    "not_evaluable"
  )
  if (any(!candidate_state %in% allowed_candidate) ||
      any(!reference_state %in% allowed_reference)) {
    stop("Only registered candidate and reference states are allowed.",
         call. = FALSE)
  }
  finite_accept <- reference_state %in% c(
    "finite_local_minimum", "finite_box_local_minimum",
    "finite_stationary_flat"
  )
  finite_reject <- reference_state %in% c(
    "finite_nonstationary", "finite_saddle_or_max"
  )
  boundary <- reference_state == "boundary_limit"
  resolved <- finite_accept | finite_reject | boundary
  reference_class <- rep("unresolved", length(reference_state))
  reference_class[finite_accept] <- "finite_accept"
  reference_class[finite_reject] <- "finite_reject"
  reference_class[boundary] <- "boundary"
  data.frame(
    ReferenceClass = reference_class,
    ReferenceResolved = resolved,
    SafetyFalseReady = resolved & !finite_accept &
      candidate_state == "numerically_eligible",
    FalseBoundaryHandoff = resolved & !boundary &
      candidate_state == "boundary_handoff",
    FalseUnready = finite_accept &
      candidate_state == "numerically_ineligible",
    MissedBoundary = boundary & candidate_state != "boundary_handoff",
    CandidateIndeterminate = resolved & candidate_state == "indeterminate",
    CandidateNotEvaluable = resolved & candidate_state == "not_evaluable",
    CorrectFiniteAccept = finite_accept &
      candidate_state == "numerically_eligible",
    CorrectFiniteReject = finite_reject &
      candidate_state == "numerically_ineligible",
    CorrectBoundaryHandoff = boundary &
      candidate_state == "boundary_handoff",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwae_rate_row <- function(events, trials, confidence) {
  data.frame(
    Events = as.integer(events), Trials = as.integer(trials),
    Rate = if (trials > 0L) events / trials else NA_real_,
    ExactUpper = mfrmr_gtwae_binomial_upper(events, trials, confidence),
    WorstCaseMCSE = if (trials > 0L) 0.5 / sqrt(trials) else NA_real_,
    Informative = trials > 0L,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwae_cell_summary <- function(ledger,
                                        policy = mfrmr_gtwae_policy()) {
  required <- c(
    "ObservationId", "ScenarioId", "MethodId", "ModelRole", "CandidateId",
    "CandidateState", "ReferenceState"
  )
  forbidden <- c(
    "TargetVariance", "TruthRegion", "EvaluationRole", "GeneratingTruth",
    "TrueVariance", "TruthLabel"
  )
  if (!is.data.frame(ledger) || !all(required %in% names(ledger)) ||
      any(forbidden %in% names(ledger)) || nrow(ledger) == 0L ||
      anyNA(ledger[required]) ||
      anyDuplicated(ledger[c("ObservationId", "CandidateId")])) {
    stop(
      "A complete truth-blind observation-by-candidate ledger is required.",
      call. = FALSE
    )
  }
  if (!setequal(unique(ledger$CandidateId), policy$CandidateGrid$CandidateId) ||
      !all(ledger$MethodId %in% policy$ReferenceReceipts$MethodId) ||
      !all(ledger$ModelRole %in% c("full", "reduced"))) {
    stop("The frozen candidate, method, or model-role grid changed.",
         call. = FALSE)
  }
  candidate_counts <- table(ledger$ObservationId)
  if (any(candidate_counts != nrow(policy$CandidateGrid))) {
    stop("Every observation requires all 24 candidate rules.",
         call. = FALSE)
  }
  reference_by_observation <- split(
    ledger$ReferenceState, ledger$ObservationId, drop = TRUE
  )
  if (any(vapply(reference_by_observation, function(value) {
    length(unique(value)) != 1L
  }, logical(1L)))) {
    stop("Reference state changed across candidates.", call. = FALSE)
  }
  classified <- mfrmr_gtwae_pair_classification(
    ledger$CandidateState, ledger$ReferenceState
  )
  rows <- cbind(ledger, classified)
  key <- interaction(
    rows$CandidateId, rows$ScenarioId, rows$MethodId, rows$ModelRole,
    drop = TRUE, lex.order = TRUE
  )
  groups <- split(rows, key, drop = TRUE)
  output <- do.call(rbind, lapply(groups, function(value) {
    finite_accept <- value$ReferenceClass == "finite_accept"
    finite_reject <- value$ReferenceClass == "finite_reject"
    boundary <- value$ReferenceClass == "boundary"
    resolved <- value$ReferenceResolved
    false_ready <- mfrmr_gtwae_rate_row(
      sum(value$SafetyFalseReady), sum(finite_reject | boundary),
      policy$Confidence
    )
    false_handoff <- mfrmr_gtwae_rate_row(
      sum(value$FalseBoundaryHandoff), sum(finite_accept | finite_reject),
      policy$Confidence
    )
    false_unready <- mfrmr_gtwae_rate_row(
      sum(value$FalseUnready), sum(finite_accept), policy$Confidence
    )
    missed_boundary <- mfrmr_gtwae_rate_row(
      sum(value$MissedBoundary), sum(boundary), policy$Confidence
    )
    indeterminate <- mfrmr_gtwae_rate_row(
      sum(value$CandidateIndeterminate), sum(resolved), policy$Confidence
    )
    not_evaluable <- mfrmr_gtwae_rate_row(
      sum(value$CandidateNotEvaluable), sum(resolved), policy$Confidence
    )
    data.frame(
      CandidateId = value$CandidateId[[1L]],
      ScenarioId = value$ScenarioId[[1L]],
      MethodId = value$MethodId[[1L]],
      ModelRole = value$ModelRole[[1L]],
      ObservationCount = length(unique(value$ObservationId)),
      ReferenceResolved = sum(resolved),
      ReferenceUnresolved = sum(!resolved),
      FalseReadyEvents = false_ready$Events,
      FalseReadyTrials = false_ready$Trials,
      FalseReadyRate = false_ready$Rate,
      FalseReadyExactUpper = false_ready$ExactUpper,
      FalseBoundaryHandoffEvents = false_handoff$Events,
      FalseBoundaryHandoffTrials = false_handoff$Trials,
      FalseBoundaryHandoffRate = false_handoff$Rate,
      FalseBoundaryHandoffExactUpper = false_handoff$ExactUpper,
      FalseUnreadyEvents = false_unready$Events,
      FalseUnreadyTrials = false_unready$Trials,
      FalseUnreadyRate = false_unready$Rate,
      FalseUnreadyExactUpper = false_unready$ExactUpper,
      MissedBoundaryEvents = missed_boundary$Events,
      MissedBoundaryTrials = missed_boundary$Trials,
      MissedBoundaryRate = missed_boundary$Rate,
      MissedBoundaryExactUpper = missed_boundary$ExactUpper,
      IndeterminateEvents = indeterminate$Events,
      IndeterminateTrials = indeterminate$Trials,
      IndeterminateRate = indeterminate$Rate,
      IndeterminateExactUpper = indeterminate$ExactUpper,
      NotEvaluableEvents = not_evaluable$Events,
      NotEvaluableTrials = not_evaluable$Trials,
      NotEvaluableRate = not_evaluable$Rate,
      NotEvaluableExactUpper = not_evaluable$ExactUpper,
      stringsAsFactors = FALSE
    )
  }))
  row.names(output) <- NULL
  output[order(
    output$CandidateId, output$ScenarioId, output$MethodId,
    output$ModelRole
  ), ]
}

mfrmr_gtwae_max_informative <- function(value) {
  value <- as.numeric(value)
  value <- value[is.finite(value)]
  if (length(value) == 0L) return(1)
  max(value)
}

mfrmr_gtwae_candidate_summary <- function(
    ledger, cell_summary = mfrmr_gtwae_cell_summary(ledger),
    policy = mfrmr_gtwae_policy()) {
  classified <- cbind(
    ledger,
    mfrmr_gtwae_pair_classification(
      ledger$CandidateState, ledger$ReferenceState
    )
  )
  required <- policy$RequiredReferenceClasses
  candidates <- policy$CandidateGrid$CandidateId
  outputs <- lapply(candidates, function(candidate_id) {
    rows <- classified[classified$CandidateId == candidate_id, , drop = FALSE]
    cells <- cell_summary[cell_summary$CandidateId == candidate_id, ,
                          drop = FALSE]
    observed <- unique(rows[
      rows$ReferenceResolved,
      c("MethodId", "ModelRole", "ReferenceClass")
    ])
    observed_key <- do.call(paste, c(observed, sep = "\r"))
    required_key <- do.call(paste, c(required, sep = "\r"))
    observed_required <- sum(required_key %in% observed_key)
    rows$CorrectDecisive <- rows$CorrectFiniteAccept |
      rows$CorrectFiniteReject | rows$CorrectBoundaryHandoff
    correct <- unique(rows[
      rows$CorrectDecisive,
      c("MethodId", "ModelRole", "ReferenceClass")
    ])
    correct_key <- do.call(paste, c(correct, sep = "\r"))
    correct_required <- sum(required_key %in% correct_key)
    grid_row <- policy$CandidateGrid[
      policy$CandidateGrid$CandidateId == candidate_id, , drop = FALSE
    ]
    data.frame(
      CandidateId = candidate_id,
      RuleFamilyId = grid_row$RuleFamilyId,
      ZoneId = grid_row$ZoneId,
      RulePriority = grid_row$RulePriority,
      EligibleUpper = grid_row$EligibleUpper,
      IneligibleLower = grid_row$IneligibleLower,
      SafetyFalseReady = sum(cells$FalseReadyEvents),
      FalseBoundaryHandoff = sum(cells$FalseBoundaryHandoffEvents),
      FalseUnready = sum(cells$FalseUnreadyEvents),
      MissedBoundary = sum(cells$MissedBoundaryEvents),
      Indeterminate = sum(cells$IndeterminateEvents),
      NotEvaluable = sum(cells$NotEvaluableEvents),
      WorstFalseReadyExactUpper =
        mfrmr_gtwae_max_informative(cells$FalseReadyExactUpper),
      WorstFalseBoundaryHandoffExactUpper =
        mfrmr_gtwae_max_informative(
          cells$FalseBoundaryHandoffExactUpper
        ),
      WorstFalseUnreadyExactUpper =
        mfrmr_gtwae_max_informative(cells$FalseUnreadyExactUpper),
      WorstMissedBoundaryExactUpper =
        mfrmr_gtwae_max_informative(cells$MissedBoundaryExactUpper),
      WorstIndeterminateExactUpper =
        mfrmr_gtwae_max_informative(cells$IndeterminateExactUpper),
      WorstNotEvaluableExactUpper =
        mfrmr_gtwae_max_informative(cells$NotEvaluableExactUpper),
      ObservedRequiredClassCount = observed_required,
      CorrectRequiredClassCount = correct_required,
      RequiredClassCount = policy$RequiredReferenceClassCount,
      ReferenceClassCoverageComplete =
        observed_required == policy$RequiredReferenceClassCount,
      CorrectDecisiveCoverageComplete =
        correct_required == policy$RequiredReferenceClassCount,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, outputs)
  row.names(output) <- NULL
  output
}

mfrmr_gtwae_rank_candidate_summaries <- function(
    summaries, policy = mfrmr_gtwae_policy()) {
  required <- c(
    "CandidateId", "RulePriority", "EligibleUpper", "IneligibleLower",
    "SafetyFalseReady", "FalseBoundaryHandoff",
    "WorstFalseReadyExactUpper",
    "WorstFalseBoundaryHandoffExactUpper", "WorstFalseUnreadyExactUpper",
    "WorstMissedBoundaryExactUpper", "WorstIndeterminateExactUpper",
    "WorstNotEvaluableExactUpper", "ReferenceClassCoverageComplete",
    "CorrectDecisiveCoverageComplete"
  )
  if (!is.data.frame(summaries) || !all(required %in% names(summaries)) ||
      nrow(summaries) == 0L || anyDuplicated(summaries$CandidateId) ||
      anyNA(summaries[required])) {
    stop("Complete unique candidate summaries are required.",
         call. = FALSE)
  }
  summaries$SafetyAdmissible <-
    summaries$SafetyFalseReady == 0L &
    summaries$FalseBoundaryHandoff == 0L
  summaries$PolicyAdmissible <-
    summaries$SafetyAdmissible &
    summaries$ReferenceClassCoverageComplete &
    summaries$CorrectDecisiveCoverageComplete
  order_index <- with(summaries, order(
    !PolicyAdmissible, !SafetyAdmissible,
    WorstFalseReadyExactUpper,
    WorstFalseBoundaryHandoffExactUpper,
    WorstFalseUnreadyExactUpper, WorstMissedBoundaryExactUpper,
    WorstIndeterminateExactUpper, WorstNotEvaluableExactUpper,
    RulePriority, EligibleUpper, IneligibleLower, CandidateId
  ))
  ranked <- summaries[order_index, , drop = FALSE]
  ranked$Rank <- seq_len(nrow(ranked))
  winner <- ranked[1L, , drop = FALSE]
  selected <- isTRUE(winner$PolicyAdmissible)
  list(
    SelectionState = if (selected) policy$CandidateSelectedState else
      policy$NoAdmissibleCandidateState,
    SelectedCandidateId = if (selected) winner$CandidateId else NA_character_,
    BestDiagnosticCandidateId = winner$CandidateId,
    RankedCandidates = ranked,
    StationarityThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE,
    PostSelectionConfidenceCoverageClaimAllowed = FALSE
  )
}

mfrmr_gtwae_selection_audit <- function(policy = mfrmr_gtwae_policy()) {
  candidates <- policy$CandidateGrid$CandidateId[1:3]
  base <- data.frame(
    CandidateId = candidates,
    RulePriority = c(1L, 1L, 2L),
    EligibleUpper = c(1e-8, 1e-7, 1e-8),
    IneligibleLower = c(1e-7, 1e-6, 1e-7),
    SafetyFalseReady = c(0L, 1L, 0L),
    FalseBoundaryHandoff = c(0L, 0L, 0L),
    WorstFalseReadyExactUpper = c(0.03, 0.01, 0.03),
    WorstFalseBoundaryHandoffExactUpper = c(0.03, 0.01, 0.03),
    WorstFalseUnreadyExactUpper = c(0.08, 0.01, 0.00),
    WorstMissedBoundaryExactUpper = c(0.10, 0.01, 0.00),
    WorstIndeterminateExactUpper = c(0.12, 0.00, 1.00),
    WorstNotEvaluableExactUpper = c(0.02, 0.00, 0.00),
    ReferenceClassCoverageComplete = TRUE,
    CorrectDecisiveCoverageComplete = c(TRUE, TRUE, FALSE),
    stringsAsFactors = FALSE
  )
  positive <- mfrmr_gtwae_rank_candidate_summaries(base, policy)
  negative_rows <- base
  negative_rows$SafetyFalseReady <- 1L
  negative <- mfrmr_gtwae_rank_candidate_summaries(negative_rows, policy)
  identity <- list(
    Contract = "stationarity_acceptance_selection_audit_b1g11_v1",
    ZeroEventUpper = c(
      N25 = mfrmr_gtwae_binomial_upper(0L, 25L, policy$Confidence),
      N100 = mfrmr_gtwae_binomial_upper(0L, 100L, policy$Confidence),
      N200 = mfrmr_gtwae_binomial_upper(0L, 200L, policy$Confidence)
    ),
    MinimumTrialsForZeroEventUpperAtMostFivePercent =
      mfrmr_gtwae_minimum_zero_event_trials(0.05, policy$Confidence),
    PositiveSelection = positive,
    NegativeSelection = negative
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    SelectionAlgebraReady =
      identical(positive$SelectedCandidateId, candidates[[1L]]) &&
      identical(negative$SelectionState,
                policy$NoAdmissibleCandidateState) &&
      is.na(negative$SelectedCandidateId) &&
      !isTRUE(positive$ConfirmationAuthorized) &&
      !isTRUE(positive$StationarityThresholdFrozen)
  )), class = "mfrmr_gtwae_selection_audit")
}

mfrmr_gtwae_contract <- function(lme4_coverage_contract) {
  mfrmr_gtwae_require_primitives()
  if (!inherits(lme4_coverage_contract, "mfrmr_gtwad_contract") ||
      !identical(
        lme4_coverage_contract$ContractHash,
        "419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0"
      ) || !isTRUE(lme4_coverage_contract$BoxConstrainedSolverReady) ||
      !isTRUE(lme4_coverage_contract$BoundaryProfileMechanicsReady) ||
      isTRUE(lme4_coverage_contract$CalibrationExecutionAuthorized)) {
    stop("The exact non-authorizing b1g10 contract is required.",
         call. = FALSE)
  }
  policy <- mfrmr_gtwae_policy()
  audit <- mfrmr_gtwae_selection_audit(policy)
  if (!isTRUE(audit$SelectionAlgebraReady) ||
      !isTRUE(policy$ReferenceMethodCoverageComplete)) {
    stop("The b1g11 policy preflight failed.", call. = FALSE)
  }
  identity <- list(
    Contract = "stationarity_acceptance_contract_draft83d2b2b1g11_v1",
    UpstreamB1g10ContractHash = lme4_coverage_contract$ContractHash,
    ReferenceReceiptHash = policy$ReferenceReceiptHash,
    Policy = policy,
    SelectionAuditHash = audit$AuditHash,
    FunctionHashes = mfrmr_gtwae_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    AcceptancePolicyFrozen = TRUE,
    MonteCarloDecisionPolicyFrozen = TRUE,
    ReferenceMethodCoverageComplete = TRUE,
    ProductionBoundaryProbeReady = FALSE,
    RunnerImplementationReady = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    Audit = audit
  )), class = "mfrmr_gtwae_contract")
}

mfrmr_gtwae_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwae_source_registry", "mfrmr_gtwae_reference_receipts",
    "mfrmr_gtwae_candidate_grid", "mfrmr_gtwae_binomial_upper",
    "mfrmr_gtwae_minimum_zero_event_trials", "mfrmr_gtwae_policy",
    "mfrmr_gtwae_pair_classification", "mfrmr_gtwae_rate_row",
    "mfrmr_gtwae_cell_summary", "mfrmr_gtwae_max_informative",
    "mfrmr_gtwae_candidate_summary",
    "mfrmr_gtwae_rank_candidate_summaries",
    "mfrmr_gtwae_selection_audit", "mfrmr_gtwae_contract"
  )
  policy_environment <- environment(mfrmr_gtwae_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwae_function_hash(get(
      name, envir = policy_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
