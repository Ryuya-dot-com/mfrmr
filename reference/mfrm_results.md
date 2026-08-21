# Build comprehensive first-screen MFRM results

Build comprehensive first-screen MFRM results

## Usage

``` r
mfrm_results(
  fit,
  include = "standard",
  response_time = NULL,
  response_time_data = NULL,
  response_time_facets = NULL,
  response_time_score = NULL,
  output = c("object", "summary", "tables", "html"),
  diagnostics = NULL,
  compute = c("auto", "never")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md).
  A standard long-format `data.frame` is also accepted when person and
  score columns can be inferred unambiguously from common names such as
  `Person` and `Score`; remaining measurement columns must use
  recognizable facet-role names. Ambiguous extra columns are rejected
  rather than guessed as facets.

- include:

  Result sections or purpose presets to include. Purpose presets are
  `"standard"`, `"publication"`, `"validation"`, `"facets"`, `"bias"`,
  `"misfit_review"`, `"linking"`, `"network"`, `"gpcm_review"`, and
  `"all"`. Section names include `"fit"`, `"diagnostics"`, `"tables"`,
  `"precision"`, `"reporting"`, `"categories"`, `"plots"`,
  `"facets_fit"`, `"bias"`, `"misfit"`, `"linking"`, `"network"`, and
  `"apa"`.

- response_time:

  Optional response-time column name. When `NULL` and `include` contains
  `"response_time"`, conservative column names such as `ResponseTime`,
  `response_time`, or `RT` are detected when available.

- response_time_data:

  Optional original long-format data containing the timing column.
  Required for already fitted objects unless the timing column is still
  present in `fit$prep$data`.

- response_time_facets:

  Optional facet columns for response-time summaries. Defaults to the
  fitted model's source facet columns when available.

- response_time_score:

  Optional score column for response-time summaries. Defaults to the
  fitted model's source score column when available.

- output:

  Return format: `"object"` for an `mfrm_results` object, `"summary"`
  for its compact summary, `"tables"` for a named list of available data
  frames, or `"html"` for a temporary HTML report.

- diagnostics:

  Optional matching output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When supplied, it is identity-checked and reused instead of
  recomputed.

- compute:

  Diagnostic computation policy. `"auto"` preserves the standard
  behavior; `"never"` collects only sections that can be built without
  computing diagnostics and marks every requested dependent section as
  `"not_computed"`. Matching supplied or stored diagnostics are still
  reused under `"never"`.

## Value

Depending on `output`, an `mfrm_results` object, a
`summary.mfrm_results` object, a named table list, or an
`mfrm_results_html` object.

## Details

`mfrm_results()` is a high-level result object. It does not introduce a
new estimator or a new validity rule. It fits only when `fit` is a data
frame, computes diagnostics automatically when needed, and collects
output from existing helpers such as
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md),
[`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md),
and
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).
Sections that are unsupported for a particular fit are retained in the
`status` table as `not_available` rather than stopping the whole results
workflow. The additive `readiness` table keeps Numerical, Data, Design,
Stability, Diagnostics, Reporting, and Plot interpretation states
separate. Plot routes can therefore remain available for diagnosis while
`InterpretationStatus` marks them as review-only. The returned object
also carries `next_actions` and `input$reproducible_code` so users can
move from the comprehensive first screen to explicit reporting or replay
code.

## Include presets

- `"standard"`: fit, diagnostics, tables, precision, reporting,
  categories, and plot routes

- `"publication"`: standard sections plus APA output assembly

- `"validation"`: standard sections plus FACETS-fit/df-sensitivity
  review

- `"facets"`: fit, diagnostics, tables, categories, plots, and
  FACETS-fit review for FACETS-facing migration work

- `"bias"` / `"bias_review"`: standard sections plus facet-level
  bias-screen guidance; interaction bias still requires explicit
  facet-pair selection

- `"misfit"` / `"misfit_review"`: standard sections plus
  unexpected-response, displacement, and pathway-map case-review
  surfaces

- `"linking"` / `"anchors"`: standard sections plus anchor-readiness and
  operational linking-review surfaces from the fitted object's stored
  anchor review; drift and screened-chain review still require multiple
  fitted forms or waves

- `"network"`: standard sections plus network/connectivity review

