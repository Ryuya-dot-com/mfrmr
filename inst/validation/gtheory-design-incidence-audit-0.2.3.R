# Draft.83a G-theory observed-design incidence audit.
#
# Repository-internal only. This file requires the Draft.81 typed-design
# prototype to have been sourced first. It performs no model fitting, computes
# no D-study coefficient, and never marks a result decision-ready.

mfrmr_gti_require_primitives <- function() {
  required <- c("mfrmr_gta_hash", "mfrmr_gta_split_facets")
  prototype_environment <- environment(mfrmr_gti_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.81 design/algebra prototype before Draft.83a: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gti_cv <- function(x) {
  x <- as.numeric(x)
  if (length(x) < 2L || mean(x) == 0) return(0)
  stats::sd(x) / mean(x)
}

mfrmr_gti_key <- function(data, columns) {
  if (length(columns) == 0L) return(rep.int("", nrow(data)))
  if (length(columns) == 1L) return(as.character(data[[columns]]))
  do.call(paste, c(lapply(data[columns], as.character), list(sep = "\034")))
}

mfrmr_gti_rank <- function(x, tolerance) {
  if (ncol(x) == 0L || nrow(x) == 0L) return(0L)
  as.integer(qr(x, tol = tolerance)$rank)
}

mfrmr_gti_score_token <- function(x) {
  out <- rep.int("NA", length(x))
  out[is.nan(x)] <- "NaN"
  out[is.infinite(x) & x > 0] <- "Inf"
  out[is.infinite(x) & x < 0] <- "-Inf"
  finite <- is.finite(x)
  out[finite] <- sprintf("%.17g", x[finite])
  out
}

mfrmr_gti_prepare <- function(spec, data, missingness) {
  mfrmr_gti_require_primitives()
  if (!inherits(spec, "mfrmr_gta_spec")) {
    stop("`spec` must be a Draft.81 typed design.", call. = FALSE)
  }
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("`data` must be a nonempty data frame.", call. = FALSE)
  }
  allowed_missingness <- c(
    "complete", "MCAR", "MAR_covariate", "MNAR_sensitivity", "unknown"
  )
  missingness <- as.character(missingness)
  if (length(missingness) != 1L || !missingness %in% allowed_missingness) {
    stop("`missingness` is not a recognized Draft.83a mechanism.",
         call. = FALSE)
  }
  factors <- c(spec$ObjectFacet, spec$RandomFacets, spec$FixedFacets)
  factors <- unique(factors)
  required <- c(factors, spec$ScoreColumn)
  absent <- setdiff(required, names(data))
  if (length(absent) > 0L) {
    stop(
      "The incidence audit data are missing required columns: ",
      paste(absent, collapse = ", "), ".", call. = FALSE
    )
  }
  if (!is.numeric(data[[spec$ScoreColumn]])) {
    stop("The observed score must be numeric; labels are not coerced.",
         call. = FALSE)
  }

  score <- data[[spec$ScoreColumn]]
  score_missing <- is.na(score)
  score_nonfinite <- !score_missing & !is.finite(score)
  factor_missing <- matrix(FALSE, nrow(data), length(factors),
                           dimnames = list(NULL, factors))
  factor_text <- vector("list", length(factors))
  names(factor_text) <- factors
  declared_levels <- vector("list", length(factors))
  names(declared_levels) <- factors
  for (factor_name in factors) {
    original_value <- data[[factor_name]]
    value <- as.character(original_value)
    missing_value <- is.na(value) | !nzchar(value)
    available_levels <- if (is.factor(original_value)) {
      as.character(levels(original_value))
    } else {
      unique(value[!missing_value])
    }
    available_levels <- available_levels[
      !is.na(available_levels) & nzchar(available_levels)
    ]
    declared_levels[[factor_name]] <- sort(
      unique(available_levels), method = "radix"
    )
    factor_missing[, factor_name] <- missing_value
    value[missing_value] <- "<MISSING>"
    factor_text[[factor_name]] <- value
  }
  any_factor_missing <- if (length(factors) == 1L) {
    factor_missing[, 1L]
  } else {
    rowSums(factor_missing) > 0L
  }
  retained_flag <- !(score_missing | score_nonfinite | any_factor_missing)

  input_payload <- data.frame(
    factor_text,
    ScoreState = mfrmr_gti_score_token(score),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  input_payload <- input_payload[do.call(order, input_payload), , drop = FALSE]
  row.names(input_payload) <- NULL

  omission_pattern <- data.frame(
    MissingScore = score_missing,
    NonfiniteScore = score_nonfinite,
    MissingFacetSet = apply(factor_missing, 1L, function(row) {
      paste(factors[row], collapse = ":")
    }),
    stringsAsFactors = FALSE
  )
  omission_pattern <- omission_pattern[!retained_flag, , drop = FALSE]
  if (nrow(omission_pattern) > 0L) {
    omission_pattern <- omission_pattern[do.call(order, omission_pattern),
                                         , drop = FALSE]
  }
  row.names(omission_pattern) <- NULL

  retained <- data[retained_flag, required, drop = FALSE]
  for (factor_name in factors) {
    retained[[factor_name]] <- factor(as.character(retained[[factor_name]]))
  }
  if (nrow(retained) > 0L) {
    ordering <- c(lapply(retained[factors], as.character),
                  list(retained[[spec$ScoreColumn]]))
    retained <- retained[do.call(order, ordering), , drop = FALSE]
  }
  row.names(retained) <- NULL
  retained_payload <- data.frame(
    lapply(retained[factors], as.character),
    Score = if (nrow(retained) > 0L) {
      mfrmr_gti_score_token(retained[[spec$ScoreColumn]])
    } else character(),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  names(retained_payload)[ncol(retained_payload)] <- spec$ScoreColumn

  list(
    Data = retained,
    Factors = factors,
    Missingness = missingness,
    InputRows = nrow(data),
    RetainedRows = nrow(retained),
    OmittedRows = sum(!retained_flag),
    MissingScoreRows = sum(score_missing),
    NonfiniteScoreRows = sum(score_nonfinite),
    MissingFacetRows = sum(any_factor_missing),
    MissingFacetCells = sum(factor_missing),
    DeclaredLevels = declared_levels,
    DeclaredLevelHash = mfrmr_gta_hash(declared_levels),
    CanonicalInputHash = mfrmr_gta_hash(input_payload),
    RetainedDataHash = mfrmr_gta_hash(retained_payload),
    OmissionPatternHash = mfrmr_gta_hash(omission_pattern)
  )
}

mfrmr_gti_ancestors <- function(factor_name, nesting, declared) {
  found <- character()
  frontier <- factor_name
  while (length(frontier) > 0L) {
    current <- frontier[[1L]]
    frontier <- frontier[-1L]
    parents <- nesting$Parent[nesting$Child == current]
    parents <- setdiff(parents, found)
    found <- union(found, parents)
    frontier <- union(frontier, parents)
  }
  declared[declared %in% found]
}

mfrmr_gti_effective_values <- function(data, factors, nesting) {
  out <- vector("list", length(factors))
  names(out) <- factors
  for (factor_name in factors) {
    members <- c(mfrmr_gti_ancestors(factor_name, nesting, factors),
                 factor_name)
    values <- lapply(members, function(member) {
      paste0(member, "=", as.character(data[[member]]))
    })
    out[[factor_name]] <- do.call(paste, c(values, list(sep = "/")))
  }
  as.data.frame(out, stringsAsFactors = FALSE, check.names = FALSE)
}

mfrmr_gti_components <- function(nodes, edges) {
  nodes <- unique(as.character(nodes))
  if (length(nodes) == 0L) {
    return(list(Count = 0L, Membership = integer()))
  }
  adjacency <- stats::setNames(vector("list", length(nodes)), nodes)
  if (nrow(edges) > 0L) {
    for (index in seq_len(nrow(edges))) {
      left <- as.character(edges[index, 1L])
      right <- as.character(edges[index, 2L])
      adjacency[[left]] <- union(adjacency[[left]], right)
      adjacency[[right]] <- union(adjacency[[right]], left)
    }
  }
  membership <- stats::setNames(rep.int(NA_integer_, length(nodes)), nodes)
  component <- 0L
  for (start in nodes) {
    if (!is.na(membership[[start]])) next
    component <- component + 1L
    frontier <- start
    membership[[start]] <- component
    while (length(frontier) > 0L) {
      current <- frontier[[1L]]
      frontier <- frontier[-1L]
      neighbours <- adjacency[[current]]
      unseen <- neighbours[is.na(membership[neighbours])]
      if (length(unseen) > 0L) {
        membership[unseen] <- component
        frontier <- union(frontier, unseen)
      }
    }
  }
  list(Count = component, Membership = membership)
}

mfrmr_gti_graph_audit <- function(prepared, spec) {
  data <- prepared$Data
  factors <- prepared$Factors
  if (nrow(data) == 0L) {
    return(list(
      EffectiveValues = data.frame(),
      Global = data.frame(
        ObservedNodes = 0L, ObservedEdges = 0L,
        ConnectedComponents = 0L, IsConnected = FALSE
      ),
      Pairwise = data.frame()
    ))
  }
  effective <- mfrmr_gti_effective_values(data, factors, spec$NestingGraph)
  global_edges <- list()
  edge_index <- 0L
  if (length(factors) > 1L) {
    for (row in seq_len(nrow(effective))) {
      anchor <- paste0(factors[[1L]], "::", effective[[factors[[1L]]]][row])
      for (factor_name in factors[-1L]) {
        edge_index <- edge_index + 1L
        global_edges[[edge_index]] <- c(
          anchor, paste0(factor_name, "::", effective[[factor_name]][row])
        )
      }
    }
  }
  global_edges <- if (length(global_edges) == 0L) {
    matrix(character(), ncol = 2L)
  } else {
    unique(do.call(rbind, global_edges))
  }
  nodes <- unlist(lapply(factors, function(factor_name) {
    paste0(factor_name, "::", unique(effective[[factor_name]]))
  }), use.names = FALSE)
  global_components <- mfrmr_gti_components(nodes, global_edges)
  global <- data.frame(
    ObservedNodes = length(unique(nodes)),
    ObservedEdges = nrow(global_edges),
    ConnectedComponents = global_components$Count,
    IsConnected = identical(global_components$Count, 1L),
    stringsAsFactors = FALSE
  )

  pairs <- utils::combn(factors, 2L, simplify = FALSE)
  pair_rows <- lapply(pairs, function(pair) {
    left <- pair[[1L]]
    right <- pair[[2L]]
    table_pair <- table(effective[[left]], effective[[right]])
    incidence <- table_pair > 0L
    observed_edges <- sum(incidence)
    left_degree <- rowSums(incidence)
    right_degree <- colSums(incidence)
    edge_positions <- which(incidence, arr.ind = TRUE)
    edges <- if (nrow(edge_positions) == 0L) {
      matrix(character(), ncol = 2L)
    } else {
      cbind(
        paste0(left, "::", rownames(incidence)[edge_positions[, 1L]]),
        paste0(right, "::", colnames(incidence)[edge_positions[, 2L]])
      )
    }
    pair_nodes <- c(
      paste0(left, "::", rownames(incidence)),
      paste0(right, "::", colnames(incidence))
    )
    graph <- mfrmr_gti_components(pair_nodes, edges)
    data.frame(
      PairId = paste(left, right, sep = ":"),
      LeftFactor = left,
      RightFactor = right,
      LeftLevels = nrow(incidence),
      RightLevels = ncol(incidence),
      ObservedEdges = observed_edges,
      PotentialEdges = length(incidence),
      IncidenceDensity = observed_edges / length(incidence),
      ConnectedComponents = graph$Count,
      IsConnected = identical(graph$Count, 1L),
      LeftDegreeMin = min(left_degree),
      LeftDegreeMax = max(left_degree),
      LeftDegreeCV = mfrmr_gti_cv(left_degree),
      RightDegreeMin = min(right_degree),
      RightDegreeMax = max(right_degree),
      RightDegreeCV = mfrmr_gti_cv(right_degree),
      stringsAsFactors = FALSE
    )
  })
  pairwise <- if (length(pair_rows) == 0L) data.frame() else
    do.call(rbind, pair_rows)
  row.names(pairwise) <- NULL
  list(EffectiveValues = effective, Global = global, Pairwise = pairwise)
}

mfrmr_gti_workload <- function(prepared, effective) {
  rows <- lapply(prepared$Factors, function(factor_name) {
    declared <- prepared$DeclaredLevels[[factor_name]]
    retained_raw <- if (prepared$RetainedRows == 0L) character() else
      unique(as.character(prepared$Data[[factor_name]]))
    counts <- if (prepared$RetainedRows == 0L) integer() else
      table(effective[[factor_name]])
    data.frame(
      Factor = factor_name,
      DeclaredRawLevels = length(declared),
      RetainedRawLevels = length(retained_raw),
      ZeroRetainedRawLevels = length(setdiff(declared, retained_raw)),
      ObservedConditionalLevels = length(counts),
      ObservationMin = if (length(counts) == 0L) NA_integer_ else min(counts),
      ObservationMedian = if (length(counts) == 0L) NA_real_ else
        stats::median(counts),
      ObservationMean = if (length(counts) == 0L) NA_real_ else mean(counts),
      ObservationMax = if (length(counts) == 0L) NA_integer_ else max(counts),
      ObservationSD = if (length(counts) > 1L) stats::sd(counts) else
        if (length(counts) == 1L) 0 else NA_real_,
      ObservationCV = if (length(counts) == 0L) NA_real_ else
        mfrmr_gti_cv(counts),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gti_cells <- function(prepared, effective, spec) {
  if (prepared$RetainedRows == 0L) {
    return(data.frame(
      ObservedCells = 0L, PotentialCells = 0,
      CartesianPotentialCells = 0, CellCoverage = NA_real_,
      PotentialCellBasis = "not_evaluable",
      CellCountMin = NA_integer_, CellCountMedian = NA_real_,
      CellCountMax = NA_integer_, RepeatedCells = 0L,
      EmptyPotentialCells = 0, ReplicationState = "no_retained_rows",
      HighestInteractionResidualState = "not_evaluable",
      DeclaredCellReplication = isTRUE(spec$CellReplication),
      ObservedAnyCellReplication = FALSE,
      stringsAsFactors = FALSE
    ))
  }
  key <- mfrmr_gti_key(effective, prepared$Factors)
  counts <- table(key)
  levels_per_factor <- vapply(effective, function(x) length(unique(x)),
                              integer(1L))
  cartesian_potential <- prod(as.double(levels_per_factor))
  nesting_resolved <- nrow(spec$NestingGraph) == 0L
  potential <- if (nesting_resolved) cartesian_potential else NA_real_
  observed <- length(counts)
  state <- if (!nesting_resolved && all(counts == 1L)) {
    "one_per_observed_cell_nested_completeness_unresolved"
  } else if (all(counts == 1L) && observed == potential) {
    "complete_one_per_cell"
  } else if (all(counts == 1L)) {
    "partial_one_per_observed_cell"
  } else if (length(unique(as.integer(counts))) == 1L &&
             observed == potential) {
    "complete_equal_replication"
  } else {
    "unequal_or_partial_replication"
  }
  separation <- if (min(counts) >= 2L) {
    "within_cell_replication_available"
  } else if (any(counts >= 2L)) {
    "partial_replication_not_global"
  } else {
    "highest_interaction_residual_not_separable"
  }
  data.frame(
    ObservedCells = observed,
    PotentialCells = potential,
    CartesianPotentialCells = cartesian_potential,
    CellCoverage = if (is.na(potential)) NA_real_ else observed / potential,
    PotentialCellBasis = if (nesting_resolved) {
      "cartesian_observed_levels"
    } else {
      "nested_structural_potential_requires_allocation_contract"
    },
    CellCountMin = min(counts),
    CellCountMedian = stats::median(counts),
    CellCountMax = max(counts),
    RepeatedCells = sum(counts > 1L),
    EmptyPotentialCells = potential - observed,
    ReplicationState = state,
    HighestInteractionResidualState = separation,
    DeclaredCellReplication = isTRUE(spec$CellReplication),
    ObservedAnyCellReplication = any(counts > 1L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gti_nesting <- function(prepared, spec) {
  nesting <- spec$NestingGraph
  if (nrow(nesting) == 0L || prepared$RetainedRows == 0L) {
    return(data.frame())
  }
  data <- prepared$Data
  rows <- lapply(seq_len(nrow(nesting)), function(index) {
    parent <- nesting$Parent[[index]]
    child <- nesting$Child[[index]]
    parent_child <- unique(data.frame(
      Parent = as.character(data[[parent]]),
      Child = as.character(data[[child]]),
      stringsAsFactors = FALSE
    ))
    parents_per_child <- table(parent_child$Child)
    children_per_parent <- table(parent_child$Parent)
    data.frame(
      Parent = parent,
      Child = child,
      ParentLevels = length(unique(parent_child$Parent)),
      RawChildLabels = length(unique(parent_child$Child)),
      ConditionalChildLevels = nrow(parent_child),
      SharedRawChildLabels = sum(parents_per_child > 1L),
      ConditionalCountMin = min(children_per_parent),
      ConditionalCountMedian = stats::median(children_per_parent),
      ConditionalCountMax = max(children_per_parent),
      LabelScopeStatus = if (any(parents_per_child > 1L)) {
        "raw_child_labels_reused_conditional_identity_applied"
      } else {
        "raw_child_labels_globally_unique"
      },
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gti_contrast_block <- function(data, members) {
  blocks <- lapply(members, function(member) {
    value <- data[[member]]
    level_count <- nlevels(value)
    if (level_count < 2L) return(matrix(numeric(), nrow(data), 0L))
    contrast <- stats::contr.sum(level_count)
    contrast[as.integer(value), , drop = FALSE]
  })
  if (any(vapply(blocks, ncol, integer(1L)) == 0L)) {
    return(matrix(numeric(), nrow(data), 0L))
  }
  block <- matrix(1, nrow(data), 1L)
  for (next_block in blocks) {
    combined <- vector("list", ncol(block) * ncol(next_block))
    cursor <- 0L
    for (left in seq_len(ncol(block))) {
      for (right in seq_len(ncol(next_block))) {
        cursor <- cursor + 1L
        combined[[cursor]] <- block[, left] * next_block[, right]
      }
    }
    block <- do.call(cbind, combined)
  }
  block
}

mfrmr_gti_is_nested_component <- function(members, nesting) {
  if (nrow(nesting) == 0L || length(members) < 2L) return(FALSE)
  any(nesting$Parent %in% members & nesting$Child %in% members)
}

mfrmr_gti_group_contrast <- function(grouping_key) {
  grouping <- factor(grouping_key)
  level_count <- nlevels(grouping)
  if (level_count < 2L) return(matrix(numeric(), length(grouping), 0L))
  contrast <- stats::contr.sum(level_count)
  contrast[as.integer(grouping), , drop = FALSE]
}

mfrmr_gti_rank_audit <- function(prepared, spec, effective,
                                 rank_tolerance, max_matrix_cells) {
  effect_map <- spec$EffectMap[spec$EffectMap$ComponentId != "Residual",
                               , drop = FALSE]
  if (prepared$RetainedRows == 0L) {
    return(list(
      Components = data.frame(), FullModelRank = 0L,
      ResidualDegreesFreedom = 0L, MatrixCells = 0,
      CapacityStatus = "no_retained_rows"
    ))
  }
  component_members <- lapply(
    effect_map$Members, mfrmr_gta_split_facets
  )
  nested_component <- vapply(
    component_members, mfrmr_gti_is_nested_component, logical(1L),
    nesting = spec$NestingGraph
  )
  block_columns <- vapply(seq_len(nrow(effect_map)), function(index) {
    members <- component_members[[index]]
    if (nested_component[[index]]) {
      return(max(0L, length(unique(mfrmr_gti_key(effective, members))) - 1L))
    }
    prod(vapply(members, function(member) {
      max(0L, nlevels(prepared$Data[[member]]) - 1L)
    }, integer(1L)))
  }, numeric(1L))
  nominal <- vapply(seq_len(nrow(effect_map)), function(index) {
    if (!nested_component[[index]]) return(block_columns[[index]])
    members <- component_members[[index]]
    observed_groups <- length(unique(mfrmr_gti_key(effective, members)))
    proper <- which(vapply(component_members, function(candidate) {
      length(candidate) < length(members) && all(candidate %in% members)
    }, logical(1L)))
    if (length(proper) == 0L) return(max(0L, observed_groups - 1L))
    proper_groups <- vapply(proper, function(candidate_index) {
      length(unique(mfrmr_gti_key(
        effective, component_members[[candidate_index]]
      )))
    }, integer(1L))
    max(0L, observed_groups - max(proper_groups))
  }, numeric(1L))
  total_columns <- 1 + sum(block_columns)
  matrix_cells <- as.double(prepared$RetainedRows) * total_columns
  if (matrix_cells > max_matrix_cells) {
    rows <- lapply(seq_len(nrow(effect_map)), function(index) {
      data.frame(
        ComponentId = effect_map$ComponentId[[index]],
        Members = effect_map$Members[[index]],
        ObservedGroupingLevels = NA_integer_,
        PotentialLevelCombinations = NA_real_,
        GroupCoverage = NA_real_,
        GroupObservationMin = NA_integer_,
        GroupObservationMedian = NA_real_,
        GroupObservationMax = NA_integer_,
        NominalContrastDf = nominal[[index]],
        BlockRank = NA_integer_, IncrementalRank = NA_integer_,
        FixedEquivalentStatus = "not_evaluated_capacity",
        stringsAsFactors = FALSE
      )
    })
    return(list(
      Components = do.call(rbind, rows), FullModelRank = NA_integer_,
      ResidualDegreesFreedom = NA_integer_, MatrixCells = matrix_cells,
      CapacityStatus = "not_evaluated_capacity"
    ))
  }

  blocks <- lapply(seq_len(nrow(effect_map)), function(index) {
    members <- component_members[[index]]
    if (nested_component[[index]]) {
      mfrmr_gti_group_contrast(mfrmr_gti_key(effective, members))
    } else {
      mfrmr_gti_contrast_block(prepared$Data, members)
    }
  })
  full <- do.call(cbind, c(list(matrix(1, prepared$RetainedRows, 1L)), blocks))
  full_rank <- mfrmr_gti_rank(full, rank_tolerance)
  rows <- lapply(seq_len(nrow(effect_map)), function(index) {
    members <- mfrmr_gta_split_facets(effect_map$Members[[index]])
    grouping_key <- mfrmr_gti_key(effective, members)
    group_counts <- table(grouping_key)
    potential <- if (nested_component[[index]]) {
      NA_real_
    } else {
      prod(vapply(effective[members], function(x) {
        length(unique(x))
      }, integer(1L)))
    }
    without <- do.call(cbind, c(
      list(matrix(1, prepared$RetainedRows, 1L)), blocks[-index]
    ))
    block_rank <- mfrmr_gti_rank(blocks[[index]], rank_tolerance)
    incremental <- full_rank - mfrmr_gti_rank(without, rank_tolerance)
    absorbed_by_nested_child <- !nested_component[[index]] && any(vapply(
      which(nested_component), function(child_index) {
        all(members %in% component_members[[child_index]])
      }, logical(1L)
    ))
    status <- if (incremental == 0L && absorbed_by_nested_child) {
      "fixed_equivalent_nested_hierarchy_absorbed"
    } else if (nominal[[index]] == 0L || incremental == 0L) {
      "fixed_equivalent_zero_increment"
    } else if (incremental < nominal[[index]]) {
      "fixed_equivalent_partial_increment"
    } else {
      "fixed_equivalent_full_increment"
    }
    data.frame(
      ComponentId = effect_map$ComponentId[[index]],
      Members = effect_map$Members[[index]],
      ObservedGroupingLevels = length(group_counts),
      PotentialLevelCombinations = potential,
      GroupCoverage = if (is.na(potential)) NA_real_ else
        length(group_counts) / potential,
      GroupObservationMin = min(group_counts),
      GroupObservationMedian = stats::median(group_counts),
      GroupObservationMax = max(group_counts),
      NominalContrastDf = nominal[[index]],
      BlockRank = block_rank,
      IncrementalRank = incremental,
      FixedEquivalentStatus = status,
      stringsAsFactors = FALSE
    )
  })
  component_table <- do.call(rbind, rows)
  row.names(component_table) <- NULL
  list(
    Components = component_table,
    FullModelRank = full_rank,
    ResidualDegreesFreedom = prepared$RetainedRows - full_rank,
    MatrixCells = matrix_cells,
    CapacityStatus = "evaluated"
  )
}

mfrmr_gti_nesting_related <- function(left, right, nesting, declared) {
  left %in% mfrmr_gti_ancestors(right, nesting, declared) ||
    right %in% mfrmr_gti_ancestors(left, nesting, declared)
}

mfrmr_gti_audit <- function(spec, data,
                            missingness = c(
                              "complete", "MCAR", "MAR_covariate",
                              "MNAR_sensitivity", "unknown"
                            ),
                            rank_tolerance = 1e-10,
                            max_matrix_cells = 5e6) {
  if (length(missingness) > 1L) missingness <- missingness[[1L]]
  if (!is.numeric(rank_tolerance) || length(rank_tolerance) != 1L ||
      !is.finite(rank_tolerance) || rank_tolerance <= 0) {
    stop("`rank_tolerance` must be one finite positive number.",
         call. = FALSE)
  }
  if (!is.numeric(max_matrix_cells) || length(max_matrix_cells) != 1L ||
      !is.finite(max_matrix_cells) || max_matrix_cells < 1) {
    stop("`max_matrix_cells` must be one finite positive number.",
         call. = FALSE)
  }
  prepared <- mfrmr_gti_prepare(spec, data, missingness)
  graph <- mfrmr_gti_graph_audit(prepared, spec)
  workload <- mfrmr_gti_workload(prepared, graph$EffectiveValues)
  cells <- mfrmr_gti_cells(prepared, graph$EffectiveValues, spec)
  nesting <- mfrmr_gti_nesting(prepared, spec)
  ranks <- mfrmr_gti_rank_audit(
    prepared, spec, graph$EffectiveValues, rank_tolerance,
    max_matrix_cells
  )

  issues <- character()
  if (prepared$RetainedRows == 0L) issues <- c(issues, "no_retained_rows")
  if (prepared$OmittedRows > 0L && identical(missingness, "complete")) {
    issues <- c(issues, "declared_complete_but_rows_omitted")
  }
  if (prepared$OmittedRows > 0L && identical(missingness, "unknown")) {
    issues <- c(issues, "unknown_missingness_with_omissions")
  }
  if (prepared$RetainedRows > 0L) {
    observed_levels <- vapply(prepared$Data[prepared$Factors], nlevels,
                              integer(1L))
    if (any(observed_levels < 2L)) {
      issues <- c(issues, paste0(
        "insufficient_observed_levels:",
        paste(names(observed_levels)[observed_levels < 2L], collapse = ",")
      ))
    }
  }
  isolated_declared <- workload$ZeroRetainedRawLevels > 0L
  if (any(isolated_declared)) {
    issues <- c(issues, paste0(
      "declared_levels_without_retained_rows:",
      paste(workload$Factor[isolated_declared], collapse = ",")
    ))
  }
  if (nrow(graph$Pairwise) > 0L) {
    object <- spec$ObjectFacet
    object_pairs <- graph$Pairwise[
      graph$Pairwise$LeftFactor == object |
        graph$Pairwise$RightFactor == object, , drop = FALSE
    ]
    for (index in seq_len(nrow(object_pairs))) {
      facet <- setdiff(
        c(object_pairs$LeftFactor[[index]], object_pairs$RightFactor[[index]]),
        object
      )
      related <- mfrmr_gti_nesting_related(
        object, facet, spec$NestingGraph, prepared$Factors
      )
      if (!object_pairs$IsConnected[[index]] && !related) {
        issues <- c(issues, paste0(
          "non_nested_object_facet_disconnected:", facet
        ))
      }
    }
  }
  if (nrow(ranks$Components) > 0L) {
    deficient <- ranks$Components$FixedEquivalentStatus %in% c(
      "fixed_equivalent_zero_increment",
      "fixed_equivalent_partial_increment"
    )
    if (any(deficient)) {
      issues <- c(issues, paste0(
        "fixed_equivalent_rank_deficiency:",
        paste(ranks$Components$ComponentId[deficient], collapse = ",")
      ))
    }
  }
  if (identical(ranks$CapacityStatus, "not_evaluated_capacity")) {
    issues <- c(issues, "rank_audit_not_evaluated_capacity")
  }
  if (identical(ranks$CapacityStatus, "evaluated") &&
      ranks$ResidualDegreesFreedom <= 0L) {
    issues <- c(issues, "no_fixed_equivalent_residual_df")
  }
  if (isTRUE(cells$DeclaredCellReplication !=
             cells$ObservedAnyCellReplication)) {
    issues <- c(issues, "cell_replication_metadata_mismatch")
  }
  highest_members <- paste(
    c(spec$ObjectFacet, spec$RandomFacets), collapse = ":"
  )
  highest_present <- highest_members %in% spec$EffectMap$ComponentId
  if (highest_present && !identical(
    cells$HighestInteractionResidualState,
    "within_cell_replication_available"
  )) {
    issues <- c(issues, "highest_order_residual_not_separable")
  }
  if (identical(
    cells$HighestInteractionResidualState, "partial_replication_not_global"
  )) {
    issues <- c(issues, "partial_full_cell_replication")
  }
  issues <- unique(issues)

  missingness_status <- if (prepared$OmittedRows == 0L) {
    "no_rows_omitted"
  } else if (identical(missingness, "complete")) {
    "declaration_conflict"
  } else {
    paste0("omissions_declared_", missingness)
  }
  audit_state <- if (!identical(ranks$CapacityStatus, "evaluated")) {
    paste0("audit_", ranks$CapacityStatus)
  } else if (length(issues) > 0L) {
    "audit_complete_with_design_concerns"
  } else {
    "audit_complete"
  }
  identity <- list(
    Contract = "gtheory_design_incidence_audit_draft83a_v1",
    DesignHash = spec$DesignHash,
    DeclaredLevelHash = prepared$DeclaredLevelHash,
    CanonicalInputHash = prepared$CanonicalInputHash,
    RetainedDataHash = prepared$RetainedDataHash,
    OmissionPatternHash = prepared$OmissionPatternHash,
    MissingnessMechanism = missingness,
    RankTolerance = rank_tolerance,
    MaxMatrixCells = max_matrix_cells,
    Workload = workload,
    GlobalConnectivity = graph$Global,
    PairwiseConnectivity = graph$Pairwise,
    CellAudit = cells,
    NestingAudit = nesting,
    ComponentRankAudit = ranks$Components,
    FullModelRank = ranks$FullModelRank,
    ResidualDegreesFreedom = ranks$ResidualDegreesFreedom,
    RankMatrixCells = ranks$MatrixCells,
    RankCapacityStatus = ranks$CapacityStatus,
    Issues = issues
  )
  audit_hash <- mfrmr_gta_hash(identity)
  structure(c(identity, list(
    InputRows = prepared$InputRows,
    RetainedRows = prepared$RetainedRows,
    OmittedRows = prepared$OmittedRows,
    MissingScoreRows = prepared$MissingScoreRows,
    NonfiniteScoreRows = prepared$NonfiniteScoreRows,
    MissingFacetRows = prepared$MissingFacetRows,
    MissingFacetCells = prepared$MissingFacetCells,
    MissingnessStatus = missingness_status,
    AuditState = audit_state,
    IncidenceScreenPassed = length(issues) == 0L,
    EstimationEligibility = "not_adjudicated_draft83a",
    CoefficientEligible = FALSE,
    DecisionReady = FALSE,
    AuditHash = audit_hash
  )), class = "mfrmr_gti_audit")
}
