#' Plot numeric feature PCA and optional exploratory groups
#'
#' Review explained variation, original-feature coefficients or entity scores
#' from a saved PCA without refitting it.
#'
#' @param x A result from [mfrm_pca()].
#' @param type `"scree"` (default), `"scores"`, or `"loadings"`.
#' @param components For scores, two distinct retained component numbers.
#'   For loadings, one retained component number. Defaults to `c(1, 2)` for
#'   scores and `1` for loadings. Unavailable axes cause an error.
#' @param groups Optional [mfrm_cluster_kmeans()], [mfrm_cluster_pam()] or
#'   [mfrm_cluster_hierarchical()] result used to color a scores plot. Its IDs,
#'   included entities and shared PCA features must match. Labels only annotate
#'   the view; they do not refit PCA or imply separation on every component.
#'   Groups use both colour and point shape, including monochrome output.
#'   Shapes repeat after six groups; inspect the ID-aligned table for crowded views.
#' @inheritParams plot.mfrm_clusters
#' @return Invisibly, an `mfrm_plot_data` object with the exact plotted table,
#'   selected components, group colour/shape encoding, excluded IDs and axis meanings. Scree data retain the
#'   full variance table, including components not used for clustering.
#'   [plot_data()] extracts these values. Automatic [as_ggplot()] conversion
#'   is unavailable; the extracted table supports custom graphics.
#' @details Scores and loading signs are arbitrary. Loadings are eigenvector
#'   coefficients in the centered, weighted and optionally standardized space;
#'   they are not original-unit correlations. A two-component scores view omits
#'   other directions, so apparent overlap or separation is only a projection.
#'   No confidence region, group validity or rater-quality judgment is implied.
#' @seealso [mfrm_pca()], [mfrm_cluster_kmeans()]
#' @examples
#' attributes <- data.frame(ID = letters[1:6],
#'   ExperienceYears = c(1, 2, 4, 8, 10, 12),
#'   WorkshopHours = c(8, 16, 12, 24, 16, 32))
#' result <- mfrm_pca(mfrm_features(attributes, "ID", names(attributes)[-1]))
#' plot(result)
#' plot(result, type = "scores")
#' plot(result, type = "loadings", components = 1)
#' plot_data(plot(result, type = "scores", draw = FALSE))$table
#' @export
plot.mfrm_pca <- function(x, type = c("scree", "scores", "loadings"),
                          components = NULL, groups = NULL, labels = NULL,
                          draw = TRUE, preset = "standard", ...) {
  rlang::check_dots_empty()
  type <- match.arg(type)
  check_cluster_plot_flags(draw, labels)
  style <- resolve_plot_preset(preset)
  if (type != "scores" && !is.null(groups)) stop("`groups` is only used for scores plots.", call. = FALSE)
  excluded <- x$scores$ID[is.na(x$scores$PC1)]
  subtitle <- sprintf("Included: %d | Excluded: %d | Retained components: %d",
    x$settings$included, x$settings$excluded, x$settings$components)
  subtitle <- paste0(subtitle, if (isTRUE(x$settings$scale)) " | Sample-SD scaling" else " | Original-unit scaling")
  if (type == "scree") {
    if (!is.null(components)) stop("Scree plots show every fitted component; do not select components here.", call. = FALSE)
    tab <- x$variance
    title <- "Variation in numeric external features"
    xlab <- "Principal component"
    ylab <- "Explained variance (%)"
  } else {
    if (is.null(components)) components <- if (type == "scores") c(1L, 2L) else 1L
    if (!is.numeric(components) || is.complex(components) ||
        length(components) != (if (type == "scores") 2L else 1L) ||
        any(!is.finite(components)) || any(components != floor(components)) ||
        anyDuplicated(components) || any(components < 1 | components > x$settings$components)) {
      stop("Choose ", if (type == "scores") "two distinct" else "one",
        " retained component number(s).", call. = FALSE)
    }
    axes <- paste0("PC", components)
    if (type == "loadings") {
      tab <- data.frame(Feature = rownames(x$loadings), Loading = x$loadings[, axes])
      title <- paste("Feature coefficients:", axes)
      xlab <- "Coefficient in the transformed feature space"
      ylab <- ""
    } else {
      tab <- x$scores[!x$scores$ID %in% excluded, c("ID", axes), drop = FALSE]
      tab$Cluster <- NA_integer_
      if (!is.null(groups)) {
        if (!inherits(groups, "mfrm_clusters") ||
            !setequal(groups$membership$ID, x$scores$ID) ||
            !setequal(groups$membership$ID[!is.na(groups$membership$Cluster)], tab$ID) ||
            !all(x$feature_data$features %in% groups$feature_data$features)) {
          stop("Groups must retain the PCA IDs, included entities and selected numeric features.", call. = FALSE)
        }
        original <- x$feature_data
        compared <- groups$feature_data
        index <- match(original$row_summary$ID, compared$row_summary$ID)
        same <- isTRUE(all.equal(lapply(original$data[original$features], unname),
          lapply(compared$data[index, original$features, drop = FALSE], unname), tolerance = 0))
        if (!same) stop("Groups and PCA must use the same original feature values.", call. = FALSE)
        tab$Cluster <- groups$membership$Cluster[match(tab$ID, groups$membership$ID)]
      }
      percent <- 100 * x$variance$Proportion[components]
      title <- "Principal component scores"
      xlab <- sprintf("%s (%.1f%% of transformed variance)", axes[1], percent[1])
      ylab <- sprintf("%s (%.1f%% of transformed variance)", axes[2], percent[2])
    }
  }
  encoding <- NULL
  if (type == "scores") {
    levels <- sort(unique(tab$Cluster[!is.na(tab$Cluster)]))
    encoding <- data.frame(Cluster = levels,
      Colour = unname(.plot_series_colors(levels, style$name)),
      Shape = rep(c(16, 17, 15, 18, 1, 2), length.out = length(levels)))
  }
  show_labels <- labels %||% (nrow(tab) <= 50L)
  out <- new_mfrm_plot_data(paste0("feature_pca_", type), list(table = tab,
    components = components, encoding = encoding, transformation = x$transformation,
    weights = x$settings$weights, scale = x$settings$scale,
    excluded_ids = excluded, title = title,
    subtitle = subtitle, xlab = xlab, ylab = ylab, labels = show_labels,
    preset = style$name))
  if (!draw) return(invisible(out))
  apply_plot_preset(style)
  old <- graphics::par(mar = c(6, if (type == "loadings") 10 else 5, 5, 2))
  on.exit(graphics::par(old), add = TRUE)
  if (type == "scree") {
    graphics::plot(seq_len(nrow(tab)), 100 * tab$Proportion, type = "l",
      col = style$foreground, xlab = xlab, ylab = ylab, main = title, xaxt = "n")
    graphics::axis(1, at = seq_len(nrow(tab)))
    graphics::points(seq_len(nrow(tab)), 100 * tab$Proportion,
      pch = ifelse(tab$Retained, 16, 1),
      col = ifelse(tab$Retained, style$accent_primary, "grey65"))
    if (any(!tab$Retained)) graphics::legend("topright",
      legend = c("Retained", "Not retained"), pch = c(16, 1),
      col = c(style$accent_primary, "grey65"), bty = "n")
  } else if (type == "loadings") {
    graphics::plot(tab$Loading, seq_len(nrow(tab)), xlim = c(-1, 1), yaxt = "n",
      pch = 16, col = style$accent_primary, xlab = xlab, ylab = ylab, main = title)
    graphics::abline(v = 0, col = style$grid)
    graphics::axis(2, at = seq_len(nrow(tab)), labels = tab$Feature, las = 1)
  } else {
    color <- if (nrow(encoding)) encoding$Colour[match(tab$Cluster, encoding$Cluster)] else style$accent_primary
    shape <- if (nrow(encoding)) encoding$Shape[match(tab$Cluster, encoding$Cluster)] else 16
    graphics::plot(tab[[axes[1]]], tab[[axes[2]]], pch = shape, col = color,
      xlab = xlab, ylab = ylab, main = title, asp = 1)
    if (show_labels) graphics::text(tab[[axes[1]]], tab[[axes[2]]], labels = tab$ID, pos = 3, cex = 0.7)
    if (nrow(encoding)) graphics::legend("topright", legend = paste("Group", encoding$Cluster),
      col = encoding$Colour, pch = encoding$Shape, bty = "n")
  }
  graphics::mtext(subtitle, side = 3, line = 0.3, cex = 0.8)
  invisible(out)
}
