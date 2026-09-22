# Repository-only sparse-design audit for two many-facet GPCM slope actions.
#
# This file extends the p3a population projection. It asks whether an observed
# Rater-by-Criterion graph retains enough cycles to distinguish the implemented
# complete-predictor action from a loading-only action. The finite-sample part
# is an optimistic known-ability oracle, not a fitted JML or MML comparison.

mfrmr_gsab_require_support <- function() {
  required <- c(
    "mfrmr_gsap_actions", "mfrmr_gsap_assert", "mfrmr_gsap_design",
    "mfrmr_gsap_hermite_normal", "mfrmr_gsap_kl",
    "mfrmr_gsap_pack", "mfrmr_gsap_parameters",
    "mfrmr_gsap_probabilities", "mfrmr_gsap_scenarios",
    "mfrmr_gsap_unpack"
  )
  support_environment <- environment(mfrmr_gsab_require_support)
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
      "Source gpcm-slope-action-projection-p3a-0.2.3.R before this audit. ",
      "Missing: ", paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gsab_designs <- function() {
  edge_table <- function(rater, criterion) {
    data.frame(
      RaterIndex = as.integer(rater),
      CriterionIndex = as.integer(criterion),
      stringsAsFactors = FALSE
    )
  }
  list(
    complete = edge_table(
      rep(seq_len(4L), times = 4L),
      rep(seq_len(4L), each = 4L)
    ),
    balanced_cycle = edge_table(
      c(1, 1, 2, 2, 3, 3, 4, 4),
      c(1, 2, 2, 3, 3, 4, 4, 1)
    ),
    localized_cycle = edge_table(
      c(1, 1, 2, 2, 2, 3, 3, 4),
      c(1, 2, 1, 2, 3, 3, 4, 4)
    ),
    connected_tree = edge_table(
      c(1, 1, 2, 2, 3, 3, 4),
      c(1, 2, 1, 3, 3, 4, 4)
    )
  )
}

mfrmr_gsab_validate_edges <- function(edges) {
  edges <- as.data.frame(edges, stringsAsFactors = FALSE)
  mfrmr_gsap_assert(
    identical(names(edges), c("RaterIndex", "CriterionIndex")),
    "Edges must contain `RaterIndex` and `CriterionIndex` in that order."
  )
  edges[] <- lapply(edges, as.integer)
  mfrmr_gsap_assert(
    nrow(edges) >= 1L &&
      all(edges$RaterIndex %in% seq_len(4L)) &&
      all(edges$CriterionIndex %in% seq_len(4L)) &&
      !anyDuplicated(edges),
    "Edges must be unique pairs from the fixed four-by-four design."
  )
  mfrmr_gsap_assert(
    identical(sort(unique(edges$RaterIndex)), seq_len(4L)) &&
      identical(sort(unique(edges$CriterionIndex)), seq_len(4L)),
    "Every Rater and Criterion must appear in the sparse audit."
  )
  edges
}

mfrmr_gsab_graph_summary <- function(edges) {
  edges <- mfrmr_gsab_validate_edges(edges)
  adjacency <- matrix(FALSE, nrow = 8L, ncol = 8L)
  for (edge_index in seq_len(nrow(edges))) {
    rater_vertex <- edges$RaterIndex[edge_index]
    criterion_vertex <- 4L + edges$CriterionIndex[edge_index]
    adjacency[rater_vertex, criterion_vertex] <- TRUE
    adjacency[criterion_vertex, rater_vertex] <- TRUE
  }
  unseen <- seq_len(8L)
  components <- 0L
  while (length(unseen) > 0L) {
    components <- components + 1L
    frontier <- unseen[1L]
    visited <- integer()
    while (length(frontier) > 0L) {
      vertex <- frontier[1L]
      frontier <- frontier[-1L]
      if (vertex %in% visited) next
      visited <- c(visited, vertex)
      neighbours <- which(adjacency[vertex, ])
      frontier <- unique(c(frontier, setdiff(neighbours, visited)))
    }
    unseen <- setdiff(unseen, visited)
  }
  degrees <- rowSums(adjacency)
  data.frame(
    EdgeCount = nrow(edges),
    Components = components,
    Connected = components == 1L,
    CycleRank = nrow(edges) - 8L + components,
    MinimumDegree = min(degrees),
    MaximumDegree = max(degrees),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsab_edge_rows <- function(theta, edges) {
  edges <- mfrmr_gsab_validate_edges(edges)
  design <- mfrmr_gsap_design(theta)
  observed_key <- paste(edges$RaterIndex, edges$CriterionIndex, sep = "::")
  design_key <- paste(design$RaterIndex, design$CriterionIndex, sep = "::")
  rows <- which(design_key %in% observed_key)
  mfrmr_gsap_assert(
    length(rows) == length(theta) * nrow(edges),
    "Observed-edge row construction did not preserve the fixed design."
  )
  rows
}

mfrmr_gsab_probabilities <- function(theta, parameters, action, edges) {
  probabilities <- mfrmr_gsap_probabilities(theta, parameters, action)
  probabilities[mfrmr_gsab_edge_rows(theta, edges), , drop = FALSE]
}

mfrmr_gsab_additive_coordinates <- function(edges, target) {
  edges <- mfrmr_gsab_validate_edges(edges)
  target <- as.numeric(target)
  mfrmr_gsap_assert(
    length(target) == nrow(edges) && all(is.finite(target)),
    "The additive target must have one finite value per observed edge."
  )
  rater_free <- vapply(seq_len(3L), function(index) {
    as.numeric(edges$RaterIndex == index) -
      as.numeric(edges$RaterIndex == 4L)
  }, numeric(nrow(edges)))
  criterion_offset <- vapply(seq_len(4L), function(index) {
    as.numeric(edges$CriterionIndex == index)
  }, numeric(nrow(edges)))
  design <- cbind(rater_free, criterion_offset)
  decomposition <- qr(design)
  mfrmr_gsap_assert(
    decomposition$rank == ncol(design),
    "The observed graph must identify sum-zero Rater and Criterion offsets."
  )
  coefficients <- qr.coef(decomposition, target)
  fitted <- as.vector(design %*% coefficients)
  list(
    severities = c(coefficients[seq_len(3L)], -sum(coefficients[seq_len(3L)])),
    criterion_offsets = coefficients[seq.int(4L, 7L)],
    maximum_residual = max(abs(target - fitted))
  )
}

mfrmr_gsab_projection_start <- function(parameters, truth_action,
                                         candidate_action, edges) {
  truth_action <- match.arg(truth_action, mfrmr_gsap_actions())
  candidate_action <- match.arg(candidate_action, mfrmr_gsap_actions())
  edges <- mfrmr_gsab_validate_edges(edges)
  slopes <- parameters$slopes
  severities <- parameters$severities
  rater <- edges$RaterIndex
  criterion <- edges$CriterionIndex
  if (identical(truth_action, "complete_predictor")) {
    additive <- mfrmr_gsab_additive_coordinates(
      edges, slopes[criterion] * severities[rater]
    )
    boundaries <- parameters$boundaries * slopes +
      additive$criterion_offsets
  } else {
    additive <- mfrmr_gsab_additive_coordinates(
      edges, severities[rater] / slopes[criterion]
    )
    boundaries <- parameters$boundaries / slopes +
      additive$criterion_offsets
  }
  list(
    parameters = mfrmr_gsap_parameters(
      slopes, additive$severities, boundaries
    ),
    maximum_additive_residual = additive$maximum_residual
  )
}

mfrmr_gsab_project <- function(parameters, truth_action, candidate_action,
                               edges, points = 31L) {
  truth_action <- match.arg(truth_action, mfrmr_gsap_actions())
  candidate_action <- match.arg(candidate_action, mfrmr_gsap_actions())
  edges <- mfrmr_gsab_validate_edges(edges)
  quadrature <- mfrmr_gsap_hermite_normal(points)
  truth <- mfrmr_gsab_probabilities(
    quadrature$nodes, parameters, truth_action, edges
  )
  row_weights <- rep(quadrature$weights, times = nrow(edges)) / nrow(edges)
  start_result <- mfrmr_gsab_projection_start(
    parameters, truth_action, candidate_action, edges
  )
  start <- mfrmr_gsap_pack(start_result$parameters)
  objective <- function(vector) {
    candidate_parameters <- mfrmr_gsap_unpack(
      vector,
      criterion_count = length(parameters$slopes),
      rater_count = length(parameters$severities),
      transition_count = ncol(parameters$boundaries)
    )
    candidate <- mfrmr_gsab_probabilities(
      quadrature$nodes, candidate_parameters, candidate_action, edges
    )
    mfrmr_gsap_kl(truth, candidate, row_weights)
  }
  start_kl <- objective(start)
  if (start_kl < 1e-14) {
    fitted_vector <- start
    projected_kl <- start_kl
    convergence <- 0L
    evaluations <- 1L
  } else {
    optimization <- stats::optim(
      par = start,
      fn = objective,
      method = "BFGS",
      control = list(maxit = 1000L, reltol = 1e-12)
    )
    fitted_vector <- optimization$par
    projected_kl <- objective(fitted_vector)
    convergence <- as.integer(optimization$convergence)
    evaluations <- as.integer(optimization$counts[["function"]])
  }
  fitted_parameters <- mfrmr_gsap_unpack(
    fitted_vector,
    criterion_count = length(parameters$slopes),
    rater_count = length(parameters$severities),
    transition_count = ncol(parameters$boundaries)
  )
  evaluation_theta <- seq(-4, 4, length.out = 161L)
  truth_evaluation <- mfrmr_gsab_probabilities(
    evaluation_theta, parameters, truth_action, edges
  )
  fitted_evaluation <- mfrmr_gsab_probabilities(
    evaluation_theta, fitted_parameters, candidate_action, edges
  )
  list(
    truth_action = truth_action,
    candidate_action = candidate_action,
    start_kl = start_kl,
    projected_kl = projected_kl,
    maximum_probability_difference = max(abs(
      truth_evaluation - fitted_evaluation
    )),
    maximum_additive_residual = start_result$maximum_additive_residual,
    convergence = convergence,
    evaluations = evaluations,
    fitted_parameters = fitted_parameters
  )
}

mfrmr_gsab_oracle_selection <- function(parameters, projection, edges,
                                         sample_sizes = c(50L, 100L, 250L),
                                         replications = 400L,
                                         seed = 41031L) {
  edges <- mfrmr_gsab_validate_edges(edges)
  sample_sizes <- sort(unique(as.integer(sample_sizes)))
  replications <- as.integer(replications)[1L]
  mfrmr_gsap_assert(
    length(sample_sizes) >= 1L && all(sample_sizes >= 1L) &&
      replications >= 1L,
    "Oracle sampling requires positive sample sizes and replications."
  )
  if (projection$projected_kl < 1e-12 &&
      projection$maximum_probability_difference < 1e-6) {
    return(data.frame(
      SampleSize = sample_sizes,
      Replications = replications,
      TruthSelectionRate = NA_real_,
      MonteCarloSE = NA_real_,
      TieRate = NA_real_,
      MeanLogLikelihoodAdvantagePerResponse = NA_real_,
      SelectionStatus = "not_identifiable_on_observed_edges",
      stringsAsFactors = FALSE
    ))
  }
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
  maximum_n <- max(sample_sizes)
  person_count <- maximum_n * replications
  theta <- stats::rnorm(person_count)
  truth <- mfrmr_gsab_probabilities(
    theta, parameters, projection$truth_action, edges
  )
  candidate <- mfrmr_gsab_probabilities(
    theta, projection$fitted_parameters, projection$candidate_action, edges
  )
  uniforms <- stats::runif(nrow(truth))
  category <- rep(1L, nrow(truth))
  cumulative <- numeric(nrow(truth))
  for (score_index in seq_len(ncol(truth) - 1L)) {
    cumulative <- cumulative + truth[, score_index]
    category <- category + as.integer(uniforms > cumulative)
  }
  selected <- cbind(seq_len(nrow(truth)), category)
  row_advantage <- log(truth[selected]) - log(candidate[selected])
  person_advantage <- rowSums(matrix(
    row_advantage, nrow = person_count, ncol = nrow(edges)
  ))
  replication_advantage <- matrix(
    person_advantage, nrow = maximum_n, ncol = replications
  )
  rows <- lapply(sample_sizes, function(sample_size) {
    total <- colSums(
      replication_advantage[seq_len(sample_size), , drop = FALSE]
    )
    selected_truth <- total > 0
    tied <- total == 0
    rate <- mean(selected_truth) + 0.5 * mean(tied)
    data.frame(
      SampleSize = sample_size,
      Replications = replications,
      TruthSelectionRate = rate,
      MonteCarloSE = sqrt(rate * (1 - rate) / replications),
      TieRate = mean(tied),
      MeanLogLikelihoodAdvantagePerResponse =
        mean(total) / (sample_size * nrow(edges)),
      SelectionStatus = "known_ability_fixed_parameter_oracle",
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_run_gpcm_slope_action_sparse_oracle <- function() {
  mfrmr_gsab_require_support()
  designs <- mfrmr_gsab_designs()
  parameters <- mfrmr_gsap_scenarios()$moderate_crossed$parameters
  projection_rows <- list()
  structural_rows <- list()
  fitted_q41 <- list()
  row_index <- 0L
  for (design_name in names(designs)) {
    edges <- designs[[design_name]]
    graph <- mfrmr_gsab_graph_summary(edges)
    structural_rows[[length(structural_rows) + 1L]] <- cbind(
      data.frame(Design = design_name, stringsAsFactors = FALSE),
      graph
    )
    for (points in c(31L, 41L)) {
      for (truth_index in seq_along(mfrmr_gsap_actions())) {
        truth_action <- mfrmr_gsap_actions()[truth_index]
        candidate_action <- setdiff(mfrmr_gsap_actions(), truth_action)
        projection <- mfrmr_gsab_project(
          parameters, truth_action, candidate_action, edges, points
        )
        row_index <- row_index + 1L
        projection_rows[[row_index]] <- data.frame(
          Design = design_name,
          Nodes = points,
          TruthAction = truth_action,
          CandidateAction = candidate_action,
          EdgeCount = nrow(edges),
          CycleRank = graph$CycleRank,
          MaximumAdditiveResidual = projection$maximum_additive_residual,
          StartKLPerResponse = projection$start_kl,
          ProjectedKLPerResponse = projection$projected_kl,
          MaxProbabilityDifference = projection$maximum_probability_difference,
          OptimizerConvergence = projection$convergence,
          FunctionEvaluations = projection$evaluations,
          stringsAsFactors = FALSE
        )
        if (points == 41L) {
          fit_key <- paste(design_name, truth_action, sep = "::")
          fitted_q41[[fit_key]] <- projection
        }
      }
    }
  }
  projections <- do.call(rbind, projection_rows)
  structure <- do.call(rbind, structural_rows)
  rownames(projections) <- NULL
  rownames(structure) <- NULL
  q31 <- projections[projections$Nodes == 31L, , drop = FALSE]
  q41 <- projections[projections$Nodes == 41L, , drop = FALSE]
  projection_key <- function(table) {
    paste(table$Design, table$TruthAction, sep = "::")
  }
  q41 <- q41[match(projection_key(q31), projection_key(q41)), , drop = FALSE]
  stability <- data.frame(
    Design = q31$Design,
    TruthAction = q31$TruthAction,
    ProjectedKLAbsQ41MinusQ31 = abs(
      q41$ProjectedKLPerResponse - q31$ProjectedKLPerResponse
    ),
    MaxProbabilityDifferenceAbsQ41MinusQ31 = abs(
      q41$MaxProbabilityDifference - q31$MaxProbabilityDifference
    ),
    stringsAsFactors = FALSE
  )
  simulation_rows <- list()
  simulation_index <- 0L
  for (design_index in seq_along(designs)) {
    design_name <- names(designs)[design_index]
    edges <- designs[[design_name]]
    for (truth_index in seq_along(mfrmr_gsap_actions())) {
      truth_action <- mfrmr_gsap_actions()[truth_index]
      fit_key <- paste(design_name, truth_action, sep = "::")
      selection <- mfrmr_gsab_oracle_selection(
        parameters,
        fitted_q41[[fit_key]],
        edges,
        seed = 41000L + 100L * design_index + truth_index
      )
      selection$Design <- design_name
      selection$TruthAction <- truth_action
      selection$CandidateAction <- setdiff(
        mfrmr_gsap_actions(), truth_action
      )
      simulation_index <- simulation_index + 1L
      simulation_rows[[simulation_index]] <- selection[, c(
        "Design", "TruthAction", "CandidateAction", "SampleSize",
        "Replications", "TruthSelectionRate", "MonteCarloSE", "TieRate",
        "MeanLogLikelihoodAdvantagePerResponse", "SelectionStatus"
      )]
    }
  }
  simulation <- do.call(rbind, simulation_rows)
  rownames(simulation) <- NULL
  list(
    status = "gpcm_slope_action_sparse_known_ability_oracle_complete",
    estimator_scope = "known_ability_fixed_parameter_oracle_not_jml_or_mml",
    parameters = parameters,
    structure = structure,
    projections = projections,
    stability = stability,
    simulation = simulation,
    public_family_added = FALSE,
    model_selection_enabled = FALSE,
    readiness_overridden = FALSE,
    practical_threshold_frozen = FALSE,
    release_authorized = FALSE
  )
}
