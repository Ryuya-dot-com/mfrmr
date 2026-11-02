#' @rdname mfrm_response_diagnostics
#' @details `plot()` method: Plot descriptive response residual summaries
#'
#' Compare residual summaries across selected groups without reference cutoffs.
#' @param x Saved [mfrm_response_diagnostics()] output.
#'
#' Also for `summary()`: A saved response-diagnostics result.
#' @param facet One recorded grouping column; default is the first.
#' @param style `"paired"` connects each group's Infit and Outfit on a common
#'   axis. `"scatter"` plots Infit against Outfit; labels identify groups.
#' @inheritParams plot.mfrm_extended_comparison
#' @param palette `"accessible"` uses blue circles and orange triangles;
#'   `"mono"` retains distinct symbols in black. No red/green warning scale.
#' @param show_labels Show group labels. Unavailable groups keep their labels
#'   in the paired view; both views retain all rows in [plot_data()].
#' @param marginal Marginal histogram display for `style = "scatter"`:
#'   `"auto"` (default; shown when at least 8 finite pairs exist), `"histogram"`,
#'   or `"none"`.
#' @return For `plot()`: Invisibly, a `ggplot` object; [plot_data()] extracts
#'   selected measures, display settings, notes and alternative text.
#' @details For `plot()`: The response probabilities integrate the latent effects conditional
#'   on the same observed responses and fixed calibration. These are descriptive
#'   summaries, not ordinary plug-in Infit/Outfit. Neither an expectation of
#'   one nor a universal acceptable range is established. No interval, warning
#'   region or statistical test is drawn. Hiding annotations changes only the
#'   display; [plot_data()] retains the probability definition and limitations.
#'   For corrected JML, probabilities instead condition on corrected calibration
#'   and reprofiled Person point estimates; no latent effects are integrated.
#'   The paired view displays each available index independently, so an
#'   available Infit is retained when zero conditional variance makes Outfit
#'   undefined. The scatter view requires both indices. The caption reports
#'   partial availability, and the saved table retains its reasons.
#' @export
plot.mfrm_response_diagnostics <- function(x, facet = NULL, style = c("paired", "scatter"),
    draw = TRUE, palette = c("accessible", "mono"), title = NULL, caption = NULL,
    show_title = FALSE, show_notes = FALSE, show_labels = TRUE, text_scale = 1,
    point_size = 2.5, marginal = c("auto", "histogram", "none"), ...) {
  rlang::check_dots_empty()
  style <- match.arg(style); palette <- match.arg(palette)
  marginal <- match.arg(marginal)
  for (key in c("draw", "show_title", "show_notes", "show_labels")) if (!is.logical(get(key)) || length(get(key)) != 1L || is.na(get(key))) stop("Display switches must be TRUE or FALSE.", call. = FALSE)
  for (key in c("title", "caption")) if (!is.null(get(key)) && (!is.character(get(key)) || length(get(key)) != 1L || is.na(get(key)))) stop("Titles/captions must be NULL or one string.", call. = FALSE)
  for (key in c("text_scale", "point_size")) if (!is.numeric(get(key)) || length(get(key)) != 1L || !is.finite(get(key)) || get(key) <= 0) stop("Text and point sizes must be positive finite numbers.", call. = FALSE)
  facet <- facet %||% x$settings$group_by[1L]
  if (!is.character(facet) || length(facet) != 1L || is.na(facet) || !facet %in% x$settings$group_by) stop("Choose one recorded grouping column.", call. = FALSE)
  tab <- x$measures[x$measures$Facet == facet, , drop = FALSE]
  available <- if (style=="paired") is.finite(tab$Infit) | is.finite(tab$Outfit) else
    is.finite(tab$Infit) & is.finite(tab$Outfit)
  limits <- c(0, max(c(.1, tab$Infit, tab$Outfit), na.rm = TRUE) * 1.15)
  note <- if (identical(x$settings$probability_method,"corrected_jml_plugin"))
    "Same-data conditional probabilities | calibration and Person profiles fixed | no reference cutoffs" else
    "Same-data posterior predictions | calibration fixed | descriptive only; no reference cutoffs"
  if (any(tab$Status=="partially_available",na.rm=TRUE)) note <- paste(note,
    "Zero-variance ratings prevent Outfit; defined Infit is retained.",sep="\n")
  count <- sprintf("%d of %d groups displayed; selected rows only.", sum(available), nrow(tab))
  if (any(xor(is.finite(tab$Infit),is.finite(tab$Outfit)))) count <- paste(count,
    sprintf("Infit available: %d; Outfit available: %d.",sum(is.finite(tab$Infit)),sum(is.finite(tab$Outfit))))
  payload <- list(table = tab, settings = x$settings,
    title = title %||% paste(x$settings$model, "residual summaries:", facet),
    caption = caption %||% paste(note, count, sep = "\n"),
    alt_text = paste("Descriptive Infit and Outfit by", facet, "in a", style, "view.", count, x$settings$target, x$settings$limitation),
    notes = data.frame(Note = c(note, count, x$settings$integration, x$settings$limitation)),
    display = list(style = style, palette = palette, show_title = show_title,
      show_notes = show_notes, show_labels = show_labels, text_scale = text_scale,
      point_size = point_size, limits = limits, marginal = marginal))
  out <- new_mfrm_plot_data("response_diagnostics", payload)
  p <- .mfrm_finalize_ggplot(out, draw = FALSE)
  attr(p, "mfrmr_alt_text") <- payload$alt_text
  if (isTRUE(draw)) .mfrm_draw_ggplot_clean(p)
  invisible(p)
}

