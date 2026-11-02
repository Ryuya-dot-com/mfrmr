#' @rdname read_mfrm_posterior
#' @details `plot()` method: Plot saved posterior estimates, contrasts, and credible intervals
#' @param x Output from [read_mfrm_posterior()].
#'
#' Also for `print()` and `as.data.frame()`: A saved `mfrm_posterior_summary`.
#' @param quantity One of `"location"` (default unless `contrasts` is supplied),
#'   `"ability"`, `"step_offset"`, `"slope"`, `"log_slope"`, `"population_mean"`,
#'   `"population_sd"`, or `"contrast"`. Population quantities require an
#'   estimated-population export; `"contrast"` requires attached or supplied
#'   `contrasts`. Quantities with different units are not mixed.
#' @param facet Optional facet/owner names to retain; `NULL` retains all for
#'   the selected quantity. Step rows use `facet = "Step owner"`, or the named
#'   step facet for an extended two-family bundle, and retain their owner
#'   labels and category transitions in the plotted table.
#' @param view One of `"intervals"` (default: posterior means and equal-tailed
#'   credible intervals) or `"draws"` (empirical MCMC draw distribution slabs
#'   behind the intervals; requires `posterior-draws.rds` and fails closed when
#'   joint draws are absent).
#' @param draw Logical; `FALSE` returns plot data without opening a device.
#' @param reference Optional finite vertical reference; `NULL` omits it (for
#'   `quantity = "contrast"`, defaults to `0` for linear differences and `1` for
#'   slope ratios unless explicitly set to `NULL`). Zero for locations and one
#'   for relative slopes are references, not standards of performance or rater
#'   quality.
#' @param preset A package plot preset, such as `"standard"` or `"monochrome"`.
#' @param show_legend Logical; show interval/fixed-value symbols.
#' @param title,subtitle,caption Optional returned text. Defaults omit it.
#'   Text is not drawn by default; retrieve it with [plot_data()].
#' @return For `plot()`: Invisibly, a `ggplot` object; [plot_data()] extracts the
#'   exact long `table` (and `draws` when `view = "draws"`), source settings,
#'   parameter or contrast identities, interval statuses and interpretation notes,
#'   and [as_ggplot()] remains idempotent. No posterior draws, densities or
#'   raincloud samples are ever reconstructed from marginal summaries.
#' @details For `plot()`: These are equal-tailed *posterior credible* intervals
#'   at `level`, not frequentist confidence intervals. Dashed intervals and open
#'   circles mark estimates whose sampling screen requires review; solid
#'   intervals mean that no sampling flag was detected, not that inference is
#'   validated. Open diamonds mark fixed anchors/constraint-determined values
#'   without an interval. Crosses mark estimated points without an available
#'   interval. Missing points retain their labels and are never replaced by zero.
#'   Original row order, labels and endpoints are preserved.
#' @seealso [read_mfrm_posterior()], [mfrm_report()]
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @examples
#' posterior <- read_mfrm_posterior(system.file(
#'   "extdata", "posterior-example", package = "mfrmr"))
#' p <- plot(posterior, quantity = "location", draw = FALSE)
#' plot_data(p, "table")
#' if (requireNamespace("ggplot2", quietly = TRUE)) as_ggplot(p)
#'
#' joint_post <- read_mfrm_posterior(system.file(
#'   "extdata", "posterior-draws-example", package = "mfrmr"))
#' pc <- plot(joint_post, contrasts = "Rater", level = 0.90,
#'            view = "draws", draw = FALSE)
#' plot_data(pc, "table")[, c("label", "value_role", "mean", "lower", "upper")]
#' @export
plot.mfrm_posterior_summary <- function(x,
    quantity = c("location", "ability", "step_offset", "slope", "log_slope",
                 "population_mean", "population_sd", "contrast"),
    facet = NULL, contrasts = NULL, level = x$level,
    view = c("intervals", "draws"),
    draw = TRUE, reference = NULL, preset = "standard", show_legend = TRUE,
    title = NULL, subtitle = NULL, caption = NULL, ...) {
  rlang::check_dots_empty()
  .mfrm_validate_posterior(x)
  ref_missing <- missing(reference)
  if (!is.null(contrasts) && missing(quantity)) {
    quantity <- "contrast"
  } else {
    quantity <- match.arg(quantity)
  }
  view <- match.arg(view)
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  style <- resolve_plot_preset(preset)
  if (!all(vapply(list(draw, show_legend), function(v) is.logical(v) && length(v) == 1L && !is.na(v), logical(1))))
    stop("`draw` and `show_legend` must be TRUE or FALSE.", call. = FALSE)
  if (!is.null(reference) && (!is.numeric(reference) || length(reference) != 1L || !is.finite(reference)))
    stop("`reference` must be NULL or one finite number.", call. = FALSE)
  if (!all(vapply(list(title, subtitle, caption), function(v) is.null(v) ||
      (is.character(v) && length(v) == 1L && !is.na(v)), logical(1))))
    stop("Plot text must be NULL or one nonmissing string.", call. = FALSE)
  if (identical(view, "draws") && is.null(x$draws)) {
    stop(
      "Empirical posterior draw plots (`view = 'draws'`) require joint draws (`posterior-draws.rds`). ",
      "Draws are never reconstructed from marginal summaries.",
      call. = FALSE
    )
  }
  level <- .mfrm_validate_credible_level(level)
  if (is.null(x$draws) && abs(level - x$level) > 1e-12) {
    stop("Only the stored 95% posterior credible interval is available. Use the backend's draws for another level.", call. = FALSE)
  }
  if (!is.null(contrasts) || abs(level - x$level) > 1e-12) {
    x <- summary.mfrm_posterior_summary(x, contrasts = contrasts, level = level)
  }
  if (identical(quantity, "contrast")) {
    if (is.null(x$contrasts) || !nrow(x$contrasts)) {
      stop("No posterior contrasts are attached; supply `contrasts` or call `summary(x, contrasts = ...)` first.", call. = FALSE)
    }
    tab <- x$contrasts
    if (!is.null(facet)) {
      if (!is.character(facet) || !length(facet) || anyNA(facet) || !all(facet %in% tab$facet))
        stop("`facet` must select existing owners for the selected contrasts.", call. = FALSE)
      tab <- tab[tab$facet %in% facet, , drop = FALSE]
    }
    if (!nrow(tab)) stop("No saved contrasts match this plot selection.", call. = FALSE)
    if (ref_missing) {
      scales_u <- unique(tab$scale)
      if (length(scales_u) == 1L) {
        reference <- if (identical(scales_u, "ratio")) 1 else 0
      }
    }
    tab$Display <- ifelse(tab$value_role %in% c("fixed_anchor", "fixed_by_constraint"), "Fixed value",
      ifelse(!tab$interval_computed, "Interval unavailable", ifelse(
        tab$sampling_review == "sampling_review_required", "Sampling review required", "No sampling flag")))
    tab$Label <- tab$label
    tab$Label[!is.finite(tab$mean)] <- paste(tab$Label[!is.finite(tab$mean)], "(not estimated)")
    tab$Y <- rev(seq_len(nrow(tab)))
    metric_txt <- if (!is.null(x$population)) "native relative-slope metric" else "fixed N(0,1) ability units"
    xlab <- if (all(tab$scale == "ratio")) {
      "Posterior slope ratio"
    } else {
      paste0("Posterior contrast (", metric_txt, ")")
    }
    interval_type_txt <- "equal-tailed posterior credible interval for varying contrasts"
  } else {
    tab <- x$parameters[x$parameters$quantity == quantity, , drop = FALSE]
    if (!is.null(facet)) {
      if (!is.character(facet) || !length(facet) || anyNA(facet) || !all(facet %in% tab$facet))
        stop("`facet` must select existing owners for the selected quantity.", call. = FALSE)
      tab <- tab[tab$facet %in% facet, , drop = FALSE]
    }
    if (!nrow(tab)) stop("No saved parameters match this plot selection.", call. = FALSE)
    tab$Display <- ifelse(tab$value_role %in% c("fixed_anchor", "fixed_by_constraint"), "Fixed value",
      ifelse(!tab$interval_computed, "Interval unavailable", ifelse(
        tab$sampling_review == "sampling_review_required", "Sampling review required", "No sampling flag")))
    tab$Label <- paste(tab$facet, tab$level, sep = ": ")
    steps <- !is.na(tab$transition)
    tab$Label[steps] <- paste(tab$Label[steps], tab$transition[steps], sep = " | ")
    tab$Label[!is.finite(tab$mean)] <- paste(tab$Label[!is.finite(tab$mean)], "(not estimated)")
    tab$Y <- rev(seq_len(nrow(tab)))
    xlab <- switch(quantity, location = "Location (fixed N(0,1) ability units)",
      ability = "Ability (fixed N(0,1) units)", step_offset = "Step offset (fixed N(0,1) ability units)",
      slope = "Component discrimination", log_slope = "Log component discrimination",
      population_mean = "Population mean (native relative-slope metric)",
      population_sd = "Population SD (native relative-slope metric)")
    if (!is.null(x$population)) xlab <- sub("fixed N(0,1) ability units",
      "native relative-slope metric", sub("fixed N(0,1) units", "native relative-slope metric", xlab, fixed = TRUE), fixed = TRUE)
    interval_type_txt <- x$interval
  }

  draws_df <- NULL
  if (identical(view, "draws")) {
    src_arr <- if (identical(quantity, "contrast")) x$contrast_draws$array else x$draws$array
    id_col <- if (identical(quantity, "contrast")) tab$contrast_id else tab$variable
    sub_arr <- src_arr[, , id_col, drop = FALSE]
    n_iter <- dim(sub_arr)[1L]
    n_chain <- dim(sub_arr)[2L]
    n_per <- n_iter * n_chain
    draws_df <- data.frame(
      id = rep(id_col, each = n_per),
      Label = rep(tab$Label, each = n_per),
      Display = rep(tab$Display, each = n_per),
      Y = rep(tab$Y, each = n_per),
      chain = rep(rep(seq_len(n_chain), each = n_iter), times = nrow(tab)),
      iteration = rep(rep(seq_len(n_iter), times = n_chain), times = nrow(tab)),
      value = as.numeric(sub_arr),
      stringsAsFactors = FALSE
    )
  }

  payload <- list(table = tab, source = x$source,
    checks = x$checks, decision = x$decision, notes = x$notes, level = x$level,
    interval_type = interval_type_txt, view = view,
    title = title, subtitle = subtitle, caption = caption,
    xlab = xlab, reference = reference, preset = style$name, show_legend = show_legend)
  if (!is.null(draws_df)) payload$draws <- draws_df
  out <- new_mfrm_plot_data("posterior_intervals", payload)
  .mfrm_finalize_ggplot(out, draw = draw)
}

