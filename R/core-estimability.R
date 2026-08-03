# ==============================================================================
# Estimator-specific constrained estimability audit
# ==============================================================================
#
# The audit works in the exact free-coordinate parameterization used by the
# optimizer. For RSM/PCM it builds the sparse adjacent-category-logit design,
# including Person coordinates for JML and excluding them for MML. Anchors,
# group constraints, facet signs, two-way interactions, and step constraints
# enter through their actual expansion Jacobians.
#
# GPCM log slopes and latent-regression residual variance are nonlinear
# coordinates. The additive block is audited before fitting. A bounded local
# fitted-information instrument is available after a stationary fit, but a
# full-model estimability claim remains deferred until structural nonlinear
# audits and pilot-calibrated weak-information rules exist. This distinction
# is retained in `Complete` and `NonlinearBlocks`.

mfrmr_estimability_contract_version <- function() {
  "mfrmr-internal-readiness-0.2.3-v1"
}

mfrmr_empty_sparse_matrix <- function(nrow = 0L, ncol = 0L) {
  Matrix::sparseMatrix(
    i = integer(0), j = integer(0), x = numeric(0),
    dims = c(as.integer(nrow), as.integer(ncol))
  )
}

mfrmr_estimability_map <- function(Block = character(0),
                                    Coordinate = character(0),
                                    Facet = character(0),
                                    Level = character(0),
                                    ReferenceLevel = character(0),
                                    Constraint = character(0),
                                    OptimizerIndex = integer(0)) {
  data.frame(
    Block = as.character(Block),
    Coordinate = as.character(Coordinate),
    Facet = as.character(Facet),
    Level = as.character(Level),
    ReferenceLevel = as.character(ReferenceLevel),
    Constraint = as.character(Constraint),
    OptimizerIndex = as.integer(OptimizerIndex),
    stringsAsFactors = FALSE
  )
}

mfrmr_constraint_jacobian_sparse <- function(spec, block) {
  levels <- as.character(spec$levels %||% character(0))
  n_levels <- length(levels)
  anchors <- as.numeric(spec$anchors %||% rep(NA_real_, n_levels))
  groups <- as.character(spec$groups %||% rep(NA_character_, n_levels))
  if (length(anchors) != n_levels || length(groups) != n_levels) {
    stop("Internal estimability audit found a malformed facet constraint.",
         call. = FALSE)
  }

  free_idx <- which(is.na(anchors))
  row_i <- integer(0)
  col_j <- integer(0)
  values <- numeric(0)
  map_rows <- list()
  col_cursor <- 0L

  add_column <- function(level_idx, reference_idx, constraint, group = "") {
    col_cursor <<- col_cursor + 1L
    row_i <<- c(row_i, level_idx, reference_idx)
    col_j <<- c(col_j, col_cursor, col_cursor)
    values <<- c(values, 1, -1)
    suffix <- if (nzchar(group)) paste0("|group=", group) else ""
    map_rows[[col_cursor]] <<- mfrmr_estimability_map(
      Block = block,
      Coordinate = paste0(block, ":", levels[level_idx], suffix),
      Facet = block,
      Level = levels[level_idx],
      ReferenceLevel = levels[reference_idx],
      Constraint = constraint,
      OptimizerIndex = NA_integer_
    )
  }

  group_ids <- unique(stats::na.omit(groups[free_idx]))
  group_ids <- group_ids[nzchar(group_ids)]
  grouped_idx <- integer(0)
  if (length(group_ids) > 0L) {
    for (group_id in group_ids) {
      group_levels <- which(groups == group_id)
      free_in_group <- group_levels[is.na(anchors[group_levels])]
      grouped_idx <- c(grouped_idx, free_in_group)
      if (length(free_in_group) <= 1L) next
      reference <- free_in_group[length(free_in_group)]
      for (level_idx in free_in_group[-length(free_in_group)]) {
        add_column(
          level_idx = level_idx,
          reference_idx = reference,
          constraint = "group_sum",
          group = group_id
        )
      }
    }
  }

  ungrouped_idx <- setdiff(free_idx, grouped_idx)
  if (length(ungrouped_idx) > 0L) {
    if (isTRUE(spec$centered)) {
      if (length(ungrouped_idx) > 1L) {
        reference <- ungrouped_idx[length(ungrouped_idx)]
        for (level_idx in ungrouped_idx[-length(ungrouped_idx)]) {
          add_column(
            level_idx = level_idx,
            reference_idx = reference,
            constraint = "sum_zero"
          )
        }
      }
    } else {
      for (level_idx in ungrouped_idx) {
        col_cursor <- col_cursor + 1L
        row_i <- c(row_i, level_idx)
        col_j <- c(col_j, col_cursor)
        values <- c(values, 1)
        map_rows[[col_cursor]] <- mfrmr_estimability_map(
          Block = block,
          Coordinate = paste0(block, ":", levels[level_idx]),
          Facet = block,
          Level = levels[level_idx],
          ReferenceLevel = "",
          Constraint = "free_location",
          OptimizerIndex = NA_integer_
        )
      }
    }
  }

  expected <- as.integer(spec$n_params %||% 0L)
  if (col_cursor != expected) {
    stop(
      "Internal estimability audit/free-parameter mismatch for ",
      shQuote(block), ": audit built ", col_cursor,
      " coordinate(s), optimizer expects ", expected, ".",
      call. = FALSE
    )
  }

  jacobian <- if (col_cursor == 0L) {
    mfrmr_empty_sparse_matrix(n_levels, 0L)
  } else {
    Matrix::sparseMatrix(
      i = row_i, j = col_j, x = values,
      dims = c(n_levels, col_cursor)
    )
  }
  map <- if (length(map_rows) == 0L) {
    mfrmr_estimability_map()
  } else {
    do.call(rbind, map_rows)
  }
  rownames(map) <- NULL
  dimnames(jacobian) <- list(
    levels,
    if (nrow(map) > 0L) map$Coordinate else character(0)
  )
  list(jacobian = jacobian, map = map)
}

