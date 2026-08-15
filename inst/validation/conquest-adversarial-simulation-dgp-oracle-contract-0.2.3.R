# Exact DGP and code-path-separated mathematical oracles for ConQuest ASP-G2.
#
# Randomness is an external input: the latent and response primitives consume
# open-interval uniforms but never create them. The direct response generator,
# reconstructed-A probability oracle, and log-centered continuous oracle call
# neither a package fit path nor ConQuest. No simulation dataset is generated or
# authorized by this contract.

mfrmr_cq_ado_specification <-
  "0.2.3-conquest-adversarial-simulation-dgp-oracle-contract-v1"
mfrmr_cq_ado_contract <-
  "mfrmr_conquest_adversarial_simulation_dgp_oracle_contract_v1"
mfrmr_cq_ado_tail_limit <- 12
mfrmr_cq_ado_relative_tolerance <- 1e-11
mfrmr_cq_ado_absolute_tolerance <- 1e-13
mfrmr_cq_ado_subdivisions <- 750L
mfrmr_cq_ado_maximum_sentinel_deviance_error_envelope <- 1e-8

mfrmr_cq_ado_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ado_require_contracts <- function() {
  target <- environment(mfrmr_cq_ado_require_contracts)
  ready <- exists(
    "mfrmr_cq_asp_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_asp_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_program_v1"
  ) && exists(
    "mfrmr_cq_ast_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ast_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_template_contract_v1"
  ) && exists(
    "mfrmr_cq_ast_review", envir = target, mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_p2_matrix_contract", envir = target,
    mode = "function", inherits = TRUE
  )
  mfrmr_cq_ado_assert(
    ready,
    paste(
      "Source the exact ASP program, deterministic-template, and P2 matrix",
      "contracts before the DGP-oracle contract."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_ado_profile_registry <- function() {
  data.frame(
    ProfileId = c(
      "ASP-DGP-CENTRAL-MODEL",
      "ASP-DGP-RARE-BOUNDARY",
      "ASP-DGP-EXTREME-LATENT-STRESS",
      "ASP-DGP-UNUSED-CATEGORY-CONTAMINATION"
    ),
    PopulationIntercept = 0.10,
    PopulationSlope = 0.45,
    PopulationVariance = 0.70,
    RaterCoordinates = "R1=-0.45;R2=-0.15;R3=0.20;R4=0.40",
    CriterionCoordinates = "C1=-0.30;C2=0.05;C3=0.25",
    StepProfile = c("central", "rare_boundary", "central", "central"),
    LatentRule = c(
      "inverse_normal_from_supplied_open_uniform",
      "inverse_normal_from_supplied_open_uniform",
      "inverse_normal_with_fixed_1e-5_and_1_minus_1e-5_tail_anchors",
      "inverse_normal_from_supplied_open_uniform"
    ),
    ResponseRule = c(
      "inverse_CDF_from_supplied_open_uniform",
      "inverse_CDF_from_supplied_open_uniform",
      "inverse_CDF_from_supplied_open_uniform",
      "inverse_CDF_then_recode_1_to_2_control_only"
    ),
    ModelConformingIIDForRecovery = c(TRUE, TRUE, FALSE, FALSE),
    RecoveryEligible = c(TRUE, TRUE, FALSE, FALSE),
    CandidateOutputInformed = FALSE,
    Frozen = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ado_scenario_map <- function() {
  data.frame(
    ScenarioClassId = c(
      "ASP-POS-COMPLETE",
      "ASP-POS-SPARSE-MULTIBRIDGE",
      "ASP-SENS-WEAK-SINGLE-BRIDGE",
      "ASP-SENS-UNEQUAL-WORKLOAD",
      "ASP-INV-PAIRED-MISSINGNESS",
      "ASP-SENS-RARE-BOUNDARY-CATEGORY",
      "ASP-SENS-EXTREME-PERSON",
      "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY",
      "ASP-NEG-DISCONNECTED-DESIGN"
    ),
    ProfileId = c(
      rep("ASP-DGP-CENTRAL-MODEL", 5L),
      "ASP-DGP-RARE-BOUNDARY",
      "ASP-DGP-EXTREME-LATENT-STRESS",
      "ASP-DGP-UNUSED-CATEGORY-CONTAMINATION",
      "ASP-DGP-CENTRAL-MODEL"
    ),
    ResponsePostprocessing = c(
      rep("none", 7L), "recode_category_1_to_2", "none"
    ),
    RecoveryEligible = c(rep(TRUE, 6L), rep(FALSE, 3L)),
    FitExpected = c(rep(TRUE, 7L), FALSE, FALSE),
    RequiredPrimaryOutcome = c(
      "truth_oracle_and_cross_engine_numeric_layers",
      "truth_oracle_and_cross_engine_numeric_layers",
      "weak_information_sensitivity_with_full_denominator",
      "workload_sensitivity_with_full_denominator",
      "representation_invariance_on_identical_retained_responses",
      "rare_category_truth_and_failure_rates",
      "typed_extreme_person_and_fit_stability_only",
      "support_boundary_rejection_before_fit",
      "rank_deficiency_rejection_before_fit"
    ),
    DataGenerationAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ado_truth <- function(profile_id, family) {
  mfrmr_cq_ado_require_contracts()
  profile_id <- as.character(profile_id)[1L]
  family <- toupper(as.character(family)[1L])
  profiles <- mfrmr_cq_ado_profile_registry()
  profile <- profiles[profiles$ProfileId == profile_id, , drop = FALSE]
  mfrmr_cq_ado_assert(
    nrow(profile) == 1L && family %in% c("RSM", "PCM"),
    "The DGP truth requires one registered profile and RSM or PCM."
  )
  rater <- c(R1 = -0.45, R2 = -0.15, R3 = 0.20, R4 = 0.40)
  criterion <- c(C1 = -0.30, C2 = 0.05, C3 = 0.25)
  central_rsm <- c(S1 = -0.90, S2 = 0.10, S3 = 0.80)
  central_pcm <- rbind(
    C1 = c(S1 = -1.00, S2 = 0.20, S3 = 0.80),
    C2 = c(S1 = -0.80, S2 = -0.10, S3 = 0.90),
    C3 = c(S1 = -1.20, S2 = 0.40, S3 = 0.80)
  )
  rare_rsm <- c(S1 = -1.60, S2 = 0, S3 = 1.60)
  rare_pcm <- rbind(
    C1 = c(S1 = -1.70, S2 = 0.10, S3 = 1.60),
    C2 = c(S1 = -1.50, S2 = -0.10, S3 = 1.60),
    C3 = c(S1 = -1.80, S2 = 0.20, S3 = 1.60)
  )
  rare <- profile$StepProfile == "rare_boundary"
  list(
    ProfileId = profile_id,
    Family = family,
    PopulationIntercept = as.numeric(profile$PopulationIntercept),
    PopulationSlope = as.numeric(profile$PopulationSlope),
    PopulationVariance = as.numeric(profile$PopulationVariance),
    Rater = rater,
    Criterion = criterion,
    Steps = if (family == "RSM") {
      if (rare) rare_rsm else central_rsm
    } else {
      if (rare) rare_pcm else central_pcm
    },
    LowerTailAnchorProbability = if (
      profile_id == "ASP-DGP-EXTREME-LATENT-STRESS"
    ) 1e-5 else NA_real_,
    UpperTailAnchorProbability = if (
      profile_id == "ASP-DGP-EXTREME-LATENT-STRESS"
    ) 1 - 1e-5 else NA_real_,
    ResponsePostprocessing = as.character(profile$ResponseRule),
    ModelConformingIIDForRecovery =
      isTRUE(profile$ModelConformingIIDForRecovery),
    RecoveryEligible = isTRUE(profile$RecoveryEligible)
  )
}

mfrmr_cq_ado_truth_audit <- function() {
  profiles <- mfrmr_cq_ado_profile_registry()$ProfileId
  grid <- expand.grid(
    ProfileId = profiles, Family = c("RSM", "PCM"),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  rows <- lapply(seq_len(nrow(grid)), function(index) {
    truth <- mfrmr_cq_ado_truth(grid$ProfileId[index], grid$Family[index])
    step_sum <- if (truth$Family == "RSM") {
      sum(truth$Steps)
    } else {
      max(abs(rowSums(truth$Steps)))
    }
    data.frame(
      ProfileId = truth$ProfileId,
      Family = truth$Family,
      PopulationVariancePositive = truth$PopulationVariance > 0,
      RaterSum = sum(truth$Rater),
      CriterionSum = sum(truth$Criterion),
      StepConstraintMaximum = abs(step_sum),
      Finite = all(is.finite(c(
        truth$PopulationIntercept, truth$PopulationSlope,
        truth$PopulationVariance, truth$Rater, truth$Criterion, truth$Steps
      ))),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_ado_softmax <- function(log_kernel) {
  value <- as.numeric(log_kernel)
  value <- value - max(value)
  probability <- exp(value)
  probability / sum(probability)
}

mfrmr_cq_ado_direct_probability <- function(
    truth, theta, rater, criterion) {
  theta <- as.numeric(theta)[1L]
  rater <- as.character(rater)[1L]
  criterion <- as.character(criterion)[1L]
  mfrmr_cq_ado_assert(
    is.list(truth) && truth$Family %in% c("RSM", "PCM") &&
      is.finite(theta) && rater %in% names(truth$Rater) &&
      criterion %in% names(truth$Criterion),
    "The direct generator probability received invalid coordinates."
  )
  step <- if (truth$Family == "RSM") {
    truth$Steps
  } else {
    truth$Steps[criterion, ]
  }
  eta <- theta - truth$Rater[rater] - truth$Criterion[criterion]
  category <- 0:3
  mfrmr_cq_ado_softmax(category * eta - c(0, cumsum(step)))
}

mfrmr_cq_ado_matrix_parameter <- function(truth) {
  contract <- mfrmr_cq_p2_matrix_contract(truth$Family)
  value <- c(
    truth$Rater[1:3], truth$Criterion[1:2],
    if (truth$Family == "RSM") {
      truth$Steps[1:2]
    } else {
      as.vector(t(truth$Steps[, 1:2, drop = FALSE]))
    }
  )
  names(value) <- colnames(contract$A)
  value
}

mfrmr_cq_ado_matrix_probability <- function(
    truth, theta, rater, criterion) {
  contract <- mfrmr_cq_p2_matrix_contract(truth$Family)
  parameter <- mfrmr_cq_ado_matrix_parameter(truth)
  selected <- contract$C$Rater == rater &
    contract$C$Criterion == criterion
  mfrmr_cq_ado_assert(
    sum(selected) == 4L && is.finite(theta),
    "The reconstructed-A probability oracle received invalid coordinates."
  )
  log_kernel <- contract$C$ThetaScore[selected] * theta +
    as.numeric(contract$A[selected, , drop = FALSE] %*% parameter)
  mfrmr_cq_ado_softmax(log_kernel)
}

mfrmr_cq_ado_probability_audit <- function() {
  profiles <- mfrmr_cq_ado_profile_registry()$ProfileId
  cases <- expand.grid(
    ProfileId = profiles,
    Family = c("RSM", "PCM"),
    Theta = c(-4, -2, -0.5, 0, 1, 3, 4),
    Rater = paste0("R", 1:4),
    Criterion = paste0("C", 1:3),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  difference <- vapply(seq_len(nrow(cases)), function(index) {
    truth <- mfrmr_cq_ado_truth(
      cases$ProfileId[index], cases$Family[index]
    )
    direct <- mfrmr_cq_ado_direct_probability(
      truth, cases$Theta[index], cases$Rater[index], cases$Criterion[index]
    )
    matrix <- mfrmr_cq_ado_matrix_probability(
      truth, cases$Theta[index], cases$Rater[index], cases$Criterion[index]
    )
    max(abs(direct - matrix))
  }, numeric(1L))
  data.frame(
    Cases = nrow(cases),
    MaximumAbsoluteDifference = max(difference),
    AllDirectProbabilitiesPositive = all(vapply(
      seq_len(nrow(cases)), function(index) {
        truth <- mfrmr_cq_ado_truth(
          cases$ProfileId[index], cases$Family[index]
        )
        all(mfrmr_cq_ado_direct_probability(
          truth, cases$Theta[index], cases$Rater[index],
          cases$Criterion[index]
        ) > 0)
      }, logical(1L)
    )),
    GeneratorCallsMatrixOracle = FALSE,
    CandidateOutputRead = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ado_validate_open_uniform <- function(value, expected_length, label) {
  value <- as.numeric(value)
  expected_length <- as.integer(expected_length)[1L]
  mfrmr_cq_ado_assert(
    length(value) == expected_length && all(is.finite(value)) &&
      all(value > 0 & value < 1),
    paste0("`", label, "` must contain exactly ", expected_length,
           " finite values strictly inside (0,1).")
  )
  value
}

mfrmr_cq_ado_latent_from_uniform <- function(template, uniforms) {
  mfrmr_cq_ado_require_contracts()
  mapping <- mfrmr_cq_ado_scenario_map()
  row <- mapping[
    mapping$ScenarioClassId == template$ScenarioClassId, , drop = FALSE
  ]
  mfrmr_cq_ado_assert(nrow(row) == 1L, "The template scenario is unregistered.")
  person <- unique(template$Data[, c(
    "Person", "PersonIndex", "X"
  ), drop = FALSE])
  person <- person[order(person$PersonIndex), , drop = FALSE]
  rownames(person) <- NULL
  uniforms <- mfrmr_cq_ado_validate_open_uniform(
    uniforms, nrow(person), "uniforms"
  )
  truth <- mfrmr_cq_ado_truth(row$ProfileId, template$Family)
  person$SuppliedUniform <- uniforms
  person$LatentValue <- truth$PopulationIntercept +
    truth$PopulationSlope * person$X +
    sqrt(truth$PopulationVariance) * stats::qnorm(uniforms)
  person$TailAnchorApplied <- FALSE
  if (row$ProfileId == "ASP-DGP-EXTREME-LATENT-STRESS") {
    lower <- which.min(person$PersonIndex)
    upper <- which.max(person$PersonIndex)
    person$LatentValue[lower] <- truth$PopulationIntercept +
      truth$PopulationSlope * person$X[lower] +
      sqrt(truth$PopulationVariance) * stats::qnorm(
        truth$LowerTailAnchorProbability
      )
    person$LatentValue[upper] <- truth$PopulationIntercept +
      truth$PopulationSlope * person$X[upper] +
      sqrt(truth$PopulationVariance) * stats::qnorm(
        truth$UpperTailAnchorProbability
      )
    person$TailAnchorApplied[c(lower, upper)] <- TRUE
  }
  person$ProfileId <- row$ProfileId
  person$ModelConformingIIDForRecovery <-
    truth$ModelConformingIIDForRecovery
  person$RecoveryEligible <- isTRUE(row$RecoveryEligible) &&
    truth$RecoveryEligible
  person
}

mfrmr_cq_ado_response_from_uniform <- function(probability, uniform) {
  probability <- as.numeric(probability)
  uniform <- mfrmr_cq_ado_validate_open_uniform(uniform, 1L, "uniform")
  mfrmr_cq_ado_assert(
    length(probability) == 4L && all(is.finite(probability)) &&
      all(probability > 0) && abs(sum(probability) - 1) < 1e-12,
    "`probability` must be four positive finite values summing to one."
  )
  as.integer(sum(uniform > cumsum(probability)))
}

mfrmr_cq_ado_generator_contract <- function() {
  data.frame(
    Component = c(
      "latent_uniform_transform",
      "direct_response_probability",
      "inverse_CDF_response_map",
      "reconstructed_A_probability_oracle",
      "log_centered_continuous_oracle",
      "simulation_dataset_wrapper"
    ),
    Implementation = c(
      "base_qnorm_on_caller_supplied_open_uniform",
      "direct_cumulative_step_log_kernel",
      "first_CDF_boundary_not_below_supplied_open_uniform",
      "independently_reconstructed_constrained_A_coefficients",
      "split_integral_around_independently_located_log_mode",
      "absent_until_ASP_G3_authorization_contract"
    ),
    CallsMfrmrFit = FALSE,
    CallsConQuest = FALSE,
    CreatesRandomnessInternally = FALSE,
    ImplementedAtG2 = c(rep(TRUE, 5L), FALSE),
    PermittedInGenerationPath = c(rep(TRUE, 3L), rep(FALSE, 3L)),
    CandidateOutputInformed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ado_person_log_integrand <- function(
    z, person_data, truth, method = c("matrix", "direct")) {
  method <- match.arg(method)
  x <- unique(person_data$X)
  mfrmr_cq_ado_assert(length(x) == 1L, "Person X changed within response rows.")
  probability <- if (method == "matrix") {
    mfrmr_cq_ado_matrix_probability
  } else {
    mfrmr_cq_ado_direct_probability
  }
  vapply(z, function(value) {
    theta <- truth$PopulationIntercept + truth$PopulationSlope * x +
      sqrt(truth$PopulationVariance) * value
    response_loglik <- sum(vapply(seq_len(nrow(person_data)), function(index) {
      log(probability(
        truth, theta, person_data$Rater[index],
        person_data$Criterion[index]
      )[person_data$Response[index] + 1L])
    }, numeric(1L)))
    response_loglik + stats::dnorm(value, log = TRUE)
  }, numeric(1L))
}

mfrmr_cq_ado_person_integral <- function(person_data, truth, method) {
  lower <- -mfrmr_cq_ado_tail_limit
  upper <- mfrmr_cq_ado_tail_limit
  objective <- function(z) {
    mfrmr_cq_ado_person_log_integrand(z, person_data, truth, method)
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
  scaled_error <- left$abs.error + right$abs.error
  log_integral <- log_height + log(scaled_value)
  relative_error <- scaled_error / scaled_value
  numerical_log_bound <- if (
      is.finite(relative_error) && relative_error >= 0 && relative_error < 1
  ) -log1p(-relative_error) else Inf
  log_tail_mass <- log(2) + stats::pnorm(
    -mfrmr_cq_ado_tail_limit, log.p = TRUE
  )
  tail_log_bound <- log1p(exp(log_tail_mass - log_integral))
  data.frame(
    Person = person_data$Person[1L],
    Responses = nrow(person_data),
    ModeLocation = location,
    ModeInterior = location > lower + 1e-6 && location < upper - 1e-6,
    LogLikelihood = log_integral,
    NumericalLogErrorBound = numerical_log_bound,
    NormalTailLogErrorBound = tail_log_bound,
    TotalLogErrorBound = numerical_log_bound + tail_log_bound,
    LeftMessage = as.character(left$message),
    RightMessage = as.character(right$message),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ado_continuous_loglikelihood <- function(
    template, method = c("matrix", "direct")) {
  mfrmr_cq_ado_require_contracts()
  method <- match.arg(method)
  mapping <- mfrmr_cq_ado_scenario_map()
  row <- mapping[
    mapping$ScenarioClassId == template$ScenarioClassId, , drop = FALSE
  ]
  mfrmr_cq_ado_assert(nrow(row) == 1L, "The template scenario is unregistered.")
  truth <- mfrmr_cq_ado_truth(row$ProfileId, template$Family)
  data <- template$Data[!is.na(template$Data$Response), , drop = FALSE]
  by_person <- split(data, data$Person)
  detail <- do.call(rbind, lapply(by_person, function(person_data) {
    mfrmr_cq_ado_person_integral(person_data, truth, method)
  }))
  rownames(detail) <- NULL
  finite <- all(is.finite(unlist(detail[, c(
    "ModeLocation", "LogLikelihood", "NumericalLogErrorBound",
    "NormalTailLogErrorBound", "TotalLogErrorBound"
  )])))
  converged <- all(detail$LeftMessage == "OK") &&
    all(detail$RightMessage == "OK")
  mfrmr_cq_ado_assert(
    finite && converged && all(detail$ModeInterior),
    "The ASP continuous oracle failed its numerical contract."
  )
  list(
    ArmId = template$ArmId,
    Family = template$Family,
    ProfileId = row$ProfileId,
    Method = method,
    Persons = nrow(detail),
    ObservedRows = sum(detail$Responses),
    LogLikelihood = sum(detail$LogLikelihood),
    Deviance = -2 * sum(detail$LogLikelihood),
    DeclaredDevianceErrorBound = 2 * sum(detail$TotalLogErrorBound),
    QuadratureErrorIsNumericalEstimate = TRUE,
    OmittedNormalTailErrorIsAnalyticBound = TRUE,
    ModesInterior = all(detail$ModeInterior),
    IntegrationsConverged = converged,
    Detail = detail,
    FitAttempted = FALSE,
    ExternalExecutionAttempted = FALSE
  )
}

mfrmr_cq_ado_continuous_audit <- function() {
  templates <- mfrmr_cq_ast_templates()
  selected <- names(templates)[vapply(templates, function(value) {
    value$ScenarioClassId %in% c(
      "ASP-POS-COMPLETE", "ASP-SENS-RARE-BOUNDARY-CATEGORY"
    )
  }, logical(1L))]
  rows <- lapply(selected, function(id) {
    sentinel <- templates[[id]]
    sentinel_persons <- if (sentinel$Family == "RSM") {
      "ASPT020"
    } else {
      "ASPT029"
    }
    sentinel$Data <- sentinel$Data[
      sentinel$Data$Person %in% sentinel_persons, , drop = FALSE
    ]
    matrix <- mfrmr_cq_ado_continuous_loglikelihood(
      sentinel, "matrix"
    )
    direct <- mfrmr_cq_ado_continuous_loglikelihood(
      sentinel, "direct"
    )
    data.frame(
      ArmId = id,
      Family = matrix$Family,
      ProfileId = matrix$ProfileId,
      SentinelPersons = paste(sentinel_persons, collapse = ";"),
      Persons = matrix$Persons,
      ObservedRows = matrix$ObservedRows,
      MatrixLogLikelihood = matrix$LogLikelihood,
      DirectLogLikelihood = direct$LogLikelihood,
      AbsoluteLogLikelihoodDifference = abs(
        matrix$LogLikelihood - direct$LogLikelihood
      ),
      MaximumDeclaredDevianceErrorBound = max(
        matrix$DeclaredDevianceErrorBound,
        direct$DeclaredDevianceErrorBound
      ),
      ModesInterior = matrix$ModesInterior && direct$ModesInterior,
      IntegrationsConverged = matrix$IntegrationsConverged &&
        direct$IntegrationsConverged,
      FullArmAuditDeferredToG3 = TRUE,
      FitAttempted = FALSE,
      ExternalExecutionAttempted = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_ado_review <- function(run_continuous_oracles = FALSE) {
  mfrmr_cq_ado_require_contracts()
  templates <- mfrmr_cq_ast_review()
  profiles <- mfrmr_cq_ado_profile_registry()
  scenario_map <- mfrmr_cq_ado_scenario_map()
  truth <- mfrmr_cq_ado_truth_audit()
  probability <- mfrmr_cq_ado_probability_audit()
  generator <- mfrmr_cq_ado_generator_contract()
  continuous <- if (isTRUE(run_continuous_oracles)) {
    mfrmr_cq_ado_continuous_audit()
  } else {
    data.frame()
  }
  core_ready <-
    isTRUE(templates$ASP_G1_complete) && nrow(profiles) == 4L &&
    !anyDuplicated(profiles$ProfileId) && all(profiles$Frozen) &&
    !any(profiles$CandidateOutputInformed) &&
    nrow(scenario_map) == 9L && !anyDuplicated(scenario_map$ScenarioClassId) &&
    setequal(
      scenario_map$ScenarioClassId,
      mfrmr_cq_asp_scenario_registry()$ScenarioClassId
    ) && !any(scenario_map$DataGenerationAuthorized) &&
    nrow(truth) == 8L && all(truth$PopulationVariancePositive) &&
    max(abs(truth$RaterSum)) < 1e-15 &&
    max(abs(truth$CriterionSum)) < 1e-15 &&
    max(truth$StepConstraintMaximum) < 1e-15 && all(truth$Finite) &&
    probability$Cases == 672L &&
    probability$MaximumAbsoluteDifference < 1e-14 &&
    isTRUE(probability$AllDirectProbabilitiesPositive) &&
    !isTRUE(probability$GeneratorCallsMatrixOracle) &&
    nrow(generator) == 6L && !any(generator$CallsMfrmrFit) &&
    !any(generator$CallsConQuest) &&
    !any(generator$CreatesRandomnessInternally) &&
    !isTRUE(generator$ImplementedAtG2[6L]) &&
    identical(which(generator$PermittedInGenerationPath), 1:3)
  continuous_ready <- isTRUE(run_continuous_oracles) &&
    nrow(continuous) == 4L &&
    all(continuous$Persons == 1L) &&
    all(continuous$ModesInterior) &&
    all(continuous$IntegrationsConverged) &&
    all(continuous$FullArmAuditDeferredToG3) &&
    all(continuous$AbsoluteLogLikelihoodDifference <= 1e-10) &&
    all(is.finite(continuous$MaximumDeclaredDevianceErrorBound)) &&
    all(continuous$MaximumDeclaredDevianceErrorBound <=
      mfrmr_cq_ado_maximum_sentinel_deviance_error_envelope) &&
    !any(continuous$FitAttempted) &&
    !any(continuous$ExternalExecutionAttempted)
  complete <- core_ready && continuous_ready
  list(
    specification = mfrmr_cq_ado_specification,
    contract_version = mfrmr_cq_ado_contract,
    status = if (complete) {
      "ASP_G2_exact_DGP_and_separated_oracles_complete_execution_closed"
    } else if (core_ready && !isTRUE(run_continuous_oracles)) {
      "ASP_G2_core_frozen_continuous_audit_unopened"
    } else {
      "ASP_G2_contract_or_oracle_audit_failed"
    },
    profiles = profiles,
    scenario_map = scenario_map,
    truth_audit = truth,
    probability_audit = probability,
    generator_contract = generator,
    continuous_audit = continuous,
    ASP_G1_prerequisite_complete = isTRUE(templates$ASP_G1_complete),
    ASP_G2_complete = complete,
    exact_DGP_values_frozen = core_ready,
    generator_probability_path_separate_from_matrix_oracle = TRUE,
    both_probability_paths_separate_from_fit_paths = TRUE,
    continuous_oracle_log_centered = TRUE,
    quadrature_error_is_numerical_estimate_not_proof = TRUE,
    omitted_normal_tail_error_is_analytic_bound = TRUE,
    maximum_sentinel_deviance_error_envelope =
      mfrmr_cq_ado_maximum_sentinel_deviance_error_envelope,
    continuous_G2_audit_is_one_person_per_arm_sentinel = TRUE,
    full_arm_continuous_audit_deferred_to_G3 = TRUE,
    internal_randomness_created = FALSE,
    prototype_responses_reclassified_as_simulation = FALSE,
    remaining_generation_blockers = c(
      "non_evaluative_smoke_seed_band",
      "calibration_seed_band",
      "confirmation_seed_band",
      "metric_specific_precision_targets_and_replication_counts",
      "sequential_stop_expand_abort_and_runtime_cap"
    ),
    next_gate = "ASP-G3-NONEVALUATIVE-SMOKE",
    any_data_generation_authorized = FALSE,
    any_fit_authorized = FALSE,
    ConQuest_execution_authorized = FALSE,
    public_text_change_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
