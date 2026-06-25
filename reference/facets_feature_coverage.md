# FACETS Feature Coverage Matrix

`facets_feature_coverage()` summarizes how the current `mfrmr` release
maps the main FACETS output-table, output-file, and graph-menu surface
to package functions.

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

- `Scope`

- `GapOrBoundary`

- `Priority`

## Details

The matrix is based on the FACETS 64-bit output index, which lists
output Tables 1–14, DIF/bias plots, R/Web plots, output files, and
graph-menu curves. `mfrmr` intentionally prioritizes structured R tables
and reusable plot data over exact FACETS line-printer output.

Status meanings:

- `implemented`: a package-native route covers the substantive output.

- `supported_with_caveat`: a package-native route exists, but the output
  must be read with explicit identification, validation, or scope
  caveats.

- `partial`: the concept is covered, but not the full FACETS formatting,
  option surface, file type, or external integration.

- `not_implemented`: a FACETS feature has no direct package-native route
  in the current release.

- `not_targeted`: the feature is tied to FACETS UI, Web/Excel handoff,
  or another external program format and is not a release goal.

## References

Linacre, J. M. (2026). *A user's guide to FACETS, version 4.5.0*. Output
tables - files - plots - graphs:
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
#>                                                   FACETSFeature
#> 1                                Table 1: specification summary
#> 2                                  Table 2: data summary report
#> 3                                Table 3: main iteration report
#> 4                                 Table 4: unexpected responses
#> 5                              Table 5: measurable data summary
#> 6                        Table 6.0: all-facet Wright map rulers
#> 7                         Table 6.0.0: disjoint element listing
#> 8                         Table 6.2: graphical facet statistics
#> 9                             Table 7: facet measurement report
#> 10                          Table 7: reliability and chi-square
#> 11                                Table 7: agreement statistics
#> 12           Table 8.1: dichotomous/binomial/Poisson statistics
#> 13 Table 8.1: polytomous rating-scale/partial-credit statistics
#> 14                           Table 8: scale-structure bar chart
#> 15                  Table 8: scale-structure probability curves
#> 16                    Table 9: bias-estimation iteration report
#> 17                 Table 10: unexpected after allowing for bias
#> 18                            Table 11: bias-calculation counts
#> 19                                Table 12: bias summary report
#> 20                             Table 13: DIF/bias detail report
#> 21                               Table 14: pairwise bias report
#> 22                                          DIF/bias Excel plot
#> 23                Scatterplots and histograms from FACETS menus
#> 24                                       X-Y plot: R Statistics
#> 25                                            X-Y plot: Webpage
#> 26                                     X-Y-Z plot: R Statistics
#> 27                                      Histogram: R Statistics
#> 28                Generalizability Theory via R package gtheory
#> 29                        Connectivity network graph via igraph
#> 30                                  Specification settings file
#> 31                                           Anchor output file
#> 32                                          Graph plotting file
#> 33                                           Output report file
#> 34                                        Residuals output file
#> 35                                            Score output file
#> 36                                          Simulated data file
#> 37                                     Subset group-anchor file
#> 38                               Winsteps control and data file
#> 39                                  Category probability curves
#> 40                                       Expected score ICC/IRF
#> 41                                Cumulative probability curves
#> 42                                    Test information function
#> 43                                Category information function
#> 44                               Conditional probability curves
#> 45        Full FACETS command-file parser and UI option surface
#> 46                   Exact FACETS line-printer report emulation
#> 47                                Raw FACETS report-text import
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
#>                                                                                                                                     mfrmrRoute
#> 1                                                                                                                      specifications_report()
#> 2                                                                                                  data_quality_report(); describe_mfrm_data()
#> 3                                                                                                                estimation_iteration_report()
#> 4                                                                                               unexpected_response_table(); plot_unexpected()
#> 5                                                                                             measurable_summary_table(); describe_mfrm_data()
#> 6                                                                                            plot(fit, type = "wright"); plot_wright_unified()
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
#>                   Status
#> 1            implemented
#> 2            implemented
#> 3                partial
#> 4            implemented
#> 5            implemented
#> 6            implemented
#> 7            implemented
#> 8                partial
#> 9            implemented
#> 10           implemented
#> 11           implemented
#> 12               partial
#> 13           implemented
#> 14               partial
#> 15           implemented
#> 16           implemented
#> 17           implemented
#> 18           implemented
#> 19               partial
#> 20           implemented
#> 21           implemented
#> 22               partial
#> 23               partial
#> 24               partial
#> 25          not_targeted
#> 26               partial
#> 27               partial
#> 28 supported_with_caveat
#> 29           implemented
#> 30               partial
#> 31           implemented
#> 32           implemented
#> 33               partial
#> 34           implemented
#> 35               partial
#> 36               partial
#> 37               partial
#> 38       not_implemented
#> 39           implemented
#> 40           implemented
#> 41           implemented
#> 42           implemented
#> 43           implemented
#> 44               partial
#> 45          not_targeted
#> 46          not_targeted
#> 47               partial
#>                                                                                                                                             Scope
#> 1                                                                                            Structured run settings and reproducibility context.
#> 2                                                                          Rows, exclusions, missingness, score support, and response-pattern QC.
#> 3                                                                                                    Convergence and replayed iteration evidence.
#> 4                                                                                                       Case-level unexpected-response screening.
#> 5                                                                                Facet coverage, category counts, and subset/connectivity checks.
#> 6                                                                                                    Common-logit person/facet/threshold display.
#> 7                                                                                              Disconnected subsets and facet-by-subset coverage.
#> 8                                                                                                          Facet statistics and visual summaries.
#> 9                                                                                         Measures, SEs, fit, anchoring status, and review flags.
#> 10                                                                          Rasch/FACETS-style separation, reliability, and chi-square summaries.
#> 11                               Observed/expected agreement, pairwise rater-network, rater-by-criterion halo network, and rater-agreement views.
#> 12                                                                                           Two-category Rasch-category summaries are available.
#> 13                                                                               Rating-scale/partial-credit category diagnostics and thresholds.
#> 14                                                                                                   Category structure and transition summaries.
#> 15                                                                                            Category probability and expected-score curve data.
#> 16                                                                                            Bias recalibration path and final iteration status.
#> 17                                                                                        Unexpected rows after the current bias-screening layer.
#> 18                                                                                                         Response counts behind bias estimates.
#> 19                                                                                        Distributional and visual bias summaries are available.
#> 20                                                                                 Ranked cell-level bias/interactions with screening statistics.
#> 21                                                                                                      Pairwise contrasts for two-way bias runs.
#> 22                                                                                    R-native scatter, heatmap, and facet-profile bias displays.
#> 23                                                                                                 Reusable plot data supports custom R graphics.
#> 24                                                                                           Users can build X-Y plots from returned data frames.
#> 25                                                                                                      No package-native Webpage plot generator.
#> 26                                                                                             Selected 3D/surface-ready plot data are available.
#> 27                                                                                      Several package outputs include histogram-like summaries.
#> 28 Observed univariate G-study variance components plus D-study projections with residual-scaling sensitivity and `IdentificationStatus` columns.
#> 29      Facet-level co-observation network plus rater agreement/disagreement/severity-direction and halo networks with reusable node/edge tables.
#> 30                                                                                           R-native reproducibility manifest and replay script.
#> 31                                                                                                  Reusable anchor tables from fitted estimates.
#> 32                                                                                                         Graphfile-style category curve output.
#> 33                                                                                                          Structured appendix/report artifacts.
#> 34                              Standalone observation-level residual CSV/TSV output, residual tables, and residual visualizations are available.
#> 35                                                                       Score-side export/import is available for validated Rasch-family routes.
#> 36                                                                                        Simulation data and explicit simulation specifications.
#> 37                                                              Connected-subset summary/node files and group-anchor inputs/checks are available.
#> 38                                                                                                         No Winsteps control/data export route.
#> 39                                                                                                     Category probability curve data and plots.
#> 40                                                                                                              Expected-score curves over theta.
#> 41                               Cumulative category-probability curve data, flipped direction data, and approximate .5 boundaries are available.
#> 42                                                                                                 Design-weighted test/scale information curves.
#> 43                      Category-specific information contributions, total information curves, and facet/level contribution curves are available.
#> 44                                                                                Category probability curves conditional on theta are available.
#> 45                                                                                                R function arguments are the package interface.
#> 46                                                                                                     Selected fixed-width handoff is available.
#> 47                                                                                                           Fit/score table import is supported.
#>                                                                                                                                                                        GapOrBoundary
#> 1                                                                                                                                           Not an exact FACETS line-printer layout.
#> 2                                                                                                                                         Structured QC replaces FACETS text layout.
#> 3                                                                                                                           Does not reproduce every FACETS optimizer-internal line.
#> 4                                                                                                                   Structured table and plots, not printer-identical FACETS output.
#> 5                                                                                                                                   Column order and text layout differ from FACETS.
#> 6                                                                                                                                       R-native graphics replace FACETS ruler text.
#> 7                                                                                                                                    Network-style graph is not the default display.
#> 8                                                                                                                 FACETS M/S/Q/X printer-graph formatting is not reproduced exactly.
#> 9                                                                                                                    FACETS column order/options are broader than the default table.
#> 10                                                                                                                                            Uses package-native structured output.
#> 11                                                                                                                                    Structured output replaces FACETS text blocks.
#> 12                                                                                                           FACETS binomial-trial and Poisson-specific reports are not implemented.
#> 13                                                                                                                                       Exact FACETS text layout is not reproduced.
#> 14                                                                                                                            FACETS line-printer artwork is not reproduced exactly.
#> 15                                                                                                                            Uses R-native plot data rather than FACETS graph text.
#> 16                                                                                                                        Conditional screening semantics are documented separately.
#> 17                                                                                                                                     Structured table replaces FACETS text layout.
#> 18                                                                                                                                    Structured output replaces FACETS text layout.
#> 19                                                                                                                    FACETS vertical frequency bar-chart is not reproduced exactly.
#> 20                                                                                                                     Reported as screening evidence, not final fairness inference.
#> 21                                                                                                                               Higher-order runs omit pairwise sections by design.
#> 22                                                                                                                                         Excel-specific output is not implemented.
#> 23                                                                                                                           FACETS arbitrary R/Web plotting menus are not mirrored.
#> 24                                                                                                                             No dedicated FACETS-style arbitrary X-Y plot wrapper.
#> 25                                                                                                                                       Webpage menu output is a FACETS UI feature.
#> 26                                                                                                                                           No arbitrary FACETS X-Y-Z plot wrapper.
#> 27                                                                                                                                           No general FACETS histogram menu clone.
#> 28 Package-native caveated G/D-study route; not a FACETS/gtheory UI clone, not multivariate/profile G-theory, and not high-stakes-ready when boundary or singular fits are reported.
#> 29                                                                                                              R-native igraph analysis and display rather than FACETS menu output.
#> 30                                                                                                                               Does not write a FACETS command specification file.
#> 31                                                                                                                                Uses R/CSV tables rather than FACETS fixed syntax.
#> 32                                                                                                                        Command-level FACETS graph options are not fully mirrored.
#> 33                                                                                                                             Full FACETS report-file emulation is not implemented.
#> 34                                                                                        Uses package-native residual columns rather than exact FACETS fixed-field residual syntax.
#> 35                                                                                                              Bounded GPCM score-side equivalence is outside the current boundary.
#> 36                                                                                                                                           Not a FACETS simulated-data file clone.
#> 37                                                             The standalone subset writer exports connectivity review tables, not a full FACETS UI-compatible subset command file.
#> 38                                                                                                                                Would require a separate Winsteps output contract.
#> 39                                                                                                                                  R-native plots replace FACETS graph menu output.
#> 40                                                                                                                                        Not labeled as FACETS ICC/IRF menu output.
#> 41                                                                                                                              R-native plot data replace FACETS graph-menu output.
#> 42                                                                                                                                    R-native information definition and plot data.
#> 43                                                                                                                              R-native plot data replace FACETS graph-menu output.
#> 44                                                                                                           FACETS conditional-probability menu semantics are not mirrored exactly.
#> 45                                                                                                              Parsing arbitrary FACETS command files is outside the release scope.
#> 46                                                                                                                  Exact full report emulation is intentionally not a package goal.
#> 47                                                                                                                             General raw FACETS report parsing is not implemented.
#>        Priority
#> 1  release_core
#> 2  release_core
#> 3  release_core
#> 4  release_core
#> 5  release_core
#> 6  release_core
#> 7  release_core
#> 8  release_core
#> 9  release_core
#> 10 release_core
#> 11 release_core
#> 12        defer
#> 13 release_core
#> 14 release_core
#> 15 release_core
#> 16 release_core
#> 17 release_core
#> 18 release_core
#> 19 release_core
#> 20 release_core
#> 21 release_core
#> 22        defer
#> 23          low
#> 24          low
#> 25  not_planned
#> 26          low
#> 27          low
#> 28 release_core
#> 29 release_core
#> 30 release_core
#> 31 release_core
#> 32 release_core
#> 33        defer
#> 34 release_core
#> 35 release_core
#> 36 release_core
#> 37 release_core
#> 38  not_planned
#> 39 release_core
#> 40 release_core
#> 41 release_core
#> 42 release_core
#> 43 release_core
#> 44        defer
#> 45  not_planned
#> 46  not_planned
#> 47        defer
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
#>     Status
#> 3  partial
#> 8  partial
#> 12 partial
#> 14 partial
#> 19 partial
#> 22 partial
#> 23 partial
#> 24 partial
#> 26 partial
#> 27 partial
#> 30 partial
#> 33 partial
#> 35 partial
#> 36 partial
#> 37 partial
#> 44 partial
#> 47 partial
#>                                                                                Scope
#> 3                                       Convergence and replayed iteration evidence.
#> 8                                             Facet statistics and visual summaries.
#> 12                              Two-category Rasch-category summaries are available.
#> 14                                      Category structure and transition summaries.
#> 19                           Distributional and visual bias summaries are available.
#> 22                       R-native scatter, heatmap, and facet-profile bias displays.
#> 23                                    Reusable plot data supports custom R graphics.
#> 24                              Users can build X-Y plots from returned data frames.
#> 26                                Selected 3D/surface-ready plot data are available.
#> 27                         Several package outputs include histogram-like summaries.
#> 30                              R-native reproducibility manifest and replay script.
#> 33                                             Structured appendix/report artifacts.
#> 35          Score-side export/import is available for validated Rasch-family routes.
#> 36                           Simulation data and explicit simulation specifications.
#> 37 Connected-subset summary/node files and group-anchor inputs/checks are available.
#> 44                   Category probability curves conditional on theta are available.
#> 47                                              Fit/score table import is supported.
#>                                                                                                            GapOrBoundary
#> 3                                                               Does not reproduce every FACETS optimizer-internal line.
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
#> 35                                                  Bounded GPCM score-side equivalence is outside the current boundary.
#> 36                                                                               Not a FACETS simulated-data file clone.
#> 37 The standalone subset writer exports connectivity review tables, not a full FACETS UI-compatible subset command file.
#> 44                                               FACETS conditional-probability menu semantics are not mirrored exactly.
#> 47                                                                 General raw FACETS report parsing is not implemented.
#>        Priority
#> 3  release_core
#> 8  release_core
#> 12        defer
#> 14 release_core
#> 19 release_core
#> 22        defer
#> 23          low
#> 24          low
#> 26          low
#> 27          low
#> 30 release_core
#> 33        defer
#> 35 release_core
#> 36 release_core
#> 37 release_core
#> 44        defer
#> 47        defer
facets_feature_coverage("supported_with_caveat")
#>     FACETSArea                                 FACETSFeature FACETSReference
#> 28 R/Web plots Generalizability Theory via R package gtheory     gtheory.htm
#>                                                      mfrmrRoute
#> 28 mfrm_generalizability(); mfrm_d_study(); compute_facet_icc()
#>                   Status
#> 28 supported_with_caveat
#>                                                                                                                                             Scope
#> 28 Observed univariate G-study variance components plus D-study projections with residual-scaling sensitivity and `IdentificationStatus` columns.
#>                                                                                                                                                                        GapOrBoundary
#> 28 Package-native caveated G/D-study route; not a FACETS/gtheory UI clone, not multivariate/profile G-theory, and not high-stakes-ready when boundary or singular fits are reported.
#>        Priority
#> 28 release_core
facets_feature_coverage("not_implemented")
#>     FACETSArea                  FACETSFeature  FACETSReference mfrmrRoute
#> 38 Output file Winsteps control and data file winstepsfile.htm       none
#>             Status                                  Scope
#> 38 not_implemented No Winsteps control/data export route.
#>                                         GapOrBoundary    Priority
#> 38 Would require a separate Winsteps output contract. not_planned
```
