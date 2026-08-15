# Repository-only P2 additive RSM/PCM adversarial fixtures for ConQuest work.
#
# These deterministic fixtures and mathematical oracles are constructed before
# external output exists. The file does not launch ConQuest, fit mfrmr, select
# numerical tolerances, or authorize a comparison.

mfrmr_cq_p2_specification <-
  "0.2.3-conquest-p2-additive-adversarial-fixtures-v1"
mfrmr_cq_p2_contract <- "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"

mfrmr_cq_p2_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2_require_registry <- function() {
  target <- environment(mfrmr_cq_p2_require_registry)
  available <- exists(
    "mfrmr_cq_ssr_registry", envir = target, mode = "function",
    inherits = TRUE
  )
  mfrmr_cq_p2_assert(
    available,
    "Source the successor semantic registry before the P2 fixtures."
  )
  invisible(TRUE)
}

mfrmr_cq_p2_truth <- function() {
  rater <- c(R1 = -0.45, R2 = -0.15, R3 = 0.20, R4 = 0.40)
  criterion <- c(C1 = -0.30, C2 = 0.05, C3 = 0.25)
  rsm_steps <- c(S1 = -0.90, S2 = 0.10, S3 = 0.80)
  pcm_steps <- rbind(
    C1 = c(S1 = -1.00, S2 = 0.20, S3 = 0.80),
    C2 = c(S1 = -0.80, S2 = -0.10, S3 = 0.90),
    C3 = c(S1 = -1.20, S2 = 0.40, S3 = 0.80)
  )
  mfrmr_cq_p2_assert(
    abs(sum(rater)) < 1e-15 && abs(sum(criterion)) < 1e-15 &&
      abs(sum(rsm_steps)) < 1e-15 &&
      max(abs(rowSums(pcm_steps))) < 1e-15,
    "The P2 generating coordinates must satisfy every sum-zero constraint."
  )
  list(
    PopulationIntercept = 0.10,
    PopulationSlope = 0.45,
    PopulationVariance = 0.70,
    Rater = rater,
    Criterion = criterion,
    RsmSteps = rsm_steps,
    PcmSteps = pcm_steps
  )
}

