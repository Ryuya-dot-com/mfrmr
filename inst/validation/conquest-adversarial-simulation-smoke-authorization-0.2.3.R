# Prospective authorization contract for ConQuest ASP-G3 smoke generation.
#
# This contract freezes one mechanics-only seed per scenario-family arm, the
# complete future output schema, and a full-Person continuous-oracle
# qualification. It creates no randomness or sampled response data, fits
# nothing, and launches neither engine. Successful review authorizes only the
# later generation of the eighteen frozen smoke datasets.

mfrmr_cq_asg_specification <-
  "0.2.3-conquest-adversarial-simulation-smoke-authorization-v1"
mfrmr_cq_asg_contract <-
  "mfrmr_conquest_adversarial_simulation_smoke_authorization_v1"
mfrmr_cq_asg_smoke_namespace_start <- 987000L
mfrmr_cq_asg_smoke_namespace_end <- 987099L
mfrmr_cq_asg_smoke_seed_start <- 987001L
mfrmr_cq_asg_maximum_deviance_error_envelope <- 1e-8
mfrmr_cq_asg_integrand_probe_tolerance <- 1e-12
mfrmr_cq_asg_coefficient_tolerance <- 1e-14

mfrmr_cq_asg_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_asg_require_contracts <- function() {
  target <- environment(mfrmr_cq_asg_require_contracts)
  ready <- exists(
    "mfrmr_cq_ado_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ado_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_dgp_oracle_contract_v1"
  ) && exists(
    "mfrmr_cq_ado_review", envir = target, mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_ast_templates", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_p2_matrix_contract", envir = target,
    mode = "function", inherits = TRUE
  )
  mfrmr_cq_asg_assert(
    ready,
    "Source the ASP program, template, P2 matrix, and G2 DGP contracts first."
  )
  invisible(TRUE)
}

mfrmr_cq_asg_seed_registry <- function() {
  mfrmr_cq_asg_require_contracts()
  template <- mfrmr_cq_ast_template_registry()
  out <- template[, c(
    "ArmId", "ScenarioClassId", "Family", "ExpectedDisposition"
  ), drop = FALSE]
  out$Phase <- "non_evaluative_schema_smoke"
  out$Replicate <- 1L
  out$Seed <- seq.int(
    mfrmr_cq_asg_smoke_seed_start,
    length.out = nrow(out)
  )
  out$DatasetId <- sprintf("CQASP-SMOKE-%02d", seq_len(nrow(out)))
  out$EvaluationUse <- "mechanics_only_not_operating_characteristics"
  out$MayTuneDGP <- FALSE
  out$MayTuneMetricThreshold <- FALSE
  out$MayEstimateFailureRate <- FALSE
  out$MayEnterCalibration <- FALSE
  out$MayEnterConfirmation <- FALSE
  out$MaySupportPublicClaim <- FALSE
  out$ResultOpened <- FALSE
  out$Generated <- FALSE
  out$RetainIfGenerated <- TRUE
  out$Candidate004DataReused <- FALSE
  out$Candidate004OutputInformed <- FALSE
  out
}

