#' List available simulation metrics
#'
#' @param x A simulation specification, simulation summary table, simulation
#'   evaluation object, or data frame.
#' @param component Optional component to inspect. Defaults to the most useful
#'   table for each object class: design-grid summaries for arbitrary
#'   specifications, `design_summary` for [evaluate_mfrm_design()],
#'   `detection_summary` for [evaluate_mfrm_signal_detection()], and
#'   `fit_summary` for [evaluate_mfrm_bias_detection()].
#' @param design_id Optional design rows used when `x` is an arbitrary
#'   simulation specification.
#'
#' @return A data frame with metric names, source component, role, direction,
#'   and suggested-default flags.
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 20,
#'   facets = list(Rater = c(2, 4), Criteria = c(2, 3), Task = c(2, 4)),
#'   facets_per_person = list(Rater = c(1, 2), Task = 2),
#'   score_levels = 4
#' )
#' list_mfrm_sim_metrics(spec)
#' @export
list_mfrm_sim_metrics <- function(x, component = NULL, design_id = NULL) {
  source <- mfrm_sim_dashboard_source(x, component = component, design_id = design_id)
  mfrm_sim_metric_catalog(source$table, component = source$component, requires_fit = source$requires_fit)
}

#' Plot a multi-metric simulation dashboard
#'
#' @param x A simulation specification, grid summary, simulation evaluation
#'   object, or data frame.
#' @param metrics Character vector of numeric metric columns to plot. If
#'   omitted, a conservative default set is chosen from
#'   [list_mfrm_sim_metrics()].
#' @param x_var Design or data column used for the horizontal axis. Defaults to
#'   `n_Rater`, `n_rater`, the first `n_*` column, or `design_id`.
#' @param group_var Optional design or data column used for grouped lines.
#' @param panel_var Optional design or data column used for panels in addition
#'   to metric panels.
#' @param facet Optional facet filter when the source table has a `Facet`
#'   column. The default uses `Rater` when present, otherwise the first
#'   non-person facet. Use `facet = "all"` to keep all facets.
#' @param component Optional component to plot. See [list_mfrm_sim_metrics()].
#' @param design_id Optional design rows used when `x` is an arbitrary
#'   simulation specification.
#' @param draw Whether to draw a base R multi-panel plot.
#' @param scales Y-axis scaling. `"free_y"` gives each metric its own y-axis;
#'   `"fixed"` uses a common y-axis across metrics.
#' @param ... Additional arguments passed to the base plotting call.
#'
#' @details
#' This dashboard separates two planning stages. Before fitting, arbitrary
#' design-grid summaries can plot workload and connectivity metrics such as
#' `MeanObsPerPerson`, `Observations`, and `MinPairCoverage`. After repeated
#' fitting, evaluation objects can plot empirical performance metrics such as
#' `MeanReliability`, `MeanSeparation`, `MeanSeverityRMSE`,
#' `MeanUnderfitRate`, or `ConvergenceRate`.
#'
#' The returned `mfrm_plot_data` payload contains a long-form data frame with
#' `.metric`, `.value`, `.x`, `.group`, and `.panel` columns so users can build
#' their own ggplot2, lattice, or spreadsheet visualizations.
#'
#' In practice, useful dashboards usually combine one metric from each
#' decision category:
#' - response burden/connectivity: `Observations`, `MeanObsPerPerson`,
#'   `MinPairCoverage`, `CompletePairCoverageRate`
#' - measurement precision: `MeanReliability`, `MeanSeparation`, `MeanStrata`
#' - recovery error: `MeanSeverityRMSE`, `MeanSeverityBias`
#' - fit and flag direction: `MeanUnderfitRate`, `MeanOverfitRate`,
#'   `MeanMnSqMisfitRate`
#' - computational stability: `ConvergenceRate`, `MeanElapsedSec`
#'
#' @return Invisibly, an `mfrm_plot_data` object.
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 20,
#'   facets = list(Rater = c(2, 4), Criteria = c(2, 3), Task = c(2, 4)),
#'   facets_per_person = list(Rater = c(1, 2), Task = 2),
#'   score_levels = 4
#' )
#' dash <- plot_mfrm_sim_dashboard(
#'   spec,
#'   metrics = c("MeanObsPerPerson", "MinPairCoverage"),
#'   x_var = "n_Rater",
#'   group_var = "n_Task",
#'   panel_var = "n_Criteria",
#'   draw = FALSE
#' )
#' head(dash$data$data)
#' @export
plot_mfrm_sim_dashboard <- function(x,
                                    metrics = NULL,
                                    x_var = NULL,
                                    group_var = NULL,
                                    panel_var = NULL,
                                    facet = NULL,
                                    component = NULL,
                                    design_id = NULL,
                                    draw = TRUE,
                                    scales = c("free_y", "fixed"),
                                    ...) {
  scales <- match.arg(scales)
  source <- mfrm_sim_dashboard_source(x, component = component, design_id = design_id)
  tbl <- as.data.frame(source$table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0L) stop("No simulation rows are available for dashboard plotting.", call. = FALSE)

  catalog <- mfrm_sim_metric_catalog(tbl, component = source$component, requires_fit = source$requires_fit)
  if (is.null(metrics)) {
    metrics <- catalog$Metric[catalog$SuggestedDefault %in% TRUE]
    if (length(metrics) == 0L) metrics <- utils::head(catalog$Metric, 4L)
  }
  metrics <- unique(as.character(metrics))
  missing_metrics <- setdiff(metrics, names(tbl))
  if (length(missing_metrics) > 0L) {
    stop("`metrics` are not columns in the source table: ", paste(missing_metrics, collapse = ", "), ".", call. = FALSE)
  }
  non_numeric <- metrics[!vapply(tbl[metrics], is.numeric, logical(1))]
  if (length(non_numeric) > 0L) {
    stop("`metrics` must identify numeric columns: ", paste(non_numeric, collapse = ", "), ".", call. = FALSE)
  }

  if ("Facet" %in% names(tbl)) {
    if (is.null(facet)) {
      facet <- mfrm_sim_dashboard_default_facet(tbl)
    }
    if (!identical(tolower(as.character(facet[1])), "all")) {
      facet <- as.character(facet[1])
      tbl <- tbl[as.character(tbl$Facet) == facet, , drop = FALSE]
      if (nrow(tbl) == 0L) stop("No rows are available for `facet = \"", facet, "\"`.", call. = FALSE)
    }
  }

  if (is.null(x_var)) x_var <- mfrm_sim_dashboard_default_x(tbl)
  x_var <- as.character(x_var[1])
  group_var <- if (is.null(group_var)) NULL else as.character(group_var[1])
  panel_var <- if (is.null(panel_var)) NULL else as.character(panel_var[1])
  mfrm_sim_dashboard_require_column(tbl, x_var, "x_var")
  if (!is.null(group_var)) mfrm_sim_dashboard_require_column(tbl, group_var, "group_var")
  if (!is.null(panel_var)) mfrm_sim_dashboard_require_column(tbl, panel_var, "panel_var")

  plot_tbl <- mfrm_sim_dashboard_long_table(
    tbl = tbl,
    metrics = metrics,
    x_var = x_var,
    group_var = group_var,
    panel_var = panel_var
  )
  if (nrow(plot_tbl) == 0L) stop("No finite metric values are available for dashboard plotting.", call. = FALSE)

  if (isTRUE(draw)) {
    mfrm_sim_dashboard_draw(plot_tbl, x_var = x_var, group_var = group_var, scales = scales, ...)
  }

  invisible(new_mfrm_plot_data(
    "simulation_dashboard",
    list(
      data = plot_tbl,
      source_data = tbl,
      metric_catalog = catalog,
      metrics = metrics,
      x_var = x_var,
      group_var = group_var,
      panel_var = panel_var,
      facet = facet,
      component = source$component,
      requires_fit = source$requires_fit,
      title = "Simulation metric dashboard"
    )
  ))
}

