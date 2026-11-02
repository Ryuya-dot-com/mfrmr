# Group mixed external features using Gower distances and PAM

Partition an entity-level feature table using Gower dissimilarities and
partitioning around medoids (PAM) from the optional `cluster` package.
Use `mfrm_cluster()` and select `method = "pam"` (the default),
`"hierarchical"`, or `"kmeans"`. Each method retains its own geometry,
settings and result class; the method is never selected from the data.

The former `mfrm_cluster_pam()` entry is no longer exported; use
`mfrm_cluster(..., method = "pam")`. Its calculation is unchanged.

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

# S3 method for class 'mfrm_clusters'
print(x, ...)

# S3 method for class 'mfrm_clusters'
summary(object, ...)
```

## Arguments

- x:

  An object returned by
  [`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_features.md).

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

- method:

  Clustering method: `"pam"`, `"hierarchical"`, or `"kmeans"`. PAM and
  hierarchical clustering use Gower distances. K-means uses numeric
  features or an existing
  [`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_pca.md)
  result. See the method guides [hierarchical clustering
  details](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster_hierarchical.md)
  and [k-means
  details](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster_kmeans.md)
  for their limits.

- ...:

  Reserved for method compatibility.

- object:

  An object returned by `mfrm_cluster()`.

## Value

An `mfrm_clusters` object containing `membership` (ID, Cluster, Medoid,
Silhouette), `cluster_summary`, numeric and categorical `profiles`,
`medoids`, the reviewed `feature_data`, and `settings`. Silhouette
values describe within-sample separation, not membership probabilities
or resampling stability.
[`summary()`](https://rdrr.io/r/base/summary.html) returns the
cluster-size/silhouette table. Numeric profiles report the mean, median
and sample SD in the original feature units. SD is `NA` for a one-entity
group and zero for identical values in a group with at least two
entities. A singleton's silhouette is zero by convention; it is not
evidence of group separation.

## Details

Numeric differences are divided by the feature range among included
entities; nominal features use match/mismatch and logical features use
symmetric binary differences. Ordered factors use equally spaced integer
codes in their declared level order, divided by the observed code range.
Unused intermediate levels retain their spacing. The Gower dissimilarity
is the weighted mean of these feature contributions, dividing by the sum
of the selected weights. Weights apply to features, not entities.
Numeric 0/1 features are treated as numeric, not asymmetric
presence/absence. Every selected feature must vary among included
entities. Gower scaling, feature types, weights, omission policy, and
numeric ranges are retained. Numeric ranges and relative weights must be
representable without overflow or underflow; rescale features or revise
extreme weight ratios if refused.

PAM uses deterministic BUILD/SWAP initialization; tied distances may
admit alternative partitions. Group numbers are arbitrary labels. These
are exploratory groups, not latent classes, ability estimates, or
assessments of rater quality. No inference, uncertainty propagation,
new-entity classification, or resampling stability is provided. Omission
may change both the sample and numeric ranges and does not correct
missing-data bias.

Pairwise distances require quadratic memory. This interface is limited
to 5,000 included entities. It does not silently sample larger inputs.
This input limit does not guarantee low memory use or acceptable run
time.

For feature selection, missingness review, and multiple-imputation
examples, see [online feature-analysis
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-external-features.html).

## Reading clustering metrics

For entity i, a(i) is its mean dissimilarity to other members of its own
group; b(i) is the smallest mean dissimilarity to any other group.
Silhouette = (b - a) / max(a, b), between -1 and 1. Values near 1
indicate compact, separated placement in this fitted geometry; near zero
indicates a boundary; negative values indicate closer average proximity
to another group. A singleton receives 0 by convention; zero does not
establish overlap. A zero denominator also receives 0. Overall means
weight entities equally; cluster means use that cluster's included
entities. Excluded IDs have NA. A silhouette is neither a membership
probability nor evidence of stability.

Gower distance is unitless in `[0, 1]` here: numeric absolute
differences divided by included-sample ranges, nominal/binary
mismatches, and ordinal rank differences are combined using the
specified feature weights. The PAM medoid is an actual included entity
minimizing within-group total dissimilarity; it is not a feature-wise
mean. Profile Mean/Median/SD retain original units; categorical
Proportion uses included group size as denominator. A large group or a
high silhouette is not a better-performing group. Compare partitions
under a fixed feature/distance definition; changing the sample, weights
or scaling changes what these numbers measure. See
[`cluster::silhouette()`](https://rdrr.io/pkg/cluster/man/silhouette.html)
and Rousseeuw (1987),
[doi:10.1016/0377-0427(87)90125-7](https://doi.org/10.1016/0377-0427%2887%2990125-7)
, for the silhouette definition.

## See also

[`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_features.md),
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster_imputed.md),
[`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster_compare.md),
[hierarchical clustering
details](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster_hierarchical.md),
[`plot.mfrm_clusters()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_clusters.md),
[`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html),
[`cluster::pam()`](https://rdrr.io/pkg/cluster/man/pam.html)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("mfrm_cluster", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
if (requireNamespace("cluster", quietly = TRUE)) {
  # Fictional raters; R2 has unrecorded experience, not zero years.
  raters <- data.frame(Rater = paste0("R", 1:6),
    ExperienceYears = c(1, NA, 3, 12, 13, 14),
    Specialty = rep(c("Language", "Science"), each = 3))
  features <- mfrm_features(raters, "Rater", c("ExperienceYears", "Specialty"))
  # The default stops on missing features. Here omission is explicit.
  groups <- mfrm_cluster(method = "pam", features, k = 2,
    weights = c(ExperienceYears = 2, Specialty = 1), missing = "omit")
  groups$membership  # R2 remains present with unavailable membership.
  summary(groups)
  groups$profiles
  groups$medoids
}
} # }
```
