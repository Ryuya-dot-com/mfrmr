# Build a candidate direct-anchor table from fitted estimates

Build a candidate direct-anchor table from fitted estimates

## Usage

``` r
make_anchor_table(
  fit,
  facets = NULL,
  include_person = FALSE,
  digits = 6,
  readiness_policy = c("error", "review")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- facets:

  Optional subset of facets to include.

- include_person:

  Include person estimates as candidate anchors. Use only when cross-run
  person identity and the intended longitudinal constraint are
  substantively justified.

- digits:

  Rounding digits for anchor values.

- readiness_policy:

  How a source fit that is not inference-ready is handled. `"error"`
  (default) refuses anchor export or reuse. `"review"` permits explicit
  review-only extraction; those values must not be used as operational
  anchors.

## Value

A data.frame with `Facet`, `Level`, and `Anchor`.

## Details

This function performs a mechanical conversion from fitted estimates to
the `Facet`/`Level`/`Anchor` schema accepted by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
The returned rows are candidate direct constraints, not an approved
anchor set.

By default, the function refuses export when the source fit is not
inference-ready under the current readiness contract. Set
`readiness_policy = "review"` only to inspect candidate values; this
does not make them eligible for reuse. The function cannot verify
cross-run element identity or invariance. Before reuse, document why
selected elements retain the same meaning, check the observed design's
connectedness, and run
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
on the receiving data. That review checks schema and receiving-data
support; it does not validate the source fit or the substantive
invariance assumption.

The `digits` parameter controls rounding precision. Use at least 4
digits for research applications; excessive rounding (e.g., 1 digit) can
introduce avoidable calibration error.

## Interpreting output

- `Facet`: facet name to be anchored in later runs.

- `Level`: specific element/level name inside that facet.

- `Anchor`: fixed logit value (rounded by `digits`).

## Typical workflow

1.  Fit and diagnose a defensible reference run with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Confirm source readiness, element identity, and the intended link.

3.  Export candidates with `make_anchor_table(fit)` and review them.

4.  Pass selected rows back into `fit_mfrm(..., anchors = ...)`.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)

## Examples

``` r
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 7, maxit = 30
)
anchors_tbl <- make_anchor_table(fit)
head(anchors_tbl)
#> # A tibble: 6 × 3
#>   Facet     Level        Anchor
#>   <chr>     <chr>         <dbl>
#> 1 Criterion Content      -0.339
#> 2 Criterion Language      0.118
#> 3 Criterion Organization  0.221
#> 4 Rater     R01          -0.597
#> 5 Rater     R02          -0.334
#> 6 Rater     R03           0.259
summary(anchors_tbl$Anchor)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#> -0.5968 -0.3339  0.1349  0.0000  0.2207  0.3678 
```
