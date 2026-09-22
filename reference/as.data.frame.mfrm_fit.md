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
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Extract estimates and select the rows to display
estimates <- as.data.frame(fit)
head(subset(estimates, Facet == "Person")) # First six persons
#>    Facet Level    Estimate Extreme
#> 1 Person  P001  0.28429588    none
#> 2 Person  P002  0.66118004    none
#> 3 Person  P003  0.02177773    none
#> 4 Person  P004  0.22410785    none
#> 5 Person  P005 -0.17496065    none
#> 6 Person  P006  0.67681003    none
subset(estimates, Facet == "Rater")       # All raters
#>    Facet Level   Estimate Extreme
#> 49 Rater   R01 -0.6059776    <NA>
#> 50 Rater   R02 -0.3820356    <NA>
#> 51 Rater   R03  0.2120388    <NA>
#> 52 Rater   R04  0.1799462    <NA>
#> 53 Rater   R05  0.1842365    <NA>
#> 54 Rater   R06  0.4117917    <NA>
subset(estimates, Facet == "Criterion")   # All criteria
#>        Facet        Level   Estimate Extreme
#> 55 Criterion      Content -0.3441471    <NA>
#> 56 Criterion     Language  0.1204520    <NA>
#> 57 Criterion Organization  0.2236950    <NA>
# }
```
