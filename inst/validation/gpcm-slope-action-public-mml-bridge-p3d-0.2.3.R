# Repository-only bridge between the public mfrmr GPCM-MML fit and the p3c
# independent complete-predictor likelihood. It does not add a response
# family, promote inference readiness, or claim external-software equivalence.

mfrmr_gsapd_require_support <- function() {
  required <- c(
    "mfrmr_gsap_actions", "mfrmr_gsap_assert", "mfrmr_gsap_scenarios",
    "mfrmr_gsab_designs", "mfrmr_gsab_probabilities",
    "mfrmr_gsam_fit_multistart", "mfrmr_gsam_information",
    "mfrmr_gsam_marginal_bundle", "mfrmr_gsam_order_edges",
    "mfrmr_gsam_pack", "mfrmr_gsam_parameters", "mfrmr_gsam_simulate"
  )
  support_environment <- environment(mfrmr_gsapd_require_support)
  missing <- required[!vapply(required, function(name) {
    exists(
      name,
      envir = support_environment,
      mode = "function",
      inherits = TRUE
    )
  }, logical(1))]
  if (length(missing) > 0L) {
    stop(
      "Source the p3a, p3b, and p3c validation scripts first. Missing: ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  mfrmr_gsap_assert(
    requireNamespace("mfrmr", quietly = TRUE),
    "The public MML bridge requires the current `mfrmr` package."
  )
  invisible(TRUE)
}

mfrmr_gsapd_capture <- function(expression) {
  warnings <- character()
  messages <- character()
  value <- withCallingHandlers(
    expression,
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    },
    message = function(condition) {
      messages <<- c(messages, conditionMessage(condition))
      invokeRestart("muffleMessage")
    }
  )
  list(
    value = value,
    warnings = unique(warnings),
    messages = unique(messages)
  )
}

