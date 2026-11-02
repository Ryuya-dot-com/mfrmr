# Unified ggplot2 styling, marginal histograms, composite layouts, and finalizer.

.mfrmr_gg_theme_styled <- function(preset = NULL, base_size = NULL) {
  style <- resolve_plot_preset(preset %||% .mfrm_default_plot_preset())
  if (is.null(base_size)) {
    base_size <- switch(
      style$name,
      compact = 9.8,
      publication = 11.2,
      11
    )
  }
  outer_margin <- if (identical(style$name, "compact")) {
    ggplot2::margin(6, 10, 6, 8)
  } else {
    ggplot2::margin(10, 14, 10, 10)
  }
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = style$background, colour = NA),
      panel.background = ggplot2::element_rect(fill = style$panel_background, colour = NA),
      panel.border = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = style$grid, linewidth = 0.35),
      panel.grid.minor = ggplot2::element_blank(),
      axis.line = ggplot2::element_line(colour = style$axis, linewidth = 0.45, lineend = "square"),
      axis.ticks = ggplot2::element_line(colour = style$axis, linewidth = 0.4),
      axis.ticks.length = grid::unit(3, "pt"),
      axis.title = ggplot2::element_text(
        colour = style$foreground,
        size = base_size * style$label_cex
      ),
      axis.text = ggplot2::element_text(
        colour = style$axis,
        size = base_size * style$axis_cex
      ),
      plot.title = ggplot2::element_text(
        colour = style$foreground,
        face = "bold",
        size = base_size * 1.1,
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        colour = style$neutral,
        size = base_size * 0.92,
        margin = ggplot2::margin(b = 6)
      ),
      plot.caption = ggplot2::element_text(
        colour = style$neutral,
        size = base_size * 0.84,
        hjust = 0,
        margin = ggplot2::margin(t = 6)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      strip.background = ggplot2::element_rect(fill = style$strip_background, colour = NA),
      strip.text = ggplot2::element_text(
        colour = style$foreground,
        face = "bold",
        size = base_size * 0.92
      ),
      legend.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      legend.title = ggplot2::element_text(
        colour = style$foreground,
        face = "bold",
        size = base_size * 0.9
      ),
      legend.text = ggplot2::element_text(
        colour = style$axis,
        size = base_size * 0.88
      ),
      plot.margin = outer_margin
    )
}

.mfrmr_empty_ggplot <- function(message = "No plottable finite values available.",
                                payload = list(),
                                preset = NULL,
                                xlab = NULL,
                                ylab = NULL) {
  style <- resolve_plot_preset(preset %||% payload$preset %||% .mfrm_default_plot_preset())
  df <- data.frame(x = 0, y = 0, label = as.character(message)[1L], stringsAsFactors = FALSE)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$x, y = .data$y)) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$label),
      colour = style$neutral,
      size = 3.5
    ) +
    ggplot2::scale_x_continuous(breaks = NULL, limits = c(-1, 1)) +
    ggplot2::scale_y_continuous(breaks = NULL, limits = c(-1, 1)) +
    .mfrmr_gg_theme_styled(style$name) +
    ggplot2::theme(
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank()
    )
  .mfrmr_gg_labs(p, payload, x = xlab, y = ylab)
}

.mfrmr_resolve_marginal_arg <- function(marginal = c("auto", "histogram", "none")) {
  if (is.null(marginal)) return("auto")
  if (!is.character(marginal) || length(marginal) < 1L || is.na(marginal[1L])) {
    stop("`marginal` must be one of: auto, histogram, none.", call. = FALSE)
  }
  if (length(marginal) > 1L) marginal <- marginal[1L]
  match.arg(marginal, c("auto", "histogram", "none"))
}

