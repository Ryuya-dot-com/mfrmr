# Repository-only log-centered continuous-likelihood oracle for ConQuest P2.
#
# The oracle scales each Person integrand by an independently located log-mode,
# integrates the two sides of a fixed [-12, 12] interval, and carries explicit
# numerical and omitted-normal-tail error bounds onto the deviance scale. It
# fits and launches nothing and cannot reclassify consumed contracts.

mfrmr_cq_p2co_specification <-
  "0.2.3-conquest-p2-log-centered-continuous-oracle-v1"
mfrmr_cq_p2co_contract <-
  "mfrmr_conquest_p2_log_centered_continuous_oracle_v1"
mfrmr_cq_p2co_tail_limit <- 12
mfrmr_cq_p2co_relative_tolerance <- 1e-12
mfrmr_cq_p2co_absolute_tolerance <- 1e-14
mfrmr_cq_p2co_subdivisions <- 1000L

mfrmr_cq_p2co_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2co_require_contract <- function() {
  target <- environment(mfrmr_cq_p2co_require_contract)
  required <- c(
    "mfrmr_cq_p2_fixture_registry", "mfrmr_cq_p2_observed_data",
    "mfrmr_cq_p2_probability", "mfrmr_cq_p2_continuous_loglikelihood",
    "mfrmr_cq_p2ad_fixed_loglikelihood"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_p2ad_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2ad_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_bounded_adaptive_density_contract_v1"
  )
  mfrmr_cq_p2co_assert(
    all(available) && identity,
    "Source the exact bounded adaptive-density contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2co_budget_registry <- function() {
  data.frame(
    GateId = c(
      "Q121_LOG_CENTERED_CONTINUOUS_DEVIANCE",
      "Q241_LOG_CENTERED_CONTINUOUS_DEVIANCE",
      "LOG_CENTERED_DECLARED_DEVIANCE_ERROR_BOUND"
    ),
    AbsoluteTolerance = c(1e-7, 1e-7, 1e-8),
    SourceBasis = c(
      "unchanged_future_continuous_target_budget_applied_to_q121",
      "unchanged_future_continuous_target_budget_applied_to_q241",
      paste0(
        "prospective_10x_separation_below_continuous_agreement_budget_",
        "using_numerical_plus_normal_tail_bound"
      )
    ),
    Candidate003OutputInformed = FALSE,
    LegacyContinuousOutputTuned = FALSE,
    Frozen = TRUE,
    CanReclassifyConsumedContract = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2co_budget <- function(gate_id) {
  budget <- mfrmr_cq_p2co_budget_registry()
  row <- budget[budget$GateId == gate_id, , drop = FALSE]
  mfrmr_cq_p2co_assert(
    nrow(row) == 1L && isTRUE(row$Frozen) &&
      !isTRUE(row$Candidate003OutputInformed) &&
      !isTRUE(row$LegacyContinuousOutputTuned),
    "The continuous-oracle qualification budget is invalid."
  )
  as.numeric(row$AbsoluteTolerance)
}

mfrmr_cq_p2co_numerical_contract <- function() {
  data.frame(
    TailLower = -mfrmr_cq_p2co_tail_limit,
    TailUpper = mfrmr_cq_p2co_tail_limit,
    ModeSearchLower = -mfrmr_cq_p2co_tail_limit,
    ModeSearchUpper = mfrmr_cq_p2co_tail_limit,
    RelativeTolerance = mfrmr_cq_p2co_relative_tolerance,
    AbsoluteTolerance = mfrmr_cq_p2co_absolute_tolerance,
    Subdivisions = mfrmr_cq_p2co_subdivisions,
    IntegrationSplit = "independently_located_log_integrand_mode",
    OmittedTailBound = "response_likelihood_le_1_times_normal_tail_mass",
    CandidateOutputRead = FALSE,
    ExternalExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2co_person_log_integrand <- function(z, person_data, fixture) {
  truth <- fixture$Truth
  x <- unique(person_data$X)
  mfrmr_cq_p2co_assert(
    length(x) == 1L, "Person covariate drifted within continuous-oracle rows."
  )
  vapply(z, function(value) {
    theta <- truth$PopulationIntercept + truth$PopulationSlope * x +
      sqrt(truth$PopulationVariance) * value
    response_loglik <- sum(vapply(seq_len(nrow(person_data)), function(index) {
      log(mfrmr_cq_p2_probability(
        fixture$Model, theta, person_data$Rater[index],
        person_data$Criterion[index]
      )[person_data$Response[index] + 1L])
    }, numeric(1L)))
    response_loglik + stats::dnorm(value, log = TRUE)
  }, numeric(1L))
}

mfrmr_cq_p2co_person_integral <- function(person_data, fixture) {
  lower <- -mfrmr_cq_p2co_tail_limit
  upper <- mfrmr_cq_p2co_tail_limit
  objective <- function(z) {
    mfrmr_cq_p2co_person_log_integrand(z, person_data, fixture)
  }
  mode <- stats::optimize(
    objective, interval = c(lower, upper), maximum = TRUE, tol = 1e-10
  )
  mode_location <- as.numeric(mode$maximum)
  mode_log_integrand <- as.numeric(mode$objective)
  scaled <- function(z) {
    exp(mfrmr_cq_p2co_person_log_integrand(z, person_data, fixture) -
          mode_log_integrand)
  }
  left <- stats::integrate(
    scaled, lower = lower, upper = mode_location,
    rel.tol = mfrmr_cq_p2co_relative_tolerance,
    abs.tol = mfrmr_cq_p2co_absolute_tolerance,
    subdivisions = mfrmr_cq_p2co_subdivisions,
    stop.on.error = TRUE
  )
  right <- stats::integrate(
    scaled, lower = mode_location, upper = upper,
    rel.tol = mfrmr_cq_p2co_relative_tolerance,
    abs.tol = mfrmr_cq_p2co_absolute_tolerance,
    subdivisions = mfrmr_cq_p2co_subdivisions,
    stop.on.error = TRUE
  )
  scaled_value <- left$value + right$value
  scaled_error <- left$abs.error + right$abs.error
  log_integral <- mode_log_integrand + log(scaled_value)
  numerical_relative_error <- scaled_error / scaled_value
  numerical_log_error_bound <- if (
      is.finite(numerical_relative_error) &&
        numerical_relative_error >= 0 && numerical_relative_error < 1) {
    -log1p(-numerical_relative_error)
  } else {
    Inf
  }
  log_tail_mass <- log(2) + stats::pnorm(
    -mfrmr_cq_p2co_tail_limit, log.p = TRUE
  )
  tail_log_error_bound <- log1p(exp(log_tail_mass - log_integral))
  probe <- c(mode_location - 1e-4, mode_location + 1e-4)
  probe <- probe[probe > lower & probe < upper]
  local_maximum <- length(probe) == 2L && all(
    objective(probe) <= mode_log_integrand + 1e-12
  )
  mode_interior <- mode_location > lower + 1e-6 &&
    mode_location < upper - 1e-6
  data.frame(
    Person = person_data$Person[1L],
    Responses = nrow(person_data),
    ModeLocation = mode_location,
    ModeLogIntegrand = mode_log_integrand,
    ModeInterior = mode_interior,
    LocalMaximumCheck = local_maximum,
    LeftMessage = as.character(left$message),
    RightMessage = as.character(right$message),
    LogLikelihood = log_integral,
    NumericalRelativeError = numerical_relative_error,
    NumericalLogErrorBound = numerical_log_error_bound,
    NormalTailLogErrorBound = tail_log_error_bound,
    TotalLogErrorBound = numerical_log_error_bound + tail_log_error_bound,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2co_log_centered_loglikelihood <- function(fixture) {
  data <- mfrmr_cq_p2_observed_data(fixture)
  by_person <- split(data, data$Person)
  detail <- do.call(rbind, lapply(by_person, function(person_data) {
    mfrmr_cq_p2co_person_integral(person_data, fixture)
  }))
  rownames(detail) <- NULL
  converged <- all(detail$LeftMessage == "OK") &&
    all(detail$RightMessage == "OK")
  finite <- all(is.finite(unlist(detail[, c(
    "ModeLocation", "ModeLogIntegrand", "LogLikelihood",
    "NumericalRelativeError", "NumericalLogErrorBound",
    "NormalTailLogErrorBound", "TotalLogErrorBound"
  )])))
  mfrmr_cq_p2co_assert(
    finite && converged && all(detail$ModeInterior) &&
      all(detail$LocalMaximumCheck),
    "The log-centered Person integrals failed their numerical contract."
  )
  list(
    RegistryRowId = fixture$RegistryRowId,
    Model = fixture$Model,
    Persons = nrow(detail),
    ObservedRows = sum(detail$Responses),
    LogLikelihood = sum(detail$LogLikelihood),
    Deviance = -2 * sum(detail$LogLikelihood),
    DeclaredDevianceErrorBound = 2 * sum(detail$TotalLogErrorBound),
    ModesInterior = all(detail$ModeInterior),
    LocalMaximumChecksPassed = all(detail$LocalMaximumCheck),
    IntegrationsConverged = converged,
    Detail = detail,
    Candidate003Reclassified = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_p2co_audit <- function() {
  mfrmr_cq_p2co_require_contract()
  fixtures <- mfrmr_cq_p2_fixture_registry()
  rows <- lapply(fixtures, function(fixture) {
    centered <- mfrmr_cq_p2co_log_centered_loglikelihood(fixture)
    q121 <- mfrmr_cq_p2ad_fixed_loglikelihood(fixture, 121L)
    q241 <- mfrmr_cq_p2ad_fixed_loglikelihood(fixture, 241L)
    legacy <- mfrmr_cq_p2_continuous_loglikelihood(
      fixture, relative_tolerance = 1e-10
    )
    legacy_deviance <- -2 * legacy$LogLikelihood
    data.frame(
      RegistryRowId = fixture$RegistryRowId,
      Model = fixture$Model,
      Persons = centered$Persons,
      Q121LogCenteredDevianceMovement = abs(
        q121$Deviance - centered$Deviance
      ),
      Q241LogCenteredDevianceMovement = abs(
        q241$Deviance - centered$Deviance
      ),
      LegacyLogCenteredDevianceMovement = abs(
        legacy_deviance - centered$Deviance
      ),
      DeclaredDevianceErrorBound = centered$DeclaredDevianceErrorBound,
      ModesInterior = centered$ModesInterior,
      LocalMaximumChecksPassed = centered$LocalMaximumChecksPassed,
      IntegrationsConverged = centered$IntegrationsConverged,
      Finite = all(is.finite(c(
        q121$Deviance, q241$Deviance, legacy_deviance,
        centered$Deviance, centered$DeclaredDevianceErrorBound
      ))),
      Candidate003Reclassified = FALSE,
      ExternalExecutionAuthorized = FALSE,
      ScientificEquivalenceInferred = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_p2co_qualify <- function(audit, expected_registry_rows) {
  audit <- as.data.frame(audit, stringsAsFactors = FALSE)
  expected_registry_rows <- as.character(expected_registry_rows)
  required <- c(
    "RegistryRowId", "Q121LogCenteredDevianceMovement",
    "Q241LogCenteredDevianceMovement", "DeclaredDevianceErrorBound",
    "ModesInterior", "LocalMaximumChecksPassed", "IntegrationsConverged",
    "Finite"
  )
  complete <- all(required %in% names(audit)) &&
    nrow(audit) == length(expected_registry_rows) &&
    !anyDuplicated(audit$RegistryRowId) &&
    setequal(audit$RegistryRowId, expected_registry_rows)
  passed <- complete && all(audit$Finite) && all(audit$ModesInterior) &&
    all(audit$LocalMaximumChecksPassed) && all(audit$IntegrationsConverged) &&
    all(audit$Q121LogCenteredDevianceMovement <=
          mfrmr_cq_p2co_budget(
            "Q121_LOG_CENTERED_CONTINUOUS_DEVIANCE"
          )) &&
    all(audit$Q241LogCenteredDevianceMovement <=
          mfrmr_cq_p2co_budget(
            "Q241_LOG_CENTERED_CONTINUOUS_DEVIANCE"
          )) &&
    all(audit$DeclaredDevianceErrorBound <=
          mfrmr_cq_p2co_budget(
            "LOG_CENTERED_DECLARED_DEVIANCE_ERROR_BOUND"
          ))
  list(
    status = if (passed) {
      "log_centered_continuous_oracle_qualified"
    } else {
      "log_centered_continuous_oracle_not_qualified"
    },
    complete_denominator = complete,
    passed = passed,
    candidate_003_reclassified = FALSE,
    consumed_predecessor_reclassified = FALSE,
    external_execution_authorized = FALSE
  )
}

mfrmr_cq_p2co_review <- function(run_oracles = FALSE) {
  mfrmr_cq_p2co_require_contract()
  budget <- mfrmr_cq_p2co_budget_registry()
  numerical <- mfrmr_cq_p2co_numerical_contract()
  contract_ready <- nrow(budget) == 3L && all(budget$Frozen) &&
    identical(budget$AbsoluteTolerance, c(1e-7, 1e-7, 1e-8)) &&
    !any(budget$Candidate003OutputInformed) &&
    !any(budget$LegacyContinuousOutputTuned) &&
    numerical$TailLower == -12 && numerical$TailUpper == 12 &&
    numerical$RelativeTolerance == 1e-12 &&
    numerical$AbsoluteTolerance == 1e-14 &&
    numerical$Subdivisions == 1000L
  audit <- if (isTRUE(run_oracles)) mfrmr_cq_p2co_audit() else data.frame()
  expected <- names(mfrmr_cq_p2_fixture_registry())
  qualification <- if (nrow(audit)) {
    mfrmr_cq_p2co_qualify(audit, expected)
  } else {
    NULL
  }
  oracle_ready <- isTRUE(run_oracles) && !is.null(qualification) &&
    isTRUE(qualification$passed)
  list(
    specification = mfrmr_cq_p2co_specification,
    contract_version = mfrmr_cq_p2co_contract,
    status = if (contract_ready && oracle_ready) {
      "log_centered_continuous_oracle_contract_and_audit_ready"
    } else if (contract_ready && !isTRUE(run_oracles)) {
      "log_centered_continuous_oracle_contract_frozen_audit_unopened"
    } else {
      "log_centered_continuous_oracle_contract_or_audit_failed"
    },
    budgets = budget,
    numerical_contract = numerical,
    audit = audit,
    qualification = qualification,
    contract_ready = contract_ready,
    oracle_audit_run = isTRUE(run_oracles),
    oracle_qualified = oracle_ready,
    legacy_continuous_oracle_replaced_for_future_candidates = oracle_ready,
    candidate_003_reclassified = FALSE,
    candidate_004_generation_authorized = contract_ready && oracle_ready,
    candidate_004_fit_authorized = FALSE,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
