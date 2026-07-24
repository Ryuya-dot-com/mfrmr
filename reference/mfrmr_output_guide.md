# Choose an mfrmr output helper by user goal

`mfrmr_output_guide()` returns a compact table for choosing among the
main table, report, review, bundle, export, and compatibility helpers.
It is a user-facing map, not an analysis result.

## Usage

``` r
mfrmr_output_guide(
  scope = c("all", "public", "beginner", "psychometric", "entry", "viewer", "binary",
    "tables", "reports", "reviews", "bundles", "exports", "compatibility", "gpcm",
    "simulation", "linking", "network", "response_time", "facets", "conquest", "r")
)
```

## Arguments

- scope:

  Which rows to return. `"all"` returns the full guide. `"public"`
  returns the canonical six-step route for most users; `"beginner"`
  returns the same compact route rather than combining every
  beginner-labelled specialist row. `"entry"` returns the recommended
  first-screen routes. `"viewer"` returns local-viewer routes built
  around `mfrm_results(include = ...)`. `"binary"` returns the
  two-category person-item Rasch route and checks. Other values filter
  to one output family or to bounded-`GPCM`-relevant routes. `"linking"`
  returns anchor, drift, and equating route rows. `"simulation"` and
  `"network"` return advanced design-review rows. `"response_time"`
  returns descriptive response-time QC rows. `"facets"`, `"conquest"`,
  and `"r"` return user-pathway rows for people arriving from those
  workflows.

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

Use `mfrmr_output_guide("public")` or `mfrmr_output_guide("beginner")`
for the shortest top-level API map: an explicit
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
check and
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
MML fit, the lightweight fit summary, the comprehensive FACETS-organized
summary, the required native Wright map with SE/CI, optional
FACETS-style Wright and person-inclusive Infit views, and finally
report/export. Use `mfrmr_output_guide("entry")` when you specifically
need alternative first-screen creation routes, including existing result
objects, the optional viewer, or interactive console work. After
creating `res`, use `summary(res)$next_actions` to choose a
purpose-specific specialist helper. Use `mfrmr_output_guide("viewer")`
when the next step is the optional local Shiny reader; it shows which
`include` preset to use before calling
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md).
Use `mfrmr_output_guide("psychometric")` for the technical table,
review, and reporting routes whose interpretation boundaries should be
checked before manuscript use.

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
#>                                                  Question
#> 1 1. Check score support and fit with explicit data roles
#> 2          2. Check convergence and fitted-model settings
#> 3      3. Build the comprehensive FACETS-organized review
#> 4  4. Create the required native Wright map with SE or CI
#> 5    5. Add optional FACETS-style and Infit pathway views
#> 6     6. Review, report, and export the completed results
#>                   APILayer                               ObjectRole
#> 1 top_level_public_surface model estimation and result-object entry
#> 2 top_level_public_surface                      fit summary surface
#> 3 top_level_public_surface              comprehensive result object
#> 4 top_level_public_surface            specialist evidence component
#> 5 top_level_public_surface            specialist evidence component
#> 6 top_level_public_surface                      file export surface
#>                                                                                                                                                                                                                MainFunction
#> 1                                                                         describe_mfrm_data(data, person = ..., facets = ..., score = ...); fit <- fit_mfrm(data, person = ..., facets = ..., score = ..., method = "MML")
#> 2                                                                                                                                                                           summary(fit, profile = "fit", detail = "brief")
#> 3                                                                                                                                       review <- summary(fit, profile = "facets", detail = "brief"); res <- review$results
#> 4                                                                                                                      plot(res, type = "wright", renderer = "native", show_ci = TRUE, top_n = Inf, preset = "publication")
#> 5 fit$prep$score_map; plot(res, type = "wright", renderer = "facets", category_labels = rubric_labels, show_ci = FALSE); plot(res, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, person_labels = "none")
#> 6                                                                                                                report <- mfrm_report(res); summary(report, view = "reader"); export_mfrm_results(res, preset = "starter")

