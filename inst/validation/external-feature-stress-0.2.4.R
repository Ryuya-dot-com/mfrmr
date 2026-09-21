# Run one condition from the package root in a fresh R process.
# Rscript --vanilla inst/validation/external-feature-stress-0.2.4.R CASE OUTPUT [BACKEND]
# BACKEND is pam (default), average, or complete. Select only new or affected
# conditions; adding a backend does not require repeating the full design.
# Use an external timeout and process RSS measurement. These are single-seed
# operational stress checks, not recovery, coverage, or model-adequacy studies.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) %in% 2:3)
case <- args[1L]
out <- args[2L]
backend <- if (length(args) == 3L) match.arg(args[3L], c("pam", "average", "complete")) else "pam"
method <- if (backend == "pam") "pam" else "hierarchical"
linkage <- if (backend == "pam") NULL else backend
dir.create(out, recursive = TRUE, showWarnings = FALSE)
source("R/reporting.R") # Package helpers, also on R versions without base %||%.
source("R/api-feature-clustering.R")
source("R/api-hierarchical-clustering.R")
source("R/api-cluster-comparison.R")
design <- data.frame(
  Case = c("size_100", "size_1000", "size_5000", "features_40", "groups_100",
           "duplicates", "rare_skewed", "no_planted_groups", "mi_5", "mi_20", "mi_high_missing"),
  N = c(100L, 1000L, 5000L, 1000L, 500L, 300L, 500L, 400L, 300L, 300L, 300L),
  P = c(8L, 8L, 8L, 40L, 8L, 8L, 8L, 8L, 8L, 8L, 8L),
  K = c(4L, 4L, 4L, 4L, 100L, 8L, 4L, 4L, 4L, 4L, 4L),
  M = c(rep(0L, 8L), 5L, 20L, 5L),
  MissingRate = c(rep(0, 8L), .2, .2, .6))
design <- rbind(design, data.frame(
  Case = paste0("features_", c(100L, 500L, 1000L)),
  N = 1000L, P = c(100L, 500L, 1000L), K = 4L, M = 0L,
  MissingRate = 0))
stopifnot(case %in% design$Case)
condition <- design[match(case, design$Case), ]
condition$Backend <- backend
write.csv(condition, file.path(out, "condition.csv"), row.names = FALSE)
set.seed(20260921L)
n <- condition$N
p <- condition$P
data <- data.frame(ID = sprintf("R%05d", seq_len(n)))
for (j in seq_len(p)) {
  data[[paste0("Feature", j)]] <- switch(as.character((j - 1L) %% 4L),
    "0" = rnorm(n),
    "1" = factor(sample(c("Language", "Science", "Social science"), n, TRUE)),
    "2" = ordered(sample(c("Introductory", "Intermediate", "Advanced"), n, TRUE),
                  levels = c("Introductory", "Intermediate", "Advanced")),
    "3" = sample(c(FALSE, TRUE), n, TRUE))
}
if (case == "duplicates") data[-1] <- data[rep(1:12, length.out = n), -1]
if (case == "rare_skewed") {
  stratum <- rep(0:3, c(n - 15L, 5L, 5L, 5L))
  for (j in c(1L, 5L)) data[[j + 1L]] <- stratum * 10 + rnorm(n, sd = .01)
  for (j in c(2L, 6L)) data[[j + 1L]] <- factor(paste0("Background", stratum))
  specialty <- as.character(data$Feature2)
  specialty[n] <- "SingleRaterSpecialty"
  data$Feature2 <- factor(specialty)
  for (j in c(3L, 7L)) data[[j + 1L]] <- ordered(pmin(stratum, 2), levels = 0:2)
  for (j in c(4L, 8L)) data[[j + 1L]] <- stratum > 0
}
features <- names(data)[-1L]
if (condition$M > 0L) {
  for (name in features) data[[name]][sample.int(n, n * condition$MissingRate)] <- NA
}
structural <- if (case == "mi_high_missing") seq_len(15L) else integer()
data$Feature1[structural] <- NA_real_
reasons <- if (length(structural)) data.frame(ID = data$ID[structural],
  Feature = "Feature1", Reason = "Not applicable") else NULL
