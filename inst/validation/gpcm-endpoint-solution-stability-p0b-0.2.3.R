# mfrmr 0.2.3 repository-only five-category GPCM endpoint P0b audit
#
# This bounded extension applies the P0 candidate registry and canonical
# evaluator to exact and 19/20 near-endpoint Person response patterns under
# the current free-population GPCM-MML identification. It does not adjudicate
# fixed-facet recession, population-variance boundaries, continuous-normal
# integration, Hessian uncertainty, DFF, fit, rank, or separation.

mfrmr_gss_p0b_specification <- "0.2.3-draft.1"
mfrmr_gss_p0b_contract <- "mfrmr_gpcm_endpoint_solution_stability_p0b_v1"
mfrmr_gss_p0b_dependency_contract <- "mfrmr_gpcm_solution_stability_p0_v1"
mfrmr_gss_p0b_dependency_sha256 <-
  "89b20f7185ca3eaf06920cd5468711d47429df9f6d6841f59ef7a425e5e51c6f"
mfrmr_gss_p0b_scenarios <- c(
  "EXT5-P-HI", "EXT5-P-LO", "EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO"
)
mfrmr_gss_p0b_gradient_steps <- c(1e-5, 1e-6, 1e-7, 1e-8, 1e-9)

mfrmr_gss_p0b_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gss_p0b_require_sources <- function() {
  target <- environment(mfrmr_gss_p0b_require_sources)
  required <- c(
    "mfrmr_gss_contract", "mfrmr_gss_build_registry",
    "mfrmr_gss_run_candidate", "mfrmr_gss_candidate_row",
    "mfrmr_gss_pairwise", "mfrmr_gss_candidate_signature",
    "mfrmr_gss_compare_signatures", "mfrmr_num_fit_context"
  )
  available <- vapply(
    required,
    exists,
    logical(1),
    envir = target,
    inherits = TRUE
  )
  mfrmr_gss_p0b_assert(
    all(available) && identical(
      get("mfrmr_gss_contract", envir = target, inherits = TRUE),
      mfrmr_gss_p0b_dependency_contract
    ),
    paste0(
      "Source numerical-stationarity-pilot-0.2.3.R and ",
      "gpcm-solution-stability-p0-0.2.3.R before the endpoint P0b audit."
    )
  )
  invisible(TRUE)
}

