new_plot_legend <- function(label = character(),
                            role = character(),
                            aesthetic = character(),
                            value = character()) {
  data.frame(
    label = as.character(label),
    role = as.character(role),
    aesthetic = as.character(aesthetic),
    value = as.character(value),
    stringsAsFactors = FALSE
  )
}

new_reference_lines <- function(axis = character(),
                                value = numeric(),
                                label = character(),
                                linetype = character(),
                                role = character()) {
  data.frame(
    axis = as.character(axis),
    value = suppressWarnings(as.numeric(value)),
    label = as.character(label),
    linetype = as.character(linetype),
    role = as.character(role),
    stringsAsFactors = FALSE
  )
}

normalize_plot_legend <- function(legend) {
  empty <- new_plot_legend()
  if (is.null(legend)) return(empty)
  if (is.character(legend)) {
    return(new_plot_legend(
      label = legend,
      role = rep("group", length(legend)),
      aesthetic = rep("text", length(legend)),
      value = rep("", length(legend))
    ))
  }
  if (is.data.frame(legend)) {
    out <- legend
  } else if (is.list(legend)) {
    out <- tryCatch(as.data.frame(legend, stringsAsFactors = FALSE), error = function(e) empty)
  } else {
    return(empty)
  }
  for (nm in names(empty)) {
    if (!nm %in% names(out)) out[[nm]] <- empty[[nm]]
  }
  out <- out[, names(empty), drop = FALSE]
  out[] <- lapply(out, as.character)
  out
}

normalize_reference_lines <- function(reference_lines) {
  empty <- new_reference_lines()
  if (is.null(reference_lines)) return(empty)
  if (is.data.frame(reference_lines)) {
    out <- reference_lines
  } else if (is.list(reference_lines)) {
    out <- tryCatch(as.data.frame(reference_lines, stringsAsFactors = FALSE), error = function(e) empty)
  } else {
    return(empty)
  }
  for (nm in names(empty)) {
    if (!nm %in% names(out)) out[[nm]] <- empty[[nm]]
  }
  out <- out[, names(empty), drop = FALSE]
  out$axis <- as.character(out$axis)
  out$value <- suppressWarnings(as.numeric(out$value))
  out$label <- as.character(out$label)
  out$linetype <- as.character(out$linetype)
  out$role <- as.character(out$role)
  out
}

standardize_plot_payload <- function(name, data) {
  if (is.null(data)) {
    data <- list()
  } else if (is.data.frame(data) || !is.list(data)) {
    data <- list(data = data)
  }
  data$plot_name <- data$plot_name %||% name
  data$title <- data$title %||% NULL
  data$subtitle <- data$subtitle %||% NULL
  data$legend <- normalize_plot_legend(data$legend %||% NULL)
  data$reference_lines <- normalize_reference_lines(data$reference_lines %||% NULL)
  data
}

new_mfrm_plot_data <- function(name, data) {
  out <- list(name = name, data = standardize_plot_payload(name, data))
  class(out) <- c("mfrm_plot_data", class(out))
  out
}

#' @export
print.mfrm_plot_data <- function(x, ...) {
  data <- x$data %||% list()
  cat("<mfrm_plot_data>\n")
  cat("  name     : ", x$name %||% "<unnamed>", "\n", sep = "")
  if (!is.null(data$title) && nzchar(data$title)) {
    cat("  title    : ", data$title, "\n", sep = "")
  }
  if (!is.null(data$subtitle) && nzchar(data$subtitle)) {
    cat("  subtitle : ", data$subtitle, "\n", sep = "")
  }
  data_slots <- setdiff(
    names(data),
    c("title", "subtitle", "legend", "reference_lines")
  )
  if (length(data_slots) > 0L) {
    cat("  data     :\n", sep = "")
    for (slot in data_slots) {
      val <- data[[slot]]
      shape <- if (is.data.frame(val)) {
        sprintf("data.frame [%d x %d]", nrow(val), ncol(val))
      } else if (is.matrix(val)) {
        sprintf("matrix [%d x %d]", nrow(val), ncol(val))
      } else if (is.list(val)) {
        sprintf("list (%d slots)", length(val))
      } else if (is.atomic(val)) {
        sprintf("%s [%d]", typeof(val), length(val))
      } else {
        class(val)[1]
      }
      cat("    $", slot, " : ", shape, "\n", sep = "")
    }
  }
  legend <- data$legend
  if (!is.null(legend) && length(legend) > 0L) {
    n_items <- if (is.list(legend) && !is.null(legend$labels)) {
      length(legend$labels)
    } else {
      length(legend)
    }
    cat("  legend   : ", n_items, " entries\n", sep = "")
  }
  ref_lines <- data$reference_lines
  if (!is.null(ref_lines) && length(ref_lines) > 0L) {
    n_ref <- if (is.data.frame(ref_lines)) nrow(ref_lines) else length(ref_lines)
    cat("  ref lines: ", n_ref, "\n", sep = "")
  }
  cat("Re-render via ggplot2 / plotly using `x$data`; or pass the\n")
  cat("originating `draw = FALSE` plot helper its inverse to draw it.\n")
  invisible(x)
}

as_mfrm_plot_data_object <- function(x, type = NULL, ...) {
  if (inherits(x, "mfrm_plot_data")) {
    return(x)
  }
  dots <- list(...)
  if (!is.null(type)) {
    dots$type <- type
  }
  plot_args <- c(list(x = x, draw = FALSE), dots)
  out <- tryCatch(
    do.call(plot, plot_args),
    error = function(e) {
      stop(
        "`x` must be an `mfrm_plot_data` object or an object whose ",
        "`plot()` method supports `draw = FALSE`. Plotting failed: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )
  if (!inherits(out, "mfrm_plot_data")) {
    stop(
      "`plot(..., draw = FALSE)` must return an `mfrm_plot_data` object.",
      call. = FALSE
    )
  }
  out
}

plot_component_role <- function(name, value) {
  name <- as.character(name)
  if (name %in% c("plot", "plot_long", "pathway_long", "information_long",
                  "surface", "data", "table", "matrix")) {
    return("primary_data")
  }
  if (grepl("annotation|reference_lines|boundary_lines", name)) {
    return("annotation")
  }
  if (grepl("setting|threshold|range|level|direction|preset|top_n", name)) {
    return("settings")
  }
  if (grepl("legend|style|palette", name)) {
    return("style")
  }
  if (grepl("summary|status|flag|overview|guide|policy|caveat|note", name)) {
    return("summary_or_guidance")
  }
  if (grepl("fit|misfit|infit|outfit|df_sensitivity", name)) {
    return("fit_review")
  }
  if (grepl("probabilit|curve|ogive|information|sem|theta|category", name)) {
    return("curve_data")
  }
  if (is.matrix(value)) {
    return("matrix_data")
  }
  if (is.data.frame(value)) {
    return("table_data")
  }
  if (is.list(value)) {
    return("metadata")
  }
  "scalar_or_vector"
}

plot_component_shape <- function(value) {
  if (is.data.frame(value)) {
    return(list(
      object_type = "data.frame",
      rows = nrow(value),
      columns = ncol(value),
      length = length(value),
      column_names = paste(names(value), collapse = ", ")
    ))
  }
  if (is.matrix(value)) {
    return(list(
      object_type = "matrix",
      rows = nrow(value),
      columns = ncol(value),
      length = length(value),
      column_names = paste(colnames(value) %||% character(0), collapse = ", ")
    ))
  }
  if (is.list(value)) {
    return(list(
      object_type = paste0("list:", class(value)[1]),
      rows = NA_integer_,
      columns = length(value),
      length = length(value),
      column_names = paste(names(value) %||% character(0), collapse = ", ")
    ))
  }
  list(
    object_type = typeof(value),
    rows = NA_integer_,
    columns = NA_integer_,
    length = length(value),
    column_names = ""
  )
}

plot_component_note <- function(name, role) {
  if (name %in% c("plot_long", "pathway_long", "information_long")) {
    return("Best starting point for ggplot2, plotly, or Quarto re-rendering.")
  }
  if (name %in% c("plot_annotations", "pathway_annotations", "reference_lines", "boundary_lines")) {
    return("Use with primary data to draw thresholds, labels, and reference lines.")
  }
  if (name %in% c("plot_settings", "settings")) {
    return("Records resolved plotting options and aliases after normalization.")
  }
  if (name %in% c("curve_style", "legend")) {
    return("Use to reproduce color, line-type, or legend mappings.")
  }
  if (name %in% c("fit_measures", "fit_status", "curve_fit_status", "flag_summary")) {
    return("Use to label or filter review-relevant plotted rows.")
  }
  if (role == "summary_or_guidance") {
    return("Use for captions, QA checks, or report text.")
  }
  ""
}

#' Extract reusable data from an mfrmr plot object
#'
#' @description
#' `plot_data()` is a small accessor for users who want to build custom
#' base-R, ggplot2, plotly, or table-based displays from mfrmr plot helpers.
#' It accepts an existing `mfrm_plot_data` object, or any mfrmr object whose
#' `plot()` method supports `draw = FALSE`. Use [plot_data_components()] first
#' when you want to inspect which components are available before extracting
#' one.
#'
#' @param x An `mfrm_plot_data` object, or a fitted/report/review object with a
#'   `plot(..., draw = FALSE)` method.
#' @param component Optional single component name inside the reusable plot
#'   data. When `NULL`, the full plot-data list is returned.
#' @param type Optional plot type passed to `plot()` when `x` is not already an
#'   `mfrm_plot_data` object.
#' @param ... Additional arguments passed to `plot(..., draw = FALSE)` when
#'   `x` is not already an `mfrm_plot_data` object.
#'
#' @return The full reusable plot-data list, or the selected component.
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", maxit = 30)
#'
#' wright_plot_data <- plot_data(fit, type = "wright")
#' names(wright_plot_data)
#'
#' wright_table <- plot_data(fit, type = "wright", component = "locations")
#' head(wright_table)
#'
#' curves <- category_curves_report(fit, theta_points = 51)
#' curve_long <- plot_data(curves, component = "plot_long")
#' head(curve_long[, c("PlotType", "Theta", "Series", "Value")])
#'
#' pathway_long <- plot_data(fit, type = "pathway", component = "pathway_long")
#' head(pathway_long[, c("Layer", "CurveGroup", "Theta", "Value")])
#' pathway_fit <- plot_data(fit, type = "pathway", component = "fit_measures")
#' head(pathway_fit[, c("Facet", "Level", "Infit", "Outfit", "FitStatus")])
#'
#' info <- compute_information(fit, theta_points = 51)
#' sem_long <- plot_data(
#'   plot_information(info, type = "sem", draw = FALSE),
#'   component = "plot_long"
#' )
#' head(sem_long[, c("Metric", "Theta", "Value", "DisplayedByDefault")])
#' }
#' @export
plot_data <- function(x, component = NULL, type = NULL, ...) {
  x <- as_mfrm_plot_data_object(x, type = type, ...)
  payload <- x$data %||% list()
  if (is.null(component)) {
    return(payload)
  }

  if (length(component) != 1L || is.na(component) || !nzchar(component)) {
    stop("`component` must be a single non-empty component name.", call. = FALSE)
  }
  component <- as.character(component)
  if (!component %in% names(payload)) {
    choices <- names(payload)
    choices <- choices[nzchar(choices)]
    stop(
      "`component` must be one of: ",
      paste(choices, collapse = ", "),
      call. = FALSE
    )
  }

  payload[[component]]
}

#' List reusable components in mfrmr plot data
#'
#' @description
#' `plot_data_components()` is a companion to [plot_data()]. It returns a
#' compact table that tells users which plot-data components are available,
#' what shape they have, and which ones are most useful for custom graphics,
#' dashboards, or report assembly.
#'
#' @param x An `mfrm_plot_data` object, or a fitted/report/review object with a
#'   `plot(..., draw = FALSE)` method.
#' @param type Optional plot type passed to `plot()` when `x` is not already an
#'   `mfrm_plot_data` object.
#' @param ... Additional arguments passed to `plot(..., draw = FALSE)` when
#'   `x` is not already an `mfrm_plot_data` object.
#'
#' @return A data frame with one row per reusable plot-data component.
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", maxit = 30)
#' plot_data_components(fit, type = "pathway")
#'
#' curves <- category_curves_report(fit, theta_points = 51)
#' plot_data_components(curves, type = "category_probability")
#'
#' toy$ResponseTime <- 10 + seq_len(nrow(toy)) %% 6 + as.numeric(toy$Score)
#' rt <- response_time_review(
#'   toy,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   time = "ResponseTime"
#' )
#' plot_data_components(plot_response_time_review(rt, draw = FALSE))
#' }
#' @export
plot_data_components <- function(x, type = NULL, ...) {
  plot_obj <- as_mfrm_plot_data_object(x, type = type, ...)
  payload <- plot_obj$data %||% list()
  component_names <- names(payload)
  component_names <- component_names[!is.na(component_names) & nzchar(component_names)]
  if (length(component_names) == 0L) {
    return(data.frame(
      PlotName = as.character(plot_obj$name %||% NA_character_),
      Component = character(),
      Role = character(),
      ObjectType = character(),
      Rows = integer(),
      Columns = integer(),
      Length = integer(),
      IsTabular = logical(),
      Accessor = character(),
      Notes = character(),
      ColumnNames = character(),
      stringsAsFactors = FALSE
    ))
  }
  rows <- lapply(component_names, function(nm) {
    val <- payload[[nm]]
    shape <- plot_component_shape(val)
    role <- plot_component_role(nm, val)
    data.frame(
      PlotName = as.character(plot_obj$name %||% NA_character_),
      Component = nm,
      Role = role,
      ObjectType = shape$object_type,
      Rows = suppressWarnings(as.integer(shape$rows)),
      Columns = suppressWarnings(as.integer(shape$columns)),
      Length = suppressWarnings(as.integer(shape$length)),
      IsTabular = is.data.frame(val) || is.matrix(val),
      Accessor = paste0("plot_data(x, component = \"", nm, "\")"),
      Notes = plot_component_note(nm, role),
      ColumnNames = shape$column_names,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

.require_ggplot2 <- function() {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      "`as_ggplot()` requires the `ggplot2` package. ",
      "Install ggplot2 or use the base-R plot route.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

.mfrm_plot_title <- function(payload, fallback = NULL) {
  title <- as.character(payload$title %||% fallback %||% "")
  title <- title[!is.na(title) & nzchar(title)]
  title[1] %||% NULL
}

.mfrm_plot_subtitle <- function(payload) {
  subtitle <- as.character(payload$subtitle %||% "")
  subtitle <- subtitle[!is.na(subtitle) & nzchar(subtitle)]
  subtitle[1] %||% NULL
}

.mfrm_ggplot_theme <- function() {
  ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title.position = "plot"
    )
}

.mfrm_ggplot_labs <- function(p, payload, x = NULL, y = NULL,
                              fallback = NULL) {
  p + ggplot2::labs(
    title = .mfrm_plot_title(payload, fallback = fallback),
    subtitle = .mfrm_plot_subtitle(payload),
    x = x,
    y = y
  )
}

.mfrm_ggplot_add_reference_lines <- function(p, reference_lines) {
  refs <- normalize_reference_lines(reference_lines)
  if (!is.data.frame(refs) || nrow(refs) == 0L) return(p)
  for (i in seq_len(nrow(refs))) {
    value <- suppressWarnings(as.numeric(refs$value[i]))
    if (!is.finite(value)) next
    lty <- as.character(refs$linetype[i] %||% "dashed")
    if (!nzchar(lty)) lty <- "dashed"
    axis <- tolower(as.character(refs$axis[i] %||% ""))
    if (axis %in% c("v", "x", "vertical")) {
      p <- p + ggplot2::geom_vline(
        xintercept = value,
        linetype = lty,
        colour = "grey45",
        linewidth = 0.35
      )
    } else if (axis %in% c("h", "y", "horizontal")) {
      p <- p + ggplot2::geom_hline(
        yintercept = value,
        linetype = lty,
        colour = "grey45",
        linewidth = 0.35
      )
    }
  }
  p
}

.mfrm_select_ggplot_component <- function(payload, component = NULL) {
  if (!is.null(component)) {
    if (length(component) != 1L || is.na(component) || !nzchar(component)) {
      stop("`component` must be a single non-empty component name.",
           call. = FALSE)
    }
    if (!component %in% names(payload)) {
      stop(
        "`component` must be one of: ",
        paste(names(payload), collapse = ", "),
        call. = FALSE
      )
    }
    return(list(name = component, value = payload[[component]]))
  }

  priority <- c(
    "plot_long", "pathway_long", "information_long", "probabilities",
    "expected", "data", "locations", "person", "steps", "table", "matrix"
  )
  for (nm in priority) {
    val <- payload[[nm]]
    if ((is.data.frame(val) && nrow(val) > 0L) ||
        (is.matrix(val) && length(val) > 0L)) {
      return(list(name = nm, value = val))
    }
  }
  metadata_names <- c("legend", "reference_lines")
  for (nm in names(payload)) {
    if (nm %in% metadata_names) next
    val <- payload[[nm]]
    if ((is.data.frame(val) && nrow(val) > 0L) ||
        (is.matrix(val) && length(val) > 0L)) {
      return(list(name = nm, value = val))
    }
  }
  stop(
    "No tabular plot component could be converted to ggplot2. ",
    "Use `plot_data_components()` to inspect available components.",
    call. = FALSE
  )
}

.mfrm_matrix_to_tile_data <- function(mat, flag_matrix = NULL) {
  if (!is.matrix(mat)) {
    stop("Matrix heatmap conversion requires a matrix component.",
         call. = FALSE)
  }
  long <- as.data.frame(as.table(mat), stringsAsFactors = FALSE)
  names(long) <- c("Row", "Column", "Value")
  long$Row <- as.character(long$Row)
  long$Column <- as.character(long$Column)
  long$Flag <- FALSE
  if (is.matrix(flag_matrix) && all(dim(flag_matrix) == dim(mat))) {
    flag_long <- as.data.frame(as.table(flag_matrix), stringsAsFactors = FALSE)
    long$Flag <- as.logical(flag_long$Freq)
    long$Flag[is.na(long$Flag)] <- FALSE
  }
  long
}

.mfrm_ggplot_matrix_heatmap <- function(mat,
                                        payload,
                                        flag_matrix = NULL,
                                        value_digits = 2L,
                                        show_values = FALSE,
                                        flag_color = "black") {
  long <- .mfrm_matrix_to_tile_data(mat, flag_matrix = flag_matrix)
  p <- ggplot2::ggplot(long, ggplot2::aes(x = Column, y = Row, fill = Value)) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.25) +
    ggplot2::scale_fill_gradient2(
      low = "steelblue",
      mid = "white",
      high = "firebrick",
      na.value = "grey90"
    ) +
    ggplot2::coord_equal() +
    .mfrm_ggplot_theme() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid.major = ggplot2::element_blank()
    )
  if (isTRUE(show_values)) {
    long$Label <- ifelse(
      is.finite(long$Value),
      formatC(long$Value, format = "f", digits = value_digits),
      ""
    )
    p <- p + ggplot2::geom_text(
      data = long,
      ggplot2::aes(label = Label),
      size = 3,
      colour = "grey15"
    )
  }
  flagged <- long[long$Flag, , drop = FALSE]
  if (nrow(flagged) > 0L) {
    p <- p + ggplot2::geom_tile(
      data = flagged,
      fill = NA,
      colour = flag_color,
      linewidth = 0.8
    )
  }
  .mfrm_ggplot_labs(
    p,
    payload,
    x = "Group or contrast",
    y = "Facet level",
    fallback = "DIF/DFF heatmap"
  )
}

.mfrm_ggplot_effect_summary <- function(df, payload) {
  required <- c("Pair", "Effect")
  if (!all(required %in% names(df))) {
    stop("Effect-summary conversion requires `Pair` and `Effect` columns.",
         call. = FALSE)
  }
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  df$Effect <- suppressWarnings(as.numeric(df$Effect))
  df <- df[is.finite(df$Effect), , drop = FALSE]
  if (nrow(df) == 0L) {
    stop("No finite `Effect` values are available for ggplot conversion.",
         call. = FALSE)
  }
  df$Pair <- as.character(df$Pair)
  df$PairFactor <- factor(df$Pair, levels = rev(unique(df$Pair)))
  if (!"Color" %in% names(df)) df$Color <- "#4D4D4D"
  df$Color <- as.character(df$Color)

  p <- ggplot2::ggplot(df, ggplot2::aes(y = PairFactor)) +
    ggplot2::geom_segment(
      ggplot2::aes(x = 0, xend = Effect, yend = PairFactor, colour = Color),
      linewidth = 1.1,
      lineend = "round"
    ) +
    ggplot2::geom_point(
      ggplot2::aes(x = Effect, colour = Color),
      size = 2.2
    ) +
    ggplot2::scale_colour_identity() +
    .mfrm_ggplot_theme()

  if (all(c("CI_Lower", "CI_Upper") %in% names(df))) {
    ci <- df[
      is.finite(suppressWarnings(as.numeric(df$CI_Lower))) &
        is.finite(suppressWarnings(as.numeric(df$CI_Upper))),
      ,
      drop = FALSE
    ]
    if (nrow(ci) > 0L) {
      ci$CI_Lower <- suppressWarnings(as.numeric(ci$CI_Lower))
      ci$CI_Upper <- suppressWarnings(as.numeric(ci$CI_Upper))
      p <- p + ggplot2::geom_segment(
        data = ci,
        ggplot2::aes(
          x = CI_Lower,
          xend = CI_Upper,
          y = PairFactor,
          yend = PairFactor
        ),
        inherit.aes = FALSE,
        colour = "grey35",
        linewidth = 0.45
      )
    }
  }

  p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
  xlab <- payload$settings$effect_axis_label %||% "Effect"
  .mfrm_ggplot_labs(
    p,
    payload,
    x = xlab,
    y = NULL,
    fallback = "Differential functioning summary"
  )
}

.mfrm_ggplot_eap_power_sensitivity <- function(payload) {
  df <- as.data.frame(payload$data, stringsAsFactors = FALSE)
  if (nrow(df) == 0L) {
    stop("No EAP power-sensitivity rows are available for ggplot conversion.",
         call. = FALSE)
  }
  settings <- payload$settings %||% list()
  plot_type <- as.character(payload$type %||% settings$type %||% "")
  metric <- as.character(payload$metric %||% settings$metric %||% "")
  if (!nzchar(metric) || !metric %in% names(df)) {
    stop("The requested EAP power-sensitivity metric is not available in the plot payload.",
         call. = FALSE)
  }
  if (plot_type %in% c("person_heatmap", "facet_heatmap")) {
    y_col <- if (identical(plot_type, "person_heatmap")) "Person" else "DisplayLabel"
    if (!all(c("Condition", y_col) %in% names(df))) {
      stop("EAP power-sensitivity heatmap payload is missing required columns.",
           call. = FALSE)
    }
    df$Condition <- factor(
      df[["Condition"]],
      levels = unique(df[["Condition"]][order(df[["ConditionOrder"]])])
    )
    df[[y_col]] <- factor(df[[y_col]], levels = rev(unique(df[[y_col]])))
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .data$Condition, y = .data[[y_col]], fill = .data[[metric]])
    ) +
      ggplot2::geom_tile(colour = "white", linewidth = 0.25) +
      ggplot2::scale_fill_gradient2(
        low = "#2b6cb0",
        mid = "white",
        high = "#b83227",
        na.value = "grey90"
      ) +
      .mfrm_ggplot_theme() +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
        panel.grid.major = ggplot2::element_blank()
      )
    return(.mfrm_ggplot_labs(
      p,
      payload,
      x = "Power condition",
      y = if (identical(plot_type, "person_heatmap")) "Person" else "Facet level",
      fallback = "EAP power sensitivity"
    ))
  }
  if (identical(plot_type, "person_curve")) {
    if (!all(c("ConditionOrder", "Condition", "Person") %in% names(df))) {
      stop("EAP power-sensitivity curve payload is missing required columns.",
           call. = FALSE)
    }
    cond <- unique(df[order(df[["ConditionOrder"]]), c("ConditionOrder", "Condition")])
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = .data$ConditionOrder,
        y = .data[[metric]],
        colour = .data$Person,
        group = .data$Person
      )
    ) +
      ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "grey65") +
      ggplot2::geom_line(linewidth = 0.65) +
      ggplot2::geom_point(size = 1.8) +
      ggplot2::scale_x_continuous(
        breaks = cond[["ConditionOrder"]],
        labels = cond[["Condition"]]
      ) +
      .mfrm_ggplot_theme() +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
    return(.mfrm_ggplot_labs(
      p,
      payload,
      x = "Power condition",
      y = metric,
      fallback = "EAP power sensitivity curves"
    ))
  }
  if (identical(plot_type, "facet_stability")) {
    if (!all(c("DisplayLabel", "StabilityFlag") %in% names(df))) {
      stop("EAP facet-stability payload is missing required columns.",
           call. = FALSE)
    }
    df$DisplayLabel <- factor(df$DisplayLabel, levels = df$DisplayLabel)
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .data$DisplayLabel, y = .data[[metric]], fill = .data$StabilityFlag)
    ) +
      ggplot2::geom_col(width = 0.72) +
      ggplot2::coord_flip() +
      ggplot2::scale_fill_manual(
        values = c(stable = "#238b45", review = "#d95f02", unstable = "#b11f24", unknown = "#6b7280"),
        drop = FALSE
      ) +
      .mfrm_ggplot_theme()
    return(.mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = metric,
      fallback = "Facet-level EAP sensitivity stability"
    ))
  }
  stop("Unsupported EAP power-sensitivity plot type: ", plot_type, call. = FALSE)
}

.mfrm_ggplot_simulation_caption <- function(payload) {
  note <- as.character(payload$interpretation_note %||% "")
  note <- note[!is.na(note) & nzchar(note)]
  note[1] %||% NULL
}

.mfrm_ggplot_add_simulation_caption <- function(p, payload) {
  caption <- .mfrm_ggplot_simulation_caption(payload)
  if (is.null(caption)) return(p)
  p + ggplot2::labs(caption = caption) +
    ggplot2::theme(
      plot.caption = ggplot2::element_text(hjust = 0, colour = "grey35")
    )
}

.mfrm_ggplot_simulation_scan <- function(payload) {
  df <- as.data.frame(payload$data %||% data.frame(), stringsAsFactors = FALSE)
  x_col <- as.character(payload$x_var %||% "")
  if (!nzchar(x_col) || !x_col %in% names(df) || !"y" %in% names(df)) {
    stop("Simulation scan conversion requires `data` with the resolved `x_var` and `y` columns.",
         call. = FALSE)
  }
  df[[x_col]] <- suppressWarnings(as.numeric(df[[x_col]]))
  df$y <- suppressWarnings(as.numeric(df$y))
  if (!"group" %in% names(df)) df$group <- "All designs"
  df$group <- as.character(df$group)
  df <- df[is.finite(df[[x_col]]) & is.finite(df$y), , drop = FALSE]
  if (nrow(df) == 0L) {
    stop("No finite simulation scan rows are available for ggplot conversion.",
         call. = FALSE)
  }
  title <- if (identical(as.character(payload$plot %||% ""), "signal_detection")) {
    if (identical(as.character(payload$signal %||% ""), "bias")) {
      "Bias screening simulation"
    } else {
      "DIF screening simulation"
    }
  } else {
    paste("Design simulation:", as.character(payload$facet %||% "facet"))
  }
  payload$title <- payload$title %||% title
  payload$subtitle <- payload$subtitle %||%
    paste("Metric:", as.character(payload$display_metric %||% payload$metric_col %||% payload$metric %||% "value"))
  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = .data[[x_col]],
      y = .data$y,
      colour = .data$group,
      group = .data$group
    )
  ) +
    ggplot2::geom_line(linewidth = 0.75) +
    ggplot2::geom_point(size = 2) +
    .mfrm_ggplot_theme() +
    ggplot2::theme(legend.position = "bottom")
  p <- .mfrm_ggplot_labs(
    p,
    payload,
    x = as.character(payload$x_label %||% x_col),
    y = as.character(payload$display_metric %||% payload$metric_col %||% "Value"),
    fallback = title
  )
  .mfrm_ggplot_add_simulation_caption(p, payload)
}

