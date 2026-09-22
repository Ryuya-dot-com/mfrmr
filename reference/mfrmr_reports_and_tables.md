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

  Exports those documented summary-table bundles as CSV and optional
  HTML appendix artifacts without requiring the broader fit-based export
  bundle. This is the preferred export route for recovery simulation
  evidence.

- [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md):

  Can now take those summary-table bundles directly, so a selected
  component can move from
  [`summary()`](https://rdrr.io/r/base/summary.html) to a formatted
  handoff table without rebuilding the analysis object path.

## Practical interpretation rules

- Use bundle summaries first, then drill down into component tables.

- Use
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  to determine whether formal inference is supported for the fitted
  result.

- Treat category and bias outputs as complementary layers rather than
  substitutes for overall fit review.

- Treat zero-count score categories as scale-functioning caveats.
  Boundary zero-count categories can be retained with explicit
  `rating_min` / `rating_max`; retaining an intermediate zero-count
  category with `keep_original = TRUE` creates an unsupported
  adjacent-step contrast in a polytomous fitted ladder, so new fits stop
  before optimization. `summary(describe_mfrm_data(...))` exposes these
  in `Notes`, printed `Caveats`, and `$caveats`; `summary(fit)` carries
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
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Build the comprehensive results and report
res <- mfrm_results(fit)
report <- mfrm_report(res)
summary(report, view = "reader")
#> mfrmr Report Summary
#> 
#> Overview
#>  Style OverallStatus     FirstAction ReviewAreas NotComputedAreas CaveatAreas
#>     qc        review Start with Fit.           1                0           0
#>  OptionalAreas UnavailableAreas OkAreas
#>              3                0       1
#>                                                      SourceInclude
#>  fit, diagnostics, tables, precision, reporting, categories, plots
#> 
#> Decision
#>  - Interpretation: Fit-readiness requirements satisfied; formal precision
#>    review required
#>  - Formal inference: No
#>  - Why: Formal precision support has not been evaluated.
#>  - Next: Read the compact results summary.
#> 
#> First screen
#>               Area            Status         Readiness
#>            Overall            review            review
#>                Fit            review            review
#>         Bias / DFF request_if_needed request_if_needed
#>  Linking / anchors request_if_needed request_if_needed
#>   Misfit / pathway request_if_needed request_if_needed
#>          Precision                ok             ready
#>                                                                      MainIssue
#>  ok=1; review=1; caveat=0; request_if_needed=3; not_computed=0; unavailable=0.
#>                   ReviewSignalCount = 9; underfit=0; overfit=0; df_sensitive=9
#>                                                    Evidence was not requested.
#>                                                    Evidence was not requested.
#>                                                    Evidence was not requested.
#>                                                No report-index review signals.
#>                                                                NextAction
#>                                                           Start with Fit.
#>  Inspect the primary evidence table and template boundary before writing.
#>                        Request this evidence only if the claim is needed.
#>                        Request this evidence only if the claim is needed.
#>                        Request this evidence only if the claim is needed.
#>                   Use the listed template route if this area is reported.
#>                                  PrimaryRoute
#>    report$report_index; report$template_index
#>                   report$fit_evidence_summary
#>           mfrm_results(fit, include = "bias")
#>        mfrm_results(fit, include = "linking")
#>  mfrm_results(fit, include = "misfit_review")
#>             report$precision_evidence_summary
#> 
#> Claim readiness
#>                Readiness Claims                    ExampleClaim
#>  needs_requested_section      5       APA-style manuscript text
#>        write_with_caveat      1      Fit and precision evidence
#>                    ready      4 Appendix or reviewer supplement
#> 
#> Immediate actions
#>  Area Status                                                    MainIssue
#>   Fit review ReviewSignalCount = 9; underfit=0; overfit=0; df_sensitive=9
#>                                                                NextAction
#>  Inspect the primary evidence table and template boundary before writing.
#>                 PrimaryRoute                  TemplateRoute
#>  report$fit_evidence_summary report$fit_reporting_templates
#> 
#> Report gaps
#>  Priority           GapType                        Section
#>         3     not_requested     APA and manuscript wording
#>         3     not_requested            Anchors and linking
#>         3     not_requested                 Bias screening
#>         3     not_requested      Misfit and pathway review
#>         3     not_requested       Network and connectivity
#>         3     not_requested               Response-time QC
#>         4 caveated_evidence Fit, separation, and precision
#>                                                                                                   RecommendedAction
#>                   Rebuild the result with mfrm_results(fit, include = "publication") before using APA-style output.
#>                Rebuild the result with mfrm_results(fit, include = "linking") before writing anchor-readiness text.
#>            Rebuild the result with mfrm_results(fit, include = "bias") before writing bias or fairness-screen text.
#>  Rebuild the result with mfrm_results(fit, include = "misfit_review") before writing observation-level misfit text.
#>                    Rebuild the result with mfrm_results(fit, include = "network") before writing connectivity text.
#>          Request the relevant mfrm_results() section or call the route-specific helper before reporting this claim.
#>                             Write only a caveated claim and inspect the route-specific table before manuscript use.
#>                                                                                                                           Route
#>                                                                 mfrm_results(fit, include = "publication"); build_apa_outputs()
#>                                                             mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#>                                                 mfrm_results(fit, include = "bias"); estimate_bias(); bias_interaction_report()
#>                                                       mfrm_results(fit, include = "misfit_review"); plot(res, type = "pathway")
#>                                                             mfrm_results(fit, include = "network"); build_mfrm_network_review()
#>  mfrm_results(fit, include = "response_time", response_time = ..., response_time_data = ...); plot(res, type = "response_time")
#>                                             summary(res$components$precision_review); precision_review_report(fit, diagnostics)

# Find report sections that need attention
report$first_screen[, c("Area", "Status", "MainIssue", "NextAction")]
#>                Area            Status
#> 1           Overall            review
#> 2               Fit            review
#> 3        Bias / DFF request_if_needed
#> 4 Linking / anchors request_if_needed
#> 5  Misfit / pathway request_if_needed
#> 6         Precision                ok
#>                                                                       MainIssue
#> 1 ok=1; review=1; caveat=0; request_if_needed=3; not_computed=0; unavailable=0.
#> 2                  ReviewSignalCount = 9; underfit=0; overfit=0; df_sensitive=9
#> 3                                                   Evidence was not requested.
#> 4                                                   Evidence was not requested.
#> 5                                                   Evidence was not requested.
#> 6                                               No report-index review signals.
#>                                                                 NextAction
#> 1                                                          Start with Fit.
#> 2 Inspect the primary evidence table and template boundary before writing.
#> 3                       Request this evidence only if the claim is needed.
#> 4                       Request this evidence only if the claim is needed.
#> 5                       Request this evidence only if the claim is needed.
#> 6                  Use the listed template route if this area is reported.

# Extract individual person, rater, and criterion estimates
estimates <- as.data.frame(fit)
head(subset(estimates, Facet == "Person")) # First six persons
#>    Facet Level    Estimate Extreme
#> 1 Person  P001  0.28429588    none
#> 2 Person  P002  0.66118004    none
#> 3 Person  P003  0.02177773    none
#> 4 Person  P004  0.22410785    none
#> 5 Person  P005 -0.17496065    none
#> 6 Person  P006  0.67681003    none
subset(estimates, Facet == "Rater")       # All raters
#>    Facet Level   Estimate Extreme
#> 49 Rater   R01 -0.6059776    <NA>
#> 50 Rater   R02 -0.3820356    <NA>
#> 51 Rater   R03  0.2120388    <NA>
#> 52 Rater   R04  0.1799462    <NA>
#> 53 Rater   R05  0.1842365    <NA>
#> 54 Rater   R06  0.4117917    <NA>
subset(estimates, Facet == "Criterion")   # All criteria
#>        Facet        Level   Estimate Extreme
#> 55 Criterion      Content -0.3441471    <NA>
#> 56 Criterion     Language  0.1204520    <NA>
#> 57 Criterion Organization  0.2236950    <NA>
# }
```
