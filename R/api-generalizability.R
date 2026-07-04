# ==============================================================================
# Generalizability theory adapter (random rater / random item effects)
# ==============================================================================
#
# `mfrm_generalizability()` formalises the generalizability-theory
# (Cronbach et al. 1972 / Brennan 2001) decomposition that
# `compute_facet_icc()` already performs internally via
# `lme4::lmer`. The MFRM frames non-person facets as fixed effects
# for measurement; for reporting a G-coefficient, the same facets
# are re-fit as crossed random effects so the variance components
# can be combined into the canonical G / Phi indices.
#
# This helper does NOT re-fit the MFRM. It treats the rating data
# as a crossed random-effects ANOVA (Person + each non-person facet
# + optional explicitly requested interactions + residual) and
# returns the variance decomposition + G / Phi coefficients.

gstudy_runtime_summary <- function(started_at, finished_at, data,
                                   random_facets, random_interactions = character(0),
                                   progress, lmer_warnings,
                                   lmer_messages = character(0),
                                   singular_fit = FALSE) {
  elapsed <- as.numeric(difftime(finished_at, started_at, units = "secs"))
  data.frame(
    StartedAt = format(started_at, "%Y-%m-%d %H:%M:%S %Z"),
    FinishedAt = format(finished_at, "%Y-%m-%d %H:%M:%S %Z"),
    ElapsedSec = if (is.finite(elapsed)) elapsed else NA_real_,
    RatingRows = nrow(as.data.frame(data %||% data.frame(), stringsAsFactors = FALSE)),
    RandomFacetCount = length(random_facets),
    RandomFacets = paste(random_facets, collapse = ", "),
    RandomInteractionCount = length(random_interactions),
    RandomInteractions = paste(random_interactions, collapse = ", "),
    LmerWarnings = length(unique(as.character(lmer_warnings %||% character(0)))),
    LmerMessages = length(unique(as.character(lmer_messages %||% character(0)))),
    SingularFit = isTRUE(singular_fit),
    ProgressShown = isTRUE(progress),
    stringsAsFactors = FALSE
  )
}

mfrm_gt_normalize_random_interactions <- function(random_interactions,
                                                  object_facet,
                                                  random_facets) {
  if (is.null(random_interactions) || length(random_interactions) == 0L) {
    return(list())
  }
  available <- c(object_facet, random_facets)
  terms <- if (is.character(random_interactions)) {
    lapply(random_interactions, function(term) {
      term <- trimws(as.character(term))
      if (is.na(term) || !nzchar(term)) {
        stop("`random_interactions` cannot contain empty strings.", call. = FALSE)
      }
      parts <- trimws(strsplit(term, ":", fixed = TRUE)[[1]])
      if (length(parts) != 2L || any(!nzchar(parts))) {
        stop(
          "`random_interactions` must use explicit two-way terms such as ",
          "`\"Person:Token\"` or `\"Rater:Token\"`. Problem term: ",
          shQuote(term), ".",
          call. = FALSE
        )
      }
      parts
    })
  } else if (is.list(random_interactions) && !is.data.frame(random_interactions)) {
    lapply(random_interactions, function(term) {
      parts <- trimws(as.character(term))
      parts <- parts[!is.na(parts) & nzchar(parts)]
      if (length(parts) != 2L) {
        stop(
          "List entries in `random_interactions` must each contain exactly ",
          "two facet names, for example `list(c(\"Person\", \"Token\"))`.",
          call. = FALSE
        )
      }
      parts
    })
  } else {
    stop(
      "`random_interactions` must be NULL, a character vector of `A:B` ",
      "terms, or a list of length-two character vectors.",
      call. = FALSE
    )
  }

  specs <- vector("list", length(terms))
  canonical <- character(length(terms))
  for (i in seq_along(terms)) {
    parts <- terms[[i]]
    missing <- setdiff(parts, available)
    if (length(missing) > 0L) {
      stop(
        "`random_interactions` references facet(s) not available in the ",
        "G-study design: ", paste(shQuote(missing), collapse = ", "),
        ". Available facets are: ", paste(shQuote(available), collapse = ", "),
        ".",
        call. = FALSE
      )
    }
    if (length(unique(parts)) != 2L) {
      stop(
        "`random_interactions` terms must name two distinct facets. ",
        "Problem term: ", shQuote(paste(parts, collapse = ":")), ".",
        call. = FALSE
      )
    }
    canonical[i] <- paste(sort(parts), collapse = "\r")
    source <- paste(parts, collapse = ":")
    measurement_facets <- setdiff(parts, object_facet)
    includes_object <- object_facet %in% parts
    specs[[i]] <- list(
      source = source,
      facets = parts,
      measurement_facets = measurement_facets,
      includes_object = includes_object,
      component_type = if (includes_object) "object_interaction" else "facet_interaction",
      decision_role = if (includes_object) "relative_and_absolute_error" else "absolute_error"
    )
  }
  if (any(duplicated(canonical))) {
    dup <- vapply(specs[duplicated(canonical)], `[[`, character(1), "source")
    stop(
      "`random_interactions` contains duplicate facet pairs: ",
      paste(shQuote(dup), collapse = ", "), ". Each two-way pair may be ",
      "specified only once.",
      call. = FALSE
    )
  }
  names(specs) <- vapply(specs, `[[`, character(1), "source")
  specs
}

mfrm_gt_get_variance <- function(v, source, default = 0) {
  source <- as.character(source)[1L]
  if (is.na(source) || !nzchar(source) || !source %in% names(v)) {
    return(default)
  }
  value <- suppressWarnings(as.numeric(v[[source]]))
  if (is.finite(value)) value else default
}

mfrm_gt_sum_variance <- function(v, sources) {
  sources <- as.character(sources %||% character(0))
  if (length(sources) == 0L) return(0)
  sum(vapply(sources, function(source) {
    mfrm_gt_get_variance(v, source, default = 0)
  }, numeric(1)), na.rm = TRUE)
}

mfrm_gt_variance_vector <- function(x) {
  if (inherits(x, "mfrm_generalizability")) {
    raw <- x$design$variance_raw %||% NULL
    if (!is.null(raw) && length(raw) > 0L) {
      return(stats::setNames(
        suppressWarnings(as.numeric(raw)),
        names(raw)
      ))
    }
    x <- x$variance_components
  }
  vc <- as.data.frame(x, stringsAsFactors = FALSE)
  stats::setNames(
    suppressWarnings(as.numeric(vc$Variance)),
    as.character(vc$Source)
  )
}

mfrm_gt_component_metadata <- function(sources,
                                       object_facet,
                                       random_facets,
                                       interaction_specs) {
  interaction_names <- names(interaction_specs)
  component_type <- vapply(sources, function(source) {
    if (source == "Residual") {
      "residual"
    } else if (source == object_facet) {
      "object"
    } else if (source %in% random_facets) {
      "facet_main"
    } else if (source %in% interaction_names) {
      interaction_specs[[source]]$component_type
    } else {
      "other"
    }
  }, character(1))
  decision_role <- vapply(seq_along(sources), function(i) {
    source <- sources[i]
    type <- component_type[i]
    if (type == "object") {
      "object"
    } else if (type == "facet_main") {
      "absolute_error"
    } else if (source %in% interaction_names) {
      interaction_specs[[source]]$decision_role
    } else if (type == "residual") {
      "relative_and_absolute_error"
    } else {
      "unclassified"
    }
  }, character(1))
  divisor_facets <- vapply(seq_along(sources), function(i) {
    source <- sources[i]
    type <- component_type[i]
    if (type == "facet_main") {
      source
    } else if (source %in% interaction_names) {
      paste(interaction_specs[[source]]$measurement_facets, collapse = ":")
    } else if (type == "residual") {
      paste(random_facets, collapse = ":")
    } else {
      ""
    }
  }, character(1))
  data.frame(
    ComponentType = unname(component_type),
    DecisionRole = unname(decision_role),
    DivisorFacets = unname(divisor_facets),
    stringsAsFactors = FALSE
  )
}

mfrm_gt_project_interaction_error <- function(interaction_specs,
                                              v,
                                              counts,
                                              random_facets,
                                              includes_object) {
  specs <- interaction_specs[vapply(interaction_specs, function(spec) {
    isTRUE(spec$includes_object) == isTRUE(includes_object)
  }, logical(1))]
  if (length(specs) == 0L) {
    return(rep(0, nrow(counts)))
  }
  out <- numeric(nrow(counts))
  for (spec in specs) {
    sigma2 <- mfrm_gt_get_variance(v, spec$source, default = 0)
    if (!is.finite(sigma2) || sigma2 <= 0) next
    divisor <- vapply(seq_len(nrow(counts)), function(i) {
      facets <- intersect(spec$measurement_facets, random_facets)
      if (length(facets) == 0L) return(1)
      prod(vapply(facets, function(facet) {
        counts[[paste0("n_", facet)]][i]
      }, numeric(1)))
    }, numeric(1))
    out <- out + sigma2 / divisor
  }
  out
}

mfrm_gt_quote_name <- function(x) {
  x <- as.character(x)
  paste0("`", gsub("`", "\\\\`", x, fixed = TRUE), "`")
}

mfrm_gt_formula_group <- function(source, interaction_specs) {
  if (source %in% names(interaction_specs)) {
    return(paste(mfrm_gt_quote_name(interaction_specs[[source]]$facets), collapse = ":"))
  }
  mfrm_gt_quote_name(source)
}

mfrm_gt_normalize_lme4_group <- function(source, interaction_specs) {
  source <- as.character(source)
  interaction_names <- names(interaction_specs)
  if (length(interaction_names) == 0L) {
    return(source)
  }
  unquoted <- gsub("`", "", source, fixed = TRUE)
  ifelse(unquoted %in% interaction_names, unquoted, source)
}

mfrm_gt_validate_design_check_args <- function(min_levels,
                                               min_replicates_per_cell,
                                               sparse_cell_threshold) {
  min_levels <- suppressWarnings(as.integer(min_levels[1] %||% 2L))
  if (!is.finite(min_levels) || min_levels < 2L) {
    stop("`min_levels` must be an integer value of 2 or larger.", call. = FALSE)
  }
  min_replicates_per_cell <- suppressWarnings(as.integer(min_replicates_per_cell[1] %||% 2L))
  if (!is.finite(min_replicates_per_cell) || min_replicates_per_cell < 1L) {
    stop("`min_replicates_per_cell` must be an integer value of 1 or larger.",
         call. = FALSE)
  }
  sparse_cell_threshold <- suppressWarnings(as.numeric(sparse_cell_threshold[1] %||% 0.5))
  if (!is.finite(sparse_cell_threshold) ||
      sparse_cell_threshold < 0 || sparse_cell_threshold > 1) {
    stop("`sparse_cell_threshold` must be a numeric value between 0 and 1.",
         call. = FALSE)
  }
  list(
    min_levels = min_levels,
    min_replicates_per_cell = min_replicates_per_cell,
    sparse_cell_threshold = sparse_cell_threshold
  )
}

