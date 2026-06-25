# mfrmr Workflow and Method Map

Quick reference for end-to-end `mfrmr` analysis and for checking which
output objects support
[`summary()`](https://rdrr.io/r/base/summary.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Canonical reporting route

For the clearest default route in `RSM` / `PCM`, use
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
with `method = "MML"` -\>
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
with `diagnostic_mode = "both"` -\>
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
-\>
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
and, when flagged,
[`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md)
/
[`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)
-\>
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
-\>
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
-\>
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
or
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).

Use `JML` only when you explicitly want a faster exploratory pass and
are willing to defer strict marginal follow-up and formal precision
language to a later `MML` run.

## Canonical operational review route

When the main question is scale maintenance rather than manuscript
reporting, branch after
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
into:
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
and/or
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
-\>
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
when adjacent-link review is needed -\>
[`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
-\> inspect `review$group_view_index` for stable wave / link / facet
rollups and `summary(review)$plot_routes` for the next plot helper -\>
[`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md)
or `plot(anchor_review, ...)` for the specific flagged evidence family.

For bounded `GPCM`, use
[`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
as a caveated exploratory synthesis over direct anchor, drift, and chain
evidence. It is not an operational `GPCM` linking decision or evidence
that anchor drift is absent.

## Canonical misfit case-review route

When the main question is which observations, facet levels, or pairwise
structures deserve follow-up, branch after
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
into:
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
-\> inspect `casebook$group_view_index`, `casebook$group_views`, and
`summary(casebook)$plot_routes` for stable person / facet / wave rollups
and the next plot helper -\>
[`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
[`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
or
[`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)
according to `casebook$plot_map` -\>
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
/
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
when the flagged cases need appendix-style reporting support.

[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
can still be used for bounded `GPCM`, but it should be read as an
operational exploratory screen rather than as a strict Rasch-style
invariance report.

## Latent-regression route

When the fit uses `population_formula = ...`, keep the distinction
between the estimator and the forecast helpers explicit:

- [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  estimates the current narrow latent-regression `MML` branch. In the
  returned fit object, `fit$population$person_table` is the
  complete-case estimation table, while
  `fit$population$person_table_replay` retains the
  observed-person-aligned pre-omit background-data table for
  replay/export provenance.

- [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  and
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  can then score under the fitted population model when scored units
  also supply one-row-per-person background data. That scoring-time
  `person_data` contract remains separate from the fit object's stored
  replay table.

- [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  remains a scenario-level simulation/refit helper rather than the
  latent-regression estimator itself.

## Score-category support

If the intended rating scale includes categories not observed in the
current data, make that support explicit. For example, use
`rating_min = 1, rating_max = 5` for a 1-5 scale with only 2-5 observed.
If an intermediate category is unobserved (for example 1, 2, 4, 5 with
no 3), also set `keep_original = TRUE` if the zero-count category should
remain in the fitted support. `summary(describe_mfrm_data(...))` reports
retained zero-count categories in `Notes`, printed `Caveats`, and
`$caveats`; `summary(fit)` carries full structured rows into printed
`Caveats` and `$caveats`, with `Key warnings` as a short triage subset.
Summary-table exports route those rows through `score_category_caveats`
or `analysis_caveats`. Adjacent threshold estimates should still be
treated as weakly identified when an intermediate category is
unobserved.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
    For final reporting, prefer `method = "MML"` unless you explicitly
    want a fast exploratory JML pass.

2.  (Optional) Use
    [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
    or
    [`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
    for a legacy-compatible one-shot workflow wrapper.

3.  For `RSM` / `PCM`, build diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
    For final reporting, prefer `diagnostic_mode = "both"` so the legacy
    residual path and the strict marginal screen remain visible side by
    side. For bounded `GPCM`, diagnostics are now available through
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    together with
    [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
    [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
    [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
    [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
    [`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
    [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
    [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md),
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
    and
    [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
    – the fair-average panel of the dashboard reports an explicit
    unavailability indicator under GPCM. Use
    [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
    directly when you need the supported slope-aware element-conditional
    fair averages. Treat those residual-based summaries as exploratory
    screens because the discrimination parameter is free. Full
    FACETS-style score-side contract review remains blocked for bounded
    `GPCM`; package-native scorefile export, fit-based reporting
    bundles, direct fair-average tables, and bias-screening tables carry
    their own caveats. Posterior scoring with
    [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
    /
    [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md),
    design-weighted information via
    [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
    /
    [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md),
    Wright/pathway/CCC plots via
    [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
    direct category reports via
    [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md)
    /
    [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md),
    and direct data generation through
    [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
    [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
    and
    [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)
    are also available when the simulation specification stores both
    thresholds and slopes. Use
    [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
    and
    [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
    for direct recovery checks plus caveated role-based design
    evaluation, population forecasting, diagnostic-screening, and
    signal-detection helpers. Caveated APA/QC/export bundles are
    available for sensitivity reporting, while score-side FACETS helpers
    remain outside the validated `GPCM` boundary. Use
    [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
    as the formal capability map before branching into less common
    helpers.

4.  (Optional, `RSM` / `PCM`; bounded `GPCM` with caveat) Estimate
    interaction bias with
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

5.  Choose a downstream branch:
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    for direct report preparation, or
    [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
    for Rasch-versus-bounded-`GPCM` weighting review, or
    [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
    /
    [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
    for operational case review. For bounded `GPCM`, use
    [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
    only as an exploratory index over direct anchor/drift/chain
    evidence.

6.  Generate reporting bundles:
    [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
    [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md),
    [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md).
    For bounded `GPCM`, use the APA, visual, QC, and fit-based export
    bundles as caveated sensitivity-reporting surfaces; full score-side
    FACETS review stays blocked, while diagnostic/signal-detection
    design screening has its own caveated operating-characteristic
    route.

7.  (Optional, `RSM` / `PCM`) Review report completeness with
    [`reference_case_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_review.md).
    Use
    [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md)
    only when you explicitly need the compatibility layer.

8.  (Optional, `RSM` / `PCM`) For operational linking follow-up, combine
    [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
    [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
    and
    [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
    inside
    [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
    before exporting appendix-style tables.

9.  (Optional) Check packaged reference cases with
    [`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md)
    when you want package-side reference checks.

10. (Optional) For design planning or future scoring, move to the
    simulation/prediction layer:
    [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
    /
    [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md)
    -\>
    [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
    -\>
    [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
    /
    [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
    /
    [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
    -\>
    [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
    /
    [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md).
    Current fit-derived simulation specs include direct `GPCM` data
    generation and recovery checks. Design-evaluation,
    population-forecasting, diagnostic- screening, and signal-detection
    helpers also support bounded `GPCM` as caveated role-based
    simulation/refit evidence; inspect `gpcm_boundary` before using
    those results in design claims. Unit scoring can use an ordinary
    `MML` fit directly, a latent-regression `MML` fit when you also
    supply one-row-per-person background data for the scored units, or a
    `JML` fit when a post hoc reference-prior EAP layer is acceptable.
    Intercept-only latent-regression fits (`population_formula = ~ 1`)
    can reconstruct that minimal person table from the scored person
    IDs. Keep
    [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
    conceptually separate from that scoring layer: it is a
    simulation-based scenario forecast helper, not the latent-regression
    estimator itself. Prediction export still requires actual prediction
    objects in addition to `include = "predictions"`.

11. Use [`summary()`](https://rdrr.io/r/base/summary.html) for compact
    text checks and
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html) (or
    dedicated plot helpers) for base-R visual diagnostics.

## Three practical routes

- Quick first pass: `RSM` / `PCM`:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  when you want the package to route the next figures. bounded `GPCM`:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
  /
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
  -\>
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
  -\>
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  -\>
  [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
  -\>
  [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  /
  [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md)
  -\>
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  /
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  when those screening tables answer the question. For bounded `GPCM`,
  the fit-based export family
  ([`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
  [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md),
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md))
  is available as caveated sensitivity-reporting output with explicit
  `gpcm_boundary` rows.

- Linking and coverage review:
  [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
  -\> `plot(..., type = "design_matrix")` -\>
  [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md).

- Manuscript prep: `RSM` / `PCM`:
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\> inspect the `"Visual Displays"` and `"Method Section"` rows -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  -\>
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  -\>
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  or
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).
  First-release `GPCM`:
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\> direct table/plot helpers -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  /
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
  -\>
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  with `gpcm_boundary` caveats.

- Weighting-policy review:
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  -\>
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  -\>
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  /
  [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
  when you want to inspect whether bounded `GPCM` is introducing
  substantively acceptable discrimination-based reweighting relative to
  the Rasch-family reference.

- Design planning and forecasting:
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  or
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md)
  -\>
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
  -\>
  [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
  for parameter-recovery checks, then
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  -\>
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  -\>
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  or
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  under the fitted scoring basis (ordinary `MML`, latent-regression
  `MML` with person-level background data, or `JML` with the documented
  post hoc EAP approximation). Here again,
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  is the scenario-level forecast helper, whereas
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  /
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  are the scoring layer. Prediction export requires actual prediction
  objects. First-release `GPCM` now supports direct data generation via
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
  and
  [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md),
  [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md),
  caveated role-based design evaluation and population forecasting,
  diagnostic/signal-detection design screening, residual diagnostics,
  and direct curve/report helpers. The current planning layer remains
  role-based for two non-person facets even though estimation itself
  supports arbitrary facet counts; future arbitrary-facet planning
  fields should be treated as design metadata rather than finished
  public behavior.

## Interpreting output

This help page is a map, not an estimator:

- use it to decide function order,

- confirm which objects have
  [`summary()`](https://rdrr.io/r/base/summary.html)/[`plot()`](https://rdrr.io/r/graphics/plot.default.html)
  defaults,

- identify when dedicated helper functions are needed,

- and treat
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  as the package's readiness router for plot and report follow-up.

## Objects with default [`summary()`](https://rdrr.io/r/base/summary.html) and [`plot()`](https://rdrr.io/r/graphics/plot.default.html) routes

- `mfrm_fit`: `summary(fit)` and `plot(fit, ...)`.

- `mfrm_diagnostics`: `summary(diag)`; plotting via dedicated helpers
  such as
  [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
  [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md).

- `mfrm_bias`: `summary(bias)` and
  [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md).

- `mfrm_data_description`: `summary(ds)` and `plot(ds, ...)`.

- `mfrm_anchor_review`: `summary(review)` and `plot(review, ...)`.

- `mfrm_misfit_casebook`: `summary(casebook)` and `print(casebook)`,
  with grouping views available through `casebook$group_view_index` and
  `casebook$group_views`, source-specific plotting routed through
  `summary(casebook)$plot_routes` and `casebook$plot_map`, and
  appendix/report handoff available through
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  and
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).

- `mfrm_weighting_review`: `summary(review)` and `print(review)`, with
  information follow-up routed through
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  and
  [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
  according to `review$plot_map`, and appendix/report handoff available
  through
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  and
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).

- `mfrm_linking_review`: `summary(review)` and `print(review)`, with
  grouping views available through `review$group_view_index` and
  `review$group_views`, and plotting routed through
  `summary(review)$plot_routes`,
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md),
  and `plot(anchor_review, ...)` according to `review$plot_map`.

- `mfrm_facets_run`: `summary(run)` and
  `plot(run, type = c("fit", "qc"), ...)`.

- `apa_table`: `summary(tbl)` and `plot(tbl, ...)`.

- `mfrm_apa_outputs`: `summary(apa)` for compact diagnostics of report
  text.

- `mfrm_summary_table_bundle`: `print(bundle)` for manuscript-oriented
  table index plus named tables from supported
  [`summary()`](https://rdrr.io/r/base/summary.html) outputs,
  `summary(bundle)` for table-role/numeric coverage, and
  `plot(bundle, ...)` for table-size or numeric-column QC.

- `mfrm_threshold_profiles`: `summary(profiles)` for preset threshold
  grids.

- `mfrm_population_prediction`: `summary(pred)` for design-level
  forecast tables.

- `mfrm_unit_prediction`: `summary(pred)` for unit-level posterior
  summaries under the fitted scoring basis.

- `mfrm_plausible_values`: `summary(pv)` for draw-level uncertainty
  summaries.

- `mfrm_bundle` families:
  [`summary()`](https://rdrr.io/r/base/summary.html) and class-aware
  `plot(bundle, ...)`. Key bundle classes now also use class-aware
  `summary(bundle)`: `mfrm_unexpected`, `mfrm_fair_average`,
  `mfrm_displacement`, `mfrm_interrater`, `mfrm_facets_chisq`,
  `mfrm_bias_interaction`, `mfrm_rating_scale`,
  `mfrm_category_structure`, `mfrm_category_curves`, `mfrm_measurable`,
  `mfrm_unexpected_after_bias`, `mfrm_output_bundle`,
  `mfrm_residual_pca`, `mfrm_specifications`, `mfrm_data_quality`,
  `mfrm_iteration_report`, `mfrm_subset_connectivity`,
  `mfrm_facet_statistics`, `mfrm_facets_contract_review`,
  `mfrm_reference_review`, `mfrm_reference_benchmark`.

## [`plot.mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bundle.md) coverage

Default dispatch now covers:

- `mfrm_unexpected`, `mfrm_fair_average`, `mfrm_displacement`

- `mfrm_interrater`, `mfrm_facets_chisq`, `mfrm_bias_interaction`

- `mfrm_bias_count`, `mfrm_fixed_reports`, `mfrm_visual_summaries`

- `mfrm_category_structure`, `mfrm_category_curves`, `mfrm_rating_scale`

- `mfrm_measurable`, `mfrm_unexpected_after_bias`, `mfrm_output_bundle`

- `mfrm_residual_pca`, `mfrm_specifications`, `mfrm_data_quality`

- `mfrm_iteration_report`, `mfrm_subset_connectivity`,
  `mfrm_facet_statistics`

- `mfrm_facets_contract_review`, `mfrm_reference_review`,
  `mfrm_reference_benchmark`

For unknown bundle classes, use dedicated plotting helpers or custom
base-R plots from component tables.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
[`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md),
[gpcm_capability_matrix](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
`summary(diag)`, [`summary()`](https://rdrr.io/r/base/summary.html),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

## Examples

``` r
if (FALSE) { # \dontrun{
toy_full <- load_mfrmr_data("example_core")
keep_people <- unique(toy_full$Person)[1:12]
toy <- toy_full[toy_full$Person %in% keep_people, , drop = FALSE]

fit <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  quad_points = 7,
  maxit = 30
)
summary(fit)$next_actions

diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
summary(diag)$next_actions

chk <- reporting_checklist(fit, diagnostics = diag)
subset(
  chk$checklist,
  Section == "Visual Displays",
  c("Item", "DraftReady", "NextAction")
)

qc <- plot_qc_dashboard(fit, diagnostics = diag, draw = FALSE, preset = "publication")
qc$data$preset
p_marg <- plot_marginal_fit(diag, draw = FALSE, preset = "publication")
p_marg$data$preset

sc <- subset_connectivity_report(fit, diagnostics = diag)
p_design <- plot(sc, type = "design_matrix", draw = FALSE, preset = "publication")
p_design$data$plot

bundle <- build_summary_table_bundle(chk, appendix_preset = "recommended")
summary(bundle)$role_summary
plot(bundle, type = "appendix_presets", draw = FALSE)$data$plot
} # }
```