entry <- mfrmr_output_guide("entry")
entry[, c("Question", "Lifecycle", "UserLevel", "MainFunction")]
#>                                                                  Question
#> 7        Start with explicit model roles and a comprehensive first screen
#> 8                 Open a FACETS-style result surface from an existing fit
#> 9                 Browse the comprehensive result in a local Shiny viewer
#> 10 Choose the next purpose-specific helper without scanning the namespace
#> 11          Use column-selection prompts for exploratory data-frame input
#>    Lifecycle UserLevel                                       MainFunction
#> 7     stable  beginner        fit_mfrm(); diagnose_mfrm(); mfrm_results()
#> 8     stable  beginner                                     mfrm_results()
#> 9     stable  beginner res <- mfrm_results(fit); launch_mfrmr_viewer(res)
#> 10    stable  beginner    mfrmr_output_guide(); summary(res)$next_actions
#> 11    stable  beginner                         mfrm_results_interactive()

reviews <- mfrmr_output_guide("reviews")
reviews[, c("Question", "MainFunction", "UseWhen")]
#>                                                   Question
#> 24 Review response-time metadata as descriptive QC context
#> 25     Decide how strongly precision claims can be phrased
#> 28               Screen bias, DFF, or interaction evidence
#> 29            Review anchors, drift, and linking readiness
#> 30         Compare equal-weighting and bounded-GPCM routes
#>                                                                                                                                 MainFunction
#> 24 response_time_review(); mfrm_results(include = "response_time", response_time = ...); plot_response_time_review(); plot_data_components()
#> 25                                                                                                                 precision_review_report()
#> 28                                            mfrm_results(fit, include = "bias"); estimate_bias(); analyze_dff(); bias_interaction_report()
#> 29                                                                      review_mfrm_anchors(); detect_anchor_drift(); build_linking_review()
#> 30                                                                     build_model_choice_review(); build_weighting_review(); compare_mfrm()
#>                                                                                                            UseWhen
#> 24 You have event-level timing metadata and need rapid/slow-response screening outside the fitted MFRM likelihood.
#> 25                                   You need to separate model-based, hybrid, and exploratory precision evidence.
#> 28                                       You need screening evidence for follow-up fairness or interaction review.
#> 29                                            You need operational scale-maintenance checks for RSM/PCM workflows.
#> 30                                You need to review whether discrimination-based reweighting changes conclusions.