mfrm_sim_dashboard_source <- function(x, component = NULL, design_id = NULL) {
  if (inherits(x, "mfrm_arbitrary_sim_spec")) {
    return(list(
      table = summarize_mfrm_sim_grid(x, design_id = design_id),
      component = "design_grid",
      requires_fit = FALSE
    ))
  }
  if (inherits(x, "mfrm_sim_grid_summary")) {
    return(list(table = as.data.frame(x, stringsAsFactors = FALSE), component = "design_grid", requires_fit = FALSE))
  }
  if (inherits(x, "mfrm_design_evaluation")) {
    component <- component %||% "design_summary"
    return(list(table = as.data.frame(x, component = component), component = component, requires_fit = TRUE))
  }
  if (inherits(x, "summary.mfrm_design_evaluation")) {
    component <- component %||% "design_summary"
    return(list(table = as.data.frame(x, component = component), component = component, requires_fit = TRUE))
  }
  if (inherits(x, "mfrm_signal_detection")) {
    component <- component %||% "detection_summary"
    return(list(table = as.data.frame(x, component = component), component = component, requires_fit = TRUE))
  }
  if (inherits(x, "summary.mfrm_signal_detection")) {
    component <- component %||% "detection_summary"
    return(list(table = as.data.frame(x, component = component), component = component, requires_fit = TRUE))
  }
  if (inherits(x, "mfrm_bias_detection")) {
    component <- component %||% "fit_summary"
    return(list(table = as.data.frame(x, component = component), component = component, requires_fit = TRUE))
  }
  if (inherits(x, "summary.mfrm_bias_detection")) {
    component <- component %||% "fit_summary"
    return(list(table = as.data.frame(x, component = component), component = component, requires_fit = TRUE))
  }
  if (is.data.frame(x)) {
    return(list(table = as.data.frame(x, stringsAsFactors = FALSE), component = component %||% "data", requires_fit = NA))
  }
  stop("`x` must be a simulation specification, simulation evaluation object, or data frame.", call. = FALSE)
}

