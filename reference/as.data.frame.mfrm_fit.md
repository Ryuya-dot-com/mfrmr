# Convert mfrm_fit to a tidy data.frame

Returns all facet-level estimates (person and others) in a single tidy
data.frame. Useful for quick interactive export:
`write.csv(as.data.frame(fit), "results.csv")`.

## Usage

``` r
# S3 method for class 'mfrm_fit'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  An `mfrm_fit` object from
  [`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- row.names:

  Ignored (included for S3 generic compatibility).

- optional:

  Ignored (included for S3 generic compatibility).

- ...:

  Additional arguments (ignored).

## Value

A data.frame with columns `Facet`, `Level`, `Estimate`, and `Extreme`.
The `Extreme` column is populated for person rows from the extreme-score
flag added in 0.1.6 (`"Min"` / `"Max"` / `NA`); non-person facet rows
carry `NA` in that column by design.

## Details

This method returns four columns (`Facet`, `Level`, `Estimate`,
`Extreme`) so that the result is easy to inspect, join, or write to
disk.

## Interpreting output

Person estimates are returned with `Facet = "Person"`. All non-person
facets are stacked underneath in the same schema.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Convert with `as.data.frame(fit)` for a compact long-format export.

3.  Join additional diagnostics later if you need SE or fit statistics.

## See also

[`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`export_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", model = "RSM", maxit = 30)
head(as.data.frame(fit))
#>       Facet Level   Estimate Extreme
#> P001 Person  P001  0.6857247    none
#> P002 Person  P002  1.6727706    none
#> P003 Person  P003  1.2575190    none
#> P004 Person  P004  0.9010429    none
#> P005 Person  P005  0.9010429    none
#> P006 Person  P006 -1.5244704    none
```
