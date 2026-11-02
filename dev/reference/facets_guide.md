# Choose a FACETS comparison guide

One entry point for terminology, feature coverage, visual
correspondence, and fit-statistic interpretation. These guides describe
how to use and compare outputs; they do not establish numerical
equivalence with FACETS.

## Usage

``` r
facets_guide(
  topic = c("positioning", "terms", "visuals", "coverage", "fit_df"),
  ...
)
```

## Arguments

- topic:

  Guide to return: `"positioning"` explains the relationship between the
  packages; `"terms"` maps terminology; `"visuals"` maps plots;
  `"coverage"` lists supported and unavailable outputs; `"fit_df"`
  explains degrees of freedom and ZSTD comparisons.

- ...:

  Topic-specific controls. For `"coverage"`, `status = "all"` can filter
  to `"implemented"`, `"supported_with_caveat"`, `"partial"`,
  `"not_implemented"`, or `"not_targeted"`. For `"fit_df"`,
  `include_references = FALSE` omits the reference table. Other topics
  accept no extra arguments. Unsupported arguments raise an error.

## Value

A data frame for positioning, terms, visuals, or coverage. The fit-df
guide is an `mfrm_facets_fit_df_guide` bundle with `summary`,
`formula_guide`, `column_guide`, `decision_guide`,
`interpretation_guide`, `references`, and `settings`; its existing
summary/print methods apply.

## Details

The full topic descriptions are available in
[facets_positioning_guide](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_positioning_guide.md),
[facets_term_crosswalk](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_term_crosswalk.md),
[facets_visual_contract](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_visual_contract.md),
[facets_feature_coverage](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_feature_coverage.md),
and
[facets_fit_df_guide](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_fit_df_guide.md).
All topics are descriptive and require no fitting.

## See also