mfrmr_output_guide("gpcm")[, c("Question", "MainFunction", "GPCMStatus")]
#>                                                                                Question
#> 1                               1. Check score support and fit with explicit data roles
#> 2                                        2. Check convergence and fitted-model settings
#> 3                                    3. Build the comprehensive FACETS-organized review
#> 4                                4. Create the required native Wright map with SE or CI
#> 5                                  5. Add optional FACETS-style and Infit pathway views
#> 6                                   6. Review, report, and export the completed results
#> 7                      Start with explicit model roles and a comprehensive first screen
#> 8                               Open a FACETS-style result surface from an existing fit
#> 9                               Browse the comprehensive result in a local Shiny viewer
#> 11                        Use column-selection prompts for exploratory data-frame input
#> 12                                                Open the standard first-screen viewer
#> 13                                         Prepare publication-oriented viewer sections
#> 14                      Check validation, fit, and separation surfaces before reporting
#> 15                 Inspect bias-screen prompts without choosing contrasts automatically
#> 16                                     Inspect pathway-map and row-level misfit prompts
#> 17                                                 Inspect anchor and linking readiness
#> 18                                        Prepare a broad reviewer-facing viewer object
#> 19                                            Fit ordinary person-item binary responses
#> 21                                 Open the first-screen results for a binary Rasch run
#> 25                                  Decide how strongly precision claims can be phrased
#> 26                           Summarize facet variability, separation, and measurability
#> 27                                Review category functioning and expected-score curves
#> 28                                            Screen bias, DFF, or interaction evidence
#> 29                                         Review anchors, drift, and linking readiness
#> 30                                      Compare equal-weighting and bounded-GPCM routes
#> 31                                         Turn summaries into reusable appendix tables
#> 32                                        Assemble manuscript-oriented narrative output
#> 33                                         Write files for appendix, replay, or handoff
#> 34                                          Serve a legacy-compatible downstream layout
#> 35                  Open first-screen anchor and linking readiness from an existing fit
#> 36                        Review intended anchor and group-anchor tables before fitting
#> 37                                  Check drift across separately fitted waves or forms
#> 38                          Build a screened equating chain across ordered calibrations
#> 39                               Generate planned, sparse, or peer-review response data
#> 40                                      Evaluate design and recovery operating behavior
#> 41                          Screen diagnostic behavior under misspecification scenarios
#> 42                     Export simulation operating-characteristic tables for appendices
#> 43                                Review co-observation connectivity as design evidence
#> 44                                               Review peer-review assignment topology
#> 45                                                Check the bounded GPCM support matrix
#> 46                                Find alternatives for unavailable bounded GPCM routes
#> 47 1. Check score support, then open a FACETS-organized review from an explicit MML fit
#> 48                           2. Draw the required native Wright map with facet SE or CI
#> 49                             3. Add the FACETS-style ruler with rubric-labelled steps
#> 50                    4. Review Infit by measure, adding persons explicitly when needed
#> 51                      1. Fit the supported overlap model explicitly with MML in mfrmr
#> 52              2. State the ConQuest comparison scope before preparing external review
#> 53                       State the FACETS relationship before using FACETS-style routes
#> 54                                      Translate FACETS direct and group anchor blocks
#> 55                                   Review anchor drift across forms, raters, or waves
#> 56                                          List fit measures and misfit flags by facet
#> 57                                                Explain FACETS df and ZSTD conversion
#> 58                                   Bring an external FACETS fit table into the review
#> 59                   Review rating-scale categories, fair averages, and expected curves
#> 60                            Review FACETS Table 14-style bias and interaction signals
#> 61                           Draw a Wright map / variable map on the common logit scale
#> 64                                               Prepare a scoped ConQuest overlap case
#> 65                             Compare extracted ConQuest tables after the external run
#> 66                                     State where mfrmr is less flexible than ConQuest
#> 70                                             Combine tables and plot data for reports
#>                                                                                                                                                                                                                              MainFunction
#> 1                                                                                       describe_mfrm_data(data, person = ..., facets = ..., score = ...); fit <- fit_mfrm(data, person = ..., facets = ..., score = ..., method = "MML")
#> 2                                                                                                                                                                                         summary(fit, profile = "fit", detail = "brief")
#> 3                                                                                                                                                     review <- summary(fit, profile = "facets", detail = "brief"); res <- review$results
#> 4                                                                                                                                    plot(res, type = "wright", renderer = "native", show_ci = TRUE, top_n = Inf, preset = "publication")
#> 5               fit$prep$score_map; plot(res, type = "wright", renderer = "facets", category_labels = rubric_labels, show_ci = FALSE); plot(res, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, person_labels = "none")
#> 6                                                                                                                              report <- mfrm_report(res); summary(report, view = "reader"); export_mfrm_results(res, preset = "starter")
#> 7                                                                                                                                                                                             fit_mfrm(); diagnose_mfrm(); mfrm_results()
#> 8                                                                                                                                                                                                                          mfrm_results()
#> 9                                                                                                                                                                                      res <- mfrm_results(fit); launch_mfrmr_viewer(res)
#> 11                                                                                                                                                                                                             mfrm_results_interactive()
#> 12                                                                                                                                                               res <- mfrm_results(fit, include = "standard"); launch_mfrmr_viewer(res)
#> 13                                                                                                                                                            res <- mfrm_results(fit, include = "publication"); launch_mfrmr_viewer(res)
#> 14                                                                                                                                                             res <- mfrm_results(fit, include = "validation"); launch_mfrmr_viewer(res)
#> 15                                                                                                                                                                   res <- mfrm_results(fit, include = "bias"); launch_mfrmr_viewer(res)
#> 16                                                                                                                                                          res <- mfrm_results(fit, include = "misfit_review"); launch_mfrmr_viewer(res)
#> 17                                                                                                                                                                res <- mfrm_results(fit, include = "linking"); launch_mfrmr_viewer(res)
#> 18                                                                                                                     res <- mfrm_results(fit, include = c("publication", "bias", "misfit_review", "linking")); launch_mfrmr_viewer(res)
#> 19                                                                                                                                              fit_mfrm(data, person = ..., facets = "Item", score = ..., model = "RSM"); mfrm_results()
#> 21                                                                                                                                                                  mfrm_results(fit); plot(res, type = "wright"); plot(res, type = "qc")
#> 25                                                                                                                                                                                                              precision_review_report()
#> 26                                                                                                                                                                                                              facet_statistics_report()
#> 27                                                                                                                                                            rating_scale_table(); category_structure_report(); category_curves_report()
#> 28                                                                                                                                         mfrm_results(fit, include = "bias"); estimate_bias(); analyze_dff(); bias_interaction_report()
#> 29                                                                                                                                                                   review_mfrm_anchors(); detect_anchor_drift(); build_linking_review()
#> 30                                                                                                                                                                  build_model_choice_review(); build_weighting_review(); compare_mfrm()
#> 31                                                                                                                                                                                                           build_summary_table_bundle()
#> 32                                                                                                                                                                              mfrm_report(); reporting_checklist(); build_apa_outputs()
#> 33                                                                                                                                          export_mfrm_results(); export_summary_appendix(); export_mfrm_bundle(); build_mfrm_manifest()
#> 34                                                                                                                                                        run_mfrm_facets(); facets_output_file_bundle(); facets_output_contract_review()
#> 35                                                                                                                                                                    mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#> 36                                                                                                                                               make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 37                                                                                                                          detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot_anchor_drift()
#> 38                                                                                                           build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot_anchor_drift(type = "chain")
#> 39                                                                                                                                                                   build_mfrm_sim_spec(); simulate_mfrm_data(); extract_mfrm_sim_spec()
#> 40                                                                                                                                                               evaluate_mfrm_design(); evaluate_mfrm_recovery(); assess_mfrm_recovery()
#> 41                                                                                                                                                  evaluate_mfrm_diagnostic_screening(); summary(); plot(..., draw = FALSE); plot_data()
#> 42                                                                                                                                          summary(diag_eval); build_summary_table_bundle(diag_eval); export_summary_appendix(diag_eval)
#> 43                                                                                                                                                                                   mfrm_network_analysis(); build_mfrm_network_review()
#> 44                                                                                                                   build_peer_review_sim_spec(); build_peer_review_design_review(); build_mfrm_network_review(peer_review_design = ...)
#> 45                                                                                                                                                                                                               gpcm_capability_matrix()
#> 46                                                                                                                                                                                                          gpcm_runtime_guard_coverage()
#> 47 describe_mfrm_data(data, person = ..., facets = ..., score = ...); fit <- fit_mfrm(data, person = ..., facets = ..., score = ..., method = "MML"); review <- summary(fit, profile = "facets", detail = "brief"); res <- review$results
#> 48                                                                                                                                   plot(res, type = "wright", renderer = "native", show_ci = TRUE, top_n = Inf, preset = "publication")
#> 49                                                                                                                  fit$prep$score_map; plot(res, type = "wright", renderer = "facets", category_labels = rubric_labels, show_ci = FALSE)
#> 50                                                                                        plot(res, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, top_n_person = 12, person_labels = "none", facet_labels = "flagged")
#> 51                                                                      fit_lr <- fit_mfrm(data, person = "Person", facets = "Item", score = "Score", method = "MML", model = "RSM", population_formula = ~ X, person_data = person_data)
#> 52                                                                                                                                                                  mfrmr_output_guide("conquest"); build_conquest_overlap_bundle(fit_lr)
#> 53                                                                                                                   facets_positioning_guide(); facets_feature_coverage(); run_mfrm_facets(); mfrmRFacets(); facets_output_file_bundle()
#> 54                                                                                                                                               review_mfrm_anchors(); make_anchor_table(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 55                                                                                                                                               anchor_to_baseline(); detect_anchor_drift(); build_equating_chain(); plot_anchor_drift()
#> 56                                                                                                                                                                       fit_measures_table(); facets_chisq_table(); displacement_table()
#> 57                                                                                                                                                                           facets_fit_df_guide(); diagnose_mfrm(fit_df_method = "both")
#> 58                                                                                                                                                       read_facets_fit_table(); facets_fit_review(); plot(..., type = "df_sensitivity")
#> 59                                                                                                                 rating_scale_table(); category_structure_report(); category_curves_report(); fair_average_table(); plot_fair_average()
#> 60                                                                                                       mfrm_results(fit, include = "bias"); estimate_bias(); bias_interaction_report(); bias_pairwise_report(); plot_bias_interaction()
#> 61                                                                                                                                                          plot(fit, type = "wright"); plot_wright_unified(); plot_data(type = "wright")
#> 64                                                                                                                                                                                                        build_conquest_overlap_bundle()
#> 65                                                                                                                                                                        normalize_conquest_overlap_exports(); review_conquest_overlap()
#> 66                                                                                                                                                                                      reporting_checklist(); reference_case_benchmark()
#> 70                                                                                                                                                                                 build_summary_table_bundle(); build_visual_summaries()
#>                                                                      GPCMStatus
#> 1                                                         supported_with_caveat
#> 2                                                         supported_with_caveat
#> 3                                                         supported_with_caveat
#> 4                                                         supported_with_caveat
#> 5                                                         supported_with_caveat
#> 6                  summary_appendix_supported; fit_bundle_supported_with_caveat
#> 7                                                         supported_with_caveat
#> 8                                                         supported_with_caveat
#> 9                                             viewer_only_uses_existing_results
#> 11                                                        supported_with_caveat
#> 12                                            viewer_only_uses_existing_results
#> 13                                                        supported_with_caveat
#> 14                                                        supported_with_caveat
#> 15                                                        supported_with_caveat
#> 16                                                        supported_with_caveat
#> 17 anchor_readiness_supported; exploratory_linking_review_supported_with_caveat
#> 18                                            viewer_only_uses_existing_results
#> 19                                          rsm_recommended_for_ordinary_binary
#> 21                                                        supported_with_caveat
#> 25                                                        supported_with_caveat
#> 26                                                        supported_with_caveat
#> 27                                                        supported_with_caveat
#> 28                                                        supported_with_caveat
#> 29                       supported_with_caveat; exploratory_gpcm_linking_review
#> 30                                                        supported_with_caveat
#> 31                                                 supported_for_direct_outputs
#> 32                                                        supported_with_caveat
#> 33                 summary_appendix_supported; fit_bundle_supported_with_caveat
#> 34                                graph_only_or_blocked_by_score_side_semantics
#> 35 anchor_readiness_supported; exploratory_linking_review_supported_with_caveat
#> 36                                                        supported_with_caveat
#> 37                       supported_with_caveat; exploratory_gpcm_linking_review
#> 38                       supported_with_caveat; exploratory_gpcm_linking_review
#> 39                                                        supported_with_caveat
#> 40                                                        supported_with_caveat
#> 41                                                        supported_with_caveat
#> 42                                                        supported_with_caveat
#> 43                                       design_diagnostic_not_measurement_gate
#> 44                                       design_diagnostic_not_measurement_gate
#> 45                                                       bounded_support_matrix
#> 46                                                  out_of_scope_route_guidance
#> 47                                                        supported_with_caveat
#> 48                                                        supported_with_caveat
#> 49                                                        supported_with_caveat
#> 50                                                        supported_with_caveat
#> 51                                       blocked_for_gpcm; rsm_pcm_overlap_only
#> 52                                       blocked_for_gpcm; rsm_pcm_overlap_only
#> 53                                graph_only_or_blocked_by_score_side_semantics
#> 54                                                        supported_with_caveat
#> 55                       supported_with_caveat; exploratory_gpcm_linking_review
#> 56                                                        supported_with_caveat
#> 57                                                        supported_with_caveat
#> 58                                                        supported_with_caveat
#> 59                                                        supported_with_caveat
#> 60                                                        supported_with_caveat
#> 61                                                        supported_with_caveat
#> 64                                       blocked_for_gpcm; rsm_pcm_overlap_only
#> 65                                       blocked_for_gpcm; rsm_pcm_overlap_only
#> 66                                       blocked_for_gpcm; rsm_pcm_overlap_only
#> 70                                                 supported_for_direct_outputs
mfrmr_output_guide("simulation")[, c("Question", "Lifecycle")]
#>                                                            Question Lifecycle
#> 39           Generate planned, sparse, or peer-review response data  advanced
#> 40                  Evaluate design and recovery operating behavior  advanced
#> 41      Screen diagnostic behavior under misspecification scenarios  advanced
#> 42 Export simulation operating-characteristic tables for appendices  advanced
mfrmr_output_guide("linking")[, c("Question", "MainFunction")]
#>                                                               Question
#> 35 Open first-screen anchor and linking readiness from an existing fit
#> 36       Review intended anchor and group-anchor tables before fitting
#> 37                 Check drift across separately fitted waves or forms
#> 38         Build a screened equating chain across ordered calibrations
#>                                                                                                                    MainFunction
#> 35                                                          mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#> 36                                     make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 37                detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot_anchor_drift()
#> 38 build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot_anchor_drift(type = "chain")
mfrmr_output_guide("facets")[, c("Question", "MainFunction")]
#>                                                                                Question
#> 47 1. Check score support, then open a FACETS-organized review from an explicit MML fit
#> 48                           2. Draw the required native Wright map with facet SE or CI
#> 49                             3. Add the FACETS-style ruler with rubric-labelled steps
#> 50                    4. Review Infit by measure, adding persons explicitly when needed
#> 53                       State the FACETS relationship before using FACETS-style routes
#> 54                                      Translate FACETS direct and group anchor blocks
#> 55                                   Review anchor drift across forms, raters, or waves
#> 56                                          List fit measures and misfit flags by facet
#> 57                                                Explain FACETS df and ZSTD conversion
#> 58                                   Bring an external FACETS fit table into the review
#> 59                   Review rating-scale categories, fair averages, and expected curves
#> 60                            Review FACETS Table 14-style bias and interaction signals
#> 61                           Draw a Wright map / variable map on the common logit scale
#> 62                Check score support and rater response patterns before fitting claims
#> 63                                  Write residual and subset files for external review
#>                                                                                                                                                                                                                              MainFunction
#> 47 describe_mfrm_data(data, person = ..., facets = ..., score = ...); fit <- fit_mfrm(data, person = ..., facets = ..., score = ..., method = "MML"); review <- summary(fit, profile = "facets", detail = "brief"); res <- review$results
#> 48                                                                                                                                   plot(res, type = "wright", renderer = "native", show_ci = TRUE, top_n = Inf, preset = "publication")
#> 49                                                                                                                  fit$prep$score_map; plot(res, type = "wright", renderer = "facets", category_labels = rubric_labels, show_ci = FALSE)
#> 50                                                                                        plot(res, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, top_n_person = 12, person_labels = "none", facet_labels = "flagged")
#> 53                                                                                                                   facets_positioning_guide(); facets_feature_coverage(); run_mfrm_facets(); mfrmRFacets(); facets_output_file_bundle()
#> 54                                                                                                                                               review_mfrm_anchors(); make_anchor_table(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 55                                                                                                                                               anchor_to_baseline(); detect_anchor_drift(); build_equating_chain(); plot_anchor_drift()
#> 56                                                                                                                                                                       fit_measures_table(); facets_chisq_table(); displacement_table()
#> 57                                                                                                                                                                           facets_fit_df_guide(); diagnose_mfrm(fit_df_method = "both")
#> 58                                                                                                                                                       read_facets_fit_table(); facets_fit_review(); plot(..., type = "df_sensitivity")
#> 59                                                                                                                 rating_scale_table(); category_structure_report(); category_curves_report(); fair_average_table(); plot_fair_average()
#> 60                                                                                                       mfrm_results(fit, include = "bias"); estimate_bias(); bias_interaction_report(); bias_pairwise_report(); plot_bias_interaction()
#> 61                                                                                                                                                          plot(fit, type = "wright"); plot_wright_unified(); plot_data(type = "wright")
#> 62                                                                                                                                                                                   data_quality_report(); plot(..., type = "dashboard")
#> 63                                                                                                                                                      write_mfrm_residual_file(); write_mfrm_subset_file(); facets_output_file_bundle()
mfrmr_output_guide("binary")[, c("Question", "MainFunction")]
#>                                                Question
#> 19            Fit ordinary person-item binary responses
#> 20               Confirm the two-category score support
#> 21 Open the first-screen results for a binary Rasch run
#>                                                                                 MainFunction
#> 19 fit_mfrm(data, person = ..., facets = "Item", score = ..., model = "RSM"); mfrm_results()
#> 20                  describe_mfrm_data(); fit$prep$score_map; summary(fit)$settings_overview
#> 21                     mfrm_results(fit); plot(res, type = "wright"); plot(res, type = "qc")
mfrmr_output_guide("viewer")[, c("Question", "MainFunction")]
#>                                                                Question
#> 12                                Open the standard first-screen viewer
#> 13                         Prepare publication-oriented viewer sections
#> 14      Check validation, fit, and separation surfaces before reporting
#> 15 Inspect bias-screen prompts without choosing contrasts automatically
#> 16                     Inspect pathway-map and row-level misfit prompts
#> 17                                 Inspect anchor and linking readiness
#> 18                        Prepare a broad reviewer-facing viewer object
#>                                                                                                          MainFunction
#> 12                                           res <- mfrm_results(fit, include = "standard"); launch_mfrmr_viewer(res)
#> 13                                        res <- mfrm_results(fit, include = "publication"); launch_mfrmr_viewer(res)
#> 14                                         res <- mfrm_results(fit, include = "validation"); launch_mfrmr_viewer(res)
#> 15                                               res <- mfrm_results(fit, include = "bias"); launch_mfrmr_viewer(res)
#> 16                                      res <- mfrm_results(fit, include = "misfit_review"); launch_mfrmr_viewer(res)
#> 17                                            res <- mfrm_results(fit, include = "linking"); launch_mfrmr_viewer(res)
#> 18 res <- mfrm_results(fit, include = c("publication", "bias", "misfit_review", "linking")); launch_mfrmr_viewer(res)
mfrmr_output_guide("response_time")[, c("Question", "MainFunction")]
#>                                                   Question
#> 24 Review response-time metadata as descriptive QC context
#> 69    Reuse response-time plot data for custom QC graphics
#>                                                                                                                                 MainFunction
#> 24 response_time_review(); mfrm_results(include = "response_time", response_time = ...); plot_response_time_review(); plot_data_components()
#> 69                                 response_time_review(); plot_response_time_review(..., draw = FALSE); plot_data_components(); plot_data()
mfrmr_output_guide("beginner")[, c("Question", "MainFunction")]
#>                                                  Question
#> 1 1. Check score support and fit with explicit data roles
#> 2          2. Check convergence and fitted-model settings
#> 3      3. Build the comprehensive FACETS-organized review
#> 4  4. Create the required native Wright map with SE or CI
#> 5    5. Add optional FACETS-style and Infit pathway views
#> 6     6. Review, report, and export the completed results
#>                                                                                                                                                                                                                MainFunction
#> 1                                                                         describe_mfrm_data(data, person = ..., facets = ..., score = ...); fit <- fit_mfrm(data, person = ..., facets = ..., score = ..., method = "MML")
#> 2                                                                                                                                                                           summary(fit, profile = "fit", detail = "brief")
#> 3                                                                                                                                       review <- summary(fit, profile = "facets", detail = "brief"); res <- review$results
#> 4                                                                                                                      plot(res, type = "wright", renderer = "native", show_ci = TRUE, top_n = Inf, preset = "publication")
#> 5 fit$prep$score_map; plot(res, type = "wright", renderer = "facets", category_labels = rubric_labels, show_ci = FALSE); plot(res, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, person_labels = "none")
#> 6                                                                                                                report <- mfrm_report(res); summary(report, view = "reader"); export_mfrm_results(res, preset = "starter")
mfrmr_output_guide("psychometric")[, c("Question", "DecisionBoundary")]
#>                                                       Question
#> 22                   Document the model setup and run settings
#> 23      Check whether data were filtered, dropped, or remapped
#> 25         Decide how strongly precision claims can be phrased
#> 26  Summarize facet variability, separation, and measurability
#> 27       Review category functioning and expected-score curves
#> 29                Review anchors, drift, and linking readiness
#> 30             Compare equal-weighting and bounded-GPCM routes
#> 37         Check drift across separately fitted waves or forms
#> 38 Build a screened equating chain across ordered calibrations
#>                                                                                                                            DecisionBoundary
#> 22                                 Specialist follow-up: inspect the source object and help page before treating output as report evidence.
#> 23                                 Specialist follow-up: inspect the source object and help page before treating output as report evidence.
#> 25                                            Precision and separation evidence are not inter-rater agreement or standalone validity proof.
#> 26                                 Specialist follow-up: inspect the source object and help page before treating output as report evidence.
#> 27                                 Specialist follow-up: inspect the source object and help page before treating output as report evidence.
#> 29 Anchor and linking evidence support scale-maintenance review; drift and equating claims require explicit multi-fit wave or form designs.
#> 30                                 Specialist follow-up: inspect the source object and help page before treating output as report evidence.
#> 37 Anchor and linking evidence support scale-maintenance review; drift and equating claims require explicit multi-fit wave or form designs.
#> 38 Anchor and linking evidence support scale-maintenance review; drift and equating claims require explicit multi-fit wave or form designs.
```
