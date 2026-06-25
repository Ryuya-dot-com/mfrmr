# Package index

## Primary workflow

Start here for routine fit, first-screen results, reports, and exports.

- [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
  : Load a packaged simulation dataset

- [`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/list_mfrmr_data.md)
  : List packaged simulation datasets

- [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  : Summarize MFRM input data (TAM-style descriptive snapshot)

- [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  : Fit many-facet ordered-response models with a flexible number of
  facets

- [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  :

  Compute diagnostics for an `mfrm_fit` object

- [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  : Build comprehensive first-screen MFRM results

- [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  :

  Build report-ready output from
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)

- [`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
  : Export a lightweight mfrm_results archive

- [`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
  : Choose an mfrmr output helper by user goal

- [`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md)
  : Confidence-interval and uncertainty route guide

## Bounded GPCM boundary

Supported, caveated, blocked, and deferred bounded-GPCM routes.

- [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
  : Bounded GPCM Support Matrix
- [`gpcm_runtime_guard_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_runtime_guard_coverage.md)
  : Bounded GPCM Route-Boundary Coverage
- [`gpcm_score_side_contract()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_score_side_contract.md)
  : Bounded GPCM Score-Side Export Contract
- [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
  : Build a model-choice review across RSM, PCM, and bounded GPCM fits
- [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  : Build a weighting-policy review between Rasch-family and bounded
  GPCM fits
- [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  : Compute design-weighted precision curves for ordered many-facet fits
- [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
  : Plot design-weighted precision curves
- [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md)
  : Build a category structure report (preferred alias)
- [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md)
  : Build a category curve export bundle (preferred alias)

## Diagnostics and quality control

Fit review, residual diagnostics, precision, agreement, and QC
dashboards.

- [`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md)
  : Build a FACETS-style fit-measures review table
- [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
  : Facet-quality dashboard for facet-level screening
- [`anchor_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_accessors.md)
  [`precision_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_accessors.md)
  : Extract canonical review components
- [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  : Build a precision review report
- [`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md)
  : Build a measurable-data summary
- [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
  : Build a rating-scale diagnostics report
- [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  : Build an inter-rater agreement report
- [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
  : Build an unexpected-response screening report
- [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)
  : Compute displacement diagnostics for facet levels
- [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
  : Run exploratory residual PCA summaries
- [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md)
  : Person fit indices: lz and Snijders-corrected lz\*
- [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md)
  : Run automated quality control pipeline
- [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
  : Plot a base-R QC dashboard
- [`plot_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_pipeline.md)
  : Plot QC pipeline results

## Reporting, tables, and exports

Manuscript-ready tables, visual summaries, appendices, and replay
bundles.

- [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  : Build an auto-filled MFRM reporting checklist

- [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  : Build APA text outputs from model results

- [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
  : Build warning and narrative summaries for visual outputs

- [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  :

  Build a manuscript-oriented table bundle from
  [`summary()`](https://rdrr.io/r/base/summary.html) outputs

- [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
  : Export manuscript appendix tables from validated summary surfaces

- [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md)
  : Build a reproducibility manifest for an MFRM analysis

- [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md)
  : Build a package-native replay script for an MFRM analysis

- [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  : Export an analysis bundle for sharing or archiving

- [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  : Build APA-style table output using base R structures

- [`as_kable()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_kable.md)
  :

  Generic for converting objects to a
  [`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html)

- [`as_flextable()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_flextable.md)
  :

  Generic for converting objects to a `flextable`

- [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
  : Extract reusable data from an mfrmr plot object

- [`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
  : List reusable components in mfrmr plot data

## Simulation, design, and recovery

Design review, bounded-GPCM recovery checks, and future-administration
scenarios.

- [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  : Build an explicit simulation specification for MFRM design studies
- [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)
  : Simulate long-format ordered many-facet data for design studies
- [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md)
  : Derive a simulation specification from a fitted MFRM object
- [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
  : Evaluate parameter recovery by repeated simulation and refitting
- [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
  [`plot(`*`<mfrm_recovery_assessment>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
  : Assess whether recovery-simulation results are ready to use
- [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  : Evaluate MFRM design conditions by repeated simulation
- [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
  : Evaluate legacy and strict marginal diagnostic screening under
  controlled misfit scenarios
- [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md)
  : Evaluate DIF power and bias-screening behavior under known simulated
  signals
- [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  : Forecast population-level MFRM operating characteristics for one
  future design
- [`build_mfrm_resampling_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_resampling_spec.md)
  : Build an observed-data resampling specification
- [`draw_mfrm_resamples()`](https://ryuya-dot-com.github.io/mfrmr/reference/draw_mfrm_resamples.md)
  : Draw observed-data MFRM resamples

## Linking, bias, and DFF screening

Anchor review, linking synthesis, residual-bias screening, and
differential-functioning review.

- [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)
  : Build an anchor table from fitted estimates
- [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
  : Review and normalize anchor/group-anchor tables
- [`anchor_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_accessors.md)
  [`precision_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_accessors.md)
  : Extract canonical review components
- [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  [`print(`*`<mfrm_anchored_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  [`summary(`*`<mfrm_anchored_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  [`print(`*`<summary.mfrm_anchored_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  : Fit new data anchored to a baseline calibration
- [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  [`print(`*`<mfrm_anchor_drift>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  [`summary(`*`<mfrm_anchor_drift>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  [`print(`*`<summary.mfrm_anchor_drift>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  : Detect anchor drift across multiple calibrations
- [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  [`print(`*`<mfrm_equating_chain>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  [`plot(`*`<mfrm_equating_chain>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  [`summary(`*`<mfrm_equating_chain>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  [`print(`*`<summary.mfrm_equating_chain>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  : Build a screened linking chain across ordered calibrations
- [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  : Build a linking-review synthesis object
- [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  : Estimate bias and interaction screening terms
- [`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
  : Estimate bias across multiple facet pairs
- [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  : Differential facet functioning analysis
- [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md)
  : Compute interaction table between a facet and a grouping variable
- [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)
  : Generate a differential-functioning interpretation report

## FACETS and related-package migration

FACETS handoff, external-table review, and related package import
adapters.

- [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md)
  : FACETS Positioning Guide

- [`facets_feature_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_feature_coverage.md)
  : FACETS Feature Coverage Matrix

- [`facets_fit_df_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_df_guide.md)
  : Guide FACETS-style fit df and ZSTD standardization

- [`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
  : Review fit standardization against FACETS-style ZSTD conventions

- [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)
  :

  Build a legacy-compatible output-file bundle (`GRAPH=` / `SCORE=`)

- [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md)
  : Build a FACETS output-contract review

- [`read_facets_fit_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_fit_table.md)
  [`import_facets_fit_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_fit_table.md)
  : Read a FACETS fit table for fit review

- [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  [`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  : Run a legacy-compatible estimation workflow wrapper

- [`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md)
  :

  Import an `mirt` fit to an mfrmr-compatible bundle

- [`import_tam_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_tam_fit.md)
  :

  Import a `TAM` fit to an mfrmr-compatible bundle

- [`import_erm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_erm_fit.md)
  :

  Import an `eRm` fit to an mfrmr-compatible bundle

## Advanced reviews and visualization

Specialist plots, S3 methods, network reviews, reliability, shrinkage,
and compatibility helpers.

- [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md)
  : Plot anchor drift or a screened linking chain

- [`plot_apa_figure_one()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_apa_figure_one.md)
  : Manuscript-ready four-panel composite (Wright + severity +
  threshold + summary)

- [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)
  : Plot bias interaction diagnostics (preferred alias)

- [`plot_bubble()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bubble.md)
  : Bubble chart of measure estimates and fit statistics

- [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md)
  : Plot a differential-functioning heatmap

- [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md)
  : Summary plot of differential functioning effect sizes

- [`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md)
  : Plot facet-equivalence results

- [`plot_facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_quality_dashboard.md)
  : Plot a facet-quality dashboard

- [`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md)
  : Plot facet variability diagnostics using base R

- [`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md)
  : Plot fair-average diagnostics using base R

- [`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md)
  : Guttman-style scalogram of person x item observed responses

- [`plot_local_dependence_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_local_dependence_heatmap.md)
  : Pairwise standardized-residual heatmap for local-dependence review

- [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md)
  : Plot strict marginal-fit follow-up cells using base R

- [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)
  : Plot strict pairwise local-dependence follow-up using base R

- [`plot_person_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_person_fit.md)
  : Plot per-person fit

- [`plot_rater_agreement_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_agreement_heatmap.md)
  : Pairwise rater-agreement heatmap

- [`plot_rater_severity_profile()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_severity_profile.md)
  : Plot per-rater severity ranking with confidence interval whiskers

- [`plot_rater_trajectory()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_trajectory.md)
  : Rater-severity trajectory across an ordered wave / occasion variable

- [`plot_reliability_snapshot()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_reliability_snapshot.md)
  : Facet reliability and separation snapshot bar plot

- [`plot_response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_response_time_review.md)
  : Plot response-time review summaries

- [`plot_shrinkage_funnel()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_shrinkage_funnel.md)
  : Empirical-Bayes shrinkage funnel / caterpillar

- [`plot_threshold_ladder()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_threshold_ladder.md)
  : Plot RSM/PCM threshold ladders with disorder highlighting

- [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md)
  : Plot unexpected responses using base R

- [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md)
  : Plot a unified Wright map with all facets on a shared logit scale

- [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md)
  : Analyze practical equivalence within a facet

- [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
  : Analyze the hierarchical structure of a rating design

- [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
  : Apply empirical-Bayes shrinkage to fitted non-person facet estimates

- [`as.data.frame(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/as.data.frame.mfrm_fit.md)
  : Convert mfrm_fit to a tidy data.frame

- [`as_flextable(`*`<apa_table>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/as_flextable.apa_table.md)
  :

  Convert an `apa_table` to a `flextable`

- [`as_kable(`*`<apa_table>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/as_kable.apa_table.md)
  :

  Convert an `apa_table` to a
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html) object

- [`bias_count_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_count_table.md)
  : Build a bias-cell count report

- [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
  : Build a bias-interaction plot-data bundle (FACETS Table 13: ranked
  bias list)

- [`bias_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_iteration_report.md)
  : Build a bias-iteration report (FACETS Table 9: iteration /
  convergence trace)

- [`bias_pairwise_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_pairwise_report.md)
  : Build a bias pairwise-contrast report (FACETS Table 14: pairwise
  contrasts)

- [`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md)
  : Build a scoped ConQuest-overlap bundle

- [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md)
  : Build legacy-compatible fixed-width text reports

- [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
  : Build a case-level misfit review bundle

- [`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md)
  : Build an MFRM network review

- [`build_peer_review_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_peer_review_sim_spec.md)
  : Build a peer-review simulation specification

- [`build_peer_review_design_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_peer_review_design_review.md)
  : Build a peer-review design review

- [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  : Compare two or more fitted MFRM models

- [`compatibility_alias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/compatibility_alias_table.md)
  : List retained compatibility aliases and preferred names

- [`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md)
  : Compute Kish design effects for each facet

- [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  : Compute intra-class correlations for each facet

- [`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md)
  : Build a data quality summary report (preferred alias)

- [`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md)
  : Detect nesting structure between facets

- [`ej2021_data`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_study1`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_study2`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_combined`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_study1_itercal`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_study2_itercal`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_combined_itercal`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  : Simulated MFRM datasets based on Eckes and Jin (2021)

- [`estimation_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimation_iteration_report.md)
  : Build an estimation-iteration report (preferred alias)

- [`export_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm.md)
  : Export MFRM results to CSV files

- [`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md)
  : Review per-facet-level sample adequacy

- [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md)
  : Build a facet statistics report (preferred alias)

- [`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_chisq_table.md)
  : Build facet variability diagnostics with fixed/random reference
  tests

- [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  : Build an adjusted-score reference table bundle

- [`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interaction_effect_table.md)
  : Extract model-estimated facet interaction effects

- [`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_misfit_thresholds.md)
  : MnSq misfit threshold pair used across mfrmr screening helpers

- [`mfrm_results_interactive()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results_interactive.md)
  :

  Interactively choose data-frame columns before calling
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)

- [`mfrm_threshold_profiles()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md)
  : List literature-based warning threshold profiles

- [`mfrmr`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
  [`mfrmr-package`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
  : mfrmr: Many-Facet Ordered-Response Modeling in R

- [`mfrmr_compatibility_layer`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
  : mfrmr Compatibility Layer Map

- [`mfrmr_example_data`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_example_data.md)
  [`mfrmr_example_core`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_example_data.md)
  [`mfrmr_example_bias`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_example_data.md)
  : Purpose-built example datasets for package help pages

- [`mfrmr_linking_and_dff`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)
  : mfrmr Linking and DFF Guide

- [`mfrmr_reporting_and_apa`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)
  : mfrmr Reporting and APA Guide

- [`mfrmr_reports_and_tables`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md)
  : mfrmr Reports and Tables Map

- [`mfrmr_visual_diagnostics`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
  : mfrmr Visual Diagnostics Map

- [`mfrmr_workflow_methods`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
  : mfrmr Workflow and Method Map

- [`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_files.md)
  :

  Normalize extracted ConQuest overlap files to the `mfrmr` review
  contract

- [`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md)
  :

  Normalize extracted ConQuest overlap tables to the `mfrmr` review
  contract

- [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md)
  : Analyze the MFRM design network

- [`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
  : Analyze rater agreement, disagreement, and severity-direction
  networks

- [`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
  : Analyze rater-by-criterion halo-effect networks

- [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  : Project G-theory coefficients under alternative D-study designs

- [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  : Generalizability-theory variance decomposition for an MFRM design

- [`plot(`*`<apa_table>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.apa_table.md)
  : Plot an APA/FACETS table object using base R

- [`plot(`*`<mfrm_anchor_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_anchor_review.md)
  : Plot an anchor-review object

- [`plot(`*`<mfrm_bundle>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bundle.md)
  : Plot report/table bundles with base R defaults

- [`plot(`*`<mfrm_data_description>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_data_description.md)
  : Plot a data-description object

- [`plot(`*`<mfrm_design_evaluation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_design_evaluation.md)
  : Plot a design-simulation study

- [`plot(`*`<mfrm_diagnostic_screening>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_diagnostic_screening.md)
  : Plot a diagnostic-screening validation study

- [`plot(`*`<mfrm_facet_nesting>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_facet_nesting.md)
  : Plot the pairwise nesting index matrix

- [`plot(`*`<mfrm_facet_sample_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_facet_sample_review.md)
  : Plot a facet sample-size review

- [`plot(`*`<mfrm_facets_run>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_facets_run.md)
  : Plot outputs from a legacy-compatible workflow run

- [`plot(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  : Plot fitted MFRM results with base R

- [`plot(`*`<mfrm_future_branch_active_branch>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_future_branch_active_branch.md)
  : Plot a future arbitrary-facet planning active branch

- [`plot(`*`<mfrm_recovery_simulation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_recovery_simulation.md)
  : Plot parameter-recovery simulation results

- [`plot(`*`<mfrm_signal_detection>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_signal_detection.md)
  : Plot DIF/bias screening simulation results

- [`plot(`*`<mfrm_summary_table_bundle>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_summary_table_bundle.md)
  : Plot a summary-table bundle for manuscript QC

- [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md)
  : Plot displacement diagnostics using base R

- [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md)
  : Plot inter-rater agreement diagnostics using base R

- [`plot_residual_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_matrix.md)
  : Person x facet-level standardized-residual matrix

- [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md)
  : Visualize residual PCA results

- [`plot_residual_qq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_qq.md)
  : Normal quantile-quantile plot of person standardized residuals

- [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  : Score future or partially observed units under the fitted scoring
  basis

- [`print(`*`<mfrm_apa_text>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/print.mfrm_apa_text.md)
  : Print APA narrative text with preserved line breaks

- [`q3_statistic()`](https://ryuya-dot-com.github.io/mfrmr/reference/q3_statistic.md)
  : Yen-style Q3 local-dependence statistic between facet levels

- [`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
  :

  Recode common missing-value sentinels to `NA`

- [`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md)
  : Recommend a design condition from simulation results

- [`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md)
  : Benchmark packaged reference cases

- [`reference_case_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_review.md)
  : Build a package-native reference review for report completeness

- [`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md)
  :

  Review an exact-overlap ConQuest comparison against an `mfrmr` overlap
  bundle

- [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
  : Review response-time patterns outside the MFRM likelihood

- [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  : Sample approximate plausible values under fitted posterior scoring

- [`shrinkage_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/shrinkage_report.md)
  : Extract the shrinkage report from a fitted mfrm_fit

- [`specifications_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/specifications_report.md)
  : Build a specification summary report (preferred alias)

- [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
  : Build a subset connectivity report (preferred alias)

- [`summary(`*`<apa_table>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.apa_table.md)
  : Summarize an APA/FACETS table object

- [`summary(`*`<mfrm_anchor_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_anchor_review.md)
  : Summarize an anchor-review object

- [`summary(`*`<mfrm_apa_outputs>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_apa_outputs.md)
  : Summarize APA report-output bundles

- [`summary(`*`<mfrm_bias>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_bias.md)
  :

  Summarize an `mfrm_bias` object in a user-friendly format

- [`summary(`*`<mfrm_bundle>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_bundle.md)
  : Summarize report/table bundles in a user-friendly format

- [`summary(`*`<mfrm_data_description>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_data_description.md)
  : Summarize a data-description object

- [`summary(`*`<mfrm_design_evaluation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md)
  : Summarize a design-simulation study

- [`summary(`*`<mfrm_diagnostic_screening>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_diagnostic_screening.md)
  : Summarize a diagnostic-screening validation study

- [`summary(`*`<mfrm_diagnostics>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_diagnostics.md)
  :

  Summarize an `mfrm_diagnostics` object in a user-friendly format

- [`summary(`*`<mfrm_facet_dashboard>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_facet_dashboard.md)
  : Summarize a facet-quality dashboard

- [`summary(`*`<mfrm_facets_run>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_facets_run.md)
  : Summarize a legacy-compatible workflow run

- [`summary(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)
  :

  Summarize an `mfrm_fit` object in a user-friendly format

- [`summary(`*`<mfrm_future_branch_active_branch>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_future_branch_active_branch.md)
  : Summarize a future arbitrary-facet planning active branch

- [`summary(`*`<mfrm_linking_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_linking_review.md)
  : Summarize a linking-review object

- [`summary(`*`<mfrm_misfit_casebook>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_misfit_casebook.md)
  : Summarize a misfit-casebook object

- [`summary(`*`<mfrm_model_choice_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_model_choice_review.md)
  : Summarize a model-choice review

- [`summary(`*`<mfrm_network_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_network_review.md)
  : Summarize an MFRM network review

- [`summary(`*`<mfrm_peer_review_design_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_peer_review_design_review.md)
  : Summarize a peer-review design review

- [`summary(`*`<mfrm_person_fit_indices>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_person_fit_indices.md)
  : Summarize person-fit indices

- [`summary(`*`<mfrm_plausible_values>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_plausible_values.md)
  : Summarize approximate plausible values from posterior scoring

- [`summary(`*`<mfrm_population_prediction>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_population_prediction.md)
  : Summarize a population-level design forecast

- [`summary(`*`<mfrm_reporting_checklist>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_reporting_checklist.md)
  : Summarize a reporting-checklist bundle for manuscript work

- [`summary(`*`<mfrm_response_time_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_response_time_review.md)
  : Summarize a response-time review

- [`summary(`*`<mfrm_signal_detection>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_signal_detection.md)
  : Summarize a DIF/bias screening simulation

- [`summary(`*`<mfrm_summary_table_bundle>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_summary_table_bundle.md)
  : Summarize a summary-table bundle for manuscript QC

- [`summary(`*`<mfrm_threshold_profiles>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_threshold_profiles.md)
  : Summarize threshold-profile presets for visual warning logic

- [`summary(`*`<mfrm_unit_prediction>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_unit_prediction.md)
  : Summarize posterior unit scoring output

- [`summary(`*`<mfrm_weighting_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_weighting_review.md)
  : Summarize a weighting-review object

- [`unexpected_after_bias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_after_bias_table.md)
  : Build an unexpected-after-adjustment screening report

- [`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md)
  : Figure-reporting template for visual diagnostics

- [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md)
  : Write a standalone residual file

- [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md)
  : Write standalone subset-connectivity files

- [`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md)
  : Launch a local Shiny viewer for an mfrm_results object
