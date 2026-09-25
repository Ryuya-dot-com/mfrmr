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
proofs of scale equivalence or score comparability. It also does not
verify source-fit readiness, cross-wave element identity, invariance, or
the external assumptions behind group anchors; these must be established
before promoting the synthesized review.

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

This helper is currently intended for the documented `RSM` / `PCM`
linking workflow. If the supplied drift/chain sources resolve to `GPCM`,
the helper stops with a package-level message rather than silently
implying support.

## See also

[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md),
[`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
# \donttest{
# Deliberately linked teaching waves: common labels below represent the
# same rater and criterion identities by construction.
toy <- load_mfrmr_data("example_core")
people <- unique(toy$Person)
# Two balanced 12-Person waves retain every Rater and Criterion.
d1 <- toy[toy$Person %in% people[1:12], , drop = FALSE]
d2 <- toy[toy$Person %in% people[13:24], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", quad_points = 7, maxit = 30)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", quad_points = 7, maxit = 30)
anchor_review_obj <- review_mfrm_anchors(d1, "Person", c("Rater", "Criterion"), "Score")
drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))
#> Warning: Thin linking support between 'Wave1' and 'Wave2': fewer than 5 retained common elements in Criterion, Rater.
chain <- build_equating_chain(list(Wave1 = fit1, Wave2 = fit2))
#> Warning: Thin linking support between 'Wave1' and 'Wave2': fewer than 5 retained common elements in Criterion, Rater.
review <- build_linking_review(anchor_review = anchor_review_obj, drift = drift, chain = chain)
summary(review)
#> mfrm Linking Review Summary
#>   Linking flags are review screens, not tests of anchor invariance.
#>   Source-parameter, estimated-offset and cross-fit covariance are not fully
#>   propagated. A sufficient element count alone does not establish a common
#>   scale.
#> 
#> Overview
#>  AnchorReviewAvailable DriftAvailable ChainAvailable SourceModels
#>                   TRUE           TRUE           TRUE          RSM
#> 
#> Key Warnings
#>  - Drift review flagged 2 wave/facet support or drift rows.
#>  - Chain review flagged 1 adjacent-link instability rows.
#> 
#> Next Actions
#>  - Inspect detect_anchor_drift() and plot_anchor_drift(drift, type = "drift")
#>    for wave-level follow-up.
#>  - Inspect build_equating_chain() and plot_anchor_drift(chain, type = "chain")
#>    before using cumulative offsets operationally.
#> 
#> Top Linking Risks
#>      Facet Level  Wave           Link
#>  Criterion  <NA> Wave2           <NA>
#>      Rater  <NA> Wave2           <NA>
#>       <NA>  <NA>  <NA> Wave1 -> Wave2
#>                                                          Signal Magnitude
#>  Retained common-element support is below the package guideline      1.00
#>  Retained common-element support is below the package guideline      1.00
#>              Thin retained support in an adjacent screened link      0.48
#>                                                                                         Guidance
#>              Treat drift flags as low-support until more retained common elements are available.
#>              Treat drift flags as low-support until more retained common elements are available.
#>  Inspect the adjacent link and cumulative offsets before using the chain for operational review.
#> 
#> Plot Follow-up
#>        ReviewArea Available                                 PlotHelper
#>   Anchor adequacy      TRUE plot(anchor_review, type = "issue_counts")
#>  Wave-level drift      TRUE   plot_anchor_drift(drift, type = "drift")
#>    Screened chain      TRUE   plot_anchor_drift(chain, type = "chain")
#>                                                                            Trigger
#>                            Use when anchor issues or overlap warnings are present.
#>  Use when fitted waves show flagged drift or thin retained common-element support.
#>                Use when adjacent links show thin support or large residual spread.
#>   Detailed risk values, grouped views and support information remain in the
#>   returned review tables.
#> 
#> Notes
#>  - Review anchor overlap, fitted-wave drift and adjacent-link residuals
#>    together before comparing results across administrations.
#>  - Drift or limited-overlap flags identify comparisons to investigate; they do
#>    not establish that the measurement scale has changed.
review$top_linking_risks
#> # A tibble: 3 × 20
#>   RiskID     Area  SourceFamily SourceTable SourceRowKey AdministrationID WaveID
#>   <chr>      <chr> <chr>        <chr>       <chr>        <chr>            <chr> 
#> 1 thin_link… post… thin_link_s… drift$comm… Criterion::… NA               Wave2 
#> 2 thin_link… post… thin_link_s… drift$comm… Rater::Wave2 NA               Wave2 
#> 3 chain_sup… chai… equating_ch… chain$links Wave1 -> Wa… NA               NA    
#> # ℹ 13 more variables: LinkKey <chr>, Facet <chr>, Level <chr>, Wave <chr>,
#> #   Link <chr>, Signal <chr>, Magnitude <dbl>, SeverityGroup <chr>,
#> #   ReviewPriority <dbl>, Guidance <chr>, PrimaryPlotRoute <chr>,
#> #   SupportStatus <chr>, RiskRank <int>
review$group_view_index
#> # A tibble: 4 × 3
#>   View              Rows Description                                          
#>   <chr>            <int> <chr>                                                
#> 1 by_wave              1 Concentrated linking risks by fitted wave.           
#> 2 by_link              1 Concentrated linking risks by adjacent screened link.
#> 3 by_facet             2 Concentrated linking risks by facet.                 
#> 4 by_source_family     2 Volume and priority by evidence source family.       
# }
```