mfrmr_cq_asg_phase_separation_contract <- function() {
  data.frame(
    Phase = c("smoke", "calibration", "confirmation"),
    SeedState = c("frozen", "not_frozen", "not_frozen"),
    NamespaceStart = c(
      mfrmr_cq_asg_smoke_namespace_start, NA_integer_, NA_integer_
    ),
    NamespaceEnd = c(
      mfrmr_cq_asg_smoke_namespace_end, NA_integer_, NA_integer_
    ),
    ExactSeedsAssigned = c(18L, 0L, 0L),
    ResultState = c("sealed_not_generated", "unavailable", "unavailable"),
    MustExcludeFrozenSmokeNamespace = c(FALSE, TRUE, TRUE),
    ReuseAcrossPhasesPermitted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asg_output_schema_registry <- function() {
  data.frame(
    TableId = c(
      "dataset_manifest",
      "response_data",
      "structural_disposition",
      "engine_outcome",
      "metric_outcome",
      "continuous_oracle"
    ),
    RowUnit = c(
      "one_generated_dataset",
      "one_declared_response_opportunity",
      "one_generated_dataset",
      "one_dataset_by_engine",
      "one_dataset_by_metric_engine_coordinate",
      "one_dataset_by_engine_quadrature_rule"
    ),
    PrimaryKey = c(
      "DatasetId",
      "DatasetId;RepresentationId;Person;Rater;Criterion",
      "DatasetId",
      "DatasetId;Engine",
      "DatasetId;MetricId;Engine;Coordinate",
      "DatasetId;Engine;QuadratureId"
    ),
    RequiredColumns = c(
      paste(c(
        "ProgramSpecification", "SmokeContract", "Phase", "DatasetId",
        "ArmId", "ScenarioClassId", "Family", "Replicate", "Seed",
        "ProfileId", "ExpectedStructuralDisposition", "GenerationStatus",
        "ObservedRows", "Persons", "Category0", "Category1", "Category2",
        "Category3", "RecoveryEligible", "EvaluationUse",
        "RetainedInUnconditionalDenominator"
      ), collapse = ";"),
      paste(c(
        "DatasetId", "RepresentationId", "Person", "PersonIndex", "X",
        "Rater", "RaterIndex", "Criterion", "CriterionIndex", "Response",
        "ResponseObserved", "ProfileId", "RecoveryEligible"
      ), collapse = ";"),
      paste(c(
        "DatasetId", "ExpectedDisposition", "ObservedDisposition",
        "DispositionReason", "PredictorDimension", "PredictorRank",
        "SupportBoundaryStatus", "NumericalComparisonPermitted"
      ), collapse = ";"),
      paste(c(
        "DatasetId", "Engine", "AttemptRequired", "Attempted",
        "ReturnStatus", "FailureClass", "NativeVersion", "Platform",
        "ElapsedSeconds", "EligibleForNumericComparison",
        "RetainedInUnconditionalDenominator"
      ), collapse = ";"),
      paste(c(
        "DatasetId", "MetricId", "Engine", "Coordinate", "Estimate",
        "Truth", "Error", "Eligibility", "IneligibilityReason",
        "PrimaryDenominator", "UnconditionalCompanionCount"
      ), collapse = ";"),
      paste(c(
        "DatasetId", "Engine", "QuadratureId", "Deviance",
        "OracleDeviance", "AbsoluteError", "NumericalErrorEstimate",
        "OmittedTailAnalyticBound", "Eligibility", "IneligibilityReason"
      ), collapse = ";")
    ),
    FailureOrIneligibleRowsRequired = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
    ConditionalRowsRequireUnconditionalCompanion = c(
      FALSE, FALSE, FALSE, FALSE, TRUE, TRUE
    ),
    WriteAuthorizedByThisContract = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asg_metric_schema_map <- function() {
  metric <- mfrmr_cq_asp_metric_registry()
  out <- metric[, c(
    "MetricId", "PrimaryDenominator", "MandatoryUnconditionalCompanion",
    "AnalysisState"
  ), drop = FALSE]
  out$TableId <- c(
    "structural_disposition",
    "engine_outcome", "engine_outcome", "engine_outcome",
    "metric_outcome", "continuous_oracle", "metric_outcome",
    "metric_outcome", "metric_outcome", "continuous_oracle",
    "metric_outcome", "metric_outcome"
  )
  out$ActiveAtSmoke <- out$MetricId %in% c(
    "ASP-STRUCTURAL-DISPOSITION", "ASP-CONQUEST-EXECUTION",
    "ASP-MFRMR-EXECUTION", "ASP-JOINT-NUMERIC-ELIGIBILITY"
  )
  out$MayBeEstimatedFromSmoke <- FALSE
  out$SchemaReservedForLater <- !out$ActiveAtSmoke
  out
}

mfrmr_cq_asg_non_evaluative_policy <- function() {
  data.frame(
    Action = c(
      "validate_generation_and_replay_mechanics",
      "validate_required_output_columns_and_primary_keys",
      "validate_structural_prefit_disposition",
      "estimate_bias_RMSE_or_failure_rates",
      "select_or_tune_DGP_values",
      "select_or_tune_metric_thresholds",
      "compare_or_rank_engines_scientifically",
      "reuse_rows_in_calibration_or_confirmation",
      "support_a_public_equivalence_claim"
    ),
    PermittedForSmoke = c(rep(TRUE, 3L), rep(FALSE, 6L)),
    AuthorizedByThisContract = c(FALSE, FALSE, FALSE, rep(FALSE, 6L)),
    ResultCanChangeFrozenDesign = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asg_location_coefficients <- function(
    truth, method = c("direct", "matrix")) {
  method <- match.arg(method)
  category <- 0:3
  location <- expand.grid(
    Category = category,
    Rater = names(truth$Rater),
    Criterion = names(truth$Criterion),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  if (method == "direct") {
    step <- if (truth$Family == "RSM") {
      lapply(location$Criterion, function(value) truth$Steps)
    } else {
      lapply(location$Criterion, function(value) truth$Steps[value, ])
    }
    cumulative <- vapply(seq_len(nrow(location)), function(index) {
      c(0, cumsum(step[[index]]))[location$Category[index] + 1L]
    }, numeric(1L))
    location$ThetaCoefficient <- location$Category
    location$Intercept <-
      -location$Category * (
        truth$Rater[location$Rater] + truth$Criterion[location$Criterion]
      ) - cumulative
  } else {
    contract <- mfrmr_cq_p2_matrix_contract(truth$Family)
    parameter <- mfrmr_cq_ado_matrix_parameter(truth)
    key <- paste(
      contract$C$Category, contract$C$Rater, contract$C$Criterion,
      sep = "::"
    )
    index <- match(
      paste(location$Category, location$Rater, location$Criterion, sep = "::"),
      key
    )
    mfrmr_cq_asg_assert(
      !anyNA(index), "The matrix coefficient lookup is incomplete."
    )
    location$ThetaCoefficient <- contract$C$ThetaScore[index]
    location$Intercept <- as.numeric(
      contract$A[index, , drop = FALSE] %*% parameter
    )
  }
  location
}

mfrmr_cq_asg_coefficient_audit <- function() {
  mfrmr_cq_asg_require_contracts()
  cases <- expand.grid(
    ProfileId = mfrmr_cq_ado_profile_registry()$ProfileId,
    Family = c("RSM", "PCM"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  rows <- lapply(seq_len(nrow(cases)), function(index) {
    truth <- mfrmr_cq_ado_truth(
      cases$ProfileId[index], cases$Family[index]
    )
    direct <- mfrmr_cq_asg_location_coefficients(truth, "direct")
    matrix <- mfrmr_cq_asg_location_coefficients(truth, "matrix")
    data.frame(
      ProfileId = truth$ProfileId,
      Family = truth$Family,
      LocationCategoryCoefficients = nrow(direct),
      MaximumThetaCoefficientDifference = max(abs(
        direct$ThetaCoefficient - matrix$ThetaCoefficient
      )),
      MaximumInterceptDifference = max(abs(
        direct$Intercept - matrix$Intercept
      )),
      EqualityHoldsForEveryFiniteTheta = TRUE,
      CandidateOutputRead = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_asg_compile_person <- function(person_data, truth) {
  lookup <- mfrmr_cq_asg_location_coefficients(truth, "direct")
  row_key <- paste(person_data$Rater, person_data$Criterion, sep = "::")
  lookup_key <- paste(lookup$Rater, lookup$Criterion, sep = "::")
  index <- lapply(row_key, function(key) which(lookup_key == key))
  valid <- vapply(index, length, integer(1L)) == 4L
  response <- as.integer(person_data$Response)
  x <- unique(person_data$X)
  mfrmr_cq_asg_assert(
    all(valid) && length(x) == 1L && is.finite(x) &&
      length(response) == nrow(person_data) &&
      all(response %in% 0:3),
    "The full-Person continuous fixture is invalid."
  )
  intercept <- t(vapply(index, function(value) {
    rows <- lookup[value, , drop = FALSE]
    rows <- rows[order(rows$Category), , drop = FALSE]
    rows$Intercept
  }, numeric(4L)))
  theta_coefficient <- t(vapply(index, function(value) {
    rows <- lookup[value, , drop = FALSE]
    rows <- rows[order(rows$Category), , drop = FALSE]
    rows$ThetaCoefficient
  }, numeric(4L)))
  list(
    Person = as.character(person_data$Person[1L]),
    X = as.numeric(x),
    Responses = nrow(person_data),
    Response = response,
    Intercept = intercept,
    ThetaCoefficient = theta_coefficient
  )
}

mfrmr_cq_asg_compiled_log_integrand <- function(z, compiled, truth) {
  vapply(z, function(value) {
    theta <- truth$PopulationIntercept + truth$PopulationSlope * compiled$X +
      sqrt(truth$PopulationVariance) * value
    kernel <- compiled$Intercept + compiled$ThetaCoefficient * theta
    center <- apply(kernel, 1L, max)
    log_normalizer <- center + log(rowSums(exp(kernel - center)))
    selected <- kernel[cbind(
      seq_len(compiled$Responses), compiled$Response + 1L
    )]
    sum(selected - log_normalizer) + stats::dnorm(value, log = TRUE)
  }, numeric(1L))
}

mfrmr_cq_asg_integrand_probe_audit <- function() {
  templates <- mfrmr_cq_ast_templates()
  selected <- templates[vapply(templates, function(value) {
    value$ScenarioClassId %in% c(
      "ASP-POS-COMPLETE", "ASP-SENS-RARE-BOUNDARY-CATEGORY"
    )
  }, logical(1L))]
  probe <- c(-4, -1, 0, 1, 4)
  difference <- numeric()
  persons <- 0L
  for (template in selected) {
    mapping <- mfrmr_cq_ado_scenario_map()
    profile <- mapping$ProfileId[
      mapping$ScenarioClassId == template$ScenarioClassId
    ]
    truth <- mfrmr_cq_ado_truth(profile, template$Family)
    by_person <- split(template$Data, template$Data$Person)
    for (person_data in by_person) {
      compiled <- mfrmr_cq_asg_compile_person(person_data, truth)
      current <- mfrmr_cq_asg_compiled_log_integrand(
        probe, compiled, truth
      )
      original <- mfrmr_cq_ado_person_log_integrand(
        probe, person_data, truth, "direct"
      )
      difference <- c(difference, abs(current - original))
      persons <- persons + 1L
    }
  }
  data.frame(
    Arms = length(selected),
    Persons = persons,
    ProbePointsPerPerson = length(probe),
    IntegrandEvaluations = length(difference),
    MaximumAbsoluteDifference = max(difference),
    PrototypeFixtureOnly = TRUE,
    SampledResponseDataUsed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asg_person_integral <- function(compiled, truth) {
  lower <- -mfrmr_cq_ado_tail_limit
  upper <- mfrmr_cq_ado_tail_limit
  objective <- function(z) {
    mfrmr_cq_asg_compiled_log_integrand(z, compiled, truth)
  }
  mode <- stats::optimize(
    objective, interval = c(lower, upper), maximum = TRUE, tol = 1e-10
  )
  location <- as.numeric(mode$maximum)
  log_height <- as.numeric(mode$objective)
  scaled <- function(z) exp(objective(z) - log_height)
  left <- stats::integrate(
    scaled, lower = lower, upper = location,
    rel.tol = mfrmr_cq_ado_relative_tolerance,
    abs.tol = mfrmr_cq_ado_absolute_tolerance,
    subdivisions = mfrmr_cq_ado_subdivisions,
    stop.on.error = TRUE
  )
  right <- stats::integrate(
    scaled, lower = location, upper = upper,
    rel.tol = mfrmr_cq_ado_relative_tolerance,
    abs.tol = mfrmr_cq_ado_absolute_tolerance,
    subdivisions = mfrmr_cq_ado_subdivisions,
    stop.on.error = TRUE
  )
  scaled_value <- left$value + right$value
  numerical_relative_error <- (left$abs.error + right$abs.error) /
    scaled_value
  numerical_log_error <- if (
      is.finite(numerical_relative_error) &&
        numerical_relative_error >= 0 && numerical_relative_error < 1
  ) -log1p(-numerical_relative_error) else Inf
  log_integral <- log_height + log(scaled_value)
  log_tail_mass <- log(2) + stats::pnorm(
    -mfrmr_cq_ado_tail_limit, log.p = TRUE
  )
  tail_log_bound <- log1p(exp(log_tail_mass - log_integral))
  data.frame(
    Person = compiled$Person,
    Responses = compiled$Responses,
    ModeLocation = location,
    ModeInterior = location > lower + 1e-6 && location < upper - 1e-6,
    LogLikelihood = log_integral,
    NumericalLogErrorEstimate = numerical_log_error,
    OmittedNormalTailLogBound = tail_log_bound,
    TotalLogErrorEnvelope = numerical_log_error + tail_log_bound,
    LeftMessage = as.character(left$message),
    RightMessage = as.character(right$message),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_asg_full_person_continuous_audit <- function() {
  templates <- mfrmr_cq_ast_templates()
  selected <- templates[vapply(templates, function(value) {
    value$ScenarioClassId %in% c(
      "ASP-POS-COMPLETE", "ASP-SENS-RARE-BOUNDARY-CATEGORY"
    )
  }, logical(1L))]
  rows <- lapply(selected, function(template) {
    mapping <- mfrmr_cq_ado_scenario_map()
    profile <- mapping$ProfileId[
      mapping$ScenarioClassId == template$ScenarioClassId
    ]
    truth <- mfrmr_cq_ado_truth(profile, template$Family)
    by_person <- split(template$Data, template$Data$Person)
    detail <- do.call(rbind, lapply(by_person, function(person_data) {
      compiled <- mfrmr_cq_asg_compile_person(person_data, truth)
      mfrmr_cq_asg_person_integral(compiled, truth)
    }))
    rownames(detail) <- NULL
    converged <- all(detail$LeftMessage == "OK") &&
      all(detail$RightMessage == "OK")
    finite <- all(is.finite(unlist(detail[, c(
      "ModeLocation", "LogLikelihood", "NumericalLogErrorEstimate",
      "OmittedNormalTailLogBound", "TotalLogErrorEnvelope"
    )])))
    mfrmr_cq_asg_assert(
      finite && converged && all(detail$ModeInterior),
      "The full-Person continuous qualification failed."
    )
    data.frame(
      ArmId = template$ArmId,
      ScenarioClassId = template$ScenarioClassId,
      Family = template$Family,
      ProfileId = profile,
      Persons = nrow(detail),
      ObservedRows = sum(detail$Responses),
      LogLikelihood = sum(detail$LogLikelihood),
      Deviance = -2 * sum(detail$LogLikelihood),
      DeclaredDevianceErrorEnvelope =
        2 * sum(detail$TotalLogErrorEnvelope),
      ModesInterior = all(detail$ModeInterior),
      IntegrationsConverged = converged,
      QuadratureErrorIsNumericalEstimate = TRUE,
      OmittedNormalTailErrorIsAnalyticBound = TRUE,
      PrototypeFixtureOnly = TRUE,
      SampledResponseDataUsed = FALSE,
      FitAttempted = FALSE,
      ExternalExecutionAttempted = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_asg_review <- function(run_full_continuous_oracle = FALSE) {
  mfrmr_cq_asg_require_contracts()
  g2 <- mfrmr_cq_ado_review(run_continuous_oracles = FALSE)
  seeds <- mfrmr_cq_asg_seed_registry()
  phases <- mfrmr_cq_asg_phase_separation_contract()
  schema <- mfrmr_cq_asg_output_schema_registry()
  metric_map <- mfrmr_cq_asg_metric_schema_map()
  policy <- mfrmr_cq_asg_non_evaluative_policy()
  coefficient <- mfrmr_cq_asg_coefficient_audit()
  integrand <- mfrmr_cq_asg_integrand_probe_audit()
  continuous <- if (isTRUE(run_full_continuous_oracle)) {
    mfrmr_cq_asg_full_person_continuous_audit()
  } else {
    data.frame()
  }
  core_ready <-
    isTRUE(g2$exact_DGP_values_frozen) &&
    g2$status == "ASP_G2_core_frozen_continuous_audit_unopened" &&
    nrow(seeds) == 18L && !anyDuplicated(seeds$ArmId) &&
    !anyDuplicated(seeds$Seed) && !anyDuplicated(seeds$DatasetId) &&
    min(seeds$Seed) >= mfrmr_cq_asg_smoke_namespace_start &&
    max(seeds$Seed) <= mfrmr_cq_asg_smoke_namespace_end &&
    !any(seeds$ResultOpened) && !any(seeds$Generated) &&
    all(seeds$RetainIfGenerated) &&
    !any(seeds$Candidate004DataReused) &&
    !any(seeds$Candidate004OutputInformed) &&
    nrow(phases) == 3L && sum(phases$SeedState == "frozen") == 1L &&
    !any(phases$ReuseAcrossPhasesPermitted) &&
    nrow(schema) == 6L && !anyDuplicated(schema$TableId) &&
    all(schema$FailureOrIneligibleRowsRequired) &&
    !any(schema$WriteAuthorizedByThisContract) &&
    nrow(metric_map) == 12L && !anyDuplicated(metric_map$MetricId) &&
    setequal(metric_map$TableId, schema$TableId[c(3L, 4L, 5L, 6L)]) &&
    !any(metric_map$MayBeEstimatedFromSmoke) &&
    sum(policy$PermittedForSmoke) == 3L &&
    !any(policy$AuthorizedByThisContract) &&
    nrow(coefficient) == 8L &&
    sum(coefficient$LocationCategoryCoefficients) == 384L &&
    max(coefficient$MaximumThetaCoefficientDifference) <=
      mfrmr_cq_asg_coefficient_tolerance &&
    max(coefficient$MaximumInterceptDifference) <=
      mfrmr_cq_asg_coefficient_tolerance &&
    all(coefficient$EqualityHoldsForEveryFiniteTheta) &&
    integrand$Arms == 4L && integrand$Persons == 192L &&
    integrand$IntegrandEvaluations == 960L &&
    integrand$MaximumAbsoluteDifference <=
      mfrmr_cq_asg_integrand_probe_tolerance &&
    !isTRUE(integrand$SampledResponseDataUsed)
  continuous_ready <- isTRUE(run_full_continuous_oracle) &&
    nrow(continuous) == 4L && sum(continuous$Persons) == 192L &&
    all(continuous$Persons == 48L) &&
    identical(sort(continuous$ObservedRows), c(288L, 288L, 576L, 576L)) &&
    all(continuous$ModesInterior) &&
    all(continuous$IntegrationsConverged) &&
    all(continuous$DeclaredDevianceErrorEnvelope <=
      mfrmr_cq_asg_maximum_deviance_error_envelope) &&
    all(continuous$PrototypeFixtureOnly) &&
    !any(continuous$SampledResponseDataUsed) &&
    !any(continuous$FitAttempted) &&
    !any(continuous$ExternalExecutionAttempted)
  authorized <- core_ready && continuous_ready
  list(
    specification = mfrmr_cq_asg_specification,
    contract_version = mfrmr_cq_asg_contract,
    status = if (authorized) {
      "ASP_G3_smoke_contract_frozen_generation_authorized_not_run"
    } else if (core_ready && !isTRUE(run_full_continuous_oracle)) {
      "ASP_G3_core_frozen_full_person_oracle_unopened"
    } else {
      "ASP_G3_smoke_authorization_failed"
    },
    seed_registry = seeds,
    phase_separation = phases,
    output_schema = schema,
    metric_schema_map = metric_map,
    non_evaluative_policy = policy,
    coefficient_audit = coefficient,
    integrand_probe_audit = integrand,
    full_person_continuous_audit = continuous,
    G2_exact_DGP_prerequisite_frozen = isTRUE(g2$exact_DGP_values_frozen),
    G3_authorization_complete = authorized,
    G3_smoke_execution_complete = FALSE,
    G3_complete = FALSE,
    smoke_seed_band_frozen = core_ready,
    output_schema_frozen = core_ready,
    full_person_continuous_oracle_qualified = continuous_ready,
    algebraic_coefficient_identity_qualified = core_ready,
    smoke_results_opened = FALSE,
    smoke_operating_characteristics_permitted = FALSE,
    authorized_smoke_datasets = if (authorized) 18L else 0L,
    maximum_datasets_per_arm = if (authorized) 1L else 0L,
    smoke_dataset_generation_authorized = authorized,
    any_sampled_response_generated = FALSE,
    any_fit_authorized = FALSE,
    ConQuest_execution_authorized = FALSE,
    calibration_seed_band_frozen = FALSE,
    confirmation_seed_band_frozen = FALSE,
    metric_precision_and_replication_counts_frozen = FALSE,
    sequential_and_resource_rules_frozen = FALSE,
    remaining_generation_blockers = c(
      "calibration_seed_band",
      "confirmation_seed_band",
      "metric_specific_precision_targets_and_replication_counts",
      "sequential_stop_expand_abort_and_runtime_cap"
    ),
    next_action = "ASP-G3-NONEVALUATIVE-SMOKE-GENERATION",
    public_text_change_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
