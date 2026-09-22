# Repository-only successor integration contract for ConQuest P2.
#
# This contract was frozen after candidate 003 was closed, but it cannot alter
# that result. It uses pre-candidate evidence to treat q31 -> q61 as a required
# diagnostic and q61 -> q121 plus q121 -> continuous as the governing layers
# for a future disjoint candidate. It fits and launches nothing.

mfrmr_cq_p2si_specification <-
  "0.2.3-conquest-p2-successor-integration-contract-v1"
mfrmr_cq_p2si_contract <-
  "mfrmr_conquest_p2_successor_integration_contract_v1"

mfrmr_cq_p2si_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2si_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2si_require_contracts)
  required <- c(
    "mfrmr_cq_p2_fixture_registry", "mfrmr_cq_p2_observed_data",
    "mfrmr_cq_p2_probability", "mfrmr_cq_p2_continuous_loglikelihood",
    "mfrmr_cq_p2m_metric_rule_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- c(
    exists("mfrmr_cq_p2_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"
      ),
    exists("mfrmr_cq_p2m_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2m_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_metric_boundary_contract_v1"
      )
  )
  mfrmr_cq_p2si_assert(
    all(available) && all(identity),
    "Source the exact P2 fixture and metric contracts first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2si_prior_p2_budget <- function(rule_id) {
  mfrmr_cq_p2si_require_contracts()
  rules <- mfrmr_cq_p2m_metric_rule_registry()
  row <- rules[rules$RuleId == rule_id, , drop = FALSE]
  mfrmr_cq_p2si_assert(
    nrow(row) == 1L && isTRUE(row$Frozen) &&
      isTRUE(row$NumericPassAuthorized) &&
      is.finite(row$AbsoluteTolerance) && row$AbsoluteTolerance > 0,
    "The same-estimand P2 numerical budget is absent or ineligible."
  )
  as.numeric(row$AbsoluteTolerance)
}

