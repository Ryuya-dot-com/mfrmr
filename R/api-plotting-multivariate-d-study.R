#' Compare measurement-condition counts in a multivariate D-study
#'
#' See how a planned change in the number of tasks, raters, or other conditions affects the
#' dependability of a mean score. Plot an existing D-study result; no model
#' is refitted. Start with `plot(d)` for G and Phi, then use
#' `plot(d, type = "sem")` to examine error in score units. If the result has
#' several composites, select one explicitly with `composite`.
#'
#' @param x A result from [mfrm_multivariate_d_study()].
#' @param type `"coefficients"` shows G and Phi in separate panels;
#'   `"sem"` shows relative and absolute standard errors of measurement.
#' @param score A single original score name. An explicit name always selects
#'   an original score, even if a composite has the same name. If both `score`
#'   and `composite` are `NULL`, select the sole composite, or the first score
#'   when there are no composites. Several composites require an explicit
#'   selection. The title identifies the selection and any composite weights.
#'   Call the method again to inspect another score or composite.
#' @param x_var A count column in `x$design_grid`: `"Tasks"`/`"Raters"` for
#'   the task/rater interface, or a facet label supplied through `facets`.
#'   By default use the last varying count column, or the last column if
#'   none varies. A one-facet result permits only its included facet.
#'   Each line holds the other facet count constant.
#' @param draw Draw the plot when `TRUE`; `FALSE` only returns its data.
#' @param preset Plot style: `"standard"`, `"publication"`, `"compact"`, or
#'   `"monochrome"`. Point shapes and line types also distinguish counts.
#' @param composite A single composite name from `x$coefficients`, as defined
#'   by a weight-matrix column, or `"Composite"` for vector weights. Supply
#'   either `score` or `composite`, not both.
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
#' units. Weights are not normalized. Changing weights can also change the
#' meaning of the score; a higher G or Phi alone does not justify a new set
#' of weights.
#'
#' Points represent only the supplied scenarios. Lines connect them as visual
#' guides within a fixed count of the other facet, without fitting a curve or
#' evaluating intermediate designs. For example, with tasks on the horizontal
#' axis, compare points along one line to change tasks while keeping raters
#' constant. Compare lines at the same task count to change raters.
#'
#' Scenarios retain the G-study's crossed or nested structure, with complete
#' balanced future conditions shared by every person and score. For a nested
#' facet, the axis or legend says "per" to identify its count within each parent,
#' for example "Raters per Task"; this is not the total rater pool size.
#' Even when the G-study used incomplete
#' data, the figure does not describe reliability of that sparse roster.
#' Projections hold estimated covariance components fixed and have no sampling
#' confidence intervals. A flattening curve can indicate limited gains from
#' adding one facet alone; it does not identify a cost-effective optimum.
#' The highest point alone does not account for uncertainty in the estimated
#' components. Read the size of differences as well as their ordering. Equal products
#' of rater and task counts give equal rating counts, not necessarily equal
#' examinee burden or total cost. Unavailable candidates prevent a complete
#' comparison for that metric.
#'
#' Unavailable estimates stay missing. A panel with no estimates states the
#' reason; otherwise a margin note reports unavailable scenarios. The returned
#' `unavailable` table preserves their counts, metrics, and `Status` values.
#' Each panel uses its metric's status, so an unavailable Phi does not hide
#' an available G. Non-PSD component matrices are noted separately on the
#' figure; inspect `x$component_diagnostics` before using raw projections.
#' Increasing planned counts does not repair those component estimates.
#' Missing values are never plotted as zero. Previously saved D-study objects
#' retain their recorded values and availability: rerun
#' [mfrm_multivariate_d_study()] on the saved G-study to apply current rules.
#'
#' @return Invisibly, an `mfrm_plot_data` object. Use [plot_data()] to extract
#'   `table` (the selected score/composite), `series` (one row per scenario and
#'   plotted metric, including missing values), `unavailable`, `design_grid`,
#'   `weights`, score identity, axis/group names, labels, `component_note`,
#'   and legend settings. In `series`, `Status` is specific to `Metric`;
#'   `table` retains the original row status and metric-specific columns.
#'   `weights` contains the selected composite's named weight vector,
#'   or `NULL` when plotting an original score.
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
#'
#' # A weight matrix names several choices; explicitly select the plotted one.
#' alternatives <- mfrm_multivariate_d_study(g, data.frame(Tasks = c(3, 6, 12)),
#'   weights = cbind(Equal = c(V = 0.5, W = 0.5), Difference = c(V = -1, W = 1)))
#' plot(alternatives, composite = "Equal")
#' plot(alternatives, composite = "Difference", type = "sem")
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   print(as_ggplot(alternatives, composite = "Equal"))
#' }
#' @export
plot.mfrm_multivariate_d_study <- function(x, type = c("coefficients", "sem"),
                                          score = NULL, x_var = NULL, draw = TRUE,
                                          preset = "standard", composite = NULL, ...) {
  rlang::check_dots_empty()
  type <- match.arg(type)
  if (!is.logical(draw) || length(draw) != 1L || is.na(draw)) {
    stop("`draw` must be TRUE or FALSE.", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  tab <- x$coefficients
  if (!is.null(score) && !is.null(composite)) {
    stop("Choose either `score` or `composite`, not both.", call. = FALSE)
  }
  if (is.null(score) && is.null(composite)) {
    composites <- unique(tab$Score[tab$Kind == "Composite"])
    if (length(composites) > 1L) {
      stop("Several composites are available; select one with `composite`, or an original score with `score`.", call. = FALSE)
    }
    if (length(composites)) composite <- composites else score <- x$gstudy$design$scores[1L]
  }
  if (!is.null(composite)) {
    if (!is.character(composite) || length(composite) != 1L || is.na(composite) ||
        !any(tab$Kind == "Composite" & tab$Score == composite)) {
      stop("`composite` must name one composite in the D-study result.", call. = FALSE)
    }
    kind <- "Composite"
    score <- composite
  } else {
    kind <- "Score"
    if (!is.character(score) || length(score) != 1L || is.na(score) ||
        !any(tab$Kind == kind & tab$Score == score)) {
      stop("`score` must name one original score; use NULL for the default selection.", call. = FALSE)
    }
  }
  selected_weights <- if (kind == "Composite") {
    if (is.matrix(x$weights)) setNames(x$weights[, score], rownames(x$weights)) else x$weights
  } else NULL
  tab <- tab[tab$Kind == kind & tab$Score == score, , drop = FALSE]
  facets <- names(x$design_grid)
  if (is.null(x_var)) {
    varying <- facets[vapply(tab[facets], function(n) length(unique(n)) > 1L, logical(1))]
    x_var <- tail(if (length(varying)) varying else facets, 1L)
  }
  if (!is.character(x_var) || length(x_var) != 1L || is.na(x_var) || !x_var %in% facets) {
    stop("`x_var` must name a facet count present in the D-study: ",
      paste(facets, collapse = ", "), ".", call. = FALSE)
  }
  x_label <- if (x_var %in% c("Tasks", "Raters")) paste("Number of", tolower(x_var)) else
    paste(x_var, "count")
  nesting <- x$gstudy$design$nesting
  count_labels <- setNames(facets, facets)
  if (!is.null(nesting)) {
    child_column <- x$gstudy$design$count_columns[[names(nesting)]]
    count_labels[child_column] <- paste(child_column, "per", unname(nesting))
    if (x_var == child_column) x_label <- paste(x_label, "per", unname(nesting))
  }
  group_var <- setdiff(facets, x_var)
  metrics <- if (type == "coefficients") c("G", "Phi") else c("RelativeSEM", "AbsoluteSEM")
  labels <- if (type == "coefficients") c("G: relative ordering", "Phi: absolute score levels") else
    c("Relative SEM: ordering", "Absolute SEM: score levels")
  groups <- if (length(group_var)) paste(count_labels[[group_var]], "=", sort(unique(tab[[group_var]]))) else
    paste(x_var, "only")
  series <- do.call(rbind, lapply(metrics, function(metric) {
    rows <- data.frame(tab, Metric = metric, X = tab[[x_var]],
      Group = if (length(group_var)) paste(count_labels[[group_var]], "=", tab[[group_var]]) else groups,
      Value = tab[[metric]], row.names = NULL, check.names = FALSE)
    # Preserve the recorded policy for older D-study objects; do not recalculate.
    if (!is.null(tab[[paste0(metric, "Status")]])) rows$Status <- tab[[paste0(metric, "Status")]]
    rows
  }))
  unavailable <- series[series$Status != "Available" | !is.finite(series$Value), , drop = FALSE]
  cols <- if (style$name == "monochrome") rep(style$foreground, length(groups)) else
    grDevices::hcl.colors(max(3L, length(groups)), "Dark 3")[seq_along(groups)]
  line_types <- rep(1:6, length.out = length(groups))
  shapes <- rep(c(16, 17, 15, 18, 1, 2), length.out = length(groups))
  title <- if (kind == "Composite") paste0("Composite",
    if (is.matrix(x$weights)) paste0(" ", score), ": ", paste(names(selected_weights),
    format(selected_weights, trim = TRUE), sep = " = ", collapse = ", ")) else paste("Score:", score)
  design_label <- if (is.null(nesting)) "Future complete crossed designs" else
    paste0("Future balanced nested designs: ", names(nesting), " within ", unname(nesting))
  subtitle <- paste(design_label, "| Estimated components held fixed | No confidence intervals")
  component_note <- if (any(!x$component_diagnostics$PositiveSemidefinite))
    "Non-PSD covariance components: raw projections; review component diagnostics." else NULL
  out <- new_mfrm_plot_data("multivariate_d_study", list(table = tab, series = series,
    unavailable = unavailable, design_grid = x$design_grid, weights = selected_weights,
    nesting = nesting,
    score = score, kind = kind, plot = type, x_var = x_var, x_label = x_label,
    group_var = group_var, metric = metrics,
    title = title, subtitle = subtitle, component_note = component_note, panel_labels = labels,
    legend = new_plot_legend(groups, rep("condition_count", length(groups)),
      rep("color", length(groups)), cols),
    line_types = line_types, point_shapes = shapes, preset = style$name))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  old <- graphics::par()[c("mfrow", "mar", "oma", "cex", "mex")]
  on.exit(graphics::par(old), add = TRUE)
  title_lines <- strwrap(title, width = 75)
  graphics::par(mfrow = c(2, 1), mar = c(4.7, 5.3, 2.3, if (length(group_var)) 8 else 1),
    oma = c(if (is.null(component_note)) 2.6 else 3.6, 0, length(title_lines) + 0.5, 0))
  if (length(group_var)) {
    margin <- graphics::par("mar")
    legend_width <- max(graphics::strwidth(paste("MMMM", groups), units = "inches", cex = 0.8))
    margin[4L] <- max(margin[4L], legend_width / (graphics::par("csi") * graphics::par("mex")) + 1)
    graphics::par(mar = margin)
  }
  available <- series$Status == "Available" & is.finite(series$Value)
  y_lim <- if (type == "coefficients" || !any(available)) c(0, 1) else
    c(0, max(series$Value[available]))
  if (y_lim[2] == 0) y_lim[2] <- 1
  for (i in seq_along(metrics)) {
    s <- series[series$Metric == metrics[i], , drop = FALSE]
    ok <- s$Status == "Available" & is.finite(s$Value)
    graphics::plot(range(s$X), y_lim, type = "n", ylim = y_lim,
      xlab = x_label,
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
  graphics::mtext(paste0(design_label, "; estimated components held fixed."),
    side = 1, outer = TRUE, line = 0.4, cex = 0.75)
  graphics::mtext("Points are requested scenarios; lines are guides. No confidence intervals.",
    side = 1, outer = TRUE, line = 1.4, cex = 0.75)
  if (!is.null(component_note)) graphics::mtext(component_note,
    side = 1, outer = TRUE, line = 2.4, cex = 0.75)
  invisible(out)
}

.mfrm_mvds_unavailable_message <- function(status) {
  reasons <- unique(status)
  reasons[reasons == "Non-PSD component estimates"] <- "Covariance components failed validity checks."
  reasons[reasons == "Available"] <- "No finite estimates in the stored result."
  paste(c("Estimates unavailable", reasons,
    "Inspect the D-study table and component diagnostics."), collapse = "\n")
}
