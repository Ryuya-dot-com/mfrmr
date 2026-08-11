# Draft.82 balanced univariate G-study estimation prototype.
#
# Repository-internal only. This file requires the Draft.81 design/algebra
# prototype to have been sourced first. It fits no MFRM likelihood and exports
# no package API.

mfrmr_gte_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gta_component_id", "mfrmr_gta_d_study",
    "mfrmr_gta_spec"
  )
  prototype_environment <- environment(mfrmr_gte_require_primitives)
  missing <- required[!vapply(
    required,
    exists,
    logical(1L),
    envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.81 design/algebra prototype before Draft.82: ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gte_subsets <- function(factors, include_full = TRUE) {
  maximum <- length(factors) - as.integer(!isTRUE(include_full))
  out <- list()
  if (maximum < 1L) return(out)
  for (size in seq_len(maximum)) {
    out <- c(out, utils::combn(factors, size, simplify = FALSE))
  }
  out
}

mfrmr_gte_key <- function(data, columns) {
  if (length(columns) == 1L) return(as.character(data[[columns]]))
  do.call(
    paste,
    c(lapply(data[columns], as.character), list(sep = "\034"))
  )
}

mfrmr_gte_prepare_data <- function(spec, data) {
  mfrmr_gte_require_primitives()
  if (!inherits(spec, "mfrmr_gta_spec")) {
    stop("`spec` must be a Draft.81 typed design.", call. = FALSE)
  }
  if (!isTRUE(spec$DStudyEligible)) {
    stop(
      "Draft.82 requires a Draft.81 algebra-eligible crossed design: ",
      paste(spec$Issues, collapse = "; "), ".",
      call. = FALSE
    )
  }
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("`data` must be a nonempty data frame.", call. = FALSE)
  }
  factors <- c(spec$ObjectFacet, spec$RandomFacets)
  required <- c(factors, spec$ScoreColumn)
  missing <- setdiff(required, names(data))
  if (length(missing) > 0L) {
    stop(
      "The G-study data are missing required columns: ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  retained <- data[required]
  if (!is.numeric(retained[[spec$ScoreColumn]]) ||
      anyNA(retained[[spec$ScoreColumn]]) ||
      any(!is.finite(retained[[spec$ScoreColumn]]))) {
    stop("The observed score must be finite numeric data with no missing row.",
         call. = FALSE)
  }
  for (factor_name in factors) {
    if (anyNA(retained[[factor_name]])) {
      stop("Balanced Draft.82 data cannot contain missing facet levels.",
           call. = FALSE)
    }
    retained[[factor_name]] <- factor(as.character(retained[[factor_name]]))
    if (nlevels(retained[[factor_name]]) < 2L) {
      stop("Every object/facet factor needs at least two observed levels.",
           call. = FALSE)
    }
  }
  order_columns <- lapply(retained[factors], as.integer)
  retained <- retained[do.call(order, order_columns), , drop = FALSE]
  row.names(retained) <- NULL

  level_counts <- stats::setNames(
    vapply(retained[factors], nlevels, integer(1L)), factors
  )
  expected_cells <- prod(level_counts)
  cell_key <- mfrmr_gte_key(retained, factors)
  cell_counts <- table(cell_key)
  if (nrow(retained) != expected_cells || length(cell_counts) != expected_cells ||
      any(cell_counts != 1L)) {
    stop(
      "Draft.82 requires one finite observation in every complete crossed cell.",
      call. = FALSE
    )
  }
  hash_payload <- data.frame(
    lapply(retained[factors], as.character),
    Score = as.numeric(retained[[spec$ScoreColumn]]),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  names(hash_payload)[ncol(hash_payload)] <- spec$ScoreColumn
  list(
    Data = retained,
    Factors = factors,
    LevelCounts = level_counts,
    ObservationCount = nrow(retained),
    CellCount = expected_cells,
    DataHash = mfrmr_gta_hash(hash_payload)
  )
}

mfrmr_gte_mean_squares <- function(prepared) {
  data <- prepared$Data
  factors <- prepared$Factors
  score <- names(data)[ncol(data)]
  grand_mean <- mean(data[[score]])
  subsets <- mfrmr_gte_subsets(factors, include_full = TRUE)
  effect_tables <- list()
  rows <- vector("list", length(subsets))

  for (index in seq_along(subsets)) {
    members <- subsets[[index]]
    effect_id <- paste(members, collapse = ":")
    marginal <- stats::aggregate(
      data[[score]], by = data[members], FUN = mean
    )
    names(marginal)[ncol(marginal)] <- "MarginalMean"
    effect <- marginal$MarginalMean - grand_mean
    if (length(members) > 1L) {
      proper <- mfrmr_gte_subsets(members, include_full = FALSE)
      for (lower_members in proper) {
        lower_id <- paste(lower_members, collapse = ":")
        lower <- effect_tables[[lower_id]]
        match_index <- match(
          mfrmr_gte_key(marginal, lower_members),
          mfrmr_gte_key(lower, lower_members)
        )
        if (anyNA(match_index)) {
          stop("Internal ANOVA marginal-effect alignment failed.",
               call. = FALSE)
        }
        effect <- effect - lower$Effect[match_index]
      }
    }
    effect_table <- cbind(
      marginal[members],
      data.frame(Effect = effect, stringsAsFactors = FALSE)
    )
    effect_tables[[effect_id]] <- effect_table
    complement <- setdiff(factors, members)
    multiplier <- if (length(complement) == 0L) {
      1
    } else {
      prod(prepared$LevelCounts[complement])
    }
    degrees_freedom <- prod(prepared$LevelCounts[members] - 1L)
    sum_squares <- multiplier * sum(effect^2)
    rows[[index]] <- data.frame(
      EffectId = effect_id,
      Members = effect_id,
      Order = length(members),
      DegreesFreedom = as.integer(degrees_freedom),
      AveragingMultiplier = as.numeric(multiplier),
      SumSquares = as.numeric(sum_squares),
      MeanSquare = as.numeric(sum_squares / degrees_freedom),
      stringsAsFactors = FALSE
    )
  }
  mean_squares <- do.call(rbind, rows)
  row.names(mean_squares) <- NULL
  corrected_total <- sum((data[[score]] - grand_mean)^2)
  decomposed_total <- sum(mean_squares$SumSquares)
  tolerance <- 1e-10 * max(1, corrected_total)
  list(
    GrandMean = grand_mean,
    MeanSquares = mean_squares,
    EffectTables = effect_tables,
    CorrectedTotalSumSquares = corrected_total,
    DecomposedSumSquares = decomposed_total,
    DecompositionDifference = decomposed_total - corrected_total,
    DecompositionTolerance = tolerance,
    DecompositionPassed =
      abs(decomposed_total - corrected_total) <= tolerance
  )
}

mfrmr_gte_component_label <- function(members, factors) {
  if (length(members) == length(factors)) "Residual" else
    paste(members, collapse = ":")
}

mfrmr_gte_mom <- function(spec, data, zero_tolerance = 1e-12) {
  prepared <- mfrmr_gte_prepare_data(spec, data)
  anova <- mfrmr_gte_mean_squares(prepared)
  if (!isTRUE(anova$DecompositionPassed)) {
    stop("The balanced ANOVA sum-of-squares decomposition did not close.",
         call. = FALSE)
  }
  factors <- prepared$Factors
  subsets <- mfrmr_gte_subsets(factors, include_full = TRUE)
  subsets <- subsets[order(vapply(subsets, length, integer(1L)),
                           decreasing = TRUE)]
  estimates <- numeric()
  equation_rows <- list()

  for (members in subsets) {
    effect_id <- paste(members, collapse = ":")
    component_id <- mfrmr_gte_component_label(members, factors)
    mean_square <- anova$MeanSquares$MeanSquare[
      match(effect_id, anova$MeanSquares$EffectId)
    ]
    supersets <- subsets[vapply(
      subsets,
      function(candidate) {
        length(candidate) > length(members) && all(members %in% candidate)
      },
      logical(1L)
    )]
    higher_sum <- 0
    if (length(supersets) > 0L) {
      for (higher_members in supersets) {
        higher_id <- mfrmr_gte_component_label(higher_members, factors)
        coefficient <- if (length(setdiff(factors, higher_members)) == 0L) {
          1
        } else {
          prod(prepared$LevelCounts[setdiff(factors, higher_members)])
        }
        contribution <- coefficient * estimates[[higher_id]]
        higher_sum <- higher_sum + contribution
        equation_rows[[length(equation_rows) + 1L]] <- data.frame(
          MeanSquareId = effect_id,
          ComponentId = higher_id,
          EMSCoefficient = as.numeric(coefficient),
          ComponentEstimate = as.numeric(estimates[[higher_id]]),
          FittedContribution = as.numeric(contribution),
          ContributionRole = "subtracted_higher_order",
          stringsAsFactors = FALSE
        )
      }
    }
    target_coefficient <- if (length(setdiff(factors, members)) == 0L) {
      1
    } else {
      prod(prepared$LevelCounts[setdiff(factors, members)])
    }
    estimate <- (mean_square - higher_sum) / target_coefficient
    estimates[[component_id]] <- estimate
    equation_rows[[length(equation_rows) + 1L]] <- data.frame(
      MeanSquareId = effect_id,
      ComponentId = component_id,
      EMSCoefficient = as.numeric(target_coefficient),
      ComponentEstimate = as.numeric(estimate),
      FittedContribution = as.numeric(target_coefficient * estimate),
      ContributionRole = "solved_target",
      stringsAsFactors = FALSE
    )
  }

  component_ids <- spec$EffectMap$ComponentId
  estimate_vector <- estimates[component_ids]
  if (anyNA(estimate_vector)) {
    stop("The MoM equations did not resolve every typed component.",
         call. = FALSE)
  }
  zero_tolerance <- as.numeric(zero_tolerance)[1L]
  if (!is.finite(zero_tolerance) || zero_tolerance < 0) {
    stop("`zero_tolerance` must be finite and nonnegative.", call. = FALSE)
  }
  boundary_state <- ifelse(
    estimate_vector < -zero_tolerance, "negative_raw",
    ifelse(abs(estimate_vector) <= zero_tolerance,
           "exact_zero_raw", "interior_raw")
  )
  components <- cbind(
    spec$EffectMap,
    data.frame(
      Estimate = as.numeric(estimate_vector),
      EstimatorFamily = "balanced_anova_mom",
      ConstraintIdentity = "unconstrained_raw_moment_equations",
      BoundaryState = boundary_state,
      InferenceStatus = "point_only_no_interval",
      stringsAsFactors = FALSE
    )
  )
  equations <- do.call(rbind, equation_rows)
  row.names(equations) <- NULL
  estimator_identity <- list(
    Family = "balanced_anova_mom",
    Method = "orthogonal_expected_mean_square_inversion",
    Constraints = "none",
    Response = "Gaussian_observed_score",
    CellContract = "complete_crossed_one_observation_per_cell",
    Interval = "none"
  )
  payload <- list(
    Contract = "gtheory_balanced_estimation_draft82_v1",
    ModelIdentity = "typed_complete_crossed_lower_order_plus_residual_v1",
    EstimatorIdentity = estimator_identity,
    DesignHash = spec$DesignHash,
    DataHash = prepared$DataHash,
    LevelCounts = prepared$LevelCounts,
    MeanSquares = anova$MeanSquares,
    Components = components,
    EMSEquations = equations,
    DecompositionAudit = anova[c(
      "CorrectedTotalSumSquares", "DecomposedSumSquares",
      "DecompositionDifference", "DecompositionTolerance",
      "DecompositionPassed"
    )]
  )
  structure(
    c(payload, list(
      ResultHash = mfrmr_gta_hash(payload),
      Spec = spec,
      PreparedData = prepared,
      EffectTables = anova$EffectTables,
      EstimationReady = TRUE,
      InferenceReady = FALSE,
      DecisionReady = FALSE
    )),
    class = "mfrmr_gte_fit"
  )
}

mfrmr_gte_lme4_formula <- function(spec, decomposition) {
  if (identical(decomposition, "typed_complete_crossed")) {
    return(stats::as.formula(spec$FormulaCanonical))
  }
  terms <- c(spec$ObjectFacet, spec$RandomFacets)
  stats::as.formula(paste0(
    spec$ScoreColumn, " ~ 1 + ",
    paste0("(1 | ", terms, ")", collapse = " + ")
  ))
}

mfrmr_gte_lme4_effect_map <- function(spec, decomposition) {
  if (identical(decomposition, "typed_complete_crossed")) {
    return(spec$EffectMap)
  }
  keep <- c(spec$ObjectFacet, spec$RandomFacets, "Residual")
  out <- spec$EffectMap[
    match(keep, spec$EffectMap$ComponentId), , drop = FALSE
  ]
  row.names(out) <- NULL
  out$ComponentForm[out$ComponentId == "Residual"] <-
    "collapsed_all_interactions_residual"
  out$ScaleBy[out$ComponentId == "Residual"] <-
    paste(spec$RandomFacets, collapse = ":")
  out
}

mfrmr_gte_lme4_diagnostics <- function(fit, warnings, messages,
                                        zero_components,
                                        singular_tolerance) {
  optinfo <- fit@optinfo
  opt_code <- optinfo$conv$opt
  if (is.null(opt_code) || length(opt_code) == 0L) opt_code <- 0L
  opt_code <- as.integer(opt_code[1L])
  convergence_messages <- as.character(unlist(
    optinfo$conv$lme4$messages, use.names = FALSE
  ))
  convergence_messages <- convergence_messages[nzchar(convergence_messages)]
  nonboundary_convergence_messages <- convergence_messages[!grepl(
    "boundary|singular", convergence_messages, ignore.case = TRUE
  )]
  gradient <- suppressWarnings(as.numeric(optinfo$derivs$gradient))
  max_gradient <- if (length(gradient) > 0L && all(is.finite(gradient))) {
    max(abs(gradient))
  } else {
    NA_real_
  }
  hessian <- optinfo$derivs$Hessian
  minimum_hessian_eigenvalue <- if (is.matrix(hessian) &&
                                    all(is.finite(hessian))) {
    min(eigen((hessian + t(hessian)) / 2, symmetric = TRUE,
              only.values = TRUE)$values)
  } else {
    NA_real_
  }
  singular <- tryCatch(
    isTRUE(lme4::isSingular(fit, tol = singular_tolerance)),
    error = function(e) NA
  )
  optimizer_warning <- opt_code != 0L ||
    length(nonboundary_convergence_messages) > 0L
  status <- if (optimizer_warning) {
    "optimizer_warning"
  } else if (isTRUE(singular) || any(zero_components)) {
    "boundary_or_singular"
  } else if (is.na(singular)) {
    "singularity_check_unavailable"
  } else {
    "identified"
  }
  data.frame(
    FitStatus = status,
    OptimizerCode = opt_code,
    Singular = singular,
    SingularTolerance = singular_tolerance,
    ZeroComponentCount = sum(zero_components),
    MaximumAbsoluteGradient = max_gradient,
    MinimumHessianEigenvalue = minimum_hessian_eigenvalue,
    WarningCount = length(warnings),
    MessageCount = length(messages),
    ConvergenceMessageCount = length(convergence_messages),
    Warnings = paste(warnings, collapse = " | "),
    Messages = paste(messages, collapse = " | "),
    ConvergenceMessages = paste(convergence_messages, collapse = " | "),
    stringsAsFactors = FALSE
  )
}

mfrmr_gte_lme4 <- function(
    spec, data, reml = TRUE,
    decomposition = c("typed_complete_crossed",
                      "main_effects_collapsed_residual_v1"),
    zero_tolerance = 1e-10, singular_tolerance = 1e-4) {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    stop("Draft.82 lme4 estimation requires the suggested `lme4` package.",
         call. = FALSE)
  }
  decomposition <- match.arg(decomposition)
  prepared <- mfrmr_gte_prepare_data(spec, data)
  formula <- mfrmr_gte_lme4_formula(spec, decomposition)
  warnings <- character()
  messages <- character()
  fit <- tryCatch(
    withCallingHandlers(
      lme4::lmer(
        formula, data = prepared$Data, REML = isTRUE(reml),
        control = lme4::lmerControl()
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
  if (inherits(fit, "error")) {
    stop("lme4::lmer failed: ", conditionMessage(fit), call. = FALSE)
  }
  effect_map <- mfrmr_gte_lme4_effect_map(spec, decomposition)
  vc <- as.data.frame(lme4::VarCorr(fit))
  vc <- vc[is.na(vc$var2), c("grp", "vcov"), drop = FALSE]
  component_id <- vapply(as.character(vc$grp), function(group) {
    if (identical(group, "Residual")) return("Residual")
    mfrmr_gta_component_id(
      strsplit(group, ":", fixed = TRUE)[[1L]],
      c(spec$ObjectFacet, spec$RandomFacets)
    )
  }, character(1L))
  if (anyDuplicated(component_id)) {
    stop("lme4 returned duplicate semantic variance components.",
         call. = FALSE)
  }
  estimate <- stats::setNames(as.numeric(vc$vcov), component_id)
  required_ids <- effect_map$ComponentId
  if (!setequal(names(estimate), required_ids)) {
    stop(
      "lme4 variance-component identities do not match the typed effect map.",
      call. = FALSE
    )
  }
  estimate <- estimate[required_ids]
  zero_tolerance <- as.numeric(zero_tolerance)[1L]
  singular_tolerance <- as.numeric(singular_tolerance)[1L]
  if (!is.finite(zero_tolerance) || zero_tolerance < 0 ||
      !is.finite(singular_tolerance) || singular_tolerance < 0) {
    stop("Boundary and singular tolerances must be finite and nonnegative.",
         call. = FALSE)
  }
  zero_components <- estimate <= zero_tolerance
  components <- cbind(
    effect_map,
    data.frame(
      Estimate = as.numeric(estimate),
      EstimatorFamily = if (isTRUE(reml)) "lme4_reml" else "lme4_ml",
      ConstraintIdentity = "nonnegative_variance_parameterization",
      BoundaryState = ifelse(
        zero_components, "constrained_zero_boundary", "interior_constrained"
      ),
      InferenceStatus = "point_only_no_interval",
      stringsAsFactors = FALSE
    )
  )
  diagnostics <- mfrmr_gte_lme4_diagnostics(
    fit, warnings, messages, zero_components, singular_tolerance
  )
  estimator_identity <- list(
    Family = if (isTRUE(reml)) "lme4_reml" else "lme4_ml",
    Backend = "lme4",
    BackendVersion = as.character(utils::packageVersion("lme4")),
    Method = if (isTRUE(reml)) "REML" else "ML",
    Constraints = "variance_components_nonnegative",
    FormulaCanonical = paste(deparse(formula, width.cutoff = 500L),
                             collapse = " "),
    Response = "Gaussian_observed_score",
    CellContract = "complete_crossed_one_observation_per_cell",
    Interval = "none"
  )
  model_identity <- if (identical(
    decomposition, "typed_complete_crossed"
  )) {
    "typed_complete_crossed_lower_order_plus_residual_v1"
  } else {
    "main_effects_collapsed_residual_v1"
  }
  payload <- list(
    Contract = "gtheory_balanced_estimation_draft82_v1",
    ModelIdentity = model_identity,
    EstimatorIdentity = estimator_identity,
    DesignHash = spec$DesignHash,
    DataHash = prepared$DataHash,
    LevelCounts = prepared$LevelCounts,
    Components = components,
    FitDiagnostics = diagnostics
  )
  structure(
    c(payload, list(
      ResultHash = mfrmr_gta_hash(payload),
      Spec = spec,
      PreparedData = prepared,
      BackendFit = fit,
      EstimationReady = diagnostics$FitStatus %in%
        c("identified", "boundary_or_singular"),
      InferenceReady = FALSE,
      DecisionReady = FALSE
    )),
    class = "mfrmr_gte_fit"
  )
}

mfrmr_gte_d_study <- function(fit, design_grid) {
  if (!inherits(fit, "mfrmr_gte_fit")) {
    stop("`fit` must be a Draft.82 balanced G-study result.", call. = FALSE)
  }
  if (!identical(
    fit$ModelIdentity,
    "typed_complete_crossed_lower_order_plus_residual_v1"
  )) {
    stop(
      "The collapsed-residual compatibility fit uses the existing sensitivity contract, not typed component algebra.",
      call. = FALSE
    )
  }
  components <- stats::setNames(
    fit$Components$Estimate, fit$Components$ComponentId
  )
  result <- mfrmr_gta_d_study(fit$Spec, components, design_grid)
  algebra_result_hash <- result$ResultHash
  result$SourceEstimator <- fit$EstimatorIdentity
  result$SourceEstimationHash <- fit$ResultHash
  result$AlgebraResultHash <- algebra_result_hash
  result$InferenceReady <- FALSE
  result$DecisionReady <- FALSE
  result$ResultHash <- mfrmr_gta_hash(list(
    Contract = "gtheory_estimation_to_dstudy_draft82_v1",
    AlgebraResultHash = algebra_result_hash,
    SourceEstimationHash = fit$ResultHash,
    SourceEstimator = fit$EstimatorIdentity,
    Scenarios = result$Scenarios,
    Contributions = result$Contributions,
    InferenceReady = FALSE,
    DecisionReady = FALSE
  ))
  result
}

mfrmr_gte_center_array <- function(x) {
  dimensions <- dim(x)
  if (is.null(dimensions)) {
    return(x - mean(x))
  }
  out <- x
  for (dimension in seq_along(dimensions)) {
    margins <- setdiff(seq_along(dimensions), dimension)
    if (length(margins) == 0L) {
      out <- out - mean(out)
    } else {
      marginal_mean <- apply(out, margins, mean)
      out <- sweep(out, margins, marginal_mean, FUN = "-")
    }
  }
  out
}

mfrmr_gte_pure_effect <- function(dimensions, mean_square) {
  if (mean_square < 0 || !is.finite(mean_square)) {
    stop("Fixture pure-effect mean squares must be finite and nonnegative.",
         call. = FALSE)
  }
  if (mean_square == 0) return(array(0, dim = dimensions))
  raw <- array(stats::rnorm(prod(dimensions)), dim = dimensions)
  centered <- mfrmr_gte_center_array(raw)
  degrees_freedom <- prod(dimensions - 1L)
  current <- sum(centered^2) / degrees_freedom
  if (!is.finite(current) || current <= 0) {
    stop("Fixture pure-effect construction was degenerate.", call. = FALSE)
  }
  centered * sqrt(mean_square / current)
}

mfrmr_gte_fixture <- function(
    design = c("pxi", "pxrxi"), state = c("interior", "negative_raw"),
    seed = 8201L) {
  mfrmr_gte_require_primitives()
  design <- match.arg(design)
  state <- match.arg(state)
  if (identical(design, "pxrxi") && identical(state, "negative_raw")) {
    stop("The Draft.82 negative fixture is defined for p x i only.",
         call. = FALSE)
  }
  set.seed(as.integer(seed)[1L])
  if (identical(design, "pxi")) {
    level_counts <- c(Person = 18L, Item = 6L)
    spec <- mfrmr_gta_spec(
      Score ~ 1 + (1 | Person) + (1 | Item),
      object = "Person", facets = "Item",
      residual_scale_by = "Item"
    )
    target <- c(Person = 1, Item = 0.2, Residual = 0.8)
  } else {
    level_counts <- c(Person = 16L, Rater = 4L, Item = 5L)
    spec <- mfrmr_gta_spec(
      Score ~ 1 +
        (1 | Person) + (1 | Rater) + (1 | Item) +
        (1 | Person:Rater) + (1 | Person:Item) + (1 | Rater:Item),
      object = "Person", facets = c("Rater", "Item"),
      residual_scale_by = c("Rater", "Item")
    )
    target <- c(
      Person = 1, Rater = 0.12, Item = 0.18,
      `Person:Rater` = 0.24, `Person:Item` = 0.30,
      `Rater:Item` = 0.08, Residual = 0.48
    )
  }
  factors <- names(level_counts)
  subsets <- mfrmr_gte_subsets(factors, include_full = TRUE)
  pure_mean_squares <- numeric()
  for (members in subsets) {
    component_id <- mfrmr_gte_component_label(members, factors)
    coefficient_target <- if (length(setdiff(factors, members)) == 0L) {
      1
    } else {
      prod(level_counts[setdiff(factors, members)])
    }
    supersets <- subsets[vapply(
      subsets, function(candidate) all(members %in% candidate), logical(1L)
    )]
    expected_ms <- sum(vapply(supersets, function(higher_members) {
      higher_id <- mfrmr_gte_component_label(higher_members, factors)
      coefficient <- if (length(setdiff(factors, higher_members)) == 0L) {
        1
      } else {
        prod(level_counts[setdiff(factors, higher_members)])
      }
      coefficient * target[[higher_id]]
    }, numeric(1L)))
    pure_mean_squares[[paste(members, collapse = ":")]] <-
      expected_ms / coefficient_target
  }
  if (identical(state, "negative_raw")) {
    pure_mean_squares[["Person"]] <- 1
    pure_mean_squares[["Item"]] <- 0
    pure_mean_squares[["Person:Item"]] <- 0.8
    target <- c(
      Person = 1 - 0.8 / level_counts[["Item"]],
      Item = -0.8 / level_counts[["Person"]],
      Residual = 0.8
    )
  }
  data <- do.call(
    expand.grid,
    c(
      lapply(level_counts, function(count) factor(seq_len(count))),
      list(KEEP.OUT.ATTRS = FALSE, stringsAsFactors = TRUE)
    )
  )
  score <- numeric(nrow(data))
  for (members in subsets) {
    effect_id <- paste(members, collapse = ":")
    effect <- mfrmr_gte_pure_effect(
      as.integer(level_counts[members]), pure_mean_squares[[effect_id]]
    )
    indices <- lapply(data[members], as.integer)
    score <- score + if (length(members) == 1L) {
      effect[indices[[1L]]]
    } else {
      effect[do.call(cbind, indices)]
    }
  }
  data$Score <- score
  list(
    Design = design,
    State = state,
    Spec = spec,
    Data = data,
    ExpectedComponents = target,
    PureMeanSquares = pure_mean_squares,
    LevelCounts = level_counts,
    Seed = as.integer(seed)[1L]
  )
}
