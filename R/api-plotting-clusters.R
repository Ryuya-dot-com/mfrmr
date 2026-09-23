#' Plot exploratory groups and imputation sensitivity
#'
#' Inspect within-sample separation, individual feature profiles, or pairwise
#' co-membership across imputations using existing clustering results.
#'
#' @param x An object returned by [mfrm_cluster()], [mfrm_cluster_kmeans()] or
#'   [mfrm_cluster_imputed()], as appropriate.
#' @param type For a single partition, `"silhouette"` or `"profile"`.
#' @param feature A single selected feature name, required for `type = "profile"`.
#'   Numeric features show means and medians in their original units;
#'   categorical features show within-group proportions in the original level
#'   order (including unused factor levels).
#' @param ids For imputation heatmaps, an optional character vector of distinct
#'   entity IDs in the desired display order. Selection affects only the view,
#'   not clustering or the denominator. By default all IDs appear in input order.
#' @param labels Whether to display entity IDs on silhouettes or heatmaps.
#'   The default displays them for at most 50 entities. No entities are sampled
#'   when labels are hidden. Profile plots always label groups and levels.
#' @param draw Draw the plot when `TRUE`; `FALSE` only returns plotted values.
#' @param preset Plot style: `"standard"`, `"publication"`, `"compact"`, or
#'   `"monochrome"`.
#' @param ... Reserved for future use; additional arguments are rejected.
#' @return Invisibly, an `mfrm_plot_data` object. Its `data` contains the plotted
#'   table or matrix, title, subtitle, legend, and excluded IDs. Heatmaps also
#'   retain the displayed IDs and the number of imputations. Use [plot_data()]
#'   to extract this payload for custom graphics.
#'   Automatic [as_ggplot()] conversion is not supported for these views.
#' @details
#' No model or clustering is refitted. Silhouette widths describe separation
#' in the fitted sample, not stability or probabilities. The dashed line is
#' the overall mean silhouette; excluded entities have no silhouette.
#'
#' Feature profiles describe one partition; numeric summaries have no confidence
#' intervals. For an imputed result, inspect a completion with
#' `plot(x$analyses[[1]], type = "profile", feature = "ExperienceYears")`.
#' Cluster numbers must not be averaged across imputations.
#'
#' Imputation heatmaps show the fraction of all supplied imputations in which
#' each pair belongs to the same group, on a fixed zero-to-one scale. Grey cells
#' are unavailable pairs involving excluded entities, not zero co-membership.
#' These fractions describe sensitivity to imputations under fixed settings,
#' not membership probabilities, sampling stability, or a consensus partition.
#' Rows and columns follow input order or explicit `ids`; no hierarchical
#' clustering is performed. PAM is nonhierarchical and these plots do not
#' provide a dendrogram. Use [mfrm_cluster_hierarchical()] for a separate
#' hierarchical analysis and its dendrogram.
#' @seealso [mfrm_cluster()], [mfrm_cluster_imputed()], [mfrm_cluster_compare()]
#' @examples
#' if (requireNamespace("cluster", quietly = TRUE)) {
#'   raters <- data.frame(Rater = paste0("R", 1:6),
#'     ExperienceYears = c(1, 2, 3, 12, 13, 14),
#'     Specialty = factor(rep(c("Language", "Science"), each = 3)))
#'   groups <- mfrm_cluster(mfrm_features(raters, "Rater",
#'     c("ExperienceYears", "Specialty")), k = 2)
#'   plot(groups)
#'   plot(groups, type = "profile", feature = "ExperienceYears")
#'   plot(groups, type = "profile", feature = "Specialty")
#'   values <- plot_data(plot(groups, draw = FALSE))
#'   values$table
#' }
#' @name plot.mfrm_clusters
NULL