[`read_facets_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_facets_results.md),
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_fit_review.md),
[mfrmr_api_migration_030](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_api_migration_030.md)

## Examples

``` r
facets_guide("terms")
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
#>                                                                     mfrmrRoute
#> 1                                           fit_measures_table(); summary(fit)
#> 2             fit_measures_table(); plot(fit, type = "wright", show_ci = TRUE)
#> 3                                        diagnose_mfrm(); fit_measures_table()
#> 4                                        diagnose_mfrm(); fit_measures_table()
#> 5            facets_guide('fit_df'); fit_measures_table(df_sensitivity = TRUE)
#> 6                                             fit_mfrm(model = "RSM" or "PCM")
#> 7       plot(x, type = "wright", view = "unified"); plot(fit, type = "wright")
#> 8                                 facets_output_file_bundle(include = "graph")
#> 9                                 make_anchor_table(); fit_mfrm(anchors = ...)
#> 10 fit_mfrm(positive_facets = ...); plot(x, type = "wright", view = "unified")
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
#> 6                        The package exposes documented RSM/PCM and GPCM routes, not a FACETS command parser.
#> 7                FACETS-style rendering reproduces the ruler grammar, not optimizer-level numerical identity.
#> 8                                    CSV/TSV handoff is package-native rather than fixed-field FACETS syntax.
#> 9                         The table is an R-native anchor contract, not a complete FACETS specification file.
#> 10                                                   Always report which facets use the positive orientation.
facets_guide("coverage", status = "partial")
#>                FACETSArea                                      FACETSFeature
#> 3            Output table                     Table 3: main iteration report
#> 5            Output table                   Table 5: measurable data summary
#> 8            Output table              Table 6.2: graphical facet statistics
#> 12           Output table Table 8.1: dichotomous/binomial/Poisson statistics
#> 14           Output table                 Table 8: scale-structure bar chart
#> 18           Output table                  Table 11: bias-calculation counts
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
#> 5               table5.htm
#> 8             table6_2.htm
#> 12 table8_1dichotomous.htm
#> 14      table8barchart.htm
#> 18             table11.htm
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
#>                                                                                          mfrmrRoute
#> 3                                                                     estimation_iteration_report()
#> 5                                                  measurable_summary_table(); describe_mfrm_data()
#> 8                                                              facet_statistics_report(); plot(...)
#> 12                                             rating_scale_table() for two-category ordered scores
#> 14                                                                      category_structure_report()
#> 18                                                                               bias_count_table()
#> 19                                              summary(estimate_bias(...)); plot(x, type = "bias")
#> 22                                                                  plot(plot = ..., type = "bias")
#> 23                                                                plot_data(); package plot helpers
#> 24                                                             plot_data(); user-defined R plotting
#> 26                                                     plot(fit, type = "ccc_surface"); plot_data()
#> 27                                    plot_data(); plot(fit, type = "wright"); plot(x, type = "qc")
#> 30                                                build_mfrm_manifest(); build_mfrm_replay_script()
#> 33                                                 export_summary_appendix(); build_fixed_reports()
#> 35 facets_output_file_bundle(include = "score"); read_facets_results(); facets_fit_review(); plot()
#> 36                                                      simulate_mfrm_data(); build_mfrm_sim_spec()
#> 37              write_mfrm_subset_file(); group_anchors; review_mfrm_anchors(); make_anchor_table()
#> 44                                                                         category_curves_report()
#> 47                                   read_facets_results() for delimited/fixed-field score extracts
#>     Status SurfaceCoverage             StatisticalContract
#> 3  partial         partial partial_package_native_contract
#> 5  partial         partial partial_package_native_contract
#> 8  partial         partial partial_package_native_contract
#> 12 partial         partial partial_package_native_contract
#> 14 partial         partial partial_package_native_contract
#> 18 partial         partial partial_package_native_contract
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
#> 5  external_match_not_established partial_workflow_only
#> 8  external_match_not_established partial_workflow_only
#> 12 external_match_not_established partial_workflow_only
#> 14 external_match_not_established partial_workflow_only
#> 18 external_match_not_established partial_workflow_only
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
#>                                                                                                                            Capability
#> 3                                                                                        Convergence and replayed iteration evidence.
#> 5                                                                    Facet coverage, category counts, and subset/connectivity checks.
#> 8                                                                                              Facet statistics and visual summaries.
#> 12                                                                               Two-category Rasch-category summaries are available.
#> 14                                                                                       Category structure and transition summaries.
#> 18                                                         Cell counts, logit shifts and separate baseline/remaining score residuals.
#> 19                                                                            Distributional and visual bias summaries are available.
#> 22                                                                        R-native scatter, heatmap, and facet-profile bias displays.
#> 23                                                                                     Reusable plot data supports custom R graphics.
#> 24                                                                               Users can build X-Y plots from returned data frames.
#> 26                                                                                 Selected 3D/surface-ready plot data are available.
#> 27                                                                          Several package outputs include histogram-like summaries.
#> 30                                                                               R-native reproducibility manifest and replay script.
#> 33                                                                                              Structured appendix/report artifacts.
#> 35 Native observation-level score export and separate FACETS element-level import, including standalone source-measure and fit plots.
#> 36                                                                            Simulation data and explicit simulation specifications.
#> 37                                                  Connected-subset summary/node files and group-anchor inputs/checks are available.
#> 44                                                                    Category probability curves conditional on theta are available.
#> 47                                                                                               Fit/score table import is supported.
#>                                                                                                                                                                                                                                                                                                                          Limitation
#> 3                                                                                                                                                                                                                                                                           Does not reproduce the complete FACETS iteration trace.
#> 5                                                                                                                                                                                             Does not reproduce FACETS response moments, raw/residual variance and global Pearson summaries; this is substantive partial coverage.
#> 8                                                                                                                                                                                                                                                                FACETS M/S/Q/X printer-graph formatting is not reproduced exactly.
#> 12                                                                                                                                                                                                                                                          FACETS binomial-trial and Poisson-specific reports are not implemented.
#> 14                                                                                                                                                                                                                                                                           FACETS line-printer artwork is not reproduced exactly.
#> 18                                                                                                                                                                                                                                                   FACETS Table 11 response moments and variance decompositions are not supplied.
#> 19                                                                                                                                                                                                                                                                   FACETS vertical frequency bar-chart is not reproduced exactly.
#> 22                                                                                                                                                                                                                                                                                        Excel-specific output is not implemented.
#> 23                                                                                                                                                                                                                                                                          FACETS arbitrary R/Web plotting menus are not mirrored.
#> 24                                                                                                                                                                                                                                                                            No dedicated FACETS-style arbitrary X-Y plot wrapper.
#> 26                                                                                                                                                                                                                                                                                          No arbitrary FACETS X-Y-Z plot wrapper.
#> 27                                                                                                                                                                                                                                                                                          No general FACETS histogram menu clone.
#> 30                                                                                                                                                                                                                                                                              Does not write a FACETS command specification file.
#> 33                                                                                                                                                                                                                                                                            Full FACETS report-file emulation is not implemented.
#> 35 Export and import have different units/formats. Fixed imports require validated ASCII all-field headings; use named delimited columns for other layouts or non-ASCII labels. Imported results are descriptive, without external-calibration scoring or inferred joint uncertainty. GPCM score-side equivalence is outside scope.
#> 36                                                                                                                                                                                                                                                                                          Not a FACETS simulated-data file clone.
#> 37                                                                                                                                                                                                            The standalone subset writer exports connectivity review tables, not a full FACETS UI-compatible subset command file.
#> 44                                                                                                                                                                                                                                                          FACETS conditional-probability menu semantics are not mirrored exactly.
#> 47                                                                                                                                                                                                                                                                            General raw FACETS report parsing is not implemented.
#>                                                                                                                             Alternative
#> 3                       Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 5                       Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 8                       Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 12 Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.
#> 14                      Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
#> 18                      Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.
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
facets_guide("fit_df")$decision_guide
#>   Step                                                         Question
#> 1    1                                           Are MnSq values close?
#> 2    2                   Are df values close under the same convention?
#> 3    3                   Do ZSTD values differ after MnSq and df agree?
#> 4    4 Does |ZSTD| > 2 status change only after changing df convention?
#> 5    5                            Is an external FACETS table supplied?
#>                                                                                            RecommendedAction
#> 1 If MnSq differs materially, treat this as a fit-statistic or estimation difference before discussing ZSTD.
#> 2                    If df differs, classify the ZSTD gap as a df-convention issue unless MnSq also differs.
#> 3            Check WHEXACT/normalization settings and rounding/truncation before making a substantive claim.
#> 4         Report the flag as convention-sensitive; inspect MnSq and substantive context before acting on it.
#> 5                                            Use read_facets_results(), then pass it to facets_fit_review().
```
