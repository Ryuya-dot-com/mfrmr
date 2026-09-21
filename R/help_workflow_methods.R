#' mfrmr Workflow and Method Map
#'
#' @description
#' Start with one analysis: load ratings, fit a model, plot the results, and
#' read the summary. The Examples section contains a complete runnable script.
#' The later sections describe diagnostics, reporting, and specialist routes.
#'
#' @section Start here:
#' 1. Load the package with `library(mfrmr)` and example ratings with
#'    `toy <- load_mfrmr_data("example_operational")`.
#' 2. Fit with [fit_mfrm()]. The `person`, `facets`, and `score` arguments
#'    name columns in the data; each row represents one rating event.
#' 3. Draw the Wright map with `plot(fit)` to view person abilities, rater
#'    severities, criterion difficulties, and category thresholds together.
#' 4. Save `results <- summary(fit)` and inspect `results$person_overview`
#'    and `results$facet_overview` for the distributions of estimates.
#'
#' These overview tables summarize distributions. Use `as.data.frame(fit)`
#' for individual person, rater, and criterion estimates, identified by
#' `Facet` and `Level`. Before interpreting or reporting estimates, read
#' `results$decision` and follow its `NextAction`; the default summary does
#' not compute diagnostics. For your own data, first check the rating design
#' and score categories with [describe_mfrm_data()].
#' `head(toy)` shows the input rows; `Study` and `Group` are extra labels unused
#' by this model. `<-` saves an object and `$` selects a named part of it.
#'
#' @section Use your own ratings:
#' The "Use your own CSV" section of
#' `vignette("mfrmr-workflow", package = "mfrmr")` covers CSV import,
#' column-name mapping, and reshaping a sheet with separate criterion columns.
#' The following help pages are also available without an installed vignette:
#' - [describe_mfrm_data()] explains input and retained row counts, category
#'   usage, connectedness, and how to follow up input problems.
#' - [recode_missing_codes()] shows how to replace documented missing-score
#'   markers while preserving person and rater IDs.
#' - [summary.mfrm_data_description()] shows a missing-score example and
#'   explains the full data checks versus their compact summary tables.
#'
#' Set the score bounds from your rubric and use the same columns, bounds,
#' and `keep_original` setting for the review and the fit. Reviewing data does
#' not change the original ratings. After correcting or recoding them, repeat
#' the review and pass the corrected data frame to [fit_mfrm()]. A
#' `data_review` object contains checks; it is not the rating data to fit.
#'
#' @section From the first summary to diagnostics:
#' A `FormalInference = "No"` entry in `results$decision` can mean that precision
#' has not yet been reviewed. Read `Why` and `NextAction` to distinguish that
#' state from a detected problem. Run `diagnostics <- diagnose_mfrm(fit)` and
#' inspect `summary(diagnostics)$decision`. To reuse these checks in the fuller
#' reporting object, call `res <- mfrm_results(fit, diagnostics = diagnostics)`.
#' Here `results` is the basic summary and `res` is the comprehensive object
#' accepted by [mfrm_report()] and [export_mfrm_results()].
#'
#' @section Updating saved analyses for 0.2.4:
#' Keep the original objects, data and analysis settings. Installing an update
#' does not recalculate saved tables, figures or reports. Start by printing
#' `summary(fit)` under the updated package and reading its interpretation
#' decision. If the saved native fit lacks the current estimation checks,
#' refit from the original data with the same intended model, category coding,
#' anchors, weights and numerical settings. Running [diagnose_mfrm()] alone
#' cannot establish checks missing from that fit. If the original data or
#' settings are unavailable, retain the old result as historical output;
#' its previous approval is not evidence for current inferential use.
#'
#' For a fit with current estimation checks, update the affected result at
#' the earliest step below, then rebuild its dependent summaries, plots and
#' exports. A request to recompute diagnostics or scoring does not itself
#' require a new calibration fit.
#'
#' - **Display wording only:** reprint a saved fit summary. This updates labels
#'   and removes the duplicate inference decision; it does not recalculate
#'   stored diagnostics or establish missing precision evidence.
#' - **Diagnostics and QC:** recreate [diagnose_mfrm()] results with the original
#'   diagnostic settings before rebuilding reliability, precision, category,
#'   marginal-fit, person-fit, unexpected-response, fair-score and reporting
#'   results. Rerun separately requested [q3_statistic()],
#'   [analyze_residual_pca()] and [compute_person_fit_indices()] calculations
#'   with their original options. In [run_qc_pipeline()], request
#'   `separation_facets` only for facets whose levels need to be distinguished;
#'   it is no longer a default rater-quality requirement. Missing results remain
#'   unavailable and cannot be treated as passes.
#' - **Group comparisons and equivalence:** recreate residual [analyze_dff()]
#'   / [analyze_dif()] and [dif_interaction_table()] results from the existing
#'   fit and original group data. They now describe residual differences without
#'   tests or confidence intervals. Recompute [analyze_facet_equivalence()]
#'   from an eligible MML fit with matching current diagnostics and the original
#'   practical bound; old equivalence bundles cannot supply the required joint
#'   covariance. Rebuild model-choice and weighting reviews from their source
#'   fits as well.
#' - **ICC and design effects:** rerun [compute_facet_icc()] or
#'   [analyze_hierarchical_structure()] from the original data and settings.
#'   Numeric score labels now retain their values. Missing scores or grouping
#'   values require an explicit `missing = "omit"` choice; malformed scores
#'   must be corrected. Inspect `attr(icc, "data_usage")`, then recreate
#'   [compute_facet_design_effect()] using the new ICC result. Older ICC
#'   tables lack the row accounting needed to calculate matching sample sizes.
#'   Recalculation also removes the fixed variance cutoff tied to score units
#'   and preserves small positive variances without decimal rounding. Constant
#'   retained scores have unavailable variance components and ICCs. Design
#'   effects remain per-facet approximations; their equivalent row counts do
#'   not estimate the precision of a complete crossed or unbalanced design.
#'   The former `ci_method = "profile"` transformed separate component bounds
#'   and did not calculate a profile-likelihood interval for the ICC ratio.
#'   Choose `"boot"` explicitly for parametric percentile intervals, then read
#'   `ICC_CI_Status` and `attr(icc, "icc_ci")`. Failed or nonconverged refits
#'   and fit warnings withhold intervals. Saved bootstrap results also require
#'   rerunning to obtain complete failure accounting and identify
#'   constant-response refits, which withhold intervals; reprinting is insufficient.
#' - **Observed-score design coefficients and shrinkage:** rerun
#'   [mfrm_generalizability()] with its original data and settings, then
#'   [mfrm_d_study()] with the planned counts and residual-scaling choice.
#'   This re-estimates the separate observed-score mixed model, not the MFRM.
#'   Reapply [apply_empirical_bayes_shrinkage()] with the original prior settings
#'   to refresh shrinkage reports and descriptive bands.
#' - **Fitted-object Person scores:** re-summarize the original prediction object
#'   to recover stored interval settings and updated explanations. To replace
#'   older grid-endpoint intervals with continuous posterior intervals, rerun
#'   [predict_mfrm_units()] using the existing fit, scoring data and settings.
#'   Reprinting cannot change an already calculated interval. Rerun scoring
#'   when older estimated-population results lack numerical prior information
#'   or are refused because they claimed unrestricted scoring; these fits
#'   require explicit `readiness_policy = "review"`.
#' - **Plausible values:** use `summary(original_plausible_values)` on the saved
#'   draw object to obtain empirical quantiles at its requested interval level.
#'   No new draws are needed for this correction. A saved derived summary alone
#'   cannot recover the original draws. If estimated-population restrictions
#'   require regeneration, repeat the original scoring/draw call with the same
#'   data, settings and seed, and `readiness_policy = "review"`.
#' - **Portable calibration:** [load_mfrm_calibration()] preserves a valid
#'   artifact's recorded scoring algorithm; older grid-based intervals remain
#'   grid-based. To adopt continuous intervals, create a new calibration using
#'   the reviewed source fits and [mfrm_calibration_workflow], then score again.
#'   Retain the old artifact for reproducibility. Re-summarizing older score
#'   results recovers recorded algorithm/level labels without changing values.
#' - **External fits:** rerun [import_erm_fit()], [import_tam_fit()] or
#'   [import_mirt_fit()] on the saved source-package fit and rebuild displays;
#'   source-model re-estimation is unnecessary. Use `compute_fit = TRUE` when
#'   imported measurement diagnostics are needed. Unsupported source models
#'   remain unsupported, and imports do not become native fits.
#' - **Agreement, networks and timing:** rebuild [interrater_agreement_table()],
#'   [rater_network_analysis()] and [rater_halo_network_analysis()] from the
#'   existing native fit, matching diagnostics and original settings. Refresh
#'   design reviews with [build_mfrm_network_review()] to record whether the
#'   graph covers all observed subsets. Recreate [response_time_review()] from
#'   the original timed-event data and settings. No MFRM refit is required.
#'   Unavailable comparisons remain unassessed; a missing or excluded graph
#'   edge does not establish absence of a rater effect. Halo Welch-test columns
#'   are retained as missing values. Timing rates use valid times and describe
#'   cutoff rules, not calibrated rapid-guessing or low-effort classifications.
#' - **Simulation and design summaries:** re-summarize saved evaluation objects
#'   to retain attempted-run denominators and unavailable residual-DIF rates.
#'   Missing workload or connectivity records cannot be reconstructed by
#'   summary formatting. If those records are required for a recommendation,
#'   repeat the original evaluation with its recorded design, settings and seeds.
#'
#' After any required recalculation, regenerate dependent [mfrm_results()],
#' reports and exports with matching source objects. A newly created PDF, HTML
#' file or CSV can still contain outdated calculations if built from an old
#' derived object. Consult the affected function's help for its interpretation
#' limits; updating an object does not broaden those limits.
#'
#' @section Next steps for reporting:
#' For the clearest default route in `RSM` / `PCM`, use
#' [describe_mfrm_data()] ->
#' [fit_mfrm()] with `method = "MML"` ->
#' `summary(fit, profile = "fit")` ->
#' `review <- summary(fit, profile = "facets")` ->
#' the required native `plot(fit, type = "wright", show_ci = TRUE)` ->
#' reuse `review$results$diagnostics`; call [diagnose_mfrm()] again only when
#' residual PCA or other custom settings are needed ->
#' [reporting_checklist()] ->
#' [plot_qc_dashboard()] and, when flagged, [plot_marginal_fit()] /
#' [plot_marginal_pairwise()] ->
#' [build_apa_outputs()] ->
#' [build_summary_table_bundle()] -> [apa_table()] or
#' [export_summary_appendix()].
#' The `"facets"` profile name is historical: it provides a comprehensive
#' measurement review and does not require FACETS, TAM, or sirt knowledge or
#' software.
#'
#' Use `JML` only when its fixed-person-parameter estimand is methodologically
#' intended, for example for a JMLE-oriented external comparison, descriptive
#' or exploratory work, or a design with substantial information per person.
#' Do not select it merely as a faster substitute for `MML`: a later `MML` run
#' targets a different estimand rather than serving as stricter follow-up to
#' the same analysis.
#'
#' @section Canonical operational review route:
#' When the main question is scale maintenance rather than manuscript reporting,
#' branch from `review$results$diagnostics` into:
#' [review_mfrm_anchors()] and/or [detect_anchor_drift()] ->
#' [build_equating_chain()] when adjacent-link review is needed ->
#' [build_linking_review()] ->
#' inspect `review$group_view_index` for stable wave / link / facet rollups and
#' `summary(review)$plot_routes` for the next plot helper ->
#' [plot_anchor_drift()] or `plot(anchor_review, ...)` for the specific flagged
#' evidence family.
#'
#' For bounded `GPCM`, use [build_linking_review()] as a caveated exploratory
#' synthesis over direct anchor, drift, and chain evidence. It is not an
#' operational `GPCM` linking decision or evidence that anchor drift is absent.
#'
#' @section Canonical misfit case-review route:
#' When the main question is which observations, facet levels, or pairwise
#' structures deserve follow-up, branch from `review$results$diagnostics` into:
#' [build_misfit_casebook()] ->
#' inspect `casebook$group_view_index`, `casebook$group_views`, and
#' `summary(casebook)$plot_routes` for stable person / facet / wave rollups and
#' the next plot helper ->
#' [plot_unexpected()], [plot_displacement()], [plot_marginal_fit()], or
#' [plot_marginal_pairwise()] according to `casebook$plot_map` ->
#' [build_summary_table_bundle()] / [export_summary_appendix()] when the
#' flagged cases need appendix-style reporting support.
#'
#' `build_misfit_casebook()` can still be used for bounded `GPCM`, but it
#' should be read as an operational exploratory screen rather than as a strict
#' Rasch-style invariance report.
#'
#' @section Latent-regression route:
#' When the fit uses `population_formula = ...`, keep the distinction between
#' the estimator and the forecast helpers explicit:
#' - [fit_mfrm()] estimates the current narrow latent-regression `MML` branch.
#'   In the returned fit object, `fit$population$person_table` is the
#'   complete-case estimation table, while
#'   `fit$population$person_table_replay` retains the observed-person-aligned
#'   pre-omit background-data table for replay/export provenance.
#' - [predict_mfrm_units()] and [sample_mfrm_plausible_values()] can then score
#'   under the fitted population model when scored units also supply
#'   one-row-per-person background data. That scoring-time `person_data`
#'   contract remains separate from the fit object's stored replay table.
#'   Estimated-population scoring currently requires explicit
#'   `readiness_policy = "review"`. Scores and intervals hold the estimated
#'   calibration and population parameters fixed; their estimation uncertainty
#'   is omitted. These draws alone do not justify downstream group comparisons
#'   or regression without a compatible conditioning model and sampling design.
#' - [predict_mfrm_population()] remains a scenario-level simulation/refit
#'   helper rather than the latent-regression estimator itself.
#'
#' @section Score-category support:
#' If the intended rating scale includes categories not observed in the current
#' data, make that support explicit. For example, use
#' `rating_min = 1, rating_max = 5` for a 1-5 scale with only 2-5 observed.
#' This preserves the declaration in the data-support review. A zero-count
#' boundary is review evidence for the separate element-boundary contract; it
#' is not by itself an unsupported free-step contrast.
#' If an intermediate category is unobserved (for example 1, 2, 4, 5 with no
#' 3), also set `keep_original = TRUE` if the zero-count category should remain
#' in the fitted support. `summary(describe_mfrm_data(...))` reports retained
#' zero-count categories in `Notes`, printed `Caveats`, and `$caveats`;
#' `summary(fit)` carries full structured rows into printed `Caveats` and
#' `$caveats`, with `Key warnings` as a short triage subset. Summary-table
#' exports route those rows through `score_category_caveats` or
#' `analysis_caveats`. In a polytomous fitted ladder, a retained zero-count
#' internal category creates an unsupported adjacent-step contrast and stops
#' fitting before optimization.
#'
#' @section Planned assignment and structural missingness:
#' A long-format table alone does not reveal whether an absent Person x facet
#' cell was expected or never assigned. When a score-free assignment roster is
#' available, pass it as `expected_design` to [describe_mfrm_data()]. The
#' summary then separates expected-but-unobserved cells from unexpected
#' observations and reports observed versus declared Person-facet graph
#' components. Without a roster, structural missingness is explicitly marked
#' as not assessed; mfrmr does not assume a complete crossing.
#'
#' @section Typical workflow:
#' 1. Review the long-format data and intended score support with
#'    [describe_mfrm_data()].
#' 2. Fit a model with [fit_mfrm()]. Choose `MML` or `JML` from the prespecified
#'    estimand and assumptions; do not select `JML` merely to shorten runtime.
#' 3. Read `summary(fit, profile = "fit")`, then request
#'    `summary(fit, profile = "facets")` and draw the required native Wright
#'    map with `plot(fit, type = "wright", show_ci = TRUE)`.
#' 4. (Optional) Use [run_mfrm_facets()] or [mfrmRFacets()] for a
#'    legacy-compatible one-shot workflow wrapper.
#' 5. For `RSM` / `PCM`, build diagnostics with [diagnose_mfrm()].
#'    For final reporting, prefer `diagnostic_mode = "both"` so the legacy
#'    residual path and the strict marginal screen remain visible side by side.
#'    For bounded `GPCM`, diagnostics are now available through
#'    [diagnose_mfrm()] together with [analyze_residual_pca()],
#'    [interrater_agreement_table()], [unexpected_response_table()],
#'    [displacement_table()], [measurable_summary_table()],
#'    [rating_scale_table()], [facet_quality_dashboard()],
#'    [reporting_checklist()], and [plot_qc_dashboard()] -- the
#'    fair-average panel of the dashboard reports an explicit
#'    unavailability indicator under GPCM. Use [fair_average_table()] directly
#'    when you need the supported slope-aware element-conditional fair averages.
#'    Treat those residual-based
#'    summaries as exploratory screens because the discrimination
#'    parameter is free.
#'    Full FACETS-style score-side contract review remains blocked for bounded
#'    `GPCM`; package-native scorefile export, fit-based reporting bundles,
#'    direct fair-average tables, and bias-screening tables carry their own
#'    caveats.
#'    Posterior scoring with [predict_mfrm_units()] /
#'    [sample_mfrm_plausible_values()], design-weighted information via
#'    [compute_information()] / [plot_information()], Wright/pathway/CCC plots
#'    via [plot.mfrm_fit()], direct category reports via
#'    [category_structure_report()] / [category_curves_report()], and direct
#'    data generation through [build_mfrm_sim_spec()], [extract_mfrm_sim_spec()],
#'    and [simulate_mfrm_data()] are also available when the simulation
#'    specification stores both thresholds and slopes. Use
#'    [evaluate_mfrm_recovery()] and [assess_mfrm_recovery()] for direct
#'    recovery checks plus caveated role-based design evaluation, population
#'    forecasting, diagnostic-screening, and signal-detection helpers.
#'    Caveated APA/QC/export bundles are available for sensitivity reporting,
#'    while score-side FACETS helpers remain outside the documented `GPCM`
#'    boundary. Use
#'    [gpcm_capability_matrix()] as the formal capability map
#'    before branching into less common helpers.
#'    Residual DIF/DFF differences remain descriptive; their detection and
#'    false-positive rates are unavailable in [evaluate_mfrm_signal_detection()].
#' 6. (Optional, `RSM` / `PCM`; bounded `GPCM` with caveat) Estimate
#'    interaction bias with [estimate_bias()].
#' 7. Choose a downstream branch:
#'    [reporting_checklist()] for direct report preparation, or
#'    [build_weighting_review()] for Rasch-versus-bounded-`GPCM`
#'    weighting review, or [build_misfit_casebook()] / [build_linking_review()]
#'    for operational case review. For bounded `GPCM`, use
#'    [build_linking_review()] only as an exploratory index over direct
#'    anchor/drift/chain evidence.
#' 8. Generate reporting bundles:
#'    [build_summary_table_bundle()], [apa_table()],
#'    [export_summary_appendix()], [build_fixed_reports()],
#'    [build_visual_summaries()]. For bounded `GPCM`, use the APA, visual,
#'    QC, and fit-based export bundles as caveated sensitivity-reporting
#'    surfaces; full score-side FACETS review stays blocked, while
#'    diagnostic/signal-detection design screening has its own caveated
#'    operating-characteristic route.
#' 9. (Optional, `RSM` / `PCM`) Review report completeness with
#'    [reference_case_review()]. Use `facets_output_contract_review()` only when you
#'    explicitly need the compatibility layer.
#' 10. (Optional, `RSM` / `PCM`) For operational linking follow-up, combine
#'    [review_mfrm_anchors()], [detect_anchor_drift()], and
#'    [build_equating_chain()] inside [build_linking_review()] before
#'    exporting appendix-style tables.
#' 11. (Optional) Check packaged reference cases with
#'    [reference_case_benchmark()] when you want package-side reference checks.
#' 12. (Optional) For design planning or future scoring, move to the
#'    simulation/prediction layer:
#'    [build_mfrm_sim_spec()] / [extract_mfrm_sim_spec()] ->
#'    [evaluate_mfrm_recovery()] -> [assess_mfrm_recovery()] /
#'    [evaluate_mfrm_design()] / [predict_mfrm_population()] ->
#'    [predict_mfrm_units()] / [sample_mfrm_plausible_values()]. Current
#'    fit-derived simulation specs include direct `GPCM` data generation and
#'    recovery checks. Design-evaluation, population-forecasting, diagnostic-
#'    screening, and signal-detection helpers also support bounded `GPCM` as
#'    caveated role-based simulation/refit evidence; inspect `gpcm_boundary`
#'    before using those results in design claims.
#'    Unit scoring can use an ordinary `MML` fit directly, a latent-regression
#'    `MML` fit when you also supply one-row-per-person background data for the
#'    scored units, or a `JML` fit when a post hoc reference-prior EAP layer is
#'    acceptable. Estimated-population fits require explicit
#'    `readiness_policy = "review"`; this does not remove their interpretation
#'    limits. Intercept-only latent-regression fits
#'    (`population_formula = ~ 1`) can reconstruct that minimal person table
#'    from the scored person IDs. Keep `predict_mfrm_population()`
#'    conceptually separate from that scoring layer: it is a simulation-based
#'    scenario forecast helper, not the latent-regression estimator itself.
#'    Prediction export still requires actual prediction objects in addition to
#'    `include = "predictions"`.
#' 13. Use `summary()` for compact text checks and `plot()` (or dedicated plot
#'    helpers) for base-R visual diagnostics.
#'
#' @section Three practical routes:
#' - Quick first pass:
#'   `RSM` / `PCM`: [fit_mfrm()] -> [diagnose_mfrm()] -> [plot_qc_dashboard()] ->
#'   [reporting_checklist()] when you want the package to route the next figures.
#'   bounded `GPCM`: [fit_mfrm()] -> [diagnose_mfrm()] ->
#'   [plot_qc_dashboard()] / [unexpected_response_table()] ->
#'   [rating_scale_table()] ->
#'   [compute_information()] -> [plot_information()] ->
#'   [plot.mfrm_fit()] / [category_curves_report()] ->
#'   [fair_average_table()] / [estimate_bias()] when those screening tables
#'   answer the question. For bounded `GPCM`, the fit-based export family
#'   ([build_mfrm_manifest()], [build_mfrm_replay_script()],
#'   [export_mfrm_bundle()]) is available as caveated sensitivity-reporting
#'   output with explicit `gpcm_boundary` rows.
#' - Linking and coverage review:
#'   [subset_connectivity_report()] -> `plot(..., type = "design_matrix")` ->
#'   [plot_wright_unified()].
#' - Manuscript prep:
#'   `RSM` / `PCM`:
#'   [reporting_checklist()] -> inspect the `"Visual Displays"` and
#'   `"Method Section"` rows -> [build_apa_outputs()] ->
#'   [build_summary_table_bundle()] -> [apa_table()] or
#'   [export_summary_appendix()].
#'   bounded `GPCM`:
#'   [reporting_checklist()] -> direct table/plot helpers ->
#'   [build_apa_outputs()] / [build_visual_summaries()] ->
#'   [export_mfrm_bundle()] with `gpcm_boundary` caveats.
#' - Weighting-policy review:
#'   [compare_mfrm()] -> [build_weighting_review()] ->
#'   [compute_information()] / [plot_information()] when you want to inspect
#'   whether bounded `GPCM` is introducing substantively acceptable
#'   discrimination-based reweighting relative to the Rasch-family reference.
#'   Eligible MML comparisons require a common grid of at least 31 points and
#'   a denser common-grid sensitivity check when close or consequential.
#'   Free-slope GPCM ranking and the PCM-versus-GPCM chi-square LRT remain
#'   unavailable; grid refinement alone does not change those restrictions.
#' - Design planning and forecasting:
#'   [build_mfrm_sim_spec()] or [extract_mfrm_sim_spec()] ->
#'   [evaluate_mfrm_recovery()] -> [assess_mfrm_recovery()] for
#'   parameter-recovery checks, then [evaluate_mfrm_design()] ->
#'   [predict_mfrm_population()] ->
#'   [predict_mfrm_units()] or [sample_mfrm_plausible_values()] under the fitted
#'   scoring basis (ordinary `MML`, latent-regression `MML` with person-level
#'   background data, or `JML` with the documented post hoc EAP approximation).
#'   Here again, [predict_mfrm_population()] is the
#'   scenario-level forecast helper, whereas [predict_mfrm_units()] /
#'   [sample_mfrm_plausible_values()] are the scoring layer. Prediction export
#'   requires actual prediction objects. Bounded `GPCM` supports
#'   direct data generation via
#'   [build_mfrm_sim_spec()], [extract_mfrm_sim_spec()], and
#'   [simulate_mfrm_data()], [evaluate_mfrm_recovery()],
#'   [assess_mfrm_recovery()], caveated role-based design evaluation and
#'   population forecasting, diagnostic/signal-detection design screening,
#'   residual diagnostics, and direct curve/report helpers. The current
#'   planning layer remains role-based for two
#'   non-person facets even though estimation itself supports arbitrary facet
#'   counts. Additional arbitrary-facet fields are structural design metadata,
#'   not Monte Carlo performance results.
#'
#' @section Interpreting output:
#' This help page is a map, not an estimator:
#' - use it to decide function order,
#' - confirm which objects have `summary()`/`plot()` defaults,
#' - identify when dedicated helper functions are needed,
#' - and treat [reporting_checklist()] as the package's readiness router for
#'   plot and report follow-up.
#'
#' @section Objects with default `summary()` and `plot()` routes:
#' - `mfrm_fit`: `summary(fit)` and `plot(fit, ...)`.
#' - `mfrm_diagnostics`: `summary(diag)`; plotting via dedicated helpers
#'   such as [plot_unexpected()], [plot_displacement()], [plot_qc_dashboard()].
#' - `mfrm_bias`: `summary(bias)` and [plot_bias_interaction()].
#' - `mfrm_data_description`: `summary(ds)` and `plot(ds, ...)`.
#' - `mfrm_anchor_review`: `summary(review)` and `plot(review, ...)`.
#' - `mfrm_misfit_casebook`: `summary(casebook)` and `print(casebook)`, with
#'   grouping views available through `casebook$group_view_index` and
#'   `casebook$group_views`, source-specific plotting routed through
#'   `summary(casebook)$plot_routes` and `casebook$plot_map`, and
#'   appendix/report handoff available through
#'   [build_summary_table_bundle()] and [export_summary_appendix()].
#' - `mfrm_weighting_review`: `summary(review)` and `print(review)`, with
#'   information follow-up routed through [compute_information()] and
#'   [plot_information()] according to `review$plot_map`, and appendix/report
#'   handoff available through [build_summary_table_bundle()] and
#'   [export_summary_appendix()].
#' - `mfrm_linking_review`: `summary(review)` and `print(review)`, with
#'   grouping views available through `review$group_view_index` and
#'   `review$group_views`, and plotting routed through `summary(review)$plot_routes`,
#'   [plot_anchor_drift()], and `plot(anchor_review, ...)` according to
#'   `review$plot_map`.
#' - `mfrm_facets_run`: `summary(run)` and `plot(run, type = c("fit", "qc"), ...)`.
#' - `apa_table`: `summary(tbl)` and `plot(tbl, ...)`.
#' - `mfrm_apa_outputs`: `summary(apa)` for compact diagnostics of report text.
#' - `mfrm_summary_table_bundle`: `print(bundle)` for manuscript-oriented table
#'   index plus named tables from supported `summary()` outputs,
#'   `summary(bundle)` for table-role/numeric coverage, and `plot(bundle, ...)`
#'   for table-size or numeric-column QC.
#' - `mfrm_threshold_profiles`: `summary(profiles)` for preset threshold grids.
#' - `mfrm_population_prediction`: `summary(pred)` for design-level forecast
#'   tables.
#' - `mfrm_unit_prediction`: `summary(pred)` for unit-level posterior summaries
#'   under the fitted scoring basis.
#' - `mfrm_plausible_values`: `summary(pv)` for draw-level uncertainty
#'   summaries.
#' - `mfrm_bundle` families:
#'   `summary()` and class-aware `plot(bundle, ...)`.
#'   Key bundle classes now also use class-aware `summary(bundle)`:
#'   `mfrm_unexpected`, `mfrm_fair_average`, `mfrm_displacement`,
#'   `mfrm_interrater`, `mfrm_facets_chisq`, `mfrm_bias_interaction`,
#'   `mfrm_rating_scale`, `mfrm_category_structure`, `mfrm_category_curves`,
#'   `mfrm_measurable`, `mfrm_unexpected_after_bias`, `mfrm_output_bundle`,
#'   `mfrm_residual_pca`, `mfrm_specifications`, `mfrm_data_quality`,
#'   `mfrm_iteration_report`, `mfrm_subset_connectivity`,
#'   `mfrm_facet_statistics`, `mfrm_facets_contract_review`, `mfrm_reference_review`,
#'   `mfrm_reference_benchmark`.
#'
#' @section `plot.mfrm_bundle()` coverage:
#' Default dispatch now covers:
#' - `mfrm_unexpected`, `mfrm_fair_average`, `mfrm_displacement`
#' - `mfrm_interrater`, `mfrm_facets_chisq`, `mfrm_bias_interaction`
#' - `mfrm_bias_count`, `mfrm_fixed_reports`, `mfrm_visual_summaries`
#' - `mfrm_category_structure`, `mfrm_category_curves`, `mfrm_rating_scale`
#' - `mfrm_measurable`, `mfrm_unexpected_after_bias`, `mfrm_output_bundle`
#' - `mfrm_residual_pca`, `mfrm_specifications`, `mfrm_data_quality`
#' - `mfrm_iteration_report`, `mfrm_subset_connectivity`, `mfrm_facet_statistics`
#' - `mfrm_facets_contract_review`, `mfrm_reference_review`, `mfrm_reference_benchmark`
#'
#' For unknown bundle classes, use dedicated plotting helpers or custom base-R
#' plots from component tables.
#'
#' @seealso [fit_mfrm()], [run_mfrm_facets()], [mfrmRFacets()],
#'   [diagnose_mfrm()], [estimate_bias()], [mfrmr_visual_diagnostics],
#'   [mfrmr_reports_and_tables], [mfrmr_reporting_and_apa],
#'   [gpcm_capability_matrix], [mfrmr_linking_and_dff],
#'   [mfrmr_compatibility_layer],
#'   [summary.mfrm_fit()], `summary(diag)`,
#'   `summary()`, [plot.mfrm_fit()], `plot()`
#'
#' @examples
#' \donttest{
#' # Load the package
#' library(mfrmr)
#'
#' # Load example ratings and look at the first six rows
#' toy <- load_mfrmr_data("example_operational")
#' head(toy)
#'
#' # Fit the model
#' fit <- fit_mfrm(
#'   data = toy,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   method = "MML",
#'   model = "RSM"
#' )
#'
#' # Plot the results (Wright map)
#' plot(fit)
#'
#' # Save the summary, then display its tables
#' results <- summary(fit)
#' results$person_overview # One row summarizing person ability estimates
#' results$facet_overview  # One row per facet: number of levels, mean, SD, range
#'
#' # Check the interpretation status and recommended next step
#' results$decision
#' }
#' @name mfrmr_workflow_methods
NULL
