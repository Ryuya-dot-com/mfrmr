#' Plot pooled facet estimates or prespecified contrasts
#'
#' @param x Output from [pool_mfrm_imputed()].
#' @param draw Logical. With `FALSE`, return the exact plot data without
#'   opening a graphics device.
#' @param preset A package plotting preset, such as `"standard"` or
#'   `"monochrome"`.
#' @param title,subtitle Optional text; `NULL` omits it. The default subtitle
#'   retains a notice when complete-data information is weak. Full cautions
#'   remain in the returned plot data even with custom or omitted text.
#' @param ... Unused.
#' @return Invisibly, an `mfrm_plot_data` object containing the plotted `table`,
#'   exact contrast coefficients and inference settings. Use [plot_data()] for
#'   custom graphics; automatic [as_ggplot()] conversion is unavailable.
#' @details Plots use the stored pointwise multiple-imputation intervals and
#'   preserve target order. Open diamonds identify fixed targets without an
#'   inferential interval. A zero reference line does not define a practical
#'   importance threshold. The plot does not refit, select significant raters,
#'   adjust for multiplicity or turn severity differences into rater quality.
#' @seealso [pool_mfrm_imputed()]
#' @export
plot.mfrm_pooled <- function(x, draw = TRUE, preset = "standard",
    title = paste("Pooled", x$settings$facet, "estimates and contrasts"),
    subtitle = sprintf("%d imputations | %.0f%% pointwise MI intervals",
      x$settings$imputations, 100 * x$settings$ci_level), ...) {
  rlang::check_dots_empty()
  if (!is.logical(draw) || length(draw) != 1L || is.na(draw)) {
    stop("`draw` must be TRUE or FALSE.", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  tab <- x$table
  if (missing(subtitle) && length(x$cautions)) subtitle <- paste(subtitle,
    "Weak information: review completed-data intervals.", sep = "\n")
  if (!all(vapply(list(title, subtitle), function(a)
      is.null(a) || (is.character(a) && length(a) == 1L && !is.na(a)), logical(1)))) {
    stop("Plot text must be NULL or one nonmissing character string.", call. = FALSE)
  }
  out <- new_mfrm_plot_data("pooled_facet_intervals", list(table = tab,
    contrasts = x$contrasts, settings = x$settings, title = title,
    cautions = x$cautions, information_review = x$information_review,
    subtitle = subtitle, xlab = "Estimate (logits)", preset = style$name))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  extra_lines <- if (is.null(subtitle)) 0L else
    max(0L, length(strsplit(subtitle, "\n", fixed = TRUE)[[1L]]) - 1L)
  old <- graphics::par(mar = c(5, 10, 5 + extra_lines, 2))
  on.exit(graphics::par(old), add = TRUE)
  y <- rev(seq_len(nrow(tab)))
  limits <- range(c(0, tab$Estimate, tab$Lower, tab$Upper), finite = TRUE)
  if (diff(limits) == 0) limits <- limits + c(-0.1, 0.1)
  fixed <- tab$Status == "fixed"
  graphics::plot(tab$Estimate, y, xlim = limits, ylim = c(0.5, nrow(tab) + 0.5),
    pch = ifelse(fixed, 5, 16), col = style$accent_primary, yaxt = "n",
    xlab = "Estimate (logits)", ylab = "", main = "")
  graphics::abline(v = 0, col = style$grid, lty = 2)
  graphics::segments(tab$Lower[!fixed], y[!fixed], tab$Upper[!fixed], y[!fixed],
    col = style$accent_primary, lwd = 2)
  graphics::axis(2, at = y, labels = tab$Target, las = 1)
  if (!is.null(title)) graphics::title(main = title, line = 3 + extra_lines)
  if (!is.null(subtitle)) graphics::mtext(subtitle, side = 3, line = 0.3, cex = 0.8)
  if (any(fixed)) graphics::mtext("Open diamonds: fixed by model constraints", side = 1, line = 3, cex = 0.8)
  invisible(out)
}