mfrmr_interaction_jacobian_sparse <- function(spec) {
  n_a <- as.integer(spec$n_a %||% 0L)
  n_b <- as.integer(spec$n_b %||% 0L)
  n_params <- as.integer(spec$n_params %||% 0L)
  n_cells <- n_a * n_b
  if (n_params == 0L) {
    return(list(
      jacobian = mfrmr_empty_sparse_matrix(n_cells, 0L),
      map = mfrmr_estimability_map()
    ))
  }

  row_i <- integer(0)
  col_j <- integer(0)
  values <- numeric(0)
  map_rows <- vector("list", n_params)
  col_cursor <- 0L
  cell <- function(a, b) a + (b - 1L) * n_a
  for (b in seq_len(n_b - 1L)) {
    for (a in seq_len(n_a - 1L)) {
      col_cursor <- col_cursor + 1L
      row_i <- c(row_i, cell(a, b), cell(a, n_b),
                 cell(n_a, b), cell(n_a, n_b))
      col_j <- c(col_j, rep(col_cursor, 4L))
      values <- c(values, 1, -1, -1, 1)
      map_rows[[col_cursor]] <- mfrmr_estimability_map(
        Block = "interactions",
        Coordinate = paste0(
          spec$name, ":", spec$levels_a[a], "*", spec$levels_b[b]
        ),
        Facet = spec$name,
        Level = paste(spec$levels_a[a], spec$levels_b[b], sep = "*"),
        ReferenceLevel = paste(spec$levels_a[n_a], spec$levels_b[n_b],
                               sep = "*"),
        Constraint = "two_way_sum_zero_margins",
        OptimizerIndex = NA_integer_
      )
    }
  }
  if (col_cursor != n_params) {
    stop("Internal interaction estimability dimension mismatch.", call. = FALSE)
  }
  list(
    jacobian = Matrix::sparseMatrix(
      i = row_i, j = col_j, x = values,
      dims = c(n_cells, n_params)
    ),
    map = do.call(rbind, map_rows)
  )
}

mfrmr_step_jacobian_sparse <- function(config, sizes) {
  n_steps <- max(as.integer(config$n_cat %||% 0L) - 1L, 0L)
  n_free_per_scope <- sum_zero_param_count(n_steps)
  n_scope <- if (identical(config$model, "RSM")) {
    1L
  } else {
    length(config$facet_levels[[config$step_facet]] %||% character(0))
  }
  n_rows <- n_scope * n_steps
  n_cols <- n_scope * n_free_per_scope
  if (n_cols == 0L) {
    return(list(
      jacobian = mfrmr_empty_sparse_matrix(n_rows, 0L),
      map = mfrmr_estimability_map()
    ))
  }

  row_i <- integer(0)
  col_j <- integer(0)
  values <- numeric(0)
  map_rows <- vector("list", n_cols)
  col_cursor <- 0L
  scope_levels <- if (identical(config$model, "RSM")) {
    "shared"
  } else {
    as.character(config$facet_levels[[config$step_facet]])
  }
  for (scope in seq_len(n_scope)) {
    row_offset <- (scope - 1L) * n_steps
    for (transition in seq_len(n_free_per_scope)) {
      col_cursor <- col_cursor + 1L
      row_i <- c(row_i, row_offset + transition, row_offset + n_steps)
      col_j <- c(col_j, col_cursor, col_cursor)
      values <- c(values, 1, -1)
      map_rows[[col_cursor]] <- mfrmr_estimability_map(
        Block = "steps",
        Coordinate = paste0(
          "steps:", scope_levels[scope], ":transition", transition
        ),
        Facet = if (identical(config$model, "RSM")) {
          "shared_rating_scale"
        } else {
          config$step_facet
        },
        Level = scope_levels[scope],
        ReferenceLevel = paste0("transition", n_steps),
        Constraint = "within_ladder_sum_zero",
        OptimizerIndex = NA_integer_
      )
    }
  }
  list(
    jacobian = Matrix::sparseMatrix(
      i = row_i, j = col_j, x = values,
      dims = c(n_rows, n_cols)
    ),
    map = do.call(rbind, map_rows)
  )
}