#' @rdname plot.mfrm_clusters
#' @export
plot.mfrm_clusters <- function(x, type = c("silhouette", "profile"),
                               feature = NULL, labels = NULL, draw = TRUE,
                               preset = "standard", ...) {
  rlang::check_dots_empty()
  type <- match.arg(type)
  check_cluster_plot_flags(draw, labels)
  style <- resolve_plot_preset(preset)
  excluded <- x$membership$ID[is.na(x$membership$Cluster)]
  method <- if (is.null(x$settings$linkage)) x$settings$method else
    paste(x$settings$linkage, "linkage")
  subtitle <- sprintf("%s / %s | Included: %d | Excluded: %d",
    method, x$settings$distance, x$settings$included, length(excluded))
  if (!is.null(x$settings$space)) {
    subtitle <- paste0(subtitle, " | ", x$settings$space,
      if (!is.null(x$settings$components)) paste0(": ", x$settings$components) else "",
      if (isTRUE(x$settings$scale)) " | Sample-SD scaling" else " | Original-unit scaling")
  }
  if (type == "silhouette") {
    if (!is.null(feature)) stop("`feature` is only used for type = 'profile'.", call. = FALSE)
    tab <- x$membership[!is.na(x$membership$Cluster), , drop = FALSE]
    if (!nrow(tab) || any(!is.finite(tab$Silhouette))) {
      stop("Silhouettes are unavailable; fit with silhouette = TRUE or use a profile plot.", call. = FALSE)
    }
    tab <- tab[order(tab$Cluster, -tab$Silhouette, tab$ID), , drop = FALSE]
    show_labels <- labels %||% (nrow(tab) <= 50L)
    average <- mean(tab$Silhouette)
    out <- new_mfrm_plot_data("cluster_silhouette", list(table = tab,
      cluster_summary = x$cluster_summary, excluded_ids = excluded,
      labels = show_labels, title = "Silhouette widths", subtitle = subtitle,
      reference_lines = new_reference_lines("x", average, "Overall mean", "dashed", "mean"),
      preset = style$name))
    if (!draw) return(invisible(out))
    apply_plot_preset(style)
    old <- graphics::par(mar = c(6, 7, 5, if (show_labels) 6 else 2))
    on.exit(graphics::par(old), add = TRUE)
    pos <- seq_len(nrow(tab))
    graphics::plot(NA, xlim = c(-1, 1), ylim = c(nrow(tab) + 0.5, 0.5),
      xlab = "Silhouette width", ylab = "", yaxt = "n", main = out$data$title)
    graphics::abline(v = 0, col = style$grid)
    graphics::rect(0, pos - 0.4, tab$Silhouette, pos + 0.4, border = NA,
      col = ifelse(tab$Cluster %% 2L == 1L, style$accent_primary, style$accent_secondary))
    graphics::abline(v = average, lty = 2, col = style$foreground)
    centers <- tapply(pos, tab$Cluster, mean)
    graphics::axis(2, at = centers, labels = paste("Group", names(centers)), las = 1)
    if (show_labels) graphics::axis(4, at = pos, labels = tab$ID, las = 1, tick = FALSE)
    graphics::mtext(subtitle, side = 3, line = 0.3, cex = 0.8)
    graphics::mtext(sprintf("Dashed: overall mean %.3f | In-sample separation", average),
      side = 1, line = 4.5, cex = 0.8)
    return(invisible(out))
  }
  if (!is.character(feature) || length(feature) != 1L || is.na(feature) ||
      !feature %in% x$feature_data$features) {
    stop("`feature` must name one selected feature for type = 'profile'.", call. = FALSE)
  }
  numeric <- is.numeric(x$feature_data$data[[feature]])
  tab <- x$profiles[[if (numeric) "numeric" else "categorical"]]
  tab <- tab[tab$Feature == feature, , drop = FALSE]
  title <- paste("Feature profile:", feature)
  groups <- x$cluster_summary$Cluster
  group_labels <- sprintf("Group %d (n = %d)", groups, x$cluster_summary$N)
  payload <- list(table = tab, excluded_ids = excluded, feature = feature,
    title = title, subtitle = subtitle, preset = style$name)
  if (numeric) {
    payload$legend <- new_plot_legend(c("Mean", "Median"), rep("summary", 2),
      rep("pch", 2), c("16", "17"))
  } else {
    levels <- unique(tab$Level)
    mat <- matrix(0, length(groups), length(levels), dimnames = list(group_labels, levels))
    mat[cbind(match(tab$Cluster, groups), match(tab$Level, levels))] <- tab$Proportion
    payload$matrix <- mat
    payload$legend <- cluster_proportion_legend(style)
  }
  out <- new_mfrm_plot_data("cluster_profile", payload)
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  if (!numeric) {
    draw_cluster_proportions(mat, title, subtitle, style, TRUE, "Within-group proportion")
  } else {
    old <- graphics::par(mar = c(6, 9, 5, 2))
    on.exit(graphics::par(old), add = TRUE)
    pos <- seq_len(nrow(tab))
    graphics::plot(tab$Mean, pos, xlim = range(c(tab$Mean, tab$Median)),
      ylim = c(nrow(tab) + 0.5, 0.5), pch = 16, col = style$accent_primary,
      xlab = paste(feature, "(original units)"), ylab = "", yaxt = "n", main = title)
    graphics::points(tab$Median, pos, pch = 17, col = style$accent_secondary)
    graphics::axis(2, at = pos, labels = group_labels, las = 1)
    graphics::mtext(subtitle, side = 3, line = 0.3, cex = 0.8)
    graphics::mtext("Mean: circles | Median: triangles", side = 1, line = 4.5, cex = 0.8)
  }
  invisible(out)
}

