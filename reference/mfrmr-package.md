# mfrmr: Many-Facet Ordered-Response Modeling in R

`mfrmr` provides estimation, diagnostics, and reporting utilities for
many-facet ordered-response measurement models: the Rasch-family `RSM` /
`PCM` route and the package's bounded `GPCM` extension where explicitly
documented.

## Details

Start with the following core workflow before branching into
diagnostics, bounded `GPCM`, simulation, and planning notes:

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    using `method = "MML"`

2.  Build a comprehensive first screen with
    [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)

3.  Build report-ready output with
    [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)

4.  Export a reproducible result folder with
    [`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)

5.  Add
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
    [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
    and
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    when the review needs deeper diagnostics; for bounded `GPCM`, read
    [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
    before interpreting specialist helpers

Recommended workflow:

1.  Fit model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)

2.  For `RSM` / `PCM`, compute diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    and prefer `diagnostic_mode = "both"` when you want legacy residual
    continuity plus the newer strict marginal-fit screen

3.  For `RSM` / `PCM`, run residual PCA with
    [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
    if needed

4.  For `RSM` / `PCM`, or bounded `GPCM` with the documented screening
    caveat, estimate interactions with
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)

5.  For `RSM` / `PCM`, choose a downstream branch:
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    for manuscript/report preparation, or
    [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
    /
    [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
    for operational misfit or anchor/drift review. After
    [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md),
    inspect `casebook$group_view_index` before moving to source-specific
    plots.

6.  For `RSM` / `PCM`, build narrative/report outputs with
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
    and
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)

7.  Treat bounded `GPCM`, prediction, and planning helpers as advanced
    scope after the basic `RSM` / `PCM` route is working cleanly.

Guide pages:

- [`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
  for the compact purpose-to-helper map

- [mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)

- [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

- [mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md)

- [mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)

- [mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

- [gpcm_capability_matrix](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)

- [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

Companion vignettes:

- [`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md)

- [`vignette("mfrmr-mml-and-marginal-fit", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-mml-and-marginal-fit.md)

- [`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md)

- [`vignette("mfrmr-reporting-and-apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-reporting-and-apa.md)

- [`vignette("mfrmr-linking-and-dff", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.md)

A two-page landscape cheatsheet of the public API ships at
`system.file("cheatsheet", "mfrmr-cheatsheet.pdf", package = "mfrmr")`
(pre-rendered) and
`system.file("cheatsheet", "mfrmr-cheatsheet.Rmd", package = "mfrmr")`
(source). Open the PDF directly for a printable reference card, or knit
the source with
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
when you want a customised version.

## First 5-minute route

Use this order before exploring the broader feature surface:

1.  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    with `method = "MML"`

2.  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
    for a comprehensive first screen

3.  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
    for report-ready wording, tables, and route labels

4.  [`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
    for a reproducible result folder

5.  Add
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    with `diagnostic_mode = "both"` for deeper `RSM` / `PCM`
    diagnostics; for bounded `GPCM`, keep diagnostics on the direct
    exploratory route and read
    [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)

6.  Choose the next branch:
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    for reporting,
    [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
    for Rasch-versus-`GPCM` weighting review,
    [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
    for operational case review, or
    [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
    for operational linking review (`RSM` / `PCM`) or caveated
    bounded-`GPCM` linking synthesis

## Advanced scope

After the basic route above:

- the package now includes a first-version latent-regression `MML`
  branch for ordered-response `RSM` / `PCM` models with a
  one-dimensional conditional-normal population model and explicit
  one-row-per-person covariates expanded through
  [`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html)

- bounded `GPCM` support is summarized by
  [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)

- bounded `GPCM` supports the core fit/summary/scoring/information path,
  direct Wright/pathway/CCC plots, residual-PCA follow-up, and the
  residual-based diagnostics tables/plots as exploratory tools

- posterior-predictive computation, `MCMC` engines, and Docker-based
  advanced runtimes are future extensions rather than requirements for
  the current bounded `GPCM` route

- direct `GPCM` data generation through
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
  and
  [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)
  is available when the specification carries both thresholds and slopes

- slope-aware
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  and
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  are available for bounded `GPCM` with explicit caveats;
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
  [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
  [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
  [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md),
  and
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  are available as caveated partial reporting/export surfaces;
  score-side FACETS compatibility and broader planning semantics remain
  validated for `RSM` / `PCM`

- [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  remains a scenario-level forecast helper and should not be described
  as the latent-regression estimator itself

- the current simulation/planning layer remains role-based for two
  non-person facets rather than fully arbitrary-facet planning, with
  boundaries exposed through planner metadata such as `planning_scope`,
  `planning_constraints`, and `planning_schema`

- latent-class mixture models and response-time / careless-rating
  adjustment are not estimated by mfrmr; use residual, person-fit,
  local-dependence, and rater-drift diagnostics as screening layers
  rather than as mixture-model substitutes

## Equal weighting versus bounded GPCM

The package's operational reference route is the Rasch-family `RSM` /
`PCM` branch. That route enforces fixed discrimination and therefore
preserves an equal-weighting scoring interpretation across observed
ratings.

Bounded `GPCM` is supported because some users want a slope-aware model-
comparison or sensitivity layer inside the same many-facet workflow.
However, the package does not treat bounded `GPCM` as a universal
replacement for the Rasch-family route. A better fit under `GPCM` should
be read as evidence about discrimination-based reweighting, not as an
automatic reason to discard the equal-weighting model.

Observation weights are a different concept again. Optional `Weight`
columns change how observed rating events enter estimation and
summaries, but they do not create a free-form facet-weighting scheme and
do not alter the fixed-discrimination meaning of `RSM` / `PCM`.

Public entry map:

- First-screen results:
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
  `summary(res)$next_actions`, and `mfrmr_output_guide("entry")`

- Interactive exploration:
  [`mfrm_results_interactive()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results_interactive.md)
  only when prompts are explicitly wanted at the console

Function families:

- Model fitting:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  [`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
  [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- Legacy-compatible workflow wrapper:
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
  [`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)

- Diagnostics:
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
  `summary(diag)`,
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
  [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md)

- Bias and interaction:
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
  [`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md),
  `summary(bias)`,
  [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md),
  [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)

- Differential functioning:
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
  [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)

- Design simulation:
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
  [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md),
  [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md),
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
  [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md),
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md),
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  (including fit-derived empirical / resampled / skeleton-based
  simulation specifications; fixed-calibration unit scoring supports
  `MML` fits directly, latent-regression `MML` fits through the fitted
  population model when scored units also provide one-row-per-person
  background data, and `JML` fits through a post hoc reference-prior EAP
  layer; fit-derived simulation specifications also support direct
  bounded `GPCM` data generation, recovery checks, role-based design
  evaluation, population forecasting, diagnostic-screening, and
  signal-detection helpers with documented caveats; curve reports,
  graph-only exports, fair-average tables, and bias screening are also
  available for bounded `GPCM` with documented caveats)

- Reporting:
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  for the full `RSM` / `PCM` route; bounded `GPCM` currently stays on
  the checklist / direct-table / direct- plot / summary-appendix side
  instead of the narrative/QC layer

- Weighting review:
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md),
  [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md),
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
  [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)

- Case review:
  [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md),
  [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
  [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
  [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)

- Linking and scale maintenance:
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md),
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md),
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md)

- Dashboards:
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md),
  [`plot_facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_quality_dashboard.md)

- Export / reproducibility:
  [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
  [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md),
  [`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md),
  [`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_files.md),
  [`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md),
  [`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md),
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  for the diagnostics-compatible Rasch-family route; bounded `GPCM`
  remains outside the current fit-based manifest/replay/bundle layer but
  can use
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
  for documented direct outputs

- Equivalence:
  [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md),
  [`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md)

- Data and anchors:
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
  [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md),
  [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)

Data interface:

- Input analysis data is long format (one row per observed rating).

- Required columns are one person column, one ordered score column, and
  one or more non-person facet columns named in `facets = c(...)`.

- Score values should be ordered integer categories. Binary `0/1` or
  `1/2` input is supported as the two-category Rasch-family special
  case; by contrast, fractional score values should be recoded before
  fitting rather than relying on automatic coercion.

- If `keep_original = FALSE`, unused intermediate categories are
  collapsed to a contiguous internal scale and the mapping is stored in
  `fit$prep$score_map`.

- If the intended scale has unused boundary categories, such as a 1-5
  scale with only 2-5 observed, set `rating_min = 1, rating_max = 5` so
  the zero-count boundary category remains in the fitted support. If
  unused intermediate categories should also remain in the original
  scale, set `keep_original = TRUE`.

- `summary(describe_mfrm_data(...))` reports retained zero-count
  categories in `Notes`, printed `Caveats`, and `$caveats`;
  `summary(fit)` carries full structured rows into printed `Caveats` and
  `$caveats`, with `Key warnings` as a short triage subset.
  Summary-table exports route those rows through
  `score_category_caveats` or `analysis_caveats`. Treat adjacent
  thresholds as weakly identified when an intermediate category is
  unobserved.

- Optional columns such as `Subset`, `Weight`, and `Group` support
  linking, weighted analysis, and fairness-focused follow-up workflows.

- Packaged simulation data is available via
  [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
  or [`data()`](https://rdrr.io/r/utils/data.html).

## Interpreting output

Core object classes are:

- `mfrm_fit`: fitted model parameters and metadata.

- `mfrm_diagnostics`: fit, facet-level reliability, and flag
  diagnostics, plus inter-rater agreement when one facet is treated as a
  rater facet.

- `mfrm_bias`: interaction bias estimates.

- `mfrm_dff` / `mfrm_dif`: differential-functioning contrasts and
  screening summaries.

- `mfrm_population_prediction`: scenario-level forecast summaries for
  one future design.

- `mfrm_unit_prediction`: posterior summaries for future or partially
  observed persons under the fitted scoring basis.

- `mfrm_plausible_values`: posterior draws for future or partially
  observed persons under the fitted scoring basis.

- `mfrm_bundle` families: summary/report bundles and draw-free plot
  data.

## Typical workflow

1.  Prepare long-format data.

2.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

3.  For `RSM` / `PCM`, diagnose with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    and prefer `diagnostic_mode = "both"` for final `MML` runs.

4.  For `RSM` / `PCM`, run
    [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
    or
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
    when fairness or interaction questions matter; bounded `GPCM` also
    supports
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
    as a conditional screening review.

5.  For `RSM` / `PCM`, report with
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
    and
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md).

6.  For design planning, move to
    [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
    [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
    [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md),
    [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
    and
    [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md).
    Bounded `GPCM` also supports direct simulation via
    [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md)
    /
    [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
    but not the broader planning helpers. Those helpers assume two
    non-person facet roles even though the estimation core supports
    arbitrary facet counts. Treat
    [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
    as Monte Carlo design evaluation, and use
    [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
    for analytic G/Phi design projections. Always read the
    `IdentificationStatus`, `GStatus`, and `PhiStatus` columns before
    reporting those projections; boundary or singular mixed-model fits
    are design-identification warnings, not high-stakes-ready
    reliability evidence.
    [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
    remains the scenario-level forecast helper, not the
    latent-regression estimator.

7.  For future-unit scoring, retain an `MML` calibration when you want
    the fitted marginal model directly, use an active latent-regression
    `MML` fit when scored units also provide one-row-per-person
    background data, or use a `JML` calibration when a post hoc
    fixed-calibration EAP layer is acceptable; then score with
    [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
    or
    [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md).

8.  For bounded `GPCM`, use
    [`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
    [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
    [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
    [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md),
    [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
    [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
    [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
    [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
    [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md),
    graph-only
    [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md),
    direct simulation-spec generation/data generation, recovery checks,
    [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
    and the residual-based table helpers with their documented caveats.
    Caveated APA/QC/export bundles and exploratory linking review plus
    role-based design evaluation, population forecasting,
    diagnostic-screening, and signal-detection helpers are available,
    while full score-side FACETS review, posterior-predictive checks,
    and heavy backends remain outside the bounded `GPCM` route. Use
    [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
    as the formal boundary statement.

## Model formulation

The Rasch-family branch used by `RSM` and `PCM` extends the basic Rasch
model by incorporating multiple measurement facets into a single
additive linear predictor on the log-odds scale.

**RSM/PCM adjacent-category equation**

For an observation where person \\n\\ with ability \\\theta_n\\ is rated
by rater \\j\\ with severity \\\delta_j\\ on criterion \\i\\ with
difficulty \\\beta_i\\, the probability of observing category \\k\\ (out
of \\K\\ ordered categories) is:

\$\$P(X\_{nij} = k \mid \theta_n, \delta_j, \beta_i, \tau) =
\frac{\exp\bigl\[\sum\_{s=1}^{k}(\theta_n - \delta_j - \beta_i -
\tau_s)\bigr\]} {\sum\_{c=0}^{K}\exp\bigl\[\sum\_{s=1}^{c}(\theta_n -
\delta_j - \beta_i - \tau_s)\bigr\]}\$\$

where \\\tau_s\\ are the Rasch-Andrich threshold (step) parameters in
the `RSM` reference case and \\\sum\_{s=1}^{0}(\cdot) \equiv 0\\ by
convention. Additional facets enter as additive terms in the linear
predictor \\\eta = \theta_n - \delta_j - \beta_i - \ldots\\.

This additive predictor generalises to any number of facets; the
`facets` argument to
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
accepts an arbitrary-length character vector.

**Rating Scale Model (RSM)**

Under the RSM (Andrich, 1978), all levels of the step facet share a
single set of threshold parameters \\\tau_1, \ldots, \tau_K\\.

**Partial Credit Model (PCM)**

Under the PCM (Masters, 1982), each level of the designated `step_facet`
has its own threshold vector on the package's common observed score
scale. In the current implementation, threshold locations may vary by
step-facet level, but the fitted score range is defined by one global
category set taken from the observed data.

**Bounded Generalized Partial Credit Model (GPCM)**

Under bounded `GPCM` (Muraki, 1992), the same adjacent-category
partial-credit kernel is multiplied by a positive slope \\\alpha_g\\ for
the designated slope-facet level \\g\\:

\$\$\ln\frac{P(X\_{nij} = k)}{P(X\_{nij} = k-1)} = \alpha_g(\theta_n -
\delta_j - \beta_i - \tau\_{gk}).\$\$

The current implementation requires `slope_facet == step_facet` and
identifies slopes on the log scale with geometric mean 1. This makes
bounded `GPCM` a slope-aware sensitivity/extension route, not a
replacement for the equal-weighting `RSM`/`PCM` interpretation.

**Ordered-response scope**

The implemented response-model scope is ordered categorical only. Binary
responses are the \\K = 1\\ special case of the same formulation, so
they are handled through the ordinary ordered-score interface. This
means `mfrmr` supports ordered binary and ordered polytomous data under
`RSM` and `PCM`, plus a narrow bounded `GPCM` branch with one designated
`slope_facet` that currently must equal `step_facet`. Unordered
nominal/multinomial response models are not yet implemented.

## Estimation methods

**Marginal Maximum Likelihood (MML)**

MML integrates over the person ability distribution using Gauss-Hermite
quadrature, in the broader marginal-likelihood framework introduced by
Bock & Aitkin (1981) for IRT:

\$\$L = \prod\_{n} \int P(\mathbf{X}\_n \mid \theta,
\boldsymbol{\delta}) \\ \phi(\theta) \\ d\theta \approx \prod\_{n}
\sum\_{q=1}^{Q} w_q \\ P(\mathbf{X}\_n \mid \theta_q,
\boldsymbol{\delta})\$\$

where \\\phi(\theta)\\ is the assumed normal prior and \\(\theta_q,
w_q)\\ are quadrature nodes and weights. Person estimates are obtained
post-hoc via Expected A Posteriori (EAP):

\$\$\hat{\theta}\_n^{\mathrm{EAP}} = \frac{\sum_q \theta_q \\ w_q \\
L(\mathbf{X}\_n \mid \theta_q)} {\sum_q w_q \\ L(\mathbf{X}\_n \mid
\theta_q)}\$\$

MML avoids the incidental-parameter problem and is generally preferred
for smaller samples.

Note: Bock & Aitkin (1981) is the canonical citation for the
Gauss-Hermite-quadrature MML *framework*. The default mfrmr engine
(`mml_engine = "direct"`) optimises this marginal log-likelihood by
direct gradient methods (BFGS / L-BFGS-B), not by Bock & Aitkin's
signature EM algorithm. The `"em"` and `"hybrid"` engines do follow the
EM template but use a BFGS M-step rather than B&A's probit IRLS, because
the target is the polytomous Rasch family rather than B&A's 2PL probit
model.

**Joint Maximum Likelihood (JML)**

JML estimates all person and facet parameters simultaneously as fixed
effects by maximising the joint log-likelihood
\\\ell(\boldsymbol{\theta}, \boldsymbol{\delta} \mid \mathbf{X})\\
directly. It does not assume a parametric person distribution, which can
be advantageous when the population shape is strongly non-normal, but
parameter estimates are known to be biased when the number of persons is
small relative to the number of items (Neyman & Scott, 1948). The
package still accepts `"JMLE"` as a backward-compatible alias, but
user-facing summaries and documentation use `"JML"` as the public label.

See
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for practical guidance on choosing between the two.

## Strict marginal diagnostics

For `RSM` / `PCM`, `diagnose_mfrm(..., diagnostic_mode = "both")`
returns two complementary targets: the `legacy` residual / EAP
diagnostics and a `marginal_fit` layer whose expected counts and
pairwise summaries are integrated over the posterior quadrature bundle
rather than plugged in at the EAP point. The screen is structured as
limited-information evidence (Orlando & Thissen, 2000; Haberman &
Sinharay, 2013; Sinharay & Monroe, 2025), not as an omnibus accept /
reject test, and it complements rather than replaces separation /
reliability and inter-rater agreement summaries. The full derivation,
with notation and pairwise local-dependence events, lives in
[`vignette("mfrmr-mml-and-marginal-fit", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-mml-and-marginal-fit.md).

## Statistical background

Key statistics reported throughout the package:

**Infit (Information-Weighted Mean Square)**

Weighted average of squared standardized residuals, where weights are
the model-based variance of each observation:

\$\$\mathrm{Infit}\_j = \frac{\sum_i Z\_{ij}^2 \\ \mathrm{Var}\_i \\
w_i} {\sum_i \mathrm{Var}\_i \\ w_i}\$\$

Expected value is 1.0 under model fit. Values below 0.5 suggest overfit
(Mead-style responses); values above 1.5 suggest underfit (noise or
misfit). Infit is most sensitive to unexpected patterns among on-target
observations (Wright & Masters, 1982).

Note: The 0.5–1.5 range is the general "productive for measurement" band
given by Linacre (2002, *RMT* 16(2), 878). Context-specific bands come
from Wright & Linacre (1994, *RMT* 8(3), 370): 0.8–1.2 for high-stakes
MCQ, 0.7–1.3 for run-of-the-mill MCQ, 0.6–1.4 for rating-scale surveys,
0.5–1.7 for clinical observation, and 0.4–1.2 for judged performance.
See also Bond & Fox (2015) for textbook summaries of these conventions.

**Outfit (Unweighted Mean Square)**

Simple average of squared standardized residuals:

\$\$\mathrm{Outfit}\_j = \frac{\sum_i Z\_{ij}^2 \\ w_i}{\sum_i w_i}\$\$

Same expected value and flagging thresholds as Infit, but more sensitive
to extreme off-target outliers (e.g., a high-ability person scoring the
lowest category).

**ZSTD (Standardized Fit Statistic)**

Wilson-Hilferty (1931) cube-root transformation that converts the
mean-square chi-square ratio to an approximate standard normal deviate:

\$\$\mathrm{ZSTD} = \frac{\mathrm{MnSq}^{1/3} - (1 -
2/(9\\\mathit{df}))} {\sqrt{2/(9\\\mathit{df})}}\$\$

Values near 0 indicate expected fit; \\\|\mathrm{ZSTD}\| \> 2\\ flags
potential misfit at the 5\\ 1\\ ZSTD is reported alongside every Infit
and Outfit value. ZSTD is withheld (`NA`) when the applicable df falls
below 1, where the Wilson-Hilferty transformation is numerically
unstable; FACETS/Winsteps under `WHEXACT` can continue with a linear
approximation on such cells.

**Residual basis under MML vs JMLE engines**

For `method = "MML"` fits, the standardized residuals behind Infit,
Outfit, and ZSTD are evaluated at EAP person measures, which are
shrunken toward the population mean. JMLE engines such as FACETS
evaluate the same formulas at unshrunken JMLE estimates, so MnSq and
ZSTD values are not numerically interchangeable across the two residual
bases, most visibly for extreme-scoring persons. Use `method = "JML"`
when an external FACETS fit comparison requires a JMLE-style residual
basis, and see
[`facets_fit_df_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_df_guide.md)
for the separate standardization-side df/ZSTD conventions.

**PTMEA (Point-Measure Correlation)**

Pearson correlation between observed scores and estimated person
measures within each facet level. Positive values indicate that scoring
aligns with the latent trait dimension; negative values suggest reversed
orientation or scoring errors.

**Separation**

Package-reported separation is the ratio of adjusted true standard
deviation to root-mean-square measurement error:

\$\$G = \frac{\mathrm{SD}\_{\mathrm{adj}}}{\mathrm{RMSE}}\$\$

where \\\mathrm{SD}\_{\mathrm{adj}} = \sqrt{\mathrm{ObservedVariance} -
\mathrm{ErrorVariance}}\\. Higher values indicate the facet
discriminates more statistically distinct levels along the measured
variable. In `mfrmr`, `Separation` is the model-based value and
`RealSeparation` provides a more conservative companion based on
`RealSE`.

**Reliability**

\$\$R = \frac{G^2}{1 + G^2}\$\$

Analogous to Cronbach's alpha or KR-20 for the reproducibility of
element ordering. In `mfrmr`, `Reliability` is the model-based value and
`RealReliability` gives the conservative companion based on `RealSE`.
For `MML`, these are anchored to observed-information `ModelSE`
estimates for non-person facets; `JML` keeps them as exploratory
summaries.

For the person facet under `MML`, the same \\G\\ and \\R\\ formulas are
applied to EAP person measures with posterior SDs in the error slot. EAP
measures are shrunken, so their observed variance is already deflated
(approximately the true variance times the reliability), and subtracting
the mean posterior variance deflates it again. The reported MML person
separation/reliability is therefore a conservative summary: it is
systematically lower than the IRT empirical-reliability convention
\\\mathrm{Var}(\mathrm{EAP}) / (\mathrm{Var}(\mathrm{EAP}) +
\overline{\mathrm{PSD}^2})\\ and is not numerically comparable to
JMLE-based person separation reliability from FACETS. The gap is small
when measurement is precise and grows as precision drops. Person rows
can still carry the model-based precision tier because posterior SDs are
model-based quantities; that tier describes the SE source, not FACETS
comparability. Use `method = "JML"` when a FACETS-style person
separation table is required, and treat MML person rows as conservative
summaries.

This is a Rasch/FACETS-style separation reliability on the fitted logit
scale, not an intra-class correlation. Use
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
only when you want the complementary random-effects variance-share view
on the observed-score scale; for non-person facets, large ICC values
indicate systematic facet variance rather than desirable measurement
reliability.

**Strata**

Number of statistically distinguishable groups of elements:

\$\$H = \frac{4G + 1}{3}\$\$

Three or more strata are commonly used as a practical target (Wright &
Masters, 1982), but in this package the estimate inherits the same
approximation limits as the separation index.

## Key references

- Andrich, D. (1978). A rating formulation for ordered response
  categories. *Psychometrika*, 43, 561–573.

- Bond, T. G., & Fox, C. M. (2015). *Applying the Rasch model* (3rd
  ed.). Routledge.

- Bock, R. D., & Aitkin, M. (1981). Marginal maximum likelihood
  estimation of item parameters: Application of an EM algorithm.
  *Psychometrika*, 46, 443–459.

- Burnham, K. P., & Anderson, D. R. (2002). *Model selection and
  multimodel inference: A practical information-theoretic approach* (2nd
  ed.). Springer. (AIC / BIC weights and Delta-IC bands used by
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).)

- Drasgow, F., Levine, M. V., & Williams, E. A. (1985). Appropriateness
  measurement with polychotomous item response models and standardized
  indices. *British Journal of Mathematical and Statistical Psychology*,
  38(1), 67–86. (Source for the `lz` person-fit statistic implemented in
  [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md).)

- Haberman, S. J., & Sinharay, S. (2013). Generalized residuals for
  general models for contingency tables with application to item
  response theory. *Journal of the American Statistical Association*,
  108, 1435–1444.

- Eckes, T. (2005). Examining rater effects in TestDaF writing and
  speaking performance assessments: A many-facet Rasch analysis.
  *Language Assessment Quarterly*, 2, 197–221.

- Muraki, E. (1992). A generalized partial credit model: Application of
  an EM algorithm. *Applied Psychological Measurement*, 16(2), 159–176.
  (Source for the bounded `GPCM` extension used in
  `fit_mfrm(model = "GPCM")`,
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
  and
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).)

- Muraki, E. (1993). Information functions of the generalized partial
  credit model. *Applied Psychological Measurement*, 17(4), 351–363.
  (Companion paper to Muraki 1992 that derives the GPCM item information
  identity \\I_j(\theta) = D^2 a_j^2 \mathrm{Var}(T \mid \theta)\\ via
  Samejima's (1974) polytomous information formula. This is the
  canonical reference for
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  under bounded `GPCM`.)

- Samejima, F. (1974). Normal ogive model on the continuous response
  level in the multidimensional latent space. *Psychometrika*, 39,
  111–121. (General polytomous information formula that Muraki 1993
  specializes to the GPCM.)

- Snijders, T. A. B. (2001). Asymptotic null distribution of person fit
  statistics with estimated person parameter. *Psychometrika*, 66(3),
  331–342. (Source for the `lz_star` correction in
  [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md)
  when person estimates come from the JML/fixed-effect route. MML/EAP
  person scores are left uncorrected because EAP does not satisfy the
  Snijders estimating-equation setup.)

- Linacre, J. M. (1989). *Many-facet Rasch measurement*. MESA Press.

- Linacre, J. M. (2002). What do Infit and Outfit, mean-square and
  standardized mean? *Rasch Measurement Transactions*, 16(2), 878.

- Masters, G. N. (1982). A Rasch model for partial credit scoring.
  *Psychometrika*, 47, 149–174.

- Orlando, M., & Thissen, D. (2000). Likelihood-based item-fit indices
  for dichotomous item response theory models. *Applied Psychological
  Measurement*, 24, 50–64.

- Orlando, M., & Thissen, D. (2003). Further investigation of the
  performance of S-X2: An item fit index for use with dichotomous item
  response theory models. *Applied Psychological Measurement*, 27,
  289–298.

- Sinharay, S., Johnson, M. S., & Stern, H. S. (2006). Posterior
  predictive assessment of item response theory models. *Applied
  Psychological Measurement*, 30, 298–321.

- Sinharay, S., & Monroe, S. (2025). Assessment of fit of item response
  theory models: A critical review of the status quo and some future
  directions. *British Journal of Mathematical and Statistical
  Psychology*, 78, 711–733.

- Wright, B. D., & Masters, G. N. (1982). *Rating scale analysis*. MESA
  Press.

- Wright, B. D., & Linacre, J. M. (1994). Reasonable mean-square fit
  values. *Rasch Measurement Transactions*, 8(3), 370.

- Wilson, E. B., & Hilferty, M. M. (1931). The distribution of
  chi-square. *Proceedings of the National Academy of Sciences of the
  United States of America*, 17(12), 684-688.

## Model selection

**RSM vs PCM**

The Rating Scale Model (RSM; Andrich, 1978) assumes all levels of the
step facet share identical threshold parameters. The Partial Credit
Model (PCM; Masters, 1982) allows each level of the `step_facet` to have
its own set of thresholds on the package's shared observed score scale.
Use RSM when the rating rubric is identical across all items/criteria;
use PCM when category boundaries are expected to vary by item or
criterion. In the current implementation, PCM assumes one common
observed score support across the fitted data, so it should not be
described as a fully mixed-category model with arbitrary item-specific
category counts.

**MML vs JML**

Marginal Maximum Likelihood (MML) integrates over the person ability
distribution using Gauss-Hermite quadrature and does not directly
estimate person parameters; person estimates are computed post-hoc via
Expected A Posteriori (EAP). Joint Maximum Likelihood (JML) estimates
all person and facet parameters simultaneously as fixed effects;
`"JMLE"` remains a backward-compatible alias.

MML is generally preferred for smaller samples because it avoids the
incidental-parameter problem of JML. JML does not assume a normal person
distribution and can be lighter computationally in some settings, which
may be an advantage when the population shape is strongly non-normal.

See
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for usage.

**Fixed-calibration scoring after fitting**

[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
and
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
score future or partially observed persons on a quadrature grid under
the fitted scoring basis. For ordinary `MML` fits, these summaries
inherit the fitted marginal calibration directly. For latent-regression
`MML` fits, they use the fitted one-dimensional conditional normal
population model and therefore require one-row-per-person background
data for the scored units when the fitted population model includes
covariates. Intercept-only latent-regression fits
(`population_formula = ~ 1`) can reconstruct that minimal person table
from the scored person IDs. For `JML` fits, `mfrmr` uses the fitted
facet and step parameters together with a standard normal reference
prior introduced only for the post hoc scoring layer. This is useful for
practical fixed-scale scoring, but it should still be described as a
limited approximation rather than as full ConQuest-style population
modeling.

**Current ConQuest overlap**

The package now includes a first-version latent-regression `MML` branch,
but the overlap with ConQuest should still be described conservatively.
The documented overlap is: ordered-response `RSM` / `PCM`, one latent
dimension, a conditional-normal person population model, and person
covariates supplied through an explicit one-row-per-person table and
expanded through the package-built model matrix. Categorical person
covariates carry fitted levels and contrasts into scoring. This is a
scoped overlap, not a claim of broad ConQuest numerical equivalence for
arbitrary imported design matrices, multidimensional models, imported
design specifications, or the full plausible-values workflow.

## See also

Useful links:

- <https://ryuya-dot-com.github.io/mfrmr/>

- <https://github.com/Ryuya-dot-com/mfrmr>

- Report bugs at <https://github.com/Ryuya-dot-com/mfrmr/issues>

## Author

**Maintainer**: Ryuya Komuro <ryuya.komuro.c4@tohoku.ac.jp>
([ORCID](https://orcid.org/0000-0001-9205-0926)) \[copyright holder\]

Authors:

- Ryuya Komuro <ryuya.komuro.c4@tohoku.ac.jp>
  ([ORCID](https://orcid.org/0000-0001-9205-0926)) \[copyright holder\]

## Examples

``` r
mfrm_threshold_profiles()
#> mfrmr Threshold Profile Summary
#> 
#> Overview
#>  Profiles ThresholdCount PCAReferenceCount DefaultProfile
#>         3             11                 7       standard
#> 
#> Profile thresholds
#>               Threshold strict standard lenient
#>        expected_var_min   0.30    2e-01    0.10
#>             low_cat_min  15.00    1e+01    5.00
#>        min_facet_levels   4.00    3e+00    2.00
#>       misfit_ratio_warn   0.08    1e-01    0.15
#>  missing_fit_ratio_warn   0.15    2e-01    0.30
#>               n_obs_min 200.00    1e+02   60.00
#>            n_person_min  50.00    3e+01   20.00
#>    pca_first_eigen_warn   1.50    2e+00    3.00
#>     pca_first_prop_warn   0.10    1e-01    0.20
#>        zstd2_ratio_warn   0.08    1e-01    0.15
#>        zstd3_ratio_warn   0.03    5e-02    0.08
#> 
#> Threshold ranges across profiles
#>               Threshold   Min Median    Max   Span
#>        expected_var_min  0.10  2e-01   0.30   0.20
#>             low_cat_min  5.00  1e+01  15.00  10.00
#>        min_facet_levels  2.00  3e+00   4.00   2.00
#>       misfit_ratio_warn  0.08  1e-01   0.15   0.07
#>  missing_fit_ratio_warn  0.15  2e-01   0.30   0.15
#>               n_obs_min 60.00  1e+02 200.00 140.00
#>            n_person_min 20.00  3e+01  50.00  30.00
#>    pca_first_eigen_warn  1.50  2e+00   3.00   1.50
#>     pca_first_prop_warn  0.10  1e-01   0.20   0.10
#>        zstd2_ratio_warn  0.08  1e-01   0.15   0.07
#>        zstd3_ratio_warn  0.03  5e-02   0.08   0.05
#> 
#> PCA reference bands
#>        Band              Key Value
#>  eigenvalue critical_minimum  1.40
#>  eigenvalue          caution  1.50
#>  eigenvalue           common  2.00
#>  eigenvalue           strong  3.00
#>  proportion            minor  0.05
#>  proportion          caution  0.10
#>  proportion           strong  0.20
#> 
#> Notes
#>  - Profiles tune warning strictness for build_visual_summaries().Use `thresholds` in build_visual_summaries() to override selected values.
list_mfrmr_data()
#> [1] "example_core"     "example_bias"     "study1"           "study2"          
#> [5] "combined"         "study1_itercal"   "study2_itercal"   "combined_itercal"

if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM",
  quad_points = 7
)
diag <- diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")
summary(diag)
} # }
```