.mfrmr_hist_bins_1d <- function(vals, n_bins) {
  empty <- data.frame(
    Bin = integer(),
    Lower = numeric(),
    Upper = numeric(),
    Midpoint = numeric(),
    Count = integer(),
    Density = numeric(),
    stringsAsFactors = FALSE
  )
  vals <- vals[is.finite(vals)]
  if (length(vals) == 0L || n_bins < 1L) return(empty)
  rng <- range(vals)
  span <- diff(rng)
  if (!is.finite(span) || span <= .Machine$double.eps * max(1, max(abs(rng)))) {
    rng <- rng + c(-0.5, 0.5)
  }
  brks <- seq(rng[1L], rng[2L], length.out = as.integer(n_bins) + 1L)
  h <- graphics::hist(vals, breaks = brks, plot = FALSE, include.lowest = TRUE, right = TRUE)
  data.frame(
    Bin = seq_along(h$counts),
    Lower = as.numeric(brks[-length(brks)]),
    Upper = as.numeric(brks[-1L]),
    Midpoint = as.numeric(h$mids),
    Count = as.integer(h$counts),
    Density = as.numeric(h$density),
    stringsAsFactors = FALSE
  )
}

.mfrmr_compute_marginal_bins <- function(x,
                                         y,
                                         marginal = c("auto", "histogram", "none"),
                                         min_n = 8L,
                                         single_panel = TRUE,
                                         min_bins = 5L,
                                         max_bins = 20L) {
  mode <- .mfrmr_resolve_marginal_arg(marginal)
  x_num <- suppressWarnings(as.numeric(x))
  y_num <- suppressWarnings(as.numeric(y))
  n_len <- min(length(x_num), length(y_num))
  if (n_len > 0L) {
    x_num <- x_num[seq_len(n_len)]
    y_num <- y_num[seq_len(n_len)]
    ok <- is.finite(x_num) & is.finite(y_num)
    xf <- x_num[ok]
    yf <- y_num[ok]
  } else {
    xf <- numeric()
    yf <- numeric()
  }
  n_complete <- length(xf)
  enabled <- switch(
    mode,
    none = FALSE,
    auto = isTRUE(single_panel) && n_complete >= as.integer(min_n),
    histogram = isTRUE(single_panel) && n_complete >= 2L
  )
  n_bins <- if (n_complete > 0L) {
    min(as.integer(max_bins), max(as.integer(min_bins), as.integer(sqrt(n_complete))))
  } else {
    0L
  }
  list(
    mode = mode,
    enabled = isTRUE(enabled),
    single_panel = isTRUE(single_panel),
    n_complete = as.integer(n_complete),
    n_bins = as.integer(n_bins),
    x_bins = .mfrmr_hist_bins_1d(xf, max(1L, n_bins)),
    y_bins = .mfrmr_hist_bins_1d(yf, max(1L, n_bins))
  )
}

.mfrmr_extract_panel_range <- function(range_entry, axis = c("x", "y")) {
  axis <- match.arg(axis)
  direct <- range_entry[[paste0(axis, ".range")]]
  if (is.numeric(direct) && length(direct) == 2L && all(is.finite(direct))) {
    return(direct)
  }
  nested <- range_entry[[axis]]$range
  if (is.numeric(nested) && length(nested) == 2L && all(is.finite(nested))) {
    return(nested)
  }
  NULL
}

.mfrmr_build_marginal_top_grob <- function(bins, xr, params) {
  if (!is.data.frame(bins) || nrow(bins) == 0L || is.null(xr) || diff(xr) <= 0) {
    return(grid::nullGrob())
  }
  max_c <- max(bins$Count, na.rm = TRUE)
  if (!is.finite(max_c) || max_c <= 0) return(grid::nullGrob())
  keep <- bins$Count > 0L & bins$Upper > xr[1L] & bins$Lower < xr[2L]
  bg_grob <- grid::rectGrob(
    x = grid::unit(0.5, "npc"),
    y = grid::unit(0.5, "npc"),
    width = grid::unit(1, "npc"),
    height = grid::unit(1, "npc"),
    gp = grid::gpar(fill = params$bg %||% "#F8FAFC", col = NA)
  )
  base_grob <- grid::segmentsGrob(
    x0 = grid::unit(0, "npc"),
    y0 = grid::unit(0, "npc"),
    x1 = grid::unit(1, "npc"),
    y1 = grid::unit(0, "npc"),
    gp = grid::gpar(col = params$baseline %||% "#334155", lwd = 0.6)
  )
  if (!any(keep)) return(grid::grobTree(bg_grob, base_grob))
  b <- bins[keep, , drop = FALSE]
  x0 <- pmax(0, pmin(1, (b$Lower - xr[1L]) / diff(xr)))
  x1 <- pmax(0, pmin(1, (b$Upper - xr[1L]) / diff(xr)))
  w <- pmax(1e-4, x1 - x0)
  h <- pmax(0.03, 0.88 * (b$Count / max_c))
  bars_grob <- grid::rectGrob(
    x = grid::unit((x0 + x1) / 2, "npc"),
    y = grid::unit(0, "npc"),
    width = grid::unit(w, "npc"),
    height = grid::unit(h, "npc"),
    just = c("centre", "bottom"),
    gp = grid::gpar(
      fill = grDevices::adjustcolor(params$fill %||% "#309B92", alpha.f = params$alpha %||% 0.78),
      col = params$border %||% "#FFFFFF",
      lwd = 0.5
    )
  )
  grid::grobTree(bg_grob, bars_grob, base_grob)
}

