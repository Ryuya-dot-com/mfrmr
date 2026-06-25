# Build a linking-review synthesis object

Build a linking-review synthesis object

## Usage

``` r
build_linking_review(
  anchor_review = NULL,
  drift = NULL,
  chain = NULL,
  top_n = 10
)
```

## Arguments

- anchor_review:

  Optional output from
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

- drift:

  Optional output from
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md).

- chain:

  Optional output from
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md).

- top_n:

  Maximum number of linking-risk rows to highlight in summary outputs.
  The full object keeps the full risk tables.

## Value

An object of class `mfrm_linking_review`.

## Details

`build_linking_review()` does not recompute anchor, drift, or chain
statistics. It is a synthesis layer that organizes package-native
evidence into one operational review surface with:

- a front-door status block,

- ranked linking risks,

- explicit next actions,

- plot routing metadata,

- a reporting/export handoff map.

The helper keeps the current conservative interpretation policy: anchor
drift and screened links are operational review tools, not automatic
proofs of scale equivalence or score comparability.

## Recommended input route

Use existing package-native outputs in this order:

1.  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
    for pre-fit anchor adequacy.

2.  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
    for direct wave-to-reference drift screening.

3.  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
    for adjacent screened-link review across waves.

## Interpreting output

- `overview`: which evidence sources were supplied and the current
  review status.

- `top_linking_risks`: primary operational triage table.

- `group_view_index`: stable wave/link/facet/source-family grouping
  routes.

- `plot_map`: which existing plotting helper should be used next.

- `reporting_map`: what is covered here versus which manuscript-oriented
  helper should be used separately.

## GPCM boundary

This helper is currently intended for the validated `RSM` / `PCM`
linking workflow. If the supplied drift/chain sources resolve to bounded
`GPCM`, the helper stops with a package-level message rather than
silently implying support.

## See also

[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md),
[`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
if (FALSE) { # \dontrun{
d1 <- load_mfrmr_data("study1")
d2 <- load_mfrmr_data("study2")
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
anchor_review_obj <- review_mfrm_anchors(d1, "Person", c("Rater", "Criterion"), "Score")
drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))
chain <- build_equating_chain(list(Wave1 = fit1, Wave2 = fit2))
review <- build_linking_review(anchor_review = anchor_review_obj, drift = drift, chain = chain)
summary(review)
review$top_linking_risks
review$group_view_index
} # }
```