- `"response_time"`: descriptive response-time QC review when timing
  metadata are supplied through `response_time` / `response_time_data`

- `"gpcm_review"`: standard sections with bounded-`GPCM` caveats
  retained in the collected summaries and reports

- `"all"`: standard sections plus FACETS-fit, network, APA, and
  response-time sections

## Response-time metadata

Response-time review is opt-in and descriptive. It does not change
fitted MFRM estimates, fit a joint speed-accuracy model, or create
automatic exclusion rules. Use `include = "response_time"` together with
`response_time = "ResponseTime"`. When `fit` is an already fitted
object, also supply `response_time_data = original_data` because fitted
objects keep only the measurement columns needed for estimation.

## What to inspect first

Start with `summary(res)`. The most useful fields are:

- `overview`: input mode, model, method, table count, and plot-route
  count

- `decision`: plain-language interpretation, formal-inference, reason,
  and next-action text derived from the source-fit readiness record

- `readiness`: separate analysis and plot-interpretation gates

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: the exact source-fit readiness record
  retained separately from the workflow-level `readiness` table

- `triage`: first-screen signals ordered by unavailable/review/info/ok

- `status`: which sections were available, skipped, or unsupported

- `plot_map`: supported plot routes, availability, and interpretation
  status

- `next_actions`: recommended follow-up calls

- `reproducible_code`: replay script for the first-screen route

## Data-frame input

Direct data-frame input is intentionally narrow. It accepts unambiguous
`Person` / `Score` columns and familiar facet-role names such as
`Rater`, `Item`, `Task`, or `Criterion`, and fits the `RSM` / `MML`
route. It stops when other columns could be metadata, grouping
variables, or background variables rather than silently treating them as
measurement facets. For research scripts, use
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
explicitly so column roles, model, method, anchors, and missing-data
rules are recorded. Use
[`mfrm_results_interactive()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results_interactive.md)
only for opt-in column selection at the console.

## Visualization and HTML

`plot(res)` routes to the primary native Wright map when the fitted
object contains compatible person and facet locations. This default
retains available mfrmr facet uncertainty. Use `plot(res, type = "fit")`
when the explicit three-plot Wright/pathway/category bundle is wanted.
The compact native default discloses any omitted facet locations in its
subtitle and `data$retention`; use `plot(res, top_n = Inf)` for a
complete final map. Other routes include `plot(res, type = "wright")`,
`"pathway"`, `"fit_pathway"`, `"qc"`, `"category"`, `"anchors"`,
`"response_time"`, and `"tables"`. The Wright map is the required first
fitted-scale figure; `"fit_pathway"` is a follow-up with Infit or Outfit
on the horizontal axis and measure on the vertical axis.
`output = "html"` writes a lightweight temporary HTML file; use
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md)
when you want an optional local Shiny reader for an already-created
`mfrm_results` object. Use
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
for a compact analysis archive of the comprehensive results object, or
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
when a fit-centered durable analysis archive is needed. Neither route
deidentifies its contents.

## Typical workflow

1.  Fit explicitly with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    in scripts and manuscripts.

2.  Call `res <- mfrm_results(fit)`.

3.  Read `summary(res, view = "brief")` and its `readiness` table, then
    create the required
    `plot(res, type = "wright", show_ci = TRUE, top_n = Inf)` figure.

4.  Read `summary(res)$triage`, `summary(res)$status`,
    `summary(res)$plot_map`, and `summary(res)$next_actions`.

5.  Call `report <- mfrm_report(res)` when a report-ready surface is
    needed.

6.  Use `export_mfrm_results(res, preset = "starter")` to write the
    Wright map, CSV, report, RDS, replay, and manifest files for
    controlled review. Treat the folder as potentially identifying
    unless it has been separately transformed and reviewed under the
    applicable data-handling policy.

7.  Use
    `plot(res, type = "fit_pathway", include_person = TRUE, top_n_person = 12, person_labels = "none", facet_labels = "flagged")`
    or `plot(res, type = "qc")` for focused visual follow-up.

8.  Optionally inspect the same result with
    [`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md)
    in an interactive session.

9.  Use
    [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
    or the helper named in `summary(res)$next_actions` for
    report-specific follow-up.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:8], , drop = FALSE]

# JML keeps the help example fast; use the recommended workflow settings
# for final analyses.
fit <- fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
res <- mfrm_results(fit)