#' @rdname plot.mfrm_clusters
#' @export
plot.mfrm_imputed_clusters <- function(x, ids = NULL, labels = NULL, draw = TRUE,
                                       preset = "standard", ...) {
  rlang::check_dots_empty()
  check_cluster_plot_flags(draw, labels)
  style <- resolve_plot_preset(preset)
  all_ids <- rownames(x$co_membership)
  if (is.null(ids)) ids <- all_ids
  if (!is.character(ids) || !length(ids) || anyNA(ids) || anyDuplicated(ids) ||
      !all(ids %in% all_ids)) {
    stop("`ids` must be distinct entity IDs present in the result.", call. = FALSE)
  }
  mat <- x$co_membership[ids, ids, drop = FALSE]
  excluded <- all_ids[is.na(diag(x$co_membership))]
  show_labels <- labels %||% (length(ids) <= 50L)
  method <- x$settings$method %||% "PAM"
  linkage <- x$settings$linkage
  title <- paste("Co-membership:", if (is.null(linkage)) method else paste(linkage, "linkage"))
  subtitle <- sprintf("Imputations: %d | Displayed: %d of %d | Excluded in view: %d",
    x$settings$imputations, length(ids), length(all_ids), sum(ids %in% excluded))
  out <- new_mfrm_plot_data("cluster_co_membership", list(matrix = mat,
    ids = ids, excluded_ids = excluded, imputations = x$settings$imputations,
    labels = show_labels, method = method, linkage = linkage, title = title, subtitle = subtitle,
    legend = cluster_proportion_legend(style), preset = style$name))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  draw_cluster_proportions(mat, title, subtitle, style, show_labels,
    "Fraction of imputations | Grey: unavailable")
  invisible(out)
}

check_cluster_plot_flags <- function(draw, labels) {
  if (!is.logical(draw) || length(draw) != 1L || is.na(draw) ||
      (!is.null(labels) && (!is.logical(labels) || length(labels) != 1L || is.na(labels)))) {
    stop("`draw` and non-NULL `labels` must each be TRUE or FALSE.", call. = FALSE)
  }
}

cluster_proportion_legend <- function(style) {
  new_plot_legend(c(as.character(seq(0, 1, 0.25)), "Unavailable"),
    c(rep("proportion", 5), "missing"), rep("fill", 6),
    c(grDevices::colorRampPalette(c("white", style$accent_primary))(5), "grey70"))
}

draw_cluster_proportions <- function(mat, title, subtitle, style, labels, caption) {
  old <- graphics::par(mar = c(if (labels) 7 else 4, if (labels) 9 else 4, 5, 7))
  on.exit(graphics::par(old), add = TRUE)
  nr <- nrow(mat)
  nc <- ncol(mat)
  graphics::plot(NA, xlim = c(0.5, nc + 0.5), ylim = c(0.5, nr + 0.5),
    xaxs = "i", yaxs = "i", xlab = "", ylab = "", axes = FALSE, main = title)
  graphics::rect(0.5, 0.5, nc + 0.5, nr + 0.5, col = "grey70", border = NA)
  graphics::image(seq(0.5, nc + 0.5), seq(0.5, nr + 0.5),
    t(mat[nr:1, , drop = FALSE]), add = TRUE, useRaster = TRUE,
    col = grDevices::colorRampPalette(c("white", style$accent_primary))(100),
    breaks = seq(0, 1, length.out = 101))
  if (labels) {
    graphics::axis(1, at = seq_len(nc), labels = colnames(mat), las = 2, tick = FALSE)
    graphics::axis(2, at = seq_len(nr), labels = rev(rownames(mat)), las = 1, tick = FALSE)
  }
  graphics::box()
  key <- cluster_proportion_legend(style)
  graphics::legend(nc + 0.5 + 0.03 * nc, nr + 0.5, legend = key$label,
    fill = key$value, bty = "n", xpd = NA, cex = 0.8)
  graphics::mtext(subtitle, side = 3, line = 0.3, cex = 0.8)
  graphics::mtext(caption, side = 1, line = if (labels) 5.5 else 2.5, cex = 0.8)
}
