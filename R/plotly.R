.mfrm_interactive_types <- c("wright", "category_curves", "steps", "raters", "pathway", "fit_sensitivity")

.mfrm_plotly <- function(p, type) {
  if (!type %in% .mfrm_interactive_types)
    stop("Interactive plots support: ", paste(.mfrm_interactive_types, collapse = ", "), ".", call. = FALSE)
  if (!requireNamespace("plotly", quietly = TRUE))
    stop("Install the optional 'plotly' package for interactive plots.", call. = FALSE)
  notes <- attr(p, "mfrm_notes")
  # Explicit groups keep row-specific hover labels from splitting connected lines.
  for (i in seq_along(p$layers)) {
    layer <- p$layers[[i]]
    d <- if (is.data.frame(layer$data)) layer$data else p$data
    if (!is.data.frame(d) || !nrow(d)) next
    fields <- if (inherits(layer$geom, "GeomRect")) {
      c("Lower", "Upper", "Count")
    } else if (inherits(layer$geom, "GeomText") && "Mark" %in% names(d)) {
      c("Lower", "Upper", "Count")
    } else if (inherits(layer$geom, "GeomText") && "FairAverage" %in% names(d)) {
      c("FairAverage", "Logit", "Reference")
    } else if (inherits(layer$geom, "GeomText") && "LabelY" %in% names(d)) {
      c("Panel", "Element", "Logit")
    } else if (inherits(layer$geom, "GeomPolygon")) {
      c("Logit", "Density")
    } else if (inherits(layer$geom, c("GeomPoint", "GeomLine", "GeomStep"))) {
      intersect(c("Panel", "Element", "Logit", "ScaleGroup", "RatingContext", "LinearMeasure", "theta",
        "Category", "Probability", "Facet", "Level", "Estimate", "FitBasis", "Statistic", "FitMnSq",
        "PlotInfit", "FitZSTD", "DiagnosticFlag", "FitBand", "HalfWidth", "RuleDirection", "FlaggedCount",
        "TotalElements", "UnavailableMnSqCount", "UnresolvedZSTDCount"), names(d))
    }
    fields <- intersect(fields, names(d))
    if (!length(fields)) next
    text <- lapply(fields, function(f) {
      v <- d[[f]]
      if (is.numeric(v)) v <- format(signif(v, 5), trim = TRUE)
      label <- switch(f, PlotInfit = "Infit MnSq", FitMnSq = "MnSq", FitZSTD = "ZSTD",
        theta = "Person ability", FairAverage = "Fair average", Lower = "Lower logit", Upper = "Upper logit",
        gsub("([a-z])([A-Z])", "\\1 \\2", f))
      paste0(label, ": ", .tidymfrm_escape_html(as.character(v)))
    })
    d$.hover <- do.call(paste, c(text, sep = "<br>"))
    groups <- intersect(c("Category", "Panel", "RuleDirection", "FitBasis", "Facet", "Statistic"), names(d))
    d$.hover_group <- if (length(groups)) interaction(d[groups], drop = TRUE) else 1L
    mapping <- layer$mapping
    mapping$text <- ggplot2::aes(text = .data$.hover)$text
    if (inherits(layer$geom, c("GeomLine", "GeomStep", "GeomPolygon")))
      mapping$group <- ggplot2::aes(group = .data$.hover_group)$group
    if (inherits(layer$geom, "GeomRect"))
      mapping$group <- ggplot2::aes(group = .data$Lower)$group
    layer$mapping <- mapping
    layer$data <- d
  }
  w <- plotly::ggplotly(p, tooltip = "text")
  if (type == "wright") {
    # ggplotly omits geom_text hjust; keep the frequency symbols to the left of the ruler.
    for (i in seq_along(w$x$data)) {
      tr <- w$x$data[[i]]
      if (identical(tr$mode, "text") && any(startsWith(as.character(tr$hovertext), "Lower logit: ")))
        w$x$data[[i]]$textposition <- "middle left"
      if (identical(tr$mode, "text") && any(grepl("^(Fair average|Panel): ", tr$hovertext)))
        w$x$data[[i]]$textposition <- "middle right"
    }
  }
  if (length(notes))
    w <- htmlwidgets::appendContent(w, htmltools::tags$ul(lapply(notes, htmltools::tags$li)))
  attr(w, "mfrm_fair_average") <- attr(p, "mfrm_fair_average")
  attr(w, "mfrm_notes") <- notes
  w
}
