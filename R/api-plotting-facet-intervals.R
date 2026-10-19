#' Plot fixed-facet interval methods
#'
#' @param x Output from [mfrm_facet_intervals()].
#' @param comparison Logical. With a sandwich result, also show its ordinary
#'   model-based interval. Both intervals use the same point estimate.
#' @param draw Logical; `FALSE` returns exact plotted data without opening a device.
#' @param preset A package plot preset, for example `"standard"` or `"monochrome"`.
#' @param title,subtitle,caption Optional returned text; `NULL` omits it.
#'   Defaults describe the facet, exact confidence level, method and
#'   fixed/unavailable symbols. This text is not drawn; use
#'   `plot_data(p, "notes")` and `plot_data(p, "title")` to retrieve it.
#' @param reference Optional finite vertical reference; default zero. Use
#'   `NULL` to omit it. This is not a rater-quality threshold.
#' @param show_legend Logical; show the method legend (default `TRUE`).
#' @param ... Unused.
#' @return Invisibly, an `mfrm_plot_data` object retaining the `table`, contrast
#'   coefficients, settings and labels. Use [plot_data()] for custom graphics;
#'   [as_ggplot()] returns a customizable ggplot with the same saved values.
#' @details Fixed targets use open diamonds without inferential intervals.
#'   Unavailable selected intervals use crosses; an ordinary comparison interval
#'   does not substitute for a missing sandwich interval. The zero line is a
#'   reference, not a threshold of practical importance or a rater-quality rule.
#'   No fit or covariance is recalculated. Target order is preserved.
#'   Weak-information cautions remain in the returned data and appear in the
#'   default subtitle. Custom or omitted subtitles change display only.
#'   For experimental two-family GPCM locations, the axis uses fixed-N(0,1)
#'   ability units and the default subtitle states the location reference and
#'   unqualified coverage, with a deficient Person-score rank caution when
#'   applicable. These are not uniform expected-rating differences.
#'   Standardized contrast axes use population SD units; returned notes identify
#'   whether SD uncertainty is estimated or the known SD is one. Reviewed
#'   interaction contrasts retain group direction, panel weights and scale in
#'   their source result; returned labels distinguish them from facet locations.
#'   Native CML intervals are labeled conditional information. Their returned
#'   notes describe asymptotic validity without implying weak information or
#'   an estimated ability population SD.
#'   When a comparison has no estimate, its row is labeled "not estimated"
#'   and has no point or interval. An empty display range is only an axis
#'   placeholder; it does not assign a value to unavailable targets.
#' @inheritSection mfrmr_visual_diagnostics Session plot defaults
#' @export
plot.mfrm_facet_intervals <- function(x, comparison = TRUE, draw = TRUE,
                                      preset = "standard",
    title = paste(x$settings$facet, "estimates and contrasts"),
    subtitle = paste0(format(100 * x$settings$level, trim = TRUE),
      "% pointwise normal intervals | ",
      if (x$settings$method == "sandwich") paste0("Sandwich | ", x$settings$clusters,
        " independent clusters assumed") else if (
          identical(x$settings$procedure, "cml_conditional_information"))
            "Conditional information" else "Observed information"),
    caption = if (any(!is.finite(x$table$Estimate)))
      paste0("Not estimated: no point or interval | ",
        "Crosses: estimated points with unavailable intervals") else
      if (any(x$table$Status != "available"))
        "Open diamonds: fixed targets | Crosses: unavailable selected intervals" else NULL,
    reference = 0, show_legend = TRUE, ...) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  rlang::check_dots_empty()
  default_subtitle <- missing(subtitle)
  native <- identical(x$settings$procedure, "mml_native_location_model_v1")
  interaction <- !is.null(x$comparison_review)
  standardized <- identical(x$settings$scale, "standardized_population_sd")
  conditional <- identical(x$settings$procedure, "cml_conditional_information")
  if (default_subtitle && length(x$cautions)) subtitle <- paste(subtitle,
    if (standardized) "Population-SD-standardized contrasts; coverage unqualified." else
    if (conditional) "Conditional likelihood; asymptotic intervals, no population SD estimated." else
    if (isTRUE(x$settings$two_family)) "Experimental two-family locations; coverage unqualified." else
      if (interaction) "Model-based interaction contrasts; coverage unqualified." else
      if (native) "Experimental native locations; coverage unqualified." else
      "Weak information: review interval reliability.", sep = "\n")
  if (default_subtitle && isTRUE(x$settings$two_family) && !standardized) subtitle <- paste(subtitle,
    if (x$settings$location_reference == "sum_to_zero_across_levels")
      "Locations sum to zero across this family's levels." else
      "Uncentered locations on the fixed N(0,1) ability scale.", sep = "\n")
  if (default_subtitle && isTRUE(x$settings$two_family) &&
      isTRUE(x$numerical_checks$ScoreRankDeficient)) subtitle <- paste(subtitle,
    "Deficient Person-score rank; model-based approximation.", sep = "\n")
  if (default_subtitle && native && !standardized) subtitle <- paste(subtitle,
    "Centered locations in native ability units; not divided by population SD.", sep = "\n")
  if (default_subtitle && interaction) subtitle <- paste(subtitle,
    "Facet-by-origin interaction differences with the declared group order and panel weights.", sep = "\n")
  if (default_subtitle && standardized) subtitle <- paste(subtitle,
    if (isTRUE(x$settings$population_sd_estimated))
      "Full joint delta method includes estimated population SD uncertainty." else
      "Known population SD = 1; native and standardized contrasts coincide.", sep = "\n")
  if (any(!vapply(list(comparison, draw, show_legend), function(a)
      is.logical(a) && length(a) == 1L && !is.na(a), logical(1)))) {
    stop("`comparison`, `draw` and `show_legend` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!all(vapply(list(title, subtitle, caption), function(a)
      is.null(a) || (is.character(a) && length(a) == 1L && !is.na(a)), logical(1)))) {
    stop("Plot text must be NULL or one nonmissing character string.", call. = FALSE)
  }
  if (!is.null(reference) && (!is.numeric(reference) || is.complex(reference) ||
      length(reference) != 1L || !is.finite(reference))) {
    stop("`reference` must be NULL or one finite number.", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  tab <- x$table
  labels <- ifelse(is.finite(tab$Estimate), tab$Target, paste0(tab$Target, " (not estimated)"))
  show_model <- comparison && x$settings$method == "sandwich"
  selected_label <- if (conditional) "Conditional information" else
    if (x$settings$method == "sandwich") "Sandwich" else "Observed information"
  out <- new_mfrm_plot_data("facet_interval_methods", list(table = tab,
    contrasts = x$contrasts, settings = x$settings, comparison = show_model,
    target_labels = labels, comparison_review = x$comparison_review, fit_checks = x$fit_checks,
    cautions = x$cautions, information_review = x$information_review,
    title = title, subtitle = subtitle, caption = caption, reference = reference,
    show_legend = show_legend, xlab = if (standardized) "Contrast (population SD units)" else if (isTRUE(x$settings$two_family))
      "Location / contrast (fixed N(0,1) scale)" else if (interaction) "Interaction contrast (native ability units)" else if (native)
      "Location / contrast (native ability units)" else "Estimate (logits)", preset = style$name))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  old <- graphics::par(mar = c(4.5, 10, if (show_legend) 3 else 1.5, 2))
  on.exit(graphics::par(old), add = TRUE)
  y <- rev(seq_len(nrow(tab)))
  values <- c(reference, tab$Estimate, tab$Lower, tab$Upper,
    if (show_model) c(tab$ModelLower, tab$ModelUpper))
  limits <- if (any(is.finite(values))) range(values, finite = TRUE) else c(-1, 1)
  if (diff(limits) == 0) limits <- limits + c(-0.1, 0.1)
  graphics::plot(tab$Estimate, y, type = "n", xlim = limits,
    ylim = c(0.5, nrow(tab) + 0.5), yaxt = "n", xlab = out$data$xlab,
    ylab = "", main = "")
  if (!is.null(reference)) graphics::abline(v = reference, col = style$grid, lty = 2)
  offset <- if (show_model) .1 else 0
  if (show_model) {
    graphics::segments(tab$ModelLower, y - offset, tab$ModelUpper, y - offset,
      col = "grey50", lwd = 2)
    graphics::points(tab$Estimate, y - offset,
      pch = ifelse(tab$Status == "fixed", 5, 1), col = "grey50")
  }
  graphics::segments(tab$Lower, y + offset, tab$Upper, y + offset,
    col = style$accent_primary, lwd = 2)
  shape <- ifelse(tab$Status == "fixed", 5, ifelse(tab$Status == "available", 16, 4))
  graphics::points(tab$Estimate, y + offset, pch = shape, col = style$accent_primary)
  graphics::axis(2, at = y, labels = labels, las = 1)
  if (show_legend) graphics::legend(x = mean(graphics::par("usr")[1:2]),
    y = graphics::par("usr")[4] + .6 * graphics::strheight("M"),
    xjust = .5, yjust = 0, horiz = TRUE, xpd = NA,
    legend = c(selected_label, if (show_model) "Observed information"),
    pch = c(16, if (show_model) 1), col = c(style$accent_primary, if (show_model) "grey50"),
    bty = "n", cex = .8)
  invisible(out)
}

# Convert the draw-free payload, so base and ggplot routes share all selections.
mfrm_gg_facet_intervals <- function(x) {
  .require_mfrmr_ggplot2()
  d <- x$data; tab <- d$table
  style <- resolve_plot_preset(d$preset %||% "standard")
  selected <- if (identical(d$settings$procedure, "cml_conditional_information"))
    "Conditional information" else if (d$settings$method == "sandwich") "Sandwich" else "Observed information"
  offset <- if (isTRUE(d$comparison)) .1 else 0
  rows <- tab
  rows$Y <- rev(seq_len(nrow(tab))) + offset
  rows$Method <- selected
  rows$Display <- ifelse(tab$Status == "fixed", "Fixed",
    ifelse(tab$Status == "available", "Available", "Unavailable"))
  if (isTRUE(d$comparison)) {
    ordinary <- rows
    ordinary$Y <- ordinary$Y - 2 * offset
    ordinary$Method <- "Observed information"
    ordinary$Lower <- ordinary$ModelLower; ordinary$Upper <- ordinary$ModelUpper
    ordinary$Display <- ifelse(ordinary$Status == "fixed", "Fixed", "Available")
    rows <- rbind(rows, ordinary)
  }
  finite <- rows[rows$Display == "Available" & is.finite(rows$Lower) & is.finite(rows$Upper), , drop = FALSE]
  p <- ggplot2::ggplot(rows, ggplot2::aes(x = .data$Estimate, y = .data$Y,
      color = .data$Method)) +
    ggplot2::geom_segment(data = finite, ggplot2::aes(x = .data$Lower,
      xend = .data$Upper, yend = .data$Y, linetype = .data$Method), linewidth = .8) +
    ggplot2::geom_point(data = rows[is.finite(rows$Estimate), , drop = FALSE],
      ggplot2::aes(shape = .data$Display), size = 2.8) +
    ggplot2::scale_shape_manual(values = c(Available = 16, Fixed = 5, Unavailable = 4),
      limits = if (!any(is.finite(rows$Estimate))) character() else NULL) +
    ggplot2::scale_color_manual(limits = unique(rows$Method),
      values = c(Sandwich = style$accent_primary, "Conditional information" = style$accent_primary,
      "Observed information" = if (selected == "Sandwich") "grey45" else style$accent_primary)) +
    ggplot2::scale_linetype_manual(limits = unique(rows$Method),
      values = c(Sandwich = "solid", "Observed information" = "dashed", "Conditional information" = "solid")) +
    ggplot2::scale_y_continuous(breaks = rev(seq_len(nrow(tab))),
      labels = d$target_labels %||% tab$Target,
      limits = if (any(!is.finite(tab$Estimate))) c(.5, nrow(tab) + .5) else NULL) +
    ggplot2::labs(color = "Method", linetype = "Method", shape = "Interval",
      alt = "Fixed-facet estimates and pointwise normal intervals. Method comparisons use vertical offsets and line types. Open diamonds mark fixed targets and crosses mark estimated points with unavailable intervals. Rows labeled not estimated have no point or interval; no missing estimate is replaced by zero.") +
    .mfrmr_gg_theme()
  if (!is.null(d$reference)) p <- p + ggplot2::geom_vline(xintercept = d$reference,
    linetype = "dashed", color = "grey60")
  if (!any(is.finite(c(d$reference, rows$Estimate, rows$Lower, rows$Upper))))
    p <- p + ggplot2::scale_x_continuous(limits = c(-1, 1))
  if (identical(d$show_legend, FALSE)) p <- p + ggplot2::theme(legend.position = "none")
  p <- .mfrmr_gg_labs(p, d, x = d$xlab)
  attr(p, "mfrmr_plot_data") <- x
  p
}
