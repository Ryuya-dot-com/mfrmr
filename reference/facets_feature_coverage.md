# FACETS Feature Coverage Matrix

`facets_feature_coverage()` summarizes how `mfrmr` maps the main FACETS
output-table, output-file, and graph-menu surface to package functions.
It is a surface-coverage guide, not a statement that estimands,
conditioning, extreme-score handling, degrees of freedom, or numerical
results are equivalent.

Use this helper before migration work when you need a public,
user-facing answer to three questions:

- which FACETS outputs have a close `mfrmr` route,

- which outputs are only partially covered by structured R objects,

- which FACETS-specific outputs are not implemented or intentionally
  outside the current package scope.

## Usage

``` r
facets_feature_coverage(
  status = c("all", "implemented", "supported_with_caveat", "partial", "not_implemented",
    "not_targeted")
)
```

## Arguments

- status:

  Which rows to return. `"all"` returns the full matrix. Other values
  filter by the `Status` column.

## Value

A data.frame with columns:

- `FACETSArea`

- `FACETSFeature`

- `FACETSReference`

- `mfrmrRoute`

- `Status`

- `SurfaceCoverage`

- `StatisticalContract`

- `ValidationEvidence`

- `OperationalStatus`

- `Capability`

- `Limitation`

- `Alternative`

## Details

The matrix is based on the FACETS 64-bit output index, which lists
output Tables 1–14, DIF/bias plots, R/Web plots, output files, and
graph-menu curves. `mfrmr` intentionally prioritizes structured R tables
and reusable plot data over exact FACETS line-printer output.

The current software reference target is FACETS 64-bit 4.5.1 (July
2026). Bibliographic references retain the title and edition of the
consulted manual rather than silently relabelling a 4.5.0 manual as
4.5.1. External numerical validation is a separate evidence contract.

Status meanings:

- `implemented`: a package-native route covers the substantive output
  surface; this status alone does not claim an externally matched
  statistical contract.

- `supported_with_caveat`: a package-native route exists, but the output
  must be read with explicit identification, validation, or scope
  caveats.

- `partial`: the concept is covered, but not the full FACETS formatting,
  option surface, file type, or external integration.

- `not_implemented`: a FACETS feature has no direct package-native route
  in the documented package scope.

- `not_targeted`: the feature is tied to FACETS UI, Web/Excel handoff,
  or another external program format and is outside the package scope.

The four contract axes are deliberately independent:

- `SurfaceCoverage` records whether a corresponding package surface
  exists; familiar visual grammar belongs only to this axis.

- `StatisticalContract` records the package-native statistical scope and
  never implies a FACETS-matched estimand.

- `ValidationEvidence` records whether this table establishes matched
  external numerical evidence. It currently does not; validation belongs
  to a separate candidate-linked evidence contract.

- `OperationalStatus` records route availability. A package route being
  available does not make `mfrmr` operationally interchangeable with
  FACETS.

## References

Linacre, J. M. (2026). *A user's guide to FACETS, version 4.5.0*.
Current FACETS software release: <https://www.winsteps.com/facets.htm>.
Output tables - files - plots - graphs:
<https://www.winsteps.com/facetman64/outputtableindex.htm>.

## See also

