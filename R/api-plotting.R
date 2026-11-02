.mfrm_default_plot_preset <- function() {
  preset <- getOption("mfrmr.plot_preset", "standard")
  choices <- c("standard", "publication", "compact", "monochrome")
  if (!is.character(preset) || length(preset) != 1L || is.na(preset) ||
      !preset %in% choices) {
    stop("Option `mfrmr.plot_preset` must be one of: standard, publication, compact, monochrome. Set it to NULL to restore the package default.", call. = FALSE)
  }
  unname(preset)
}

# Resolve the new spelling before any input processing or drawing. A blank
# string survives legacy default-title fallbacks in renderers and converters.
.mfrm_plot_title_alias <- function(main, title, main_missing, title_missing) {
  if (title_missing) return(main)
  if (!main_missing) stop("Supply only one of `title` and `main`, not both.", call. = FALSE)
  if (is.null(title)) return("")
  if (!is.character(title) || length(title) != 1L || is.na(title)) {
    stop("`title` must be one character string or NULL.", call. = FALSE)
  }
  unname(title)
}

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

# Collect figure text without discarding the original, plot-specific metadata.
.mfrm_plot_annotation_notes <- function(data) {
  notes <- data[["notes"]]
  if (is.data.frame(notes)) {
    out <- as.data.frame(notes, stringsAsFactors = FALSE)
    column <- intersect(c("Text", "Note", "Message"), names(out))[1L]
    out$Text <- if (!is.na(column)) as.character(out[[column]]) else rep("", nrow(out))
    if (!"Type" %in% names(out)) out$Type <- rep("note", nrow(out))
    out <- out[, c("Type", "Text", setdiff(names(out), c("Type", "Text"))), drop = FALSE]
  } else {
    text <- as.character(notes %||% character())
    out <- data.frame(Type = rep("note", length(text)), Text = text, stringsAsFactors = FALSE)
  }
  fields <- c("subtitle", "caption", "note", "interpretation_note", "uncertainty_note",
              "retention_note", "component_note", "projection_note", "interpretation", "cautions")
  for (field in fields) {
    value <- data[[field]]
    if (!is.character(value)) next
    key <- trimws(value)
    value <- value[!is.na(key) & nzchar(key) & !duplicated(key) &
      !key %in% trimws(out$Text)]
    if (!length(value)) next
    extra <- data.frame(Type = rep(if (field == "cautions") "caution" else field, length(value)),
      Text = value, stringsAsFactors = FALSE)
    for (column in setdiff(names(out), names(extra))) extra[[column]] <- NA
    out <- rbind(out, extra)
  }
  out <- out[!is.na(out$Text) & nzchar(out$Text), , drop = FALSE]
  rownames(out) <- NULL
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
  if (is.null(data[["notes"]])) data$notes <- .mfrm_plot_annotation_notes(data)
  data$legend <- normalize_plot_legend(data$legend %||% NULL)
  data$reference_lines <- normalize_reference_lines(data$reference_lines %||% NULL)
  data
}

new_mfrm_plot_data <- function(name, data) {
  out <- list(name = name, data = standardize_plot_payload(name, data))
  class(out) <- c("mfrm_plot_data", class(out))
  out
}

.mfrm_score_direction_notes <- function(fit, facets = fit$config$facet_names,
                                        include_person = TRUE) {
  text <- "Score meaning is supplied by the rubric: higher coded scores need not mean better performance. Reversing category labels alone does not reverse the fitted scale."
  if (inherits(fit, "mfrm_imported_fit")) {
    text <- c(text, "Imported locations retain the source model's orientation; check its coding and discrimination before interpreting higher values.")
  } else {
    if (include_person) text <- c(text,
      "Higher Person locations increase expected coded scores in these positive-discrimination models, holding other effects fixed.")
    for (facet in facets) {
      sign <- unname(fit$config$facet_signs[facet])
      effect <- if (length(sign) != 1L || !is.finite(sign) || sign == 0) {
        "have no recorded score direction; check the fitted model"
      } else if (sign < 0) "reduce expected coded scores" else "increase expected coded scores"
      text <- c(text, paste0(facet, ": higher locations ", effect, ", holding other effects fixed."))
    }
  }
  data.frame(Type = c("score_coding", rep("orientation", length(text) - 1L)),
    Text = text, stringsAsFactors = FALSE)
}

.mfrm_step_interpretation_note <- function() {
  paste("A Step describes the transition between adjacent score categories, not a learning stage or a pass/fail cut.",
    "At the corresponding predictor value, the two categories have equal probability, not necessarily probability 0.5 each.",
    "Stored step offsets and full ability-axis crossings differ when other facet effects or interactions are included; check the reference profile and step owner.")
}