mfrmr_gss_p0b_plan <- function() {
  data.frame(
    ScenarioOrder = seq_along(mfrmr_gss_p0b_scenarios),
    ScenarioId = mfrmr_gss_p0b_scenarios,
    Direction = c("high", "low", "high", "low"),
    EndpointKind = c("exact", "exact", "near", "near"),
    EndpointResponses = c(20L, 20L, 19L, 19L),
    PersonResponses = 20L,
    EndpointRate = c(1, 1, 0.95, 0.95),
    ExpectedResponseExtreme = c("high", "low", "none", "none"),
    ExpectedBoundaryDirection = c("high", "low", "none", "none"),
    ExpectedReasonCodes = c(
      "mml_extreme_response_prior_regularized",
      "mml_extreme_response_prior_regularized",
      "", ""
    ),
    Model = "GPCM",
    Method = "MML",
    Identification = "free_population",
    StepOwner = "Criterion",
    SlopeOwner = "Criterion",
    QuadPoints = 31L,
    Maxit = 800L,
    Reltol = 1e-12,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gss_p0b_base_data <- function() {
  data <- expand.grid(
    Person = sprintf("P%02d", seq_len(20L)),
    Rater = paste0("R", seq_len(5L)),
    Criterion = paste0("C", seq_len(4L)),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  person <- as.integer(sub("^P", "", data$Person))
  rater <- as.integer(sub("^R", "", data$Rater))
  criterion <- as.integer(sub("^C", "", data$Criterion))
  data$Score <- as.integer((person + 2L * rater + 3L * criterion) %% 5L + 1L)
  data
}

mfrmr_gss_p0b_fixture <- function(scenario_id) {
  mfrmr_gss_p0b_require_sources()
  scenario_id <- as.character(scenario_id)[1L]
  plan <- mfrmr_gss_p0b_plan()
  row <- plan[plan$ScenarioId == scenario_id, , drop = FALSE]
  mfrmr_gss_p0b_assert(
    nrow(row) == 1L,
    "Unknown endpoint P0b scenario."
  )
  data <- mfrmr_gss_p0b_base_data()
  target <- data$Person == "P01"
  data$Score[target] <- 5L
  if (identical(row$EndpointKind, "near")) {
    off_endpoint <- target & data$Rater == "R5" & data$Criterion == "C4"
    mfrmr_gss_p0b_assert(
      sum(off_endpoint) == 1L,
      "The near-endpoint fixture requires exactly one declared off-endpoint row."
    )
    data$Score[off_endpoint] <- 4L
  }
  if (identical(row$Direction, "low")) {
    data$Score <- 6L - data$Score
  }
  endpoint_score <- if (identical(row$Direction, "high")) 5L else 1L
  target_scores <- data$Score[target]
  mfrmr_gss_p0b_assert(
    length(target_scores) == row$PersonResponses &&
      sum(target_scores == endpoint_score) == row$EndpointResponses &&
      mean(target_scores == endpoint_score) == row$EndpointRate,
    "The endpoint fixture does not match its declared response rate."
  )
  support <- table(
    factor(data$Criterion, levels = paste0("C", seq_len(4L))),
    factor(data$Score, levels = 1:5)
  )
  mfrmr_gss_p0b_assert(
    all(support > 0L),
    "Every Criterion must retain all five categories in the P0b fixture."
  )
  canonical_csv <- paste(
    capture.output(utils::write.csv(data, row.names = FALSE, quote = TRUE)),
    collapse = "\n"
  )
  list(
    fixture_id = scenario_id,
    seed = NA_integer_,
    data = data,
    sha256 = digest::digest(
      canonical_csv,
      algo = "sha256",
      serialize = FALSE
    ),
    plan = row,
    category_support = support
  )
}

mfrmr_gss_p0b_reflection_audit <- function() {
  pairs <- list(
    c("EXT5-P-HI", "EXT5-P-LO"),
    c("EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO")
  )
  do.call(rbind, lapply(pairs, function(pair) {
    high <- mfrmr_gss_p0b_fixture(pair[1L])$data
    low <- mfrmr_gss_p0b_fixture(pair[2L])$data
    key_columns <- c("Person", "Rater", "Criterion")
    data.frame(
      HighScenarioId = pair[1L],
      LowScenarioId = pair[2L],
      RowIdentity = identical(high[key_columns], low[key_columns]),
      ExactScoreReflection = identical(
        as.integer(high$Score + low$Score),
        rep(6L, nrow(high))
      ),
      Rows = nrow(high),
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_gss_p0b_fit <- function(fixture) {
  row <- fixture$plan
  warnings <- character(0)
  error_text <- ""
  fit <- tryCatch(
    withCallingHandlers(
      getExportedValue("mfrmr", "fit_mfrm")(
        fixture$data,
        person = "Person",
        facets = c("Rater", "Criterion"),
        score = "Score",
        rating_min = 1L,
        rating_max = 5L,
        model = "GPCM",
        method = "MML",
        step_facet = "Criterion",
        slope_facet = "Criterion",
        quad_points = as.integer(row$QuadPoints),
        maxit = as.integer(row$Maxit),
        reltol = as.numeric(row$Reltol),
        optimizer = "L-BFGS-B",
        mml_engine = "direct",
        gpcm_mml_identification = "free_population"
      ),
      warning = function(condition) {
        warnings <<- c(warnings, conditionMessage(condition))
        invokeRestart("muffleWarning")
      },
      message = function(condition) invokeRestart("muffleMessage")
    ),
    error = function(condition) {
      error_text <<- conditionMessage(condition)
      NULL
    }
  )
  list(fit = fit, warnings = unique(warnings), error = error_text)
}

mfrmr_gss_p0b_endpoint_row <- function(fixture, fitted) {
  fit <- fitted$fit
  plan <- fixture$plan
  if (is.null(fit)) {
    return(data.frame(
      ScenarioId = as.character(plan$ScenarioId),
      Direction = as.character(plan$Direction),
      EndpointKind = as.character(plan$EndpointKind),
      EndpointResponses = as.integer(plan$EndpointResponses),
      PersonResponses = as.integer(plan$PersonResponses),
      EndpointRate = as.numeric(plan$EndpointRate),
      FixtureSHA256 = fixture$sha256,
      FitReturned = FALSE,
      PrimaryEstimate = NA_real_,
      PosteriorSD = NA_real_,
      PrimaryEstimateBasis = NA_character_,
      ParameterStatus = NA_character_,
      ResponseExtreme = NA_character_,
      BoundaryDirection = NA_character_,
      ReasonCodes = NA_character_,
      PopulationSigma2 = NA_real_,
      PopulationConverged = FALSE,
      ConvergenceSeverity = "fail",
      FitReadiness = "blocked",
      InferenceReady = FALSE,
      FitBoundaryState = "not_evaluated",
      SlopeBoundaryAuditState = "not_evaluated_fit_failed",
      SlopeBoundaryAuditComplete = FALSE,
      SlopeBoundaryScopeComplete = FALSE,
      ContinuousIntegralCertificate = FALSE,
      EndpointContractPassed = FALSE,
      WarningCount = length(fitted$warnings),
      WarningText = paste(fitted$warnings, collapse = " | "),
      ErrorText = fitted$error,
      P0BStatus = "blocked_source_fit_failed",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    ))
  }
  person <- fit$facets$person[
    fit$facets$person$Person == "P01", , drop = FALSE
  ]
  mfrmr_gss_p0b_assert(
    nrow(person) == 1L,
    "The P0b fit must retain exactly one P01 Person row."
  )
  readiness <- fit$readiness$fit
  slope_audit <- fit$config$boundary_audit$gpcm_slope_boundary
  exact_reason <- identical(
    as.character(person$ReasonCodes),
    as.character(plan$ExpectedReasonCodes)
  )
  contract_passed <-
    is.finite(person$PrimaryEstimate) &&
    is.finite(person$PosteriorSD) &&
    identical(as.character(person$PrimaryEstimateBasis), "posterior_eap") &&
    identical(
      as.character(person$ResponseExtreme),
      as.character(plan$ExpectedResponseExtreme)
    ) &&
    identical(
      as.character(person$BoundaryDirection),
      as.character(plan$ExpectedBoundaryDirection)
    ) &&
    exact_reason
  data.frame(
    ScenarioId = as.character(plan$ScenarioId),
    Direction = as.character(plan$Direction),
    EndpointKind = as.character(plan$EndpointKind),
    EndpointResponses = as.integer(plan$EndpointResponses),
    PersonResponses = as.integer(plan$PersonResponses),
    EndpointRate = as.numeric(plan$EndpointRate),
    FixtureSHA256 = fixture$sha256,
    FitReturned = TRUE,
    PrimaryEstimate = as.numeric(person$PrimaryEstimate),
    PosteriorSD = as.numeric(person$PosteriorSD),
    PrimaryEstimateBasis = as.character(person$PrimaryEstimateBasis),
    ParameterStatus = as.character(person$ParameterStatus),
    ResponseExtreme = as.character(person$ResponseExtreme),
    BoundaryDirection = as.character(person$BoundaryDirection),
    ReasonCodes = as.character(person$ReasonCodes),
    PopulationSigma2 = as.numeric(fit$population$sigma2),
    PopulationConverged = isTRUE(fit$population$converged),
    ConvergenceSeverity = as.character(fit$summary$ConvergenceSeverity[1L]),
    FitReadiness = as.character(readiness$FitReadiness[1L]),
    InferenceReady = isTRUE(readiness$InferenceReady[1L]),
    FitBoundaryState = as.character(readiness$BoundaryState[1L]),
    SlopeBoundaryAuditState = as.character(slope_audit$state),
    SlopeBoundaryAuditComplete = isTRUE(slope_audit$complete),
    SlopeBoundaryScopeComplete = isTRUE(slope_audit$scope_complete),
    ContinuousIntegralCertificate = isTRUE(
      slope_audit$continuous_integral_certificate
    ),
    EndpointContractPassed = contract_passed,
    WarningCount = length(fitted$warnings),
    WarningText = paste(fitted$warnings, collapse = " | "),
    ErrorText = fitted$error,
    P0BStatus = "review_population_boundary_and_solution_stability_unresolved",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gss_p0b_gradient_ladder <- function(
    scenario_id, context, candidate_objects, candidate_ids) {
  candidate_ids <- unique(as.character(candidate_ids))
  mfrmr_gss_p0b_assert(
    length(candidate_ids) > 0L &&
      all(candidate_ids %in% names(candidate_objects)),
    "The gradient ladder requires declared candidate IDs."
  )
  rows <- list()
  cursor <- 0L
  for (candidate_id in candidate_ids) {
    opt <- candidate_objects[[candidate_id]]
    mfrmr_gss_p0b_assert(
      !is.null(opt) && length(opt$par) == nrow(context$coordinates) &&
        all(is.finite(opt$par)),
      "The gradient ladder requires a complete finite candidate vector."
    )
    par <- as.numeric(opt$par)
    analytic <- suppressWarnings(as.numeric(context$gr(par)))
    for (step in mfrmr_gss_p0b_gradient_steps) {
      numeric <- suppressWarnings(mfrmr_num_central_gradient(
        context$fn, par, step
      ))
      finite <- length(analytic) == length(numeric) &&
        all(is.finite(analytic)) && all(is.finite(numeric))
      difference <- if (finite) abs(analytic - numeric) else NA_real_
      scaled <- if (finite) {
        difference / pmax(1, abs(analytic), abs(numeric))
      } else NA_real_
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        ScenarioId = scenario_id,
        CandidateId = candidate_id,
        RelativeStep = step,
        MaximumFreeCoordinateMagnitude = max(abs(par)),
        AnalyticGradientMaxAbs = if (finite) max(abs(analytic)) else NA_real_,
        NumericGradientMaxAbs = if (finite) max(abs(numeric)) else NA_real_,
        MaxAbsDifference = if (finite) max(difference) else NA_real_,
        MaxScaledDifference = if (finite) max(scaled) else NA_real_,
        EvaluationComplete = finite,
        ToleranceStatus = "not_frozen_calibration_ladder",
        StepSelectionAuthorized = FALSE,
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

mfrmr_gss_p0b_run_scenario <- function(fixture) {
  fitted <- mfrmr_gss_p0b_fit(fixture)
  endpoint <- mfrmr_gss_p0b_endpoint_row(fixture, fitted)
  if (is.null(fitted$fit)) {
    return(list(
      endpoint = endpoint,
      registry = data.frame(),
      candidates = data.frame(),
      pairwise = data.frame(),
      semantic_differences = data.frame(),
      gradient_ladder = data.frame(),
      signatures = list(),
      candidate_objects = list(),
      fit = NULL
    ))
  }
  fit <- fitted$fit
  context <- mfrmr_num_fit_context(fit)
  registry <- mfrmr_gss_build_registry(
    fit,
    fixture,
    context,
    maxit = as.integer(fixture$plan$Maxit),
    reltol = as.numeric(fixture$plan$Reltol)
  )
  candidate_objects <- vector("list", nrow(registry))
  names(candidate_objects) <- registry$StartId
  rows <- vector("list", nrow(registry))
  for (index in seq_len(nrow(registry))) {
    run <- mfrmr_gss_run_candidate(
      registry[index, , drop = FALSE],
      fit,
      context,
      use_fit_opt = identical(registry$StartId[index], "default")
    )
    candidate_objects[index] <- list(run$opt)
    rows[[index]] <- mfrmr_gss_candidate_row(
      registry[index, , drop = FALSE],
      run,
      fit,
      context
    )
  }
  candidates <- do.call(rbind, rows)
  row.names(candidates) <- NULL
  candidates$ScenarioId <- fixture$fixture_id
  candidates$EndpointKind <- as.character(fixture$plan$EndpointKind)
  candidates$EndpointDirection <- as.character(fixture$plan$Direction)
  candidates$EndpointRate <- as.numeric(fixture$plan$EndpointRate)
  candidates$P0StabilityEligible <- FALSE
  candidates$P0StabilityEligibilityReason <-
    "population_boundary_solution_tolerance_and_integration_rules_not_frozen"

  comparison <- tryCatch(
    mfrmr_gss_pairwise(candidates, candidate_objects, context),
    error = function(condition) list(
      summary = data.frame(),
      semantic = data.frame(),
      error = conditionMessage(condition)
    )
  )
  signatures <- lapply(seq_len(nrow(candidates)), function(index) {
    mfrmr_gss_candidate_signature(candidates[index, , drop = FALSE])
  })
  names(signatures) <- candidates$StartId
  finite <- which(is.finite(candidates$CommonObjective))
  diagnostic_lowest <- if (length(finite) > 0L) {
    as.character(candidates$StartId[
      finite[which.min(candidates$CommonObjective[finite])]
    ])
  } else {
    "default"
  }
  gradient_ladder <- mfrmr_gss_p0b_gradient_ladder(
    fixture$fixture_id,
    context,
    candidate_objects,
    c("default", diagnostic_lowest)
  )
  list(
    endpoint = endpoint,
    registry = registry,
    candidates = candidates,
    pairwise = comparison$summary,
    semantic_differences = comparison$semantic,
    comparison_error = mfrmr_gss_or(comparison$error, ""),
    gradient_ladder = gradient_ladder,
    signatures = signatures,
    candidate_objects = candidate_objects,
    context = context,
    fit = fit
  )
}

mfrmr_gss_p0b_signature <- function(endpoint_row, scenario_candidates) {
  mfrmr_gss_p0b_assert(
    is.data.frame(endpoint_row) && nrow(endpoint_row) == 1L &&
      is.data.frame(scenario_candidates),
    "The endpoint signature requires one endpoint row and its candidate rows."
  )
  candidates_available <- nrow(scenario_candidates) > 0L
  optimizer_passes <- if (candidates_available &&
                          "ExistingOptimizerNumericalPass" %in%
                            names(scenario_candidates)) {
    sum(scenario_candidates$ExistingOptimizerNumericalPass)
  } else 0L
  endpoint_reason <- as.character(endpoint_row$ReasonCodes)
  if (length(endpoint_reason) != 1L || is.na(endpoint_reason) ||
      !nzchar(endpoint_reason)) {
    endpoint_reason <- if (isTRUE(endpoint_row$FitReturned)) {
      "no_exact_response_boundary_reason_near_endpoint"
    } else {
      "source_fit_failed"
    }
  }
  signature <- data.frame(
    Metric = c(
      "endpoint_contract", "person_response_class", "person_estimate_basis",
      "population_convergence", "optimizer_numerical_panel",
      "population_boundary", "continuous_integration", "candidate_eap",
      "dff", "fit", "person_rank", "rater_rank", "facet_separation",
      "overall"
    ),
    State = c(
      if (isTRUE(endpoint_row$EndpointContractPassed)) "pass" else "fail",
      paste0(endpoint_row$EndpointKind, "_", endpoint_row$Direction),
      as.character(endpoint_row$PrimaryEstimateBasis),
      if (isTRUE(endpoint_row$PopulationConverged)) "pass" else "review",
      if (!candidates_available) {
        "fail"
      } else if (all(scenario_candidates$ExistingOptimizerNumericalPass)) {
        "pass"
      } else {
        "review"
      },
      "not_evaluated",
      "not_evaluated",
      "not_evaluated",
      "not_evaluated",
      "not_evaluated",
      "not_evaluated",
      "not_evaluated",
      "not_evaluated",
      if (isTRUE(endpoint_row$EndpointContractPassed) && candidates_available) {
        "review"
      } else {
        "blocked"
      }
    ),
    Eligibility = c(
      "endpoint_provenance_only", "endpoint_provenance_only",
      "endpoint_provenance_only", "not_selection_eligible",
      "comparison_only", rep("not_selection_eligible", 9L)
    ),
    Reason = c(
      if (isTRUE(endpoint_row$EndpointContractPassed)) {
        "declared_exact_or_near_person_response_contract_replayed"
      } else {
        "endpoint_contract_mismatch"
      },
      as.character(endpoint_row$ResponseExtreme),
      endpoint_reason,
      if (isTRUE(endpoint_row$PopulationConverged)) {
        "source_fit_population_converged"
      } else {
        "source_fit_population_not_converged"
      },
      if (candidates_available) {
        paste0(
          optimizer_passes,
          "_of_", nrow(scenario_candidates), "_existing_optimizer_pass"
        )
      } else {
        "no_candidate_vectors_source_fit_failed"
      },
      "marginal_population_variance_profile_required",
      "q_ladder_and_continuous_integral_not_adjudicated",
      "alternate_optimizer_vectors_not_materialized_as_full_person_posteriors",
      "scheduled_for_p3", "scheduled_for_p3", "scheduled_for_p3",
      "scheduled_for_p3", "scheduled_for_p3",
      "p0b_endpoint_provenance_only_later_gates_missing"
    ),
    stringsAsFactors = FALSE
  )
  mfrmr_gss_p0b_assert(
    !anyDuplicated(signature$Metric) &&
      all(nzchar(signature$State)) &&
      all(nzchar(signature$Eligibility)) &&
      all(nzchar(signature$Reason)),
    "Endpoint P0b signatures require unique non-empty canonical fields."
  )
  signature
}

mfrmr_run_gpcm_endpoint_solution_stability_p0b <- function(progress = FALSE) {
  mfrmr_gss_p0b_require_sources()
  plan <- mfrmr_gss_p0b_plan()
  reflection <- mfrmr_gss_p0b_reflection_audit()
  mfrmr_gss_p0b_assert(
    all(reflection$RowIdentity) && all(reflection$ExactScoreReflection),
    "High/low endpoint fixtures must be exact score reflections."
  )
  results <- vector("list", nrow(plan))
  names(results) <- plan$ScenarioId
  for (index in seq_len(nrow(plan))) {
    if (isTRUE(progress)) message("Endpoint P0b: ", plan$ScenarioId[index])
    fixture <- mfrmr_gss_p0b_fixture(plan$ScenarioId[index])
    results[[index]] <- mfrmr_gss_p0b_run_scenario(fixture)
  }
  endpoints <- do.call(rbind, lapply(results, `[[`, "endpoint"))
  candidates <- do.call(rbind, lapply(results, `[[`, "candidates"))
  pairwise <- do.call(rbind, lapply(names(results), function(id) {
    value <- results[[id]]$pairwise
    if (nrow(value) == 0L) return(NULL)
    value$ScenarioId <- id
    value
  }))
  semantic <- do.call(rbind, lapply(names(results), function(id) {
    value <- results[[id]]$semantic_differences
    if (nrow(value) == 0L) return(NULL)
    value$ScenarioId <- id
    value
  }))
  gradient_ladder <- do.call(rbind, lapply(results, `[[`, "gradient_ladder"))
  signatures <- lapply(names(results), function(id) {
    mfrmr_gss_p0b_signature(
      results[[id]]$endpoint,
      results[[id]]$candidates
    )
  })
  names(signatures) <- names(results)
  scenario_summary <- do.call(rbind, lapply(names(results), function(id) {
    result <- results[[id]]
    candidate <- result$candidates
    if (nrow(candidate) == 0L) {
      return(data.frame(
        ScenarioId = id,
        FitReturned = FALSE,
        EndpointContractPassed = FALSE,
        DeclaredStarts = 0L,
        ReturnedStarts = 0L,
        ExistingOptimizerPassStarts = 0L,
        P0ComparisonEligibleStarts = 0L,
        P0StabilityEligibleStarts = 0L,
        DiagnosticLowestObjectiveStart = NA_character_,
        DiagnosticObjectiveImprovementFromDefault = NA_real_,
        CommonObjectiveRange = NA_real_,
        MaximumAnalyticNumericGradientDifference = NA_real_,
        DefaultGradientLadderMinimumDifference = NA_real_,
        DefaultGradientLadderDiagnosticStep = NA_real_,
        DiagnosticBestGradientLadderMinimumDifference = NA_real_,
        DiagnosticBestGradientLadderDiagnosticStep = NA_real_,
        GradientToleranceStatus = "not_frozen_calibration_ladder",
        ComparisonError = as.character(result$endpoint$ErrorText),
        OverallStatus = "blocked_source_fit_failed",
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      ))
    }
    finite <- which(is.finite(candidate$CommonObjective))
    lowest_index <- if (length(finite) > 0L) {
      finite[which.min(candidate$CommonObjective[finite])]
    } else integer(0)
    lowest_id <- if (length(lowest_index) == 1L) {
      as.character(candidate$StartId[lowest_index])
    } else NA_character_
    pass <- which(
      candidate$ExistingOptimizerNumericalPass &
        is.finite(candidate$CommonObjective)
    )
    lowest_pass_index <- if (length(pass) > 0L) {
      pass[which.min(candidate$CommonObjective[pass])]
    } else integer(0)
    lowest_pass_id <- if (length(lowest_pass_index) == 1L) {
      as.character(candidate$StartId[lowest_pass_index])
    } else NA_character_
    best_semantic <- if (length(lowest_index) == 1L) {
      mfrmr_gss_semantic_vector(
        result$context,
        result$candidate_objects[[lowest_id]]$par
      )
    } else data.frame()
    semantic_value <- function(parameter_class, summary_function) {
      value <- best_semantic$Value[
        best_semantic$ParameterClass == parameter_class
      ]
      if (length(value) == 0L || any(!is.finite(value))) return(NA_real_)
      as.numeric(summary_function(value))
    }
    ladder_minimum <- function(candidate_id, field = "MaxAbsDifference") {
      value <- result$gradient_ladder[
        result$gradient_ladder$CandidateId == candidate_id &
          result$gradient_ladder$EvaluationComplete, , drop = FALSE
      ]
      if (nrow(value) == 0L) return(NA_real_)
      if (identical(field, "RelativeStep")) {
        index <- which.min(value$MaxAbsDifference)
        return(as.numeric(value$RelativeStep[index]))
      }
      min(as.numeric(value[[field]]))
    }
    data.frame(
      ScenarioId = id,
      FitReturned = isTRUE(result$endpoint$FitReturned),
      EndpointContractPassed = isTRUE(result$endpoint$EndpointContractPassed),
      DeclaredStarts = nrow(result$registry),
      ReturnedStarts = sum(candidate$FitReturned),
      ExistingOptimizerPassStarts = sum(
        candidate$ExistingOptimizerNumericalPass
      ),
      P0ComparisonEligibleStarts = sum(candidate$P0ComparisonEligible),
      P0StabilityEligibleStarts = sum(candidate$P0StabilityEligible),
      DefaultStartSeverity = as.character(
        candidate$ConvergenceSeverity[candidate$StartId == "default"]
      ),
      FailedSeverityStarts = sum(candidate$ConvergenceSeverity == "fail"),
      DiagnosticLowestObjectiveStart = lowest_id,
      DiagnosticLowestObjectiveSeverity = if (length(lowest_index) == 1L) {
        as.character(candidate$ConvergenceSeverity[lowest_index])
      } else NA_character_,
      DiagnosticLowestExistingPassStart = lowest_pass_id,
      DiagnosticObjectiveImprovementFromDefault = if (length(finite) > 0L) {
        candidate$CommonObjective[candidate$StartId == "default"] -
          min(candidate$CommonObjective[finite])
      } else NA_real_,
      DiagnosticBestPopulationSigma2 = semantic_value(
        "population_sigma2", min
      ),
      DiagnosticBestLogSlopeMinimum = semantic_value("log_slope", min),
      DiagnosticBestLogSlopeMaximum = semantic_value("log_slope", max),
      DiagnosticBestSlopeMinimum = semantic_value("slope", min),
      DiagnosticBestSlopeMaximum = semantic_value("slope", max),
      CommonObjectiveRange = if (length(finite) > 0L) {
        diff(range(candidate$CommonObjective[finite]))
      } else NA_real_,
      MaximumAnalyticNumericGradientDifference = if (
        any(is.finite(candidate$AnalyticNumericGradientMaxAbsDifference))
      ) {
        max(candidate$AnalyticNumericGradientMaxAbsDifference, na.rm = TRUE)
      } else NA_real_,
      DefaultGradientLadderMinimumDifference = ladder_minimum("default"),
      DefaultGradientLadderDiagnosticStep = ladder_minimum(
        "default", "RelativeStep"
      ),
      DiagnosticBestGradientLadderMinimumDifference = ladder_minimum(
        lowest_id
      ),
      DiagnosticBestGradientLadderDiagnosticStep = ladder_minimum(
        lowest_id, "RelativeStep"
      ),
      GradientToleranceStatus = "not_frozen_calibration_ladder",
      ComparisonError = mfrmr_gss_or(result$comparison_error, ""),
      OverallStatus =
        "review_population_boundary_and_solution_stability_unresolved",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  structure(
    list(
      contract = mfrmr_gss_p0b_contract,
      specification = mfrmr_gss_p0b_specification,
      dependency_contract = mfrmr_gss_p0b_dependency_contract,
      dependency_sha256 = mfrmr_gss_p0b_dependency_sha256,
      plan = plan,
      reflection_audit = reflection,
      endpoints = endpoints,
      candidates = candidates,
      pairwise = pairwise,
      semantic_differences = semantic,
      gradient_ladder = gradient_ladder,
      decision_signatures = signatures,
      scenario_summary = scenario_summary,
      scenario_results = results,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_endpoint_solution_stability_p0b"
  )
}