.mfrmr_gg_response_diagnostics <- function(payload) {
  opt <- payload$display; tab <- payload$table
  tab$.Row <- rev(seq_len(nrow(tab)))
  available <- is.finite(tab$Infit) & is.finite(tab$Outfit); used <- tab[available, , drop = FALSE]
  colours <- if (opt$palette == "mono") c("#222222", "#222222") else c("#0072B2", "#9C4700")
  p <- ggplot2::ggplot(tab, ggplot2::aes(x = .data$Infit, y = .data$.Row))
  if (opt$style == "paired") {
    p <- p + ggplot2::geom_segment(data = used,
      ggplot2::aes(xend = .data$Outfit, yend = .data$.Row), colour = "grey65") +
      ggplot2::geom_point(data = tab[is.finite(tab$Infit),,drop=FALSE], ggplot2::aes(shape = "Infit", colour = "Infit"), size = opt$point_size) +
      ggplot2::geom_point(data = tab[is.finite(tab$Outfit),,drop=FALSE], ggplot2::aes(x = .data$Outfit, shape = "Outfit", colour = "Outfit"), size = opt$point_size) +
      ggplot2::scale_shape_manual(name = NULL, values = c(Infit = 16, Outfit = 17)) +
      ggplot2::scale_colour_manual(name = NULL, values = stats::setNames(colours, c("Infit", "Outfit"))) +
      ggplot2::scale_y_continuous(breaks = tab$.Row,
        labels = if (opt$show_labels) tab$Level else rep("", nrow(tab)), limits = c(.5, nrow(tab) + .5))
  } else {
    p <- p + ggplot2::geom_point(data = used, ggplot2::aes(y = .data$Outfit),
      colour = colours[1], size = opt$point_size) +
      ggplot2::scale_y_continuous(limits = opt$limits)
    if (opt$show_labels) p <- p + ggplot2::geom_text(data = used,
      ggplot2::aes(y = .data$Outfit, label = .data$Level), vjust = -1, size = 3 * opt$text_scale)
  }
  shown <- if (opt$style=="paired") is.finite(tab$Infit) | is.finite(tab$Outfit) else available
  if (!any(shown)) p <- p + ggplot2::annotate("text", x = mean(opt$limits),
    y = if (opt$style == "paired") (nrow(tab) + 1) / 2 else mean(opt$limits), label = "No available summaries")
  p <- p + ggplot2::scale_x_continuous(limits = opt$limits) +
    .mfrmr_gg_theme_styled(if (opt$palette == "mono") "monochrome" else "standard", base_size = 11 * opt$text_scale) +
    ggplot2::theme(legend.position = "bottom")
  p <- .mfrmr_gg_labs(p, payload, x = if (opt$style == "paired") "Descriptive mean square" else "Descriptive Infit",
    y = if (opt$style == "paired") NULL else "Descriptive Outfit") + ggplot2::labs(alt = payload$alt_text)
  if (opt$style != "paired") {
    p <- .mfrmr_attach_marginal_histograms(
      p,
      x = used$Infit,
      y = used$Outfit,
      marginal = opt$marginal %||% "auto",
      preset = if (opt$palette == "mono") "monochrome" else "standard"
    )
  }
  attr(p, "mfrmr_alt_text") <- payload$alt_text
  p
}
