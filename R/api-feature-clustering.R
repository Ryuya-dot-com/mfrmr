#' Prepare external features for exploratory grouping
#'
#' Keep one row per Person, rater, or other entity, review feature availability,
#' and optionally attach user-supplied reasons for missing values.
#'
#' @param data A data frame with one row per entity. Repeated rating rows must
#'   be summarized or joined to an entity-level table before calling this function.
#' @param id Name of the unique, nonmissing identifier column. Character, factor,
#'   or finite numeric identifiers are stored as character strings without trimming.
#' @param features Explicit character vector of feature column names, excluding
#'   the identifier. Numeric, character, factor, ordered factor, and logical
#'   columns are supported. Character columns become nominal factors; logical
#'   columns represent symmetric binary features. Ordered factor levels retain
#'   their declared order. Dates, lists, and matrices must be converted explicitly.
#' @param missing_reasons Optional data frame with columns `ID`, `Feature`, and
#'   `Reason`, one row per annotated missing cell. IDs refer to `id`; features
#'   must be selected columns. Reasons for observed or unknown cells are refused.
#'   Unannotated missing cells are labelled "Not supplied". Reasons are supplied
#'   by the user, not inferred missing-data mechanisms.
#' @return An `mfrm_features` object containing `data`, `id`, `features`, a
#'   `feature_summary`, a `row_summary`, and `missing` (all missing cells and
#'   their reasons). No values are imputed or rows discarded.
#' @details Numeric `NA` and `NaN` are missing. Infinite numeric values and blank
#'   categorical labels are refused; replace missing markers with `NA` explicitly.
#'   Constant and entirely missing features remain available for review but
#'   cannot be used by [mfrm_cluster()]. IDs and unselected columns do not enter
#'   distances. These functions are intended for external attributes such as
#'   training, experience, or specialization. They do not propagate uncertainty
#'   from estimated ability, severity, or fit statistics.
#' @examples
#' raters <- data.frame(
#'   Rater = paste0("R", 1:6),
#'   Experience = c(1, 2, 3, 12, 13, 14),
#'   Specialty = c("Language", "Language", "Language", "Science", "Science", "Science")
#' )
#' features <- mfrm_features(raters, "Rater", c("Experience", "Specialty"))
#' summary(features)
#' if (requireNamespace("cluster", quietly = TRUE)) {
#'   groups <- mfrm_cluster(features, k = 2)
#'   groups$membership
#'   summary(groups)
#' }
#' @export
mfrm_features <- function(data, id, features, missing_reasons = NULL) {
  if (!is.data.frame(data) || nrow(data) == 0L || anyDuplicated(names(data)) ||
      anyNA(names(data)) || any(!nzchar(names(data)))) {
    stop("`data` must be a nonempty data frame with unique, nonmissing column names.", call. = FALSE)
  }
  if (!is.character(id) || length(id) != 1L || is.na(id) || !id %in% names(data)) {
    stop("`id` must name one column in `data`.", call. = FALSE)
  }
  if (!is.character(features) || !length(features) || anyNA(features) ||
      anyDuplicated(features) || any(!features %in% names(data)) || id %in% features) {
    stop("`features` must name distinct columns in `data`, excluding `id`.", call. = FALSE)
  }
  ids <- data[[id]]
  if (!(is.character(ids) || is.factor(ids) || (is.numeric(ids) && !is.object(ids) && !is.complex(ids))) ||
      !is.null(dim(ids)) || anyNA(ids) ||
      (is.numeric(ids) && any(!is.finite(ids)))) {
    stop("Identifiers must be nonmissing character, factor, or finite numeric values.", call. = FALSE)
  }
  ids <- as.character(ids)
  if (any(!nzchar(trimws(ids))) || anyDuplicated(ids)) {
    stop("Identifiers must be nonblank and unique: supply one row per entity.", call. = FALSE)
  }
  selected <- as.data.frame(data[, c(id, features), drop = FALSE])
  selected[[id]] <- ids
  types <- character(length(features))
  for (j in seq_along(features)) {
    name <- features[j]
    value <- selected[[name]]
    if (!is.null(dim(value)) ||
        !(is.factor(value) || (!is.object(value) &&
          ((is.numeric(value) && !is.complex(value)) || is.character(value) || is.logical(value))))) {
      stop("Feature '", name, "' has an unsupported type; convert it explicitly.", call. = FALSE)
    }
    if (is.numeric(value) && any(is.infinite(value))) {
      stop("Feature '", name, "' contains infinite values.", call. = FALSE)
    }
    if ((is.character(value) || is.factor(value)) &&
        any(!is.na(value) & !nzchar(trimws(as.character(value))))) {
      stop("Feature '", name, "' contains blank labels; use NA for missing values.", call. = FALSE)
    }
    types[j] <- if (is.ordered(value)) "Ordinal" else if (is.factor(value) ||
      is.character(value)) "Nominal" else if (is.logical(value)) "Symmetric binary" else "Numeric"
    if (is.character(value)) selected[[name]] <- factor(value)
  }
  values <- selected[, features, drop = FALSE]
  absent <- is.na(values)
  cells <- which(absent, arr.ind = TRUE)
  missing <- data.frame(ID = ids[cells[, 1L]], Feature = features[cells[, 2L]],
                        stringsAsFactors = FALSE)
  if (!is.null(missing_reasons)) {
    if (!is.data.frame(missing_reasons) || anyDuplicated(names(missing_reasons)) ||
        !all(c("ID", "Feature", "Reason") %in% names(missing_reasons))) {
      stop("`missing_reasons` must be a data frame with ID, Feature, and Reason columns.", call. = FALSE)
    }
    reasons <- missing_reasons[, c("ID", "Feature", "Reason"), drop = FALSE]
    if (is.numeric(reasons$ID) && !is.object(reasons$ID) && !is.complex(reasons$ID) &&
        all(is.finite(reasons$ID))) reasons$ID <- as.character(reasons$ID)
    if (!all(vapply(reasons, function(v) (is.character(v) || is.factor(v)) &&
      is.null(dim(v)), logical(1)))) {
      stop("Missing-reason ID, Feature, and Reason columns must be character or factor.", call. = FALSE)
    }
    reasons[] <- lapply(reasons, as.character)
    if (anyNA(reasons) || any(!nzchar(trimws(reasons$Reason))) ||
        anyDuplicated(reasons[c("ID", "Feature")])) {
      stop("Missing reasons must be nonblank, nonmissing, and unique per ID and feature.", call. = FALSE)
    }
    row <- match(reasons$ID, ids)
    column <- match(reasons$Feature, features)
    if (anyNA(row) || anyNA(column) || !all(absent[cbind(row, column)])) {
      stop("Missing reasons must refer only to missing cells in the selected features.", call. = FALSE)
    }
    missing <- dplyr::left_join(missing, reasons, by = c("ID", "Feature"))
  } else {
    missing$Reason <- rep(NA_character_, nrow(missing))
  }
  missing$Reason[is.na(missing$Reason)] <- "Not supplied"
  out <- list(
    data = selected, id = id, features = features,
    feature_summary = data.frame(
      Feature = features, Type = types, Observed = colSums(!absent),
      Missing = colSums(absent),
      Distinct = vapply(values, function(v) length(unique(v[!is.na(v)])), integer(1)),
      row.names = NULL
    ),
    row_summary = data.frame(ID = ids, MissingFeatures = rowSums(absent),
                             Complete = rowSums(absent) == 0L),
    missing = missing
  )
  class(out) <- "mfrm_features"
  out
}

