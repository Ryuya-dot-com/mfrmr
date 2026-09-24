# K-means groups from numeric features or retained principal components

Divide people, raters or tasks into k groups with similar numeric
attributes. The algorithm minimizes squared distances within groups,
using the numeric features or retained principal components supplied by
you. The groups are descriptive; they do not measure ability or rater
quality.

## Usage

``` r
mfrm_cluster_kmeans(
  x,
  k,
  weights = NULL,
  missing = c("error", "omit"),
  scale = TRUE,
  nstart = 25,
  iter.max = 100,
  seed = 1,
  silhouette = TRUE
)
```

## Arguments

- x:

  A table reviewed with
  [`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md).
  For `mfrm_cluster_kmeans()`, a result from
  [`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md)
  is also accepted.

- k:

  Number of groups, an integer from 2 to one less than the number of
  included entities, and no greater than their number of distinct
  profiles. The number is chosen by the user, not optimized
  automatically.

- weights:

  Optional named, strictly positive finite numeric vector with one
  weight per selected feature. Defaults to equal weights. Names, not
  vector order, identify features. Remove a feature to exclude it.

- missing:

  Either `"error"` (default) or `"omit"`. The latter excludes incomplete
  entities explicitly, retaining their IDs, reasons, and missing group
  membership in the result. No values are imputed.

- scale:

  Divide centered numeric features by their sample standard deviations
  (`TRUE`, default). With `FALSE`, distances retain the original feature
  units. Numeric coding must have a meaningful Euclidean interpretation;
  factors, ordered factors, characters and logical features are refused.

- nstart:

  Number of random starts; default 25.

- iter.max:

  Maximum iterations per start; default 100.

- seed:

  Nonnegative integer seed. The default is 1. The caller's random number
  state is restored; the RNG kind is retained in `settings`.

- silhouette:

  Compute Euclidean silhouettes (`TRUE`, default) using the optional
  `cluster` package. This requires pairwise distances and is limited to
  5,000 included entities. Explicit `FALSE` avoids that quadratic
  allocation; silhouettes then remain unavailable, not zero. Other
  memory/time limits still depend on the dimensions and numerical
  workload.

## Value

An `mfrm_clusters` object with memberships, original-unit profiles,
cluster sizes and silhouettes, `centers` in the fitted space,
per-cluster `withinss`, `totss`, `tot.withinss`, the input PCA when
used, original feature data, transformation and settings. K-means has no
medoids.

## Details

Uses [`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html) with
Hartigan-Wong updates and the stated random starts. Warnings,
nonconvergence and nonfinite sums of squares stop the analysis; no
failed run is silently presented as a usable result. Multiple starts
reduce sensitivity to initialization without guaranteeing a global
optimum. Review alternative seeds separately when needed. Labels are
arbitrary and results can depend on input order, ties and RNG kind.

Numeric preprocessing matches
[`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md).
With a PCA input, its retained scores are used exactly: do not respecify
`weights`, `scale` or `missing`. Full-rank PCA preserves the distance
objective; truncation changes it. No component whitening is performed.
The centers of a truncated PCA are coordinates in that subspace;
`profiles` describe the original attributes. Categorical codes must not
be converted to numeric solely to pass this interface. Use
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
for Gower/PAM mixed-feature groups.

Compare fitted partitions using
[`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_compare.md).
Silhouettes calculated in different geometries are not directly
comparable evidence of which feature set, scale or component count is
correct. Grouping does not propagate measurement uncertainty or
establish rater quality.

## See also

[`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md),
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md),
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md),
[`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_compare.md),
[`plot.mfrm_clusters()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_clusters.md),
[`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html)

## Examples

``` r
raters <- data.frame(Rater = paste0("R", 1:8),
  ExperienceYears = c(1, 2, 3, 4, 10, 12, 13, 15),
  WorkshopHours = c(4, 12, 8, 20, 12, 28, 16, 32),
  AnnualRatings = c(80, 120, 90, 160, 280, 350, 300, 400))
features <- mfrm_features(raters, "Rater", names(raters)[-1])
direct <- mfrm_cluster_kmeans(features, 2, seed = 17, silhouette = FALSE)
reduced <- mfrm_cluster_kmeans(mfrm_pca(features, components = 2), 2,
  seed = 17, silhouette = FALSE)
summary(mfrm_cluster_compare(list(Features = direct, TwoPCs = reduced)))
#>      First Second Partitions Included Pairs MeanChangedFraction
#> 1 Features TwoPCs          1        8    28                   0
#>   MinChangedFraction MaxChangedFraction MeanAdjustedRand
#> 1                  0                  0                1
direct$centers
#>   ExperienceYears WorkshopHours AnnualRatings
#> 1       0.8959644     0.5690138     0.8801006
#> 2      -0.8959644    -0.5690138    -0.8801006
direct$profiles$numeric
#>   Cluster         Feature N  Mean Median        SD
#> 1       1 ExperienceYears 4  12.5   12.5  2.081666
#> 2       1   WorkshopHours 4  22.0   22.0  9.521905
#> 3       1   AnnualRatings 4 332.5  325.0 53.774219
#> 4       2 ExperienceYears 4   2.5    2.5  1.290994
#> 5       2   WorkshopHours 4  11.0   10.0  6.831301
#> 6       2   AnnualRatings 4 112.5  105.0 35.939764
```
