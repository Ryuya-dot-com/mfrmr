# Exact continuous-normal binary GPCM slope-path microcase.
#
# Two zero-threshold binary items have slopes exp(t) and exp(-t).  For the
# discordant response pattern (1, 0), the marginal probability increases
# strictly for every finite t > 0 and approaches 1/4 without attaining it.
# The concordant pattern (1, 1) decreases to the same limit.  This file audits
# that closed-form argument and its exact sample count condition numerically;
# it does not certify a fitted model.

mfrmr_gmcb_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gmcb_validate <- function(distance, pattern) {
  distance <- as.numeric(distance)
  mfrmr_gmcb_assert(
    length(distance) == 1L && is.finite(distance) && distance >= 0,
    "`distance` must be one finite nonnegative scalar."
  )
  pattern <- match.arg(pattern, c("discordant_10", "concordant_11"))
  list(distance = distance, pattern = pattern)
}

mfrmr_gmcb_log_cosh <- function(value) {
  magnitude <- abs(value)
  magnitude + log1p(exp(-2 * magnitude)) - log(2)
}

mfrmr_gmcb_pair_probability <- function(x, distance,
                                         pattern = "discordant_10") {
  contract <- mfrmr_gmcb_validate(distance, pattern)
  x <- as.numeric(x)
  mfrmr_gmcb_assert(
    length(x) > 0L && all(is.finite(x)) && all(x >= 0),
    "`x` must contain finite nonnegative values."
  )
  log_cosh_large <- mfrmr_gmcb_log_cosh(x * cosh(contract$distance))
  log_cosh_small <- mfrmr_gmcb_log_cosh(x * sinh(contract$distance))
  discordant <- stats::plogis(log_cosh_small - log_cosh_large)
  if (identical(contract$pattern, "discordant_10")) {
    discordant
  } else {
    1 - discordant
  }
}

mfrmr_gmcb_pair_derivative <- function(x, distance,
                                        pattern = "discordant_10") {
  contract <- mfrmr_gmcb_validate(distance, pattern)
  x <- as.numeric(x)
  mfrmr_gmcb_assert(
    length(x) > 0L && all(is.finite(x)) && all(x >= 0),
    "`x` must contain finite nonnegative values."
  )
  if (contract$distance == 0) return(rep(0, length(x)))
  hyperbolic_cosine <- cosh(contract$distance)
  hyperbolic_sine <- sinh(contract$distance)
  discordant <- mfrmr_gmcb_pair_probability(
    x, contract$distance, "discordant_10"
  )
  positive_margin <- x * (
    hyperbolic_cosine * tanh(x * hyperbolic_sine) -
      hyperbolic_sine * tanh(x * hyperbolic_cosine)
  )
  derivative <- discordant * (1 - discordant) * positive_margin
  if (identical(contract$pattern, "discordant_10")) {
    derivative
  } else {
    -derivative
  }
}

mfrmr_gmcb_direct_probability <- function(theta, distance,
                                           pattern = "discordant_10") {
  contract <- mfrmr_gmcb_validate(distance, pattern)
  theta <- as.numeric(theta)
  increasing_slope <- exp(contract$distance)
  decreasing_slope <- exp(-contract$distance)
  first <- stats::plogis(increasing_slope * theta)
  second <- if (identical(contract$pattern, "discordant_10")) {
    stats::plogis(-decreasing_slope * theta)
  } else {
    stats::plogis(decreasing_slope * theta)
  }
  first * second
}

mfrmr_gmcb_integrate <- function(integrand, lower, upper, rel_tolerance) {
  result <- stats::integrate(
    integrand,
    lower = lower,
    upper = upper,
    rel.tol = rel_tolerance,
    abs.tol = rel_tolerance,
    subdivisions = 1000L,
    stop.on.error = TRUE
  )
  c(value = as.numeric(result$value), absolute_error = result$abs.error)
}

