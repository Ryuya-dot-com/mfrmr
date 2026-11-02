# Plot exploratory groups and imputation sensitivity

Inspect within-sample separation, individual feature profiles, or
pairwise co-membership across imputations using existing clustering
results.

## Usage

``` r
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

  An object returned by
  [`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster.md)
  or
  [`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster_imputed.md),
  as appropriate.

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

- ...:

  Reserved for future use; additional arguments are rejected.

- ids:

  For imputation heatmaps, an optional character vector of distinct
  entity IDs in the desired display order. Selection affects only the
  view, not clustering or the denominator. By default all IDs appear in
  input order.

## Value

Invisibly, a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
extracts the plotted table or matrix, title, subtitle, legend, and
excluded IDs. Heatmaps also retain the displayed IDs and the number of
imputations. Profile plots also retain `observations`: original-unit
entity values and group/exclusion status, suitable for custom
distribution plots; see
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
converts imputation co-membership heatmaps using the saved matrix, ID
order, label choice, colours and imputation count. The default and
`component = "matrix"` retain the complete view and its fixed
zero-to-one scale. Unavailable cells have both grey fill and crosses,
distinguishing them from zero even in monochrome. Metadata, including
excluded IDs, remain available with
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).
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
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## See also

[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster.md),
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster_imputed.md),
[`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster_compare.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
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