.mfrm_gg_posterior_intervals <- function(x) {
  .require_mfrmr_ggplot2()
  d <- x$data; tab <- d$table
  style <- resolve_plot_preset(d$preset)
  finite <- tab[is.finite(tab$lower) & is.finite(tab$upper), , drop = FALSE]
  lvl_pct <- format(100 * (d$level %||% 0.95), trim = TRUE)
  leg_lbl <- paste0(lvl_pct, "% credible interval")
  p <- ggplot2::ggplot(tab, ggplot2::aes(x = .data$mean, y = .data$Y))
  if (identical(d$view, "draws") && is.data.frame(d$draws) && nrow(d$draws) > 0L) {
    vary_draws <- d$draws[d$draws$Display != "Fixed value" & is.finite(d$draws$value), , drop = FALSE]
    if (nrow(vary_draws) > 0L) {
      # Retain only rows with non-degenerate spread for violin density slabs.
      spread_by_y <- tapply(vary_draws$value, vary_draws$Y, function(v) diff(range(v)))
      keep_y <- as.numeric(names(spread_by_y)[spread_by_y > 0])
      slab_draws <- vary_draws[vary_draws$Y %in% keep_y, , drop = FALSE]
      if (nrow(slab_draws) > 0L) {
        slab_fill <- if (identical(style$name, "monochrome")) "#94A3B8" else "#309B92"
        p <- p + ggplot2::geom_violin(
          data = slab_draws,
          ggplot2::aes(x = .data$value, y = .data$Y, group = .data$Y),
          orientation = "y", scale = "width", width = 0.55, trim = TRUE,
          fill = slab_fill, alpha = 0.24, color = NA, inherit.aes = FALSE
        )
      }
    }
  }
  p <- p +
    ggplot2::geom_segment(data = finite, ggplot2::aes(x = .data$lower, xend = .data$upper,
      yend = .data$Y, linetype = .data$Display), color = style$accent_primary, linewidth = .8) +
    ggplot2::geom_point(data = tab[is.finite(tab$mean), , drop = FALSE],
      ggplot2::aes(shape = .data$Display), color = style$accent_primary, size = 2.8) +
    ggplot2::scale_shape_manual(limits = unique(tab$Display), values = c("Fixed value" = 5, "Interval unavailable" = 4,
      "Sampling review required" = 1, "No sampling flag" = 16)) +
    ggplot2::scale_linetype_manual(limits = unique(tab$Display), values = c("Fixed value" = "blank", "Interval unavailable" = "blank",
      "Sampling review required" = "dashed", "No sampling flag" = "solid")) +
    ggplot2::scale_y_continuous(breaks = tab$Y, labels = tab$Label, limits = c(.5, nrow(tab) + .5)) +
    ggplot2::labs(shape = leg_lbl, linetype = leg_lbl,
      alt = paste0("Saved posterior means and ", lvl_pct, "% credible intervals. Diamonds indicate fixed values; dashed lines and open circles indicate sampling review. Missing estimates are not replaced by zero.")) + .mfrmr_gg_theme()
  if (!is.null(d$reference)) p <- p + ggplot2::geom_vline(xintercept = d$reference, linetype = "dotted", color = "grey60")
  if (!any(is.finite(c(d$reference, tab$mean, tab$lower, tab$upper))))
    p <- p + ggplot2::scale_x_continuous(limits = c(-1, 1))
  if (!d$show_legend) p <- p + ggplot2::theme(legend.position = "none")
  p <- .mfrmr_gg_labs(p, d, x = d$xlab)
  attr(p, "mfrmr_plot_data") <- x
  p
}