.mfrm_ggplot_recovery_simulation <- function(payload) {
  df <- as.data.frame(payload$plot_table %||% data.frame(),
                      stringsAsFactors = FALSE)
  if (nrow(df) == 0L) {
    stop("Recovery-simulation conversion requires a non-empty `plot_table`.",
         call. = FALSE)
  }
  plot_type <- as.character(payload$type %||% "")
  if (plot_type %in% c("summary", "coverage")) {
    if (!all(c("PlotGroup", "Value") %in% names(df))) {
      stop("Recovery summary conversion requires PlotGroup and Value columns.",
           call. = FALSE)
    }
    df$Value <- suppressWarnings(as.numeric(df$Value))
    df <- df[is.finite(df$Value), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite recovery summary values are available for ggplot conversion.",
           call. = FALSE)
    }
    df$PlotGroup <- factor(as.character(df$PlotGroup), levels = rev(unique(as.character(df$PlotGroup))))
    if (!"ParameterType" %in% names(df)) df$ParameterType <- "parameter"
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .data$PlotGroup, y = .data$Value, fill = .data$ParameterType)
    ) +
      ggplot2::geom_col(width = 0.72) +
      ggplot2::coord_flip() +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "bottom")
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = as.character(payload$metric_label %||% payload$metric %||% "Value"),
      fallback = "Parameter recovery"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  if (identical(plot_type, "replications")) {
    if (!all(c("Status", "Reps") %in% names(df))) {
      stop("Recovery replication-status conversion requires Status and Reps columns.",
           call. = FALSE)
    }
    df$Reps <- suppressWarnings(as.numeric(df$Reps))
    df <- df[is.finite(df$Reps), , drop = FALSE]
    df$Status <- factor(
      as.character(df$Status),
      levels = intersect(c("failed", "not_converged", "converged"),
                         unique(as.character(df$Status)))
    )
    status_cols <- c(
      converged = "#238b45",
      not_converged = "#b65e16",
      failed = "#b11f24"
    )
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Status, y = .data$Reps, fill = .data$Status)) +
      ggplot2::geom_col(width = 0.72) +
      ggplot2::scale_fill_manual(values = status_cols, drop = FALSE, na.value = "#6b7280") +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "none")
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = "Replications",
      fallback = "Parameter recovery: replication status"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  if (identical(plot_type, "errors")) {
    if (!all(c("PlotGroup", "ErrorForPlot") %in% names(df))) {
      stop("Recovery error conversion requires PlotGroup and ErrorForPlot columns.",
           call. = FALSE)
    }
    df$ErrorForPlot <- suppressWarnings(as.numeric(df$ErrorForPlot))
    df <- df[is.finite(df$ErrorForPlot), , drop = FALSE]
    df$PlotGroup <- factor(as.character(df$PlotGroup), levels = rev(unique(as.character(df$PlotGroup))))
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$PlotGroup, y = .data$ErrorForPlot)) +
      ggplot2::geom_boxplot(fill = "#dbeafe", colour = "#334e68", width = 0.65, outlier.alpha = 0.55) +
      ggplot2::coord_flip() +
      .mfrm_ggplot_theme()
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = as.character(payload$metric_label %||% "Recovery error"),
      fallback = "Parameter recovery: error distribution"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  if (identical(plot_type, "scatter")) {
    if (!all(c("TruthForPlot", "EstimateForPlot") %in% names(df))) {
      stop("Recovery scatter conversion requires TruthForPlot and EstimateForPlot columns.",
           call. = FALSE)
    }
    df$TruthForPlot <- suppressWarnings(as.numeric(df$TruthForPlot))
    df$EstimateForPlot <- suppressWarnings(as.numeric(df$EstimateForPlot))
    df <- df[is.finite(df$TruthForPlot) & is.finite(df$EstimateForPlot), , drop = FALSE]
    if (!"PlotGroup" %in% names(df)) df$PlotGroup <- "parameter"
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = .data$TruthForPlot,
        y = .data$EstimateForPlot,
        colour = .data$PlotGroup
      )
    ) +
      ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey45") +
      ggplot2::geom_point(alpha = 0.78, size = 1.8) +
      ggplot2::coord_equal() +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "bottom")
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = "Truth",
      y = as.character(payload$metric_label %||% "Estimate"),
      fallback = "Parameter recovery: truth versus estimate"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  stop("Unsupported recovery-simulation plot type: ", plot_type, call. = FALSE)
}

.mfrm_ggplot_recovery_assessment <- function(payload) {
  plot_type <- as.character(payload$type %||% "")
  if (identical(plot_type, "status")) {
    df <- as.data.frame(payload$status_counts %||% payload$plot_table %||% data.frame(),
                        stringsAsFactors = FALSE)
    if (!all(c("Status", "Checks") %in% names(df))) {
      stop("Recovery-assessment status conversion requires Status and Checks columns.",
           call. = FALSE)
    }
    df$Checks <- suppressWarnings(as.numeric(df$Checks))
    status_cols <- c(ok = "#238b45", review = "#b65e16", concern = "#b11f24",
                     not_available = "#6b7280", not_assessed = "#9ca3af")
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Status, y = .data$Checks, fill = .data$Status)) +
      ggplot2::geom_col(width = 0.72) +
      ggplot2::scale_fill_manual(values = status_cols, drop = FALSE, na.value = "#6b7280") +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "none")
    return(.mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = "Checklist checks",
      fallback = "Recovery assessment: checklist status"
    ))
  }
  if (identical(plot_type, "metrics")) {
    df <- as.data.frame(payload$plot_table %||% data.frame(),
                        stringsAsFactors = FALSE)
    if (!all(c("PlotGroup", "Value", "Status") %in% names(df))) {
      stop("Recovery-assessment metric conversion requires PlotGroup, Value, and Status columns.",
           call. = FALSE)
    }
    df$Value <- suppressWarnings(as.numeric(df$Value))
    df <- df[is.finite(df$Value), , drop = FALSE]
    df$PlotGroup <- factor(as.character(df$PlotGroup), levels = rev(unique(as.character(df$PlotGroup))))
    status_cols <- c(ok = "#238b45", review = "#b65e16", concern = "#b11f24",
                     not_available = "#6b7280", not_assessed = "#9ca3af")
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$PlotGroup, y = .data$Value, fill = .data$Status)) +
      ggplot2::geom_col(width = 0.72) +
      ggplot2::coord_flip() +
      ggplot2::scale_fill_manual(values = status_cols, drop = FALSE, na.value = "#6b7280") +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "bottom")
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    return(.mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = as.character(payload$metric_label %||% payload$metric %||% "Value"),
      fallback = "Recovery assessment"
    ))
  }
  stop("Unsupported recovery-assessment plot type: ", plot_type, call. = FALSE)
}

.mfrm_ggplot_generalizability <- function(payload) {
  plot_type <- as.character(payload$plot %||% "")
  df <- as.data.frame(payload$plot_table %||% data.frame(),
                      stringsAsFactors = FALSE)
  if (nrow(df) == 0L) {
    stop("G-study conversion requires a non-empty `plot_table`.",
         call. = FALSE)
  }
  if (identical(plot_type, "variance_components")) {
    if (!all(c("Source", "Value") %in% names(df))) {
      stop("G-study variance-component conversion requires Source and Value columns.",
           call. = FALSE)
    }
    df$Source <- as.character(df$Source)
    df$Value <- suppressWarnings(as.numeric(df$Value))
    df <- df[is.finite(df$Value), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite G-study variance components are available for ggplot conversion.",
           call. = FALSE)
    }
    df$Source <- factor(df$Source, levels = df$Source[order(df$Value)])
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Source, y = .data$Value, fill = .data$Source)) +
      ggplot2::geom_col(width = 0.72) +
      ggplot2::coord_flip() +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "none")
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = if (identical(as.character(payload$metric %||% ""), "ProportionVariance")) {
        "Proportion of variance"
      } else {
        "Variance"
      },
      fallback = "G-study variance components"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  if (identical(plot_type, "coefficients")) {
    if (!all(c("Metric", "Value") %in% names(df))) {
      stop("G-study coefficient conversion requires Metric and Value columns.",
           call. = FALSE)
    }
    df$Metric <- factor(as.character(df$Metric), levels = intersect(c("G", "Phi"), as.character(df$Metric)))
    df$Value <- suppressWarnings(as.numeric(df$Value))
    if (!"Status" %in% names(df)) df$Status <- "review"
    df <- df[is.finite(df$Value), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite G-study coefficients are available for ggplot conversion.",
           call. = FALSE)
    }
    status_cols <- c(
      high_stakes_candidate = "#238b45",
      routine_candidate = "#d99f0b",
      review = "#b11f24",
      unavailable = "#6b7280"
    )
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Metric, y = .data$Value, fill = .data$Status)) +
      ggplot2::geom_col(width = 0.62) +
      ggplot2::scale_fill_manual(values = status_cols, drop = FALSE, na.value = "#6b7280") +
      ggplot2::coord_cartesian(ylim = c(0, 1)) +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "bottom")
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = "Coefficient",
      fallback = "G-study G/Phi coefficients"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  stop("Unsupported G-study plot type: ", plot_type, call. = FALSE)
}

.mfrm_ggplot_generalizability_design_check <- function(payload) {
  df <- as.data.frame(payload$plot_table %||% data.frame(),
                      stringsAsFactors = FALSE)
  if (!all(c("PlotGroup", "Value", "Status") %in% names(df))) {
    stop("G-study design-check conversion requires PlotGroup, Value, and Status columns.",
         call. = FALSE)
  }
  df$PlotGroup <- as.character(df$PlotGroup)
  df$Value <- suppressWarnings(as.numeric(df$Value))
  df$Status <- as.character(df$Status)
  df <- df[is.finite(df$Value) & nzchar(df$PlotGroup), , drop = FALSE]
  if (nrow(df) == 0L) {
    stop("No finite G-study design-check rows are available for ggplot conversion.",
         call. = FALSE)
  }
  df$PlotGroup <- factor(df$PlotGroup, levels = rev(df$PlotGroup))
  status_cols <- c(
    ok = "#238b45",
    sensitivity_only = "#b65e16",
    review = "#b11f24",
    not_requested = "#6b7280"
  )
  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = .data$PlotGroup, y = .data$Value, fill = .data$Status)
  ) +
    ggplot2::geom_col(width = 0.72) +
    ggplot2::scale_fill_manual(values = status_cols, drop = FALSE, na.value = "#6b7280") +
    .mfrm_ggplot_theme() +
    ggplot2::theme(legend.position = "bottom")
  if (identical(as.character(payload$value_scale %||% ""), "proportion")) {
    p <- p + ggplot2::coord_flip(ylim = c(0, 1))
  } else {
    p <- p + ggplot2::coord_flip()
  }
  p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
  p <- .mfrm_ggplot_labs(
    p,
    payload,
    x = NULL,
    y = as.character(payload$metric_label %||% payload$metric %||% "Value"),
    fallback = "G-study design check"
  )
  .mfrm_ggplot_add_simulation_caption(p, payload)
}

.mfrm_ggplot_generalizability_comparison <- function(payload) {
  plot_type <- as.character(payload$plot %||% "")
  df <- as.data.frame(payload$plot_table %||% data.frame(),
                      stringsAsFactors = FALSE)
  if (nrow(df) == 0L) {
    stop("G-study comparison conversion requires a non-empty `plot_table`.",
         call. = FALSE)
  }
  if (identical(plot_type, "design_check")) {
    if (!all(c("ModelLabel", "PlotGroup", "Value", "Status") %in% names(df))) {
      stop("G-study comparison design-check conversion requires ModelLabel, PlotGroup, Value, and Status columns.",
           call. = FALSE)
    }
    df$ModelLabel <- as.character(df$ModelLabel)
    df$PlotGroup <- as.character(df$PlotGroup)
    df$Status <- as.character(df$Status)
    df$Value <- suppressWarnings(as.numeric(df$Value))
    df <- df[is.finite(df$Value) & nzchar(df$PlotGroup), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite G-study comparison design-check rows are available for ggplot conversion.",
           call. = FALSE)
    }
    df$PlotGroup <- factor(df$PlotGroup, levels = rev(unique(df$PlotGroup)))
    status_cols <- c(
      ok = "#238b45",
      sensitivity_only = "#b65e16",
      review = "#b11f24",
      not_requested = "#6b7280"
    )
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .data$PlotGroup, y = .data$Value, fill = .data$Status)
    ) +
      ggplot2::geom_col(width = 0.72) +
      ggplot2::scale_fill_manual(values = status_cols, drop = FALSE, na.value = "#6b7280") +
      ggplot2::facet_wrap(stats::as.formula("~ ModelLabel"), scales = "free_y") +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "bottom")
    if (identical(as.character(payload$value_scale %||% ""), "proportion")) {
      p <- p + ggplot2::coord_flip(ylim = c(0, 1))
    } else {
      p <- p + ggplot2::coord_flip()
    }
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = as.character(payload$metric_label %||% payload$metric %||% "Value"),
      fallback = "G-study design-check sensitivity comparison"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  if (plot_type %in% c("coefficients", "coefficient_delta")) {
    if (!all(c("ModelLabel", "Metric", "Value") %in% names(df))) {
      stop("G-study comparison coefficient conversion requires ModelLabel, Metric, and Value columns.",
           call. = FALSE)
    }
    df$ModelLabel <- as.character(df$ModelLabel)
    df$Metric <- as.character(df$Metric)
    df$Value <- suppressWarnings(as.numeric(df$Value))
    df <- df[is.finite(df$Value), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite G-study comparison coefficient rows are available for ggplot conversion.",
           call. = FALSE)
    }
    if (identical(plot_type, "coefficients")) {
      p <- ggplot2::ggplot(
        df,
        ggplot2::aes(x = .data$Metric, y = .data$Value, fill = .data$ModelLabel)
      ) +
        ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.72), width = 0.62) +
        ggplot2::coord_cartesian(ylim = c(0, 1)) +
        .mfrm_ggplot_theme() +
        ggplot2::theme(legend.position = "bottom")
      p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
      p <- .mfrm_ggplot_labs(
        p,
        payload,
        x = NULL,
        y = "Coefficient",
        fallback = "G-study coefficient sensitivity comparison"
      )
      return(.mfrm_ggplot_add_simulation_caption(p, payload))
    }
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .data$Metric, y = .data$Value, fill = .data$Value >= 0)
    ) +
      ggplot2::geom_col(width = 0.62, show.legend = FALSE) +
      ggplot2::coord_flip() +
      ggplot2::scale_fill_manual(values = c(`TRUE` = "#1b9e77", `FALSE` = "#d95f02")) +
      .mfrm_ggplot_theme()
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = "Expanded minus baseline",
      fallback = "G-study coefficient delta"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  if (identical(plot_type, "variance_delta")) {
    if (!all(c("Source", "Value") %in% names(df))) {
      stop("G-study variance-delta conversion requires Source and Value columns.",
           call. = FALSE)
    }
    df$Source <- as.character(df$Source)
    df$Value <- suppressWarnings(as.numeric(df$Value))
    df <- df[is.finite(df$Value), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite variance-delta rows are available for ggplot conversion.",
           call. = FALSE)
    }
    df$Source <- factor(df$Source, levels = rev(df$Source))
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .data$Source, y = .data$Value, fill = .data$Value >= 0)
    ) +
      ggplot2::geom_col(width = 0.72, show.legend = FALSE) +
      ggplot2::coord_flip() +
      ggplot2::scale_fill_manual(values = c(`TRUE` = "#1b9e77", `FALSE` = "#d95f02")) +
      .mfrm_ggplot_theme()
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = NULL,
      y = as.character(payload$metric %||% "DeltaVariance"),
      fallback = "G-study variance movement"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  if (identical(plot_type, "d_study_overlay")) {
    if (!all(c("X", "Value", "Series") %in% names(df))) {
      stop("G-study comparison D-study overlay conversion requires X, Value, and Series columns.",
           call. = FALSE)
    }
    df$X <- suppressWarnings(as.numeric(df$X))
    df$Value <- suppressWarnings(as.numeric(df$Value))
    df$Series <- as.character(df$Series)
    if (!"Panel" %in% names(df)) df$Panel <- "All designs"
    df <- df[is.finite(df$X) & is.finite(df$Value), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite D-study overlay rows are available for ggplot conversion.",
           call. = FALSE)
    }
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = .data$X,
        y = .data$Value,
        colour = .data$Series,
        linetype = .data$Series,
        group = .data$Series
      )
    ) +
      ggplot2::geom_line(linewidth = 0.75) +
      ggplot2::geom_point(size = 2) +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "bottom")
    metrics <- unique(as.character(df$Metric %||% ""))
    if (length(metrics) > 0L && all(metrics %in% c("G", "Phi"))) {
      p <- p + ggplot2::coord_cartesian(ylim = c(0, 1))
    }
    if ("Panel" %in% names(df) && length(unique(as.character(df$Panel))) > 1L) {
      p <- p + ggplot2::facet_wrap(stats::as.formula("~ Panel"))
    }
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = as.character(payload$x_var %||% "Planned count"),
      y = if (length(metrics) > 0L && all(metrics %in% c("G", "Phi"))) {
        "Coefficient"
      } else {
        "Error variance"
      },
      fallback = "D-study sensitivity overlay"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  stop("Unsupported G-study comparison plot type: ", plot_type, call. = FALSE)
}

.mfrm_ggplot_d_study <- function(payload) {
  plot_type <- as.character(payload$plot %||% "")
  if (plot_type %in% c("coefficients", "error_variance")) {
    df <- as.data.frame(payload$series %||% data.frame(),
                        stringsAsFactors = FALSE)
    if (!all(c("X", "Value") %in% names(df))) {
      stop("D-study line conversion requires X and Value columns.",
           call. = FALSE)
    }
    df$X <- suppressWarnings(as.numeric(df$X))
    df$Value <- suppressWarnings(as.numeric(df$Value))
    if (!"Series" %in% names(df)) df$Series <- as.character(df$Metric %||% "Projection")
    df$Series <- as.character(df$Series)
    if (!"Panel" %in% names(df)) df$Panel <- "All designs"
    df <- df[is.finite(df$X) & is.finite(df$Value), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite D-study line rows are available for ggplot conversion.",
           call. = FALSE)
    }
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = .data$X,
        y = .data$Value,
        colour = .data$Series,
        linetype = .data$Series,
        group = .data$Series
      )
    ) +
      ggplot2::geom_line(linewidth = 0.75) +
      ggplot2::geom_point(size = 2) +
      .mfrm_ggplot_theme() +
      ggplot2::theme(legend.position = "bottom")
    if (identical(plot_type, "coefficients")) {
      p <- p + ggplot2::coord_cartesian(ylim = c(0, 1))
    }
    if (all(c("PanelRow", "PanelCol") %in% names(df)) &&
        length(payload$panel_grid %||% character(0)) == 2L) {
      p <- p + ggplot2::facet_grid(stats::as.formula("PanelRow ~ PanelCol"))
    } else if ("Panel" %in% names(df) && length(unique(as.character(df$Panel))) > 1L) {
      p <- p + ggplot2::facet_wrap(stats::as.formula("~ Panel"))
    }
    p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = as.character(payload$x_var %||% "Planned count"),
      y = if (identical(plot_type, "coefficients")) "Coefficient" else "Error variance",
      fallback = if (identical(plot_type, "coefficients")) {
        "D-study G/Phi projection"
      } else {
        "D-study error variance projection"
      }
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  if (plot_type %in% c("heatmap", "contour", "surface3d")) {
    df <- as.data.frame(payload$surface %||% payload$series %||% data.frame(),
                        stringsAsFactors = FALSE)
    if (!all(c("X", "Y", "Value") %in% names(df))) {
      stop("D-study surface conversion requires X, Y, and Value columns.",
           call. = FALSE)
    }
    df$X <- suppressWarnings(as.numeric(df$X))
    df$Y <- suppressWarnings(as.numeric(df$Y))
    df$Value <- suppressWarnings(as.numeric(df$Value))
    if (!"Panel" %in% names(df)) df$Panel <- "All designs"
    df <- df[is.finite(df$X) & is.finite(df$Y) & is.finite(df$Value), , drop = FALSE]
    if (nrow(df) == 0L) {
      stop("No finite D-study surface rows are available for ggplot conversion.",
           call. = FALSE)
    }
    if (identical(plot_type, "surface3d")) {
      base_subtitle <- as.character(payload$subtitle %||% "")
      extra <- "as_ggplot() renders the 3D route as an editable 2D surface projection"
      payload$subtitle <- if (nzchar(base_subtitle)) paste(base_subtitle, extra, sep = "; ") else extra
    }
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$X, y = .data$Y, fill = .data$Value)) +
      ggplot2::geom_tile(colour = "white", linewidth = 0.25) +
      ggplot2::scale_fill_gradientn(
        colours = grDevices::hcl.colors(9L, palette = "YlGnBu", rev = TRUE),
        na.value = "grey90"
      ) +
      .mfrm_ggplot_theme() +
      ggplot2::theme(
        legend.position = "bottom",
        panel.grid.major = ggplot2::element_blank()
      )
    if (plot_type %in% c("contour", "surface3d")) {
      p <- p + ggplot2::geom_contour(
        data = df,
        ggplot2::aes(x = .data$X, y = .data$Y, z = .data$Value),
        inherit.aes = FALSE,
        colour = "grey25",
        linewidth = 0.35,
        bins = 8L
      )
    }
    if ("Panel" %in% names(df) && length(unique(as.character(df$Panel))) > 1L) {
      p <- p + ggplot2::facet_wrap(stats::as.formula("~ Panel"))
    }
    p <- .mfrm_ggplot_labs(
      p,
      payload,
      x = as.character(payload$x_var %||% "Planned count"),
      y = as.character(payload$y_var %||% "Planned count"),
      fallback = "D-study design grid"
    )
    return(.mfrm_ggplot_add_simulation_caption(p, payload))
  }
  stop("Unsupported D-study plot type: ", plot_type, call. = FALSE)
}

.mfrm_ggplot_curve_data <- function(df, payload) {
  if (!all(c("Theta", "Value") %in% names(df))) {
    stop("Curve conversion requires `Theta` and `Value` columns.",
         call. = FALSE)
  }
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  if ("DisplayedByDefault" %in% names(df)) {
    keep <- is.na(df$DisplayedByDefault) | as.logical(df$DisplayedByDefault)
    df <- df[keep, , drop = FALSE]
  }
  df$Theta <- suppressWarnings(as.numeric(df$Theta))
  df$Value <- suppressWarnings(as.numeric(df$Value))
  df <- df[is.finite(df$Theta) & is.finite(df$Value), , drop = FALSE]
  if (nrow(df) == 0L) {
    stop("No finite curve rows are available for ggplot conversion.",
         call. = FALSE)
  }
  colour_col <- intersect(
    c("Series", "Metric", "CurveGroup", "Category", "ValueName", "Layer"),
    names(df)
  )[1]
  if (!is.na(colour_col)) {
    df$.mfrmr_colour <- as.character(df[[colour_col]])
  } else {
    df$.mfrmr_colour <- "series"
  }
  group_cols <- intersect(
    c("Series", "Metric", "CurveGroup", "Category", "ValueName", "Layer"),
    names(df)
  )
  if (length(group_cols) > 0L) {
    df$.mfrmr_group <- do.call(paste, c(df[group_cols], sep = " | "))
  } else {
    df$.mfrmr_group <- "series"
  }

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = Theta,
      y = Value,
      colour = .mfrmr_colour,
      group = .mfrmr_group
    )
  ) +
    ggplot2::geom_line(linewidth = 0.7) +
    .mfrm_ggplot_theme()
  p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
  .mfrm_ggplot_labs(
    p,
    payload,
    x = "Theta / logit",
    y = "Value",
    fallback = "mfrmr curve"
  )
}

.mfrm_ggplot_threshold_ladder <- function(df, payload) {
  if (!all(c("Group", "Threshold") %in% names(df))) {
    stop("Threshold-ladder conversion requires `Group` and `Threshold` columns.",
         call. = FALSE)
  }
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  df$Threshold <- suppressWarnings(as.numeric(df$Threshold))
  df <- df[is.finite(df$Threshold), , drop = FALSE]
  if (!"Step" %in% names(df)) df$Step <- seq_len(nrow(df))
  if (!"Disordered" %in% names(df)) df$Disordered <- FALSE
  df$Disordered <- as.logical(df$Disordered)
  df$Group <- as.character(df$Group)

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = Group, y = Threshold, group = Group)
  ) +
    ggplot2::geom_line(colour = "grey45", linewidth = 0.5) +
    ggplot2::geom_point(ggplot2::aes(colour = Disordered), size = 2.1) +
    ggplot2::scale_colour_manual(
      values = c(`FALSE` = "#2B6CB0", `TRUE` = "#C53030")
    ) +
    .mfrm_ggplot_theme() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
  p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
  .mfrm_ggplot_labs(
    p,
    payload,
    x = NULL,
    y = "Threshold (logit)",
    fallback = "Threshold ladder"
  )
}

.mfrm_ggplot_estimate_rows <- function(df, payload) {
  label_col <- intersect(c("Level", "Person", "Step", "Label", "Group"), names(df))[1]
  if (is.na(label_col) || !"Estimate" %in% names(df)) {
    stop("Estimate-row conversion requires `Estimate` and a label column.",
         call. = FALSE)
  }
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  df$Estimate <- suppressWarnings(as.numeric(df$Estimate))
  df$.mfrmr_label <- as.character(df[[label_col]])
  df <- df[is.finite(df$Estimate) & nzchar(df$.mfrmr_label), , drop = FALSE]
  if (nrow(df) == 0L) {
    stop("No finite estimate rows are available for ggplot conversion.",
         call. = FALSE)
  }
  df$.mfrmr_label <- factor(df$.mfrmr_label, levels = rev(unique(df$.mfrmr_label)))
  p <- ggplot2::ggplot(df, ggplot2::aes(x = Estimate, y = .mfrmr_label)) +
    ggplot2::geom_point(size = 2) +
    .mfrm_ggplot_theme()
  if (all(c("CI_Lower", "CI_Upper") %in% names(df))) {
    ci <- df[is.finite(df$CI_Lower) & is.finite(df$CI_Upper), , drop = FALSE]
    if (nrow(ci) > 0L) {
      p <- p + ggplot2::geom_segment(
        data = ci,
        ggplot2::aes(
          x = CI_Lower,
          xend = CI_Upper,
          y = .mfrmr_label,
          yend = .mfrmr_label
        ),
        inherit.aes = FALSE,
        colour = "grey45"
      )
    }
  } else if ("SE" %in% names(df)) {
    se <- suppressWarnings(as.numeric(df$SE))
    ci <- df[is.finite(se), , drop = FALSE]
    if (nrow(ci) > 0L) {
      ci$CI_Lower <- ci$Estimate - 1.96 * suppressWarnings(as.numeric(ci$SE))
      ci$CI_Upper <- ci$Estimate + 1.96 * suppressWarnings(as.numeric(ci$SE))
      p <- p + ggplot2::geom_segment(
        data = ci,
        ggplot2::aes(
          x = CI_Lower,
          xend = CI_Upper,
          y = .mfrmr_label,
          yend = .mfrmr_label
        ),
        inherit.aes = FALSE,
        colour = "grey45"
      )
    }
  }
  p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
  .mfrm_ggplot_labs(
    p,
    payload,
    x = "Estimate",
    y = NULL,
    fallback = "mfrmr estimates"
  )
}

.mfrm_ggplot_numeric_fallback <- function(df, payload) {
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  numeric_cols <- names(df)[vapply(df, is.numeric, logical(1))]
  if (length(numeric_cols) == 0L) {
    stop(
      "The selected component has no numeric columns for ggplot conversion.",
      call. = FALSE
    )
  }
  character_cols <- names(df)[
    vapply(df, function(z) is.character(z) || is.factor(z), logical(1))
  ]
  if (length(character_cols) > 0L) {
    x_col <- numeric_cols[1]
    y_col <- character_cols[1]
    dat <- data.frame(
      x = suppressWarnings(as.numeric(df[[x_col]])),
      y = as.character(df[[y_col]]),
      stringsAsFactors = FALSE
    )
    dat <- dat[is.finite(dat$x) & nzchar(dat$y), , drop = FALSE]
    dat$y <- factor(dat$y, levels = rev(unique(dat$y)))
    p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_col(fill = "#2B6CB0", width = 0.7) +
      .mfrm_ggplot_theme()
    return(.mfrm_ggplot_labs(
      p, payload, x = x_col, y = y_col, fallback = "mfrmr plot data"
    ))
  }
  if (length(numeric_cols) >= 2L) {
    dat <- data.frame(
      x = suppressWarnings(as.numeric(df[[numeric_cols[1]]])),
      y = suppressWarnings(as.numeric(df[[numeric_cols[2]]])),
      stringsAsFactors = FALSE
    )
    dat <- dat[is.finite(dat$x) & is.finite(dat$y), , drop = FALSE]
    p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_point(colour = "#2B6CB0", size = 2) +
      .mfrm_ggplot_theme()
    return(.mfrm_ggplot_labs(
      p,
      payload,
      x = numeric_cols[1],
      y = numeric_cols[2],
      fallback = "mfrmr plot data"
    ))
  }
  stop("The selected component is not suitable for automatic ggplot conversion.",
       call. = FALSE)
}

.mfrm_category_curve_probabilities <- function(payload) {
  prob <- as.data.frame(payload$probabilities %||% data.frame(),
                        stringsAsFactors = FALSE)
  if (nrow(prob) > 0L &&
      all(c("Theta", "Probability", "Category", "CurveGroup") %in%
            names(prob))) {
    return(prob)
  }
  long <- as.data.frame(payload$plot_long %||% data.frame(),
                        stringsAsFactors = FALSE)
  if (nrow(long) > 0L &&
      all(c("PlotType", "Theta", "Value", "Category", "CurveGroup") %in%
            names(long))) {
    long <- long[as.character(long$PlotType) == "ccc", , drop = FALSE]
    if (nrow(long) > 0L) {
      long$Probability <- suppressWarnings(as.numeric(long$Value))
      return(long)
    }
  }
  data.frame()
}

