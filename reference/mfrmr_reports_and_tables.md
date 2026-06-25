# mfrmr Reports and Tables Map

Quick guide to choosing the right report or table helper in `mfrmr`. Use
this page when you know the reporting question but have not yet decided
which bundle, table, or reporting helper to call.

## Start with the question

- "How should I document the model setup and run settings?" Use
  [`specifications_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/specifications_report.md).

- "Was data filtered, dropped, or mapped in unexpected ways?" Use
  [`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md)
  and
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).

- "Did estimation converge cleanly and how formal is the precision
  layer?" Use
  [`estimation_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimation_iteration_report.md)
  and
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md).

- "Which facets are measurable, variable, or weakly separated?" Use
  [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md),
  [`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
  and
  [`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_chisq_table.md).

- "Are score categories functioning in a usable sequence?" Use
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
  [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
  and
  [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md).

- "Is the design linked well enough across subsets, forms, or waves?"
  Use
  [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
  and
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md).

- "What should go into the manuscript text and tables?" For `RSM` /
  `PCM`, use
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
  and
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  or
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).
  For bounded `GPCM`, use the same route only where
  [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
  marks it as `supported_with_caveat`: direct table/plot helpers,
  summary-table appendix export, caveated
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
  and caveated
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  are available with a `gpcm_boundary`; score-side exports and
  design-forecasting evidence use their own caveated or blocked `GPCM`
  routes.

- "Did a simulation recover the known generating parameters well
  enough?" Use
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
  for the recovery study,
  [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
  for the adequacy checklist, and then
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  or
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
  for the appendix handoff.

## Recommended report route

1.  Start with
    [`specifications_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/specifications_report.md)
    and
    [`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md)
    to document the run and confirm usable data.

2.  Continue with
    [`estimation_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimation_iteration_report.md)
    and
    [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
    to judge convergence and inferential strength.

3.  Use
    [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md)
    and
    [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
    to describe spread, linkage, and measurability.

4.  Add
    [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
    [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
    and
    [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md)
    to document scale functioning.

5.  For `RSM` / `PCM`, finish with
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    and
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
    for manuscript-oriented output, then
    [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
    for reusable handoff tables or
    [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
    for direct appendix export. For bounded `GPCM`, the same
    report/export route is available only as a caveated
    sensitivity-reporting layer with `gpcm_boundary`; keep FACETS-style
    score-side review and design forecasting on their separate
    capability rows.

If you are unsure which helper to call, start with
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md).
It returns a compact purpose-to-helper table that separates `*_table`,
`*_report`, `*_review`, `*_bundle`, `export_*`, and compatibility
routes.

## Which output answers which question

- [`specifications_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/specifications_report.md):

  Documents model type, estimation method, anchors, and core run
  settings. Best for method sections and reproducibility records.

- [`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md):

  Summarizes retained and dropped rows, missingness, and unknown
  elements. Best for data cleaning narratives.

- [`estimation_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimation_iteration_report.md):

  Shows replayed convergence trajectories. Best for diagnosing slow or
  unstable estimation.

- [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md):

  Summarizes whether `SE`, `CI`, and reliability indices are
  model-based, hybrid, or exploratory. Best for deciding how strongly to
  phrase inferential claims.

- [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md):

  Bundles facet summaries, precision summaries, and variability tests.
  Best for facet-level reporting.

- [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md):

  Summarizes disconnected subsets and coverage bottlenecks. Best for
  linking and anchor strategy review.

- [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md):

  Gives category counts, average measures, and threshold diagnostics.
  Best for first-pass category evaluation.

- [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md):

  Adds transition points and compact category warnings. Best for
  category-order interpretation.

- [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md):

  Returns category-probability, cumulative-probability, expected-ogive,
  total-information, and category-specific information coordinates. Best
  for downstream graphics and report drafts.

- [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md):

  Writes an observation-level residual file, optionally with modeled
  category probabilities. Best for external case review or reproducible
  handoff.

- [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md):

  Writes connected-subset summary and node-membership files. Best for
  scale-linking review outside R.

- [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md):

  Turns analysis status into an action list with priorities and next
  steps. Best for closing reporting gaps.

- [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md):

  Creates manuscript-draft text, notes, captions, and section maps from
  a shared reporting contract.

- [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md):

  Converts supported [`summary()`](https://rdrr.io/r/base/summary.html)
  outputs into named `data.frame` tables with a compact index for
  appendix or manuscript handoff, including recovery simulation and
  recovery assessment outputs. It also supports bundle-level
  [`summary()`](https://rdrr.io/r/base/summary.html) /
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for QC before
  export.

- [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md):

  Exports those validated summary-table bundles as CSV and optional HTML
  appendix artifacts without requiring the broader fit-based export
  bundle. This is the preferred export route for recovery simulation
  evidence.

- [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md):

  Can now take those summary-table bundles directly, so a selected
  component can move from
  [`summary()`](https://rdrr.io/r/base/summary.html) to a formatted
  handoff table without rebuilding the analysis object path.

## Practical interpretation rules

- Use bundle summaries first, then drill down into component tables.

- Treat
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  as the gatekeeper for formal inference.

- Treat category and bias outputs as complementary layers rather than
  substitutes for overall fit review.

- Treat zero-count score categories as scale-functioning caveats.
  Boundary zero-count categories can be retained with explicit
  `rating_min` / `rating_max`; intermediate zero-count categories
  require `keep_original = TRUE` and make adjacent thresholds weakly
  identified. `summary(describe_mfrm_data(...))` exposes these in
  `Notes`, printed `Caveats`, and `$caveats`; `summary(fit)` carries
  full structured caveats into printed `Caveats` and `$caveats`, with
  `Key warnings` as a short triage subset. Summary-table exports use
  `score_category_caveats` and `analysis_caveats`.

- Use
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  before
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  when a report still needs missing diagnostics or clearer caveats.

## Typical workflow

- Run documentation:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`specifications_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/specifications_report.md)
  -\>
  [`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md).

- Precision and facet review:
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  -\>
  [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md).

- Scale review:
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
  -\>
  [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md)
  -\>
  [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md).

- Manuscript handoff (`RSM` / `PCM`):
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  -\>
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  -\> [`summary()`](https://rdrr.io/r/base/summary.html) /
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) -\>
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  or
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
  /
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)(include
  = "summary_tables").

- Bounded `GPCM` handoff:
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\> direct summaries/plots -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  or
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  -\>
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
  or caveated
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
  with `gpcm_boundary` retained in report/export objects.

- Recovery simulation handoff:
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
  -\> [`plot()`](https://rdrr.io/r/graphics/plot.default.html) /
  [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
  -\>
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  -\>
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).

## Companion guides

- For visual follow-up, see
  [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

- For one-shot analysis routes, see
  [mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md).

- For manuscript assembly, see
  [mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md).

- For linking and DFF review, see
  [mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md).

- For legacy-compatible wrappers and exports, see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md).

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
fit <- fit_mfrm(
  toy_small,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  quad_points = 7,
  maxit = 30
)
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")

spec <- specifications_report(fit)
summary(spec)$overview

prec <- precision_review_report(fit, diagnostics = diag)
summary(prec)$checks

checklist <- reporting_checklist(fit, diagnostics = diag)
subset(checklist$checklist, Section == "Visual Displays", c("Item", "NextAction"))

apa <- build_apa_outputs(fit, diagnostics = diag)
apa$section_map[, c("Heading", "Available")]
bundle <- build_summary_table_bundle(checklist)
bundle$table_index
} # }
```