.mfrmr_build_marginal_right_grob <- function(bins, yr, params) {
  if (!is.data.frame(bins) || nrow(bins) == 0L || is.null(yr) || diff(yr) <= 0) {
    return(grid::nullGrob())
  }
  max_c <- max(bins$Count, na.rm = TRUE)
  if (!is.finite(max_c) || max_c <= 0) return(grid::nullGrob())
  keep <- bins$Count > 0L & bins$Upper > yr[1L] & bins$Lower < yr[2L]
  bg_grob <- grid::rectGrob(
    x = grid::unit(0.5, "npc"),
    y = grid::unit(0.5, "npc"),
    width = grid::unit(1, "npc"),
    height = grid::unit(1, "npc"),
    gp = grid::gpar(fill = params$bg %||% "#F8FAFC", col = NA)
  )
  base_grob <- grid::segmentsGrob(
    x0 = grid::unit(0, "npc"),
    y0 = grid::unit(0, "npc"),
    x1 = grid::unit(0, "npc"),
    y1 = grid::unit(1, "npc"),
    gp = grid::gpar(col = params$baseline %||% "#334155", lwd = 0.6)
  )
  if (!any(keep)) return(grid::grobTree(bg_grob, base_grob))
  b <- bins[keep, , drop = FALSE]
  y0 <- pmax(0, pmin(1, (b$Lower - yr[1L]) / diff(yr)))
  y1 <- pmax(0, pmin(1, (b$Upper - yr[1L]) / diff(yr)))
  h <- pmax(1e-4, y1 - y0)
  w <- pmax(0.03, 0.88 * (b$Count / max_c))
  bars_grob <- grid::rectGrob(
    x = grid::unit(0, "npc"),
    y = grid::unit((y0 + y1) / 2, "npc"),
    width = grid::unit(w, "npc"),
    height = grid::unit(h, "npc"),
    just = c("left", "centre"),
    gp = grid::gpar(
      fill = grDevices::adjustcolor(params$fill %||% "#309B92", alpha.f = params$alpha %||% 0.78),
      col = params$border %||% "#FFFFFF",
      lwd = 0.5
    )
  )
  grid::grobTree(bg_grob, bars_grob, base_grob)
}

