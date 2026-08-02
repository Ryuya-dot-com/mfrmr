# mfrmr 0.2.3 repository-only TAM dimensionality pilot
#
# This runner challenges the supported one-dimensional mfrmr model with
# prespecified one- and two-dimensional TAM marginal-MML fits. It is pilot
# instrumentation only. It does not expose multidimensional mfrmr estimates,
# authorize a regular chi-square LRT, freeze an integration tolerance, or
# justify dimension-specific scores.
#
# Run from the repository root after loading the development package:
#
#   pkgload::load_all(".")
#   source("inst/validation/external-ic-normalizer-0.2.3.R")
#   source("inst/validation/tam-dimensionality-pilot-0.2.3.R")
#   pilot <- mfrmr_run_tam_dimensionality_pilot_matrix(progress = TRUE)
#   print(pilot)

mfrmr_tam_dim_specification <- "0.2.3-draft.6"
mfrmr_tam_dim_contract <- "mfrmr_tam_dimensionality_pilot_v1"
mfrmr_tam_dim_boundary_correlation_review <- 0.995

mfrmr_tam_dim_or <- function(value, fallback) {
  if (is.null(value) || length(value) == 0L) fallback else value
}

mfrmr_tam_dim_scalar <- function(value) {
  suppressWarnings(as.numeric(value)[1])
}

mfrmr_tam_dim_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_tam_dim_hash <- function(object) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The TAM dimensionality pilot requires the suggested `digest` package.",
         call. = FALSE)
  }
  paste0("sha256:", digest::digest(object, algo = "sha256", serialize = TRUE))
}

mfrmr_tam_dim_git_identity <- function(pkg_dir = ".") {
  command <- function(arguments) {
    tryCatch(
      suppressWarnings(system2(
        "git", c("-C", normalizePath(pkg_dir, mustWork = TRUE), arguments),
        stdout = TRUE, stderr = FALSE
      )),
      error = function(error) character(0)
    )
  }
  commit <- command(c("rev-parse", "HEAD"))
  status <- command(c("status", "--porcelain"))
  list(
    commit = if (length(commit) == 1L) commit else NA_character_,
    dirty = if (length(commit) == 1L) length(status) > 0L else NA
  )
}

mfrmr_tam_dim_scenario_registry <- function() {
  data.frame(
    ScenarioId = c("DIM-SYN-TRUE-1D", "DIM-SYN-TRUE-2D"),
    Truth = c("one_dimension", "two_dimensions"),
    Seed = c(20260727L, 20260728L),
    Persons = c(240L, 240L),
    Items = c(12L, 12L),
    TrueCorrelation = c(1, 0.45),
    ResponseFamily = "binary_rasch",
    QSource = "prespecified_simple_structure",
    EvidenceRole = "pilot",
    PartitionRole = "pilot_only_not_confirmation",
    stringsAsFactors = FALSE
  )
}

mfrmr_tam_dim_validate_q <- function(Q, item_names, dimensions) {
  Q <- as.matrix(Q)
  dimensions <- suppressWarnings(as.integer(dimensions)[1])
  mfrmr_tam_dim_assert(
    is.numeric(Q) && nrow(Q) == length(item_names) &&
      ncol(Q) == dimensions,
    "`Q` must be a numeric item-by-dimension matrix of the declared size."
  )
  mfrmr_tam_dim_assert(
    dimensions %in% c(1L, 2L),
    "The draft.6 pilot accepts only one- or two-dimensional Q matrices."
  )
  mfrmr_tam_dim_assert(
    all(is.finite(Q)) && all(Q %in% c(0, 1)) && all(rowSums(Q) == 1),
    "Every pilot item must load on exactly one prespecified dimension."
  )
  mfrmr_tam_dim_assert(
    all(colSums(Q) >= 3L),
    "Every pilot dimension must have at least three indicators."
  )
  rownames(Q) <- item_names
  if (is.null(colnames(Q))) colnames(Q) <- paste0("D", seq_len(dimensions))
  Q
}