.mfrm_category_curve_dominance <- function(prob) {
  if (nrow(prob) == 0L ||
      !all(c("CurveGroup", "Theta", "Category", "Probability") %in%
            names(prob))) {
    return(data.frame())
  }
  prob <- prob[is.finite(prob$Theta) & is.finite(prob$Probability), ,
               drop = FALSE]
  if (nrow(prob) == 0L) return(data.frame())
  groups <- unique(as.character(prob$CurveGroup))
  rows <- list()
  for (g in groups) {
    sub_g <- prob[as.character(prob$CurveGroup) == g, , drop = FALSE]
    theta_vals <- sort(unique(sub_g$Theta))
    if (length(theta_vals) == 0L) next
    dominant <- vapply(theta_vals, function(th) {
      sub_t <- sub_g[sub_g$Theta == th, , drop = FALSE]
      if (nrow(sub_t) == 0L) return(NA_character_)
      as.character(sub_t$Category[which.max(sub_t$Probability)][1])
    }, character(1))
    ok <- !is.na(dominant) & nzchar(dominant)
    theta_vals <- theta_vals[ok]
    dominant <- dominant[ok]
    if (length(theta_vals) == 0L) next
    starts <- which(c(TRUE, dominant[-1L] != dominant[-length(dominant)]))
    ends <- c(starts[-1L] - 1L, length(dominant))
    theta_step <- if (length(theta_vals) > 1L) {
      stats::median(diff(theta_vals), na.rm = TRUE)
    } else {
      0.1
    }
    if (!is.finite(theta_step) || theta_step <= 0) theta_step <- 0.1
    for (i in seq_along(starts)) {
      rows[[length(rows) + 1L]] <- data.frame(
        CurveGroup = g,
        DominantCategory = dominant[starts[i]],
        ThetaStart = theta_vals[starts[i]] - theta_step / 2,
        ThetaEnd = theta_vals[ends[i]] + theta_step / 2,
        YMin = 0,
        YMax = 1,
        stringsAsFactors = FALSE
      )
    }
  }
  if (length(rows) == 0L) return(data.frame())
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

.mfrm_ggplot_category_curves <- function(payload,
                                         slope_aes = c("none", "linewidth", "alpha", "colour"),
                                         facet_by = c("auto", "none", "curve_group"),
                                         show_overlay = TRUE,
                                         show_dominance = FALSE) {
  slope_aes <- match.arg(slope_aes)
  facet_by <- match.arg(facet_by)
  prob <- .mfrm_category_curve_probabilities(payload)
  required <- c("Theta", "Probability", "Category", "CurveGroup")
  if (!all(required %in% names(prob))) {
    stop("CCC conversion requires category-curve probabilities with Theta, Probability, Category, and CurveGroup columns.",
         call. = FALSE)
  }
  prob <- as.data.frame(prob, stringsAsFactors = FALSE)
  prob$Theta <- suppressWarnings(as.numeric(prob$Theta))
  prob$Probability <- suppressWarnings(as.numeric(prob$Probability))
  prob$Category <- as.character(prob$Category)
  prob$CurveGroup <- as.character(prob$CurveGroup)
  if (!"Slope" %in% names(prob)) prob$Slope <- 1
  prob$Slope <- suppressWarnings(as.numeric(prob$Slope))
  finite_slope <- prob$Slope[is.finite(prob$Slope) & prob$Slope > 0]
  slope_fallback <- if (length(finite_slope) > 0L) {
    stats::median(finite_slope)
  } else {
    1
  }
  prob$Slope[!is.finite(prob$Slope) | prob$Slope <= 0] <- slope_fallback
  prob <- prob[
    is.finite(prob$Theta) & is.finite(prob$Probability) &
      nzchar(prob$Category) & nzchar(prob$CurveGroup),
    ,
    drop = FALSE
  ]
  if (nrow(prob) == 0L) {
    stop("No finite CCC probability rows are available for ggplot conversion.",
         call. = FALSE)
  }
  prob$Trace <- paste(prob$CurveGroup, prob$Category, sep = " | Cat ")
  category_levels <- unique(as.character(prob$Category))
  numeric_categories <- suppressWarnings(as.numeric(category_levels))
  if (all(is.finite(numeric_categories))) {
    category_levels <- category_levels[order(numeric_categories)]
  }
  prob$Category <- factor(prob$Category, levels = category_levels)
  group_count <- length(unique(as.character(prob$CurveGroup)))
  if (identical(facet_by, "auto")) {
    facet_by <- if (group_count > 1L) "curve_group" else "none"
  }

  dominance <- if (isTRUE(show_dominance)) {
    .mfrm_category_curve_dominance(prob)
  } else {
    data.frame()
  }
  add_dominance <- function(p) {
    if (nrow(dominance) == 0L) return(p)
    p + ggplot2::geom_rect(
      data = dominance,
      ggplot2::aes(
        xmin = ThetaStart,
        xmax = ThetaEnd,
        ymin = YMin,
        ymax = YMax,
        fill = DominantCategory
      ),
      inherit.aes = FALSE,
      colour = NA,
      alpha = 0.08,
      show.legend = FALSE
    )
  }
  if (nrow(dominance) > 0L) {
    dominance$DominantCategory <- factor(
      dominance$DominantCategory,
      levels = category_levels
    )
  }
  p <- add_dominance(ggplot2::ggplot())

  if (identical(slope_aes, "colour")) {
    p <- p +
      ggplot2::geom_line(
        data = prob,
        ggplot2::aes(
          x = Theta,
          y = Probability,
          group = Trace,
          colour = Slope,
          linetype = Category
        ),
        linewidth = 0.85,
        alpha = 0.95
      ) +
      ggplot2::scale_colour_gradient(
        low = "#2B6CB0",
        high = "#C53030",
        name = "Slope"
      )
  } else if (identical(slope_aes, "linewidth")) {
    line_mapping <- ggplot2::aes(
      x = Theta,
      y = Probability,
      group = Trace,
      colour = Category,
      linewidth = Slope
    )
    if (identical(facet_by, "none") && group_count > 1L) {
      line_mapping <- ggplot2::aes(
        x = Theta,
        y = Probability,
        group = Trace,
        colour = Category,
        linewidth = Slope,
        linetype = CurveGroup
      )
    }
    p <- p + ggplot2::geom_line(
      data = prob,
      line_mapping,
      alpha = 0.95
    ) +
      ggplot2::scale_linewidth_continuous(
        range = c(0.45, 1.35),
        name = "Slope"
      )
  } else if (identical(slope_aes, "alpha")) {
    line_mapping <- ggplot2::aes(
      x = Theta,
      y = Probability,
      group = Trace,
      colour = Category,
      alpha = Slope
    )
    if (identical(facet_by, "none") && group_count > 1L) {
      line_mapping <- ggplot2::aes(
        x = Theta,
        y = Probability,
        group = Trace,
        colour = Category,
        alpha = Slope,
        linetype = CurveGroup
      )
    }
    p <- p + ggplot2::geom_line(
      data = prob,
      line_mapping,
      linewidth = 0.9
    ) +
      ggplot2::scale_alpha_continuous(
        range = c(0.45, 1),
        name = "Slope"
      )
  } else {
    p <- p + ggplot2::geom_line(
      data = prob,
      ggplot2::aes(
        x = Theta,
        y = Probability,
        group = Trace,
        colour = Category
      ),
      linewidth = 0.85,
      alpha = 0.95
    )
    if (identical(facet_by, "none") && group_count > 1L) {
      p <- p + ggplot2::aes(linetype = CurveGroup)
    }
  }

  overlay <- as.data.frame(payload$overlay %||% data.frame(),
                           stringsAsFactors = FALSE)
  if (isTRUE(show_overlay) && nrow(overlay) > 0L &&
      all(c("Theta", "Category", "Proportion") %in% names(overlay))) {
    overlay$Theta <- suppressWarnings(as.numeric(overlay$Theta))
    overlay$Proportion <- suppressWarnings(as.numeric(overlay$Proportion))
    overlay$Category <- factor(as.character(overlay$Category),
                               levels = category_levels)
    if (!"N" %in% names(overlay)) overlay$N <- 1
    overlay$N <- suppressWarnings(as.numeric(overlay$N))
    overlay$N[!is.finite(overlay$N) | overlay$N <= 0] <- 1
    overlay <- overlay[
      is.finite(overlay$Theta) & is.finite(overlay$Proportion) &
        !is.na(overlay$Category),
      ,
      drop = FALSE
    ]
    if (nrow(overlay) > 0L) {
      p <- p +
        ggplot2::geom_point(
          data = overlay,
          ggplot2::aes(
            x = Theta,
            y = Proportion,
            fill = Category,
            size = N
          ),
          inherit.aes = FALSE,
          shape = 21,
          colour = "grey20",
          stroke = 0.25,
          alpha = 0.78
        ) +
        ggplot2::scale_size_continuous(range = c(1.3, 4), name = "Bin N")
    }
  }

  if (identical(facet_by, "curve_group") && group_count > 1L) {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(CurveGroup))
  }
  p <- p +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    .mfrm_ggplot_theme() +
    ggplot2::theme(
      legend.position = "bottom",
      panel.grid.minor = ggplot2::element_blank()
    )
  p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
  .mfrm_ggplot_labs(
    p,
    payload,
    x = "Theta / logit",
    y = "Category probability",
    fallback = "Category characteristic curves"
  )
}

.mfrm_ggplot_bubble <- function(payload) {
  tbl <- as.data.frame(payload$table %||% data.frame(),
                       stringsAsFactors = FALSE)
  if (!all(c("Facet", "Level", "Infit", "Outfit") %in% names(tbl))) {
    stop("Bubble conversion requires `table` with Facet, Level, Infit, and Outfit columns.",
         call. = FALSE)
  }
  view <- as.character(payload$view %||% "measure")
  fit_stat <- as.character(payload$fit_stat %||% "Infit")
  if (!fit_stat %in% c("Infit", "Outfit")) fit_stat <- "Infit"
  if (!view %in% c("measure", "fit_measure", "infit_outfit")) {
    view <- "measure"
  }
  if (identical(view, "infit_outfit")) {
    tbl$FitX <- suppressWarnings(as.numeric(tbl$Infit))
    tbl$FitY <- suppressWarnings(as.numeric(tbl$Outfit))
    x_lab <- "Infit MnSq"
    y_lab <- "Outfit MnSq"
  } else if (identical(view, "fit_measure")) {
    if (!"Estimate" %in% names(tbl)) {
      stop("Fit-pathway conversion requires an `Estimate` column.",
           call. = FALSE)
    }
    tbl$FitX <- suppressWarnings(as.numeric(tbl[[fit_stat]]))
    tbl$FitY <- suppressWarnings(as.numeric(tbl$Estimate))
    x_lab <- paste0(fit_stat, " Mean Square")
    y_lab <- "Measure (logits)"
  } else {
    if (!"Estimate" %in% names(tbl)) {
      stop("Measure-fit conversion requires an `Estimate` column.",
           call. = FALSE)
    }
    tbl$FitX <- suppressWarnings(as.numeric(tbl$Estimate))
    tbl$FitY <- suppressWarnings(as.numeric(tbl[[fit_stat]]))
    x_lab <- "Measure (logits)"
    y_lab <- paste0(fit_stat, " Mean Square")
  }
  tbl <- tbl[is.finite(tbl$FitX) & is.finite(tbl$FitY), , drop = FALSE]
  if (nrow(tbl) == 0L) {
    stop("No finite bubble rows are available for ggplot conversion.",
         call. = FALSE)
  }
  radius <- suppressWarnings(as.numeric(payload$radius %||% NA_real_))
  if (length(radius) != nrow(tbl) || all(!is.finite(radius))) {
    tbl$Radius <- 3
  } else {
    radius[!is.finite(radius)] <- stats::median(radius[is.finite(radius)])
    radius_max <- max(radius, na.rm = TRUE)
    if (!is.finite(radius_max) || radius_max <= 0) radius_max <- 1
    tbl$Radius <- 2 + 5 * radius / radius_max
  }
  tbl$Facet <- as.character(tbl$Facet)

  fit_range <- suppressWarnings(as.numeric(payload$fit_range %||% c(0.5, 1.5)))
  if (length(fit_range) != 2L || !all(is.finite(fit_range)) ||
      fit_range[1] >= fit_range[2]) {
    fit_range <- c(0.5, 1.5)
  }
  if (identical(view, "infit_outfit")) {
    band <- data.frame(
      XMin = fit_range[1],
      XMax = fit_range[2],
      YMin = fit_range[1],
      YMax = fit_range[2],
      stringsAsFactors = FALSE
    )
  } else if (identical(view, "fit_measure")) {
    y_rng <- range(tbl$FitY, finite = TRUE)
    y_pad <- if (diff(y_rng) > 0) 0.08 * diff(y_rng) else 0.5
    band <- data.frame(
      XMin = fit_range[1],
      XMax = fit_range[2],
      YMin = y_rng[1] - y_pad,
      YMax = y_rng[2] + y_pad,
      stringsAsFactors = FALSE
    )
  } else {
    x_rng <- range(tbl$FitX, finite = TRUE)
    x_pad <- if (diff(x_rng) > 0) 0.08 * diff(x_rng) else 0.5
    band <- data.frame(
      XMin = x_rng[1] - x_pad,
      XMax = x_rng[2] + x_pad,
      YMin = fit_range[1],
      YMax = fit_range[2],
      stringsAsFactors = FALSE
    )
  }

  p <- ggplot2::ggplot() +
    ggplot2::geom_rect(
      data = band,
      ggplot2::aes(xmin = XMin, xmax = XMax, ymin = YMin, ymax = YMax),
      inherit.aes = FALSE,
      fill = "#E8F0FE",
      colour = NA,
      alpha = 0.55
    ) +
    ggplot2::geom_point(
      data = tbl,
      ggplot2::aes(x = FitX, y = FitY, colour = Facet, size = Radius),
      alpha = 0.72
    ) +
    ggplot2::scale_size_identity() +
    .mfrm_ggplot_theme() +
    ggplot2::theme(legend.position = "right")
  p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
  .mfrm_ggplot_labs(
    p,
    payload,
    x = x_lab,
    y = y_lab,
    fallback = "Fit pathway"
  )
}

.mfrm_rescale_ggplot_numeric <- function(x, to = c(0.25, 1.8), fallback = NULL) {
  x <- suppressWarnings(as.numeric(x))
  if (length(x) == 0L) return(numeric(0))
  finite <- is.finite(x)
  if (!any(finite)) {
    return(rep(fallback %||% mean(to), length(x)))
  }
  rng <- range(x[finite], finite = TRUE)
  out <- rep(fallback %||% mean(to), length(x))
  if (is.finite(diff(rng)) && diff(rng) > sqrt(.Machine$double.eps)) {
    out[finite] <- to[1] + (x[finite] - rng[1]) * diff(to) / diff(rng)
  } else {
    out[finite] <- fallback %||% mean(to)
  }
  out
}

.mfrm_ggplot_network <- function(payload) {
  nodes <- as.data.frame(payload$node_plot %||% data.frame(),
                         stringsAsFactors = FALSE)
  edges <- as.data.frame(payload$edge_plot %||% data.frame(),
                         stringsAsFactors = FALSE)
  if (!all(c("PlotX", "PlotY", "NodeColor", "NodeSize") %in% names(nodes))) {
    stop("Network ggplot conversion requires `node_plot` with PlotX, PlotY, NodeColor, and NodeSize columns.",
         call. = FALSE)
  }
  nodes$PlotX <- suppressWarnings(as.numeric(nodes$PlotX))
  nodes$PlotY <- suppressWarnings(as.numeric(nodes$PlotY))
  nodes$NodeSize <- suppressWarnings(as.numeric(nodes$NodeSize))
  nodes <- nodes[is.finite(nodes$PlotX) & is.finite(nodes$PlotY), , drop = FALSE]
  if (nrow(nodes) == 0L) {
    stop("No finite network node coordinates are available for ggplot conversion.",
         call. = FALSE)
  }
  if (!"NodeLabel" %in% names(nodes)) {
    label_col <- intersect(c("Level", "Rater", "Node"), names(nodes))[1]
    nodes$NodeLabel <- if (!is.na(label_col)) as.character(nodes[[label_col]]) else ""
  }
  nodes$NodeLabel <- as.character(nodes$NodeLabel)
  nodes$NodeLabel[is.na(nodes$NodeLabel)] <- ""
  nodes$.NodeSizeGG <- .mfrm_rescale_ggplot_numeric(
    nodes$NodeSize,
    to = c(2.5, 5.8),
    fallback = 4.2
  )

  if ("Facet" %in% names(nodes)) {
    nodes$NodeGroup <- as.character(nodes$Facet)
  } else if ("SeverityIndex" %in% names(nodes)) {
    sev <- suppressWarnings(as.numeric(nodes$SeverityIndex))
    nodes$NodeGroup <- ifelse(
      is.finite(sev) & sev > 0,
      "More severe",
      ifelse(is.finite(sev) & sev < 0, "More lenient", "Balanced")
    )
  } else {
    nodes$NodeGroup <- "Rater"
  }
  nodes$NodeGroup[is.na(nodes$NodeGroup) | !nzchar(nodes$NodeGroup)] <- "Node"
  group_colours <- stats::setNames(
    as.character(nodes$NodeColor),
    nodes$NodeGroup
  )
  group_colours <- group_colours[!duplicated(names(group_colours))]

  edges_ok <- all(c("PlotX", "PlotY", "PlotXEnd", "PlotYEnd", "EdgeWidth") %in%
                    names(edges))
  if (nrow(edges) > 0L && edges_ok) {
    edge_cols <- c("PlotX", "PlotY", "PlotXEnd", "PlotYEnd", "EdgeWidth")
    edges[edge_cols] <- lapply(edges[edge_cols], function(z) {
      suppressWarnings(as.numeric(z))
    })
    edges <- edges[
      is.finite(edges$PlotX) & is.finite(edges$PlotY) &
        is.finite(edges$PlotXEnd) & is.finite(edges$PlotYEnd),
      ,
      drop = FALSE
    ]
    edges$.EdgeWidthGG <- .mfrm_rescale_ggplot_numeric(
      edges$EdgeWidth,
      to = c(0.25, 1.45),
      fallback = 0.55
    )
  } else {
    edges <- data.frame()
  }
  if (nrow(edges) > 0L && !"EdgeColor" %in% names(edges)) {
    edges$EdgeColor <- "#64748b"
  }

  directed <- isTRUE(payload$directed %||% FALSE)
  p <- ggplot2::ggplot()
  if (nrow(edges) > 0L) {
    segment_args <- list(
      data = edges,
      mapping = ggplot2::aes(
        x = .data$PlotX,
        y = .data$PlotY,
        xend = .data$PlotXEnd,
        yend = .data$PlotYEnd,
        colour = .data$EdgeColor,
        linewidth = .data$.EdgeWidthGG
      ),
      inherit.aes = FALSE,
      alpha = 0.72,
      lineend = "round"
    )
    if (isTRUE(directed)) {
      segment_args$arrow <- grid::arrow(
        length = grid::unit(0.11, "inches"),
        type = "closed"
      )
    }
    p <- p + do.call(ggplot2::geom_segment, segment_args)
  }
  p <- p +
    ggplot2::geom_point(
      data = nodes,
      ggplot2::aes(
        x = .data$PlotX,
        y = .data$PlotY,
        fill = .data$NodeGroup,
        size = .data$.NodeSizeGG
      ),
      inherit.aes = FALSE,
      shape = 21,
      colour = "grey20",
      stroke = 0.28,
      alpha = 0.94
    )
  label_nodes <- nodes[nzchar(nodes$NodeLabel), , drop = FALSE]
  if (nrow(label_nodes) > 0L) {
    p <- p + ggplot2::geom_text(
      data = label_nodes,
      ggplot2::aes(
        x = .data$PlotX,
        y = .data$PlotY,
        label = .data$NodeLabel
      ),
      inherit.aes = FALSE,
      size = 2.6,
      vjust = -0.85,
      colour = "grey15",
      check_overlap = TRUE
    )
  }
  p <- p +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_fill_manual(values = group_colours, name = NULL) +
    ggplot2::scale_size_identity() +
    ggplot2::scale_linewidth_identity() +
    ggplot2::coord_equal() +
    .mfrm_ggplot_theme() +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      legend.position = "bottom"
    )
  .mfrm_ggplot_labs(
    p,
    payload,
    fallback = "Network diagnostic"
  )
}

.mfrm_ggplot_wright_map <- function(payload) {
  loc <- as.data.frame(payload$locations %||% data.frame(),
                       stringsAsFactors = FALSE)
  if (!all(c("PlotType", "Group", "Label", "Estimate", "X") %in% names(loc))) {
    stop("Wright-map conversion requires `locations` with PlotType, Group, Label, Estimate, and X columns.",
         call. = FALSE)
  }
  loc$Estimate <- suppressWarnings(as.numeric(loc$Estimate))
  loc$X <- suppressWarnings(as.numeric(loc$X))
  loc <- loc[is.finite(loc$Estimate) & is.finite(loc$X), , drop = FALSE]
  if (nrow(loc) == 0L) {
    stop("No finite Wright-map locations are available for ggplot conversion.",
         call. = FALSE)
  }

  group_levels <- as.character(payload$group_levels %||% unique(loc$Group))
  group_levels <- group_levels[nzchar(group_levels)]
  n_groups <- length(group_levels)
  y_range <- suppressWarnings(as.numeric(payload$y_range %||%
                                           range(loc$Estimate, finite = TRUE)))
  if (length(y_range) != 2L || !all(is.finite(y_range)) ||
      diff(y_range) <= sqrt(.Machine$double.eps)) {
    y_center <- mean(loc$Estimate, na.rm = TRUE)
    y_range <- y_center + c(-0.5, 0.5)
  }
  y_pad <- 0.04 * diff(y_range)
  y_limits <- y_range + c(-y_pad, y_pad)
  pretty_y <- pretty(y_range, n = 6)

  hist_data <- payload$person_hist
  hist_df <- data.frame()
  hist_band <- 0.85
  if (is.list(hist_data) &&
      length(hist_data$counts) > 0L &&
      length(hist_data$breaks) == length(hist_data$counts) + 1L) {
    hist_counts <- suppressWarnings(as.numeric(hist_data$counts))
    hist_max <- max(hist_counts, na.rm = TRUE)
    if (!is.finite(hist_max) || hist_max <= 0) hist_max <- 1
    hist_df <- data.frame(
      XLeft = -hist_band * hist_counts / hist_max,
      XRight = 0,
      YBottom = suppressWarnings(as.numeric(utils::head(hist_data$breaks, -1L))),
      YTop = suppressWarnings(as.numeric(utils::tail(hist_data$breaks, -1L))),
      Count = hist_counts,
      stringsAsFactors = FALSE
    )
    hist_df <- hist_df[
      is.finite(hist_df$YBottom) & is.finite(hist_df$YTop),
      ,
      drop = FALSE
    ]
  }

  p <- ggplot2::ggplot()
  if (nrow(hist_df) > 0L) {
    p <- p + ggplot2::geom_rect(
      data = hist_df,
      ggplot2::aes(
        xmin = XLeft,
        xmax = XRight,
        ymin = YBottom,
        ymax = YTop
      ),
      inherit.aes = FALSE,
      fill = "#94A3B8",
      colour = "white",
      linewidth = 0.2,
      alpha = 0.65
    )
  }

  group_shade <- data.frame()
  if (n_groups > 0L) {
    odd <- seq_len(n_groups)[seq_len(n_groups) %% 2L == 1L]
    group_shade <- data.frame(
      XLeft = odd - 0.5,
      XRight = odd + 0.5,
      YBottom = y_limits[1],
      YTop = y_limits[2],
      stringsAsFactors = FALSE
    )
  }
  if (nrow(group_shade) > 0L) {
    p <- p + ggplot2::geom_rect(
      data = group_shade,
      ggplot2::aes(
        xmin = XLeft,
        xmax = XRight,
        ymin = YBottom,
        ymax = YTop
      ),
      inherit.aes = FALSE,
      fill = "#EEF2F7",
      colour = NA,
      alpha = 0.55
    )
  }

  density_df <- as.data.frame(payload$group %||% data.frame(),
                              stringsAsFactors = FALSE)
  density_groups <- character()
  if (nrow(density_df) > 0L &&
      all(c("Group", "Theta", "Density") %in% names(density_df))) {
    density_df$Theta <- suppressWarnings(as.numeric(density_df$Theta))
    density_df$Density <- suppressWarnings(as.numeric(density_df$Density))
    density_df <- density_df[
      is.finite(density_df$Theta) & is.finite(density_df$Density),
      ,
      drop = FALSE
    ]
    density_max <- max(density_df$Density, na.rm = TRUE)
    if (is.finite(density_max) && density_max > 0 && nrow(density_df) > 1L) {
      density_df$DensityX <- -hist_band * density_df$Density / density_max
      density_groups <- unique(as.character(density_df$Group))
      p <- p + ggplot2::geom_path(
        data = density_df,
        ggplot2::aes(x = DensityX, y = Theta, colour = Group, group = Group),
        inherit.aes = FALSE,
        linewidth = 0.75,
        alpha = 0.95
      )
    }
  }

  summary_df <- as.data.frame(payload$group_summary %||% data.frame(),
                              stringsAsFactors = FALSE)
  if (nrow(summary_df) > 0L &&
      all(c("XBase", "Min", "Max", "Q1", "Q3", "Median", "PlotType") %in% names(summary_df))) {
    numeric_cols <- c("XBase", "Min", "Max", "Q1", "Q3", "Median")
    summary_df[numeric_cols] <- lapply(summary_df[numeric_cols], function(z) {
      suppressWarnings(as.numeric(z))
    })
    summary_df <- summary_df[
      is.finite(summary_df$XBase) & is.finite(summary_df$Min) &
        is.finite(summary_df$Max),
      ,
      drop = FALSE
    ]
    if (nrow(summary_df) > 0L) {
      p <- p +
        ggplot2::geom_segment(
          data = summary_df,
          ggplot2::aes(
            x = XBase,
            xend = XBase,
            y = Min,
            yend = Max,
            colour = PlotType
          ),
          inherit.aes = FALSE,
          linewidth = 0.6,
          alpha = 0.45
        ) +
        ggplot2::geom_segment(
          data = summary_df,
          ggplot2::aes(
            x = XBase,
            xend = XBase,
            y = Q1,
            yend = Q3,
            colour = PlotType
          ),
          inherit.aes = FALSE,
          linewidth = 2.2,
          alpha = 0.85
        ) +
        ggplot2::geom_segment(
          data = summary_df,
          ggplot2::aes(
            x = XBase - 0.12,
            xend = XBase + 0.12,
            y = Median,
            yend = Median
          ),
          inherit.aes = FALSE,
          colour = "grey15",
          linewidth = 0.45
        )
    }
  }

  stats_df <- as.data.frame(payload$person_stats %||% data.frame(),
                            stringsAsFactors = FALSE)
  if (nrow(stats_df) > 0L) {
    stats_lines <- data.frame(
      Statistic = c("Person median", "Person mean"),
      Value = suppressWarnings(as.numeric(c(stats_df$Median[1], stats_df$Mean[1]))),
      LineType = c("dashed", "dotted"),
      stringsAsFactors = FALSE
    )
    stats_lines <- stats_lines[is.finite(stats_lines$Value), , drop = FALSE]
    if (nrow(stats_lines) > 0L) {
      p <- p + ggplot2::geom_segment(
        data = stats_lines,
        ggplot2::aes(
          x = -hist_band,
          xend = 0,
          y = Value,
          yend = Value,
          linetype = Statistic
        ),
        inherit.aes = FALSE,
        colour = "grey25",
        linewidth = 0.45
      )
    }
  }

  ci_df <- data.frame()
  if (all(c("CI_Lower", "CI_Upper") %in% names(loc))) {
    ci_df <- loc[
      is.finite(suppressWarnings(as.numeric(loc$CI_Lower))) &
        is.finite(suppressWarnings(as.numeric(loc$CI_Upper))),
      ,
      drop = FALSE
    ]
    if (nrow(ci_df) > 0L) {
      ci_df$CI_Lower <- suppressWarnings(as.numeric(ci_df$CI_Lower))
      ci_df$CI_Upper <- suppressWarnings(as.numeric(ci_df$CI_Upper))
    }
  } else if ("SE" %in% names(loc)) {
    ci_df <- loc[is.finite(suppressWarnings(as.numeric(loc$SE))), , drop = FALSE]
    if (nrow(ci_df) > 0L) {
      ci_df$CI_Lower <- ci_df$Estimate - 1.96 * suppressWarnings(as.numeric(ci_df$SE))
      ci_df$CI_Upper <- ci_df$Estimate + 1.96 * suppressWarnings(as.numeric(ci_df$SE))
    }
  }
  if (nrow(ci_df) > 0L) {
    p <- p + ggplot2::geom_segment(
      data = ci_df,
      ggplot2::aes(
        x = X,
        xend = X,
        y = CI_Lower,
        yend = CI_Upper,
        colour = PlotType
      ),
      inherit.aes = FALSE,
      linewidth = 0.45,
      alpha = 0.65
    )
  }

  colour_values <- c(
    `Facet level` = "#1B9E77",
    `Step threshold` = "#D95F02"
  )
  if (length(density_groups) > 0L) {
    density_colours <- grDevices::hcl.colors(
      max(3L, length(density_groups)),
      "Dark 3"
    )[seq_along(density_groups)]
    colour_values <- c(
      colour_values,
      stats::setNames(density_colours, density_groups)
    )
  }

  p <- p +
    ggplot2::geom_point(
      data = loc,
      ggplot2::aes(x = X, y = Estimate, colour = PlotType, shape = PlotType),
      inherit.aes = FALSE,
      size = 2.1,
      alpha = 0.9
    )

  label_df <- as.data.frame(payload$label_points %||% data.frame(),
                            stringsAsFactors = FALSE)
  if (nrow(label_df) > 0L && all(c("X", "Estimate", "Label") %in% names(label_df))) {
    label_df$X <- suppressWarnings(as.numeric(label_df$X))
    label_df$Estimate <- suppressWarnings(as.numeric(label_df$Estimate))
    label_df <- label_df[
      is.finite(label_df$X) & is.finite(label_df$Estimate) &
        nzchar(as.character(label_df$Label)),
      ,
      drop = FALSE
    ]
    if (nrow(label_df) > 0L) {
      label_df$Label <- truncate_axis_label(label_df$Label, width = 14L)
      p <- p + ggplot2::geom_text(
        data = label_df,
        ggplot2::aes(x = X + 0.06, y = Estimate, label = Label),
        inherit.aes = FALSE,
        hjust = 0,
        size = 2.6,
        colour = "grey20",
        check_overlap = TRUE
      )
    }
  }

  p <- p +
    ggplot2::geom_hline(
      yintercept = pretty_y,
      colour = "#D9DDE3",
      linewidth = 0.25
    ) +
    ggplot2::geom_hline(
      yintercept = 0,
      colour = "grey35",
      linetype = "dashed",
      linewidth = 0.35
    ) +
    ggplot2::scale_colour_manual(values = colour_values, na.value = "#2B6CB0") +
    ggplot2::scale_shape_manual(
      values = c(`Facet level` = 16, `Step threshold` = 17),
      na.value = 16
    ) +
    ggplot2::scale_x_continuous(
      breaks = c(-hist_band / 2, seq_len(n_groups)),
      labels = c("Persons", truncate_axis_label(group_levels, width = 16L)),
      limits = c(-hist_band - 0.08, max(1, n_groups) + 0.85),
      expand = ggplot2::expansion(mult = c(0.01, 0.04))
    ) +
    ggplot2::coord_cartesian(ylim = y_limits, clip = "on") +
    .mfrm_ggplot_theme() +
    ggplot2::guides(
      fill = "none",
      shape = "none",
      linetype = "none",
      colour = ggplot2::guide_legend(title = NULL)
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid.major.x = ggplot2::element_blank(),
      legend.position = "right",
      legend.title = ggplot2::element_blank()
    )
  .mfrm_ggplot_labs(
    p,
    payload,
    x = NULL,
    y = "Logit scale",
    fallback = "Wright map"
  )
}

