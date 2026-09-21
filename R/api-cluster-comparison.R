#' Compare exploratory groups across group counts and feature weights
#'
#' Compare existing external-feature clustering results without refitting.
#' Review how group membership changes when the number of groups or feature
#' weights changes, including paired comparisons across the same imputations.
#'
#' @param analyses A named list of at least two results from [mfrm_cluster()],
#'   or a named list of results from [mfrm_cluster_imputed()]. Do not mix the two
#'   result types. Names must be unique and nonblank. All results must use the
#'   same original feature values, types, IDs, and included entities. Row and
#'   feature order may differ. For imputed results, the completed feature tables
#'   must also match by imputation number; reuse the same `mids` object when
#'   fitting each setting. Different imputation models are not compared here.
#' @return An `mfrm_cluster_comparison` object containing:
#'   \itemize{
#'   \item `analysis_summary`: group count, included/excluded entity counts,
#'     smallest/largest group sizes, and mean silhouette for each analysis and
#'     imputation. `Imputation` is `NA` for ordinary clustering results.
#'   \item `weights`: supplied feature weights for each analysis.
#'   \item `comparisons`: all pairs of analyses, with one row per imputation.
#'     `Pairs` counts unordered pairs of included entities, excluding self-pairs.
#'     `SplitPairs` were together in `First` and apart in `Second`; `JoinedPairs`
#'     were apart in `First` and together in `Second`. `ChangedFraction` is
#'     their sum divided by `Pairs`. `AdjustedRand` is the adjusted Rand index.
#'   \item `comparison_summary`: number of compared partitions, mean/minimum/
#'     maximum changed fraction, and mean adjusted Rand index for each analysis
#'     pair. `summary()` returns this table.
#'   \item `analyses`: the original results, including omitted IDs and all
#'     imputation-specific partitions, profiles, and settings.
#'   }
#' @details Comparisons align entities by ID and do not compare numeric group
#'   labels directly. Zero changed fraction and an adjusted Rand index of one
#'   indicate identical partitions, allowing arbitrary renumbering of groups.
#'   The changed fraction can be small when many pairs are separated in both
#'   partitions. The adjusted Rand index corrects agreement against random
#'   partitions with fixed group sizes; it can be negative. Neither measure
#'   identifies the correct group count or establishes group validity.
#'
#'   Mean silhouette and group sizes help describe each partition. Silhouette
#'   values calculated with different feature weights use different distances;
#'   their maximum is not an automatic criterion for choosing weights. Review
#'   group profiles in the retained `analyses` alongside the comparison.
#'
#'   With multiple imputations, each comparison uses the same completed data
#'   on both sides. Every imputation is retained. Summary means and ranges
#'   describe sensitivity to settings across those imputations; they are not
#'   Rubin-pooled estimates, confidence intervals, or sampling stability.
#'   Different input data or inclusion masks cause an error rather than a
#'   silent intersection of entities or imputations. No preferred setting,
#'   consensus partition, or hypothesis test is returned.
#' @references Hubert, L. and Arabie, P. (1985). Comparing partitions.
#'   Journal of Classification, 2, 193--218. \doi{10.1007/BF01908075}.
#' @seealso [mfrm_features()], [mfrm_cluster()], [mfrm_cluster_imputed()]
#' @examples
#' if (requireNamespace("cluster", quietly = TRUE)) {
#'   raters <- data.frame(Rater = paste0("R", 1:8),
#'     Experience = c(1, 2, 3, 4, 11, 12, 13, 14),
#'     Specialty = rep(c("Language", "Science"), 4))
#'   features <- mfrm_features(raters, "Rater", c("Experience", "Specialty"))
#'   fits <- list(
#'     TwoGroups = mfrm_cluster(features, k = 2),
#'     ThreeGroups = mfrm_cluster(features, k = 3),
#'     ExperienceWeighted = mfrm_cluster(features, k = 2,
#'       weights = c(Experience = 3, Specialty = 1)))
#'   comparison <- mfrm_cluster_compare(fits)
#'   summary(comparison)
#'   comparison$analysis_summary
#'   comparison$comparisons
#' }
#' @export
mfrm_cluster_compare <- function(analyses) {
  if (!is.list(analyses) || length(analyses) < 2L || is.null(names(analyses)) ||
      anyNA(names(analyses)) || any(!nzchar(trimws(names(analyses)))) ||
      anyDuplicated(names(analyses))) {
    stop("`analyses` must be a list of at least two results with unique, nonblank names.", call. = FALSE)
  }
  imputed <- all(vapply(analyses, inherits, logical(1), "mfrm_imputed_clusters"))
  if (!imputed && !all(vapply(analyses, inherits, logical(1), "mfrm_clusters"))) {
    stop("Supply only mfrm_cluster() results or only mfrm_cluster_imputed() results.", call. = FALSE)
  }
  partitions <- if (imputed) lapply(analyses, `[[`, "analyses") else lapply(analyses, list)
  m <- length(partitions[[1L]])
  if (m < 1L || any(lengths(partitions) != m) ||
      (imputed && any(vapply(analyses, function(a) !identical(length(a$analyses),
        a$settings$imputations), logical(1))))) {
    stop("All results must retain the same number of imputations.", call. = FALSE)
  }
  original <- analyses[[1L]]$feature_data
  ids <- original$row_summary$ID
  features <- original$features
  # Reuse feature validation, aligning both original and completed tables by ID.
  feature_table <- function(x) {
    x <- mfrm_features(x$data, x$id, x$features, x$missing)
    if (!setequal(x$row_summary$ID, ids) || !setequal(x$features, features)) {
      stop("All results must use the same entity IDs and selected features.", call. = FALSE)
    }
    data <- x$data[match(ids, x$row_summary$ID), features, drop = FALSE]
    rownames(data) <- NULL
    data
  }
  original_data <- feature_table(original)
  completed_data <- lapply(partitions[[1L]], function(a) feature_table(a$feature_data))
  included <- !is.na(partitions[[1L]][[1L]]$membership$Cluster[
    match(ids, partitions[[1L]][[1L]]$membership$ID)])
  memberships <- summaries <- weight_tables <- vector("list", length(analyses))
  for (i in seq_along(analyses)) {
    if (!isTRUE(all.equal(feature_table(analyses[[i]]$feature_data), original_data,
                          tolerance = 0))) {
      stop("All results must use the same original feature values and types.", call. = FALSE)
    }
    memberships[[i]] <- vector("list", m)
    summaries[[i]] <- vector("list", m)
    for (j in seq_len(m)) {
      a <- partitions[[i]][[j]]
      if (!inherits(a, "mfrm_clusters")) {
        stop("Every retained partition must be an mfrm_cluster() result.", call. = FALSE)
      }
      if (!isTRUE(all.equal(feature_table(a$feature_data), completed_data[[j]], tolerance = 0))) {
        stop("Completed feature values and types must match at imputation ", j, ".", call. = FALSE)
      }
      member <- a$membership
      if (anyDuplicated(member$ID) || !setequal(member$ID, ids)) {
        stop("Membership IDs must match the original feature table.", call. = FALSE)
      }
      labels <- member$Cluster[match(ids, member$ID)]
      if (!identical(!is.na(labels), included)) {
        stop("All partitions must include the same entities; omitted IDs cannot be silently dropped.", call. = FALSE)
      }
      labels <- labels[included]
      if (!is.numeric(labels) || any(!is.finite(labels)) ||
          length(unique(labels)) != a$settings$k || a$settings$k < 2L ||
          a$settings$k >= length(labels)) {
        stop("Each partition must retain valid group memberships and its group count.", call. = FALSE)
      }
      memberships[[i]][[j]] <- labels
      sizes <- table(labels)
      summaries[[i]][[j]] <- data.frame(Analysis = names(analyses)[i],
        Imputation = if (imputed) j else NA_integer_, K = a$settings$k,
        Included = sum(included), Excluded = sum(!included),
        MinGroupSize = min(sizes), MaxGroupSize = max(sizes),
        MeanSilhouette = mean(member$Silhouette, na.rm = TRUE))
    }
    weights <- partitions[[i]][[1L]]$settings$weights
    weight_tables[[i]] <- data.frame(Analysis = names(analyses)[i],
      Feature = names(weights), Weight = unname(weights))
  }
  pairs <- utils::combn(seq_along(analyses), 2L)
  comparisons <- comparison_summary <- vector("list", ncol(pairs))
  for (p in seq_len(ncol(pairs))) {
    first <- pairs[1L, p]
    second <- pairs[2L, p]
    rows <- vector("list", m)
    for (j in seq_len(m)) {
      cross <- table(memberships[[first]][[j]], memberships[[second]][[j]])
      total <- choose(sum(cross), 2)
      together <- sum(choose(cross, 2))
      together_first <- sum(choose(rowSums(cross), 2))
      together_second <- sum(choose(colSums(cross), 2))
      expected <- together_first * together_second / total
      rows[[j]] <- data.frame(First = names(analyses)[first], Second = names(analyses)[second],
        Imputation = if (imputed) j else NA_integer_, Included = sum(included), Pairs = total,
        SplitPairs = together_first - together, JoinedPairs = together_second - together,
        ChangedFraction = (together_first + together_second - 2 * together) / total,
        AdjustedRand = (together - expected) / ((together_first + together_second) / 2 - expected))
    }
    comparisons[[p]] <- do.call(rbind, rows)
    values <- comparisons[[p]]
    comparison_summary[[p]] <- data.frame(First = names(analyses)[first], Second = names(analyses)[second],
      Partitions = m, Included = sum(included), Pairs = values$Pairs[1L],
      MeanChangedFraction = mean(values$ChangedFraction),
      MinChangedFraction = min(values$ChangedFraction), MaxChangedFraction = max(values$ChangedFraction),
      MeanAdjustedRand = mean(values$AdjustedRand))
  }
  out <- list(analysis_summary = do.call(rbind, lapply(summaries, function(x) do.call(rbind, x))),
    weights = do.call(rbind, weight_tables), comparisons = do.call(rbind, comparisons),
    comparison_summary = do.call(rbind, comparison_summary), analyses = analyses)
  class(out) <- "mfrm_cluster_comparison"
  out
}

#' @rdname mfrm_cluster_compare
#' @param x,object An object returned by [mfrm_cluster_compare()].
#' @param ... Reserved for method compatibility.
#' @export
print.mfrm_cluster_comparison <- function(x, ...) {
  cat("Exploratory grouping sensitivity to group count and feature weights\n")
  print(x$comparison_summary, row.names = FALSE)
  cat("ChangedFraction counts pairs whose together/apart status changes; group numbers are arbitrary.\n")
  cat("Summaries are descriptive, not pooled inference, sampling stability, or automatic setting selection.\n")
  invisible(x)
}

#' @rdname mfrm_cluster_compare
#' @export
summary.mfrm_cluster_comparison <- function(object, ...) object$comparison_summary
