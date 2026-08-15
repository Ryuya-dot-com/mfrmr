# Repository-only mfrmr preflight contract for ConQuest P2 candidate 004.
#
# q31 is diagnostic. RSM and PCM are first fit at q31/q61/q121; q241 is fit
# only if the complete q61--q121 slice fails. The lowest complete dense pair
# must pass unchanged coordinate/deviance budgets and a log-centered continuous
# reevaluation at the upper fit. This file cannot launch ConQuest.

mfrmr_cq_p2c4p_specification <-
  "0.2.3-conquest-p2-candidate-004-mfrmr-preflight-v1"
mfrmr_cq_p2c4p_contract <-
  "mfrmr_conquest_p2_candidate_004_mfrmr_preflight_v1"
mfrmr_cq_p2c4p_candidate_id <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004"
mfrmr_cq_p2c4p_output_basename <-
  "conquest-p2-candidate-004-mfrmr-preflight-20260815-v1"
mfrmr_cq_p2c4p_minimum_population_variance <- 0.05

mfrmr_cq_p2c4p_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4p_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2c4p_require_contracts)
  required <- c(
    "mfrmr_cq_p2c4_fixture", "mfrmr_cq_p2c4o_review",
    "mfrmr_cq_p2c3p_namespace", "mfrmr_cq_p2c3p_fit_gate",
    "mfrmr_cq_p2c3p_coordinates", "mfrmr_cq_p2c3p_failure_summary",
    "mfrmr_cq_p2ad_stage_registry", "mfrmr_cq_p2ad_select_stage",
    "mfrmr_cq_p2co_budget"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identities <- c(
    exists("mfrmr_cq_p2c4o_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2c4o_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_candidate_004_fixture_observation_v1"
      ),
    exists("mfrmr_cq_p2c3p_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2c3p_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_candidate_003_mfrmr_preflight_v1"
      ),
    exists("mfrmr_cq_p2ad_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2ad_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_bounded_adaptive_density_contract_v1"
      ),
    exists("mfrmr_cq_p2co_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2co_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_log_centered_continuous_oracle_v1"
      )
  )
  mfrmr_cq_p2c4p_assert(
    all(available) && all(identities),
    paste(
      "Source the exact candidate-004 observation, retained fit gate,",
      "adaptive-density, and log-centered-oracle contracts first."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4p_plan <- function() {
  stage <- mfrmr_cq_p2ad_stage_registry()
  dense <- stage[stage$Governing, , drop = FALSE]
  family <- rep(c("RSM", "PCM"), each = 4L)
  nodes <- rep(c(31L, 61L, 121L, 241L), times = 2L)
  out <- data.frame(
    ExecutionOrder = seq_along(nodes),
    RunId = paste0(tolower(family), "_q", sprintf("%03d", nodes)),
    Family = family,
    Nodes = nodes,
    ExecutionPhase = ifelse(nodes == 241L, "conditional_dense_pair_2", "initial"),
    Role = rep(c("diagnostic", "dense_pair_1_lower", "dense_pair_1_upper", "dense_pair_2_upper"), times = 2L),
    ExpectedNpar = rep(c(10L, 14L), each = 4L),
    ExpectedExpandedCoordinateCount = rep(c(13L, 19L), each = 4L),
    MinimumPopulationVariance = mfrmr_cq_p2c4p_minimum_population_variance,
    DenseCoordinateAbsoluteTolerance = dense$CoordinateTolerance[1L],
    DenseDevianceAbsoluteTolerance = dense$DevianceTolerance[1L],
    UpperContinuousDevianceTolerance =
      dense$UpperContinuousDevianceTolerance[1L],
    DeclaredContinuousErrorBoundTolerance = mfrmr_cq_p2co_budget(
      "LOG_CENTERED_DECLARED_DEVIANCE_ERROR_BOUND"
    ),
    FitAttemptCap = 1L,
    Candidate003OutputTuned = FALSE,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_p2c4p_assert(
    nrow(out) == 8L &&
      identical(out$Family, rep(c("RSM", "PCM"), each = 4L)) &&
      identical(out$Nodes, rep(c(31L, 61L, 121L, 241L), times = 2L)) &&
      sum(out$ExecutionPhase == "initial") == 6L &&
      sum(out$ExecutionPhase == "conditional_dense_pair_2") == 2L &&
      identical(out$ExpectedNpar, rep(c(10L, 14L), each = 4L)) &&
      identical(
        out$ExpectedExpandedCoordinateCount,
        rep(c(13L, 19L), each = 4L)
      ) &&
      all(out$MinimumPopulationVariance == 0.05) &&
      all(out$DenseCoordinateAbsoluteTolerance == 2e-6) &&
      all(out$DenseDevianceAbsoluteTolerance == 2e-6) &&
      all(out$UpperContinuousDevianceTolerance == 1e-7) &&
      all(out$DeclaredContinuousErrorBoundTolerance == 1e-8) &&
      all(out$FitAttemptCap == 1L) &&
      !any(out$Candidate003OutputTuned),
    "The candidate-004 mfrmr preflight plan drifted."
  )
  out
}

mfrmr_cq_p2c4p_fixture <- function() {
  observation <- mfrmr_cq_p2c4o_review()
  mfrmr_cq_p2c4p_assert(
    isTRUE(observation$mfrmr_fit_preflight_contract_authorized) &&
      !isTRUE(observation$mfrmr_fit_authorized) &&
      !isTRUE(observation$external_execution_authorized),
    "Candidate 004 is not eligible for a frozen mfrmr preflight contract."
  )
  fixture <- mfrmr_cq_p2c4_fixture()
  data <- fixture$Data
  data$Score <- data$Response
  data$Response <- NULL
  person <- unique(data[, c("Person", "X"), drop = FALSE])
  list(
    long = data,
    person = person,
    source_fixture = fixture,
    truth_recovery_authorized = FALSE,
    external_execution_authorized = FALSE
  )
}

mfrmr_cq_p2c4p_fit_arguments <- function(family, nodes, fixture) {
  family <- toupper(as.character(family)[1L])
  nodes <- as.integer(nodes)[1L]
  mfrmr_cq_p2c4p_assert(
    family %in% c("RSM", "PCM") && nodes %in% c(31L, 61L, 121L, 241L),
    "The preflight permits only RSM/PCM at q=31/61/121/241."
  )
  out <- list(
    data = fixture$long,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 0,
    rating_max = 3,
    method = "MML",
    model = family,
    population_formula = ~ X,
    person_data = fixture$person,
    quad_points = nodes,
    maxit = 2000L,
    reltol = 1e-12,
    mml_engine = "direct"
  )
  if (family == "PCM") out$step_facet <- "Criterion"
  out
}

mfrmr_cq_p2c4p_fit_gate <- function(summary, sigma2, expected_npar) {
  mfrmr_cq_p2c3p_fit_gate(summary, sigma2, expected_npar)
}

mfrmr_cq_p2c4p_expanded_coordinates <- function(fit, arm) {
  mfrmr_cq_p2c3p_coordinates(fit, arm)
}

mfrmr_cq_p2c4p_fitted_coordinates <- function(fit, family, fixture) {
  family <- toupper(as.character(family)[1L])
  rater_levels <- sort(unique(as.character(fixture$long$Rater)))
  criterion_levels <- sort(unique(as.character(fixture$long$Criterion)))
  facet <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  extract_facet <- function(name, levels) {
    table <- facet[facet$Facet == name, , drop = FALSE]
    value <- as.numeric(table$Estimate[match(levels, table$Level)])
    mfrmr_cq_p2c4p_assert(
      length(value) == length(levels) && all(is.finite(value)),
      paste0("The fitted ", name, " coordinates are incomplete.")
    )
    stats::setNames(value, levels)
  }
  rater <- extract_facet("Rater", rater_levels)
  criterion <- extract_facet("Criterion", criterion_levels)
  step_table <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  if (family == "RSM") {
    shared <- as.numeric(step_table$Estimate[match(
      paste0("Step_", 1:3), step_table$Step
    )])
    steps <- matrix(
      rep(shared, times = length(criterion_levels)),
      nrow = length(criterion_levels), byrow = TRUE,
      dimnames = list(criterion_levels, paste0("Step_", 1:3))
    )
  } else {
    key <- paste(step_table$StepFacet, step_table$Step, sep = "\r")
    steps <- t(vapply(criterion_levels, function(level) {
      as.numeric(step_table$Estimate[match(
        paste(level, paste0("Step_", 1:3), sep = "\r"), key
      )])
    }, numeric(3L)))
    rownames(steps) <- criterion_levels
    colnames(steps) <- paste0("Step_", 1:3)
  }
  beta <- as.numeric(fit$population$coefficients[c("(Intercept)", "X")])
  names(beta) <- c("Intercept", "X")
  sigma2 <- as.numeric(fit$population$sigma2)
  mfrmr_cq_p2c4p_assert(
    all(is.finite(c(beta, sigma2, rater, criterion, steps))) && sigma2 > 0 &&
      abs(sum(rater)) <= 1e-8 && abs(sum(criterion)) <= 1e-8 &&
      all(abs(rowSums(steps)) <= 1e-8),
    "The fitted coordinates violate finiteness or sum-zero constraints."
  )
  list(
    family = family, beta = beta, sigma2 = sigma2,
    rater = rater, criterion = criterion, steps = steps
  )
}

mfrmr_cq_p2c4p_person_log_integrand <- function(z, person_data, coordinate) {
  x <- unique(person_data$X)
  mfrmr_cq_p2c4p_assert(
    length(x) == 1L, "Person covariate drifted within preflight rows."
  )
  vapply(z, function(value) {
    theta <- coordinate$beta["Intercept"] + coordinate$beta["X"] * x +
      sqrt(coordinate$sigma2) * value
    response_loglik <- sum(vapply(seq_len(nrow(person_data)), function(index) {
      rater <- person_data$Rater[index]
      criterion <- person_data$Criterion[index]
      eta <- theta - coordinate$rater[rater] - coordinate$criterion[criterion]
      category <- 0:3
      log_kernel <- category * eta - c(
        0, cumsum(coordinate$steps[criterion, ])
      )
      log_probability <- log_kernel - {
        maximum <- max(log_kernel)
        maximum + log(sum(exp(log_kernel - maximum)))
      }
      log_probability[person_data$Score[index] + 1L]
    }, numeric(1L)))
    response_loglik + stats::dnorm(value, log = TRUE)
  }, numeric(1L))
}

mfrmr_cq_p2c4p_person_integral <- function(person_data, coordinate) {
  lower <- -mfrmr_cq_p2co_tail_limit
  upper <- mfrmr_cq_p2co_tail_limit
  objective <- function(z) {
    mfrmr_cq_p2c4p_person_log_integrand(z, person_data, coordinate)
  }
  mode <- stats::optimize(
    objective, interval = c(lower, upper), maximum = TRUE, tol = 1e-10
  )
  location <- as.numeric(mode$maximum)
  log_mode <- as.numeric(mode$objective)
  scaled <- function(z) exp(objective(z) - log_mode)
  left <- stats::integrate(
    scaled, lower = lower, upper = location,
    rel.tol = mfrmr_cq_p2co_relative_tolerance,
    abs.tol = mfrmr_cq_p2co_absolute_tolerance,
    subdivisions = mfrmr_cq_p2co_subdivisions, stop.on.error = TRUE
  )
  right <- stats::integrate(
    scaled, lower = location, upper = upper,
    rel.tol = mfrmr_cq_p2co_relative_tolerance,
    abs.tol = mfrmr_cq_p2co_absolute_tolerance,
    subdivisions = mfrmr_cq_p2co_subdivisions, stop.on.error = TRUE
  )
  scaled_value <- left$value + right$value
  relative_error <- (left$abs.error + right$abs.error) / scaled_value
  numerical_log_error <- if (
      is.finite(relative_error) && relative_error >= 0 && relative_error < 1) {
    -log1p(-relative_error)
  } else {
    Inf
  }
  log_integral <- log_mode + log(scaled_value)
  log_tail_mass <- log(2) + stats::pnorm(
    -mfrmr_cq_p2co_tail_limit, log.p = TRUE
  )
  tail_log_error <- log1p(exp(log_tail_mass - log_integral))
  probe <- c(location - 1e-4, location + 1e-4)
  local_maximum <- length(probe) == 2L &&
    all(probe > lower & probe < upper) &&
    all(objective(probe) <= log_mode + 1e-12)
  data.frame(
    Person = person_data$Person[1L],
    LogLikelihood = log_integral,
    TotalLogErrorBound = numerical_log_error + tail_log_error,
    ModeInterior = location > lower + 1e-6 && location < upper - 1e-6,
    LocalMaximumCheck = local_maximum,
    IntegrationsConverged = left$message == "OK" && right$message == "OK",
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4p_continuous_deviance <- function(fit, family, fixture) {
  coordinate <- mfrmr_cq_p2c4p_fitted_coordinates(fit, family, fixture)
  by_person <- split(fixture$long, fixture$long$Person)
  detail <- do.call(rbind, lapply(by_person, function(person_data) {
    mfrmr_cq_p2c4p_person_integral(person_data, coordinate)
  }))
  rownames(detail) <- NULL
  ready <- nrow(detail) == nrow(fixture$person) &&
    all(is.finite(detail$LogLikelihood)) &&
    all(is.finite(detail$TotalLogErrorBound)) &&
    all(detail$ModeInterior) && all(detail$LocalMaximumCheck) &&
    all(detail$IntegrationsConverged)
  mfrmr_cq_p2c4p_assert(
    ready, "The fitted log-centered continuous reevaluation failed."
  )
  list(
    LogLikelihood = sum(detail$LogLikelihood),
    Deviance = -2 * sum(detail$LogLikelihood),
    DeclaredDevianceErrorBound = 2 * sum(detail$TotalLogErrorBound),
    Detail = detail
  )
}

mfrmr_cq_p2c4p_empty_coordinates <- function() {
  data.frame(
    RunId = character(), Family = character(), Nodes = integer(),
    Coordinate = character(), Estimate = numeric(),
    ExternalExecutionAuthorized = logical(),
    ScientificEquivalenceInferred = logical(), stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4p_pair_metrics <- function(
    lower_nodes, upper_nodes, fit_summary, coordinates, fits, plan, fixture) {
  rows <- lapply(c("RSM", "PCM"), function(family) {
    summaries <- fit_summary[
      fit_summary$Family == family &
        fit_summary$Nodes %in% c(lower_nodes, upper_nodes), , drop = FALSE
    ]
    lower <- coordinates[
      coordinates$Family == family & coordinates$Nodes == lower_nodes,
      c("Coordinate", "Estimate"), drop = FALSE
    ]
    upper <- coordinates[
      coordinates$Family == family & coordinates$Nodes == upper_nodes,
      c("Coordinate", "Estimate"), drop = FALSE
    ]
    same <- nrow(lower) > 0L && nrow(lower) == nrow(upper) &&
      !anyDuplicated(lower$Coordinate) && !anyDuplicated(upper$Coordinate) &&
      setequal(lower$Coordinate, upper$Coordinate)
    movement <- NA_real_
    if (same) {
      upper <- upper[match(lower$Coordinate, upper$Coordinate), , drop = FALSE]
      movement <- max(abs(upper$Estimate - lower$Estimate))
    }
    expected_count <- unique(
      plan$ExpectedExpandedCoordinateCount[plan$Family == family]
    )
    complete <- same && length(expected_count) == 1L &&
      nrow(lower) == expected_count
    deviance_movement <- if (
        nrow(summaries) == 2L && all(is.finite(summaries$Deviance))) {
      abs(
        summaries$Deviance[summaries$Nodes == upper_nodes] -
          summaries$Deviance[summaries$Nodes == lower_nodes]
      )
    } else {
      NA_real_
    }
    structural <- nrow(summaries) == 2L &&
      all(summaries$StructuralNumericalPass)
    upper_run <- paste0(tolower(family), "_q", sprintf("%03d", upper_nodes))
    continuous <- if (!is.null(fits[[upper_run]])) {
      tryCatch(
        mfrmr_cq_p2c4p_continuous_deviance(
          fits[[upper_run]], family, fixture
        ),
        error = function(error) error
      )
    } else {
      simpleError("upper fit unavailable")
    }
    continuous_ready <- !inherits(continuous, "error")
    continuous_deviance <- if (continuous_ready) continuous$Deviance else NA_real_
    declared_bound <- if (continuous_ready) {
      continuous$DeclaredDevianceErrorBound
    } else {
      NA_real_
    }
    upper_deviance <- summaries$Deviance[summaries$Nodes == upper_nodes]
    continuous_movement <- if (
        continuous_ready && length(upper_deviance) == 1L &&
          is.finite(upper_deviance)) {
      abs(upper_deviance - continuous_deviance)
    } else {
      NA_real_
    }
    finite <- all(is.finite(c(
      movement, deviance_movement, continuous_deviance,
      continuous_movement, declared_bound
    )))
    data.frame(
      ArmId = family,
      LowerNodes = as.integer(lower_nodes),
      UpperNodes = as.integer(upper_nodes),
      ExpectedCoordinateCount = expected_count,
      CoordinateCount = if (same) nrow(lower) else 0L,
      CompleteCoordinateDenominator = complete,
      SelectedPairStructuralPass = structural,
      CoordinateMovement = movement,
      DevianceMovement = deviance_movement,
      UpperContinuousDeviance = continuous_deviance,
      UpperContinuousDevianceMovement = continuous_movement,
      DeclaredContinuousDevianceErrorBound = declared_bound,
      ContinuousNumericalContractPassed = continuous_ready &&
        is.finite(declared_bound) && declared_bound <= 1e-8,
      Finite = finite,
      ContinuousError = if (continuous_ready) NA_character_ else
        conditionMessage(continuous),
      ExternalExecutionAuthorized = FALSE,
      EvidencePromotionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_cq_p2c4p_select_stage <- function(metrics) {
  metrics <- as.data.frame(metrics, stringsAsFactors = FALSE)
  required <- c(
    "CompleteCoordinateDenominator", "SelectedPairStructuralPass",
    "ContinuousNumericalContractPassed", "Finite"
  )
  mfrmr_cq_p2c4p_assert(
    all(required %in% names(metrics)),
    "Candidate-004 stage metrics are incomplete."
  )
  selection_metrics <- metrics
  selection_metrics$Finite <- metrics$Finite &
    metrics$CompleteCoordinateDenominator &
    metrics$SelectedPairStructuralPass &
    metrics$ContinuousNumericalContractPassed
  mfrmr_cq_p2ad_select_stage(
    selection_metrics, expected_arm_ids = c("RSM", "PCM")
  )
}

mfrmr_cq_p2c4p_diagnostic <- function(fit_summary, coordinates, plan) {
  rows <- lapply(c("RSM", "PCM"), function(family) {
    summaries <- fit_summary[
      fit_summary$Family == family & fit_summary$Nodes %in% c(31L, 61L),
      , drop = FALSE
    ]
    q31 <- coordinates[
      coordinates$Family == family & coordinates$Nodes == 31L,
      c("Coordinate", "Estimate"), drop = FALSE
    ]
    q61 <- coordinates[
      coordinates$Family == family & coordinates$Nodes == 61L,
      c("Coordinate", "Estimate"), drop = FALSE
    ]
    same <- nrow(q31) > 0L && nrow(q31) == nrow(q61) &&
      setequal(q31$Coordinate, q61$Coordinate) &&
      !anyDuplicated(q31$Coordinate) && !anyDuplicated(q61$Coordinate)
    coordinate_movement <- NA_real_
    if (same) {
      q61 <- q61[match(q31$Coordinate, q61$Coordinate), , drop = FALSE]
      coordinate_movement <- max(abs(q61$Estimate - q31$Estimate))
    }
    deviance_movement <- if (
        nrow(summaries) == 2L && all(is.finite(summaries$Deviance))) {
      abs(summaries$Deviance[summaries$Nodes == 61L] -
            summaries$Deviance[summaries$Nodes == 31L])
    } else {
      NA_real_
    }
    expected <- unique(
      plan$ExpectedExpandedCoordinateCount[plan$Family == family]
    )
    data.frame(
      Family = family,
      ExpectedCoordinateCount = expected,
      CompleteCoordinateDenominator = same && nrow(q31) == expected,
      MaximumAbsoluteQ31Q61CoordinateMovement = coordinate_movement,
      AbsoluteQ31Q61DevianceMovement = deviance_movement,
      Governing = FALSE,
      ExternalExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_cq_p2c4p_review <- function() {
  mfrmr_cq_p2c4p_require_contracts()
  observation <- mfrmr_cq_p2c4o_review()
  plan <- mfrmr_cq_p2c4p_plan()
  ready <- isTRUE(observation$mfrmr_fit_preflight_contract_authorized) &&
    nrow(plan) == 8L && sum(plan$ExecutionPhase == "initial") == 6L &&
    sum(plan$ExecutionPhase == "conditional_dense_pair_2") == 2L
  list(
    specification = mfrmr_cq_p2c4p_specification,
    contract_version = mfrmr_cq_p2c4p_contract,
    candidate_id = mfrmr_cq_p2c4p_candidate_id,
    status = if (ready) {
      "candidate_004_mfrmr_preflight_contract_frozen_execution_unopened"
    } else {
      "candidate_004_mfrmr_preflight_contract_invalid"
    },
    plan = plan,
    initial_fit_cap = 6L,
    conditional_fit_cap = 2L,
    total_fit_cap = 8L,
    frozen_output_basename = mfrmr_cq_p2c4p_output_basename,
    q31_governing = FALSE,
    q241_runs_only_after_complete_dense_pair_1_failure = TRUE,
    design_rank_not_evaluated_is_inference_ready = FALSE,
    mfrmr_preflight_execution_authorized = ready,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    truth_recovery_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_p2c4p_fit_one <- function(arm, namespace, fixture, output_dir) {
  warnings <- character(0)
  fit <- tryCatch(
    withCallingHandlers(
      do.call(
        get("fit_mfrm", envir = namespace, inherits = FALSE),
        mfrmr_cq_p2c4p_fit_arguments(arm$Family, arm$Nodes, fixture)
      ),
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(error) error
  )
  if (inherits(fit, "error")) {
    summary <- mfrmr_cq_p2c3p_failure_summary(arm, conditionMessage(fit))
    writeLines(
      conditionMessage(fit),
      file.path(output_dir, paste0(arm$RunId, "_error.txt")),
      useBytes = TRUE
    )
    return(list(summary = summary, coordinates = NULL, fit = NULL))
  }
  saveRDS(fit, file.path(output_dir, paste0(arm$RunId, "_fit.rds")))
  fit_summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
  sigma2 <- as.numeric(fit$population$sigma2)
  gate <- mfrmr_cq_p2c4p_fit_gate(
    fit_summary, sigma2, arm$ExpectedNpar
  )
  summary <- data.frame(
    RunId = arm$RunId, Family = arm$Family, Nodes = arm$Nodes,
    ExpectedNpar = arm$ExpectedNpar,
    ObservedNpar = as.integer(fit_summary$Npar[1L]),
    LogLik = as.numeric(fit_summary$LogLik[1L]),
    Deviance = as.numeric(fit_summary$Deviance[1L]),
    PopulationVariance = sigma2,
    ConvergenceStatus = as.character(fit_summary$ConvergenceStatus[1L]),
    ConvergenceSeverity = as.character(fit_summary$ConvergenceSeverity[1L]),
    FitReadiness = as.character(fit_summary$FitReadiness[1L]),
    EstimabilityState = as.character(fit_summary$EstimabilityState[1L]),
    BoundaryState = as.character(fit_summary$BoundaryState[1L]),
    NumericalState = as.character(fit_summary$NumericalState[1L]),
    ReadinessReasonCodes = as.character(fit_summary$ReadinessReasonCodes[1L]),
    WarningCount = length(unique(warnings)), Error = NA_character_,
    gate,
    stringsAsFactors = FALSE
  )
  coordinates <- mfrmr_cq_p2c4p_expanded_coordinates(fit, arm)
  writeLines(
    if (length(warnings)) unique(warnings) else "none",
    file.path(output_dir, paste0(arm$RunId, "_warnings.txt")),
    useBytes = TRUE
  )
  list(summary = summary, coordinates = coordinates, fit = fit)
}

mfrmr_cq_p2c4p_execute <- function(
    output_dir, source_root = ".", authorize = FALSE) {
  mfrmr_cq_p2c4p_assert(
    identical(authorize, TRUE),
    "Execution is held; authorize only the frozen candidate-004 preflight."
  )
  review <- mfrmr_cq_p2c4p_review()
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_p2c4p_assert(
    identical(basename(output_dir), mfrmr_cq_p2c4p_output_basename),
    "The preflight output directory basename is not the frozen candidate path."
  )
  mfrmr_cq_p2c4p_assert(
    !file.exists(output_dir) && !dir.exists(output_dir),
    "The frozen preflight output directory must not already exist."
  )
  namespace <- mfrmr_cq_p2c3p_namespace(source_root)
  mfrmr_cq_p2c4p_assert(
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE),
    "The preflight output directory could not be created."
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  fixture <- mfrmr_cq_p2c4p_fixture()
  plan <- review$plan
  utils::write.csv(
    plan, file.path(output_dir, "preflight_plan.csv"), row.names = FALSE, na = ""
  )
  utils::write.csv(
    fixture$long, file.path(output_dir, "fixture_long.csv"),
    row.names = FALSE, na = ""
  )
  results <- list()
  fits <- list()
  run_indices <- function(indices) {
    for (index in indices) {
      arm <- plan[index, , drop = FALSE]
      result <- mfrmr_cq_p2c4p_fit_one(arm, namespace, fixture, output_dir)
      results[[arm$RunId]] <<- result
      fits[[arm$RunId]] <<- result$fit
    }
  }
  initial <- which(plan$ExecutionPhase == "initial")
  run_indices(initial)
  combine_summary <- function() do.call(
    rbind, lapply(results, `[[`, "summary")
  )
  combine_coordinates <- function() {
    value <- do.call(rbind, lapply(results, `[[`, "coordinates"))
    if (is.null(value)) mfrmr_cq_p2c4p_empty_coordinates() else value
  }
  fit_summary <- combine_summary()
  coordinates <- combine_coordinates()
  dense_1 <- mfrmr_cq_p2c4p_pair_metrics(
    61L, 121L, fit_summary, coordinates, fits, plan, fixture
  )
  selection <- mfrmr_cq_p2c4p_select_stage(dense_1)
  metrics <- dense_1
  q241_attempted <- FALSE
  if (!identical(selection$selected_stage, "dense_pair_1")) {
    q241_attempted <- TRUE
    run_indices(which(plan$ExecutionPhase == "conditional_dense_pair_2"))
    fit_summary <- combine_summary()
    coordinates <- combine_coordinates()
    dense_2 <- mfrmr_cq_p2c4p_pair_metrics(
      121L, 241L, fit_summary, coordinates, fits, plan, fixture
    )
    metrics <- rbind(dense_1, dense_2)
    selection <- mfrmr_cq_p2c4p_select_stage(metrics)
  }
  diagnostic <- mfrmr_cq_p2c4p_diagnostic(
    fit_summary, coordinates, plan
  )
  passed <- identical(
    selection$status, "lowest_complete_passing_dense_pair_selected"
  ) && selection$selected_stage %in% c("dense_pair_1", "dense_pair_2")
  run_summary <- data.frame(
    Specification = mfrmr_cq_p2c4p_specification,
    ContractVersion = mfrmr_cq_p2c4p_contract,
    CandidateId = mfrmr_cq_p2c4p_candidate_id,
    Status = if (passed) {
      "candidate_004_mfrmr_preflight_passed_external_review_required"
    } else {
      "candidate_004_mfrmr_preflight_failed_external_execution_blocked"
    },
    SourceRoot = normalizePath(source_root, winslash = "/", mustWork = TRUE),
    PackageVersion = as.character(utils::packageVersion("mfrmr")),
    AttemptedFits = nrow(fit_summary),
    FitCap = review$total_fit_cap,
    Q241Attempted = q241_attempted,
    SelectedStage = selection$selected_stage,
    SelectedLowerNodes = selection$selected_lower_nodes,
    SelectedUpperNodes = selection$selected_upper_nodes,
    EligibleForNewExternalAuthorizationReview = passed,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    TruthRecoveryAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  utils::write.csv(
    fit_summary, file.path(output_dir, "fit_summary.csv"),
    row.names = FALSE, na = ""
  )
  utils::write.csv(
    coordinates, file.path(output_dir, "coordinates.csv"),
    row.names = FALSE, na = ""
  )
  utils::write.csv(
    diagnostic, file.path(output_dir, "q31_q61_diagnostic.csv"),
    row.names = FALSE, na = ""
  )
  utils::write.csv(
    metrics, file.path(output_dir, "dense_stage_metrics.csv"),
    row.names = FALSE, na = ""
  )
  utils::write.csv(
    selection$stage_review, file.path(output_dir, "stage_selection.csv"),
    row.names = FALSE, na = ""
  )
  utils::write.csv(
    run_summary, file.path(output_dir, "run_summary.csv"),
    row.names = FALSE, na = ""
  )
  list(
    status = run_summary$Status,
    output_dir = output_dir,
    fit_summary = fit_summary,
    coordinates = coordinates,
    diagnostic = diagnostic,
    dense_stage_metrics = metrics,
    stage_selection = selection,
    run_summary = run_summary,
    eligible_for_new_external_authorization_review = passed,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    truth_recovery_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