mfrm_sim_metric_catalog <- function(tbl, component, requires_fit) {
  tbl <- as.data.frame(tbl, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0L) {
    return(data.frame(
      Metric = character(), Component = character(), Role = character(),
      HigherIsBetter = logical(), RequiresFitting = logical(),
      SuggestedDefault = logical(), stringsAsFactors = FALSE
    ))
  }
  numeric_cols <- names(tbl)[vapply(tbl, is.numeric, logical(1))]
  metric_cols <- setdiff(numeric_cols, mfrm_sim_dashboard_non_metric_columns(tbl))
  rows <- lapply(metric_cols, function(metric) {
    meta <- mfrm_sim_metric_metadata(metric, component = component)
    data.frame(
      Metric = metric,
      Component = component,
      Role = meta$role,
      HigherIsBetter = meta$higher_is_better,
      RequiresFitting = isTRUE(requires_fit),
      SuggestedDefault = mfrm_sim_metric_is_default(metric, component),
      stringsAsFactors = FALSE
    )
  })
  if (length(rows) == 0L) {
    return(data.frame(
      Metric = character(), Component = character(), Role = character(),
      HigherIsBetter = logical(), RequiresFitting = logical(),
      SuggestedDefault = logical(), stringsAsFactors = FALSE
    ))
  }
  tibble::as_tibble(dplyr::bind_rows(rows))
}