mfrmr_cq_p2si_budget_registry <- function() {
  coordinate <- mfrmr_cq_p2si_prior_p2_budget(
    "P2-MFRMR-Q-MOVEMENT-COORDINATE"
  )
  deviance <- mfrmr_cq_p2si_prior_p2_budget(
    "P2-MFRMR-Q-MOVEMENT-DEVIANCE"
  )
  data.frame(
    BudgetId = c(
      "P2S-FINAL-Q-COORDINATE", "P2S-FINAL-Q-DEVIANCE",
      "P2S-Q121-CONTINUOUS-DEVIANCE"
    ),
    Units = c(
      "common_model_coordinate", "positive_deviance", "positive_deviance"
    ),
    AbsoluteTolerance = c(coordinate, deviance, 1e-7),
    SourceBasis = c(
      "unchanged_same_estimand_P2_coordinate_budget_applied_to_q61_q121",
      "unchanged_same_estimand_P2_deviance_budget_applied_to_q61_q121",
      paste0(
        "candidate_uninformed_continuous_oracle_budget_1000x_",
        "declared_relative_integration_tolerance"
      )
    ),
    Candidate003OutputInformed = FALSE,
    P3NumericBudgetTransferred = FALSE,
    Frozen = TRUE,
    CanReclassifyCandidate003 = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2si_budget <- function(budget_id) {
  budget <- mfrmr_cq_p2si_budget_registry()
  row <- budget[budget$BudgetId == budget_id, , drop = FALSE]
  mfrmr_cq_p2si_assert(
    nrow(row) == 1L && isTRUE(row$Frozen) &&
      !isTRUE(row$Candidate003OutputInformed) &&
      !isTRUE(row$P3NumericBudgetTransferred),
    "The successor integration budget is invalid or retrospectively informed."
  )
  as.numeric(row$AbsoluteTolerance)
}

mfrmr_cq_p2si_ladder_registry <- function() {
  data.frame(
    Layer = c(
      "required_snapshot", "required_snapshot", "required_snapshot",
      "starting_grid_diagnostic", "governing_finite_grid",
      "governing_continuous_target"
    ),
    From = c(NA, NA, NA, 31, 61, 121),
    To = c(31, 61, 121, 61, 121, Inf),
    Role = c(
      rep("retained_complete_denominator", 3L),
      "finite_required_diagnostic_no_pass_threshold",
      "coordinate_and_deviance_pass_required",
      "deviance_pass_required"
    ),
    CoordinateTolerance = c(
      rep(NA_real_, 4L),
      mfrmr_cq_p2si_budget("P2S-FINAL-Q-COORDINATE"), NA_real_
    ),
    DevianceTolerance = c(
      rep(NA_real_, 4L),
      mfrmr_cq_p2si_budget("P2S-FINAL-Q-DEVIANCE"),
      mfrmr_cq_p2si_budget("P2S-Q121-CONTINUOUS-DEVIANCE")
    ),
    Governing = c(rep(FALSE, 4L), TRUE, TRUE),
    Candidate003CanBeReclassified = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2si_integration_state_registry <- function() {
  data.frame(
    IntegrationState = c(
      "integration_eligible", "q31_q61_diagnostic_missing",
      "q61_q121_coordinate_unresolved", "q61_q121_deviance_unresolved",
      "q121_continuous_target_unresolved", "nonfinite_integration_value"
    ),
    FutureCrossEngineNumericEligible = c(TRUE, rep(FALSE, 5L)),
    ObservedOutcome = c("eligible", rep("integration_unresolved", 5L)),
    Candidate003CanBeReclassified = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2si_classify_integration <- function(
    q31_q61_coordinate, q31_q61_deviance,
    q61_q121_coordinate, q61_q121_deviance,
    q121_continuous_deviance) {
  value <- c(
    q31_q61_coordinate, q31_q61_deviance,
    q61_q121_coordinate, q61_q121_deviance,
    q121_continuous_deviance
  )
  if (length(value) != 5L || anyNA(value)) {
    state <- "q31_q61_diagnostic_missing"
  } else if (any(!is.finite(value))) {
    state <- "nonfinite_integration_value"
  } else if (abs(q61_q121_coordinate) >
      mfrmr_cq_p2si_budget("P2S-FINAL-Q-COORDINATE")) {
    state <- "q61_q121_coordinate_unresolved"
  } else if (abs(q61_q121_deviance) >
      mfrmr_cq_p2si_budget("P2S-FINAL-Q-DEVIANCE")) {
    state <- "q61_q121_deviance_unresolved"
  } else if (abs(q121_continuous_deviance) >
      mfrmr_cq_p2si_budget("P2S-Q121-CONTINUOUS-DEVIANCE")) {
    state <- "q121_continuous_target_unresolved"
  } else {
    state <- "integration_eligible"
  }
  registry <- mfrmr_cq_p2si_integration_state_registry()
  row <- registry[registry$IntegrationState == state, , drop = FALSE]
  list(
    State = state,
    ObservedOutcome = row$ObservedOutcome,
    FutureCrossEngineNumericEligible =
      isTRUE(row$FutureCrossEngineNumericEligible),
    Q31Q61DiagnosticThresholdApplied = FALSE,
    Candidate003Reclassified = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_p2si_gh_normal <- function(nodes) {
  nodes <- as.integer(nodes)[1L]
  mfrmr_cq_p2si_assert(
    nodes %in% c(31L, 61L, 121L),
    "The successor oracle permits only q=31, q=61, or q=121."
  )
  index <- seq_len(nodes - 1L)
  jacobi <- matrix(0, nrow = nodes, ncol = nodes)
  off_diagonal <- sqrt(index / 2)
  jacobi[cbind(index, index + 1L)] <- off_diagonal
  jacobi[cbind(index + 1L, index)] <- off_diagonal
  decomposition <- eigen(jacobi, symmetric = TRUE)
  list(
    nodes = sqrt(2) * decomposition$values,
    weights = decomposition$vectors[1L, ]^2
  )
}

mfrmr_cq_p2si_fixed_loglikelihood <- function(fixture, nodes) {
  quadrature <- mfrmr_cq_p2si_gh_normal(nodes)
  data <- mfrmr_cq_p2_observed_data(fixture)
  truth <- fixture$Truth
  by_person <- split(data, data$Person)
  log_likelihood <- vapply(by_person, function(person_data) {
    x <- unique(person_data$X)
    mfrmr_cq_p2si_assert(
      length(x) == 1L, "Person covariate drifted within oracle rows."
    )
    theta <- truth$PopulationIntercept + truth$PopulationSlope * x +
      sqrt(truth$PopulationVariance) * quadrature$nodes
    log_pattern <- vapply(theta, function(value) {
      sum(vapply(seq_len(nrow(person_data)), function(index) {
        log(mfrmr_cq_p2_probability(
          fixture$Model, value, person_data$Rater[index],
          person_data$Criterion[index]
        )[person_data$Response[index] + 1L])
      }, numeric(1L)))
    }, numeric(1L))
    log_joint <- log_pattern + log(quadrature$weights)
    maximum <- max(log_joint)
    maximum + log(sum(exp(log_joint - maximum)))
  }, numeric(1L))
  mfrmr_cq_p2si_assert(
    all(is.finite(log_likelihood)) &&
      abs(sum(quadrature$weights) - 1) <= 1e-13,
    "The finite-GHQ truth oracle was nonfinite or unnormalized."
  )
  list(
    RegistryRowId = fixture$RegistryRowId,
    Model = fixture$Model,
    Nodes = as.integer(nodes),
    Persons = length(log_likelihood),
    LogLikelihood = sum(log_likelihood),
    Deviance = -2 * sum(log_likelihood),
    QuadratureWeightSumDifference = abs(sum(quadrature$weights) - 1),
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_p2si_truth_oracle_audit <- function(relative_tolerance = 1e-10) {
  mfrmr_cq_p2si_require_contracts()
  fixtures <- mfrmr_cq_p2_fixture_registry()
  rows <- lapply(fixtures, function(fixture) {
    q31 <- mfrmr_cq_p2si_fixed_loglikelihood(fixture, 31L)
    q61 <- mfrmr_cq_p2si_fixed_loglikelihood(fixture, 61L)
    q121 <- mfrmr_cq_p2si_fixed_loglikelihood(fixture, 121L)
    continuous <- mfrmr_cq_p2_continuous_loglikelihood(
      fixture, relative_tolerance = relative_tolerance
    )
    data.frame(
      RegistryRowId = fixture$RegistryRowId,
      Model = fixture$Model,
      Persons = q121$Persons,
      Q31Q61DevianceMovement = abs(q61$Deviance - q31$Deviance),
      Q61Q121DevianceMovement = abs(q121$Deviance - q61$Deviance),
      Q121ContinuousDevianceMovement = abs(
        q121$Deviance + 2 * continuous$LogLikelihood
      ),
      ContinuousIntegrationAbsoluteErrorEstimate =
        continuous$IntegrationAbsoluteErrorEstimate,
      Finite = all(is.finite(c(
        q31$Deviance, q61$Deviance, q121$Deviance,
        continuous$LogLikelihood
      ))),
      ExternalExecutionAuthorized = FALSE,
      ScientificEquivalenceInferred = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_p2si_review <- function(run_truth_oracles = FALSE) {
  mfrmr_cq_p2si_require_contracts()
  budget <- mfrmr_cq_p2si_budget_registry()
  ladder <- mfrmr_cq_p2si_ladder_registry()
  states <- mfrmr_cq_p2si_integration_state_registry()
  contract_ready <- nrow(budget) == 3L && nrow(ladder) == 6L &&
    nrow(states) == 6L && all(budget$Frozen) &&
    !any(budget$Candidate003OutputInformed) &&
    !any(budget$P3NumericBudgetTransferred) &&
    !any(budget$CanReclassifyCandidate003) &&
    identical(ladder$To[1:3], c(31, 61, 121)) &&
    !ladder$Governing[4L] && all(ladder$Governing[5:6])
  audit <- if (isTRUE(run_truth_oracles)) {
    mfrmr_cq_p2si_truth_oracle_audit()
  } else {
    data.frame()
  }
  oracle_ready <- isTRUE(run_truth_oracles) && nrow(audit) == 13L &&
    all(audit$Finite) &&
    all(audit$Q61Q121DevianceMovement <=
          mfrmr_cq_p2si_budget("P2S-FINAL-Q-DEVIANCE")) &&
    all(audit$Q121ContinuousDevianceMovement <=
          mfrmr_cq_p2si_budget("P2S-Q121-CONTINUOUS-DEVIANCE"))
  list(
    specification = mfrmr_cq_p2si_specification,
    contract_version = mfrmr_cq_p2si_contract,
    status = if (contract_ready && oracle_ready) {
      "P2_successor_integration_contract_and_truth_oracles_ready"
    } else if (contract_ready && !isTRUE(run_truth_oracles)) {
      "P2_successor_integration_contract_frozen_truth_oracles_unopened"
    } else {
      "P2_successor_integration_contract_or_truth_oracle_failed"
    },
    budgets = budget,
    ladder = ladder,
    integration_states = states,
    truth_oracle_audit = audit,
    contract_ready = contract_ready,
    truth_oracles_run = isTRUE(run_truth_oracles),
    truth_oracle_ready = oracle_ready,
    candidate_003_reclassified = FALSE,
    candidate_004_generation_authorized = contract_ready && oracle_ready,
    candidate_004_fit_authorized = FALSE,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
