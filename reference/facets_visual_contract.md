# FACETS-facing visual contract

`facets_visual_contract()` identifies the closest package route for
common FACETS visual surfaces and states what may—and may not—be claimed
from that visual correspondence. It distinguishes the FACETS-style
asterisk ruler from the native uncertainty-aware Wright map.

## Usage

``` r
facets_visual_contract()
```

## Value

A data.frame with visual surface, status, first route, editable data
route, and claim-boundary columns.

## See also

[`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
[`facets_term_crosswalk()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_term_crosswalk.md),
[`facets_feature_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_feature_coverage.md)

## Examples

``` r
facets_visual_contract()
#>                  FACETSVisualSurface                Status
#> 1      Table 6 asterisk Wright ruler    implemented_visual
#> 2 Native Wright map with uncertainty       mfrmr_extension
#> 3     Table 8 rating-scale structure           implemented
#> 4     Graphs: expected-score ICC/IRF           implemented
#> 5               Bond-Fox fit pathway implemented_extension
#> 6             DIF/bias visual review               partial
#> 7        Graphfile and R/Web handoff               partial
#>                                                                                 FirstMfrmrRoute
#> 1                                                 plot_wright_unified(fit, renderer = "facets")
#> 2                                 plot_wright_unified(fit, renderer = "native", show_ci = TRUE)
#> 3                                             rating_scale_table(); category_structure_report()
#> 4                                                                   plot(fit, type = "pathway")
#> 5 plot(fit, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, top_n_person = 12)
#> 6                                                                       plot_bias_interaction()
#> 7                                         facets_output_file_bundle(); plot_data(); as_ggplot()
#>                                             EditableDataRoute
#> 1        plot(..., draw = FALSE)$data$facets_style$ruler_rows
#> 2 plot(..., draw = FALSE); plot_data(component = "locations")
#> 3                           rating_scale_table(); plot_data()
#> 4                                 plot_data(type = "pathway")
#> 5                             plot_data(type = "fit_pathway")
#> 6                      plot_data(); bias_interaction_report()
#> 7         facets_output_file_bundle(); plot_data_components()
#>                                                                                                       ClaimBoundary
#> 1 FACETS-style visual grammar; numerical equivalence requires an external golden comparison under aligned settings.
#> 2                    The SE/CI display is an mfrmr extension and should be retained for uncertainty interpretation.
#> 3                                                         Structured R output replaces FACETS line-printer artwork.
#> 4                                          This is expected score over theta, not a measure-versus-fit pathway map.
#> 5                             This is a Bond-Fox-style mfrmr extension; it is not a standard FACETS Table 6 output.
#> 6                                                    Screening display only; it is not a final fairness conclusion.
#> 7                          Editable handoff is supported, but FACETS UI, Excel, and webpage behavior is not cloned.
```
