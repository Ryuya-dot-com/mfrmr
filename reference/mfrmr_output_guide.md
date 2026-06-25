# Choose an mfrmr output helper by user goal

`mfrmr_output_guide()` returns a compact table for choosing among the
main table, report, review, bundle, export, and compatibility helpers.
It is a user-facing map, not an analysis result.

## Usage

``` r
mfrmr_output_guide(
  scope = c("all", "public", "entry", "viewer", "binary", "tables", "reports", "reviews",
    "bundles", "exports", "compatibility", "gpcm", "simulation", "linking", "network",
    "response_time", "facets", "conquest", "r")
)
```

## Arguments

- scope:

  Which rows to return. `"all"` returns the full guide. `"public"`
  returns the small top-level public surface for most users. `"entry"`
  returns the recommended first-screen routes. `"viewer"` returns
  local-viewer routes built around `mfrm_results(include = ...)`.
  `"binary"` returns the two-category person-item Rasch route and
  checks. Other values filter to one output family or to
  bounded-`GPCM`-relevant routes. `"linking"` returns anchor, drift, and
  equating route rows. `"simulation"` and `"network"` return advanced
  design-review rows. `"response_time"` returns descriptive
  response-time QC rows. `"facets"`, `"conquest"`, and `"r"` return
  user-pathway rows for people arriving from those workflows.

## Value

A data.frame with one row per recommended route and columns:

- `Scope`

- `Question`

- `OutputFamily`

- `Lifecycle`

- `UserLevel`

- `APILayer`

- `ObjectRole`

- `DecisionBoundary`

- `RecommendedEntry`

- `MainFunction`

- `UseWhen`

- `TypicalInput`

- `NextStep`

- `GPCMStatus`

- `Notes`

## Details

Naming convention used by the guide:

- `*_table`: focused table or table-like result for one evidence source

- `*_report`: multi-table evidence bundle for a reporting question

- `*_review`: status, interpretation, or decision-support object

- `*_bundle`: reusable collection of tables/metadata for handoff

- `export_*`: writes files or appendix artifacts

## First-screen route

