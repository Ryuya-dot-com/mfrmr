# mfrmr Reporting and APA Guide

Package-native guide to moving from fitted model objects to
manuscript-draft text, tables, notes, and revision checklists in
`mfrmr`.

This guide currently applies fully to diagnostics-based `RSM` / `PCM`
workflows. First-release `GPCM` fits now support
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md),
direct curve/graph and residual table helpers, and caveated
APA/QC/export bundles. Use
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
when you need the formal boundary for the current `GPCM` reporting path.

In particular, bounded `GPCM`
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
[`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
[`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md),
and
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
outputs include explicit `gpcm_boundary` caveats. Full FACETS-style
score-side contract review remains blocked. Scorefile export, design
forecasting, diagnostic/signal-detection screening, and linking
synthesis use their own caveated `GPCM` routes and should not be treated
as automatic operational-scoring evidence.

## Start with the reporting question

- "Which parts of this run are draft-complete, and with what caveats?"
  Use
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- "How should I phrase the model, fit, and precision sections?" For
  `RSM` / `PCM`, use
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- "Which tables should I hand off to a manuscript or appendix?" Use
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md),
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
  and
  [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md).

- "How do I explain model-based vs exploratory precision?" Use
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  and `summary(diagnose_mfrm(...))`.

- "Which caveats need to appear in the write-up?" Use
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  first, then
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- "How should I report candidate-model comparisons?" Use
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  for the same-data comparison table, then
  [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
  and
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  for cautious model-role, route-boundary, and wording tables.

- "How should I start figure captions or visual-results wording?" Use
  [`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md)
  for conservative caption and results sentence starters, then verify
  availability with `reporting_checklist()$visual_scope`.

## Recommended reporting route

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Build diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

3.  Review precision strength with
    [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
    when inferential language matters.

4.  Run
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    to identify missing sections, caveats, and next actions. Use the
    `"Visual Displays"` rows as the figure-routing layer for the current
    run.

5.  When strict marginal rows are available, follow up with
    [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md)
    and
    [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)
    before finalizing the narrative around local misfit.

6.  Create manuscript-draft prose and metadata with
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
    For bounded `GPCM`, treat the APA/QC/export stack as caveated
    sensitivity-reporting output and keep its `gpcm_boundary` visible.

7.  Convert summary outputs to reusable table bundles with
    [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
    review the bundle with
    [`summary()`](https://rdrr.io/r/base/summary.html) /
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html), then
    convert specific components to handoff tables with
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
    or export them directly with
    [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).

8.  When candidate models are compared, keep the comparison as a
    reporting review:
    [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
    -\>
    [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
    -\>
    [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).
    Treat bounded `GPCM` as a slope-aware sensitivity route unless the
    study design explicitly justifies discrimination-based operational
    scoring.

## Model-comparison reporting route

Use
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
to build the candidate-model table and inspect `ICComparable`,
`ComparisonBasis`, and any nesting warnings before reading information
criteria. Then use
[`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
to attach the comparison to explicit model roles, downstream-route
boundaries, wording templates, and optional
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
output. Convert that review with
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
when a manuscript appendix, coauthor handoff, or HTML export needs
stable table names.

A conservative bounded-`GPCM` reporting sequence is:
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for the equal-weighting `RSM` / `PCM` reference,
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for the bounded `GPCM` sensitivity fit,
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
then
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
or
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md).
Do not use `AIC`, `BIC`, or log-likelihood alone as an automatic
operational-scoring decision.

## Latent-regression reporting route

Active latent-regression fits expose their reporting surface through
`summary(fit)$population_overview`,
`summary(fit)$population_coefficients`,
`summary(fit)$population_coding`, and fit-level `caveats`. Report those
coefficients as conditional-normal population-model parameters, not as a
post-hoc regression on EAP or MLE scores. Also report the
`population_formula`, coding/contrast information, `population_policy`,
and omitted-person or omitted-row counts when complete-case handling was
used.

Prediction-side helpers
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
and
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
can carry the fitted population model into future-unit scoring and
plausible-value draws. In 0.2.2 this remains a first-version,
one-dimensional `MML` route for `RSM` / `PCM`; avoid stronger claims
about multidimensional latent regression, Wald tests, posterior
predictive checking, or full external-engine equivalence unless those
checks were performed outside this helper family.

## Publication-readiness boundary

`mfrmr` can provide a defensible measurement-output trail for a
manuscript: fitted model summaries, diagnostic tables, precision review,
report templates, APA table metadata, figure-routing guidance, and
reproducible exports. It does not decide whether a specific journal
claim is warranted. For high-stakes or selective journals, use the
package outputs together with the study design, measurement rationale,
primary citations, sensitivity checks, and substantive argument for the
target field.

Treat `DraftReady`, `ReadyForAPA`, `ClaimStrength`, and report-template
rows as drafting and caveat-routing aids. They are not formal acceptance
rules, proof of validity, or a substitute for peer-review judgment.
Before copying text, inspect
`mfrm_report(res, style = "apa")$first_screen`, `$claim_readiness`,
`$report_gaps`, and `$template_index`.

## Which helper answers which task

- [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md):

  Turns current analysis objects into a prioritized revision guide with
  `DraftReady`, `Priority`, and `NextAction`. `DraftReady` means "ready
  to draft with the documented caveats"; `ReadyForAPA` is retained as a
  backward-compatible alias, and neither field means "formal inference
  is automatically justified". The `"Visual Displays"` rows also mirror
  the public plot family, so the checklist doubles as a figure-routing
  surface.

- [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md):

  Builds shared-contract prose, table notes, captions, and a section map
  from the current fit and diagnostics.

- [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md):

  Turns supported [`summary()`](https://rdrr.io/r/base/summary.html)
  outputs into named `data.frame` tables plus an index for manuscript or
  appendix handoff, and now also supports bundle-level
  [`summary()`](https://rdrr.io/r/base/summary.html) /
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for role
  coverage and numeric QC.

- [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md):

  Writes those validated summary-table bundles to CSV and optional HTML
  appendix artifacts without requiring a full fit-based export bundle.

- [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md):

  Produces reproducible base-R tables with APA-oriented labels, notes,
  and captions.

- [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md):

  Summarizes whether precision claims are model-based, hybrid, or
  exploratory.

- [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md):

  Provides facet-level summaries that often feed result tables and
  appendix material.

- [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md):

  Prepares publication-oriented figure data that can be cited from the
  report text.

- [`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md):

  Provides conservative figure placement, caption-starter,
  results-wording, and overclaim-avoidance guidance for public visual
  helpers.

## Practical reporting rules

- Treat
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  as the gap finder and
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  as the writing engine.

- Use the checklist's `"Visual Displays"` rows to decide whether the
  next follow-up should be
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
  [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md),
  [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md),
  or another public plot.

- Use
  [`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md)
  to draft visual captions and results-sentence starters, but do not
  paste the skeletons without checking the actual fit, diagnostics, and
  study context.

- Phrase formal inferential claims only when the precision tier is
  model-based.

- Keep bias and differential-functioning outputs in screening language
  unless the current precision layer and linking evidence justify
  stronger claims.

- Treat `DraftReady` (and the legacy alias `ReadyForAPA`) as a
  drafting-readiness flag, not as a substitute for methodological
  review.

- Rebuild APA outputs after major model changes instead of editing old
  text by hand.

- For bounded `GPCM`, use APA/QC/export helpers only as caveated
  sensitivity-reporting surfaces and keep full FACETS-style score-side
  review outside this route.

## Fit-to-HTML reporting bundle

When the user already has a fitted object and wants a local report
folder in one call, use
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
directly:
`export_mfrm_bundle(fit, include = c("core_tables", "checklist", "dashboard", "apa", "summary_tables", "manifest", "script", "html"))`.
This route computes missing diagnostics, writes CSV/text/replay
artifacts, and creates a lightweight HTML summary without requiring a
prior
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
object. Use
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
and
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
first when the goal is interactive triage or report-readiness review;
use
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
when the goal is a file bundle for a project folder, coauthor handoff,
or supplementary-methods archive.

## Typical workflow

- Manuscript-first route:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  -\>
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  -\> [`summary()`](https://rdrr.io/r/base/summary.html) /
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) -\>
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md),
  or
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)(include
  = c("summary_tables", "html")). For `RSM` / `PCM` final reports,
  prefer `method = "MML"` and `diagnostic_mode = "both"` in the
  diagnostics step. For bounded `GPCM`, use the same fit-based
  reporting/export family only as caveated sensitivity-reporting output
  and inspect its `gpcm_boundary` rows before writing claims.

- Appendix-first route:
  [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md)
  -\>
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  -\>
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
  -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- Precision-sensitive route:
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- bounded `GPCM` route:
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\> direct residual/category/information helpers -\> caveated
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
  [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
  or
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  as needed.

- Model-comparison route:
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  -\>
  [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
  -\>
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  -\>
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
  or
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)(include
  = c("summary_tables", "html")).

## Companion guides

- For report/table selection, see
  [mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md).

- For end-to-end analysis routes, see
  [mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md).

- For visual follow-up, see
  [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

- For the bounded `GPCM` support statement, see
  [gpcm_capability_matrix](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md).

- For a longer walkthrough, see
  [`vignette("mfrmr-reporting-and-apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-reporting-and-apa.md).

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  quad_points = 7,
  maxit = 30
)
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")

checklist <- reporting_checklist(fit, diagnostics = diag)
visual_reporting_template("manuscript")[, c("FigureFamily", "CaptionSkeleton")]
head(checklist$checklist[, c("Section", "Item", "DraftReady", "NextAction")])
subset(
  checklist$checklist,
  Section == "Visual Displays",
  c("Item", "Available", "NextAction")
)

apa <- build_apa_outputs(fit, diagnostics = diag)
apa$section_map[, c("SectionId", "Available")]

tbl <- apa_table(fit, which = "summary")
tbl$caption
bundle <- build_summary_table_bundle(checklist)
bundle$table_index
apa_from_bundle <- apa_table(bundle, which = "section_summary")
apa_from_bundle$caption

report_bundle <- export_mfrm_bundle(
  fit,
  diagnostics = diag,
  output_dir = tempdir(),
  prefix = "mfrmr_report_bundle",
  include = c("core_tables", "checklist", "apa", "summary_tables", "html"),
  overwrite = TRUE
)
report_bundle$summary[, c("FilesWritten", "HtmlWritten")]
} # }
```