mfrm_gt_prepare_design_data <- function(fit, data, object_facet, random_facets) {
  if (is.null(data)) {
    data <- as.data.frame(fit$prep$data %||% data.frame(),
                          stringsAsFactors = FALSE)
  }
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("`data` is empty or not a data frame.", call. = FALSE)
  }
  facet_cols <- c(object_facet, random_facets)
  missing_cols <- setdiff(facet_cols, names(data))
  if (length(missing_cols) > 0L) {
    stop("Data frame is missing required facet columns: ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }
  design_data <- data[, facet_cols, drop = FALSE]
  complete <- stats::complete.cases(design_data)
  rows_omitted <- sum(!complete, na.rm = TRUE)
  design_data <- design_data[complete, , drop = FALSE]
  for (col in facet_cols) {
    design_data[[col]] <- as.character(design_data[[col]])
  }
  list(data = design_data, rows_omitted = rows_omitted)
}

mfrm_gt_observed_levels <- function(data, facet) {
  values <- as.character(data[[facet]])
  values <- values[!is.na(values) & nzchar(values)]
  length(unique(values))
}

mfrm_gt_level_counts <- function(data, facet) {
  values <- as.character(data[[facet]])
  values <- values[!is.na(values) & nzchar(values)]
  as.integer(table(values, useNA = "no"))
}

mfrm_gt_cell_counts <- function(data, facets) {
  if (nrow(data) == 0L || length(facets) == 0L) {
    return(integer(0))
  }
  keys <- do.call(
    paste,
    c(lapply(facets, function(facet) as.character(data[[facet]])),
      sep = "\r")
  )
  as.integer(table(keys, useNA = "no"))
}

mfrm_gt_count_summary <- function(counts, min_replicates_per_cell) {
  if (length(counts) == 0L) {
    return(list(
      min = NA_integer_,
      median = NA_real_,
      max = NA_integer_,
      singleton = NA_integer_,
      singleton_rate = NA_real_,
      replicated = NA_integer_,
      replicated_rate = NA_real_
    ))
  }
  singleton <- sum(counts < min_replicates_per_cell, na.rm = TRUE)
  replicated <- sum(counts >= min_replicates_per_cell, na.rm = TRUE)
  list(
    min = min(counts, na.rm = TRUE),
    median = stats::median(counts, na.rm = TRUE),
    max = max(counts, na.rm = TRUE),
    singleton = singleton,
    singleton_rate = singleton / length(counts),
    replicated = replicated,
    replicated_rate = replicated / length(counts)
  )
}

mfrm_gt_status_rank <- function(status) {
  rank <- c(review = 3L, sensitivity_only = 2L, ok = 1L,
            not_requested = 0L)
  unname(rank[as.character(status)] %||% NA_integer_)
}

mfrm_gt_design_status <- function(levels,
                                  observed_cells,
                                  density,
                                  singleton_rate,
                                  replicated_rate,
                                  min_levels,
                                  sparse_cell_threshold) {
  if (any(!is.finite(levels)) || any(levels < min_levels) ||
      !is.finite(observed_cells) || observed_cells < min_levels) {
    return("review")
  }
  if (is.finite(density) && density < sparse_cell_threshold) {
    return("review")
  }
  if (is.finite(replicated_rate) && replicated_rate <= 0) {
    return("review")
  }
  if ((is.finite(singleton_rate) && singleton_rate >= 0.80) ||
      (is.finite(replicated_rate) && replicated_rate < 0.50)) {
    return("sensitivity_only")
  }
  "ok"
}

mfrm_gt_design_concern <- function(status,
                                   levels,
                                   observed_cells,
                                   density,
                                   singleton_rate,
                                   replicated_rate,
                                   min_levels,
                                   sparse_cell_threshold) {
  if (identical(status, "not_requested")) {
    return("no_explicit_interactions")
  }
  if (any(!is.finite(levels)) || any(levels < min_levels)) {
    return("too_few_levels")
  }
  if (!is.finite(observed_cells) || observed_cells < min_levels) {
    return("too_few_observed_cells")
  }
  if (is.finite(density) && density < sparse_cell_threshold) {
    return("sparse_crossing")
  }
  if (is.finite(replicated_rate) && replicated_rate <= 0) {
    return("no_replicated_cells")
  }
  if (is.finite(singleton_rate) && singleton_rate >= 0.80) {
    return("mostly_singleton_cells")
  }
  if (is.finite(replicated_rate) && replicated_rate < 0.50) {
    return("few_replicated_cells")
  }
  "none"
}

mfrm_gt_design_action <- function(status, concern, includes_object = NA) {
  if (identical(status, "not_requested")) {
    return("No explicit interaction model requested; main-effects G-study leaves interaction variance in Residual.")
  }
  if (identical(status, "ok")) {
    return("Proceed only when substantively motivated; report the component as observed-score G-study evidence.")
  }
  if (identical(status, "sensitivity_only")) {
    return("Treat as sensitivity evidence; compare with the main-effects baseline and inspect singular-fit diagnostics.")
  }
  if (identical(concern, "too_few_levels")) {
    return("Do not interpret this component alone until the facets have enough observed levels.")
  }
  if (identical(concern, "sparse_crossing")) {
    return("Review assignment and crossing before interpreting this interaction component.")
  }
  if (identical(concern, "no_replicated_cells")) {
    return("Keep the component in Residual or add exact-cell replication before separating it.")
  }
  if (isTRUE(includes_object)) {
    return("Use only as a sensitivity check for relative and absolute error; review crossing and replication.")
  }
  "Use only as a sensitivity check for absolute error; review crossing and replication."
}

mfrm_gt_facet_overview <- function(data, facets, role_lookup,
                                   min_levels, min_replicates_per_cell) {
  rows <- lapply(facets, function(facet) {
    counts <- mfrm_gt_level_counts(data, facet)
    summary <- mfrm_gt_count_summary(counts, min_replicates_per_cell)
    levels <- length(counts)
    singleton_rate <- if (length(counts) > 0L) summary$singleton / length(counts) else NA_real_
    status <- if (levels < min_levels) {
      "review"
    } else if (is.finite(singleton_rate) && singleton_rate >= 0.50) {
      "sensitivity_only"
    } else {
      "ok"
    }
    data.frame(
      Facet = facet,
      Role = unname(role_lookup[[facet]] %||% "measurement_facet"),
      Levels = levels,
      Observations = sum(counts, na.rm = TRUE),
      MinRowsPerLevel = summary$min,
      MedianRowsPerLevel = summary$median,
      MaxRowsPerLevel = summary$max,
      SingletonLevels = summary$singleton,
      SingletonLevelRate = round(singleton_rate, 4),
      Status = status,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrm_gt_interaction_overview <- function(data, interaction_specs,
                                         min_levels,
                                         min_replicates_per_cell,
                                         sparse_cell_threshold) {
  if (length(interaction_specs) == 0L) {
    return(data.frame(
      Interaction = "(none)",
      Facets = "",
      ComponentType = "not_requested",
      IncludesObject = NA,
      FacetALevels = NA_integer_,
      FacetBLevels = NA_integer_,
      PossibleCells = NA_real_,
      ObservedCells = NA_integer_,
      MissingCells = NA_real_,
      CellDensity = NA_real_,
      MinRowsPerObservedCell = NA_integer_,
      MedianRowsPerObservedCell = NA_real_,
      MaxRowsPerObservedCell = NA_integer_,
      SingletonCells = NA_integer_,
      SingletonCellRate = NA_real_,
      ReplicatedCells = NA_integer_,
      ReplicatedCellRate = NA_real_,
      Status = "not_requested",
      MainConcern = "no_explicit_interactions",
      RecommendedAction = mfrm_gt_design_action("not_requested",
                                                "no_explicit_interactions"),
      stringsAsFactors = FALSE
    ))
  }
  rows <- lapply(interaction_specs, function(spec) {
    facets <- spec$facets
    levels <- vapply(facets, function(facet) mfrm_gt_observed_levels(data, facet),
                     integer(1))
    possible <- prod(as.numeric(levels))
    counts <- mfrm_gt_cell_counts(data, facets)
    observed <- length(counts)
    missing <- if (is.finite(possible)) max(possible - observed, 0) else NA_real_
    density <- if (is.finite(possible) && possible > 0) observed / possible else NA_real_
    summary <- mfrm_gt_count_summary(counts, min_replicates_per_cell)
    status <- mfrm_gt_design_status(
      levels = levels,
      observed_cells = observed,
      density = density,
      singleton_rate = summary$singleton_rate,
      replicated_rate = summary$replicated_rate,
      min_levels = min_levels,
      sparse_cell_threshold = sparse_cell_threshold
    )
    concern <- mfrm_gt_design_concern(
      status = status,
      levels = levels,
      observed_cells = observed,
      density = density,
      singleton_rate = summary$singleton_rate,
      replicated_rate = summary$replicated_rate,
      min_levels = min_levels,
      sparse_cell_threshold = sparse_cell_threshold
    )
    data.frame(
      Interaction = spec$source,
      Facets = paste(facets, collapse = ":"),
      ComponentType = spec$component_type,
      IncludesObject = isTRUE(spec$includes_object),
      FacetALevels = unname(levels[1]),
      FacetBLevels = unname(levels[2]),
      PossibleCells = possible,
      ObservedCells = observed,
      MissingCells = missing,
      CellDensity = round(density, 4),
      MinRowsPerObservedCell = summary$min,
      MedianRowsPerObservedCell = summary$median,
      MaxRowsPerObservedCell = summary$max,
      SingletonCells = summary$singleton,
      SingletonCellRate = round(summary$singleton_rate, 4),
      ReplicatedCells = summary$replicated,
      ReplicatedCellRate = round(summary$replicated_rate, 4),
      Status = status,
      MainConcern = concern,
      RecommendedAction = mfrm_gt_design_action(status, concern,
                                                includes_object = spec$includes_object),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrm_gt_highest_order_review <- function(data, facets,
                                         min_levels,
                                         min_replicates_per_cell,
                                         sparse_cell_threshold) {
  levels <- vapply(facets, function(facet) mfrm_gt_observed_levels(data, facet),
                   integer(1))
  possible <- prod(as.numeric(levels))
  counts <- mfrm_gt_cell_counts(data, facets)
  observed <- length(counts)
  missing <- if (is.finite(possible)) max(possible - observed, 0) else NA_real_
  density <- if (is.finite(possible) && possible > 0) observed / possible else NA_real_
  summary <- mfrm_gt_count_summary(counts, min_replicates_per_cell)
  status <- mfrm_gt_design_status(
    levels = levels,
    observed_cells = observed,
    density = density,
    singleton_rate = summary$singleton_rate,
    replicated_rate = summary$replicated_rate,
    min_levels = min_levels,
    sparse_cell_threshold = sparse_cell_threshold
  )
  if (identical(status, "ok") &&
      is.finite(summary$replicated_rate) && summary$replicated_rate < 1) {
    status <- "sensitivity_only"
  }
  concern <- mfrm_gt_design_concern(
    status = status,
    levels = levels,
    observed_cells = observed,
    density = density,
    singleton_rate = summary$singleton_rate,
    replicated_rate = summary$replicated_rate,
    min_levels = min_levels,
    sparse_cell_threshold = sparse_cell_threshold
  )
  data.frame(
    FullCellFacets = paste(facets, collapse = ":"),
    FacetCount = length(facets),
    PossibleCells = possible,
    ObservedCells = observed,
    MissingCells = missing,
    CellDensity = round(density, 4),
    MinRowsPerObservedCell = summary$min,
    MedianRowsPerObservedCell = summary$median,
    MaxRowsPerObservedCell = summary$max,
    SingletonFullCells = summary$singleton,
    SingletonFullCellRate = round(summary$singleton_rate, 4),
    ReplicatedFullCells = summary$replicated,
    ReplicatedFullCellRate = round(summary$replicated_rate, 4),
    Status = status,
    MainConcern = concern,
    RecommendedAction = mfrm_gt_design_action(status, concern),
    stringsAsFactors = FALSE
  )
}

#' Check whether a G-study design can support explicit random interactions
#'
#' @description
#' `check_mfrm_generalizability_design()` inspects the observed rating design
#' before the G-study variance-component refit. It does not call `lme4` and it
#' does not estimate variance components. Instead, it reports whether requested
#' two-way random interactions have enough observed levels, crossed cells, and
#' exact-cell replication to be interpreted beyond a sensitivity check.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param data Optional data frame. When `NULL`, the rating data stored on
#'   `fit$prep$data` is used.
#' @param object_facet Facet that plays the role of the object of measurement.
#'   Defaults to `"Person"`.
#' @param random_facets Character vector of random measurement facets. Default
#'   uses every facet in `fit$config$facet_names` other than `object_facet`.
#' @param random_interactions Optional explicitly requested two-way random
#'   interactions, such as `"Person:Rater"` or `list(c("Rater", "Criterion"))`.
#'   The same validation rules as [mfrm_generalizability()] are used.
#' @param min_levels Minimum observed levels required for each facet in a
#'   requested interaction. Defaults to `2`.
#' @param min_replicates_per_cell Minimum row count used to call an observed
#'   interaction cell replicated. Defaults to `2`.
#' @param sparse_cell_threshold Minimum observed-cell density for the crossed
#'   interaction table. Densities below this value are flagged for review.
#'
#' @return An object of class `mfrm_generalizability_design_check`, a list with:
#' - `overview`: one-row summary of rows, requested interactions, review
#'   counts, sensitivity-only counts, and highest-order cell status
#' - `facet_overview`: observed levels and rows per level for the object facet
#'   and each random measurement facet
#' - `interaction_overview`: one row per requested two-way interaction, with
#'   possible cells, observed cells, density, cell replication, status, main
#'   concern, and recommended action
#' - `highest_order_review`: observed full-cell crossing across the object
#'   facet and all random measurement facets, used to review whether pure error
#'   and highest-order interaction are difficult to separate
#' - `settings`: thresholds and facet choices used by the check
#' - `notes`: interpretation boundaries for the design check
#'
#' `plot.mfrm_generalizability_design_check(draw = FALSE)` returns an
#' `mfrm_plot_data` object with reusable `plot_table`, `facet_overview`,
#' `interaction_overview`, `highest_order_review`, `overview`, `guidance`, and
#' `figure_recipes` components.
#'
#' @section Interpretation:
#' The check is descriptive. It cannot guarantee a non-singular mixed model
#' fit, and it cannot prove that an interaction variance component is
#' substantively meaningful. Rows marked `sensitivity_only` or `review` mean
#' that the corresponding expanded G-study should be compared with the
#' main-effects baseline and reported with caution.
#'
#' The highest-order review is included because common MFRM rating tables have
#' one observation per person-by-rater-by-task or analogous full cell. In that
#' case the pure residual term and the highest-order interaction remain
#' difficult to separate, even when selected two-way interactions are estimable
#' as a descriptive sensitivity model.
#'
#' @seealso [mfrm_generalizability()], [compare_mfrm_generalizability()],
#'   [mfrm_d_study()], [mfrm_analysis_audit()], [plot_data()], [as_ggplot()]
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 30)
#' design_check <- check_mfrm_generalizability_design(
#'   fit,
#'   random_interactions = c("Person:Rater", "Rater:Criterion")
#' )
#' summary(design_check)
#' design_check$interaction_overview
#' design_check$highest_order_review
#' plot(design_check, draw = FALSE)
#' plot(design_check, type = "highest_order", draw = FALSE)
#' plot(design_check, type = "facet_levels", metric = "Levels", draw = FALSE)
#' plot_data_components(plot(design_check, draw = FALSE))
#' }
#' @export
check_mfrm_generalizability_design <- function(fit,
                                               data = NULL,
                                               object_facet = "Person",
                                               random_facets = NULL,
                                               random_interactions = NULL,
                                               min_levels = 2L,
                                               min_replicates_per_cell = 2L,
                                               sparse_cell_threshold = 0.5) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  args <- mfrm_gt_validate_design_check_args(
    min_levels = min_levels,
    min_replicates_per_cell = min_replicates_per_cell,
    sparse_cell_threshold = sparse_cell_threshold
  )
  facet_names <- as.character(fit$config$facet_names %||% character(0))
  if (is.null(random_facets)) {
    random_facets <- setdiff(facet_names, object_facet)
  }
  random_facets <- as.character(random_facets)
  if (length(random_facets) == 0L) {
    stop("At least one non-person facet is required as a random ",
         "condition of measurement.", call. = FALSE)
  }
  interaction_specs <- mfrm_gt_normalize_random_interactions(
    random_interactions = random_interactions,
    object_facet = object_facet,
    random_facets = random_facets
  )
  prepared <- mfrm_gt_prepare_design_data(
    fit = fit,
    data = data,
    object_facet = object_facet,
    random_facets = random_facets
  )
  design_data <- prepared$data
  all_facets <- c(object_facet, random_facets)
  role_lookup <- stats::setNames(
    c("object_of_measurement", rep("measurement_facet", length(random_facets))),
    all_facets
  )
  facet_overview <- mfrm_gt_facet_overview(
    data = design_data,
    facets = all_facets,
    role_lookup = role_lookup,
    min_levels = args$min_levels,
    min_replicates_per_cell = args$min_replicates_per_cell
  )
  interaction_overview <- mfrm_gt_interaction_overview(
    data = design_data,
    interaction_specs = interaction_specs,
    min_levels = args$min_levels,
    min_replicates_per_cell = args$min_replicates_per_cell,
    sparse_cell_threshold = args$sparse_cell_threshold
  )
  highest_order_review <- mfrm_gt_highest_order_review(
    data = design_data,
    facets = all_facets,
    min_levels = args$min_levels,
    min_replicates_per_cell = args$min_replicates_per_cell,
    sparse_cell_threshold = args$sparse_cell_threshold
  )

  facet_review <- sum(facet_overview$Status == "review", na.rm = TRUE)
  interaction_review <- sum(interaction_overview$Status == "review", na.rm = TRUE)
  interaction_sensitivity <- sum(interaction_overview$Status == "sensitivity_only",
                                 na.rm = TRUE)
  highest_status <- as.character(highest_order_review$Status[1] %||% NA_character_)
  highest_review <- identical(highest_status, "review")
  highest_sensitivity <- identical(highest_status, "sensitivity_only")
  overview <- data.frame(
    Rows = nrow(design_data),
    RowsOmittedForMissingFacets = prepared$rows_omitted,
    ObjectFacet = object_facet,
    RandomFacets = paste(random_facets, collapse = ", "),
    RequestedInteractions = paste(names(interaction_specs), collapse = ", "),
    RequestedInteractionCount = length(interaction_specs),
    FacetReviewCount = facet_review,
    InteractionReviewCount = interaction_review,
    InteractionSensitivityOnlyCount = interaction_sensitivity,
    HighestOrderStatus = highest_status,
    ReviewCount = facet_review + interaction_review + as.integer(highest_review),
    SensitivityOnlyCount = interaction_sensitivity + as.integer(highest_sensitivity),
    stringsAsFactors = FALSE
  )
  notes <- c(
    "This design check is descriptive and does not fit the G-study mixed model.",
    "A clean design check does not guarantee a non-singular lme4 fit.",
    if (length(interaction_specs) == 0L) {
      "No explicit random interactions were requested; the main-effects G-study leaves interaction variance in Residual."
    } else {
      "Requested two-way interactions should still be compared with the main-effects G-study before reporting."
    },
    "Highest-order cells with no exact replication imply that pure error and highest-order interaction remain difficult to separate."
  )
  out <- list(
    overview = overview,
    facet_overview = facet_overview,
    interaction_overview = interaction_overview,
    highest_order_review = highest_order_review,
    settings = list(
      object_facet = object_facet,
      random_facets = random_facets,
      random_interactions = names(interaction_specs),
      min_levels = args$min_levels,
      min_replicates_per_cell = args$min_replicates_per_cell,
      sparse_cell_threshold = args$sparse_cell_threshold
    ),
    notes = notes
  )
  class(out) <- c("mfrm_generalizability_design_check", "list")
  out
}

#' Generalizability-theory variance decomposition for an MFRM design
#'
#' Re-fits the rating data underlying an `mfrm_fit` as a crossed
#' random-effects model on the observed `Score` column,
#' `Score ~ 1 + (1 | Person) + (1 | Facet1) + ... + Residual`,
#' via `lme4::lmer`, and returns G-theory variance components plus
#' G / Phi coefficients. This is an observed-score G-theory complement to
#' the Rasch-style separation / reliability statistics that `diagnose_mfrm()`
#' emits; it does not re-estimate the MFRM, replace MFRM fit diagnostics, or
#' place G / Phi on the fitted logit scale.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param data Optional data frame. When `NULL`, the rating data
#'   stored on `fit$prep$data` is used.
#' @param object_facet Facet that plays the role of the "object of
#'   measurement" -- typically `"Person"` (default).
#' @param random_facets Character vector of non-person facets to
#'   treat as random conditions of measurement. Default uses every
#'   facet other than `object_facet`.
#' @param random_interactions Optional explicitly requested two-way random
#'   interactions, such as `"Person:Token"` or `"Rater:Token"`. The default
#'   `NULL` preserves the main-effects baseline and folds interaction variance
#'   into `Residual`.
#' @param reml Logical, passed to [lme4::lmer()] (default `TRUE`).
#' @param progress Logical. Whether to show a short CLI progress/status display
#'   while preparing the G-study model and fitting the crossed random-effects
#'   decomposition. Defaults to [interactive()], so interactive exploratory
#'   runs can show progress while tests, scripts, and report rendering stay
#'   quiet. Set `TRUE` or `FALSE` explicitly to override.
#'
#' @return An object of class `mfrm_generalizability` with:
#' \describe{
#'   \item{`variance_components`}{One row per random effect plus
#'     residual, with columns `Source`, `Variance`, and
#'     `ProportionVariance`.}
#'   \item{`coefficients`}{One-row data frame with `G`
#'     (generalizability coefficient, relative decision), `Phi`
#'     (dependability coefficient, absolute decision), and the single-cell
#'     relative / absolute error variance denominators.}
#'   \item{`design`}{Description of the crossed-random model, including
#'     `design_check` from [check_mfrm_generalizability_design()].}
#'   \item{`runtime`}{Elapsed-time metadata for the G-study refit.}
#' }
#' `plot.mfrm_generalizability(draw = FALSE)` returns an `mfrm_plot_data`
#' object with reusable `plot_table`, `variance_components`, `coefficients`,
#' `reading_order`, `guidance`, `figure_recipes`, and `interpretation_note`
#' components.
#'
#' @section Interpretation:
#' - This helper answers a G-theory design question on the observed-score
#'   scale: how much observed score variation is associated with the object
#'   of measurement, measurement facets, selected interactions, and residual
#'   error. It is complementary to MFRM separation reliability, not a
#'   competing estimate of the same quantity.
#' - `G` is appropriate for **relative** decisions (rank-ordering
#'   persons): `G = sigma2(p) / (sigma2(p) + sigma2(object-by-condition
#'   interactions) + sigma2(Residual))`.
#' - The reported `Phi` is appropriate for **absolute** decisions (cut-score
#'   classification): `Phi = sigma2(p) / (sigma2(p) + sigma2(facet
#'   main effects) + sigma2(non-object interactions) +
#'   sigma2(object-by-condition interactions) + sigma2(Residual))`, before
#'   D-study scaling.
#' - Use [mfrm_d_study()] to project `G` / `Phi` under planned numbers of
#'   raters, items, criteria, or other random measurement facets.
#' - Reporting bands follow Brennan (2001): G / Phi >= 0.8 for
#'   high-stakes decisions, >= 0.7 for routine reporting.
#'
#' @section Limitations:
#' The default `random_interactions = NULL` is the historical main-effects
#' baseline (`Score ~ 1 + (1|Person) + (1|Facet1) + ... + Residual`); all
#' two-way and higher interaction variance is then folded into `Residual`.
#' Supplying `random_interactions` estimates the named two-way components as
#' random effects. Components that are not specified still remain in
#' `Residual`, and the highest-order interaction / pure error term may remain
#' unidentified in one-observation-per-cell designs. Treat expanded models as
#' sensitivity evidence when designs are sparse, singular, or weakly connected.
#' Use [check_mfrm_generalizability_design()] before fitting interaction-
#' expanded models when crossing and exact-cell replication are unclear.
#'
#' @section Interaction-expanded G-studies:
#' `random_interactions` currently accepts **two-way** terms only. This is
#' intentional: in many MFRM rating designs there is one observation for each
#' person-by-rater-by-token (or analogous) cell, so the highest-order
#' interaction is confounded with residual error. Attempting to estimate
#' three-way terms such as `Person:Rater:Token` is usually not identified
#' without replicated observations within those exact cells and is rejected by
#' this helper. When expanded models are fitted, review
#' `gt$design$singular_fit`, `gt$design$lmer_warnings`, and
#' `gt$design$lmer_messages`; a singular fit means one or more variance
#' directions are estimated on the boundary and the expanded decomposition
#' should be reported as sensitivity evidence rather than a definitive
#' variance partition.
#'
#' @section References:
#' - Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N.
#'   (1972). *The dependability of behavioral measurements: Theory
#'   of generalizability for scores and profiles*. Wiley.
#' - Brennan, R. L. (2001). *Generalizability theory*. Springer.
#'
#' @seealso [check_mfrm_generalizability_design()], [mfrm_d_study()],
#'   [compare_mfrm_generalizability()],
#'   [compute_facet_icc()], [diagnose_mfrm()], [as_ggplot()],
#'   [plot_data_components()]
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 30)
#' if (requireNamespace("lme4", quietly = TRUE)) {
#'   gt <- mfrm_generalizability(fit)
#'   gt$variance_components
#'   # Look for: a Person variance component well above any single
#'   #   non-person facet's variance share. Large rater or criterion
#'   #   variance shares mean those conditions add measurement error
#'   #   relative to person spread.
#'   gt$coefficients
#'   # Look for: G >= 0.7 for routine reporting, >= 0.8 for high-stakes.
#'   #   G < Phi means absolute decisions are noisier than relative
#'   #   decisions; review whether facet main effects need anchoring.
#'   plot(gt, draw = FALSE)
#'   plot(gt, type = "coefficients", draw = FALSE)
#'   plot(gt, type = "design_check", draw = FALSE)
#'
#'   design_check <- check_mfrm_generalizability_design(
#'     fit,
#'     random_interactions = c("Person:Rater", "Rater:Criterion")
#'   )
#'   design_check$interaction_overview
#'
#'   gt_expanded <- mfrm_generalizability(
#'     fit,
#'     random_interactions = c("Person:Rater", "Rater:Criterion")
#'   )
#'   gt_expanded$variance_components[, c("Source", "Variance",
#'                                       "ComponentType", "DecisionRole")]
#'   gt_expanded$design$singular_fit
#' }
#' }
#' @export
mfrm_generalizability <- function(fit,
                                  data = NULL,
                                  object_facet = "Person",
                                  random_facets = NULL,
                                  random_interactions = NULL,
                                  reml = TRUE,
                                  progress = interactive()) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  if (!requireNamespace("lme4", quietly = TRUE)) {
    stop("`mfrm_generalizability()` requires the `lme4` package ",
         "(in Suggests). Install it and retry.", call. = FALSE)
  }
  if (!is.logical(progress) || length(progress) != 1L || is.na(progress)) {
    stop("`progress` must be a single TRUE/FALSE value.", call. = FALSE)
  }
  gstudy_started_at <- Sys.time()
  gstudy_progress_id <- NULL
  if (isTRUE(progress)) {
    gstudy_progress_id <- cli::cli_progress_bar(
      name = "mfrm_generalizability",
      total = 4L,
      format = paste(
        "{cli::pb_spin} G-study {cli::pb_current}/{cli::pb_total}",
        "[{cli::pb_elapsed}] {cli::pb_status}"
      ),
      clear = TRUE,
      .envir = parent.frame()
    )
    on.exit(cli::cli_progress_done(id = gstudy_progress_id), add = TRUE)
  }
  update_gstudy_progress <- function(step, status) {
    if (is.null(gstudy_progress_id)) return(invisible(NULL))
    cli::cli_progress_update(
      id = gstudy_progress_id,
      set = as.integer(step),
      status = as.character(status)
    )
    invisible(NULL)
  }
  update_gstudy_progress(0L, "checking rating data")
  if (is.null(data)) {
    data <- as.data.frame(fit$prep$data %||% data.frame(),
                          stringsAsFactors = FALSE)
  }
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("`data` is empty or not a data frame.", call. = FALSE)
  }

  facet_names <- as.character(fit$config$facet_names %||% character(0))
  if (is.null(random_facets)) {
    random_facets <- setdiff(facet_names, object_facet)
  }
  random_facets <- as.character(random_facets)
  if (length(random_facets) == 0L) {
    stop("At least one non-person facet is required as a random ",
         "condition of measurement.", call. = FALSE)
  }
  interaction_specs <- mfrm_gt_normalize_random_interactions(
    random_interactions = random_interactions,
    object_facet = object_facet,
    random_facets = random_facets
  )
  needed_cols <- c(object_facet, random_facets, "Score")
  missing_cols <- setdiff(needed_cols, names(data))
  if (length(missing_cols) > 0L) {
    stop("Data frame is missing required columns: ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }

  update_gstudy_progress(1L, "preparing crossed random-effects factors")
  for (col in c(object_facet, random_facets)) {
    if (!is.factor(data[[col]])) {
      data[[col]] <- as.factor(as.character(data[[col]]))
    }
  }
  data$Score <- suppressWarnings(as.numeric(data$Score))
  data <- data[is.finite(data$Score), , drop = FALSE]
  design_check <- check_mfrm_generalizability_design(
    fit = fit,
    data = data,
    object_facet = object_facet,
    random_facets = random_facets,
    random_interactions = if (length(interaction_specs) > 0L) {
      names(interaction_specs)
    } else {
      NULL
    }
  )

  random_terms <- c(
    object_facet,
    random_facets,
    vapply(interaction_specs, `[[`, character(1), "source")
  )
  random_groups <- vapply(random_terms, mfrm_gt_formula_group, character(1),
                          interaction_specs = interaction_specs)
  formula_str <- paste0(
    "Score ~ 1 + ",
    paste0("(1 | ", random_groups, ")", collapse = " + ")
  )
  formula <- stats::as.formula(formula_str)

  lmer_warnings <- character(0)
  lmer_messages <- character(0)
  update_gstudy_progress(2L, "fitting lme4 variance-component model")
  fit_lmer <- tryCatch(
    withCallingHandlers(
      lme4::lmer(formula, data = data, REML = isTRUE(reml)),
      warning = function(w) {
        lmer_warnings <<- c(lmer_warnings, trimws(conditionMessage(w)))
        invokeRestart("muffleWarning")
      },
      message = function(m) {
        lmer_messages <<- c(lmer_messages, trimws(conditionMessage(m)))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(e) e
  )
  if (inherits(fit_lmer, "error")) {
    stop("lme4::lmer failed: ", conditionMessage(fit_lmer), call. = FALSE)
  }
  singular_fit <- isTRUE(lme4::isSingular(fit_lmer, tol = 1e-4))

  update_gstudy_progress(3L, "summarizing G and Phi")
  vc <- as.data.frame(lme4::VarCorr(fit_lmer))
  vc <- vc[is.na(vc$var2), c("grp", "vcov")]
  total_var <- sum(vc$vcov, na.rm = TRUE)
  zero_tol <- sqrt(.Machine$double.eps)
  sources <- mfrm_gt_normalize_lme4_group(as.character(vc$grp), interaction_specs)
  metadata <- mfrm_gt_component_metadata(
    sources = sources,
    object_facet = object_facet,
    random_facets = random_facets,
    interaction_specs = interaction_specs
  )
  variance_raw <- stats::setNames(as.numeric(vc$vcov), sources)
  var_components <- data.frame(
    Source = sources,
    Variance = round(as.numeric(vc$vcov), 6),
    ProportionVariance = if (is.finite(total_var) && total_var > zero_tol) {
      round(vc$vcov / total_var, 4)
    } else {
      rep(NA_real_, length(vc$vcov))
    },
    stringsAsFactors = FALSE
  )
  var_components <- cbind(var_components, metadata)

  # G / Phi coefficients (single observation per cell convention).
  # Named object-by-condition interactions contribute to both relative
  # and absolute error; named condition-by-condition interactions
  # contribute only to absolute error. Unnamed interaction variance
  # remains in Residual.
  v <- variance_raw
  sigma2_p <- mfrm_gt_get_variance(v, object_facet, default = NA_real_)
  sigma2_residual <- mfrm_gt_get_variance(v, "Residual", default = NA_real_)
  if (!is.finite(sigma2_residual)) sigma2_residual <- 0
  sigma2_main <- if (length(random_facets) > 0L) {
    mfrm_gt_sum_variance(v, random_facets)
  } else 0
  object_interaction_sources <- names(interaction_specs)[vapply(interaction_specs, function(spec) {
    isTRUE(spec$includes_object)
  }, logical(1))]
  facet_interaction_sources <- setdiff(names(interaction_specs), object_interaction_sources)
  sigma2_object_interactions <- mfrm_gt_sum_variance(v, object_interaction_sources)
  sigma2_facet_interactions <- mfrm_gt_sum_variance(v, facet_interaction_sources)
  relative_error <- sigma2_object_interactions + sigma2_residual
  absolute_error <- sigma2_main + sigma2_object_interactions +
    sigma2_facet_interactions + sigma2_residual
  if (!is.finite(sigma2_p) || sigma2_p <= 0) {
    G_coef <- NA_real_
    Phi_coef <- NA_real_
  } else {
    G_coef <- sigma2_p / (sigma2_p + relative_error)
    Phi_coef <- sigma2_p / (sigma2_p + absolute_error)
  }

  gstudy_finished_at <- Sys.time()
  runtime <- gstudy_runtime_summary(
    started_at = gstudy_started_at,
    finished_at = gstudy_finished_at,
    data = data,
    random_facets = random_facets,
    random_interactions = names(interaction_specs),
    progress = progress,
    lmer_warnings = lmer_warnings,
    lmer_messages = lmer_messages,
    singular_fit = singular_fit
  )

  out <- list(
    variance_components = var_components,
    coefficients = data.frame(
      G = round(G_coef, 4),
      Phi = round(Phi_coef, 4),
      ObjectVariance = round(sigma2_p, 6),
      MainEffectErrorVariance = round(sigma2_main, 6),
      ObjectInteractionVariance = round(sigma2_object_interactions, 6),
      FacetInteractionVariance = round(sigma2_facet_interactions, 6),
      ResidualVariance = round(sigma2_residual, 6),
      RelativeErrorVariance = round(relative_error, 6),
      AbsoluteErrorVariance = round(absolute_error, 6),
      stringsAsFactors = FALSE
    ),
    design = list(
      object_facet = object_facet,
      random_facets = random_facets,
      random_interactions = interaction_specs,
      random_interaction_terms = names(interaction_specs),
      analysis_role = "observed_score_g_theory_complement",
      metric_basis = "observed_score",
      model_scope = if (length(interaction_specs) > 0L) "interaction_expanded" else "main_effects",
      observed_levels = stats::setNames(
        vapply(c(object_facet, random_facets), function(col) {
          dplyr::n_distinct(data[[col]])
        }, integer(1)),
        c(object_facet, random_facets)
      ),
      formula = format(formula),
      reml = isTRUE(reml),
      variance_raw = variance_raw,
      singular_fit = singular_fit,
      lmer_warnings = lmer_warnings,
      lmer_messages = lmer_messages,
      design_check = design_check
    ),
    runtime = runtime
  )
  class(out) <- c("mfrm_generalizability", "list")
  update_gstudy_progress(4L, "done")
  out
}

#' Project G-theory coefficients under alternative D-study designs
#'
#' @description
#' `mfrm_d_study()` applies a practical D-study projection to the
#' variance components from [mfrm_generalizability()]. It answers questions such
#' as "what happens to `G` and `Phi` if we use 2, 3, or 4 raters?" without
#' re-fitting the Rasch/MFRM model.
#'
#' @param x Output from [mfrm_generalizability()] or an `mfrm_fit` for
#'   `mfrm_d_study()`. For `plot.mfrm_d_study()`, an `mfrm_d_study` object.
#'   If an `mfrm_fit` is supplied to `mfrm_d_study()`,
#'   [mfrm_generalizability()] is called first.
#' @param design_grid Data frame or named list giving planned counts for each
#'   random measurement facet. Column names may be the facet names themselves
#'   (for example `Rater`) or `n_` plus the facet name (for example
#'   `n_Rater`). When `NULL`, one row using the observed number of levels is
#'   returned.
#' @param object_facet,random_facets,random_interactions Passed to
#'   [mfrm_generalizability()] when `x` is an `mfrm_fit`.
#' @param residual_scaling How the collapsed residual variance should be scaled
#'   when planned facet counts increase. `"highest_order"` treats the residual
#'   as highest-order person-by-all-conditions/error variance and divides by
#'   the product of planned counts. `"single_condition"` divides by the smallest
#'   planned facet count, a conservative sensitivity check when unmodeled
#'   person-by-one-facet interactions may dominate. `"none"` leaves the residual
#'   unscaled. `"sensitivity"` returns all three assumptions for each design
#'   row.
#' @param progress Logical. When `x` is an `mfrm_fit`, passed to
#'   [mfrm_generalizability()] so the G-study refit can show a short
#'   progress/status display. Defaults to [interactive()]. D-study projection
#'   from an already-computed `mfrm_generalizability` object is analytic and
#'   usually completes too quickly to need progress output.
#' @param ... Additional arguments passed to [mfrm_generalizability()] when `x`
#'   is an `mfrm_fit`.
#'
#' @details
#' The projection uses the variance decomposition already estimated by
#' [mfrm_generalizability()]. For a random measurement facet `j`, main-effect
#' variance contributes `sigma2_j / n_j` to the absolute-error denominator.
#' An object-by-facet interaction such as `Person:Rater` contributes
#' `sigma2_pr / n_rater` to both relative and absolute error; a non-object
#' interaction such as `Rater:Token` contributes `sigma2_rt / (n_rater *
#' n_token)` to absolute error only. The residual term contains any unmodeled
#' interactions and highest-order error, so the selected `residual_scaling`
#' assumption is reported explicitly.
#'
#' This is a pragmatic D-study planning layer. If person-by-rater or
#' person-by-item interactions are a primary estimand, supply those terms via
#' `random_interactions` and use `residual_scaling = "sensitivity"` to show how
#' conclusions change under residual-scaling assumptions. Sparse or singular
#' expanded models should be reported as sensitivity evidence.
#'
#' The `G` and `Phi` values returned here belong to the generalizability-theory
#' metric family and stay on the observed-score variance decomposition from the
#' upstream G-study. They should not be interpreted as coefficient alpha, omega,
#' KR-20, MFRM separation reliability, or IRT marginal reliability, even though
#' all of those summaries may be displayed on a 0--1 scale in broader reporting
#' dashboards.
#'
#' @return `mfrm_d_study()` returns an object of class `mfrm_d_study`, a
#'   data.frame with one row per design scenario and columns for planned facet
#'   counts, variance terms, projected `G`, projected `Phi`, and interpretation
#'   bands. The object carries a `runtime` attribute with projection elapsed
#'   time and, when applicable, the upstream G-study refit elapsed time.
#'   `plot.mfrm_d_study(draw = FALSE)` returns an `mfrm_plot_data`
#'   object with reusable `table`, `series`, optional `surface`,
#'   `reading_order`, `guidance`, `figure_recipes`, and `interpretation_note`
#'   components.
#'
#' @references
#' Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N.
#' (1972). *The dependability of behavioral measurements: Theory of
#' generalizability for scores and profiles*. Wiley.
#'
#' Brennan, R. L. (2001). *Generalizability theory*. Springer.
#'
#' @seealso [mfrm_generalizability()], [compare_mfrm_generalizability()],
#'   [evaluate_mfrm_design()], [recommend_mfrm_design()], [plot_data()]
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 30)
#' if (requireNamespace("lme4", quietly = TRUE)) {
#'   gt <- mfrm_generalizability(fit)
#'   ds <- mfrm_d_study(gt, data.frame(Rater = c(2, 3, 4), Criterion = 4))
#'   plot(ds, draw = FALSE)
#'
#'   gt_expanded <- mfrm_generalizability(
#'     fit,
#'     random_interactions = c("Person:Rater", "Rater:Criterion")
#'   )
#'   mfrm_d_study(
#'     gt_expanded,
#'     expand.grid(Rater = 2:4, Criterion = c(2, 4)),
#'     residual_scaling = "sensitivity"
#'   )
#' }
#' }
#' @export
mfrm_d_study <- function(x,
                         design_grid = NULL,
                         object_facet = "Person",
                         random_facets = NULL,
                         random_interactions = NULL,
                         residual_scaling = c("highest_order", "single_condition", "none", "sensitivity"),
                         progress = interactive(),
                         ...) {
  dstudy_started_at <- Sys.time()
  residual_scaling <- match.arg(residual_scaling)
  if (!is.logical(progress) || length(progress) != 1L || is.na(progress)) {
    stop("`progress` must be a single TRUE/FALSE value.", call. = FALSE)
  }
  source_was_fit <- inherits(x, "mfrm_fit")
  if (inherits(x, "mfrm_fit")) {
    x <- mfrm_generalizability(
      x,
      object_facet = object_facet,
      random_facets = random_facets,
      random_interactions = random_interactions,
      progress = progress,
      ...
    )
  }
  if (!inherits(x, "mfrm_generalizability")) {
    stop("`x` must be output from mfrm_generalizability() or an mfrm_fit object.", call. = FALSE)
  }

  random_facets <- as.character(x$design$random_facets %||% character(0))
  if (length(random_facets) == 0L) {
    stop("No random measurement facets are available for D-study projection.", call. = FALSE)
  }
  observed_levels <- x$design$observed_levels %||% NULL
  if (is.null(design_grid)) {
    if (is.null(observed_levels)) {
      stop("`design_grid` is required because observed facet counts are unavailable.", call. = FALSE)
    }
    design_grid <- as.data.frame(as.list(observed_levels[random_facets]), stringsAsFactors = FALSE)
  } else if (is.list(design_grid) && !is.data.frame(design_grid)) {
    design_grid <- as.data.frame(design_grid, stringsAsFactors = FALSE)
  } else {
    design_grid <- as.data.frame(design_grid, stringsAsFactors = FALSE)
  }
  if (nrow(design_grid) == 0L) {
    stop("`design_grid` must contain at least one design row.", call. = FALSE)
  }

  count_cols <- vapply(random_facets, function(facet) {
    prefixed <- paste0("n_", facet)
    if (facet %in% names(design_grid)) {
      facet
    } else if (prefixed %in% names(design_grid)) {
      prefixed
    } else {
      NA_character_
    }
  }, character(1))
  if (anyNA(count_cols)) {
    missing <- random_facets[is.na(count_cols)]
    stop(
      "`design_grid` is missing count column(s) for random facet(s): ",
      paste(missing, collapse = ", "),
      ". Use either the facet name or `n_<facet>`.",
      call. = FALSE
    )
  }

  counts <- as.data.frame(
    lapply(count_cols, function(col) suppressWarnings(as.numeric(design_grid[[col]]))),
    stringsAsFactors = FALSE
  )
  names(counts) <- paste0("n_", random_facets)
  counts_matrix <- as.matrix(counts)
  if (any(!is.finite(counts_matrix) | counts_matrix <= 0)) {
    stop("All D-study facet counts must be positive finite numbers.", call. = FALSE)
  }
  scaling_levels <- if (identical(residual_scaling, "sensitivity")) {
    c("highest_order", "single_condition", "none")
  } else {
    residual_scaling
  }
  if (length(scaling_levels) > 1L) {
    row_index <- rep(seq_len(nrow(counts)), each = length(scaling_levels))
    counts <- counts[row_index, , drop = FALSE]
    scaling_col <- rep(scaling_levels, times = length(unique(row_index)))
  } else {
    scaling_col <- rep(scaling_levels, nrow(counts))
  }

  v <- mfrm_gt_variance_vector(x)
  sigma2_p <- mfrm_gt_get_variance(v, x$design$object_facet, default = NA_real_)
  sigma2_residual <- mfrm_gt_get_variance(v, "Residual", default = 0)
  if (!is.finite(sigma2_residual)) sigma2_residual <- 0
  facet_main_error <- numeric(nrow(counts))
  for (facet in random_facets) {
    sigma2_f <- mfrm_gt_get_variance(v, facet, default = 0)
    facet_main_error <- facet_main_error + sigma2_f / counts[[paste0("n_", facet)]]
  }
  interaction_specs <- x$design$random_interactions %||% list()
  object_interaction_error <- mfrm_gt_project_interaction_error(
    interaction_specs = interaction_specs,
    v = v,
    counts = counts,
    random_facets = random_facets,
    includes_object = TRUE
  )
  facet_interaction_error <- mfrm_gt_project_interaction_error(
    interaction_specs = interaction_specs,
    v = v,
    counts = counts,
    random_facets = random_facets,
    includes_object = FALSE
  )
  residual_divisor <- vapply(seq_len(nrow(counts)), function(i) {
    row_counts <- unlist(counts[i, , drop = TRUE], use.names = FALSE)
    switch(
      scaling_col[i],
      highest_order = prod(row_counts),
      single_condition = min(row_counts),
      none = 1,
      prod(row_counts)
    )
  }, numeric(1))
  residual_error <- sigma2_residual / residual_divisor
  rel_error <- object_interaction_error + residual_error
  abs_error <- facet_main_error + object_interaction_error +
    facet_interaction_error + residual_error
  if (!is.finite(sigma2_p) || sigma2_p <= 0) {
    projected_g <- rep(NA_real_, nrow(counts))
    projected_phi <- rep(NA_real_, nrow(counts))
  } else {
    projected_g <- sigma2_p / (sigma2_p + rel_error)
    projected_phi <- sigma2_p / (sigma2_p + abs_error)
  }

  classify_coef <- function(value) {
    dplyr::case_when(
      !is.finite(value) ~ "unavailable",
      value >= 0.80 ~ "high_stakes_candidate",
      value >= 0.70 ~ "routine_candidate",
      TRUE ~ "review"
    )
  }
  out <- cbind(
    data.frame(Scenario = seq_len(nrow(counts)), counts, stringsAsFactors = FALSE),
    data.frame(
      ResidualScaling = scaling_col,
      ResidualDivisor = residual_divisor,
      ObjectVariance = sigma2_p,
      MainEffectErrorVariance = facet_main_error,
      ObjectInteractionErrorVariance = object_interaction_error,
      FacetInteractionErrorVariance = facet_interaction_error,
      ResidualErrorVariance = residual_error,
      RelativeErrorVariance = rel_error,
      AbsoluteErrorVariance = abs_error,
      G = round(projected_g, 4),
      Phi = round(projected_phi, 4),
      GStatus = classify_coef(projected_g),
      PhiStatus = classify_coef(projected_phi),
      stringsAsFactors = FALSE
    )
  )
  attr(out, "object_facet") <- x$design$object_facet
  attr(out, "random_facets") <- random_facets
  attr(out, "random_interactions") <- names(interaction_specs)
  attr(out, "residual_scaling") <- residual_scaling
  attr(out, "source") <- "mfrm_generalizability"
  dstudy_finished_at <- Sys.time()
  dstudy_elapsed <- as.numeric(difftime(dstudy_finished_at, dstudy_started_at, units = "secs"))
  gstudy_runtime <- as.data.frame(x$runtime %||% data.frame(), stringsAsFactors = FALSE)
  attr(out, "runtime") <- data.frame(
    StartedAt = format(dstudy_started_at, "%Y-%m-%d %H:%M:%S %Z"),
    FinishedAt = format(dstudy_finished_at, "%Y-%m-%d %H:%M:%S %Z"),
    ProjectionElapsedSec = if (is.finite(dstudy_elapsed)) dstudy_elapsed else NA_real_,
    GStudyElapsedSec = if ("ElapsedSec" %in% names(gstudy_runtime)) {
      suppressWarnings(as.numeric(gstudy_runtime$ElapsedSec[1]))
    } else {
      NA_real_
    },
    SourceWasFit = isTRUE(source_was_fit),
    ProgressShown = isTRUE(progress),
    stringsAsFactors = FALSE
  )
  class(out) <- c("mfrm_d_study", "data.frame")
  out
}

#' Compare main-effects and interaction-expanded G-study decompositions
#'
#' @description
#' `compare_mfrm_generalizability()` fits the historical main-effects
#' G-study baseline and an explicitly requested interaction-expanded G-study,
#' then reports how the G / Phi coefficients, variance components, and optional
#' D-study projections change. This is a sensitivity-review layer: it helps
#' users see how much observed-score variance moves out of `Residual` when
#' targeted token, rater, item, or criterion interactions are estimated
#' separately. It does not compare MFRM separation reliability with G-theory
#' reliability-like coefficients.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param data Optional data frame passed to [mfrm_generalizability()].
#' @param object_facet Facet that plays the role of the object of measurement.
#' @param random_facets Character vector of random measurement facets. Default
#'   uses every facet other than `object_facet`.
#' @param random_interactions Explicit two-way random interactions for the
#'   expanded model, such as `"Person:Token"` or
#'   `c("Person:Rater", "Rater:Token")`.
#' @param design_grid Optional D-study grid passed to [mfrm_d_study()] for both
#'   baseline and expanded decompositions. When `NULL`, observed facet counts
#'   are used.
#' @param residual_scaling Residual-scaling assumption passed to
#'   [mfrm_d_study()]. The default `"sensitivity"` returns the three built-in
#'   assumptions for both decompositions.
#' @param reml Logical, passed to [mfrm_generalizability()].
#' @param progress Logical, passed to [mfrm_generalizability()] for the two
#'   G-study refits.
#'
#' @details
#' This comparison should not be read as automatic evidence that the expanded
#' model is superior. If the expanded model is singular, or if a named
#' interaction variance is estimated at zero, the result usually means the data
#' do not support separating that component from the remaining residual/error
#' structure. The intended workflow is to use this helper as a reporting
#' sensitivity check, then keep the main-effects baseline or a smaller
#' interaction set when the expanded model is unstable.
#'
#' @return An object of class `mfrm_generalizability_comparison`, a list with
#'   `summary`, `comparison_review`, `coefficients`, `variance_components`,
#'   `variance_delta`, `d_study`, `design_checks`, `baseline`, `expanded`, and
#'   `warnings`.
#'
#' @seealso [mfrm_generalizability()], [mfrm_d_study()]
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 30)
#' if (requireNamespace("lme4", quietly = TRUE)) {
#'   cmp <- compare_mfrm_generalizability(
#'     fit,
#'     random_interactions = c("Person:Rater", "Rater:Criterion"),
#'     design_grid = expand.grid(Rater = 2:4, Criterion = 4),
#'     residual_scaling = "sensitivity"
#'   )
#'   cmp$summary
#'   cmp$comparison_review
#'   cmp$design_checks$overview
#'   cmp$variance_delta
#'   cmp$warnings
#'   plot(cmp, type = "design_check", draw = FALSE)
#' }
#' }
#' @export
compare_mfrm_generalizability <- function(fit,
                                          data = NULL,
                                          object_facet = "Person",
                                          random_facets = NULL,
                                          random_interactions = NULL,
                                          design_grid = NULL,
                                          residual_scaling = c("sensitivity", "highest_order", "single_condition", "none"),
                                          reml = TRUE,
                                          progress = interactive()) {
  residual_scaling <- match.arg(residual_scaling)
  if (is.null(random_interactions) || length(random_interactions) == 0L) {
    stop(
      "`random_interactions` must name at least one explicit two-way term, ",
      "for example `\"Person:Token\"`, for the expanded sensitivity model.",
      call. = FALSE
    )
  }
  if (!is.logical(progress) || length(progress) != 1L || is.na(progress)) {
    stop("`progress` must be a single TRUE/FALSE value.", call. = FALSE)
  }

  baseline <- mfrm_generalizability(
    fit,
    data = data,
    object_facet = object_facet,
    random_facets = random_facets,
    random_interactions = NULL,
    reml = reml,
    progress = progress
  )
  expanded <- mfrm_generalizability(
    fit,
    data = data,
    object_facet = object_facet,
    random_facets = random_facets,
    random_interactions = random_interactions,
    reml = reml,
    progress = progress
  )

  baseline_coef <- as.data.frame(baseline$coefficients, stringsAsFactors = FALSE)
  expanded_coef <- as.data.frame(expanded$coefficients, stringsAsFactors = FALSE)
  numeric_cols <- intersect(names(baseline_coef), names(expanded_coef))
  delta_coef <- expanded_coef
  for (col in numeric_cols) {
    delta_coef[[col]] <- suppressWarnings(as.numeric(expanded_coef[[col]]) -
                                            as.numeric(baseline_coef[[col]]))
  }
  coefficients <- rbind(
    data.frame(Model = "baseline_main_effects", baseline_coef, stringsAsFactors = FALSE),
    data.frame(Model = "interaction_expanded", expanded_coef, stringsAsFactors = FALSE),
    data.frame(Model = "expanded_minus_baseline", delta_coef, stringsAsFactors = FALSE)
  )
  row.names(coefficients) <- NULL

  baseline_vc <- data.frame(Model = "baseline_main_effects",
                            baseline$variance_components,
                            stringsAsFactors = FALSE)
  expanded_vc <- data.frame(Model = "interaction_expanded",
                            expanded$variance_components,
                            stringsAsFactors = FALSE)
  variance_components <- rbind(baseline_vc, expanded_vc)
  row.names(variance_components) <- NULL

  base_v <- mfrm_gt_variance_vector(baseline)
  expanded_v <- mfrm_gt_variance_vector(expanded)
  all_sources <- union(names(base_v), names(expanded_v))
  component_lookup <- stats::setNames(
    as.character(expanded$variance_components$ComponentType),
    as.character(expanded$variance_components$Source)
  )
  base_component_lookup <- stats::setNames(
    as.character(baseline$variance_components$ComponentType),
    as.character(baseline$variance_components$Source)
  )
  variance_delta <- data.frame(
    Source = all_sources,
    ComponentType = vapply(all_sources, function(source) {
      expanded_type <- if (source %in% names(component_lookup)) {
        component_lookup[[source]]
      } else {
        NA_character_
      }
      baseline_type <- if (source %in% names(base_component_lookup)) {
        base_component_lookup[[source]]
      } else {
        NA_character_
      }
      if (!is.na(expanded_type) && nzchar(expanded_type)) {
        expanded_type
      } else if (!is.na(baseline_type) && nzchar(baseline_type)) {
        baseline_type
      } else {
        "other"
      }
    }, character(1)),
    BaselineVariance = vapply(all_sources, function(source) {
      mfrm_gt_get_variance(base_v, source, default = 0)
    }, numeric(1)),
    ExpandedVariance = vapply(all_sources, function(source) {
      mfrm_gt_get_variance(expanded_v, source, default = 0)
    }, numeric(1)),
    stringsAsFactors = FALSE
  )
  variance_delta$DeltaVariance <- variance_delta$ExpandedVariance -
    variance_delta$BaselineVariance

  baseline_d <- mfrm_d_study(
    baseline,
    design_grid = design_grid,
    residual_scaling = residual_scaling,
    progress = progress
  )
  expanded_d <- mfrm_d_study(
    expanded,
    design_grid = design_grid,
    residual_scaling = residual_scaling,
    progress = progress
  )
  d_study <- rbind(
    data.frame(Model = "baseline_main_effects", baseline_d, stringsAsFactors = FALSE),
    data.frame(Model = "interaction_expanded", expanded_d, stringsAsFactors = FALSE)
  )
  row.names(d_study) <- NULL

  design_checks <- mfrm_gt_comparison_design_checks(
    baseline = baseline,
    expanded = expanded
  )

  warnings <- do.call(rbind, list(
    mfrm_gt_comparison_warnings(baseline, "baseline_main_effects"),
    mfrm_gt_comparison_warnings(expanded, "interaction_expanded")
  ))
  row.names(warnings) <- NULL

  summary <- data.frame(
    RandomInteractions = paste(expanded$design$random_interaction_terms, collapse = ", "),
    BaselineG = baseline_coef$G,
    ExpandedG = expanded_coef$G,
    DeltaG = expanded_coef$G - baseline_coef$G,
    BaselinePhi = baseline_coef$Phi,
    ExpandedPhi = expanded_coef$Phi,
    DeltaPhi = expanded_coef$Phi - baseline_coef$Phi,
    BaselineSingular = isTRUE(baseline$design$singular_fit),
    ExpandedSingular = isTRUE(expanded$design$singular_fit),
    BaselineDesignReview = sum(design_checks$overview$Model == "baseline_main_effects" &
                                 design_checks$overview$Status == "review",
                               na.rm = TRUE),
    ExpandedDesignReview = sum(design_checks$overview$Model == "interaction_expanded" &
                                 design_checks$overview$Status == "review",
                               na.rm = TRUE),
    ExpandedDesignSensitivityOnly = sum(design_checks$overview$Model == "interaction_expanded" &
                                          design_checks$overview$Status == "sensitivity_only",
                                        na.rm = TRUE),
    stringsAsFactors = FALSE
  )

  comparison_review <- mfrm_gt_comparison_review(
    summary = summary,
    variance_delta = variance_delta,
    d_study = d_study,
    design_checks = design_checks,
    warnings = warnings
  )
  summary$ComparisonReview <- sum(comparison_review$Status == "review",
                                  na.rm = TRUE)
  summary$ComparisonSensitivityOnly <- sum(
    comparison_review$Status == "sensitivity_only",
    na.rm = TRUE
  )

  out <- list(
    summary = summary,
    comparison_review = comparison_review,
    coefficients = coefficients,
    variance_components = variance_components,
    variance_delta = variance_delta,
    d_study = d_study,
    design_checks = design_checks,
    baseline = baseline,
    expanded = expanded,
    warnings = warnings
  )
  class(out) <- c("mfrm_generalizability_comparison", "list")
  out
}

mfrm_gt_bootstrap_interval <- function(values, point_estimate, ci) {
  values <- suppressWarnings(as.numeric(values))
  values <- values[is.finite(values)]
  alpha <- (1 - ci) / 2
  if (length(values) == 0L) {
    return(data.frame(
      PointEstimate = point_estimate,
      Mean = NA_real_,
      SD = NA_real_,
      Median = NA_real_,
      Lower = NA_real_,
      Upper = NA_real_,
      SuccessfulReps = 0L,
      stringsAsFactors = FALSE
    ))
  }
  qs <- stats::quantile(values, probs = c(alpha, 1 - alpha),
                        na.rm = TRUE, names = FALSE, type = 6)
  data.frame(
    PointEstimate = point_estimate,
    Mean = mean(values, na.rm = TRUE),
    SD = if (length(values) > 1L) stats::sd(values, na.rm = TRUE) else NA_real_,
    Median = stats::median(values, na.rm = TRUE),
    Lower = qs[1L],
    Upper = qs[2L],
    SuccessfulReps = length(values),
    stringsAsFactors = FALSE
  )
}

mfrm_gt_bootstrap_intervals <- function(point_estimate,
                                        coefficient_draws,
                                        variance_draws,
                                        ci) {
  point_coef <- as.data.frame(point_estimate$coefficients %||% data.frame(),
                              stringsAsFactors = FALSE)
  coef_names <- names(point_coef)[vapply(point_coef, function(col) {
    is.numeric(col) || is.integer(col)
  }, logical(1))]
  coef_intervals <- lapply(coef_names, function(metric) {
    value <- suppressWarnings(as.numeric(point_coef[[metric]][1L] %||% NA_real_))
    iv <- mfrm_gt_bootstrap_interval(coefficient_draws[[metric]], value, ci)
    data.frame(
      Target = "coefficient",
      Source = NA_character_,
      Metric = metric,
      ComponentType = NA_character_,
      DecisionRole = NA_character_,
      iv,
      stringsAsFactors = FALSE
    )
  })

  point_vc <- as.data.frame(point_estimate$variance_components %||% data.frame(),
                            stringsAsFactors = FALSE)
  variance_intervals <- lapply(seq_len(nrow(point_vc)), function(i) {
    source <- as.character(point_vc$Source[i])
    metric <- "Variance"
    point_value <- suppressWarnings(as.numeric(point_vc$Variance[i]))
    rows <- variance_draws[as.character(variance_draws$Source) == source, , drop = FALSE]
    iv <- mfrm_gt_bootstrap_interval(rows[[metric]], point_value, ci)
    data.frame(
      Target = "variance_component",
      Source = source,
      Metric = metric,
      ComponentType = as.character(point_vc$ComponentType[i] %||% NA_character_),
      DecisionRole = as.character(point_vc$DecisionRole[i] %||% NA_character_),
      iv,
      stringsAsFactors = FALSE
    )
  })

  out <- do.call(rbind, c(coef_intervals, variance_intervals))
  row.names(out) <- NULL
  out$CI <- ci
  out$Method <- "observed_data_person_cluster_percentile_bootstrap"
  out
}

#' Bootstrap observed-score G-study uncertainty
#'
#' @description
#' `bootstrap_mfrm_generalizability()` resamples observed rating rows by person
#' cluster and refits [mfrm_generalizability()] on each bootstrap draw. It is a
#' reporting and sensitivity helper for observed-score G / Phi uncertainty, not
#' an MFRM separation-reliability estimator and not a replacement for the
#' fitted many-facet model.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param data Optional rating data. When `NULL`, the data stored in `fit` are
#'   used.
#' @param object_facet Name of the object-of-measurement facet.
#' @param random_facets Measurement facets to include as random components.
#'   When `NULL`, all fitted non-object facets are used.
#' @param random_interactions Optional explicit two-way interaction terms such
#'   as `"Person:Criterion"`.
#' @param reps Number of bootstrap replicates.
#' @param ci Confidence level for percentile intervals.
#' @param strata Optional facet columns used for stratified resampling.
#' @param preserve_facets Optional facet columns whose observed levels should
#'   be topped up in sparse bootstrap draws when missing.
#' @param reml Passed to the underlying mixed-model G-study fit.
#' @param seed Optional random seed.
#' @param progress Whether to show a progress bar.
#'
#' @return An object of class `mfrm_generalizability_bootstrap`, a list with
#' bootstrap overview, interval, draw, failure, setting, and terminology
#' components.
#'
#' @seealso [mfrm_generalizability()], [check_mfrm_generalizability_design()],
#'   [compare_mfrm_generalizability()]
#' @concept generalizability theory
#' @concept uncertainty displays
#' @export
bootstrap_mfrm_generalizability <- function(fit,
                                            data = NULL,
                                            object_facet = "Person",
                                            random_facets = NULL,
                                            random_interactions = NULL,
                                            reps = 100,
                                            ci = 0.95,
                                            strata = NULL,
                                            preserve_facets = NULL,
                                            reml = TRUE,
                                            seed = NULL,
                                            progress = interactive()) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  if (!is.logical(progress) || length(progress) != 1L || is.na(progress)) {
    stop("`progress` must be a single TRUE/FALSE value.", call. = FALSE)
  }
  reps <- suppressWarnings(as.integer(reps[1L]))
  if (!is.finite(reps) || reps < 1L) {
    stop("`reps` must be a positive integer.", call. = FALSE)
  }
  ci <- suppressWarnings(as.numeric(ci[1L]))
  if (!is.finite(ci) || ci <= 0 || ci >= 1) {
    stop("`ci` must be a finite number in (0, 1).", call. = FALSE)
  }
  started_at <- Sys.time()
  if (is.null(data)) {
    data <- as.data.frame(fit$prep$data %||% data.frame(),
                          stringsAsFactors = FALSE)
  } else {
    data <- as.data.frame(data, stringsAsFactors = FALSE)
  }
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("`data` is empty or not a data frame.", call. = FALSE)
  }
  facet_names <- as.character(fit$config$facet_names %||% character(0))
  if (is.null(random_facets)) {
    random_facets <- setdiff(facet_names, object_facet)
  }
  random_facets <- as.character(random_facets)
  preserve_facets <- as.character(preserve_facets %||% character(0))
  strata <- as.character(strata %||% character(0))

  point <- mfrm_generalizability(
    fit,
    data = data,
    object_facet = object_facet,
    random_facets = random_facets,
    random_interactions = random_interactions,
    reml = reml,
    progress = FALSE
  )

  spec <- build_mfrm_resampling_spec(
    data = data,
    person = object_facet,
    facets = random_facets,
    score = "Score",
    strata = strata,
    preserve_facets = preserve_facets,
    design = "stratified_bootstrap",
    reps = reps,
    sample_fraction = 1,
    replace = TRUE,
    seed = seed,
    topup_preserve_facets = length(preserve_facets) > 0L
  )
  draws <- draw_mfrm_resamples(spec)

  progress_id <- NULL
  if (isTRUE(progress)) {
    progress_id <- cli::cli_progress_bar(
      name = "bootstrap_mfrm_generalizability",
      total = reps,
      format = paste(
        "{cli::pb_spin} bootstrap G-study {cli::pb_current}/{cli::pb_total}",
        "[{cli::pb_elapsed}] {cli::pb_status}"
      ),
      clear = TRUE,
      .envir = parent.frame()
    )
    on.exit(cli::cli_progress_done(id = progress_id), add = TRUE)
  }

  coef_rows <- vector("list", reps)
  vc_rows <- vector("list", reps)
  failure_rows <- vector("list", reps)
  for (rep_id in seq_len(reps)) {
    if (!is.null(progress_id)) {
      cli::cli_progress_update(id = progress_id, set = rep_id,
                               status = paste0("replicate ", rep_id))
    }
    boot_data <- draws$samples[[rep_id]]
    fit_rep <- tryCatch(
      mfrm_generalizability(
        fit,
        data = boot_data,
        object_facet = object_facet,
        random_facets = random_facets,
        random_interactions = random_interactions,
        reml = reml,
        progress = FALSE
      ),
      error = function(e) e
    )
    if (inherits(fit_rep, "error")) {
      failure_rows[[rep_id]] <- data.frame(
        Replicate = rep_id,
        Message = conditionMessage(fit_rep),
        stringsAsFactors = FALSE
      )
      next
    }
    coef <- as.data.frame(fit_rep$coefficients %||% data.frame(),
                          stringsAsFactors = FALSE)
    coef_rows[[rep_id]] <- data.frame(
      Replicate = rep_id,
      SingularFit = isTRUE(fit_rep$design$singular_fit),
      LmerWarnings = length(fit_rep$design$lmer_warnings %||% character(0)),
      LmerMessages = length(fit_rep$design$lmer_messages %||% character(0)),
      coef,
      stringsAsFactors = FALSE
    )
    vc <- as.data.frame(fit_rep$variance_components %||% data.frame(),
                        stringsAsFactors = FALSE)
    vc_rows[[rep_id]] <- data.frame(
      Replicate = rep_id,
      vc,
      stringsAsFactors = FALSE
    )
  }
  coefficient_draws <- dplyr::bind_rows(coef_rows)
  variance_draws <- dplyr::bind_rows(vc_rows)
  failures <- dplyr::bind_rows(failure_rows)
  if (nrow(failures) == 0L) {
    failures <- data.frame(Replicate = integer(), Message = character(),
                           stringsAsFactors = FALSE)
  }
  intervals <- mfrm_gt_bootstrap_intervals(
    point_estimate = point,
    coefficient_draws = coefficient_draws,
    variance_draws = variance_draws,
    ci = ci
  )
  finished_at <- Sys.time()
  elapsed <- as.numeric(difftime(finished_at, started_at, units = "secs"))
  overview <- data.frame(
    RepsRequested = reps,
    RepsSucceeded = nrow(coefficient_draws),
    RepsFailed = nrow(failures),
    CI = ci,
    Method = "observed_data_person_cluster_percentile_bootstrap",
    Strata = paste(strata, collapse = ", "),
    PreserveFacets = paste(preserve_facets, collapse = ", "),
    ElapsedSec = if (is.finite(elapsed)) elapsed else NA_real_,
    stringsAsFactors = FALSE
  )
  out <- list(
    overview = overview,
    point_estimate = point,
    intervals = intervals,
    coefficient_draws = coefficient_draws,
    variance_draws = variance_draws,
    failures = failures,
    resamples = draws,
    settings = list(
      object_facet = object_facet,
      random_facets = random_facets,
      random_interactions = random_interactions,
      reps = reps,
      ci = ci,
      strata = strata,
      preserve_facets = preserve_facets,
      reml = isTRUE(reml),
      seed = seed
    ),
    terminology = c(
      "Bootstrap intervals summarize observed-data resampling stability around the G-study decomposition.",
      "They are not MFRM separation-reliability intervals and do not prove that unsupported interactions are identified.",
      "Use more than a smoke-test number of replicates before reporting interval estimates."
    )
  )
  class(out) <- c("mfrm_generalizability_bootstrap", "list")
  out
}

mfrm_gt_comparison_review <- function(summary,
                                      variance_delta,
                                      d_study,
                                      design_checks,
                                      warnings) {
  scalar_num <- function(x, default = NA_real_) {
    x <- suppressWarnings(as.numeric(x))
    x <- x[is.finite(x)]
    if (length(x) == 0L) return(default)
    x[1L]
  }
  fmt <- function(x, digits = 3L) {
    x <- suppressWarnings(as.numeric(x))
    if (!is.finite(x)) return("NA")
    formatC(x, digits = digits, format = "f")
  }
  make_row <- function(checkpoint, status, evidence, interpretation,
                       next_action, boundary) {
    data.frame(
      Checkpoint = checkpoint,
      Status = status,
      Evidence = evidence,
      Interpretation = interpretation,
      NextAction = next_action,
      Boundary = boundary,
      stringsAsFactors = FALSE
    )
  }

  overview <- as.data.frame(design_checks$overview %||% data.frame(),
                            stringsAsFactors = FALSE)
  if (!all(c("Model", "Status") %in% names(overview))) {
    overview <- data.frame(Model = character(), Status = character(),
                           SourceTable = character(), stringsAsFactors = FALSE)
  }
  count_status <- function(model, status) {
    sum(as.character(overview$Model) == model &
          as.character(overview$Status) == status,
        na.rm = TRUE)
  }
  highest_status <- function(model) {
    if (!all(c("Model", "SourceTable", "Status") %in% names(overview))) {
      return("unavailable")
    }
    rows <- overview[
      as.character(overview$Model) == model &
        as.character(overview$SourceTable) == "highest_order_review",
      ,
      drop = FALSE
    ]
    if (nrow(rows) == 0L) return("unavailable")
    as.character(rows$Status[1L])
  }
  baseline_review <- count_status("baseline_main_effects", "review")
  expanded_review <- count_status("interaction_expanded", "review")
  expanded_sensitivity <- count_status("interaction_expanded", "sensitivity_only")
  design_status <- if (expanded_sensitivity > 0L) {
    "sensitivity_only"
  } else if (expanded_review > 0L || baseline_review > 0L) {
    "review"
  } else {
    "ok"
  }

  warn_tbl <- as.data.frame(warnings %||% data.frame(), stringsAsFactors = FALSE)
  if (!all(c("Model", "Type") %in% names(warn_tbl))) {
    warn_tbl <- data.frame(Model = character(), Type = character(),
                           stringsAsFactors = FALSE)
  }
  expanded_lme4_rows <- sum(
    as.character(warn_tbl$Model) == "interaction_expanded" &
      as.character(warn_tbl$Type) %in% c("lme4_warning", "lme4_message"),
    na.rm = TRUE
  )
  baseline_lme4_rows <- sum(
    as.character(warn_tbl$Model) == "baseline_main_effects" &
      as.character(warn_tbl$Type) %in% c("lme4_warning", "lme4_message"),
    na.rm = TRUE
  )
  baseline_singular <- isTRUE(summary$BaselineSingular[1L])
  expanded_singular <- isTRUE(summary$ExpandedSingular[1L])
  fit_status <- if (expanded_singular) {
    "sensitivity_only"
  } else if (baseline_singular || expanded_lme4_rows > 0L ||
             baseline_lme4_rows > 0L) {
    "review"
  } else {
    "ok"
  }

  delta_g <- scalar_num(summary$DeltaG)
  delta_phi <- scalar_num(summary$DeltaPhi)
  finite_coef_deltas <- abs(c(delta_g, delta_phi))
  finite_coef_deltas <- finite_coef_deltas[is.finite(finite_coef_deltas)]
  max_coef_delta <- if (length(finite_coef_deltas) > 0L) {
    max(finite_coef_deltas)
  } else {
    NA_real_
  }
  coefficient_status <- if (is.finite(max_coef_delta) && max_coef_delta >= 0.05) {
    "review"
  } else if (is.finite(max_coef_delta) && max_coef_delta >= 0.02) {
    "info"
  } else {
    "ok"
  }

  variance_delta <- as.data.frame(variance_delta %||% data.frame(),
                                  stringsAsFactors = FALSE)
  if (!all(c("Source", "ComponentType", "ExpandedVariance",
             "DeltaVariance") %in% names(variance_delta))) {
    variance_delta <- data.frame(Source = character(),
                                 ComponentType = character(),
                                 ExpandedVariance = numeric(),
                                 DeltaVariance = numeric(),
                                 stringsAsFactors = FALSE)
  }
  component_type <- as.character(variance_delta$ComponentType)
  interaction_rows <- grepl("interaction", component_type, fixed = TRUE)
  expanded_interaction_variance <- sum(
    suppressWarnings(as.numeric(variance_delta$ExpandedVariance[interaction_rows])),
    na.rm = TRUE
  )
  zero_named_interactions <- sum(
    interaction_rows &
      abs(suppressWarnings(as.numeric(variance_delta$ExpandedVariance))) <=
        sqrt(.Machine$double.eps),
    na.rm = TRUE
  )
  residual_delta <- NA_real_
  if ("Residual" %in% as.character(variance_delta$Source)) {
    residual_delta <- scalar_num(
      variance_delta$DeltaVariance[as.character(variance_delta$Source) == "Residual"]
    )
  }
  variance_status <- if (zero_named_interactions > 0L) {
    "review"
  } else if ((is.finite(expanded_interaction_variance) &&
              expanded_interaction_variance > sqrt(.Machine$double.eps)) ||
             (is.finite(residual_delta) &&
              abs(residual_delta) > sqrt(.Machine$double.eps))) {
    "info"
  } else {
    "ok"
  }

  d_study <- as.data.frame(d_study %||% data.frame(), stringsAsFactors = FALSE)
  d_status <- "info"
  d_rows <- 0L
  max_d_g <- NA_real_
  max_d_phi <- NA_real_
  if (nrow(d_study) > 0L && "Model" %in% names(d_study)) {
    base_d <- d_study[as.character(d_study$Model) == "baseline_main_effects",
                       ,
                       drop = FALSE]
    expanded_d <- d_study[as.character(d_study$Model) == "interaction_expanded",
                          ,
                          drop = FALSE]
    key_cols <- grep("^n_", names(d_study), value = TRUE)
    if ("ResidualScaling" %in% names(d_study)) {
      key_cols <- c(key_cols, "ResidualScaling")
    }
    key_cols <- intersect(key_cols, intersect(names(base_d), names(expanded_d)))
    if (nrow(base_d) > 0L && nrow(expanded_d) > 0L && length(key_cols) > 0L) {
      merged_d <- merge(
        base_d,
        expanded_d,
        by = key_cols,
        suffixes = c(".baseline", ".expanded")
      )
      d_rows <- nrow(merged_d)
      if (d_rows > 0L && all(c("G.baseline", "G.expanded") %in% names(merged_d))) {
        d_g <- abs(suppressWarnings(as.numeric(merged_d$G.expanded)) -
                     suppressWarnings(as.numeric(merged_d$G.baseline)))
        d_g <- d_g[is.finite(d_g)]
        if (length(d_g) > 0L) max_d_g <- max(d_g)
      }
      if (d_rows > 0L && all(c("Phi.baseline", "Phi.expanded") %in% names(merged_d))) {
        d_phi <- abs(suppressWarnings(as.numeric(merged_d$Phi.expanded)) -
                       suppressWarnings(as.numeric(merged_d$Phi.baseline)))
        d_phi <- d_phi[is.finite(d_phi)]
        if (length(d_phi) > 0L) max_d_phi <- max(d_phi)
      }
    }
  }
  finite_d_deltas <- c(max_d_g, max_d_phi)
  finite_d_deltas <- finite_d_deltas[is.finite(finite_d_deltas)]
  max_d_delta <- if (length(finite_d_deltas) > 0L) {
    max(finite_d_deltas)
  } else {
    NA_real_
  }
  if (is.finite(max_d_delta) && max_d_delta >= 0.05) {
    d_status <- "review"
  } else if (is.finite(max_d_delta) && max_d_delta < 0.02) {
    d_status <- "ok"
  }

  rows <- list(
    make_row(
      "interaction_design_support",
      design_status,
      paste0(
        "expanded review=", expanded_review,
        "; expanded sensitivity_only=", expanded_sensitivity,
        "; expanded highest_order=", highest_status("interaction_expanded")
      ),
      "Observed crossing and replication determine how much weight to give the expanded interaction decomposition.",
      if (identical(design_status, "ok")) {
        "Proceed to coefficient and variance-movement review."
      } else {
        "Report the expanded model as sensitivity evidence unless additional design evidence supports the interaction terms."
      },
      "Design checks describe observed support; they are not variance-component estimates."
    ),
    make_row(
      "fit_stability",
      fit_status,
      paste0(
        "baseline singular=", baseline_singular,
        "; expanded singular=", expanded_singular,
        "; baseline lme4 rows=", baseline_lme4_rows,
        "; expanded lme4 rows=", expanded_lme4_rows
      ),
      "Singular fits and lme4 warnings are boundary evidence for the G-study refit, especially in interaction-expanded models.",
      if (identical(fit_status, "ok")) {
        "Keep singular-fit status beside the reported G-study table."
      } else {
        "Avoid presenting the expanded decomposition as a definitive variance partition."
      },
      "This reviews the observed-score G-study refit, not the upstream MFRM calibration."
    ),
    make_row(
      "coefficient_movement",
      coefficient_status,
      paste0("DeltaG=", fmt(delta_g), "; DeltaPhi=", fmt(delta_phi)),
      "Expanded-minus-baseline movement shows sensitivity of observed-score G/Phi to named interaction terms.",
      if (identical(coefficient_status, "review")) {
        "Explain the movement and read it together with design and fit-stability rows."
      } else {
        "Use as a magnitude summary after design support has been reviewed."
      },
      "The 0.02/0.05 bands are descriptive screening bands, not validity cutoffs."
    ),
    make_row(
      "variance_movement",
      variance_status,
      paste0(
        "expanded interaction variance=", fmt(expanded_interaction_variance),
        "; zero named interaction components=", zero_named_interactions,
        "; residual DeltaVariance=", fmt(residual_delta)
      ),
      "Variance movement shows where the expanded decomposition reallocates variance from residual or main effects.",
      if (zero_named_interactions > 0L) {
        "Treat zero named interaction variances as boundary evidence and avoid over-interpreting separated components."
      } else {
        "Use this row to describe variance movement, not model superiority."
      },
      "Component movement is descriptive sensitivity evidence under the declared random-effects scope."
    ),
    make_row(
      "dstudy_projection_movement",
      d_status,
      paste0(
        "matched design rows=", d_rows,
        "; max |DeltaG|=", fmt(max_d_g),
        "; max |DeltaPhi|=", fmt(max_d_phi)
      ),
      "D-study movement shows whether practical design recommendations change under the expanded decomposition.",
      if (identical(d_status, "review")) {
        "Compare recommended facet counts under the same residual-scaling assumption before changing the design claim."
      } else {
        "Use the overlay plot when planning decisions depend on projected G/Phi."
      },
      "Compare only rows with the same design grid and residual-scaling assumption."
    ),
    make_row(
      "reporting_boundary",
      "info",
      "G/Phi are observed-score G-theory coefficients; the comparison is not an automatic model-selection rule.",
      "The expanded model can clarify sensitivity to targeted interactions without replacing the main-effects baseline.",
      "Report the chosen decomposition, design support, fit-stability evidence, and any retained sensitivity-only status.",
      "Keep MFRM separation reliability, IRT reliability, and G-theory G/Phi in separate reporting lanes."
    )
  )
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrm_gt_comparison_design_checks <- function(baseline, expanded) {
  models <- list(
    baseline_main_effects = baseline,
    interaction_expanded = expanded
  )
  model_labels <- stats::setNames(
    mfrm_gt_model_label(names(models)),
    names(models)
  )
  add_model <- function(df, model, source_table) {
    df <- as.data.frame(df %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(df) == 0L) return(data.frame())
    data.frame(
      Model = model,
      ModelLabel = unname(model_labels[[model]]),
      SourceTable = source_table,
      df,
      stringsAsFactors = FALSE
    )
  }
  facet <- do.call(rbind, lapply(names(models), function(model) {
    check <- models[[model]]$design$design_check %||% NULL
    if (!inherits(check, "mfrm_generalizability_design_check")) return(data.frame())
    add_model(check$facet_overview, model, "facet_overview")
  }))
  interaction <- do.call(rbind, lapply(names(models), function(model) {
    check <- models[[model]]$design$design_check %||% NULL
    if (!inherits(check, "mfrm_generalizability_design_check")) return(data.frame())
    add_model(check$interaction_overview, model, "interaction_overview")
  }))
  highest <- do.call(rbind, lapply(names(models), function(model) {
    check <- models[[model]]$design$design_check %||% NULL
    if (!inherits(check, "mfrm_generalizability_design_check")) return(data.frame())
    add_model(check$highest_order_review, model, "highest_order_review")
  }))
  raw_overview <- do.call(rbind, lapply(names(models), function(model) {
    check <- models[[model]]$design$design_check %||% NULL
    if (!inherits(check, "mfrm_generalizability_design_check")) return(data.frame())
    add_model(check$overview, model, "overview")
  }))

  overview_rows <- list()
  if (nrow(facet) > 0L) {
    overview_rows[[length(overview_rows) + 1L]] <- data.frame(
      Model = facet$Model,
      ModelLabel = facet$ModelLabel,
      SourceTable = "facet_overview",
      Signal = facet$Facet,
      Status = facet$Status,
      MainConcern = ifelse(facet$Status == "ok", "none", "facet_level_review"),
      RecommendedAction = ifelse(
        facet$Status == "ok",
        "Facet level coverage is adequate for this descriptive design check.",
        "Review sparse or weakly represented facet levels before strong design claims."
      ),
      Metric = "Levels",
      Value = suppressWarnings(as.numeric(facet$Levels)),
      stringsAsFactors = FALSE
    )
  }
  if (nrow(interaction) > 0L) {
    interaction_value <- suppressWarnings(as.numeric(interaction$ReplicatedCellRate))
    interaction_value[!is.finite(interaction_value) &
                        interaction$Status == "not_requested"] <- 0
    overview_rows[[length(overview_rows) + 1L]] <- data.frame(
      Model = interaction$Model,
      ModelLabel = interaction$ModelLabel,
      SourceTable = "interaction_overview",
      Signal = interaction$Interaction,
      Status = interaction$Status,
      MainConcern = interaction$MainConcern,
      RecommendedAction = interaction$RecommendedAction,
      Metric = "ReplicatedCellRate",
      Value = interaction_value,
      stringsAsFactors = FALSE
    )
  }
  if (nrow(highest) > 0L) {
    overview_rows[[length(overview_rows) + 1L]] <- data.frame(
      Model = highest$Model,
      ModelLabel = highest$ModelLabel,
      SourceTable = "highest_order_review",
      Signal = highest$FullCellFacets,
      Status = highest$Status,
      MainConcern = highest$MainConcern,
      RecommendedAction = highest$RecommendedAction,
      Metric = "ReplicatedFullCellRate",
      Value = suppressWarnings(as.numeric(highest$ReplicatedFullCellRate)),
      stringsAsFactors = FALSE
    )
  }
  overview <- if (length(overview_rows) > 0L) {
    out <- do.call(rbind, overview_rows)
    row.names(out) <- NULL
    out
  } else {
    data.frame(
      Model = character(),
      ModelLabel = character(),
      SourceTable = character(),
      Signal = character(),
      Status = character(),
      MainConcern = character(),
      RecommendedAction = character(),
      Metric = character(),
      Value = numeric(),
      stringsAsFactors = FALSE
    )
  }

  list(
    overview = overview,
    overview_raw = raw_overview,
    facet_overview = facet,
    interaction_overview = interaction,
    highest_order_review = highest
  )
}

mfrm_gt_comparison_design_plot_table <- function(x,
                                                 design_check_type,
                                                 metric = NULL,
                                                 model = NULL,
                                                 status = NULL,
                                                 sort_by = c("status", "value", "name"),
                                                 decreasing = NULL,
                                                 top_n = Inf) {
  sort_by <- match.arg(sort_by)
  models <- list(
    baseline_main_effects = x$baseline,
    interaction_expanded = x$expanded
  )
  available_models <- names(models)
  if (is.null(model)) {
    keep_models <- available_models
  } else {
    keep_models <- as.character(model)
    keep_models <- keep_models[!is.na(keep_models) & nzchar(keep_models)]
    if (length(keep_models) == 0L) keep_models <- available_models
    missing <- setdiff(keep_models, available_models)
    if (length(missing) > 0L) {
      stop("`model` must use value(s) from: ",
           paste(available_models, collapse = ", "), ".", call. = FALSE)
    }
  }
  rows <- lapply(keep_models, function(model_name) {
    check <- models[[model_name]]$design$design_check %||% NULL
    if (!inherits(check, "mfrm_generalizability_design_check")) {
      return(data.frame())
    }
    tbl <- gtheory_design_check_table(
      x = check,
      type = design_check_type,
      metric = metric,
      status = status,
      sort_by = sort_by,
      decreasing = decreasing,
      top_n = top_n
    )
    data.frame(
      Model = model_name,
      ModelLabel = mfrm_gt_model_label(model_name),
      tbl,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  if (is.null(out) || nrow(out) == 0L) {
    stop("No finite comparison design-check rows are available for plotting.",
         call. = FALSE)
  }
  row.names(out) <- NULL
  out
}

mfrm_gt_comparison_warnings <- function(x, model) {
  rows <- data.frame(Model = character(0), Type = character(0),
                     Message = character(0), stringsAsFactors = FALSE)
  if (isTRUE(x$design$singular_fit)) {
    rows <- rbind(rows, data.frame(
      Model = model,
      Type = "singular_fit",
      Message = "lme4 reported a singular random-effects fit; variance components may be boundary estimates.",
      stringsAsFactors = FALSE
    ))
  }
  warning_messages <- as.character(x$design$lmer_warnings %||% character(0))
  if (length(warning_messages) > 0L) {
    rows <- rbind(rows, data.frame(
      Model = model,
      Type = "lme4_warning",
      Message = warning_messages,
      stringsAsFactors = FALSE
    ))
  }
  lmer_messages <- as.character(x$design$lmer_messages %||% character(0))
  if (length(lmer_messages) > 0L) {
    rows <- rbind(rows, data.frame(
      Model = model,
      Type = "lme4_message",
      Message = lmer_messages,
      stringsAsFactors = FALSE
    ))
  }
  design_check <- x$design$design_check %||% NULL
  if (inherits(design_check, "mfrm_generalizability_design_check")) {
    interaction_overview <- as.data.frame(
      design_check$interaction_overview %||% data.frame(),
      stringsAsFactors = FALSE
    )
    if (nrow(interaction_overview) > 0L &&
        all(c("Status", "Interaction", "MainConcern") %in%
            names(interaction_overview))) {
      flagged <- interaction_overview[
        interaction_overview$Status %in% c("review", "sensitivity_only"),
        ,
        drop = FALSE
      ]
      if (nrow(flagged) > 0L) {
        rows <- rbind(rows, data.frame(
          Model = model,
          Type = paste0("design_", flagged$Status),
          Message = paste0(
            "Design check flagged ", flagged$Interaction, " as ",
            flagged$Status, " (", flagged$MainConcern, ")."
          ),
          stringsAsFactors = FALSE
        ))
      }
    }
    highest_order <- as.data.frame(
      design_check$highest_order_review %||% data.frame(),
      stringsAsFactors = FALSE
    )
    if (nrow(highest_order) > 0L &&
        "Status" %in% names(highest_order) &&
        highest_order$Status[1] %in% c("review", "sensitivity_only")) {
      rows <- rbind(rows, data.frame(
        Model = model,
        Type = paste0("design_highest_order_", highest_order$Status[1]),
        Message = paste0(
          "Highest-order cell review is ", highest_order$Status[1],
          " (", highest_order$MainConcern[1],
          "); residual and highest-order interaction may remain difficult to separate."
        ),
        stringsAsFactors = FALSE
      ))
    }
  }
  rows
}

mfrm_gt_model_label <- function(model) {
  dplyr::case_when(
    model == "baseline_main_effects" ~ "Main effects",
    model == "interaction_expanded" ~ "Interaction-expanded",
    model == "expanded_minus_baseline" ~ "Expanded minus baseline",
    TRUE ~ as.character(model)
  )
}

mfrm_gt_validate_metric <- function(metric, available, default, arg_name = "metric") {
  if (is.null(metric)) metric <- default
  metric <- as.character(metric)
  metric <- metric[!is.na(metric) & nzchar(metric)]
  if (length(metric) == 0L) metric <- default
  missing <- setdiff(metric, available)
  if (length(missing) > 0L) {
    stop("`", arg_name, "` must use value(s) from: ",
         paste(available, collapse = ", "), ".", call. = FALSE)
  }
  metric
}

#' @rdname compare_mfrm_generalizability
#' @param x Output from [compare_mfrm_generalizability()] for the plot method.
#' @param y Reserved for S3 generic compatibility.
#' @param type Comparison plot route. `"coefficients"` compares baseline and
#'   expanded `G`/`Phi`; `"coefficient_delta"` shows expanded-minus-baseline
#'   movement; `"variance_delta"` shows source-level variance movement;
#'   `"d_study_overlay"` overlays projected D-study rows by model; and
#'   `"design_check"` compares the baseline and expanded design-check signals.
#' @param metric Metric(s) to display. Defaults to `G`/`Phi` for coefficient
#'   routes, `DeltaVariance` for variance movement, and `Phi` for D-study
#'   overlays.
#' @param model Optional model filter using values from the comparison tables,
#'   such as `"baseline_main_effects"` or `"interaction_expanded"`.
#' @param x_var Planned-count column for `type = "d_study_overlay"`.
#' @param group_var Optional grouping column for `type = "d_study_overlay"`.
#' @param panel_by Optional single small-multiple column for
#'   `type = "d_study_overlay"`.
#' @param design_check_type Route passed to each model's
#'   design-check plot table when `type = "design_check"`.
#' @param design_check_status Optional design-check status filter.
#' @param design_check_sort_by Design-check ordering rule.
#' @param design_check_decreasing Optional design-check ordering direction.
#' @param component_type Optional component-type filter for
#'   `type = "variance_delta"`.
#' @param sort_by Ordering rule for `type = "variance_delta"`:
#'   `"value"` (default), `"source"`, or `"none"`.
#' @param decreasing Logical. Whether `sort_by` uses decreasing order.
#' @param top_n Optional positive integer limiting displayed rows after
#'   filtering and sorting.
#' @param draw If `TRUE`, draw with base graphics. If `FALSE`, return an
#'   `mfrm_plot_data` object for custom graphics.
#' @param main Optional plot title.
#' @param palette Optional vector of colors for base graphics.
#' @param preset Plot style preset used by the base-graphics renderer.
#' @param ... Reserved for future extensions.
#' @export
plot.mfrm_generalizability_comparison <- function(x,
                                                  y = NULL,
                                                  type = c("coefficients", "coefficient_delta", "variance_delta", "d_study_overlay", "design_check"),
                                                  metric = NULL,
                                                  model = NULL,
                                                  x_var = NULL,
                                                  group_var = NULL,
                                                  panel_by = NULL,
                                                  design_check_type = c("interaction_cells", "highest_order", "facet_levels", "overview"),
                                                  design_check_status = NULL,
                                                  design_check_sort_by = c("status", "value", "name"),
                                                  design_check_decreasing = NULL,
                                                  component_type = NULL,
                                                  sort_by = c("value", "source", "none"),
                                                  decreasing = TRUE,
                                                  top_n = NULL,
                                                  draw = TRUE,
                                                  main = NULL,
                                                  palette = NULL,
                                                  preset = c("standard", "publication", "compact", "monochrome"),
                                                  ...) {
  if (!inherits(x, "mfrm_generalizability_comparison")) {
    stop("`x` must be output from compare_mfrm_generalizability().", call. = FALSE)
  }
  type <- match.arg(type)
  design_check_type <- match.arg(design_check_type)
  design_check_sort_by <- match.arg(design_check_sort_by)
  sort_by <- match.arg(sort_by)
  style <- resolve_plot_preset(preset)
  reading_order <- gtheory_comparison_reading_order()
  interpretation_note <- gtheory_interpretation_note()
  validate_model <- function(model, available, default = available) {
    if (is.null(model)) model <- default
    model <- as.character(model)
    model <- model[!is.na(model) & nzchar(model)]
    if (length(model) == 0L) model <- default
    missing <- setdiff(model, available)
    if (length(missing) > 0L) {
      stop("`model` must use value(s) from: ",
           paste(available, collapse = ", "), ".", call. = FALSE)
    }
    model
  }

  if (identical(type, "design_check")) {
    metric <- metric %||% gtheory_design_check_default_metric(design_check_type)
    if (length(metric) != 1L) {
      stop("`type = \"design_check\"` requires exactly one `metric`.",
           call. = FALSE)
    }
    plot_tbl <- mfrm_gt_comparison_design_plot_table(
      x = x,
      design_check_type = design_check_type,
      metric = metric,
      model = model,
      status = design_check_status,
      sort_by = design_check_sort_by,
      decreasing = design_check_decreasing,
      top_n = top_n %||% Inf
    )
    metric <- plot_tbl$Metric[1]
    metric_label <- plot_tbl$MetricLabel[1]
    status_cols <- resolve_palette(
      palette,
      defaults = gtheory_design_check_status_colors(style)
    )
    plot_tbl$Color <- unname(status_cols[plot_tbl$Status])
    plot_tbl$Color[is.na(plot_tbl$Color)] <- style$neutral
    value_scale <- if (grepl("Rate|Density", metric)) "proportion" else "count"
    if (isTRUE(draw)) {
      apply_plot_preset(style)
      values <- plot_tbl$Value
      labels <- paste(plot_tbl$ModelLabel, plot_tbl$PlotGroup, sep = ": ")
      labels <- truncate_axis_label(labels, width = 38L)
      xlim <- range(c(0, values), finite = TRUE)
      if (!all(is.finite(xlim)) || diff(xlim) <= 0) xlim <- c(0, 1)
      if (identical(value_scale, "proportion")) xlim <- c(0, 1)
      old_mar <- graphics::par("mar")
      on.exit(graphics::par(mar = old_mar), add = TRUE)
      graphics::par(mar = c(5, 13, 4, 2))
      graphics::barplot(
        height = rev(values),
        names.arg = rev(labels),
        horiz = TRUE,
        las = 1,
        col = rev(plot_tbl$Color),
        border = NA,
        xlim = xlim,
        xlab = metric_label,
        main = main %||% "G-study design-check sensitivity comparison"
      )
      graphics::grid(nx = NULL, ny = NA, col = style$grid)
      if (identical(value_scale, "proportion")) {
        graphics::abline(v = 0.5, lty = 2,
                         col = grDevices::adjustcolor(style$neutral, alpha.f = 0.7))
      }
      graphics::legend(
        "bottomright",
        legend = names(status_cols),
        fill = unname(status_cols),
        border = NA,
        bty = "n",
        cex = 0.76
      )
    }
    return(invisible(new_mfrm_plot_data(
      "generalizability_comparison",
      list(
        plot = type,
        design_check_type = design_check_type,
        plot_table = plot_tbl,
        design_checks = x$design_checks %||% mfrm_gt_comparison_design_checks(x$baseline, x$expanded),
        coefficients = as.data.frame(x$coefficients %||% data.frame(), stringsAsFactors = FALSE),
        variance_delta = as.data.frame(x$variance_delta %||% data.frame(), stringsAsFactors = FALSE),
        d_study = as.data.frame(x$d_study %||% data.frame(), stringsAsFactors = FALSE),
        comparison_review = as.data.frame(x$comparison_review %||% data.frame(),
                                          stringsAsFactors = FALSE),
        warnings = as.data.frame(x$warnings %||% data.frame(), stringsAsFactors = FALSE),
        metric_family = "G-theory",
        metric = metric,
        metric_label = metric_label,
        value_col = "Value",
        value_scale = value_scale,
        title = main %||% "G-study design-check sensitivity comparison",
        subtitle = "Baseline main-effects design check versus interaction-expanded design check",
        filters = list(
          model = model,
          status = design_check_status,
          sort_by = design_check_sort_by,
          decreasing = design_check_decreasing,
          top_n = top_n
        ),
        reading_order = reading_order,
        guidance = gtheory_comparison_guidance(type),
        figure_recipes = gtheory_comparison_figure_recipes(type, metric = metric),
        interpretation_note = paste(
          "Design-check comparison summarizes observed crossing and replication.",
          "It does not estimate variance components or choose the reporting model."
        ),
        legend = new_plot_legend(
          label = names(status_cols),
          role = rep("design_status", length(status_cols)),
          aesthetic = rep("fill", length(status_cols)),
          value = unname(status_cols)
        ),
        reference_lines = if (identical(value_scale, "proportion")) {
          new_reference_lines(
            axis = "x",
            value = 0.5,
            label = "0.50 review reference",
            linetype = "dashed",
            role = "design_reference"
          )
        } else {
          new_reference_lines()
        },
        preset = style$name
      )
    )))
  }

  if (type %in% c("coefficients", "coefficient_delta")) {
    coefs <- as.data.frame(x$coefficients %||% data.frame(), stringsAsFactors = FALSE)
    if (!"Model" %in% names(coefs)) {
      stop("Comparison coefficients are missing the `Model` column.", call. = FALSE)
    }
    available_metrics <- setdiff(names(coefs), "Model")
    numeric_metrics <- available_metrics[vapply(coefs[available_metrics], function(col) {
      any(is.finite(suppressWarnings(as.numeric(col))))
    }, logical(1))]
    metric <- mfrm_gt_validate_metric(
      metric,
      available = numeric_metrics,
      default = intersect(c("G", "Phi"), numeric_metrics)
    )
    default_models <- if (identical(type, "coefficients")) {
      intersect(c("baseline_main_effects", "interaction_expanded"), unique(coefs$Model))
    } else {
      intersect("expanded_minus_baseline", unique(coefs$Model))
    }
    keep_models <- validate_model(model, unique(as.character(coefs$Model)), default = default_models)
    coefs <- coefs[as.character(coefs$Model) %in% keep_models, , drop = FALSE]
    plot_tbl <- do.call(rbind, lapply(metric, function(metric_name) {
      data.frame(
        Model = as.character(coefs$Model),
        ModelLabel = mfrm_gt_model_label(as.character(coefs$Model)),
        Metric = metric_name,
        MetricFamily = "G-theory",
        Value = suppressWarnings(as.numeric(coefs[[metric_name]])),
        stringsAsFactors = FALSE
      )
    }))
    plot_tbl <- plot_tbl[is.finite(plot_tbl$Value), , drop = FALSE]
    if (nrow(plot_tbl) == 0L) {
      stop("No finite comparison coefficient values are available for plotting.", call. = FALSE)
    }
    if (identical(type, "coefficients")) {
      plot_tbl$Status <- gtheory_coefficient_status(plot_tbl$Value)
    }
    series_levels <- unique(plot_tbl$ModelLabel)
    bar_cols <- if (is.null(palette)) {
      base_cols <- c(
        "Main effects" = style$accent_primary,
        "Interaction-expanded" = style$accent_secondary,
        "Expanded minus baseline" = style$accent_tertiary
      )
      unname(base_cols[series_levels] %||% rep(style$accent_primary, length(series_levels)))
    } else {
      rep(as.character(palette), length.out = length(series_levels))
    }
    if (isTRUE(draw)) {
      apply_plot_preset(style)
      old_par <- graphics::par(no.readonly = TRUE)
      on.exit(graphics::par(old_par), add = TRUE)
      value_matrix <- tapply(plot_tbl$Value, list(plot_tbl$ModelLabel, plot_tbl$Metric), mean, na.rm = TRUE)
      if (identical(type, "coefficients")) {
        graphics::barplot(
          value_matrix,
          beside = TRUE,
          col = bar_cols,
          border = NA,
          ylim = c(0, 1),
          ylab = "Coefficient",
          main = main %||% "G-study coefficient sensitivity comparison",
          legend.text = rownames(value_matrix),
          args.legend = list(bty = "n", cex = 0.75, x = "bottomright")
        )
        graphics::grid(nx = NA, ny = NULL, col = style$grid)
        graphics::abline(h = c(0.70, 0.80), col = grDevices::adjustcolor(style$neutral, alpha.f = 0.6), lty = c(3, 2))
      } else {
        vals <- plot_tbl$Value
        x_lim <- range(c(0, vals), na.rm = TRUE)
        pad <- diff(x_lim) * 0.08
        if (!is.finite(pad) || pad == 0) pad <- max(0.01, abs(x_lim[1]) * 0.08)
        graphics::barplot(
          vals,
          names.arg = plot_tbl$Metric,
          horiz = TRUE,
          col = ifelse(vals >= 0, style$accent_tertiary, style$warn),
          border = NA,
          xlim = x_lim + c(-pad, pad),
          xlab = "Expanded minus baseline",
          main = main %||% "G-study coefficient delta"
        )
        graphics::abline(v = 0, col = style$neutral, lty = 2)
        graphics::grid(nx = NULL, ny = NA, col = style$grid)
      }
    }
    return(invisible(new_mfrm_plot_data(
      "generalizability_comparison",
      list(
        plot = type,
        plot_table = plot_tbl,
        coefficients = as.data.frame(x$coefficients %||% data.frame(), stringsAsFactors = FALSE),
        variance_delta = as.data.frame(x$variance_delta %||% data.frame(), stringsAsFactors = FALSE),
        d_study = as.data.frame(x$d_study %||% data.frame(), stringsAsFactors = FALSE),
        design_checks = x$design_checks %||% mfrm_gt_comparison_design_checks(x$baseline, x$expanded),
        comparison_review = as.data.frame(x$comparison_review %||% data.frame(),
                                          stringsAsFactors = FALSE),
        warnings = as.data.frame(x$warnings %||% data.frame(), stringsAsFactors = FALSE),
        metric_family = "G-theory",
        metric = metric,
        value_col = "Value",
        title = main %||% if (identical(type, "coefficients")) {
          "G-study coefficient sensitivity comparison"
        } else {
          "G-study coefficient delta"
        },
        subtitle = "Main-effects baseline versus interaction-expanded sensitivity model",
        reading_order = reading_order,
        guidance = gtheory_comparison_guidance(type),
        figure_recipes = gtheory_comparison_figure_recipes(type, metric = metric),
        interpretation_note = interpretation_note,
        legend = new_plot_legend(
          label = series_levels,
          role = rep("model", length(series_levels)),
          aesthetic = rep("fill", length(series_levels)),
          value = bar_cols
        ),
        reference_lines = if (identical(type, "coefficients")) {
          new_reference_lines(
            axis = rep("y", 2L),
            value = c(0.70, 0.80),
            label = c("routine", "high_stakes"),
            linetype = c("dotted", "dashed"),
            role = rep("decision_band", 2L)
          )
        } else {
          new_reference_lines(axis = "x", value = 0, label = "no_change",
                              linetype = "dashed", role = "zero_delta")
        },
        preset = style$name
      )
    )))
  }

  if (identical(type, "variance_delta")) {
    variance_delta <- as.data.frame(x$variance_delta %||% data.frame(), stringsAsFactors = FALSE)
    required <- c("Source", "ComponentType", "BaselineVariance",
                  "ExpandedVariance", "DeltaVariance")
    if (!all(required %in% names(variance_delta))) {
      stop("Comparison variance deltas are missing required columns.", call. = FALSE)
    }
    metric <- mfrm_gt_validate_metric(
      metric,
      available = c("DeltaVariance", "BaselineVariance", "ExpandedVariance"),
      default = "DeltaVariance"
    )
    if (length(metric) != 1L) {
      stop("`type = \"variance_delta\"` requires exactly one `metric`.", call. = FALSE)
    }
    variance_delta$Value <- suppressWarnings(as.numeric(variance_delta[[metric]]))
    variance_delta <- variance_delta[is.finite(variance_delta$Value), , drop = FALSE]
    plot_tbl <- gtheory_filter_variance_components(
      variance_delta,
      component_type = component_type,
      decision_role = NULL,
      sort_by = sort_by,
      decreasing = decreasing,
      top_n = top_n,
      value_col = "Value"
    )
    if (nrow(plot_tbl) == 0L) {
      stop("No finite variance deltas are available for plotting.", call. = FALSE)
    }
    plot_tbl$MetricFamily <- "G-theory"
    plot_tbl$Metric <- metric
    plot_tbl$MetricRole <- "variance_movement"
    bar_cols <- if (is.null(palette)) {
      ifelse(plot_tbl$Value >= 0, style$accent_tertiary, style$warn)
    } else {
      rep(as.character(palette), length.out = nrow(plot_tbl))
    }
    if (isTRUE(draw)) {
      apply_plot_preset(style)
      old_par <- graphics::par(no.readonly = TRUE)
      on.exit(graphics::par(old_par), add = TRUE)
      vals <- plot_tbl$Value
      x_lim <- range(c(0, vals), na.rm = TRUE)
      pad <- diff(x_lim) * 0.08
      if (!is.finite(pad) || pad == 0) pad <- max(1e-6, abs(x_lim[1]) * 0.08)
      graphics::barplot(
        vals,
        names.arg = truncate_axis_label(plot_tbl$Source, width = 24L),
        horiz = TRUE,
        las = 1,
        col = bar_cols,
        border = NA,
        xlim = x_lim + c(-pad, pad),
        xlab = metric,
        main = main %||% "G-study variance movement"
      )
      graphics::abline(v = 0, col = style$neutral, lty = 2)
      graphics::grid(nx = NULL, ny = NA, col = style$grid)
    }
    return(invisible(new_mfrm_plot_data(
      "generalizability_comparison",
      list(
        plot = type,
        plot_table = plot_tbl,
        variance_delta = variance_delta,
        coefficients = as.data.frame(x$coefficients %||% data.frame(), stringsAsFactors = FALSE),
        d_study = as.data.frame(x$d_study %||% data.frame(), stringsAsFactors = FALSE),
        design_checks = x$design_checks %||% mfrm_gt_comparison_design_checks(x$baseline, x$expanded),
        comparison_review = as.data.frame(x$comparison_review %||% data.frame(),
                                          stringsAsFactors = FALSE),
        warnings = as.data.frame(x$warnings %||% data.frame(), stringsAsFactors = FALSE),
        metric_family = "G-theory",
        metric = metric,
        value_col = "Value",
        title = main %||% "G-study variance movement",
        subtitle = "Expanded minus baseline variance-component comparison",
        filters = list(
          component_type = component_type,
          sort_by = sort_by,
          decreasing = isTRUE(decreasing),
          top_n = top_n
        ),
        reading_order = reading_order,
        guidance = gtheory_comparison_guidance(type),
        figure_recipes = gtheory_comparison_figure_recipes(type, metric = metric),
        interpretation_note = interpretation_note,
        legend = new_plot_legend(
          label = plot_tbl$Source,
          role = rep("variance_component", nrow(plot_tbl)),
          aesthetic = rep("fill", nrow(plot_tbl)),
          value = bar_cols
        ),
        reference_lines = new_reference_lines(
          axis = "x",
          value = 0,
          label = "no_change",
          linetype = "dashed",
          role = "zero_delta"
        ),
        preset = style$name
      )
    )))
  }

  d_study <- as.data.frame(x$d_study %||% data.frame(), stringsAsFactors = FALSE)
  n_cols <- grep("^n_", names(d_study), value = TRUE)
  if (length(n_cols) == 0L) {
    stop("Comparison D-study table does not contain planned-count columns.", call. = FALSE)
  }
  if (is.null(x_var)) x_var <- n_cols[1L]
  x_var <- as.character(x_var[1L])
  if (!x_var %in% n_cols) {
    stop("`x_var` must be one of: ", paste(n_cols, collapse = ", "), call. = FALSE)
  }
  if (!"Model" %in% names(d_study)) {
    stop("Comparison D-study table is missing the `Model` column.", call. = FALSE)
  }
  keep_models <- validate_model(
    model,
    available = unique(as.character(d_study$Model)),
    default = intersect(c("baseline_main_effects", "interaction_expanded"),
                        unique(as.character(d_study$Model)))
  )
  d_study <- d_study[as.character(d_study$Model) %in% keep_models, , drop = FALSE]
  metric <- mfrm_gt_validate_metric(
    metric,
    available = intersect(c("G", "Phi", "RelativeErrorVariance", "AbsoluteErrorVariance"),
                          names(d_study)),
    default = "Phi"
  )
  plot_vars <- c(names(d_study), "Metric", "MetricFamily", "MetricRole",
                 "ModelLabel", "Series", "Panel")
  validate_plot_var <- function(value, arg_name) {
    if (is.null(value)) return(NULL)
    value <- as.character(value[1L])
    if (is.na(value) || !nzchar(value)) return(NULL)
    if (!value %in% plot_vars) {
      stop("`", arg_name, "` must use a column from the D-study overlay data: ",
           paste(plot_vars, collapse = ", "), ".", call. = FALSE)
    }
    value
  }
  if (is.null(group_var) && "ResidualScaling" %in% names(d_study) &&
      dplyr::n_distinct(d_study$ResidualScaling) > 1L) {
    group_var <- "ResidualScaling"
  }
  if (is.null(panel_by) && length(metric) > 1L) {
    panel_by <- "Metric"
  }
  group_var <- validate_plot_var(group_var, "group_var")
  panel_by <- validate_plot_var(panel_by, "panel_by")

  series_tbl <- do.call(rbind, lapply(metric, function(metric_name) {
    tmp <- d_study
    tmp$Metric <- metric_name
    tmp$MetricFamily <- "G-theory"
    tmp$MetricRole <- dplyr::case_when(
      metric_name == "G" ~ "relative_decision",
      metric_name == "Phi" ~ "absolute_decision",
      metric_name == "RelativeErrorVariance" ~ "relative_error",
      metric_name == "AbsoluteErrorVariance" ~ "absolute_error",
      TRUE ~ "projection"
    )
    tmp$ModelLabel <- mfrm_gt_model_label(as.character(tmp$Model))
    tmp$X <- suppressWarnings(as.numeric(tmp[[x_var]]))
    tmp$Value <- suppressWarnings(as.numeric(tmp[[metric_name]]))
    tmp
  }))
  series_tbl <- series_tbl[is.finite(series_tbl$X) & is.finite(series_tbl$Value), , drop = FALSE]
  if (nrow(series_tbl) == 0L) {
    stop("No finite D-study overlay values are available for plotting.", call. = FALSE)
  }
  group_components <- unique(c("ModelLabel", group_var))
  group_components <- group_components[!is.na(group_components) & nzchar(group_components)]
  if (length(metric) > 1L && !identical(panel_by, "Metric")) {
    group_components <- unique(c(group_components, "Metric"))
  }
  series_tbl$Series <- do.call(paste, c(series_tbl[, group_components, drop = FALSE], sep = " / "))
  if (!is.null(panel_by)) {
    series_tbl$Panel <- as.character(series_tbl[[panel_by]])
  } else {
    series_tbl$Panel <- "All designs"
  }
  series_levels <- unique(series_tbl$Series)
  if (is.null(palette)) {
    series_cols <- stats::setNames(
      grDevices::hcl.colors(max(3L, length(series_levels)), palette = "Dark 3")[seq_along(series_levels)],
      series_levels
    )
  } else {
    series_cols <- stats::setNames(rep(as.character(palette), length.out = length(series_levels)),
                                   series_levels)
  }
  line_types <- stats::setNames(rep(seq_len(6L), length.out = length(series_levels)), series_levels)
  if (isTRUE(draw)) {
    apply_plot_preset(style)
    old_par <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(old_par), add = TRUE)
    panel_levels <- unique(series_tbl$Panel)
    graphics::par(mfrow = grDevices::n2mfrow(length(panel_levels)))
    y_lim <- if (all(metric %in% c("G", "Phi"))) c(0, 1) else range(c(0, series_tbl$Value), na.rm = TRUE)
    for (panel in panel_levels) {
      s_panel <- series_tbl[series_tbl$Panel == panel, , drop = FALSE]
      graphics::plot(
        s_panel$X,
        s_panel$Value,
        type = "n",
        xlab = x_var,
        ylab = if (all(metric %in% c("G", "Phi"))) "Coefficient" else "Error variance",
        ylim = y_lim,
        main = main %||% panel
      )
      graphics::grid(col = style$grid)
      for (series in unique(s_panel$Series)) {
        s <- s_panel[s_panel$Series == series, , drop = FALSE]
        s <- s[order(s$X), , drop = FALSE]
        graphics::lines(s$X, s$Value, col = series_cols[series], lty = line_types[series], lwd = 2)
        graphics::points(s$X, s$Value, col = series_cols[series], pch = 16)
      }
      if (all(metric %in% c("G", "Phi"))) {
        graphics::abline(h = c(0.70, 0.80), col = grDevices::adjustcolor(style$neutral, alpha.f = 0.6), lty = c(3, 2))
      }
      graphics::legend(
        "bottomright",
        legend = unique(s_panel$Series),
        col = unname(series_cols[unique(s_panel$Series)]),
        lty = unname(line_types[unique(s_panel$Series)]),
        pch = 16,
        bty = "n",
        cex = 0.72
      )
    }
  }
  invisible(new_mfrm_plot_data(
    "generalizability_comparison",
    list(
      plot = type,
      plot_table = series_tbl,
      series = series_tbl,
      d_study = d_study,
      coefficients = as.data.frame(x$coefficients %||% data.frame(), stringsAsFactors = FALSE),
      variance_delta = as.data.frame(x$variance_delta %||% data.frame(), stringsAsFactors = FALSE),
      design_checks = x$design_checks %||% mfrm_gt_comparison_design_checks(x$baseline, x$expanded),
      comparison_review = as.data.frame(x$comparison_review %||% data.frame(),
                                        stringsAsFactors = FALSE),
      warnings = as.data.frame(x$warnings %||% data.frame(), stringsAsFactors = FALSE),
      metric_family = "G-theory",
      metric = metric,
      value_col = "Value",
      x_var = x_var,
      group_var = group_var %||% NA_character_,
      panel_by = panel_by %||% NA_character_,
      title = main %||% "D-study sensitivity overlay",
      subtitle = "Projected design rows from baseline and interaction-expanded G-studies",
      reading_order = reading_order,
      guidance = gtheory_comparison_guidance(type),
      figure_recipes = gtheory_comparison_figure_recipes(
        type,
        metric = metric,
        x_var = x_var,
        group_var = group_var,
        panel_by = panel_by
      ),
      interpretation_note = interpretation_note,
      legend = new_plot_legend(
        label = series_levels,
        role = rep("series", length(series_levels)),
        aesthetic = rep("line", length(series_levels)),
        value = unname(series_cols[series_levels])
      ),
      reference_lines = if (all(metric %in% c("G", "Phi"))) {
        new_reference_lines(
          axis = rep("y", 2L),
          value = c(0.70, 0.80),
          label = c("routine", "high_stakes"),
          linetype = c("dotted", "dashed"),
          role = rep("decision_band", 2L)
        )
      } else {
        new_reference_lines()
      },
      preset = style$name
    )
  ))
}

#' @export
print.mfrm_d_study <- function(x, ...) {
  cat("mfrmr D-study projection\n")
  cat("  Object of measurement:", attr(x, "object_facet") %||% NA_character_, "\n")
  cat("  Random facets:", paste(attr(x, "random_facets") %||% character(0), collapse = ", "), "\n\n")
  interactions <- attr(x, "random_interactions") %||% character(0)
  if (length(interactions) > 0L) {
    cat("  Random interactions:", paste(interactions, collapse = ", "), "\n")
  }
  cat("  Residual scaling:", attr(x, "residual_scaling") %||% paste(unique(x$ResidualScaling), collapse = ", "), "\n\n")
  runtime <- attr(x, "runtime", exact = TRUE)
  if (is.data.frame(runtime) && nrow(runtime) > 0L) {
    cat(sprintf("  Projection elapsed: %.3f sec\n\n",
                suppressWarnings(as.numeric(runtime$ProjectionElapsedSec[1] %||% NA_real_))))
  }
  print.data.frame(x, row.names = FALSE, ...)
  invisible(x)
}

gtheory_plot_arg <- function(value) {
  if (is.null(value) || length(value) == 0L || all(is.na(value))) {
    return("NULL")
  }
  if (length(value) > 1L) {
    return(paste0("c(", paste(vapply(value, gtheory_plot_arg, character(1)), collapse = ", "), ")"))
  }
  value <- value[1L]
  if (is.numeric(value) || is.integer(value)) {
    return(format(value, trim = TRUE, scientific = FALSE))
  }
  paste0("\"", gsub("\"", "\\\\\"", as.character(value), fixed = TRUE), "\"")
}

gtheory_coefficient_status <- function(value) {
  value <- suppressWarnings(as.numeric(value))
  out <- rep("review", length(value))
  out[!is.finite(value)] <- "unavailable"
  out[is.finite(value) & value >= 0.70] <- "routine_candidate"
  out[is.finite(value) & value >= 0.80] <- "high_stakes_candidate"
  out
}

gtheory_interpretation_note <- function() {
  paste(
    "G-study and D-study plots summarize observed-score generalizability-theory planning evidence from the declared variance-component decomposition.",
    "Do not interpret G or Phi as coefficient alpha, omega, KR-20, MFRM separation reliability, IRT marginal reliability, or definitive evidence that unsupported higher-order interactions were separately estimated."
  )
}

gtheory_generalizability_reading_order <- function() {
  data.frame(
    Step = seq_len(5L),
    Route = c("design_check", "variance_components", "coefficients", "d_study", "table"),
    WhatToPlot = c(
      "plot(x, type = \"design_check\", draw = FALSE)",
      "plot(x, type = \"variance_components\", draw = FALSE)",
      "plot(x, type = \"coefficients\", draw = FALSE)",
      "mfrm_d_study(x, design_grid) |> plot(draw = FALSE)",
      "x$design$design_check; x$variance_components; x$coefficients"
    ),
    Purpose = c(
      "Start with observed crossing, cell replication, and highest-order residual confounding before interpreting expanded interaction components.",
      "Start with where observed score variance is concentrated across object, facet, and residual sources.",
      "Then read G for relative decisions and Phi for absolute decisions against the 0.70/0.80 reporting bands, separately from MFRM separation reliability.",
      "Use D-study projections before changing the number of raters, tasks, criteria, or other measurement facets.",
      "Report the declared model scope and residual/error limitations alongside any visual."
    ),
    stringsAsFactors = FALSE
  )
}

gtheory_generalizability_guidance <- function(type) {
  switch(
    type,
    design_check = c(
      "Read the design check before interpreting interaction-expanded variance components.",
      "Review and sensitivity-only signals describe observed crossing and replication, not fitted variance components.",
      "Highest-order cells with no exact replication mean residual and highest-order interaction remain difficult to separate."
    ),
    variance_components = c(
      "Read variance components before interpreting G or Phi.",
      "Large non-person facet shares indicate systematic condition effects; large residual share indicates unmodeled interaction/error.",
      "Use this as an observed-data decomposition, and check the declared model scope before interpreting interaction terms."
    ),
    coefficients = c(
      "Read G as relative-decision dependability and Phi as absolute-decision dependability.",
      "Keep these observed-score G-theory coefficients separate from fitted-logit MFRM separation reliability.",
      "Use 0.70 and 0.80 as reporting bands, not automatic validity thresholds.",
      "Move to mfrm_d_study() when the question is how many raters, items, criteria, or tasks are needed."
    )
  )
}

gtheory_generalizability_figure_recipes <- function(type) {
  data.frame(
    FigureID = c("gstudy_design_check", "gstudy_variance_components",
                 "gstudy_coefficients", "dstudy_projection"),
    RecommendedUse = c(
      "First figure when named random interactions are requested or the design may be sparse.",
      "First G-study figure in a measurement-design appendix.",
      "Short observed-score dependability summary after the variance-component display.",
      "Planning figure after candidate facet counts have been proposed."
    ),
    PlotCall = c(
      "plot(x, type = \"design_check\", draw = FALSE)",
      "plot(x, type = \"variance_components\", draw = FALSE)",
      "plot(x, type = \"coefficients\", draw = FALSE)",
      "plot(mfrm_d_study(x, design_grid, residual_scaling = \"sensitivity\"), draw = FALSE)"
    ),
    PlotType = c("design_check", "variance_components", "coefficients", "d_study"),
    Metric = c("ReplicatedCellRate", "ProportionVariance", "G/Phi", "G/Phi"),
    SelectedRoute = c("design_check", "variance_components", "coefficients", "d_study") == type,
    CaptionBoundary = c(
      "Describe observed crossing and replication; do not present this as a variance component.",
      "Describe the declared G-study variance decomposition and model scope.",
      "Name G as relative and Phi as absolute G-theory dependability, not MFRM separation reliability.",
      "Report residual-scaling assumptions when projecting planned designs."
    ),
    PlotDataContract = rep("mfrm_plot_data", 4L),
    stringsAsFactors = FALSE
  )
}

gtheory_comparison_reading_order <- function() {
  data.frame(
    Step = seq_len(6L),
    Route = c(
      "design_check",
      "coefficients",
      "coefficient_delta",
      "variance_delta",
      "d_study_overlay",
      "table"
    ),
    WhatToPlot = c(
      "plot(x, type = \"design_check\", draw = FALSE)",
      "plot(x, type = \"coefficients\", draw = FALSE)",
      "plot(x, type = \"coefficient_delta\", draw = FALSE)",
      "plot(x, type = \"variance_delta\", draw = FALSE)",
      "plot(x, type = \"d_study_overlay\", metric = \"Phi\", draw = FALSE)",
      "x$summary; x$comparison_review; x$design_checks; x$variance_delta; x$warnings"
    ),
    Purpose = c(
      "Start by checking whether the requested interaction-expanded decomposition has observed design support.",
      "Then compare baseline and interaction-expanded G/Phi side by side.",
      "Then inspect whether the coefficient movement is practically meaningful.",
      "Use the variance-delta route to see which variance moved out of residual into named components.",
      "Use the D-study overlay when the question is whether design recommendations change.",
      "Keep singular-fit and warning evidence next to every visual interpretation."
    ),
    stringsAsFactors = FALSE
  )
}

gtheory_comparison_guidance <- function(type) {
  switch(
    type,
    design_check = c(
      "Use this before interpreting coefficient or variance movement.",
      "Baseline rows usually show the main-effects residual convention; expanded rows show the requested interaction design support.",
      "Review or sensitivity-only signals mean the expanded model should remain sensitivity evidence unless additional design evidence supports it."
    ),
    coefficients = c(
      "Use this after reviewing design support and comparison-review checkpoints.",
      "Compare only like-with-like G-theory coefficients; these are not MFRM separation reliability.",
      "If the expanded model is singular, treat side-by-side differences as sensitivity evidence."
    ),
    coefficient_delta = c(
      "Use coefficient deltas to summarize direction and magnitude of movement from baseline to expanded model.",
      "Small deltas with boundary or singular evidence usually support retaining the main-effects baseline.",
      "Do not read a positive delta as automatic evidence that the expanded model is the better reporting model."
    ),
    variance_delta = c(
      "Use variance deltas to identify which named interaction components absorb variance from Residual or other terms.",
      "Component-level movement is descriptive sensitivity evidence, not a definitive higher-order variance partition.",
      "Pair this route with the singular-fit and lme4 warning table."
    ),
    d_study_overlay = c(
      "Use this when the practical question is whether planned rater/task/criterion counts change.",
      "Compare baseline and expanded projections under the same residual-scaling assumption.",
      "Facet or group by ResidualScaling when sensitivity output is present."
    )
  )
}

gtheory_comparison_figure_recipes <- function(type, metric, x_var = NULL,
                                              group_var = NULL,
                                              panel_by = NULL) {
  coefficient_metric <- if (identical(type, "design_check")) {
    c("G", "Phi")
  } else {
    metric %||% c("G", "Phi")
  }
  d_study_metric <- if (identical(type, "design_check")) {
    "Phi"
  } else {
    metric %||% "Phi"
  }
  metric_call <- gtheory_plot_arg(coefficient_metric)
  d_study_metric_call <- gtheory_plot_arg(d_study_metric)
  x_call <- gtheory_plot_arg(x_var)
  group_call <- gtheory_plot_arg(group_var)
  panel_call <- gtheory_plot_arg(panel_by)
  data.frame(
    FigureID = c(
      "gstudy_comparison_design_check",
      "gstudy_comparison_coefficients",
      "gstudy_comparison_coefficient_delta",
      "gstudy_comparison_variance_delta",
      "gstudy_comparison_d_study_overlay"
    ),
    RecommendedUse = c(
      "First figure when deciding how much weight to give the expanded interaction model.",
      "Coefficient figure after design support and comparison-review checkpoints.",
      "Compact follow-up when coefficient movement is the message.",
      "Review figure showing where variance moved when interactions were named.",
      "Design-planning figure showing whether D-study recommendations change."
    ),
    PlotCall = c(
      "plot(x, type = \"design_check\", draw = FALSE)",
      paste0("plot(x, type = \"coefficients\", metric = ", metric_call, ", draw = FALSE)"),
      paste0("plot(x, type = \"coefficient_delta\", metric = ", metric_call, ", draw = FALSE)"),
      "plot(x, type = \"variance_delta\", draw = FALSE)",
      paste0("plot(x, type = \"d_study_overlay\", metric = ", d_study_metric_call,
             ", x_var = ", x_call, ", group_var = ", group_call,
             ", panel_by = ", panel_call, ", draw = FALSE)")
    ),
    PlotType = c("design_check", "coefficients", "coefficient_delta", "variance_delta", "d_study_overlay"),
    Metric = c(
      "ReplicatedCellRate",
      paste(coefficient_metric, collapse = "/"),
      paste(coefficient_metric, collapse = "/"),
      "DeltaVariance",
      paste(d_study_metric, collapse = "/")
    ),
    SelectedRoute = c("design_check", "coefficients", "coefficient_delta", "variance_delta", "d_study_overlay") == type,
    CaptionBoundary = c(
      "Describe observed design support before coefficient movement.",
      "Name both rows as observed-score G-theory decompositions.",
      "Report deltas as expanded minus baseline.",
      "Describe variance movement, not a guaranteed model improvement.",
      "State residual-scaling and singular-fit evidence."
    ),
    PlotDataContract = rep("mfrm_plot_data", 5L),
    stringsAsFactors = FALSE
  )
}

gtheory_filter_variance_components <- function(vc,
                                               component_type = NULL,
                                               decision_role = NULL,
                                               sort_by = c("value", "source", "none"),
                                               decreasing = TRUE,
                                               top_n = NULL,
                                               value_col = "Value") {
  sort_by <- match.arg(sort_by)
  vc <- as.data.frame(vc, stringsAsFactors = FALSE)
  filter_col <- function(tbl, col, value, arg_name) {
    if (is.null(value)) return(tbl)
    value <- as.character(value)
    value <- value[!is.na(value) & nzchar(value)]
    if (length(value) == 0L) return(tbl)
    if (!col %in% names(tbl)) {
      stop("`", arg_name, "` requires a `", col, "` column in the variance-component table.",
           call. = FALSE)
    }
    available <- sort(unique(as.character(tbl[[col]])))
    missing <- setdiff(value, available)
    if (length(missing) > 0L) {
      stop(
        "`", arg_name, "` must use value(s) from: ",
        paste(available, collapse = ", "), ".",
        call. = FALSE
      )
    }
    tbl[as.character(tbl[[col]]) %in% value, , drop = FALSE]
  }
  vc <- filter_col(vc, "ComponentType", component_type, "component_type")
  vc <- filter_col(vc, "DecisionRole", decision_role, "decision_role")
  if (nrow(vc) == 0L) {
    stop("No variance components remain after filtering.", call. = FALSE)
  }
  if (!is.logical(decreasing) || length(decreasing) != 1L || is.na(decreasing)) {
    stop("`decreasing` must be a single TRUE/FALSE value.", call. = FALSE)
  }
  if (!is.null(top_n)) {
    top_n <- suppressWarnings(as.integer(top_n[1L]))
    if (!is.finite(top_n) || top_n <= 0L) {
      stop("`top_n` must be a positive integer or NULL.", call. = FALSE)
    }
  }
  if (identical(sort_by, "value") && value_col %in% names(vc)) {
    ord <- order(suppressWarnings(as.numeric(vc[[value_col]])),
                 decreasing = isTRUE(decreasing), na.last = TRUE)
    vc <- vc[ord, , drop = FALSE]
  } else if (identical(sort_by, "source") && "Source" %in% names(vc)) {
    ord <- order(as.character(vc$Source), decreasing = isTRUE(decreasing), na.last = TRUE)
    vc <- vc[ord, , drop = FALSE]
  }
  if (!is.null(top_n) && nrow(vc) > top_n) {
    vc <- vc[seq_len(top_n), , drop = FALSE]
  }
  row.names(vc) <- NULL
  vc
}

gtheory_d_study_reading_order <- function() {
  data.frame(
    Step = seq_len(5L),
    Route = c("coefficients", "heatmap", "contour", "error_variance", "table"),
    WhatToPlot = c(
      "plot(x, type = \"coefficients\", draw = FALSE)",
      "plot(x, type = \"heatmap\", metric = \"Phi\", draw = FALSE)",
      "plot(x, type = \"contour\", metric = \"Phi\", draw = FALSE)",
      "plot(x, type = \"error_variance\", draw = FALSE)",
      "as.data.frame(x)"
    ),
    Purpose = c(
      "Start with projected G/Phi by planned facet count.",
      "Use a heatmap when two planned facets vary and a publication-friendly design grid is needed.",
      "Use contours to show approximate target bands on a two-facet design grid.",
      "Diagnose whether relative or absolute error variance is driving low coefficients.",
      "Keep the row-level D-study table as the auditable source for reported design choices."
    ),
    stringsAsFactors = FALSE
  )
}

gtheory_d_study_guidance <- function(type, metric) {
  metric_label <- paste(as.character(metric %||% "selected metric"), collapse = ", ")
  switch(
    type,
    coefficients = c(
      "Use this as the primary D-study design-planning plot.",
      "Read G and Phi separately; G is for relative decisions and Phi is for absolute decisions.",
      "Compare residual-scaling panels or series before selecting a planned design."
    ),
    error_variance = c(
      "Use this after the coefficient plot to see which error term limits dependability.",
      "Relative error affects G; absolute error affects Phi and includes scaled facet main effects.",
      "Do not report the error-variance plot without the matching G/Phi projection."
    ),
    heatmap = c(
      paste0("Use this two-facet grid for ", metric_label, " when a table would be hard to scan."),
      "Prefer heatmap over 3D surface for reporting because equal cells and facets are easier to compare.",
      "Facet or panel residual-scaling assumptions when sensitivity output is present."
    ),
    contour = c(
      paste0("Use contours to communicate approximate ", metric_label, " target regions."),
      "Check the underlying table before treating a contour line as an exact design boundary.",
      "Use alongside heatmap or table output for sparse or irregular grids."
    ),
    surface3d = c(
      paste0("Use the 3D surface only for exploration of ", metric_label, "."),
      "For reports, use heatmap or contour so planned counts and coefficient bands remain readable.",
      "The ggplot conversion renders this route as an editable 2D surface projection."
    )
  )
}

gtheory_d_study_figure_recipes <- function(type, metric, x_var, y_var,
                                           group_var, panel_by, panel_grid) {
  x_call <- gtheory_plot_arg(x_var)
  y_call <- gtheory_plot_arg(y_var)
  group_call <- gtheory_plot_arg(group_var)
  panel_by_call <- gtheory_plot_arg(panel_by)
  panel_grid_call <- gtheory_plot_arg(panel_grid)
  metric_call <- gtheory_plot_arg(metric[1L] %||% "Phi")
  data.frame(
    FigureID = c(
      "dstudy_coefficient_projection",
      "dstudy_phi_heatmap",
      "dstudy_phi_contour",
      "dstudy_error_variance",
      "dstudy_surface_exploration"
    ),
    RecommendedUse = c(
      "Main design-planning figure for projected G/Phi.",
      "Publication-friendly two-facet design grid, usually for Phi.",
      "Approximate target-region display when two planned facets vary.",
      "Diagnostic follow-up for low G/Phi projections.",
      "Exploratory view only; use heatmap or contour in reports."
    ),
    PlotCall = c(
      paste0("plot(x, type = \"coefficients\", x_var = ", x_call,
             ", group_var = ", group_call, ", panel_by = ", panel_by_call,
             ", panel_grid = ", panel_grid_call, ", draw = FALSE)"),
      paste0("plot(x, type = \"heatmap\", metric = \"Phi\", x_var = ", x_call,
             ", y_var = ", y_call, ", draw = FALSE)"),
      paste0("plot(x, type = \"contour\", metric = \"Phi\", x_var = ", x_call,
             ", y_var = ", y_call, ", draw = FALSE)"),
      paste0("plot(x, type = \"error_variance\", x_var = ", x_call,
             ", group_var = ", group_call, ", draw = FALSE)"),
      paste0("plot(x, type = \"surface3d\", metric = ", metric_call,
             ", x_var = ", x_call, ", y_var = ", y_call, ", draw = FALSE)")
    ),
    PlotType = c("coefficients", "heatmap", "contour", "error_variance", "surface3d"),
    Metric = c("G/Phi", "Phi", "Phi", "relative/absolute error variance", metric[1L] %||% "Phi"),
    SelectedRoute = c("coefficients", "heatmap", "contour", "error_variance", "surface3d") == type,
    CaptionBoundary = c(
      "Name G/Phi as G-theory projections under declared residual scaling.",
      "Use as a design grid, not a model-fit heatmap.",
      "Treat contours as approximate guides over the observed grid.",
      "Use as diagnostic support for coefficient interpretation.",
      "Do not use as the primary publication figure."
    ),
    PlotDataContract = rep("mfrm_plot_data", 5L),
    stringsAsFactors = FALSE
  )
}

#' @rdname mfrm_generalizability
#' @param x Output from [mfrm_generalizability()].
#' @param y Reserved for S3 generic compatibility.
#' @param type Plot route. `"design_check"` displays the observed design
#'   review stored in `x$design$design_check`, `"variance_components"` displays
#'   the observed G-study decomposition, and `"coefficients"` displays `G` and
#'   `Phi` with 0.70/0.80 decision-reference bands.
#' @param design_check_type Route passed to
#'   `plot.mfrm_generalizability_design_check()` when `type = "design_check"`.
#' @param design_check_metric Optional design-check metric passed to the
#'   design-check plot route.
#' @param design_check_status Optional design-check status filter.
#' @param design_check_sort_by Ordering rule passed to the design-check plot
#'   route.
#' @param design_check_decreasing Optional design-check ordering direction.
#' @param component_type Optional component-type filter for variance-component
#'   plots, for example `"object_interaction"`, `"facet_interaction"`,
#'   `"facet_main"`, or `"residual"`.
#' @param decision_role Optional decision-role filter for variance-component
#'   plots, for example `"relative_and_absolute_error"` or `"absolute_error"`.
#' @param sort_by Variance-component ordering rule: `"value"` (default),
#'   `"source"`, or `"none"`.
#' @param decreasing Logical. Whether `sort_by` uses decreasing order.
#' @param top_n Optional positive integer limiting the displayed variance
#'   components after filtering and sorting.
#' @param show_proportion Logical. For variance-component plots, use
#'   `ProportionVariance` when available (`TRUE`, default) or raw `Variance`
#'   (`FALSE`).
#' @param draw If `TRUE`, draw with base graphics. If `FALSE`, return an
#'   `mfrm_plot_data` object with reusable plot tables and guidance metadata.
#' @param main Optional plot title.
#' @param palette Optional vector of colors for base graphics.
#' @param preset Plot style preset used by the base-graphics renderer.
#' @param ... Reserved for future extensions.
#' @export
plot.mfrm_generalizability <- function(x,
                                       y = NULL,
                                       type = c("variance_components", "coefficients", "design_check"),
                                       design_check_type = c("interaction_cells", "highest_order", "facet_levels", "overview"),
                                       design_check_metric = NULL,
                                       design_check_status = NULL,
                                       design_check_sort_by = c("status", "value", "name"),
                                       design_check_decreasing = NULL,
                                       component_type = NULL,
                                       decision_role = NULL,
                                       sort_by = c("value", "source", "none"),
                                       decreasing = TRUE,
                                       top_n = NULL,
                                       show_proportion = TRUE,
                                       draw = TRUE,
                                       main = NULL,
                                       palette = NULL,
                                       preset = c("standard", "publication", "compact", "monochrome"),
                                       ...) {
  if (!inherits(x, "mfrm_generalizability")) {
    stop("`x` must be output from mfrm_generalizability().", call. = FALSE)
  }
  type <- match.arg(type)
  design_check_type <- match.arg(design_check_type)
  design_check_sort_by <- match.arg(design_check_sort_by)
  sort_by <- match.arg(sort_by)
  if (!is.logical(show_proportion) || length(show_proportion) != 1L || is.na(show_proportion)) {
    stop("`show_proportion` must be a single TRUE/FALSE value.", call. = FALSE)
  }
  if (identical(type, "design_check")) {
    design_check <- x$design$design_check %||% NULL
    if (!inherits(design_check, "mfrm_generalizability_design_check")) {
      stop(
        "`x` does not contain `design$design_check`; rerun ",
        "mfrm_generalizability() or call check_mfrm_generalizability_design().",
        call. = FALSE
      )
    }
    return(plot(
      design_check,
      type = design_check_type,
      metric = design_check_metric,
      status = design_check_status,
      sort_by = design_check_sort_by,
      decreasing = design_check_decreasing,
      top_n = top_n %||% Inf,
      draw = draw,
      main = main,
      palette = palette,
      preset = preset,
      ...
    ))
  }
  style <- resolve_plot_preset(preset)
  reading_order <- gtheory_generalizability_reading_order()
  interpretation_note <- gtheory_interpretation_note()

  if (identical(type, "variance_components")) {
    vc <- as.data.frame(x$variance_components %||% data.frame(), stringsAsFactors = FALSE)
    if (!all(c("Source", "Variance", "ProportionVariance") %in% names(vc))) {
      stop("G-study variance components are missing required columns.", call. = FALSE)
    }
    vc$Source <- as.character(vc$Source)
    vc$Variance <- suppressWarnings(as.numeric(vc$Variance))
    vc$ProportionVariance <- suppressWarnings(as.numeric(vc$ProportionVariance))
    value_col <- if (isTRUE(show_proportion) && any(is.finite(vc$ProportionVariance))) {
      "ProportionVariance"
    } else {
      "Variance"
    }
    vc$Value <- suppressWarnings(as.numeric(vc[[value_col]]))
    vc <- vc[is.finite(vc$Value), , drop = FALSE]
    vc <- gtheory_filter_variance_components(
      vc,
      component_type = component_type,
      decision_role = decision_role,
      sort_by = sort_by,
      decreasing = decreasing,
      top_n = top_n,
      value_col = "Value"
    )
    if (nrow(vc) == 0L) {
      stop("No finite G-study variance components are available for plotting.", call. = FALSE)
    }
    vc$MetricFamily <- "G-theory"
    vc$MetricRole <- if (identical(value_col, "ProportionVariance")) "variance_share" else "variance_component"
    bar_cols <- if (is.null(palette)) {
      if (identical(style$name, "monochrome")) {
        grDevices::gray.colors(nrow(vc), start = 0.78, end = 0.35)
      } else {
        grDevices::hcl.colors(max(3L, nrow(vc)), palette = "Dark 3")[seq_len(nrow(vc))]
      }
    } else {
      rep(as.character(palette), length.out = nrow(vc))
    }
    if (isTRUE(draw)) {
      apply_plot_preset(style)
      old_par <- graphics::par(no.readonly = TRUE)
      on.exit(graphics::par(old_par), add = TRUE)
      y_top <- max(vc$Value, na.rm = TRUE)
      if (!is.finite(y_top) || y_top <= 0) y_top <- 1
      graphics::barplot(
        vc$Value,
        names.arg = truncate_axis_label(vc$Source, width = 18L),
        col = bar_cols,
        border = NA,
        las = 2,
        ylim = c(0, y_top * 1.12),
        ylab = if (identical(value_col, "ProportionVariance")) "Proportion of variance" else "Variance",
        main = main %||% "G-study variance components"
      )
      graphics::grid(nx = NA, ny = NULL, col = style$grid)
    }
    return(invisible(new_mfrm_plot_data(
      "generalizability",
      list(
        plot = type,
        plot_table = vc,
        variance_components = vc,
        coefficients = as.data.frame(x$coefficients %||% data.frame(), stringsAsFactors = FALSE),
        design = x$design,
        metric_family = "G-theory",
        metric = value_col,
        value_col = "Value",
        reading_order = reading_order,
        guidance = gtheory_generalizability_guidance(type),
        figure_recipes = gtheory_generalizability_figure_recipes(type),
        interpretation_note = interpretation_note,
        title = main %||% "G-study variance components",
        subtitle = if (identical(x$design$model_scope %||% "main_effects", "interaction_expanded")) {
          "Interaction-expanded variance decomposition"
        } else {
          "Main-effects variance decomposition"
        },
        filters = list(
          component_type = component_type,
          decision_role = decision_role,
          sort_by = sort_by,
          decreasing = isTRUE(decreasing),
          top_n = top_n,
          show_proportion = isTRUE(show_proportion)
        ),
        legend = new_plot_legend(
          label = vc$Source,
          role = rep("variance_component", nrow(vc)),
          aesthetic = rep("fill", nrow(vc)),
          value = bar_cols
        ),
        reference_lines = new_reference_lines(),
        preset = style$name
      )
    )))
  }

  coefs <- as.data.frame(x$coefficients %||% data.frame(), stringsAsFactors = FALSE)
  coef_values <- c(
    G = suppressWarnings(as.numeric(coefs$G[1L] %||% NA_real_)),
    Phi = suppressWarnings(as.numeric(coefs$Phi[1L] %||% NA_real_))
  )
  coef_tbl <- data.frame(
    Metric = names(coef_values),
    MetricFamily = "G-theory",
    MetricRole = c("relative_decision", "absolute_decision"),
    Value = round(as.numeric(coef_values), 4),
    Status = gtheory_coefficient_status(coef_values),
    stringsAsFactors = FALSE
  )
  coef_tbl <- coef_tbl[is.finite(coef_tbl$Value), , drop = FALSE]
  if (nrow(coef_tbl) == 0L) {
    stop("No finite G-study coefficients are available for plotting.", call. = FALSE)
  }
  status_cols <- c(
    high_stakes_candidate = "#238b45",
    routine_candidate = "#d99f0b",
    review = "#b11f24",
    unavailable = "#6b7280"
  )
  bar_cols <- if (is.null(palette)) {
    unname(status_cols[coef_tbl$Status])
  } else {
    rep(as.character(palette), length.out = nrow(coef_tbl))
  }
  if (isTRUE(draw)) {
    apply_plot_preset(style)
    old_par <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(old_par), add = TRUE)
    graphics::barplot(
      coef_tbl$Value,
      names.arg = coef_tbl$Metric,
      col = bar_cols,
      border = NA,
      ylim = c(0, 1),
      ylab = "Coefficient",
      main = main %||% "G-study G/Phi coefficients"
    )
    graphics::grid(nx = NA, ny = NULL, col = style$grid)
    graphics::abline(
      h = c(0.70, 0.80),
      col = grDevices::adjustcolor(style$neutral, alpha.f = 0.6),
      lty = c(3, 2)
    )
  }
  invisible(new_mfrm_plot_data(
    "generalizability",
    list(
      plot = type,
      plot_table = coef_tbl,
      variance_components = as.data.frame(x$variance_components %||% data.frame(), stringsAsFactors = FALSE),
      coefficients = coef_tbl,
      design = x$design,
      metric_family = "G-theory",
      metric = coef_tbl$Metric,
      value_col = "Value",
      reading_order = reading_order,
      guidance = gtheory_generalizability_guidance(type),
      figure_recipes = gtheory_generalizability_figure_recipes(type),
      interpretation_note = interpretation_note,
      title = main %||% "G-study G/Phi coefficients",
      subtitle = if (identical(x$design$model_scope %||% "main_effects", "interaction_expanded")) {
        "Relative and absolute dependability, interaction-expanded sensitivity model"
      } else {
        "Relative and absolute dependability, one-observation-per-cell baseline"
      },
      legend = new_plot_legend(
        label = coef_tbl$Status,
        role = rep("decision_band", nrow(coef_tbl)),
        aesthetic = rep("fill", nrow(coef_tbl)),
        value = bar_cols
      ),
      reference_lines = new_reference_lines(
        axis = rep("y", 2L),
        value = c(0.70, 0.80),
        label = c("routine", "high_stakes"),
        linetype = c("dotted", "dashed"),
        role = rep("decision_band", 2L)
      ),
      preset = style$name
    )
  ))
}

#' @rdname mfrm_d_study
#' @param y Reserved for S3 generic compatibility.
#' @param type Plot route: `"coefficients"` for projected `G`/`Phi`,
#'   `"error_variance"` for relative/absolute error variance, `"heatmap"` or
#'   `"contour"` for two-planned-facet design grids, and `"surface3d"` for
#'   exploratory base-R perspective plots.
#' @param x_var Planned-count column for the x axis. Defaults to the first
#'   `n_<facet>` column.
#' @param y_var Planned-count column for heatmap, contour, and surface routes.
#' @param group_var Optional series grouping column for line routes.
#' @param panel_by Optional single column for small multiples.
#' @param panel_grid Optional two-column small-multiple grid.
#' @param metric Metric to display. Line routes default to both `G`/`Phi` or
#'   both error-variance metrics; surface routes require exactly one metric.
#' @param draw If `TRUE`, draw with base graphics. If `FALSE`, return an
#'   `mfrm_plot_data` object with reusable plot tables and guidance metadata.
#' @param main Optional plot title.
#' @param palette Optional colors.
#' @param preset Plot style preset used by the base-graphics renderer.
#' @export
plot.mfrm_d_study <- function(x,
                              y = NULL,
                              type = c("coefficients", "error_variance", "heatmap", "contour", "surface3d"),
                              x_var = NULL,
                              y_var = NULL,
                              group_var = NULL,
                              panel_by = NULL,
                              panel_grid = NULL,
                              metric = NULL,
                              draw = TRUE,
                              main = NULL,
                              palette = NULL,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              ...) {
  type <- match.arg(type)
  tbl <- as.data.frame(x, stringsAsFactors = FALSE)
  n_cols <- grep("^n_", names(tbl), value = TRUE)
  if (length(n_cols) == 0L) {
    stop("D-study table does not contain planned-count columns.", call. = FALSE)
  }
  if (is.null(x_var)) {
    x_var <- n_cols[1L]
  }
  x_var <- as.character(x_var[1L])
  if (!x_var %in% names(tbl)) {
    stop("`x_var` must be one of: ", paste(n_cols, collapse = ", "), call. = FALSE)
  }

  is_surface <- type %in% c("heatmap", "contour", "surface3d")
  if (is_surface) {
    if (is.null(y_var)) {
      candidates <- setdiff(n_cols, x_var)
      if (length(candidates) == 0L) {
        stop("`y_var` is required for D-study heatmap/contour plots.", call. = FALSE)
      }
      y_var <- candidates[1L]
    }
    y_var <- as.character(y_var[1L])
    if (!y_var %in% names(tbl)) {
      stop("`y_var` must be one of: ", paste(setdiff(n_cols, x_var), collapse = ", "), call. = FALSE)
    }
    if (identical(y_var, x_var)) {
      stop("`y_var` must differ from `x_var`.", call. = FALSE)
    }
  }

  coefficient_cols <- c("G", "Phi")
  error_cols <- c("RelativeErrorVariance", "AbsoluteErrorVariance")
  available_metrics <- if (identical(type, "coefficients")) {
    coefficient_cols
  } else if (identical(type, "error_variance")) {
    error_cols
  } else {
    c(coefficient_cols, error_cols)
  }
  if (is_surface && is.null(metric)) {
    metric <- if ("Phi" %in% available_metrics) "Phi" else available_metrics[1L]
  }
  if (!is.null(metric)) {
    metric <- as.character(metric)
    unknown_metric <- setdiff(metric, c(coefficient_cols, error_cols))
    if (length(unknown_metric) > 0L) {
      stop("`metric` must be one of: ",
           paste(c(coefficient_cols, error_cols), collapse = ", "), call. = FALSE)
    }
    metric_cols <- intersect(metric, available_metrics)
    if (length(metric_cols) == 0L) {
      stop("`metric` is not compatible with `type = \"", type, "\"`.", call. = FALSE)
    }
  } else {
    metric_cols <- available_metrics
  }
  if (is_surface && length(metric_cols) != 1L) {
    stop("D-study surface plots require exactly one `metric`.", call. = FALSE)
  }
  missing_metrics <- setdiff(metric_cols, names(tbl))
  if (length(missing_metrics) > 0L) {
    stop("D-study table is missing metric column(s): ",
         paste(missing_metrics, collapse = ", "), call. = FALSE)
  }

  scaling <- if ("ResidualScaling" %in% names(tbl)) {
    as.character(tbl$ResidualScaling)
  } else {
    rep("projection", nrow(tbl))
  }
  series_tbl <- do.call(rbind, lapply(metric_cols, function(metric_name) {
    tmp <- tbl
    tmp$Metric <- metric_name
    tmp$MetricFamily <- "G-theory"
    tmp$MetricRole <- dplyr::case_when(
      metric_name == "G" ~ "relative_decision",
      metric_name == "Phi" ~ "absolute_decision",
      metric_name == "RelativeErrorVariance" ~ "relative_error",
      metric_name == "AbsoluteErrorVariance" ~ "absolute_error",
      TRUE ~ "projection"
    )
    tmp$ResidualScaling <- scaling
    tmp$X <- suppressWarnings(as.numeric(tmp[[x_var]]))
    tmp$Y <- if (is_surface) suppressWarnings(as.numeric(tmp[[y_var]])) else NA_real_
    tmp$Value <- suppressWarnings(as.numeric(tmp[[metric_name]]))
    tmp
  }))
  series_tbl <- series_tbl[is.finite(series_tbl$X) & is.finite(series_tbl$Value), , drop = FALSE]
  if (is_surface) {
    series_tbl <- series_tbl[is.finite(series_tbl$Y), , drop = FALSE]
  }

  plot_vars <- c(names(tbl), "Metric", "MetricFamily", "MetricRole", "ResidualScaling")
  validate_plot_var <- function(value, arg_name, allow_null = TRUE, max_len = Inf) {
    if (is.null(value)) {
      if (isTRUE(allow_null)) return(NULL)
      stop("`", arg_name, "` is required.", call. = FALSE)
    }
    value <- as.character(value)
    value <- value[nzchar(value)]
    if (length(value) == 0L) {
      if (isTRUE(allow_null)) return(NULL)
      stop("`", arg_name, "` is required.", call. = FALSE)
    }
    if (length(value) > max_len) {
      stop("`", arg_name, "` must have length <= ", max_len, ".", call. = FALSE)
    }
    missing <- setdiff(value, plot_vars)
    if (length(missing) > 0L) {
      stop("`", arg_name, "` must use column(s) from the D-study plot data: ",
           paste(plot_vars, collapse = ", "), ".", call. = FALSE)
    }
    value
  }
  if (is.null(group_var) && !is_surface) {
    group_candidates <- setdiff(n_cols, x_var)
    if (length(group_candidates) > 0L) {
      group_var <- group_candidates[1L]
    }
  }
  group_var <- validate_plot_var(group_var, "group_var", allow_null = TRUE, max_len = 1L)
  panel_by <- validate_plot_var(panel_by, "panel_by", allow_null = TRUE, max_len = 1L)
  panel_grid <- validate_plot_var(panel_grid, "panel_grid", allow_null = TRUE, max_len = 2L)
  if (!is.null(panel_by) && !is.null(panel_grid)) {
    stop("Use either `panel_by` or `panel_grid`, not both.", call. = FALSE)
  }
  if (is_surface && is.null(panel_by) && is.null(panel_grid) &&
      "ResidualScaling" %in% names(series_tbl) &&
      dplyr::n_distinct(series_tbl$ResidualScaling) > 1L) {
    panel_by <- "ResidualScaling"
  }

  style <- resolve_plot_preset(preset)
  if (nrow(series_tbl) == 0L) {
    stop("No finite D-study values are available for plotting.", call. = FALSE)
  }
  reading_order <- gtheory_d_study_reading_order()
  interpretation_note <- gtheory_interpretation_note()
  guidance <- gtheory_d_study_guidance(type, metric_cols)
  figure_recipes <- gtheory_d_study_figure_recipes(
    type = type,
    metric = metric_cols,
    x_var = x_var,
    y_var = y_var,
    group_var = group_var,
    panel_by = panel_by,
    panel_grid = panel_grid
  )

  if (is_surface) {
    panel_vars <- c(panel_by, panel_grid)
    if (length(panel_vars) == 0L) {
      series_tbl$Panel <- "All designs"
      panel_levels <- "All designs"
    } else {
      series_tbl$Panel <- do.call(paste, c(series_tbl[, panel_vars, drop = FALSE], sep = " / "))
      panel_levels <- unique(series_tbl$Panel)
    }
    fill_values <- range(series_tbl$Value, na.rm = TRUE)
    fill_cols <- if (is.null(palette)) {
      if (identical(style$name, "monochrome")) {
        grDevices::gray.colors(18L, start = 0.95, end = 0.25)
      } else {
        grDevices::hcl.colors(18L, palette = "YlGnBu", rev = TRUE)
      }
    } else {
      rep(as.character(palette), length.out = 18L)
    }
    if (isTRUE(draw)) {
      apply_plot_preset(style)
      old_par <- graphics::par(no.readonly = TRUE)
      on.exit(graphics::par(old_par), add = TRUE)
      panel_n <- length(panel_levels)
      graphics::par(mfrow = grDevices::n2mfrow(panel_n))
      for (panel in panel_levels) {
        s <- series_tbl[series_tbl$Panel == panel, , drop = FALSE]
        x_levels <- sort(unique(s$X))
        y_levels <- sort(unique(s$Y))
        z <- matrix(NA_real_, nrow = length(x_levels), ncol = length(y_levels))
        for (i in seq_len(nrow(s))) {
          xi <- match(s$X[i], x_levels)
          yi <- match(s$Y[i], y_levels)
          z[xi, yi] <- s$Value[i]
        }
        z_finite <- z[is.finite(z)]
        has_contours <- length(unique(z_finite)) > 1L
        if (identical(type, "heatmap")) {
          graphics::image(
            x_levels, y_levels, z,
            col = fill_cols,
            zlim = fill_values,
            xlab = x_var,
            ylab = y_var,
            main = main %||% paste(metric_cols[1L], panel, sep = " / ")
          )
          if (has_contours) {
            graphics::contour(x_levels, y_levels, z, add = TRUE, drawlabels = TRUE)
          }
        } else if (identical(type, "contour")) {
          if (has_contours) {
            graphics::contour(
              x_levels, y_levels, z,
              xlab = x_var,
              ylab = y_var,
              main = main %||% paste(metric_cols[1L], panel, sep = " / "),
              drawlabels = TRUE
            )
          } else {
            graphics::plot(
              range(x_levels, na.rm = TRUE),
              range(y_levels, na.rm = TRUE),
              type = "n",
              xlab = x_var,
              ylab = y_var,
              main = main %||% paste(metric_cols[1L], panel, sep = " / ")
            )
            graphics::text(mean(range(x_levels, na.rm = TRUE)), mean(range(y_levels, na.rm = TRUE)), "constant surface")
          }
        } else {
          zlim <- range(z_finite, na.rm = TRUE)
          if (!all(is.finite(zlim))) {
            zlim <- c(0, 1)
          }
          if (isTRUE(all.equal(zlim[1L], zlim[2L]))) {
            pad <- max(1e-6, abs(zlim[1L]) * 1e-6)
            zlim <- zlim + c(-pad, pad)
          }
          z_cols <- if (is.null(palette)) {
            if (identical(style$name, "monochrome")) "gray85" else style$fill_soft
          } else {
            as.character(palette)[1L]
          }
          graphics::persp(
            x_levels, y_levels, z,
            theta = 35,
            phi = 25,
            col = z_cols,
            border = grDevices::adjustcolor(style$foreground, alpha.f = 0.35),
            ticktype = "detailed",
            xlab = x_var,
            ylab = y_var,
            zlab = metric_cols[1L],
            zlim = zlim,
            main = main %||% paste(metric_cols[1L], panel, sep = " / ")
          )
        }
      }
    }
    return(invisible(new_mfrm_plot_data(
      "d_study",
      list(
        plot = type,
        table = tbl,
        series = series_tbl,
        surface = series_tbl,
        metric_family = "G-theory",
        metric = metric_cols[1L],
        x_var = x_var,
        y_var = y_var,
        group_var = group_var %||% NA_character_,
        panel_by = panel_by %||% NA_character_,
        panel_grid = panel_grid %||% character(0),
        title = main %||% paste("D-study", metric_cols[1L], type),
        subtitle = "Projection from declared G-study variance components",
        reading_order = reading_order,
        guidance = guidance,
        figure_recipes = figure_recipes,
        interpretation_note = interpretation_note,
        legend = new_plot_legend(
          label = metric_cols[1L],
          role = "metric",
          aesthetic = switch(type, heatmap = "fill", contour = "contour", surface3d = "surface", "value"),
          value = paste(fill_values, collapse = " to ")
        ),
        reference_lines = new_reference_lines(),
        preset = style$name
      )
    )))
  }

  panel_vars <- c(panel_by, panel_grid)
  group_components <- unique(c("Metric", "ResidualScaling", group_var))
  group_components <- setdiff(group_components[!is.na(group_components) & nzchar(group_components)], panel_vars)
  if (length(group_components) == 0L) {
    series_tbl$Series <- "Projection"
  } else {
    series_tbl$Series <- do.call(paste, c(series_tbl[, group_components, drop = FALSE], sep = " / "))
  }
  if (length(panel_grid) == 2L) {
    series_tbl$PanelRow <- as.character(series_tbl[[panel_grid[1L]]])
    series_tbl$PanelCol <- as.character(series_tbl[[panel_grid[2L]]])
    series_tbl$Panel <- paste(series_tbl$PanelRow, series_tbl$PanelCol, sep = " / ")
  } else if (!is.null(panel_by)) {
    series_tbl$Panel <- as.character(series_tbl[[panel_by]])
    series_tbl$PanelRow <- series_tbl$Panel
    series_tbl$PanelCol <- "panel"
  } else {
    series_tbl$Panel <- "All designs"
    series_tbl$PanelRow <- "All designs"
    series_tbl$PanelCol <- "panel"
  }
  series_levels <- unique(series_tbl$Series)
  if (is.null(palette)) {
    series_cols <- if (identical(style$name, "monochrome")) {
      stats::setNames(rep(style$foreground, length(series_levels)), series_levels)
    } else {
      stats::setNames(
        grDevices::hcl.colors(max(3L, length(series_levels)), palette = "Dark 3")[seq_along(series_levels)],
        series_levels
      )
    }
  } else {
    palette <- as.character(palette)
    series_cols <- stats::setNames(rep(palette, length.out = length(series_levels)), series_levels)
  }
  line_types <- stats::setNames(rep(seq_len(6L), length.out = length(series_levels)), series_levels)

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    old_par <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(old_par), add = TRUE)
    if (length(panel_grid) == 2L) {
      row_levels <- unique(series_tbl$PanelRow)
      col_levels <- unique(series_tbl$PanelCol)
      graphics::par(mfrow = c(length(row_levels), length(col_levels)))
      panel_specs <- expand.grid(PanelRow = row_levels, PanelCol = col_levels, stringsAsFactors = FALSE)
    } else {
      panel_levels <- unique(series_tbl$Panel)
      graphics::par(mfrow = grDevices::n2mfrow(length(panel_levels)))
      panel_specs <- data.frame(Panel = panel_levels, stringsAsFactors = FALSE)
    }
    y_lim <- if (identical(type, "coefficients")) {
      c(0, 1)
    } else {
      range(c(0, series_tbl$Value), na.rm = TRUE)
    }
    for (i in seq_len(nrow(panel_specs))) {
      if (length(panel_grid) == 2L) {
        s_panel <- series_tbl[
          series_tbl$PanelRow == panel_specs$PanelRow[i] &
            series_tbl$PanelCol == panel_specs$PanelCol[i],
          ,
          drop = FALSE
        ]
        panel_title <- paste(panel_specs$PanelRow[i], panel_specs$PanelCol[i], sep = " / ")
      } else {
        s_panel <- series_tbl[series_tbl$Panel == panel_specs$Panel[i], , drop = FALSE]
        panel_title <- panel_specs$Panel[i]
      }
      graphics::plot(
        s_panel$X,
        s_panel$Value,
        type = "n",
        xlab = x_var,
        ylab = if (identical(type, "coefficients")) "Coefficient" else "Error variance",
        ylim = y_lim,
        main = main %||% panel_title
      )
      graphics::grid(col = style$grid)
      for (series in unique(s_panel$Series)) {
        s <- s_panel[s_panel$Series == series, , drop = FALSE]
        s <- s[order(s$X), , drop = FALSE]
        graphics::lines(s$X, s$Value, col = series_cols[series], lty = line_types[series], lwd = 2)
        graphics::points(s$X, s$Value, col = series_cols[series], pch = 16)
      }
      if (identical(type, "coefficients")) {
        graphics::abline(h = c(0.70, 0.80), col = grDevices::adjustcolor(style$neutral, alpha.f = 0.6), lty = c(3, 2))
      }
      graphics::legend(
        "bottomright",
        legend = unique(s_panel$Series),
        col = unname(series_cols[unique(s_panel$Series)]),
        lty = unname(line_types[unique(s_panel$Series)]),
        pch = 16,
        bty = "n",
        cex = 0.72
      )
    }
  }

  invisible(new_mfrm_plot_data(
    "d_study",
    list(
      plot = type,
      table = tbl,
      series = series_tbl,
      metric_family = "G-theory",
      metric = metric_cols,
      x_var = x_var,
      y_var = y_var %||% NA_character_,
      group_var = group_var %||% NA_character_,
      panel_by = panel_by %||% NA_character_,
      panel_grid = panel_grid %||% character(0),
      title = main %||% if (identical(type, "coefficients")) "D-study G/Phi projection" else "D-study error variance projection",
      subtitle = "Projection from declared G-study variance components",
      reading_order = reading_order,
      guidance = guidance,
      figure_recipes = figure_recipes,
      interpretation_note = interpretation_note,
      legend = new_plot_legend(
        label = series_levels,
        role = rep("series", length(series_levels)),
        aesthetic = rep("line", length(series_levels)),
        value = unname(series_cols[series_levels])
      ),
      reference_lines = if (identical(type, "coefficients")) {
        new_reference_lines(
          axis = rep("y", 2L),
          value = c(0.70, 0.80),
          label = c("routine", "high_stakes"),
          linetype = c("dotted", "dashed"),
          role = rep("decision_band", 2L)
        )
      } else {
        new_reference_lines()
      },
      preset = style$name
    )
  ))
}

gtheory_design_check_status_colors <- function(style) {
  c(
    ok = style$success,
    sensitivity_only = style$warn,
    review = style$fail,
    not_requested = style$neutral
  )
}

gtheory_design_check_metric_label <- function(metric) {
  labels <- c(
    CellDensity = "Observed cell density",
    ReplicatedCellRate = "Replicated cell rate",
    SingletonCellRate = "Singleton cell rate",
    ObservedCells = "Observed cells",
    MissingCells = "Missing cells",
    PossibleCells = "Possible cells",
    ReplicatedFullCellRate = "Replicated full-cell rate",
    SingletonFullCellRate = "Singleton full-cell rate",
    Levels = "Observed levels",
    Observations = "Rows",
    SingletonLevelRate = "Singleton level rate",
    MinRowsPerLevel = "Minimum rows per level",
    MedianRowsPerLevel = "Median rows per level",
    MaxRowsPerLevel = "Maximum rows per level",
    Count = "Count"
  )
  labels[[metric]] %||% metric
}

gtheory_design_check_default_metric <- function(type) {
  switch(
    type,
    interaction_cells = "ReplicatedCellRate",
    highest_order = "ReplicatedFullCellRate",
    facet_levels = "Levels",
    overview = "Count",
    "Count"
  )
}

gtheory_design_check_table <- function(x, type, metric = NULL,
                                       status = NULL,
                                       sort_by = c("status", "value", "name"),
                                       decreasing = NULL,
                                       top_n = Inf) {
  sort_by <- match.arg(sort_by)
  metric <- as.character(metric %||% gtheory_design_check_default_metric(type))[1L]
  decreasing <- isTRUE(decreasing %||% !identical(sort_by, "name"))
  top_n <- suppressWarnings(as.integer(top_n[1] %||% Inf))
  if (!is.finite(top_n) || top_n <= 0L) top_n <- Inf

  if (identical(type, "interaction_cells")) {
    tbl <- as.data.frame(x$interaction_overview %||% data.frame(),
                         stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L) {
      stop("No interaction-overview rows are available.", call. = FALSE)
    }
    group <- as.character(tbl$Interaction %||% tbl$Facets)
    source <- "interaction_overview"
  } else if (identical(type, "highest_order")) {
    tbl <- as.data.frame(x$highest_order_review %||% data.frame(),
                         stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L) {
      stop("No highest-order review row is available.", call. = FALSE)
    }
    group <- as.character(tbl$FullCellFacets %||% "Highest-order cells")
    source <- "highest_order_review"
  } else if (identical(type, "facet_levels")) {
    tbl <- as.data.frame(x$facet_overview %||% data.frame(),
                         stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L) {
      stop("No facet-overview rows are available.", call. = FALSE)
    }
    group <- as.character(tbl$Facet %||% "Facet")
    source <- "facet_overview"
  } else {
    overview <- as.data.frame(x$overview %||% data.frame(),
                              stringsAsFactors = FALSE)
    if (nrow(overview) == 0L) {
      stop("No design-check overview row is available.", call. = FALSE)
    }
    tbl <- data.frame(
      Signal = c(
        "Facet review",
        "Interaction review",
        "Interaction sensitivity-only",
        "Highest-order review",
        "Highest-order sensitivity-only"
      ),
      Count = c(
        suppressWarnings(as.numeric(overview$FacetReviewCount[1] %||% 0)),
        suppressWarnings(as.numeric(overview$InteractionReviewCount[1] %||% 0)),
        suppressWarnings(as.numeric(overview$InteractionSensitivityOnlyCount[1] %||% 0)),
        as.numeric(identical(as.character(overview$HighestOrderStatus[1] %||% ""), "review")),
        as.numeric(identical(as.character(overview$HighestOrderStatus[1] %||% ""), "sensitivity_only"))
      ),
      Status = c("review", "review", "sensitivity_only",
                 as.character(overview$HighestOrderStatus[1] %||% "ok"),
                 as.character(overview$HighestOrderStatus[1] %||% "ok")),
      MainConcern = c(
        "facet_level_review",
        "interaction_cell_review",
        "interaction_cell_sensitivity",
        "highest_order_review",
        "highest_order_sensitivity"
      ),
      RecommendedAction = "Review the source table before reporting interaction-expanded G-study claims.",
      stringsAsFactors = FALSE
    )
    group <- tbl$Signal
    metric <- "Count"
    source <- "overview"
  }

  if (!metric %in% names(tbl)) {
    numeric_cols <- names(tbl)[vapply(tbl, is.numeric, logical(1))]
    stop(
      "`metric` must be one of: ",
      paste(numeric_cols, collapse = ", "),
      call. = FALSE
    )
  }
  value <- suppressWarnings(as.numeric(tbl[[metric]]))
  status_col <- as.character(tbl$Status %||% "ok")
  if (identical(type, "interaction_cells") &&
      length(status_col) == 1L &&
      identical(status_col[1], "not_requested") &&
      (!is.finite(value[1]) || is.na(value[1]))) {
    value[1] <- 0
  }
  concern <- as.character(tbl$MainConcern %||% "")
  action <- as.character(tbl$RecommendedAction %||% "")
  plot_table <- data.frame(
    PlotGroup = group,
    Value = value,
    Metric = metric,
    MetricLabel = gtheory_design_check_metric_label(metric),
    Status = status_col,
    StatusRank = vapply(status_col, mfrm_gt_status_rank, integer(1)),
    MainConcern = concern,
    RecommendedAction = action,
    SourceTable = source,
    stringsAsFactors = FALSE
  )
  keep <- is.finite(plot_table$Value) & nzchar(plot_table$PlotGroup)
  plot_table <- plot_table[keep, , drop = FALSE]
  if (!is.null(status)) {
    status <- as.character(status)
    status <- status[!is.na(status) & nzchar(status)]
    if (length(status) > 0L) {
      plot_table <- plot_table[plot_table$Status %in% status, , drop = FALSE]
    }
  }
  if (nrow(plot_table) == 0L) {
    stop("No finite design-check rows are available for plotting.", call. = FALSE)
  }
  ord <- switch(
    sort_by,
    status = order(plot_table$StatusRank, plot_table$Value,
                   plot_table$PlotGroup, decreasing = decreasing),
    value = order(plot_table$Value, plot_table$PlotGroup,
                  decreasing = decreasing),
    name = order(plot_table$PlotGroup, decreasing = decreasing)
  )
  plot_table <- plot_table[ord, , drop = FALSE]
  if (is.finite(top_n) && nrow(plot_table) > top_n) {
    plot_table <- plot_table[seq_len(top_n), , drop = FALSE]
  }
  row.names(plot_table) <- NULL
  plot_table
}

gtheory_design_check_reading_order <- function() {
  data.frame(
    Route = c("overview", "interaction_cells", "highest_order",
              "facet_levels", "source_tables"),
    UseWhen = c(
      "Start here to count review and sensitivity-only signals.",
      "Use this before interpreting named two-way interaction components.",
      "Use this to decide whether residual and highest-order interaction remain difficult to separate.",
      "Use this to inspect sparse or weakly represented facets.",
      "Use the source tables for exact cells, concerns, and recommended actions."
    ),
    Function = c(
      "plot(x, type = \"overview\", draw = FALSE)",
      "plot(x, type = \"interaction_cells\", draw = FALSE)",
      "plot(x, type = \"highest_order\", draw = FALSE)",
      "plot(x, type = \"facet_levels\", draw = FALSE)",
      "x$interaction_overview; x$highest_order_review; x$facet_overview"
    ),
    stringsAsFactors = FALSE
  )
}

gtheory_design_check_guidance <- function(type, metric) {
  data.frame(
    Step = c("Read status first", "Read metric second", "Do not overclaim"),
    Guidance = c(
      "Review and sensitivity-only statuses identify where the expanded G-study needs caution.",
      paste0(gtheory_design_check_metric_label(metric),
             " is descriptive evidence about the observed rating design, not a variance component."),
      "Use these displays with main-effects versus interaction-expanded G-study comparison, lme4 singular-fit messages, and substantive design knowledge."
    ),
    stringsAsFactors = FALSE
  )
}

gtheory_design_check_figure_recipes <- function(type, metric) {
  routes <- c("overview", "interaction_cells", "highest_order", "facet_levels")
  data.frame(
    PlotType = routes,
    DefaultMetric = vapply(routes, gtheory_design_check_default_metric,
                           character(1)),
    SelectedRoute = routes == type,
    ExampleCall = c(
      "plot(x, type = \"overview\", draw = FALSE)",
      paste0("plot(x, type = \"interaction_cells\", metric = \"",
             metric, "\", draw = FALSE)"),
      "plot(x, type = \"highest_order\", draw = FALSE)",
      "plot(x, type = \"facet_levels\", metric = \"Levels\", draw = FALSE)"
    ),
    stringsAsFactors = FALSE
  )
}

#' @rdname check_mfrm_generalizability_design
#' @param x Output from `check_mfrm_generalizability_design()` or its
#'   `summary()` method.
#' @param y Reserved for S3 generic compatibility.
#' @param type Plot route. `"interaction_cells"` displays requested
#'   interaction-cell density or replication, `"highest_order"` displays the
#'   full object-by-facet cell review, `"facet_levels"` displays observed
#'   facet-level coverage, and `"overview"` displays review/sensitivity counts.
#' @param metric Numeric column to plot for the selected route. Defaults are
#'   route-specific; inspect `plot_data_components(plot(x, draw = FALSE))` or
#'   the source tables for alternatives.
#' @param status Optional status filter, for example `"review"` or
#'   `c("review", "sensitivity_only")`.
#' @param sort_by Ordering rule: `"status"`, `"value"`, or `"name"`.
#' @param decreasing Logical ordering direction. Defaults to descending except
#'   for `sort_by = "name"`.
#' @param top_n Optional maximum number of rows to display.
#' @param draw If `TRUE`, draw with base graphics. If `FALSE`, return an
#'   `mfrm_plot_data` object.
#' @param main Optional plot title.
#' @param palette Optional named or unnamed colors for statuses.
#' @param preset Plot style preset used by the base-graphics renderer.
#' @export
plot.mfrm_generalizability_design_check <- function(x,
                                                    y = NULL,
                                                    type = c("interaction_cells", "highest_order", "facet_levels", "overview"),
                                                    metric = NULL,
                                                    status = NULL,
                                                    sort_by = c("status", "value", "name"),
                                                    decreasing = NULL,
                                                    top_n = Inf,
                                                    draw = TRUE,
                                                    main = NULL,
                                                    palette = NULL,
                                                    preset = c("standard", "publication", "compact", "monochrome"),
                                                    ...) {
  if (!inherits(x, "mfrm_generalizability_design_check")) {
    stop("`x` must be output from check_mfrm_generalizability_design().",
         call. = FALSE)
  }
  type <- match.arg(type)
  sort_by <- match.arg(sort_by)
  style <- resolve_plot_preset(preset)
  plot_table <- gtheory_design_check_table(
    x = x,
    type = type,
    metric = metric,
    status = status,
    sort_by = sort_by,
    decreasing = decreasing,
    top_n = top_n
  )
  metric <- plot_table$Metric[1]
  metric_label <- plot_table$MetricLabel[1]
  status_cols <- resolve_palette(
    palette,
    defaults = gtheory_design_check_status_colors(style)
  )
  plot_table$Color <- unname(status_cols[plot_table$Status])
  plot_table$Color[is.na(plot_table$Color)] <- style$neutral
  value_scale <- if (grepl("Rate|Density", metric)) "proportion" else "count"
  title <- main %||% switch(
    type,
    interaction_cells = "G-study design check: requested interactions",
    highest_order = "G-study design check: highest-order cells",
    facet_levels = "G-study design check: facet coverage",
    overview = "G-study design check: review signals"
  )
  subtitle <- if (identical(value_scale, "proportion")) {
    "Rates describe observed design support, not fitted variance components"
  } else {
    "Counts describe observed design support, not fitted variance components"
  }
  reference_lines <- if (identical(value_scale, "proportion")) {
    new_reference_lines(
      axis = "y",
      value = 0.5,
      label = "0.50 review reference",
      linetype = "dashed",
      role = "design_reference"
    )
  } else {
    new_reference_lines()
  }
  if (isTRUE(draw)) {
    apply_plot_preset(style)
    values <- plot_table$Value
    labels <- truncate_axis_label(plot_table$PlotGroup, width = 32L)
    xlim <- range(c(0, values), finite = TRUE)
    if (!all(is.finite(xlim)) || diff(xlim) <= 0) xlim <- c(0, 1)
    if (identical(value_scale, "proportion")) xlim <- c(0, 1)
    old_mar <- graphics::par("mar")
    on.exit(graphics::par(mar = old_mar), add = TRUE)
    graphics::par(mar = c(5, 11, 4, 2))
    mids <- graphics::barplot(
      height = rev(values),
      names.arg = rev(labels),
      horiz = TRUE,
      las = 1,
      col = rev(plot_table$Color),
      border = NA,
      xlim = xlim,
      xlab = metric_label,
      main = title
    )
    graphics::grid(nx = NULL, ny = NA, col = style$grid)
    if (identical(value_scale, "proportion")) {
      graphics::abline(v = 0.5, lty = 2,
                       col = grDevices::adjustcolor(style$neutral, alpha.f = 0.7))
    }
    graphics::legend(
      "bottomright",
      legend = names(status_cols),
      fill = unname(status_cols),
      border = NA,
      bty = "n",
      cex = 0.76
    )
    invisible(mids)
  }
  invisible(new_mfrm_plot_data(
    "generalizability_design_check",
    list(
      plot = type,
      plot_table = plot_table,
      facet_overview = as.data.frame(x$facet_overview %||% data.frame(),
                                     stringsAsFactors = FALSE),
      interaction_overview = as.data.frame(x$interaction_overview %||% data.frame(),
                                           stringsAsFactors = FALSE),
      highest_order_review = as.data.frame(x$highest_order_review %||% data.frame(),
                                           stringsAsFactors = FALSE),
      overview = as.data.frame(x$overview %||% data.frame(),
                               stringsAsFactors = FALSE),
      metric = metric,
      metric_label = metric_label,
      value_scale = value_scale,
      status_filter = status %||% character(0),
      sort_by = sort_by,
      reading_order = gtheory_design_check_reading_order(),
      guidance = gtheory_design_check_guidance(type, metric),
      figure_recipes = gtheory_design_check_figure_recipes(type, metric),
      interpretation_note = paste(
        "Design-check plots summarize observed crossing and replication.",
        "They do not estimate variance components or guarantee a non-singular mixed model."
      ),
      title = title,
      subtitle = subtitle,
      legend = new_plot_legend(
        label = names(status_cols),
        role = rep("design_status", length(status_cols)),
        aesthetic = rep("fill", length(status_cols)),
        value = unname(status_cols)
      ),
      reference_lines = reference_lines,
      preset = style$name
    )
  ))
}

#' @rdname check_mfrm_generalizability_design
#' @param object Output from `check_mfrm_generalizability_design()`.
#' @param digits Number of digits used by the summary print method.
#' @param ... Reserved for future extensions.
#' @method summary mfrm_generalizability_design_check
#' @export
summary.mfrm_generalizability_design_check <- function(object, digits = 3, ...) {
  if (!inherits(object, "mfrm_generalizability_design_check")) {
    stop("`object` must be output from check_mfrm_generalizability_design().",
         call. = FALSE)
  }
  digits <- max(0L, as.integer(digits[1] %||% 3L))
  if (!is.finite(digits)) digits <- 3L
  out <- list(
    overview = as.data.frame(object$overview %||% data.frame(),
                             stringsAsFactors = FALSE),
    facet_overview = as.data.frame(object$facet_overview %||% data.frame(),
                                   stringsAsFactors = FALSE),
    interaction_overview = as.data.frame(object$interaction_overview %||% data.frame(),
                                         stringsAsFactors = FALSE),
    highest_order_review = as.data.frame(object$highest_order_review %||% data.frame(),
                                         stringsAsFactors = FALSE),
    settings = object$settings %||% list(),
    notes = object$notes %||% character(0),
    digits = digits
  )
  class(out) <- "summary.mfrm_generalizability_design_check"
  out
}

#' @rdname check_mfrm_generalizability_design
#' @method print summary.mfrm_generalizability_design_check
#' @export
print.summary.mfrm_generalizability_design_check <- function(x, ...) {
  digits <- as.integer(x$digits %||% 3L)
  if (!is.finite(digits)) digits <- 3L
  cat("G-study design check\n")
  if (nrow(x$overview) > 0L) {
    print(round_numeric_df(x$overview, digits = digits), row.names = FALSE)
  }
  if (nrow(x$facet_overview) > 0L) {
    cat("\nFacet overview\n")
    print(round_numeric_df(x$facet_overview, digits = digits), row.names = FALSE)
  }
  if (nrow(x$interaction_overview) > 0L) {
    cat("\nRequested interactions\n")
    cols <- intersect(c("Interaction", "ComponentType", "ObservedCells",
                        "CellDensity", "ReplicatedCellRate", "Status",
                        "MainConcern"),
                      names(x$interaction_overview))
    print(round_numeric_df(x$interaction_overview[, cols, drop = FALSE],
                           digits = digits),
          row.names = FALSE)
  }
  if (nrow(x$highest_order_review) > 0L) {
    cat("\nHighest-order cells\n")
    cols <- intersect(c("FullCellFacets", "ObservedCells", "CellDensity",
                        "ReplicatedFullCellRate", "Status", "MainConcern"),
                      names(x$highest_order_review))
    print(round_numeric_df(x$highest_order_review[, cols, drop = FALSE],
                           digits = digits),
          row.names = FALSE)
  }
  if (length(x$notes) > 0L) {
    cat("\nNotes\n")
    for (line in x$notes) cat(" - ", line, "\n", sep = "")
  }
  invisible(x)
}

#' @rdname check_mfrm_generalizability_design
#' @method print mfrm_generalizability_design_check
#' @export
print.mfrm_generalizability_design_check <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
summary.mfrm_generalizability <- function(object, digits = 3, ...) {
  if (!inherits(object, "mfrm_generalizability")) {
    stop("`object` must be output from mfrm_generalizability().", call. = FALSE)
  }
  digits <- max(0L, as.integer(digits[1] %||% 3L))
  if (!is.finite(digits)) digits <- 3L
  runtime <- as.data.frame(object$runtime %||% data.frame(), stringsAsFactors = FALSE)
  design_check <- object$design$design_check %||% NULL
  design_overview <- if (inherits(design_check, "mfrm_generalizability_design_check")) {
    as.data.frame(design_check$overview %||% data.frame(),
                  stringsAsFactors = FALSE)
  } else {
    data.frame()
  }
  overview <- data.frame(
    ObjectFacet = as.character(object$design$object_facet %||% NA_character_),
    RandomFacets = paste(as.character(object$design$random_facets %||% character(0)), collapse = ", "),
    AnalysisRole = as.character(object$design$analysis_role %||%
                                  "observed_score_g_theory_complement"),
    MetricBasis = as.character(object$design$metric_basis %||% "observed_score"),
    ModelScope = as.character(object$design$model_scope %||% "main_effects"),
    RandomInteractions = paste(as.character(object$design$random_interaction_terms %||% character(0)), collapse = ", "),
    G = suppressWarnings(as.numeric(object$coefficients$G[1] %||% NA_real_)),
    Phi = suppressWarnings(as.numeric(object$coefficients$Phi[1] %||% NA_real_)),
    ElapsedSec = if ("ElapsedSec" %in% names(runtime)) {
      suppressWarnings(as.numeric(runtime$ElapsedSec[1]))
    } else {
      NA_real_
    },
    DesignReviewCount = if (nrow(design_overview) > 0L) {
      suppressWarnings(as.integer(design_overview$ReviewCount[1] %||% NA_integer_))
    } else {
      NA_integer_
    },
    DesignSensitivityOnlyCount = if (nrow(design_overview) > 0L) {
      suppressWarnings(as.integer(design_overview$SensitivityOnlyCount[1] %||% NA_integer_))
    } else {
      NA_integer_
    },
    HighestOrderStatus = if (nrow(design_overview) > 0L) {
      as.character(design_overview$HighestOrderStatus[1] %||% NA_character_)
    } else {
      NA_character_
    },
    LmerWarnings = length(as.character(object$design$lmer_warnings %||% character(0))),
    LmerMessages = length(as.character(object$design$lmer_messages %||% character(0))),
    SingularFit = isTRUE(object$design$singular_fit),
    stringsAsFactors = FALSE
  )
  out <- list(
    overview = overview,
    variance_components = as.data.frame(object$variance_components %||% data.frame(), stringsAsFactors = FALSE),
    coefficients = as.data.frame(object$coefficients %||% data.frame(), stringsAsFactors = FALSE),
    design_check_overview = if (inherits(design_check, "mfrm_generalizability_design_check")) {
      as.data.frame(design_check$overview %||% data.frame(),
                    stringsAsFactors = FALSE)
    } else {
      data.frame()
    },
    design_check_facets = if (inherits(design_check, "mfrm_generalizability_design_check")) {
      as.data.frame(design_check$facet_overview %||% data.frame(),
                    stringsAsFactors = FALSE)
    } else {
      data.frame()
    },
    design_check_interactions = if (inherits(design_check, "mfrm_generalizability_design_check")) {
      as.data.frame(design_check$interaction_overview %||% data.frame(),
                    stringsAsFactors = FALSE)
    } else {
      data.frame()
    },
    design_check_highest_order = if (inherits(design_check, "mfrm_generalizability_design_check")) {
      as.data.frame(design_check$highest_order_review %||% data.frame(),
                    stringsAsFactors = FALSE)
    } else {
      data.frame()
    },
    runtime = runtime,
    design = object$design %||% list(),
    notes = gtheory_interpretation_note(),
    digits = digits
  )
  class(out) <- "summary.mfrm_generalizability"
  out
}

#' @export
print.summary.mfrm_generalizability <- function(x, ...) {
  digits <- as.integer(x$digits %||% 3L)
  if (!is.finite(digits)) digits <- 3L
  cat("Observed-score Generalizability-theory Summary\n")
  if (!is.null(x$overview) && nrow(x$overview) > 0L) {
    print(round_numeric_df(as.data.frame(x$overview), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$runtime) && nrow(x$runtime) > 0L) {
    cat("\nRuntime\n")
    print(round_numeric_df(as.data.frame(x$runtime), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$variance_components) && nrow(x$variance_components) > 0L) {
    cat("\nVariance components\n")
    print(round_numeric_df(as.data.frame(x$variance_components), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$coefficients) && nrow(x$coefficients) > 0L) {
    cat("\nCoefficients\n")
    print(round_numeric_df(as.data.frame(x$coefficients), digits = digits), row.names = FALSE)
  }
  if (length(x$notes) > 0L) {
    cat("\nNotes\n")
    for (line in x$notes) cat(" - ", line, "\n", sep = "")
  }
  invisible(x)
}

#' @export
summary.mfrm_generalizability_bootstrap <- function(object, digits = 3, ...) {
  if (!inherits(object, "mfrm_generalizability_bootstrap")) {
    stop("`object` must be output from bootstrap_mfrm_generalizability().",
         call. = FALSE)
  }
  digits <- max(0L, as.integer(digits[1] %||% 3L))
  if (!is.finite(digits)) digits <- 3L
  intervals <- as.data.frame(object$intervals %||% data.frame(),
                             stringsAsFactors = FALSE)
  key_metrics <- intervals[
    intervals$Target == "coefficient" &
      intervals$Metric %in% c("G", "Phi"),
    ,
    drop = FALSE
  ]
  out <- list(
    overview = as.data.frame(object$overview %||% data.frame(),
                             stringsAsFactors = FALSE),
    key_metrics = key_metrics,
    intervals = intervals,
    failures = as.data.frame(object$failures %||% data.frame(),
                             stringsAsFactors = FALSE),
    settings = object$settings %||% list(),
    terminology = object$terminology %||% character(0),
    digits = digits
  )
  class(out) <- "summary.mfrm_generalizability_bootstrap"
  out
}

#' @export
print.summary.mfrm_generalizability_bootstrap <- function(x, ...) {
  digits <- as.integer(x$digits %||% 3L)
  if (!is.finite(digits)) digits <- 3L
  cat("Observed-data bootstrap G-study uncertainty summary\n")
  if (nrow(x$overview) > 0L) {
    print(round_numeric_df(x$overview, digits = digits), row.names = FALSE)
  }
  if (nrow(x$key_metrics) > 0L) {
    cat("\nG/Phi intervals\n")
    cols <- intersect(c("Metric", "PointEstimate", "Mean", "SD",
                        "Lower", "Upper", "SuccessfulReps"),
                      names(x$key_metrics))
    print(round_numeric_df(x$key_metrics[, cols, drop = FALSE], digits = digits),
          row.names = FALSE)
  }
  if (nrow(x$failures) > 0L) {
    cat("\nFailed replicates\n")
    print(utils::head(x$failures, 5L), row.names = FALSE)
  }
  if (length(x$terminology) > 0L) {
    cat("\nNotes\n")
    for (line in x$terminology) cat(" - ", line, "\n", sep = "")
  }
  invisible(x)
}

#' @export
print.mfrm_generalizability_bootstrap <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
summary.mfrm_generalizability_comparison <- function(object, digits = 3, ...) {
  if (!inherits(object, "mfrm_generalizability_comparison")) {
    stop("`object` must be output from compare_mfrm_generalizability().",
         call. = FALSE)
  }
  digits <- max(0L, as.integer(digits[1] %||% 3L))
  if (!is.finite(digits)) digits <- 3L
  design_checks <- object$design_checks %||% list()
  out <- list(
    overview = as.data.frame(object$summary %||% data.frame(),
                             stringsAsFactors = FALSE),
    comparison_review = as.data.frame(object$comparison_review %||% data.frame(),
                                      stringsAsFactors = FALSE),
    coefficients = as.data.frame(object$coefficients %||% data.frame(),
                                 stringsAsFactors = FALSE),
    variance_components = as.data.frame(object$variance_components %||%
                                          data.frame(),
                                        stringsAsFactors = FALSE),
    variance_delta = as.data.frame(object$variance_delta %||% data.frame(),
                                   stringsAsFactors = FALSE),
    d_study = as.data.frame(object$d_study %||% data.frame(),
                            stringsAsFactors = FALSE),
    design_check_overview = as.data.frame(design_checks$overview %||%
                                            data.frame(),
                                          stringsAsFactors = FALSE),
    design_check_raw_overview = as.data.frame(design_checks$overview_raw %||%
                                                data.frame(),
                                              stringsAsFactors = FALSE),
    design_check_facets = as.data.frame(design_checks$facet_overview %||%
                                          data.frame(),
                                        stringsAsFactors = FALSE),
    design_check_interactions = as.data.frame(design_checks$interaction_overview %||%
                                                data.frame(),
                                              stringsAsFactors = FALSE),
    design_check_highest_order = as.data.frame(design_checks$highest_order_review %||%
                                                 data.frame(),
                                               stringsAsFactors = FALSE),
    warnings = as.data.frame(object$warnings %||% data.frame(),
                             stringsAsFactors = FALSE),
    notes = c(
      gtheory_interpretation_note(),
      "The comparison review is a reporting and sensitivity-review table, not an automatic model-selection rule."
    ),
    digits = digits
  )
  class(out) <- "summary.mfrm_generalizability_comparison"
  out
}

#' @export
print.summary.mfrm_generalizability_comparison <- function(x, ...) {
  digits <- as.integer(x$digits %||% 3L)
  if (!is.finite(digits)) digits <- 3L
  cat("Observed-score G-study comparison summary\n")
  if (nrow(x$overview) > 0L) {
    print(round_numeric_df(x$overview, digits = digits), row.names = FALSE)
  }
  if (nrow(x$comparison_review) > 0L) {
    cat("\nComparison review\n")
    keep <- intersect(c("Checkpoint", "Status", "Evidence", "NextAction"),
                      names(x$comparison_review))
    print(x$comparison_review[, keep, drop = FALSE], row.names = FALSE)
  }
  if (nrow(x$coefficients) > 0L) {
    cat("\nCoefficient rows\n")
    keep <- intersect(c("Model", "G", "Phi", "RelativeErrorVariance",
                        "AbsoluteErrorVariance"),
                      names(x$coefficients))
    print(round_numeric_df(x$coefficients[, keep, drop = FALSE], digits = digits),
          row.names = FALSE)
  }
  if (nrow(x$warnings) > 0L) {
    cat("\nWarnings\n")
    print(x$warnings, row.names = FALSE)
  }
  if (length(x$notes) > 0L) {
    cat("\nNotes\n")
    for (line in x$notes) cat(" - ", line, "\n", sep = "")
  }
  invisible(x)
}

#' @export
print.mfrm_generalizability_comparison <- function(x, ...) {
  cat("mfrmr observed-score G-study sensitivity comparison\n")
  cat("  Random interactions:",
      x$summary$RandomInteractions[1] %||% NA_character_, "\n\n")
  print.data.frame(x$summary, row.names = FALSE, ...)
  review <- as.data.frame(x$comparison_review %||% data.frame(),
                          stringsAsFactors = FALSE)
  if (nrow(review) > 0L) {
    cat("\nComparison review\n")
    review_cols <- intersect(c("Checkpoint", "Status", "Evidence", "NextAction"),
                             names(review))
    print.data.frame(review[, review_cols, drop = FALSE],
                     row.names = FALSE, ...)
  }
  cat("\nCoefficient rows\n")
  print.data.frame(x$coefficients[, c("Model", "G", "Phi",
                                      "RelativeErrorVariance",
                                      "AbsoluteErrorVariance"),
                                  drop = FALSE],
                   row.names = FALSE, ...)
  if (nrow(x$warnings) > 0L) {
    cat("\nWarnings\n")
    print.data.frame(x$warnings, row.names = FALSE, ...)
  }
  cat("\nInterpretation boundary\n")
  cat("  G and Phi are observed-score G-theory coefficients, not MFRM separation reliability.\n")
  invisible(x)
}

#' @export
print.mfrm_generalizability <- function(x, ...) {
  cat("Observed-score generalizability-theory decomposition\n")
  cat(sprintf("  Object of measurement: %s\n",
              x$design$object_facet))
  cat("  Analysis role: observed-score G-theory complement to MFRM\n")
  cat("  Metric basis: observed Score column, not fitted logit measures\n")
  cat(sprintf("  Random facets: %s\n",
              paste(x$design$random_facets, collapse = ", ")))
  cat(sprintf("  Model scope: %s\n",
              x$design$model_scope %||% "main_effects"))
  if (length(x$design$random_interaction_terms %||% character(0)) > 0L) {
    cat(sprintf("  Random interactions: %s\n",
                paste(x$design$random_interaction_terms, collapse = ", ")))
  }
  runtime <- as.data.frame(x$runtime %||% data.frame(), stringsAsFactors = FALSE)
  if ("ElapsedSec" %in% names(runtime)) {
    cat(sprintf("  Elapsed: %.3f sec\n",
                suppressWarnings(as.numeric(runtime$ElapsedSec[1] %||% NA_real_))))
  }
  design_check <- x$design$design_check %||% NULL
  if (inherits(design_check, "mfrm_generalizability_design_check")) {
    design_overview <- as.data.frame(design_check$overview %||% data.frame(),
                                     stringsAsFactors = FALSE)
    if (nrow(design_overview) > 0L) {
      cat(sprintf(
        "  Design check: %s review signal(s), %s sensitivity-only signal(s); highest-order cells = %s\n",
        design_overview$ReviewCount[1] %||% NA_integer_,
        design_overview$SensitivityOnlyCount[1] %||% NA_integer_,
        design_overview$HighestOrderStatus[1] %||% NA_character_
      ))
    }
  }
  cat("\nVariance components\n")
  print(x$variance_components, row.names = FALSE)
  cat(sprintf("\nG (relative): %.3f | Phi (absolute): %.3f\n",
              as.numeric(x$coefficients$G),
              as.numeric(x$coefficients$Phi)))
  if (isTRUE(x$design$singular_fit)) {
    cat("\nlme4 reported a singular random-effects fit; review boundary variance components.\n")
    if (identical(x$design$model_scope %||% "main_effects", "interaction_expanded")) {
      cat("Treat this interaction-expanded decomposition as sensitivity evidence, not a definitive variance partition.\n")
    }
  }
  if (length(x$design$lmer_warnings) > 0L) {
    cat(sprintf("\n%d lme4 warning(s) suppressed; results may be unstable.\n",
                length(x$design$lmer_warnings)))
  }
  if (length(x$design$lmer_messages %||% character(0)) > 0L) {
    cat(sprintf("\n%d lme4 message(s) suppressed; review `design$lmer_messages`.\n",
                length(x$design$lmer_messages)))
  }
  cat("\nInterpretation boundary: G/Phi are observed-score G-theory coefficients, not MFRM separation reliability.\n")
  invisible(x)
}
