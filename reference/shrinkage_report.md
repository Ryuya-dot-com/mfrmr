# Extract the shrinkage report from a fitted mfrm_fit

Lightweight accessor that returns the per-facet empirical-Bayes
shrinkage table stored on a fit when `facet_shrinkage != "none"`.
Returns `NULL` (with a message) when no shrinkage has been applied so
callers can probe without error.

## Usage

``` r
shrinkage_report(fit)
```

## Arguments

- fit:

  An `mfrm_fit` object.

## Value

A data.frame with one row per facet (and optionally `"Person"`) or
`NULL` when shrinkage has not been applied.

## See also

[`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 300,
                facet_shrinkage = "empirical_bayes")
shrinkage_report(fit)
#>       Facet NLevels NLevelsUsed       Tau2     MeanSE2 MeanShrinkage
#> 1     Rater       4           4 0.06402776 0.009499649     0.1291985
#> 2 Criterion       4           4 0.05258949 0.009500118     0.1530052
#>   EffectiveDF          Method PriorSource Note SupportsFormalInference
#> 1    3.483206 empirical_bayes   empirical <NA>                   FALSE
#> 2    3.387979 empirical_bayes   empirical <NA>                   FALSE
#>                                                                                                                                                             Interpretation
#> 1 Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision.
#> 2 Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision.
# }
```
