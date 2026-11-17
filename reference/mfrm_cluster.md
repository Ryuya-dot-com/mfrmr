# Group external features with an explicitly chosen clustering method

Group an entity-level feature table using PAM, hierarchical clustering
or numeric k-means. Gower-based methods use the optional `cluster`
package. Use `mfrm_cluster()` and select `method = "pam"` (the default),
`"hierarchical"`, or `"kmeans"`. Each method retains its own geometry,
settings and result class; the method is never selected from the data.

Compare existing external-feature clustering results without refitting.
Review how group membership changes when the selected features, number
of groups, feature weights, or clustering method changes, including
paired comparisons across the same imputations.

The former `mfrm_cluster_pam()` entry is no longer exported; use
`mfrm_cluster(..., method = "pam")`. Its calculation is unchanged.

Apply the same external-feature clustering analysis to each completed
data set from `mice`, retaining all analyses and the fraction of
imputations in which each pair of entities belongs to the same group.

Inspect within-sample separation, individual feature profiles, or
pairwise co-membership across imputations using existing clustering
results.

## Usage

``` r
mfrm_cluster(
  x,
  k,
  weights = NULL,
  missing = c("error", "omit"),
  method = c("pam", "hierarchical", "kmeans"),
  ...
)

mfrm_cluster_compare(analyses)

# S3 method for class 'mfrm_cluster_comparison'
print(x, ...)

# S3 method for class 'mfrm_cluster_comparison'
summary(object, ...)

# S3 method for class 'mfrm_clusters'
print(x, ...)

# S3 method for class 'mfrm_clusters'
summary(object, ...)

mfrm_cluster_imputed(
  x,
  imputed,
  impute,
  k,
  weights = NULL,
  missing = c("error", "omit"),
  method = c("pam", "hierarchical", "kmeans"),
  linkage = NULL,
  components = NULL,
  scale = TRUE,
  nstart = 25,
  iter.max = 100,
  seed = 1,
  silhouette = TRUE
)

# S3 method for class 'mfrm_imputed_clusters'
print(x, ...)

# S3 method for class 'mfrm_imputed_clusters'
summary(object, ...)

# S3 method for class 'mfrm_hierarchical_clusters'
plot(
  x,
  type = c("dendrogram", "silhouette", "profile"),
  feature = NULL,
  labels = NULL,
  draw = TRUE,
  preset = "standard",
  ...
)

# S3 method for class 'mfrm_clusters'
plot(
  x,
  type = c("silhouette", "profile"),
  feature = NULL,
  labels = NULL,
  draw = TRUE,
  preset = "standard",
  ...
)

# S3 method for class 'mfrm_imputed_clusters'
plot(x, ids = NULL, labels = NULL, draw = TRUE, preset = "standard", ...)
```

## Arguments

- x:

  An object returned by `mfrm_cluster()` or `mfrm_cluster_imputed()`, as
  appropriate.

- k:

  As in `mfrm_cluster()`. The same choices apply to every imputation.

- weights:

  As in `mfrm_cluster()`. The same choices apply to every imputation.

- missing:

  Either `"error"` (default) or `"omit"`, applied to missing features
  remaining after imputation. Explicit omission retains excluded IDs
  with unavailable memberships and pairwise proportions.

- method:

  `"pam"` (default), `"hierarchical"`, or `"kmeans"`. The same method is
  used for every completion. Hierarchical analyses retain separate
  trees.

- ...:

  Reserved for future use; additional arguments are rejected.

- analyses:

  A named list of at least two results from `mfrm_cluster()` and/or
  hierarchical clustering details or k-means details, or a named list of
  results from `mfrm_cluster_imputed()`. Do not mix the two result
  types. Names must be unique and nonblank. All results must use the
  same entity IDs and included entities. Selected features may differ;
  features with the same name must retain their original values and
  types. Row and feature order may differ. IDs must refer to the same
  entities, not, for example, persons and raters that happen to share ID
  labels. For imputed results, shared completed features must also match
  by imputation number. When feature selections differ, all results must
  retain the same `mids` object, including its data and settings; each
  retained completion is checked against it using the optional `mice`
  package. Reuse one fitted imputation model. Results saved in separate
  RDS files can be compared after reopening when their retained
  imputation data, settings and formula expressions are unchanged.
  Formula environments are not evaluated in this comparison; no
  completions are regenerated.