mfrmr_estimability_set_optimizer_index <- function(map, block, slices) {
  if (nrow(map) == 0L) return(map)
  idx <- slices[[block]] %||% integer(0)
  if (length(idx) == nrow(map)) {
    map$OptimizerIndex <- as.integer(idx)
  }
  map
}

mfrmr_estimability_eta_design <- function(prep, idx, config, sizes,
                                           include_person,
                                           include_population_beta) {
  n_obs <- length(idx$score_k)
  slices <- build_param_slices(sizes)
  blocks <- list()
  maps <- list()

  append_block <- function(name, matrix, map) {
    if (ncol(matrix) == 0L) return(invisible(NULL))
    blocks[[length(blocks) + 1L]] <<- matrix
    maps[[length(maps) + 1L]] <<- map
    invisible(NULL)
  }

  if (isTRUE(include_person)) {
    theta <- mfrmr_constraint_jacobian_sparse(config$theta_spec, "Person")
    theta$map <- mfrmr_estimability_set_optimizer_index(
      theta$map, "theta", slices
    )
    append_block("theta", theta$jacobian[idx$person, , drop = FALSE],
                 theta$map)
  }

  for (facet in config$facet_names) {
    facet_block <- mfrmr_constraint_jacobian_sparse(
      config$facet_specs[[facet]], facet
    )
    sign <- as.numeric(config$facet_signs[[facet]] %||% -1)
    facet_block$map <- mfrmr_estimability_set_optimizer_index(
      facet_block$map, facet, slices
    )
    append_block(
      facet,
      sign * facet_block$jacobian[idx$facets[[facet]], , drop = FALSE],
      facet_block$map
    )
  }

  interaction_specs <- config$interaction_specs %||% list()
  if (length(interaction_specs) > 0L) {
    interaction_matrices <- list()
    interaction_maps <- list()
    for (name in names(interaction_specs)) {
      interaction <- mfrmr_interaction_jacobian_sparse(
        interaction_specs[[name]]
      )
      interaction_matrices[[length(interaction_matrices) + 1L]] <-
        interaction$jacobian[idx$interactions[[name]], , drop = FALSE]
      interaction_maps[[length(interaction_maps) + 1L]] <- interaction$map
    }
    interaction_matrix <- do.call(cbind, interaction_matrices)
    interaction_map <- do.call(rbind, interaction_maps)
    rownames(interaction_map) <- NULL
    interaction_map <- mfrmr_estimability_set_optimizer_index(
      interaction_map, "interactions", slices
    )
    append_block("interactions", interaction_matrix, interaction_map)
  }

  if (isTRUE(include_population_beta) &&
      isTRUE(config$population_spec$active) &&
      as.integer(sizes$beta %||% 0L) > 0L) {
    pop <- config$population_spec
    lookup <- as.integer(pop$person_lookup %||% integer(0))
    if (length(lookup) != config$n_person || anyNA(lookup[idx$person])) {
      stop("Internal estimability audit could not align population-model persons.",
           call. = FALSE)
    }
    beta_matrix <- as.matrix(pop$design_matrix)[lookup[idx$person], , drop = FALSE]
    beta_names <- colnames(beta_matrix)
    if (is.null(beta_names)) beta_names <- paste0("beta_", seq_len(ncol(beta_matrix)))
    beta_map <- mfrmr_estimability_map(
      Block = rep("beta", ncol(beta_matrix)),
      Coordinate = paste0("beta:", beta_names),
      Facet = rep("PersonPopulation", ncol(beta_matrix)),
      Level = beta_names,
      ReferenceLevel = rep("", ncol(beta_matrix)),
      Constraint = rep("population_location", ncol(beta_matrix)),
      OptimizerIndex = as.integer(slices$beta %||% rep(NA_integer_, ncol(beta_matrix)))
    )
    append_block(
      "beta", Matrix::Matrix(beta_matrix, sparse = TRUE), beta_map
    )
  }

  design <- if (length(blocks) == 0L) {
    mfrmr_empty_sparse_matrix(n_obs, 0L)
  } else {
    do.call(cbind, blocks)
  }
  map <- if (length(maps) == 0L) {
    mfrmr_estimability_map()
  } else {
    do.call(rbind, maps)
  }
  rownames(map) <- NULL
  list(design = design, map = map)
}