wright <- plot(res, draw = FALSE)
wright$name
#> [1] "wright_map"
fit_bundle <- plot(res, type = "fit", draw = FALSE)

sx <- summary(res)
sx$overview
#>   InputMode Model Method   N Persons Facets Categories Components Tables
#> 1  mfrm_fit   RSM    JML 128       8      2          4         10    109
#>   PlotRoutes NotAvailable NotComputed
#> 1          7            0           0
sx$readiness
#>        Domain                                Status
#> 1         Fit                                 ready
#> 2   Numerical                                  pass
#> 3        Data                                  pass
#> 4      Design                           pass_linked
#> 5   Stability                                  pass
#> 6 Diagnostics                          not_assessed
#> 7   Reporting exploratory_fit_ready_for_diagnostics
#> 8        Plot   ready_for_diagnostic_interpretation
#>                                                                                                                                                                        Detail
#> 1                                                                                                                                 All stored fit-readiness components passed.
#> 2                                                                                                                                      Optimizer returned convergence code 0.
#> 3                                                                                                                          No preparation warning or review row was retained.
#> 4                                           The observed graph satisfies the connectivity requirement; review the remaining design and identification assumptions separately.
#> 5                                                                                                                   No boundary-constant non-person facet level was detected.
#> 6                                                                                                       Diagnostics have not yet been incorporated into this fit-only status.
#> 7                                                                                                       Reporting status is the strictest applicable upstream workflow state.
#> 8 Stored fit readiness plus numerical, data-support, connectivity, and stability gates passed. Treat this display as diagnostic evidence, not automatic publication approval.
sx$triage
#>                      Area Severity                                 Signal
#> 5             Diagnostics   review            diagnostic_warnings_present
#> 10 Precision / separation   review             precision_review_available
#> 11              Reporting   review reporting_checklist_available_but_held
#> 2             Data review       ok                    data_readiness_pass
#> 3   Design / connectivity       ok                          design_linked
#> 8    Diagnostic dashboard       ok                      qc_plot_available
#> 1           Numerical fit       ok               numerical_readiness_pass
#> 6    Section availability       ok           requested_sections_available
#> 4               Stability       ok               stability_readiness_pass
#> 9                  Tables       ok                       tables_collected
#> 7              Wright map       ok          required_wright_map_available
#>                                                                              Route
#> 5                                            summary(res$diagnostics)$key_warnings
#> 10                                        summary(res$components$precision_review)
#> 11                                     summary(res$components$reporting_checklist)
#> 2                                                           summary(res)$readiness
#> 3                                                           summary(res)$readiness
#> 8                                   plot(res, type = "qc", preset = "publication")
#> 1                                                           summary(res)$readiness
#> 6                                                              summary(res)$status
#> 4                                                           summary(res)$readiness
#> 9                                                  build_summary_table_bundle(res)
#> 7  plot(res, type = "wright", preset = "publication", show_ci = TRUE, top_n = Inf)
#>                                                                                                                                                                                     Detail
#> 5                                                                                                       Precision review flagged 1 review/warn checks. | Unexpected responses flagged: 25.
#> 10                                                                      Precision review is available; inspect fit, separation, reliability, and ZSTD wording boundaries before reporting.
#> 11 Reporting checklist is available, but the associated reporting status is `exploratory_fit_ready_for_diagnostics`. Reporting status is the strictest applicable upstream workflow state.
#> 2                                                                                                                Data status is `pass`. No preparation warning or review row was retained.
#> 3                        Design status is `pass_linked`. The observed graph satisfies the connectivity requirement; review the remaining design and identification assumptions separately.
#> 8                                                                                               The QC dashboard is available as a focused follow-up after the required Wright-map review.
#> 1                                                                                                                       Numerical status is `pass`. Optimizer returned convergence code 0.
#> 6                                                                                                                                Requested sections that could be computed were available.
#> 4                                                                                                    Stability status is `pass`. No boundary-constant non-person facet level was detected.
#> 9                                                                                                                      109 data-frame table(s) were collected for appendix or handoff use.
#> 7                                             The required shared-logit Wright map is available; inspect person targeting, facet locations, steps, and uncertainty before follow-up plots.
sx$plot_map
#>            Type Available RequiredArtifact
#> 1        wright      TRUE             TRUE
#> 2           fit      TRUE            FALSE
#> 3       pathway      TRUE            FALSE
#> 4   fit_pathway      TRUE            FALSE
#> 5            qc      TRUE            FALSE
#> 6      category      TRUE            FALSE
#> 7       anchors     FALSE            FALSE
#> 8 response_time     FALSE            FALSE
#> 9        tables      TRUE            FALSE
#>                                                                                                                                             Route
#> 1                                                                    plot(res, type = 'wright', renderer = 'native', show_ci = TRUE, top_n = Inf)
#> 2                                                                                                                         plot(res, type = 'fit')
#> 3                                                                                                                     plot(res, type = 'pathway')
#> 4 plot(res, type = 'fit_pathway', fit_stat = 'Infit', include_person = FALSE, top_n_person = 0, person_labels = 'none', facet_labels = 'flagged')
#> 5                                                                                                                          plot(res, type = 'qc')
#> 6                                                                                                                    plot(res, type = 'category')
#> 7                                                                                                                     plot(res, type = 'anchors')
#> 8                                                                                                               plot(res, type = 'response_time')
#> 9                                                                                                                      plot(res, type = 'tables')
#>                                                                                                 Detail
#> 1 Required first fitted-scale figure: persons, facet levels, and thresholds on the shared logit ruler.
#> 2                                                      Model-level visual bundle from plot.mfrm_fit().
#> 3                                                     Expected-score pathway map from plot.mfrm_fit().
#> 4      Infit/Outfit-versus-measure pathway with facet uncertainty; person rows are an explicit opt-in.
#> 5                                                  Quality-control dashboard from plot_qc_dashboard().
#> 6                                   Rating-scale/category plot when rating_scale_table() is available.
#> 7                                         Anchor-review plot from the stored fit_mfrm() anchor review.
#> 8                          Descriptive response-time QC plot when response_time_review() is available.
#> 9                                            Numeric table-profile plot from the summary-table bundle.
#>                  InterpretationStatus InterpretationReady
#> 1 ready_for_diagnostic_interpretation                TRUE
#> 2 ready_for_diagnostic_interpretation                TRUE
#> 3 ready_for_diagnostic_interpretation                TRUE
#> 4 ready_for_diagnostic_interpretation                TRUE
#> 5 ready_for_diagnostic_interpretation                TRUE
#> 6 ready_for_diagnostic_interpretation                TRUE
#> 7                       not_available               FALSE
#> 8                      not_applicable                  NA
#> 9                      not_applicable                  NA
#>           ReadinessRoute
#> 1 summary(res)$readiness
#> 2 summary(res)$readiness
#> 3 summary(res)$readiness
#> 4 summary(res)$readiness
#> 5 summary(res)$readiness
#> 6 summary(res)$readiness
#> 7 summary(res)$readiness
#> 8                       
#> 9                       
sx$next_actions
#>   Priority               Area
#> 1        1           Overview
#> 3        2             Triage
#> 2        2         Wright map
#> 4        3        Diagnostics
#> 5        4 Visual diagnostics
#> 6        5        Fit pathway
#> 7        5          Precision
#> 8        6          Reporting
#> 9       11             Tables
#>                                                                      Action
#> 1                                         Read the compact results summary.
#> 3                            Read the first-screen triage before branching.
#> 2                   Create and inspect the required shared-logit scale map.
#> 4                    Review diagnostic key warnings before report drafting.
#> 5                     Open the QC dashboard after reviewing the Wright map.
#> 6 Review Infit against measure, including selected person rows when useful.
#> 7        Inspect fit, separation, reliability, and ZSTD wording boundaries.
#> 8        Use the reporting checklist as a guide for preparing a manuscript.
#> 9                            Create an appendix-ready summary-table bundle.
#>                                                                                                                                                                     Route
#> 1                                                                                                                                                            summary(res)
#> 3                                                                                                                                                     summary(res)$triage
#> 2                                                                                         plot(res, type = "wright", preset = "publication", show_ci = TRUE, top_n = Inf)
#> 4                                                                                                                                   summary(res$diagnostics)$key_warnings
#> 5                                                                                                                          plot(res, type = "qc", preset = "publication")
#> 6 plot(res, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, top_n_person = 12, person_labels = "none", facet_labels = "flagged", preset = "publication")
#> 7                                                                                                                                summary(res$components$precision_review)
#> 8                                                                                                                             summary(res$components$reporting_checklist)
#> 9                                                                                                                                         build_summary_table_bundle(res)
#>                                                                                                                                                 Reason
#> 1                                                           Confirms input mode, model, method, section status, table coverage, and available figures.
#> 3                             Triage orders unavailable, review, information, and OK signals across diagnostics, tables, plots, and reporting outputs.
#> 2 The Wright map is the primary fitted-scale figure: compare person targeting with facet levels and step thresholds before branching into diagnostics.
#> 4                                            Diagnostic warnings identify the highest-priority fit, precision, residual, or category follow-up checks.
#> 5                                                            The QC dashboard gives a focused follow-up view of fit, residual, and category summaries.
#> 6                                          This follow-up separates measure uncertainty from fit displacement while keeping person inclusion explicit.
#> 7                                         Precision review keeps fit-size, standardized fit, and separation evidence in separate reporting categories.
#> 8                                                                                Checklist rows identify report-ready, missing, and caveated sections.
#> 9                                                                   The bundle exposes table roles, plot readiness, and conservative appendix presets.
mfrm_results(fit, include = "validation", output = "summary")$status
#>                Section Status
#> 1                input     ok
#> 2          diagnostics     ok
#> 3          fit_summary     ok
#> 4  diagnostics_summary     ok
#> 5            iteration     ok
#> 6         fit_measures     ok
#> 7     facet_statistics     ok
#> 8         fair_average     ok
#> 9         rating_scale     ok
#> 10          unexpected     ok
#> 11    precision_review     ok
#> 12   facets_fit_review     ok
#> 13 reporting_checklist     ok
#> 14       fit_readiness     ok
#> 15 numerical_readiness     ok
#> 16      data_readiness     ok
#> 17    design_readiness     ok
#> 18 stability_readiness     ok
#> 19 plot_interpretation     ok
#> 20 reporting_readiness review
#>                                                                                                                                                                                                                           Detail
#> 1                                                                                                                                                                                                          Input mode: mfrm_fit.
#> 2                                                                                                                       Computed automatically with residual_pca = 'none', diagnostic_mode = 'both', and fit_df_method = 'both'.
#> 3                                                                                                                                                                                                                     Available.
#> 4                                                                                                                                                                                                                     Available.
#> 5                                                                                                                                                                                                                     Available.
#> 6                                                                                                                                                                                                                     Available.
#> 7                                                                                                                                                                                                                     Available.
#> 8                                                                                                                                                                                                                     Available.
#> 9                                                                                                                                                                                                                     Available.
#> 10                                                                                                                                                                                                                    Available.
#> 11                                                                                                                                                                                                                    Available.
#> 12                                                                                                                                                                                                                    Available.
#> 13                                                                                                                                                                                                                    Available.
#> 14                                                                                                                                                                Fit status: ready. All stored fit-readiness components passed.
#> 15                                                                                                                                                                Numerical status: pass. Optimizer returned convergence code 0.
#> 16                                                                                                                                                         Data status: pass. No preparation warning or review row was retained.
#> 17                                                                 Design status: pass_linked. The observed graph satisfies the connectivity requirement; review the remaining design and identification assumptions separately.
#> 18                                                                                                                                             Stability status: pass. No boundary-constant non-person facet level was detected.
#> 19 Plot status: ready_for_diagnostic_interpretation. Stored fit readiness plus numerical, data-support, connectivity, and stability gates passed. Treat this display as diagnostic evidence, not automatic publication approval.
#> 20                                                                                                Reporting status: exploratory_fit_ready_for_diagnostics. Reporting status is the strictest applicable upstream workflow state.

plot(res, type = "qc", draw = FALSE)

# Direct data-frame input is available only after selecting unambiguous
# measurement columns. Extra study/group columns require an explicit fit.
mfrm_results(
  toy_small[, c("Person", "Rater", "Criterion", "Score")],
  include = c("fit", "diagnostics"),
  output = "summary"
)$mapping
#>      Key            Value
#> 1 Person           Person
#> 2  Score            Score
#> 3 Facets Rater, Criterion
#> 4 Weight                 
# }
```