review <- mfrm_features(data, "ID", features, reasons)
weights <- stats::setNames(rep(1, p), features)
weights[1] <- 3
warnings <- character()
events <- NULL
result <- tryCatch(withCallingHandlers({
  started <- proc.time()[["elapsed"]]
  model_seconds <- 0
  if (condition$M > 0L) {
    cells <- subset(review$missing, Reason != "Not applicable")
    where <- is.na(data)
    where[structural, "Feature1"] <- FALSE
    methods <- mice::make.method(data, where = where)
    methods["ID"] <- ""
    predictors <- mice::make.predictorMatrix(data)
    predictors[, "ID"] <- 0
    predictors["ID", ] <- 0
    # Structurally missing, nonimputed predictors must not block other targets.
    if (length(structural)) predictors[, "Feature1"] <- 0
    model_start <- proc.time()[["elapsed"]]
    model <- mice::mice(data, m = condition$M, maxit = 5, where = where,
      method = methods, predictorMatrix = predictors, seed = 3107, printFlag = FALSE)
    model_seconds <- proc.time()[["elapsed"]] - model_start
    events <- model$loggedEvents
    a <- mfrm_cluster_imputed(review, model, cells, condition$K, missing = "omit",
      method = method, linkage = linkage)
    b <- mfrm_cluster_imputed(review, model, cells, condition$K + 1L, weights, missing = "omit",
      method = method, linkage = linkage)
    stopifnot(length(a$analyses) == condition$M,
      identical(a$imputation_model, model), identical(a$feature_data, review),
      all(a$analysis_summary$Excluded == length(structural)))
    ids <- data$ID[setdiff(seq_len(n), structural)]
    co <- a$co_membership[ids, ids, drop = FALSE]
    stopifnot(isTRUE(all.equal(co, t(co))), all(is.finite(co)),
      all(co >= 0 & co <= 1), all(diag(co) == 1))
    if (length(structural)) stopifnot(all(is.na(a$co_membership[data$ID[structural], ])))
    # Check the all-imputation denominator independently for a pair sample.
    left <- sample(ids, 200L, TRUE)
    right <- sample(ids, 200L, TRUE)
    together <- vapply(a$analyses, function(fit) {
      labels <- stats::setNames(fit$membership$Cluster, fit$membership$ID)
      unname(labels[left] == labels[right])
    }, logical(length(left)))
    stopifnot(isTRUE(all.equal(unname(a$co_membership[cbind(left, right)]), rowMeans(together))))
    fits <- c(a$analyses, b$analyses)
  } else {
    if (backend == "pam") {
      a <- mfrm_cluster(review, condition$K)
      b <- mfrm_cluster(review, condition$K + 1L, weights)
    } else {
      a <- mfrm_cluster_hierarchical(review, condition$K, linkage = linkage)
      b <- mfrm_cluster_hierarchical(review, condition$K + 1L, weights, linkage = linkage)
    }
    fits <- list(a, b)
  }
  comparison_start <- proc.time()[["elapsed"]]
  compared <- mfrm_cluster_compare(list(EqualWeights = a, MoreGroupsWeighted = b))
  comparison_seconds <- proc.time()[["elapsed"]] - comparison_start
  for (fit in fits) {
    labels <- fit$membership$Cluster
    included <- !is.na(labels)
    stopifnot(identical(fit$membership$ID, data$ID),
      sum(included) == n - length(structural),
      length(unique(labels[included])) == fit$settings$k,
      sum(fit$cluster_summary$N) == sum(included),
      all(is.finite(fit$membership$Silhouette[included])),
      all(abs(fit$membership$Silhouette[included]) <= 1 + 1e-12))
    if (backend == "pam") {
      stopifnot(sum(fit$membership$Medoid, na.rm = TRUE) == fit$settings$k)
    } else {
      stopifnot(inherits(fit, "mfrm_hierarchical_clusters"),
        identical(fit$settings$linkage, linkage),
        identical(fit$tree$labels, data$ID[included]),
        nrow(fit$tree$merge) == sum(included) - 1L,
        all(is.finite(fit$tree$height)), all(diff(fit$tree$height) >= -1e-12),
        identical(labels[included], unname(stats::cutree(fit$tree, k = fit$settings$k))),
        is.null(fit$medoids), !"Medoid" %in% names(fit$membership))
    }
  }
  stopifnot(all(is.finite(compared$comparisons$AdjustedRand)),
    all(compared$comparisons$AdjustedRand >= -1 & compared$comparisons$AdjustedRand <= 1),
    all(compared$comparisons$ChangedFraction >= 0 & compared$comparisons$ChangedFraction <= 1),
    all(compared$comparisons$Pairs == choose(n - length(structural), 2)),
    nrow(compared$comparisons) == max(1L, condition$M))
  write.csv(compared$analysis_summary, file.path(out, "analyses.csv"), row.names = FALSE)
  write.csv(compared$comparisons, file.path(out, "comparisons.csv"), row.names = FALSE)
  data.frame(Case = case, Backend = backend, Passed = TRUE, N = n, P = p, M = condition$M,
    SelectedMissingCells = nrow(review$missing), Excluded = length(structural),
    ModelSeconds = model_seconds, ComparisonSeconds = comparison_seconds,
    AnalysisSeconds = proc.time()[["elapsed"]] - started,
    ResultMiB = as.numeric(object.size(compared)) / 1024^2,
    MinGroupSize = min(compared$analysis_summary$MinGroupSize),
    MeanSilhouette = mean(compared$analysis_summary$MeanSilhouette),
    Error = "")
}, warning = function(w) {
  warnings <<- c(warnings, conditionMessage(w))
  invokeRestart("muffleWarning")
}), error = function(e) data.frame(Case = case, Backend = backend, Passed = FALSE, Error = conditionMessage(e)))
write.csv(result, file.path(out, "result.csv"), row.names = FALSE)
writeLines(warnings, file.path(out, "warnings.txt"))
if (!is.null(events)) write.csv(events, file.path(out, "mice-events.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
files <- c("R/reporting.R", "R/api-feature-clustering.R", "R/api-hierarchical-clustering.R", "R/api-cluster-comparison.R",
           "inst/validation/external-feature-stress-0.2.4.R")
write.csv(data.frame(File = files, MD5 = unname(tools::md5sum(files))),
          file.path(out, "source-md5.csv"), row.names = FALSE)
print(result, row.names = FALSE)
if (!result$Passed) quit(status = 1L)
