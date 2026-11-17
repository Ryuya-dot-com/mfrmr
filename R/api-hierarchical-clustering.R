#' @details
#' **Hierarchical Gower clustering (`method = "hierarchical"`)**: Uses
#' [stats::hclust()] and [stats::cutree()] at `k` with `linkage = "average"`
#' (default, UPGMA) or `"complete"` (Ward linkage is unsupported for mixed
#' Gower dissimilarities; Murtagh & Legendre, 2014,
#' \doi{10.1007/s00357-014-9161-z}). Returns an `mfrm_hierarchical_clusters`
#' subclass retaining `tree` (`medoids` is `NULL`). Tied merge heights use
#' merge order at cut `k`. Default `plot()` draws the stored dendrogram with
#' `k`-group boxes (`component = "tree"` in [plot_data()]); `"silhouette"` and
#' `"profile"` views match `plot.mfrm_clusters()`.
#' @aliases mfrm_cluster_hierarchical
#' @usage NULL
#' @rdname mfrm_cluster
mfrm_cluster_hierarchical <- function(x, k, weights = NULL,
                                      missing = c("error", "omit"),
                                      linkage = c("average", "complete")) {
  linkage <- match.arg(linkage)
  cluster_external_features(x, k, weights, match.arg(missing), linkage)
}

#' @rdname mfrm_cluster
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @export
plot.mfrm_hierarchical_clusters <- function(x, type = c("dendrogram", "silhouette", "profile"),
                                            feature = NULL, labels = NULL, draw = TRUE,
                                            preset = "standard", ...) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  rlang::check_dots_empty()
  type <- match.arg(type)
  if (type != "dendrogram") {
    return(invisible(plot.mfrm_clusters(x, type, feature, labels, draw, preset)))
  }
  if (!is.null(feature)) stop("`feature` is only used for type = 'profile'.", call. = FALSE)
  check_cluster_plot_flags(draw, labels)
  style <- resolve_plot_preset(preset)
  tree <- x$tree
  show_labels <- labels %||% (length(tree$order) <= 50L)
  excluded <- x$membership$ID[is.na(x$membership$Cluster)]
  leaf_order <- tree$labels[tree$order]
  title <- "Hierarchical feature groups"
  subtitle <- sprintf("%s linkage / Gower | Included: %d | Excluded: %d",
    switch(x$settings$linkage, average = "Average", complete = "Complete"),
    x$settings$included, length(excluded))
  out <- new_mfrm_plot_data("cluster_dendrogram", list(tree = tree,
    leaf_order = leaf_order, table = x$membership[match(leaf_order, x$membership$ID), , drop = FALSE],
    k = x$settings$k, excluded_ids = excluded, labels = show_labels,
    title = title, subtitle = subtitle, preset = style$name,
    caption = sprintf("Boxes: %d groups | Heights do not measure branch support", x$settings$k)))
  .mfrm_finalize_ggplot(out, draw = draw)
}

# Lay out the saved binary merges; no distances or groups are re-estimated.
.mfrmr_gg_dendrogram <- function(x) {
  .require_mfrmr_ggplot2()
  d <- x$data
  tree <- d$tree
  n <- length(tree$order)
  if (!inherits(tree, "hclust") || n < 2L ||
      !identical(sort(tree$order), seq_len(n)) ||
      !is.matrix(tree$merge) || !identical(dim(tree$merge), c(n - 1L, 2L)) ||
      length(tree$height) != n - 1L || any(!is.finite(tree$height)) ||
      any(tree$height < 0) || length(tree$labels) != n ||
      !identical(d$leaf_order, tree$labels[tree$order]) ||
      !is.data.frame(d$table) || !all(c("ID", "Cluster") %in% names(d$table)) ||
      !identical(d$table$ID, d$leaf_order) || anyNA(d$table$Cluster)) {
    stop("Dendrogram data lack a matching saved tree, leaf order or membership table. Recreate them with plot(hierarchy, draw = FALSE).", call. = FALSE)
  }
  runs <- rle(d$table$Cluster)
  if (length(d$k) != 1L || !is.numeric(d$k) || is.na(d$k) ||
      d$k < 2L || d$k >= n || length(runs$lengths) != d$k ||
      anyDuplicated(runs$values)) {
    stop("Dendrogram groups must match the saved contiguous leaf groups and group count.", call. = FALSE)
  }
  leaf_x <- match(seq_len(n), tree$order)
  node_x <- numeric(n - 1L)
  segments <- matrix(NA_real_, 3L * (n - 1L), 4L,
    dimnames = list(NULL, c("X", "Y", "Xend", "Yend")))
  for (i in seq_len(n - 1L)) {
    children <- tree$merge[i, ]
    if (anyNA(children) || any(children != as.integer(children)) ||
        any(children == 0L | children < -n | children >= i)) {
      stop("The saved dendrogram contains invalid merge indices.", call. = FALSE)
    }
    xx <- yy <- numeric(2)
    for (j in 1:2) {
      child <- children[j]
      xx[j] <- if (child < 0) leaf_x[-child] else node_x[child]
      yy[j] <- if (child < 0) 0 else tree$height[child]
    }
    node_x[i] <- mean(xx)
    segments[3L * (i - 1L) + 1:3, ] <- rbind(
      c(xx[1], yy[1], xx[1], tree$height[i]),
      c(xx[2], yy[2], xx[2], tree$height[i]),
      c(xx[1], tree$height[i], xx[2], tree$height[i]))
  }
  ends <- cumsum(runs$lengths)
  bottom <- -0.04 * if (max(tree$height) > 0) max(tree$height) else 1
  boxes <- data.frame(Left = c(0, utils::head(ends, -1)) + 0.65,
    Right = ends + 0.35, Bottom = bottom,
    Top = mean(tree$height[n - d$k + 0:1]))
  style <- resolve_plot_preset(d$preset %||% "standard")
  p <- ggplot2::ggplot(as.data.frame(segments)) +
    ggplot2::geom_segment(ggplot2::aes(x = .data$X, y = .data$Y,
      xend = .data$Xend, yend = .data$Yend), colour = style$foreground, linewidth = 0.45) +
    ggplot2::geom_rect(data = boxes, ggplot2::aes(xmin = .data$Left,
      xmax = .data$Right, ymin = .data$Bottom, ymax = .data$Top),
      fill = NA, colour = style$accent_primary, linewidth = 0.55, linetype = "dashed") +
    ggplot2::scale_x_continuous(breaks = if (isTRUE(d$labels)) seq_len(n) else NULL,
      labels = if (isTRUE(d$labels)) d$leaf_order else NULL) +
    ggplot2::scale_y_continuous(breaks = function(limits) {
      ticks <- pretty(c(0, max(tree$height)))
      ticks[ticks >= 0 & ticks <= limits[2]]
    }) +
    .mfrmr_gg_theme() +
    ggplot2::theme(panel.grid = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, vjust = 0.5))
  caption <- sprintf("Dashed boxes: %d groups | Heights do not measure branch support", d$k)
  if (tree$height[n - d$k] == tree$height[n - d$k + 1L]) caption <- paste0(caption,
    "\nTied heights: boxes follow saved merge-order groups, not a unique height cut.")
  d$caption <- caption
  p <- .mfrmr_gg_labs(p, d, x = NULL, y = "Gower dissimilarity") +
    ggplot2::labs(
      alt = "Hierarchy of external features, using saved merge heights and leaf order. Dashed boxes mark the requested groups, including merge-order cuts at tied heights. Excluded entities have no leaves; heights do not measure significance or branch support.")
  attr(p, "mfrmr_plot_data") <- x
  p
}
