# Dedicated ggplot2 renderers for network, category, G/D-study, audit, and composite views.

.mfrmr_gg_network_graph <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")
  coords <- as.data.frame(payload$coordinates %||% data.frame(), stringsAsFactors = FALSE)
  nodes <- as.data.frame(payload$nodes %||% data.frame(), stringsAsFactors = FALSE)
  edges <- as.data.frame(payload$edges %||% data.frame(), stringsAsFactors = FALSE)
  if (!nrow(coords) || !all(c("Node", "X", "Y") %in% names(coords))) {
    p <- .mfrmr_empty_ggplot("No network coordinates available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  coords$X <- suppressWarnings(as.numeric(coords$X))
  coords$Y <- suppressWarnings(as.numeric(coords$Y))
  coords <- coords[is.finite(coords$X) & is.finite(coords$Y), , drop = FALSE]

  design <- identical(x$name, "subset_connectivity")
  halo <- identical(x$name, "halo_network")
  id_col <- if (design || halo) "Node" else if ("Rater" %in% names(nodes)) "Rater" else "Node"
  idx_n <- if (id_col %in% names(nodes)) match(coords$Node, as.character(nodes[[id_col]])) else rep(NA_integer_, nrow(coords))
  coords$Group <- if (design && "Facet" %in% names(nodes)) {
    as.character(nodes$Facet[idx_n])
  } else if (halo && "Rater" %in% names(nodes)) {
    as.character(nodes$Rater[idx_n])
  } else {
    rep("Rater", nrow(coords))
  }
  coords$Group[is.na(coords$Group) | !nzchar(coords$Group)] <- "Node"
  coords$DisplayLabel <- if (nrow(coords) > 80L) {
    rep("", nrow(coords))
  } else if (design && "Level" %in% names(nodes)) {
    as.character(nodes$Level[idx_n])
  } else {
    as.character(coords$Node)
  }
  if (is.list(payload$graphical) && "vertex.label" %in% names(payload$graphical)) {
    vl <- payload$graphical[["vertex.label"]]
    if (length(vl) == 0L || all(is.na(vl))) {
      coords$DisplayLabel <- rep("", nrow(coords))
    } else {
      coords$DisplayLabel <- rep(as.character(vl), length.out = nrow(coords))
      coords$DisplayLabel[is.na(coords$DisplayLabel)] <- ""
    }
  }

  leg <- payload$legend
  groups <- unique(coords$Group)
  if (is.data.frame(leg) && nrow(leg) > 0L && all(c("label", "value") %in% names(leg))) {
    group_cols <- stats::setNames(as.character(leg$value), as.character(leg$label))
    missing_g <- setdiff(groups, names(group_cols))
    if (length(missing_g) > 0L) {
      extra <- stats::setNames(rep(style$series, length.out = length(missing_g)), missing_g)
      group_cols <- c(group_cols, extra)
    }
  } else {
    group_cols <- stats::setNames(rep(style$series, length.out = length(groups)), groups)
  }

  p <- ggplot2::ggplot()
  if (nrow(edges) > 0L && all(c("From", "To", "Weight") %in% names(edges))) {
    a <- match(as.character(edges$From), coords$Node)
    b <- match(as.character(edges$To), coords$Node)
    ok_e <- !is.na(a) & !is.na(b) & is.finite(suppressWarnings(as.numeric(edges$Weight))) & a != b
    if (any(ok_e)) {
      edf <- edges[ok_e, , drop = FALSE]
      ia <- a[ok_e]
      ib <- b[ok_e]
      w_abs <- abs(as.numeric(edf$Weight))
      max_w <- max(w_abs, na.rm = TRUE)
      if (!is.finite(max_w) || max_w <= 0) max_w <- 1
      signed <- if ("SignedWeight" %in% names(edf)) suppressWarnings(as.numeric(edf$SignedWeight)) else as.numeric(edf$Weight)
      edf$X0 <- coords$X[ia]
      edf$Y0 <- coords$Y[ia]
      edf$X1 <- coords$X[ib]
      edf$Y1 <- coords$Y[ib]
      edf$LineWidth <- 0.35 + 1.45 * (w_abs / max_w)
      edf$SignGroup <- ifelse(!is.na(signed) & signed < 0, "Negative", "Positive")
      edge_col_map <- if (identical(style$name, "monochrome")) {
        c(Positive = "gray40", Negative = "gray55")
      } else {
        c(Positive = "#64748B", Negative = "#2176AE")
      }
      arrow_spec <- if (isTRUE(payload$directed)) {
        grid::arrow(length = grid::unit(0.08, "inches"), type = "closed")
      } else {
        NULL
      }
      p <- p +
        ggplot2::geom_segment(
          data = edf,
          ggplot2::aes(
            x = .data$X0,
            y = .data$Y0,
            xend = .data$X1,
            yend = .data$Y1,
            linewidth = .data$LineWidth,
            linetype = .data$SignGroup
          ),
          colour = unname(edge_col_map[edf$SignGroup]),
          alpha = 0.72,
          arrow = arrow_spec,
          show.legend = FALSE
        ) +
        ggplot2::scale_linewidth_identity() +
        ggplot2::scale_linetype_manual(values = c(Positive = "solid", Negative = "dashed"), guide = "none")
    }
  }

  coords$GroupFactor <- factor(coords$Group, levels = groups)
  xr <- range(coords$X, finite = TRUE)
  yr <- range(coords$Y, finite = TRUE)
  pad_x <- max(0.28, 0.22 * diff(xr))
  pad_y <- max(0.28, 0.22 * diff(yr))

  pt_size <- if (design) 3.4 else 4.6
  if (is.list(payload$graphical) && is.numeric(payload$graphical[["vertex.size"]]) &&
      length(payload$graphical[["vertex.size"]]) >= 1L &&
      is.finite(payload$graphical[["vertex.size"]][1L]) &&
      payload$graphical[["vertex.size"]][1L] > 0) {
    pt_size <- max(1.5, as.numeric(payload$graphical[["vertex.size"]][1L]) * 0.38)
  }
  p <- p +
    ggplot2::geom_point(
      data = coords,
      ggplot2::aes(x = .data$X, y = .data$Y, fill = .data$GroupFactor),
      shape = 21,
      colour = "#FFFFFF",
      stroke = 0.7,
      size = pt_size
    ) +
    ggplot2::scale_fill_manual(values = group_cols, name = if (design) "Facet" else NULL)

  lbl_df <- coords[nzchar(coords$DisplayLabel), , drop = FALSE]
  if (nrow(lbl_df) > 0L) {
    p <- p + ggplot2::geom_text(
      data = lbl_df,
      ggplot2::aes(x = .data$X, y = .data$Y, label = .data$DisplayLabel),
      vjust = -1.0,
      size = 3.0,
      colour = style$foreground,
      check_overlap = TRUE,
      show.legend = FALSE
    )
  }

  if (length(groups) <= 1L) {
    p <- p + ggplot2::guides(fill = "none")
  }

  p <- p +
    ggplot2::coord_equal(xlim = xr + c(-pad_x, pad_x), ylim = yr + c(-pad_y, pad_y)) +
    .mfrmr_gg_theme_styled(style$name) +
    ggplot2::theme(
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank()
    )
  p <- .mfrmr_gg_labs(p, payload, x = NULL, y = NULL)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_rater_network <- function(x) {
  payload <- x$data
  plot_kind <- as.character(payload$plot %||% "network")[1L]
  if (identical(plot_kind, "network")) return(.mfrmr_gg_network_graph(x))
  if (identical(plot_kind, "matrix") && is.matrix(payload$matrix)) {
    p <- .mfrmr_gg_matrix(payload$matrix, payload)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  style <- resolve_plot_preset(payload$preset %||% "standard")
  tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
  metric <- as.character(payload$metric %||% "Strength")[1L]
  if (!nrow(tbl) || !metric %in% names(tbl)) {
    p <- .mfrmr_empty_ggplot(paste(metric, "unavailable"), payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  tbl$Value <- suppressWarnings(as.numeric(tbl[[metric]]))
  tbl$Row <- seq_len(nrow(tbl))
  tbl$Label <- as.character(tbl$Rater %||% tbl$Node %||% tbl$Row)
  avail <- is.finite(tbl$Value)

  if (!any(avail)) {
    p <- .mfrmr_empty_ggplot(paste(metric, "unavailable"), payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(plot_kind, "severity")) {
    tbl$Fill <- ifelse(
      tbl$Value > 0, style$fail,
      ifelse(tbl$Value < 0, style$accent_tertiary, style$neutral)
    )
  } else {
    tbl$Fill <- style$accent_primary
  }

  p <- ggplot2::ggplot(tbl, ggplot2::aes(x = .data$Value, y = .data$Row))
  if (identical(plot_kind, "severity")) {
    p <- p + ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line)
  }
  p <- p +
    ggplot2::geom_col(
      data = tbl[avail, , drop = FALSE],
      ggplot2::aes(fill = .data$Fill),
      orientation = "y",
      width = 0.65
    ) +
    ggplot2::scale_fill_identity()

  if (all(c("CI_Lower", "CI_Upper") %in% names(tbl))) {
    ci_ok <- avail & is.finite(tbl$CI_Lower) & is.finite(tbl$CI_Upper)
    if (any(ci_ok)) {
      p <- p + ggplot2::geom_segment(
        data = tbl[ci_ok, , drop = FALSE],
        ggplot2::aes(x = .data$CI_Lower, xend = .data$CI_Upper, y = .data$Row, yend = .data$Row),
        colour = style$foreground,
        linewidth = 0.6
      )
    }
  }
  if (any(!avail)) {
    x_mid <- mean(range(tbl$Value[avail], finite = TRUE))
    p <- p + ggplot2::geom_text(
      data = tbl[!avail, , drop = FALSE],
      ggplot2::aes(x = x_mid, y = .data$Row),
      label = "Unavailable",
      colour = style$neutral,
      size = 3,
      inherit.aes = FALSE
    )
  }
  p <- p +
    ggplot2::scale_y_reverse(breaks = tbl$Row, labels = tbl$Label) +
    .mfrmr_gg_theme_styled(style$name)
  p <- .mfrmr_gg_add_references(p, payload$reference_lines)
  xlab <- if (identical(plot_kind, "severity")) "-log(out-strength / in-strength)" else metric
  p <- .mfrmr_gg_labs(p, payload, x = xlab, y = NULL)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_subset_connectivity <- function(x) {
  payload <- x$data
  plot_kind <- as.character(payload$plot %||% "network")[1L]
  if (identical(plot_kind, "network")) return(.mfrmr_gg_network_graph(x))
  style <- resolve_plot_preset(payload$preset %||% "standard")

  if (identical(plot_kind, "coverage_matrix") && is.matrix(payload$matrix)) {
    mat <- payload$matrix
    long <- as.data.frame(as.table(mat), stringsAsFactors = FALSE)
    names(long) <- c("Facet", "Subset", "Coverage")
    long$Coverage <- suppressWarnings(as.numeric(long$Coverage))
    if (is.matrix(payload$labels) && identical(dim(payload$labels), dim(mat))) {
      long$CellLabel <- as.character(as.data.frame(as.table(payload$labels), stringsAsFactors = FALSE)$Freq)
    } else {
      long$CellLabel <- ifelse(is.finite(long$Coverage), sprintf("%.0f%%", 100 * long$Coverage), "")
    }
    long$Facet <- factor(long$Facet, levels = rev(rownames(mat)))
    long$Subset <- factor(long$Subset, levels = colnames(mat))
    p_cov <- ggplot2::ggplot(long, ggplot2::aes(x = .data$Subset, y = .data$Facet, fill = .data$Coverage)) +
      ggplot2::geom_tile(colour = "#FFFFFF", linewidth = 0.4) +
      ggplot2::geom_text(
        ggplot2::aes(label = .data$CellLabel),
        size = 3.0,
        colour = ifelse(is.finite(long$Coverage) & long$Coverage >= 0.65, "#FFFFFF", style$foreground)
      ) +
      ggplot2::scale_fill_gradient(
        low = style$fill_soft,
        high = style$accent_primary,
        limits = c(0, 1),
        na.value = style$missing,
        name = "Coverage"
      ) +
      .mfrmr_gg_theme_styled(style$name) +
      ggplot2::theme(panel.grid.major = ggplot2::element_blank()) +
      ggplot2::labs(x = "Connected subset", y = "Facet")

    sub_sum <- as.data.frame(payload$subset_summary %||% data.frame(), stringsAsFactors = FALSE)
    pct_col <- intersect(c("ObservationPercent", "Share"), names(sub_sum))[1L]
    if (nrow(sub_sum) > 0L && "Subset" %in% names(sub_sum) && !is.na(pct_col)) {
      sub_sum$SubsetLabel <- as.character(sub_sum$Subset)
      if (!all(sub_sum$SubsetLabel %in% colnames(mat)) && all(paste0("S", sub_sum$Subset) %in% colnames(mat))) {
        sub_sum$SubsetLabel <- paste0("S", sub_sum$Subset)
      }
      sub_sum$SubsetFactor <- factor(sub_sum$SubsetLabel, levels = colnames(mat))
      raw_pct <- suppressWarnings(as.numeric(sub_sum[[pct_col]]))
      sub_sum$Pct <- if (identical(pct_col, "Share")) 100 * raw_pct else raw_pct
      p_top <- ggplot2::ggplot(
        sub_sum[is.finite(sub_sum$Pct) & !is.na(sub_sum$SubsetFactor), , drop = FALSE],
        ggplot2::aes(x = .data$SubsetFactor, y = .data$Pct)
      ) +
        ggplot2::geom_col(fill = style$accent_tertiary, width = 0.62) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::labs(x = NULL, y = "Obs. share (%)")
      p <- .mfrm_compose_ggplots(list(p_top, p_cov), ncol = 1L, heights = c(1, 2.2), payload = payload, preset = style$name)
    } else {
      p <- .mfrmr_gg_labs(p_cov, payload, x = "Connected subset", y = "Facet")
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
  if (!nrow(tbl)) {
    p <- .mfrmr_empty_ggplot("No subset connectivity rows available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  if (identical(plot_kind, "subset_observations")) {
    tbl$Label <- paste0("Subset ", tbl$Subset)
    tbl$Value <- suppressWarnings(as.numeric(tbl$Observations))
    ylab <- "Observations"
  } else {
    tbl$Label <- paste0("S", tbl$Subset, ": ", tbl$Facet)
    tbl$Value <- suppressWarnings(as.numeric(tbl$LevelsN))
    ylab <- "Observed levels"
  }
  tbl$Pos <- seq_len(nrow(tbl))
  p <- ggplot2::ggplot(tbl[is.finite(tbl$Value), , drop = FALSE], ggplot2::aes(x = .data$Pos, y = .data$Value)) +
    ggplot2::geom_col(fill = style$accent_primary, width = 0.68) +
    ggplot2::scale_x_continuous(breaks = tbl$Pos, labels = tbl$Label) +
    .mfrmr_gg_theme_styled(style$name) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
  p <- .mfrmr_gg_labs(p, payload, x = NULL, y = ylab)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_residual_network <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")
  view_type <- as.character(payload$type %||% "network")[1L]

  if (identical(view_type, "dendrogram")) {
    tree <- payload$clustering$tree
    if (is.null(tree)) {
      p <- .mfrmr_empty_ggplot("No clustering tree available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    hc <- stats::as.hclust(tree)
    n_leaves <- length(hc$order)
    if (n_leaves < 2L) {
      p <- .mfrmr_empty_ggplot("At least two leaves required for dendrogram.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    mem <- payload$clustering$membership
    orig_labels <- as.character(hc$labels %||% seq_len(n_leaves))
    leaf_labels <- orig_labels
    if (!is.null(mem) && length(leaf_labels) > 0L) {
      leaf_labels <- paste0(leaf_labels, " [", unname(mem[orig_labels]), "]")
    }
    leaf_y <- n_leaves + 1L - match(seq_len(n_leaves), hc$order)
    node_y <- numeric(n_leaves - 1L)
    segs <- matrix(NA_real_, 3L * (n_leaves - 1L), 4L, dimnames = list(NULL, c("X", "Y", "Xend", "Yend")))
    for (i in seq_len(n_leaves - 1L)) {
      ch <- hc$merge[i, ]
      xx <- yy <- numeric(2L)
      for (j in 1:2) {
        yy[j] <- if (ch[j] < 0L) leaf_y[-ch[j]] else node_y[ch[j]]
        xx[j] <- if (ch[j] < 0L) 0 else hc$height[ch[j]]
      }
      node_y[i] <- mean(yy)
      segs[3L * (i - 1L) + 1:3, ] <- rbind(
        c(xx[1L], yy[1L], hc$height[i], yy[1L]),
        c(xx[2L], yy[2L], hc$height[i], yy[2L]),
        c(hc$height[i], yy[1L], hc$height[i], yy[2L])
      )
    }
    p <- ggplot2::ggplot(as.data.frame(segs)) +
      ggplot2::geom_segment(
        ggplot2::aes(x = .data$X, y = .data$Y, xend = .data$Xend, yend = .data$Yend),
        colour = style$foreground,
        linewidth = 0.5
      ) +
      ggplot2::scale_y_continuous(
        breaks = leaf_y,
        labels = leaf_labels,
        position = "right"
      ) +
      .mfrmr_gg_theme_styled(style$name) +
      ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
    p <- .mfrmr_gg_labs(
      p,
      payload,
      x = paste(payload$settings$Linkage %||% "Average", "linkage distance"),
      y = NULL
    )
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  lay <- as.data.frame(payload$layout %||% data.frame(), stringsAsFactors = FALSE)
  edges <- as.data.frame(payload$edges %||% data.frame(), stringsAsFactors = FALSE)
  if (!nrow(lay) || !all(c("Level", "X", "Y") %in% names(lay))) {
    p <- .mfrmr_empty_ggplot("No residual network nodes available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  p <- ggplot2::ggplot()
  if (nrow(edges) > 0L && all(c("Level1", "Level2", "ResidualCor") %in% names(edges))) {
    a <- match(edges$Level1, lay$Level)
    b <- match(edges$Level2, lay$Level)
    ok <- !is.na(a) & !is.na(b) & is.finite(edges$ResidualCor)
    if (any(ok)) {
      edf <- edges[ok, , drop = FALSE]
      edf$X0 <- lay$X[a[ok]]
      edf$Y0 <- lay$Y[a[ok]]
      edf$X1 <- lay$X[b[ok]]
      edf$Y1 <- lay$Y[b[ok]]
      edf$Sign <- factor(ifelse(edf$ResidualCor >= 0, "Positive", "Negative"), levels = c("Positive", "Negative"))
      edf$LW <- 0.4 + 2.0 * abs(edf$ResidualCor)
      cols <- if (identical(style$name, "monochrome")) {
        c(Positive = "gray30", Negative = "gray50")
      } else {
        c(Positive = "#B83230", Negative = "#2176AE")
      }
      p <- p +
        ggplot2::geom_segment(
          data = edf,
          ggplot2::aes(
            x = .data$X0, y = .data$Y0, xend = .data$X1, yend = .data$Y1,
            colour = .data$Sign, linetype = .data$Sign, linewidth = .data$LW
          ),
          alpha = 0.8
        ) +
        ggplot2::scale_colour_manual(values = cols, name = "Association") +
        ggplot2::scale_linetype_manual(values = c(Positive = "solid", Negative = "dashed"), name = "Association") +
        ggplot2::scale_linewidth_identity()
    }
  }
  lay$LabelX <- lay$X * 1.15
  lay$LabelY <- lay$Y * 1.15
  p <- p +
    ggplot2::geom_point(
      data = lay,
      ggplot2::aes(x = .data$X, y = .data$Y),
      shape = 21,
      fill = "#FFFFFF",
      colour = style$foreground,
      stroke = 0.8,
      size = 4.2
    ) +
    ggplot2::geom_text(
      data = lay,
      ggplot2::aes(x = .data$LabelX, y = .data$LabelY, label = .data$Level),
      size = 3.1,
      colour = style$foreground
    ) +
    ggplot2::coord_equal(xlim = c(-1.55, 1.55), ylim = c(-1.45, 1.45)) +
    .mfrmr_gg_theme_styled(style$name) +
    ggplot2::theme(
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      legend.position = "top"
    )
  p <- .mfrmr_gg_labs(p, payload, x = NULL, y = NULL)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_network_ergm <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")
  view_type <- as.character(payload$plot %||% "coefficients")[1L]
  tab <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)

  if (identical(view_type, "gof")) {
    draws <- as.data.frame(payload$draws %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(draws) > 0L && all(c("Statistic", "Category", "Simulated") %in% names(draws))) {
      draws$Label <- paste(draws$Statistic, draws$Category, sep = ": ")
      draws_ok <- draws[is.finite(draws$Simulated), , drop = FALSE]
      p <- ggplot2::ggplot(draws_ok, ggplot2::aes(x = .data$Label, y = .data$Simulated)) +
        ggplot2::geom_boxplot(fill = style$fill_soft, colour = style$axis, outlier.size = 1.2)
      if (nrow(tab) > 0L && all(c("Statistic", "Category", "Observed") %in% names(tab))) {
        tab$Label <- paste(tab$Statistic, tab$Category, sep = ": ")
        obs_ok <- tab[is.finite(tab$Observed), , drop = FALSE]
        p <- p + ggplot2::geom_point(
          data = obs_ok,
          ggplot2::aes(x = .data$Label, y = .data$Observed),
          colour = style$fail,
          shape = 18,
          size = 3.2,
          inherit.aes = FALSE
        )
      }
      p <- p +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
      p <- .mfrmr_gg_labs(p, payload, x = "Network statistic", y = "Simulated vs observed count")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (nrow(tab) > 0L && all(c("Observed", "SimMean") %in% names(tab))) {
      tab$Row <- seq_len(nrow(tab))
      tab$Label <- if (all(c("Statistic", "Category") %in% names(tab))) {
        paste(tab$Statistic, tab$Category, sep = ": ")
      } else {
        as.character(tab$Row)
      }
      p <- ggplot2::ggplot(tab, ggplot2::aes(y = .data$Row)) +
        ggplot2::geom_point(
          data = tab[is.finite(tab$SimMean), , drop = FALSE],
          ggplot2::aes(x = .data$SimMean),
          colour = style$accent_primary,
          size = 2.6
        ) +
        ggplot2::geom_point(
          data = tab[is.finite(tab$Observed), , drop = FALSE],
          ggplot2::aes(x = .data$Observed),
          colour = style$fail,
          shape = 18,
          size = 3.2
        ) +
        ggplot2::scale_y_reverse(breaks = tab$Row, labels = tab$Label) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Statistic value", y = NULL)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    p <- .mfrmr_empty_ggplot("No ERGM goodness-of-fit draws available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  keep <- is.finite(tab$Estimate) & is.finite(tab$Lower) & is.finite(tab$Upper)
  z <- tab[keep, , drop = FALSE]
  if (!nrow(z)) {
    p <- .mfrmr_empty_ggplot("No finite ERGM coefficient intervals available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  z$Row <- seq_len(nrow(z))
  p <- ggplot2::ggplot(z, ggplot2::aes(x = .data$Estimate, y = .data$Row)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line) +
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$Lower, xend = .data$Upper, yend = .data$Row),
      colour = style$accent_primary,
      linewidth = 0.7
    ) +
    ggplot2::geom_point(colour = style$accent_primary, size = 2.8) +
    ggplot2::scale_y_reverse(breaks = z$Row, labels = z$Term) +
    .mfrmr_gg_theme_styled(style$name)
  p <- .mfrmr_gg_labs(p, payload, x = "Conditional log-odds coefficient", y = NULL)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_category_extended <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")

  if (identical(x$name, "threshold_ladder")) {
    df <- as.data.frame(payload$data %||% data.frame(), stringsAsFactors = FALSE)
    df$CurveGroup <- df$Group %||% df$CurveGroup
    df$Estimate <- df$Threshold %||% df$Estimate
    if (!nrow(df) || !all(c("CurveGroup", "Step", "Estimate") %in% names(df))) {
      p <- .mfrmr_empty_ggplot("No step thresholds available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    groups <- unique(as.character(df$CurveGroup))
    df$GroupPos <- match(as.character(df$CurveGroup), groups)
    df$Estimate <- suppressWarnings(as.numeric(df$Estimate))

    seg_list <- lapply(seq_along(groups), function(gi) {
      sub <- df[df$GroupPos == gi, , drop = FALSE]
      if (nrow(sub) < 2L) return(NULL)
      rows <- list()
      for (k in seq_len(nrow(sub) - 1L)) {
        y0 <- sub$Estimate[k]
        y1 <- sub$Estimate[k + 1L]
        adjacent <- !"StepIndex" %in% names(sub) ||
          isTRUE(sub$StepIndex[k + 1L] == sub$StepIndex[k] + 1L)
        if (adjacent && is.finite(y0) && is.finite(y1)) {
          rows[[length(rows) + 1L]] <- data.frame(
            GroupPos = gi,
            Y0 = y0,
            Y1 = y1,
            Disordered = y1 < y0,
            stringsAsFactors = FALSE
          )
        }
      }
      if (length(rows)) do.call(rbind, rows) else NULL
    })
    segs <- do.call(rbind, seg_list[!vapply(seg_list, is.null, logical(1))])
    fin_df <- df[is.finite(df$Estimate), , drop = FALSE]
    miss_df <- df[!is.finite(df$Estimate), , drop = FALSE]

    p <- ggplot2::ggplot() +
      ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = style$ref_line)
    if (!is.null(segs) && nrow(segs) > 0L) {
      segs$Status <- ifelse(segs$Disordered, "Disordered crossing", "Ordered step")
      # Overlapping ordered connections must not cover a disordered crossing.
      segs <- segs[order(segs$Disordered), , drop = FALSE]
      highlight <- isTRUE(payload$highlight_disorder %||% TRUE)
      p <- p +
        ggplot2::geom_segment(
          data = segs,
          ggplot2::aes(
            x = .data$GroupPos, xend = .data$GroupPos,
            y = .data$Y0, yend = .data$Y1,
            colour = .data$Status
          ),
          linewidth = 0.9
        ) +
        ggplot2::scale_colour_manual(
          values = c(`Ordered step` = style$accent_primary,
            `Disordered crossing` = if (highlight) style$fail else style$accent_primary),
          name = NULL, guide = if (highlight) "legend" else "none"
        )
    }
    if (nrow(fin_df) > 0L) {
      p <- p +
        ggplot2::geom_point(
          data = fin_df,
          ggplot2::aes(x = .data$GroupPos, y = .data$Estimate),
          colour = style$accent_primary,
          size = 2.6
        ) +
        ggplot2::geom_text(
          data = fin_df,
          ggplot2::aes(x = .data$GroupPos + 0.08, y = .data$Estimate, label = .data$Step),
          hjust = 0,
          size = 2.8,
          colour = style$foreground,
          check_overlap = TRUE
        )
    }
    if (nrow(miss_df) > 0L) {
      y_mid <- if (nrow(fin_df) > 0L) mean(range(fin_df$Estimate)) else 0
      miss_agg <- stats::aggregate(Step ~ GroupPos, data = miss_df, FUN = function(s) paste(c(s, "unavailable"), collapse = " "))
      p <- p + ggplot2::geom_text(
        data = miss_agg,
        ggplot2::aes(x = .data$GroupPos, y = y_mid, label = .data$Step),
        size = 2.6,
        colour = style$neutral
      )
    }
    p <- p +
      ggplot2::scale_x_continuous(
        breaks = seq_along(groups),
        labels = groups,
        limits = c(0.5, length(groups) + 0.55)
      ) +
      .mfrmr_gg_theme_styled(style$name)
    p <- .mfrmr_gg_labs(p, payload, x = "Step owner / curve group", y = "Step threshold (logits)")
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(x$name, "category_structure") && !identical(payload$plot, "counts")) {
    mode_tbl <- as.data.frame(payload$mode_boundaries %||% data.frame(), stringsAsFactors = FALSE)
    half_tbl <- as.data.frame(payload$mean_halfscore_points %||% data.frame(), stringsAsFactors = FALSE)
    pts <- list()
    if (!identical(payload$plot, "mean_halfscore") &&
        nrow(mode_tbl) > 0L && "ModeBoundaryTheta" %in% names(mode_tbl)) {
      grp <- if ("CurveGroup" %in% names(mode_tbl)) as.character(mode_tbl$CurveGroup) else rep("Common", nrow(mode_tbl))
      pts[[length(pts) + 1L]] <- data.frame(
        Group = grp,
        Theta = suppressWarnings(as.numeric(mode_tbl$ModeBoundaryTheta)),
        Kind = "Mode boundary",
        stringsAsFactors = FALSE
      )
    }
    if (!identical(payload$plot, "mode_boundaries") &&
        nrow(half_tbl) > 0L && "MeanBoundaryTheta" %in% names(half_tbl)) {
      grp <- if ("CurveGroup" %in% names(half_tbl)) as.character(half_tbl$CurveGroup) else rep("Common", nrow(half_tbl))
      pts[[length(pts) + 1L]] <- data.frame(
        Group = grp,
        Theta = suppressWarnings(as.numeric(half_tbl$MeanBoundaryTheta)),
        Kind = "Half-score point",
        stringsAsFactors = FALSE
      )
    }
    comb <- if (length(pts)) do.call(rbind, pts) else data.frame()
    comb <- comb[is.finite(comb$Theta), , drop = FALSE]
    if (!nrow(comb)) {
      p <- .mfrmr_empty_ggplot("No finite category boundaries available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    comb$Group <- factor(comb$Group, levels = rev(unique(comb$Group)))
    p <- ggplot2::ggplot(comb, ggplot2::aes(x = .data$Theta, y = .data$Group, colour = .data$Kind, shape = .data$Kind)) +
      ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line) +
      ggplot2::geom_point(size = 2.8, alpha = 0.88) +
      ggplot2::scale_colour_manual(values = c(`Mode boundary` = style$accent_primary, `Half-score point` = style$accent_secondary), name = NULL) +
      ggplot2::scale_shape_manual(values = c(`Mode boundary` = 16, `Half-score point` = 17), name = NULL) +
      .mfrmr_gg_theme_styled(style$name)
    if (length(unique(comb$Kind)) <= 1L) p <- p + ggplot2::guides(colour = "none", shape = "none")
    p <- .mfrmr_gg_labs(p, payload, x = "Ability / propensity (logits)", y = NULL)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  # category_curves
  build_one_curve_panel <- function(df_panel, ylab, panel_title = NULL) {
    df_panel <- as.data.frame(df_panel %||% data.frame(), stringsAsFactors = FALSE)
    df_panel <- df_panel[is.finite(df_panel$Theta) & is.finite(df_panel$Value), , drop = FALSE]
    if (!nrow(df_panel)) {
      return(.mfrmr_empty_ggplot("No curve values available.", preset = style$name))
    }
    series_col <- if ("Series" %in% names(df_panel)) "Series" else if ("Category" %in% names(df_panel)) "Category" else NULL
    if (is.null(series_col)) {
      df_panel$SeriesKey <- "Curve"
    } else {
      df_panel$SeriesKey <- as.character(df_panel[[series_col]])
    }
    s_levels <- unique(df_panel$SeriesKey)
    df_panel$SeriesFactor <- factor(df_panel$SeriesKey, levels = s_levels)
    cols <- stats::setNames(rep(style$series, length.out = length(s_levels)), s_levels)
    p_sub <- ggplot2::ggplot(
      df_panel,
      ggplot2::aes(
        x = .data$Theta,
        y = .data$Value,
        colour = .data$SeriesFactor,
        group = interaction(.data$SeriesFactor, .data$CurveGroup %||% "1", drop = TRUE)
      )
    ) +
      ggplot2::geom_line(linewidth = 0.78) +
      ggplot2::scale_colour_manual(values = cols, name = NULL) +
      .mfrmr_gg_theme_styled(style$name)
    if (length(s_levels) <= 1L) p_sub <- p_sub + ggplot2::guides(colour = "none")
    if (!is.null(panel_title)) {
      p_sub <- p_sub + ggplot2::labs(subtitle = panel_title, x = "Theta (logits)", y = ylab)
    } else {
      p_sub <- p_sub + ggplot2::labs(x = "Theta (logits)", y = ylab)
    }
    p_sub
  }

  plot_type <- as.character(payload$plot %||% "ccc")[1L]
  long_df <- as.data.frame(payload$plot_long %||% data.frame(), stringsAsFactors = FALSE)

  if (identical(plot_type, "overview")) {
    ccc_df <- if ("PlotType" %in% names(long_df)) long_df[long_df$PlotType == "ccc", , drop = FALSE] else data.frame()
    cum_df <- if ("PlotType" %in% names(long_df)) {
      sub_c <- long_df[long_df$PlotType == "cumulative", , drop = FALSE]
      if ("DisplayedByDefault" %in% names(sub_c)) sub_c <- sub_c[sub_c$DisplayedByDefault %in% TRUE, , drop = FALSE]
      sub_c
    } else data.frame()
    inf_df <- if ("PlotType" %in% names(long_df)) long_df[long_df$PlotType == "information", , drop = FALSE] else data.frame()
    cinf_df <- if ("PlotType" %in% names(long_df)) long_df[long_df$PlotType == "category_information", , drop = FALSE] else data.frame()
    p_cum <- build_one_curve_panel(cum_df, "Cumulative prob.", "Cumulative probability") +
      ggplot2::geom_hline(yintercept = 0.5, linetype = "dotted", colour = style$ref_line, linewidth = 0.4)
    b_lines <- as.data.frame(payload$boundary_lines %||% data.frame(), stringsAsFactors = FALSE)
    b_col <- intersect(c("ThurstonianThreshold", "Theta"), names(b_lines))[1L]
    if (nrow(b_lines) > 0L && !is.na(b_col)) {
      b_x <- unique(suppressWarnings(as.numeric(b_lines[[b_col]])))
      b_x <- b_x[is.finite(b_x)]
      if (length(b_x) > 0L) {
        p_cum <- p_cum + ggplot2::geom_vline(xintercept = b_x, linetype = "dotted", colour = style$ref_line, linewidth = 0.35)
      }
    }
    panels <- list(
      build_one_curve_panel(ccc_df, "Probability", "Category probability"),
      p_cum,
      build_one_curve_panel(inf_df, "Information", "Total information"),
      build_one_curve_panel(cinf_df, "Category info", "Category-specific information")
    )
    p <- .mfrm_compose_ggplots(panels, ncol = 2L, payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if ("PlotType" %in% names(long_df)) {
    long_df <- long_df[long_df$PlotType == plot_type, , drop = FALSE]
  }
  if (identical(plot_type, "cumulative") && "DisplayedByDefault" %in% names(long_df)) {
    long_df <- long_df[long_df$DisplayedByDefault %in% TRUE, , drop = FALSE]
  }
  ylab <- switch(
    plot_type,
    ogive = "Expected score",
    cumulative = "Cumulative probability",
    information = "Total information",
    category_information = "Category information",
    "Category probability"
  )
  p <- build_one_curve_panel(long_df, ylab = ylab, panel_title = NULL)
  if (identical(plot_type, "cumulative")) {
    p <- p + ggplot2::geom_hline(yintercept = 0.5, linetype = "dotted", colour = style$ref_line, linewidth = 0.4)
    b_lines <- as.data.frame(payload$boundary_lines %||% data.frame(), stringsAsFactors = FALSE)
    b_col <- intersect(c("ThurstonianThreshold", "Theta"), names(b_lines))[1L]
    if (nrow(b_lines) > 0L && !is.na(b_col)) {
      b_x <- unique(suppressWarnings(as.numeric(b_lines[[b_col]])))
      b_x <- b_x[is.finite(b_x)]
      if (length(b_x) > 0L) {
        p <- p + ggplot2::geom_vline(
          xintercept = b_x,
          linetype = "dotted",
          colour = style$ref_line,
          linewidth = 0.4
        )
      }
    }
  }
  if ("CurveGroup" %in% names(long_df) && length(unique(long_df$CurveGroup)) > 1L) {
    p <- p + ggplot2::facet_wrap(~ CurveGroup)
  }
  p <- .mfrmr_gg_labs(p, payload, x = "Theta (logits)", y = ylab)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_bias_all <- function(x) {
  payload <- x$data
  plot_kind <- as.character(payload$plot %||% "scatter")[1L]
  style <- resolve_plot_preset(payload$preset %||% "standard")

  if (plot_kind %in% c("scatter", "ranked")) {
    p <- .mfrmr_gg_bias(x)
    if (identical(plot_kind, "scatter")) {
      df <- as.data.frame(payload$scatter_data %||% data.frame(), stringsAsFactors = FALSE)
      p <- .mfrmr_attach_marginal_histograms(
        p,
        x = df$ObsExpAverage,
        y = df$BiasSize,
        marginal = payload$plot_settings$Marginal %||% payload$marginal %||% "auto",
        preset = style$name
      )
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(plot_kind, "heatmap") && is.matrix(payload$heatmap_matrix)) {
    p <- .mfrmr_gg_matrix(
      payload$heatmap_matrix,
      payload,
      flag_matrix = payload$heatmap_flag_matrix,
      show_values = nrow(payload$heatmap_matrix) <= 12L && ncol(payload$heatmap_matrix) <= 12L
    )
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(plot_kind, "abs_t_hist")) {
    df <- as.data.frame(payload$scatter_data %||% payload$ranked_table %||% data.frame(), stringsAsFactors = FALSE)
    t_vals <- abs(suppressWarnings(as.numeric(df$t)))
    t_vals <- t_vals[is.finite(t_vals)]
    if (!length(t_vals)) {
      p <- .mfrmr_empty_ggplot("No finite |t| values available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    n_bins <- min(20L, max(6L, as.integer(sqrt(length(t_vals)))))
    p <- ggplot2::ggplot(data.frame(AbsT = t_vals), ggplot2::aes(x = .data$AbsT)) +
      ggplot2::geom_histogram(bins = n_bins, fill = style$hist_fill, colour = "#FFFFFF", alpha = 0.85) +
      ggplot2::geom_vline(xintercept = 2, linetype = "dashed", colour = style$warn) +
      .mfrmr_gg_theme_styled(style$name)
    p <- .mfrmr_gg_add_references(p, payload$reference_lines)
    p <- .mfrmr_gg_labs(p, payload, x = "|Bias t|", y = "Interaction cells")
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  # facet_profile
  prof <- as.data.frame(payload$facet_profile %||% data.frame(), stringsAsFactors = FALSE)
  val_col <- intersect(c("MeanAbsBias", "MeanAbsBiasSize", "MaxAbsBias", "MaxAbsBiasSize", "MeanAbsT"), names(prof))[1L]
  if (!nrow(prof) || is.na(val_col)) {
    p <- .mfrmr_empty_ggplot("No bias facet profile available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  prof$Value <- suppressWarnings(as.numeric(prof[[val_col]]))
  prof <- prof[is.finite(prof$Value), , drop = FALSE]
  prof$Label <- if (all(c("Facet", "Level") %in% names(prof))) paste(prof$Facet, prof$Level, sep = ": ") else as.character(seq_len(nrow(prof)))
  prof$Row <- seq_len(nrow(prof))
  p <- ggplot2::ggplot(prof, ggplot2::aes(x = .data$Value, y = .data$Row)) +
    ggplot2::geom_segment(ggplot2::aes(x = 0, xend = .data$Value, yend = .data$Row), colour = style$neutral) +
    ggplot2::geom_point(colour = style$accent_primary, size = 2.6) +
    ggplot2::scale_y_reverse(breaks = prof$Row, labels = prof$Label) +
    .mfrmr_gg_theme_styled(style$name)
  p <- .mfrmr_gg_add_references(p, payload$reference_lines)
  p <- .mfrmr_gg_labs(p, payload, x = "Mean |Bias Size| (logits)", y = NULL)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_residual_qq <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")
  df <- as.data.frame(payload$data %||% data.frame(), stringsAsFactors = FALSE)
  df <- df[is.finite(df$Theoretical) & is.finite(df$Sample), , drop = FALSE]
  if (!nrow(df)) {
    p <- .mfrmr_empty_ggplot("No finite person residuals available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Theoretical, y = .data$Sample)) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = style$ref_line, linewidth = 0.5) +
    ggplot2::geom_point(colour = style$accent_primary, size = 2.3, alpha = 0.85) +
    .mfrmr_gg_theme_styled(style$name)
  p <- .mfrmr_gg_labs(
    p,
    payload,
    x = "Theoretical quantile (N(0, 1))",
    y = "Sample quantile (person standardized residual)"
  )
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_ccc_surface <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")
  surf <- as.data.frame(payload$surface %||% payload$probabilities %||% data.frame(), stringsAsFactors = FALSE)
  if (!nrow(surf) || !all(c("Theta", "Category", "Probability") %in% names(surf))) {
    p <- .mfrmr_empty_ggplot("No category probability surface available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  cats <- unique(as.character(surf$Category))
  surf$CategoryFactor <- factor(as.character(surf$Category), levels = cats)
  surf <- surf[is.finite(surf$Theta) & is.finite(surf$Probability), , drop = FALSE]

  p <- ggplot2::ggplot(surf, ggplot2::aes(x = .data$Theta, y = .data$CategoryFactor, fill = .data$Probability)) +
    ggplot2::geom_tile() +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line, linewidth = 0.4) +
    ggplot2::scale_fill_gradient(
      low = if (identical(style$name, "monochrome")) "gray95" else "#F8FAFC",
      high = if (identical(style$name, "monochrome")) "gray15" else style$accent_primary,
      limits = c(0, 1),
      name = "Probability"
    ) +
    .mfrmr_gg_theme_styled(style$name)
  if ("CurveGroup" %in% names(surf) && length(unique(surf$CurveGroup)) > 1L) {
    p <- p + ggplot2::facet_wrap(~ CurveGroup)
  }
  p <- .mfrmr_gg_labs(p, payload, x = "Ability / propensity (logits)", y = "Score category")
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_screening_performance <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")
  tab <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
  if (!nrow(tab)) {
    p <- .mfrmr_empty_ggplot("No planned screening targets available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  tab$Row <- seq_len(nrow(tab))
  labels <- as.character(payload$labels %||% tab$Condition %||% tab$Row)
  counts_lbl <- paste0(labels, "  [", tab$Available, "/", tab$Planned, "]")

  all_ok <- is.finite(tab$AllTrialsLower) & is.finite(tab$AllTrialsUpper)
  mc_ok <- is.finite(tab$MCLower) & is.finite(tab$MCUpper)
  rate_ok <- is.finite(tab$Rate)

  p <- ggplot2::ggplot(tab, ggplot2::aes(y = .data$Row))
  if (any(all_ok)) {
    p <- p + ggplot2::geom_segment(
      data = tab[all_ok, , drop = FALSE],
      ggplot2::aes(x = .data$AllTrialsLower, xend = .data$AllTrialsUpper, y = .data$Row, yend = .data$Row),
      colour = "grey78",
      linewidth = 3.2
    )
  }
  if (any(mc_ok)) {
    p <- p + ggplot2::geom_segment(
      data = tab[mc_ok, , drop = FALSE],
      ggplot2::aes(x = .data$MCLower, xend = .data$MCUpper, y = .data$Row, yend = .data$Row),
      colour = style$accent_primary,
      linewidth = 1.0
    )
  }
  if (any(rate_ok)) {
    p <- p + ggplot2::geom_point(
      data = tab[rate_ok, , drop = FALSE],
      ggplot2::aes(x = .data$Rate, y = .data$Row),
      colour = style$accent_primary,
      size = 2.8
    )
  }
  if (any(!rate_ok)) {
    p <- p + ggplot2::geom_text(
      data = tab[!rate_ok, , drop = FALSE],
      ggplot2::aes(x = 0.5, y = .data$Row),
      label = "Unavailable",
      colour = style$neutral,
      size = 3.0
    )
  }
  p <- p +
    ggplot2::scale_x_continuous(limits = c(0, 1)) +
    ggplot2::scale_y_reverse(breaks = tab$Row, labels = counts_lbl) +
    .mfrmr_gg_theme_styled(style$name)
  p <- .mfrmr_gg_labs(p, payload, x = "Proportion", y = NULL)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_d_study <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")
  plot_type <- as.character(payload$plot %||% "coefficients")[1L]
  ser <- as.data.frame(payload$series %||% payload$surface %||% payload$table %||% data.frame(), stringsAsFactors = FALSE)
  x_var <- as.character(payload$x_var %||% names(ser)[1L])[1L]
  y_var <- as.character(payload$y_var %||% NA_character_)[1L]

  if (plot_type %in% c("heatmap", "contour", "surface3d") &&
      !is.na(y_var) && nzchar(y_var) && all(c(x_var, y_var) %in% names(ser))) {
    metric_col <- intersect(c("Value", as.character(payload$metric)), names(ser))[1L]
    ser$XVal <- suppressWarnings(as.numeric(ser[[x_var]]))
    ser$YVal <- suppressWarnings(as.numeric(ser[[y_var]]))
    ser$ZVal <- suppressWarnings(as.numeric(ser[[metric_col]]))
    ser <- ser[is.finite(ser$XVal) & is.finite(ser$YVal) & is.finite(ser$ZVal), , drop = FALSE]
    if (!nrow(ser)) {
      p <- .mfrmr_empty_ggplot("No finite D-Study surface values available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }

    if (identical(plot_type, "surface3d")) {
      # Isometric 2D projection of (X, Y, Z) grid per panel.
      xr <- range(ser$XVal)
      yr <- range(ser$YVal)
      zr <- range(ser$ZVal)
      nx <- if (diff(xr) > 0) (ser$XVal - xr[1L]) / diff(xr) else rep(0.5, nrow(ser))
      ny <- if (diff(yr) > 0) (ser$YVal - yr[1L]) / diff(yr) else rep(0.5, nrow(ser))
      nz <- if (diff(zr) > 0) (ser$ZVal - zr[1L]) / diff(zr) else rep(0.5, nrow(ser))
      ang <- 35 * pi / 180
      ser$IsoX <- nx * cos(ang) - ny * sin(ang)
      ser$IsoY <- 0.45 * (nx * sin(ang) + ny * cos(ang)) + 0.85 * nz
      p <- ggplot2::ggplot(ser, ggplot2::aes(x = .data$IsoX, y = .data$IsoY)) +
        ggplot2::geom_line(ggplot2::aes(group = .data$YVal), colour = style$grid, linewidth = 0.45) +
        ggplot2::geom_line(ggplot2::aes(group = .data$XVal), colour = style$axis, linewidth = 0.45, alpha = 0.65) +
        ggplot2::geom_point(ggplot2::aes(colour = .data$ZVal), size = 2.4) +
        ggplot2::scale_colour_gradient(
          low = if (identical(style$name, "monochrome")) "gray80" else style$accent_secondary,
          high = if (identical(style$name, "monochrome")) "gray15" else style$accent_primary,
          name = as.character(payload$metric)[1L]
        ) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text = ggplot2::element_blank(), axis.ticks = ggplot2::element_blank())
      if ("Panel" %in% names(ser) && length(unique(ser$Panel)) > 1L) {
        p <- p + ggplot2::facet_wrap(~ Panel)
      }
      p <- .mfrmr_gg_labs(p, payload, x = paste(x_var, "x", y_var, "(isometric projection)"), y = as.character(payload$metric)[1L])
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }

    p <- ggplot2::ggplot(ser, ggplot2::aes(x = .data$XVal, y = .data$YVal, fill = .data$ZVal)) +
      ggplot2::geom_tile(colour = "#FFFFFF", linewidth = 0.2) +
      ggplot2::scale_fill_gradient(
        low = if (identical(style$name, "monochrome")) "gray90" else style$fill_soft,
        high = if (identical(style$name, "monochrome")) "gray20" else style$accent_primary,
        name = as.character(payload$metric)[1L]
      ) +
      .mfrmr_gg_theme_styled(style$name)
    if (identical(plot_type, "contour") &&
        length(unique(ser$XVal)) >= 2L &&
        length(unique(ser$YVal)) >= 2L &&
        length(unique(ser$ZVal)) > 1L) {
      p <- p + ggplot2::geom_contour(ggplot2::aes(z = .data$ZVal), colour = style$foreground, linewidth = 0.4, na.rm = TRUE)
    }
    if ("Panel" %in% names(ser) && length(unique(ser$Panel)) > 1L) {
      p <- p + ggplot2::facet_wrap(~ Panel)
    }
    p <- .mfrmr_gg_labs(p, payload, x = x_var, y = y_var)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  val_col <- intersect(c("Value", as.character(payload$metric)), names(ser))[1L]
  if (!nrow(ser) || is.na(val_col) || !x_var %in% names(ser)) {
    p <- .mfrmr_empty_ggplot("No D-Study projection series available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  ser$XVal <- suppressWarnings(as.numeric(ser[[x_var]]))
  ser$YVal <- suppressWarnings(as.numeric(ser[[val_col]]))
  ser <- ser[is.finite(ser$XVal) & is.finite(ser$YVal), , drop = FALSE]
  ser$Series <- as.character(ser$Series %||% ser$Metric %||% val_col)
  s_levels <- unique(ser$Series)
  ser$SeriesFactor <- factor(ser$Series, levels = s_levels)

  leg <- payload$legend
  if (is.data.frame(leg) && nrow(leg) > 0L && all(s_levels %in% leg$label)) {
    cols <- stats::setNames(as.character(leg$value[match(s_levels, leg$label)]), s_levels)
  } else {
    cols <- stats::setNames(rep(style$series, length.out = length(s_levels)), s_levels)
  }

  p <- ggplot2::ggplot(ser, ggplot2::aes(x = .data$XVal, y = .data$YVal, colour = .data$SeriesFactor, group = .data$SeriesFactor)) +
    ggplot2::geom_line(linewidth = 0.78) +
    ggplot2::geom_point(size = 2.2) +
    ggplot2::scale_colour_manual(values = cols, name = NULL) +
    .mfrmr_gg_theme_styled(style$name)
  if (identical(plot_type, "coefficients")) {
    p <- p + ggplot2::coord_cartesian(ylim = c(0, 1))
  }
  if ("Panel" %in% names(ser) && length(unique(ser$Panel)) > 1L) {
    p <- p + ggplot2::facet_wrap(~ Panel)
  }
  p <- .mfrmr_gg_add_references(p, payload$reference_lines)
  ylab <- if (identical(plot_type, "coefficients")) "Generalizability / dependability" else "Error variance"
  p <- .mfrmr_gg_labs(p, payload, x = x_var, y = ylab)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_multivariate_d_comparison <- function(x) {
  payload <- x$data
  style <- resolve_plot_preset(payload$preset %||% "standard")
  view <- as.character(payload$view %||% "differences")[1L]
  metrics <- as.character(payload$metrics %||% character())

  if (identical(view, "plans")) {
    ser <- as.data.frame(payload$series %||% data.frame(), stringsAsFactors = FALSE)
    if (!nrow(ser)) {
      p <- .mfrmr_empty_ggplot("No D-Study plan projections available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    grid_df <- as.data.frame(payload$design_grid %||% data.frame(), stringsAsFactors = FALSE)
    plan_labels <- if (nrow(grid_df) > 0L) {
      lbl <- if ("Plan" %in% names(ser)) as.character(ser$Plan[match(seq_len(nrow(grid_df)), ser$Scenario)]) else
        vapply(seq_len(nrow(grid_df)), function(i) {
        paste(paste(names(grid_df), unlist(grid_df[i, ]), sep = "="), collapse = ", ")
      }, character(1))
      if (!is.null(payload$reference) && payload$reference %in% seq_along(lbl)) {
        lbl[payload$reference] <- paste0(lbl[payload$reference], " (ref)")
      }
      lbl
    } else {
      as.character(sort(unique(ser$Scenario)))
    }
    ser$IsRef <- ser$Scenario == (payload$reference %||% -1L)
    ser$Shape <- ifelse(!is.finite(ser$Value), 4, ifelse(ser$IsRef, 18, 16))
    fin <- ser[is.finite(ser$Value), , drop = FALSE]
    p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$Scenario, y = .data$Value)) +
      ggplot2::geom_line(colour = style$neutral, linewidth = 0.5) +
      ggplot2::geom_point(ggplot2::aes(shape = .data$Shape), colour = style$accent_primary, size = 3.0) +
      ggplot2::scale_shape_identity() +
      ggplot2::scale_x_continuous(breaks = seq_along(plan_labels),
        labels = vapply(plan_labels, function(label) paste(strwrap(label, width = 24), collapse = "\n"), character(1)),
        expand = ggplot2::expansion(add = .4)) +
      ggplot2::facet_wrap(~ Metric, ncol = 1L, scales = "free_y") +
      .mfrmr_gg_theme_styled(style$name) +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 0, hjust = .5))
    p <- .mfrmr_gg_labs(p, payload, x = "Candidate D-Study plan", y = "Projected value")
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  tab <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
  if (!nrow(tab)) {
    p <- .mfrmr_empty_ggplot("No D-Study plan differences available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  if (length(metrics) > 0L && "Metric" %in% names(tab)) {
    tab <- tab[tab$Metric %in% metrics, , drop = FALSE]
  }
  tab$RowLabel <- as.character(tab$Comparison %||% tab$Plan %||% seq_len(nrow(tab)))
  tab$RowFactor <- factor(tab$RowLabel, levels = rev(unique(tab$RowLabel)))
  est_col <- intersect(c("Difference", "Estimate"), names(tab))[1L]
  lo_col <- intersect(c("Lower", "CI_Lower"), names(tab))[1L]
  hi_col <- intersect(c("Upper", "CI_Upper"), names(tab))[1L]
  tab$Est <- suppressWarnings(as.numeric(tab[[est_col]]))
  tab$Lo <- if (!is.na(lo_col)) suppressWarnings(as.numeric(tab[[lo_col]])) else NA_real_
  tab$Hi <- if (!is.na(hi_col)) suppressWarnings(as.numeric(tab[[hi_col]])) else NA_real_
  ci_ok <- is.finite(tab$Est) & is.finite(tab$Lo) & is.finite(tab$Hi) & (tab$Status %||% "Available") == "Available"
  pt_only <- is.finite(tab$Est) & !ci_ok
  miss <- !is.finite(tab$Est)

  p <- ggplot2::ggplot(tab, ggplot2::aes(y = .data$RowFactor)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line)
  if (any(ci_ok)) {
    p <- p +
      ggplot2::geom_segment(
        data = tab[ci_ok, , drop = FALSE],
        ggplot2::aes(x = .data$Lo, xend = .data$Hi, yend = .data$RowFactor),
        colour = style$accent_primary,
        linewidth = 0.75
      ) +
      ggplot2::geom_point(
        data = tab[ci_ok, , drop = FALSE],
        ggplot2::aes(x = .data$Est),
        colour = style$accent_primary,
        shape = 16,
        size = 2.6
      )
  }
  if (any(pt_only)) {
    p <- p + ggplot2::geom_point(
      data = tab[pt_only, , drop = FALSE],
      ggplot2::aes(x = .data$Est),
      colour = style$warn,
      shape = 1,
      size = 2.8
    )
  }
  if (any(miss)) {
    p <- p + ggplot2::geom_text(
      data = tab[miss, , drop = FALSE],
      ggplot2::aes(x = 0, y = .data$RowFactor),
      label = "* Unavailable",
      colour = style$neutral,
      size = 2.9
    )
  }
  if ("Metric" %in% names(tab) && length(unique(tab$Metric)) > 1L) {
    p <- p + ggplot2::facet_wrap(~ Metric, ncol = 1L, scales = "free_x")
  }
  p <- p + .mfrmr_gg_theme_styled(style$name)
  p <- .mfrmr_gg_labs(p, payload, x = "Difference vs reference plan", y = NULL)
  attr(p, "mfrmr_plot_data") <- x
  p
}

.mfrmr_gg_specialized_views <- function(x) {
  nm <- as.character(x$name %||% "")[1L]
  payload <- x$data %||% list()
  style <- resolve_plot_preset(payload$preset %||% "standard")

  if (nm %in% c("information_tif", "information_se", "information_sem",
                 "information_tif_se", "information_iif")) {
    curves <- payload$plot_long %||% payload$information_long
    if (is.data.frame(curves) && all(c("Theta", "Value", "Series") %in% names(curves))) {
      # Preserve the complete payload while drawing only the requested series.
      if ("DisplayedByDefault" %in% names(curves)) {
        curves <- curves[curves$DisplayedByDefault %in% TRUE, , drop = FALSE]
      }
      p <- ggplot2::ggplot(curves,
        ggplot2::aes(x = .data$Theta, y = .data$Value,
                     colour = .data$Series, group = .data$Series)) +
        ggplot2::geom_line(na.rm = TRUE) + .mfrmr_gg_theme_styled(style$name)
      ylab <- if (nm %in% c("information_se", "information_sem"))
        "Conditional SEM" else "Observed-design information"
      if (identical(nm, "information_tif_se")) {
        # Information and its inverse square root have different units.
        p <- p + ggplot2::facet_grid(Series ~ ., scales = "free_y")
        ylab <- NULL
      }
      if (!identical(nm, "information_iif")) {
        p <- p + ggplot2::theme(legend.position = "none")
      } else {
        p <- p + ggplot2::labs(colour = "Facet level")
      }
      p <- .mfrmr_gg_labs(p, payload, x = "Ability (logits)", y = ylab)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
  }

  if (identical(nm, "fit_plot_bundle")) {
    raw_plots <- list(payload$wright_map, payload$pathway_map, payload$category_characteristic_curves)
    plots <- lapply(raw_plots, function(item) {
      if (inherits(item, "ggplot")) item else if (inherits(item, "mfrm_plot_data")) as_ggplot(item) else NULL
    })
    plots <- plots[vapply(plots, inherits, logical(1), "ggplot")]
    p <- .mfrm_compose_ggplots(plots, ncol = 3L, payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "apa_figure_one")) {
    sub_data <- payload$data %||% list()
    g_w <- if (inherits(sub_data$wright, "ggplot")) sub_data$wright else as_ggplot(sub_data$wright)
    g_s <- if (inherits(sub_data$severity, "ggplot")) sub_data$severity else as_ggplot(sub_data$severity)
    g_t <- if (inherits(sub_data$threshold, "ggplot")) sub_data$threshold else as_ggplot(sub_data$threshold)
    lines_txt <- paste(as.character(sub_data$summary %||% character()), collapse = "\n")
    g_txt <- ggplot2::ggplot(data.frame(x = 0.04, y = 0.94, txt = lines_txt), ggplot2::aes(x = .data$x, y = .data$y)) +
      ggplot2::geom_text(
        ggplot2::aes(label = .data$txt),
        hjust = 0,
        vjust = 1,
        size = 3.1,
        colour = style$foreground,
        lineheight = 1.25
      ) +
      ggplot2::scale_x_continuous(limits = c(0, 1), breaks = NULL) +
      ggplot2::scale_y_continuous(limits = c(0, 1), breaks = NULL) +
      .mfrmr_gg_theme_styled(style$name) +
      ggplot2::theme(
        axis.line = ggplot2::element_blank(),
        panel.grid.major = ggplot2::element_blank()
      ) +
      ggplot2::labs(x = NULL, y = NULL)
    p <- .mfrm_compose_ggplots(list(g_w, g_s, g_t, g_txt), ncol = 2L, payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "qc_dashboard")) {
    make_bar <- function(df, xcol, ycol, ttl, h_ref = NULL) {
      df <- as.data.frame(df %||% data.frame(), stringsAsFactors = FALSE)
      if (!nrow(df) || !all(c(xcol, ycol) %in% names(df))) {
        return(.mfrmr_empty_ggplot("No data", preset = style$name) + ggplot2::labs(subtitle = ttl))
      }
      df$Val <- suppressWarnings(as.numeric(df[[ycol]]))
      df <- df[is.finite(df$Val), , drop = FALSE]
      if (!nrow(df)) return(.mfrmr_empty_ggplot("No finite values", preset = style$name) + ggplot2::labs(subtitle = ttl))
      df <- utils::head(df, 20L)
      df$Pos <- seq_len(nrow(df))
      g <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Pos, y = .data$Val)) +
        ggplot2::geom_col(fill = style$accent_primary, width = 0.7) +
        ggplot2::scale_x_continuous(breaks = df$Pos, labels = truncate_axis_label(df[[xcol]], 14L)) +
        .mfrmr_gg_theme_styled("compact") +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1)) +
        ggplot2::labs(subtitle = ttl, x = NULL, y = ycol)
      if (!is.null(h_ref)) {
        for (rv in h_ref) g <- g + ggplot2::geom_hline(yintercept = rv, linetype = "dashed", colour = style$ref_line)
      }
      g
    }
    fit_df <- as.data.frame(payload$fit %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(fit_df) > 0L && all(c("Facet", "Level") %in% names(fit_df))) {
      fit_df$Elem <- paste(fit_df$Facet, fit_df$Level, sep = ":")
    }
    p1 <- make_bar(payload$category_stats, "Category", "Count", "Category counts")
    p2 <- make_bar(fit_df, "Elem", "Infit", "Infit MnSq", h_ref = c(0.5, 1.5))
    p3 <- make_bar(fit_df, "Elem", "InfitZSTD", "Infit ZSTD", h_ref = c(-2, 2))
    unexp_tbl <- if (is.list(payload$unexpected)) payload$unexpected$summary %||% payload$unexpected$table else NULL
    p4 <- if (is.data.frame(unexp_tbl) && nrow(unexp_tbl) > 0L) {
      num_c <- names(unexp_tbl)[vapply(unexp_tbl, is.numeric, logical(1))][1L]
      lbl_c <- names(unexp_tbl)[1L]
      make_bar(unexp_tbl, lbl_c, num_c, "Unexpected responses")
    } else {
      .mfrmr_empty_ggplot("Unexpected responses summary", preset = style$name) + ggplot2::labs(subtitle = "Unexpected responses")
    }
    disp_tbl <- if (is.list(payload$displacement)) payload$displacement$table else NULL
    if (is.data.frame(disp_tbl) && nrow(disp_tbl) > 0L && all(c("Facet", "Level") %in% names(disp_tbl))) {
      disp_tbl$Elem <- paste(disp_tbl$Facet, disp_tbl$Level, sep = ":")
    }
    p5 <- make_bar(disp_tbl, "Elem", "Displacement", "Displacement", h_ref = 0)
    p6 <- make_bar(payload$reliability, "Facet", "Separation", "Separation by facet", h_ref = 1)
    p <- .mfrm_compose_ggplots(list(p1, p2, p3, p4, p5, p6), ncol = 2L, payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "qc_pipeline")) {
    vt <- as.data.frame(payload$verdicts %||% payload$table %||% data.frame(), stringsAsFactors = FALSE)
    if (!nrow(vt)) {
      p <- .mfrmr_empty_ggplot("No QC verdicts available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    vt$Row <- seq_len(nrow(vt))
    cols <- c(Pass = style$success, Warn = style$warn, Fail = style$fail)
    vt$VerdictFactor <- factor(vt$Verdict, levels = unique(c("Pass", "Warn", "Fail", vt$Verdict)))
    missing_v <- setdiff(levels(vt$VerdictFactor), names(cols))
    if (length(missing_v)) cols <- c(cols, stats::setNames(rep(style$neutral, length(missing_v)), missing_v))

    if (identical(payload$plot, "detail")) {
      p <- ggplot2::ggplot(vt, ggplot2::aes(y = .data$Row)) +
        ggplot2::geom_tile(
          ggplot2::aes(x = 0.08, fill = .data$VerdictFactor),
          width = 0.14,
          height = 0.78
        ) +
        ggplot2::geom_text(
          ggplot2::aes(x = 0.08, label = substr(.data$Verdict, 1L, 1L)),
          colour = "#FFFFFF",
          fontface = "bold",
          size = 3.2
        ) +
        ggplot2::geom_text(
          ggplot2::aes(x = 0.18, label = .data$Detail),
          hjust = 0,
          size = 3.0,
          colour = style$foreground
        ) +
        ggplot2::scale_x_continuous(limits = c(0, 1.05), breaks = NULL) +
        ggplot2::scale_y_reverse(breaks = vt$Row, labels = vt$Check) +
        ggplot2::scale_fill_manual(values = cols, name = "Verdict") +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.line = ggplot2::element_blank(), panel.grid.major = ggplot2::element_blank())
    } else {
      p <- ggplot2::ggplot(vt, ggplot2::aes(x = 0.5, y = .data$Row)) +
        ggplot2::geom_tile(ggplot2::aes(fill = .data$VerdictFactor), width = 0.92, height = 0.78) +
        ggplot2::geom_text(
          ggplot2::aes(label = paste0(.data$Verdict, "  (", .data$Value, ")")),
          colour = "#FFFFFF",
          fontface = "bold",
          size = 3.2
        ) +
        ggplot2::scale_x_continuous(limits = c(0, 1), breaks = NULL) +
        ggplot2::scale_y_reverse(breaks = vt$Row, labels = vt$Check) +
        ggplot2::scale_fill_manual(values = cols, name = "Verdict") +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.line = ggplot2::element_blank(), panel.grid.major = ggplot2::element_blank())
    }
    p <- .mfrmr_gg_labs(p, payload, x = NULL, y = NULL)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "facet_equivalence")) {
    df <- as.data.frame(payload$data %||% data.frame(), stringsAsFactors = FALSE)
    if (!nrow(df)) {
      p <- .mfrmr_empty_ggplot("No facet equivalence rows available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(payload$type, "rope")) {
      df <- df[order(df$ROPEPct, decreasing = TRUE, na.last = TRUE), , drop = FALSE]
      df$Pos <- seq_len(nrow(df))
      p <- ggplot2::ggplot(df[is.finite(df$ROPEPct), , drop = FALSE], ggplot2::aes(x = .data$Pos, y = .data$ROPEPct)) +
        ggplot2::geom_col(fill = style$accent_primary, width = 0.68) +
        ggplot2::scale_x_continuous(breaks = df$Pos, labels = df$Element) +
        ggplot2::coord_cartesian(ylim = c(0, 100)) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = "Normal reference mass within bound (%)")
    } else {
      df <- df[order(df$Deviation, na.last = TRUE), , drop = FALSE]
      df$Row <- seq_len(nrow(df))
      bound <- suppressWarnings(as.numeric(payload$equivalence_bound %||% NA_real_))[1L]
      cols <- c(inside = style$success, outside = style$fail, undecided = style$warn, unavailable = style$neutral)
      df$StatusKey <- ifelse(df$ROPEStatus %in% names(cols), df$ROPEStatus, "undecided")
      ci_ok <- is.finite(df$DeviationCI_Lower) & is.finite(df$DeviationCI_Upper)
      pt_ok <- is.finite(df$Deviation)
      p <- ggplot2::ggplot(df, ggplot2::aes(y = .data$Row))
      if (is.finite(bound) && bound > 0) {
        p <- p + ggplot2::annotate(
          "rect",
          xmin = -bound, xmax = bound, ymin = -Inf, ymax = Inf,
          fill = style$success, alpha = 0.10
        )
      }
      p <- p + ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line)
      if (any(ci_ok)) {
        p <- p + ggplot2::geom_segment(
          data = df[ci_ok, , drop = FALSE],
          ggplot2::aes(
            x = .data$DeviationCI_Lower, xend = .data$DeviationCI_Upper,
            yend = .data$Row, colour = .data$StatusKey
          ),
          linewidth = 0.75
        )
      }
      if (any(pt_ok)) {
        p <- p + ggplot2::geom_point(
          data = df[pt_ok, , drop = FALSE],
          ggplot2::aes(x = .data$Deviation, colour = .data$StatusKey),
          size = 2.6
        )
      }
      p <- p +
        ggplot2::scale_colour_manual(values = cols, name = "ROPE status") +
        ggplot2::scale_y_continuous(breaks = df$Row, labels = df$Element) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Deviation from facet mean (logits)", y = NULL)
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "facet_sample_review")) {
    df <- as.data.frame(payload$table %||% payload$data %||% data.frame(), stringsAsFactors = FALSE)
    if (!nrow(df)) {
      p <- .mfrmr_empty_ggplot("Review table empty.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    df$Row <- seq_len(nrow(df))
    df$Label <- paste0(df$Facet, " / ", df$Level)
    cols <- if (identical(style$name, "monochrome")) {
      c(
        sparse = "gray25", marginal = "gray45", standard = "gray65", strong = "gray80",
        `<10` = "gray25", `10-29` = "gray45", `>=30` = "gray65"
      )
    } else {
      c(
        sparse = "#D73027", marginal = "#FDAE61", standard = "#66BD63", strong = "#1A9850",
        `<10` = style$fail, `10-29` = style$warn, `>=30` = style$accent_primary
      )
    }
    thr <- payload$thresholds %||% list(sparse = 10, marginal = 30, standard = 50)
    thr_vals <- suppressWarnings(as.numeric(c(thr$sparse, thr$marginal, thr$standard)))
    thr_vals <- thr_vals[is.finite(thr_vals)]
    p <- ggplot2::ggplot(df[is.finite(df$N), , drop = FALSE], ggplot2::aes(x = .data$N, y = .data$Row, fill = .data$SampleCategory)) +
      ggplot2::geom_col(orientation = "y", width = 0.7) +
      ggplot2::scale_fill_manual(values = cols, name = "Sample band", na.value = style$neutral) +
      ggplot2::scale_y_reverse(breaks = df$Row, labels = df$Label) +
      .mfrmr_gg_theme_styled(style$name)
    if (length(thr_vals) > 0L) {
      p <- p + ggplot2::geom_vline(xintercept = thr_vals, linetype = "dashed", colour = style$neutral)
    }
    p <- .mfrmr_gg_labs(p, payload, x = "Retained rating rows per level", y = NULL)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "facet_nesting")) {
    mat <- payload$matrix
    if (!is.matrix(mat) || length(mat) == 0L) {
      p <- .mfrmr_empty_ggplot("At least two facets required for nesting matrix.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    p <- .mfrmr_gg_matrix(mat, payload, show_values = TRUE, value_digits = 2L)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "hierarchical_structure")) {
    if (identical(payload$plot, "icc")) {
      icc_df <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
      if (!nrow(icc_df) || !all(c("Facet", "ICC") %in% names(icc_df))) {
        p <- .mfrmr_empty_ggplot("No ICC estimates available.", payload = payload, preset = style$name)
        attr(p, "mfrmr_plot_data") <- x
        return(p)
      }
      icc_df$Row <- seq_len(nrow(icc_df))
      x_upper <- max(1, max(c(icc_df$ICC, icc_df$ICC_CI_Upper), na.rm = TRUE) * 1.1)
      p <- ggplot2::ggplot(icc_df[is.finite(icc_df$ICC), , drop = FALSE], ggplot2::aes(x = .data$ICC, y = .data$Row)) +
        ggplot2::geom_col(orientation = "y", fill = style$accent_primary, width = 0.65)
      if (all(c("ICC_CI_Lower", "ICC_CI_Upper") %in% names(icc_df))) {
        ci_ok <- is.finite(icc_df$ICC_CI_Lower) & is.finite(icc_df$ICC_CI_Upper)
        if (any(ci_ok)) {
          p <- p + ggplot2::geom_segment(
            data = icc_df[ci_ok, , drop = FALSE],
            ggplot2::aes(x = .data$ICC_CI_Lower, xend = .data$ICC_CI_Upper, y = .data$Row, yend = .data$Row),
            colour = style$foreground,
            linewidth = 0.75
          )
        }
      }
      p <- p +
        ggplot2::geom_vline(xintercept = c(0.05, 0.15), linetype = c("dotted", "dashed"), colour = c(style$warn, style$fail)) +
        ggplot2::scale_x_continuous(limits = c(0, x_upper)) +
        ggplot2::scale_y_reverse(breaks = icc_df$Row, labels = icc_df$Facet) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Variance share (ICC)", y = NULL)
    } else {
      mat <- payload$matrix
      p <- if (is.matrix(mat) && length(mat) > 0L) {
        .mfrmr_gg_matrix(mat, payload, show_values = nrow(mat) <= 15L && ncol(mat) <= 15L, value_digits = 0L)
      } else {
        .mfrmr_empty_ggplot("No cross-tabulation matrix available.", payload = payload, preset = style$name)
      }
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (nm %in% c("equating_chain_graph", "equating_chain_links", "equating_chain_anchor_removal", "equating_chain_offset_sensitivity")) {
    d <- payload$data %||% list()
    key <- payload$styles
    if (identical(nm, "equating_chain_offset_sensitivity")) {
      rows <- as.data.frame(d$removal %||% data.frame(), stringsAsFactors = FALSE)
      if (!nrow(rows)) {
        p <- .mfrmr_empty_ggplot("No common elements to remove.", payload = payload, preset = style$name)
        attr(p, "mfrmr_plot_data") <- x
        return(p)
      }
      rows <- rows[order(signif(rows$MaxAbsCumulativeChange, 3), decreasing = TRUE, na.last = TRUE), , drop = FALSE]
      rows$Row <- seq_len(nrow(rows))
      rows$Avail <- is.finite(rows$MaxAbsCumulativeChange)
      rows$Pos <- ifelse(rows$Avail, rows$MaxAbsCumulativeChange, 0)
      rows$Label <- sprintf("%s: %s", rows$Facet, rows$Level)
      k_idx <- ifelse(!rows$Avail, 3L, ifelse(rows$CompleteComparison, 1L, 2L))
      rows$StatusLabel <- factor(key$Label[k_idx], levels = key$Label)
      p <- ggplot2::ggplot(rows, ggplot2::aes(x = .data$Pos, y = .data$Row)) +
        ggplot2::geom_segment(
          data = rows[rows$Avail, , drop = FALSE],
          ggplot2::aes(x = 0, xend = .data$Pos, yend = .data$Row),
          colour = style$neutral
        ) +
        ggplot2::geom_point(ggplot2::aes(colour = .data$StatusLabel, shape = .data$StatusLabel), size = 2.8) +
        ggplot2::geom_text(
          ggplot2::aes(label = ifelse(.data$Avail, format(signif(.data$MaxAbsCumulativeChange, 3), trim = TRUE), "unavailable")),
          hjust = -0.2,
          size = 2.8,
          colour = style$foreground
        ) +
        ggplot2::scale_colour_manual(values = stats::setNames(key$Color, key$Label), name = NULL) +
        ggplot2::scale_shape_manual(values = stats::setNames(key$Shape, key$Label), name = NULL) +
        ggplot2::scale_x_continuous(limits = c(0, max(0.1, rows$Pos) * 1.35)) +
        ggplot2::scale_y_reverse(breaks = rows$Row, labels = rows$Label) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Max. absolute cumulative offset change (logits)", y = NULL)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(nm, "equating_chain_anchor_removal")) {
      rows <- as.data.frame(d$removal %||% data.frame(), stringsAsFactors = FALSE)
      if (!nrow(rows)) {
        p <- .mfrmr_empty_ggplot("No common elements to remove.", payload = payload, preset = style$name)
        attr(p, "mfrmr_plot_data") <- x
        return(p)
      }
      rows <- rows[order(rows$NewlyDisconnectedPairs, decreasing = TRUE), , drop = FALSE]
      rows$Row <- seq_len(nrow(rows))
      rows$Label <- sprintf("%s: %s", rows$Facet, rows$Level)
      k_idx <- ifelse(rows$NewlyDisconnectedPairs > 0, 1L, ifelse(rows$RetainedOccurrences > 0, 2L, 3L))
      rows$StatusLabel <- factor(key$Label[k_idx], levels = key$Label)
      p <- ggplot2::ggplot(rows, ggplot2::aes(x = .data$NewlyDisconnectedPairs, y = .data$Row)) +
        ggplot2::geom_segment(ggplot2::aes(x = 0, xend = .data$NewlyDisconnectedPairs, yend = .data$Row), colour = style$neutral) +
        ggplot2::geom_point(ggplot2::aes(colour = .data$StatusLabel, shape = .data$StatusLabel), size = 2.8) +
        ggplot2::scale_colour_manual(values = stats::setNames(key$Color, key$Label), name = NULL) +
        ggplot2::scale_shape_manual(values = stats::setNames(key$Shape, key$Label), name = NULL) +
        ggplot2::scale_y_reverse(breaks = rows$Row, labels = rows$Label) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Newly disconnected wave pairs", y = NULL)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(nm, "equating_chain_links")) {
      nodes <- as.data.frame(d$nodes %||% data.frame(), stringsAsFactors = FALSE)
      edges <- as.data.frame(d$links %||% data.frame(), stringsAsFactors = FALSE)
      ang <- seq(0, 2 * pi, length.out = nrow(nodes) + 1L)[-1L] + pi / 2
      nodes$X <- cos(ang)
      nodes$Y <- sin(ang)
      p <- ggplot2::ggplot()
      if (nrow(edges) > 0L) {
        a <- match(edges$from, nodes$NodeId)
        b <- match(edges$to, nodes$NodeId)
        edges$X0 <- nodes$X[a]
        edges$Y0 <- nodes$Y[a]
        edges$X1 <- nodes$X[b]
        edges$Y1 <- nodes$Y[b]
        edges$StatusLabel <- factor(key$Label[match(edges$Status, key$Status)], levels = key$Label)
        p <- p +
          ggplot2::geom_segment(
            data = edges,
            ggplot2::aes(x = .data$X0, y = .data$Y0, xend = .data$X1, yend = .data$Y1,
                         colour = .data$StatusLabel, linetype = .data$StatusLabel),
            linewidth = 0.8
          ) +
          ggplot2::geom_text(
            data = edges,
            ggplot2::aes(x = (.data$X0 + .data$X1) / 2, y = (.data$Y0 + .data$Y1) / 2, label = .data$RetainedElements),
            vjust = -0.4,
            size = 2.9,
            colour = style$foreground
          ) +
          ggplot2::scale_colour_manual(values = stats::setNames(key$Color, key$Label), name = NULL) +
          ggplot2::scale_linetype_manual(values = stats::setNames(key$Linetype, key$Label), name = NULL)
      }
      p <- p +
        ggplot2::geom_point(data = nodes, ggplot2::aes(x = .data$X, y = .data$Y), shape = 22, fill = "#FFFFFF", colour = style$foreground, size = 4.2) +
        ggplot2::geom_text(data = nodes, ggplot2::aes(x = .data$X * 1.18, y = .data$Y * 1.18, label = .data$Label), size = 3.0, colour = style$foreground) +
        ggplot2::coord_equal(xlim = c(-1.6, 1.6), ylim = c(-1.5, 1.5)) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.line = ggplot2::element_blank(), axis.ticks = ggplot2::element_blank(),
                       axis.text = ggplot2::element_blank(), panel.grid.major = ggplot2::element_blank())
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = NULL)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    # equating_chain_graph
    nodes <- as.data.frame(d$nodes %||% data.frame(), stringsAsFactors = FALSE)
    edges <- as.data.frame(d$edges %||% data.frame(), stringsAsFactors = FALSE)
    nw <- d$n_waves %||% sum(nodes$Kind == "wave")
    ne <- d$n_element_nodes %||% sum(nodes$Kind != "wave")
    y_seq <- function(n) if (n <= 1L) 0.5 else seq(0.92, 0.08, length.out = n)
    nodes$X <- c(rep(0.28, nw), rep(0.68, ne))
    nodes$Y <- c(y_seq(nw), y_seq(ne))
    p <- ggplot2::ggplot()
    if (nrow(edges) > 0L) {
      a <- match(edges$from, nodes$NodeId)
      b <- match(edges$to, nodes$NodeId)
      edges$X0 <- nodes$X[a]
      edges$Y0 <- nodes$Y[a]
      edges$X1 <- nodes$X[b]
      edges$Y1 <- nodes$Y[b]
      edges$StatusLabel <- factor(key$Label[match(edges$Status, key$Status)], levels = key$Label)
      p <- p +
        ggplot2::geom_segment(
          data = edges,
          ggplot2::aes(x = .data$X0, y = .data$Y0, xend = .data$X1, yend = .data$Y1,
                       colour = .data$StatusLabel, linetype = .data$StatusLabel),
          linewidth = 0.75
        ) +
        ggplot2::scale_colour_manual(values = stats::setNames(key$Color, key$Label), name = NULL) +
        ggplot2::scale_linetype_manual(values = stats::setNames(key$Linetype, key$Label), name = NULL)
    }
    p <- p +
      ggplot2::geom_point(
        data = nodes,
        ggplot2::aes(x = .data$X, y = .data$Y),
        shape = ifelse(nodes$Kind == "wave", 22, 21),
        fill = "#FFFFFF",
        colour = style$foreground,
        size = 3.6
      ) +
      ggplot2::geom_text(
        data = nodes,
        ggplot2::aes(
          x = ifelse(.data$Kind == "wave", .data$X - 0.03, .data$X + 0.03),
          y = .data$Y,
          label = truncate_axis_label(.data$Label, 26L),
          hjust = ifelse(.data$Kind == "wave", 1, 0)
        ),
        size = 2.8,
        colour = style$foreground
      ) +
      ggplot2::scale_x_continuous(limits = c(0, 1), breaks = NULL) +
      ggplot2::scale_y_continuous(limits = c(0, 1), breaks = NULL) +
      .mfrmr_gg_theme_styled(style$name) +
      ggplot2::theme(axis.line = ggplot2::element_blank(), panel.grid.major = ggplot2::element_blank())
    p <- .mfrmr_gg_labs(p, payload, x = NULL, y = NULL)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (grepl("^facets_results_", nm)) {
    view_type <- sub("^facets_results_", "", nm)
    d <- as.data.frame(payload$plot_data %||% payload$data %||% data.frame(), stringsAsFactors = FALSE)
    show_leg <- isTRUE(payload$display$show_legend %||% TRUE)
    if (!nrow(d)) {
      p <- .mfrmr_empty_ggplot("No imported FACETS rows available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (view_type %in% c("ccc", "expected")) {
      fin <- d[d$Available %in% TRUE & is.finite(d$X) & is.finite(d$Y), , drop = FALSE]
      if (!nrow(fin)) {
        p <- .mfrmr_empty_ggplot("No available coordinates.", payload = payload, preset = style$name)
        attr(p, "mfrmr_plot_data") <- x
        return(p)
      }
      s_levels <- unique(as.character(fin$Series))
      fin$SeriesFactor <- factor(as.character(fin$Series), levels = s_levels)
      fin$SegGroup <- interaction(fin$Panel %||% "1", fin$SeriesFactor, fin$Segment %||% 0L, drop = TRUE)
      cols_map <- if ("Color" %in% names(fin)) {
        stats::setNames(as.character(fin$Color[match(s_levels, fin$Series)]), s_levels)
      } else {
        stats::setNames(rep(style$series, length.out = length(s_levels)), s_levels)
      }
      lty_map <- if ("LineType" %in% names(fin)) {
        stats::setNames(as.integer(fin$LineType[match(s_levels, fin$Series)]), s_levels)
      } else {
        stats::setNames(rep(1L, length(s_levels)), s_levels)
      }
      seg_counts <- table(fin$SegGroup)
      iso_groups <- names(seg_counts)[seg_counts == 1L]
      iso_df <- fin[as.character(fin$SegGroup) %in% iso_groups, , drop = FALSE]
      p <- ggplot2::ggplot(
        fin,
        ggplot2::aes(
          x = .data$X, y = .data$Y,
          colour = .data$SeriesFactor,
          linetype = .data$SeriesFactor,
          group = .data$SegGroup
        )
      ) +
        ggplot2::geom_line(linewidth = 0.78) +
        ggplot2::scale_colour_manual(values = cols_map, name = if (identical(view_type, "ccc")) "Source category" else NULL) +
        ggplot2::scale_linetype_manual(values = lty_map, name = if (identical(view_type, "ccc")) "Source category" else NULL) +
        .mfrmr_gg_theme_styled(style$name)
      if (nrow(iso_df) > 0L) {
        p <- p + ggplot2::geom_point(data = iso_df, size = 2.2)
      }
      if (identical(view_type, "ccc")) {
        p <- p + ggplot2::coord_cartesian(ylim = c(0, 1))
      }
      if ("Panel" %in% names(d) && length(unique(d$Panel)) > 1L) {
        p <- p + ggplot2::facet_wrap(~ Panel)
      }
      if (!show_leg || identical(view_type, "expected")) {
        p <- p + ggplot2::theme(legend.position = "none")
      }
      p <- .mfrmr_gg_labs(p, payload, x = payload$xlab, y = payload$ylab)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }

    x_col <- if ("X" %in% names(d)) "X" else "Estimate"
    y_col <- if ("Y" %in% names(d)) "Y" else "Estimate"
    d$XVal <- suppressWarnings(as.numeric(d[[x_col]]))
    d$YVal <- suppressWarnings(as.numeric(d[[y_col]]))
    avail_vec <- if ("Available" %in% names(d)) d$Available %in% TRUE else is.finite(d$XVal) & is.finite(d$YVal)
    fin <- d[avail_vec & is.finite(d$XVal) & is.finite(d$YVal), , drop = FALSE]
    if (!nrow(fin) && view_type != "measure") {
      p <- .mfrmr_empty_ggplot("No available points.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    sym_labels <- c(
      estimated = "Estimated", anchored = "Direct/group anchor",
      extreme_low = "Extreme low", extreme_high = "Extreme high",
      single_observation = "Single observation", unknown = "Unknown status",
      no_data = "No data", unmeasurable = "Unmeasurable"
    )
    sym_codes <- c(
      estimated = 19L, anchored = 15L, extreme_low = 25L, extreme_high = 24L,
      single_observation = 5L, unknown = 1L, no_data = 4L, unmeasurable = 4L
    )
    d$StatusLabel <- unname(sym_labels[as.character(d$SourceStatus %||% "estimated")])
    d$StatusLabel[is.na(d$StatusLabel)] <- "Estimated"
    fin <- d[avail_vec & is.finite(d$XVal) & is.finite(d$YVal), , drop = FALSE]
    used_lbl <- unique(fin$StatusLabel)
    shape_map <- stats::setNames(
      unname(sym_codes[match(used_lbl, sym_labels)]),
      used_lbl
    )
    shape_map[is.na(shape_map)] <- 19L

    if (identical(view_type, "measure")) {
      p <- ggplot2::ggplot(d, ggplot2::aes(y = .data$YVal))
      if (nrow(fin) > 0L) {
        p <- p + ggplot2::geom_point(
          data = fin,
          ggplot2::aes(x = .data$XVal, shape = .data$StatusLabel),
          colour = style$accent_primary,
          fill = "#FFFFFF",
          size = 2.5
        ) + ggplot2::scale_shape_manual(values = shape_map, name = NULL)
      }
      miss <- d[!avail_vec | !is.finite(d$XVal), , drop = FALSE]
      if (nrow(miss) > 0L) {
        x_mid <- if (nrow(fin) > 0L) mean(range(fin$XVal)) else 0
        p <- p + ggplot2::geom_text(
          data = miss,
          ggplot2::aes(x = x_mid, y = .data$YVal),
          label = "Unavailable",
          size = 2.7,
          colour = style$neutral
        )
      }
      if ("Facet" %in% names(d) && length(unique(d$Facet)) > 1L) {
        # Per-facet unique label key so free_y shows clean DisplayLabels
        d$RowKey <- paste0(d$Facet, "___", d$YVal)
        if (nrow(fin) > 0L) fin$RowKey <- paste0(fin$Facet, "___", fin$YVal)
        if (nrow(miss) > 0L) miss$RowKey <- paste0(miss$Facet, "___", miss$YVal)
        lbl_lookup <- stats::setNames(as.character(d$DisplayLabel %||% d$ElementKey), d$RowKey)
        p <- ggplot2::ggplot(d, ggplot2::aes(y = .data$RowKey))
        if (nrow(fin) > 0L) {
          p <- p + ggplot2::geom_point(
            data = fin,
            ggplot2::aes(x = .data$XVal, shape = .data$StatusLabel),
            colour = style$accent_primary,
            fill = "#FFFFFF",
            size = 2.5
          ) + ggplot2::scale_shape_manual(values = shape_map, name = NULL)
        }
        if (nrow(miss) > 0L) {
          x_mid <- if (nrow(fin) > 0L) mean(range(fin$XVal)) else 0
          p <- p + ggplot2::geom_text(
            data = miss,
            ggplot2::aes(x = x_mid, y = .data$RowKey),
            label = "Unavailable",
            size = 2.7,
            colour = style$neutral
          )
        }
        d_ord <- d[order(d$Facet, d$YVal), , drop = FALSE]
        p <- p +
          ggplot2::scale_y_discrete(limits = unique(d_ord$RowKey), labels = lbl_lookup) +
          ggplot2::facet_wrap(~ Facet, scales = "free_y") +
          .mfrmr_gg_theme_styled(style$name)
      } else {
        p <- p +
          ggplot2::scale_y_continuous(breaks = d$YVal, labels = d$DisplayLabel %||% d$ElementKey) +
          .mfrmr_gg_theme_styled(style$name)
      }
    } else if (identical(view_type, "wright")) {
      facets_ord <- unique(as.character(d$Facet))
      fin$FacetFactor <- factor(as.character(fin$Facet), levels = facets_ord)
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$FacetFactor, y = .data$YVal, shape = .data$StatusLabel)) +
        ggplot2::geom_point(
          position = ggplot2::position_jitter(width = 0.08, height = 0, seed = 1),
          colour = style$accent_primary,
          fill = "#FFFFFF",
          size = 2.4
        ) +
        ggplot2::scale_shape_manual(values = shape_map, name = NULL) +
        ggplot2::scale_x_discrete(drop = FALSE) +
        .mfrmr_gg_theme_styled(style$name)
    } else if (identical(view_type, "infit_outfit")) {
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$XVal, y = .data$YVal, shape = .data$StatusLabel)) +
        ggplot2::geom_vline(xintercept = 1, linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_point(colour = style$accent_primary, fill = "#FFFFFF", size = 2.4, alpha = 0.88) +
        ggplot2::scale_shape_manual(values = shape_map, name = NULL) +
        .mfrmr_gg_theme_styled(style$name)
      if ("Panel" %in% names(d) && length(unique(d$Panel)) > 1L) {
        p <- p + ggplot2::facet_wrap(~ Panel)
      }
    } else {
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$XVal, y = .data$YVal, shape = .data$StatusLabel)) +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_point(colour = style$accent_primary, fill = "#FFFFFF", size = 2.4, alpha = 0.88) +
        ggplot2::scale_shape_manual(values = shape_map, name = NULL) +
        .mfrmr_gg_theme_styled(style$name)
      if ("Panel" %in% names(d) && length(unique(d$Panel)) > 1L) {
        p <- p + ggplot2::facet_wrap(~ Panel)
      }
    }
    if (!show_leg) p <- p + ggplot2::theme(legend.position = "none")
    p <- .mfrmr_gg_labs(p, payload, x = payload$xlab, y = payload$ylab)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "fair_reference_intervals")) {
    pd <- as.data.frame(payload$plot_data %||% data.frame(), stringsAsFactors = FALSE)
    if (!nrow(pd)) {
      p <- .mfrmr_empty_ggplot("No common-plan interval rows available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    ci_ok <- is.finite(pd$Lower) & is.finite(pd$Upper)
    pt_ok <- is.finite(pd$X)
    p <- ggplot2::ggplot(pd, ggplot2::aes(y = .data$Y))
    if (any(ci_ok)) {
      p <- p + ggplot2::geom_segment(
        data = pd[ci_ok, , drop = FALSE],
        ggplot2::aes(x = .data$Lower, xend = .data$Upper, yend = .data$Y),
        colour = style$accent_primary,
        linewidth = 0.75
      )
    }
    if (any(pt_ok)) {
      p <- p + ggplot2::geom_point(
        data = pd[pt_ok, , drop = FALSE],
        ggplot2::aes(x = .data$X),
        colour = style$accent_primary,
        size = 2.7
      )
    }
    if (any(!pt_ok)) {
      x_mid <- if (any(pt_ok)) mean(range(pd$X[pt_ok])) else 0
      p <- p + ggplot2::geom_text(
        data = pd[!pt_ok, , drop = FALSE],
        ggplot2::aes(x = x_mid, y = .data$Y),
        label = "Unavailable",
        colour = style$neutral,
        size = 2.9
      )
    }
    p <- p +
      ggplot2::scale_y_continuous(breaks = pd$Y, labels = pd$Label) +
      .mfrmr_gg_theme_styled(style$name)
    p <- .mfrmr_gg_labs(p, payload, x = payload$xlab %||% "Expected score", y = NULL)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "person_fit")) {
    df <- as.data.frame(payload$data %||% data.frame(), stringsAsFactors = FALSE)
    view_kind <- if ("Infit" %in% names(df) && "Outfit" %in% names(df) && grepl("scatter|vs", tolower(payload$title %||% ""))) "scatter" else "ranked"
    if (nrow(df) > 0L && all(c("X", "Y") %in% names(df))) {
      fin <- df[is.finite(df$X) & is.finite(df$Y), , drop = FALSE]
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$X, y = .data$Y)) +
        ggplot2::geom_point(colour = style$accent_primary, size = 2.3, alpha = 0.82) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_add_references(p, payload$reference_lines)
      p <- .mfrmr_gg_labs(p, payload, x = payload$xlab, y = payload$ylab)
      if (identical(view_kind, "scatter")) {
        p <- .mfrmr_attach_marginal_histograms(p, x = fin$X, y = fin$Y, marginal = payload$marginal %||% "auto", preset = style$name)
      }
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
  }

  if (identical(nm, "displacement")) {
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    plot_type <- as.character(payload$plot %||% "lollipop")[1L]
    if (nrow(tbl) > 0L && "Displacement" %in% names(tbl)) {
      tbl <- tbl[is.finite(tbl$Displacement), , drop = FALSE]
      tbl$Label <- if (all(c("Facet", "Level") %in% names(tbl))) paste(tbl$Facet, tbl$Level, sep = ": ") else as.character(seq_len(nrow(tbl)))
      if (identical(plot_type, "scatter") && "Measure" %in% names(tbl)) {
        fin <- tbl[is.finite(tbl$Measure) & is.finite(tbl$Displacement), , drop = FALSE]
        p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$Measure, y = .data$Displacement)) +
          ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = style$ref_line) +
          ggplot2::geom_point(colour = style$accent_primary, size = 2.5, alpha = 0.85) +
          .mfrmr_gg_theme_styled(style$name)
        p <- .mfrmr_gg_add_references(p, payload$reference_lines)
        p <- .mfrmr_gg_labs(p, payload, x = "Measure (logits)", y = "Displacement (logits)")
        p <- .mfrmr_attach_marginal_histograms(
          p,
          x = fin$Measure,
          y = fin$Displacement,
          marginal = payload$marginal %||% "auto",
          preset = style$name
        )
      } else {
        tbl$Row <- seq_len(nrow(tbl))
        p <- ggplot2::ggplot(tbl, ggplot2::aes(x = .data$Displacement, y = .data$Row)) +
          ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line) +
          ggplot2::geom_segment(ggplot2::aes(x = 0, xend = .data$Displacement, yend = .data$Row), colour = style$neutral) +
          ggplot2::geom_point(colour = style$accent_primary, size = 2.6) +
          ggplot2::scale_y_reverse(breaks = tbl$Row, labels = tbl$Label) +
          .mfrmr_gg_theme_styled(style$name)
        p <- .mfrmr_gg_add_references(p, payload$reference_lines)
        p <- .mfrmr_gg_labs(p, payload, x = "Displacement (logits)", y = NULL)
      }
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
  }

  if (identical(nm, "recovery_simulation")) {
    pt <- as.data.frame(payload$plot_table %||% data.frame(), stringsAsFactors = FALSE)
    vtype <- as.character(payload$type %||% "summary")[1L]
    if (nrow(pt) > 0L && all(c("TruthForPlot", "EstimateForPlot") %in% names(pt))) {
      fin <- pt[is.finite(pt$TruthForPlot) & is.finite(pt$EstimateForPlot), , drop = FALSE]
      groups <- unique(as.character(fin$PlotGroup %||% "Parameter"))
      fin$GroupFactor <- factor(as.character(fin$PlotGroup %||% "Parameter"), levels = groups)
      cols <- stats::setNames(rep(style$series, length.out = length(groups)), groups)
      lim <- range(c(fin$TruthForPlot, fin$EstimateForPlot), finite = TRUE)
      pad <- max(0.1, 0.08 * diff(lim))
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$TruthForPlot, y = .data$EstimateForPlot, colour = .data$GroupFactor)) +
        ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_point(size = 2.2, alpha = 0.82) +
        ggplot2::scale_colour_manual(values = cols, name = NULL) +
        ggplot2::coord_equal(xlim = lim + c(-pad, pad), ylim = lim + c(-pad, pad)) +
        .mfrmr_gg_theme_styled(style$name)
      if (length(groups) <= 1L) p <- p + ggplot2::guides(colour = "none")
      p <- .mfrmr_gg_labs(p, payload, x = "True parameter", y = payload$metric_label %||% "Estimated parameter")
      p <- .mfrmr_attach_marginal_histograms(
        p,
        x = fin$TruthForPlot,
        y = fin$EstimateForPlot,
        marginal = payload$marginal %||% "auto",
        preset = style$name
      )
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (nrow(pt) > 0L && all(c("ErrorForPlot", "PlotGroup") %in% names(pt))) {
      fin <- pt[is.finite(pt$ErrorForPlot), , drop = FALSE]
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$PlotGroup, y = .data$ErrorForPlot)) +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_boxplot(fill = style$fill_soft, colour = style$axis, outlier.size = 1.2) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 30, hjust = 1))
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = payload$metric_label %||% "Estimation error")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (nrow(pt) > 0L && all(c("Status", "Reps") %in% names(pt))) {
      pt$Pos <- seq_len(nrow(pt))
      status_cols <- c(converged = style$success, not_converged = style$warn, failed = style$fail)
      pt$BarFill <- unname(status_cols[as.character(pt$Status)])
      pt$BarFill[is.na(pt$BarFill)] <- style$neutral
      p <- ggplot2::ggplot(pt, ggplot2::aes(x = .data$Pos, y = .data$Reps, fill = .data$BarFill)) +
        ggplot2::geom_col(width = 0.65) +
        ggplot2::scale_fill_identity() +
        ggplot2::scale_x_continuous(breaks = pt$Pos, labels = pt$Status) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = "Replications")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (nrow(pt) > 0L && all(c("PlotGroup", "Value") %in% names(pt))) {
      pt$Pos <- seq_len(nrow(pt))
      p <- ggplot2::ggplot(pt[is.finite(pt$Value), , drop = FALSE], ggplot2::aes(x = .data$Pos, y = .data$Value)) +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_col(fill = style$accent_primary, width = 0.68) +
        ggplot2::scale_x_continuous(breaks = pt$Pos, labels = truncate_axis_label(pt$PlotGroup, 26L)) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 30, hjust = 1))
      if (as.character(payload$metric %||% "")[1L] %in% c("Coverage95", "SEAvailableRate")) {
        p <- p + ggplot2::coord_cartesian(ylim = c(0, 1))
      }
      p <- .mfrmr_gg_add_references(p, payload$reference_lines)
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = payload$metric_label %||% "Value")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
  }

  if (identical(nm, "recovery_assessment")) {
    vtype <- as.character(payload$type %||% "status")[1L]
    if (identical(vtype, "status")) {
      st <- as.data.frame(payload$status_counts %||% data.frame(), stringsAsFactors = FALSE)
      if (!nrow(st) || !all(c("Status", "Checks") %in% names(st))) {
        p <- .mfrmr_empty_ggplot("No recovery-assessment checklist statuses available.", payload = payload, preset = style$name)
      } else {
        st$Pos <- seq_len(nrow(st))
        st$Fill <- recovery_assessment_status_palette(as.character(st$Status))
        p <- ggplot2::ggplot(st, ggplot2::aes(x = .data$Pos, y = .data$Checks, fill = .data$Fill)) +
          ggplot2::geom_col(width = 0.65) +
          ggplot2::scale_fill_identity() +
          ggplot2::scale_x_continuous(breaks = st$Pos, labels = as.character(st$Status)) +
          .mfrmr_gg_theme_styled(style$name)
        p <- .mfrmr_gg_labs(p, payload, x = NULL, y = "Checklist checks")
      }
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    pt <- as.data.frame(payload$plot_table %||% data.frame(), stringsAsFactors = FALSE)
    if (!nrow(pt) || !all(c("PlotGroup", "Value", "Status") %in% names(pt))) {
      p <- .mfrmr_empty_ggplot("No recovery-assessment metric rows available.", payload = payload, preset = style$name)
    } else {
      pt <- pt[is.finite(pt$Value), , drop = FALSE]
      pt$Pos <- seq_len(nrow(pt))
      pt$Fill <- recovery_assessment_status_palette(as.character(pt$Status))
      p <- ggplot2::ggplot(pt, ggplot2::aes(x = .data$Pos, y = .data$Value, fill = .data$Fill)) +
        ggplot2::geom_col(width = 0.68) +
        ggplot2::scale_fill_identity() +
        ggplot2::scale_x_continuous(breaks = pt$Pos, labels = truncate_axis_label(pt$PlotGroup, 26L)) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 30, hjust = 1))
      p <- .mfrmr_gg_add_references(p, payload$reference_lines)
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = payload$metric_label %||% "Value")
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "diagnostic_screening")) {
    pt <- as.data.frame(payload$plot_long %||% payload$plot_table %||% data.frame(), stringsAsFactors = FALSE)
    x_var <- as.character(payload$x_var %||% "")[1L]
    if (!nrow(pt) || !nzchar(x_var) || !x_var %in% names(pt) || !"Value" %in% names(pt)) {
      p <- .mfrmr_empty_ggplot("No finite diagnostic-screening values available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    pt$.mfrmr_x <- suppressWarnings(as.numeric(pt[[x_var]]))
    pt$.mfrmr_y <- suppressWarnings(as.numeric(pt$Value))
    pt$.mfrmr_group <- if ("group" %in% names(pt)) as.character(pt$group) else "Signal"
    pt <- pt[is.finite(pt$.mfrmr_x) & is.finite(pt$.mfrmr_y), , drop = FALSE]
    if (!nrow(pt)) {
      p <- .mfrmr_empty_ggplot("No finite diagnostic-screening values available.", payload = payload, preset = style$name)
    } else {
      grps <- unique(pt$.mfrmr_group)
      pt$.mfrmr_group_factor <- factor(pt$.mfrmr_group, levels = grps)
      cols_ds <- stats::setNames(rep(style$series, length.out = length(grps)), grps)
      p <- ggplot2::ggplot(pt, ggplot2::aes(x = .data$.mfrmr_x, y = .data$.mfrmr_y, colour = .data$.mfrmr_group_factor, group = .data$.mfrmr_group_factor)) +
        ggplot2::geom_line(linewidth = 0.8) +
        ggplot2::geom_point(size = 2.4) +
        ggplot2::scale_colour_manual(values = cols_ds, name = NULL) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(legend.position = "bottom")
      p <- .mfrmr_gg_labs(
        p, payload,
        x = payload$x_label %||% x_var,
        y = paste("Diagnostic-screening", as.character(payload$metric %||% "value")[1L])
      )
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "response_time_review")) {
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    thr <- as.data.frame(payload$thresholds %||% data.frame(), stringsAsFactors = FALSE)
    unit <- as.character(payload$overview$TimeUnit[1L] %||% "seconds")
    vtype <- as.character(payload$type %||% "distribution")[1L]
    thr_vals <- suppressWarnings(as.numeric(thr$Value))
    if (identical(vtype, "distribution")) {
      vals <- suppressWarnings(as.numeric(tbl$LogTime))
      vals <- vals[is.finite(vals)]
      if (!length(vals)) {
        p <- .mfrmr_empty_ggplot("No valid times are available for these groups.", payload = payload, preset = style$name)
      } else {
        n_bins <- if (length(unique(vals)) < 2L) 5L else min(20L, max(5L, as.integer(sqrt(length(vals)))))
        p <- ggplot2::ggplot(data.frame(LogTime = vals), ggplot2::aes(x = .data$LogTime)) +
          ggplot2::geom_histogram(bins = n_bins, fill = style$hist_fill, colour = "#FFFFFF", alpha = 0.88)
        log_thr <- suppressWarnings(log(thr_vals))
        if (length(log_thr) >= 1L && is.finite(log_thr[1L])) {
          p <- p + ggplot2::geom_vline(xintercept = log_thr[1L], linetype = "dashed", colour = style$warn, linewidth = 0.7)
        }
        if (length(log_thr) >= 2L && is.finite(log_thr[2L])) {
          p <- p + ggplot2::geom_vline(xintercept = log_thr[2L], linetype = "dotted", colour = style$accent_secondary, linewidth = 0.7)
        }
        p <- p + .mfrmr_gg_theme_styled(style$name)
        p <- .mfrmr_gg_labs(p, payload, x = paste0("log response time (", unit, ")"), y = "Count")
      }
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    med <- suppressWarnings(as.numeric(tbl$MedianTime))
    if (!nrow(tbl) || !any(is.finite(med))) {
      p <- .mfrmr_empty_ggplot("No valid times are available for these groups.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(vtype, "score")) {
      tbl$Pos <- seq_len(nrow(tbl))
      tbl$Med <- med
      fin <- tbl[is.finite(tbl$Med), , drop = FALSE]
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$Pos, y = .data$Med)) +
        ggplot2::geom_line(colour = style$accent_primary, linewidth = 0.8) +
        ggplot2::geom_point(shape = 21, fill = style$accent_primary, colour = "#FFFFFF", stroke = 0.45, size = 2.8) +
        ggplot2::scale_x_continuous(breaks = tbl$Pos, labels = as.character(tbl$Score))
      if (length(thr_vals) >= 1L && is.finite(thr_vals[1L])) {
        p <- p + ggplot2::geom_hline(yintercept = thr_vals[1L], linetype = "dashed", colour = style$warn, linewidth = 0.7)
      }
      if (length(thr_vals) >= 2L && is.finite(thr_vals[2L])) {
        p <- p + ggplot2::geom_hline(yintercept = thr_vals[2L], linetype = "dotted", colour = style$accent_secondary, linewidth = 0.7)
      }
      p <- p + .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Score", y = paste0("Median time (", unit, ")"))
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    label_col <- if (identical(vtype, "person")) "Person" else "Level"
    tbl$Row <- seq_len(nrow(tbl))
    tbl$Med <- med
    fin <- tbl[is.finite(tbl$Med), , drop = FALSE]
    p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$Med, y = .data$Row)) +
      ggplot2::geom_point(shape = 21, fill = style$accent_primary, colour = "#FFFFFF", stroke = 0.45, size = 2.8) +
      ggplot2::scale_y_continuous(breaks = tbl$Row, labels = as.character(tbl[[label_col]]))
    if (length(thr_vals) >= 1L && is.finite(thr_vals[1L])) {
      p <- p + ggplot2::geom_vline(xintercept = thr_vals[1L], linetype = "dashed", colour = style$warn, linewidth = 0.7)
    }
    if (length(thr_vals) >= 2L && is.finite(thr_vals[2L])) {
      p <- p + ggplot2::geom_vline(xintercept = thr_vals[2L], linetype = "dotted", colour = style$accent_secondary, linewidth = 0.7)
    }
    p <- p + .mfrmr_gg_theme_styled(style$name)
    p <- .mfrmr_gg_labs(p, payload, x = paste0("Median time (", unit, ")"), y = NULL)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "structural_design_review")) {
    lbls <- payload$label
    vals <- payload$value
    if ((is.null(lbls) || is.null(vals)) && is.data.frame(payload$table) && nrow(payload$table) > 0L) {
      tdf <- payload$table
      p_kind <- as.character(payload$plot %||% "")[1L]
      lbls <- if (p_kind == "selection_handoff_bundles" && all(c("AppendixSection", "Bundle") %in% names(tdf))) {
        paste0(tdf$AppendixSection, " :: ", tdf$Bundle)
      } else if (p_kind == "selection_handoff_role_sections" && all(c("AppendixSection", "Role") %in% names(tdf))) {
        paste0(tdf$AppendixSection, " :: ", tdf$Role)
      } else {
        chr_c <- intersect(c("Preset", "Table", "AppendixSection", "Bundle", "Role"), names(tdf))[1L]
        if (!is.na(chr_c)) as.character(tdf[[chr_c]]) else as.character(seq_len(nrow(tdf)))
      }
      num_c <- if (identical(payload$selection_value, "fraction")) {
        intersect(c("PlotReadyFraction", "SelectedFraction", "RowFraction"), names(tdf))[1L]
      } else {
        intersect(c("PlotReadyTables", "TablesSelected", "Tables", "Rows"), names(tdf))[1L]
      }
      if (is.na(num_c)) num_c <- names(tdf)[vapply(tdf, is.numeric, logical(1))][1L]
      vals <- if (!is.na(num_c)) tdf[[num_c]] else numeric()
    }
    df <- data.frame(
      Pos = seq_along(vals),
      Label = as.character(lbls),
      Value = suppressWarnings(as.numeric(vals)),
      stringsAsFactors = FALSE
    )
    df <- df[is.finite(df$Value) & nzchar(df$Label), , drop = FALSE]
    if (!nrow(df)) {
      p <- .mfrmr_empty_ggplot("No finite structural-design values available.", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    df$Pos <- seq_len(nrow(df))
    bar_fill <- if (is.data.frame(payload$legend) && nrow(payload$legend) > 0L && "value" %in% names(payload$legend)) {
      as.character(payload$legend$value[1L])
    } else {
      style$accent_primary
    }
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Pos, y = .data$Value)) +
      ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = style$ref_line) +
      ggplot2::geom_col(fill = bar_fill, width = 0.68) +
      ggplot2::scale_x_continuous(breaks = df$Pos, labels = truncate_axis_label(df$Label, 24L)) +
      .mfrmr_gg_theme_styled(style$name) +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
    p <- .mfrmr_gg_labs(p, payload, x = NULL, y = payload$ylab %||% payload$legend$label[1L] %||% "Value")
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "facet_quality_dashboard")) {
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    plot_kind <- as.character(payload$plot %||% "severity")[1L]
    if (!nrow(tbl)) {
      msg <- if (identical(plot_kind, "flags")) "No flagged facet levels." else "No finite severity estimates available."
      p <- .mfrmr_empty_ggplot(msg, payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    lbl_col <- intersect(c("Level", "Element"), names(tbl))[1L]
    tbl$Row <- seq_len(nrow(tbl))
    tbl$Label <- if (!is.na(lbl_col)) as.character(tbl[[lbl_col]]) else as.character(tbl$Row)
    if (identical(plot_kind, "flags") && "FlagCount" %in% names(tbl)) {
      tbl$Val <- suppressWarnings(as.numeric(tbl$FlagCount))
      p <- ggplot2::ggplot(tbl[is.finite(tbl$Val), , drop = FALSE], ggplot2::aes(x = .data$Val, y = .data$Row)) +
        ggplot2::geom_col(orientation = "y", fill = style$warn, width = 0.68) +
        ggplot2::scale_y_reverse(breaks = tbl$Row, labels = tbl$Label) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Flag count", y = NULL)
    } else {
      tbl$Val <- suppressWarnings(as.numeric(tbl$Estimate))
      sw <- suppressWarnings(as.numeric(payload$thresholds$severity_warn %||% NA_real_))[1L]
      tbl$Flagged <- if ("AnyFlag" %in% names(tbl)) tbl$AnyFlag %in% TRUE else FALSE
      p <- ggplot2::ggplot(tbl[is.finite(tbl$Val), , drop = FALSE], ggplot2::aes(x = .data$Val, y = .data$Row)) +
        ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line)
      if (is.finite(sw) && sw > 0) {
        p <- p + ggplot2::geom_vline(xintercept = c(-sw, sw), linetype = "dotted", colour = style$warn)
      }
      p <- p +
        ggplot2::geom_segment(ggplot2::aes(x = 0, xend = .data$Val, yend = .data$Row), colour = style$neutral) +
        ggplot2::geom_point(ggplot2::aes(colour = .data$Flagged), size = 2.6, show.legend = FALSE) +
        ggplot2::scale_colour_manual(values = c(`FALSE` = style$accent_primary, `TRUE` = style$fail)) +
        ggplot2::scale_y_reverse(breaks = tbl$Row, labels = tbl$Label) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Estimate (logits)", y = NULL)
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (nm %in% c("apa_table", "summary_table_bundle")) {
    p_kind <- as.character(payload$plot %||% "")[1L]
    bar_fill <- if (is.data.frame(payload$legend) && nrow(payload$legend) > 0L && "value" %in% names(payload$legend)) {
      as.character(payload$legend$value[1L])
    } else {
      style$accent_primary
    }
    if (identical(p_kind, "first_numeric")) {
      vals <- suppressWarnings(as.numeric(payload$values))
      vals <- vals[is.finite(vals)]
      if (!length(vals)) {
        p <- .mfrmr_empty_ggplot("No finite values available.", payload = payload, preset = style$name)
      } else {
        n_bins <- min(20L, max(5L, as.integer(sqrt(length(vals)))))
        p <- ggplot2::ggplot(data.frame(Val = vals), ggplot2::aes(x = .data$Val)) +
          ggplot2::geom_histogram(bins = n_bins, fill = bar_fill, colour = "#FFFFFF", alpha = 0.88) +
          .mfrmr_gg_theme_styled(style$name)
        p <- .mfrmr_gg_labs(p, payload, x = as.character(payload$column %||% "Value")[1L], y = "Count")
      }
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(p_kind, "appendix_roles")) {
      roles <- as.character(payload$role %||% character())
      rec <- suppressWarnings(as.numeric(payload$recommended_tables))
      cmp <- suppressWarnings(as.numeric(payload$compact_tables))
      long <- rbind(
        data.frame(Role = roles, Group = "Recommended", Tables = rec, stringsAsFactors = FALSE),
        data.frame(Role = roles, Group = "Compact", Tables = cmp, stringsAsFactors = FALSE)
      )
      long <- long[is.finite(long$Tables) & nzchar(long$Role), , drop = FALSE]
      long$RoleFactor <- factor(long$Role, levels = unique(roles))
      long$GroupFactor <- factor(long$Group, levels = c("Recommended", "Compact"))
      cols_ar <- c(Recommended = "#2a9d8f", Compact = "#8d99ae")
      if (is.list(payload$legend) && length(payload$legend) >= 2L) {
        c1 <- payload$legend[[1L]]$value[1L]
        c2 <- payload$legend[[2L]]$value[1L]
        if (!is.null(c1) && !is.null(c2)) cols_ar <- c(Recommended = as.character(c1), Compact = as.character(c2))
      }
      p <- ggplot2::ggplot(long, ggplot2::aes(x = .data$RoleFactor, y = .data$Tables, fill = .data$GroupFactor)) +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.75), width = 0.68) +
        ggplot2::scale_fill_manual(values = cols_ar, name = NULL) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = "Tables")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    labels <- switch(
      p_kind,
      numeric_profile = payload$column,
      table_rows = payload$table,
      role_tables = payload$role,
      appendix_sections = payload$appendix_section,
      appendix_presets = payload$preset,
      payload$labels
    )
    vals <- switch(
      p_kind,
      numeric_profile = payload$mean,
      table_rows = payload$rows,
      role_tables = payload$tables,
      appendix_sections = payload$tables,
      appendix_presets = payload$tables,
      payload$values
    )
    ylab <- switch(
      p_kind,
      numeric_profile = "Mean",
      table_rows = "Rows",
      payload$ylab %||% "Tables"
    )
    if ((is.null(labels) || is.null(vals)) && is.data.frame(payload$table)) {
      tdf <- payload$table
      chr_c <- names(tdf)[vapply(tdf, function(z) is.character(z) || is.factor(z), logical(1))]
      num_c <- names(tdf)[vapply(tdf, is.numeric, logical(1))]
      if (length(chr_c) > 0L && length(num_c) > 0L) {
        labels <- as.character(tdf[[chr_c[1L]]])
        vals <- suppressWarnings(as.numeric(tdf[[num_c[1L]]]))
      }
    }
    df_b <- data.frame(
      Pos = seq_along(vals),
      Label = as.character(labels),
      Value = suppressWarnings(as.numeric(vals)),
      stringsAsFactors = FALSE
    )
    df_b <- df_b[is.finite(df_b$Value) & nzchar(df_b$Label), , drop = FALSE]
    if (!nrow(df_b)) {
      p <- .mfrmr_empty_ggplot("No finite summary values available.", payload = payload, preset = style$name)
    } else {
      df_b$Pos <- seq_len(nrow(df_b))
      p <- ggplot2::ggplot(df_b, ggplot2::aes(x = .data$Pos, y = .data$Value)) +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_col(fill = bar_fill, width = 0.68) +
        ggplot2::scale_x_continuous(breaks = df_b$Pos, labels = truncate_axis_label(df_b$Label, 28L)) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = ylab)
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  bar_helper <- function(labels, values, ylab = "Value", fill = style$accent_primary,
                         h_ref = NULL, empty_msg = "No finite values available.") {
    df_h <- data.frame(
      Label = as.character(labels),
      Value = suppressWarnings(as.numeric(values)),
      Fill = rep(as.character(fill), length.out = max(1L, length(values)))[seq_along(values)],
      stringsAsFactors = FALSE
    )
    df_h <- df_h[is.finite(df_h$Value) & nzchar(df_h$Label), , drop = FALSE]
    if (!nrow(df_h)) {
      return(.mfrmr_empty_ggplot(empty_msg, payload = payload, preset = style$name))
    }
    df_h$Pos <- seq_len(nrow(df_h))
    g <- ggplot2::ggplot(df_h, ggplot2::aes(x = .data$Pos, y = .data$Value))
    if (!is.null(h_ref) && length(h_ref) > 0L) {
      g <- g + ggplot2::geom_hline(yintercept = h_ref, linetype = "dashed", colour = style$ref_line)
    }
    g <- g +
      ggplot2::geom_col(ggplot2::aes(fill = .data$Fill), width = 0.68) +
      ggplot2::scale_fill_identity() +
      ggplot2::scale_x_continuous(breaks = df_h$Pos, labels = truncate_axis_label(df_h$Label, 28L)) +
      .mfrmr_gg_theme_styled(style$name) +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
    .mfrmr_gg_labs(g, payload, x = NULL, y = ylab)
  }

  if (identical(nm, "unexpected_after_bias")) {
    p_kind <- as.character(payload$plot %||% "scatter")[1L]
    if (identical(p_kind, "comparison")) {
      vals <- c(suppressWarnings(as.numeric(payload$baseline)), suppressWarnings(as.numeric(payload$after)))
      p <- bar_helper(c("Baseline", "After bias"), vals, ylab = "Unexpected responses",
                      fill = c(style$accent_secondary, style$accent_primary))
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    if (identical(p_kind, "scatter") && nrow(tbl) > 0L && all(c("StdResidual", "ObsProb") %in% names(tbl))) {
      tbl$X <- suppressWarnings(as.numeric(tbl$StdResidual))
      tbl$Y <- -log10(pmax(suppressWarnings(as.numeric(tbl$ObsProb)), .Machine$double.xmin))
      tbl$Dir <- ifelse(as.character(tbl$Direction %||% "") == "Higher than expected", "Higher than expected", "Lower than expected")
      fin <- tbl[is.finite(tbl$X) & is.finite(tbl$Y), , drop = FALSE]
      z_thr <- as.numeric(payload$thresholds$abs_z_min %||% 2)
      p_thr <- as.numeric(payload$thresholds$prob_max %||% 0.30)
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$X, y = .data$Y, colour = .data$Dir)) +
        ggplot2::geom_vline(xintercept = c(-z_thr, z_thr), linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_hline(yintercept = -log10(p_thr), linetype = "dashed", colour = style$ref_line) +
        ggplot2::geom_point(size = 2.4, alpha = 0.85) +
        ggplot2::scale_colour_manual(values = c(`Higher than expected` = style$warn, `Lower than expected` = style$accent_primary), name = NULL) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Standardized residual", y = "-log10(P_obs)")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    lbls <- if ("Row" %in% names(tbl)) paste0("Row ", tbl$Row) else paste0("Case ", seq_len(nrow(tbl)))
    p <- bar_helper(lbls, tbl$Severity, ylab = "Severity")
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "output_bundle")) {
    p_kind <- as.character(payload$plot %||% "graph_expected")[1L]
    if (identical(p_kind, "graph_expected")) {
      tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
      tbl$Measure <- suppressWarnings(as.numeric(tbl$Measure))
      tbl$Expected <- suppressWarnings(as.numeric(tbl$Expected))
      tbl$CurveGroup <- as.character(tbl$CurveGroup %||% "All")
      fin <- tbl[is.finite(tbl$Measure) & is.finite(tbl$Expected), , drop = FALSE]
      fin <- fin[order(fin$CurveGroup, fin$Measure), , drop = FALSE]
      grps <- unique(fin$CurveGroup)
      cols_o <- stats::setNames(rep(style$series, length.out = length(grps)), grps)
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$Measure, y = .data$Expected, colour = .data$CurveGroup, group = .data$CurveGroup)) +
        ggplot2::geom_line(linewidth = 0.8) +
        ggplot2::scale_colour_manual(values = cols_o, name = NULL) +
        .mfrmr_gg_theme_styled(style$name)
      if (length(grps) <= 1L) p <- p + ggplot2::guides(colour = "none")
      p <- .mfrmr_gg_labs(p, payload, x = "Theta / Logit", y = "Expected score")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    vals <- suppressWarnings(as.numeric(payload$values))
    vals <- vals[is.finite(vals)]
    if (!length(vals)) {
      p <- .mfrmr_empty_ggplot("No finite scorefile values available.", payload = payload, preset = style$name)
    } else {
      n_bins <- min(20L, max(5L, as.integer(sqrt(length(vals)))))
      xlab <- switch(p_kind, score_residuals = "Residual", score_se = as.character(payload$se_column %||% "SE")[1L], "Observed probability")
      p <- ggplot2::ggplot(data.frame(Val = vals), ggplot2::aes(x = .data$Val)) +
        ggplot2::geom_histogram(bins = n_bins, fill = style$hist_fill, colour = "#FFFFFF", alpha = 0.88) +
        .mfrmr_gg_theme_styled(style$name)
      if (identical(p_kind, "score_residuals")) {
        p <- p + ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = style$ref_line)
      }
      p <- .mfrmr_gg_labs(p, payload, x = xlab, y = "Count")
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (nm %in% c("specifications", "anchor_review")) {
    p_kind <- as.character(payload$plot %||% "")[1L]
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    if (p_kind %in% c("anchor_constraints", "facet_constraints") && nrow(tbl) > 0L) {
      anc <- suppressWarnings(as.numeric(tbl$Anchored %||% tbl$AnchoredLevels %||% 0))
      grp <- suppressWarnings(as.numeric(tbl$Grouped %||% tbl$GroupedLevels %||% 0))
      fre <- suppressWarnings(as.numeric(tbl$Free %||% tbl$FreeLevels %||% 0))
      fre[!is.finite(fre)] <- 0
      f_names <- as.character(tbl$Facet)
      long <- rbind(
        data.frame(Facet = f_names, Status = "Anchored", Count = anc, stringsAsFactors = FALSE),
        data.frame(Facet = f_names, Status = "Grouped", Count = grp, stringsAsFactors = FALSE),
        data.frame(Facet = f_names, Status = "Free", Count = fre, stringsAsFactors = FALSE)
      )
      long$FacetFactor <- factor(long$Facet, levels = unique(f_names))
      long$StatusFactor <- factor(long$Status, levels = c("Anchored", "Grouped", "Free"))
      p <- ggplot2::ggplot(long[is.finite(long$Count), , drop = FALSE], ggplot2::aes(x = .data$FacetFactor, y = .data$Count, fill = .data$StatusFactor)) +
        ggplot2::geom_col(width = 0.68, colour = "#FFFFFF", linewidth = 0.2) +
        ggplot2::scale_fill_manual(
          values = c(Anchored = style$accent_tertiary, Grouped = style$accent_secondary, Free = "#CBD5E1"),
          name = NULL
        ) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = "Levels")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(p_kind, "convergence")) {
      p <- bar_helper(tbl$Setting, tbl$Value, ylab = "Value")
    } else if (identical(p_kind, "facet_elements")) {
      p <- bar_helper(tbl$Facet, tbl$Elements, ylab = "Elements")
    } else if (identical(p_kind, "issue_counts")) {
      p <- bar_helper(tbl$Issue, tbl$N, ylab = "Rows", fill = style$fail)
    } else {
      rec <- suppressWarnings(as.numeric(tbl$RecommendedMinObs))
      rec <- rec[is.finite(rec)]
      p <- bar_helper(tbl$Facet, tbl$MinObsPerLevel, ylab = "Min observations",
                      h_ref = if (length(rec)) unique(rec)[1L] else NULL)
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "data_description")) {
    p_kind <- as.character(payload$plot %||% "score_distribution")[1L]
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    p <- switch(
      p_kind,
      facet_levels = bar_helper(tbl$Facet, tbl$Levels, ylab = "Levels", fill = style$success),
      missing = bar_helper(tbl$Column, tbl$Missing, ylab = "Missing", fill = style$accent_tertiary),
      bar_helper(tbl$Score, tbl$WeightedN, ylab = "Weighted N", fill = style$accent_primary)
    )
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "measurable")) {
    p_kind <- as.character(payload$plot %||% "facet_coverage")[1L]
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    p <- switch(
      p_kind,
      category_counts = bar_helper(tbl$Category, tbl$Count, ylab = "Count", fill = style$success),
      subset_observations = bar_helper(paste0("Subset ", tbl$Subset), tbl$Observations, ylab = "Observations", fill = style$accent_tertiary),
      bar_helper(tbl$Facet, tbl$Levels, ylab = "Levels", fill = style$accent_primary)
    )
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "export_bundle")) {
    p_kind <- as.character(payload$plot %||% "formats")[1L]
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    lbls <- if (p_kind %in% c("selection_handoff_bundles") && all(c("AppendixSection", "Bundle") %in% names(tbl))) {
      paste0(tbl$AppendixSection, " :: ", tbl$Bundle)
    } else if (p_kind %in% c("selection_handoff_role_sections") && all(c("AppendixSection", "Role") %in% names(tbl))) {
      paste0(tbl$AppendixSection, " :: ", tbl$Role)
    } else {
      chr_c <- names(tbl)[vapply(tbl, function(z) is.character(z) || is.factor(z), logical(1))][1L]
      if (!is.na(chr_c)) as.character(tbl[[chr_c]]) else as.character(seq_len(nrow(tbl)))
    }
    num_c <- if (identical(payload$selection_value, "fraction")) {
      intersect(c("PlotReadyFraction", "SelectedFraction", "RowFraction"), names(tbl))[1L]
    } else {
      NA_character_
    }
    if (is.na(num_c)) {
      num_c <- intersect(c("Files", "PlotReadyTables", "TablesSelected", "Tables", "Rows"), names(tbl))[1L]
    }
    if (is.na(num_c)) num_c <- names(tbl)[vapply(tbl, is.numeric, logical(1))][1L]
    vals <- if (!is.na(num_c)) tbl[[num_c]] else numeric()
    bar_c <- if (is.data.frame(payload$legend) && nrow(payload$legend) > 0L && "value" %in% names(payload$legend)) {
      as.character(payload$legend$value[1L])
    } else style$accent_primary
    p <- bar_helper(lbls, vals, ylab = num_c %||% "Files", fill = bar_c)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "data_quality")) {
    p_kind <- as.character(payload$plot %||% "dashboard")[1L]
    if (identical(p_kind, "dashboard")) {
      mk_panel <- function(df_p, lcol, vcol, ttl, msg) {
        df_p <- as.data.frame(df_p %||% data.frame(), stringsAsFactors = FALSE)
        if (!nrow(df_p) || !all(c(lcol, vcol) %in% names(df_p))) {
          return(.mfrmr_empty_ggplot(msg, preset = style$name) + ggplot2::labs(subtitle = ttl))
        }
        df_p$Val <- suppressWarnings(as.numeric(df_p[[vcol]]))
        df_p <- df_p[is.finite(df_p$Val), , drop = FALSE]
        if (!nrow(df_p)) return(.mfrmr_empty_ggplot(msg, preset = style$name) + ggplot2::labs(subtitle = ttl))
        df_p$Pos <- seq_len(nrow(df_p))
        ggplot2::ggplot(df_p, ggplot2::aes(x = .data$Pos, y = .data$Val)) +
          ggplot2::geom_col(fill = style$accent_primary, width = 0.68) +
          ggplot2::scale_x_continuous(breaks = df_p$Pos, labels = truncate_axis_label(df_p[[lcol]], 18L)) +
          .mfrmr_gg_theme_styled("compact") +
          ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1)) +
          ggplot2::labs(subtitle = ttl, x = NULL, y = vcol)
      }
      fcu <- as.data.frame(payload$facet_category_usage %||% data.frame(), stringsAsFactors = FALSE)
      if (nrow(fcu) > 0L && all(c("Facet", "Level") %in% names(fcu))) fcu$Elem <- paste(fcu$Facet, fcu$Level, sep = ": ")
      p1 <- mk_panel(payload$row_review, "Status", "N", "Row review", "No row-review table")
      p2 <- mk_panel(payload$score_support, "Score", "Count", "Score support", "No score-support table")
      p3 <- mk_panel(fcu, "Elem", "IssueCategories", "Facet category use", "No facet category summary")
      p4 <- mk_panel(payload$missing_rows, "Field", "Count", "Missing/invalid rows", "No row-count fields")
      p <- .mfrm_compose_ggplots(list(p1, p2, p3, p4), ncol = 2L, payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    if (identical(p_kind, "quality_flags")) {
      if (!nrow(tbl)) {
        p <- .mfrmr_empty_ggplot("No priority QC flags", payload = payload, preset = style$name)
      } else {
        fills <- ifelse((tbl$HighSeverityFlags %||% 0) > 0, style$fail, style$warn)
        p <- bar_helper(tbl$Area, tbl$Flags, ylab = "Flags", fill = fills)
      }
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(p_kind, "score_map")) {
      tbl$Pos <- seq_len(nrow(tbl))
      y_v <- suppressWarnings(as.numeric(tbl$InternalNumeric))
      if (any(!is.finite(y_v))) y_v <- tbl$Pos
      tbl$YVal <- y_v
      tbl$StatusFactor <- factor(ifelse(tbl$MappingStatus == "recoded", "Recoded", "Identity"), levels = c("Identity", "Recoded"))
      p <- ggplot2::ggplot(tbl, ggplot2::aes(x = .data$Pos, y = .data$YVal)) +
        ggplot2::geom_line(colour = style$neutral, linewidth = 0.6) +
        ggplot2::geom_point(ggplot2::aes(colour = .data$StatusFactor), size = 2.8) +
        ggplot2::scale_colour_manual(values = c(Identity = style$accent_tertiary, Recoded = style$accent_secondary), name = NULL) +
        ggplot2::scale_x_continuous(breaks = tbl$Pos, labels = as.character(tbl$OriginalScore)) +
        .mfrmr_gg_theme_styled(style$name)
      if (!any(tbl$MappingStatus == "recoded", na.rm = TRUE)) p <- p + ggplot2::guides(colour = "none")
      p <- .mfrmr_gg_labs(p, payload, x = "Original score", y = "Internal score")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    p <- switch(
      p_kind,
      row_review = bar_helper(tbl$Status, tbl$N, ylab = "Rows"),
      facet_category_usage = bar_helper(paste(tbl$Facet, tbl$Level, sep = ": "), tbl$IssueCategories, ylab = "Zero or sparse categories"),
      facet_response_patterns = bar_helper(paste(tbl$Facet, tbl$Level, sep = ": "), 100 * suppressWarnings(as.numeric(tbl$DominantPercent)), ylab = "Dominant score (%)", h_ref = 95),
      missing_rows = bar_helper(tbl$Field, tbl$Count, ylab = "Rows", fill = style$accent_secondary),
      bar_helper(tbl$Score, tbl$Count, ylab = "Count", fill = style$accent_tertiary)
    )
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "fit_measures")) {
    p_kind <- as.character(payload$plot %||% "status")[1L]
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    if (identical(p_kind, "status")) {
      p <- bar_helper(tbl$FitStatus, tbl$Rows, ylab = "Rows")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(p_kind, "df_sensitivity")) {
      lbls <- paste(tbl$Facet, tbl$Level, sep = ": ")
      thr_v <- suppressWarnings(as.numeric(payload$thresholds))
      thr_v <- thr_v[is.finite(thr_v)]
      p <- bar_helper(lbls, tbl$MaxAbsZSTDDiff_FACETS_vs_ENGINE, ylab = "Max |ZSTD difference|", h_ref = thr_v)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    if (identical(p_kind, "infit_outfit")) {
      tbl$InfitVal <- suppressWarnings(as.numeric(tbl$Infit))
      tbl$OutfitVal <- suppressWarnings(as.numeric(tbl$Outfit))
      fin <- tbl[is.finite(tbl$InfitVal) & is.finite(tbl$OutfitVal), , drop = FALSE]
      fr <- suppressWarnings(as.numeric(payload$fit_range %||% c(0.5, 1.5)))
      p <- ggplot2::ggplot(fin, ggplot2::aes(x = .data$InfitVal, y = .data$OutfitVal, colour = .data$FitStatus)) +
        ggplot2::geom_vline(xintercept = c(fr[1L], 1, fr[2L]), linetype = c("dotted", "dashed", "dotted"), colour = style$ref_line) +
        ggplot2::geom_hline(yintercept = c(fr[1L], 1, fr[2L]), linetype = c("dotted", "dashed", "dotted"), colour = style$ref_line) +
        ggplot2::geom_point(size = 2.5, alpha = 0.86) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Infit MnSq", y = "Outfit MnSq")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
  }

  if (identical(nm, "iteration_report")) {
    p_kind <- as.character(payload$plot %||% "residual")[1L]
    it <- suppressWarnings(as.numeric(payload$iteration))
    if (identical(p_kind, "objective")) {
      obj_v <- suppressWarnings(as.numeric(payload$objective))
      df_i <- data.frame(Iteration = it, Value = obj_v, stringsAsFactors = FALSE)
      df_i <- df_i[is.finite(df_i$Iteration) & is.finite(df_i$Value), , drop = FALSE]
      p <- ggplot2::ggplot(df_i, ggplot2::aes(x = .data$Iteration, y = .data$Value)) +
        ggplot2::geom_line(colour = style$accent_primary, linewidth = 0.8) +
        ggplot2::geom_point(colour = style$accent_primary, size = 2.3) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = "Iteration", y = "Objective (log-likelihood proxy)")
    } else {
      s2_nm <- if (identical(p_kind, "residual")) "Categories" else "Steps"
      s2_v <- if (identical(p_kind, "residual")) payload$category else payload$step
      df_i <- rbind(
        data.frame(Iteration = it, Series = "Elements", Value = suppressWarnings(as.numeric(payload$element)), stringsAsFactors = FALSE),
        data.frame(Iteration = it, Series = s2_nm, Value = suppressWarnings(as.numeric(s2_v)), stringsAsFactors = FALSE)
      )
      df_i <- df_i[is.finite(df_i$Iteration) & is.finite(df_i$Value), , drop = FALSE]
      df_i$SeriesFactor <- factor(df_i$Series, levels = c("Elements", s2_nm))
      cols_i <- stats::setNames(c(style$accent_primary, style$accent_secondary), c("Elements", s2_nm))
      p <- ggplot2::ggplot(df_i, ggplot2::aes(x = .data$Iteration, y = .data$Value, colour = .data$SeriesFactor, shape = .data$SeriesFactor)) +
        ggplot2::geom_line(linewidth = 0.8) +
        ggplot2::geom_point(size = 2.4) +
        ggplot2::scale_colour_manual(values = cols_i, name = NULL) +
        ggplot2::scale_shape_manual(values = stats::setNames(c(16, 17), c("Elements", s2_nm)), name = NULL) +
        .mfrmr_gg_theme_styled(style$name)
      ylab_i <- if (identical(p_kind, "residual")) "Residual metric" else "Max absolute change"
      p <- .mfrmr_gg_labs(p, payload, x = "Iteration", y = ylab_i)
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "network_analysis")) {
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    metric <- as.character(payload$metric %||% "Betweenness")[1L]
    lbls <- if (all(c("Facet", "Level") %in% names(tbl))) paste(tbl$Facet, tbl$Level, sep = ":") else as.character(tbl$Facet)
    p <- bar_helper(lbls, tbl[[metric]], ylab = metric,
                    fill = if (identical(payload$plot, "facet_summary")) style$accent_secondary else style$accent_primary)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "facet_statistics")) {
    p_kind <- as.character(payload$plot %||% "means")[1L]
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    if (identical(p_kind, "ranges")) {
      tbl$Row <- seq_len(nrow(tbl))
      tbl$MinV <- suppressWarnings(as.numeric(tbl$Min))
      tbl$MaxV <- suppressWarnings(as.numeric(tbl$Max))
      tbl$MeanV <- suppressWarnings(as.numeric(tbl$Mean))
      p <- ggplot2::ggplot(tbl, ggplot2::aes(y = .data$Row)) +
        ggplot2::geom_segment(
          data = tbl[is.finite(tbl$MinV) & is.finite(tbl$MaxV), , drop = FALSE],
          ggplot2::aes(x = .data$MinV, xend = .data$MaxV, yend = .data$Row),
          colour = style$accent_secondary, linewidth = 1.0
        ) +
        ggplot2::geom_point(
          data = tbl[is.finite(tbl$MeanV), , drop = FALSE],
          ggplot2::aes(x = .data$MeanV),
          colour = style$accent_primary, size = 2.8
        ) +
        ggplot2::scale_y_continuous(breaks = tbl$Row, labels = as.character(tbl$Facet)) +
        .mfrmr_gg_theme_styled(style$name)
      p <- .mfrmr_gg_labs(p, payload, x = as.character(payload$metric %||% "Value")[1L], y = NULL)
    } else if (identical(p_kind, "sds")) {
      p <- bar_helper(tbl$Facet, tbl$SD, ylab = "SD", fill = style$accent_tertiary)
    } else {
      p <- bar_helper(tbl$Facet, tbl$Mean, ylab = "Mean", fill = style$accent_primary)
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "facets_contract_review")) {
    p_kind <- as.character(payload$plot %||% "column_coverage")[1L]
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    p <- switch(
      p_kind,
      column_coverage = {
        vals <- suppressWarnings(as.numeric(tbl$coverage))
        vals[!is.finite(vals)] <- 0
        fills <- ifelse(!tbl$available, style$neutral, ifelse(tbl$full_match, style$success, style$fail))
        bar_helper(payload$labels %||% paste0(tbl$table_id, ":", tbl$component), vals, ylab = "Coverage", fill = fills, h_ref = 1)
      },
      table_coverage = {
        vals <- suppressWarnings(as.numeric(tbl$MeanCoverage))
        vals[!is.finite(vals)] <- 0
        bar_helper(tbl$table_id, vals, ylab = "Mean coverage", h_ref = 1)
      },
      metric_status = {
        fills <- c(style$success, style$fail, style$neutral)[seq_len(nrow(tbl))]
        bar_helper(tbl$Status, tbl$Checks, ylab = "Checks", fill = fills)
      },
      {
        vals <- suppressWarnings(as.numeric(tbl$PassRate))
        vals[!is.finite(vals)] <- 0
        bar_helper(tbl$Table, vals, ylab = "Pass rate", fill = style$accent_tertiary, h_ref = 1)
      }
    )
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "bias_count")) {
    p_kind <- as.character(payload$plot %||% "cell_counts")[1L]
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    lbls <- as.character(payload$labels %||% seq_len(nrow(tbl)))
    if (identical(p_kind, "lowcount_by_facet")) {
      p <- bar_helper(lbls, tbl$LowCountRate, ylab = "Low-count rate", fill = style$accent_tertiary, h_ref = 0)
    } else {
      fills <- ifelse(tbl$LowCountFlag %in% TRUE, style$fail, style$accent_primary)
      p <- bar_helper(lbls, tbl$Count, ylab = "Observed count", fill = fills)
    }
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "fixed_reports")) {
    if (!is.null(payload$message)) {
      p <- .mfrmr_empty_ggplot("No data", payload = payload, preset = style$name)
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    p_kind <- as.character(payload$plot %||% "contrast")[1L]
    if (identical(p_kind, "pvalue")) {
      p_vals <- suppressWarnings(as.numeric(payload$p_values))
      p_vals <- p_vals[is.finite(p_vals)]
      if (!length(p_vals)) {
        p <- .mfrmr_empty_ggplot("No data", payload = payload, preset = style$name)
      } else {
        n_bins <- min(20L, max(5L, as.integer(sqrt(length(p_vals)))))
        p <- ggplot2::ggplot(data.frame(P = p_vals), ggplot2::aes(x = .data$P)) +
          ggplot2::geom_histogram(bins = n_bins, fill = style$accent_tertiary, colour = "#FFFFFF", alpha = 0.88) +
          ggplot2::geom_vline(xintercept = 0.05, linetype = "dashed", colour = style$ref_line) +
          .mfrmr_gg_theme_styled(style$name)
        p <- .mfrmr_gg_labs(p, payload, x = "p-value", y = "Count")
      }
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    lbls <- as.character(payload$labels %||% seq_len(nrow(tbl)))
    fills <- ifelse(suppressWarnings(as.numeric(tbl$Contrast)) >= 0, style$success, style$warn)
    p <- bar_helper(lbls, tbl$Contrast, ylab = "Contrast (logit)", fill = fills, h_ref = 0, empty_msg = "No data")
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  if (identical(nm, "visual_summaries")) {
    p_kind <- as.character(payload$plot %||% "comparison")[1L]
    if (identical(p_kind, "comparison") && is.matrix(payload$matrix)) {
      mat <- payload$matrix
      vis <- as.character(payload$visuals %||% colnames(mat))
      long <- rbind(
        data.frame(Visual = vis, Type = "Warning", Messages = suppressWarnings(as.numeric(mat[1L, ])), stringsAsFactors = FALSE),
        data.frame(Visual = vis, Type = "Summary", Messages = suppressWarnings(as.numeric(mat[2L, ])), stringsAsFactors = FALSE)
      )
      long$VisualFactor <- factor(long$Visual, levels = unique(vis))
      long$TypeFactor <- factor(long$Type, levels = c("Warning", "Summary"))
      p <- ggplot2::ggplot(long[is.finite(long$Messages), , drop = FALSE], ggplot2::aes(x = .data$VisualFactor, y = .data$Messages, fill = .data$TypeFactor)) +
        ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.75), width = 0.68) +
        ggplot2::scale_fill_manual(values = c(Warning = style$fail, Summary = style$accent_primary), name = NULL) +
        .mfrmr_gg_theme_styled(style$name) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
      p <- .mfrmr_gg_labs(p, payload, x = NULL, y = "Messages")
      attr(p, "mfrmr_plot_data") <- x
      return(p)
    }
    tbl <- as.data.frame(payload$table %||% data.frame(), stringsAsFactors = FALSE)
    p <- bar_helper(tbl$Visual, tbl$Messages, ylab = "Messages", fill = style$accent_tertiary)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  NULL
}