FacetMarginalHist <- ggplot2::ggproto(
  "FacetMarginalHist",
  ggplot2::FacetNull,
  draw_panels = function(self, panels, layout, x_scales, y_scales, ranges, coord, data, theme, params) {
    gt <- ggplot2::ggproto_parent(ggplot2::FacetNull, self)$draw_panels(
      panels, layout, x_scales, y_scales, ranges, coord, data, theme, params
    )
    panel_idx <- which(gt$layout$name == "panel")
    if (length(panel_idx) != 1L || length(ranges) < 1L) return(gt)
    xr <- .mfrmr_extract_panel_range(ranges[[1L]], "x")
    yr <- .mfrmr_extract_panel_range(ranges[[1L]], "y")
    if (is.null(xr) || is.null(yr)) return(gt)

    top_grob <- .mfrmr_build_marginal_top_grob(params$x_bins, xr, params)
    right_grob <- .mfrmr_build_marginal_right_grob(params$y_bins, yr, params)
    strip_size <- params$strip_size %||% grid::unit(0.56, "inches")
    gap_size <- grid::unit(3, "pt")

    p_top <- gt$layout$t[panel_idx]
    p_left <- gt$layout$l[panel_idx]
    p_right <- gt$layout$r[panel_idx]

    gt <- gtable::gtable_add_rows(gt, heights = gap_size, pos = p_top - 1L)
    gt <- gtable::gtable_add_rows(gt, heights = strip_size, pos = p_top - 1L)
    gt <- gtable::gtable_add_grob(
      gt,
      top_grob,
      t = p_top,
      l = p_left,
      r = p_right,
      clip = "on",
      name = "marginal-hist-x"
    )

    panel_idx2 <- which(gt$layout$name == "panel")[1L]
    p_top2 <- gt$layout$t[panel_idx2]
    p_bottom2 <- gt$layout$b[panel_idx2]
    p_right2 <- gt$layout$r[panel_idx2]

    gt <- gtable::gtable_add_cols(gt, widths = gap_size, pos = p_right2)
    gt <- gtable::gtable_add_cols(gt, widths = strip_size, pos = p_right2 + 1L)
    gt <- gtable::gtable_add_grob(
      gt,
      right_grob,
      t = p_top2,
      b = p_bottom2,
      l = p_right2 + 2L,
      r = p_right2 + 2L,
      clip = "on",
      name = "marginal-hist-y"
    )
    gt
  }
)

.mfrmr_attach_marginal_histograms <- function(p,
                                              x = NULL,
                                              y = NULL,
                                              marginal = "auto",
                                              preset = NULL,
                                              min_n = 8L,
                                              single_panel = TRUE,
                                              hist_info = NULL) {
  if (!inherits(p, "ggplot")) return(p)
  if (!inherits(p$facet, "FacetNull")) single_panel <- FALSE
  info <- hist_info %||% .mfrmr_compute_marginal_bins(
    x = x,
    y = y,
    marginal = marginal,
    min_n = min_n,
    single_panel = single_panel
  )
  attr(p, "mfrmr_marginal_histograms") <- info
  if (!isTRUE(info$enabled)) return(p)

  style <- resolve_plot_preset(preset %||% .mfrm_default_plot_preset())
  strip_size <- if (identical(style$name, "compact")) {
    grid::unit(0.42, "inches")
  } else {
    grid::unit(0.56, "inches")
  }
  p <- p + ggplot2::ggproto(
    NULL,
    FacetMarginalHist,
    shrink = TRUE,
    params = list(
      x_bins = info$x_bins,
      y_bins = info$y_bins,
      fill = style$hist_fill,
      border = "#FFFFFF",
      baseline = style$axis,
      bg = style$panel_background,
      alpha = if (identical(style$name, "monochrome")) 0.85 else 0.78,
      strip_size = strip_size
    )
  )
  attr(p, "mfrmr_marginal_histograms") <- info
  p
}

.mfrm_clone_ggplot_for_print <- function(g) {
  if (!inherits(g, "ggplot")) return(g)
  g_copy <- g
  if (!is.null(g_copy$layers)) {
    g_copy$layers <- lapply(g_copy$layers, function(ly) {
      if (!is.environment(ly)) return(ly)
      ly2 <- rlang::env_clone(ly, parent = parent.env(ly))
      class(ly2) <- class(ly)
      if (is.list(ly2$geom_params) && is.list(ly2$geom_params$plots)) {
        gp2 <- ly2$geom_params
        gp2$plots <- lapply(gp2$plots, .mfrm_clone_ggplot_for_print)
        ly2$geom_params <- gp2
      }
      ly2
    })
  }
  if (is.environment(g_copy$scales)) {
    sc2 <- rlang::env_clone(g_copy$scales, parent = parent.env(g_copy$scales))
    class(sc2) <- class(g_copy$scales)
    if (is.list(sc2$scales)) {
      sc2$scales <- lapply(sc2$scales, function(s) {
        if (!is.environment(s)) return(s)
        s2 <- rlang::env_clone(s, parent = parent.env(s))
        class(s2) <- class(s)
        s2
      })
    }
    g_copy$scales <- sc2
  }
  if (is.environment(g_copy$facet)) {
    fc2 <- rlang::env_clone(g_copy$facet, parent = parent.env(g_copy$facet))
    class(fc2) <- class(g_copy$facet)
    g_copy$facet <- fc2
  }
  if (is.environment(g_copy$coordinates)) {
    cd2 <- rlang::env_clone(g_copy$coordinates, parent = parent.env(g_copy$coordinates))
    class(cd2) <- class(g_copy$coordinates)
    g_copy$coordinates <- cd2
  }
  g_copy
}

