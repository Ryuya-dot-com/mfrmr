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

# S3 method for class 'mfrm_linking_review'
summary(object, digits = 3, top_n = 10, ...)
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

  For `build_linking_review()`: Maximum number of linking-risk rows to
  highlight in summary outputs. The full object keeps the full risk
  tables.

  For [`summary()`](https://rdrr.io/r/base/summary.html): Number of top
  linking-risk rows to keep in the compact summary.

- object:

  Output from `build_linking_review()`.

- digits:

  Number of digits for printed numeric values.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `mfrm_linking_review`.

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_linking_review`.

## Details

Combine saved anchor, drift and chain results without recalculation.
Choose the inputs for the question:
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
checks receiving-data constraints,
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
compares waves with a reference, and
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
follows adjacent links. These are complementary sources, not a required
sequence.

The combined review does not verify source-fit readiness, cross-wave
identity, invariance or group-anchor assumptions, and cannot establish
scale equivalence or score comparability. Its documented scope is
RSM/PCM; GPCM drift/chain inputs remain exploratory with scope
`supported_with_caveat`.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize a
linking-review object

## Using the review

Read `overview` for supplied sources and status, then
`top_linking_risks` for ranked follow-up. `group_view_index` groups by
wave, link, facet or source family. `plot_map` routes to the source
plots; `reporting_map` identifies coverage and separate
manuscript-reporting helpers. Retain the original results when
inspecting risks or deciding next actions.

## Linking and DFF route map

|  |  |
|----|----|
| Question | Route |
| Do planned/observed assignments connect ratings? | [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md) (`design_connectivity`), [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md) |
| Which baseline locations can serve as anchors? | [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md), [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md) |
| How do I fit new data with baseline locations fixed? | [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md) |
| Have common elements shifted across waves? | [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md), [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md), `build_linking_review()` |
| Do facet levels differ between groups? | [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md) (`mfrm_report(x, type = "dff")`); see [`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md) and [`ordinal_logistic_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/ordinal_logistic_table.md) |

Keep four concepts distinct: **common ratings** (observed overlap),
**scale identification** (e.g., sum-to-zero centering), **direct
anchors** (`Facet`, `Level`, `Anchor` fixing internal logit
coordinates), and **group anchors** (`Facet`, `Level`, `Group`,
`GroupValue` fixing an unweighted arithmetic group mean). With
`centering_scope = "facet"` (default), centered facets sum to zero
across all levels including anchors/groups; `"remainder"` centers
unconstrained levels only; `"anchor_origin"` (additive RSM/PCM JML) lets
anchors replace centering on their facet when an active unanchored
`noncenter_facet` is selected.

[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
and
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
estimate one pooled offset per link (`Offset_SD` is residual spread
across retained elements, not an offset SE; `LinkSupportAdequate` is a
local 5-element count screen, not proof of invariance). Source-anchor
covariance is excluded unless explicitly requested via
`anchor_covariance` and `independent_anchors = TRUE` in
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
(intercept-only RSM/PCM anchor-origin MML).

## See also

[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md),
[plot(x)](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
mfrmr_linking_and_dff

`build_linking_review()`

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("build_linking_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Deliberately linked teaching waves: common labels below represent the
# same rater and criterion identities by construction.
toy <- load_mfrmr_data("example_core")
people <- unique(toy$Person)
# Two balanced 24-Person waves retain every Rater and Criterion.
d1 <- toy[toy$Person %in% people[1:24], , drop = FALSE]
d2 <- toy[toy$Person %in% people[25:48], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", quad_points = 7, maxit = 30)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", quad_points = 7, maxit = 30)
anchor_review_obj <- review_mfrm_anchors(d1, "Person", c("Rater", "Criterion"), "Score")
drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))
chain <- build_equating_chain(list(Wave1 = fit1, Wave2 = fit2))
review <- build_linking_review(anchor_review = anchor_review_obj, drift = drift, chain = chain)
summary(review)
review$top_linking_risks
review$group_view_index
} # }
```