.mfrm_ggplot_pathway_map <- function(payload) {
  exp_df <- as.data.frame(payload$expected %||% data.frame(),
                          stringsAsFactors = FALSE)
  if (!all(c("Theta", "ExpectedScore", "CurveGroup") %in% names(exp_df))) {
    stop("Pathway-map conversion requires `expected` with Theta, ExpectedScore, and CurveGroup columns.",
         call. = FALSE)
  }
  exp_df$Theta <- suppressWarnings(as.numeric(exp_df$Theta))
  exp_df$ExpectedScore <- suppressWarnings(as.numeric(exp_df$ExpectedScore))
  exp_df <- exp_df[
    is.finite(exp_df$Theta) & is.finite(exp_df$ExpectedScore),
    ,
    drop = FALSE
  ]
  if (nrow(exp_df) == 0L) {
    stop("No finite pathway expected-score rows are available for ggplot conversion.",
         call. = FALSE)
  }
  groups <- unique(as.character(exp_df$CurveGroup))
  y_range <- range(exp_df$ExpectedScore, finite = TRUE)
  if (!all(is.finite(y_range)) || diff(y_range) <= sqrt(.Machine$double.eps)) {
    y_range <- y_range[1] + c(-0.5, 0.5)
  }

  dominance <- as.data.frame(payload$dominance_regions %||% data.frame(),
                             stringsAsFactors = FALSE)
  use_strips <- nrow(dominance) > 0L &&
    all(c("CurveGroup", "Category", "ThetaStart", "ThetaEnd", "ThetaMid") %in%
          names(dominance)) &&
    length(groups) <= 8L
  band_h <- max(diff(y_range) * 0.035, 0.08)
  band_gap <- band_h * 0.35
  band_top <- y_range[1] - band_h * 0.45
  band_pad <- if (isTRUE(use_strips)) {
    (band_h + band_gap) * length(groups) + band_h
  } else {
    0
  }
  y_limits <- c(y_range[1] - band_pad, y_range[2])

  p <- ggplot2::ggplot()
  if (isTRUE(use_strips)) {
    group_index <- stats::setNames(seq_along(groups), groups)
    dominance$ThetaStart <- suppressWarnings(as.numeric(dominance$ThetaStart))
    dominance$ThetaEnd <- suppressWarnings(as.numeric(dominance$ThetaEnd))
    dominance$ThetaMid <- suppressWarnings(as.numeric(dominance$ThetaMid))
    dominance$BandRow <- unname(group_index[as.character(dominance$CurveGroup)])
    dominance$YTop <- band_top - (dominance$BandRow - 1L) * (band_h + band_gap)
    dominance$YBottom <- dominance$YTop - band_h
    dominance$YMid <- (dominance$YTop + dominance$YBottom) / 2
    dominance <- dominance[
      is.finite(dominance$ThetaStart) & is.finite(dominance$ThetaEnd) &
        is.finite(dominance$YTop) & is.finite(dominance$YBottom),
      ,
      drop = FALSE
    ]
    if (nrow(dominance) > 0L) {
      p <- p +
        ggplot2::geom_rect(
          data = dominance,
          ggplot2::aes(
            xmin = ThetaStart,
            xmax = ThetaEnd,
            ymin = YBottom,
            ymax = YTop,
            fill = CurveGroup
          ),
          inherit.aes = FALSE,
          colour = "white",
          linewidth = 0.2,
          alpha = 0.16
        ) +
        ggplot2::geom_text(
          data = dominance,
          ggplot2::aes(x = ThetaMid, y = YMid, label = Category, colour = CurveGroup),
          inherit.aes = FALSE,
          size = 2.4,
          show.legend = FALSE,
          check_overlap = TRUE
        )
    }
    band_labels <- data.frame(
      CurveGroup = groups,
      X = min(exp_df$Theta, na.rm = TRUE),
      Y = band_top - (seq_along(groups) - 1L) * (band_h + band_gap) - band_h / 2,
      Label = truncate_axis_label(groups, width = 14L),
      stringsAsFactors = FALSE
    )
    p <- p + ggplot2::geom_text(
      data = band_labels,
      ggplot2::aes(x = X, y = Y, label = Label, colour = CurveGroup),
      inherit.aes = FALSE,
      hjust = 1,
      size = 2.5,
      show.legend = FALSE
    )
  }

  steps <- as.data.frame(payload$steps %||% data.frame(),
                         stringsAsFactors = FALSE)
  if (nrow(steps) > 0L &&
      all(c("Threshold", "PathY", "CurveGroup", "ThresholdLabel") %in% names(steps))) {
    steps$Threshold <- suppressWarnings(as.numeric(steps$Threshold))
    steps$PathY <- suppressWarnings(as.numeric(steps$PathY))
    steps$ThresholdLabelShort <- truncate_axis_label(steps$ThresholdLabel,
                                                     width = 6L)
    steps <- steps[is.finite(steps$Threshold) & is.finite(steps$PathY), ,
                   drop = FALSE]
    if (nrow(steps) > 0L) {
      p <- p +
        ggplot2::geom_vline(
          data = steps,
          ggplot2::aes(xintercept = Threshold, colour = CurveGroup),
          inherit.aes = FALSE,
          linetype = "dotted",
          linewidth = 0.35,
          alpha = 0.22,
          show.legend = FALSE
        )
    }
  }

  p <- p +
    ggplot2::geom_line(
      data = exp_df,
      ggplot2::aes(
        x = Theta,
        y = ExpectedScore,
        colour = CurveGroup,
        group = CurveGroup
      ),
      inherit.aes = FALSE,
      linewidth = 0.85
    )

  if (nrow(steps) > 0L) {
    p <- p +
      ggplot2::geom_point(
        data = steps,
        ggplot2::aes(x = Threshold, y = PathY, colour = CurveGroup),
        inherit.aes = FALSE,
        shape = 18,
        size = 2.2,
        show.legend = FALSE
      ) +
      ggplot2::geom_text(
        data = steps,
        ggplot2::aes(
          x = Threshold,
          y = PathY,
          label = ThresholdLabelShort,
          colour = CurveGroup
        ),
        inherit.aes = FALSE,
        vjust = -0.7,
        size = 2.4,
        show.legend = FALSE,
        check_overlap = TRUE
      )
  }

  endpoints <- as.data.frame(payload$endpoint_labels %||% data.frame(),
                             stringsAsFactors = FALSE)
  if (nrow(endpoints) > 0L &&
      all(c("Theta", "ExpectedScore", "CurveGroup") %in% names(endpoints)) &&
      length(groups) <= 6L) {
    endpoints$Theta <- suppressWarnings(as.numeric(endpoints$Theta))
    endpoints$ExpectedScore <- suppressWarnings(as.numeric(endpoints$ExpectedScore))
    endpoints <- endpoints[
      is.finite(endpoints$Theta) & is.finite(endpoints$ExpectedScore),
      ,
      drop = FALSE
    ]
    if (nrow(endpoints) > 0L) {
      endpoints$CurveGroupLabel <- truncate_axis_label(endpoints$CurveGroup,
                                                       width = 14L)
      p <- p + ggplot2::geom_text(
        data = endpoints,
        ggplot2::aes(
          x = Theta,
          y = ExpectedScore,
          label = CurveGroupLabel,
          colour = CurveGroup
        ),
        inherit.aes = FALSE,
        hjust = -0.05,
        size = 2.6,
        show.legend = FALSE,
        check_overlap = TRUE
      )
    }
  }

  fit_annotations <- as.data.frame(payload$pathway_annotations %||% data.frame(),
                                   stringsAsFactors = FALSE)
  if (nrow(fit_annotations) > 0L &&
      all(c("AnnotationType", "X", "Y", "FitStatus", "Underfit", "Overfit") %in%
            names(fit_annotations))) {
    fit_annotations$X <- suppressWarnings(as.numeric(fit_annotations$X))
    fit_annotations$Y <- suppressWarnings(as.numeric(fit_annotations$Y))
    fit_annotations$Underfit <- as.logical(fit_annotations$Underfit)
    fit_annotations$Overfit <- as.logical(fit_annotations$Overfit)
    fit_annotations <- fit_annotations[
      is.finite(fit_annotations$X) & is.finite(fit_annotations$Y) &
        fit_annotations$AnnotationType == "curve_fit" &
        (fit_annotations$Underfit | fit_annotations$Overfit),
      ,
      drop = FALSE
    ]
    if (nrow(fit_annotations) > 0L) {
      fit_annotations$FitStatus <- as.character(fit_annotations$FitStatus)
      p <- p + ggplot2::geom_point(
        data = fit_annotations,
        ggplot2::aes(x = X, y = Y, shape = FitStatus),
        inherit.aes = FALSE,
        size = 3,
        colour = "#C53030",
        stroke = 1
      )
    }
  }

  p <- p +
    ggplot2::geom_hline(
      yintercept = pretty(y_range, n = 6),
      colour = "#D9DDE3",
      linewidth = 0.25
    )
  p <- .mfrm_ggplot_add_reference_lines(p, payload$reference_lines)
  p <- p +
    ggplot2::coord_cartesian(ylim = y_limits, clip = "off") +
    .mfrm_ggplot_theme() +
    ggplot2::theme(
      legend.position = "bottom",
      panel.grid.minor = ggplot2::element_blank()
    )
  .mfrm_ggplot_labs(
    p,
    payload,
    x = "Theta / logit",
    y = "Expected score",
    fallback = "Pathway map"
  )
}

.mfrm_ggplot_from_tabular <- function(component, payload) {
  value <- component$value
  if (is.matrix(value)) {
    return(.mfrm_ggplot_matrix_heatmap(value, payload = payload))
  }
  df <- as.data.frame(value, stringsAsFactors = FALSE)
  if (all(c("Pair", "Effect") %in% names(df))) {
    return(.mfrm_ggplot_effect_summary(df, payload))
  }
  if (all(c("Theta", "Value") %in% names(df))) {
    return(.mfrm_ggplot_curve_data(df, payload))
  }
  if (all(c("Group", "Threshold") %in% names(df))) {
    return(.mfrm_ggplot_threshold_ladder(df, payload))
  }
  if ("Estimate" %in% names(df) &&
      length(intersect(c("Level", "Person", "Step", "Label", "Group"), names(df))) > 0L) {
    return(.mfrm_ggplot_estimate_rows(df, payload))
  }
  .mfrm_ggplot_numeric_fallback(df, payload)
}

#' Convert mfrmr plot data to a ggplot object
#'
#' @description
#' `as_ggplot()` converts an existing `mfrm_plot_data` object, supported
#' draw-free simulation plot lists, or any `mfrmr` object whose `plot()` method
#' supports `draw = FALSE`, into a `ggplot2` object. It is an optional rendering
#' layer: base-R plotting remains the default package renderer, while
#' `as_ggplot()` gives users a modifiable object for themes, scales, facets,
#' Quarto reports, and downstream export.
#'
#' The converter is intentionally conservative. It supports common
#' `mfrm_plot_data` shapes used by Wright maps, pathway maps, fit-pathway
#' displays, EAP power-sensitivity diagnostics, DIF/DFF summaries and heatmaps,
#' G-study/D-study planning plots, G-study design checks, simulation
#' design/recovery/signal handoff plots, category and information curves,
#' threshold ladders, network plot payloads, and
#' estimate/profile rows. When a payload cannot be inferred safely, use
#' [plot_data_components()] and [plot_data()] to build a custom figure directly.
#'
#' @param x An `mfrm_plot_data` object, a supported draw-free simulation plot
#'   list, or a fitted/report/review/simulation object with a
#'   `plot(..., draw = FALSE)` method.
#' @param type Optional plot type passed to `plot()` when `x` is not already an
#'   `mfrm_plot_data` object.
#' @param component Optional component inside the plot payload. When `NULL`,
#'   a suitable tabular component is selected automatically.
#' @param ... Additional arguments passed to `plot(..., draw = FALSE)` when
#'   `x` is not already an `mfrm_plot_data` object. For CCC payloads, the
#'   converter also accepts `slope_aes` (`"none"`, `"linewidth"`, `"alpha"`,
#'   or `"colour"`/`"color"`), `facet_by` (`"auto"`, `"none"`, or
#'   `"curve_group"`), `show_overlay`, and `show_dominance`.
#'
#' @details
#' Category characteristic curve payloads receive a dedicated converter.
#' Categories are colour-coded by default; for `GPCM`-style payloads with a
#' nonconstant `Slope` column, `slope_aes` can map the slope/discrimination
#' parameter to line width, alpha, or a continuous colour scale. For RSM and
#' PCM payloads the slope is constant, so the same arguments remain valid but
#' intentionally add little or no visual differentiation.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", maxit = 30)
#'
#' as_ggplot(fit, type = "wright")
#' as_ggplot(fit, type = "pathway")
#' as_ggplot(fit, type = "fit_pathway", fit_stat = "Outfit")
#' as_ggplot(plot(fit, type = "ccc", draw = FALSE))
#' as_ggplot(fit, type = "ccc", slope_aes = "linewidth")
#' as_ggplot(plot(fit, type = "ccc_overlay", draw = FALSE), show_overlay = TRUE)
#'
#' dff <- analyze_dff(
#'   fit,
#'   facet = "Rater",
#'   group = "Group",
#'   data = toy,
#'   method = "residual"
#' )
#' as_ggplot(plot_dif_summary(dff, draw = FALSE))
#' as_ggplot(plot_dif_heatmap(dff, metric = "obs_exp", draw = FALSE))
#' if (requireNamespace("igraph", quietly = TRUE)) {
#'   review <- build_mfrm_network_review(fit, facets = "Rater")
#'   as_ggplot(plot(review, type = "network", draw = FALSE))
#' }
#'
#' rec <- evaluate_mfrm_recovery(reps = 1, maxit = 30)
#' as_ggplot(plot(rec, type = "summary", metric = "rmse", draw = FALSE))
#'
#' if (requireNamespace("lme4", quietly = TRUE)) {
#'   gt <- mfrm_generalizability(fit)
#'   as_ggplot(plot(gt, draw = FALSE))
#'   design_check <- check_mfrm_generalizability_design(
#'     fit,
#'     random_interactions = c("Person:Rater", "Rater:Criterion")
#'   )
#'   as_ggplot(plot(design_check, draw = FALSE))
#'   ds <- mfrm_d_study(gt, data.frame(Rater = c(2, 3, 4), Criterion = 4))
#'   as_ggplot(plot(ds, draw = FALSE))
#' }
#' }
#' @export
as_ggplot <- function(x, type = NULL, component = NULL, ...) {
  UseMethod("as_ggplot")
}

#' @rdname as_ggplot
#' @export
as_ggplot.default <- function(x, type = NULL, component = NULL, ...) {
  dots <- list(...)
  ggplot_arg_names <- c(
    "slope_aes", "facet_by", "show_overlay", "show_dominance"
  )
  dot_names <- names(dots) %||% rep("", length(dots))
  ggplot_args <- nzchar(dot_names) & dot_names %in% ggplot_arg_names
  plot_dots <- dots[!ggplot_args]
  conversion_dots <- dots[ggplot_args]
  plot_obj <- do.call(
    as_mfrm_plot_data_object,
    c(list(x = x, type = type), plot_dots)
  )
  do.call(
    as_ggplot,
    c(list(x = plot_obj, component = component), conversion_dots)
  )
}

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_design_evaluation <- function(x, type = NULL, component = NULL, ...) {
  plot_obj <- plot(x, draw = FALSE, ...)
  as_ggplot(plot_obj, component = component)
}

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_design_evaluation_plot_data <- function(x, type = NULL, component = NULL, ...) {
  .require_ggplot2()
  payload <- as.list(x)
  if (!is.null(component)) {
    selected <- .mfrm_select_ggplot_component(payload, component = component)
    return(.mfrm_ggplot_from_tabular(selected, payload))
  }
  .mfrm_ggplot_simulation_scan(payload)
}

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_signal_detection <- function(x, type = NULL, component = NULL, ...) {
  plot_obj <- plot(x, draw = FALSE, ...)
  as_ggplot(plot_obj, component = component)
}

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_signal_detection_plot_data <- function(x, type = NULL, component = NULL, ...) {
  .require_ggplot2()
  payload <- as.list(x)
  if (!is.null(component)) {
    selected <- .mfrm_select_ggplot_component(payload, component = component)
    return(.mfrm_ggplot_from_tabular(selected, payload))
  }
  .mfrm_ggplot_simulation_scan(payload)
}

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_plot_data <- function(x, type = NULL, component = NULL, ...) {
  .require_ggplot2()
  payload <- x$data %||% list()
  dots <- list(...)
  slope_aes <- as.character(dots$slope_aes %||% "none")
  slope_aes <- match.arg(slope_aes, c("none", "linewidth", "alpha", "colour", "color"))
  if (identical(slope_aes, "color")) slope_aes <- "colour"
  facet_by <- as.character(dots$facet_by %||% "auto")
  facet_by <- match.arg(facet_by, c("auto", "none", "curve_group"))
  show_overlay <- isTRUE(dots$show_overlay %||% TRUE)
  show_dominance <- isTRUE(dots$show_dominance %||% FALSE)
  if (identical(x$name, "wright_map") && is.null(component)) {
    return(.mfrm_ggplot_wright_map(payload))
  }
  if (identical(x$name, "pathway_map") && is.null(component)) {
    return(.mfrm_ggplot_pathway_map(payload))
  }
  if (x$name %in% c("bubble", "fit_pathway") && is.null(component)) {
    return(.mfrm_ggplot_bubble(payload))
  }
  if (x$name %in% c("subset_connectivity", "rater_network") &&
      identical(as.character(payload$plot %||% ""), "network") &&
      is.null(component)) {
    return(.mfrm_ggplot_network(payload))
  }
  if (x$name %in% c(
    "category_characteristic_curves",
    "category_characteristic_curves_overlay"
  ) && is.null(component)) {
    return(.mfrm_ggplot_category_curves(
      payload,
      slope_aes = slope_aes,
      facet_by = facet_by,
      show_overlay = show_overlay,
      show_dominance = show_dominance
    ))
  }
  if (identical(x$name, "category_curves") &&
      identical(as.character(payload$plot %||% ""), "ccc") &&
      is.null(component)) {
    return(.mfrm_ggplot_category_curves(
      payload,
      slope_aes = slope_aes,
      facet_by = facet_by,
      show_overlay = show_overlay,
      show_dominance = show_dominance
    ))
  }
  if (identical(x$name, "dif_heatmap") && is.matrix(payload$matrix)) {
    settings <- payload$settings %||% list()
    return(.mfrm_ggplot_matrix_heatmap(
      payload$matrix,
      payload = payload,
      flag_matrix = payload$flag_matrix,
      value_digits = settings$value_digits %||% 2L,
      show_values = isTRUE(settings$show_values),
      flag_color = settings$flag_color %||% "black"
    ))
  }
  if (identical(x$name, "dif_summary") && is.data.frame(payload$data)) {
    return(.mfrm_ggplot_effect_summary(payload$data, payload))
  }
  if (identical(x$name, "eap_power_sensitivity") && is.data.frame(payload$data)) {
    return(.mfrm_ggplot_eap_power_sensitivity(payload))
  }
  if (identical(x$name, "recovery_simulation") && is.null(component)) {
    return(.mfrm_ggplot_recovery_simulation(payload))
  }
  if (identical(x$name, "recovery_assessment") && is.null(component)) {
    return(.mfrm_ggplot_recovery_assessment(payload))
  }
  if (identical(x$name, "generalizability") && is.null(component)) {
    return(.mfrm_ggplot_generalizability(payload))
  }
  if (identical(x$name, "generalizability_design_check") && is.null(component)) {
    return(.mfrm_ggplot_generalizability_design_check(payload))
  }
  if (identical(x$name, "generalizability_comparison") && is.null(component)) {
    return(.mfrm_ggplot_generalizability_comparison(payload))
  }
  if (identical(x$name, "d_study") && is.null(component)) {
    return(.mfrm_ggplot_d_study(payload))
  }
  component <- .mfrm_select_ggplot_component(payload, component = component)
  .mfrm_ggplot_from_tabular(component, payload)
}

truncate_axis_label <- function(x, width = 28L) {
  x <- as.character(x)
  width <- max(8L, as.integer(width))
  ifelse(nchar(x) > width, paste0(substr(x, 1, width - 3L), "..."), x)
}

draw_rotated_x_labels <- function(at,
                                  labels,
                                  srt = 45,
                                  cex = 0.85,
                                  line_offset = 0.08) {
  at <- as.numeric(at)
  labels <- as.character(labels)
  ok <- is.finite(at) & nzchar(labels)
  if (!any(ok)) return(invisible(NULL))

  at <- at[ok]
  labels <- labels[ok]
  graphics::axis(side = 1, at = at, labels = FALSE, tck = -0.02)

  usr <- graphics::par("usr")
  y <- usr[3] - line_offset * diff(usr[3:4])
  graphics::text(
    x = at,
    y = y,
    labels = labels,
    srt = srt,
    adj = 1,
    xpd = NA,
    cex = cex
  )
  invisible(NULL)
}

resolve_palette <- function(palette = NULL, defaults = character(0)) {
  defaults <- stats::setNames(as.character(defaults), names(defaults))
  if (length(defaults) == 0) return(defaults)
  if (is.null(palette) || length(palette) == 0) return(defaults)

  palette <- stats::setNames(as.character(palette), names(palette))
  nm <- names(palette)
  if (is.null(nm) || any(!nzchar(nm))) {
    take <- seq_len(min(length(defaults), length(palette)))
    defaults[take] <- palette[take]
    return(defaults)
  }
  hit <- intersect(names(defaults), nm)
  if (length(hit) > 0) defaults[hit] <- palette[hit]
  defaults
}

resolve_plot_preset <- function(preset = c("standard", "publication", "compact", "monochrome")) {
  if (length(preset) > 1L) preset <- preset[1L]
  preset <- match.arg(preset, c("standard", "publication", "compact", "monochrome"))
  switch(
    preset,
    standard = list(
      name = "standard",
      background = "white",
      foreground = "#1f2933",
      axis = "#334e68",
      grid = "#e5e7eb",
      fill_soft = "#dbeafe",
      fill_muted = "#cfe8f3",
      fill_warm = "#fee8d6",
      accent_primary = "#1f78b4",
      accent_secondary = "#d95f02",
      accent_tertiary = "#1b9e77",
      success = "#238b45",
      warn = "#b65e16",
      fail = "#b11f24",
      neutral = "#6b7280",
      axis_cex = 0.88,
      label_cex = 0.96,
      title_cex = 1
    ),
    publication = list(
      name = "publication",
      background = "#fcfdff",
      foreground = "#14213d",
      axis = "#223f5a",
      grid = "#d6dee6",
      fill_soft = "#d8eff5",
      fill_muted = "#d7e9f3",
      fill_warm = "#fde6cf",
      accent_primary = "#1b4965",
      accent_secondary = "#ca6702",
      accent_tertiary = "#2a9d8f",
      success = "#1b6f5f",
      warn = "#ad6a12",
      fail = "#9b2226",
      neutral = "#52606d",
      axis_cex = 0.9,
      label_cex = 0.98,
      title_cex = 1.05
    ),
    compact = list(
      name = "compact",
      background = "white",
      foreground = "#1f2933",
      axis = "#334e68",
      grid = "#eceff3",
      fill_soft = "#ddeefb",
      fill_muted = "#d9ebf5",
      fill_warm = "#feecd9",
      accent_primary = "#2c7fb8",
      accent_secondary = "#d95f02",
      accent_tertiary = "#31a354",
      success = "#238b45",
      warn = "#b65e16",
      fail = "#cb181d",
      neutral = "#6b7280",
      axis_cex = 0.82,
      label_cex = 0.9,
      title_cex = 0.95
    ),
    monochrome = list(
      name = "monochrome",
      background = "white",
      foreground = "gray10",
      axis = "gray20",
      grid = "gray85",
      fill_soft = "gray88",
      fill_muted = "gray78",
      fill_warm = "gray70",
      accent_primary = "gray15",
      accent_secondary = "gray45",
      accent_tertiary = "gray65",
      success = "gray30",
      warn = "gray45",
      fail = "gray10",
      neutral = "gray55",
      axis_cex = 0.88,
      label_cex = 0.96,
      title_cex = 1
    )
  )
}

apply_plot_preset <- function(style) {
  # Capture the caller's par() state and register an on.exit handler in
  # the caller's frame so graphical parameters are restored when the
  # calling function exits. This follows "Writing R Extensions" 2.1:
  # functions that modify par() must restore it. The envir=parent.frame()
  # pattern is the standard CRAN-safe form used by withr::defer and
  # friends -- see ?on.exit for the contract.
  old <- graphics::par(no.readonly = TRUE)
  do.call(
    base::on.exit,
    list(substitute(graphics::par(old), list(old = old)), add = TRUE),
    envir = parent.frame()
  )
  graphics::par(
    bg = style$background,
    fg = style$foreground,
    col.axis = style$axis,
    col.lab = style$axis,
    col.main = style$foreground,
    col.sub = style$axis,
    cex.axis = style$axis_cex,
    cex.lab = style$label_cex,
    cex.main = style$title_cex,
    lend = "round",
    ljoin = "round"
  )
  invisible(old)
}

barplot_rot45 <- function(height,
                          labels,
                          col,
                          border = "white",
                          main = NULL,
                          ylab = NULL,
                          label_angle = 45,
                          label_cex = 0.84,
                          mar_bottom = 8.2,
                          label_width = 22L,
                          add_grid = FALSE,
                          ...) {
  old_mar <- graphics::par("mar")
  on.exit(graphics::par(mar = old_mar), add = TRUE)
  mar <- old_mar
  mar[1] <- max(mar[1], mar_bottom)
  graphics::par(mar = mar)

  mids <- graphics::barplot(
    height = height,
    names.arg = FALSE,
    col = col,
    border = border,
    main = main,
    ylab = ylab,
    ...
  )
  if (isTRUE(add_grid)) {
    ylim <- graphics::par("usr")[3:4]
    graphics::abline(h = pretty(ylim, n = 5), col = "#ececec", lty = 1)
  }
  draw_rotated_x_labels(
    at = mids,
    labels = truncate_axis_label(labels, width = label_width),
    srt = label_angle,
    cex = label_cex,
    line_offset = 0.085
  )
  invisible(mids)
}

stack_fair_raw_tables <- function(raw_by_facet) {
  if (is.null(raw_by_facet) || length(raw_by_facet) == 0) return(data.frame())
  out <- lapply(names(raw_by_facet), function(facet) {
    df <- raw_by_facet[[facet]]
    if (is.null(df) || nrow(df) == 0) return(NULL)
    df <- as.data.frame(df, stringsAsFactors = FALSE)
    df$Facet <- facet
    df
  })
  out <- out[!vapply(out, is.null, logical(1))]
  if (length(out) == 0) data.frame() else dplyr::bind_rows(out)
}

# Delta-method variance Var(X | eta) for each fair_average_table row.
#
# Returns Var(X | eta = sign * Measure) at each row of `fair_df`, so the
# caller can form delta-method standard errors on the observed-score
# scale via |dE[X]/d_delta| * SE(delta) = Var(X) * SE(delta) (a known
# Rasch-family identity). This helper is intentionally RSM/PCM only. Bounded
# GPCM plot CIs use the opt-in structural fair-average SE columns produced by
# fair_average_table(fair_se = TRUE). Rows that cannot be resolved return
# NA_real_ so callers can suppress CI whiskers.
.fair_average_delta_variance <- function(fit, fair_df) {
  n <- nrow(fair_df)
  if (n == 0L) return(numeric(0))
  spec <- tryCatch(build_step_curve_spec(fit), error = function(e) NULL)
  if (is.null(spec) || length(spec$groups) == 0L) {
    return(rep(NA_real_, n))
  }
  model <- toupper(as.character(fit$config$model[1]))
  if (identical(model, "GPCM")) {
    return(rep(NA_real_, n))
  }
  step_facet <- as.character(fit$config$step_facet %||% NA_character_)
  rating_min <- suppressWarnings(as.numeric(fit$prep$rating_min %||% 0))
  if (!is.finite(rating_min)) rating_min <- 0
  facet_signs <- fit$config$facet_signs %||%
    stats::setNames(rep(-1, length(fit$config$facet_names)),
                    fit$config$facet_names)

  single_group_var <- function(eta_scalar, step_cum) {
    n_cat <- length(step_cum)
    if (n_cat < 2L) return(NA_real_)
    k_vec <- rating_min + 0:(n_cat - 1L)
    probs <- category_prob_rsm(eta_scalar, step_cum)
    expected <- as.numeric(probs %*% k_vec)
    second <- as.numeric(probs %*% (k_vec^2))
    max(second - expected^2, 0)
  }

  vars <- rep(NA_real_, n)
  fair_facet <- as.character(fair_df$Facet)
  fair_level <- as.character(fair_df$Level)
  fair_meas <- suppressWarnings(as.numeric(fair_df$Measure))

  for (i in seq_len(n)) {
    if (!is.finite(fair_meas[i])) next
    sign_i <- suppressWarnings(as.numeric(facet_signs[fair_facet[i]] %||% -1))
    if (!is.finite(sign_i)) sign_i <- -1
    eta_i <- sign_i * fair_meas[i]

    if (model == "RSM") {
      g <- spec$groups[[1L]]
      vars[i] <- single_group_var(eta_i, g$step_cum)
    } else if (!is.na(step_facet) && identical(fair_facet[i], step_facet) &&
               fair_level[i] %in% names(spec$groups)) {
      # PCM / GPCM row that IS the step facet: use that level's tau vector.
      vars[i] <- single_group_var(eta_i, spec$groups[[fair_level[i]]]$step_cum)
    } else if (model %in% c("PCM", "GPCM")) {
      # Row from another facet: average variance across step-facet levels.
      per_group <- vapply(
        spec$groups,
        function(g) single_group_var(eta_i, g$step_cum),
        numeric(1)
      )
      per_group <- per_group[is.finite(per_group)]
      if (length(per_group) > 0L) vars[i] <- mean(per_group)
    }
  }
  vars
}