#' @rdname mfrm_features
#' @param x,object An object returned by the corresponding function.
#' @param ... Reserved for method compatibility.
#' @export
print.mfrm_features <- function(x, ...) {
  cat("External feature review\n")
  cat(nrow(x$data), "entities;", length(x$features), "features;",
      sum(x$row_summary$Complete), "complete rows\n")
  print(x$feature_summary, row.names = FALSE)
  cat("Missing values are retained. Reasons are user-supplied; no imputation is performed.\n")
  invisible(x)
}

#' @rdname mfrm_features
#' @export
summary.mfrm_features <- function(object, ...) object$feature_summary

#' Explore groups defined by external features
#'
#' Partition an entity-level feature table using Gower dissimilarities and
#' partitioning around medoids (PAM) from the optional `cluster` package.
#'
#' @param x An object returned by [mfrm_features()].
#' @param k Number of groups, an integer from 2 to one less than the number of
#'   included entities, and no greater than their number of distinct profiles.
#'   The number is chosen by the user, not optimized automatically.
#' @param weights Optional named, strictly positive finite numeric vector with
#'   one weight per selected feature. Defaults to equal weights. Names, not
#'   vector order, identify features. Remove a feature to exclude it.
#' @param missing Either `"error"` (default) or `"omit"`. The latter excludes
#'   incomplete entities explicitly, retaining their IDs, reasons, and missing
#'   group membership in the result. No values are imputed.
#' @return An `mfrm_clusters` object containing `membership` (ID, Cluster,
#'   Medoid, Silhouette), `cluster_summary`, numeric and categorical `profiles`,
#'   `medoids`, the reviewed `feature_data`, and `settings`. Silhouette values
#'   describe within-sample separation, not membership probabilities or
#'   resampling stability. `summary()` returns the cluster-size/silhouette table.
#' @details Numeric differences are divided by the feature range among included
#'   entities; nominal features use match/mismatch, ordered factors use their
#'   declared order, and logical features use symmetric binary differences.
#'   Numeric 0/1 features are treated as numeric, not asymmetric presence/absence.
#'   Every selected feature must vary among included entities. Gower scaling,
#'   feature types, weights, omission policy, and numeric ranges are retained.
#'
#'   PAM uses deterministic BUILD/SWAP initialization; tied distances may admit
#'   alternative partitions. Group numbers are arbitrary labels. These are
#'   exploratory groups, not latent classes, ability estimates, or assessments
#'   of rater quality. No inference, uncertainty propagation, new-entity
#'   classification, or resampling stability is provided. Omission may change
#'   both the sample and numeric ranges and does not correct missing-data bias.
#'
#'   Pairwise distances require quadratic memory. This interface is limited
#'   to 5,000 included entities. It does not silently sample larger inputs.
#' @seealso [mfrm_features()], [cluster::daisy()], [cluster::pam()]
#' @examples
#' # See mfrm_features() for a complete mixed-feature example.
#' @export
mfrm_cluster <- function(x, k, weights = NULL, missing = c("error", "omit")) {
  if (!inherits(x, "mfrm_features")) {
    stop("`x` must be prepared with mfrm_features().", call. = FALSE)
  }
  x <- mfrm_features(x$data, x$id, x$features, x$missing)
  missing <- match.arg(missing)
  keep <- x$row_summary$Complete
  if (any(!keep) && missing == "error") {
    stop("Selected features contain missing values. Inspect `x$missing`; use missing = 'omit' to exclude incomplete entities explicitly.", call. = FALSE)
  }
  values <- x$data[keep, x$features, drop = FALSE]
  n <- nrow(values)
  if (!is.numeric(k) || is.complex(k) || length(k) != 1L || !is.finite(k) || k != floor(k) || k < 2 || k >= n) {
    stop("`k` must be an integer from 2 to one less than the number of included entities.", call. = FALSE)
  }
  # ponytail: quadratic distances; use a scalable mixed-data backend if larger cohorts are needed.
  if (n > 5000L) stop("Clustering is limited to 5,000 included entities because pairwise distances require quadratic memory.", call. = FALSE)
  if (any(vapply(values, function(v) length(unique(v)) < 2L, logical(1)))) {
    stop("Every selected feature must vary among included entities; remove constant features and retry.", call. = FALSE)
  }
  if (k > nrow(unique(values))) stop("`k` exceeds the number of distinct included feature profiles.", call. = FALSE)
  if (is.null(weights)) weights <- stats::setNames(rep(1, length(x$features)), x$features)
  if (!is.numeric(weights) || is.complex(weights) || !is.null(dim(weights)) || length(weights) != length(x$features) ||
      is.null(names(weights)) || anyDuplicated(names(weights)) ||
      !setequal(names(weights), x$features) || any(!is.finite(weights) | weights <= 0)) {
    stop("`weights` must be a named, positive finite numeric vector covering each selected feature once.", call. = FALSE)
  }
  weights <- weights[x$features]
  if (!requireNamespace("cluster", quietly = TRUE)) {
    stop("Install the optional 'cluster' package to use mfrm_cluster().", call. = FALSE)
  }
  rownames(values) <- as.character(seq_len(n))
  binary <- which(vapply(values, is.logical, logical(1)))
  distance <- cluster::daisy(values, metric = "gower", weights = unname(weights / max(weights)),
                             type = list(symm = binary), warnBin = FALSE)
  if (any(!is.finite(distance))) stop("The selected features do not produce finite distances; review their scales.", call. = FALSE)
  fit <- cluster::pam(distance, k = as.integer(k), diss = TRUE, variant = "original",
                      keep.diss = FALSE, keep.data = FALSE)
  silhouette <- numeric(n)
  silhouette[as.integer(rownames(fit$silinfo$widths))] <- fit$silinfo$widths[, "sil_width"]
  membership <- data.frame(ID = x$row_summary$ID, Cluster = NA_integer_,
                           Medoid = NA, Silhouette = NA_real_)
  membership$Cluster[keep] <- as.integer(fit$clustering)
  membership$Medoid[keep] <- seq_len(n) %in% fit$id.med
  membership$Silhouette[keep] <- silhouette
  sizes <- as.integer(tabulate(fit$clustering, nbins = k))
  cluster_summary <- data.frame(Cluster = seq_len(k), N = sizes,
    MeanSilhouette = as.numeric(tapply(silhouette, fit$clustering, mean)))
  numeric_profiles <- categorical_profiles <- list()
  for (g in seq_len(k)) for (name in x$features) {
    value <- values[[name]][fit$clustering == g]
    if (is.numeric(value)) {
      numeric_profiles[[length(numeric_profiles) + 1L]] <- data.frame(
        Cluster = g, Feature = name, N = length(value), Mean = mean(value),
        Median = stats::median(value), SD = stats::sd(value))
    } else {
      counts <- table(if (is.logical(value)) factor(value, levels = c(FALSE, TRUE)) else value)
      categorical_profiles[[length(categorical_profiles) + 1L]] <- data.frame(
        Cluster = g, Feature = name, Level = names(counts), N = as.integer(counts),
        Proportion = as.numeric(counts) / length(value))
    }
  }
  numeric_names <- x$features[vapply(values, is.numeric, logical(1))]
  ranges <- data.frame(Feature = numeric_names,
    Minimum = vapply(values[numeric_names], min, numeric(1)),
    Maximum = vapply(values[numeric_names], max, numeric(1)), row.names = NULL)
  out <- list(membership = membership, cluster_summary = cluster_summary,
    profiles = list(
      numeric = dplyr::bind_rows(data.frame(Cluster = integer(), Feature = character(),
        N = integer(), Mean = numeric(), Median = numeric(), SD = numeric()), numeric_profiles),
      categorical = dplyr::bind_rows(data.frame(Cluster = integer(), Feature = character(),
        Level = character(), N = integer(), Proportion = numeric()), categorical_profiles)),
    medoids = x$data[which(keep)[fit$id.med], c(x$id, x$features), drop = FALSE],
    feature_data = x,
    settings = list(k = as.integer(k), method = "PAM", distance = "Gower",
      weights = weights, numeric_ranges = ranges, missing = missing,
      included = n, excluded = sum(!keep)))
  class(out) <- "mfrm_clusters"
  out
}

#' @rdname mfrm_cluster
#' @param object An object returned by [mfrm_cluster()].
#' @param ... Reserved for method compatibility.
#' @export
print.mfrm_clusters <- function(x, ...) {
  cat("Exploratory feature groups (Gower distance, PAM)\n")
  cat(x$settings$included, "entities included;", x$settings$excluded, "excluded for missing features\n")
  print(x$cluster_summary, row.names = FALSE)
  cat("Group labels are arbitrary. Silhouette describes separation in this sample; stability is not assessed.\n")
  cat("These groups do not establish ability levels or rater quality.\n")
  invisible(x)
}

#' @rdname mfrm_cluster
#' @export
summary.mfrm_clusters <- function(object, ...) object$cluster_summary
