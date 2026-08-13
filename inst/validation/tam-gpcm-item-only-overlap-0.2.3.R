# Repository-only TAM comparison for the GPCM MML kernel.
#
# TAM estimates GPCM slopes with tam.mml.2pl(), but does not estimate slopes
# in tam.mml.mfr().  This runner therefore compares the exact item-only
# overlap.  It must not be used as evidence for the combined rater-plus-slope
# model fitted by mfrmr.

mfrmr_tgio_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_tgio_require <- function() {
  for (package in c("mfrmr", "TAM")) {
    mfrmr_tgio_assert(
      requireNamespace(package, quietly = TRUE),
      paste0("The TAM GPCM overlap requires `", package, "`.")
    )
  }
  invisible(TRUE)
}

mfrmr_tgio_plan <- function() {
  data.frame(
    RunId = c("item_gpcm_q031", "item_gpcm_q041"),
    Nodes = c(31L, 41L),
    Model = "GPCM",
    Estimator = "MML",
    Scope = "item_only_no_rater_facet",
    TAMRoute = "tam.mml.2pl",
    MfrmrSlopeOwner = "Criterion",
    TAMLatentVariance = "fixed_one",
    MfrmrIdentification =
      "free_population_geometric_mean_one_relative_slopes",
    IntegrationComparison =
      "same_continuous_normal_target_different_fixed_grid_rules",
    TAMStopping = "conv=1e-6;convD=1e-8;convM=1e-6;Msteps=20",
    stringsAsFactors = FALSE
  )
}

mfrmr_tgio_data <- function() {
  mfrmr_tgio_require()
  data_environment <- new.env(parent = emptyenv())
  utils::data("data.gpcm", package = "TAM", envir = data_environment)
  response <- get("data.gpcm", envir = data_environment, inherits = FALSE)
  response <- as.data.frame(response, stringsAsFactors = FALSE)
  item_names <- names(response)
  item_count <- ncol(response)
  person_count <- nrow(response)
  long <- data.frame(
    Person = rep(sprintf("P%03d", seq_len(person_count)), times = item_count),
    Criterion = rep(item_names, each = person_count),
    Score = as.integer(unlist(response, use.names = FALSE)),
    stringsAsFactors = FALSE
  )
  category_values <- sort(unique(long$Score))
  mfrmr_tgio_assert(
    identical(category_values, seq.int(0L, max(category_values))) &&
      !anyNA(long),
    "The TAM GPCM fixture must have complete consecutive categories from zero."
  )
  list(response = response, long = long, items = item_names)
}

