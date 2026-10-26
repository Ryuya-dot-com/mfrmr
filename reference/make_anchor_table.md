# Build a candidate direct-anchor table from fitted estimates

Build a candidate direct-anchor table from fitted estimates

## Usage

``` r
make_anchor_table(
  fit,
  facets = NULL,
  include_person = FALSE,
  digits = NULL,
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
  substantively justified. Fixed Person values are supported only by a
  receiving JML fit; MML rejects Person anchors.

- digits:

  `NULL` (default) preserves the fitted numeric values. A nonnegative
  integer explicitly rounds them for display or external use.

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
anchor set. `Anchor` uses the internal, untransformed location metric.
The table does not include category thresholds, GPCM slopes, model
settings or source SEs; it is not a complete saved calibration. See
[`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
for that separate workflow. Fixing an estimated value does not propagate
its source uncertainty into the new fit.

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

Keep `digits = NULL` for recalibration. Rounding individual anchors can
break their joint sum or group-mean constraint, even at six decimal
places. Explicitly rounded values are different constraints and must be
reviewed before reuse; the fitter does not silently recenter supplied
anchors.

## Interpreting output

- `Facet`: facet name to be anchored in later runs.

- `Level`: specific element/level name inside that facet.

- `Anchor`: fixed logit value (rounded only when `digits` is supplied).

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
ratings <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  ratings, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", rating_min = 1, rating_max = 4,
  category_policy = "preserve"
)
# Select a facet deliberately; matching labels alone do not prove invariance.
anchors_tbl <- make_anchor_table(fit, facets = "Rater")
anchors_tbl
#> # A tibble: 6 × 3
#>   Facet Level Anchor
#>   <chr> <chr>  <dbl>
#> 1 Rater R01   -0.606
#> 2 Rater R02   -0.382
#> 3 Rater R03    0.212
#> 4 Rater R04    0.180
#> 5 Rater R05    0.184
#> 6 Rater R06    0.412
```