mfrmr_estimability_adjacent_design <- function(prep, idx, config, sizes,
                                                include_person = NULL,
                                                include_population_beta = NULL) {
  if (is.null(include_person)) {
    include_person <- identical(config$method, "JML")
  }
  if (is.null(include_population_beta)) {
    include_population_beta <- identical(config$method, "MML")
  }
  eta <- mfrmr_estimability_eta_design(
    prep = prep,
    idx = idx,
    config = config,
    sizes = sizes,
    include_person = include_person,
    include_population_beta = include_population_beta
  )
  n_obs <- nrow(eta$design)
  n_steps <- max(as.integer(config$n_cat %||% 0L) - 1L, 0L)
  if (n_steps <= 0L) {
    stop("Estimability audit requires at least two response categories.",
         call. = FALSE)
  }
  transition <- rep(seq_len(n_steps), each = n_obs)
  obs_index <- rep(seq_len(n_obs), times = n_steps)
  eta_repeated <- eta$design[obs_index, , drop = FALSE]

  step <- mfrmr_step_jacobian_sparse(config, sizes)
  step$map <- mfrmr_estimability_set_optimizer_index(
    step$map, "steps", build_param_slices(sizes)
  )
  expanded_step_index <- if (identical(config$model, "RSM")) {
    transition
  } else {
    scope <- rep(as.integer(idx$step_idx), times = n_steps)
    (scope - 1L) * n_steps + transition
  }
  step_selected <- step$jacobian[expanded_step_index, , drop = FALSE]
  design <- cbind(eta_repeated, -step_selected)
  map <- rbind(eta$map, step$map)
  rownames(map) <- NULL
  if (ncol(design) != nrow(map)) {
    stop("Internal estimability design/map dimension mismatch.", call. = FALSE)
  }
  list(
    design = methods::as(design, "dgCMatrix"),
    map = map,
    transition_rows = nrow(design),
    observation_rows = n_obs,
    transitions = n_steps
  )
}

