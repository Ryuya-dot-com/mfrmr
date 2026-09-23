#' Plot fixed-facet interval methods
#'
#' @param x Output from [mfrm_facet_intervals()].
#' @param comparison Logical. With a sandwich result, also show its ordinary
#'   model-based interval. Both intervals use the same point estimate.
#' @param draw Logical; `FALSE` returns exact plotted data without opening a device.
#' @param preset A package plot preset, for example `"standard"` or `"monochrome"`.
#' @param ... Unused.
#' @return Invisibly, an `mfrm_plot_data` object retaining the `table`, contrast
#'   coefficients, settings and labels. Use [plot_data()] for custom graphics;
#'   automatic [as_ggplot()] conversion is unavailable.
#' @details Fixed targets use open diamonds without inferential intervals.
#'   Unavailable selected intervals use crosses; an ordinary comparison interval
#'   does not substitute for a missing sandwich interval. The zero line is a
#'   reference, not a threshold of practical importance or a rater-quality rule.
#'   No fit or covariance is recalculated. Target order is preserved.
#' @export
plot.mfrm_facet_intervals <- function(x, comparison = TRUE, draw = TRUE,
                                      preset = "standard", ...) {
  rlang::check_dots_empty()
  if (any(!vapply(list(comparison, draw), function(a)
      is.logical(a) && length(a) == 1L && !is.na(a), logical(1)))) {
    stop("`comparison` and `draw` must be TRUE or FALSE.", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  tab <- x$table
  show_model <- comparison && x$settings$method == "sandwich"
  title <- paste(x$settings$facet, "estimates and contrasts")
  subtitle <- sprintf("%.0f%% pointwise normal intervals%s", 100 * x$settings$level,
    if (x$settings$method == "sandwich") paste0(" | ", x$settings$clusters, " independent clusters assumed") else "")
  selected_label <- if (x$settings$method == "sandwich") "Sandwich" else "Observed information"
  out <- new_mfrm_plot_data("facet_interval_methods", list(table = tab,
    contrasts = x$contrasts, settings = x$settings, comparison = show_model,
    title = title, subtitle = subtitle, xlab = "Estimate (logits)", preset = style$name))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  status_note <- any(tab$Status != "available")
  old <- graphics::par(mar = c(if (status_note) 7 else 5, 10, 6, 2))
  on.exit(graphics::par(old), add = TRUE)
  y <- rev(seq_len(nrow(tab)))
  limits <- range(c(0, tab$Estimate, tab$Lower, tab$Upper,
    if (show_model) c(tab$ModelLower, tab$ModelUpper)), finite = TRUE)
  if (diff(limits) == 0) limits <- limits + c(-0.1, 0.1)
  graphics::plot(tab$Estimate, y, type = "n", xlim = limits,
    ylim = c(0.5, nrow(tab) + 0.5), yaxt = "n", xlab = "Estimate (logits)",
    ylab = "", main = "")
  graphics::abline(v = 0, col = style$grid, lty = 2)
  offset <- if (show_model) .1 else 0
  if (show_model) {
    graphics::segments(tab$ModelLower, y - offset, tab$ModelUpper, y - offset,
      col = "grey50", lwd = 2)
    graphics::points(tab$Estimate, y - offset, pch = 1, col = "grey50")
  }
  graphics::segments(tab$Lower, y + offset, tab$Upper, y + offset,
    col = style$accent_primary, lwd = 2)
  shape <- ifelse(tab$Status == "fixed", 5, ifelse(tab$Status == "available", 16, 4))
  graphics::points(tab$Estimate, y + offset, pch = shape, col = style$accent_primary)
  graphics::axis(2, at = y, labels = tab$Target, las = 1)
  graphics::title(main = title, line = 4)
  graphics::mtext(subtitle, side = 3, line = 2.2, cex = .8)
  graphics::legend(x = mean(graphics::par("usr")[1:2]),
    y = graphics::par("usr")[4] + .6 * graphics::strheight("M"),
    xjust = .5, yjust = 0, horiz = TRUE, xpd = NA,
    legend = c(selected_label, if (show_model) "Observed information"),
    pch = c(16, if (show_model) 1), col = c(style$accent_primary, if (show_model) "grey50"),
    bty = "n", cex = .8)
  if (status_note) graphics::mtext(
    "Open diamonds: fixed targets | Crosses: unavailable selected intervals", side = 1, line = 5, cex = .75)
  invisible(out)
}