mfrmr_cq_p2_complete_grid <- function() {
  grid <- expand.grid(
    PersonIndex = seq_len(48L),
    RaterIndex = seq_len(4L),
    CriterionIndex = seq_len(3L),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  grid <- grid[order(
    grid$PersonIndex, grid$RaterIndex, grid$CriterionIndex
  ), , drop = FALSE]
  rownames(grid) <- NULL
  grid$Person <- sprintf("P%03d", grid$PersonIndex)
  grid$X <- ifelse(grid$PersonIndex <= 24L, -1, 1)
  grid$Rater <- paste0("R", grid$RaterIndex)
  grid$Criterion <- paste0("C", grid$CriterionIndex)
  grid$Response <- as.integer(
    (grid$PersonIndex + 2L * grid$RaterIndex +
       3L * grid$CriterionIndex) %% 4L
  )
  grid[, c(
    "Person", "PersonIndex", "X", "Rater", "RaterIndex",
    "Criterion", "CriterionIndex", "Response"
  ), drop = FALSE]
}

mfrmr_cq_p2_assignment <- function(design_case, grid) {
  person <- grid$PersonIndex
  rater <- grid$RaterIndex
  if (design_case == "connected_sparse_multiple_independent_bridges") {
    group <- ((person - 1L) %/% 12L) + 1L
    pair <- list(c(1L, 2L), c(2L, 3L), c(3L, 4L), c(4L, 1L))
    return(vapply(seq_along(person), function(index) {
      rater[index] %in% pair[[group[index]]]
    }, logical(1L)))
  }
  if (design_case == "connected_sparse_one_weak_bridge") {
    return(
      (person <= 10L & rater %in% c(1L, 2L)) |
        (person >= 11L & person <= 20L & rater %in% c(2L, 3L)) |
        (person >= 21L & person <= 30L & rater %in% c(3L, 1L)) |
        (person >= 31L & person <= 32L & rater %in% c(3L, 4L)) |
        (person >= 33L & rater == 4L)
    )
  }
  if (design_case == "connected_sparse_unequal_rater_workload") {
    return(
      rater == 1L |
        (rater == 2L & person <= 36L) |
        (rater == 3L & person >= 13L & person <= 36L) |
        (rater == 4L & person >= 25L)
    )
  }
  if (design_case == "two_disconnected_rater_criterion_components") {
    return(
      (person <= 24L & rater %in% c(1L, 2L)) |
        (person >= 25L & rater %in% c(3L, 4L))
    )
  }
  mfrmr_cq_p2_assert(
    FALSE,
    paste0("Unregistered P2 assignment design: `", design_case, "`.")
  )
}

mfrmr_cq_p2_rare_boundary_responses <- function(data) {
  split_index <- split(
    seq_len(nrow(data)), paste(data$Rater, data$Criterion, sep = "::")
  )
  response <- integer(nrow(data))
  for (index in split_index) {
    ordered <- index[order(data$PersonIndex[index])]
    response[ordered] <- 1L + (seq_along(ordered) %% 2L)
    rater <- data$RaterIndex[ordered[1L]]
    criterion <- data$CriterionIndex[ordered[1L]]
    zero_position <- 1L + ((5L * rater + 3L * criterion - 1L) %%
                            length(ordered))
    maximum_position <- 1L + ((7L * rater + 5L * criterion + 10L) %%
                               length(ordered))
    if (maximum_position == zero_position) {
      maximum_position <- 1L + (maximum_position %% length(ordered))
    }
    response[ordered[zero_position]] <- 0L
    response[ordered[maximum_position]] <- 3L
  }
  response
}

mfrmr_cq_p2_fixture <- function(registry_row_id) {
  mfrmr_cq_p2_require_registry()
  registry <- mfrmr_cq_ssr_registry()
  row <- registry[
    registry$RegistryRowId == as.character(registry_row_id)[1L], ,
    drop = FALSE
  ]
  mfrmr_cq_p2_assert(
    nrow(row) == 1L && row$Priority == "P2" &&
      row$ComparisonStratum == "additive_rsm_pcm_mml",
    "`registry_row_id` must identify one P2 additive registry row."
  )
  grid <- mfrmr_cq_p2_complete_grid()
  assignment_case <- row$DesignCase
  if (assignment_case %in% c(
    "planned_rows_absent",
    "same_cells_explicit_missing_values",
    "rare_minimum_and_maximum_categories_all_transitions_observed",
    "persons_with_nonextreme_observed_scores",
    "persons_with_minimum_or_maximum_observed_scores",
    "declared_0_to_3_support_with_category_1_globally_unused"
  )) {
    assignment_case <- "connected_sparse_multiple_independent_bridges"
  }
  observed <- mfrmr_cq_p2_assignment(assignment_case, grid)
  explicit_missing <- row$DesignCase == "same_cells_explicit_missing_values"
  if (explicit_missing) {
    data <- grid
    data$Response[!observed] <- NA_integer_
    representation <- "complete_grid_with_explicit_missing_values"
  } else {
    data <- grid[observed, , drop = FALSE]
    rownames(data) <- NULL
    representation <- "planned_observed_rows_only"
  }
  retained <- !is.na(data$Response)
  if (row$DesignCase ==
      "rare_minimum_and_maximum_categories_all_transitions_observed") {
    data$Response[retained] <- mfrmr_cq_p2_rare_boundary_responses(
      data[retained, , drop = FALSE]
    )
  }
  if (row$DesignCase ==
      "declared_0_to_3_support_with_category_1_globally_unused") {
    data$Response[retained & data$Response == 1L] <- 2L
  }
  if (row$DesignCase == "persons_with_minimum_or_maximum_observed_scores") {
    data$Response[retained & data$Person == "P001"] <- 0L
    data$Response[retained & data$Person == "P048"] <- 3L
  }
  list(
    Specification = mfrmr_cq_p2_specification,
    ContractVersion = mfrmr_cq_p2_contract,
    RegistryRowId = row$RegistryRowId,
    SemanticFixtureId = paste0(
      "mfrmr-p2-additive-",
      tolower(gsub("[^A-Za-z0-9]+", "-", row$RegistryRowId)), "-v1"
    ),
    Model = row$Family,
    DesignCase = row$DesignCase,
    ExpectedDisposition = row$ExpectedDisposition,
    Representation = representation,
    DeclaredCategories = 0:3,
    Data = data,
    Truth = mfrmr_cq_p2_truth(),
    ExternalExecutionAuthorized = FALSE,
    ComparisonPassed = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_p2_fixture_registry <- function() {
  mfrmr_cq_p2_require_registry()
  registry <- mfrmr_cq_ssr_registry()
  rows <- registry[
    registry$Priority == "P2" &
      registry$ComparisonStratum == "additive_rsm_pcm_mml", ,
    drop = FALSE
  ]
  fixtures <- lapply(rows$RegistryRowId, mfrmr_cq_p2_fixture)
  names(fixtures) <- rows$RegistryRowId
  fixtures
}

mfrmr_cq_p2_observed_data <- function(fixture) {
  data <- fixture$Data
  data <- data[!is.na(data$Response), , drop = FALSE]
  data <- data[order(
    data$PersonIndex, data$RaterIndex, data$CriterionIndex
  ), , drop = FALSE]
  rownames(data) <- NULL
  data
}

mfrmr_cq_p2_component_count <- function(levels, edges) {
  levels <- as.character(levels)
  adjacency <- stats::setNames(vector("list", length(levels)), levels)
  if (nrow(edges) > 0L) {
    for (index in seq_len(nrow(edges))) {
      left <- edges$Rater1[index]
      right <- edges$Rater2[index]
      adjacency[[left]] <- unique(c(adjacency[[left]], right))
      adjacency[[right]] <- unique(c(adjacency[[right]], left))
    }
  }
  unvisited <- levels
  components <- 0L
  while (length(unvisited) > 0L) {
    components <- components + 1L
    queue <- unvisited[1L]
    reached <- character(0)
    while (length(queue) > 0L) {
      current <- queue[1L]
      queue <- queue[-1L]
      if (current %in% reached) next
      reached <- c(reached, current)
      queue <- unique(c(queue, adjacency[[current]]))
    }
    unvisited <- setdiff(unvisited, reached)
  }
  components
}

mfrmr_cq_p2_graph_audit <- function(fixture) {
  data <- mfrmr_cq_p2_observed_data(fixture)
  levels <- paste0("R", seq_len(4L))
  pairs <- utils::combn(levels, 2L, simplify = FALSE)
  edge_rows <- lapply(pairs, function(pair) {
    left <- unique(data$Person[data$Rater == pair[1L]])
    right <- unique(data$Person[data$Rater == pair[2L]])
    data.frame(
      Rater1 = pair[1L],
      Rater2 = pair[2L],
      CommonPersons = length(intersect(left, right)),
      stringsAsFactors = FALSE
    )
  })
  all_pairs <- do.call(rbind, edge_rows)
  edges <- all_pairs[all_pairs$CommonPersons > 0L, , drop = FALSE]
  components <- mfrmr_cq_p2_component_count(levels, edges)
  bridge <- logical(nrow(edges))
  if (nrow(edges) > 0L) {
    for (index in seq_len(nrow(edges))) {
      reduced <- edges[-index, , drop = FALSE]
      bridge[index] <-
        mfrmr_cq_p2_component_count(levels, reduced) > components
    }
  }
  loads <- table(factor(data$Rater, levels = levels))
  list(
    Components = components,
    Connected = components == 1L,
    PositiveEdgeCount = nrow(edges),
    BridgeEdgeCount = sum(bridge),
    EdgeTable = transform(edges, IsBridge = bridge),
    RaterLoads = as.integer(loads),
    RaterLoadMin = min(loads),
    RaterLoadMax = max(loads),
    MinPositiveCommonPersons = if (nrow(edges) > 0L) {
      min(edges$CommonPersons)
    } else {
      0L
    }
  )
}

mfrmr_cq_p2_support_audit <- function(fixture) {
  data <- mfrmr_cq_p2_observed_data(fixture)
  counts <- table(factor(data$Response, levels = 0:3))
  person <- split(data$Response, data$Person)
  possible_max <- vapply(person, length, integer(1L)) * 3L
  score <- vapply(person, sum, integer(1L))
  data.frame(
    RegistryRowId = fixture$RegistryRowId,
    ObservedRows = nrow(data),
    Category0 = as.integer(counts[1L]),
    Category1 = as.integer(counts[2L]),
    Category2 = as.integer(counts[3L]),
    Category3 = as.integer(counts[4L]),
    Persons = length(person),
    MinimumScorePersons = sum(score == 0L),
    MaximumScorePersons = sum(score == possible_max),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2_contrast_basis <- function(levels, prefix) {
  levels <- as.integer(levels)
  basis <- rbind(diag(levels - 1L), rep(-1, levels - 1L))
  rownames(basis) <- paste0(prefix, seq_len(levels))
  colnames(basis) <- paste0(prefix, seq_len(levels - 1L))
  basis
}

mfrmr_cq_p2_matrix_contract <- function(model) {
  model <- toupper(as.character(model)[1L])
  mfrmr_cq_p2_assert(model %in% c("RSM", "PCM"),
                     "`model` must be RSM or PCM.")
  rater_basis <- mfrmr_cq_p2_contrast_basis(4L, "R")
  criterion_basis <- mfrmr_cq_p2_contrast_basis(3L, "C")
  step_basis <- mfrmr_cq_p2_contrast_basis(3L, "S")
  rows <- expand.grid(
    RaterIndex = seq_len(4L),
    CriterionIndex = seq_len(3L),
    Category = 0:3,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  rows <- rows[order(
    rows$RaterIndex, rows$CriterionIndex, rows$Category
  ), , drop = FALSE]
  rater <- t(vapply(seq_len(nrow(rows)), function(index) {
    -rows$Category[index] * rater_basis[rows$RaterIndex[index], ]
  }, numeric(3L)))
  criterion <- t(vapply(seq_len(nrow(rows)), function(index) {
    -rows$Category[index] * criterion_basis[rows$CriterionIndex[index], ]
  }, numeric(2L)))
  if (model == "RSM") {
    step <- t(vapply(seq_len(nrow(rows)), function(index) {
      category <- rows$Category[index]
      if (category == 0L) rep(0, 2L) else {
        -colSums(step_basis[seq_len(category), , drop = FALSE])
      }
    }, numeric(2L)))
    colnames(step) <- paste0("SharedStep:S", 1:2)
  } else {
    step <- matrix(0, nrow = nrow(rows), ncol = 6L)
    colnames(step) <- unlist(lapply(paste0("C", 1:3), function(criterion) {
      paste0(criterion, ":Step:S", 1:2)
    }))
    for (index in seq_len(nrow(rows))) {
      category <- rows$Category[index]
      if (category > 0L) {
        columns <- (2L * rows$CriterionIndex[index] - 1L):
          (2L * rows$CriterionIndex[index])
        step[index, columns] <-
          -colSums(step_basis[seq_len(category), , drop = FALSE])
      }
    }
  }
  colnames(rater) <- paste0("Rater:R", 1:3)
  colnames(criterion) <- paste0("Criterion:C", 1:2)
  a_matrix <- cbind(rater, criterion, step)
  row_key <- paste0(
    "R", rows$RaterIndex, "::C", rows$CriterionIndex,
    "::k", rows$Category
  )
  rownames(a_matrix) <- row_key
  c_matrix <- data.frame(
    RowKey = row_key,
    Rater = paste0("R", rows$RaterIndex),
    Criterion = paste0("C", rows$CriterionIndex),
    Category = rows$Category,
    ThetaScore = rows$Category,
    stringsAsFactors = FALSE
  )
  list(
    Model = model,
    Orientation = "conditional_log_kernel_free_coordinate_coefficient",
    A = a_matrix,
    C = c_matrix,
    ConditionalFreeDimension = ncol(a_matrix),
    PopulationFreeDimension = 3L,
    TotalExpectedFreeDimension = ncol(a_matrix) + 3L
  )
}

mfrmr_cq_p2_parameter_vector <- function(model) {
  truth <- mfrmr_cq_p2_truth()
  model <- toupper(as.character(model)[1L])
  matrix_contract <- mfrmr_cq_p2_matrix_contract(model)
  value <- c(
    truth$Rater[1:3],
    truth$Criterion[1:2],
    if (model == "RSM") {
      truth$RsmSteps[1:2]
    } else {
      as.vector(t(truth$PcmSteps[, 1:2, drop = FALSE]))
    }
  )
  names(value) <- colnames(matrix_contract$A)
  value
}

mfrmr_cq_p2_softmax <- function(log_kernel) {
  value <- as.numeric(log_kernel)
  value <- value - max(value)
  probability <- exp(value)
  probability / sum(probability)
}

mfrmr_cq_p2_probability <- function(model, theta, rater, criterion) {
  truth <- mfrmr_cq_p2_truth()
  model <- toupper(as.character(model)[1L])
  rater <- as.character(rater)[1L]
  criterion <- as.character(criterion)[1L]
  theta <- as.numeric(theta)[1L]
  mfrmr_cq_p2_assert(
    model %in% c("RSM", "PCM") && rater %in% names(truth$Rater) &&
      criterion %in% names(truth$Criterion) && is.finite(theta),
    "The probability oracle received an invalid model coordinate."
  )
  steps <- if (model == "RSM") truth$RsmSteps else {
    truth$PcmSteps[criterion, ]
  }
  category <- 0:3
  eta <- theta - truth$Rater[rater] - truth$Criterion[criterion]
  log_kernel <- category * eta - c(0, cumsum(steps))
  mfrmr_cq_p2_softmax(log_kernel)
}

mfrmr_cq_p2_matrix_probability <- function(model, theta, rater, criterion) {
  contract <- mfrmr_cq_p2_matrix_contract(model)
  parameter <- mfrmr_cq_p2_parameter_vector(model)
  selected <- contract$C$Rater == rater & contract$C$Criterion == criterion
  log_kernel <- contract$C$ThetaScore[selected] * theta +
    as.numeric(contract$A[selected, , drop = FALSE] %*% parameter)
  mfrmr_cq_p2_softmax(log_kernel)
}

mfrmr_cq_p2_probability_audit <- function() {
  cases <- expand.grid(
    Model = c("RSM", "PCM"),
    Theta = c(-2.25, -0.50, 0, 0.75, 2.40),
    Rater = paste0("R", 1:4),
    Criterion = paste0("C", 1:3),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  difference <- vapply(seq_len(nrow(cases)), function(index) {
    direct <- mfrmr_cq_p2_probability(
      cases$Model[index], cases$Theta[index], cases$Rater[index],
      cases$Criterion[index]
    )
    matrix <- mfrmr_cq_p2_matrix_probability(
      cases$Model[index], cases$Theta[index], cases$Rater[index],
      cases$Criterion[index]
    )
    max(abs(direct - matrix))
  }, numeric(1L))
  data.frame(
    Cases = nrow(cases),
    MaxAbsProbabilityDifference = max(difference),
    RsmExpectedFreeDimension =
      mfrmr_cq_p2_matrix_contract("RSM")$TotalExpectedFreeDimension,
    PcmExpectedFreeDimension =
      mfrmr_cq_p2_matrix_contract("PCM")$TotalExpectedFreeDimension,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2_continuous_loglikelihood <- function(
    fixture, relative_tolerance = 1e-9) {
  data <- mfrmr_cq_p2_observed_data(fixture)
  truth <- fixture$Truth
  by_person <- split(data, data$Person)
  person_rows <- lapply(by_person, function(person_data) {
    x <- unique(person_data$X)
    mfrmr_cq_p2_assert(length(x) == 1L, "Person covariate drifted within rows.")
    mean <- truth$PopulationIntercept + truth$PopulationSlope * x
    sd <- sqrt(truth$PopulationVariance)
    integrand <- function(z) vapply(z, function(value) {
      theta <- mean + sd * value
      probability <- vapply(seq_len(nrow(person_data)), function(index) {
        mfrmr_cq_p2_probability(
          fixture$Model,
          theta,
          person_data$Rater[index],
          person_data$Criterion[index]
        )[person_data$Response[index] + 1L]
      }, numeric(1L))
      exp(sum(log(probability))) * stats::dnorm(value)
    }, numeric(1L))
    integral <- stats::integrate(
      integrand,
      lower = -Inf,
      upper = Inf,
      rel.tol = relative_tolerance,
      subdivisions = 250L,
      stop.on.error = TRUE
    )
    data.frame(
      Person = person_data$Person[1L],
      Responses = nrow(person_data),
      MarginalProbability = integral$value,
      LogLikelihood = log(integral$value),
      AbsoluteError = integral$abs.error,
      stringsAsFactors = FALSE
    )
  })
  detail <- do.call(rbind, person_rows)
  rownames(detail) <- NULL
  mfrmr_cq_p2_assert(
    all(is.finite(detail$LogLikelihood)) &&
      all(detail$MarginalProbability > 0),
    "The continuous-target marginal likelihood is not finite."
  )
  list(
    RegistryRowId = fixture$RegistryRowId,
    Model = fixture$Model,
    Persons = nrow(detail),
    ObservedRows = sum(detail$Responses),
    LogLikelihood = sum(detail$LogLikelihood),
    IntegrationAbsoluteErrorEstimate = sum(detail$AbsoluteError),
    Detail = detail,
    ExternalExecutionAuthorized = FALSE,
    ComparisonPassed = FALSE
  )
}

mfrmr_cq_p2_review <- function(run_continuous_oracles = FALSE) {
  fixtures <- mfrmr_cq_p2_fixture_registry()
  graph <- lapply(fixtures, mfrmr_cq_p2_graph_audit)
  support <- do.call(rbind, lapply(fixtures, mfrmr_cq_p2_support_audit))
  planned <- mfrmr_cq_p2_observed_data(
    fixtures[["P2-RSM-PLANNED-MISSING-ROWS"]]
  )
  explicit <- mfrmr_cq_p2_observed_data(
    fixtures[["P2-RSM-EXPLICIT-MISSING-VALUES"]]
  )
  observed_columns <- c(
    "Person", "PersonIndex", "X", "Rater", "RaterIndex",
    "Criterion", "CriterionIndex", "Response"
  )
  missing_representation_equivalent <- identical(
    planned[, observed_columns, drop = FALSE],
    explicit[, observed_columns, drop = FALSE]
  )
  oracle <- if (isTRUE(run_continuous_oracles)) {
    lapply(fixtures, mfrmr_cq_p2_continuous_loglikelihood)
  } else {
    list()
  }
  graph_row <- function(id) graph[[id]]
  support_row <- function(id) {
    support[support$RegistryRowId == id, , drop = FALSE]
  }
  connected_ids <- setdiff(
    names(fixtures), "P2-NEG-DISCONNECTED-DESIGN"
  )
  multibridge_ids <- c(
    "P2-RSM-CONNECTED-MULTIBRIDGE", "P2-PCM-CONNECTED-MULTIBRIDGE"
  )
  weak_ids <- c(
    "P2-RSM-WEAK-SINGLE-BRIDGE", "P2-PCM-WEAK-SINGLE-BRIDGE"
  )
  workload_ids <- c(
    "P2-RSM-UNEQUAL-WORKLOAD", "P2-PCM-UNEQUAL-WORKLOAD"
  )
  rare <- support_row("P2-PCM-RARE-BOUNDARY-CATEGORIES")
  unused <- support_row("P2-NEG-UNUSED-INTERMEDIATE-CATEGORY")
  ordinary <- support_row("P2-RSM-NONEXTREME-PERSON")
  extreme <- support_row("P2-RSM-EXTREME-PERSON")
  graph_contract_ready <-
    all(vapply(graph[connected_ids], `[[`, logical(1L), "Connected")) &&
    all(vapply(graph[multibridge_ids], function(result) {
      result$PositiveEdgeCount == 4L && result$BridgeEdgeCount == 0L
    }, logical(1L))) &&
    all(vapply(graph[weak_ids], function(result) {
      result$BridgeEdgeCount == 1L &&
        result$MinPositiveCommonPersons == 2L
    }, logical(1L))) &&
    all(vapply(graph[workload_ids], function(result) {
      result$RaterLoadMax > result$RaterLoadMin
    }, logical(1L))) &&
    !graph_row("P2-NEG-DISCONNECTED-DESIGN")$Connected &&
    graph_row("P2-NEG-DISCONNECTED-DESIGN")$Components == 2L
  support_contract_ready <-
    all(rare[, paste0("Category", 0:3)] > 0L) &&
    rare$Category0 < rare$Category1 && rare$Category3 < rare$Category2 &&
    rare$MinimumScorePersons == 0L && rare$MaximumScorePersons == 0L &&
    unused$Category1 == 0L &&
    all(unused[, c("Category0", "Category2", "Category3")] > 0L) &&
    ordinary$MinimumScorePersons == 0L &&
    ordinary$MaximumScorePersons == 0L &&
    extreme$MinimumScorePersons == 1L &&
    extreme$MaximumScorePersons == 1L
  probability_audit <- mfrmr_cq_p2_probability_audit()
  fixture_contract_ready <-
    length(fixtures) == 13L &&
    !anyDuplicated(vapply(
      fixtures, `[[`, character(1L), "SemanticFixtureId"
    )) &&
    graph_contract_ready && support_contract_ready &&
    missing_representation_equivalent &&
    nrow(fixtures[["P2-RSM-EXPLICIT-MISSING-VALUES"]]$Data) == 576L &&
    sum(is.na(
      fixtures[["P2-RSM-EXPLICIT-MISSING-VALUES"]]$Data$Response
    )) == 288L &&
    probability_audit$MaxAbsProbabilityDifference < 1e-14 &&
    probability_audit$RsmExpectedFreeDimension == 10L &&
    probability_audit$PcmExpectedFreeDimension == 14L
  continuous_oracle_ready <- isTRUE(run_continuous_oracles) &&
    length(oracle) == length(fixtures) &&
    all(vapply(oracle, function(result) {
      result$Persons == 48L && is.finite(result$LogLikelihood) &&
        is.finite(result$IntegrationAbsoluteErrorEstimate)
    }, logical(1L))) &&
    identical(
      oracle[["P2-RSM-PLANNED-MISSING-ROWS"]]$LogLikelihood,
      oracle[["P2-RSM-EXPLICIT-MISSING-VALUES"]]$LogLikelihood
    )
  ready <- fixture_contract_ready && continuous_oracle_ready
  list(
    specification = mfrmr_cq_p2_specification,
    contract_version = mfrmr_cq_p2_contract,
    status = if (ready) {
      "P2_additive_fixtures_and_independent_oracles_ready_for_review"
    } else if (fixture_contract_ready && !isTRUE(run_continuous_oracles)) {
      "P2_additive_fixture_contract_ready_continuous_oracles_not_run"
    } else {
      "P2_additive_fixture_or_oracle_contract_failed"
    },
    fixtures = fixtures,
    graph = graph,
    support = support,
    probability_audit = probability_audit,
    missing_representation_equivalent = missing_representation_equivalent,
    continuous_oracles = oracle,
    graph_contract_ready = graph_contract_ready,
    support_contract_ready = support_contract_ready,
    fixture_contract_ready = fixture_contract_ready,
    continuous_oracle_ready = continuous_oracle_ready,
    fixture_and_oracle_ready = ready,
    metric_specific_rules_frozen = FALSE,
    external_execution_authorized = FALSE,
    comparison_passed = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
