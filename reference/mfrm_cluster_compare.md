# Compare exploratory groups across settings and clustering methods

Compare existing external-feature clustering results without refitting.
Review how group membership changes when the selected features, number
of groups, feature weights, or clustering method changes, including
paired comparisons across the same imputations.

## Usage

``` r
mfrm_cluster_compare(analyses)

# S3 method for class 'mfrm_cluster_comparison'
print(x, ...)

# S3 method for class 'mfrm_cluster_comparison'
summary(object, ...)
```

## Arguments

- analyses:

  A named list of at least two results from
  [`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  and/or
  [`mfrm_cluster_hierarchical()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_hierarchical.md),
  or a named list of results from
  [`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md).
  Do not mix the two result types. Names must be unique and nonblank.
  All results must use the same entity IDs and included entities.
  Selected features may differ; features with the same name must retain
  their original values and types. Row and feature order may differ. IDs
  must refer to the same entities, not, for example, persons and raters
  that happen to share ID labels. For imputed results, shared completed
  features must also match by imputation number. When feature selections
  differ, all results must retain the same `mids` object, including its
  data and settings; each retained completion is checked against it
  using the optional `mice` package. Reuse one fitted imputation model.

- x, object:

  An object returned by `mfrm_cluster_compare()`.

- ...:

  Reserved for method compatibility.

## Value

An `mfrm_cluster_comparison` object containing:

- `analysis_summary`: method, linkage (unavailable for PAM), group
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

## Details

Comparisons align entities by ID and do not compare numeric group labels
directly. Zero changed fraction and an adjusted Rand index of one
indicate identical partitions, allowing arbitrary renumbering of groups.
The changed fraction can be small when many pairs are separated in both
partitions. The adjusted Rand index corrects agreement against random
partitions with fixed group sizes; it can be negative. Neither measure
identifies the correct group count or establishes group validity.

Mean silhouette and group sizes help describe each partition. Silhouette
values calculated with different features or weights use different
distances; their maximum is not an automatic criterion for selecting
features or weights. Review group profiles in the retained `analyses`
alongside the comparison.

With multiple imputations, feature selection is applied to the same
completed data on both sides, without refitting the imputation model. A
feature omitted from clustering can remain an imputation predictor; this
comparison does not evaluate its removal from the imputation model.
Every imputation is retained. Summary means and ranges describe
sensitivity to settings across those imputations; they are not
Rubin-pooled estimates, confidence intervals, or sampling stability.
Conflicting shared feature values or different inclusion masks cause an
error rather than a silent intersection of entities or imputations. No
preferred setting, consensus partition, or hypothesis test is returned.

For an executable rater-attribute example that pairs multiple
imputations across settings, see
[`vignette("mfrmr-external-features", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-external-features.md).

## References

Hubert, L. and Arabie, P. (1985). Comparing partitions. Journal of
Classification, 2, 193–218.
[doi:10.1007/BF01908075](https://doi.org/10.1007/BF01908075) .

## See also

[`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md),
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md),
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md),
[`mfrm_cluster_hierarchical()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_hierarchical.md)

## Examples

``` r
if (requireNamespace("cluster", quietly = TRUE)) {
  # Fictional attributes; experience is measured in completed years.
  raters <- data.frame(Rater = paste0("R", 1:8),
    ExperienceYears = c(1, 2, 3, 4, 11, 12, 13, 14),
    Specialty = rep(c("Language", "Science"), 4))
  features <- mfrm_features(raters, "Rater", c("ExperienceYears", "Specialty"))
  fits <- list(
    TwoGroups = mfrm_cluster(features, k = 2),
    ThreeGroups = mfrm_cluster(features, k = 3),
    ExperienceWeighted = mfrm_cluster(features, k = 2,
      weights = c(ExperienceYears = 3, Specialty = 1)))
  comparison <- mfrm_cluster_compare(fits)
  summary(comparison)
  comparison$analysis_summary
  comparison$comparisons
  # Hold the entities and group count fixed while changing the feature set.
  experience <- mfrm_features(raters, "Rater", "ExperienceYears")
  feature_comparison <- mfrm_cluster_compare(list(
    BothFeatures = fits$TwoGroups,
    ExperienceOnly = mfrm_cluster(experience, k = 2)))
  feature_comparison$analysis_summary
  feature_comparison$weights
}
#>         Analysis         Feature Weight
#> 1   BothFeatures ExperienceYears      1
#> 2   BothFeatures       Specialty      1
#> 3 ExperienceOnly ExperienceYears      1
```
