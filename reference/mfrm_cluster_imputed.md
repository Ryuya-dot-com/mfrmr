# Compare exploratory groups across external-feature imputations

Apply the same Gower clustering analysis to each completed data set from
`mice`, retaining all analyses and the fraction of imputations in which
each pair of entities belongs to the same group.

## Usage

``` r
mfrm_cluster_imputed(
  x,
  imputed,
  impute,
  k,
  weights = NULL,
  missing = c("error", "omit"),
  method = c("pam", "hierarchical"),
  linkage = NULL
)

# S3 method for class 'mfrm_imputed_clusters'
print(x, ...)

# S3 method for class 'mfrm_imputed_clusters'
summary(object, ...)
```

## Arguments

- x:

  An original feature table reviewed with
  [`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md).

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

- k, weights:

  As in
  [`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md).
  The same choices apply to every imputation.

- missing:

  Either `"error"` (default) or `"omit"`, applied to missing features
  remaining after imputation. Explicit omission retains excluded IDs
  with unavailable memberships and pairwise proportions.

- method:

  `"pam"` (default) or `"hierarchical"`. The same method is used for
  every completion. Hierarchical analyses retain separate trees.

- linkage:

  For `method = "hierarchical"`, `"average"` (the default when `NULL`)
  or `"complete"`; see
  [`mfrm_cluster_hierarchical()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_hierarchical.md).
  Must be `NULL` for PAM, which has no linkage.

- ...:

  Reserved for method compatibility.

- object:

  An object returned by `mfrm_cluster_imputed()`.

## Value

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

## Details

Fit and review the imputation model using
[`mice::mice()`](https://amices.org/mice/reference/mice.html) before
calling this function. Choose methods, predictors (including relevant
auxiliary variables), iteration count, and number of imputations for the
intended analysis. Exclude the identifier from imputation and
prediction. Inspect model diagnostics, including `loggedEvents` and
chain behavior; this adapter checks data consistency, not convergence or
model adequacy. The original model and its diagnostics remain available
in the result.

Missing reasons do not identify a statistical missing-data mechanism. Do
not impute structurally undefined attributes such as "not applicable".
Specify eligible cells through `where` when fitting `mice` and list the
same cells in `impute`. An incomplete predictor that is not imputed can
prevent imputation of other variables; configure predictors accordingly.
Assumptions about nonresponse require substantive justification; this
function does not correct bias automatically or impute rating responses.
Nonresponse related to unobserved values needs separate sensitivity
assumptions; observed-data checks cannot establish their adequacy.

IDs, observed feature values, feature types, and factor levels/order
must be preserved. Numeric 0/1 completions of originally logical
features are restored to logical values. Row order is restored by ID.
Every selected cell must be completed in every imputation. Any invalid
completion or failed clustering stops the comparison with its imputation
number; no failures are discarded. Remaining missingness, and thus the
included sample, is the same across imputations. Gower numeric ranges
are recalculated in each completed sample; differences may reflect
changes in both feature values and scaling. Hierarchical trees belong to
individual completions; no pooled tree, consensus hierarchy, or
branch-support estimate is returned.

Co-membership proportions are invariant to arbitrary group numbering.
They describe sensitivity to the supplied imputations, conditional on
the imputation model, features, weights, and group count. They are not
posterior membership probabilities, sampling stability, or Rubin-pooled
estimates. No consensus partition, confidence interval, or automatic
group selection is produced. Both the full ID-indexed matrix and
pairwise distances require quadratic memory, so this comparison is
limited to 5,000 total entities. This input limit is not a memory or
run-time guarantee. Retaining all completed analyses also increases
memory use with the imputation count.

The short example below illustrates the interface using
[`mice::nhanes2`](https://amices.org/mice/reference/nhanes2.html). For a
complete example with fictional rater attributes, explicit missingness
reasons, imputation diagnostics, and comparisons of group counts and
weights, see
[`vignette("mfrmr-external-features", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-external-features.md).

## See also

[`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md),
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md),
[`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_compare.md),
[`mfrm_cluster_hierarchical()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_hierarchical.md),
[`plot.mfrm_clusters()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_clusters.md),
[`mice::mice()`](https://amices.org/mice/reference/mice.html),
[`mice::complete()`](https://tidyr.tidyverse.org/reference/complete.html)

## Examples

``` r
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
#> NULL
```