mfrmr_gmcb_point <- function(distance, pattern = "discordant_10",
                              rel_tolerance = 1e-11) {
  contract <- mfrmr_gmcb_validate(distance, pattern)
  tolerance <- as.numeric(rel_tolerance)
  mfrmr_gmcb_assert(
    length(tolerance) == 1L && is.finite(tolerance) && tolerance > 0,
    "`rel_tolerance` must be one finite positive scalar."
  )
  paired <- mfrmr_gmcb_integrate(
    function(x) {
      stats::dnorm(x) * mfrmr_gmcb_pair_probability(
        x, contract$distance, contract$pattern
      )
    },
    0, Inf, tolerance
  )
  direct <- mfrmr_gmcb_integrate(
    function(theta) {
      stats::dnorm(theta) * mfrmr_gmcb_direct_probability(
        theta, contract$distance, contract$pattern
      )
    },
    -Inf, Inf, tolerance
  )
  derivative <- mfrmr_gmcb_integrate(
    function(x) {
      stats::dnorm(x) * mfrmr_gmcb_pair_derivative(
        x, contract$distance, contract$pattern
      )
    },
    0, Inf, tolerance
  )
  boundary <- 0.25
  data.frame(
    Pattern = contract$pattern,
    Distance = contract$distance,
    MarginalProbability = paired[["value"]],
    DirectMarginalProbability = direct[["value"]],
    PairIdentityDifference = paired[["value"]] - direct[["value"]],
    AnalyticDerivative = derivative[["value"]],
    BoundaryProbability = boundary,
    BoundaryMinusMarginal = boundary - paired[["value"]],
    MaximumIntegrationError = max(
      paired[["absolute_error"]],
      direct[["absolute_error"]],
      derivative[["absolute_error"]]
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gmcb_sample_profile <- function(profile, case_id,
                                       discordant_persons,
                                       concordant_persons) {
  counts <- c(discordant_persons, concordant_persons)
  mfrmr_gmcb_assert(
    all(is.finite(counts)) && all(counts >= 0) &&
      all(counts == as.integer(counts)) && sum(counts) > 0,
    "Pattern counts must be nonnegative integers with a positive total."
  )
  discordant <- profile[profile$Pattern == "discordant_10", , drop = FALSE]
  concordant <- profile[profile$Pattern == "concordant_11", , drop = FALSE]
  mfrmr_gmcb_assert(
    identical(discordant$Distance, concordant$Distance),
    "The two response-pattern profiles were not distance-aligned."
  )
  log_likelihood <- discordant_persons * log(
    discordant$MarginalProbability
  ) + concordant_persons * log(concordant$MarginalProbability)
  derivative <- discordant_persons *
    discordant$AnalyticDerivative / discordant$MarginalProbability +
    concordant_persons *
    concordant$AnalyticDerivative / concordant$MarginalProbability
  boundary_log_likelihood <- sum(counts) * log(0.25)
  data.frame(
    CaseId = as.character(case_id),
    DiscordantPersons = as.integer(discordant_persons),
    ConcordantPersons = as.integer(concordant_persons),
    Distance = discordant$Distance,
    LogLikelihood = log_likelihood,
    AnalyticDerivative = derivative,
    BoundaryLogLikelihood = boundary_log_likelihood,
    BoundaryMinusLogLikelihood = boundary_log_likelihood - log_likelihood,
    HalfLineIncreasingByCountTheorem =
      discordant_persons >= concordant_persons,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_mml_continuous_binary_path <- function(
    distances = c(0, 0.25, 0.5, 1, 2, 4, 8),
    difference_step = 1e-4) {
  distances <- as.numeric(distances)
  step <- as.numeric(difference_step)
  mfrmr_gmcb_assert(
    length(distances) >= 3L && all(is.finite(distances)) &&
      all(distances >= 0) && !is.unsorted(distances, strictly = TRUE),
    "`distances` must contain at least three strictly increasing values."
  )
  mfrmr_gmcb_assert(
    length(step) == 1L && is.finite(step) && step > 0 &&
      all(distances[distances > 0] > step),
    "`difference_step` must be positive and below every positive distance."
  )

  patterns <- c("discordant_10", "concordant_11")
  profile <- do.call(rbind, lapply(patterns, function(pattern) {
    do.call(rbind, lapply(distances, function(distance) {
      point <- mfrmr_gmcb_point(distance, pattern)
      if (distance == 0) {
        point$FiniteDifferenceDerivative <- 0
      } else {
        lower <- mfrmr_gmcb_point(distance - step, pattern)
        upper <- mfrmr_gmcb_point(distance + step, pattern)
        point$FiniteDifferenceDerivative <-
          (upper$MarginalProbability - lower$MarginalProbability) / (2 * step)
      }
      point$DerivativeDifference <-
        point$AnalyticDerivative - point$FiniteDifferenceDerivative
      point
    }))
  }))
  rownames(profile) <- NULL

  sample_cases <- data.frame(
    CaseId = c(
      "all_discordant", "balanced_patterns",
      "concordant_majority", "all_concordant"
    ),
    DiscordantPersons = c(12L, 6L, 5L, 0L),
    ConcordantPersons = c(0L, 6L, 7L, 12L),
    stringsAsFactors = FALSE
  )
  sample_rows <- vector("list", nrow(sample_cases))
  for (index in seq_len(nrow(sample_cases))) {
    sample_rows[[index]] <- mfrmr_gmcb_sample_profile(
      profile = profile,
      case_id = sample_cases$CaseId[[index]],
      discordant_persons = sample_cases$DiscordantPersons[[index]],
      concordant_persons = sample_cases$ConcordantPersons[[index]]
    )
  }
  sample_profile <- do.call(rbind, sample_rows)
  rownames(sample_profile) <- NULL

  theorem <- data.frame(
    Scope = "two_binary_zero_threshold_items_standard_normal",
    SlopePath = "alpha_1=exp(t);alpha_2=exp(-t);t>=0",
    DiscordantPatternResult =
      "strictly_increasing_to_unattained_one_quarter",
    ConcordantPatternResult =
      "strictly_decreasing_to_one_quarter",
    SampleHalfLineCondition =
      "discordant_person_count_greater_than_or_equal_to_concordant_count",
    MicrocaseContinuousHalfLineProved = TRUE,
    ProductionHalfLineCertified = FALSE,
    TheoremDependsOnNumericalIntegration = FALSE,
    NumericAuditUsesAdaptiveIntegration = TRUE,
    ReadinessEffect = "none_repository_microcase",
    stringsAsFactors = FALSE
  )

  list(
    status = "continuous_binary_microcase_proved_and_audited",
    theorem = theorem,
    profile = profile,
    sample_profile = sample_profile,
    boundary_probability = 0.25,
    full_gpcm_fit_covered = FALSE,
    moving_additive_coordinates_covered = FALSE,
    population_scale_path_covered = FALSE,
    readiness_overridden = FALSE,
    release_authorized = FALSE
  )
}