- object:

  An object returned by `mfrm_cluster_imputed()`.

- imputed:

  A `mids` object from the optional `mice` package, containing the
  identifier, selected features, and at least two imputations. Its
  original data must match `x` by ID. Auxiliary variables may be
  included in the imputation model without becoming clustering features.

- impute:

  A data frame with `ID` and `Feature` columns explicitly listing the
  missing cells to impute. For example, select appropriate rows from
  `x$missing` after reviewing their reasons. Extra columns are ignored.
  The selected-feature entries in `imputed$where` must match this
  selection; other missing cells must remain missing in every completed
  data set. If all selected features are already complete, supply the
  empty `x$missing` table. This retains one partition per imputation so
  the result can be compared with other feature selections from the same
  model.

- linkage:

  For `method = "hierarchical"`, `"average"` (the default when `NULL`)
  or `"complete"`; see hierarchical clustering details. Must be `NULL`
  for PAM and k-means, which have no linkage.

- components:

  For k-means, `NULL` uses numeric features directly. An integer fits
  PCA separately in each completion and uses that many leading
  components. No whitening, pooled PCA basis or component-sign matching
  is performed.

- scale:

  For `method = "kmeans"`, as in k-means details. These arguments must
  not be supplied for other methods. The same seed and settings are used
  for every completion; sensitivity still includes possible changes in
  local optima. Review alternative seeds separately.

- nstart:

  For `method = "kmeans"`, as in k-means details. These arguments must
  not be supplied for other methods. The same seed and settings are used
  for every completion; sensitivity still includes possible changes in
  local optima. Review alternative seeds separately.

- iter.max:

  For `method = "kmeans"`, as in k-means details. These arguments must
  not be supplied for other methods. The same seed and settings are used
  for every completion; sensitivity still includes possible changes in
  local optima. Review alternative seeds separately.

- seed:

  For `method = "kmeans"`, as in k-means details. These arguments must
  not be supplied for other methods. The same seed and settings are used
  for every completion; sensitivity still includes possible changes in
  local optima. Review alternative seeds separately.

- silhouette:

  For `method = "kmeans"`, as in k-means details. These arguments must
  not be supplied for other methods. The same seed and settings are used
  for every completion; sensitivity still includes possible changes in
  local optima. Review alternative seeds separately.

- type:

  For a single partition, `"silhouette"` or `"profile"`.

- feature:

  A single selected feature name, required for `type = "profile"`.
  Numeric features show means and medians in their original units;
  categorical features show within-group proportions in the original
  level order (including unused factor levels).

- labels:

  Whether to display entity IDs on silhouettes or heatmaps. The default
  displays them for at most 50 entities. No entities are sampled when
  labels are hidden. Profile plots always label groups and levels.

- draw:

  Draw the plot when `TRUE`; `FALSE` only returns plotted values.