#' @export
print.mfrm_plot_data <- function(x, ...) {
  data <- x$data %||% list()
  data$notes <- .mfrm_plot_annotation_notes(data)
  data$notes <- data$notes[!data$notes$Text %in% (data$subtitle %||% character()), , drop = FALSE]
  if (x$name %in% c("dif_summary", "dif_heatmap", "fair_average")) {
    cat(data$title %||% "Group and adjusted-score plot", "\n")
    if (!is.null(data$subtitle) && nzchar(data$subtitle)) cat(data$subtitle, "\n")
    if (is.data.frame(data$notes) && "Text" %in% names(data$notes)) {
      for (line in unique(data$notes$Text)) cat(paste(strwrap(line), collapse = "\n"), "\n")
    }
    cat("Use `plot_data()` to extract the plotted values.\n")
    return(invisible(x))
  }
  cat("<mfrm_plot_data>\n")
  cat("  name     : ", x$name %||% "<unnamed>", "\n", sep = "")
  if (!is.null(data$title) && nzchar(data$title)) {
    cat("  title    : ", data$title, "\n", sep = "")
  }
  if (!is.null(data$subtitle) && nzchar(data$subtitle)) {
    cat("  subtitle : ", data$subtitle, "\n", sep = "")
  }
  if (is.data.frame(data$notes) && all(c("Type", "Text") %in% names(data$notes))) {
    cat("  notes    :\n")
    for (i in seq_len(nrow(data$notes))) {
      cat(paste(strwrap(paste0("[", data$notes$Type[i], "] ", data$notes$Text[i]),
        width = max(40L, getOption("width") - 4L), prefix = "    "), collapse = "\n"), "\n", sep = "")
    }
  }
  data_slots <- setdiff(
    names(data),
    c("title", "subtitle", "caption", "legend", "reference_lines", "notes")
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
    n_items <- if (is.data.frame(legend)) {
      nrow(legend)
    } else if (is.list(legend) && !is.null(legend$labels)) {
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
  cat("Use `plot_data()` to extract the saved values and notes.\n")
  cat("For supported views, `as_ggplot()` redraws this saved result.\n")
  invisible(x)
}

as_mfrm_plot_data_object <- function(x, type = NULL, ...) {
  saved <- attr(x, "mfrmr_plot_data", exact = TRUE)
  if (inherits(saved, "mfrm_plot_data")) return(saved)
  if (inherits(x, "mfrm_plot_data")) {
    return(x)
  }
  if (inherits(x, c("mfrm_design_evaluation_plot_data", "mfrm_signal_detection_plot_data")) ||
      (is.list(x) && !inherits(x, "ggplot") &&
       as.character(x$plot %||% "")[1L] %in% c("design_evaluation", "signal_detection") &&
       is.data.frame(x$data))) {
    nm <- if (inherits(x, "mfrm_signal_detection_plot_data") ||
              identical(as.character(x$plot %||% "")[1L], "signal_detection")) {
      "signal_detection"
    } else {
      "design_evaluation"
    }
    return(new_mfrm_plot_data(nm, unclass(x)))
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
  saved <- attr(out, "mfrmr_plot_data", exact = TRUE)
  if (inherits(saved, "mfrm_plot_data")) return(saved)
  if (!inherits(out, "mfrm_plot_data")) {
    stop(
      "`plot(..., draw = FALSE)` must return a `ggplot` carrying `mfrmr_plot_data` or an `mfrm_plot_data` object.",
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
#' Titles, subtitles, and explanatory footnotes are omitted from figures by
#' default. Use `plot_data(p, "title")` for the suggested title and
#' `plot_data(p, "notes")` for a `Type`/`Text` table of descriptions and cautions.
#' This works for saved `0.2.x` plot payloads and mfrmr-generated ggplots,
#' including after `saveRDS()`/`readRDS()`. Printing an `mfrm_plot_data` object
#' also displays its notes in the console. Axes, legends, panel headings and
#' data/status symbols remain in the figure. Removing figure text does not
#' remove numerical warnings or strengthen the interpretation of a result.
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
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Draw the Wright map and keep its reusable data
#' wright <- plot(fit)
#' plot_data(wright, "notes")
#'
#' # Extract the plotted locations as a table
#' locations <- plot_data(wright, component = "locations")
#' head(locations)
#'
#' # For table extraction alone, no graphics device is needed
#' locations_only <- plot_data(fit, component = "locations")
#' head(locations_only)
#' @param format `"native"` (default) returns the saved component unchanged.
#'   `"long"` reshapes a selected table or matrix without dropping missing cells.
#' @param value_cols Explicit table columns to gather into `Variable` and `Value`.
#'   Other columns, and an added `SourceRow`, remain identifiers/metadata.
#'   Select compatible value types and comparable units; estimates, standard
#'   errors and interval bounds are distinct quantities, not replicate draws.
#'   Matrices instead yield Row, Column, RowLabel, ColumnLabel and Value, with
#'   indices retaining identity even if labels repeat. Already-long tables
#'   (including cluster-profile `observations`) need no reshaping.
#' @section Custom distribution plots:
#' A cluster profile's `observations` component contains one row per original
#' entity and selected feature, with ID, Feature, Value, Cluster, Included and
#' MissingReason. Missing values and omitted entities remain. Use Included to
#' select the plotted population explicitly. `table` is the summary, not raw
#' observations. Export either with write.csv; use the observations for custom
#' box/violin/raincloud plots. Feature units are the original units, supplied by
#' the study. A smooth density is usually inappropriate for a few ordinal bins.
#' [online networks and reporting guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-networks-and-reporting.html) demonstrates custom plots and CSVs.
#' @export
plot_data <- function(x, component = NULL, type = NULL, ...,
                      format = c("native", "long"), value_cols = NULL) {
  format <- match.arg(format)
  if (identical(component, "notes")) {
    notes <- attr(x, "mfrmr_notes", exact = TRUE)
    if (!is.null(notes)) return(notes)
  }
  x <- as_mfrm_plot_data_object(x, type = type, ...)
  payload <- x$data %||% list()
  if (identical(component, "notes")) return(.mfrm_plot_annotation_notes(payload))
  if (is.null(component)) {
    if (format == "long") stop("Select a table or matrix `component` for long output.", call. = FALSE)
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

  selected <- payload[[component]]
  if (format == "native") return(selected)
  if (is.matrix(selected)) {
    if (!is.null(value_cols)) stop("`value_cols` applies to data frames, not matrices.", call. = FALSE)
    out <- expand.grid(Row = seq_len(nrow(selected)), Column = seq_len(ncol(selected)))
    out$RowLabel <- (rownames(selected) %||% as.character(seq_len(nrow(selected))))[out$Row]
    out$ColumnLabel <- (colnames(selected) %||% as.character(seq_len(ncol(selected))))[out$Column]
    out$Value <- as.vector(selected)
    return(out)
  }
  if (!is.data.frame(selected) || !is.character(value_cols) || !length(value_cols) ||
      anyNA(value_cols) || anyDuplicated(value_cols) ||
      !all(value_cols %in% names(selected)) || anyDuplicated(names(selected)) ||
      any(c("SourceRow", "Variable", "Value") %in% names(selected))) {
    stop("Long tables require explicit `value_cols` and no reserved SourceRow/Variable/Value columns; already-long tables use format = 'native'.", call. = FALSE)
  }
  selected$SourceRow <- seq_len(nrow(selected))
  tidyr::pivot_longer(selected, cols = dplyr::all_of(value_cols),
    names_to = "Variable", values_to = "Value", values_drop_na = FALSE)
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
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Discover which tables the default Wright map provides without drawing it
#' plot_data_components(fit)
#'
#' # Extract one of the listed components
#' locations <- plot_data(fit, component = "locations")
#' head(locations)
#'
#' # A different plot type has different reusable tables
#' plot_data_components(fit, type = "ccc")
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

truncate_axis_label <- function(x, width = 28L) {
  x <- as.character(x)
  width <- max(8L, as.integer(width))
  values <- unique(x)
  labels <- ifelse(nchar(values, type = "width") > width,
                    paste0(strtrim(values, width - 3L), "..."), values)
  collision <- (duplicated(labels) | duplicated(labels, fromLast = TRUE)) &
    !is.na(values) & nchar(values, type = "width") > width
  if (any(collision)) {
    tail_width <- ceiling((width - 3L) / 2)
    suffix <- substring(values[collision], nchar(values[collision]) - tail_width + 1L)
    while (any(nchar(suffix, type = "width") > tail_width)) {
      wide <- nchar(suffix, type = "width") > tail_width
      suffix[wide] <- substring(suffix[wide], 2L)
    }
    labels[collision] <- paste0(strtrim(values[collision], width - 3L - tail_width),
      "...", suffix)
    # Preserve full names when an abbreviation would still be ambiguous.
    while (anyDuplicated(labels)) {
      collision <- duplicated(labels) | duplicated(labels, fromLast = TRUE)
      labels[collision] <- values[collision]
    }
  }
  labels[match(x, values)]
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
      background = "#FFFFFF",
      panel_background = "#F8FAFC",
      strip_background = "#EEF2F7",
      foreground = "#17344B",
      axis = "#334155",
      grid = "#DCE3EB",
      fill_soft = "#DBEAFE",
      fill_muted = "#D6EEF2",
      fill_warm = "#FEE8D6",
      accent_primary = "#2176AE",
      accent_secondary = "#D88627",
      accent_tertiary = "#27988D",
      hist_fill = "#309B92",
      series = c("#2176AE", "#D88627", "#8064A2", "#27988D", "#A34D72", "#6E7D35"),
      success = "#238B45",
      warn = "#C26D18",
      fail = "#B83230",
      neutral = "#64748B",
      missing = "#CBD5E1",
      ref_line = "#8593A4",
      axis_cex = 0.88,
      label_cex = 0.96,
      title_cex = 1
    ),
    publication = list(
      name = "publication",
      background = "#FFFFFF",
      panel_background = "#FFFFFF",
      strip_background = "#F8FAFC",
      foreground = "#14213D",
      axis = "#243B53",
      grid = "#E2E8F0",
      fill_soft = "#D8EFF5",
      fill_muted = "#D7E9F3",
      fill_warm = "#FDE6CF",
      accent_primary = "#1B4965",
      accent_secondary = "#CA6702",
      accent_tertiary = "#2A9D8F",
      hist_fill = "#2A9D8F",
      series = c("#1B4965", "#CA6702", "#6D597A", "#2A9D8F", "#9B2226", "#588157"),
      success = "#1B6F5F",
      warn = "#AD6A12",
      fail = "#9B2226",
      neutral = "#52606D",
      missing = "#CBD5E1",
      ref_line = "#7B8794",
      axis_cex = 0.9,
      label_cex = 0.98,
      title_cex = 1.05
    ),
    compact = list(
      name = "compact",
      background = "#FFFFFF",
      panel_background = "#F8FAFC",
      strip_background = "#EEF2F7",
      foreground = "#17344B",
      axis = "#334155",
      grid = "#E2E8F0",
      fill_soft = "#DDEEFB",
      fill_muted = "#D9EBF5",
      fill_warm = "#FEECD9",
      accent_primary = "#2176AE",
      accent_secondary = "#D88627",
      accent_tertiary = "#27988D",
      hist_fill = "#309B92",
      series = c("#2176AE", "#D88627", "#8064A2", "#27988D", "#A34D72", "#6E7D35"),
      success = "#238B45",
      warn = "#C26D18",
      fail = "#B83230",
      neutral = "#64748B",
      missing = "#CBD5E1",
      ref_line = "#8593A4",
      axis_cex = 0.82,
      label_cex = 0.9,
      title_cex = 0.95
    ),
    monochrome = list(
      name = "monochrome",
      background = "#FFFFFF",
      panel_background = "#FFFFFF",
      strip_background = "#F1F5F9",
      foreground = "gray10",
      axis = "gray20",
      grid = "gray86",
      fill_soft = "gray88",
      fill_muted = "gray78",
      fill_warm = "gray70",
      accent_primary = "gray15",
      accent_secondary = "gray45",
      accent_tertiary = "gray65",
      hist_fill = "gray35",
      series = c("gray15", "gray35", "gray50", "gray65", "gray25", "gray55"),
      success = "gray30",
      warn = "gray45",
      fail = "gray10",
      neutral = "gray55",
      missing = "gray82",
      ref_line = "gray50",
      axis_cex = 0.88,
      label_cex = 0.96,
      title_cex = 1
    )
  )
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

# Conditional Rasch-family derivative at the SAME reference profile as the
# reported fair score. Inverting the fair score avoids reporting-scale,
# Person-sign and mean-reference errors. Calibration is held fixed here.
.fair_average_delta_variance <- function(fit, fair_df, metric = "FairM",
                                         totalscore = TRUE, obs = NULL) {
  out <- rep(NA_real_, nrow(fair_df))
  if (!inherits(fit, "mfrm_fit") || !fit$config$model %in% c("RSM", "PCM")) return(out)
  params <- expand_params(fit$opt$par, build_param_sizes(fit$config), fit$config)
  pcm <- identical(fit$config$model, "PCM")
  if (pcm) {
    if (is.null(obs)) obs <- compute_obs_table(fit)
    # Match calc_facets_report_tbls(): totalscore = FALSE excludes observations
    # with another extreme facet, including those with multiple extreme facets.
    if (!isTRUE(totalscore)) {
      extreme_flags <- lapply(c("Person", fit$config$facet_names), function(facet) {
        extreme <- vapply(split(obs$Observed, as.character(obs[[facet]])), function(y) {
          all(y == fit$prep$rating_min) || all(y == fit$prep$rating_max)
        }, logical(1))
        as.character(obs[[facet]]) %in% names(extreme)[extreme]
      })
      names(extreme_flags) <- c("Person", fit$config$facet_names)
      if (identical(fit$config$method, "JML") &&
          length(fit$config$interaction_specs) == 0L) {
        unanchored <- .mfrm_unanchored_extremes(fit, obs)
        extreme_flags <- lapply(names(extreme_flags), function(facet)
          as.character(obs[[facet]]) %in% unanchored[[facet]]) |>
          stats::setNames(c("Person", fit$config$facet_names))
      }
      extreme_count <- Reduce(`+`, extreme_flags)
    }
    owner <- match(as.character(obs[[fit$config$step_facet]]),
      fit$prep$levels[[fit$config$step_facet]])
    weights <- get_weights(obs)
  }
  for (i in seq_len(nrow(fair_df))) {
    if (pcm) {
      facet <- fair_df$Facet[i]
      use <- as.character(obs[[facet]]) == fair_df$Level[i]
      if (!isTRUE(totalscore)) {
        use <- use & (extreme_count == 0 | (extreme_count == 1 & extreme_flags[[facet]]))
      }
      rows <- which(use)
      if (!length(rows) || anyNA(owner[rows]) ||
          any(!is.finite(weights[rows]) | weights[rows] < 0) || sum(weights[rows]) <= 0) next
      scale_weights <- tapply(weights[rows], owner[rows], sum)
      scale_weights <- scale_weights / sum(scale_weights)
      scale_steps <- lapply(as.integer(names(scale_weights)), function(j) {
        c(0, cumsum(params$steps_mat[j, ]))
      })
      moments <- function(eta) {
        per_scale <- vapply(scale_steps, function(cumulative) {
          prob <- as.numeric(category_prob_rsm(eta, cumulative))
          scores <- seq_along(prob) - 1
          mean <- sum(prob * scores)
          c(mean = mean + fit$prep$rating_min,
            variance = sum(prob * (scores - mean)^2))
        }, numeric(2))
        as.numeric(per_scale %*% scale_weights)
      }
      target <- fair_df[[metric]][i]
      if (!is.finite(target)) next
      residual <- function(eta) moments(eta)[1] - target
      boundary <- c(residual(-20), residual(20))
      if (any(!is.finite(boundary)) || prod(sign(boundary)) > 0) next
      eta <- stats::uniroot(residual, lower = -20, upper = 20, tol = 1e-10)$root
      # The derivative is the mean of within-scale variances, without the
      # between-scale term that would enter a mixture's total variance.
      out[i] <- moments(eta)[2]
      next
    }
    cumulative <- c(0, cumsum(params$steps))
    eta <- estimate_eta_from_target(fair_df[[metric]][i], cumulative,
                                    fit$prep$rating_min, fit$prep$rating_max)
    if (!is.finite(eta)) next
    prob <- as.numeric(category_prob_rsm(eta, cumulative))
    scores <- seq_along(prob) - 1
    out[i] <- sum(prob * (scores - sum(prob * scores))^2)
  }
  out
}

resolve_unexpected_bundle <- function(x,
                                      diagnostics = NULL,
                                      abs_z_min = 3,
                                      prob_max = 0.30,
                                      top_n = 100,
                                      rule = "residual") {
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
    validate_fair_measure_basis(x)
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
    validate_descriptive_bundle(x, "mfrm_interrater")
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
    mfrm_results_validate_diagnostics_identity(x, diagnostics, helper = "marginal diagnostic plots")
  } else if (inherits(x, "mfrm_diagnostics") || (is.list(x) && !is.null(x$marginal_fit))) {
    diagnostics <- x
  } else {
    stop("`x` must be an mfrm_fit object or output from diagnose_mfrm().", call. = FALSE)
  }

  marginal_fit <- diagnostics$marginal_fit %||% NULL
  validate_marginal_coverage(marginal_fit)
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

#' Plot strict marginal-fit follow-up cells with ggplot2
#'
#' @param x Output from [fit_mfrm()] or [diagnose_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param plot_type `"std_residual"` or `"prop_diff"`.
#' @param top_n Maximum cells shown.
#' @param facet Optional facet name used to keep only matching facet-level rows.
#'   When `NULL`, the plot uses the mixed top-cell table returned by the strict
#'   marginal screen.
#' @param main Compatibility title argument. Omitted or `NULL` keeps the default
#'   title. Existing calls remain supported without a deprecation warning.
#'   For new code, prefer `title`; do not supply both arguments.
#' @param title Plot title. Omit it to keep the default, supply one character
#'   string to replace it, or use `NULL` (or `""`) to suppress it. This changes
#'   only the heading; numerical results, reference lines, subtitles and
#'   interpretation notes remain. Both `main` and `title` explicitly supplied
#'   is an error, even if equal or `NULL`. Positional legacy arguments retain
#'   their order; use the exact name `title`.
#' @param palette Optional named color overrides. Recognized names:
#'   `positive`, `negative`, `flag`.
#' @param label_angle X-axis label angle.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`,
#'   or `"monochrome"`).
#' @param draw If `TRUE`, print the `ggplot` object.
#'
#' @details
#' This helper visualizes the largest first-order strict marginal-fit cells from
#' `diagnose_mfrm(..., diagnostic_mode = "both")` or
#' `diagnostic_mode = "marginal_fit"`.
#'
#' The `"std_residual"` view ranks cells by the absolute standardized residual
#' from posterior-integrated expected category counts. The `"prop_diff"` view
#' ranks cells by the absolute observed-minus-expected proportion gap and plots
#' their signed gaps. Both views apply the facet filter before ranking all cells.
#' The returned `full_table` retains all candidate rows; `retention` records
#' available/unavailable values for the selected metric. Undefined values are
#' not zero residuals, and grey bars/labels indicate unavailable values or flags.
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
#' 3. Use `plot()` to inspect the largest strict marginal cells.
#' 4. Follow up with [rating_scale_table()] or substantive design review.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes.
#' @seealso [diagnose_mfrm()], [rating_scale_table()], [plot(x, type = "marginal_pairwise")][plot.mfrm_fit],
#'   [mfrmr_visual_diagnostics]
#' @examples
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Use the diagnostics saved with this fit
#' diagnostics <- example_fit$diagnostics
#'
#' # Which score categories occur more or less often than the model expects?
#' plot(diagnostics, type = "marginal_fit")
#' # Positive bars: more frequent than expected; negative bars: less frequent
#'
#' # Optional: show observed-minus-expected proportions instead
#' # Run this command separately to inspect the second figure
#' plot(diagnostics, type = "marginal_fit", view = "prop_diff")
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_marginal_fit <- function(x,
                              diagnostics = NULL,
                              plot_type = c("std_residual", "prop_diff"),
                              top_n = 20,
                              facet = NULL,
                              main = NULL,
                              palette = NULL,
                              label_angle = 45,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              draw = TRUE,
                              title = NULL) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  main <- .mfrm_plot_title_alias(main, title, missing(main), missing(title))
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
  tbl <- as.data.frame(dplyr::bind_rows(bundle$marginal_fit$step_or_scale$cell_stats,
                                        bundle$marginal_fit$facet_level$cell_stats))
  if (nrow(tbl) == 0) {
    stop("No strict marginal cell rows are available for plotting.", call. = FALSE)
  }
  if (!is.null(facet)) {
    facet <- as.character(facet[1])
    tbl <- tbl[as.character(tbl$Facet %||% "") %in% facet, , drop = FALSE]
  }
  if (nrow(tbl) == 0) {
    stop("No strict marginal cell rows matched the requested `facet` filter.", call. = FALSE)
  }

  metric_vals <- if (identical(plot_type, "std_residual")) {
    abs(suppressWarnings(as.numeric(tbl$StdResidual)))
  } else {
    abs(suppressWarnings(as.numeric(tbl$PropDiff)))
  }
  metric_vals[!is.finite(metric_vals)] <- NA_real_
  retention <- data.frame(Candidates = nrow(tbl), Available = sum(is.finite(metric_vals)), Unavailable = sum(!is.finite(metric_vals)))
  ord <- order(metric_vals, decreasing = TRUE, na.last = TRUE)
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
  flagged <- as.logical(sub$FlaggedAbsZ %||% rep(NA, nrow(sub)))
  cols <- ifelse(
    flagged,
    pal["flag"],
    ifelse(values >= 0, pal["positive"], pal["negative"])
  )

  cols[is.na(flagged) | !is.finite(values)] <- "grey70"
  values[!is.finite(values)] <- NA_real_
  abs_z_warn <- as.numeric(bundle$marginal_fit$thresholds$abs_z_warn %||% 2)
  plot_title <- switch(
    plot_type,
    std_residual = "Strict marginal category screening scores",
    prop_diff = "Strict marginal category gaps"
  )
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- sprintf("Posterior-expected screen; %d displayed from %d cells; %d selected-metric values unavailable.",
                           nrow(sub), nrow(tbl), retention$Unavailable)
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
  plot_legend <- rbind(plot_legend, new_plot_legend(label = "Value or classification unavailable", role = "status", aesthetic = "bar", value = "grey70"))
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

  out <- new_mfrm_plot_data(
    "marginal_fit",
    list(
      plot = plot_type,
      table = sub,
      full_table = tbl,
      coverage = bundle$marginal_fit$coverage,
      retention = retention,
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
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Plot strict pairwise local-dependence follow-up with ggplot2
#'
#' @param x Output from [fit_mfrm()] or [diagnose_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param metric `"exact"` or `"adjacent"`.
#' @param top_n Maximum level pairs shown.
#' @param facet Optional facet name used to keep only matching pairwise rows.
#' @inheritParams plot_marginal_fit
#' @param palette Optional named color overrides. Recognized names: `ok`, `flag`.
#' @param label_angle X-axis label angle.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, print the `ggplot` object.
#'
#' @details
#' This helper visualizes the strict pairwise local-dependence follow-up derived
#' from posterior-integrated expected exact and adjacent agreement.
#'
#' The `"exact"` view ranks level pairs by the absolute exact-agreement
#' standardized residual. The `"adjacent"` view uses the adjacent-agreement
#' standardized residual instead. Both are exploratory corroboration screens for
#' strict marginal-fit flags. Selection uses all pairs within the requested
#' facet, not a preselected list for the other metric. `retention` counts
#' available/unavailable metric values, while `full_table` retains all candidates.
#' Grey bars/labels indicate unavailable values or classifications.
#'
#' @section Interpreting output:
#' - Positive bars mean the observed agreement exceeded the posterior-expected
#'   agreement for that level pair.
#' - Negative bars mean the observed agreement fell below the posterior-expected
#'   agreement.
#' - Red bars indicate an available standardized-residual or agreement-gap
#'   rule was crossed. A missing companion rule does not cancel a known crossing.
#'   These are descriptive cutoffs without calibrated error rates.
#'
#' @section Typical workflow:
#' 1. Fit with [fit_mfrm()] using `method = "MML"` for `RSM` / `PCM`.
#' 2. Run [diagnose_mfrm()] with `diagnostic_mode = "both"`.
#' 3. Use `plot()` to inspect level pairs behind pairwise
#'    local-dependence flags.
#' 4. Corroborate with legacy diagnostics, design review, and substantive
#'    interpretation before making claims.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes.
#' @seealso [diagnose_mfrm()], [plot(x, type = "marginal_fit")][plot.mfrm_fit], [mfrmr_visual_diagnostics]
#' @examples
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Use the diagnostics saved with this fit
#' diagnostics <- example_fit$diagnostics
#'
#' # Which pairs show more or less exact agreement than the model expects?
#' plot(diagnostics, type = "marginal_pairwise")
#' # These are screening results; inspect the rating design before drawing conclusions
#'
#' # Optional: agreement within one score category
#' plot(diagnostics, type = "marginal_pairwise", metric = "adjacent")
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_marginal_pairwise <- function(x,
                                   diagnostics = NULL,
                                   metric = c("exact", "adjacent"),
                                   top_n = 20,
                                   facet = NULL,
                                   main = NULL,
                                   palette = NULL,
                                   label_angle = 45,
                                   preset = c("standard", "publication", "compact", "monochrome"),
                                   draw = TRUE,
                                   title = NULL) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  main <- .mfrm_plot_title_alias(main, title, missing(main), missing(title))
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
  tbl <- as.data.frame(bundle$marginal_fit$pairwise$pair_stats %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) {
    stop("No strict pairwise local-dependence rows are available for plotting.", call. = FALSE)
  }
  if (!is.null(facet)) {
    facet <- as.character(facet[1])
    tbl <- tbl[as.character(tbl$Facet %||% "") %in% facet, , drop = FALSE]
  }
  if (nrow(tbl) == 0) {
    stop("No strict pairwise rows matched the requested `facet` filter.", call. = FALSE)
  }

  metric_vals <- if (identical(metric, "exact")) {
    abs(suppressWarnings(as.numeric(tbl$ExactStdResidual)))
  } else {
    abs(suppressWarnings(as.numeric(tbl$AdjacentStdResidual)))
  }
  metric_vals[!is.finite(metric_vals)] <- NA_real_
  retention <- data.frame(Candidates = nrow(tbl), Available = sum(is.finite(metric_vals)), Unavailable = sum(!is.finite(metric_vals)))
  ord <- order(metric_vals, decreasing = TRUE, na.last = TRUE)
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
    as.logical(sub$FlaggedExact %||% rep(NA, nrow(sub)))
  } else {
    as.logical(sub$FlaggedAdjacent %||% rep(NA, nrow(sub)))
  }
  cols <- ifelse(flagged, pal["flag"], pal["ok"])
  cols[is.na(flagged) | !is.finite(values)] <- "grey70"
  values[!is.finite(values)] <- NA_real_
  abs_z_warn <- as.numeric(bundle$marginal_fit$thresholds$abs_z_warn %||% 2)

  plot_title <- switch(
    metric,
    exact = "Strict pairwise exact-agreement screening scores",
    adjacent = "Strict pairwise adjacent-agreement screening scores"
  )
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- sprintf("Posterior-expected agreement screen; %d displayed from %d level pairs; %d selected-metric values unavailable.",
                           nrow(sub), nrow(tbl), retention$Unavailable)
  plot_legend <- new_plot_legend(
    label = c("No available rule crossed", "Flagged level pair"),
    role = c("status", "status"),
    aesthetic = c("bar", "bar"),
    value = c(pal["ok"], pal["flag"])
  )
  plot_legend <- rbind(plot_legend, new_plot_legend(label = "Value or classification unavailable", role = "status", aesthetic = "bar", value = "grey70"))
  plot_reference <- new_reference_lines(
    axis = c("h", "h", "h"),
    value = c(-abs_z_warn, 0, abs_z_warn),
    label = c("Negative review threshold", "Centered reference", "Positive review threshold"),
    linetype = c("dashed", "solid", "dashed"),
    role = c("threshold", "reference", "threshold")
  )

  out <- new_mfrm_plot_data(
    "marginal_pairwise",
    list(
      plot = metric,
      table = sub,
      full_table = tbl,
      coverage = bundle$marginal_fit$pairwise$coverage,
      retention = retention,
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
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Plot unexpected responses with ggplot2
#'
#' @param x Output from [fit_mfrm()] or [unexpected_response_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param abs_z_min Absolute standardized-residual cutoff (default 3).
#' @param prob_max Maximum observed-category probability cutoff.
#' @param top_n Maximum rows used from the unexpected table.
#' @param rule Flagging rule: `"residual"` (default), `"either"`, or `"both"`.
#' @param plot_type `"scatter"` or `"severity"`.
#' @inheritParams plot_marginal_fit
#' @param palette Optional named color overrides (`higher`, `lower`, `bar`).
#' @param label_angle X-axis label angle for `"severity"` bar plot.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, print the `ggplot` object.
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
#' Saved table bundles retain their recorded rule and thresholds. A fully
#' evaluated screen with no flags returns an empty display and its summary.
#' The `rule` parameter controls flagging logic:
#' - `"residual"`: flag by the absolute standardized residual alone.
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
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes.
#' @seealso [unexpected_response_table()], [plot(x, type = "fair_average")][plot.mfrm_fit], [plot(x, type = "displacement")][plot.mfrm_fit],
#'   [plot(x, type = "qc")][plot.mfrm_fit], [mfrmr_visual_diagnostics]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_unexpected", run.dontrun = TRUE)
#' \dontrun{
#' # Saved synthetic JML/RSM analysis of example_core.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#' p <- plot(fit, type = "unexpected", abs_z_min = 1.5, prob_max = 0.4, top_n = 10, draw = FALSE)
#' if (interactive()) {
#'   plot(fit, type = "unexpected", abs_z_min = 1.5, prob_max = 0.4,
#'     top_n = 10, view = "severity", preset = "publication",
#'     main = "Unexpected Response Severity (Customized)",
#'     palette = c(higher = "#d95f02", lower = "#1b9e77", bar = "#2b8cbe"),
#'     label_angle = 45)
#' }
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_unexpected <- function(x,
                            diagnostics = NULL,
                            abs_z_min = 3,
                            prob_max = 0.30,
                            top_n = 100,
                            rule = c("residual", "either", "both"),
                            plot_type = c("scatter", "severity"),
                            main = NULL,
                            palette = NULL,
                            label_angle = 45,
                            preset = c("standard", "publication", "compact", "monochrome"),
                            draw = TRUE,
                            title = NULL) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  main <- .mfrm_plot_title_alias(main, title, missing(main), missing(title))
  rule <- match.arg(tolower(rule), c("residual", "either", "both"))
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
  validate_unexpected_coverage(bundle)
  abs_z_min <- bundle$thresholds$abs_z_min
  prob_max <- bundle$thresholds$prob_max
  rule <- bundle$thresholds$rule
  tbl <- as.data.frame(bundle$table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) {
    if (!isTRUE(bundle$summary$UnavailableObservations[1] == 0)) {
      stop("No responses were flagged, but some responses could not be classified; inspect the screening summary.", call. = FALSE)
    }
  }
  tbl <- tbl[seq_len(min(nrow(tbl), top_n)), , drop = FALSE]
  plot_title <- if (plot_type == "scatter") "Unexpected responses" else "Unexpected response severity"
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- if (identical(rule, "residual")) {
    sprintf("Rule: residual; |Z| >= %s", format(abs_z_min))
  } else sprintf("Rule: %s; |Z| >= %s; P(obs) <= %s", rule, format(abs_z_min), format(prob_max))
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

  if (identical(rule, "residual") && nrow(plot_reference)) {
    plot_reference <- plot_reference[plot_reference$axis != "h", , drop = FALSE]
  }

  out <- new_mfrm_plot_data(
    "unexpected",
    list(
      plot = plot_type,
      table = tbl,
      summary = bundle$summary,
      thresholds = bundle$thresholds,
      notes = if (!nrow(tbl)) "No unexpected responses under the recorded rule." else character(),
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Plot fair-average diagnostics with ggplot2
#'
#' @param x Output from [fit_mfrm()] or [fair_average_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param facet Optional facet name or names. Use `"Person"` for ability-to-score relationships.
#' @param metric Adjusted-score metric. Accepts legacy names (`"FairM"`,
#'   `"FairZ"`) and package-native names (`"AdjustedAverage"`,
#'   `"StandardizedAdjustedAverage"`).
#' @param plot_type `"difference"`, `"scatter"`, or `"measure"` (Measure on x, fair score on y).
#' @param top_n Maximum levels shown for `"difference"` plot.
#' @param show_ci Draw approximate fair-score intervals. RSM/PCM propagate
#'   only the focal measure SE, holding thresholds, other effects and reference
#'   means fixed. This is not full calibration uncertainty. GPCM uses available
#'   structural delta-method SEs, conditioning on person EAP/reference means;
#'   person rows are unavailable. Bounds are clipped to the internal rating
#'   range. Unavailable intervals are retained as NA with status and notes.
#'   The difference view treats the observed average as fixed: its whiskers
#'   are not confidence intervals for the observed-minus-fair gap.
#'   Returned `CI_Eligible` is `FALSE`; `CI_ReportingUse` distinguishes
#'   diagnostic-only and unavailable intervals, including stored bundles.
#' @param ci_level Confidence level used when `show_ci = TRUE`;
#'   default `0.95`. The returned plot-data object gains `CI_Lower`,
#'   `CI_Upper`, and `CI_Level` columns for downstream reuse.
#' @param draw If `TRUE`, print the `ggplot` object.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param ... Additional arguments passed to [fair_average_table()] when `x` is `mfrm_fit`.
#'
#' @param show_title Show the figure title. The title remains in the return value.
#' @param show_notes Show short figure annotations. Full interpretation and
#'   uncertainty notes remain in `plot_data(p, "notes")` and the ggplot `mfrmr_notes` attribute.
#'
#' @details
#' FairM is an expected score at the mean measures of the other facets; for
#' non-person rows it also uses the mean estimated person measure. FairZ uses
#' zero reference measures instead. **FairZ is not a z-score.** The historical
#' alias `StandardizedAdjustedAverage` refers to the reference environment,
#' not z-standardization. Both metrics use fitted internal score coding.
#' PCM averages expectations over the administered rating scales using the
#' same observation weights and `totalscore` selection as the fair-score table.
#' Its conditional derivative averages the within-scale score variances.
#' In ordinary additive RSM/PCM JML, finite direct anchors remain eligible in
#' both the fair score and its conditional derivative when `totalscore = FALSE`,
#' even if their observed responses are all minimum or all maximum.
#' GPCM uses an element's own thresholds for the step facet and the mean
#' threshold profile for other facets, with its own slope for the slope facet
#' and slope 1 otherwise. Person and other-facet measures remain at the chosen
#' reference; these scores do not average over the observed person distribution.
#'
#' `plot_type = "measure"` connects measures (person ability or facet effects)
#' to the reported fair score. Select `facet = "Person"` for an ability-to-score
#' view. Points reuse the table values, without fitting a trend across different
#' reference profiles. This transformation is not independent validation of
#' the fitted model. `umean`/`uscale` change Measure units, not score units;
#' Positive `xtreme` disables conditional fair-score intervals. With the default
#' `xtreme_method = "display"`, it changes only the reported Measure.
#' `xtreme_method = "facets"` also uses the extrapolated measure in that
#' element's fair scores; its measure SE describes information at a corrected
#' total, not uncertainty of the original infinite MLE. See [fair_average_table()].
#'
#' `"difference"` ranks absolute observed-minus-fair gaps; `"scatter"` compares
#' observed averages against fair scores with an identity line. These gaps
#' also reflect assignment and person mix and do not by themselves diagnose
#' leniency, severity or bias. Intervals are conditional approximations with
#' full-refit coverage unverified. RSM/PCM intervals require a fitted model;
#' a stored bundle alone lacks the calibration needed to calculate them.
#' GPCM bundle intervals honor `ci_level`; older bundles without rating limits
#' can only reuse intervals at their recorded confidence level.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes.
#' With `draw = FALSE`, the returned plot data includes `title`, `subtitle`,
#' `legend`, `reference_lines`, and the stacked fair-average `data`.
#' `plot_data` contains the displayed rows and coordinates; `excluded` retains
#' non-finite rows. `notes` explains the reference, uncertainty and row selection.
#' @seealso [fair_average_table()], [plot(x, type = "unexpected")][plot.mfrm_fit], [plot(x, type = "displacement")][plot.mfrm_fit],
#'   [plot(x, type = "qc")][plot.mfrm_fit], [mfrmr_visual_diagnostics]
#' @concept confidence intervals
#' @concept visual diagnostics
#' @concept fair averages
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_fair_average", run.dontrun = TRUE)
#' \dontrun{
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Use the diagnostics saved with this fit
#' diagnostics <- example_fit$diagnostics
#'
#' # How do the observed and reference-adjusted person averages compare?
#' plot(fit, type = "fair_average", diagnostics = diagnostics,
#'   facet = "Person", metric = "FairM", view = "scatter")
#'
#' # Optional: inspect the gap (observed average minus FairM)
#' plot(fit, type = "fair_average", diagnostics = diagnostics,
#'   facet = "Person", metric = "FairM", view = "difference")
#' # A positive gap means the observed average is higher than the model-based FairM
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_fair_average <- function(x,
                              diagnostics = NULL,
                              facet = NULL,
                              metric = c("AdjustedAverage", "StandardizedAdjustedAverage", "FairM", "FairZ"),
                              plot_type = c("difference", "scatter", "measure"),
                              top_n = 40,
                              show_ci = FALSE,
                              ci_level = 0.95,
                              draw = TRUE,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              show_title = FALSE,
                              show_notes = FALSE,
                              marginal = c("auto", "histogram", "none"),
                              ...) {
  if (identical(x$settings$estimator, "jeffreys_canonical_joint"))
    stop("This result contains common-plan Jeffreys scores, not FairM/FairZ diagnostics. Plot its confint() result, or inspect reference_scores.", call. = FALSE)
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  marginal <- .mfrmr_resolve_marginal_arg(marginal)
  metric <- match.arg(metric)
  metric <- switch(metric, AdjustedAverage = "FairM", StandardizedAdjustedAverage = "FairZ", metric)
  plot_type <- match.arg(tolower(plot_type), c("difference", "scatter", "measure"))
  if (!is.numeric(top_n) || length(top_n) != 1L || is.na(top_n) || top_n < 1) {
    stop("`top_n` must be a positive number.", call. = FALSE)
  }
  if (!is.numeric(ci_level) || length(ci_level) != 1L ||
      !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1) {
    stop("`ci_level` must be a single number in (0, 1).", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  is_fit <- inherits(x, "mfrm_fit")
  bundle <- if (is_fit) {
    args <- list(...)
    if (isTRUE(show_ci) && identical(x$config$model, "GPCM") && is.null(args$fair_se)) args$fair_se <- TRUE
    if (isTRUE(args$fair_se)) args$ci_level <- ci_level
    do.call(fair_average_table, c(list(fit = x, diagnostics = diagnostics), args))
  } else resolve_fair_bundle(x)
  report_scale <- bundle$settings$uscale %||% 1
  report_origin <- bundle$settings$umean %||% 0
  if (!is.finite(report_scale)) report_scale <- 1
  if (!is.finite(report_origin)) report_origin <- 0
  fair_df <- stack_fair_raw_tables(bundle$raw_by_facet)
  needed <- c("Facet", "Level", "ObservedAverage", metric,
              if (plot_type == "measure") "Measure")
  if (!all(needed %in% names(fair_df))) stop("Fair-average table does not include required columns.")
  if (!is.null(facet)) {
    fair_df <- fair_df[as.character(fair_df$Facet) %in% as.character(facet), , drop = FALSE]
    if (!nrow(fair_df)) stop("Requested `facet` was not found in fair-average output.")
  }
  mean_reference_unavailable <- identical(metric, "FairM") &&
    any(grepl("mean Person measure is unbounded", fair_df$FairMReference, fixed = TRUE))
  finite <- is.finite(fair_df[[metric]]) & is.finite(fair_df[[if (plot_type == "measure") "Measure" else "ObservedAverage"]])
  excluded <- fair_df[!finite, , drop = FALSE]
  fair_df <- fair_df[finite, , drop = FALSE]
  if (!nrow(fair_df)) {
    if (mean_reference_unavailable) stop(paste(
      "FairM is unavailable because the mean JML Person measure is unbounded.",
      "Use metric = \"FairZ\" for a zero-reference summary."
    ), call. = FALSE)
    stop("No finite fair-average rows available.")
  }
  fair_df$Gap <- fair_df$ObservedAverage - fair_df[[metric]]
  ci_note <- NULL
  if (isTRUE(show_ci)) {
    fair_df$CI_SE <- NA_real_
    fair_df$CI_Lower <- fair_df$CI_Upper <- NA_real_
    fair_df$CI_Level <- ci_level
    fair_df$CI_Status <- "unavailable"
    fair_df$CI_Method <- "unavailable"
    if (identical(bundle$settings$model, "GPCM")) {
      se_col <- paste0(metric, "SE")
      if (se_col %in% names(fair_df)) {
        fair_df$CI_SE <- fair_df[[se_col]]
        fair_df$CI_Status <- fair_df[[paste0(metric, "_SE_Status")]] %||% "unavailable"
        fair_df$CI_Method <- "structural delta method"
      }
      ci_note <- "structural delta method; person EAP/reference mean held fixed; person rows unavailable."
    } else if (is_fit && "ModelSE" %in% names(fair_df)) {
      scale <- bundle$settings$uscale %||% 1
      if (!is.finite(scale)) scale <- 1
      if (scale != 0 && (bundle$settings$xtreme %||% 0) == 0) {
        variance <- .fair_average_delta_variance(x, fair_df, metric,
          totalscore = bundle$settings$totalscore %||% TRUE, obs = diagnostics$obs)
        valid <- is.finite(variance) & variance > 1e-6 & is.finite(fair_df$ModelSE) & fair_df$ModelSE >= 0
        fair_df$CI_SE[valid] <- variance[valid] * fair_df$ModelSE[valid] / abs(scale)
        fair_df$CI_Status[valid] <- "conditional_approximation"
        fair_df$CI_Method[valid] <- "conditional measure delta method"
      }
      ci_note <- "Conditional measure delta method; thresholds, other effects and reference means held fixed."
    } else ci_note <- "CI unavailable: pass a fitted model or a GPCM bundle with fair_se = TRUE."
    limits <- c(bundle$settings$rating_min, bundle$settings$rating_max)
    if (length(limits) != 2L && is_fit) limits <- c(x$prep$rating_min, x$prep$rating_max)
    if (length(limits) == 2L && all(is.finite(limits))) {
      z <- stats::qnorm((1 - ci_level) / 2, lower.tail = FALSE)
      fair_df$CI_Lower <- pmax(limits[1], fair_df[[metric]] - z * fair_df$CI_SE)
      fair_df$CI_Upper <- pmin(limits[2], fair_df[[metric]] + z * fair_df$CI_SE)
    } else {
      # Older bundles retain their own confidence level; never relabel a 95% CI as 90%.
      cols <- paste0(metric, c("_CI_Lower", "_CI_Upper", "_CI_Level"))
      if (all(cols %in% names(fair_df))) {
        same <- is.finite(fair_df[[cols[3]]]) & abs(fair_df[[cols[3]]] - ci_level) < 1e-12
        fair_df$CI_Lower[same] <- fair_df[[cols[1]]][same]
        fair_df$CI_Upper[same] <- fair_df[[cols[2]]][same]
      }
    }
    unavailable <- !is.finite(fair_df$CI_Lower) | !is.finite(fair_df$CI_Upper)
    fair_df$CI_Status[unavailable] <- "unavailable"
    fair_df$CI_Eligible <- FALSE
    fair_df$CI_ReportingUse <- ifelse(unavailable, "unavailable", "diagnostic_only")
    ci_note <- paste0(round(100 * ci_level), "% approximate intervals. ", ci_note,
      " These intervals omit some sources of estimation uncertainty; ", sum(unavailable), " row(s) unavailable.",
      if (plot_type == "difference") " Observed averages treated as fixed; these are not gap confidence intervals." else "")
  }
  groups <- unique(as.character(fair_df$Facet))
  encoding <- data.frame(Facet = groups, Color = unname(.plot_series_colors(groups, style$name)),
    Shape = rep(c(16, 17, 15, 18, 1, 2), length.out = length(groups)))
  fair_df$Color <- encoding$Color[match(fair_df$Facet, groups)]
  fair_df$Shape <- encoding$Shape[match(fair_df$Facet, groups)]
  plot_df <- fair_df
  if (plot_type == "difference") {
    ord <- order(abs(plot_df$Gap), decreasing = TRUE)
    plot_df <- plot_df[head(ord, min(length(ord), top_n)), , drop = FALSE]
  }
  plot_df$Label <- paste(plot_df$Facet, plot_df$Level, sep = ": ")
  plot_df$X <- switch(plot_type, difference = plot_df$Gap, scatter = plot_df[[metric]], measure = plot_df$Measure)
  plot_df$Y <- switch(plot_type, difference = rev(seq_len(nrow(plot_df))), scatter = plot_df$ObservedAverage, measure = plot_df[[metric]])
  plot_df$Lower <- plot_df$Upper <- NA_real_
  if (isTRUE(show_ci)) {
    plot_df$Lower <- if (plot_type == "difference") plot_df$ObservedAverage - plot_df$CI_Upper else plot_df$CI_Lower
    plot_df$Upper <- if (plot_type == "difference") plot_df$ObservedAverage - plot_df$CI_Lower else plot_df$CI_Upper
  }
  reference_note <- if (metric == "FairM") {
    "FairM: expected score at mean other-facet measures (and mean person measure for non-person rows)."
  } else "FairZ: expected score at zero other-facet/person reference; Z does not mean z-score."
  reference_note <- paste(reference_note,
    "PCM averages administered-scale expectations using observation weights and the table's totalscore selection.",
    "GPCM uses own thresholds for the step facet, otherwise mean thresholds; own slope for the slope facet, otherwise slope 1.")
  score_note <- paste("Scores use fitted internal category coding. Gaps also reflect assignment/person mix;",
    "they do not by themselves establish leniency, severity or bias.")
  if (plot_type == "measure") score_note <- paste(score_note,
    "Points show a model-based transformation, not independent validation. Do not pool correlations across facets.")
  if ((bundle$settings$xtreme %||% 0) > 0) score_note <- paste(score_note,
    if (identical(bundle$settings$xtreme_method, "facets"))
      "FACETS total-score extrapolation changes the extreme element's reported Measure and fair scores. Its measure SE is conditional on the adjusted total; fair-score intervals remain unavailable. Primary estimates and anchors are retained." else
        "xtreme changes the displayed Measure only; fair scores are unchanged and conditional intervals unavailable.")
  if (mean_reference_unavailable) score_note <- paste(score_note,
    "Non-Person FairM rows are unavailable because the mean JML Person measure is unbounded; FairZ uses a zero reference.")
  interval_caption <- if (plot_type == "difference") {
    "Approximate fair-score intervals; observed means held fixed."
  } else "Approximate fair-score intervals omit some estimation uncertainty."
  out <- new_mfrm_plot_data("fair_average", list(
    plot = plot_type, metric = metric, data = fair_df, plot_data = plot_df,
    excluded = excluded, settings = bundle$settings, ci_note = ci_note,
    title = switch(plot_type, difference = paste("Observed -", metric),
      scatter = paste("Observed vs", metric), measure = paste("Measure and", metric)),
    subtitle = if (isTRUE(show_ci)) interval_caption else reference_note,
    caption = NULL, display = list(show_title = isTRUE(show_title), show_notes = isTRUE(show_notes)),
    xlab = switch(plot_type, difference = paste("Observed -", metric), scatter = paste(metric, "(internal score)"),
      measure = if (report_scale == 1 && report_origin == 0) "Measure (logits)" else "Measure (reporting units)"),
    ylab = switch(plot_type, difference = "", scatter = "Observed average (internal score)", measure = paste(metric, "(internal score)")),
    encoding = encoding,
    legend = new_plot_legend(groups, rep("facet", length(groups)), rep("point", length(groups)), encoding$Color),
    reference_lines = if (plot_type == "difference") new_reference_lines("v", 0, "Zero gap", "dashed", "reference") else if (plot_type == "scatter") new_reference_lines("diag", 1, "Identity", "dashed", "reference") else NULL,
    marginal = marginal,
    preset = style$name))
  if (is_fit) out <- .mfrm_attach_plot_readiness(out, .mfrm_fit_plot_readiness(x))
  out$data$notes <- rbind(.mfrm_plot_notes(out$data), data.frame(
    Type = c("reference", "interpretation", if (!is.null(ci_note)) "uncertainty", "retention"),
    Text = c(reference_note, score_note, ci_note,
      paste(nrow(excluded), "non-finite rows excluded;", nrow(plot_df), "of", nrow(fair_df), "finite rows displayed."))))
  if (length(groups) > 6L) out$data$notes <- rbind(out$data$notes,
    data.frame(Type = "display", Text = "Shapes repeat beyond six facets; select a facet for an unambiguous grayscale display."))
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Plot displacement diagnostics with ggplot2
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
#' @param draw If `TRUE`, print the `ggplot` object.
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
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes.
#' @seealso [displacement_table()], [plot(x, type = "unexpected")][plot.mfrm_fit], [plot(x, type = "fair_average")][plot.mfrm_fit],
#'   [plot(x, type = "qc")][plot.mfrm_fit], [mfrmr_visual_diagnostics]
#' @concept confidence intervals
#' @concept visual diagnostics
#' @concept displacement
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_displacement", run.dontrun = TRUE)
#' \dontrun{
#' # Saved synthetic JML/RSM analysis of example_core.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#' p <- plot(fit, type = "displacement", anchored_only = FALSE, draw = FALSE)
#' if (interactive()) {
#'   plot(fit, type = "displacement", anchored_only = FALSE, view = "lollipop", preset = "publication")
#' }
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_displacement <- function(x,
                              diagnostics = NULL,
                              anchored_only = FALSE,
                              facets = NULL,
                              plot_type = c("lollipop", "hist", "scatter"),
                              top_n = 40,
                              show_ci = FALSE,
                              ci_level = 0.95,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              marginal = c("auto", "histogram", "none"),
                              draw = TRUE,
                              ...) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  marginal <- .mfrmr_resolve_marginal_arg(marginal)
  plot_type <- match.arg(tolower(plot_type), c("lollipop", "hist", "scatter"))
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
    z_ci <- stats::qnorm((1 - ci_level) / 2, lower.tail = FALSE)
    tbl$CI_Lower <- tbl$Displacement - z_ci * tbl$DisplacementSE
    tbl$CI_Upper <- tbl$Displacement + z_ci * tbl$DisplacementSE
    tbl$CI_Level <- ci_level
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
      marginal = marginal,
      preset = style$name
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Plot inter-rater agreement diagnostics with ggplot2
#'
#' @param x Output from [fit_mfrm()] or [interrater_agreement_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param rater_facet Name of the rater facet when `x` is `mfrm_fit`.
#' @param context_facets Optional context facets when `x` is `mfrm_fit`.
#' @param exact_warn Warning threshold for exact agreement when `x` is a fit.
#'   Saved agreement results use their own thresholds; conflicting overrides
#'   are rejected. Recreate the agreement result to change its flag rules.
#' @param corr_warn Warning threshold for pairwise correlation when `x` is a fit.
#'   Saved agreement results use their own threshold.
#' @param plot_type `"exact"`, `"corr"`, or `"difference"`.
#' @param top_n Maximum pairs displayed for bar-style plots.
#' @inheritParams plot_marginal_fit
#' @param palette Optional named color overrides (`ok`, `flag`, `expected`).
#' @param label_angle X-axis label angle for bar-style plots.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, print the `ggplot` object.
#'
#' @details
#' Inter-rater agreement plots describe matched scores for a chosen rater
#' facet. The default matches Person and all other non-rater facets; custom
#' `context_facets` change the comparison unit. Inspect the saved settings
#' before interpreting agreement. Repeated ratings within a rater/context
#' cell are averaged as described in [interrater_agreement_table()].
#'
#' **Exact agreement** is the proportion of matched observations where
#' both raters assigned the same category score.  The **expected
#' agreement** line shows the proportion expected under the fitted model,
#' averaging products of category probabilities over matched rating contexts.
#' It is a model-based baseline, not a chance-corrected agreement coefficient.
#'
#' **Pairwise correlation** is the Pearson correlation between scores
#' assigned by each rater pair on matched observations.
#'
#' The **difference plot** describes directional score differences
#' (mean signed difference on x-axis: positive = Rater 1 assigned higher scores)
#' and total inconsistency (mean absolute difference on y-axis).  Points
#' near the origin indicate both small mean differences and low inconsistency.
#'
#' The `context_facets` parameter specifies which facets define "the
#' same rating target" (e.g., Criterion).  When `NULL`, all non-rater
#' facets are used as context.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"exact"` (default)}{Bar chart of exact agreement proportion by
#'     rater pair.  Expected agreement overlaid as connected circles.
#'     Horizontal reference line at the saved `exact_warn`. Bar colors follow
#'     the combined exact/correlation flag, not only the displayed metric.}
#'   \item{`"corr"`}{Bar chart of pairwise Pearson correlation by rater
#'     pair.  Reference line at `corr_warn`.  Ordered by correlation
#'     (lowest first).  Low correlations suggest inconsistent rank
#'     ordering of persons between raters.}
#'   \item{`"difference"`}{Scatter plot.  X-axis: mean signed score
#'     difference (Rater 1 \eqn{-} Rater 2); positive values indicate
#'     Rater 1 assigned higher scores. This observed-score contrast is distinct
#'     from the fitted rater-severity parameter. Y-axis: mean absolute difference
#'     (overall disagreement magnitude).  Points colored red when
#'     flagged.  Vertical reference at 0.}
#' }
#'
#' @section Interpreting output:
#' Colors retain the saved combined flag: either known cutoff crossing flags
#' a pair; an incomplete decision is neutral. These are descriptive review
#' rules, not automatic rater-quality or training-priority decisions.
#' On the difference plot, points far from the
#' origin along the x-axis indicate directional score differences; points high on the
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
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes. [as_ggplot()]
#'   preserves the selected metric, pair order, model-expected values,
#'   unavailable comparisons and saved review thresholds. Notes remain in
#'   `plot_data(p, "notes")`, outside the default figure. `top_n` limits the
#'   two bar views; the difference view uses all pairs in the input bundle.
#' @seealso [interrater_agreement_table()], [plot(x, type = "facets_chisq")][plot.mfrm_fit],
#'   [plot(x, type = "qc")][plot.mfrm_fit], [mfrmr_visual_diagnostics]
#' @examples
#' # Long-running workflow; run explicitly when needed.
#' # example("plot_interrater_agreement", run.dontrun = TRUE)
#' \dontrun{
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Compare observed exact agreement with its model-expected baseline
#' plot(fit, type = "agreement", rater_facet = "Rater")
#' # Bars show observed agreement; connected circles show model-expected agreement
#'
#' # Optional: compare the direction and magnitude of observed-score differences
#' plot(fit, type = "agreement", rater_facet = "Rater", metric = "difference")
#' # Positive horizontal values mean Rater1 assigned higher scores than Rater2
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
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
                                      draw = TRUE,
                                      title = NULL) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  main <- .mfrm_plot_title_alias(main, title, missing(main), missing(title))
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
  if (!inherits(x, "mfrm_fit")) {
    saved_exact <- bundle$settings$exact_warn %||% exact_warn
    saved_corr <- bundle$settings$corr_warn %||% corr_warn
    if ((!missing(exact_warn) && !isTRUE(all.equal(exact_warn, saved_exact))) ||
        (!missing(corr_warn) && !isTRUE(all.equal(corr_warn, saved_corr)))) {
      stop("Saved agreement flags use the saved thresholds. Recreate the result with interrater_agreement_table() to change them.", call. = FALSE)
    }
    exact_warn <- saved_exact
    corr_warn <- saved_corr
  }

  tbl <- as.data.frame(bundle$pairs, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) stop("No inter-rater pair rows are available.")
  if (!all(c("Rater1", "Rater2", "Exact", "Corr", "MeanDiff", "MAD") %in% names(tbl))) {
    stop("Inter-rater table does not include required columns.")
  }

  order_value <- if (plot_type == "corr") tbl$Corr else tbl$Exact
  ord_exact <- order(order_value, na.last = TRUE)
  use <- ord_exact[seq_len(min(length(ord_exact), top_n))]
  sub <- tbl[use, , drop = FALSE]
  labels <- truncate_axis_label(paste0(sub$Rater1, " | ", sub$Rater2), width = 28L)
  cols <- if ("Flag" %in% names(sub)) ifelse(is.na(sub$Flag), style$neutral, ifelse(sub$Flag, pal["flag"], pal["ok"])) else pal["ok"]
  plot_title <- switch(
    plot_type,
    exact = "Inter-rater exact agreement",
    corr = "Inter-rater correlation",
    difference = "Inter-rater difference profile"
  )
  if (!is.null(main)) plot_title <- as.character(main[1])
  plot_subtitle <- paste0("Rater facet: ", as.character(bundle$settings$rater_facet %||% rater_facet %||% "auto"))
  available_n <- sum(is.finite(if (plot_type == "corr") tbl$Corr else if (plot_type == "difference") tbl$MeanDiff else tbl$Exact))
  plot_subtitle <- paste0(plot_subtitle, "; ", available_n, " / ", nrow(tbl), " pairs available; remaining pairs are unassessed.")
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

  out <- new_mfrm_plot_data(
    "interrater",
    list(
      plot = plot_type,
      pairs = tbl,
      table = if (plot_type == "difference") tbl else sub,
      notes = bundle$notes,
      summary = bundle$summary,
      settings = bundle$settings,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = plot_legend,
      reference_lines = plot_reference,
      preset = style$name,
      palette = pal,
      label_angle = label_angle
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Plot facet variability diagnostics with ggplot2
#'
#' @param x Output from [fit_mfrm()] or [facets_chisq_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param fixed_p_max Warning cutoff for fixed-effect chi-square p-values.
#' @param random_p_max Warning cutoff for random-effect chi-square p-values.
#' @param plot_type `"fixed"`, `"random"`, or `"variance"`.
#' @inheritParams plot_marginal_fit
#' @param palette Optional named color overrides (`fixed_ok`, `fixed_flag`,
#' `random_ok`, `random_flag`, `variance`).
#' @param label_angle X-axis label angle for bar-style plots.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `TRUE`, print the `ggplot` object.
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
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes.
#' @seealso [facets_chisq_table()], [plot(x, type = "agreement")][plot.mfrm_fit], [plot(x, type = "qc")][plot.mfrm_fit]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_facets_chisq", run.dontrun = TRUE)
#' \dontrun{
#' # Saved synthetic JML/RSM analysis of example_core.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#' p <- plot(fit, type = "facets_chisq", draw = FALSE)
#' if (interactive()) {
#'   plot(fit, type = "facets_chisq", draw = TRUE, view = "fixed",
#'     preset = "publication", main = "Facet Chi-square (Customized)",
#'     palette = c(fixed_ok = "#2b8cbe", fixed_flag = "#cb181d"),
#'     label_angle = 45)
#' }
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_facets_chisq <- function(x,
                              diagnostics = NULL,
                              fixed_p_max = 0.05,
                              random_p_max = 0.05,
                              plot_type = c("fixed", "random", "variance"),
                              main = NULL,
                              palette = NULL,
                              label_angle = 45,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              draw = TRUE,
                              title = NULL) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  main <- .mfrm_plot_title_alias(main, title, missing(main), missing(title))
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
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Plot a QC dashboard with ggplot2
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
#' @param draw If `TRUE`, print the `ggplot` object.
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
#' For `GPCM`, the dashboard now reuses the residual-based
#' diagnostics stack and marks the fair-average panel unavailable rather
#' than silently reusing the Rasch-only compatibility calculation.
#'
#' @section Plot types:
#' This function draws a fixed 3\eqn{\times}3 panel grid (no `plot_type`
#' argument).  For individual panel control, use the dedicated helpers:
#' [plot(x, type = "unexpected")][plot.mfrm_fit], [plot(x, type = "fair_average")][plot.mfrm_fit], [plot(x, type = "displacement")][plot.mfrm_fit],
#' [plot(x, type = "agreement")][plot.mfrm_fit], [plot(x, type = "facets_chisq")][plot.mfrm_fit].
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
#' (`plot()`, `plot()`, `plot()`,
#' `plot()`) for detailed diagnosis.
#'
#' @section Typical workflow:
#' 1. Fit and diagnose model.
#' 2. Run `plot()` for one-page triage.
#' 3. Drill into flagged panels using dedicated functions.
#'
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes.
#' @seealso [plot(x, type = "unexpected")][plot.mfrm_fit], [plot(x, type = "fair_average")][plot.mfrm_fit], [plot(x, type = "displacement")][plot.mfrm_fit], [plot(x, type = "agreement")][plot.mfrm_fit], [plot(x, type = "facets_chisq")][plot.mfrm_fit], [build_visual_summaries()]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_qc_dashboard", run.dontrun = TRUE)
#' \dontrun{
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Use the diagnostics saved with this fit
#' diagnostics <- example_fit$diagnostics
#'
#' # Read the interpretation status before reviewing the quality-control (QC) panels
#' review <- summary(diagnostics)
#' review$decision
#'
#' # Draw the dashboard and save its data
#' qc <- plot(fit, type = "qc", diagnostics = diagnostics)
#'
#' # Inspect the counts behind the category panel
#' plot_data(qc, "category_stats")[, c("Category", "Count", "ExpectedCount")]
#' # Use focused plots such as plot(diagnostics, type = "marginal_fit") to investigate a panel
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
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
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
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
      status = "available_direct_only",
      direct_route = "fair_average_table(fit, diagnostics = diagnostics)",
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
  .mfrm_finalize_ggplot(out, draw = draw)
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
#' positioned at its measure estimate (x) and fit mean-square (y).
#' Bubble radius reflects approximate measurement precision or sample size.
#'
#' @param x Output from \code{\link{fit_mfrm}} or \code{\link{diagnose_mfrm}}.
#' @param diagnostics Optional output from \code{\link{diagnose_mfrm}} when
#'   \code{x} is an \code{mfrm_fit} object. If omitted, diagnostics are
#'   computed automatically.
#' @param fit_stat Fit statistic for the y-axis: \code{"Infit"} (default) or
#'   \code{"Outfit"}. Ignored when \code{view = "infit_outfit"} because
#'   that view always plots Infit on x and Outfit on y.
#' @param view Layout. \code{"measure"} (default, the historical
#'   mfrmr layout) plots Measure (logit) on x and the chosen
#'   \code{fit_stat} MnSq on y. \code{"infit_outfit"} plots Infit MnSq
#'   on x and Outfit MnSq on y, matching the Winsteps Table 30.2
#'   "Most-misfitting Persons / Items" scatter that many MFRM and
#'   Rasch users expect, and defaults \code{bubble_size = "N"}.
#' @param bubble_size Variable controlling bubble radius: \code{"SE"} (default
#'   for \code{view = "measure"}), \code{"N"} (observation count;
#'   default for \code{view = "infit_outfit"}), or \code{"equal"}
#'   (uniform size).
#' @param facets Character vector of facets to include. \code{NULL} (default)
#'   includes every row allowed by \code{include_person}.
#' @param include_person If \code{TRUE}, person measures may be included in
#'   the chart (and in \code{facets} filtering). The default is \code{FALSE}
#'   because person rows commonly overwhelm facet-level patterns.
#' @param fit_range Numeric length-2 vector defining the heuristic fit-review band
#'   shown as a shaded region (default \code{c(0.5, 1.5)}).
#' @param top_n Maximum number of elements to plot (default 60).
#' @inheritParams plot_marginal_fit
#' @param palette Optional named colour vector keyed by facet name.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If \code{TRUE} (default), print the `ggplot` object.
#'
#' @details
#' When \code{x} is an \code{mfrm_fit} object and \code{diagnostics} is omitted,
#' the function computes diagnostics internally via \code{\link{diagnose_mfrm}()}.
#' For repeated plotting in the same workflow, passing a precomputed diagnostics
#' object avoids that extra work.
#'
#' The x-axis shows element measure estimates on the **logit** scale
#' (one logit = one unit change in log-odds of responding in a higher
#' category).  The y-axis shows the selected fit mean-square statistic.
#' A shaded band between \code{fit_range[1]} and \code{fit_range[2]}
#' highlights a common heuristic review range.
#'
#' `preset = "monochrome"` uses gray facet colours unless overridden with
#' `palette`. [as_ggplot()] retains the saved radius ratios and facet colours,
#' but uses physical point sizes rather than base graphics' plot units. It
#' also retains the reference lines; this is not a pixel-identical rendering.
#'
#' Bubble radius options:
#' \itemize{
#'   \item \code{"SE"}: inversely proportional to standard error---larger
#'     circles indicate more precisely estimated elements under the current
#'     SE approximation.
#'   \item \code{"N"}: radius proportional to the square root of
#'     observation count, so circle area is proportional to count---larger
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
#' \item Call \code{plot(fit, type = "bubble", diagnostics = diag)} to inspect the most extreme elements.
#' }
#'
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes.
#' @seealso \code{\link{diagnose_mfrm}}, \code{\link{plot_unexpected}},
#'   \code{\link{plot_fair_average}}
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_bubble", run.dontrun = TRUE)
#' \dontrun{
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Use the diagnostics saved with this fit
#' diagnostics <- example_fit$diagnostics
#'
#' # Compare facet estimates (horizontal axis) with Infit (vertical axis)
#' plot(fit, type = "bubble", diagnostics = diagnostics)
#' # Above the review band: more response variation than expected; below: less
#' # By default, larger bubbles indicate greater precision, not greater misfit
#'
#' # Optional: compare Infit (horizontal) and Outfit (vertical) directly
#' plot(fit, type = "bubble", diagnostics = diagnostics, view = "infit_outfit")
#' # Here bubble size represents observation count; bands are review aids
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_bubble <- function(x,
                        diagnostics = NULL,
                        fit_stat = c("Infit", "Outfit"),
                        view = c("measure", "infit_outfit"),
                        bubble_size = NULL,
                        facets = NULL,
                        include_person = FALSE,
                        fit_range = c(0.5, 1.5),
                        top_n = 60,
                        main = NULL,
                        palette = NULL,
                        draw = TRUE,
                        preset = c("standard", "publication", "compact", "monochrome"),
                        marginal = c("auto", "histogram", "none"),
                        title = NULL) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  marginal <- .mfrmr_resolve_marginal_arg(marginal)
  main <- .mfrm_plot_title_alias(main, title, missing(main), missing(title))
  fit_stat <- match.arg(fit_stat)
  view <- match.arg(view)
  if (is.null(bubble_size)) {
    bubble_size <- if (identical(view, "infit_outfit")) "N" else "SE"
  }
  bubble_size <- match.arg(bubble_size, c("SE", "N", "equal"))
  if (!is.logical(include_person) || length(include_person) != 1L || is.na(include_person)) {
    stop("`include_person` must be TRUE or FALSE.", call. = FALSE)
  }
  top_n <- max(1L, as.integer(top_n))
  style <- resolve_plot_preset(preset)

  measures <- resolve_bubble_measures(x, diagnostics)
  if (!isTRUE(include_person)) {
    measures <- measures[measures$Facet != "Person", , drop = FALSE]
  }
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
      valid_se <- is.finite(se_vals) & se_vals > 0
      fallback_se <- if (any(valid_se)) stats::median(se_vals[valid_se]) else 0.1
      se_vals[!valid_se] <- fallback_se
      precision <- 1 / pmax(se_vals, sqrt(.Machine$double.eps))
      precision / max(precision, na.rm = TRUE) * 0.15
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
  if (identical(style$name, "monochrome")) {
    default_cols <- .plot_series_colors(unique_facets, "monochrome")
  }
  cols <- resolve_palette(palette = palette, defaults = default_cols)
  point_cols <- cols[as.character(measures$Facet)]

  title_payload <- if (is.null(main)) {
    if (identical(view, "infit_outfit")) {
      "Infit-Outfit MnSq scatter (Winsteps Table 30 layout)"
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
      include_person = isTRUE(include_person),
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
      marginal = marginal,
      preset = style$name
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}

# ---- CSV Export ----

#' Export fitted MFRM tables to CSV files
#'
#' Writes tidy CSV files suitable for import into spreadsheet software or
#' further analysis in other tools.
#' This is the CSV-only route from a fitted model. It does not run diagnostics,
#' save a complete R object, or create a replay script. Use
#' [export_mfrm_results()] to archive an existing results object and reload it
#' without refitting, or [export_mfrm_bundle()] for a fit-level collection with
#' an optional refitting script. In 0.2.4 this replaces `export_mfrm()`;
#' arguments, CSV filenames and the returned file table are unchanged. Enriched
#' facet CSVs now also retain the diagnostic availability and uncertainty fields.
#'
#' @param fit Output from \code{\link{fit_mfrm}}.
#' @param diagnostics Optional output from \code{\link{diagnose_mfrm}}.
#'   When provided, enriches facet estimates with SE, fit statistics, their
#'   calculation/availability fields and reasons, and
#'   writes the full measures table. Must belong to the same \code{fit};
#'   mismatched or outdated diagnostics are rejected before creating files.
#' @param output_dir Directory for CSV files. Created if it does not exist.
#' @param prefix Filename prefix (default \code{"mfrm"}).
#' @param tables Character vector of tables to export. Any subset of
#'   \code{"person"}, \code{"facets"}, \code{"summary"}, \code{"steps"},
#'   \code{"measures"}. Default exports all available tables.
#' @param overwrite If \code{FALSE} (default), refuse to overwrite existing
#'   files.
#' @param acknowledge_sensitive Logical; set to \code{TRUE} only after
#'   acknowledging that these tables can contain direct person identifiers,
#'   person-level estimates, and original facet labels. This suppresses the
#'   privacy warning; it does not deidentify any file.
#'
#' @section Exported files:
#' \describe{
#'   \item{\code{{prefix}_person_estimates.csv}}{Person ID, Estimate, SD.}
#'   \item{\code{{prefix}_facet_estimates.csv}}{Facet, Level, Estimate,
#'     and optionally SE, Infit, Outfit, PTMEA and their qualification fields
#'     when diagnostics are supplied.}
#'   \item{\code{{prefix}_fit_summary.csv}}{One-row model summary.}
#'   \item{\code{{prefix}_step_parameters.csv}}{Step/threshold parameters.}
#'   \item{\code{{prefix}_measures.csv}}{Full measures table (requires
#'     diagnostics).}
#' }
#'
#' @section Interpreting output:
#' The returned data.frame tells you exactly which files were written and where.
#' This is convenient for scripted pipelines where the output directory is created
#' on the fly. The files are analysis tables, not a deidentified sharing
#' package; review each file under the applicable data-handling policy before
#' sharing it.
#' In enriched facet tables, read `SE_Method`, `SEUse`, `CIUse`,
#' `InferenceReady` and `SupportsFormalInference` with the SE. Read `FitStatus`
#' and `FitReason` with Infit/Outfit. A finite value does not imply valid formal
#' inference. These columns preserve the matching diagnostics' qualifications;
#' the export does not compute a new SE or confidence interval. Missing fields
#' in an older diagnostic result are not filled with assumed approval.
#'
#' @section Typical workflow:
#' \enumerate{
#' \item Fit a model with \code{\link{fit_mfrm}()}.
#' \item Optionally compute diagnostics with \code{\link{diagnose_mfrm}()} when you want enriched facet or measures exports.
#' \item Call \code{export_mfrm_tables(...)} and inspect the returned \code{Path} column.
#' }
#'
#' @return Invisibly, a data.frame listing written files, their paths, and
#'   explicit privacy/data-handling metadata. `Deidentified` and
#'   `ShareableWithoutReview` are always `FALSE`.
#' @seealso \code{\link{fit_mfrm}}, \code{\link{diagnose_mfrm}},
#'   \code{\link{as.data.frame.mfrm_fit}}, [export_mfrm_results()],
#'   [export_mfrm_bundle()], [mfrmr_compatibility_layer]
#' @aliases export_mfrm
#' @examples
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Use the diagnostics saved with this fit
#' diagnostics <- example_fit$diagnostics
#'
#' # Use a new temporary folder for this example; choose a permanent one for your work
#' output_dir <- tempfile("mfrmr-tables-")
#' files <- export_mfrm_tables(
#'   fit,
#'   diagnostics = diagnostics,
#'   output_dir = output_dir,
#'   acknowledge_sensitive = TRUE # Synthetic data; exported tables retain person IDs
#' )
#'
#' # Preview filenames; full paths remain in files$Path
#' data.frame(Table = files$Table, File = basename(files$Path))
#' # Open a path from files$Path in a spreadsheet app or with read.csv()
#' @export
export_mfrm_tables <- function(fit,
                        diagnostics = NULL,
                        output_dir = ".",
                        prefix = "mfrm",
                        tables = c("person", "facets", "summary", "steps", "measures"),
                        overwrite = FALSE,
                        acknowledge_sensitive = FALSE) {
  stop_if_product_slopes(fit, "export_mfrm_tables()")

  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().")
  }
  if (!is.null(diagnostics)) {
    mfrm_results_validate_diagnostics_identity(fit, diagnostics,
                                               helper = "export_mfrm_tables()")
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
  acknowledge_sensitive <- isTRUE(acknowledge_sensitive)
  output_dir <- as.character(output_dir[1])

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(output_dir)) {
    stop("Could not create output directory: ", output_dir)
  }

  privacy_notice <- paste0(
    "These CSV files are analysis tables, not a deidentified or automatically ",
    "shareable package. They can contain direct person identifiers, person-level ",
    "estimates, and original facet labels. Review and transform every file under ",
    "the applicable data-handling policy before sharing it."
  )
  if (!acknowledge_sensitive) {
    warning(
      privacy_notice,
      " Set `acknowledge_sensitive = TRUE` only to acknowledge this risk; ",
      "that setting does not deidentify the export.",
      call. = FALSE
    )
  }

  written <- data.frame(
    Table = character(0),
    Path = character(0),
    DataHandling = character(0),
    PrivacyClass = character(0),
    Deidentified = logical(0),
    ShareableWithoutReview = logical(0),
    SensitiveDataAcknowledged = logical(0),
    stringsAsFactors = FALSE
  )

  write_one <- function(df, filename, table_name) {
    path <- file.path(output_dir, filename)
    if (file.exists(path) && !overwrite) {
      stop("File already exists: ", path, ". Set overwrite = TRUE to replace.")
    }
    utils::write.csv(df, file = path, row.names = FALSE, na = "")
    data_handling <- if (table_name %in% c("person", "measures")) {
      "may_contain_person_level_data"
    } else if (identical(table_name, "facets")) {
      "may_contain_original_facet_labels"
    } else {
      "review_before_sharing"
    }
    written <<- rbind(written, data.frame(
      Table = table_name,
      Path = normalizePath(path, winslash = "/", mustWork = FALSE),
      DataHandling = data_handling,
      PrivacyClass = "analysis_archive",
      Deidentified = FALSE,
      ShareableWithoutReview = FALSE,
      SensitiveDataAcknowledged = acknowledge_sensitive,
      stringsAsFactors = FALSE
    ))
  }

  if ("person" %in% tables) {
    person_df <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
    write_one(person_df, paste0(prefix, "_person_estimates.csv"), "person")
  }

  if ("facets" %in% tables) {
    facet_df <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
    if (!is.null(diagnostics) && !is.null(diagnostics$measures)) {
      enrich_cols <- intersect(c("SE", "Infit", "Outfit", "PTMEA", "N",
        "ParameterStatus", "BoundaryDirection", "ReasonCodes", "EstimateUse",
        "SourceFitReadiness", "SourceInferenceReady", "SE_Method", "Converged",
        "InferenceReady", "ConvergenceSeverity", "PrecisionTier",
        "SupportsFormalInference", "SEUse", "CIBasis", "CIUse", "Fixed",
        "FitResponseRows", "FitAvailableRows", "FitUnavailableRows", "FitStatus", "FitReason"),
                               names(diagnostics$measures))
      if (length(enrich_cols) > 0) {
        enrich <- diagnostics$measures[diagnostics$measures$Facet != "Person",
                                       c("Facet", "Level", enrich_cols), drop = FALSE]
        enrich <- as.data.frame(enrich, stringsAsFactors = FALSE)
        enrich$Level <- as.character(enrich$Level)
        facet_df$Level <- as.character(facet_df$Level)
        key <- function(x) paste(x$Facet, x$Level, sep = "\r")
        facet_df[enrich_cols] <- enrich[match(key(facet_df), key(enrich)), enrich_cols, drop = FALSE]
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
#' tidy data.frame. Person rows retain their original identifiers; review or
#' transform them before writing the result outside a controlled analysis
#' environment.
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
#'   is populated for person rows from the extreme-score flag
#'   (\code{"Min"} / \code{"Max"} / \code{NA}); non-person
#'   facet rows carry \code{NA} in that column by design.
#'   Corrected-JML fits additionally retain estimator, correction order,
#'   point/covariance status, uncertainty target and structural \code{RootSE}
#'   columns. Person \code{RootSE} is missing; extreme Person flags are
#'   \code{"low"} / \code{"high"} / \code{"none"}. The \code{estimation_note}
#'   attribute explains the local-root uncertainty and remaining bias. Ordinary
#'   diagnostic attachments do not apply to this estimator; see the Corrected
#'   JML section of \code{\link{fit_mfrm}}.
#' @seealso \code{\link{fit_mfrm}}, \code{\link{export_mfrm_tables}}
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("as.data.frame.mfrm_fit", run.dontrun = TRUE)
#' \dontrun{
#' library(mfrmr)
#'
#' # Saved synthetic MML/RSM analysis of example_operational.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#'
#' # Extract estimates and select the rows to display
#' estimates <- as.data.frame(fit)
#' head(subset(estimates, Facet == "Person")) # First six persons
#' subset(estimates, Facet == "Rater")       # All raters
#' subset(estimates, Facet == "Criterion")   # All criteria
#' }
#' @export
as.data.frame.mfrm_fit <- function(x, row.names = NULL, optional = FALSE, ...) {
  if (mfrm_has_jml_adjustment(x)) {
    rlang::check_dots_empty()
    person <- x$facets$person
    person$Facet <- "Person"; person$Level <- person$Person
    person$Person <- person$SE <- NULL
    out <- as.data.frame(dplyr::bind_rows(person,x$facets$others),row.names=row.names,
      optional=optional)
    attr(out,"estimation_note") <- mfrm_jml_note()
    return(out)
  }
  # Carry forward the Extreme flag from build_person_table().
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
  if (mfrm_has_jml_adjustment(x)) {
    print(summary(x)); return(invisible(x))
  }
  if (is.list(x) && !is.null(x$summary) && nrow(x$summary) > 0) {
    ov <- round_numeric_df(as.data.frame(x$summary), digits = 3L)[1, , drop = FALSE]
    fit_summary <- tryCatch(summary(x), error = function(e) NULL)
    scale_contract <- tryCatch(
      mfrm_fit_scale_contract(x),
      error = function(e) tibble::tibble()
    )
    cat("mfrm_fit object\n")
    print_wrapped_line(sprintf(
      "Model: %s | Method: %s",
      ov$Model %||% NA_character_, ov$Method %||% NA_character_
    ))
    print_wrapped_line(sprintf(
      "N: %s | Persons: %s | Facets: %s | Categories: %s",
      ov$N %||% NA, ov$Persons %||% NA, ov$Facets %||% NA,
      ov$Categories %||% NA
    ))
    decision_available <- !is.null(fit_summary) &&
      nrow(fit_summary$decision %||% data.frame()) == 1L
    if (decision_available) {
      print_fit_decision_section(fit_summary$decision)
    }
    if (!is.null(fit_summary)) {
      print_wrapped_line(fit_summary$estimation_note %||% character(0))
      mml_contract_lines <- mfrm_mml_integration_console_lines(fit_summary)
      if (length(mml_contract_lines) > 0L) {
        print_wrapped_line(mml_contract_lines)
      }
    }
    if (nrow(scale_contract) > 0L) {
      population_sd <- as.numeric(scale_contract$PopulationSD[1])
      population_text <- if (is.finite(population_sd)) {
        paste0(" | Population SD: ", formatC(population_sd, digits = 3L, format = "fg"))
      } else {
        ""
      }
      print_wrapped_line(sprintf(
        "Scale: %s | Discrimination: %s%s",
        switch(as.character(scale_contract$CoordinateBasis[1]),
          joint_person_coordinate_scale = "jointly estimated Person measures",
          fixed_standard_normal = "fixed standard-normal population",
          estimated_population_scale = "estimated population",
          estimated_population_mean_fixed_sd = "estimated population mean, fixed SD",
          "see fitted scale settings"),
        if (identical(scale_contract$SlopeBasis[1], "owner_specific_product_discrimination"))
          "product of facet slopes; first family geometric mean 1, second family free" else
        if (identical(as.character(scale_contract$Model[1]), "GPCM"))
          "relative slopes with geometric mean 1" else "fixed at 1",
        population_text
      ))
      if (identical(as.character(scale_contract$Model[1]), "GPCM")) {
        print_wrapped_line(mfrm_gpcm_console_lines(scale_contract))
      }
    }
    ic_lines <- mfrm_ic_console_lines(x$summary, digits = 3L)
    if (length(ic_lines) > 0L) {
      print_wrapped_line(ic_lines)
    }
    if ("Converged" %in% names(ov) && "ConvergenceStatus" %in% names(ov)) {
      convergence <- mfrm_convergence_state(x)
      status_label <- switch(
        convergence$status,
        converged = "No further numerical review indicated",
        converged_gradient_review = "Terminal gradient needs review",
        reviewable_warning = "Optimizer warning needs review",
        iteration_limit = "Iteration limit reached",
        optimizer_warning = "Optimizer warning",
        unknown = "Status unavailable",
        convergence$status
      )
      print_wrapped_line(sprintf(
        "Optimizer returned code 0: %s | Convergence review: %s",
        ifelse(convergence$code_converged, "Yes", "No"),
        status_label
      ))
      if (!decision_available) {
        print_wrapped_line("Formal inference: not established; the interpretation decision is unavailable.")
      }
    }
    if (isTRUE(x$config$attached_diagnostics)) {
      attached_cols <- as.character(x$config$attached_diagnostics_cols %||% character(0))
      if (length(attached_cols) > 0L) {
        print_wrapped_line(sprintf(
          "Attached diagnostics: %s",
          paste(attached_cols, collapse = ", ")
        ))
      } else {
        cat("  Attached diagnostics: yes (per-element fit columns merged)\n")
      }
    }
    if (!decision_available) {
      if (!is.null(fit_summary) &&
          nrow(fit_summary$status %||% data.frame()) > 0) {
        first_status <- fit_summary$status[1, , drop = FALSE]
        print_wrapped_line(sprintf(
          "Summary status: %s",
          first_status$Value[1] %||% NA_character_
        ))
      }
      if (!is.null(fit_summary) &&
          length(fit_summary$key_warnings) > 0 &&
          !summary_lines_are_default(
            fit_summary$key_warnings,
            "No immediate warnings from fit-level summary checks."
          )) {
        print_wrapped_line(paste0(
          "Key warning: ", fit_summary$key_warnings[1]
        ))
      }
      if (!is.null(fit_summary) && length(fit_summary$next_actions) > 0) {
        print_wrapped_line(paste0("Next: ", fit_summary$next_actions[1]))
      } else {
        cat("  Next: use `summary(x)` for details.\n")
      }
    }
    cat("  Use `summary(x)` for the full fit summary.\n")
  } else {
    cat("mfrm_fit object (empty summary)\n")
  }
  invisible(x)
}
