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
                method = "JML", maxit = 30,
                facet_shrinkage = "empirical_bayes")
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
shrinkage_report(fit)
#>       Facet NLevels NLevelsUsed       Tau2     MeanSE2 MeanShrinkage
#> 1     Rater       4           4 0.06403506 0.009500135     0.1291914
#> 2 Criterion       4           4 0.05259214 0.009500604     0.1530053
#>   EffectiveDF          Method PriorSource Note
#> 1    3.483234 empirical_bayes   empirical <NA>
#> 2    3.387979 empirical_bayes   empirical <NA>
# }
```