Use `mfrmr_output_guide("public")` when you want the shortest top-level
API map. Use `mfrmr_output_guide("entry")` when you specifically want
first-screen creation routes. The entry guide points new scripts to
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
-\>
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
-\>
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
existing fits to
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
and exploratory console work to
[`mfrm_results_interactive()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results_interactive.md).
After creating `res`, use `summary(res)$next_actions` to choose the next
purpose-specific helper. Use `mfrmr_output_guide("viewer")` when the
next step is the optional local Shiny reader; it shows which `include`
preset to use before calling
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md).

## How to use this guide

Treat `MainFunction` as the route to try next and `UseWhen` as the
guardrail. The guide is not a replacement for the help pages of the
listed functions; it is a namespace map for deciding which page to open.
For bounded `GPCM`, use `scope = "gpcm"` to find both the support matrix
and the table that explains how out-of-scope routes are handled.

## Examples

``` r
public <- mfrmr_output_guide("public")
public[, c("Question", "APILayer", "ObjectRole", "MainFunction")]
#>                                                 Question
#> 1                      Start a new reproducible analysis
#> 2      Open the comprehensive first-screen result object
#> 3                   Read report readiness before writing
#> 4                    Open a local point-and-click reader
#> 5 Download results, report tables, HTML, and replay code
#> 6                       Find the next specialized helper
#> 7 Use exploratory prompts only when explicitly requested
#>                   APILayer                               ObjectRole
#> 1 top_level_public_surface model estimation and result-object entry
#> 2 top_level_public_surface              comprehensive result object
#> 3 top_level_public_surface                 report-readiness surface
#> 4 top_level_public_surface       local reader over existing results
#> 5 top_level_public_surface                      file export surface
#> 6 top_level_public_surface                    route-selection guide
#> 7 top_level_public_surface        explicit opt-in interactive entry
#>                                                                     MainFunction
#> 1                          fit_mfrm(); diagnose_mfrm(); res <- mfrm_results(fit)
#> 2                          res <- mfrm_results(fit, include = ...); summary(res)
#> 3 report <- mfrm_report(res); summary(report); mfrm_report(res, output = "html")
#> 4                                                       launch_mfrmr_viewer(res)
#> 5                     export_mfrm_results(res, include = c("default", "report"))
#> 6                           mfrmr_output_guide(scope); summary(res)$next_actions
#> 7                                                   mfrm_results_interactive(df)

entry <- mfrmr_output_guide("entry")
entry[, c("Question", "Lifecycle", "UserLevel", "MainFunction")]
#>                                                                  Question
#> 8        Start with explicit model roles and a comprehensive first screen
#> 9                 Open a FACETS-style result surface from an existing fit
#> 10                Browse the comprehensive result in a local Shiny viewer
#> 11 Choose the next purpose-specific helper without scanning the namespace
#> 12          Use column-selection prompts for exploratory data-frame input
#>    Lifecycle UserLevel                                       MainFunction
#> 8     stable  beginner        fit_mfrm(); diagnose_mfrm(); mfrm_results()
#> 9     stable  beginner                                     mfrm_results()
#> 10    stable  beginner res <- mfrm_results(fit); launch_mfrmr_viewer(res)
#> 11    stable  beginner    mfrmr_output_guide(); summary(res)$next_actions
#> 12    stable  beginner                         mfrm_results_interactive()

reviews <- mfrmr_output_guide("reviews")
reviews[, c("Question", "MainFunction", "UseWhen")]
#>                                                   Question
#> 25 Review response-time metadata as descriptive QC context
#> 26     Decide how strongly precision claims can be phrased
#> 29               Screen bias, DFF, or interaction evidence
#> 30            Review anchors, drift, and linking readiness
#> 31         Compare equal-weighting and bounded-GPCM routes
#>                                                                                                                                 MainFunction
#> 25 response_time_review(); mfrm_results(include = "response_time", response_time = ...); plot_response_time_review(); plot_data_components()
#> 26                                                                                                                 precision_review_report()
#> 29                                            mfrm_results(fit, include = "bias"); estimate_bias(); analyze_dff(); bias_interaction_report()
#> 30                                                                      review_mfrm_anchors(); detect_anchor_drift(); build_linking_review()
#> 31                                                                     build_model_choice_review(); build_weighting_review(); compare_mfrm()
#>                                                                                                            UseWhen
#> 25 You have event-level timing metadata and need rapid/slow-response screening outside the fitted MFRM likelihood.
#> 26                                   You need to separate model-based, hybrid, and exploratory precision evidence.
#> 29                                       You need screening evidence for follow-up fairness or interaction review.
#> 30                                            You need operational scale-maintenance checks for RSM/PCM workflows.
#> 31                                You need to review whether discrimination-based reweighting changes conclusions.

mfrmr_output_guide("gpcm")[, c("Question", "MainFunction", "GPCMStatus")]
#>                                                                Question
#> 1                                     Start a new reproducible analysis
#> 2                     Open the comprehensive first-screen result object
#> 3                                  Read report readiness before writing
#> 4                                   Open a local point-and-click reader
#> 5                Download results, report tables, HTML, and replay code
#> 7                Use exploratory prompts only when explicitly requested
#> 8      Start with explicit model roles and a comprehensive first screen
#> 9               Open a FACETS-style result surface from an existing fit
#> 10              Browse the comprehensive result in a local Shiny viewer
#> 12        Use column-selection prompts for exploratory data-frame input
#> 13                                Open the standard first-screen viewer
#> 14                         Prepare publication-oriented viewer sections
#> 15      Check validation, fit, and separation surfaces before reporting
#> 16 Inspect bias-screen prompts without choosing contrasts automatically
#> 17                     Inspect pathway-map and row-level misfit prompts
#> 18                                 Inspect anchor and linking readiness
#> 19                        Prepare a broad reviewer-facing viewer object
#> 20                            Fit ordinary person-item binary responses
#> 22                 Open the first-screen results for a binary Rasch run
#> 26                  Decide how strongly precision claims can be phrased
#> 27           Summarize facet variability, separation, and measurability
#> 28                Review category functioning and expected-score curves
#> 29                            Screen bias, DFF, or interaction evidence
#> 30                         Review anchors, drift, and linking readiness
#> 31                      Compare equal-weighting and bounded-GPCM routes
#> 32                         Turn summaries into reusable appendix tables
#> 33                        Assemble manuscript-oriented narrative output
#> 34                         Write files for appendix, replay, or handoff
#> 35                          Serve a legacy-compatible downstream layout
#> 36  Open first-screen anchor and linking readiness from an existing fit
#> 37        Review intended anchor and group-anchor tables before fitting
#> 38                  Check drift across separately fitted waves or forms
#> 39          Build a screened equating chain across ordered calibrations
#> 40               Generate planned, sparse, or peer-review response data
#> 41                      Evaluate design and recovery operating behavior
#> 42          Screen diagnostic behavior under misspecification scenarios
#> 43     Export simulation operating-characteristic tables for appendices
#> 44                Review co-observation connectivity as design evidence
#> 45                               Review peer-review assignment topology
#> 46                                Check the bounded GPCM support matrix
#> 47                      Review out-of-scope bounded GPCM route guidance
#> 48       State the FACETS relationship before using FACETS-style routes
#> 49                      Translate FACETS direct and group anchor blocks
#> 50                   Review anchor drift across forms, raters, or waves
#> 51                          List fit measures and misfit flags by facet
#> 52                                Explain FACETS df and ZSTD conversion
#> 53                   Bring an external FACETS fit table into the review
#> 54   Review rating-scale categories, fair averages, and expected curves
#> 55            Review FACETS Table 14-style bias and interaction signals
#> 56           Draw a Wright map / variable map on the common logit scale
#> 59                               Prepare a scoped ConQuest overlap case
#> 60             Compare extracted ConQuest tables after the external run
#> 61                         State where mfrmr is less free than ConQuest
#> 65                             Combine tables and plot data for reports
#>                                                                                                                        MainFunction
#> 1                                                                             fit_mfrm(); diagnose_mfrm(); res <- mfrm_results(fit)
#> 2                                                                             res <- mfrm_results(fit, include = ...); summary(res)
#> 3                                                    report <- mfrm_report(res); summary(report); mfrm_report(res, output = "html")
#> 4                                                                                                          launch_mfrmr_viewer(res)
#> 5                                                                        export_mfrm_results(res, include = c("default", "report"))
#> 7                                                                                                      mfrm_results_interactive(df)
#> 8                                                                                       fit_mfrm(); diagnose_mfrm(); mfrm_results()
#> 9                                                                                                                    mfrm_results()
#> 10                                                                               res <- mfrm_results(fit); launch_mfrmr_viewer(res)
#> 12                                                                                                       mfrm_results_interactive()
#> 13                                                         res <- mfrm_results(fit, include = "standard"); launch_mfrmr_viewer(res)
#> 14                                                      res <- mfrm_results(fit, include = "publication"); launch_mfrmr_viewer(res)
#> 15                                                       res <- mfrm_results(fit, include = "validation"); launch_mfrmr_viewer(res)
#> 16                                                             res <- mfrm_results(fit, include = "bias"); launch_mfrmr_viewer(res)
#> 17                                                    res <- mfrm_results(fit, include = "misfit_review"); launch_mfrmr_viewer(res)
#> 18                                                          res <- mfrm_results(fit, include = "linking"); launch_mfrmr_viewer(res)
#> 19               res <- mfrm_results(fit, include = c("publication", "bias", "misfit_review", "linking")); launch_mfrmr_viewer(res)
#> 20                                        fit_mfrm(data, person = ..., facets = "Item", score = ..., model = "RSM"); mfrm_results()
#> 22                                                            mfrm_results(fit); plot(res, type = "wright"); plot(res, type = "qc")
#> 26                                                                                                        precision_review_report()
#> 27                                                                                                        facet_statistics_report()
#> 28                                                      rating_scale_table(); category_structure_report(); category_curves_report()
#> 29                                   mfrm_results(fit, include = "bias"); estimate_bias(); analyze_dff(); bias_interaction_report()
#> 30                                                             review_mfrm_anchors(); detect_anchor_drift(); build_linking_review()
#> 31                                                            build_model_choice_review(); build_weighting_review(); compare_mfrm()
#> 32                                                                                                     build_summary_table_bundle()
#> 33                                                                        mfrm_report(); reporting_checklist(); build_apa_outputs()
#> 34                                    export_mfrm_results(); export_summary_appendix(); export_mfrm_bundle(); build_mfrm_manifest()
#> 35                                                  run_mfrm_facets(); facets_output_file_bundle(); facets_output_contract_review()
#> 36                                                              mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#> 37                                         make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 38                    detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot_anchor_drift()
#> 39     build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot_anchor_drift(type = "chain")
#> 40                                                             build_mfrm_sim_spec(); simulate_mfrm_data(); extract_mfrm_sim_spec()
#> 41                                                         evaluate_mfrm_design(); evaluate_mfrm_recovery(); assess_mfrm_recovery()
#> 42                                            evaluate_mfrm_diagnostic_screening(); summary(); plot(..., draw = FALSE); plot_data()
#> 43                                    summary(diag_eval); build_summary_table_bundle(diag_eval); export_summary_appendix(diag_eval)
#> 44                                                                             mfrm_network_analysis(); build_mfrm_network_review()
#> 45             build_peer_review_sim_spec(); build_peer_review_design_review(); build_mfrm_network_review(peer_review_design = ...)
#> 46                                                                                                         gpcm_capability_matrix()
#> 47                                                                                                    gpcm_runtime_guard_coverage()
#> 48             facets_positioning_guide(); facets_feature_coverage(); run_mfrm_facets(); mfrmRFacets(); facets_output_file_bundle()
#> 49                                         review_mfrm_anchors(); make_anchor_table(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 50                                         anchor_to_baseline(); detect_anchor_drift(); build_equating_chain(); plot_anchor_drift()
#> 51                                                                 fit_measures_table(); facets_chisq_table(); displacement_table()
#> 52                                                                     facets_fit_df_guide(); diagnose_mfrm(fit_df_method = "both")
#> 53                                                 read_facets_fit_table(); facets_fit_review(); plot(..., type = "df_sensitivity")
#> 54           rating_scale_table(); category_structure_report(); category_curves_report(); fair_average_table(); plot_fair_average()
#> 55 mfrm_results(fit, include = "bias"); estimate_bias(); bias_interaction_report(); bias_pairwise_report(); plot_bias_interaction()
#> 56                                                    plot(fit, type = "wright"); plot_wright_unified(); plot_data(type = "wright")
#> 59                                                                                                  build_conquest_overlap_bundle()
#> 60                                                                    normalize_conquest_overlap_files(); review_conquest_overlap()
#> 61                                                                                reporting_checklist(); reference_case_benchmark()
#> 65                                                                           build_summary_table_bundle(); build_visual_summaries()
#>                                                                      GPCMStatus
#> 1                                                         supported_with_caveat
#> 2                                                         supported_with_caveat
#> 3                                    direct_outputs_supported; APA route scoped
#> 4                                             viewer_only_uses_existing_results
#> 5                  summary_appendix_supported; fit_bundle_supported_with_caveat
#> 7                                                         supported_with_caveat
#> 8                                                         supported_with_caveat
#> 9                                                         supported_with_caveat
#> 10                                            viewer_only_uses_existing_results
#> 12                                                        supported_with_caveat
#> 13                                            viewer_only_uses_existing_results
#> 14                                                        supported_with_caveat
#> 15                                                        supported_with_caveat
#> 16                                                        supported_with_caveat
#> 17                                                        supported_with_caveat
#> 18 anchor_readiness_supported; exploratory_linking_review_supported_with_caveat
#> 19                                            viewer_only_uses_existing_results
#> 20                                          rsm_recommended_for_ordinary_binary
#> 22                                                        supported_with_caveat
#> 26                                                        supported_with_caveat
#> 27                                                        supported_with_caveat
#> 28                                                        supported_with_caveat
#> 29                                                        supported_with_caveat
#> 30                       supported_with_caveat; exploratory_gpcm_linking_review
#> 31                                                        supported_with_caveat
#> 32                                                 supported_for_direct_outputs
#> 33                                                        supported_with_caveat
#> 34                 summary_appendix_supported; fit_bundle_supported_with_caveat
#> 35                                graph_only_or_blocked_by_score_side_semantics
#> 36 anchor_readiness_supported; exploratory_linking_review_supported_with_caveat
#> 37                                                        supported_with_caveat
#> 38                       supported_with_caveat; exploratory_gpcm_linking_review
#> 39                       supported_with_caveat; exploratory_gpcm_linking_review
#> 40                                                        supported_with_caveat
#> 41                                                        supported_with_caveat
#> 42                                                        supported_with_caveat
#> 43                                                        supported_with_caveat
#> 44                                       design_diagnostic_not_measurement_gate
#> 45                                       design_diagnostic_not_measurement_gate
#> 46                                                       bounded_support_matrix
#> 47                                                  out_of_scope_route_guidance
#> 48                                graph_only_or_blocked_by_score_side_semantics
#> 49                                                        supported_with_caveat
#> 50                       supported_with_caveat; exploratory_gpcm_linking_review
#> 51                                                        supported_with_caveat
#> 52                                                        supported_with_caveat
#> 53                                                        supported_with_caveat
#> 54                                                        supported_with_caveat
#> 55                                                        supported_with_caveat
#> 56                                                        supported_with_caveat
#> 59                                       blocked_for_gpcm; rsm_pcm_overlap_only
#> 60                                       blocked_for_gpcm; rsm_pcm_overlap_only
#> 61                                       blocked_for_gpcm; rsm_pcm_overlap_only
#> 65                                                 supported_for_direct_outputs
mfrmr_output_guide("simulation")[, c("Question", "Lifecycle")]
#>                                                            Question Lifecycle
#> 40           Generate planned, sparse, or peer-review response data  advanced
#> 41                  Evaluate design and recovery operating behavior  advanced
#> 42      Screen diagnostic behavior under misspecification scenarios  advanced
#> 43 Export simulation operating-characteristic tables for appendices  advanced
mfrmr_output_guide("linking")[, c("Question", "MainFunction")]
#>                                                               Question
#> 36 Open first-screen anchor and linking readiness from an existing fit
#> 37       Review intended anchor and group-anchor tables before fitting
#> 38                 Check drift across separately fitted waves or forms
#> 39         Build a screened equating chain across ordered calibrations
#>                                                                                                                    MainFunction
#> 36                                                          mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#> 37                                     make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 38                detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot_anchor_drift()
#> 39 build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot_anchor_drift(type = "chain")
mfrmr_output_guide("facets")[, c("Question", "MainFunction")]
#>                                                                 Question
#> 48        State the FACETS relationship before using FACETS-style routes
#> 49                       Translate FACETS direct and group anchor blocks
#> 50                    Review anchor drift across forms, raters, or waves
#> 51                           List fit measures and misfit flags by facet
#> 52                                 Explain FACETS df and ZSTD conversion
#> 53                    Bring an external FACETS fit table into the review
#> 54    Review rating-scale categories, fair averages, and expected curves
#> 55             Review FACETS Table 14-style bias and interaction signals
#> 56            Draw a Wright map / variable map on the common logit scale
#> 57 Check score support and rater response patterns before fitting claims
#> 58                   Write residual and subset files for external review
#>                                                                                                                        MainFunction
#> 48             facets_positioning_guide(); facets_feature_coverage(); run_mfrm_facets(); mfrmRFacets(); facets_output_file_bundle()
#> 49                                         review_mfrm_anchors(); make_anchor_table(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 50                                         anchor_to_baseline(); detect_anchor_drift(); build_equating_chain(); plot_anchor_drift()
#> 51                                                                 fit_measures_table(); facets_chisq_table(); displacement_table()
#> 52                                                                     facets_fit_df_guide(); diagnose_mfrm(fit_df_method = "both")
#> 53                                                 read_facets_fit_table(); facets_fit_review(); plot(..., type = "df_sensitivity")
#> 54           rating_scale_table(); category_structure_report(); category_curves_report(); fair_average_table(); plot_fair_average()
#> 55 mfrm_results(fit, include = "bias"); estimate_bias(); bias_interaction_report(); bias_pairwise_report(); plot_bias_interaction()
#> 56                                                    plot(fit, type = "wright"); plot_wright_unified(); plot_data(type = "wright")
#> 57                                                                             data_quality_report(); plot(..., type = "dashboard")
#> 58                                                write_mfrm_residual_file(); write_mfrm_subset_file(); facets_output_file_bundle()
mfrmr_output_guide("binary")[, c("Question", "MainFunction")]
#>                                                Question
#> 20            Fit ordinary person-item binary responses
#> 21               Confirm the two-category score support
#> 22 Open the first-screen results for a binary Rasch run
#>                                                                                 MainFunction
#> 20 fit_mfrm(data, person = ..., facets = "Item", score = ..., model = "RSM"); mfrm_results()
#> 21                  describe_mfrm_data(); fit$prep$score_map; summary(fit)$settings_overview
#> 22                     mfrm_results(fit); plot(res, type = "wright"); plot(res, type = "qc")
mfrmr_output_guide("viewer")[, c("Question", "MainFunction")]
#>                                                                Question
#> 13                                Open the standard first-screen viewer
#> 14                         Prepare publication-oriented viewer sections
#> 15      Check validation, fit, and separation surfaces before reporting
#> 16 Inspect bias-screen prompts without choosing contrasts automatically
#> 17                     Inspect pathway-map and row-level misfit prompts
#> 18                                 Inspect anchor and linking readiness
#> 19                        Prepare a broad reviewer-facing viewer object
#>                                                                                                          MainFunction
#> 13                                           res <- mfrm_results(fit, include = "standard"); launch_mfrmr_viewer(res)
#> 14                                        res <- mfrm_results(fit, include = "publication"); launch_mfrmr_viewer(res)
#> 15                                         res <- mfrm_results(fit, include = "validation"); launch_mfrmr_viewer(res)
#> 16                                               res <- mfrm_results(fit, include = "bias"); launch_mfrmr_viewer(res)
#> 17                                      res <- mfrm_results(fit, include = "misfit_review"); launch_mfrmr_viewer(res)
#> 18                                            res <- mfrm_results(fit, include = "linking"); launch_mfrmr_viewer(res)
#> 19 res <- mfrm_results(fit, include = c("publication", "bias", "misfit_review", "linking")); launch_mfrmr_viewer(res)
mfrmr_output_guide("response_time")[, c("Question", "MainFunction")]
#>                                                   Question
#> 25 Review response-time metadata as descriptive QC context
#> 64    Reuse response-time plot data for custom QC graphics
#>                                                                                                                                 MainFunction
#> 25 response_time_review(); mfrm_results(include = "response_time", response_time = ...); plot_response_time_review(); plot_data_components()
#> 64                                 response_time_review(); plot_response_time_review(..., draw = FALSE); plot_data_components(); plot_data()
```
