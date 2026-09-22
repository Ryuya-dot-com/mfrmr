# mfrmr Workflow and Method Map

Start with one analysis: load ratings, fit a model, plot the results,
and read the summary. The Examples section contains a complete runnable
script. The later sections describe diagnostics, reporting, and
specialist routes.

## Start here

1.  Load the package with
    [`library(mfrmr)`](https://ryuya-dot-com.github.io/mfrmr/) and
    example ratings with
    `toy <- load_mfrmr_data("example_operational")`.

2.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
    The `person`, `facets`, and `score` arguments name columns in the
    data; each row represents one rating event.

3.  Draw the Wright map with `plot(fit)` to view person abilities, rater
    severities, criterion difficulties, and category thresholds
    together.

4.  Save `results <- summary(fit)` and inspect `results$person_overview`
    and `results$facet_overview` for the distributions of estimates.

These overview tables summarize distributions. Use `as.data.frame(fit)`
for individual person, rater, and criterion estimates, identified by
`Facet` and `Level`. Before interpreting or reporting estimates, read
`results$decision` and follow its `NextAction`; the default summary does
not compute diagnostics. For your own data, first check the rating
design and score categories with
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).
`head(toy)` shows the input rows; `Study` and `Group` are extra labels
unused by this model. `<-` saves an object and `$` selects a named part
of it.

## Use your own ratings

