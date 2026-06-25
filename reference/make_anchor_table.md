# Build an anchor table from fitted estimates

Build an anchor table from fitted estimates

## Usage

``` r
make_anchor_table(fit, facets = NULL, include_person = FALSE, digits = 6)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- facets:

  Optional subset of facets to include.

- include_person:

  Include person estimates as anchors.

- digits:

  Rounding digits for anchor values.

## Value

A data.frame with `Facet`, `Level`, and `Anchor`.

## Details

This function exports estimated facet parameters as an anchor table for
use in subsequent calibrations. This is the standard approach for
**linking** across administrations: a reference run establishes the
measurement scale, and anchored re-analyses place new data on that same
scale.

Anchor values should be exported from a well-fitting reference run with
adequate sample size. If the reference model has convergence issues or
large misfit, the exported anchors may propagate instability. Re-run
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
on the receiving data to verify compatibility before estimation.

The `digits` parameter controls rounding precision. Use at least 4
digits for research applications; excessive rounding (e.g., 1 digit) can
introduce avoidable calibration error.

## Interpreting output

- `Facet`: facet name to be anchored in later runs.

- `Level`: specific element/level name inside that facet.

- `Anchor`: fixed logit value (rounded by `digits`).

## Typical workflow

1.  Fit a reference run with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Export anchors with `make_anchor_table(fit)`.

3.  Pass selected rows back into `fit_mfrm(..., anchors = ...)`.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
anchors_tbl <- make_anchor_table(fit)
head(anchors_tbl)
#> # A tibble: 6 × 3
#>   Facet     Level         Anchor
#>   <chr>     <chr>          <dbl>
#> 1 Criterion Accuracy      0.249 
#> 2 Criterion Content      -0.415 
#> 3 Criterion Language      0.0973
#> 4 Criterion Organization  0.0690
#> 5 Rater     R01          -0.196 
#> 6 Rater     R02          -0.329 
summary(anchors_tbl$Anchor)
#>     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#> -0.41510 -0.22901  0.08316  0.00000  0.20551  0.33355 
```
