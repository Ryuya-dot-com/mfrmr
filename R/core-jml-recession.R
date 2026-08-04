# Constrained JML structural recession audit
# ==============================================================================
#
# This audit asks a narrower question than the Person sufficient-score rule:
# holding all Person coordinates fixed, is there a direction in the retained
# additive structural parameter space along which every observed category is
# at least as well supported as every alternative category and at least one
# comparison improves?  The exact optimizer expansion is reused, so facet
# signs, direct/group anchors, sum-zero constraints, interactions, and steps
# enter the linear program without being reconstructed from response totals.
#
# The result is deliberately an internal certificate instrument.  It does not
# yet overwrite the finite optimizer iterate in public facet, interaction, or
# step tables.  That promotion belongs to the cross-surface propagation work
# after the certificate and target mapping have been stress-tested.

mfrmr_jml_recession_empty_target_table <- function() {
  data.frame(
    ParameterId = character(0),
    ParameterClass = character(0),
    Facet = character(0),
    Level = character(0),
    OptimizerEstimate = numeric(0),
    PositiveRecession = logical(0),
    NegativeRecession = logical(0),
    CandidateStatus = character(0),
    EvaluationState = character(0),
    ReasonCodes = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_recession_empty_certificate_table <- function() {
  data.frame(
    ParameterId = character(0),
    RequestedDirection = character(0),
    SolverStatus = integer(0),
    TargetCapacity = numeric(0),
    TargetChange = numeric(0),
    MinimumContrastMargin = numeric(0),
    PositiveContrastMargin = numeric(0),
    StrictContrastRows = integer(0),
    DirectionL1 = numeric(0),
    Certified = logical(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_recession_empty_loading_table <- function() {
  data.frame(
    ParameterId = character(0),
    RequestedDirection = character(0),
    OptimizerIndex = integer(0),
    Coordinate = character(0),
    Loading = numeric(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_observed_contrast_design <- function(adjacent_design,
                                                score_k,
                                                n_obs,
                                                n_steps) {
  adjacent_design <- methods::as(adjacent_design, "dgCMatrix")
  score_k <- suppressWarnings(as.integer(score_k))
  n_obs <- as.integer(n_obs)
  n_steps <- as.integer(n_steps)
  if (n_obs < 1L || n_steps < 1L || length(score_k) != n_obs ||
      nrow(adjacent_design) != n_obs * n_steps ||
      anyNA(score_k) || any(score_k < 0L | score_k > n_steps)) {
    stop("Internal JML recession audit received a malformed adjacent design.",
         call. = FALSE)
  }

  rows_per_observation <- n_steps
  n_contrasts <- n_obs * rows_per_observation
  row_i <- integer(0)
  col_j <- integer(0)
  values <- numeric(0)
  contrast_cursor <- 0L

  for (observation in seq_len(n_obs)) {
    observed <- score_k[observation]
    alternatives <- setdiff(0:n_steps, observed)
    for (alternative in alternatives) {
      contrast_cursor <- contrast_cursor + 1L
      if (alternative < observed) {
        transitions <- seq.int(alternative + 1L, observed)
        signs <- rep(1, length(transitions))
      } else {
        transitions <- seq.int(observed + 1L, alternative)
        signs <- rep(-1, length(transitions))
      }
      adjacent_rows <- (transitions - 1L) * n_obs + observation
      row_i <- c(row_i, rep.int(contrast_cursor, length(adjacent_rows)))
      col_j <- c(col_j, adjacent_rows)
      values <- c(values, signs)
    }
  }

  contrast_operator <- Matrix::sparseMatrix(
    i = row_i,
    j = col_j,
    x = values,
    dims = c(n_contrasts, nrow(adjacent_design))
  )
  methods::as(contrast_operator %*% adjacent_design, "dgCMatrix")
}

mfrmr_jml_structural_target_system <- function(config, sizes, params) {
  slices <- build_param_slices(sizes)
  total_parameters <- sum(as.integer(unlist(sizes, use.names = FALSE)))
  target_rows <- list()
  triplet_i <- integer(0)
  triplet_j <- integer(0)
  triplet_x <- numeric(0)
  row_cursor <- 0L

  append_targets <- function(metadata, jacobian, optimizer_slice) {
    metadata <- as.data.frame(metadata, stringsAsFactors = FALSE)
    jacobian <- methods::as(jacobian, "dgCMatrix")
    optimizer_slice <- as.integer(optimizer_slice)
    if (nrow(metadata) != nrow(jacobian) ||
        ncol(jacobian) != length(optimizer_slice)) {
      stop("Internal JML recession target-map dimension mismatch.",
           call. = FALSE)
    }
    if (nrow(metadata) == 0L) return(invisible(NULL))
    target_rows[[length(target_rows) + 1L]] <<- metadata
    nonzero <- Matrix::summary(jacobian)
    if (nrow(nonzero) > 0L) {
      triplet_i <<- c(triplet_i, row_cursor + nonzero$i)
      triplet_j <<- c(triplet_j, optimizer_slice[nonzero$j])
      triplet_x <<- c(triplet_x, nonzero$x)
    }
    row_cursor <<- row_cursor + nrow(metadata)
    invisible(NULL)
  }

  for (facet in config$facet_names) {
    levels <- as.character(config$facet_specs[[facet]]$levels %||%
                             config$facet_levels[[facet]] %||% character(0))
    jacobian <- mfrmr_constraint_jacobian_sparse(
      config$facet_specs[[facet]], facet
    )$jacobian
    append_targets(
      data.frame(
        ParameterId = paste0("Facet:", facet, ":", levels),
        ParameterClass = "facet",
        Facet = facet,
        Level = levels,
        OptimizerEstimate = as.numeric(params$facets[[facet]]),
        stringsAsFactors = FALSE
      ),
      jacobian,
      slices[[facet]] %||% integer(0)
    )
  }

  interaction_specs <- config$interaction_specs %||% list()
  interaction_slice <- as.integer(slices$interactions %||% integer(0))
  interaction_cursor <- 0L
  if (length(interaction_specs) > 0L) {
    for (name in names(interaction_specs)) {
      spec <- interaction_specs[[name]]
      built <- mfrmr_interaction_jacobian_sparse(spec)
      local_n <- ncol(built$jacobian)
      local_slice <- if (local_n > 0L) {
        interaction_slice[interaction_cursor + seq_len(local_n)]
      } else {
        integer(0)
      }
      interaction_cursor <- interaction_cursor + local_n
      grid <- expand.grid(
        FacetA_Level = as.character(spec$levels_a),
        FacetB_Level = as.character(spec$levels_b),
        KEEP.OUT.ATTRS = FALSE,
        stringsAsFactors = FALSE
      )
      cell_level <- paste(grid$FacetA_Level, grid$FacetB_Level, sep = "*")
      append_targets(
        data.frame(
          ParameterId = paste0("Interaction:", name, ":", cell_level),
          ParameterClass = "interaction",
          Facet = name,
          Level = cell_level,
          OptimizerEstimate = as.numeric(params$interactions[[name]]),
          stringsAsFactors = FALSE
        ),
        built$jacobian,
        local_slice
      )
    }
  }

  step_built <- mfrmr_step_jacobian_sparse(config, sizes)
  n_steps <- max(as.integer(config$n_cat %||% 0L) - 1L, 0L)
  step_scopes <- if (identical(config$model, "RSM")) {
    "shared"
  } else {
    as.character(config$facet_levels[[config$step_facet]] %||% character(0))
  }
  step_grid <- if (length(step_scopes) > 0L && n_steps > 0L) {
    expand.grid(
      Step = paste0("Step_", seq_len(n_steps)),
      Scope = step_scopes,
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    )[, c("Scope", "Step"), drop = FALSE]
  } else {
    data.frame(Scope = character(0), Step = character(0))
  }
  step_estimates <- if (identical(config$model, "RSM")) {
    as.numeric(params$steps)
  } else {
    as.numeric(t(params$steps_mat))
  }
  append_targets(
    data.frame(
      ParameterId = paste0("Step:", step_grid$Scope, ":", step_grid$Step),
      ParameterClass = "step",
      Facet = if (identical(config$model, "RSM")) {
        "shared_rating_scale"
      } else {
        config$step_facet
      },
      Level = paste(step_grid$Scope, step_grid$Step, sep = "*"),
      OptimizerEstimate = step_estimates,
      stringsAsFactors = FALSE
    ),
    step_built$jacobian,
    slices$steps %||% integer(0)
  )

  metadata <- if (length(target_rows) == 0L) {
    mfrmr_jml_recession_empty_target_table()[, c(
      "ParameterId", "ParameterClass", "Facet", "Level",
      "OptimizerEstimate"
    )]
  } else {
    do.call(rbind, target_rows)
  }
  rownames(metadata) <- NULL
  expansion <- Matrix::sparseMatrix(
    i = triplet_i,
    j = triplet_j,
    x = triplet_x,
    dims = c(nrow(metadata), total_parameters)
  )
  list(metadata = metadata, expansion = methods::as(expansion, "dgCMatrix"))
}

mfrmr_jml_recession_lp_base <- function(contrast_design) {
  contrast_design <- as.matrix(contrast_design)
  n_parameters <- ncol(contrast_design)
  constraint_matrix <- rbind(
    cbind(contrast_design, -contrast_design),
    cbind(diag(n_parameters), diag(n_parameters))
  )
  list(
    contrast_design = contrast_design,
    constraint_matrix = constraint_matrix,
    constraint_direction = c(
      rep(">=", nrow(contrast_design)),
      rep("<=", n_parameters)
    ),
    constraint_rhs = c(
      rep(0, nrow(contrast_design)),
      rep(1, n_parameters)
    )
  )
}

mfrmr_jml_recession_target_lp <- function(lp_base,
                                           target,
                                           objective_tolerance = 1e-7,
                                           certificate_tolerance = 1e-7,
                                           timeout = 5L) {
  target <- as.numeric(target)
  n_parameters <- length(target)
  signed_target <- c(target, -target)
  capacity_fit <- tryCatch(
    lpSolve::lp(
      direction = "max",
      objective.in = signed_target,
      const.mat = lp_base$constraint_matrix,
      const.dir = lp_base$constraint_direction,
      const.rhs = lp_base$constraint_rhs,
      timeout = as.integer(timeout)
    ),
    error = function(e) e
  )
  if (inherits(capacity_fit, "error") ||
      !identical(as.integer(capacity_fit$status %||% -1L), 0L)) {
    return(list(
      evaluated = FALSE,
      certified = FALSE,
      solver_status = if (inherits(capacity_fit, "error")) {
        NA_integer_
      } else {
        as.integer(capacity_fit$status)
      },
      target_capacity = NA_real_,
      target_change = NA_real_,
      minimum_margin = NA_real_,
      positive_margin = NA_real_,
      strict_rows = NA_integer_,
      direction = rep(NA_real_, n_parameters),
      reason = "linear_program_capacity_failed"
    ))
  }

  capacity <- as.numeric(capacity_fit$objval)
  if (!is.finite(capacity) || capacity <= 10 * objective_tolerance) {
    return(list(
      evaluated = TRUE,
      certified = FALSE,
      solver_status = as.integer(capacity_fit$status),
      target_capacity = capacity,
      target_change = 0,
      minimum_margin = 0,
      positive_margin = 0,
      strict_rows = 0L,
      direction = rep(0, n_parameters),
      reason = "no_target_recession_direction"
    ))
  }

  target_floor <- max(objective_tolerance * 2, capacity * 1e-5)
  augmented_matrix <- rbind(lp_base$constraint_matrix, signed_target)
  augmented_direction <- c(lp_base$constraint_direction, ">=")
  augmented_rhs <- c(lp_base$constraint_rhs, target_floor)
  strict_objective <- colSums(lp_base$contrast_design)
  strict_fit <- tryCatch(
    lpSolve::lp(
      direction = "max",
      objective.in = c(strict_objective, -strict_objective),
      const.mat = augmented_matrix,
      const.dir = augmented_direction,
      const.rhs = augmented_rhs,
      timeout = as.integer(timeout)
    ),
    error = function(e) e
  )
  if (inherits(strict_fit, "error") ||
      !identical(as.integer(strict_fit$status %||% -1L), 0L)) {
    return(list(
      evaluated = FALSE,
      certified = FALSE,
      solver_status = if (inherits(strict_fit, "error")) {
        NA_integer_
      } else {
        as.integer(strict_fit$status)
      },
      target_capacity = capacity,
      target_change = NA_real_,
      minimum_margin = NA_real_,
      positive_margin = NA_real_,
      strict_rows = NA_integer_,
      direction = rep(NA_real_, n_parameters),
      reason = "linear_program_strictness_failed"
    ))
  }

  solution <- as.numeric(strict_fit$solution)
  direction <- solution[seq_len(n_parameters)] -
    solution[n_parameters + seq_len(n_parameters)]
  margins <- as.numeric(lp_base$contrast_design %*% direction)
  target_change <- sum(target * direction)
  minimum_margin <- min(margins)
  positive_margin <- sum(pmax(margins, 0))
  strict_rows <- sum(margins > certificate_tolerance)
  certified <- is.finite(target_change) &&
    target_change > objective_tolerance &&
    is.finite(minimum_margin) &&
    minimum_margin >= -certificate_tolerance &&
    is.finite(positive_margin) &&
    positive_margin > objective_tolerance &&
    strict_rows > 0L

  list(
    evaluated = TRUE,
    certified = isTRUE(certified),
    solver_status = as.integer(strict_fit$status),
    target_capacity = capacity,
    target_change = target_change,
    minimum_margin = minimum_margin,
    positive_margin = positive_margin,
    strict_rows = as.integer(strict_rows),
    direction = direction,
    reason = if (isTRUE(certified)) {
      "certified_additive_recession_direction"
    } else {
      "candidate_failed_postsolve_certificate"
    }
  )
}

audit_mfrm_jml_structural_recession <- function(prep,
                                                 idx,
                                                 config,
                                                 sizes,
                                                 params,
                                                 max_lp_elements = 2e6,
                                                 max_target_directions = 200L,
                                                 lp_timeout = 2L) {
  method <- as.character(config$method %||% NA_character_)
  model <- as.character(config$model %||% NA_character_)
  empty_targets <- mfrmr_jml_recession_empty_target_table()
  empty_certificates <- mfrmr_jml_recession_empty_certificate_table()
  empty_loadings <- mfrmr_jml_recession_empty_loading_table()

  finish <- function(state, complete, detail,
                     target_status = empty_targets,
                     certificates = empty_certificates,
                     loadings = empty_loadings,
                     dimensions = data.frame()) {
    list(
      contract_version = mfrmr_boundary_contract_version(),
      method = method,
      model = model,
      scope = "JML structural additive coordinates with Person fixed",
      state = state,
      complete = isTRUE(complete),
      target_status = target_status,
      certificates = certificates,
      direction_loadings = loadings,
      dimensions = dimensions,
      detail = detail,
      limitations = paste(
        "This bounded audit certifies additive structural recession directions",
        "with Person coordinates fixed. GPCM log-slope recession, directions",
        "requiring joint Person movement, and public-table propagation are not",
        "part of this implementation slice."
      )
    )
  }

  if (!identical(method, "JML")) {
    return(finish(
      "not_applicable_mml", TRUE,
      "Structural fixed-effect recession certification is scoped to JML."
    ))
  }
  if (!requireNamespace("lpSolve", quietly = TRUE)) {
    return(finish(
      "not_evaluated_dependency", FALSE,
      "Package 'lpSolve' is required for the bounded internal certificate."
    ))
  }

  adjacent <- tryCatch(
    mfrmr_estimability_adjacent_design(
      prep = prep,
      idx = idx,
      config = config,
      sizes = sizes,
      include_person = TRUE,
      include_population_beta = FALSE
    ),
    error = function(e) e
  )
  if (inherits(adjacent, "error")) {
    return(finish(
      "not_evaluated_design", FALSE,
      paste0("Adjacent design construction failed: ", conditionMessage(adjacent))
    ))
  }

  structural_columns <- which(adjacent$map$Block != "Person")
  structural_map <- adjacent$map[structural_columns, , drop = FALSE]
  structural_optimizer_index <- as.integer(structural_map$OptimizerIndex)
  target_system <- tryCatch(
    mfrmr_jml_structural_target_system(config, sizes, params),
    error = function(e) e
  )
  if (inherits(target_system, "error")) {
    return(finish(
      "not_evaluated_mapping", FALSE,
      paste0("Expanded target mapping failed: ", conditionMessage(target_system))
    ))
  }
  targets <- target_system$metadata
  if (length(structural_columns) == 0L) {
    targets$PositiveRecession <- FALSE
    targets$NegativeRecession <- FALSE
    targets$CandidateStatus <- "fixed"
    targets$EvaluationState <- "evaluated"
    targets$ReasonCodes <- "no_free_coordinate"
    dimensions <- data.frame(
      Observations = as.integer(adjacent$observation_rows),
      Categories = as.integer(adjacent$transitions + 1L),
      ContrastRows = as.integer(adjacent$transition_rows),
      StructuralFreeCoordinates = 0L,
      ExpandedTargets = as.integer(nrow(targets)),
      FreeTargets = 0L,
      TargetDirections = 0L,
      DenseLPElements = 0,
      stringsAsFactors = FALSE
    )
    return(finish(
      "no_free_structural_coordinates", TRUE,
      "No additive structural free coordinates were present.",
      target_status = targets,
      dimensions = dimensions
    ))
  }
  if (anyNA(structural_optimizer_index) ||
      anyDuplicated(structural_optimizer_index)) {
    return(finish(
      "not_evaluated_mapping", FALSE,
      "Structural optimizer-coordinate mapping was incomplete or duplicated."
    ))
  }

  contrast <- tryCatch(
    mfrmr_jml_observed_contrast_design(
      adjacent_design = adjacent$design[, structural_columns, drop = FALSE],
      score_k = idx$score_k,
      n_obs = adjacent$observation_rows,
      n_steps = adjacent$transitions
    ),
    error = function(e) e
  )
  if (inherits(contrast, "error")) {
    return(finish(
      "not_evaluated_contrast", FALSE,
      paste0("Observed-category contrast construction failed: ",
             conditionMessage(contrast))
    ))
  }

  target_expansion <- target_system$expansion[
    , structural_optimizer_index, drop = FALSE
  ]
  if (nrow(targets) != nrow(target_expansion)) {
    return(finish(
      "not_evaluated_mapping", FALSE,
      "Expanded target metadata and Jacobian rows did not align."
    ))
  }

  free_target <- as.numeric(Matrix::rowSums(abs(target_expansion))) > 0
  target_directions <- 2L * sum(free_target)
  lp_elements <- as.double(nrow(contrast) + ncol(contrast) + 1L) *
    as.double(2L * ncol(contrast))
  dimensions <- data.frame(
    Observations = as.integer(adjacent$observation_rows),
    Categories = as.integer(adjacent$transitions + 1L),
    ContrastRows = as.integer(nrow(contrast)),
    StructuralFreeCoordinates = as.integer(ncol(contrast)),
    ExpandedTargets = as.integer(nrow(targets)),
    FreeTargets = as.integer(sum(free_target)),
    TargetDirections = as.integer(target_directions),
    DenseLPElements = as.double(lp_elements),
    stringsAsFactors = FALSE
  )
  if (lp_elements > as.double(max_lp_elements) ||
      target_directions > as.integer(max_target_directions)) {
    targets$PositiveRecession <- NA
    targets$NegativeRecession <- NA
    targets$CandidateStatus <- ifelse(
      free_target, "not_evaluated_size_limit", "fixed"
    )
    targets$EvaluationState <- ifelse(
      free_target, "not_evaluated", "evaluated"
    )
    targets$ReasonCodes <- ifelse(
      free_target, "bounded_lp_size_limit", "no_free_coordinate"
    )
    return(finish(
      "not_evaluated_size_limit", FALSE,
      paste0(
        "The bounded LP audit exceeded its current execution limit (",
        format(lp_elements, scientific = FALSE), " dense elements; ",
        target_directions, " target directions)."
      ),
      target_status = targets,
      dimensions = dimensions
    ))
  }

  lp_base <- mfrmr_jml_recession_lp_base(contrast)
  certificate_rows <- list()
  loading_rows <- list()
  positive <- negative <- rep(FALSE, nrow(targets))
  evaluated_positive <- evaluated_negative <- !free_target
  certificate_cursor <- 0L
  loading_cursor <- 0L

  for (target_index in which(free_target)) {
    target_vector <- as.numeric(target_expansion[target_index, ])
    for (requested in c("positive", "negative")) {
      signed_vector <- if (identical(requested, "positive")) {
        target_vector
      } else {
        -target_vector
      }
      solved <- mfrmr_jml_recession_target_lp(
        lp_base = lp_base,
        target = signed_vector,
        timeout = lp_timeout
      )
      if (identical(requested, "positive")) {
        evaluated_positive[target_index] <- isTRUE(solved$evaluated)
        positive[target_index] <- isTRUE(solved$certified)
      } else {
        evaluated_negative[target_index] <- isTRUE(solved$evaluated)
        negative[target_index] <- isTRUE(solved$certified)
      }
      certificate_cursor <- certificate_cursor + 1L
      certificate_rows[[certificate_cursor]] <- data.frame(
        ParameterId = targets$ParameterId[target_index],
        RequestedDirection = requested,
        SolverStatus = as.integer(solved$solver_status),
        TargetCapacity = as.numeric(solved$target_capacity),
        TargetChange = as.numeric(solved$target_change),
        MinimumContrastMargin = as.numeric(solved$minimum_margin),
        PositiveContrastMargin = as.numeric(solved$positive_margin),
        StrictContrastRows = as.integer(solved$strict_rows),
        DirectionL1 = sum(abs(as.numeric(solved$direction)), na.rm = TRUE),
        Certified = isTRUE(solved$certified),
        stringsAsFactors = FALSE
      )
      if (isTRUE(solved$certified)) {
        keep <- which(abs(solved$direction) > 1e-9)
        if (length(keep) > 0L) {
          loading_cursor <- loading_cursor + 1L
          loading_rows[[loading_cursor]] <- data.frame(
            ParameterId = targets$ParameterId[target_index],
            RequestedDirection = requested,
            OptimizerIndex = structural_optimizer_index[keep],
            Coordinate = structural_map$Coordinate[keep],
            Loading = as.numeric(solved$direction[keep]),
            stringsAsFactors = FALSE
          )
        }
      }
    }
  }

  evaluated <- evaluated_positive & evaluated_negative
  targets$PositiveRecession <- ifelse(evaluated_positive, positive, NA)
  targets$NegativeRecession <- ifelse(evaluated_negative, negative, NA)
  targets$CandidateStatus <- ifelse(
    !free_target,
    "fixed",
    ifelse(
      !evaluated,
      "not_evaluated_solver",
      ifelse(
        positive & negative,
        "unbounded_direction_ambiguous",
        ifelse(
          positive,
          "unbounded_high",
          ifelse(negative, "unbounded_low", "finite_in_audited_subspace")
        )
      )
    )
  )
  targets$EvaluationState <- ifelse(evaluated, "evaluated", "not_evaluated")
  targets$ReasonCodes <- ifelse(
    !free_target,
    "no_free_coordinate",
    ifelse(
      !evaluated,
      "linear_program_failed",
      ifelse(
        positive | negative,
        "certified_additive_recession_direction",
        "no_additive_recession_direction_certified"
      )
    )
  )
  certificates <- if (length(certificate_rows) == 0L) {
    empty_certificates
  } else {
    do.call(rbind, certificate_rows)
  }
  loadings <- if (length(loading_rows) == 0L) {
    empty_loadings
  } else {
    do.call(rbind, loading_rows)
  }
  any_certified <- any(positive | negative)
  all_evaluated <- all(evaluated)
  state <- if (!all_evaluated) {
    "not_evaluated_solver"
  } else if (any_certified) {
    "certified_recession"
  } else {
    "none_certified"
  }
  detail <- if (any_certified) {
    paste0(
      "Certified additive structural recession for ",
      sum(positive | negative), " of ", sum(free_target),
      " free expanded targets with Person coordinates fixed."
    )
  } else if (all_evaluated) {
    paste0(
      "No additive structural recession direction was certified for ",
      sum(free_target), " free expanded targets with Person coordinates fixed."
    )
  } else {
    "At least one target-direction linear program was not evaluated successfully."
  }
  finish(
    state = state,
    complete = all_evaluated && !identical(model, "GPCM"),
    detail = detail,
    target_status = targets,
    certificates = certificates,
    loadings = loadings,
    dimensions = dimensions
  )
}
