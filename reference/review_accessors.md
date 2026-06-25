# Extract canonical review components

Extract canonical review components

## Usage

``` r
anchor_review(x, required = TRUE)

precision_review(x, required = TRUE)
```

## Arguments

- x:

  A fitted `mfrm_fit`, diagnostics object, summary object, or compatible
  list containing the requested review component.

- required:

  Logical. If `TRUE`, error when no compatible review component is
  found. If `FALSE`, return `NULL` instead.

## Value

`anchor_review()` returns an `mfrm_anchor_review`-like object when
available. `precision_review()` returns the precision-review table when
available. If `required = FALSE` and no component is available, both
helpers return `NULL`.

## Details

`anchor_review()` returns the fitted object's `config$anchor_review`
component. `precision_review()` returns the diagnostics
`precision_review` table. These helpers intentionally do not search
older field names.

## Examples

``` r
fit_like <- list(config = list(
  anchor_review = structure(list(issue_counts = data.frame()),
                            class = "mfrm_anchor_review")
))
anchor_review(fit_like)
#> mfrm anchor review
#>   issue rows: 0
diag_like <- list(
  precision_review = data.frame(Check = "SE", Status = "ok", Detail = "Model-based")
)
precision_review(diag_like)
#>   Check Status      Detail
#> 1    SE     ok Model-based
```