resolve_unexpected_bundle <- function(x,
                                      diagnostics = NULL,
                                      abs_z_min = 2,
                                      prob_max = 0.30,
                                      top_n = 100,
                                      rule = "either") {
  if (inherits(x, "mfrm_fit")) {
    return(unexpected_response_table(
      fit = x,
      diagnostics = diagnostics,
      abs_z_min = abs_z_min,
      prob_max = prob_max,
      top_n = top_n,
      rule = rule
    ))
  }
  if (is.list(x) && all(c("table", "summary", "thresholds") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from unexpected_response_table().")
}

resolve_fair_bundle <- function(x,
                                diagnostics = NULL,
                                facets = NULL,
                                totalscore = TRUE,
                                umean = 0,
                                uscale = 1,
                                udecimals = 2,
                                reference = "both",
                                label_style = "both",
                                omit_unobserved = FALSE,
                                xtreme = 0) {
  if (inherits(x, "mfrm_fit")) {
    return(fair_average_table(
      fit = x,
      diagnostics = diagnostics,
      facets = facets,
      totalscore = totalscore,
      umean = umean,
      uscale = uscale,
      udecimals = udecimals,
      reference = reference,
      label_style = label_style,
      omit_unobserved = omit_unobserved,
      xtreme = xtreme
    ))
  }
  if (is.list(x) && all(c("raw_by_facet", "by_facet", "stacked") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from fair_average_table().")
}

resolve_displacement_bundle <- function(x,
                                        diagnostics = NULL,
                                        facets = NULL,
                                        anchored_only = FALSE,
                                        abs_displacement_warn = 0.5,
                                        abs_t_warn = 2,
                                        top_n = NULL) {
  if (inherits(x, "mfrm_fit")) {
    return(displacement_table(
      fit = x,
      diagnostics = diagnostics,
      facets = facets,
      anchored_only = anchored_only,
      abs_displacement_warn = abs_displacement_warn,
      abs_t_warn = abs_t_warn,
      top_n = top_n
    ))
  }
  if (is.list(x) && all(c("table", "summary", "thresholds") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from displacement_table().")
}

resolve_interrater_bundle <- function(x,
                                      diagnostics = NULL,
                                      rater_facet = NULL,
                                      context_facets = NULL,
                                      exact_warn = 0.50,
                                      corr_warn = 0.30,
                                      top_n = NULL) {
  if (inherits(x, "mfrm_fit")) {
    return(interrater_agreement_table(
      fit = x,
      diagnostics = diagnostics,
      rater_facet = rater_facet,
      context_facets = context_facets,
      exact_warn = exact_warn,
      corr_warn = corr_warn,
      top_n = top_n
    ))
  }
  if (is.list(x) && all(c("summary", "pairs", "settings") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from interrater_agreement_table().")
}

resolve_facets_chisq_bundle <- function(x,
                                        diagnostics = NULL,
                                        fixed_p_max = 0.05,
                                        random_p_max = 0.05,
                                        top_n = NULL) {
  if (inherits(x, "mfrm_fit")) {
    return(facets_chisq_table(
      fit = x,
      diagnostics = diagnostics,
      fixed_p_max = fixed_p_max,
      random_p_max = random_p_max,
      top_n = top_n
    ))
  }
  if (is.list(x) && all(c("table", "summary", "thresholds") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from facets_chisq_table().")
}

resolve_strict_marginal_plot_bundle <- function(x,
                                                diagnostics = NULL,
                                                require_pairwise = FALSE) {
  if (inherits(x, "mfrm_fit")) {
    diagnostics <- diagnostics %||%
      diagnose_mfrm(x, residual_pca = "none", diagnostic_mode = "both")
  } else if (inherits(x, "mfrm_diagnostics") || (is.list(x) && !is.null(x$marginal_fit))) {
    diagnostics <- x
  } else {
    stop("`x` must be an mfrm_fit object or output from diagnose_mfrm().", call. = FALSE)
  }

  marginal_fit <- diagnostics$marginal_fit %||% NULL
  if (!is.list(marginal_fit)) {
    stop(
      "Strict marginal diagnostics are not available. Run diagnose_mfrm(..., diagnostic_mode = \"both\") first.",
      call. = FALSE
    )
  }
  if (!isTRUE(marginal_fit$available)) {
    reason <- as.character(
      marginal_fit$summary$Reason[1] %||%
        marginal_fit$notes[1] %||%
        "Strict marginal diagnostics are not available for this run."
    )
    stop(
      paste0("Strict marginal diagnostics are not available: ", reason),
      call. = FALSE
    )
  }
  if (isTRUE(require_pairwise) && !isTRUE(marginal_fit$pairwise$available)) {
    stop(
      paste0(
        "Strict pairwise local-dependence diagnostics are not available: ",
        as.character(
          marginal_fit$pairwise$summary$Reason[1] %||%
            marginal_fit$notes[1] %||%
            "Pairwise diagnostics were not computed for this run."
        )
      ),
      call. = FALSE
    )
  }

  list(
    diagnostics = diagnostics,
    marginal_fit = marginal_fit
  )
}

format_marginal_cell_label <- function(cell_type, step_facet, facet, level, category) {
  if (identical(as.character(cell_type %||% ""), "facet_level")) {
    return(paste0(
      as.character(facet %||% "Facet"),
      ": ",
      as.character(level %||% "Level"),
      " | Cat ",
      as.character(category %||% "?")
    ))
  }
  step_label <- if (!is.na(step_facet) && nzchar(as.character(step_facet))) {
    paste0("Step facet: ", as.character(step_facet))
  } else {
    "Common scale"
  }
  paste0(step_label, " | Cat ", as.character(category %||% "?"))
}

format_marginal_pair_label <- function(facet, level1, level2) {
  paste0(
    as.character(facet %||% "Facet"),
    ": ",
    as.character(level1 %||% "Level 1"),
    " vs ",
    as.character(level2 %||% "Level 2")
  )
}

#' Plot strict marginal-fit follow-up cells using base R
#'
#' @param x Output from [fit_mfrm()] or [diagnose_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param plot_type `"std_residual"` or `"prop_diff"`.
#' @param top_n Maximum cells shown.
#' @param facet Optional facet name used to keep only matching facet-level rows.
#'   When `NULL`, the plot uses the mixed top-cell table returned by the strict
#'   marginal screen.
#' @param main Optional custom plot title.
#' @param palette Optional named color overrides. Recognized names:
#'   `positive`, `negative`, `flag`.
#' @param label_angle X-axis label angle.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`,
#'   or `"monochrome"`).
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' This helper visualizes the largest first-order strict marginal-fit cells from
#' `diagnose_mfrm(..., diagnostic_mode = "both")` or
#' `diagnostic_mode = "marginal_fit"`.
#'
#' The `"std_residual"` view ranks cells by the absolute standardized residual
#' from posterior-integrated expected category counts. The `"prop_diff"` view
#' ranks the same cells by the signed observed-minus-expected proportion gap.
#'
#' Use this plot after `summary(diagnostics)` indicates strict marginal flags.
#' The display is exploratory: it highlights which facet/category cells deserve
#' follow-up, but it is not a standalone inferential test.
#'
#' @section Interpreting output:
#' - Positive bars mean the observed category usage exceeded the posterior-
#'   expected marginal usage for that cell.
#' - Negative bars mean the observed usage fell below the posterior-expected
#'   marginal usage.
#' - Red bars indicate the current strict marginal warning rule was triggered by
#'   `|StdResidual| >= abs_z_warn`.
#'
#' @section Typical workflow:
#' 1. Fit with [fit_mfrm()] using `method = "MML"` for `RSM` / `PCM`.
#' 2. Run [diagnose_mfrm()] with `diagnostic_mode = "both"`.
#' 3. Use `plot_marginal_fit()` to inspect the largest strict marginal cells.
#' 4. Follow up with [rating_scale_table()] or substantive design review.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [diagnose_mfrm()], [rating_scale_table()], [plot_marginal_pairwise()],
#'   [mfrmr_visual_diagnostics]
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(
#'   toy,
#'   "Person",
#'   c("Rater", "Criterion"),
#'   "Score",
#'   method = "MML",
#'   quad_points = 7,
#'   maxit = 30
#' )
#' diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
#' p <- plot_marginal_fit(diag, draw = FALSE, preset = "publication")
#' p$data$preset
#' if (interactive()) {
#'   plot_marginal_fit(
#'     diag,
#'     plot_type = "prop_diff",
#'     draw = TRUE,
#'     preset = "publication"
#'   )
#' }
#' }
#' @export
plot_marginal_fit <- function(x,
                              diagnostics = NULL,
                              plot_type = c("std_residual", "prop_diff"),
                              top_n = 20,
                              facet = NULL,
                              main = NULL,
                              palette = NULL,
                              label_angle = 45,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              draw = TRUE) {
  plot_type <- match.arg(tolower(plot_type), c("std_residual", "prop_diff"))
  top_n <- max(1L, as.integer(top_n))
  style <- resolve_plot_preset(preset)
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      positive = style$accent_secondary,
      negative = style$accent_tertiary,
      flag = style$fail
    )
  )

  bundle <- resolve_strict_marginal_plot_bundle(x, diagnostics = diagnostics, require_pairwise = FALSE)
  tbl <- as.data.frame(bundle$marginal_fit$top_cells %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) {
    stop("No strict marginal cell rows are available for plotting.", call. = FALSE)
  }
  if (!is.null(facet)) {
    facet <- as.character(facet[1])
    tbl <- tbl[as.character(tbl$Facet %||% "") == facet, , drop = FALSE]
  }
  if (nrow(tbl) == 0) {
    stop("No strict marginal cell rows matched the requested `facet` filter.", call. = FALSE)
  }

  metric_vals <- if (identical(plot_type, "std_residual")) {
    abs(suppressWarnings(as.numeric(tbl$StdResidual)))
  } else {
    abs(suppressWarnings(as.numeric(tbl$PropDiff)))
  }
  ord <- order(metric_vals, decreasing = TRUE, na.last = NA)
  use <- ord[seq_len(min(length(ord), top_n))]
  sub <- tbl[use, , drop = FALSE]
  sub$CellLabel <- mapply(
    format_marginal_cell_label,
    cell_type = sub$CellType,
    step_facet = sub$StepFacet,
    facet = sub$Facet,
    level = sub$Level,
    category = sub$Category,
    USE.NAMES = FALSE
  )

  values <- if (identical(plot_type, "std_residual")) {
    suppressWarnings(as.numeric(sub$StdResidual))
  } else {
    suppressWarnings(as.numeric(sub$PropDiff))
  }
  flagged <- as.logical(sub$FlaggedAbsZ %||% FALSE)
  cols <- ifelse(
    flagged,
    pal["flag"],
    ifelse(values >= 0, pal["positive"], pal["negative"])
  )

  abs_z_warn <- as.numeric(bundle$marginal_fit$thresholds$abs_z_warn %||% 2)
  plot_title <- switch(
    plot_type,
    std_residual = "Strict marginal category screening scores",
    prop_diff = "Strict marginal category gaps"
  )
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- if (identical(plot_type, "std_residual")) {
    sprintf(
      "Latent-integrated first-order counts; exploratory screen; top %d cells by |StdResidual|.",
      nrow(sub)
    )
  } else {
    sprintf(
      "Latent-integrated first-order counts; exploratory screen; top %d cells by |Observed - Expected| proportion gap.",
      nrow(sub)
    )
  }
  plot_legend <- if (identical(plot_type, "std_residual")) {
    new_plot_legend(
      label = c("Positive residual", "Negative residual", "Flagged cell"),
      role = c("direction", "direction", "warning"),
      aesthetic = c("bar", "bar", "bar"),
      value = c(pal["positive"], pal["negative"], pal["flag"])
    )
  } else {
    new_plot_legend(
      label = c("Positive gap", "Negative gap", "Strict-warning cell"),
      role = c("direction", "direction", "warning"),
      aesthetic = c("bar", "bar", "bar"),
      value = c(pal["positive"], pal["negative"], pal["flag"])
    )
  }
  plot_reference <- if (identical(plot_type, "std_residual")) {
    new_reference_lines(
      axis = c("h", "h", "h"),
      value = c(-abs_z_warn, 0, abs_z_warn),
      label = c("Negative review threshold", "Centered reference", "Positive review threshold"),
      linetype = c("dashed", "solid", "dashed"),
      role = c("threshold", "reference", "threshold")
    )
  } else {
    new_reference_lines(
      axis = "h",
      value = 0,
      label = "Centered reference",
      linetype = "solid",
      role = "reference"
    )
  }

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    barplot_rot45(
      height = values,
      labels = sub$CellLabel,
      col = cols,
      main = plot_title,
      ylab = if (identical(plot_type, "std_residual")) {
        "Standardized residual"
      } else {
        "Observed - expected proportion"
      },
      label_angle = label_angle,
      mar_bottom = 10.2,
      label_width = 28L,
      add_grid = TRUE
    )
    graphics::abline(h = 0, lty = 1, col = grDevices::adjustcolor(style$foreground, alpha.f = 0.75))
    if (identical(plot_type, "std_residual")) {
      graphics::abline(h = c(-abs_z_warn, abs_z_warn), lty = 2, col = grDevices::adjustcolor(style$neutral, alpha.f = 0.9))
    }
    graphics::legend(
      "topleft",
      legend = as.character(plot_legend$label),
      fill = as.character(plot_legend$value),
      bty = "n",
      cex = 0.82
    )
  }

  out <- new_mfrm_plot_data(
    "marginal_fit",
    list(
      plot = plot_type,
      table = sub,
      full_table = tbl,
      summary = bundle$marginal_fit$summary,
      facet_summary = bundle$marginal_fit$facet_level$summary_stats,
      step_summary = bundle$marginal_fit$step_or_scale$summary_stats,
      guidance = bundle$marginal_fit$guidance,
      thresholds = bundle$marginal_fit$thresholds,
      notes = bundle$marginal_fit$notes,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name
    )
  )
  invisible(out)
}

#' Plot strict pairwise local-dependence follow-up using base R
#'
#' @param x Output from [fit_mfrm()] or [diagnose_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param metric `"exact"` or `"adjacent"`.
#' @param top_n Maximum level pairs shown.
#' @param facet Optional facet name used to keep only matching pairwise rows.
#' @param main Optional custom plot title.
#' @param palette Optional named color overrides. Recognized names: `ok`, `flag`.
#' @param label_angle X-axis label angle.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' This helper visualizes the strict pairwise local-dependence follow-up derived
#' from posterior-integrated expected exact and adjacent agreement.
#'
#' The `"exact"` view ranks level pairs by the absolute exact-agreement
#' standardized residual. The `"adjacent"` view uses the adjacent-agreement
#' standardized residual instead. Both are exploratory corroboration screens for
#' strict marginal-fit flags.
#'
#' @section Interpreting output:
#' - Positive bars mean the observed agreement exceeded the posterior-expected
#'   agreement for that level pair.
#' - Negative bars mean the observed agreement fell below the posterior-expected
#'   agreement.
#' - Red bars indicate the pair exceeded the current strict-warning threshold.
#'
#' @section Typical workflow:
#' 1. Fit with [fit_mfrm()] using `method = "MML"` for `RSM` / `PCM`.
#' 2. Run [diagnose_mfrm()] with `diagnostic_mode = "both"`.
#' 3. Use `plot_marginal_pairwise()` to inspect level pairs behind pairwise
#'    local-dependence flags.
#' 4. Corroborate with legacy diagnostics, design review, and substantive
#'    interpretation before making claims.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [diagnose_mfrm()], [plot_marginal_fit()], [mfrmr_visual_diagnostics]
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(
#'   toy,
#'   "Person",
#'   c("Rater", "Criterion"),
#'   "Score",
#'   method = "MML",
#'   quad_points = 7,
#'   maxit = 30
#' )
#' diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
#' p <- plot_marginal_pairwise(diag, draw = FALSE, preset = "publication")
#' p$data$preset
#' if (interactive()) {
#'   plot_marginal_pairwise(
#'     diag,
#'     metric = "adjacent",
#'     draw = TRUE,
#'     preset = "publication"
#'   )
#' }
#' }
#' @export
plot_marginal_pairwise <- function(x,
                                   diagnostics = NULL,
                                   metric = c("exact", "adjacent"),
                                   top_n = 20,
                                   facet = NULL,
                                   main = NULL,
                                   palette = NULL,
                                   label_angle = 45,
                                   preset = c("standard", "publication", "compact", "monochrome"),
                                   draw = TRUE) {
  metric <- match.arg(tolower(metric), c("exact", "adjacent"))
  top_n <- max(1L, as.integer(top_n))
  style <- resolve_plot_preset(preset)
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      ok = style$accent_primary,
      flag = style$fail
    )
  )

  bundle <- resolve_strict_marginal_plot_bundle(x, diagnostics = diagnostics, require_pairwise = TRUE)
  tbl <- as.data.frame(bundle$marginal_fit$pairwise$top_pairs %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) {
    stop("No strict pairwise local-dependence rows are available for plotting.", call. = FALSE)
  }
  if (!is.null(facet)) {
    facet <- as.character(facet[1])
    tbl <- tbl[as.character(tbl$Facet %||% "") == facet, , drop = FALSE]
  }
  if (nrow(tbl) == 0) {
    stop("No strict pairwise rows matched the requested `facet` filter.", call. = FALSE)
  }

  metric_vals <- if (identical(metric, "exact")) {
    abs(suppressWarnings(as.numeric(tbl$ExactStdResidual)))
  } else {
    abs(suppressWarnings(as.numeric(tbl$AdjacentStdResidual)))
  }
  ord <- order(metric_vals, decreasing = TRUE, na.last = NA)
  use <- ord[seq_len(min(length(ord), top_n))]
  sub <- tbl[use, , drop = FALSE]
  sub$PairLabel <- mapply(
    format_marginal_pair_label,
    facet = sub$Facet,
    level1 = sub$Level1,
    level2 = sub$Level2,
    USE.NAMES = FALSE
  )

  values <- if (identical(metric, "exact")) {
    suppressWarnings(as.numeric(sub$ExactStdResidual))
  } else {
    suppressWarnings(as.numeric(sub$AdjacentStdResidual))
  }
  flagged <- if (identical(metric, "exact")) {
    as.logical(sub$FlaggedExact %||% FALSE)
  } else {
    as.logical(sub$FlaggedAdjacent %||% FALSE)
  }
  cols <- ifelse(flagged, pal["flag"], pal["ok"])
  abs_z_warn <- as.numeric(bundle$marginal_fit$thresholds$abs_z_warn %||% 2)

  plot_title <- switch(
    metric,
    exact = "Strict pairwise exact-agreement screening scores",
    adjacent = "Strict pairwise adjacent-agreement screening scores"
  )
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- sprintf(
    "Exploratory local-dependence follow-up; top %d level pairs by |%s StdResidual|.",
    nrow(sub),
    if (identical(metric, "exact")) "Exact" else "Adjacent"
  )
  plot_legend <- new_plot_legend(
    label = c("Within current warning band", "Flagged level pair"),
    role = c("status", "status"),
    aesthetic = c("bar", "bar"),
    value = c(pal["ok"], pal["flag"])
  )
  plot_reference <- new_reference_lines(
    axis = c("h", "h", "h"),
    value = c(-abs_z_warn, 0, abs_z_warn),
    label = c("Negative review threshold", "Centered reference", "Positive review threshold"),
    linetype = c("dashed", "solid", "dashed"),
    role = c("threshold", "reference", "threshold")
  )

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    barplot_rot45(
      height = values,
      labels = sub$PairLabel,
      col = cols,
      main = plot_title,
      ylab = if (identical(metric, "exact")) {
        "Exact-agreement standardized residual"
      } else {
        "Adjacent-agreement standardized residual"
      },
      label_angle = label_angle,
      mar_bottom = 10.2,
      label_width = 30L,
      add_grid = TRUE
    )
    graphics::abline(h = 0, lty = 1, col = grDevices::adjustcolor(style$foreground, alpha.f = 0.75))
    graphics::abline(h = c(-abs_z_warn, abs_z_warn), lty = 2, col = grDevices::adjustcolor(style$neutral, alpha.f = 0.9))
    graphics::legend(
      "topleft",
      legend = as.character(plot_legend$label),
      fill = as.character(plot_legend$value),
      bty = "n",
      cex = 0.82
    )
  }

  out <- new_mfrm_plot_data(
    "marginal_pairwise",
    list(
      plot = metric,
      table = sub,
      full_table = tbl,
      summary = bundle$marginal_fit$pairwise$facet_summary,
      pair_stats = bundle$marginal_fit$pairwise$pair_stats,
      guidance = bundle$marginal_fit$guidance,
      thresholds = bundle$marginal_fit$thresholds,
      notes = bundle$marginal_fit$notes,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name
    )
  )
  invisible(out)
}

#' Plot unexpected responses using base R
#'
#' @param x Output from [fit_mfrm()] or [unexpected_response_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param abs_z_min Absolute standardized-residual cutoff.
#' @param prob_max Maximum observed-category probability cutoff.
#' @param top_n Maximum rows used from the unexpected table.
#' @param rule Flagging rule (`"either"` or `"both"`).
#' @param plot_type `"scatter"` or `"severity"`.
#' @param main Optional custom plot title.
#' @param palette Optional named color overrides (`higher`, `lower`, `bar`).
#' @param label_angle X-axis label angle for `"severity"` bar plot.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' This helper visualizes flagged observations from [unexpected_response_table()].
#' An observation is "unexpected" when its standardised residual and/or
#' observed-category probability exceed user-specified cutoffs.
#'
#' The **severity index** is a composite ranking metric that combines the
#' absolute standardised residual \eqn{|Z|} and the negative log
#' probability \eqn{-\log_{10} P_{\mathrm{obs}}}.  Higher severity
#' indicates responses that are more surprising under the fitted model.
#'
#' The `rule` parameter controls flagging logic:
#' - `"either"`: flag if \eqn{|Z| \ge} `abs_z_min` **or**
#'   \eqn{P_{\mathrm{obs}} \le} `prob_max`.
#' - `"both"`: flag only if **both** conditions hold simultaneously.
#'
#' Under common thresholds, many well-behaved runs will produce relatively few
#' flagged observations, but the flagged proportion is design- and
#' model-dependent. Treat the output as a screening display rather than a
#' calibrated goodness-of-fit test.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"scatter"` (default)}{X-axis: standardized residual \eqn{Z}.
#'     Y-axis: \eqn{-\log_{10}(P_{\mathrm{obs}})} (negative log of
#'     observed-category probability; higher = more surprising).
#'     Points colored orange when the observed score is *higher* than
#'     expected, teal when *lower*.  Dashed lines mark `abs_z_min` and
#'     `prob_max` thresholds.  Clusters of points in the upper corners
#'     indicate systematic misfit patterns worth investigating.}
#'   \item{`"severity"`}{Ranked bar chart of the composite severity index
#'     for the `top_n` most unexpected responses.  Bar length reflects
#'     the combined unexpectedness; labels identify the specific
#'     person-facet combination.  Use for QC triage and case-level
#'     prioritization.}
#' }
#'
#' @section Interpreting output:
#' Scatter plot: farther from zero on x-axis = larger residual mismatch;
#' higher y-axis = lower observed-category probability.  A uniform
#' scatter with few points beyond the threshold lines indicates fewer locally
#' surprising responses under the current thresholds.
#'
#' Severity plot: focuses on the most extreme observations for targeted
#' case review.  Look for recurring persons or facet levels among the
#' top entries---repeated appearances may signal rater misuse, scoring
#' errors, or model misspecification.
#'
#' @section Typical workflow:
#' 1. Fit model and run [diagnose_mfrm()].
#' 2. Start with `"scatter"` to assess global unexpected pattern.
#' 3. Switch to `"severity"` for case prioritization.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [unexpected_response_table()], [plot_fair_average()], [plot_displacement()],
#'   [plot_qc_dashboard()], [mfrmr_visual_diagnostics]
#' @examplesIf interactive()
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#' p <- plot_unexpected(fit, abs_z_min = 1.5, prob_max = 0.4, top_n = 10, draw = FALSE)
#' if (interactive()) {
#'   plot_unexpected(
#'     fit,
#'     abs_z_min = 1.5,
#'     prob_max = 0.4,
#'     top_n = 10,
#'     plot_type = "severity",
#'     preset = "publication",
#'     main = "Unexpected Response Severity (Customized)",
#'     palette = c(higher = "#d95f02", lower = "#1b9e77", bar = "#2b8cbe"),
#'     label_angle = 45
#'   )
#' }
#' @export
plot_unexpected <- function(x,
                            diagnostics = NULL,
                            abs_z_min = 2,
                            prob_max = 0.30,
                            top_n = 100,
                            rule = c("either", "both"),
                            plot_type = c("scatter", "severity"),
                            main = NULL,
                            palette = NULL,
                            label_angle = 45,
                            preset = c("standard", "publication", "compact", "monochrome"),
                            draw = TRUE) {
  rule <- match.arg(tolower(rule), c("either", "both"))
  plot_type <- match.arg(tolower(plot_type), c("scatter", "severity"))
  top_n <- max(1L, as.integer(top_n))
  style <- resolve_plot_preset(preset)
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      higher = style$accent_secondary,
      lower = style$accent_tertiary,
      bar = style$accent_primary
    )
  )

  bundle <- resolve_unexpected_bundle(
    x = x,
    diagnostics = diagnostics,
    abs_z_min = abs_z_min,
    prob_max = prob_max,
    top_n = top_n,
    rule = rule
  )
  tbl <- as.data.frame(bundle$table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) {
    stop("No unexpected responses were flagged under the current thresholds.")
  }
  tbl <- tbl[seq_len(min(nrow(tbl), top_n)), , drop = FALSE]
  plot_title <- if (plot_type == "scatter") "Unexpected responses" else "Unexpected response severity"
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- sprintf("Rule: %s; |Z| >= %s; P(obs) <= %s", rule, format(abs_z_min), format(prob_max))
  plot_legend <- if (plot_type == "scatter") {
    new_plot_legend(
      label = c("Higher than expected", "Lower than expected"),
      role = c("direction", "direction"),
      aesthetic = c("point", "point"),
      value = c(pal["higher"], pal["lower"])
    )
  } else {
    new_plot_legend(
      label = "Severity index",
      role = "bar",
      aesthetic = "fill",
      value = pal["bar"]
    )
  }
  plot_reference <- if (plot_type == "scatter") {
    new_reference_lines(
      axis = c("v", "v", "h"),
      value = c(-abs_z_min, abs_z_min, -log10(prob_max)),
      label = c("Residual review threshold", "Residual review threshold", "Probability review threshold"),
      linetype = c("dashed", "dashed", "dashed"),
      role = c("threshold", "threshold", "threshold")
    )
  } else {
    new_reference_lines()
  }

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    if (plot_type == "scatter") {
      x_vals <- suppressWarnings(as.numeric(tbl$StdResidual))
      y_vals <- -log10(pmax(suppressWarnings(as.numeric(tbl$ObsProb)), .Machine$double.xmin))
      dirs <- as.character(tbl$Direction)
      cols <- ifelse(dirs == "Higher than expected", pal["higher"], pal["lower"])
      cols[!is.finite(x_vals) | !is.finite(y_vals)] <- "gray60"
      graphics::plot(
        x = x_vals,
        y = y_vals,
        xlab = "Standardized residual",
        ylab = expression(-log[10](P[obs])),
        main = plot_title,
        pch = 16,
        col = cols
      )
      graphics::abline(h = pretty(graphics::par("usr")[3:4], n = 5), col = style$grid, lty = 1)
      graphics::abline(v = pretty(graphics::par("usr")[1:2], n = 5), col = style$grid, lty = 1)
      graphics::abline(v = c(-abs_z_min, abs_z_min), lty = 2, col = style$neutral)
      graphics::abline(h = -log10(prob_max), lty = 2, col = style$neutral)
      graphics::legend(
        "topleft",
        legend = c("Higher than expected", "Lower than expected"),
        col = c(pal["higher"], pal["lower"]),
        pch = 16,
        bty = "n",
        cex = 0.85
      )
    } else {
      sev <- suppressWarnings(as.numeric(tbl$Severity))
      ord <- order(sev, decreasing = TRUE, na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sev <- sev[use]
      labels <- if ("Row" %in% names(tbl)) {
        paste0("Row ", tbl$Row[use])
      } else {
        paste0("Case ", seq_along(use))
      }
      barplot_rot45(
        height = sev,
        labels = labels,
        col = pal["bar"],
        main = plot_title,
        ylab = "Severity index",
        label_angle = label_angle,
        mar_bottom = 8.2,
        add_grid = TRUE
      )
    }
  }

  out <- new_mfrm_plot_data(
    "unexpected",
    list(
      plot = plot_type,
      table = tbl,
      summary = bundle$summary,
      thresholds = bundle$thresholds,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name
    )
  )
  invisible(out)
}

#' Plot fair-average diagnostics using base R
#'
#' @param x Output from [fit_mfrm()] or [fair_average_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param facet Optional facet name for level-wise lollipop plots.
#' @param metric Adjusted-score metric. Accepts legacy names (`"FairM"`,
#'   `"FairZ"`) and package-native names (`"AdjustedAverage"`,
#'   `"StandardizedAdjustedAverage"`).
#' @param plot_type `"difference"` or `"scatter"`.
#' @param top_n Maximum levels shown for `"difference"` plot.
#' @param show_ci Logical. When `TRUE`, draw approximate
#'   confidence-interval whiskers on the fair metric using a
#'   delta-method propagation from the logit `Measure` standard error
#'   to the observed-score scale. The derivative equals the implied
#'   score variance `Var(X | Measure)`, so the fair-scale standard
#'   error is `Var(X) * ModelSE`. CI bounds are clipped to the rating
#'   range. Rows where the score variance is effectively zero (levels
#'   whose measure sits near the rating boundary, so the delta-method
#'   approximation becomes uninformative) are drawn with an open
#'   circle and excluded from the whiskers; the excluded count is
#'   reported in the subtitle. For bounded `GPCM` fits, this option requests
#'   `fair_average_table(fair_se = TRUE)` when `x` is a fit object and uses the
#'   structural delta-method fair-average CI columns when they are available.
#'   If `x` is a precomputed fair-average bundle without those columns, the
#'   plot records an unavailable-CI note.
#' @param ci_level Confidence level used when `show_ci = TRUE`;
#'   default `0.95`. The returned plot-data object gains `CI_Lower`,
#'   `CI_Upper`, and `CI_Level` columns for downstream reuse.
#' @param draw If `TRUE`, draw with base graphics.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param ... Additional arguments passed to [fair_average_table()] when `x` is `mfrm_fit`.
#'
#' @details
#' Fair-average plots compare observed scoring tendency against model-based
#' fair metrics.
#'
#' **FairM** is the model-predicted mean score for each element, adjusting
#' for the ability distribution of persons actually encountered.  It
#' answers: "What average score would this rater/criterion produce if all
#' raters/criteria saw the same mix of persons?"
#'
#' **FairZ** standardises FairM to a z-score across elements within each
#' facet, making it easier to compare relative severity across facets
#' with different raw-score scales.
#'
#' Use FairM when the raw-score metric is meaningful (e.g., reporting
#' average ratings on the original 1--4 scale).
#' Use FairZ when comparing standardised severity ranks across facets.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"difference"` (default)}{Lollipop chart showing the gap between
#'     observed and fair-average score for each element.  X-axis:
#'     Observed - Fair metric.  Y-axis: element labels.  Points colored
#'     teal (lenient, gap >= 0) or orange (severe, gap < 0).  Ordered by
#'     absolute gap.}
#'   \item{`"scatter"`}{Scatter plot of fair metric (x) vs observed average
#'     (y) with an identity line.  Points colored by facet.  Useful for
#'     checking overall alignment between observed and model-adjusted
#'     scores.}
#' }
#'
#' @section Interpreting output:
#' Difference plot: ranked element-level gaps (`Observed - Fair`), useful
#' for triage of potentially lenient/severe levels.
#'
#' Scatter plot: global agreement pattern relative to the identity line.
#'
#' Larger absolute gaps suggest stronger divergence between observed and
#' model-adjusted scoring.
#'
#' @section Typical workflow:
#' 1. Start with `plot_type = "difference"` to find largest discrepancies.
#' 2. Use `plot_type = "scatter"` to check overall alignment pattern.
#' 3. Follow up with facet-level diagnostics for flagged levels.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' With `draw = FALSE`, the returned plot data includes `title`, `subtitle`,
#' `legend`, `reference_lines`, and the stacked fair-average data.
#' @seealso [fair_average_table()], [plot_unexpected()], [plot_displacement()],
#'   [plot_qc_dashboard()], [mfrmr_visual_diagnostics]
#' @concept confidence intervals
#' @concept visual diagnostics
#' @concept fair averages
#' @examplesIf interactive()
#' toy_full <- load_mfrmr_data("example_core")
#' toy_people <- unique(toy_full$Person)[1:12]
#' toy <- toy_full[toy_full$Person %in% toy_people, , drop = FALSE]
#' fit <- suppressWarnings(
#'   fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#' )
#' p <- plot_fair_average(fit, metric = "AdjustedAverage", draw = FALSE)
#' if (interactive()) {
#'   plot_fair_average(fit, metric = "AdjustedAverage", plot_type = "difference")
#' }
#' @export
plot_fair_average <- function(x,
                              diagnostics = NULL,
                              facet = NULL,
                              metric = c("AdjustedAverage", "StandardizedAdjustedAverage", "FairM", "FairZ"),
                              plot_type = c("difference", "scatter"),
                              top_n = 40,
                              show_ci = FALSE,
                              ci_level = 0.95,
                              draw = TRUE,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              ...) {
  metric <- match.arg(metric, c("AdjustedAverage", "StandardizedAdjustedAverage", "FairM", "FairZ"))
  metric <- switch(
    metric,
    AdjustedAverage = "FairM",
    StandardizedAdjustedAverage = "FairZ",
    metric
  )
  plot_type <- match.arg(tolower(plot_type), c("difference", "scatter"))
  top_n <- max(1L, as.integer(top_n))
  if (!is.numeric(ci_level) || length(ci_level) != 1L ||
      !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1) {
    stop("`ci_level` must be a single number in (0, 1).", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)

  bundle <- if (inherits(x, "mfrm_fit")) {
    fair_args <- list(...)
    x_model <- toupper(as.character(x$config$model[1] %||% NA_character_))
    if (isTRUE(show_ci) && identical(x_model, "GPCM") &&
        is.null(fair_args$fair_se)) {
      fair_args$fair_se <- TRUE
    }
    if (isTRUE(show_ci) && identical(x_model, "GPCM") &&
        isTRUE(fair_args$fair_se) && is.null(fair_args$ci_level)) {
      fair_args$ci_level <- ci_level
    }
    do.call(
      fair_average_table,
      c(list(fit = x, diagnostics = diagnostics), fair_args)
    )
  } else {
    resolve_fair_bundle(x)
  }

  fair_df <- stack_fair_raw_tables(bundle$raw_by_facet)
  if (nrow(fair_df) == 0) stop("No fair-average data available.")
  needed <- c("Facet", "Level", "ObservedAverage", "FairM", "FairZ")
  if (!all(needed %in% names(fair_df))) {
    stop("Fair-average table does not include required columns.")
  }
  fair_df <- fair_df[is.finite(fair_df$ObservedAverage) & is.finite(fair_df[[metric]]), , drop = FALSE]
  if (nrow(fair_df) == 0) stop("No finite fair-average rows available.")

  if (!is.null(facet)) {
    fair_df <- fair_df[as.character(fair_df$Facet) == as.character(facet[1]), , drop = FALSE]
    if (nrow(fair_df) == 0) stop("Requested `facet` was not found in fair-average output.")
  }
  fair_df$Gap <- fair_df$ObservedAverage - fair_df[[metric]]

  fair_model <- toupper(as.character(
    bundle$settings$model %||%
      if (inherits(x, "mfrm_fit")) x$config$model[1] else NA_character_
  ))

  # Delta-method CI for the fair-average metric on the observed-score
  # scale. We use the Rasch identity |dE[X]/d_delta| = Var(X | delta)
  # evaluated at the facet-level measure, so the SE of the expected
  # fair score is Var(X) * ModelSE. CIs are set to NA when the
  # evaluated variance is below 1e-6 (near a rating boundary the
  # delta-method approximation becomes uninformative because a tiny
  # change in the measure barely shifts the predicted category
  # distribution). CI bounds are clipped to the rating range so we
  # never display values outside the observable scale.
  ci_excluded <- 0L
  ci_note <- NULL
  ci_enabled <- isTRUE(show_ci)
  ci_from_fair_table <- FALSE
  if (ci_enabled && identical(fair_model, "GPCM")) {
    prefix <- if (identical(metric, "FairM")) "FairM" else "FairZ"
    ci_cols <- paste0(prefix, c("_CI_Lower", "_CI_Upper", "_CI_Level"))
    se_col <- paste0(prefix, "SE")
    status_col <- paste0(prefix, "_SE_Status")
    if (all(ci_cols %in% names(fair_df))) {
      fair_df$CI_Lower <- suppressWarnings(as.numeric(fair_df[[ci_cols[1]]]))
      fair_df$CI_Upper <- suppressWarnings(as.numeric(fair_df[[ci_cols[2]]]))
      fair_df$CI_Level <- suppressWarnings(as.numeric(fair_df[[ci_cols[3]]]))
      if (se_col %in% names(fair_df)) {
        fair_df$CI_SE <- suppressWarnings(as.numeric(fair_df[[se_col]]))
      }
      if (status_col %in% names(fair_df)) {
        fair_df$CI_Status <- as.character(fair_df[[status_col]])
      }
      fair_df$CI_Method <- "structural delta method"
      ci_from_fair_table <- TRUE
      ci_enabled <- FALSE
      ci_excluded <- sum(!is.finite(fair_df$CI_Lower) | !is.finite(fair_df$CI_Upper))
      ci_note <- paste0(
        round(100 * ci_level),
        "% CI via structural delta method",
        if (ci_excluded > 0L) {
          paste0(" (", ci_excluded,
                 " row(s) unavailable: person rows or Hessian/gradient limits)")
        } else ""
      )
    } else {
      ci_enabled <- FALSE
      ci_note <- paste(
        "CI unavailable for GPCM fair averages:",
        "call fair_average_table(..., fair_se = TRUE) or pass a fit object."
      )
    }
  }
  if (ci_enabled && "ModelSE" %in% names(fair_df) &&
      "Measure" %in% names(fair_df)) {
    score_var <- .fair_average_delta_variance(x, fair_df)
    se_logit <- suppressWarnings(as.numeric(fair_df$ModelSE))
    se_fair <- score_var * se_logit
    valid <- is.finite(score_var) & is.finite(se_logit) & score_var > 1e-6
    ci_excluded <- sum(!valid)
    z_ci <- stats::qnorm(1 - (1 - ci_level) / 2)
    fair_df$CI_Lower <- NA_real_
    fair_df$CI_Upper <- NA_real_
    fair_df$CI_Level <- ci_level
    if (any(valid)) {
      rating_min <- suppressWarnings(as.numeric(x$prep$rating_min %||% NA_real_))
      rating_max <- suppressWarnings(as.numeric(x$prep$rating_max %||% NA_real_))
      lo <- fair_df[[metric]][valid] - z_ci * se_fair[valid]
      hi <- fair_df[[metric]][valid] + z_ci * se_fair[valid]
      if (is.finite(rating_min)) lo <- pmax(lo, rating_min)
      if (is.finite(rating_max)) hi <- pmin(hi, rating_max)
      fair_df$CI_Lower[valid] <- lo
      fair_df$CI_Upper[valid] <- hi
    }
    fair_df$CI_Method <- "Rasch-family delta method"
  }

  plot_title <- if (plot_type == "difference") {
    paste0("Fair-average gaps (", metric, ")")
  } else {
    paste0("Observed vs ", metric)
  }
  plot_subtitle <- paste0(
    if (!is.null(facet)) paste0("Facet: ", as.character(facet[1]), "; ") else "",
    "Metric: ", metric,
    if (!is.null(ci_note)) {
      paste0("; ", ci_note)
    } else if (isTRUE(show_ci) && "CI_Lower" %in% names(fair_df)) {
      paste0("; ", if (isTRUE(ci_from_fair_table)) {
        ci_note
      } else {
        paste0(round(100 * ci_level), "% CI via delta-method",
               if (ci_excluded > 0L) {
                 paste0(" (", ci_excluded,
                        " level(s) excluded: near-boundary score variance)")
               } else "")
      })
    } else ""
  )
  plot_legend <- if (plot_type == "difference") {
    new_plot_legend(
      label = c("Observed above model-adjusted average", "Observed below model-adjusted average"),
      role = c("gap_direction", "gap_direction"),
      aesthetic = c("point", "point"),
      value = c(style$accent_tertiary, style$accent_secondary)
    )
  } else {
    new_plot_legend(
      label = unique(as.character(fair_df$Facet)),
      role = rep("facet", length(unique(as.character(fair_df$Facet)))),
      aesthetic = rep("point", length(unique(as.character(fair_df$Facet)))),
      value = grDevices::hcl.colors(max(1L, length(unique(as.character(fair_df$Facet)))), "Dark 3")[seq_along(unique(as.character(fair_df$Facet)))]
    )
  }
  plot_reference <- if (plot_type == "difference") {
    new_reference_lines("v", 0, "Zero gap reference", "dashed", "reference")
  } else {
    new_reference_lines("diag", 1, "Identity line", "dashed", "reference")
  }

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    if (plot_type == "difference") {
      ord <- order(abs(fair_df$Gap), decreasing = TRUE, na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sub <- fair_df[use, , drop = FALSE]
      y <- seq_len(nrow(sub))
      lbl <- paste0(sub$Facet, ":", sub$Level)
      lbl <- truncate_axis_label(lbl, width = 26L)
      # When CI whiskers are active, compute Gap CI by propagating the
      # CI of the fair metric (the observed component has no CI here).
      have_gap_ci <- isTRUE(show_ci) && all(c("CI_Lower", "CI_Upper") %in% names(sub))
      gap_ci_lo <- gap_ci_hi <- NULL
      if (have_gap_ci) {
        gap_ci_lo <- sub$ObservedAverage - sub$CI_Upper
        gap_ci_hi <- sub$ObservedAverage - sub$CI_Lower
      }
      xlim <- if (have_gap_ci) {
        range(c(sub$Gap, gap_ci_lo, gap_ci_hi, 0), finite = TRUE)
      } else {
        NULL
      }
      graphics::plot(
        x = sub$Gap,
        y = y,
        type = "n",
        xlab = paste0("Observed - ", metric),
        ylab = "",
        yaxt = "n",
        main = plot_title,
        xlim = xlim
      )
      graphics::segments(x0 = 0, y0 = y, x1 = sub$Gap, y1 = y, col = "gray55")
      cols <- ifelse(sub$Gap >= 0, style$accent_tertiary, style$accent_secondary)
      if (have_gap_ci) {
        valid <- is.finite(gap_ci_lo) & is.finite(gap_ci_hi)
        if (any(valid)) {
          graphics::segments(
            x0 = gap_ci_lo[valid], y0 = y[valid],
            x1 = gap_ci_hi[valid], y1 = y[valid],
            col = cols[valid], lwd = 1
          )
        }
        # Excluded rows (near-boundary) drawn with open circle.
        if (any(!valid)) {
          graphics::points(sub$Gap[!valid], y[!valid], pch = 1,
                           col = cols[!valid])
        }
        if (any(valid)) {
          graphics::points(sub$Gap[valid], y[valid], pch = 16,
                           col = cols[valid])
        }
      } else {
        graphics::points(sub$Gap, y, pch = 16, col = cols)
      }
      graphics::axis(side = 2, at = y, labels = lbl, las = 2, cex.axis = 0.75)
      graphics::abline(v = 0, lty = 2, col = style$neutral)
    } else {
      fac <- as.character(fair_df$Facet)
      fac_levels <- unique(fac)
      col_idx <- match(fac, fac_levels)
      cols <- grDevices::hcl.colors(length(fac_levels), if (identical(style$name, "publication")) "Temps" else "Dark 3")[col_idx]
      # Horizontal whiskers on the fair metric (x-axis) when CI is on.
      have_sc_ci <- isTRUE(show_ci) && all(c("CI_Lower", "CI_Upper") %in% names(fair_df))
      xlim_sc <- if (have_sc_ci) {
        range(c(fair_df[[metric]], fair_df$CI_Lower, fair_df$CI_Upper),
              finite = TRUE)
      } else {
        NULL
      }
      graphics::plot(
        x = fair_df[[metric]],
        y = fair_df$ObservedAverage,
        xlab = metric,
        ylab = "Observed average",
        main = plot_title,
        pch = 16,
        col = cols,
        xlim = xlim_sc
      )
      if (have_sc_ci) {
        valid <- is.finite(fair_df$CI_Lower) & is.finite(fair_df$CI_Upper)
        if (any(valid)) {
          graphics::segments(
            x0 = fair_df$CI_Lower[valid], y0 = fair_df$ObservedAverage[valid],
            x1 = fair_df$CI_Upper[valid], y1 = fair_df$ObservedAverage[valid],
            col = cols[valid], lwd = 1
          )
        }
        if (any(!valid)) {
          graphics::points(fair_df[[metric]][!valid],
                           fair_df$ObservedAverage[!valid],
                           pch = 1, col = cols[!valid])
        }
      }
      lims <- range(c(fair_df[[metric]], fair_df$ObservedAverage), finite = TRUE)
      palette_vals <- grDevices::hcl.colors(length(fac_levels), if (identical(style$name, "publication")) "Temps" else "Dark 3")
      graphics::abline(a = 0, b = 1, lty = 2, col = style$neutral)
      graphics::legend("topleft", legend = fac_levels, col = palette_vals, pch = 16, bty = "n", cex = 0.85)
      graphics::segments(x0 = lims[1], y0 = lims[1], x1 = lims[2], y1 = lims[2], col = style$grid, lty = 3)
    }
  }

  out <- new_mfrm_plot_data(
    "fair_average",
    list(
      plot = plot_type,
      metric = metric,
      data = fair_df,
      settings = bundle$settings,
      ci_note = ci_note,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name
    )
  )
  invisible(out)
}

#' Plot displacement diagnostics using base R
#'
#' @param x Output from [fit_mfrm()] or [displacement_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param anchored_only Keep only anchored/group-anchored levels.
#' @param facets Optional subset of facets.
#' @param plot_type `"lollipop"` or `"hist"`.
#' @param top_n Maximum levels shown in `"lollipop"` mode.
#' @param show_ci Logical. When `TRUE` and `plot_type = "lollipop"`, draw
#'   approximate confidence-interval whiskers from `DisplacementSE`
#'   (ignored for `"hist"`).
#' @param ci_level Confidence level used when `show_ci = TRUE`; default
#'   `0.95`. The returned plot-data object gains `CI_Lower` / `CI_Upper`
#'   / `CI_Level` columns on the `table` element for downstream reuse.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, draw with base graphics.
#' @param ... Additional arguments passed to [displacement_table()] when `x` is `mfrm_fit`.
#'
#' @details
#' **Displacement** quantifies how much a single element's calibration
#' would shift the overall model if it were allowed to move freely.
#' It is computed as:
#'
#' \deqn{\mathrm{Displacement}_j = \frac{\sum_i (X_{ij} - E_{ij})}
#'                                      {\sum_i \mathrm{Var}_{ij}}}
#'
#' where the sums run over all observations involving element \eqn{j}.
#' The standard error is \eqn{1 / \sqrt{\sum_i \mathrm{Var}_{ij}}}, and
#' a t-statistic \eqn{t = \mathrm{Displacement} / \mathrm{SE}} flags
#' elements whose observed residual pattern is inconsistent with the
#' current anchor structure.
#'
#' Displacement is most informative after anchoring: large values suggest
#' that anchored values may be drifting from the current sample.
#' For non-anchored analyses, displacement reflects residual
#' calibration tension.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"lollipop"` (default)}{Dot-and-line chart of displacement values.
#'     X-axis: displacement (logits).  Y-axis: element labels.  Points
#'     colored red when flagged (default: \eqn{|\mathrm{Disp.}| > 0.5}
#'     logits).  Dashed lines at \eqn{\pm} threshold.  Ordered by
#'     absolute displacement.}
#'   \item{`"hist"`}{Histogram of displacement values with Freedman-Diaconis
#'     breaks.  Dashed reference lines at \eqn{\pm} threshold.  Use for
#'     inspecting the overall distribution shape.}
#' }
#'
#' @section Interpreting output:
#' Lollipop: top absolute displacement levels; flagged points indicate
#' larger movement from anchor expectations.
#'
#' Histogram: overall displacement distribution and threshold lines.
#' A symmetric distribution centred near zero indicates good anchor
#' stability; heavy tails or skew suggest systematic drift.
#'
#' Use `anchored_only = TRUE` when your main question is anchor robustness.
#'
#' @section Typical workflow:
#' 1. Run with `plot_type = "lollipop"` and `anchored_only = TRUE`.
#' 2. Inspect distribution with `plot_type = "hist"`.
#' 3. Drill into flagged rows via [displacement_table()].
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [displacement_table()], [plot_unexpected()], [plot_fair_average()],
#'   [plot_qc_dashboard()], [mfrmr_visual_diagnostics]
#' @concept confidence intervals
#' @concept visual diagnostics
#' @concept displacement
#' @examplesIf interactive()
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#' p <- plot_displacement(fit, anchored_only = FALSE, draw = FALSE)
#' if (interactive()) {
#'   plot_displacement(
#'     fit,
#'     anchored_only = FALSE,
#'     plot_type = "lollipop",
#'     preset = "publication"
#'   )
#' }
#' @export
plot_displacement <- function(x,
                              diagnostics = NULL,
                              anchored_only = FALSE,
                              facets = NULL,
                              plot_type = c("lollipop", "hist"),
                              top_n = 40,
                              show_ci = FALSE,
                              ci_level = 0.95,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              draw = TRUE,
                              ...) {
  plot_type <- match.arg(tolower(plot_type), c("lollipop", "hist"))
  top_n <- max(1L, as.integer(top_n))
  if (!is.numeric(ci_level) || length(ci_level) != 1L ||
      !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1) {
    stop("`ci_level` must be a single number in (0, 1).", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)

  bundle <- if (inherits(x, "mfrm_fit")) {
    displacement_table(
      fit = x,
      diagnostics = diagnostics,
      facets = facets,
      anchored_only = anchored_only,
      ...
    )
  } else {
    resolve_displacement_bundle(x)
  }

  tbl <- as.data.frame(bundle$table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) stop("No displacement rows available.")
  tbl <- tbl[is.finite(tbl$Displacement), , drop = FALSE]
  if (nrow(tbl) == 0) stop("No finite displacement values available.")

  if (!is.null(facets)) {
    tbl <- tbl[as.character(tbl$Facet) %in% as.character(facets), , drop = FALSE]
  }
  if (isTRUE(anchored_only) && "AnchorType" %in% names(tbl)) {
    tbl <- tbl[tbl$AnchorType %in% c("Anchor", "Group"), , drop = FALSE]
  }
  if (nrow(tbl) == 0) stop("No rows left after filtering.")
  d_thr <- as.numeric(bundle$thresholds$abs_displacement_warn %||% 0.5)
  plot_title <- if (plot_type == "lollipop") "Displacement diagnostics" else "Displacement distribution"
  plot_subtitle <- paste0(
    if (isTRUE(anchored_only)) "Anchored rows only" else "All available rows",
    if (!is.null(facets) && length(facets) > 0) paste0("; facets: ", paste(as.character(facets), collapse = ", ")) else ""
  )
  plot_legend <- new_plot_legend(
    label = c("Within review band", "Flagged displacement"),
    role = c("status", "status"),
    aesthetic = c("point", "point"),
    value = c(style$accent_tertiary, style$fail)
  )
  plot_reference <- new_reference_lines(
    axis = if (plot_type == "lollipop") c("v", "v", "v") else c("v", "v"),
    value = if (plot_type == "lollipop") c(-d_thr, 0, d_thr) else c(-d_thr, d_thr),
    label = if (plot_type == "lollipop") {
      c("Displacement review threshold", "Centered reference", "Displacement review threshold")
    } else {
      c("Displacement review threshold", "Displacement review threshold")
    },
    linetype = if (plot_type == "lollipop") c("dashed", "solid", "dashed") else c("dashed", "dashed"),
    role = c("threshold", if (plot_type == "lollipop") "reference" else "threshold", "threshold")[seq_len(if (plot_type == "lollipop") 3 else 2)]
  )

  # Precompute CI bounds when requested so the scatter / lollipop paths
  # can read them uniformly. Displacement standard errors live in the
  # `DisplacementSE` column of the audit table (approx. 1/sqrt(sum Var)).
  ci_available <- isTRUE(show_ci) && "DisplacementSE" %in% names(tbl) &&
    any(is.finite(tbl$DisplacementSE))
  if (ci_available) {
    z_ci <- stats::qnorm(1 - (1 - ci_level) / 2)
    tbl$CI_Lower <- tbl$Displacement - z_ci * tbl$DisplacementSE
    tbl$CI_Upper <- tbl$Displacement + z_ci * tbl$DisplacementSE
    tbl$CI_Level <- ci_level
  }

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    if (plot_type == "lollipop") {
      ord <- order(abs(tbl$Displacement), decreasing = TRUE, na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sub <- tbl[use, , drop = FALSE]
      y <- seq_len(nrow(sub))
      lbl <- truncate_axis_label(paste0(sub$Facet, ":", sub$Level), width = 26L)
      cols <- ifelse(isTRUE(sub$Flag), style$fail, style$accent_tertiary)
      # Widen the x-axis to accommodate CI whiskers when applicable.
      xlim <- if (ci_available && all(c("CI_Lower", "CI_Upper") %in% names(sub))) {
        range(c(sub$Displacement, sub$CI_Lower, sub$CI_Upper,
                -d_thr, d_thr), finite = TRUE)
      } else {
        NULL
      }
      graphics::plot(
        x = sub$Displacement,
        y = y,
        type = "n",
        xlab = "Displacement (logit)",
        ylab = "",
        yaxt = "n",
        main = plot_title,
        xlim = xlim
      )
      graphics::abline(v = pretty(graphics::par("usr")[1:2], n = 5), col = style$grid, lty = 1)
      graphics::segments(0, y, sub$Displacement, y, col = style$neutral)
      if (ci_available && all(c("CI_Lower", "CI_Upper") %in% names(sub))) {
        valid <- is.finite(sub$CI_Lower) & is.finite(sub$CI_Upper)
        if (any(valid)) {
          graphics::segments(
            x0 = sub$CI_Lower[valid], y0 = y[valid],
            x1 = sub$CI_Upper[valid], y1 = y[valid],
            col = cols[valid], lwd = 2
          )
        }
      }
      graphics::points(sub$Displacement, y, pch = 16, col = cols)
      graphics::axis(side = 2, at = y, labels = lbl, las = 2, cex.axis = 0.75)
      graphics::abline(
        v = c(-d_thr, 0, d_thr),
        lty = c(2, 1, 2),
        col = c(style$neutral, style$axis, style$neutral)
      )
    } else {
      vals <- suppressWarnings(as.numeric(tbl$Displacement))
      graphics::hist(
        x = vals,
        breaks = "FD",
        col = style$fill_soft,
        border = style$background,
        main = plot_title,
        xlab = "Displacement (logit)"
      )
      graphics::abline(v = pretty(graphics::par("usr")[1:2], n = 5), col = style$grid, lty = 1)
      graphics::abline(v = c(-d_thr, d_thr), lty = 2, col = style$neutral)
    }
  }

  out <- new_mfrm_plot_data(
    "displacement",
    list(
      plot = plot_type,
      table = tbl,
      summary = bundle$summary,
      thresholds = bundle$thresholds,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name
    )
  )
  invisible(out)
}

#' Plot inter-rater agreement diagnostics using base R
#'
#' @param x Output from [fit_mfrm()] or [interrater_agreement_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param rater_facet Name of the rater facet when `x` is `mfrm_fit`.
#' @param context_facets Optional context facets when `x` is `mfrm_fit`.
#' @param exact_warn Warning threshold for exact agreement.
#' @param corr_warn Warning threshold for pairwise correlation.
#' @param plot_type `"exact"`, `"corr"`, or `"difference"`.
#' @param top_n Maximum pairs displayed for bar-style plots.
#' @param main Optional custom plot title.
#' @param palette Optional named color overrides (`ok`, `flag`, `expected`).
#' @param label_angle X-axis label angle for bar-style plots.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' Inter-rater agreement plots summarize pairwise consistency for a chosen
#' rater facet.  Agreement statistics are computed over observations that
#' share the same person and context-facet levels, ensuring that
#' comparisons reflect identical rating targets.
#'
#' **Exact agreement** is the proportion of matched observations where
#' both raters assigned the same category score.  The **expected
#' agreement** line shows the proportion expected by chance given each
#' rater's marginal category distribution, providing a baseline.
#'
#' **Pairwise correlation** is the Pearson correlation between scores
#' assigned by each rater pair on matched observations.
#'
#' The **difference plot** decomposes disagreement into systematic bias
#' (mean signed difference on x-axis: positive = Rater 1 more severe)
#' and total inconsistency (mean absolute difference on y-axis).  Points
#' near the origin indicate both low bias and low inconsistency.
#'
#' The `context_facets` parameter specifies which facets define "the
#' same rating target" (e.g., Criterion).  When `NULL`, all non-rater
#' facets are used as context.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"exact"` (default)}{Bar chart of exact agreement proportion by
#'     rater pair.  Expected agreement overlaid as connected circles.
#'     Horizontal reference line at `exact_warn`.  Bars colored red when
#'     observed agreement falls below the warning threshold.}
#'   \item{`"corr"`}{Bar chart of pairwise Pearson correlation by rater
#'     pair.  Reference line at `corr_warn`.  Ordered by correlation
#'     (lowest first).  Low correlations suggest inconsistent rank
#'     ordering of persons between raters.}
#'   \item{`"difference"`}{Scatter plot.  X-axis: mean signed score
#'     difference (Rater 1 \eqn{-} Rater 2); positive values indicate
#'     Rater 1 is more severe.  Y-axis: mean absolute difference
#'     (overall disagreement magnitude).  Points colored red when
#'     flagged.  Vertical reference at 0.}
#' }
#'
#' @section Interpreting output:
#' Pairs below `exact_warn` and/or `corr_warn` should be prioritized for
#' rater calibration review.  On the difference plot, points far from the
#' origin along the x-axis indicate systematic bias; points high on the
#' y-axis indicate large inconsistency regardless of direction.
#'
#' @section Typical workflow:
#' 1. Select rater facet and run `"exact"` view.
#' 2. Confirm with `"corr"` view.
#' 3. Use `"difference"` to inspect directional disagreement.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [interrater_agreement_table()], [plot_facets_chisq()],
#'   [plot_qc_dashboard()], [mfrmr_visual_diagnostics]
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#' p <- plot_interrater_agreement(fit, rater_facet = "Rater", draw = FALSE)
#' if (interactive()) {
#'   plot_interrater_agreement(
#'     fit,
#'     rater_facet = "Rater",
#'     draw = TRUE,
#'     plot_type = "exact",
#'     main = "Inter-rater Agreement (Customized)",
#'     palette = c(ok = "#2b8cbe", flag = "#cb181d"),
#'     label_angle = 45,
#'     preset = "publication"
#'   )
#' }
#' }
#' @export
plot_interrater_agreement <- function(x,
                                      diagnostics = NULL,
                                      rater_facet = NULL,
                                      context_facets = NULL,
                                      exact_warn = 0.50,
                                      corr_warn = 0.30,
                                      plot_type = c("exact", "corr", "difference"),
                                      top_n = 20,
                                      main = NULL,
                                      palette = NULL,
                                      label_angle = 45,
                                      preset = c("standard", "publication", "compact", "monochrome"),
                                      draw = TRUE) {
  plot_type <- match.arg(tolower(plot_type), c("exact", "corr", "difference"))
  top_n <- max(1L, as.integer(top_n))
  style <- resolve_plot_preset(preset)
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      ok = style$accent_primary,
      flag = style$warn,
      expected = style$accent_secondary
    )
  )

  bundle <- resolve_interrater_bundle(
    x = x,
    diagnostics = diagnostics,
    rater_facet = rater_facet,
    context_facets = context_facets,
    exact_warn = exact_warn,
    corr_warn = corr_warn,
    top_n = NULL
  )

  tbl <- as.data.frame(bundle$pairs, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) stop("No inter-rater pair rows are available.")
  if (!all(c("Rater1", "Rater2", "Exact", "Corr", "MeanDiff", "MAD") %in% names(tbl))) {
    stop("Inter-rater table does not include required columns.")
  }

  ord_exact <- order(tbl$Exact, na.last = NA)
  use <- ord_exact[seq_len(min(length(ord_exact), top_n))]
  sub <- tbl[use, , drop = FALSE]
  labels <- truncate_axis_label(paste0(sub$Rater1, " | ", sub$Rater2), width = 28L)
  cols <- if ("Flag" %in% names(sub)) ifelse(sub$Flag, pal["flag"], pal["ok"]) else pal["ok"]
  plot_title <- switch(
    plot_type,
    exact = "Inter-rater exact agreement",
    corr = "Inter-rater correlation",
    difference = "Inter-rater difference profile"
  )
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- paste0("Rater facet: ", as.character(bundle$settings$rater_facet %||% rater_facet %||% "auto"))
  plot_legend <- switch(
    plot_type,
    exact = new_plot_legend(
      label = c("Observed exact agreement", "Expected exact agreement"),
      role = c("observed", "expected"),
      aesthetic = c("bar", "point-line"),
      value = c(pal["ok"], pal["expected"])
    ),
    corr = new_plot_legend(
      label = c("Within review band", "Flagged pair"),
      role = c("status", "status"),
      aesthetic = c("bar", "bar"),
      value = c(pal["ok"], pal["flag"])
    ),
    difference = new_plot_legend(
      label = c("Within review band", "Flagged pair"),
      role = c("status", "status"),
      aesthetic = c("point", "point"),
      value = c(pal["ok"], pal["flag"])
    )
  )
  plot_reference <- switch(
    plot_type,
    exact = new_reference_lines("h", exact_warn, "Exact-agreement review threshold", "dashed", "threshold"),
    corr = new_reference_lines("h", corr_warn, "Correlation review threshold", "dashed", "threshold"),
    difference = new_reference_lines("v", 0, "Centered difference reference", "dashed", "reference")
  )

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    if (plot_type == "exact") {
      bp <- barplot_rot45(
        height = suppressWarnings(as.numeric(sub$Exact)),
        labels = labels,
        col = cols,
        main = plot_title,
        ylab = "Exact agreement",
        label_angle = label_angle,
        mar_bottom = 8.2
      )
      exp_vals <- suppressWarnings(as.numeric(sub$ExpectedExact))
      if (any(is.finite(exp_vals))) {
        graphics::points(bp, exp_vals, pch = 21, bg = "white", col = pal["expected"])
        graphics::lines(bp, exp_vals, col = pal["expected"], lwd = 1.3)
      }
      graphics::abline(h = exact_warn, lty = 2, col = grDevices::adjustcolor(style$foreground, alpha.f = 0.65))
    } else if (plot_type == "corr") {
      corr_ord <- order(tbl$Corr, na.last = NA)
      use_corr <- corr_ord[seq_len(min(length(corr_ord), top_n))]
      sub_corr <- tbl[use_corr, , drop = FALSE]
      lbl_corr <- truncate_axis_label(paste0(sub_corr$Rater1, " | ", sub_corr$Rater2), width = 28L)
      col_corr <- if ("Flag" %in% names(sub_corr)) ifelse(sub_corr$Flag, pal["flag"], pal["ok"]) else pal["ok"]
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub_corr$Corr)),
        labels = lbl_corr,
        col = col_corr,
        main = plot_title,
        ylab = "Correlation",
        label_angle = label_angle,
        mar_bottom = 8.2
      )
      graphics::abline(h = corr_warn, lty = 2, col = grDevices::adjustcolor(style$foreground, alpha.f = 0.65))
    } else {
      graphics::plot(
        x = suppressWarnings(as.numeric(tbl$MeanDiff)),
        y = suppressWarnings(as.numeric(tbl$MAD)),
        pch = 16,
        col = if ("Flag" %in% names(tbl)) ifelse(tbl$Flag, pal["flag"], pal["ok"]) else pal["ok"],
        xlab = "Mean score difference (Rater1 - Rater2)",
        ylab = "Mean absolute difference",
        main = plot_title
      )
      graphics::abline(v = 0, lty = 2, col = grDevices::adjustcolor(style$foreground, alpha.f = 0.65))
      graphics::abline(h = pretty(suppressWarnings(as.numeric(tbl$MAD)), n = 4), col = grDevices::adjustcolor(style$grid, alpha.f = 0.85), lty = 1)
    }
  }

  out <- new_mfrm_plot_data(
    "interrater",
    list(
      plot = plot_type,
      pairs = tbl,
      summary = bundle$summary,
      settings = bundle$settings,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name
    )
  )
  invisible(out)
}

