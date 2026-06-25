# FACETS Positioning Guide

`facets_positioning_guide()` gives user-facing wording for the
relationship between `mfrmr` and FACETS. Use it when a report, migration
note, or methods appendix must make clear that `mfrmr` is not a FACETS
numerical clone.

## Usage

``` r
facets_positioning_guide()
```

## Value

A data.frame with columns:

- `Topic`

- `Position`

- `RecommendedWording`

- `PrimaryRoute`

## Details

The guide separates four ideas that are easy to conflate:

- estimation authority: fitted values come from `mfrmr` unless external
  FACETS output is explicitly supplied;

- compatibility purpose: FACETS-style names and files are transition,
  handoff, and report-organization surfaces;

- external comparison: FACETS comparisons require a supplied external
  table and should separate MnSq differences from df/ZSTD convention
  differences;

- extension surface: native R tables, plot data, GPCM diagnostics,
  network views, and G/D-study helpers are package extensions, not
  promises of FACETS menu-level reproduction.

## See also

[`facets_feature_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_feature_coverage.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[`read_facets_fit_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_fit_table.md),
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)

## Examples

``` r
facets_positioning_guide()
#>                        Topic
#> 1       Estimation authority
#> 2      Compatibility purpose
#> 3 External FACETS comparison
#> 4  Reporting source of truth
#> 5    Extension beyond FACETS
#>                                                                                                                                 Position
#> 1                                    mfrmr estimates are package-native; FACETS-style names do not mean that FACETS estimated the model.
#> 2 FACETS-style wrappers, table labels, and files support transition, handoff, and report organization, not optimizer-level reproduction.
#> 3                                           Numerical comparison requires an explicit external FACETS output table supplied by the user.
#> 4                              Inference and reporting should be based on native fit, diagnostics, review, table, and plot-data objects.
#> 5                           GPCM, D-study, network, and reusable visualization data are extension routes rather than FACETS menu clones.
#>                                                                                                              RecommendedWording
#> 1                           The model was estimated with mfrmr; FACETS-style output names are used only to organize the report.
#> 2 FACETS-style outputs were generated for handoff or reader familiarity; they are not evidence of FACETS numerical equivalence.
#> 3             When external FACETS output is supplied, compare MnSq first and report df/ZSTD convention sensitivity separately.
#> 4                                    Report estimates, standard errors, fit summaries, and plots from documented mfrmr objects.
#> 5                                        Use package-native extensions as additional evidence and label them as mfrmr analyses.
#>                                                                                PrimaryRoute
#> 1                                        fit_mfrm(); diagnose_mfrm(); reporting_checklist()
#> 2                 facets_feature_coverage(); run_mfrm_facets(); facets_output_file_bundle()
#> 3   read_facets_fit_table(); facets_fit_review(); fit_measures_table(df_sensitivity = TRUE)
#> 4                       build_summary_table_bundle(); build_visual_summaries(); plot_data()
#> 5 gpcm_capability_matrix(); mfrm_d_study(); mfrm_network_analysis(); plot_data_components()
```