[`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[`facets_fit_df_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_df_guide.md),
[`read_facets_fit_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_fit_table.md),
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md),
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)

## Examples

``` r
facets_feature_coverage()
#>                FACETSArea
#> 1            Output table
#> 2            Output table
#> 3            Output table
#> 4            Output table
#> 5            Output table
#> 6            Output table
#> 7            Output table
#> 8            Output table
#> 9            Output table
#> 10           Output table
#> 11           Output table
#> 12           Output table
#> 13           Output table
#> 14           Output table
#> 15           Output table
#> 16           Output table
#> 17           Output table
#> 18           Output table
#> 19           Output table
#> 20           Output table
#> 21           Output table
#> 22           Output table
#> 23            R/Web plots
#> 24            R/Web plots
#> 25            R/Web plots
#> 26            R/Web plots
#> 27            R/Web plots
#> 28            R/Web plots
#> 29            R/Web plots
#> 30            Output file
#> 31            Output file
#> 32            Output file
#> 33            Output file
#> 34            Output file
#> 35            Output file
#> 36            Output file
#> 37            Output file
#> 38            Output file
#> 39             Graph menu
#> 40             Graph menu
#> 41             Graph menu
#> 42             Graph menu
#> 43             Graph menu
#> 44             Graph menu
#> 45 Specification/workflow
#> 46 Specification/workflow
#> 47 Specification/workflow
#> 48 Current scope boundary
#> 49 Current scope boundary
#> 50 Current scope boundary
#> 51 Current scope boundary
#> 52 Current scope boundary
#> 53  Observation weighting
#> 54 Current scope boundary
#> 55 Current scope boundary
#> 56 Current scope boundary
#>                                                       FACETSFeature
#> 1                                    Table 1: specification summary
#> 2                                      Table 2: data summary report
#> 3                                    Table 3: main iteration report
#> 4                                     Table 4: unexpected responses
#> 5                                  Table 5: measurable data summary
#> 6                            Table 6.0: all-facet Wright map rulers
#> 7                             Table 6.0.0: disjoint element listing
#> 8                             Table 6.2: graphical facet statistics
#> 9                                 Table 7: facet measurement report
#> 10                              Table 7: reliability and chi-square
#> 11                                    Table 7: agreement statistics
#> 12               Table 8.1: dichotomous/binomial/Poisson statistics
#> 13     Table 8.1: polytomous rating-scale/partial-credit statistics
#> 14                               Table 8: scale-structure bar chart
#> 15                      Table 8: scale-structure probability curves
#> 16                        Table 9: bias-estimation iteration report
#> 17                     Table 10: unexpected after allowing for bias
#> 18                                Table 11: bias-calculation counts
#> 19                                    Table 12: bias summary report
#> 20                                 Table 13: DIF/bias detail report
#> 21                                   Table 14: pairwise bias report
#> 22                                              DIF/bias Excel plot
#> 23                    Scatterplots and histograms from FACETS menus
#> 24                                           X-Y plot: R Statistics
#> 25                                                X-Y plot: Webpage
#> 26                                         X-Y-Z plot: R Statistics
#> 27                                          Histogram: R Statistics
#> 28                    Generalizability Theory via R package gtheory
#> 29                            Connectivity network graph via igraph
#> 30                                      Specification settings file
#> 31                                               Anchor output file
#> 32                                              Graph plotting file
#> 33                                               Output report file
#> 34                                            Residuals output file
#> 35                                                Score output file
#> 36                                              Simulated data file
#> 37                                         Subset group-anchor file
#> 38                                   Winsteps control and data file
#> 39                                      Category probability curves
#> 40                                           Expected score ICC/IRF
#> 41                                    Cumulative probability curves
#> 42                                        Test information function
#> 43                                    Category information function
#> 44                                   Conditional probability curves
#> 45            Full FACETS command-file parser and UI option surface
#> 46                       Exact FACETS line-printer report emulation
#> 47                                    Raw FACETS report-text import
#> 48      Versioned frozen-calibration import and operational scoring
#> 49      General threshold or step anchors and starting-value import
#> 50                  Multiple observed scales and scale-specific PCM
#> 51                              Nominal/multinomial response models
#> 52                 Binomial-trial and Poisson/count response models
#> 53                        Row-frequency weights for ordered ratings
#> 54 Native multidimensional estimation and dimension-specific scores
#> 55                                                Unrestricted GPCM
#> 56                     FACETS free-slope polytomous GPCM comparison
#>                  FACETSReference
#> 1                     table1.htm
#> 2                     table2.htm
#> 3                     table3.htm
#> 4                     table4.htm
#> 5                     table5.htm
#> 6                     table6.htm
#> 7                 table6_0_0.htm
#> 8                   table6_2.htm
#> 9                     table7.htm
#> 10   table7summarystatistics.htm
#> 11 table7agreementstatistics.htm
#> 12       table8_1dichotomous.htm
#> 13       table8_1ratingscale.htm
#> 14            table8barchart.htm
#> 15              table8curves.htm
#> 16                    table9.htm
#> 17                   table10.htm
#> 18                   table11.htm
#> 19                   table12.htm
#> 20                   table13.htm
#> 21                   table14.htm
#> 22               difbiasplot.htm
#> 23          outputtableindex.htm
#> 24                   xyplotr.htm
#> 25             xyplotwebpage.htm
#> 26                  xyzplotr.htm
#> 27                histogramr.htm
#> 28                   gtheory.htm
#> 29              networkgraph.htm
#> 30         specificationfile.htm
#> 31                anchorfile.htm
#> 32           graphoutputfile.htm
#> 33                outputfile.htm
#> 34              residualfile.htm
#> 35                 scorefile.htm
#> 36             simulatedfile.htm
#> 37                subsetfile.htm
#> 38              winstepsfile.htm
#> 39                    graphs.htm
#> 40                    graphs.htm
#> 41                    graphs.htm
#> 42                    graphs.htm
#> 43                    graphs.htm
#> 44                    graphs.htm
#> 45                     index.htm
#> 46          outputtableindex.htm
#> 47          outputtableindex.htm
#> 48   mfrmr 0.2.3 public contract
#> 49   mfrmr 0.2.3 public contract
#> 50   mfrmr 0.2.3 public contract
#> 51   mfrmr 0.2.3 public contract
#> 52                    models.htm
#> 53   mfrmr 0.2.3 weight contract
#> 54   mfrmr 0.2.3 public contract
#> 55   mfrmr 0.2.3 public contract
#> 56                    t7menu.htm
#>                                                                                                                                     mfrmrRoute
#> 1                                                                                                                      specifications_report()
#> 2                                                                                                  data_quality_report(); describe_mfrm_data()
#> 3                                                                                                                estimation_iteration_report()
#> 4                                                                                               unexpected_response_table(); plot_unexpected()
#> 5                                                                                             measurable_summary_table(); describe_mfrm_data()
#> 6                                                                         plot_wright_unified(renderer = "facets"); plot(fit, type = "wright")
#> 7                                                                                                                 subset_connectivity_report()
#> 8                                                                                                         facet_statistics_report(); plot(...)
#> 9                                                                                          fit_measures_table(); diagnose_mfrm(); summary(fit)
#> 10                                                                                           facets_chisq_table(); diagnose_mfrm()$reliability
#> 11                          interrater_agreement_table(); rater_network_analysis(); rater_halo_network_analysis(); plot_interrater_agreement()
#> 12                                                                                        rating_scale_table() for two-category ordered scores
#> 13                                                                                           rating_scale_table(); category_structure_report()
#> 14                                                                                                                 category_structure_report()
#> 15                                                                                           category_curves_report(); plot(fit, type = "ccc")
#> 16                                                                                                    estimate_bias(); bias_iteration_report()
#> 17                                                                                                               unexpected_after_bias_table()
#> 18                                                                                                                          bias_count_table()
#> 19                                                                                        summary(estimate_bias(...)); plot_bias_interaction()
#> 20                                                                                                  estimate_bias(); bias_interaction_report()
#> 21                                                                                               bias_pairwise_report(); build_fixed_reports()
#> 22                                                                                                           plot_bias_interaction(plot = ...)
#> 23                                                                                                           plot_data(); package plot helpers
#> 24                                                                                                        plot_data(); user-defined R plotting
#> 25                                                                                                                                        none
#> 26                                                                                                plot(fit, type = "ccc_surface"); plot_data()
#> 27                                                                                plot_data(); plot(fit, type = "wright"); plot_qc_dashboard()
#> 28                                                                                mfrm_generalizability(); mfrm_d_study(); compute_facet_icc()
#> 29 subset_connectivity_report(); mfrm_network_analysis(); rater_network_analysis(); rater_halo_network_analysis(); plot(..., type = "network")
#> 30                                                                                           build_mfrm_manifest(); build_mfrm_replay_script()
#> 31                                                                                make_anchor_table(); export_mfrm_bundle(include = "anchors")
#> 32                                                                                                facets_output_file_bundle(include = "graph")
#> 33                                                                                            export_summary_appendix(); build_fixed_reports()
#> 34                                             write_mfrm_residual_file(); diagnose_mfrm(); unexpected_response_table(); residual plot helpers
#> 35                                                                       facets_output_file_bundle(include = "score"); read_facets_fit_table()
#> 36                                                                                                 simulate_mfrm_data(); build_mfrm_sim_spec()
#> 37                                                         write_mfrm_subset_file(); group_anchors; review_mfrm_anchors(); make_anchor_table()
#> 38                                                                                                                                        none
#> 39                                                                                           category_curves_report(); plot(fit, type = "ccc")
#> 40                                                                                       plot(fit, type = "pathway"); category_curves_report()
#> 41                                                                                    category_curves_report(); plot(..., type = "cumulative")
#> 42                                                                                       compute_information(); plot_information(type = "tif")
#> 43                   category_curves_report(); plot(..., type = "category_information"); compute_information(); plot_information(type = "iif")
#> 44                                                                                                                    category_curves_report()
#> 45                                                                                                               run_mfrm_facets(); fit_mfrm()
#> 46                                                                                                   build_fixed_reports() for selected tables
#> 47                                                                            read_facets_fit_table() for delimited/fixed-field score extracts
#> 48                                                                                                                               none in 0.2.3
#> 49                                                                                                                               none in 0.2.3
#> 50                                                                                                                               none in 0.2.3
#> 51                                                                                                                               none in 0.2.3
#> 52                                                                                                                               none in 0.2.3
#> 53                                                                                                                      fit_mfrm(weight = ...)
#> 54                                                                                                                               none in 0.2.3
#> 55                                                                                                         none for unrestricted GPCM in 0.2.3
#> 56                                                                                                       none as a direct common-estimand lane
#>                   Status                   SurfaceCoverage
#> 1            implemented                         available
#> 2            implemented                         available
#> 3                partial                           partial
#> 4            implemented                         available
#> 5            implemented                         available
#> 6            implemented familiar_visual_grammar_available
#> 7            implemented                         available
#> 8                partial                           partial
#> 9  supported_with_caveat             available_with_caveat
#> 10 supported_with_caveat             available_with_caveat
#> 11 supported_with_caveat             available_with_caveat
#> 12               partial                           partial
#> 13 supported_with_caveat             available_with_caveat
#> 14               partial                           partial
#> 15           implemented                         available
#> 16           implemented                         available
#> 17           implemented                         available
#> 18           implemented                         available
#> 19               partial                           partial
#> 20           implemented                         available
#> 21           implemented                         available
#> 22               partial                           partial
#> 23               partial                           partial
#> 24               partial                           partial
#> 25          not_targeted                      out_of_scope
#> 26               partial                           partial
#> 27               partial                           partial
#> 28 supported_with_caveat             available_with_caveat
#> 29           implemented                         available
#> 30               partial                           partial
#> 31           implemented                         available
#> 32           implemented                         available
#> 33               partial                           partial
#> 34           implemented                         available
#> 35               partial                           partial
#> 36               partial                           partial
#> 37               partial                           partial
#> 38       not_implemented                       unavailable
#> 39           implemented                         available
#> 40           implemented                         available
#> 41           implemented                         available
#> 42           implemented                         available
#> 43           implemented                         available
#> 44               partial                           partial
#> 45          not_targeted                      out_of_scope
#> 46          not_targeted                      out_of_scope
#> 47               partial                           partial
#> 48       not_implemented                       unavailable
#> 49       not_implemented                       unavailable
#> 50       not_implemented                       unavailable
#> 51       not_implemented                       unavailable
#> 52       not_implemented                       unavailable
#> 53 supported_with_caveat             available_with_caveat
#> 54       not_implemented                       unavailable
#> 55       not_implemented                       unavailable
#> 56       not_implemented                       unavailable
#>                     StatisticalContract             ValidationEvidence
#> 1  package_native_not_facets_equivalent external_match_not_established
#> 2  package_native_not_facets_equivalent external_match_not_established
#> 3       partial_package_native_contract external_match_not_established
#> 4  package_native_not_facets_equivalent external_match_not_established
#> 5  package_native_not_facets_equivalent external_match_not_established
#> 6  package_native_not_facets_equivalent external_match_not_established
#> 7  package_native_not_facets_equivalent external_match_not_established
#> 8       partial_package_native_contract external_match_not_established
#> 9               package_native_caveated external_match_not_established
#> 10              package_native_caveated external_match_not_established
#> 11              package_native_caveated external_match_not_established
#> 12      partial_package_native_contract external_match_not_established
#> 13              package_native_caveated external_match_not_established
#> 14      partial_package_native_contract external_match_not_established
#> 15 package_native_not_facets_equivalent external_match_not_established
#> 16 package_native_not_facets_equivalent external_match_not_established
#> 17 package_native_not_facets_equivalent external_match_not_established
#> 18 package_native_not_facets_equivalent external_match_not_established
#> 19      partial_package_native_contract external_match_not_established
#> 20 package_native_not_facets_equivalent external_match_not_established
#> 21 package_native_not_facets_equivalent external_match_not_established
#> 22      partial_package_native_contract external_match_not_established
#> 23      partial_package_native_contract external_match_not_established
#> 24      partial_package_native_contract external_match_not_established
#> 25                       not_applicable                 not_applicable
#> 26      partial_package_native_contract external_match_not_established
#> 27      partial_package_native_contract external_match_not_established
#> 28              package_native_caveated external_match_not_established
#> 29 package_native_not_facets_equivalent external_match_not_established
#> 30      partial_package_native_contract external_match_not_established
#> 31 package_native_not_facets_equivalent external_match_not_established
#> 32 package_native_not_facets_equivalent external_match_not_established
#> 33      partial_package_native_contract external_match_not_established
#> 34 package_native_not_facets_equivalent external_match_not_established
#> 35      partial_package_native_contract external_match_not_established
#> 36      partial_package_native_contract external_match_not_established
#> 37      partial_package_native_contract external_match_not_established
#> 38                        not_available                 not_applicable
#> 39 package_native_not_facets_equivalent external_match_not_established
#> 40 package_native_not_facets_equivalent external_match_not_established
#> 41 package_native_not_facets_equivalent external_match_not_established
#> 42 package_native_not_facets_equivalent external_match_not_established
#> 43 package_native_not_facets_equivalent external_match_not_established
#> 44      partial_package_native_contract external_match_not_established
#> 45                       not_applicable                 not_applicable
#> 46                       not_applicable                 not_applicable
#> 47      partial_package_native_contract external_match_not_established
#> 48                        not_available                 not_applicable
#> 49                        not_available                 not_applicable
#> 50                        not_available                 not_applicable
#> 51                        not_available                 not_applicable
#> 52                        not_available                 not_applicable
#> 53              package_native_caveated external_match_not_established
#> 54                        not_available                 not_applicable
#> 55                        not_available                 not_applicable
#> 56                        not_available                 not_applicable
#>                  OperationalStatus
#> 1          package_route_available
#> 2          package_route_available
#> 3            partial_workflow_only
#> 4          package_route_available
#> 5          package_route_available
#> 6          package_route_available
#> 7          package_route_available
#> 8            partial_workflow_only
#> 9  available_with_mandatory_caveat
#> 10 available_with_mandatory_caveat
#> 11 available_with_mandatory_caveat
#> 12           partial_workflow_only
#> 13 available_with_mandatory_caveat
#> 14           partial_workflow_only
#> 15         package_route_available
#> 16         package_route_available
#> 17         package_route_available
#> 18         package_route_available
#> 19           partial_workflow_only
#> 20         package_route_available
#> 21         package_route_available
#> 22           partial_workflow_only
#> 23           partial_workflow_only
#> 24           partial_workflow_only
#> 25                   external_only
#> 26           partial_workflow_only
#> 27           partial_workflow_only
#> 28 available_with_mandatory_caveat
#> 29         package_route_available
#> 30           partial_workflow_only
#> 31         package_route_available
#> 32         package_route_available
#> 33           partial_workflow_only
#> 34         package_route_available
#> 35           partial_workflow_only
#> 36           partial_workflow_only
#> 37           partial_workflow_only
#> 38                         blocked
#> 39         package_route_available
#> 40         package_route_available
#> 41         package_route_available
#> 42         package_route_available
#> 43         package_route_available
#> 44           partial_workflow_only
#> 45                   external_only
#> 46                   external_only
#> 47           partial_workflow_only
#> 48                         blocked
#> 49                         blocked
#> 50                         blocked
#> 51                         blocked
#> 52                         blocked
#> 53 available_with_mandatory_caveat
#> 54                         blocked
#> 55                         blocked
#> 56                         blocked
#>                                                                                                                                                                 Capability
#> 1                                                                                                                     Structured run settings and reproducibility context.
#> 2                                                                                                   Rows, exclusions, missingness, score support, and response-pattern QC.
#> 3                                                                                                                             Convergence and replayed iteration evidence.
#> 4                                                                                                                                Case-level unexpected-response screening.
#> 5                                                                                                         Facet coverage, category counts, and subset/connectivity checks.
#> 6                                                                  Common-logit person/facet/threshold display with FACETS-style asterisk ruler or native SE/CI rendering.
#> 7                                                                                                                       Disconnected subsets and facet-by-subset coverage.
#> 8                                                                                                                                   Facet statistics and visual summaries.
#> 9                                                                                                                  Measures, SEs, fit, anchoring status, and review flags.
#> 10                                                                                                   Rasch/FACETS-style separation, reliability, and chi-square summaries.
#> 11      Raw-category observed agreement and model-probability expected agreement, plus pairwise rater-network, rater-by-criterion halo network, and rater-agreement views.
#> 12                                                                                                                    Two-category Rasch-category summaries are available.
#> 13                                          Core category diagnostics and thresholds for one RSM scale or one PCM step facet on the package's shared observed score scale.
#> 14                                                                                                                            Category structure and transition summaries.
#> 15                                                                                                                     Category probability and expected-score curve data.
#> 16                                                                                                                     Bias recalibration path and final iteration status.
#> 17                                                                                                                 Unexpected rows after the current bias-screening layer.
#> 18                                                                                                                                  Response counts behind bias estimates.
#> 19                                                                                                                 Distributional and visual bias summaries are available.
#> 20                                                                                                          Ranked cell-level bias/interactions with screening statistics.
#> 21                                                                                                                               Pairwise contrasts for two-way bias runs.
#> 22                                                                                                             R-native scatter, heatmap, and facet-profile bias displays.
#> 23                                                                                                                          Reusable plot data supports custom R graphics.
#> 24                                                                                                                    Users can build X-Y plots from returned data frames.
#> 25                                                                                                                               No package-native Webpage plot generator.
#> 26                                                                                                                      Selected 3D/surface-ready plot data are available.
#> 27                                                                                                               Several package outputs include histogram-like summaries.
#> 28                          Observed univariate G-study variance components plus D-study projections with residual-scaling sensitivity and `IdentificationStatus` columns.
#> 29                               Facet-level co-observation network plus rater agreement/disagreement/severity-direction and halo networks with reusable node/edge tables.
#> 30                                                                                                                    R-native reproducibility manifest and replay script.
#> 31                                                                                                                           Reusable anchor tables from fitted estimates.
#> 32                                                                                                                                  Graphfile-style category curve output.
#> 33                                                                                                                                   Structured appendix/report artifacts.
#> 34                                                       Standalone observation-level residual CSV/TSV output, residual tables, and residual visualizations are available.
#> 35                                                                      Score-side export/import is available for documented Rasch-family routes covered by package tests.
#> 36                                                                                                                 Simulation data and explicit simulation specifications.
#> 37                                                                                       Connected-subset summary/node files and group-anchor inputs/checks are available.
#> 38                                                                                                                                  No Winsteps control/data export route.
#> 39                                                                                                                              Category probability curve data and plots.
#> 40                                                                                                                                       Expected-score curves over theta.
#> 41                                                        Cumulative category-probability curve data, flipped direction data, and approximate .5 boundaries are available.
#> 42                                                                                                                          Design-weighted test/scale information curves.
#> 43                                               Category-specific information contributions, total information curves, and facet/level contribution curves are available.
#> 44                                                                                                         Category probability curves conditional on theta are available.
#> 45                                                                                                                         R function arguments are the package interface.
#> 46                                                                                                                              Selected fixed-width handoff is available.
#> 47                                                                                                                                    Fit/score table import is supported.
#> 48                                                                        No current public route imports a reusable versioned calibration bundle for operational scoring.
#> 49                                                               No current public route accepts general threshold or step anchors or a threshold starting-value contract.
#> 50                                                                                       Each fit uses one observed score scale and one homogeneous response-model family.
#> 51                                                                                The current RSM, PCM, and bounded-GPCM routes model ordered category probabilities only.
#> 52                                                            Binary ordered scores are available as the two-category special case of the current ordered-response kernel.
#> 53 A positive numeric observation weight multiplies that row's conditional ordered-category likelihood contribution and can represent a defensible row-replication weight.
#> 54                                                                                                       The current public estimator and score routes are unidimensional.
#> 55                                                                                  The current public GPCM route is bounded and requires slope_facet to equal step_facet.
#> 56                                                  FACETS PCM/JMLE can serve as the direct equal-discrimination comparison after the full estimation contract is aligned.
#>                                                                                                                                                                                                                                                                                                                                                        Limitation
#> 1                                                                                                                                                                                                                                                                                                                        Not an exact FACETS line-printer layout.
#> 2                                                                                                                                                                                                                                                                                                                      Structured QC replaces FACETS text layout.
#> 3                                                                                                                                                                                                                                                                                                         Does not reproduce the complete FACETS iteration trace.
#> 4                                                                                                                                                                                                                                                                                                Structured table and plots, not printer-identical FACETS output.
#> 5                                                                                                                                                                                                                                                                                                                Column order and text layout differ from FACETS.
#> 6                                                                                                                                                                                                                         Visual correspondence does not establish numerical equivalence; compare output from a documented FACETS version under aligned settings.
#> 7                                                                                                                                                                                                                                                                                                                 Network-style graph is not the default display.
#> 8                                                                                                                                                                                                                                                                                              FACETS M/S/Q/X printer-graph formatting is not reproduced exactly.
#> 9                                                                                                                                                                                                      Estimator and person-score basis, extreme handling, df/ZSTD conventions, and FACETS options can differ; external numerical equivalence is not established.
#> 10                                                                                                                                                                                                                                        Uses package-native structured output and documented df conventions; external numerical equivalence is not established.
#> 11                                                                                                                                                                                         The package does not translate category positions across multiple independent scales, apply FACETS agreement-based SE inflation, or establish external Table 7 parity.
#> 12                                                                                                                                                                                                                                                                                        FACETS binomial-trial and Poisson-specific reports are not implemented.
#> 13                                                                                                                                                                                                                       Multiple independent scales, scale-specific anchors or starting values, Thurstone thresholds, and FACETS text layout are not reproduced.
#> 14                                                                                                                                                                                                                                                                                                         FACETS line-printer artwork is not reproduced exactly.
#> 15                                                                                                                                                                                                                                                                                                         Uses R-native plot data rather than FACETS graph text.
#> 16                                                                                                                                                                                                                                                                                                     Conditional screening semantics are documented separately.
#> 17                                                                                                                                                                                                                                                                                                                  Structured table replaces FACETS text layout.
#> 18                                                                                                                                                                                                                                                                                                                 Structured output replaces FACETS text layout.
#> 19                                                                                                                                                                                                                                                                                                 FACETS vertical frequency bar-chart is not reproduced exactly.
#> 20                                                                                                                                                                                                                                                                                                  Reported as screening evidence, not final fairness inference.
#> 21                                                                                                                                                                                                                                                                                                            Higher-order runs omit pairwise sections by design.
#> 22                                                                                                                                                                                                                                                                                                                      Excel-specific output is not implemented.
#> 23                                                                                                                                                                                                                                                                                                        FACETS arbitrary R/Web plotting menus are not mirrored.
#> 24                                                                                                                                                                                                                                                                                                          No dedicated FACETS-style arbitrary X-Y plot wrapper.
#> 25                                                                                                                                                                                                                                                                                                                    Webpage menu output is a FACETS UI feature.
#> 26                                                                                                                                                                                                                                                                                                                        No arbitrary FACETS X-Y-Z plot wrapper.
#> 27                                                                                                                                                                                                                                                                                                                        No general FACETS histogram menu clone.
#> 28                                                                                                                                                                   Package-native caveated G/D-study route; not a FACETS/gtheory UI clone, not multivariate/profile G-theory, and not suitable for high-stakes use when boundary or singular fits are reported.
#> 29                                                                                                                                                                                                                                                                                           R-native igraph analysis and display rather than FACETS menu output.
#> 30                                                                                                                                                                                                                                                                                                            Does not write a FACETS command specification file.
#> 31                                                                                                                                                                                                                                                                                                             Uses R/CSV tables rather than FACETS fixed syntax.
#> 32                                                                                                                                                                                                                                                                                                     Command-level FACETS graph options are not fully mirrored.
#> 33                                                                                                                                                                                                                                                                                                          Full FACETS report-file emulation is not implemented.
#> 34                                                                                                                                                                                                                                                                     Uses package-native residual columns rather than exact FACETS fixed-field residual syntax.
#> 35                                                                                                                                                                                                                                                                                           Bounded GPCM score-side equivalence is outside the documented scope.
#> 36                                                                                                                                                                                                                                                                                                                        Not a FACETS simulated-data file clone.
#> 37                                                                                                                                                                                                                                          The standalone subset writer exports connectivity review tables, not a full FACETS UI-compatible subset command file.
#> 38                                                                                                                                                                                                                                                                                                             Would require a separate Winsteps output contract.
#> 39                                                                                                                                                                                                                                                                                                               R-native plots replace FACETS graph menu output.
#> 40                                                                                                                                                                                                                                                                                                                     Not labeled as FACETS ICC/IRF menu output.
#> 41                                                                                                                                                                                                                                                                                                           R-native plot data replace FACETS graph-menu output.
#> 42                                                                                                                                                                                                                                                                                                                 R-native information definition and plot data.
#> 43                                                                                                                                                                                                                                                                                                           R-native plot data replace FACETS graph-menu output.
#> 44                                                                                                                                                                                                                                                                                        FACETS conditional-probability menu semantics are not mirrored exactly.
#> 45                                                                                                                                                                                                                                                                                           Parsing arbitrary FACETS command files is outside the package scope.
#> 46                                                                                                                                                                                                                                                                                                      Exact full report emulation is outside the package scope.
#> 47                                                                                                                                                                                                                                                                                                          General raw FACETS report parsing is not implemented.
#> 48                                                                                                                                                                                                                                    Posterior scoring from an existing fitted object is supported separately and is not a reusable frozen-calibration contract.
#> 49                                                                                                                                                                                                                                                   Element and group anchors do not make threshold ladders fixed or supply a general calibration-import schema.
#> 50                                                                                                                                                                                                                                       There is no per-observation ScaleId contract, scale-specific category map, or ragged scale-specific PCM threshold block.
#> 51                                                                                                                                                                                                A category-probability vector that sums to one is not an unordered nominal-response or multinomial-logit model; category order enters every current likelihood.
#> 52                                                                                                                                                                                  Grouped binomial trials, Poisson counts, negative-binomial counts, and other count likelihoods are not implemented; integer scores are interpreted as ordered category codes.
#> 53 It is not a general collapsed-person frequency table: for MML, powering responses inside one Person pattern is not equivalent to replicating a complete Person pattern after marginalization. It also does not create a count-response family, model within-cell dependence, or make non-unit-weight fits eligible for the common information-criterion panel.
#> 54                                                                                                                                                                                                                                     Residual PCA is exploratory dimensionality evidence, not native multidimensional estimation or dimension-specific scoring.
#> 55                                                                                                                                                                                                                                                                      Bounded GPCM support does not establish an unrestricted free-discrimination model family.
#> 56                                                                                                                                                                                 FACETS Table 7 Estimated Discrimination is a post-fit diagnostic that does not update other Rasch estimates, so it is not the jointly estimated bounded-GPCM slope from mfrmr.
#>                                                                                                                                                                                                    Alternative
#> 1                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 2                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 3                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 4                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 5                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 6                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 7                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 8                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 9                                                                                              Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 10                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 11                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 12                                                                        Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 13                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 14                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 15                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 16                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 17                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 18                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 19                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 20                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 21                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 22                                                                        Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 23                                                                                    Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.
#> 24                                                                                    Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.
#> 25                                                                       Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.
#> 26                                                                                    Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.
#> 27                                                                                    Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.
#> 28                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 29                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 30                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 31                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 32                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 33                                                                        Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 34                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 35                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 36                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 37                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 38                                                                       Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.
#> 39                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 40                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 41                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 42                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 43                                                                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 44                                                                        Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 45                                                                       Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.
#> 46                                                                       Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.
#> 47                                                                        Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 48                                                                                          Use fitted-object posterior scoring for current analyses; retain frozen-calibration workflows for a later release.
#> 49                                                                                    Use current element/group anchor routes only for their documented scope; retain threshold anchoring for a later release.
#> 50                                                                                           Fit supported single-scale designs separately; retain multi-scale and mixed-family workflows for a later release.
#> 51                                                                                Use a nominal-response or multinomial-regression implementation externally when category order is not substantively defined.
#> 52                                            Use FACETS or another count-model implementation for an appropriate binomial-trial or Poisson estimand; do not relabel an ordered-category fit as a count model.
#> 53                                                  Retain one distinguishable event per row when possible; preserve distinct Person response patterns, and report the exact likelihood-weight interpretation.
#> 54                                                                            Use exploratory dimensionality diagnostics and external multidimensional software when a multidimensional estimator is required.
#> 55                                                                                           Use gpcm_capability_matrix() and the documented bounded-GPCM route; retain unrestricted GPCM for a later release.
#> 56 Use FACETS for the matched PCM/JML lane or as a deliberately misspecified equal-discrimination control; use a genuinely slope-estimating program only after the GPCM kernel and identification are matched.
facets_feature_coverage("partial")
#>                FACETSArea                                      FACETSFeature
#> 3            Output table                     Table 3: main iteration report
#> 8            Output table              Table 6.2: graphical facet statistics
#> 12           Output table Table 8.1: dichotomous/binomial/Poisson statistics
#> 14           Output table                 Table 8: scale-structure bar chart
#> 19           Output table                      Table 12: bias summary report
#> 22           Output table                                DIF/bias Excel plot
#> 23            R/Web plots      Scatterplots and histograms from FACETS menus
#> 24            R/Web plots                             X-Y plot: R Statistics
#> 26            R/Web plots                           X-Y-Z plot: R Statistics
#> 27            R/Web plots                            Histogram: R Statistics
#> 30            Output file                        Specification settings file
#> 33            Output file                                 Output report file
#> 35            Output file                                  Score output file
#> 36            Output file                                Simulated data file
#> 37            Output file                           Subset group-anchor file
#> 44             Graph menu                     Conditional probability curves
#> 47 Specification/workflow                      Raw FACETS report-text import
#>            FACETSReference
#> 3               table3.htm
#> 8             table6_2.htm
#> 12 table8_1dichotomous.htm
#> 14      table8barchart.htm
#> 19             table12.htm
#> 22         difbiasplot.htm
#> 23    outputtableindex.htm
#> 24             xyplotr.htm
#> 26            xyzplotr.htm
#> 27          histogramr.htm
#> 30   specificationfile.htm
#> 33          outputfile.htm
#> 35           scorefile.htm
#> 36       simulatedfile.htm
#> 37          subsetfile.htm
#> 44              graphs.htm
#> 47    outputtableindex.htm
#>                                                                             mfrmrRoute
#> 3                                                        estimation_iteration_report()
#> 8                                                 facet_statistics_report(); plot(...)
#> 12                                rating_scale_table() for two-category ordered scores
#> 14                                                         category_structure_report()
#> 19                                summary(estimate_bias(...)); plot_bias_interaction()
#> 22                                                   plot_bias_interaction(plot = ...)
#> 23                                                   plot_data(); package plot helpers
#> 24                                                plot_data(); user-defined R plotting
#> 26                                        plot(fit, type = "ccc_surface"); plot_data()
#> 27                        plot_data(); plot(fit, type = "wright"); plot_qc_dashboard()
#> 30                                   build_mfrm_manifest(); build_mfrm_replay_script()
#> 33                                    export_summary_appendix(); build_fixed_reports()
#> 35               facets_output_file_bundle(include = "score"); read_facets_fit_table()
#> 36                                         simulate_mfrm_data(); build_mfrm_sim_spec()
#> 37 write_mfrm_subset_file(); group_anchors; review_mfrm_anchors(); make_anchor_table()
#> 44                                                            category_curves_report()
#> 47                    read_facets_fit_table() for delimited/fixed-field score extracts
#>     Status SurfaceCoverage             StatisticalContract
#> 3  partial         partial partial_package_native_contract
#> 8  partial         partial partial_package_native_contract
#> 12 partial         partial partial_package_native_contract
#> 14 partial         partial partial_package_native_contract
#> 19 partial         partial partial_package_native_contract
#> 22 partial         partial partial_package_native_contract
#> 23 partial         partial partial_package_native_contract
#> 24 partial         partial partial_package_native_contract
#> 26 partial         partial partial_package_native_contract
#> 27 partial         partial partial_package_native_contract
#> 30 partial         partial partial_package_native_contract
#> 33 partial         partial partial_package_native_contract
#> 35 partial         partial partial_package_native_contract
#> 36 partial         partial partial_package_native_contract
#> 37 partial         partial partial_package_native_contract
#> 44 partial         partial partial_package_native_contract
#> 47 partial         partial partial_package_native_contract
#>                ValidationEvidence     OperationalStatus
#> 3  external_match_not_established partial_workflow_only
#> 8  external_match_not_established partial_workflow_only
#> 12 external_match_not_established partial_workflow_only
#> 14 external_match_not_established partial_workflow_only
#> 19 external_match_not_established partial_workflow_only
#> 22 external_match_not_established partial_workflow_only
#> 23 external_match_not_established partial_workflow_only
#> 24 external_match_not_established partial_workflow_only
#> 26 external_match_not_established partial_workflow_only
#> 27 external_match_not_established partial_workflow_only
#> 30 external_match_not_established partial_workflow_only
#> 33 external_match_not_established partial_workflow_only
#> 35 external_match_not_established partial_workflow_only
#> 36 external_match_not_established partial_workflow_only
#> 37 external_match_not_established partial_workflow_only
#> 44 external_match_not_established partial_workflow_only
#> 47 external_match_not_established partial_workflow_only
#>                                                                                            Capability
#> 3                                                        Convergence and replayed iteration evidence.
#> 8                                                              Facet statistics and visual summaries.
#> 12                                               Two-category Rasch-category summaries are available.
#> 14                                                       Category structure and transition summaries.
#> 19                                            Distributional and visual bias summaries are available.
#> 22                                        R-native scatter, heatmap, and facet-profile bias displays.
#> 23                                                     Reusable plot data supports custom R graphics.
#> 24                                               Users can build X-Y plots from returned data frames.
#> 26                                                 Selected 3D/surface-ready plot data are available.
#> 27                                          Several package outputs include histogram-like summaries.
#> 30                                               R-native reproducibility manifest and replay script.
#> 33                                                              Structured appendix/report artifacts.
#> 35 Score-side export/import is available for documented Rasch-family routes covered by package tests.
#> 36                                            Simulation data and explicit simulation specifications.
#> 37                  Connected-subset summary/node files and group-anchor inputs/checks are available.
#> 44                                    Category probability curves conditional on theta are available.
#> 47                                                               Fit/score table import is supported.
#>                                                                                                               Limitation
#> 3                                                                Does not reproduce the complete FACETS iteration trace.
#> 8                                                     FACETS M/S/Q/X printer-graph formatting is not reproduced exactly.
#> 12                                               FACETS binomial-trial and Poisson-specific reports are not implemented.
#> 14                                                                FACETS line-printer artwork is not reproduced exactly.
#> 19                                                        FACETS vertical frequency bar-chart is not reproduced exactly.
#> 22                                                                             Excel-specific output is not implemented.
#> 23                                                               FACETS arbitrary R/Web plotting menus are not mirrored.
#> 24                                                                 No dedicated FACETS-style arbitrary X-Y plot wrapper.
#> 26                                                                               No arbitrary FACETS X-Y-Z plot wrapper.
#> 27                                                                               No general FACETS histogram menu clone.
#> 30                                                                   Does not write a FACETS command specification file.
#> 33                                                                 Full FACETS report-file emulation is not implemented.
#> 35                                                  Bounded GPCM score-side equivalence is outside the documented scope.
#> 36                                                                               Not a FACETS simulated-data file clone.
#> 37 The standalone subset writer exports connectivity review tables, not a full FACETS UI-compatible subset command file.
#> 44                                               FACETS conditional-probability menu semantics are not mirrored exactly.
#> 47                                                                 General raw FACETS report parsing is not implemented.
#>                                                                                                                             Alternative
#> 3                       Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 8                       Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 12 Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 14                      Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 19                      Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 22 Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 23             Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.
#> 24             Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.
#> 26             Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.
#> 27             Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.
#> 30                      Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 33 Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 35                      Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 36                      Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 37                      Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 44 Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 47 Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
facets_feature_coverage("supported_with_caveat")
#>               FACETSArea
#> 9           Output table
#> 10          Output table
#> 11          Output table
#> 13          Output table
#> 28           R/Web plots
#> 53 Observation weighting
#>                                                   FACETSFeature
#> 9                             Table 7: facet measurement report
#> 10                          Table 7: reliability and chi-square
#> 11                                Table 7: agreement statistics
#> 13 Table 8.1: polytomous rating-scale/partial-credit statistics
#> 28                Generalizability Theory via R package gtheory
#> 53                    Row-frequency weights for ordered ratings
#>                  FACETSReference
#> 9                     table7.htm
#> 10   table7summarystatistics.htm
#> 11 table7agreementstatistics.htm
#> 13       table8_1ratingscale.htm
#> 28                   gtheory.htm
#> 53   mfrmr 0.2.3 weight contract
#>                                                                                                            mfrmrRoute
#> 9                                                                 fit_measures_table(); diagnose_mfrm(); summary(fit)
#> 10                                                                  facets_chisq_table(); diagnose_mfrm()$reliability
#> 11 interrater_agreement_table(); rater_network_analysis(); rater_halo_network_analysis(); plot_interrater_agreement()
#> 13                                                                  rating_scale_table(); category_structure_report()
#> 28                                                       mfrm_generalizability(); mfrm_d_study(); compute_facet_icc()
#> 53                                                                                             fit_mfrm(weight = ...)
#>                   Status       SurfaceCoverage     StatisticalContract
#> 9  supported_with_caveat available_with_caveat package_native_caveated
#> 10 supported_with_caveat available_with_caveat package_native_caveated
#> 11 supported_with_caveat available_with_caveat package_native_caveated
#> 13 supported_with_caveat available_with_caveat package_native_caveated
#> 28 supported_with_caveat available_with_caveat package_native_caveated
#> 53 supported_with_caveat available_with_caveat package_native_caveated
#>                ValidationEvidence               OperationalStatus
#> 9  external_match_not_established available_with_mandatory_caveat
#> 10 external_match_not_established available_with_mandatory_caveat
#> 11 external_match_not_established available_with_mandatory_caveat
#> 13 external_match_not_established available_with_mandatory_caveat
#> 28 external_match_not_established available_with_mandatory_caveat
#> 53 external_match_not_established available_with_mandatory_caveat
#>                                                                                                                                                                 Capability
#> 9                                                                                                                  Measures, SEs, fit, anchoring status, and review flags.
#> 10                                                                                                   Rasch/FACETS-style separation, reliability, and chi-square summaries.
#> 11      Raw-category observed agreement and model-probability expected agreement, plus pairwise rater-network, rater-by-criterion halo network, and rater-agreement views.
#> 13                                          Core category diagnostics and thresholds for one RSM scale or one PCM step facet on the package's shared observed score scale.
#> 28                          Observed univariate G-study variance components plus D-study projections with residual-scaling sensitivity and `IdentificationStatus` columns.
#> 53 A positive numeric observation weight multiplies that row's conditional ordered-category likelihood contribution and can represent a defensible row-replication weight.
#>                                                                                                                                                                                                                                                                                                                                                        Limitation
#> 9                                                                                                                                                                                                      Estimator and person-score basis, extreme handling, df/ZSTD conventions, and FACETS options can differ; external numerical equivalence is not established.
#> 10                                                                                                                                                                                                                                        Uses package-native structured output and documented df conventions; external numerical equivalence is not established.
#> 11                                                                                                                                                                                         The package does not translate category positions across multiple independent scales, apply FACETS agreement-based SE inflation, or establish external Table 7 parity.
#> 13                                                                                                                                                                                                                       Multiple independent scales, scale-specific anchors or starting values, Thurstone thresholds, and FACETS text layout are not reproduced.
#> 28                                                                                                                                                                   Package-native caveated G/D-study route; not a FACETS/gtheory UI clone, not multivariate/profile G-theory, and not suitable for high-stakes use when boundary or singular fits are reported.
#> 53 It is not a general collapsed-person frequency table: for MML, powering responses inside one Person pattern is not equivalent to replicating a complete Person pattern after marginalization. It also does not create a count-response family, model within-cell dependence, or make non-unit-weight fits eligible for the common information-criterion panel.
#>                                                                                                                                                   Alternative
#> 9                                             Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 10                                            Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 11                                            Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 13                                            Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 28                                            Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 53 Retain one distinguishable event per row when possible; preserve distinct Person response patterns, and report the exact likelihood-weight interpretation.
facets_feature_coverage("not_implemented")
#>                FACETSArea
#> 38            Output file
#> 48 Current scope boundary
#> 49 Current scope boundary
#> 50 Current scope boundary
#> 51 Current scope boundary
#> 52 Current scope boundary
#> 54 Current scope boundary
#> 55 Current scope boundary
#> 56 Current scope boundary
#>                                                       FACETSFeature
#> 38                                   Winsteps control and data file
#> 48      Versioned frozen-calibration import and operational scoring
#> 49      General threshold or step anchors and starting-value import
#> 50                  Multiple observed scales and scale-specific PCM
#> 51                              Nominal/multinomial response models
#> 52                 Binomial-trial and Poisson/count response models
#> 54 Native multidimensional estimation and dimension-specific scores
#> 55                                                Unrestricted GPCM
#> 56                     FACETS free-slope polytomous GPCM comparison
#>                FACETSReference                            mfrmrRoute
#> 38            winstepsfile.htm                                  none
#> 48 mfrmr 0.2.3 public contract                         none in 0.2.3
#> 49 mfrmr 0.2.3 public contract                         none in 0.2.3
#> 50 mfrmr 0.2.3 public contract                         none in 0.2.3
#> 51 mfrmr 0.2.3 public contract                         none in 0.2.3
#> 52                  models.htm                         none in 0.2.3
#> 54 mfrmr 0.2.3 public contract                         none in 0.2.3
#> 55 mfrmr 0.2.3 public contract   none for unrestricted GPCM in 0.2.3
#> 56                  t7menu.htm none as a direct common-estimand lane
#>             Status SurfaceCoverage StatisticalContract ValidationEvidence
#> 38 not_implemented     unavailable       not_available     not_applicable
#> 48 not_implemented     unavailable       not_available     not_applicable
#> 49 not_implemented     unavailable       not_available     not_applicable
#> 50 not_implemented     unavailable       not_available     not_applicable
#> 51 not_implemented     unavailable       not_available     not_applicable
#> 52 not_implemented     unavailable       not_available     not_applicable
#> 54 not_implemented     unavailable       not_available     not_applicable
#> 55 not_implemented     unavailable       not_available     not_applicable
#> 56 not_implemented     unavailable       not_available     not_applicable
#>    OperationalStatus
#> 38           blocked
#> 48           blocked
#> 49           blocked
#> 50           blocked
#> 51           blocked
#> 52           blocked
#> 54           blocked
#> 55           blocked
#> 56           blocked
#>                                                                                                                Capability
#> 38                                                                                 No Winsteps control/data export route.
#> 48                       No current public route imports a reusable versioned calibration bundle for operational scoring.
#> 49              No current public route accepts general threshold or step anchors or a threshold starting-value contract.
#> 50                                      Each fit uses one observed score scale and one homogeneous response-model family.
#> 51                               The current RSM, PCM, and bounded-GPCM routes model ordered category probabilities only.
#> 52           Binary ordered scores are available as the two-category special case of the current ordered-response kernel.
#> 54                                                      The current public estimator and score routes are unidimensional.
#> 55                                 The current public GPCM route is bounded and requires slope_facet to equal step_facet.
#> 56 FACETS PCM/JMLE can serve as the direct equal-discrimination comparison after the full estimation contract is aligned.
#>                                                                                                                                                                        Limitation
#> 38                                                                                                                             Would require a separate Winsteps output contract.
#> 48                                                    Posterior scoring from an existing fitted object is supported separately and is not a reusable frozen-calibration contract.
#> 49                                                                   Element and group anchors do not make threshold ladders fixed or supply a general calibration-import schema.
#> 50                                                       There is no per-observation ScaleId contract, scale-specific category map, or ragged scale-specific PCM threshold block.
#> 51                A category-probability vector that sums to one is not an unordered nominal-response or multinomial-logit model; category order enters every current likelihood.
#> 52  Grouped binomial trials, Poisson counts, negative-binomial counts, and other count likelihoods are not implemented; integer scores are interpreted as ordered category codes.
#> 54                                                     Residual PCA is exploratory dimensionality evidence, not native multidimensional estimation or dimension-specific scoring.
#> 55                                                                                      Bounded GPCM support does not establish an unrestricted free-discrimination model family.
#> 56 FACETS Table 7 Estimated Discrimination is a post-fit diagnostic that does not update other Rasch estimates, so it is not the jointly estimated bounded-GPCM slope from mfrmr.
#>                                                                                                                                                                                                    Alternative
#> 38                                                                       Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.
#> 48                                                                                          Use fitted-object posterior scoring for current analyses; retain frozen-calibration workflows for a later release.
#> 49                                                                                    Use current element/group anchor routes only for their documented scope; retain threshold anchoring for a later release.
#> 50                                                                                           Fit supported single-scale designs separately; retain multi-scale and mixed-family workflows for a later release.
#> 51                                                                                Use a nominal-response or multinomial-regression implementation externally when category order is not substantively defined.
#> 52                                            Use FACETS or another count-model implementation for an appropriate binomial-trial or Poisson estimand; do not relabel an ordered-category fit as a count model.
#> 54                                                                            Use exploratory dimensionality diagnostics and external multidimensional software when a multidimensional estimator is required.
#> 55                                                                                           Use gpcm_capability_matrix() and the documented bounded-GPCM route; retain unrestricted GPCM for a later release.
#> 56 Use FACETS for the matched PCM/JML lane or as a deliberately misspecified equal-discrimination control; use a genuinely slope-estimating program only after the GPCM kernel and identification are matched.
```
