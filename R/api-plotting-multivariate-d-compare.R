#' Plot differences between prespecified D-study plans
#'
#' Show each plan's change from a reference, with approximate pointwise intervals.
#' The vertical zero line represents no change; an interval crossing it does not
#' establish equivalence. Positive G/Phi differences or negative SEM differences
#' favor the comparison plan. The method requires normal random effects.
#'
#' @param x A result from [mfrm_multivariate_d_compare()].
#' @param type `"coefficients"` for G/Phi or `"sem"` for SEM differences.
#' @param draw Draw the figure; `FALSE` returns its data only.
#' @param preset Plot style: `"standard"`, `"publication"`, `"compact"`, or
#'   `"monochrome"`.
#' @param ... Reserved; additional arguments are rejected.
#' @details Plans and score weights must have been specified before inspecting
#'   the results. Intervals are not simultaneous over plans or metrics. A point
#'   without an interval is retained and marked as unavailable; missing values
#'   are never replaced by zero. Each panel has its own horizontal scale.
#'   Original score units apply to SEM differences. The figure identifies the
#'   score/composite, its weights and the reference counts.
#' @return Invisibly, an `mfrm_plot_data` object. [plot_data()] extracts the exact
#'   plotted `table`, `unavailable` rows, `design_grid`, `reference`, `weights`,
#'   title and labels. Base graphics are supported; automatic ggplot conversion
#'   is not provided for this plot.
#' @seealso [mfrm_multivariate_d_compare()]
#' @export
plot.mfrm_multivariate_d_comparison <- function(x, type = c("coefficients", "sem"),
                                                draw = TRUE, preset = "standard", ...) {
  rlang::check_dots_empty()
  type <- match.arg(type)
  if (!is.logical(draw) || length(draw) != 1L || is.na(draw)) stop("`draw` must be TRUE or FALSE.", call. = FALSE)
  style <- resolve_plot_preset(preset)
  metrics <- if (type == "coefficients") c("G", "Phi") else c("RelativeSEM", "AbsoluteSEM")
  table <- x$comparisons[x$comparisons$Metric %in% metrics, , drop = FALSE]
  plan_labels <- vapply(seq_len(nrow(x$design_grid)), function(i)
    paste(paste(names(x$design_grid), unlist(x$design_grid[i, ]), sep = " = "), collapse = ", "), character(1))
  table$Plan <- plan_labels[table$Scenario]
  selection <- if (x$kind == "Composite") paste0("Composite",
    if (x$score != "Composite") paste0(" ", x$score), ": ",
    paste(names(x$weights), format(x$weights, trim = TRUE), sep = " = ", collapse = ", ")) else
    paste("Score:", x$score)
  title <- paste(selection, "| Reference:", plan_labels[x$reference])
  subtitle <- paste0(format(100 * x$level), "% approximate pointwise intervals | Normal random effects")
  unavailable <- table[table$Status != "Available", , drop = FALSE]
  note <- "Intervals crossing zero do not establish equivalence."
  if (nrow(unavailable)) note <- paste(note, nrow(unavailable), "interval(s) unavailable; inspect plot_data().")
  if (any(!x$component_diagnostics$PositiveSemidefinite) || !x$sampling_covariance_psd) {
    note <- paste(note, "Non-PSD covariance estimates: review diagnostics.")
  }
  out <- new_mfrm_plot_data("multivariate_d_comparison", list(table = table,
    unavailable = unavailable, design_grid = x$design_grid, reference = x$reference,
    weights = x$weights, title = title, subtitle = subtitle, note = note, metrics = metrics))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  old <- graphics::par()[c("mfrow", "mar", "oma", "cex", "mex")]
  on.exit(graphics::par(old), add = TRUE)
  title_lines <- strwrap(title, 90)
  note_lines <- strwrap(note, 95)
  labels <- if (type == "coefficients") c("G: relative ordering", "Phi: absolute score levels") else
    c("Relative SEM: ordering", "Absolute SEM: score levels")
  graphics::par(mfrow = c(2, 1), mar = c(5, 12, 2.5, 1),
    oma = c(length(note_lines) + 1, 0, length(title_lines) + 2, 0))
  for (j in seq_along(metrics)) {
    tab <- table[table$Metric == metrics[j], , drop = FALSE]
    position <- rev(seq_len(nrow(tab)))
    extent <- unlist(tab[c("Difference", "Lower", "Upper")], use.names = FALSE)
    limits <- range(c(0, extent[is.finite(extent)]))
    if (diff(limits) == 0) limits <- limits + c(-.05, .05)
    direction <- if (type == "coefficients") "Higher favors comparison" else "Lower favors comparison"
    graphics::plot(limits, c(.5, nrow(tab) + .5), type = "n", yaxt = "n", ylab = "",
      xlab = paste("Difference from reference |", direction), main = labels[j])
    graphics::axis(2, at = position, labels = ifelse(tab$Status == "Available", tab$Plan,
      paste0(tab$Plan, " *")), las = 1, cex.axis = .8)
    graphics::abline(v = 0, lty = 2, col = "grey50")
    ok <- tab$Status == "Available"
    graphics::segments(tab$Lower[ok], position[ok], tab$Upper[ok], position[ok], lwd = 2)
    finite <- is.finite(tab$Difference)
    graphics::points(tab$Difference[finite], position[finite], pch = ifelse(ok[finite], 16, 1))
    if (!any(finite)) graphics::text(mean(limits), mean(position), "Point projections unavailable")
  }
  graphics::mtext(title_lines, side = 3, outer = TRUE, line = rev(seq_along(title_lines)) + .8, font = 2, cex = .85)
  graphics::mtext(subtitle, side = 3, outer = TRUE, line = .4, cex = .75)
  graphics::mtext(note_lines, side = 1, outer = TRUE, line = seq_along(note_lines) - .5, cex = .75)
  invisible(out)
}
