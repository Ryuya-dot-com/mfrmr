# Summarize a facet-quality dashboard

Summarize a facet-quality dashboard

## Usage

``` r
# S3 method for class 'mfrm_facet_dashboard'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of flagged levels to preview.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_facet_dashboard`.

## See also

[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md),
[`plot_facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_quality_dashboard.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
summary(facet_quality_dashboard(fit, diagnostics = diag))
}
```