mfrmr_gsapd_long_data <- function(responses, edges) {
  edges <- mfrmr_gsam_order_edges(edges)
  responses <- mfrmr_gsam_validate_responses(responses, edges)
  person_count <- nrow(responses)
  data.frame(
    Person = rep(sprintf("P%03d", seq_len(person_count)), times = nrow(edges)),
    Rater = rep(
      sprintf("R%d", edges$RaterIndex), each = person_count
    ),
    Criterion = rep(
      sprintf("C%d", edges$CriterionIndex), each = person_count
    ),
    Score = as.integer(responses) - 1L,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsapd_fit_public <- function(long, points) {
  mfrmr_gsapd_capture(mfrmr::fit_mfrm(
    long,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    quad_points = as.integer(points)[1L],
    maxit = 500L,
    reltol = 1e-10
  ))
}

mfrmr_gsapd_public_map <- function(fit) {
  criterion_names <- sprintf("C%d", seq_len(4L))
  rater_names <- sprintf("R%d", seq_len(4L))
  slope_table <- as.data.frame(fit$slopes, stringsAsFactors = FALSE)
  slopes <- stats::setNames(
    as.numeric(slope_table$OptimizerEstimate),
    as.character(slope_table$SlopeFacet)
  )[criterion_names]
  facet_table <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  severities <- stats::setNames(
    as.numeric(facet_table$Estimate[facet_table$Facet == "Rater"]),
    as.character(facet_table$Level[facet_table$Facet == "Rater"])
  )[rater_names]
  criterion <- stats::setNames(
    as.numeric(facet_table$Estimate[facet_table$Facet == "Criterion"]),
    as.character(facet_table$Level[facet_table$Facet == "Criterion"])
  )[criterion_names]
  step_table <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  steps <- matrix(NA_real_, nrow = 4L, ncol = 3L)
  for (criterion_index in seq_len(4L)) {
    criterion_name <- criterion_names[criterion_index]
    rows <- step_table$StepFacet == criterion_name
    values <- stats::setNames(
      as.numeric(step_table$Estimate[rows]),
      as.character(step_table$Step[rows])
    )
    steps[criterion_index, ] <- values[paste0("Step_", seq_len(3L))]
  }
  mfrmr_gsap_assert(
    all(is.finite(c(slopes, severities, criterion, steps))) &&
      is.finite(as.numeric(fit$population$coefficients[1L])) &&
      is.finite(as.numeric(fit$population$sigma2[1L])),
    "The public GPCM fit did not return a complete finite optimizer map."
  )
  mfrmr_gsam_parameters(
    slopes = as.numeric(slopes),
    severities = as.numeric(severities),
    boundaries = sweep(steps, 1L, as.numeric(criterion), "+"),
    population_mean = as.numeric(fit$population$coefficients[1L]),
    population_sd = sqrt(as.numeric(fit$population$sigma2[1L]))
  )
}

mfrmr_gsapd_public_raw_se <- function(fit, public_map) {
  covariance_function <- utils::getFromNamespace(
    "compute_mml_parameter_covariance", "mfrmr"
  )
  covariance <- covariance_function(fit)
  mfrmr_gsap_assert(
    covariance$status %in% c("ok", "regularized") &&
      !is.null(covariance$cov),
    paste0(
      "The public raw observed-information covariance was unavailable: ",
      covariance$status, "."
    )
  )
  slices <- covariance$param_slices
  slope_slice <- slices$log_slopes
  sigma_slice <- slices$log_sigma2
  mfrmr_gsap_assert(
    length(slope_slice) == 3L && length(sigma_slice) == 1L,
    "The public GPCM covariance slices did not match the bridge contract."
  )
  log_slope_map <- rbind(diag(3L), rep(-1, 3L))
  log_slope_covariance <- log_slope_map %*%
    covariance$cov[slope_slice, slope_slice, drop = FALSE] %*%
    t(log_slope_map)
  slope_se <- public_map$slopes * sqrt(diag(log_slope_covariance))
  population_sd_se <- 0.5 * public_map$population_sd * sqrt(
    covariance$cov[sigma_slice, sigma_slice]
  )
  list(
    status = covariance$status,
    rank = covariance$rank,
    dimension = nrow(covariance$cov),
    slope_se = slope_se,
    population_sd_se = population_sd_se
  )
}

mfrmr_gsapd_probability_difference <- function(public_map, independent_map,
                                                 edges) {
  theta <- seq(-4, 4, length.out = 161L)
  public_probability <- mfrmr_gsab_probabilities(
    theta, public_map, "complete_predictor", edges
  )
  independent_probability <- mfrmr_gsab_probabilities(
    theta, independent_map, "complete_predictor", edges
  )
  max(abs(public_probability - independent_probability))
}

mfrmr_gsapd_kernel_match_guard <- function(summary) {
  required <- c(
    "PublicNpar", "NLLAbsDifference", "MappedPublicNLLAbsDifference",
    "SlopeMaxAbsDifference", "SeverityMaxAbsDifference",
    "BoundaryMaxAbsDifference", "PopulationMeanAbsDifference",
    "PopulationSDAbsDifference", "ProbabilityMaxAbsDifference",
    "SlopeSEMaxAbsDifference", "PopulationSDSEAbsDifference",
    "PublicCovarianceStatus", "PublicCovarianceRank",
    "IndependentHessianStatus", "IndependentHessianRank",
    "PublicEstimationConverged", "IndependentConvergence"
  )
  mfrmr_gsap_assert(
    is.data.frame(summary) && nrow(summary) > 0L &&
      all(required %in% names(summary)),
    "The kernel-match guard requires a non-empty complete bridge summary."
  )
  checks <- c(
    expected_dimension = all(summary$PublicNpar == 19L),
    public_objective = all(summary$NLLAbsDifference < 1e-6),
    mapped_public_objective = all(
      summary$MappedPublicNLLAbsDifference < 1e-8
    ),
    parameter_coordinates = all(
      summary$SlopeMaxAbsDifference < 1e-4 &
        summary$SeverityMaxAbsDifference < 1e-4 &
        summary$BoundaryMaxAbsDifference < 1e-4 &
        summary$PopulationMeanAbsDifference < 1e-4 &
        summary$PopulationSDAbsDifference < 1e-4
    ),
    fitted_probabilities = all(summary$ProbabilityMaxAbsDifference < 1e-4),
    observed_information_se = all(
      summary$SlopeSEMaxAbsDifference < 1e-4 &
        summary$PopulationSDSEAbsDifference < 1e-4
    ),
    full_rank_curvature = all(
      summary$PublicCovarianceStatus == "ok" &
        summary$PublicCovarianceRank == 19L &
        summary$IndependentHessianRank == 19L &
        summary$IndependentHessianStatus == "positive_definite"
    ),
    estimation_converged = all(
      summary$PublicEstimationConverged &
        summary$IndependentConvergence == 0L
    )
  )
  checks[is.na(checks)] <- FALSE
  list(
    matched = all(checks),
    checks = data.frame(
      Check = names(checks),
      Passed = unname(checks),
      stringsAsFactors = FALSE
    ),
    purpose = paste(
      "cross-implementation numerical regression guard;",
      "not a practical-effect, readiness, or release threshold"
    )
  )
}

mfrmr_gsapd_run_one <- function(responses, edges, points) {
  edges <- mfrmr_gsam_order_edges(edges)
  long <- mfrmr_gsapd_long_data(responses, edges)
  public_capture <- mfrmr_gsapd_fit_public(long, points)
  public_fit <- public_capture$value
  independent_fit <- mfrmr_gsam_fit_multistart(
    responses, edges, "complete_predictor", points = points
  )
  public_map <- mfrmr_gsapd_public_map(public_fit)
  public_se <- mfrmr_gsapd_public_raw_se(public_fit, public_map)
  independent_information <- mfrmr_gsam_information(
    independent_fit, responses, edges
  )
  public_readiness <- as.data.frame(
    public_fit$readiness$fit,
    stringsAsFactors = FALSE
  )
  mfrmr_gsap_assert(
    nrow(public_readiness) == 1L,
    "The public fit did not retain exactly one fit-readiness row."
  )
  mapped_public_nll <- mfrmr_gsam_marginal_bundle(
    mfrmr_gsam_pack(public_map),
    responses,
    edges,
    "complete_predictor",
    points,
    FALSE
  )$value
  public_nll <- -as.numeric(public_fit$summary$LogLik[1L])
  independent_map <- independent_fit$parameters
  list(
    summary = data.frame(
      Nodes = as.integer(points)[1L],
      ResponseRows = nrow(long),
      Persons = nrow(responses),
      PublicNpar = as.integer(public_fit$summary$Npar[1L]),
      PublicNLL = public_nll,
      IndependentNLL = independent_fit$negative_log_likelihood,
      NLLAbsDifference = abs(
        public_nll - independent_fit$negative_log_likelihood
      ),
      MappedPublicNLLAbsDifference = abs(public_nll - mapped_public_nll),
      SlopeMaxAbsDifference = max(abs(
        public_map$slopes - independent_map$slopes
      )),
      SeverityMaxAbsDifference = max(abs(
        public_map$severities - independent_map$severities
      )),
      BoundaryMaxAbsDifference = max(abs(
        public_map$boundaries - independent_map$boundaries
      )),
      PopulationMeanAbsDifference = abs(
        public_map$population_mean - independent_map$population_mean
      ),
      PopulationSDAbsDifference = abs(
        public_map$population_sd - independent_map$population_sd
      ),
      ProbabilityMaxAbsDifference = mfrmr_gsapd_probability_difference(
        public_map, independent_map, edges
      ),
      SlopeSEMaxAbsDifference = max(abs(
        public_se$slope_se - independent_information$slope_se
      )),
      PopulationSDSEAbsDifference = abs(
        public_se$population_sd_se -
          independent_information$population_sd_se
      ),
      PublicCovarianceStatus = public_se$status,
      PublicCovarianceRank = public_se$rank,
      IndependentHessianStatus = independent_information$status,
      IndependentHessianRank = independent_information$rank,
      IndependentConvergence = independent_fit$convergence,
      PublicWarningCount = length(public_capture$warnings),
      PublicMessageCount = length(public_capture$messages),
      PublicTerminalGradientSupNorm =
        as.numeric(public_fit$summary$TerminalGradientSupNorm[1L]),
      IndependentTerminalGradientSupNorm =
        independent_fit$terminal_gradient_sup_norm,
      PublicEstimationConverged = isTRUE(
        public_fit$population$estimation_converged
      ),
      PublicFitReadiness = as.character(
        public_readiness$FitReadiness[1L]
      ),
      PublicInferenceReady = isTRUE(
        public_fit$readiness$fit$InferenceReady
      ),
      PublicReadinessReasons = as.character(
        public_readiness$ReasonCodes[1L]
      ),
      stringsAsFactors = FALSE
    ),
    public_map = public_map,
    independent_map = independent_map,
    public_se = public_se,
    independent_information = independent_information,
    public_fit = public_fit,
    independent_fit = independent_fit
  )
}

mfrmr_run_gpcm_slope_action_public_mml_bridge <- function() {
  mfrmr_gsapd_require_support()
  base <- mfrmr_gsap_scenarios()$moderate_crossed$parameters
  truth <- mfrmr_gsam_parameters(
    base$slopes, base$severities, base$boundaries, 0, 1
  )
  designs <- mfrmr_gsab_designs()[c("complete", "balanced_cycle")]
  runs <- list()
  summaries <- list()
  run_index <- 0L
  for (design_index in seq_along(designs)) {
    design_name <- names(designs)[design_index]
    edges <- mfrmr_gsam_order_edges(designs[[design_name]])
    data <- mfrmr_gsam_simulate(
      80L,
      edges,
      truth,
      "complete_predictor",
      seed = 61000L + design_index
    )
    for (points in c(31L, 41L)) {
      run_index <- run_index + 1L
      run <- mfrmr_gsapd_run_one(data$responses, edges, points)
      run$summary$Design <- design_name
      runs[[run_index]] <- run
      summaries[[run_index]] <- run$summary[, c(
        "Design", setdiff(names(run$summary), "Design")
      )]
    }
  }
  summary <- do.call(rbind, summaries)
  rownames(summary) <- NULL
  stability_rows <- lapply(names(designs), function(design_name) {
    design_runs <- runs[vapply(runs, function(run) {
      identical(run$summary$Design[1L], design_name)
    }, logical(1))]
    q31 <- design_runs[[which(vapply(design_runs, function(run) {
      run$summary$Nodes[1L] == 31L
    }, logical(1)))]]
    q41 <- design_runs[[which(vapply(design_runs, function(run) {
      run$summary$Nodes[1L] == 41L
    }, logical(1)))]]
    data.frame(
      Design = design_name,
      PublicSlopeMaxAbsQ41MinusQ31 = max(abs(
        q41$public_map$slopes - q31$public_map$slopes
      )),
      IndependentSlopeMaxAbsQ41MinusQ31 = max(abs(
        q41$independent_map$slopes - q31$independent_map$slopes
      )),
      PublicPopulationSDAbsQ41MinusQ31 = abs(
        q41$public_map$population_sd - q31$public_map$population_sd
      ),
      IndependentPopulationSDAbsQ41MinusQ31 = abs(
        q41$independent_map$population_sd -
          q31$independent_map$population_sd
      ),
      stringsAsFactors = FALSE
    )
  })
  stability <- do.call(rbind, stability_rows)
  rownames(stability) <- NULL
  kernel_match <- mfrmr_gsapd_kernel_match_guard(summary)

  list(
    status = "gpcm_complete_predictor_public_mml_bridge_complete",
    comparison_scope =
      "same_rows_same_quadrature_same_complete_predictor_likelihood",
    summary = summary,
    stability = stability,
    public_kernel_matched = kernel_match$matched,
    kernel_match_checks = kernel_match$checks,
    kernel_match_guard_purpose = kernel_match$purpose,
    loading_only_public_family_added = FALSE,
    tam_many_facet_equivalence_claimed = FALSE,
    public_se_eligibility_overridden = FALSE,
    readiness_overridden = FALSE,
    comparison_tolerance_frozen = FALSE,
    release_authorized = FALSE,
    runs = runs
  )
}