- preset:

  Plot style: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`.

- ids:

  For imputation heatmaps, an optional character vector of distinct
  entity IDs in the desired display order. Selection affects only the
  view, not clustering or the denominator. By default all IDs appear in
  input order.

## Value

PAM returns an `mfrm_clusters` object containing `membership` (ID,
Cluster, Medoid, Silhouette), `cluster_summary`, numeric and categorical
`profiles`, `medoids`, the reviewed `feature_data`, and `settings`.
Silhouette values describe within-sample separation, not membership
probabilities or resampling stability.
[`summary()`](https://rdrr.io/r/base/summary.html) returns the
cluster-size/silhouette table. Numeric profiles report the mean, median
and sample SD in the original feature units. SD is `NA` for a one-entity
group and zero for identical values in a group with at least two
entities. A singleton's silhouette is zero by convention; it is not
evidence of group separation. Hierarchical and k-means results retain
their respective subclasses and method-specific tree/center components;
see their linked help.

An `mfrm_cluster_comparison` object containing:

- `analysis_summary`: method, distance, fitted space, scaling, retained
  component count, linkage (unavailable for PAM and k-means), group
  count, selected feature count (`Features`), included/excluded entity
  counts, smallest/largest group sizes, and mean silhouette for each
  analysis and imputation. `Imputation` is `NA` for ordinary clustering
  results.

- `weights`: selected features and their supplied weights for each
  analysis. Unselected features have no row; they are not zero-weight
  inputs.

- `comparisons`: all pairs of analyses, with one row per imputation.
  `Pairs` counts unordered pairs of included entities, excluding
  self-pairs. `SplitPairs` were together in `First` and apart in
  `Second`; `JoinedPairs` were apart in `First` and together in
  `Second`. `ChangedFraction` is their sum divided by `Pairs`.
  `AdjustedRand` is the adjusted Rand index.

- `comparison_summary`: number of compared partitions, mean/minimum/
  maximum changed fraction, and mean adjusted Rand index for each
  analysis pair. [`summary()`](https://rdrr.io/r/base/summary.html)
  returns this table.

- `analyses`: the original results, including omitted IDs and all
  imputation-specific partitions, profiles, and settings.

An `mfrm_imputed_clusters` object containing `analyses` (one
`mfrm_clusters` object per imputation), `co_membership` (a symmetric
matrix indexed by ID), `analysis_summary`, original `feature_data`,
`imputed_cells` with original reasons, the full `imputation_model`, and
`settings`. Every available matrix entry uses all `settings$imputations`
analyses as its denominator; pairs involving excluded entities are `NA`,
including their diagonal entries.
[`summary()`](https://rdrr.io/r/base/summary.html) returns
per-imputation counts and mean silhouette widths. Numeric ranges are
retained in each analysis. Hierarchical partitions inherit from
`mfrm_clusters` and retain their trees. Method and linkage are retained
in `settings`.

Invisibly, a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts the plotted table or matrix, title, subtitle, legend, and
excluded IDs. Heatmaps also retain the displayed IDs and the number of
imputations. Profile plots also retain `observations`: original-unit
entity values and group/exclusion status, suitable for custom
distribution plots; see
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
converts imputation co-membership heatmaps using the saved matrix, ID
order, label choice, colours and imputation count. The default and
`component = "matrix"` retain the complete view and its fixed
zero-to-one scale. Unavailable cells have both grey fill and crosses,
distinguishing them from zero even in monochrome. Metadata, including
excluded IDs, remain available with
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
No values are recomputed or renormalized when IDs are selected. Use
`ggplot2::labs(title = NULL, subtitle = NULL, caption = NULL)` to hide
annotations while retaining the source data. Silhouette conversion
retains negative widths, saved order and the overall mean reference,
with group labels independent of colour. Numeric profiles retain
original-unit means/medians and counts; circles and triangles are offset
vertically to show coincident values without adding intervals.
Categorical profiles retain the original category order, unused levels,
group counts and a fixed zero-to-one proportion scale. Default and
`component = "table"` preserve the complete selected view; categorical
profiles also accept `component = "matrix"`. These conversions do not
recluster, select groups, or estimate uncertainty.

## Details

**PAM Gower clustering (`method = "pam"`, default)**: Numeric
differences are divided by included-entity ranges, nominal features use
match/mismatch, logical features use symmetric binary differences, and
ordered factors use equally spaced declared-level ranks divided by
observed rank range; feature contributions are combined by
`weights / sum(weights)` in `[0, 1]`. Every selected feature must vary,
and included entities are capped at 5,000 (quadratic pairwise memory).
PAM uses deterministic BUILD/SWAP initialization
([`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html),
[`cluster::pam()`](https://rdrr.io/pkg/cluster/man/pam.html)).

**Silhouette and scope**: For entity \\i\\, \\s(i) = (b(i) - a(i)) /
\max(a(i), b(i)) \in \[-1, 1\]\\
([`cluster::silhouette()`](https://rdrr.io/pkg/cluster/man/silhouette.html),
Rousseeuw, 1987,
[doi:10.1016/0377-0427(87)90125-7](https://doi.org/10.1016/0377-0427%2887%2990125-7)
); singletons and zero denominators receive `0` by convention, and
excluded IDs receive `NA`. Partitions are exploratory descriptions of
external attributes, without latent-ability or rater-quality inference;
see the [online feature-analysis
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-external-features.html).

Comparisons align entities by ID: `ChangedFraction = 0` and
`AdjustedRand = 1` indicate identical partitions up to group relabeling.
Silhouettes computed under different feature sets, scalings, or weights
use different geometries and are not automatic selection criteria.
Across multiple imputations, summary means and ranges describe
sensitivity across the retained completions rather than Rubin-pooled
inference; conflicting shared feature values or differing inclusion
masks fail closed.

Fit and diagnose the imputation model in
[`mice::mice()`](https://amices.org/mice/reference/mice.html) first
(excluding the ID column from imputation/predictors and declaring
eligible cells via `where` and `impute`). Observed values, types, and
factor levels must match `x` by ID; any invalid completion or failed
clustering stops with its imputation index. Gower ranges, k-means
standardization, and per-completion PCA bases are recomputed within each
completed sample (capped at 5,000 entities). Pairwise `co_membership`
proportions are label-invariant sensitivity summaries across the
supplied completions, not Rubin-pooled estimates or posterior membership
probabilities.

**Hierarchical Gower clustering (`method = "hierarchical"`)**: Uses
[`stats::hclust()`](https://rdrr.io/r/stats/hclust.html) and
[`stats::cutree()`](https://rdrr.io/r/stats/cutree.html) at `k` with
`linkage = "average"` (default, UPGMA) or `"complete"` (Ward linkage is
unsupported for mixed Gower dissimilarities; Murtagh & Legendre, 2014,
[doi:10.1007/s00357-014-9161-z](https://doi.org/10.1007/s00357-014-9161-z)
). Returns an `mfrm_hierarchical_clusters` subclass retaining `tree`
(`medoids` is `NULL`). Tied merge heights use merge order at cut `k`.
Default [`plot()`](https://rdrr.io/r/graphics/plot.default.html) draws
the stored dendrogram with `k`-group boxes (`component = "tree"` in
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md));
`"silhouette"` and `"profile"` views match `plot.mfrm_clusters()`.

**Numeric k-means (`method = "kmeans"`)**: Uses
[`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html) with
Hartigan-Wong updates (`nstart = 25`, `iter.max = 100`, `seed = 1`,
`scale = TRUE`, `silhouette = TRUE` up to 5,000 included entities).
Numeric preprocessing matches
[`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md);
when `x` is an `mfrm_pca` result, its saved scores are used without
respecifying `weights`, `scale`, or `missing`. Warnings, nonconvergence,
and nonfinite sums of squares fail closed. Returns an `mfrm_clusters`
object with `centers`, `withinss`, `totss`, and `tot.withinss`
(`medoids` is `NULL`); `1 - tot.withinss / totss` is descriptive
fitted-space scatter, not predictive accuracy or a test of `k`.

No model or clustering is refitted. Silhouette widths describe
separation in the fitted sample, not stability or probabilities. The
dashed line is the overall mean silhouette; excluded entities have no
silhouette.

Feature profiles describe one partition; numeric summaries have no
confidence intervals. For an imputed result, inspect a completion with
`plot(x$analyses[[1]], type = "profile", feature = "ExperienceYears")`.
Cluster numbers must not be averaged across imputations.

Imputation heatmaps show the fraction of all supplied imputations in
which each pair belongs to the same group, on a fixed zero-to-one scale.
Grey cells are unavailable pairs involving excluded entities, not zero
co-membership. These fractions describe sensitivity to imputations under
fixed settings, not membership probabilities, sampling stability, or a
consensus partition. Rows and columns follow input order or explicit
`ids`; no hierarchical clustering is performed. PAM is nonhierarchical
and these plots do not provide a dendrogram. Use
`mfrm_cluster(..., method = "hierarchical")` for a separate hierarchical
analysis and its dendrogram.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## References

Hubert, L. and Arabie, P. (1985). Comparing partitions. Journal of
Classification, 2, 193–218.
[doi:10.1007/BF01908075](https://doi.org/10.1007/BF01908075) .

## See also

[`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md),
[`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md),
[`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html),
[`cluster::pam()`](https://rdrr.io/pkg/cluster/man/pam.html)

[`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md),
`mfrm_cluster()`, `mfrm_cluster_imputed()`, hierarchical clustering
details

`mfrm_cluster()`, `mfrm_cluster_imputed()`, `mfrm_cluster_compare()`

## Examples

``` r
# Optional workflow; run explicitly with example("mfrm_cluster", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
if (requireNamespace("cluster", quietly = TRUE)) {
  raters <- data.frame(Rater = paste0("R", 1:6),
    ExperienceYears = c(1, NA, 3, 12, 13, 14),
    Specialty = rep(c("Language", "Science"), each = 3))
  features <- mfrm_features(raters, "Rater", c("ExperienceYears", "Specialty"))
  groups <- mfrm_cluster(method = "pam", features, k = 2,
    weights = c(ExperienceYears = 2, Specialty = 1), missing = "omit")
  groups$membership
  summary(groups)
}
} # }
if (requireNamespace("cluster", quietly = TRUE)) {
  # Fictional attributes; experience is measured in completed years.
  raters <- data.frame(Rater = paste0("R", 1:8),
    ExperienceYears = c(1, 2, 3, 4, 11, 12, 13, 14),
    Specialty = rep(c("Language", "Science"), 4))
  features <- mfrm_features(raters, "Rater", c("ExperienceYears", "Specialty"))
  fits <- list(
    TwoGroups = mfrm_cluster(method = "pam", features, k = 2),
    ThreeGroups = mfrm_cluster(method = "pam", features, k = 3),
    ExperienceWeighted = mfrm_cluster(method = "pam", features, k = 2,
      weights = c(ExperienceYears = 3, Specialty = 1)))
  comparison <- mfrm_cluster_compare(fits)
  summary(comparison)
  comparison$analysis_summary
  comparison$comparisons
  # Hold the entities and group count fixed while changing the feature set.
  experience <- mfrm_features(raters, "Rater", "ExperienceYears")
  feature_comparison <- mfrm_cluster_compare(list(
    BothFeatures = fits$TwoGroups,
    ExperienceOnly = mfrm_cluster(method = "pam", experience, k = 2)))
  feature_comparison$analysis_summary
  feature_comparison$weights
}
#>         Analysis         Feature Weight
#> 1   BothFeatures ExperienceYears      1
#> 2   BothFeatures       Specialty      1
#> 3 ExperienceOnly ExperienceYears      1
# Optional integration example (loads additional modelling or rendering packages).
# example("mfrm_cluster_imputed", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
if (requireNamespace("mice", quietly = TRUE) &&
    requireNamespace("cluster", quietly = TRUE)) {
  attributes <- mice::nhanes2
  attributes$Person <- paste0("P", seq_len(nrow(attributes)))
  review <- mfrm_features(attributes, "Person", c("bmi", "chl"))
  # Here all missing selected attributes are assumed eligible after review.
  cells <- review$missing
  method <- mice::make.method(attributes)
  method["Person"] <- ""
  predictors <- mice::make.predictorMatrix(attributes)
  predictors[, "Person"] <- 0
  predictors["Person", ] <- 0
  # Small settings illustrate the API, not an adequacy recommendation.
  model <- mice::mice(attributes, m = 3, maxit = 2, method = method,
    predictorMatrix = predictors, seed = 42, printFlag = FALSE)
  result <- mfrm_cluster_imputed(review, model, cells, k = 2)
  summary(result)
  result$co_membership[1:4, 1:4]
  result$imputation_model$loggedEvents
}
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_clusters", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
if (requireNamespace("cluster", quietly = TRUE)) {
  raters <- data.frame(Rater = paste0("R", 1:6),
    ExperienceYears = c(1, 2, 3, 12, 13, 14),
    Specialty = factor(rep(c("Language", "Science"), each = 3)))
  groups <- mfrm_cluster(method = "pam", mfrm_features(raters, "Rater",
    c("ExperienceYears", "Specialty")), k = 2)
  plot(groups)
  plot(groups, type = "profile", feature = "ExperienceYears")
  plot(groups, type = "profile", feature = "Specialty")
  values <- plot_data(plot(groups, draw = FALSE))
  values$table
}
} # }
```
