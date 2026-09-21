#' Hierarchical grouping of external features
#'
#' Build an agglomerative hierarchy from weighted Gower dissimilarities, cut
#' it into a chosen number of groups, and inspect the retained dendrogram.
#'
#' @param x For clustering, a table reviewed with [mfrm_features()]. For plotting,
#'   an `mfrm_hierarchical_clusters` result.
#' @inheritParams mfrm_cluster
#' @param linkage `"average"` (default, UPGMA) or `"complete"`. Average linkage
#'   uses the mean dissimilarity over all cross-group pairs; complete linkage
#'   uses their maximum. Neither is selected automatically from the data.
#' @param type `"dendrogram"` (default), `"silhouette"`, or `"profile"`.
#' @inheritParams plot.mfrm_clusters
#' @param labels Whether to display entity IDs on dendrograms and silhouettes.
#'   The default labels at most 50 included entities. Hiding labels does not
#'   remove entities. Profile plots always label groups and levels.
#' @param ... Reserved for future use; additional arguments are rejected.
#' @return An `mfrm_hierarchical_clusters` object inheriting from `mfrm_clusters`.
#'   It retains the `hclust` object in `tree`, ID-aligned `membership` (ID,
#'   Cluster, Silhouette), `cluster_summary`, `profiles`, `feature_data`, and
#'   `settings` including the linkage. Hierarchical clustering does not select
#'   medoids; `medoids` is `NULL` and membership has no `Medoid` column.
#'   `summary()` returns the size/silhouette table. `plot()` invisibly returns
#'   `mfrm_plot_data`; dendrogram data include the tree, leaf order, memberships,
#'   group count, and excluded IDs.
#' @details
#' Uses [stats::hclust()] followed by [stats::cutree()] at the requested `k`.
#' Feature types, scaling, weights, missingness handling, silhouette definition,
#' and the 5,000-included-entity limit follow [mfrm_cluster()]. No distance
#' transformation or automatic sampling is performed. This limit is not a
#' memory or speed guarantee.
#'
#' Only average and complete linkage are supported. Ward's minimum-variance
#' criterion requires an appropriate Euclidean geometry; this mixed-feature
#' Gower interface does not define a Euclidean conversion or a Ward analysis.
#' Clustering MFRM bias estimates is a separate methodological question from
#' grouping the external attributes accepted here. Measurement uncertainty is
#' not propagated.
#'
#' The tree is fitted independently of PAM. Its merge heights describe the
#' selected linkage on Gower dissimilarities, not significance or branch support.
#' Tied distances can produce alternative hierarchies and input order can affect
#' their resolution. A cut at `k` uses merge order even when heights tie, so a
#' horizontal height threshold need not uniquely identify that cut.
#'
#' The default plot draws this stored tree, with boxes marking the stored `k`
#' groups. Labels are shown for at most 50 included entities by default; hiding
#' labels does not sample or remove entities. Excluded entities have no leaves
#' but remain in the result and plot data. Silhouette and feature-profile views
#' reuse [plot.mfrm_clusters()]. Plots do not refit or choose groups.
#' Automatic [as_ggplot()] conversion is not supported; use `plot()` for the
#' stored hierarchy or [plot_data()] to extract it for custom graphics.
#'
#' Use [mfrm_cluster_compare()] to compare this partition with PAM or another
#' linkage on the same data. For multiple imputations, use
#' `mfrm_cluster_imputed(..., method = "hierarchical", linkage = "average")`.
#' Each completion retains its own tree; no pooled tree or branch support is
#' estimated. See `vignette("mfrmr-external-features", package = "mfrmr")`.
#' @references Murtagh, F. and Legendre, P. (2014). Ward's Hierarchical
#'   Agglomerative Clustering Method: Which Algorithms Implement Ward's
#'   Criterion? Journal of Classification, 31, 274--295.
#'   \doi{10.1007/s00357-014-9161-z}.
#' @seealso [mfrm_cluster()], [mfrm_cluster_imputed()], [mfrm_cluster_compare()]
#' @examples
#' if (requireNamespace("cluster", quietly = TRUE)) {
#'   # Fictional rater backgrounds; R7 has unrecorded experience.
#'   raters <- data.frame(Rater = paste0("R", 1:7),
#'     ExperienceYears = c(1, 2, 3, 12, 13, 14, NA),
#'     Specialty = factor(c(rep("Language", 3), rep("Science", 4))))
#'   features <- mfrm_features(raters, "Rater", c("ExperienceYears", "Specialty"))
#'   hierarchy <- mfrm_cluster_hierarchical(features, k = 2, missing = "omit")
#'   plot(hierarchy)
#'   plot(hierarchy, type = "silhouette")
#'   plot(hierarchy, type = "profile", feature = "ExperienceYears")
#'   comparison <- mfrm_cluster_compare(list(
#'     PAM = mfrm_cluster(features, k = 2, missing = "omit"),
#'     Average = hierarchy,
#'     Complete = mfrm_cluster_hierarchical(features, k = 2,
#'       linkage = "complete", missing = "omit")))
#'   comparison$analysis_summary
#'   summary(comparison)
#' }
#' @export
mfrm_cluster_hierarchical <- function(x, k, weights = NULL,
                                      missing = c("error", "omit"),
                                      linkage = c("average", "complete")) {
  linkage <- match.arg(linkage)
  cluster_external_features(x, k, weights, match.arg(missing), linkage)
}

#' @rdname mfrm_cluster_hierarchical
#' @export
plot.mfrm_hierarchical_clusters <- function(x, type = c("dendrogram", "silhouette", "profile"),
                                            feature = NULL, labels = NULL, draw = TRUE,
                                            preset = "standard", ...) {
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
    title = title, subtitle = subtitle, preset = style$name))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  old <- graphics::par(mar = c(5, 5, 5, 2), xpd = FALSE)
  on.exit(graphics::par(old), add = TRUE)
  graphics::plot(tree, labels = if (show_labels) tree$labels else FALSE,
    hang = -1, main = title, sub = "", xlab = "", ylab = "Gower dissimilarity", axes = FALSE,
    cex = style$axis_cex)
  graphics::axis(2, at = pretty(c(0, tree$height)))
  # Keep outer boxes inside hclust's fixed plotting window, also for small trees.
  ends <- cumsum(rle(out$data$table$Cluster)$lengths)
  usr <- graphics::par("usr")
  padding <- 0.01 * diff(usr[1:2])
  cut_height <- mean(tree$height[length(tree$order) - x$settings$k + 0:1])
  graphics::rect(pmax(c(0, utils::head(ends, -1)) + 0.66, usr[1] + padding),
    usr[3] + 0.005 * diff(usr[3:4]), pmin(ends + 0.33, usr[2] - padding),
    cut_height, border = style$accent_primary)
  graphics::mtext(subtitle, side = 3, line = 0.3, cex = 0.8)
  graphics::mtext(sprintf("Boxes: %d groups | Heights do not measure branch support", x$settings$k),
    side = 1, line = 3.5, cex = 0.8)
  invisible(out)
}
