# FACETS-to-mfrmr term crosswalk

`facets_term_crosswalk()` maps common FACETS report and specification
terms to their closest `mfrmr` objects or routes. The relationship
column makes explicit whether a row is a substantive counterpart, a
presentation convention, or only a migration aid.

## Usage

``` r
facets_term_crosswalk()
```

## Value

A data.frame with `FACETSTerm`, `mfrmrTerm`, `mfrmrRoute`,
`Relationship`, and `Boundary` columns.

## See also

[`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md),
[`facets_feature_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_feature_coverage.md),
[`facets_visual_contract()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_visual_contract.md)

## Examples

``` r
facets_term_crosswalk()
#>                     FACETSTerm              mfrmrTerm
#> 1                      Measure      Estimate (logits)
#> 2                         S.E.                     SE
#> 3                   Infit MnSq                  Infit
#> 4                  Outfit MnSq                 Outfit
#> 5                         ZSTD InfitZSTD / OutfitZSTD
#> 6                Rating Scale= model = "RSM" or "PCM"
#> 7  Table 6 Wright/variable map             Wright map
#> 8                   Graphfile=     graph output table
#> 9                  Anchorfile=           anchor table
#> 10                   Positive=      facet orientation
#>                                                          mfrmrRoute
#> 1                                fit_measures_table(); summary(fit)
#> 2  fit_measures_table(); plot(fit, type = "wright", show_ci = TRUE)
#> 3                             diagnose_mfrm(); fit_measures_table()
#> 4                             diagnose_mfrm(); fit_measures_table()
#> 5  facets_fit_df_guide(); fit_measures_table(df_sensitivity = TRUE)
#> 6                                  fit_mfrm(model = "RSM" or "PCM")
#> 7                 plot_wright_unified(); plot(fit, type = "wright")
#> 8                      facets_output_file_bundle(include = "graph")
#> 9                      make_anchor_table(); fit_mfrm(anchors = ...)
#> 10           fit_mfrm(positive_facets = ...); plot_wright_unified()
#>                        Relationship
#> 1           substantive counterpart
#> 2           substantive counterpart
#> 3           substantive counterpart
#> 4           substantive counterpart
#> 5  convention-sensitive counterpart
#> 6           model-setting crosswalk
#> 7                visual counterpart
#> 8          handoff-file counterpart
#> 9           input-table counterpart
#> 10           orientation convention
#>                                                                                                      Boundary
#> 1  Numerical equality requires aligned model, estimator, identification, and supplied external FACETS output.
#> 2                                     SE bases differ by estimator and element type; inspect method metadata.
#> 3                                           Compare MnSq before standardized fit and document residual basis.
#> 4                                           Compare MnSq before standardized fit and document residual basis.
#> 5                                   df and Wilson-Hilferty conventions can change ZSTD without changing MnSq.
#> 6                The package exposes documented RSM/PCM and bounded-GPCM routes, not a FACETS command parser.
#> 7                FACETS-style rendering reproduces the ruler grammar, not optimizer-level numerical identity.
#> 8                                    CSV/TSV handoff is package-native rather than fixed-field FACETS syntax.
#> 9                         The table is an R-native anchor contract, not a complete FACETS specification file.
#> 10                                                   Always report which facets use the positive orientation.
```