.mfrm_draw_ggplot_clean <- function(p) {
  print(.mfrm_clone_ggplot_for_print(p))
  invisible(p)
}

GeomCompositePlots <- ggplot2::ggproto(
  "GeomCompositePlots",
  ggplot2::Geom,
  required_aes = c("x", "y"),
  default_aes = ggplot2::aes(),
  draw_panel = function(data, panel_params, coord, plots = list(),
                        ncol = NULL, widths = NULL, heights = NULL) {
    n <- length(plots)
    if (n == 0L) return(grid::nullGrob())
    ncol_g <- max(1L, as.integer(ncol %||% ceiling(sqrt(n))))
    nrow_g <- max(1L, as.integer(ceiling(n / ncol_g)))
    grobs <- lapply(seq_len(nrow_g * ncol_g), function(i) {
      if (i <= n && inherits(plots[[i]], "ggplot")) {
        ggplot2::ggplotGrob(.mfrm_clone_ggplot_for_print(plots[[i]]))
      } else {
        grid::nullGrob()
      }
    })
    mat <- matrix(grobs, nrow = nrow_g, ncol = ncol_g, byrow = TRUE)
    w <- widths %||% rep(1, ncol_g)
    h <- heights %||% rep(1, nrow_g)
    gtable::gtable_matrix(
      "mfrmr_composite",
      mat,
      widths = grid::unit(w, "null"),
      heights = grid::unit(h, "null")
    )
  }
)

.mfrm_compose_ggplots <- function(plots,
                                  ncol = NULL,
                                  widths = NULL,
                                  heights = NULL,
                                  payload = list(),
                                  preset = NULL) {
  style <- resolve_plot_preset(preset %||% payload$preset %||% .mfrm_default_plot_preset())
  anchor_df <- data.frame(x = 0, y = 0)
  p <- ggplot2::ggplot(anchor_df, ggplot2::aes(x = .data$x, y = .data$y)) +
    ggplot2::layer(
      geom = GeomCompositePlots,
      stat = "identity",
      position = "identity",
      data = anchor_df,
      inherit.aes = TRUE,
      params = list(
        plots = plots,
        ncol = ncol,
        widths = widths,
        heights = heights
      ),
      show.legend = FALSE
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = style$background, colour = NA),
      plot.title = ggplot2::element_text(
        colour = style$foreground,
        face = "bold",
        size = 12,
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        colour = style$neutral,
        size = 10,
        margin = ggplot2::margin(b = 6)
      ),
      plot.caption = ggplot2::element_text(
        colour = style$neutral,
        size = 9,
        hjust = 0,
        margin = ggplot2::margin(t = 6)
      ),
      plot.margin = ggplot2::margin(6, 6, 6, 6)
    )
  .mfrmr_gg_labs(p, payload, x = NULL, y = NULL)
}

.mfrm_finalize_ggplot <- function(out, draw = TRUE, builder = NULL, ...) {
  if (!inherits(out, "mfrm_plot_data")) {
    out <- new_mfrm_plot_data("plot", out)
  }
  p <- if (is.function(builder)) {
    builder(out)
  } else {
    as_ggplot.mfrm_plot_data(out, ...)
  }
  attr(p, "mfrmr_plot_data") <- out
  attr(p, "mfrmr_notes") <- .mfrm_plot_annotation_notes(out$data)
  if (isTRUE(draw)) {
    .mfrm_draw_ggplot_clean(p)
  }
  invisible(p)
}