mfrmr_estimability_null_directions <- function(scaled_design,
                                                parameter_map,
                                                rank,
                                                dense_element_limit = 2e6,
                                                max_directions = 5L,
                                                max_coordinates = 8L) {
  n_elements <- as.double(nrow(scaled_design)) * as.double(ncol(scaled_design))
  nullity <- ncol(scaled_design) - rank
  if (nullity <= 0L || n_elements > dense_element_limit ||
      ncol(scaled_design) == 0L) {
    return(data.frame())
  }
  dense <- as.matrix(scaled_design)
  sv <- tryCatch(
    base::svd(dense, nu = 0L, nv = ncol(dense)),
    error = function(e) NULL
  )
  if (is.null(sv) || is.null(sv$v) || ncol(sv$v) < ncol(dense)) {
    return(data.frame())
  }
  direction_idx <- seq.int(rank + 1L, ncol(dense))
  direction_idx <- utils::head(direction_idx, max_directions)
  rows <- lapply(seq_along(direction_idx), function(direction_number) {
    loadings <- sv$v[, direction_idx[direction_number]]
    keep <- order(abs(loadings), decreasing = TRUE)
    keep <- utils::head(keep, max_coordinates)
    data.frame(
      Direction = direction_number,
      Coordinate = parameter_map$Coordinate[keep],
      Block = parameter_map$Block[keep],
      Loading = as.numeric(loadings[keep]),
      AbsLoading = abs(as.numeric(loadings[keep])),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_estimability_rank_audit <- function(design, parameter_map,
                                           tolerances = c(1e-12, 1e-10, 1e-8),
                                           structural_tolerance = 1e-12) {
  design <- methods::as(design, "dgCMatrix")
  n_params <- ncol(design)
  if (n_params == 0L) {
    return(list(
      Rank = 0L,
      Nullity = 0L,
      State = "identified",
      ToleranceSensitive = FALSE,
      ToleranceRanks = data.frame(
        Tolerance = tolerances,
        Rank = 0L,
        Nullity = 0L
      ),
      ColumnNormMin = NA_real_,
      ColumnNormMax = NA_real_,
      SmallestSingularValue = NA_real_,
      ConditionIndex = NA_real_,
      ZeroCoordinates = character(0),
      NullDirections = data.frame()
    ))
  }

  norm_sq <- as.numeric(Matrix::colSums(design^2))
  norms <- sqrt(pmax(norm_sq, 0))
  zero <- !is.finite(norms) | norms == 0
  inverse_norm <- ifelse(zero, 1, 1 / norms)
  scaled <- design %*% Matrix::Diagonal(x = inverse_norm)
  scaled <- Matrix::drop0(methods::as(scaled, "dgCMatrix"))

  ranks <- vapply(tolerances, function(tolerance) {
    as.integer(Matrix::rankMatrix(
      scaled, method = "qr", tol = as.numeric(tolerance)
    ))
  }, integer(1))
  structural_index <- which.min(abs(tolerances - structural_tolerance))
  structural_rank <- ranks[structural_index]
  nullity <- n_params - structural_rank
  tolerance_sensitive <- length(unique(ranks)) > 1L
  state <- if (nullity > 0L) "structurally_unidentified" else "identified"

  smallest <- NA_real_
  condition_index <- NA_real_
  n_elements <- as.double(nrow(scaled)) * as.double(ncol(scaled))
  if (n_elements <= 2e6 && ncol(scaled) > 0L) {
    singular_values <- tryCatch(
      base::svd(as.matrix(scaled), nu = 0L, nv = 0L)$d,
      error = function(e) numeric(0)
    )
    if (length(singular_values) > 0L) {
      smallest <- min(singular_values)
      positive <- singular_values[singular_values > .Machine$double.eps]
      if (length(positive) > 0L) {
        condition_index <- max(singular_values) / min(positive)
      }
    }
  }

  list(
    Rank = as.integer(structural_rank),
    Nullity = as.integer(nullity),
    State = state,
    ToleranceSensitive = isTRUE(tolerance_sensitive),
    ToleranceRanks = data.frame(
      Tolerance = as.numeric(tolerances),
      Rank = as.integer(ranks),
      Nullity = as.integer(n_params - ranks),
      stringsAsFactors = FALSE
    ),
    ColumnNormMin = if (all(zero)) 0 else min(norms[!zero]),
    ColumnNormMax = if (all(zero)) 0 else max(norms[!zero]),
    SmallestSingularValue = smallest,
    ConditionIndex = condition_index,
    ZeroCoordinates = parameter_map$Coordinate[zero],
    NullDirections = mfrmr_estimability_null_directions(
      scaled_design = scaled,
      parameter_map = parameter_map,
      rank = structural_rank
    )
  )
}

mfrmr_information_rank_ladder <- function(hessian,
                                           tolerances = c(1e-10, 1e-8, 1e-6)) {
  hessian <- suppressWarnings(as.matrix(hessian))
  if (!is.numeric(hessian) || nrow(hessian) != ncol(hessian) ||
      length(hessian) == 0L || any(!is.finite(hessian))) {
    return(list(
      valid = FALSE,
      rank_ladder = data.frame(),
      eigenvalues = numeric(0),
      scale = NA_real_,
      smallest_eigenvalue = NA_real_,
      largest_eigenvalue = NA_real_
    ))
  }

  symmetric <- (hessian + t(hessian)) / 2
  eigenvalues <- tryCatch(
    as.numeric(eigen(symmetric, symmetric = TRUE, only.values = TRUE)$values),
    error = function(e) numeric(0)
  )
  if (length(eigenvalues) != nrow(symmetric) || any(!is.finite(eigenvalues))) {
    return(list(
      valid = FALSE,
      rank_ladder = data.frame(),
      eigenvalues = eigenvalues,
      scale = NA_real_,
      smallest_eigenvalue = NA_real_,
      largest_eigenvalue = NA_real_
    ))
  }

  scale <- max(abs(eigenvalues))
  thresholds <- if (is.finite(scale) && scale > 0) {
    scale * as.numeric(tolerances)
  } else {
    as.numeric(tolerances)
  }
  rank_ladder <- data.frame(
    RelativeTolerance = as.numeric(tolerances),
    AbsoluteThreshold = thresholds,
    PositiveRank = vapply(
      thresholds, function(threshold) sum(eigenvalues > threshold), integer(1)
    ),
    NegativeCount = vapply(
      thresholds, function(threshold) sum(eigenvalues < -threshold), integer(1)
    ),
    NearZeroCount = vapply(
      thresholds,
      function(threshold) sum(abs(eigenvalues) <= threshold),
      integer(1)
    ),
    stringsAsFactors = FALSE
  )

  list(
    valid = TRUE,
    rank_ladder = rank_ladder,
    eigenvalues = eigenvalues,
    scale = scale,
    smallest_eigenvalue = min(eigenvalues),
    largest_eigenvalue = max(eigenvalues)
  )
}

mfrmr_fitted_information_block_summary <- function(hessian,
                                                    sizes,
                                                    blocks) {
  slices <- build_param_slices(sizes)
  rows <- lapply(as.character(blocks), function(block) {
    slice <- as.integer(slices[[block]] %||% integer(0))
    diagonal <- if (length(slice) > 0L) {
      diag(hessian)[slice]
    } else {
      numeric(0)
    }
    data.frame(
      Block = block,
      FreeCoordinates = length(slice),
      OptimizerIndexStart = if (length(slice) > 0L) min(slice) else NA_integer_,
      OptimizerIndexEnd = if (length(slice) > 0L) max(slice) else NA_integer_,
      FiniteDiagonal = length(diagonal) > 0L && all(is.finite(diagonal)),
      MinimumDiagonal = if (length(diagonal) > 0L) min(diagonal) else NA_real_,
      MaximumDiagonal = if (length(diagonal) > 0L) max(diagonal) else NA_real_,
      stringsAsFactors = FALSE
    )
  })
  if (length(rows) == 0L) {
    return(data.frame(
      Block = character(0),
      FreeCoordinates = integer(0),
      OptimizerIndexStart = integer(0),
      OptimizerIndexEnd = integer(0),
      FiniteDiagonal = logical(0),
      MinimumDiagonal = numeric(0),
      MaximumDiagonal = numeric(0),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, rows)
}

audit_mfrm_fitted_information <- function(opt,
                                          idx,
                                          config,
                                          sizes,
                                          quad_points,
                                          nonlinear_blocks,
                                          max_free_dimension = 80L,
                                          tolerances = c(1e-10, 1e-8, 1e-6)) {
  nonlinear_blocks <- as.character(nonlinear_blocks %||% character(0))
  free_dimension <- sum(vapply(sizes, as.integer, integer(1)))
  base <- list(
    role = "observed_negative_loglikelihood_hessian_at_retained_solution",
    evaluation_point = "retained_optimizer_free_coordinate_vector",
    method = as.character(config$method),
    model = as.character(config$model),
    nonlinear_blocks = nonlinear_blocks,
    attempted = FALSE,
    status = "not_required",
    free_dimension = as.integer(free_dimension),
    dimension_limit = as.integer(max_free_dimension),
    hessian_elements = as.double(free_dimension)^2,
    numerical_differentiation = list(
      method = "central_difference_of_analytical_gradient_via_stats_optimHess",
      parameter_scale = 1,
      free_coordinate_step = 1e-3
    ),
    evaluation_summary = data.frame(
      RetainedObjective = NA_real_,
      ReevaluatedObjective = NA_real_,
      ObjectiveDifference = NA_real_,
      GradientMaxAbs = NA_real_,
      MaximumHessianAsymmetry = NA_real_,
      stringsAsFactors = FALSE
    ),
    rank_ladder = data.frame(),
    block_summary = mfrmr_fitted_information_block_summary(
      matrix(numeric(0), nrow = 0L, ncol = 0L), sizes, character(0)
    ),
    eigenvalue_summary = data.frame(
      Smallest = NA_real_,
      Largest = NA_real_,
      AbsoluteScale = NA_real_,
      stringsAsFactors = FALSE
    ),
    weak_information_classified = FALSE,
    readiness_effect = "none_pending_pilot_calibrated_rule",
    detail = "No nonlinear free-coordinate block required this fitted-information slice."
  )

  if (length(nonlinear_blocks) == 0L) return(base)

  severity <- as.character(
    opt$optimizer_diagnostics$ConvergenceSeverity %||% NA_character_
  )
  if (!identical(severity, "pass")) {
    base$status <- "not_evaluated_nonstationary"
    base$detail <- paste(
      "Fitted information was not evaluated because the retained optimizer",
      "state did not pass the terminal numerical stationarity gate."
    )
    return(base)
  }
  if (free_dimension <= 0L || is.null(opt$par) ||
      length(opt$par) != free_dimension || any(!is.finite(opt$par))) {
    base$status <- "not_evaluated_parameter_vector"
    base$detail <- paste(
      "Fitted information was not evaluated because the retained free",
      "parameter vector was unavailable, non-finite, or dimensionally inconsistent."
    )
    return(base)
  }
  if (free_dimension > as.integer(max_free_dimension)) {
    base$status <- "not_evaluated_dimension_limit"
    base$detail <- paste0(
      "Fitted information requires a dense ", free_dimension, " x ",
      free_dimension, " Hessian, exceeding the instrumentation limit of ",
      as.integer(max_free_dimension), ". This is an execution limit, not an ",
      "estimability classification."
    )
    return(base)
  }

  quad <- gauss_hermite_normal(max(1L, as.integer(quad_points)))
  cache <- make_param_cache(
    sizes = sizes,
    config = config,
    idx = idx,
    is_mml = identical(config$method, "MML")
  )
  evaluator <- make_mfrm_direct_evaluator(
    method = config$method,
    cache = cache,
    idx = idx,
    config = config,
    sizes = sizes,
    quad = quad
  )
  evaluation <- tryCatch(
    list(
      value = as.numeric(evaluator$value(opt$par)),
      gradient = as.numeric(evaluator$gradient(opt$par))
    ),
    error = function(e) list(value = NA_real_, gradient = numeric(0))
  )
  parameter_scale <- rep(1, free_dimension)
  difference_step <- rep(1e-3, free_dimension)
  hessian <- tryCatch(
    stats::optimHess(
      par = opt$par,
      fn = evaluator$value,
      gr = evaluator$gradient,
      control = list(
        fnscale = 1,
        parscale = parameter_scale,
        ndeps = difference_step
      )
    ),
    error = function(e) e
  )
  base$attempted <- TRUE
  if (inherits(hessian, "error") || is.null(hessian)) {
    base$status <- "unavailable"
    base$detail <- paste0(
      "Fitted-information Hessian was unavailable: ",
      if (inherits(hessian, "error")) conditionMessage(hessian) else "unknown error",
      "."
    )
    return(base)
  }

  hessian <- suppressWarnings(as.matrix(hessian))
  retained_objective <- as.numeric(opt$value %||% NA_real_)
  reevaluated_objective <- as.numeric(evaluation$value[1] %||% NA_real_)
  objective_difference <- if (is.finite(retained_objective) &&
                              is.finite(reevaluated_objective)) {
    reevaluated_objective - retained_objective
  } else {
    NA_real_
  }
  gradient_max_abs <- if (length(evaluation$gradient) > 0L &&
                          all(is.finite(evaluation$gradient))) {
    max(abs(evaluation$gradient))
  } else {
    NA_real_
  }
  maximum_asymmetry <- if (nrow(hessian) == ncol(hessian) &&
                           all(is.finite(hessian))) {
    max(abs(hessian - t(hessian)))
  } else {
    NA_real_
  }
  ladder <- mfrmr_information_rank_ladder(
    hessian = hessian,
    tolerances = tolerances
  )
  if (!isTRUE(ladder$valid)) {
    base$status <- "unavailable"
    base$detail <- paste(
      "Fitted-information Hessian or its symmetric eigenvalue decomposition",
      "was non-finite or unavailable."
    )
    return(base)
  }

  base$status <- "evaluated_diagnostic_only"
  base$evaluation_summary <- data.frame(
    RetainedObjective = retained_objective,
    ReevaluatedObjective = reevaluated_objective,
    ObjectiveDifference = objective_difference,
    GradientMaxAbs = gradient_max_abs,
    MaximumHessianAsymmetry = maximum_asymmetry,
    stringsAsFactors = FALSE
  )
  base$rank_ladder <- ladder$rank_ladder
  base$block_summary <- mfrmr_fitted_information_block_summary(
    hessian = hessian,
    sizes = sizes,
    blocks = nonlinear_blocks
  )
  base$eigenvalue_summary <- data.frame(
    Smallest = ladder$smallest_eigenvalue,
    Largest = ladder$largest_eigenvalue,
    AbsoluteScale = ladder$scale,
    stringsAsFactors = FALSE
  )
  base$detail <- paste(
    "The retained solution was evaluated through a dense numerical Hessian",
    "of the same negative log-likelihood and analytical gradient used by the",
    "direct optimizer, using a recorded free-coordinate difference step.",
    "The tolerance ladder is diagnostic only; it does not",
    "classify weak information or change readiness before pilot calibration."
  )
  base
}

audit_mfrm_estimability <- function(prep, idx, config, sizes) {
  primary <- mfrmr_estimability_adjacent_design(
    prep = prep, idx = idx, config = config, sizes = sizes
  )
  rank_audit <- mfrmr_estimability_rank_audit(
    primary$design, primary$map
  )

  nonlinear_blocks <- names(sizes)[
    names(sizes) %in% c("log_slopes", "log_sigma2") &
      vapply(sizes[names(sizes) %in% c("log_slopes", "log_sigma2")],
             function(x) as.integer(x %||% 0L) > 0L, logical(1))
  ]
  complete <- length(nonlinear_blocks) == 0L

  counterfactual <- NULL
  population_assumption_linked <- FALSE
  if (identical(config$method, "MML")) {
    counter_design <- mfrmr_estimability_adjacent_design(
      prep = prep,
      idx = idx,
      config = config,
      sizes = sizes,
      include_person = TRUE,
      include_population_beta = FALSE
    )
    counter_rank <- mfrmr_estimability_rank_audit(
      counter_design$design, counter_design$map
    )
    population_assumption_linked <-
      identical(rank_audit$State, "identified") &&
      identical(counter_rank$State, "structurally_unidentified")
    counterfactual <- list(
      Role = "same fixed-effect structure with free JML Person coordinates",
      Rank = counter_rank$Rank,
      Nullity = counter_rank$Nullity,
      State = counter_rank$State,
      FreeDimension = ncol(counter_design$design),
      ToleranceRanks = counter_rank$ToleranceRanks
    )
  }

  subsets <- calc_subsets(prep$data, c("Person", prep$facet_names))
  components <- nrow(as.data.frame(subsets$summary %||% data.frame()))
  disconnected <- is.finite(components) && components > 1L

  state <- rank_audit$State
  reason_codes <- character(0)
  if (identical(state, "structurally_unidentified")) {
    reason_codes <- c(reason_codes, "design_rank_deficient")
    if (disconnected) {
      reason_codes <- c(reason_codes, "disconnected_without_link")
    }
  } else if (isTRUE(population_assumption_linked)) {
    state <- "population_assumption_linked"
    reason_codes <- c(reason_codes, "population_assumption_linked")
  }
  if (!isTRUE(complete)) {
    reason_codes <- c(reason_codes, "design_rank_not_evaluated")
  }
  reason_codes <- unique(reason_codes)

  optimizer_dimension <- sum(vapply(sizes, as.integer, integer(1)))
  block_summary <- if (nrow(primary$map) == 0L) {
    data.frame(Block = character(0), FreeCoordinates = integer(0))
  } else {
    stats::aggregate(
      rep(1L, nrow(primary$map)),
      by = list(Block = primary$map$Block),
      FUN = sum
    ) |>
      stats::setNames(c("Block", "FreeCoordinates"))
  }
  null_blocks <- if (nrow(rank_audit$NullDirections) == 0L) {
    data.frame(Block = character(0), Appearances = integer(0))
  } else {
    stats::aggregate(
      rep(1L, nrow(rank_audit$NullDirections)),
      by = list(Block = rank_audit$NullDirections$Block),
      FUN = sum
    ) |>
      stats::setNames(c("Block", "Appearances"))
  }

  readiness <- data.frame(
    ReadinessContractVersion = mfrmr_estimability_contract_version(),
    ReadinessScope = "fit",
    EstimabilityState = state,
    ReasonCodes = paste(reason_codes, collapse = ";"),
    Complete = isTRUE(complete),
    AuditedFreeDimension = ncol(primary$design),
    OptimizerFreeDimension = optimizer_dimension,
    Rank = rank_audit$Rank,
    Nullity = rank_audit$Nullity,
    PopulationAssumptionLinked = isTRUE(population_assumption_linked),
    stringsAsFactors = FALSE
  )

  list(
    contract_version = mfrmr_estimability_contract_version(),
    method = config$method,
    model = config$model,
    readiness = readiness,
    complete = isTRUE(complete),
    nonlinear_blocks = nonlinear_blocks,
    design = list(
      role = "adjacent_category_logit_constrained_free_coordinate_design",
      observation_rows = primary$observation_rows,
      transition_rows = primary$transition_rows,
      transitions = primary$transitions,
      free_dimension = ncol(primary$design),
      nonzero_entries = length(primary$design@x),
      rank = rank_audit$Rank,
      nullity = rank_audit$Nullity,
      state = rank_audit$State,
      tolerance_sensitive = isTRUE(rank_audit$ToleranceSensitive),
      tolerance_ranks = rank_audit$ToleranceRanks,
      column_norm_min = rank_audit$ColumnNormMin,
      column_norm_max = rank_audit$ColumnNormMax,
      smallest_singular_value = rank_audit$SmallestSingularValue,
      condition_index = rank_audit$ConditionIndex
    ),
    parameter_blocks = block_summary,
    parameter_map = primary$map,
    zero_coordinates = rank_audit$ZeroCoordinates,
    null_directions = rank_audit$NullDirections,
    null_blocks = null_blocks,
    observed_components = as.integer(components),
    counterfactual_jml = counterfactual,
    population_assumption_linked = isTRUE(population_assumption_linked),
    fitted_information = list(
      status = if (length(nonlinear_blocks) > 0L) {
        "pending_after_optimization"
      } else {
        "pending_weak_information_calibration"
      },
      attempted = FALSE,
      nonlinear_blocks = nonlinear_blocks,
      weak_information_classified = FALSE,
      readiness_effect = "none_pending_pilot_calibrated_rule"
    )
  )
}

mfrmr_estimability_condition <- function(message, audit,
                                          type = c("error", "warning")) {
  type <- match.arg(type)
  subclass <- if (identical(type, "error")) {
    "mfrmr_estimability_error"
  } else {
    "mfrmr_estimability_warning"
  }
  structure(
    list(
      message = as.character(message),
      call = NULL,
      readiness = audit$readiness,
      estimability = audit
    ),
    class = c(
      subclass,
      "mfrmr_readiness_condition",
      type,
      "condition"
    )
  )
}

mfrmr_stop_unidentified <- function(audit) {
  affected <- as.character(audit$null_blocks$Block %||% character(0))
  affected <- affected[!is.na(affected) & nzchar(affected)]
  affected_text <- if (length(affected) > 0L) {
    paste0(" Affected free-coordinate blocks include ",
           paste(affected, collapse = ", "), ".")
  } else {
    ""
  }
  message <- paste0(
    "The estimator-specific constrained design is structurally unidentified ",
    "(rank ", audit$design$rank, " of ", audit$design$free_dimension,
    "; nullity ", audit$design$nullity, "). Optimization was not run.",
    affected_text,
    " Change the observation design or supply defensible identifying anchors."
  )
  stop(mfrmr_estimability_condition(message, audit, type = "error"))
}

mfrmr_warn_estimability <- function(audit) {
  state <- as.character(audit$readiness$EstimabilityState[1])
  message <- if (identical(state, "population_assumption_linked")) {
    paste(
      "The MML fixed-effect design is full rank, but the corresponding",
      "free-Person JML design is rank deficient. Cross-panel identification",
      "therefore relies on the common latent-population assumption; review",
      "assignment and population invariance before reporting facet contrasts."
    )
  } else {
    paste0(
      "The constrained design is full rank only at the strictest audited ",
      "tolerance. Treat this fit as weak-information review rather than as ",
      "an exact nonidentification failure."
    )
  }
  warning(mfrmr_estimability_condition(message, audit, type = "warning"))
  invisible(audit)
}