mfrm_sim_metric_metadata <- function(metric, component) {
  lower <- tolower(metric)
  role <- "custom_numeric"
  higher <- NA
  if (grepl("reliability|separation|strata|coverage|convergencerate|power|screenrate|detected", lower)) {
    role <- "measurement_quality"
    higher <- TRUE
  }
  if (grepl("rmse|bias|misfit|underfit|overfit|falsepositive|elapsed|observations|obsperperson", lower)) {
    role <- "burden_or_error"
    higher <- FALSE
  }
  if (grepl("infit|outfit", lower) && !grepl("misfit", lower)) {
    role <- "fit_mean_square"
    higher <- NA
  }
  if (identical(component, "design_grid") && grepl("coverage", lower)) {
    role <- "design_connectivity"
    higher <- TRUE
  }
  list(role = role, higher_is_better = higher)
}

mfrm_sim_metric_is_default <- function(metric, component) {
  defaults <- switch(
    component,
    design_grid = c("MeanObsPerPerson", "MinPairCoverage", "Observations"),
    design_summary = c("MeanReliability", "MeanSeverityRMSE", "ConvergenceRate", "MeanUnderfitRate"),
    fit_summary = c("MeanReliability", "MeanSeparation", "MeanInfit", "MeanOutfit"),
    detection_summary = c("DIFPower", "BiasScreenRate", "DIFFalsePositiveRate", "BiasScreenFalsePositiveRate"),
    target_summary = c("BiasScreenRate", "MeanTargetBias", "MeanBiasScreenFalsePositiveRate"),
    character()
  )
  metric %in% defaults
}

mfrm_sim_dashboard_non_metric_columns <- function(tbl) {
  unique(c(
    "design_id", "rep", "Reps", "Persons", "Facets", "ScoreLevels",
    "Facet", "Level", "Target", "FacetA", "FacetB", "LevelA", "LevelB",
    "FacetPair", "RunOK", "Converged",
    grep("^n_", names(tbl), value = TRUE),
    grep("_per_person$", names(tbl), value = TRUE),
    "n_person", "n_rater", "n_criterion", "raters_per_person"
  ))
}

mfrm_sim_dashboard_default_x <- function(tbl) {
  for (candidate in c("n_Rater", "n_rater", "n_person", "design_id")) {
    if (candidate %in% names(tbl)) return(candidate)
  }
  n_cols <- grep("^n_", names(tbl), value = TRUE)
  if (length(n_cols) > 0L) return(n_cols[1])
  numeric_cols <- names(tbl)[vapply(tbl, is.numeric, logical(1))]
  if (length(numeric_cols) > 0L) return(numeric_cols[1])
  stop("Could not infer `x_var`; please supply a column name.", call. = FALSE)
}

mfrm_sim_dashboard_default_facet <- function(tbl) {
  facets <- unique(as.character(tbl$Facet))
  if ("Rater" %in% facets) return("Rater")
  non_person <- setdiff(facets, "Person")
  if (length(non_person) > 0L) return(non_person[1])
  facets[1]
}

