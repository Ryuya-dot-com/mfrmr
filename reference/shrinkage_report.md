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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30,
                facet_shrinkage = "empirical_bayes")
shrinkage_report(fit)
}
```