#' Plot facet variability diagnostics using base R
#'
#' @param x Output from [fit_mfrm()] or [facets_chisq_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param fixed_p_max Warning cutoff for fixed-effect chi-square p-values.
#' @param random_p_max Warning cutoff for random-effect chi-square p-values.
#' @param plot_type `"fixed"`, `"random"`, or `"variance"`.
#' @param main Optional custom plot title.
#' @param palette Optional named color overrides (`fixed_ok`, `fixed_flag`,
#' `random_ok`, `random_flag`, `variance`).
#' @param label_angle X-axis label angle for bar-style plots.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' Facet chi-square tests assess whether the elements within each facet
#' differ significantly.
#'
#' **Fixed-effect chi-square** tests the null hypothesis
#' \eqn{H_0: \delta_1 = \delta_2 = \cdots = \delta_J} (all element
#' measures are equal). A flagged result (\eqn{p <} `fixed_p_max`)
#' suggests detectable between-element spread under the fitted model, but
#' it should be interpreted alongside design quality, sample size, and other
#' diagnostics.
#'
#' **Random-effect chi-square** tests whether element heterogeneity
#' exceeds what would be expected from measurement error alone, treating
#' element measures as random draws. A flagged result is screening
#' evidence that the facet may not be exchangeable under the current model.
#'
#' **Random variance** is the estimated between-element variance
#' component after removing measurement error.  It quantifies the
#' magnitude of true heterogeneity on the logit scale.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"fixed"` (default)}{Bar chart of fixed-effect chi-square by
#'     facet. Bars colored red when the null hypothesis is rejected at
#'     `fixed_p_max`. A flagged (red) bar means the facet shows spread worth
#'     reviewing under the fitted model.}
#'   \item{`"random"`}{Bar chart of random-effect chi-square by facet.
#'     Bars colored red when rejected at `random_p_max`.}
#'   \item{`"variance"`}{Bar chart of estimated random variance
#'     (logit\eqn{^2}) by facet.  Reference line at 0.  Larger values
#'     indicate greater true heterogeneity among elements.}
#' }
#'
#' @section Interpreting output:
#' Colored flags reflect configured p-value thresholds (`fixed_p_max`,
#' `random_p_max`). For the fixed test, a flagged (red) result suggests
#' facet spread worth reviewing under the current model. For the random test, a
#' flagged result is screening evidence that the facet may contribute
#' non-trivial heterogeneity beyond measurement error.
#'
#' @section Typical workflow:
#' 1. Review `"fixed"` and `"random"` panels for flagged facets.
#' 2. Check `"variance"` to contextualize heterogeneity.
#' 3. Cross-check with inter-rater and element-level fit diagnostics.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [facets_chisq_table()], [plot_interrater_agreement()], [plot_qc_dashboard()]
#' @examplesIf interactive()
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#' p <- plot_facets_chisq(fit, draw = FALSE)
#' if (interactive()) {
#'   plot_facets_chisq(
#'     fit,
#'     draw = TRUE,
#'     plot_type = "fixed",
#'     preset = "publication",
#'     main = "Facet Chi-square (Customized)",
#'     palette = c(fixed_ok = "#2b8cbe", fixed_flag = "#cb181d"),
#'     label_angle = 45
#'   )
#' }
#' @export
plot_facets_chisq <- function(x,
                              diagnostics = NULL,
                              fixed_p_max = 0.05,
                              random_p_max = 0.05,
                              plot_type = c("fixed", "random", "variance"),
                              main = NULL,
                              palette = NULL,
                              label_angle = 45,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              draw = TRUE) {
  plot_type <- match.arg(tolower(plot_type), c("fixed", "random", "variance"))
  style <- resolve_plot_preset(preset)
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      fixed_ok = style$accent_primary,
      fixed_flag = style$fail,
      random_ok = style$accent_tertiary,
      random_flag = style$fail,
      variance = style$fill_soft
    )
  )
  bundle <- resolve_facets_chisq_bundle(
    x = x,
    diagnostics = diagnostics,
    fixed_p_max = fixed_p_max,
    random_p_max = random_p_max
  )

  tbl <- as.data.frame(bundle$table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) stop("No facet chi-square rows are available.")
  if (!all(c("Facet", "FixedChiSq", "RandomChiSq", "RandomVar") %in% names(tbl))) {
    stop("Facet chi-square table does not include required columns.")
  }
  plot_title <- switch(
    plot_type,
    fixed = "Facet fixed-effect chi-square",
    random = "Facet random-effect chi-square",
    variance = "Facet random variance"
  )
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- paste0(
    "Fixed p max = ", format(fixed_p_max),
    "; random p max = ", format(random_p_max)
  )
  plot_legend <- switch(
    plot_type,
    fixed = new_plot_legend(
      label = c("Within review band", "Flagged facet"),
      role = c("status", "status"),
      aesthetic = c("bar", "bar"),
      value = c(pal["fixed_ok"], pal["fixed_flag"])
    ),
    random = new_plot_legend(
      label = c("Within review band", "Flagged facet"),
      role = c("status", "status"),
      aesthetic = c("bar", "bar"),
      value = c(pal["random_ok"], pal["random_flag"])
    ),
    variance = new_plot_legend(
      label = "Random variance",
      role = "variance",
      aesthetic = "bar",
      value = pal["variance"]
    )
  )
  plot_reference <- if (plot_type == "variance") {
    new_reference_lines("h", 0, "Zero variance reference", "dashed", "reference")
  } else {
    new_reference_lines()
  }

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    facet_labels <- truncate_axis_label(as.character(tbl$Facet), width = 20L)
    if (plot_type == "fixed") {
      ord <- order(tbl$FixedChiSq, decreasing = TRUE, na.last = NA)
      sub <- tbl[ord, , drop = FALSE]
      col_fixed <- if ("FixedFlag" %in% names(sub)) ifelse(sub$FixedFlag, pal["fixed_flag"], pal["fixed_ok"]) else pal["fixed_ok"]
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub$FixedChiSq)),
        labels = truncate_axis_label(as.character(sub$Facet), width = 20L),
        col = col_fixed,
        main = plot_title,
        ylab = expression(chi^2),
        label_angle = label_angle,
        mar_bottom = 8.2,
        border = style$background,
        add_grid = TRUE
      )
    } else if (plot_type == "random") {
      ord <- order(tbl$RandomChiSq, decreasing = TRUE, na.last = NA)
      sub <- tbl[ord, , drop = FALSE]
      col_random <- if ("RandomFlag" %in% names(sub)) ifelse(sub$RandomFlag, pal["random_flag"], pal["random_ok"]) else pal["random_ok"]
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub$RandomChiSq)),
        labels = truncate_axis_label(as.character(sub$Facet), width = 20L),
        col = col_random,
        main = plot_title,
        ylab = expression(chi^2),
        label_angle = label_angle,
        mar_bottom = 8.2,
        border = style$background,
        add_grid = TRUE
      )
    } else {
      vals <- suppressWarnings(as.numeric(tbl$RandomVar))
      barplot_rot45(
        height = vals,
        labels = facet_labels,
        col = pal["variance"],
        main = plot_title,
        ylab = "Variance",
        label_angle = label_angle,
        mar_bottom = 8.2,
        border = style$background,
        add_grid = TRUE
      )
      graphics::abline(h = 0, lty = 2, col = style$neutral)
    }
  }

  out <- new_mfrm_plot_data(
    "facets_chisq",
    list(
      plot = plot_type,
      table = tbl,
      summary = bundle$summary,
      thresholds = bundle$thresholds,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name
    )
  )
  invisible(out)
}