mfrmr_tgio_capture <- function(expression) {
  warnings <- character(0L)
  messages <- character(0L)
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

mfrmr_tgio_fit_tam <- function(response, nodes) {
  nodes <- as.integer(nodes)[1L]
  mfrmr_tgio_assert(nodes %in% c(31L, 41L), "Use q=31 or q=41.")
  mfrmr_tgio_capture(TAM::tam.mml.2pl(
    resp = response,
    irtmodel = "GPCM",
    est.variance = FALSE,
    control = list(
      nodes = seq(-6, 6, length.out = nodes),
      snodes = 0L,
      QMC = TRUE,
      maxiter = 1000L,
      conv = 1e-6,
      convD = 1e-8,
      convM = 1e-6,
      Msteps = 20L,
      progress = FALSE
    ),
    verbose = FALSE
  ))
}

mfrmr_tgio_fit_mfrmr <- function(long, nodes) {
  nodes <- as.integer(nodes)[1L]
  mfrmr_tgio_assert(nodes %in% c(31L, 41L), "Use q=31 or q=41.")
  mfrmr_tgio_capture(mfrmr::fit_mfrm(
    long,
    person = "Person",
    facets = "Criterion",
    score = "Score",
    method = "MML",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    quad_points = nodes,
    maxit = 500L,
    reltol = 1e-10
  ))
}

mfrmr_tgio_tam_map <- function(fit, items) {
  mfrmr_tgio_assert(
    inherits(fit, "tam.mml") && identical(fit$irtmodel, "GPCM"),
    "Expected a TAM GPCM MML fit."
  )
  category_count <- dim(fit$B)[2L] - 1L
  slopes <- as.numeric(fit$B[, 2L, 1L])
  names(slopes) <- dimnames(fit$B)[[1L]]
  slopes <- slopes[items]
  mfrmr_tgio_assert(
    length(slopes) == length(items) && all(is.finite(slopes)) &&
      all(slopes > 0),
    "TAM did not return one positive slope for every item."
  )
  for (category in seq_len(category_count)) {
    implied <- as.numeric(fit$B[items, category + 1L, 1L]) / category
    mfrmr_tgio_assert(
      max(abs(implied - slopes)) < 1e-10,
      "TAM B is not a one-slope-per-item GPCM design."
    )
  }

  xsi <- matrix(
    NA_real_, nrow = length(items), ncol = category_count,
    dimnames = list(items, paste0("Step_", seq_len(category_count)))
  )
  for (item in items) {
    parameter_names <- paste0(item, "_Cat", seq_len(category_count))
    positions <- match(parameter_names, rownames(fit$xsi))
    mfrmr_tgio_assert(
      !anyNA(positions),
      paste0("TAM xsi rows are incomplete for item `", item, "`.")
    )
    xsi[item, ] <- as.numeric(fit$xsi$xsi[positions])
  }

  scale_multiplier <- exp(mean(log(slopes)))
  relative_slopes <- slopes / scale_multiplier
  uncentered_thresholds <- sweep(xsi, 1L, slopes, "/") * scale_multiplier
  population_mean <- -mean(uncentered_thresholds)
  thresholds <- uncentered_thresholds + population_mean
  criterion_locations <- rowMeans(thresholds)
  steps <- thresholds - criterion_locations

  list(
    slopes = relative_slopes,
    criterion = criterion_locations,
    steps = steps,
    thresholds = thresholds,
    population_mean = population_mean,
    population_variance =
      scale_multiplier^2 * as.numeric(fit$variance[1L, 1L]),
    scale_multiplier = scale_multiplier,
    tam_slopes = slopes,
    tam_xsi = xsi
  )
}

mfrmr_tgio_mfrmr_map <- function(fit, items) {
  slope_table <- as.data.frame(fit$slopes)
  slopes <- setNames(
    slope_table$OptimizerEstimate,
    slope_table$SlopeFacet
  )[items]
  criterion_table <- as.data.frame(fit$facets$others)
  criterion <- setNames(
    criterion_table$Estimate[criterion_table$Facet == "Criterion"],
    criterion_table$Level[criterion_table$Facet == "Criterion"]
  )[items]
  step_table <- as.data.frame(fit$steps)
  step_count <- length(unique(step_table$Step))
  steps <- matrix(
    NA_real_, nrow = length(items), ncol = step_count,
    dimnames = list(items, paste0("Step_", seq_len(step_count)))
  )
  for (item in items) {
    rows <- step_table$StepFacet == item
    values <- setNames(step_table$Estimate[rows], step_table$Step[rows])
    steps[item, ] <- values[colnames(steps)]
  }
  mfrmr_tgio_assert(
    all(is.finite(c(slopes, criterion, steps))),
    "mfrmr did not return complete finite optimizer coordinates."
  )
  list(
    slopes = slopes,
    criterion = criterion,
    steps = steps,
    thresholds = steps + criterion,
    population_mean = unname(fit$population$coefficients[1L]),
    population_variance = as.numeric(fit$population$sigma2)
  )
}

mfrmr_tgio_softmax <- function(logits) {
  shifted <- logits - max(logits)
  weights <- exp(shifted)
  weights / sum(weights)
}

mfrmr_tgio_probability_audit <- function(tam_map, mfrmr_map) {
  theta_tam <- seq(-4, 4, by = 0.25)
  category_count <- ncol(tam_map$tam_xsi)
  maximum_map_identity_difference <- 0
  maximum_fitted_difference <- 0
  for (item in names(tam_map$tam_slopes)) {
    tam_slope <- tam_map$tam_slopes[[item]]
    relative_slope <- tam_map$slopes[[item]]
    for (theta in theta_tam) {
      theta_mapped <-
        tam_map$scale_multiplier * theta + tam_map$population_mean
      tam_logits <- c(
        0,
        seq_len(category_count) * tam_slope * theta -
          cumsum(tam_map$tam_xsi[item, ])
      )
      mapped_logits <- c(
        0,
        seq_len(category_count) * relative_slope * theta_mapped -
          relative_slope * cumsum(tam_map$thresholds[item, ])
      )
      fitted_logits <- c(
        0,
        seq_len(category_count) * mfrmr_map$slopes[[item]] * theta_mapped -
          mfrmr_map$slopes[[item]] *
            cumsum(mfrmr_map$thresholds[item, ])
      )
      tam_probability <- mfrmr_tgio_softmax(tam_logits)
      maximum_map_identity_difference <- max(
        maximum_map_identity_difference,
        abs(tam_probability - mfrmr_tgio_softmax(mapped_logits))
      )
      maximum_fitted_difference <- max(
        maximum_fitted_difference,
        abs(tam_probability - mfrmr_tgio_softmax(fitted_logits))
      )
    }
  }
  data.frame(
    CoordinateMapIdentityMaxAbsDifference = maximum_map_identity_difference,
    FittedProbabilityMaxAbsDifference = maximum_fitted_difference,
    ThetaTAMMinimum = min(theta_tam),
    ThetaTAMMaximum = max(theta_tam),
    ThetaGridPoints = length(theta_tam),
    stringsAsFactors = FALSE
  )
}

mfrmr_tgio_parameter_table <- function(tam_map, mfrmr_map, nodes) {
  item_rows <- function(block, tam_values, mfrmr_values) {
    data.frame(
      Nodes = nodes,
      Block = block,
      Item = names(tam_values),
      Step = NA_character_,
      TAMMapped = as.numeric(tam_values),
      MfrmrOptimizer = as.numeric(mfrmr_values[names(tam_values)]),
      stringsAsFactors = FALSE
    )
  }
  slope <- item_rows("Slope", tam_map$slopes, mfrmr_map$slopes)
  criterion <- item_rows(
    "Criterion", tam_map$criterion, mfrmr_map$criterion
  )
  step <- do.call(rbind, lapply(rownames(tam_map$steps), function(item) {
    data.frame(
      Nodes = nodes,
      Block = "Step",
      Item = item,
      Step = colnames(tam_map$steps),
      TAMMapped = as.numeric(tam_map$steps[item, ]),
      MfrmrOptimizer = as.numeric(mfrmr_map$steps[item, ]),
      stringsAsFactors = FALSE
    )
  }))
  population <- data.frame(
    Nodes = nodes,
    Block = "Population",
    Item = c("Mean", "Variance"),
    Step = NA_character_,
    TAMMapped = c(
      tam_map$population_mean, tam_map$population_variance
    ),
    MfrmrOptimizer = c(
      mfrmr_map$population_mean, mfrmr_map$population_variance
    ),
    stringsAsFactors = FALSE
  )
  table <- rbind(slope, criterion, step, population)
  table$Difference <- table$MfrmrOptimizer - table$TAMMapped
  table$AbsoluteDifference <- abs(table$Difference)
  rownames(table) <- NULL
  table
}

mfrmr_run_tam_gpcm_item_only_overlap <- function() {
  mfrmr_tgio_require()
  plan <- mfrmr_tgio_plan()
  fixture <- mfrmr_tgio_data()
  runs <- vector("list", nrow(plan))
  for (run_index in seq_len(nrow(plan))) {
    nodes <- plan$Nodes[[run_index]]
    tam_capture <- mfrmr_tgio_fit_tam(fixture$response, nodes)
    mfrmr_capture <- mfrmr_tgio_fit_mfrmr(fixture$long, nodes)
    tam_fit <- tam_capture$value
    mfrmr_fit <- mfrmr_capture$value
    tam_map <- mfrmr_tgio_tam_map(tam_fit, fixture$items)
    mfrmr_map <- mfrmr_tgio_mfrmr_map(mfrmr_fit, fixture$items)
    parameters <- mfrmr_tgio_parameter_table(
      tam_map, mfrmr_map, nodes
    )
    probability <- mfrmr_tgio_probability_audit(tam_map, mfrmr_map)
    fit_summary <- as.data.frame(mfrmr_fit$summary)
    inference_evidence <- as.data.frame(summary(mfrmr_fit)$inference_evidence)
    local_state <- inference_evidence$State[
      inference_evidence$EvidenceArea == "local_estimability"
    ]
    runs[[run_index]] <- list(
      summary = data.frame(
        RunId = plan$RunId[[run_index]],
        Nodes = nodes,
        TAMIterations = as.integer(tam_fit$iter),
        MfrmrIterations = as.integer(fit_summary$Iterations),
        TAMDeviance = as.numeric(tam_fit$deviance),
        MfrmrDeviance = as.numeric(fit_summary$Deviance),
        DevianceSignedDifference =
          as.numeric(fit_summary$Deviance - tam_fit$deviance),
        ParameterMaxAbsDifference = max(parameters$AbsoluteDifference),
        SlopeMaxAbsDifference = max(
          parameters$AbsoluteDifference[parameters$Block == "Slope"]
        ),
        ThresholdMaxAbsDifference = max(abs(
          mfrmr_map$thresholds - tam_map$thresholds
        )),
        CoordinateMapIdentityMaxAbsDifference =
          probability$CoordinateMapIdentityMaxAbsDifference,
        FittedProbabilityMaxAbsDifference =
          probability$FittedProbabilityMaxAbsDifference,
        TAMWarningCount = length(tam_capture$warnings),
        TAMMessageCount = length(tam_capture$messages),
        MfrmrWarningCount = length(mfrmr_capture$warnings),
        MfrmrMessageCount = length(mfrmr_capture$messages),
        MfrmrTerminalGradientSupNorm =
          as.numeric(fit_summary$TerminalGradientSupNorm),
        MfrmrLocalEstimability = local_state,
        MfrmrInferenceReady = isTRUE(
          mfrmr_fit$readiness$fit$InferenceReady
        ),
        stringsAsFactors = FALSE
      ),
      parameters = parameters,
      probability = probability,
      tam_map = tam_map,
      mfrmr_map = mfrmr_map,
      tam_fit = tam_fit,
      mfrmr_fit = mfrmr_fit
    )
  }

  summaries <- do.call(rbind, lapply(runs, `[[`, "summary"))
  parameters <- do.call(rbind, lapply(runs, `[[`, "parameters"))
  q31 <- runs[[1L]]
  q41 <- runs[[2L]]
  stability <- data.frame(
    Engine = c("TAM_mapped", "mfrmr_optimizer"),
    SlopeMaxAbsQ41MinusQ31 = c(
      max(abs(q41$tam_map$slopes - q31$tam_map$slopes)),
      max(abs(q41$mfrmr_map$slopes - q31$mfrmr_map$slopes))
    ),
    ThresholdMaxAbsQ41MinusQ31 = c(
      max(abs(q41$tam_map$thresholds - q31$tam_map$thresholds)),
      max(abs(q41$mfrmr_map$thresholds - q31$mfrmr_map$thresholds))
    ),
    PopulationVarianceAbsQ41MinusQ31 = c(
      abs(q41$tam_map$population_variance -
            q31$tam_map$population_variance),
      abs(q41$mfrmr_map$population_variance -
            q31$mfrmr_map$population_variance)
    ),
    DevianceAbsQ41MinusQ31 = c(
      abs(q41$summary$TAMDeviance - q31$summary$TAMDeviance),
      abs(q41$summary$MfrmrDeviance - q31$summary$MfrmrDeviance)
    ),
    stringsAsFactors = FALSE
  )

  list(
    status = "bounded_item_only_gpcm_overlap_complete",
    plan = plan,
    summaries = summaries,
    parameters = parameters,
    stability = stability,
    comparison_scope = "item_only_gpcm_mml_projection",
    full_many_facet_gpcm_compared = FALSE,
    common_continuous_likelihood_target = TRUE,
    identical_finite_quadrature_rule = FALSE,
    cross_engine_se_comparison_available = FALSE,
    inference_readiness_overridden = FALSE,
    comparison_tolerance_frozen = FALSE,
    release_authorized = FALSE,
    runs = runs
  )
}
