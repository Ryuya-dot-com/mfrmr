# Draft.83d2b2b0 replicated G-theory weak-information pilot-plan prototype.
#
# Repository-internal only. This file freezes independent replication bands,
# Monte Carlo precision targets, candidate rule architecture, three-state
# accounting, and execution authorization. It does not select a threshold or
# generate any reserved calibration/confirmation dataset by itself.

mfrmr_gtwp_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtw_extract_observables", "mfrmr_gtw_method_contrasts",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtd4_execute_one"
  )
  prototype_environment <- environment(mfrmr_gtwp_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81/82/83a/c1/c2/d1/d2a/d2b0/d2b1/d2b2a before ",
      "Draft.83d2b2b0: ", paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwp_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwp_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwp_phase_table", "mfrmr_gtwp_candidate_registry",
    "mfrmr_gtwp_plan", "mfrmr_gtwp_manifest",
    "mfrmr_gtwp_classify", "mfrmr_gtwp_state_accounting",
    "mfrmr_gtwp_binomial_upper", "mfrmr_gtwp_execute_manifest"
  )
  environment <- environment(mfrmr_gtwp_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwp_function_hash(get(name, envir = environment, inherits = TRUE))
  }, character(1L)), functions)
}

mfrmr_gtwp_phase_table <- function() {
  replications <- c(2L, 25L, 100L, 200L)
  data.frame(
    PhaseId = c(
      "schema_smoke", "feasibility_pilot", "calibration_pilot",
      "confirmation"
    ),
    ReplicateStart = c(2L, 101L, 201L, 501L),
    ReplicateEnd = c(3L, 125L, 300L, 700L),
    ReplicationsPerCell = replications,
    ScenarioProfile = c(
      "baseline_three_controls", "all_registered_cells",
      "all_registered_cells", "all_registered_cells"
    ),
    ScenarioCellCount = c(3L, 30L, 30L, 30L),
    MethodCount = 4L,
    PlannedUnits = c(24L, 3000L, 12000L, 24000L),
    WorstCaseBernoulliMCSEPerCellMethod = sqrt(0.25 / replications),
    PhasePurpose = c(
      "runner_schema_only_no_rule_selection",
      "diagnostic_availability_and_overlap_feasibility_only",
      "candidate_rule_selection_and_freeze_before_confirmation",
      "apply_frozen_rule_without_modification"
    ),
    ExecutionAuthorized = c(TRUE, TRUE, FALSE, FALSE),
    RuleSelectionPermitted = c(FALSE, FALSE, TRUE, FALSE),
    ConfirmationUse = c(FALSE, FALSE, FALSE, TRUE),
    Viewed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwp_candidate_registry <- function() {
  scores <- data.frame(
    ScoreId = c(
      "target_fraction_total", "target_to_residual_ratio",
      "target_relative_se_profiled", "reduced_likelihood_drop",
      "backend_relative_difference", "ml_reml_relative_difference"
    ),
    Scope = c(
      "single_fit", "single_fit", "single_fit_backend_specific",
      "single_fit_with_reduced_refit", "paired_backend_validation",
      "paired_likelihood_validation"
    ),
    CurrentAvailability = c(
      "implemented_covering_smoke", "implemented_covering_smoke",
      "pending_enriched_diagnostic_refit", "pending_enriched_diagnostic_refit",
      "implemented_covering_smoke", "implemented_covering_smoke"
    ),
    DirectionTowardResolved = c(
      "higher", "higher", "lower", "higher", "lower", "lower"
    ),
    InferentialLabel = "candidate_diagnostic_not_test_or_interval",
    TruthBlindAtApplication = TRUE,
    stringsAsFactors = FALSE
  )
  rules <- data.frame(
    RuleFamilyId = c(
      "fraction_zone", "ratio_zone", "ratio_precision_zone",
      "likelihood_precision_zone"
    ),
    RequiredScoreIds = c(
      "target_fraction_total",
      "target_to_residual_ratio",
      "target_to_residual_ratio;target_relative_se_profiled",
      "reduced_likelihood_drop;target_relative_se_profiled"
    ),
    ApplicationContract = c(
      "single_fit", "single_fit", "single_fit_backend_specific",
      "full_and_reduced_same_backend_same_likelihood"
    ),
    ComplexityOrder = seq_len(4L),
    State = "candidate_architecture_no_selected_threshold",
    stringsAsFactors = FALSE
  )
  grids <- list(
    target_fraction_total = c(
      1e-5, 3e-5, 1e-4, 3e-4, 0.001, 0.003, 0.01, 0.03, 0.1, 0.3
    ),
    target_to_residual_ratio = c(
      1e-5, 3e-5, 1e-4, 3e-4, 0.001, 0.003, 0.01, 0.03, 0.1, 0.3, 1
    ),
    target_relative_se_profiled = c(0.1, 0.25, 0.5, 0.75, 1, 1.5, 2, 3),
    reduced_likelihood_drop = c(0, 0.25, 0.5, 1, 2, 3.84, 5.41, 6.63, 10)
  )
  selection <- data.frame(
    Priority = 1:6,
    Criterion = c(
      "zero_negative_control_resolved_rows",
      "minimum_negative_control_one_sided_upper_bound",
      "minimum_positive_control_not_resolved_rows",
      "minimum_positive_control_indeterminate_rows",
      "minimum_not_evaluable_rows",
      "lowest_rule_complexity"
    ),
    Use = c(
      "hard_then_lexicographic", rep("lexicographic", 4L),
      "deterministic_tie_break"
    ),
    stringsAsFactors = FALSE
  )
  list(
    Scores = scores, Rules = rules, CutpointGrids = grids,
    SelectionOrder = selection, SelectedRuleFamily = NA_character_,
    SelectedLowerCutpoint = NA_real_, SelectedUpperCutpoint = NA_real_,
    ThresholdFrozen = FALSE
  )
}

mfrmr_gtwp_plan <- function(registry = mfrmr_gtw_registry()) {
  mfrmr_gtwp_require_primitives()
  if (!inherits(registry, "mfrmr_gtw_registry")) {
    stop("`registry` must be the Draft.83d2b2a calibration registry.",
         call. = FALSE)
  }
  phases <- mfrmr_gtwp_phase_table()
  candidates <- mfrmr_gtwp_candidate_registry()
  if (max(phases$ReplicateEnd) >= 1000L) {
    stop("Replication bands collide with the 1000-seed scenario spacing.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "gtheory_weak_information_pilot_plan_draft83d2b2b0_v1",
    CalibrationRegistryHash = registry$RegistryHash,
    GeneratorSeedContract =
      "scenario_seed_start_plus_replicate_minus_one_paired_across_methods",
    IndependentMonteCarloUnit = "scenario_by_replicate_dataset",
    MethodPairing = "all_four_methods_share_each_generated_dataset",
    CrossScenarioPooling = "prohibited_for_primary_cell_method_error_rates",
    PhaseTable = phases, CandidateRegistry = candidates,
    NegativeControlRole = "negative_control_not_resolved",
    PositiveControlRole = "positive_control_resolved",
    TransitionRole = "transition_no_binary_requirement",
    StateSpace = c(
      "not_resolved", "indeterminate", "resolved", "not_evaluable"
    ),
    FunctionHashes = mfrmr_gtwp_function_hashes()
  )
  structure(c(identity, list(
    PlanHash = mfrmr_gta_hash(identity), CalibrationRegistry = registry,
    SchemaSmokeExecuted = FALSE, FeasibilityPilotExecuted = FALSE,
    CalibrationPilotAuthorized = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, ConfirmationViewed = FALSE,
    RecoveryEvidenceReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwp_plan")
}

mfrmr_gtwp_phase_scenarios <- function(plan, phase_id) {
  phase <- plan$PhaseTable[
    plan$PhaseTable$PhaseId == phase_id, , drop = FALSE
  ]
  if (nrow(phase) != 1L) {
    stop("Unknown Draft.83d2b2b0 phase.", call. = FALSE)
  }
  if (phase$ScenarioProfile == "baseline_three_controls") {
    return(paste0(
      "GT-WI-baseline_complete-",
      c("exact_zero", "numerical_near_zero", "reference_1200")
    ))
  }
  plan$CalibrationRegistry$Cells$ScenarioId
}

mfrmr_gtwp_manifest <- function(plan = mfrmr_gtwp_plan(), phase_id,
                                 scenario_ids = NULL, method_ids = NULL) {
  if (!inherits(plan, "mfrmr_gtwp_plan")) {
    stop("`plan` must be a Draft.83d2b2b0 pilot plan.", call. = FALSE)
  }
  phase_id <- as.character(phase_id)
  phase <- plan$PhaseTable[
    plan$PhaseTable$PhaseId == phase_id, , drop = FALSE
  ]
  if (length(phase_id) != 1L || nrow(phase) != 1L) {
    stop("Unknown Draft.83d2b2b0 phase.", call. = FALSE)
  }
  expected_scenarios <- mfrmr_gtwp_phase_scenarios(plan, phase_id)
  if (is.null(scenario_ids)) scenario_ids <- expected_scenarios
  if (is.null(method_ids)) {
    method_ids <- plan$CalibrationRegistry$Methods$MethodId
  }
  scenario_ids <- unique(as.character(scenario_ids))
  method_ids <- unique(as.character(method_ids))
  if (any(!scenario_ids %in% expected_scenarios) ||
      any(!method_ids %in% plan$CalibrationRegistry$Methods$MethodId)) {
    stop("Scenario or method is outside the registered phase.", call. = FALSE)
  }
  cells <- plan$CalibrationRegistry$Cells[match(
    scenario_ids, plan$CalibrationRegistry$Cells$ScenarioId
  ), c(
    "ScenarioId", "DesignId", "VarianceId", "TargetVariance",
    "TruthRegion", "EvaluationRole", "SeedStart"
  ), drop = FALSE]
  methods <- plan$CalibrationRegistry$Methods[match(
    method_ids, plan$CalibrationRegistry$Methods$MethodId
  ), , drop = FALSE]
  replicates <- seq.int(phase$ReplicateStart, phase$ReplicateEnd)
  index <- expand.grid(
    Cell = seq_len(nrow(cells)), Replicate = replicates,
    Method = seq_len(nrow(methods)), KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  rows <- cbind(
    cells[index$Cell, , drop = FALSE],
    Replicate = as.integer(index$Replicate),
    methods[index$Method, , drop = FALSE]
  )
  rows$DatasetId <- sprintf("%s/R%04d", rows$ScenarioId, rows$Replicate)
  rows$Seed <- rows$SeedStart + rows$Replicate - 1L
  rows$RegistryHash <- plan$CalibrationRegistryHash
  rows$PilotPlanHash <- plan$PlanHash
  rows$PhaseId <- phase_id
  rows$ExecutionAuthorized <- phase$ExecutionAuthorized
  rows$RuleSelectionPermitted <- phase$RuleSelectionPermitted
  rows$ConfirmationUse <- phase$ConfirmationUse
  rows <- rows[c(
    "ScenarioId", "Replicate", "DatasetId", "Seed", "MethodId", "Backend",
    "RegistryHash", "PilotPlanHash", "PhaseId", "DesignId", "VarianceId",
    "TargetVariance", "TruthRegion", "EvaluationRole", "Likelihood",
    "ExecutionAuthorized", "RuleSelectionPermitted", "ConfirmationUse"
  )]
  row.names(rows) <- NULL
  complete <- setequal(scenario_ids, expected_scenarios) && setequal(
    method_ids, plan$CalibrationRegistry$Methods$MethodId
  ) && nrow(rows) == phase$PlannedUnits
  identity <- list(
    Contract = "gtheory_weak_information_phase_manifest_draft83d2b2b0_v1",
    PilotPlanHash = plan$PlanHash, PhaseId = phase_id,
    Rows = rows, PhaseComplete = complete
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity), PlannedUnits = nrow(rows),
    IndependentDatasetCount = length(unique(rows$DatasetId)),
    ExecutionAuthorized = isTRUE(phase$ExecutionAuthorized),
    RuleSelectionPermitted = isTRUE(phase$RuleSelectionPermitted),
    ConfirmationUse = isTRUE(phase$ConfirmationUse),
    DataGenerated = FALSE, ResultsViewed = FALSE
  )), class = "mfrmr_gtwp_manifest")
}

mfrmr_gtwp_classify <- function(score, lower, upper, fit_available = TRUE,
                                 direction = c("higher", "lower")) {
  direction <- match.arg(direction)
  score <- as.numeric(score)
  fit_available <- rep_len(as.logical(fit_available), length(score))
  if (length(lower) != 1L || length(upper) != 1L ||
      !is.finite(lower) || !is.finite(upper) || lower >= upper) {
    stop("Finite cutpoints must satisfy `lower < upper`.", call. = FALSE)
  }
  state <- rep("indeterminate", length(score))
  state[!fit_available | !is.finite(score)] <- "not_evaluable"
  eligible <- state != "not_evaluable"
  if (direction == "higher") {
    state[eligible & score <= lower] <- "not_resolved"
    state[eligible & score >= upper] <- "resolved"
  } else {
    state[eligible & score >= upper] <- "not_resolved"
    state[eligible & score <= lower] <- "resolved"
  }
  factor(
    state,
    levels = c("not_resolved", "indeterminate", "resolved", "not_evaluable")
  )
}

mfrmr_gtwp_state_accounting <- function(data) {
  required <- c("EvaluationRole", "ResolutionState")
  if (!is.data.frame(data) || !all(required %in% names(data))) {
    stop("State accounting requires evaluation roles and resolution states.",
         call. = FALSE)
  }
  allowed <- c("not_resolved", "indeterminate", "resolved", "not_evaluable")
  state <- as.character(data$ResolutionState)
  if (any(!state %in% allowed)) {
    stop("Unknown weak-information resolution state.", call. = FALSE)
  }
  negative <- data$EvaluationRole == "negative_control_not_resolved"
  positive <- data$EvaluationRole == "positive_control_resolved"
  transition <- data$EvaluationRole == "transition_no_binary_requirement"
  data.frame(
    NegativeExpected = sum(negative),
    NegativeFalseReady = sum(negative & state == "resolved"),
    NegativeIndeterminate = sum(negative & state == "indeterminate"),
    NegativeNotEvaluable = sum(negative & state == "not_evaluable"),
    PositiveExpected = sum(positive),
    PositiveFalseBlock = sum(positive & state == "not_resolved"),
    PositiveIndeterminate = sum(positive & state == "indeterminate"),
    PositiveNotEvaluable = sum(positive & state == "not_evaluable"),
    TransitionExpected = sum(transition),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwp_binomial_upper <- function(events, trials, confidence = 0.95) {
  events <- as.integer(events)
  trials <- as.integer(trials)
  if (length(events) != 1L || length(trials) != 1L || is.na(events) ||
      is.na(trials) || trials < 1L || events < 0L || events > trials ||
      length(confidence) != 1L || !is.finite(confidence) || confidence <= 0 ||
      confidence >= 1) {
    stop("Invalid exact-binomial upper-bound arguments.", call. = FALSE)
  }
  if (events == trials) return(1)
  stats::qbeta(confidence, events + 1, trials - events)
}

mfrmr_gtwp_execute_manifest <- function(
    manifest, plan = mfrmr_gtwp_plan(), progress = interactive()) {
  if (!inherits(manifest, "mfrmr_gtwp_manifest") ||
      !inherits(plan, "mfrmr_gtwp_plan")) {
    stop("Draft.83d2b2b0 execution requires its plan and manifest.",
         call. = FALSE)
  }
  if (!identical(manifest$PilotPlanHash, plan$PlanHash)) {
    stop("Pilot plan and manifest identities differ.", call. = FALSE)
  }
  if (!isTRUE(manifest$ExecutionAuthorized) ||
      any(!manifest$Rows$ExecutionAuthorized)) {
    stop("This pilot phase is not authorized for execution.", call. = FALSE)
  }
  if (isTRUE(manifest$ConfirmationUse) ||
      any(manifest$Rows$ConfirmationUse)) {
    stop("Confirmation data remain sealed until a rule is frozen.",
         call. = FALSE)
  }
  rows <- manifest$Rows
  outputs <- vector("list", nrow(rows))
  observables <- vector("list", nrow(rows))
  unit_cache <- list()
  for (index in seq_len(nrow(rows))) {
    key <- rows$DatasetId[[index]]
    if (is.null(unit_cache[[key]])) {
      generation <- mfrmr_gtw_generate(
        plan$CalibrationRegistry, rows$ScenarioId[[index]],
        rows$Replicate[[index]]
      )
      prefit <- mfrmr_gtd3_prefit_one(generation)
      unit_cache[[key]] <- list(Generation = generation, PreFit = prefit)
    }
    unit <- unit_cache[[key]]
    row <- rows[index, , drop = FALSE]
    row$GeneratorHash <- unit$Generation$GeneratorHash
    row$IncidenceAuditHash <- unit$PreFit$IncidenceAuditHash
    row$StructuralRankHash <- unit$PreFit$ScalableStructuralRankHash
    row$PreFitState <- unit$PreFit$PreFitState
    row$PreFitEligible <- unit$PreFit$PreFitEligible
    row$MethodEligibilityState <- if (unit$PreFit$PreFitEligible) {
      "eligible_adapter_pending_execution"
    } else unit$PreFit$PreFitState
    row$FitAttemptAuthorized <- FALSE
    row$AtomicResultRecorded <- FALSE
    unit$Row <- row
    if (isTRUE(progress)) {
      message(sprintf(
        "[%d/%d] %s / %s", index, nrow(rows), key, row$MethodId[[1L]]
      ))
    }
    outputs[[index]] <- mfrmr_gtd4_execute_one(
      row, unit$Generation, unit$PreFit
    )
    observables[[index]] <- mfrmr_gtw_extract_observables(
      outputs[[index]], unit
    )
  }
  atomic <- do.call(rbind, lapply(outputs, `[[`, "Row"))
  observable <- do.call(rbind, observables)
  row.names(atomic) <- NULL
  row.names(observable) <- NULL
  contrasts <- mfrmr_gtw_method_contrasts(observable)
  identity <- list(
    Contract = "gtheory_weak_information_pilot_execution_draft83d2b2b0_v1",
    PilotPlanHash = plan$PlanHash, ManifestHash = manifest$ManifestHash,
    PhaseId = manifest$PhaseId,
    FunctionHashes = mfrmr_gtwp_function_hashes(),
    AtomicRows = atomic[, setdiff(names(atomic), "RuntimeSeconds"), drop = FALSE],
    ObservableRows = observable, MethodContrasts = contrasts
  )
  atomic_pass <- all(atomic$AtomicResultRecorded) && all(
    (atomic$EstimationGatePassed & atomic$FailureStage == "none") |
      (!atomic$EstimationGatePassed & atomic$FailureStage != "none")
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity), PlannedUnits = nrow(atomic),
    IndependentDatasetCount = length(unique(atomic$DatasetId)),
    FitAttemptCount = sum(atomic$FitAttempted),
    FitReturnCount = sum(atomic$FitReturned),
    BasePointGatePassCount = sum(atomic$EstimationGatePassed),
    AtomicAccountingPassed = atomic_pass,
    PhaseComplete = manifest$PhaseComplete,
    SchemaExecutionReady = identical(manifest$PhaseId, "schema_smoke") &&
      manifest$PhaseComplete && atomic_pass,
    FeasibilityEvidenceReady = FALSE, CalibrationEvidenceReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    ConfirmationViewed = FALSE, RecoveryEvidenceReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwp_execution")
}