#' Plot a base-R QC dashboard
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()].
#' @param threshold_profile Threshold profile name (`strict`, `standard`, `lenient`).
#' @param thresholds Optional named threshold overrides.
#' @param abs_z_min Absolute standardized-residual cutoff for unexpected panel.
#' @param prob_max Maximum observed-category probability cutoff for unexpected panel.
#' @param rater_facet Optional rater facet used in inter-rater panel.
#' @param interrater_exact_warn Warning threshold for inter-rater exact agreement.
#' @param interrater_corr_warn Warning threshold for inter-rater correlation.
#' @param fixed_p_max Warning cutoff for fixed-effect facet chi-square p-values.
#' @param random_p_max Warning cutoff for random-effect facet chi-square p-values.
#' @param top_n Maximum elements displayed in displacement panel.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' The dashboard draws nine QC panels in a 3\eqn{\times}3 grid:
#'
#' | Panel | What it shows | Key reference lines |
#' | --- | --- | --- |
#' | 1. Category counts | Observed (bars) vs model-expected counts (line) | -- |
#' | 2. Infit vs Outfit | Scatter of element MnSq values | heuristic 0.5, 1.0, 1.5 bands |
#' | 3. \|ZSTD\| histogram | Distribution of absolute standardised residuals | \|ZSTD\| = 2 |
#' | 4. Unexpected responses | Standardised residual vs \eqn{-\log_{10} P_{\mathrm{obs}}} | `abs_z_min`, `prob_max` |
#' | 5. Fair-average gaps | Boxplots of (Observed - FairM) per facet | zero line |
#' | 6. Displacement | Top absolute displacement values | \eqn{\pm 0.5} logits |
#' | 7. Inter-rater agreement | Exact agreement with expected overlay per pair | `interrater_exact_warn` |
#' | 8. Fixed chi-square | Fixed-effect \eqn{\chi^2} per facet | `fixed_p_max` |
#' | 9. Separation & Reliability | Bar chart of separation index per facet | -- |
#'
#' `threshold_profile` controls warning overlays.  Three built-in profiles
#' are available: `"strict"`, `"standard"` (default), and `"lenient"`.
#' Use `thresholds` to override any profile value with named entries.
#'
#' For bounded `GPCM`, the dashboard now reuses the residual-based
#' diagnostics stack and marks the fair-average panel unavailable rather
#' than silently reusing the Rasch-only compatibility calculation.
#'
#' @section Plot types:
#' This function draws a fixed 3\eqn{\times}3 panel grid (no `plot_type`
#' argument).  For individual panel control, use the dedicated helpers:
#' [plot_unexpected()], [plot_fair_average()], [plot_displacement()],
#' [plot_interrater_agreement()], [plot_facets_chisq()].
#'
#' @section Interpreting output:
#' Recommended panel order for fast review:
#' 1. **Category counts + Infit/Outfit** (row 1): first-pass model screening.
#'    Category bars should roughly track the expected line; Infit/Outfit points
#'    are often reviewed against the heuristic 0.5--1.5 band.
#' 2. **Unexpected responses + Displacement** (row 2): element-level
#'    outliers.  Sparse points and small displacements are desirable.
#' 3. **Inter-rater + Chi-square** (row 3): facet-level comparability.
#'    Read these as screening panels: higher agreement suggests stronger
#'    scoring consistency, and significant fixed chi-square indicates
#'    detectable facet spread under the current model.
#' 4. **Separation/Reliability** (row 3): approximate screening precision.
#'    Higher separation indicates more statistically distinct strata under the
#'    current SE approximation.
#'
#' Treat this dashboard as a screening layer; follow up with dedicated helpers
#' (`plot_unexpected()`, `plot_displacement()`, `plot_interrater_agreement()`,
#' `plot_facets_chisq()`) for detailed diagnosis.
#'
#' @section Typical workflow:
#' 1. Fit and diagnose model.
#' 2. Run `plot_qc_dashboard()` for one-page triage.
#' 3. Drill into flagged panels using dedicated functions.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [plot_unexpected()], [plot_fair_average()], [plot_displacement()], [plot_interrater_agreement()], [plot_facets_chisq()], [build_visual_summaries()]
#' @examplesIf interactive()
#' # Fast smoke run: build the plot data only (no graphics device).
#' toy <- load_mfrmr_data("example_core")
#' toy_small <- toy[toy$Person %in% unique(toy$Person)[1:3], ]
#' fit_quick <- suppressWarnings(
#'   fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
#'            method = "JML", maxit = 3)
#' )
#' qc_quick <- plot_qc_dashboard(fit_quick, draw = FALSE)
#' names(qc_quick$data)
#'
#' \dontrun{
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#' qc <- plot_qc_dashboard(fit, draw = FALSE)
#' qc$data$panels$Status
#' # Look for: a row whose `Status` is "OK" for each panel that
#' #   the run should support. "WARN" / "REVIEW" rows tell you which
#' #   downstream helper to run next (e.g. `plot_unexpected()`,
#' #   `plot_residual_pca()`); the dashboard is a triage screen, not
#' #   a publication figure on its own.
#' if (interactive()) {
#'   plot_qc_dashboard(fit, rater_facet = "Rater")
#' }
#' }
#' @export
plot_qc_dashboard <- function(fit,
                              diagnostics = NULL,
                              threshold_profile = "standard",
                              thresholds = NULL,
                              abs_z_min = 2,
                              prob_max = 0.30,
                              rater_facet = NULL,
                              interrater_exact_warn = 0.50,
                              interrater_corr_warn = 0.30,
                              fixed_p_max = 0.05,
                              random_p_max = 0.05,
                              top_n = 20,
                              draw = TRUE,
                              preset = c("standard", "publication", "compact", "monochrome")) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().")
  }
  top_n <- max(5L, as.integer(top_n))
  style <- resolve_plot_preset(preset)
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }
  if (is.null(diagnostics$obs) || nrow(diagnostics$obs) == 0) {
    stop("`diagnostics$obs` is empty. Run diagnose_mfrm() first.")
  }

  resolved <- resolve_warning_thresholds(thresholds = thresholds, threshold_profile = threshold_profile)
  cat_tbl <- calc_category_stats(diagnostics$obs, res = fit, whexact = FALSE)
  fit_tbl <- as.data.frame(diagnostics$fit, stringsAsFactors = FALSE)
  # Keep signed InfitZSTD and OutfitZSTD so the histogram reveals over-fit
  # (MnSq < 1, ZSTD < 0) vs under-fit (MnSq > 1, ZSTD > 0) asymmetry. An
  # absolute-value collapse hid one tail under the other.
  zstd <- if (nrow(fit_tbl) > 0) {
    c(suppressWarnings(as.numeric(fit_tbl$InfitZSTD)),
      suppressWarnings(as.numeric(fit_tbl$OutfitZSTD)))
  } else {
    numeric(0)
  }
  zstd <- zstd[is.finite(zstd)]

  unexpected <- unexpected_response_table(
    fit = fit,
    diagnostics = diagnostics,
    abs_z_min = abs_z_min,
    prob_max = prob_max,
    top_n = max(top_n, 20),
    rule = "either"
  )
  fit_model <- as.character(fit$summary$Model[1] %||% fit$config$model %||% "RSM")
  fair <- if (identical(fit_model, "GPCM")) {
    diagnostics$fair_average %||% list(
      raw_by_facet = list(),
      by_facet = list(),
      stacked = tibble::tibble(),
      available = FALSE,
      reason = gpcm_fair_average_rationale()
    )
  } else {
    fair_average_table(fit = fit, diagnostics = diagnostics)
  }
  fair_df <- stack_fair_raw_tables(fair$raw_by_facet)
  fair_gap <- if (nrow(fair_df) > 0 && all(c("ObservedAverage", "FairM") %in% names(fair_df))) {
    fair_df$ObservedAverage - fair_df$FairM
  } else {
    numeric(0)
  }
  disp <- displacement_table(
    fit = fit,
    diagnostics = diagnostics,
    anchored_only = FALSE
  )
  disp_tbl <- as.data.frame(disp$table, stringsAsFactors = FALSE)
  interrater <- interrater_agreement_table(
    fit = fit,
    diagnostics = diagnostics,
    rater_facet = rater_facet,
    exact_warn = interrater_exact_warn,
    corr_warn = interrater_corr_warn,
    top_n = max(top_n, 20)
  )
  inter_tbl <- as.data.frame(interrater$pairs, stringsAsFactors = FALSE)
  fchi <- facets_chisq_table(
    fit = fit,
    diagnostics = diagnostics,
    fixed_p_max = fixed_p_max,
    random_p_max = random_p_max
  )
  fchi_tbl <- as.data.frame(fchi$table, stringsAsFactors = FALSE)
  rel_tbl <- as.data.frame(diagnostics$reliability, stringsAsFactors = FALSE)

  if (isTRUE(draw)) {
    old_par <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(old_par), add = TRUE)
    apply_plot_preset(style)
    graphics::par(mfrow = c(3, 3), mar = c(4, 4, 3, 1))

    # 1) Category counts
    if (nrow(cat_tbl) > 0) {
      cat_lbl <- as.character(cat_tbl$Category)
      obs_ct <- suppressWarnings(as.numeric(cat_tbl$Count))
      exp_ct <- suppressWarnings(as.numeric(cat_tbl$ExpectedCount))
      bp <- barplot_rot45(
        height = obs_ct,
        labels = cat_lbl,
        col = style$fill_muted,
        main = "QC: Category counts",
        ylab = "Count",
        label_angle = 45,
        mar_bottom = 6.4,
        label_cex = 0.72,
        label_width = 14L
      )
      if (all(is.finite(exp_ct))) {
        graphics::points(bp, exp_ct, pch = 21, bg = style$background, col = style$accent_primary)
        graphics::lines(bp, exp_ct, col = style$accent_primary, lwd = 1.5)
      }
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Category counts")
      graphics::text(0.5, 0.5, "No data")
    }

    # 2) Infit/Outfit scatter
    if (nrow(fit_tbl) > 0) {
      infit <- suppressWarnings(as.numeric(fit_tbl$Infit))
      outfit <- suppressWarnings(as.numeric(fit_tbl$Outfit))
      ok <- is.finite(infit) & is.finite(outfit)
      graphics::plot(
        x = infit[ok],
        y = outfit[ok],
        pch = 16,
        col = style$accent_primary,
        xlab = "Infit MnSq",
        ylab = "Outfit MnSq",
        main = "QC: Infit vs Outfit"
      )
      graphics::abline(v = c(0.5, 1, 1.5), h = c(0.5, 1, 1.5), lty = c(2, 1, 2), col = style$neutral)
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Infit vs Outfit")
      graphics::text(0.5, 0.5, "No data")
    }

    # 3) Signed ZSTD histogram: tails on both sides separate over-fit
    # (ZSTD < 0, MnSq < 1) from under-fit (ZSTD > 0, MnSq > 1).
    if (length(zstd) > 0) {
      graphics::hist(
        x = zstd,
        breaks = "FD",
        col = style$fill_soft,
        border = "white",
        main = "QC: ZSTD distribution",
        xlab = "ZSTD (Infit + Outfit, signed)"
      )
      graphics::abline(v = c(-3, -2, 2, 3), lty = 2, col = style$neutral)
      graphics::abline(v = 0, lty = 1, col = style$neutral)
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: ZSTD distribution")
      graphics::text(0.5, 0.5, "No data")
    }

    # 4) Unexpected response scatter
    if (nrow(unexpected$table) > 0) {
      ut <- unexpected$table
      x_u <- suppressWarnings(as.numeric(ut$StdResidual))
      y_u <- -log10(pmax(suppressWarnings(as.numeric(ut$ObsProb)), .Machine$double.xmin))
      graphics::plot(
        x = x_u,
        y = y_u,
        pch = 16,
        col = style$accent_secondary,
        xlab = "Std residual",
        ylab = expression(-log[10](P[obs])),
        main = "QC: Unexpected responses"
      )
      graphics::abline(v = c(-abs_z_min, abs_z_min), h = -log10(prob_max), lty = 2, col = style$neutral)
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Unexpected responses")
      graphics::text(0.5, 0.5, "No flagged rows")
    }

    # 5) Fair-average gap
    if (length(fair_gap) > 0) {
      fac <- as.character(fair_df$Facet)
      split_gap <- split(fair_gap, fac)
      old_mar <- graphics::par("mar")
      mar <- old_mar
      mar[1] <- max(mar[1], 6.4)
      graphics::par(mar = mar)
      graphics::boxplot(
        split_gap,
        xaxt = "n",
        col = style$fill_warm,
        main = "QC: Observed - Fair(M)",
        ylab = "Gap"
      )
      draw_rotated_x_labels(
        at = seq_along(split_gap),
        labels = truncate_axis_label(names(split_gap), width = 14L),
        srt = 45,
        cex = 0.72,
        line_offset = 0.085
      )
      graphics::mtext("Facet", side = 1, line = 4.8, cex = 0.82)
      graphics::par(mar = old_mar)
      graphics::abline(h = 0, lty = 2, col = style$neutral)
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Observed - Fair(M)")
      fair_msg <- as.character(fair$reason %||% "No data")
      graphics::text(0.5, 0.5, fair_msg)
    }

    # 6) Displacement lollipop
    if (nrow(disp_tbl) > 0 && all(c("Facet", "Level", "Displacement") %in% names(disp_tbl))) {
      ord <- order(abs(suppressWarnings(as.numeric(disp_tbl$Displacement))), decreasing = TRUE, na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sub <- disp_tbl[use, , drop = FALSE]
      y <- seq_len(nrow(sub))
      lbl <- truncate_axis_label(paste0(sub$Facet, ":", sub$Level), width = 24L)
      disp_vals <- suppressWarnings(as.numeric(sub$Displacement))
      cols <- if ("Flag" %in% names(sub)) ifelse(as.logical(sub$Flag), style$fail, style$success) else style$success
      graphics::plot(
        x = disp_vals,
        y = y,
        type = "n",
        xlab = "Displacement",
        ylab = "",
        yaxt = "n",
        main = "QC: Displacement"
      )
      graphics::segments(0, y, disp_vals, y, col = style$grid)
      graphics::points(disp_vals, y, pch = 16, col = cols)
      graphics::axis(side = 2, at = y, labels = lbl, las = 2, cex.axis = 0.7)
      d_thr <- as.numeric(disp$thresholds$abs_displacement_warn %||% 0.5)
      graphics::abline(v = c(-d_thr, 0, d_thr), lty = c(2, 1, 2), col = c(style$neutral, style$foreground, style$neutral))
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Displacement")
      graphics::text(0.5, 0.5, "No data")
    }

    # 7) Inter-rater exact agreement
    if (nrow(inter_tbl) > 0 && all(c("Rater1", "Rater2", "Exact") %in% names(inter_tbl))) {
      ord <- order(suppressWarnings(as.numeric(inter_tbl$Exact)), na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sub <- inter_tbl[use, , drop = FALSE]
      pair_lbl <- truncate_axis_label(paste0(sub$Rater1, " | ", sub$Rater2), width = 20L)
      cols <- if ("Flag" %in% names(sub)) ifelse(as.logical(sub$Flag), style$fail, style$accent_primary) else style$accent_primary
      bp <- barplot_rot45(
        height = suppressWarnings(as.numeric(sub$Exact)),
        labels = pair_lbl,
        col = cols,
        main = "QC: Inter-rater exact",
        ylab = "Exact agreement",
        label_angle = 45,
        mar_bottom = 6.4,
        label_cex = 0.72,
        label_width = 14L
      )
      exp_vals <- suppressWarnings(as.numeric(sub$ExpectedExact))
      if (any(is.finite(exp_vals))) {
        graphics::points(bp, exp_vals, pch = 21, bg = style$background, col = style$accent_secondary)
        graphics::lines(bp, exp_vals, col = style$accent_secondary, lwd = 1.3)
      }
      graphics::abline(h = interrater_exact_warn, lty = 2, col = style$neutral)
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Inter-rater exact")
      graphics::text(0.5, 0.5, "No data")
    }

    # 8) Facet fixed-effect chi-square
    if (nrow(fchi_tbl) > 0 && all(c("Facet", "FixedChiSq") %in% names(fchi_tbl))) {
      ord <- order(suppressWarnings(as.numeric(fchi_tbl$FixedChiSq)), decreasing = TRUE, na.last = NA)
      sub <- fchi_tbl[ord, , drop = FALSE]
      labels <- truncate_axis_label(as.character(sub$Facet), width = 20L)
      cols <- if ("FixedFlag" %in% names(sub)) ifelse(as.logical(sub$FixedFlag), style$fail, style$success) else style$success
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub$FixedChiSq)),
        labels = labels,
        col = cols,
        main = "QC: Facet fixed chi-square",
        ylab = expression(chi^2),
        label_angle = 45,
        mar_bottom = 6.4,
        label_cex = 0.72,
        label_width = 14L
      )
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Facet fixed chi-square")
      graphics::text(0.5, 0.5, "No data")
    }

    # 9) Separation reliability
    if (nrow(rel_tbl) > 0 && all(c("Facet", "Separation") %in% names(rel_tbl))) {
      ord <- order(suppressWarnings(as.numeric(rel_tbl$Separation)), decreasing = TRUE, na.last = NA)
      sub <- rel_tbl[ord, , drop = FALSE]
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub$Separation)),
        labels = truncate_axis_label(as.character(sub$Facet), width = 20L),
        col = style$accent_tertiary,
        main = "QC: Separation by facet",
        ylab = "Separation",
        label_angle = 45,
        mar_bottom = 6.4,
        label_cex = 0.72,
        label_width = 14L
      )
      graphics::abline(h = 1, lty = 2, col = style$neutral)
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Separation by facet")
      graphics::text(0.5, 0.5, "No data")
    }
  }

  out <- new_mfrm_plot_data(
    "qc_dashboard",
    list(
      title = "QC dashboard",
      subtitle = paste0("Threshold profile: ", resolved$profile_name),
      legend = new_plot_legend(
        label = c("Pass", "Warn", "Fail"),
        role = c("status", "status", "status"),
        aesthetic = c("dashboard", "dashboard", "dashboard"),
        value = c(style$success, style$warn, style$fail)
      ),
      reference_lines = new_reference_lines(),
      preset = style$name,
      threshold_profile = resolved$profile_name,
      thresholds = resolved$thresholds,
      category_stats = cat_tbl,
      fit = fit_tbl,
      zstd = zstd,
      unexpected = unexpected,
      fair_average = fair,
      displacement = disp,
      interrater = interrater,
      facets_chisq = fchi,
      reliability = rel_tbl
    )
  )
  invisible(out)
}

