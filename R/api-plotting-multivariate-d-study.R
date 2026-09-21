#' Compare task and rater counts in a multivariate D-study
#'
#' See how a planned change in the number of tasks or raters affects the
#' dependability of a mean score. Plot an existing D-study result; no model
#' is refitted. Start with `plot(d)` for G and Phi, then use
#' `plot(d, type = "sem")` to examine error in score units.
#'
#' @param x A result from [mfrm_multivariate_d_study()].
#' @param type `"coefficients"` shows G and Phi in separate panels;
#'   `"sem"` shows relative and absolute standard errors of measurement.
#' @param score A single original score name. `NULL` selects the weighted
#'   composite if present, otherwise the first score in the G-study. The
#'   title identifies the selection and, for a composite, its weights.
#'   An explicit name always selects an original score, even if it is named
#'   `"Composite"`. Call the method again to inspect another score.
#' @param x_var `"Tasks"` or `"Raters"`. By default use tasks, unless only
#'   the rater count varies. A Person-by-Task result only permits `"Tasks"`.
#'   Each line holds the other facet count constant.
#' @param draw Draw the plot when `TRUE`; `FALSE` only returns its data.
#' @param preset Plot style: `"standard"`, `"publication"`, `"compact"`, or
#'   `"monochrome"`. Point shapes and line types also distinguish counts.
#' @param ... Reserved for future use; additional arguments are rejected.
#'
#' @details
#' G describes consistency of relative ordering: for example, ranking
#' examinees. Phi also includes shifts caused by easier tasks or more lenient
#' raters and concerns absolute score levels. Higher coefficients indicate
#' greater dependability under the fitted model; neither gives the probability
#' of a correct pass/fail decision. No universal acceptable cutoff is drawn.
#'
#' SEM is the square root of error variance. Lower values indicate less error
#' in the units of the selected mean score or composite. Relative SEM concerns
#' ordering; absolute SEM also includes condition-wide shifts. SEM is not a
#' confidence interval for G or Phi. The two SEM panels share a scale, but
#' different scores or differently scaled composites need not have comparable
#' units. Weights are not normalized.
#'
#' Points represent only the supplied scenarios. Lines connect them as visual
#' guides within a fixed count of the other facet, without fitting a curve or
#' evaluating intermediate designs. For example, with tasks on the horizontal
#' axis, compare points along one line to change tasks while keeping raters
#' constant. Compare lines at the same task count to change raters.
#'
#' All scenarios describe complete future crossed designs with the same
#' conditions for each person and score. Even when the G-study used incomplete
#' data, the figure does not describe reliability of that sparse roster.
#' Projections hold estimated covariance components fixed and have no sampling
#' confidence intervals. A flattening curve can indicate limited gains from
#' adding one facet alone; it does not identify a cost-effective optimum.
#'
#' Unavailable estimates stay missing. A panel with no estimates states the
#' reason; otherwise a margin note reports unavailable scenarios. The returned
#' `unavailable` table preserves their counts, metrics, and `Status` values.
#' For failed covariance checks inspect `x$component_diagnostics` and the
#' G-study design and data; increasing planned counts cannot repair those
#' estimates. Missing values are never plotted as zero.
#'
#' @return Invisibly, an `mfrm_plot_data` object. Use [plot_data()] to extract
#'   `table` (the selected score/composite), `series` (one row per scenario and
#'   plotted metric, including missing values), `unavailable`, `design_grid`,
#'   `weights`, score identity, axis/group names, labels, and legend settings.
#'   [as_ggplot()] preserves these comparisons for editing or export with
#'   the optional ggplot2 package; for example, `as_ggplot(d, type = "sem")`.
#' @seealso [mfrm_multivariate_d_study()], [mfrm_multivariate_gstudy()]
#' @examples
#' # Question: how much would doubling the common tasks change dependability?
#' tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
#' g <- mfrm_multivariate_gstudy(tasks, c("V", "W"), rater = NULL)
#' d <- mfrm_multivariate_d_study(g, data.frame(Tasks = c(3, 6, 12)),
#'   weights = c(V = -1, W = 1))
#' plot(d) # Default: the difference W minus V; higher G/Phi is better.
#' plot(d, type = "sem") # Error in difference-score units; lower is better.
#' plot(d, score = "V") # Inspect an original score separately.
#' values <- plot_data(plot(d, draw = FALSE))
#' values$table # Exact values and availability, rather than reading off a line.
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   p <- as_ggplot(d, type = "sem")
#'   print(p)
#'   # ggplot2::ggsave("d-study-sem.png", p, width = 7, height = 7, dpi = 300)
#' }
#' @export
plot.mfrm_multivariate_d_study <- function(x, type = c("coefficients", "sem"),
                                          score = NULL, x_var = NULL, draw = TRUE,
                                          preset = "standard", ...) {
  rlang::check_dots_empty()
  type <- match.arg(type)
  if (!is.logical(draw) || length(draw) != 1L || is.na(draw)) {
    stop("`draw` must be TRUE or FALSE.", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  tab <- x$coefficients
  if (is.null(score)) {
    kind <- if (is.null(x$weights)) "Score" else "Composite"
    score <- if (kind == "Composite") "Composite" else x$gstudy$design$scores[1L]
  } else {
    kind <- "Score"
  }
  if (!is.character(score) || length(score) != 1L || is.na(score) ||
      !any(tab$Kind == kind & tab$Score == score)) {
    stop("`score` must name one original score; use NULL for the default selection.", call. = FALSE)
  }
  tab <- tab[tab$Kind == kind & tab$Score == score, , drop = FALSE]
  facets <- names(x$design_grid)
  if (is.null(x_var)) x_var <- if ("Raters" %in% facets &&
    length(unique(tab$Tasks)) == 1L && length(unique(tab$Raters)) > 1L) "Raters" else "Tasks"
  if (!is.character(x_var) || length(x_var) != 1L || is.na(x_var) || !x_var %in% facets) {
    stop("`x_var` must name a facet count present in the D-study: ",
      paste(facets, collapse = ", "), ".", call. = FALSE)
  }
  group_var <- setdiff(facets, x_var)
  metrics <- if (type == "coefficients") c("G", "Phi") else c("RelativeSEM", "AbsoluteSEM")
  labels <- if (type == "coefficients") c("G: relative ordering", "Phi: absolute score levels") else
    c("Relative SEM: ordering", "Absolute SEM: score levels")
  groups <- if (length(group_var)) paste(group_var, "=", sort(unique(tab[[group_var]]))) else "Tasks only"
  series <- do.call(rbind, lapply(metrics, function(metric) {
    data.frame(tab, Metric = metric, X = tab[[x_var]],
      Group = if (length(group_var)) paste(group_var, "=", tab[[group_var]]) else groups,
      Value = tab[[metric]], row.names = NULL)
  }))
  unavailable <- series[series$Status != "Available" | !is.finite(series$Value), , drop = FALSE]
  cols <- if (style$name == "monochrome") rep(style$foreground, length(groups)) else
    grDevices::hcl.colors(max(3L, length(groups)), "Dark 3")[seq_along(groups)]
  line_types <- rep(1:6, length.out = length(groups))
  shapes <- rep(c(16, 17, 15, 18, 1, 2), length.out = length(groups))
  title <- if (kind == "Composite") paste0("Composite: ", paste(names(x$weights),
    format(x$weights, trim = TRUE), sep = " = ", collapse = ", ")) else paste("Score:", score)
  subtitle <- "Future complete crossed designs | Estimated components held fixed | No confidence intervals"
  out <- new_mfrm_plot_data("multivariate_d_study", list(table = tab, series = series,
    unavailable = unavailable, design_grid = x$design_grid, weights = x$weights,
    score = score, kind = kind, plot = type, x_var = x_var, group_var = group_var, metric = metrics,
    title = title, subtitle = subtitle, panel_labels = labels,
    legend = new_plot_legend(groups, rep("condition_count", length(groups)),
      rep("color", length(groups)), cols),
    line_types = line_types, point_shapes = shapes, preset = style$name))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  old <- graphics::par()[c("mfrow", "mar", "oma", "cex", "mex")]
  on.exit(graphics::par(old), add = TRUE)
  title_lines <- strwrap(title, width = 75)
  graphics::par(mfrow = c(2, 1), mar = c(4.7, 5.3, 2.3, if (length(group_var)) 8 else 1),
    oma = c(2.6, 0, length(title_lines) + 0.5, 0))
  available <- series$Status == "Available" & is.finite(series$Value)
  y_lim <- if (type == "coefficients" || !any(available)) c(0, 1) else
    c(0, max(series$Value[available]))
  if (y_lim[2] == 0) y_lim[2] <- 1
  for (i in seq_along(metrics)) {
    s <- series[series$Metric == metrics[i], , drop = FALSE]
    ok <- s$Status == "Available" & is.finite(s$Value)
    graphics::plot(range(s$X), y_lim, type = "n", ylim = y_lim,
      xlab = paste("Number of", tolower(x_var)),
      ylab = if (type == "coefficients") "Dependability\nHigher is better" else "SEM (score units)\nLower is better",
      main = labels[i], xaxt = "n", yaxt = "n")
    ticks <- sort(unique(s$X))
    if (length(ticks) > 15L) ticks <- pretty(range(ticks))
    graphics::axis(1, at = ticks[ticks >= min(s$X) & ticks <= max(s$X) & ticks == floor(ticks)])
    if (any(ok)) {
      if (type == "coefficients") graphics::axis(2, at = seq(0, 1, 0.2), las = 1) else graphics::axis(2, las = 1)
      graphics::grid(nx = NA, ny = NULL, col = style$grid)
      for (j in seq_along(groups)) {
        z <- s[s$Group == groups[j], , drop = FALSE]
        z <- z[order(z$X, z$Scenario), , drop = FALSE]
        z$Value[z$Status != "Available" | !is.finite(z$Value)] <- NA_real_
        graphics::lines(z$X, z$Value, type = "b", col = cols[j], lty = line_types[j],
          pch = shapes[j], lwd = 2)
      }
      if (any(!ok)) graphics::mtext(sprintf("Unavailable: %d of %d scenarios; see returned unavailable table.",
        sum(!ok), nrow(s)), side = 1, line = 3.5, cex = 0.7)
    } else {
      graphics::text(mean(range(s$X)), mean(y_lim), .mfrm_mvds_unavailable_message(s$Status),
        cex = 0.8, col = style$foreground)
    }
    if (length(group_var)) {
      usr <- graphics::par("usr")
      graphics::legend(usr[2] + 0.03 * diff(usr[1:2]), usr[4], legend = groups,
        col = cols, lty = line_types, pch = shapes, bty = "n", xpd = NA, cex = 0.8)
    }
  }
  graphics::mtext(paste(title_lines, collapse = "\n"), side = 3, outer = TRUE,
    line = 0.3, font = 2, cex = 0.95)
  graphics::mtext("Future complete crossed designs; estimated components held fixed.",
    side = 1, outer = TRUE, line = 0.4, cex = 0.75)
  graphics::mtext("Points are requested scenarios; lines are guides. No confidence intervals.",
    side = 1, outer = TRUE, line = 1.4, cex = 0.75)
  invisible(out)
}

.mfrm_mvds_unavailable_message <- function(status) {
  reasons <- unique(status)
  reasons[reasons == "Non-PSD component estimates"] <- "Covariance components failed validity checks."
  reasons[reasons == "Available"] <- "No finite estimates in the stored result."
  paste(c("Estimates unavailable", reasons,
    "Inspect the D-study table and component diagnostics."), collapse = "\n")
}
