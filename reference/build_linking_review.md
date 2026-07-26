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

This helper is currently intended for the documented `RSM` / `PCM`
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
# \donttest{
# Deliberately linked teaching waves: common labels below represent the
# same rater and criterion identities by construction.
toy <- load_mfrmr_data("example_core")
people <- unique(toy$Person)
d1 <- toy[toy$Person %in% people[1:24], , drop = FALSE]
d2 <- toy[toy$Person %in% people[25:48], , drop = FALSE]
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
#> 
#> Overview
#>  AnchorReviewAvailable DriftAvailable ChainAvailable
#>                   TRUE           TRUE           TRUE
#>                  ReviewStatus TopRiskRows GroupViews SourceModels
#>  insufficient_anchor_evidence           3          4          RSM
#>            GPCMSupport
#>  supported_with_caveat
#> 
#> Status
#>              Item                        Value
#>    Overall status insufficient_anchor_evidence
#>  Evidence sources  anchor_review, drift, chain
#>      Bounded GPCM        supported_with_caveat
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
#>                        RiskID                   Area           SourceFamily
#>    thin_link:Criterion::Wave2 post_fit_element_drift      thin_link_support
#>        thin_link:Rater::Wave2 post_fit_element_drift      thin_link_support
#>  chain_support:Wave1 -> Wave2  chain_level_stability equating_chain_support
#>            SourceTable     SourceRowKey AdministrationID WaveID        LinkKey
#>  drift$common_by_facet Criterion::Wave2             <NA>  Wave2           <NA>
#>  drift$common_by_facet     Rater::Wave2             <NA>  Wave2           <NA>
#>            chain$links   Wave1 -> Wave2             <NA>   <NA> Wave1 -> Wave2
#>      Facet Level  Wave           Link
#>  Criterion  <NA> Wave2           <NA>
#>      Rater  <NA> Wave2           <NA>
#>       <NA>  <NA>  <NA> Wave1 -> Wave2
#>                                                          Signal Magnitude
#>  Retained common-element support is below the package guideline     1.000
#>  Retained common-element support is below the package guideline     1.000
#>              Thin retained support in an adjacent screened link     0.187
#>  SeverityGroup ReviewPriority
#>           high              1
#>           high              1
#>           high              1
#>                                                                                         Guidance
#>              Treat drift flags as low-support until more retained common elements are available.
#>              Treat drift flags as low-support until more retained common elements are available.
#>  Inspect the adjacent link and cumulative offsets before using the chain for operational review.
#>                          PrimaryPlotRoute SupportStatus RiskRank
#>  plot_anchor_drift(drift, type = "drift")     supported        1
#>  plot_anchor_drift(drift, type = "drift")     supported        2
#>  plot_anchor_drift(chain, type = "chain")     supported        3
#> 
#> Grouping Views
#>              View Rows                                           Description
#>           by_wave    1            Concentrated linking risks by fitted wave.
#>           by_link    1 Concentrated linking risks by adjacent screened link.
#>          by_facet    2                  Concentrated linking risks by facet.
#>  by_source_family    2        Volume and priority by evidence source family.
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
#> 
#> Support Status
#>         Scope                Status
#>     RSM / PCM             supported
#>  bounded GPCM supported_with_caveat
#>                                                                                                      Note
#>          Supported as a synthesis layer over documented anchor-review, drift, and equating-chain objects.
#>  Supported with caveat when bounded GPCM source objects are supplied; not active for this RSM/PCM review.
#> 
#> Notes
#>  - Linking review is an operational synthesis layer over existing
#>    package-native anchor, drift, and chain evidence.
#>  - Drift or thin-support warnings do not prove scale breakdown by themselves;
#>    they indicate where review is needed.
#>  - Repeated signals across anchor, drift, and chain evidence deserve priority,
#>    but this helper does not collapse them into one opaque composite score.
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
