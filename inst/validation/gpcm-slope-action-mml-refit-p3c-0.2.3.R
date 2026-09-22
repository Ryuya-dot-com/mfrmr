# Repository-only finite-sample MML refit for two GPCM slope actions.
#
# The model estimates relative Criterion slopes (geometric mean one),
# sum-zero Rater severities, mean-zero transition boundaries, and a normal
# population mean and standard deviation. It is a bounded comparison kernel,
# not a public mfrmr response family or model-selection route.

mfrmr_gsam_require_support <- function() {
  required <- c(
    "mfrmr_gsap_actions", "mfrmr_gsap_assert", "mfrmr_gsap_hermite_normal",
    "mfrmr_gsap_parameters", "mfrmr_gsap_scenarios",
    "mfrmr_gsab_designs", "mfrmr_gsab_probabilities",
    "mfrmr_gsab_validate_edges"
  )
  support_environment <- environment(mfrmr_gsam_require_support)
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
      "Source the p3a projection and p3b sparse-oracle scripts first. ",
      "Missing: ", paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gsam_order_edges <- function(edges) {
  edges <- mfrmr_gsab_validate_edges(edges)
  edges[order(edges$CriterionIndex, edges$RaterIndex), , drop = FALSE]
}

mfrmr_gsam_parameters <- function(slopes, severities, boundaries,
                                  population_mean = 0,
                                  population_sd = 1) {
  parameters <- mfrmr_gsap_parameters(slopes, severities, boundaries)
  population_mean <- as.numeric(population_mean)[1L]
  population_sd <- as.numeric(population_sd)[1L]
  mfrmr_gsap_assert(
    is.finite(population_mean),
    "The population mean must be finite."
  )
  mfrmr_gsap_assert(
    is.finite(population_sd) && population_sd > 0,
    "The population standard deviation must be finite and positive."
  )
  mfrmr_gsap_assert(
    abs(mean(parameters$boundaries)) < 1e-10,
    "Transition boundaries must have mean zero when population location is free."
  )
  parameters$population_mean <- population_mean
  parameters$population_sd <- population_sd
  parameters
}

mfrmr_gsam_pack <- function(parameters) {
  parameters <- mfrmr_gsam_parameters(
    parameters$slopes,
    parameters$severities,
    parameters$boundaries,
    parameters$population_mean,
    parameters$population_sd
  )
  boundary_vector <- as.numeric(t(parameters$boundaries))
  c(
    log(parameters$slopes)[seq_len(3L)],
    parameters$severities[seq_len(3L)],
    boundary_vector[seq_len(11L)],
    parameters$population_mean,
    log(parameters$population_sd)
  )
}

mfrmr_gsam_unpack <- function(vector) {
  vector <- as.numeric(vector)
  mfrmr_gsap_assert(
    length(vector) == 19L && all(is.finite(vector)),
    "The MML comparison vector must contain 19 finite coordinates."
  )
  log_slopes <- c(vector[seq_len(3L)], -sum(vector[seq_len(3L)]))
  severities <- c(vector[seq.int(4L, 6L)], -sum(vector[seq.int(4L, 6L)]))
  boundary_free <- vector[seq.int(7L, 17L)]
  boundary_vector <- c(boundary_free, -sum(boundary_free))
  boundaries <- matrix(
    boundary_vector, nrow = 4L, ncol = 3L, byrow = TRUE
  )
  mfrmr_gsam_parameters(
    slopes = exp(log_slopes),
    severities = severities,
    boundaries = boundaries,
    population_mean = vector[18L],
    population_sd = exp(vector[19L])
  )
}

mfrmr_gsam_neutral_start <- function() {
  mfrmr_gsam_parameters(
    slopes = rep(1, 4L),
    severities = rep(0, 4L),
    boundaries = matrix(rep(c(-0.8, 0, 0.8), times = 4L),
                        nrow = 4L, byrow = TRUE),
    population_mean = 0,
    population_sd = 1
  )
}

mfrmr_gsam_starts <- function() {
  list(
    neutral = mfrmr_gsam_neutral_start(),
    structured = mfrmr_gsam_parameters(
      slopes = exp(c(-0.18, -0.06, 0.06, 0.18)),
      severities = c(-0.21, -0.07, 0.07, 0.21),
      boundaries = matrix(rep(c(-0.8, 0, 0.8), times = 4L),
                          nrow = 4L, byrow = TRUE),
      population_mean = 0,
      population_sd = 0.9
    )
  )
}

mfrmr_gsam_validate_responses <- function(responses, edges) {
  edges <- mfrmr_gsam_order_edges(edges)
  responses <- as.matrix(responses)
  storage.mode(responses) <- "integer"
  mfrmr_gsap_assert(
    nrow(responses) >= 1L && ncol(responses) == nrow(edges) &&
      all(responses %in% seq_len(4L)),
    "Responses must be a nonempty Person-by-edge matrix with categories 1--4."
  )
  responses
}

mfrmr_gsam_marginal_bundle <- function(vector, responses, edges, action,
                                        points = 31L,
                                        include_gradient = FALSE) {
  action <- match.arg(action, mfrmr_gsap_actions())
  edges <- mfrmr_gsam_order_edges(edges)
  responses <- mfrmr_gsam_validate_responses(responses, edges)
  parameters <- mfrmr_gsam_unpack(vector)
  quadrature <- mfrmr_gsap_hermite_normal(points)
  theta <- parameters$population_mean +
    parameters$population_sd * quadrature$nodes
  probabilities <- mfrmr_gsab_probabilities(
    theta, parameters, action, edges
  )
  node_count <- length(theta)
  person_count <- nrow(responses)
  edge_count <- nrow(edges)
  person_node_loglik <- matrix(0, nrow = person_count, ncol = node_count)
  for (edge_index in seq_len(edge_count)) {
    edge_rows <- seq.int(
      (edge_index - 1L) * node_count + 1L,
      edge_index * node_count
    )
    edge_log_probability <- log(probabilities[edge_rows, , drop = FALSE])
    person_node_loglik <- person_node_loglik + t(
      edge_log_probability[, responses[, edge_index], drop = FALSE]
    )
  }
  weighted_loglik <- sweep(
    person_node_loglik, 2L, log(quadrature$weights), "+"
  )
  row_maximum <- apply(weighted_loglik, 1L, max)
  stabilized <- exp(weighted_loglik - row_maximum)
  log_marginal <- row_maximum + log(rowSums(stabilized))
  value <- -sum(log_marginal)
  if (!isTRUE(include_gradient)) {
    return(list(value = value, parameters = parameters))
  }
  posterior <- stabilized / rowSums(stabilized)
  gradient_log_slope <- numeric(4L)
  gradient_severity <- numeric(4L)
  gradient_boundary <- matrix(0, nrow = 4L, ncol = 3L)
  gradient_mean <- 0
  gradient_log_sd <- 0
  for (node_index in seq_len(node_count)) {
    theta_score <- numeric(person_count)
    posterior_node <- posterior[, node_index]
    for (edge_index in seq_len(edge_count)) {
      rater_index <- edges$RaterIndex[edge_index]
      criterion_index <- edges$CriterionIndex[edge_index]
      probability_row <- probabilities[
        (edge_index - 1L) * node_count + node_index, , drop = TRUE
      ]
      probability_geq <- vapply(seq_len(3L), function(transition_index) {
        sum(probability_row[seq.int(transition_index + 1L, 4L)])
      }, numeric(1))
      indicator_geq <- outer(
        responses[, edge_index], seq_len(3L), ">"
      )
      residual <- sweep(indicator_geq, 2L, probability_geq, "-")
      weighted_residual <- residual * posterior_node
      residual_sum <- colSums(weighted_residual)
      slope <- parameters$slopes[criterion_index]
      scale <- if (identical(action, "complete_predictor")) slope else 1
      gradient_severity[rater_index] <-
        gradient_severity[rater_index] - scale * sum(residual_sum)
      gradient_boundary[criterion_index, ] <-
        gradient_boundary[criterion_index, ] - scale * residual_sum
      slope_derivative <- if (identical(action, "complete_predictor")) {
        slope * (
          theta[node_index] - parameters$severities[rater_index] -
            parameters$boundaries[criterion_index, ]
        )
      } else {
        rep(slope * theta[node_index], 3L)
      }
      gradient_log_slope[criterion_index] <-
        gradient_log_slope[criterion_index] +
          sum(slope_derivative * residual_sum)
      theta_score <- theta_score + slope * rowSums(residual)
    }
    gradient_mean <- gradient_mean +
      sum(posterior_node * theta_score)
    gradient_log_sd <- gradient_log_sd +
      sum(posterior_node * theta_score) *
        parameters$population_sd * quadrature$nodes[node_index]
  }
  boundary_gradient_vector <- as.numeric(t(gradient_boundary))
  gradient <- c(
    gradient_log_slope[seq_len(3L)] - gradient_log_slope[4L],
    gradient_severity[seq_len(3L)] - gradient_severity[4L],
    boundary_gradient_vector[seq_len(11L)] - boundary_gradient_vector[12L],
    gradient_mean,
    gradient_log_sd
  )
  list(
    value = value,
    gradient = -gradient,
    parameters = parameters,
    log_marginal = log_marginal,
    posterior = posterior
  )
}

mfrmr_gsam_simulate <- function(person_count, edges, parameters, action,
                                 seed) {
  edges <- mfrmr_gsam_order_edges(edges)
  person_count <- as.integer(person_count)[1L]
  mfrmr_gsap_assert(person_count >= 1L, "Use at least one simulated Person.")
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(as.integer(seed)[1L])
  theta <- stats::rnorm(
    person_count,
    mean = parameters$population_mean,
    sd = parameters$population_sd
  )
  probabilities <- mfrmr_gsab_probabilities(
    theta, parameters, action, edges
  )
  uniforms <- stats::runif(nrow(probabilities))
  category <- rep(1L, nrow(probabilities))
  cumulative <- numeric(nrow(probabilities))
  for (score_index in seq_len(ncol(probabilities) - 1L)) {
    cumulative <- cumulative + probabilities[, score_index]
    category <- category + as.integer(uniforms > cumulative)
  }
  list(
    responses = matrix(
      category, nrow = person_count, ncol = nrow(edges)
    ),
    theta = theta,
    edges = edges
  )
}

mfrmr_gsam_fit <- function(responses, edges, action, points = 31L,
                            maxit = 500L,
                            start_parameters = mfrmr_gsam_neutral_start(),
                            start_name = "neutral",
                            reltol = 1e-9) {
  action <- match.arg(action, mfrmr_gsap_actions())
  edges <- mfrmr_gsam_order_edges(edges)
  responses <- mfrmr_gsam_validate_responses(responses, edges)
  start <- mfrmr_gsam_pack(start_parameters)
  objective <- function(vector) {
    mfrmr_gsam_marginal_bundle(
      vector, responses, edges, action, points, FALSE
    )$value
  }
  gradient <- function(vector) {
    mfrmr_gsam_marginal_bundle(
      vector, responses, edges, action, points, TRUE
    )$gradient
  }
  optimization <- stats::optim(
    par = start,
    fn = objective,
    gr = gradient,
    method = "BFGS",
    control = list(
      maxit = as.integer(maxit)[1L],
      reltol = as.numeric(reltol)[1L]
    )
  )
  terminal_gradient <- gradient(optimization$par)
  list(
    action = action,
    start_name = as.character(start_name)[1L],
    points = as.integer(points)[1L],
    par = optimization$par,
    parameters = mfrmr_gsam_unpack(optimization$par),
    negative_log_likelihood = objective(optimization$par),
    convergence = as.integer(optimization$convergence),
    function_evaluations = as.integer(optimization$counts[["function"]]),
    gradient_evaluations = as.integer(optimization$counts[["gradient"]]),
    terminal_gradient_sup_norm = max(abs(terminal_gradient)),
    terminal_gradient_rms = sqrt(mean(terminal_gradient^2))
  )
}

mfrmr_gsam_fit_multistart <- function(responses, edges, action,
                                       points = 31L,
                                       maxit = 500L,
                                       polish_gradient = 1e-4) {
  starts <- mfrmr_gsam_starts()
  fits <- lapply(names(starts), function(start_name) {
    mfrmr_gsam_fit(
      responses = responses,
      edges = edges,
      action = action,
      points = points,
      maxit = maxit,
      start_parameters = starts[[start_name]],
      start_name = start_name
    )
  })
  objectives <- vapply(
    fits, `[[`, numeric(1), "negative_log_likelihood"
  )
  mfrmr_gsap_assert(
    all(is.finite(objectives)),
    "Every deterministic MML start must return a finite objective."
  )
  retained <- fits[[which.min(objectives)]]
  retained_start_name <- retained$start_name
  pre_polish_gradient_sup_norm <- retained$terminal_gradient_sup_norm
  polish_triggered <-
    retained$terminal_gradient_sup_norm > polish_gradient
  polish_improvement <- 0
  polish_accepted <- FALSE
  polish_convergence <- NA_integer_
  polish_iterations <- 0L
  polish_message <- "not_triggered"
  if (polish_triggered) {
    objective <- function(vector) {
      mfrmr_gsam_marginal_bundle(
        vector, responses, edges, action, points, FALSE
      )$value
    }
    gradient <- function(vector) {
      mfrmr_gsam_marginal_bundle(
        vector, responses, edges, action, points, TRUE
      )$gradient
    }
    polished <- stats::nlminb(
      start = retained$par,
      objective = objective,
      gradient = gradient,
      control = list(
        eval.max = 1000L,
        iter.max = as.integer(maxit)[1L],
        rel.tol = 1e-14,
        x.tol = 1e-12
      )
    )
    polished_gradient <- gradient(polished$par)
    polished_gradient_sup_norm <- max(abs(polished_gradient))
    mfrmr_gsap_assert(
      polished$objective <=
        retained$negative_log_likelihood + 1e-8,
      "The stricter retained-solution polish worsened the MML objective."
    )
    polish_accepted <-
      polished$objective <= retained$negative_log_likelihood + 1e-10 &&
      polished_gradient_sup_norm < retained$terminal_gradient_sup_norm
    if (polish_accepted) {
      polish_improvement <- max(
        retained$negative_log_likelihood - polished$objective, 0
      )
      retained$par <- polished$par
      retained$parameters <- mfrmr_gsam_unpack(polished$par)
      retained$negative_log_likelihood <- polished$objective
      retained$function_evaluations <- retained$function_evaluations +
        as.integer(polished$evaluations[["function"]])
      retained$gradient_evaluations <- retained$gradient_evaluations +
        as.integer(polished$evaluations[["gradient"]])
      retained$terminal_gradient_sup_norm <- polished_gradient_sup_norm
      retained$terminal_gradient_rms <- sqrt(mean(polished_gradient^2))
    }
    polish_convergence <- as.integer(polished$convergence)
    polish_iterations <- as.integer(polished$iterations)
    polish_message <- as.character(polished$message)
  }
  retained$start_name <- retained_start_name
  retained$all_starts <- data.frame(
    Start = names(starts),
    NegativeLogLikelihood = objectives,
    Convergence = vapply(fits, `[[`, integer(1), "convergence"),
    TerminalGradientSupNorm = vapply(
      fits, `[[`, numeric(1), "terminal_gradient_sup_norm"
    ),
    stringsAsFactors = FALSE
  )
  retained$start_nll_range <- diff(range(objectives))
  retained$polish_triggered <- polish_triggered
  retained$pre_polish_gradient_sup_norm <- pre_polish_gradient_sup_norm
  retained$polish_improvement <- polish_improvement
  retained$polish_accepted <- polish_accepted
  retained$polish_convergence <- polish_convergence
  retained$polish_iterations <- polish_iterations
  retained$polish_message <- polish_message
  retained
}

mfrmr_gsam_gradient_check <- function(responses, edges, action,
                                      points = 11L,
                                      epsilon = 1e-6) {
  edges <- mfrmr_gsam_order_edges(edges)
  responses <- mfrmr_gsam_validate_responses(responses, edges)
  vector <- mfrmr_gsam_pack(mfrmr_gsam_neutral_start())
  analytic <- mfrmr_gsam_marginal_bundle(
    vector, responses, edges, action, points, TRUE
  )$gradient
  numeric <- vapply(seq_along(vector), function(index) {
    upper <- vector
    lower <- vector
    upper[index] <- upper[index] + epsilon
    lower[index] <- lower[index] - epsilon
    upper_value <- mfrmr_gsam_marginal_bundle(
      upper, responses, edges, action, points, FALSE
    )$value
    lower_value <- mfrmr_gsam_marginal_bundle(
      lower, responses, edges, action, points, FALSE
    )$value
    (upper_value - lower_value) / (2 * epsilon)
  }, numeric(1))
  data.frame(
    Coordinate = seq_along(vector),
    Analytic = analytic,
    Numeric = numeric,
    AbsoluteDifference = abs(analytic - numeric),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsam_information <- function(fit, responses, edges) {
  edges <- mfrmr_gsam_order_edges(edges)
  objective <- function(vector) {
    mfrmr_gsam_marginal_bundle(
      vector, responses, edges, fit$action, fit$points, FALSE
    )$value
  }
  gradient <- function(vector) {
    mfrmr_gsam_marginal_bundle(
      vector, responses, edges, fit$action, fit$points, TRUE
    )$gradient
  }
  hessian <- stats::optimHess(fit$par, fn = objective, gr = gradient)
  hessian <- (hessian + t(hessian)) / 2
  eigenvalues <- eigen(hessian, symmetric = TRUE, only.values = TRUE)$values
  tolerance <- max(abs(eigenvalues)) * sqrt(.Machine$double.eps)
  rank <- sum(eigenvalues > tolerance)
  positive_definite <- all(eigenvalues > tolerance)
  condition_number <- if (positive_definite) {
    max(eigenvalues) / min(eigenvalues)
  } else {
    Inf
  }
  covariance <- if (positive_definite) {
    chol2inv(chol(hessian))
  } else {
    NULL
  }
  slope_se <- rep(NA_real_, 4L)
  population_sd_se <- NA_real_
  if (!is.null(covariance)) {
    log_slope_map <- rbind(diag(3L), rep(-1, 3L))
    log_slope_covariance <- log_slope_map %*%
      covariance[seq_len(3L), seq_len(3L), drop = FALSE] %*%
      t(log_slope_map)
    slope_se <- fit$parameters$slopes * sqrt(diag(log_slope_covariance))
    population_sd_se <- fit$parameters$population_sd * sqrt(covariance[19L, 19L])
  }
  list(
    status = if (positive_definite) "positive_definite" else "not_positive_definite",
    hessian = hessian,
    covariance = covariance,
    rank = rank,
    dimension = length(eigenvalues),
    minimum_eigenvalue = min(eigenvalues),
    condition_number = condition_number,
    slope_se = slope_se,
    population_sd_se = population_sd_se
  )
}

mfrmr_gsam_recovery <- function(fit, truth) {
  slope_error <- fit$parameters$slopes - truth$slopes
  absolute_slope_fit <-
    fit$parameters$slopes * fit$parameters$population_sd
  absolute_slope_truth <- truth$slopes * truth$population_sd
  data.frame(
    RelativeSlopeRMSE = sqrt(mean(slope_error^2)),
    PopulationMeanError = fit$parameters$population_mean - truth$population_mean,
    PopulationSDError = fit$parameters$population_sd - truth$population_sd,
    AbsoluteSlopeRMSE = sqrt(mean(
      (absolute_slope_fit - absolute_slope_truth)^2
    )),
    SeverityRMSE = sqrt(mean(
      (fit$parameters$severities - truth$severities)^2
    )),
    BoundaryRMSE = sqrt(mean(
      (fit$parameters$boundaries - truth$boundaries)^2
    )),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsam_evaluate <- function(fit, responses, edges, points = 41L) {
  mfrmr_gsam_marginal_bundle(
    fit$par, responses, edges, fit$action, points, FALSE
  )$value
}

mfrmr_run_gpcm_slope_action_mml_refit <- function(
    replications = 20L,
    training_persons = 250L,
    validation_persons = 500L,
    fit_points = 31L,
    evaluation_points = 41L,
    maxit = 500L) {
  mfrmr_gsam_require_support()
  replications <- as.integer(replications)[1L]
  training_persons <- as.integer(training_persons)[1L]
  validation_persons <- as.integer(validation_persons)[1L]
  mfrmr_gsap_assert(
    replications >= 1L && training_persons >= 1L && validation_persons >= 1L,
    "Replications and Person counts must be positive."
  )
  base <- mfrmr_gsap_scenarios()$moderate_crossed$parameters
  truth_parameters <- mfrmr_gsam_parameters(
    base$slopes, base$severities, base$boundaries, 0, 1
  )
  designs <- mfrmr_gsab_designs()[c("complete", "balanced_cycle")]
  fit_rows <- list()
  comparison_rows <- list()
  fit_index <- 0L
  comparison_index <- 0L
  for (design_index in seq_along(designs)) {
    design_name <- names(designs)[design_index]
    edges <- mfrmr_gsam_order_edges(designs[[design_name]])
    for (truth_index in seq_along(mfrmr_gsap_actions())) {
      truth_action <- mfrmr_gsap_actions()[truth_index]
      for (replication in seq_len(replications)) {
        seed_base <- 510000L + 10000L * design_index +
          1000L * truth_index + replication
        training <- mfrmr_gsam_simulate(
          training_persons, edges, truth_parameters, truth_action, seed_base
        )
        validation <- mfrmr_gsam_simulate(
          validation_persons, edges, truth_parameters, truth_action,
          seed_base + 100000L
        )
        candidate_fits <- list()
        for (candidate_action in mfrmr_gsap_actions()) {
          fit <- mfrmr_gsam_fit_multistart(
            training$responses,
            edges,
            candidate_action,
            points = fit_points,
            maxit = maxit
          )
          information <- mfrmr_gsam_information(
            fit, training$responses, edges
          )
          recovery <- mfrmr_gsam_recovery(fit, truth_parameters)
          training_evaluation <- mfrmr_gsam_evaluate(
            fit, training$responses, edges, evaluation_points
          )
          validation_evaluation <- mfrmr_gsam_evaluate(
            fit, validation$responses, edges, evaluation_points
          )
          candidate_fits[[candidate_action]] <- list(
            fit = fit,
            information = information,
            training_nll = training_evaluation,
            validation_nll = validation_evaluation
          )
          fit_index <- fit_index + 1L
          fit_rows[[fit_index]] <- data.frame(
            Design = design_name,
            TruthAction = truth_action,
            CandidateAction = candidate_action,
            Replication = replication,
            TrainingPersons = training_persons,
            ValidationPersons = validation_persons,
            EdgeCount = nrow(edges),
            FitPoints = as.integer(fit_points)[1L],
            EvaluationPoints = as.integer(evaluation_points)[1L],
            RetainedStart = fit$start_name,
            StartNLLRange = fit$start_nll_range,
            PrePolishGradientSupNorm = fit$pre_polish_gradient_sup_norm,
            PolishTriggered = fit$polish_triggered,
            PolishAccepted = fit$polish_accepted,
            PolishImprovement = fit$polish_improvement,
            PolishConvergence = fit$polish_convergence,
            PolishIterations = fit$polish_iterations,
            Convergence = fit$convergence,
            TerminalGradientSupNorm = fit$terminal_gradient_sup_norm,
            TrainingNLLFitQ = fit$negative_log_likelihood,
            TrainingNLLEvaluationQ = training_evaluation,
            ValidationNLLEvaluationQ = validation_evaluation,
            TrainingQChangePerPerson = abs(
              training_evaluation - fit$negative_log_likelihood
            ) / training_persons,
            HessianStatus = information$status,
            HessianRank = information$rank,
            HessianDimension = information$dimension,
            HessianMinimumEigenvalue = information$minimum_eigenvalue,
            HessianConditionNumber = information$condition_number,
            PopulationMean = fit$parameters$population_mean,
            PopulationSD = fit$parameters$population_sd,
            PopulationSDSE = information$population_sd_se,
            RelativeSlope1 = fit$parameters$slopes[1L],
            RelativeSlope2 = fit$parameters$slopes[2L],
            RelativeSlope3 = fit$parameters$slopes[3L],
            RelativeSlope4 = fit$parameters$slopes[4L],
            RelativeSlopeSE1 = information$slope_se[1L],
            RelativeSlopeSE2 = information$slope_se[2L],
            RelativeSlopeSE3 = information$slope_se[3L],
            RelativeSlopeSE4 = information$slope_se[4L],
            recovery,
            stringsAsFactors = FALSE
          )
        }
        true_fit <- candidate_fits[[truth_action]]
        wrong_action <- setdiff(mfrmr_gsap_actions(), truth_action)
        wrong_fit <- candidate_fits[[wrong_action]]
        training_advantage <-
          wrong_fit$training_nll - true_fit$training_nll
        training_fit_q_advantage <-
          wrong_fit$fit$negative_log_likelihood -
            true_fit$fit$negative_log_likelihood
        validation_advantage <-
          wrong_fit$validation_nll - true_fit$validation_nll
        comparison_index <- comparison_index + 1L
        comparison_rows[[comparison_index]] <- data.frame(
          Design = design_name,
          TruthAction = truth_action,
          WrongAction = wrong_action,
          Replication = replication,
          TrainingFitQTruthSelected = training_fit_q_advantage > 0,
          TrainingTruthSelected = training_advantage > 0,
          ValidationTruthSelected = validation_advantage > 0,
          TrainingFitQNLLAdvantagePerPerson =
            training_fit_q_advantage / training_persons,
          TrainingNLLAdvantagePerPerson =
            training_advantage / training_persons,
          TrainingAdvantageQChangePerPerson = abs(
            training_advantage - training_fit_q_advantage
          ) / training_persons,
          TrainingSelectionChangedByQ =
            (training_fit_q_advantage > 0) != (training_advantage > 0),
          ValidationNLLAdvantagePerPerson =
            validation_advantage / validation_persons,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  fits <- do.call(rbind, fit_rows)
  comparisons <- do.call(rbind, comparison_rows)
  rownames(fits) <- NULL
  rownames(comparisons) <- NULL
  group_key <- interaction(
    comparisons$Design, comparisons$TruthAction, drop = TRUE
  )
  comparison_summary <- do.call(rbind, lapply(
    split(comparisons, group_key),
    function(group) {
      data.frame(
        Design = group$Design[1L],
        TruthAction = group$TruthAction[1L],
        Replications = nrow(group),
        TrainingFitQTruthSelectionRate =
          mean(group$TrainingFitQTruthSelected),
        TrainingTruthSelectionRate = mean(group$TrainingTruthSelected),
        ValidationTruthSelectionRate = mean(group$ValidationTruthSelected),
        MeanTrainingNLLAdvantagePerPerson =
          mean(group$TrainingNLLAdvantagePerPerson),
        MaximumTrainingAdvantageQChangePerPerson =
          max(group$TrainingAdvantageQChangePerPerson),
        TrainingSelectionQChangeCount =
          sum(group$TrainingSelectionChangedByQ),
        MeanValidationNLLAdvantagePerPerson =
          mean(group$ValidationNLLAdvantagePerPerson),
        stringsAsFactors = FALSE
      )
    }
  ))
  true_fits <- fits[fits$TruthAction == fits$CandidateAction, , drop = FALSE]
  recovery_key <- interaction(
    true_fits$Design, true_fits$TruthAction, drop = TRUE
  )
  recovery_summary <- do.call(rbind, lapply(
    split(true_fits, recovery_key),
    function(group) {
      slope_estimates <- as.matrix(group[paste0("RelativeSlope", 1:4)])
      slope_se <- as.matrix(group[paste0("RelativeSlopeSE", 1:4)])
      truth_slopes <- matrix(
        rep(truth_parameters$slopes, each = nrow(group)),
        nrow = nrow(group)
      )
      slope_coverage <- abs(slope_estimates - truth_slopes) <= 1.96 * slope_se
      population_coverage <- abs(group$PopulationSD - 1) <=
        1.96 * group$PopulationSDSE
      data.frame(
        Design = group$Design[1L],
        TruthAction = group$TruthAction[1L],
        ConvergenceRate = mean(group$Convergence == 0L),
        PositiveDefiniteRate = mean(
          group$HessianStatus == "positive_definite"
        ),
        MaximumTerminalGradientSupNorm =
          max(group$TerminalGradientSupNorm),
        MaximumPrePolishGradientSupNorm =
          max(group$PrePolishGradientSupNorm),
        MaximumStartNLLRange = max(group$StartNLLRange),
        MaximumPolishImprovement = max(group$PolishImprovement),
        MaximumTrainingQChangePerPerson =
          max(group$TrainingQChangePerPerson),
        MedianHessianConditionNumber =
          stats::median(group$HessianConditionNumber),
        MedianRelativeSlopeRMSE = stats::median(group$RelativeSlopeRMSE),
        MedianAbsoluteSlopeRMSE = stats::median(group$AbsoluteSlopeRMSE),
        MedianAbsolutePopulationSDError =
          stats::median(abs(group$PopulationSDError)),
        RelativeSlopeCoverage95 = mean(slope_coverage, na.rm = TRUE),
        PopulationSDCoverage95 = mean(population_coverage, na.rm = TRUE),
        stringsAsFactors = FALSE
      )
    }
  ))
  rownames(comparison_summary) <- NULL
  rownames(recovery_summary) <- NULL
  list(
    status = "gpcm_slope_action_finite_sample_mml_refit_complete",
    estimator_scope = "repository_only_direct_mml_normal_population",
    truth_parameters = truth_parameters,
    fits = fits,
    comparisons = comparisons,
    comparison_summary = comparison_summary,
    recovery_summary = recovery_summary,
    public_family_added = FALSE,
    public_model_selection_enabled = FALSE,
    readiness_overridden = FALSE,
    standard_error_rule_frozen = FALSE,
    practical_threshold_frozen = FALSE,
    release_authorized = FALSE
  )
}