mfrmr_tam_dim_simulate_binary <- function(scenario,
                                           persons = NULL,
                                           items = NULL,
                                           seed = NULL) {
  mfrmr_tam_dim_assert(
    is.data.frame(scenario) && nrow(scenario) == 1L,
    "`scenario` must be one row from the dimensionality registry."
  )
  persons <- suppressWarnings(as.integer(mfrmr_tam_dim_or(
    persons, scenario$Persons
  ))[1])
  items <- suppressWarnings(as.integer(mfrmr_tam_dim_or(
    items, scenario$Items
  ))[1])
  seed <- suppressWarnings(as.integer(mfrmr_tam_dim_or(
    seed, scenario$Seed
  ))[1])
  mfrmr_tam_dim_assert(
    is.finite(persons) && persons >= 40L,
    "The pilot requires at least 40 Persons."
  )
  mfrmr_tam_dim_assert(
    is.finite(items) && items >= 6L && items %% 2L == 0L,
    "The pilot requires an even number of at least six items."
  )
  mfrmr_tam_dim_assert(
    is.finite(seed),
    "The pilot simulation requires an explicit integer seed."
  )

  set.seed(seed)
  latent_standard <- matrix(stats::rnorm(persons * 2L), ncol = 2L)
  if (identical(as.character(scenario$Truth), "one_dimension")) {
    theta <- cbind(latent_standard[, 1], latent_standard[, 1])
  } else {
    correlation <- as.numeric(scenario$TrueCorrelation)
    covariance <- matrix(c(1, correlation, correlation, 1), nrow = 2L)
    theta <- latent_standard %*% chol(covariance)
  }

  item_names <- paste0("I", seq_len(items))
  Q2 <- matrix(0, nrow = items, ncol = 2L)
  Q2[cbind(seq_len(items), rep(1:2, each = items / 2L))] <- 1
  colnames(Q2) <- c("D1", "D2")
  Q1 <- matrix(1, nrow = items, ncol = 1L,
               dimnames = list(item_names, "D1"))
  Q2 <- mfrmr_tam_dim_validate_q(Q2, item_names, 2L)

  difficulty <- rep(
    seq(-1.5, 1.5, length.out = items / 2L),
    times = 2L
  )
  linear_predictor <- vapply(seq_len(items), function(index) {
    dimension <- which(Q2[index, ] == 1)
    theta[, dimension] - difficulty[index]
  }, numeric(persons))
  response <- matrix(
    stats::rbinom(persons * items, 1L, stats::plogis(linear_predictor)),
    nrow = persons,
    ncol = items,
    dimnames = list(sprintf("P%04d", seq_len(persons)), item_names)
  )
  mfrmr_tam_dim_assert(
    all(vapply(seq_len(items), function(index) {
      length(unique(response[, index])) == 2L
    }, logical(1))),
    "A simulated item has only one observed category; change the pilot seed."
  )

  list(
    response = response,
    Q = list(
      TAM_1D = mfrmr_tam_dim_validate_q(Q1, item_names, 1L),
      TAM_2D = Q2
    ),
    metadata = data.frame(
      ScenarioId = as.character(scenario$ScenarioId),
      Truth = as.character(scenario$Truth),
      Seed = seed,
      Persons = persons,
      Items = items,
      TrueCorrelation = as.numeric(scenario$TrueCorrelation),
      RealizedLatentCorrelation = stats::cor(theta)[1, 2],
      ResponseHash = mfrmr_tam_dim_hash(list(
        response = response,
        person_ids = rownames(response),
        item_ids = colnames(response)
      )),
      Q1Hash = mfrmr_tam_dim_hash(Q1),
      Q2Hash = mfrmr_tam_dim_hash(Q2),
      EvidenceRole = "pilot",
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_tam_dim_integration_grid <- function(
    product_nodes = c(15L, 21L, 31L, 41L),
    qmc_nodes = c(512L, 1024L, 2048L, 4096L),
    node_min = -6,
    node_max = 6) {
  product_nodes <- suppressWarnings(as.integer(product_nodes))
  qmc_nodes <- suppressWarnings(as.integer(qmc_nodes))
  mfrmr_tam_dim_assert(
    length(product_nodes) > 0L && !anyNA(product_nodes) &&
      all(product_nodes >= 5L) && all(product_nodes %% 2L == 1L) &&
      !anyDuplicated(product_nodes),
    "`product_nodes` must be unique odd integers of at least five."
  )
  mfrmr_tam_dim_assert(
    length(qmc_nodes) > 0L && !anyNA(qmc_nodes) &&
      all(qmc_nodes >= 64L) && !anyDuplicated(qmc_nodes),
    "`qmc_nodes` must be unique integers of at least 64."
  )
  mfrmr_tam_dim_assert(
    is.finite(node_min) && is.finite(node_max) && node_min < node_max,
    "The product-quadrature node bounds must be finite and increasing."
  )
  product_nodes <- sort(product_nodes)
  qmc_nodes <- sort(qmc_nodes)
  product <- data.frame(
    IntegrationFamily = "product_quadrature",
    IntegrationId = paste0("product-q", product_nodes),
    NodesPerDimension = product_nodes,
    SNodes = 0L,
    QMC = TRUE,
    Seed = NA_integer_,
    SeedOperative = FALSE,
    NodeMin = node_min,
    NodeMax = node_max,
    LadderValue = product_nodes,
    stringsAsFactors = FALSE
  )
  qmc <- data.frame(
    IntegrationFamily = "deterministic_qmc",
    IntegrationId = paste0("qmc-s", qmc_nodes),
    NodesPerDimension = NA_integer_,
    SNodes = qmc_nodes,
    QMC = TRUE,
    Seed = NA_integer_,
    SeedOperative = FALSE,
    NodeMin = node_min,
    NodeMax = node_max,
    LadderValue = qmc_nodes,
    stringsAsFactors = FALSE
  )
  grid <- rbind(product, qmc)
  grid$IntegrationComparisonId <- paste0(
    "tam_binary_1pl_v1:", grid$IntegrationFamily, ":",
    ifelse(
      grid$IntegrationFamily == "product_quadrature",
      paste0("q=", grid$NodesPerDimension, ":span=", node_min, ":", node_max),
      paste0("snodes=", grid$SNodes, ":qmc=true")
    )
  )
  grid$ReferenceWithinFamily <- ave(
    grid$LadderValue,
    grid$IntegrationFamily,
    FUN = function(value) value == max(value)
  ) == 1
  rownames(grid) <- NULL
  grid
}

mfrmr_tam_dim_stochastic_grid <- function(
    snodes = 1024L,
    seeds = c(20260731L, 20260732L, 20260733L, 20260734L),
    node_min = -6,
    node_max = 6) {
  snodes <- suppressWarnings(as.integer(snodes)[1])
  seeds <- suppressWarnings(as.integer(seeds))
  mfrmr_tam_dim_assert(
    is.finite(snodes) && snodes >= 64L,
    "The stochastic integration audit requires at least 64 nodes."
  )
  mfrmr_tam_dim_assert(
    length(seeds) >= 2L && !anyNA(seeds) && !anyDuplicated(seeds),
    "The stochastic integration audit requires at least two unique seeds."
  )
  mfrmr_tam_dim_assert(
    is.finite(node_min) && is.finite(node_max) && node_min < node_max,
    "The stochastic-grid node bounds must be finite and increasing."
  )
  grid <- data.frame(
    IntegrationFamily = "stochastic_mc",
    IntegrationId = paste0("mc-s", snodes, "-seed", seeds),
    NodesPerDimension = NA_integer_,
    SNodes = snodes,
    QMC = FALSE,
    Seed = seeds,
    SeedOperative = TRUE,
    NodeMin = node_min,
    NodeMax = node_max,
    LadderValue = seq_along(seeds),
    stringsAsFactors = FALSE
  )
  grid$IntegrationComparisonId <- paste0(
    "tam_binary_1pl_v1:stochastic_mc:snodes=", snodes,
    ":qmc=false:seed=", seeds
  )
  grid$ReferenceWithinFamily <- seq_along(seeds) == 1L
  grid
}

mfrmr_tam_dim_control <- function(grid_row,
                                   maxiter = 1000L,
                                   convD = 1e-4,
                                   conv = 1e-4) {
  mfrmr_tam_dim_assert(
    is.data.frame(grid_row) && nrow(grid_row) == 1L,
    "`grid_row` must contain exactly one integration configuration."
  )
  control <- list(
    convD = convD,
    conv = conv,
    convM = conv,
    Msteps = 4L,
    maxiter = as.integer(maxiter),
    max.increment = 1,
    min.variance = 0.001,
    progress = FALSE,
    ridge = 0,
    xsi.start0 = 0,
    increment.factor = 1,
    fac.oldxsi = 0,
    acceleration = "none",
    dev_crit = "absolute",
    trim_increment = "half",
    QMC = isTRUE(grid_row$QMC[1]),
    snodes = as.integer(grid_row$SNodes[1])
  )
  if (identical(as.character(grid_row$IntegrationFamily[1]),
                "product_quadrature")) {
    control$nodes <- seq(
      as.numeric(grid_row$NodeMin[1]),
      as.numeric(grid_row$NodeMax[1]),
      length.out = as.integer(grid_row$NodesPerDimension[1])
    )
  } else {
    # TAM ignores this product grid when snodes > 0. It remains explicit so
    # the complete integration control is reproducible from the manifest.
    control$nodes <- seq(
      as.numeric(grid_row$NodeMin[1]),
      as.numeric(grid_row$NodeMax[1]),
      length.out = 21L
    )
  }
  if (isTRUE(grid_row$SeedOperative[1])) {
    control$seed <- as.integer(grid_row$Seed[1])
  }
  control
}

mfrmr_tam_dim_parameters <- function(fit) {
  values <- numeric(0)
  if (is.matrix(fit$xsi) && "xsi" %in% colnames(fit$xsi)) {
    xsi <- as.numeric(fit$xsi[, "xsi"])
    names(xsi) <- paste0("xsi:", rownames(fit$xsi))
    values <- c(values, xsi)
  }
  variance <- as.matrix(fit$variance)
  if (length(variance) > 0L && nrow(variance) == ncol(variance)) {
    index <- which(upper.tri(variance, diag = TRUE), arr.ind = TRUE)
    covariance <- variance[index]
    names(covariance) <- paste0(
      "variance:D", index[, 1], ":D", index[, 2]
    )
    values <- c(values, covariance)
  }
  values
}

mfrmr_tam_dim_convergence_review <- function(fit,
                                              warnings,
                                              expected_persons,
                                              expected_items,
                                              maxiter,
                                              convD,
                                              objective_tolerance = 1e-8) {
  history <- as.matrix(fit$deviance.history)
  history_finite <- nrow(history) >= 1L && ncol(history) >= 2L &&
    all(is.finite(history[, 2]))
  last_history_deviance <- if (history_finite) {
    history[nrow(history), 2]
  } else {
    NA_real_
  }
  last_change <- if (history_finite && nrow(history) >= 2L) {
    abs(diff(tail(history[, 2], 2L)))
  } else {
    NA_real_
  }
  ic <- as.data.frame(fit$ic, stringsAsFactors = FALSE)
  ic_deviance <- if ("deviance" %in% names(ic)) {
    mfrmr_tam_dim_scalar(ic$deviance)
  } else {
    NA_real_
  }
  ic_loglik <- if ("loglike" %in% names(ic)) {
    mfrmr_tam_dim_scalar(ic$loglike)
  } else {
    NA_real_
  }
  objective_scale <- max(1, abs(mfrmr_tam_dim_scalar(fit$deviance)))
  objective_consistent <- is.finite(ic_deviance) && is.finite(ic_loglik) &&
    abs(ic_deviance - fit$deviance) <= objective_tolerance * objective_scale &&
    abs(ic_deviance + 2 * ic_loglik) <= objective_tolerance * objective_scale
  final_history_objective_match <- is.finite(last_history_deviance) &&
    abs(last_history_deviance - fit$deviance) <=
      objective_tolerance * objective_scale
  observed_loglik_range_pass <- is.finite(ic_loglik) && ic_loglik <= 0 &&
    is.finite(ic_deviance) && ic_deviance >= 0
  iteration <- suppressWarnings(as.integer(fit$iter)[1])
  stopped_before_ceiling <- is.finite(iteration) && iteration < maxiter
  deviance_change_pass <- is.finite(last_change) &&
    last_change <= convD * (1 + 1e-6)
  retained_persons <- suppressWarnings(as.integer(fit$nstud)[1])
  retained_items <- suppressWarnings(as.integer(fit$nitems)[1])
  observation_set_preserved <- identical(retained_persons, expected_persons) &&
    identical(retained_items, expected_items)

  variance <- as.matrix(fit$variance)
  eigenvalues <- tryCatch(
    eigen(variance, symmetric = TRUE, only.values = TRUE)$values,
    error = function(error) NA_real_
  )
  min_variance_eigenvalue <- if (all(is.finite(eigenvalues))) {
    min(eigenvalues)
  } else {
    NA_real_
  }
  positive_definite <- is.finite(min_variance_eigenvalue) &&
    min_variance_eigenvalue > 0
  max_abs_correlation <- if (nrow(variance) > 1L && positive_definite) {
    correlation <- stats::cov2cor(variance)
    max(abs(correlation[upper.tri(correlation)]))
  } else {
    NA_real_
  }
  near_correlation_boundary <- is.finite(max_abs_correlation) &&
    max_abs_correlation >= mfrmr_tam_dim_boundary_correlation_review

  hard_fail <- !objective_consistent || !observed_loglik_range_pass ||
    !stopped_before_ceiling ||
    !observation_set_preserved || !positive_definite
  review <- length(warnings) > 0L || !deviance_change_pass ||
    !final_history_objective_match || near_correlation_boundary
  status <- if (hard_fail) "fail" else if (review) "review" else "pass"
  reasons <- character(0)
  if (!objective_consistent) reasons <- c(reasons, "objective_inconsistent")
  if (!observed_loglik_range_pass) {
    reasons <- c(reasons, "observed_loglik_out_of_range")
  }
  if (!stopped_before_ceiling) reasons <- c(reasons, "iteration_ceiling")
  if (!deviance_change_pass) reasons <- c(reasons, "deviance_change_not_met")
  if (!final_history_objective_match) {
    reasons <- c(reasons, "final_history_objective_mismatch")
  }
  if (!observation_set_preserved) {
    reasons <- c(reasons, "observation_set_changed")
  }
  if (!positive_definite) reasons <- c(reasons, "covariance_not_positive")
  if (near_correlation_boundary) {
    reasons <- c(reasons, "correlation_boundary_review")
  }
  if (length(warnings) > 0L) reasons <- c(reasons, "warning_emitted")

  data.frame(
    ConvergenceStatus = status,
    ConvergenceReason = paste(reasons, collapse = ";"),
    Iterations = iteration,
    IterationCeiling = as.integer(maxiter),
    StoppedBeforeIterationCeiling = stopped_before_ceiling,
    LastAbsDevianceChange = last_change,
    DevianceTolerance = convD,
    DevianceChangePass = deviance_change_pass,
    ObjectiveConsistent = objective_consistent,
    FinalHistoryObjectiveMatch = final_history_objective_match,
    ObservedLogLikRangePass = observed_loglik_range_pass,
    ObservationSetPreserved = observation_set_preserved,
    MinVarianceEigenvalue = min_variance_eigenvalue,
    MaxAbsDimensionCorrelation = max_abs_correlation,
    NearCorrelationBoundary = near_correlation_boundary,
    WarningCount = length(warnings),
    stringsAsFactors = FALSE
  )
}

mfrmr_tam_dim_empty_fit_row <- function(scenario_id,
                                         truth,
                                         model_id,
                                         dimensions,
                                         q_hash,
                                         response_hash,
                                         grid_row,
                                         error) {
  data.frame(
    ScenarioId = scenario_id,
    Truth = truth,
    ModelId = model_id,
    Dimensions = dimensions,
    QHash = q_hash,
    ResponseHash = response_hash,
    IntegrationFamily = grid_row$IntegrationFamily,
    IntegrationId = grid_row$IntegrationId,
    IntegrationComparisonId = grid_row$IntegrationComparisonId,
    NodesPerDimension = grid_row$NodesPerDimension,
    SNodes = grid_row$SNodes,
    QMC = grid_row$QMC,
    SeedOperative = grid_row$SeedOperative,
    IntegrationSeed = grid_row$Seed,
    Deviance = NA_real_,
    LogLik = NA_real_,
    Npar = NA_integer_,
    Persons = NA_integer_,
    CommonAIC = NA_real_,
    CommonBIC = NA_real_,
    CommonSABIC = NA_real_,
    NativeABIC = NA_real_,
    NativeABICFormula = NA_character_,
    NativeABICFormulaVerified = NA,
    Iterations = NA_integer_,
    IterationCeiling = NA_integer_,
    StoppedBeforeIterationCeiling = FALSE,
    LastAbsDevianceChange = NA_real_,
    DevianceTolerance = NA_real_,
    DevianceChangePass = FALSE,
    ObjectiveConsistent = FALSE,
    FinalHistoryObjectiveMatch = FALSE,
    ObservedLogLikRangePass = FALSE,
    ObservationSetPreserved = FALSE,
    MinVarianceEigenvalue = NA_real_,
    MaxAbsDimensionCorrelation = NA_real_,
    NearCorrelationBoundary = NA,
    WarningCount = NA_integer_,
    ConvergenceStatus = "fail",
    ConvergenceReason = "fit_error",
    ArithmeticEligible = FALSE,
    ComparisonReady = FALSE,
    IntegrationStabilityStatus = "not_checked",
    SelectionAuthorized = FALSE,
    RegularChiSquareLRTAuthorized = FALSE,
    Error = error,
    ElapsedSeconds = NA_real_,
    stringsAsFactors = FALSE
  )
}

mfrmr_tam_dim_fit_one <- function(response,
                                   Q,
                                   scenario_id,
                                   truth,
                                   model_id,
                                   response_hash,
                                   q_hash,
                                   grid_row,
                                   maxiter = 1000L,
                                   convD = 1e-4,
                                   conv = 1e-4,
                                   retain_fit = FALSE) {
  if (!requireNamespace("TAM", quietly = TRUE)) {
    stop("The dimensionality pilot requires the suggested `TAM` package.",
         call. = FALSE)
  }
  control <- mfrmr_tam_dim_control(
    grid_row = grid_row,
    maxiter = maxiter,
    convD = convD,
    conv = conv
  )
  warnings <- character(0)
  messages <- character(0)
  started <- proc.time()[["elapsed"]]
  fit <- tryCatch(
    withCallingHandlers(
      TAM::tam.mml(
        resp = response,
        irtmodel = "1PL",
        Q = Q,
        est.variance = TRUE,
        constraint = "cases",
        item.elim = FALSE,
        verbose = FALSE,
        control = control
      ),
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      },
      message = function(message) {
        messages <<- c(messages, conditionMessage(message))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(error) error
  )
  elapsed <- proc.time()[["elapsed"]] - started
  if (inherits(fit, "error")) {
    return(list(
      row = mfrmr_tam_dim_empty_fit_row(
        scenario_id, truth, model_id, ncol(Q), q_hash, response_hash,
        grid_row, conditionMessage(fit)
      ),
      record = NULL,
      parameters = numeric(0),
      warnings = unique(warnings),
      messages = unique(messages),
      fit = NULL
    ))
  }

  review <- mfrmr_tam_dim_convergence_review(
    fit = fit,
    warnings = unique(warnings),
    expected_persons = nrow(response),
    expected_items = ncol(response),
    maxiter = as.integer(maxiter),
    convD = convD
  )
  if (!exists("mfrmr_external_ic_from_tam", mode = "function")) {
    stop("Source `external-ic-normalizer-0.2.3.R` before this runner.",
         call. = FALSE)
  }
  record <- mfrmr_external_ic_from_tam(
    fit = fit,
    run_id = paste(scenario_id, model_id, grid_row$IntegrationId, sep = "::"),
    model_id = model_id,
    observation_set_id = response_hash,
    likelihood_basis_id = "tam_binary_1pl_observed_response_v1",
    constraint_basis_id = "tam_cases_constraint_prespecified_q_v1",
    integration_comparison_id = grid_row$IntegrationComparisonId,
    convergence_status = review$ConvergenceStatus,
    integration_stability_status = "not_checked"
  )
  normalized <- record$record[1, , drop = FALSE]
  row <- data.frame(
    ScenarioId = scenario_id,
    Truth = truth,
    ModelId = model_id,
    Dimensions = ncol(Q),
    QHash = q_hash,
    ResponseHash = response_hash,
    IntegrationFamily = grid_row$IntegrationFamily,
    IntegrationId = grid_row$IntegrationId,
    IntegrationComparisonId = grid_row$IntegrationComparisonId,
    NodesPerDimension = grid_row$NodesPerDimension,
    SNodes = grid_row$SNodes,
    QMC = grid_row$QMC,
    SeedOperative = grid_row$SeedOperative,
    IntegrationSeed = grid_row$Seed,
    Deviance = normalized$Deviance,
    LogLik = normalized$LogLik,
    Npar = normalized$Npar,
    Persons = normalized$Persons,
    CommonAIC = normalized$CommonAIC,
    CommonBIC = normalized$CommonBIC,
    CommonSABIC = normalized$CommonSABIC,
    NativeABIC = normalized$NativeABIC,
    NativeABICFormula = normalized$NativeABICFormula,
    NativeABICFormulaVerified = normalized$NativeABICFormulaVerified,
    Iterations = review$Iterations,
    IterationCeiling = review$IterationCeiling,
    StoppedBeforeIterationCeiling = review$StoppedBeforeIterationCeiling,
    LastAbsDevianceChange = review$LastAbsDevianceChange,
    DevianceTolerance = review$DevianceTolerance,
    DevianceChangePass = review$DevianceChangePass,
    ObjectiveConsistent = review$ObjectiveConsistent,
    FinalHistoryObjectiveMatch = review$FinalHistoryObjectiveMatch,
    ObservedLogLikRangePass = review$ObservedLogLikRangePass,
    ObservationSetPreserved = review$ObservationSetPreserved,
    MinVarianceEigenvalue = review$MinVarianceEigenvalue,
    MaxAbsDimensionCorrelation = review$MaxAbsDimensionCorrelation,
    NearCorrelationBoundary = review$NearCorrelationBoundary,
    WarningCount = review$WarningCount,
    ConvergenceStatus = review$ConvergenceStatus,
    ConvergenceReason = review$ConvergenceReason,
    ArithmeticEligible = normalized$ArithmeticEligible,
    ComparisonReady = normalized$ComparisonReady,
    IntegrationStabilityStatus = normalized$IntegrationStabilityStatus,
    SelectionAuthorized = FALSE,
    RegularChiSquareLRTAuthorized = FALSE,
    Error = "",
    ElapsedSeconds = elapsed,
    stringsAsFactors = FALSE
  )
  list(
    row = row,
    record = record,
    parameters = mfrmr_tam_dim_parameters(fit),
    warnings = unique(warnings),
    messages = unique(messages),
    fit = if (retain_fit) fit else NULL
  )
}

mfrmr_tam_dim_pairwise <- function(fits, observed_responses) {
  keys <- unique(fits[, c(
    "ScenarioId", "Truth", "IntegrationFamily", "IntegrationId",
    "IntegrationComparisonId"
  ), drop = FALSE])
  rows <- vector("list", nrow(keys))
  for (index in seq_len(nrow(keys))) {
    key <- keys[index, , drop = FALSE]
    selected <- fits[
      fits$ScenarioId == key$ScenarioId &
        fits$IntegrationId == key$IntegrationId,
      , drop = FALSE
    ]
    one <- selected[selected$ModelId == "TAM-1D", , drop = FALSE]
    two <- selected[selected$ModelId == "TAM-2D", , drop = FALSE]
    arithmetic <- nrow(one) == 1L && nrow(two) == 1L &&
      isTRUE(one$ArithmeticEligible) && isTRUE(two$ArithmeticEligible)
    gap <- function(field) {
      if (!arithmetic) NA_real_ else two[[field]][1] - one[[field]][1]
    }
    deviance_gain <- if (arithmetic) one$Deviance[1] - two$Deviance[1] else
      NA_real_
    rows[[index]] <- data.frame(
      ScenarioId = key$ScenarioId,
      Truth = key$Truth,
      IntegrationFamily = key$IntegrationFamily,
      IntegrationId = key$IntegrationId,
      IntegrationComparisonId = key$IntegrationComparisonId,
      NodesPerDimension = one$NodesPerDimension[1],
      SNodes = one$SNodes[1],
      IntegrationSeed = one$IntegrationSeed[1],
      DevianceGain1DMinus2D = deviance_gain,
      DevianceGainPerPerson = if (arithmetic) {
        deviance_gain / one$Persons[1]
      } else NA_real_,
      DevianceGainPerResponse = if (arithmetic) {
        deviance_gain / observed_responses
      } else NA_real_,
      AICGap2DMinus1D = gap("CommonAIC"),
      BICGap2DMinus1D = gap("CommonBIC"),
      SABICGap2DMinus1D = gap("CommonSABIC"),
      DimensionCorrelation2D = two$MaxAbsDimensionCorrelation[1],
      OneDimensionalConvergence = one$ConvergenceStatus[1],
      TwoDimensionalConvergence = two$ConvergenceStatus[1],
      ArithmeticAvailable = arithmetic,
      IntegrationStabilityStatus = "not_frozen",
      SelectionAuthorized = FALSE,
      RegularChiSquareLRTAuthorized = FALSE,
      ParametricBootstrapStatus = "not_implemented",
      ScoreConsequenceStatus = "not_tested",
      stringsAsFactors = FALSE
    )
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_tam_dim_sign_stable <- function(values, tolerance = 1e-8) {
  values <- values[is.finite(values)]
  if (length(values) == 0L) return(FALSE)
  signs <- ifelse(abs(values) <= tolerance, 0L, sign(values))
  length(unique(signs)) == 1L
}

mfrmr_tam_dim_parameter_drift <- function(parameters,
                                           scenario_id,
                                           model_id,
                                           integration_ids,
                                           reference_id) {
  prefix <- paste(scenario_id, model_id, sep = "::")
  candidate_keys <- paste(prefix, integration_ids, sep = "::")
  candidates <- parameters[candidate_keys]
  reference_key <- paste(prefix, reference_id, sep = "::")
  reference <- candidates[[reference_key]]
  if (is.null(reference) || length(reference) == 0L) return(NA_real_)
  drift <- vapply(candidates, function(candidate) {
    if (!identical(names(candidate), names(reference))) return(Inf)
    max(abs(candidate - reference))
  }, numeric(1))
  max(drift)
}

mfrmr_tam_dim_stability <- function(pairwise, fits, parameters, grid) {
  groups <- unique(pairwise[, c(
    "ScenarioId", "Truth", "IntegrationFamily"
  ), drop = FALSE])
  rows <- vector("list", nrow(groups))
  for (index in seq_len(nrow(groups))) {
    group <- groups[index, , drop = FALSE]
    selected <- pairwise[
      pairwise$ScenarioId == group$ScenarioId &
        pairwise$IntegrationFamily == group$IntegrationFamily,
      , drop = FALSE
    ]
    family_grid <- grid[
      grid$IntegrationFamily == group$IntegrationFamily,
      , drop = FALSE
    ]
    reference_id <- family_grid$IntegrationId[
      which.max(family_grid$LadderValue)
    ]
    reference <- selected[selected$IntegrationId == reference_id, , drop = FALSE]
    fit_selected <- fits[
      fits$ScenarioId == group$ScenarioId &
        fits$IntegrationFamily == group$IntegrationFamily,
      , drop = FALSE
    ]
    max_drift <- function(field) {
      if (nrow(reference) != 1L || !all(is.finite(selected[[field]]))) {
        return(NA_real_)
      }
      max(abs(selected[[field]] - reference[[field]][1]))
    }
    rows[[index]] <- data.frame(
      ScenarioId = group$ScenarioId,
      Truth = group$Truth,
      IntegrationFamily = group$IntegrationFamily,
      ReferenceIntegrationId = reference_id,
      Ladder = paste(family_grid$LadderValue, collapse = ";"),
      AllFitsConvergencePass = all(
        fit_selected$ConvergenceStatus == "pass"
      ),
      AllObjectivesConsistent = all(fit_selected$ObjectiveConsistent),
      AllFinalHistoryObjectiveMatch = all(
        fit_selected$FinalHistoryObjectiveMatch
      ),
      MaxAbsDevianceGainDrift = max_drift("DevianceGain1DMinus2D"),
      MaxAbsAICGapDrift = max_drift("AICGap2DMinus1D"),
      MaxAbsBICGapDrift = max_drift("BICGap2DMinus1D"),
      MaxAbsSABICGapDrift = max_drift("SABICGap2DMinus1D"),
      DevianceGainSignStable = mfrmr_tam_dim_sign_stable(
        selected$DevianceGain1DMinus2D
      ),
      AICGapSignStable = mfrmr_tam_dim_sign_stable(
        selected$AICGap2DMinus1D
      ),
      BICGapSignStable = mfrmr_tam_dim_sign_stable(
        selected$BICGap2DMinus1D
      ),
      SABICGapSignStable = mfrmr_tam_dim_sign_stable(
        selected$SABICGap2DMinus1D
      ),
      MaxAbsParameterDrift1D = mfrmr_tam_dim_parameter_drift(
        parameters, group$ScenarioId, "TAM-1D",
        family_grid$IntegrationId, reference_id
      ),
      MaxAbsParameterDrift2D = mfrmr_tam_dim_parameter_drift(
        parameters, group$ScenarioId, "TAM-2D",
        family_grid$IntegrationId, reference_id
      ),
      FreezeCriterionStatus = "pilot_required",
      IntegrationStabilityStatus = "review",
      SelectionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_tam_dim_cross_family <- function(pairwise, grid) {
  scenarios <- unique(pairwise$ScenarioId)
  rows <- vector("list", length(scenarios))
  fields <- c(
    "DevianceGain1DMinus2D", "AICGap2DMinus1D",
    "BICGap2DMinus1D", "SABICGap2DMinus1D"
  )
  for (index in seq_along(scenarios)) {
    scenario_id <- scenarios[index]
    selected <- pairwise[pairwise$ScenarioId == scenario_id, , drop = FALSE]
    references <- do.call(rbind, lapply(
      unique(grid$IntegrationFamily),
      function(family) {
        family_grid <- grid[grid$IntegrationFamily == family, , drop = FALSE]
        reference_id <- family_grid$IntegrationId[
          which.max(family_grid$LadderValue)
        ]
        selected[selected$IntegrationId == reference_id, , drop = FALSE]
      }
    ))
    product <- references[
      references$IntegrationFamily == "product_quadrature", , drop = FALSE
    ]
    qmc <- references[
      references$IntegrationFamily == "deterministic_qmc", , drop = FALSE
    ]
    differences <- setNames(rep(NA_real_, length(fields)), fields)
    if (nrow(product) == 1L && nrow(qmc) == 1L) {
      differences <- vapply(fields, function(field) {
        qmc[[field]][1] - product[[field]][1]
      }, numeric(1))
    }
    rows[[index]] <- data.frame(
      ScenarioId = scenario_id,
      ProductReference = if (nrow(product) == 1L) product$IntegrationId else
        NA_character_,
      QMCReference = if (nrow(qmc) == 1L) qmc$IntegrationId else
        NA_character_,
      QMCMinusProductDevianceGain = differences[[1]],
      QMCMinusProductAICGap = differences[[2]],
      QMCMinusProductBICGap = differences[[3]],
      QMCMinusProductSABICGap = differences[[4]],
      IntegrationStabilityStatus = "review",
      SelectionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_run_tam_dimensionality_pilot <- function(
    scenario_id,
    product_nodes = c(15L, 21L, 31L, 41L),
    qmc_nodes = c(512L, 1024L, 2048L, 4096L),
    persons = NULL,
    items = NULL,
    seed = NULL,
    maxiter = 1000L,
    convD = 1e-4,
    conv = 1e-4,
    pkg_dir = ".",
    retain_fits = FALSE,
    progress = FALSE) {
  if (!requireNamespace("TAM", quietly = TRUE)) {
    stop("The dimensionality pilot requires the suggested `TAM` package.",
         call. = FALSE)
  }
  if (!exists("mfrmr_external_ic_from_tam", mode = "function")) {
    normalizer <- file.path(
      pkg_dir, "inst", "validation", "external-ic-normalizer-0.2.3.R"
    )
    if (!file.exists(normalizer)) {
      stop("Cannot find the repository external-IC normalizer.", call. = FALSE)
    }
    sys.source(normalizer, envir = parent.frame())
  }
  registry <- mfrmr_tam_dim_scenario_registry()
  scenario <- registry[registry$ScenarioId == scenario_id, , drop = FALSE]
  mfrmr_tam_dim_assert(
    nrow(scenario) == 1L,
    "`scenario_id` must identify one registered pilot scenario."
  )
  generated <- mfrmr_tam_dim_simulate_binary(
    scenario = scenario,
    persons = persons,
    items = items,
    seed = seed
  )
  grid <- mfrmr_tam_dim_integration_grid(
    product_nodes = product_nodes,
    qmc_nodes = qmc_nodes
  )
  results <- list()
  parameters <- list()
  records <- list()
  retained <- list()
  warning_rows <- list()
  message_rows <- list()
  model_ids <- c("TAM-1D", "TAM-2D")
  q_hashes <- c(
    TAM_1D = generated$metadata$Q1Hash,
    TAM_2D = generated$metadata$Q2Hash
  )
  for (grid_index in seq_len(nrow(grid))) {
    grid_row <- grid[grid_index, , drop = FALSE]
    for (model_id in model_ids) {
      if (isTRUE(progress)) {
        message(
          scenario_id, " | ", grid_row$IntegrationId, " | ", model_id
        )
      }
      model_key <- gsub("-", "_", model_id, fixed = TRUE)
      Q <- generated$Q[[model_key]]
      key <- paste(scenario_id, model_id, grid_row$IntegrationId, sep = "::")
      fitted <- mfrmr_tam_dim_fit_one(
        response = generated$response,
        Q = Q,
        scenario_id = scenario_id,
        truth = as.character(scenario$Truth),
        model_id = model_id,
        response_hash = generated$metadata$ResponseHash,
        q_hash = unname(q_hashes[[model_key]]),
        grid_row = grid_row,
        maxiter = maxiter,
        convD = convD,
        conv = conv,
        retain_fit = retain_fits
      )
      results[[key]] <- fitted$row
      parameters[[key]] <- fitted$parameters
      records[[key]] <- fitted$record
      retained[[key]] <- fitted$fit
      if (length(fitted$warnings) > 0L) {
        warning_rows[[key]] <- data.frame(
          ScenarioId = scenario_id,
          ModelId = model_id,
          IntegrationId = grid_row$IntegrationId,
          Warning = fitted$warnings,
          stringsAsFactors = FALSE
        )
      }
      if (length(fitted$messages) > 0L) {
        message_rows[[key]] <- data.frame(
          ScenarioId = scenario_id,
          ModelId = model_id,
          IntegrationId = grid_row$IntegrationId,
          Message = fitted$messages,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  fits <- do.call(rbind, results)
  rownames(fits) <- NULL
  pairwise <- mfrmr_tam_dim_pairwise(
    fits = fits,
    observed_responses = sum(!is.na(generated$response))
  )
  stability <- mfrmr_tam_dim_stability(
    pairwise = pairwise,
    fits = fits,
    parameters = parameters,
    grid = grid
  )
  warnings <- if (length(warning_rows) > 0L) {
    do.call(rbind, warning_rows)
  } else {
    data.frame(
      ScenarioId = character(), ModelId = character(),
      IntegrationId = character(), Warning = character(),
      stringsAsFactors = FALSE
    )
  }
  messages <- if (length(message_rows) > 0L) {
    do.call(rbind, message_rows)
  } else {
    data.frame(
      ScenarioId = character(), ModelId = character(),
      IntegrationId = character(), Message = character(),
      stringsAsFactors = FALSE
    )
  }
  git <- mfrmr_tam_dim_git_identity(pkg_dir)
  manifest <- cbind(
    generated$metadata,
    data.frame(
      Specification = mfrmr_tam_dim_specification,
      ContractVersion = mfrmr_tam_dim_contract,
      TAMVersion = as.character(utils::packageVersion("TAM")),
      MfrmrVersion = as.character(utils::packageVersion("mfrmr")),
      RVersion = paste(R.version$major, R.version$minor, sep = "."),
      Platform = R.version$platform,
      SourceCommit = git$commit,
      DirtyWorktree = git$dirty,
      IntegrationGridHash = mfrmr_tam_dim_hash(grid),
      MaxIterations = as.integer(maxiter),
      DevianceTolerance = convD,
      ParameterTolerance = conv,
      StartPolicy = "fresh_tam_defaults_each_refit",
      QHypothesisPolicy = "prespecified_not_data_derived",
      RegularChiSquareLRTAuthorized = FALSE,
      ParametricBootstrapStatus = "not_implemented",
      ScoreConsequenceStatus = "not_tested",
      SelectionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  )
  out <- list(
    specification = mfrmr_tam_dim_specification,
    contract_version = mfrmr_tam_dim_contract,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    selection_authorized = FALSE,
    manifest = manifest,
    integration_grid = grid,
    fits = fits,
    pairwise = pairwise,
    stability = stability,
    records = records,
    parameters = parameters,
    warnings = warnings,
    messages = messages,
    retained_fits = if (retain_fits) retained else NULL,
    status = if (all(fits$ConvergenceStatus != "fail")) "review" else "fail"
  )
  class(out) <- c("mfrmr_tam_dimensionality_pilot", class(out))
  out
}

mfrmr_run_tam_dimensionality_pilot_matrix <- function(
    product_nodes = c(15L, 21L, 31L, 41L),
    qmc_nodes = c(512L, 1024L, 2048L, 4096L),
    maxiter = 1000L,
    convD = 1e-4,
    conv = 1e-4,
    pkg_dir = ".",
    progress = FALSE) {
  registry <- mfrmr_tam_dim_scenario_registry()
  pilots <- lapply(registry$ScenarioId, function(scenario_id) {
    mfrmr_run_tam_dimensionality_pilot(
      scenario_id = scenario_id,
      product_nodes = product_nodes,
      qmc_nodes = qmc_nodes,
      maxiter = maxiter,
      convD = convD,
      conv = conv,
      pkg_dir = pkg_dir,
      progress = progress
    )
  })
  names(pilots) <- registry$ScenarioId
  fits <- do.call(rbind, lapply(pilots, `[[`, "fits"))
  pairwise <- do.call(rbind, lapply(pilots, `[[`, "pairwise"))
  stability <- do.call(rbind, lapply(pilots, `[[`, "stability"))
  manifest <- do.call(rbind, lapply(pilots, `[[`, "manifest"))
  warnings <- do.call(rbind, lapply(pilots, `[[`, "warnings"))
  messages <- do.call(rbind, lapply(pilots, `[[`, "messages"))
  grid <- pilots[[1]]$integration_grid
  cross_family <- mfrmr_tam_dim_cross_family(pairwise, grid)
  rownames(fits) <- rownames(pairwise) <- rownames(stability) <- NULL
  rownames(manifest) <- rownames(warnings) <- rownames(messages) <- NULL
  out <- list(
    specification = mfrmr_tam_dim_specification,
    contract_version = mfrmr_tam_dim_contract,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    selection_authorized = FALSE,
    scenarios = registry,
    manifest = manifest,
    integration_grid = grid,
    fits = fits,
    pairwise = pairwise,
    stability = stability,
    cross_family = cross_family,
    warnings = warnings,
    messages = messages,
    pilots = pilots,
    status = if (all(vapply(pilots, function(pilot) {
      identical(pilot$status, "review")
    }, logical(1)))) "review" else "fail"
  )
  class(out) <- c("mfrmr_tam_dimensionality_pilot_matrix", class(out))
  out
}

mfrmr_run_tam_dimensionality_qmc_repeat_audit <- function(
    scenario_id,
    qmc_nodes = 1024L,
    repeats = 2L,
    persons = NULL,
    items = NULL,
    seed = NULL,
    maxiter = 1000L,
    convD = 1e-4,
    conv = 1e-4,
    repeat_tolerance = 1e-12,
    pkg_dir = ".") {
  repeats <- suppressWarnings(as.integer(repeats)[1])
  mfrmr_tam_dim_assert(
    is.finite(repeats) && repeats >= 2L,
    "The QMC repeat audit requires at least two independent refits."
  )
  if (!exists("mfrmr_external_ic_from_tam", mode = "function")) {
    normalizer <- file.path(
      pkg_dir, "inst", "validation", "external-ic-normalizer-0.2.3.R"
    )
    if (!file.exists(normalizer)) {
      stop("Cannot find the repository external-IC normalizer.", call. = FALSE)
    }
    sys.source(normalizer, envir = parent.frame())
  }
  registry <- mfrmr_tam_dim_scenario_registry()
  scenario <- registry[registry$ScenarioId == scenario_id, , drop = FALSE]
  mfrmr_tam_dim_assert(
    nrow(scenario) == 1L,
    "`scenario_id` must identify one registered pilot scenario."
  )
  generated <- mfrmr_tam_dim_simulate_binary(
    scenario = scenario,
    persons = persons,
    items = items,
    seed = seed
  )
  grid <- mfrmr_tam_dim_integration_grid(
    product_nodes = 21L,
    qmc_nodes = qmc_nodes
  )
  grid_row <- grid[
    grid$IntegrationFamily == "deterministic_qmc", , drop = FALSE
  ]
  model_ids <- c("TAM-1D", "TAM-2D")
  q_hashes <- c(
    TAM_1D = generated$metadata$Q1Hash,
    TAM_2D = generated$metadata$Q2Hash
  )
  rows <- list()
  parameters <- list()
  for (repeat_id in seq_len(repeats)) {
    for (model_id in model_ids) {
      model_key <- gsub("-", "_", model_id, fixed = TRUE)
      key <- paste0("repeat-", repeat_id, "::", model_id)
      fitted <- mfrmr_tam_dim_fit_one(
        response = generated$response,
        Q = generated$Q[[model_key]],
        scenario_id = scenario_id,
        truth = as.character(scenario$Truth),
        model_id = model_id,
        response_hash = generated$metadata$ResponseHash,
        q_hash = unname(q_hashes[[model_key]]),
        grid_row = grid_row,
        maxiter = maxiter,
        convD = convD,
        conv = conv,
        retain_fit = FALSE
      )
      row <- fitted$row
      row$Repeat <- repeat_id
      rows[[key]] <- row
      parameters[[key]] <- fitted$parameters
    }
  }
  fits <- do.call(rbind, rows)
  rownames(fits) <- NULL
  summary_rows <- lapply(model_ids, function(model_id) {
    selected <- fits[fits$ModelId == model_id, , drop = FALSE]
    reference_deviance <- selected$Deviance[selected$Repeat == 1L]
    deviance_difference <- max(abs(selected$Deviance - reference_deviance))
    reference_parameters <- parameters[[paste0("repeat-1::", model_id)]]
    parameter_difference <- max(vapply(seq_len(repeats), function(repeat_id) {
      candidate <- parameters[[paste0("repeat-", repeat_id, "::", model_id)]]
      if (!identical(names(candidate), names(reference_parameters))) return(Inf)
      max(abs(candidate - reference_parameters))
    }, numeric(1)))
    data.frame(
      ScenarioId = scenario_id,
      ModelId = model_id,
      QMCNodes = as.integer(qmc_nodes),
      Repeats = repeats,
      SeedOperative = FALSE,
      MaxAbsDevianceRepeatDifference = deviance_difference,
      MaxAbsParameterRepeatDifference = parameter_difference,
      AllObjectivesConsistent = all(selected$ObjectiveConsistent),
      AllFitsWithoutHardFailure = all(selected$ConvergenceStatus != "fail"),
      DeterministicReplayObserved =
        is.finite(deviance_difference) &&
        is.finite(parameter_difference) &&
        deviance_difference <= repeat_tolerance &&
        parameter_difference <= repeat_tolerance,
      EvidenceRole = "pilot",
      ConfirmationAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  summary <- do.call(rbind, summary_rows)
  rownames(summary) <- NULL
  out <- list(
    specification = mfrmr_tam_dim_specification,
    contract_version = mfrmr_tam_dim_contract,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    selection_authorized = FALSE,
    manifest = generated$metadata,
    integration = grid_row,
    fits = fits,
    summary = summary,
    status = if (all(summary$DeterministicReplayObserved) &&
                     all(summary$AllFitsWithoutHardFailure)) "review" else "fail"
  )
  class(out) <- c("mfrmr_tam_dimensionality_qmc_repeat_audit", class(out))
  out
}

mfrmr_run_tam_dimensionality_stochastic_audit <- function(
    scenario_id,
    snodes = 1024L,
    seeds = c(20260731L, 20260732L, 20260733L, 20260734L),
    persons = NULL,
    items = NULL,
    seed = NULL,
    maxiter = 1000L,
    convD = 1e-4,
    conv = 1e-4,
    pkg_dir = ".") {
  if (!exists("mfrmr_external_ic_from_tam", mode = "function")) {
    normalizer <- file.path(
      pkg_dir, "inst", "validation", "external-ic-normalizer-0.2.3.R"
    )
    if (!file.exists(normalizer)) {
      stop("Cannot find the repository external-IC normalizer.", call. = FALSE)
    }
    sys.source(normalizer, envir = parent.frame())
  }
  registry <- mfrmr_tam_dim_scenario_registry()
  scenario <- registry[registry$ScenarioId == scenario_id, , drop = FALSE]
  mfrmr_tam_dim_assert(
    nrow(scenario) == 1L,
    "`scenario_id` must identify one registered pilot scenario."
  )
  generated <- mfrmr_tam_dim_simulate_binary(
    scenario = scenario,
    persons = persons,
    items = items,
    seed = seed
  )
  grid <- mfrmr_tam_dim_stochastic_grid(snodes = snodes, seeds = seeds)
  model_ids <- c("TAM-1D", "TAM-2D")
  q_hashes <- c(
    TAM_1D = generated$metadata$Q1Hash,
    TAM_2D = generated$metadata$Q2Hash
  )
  rows <- list()
  parameters <- list()
  records <- list()
  warning_rows <- list()
  for (grid_index in seq_len(nrow(grid))) {
    grid_row <- grid[grid_index, , drop = FALSE]
    for (model_id in model_ids) {
      model_key <- gsub("-", "_", model_id, fixed = TRUE)
      key <- paste(scenario_id, model_id, grid_row$IntegrationId, sep = "::")
      fitted <- mfrmr_tam_dim_fit_one(
        response = generated$response,
        Q = generated$Q[[model_key]],
        scenario_id = scenario_id,
        truth = as.character(scenario$Truth),
        model_id = model_id,
        response_hash = generated$metadata$ResponseHash,
        q_hash = unname(q_hashes[[model_key]]),
        grid_row = grid_row,
        maxiter = maxiter,
        convD = convD,
        conv = conv,
        retain_fit = FALSE
      )
      rows[[key]] <- fitted$row
      parameters[[key]] <- fitted$parameters
      records[[key]] <- fitted$record
      if (length(fitted$warnings) > 0L) {
        warning_rows[[key]] <- data.frame(
          ScenarioId = scenario_id,
          ModelId = model_id,
          IntegrationId = grid_row$IntegrationId,
          IntegrationSeed = grid_row$Seed,
          Warning = fitted$warnings,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  fits <- do.call(rbind, rows)
  rownames(fits) <- NULL
  pairwise <- mfrmr_tam_dim_pairwise(
    fits = fits,
    observed_responses = sum(!is.na(generated$response))
  )
  reference_id <- grid$IntegrationId[1]
  model_stability <- do.call(rbind, lapply(model_ids, function(model_id) {
    selected <- fits[fits$ModelId == model_id, , drop = FALSE]
    reference_deviance <- selected$Deviance[
      selected$IntegrationId == reference_id
    ]
    data.frame(
      ScenarioId = scenario_id,
      ModelId = model_id,
      SNodes = as.integer(snodes),
      Seeds = paste(seeds, collapse = ";"),
      MaxAbsDevianceSeedDifference = max(
        abs(selected$Deviance - reference_deviance)
      ),
      DevianceRange = diff(range(selected$Deviance)),
      MaxAbsParameterSeedDifference = mfrmr_tam_dim_parameter_drift(
        parameters = parameters,
        scenario_id = scenario_id,
        model_id = model_id,
        integration_ids = grid$IntegrationId,
        reference_id = reference_id
      ),
      AllObjectivesConsistent = all(selected$ObjectiveConsistent),
      AllFitsWithoutHardFailure = all(selected$ConvergenceStatus != "fail"),
      AllSeedsRecorded = all(is.finite(selected$IntegrationSeed)),
      StochasticVariationExpected = TRUE,
      EvidenceRole = "pilot",
      ConfirmationAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  reference_pair <- pairwise[pairwise$IntegrationId == reference_id, , drop = FALSE]
  drift <- function(field) {
    max(abs(pairwise[[field]] - reference_pair[[field]][1]))
  }
  pairwise_stability <- data.frame(
    ScenarioId = scenario_id,
    SNodes = as.integer(snodes),
    Seeds = paste(seeds, collapse = ";"),
    MaxAbsDevianceGainSeedDifference = drift("DevianceGain1DMinus2D"),
    MaxAbsAICGapSeedDifference = drift("AICGap2DMinus1D"),
    MaxAbsBICGapSeedDifference = drift("BICGap2DMinus1D"),
    MaxAbsSABICGapSeedDifference = drift("SABICGap2DMinus1D"),
    DevianceGainSignStable = mfrmr_tam_dim_sign_stable(
      pairwise$DevianceGain1DMinus2D
    ),
    AICGapSignStable = mfrmr_tam_dim_sign_stable(pairwise$AICGap2DMinus1D),
    BICGapSignStable = mfrmr_tam_dim_sign_stable(pairwise$BICGap2DMinus1D),
    SABICGapSignStable = mfrmr_tam_dim_sign_stable(
      pairwise$SABICGap2DMinus1D
    ),
    IntegrationStabilityStatus = "review",
    FreezeCriterionStatus = "pilot_required",
    ConfirmationAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  warnings <- if (length(warning_rows) > 0L) {
    do.call(rbind, warning_rows)
  } else {
    data.frame(
      ScenarioId = character(), ModelId = character(),
      IntegrationId = character(), IntegrationSeed = integer(),
      Warning = character(), stringsAsFactors = FALSE
    )
  }
  out <- list(
    specification = mfrmr_tam_dim_specification,
    contract_version = mfrmr_tam_dim_contract,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    selection_authorized = FALSE,
    manifest = generated$metadata,
    integration_grid = grid,
    fits = fits,
    pairwise = pairwise,
    model_stability = model_stability,
    pairwise_stability = pairwise_stability,
    records = records,
    warnings = warnings,
    status = if (all(model_stability$AllFitsWithoutHardFailure)) {
      "review"
    } else {
      "fail"
    }
  )
  class(out) <- c("mfrmr_tam_dimensionality_stochastic_audit", class(out))
  out
}

print.mfrmr_tam_dimensionality_pilot <- function(x, digits = 6L, ...) {
  cat("mfrmr 0.2.3 TAM dimensionality pilot\n")
  cat("  Scenario:", x$manifest$ScenarioId, "| truth:", x$manifest$Truth,
      "\n")
  cat("  TAM:", x$manifest$TAMVersion, "| fits:", nrow(x$fits), "\n")
  cat("  Status:", x$status, "| selection authorized: FALSE\n")
  display <- x$stability
  numeric_columns <- vapply(display, is.numeric, logical(1))
  display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
  print(display, row.names = FALSE)
  cat("  Ordinary chi-square LRT: not authorized; bootstrap: not implemented.\n")
  invisible(x)
}

print.mfrmr_tam_dimensionality_pilot_matrix <- function(x,
                                                         digits = 6L,
                                                         ...) {
  cat("mfrmr 0.2.3 TAM dimensionality pilot matrix\n")
  cat("  Specification:", x$specification, "\n")
  cat("  Contract:", x$contract_version, "\n")
  cat("  Scenarios:", nrow(x$scenarios), "| fits:", nrow(x$fits), "\n")
  cat("  Failed fits:", sum(x$fits$ConvergenceStatus == "fail"),
      "| warnings:", nrow(x$warnings), "\n")
  cat("  Status:", x$status, "| selection authorized: FALSE\n")
  display <- x$stability
  numeric_columns <- vapply(display, is.numeric, logical(1))
  display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
  print(display, row.names = FALSE)
  cat("  Numeric integration and dimensionality criteria remain unfrozen.\n")
  invisible(x)
}

print.mfrmr_tam_dimensionality_qmc_repeat_audit <- function(x,
                                                             digits = 6L,
                                                             ...) {
  cat("mfrmr 0.2.3 TAM deterministic-QMC repeat audit\n")
  cat("  Scenario:", x$manifest$ScenarioId,
      "| snodes:", x$integration$SNodes, "\n")
  display <- x$summary
  numeric_columns <- vapply(display, is.numeric, logical(1))
  display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
  print(display, row.names = FALSE)
  cat("  Status:", x$status, "| selection authorized: FALSE\n")
  invisible(x)
}

print.mfrmr_tam_dimensionality_stochastic_audit <- function(x,
                                                             digits = 6L,
                                                             ...) {
  cat("mfrmr 0.2.3 TAM stochastic-integration audit\n")
  cat("  Scenario:", x$manifest$ScenarioId,
      "| snodes:", x$integration_grid$SNodes[1],
      "| seeds:", nrow(x$integration_grid), "\n")
  display <- x$model_stability
  numeric_columns <- vapply(display, is.numeric, logical(1))
  display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
  print(display, row.names = FALSE)
  print(x$pairwise_stability, row.names = FALSE)
  cat("  Status:", x$status, "| selection authorized: FALSE\n")
  invisible(x)
}