The "Use your own CSV" section of
[`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md)
covers CSV import, column-name mapping, and reshaping a sheet with
separate criterion columns. The following help pages are also available
without an installed vignette:

- [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  explains input and retained row counts, category usage, connectedness,
  and how to follow up input problems.

- [`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
  shows how to replace documented missing-score markers while preserving
  person and rater IDs.

- [`summary.mfrm_data_description()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_data_description.md)
  shows a missing-score example and explains the full data checks versus
  their compact summary tables.

Set the score bounds from your rubric and use the same columns, bounds,
and `keep_original` setting for the review and the fit. Reviewing data
does not change the original ratings. After correcting or recoding them,
repeat the review and pass the corrected data frame to
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
A `data_review` object contains checks; it is not the rating data to
fit.

## From the first summary to diagnostics

A `FormalInference = "No"` entry in `results$decision` can mean that
precision has not yet been reviewed. Read `Why` and `NextAction` to
distinguish that state from a detected problem. Run
`diagnostics <- diagnose_mfrm(fit)` and inspect
`summary(diagnostics)$decision`. To reuse these checks in the fuller
reporting object, call
`res <- mfrm_results(fit, diagnostics = diagnostics)`. Here `results` is
the basic summary and `res` is the comprehensive object accepted by
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md).

## Assessment planning and external features

To compare tasks, raters or score weights using numeric observed scores,
start with
[`mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md)
and
[`mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_study.md).
Their help covers crossed facets, task-specific rater teams, incomplete
source designs and reading G/Phi/SEM plots. For prespecified plan
differences under normal random effects with two crossed facets, see
[`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md).
These analyses do not require an MFRM fit and do not estimate
reliability on its latent scale.

To group persons, raters or tasks by external attributes, use
[`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md)
followed by
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
or
[`mfrm_cluster_hierarchical()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_hierarchical.md).
See
[`vignette("mfrmr-external-features", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-external-features.md)
for imputation and setting comparisons. These are exploratory attribute
groups, not estimated ability classes or rater-quality judgments.

## Updating saved analyses for 0.2.4

Keep the original objects, data and analysis settings. Installing an
update does not recalculate saved tables, figures or reports. For
analyses based on a native MFRM fit, start by printing `summary(fit)`
under the updated package and reading its interpretation decision. If
the saved native fit lacks the current estimation checks, refit from the
original data with the same intended model, category coding, anchors,
weights and numerical settings. Running
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
alone cannot establish checks missing from that fit. If the original
data or settings are unavailable, retain the old result as historical
output; its previous approval is not evidence for current inferential
use. Observed-score G/D studies and external-feature groups instead use
their own source objects; they do not require an MFRM fit.

Update the affected result at the earliest step below, then rebuild its
dependent summaries, plots and exports. For an MFRM-based analysis, this
assumes a fit with current estimation checks. A request to recompute
diagnostics or scoring does not itself require a new calibration fit.

- **Display wording only:** reprint a saved fit summary. This updates
  labels and removes the duplicate inference decision; it does not
  recalculate stored diagnostics or establish missing precision
  evidence.

- **Diagnostics and QC:** recreate
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  results with the original diagnostic settings before rebuilding
  reliability, precision, category, marginal-fit, person-fit,
  unexpected-response, fair-score and reporting results. Rerun
  separately requested
  [`q3_statistic()`](https://ryuya-dot-com.github.io/mfrmr/reference/q3_statistic.md),
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
  and
  [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md)
  calculations with their original options. In
  [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
  request `separation_facets` only for facets whose levels need to be
  distinguished; it is no longer a default rater-quality requirement.
  Missing results remain unavailable and cannot be treated as passes.

- **Group comparisons and equivalence:** recreate residual
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  /
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  and
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md)
  results from the existing fit and original group data. They now
  describe residual differences without tests or confidence intervals.
  Recompute
  [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md)
  from an eligible MML fit with matching current diagnostics and the
  original practical bound; old equivalence bundles cannot supply the
  required joint covariance. Rebuild model-choice and weighting reviews
  from their source fits as well.

- **ICC and design effects:** rerun
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  or
  [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
  from the original data and settings. Numeric score labels now retain
  their values. Missing scores or grouping values require an explicit
  `missing = "omit"` choice; malformed scores must be corrected. Inspect
  `attr(icc, "data_usage")`, then recreate
  [`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md)
  using the new ICC result. Older ICC tables lack the row accounting
  needed to calculate matching sample sizes. Recalculation also removes
  the fixed variance cutoff tied to score units and preserves small
  positive variances without decimal rounding. Constant retained scores
  have unavailable variance components and ICCs. Design effects remain
  per-facet approximations; their equivalent row counts do not estimate
  the precision of a complete crossed or unbalanced design. The former
  `ci_method = "profile"` transformed separate component bounds and did
  not calculate a profile-likelihood interval for the ICC ratio. Choose
  `"boot"` explicitly for parametric percentile intervals, then read
  `ICC_CI_Status` and `attr(icc, "icc_ci")`. Failed or nonconverged
  refits and fit warnings withhold intervals. Saved bootstrap results
  also require rerunning to obtain complete failure accounting and
  identify constant-response refits, which withhold intervals;
  reprinting is insufficient.

- **Observed-score design coefficients and shrinkage:** rerun
  [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  with its original data and settings, then
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  with the planned counts and residual-scaling choice. This re-estimates
  the separate observed-score mixed model, not the MFRM. Reapply
  [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
  with the original prior settings and explicit Person choice to refresh
  shrinkage reports, descriptive bands, and replay settings.
  Reapplication replaces the previous adjustment; switching Person
  shrinkage off removes its old adjustment columns. Regenerate replay
  scripts to retain the post-fit adjustment step.

- **Multivariate G/D studies:** to apply metric-specific G/Phi/SEM
  availability rules, rerun
  [`mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_study.md)
  from the saved G-study with the original planned counts and score
  weights. Changing only future counts or weights also reuses that
  G-study. Recreate dependent plan comparisons, plots and exports after
  recalculation; replotting alone preserves stored numbers. Refit
  [`mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md)
  when changing the source data or G-study model, replacing an object
  with missing or incompatible design metadata, or correcting an earlier
  G-study affected by the single-score MINQUE(0) or period-containing
  interaction-ID bugs. In particular, a crossed result cannot be
  converted to a nested model by editing its labels; refit with an
  explicit `nesting` specification. Retain the G-study object and its
  data to calculate new prespecified plan comparisons with
  [`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md).
  A coefficient table alone does not contain the information needed for
  those intervals.

- **External-feature groups:** saved clustering results retain their
  memberships and fitted hierarchy. Replot them to update labels; use
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
  for their stored values. Automatic
  [`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
  conversion is not supported for these plots. A change to features,
  weights, group counts or method requires a new clustering call,
  followed by
  [`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_compare.md)
  on the updated results. For imputation comparisons, reuse the original
  `mice` object to preserve pairing across completed datasets; do not
  generate unrelated completions for each setting.

- **Fitted-object Person scores:** re-summarize the original prediction
  object to recover stored interval settings and updated explanations.
  To replace older grid-endpoint intervals with continuous posterior
  intervals, rerun
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  using the existing fit, scoring data and settings. Reprinting cannot
  change an already calculated interval. Rerun scoring when older
  estimated-population results lack numerical prior information or are
  refused because they claimed unrestricted scoring; these fits require
  explicit `readiness_policy = "review"`.

- **Plausible values:** use `summary(original_plausible_values)` on the
  saved draw object to obtain empirical quantiles at its requested
  interval level. No new draws are needed for this correction. A saved
  derived summary alone cannot recover the original draws. If
  estimated-population restrictions require regeneration, repeat the
  original scoring/draw call with the same data, settings and seed, and
  `readiness_policy = "review"`.

- **Portable calibration:**
  [`load_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  preserves a valid artifact's recorded scoring algorithm; older
  grid-based intervals remain grid-based. To adopt continuous intervals,
  create a new calibration using the reviewed source fits and
  [mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md),
  then score again. Retain the old artifact for reproducibility.
  Re-summarizing older score results recovers recorded algorithm/level
  labels without changing values.

- **External fits:** rerun
  [`import_erm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_erm_fit.md),
  [`import_tam_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_tam_fit.md)
  or
  [`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md)
  on the saved source-package fit and rebuild displays; source-model
  re-estimation is unnecessary. Use `compute_fit = TRUE` when imported
  measurement diagnostics are needed. Unsupported source models remain
  unsupported, and imports do not become native fits.

- **Agreement, networks and timing:** rebuild
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
  [`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
  and
  [`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
  from the existing native fit, matching diagnostics and original
  settings. Refresh design reviews with
  [`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md)
  to record whether the graph covers all observed subsets. Recreate
  [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
  from the original timed-event data and settings. No MFRM refit is
  required. Unavailable comparisons remain unassessed; a missing or
  excluded graph edge does not establish absence of a rater effect. Halo
  Welch-test columns are retained as missing values. Timing rates use
  valid times and describe cutoff rules, not calibrated rapid-guessing
  or low-effort classifications.

- **Simulation and design summaries:** re-summarize saved evaluation
  objects to retain attempted-run denominators and unavailable
  residual-DIF rates. Rebuilding design summaries also restores
  unrounded metrics for threshold decisions; rounded saved summaries
  alone cannot recover that precision. Missing workload or connectivity
  records cannot be reconstructed by summary formatting. If those
  records are required for a recommendation, repeat the original
  evaluation with its recorded design, settings and seeds.

After any required recalculation, regenerate dependent
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
reports and exports with matching source objects. A newly created PDF,
HTML file or CSV can still contain outdated calculations if built from
an old derived object. Consult the affected function's help for its
interpretation limits; updating an object does not broaden those limits.

## Next steps for reporting

For the clearest default route in `RSM` / `PCM`, use
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
-\>
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
with `method = "MML"` -\> `summary(fit, profile = "fit")` -\>
`review <- summary(fit, profile = "facets")` -\> the required native
`plot(fit, type = "wright", show_ci = TRUE)` -\> reuse
`review$results$diagnostics`; call
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
again only when residual PCA or other custom settings are needed -\>
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
The `"facets"` profile name is historical: it provides a comprehensive
measurement review and does not require FACETS, TAM, or sirt knowledge
or software.

Use `JML` only when its fixed-person-parameter estimand is
methodologically intended, for example for a JMLE-oriented external
comparison, descriptive or exploratory work, or a design with
substantial information per person. Do not select it merely as a faster
substitute for `MML`: a later `MML` run targets a different estimand
rather than serving as stricter follow-up to the same analysis.

## Canonical operational review route

When the main question is scale maintenance rather than manuscript
reporting, branch from `review$results$diagnostics` into:
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
structures deserve follow-up, branch from `review$results$diagnostics`
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
  replay table. Estimated-population scoring currently requires explicit
  `readiness_policy = "review"`. Scores and intervals hold the estimated
  calibration and population parameters fixed; their estimation
  uncertainty is omitted. These draws alone do not justify downstream
  group comparisons or regression without a compatible conditioning
  model and sampling design.

- [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  remains a scenario-level simulation/refit helper rather than the
  latent-regression estimator itself.

## Score-category support

If the intended rating scale includes categories not observed in the
current data, make that support explicit. For example, use
`rating_min = 1, rating_max = 5` for a 1-5 scale with only 2-5 observed.
This preserves the declaration in the data-support review. A zero-count
boundary is review evidence for the separate element-boundary contract;
it is not by itself an unsupported free-step contrast. If an
intermediate category is unobserved (for example 1, 2, 4, 5 with no 3),
also set `keep_original = TRUE` if the zero-count category should remain
in the fitted support. `summary(describe_mfrm_data(...))` reports
retained zero-count categories in `Notes`, printed `Caveats`, and
`$caveats`; `summary(fit)` carries full structured rows into printed
`Caveats` and `$caveats`, with `Key warnings` as a short triage subset.
Summary-table exports route those rows through `score_category_caveats`
or `analysis_caveats`. In a polytomous fitted ladder, a retained
zero-count internal category creates an unsupported adjacent-step
contrast and stops fitting before optimization.

## Planned assignment and structural missingness

A long-format table alone does not reveal whether an absent Person x
facet cell was expected or never assigned. When a score-free assignment
roster is available, pass it as `expected_design` to
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).
The summary then separates expected-but-unobserved cells from unexpected
observations and reports observed versus declared Person-facet graph
components. Without a roster, structural missingness is explicitly
marked as not assessed; mfrmr does not assume a complete crossing.

## Typical workflow

1.  Review the long-format data and intended score support with
    [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).

2.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
    Choose `MML` or `JML` from the prespecified estimand and
    assumptions; do not select `JML` merely to shorten runtime.

3.  Read `summary(fit, profile = "fit")`, then request
    `summary(fit, profile = "facets")` and draw the required native
    Wright map with `plot(fit, type = "wright", show_ci = TRUE)`.

4.  (Optional) Use
    [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
    or
    [`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
    for a legacy-compatible one-shot workflow wrapper.

5.  For `RSM` / `PCM`, build diagnostics with
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
    remain outside the documented `GPCM` boundary. Use
    [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
    as the formal capability map before branching into less common
    helpers. Residual DIF/DFF differences remain descriptive; their
    detection and false-positive rates are unavailable in
    [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md).

6.  (Optional, `RSM` / `PCM`; bounded `GPCM` with caveat) Estimate
    interaction bias with
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

7.  Choose a downstream branch:
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

8.  Generate reporting bundles:
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

9.  (Optional, `RSM` / `PCM`) Review report completeness with
    [`reference_case_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_review.md).
    Use
    [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md)
    only when you explicitly need the compatibility layer.

10. (Optional, `RSM` / `PCM`) For operational linking follow-up, combine
    [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
    [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
    and
    [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
    inside
    [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
    before exporting appendix-style tables.

11. (Optional) Check packaged reference cases with
    [`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md)
    when you want package-side reference checks.

12. (Optional) For design planning or future scoring, move to the
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
    Estimated-population fits require explicit
    `readiness_policy = "review"`; this does not remove their
    interpretation limits. Intercept-only latent-regression fits
    (`population_formula = ~ 1`) can reconstruct that minimal person
    table from the scored person IDs. Keep
    [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
    conceptually separate from that scoring layer: it is a
    simulation-based scenario forecast helper, not the latent-regression
    estimator itself. Prediction export still requires actual prediction
    objects in addition to `include = "predictions"`.

13. Use [`summary()`](https://rdrr.io/r/base/summary.html) for compact
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
  bounded `GPCM`:
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
  the Rasch-family reference. Eligible MML comparisons require a common
  grid of at least 31 points and a denser common-grid sensitivity check
  when close or consequential. Free-slope GPCM ranking and the
  PCM-versus-GPCM chi-square LRT remain unavailable; grid refinement
  alone does not change those restrictions.

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
  objects. Bounded `GPCM` supports direct data generation via
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
  supports arbitrary facet counts. Additional arbitrary-facet fields are
  structural design metadata, not Monte Carlo performance results.

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
# \donttest{
# Load the package
library(mfrmr)

# Load example ratings and look at the first six rows
toy <- load_mfrmr_data("example_operational")
head(toy)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Plot the results (Wright map)
plot(fit)


# Save the summary, then display its tables
results <- summary(fit)
results$person_overview # One row summarizing person ability estimates
#> # A tibble: 1 × 11
#>   Persons DistributionN ReviewExcludedExtremeE…¹ EstimateUse   Mean    SD Median
#>     <int>         <int>                    <int> <chr>        <dbl> <dbl>  <dbl>
#> 1      48            48                        0 source_fit… -0.155 0.824 -0.208
#> # ℹ abbreviated name: ¹​ReviewExcludedExtremeEAPs
#> # ℹ 4 more variables: Min <dbl>, Max <dbl>, Span <dbl>, MeanPosteriorSD <dbl>
results$facet_overview  # One row per facet: number of levels, mean, SD, range
#> # A tibble: 2 × 7
#>   Facet     Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>   <chr>      <int>        <dbl>      <dbl>       <dbl>       <dbl> <dbl>
#> 1 Criterion      3            0      0.302      -0.344       0.224 0.568
#> 2 Rater          6            0      0.399      -0.606       0.412 1.02 

# Check the interpretation status and recommended next step
results$decision
#>                                                           Interpretation
#> 1 Fit-readiness requirements satisfied; formal precision review required
#>   FormalInference FitReadiness                                              Why
#> 1              No        ready Formal precision support has not been evaluated.
#>                                                                                                                                                   NextAction
#> 1 Run `diagnose_mfrm()` and pass its result as `diagnostics =` to evaluate formal precision support; fit readiness alone is not a formal-inference decision.
# }
```