mfrm_sim_dashboard_require_column <- function(tbl, col, arg_name) {
  if (!col %in% names(tbl)) {
    stop(
      "`", arg_name, "` must name a column in the simulation table. ",
      "Available columns include: ", paste(names(tbl), collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(col)
}

mfrm_sim_dashboard_long_table <- function(tbl, metrics, x_var, group_var = NULL, panel_var = NULL) {
  rows <- vector("list", length(metrics))
  x_raw <- tbl[[x_var]]
  x_num <- suppressWarnings(as.numeric(x_raw))
  if (all(is.finite(x_num))) {
    x_plot <- x_num
    x_label <- as.character(x_raw)
  } else {
    x_factor <- factor(as.character(x_raw), levels = unique(as.character(x_raw)))
    x_plot <- as.integer(x_factor)
    x_label <- as.character(x_factor)
  }
  for (i in seq_along(metrics)) {
    metric <- metrics[i]
    rows[[i]] <- cbind(
      tbl,
      data.frame(
        .metric = metric,
        .value = suppressWarnings(as.numeric(tbl[[metric]])),
        .x = x_plot,
        .x_label = x_label,
        .group = if (is.null(group_var)) "All designs" else as.character(tbl[[group_var]]),
        .panel = if (is.null(panel_var)) "All designs" else as.character(tbl[[panel_var]]),
        stringsAsFactors = FALSE
      )
    )
  }
  out <- tibble::as_tibble(dplyr::bind_rows(rows))
  out[is.finite(out$.x) & is.finite(out$.value), , drop = FALSE]
}

mfrm_sim_dashboard_draw <- function(plot_tbl, x_var, group_var = NULL, scales = "free_y", ...) {
  dots <- list(...)
  panel_keys <- unique(paste(plot_tbl$.metric, plot_tbl$.panel, sep = "||"))
  groups <- unique(as.character(plot_tbl$.group))
  cols <- grDevices::hcl.colors(max(3L, length(groups)), "Dark 3")[seq_along(groups)]
  names(cols) <- groups
  fixed_ylim <- range(plot_tbl$.value, finite = TRUE)
  if (diff(fixed_ylim) == 0) fixed_ylim <- fixed_ylim + c(-0.5, 0.5)

  opar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(opar), add = TRUE)
  graphics::par(mfrow = grDevices::n2mfrow(length(panel_keys)))
  for (key in panel_keys) {
    key_parts <- strsplit(key, "||", fixed = TRUE)[[1]]
    metric <- key_parts[1]
    panel <- key_parts[2]
    slice <- plot_tbl[plot_tbl$.metric == metric & plot_tbl$.panel == panel, , drop = FALSE]
    y_lim <- if (identical(scales, "fixed")) fixed_ylim else range(slice$.value, finite = TRUE)
    if (diff(y_lim) == 0) y_lim <- y_lim + c(-0.5, 0.5)
    x_lim <- range(slice$.x, finite = TRUE)
    if (diff(x_lim) == 0) x_lim <- x_lim + c(-0.5, 0.5)
    x_axis <- unique(slice[, c(".x", ".x_label"), drop = FALSE])
    x_axis <- x_axis[order(x_axis$.x), , drop = FALSE]
    x_axis_num <- suppressWarnings(as.numeric(x_axis$.x_label))
    custom_x_axis <- !all(is.finite(x_axis_num) & abs(x_axis_num - x_axis$.x) < sqrt(.Machine$double.eps))
    plot_args <- list(
      x = NA_real_,
      y = NA_real_,
      xlim = x_lim,
      ylim = y_lim,
      xlab = x_var,
      ylab = metric,
      main = if (identical(panel, "All designs")) metric else paste(metric, "|", panel)
    )
    plot_args[names(dots)] <- dots
    if (isTRUE(custom_x_axis) && is.null(plot_args$xaxt)) plot_args$xaxt <- "n"
    do.call(graphics::plot, plot_args)
    if (isTRUE(custom_x_axis) && identical(plot_args$xaxt, "n")) {
      graphics::axis(1, at = x_axis$.x, labels = x_axis$.x_label)
    }
    for (group in groups) {
      group_tbl <- slice[as.character(slice$.group) == group, , drop = FALSE]
      if (nrow(group_tbl) == 0L) next
      group_tbl <- stats::aggregate(
        x = list(.value = group_tbl$.value),
        by = list(.x = group_tbl$.x),
        FUN = mean,
        na.rm = TRUE
      )
      group_tbl <- group_tbl[order(group_tbl$.x), , drop = FALSE]
      graphics::lines(group_tbl$.x, group_tbl$.value, col = cols[[group]], lwd = 2)
      graphics::points(group_tbl$.x, group_tbl$.value, col = cols[[group]], pch = 19)
    }
    if (!is.null(group_var) && length(groups) > 1L) {
      graphics::legend("topright", legend = paste(group_var, groups, sep = "="), col = cols, lty = 1, pch = 19, bty = "n")
    }
  }
  invisible(NULL)
}
