# Convert mfrm_fit to a tidy data.frame

Returns all facet-level estimates (person and others) in a single tidy
data.frame. Person rows retain their original identifiers; review or
transform them before writing the result outside a controlled analysis
environment.

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
flag (`"Min"` / `"Max"` / `NA`); non-person facet rows carry `NA` in
that column by design.

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
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", model = "RSM",
                quad_points = 7, maxit = 30)
head(as.data.frame(fit))
#>    Facet Level    Estimate Extreme
#> 1 Person  P001  0.22371868    none
#> 2 Person  P002  0.71054603    none
#> 3 Person  P003  0.02517584    none
#> 4 Person  P004  0.14530707    none
#> 5 Person  P005 -0.06792434    none
#> 6 Person  P006  0.70720576    none
```