# ---- Bubble Chart ----

resolve_bubble_measures <- function(x, diagnostics = NULL) {
  if (inherits(x, "mfrm_diagnostics") ||
      (is.list(x) && "measures" %in% names(x) && is.data.frame(x$measures))) {
    return(as.data.frame(x$measures, stringsAsFactors = FALSE))
  }
  if (inherits(x, "mfrm_fit")) {
    if (is.null(diagnostics)) {
      diagnostics <- diagnose_mfrm(x, residual_pca = "none")
    }
    return(as.data.frame(diagnostics$measures, stringsAsFactors = FALSE))
  }
  stop("`x` must be an mfrm_fit object or output from diagnose_mfrm().")
}

#' Bubble chart of measure estimates and fit statistics
#'
#' Produces a Rasch-convention bubble chart where each element is a circle
#' positioned by its measure estimate and fit mean-square statistic.
#' Bubble radius reflects approximate measurement precision or sample size.
#'
#' @param x Output from \code{\link{fit_mfrm}} or \code{\link{diagnose_mfrm}}.
#' @param diagnostics Optional output from \code{\link{diagnose_mfrm}} when
#'   \code{x} is an \code{mfrm_fit} object. If omitted, diagnostics are
#'   computed automatically.
#' @param fit_stat Fit statistic for the fit axis: \code{"Infit"} (default) or
#'   \code{"Outfit"}. Ignored when \code{view = "infit_outfit"} because
#'   that view always plots Infit on x and Outfit on y.
#' @param view Layout. \code{"measure"} (default, the historical
#'   mfrmr layout) plots Measure (logit) on x and the chosen
#'   \code{fit_stat} MnSq on y. \code{"fit_measure"} reverses that layout:
#'   the selected Infit/Outfit MnSq is on x and Measure (logit) is on y,
#'   which is the preferred fit-pathway display when scale location is the
#'   organizing axis. \code{"infit_outfit"} plots Infit MnSq
#'   on x and Outfit MnSq on y, matching the Winsteps Table 30.2
#'   "Most-misfitting Persons / Items" scatter that many MFRM and
#'   Rasch users expect, and defaults \code{bubble_size = "N"}.
#' @param bubble_size Variable controlling bubble radius: \code{"SE"} (default
#'   for \code{view = "measure"}), \code{"N"} (observation count;
#'   default for \code{view = "infit_outfit"}), or \code{"equal"}
#'   (uniform size).
#' @param facets Character vector of facets to include. \code{NULL} (default)
#'   includes all non-person facets.
#' @param fit_range Numeric length-2 vector defining the heuristic fit-review band
#'   shown as a shaded region (default \code{c(0.5, 1.5)}).
#' @param top_n Maximum number of elements to plot (default 60).
#' @param main Optional custom plot title.
#' @param palette Optional named colour vector keyed by facet name.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If \code{TRUE} (default), render the plot using base graphics.
#'
#' @details
#' When \code{x} is an \code{mfrm_fit} object and \code{diagnostics} is omitted,
#' the function computes diagnostics internally via \code{\link{diagnose_mfrm}()}.
#' For repeated plotting in the same workflow, passing a precomputed diagnostics
#' object avoids that extra work.
#'
#' In \code{view = "measure"}, the x-axis shows element measure estimates on
#' the **logit** scale (one logit = one unit change in log-odds of responding
#' in a higher category) and the y-axis shows the selected fit mean-square
#' statistic. In \code{view = "fit_measure"}, those axes are reversed so scale
#' location is read vertically and the selected fit statistic is read
#' horizontally. A shaded band between \code{fit_range[1]} and
#' \code{fit_range[2]} highlights a common heuristic review range.
#'
#' Bubble radius options:
#' \itemize{
#'   \item \code{"SE"}: inversely proportional to standard error---larger
#'     circles indicate more precisely estimated elements under the current
#'     SE approximation.
#'   \item \code{"N"}: proportional to observation count---larger
#'     circles indicate elements with more data.
#'   \item \code{"equal"}: uniform size, useful when SE or N differences
#'     distract from the fit pattern.
#' }
#'
#' Person estimates are excluded by default because they typically
#' outnumber facet elements and obscure the display.
#'
#' @section Interpreting the plot:
#' Points near the horizontal reference line at 1.0 are closer to model
#' expectation on the selected MnSq scale.
#' Points above 1.5 suggest underfit relative to common review heuristics;
#' these elements may have inconsistent scoring.
#' Points below 0.5 suggest overfit relative to common review heuristics;
#' these may indicate redundancy or restricted range.
#' Points are colored by facet for easy identification.
#'
#' @section Typical workflow:
#' \enumerate{
#' \item Fit a model with \code{\link{fit_mfrm}()}.
#' \item Compute diagnostics once with \code{\link{diagnose_mfrm}()}.
#' \item Call \code{plot_bubble(fit, diagnostics = diag)} to inspect the most extreme elements.
#' }
#'
#' @return Invisibly, an object of class \code{mfrm_plot_data}.
#' @seealso \code{\link{diagnose_mfrm}}, \code{\link{plot_unexpected}},
#'   \code{\link{plot_fair_average}}
#' @examplesIf interactive()
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", model = "RSM", maxit = 30)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' p <- plot_bubble(fit, diagnostics = diag, draw = FALSE)
#' head(p$data$table[, c("Facet", "Level", "Estimate", "Infit", "Outfit")])
#' # Look for (default `view = "measure"`): bubbles inside the shaded
#' #   0.5-1.5 fit-review band. Bubbles above the band are underfit
#' #   (noisy elements); below the band are overfit (overly predictable).
#' p_fit <- plot_bubble(fit, diagnostics = diag, view = "fit_measure",
#'                      fit_stat = "Outfit", draw = FALSE)
#' p_fit$data$view
#' # Look for: where elevated or suppressed Outfit values sit along the
#' #   vertical logit/measure scale.
#' #
#' # For the Winsteps Table 30 layout pass `view = "infit_outfit"`:
#' p_io <- plot_bubble(fit, diagnostics = diag, view = "infit_outfit",
#'                      draw = FALSE)
#' p_io$data$view
#' # Look for: bubbles clustered inside the central [0.5, 1.5] x [0.5, 1.5]
#' #   square. Points outside the upper-right corner have both Infit
#' #   AND Outfit > 1.5 (consistent underfit); points outside the
#' #   lower-left have both < 0.5 (consistent overfit). Bubble size in
#' #   this view defaults to N (observation count) so the visual
#' #   weighting matches how seriously the misfit should be taken.
#' @export
plot_bubble <- function(x,
                        diagnostics = NULL,
                        fit_stat = c("Infit", "Outfit"),
                        view = c("measure", "fit_measure", "infit_outfit"),
                        bubble_size = NULL,
                        facets = NULL,
                        fit_range = c(0.5, 1.5),
                        top_n = 60,
                        main = NULL,
                        palette = NULL,
                        draw = TRUE,
                        preset = c("standard", "publication", "compact", "monochrome")) {
  fit_stat <- match.arg(fit_stat)
  view <- match.arg(view)
  if (is.null(bubble_size)) {
    bubble_size <- if (identical(view, "infit_outfit")) "N" else "SE"
  }
  bubble_size <- match.arg(bubble_size, c("SE", "N", "equal"))
  top_n <- max(1L, as.integer(top_n))
  style <- resolve_plot_preset(preset)

  measures <- resolve_bubble_measures(x, diagnostics)
  measures <- measures[measures$Facet != "Person", , drop = FALSE]
  if (!is.null(facets)) {
    measures <- measures[measures$Facet %in% as.character(facets), , drop = FALSE]
  }
  if (nrow(measures) == 0) stop("No measures available for bubble chart.")

  needed <- if (identical(view, "infit_outfit")) {
    c("Facet", "Level", "Infit", "Outfit")
  } else {
    c("Facet", "Level", "Estimate", fit_stat)
  }
  missing_cols <- setdiff(needed, names(measures))
  if (length(missing_cols) > 0) {
    stop("Missing columns in measures: ", paste(missing_cols, collapse = ", "))
  }

  ok <- if (identical(view, "infit_outfit")) {
    is.finite(measures$Infit) & is.finite(measures$Outfit)
  } else {
    is.finite(measures$Estimate) & is.finite(measures[[fit_stat]])
  }
  measures <- measures[ok, , drop = FALSE]
  if (nrow(measures) == 0) stop("No finite measure/fit values for bubble chart.")

  if (nrow(measures) > top_n) {
    rank_metric <- if (identical(view, "infit_outfit")) {
      pmax(abs(measures$Infit - 1), abs(measures$Outfit - 1), na.rm = TRUE)
    } else {
      abs(measures[[fit_stat]] - 1)
    }
    measures <- measures[order(rank_metric, decreasing = TRUE), ]
    measures <- measures[seq_len(top_n), , drop = FALSE]
  }

  radius <- switch(bubble_size,
    SE = {
      se_vals <- if ("SE" %in% names(measures)) measures$SE else rep(0.1, nrow(measures))
      se_vals[!is.finite(se_vals)] <- stats::median(se_vals[is.finite(se_vals)], na.rm = TRUE)
      se_vals / max(se_vals, na.rm = TRUE) * 0.15
    },
    N = {
      n_vals <- if ("N" %in% names(measures)) measures$N else rep(1, nrow(measures))
      n_vals[!is.finite(n_vals)] <- 1
      sqrt(n_vals) / max(sqrt(n_vals), na.rm = TRUE) * 0.15
    },
    equal = rep(0.08, nrow(measures))
  )

  unique_facets <- unique(measures$Facet)
  default_cols <- stats::setNames(
    grDevices::hcl.colors(
      max(3L, length(unique_facets)),
      if (identical(style$name, "publication")) "Temps" else "Dark 3"
    )[seq_along(unique_facets)],
    unique_facets
  )
  cols <- resolve_palette(palette = palette, defaults = default_cols)
  point_cols <- cols[as.character(measures$Facet)]

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    if (identical(view, "infit_outfit")) {
      xv <- measures$Infit
      yv <- measures$Outfit
      xlab_use <- "Infit MnSq"
      ylab_use <- "Outfit MnSq"
      xr <- range(c(xv, fit_range), na.rm = TRUE)
      yr <- range(c(yv, fit_range), na.rm = TRUE)
      xr <- xr + diff(xr) * c(-0.1, 0.1)
      yr <- yr + diff(yr) * c(-0.1, 0.1)
      title_default <- "Infit-Outfit MnSq scatter (Winsteps Table 30 layout)"
    } else if (identical(view, "fit_measure")) {
      xv <- measures[[fit_stat]]
      yv <- measures$Estimate
      xlab_use <- paste0(fit_stat, " Mean Square")
      ylab_use <- "Measure (logits)"
      xr <- range(c(xv, fit_range), na.rm = TRUE)
      xr <- xr + diff(xr) * c(-0.1, 0.1)
      yr <- range(yv, na.rm = TRUE)
      yr <- yr + diff(yr) * c(-0.15, 0.15)
      title_default <- paste0("Fit pathway: ", fit_stat, " by measure")
    } else {
      xv <- measures$Estimate
      yv <- measures[[fit_stat]]
      xlab_use <- "Measure (logits)"
      ylab_use <- paste0(fit_stat, " Mean Square")
      xr <- range(xv, na.rm = TRUE)
      xr <- xr + diff(xr) * c(-0.15, 0.15)
      yr <- range(c(yv, fit_range), na.rm = TRUE)
      yr <- yr + diff(yr) * c(-0.1, 0.1)
      title_default <- paste0("Bubble Chart: ", fit_stat)
    }

    graphics::plot(
      x = xv, y = yv, type = "n",
      xlim = xr, ylim = yr,
      xlab = xlab_use, ylab = ylab_use,
      main = if (is.null(main)) title_default else as.character(main[1])
    )
    if (identical(view, "infit_outfit")) {
      # Acceptance band as a shaded square for the infit-outfit view.
      graphics::rect(
        xleft = fit_range[1], ybottom = fit_range[1],
        xright = fit_range[2], ytop = fit_range[2],
        col = grDevices::adjustcolor(style$fill_soft, alpha.f = 0.30), border = NA
      )
      graphics::abline(v = 1, lty = 2, col = style$neutral, lwd = 1.5)
      graphics::abline(h = 1, lty = 2, col = style$neutral, lwd = 1.5)
      graphics::abline(v = fit_range, lty = 3, col = style$grid)
      graphics::abline(h = fit_range, lty = 3, col = style$grid)
    } else if (identical(view, "fit_measure")) {
      graphics::rect(
        xleft = fit_range[1], ybottom = yr[1] - 1,
        xright = fit_range[2], ytop = yr[2] + 1,
        col = grDevices::adjustcolor(style$fill_soft, alpha.f = 0.45),
        border = NA
      )
      graphics::abline(v = 1, lty = 2, col = style$neutral, lwd = 1.5)
      graphics::abline(v = fit_range, lty = 3, col = style$grid)
      graphics::abline(h = pretty(yr, n = 5), col = style$grid, lty = 1)
    } else {
      graphics::rect(
        xleft = xr[1] - 1, ybottom = fit_range[1],
        xright = xr[2] + 1, ytop = fit_range[2],
        col = grDevices::adjustcolor(style$fill_soft, alpha.f = 0.45), border = NA
      )
      graphics::abline(h = 1, lty = 2, col = style$neutral, lwd = 1.5)
      graphics::abline(h = fit_range, lty = 3, col = style$grid)
    }
    graphics::symbols(
      x = xv, y = yv,
      circles = radius, inches = FALSE, add = TRUE,
      fg = point_cols,
      bg = grDevices::adjustcolor(point_cols, alpha.f = 0.45)
    )
    graphics::legend(
      "topleft", legend = unique_facets,
      col = cols[unique_facets], pch = 16, bty = "n", cex = 0.85
    )
  }

  title_payload <- if (is.null(main)) {
    if (identical(view, "infit_outfit")) {
      "Infit-Outfit MnSq scatter (Winsteps Table 30 layout)"
    } else if (identical(view, "fit_measure")) {
      paste0("Fit pathway: ", fit_stat, " by measure")
    } else {
      paste0("Bubble Chart: ", fit_stat)
    }
  } else as.character(main[1])
  reference_lines_payload <- if (identical(view, "infit_outfit")) {
    new_reference_lines(
      axis = c("h", "h", "h", "v", "v", "v"),
      value = c(fit_range[1], 1, fit_range[2], fit_range[1], 1, fit_range[2]),
      label = c("Lower fit review band", "Ideal Outfit", "Upper fit review band",
                 "Lower fit review band", "Ideal Infit", "Upper fit review band"),
      linetype = c("dashed", "dashed", "dashed", "dashed", "dashed", "dashed"),
      role = c("threshold", "reference", "threshold",
                "threshold", "reference", "threshold")
    )
  } else if (identical(view, "fit_measure")) {
    new_reference_lines(
      axis = c("v", "v", "v"),
      value = c(fit_range[1], 1, fit_range[2]),
      label = c("Lower fit review band", "Ideal fit", "Upper fit review band"),
      linetype = c("dashed", "dashed", "dashed"),
      role = c("threshold", "reference", "threshold")
    )
  } else {
    new_reference_lines(
      axis = c("h", "h", "h"),
      value = c(fit_range[1], 1, fit_range[2]),
      label = c("Lower fit review band", "Ideal fit", "Upper fit review band"),
      linetype = c("dashed", "dashed", "dashed"),
      role = c("threshold", "reference", "threshold")
    )
  }
  out <- new_mfrm_plot_data(
    "bubble",
    list(
      view = view,
      fit_stat = fit_stat,
      bubble_size = bubble_size,
      fit_range = fit_range,
      table = measures,
      radius = radius,
      title = title_payload,
      subtitle = paste0("Bubble size = ", bubble_size, "; fit review band = [", paste(format(fit_range), collapse = ", "), "]"),
      legend = new_plot_legend(
        label = unique(as.character(measures$Facet)),
        role = rep("facet", length(unique(as.character(measures$Facet)))),
        aesthetic = rep("point", length(unique(as.character(measures$Facet)))),
        value = cols[unique(as.character(measures$Facet))]
      ),
      reference_lines = reference_lines_payload,
      preset = style$name
    )
  )
  invisible(out)
}

# ---- CSV Export ----

#' Export MFRM results to CSV files
#'
#' Writes tidy CSV files suitable for import into spreadsheet software or
#' further analysis in other tools.
#'
#' @param fit Output from \code{\link{fit_mfrm}}.
#' @param diagnostics Optional output from \code{\link{diagnose_mfrm}}.
#'   When provided, enriches facet estimates with SE, fit statistics, and
#'   writes the full measures table.
#' @param output_dir Directory for CSV files. Created if it does not exist.
#' @param prefix Filename prefix (default \code{"mfrm"}).
#' @param tables Character vector of tables to export. Any subset of
#'   \code{"person"}, \code{"facets"}, \code{"summary"}, \code{"steps"},
#'   \code{"measures"}. Default exports all available tables.
#' @param overwrite If \code{FALSE} (default), refuse to overwrite existing
#'   files.
#'
#' @section Exported files:
#' \describe{
#'   \item{\code{{prefix}_person_estimates.csv}}{Person ID, Estimate, SD.}
#'   \item{\code{{prefix}_facet_estimates.csv}}{Facet, Level, Estimate,
#'     and optionally SE, Infit, Outfit, PTMEA when diagnostics supplied.}
#'   \item{\code{{prefix}_fit_summary.csv}}{One-row model summary.}
#'   \item{\code{{prefix}_step_parameters.csv}}{Step/threshold parameters.}
#'   \item{\code{{prefix}_measures.csv}}{Full measures table (requires
#'     diagnostics).}
#' }
#'
#' @section Interpreting output:
#' The returned data.frame tells you exactly which files were written and where.
#' This is convenient for scripted pipelines where the output directory is created
#' on the fly.
#'
#' @section Typical workflow:
#' \enumerate{
#' \item Fit a model with \code{\link{fit_mfrm}()}.
#' \item Optionally compute diagnostics with \code{\link{diagnose_mfrm}()} when you want enriched facet or measures exports.
#' \item Call \code{export_mfrm(...)} and inspect the returned \code{Path} column.
#' }
#'
#' @return Invisibly, a data.frame listing written files with columns
#'   \code{Table} and \code{Path}.
#' @seealso \code{\link{fit_mfrm}}, \code{\link{diagnose_mfrm}},
#'   \code{\link{as.data.frame.mfrm_fit}}
#' @examplesIf interactive()
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", model = "RSM", maxit = 30)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' out_dir <- tempfile("mfrmr_export_example_")
#' out <- export_mfrm(
#'   fit,
#'   diagnostics = diag,
#'   output_dir = out_dir,
#'   prefix = "mfrmr_example",
#'   overwrite = TRUE
#' )
#' out$Table
#' @export
export_mfrm <- function(fit,
                        diagnostics = NULL,
                        output_dir = ".",
                        prefix = "mfrm",
                        tables = c("person", "facets", "summary", "steps", "measures"),
                        overwrite = FALSE) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().")
  }
  tables <- unique(tolower(as.character(tables)))
  allowed <- c("person", "facets", "summary", "steps", "measures")
  bad <- setdiff(tables, allowed)
  if (length(bad) > 0) {
    stop("Unknown table names: ", paste(bad, collapse = ", "),
         ". Allowed: ", paste(allowed, collapse = ", "))
  }
  prefix <- as.character(prefix[1])
  if (!nzchar(prefix)) prefix <- "mfrm"
  overwrite <- isTRUE(overwrite)
  output_dir <- as.character(output_dir[1])

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(output_dir)) {
    stop("Could not create output directory: ", output_dir)
  }

  written <- data.frame(Table = character(0), Path = character(0),
                        stringsAsFactors = FALSE)

  write_one <- function(df, filename, table_name) {
    path <- file.path(output_dir, filename)
    if (file.exists(path) && !overwrite) {
      stop("File already exists: ", path, ". Set overwrite = TRUE to replace.")
    }
    utils::write.csv(df, file = path, row.names = FALSE, na = "")
    written <<- rbind(written, data.frame(Table = table_name, Path = path,
                                          stringsAsFactors = FALSE))
  }

  if ("person" %in% tables) {
    person_df <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
    write_one(person_df, paste0(prefix, "_person_estimates.csv"), "person")
  }

  if ("facets" %in% tables) {
    facet_df <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
    if (!is.null(diagnostics) && !is.null(diagnostics$measures)) {
      enrich_cols <- intersect(c("SE", "Infit", "Outfit", "PTMEA", "N"),
                               names(diagnostics$measures))
      if (length(enrich_cols) > 0) {
        enrich <- diagnostics$measures[diagnostics$measures$Facet != "Person",
                                       c("Facet", "Level", enrich_cols), drop = FALSE]
        enrich <- as.data.frame(enrich, stringsAsFactors = FALSE)
        enrich$Level <- as.character(enrich$Level)
        facet_df$Level <- as.character(facet_df$Level)
        facet_df <- merge(facet_df, enrich, by = c("Facet", "Level"), all.x = TRUE)
      }
    }
    write_one(facet_df, paste0(prefix, "_facet_estimates.csv"), "facets")
  }

  if ("summary" %in% tables) {
    summary_df <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
    write_one(summary_df, paste0(prefix, "_fit_summary.csv"), "summary")
  }

  if ("steps" %in% tables) {
    step_df <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
    if (nrow(step_df) > 0) {
      write_one(step_df, paste0(prefix, "_step_parameters.csv"), "steps")
    }
  }

  if ("measures" %in% tables && !is.null(diagnostics) && !is.null(diagnostics$measures)) {
    measures_df <- as.data.frame(diagnostics$measures, stringsAsFactors = FALSE)
    write_one(measures_df, paste0(prefix, "_measures.csv"), "measures")
  }

  invisible(written)
}

#' Convert mfrm_fit to a tidy data.frame
#'
#' Returns all facet-level estimates (person and others) in a single
#' tidy data.frame. Useful for quick interactive export:
#' \code{write.csv(as.data.frame(fit), "results.csv")}.
#'
#' @param x An \code{mfrm_fit} object from \code{\link{fit_mfrm}}.
#' @param row.names Ignored (included for S3 generic compatibility).
#' @param optional Ignored (included for S3 generic compatibility).
#' @param ... Additional arguments (ignored).
#'
#' @details
#' This method returns four columns (\code{Facet}, \code{Level},
#' \code{Estimate}, \code{Extreme}) so that the result is easy to
#' inspect, join, or write to disk.
#'
#' @section Interpreting output:
#' Person estimates are returned with \code{Facet = "Person"}.
#' All non-person facets are stacked underneath in the same schema.
#'
#' @section Typical workflow:
#' \enumerate{
#' \item Fit a model with \code{\link{fit_mfrm}()}.
#' \item Convert with \code{as.data.frame(fit)} for a compact long-format export.
#' \item Join additional diagnostics later if you need SE or fit statistics.
#' }
#'
#' @return A data.frame with columns \code{Facet}, \code{Level},
#'   \code{Estimate}, and \code{Extreme}. The \code{Extreme} column
#'   is populated for person rows from the extreme-score flag added
#'   in 0.1.6 (\code{"Min"} / \code{"Max"} / \code{NA}); non-person
#'   facet rows carry \code{NA} in that column by design.
#' @seealso \code{\link{fit_mfrm}}, \code{\link{export_mfrm}}
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", model = "RSM", maxit = 30)
#' head(as.data.frame(fit))
#' @export
as.data.frame.mfrm_fit <- function(x, row.names = NULL, optional = FALSE, ...) {
  # Carry forward the Extreme flag added in 0.1.6 (via build_person_table)
  # so downstream ggplot / CSV export paths see per-person extreme status.
  person_extreme <- if ("Extreme" %in% names(x$facets$person)) {
    as.character(x$facets$person$Extreme)
  } else {
    rep(NA_character_, nrow(x$facets$person))
  }
  person_df <- data.frame(
    Facet = "Person",
    Level = as.character(x$facets$person$Person),
    Estimate = x$facets$person$Estimate,
    Extreme = person_extreme,
    stringsAsFactors = FALSE
  )
  facet_df <- as.data.frame(
    x$facets$others[, c("Facet", "Level", "Estimate")],
    stringsAsFactors = FALSE
  )
  facet_df$Level <- as.character(facet_df$Level)
  facet_df$Extreme <- NA_character_
  rbind(person_df, facet_df)
}

#' @export
print.mfrm_plot_bundle <- function(x, ...) {
  cat("mfrm plot bundle\n")
  cat("  - wright_map\n")
  cat("  - pathway_map\n")
  cat("  - category_characteristic_curves\n")
  cat("Use `$` to access each plotting-data object.\n")
  invisible(x)
}

#' @export
print.mfrm_fit <- function(x, ...) {
  if (is.list(x) && !is.null(x$summary) && nrow(x$summary) > 0) {
    ov <- round_numeric_df(as.data.frame(x$summary), digits = 3L)[1, , drop = FALSE]
    fit_summary <- tryCatch(summary(x), error = function(e) NULL)
    cat("mfrm_fit object\n")
    cat(sprintf("  Model: %s | Method: %s\n", ov$Model %||% NA_character_, ov$Method %||% NA_character_))
    cat(sprintf("  N: %s | Persons: %s | Facets: %s | Categories: %s\n",
                ov$N %||% NA, ov$Persons %||% NA, ov$Facets %||% NA, ov$Categories %||% NA))
    cat(sprintf("  LogLik: %s | AIC: %s | BIC: %s\n",
                ov$LogLik %||% NA, ov$AIC %||% NA, ov$BIC %||% NA))
    if ("Converged" %in% names(ov) && "ConvergenceStatus" %in% names(ov)) {
      cat(sprintf("  Converged: %s | Status: %s\n",
                  ifelse(isTRUE(ov$Converged), "Yes", "No"),
                  ov$ConvergenceStatus %||% NA_character_))
    }
    if (isTRUE(x$config$attached_diagnostics)) {
      attached_cols <- as.character(x$config$attached_diagnostics_cols %||% character(0))
      if (length(attached_cols) > 0L) {
        cat(sprintf(
          "  Attached diagnostics: %s\n",
          paste(attached_cols, collapse = ", ")
        ))
      } else {
        cat("  Attached diagnostics: yes (per-element fit columns merged)\n")
      }
    }
    if (!is.null(fit_summary) && nrow(fit_summary$status %||% data.frame()) > 0) {
      first_status <- fit_summary$status[1, , drop = FALSE]
      cat(sprintf("  Summary status: %s\n", first_status$Value[1] %||% NA_character_))
    }
    if (!is.null(fit_summary) && nrow(fit_summary$design_spec %||% data.frame()) > 0) {
      ds <- fit_summary$design_spec[1, , drop = FALSE]
      step_label <- as.character(ds$StepFacet %||% NA_character_)
      threshold_label <- if (!is.na(step_label) && nzchar(step_label)) {
        paste0(ds$ThresholdStructure %||% NA_character_, " by ", step_label)
      } else {
        as.character(ds$ThresholdStructure %||% NA_character_)
      }
      cat(sprintf(
        "  Design: %s | Thresholds: %s\n",
        ds$Engine %||% NA_character_,
        threshold_label
      ))
    }
    if (!is.null(fit_summary) &&
        length(fit_summary$key_warnings) > 0 &&
        !summary_lines_are_default(
          fit_summary$key_warnings,
          "No immediate warnings from fit-level summary checks."
        )) {
      cat(sprintf("  Key warning: %s\n", fit_summary$key_warnings[1]))
    }
    if (!is.null(fit_summary) && length(fit_summary$next_actions) > 0) {
      cat(sprintf("  Next: %s\n", fit_summary$next_actions[1]))
    } else {
      cat("  Next: use `summary(x)` for details.\n")
    }
    cat("  Use `summary(x)` for the full fit summary.\n")
  } else {
    cat("mfrm_fit object (empty summary)\n")
  }
  invisible(x)
}
