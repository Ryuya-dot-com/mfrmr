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
  compute = c("auto", "never"),
  predictions = NULL,
  intervals = NULL,
  scores = NULL,
  comparison = NULL,
  response_diagnostics = NULL,
  calibration_intervals = c("none", "normal"),
  calibration_level = 0.95
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  or
  [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md).
  A standard long-format `data.frame` is also accepted when person and
  score columns can be inferred unambiguously from common names such as
  `Person` and `Score`; remaining measurement columns must use
  recognizable facet-role names. Ambiguous extra columns are rejected
  rather than guessed as facets. Native CML and comparison-only fits are
  excluded; use their [`summary()`](https://rdrr.io/r/base/summary.html)
  and the CML interval object's
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  and RDS saving. Imported source-package fits use their own
  [`summary()`](https://rdrr.io/r/base/summary.html) and point-only
  Wright map; comprehensive reports require a native mfrmr fit.

- include:

  Result sections or purpose presets to include. Purpose presets are
  `"standard"`, `"publication"`, `"validation"`, `"facets"`, `"bias"`,
  `"misfit_review"`, `"linking"`, `"network"`, `"gpcm_review"`, and
  `"all"`. Section names include `"fit"`, `"diagnostics"`, `"tables"`,
  `"precision"`, `"reporting"`, `"categories"`, `"plots"`,
  `"facets_fit"`, `"bias"`, `"misfit"`, `"linking"`, `"network"`, and
  `"apa"`. When omitted, `NULL` or empty for a two-family GPCM fit, this
  selects `c("fit", "plots")`. Explicit presets and sections remain
  scope-checked.

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
  An
  [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  object is also accepted as an alias for `response_diagnostics`; do not
  supply it twice.

- compute:

  Diagnostic computation policy. `"auto"` preserves the standard
  behavior; `"never"` collects only sections that can be built without
  computing diagnostics and marks every requested dependent section as
  `"not_computed"`. Matching supplied or stored diagnostics are still
  reused under `"never"`. The `"fit"` and `"pathway"` result plots reuse
  these diagnostics too. Under `"never"`, if none are available, their
  expected-score curves omit fit-statistic tables. To include those
  tables, supply matching `diagnostics` or rebuild the result with
  `compute = "auto"`; explicitly requesting
  `include_fit_measures = TRUE` without diagnostics under `"never"`
  gives an error. For two-family GPCM fits, both settings collect saved
  results without fitting, integration or diagnostic calculation;
  ordinary diagnostics remain `"not_available"`.

- predictions:

  Optional saved predictions for a testlet or random-rater fit: the
  result of `predict(fit, ...)`. Matching calibration, column roles,
  levels, settings and prediction-source metadata are required. Older
  predictions without this metadata must be regenerated from the saved
  fit before attachment; the fit itself does not need to be
  re-estimated.

- intervals:

  Optional saved
  [`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md)
  result from the exact supplied random-rater fit. For a native GPCM
  fit, accepts saved slope intervals, curve intervals, a GPCM bootstrap
  result, or a named list of these. Two-family GPCM also accepts
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  for locations and within-facet contrasts. All must match the exact
  fitted data, parameters, population and integration settings. For
  native RSM/PCM fits, accepts a saved
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  or
  [`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
  result, or a named list combining these. Population intervals are
  delivered in tables, with their saved cautions in
  `population_<name>_interpretation_notes`. No bootstrap or interval
  calculation is run by this function.

- scores:

  Optional saved
  [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  result for an extension, or
  [`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
  output, with matching source calibration. Native one- and two-family
  GPCM accept saved
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  output with matching calibration, population and source identity.
  Two-family GPCM also accepts a format-6
  [`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  result. One-family portable scores keep their standalone
  reporting/export methods. For testlets this is an alias for
  `predictions`; supply it once. Shared raters can also attach response
  `predictions` and rater `intervals`. No Person scoring is run here.
  Complete source-roster identity is required for the additional
  model-aware map routes; see
  [mfrmr_model_maps](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_model_maps.md).

- comparison:

  Optional descriptive extended-model result from
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).
  Calibration, settings and observed/omitted events must match this fit.
  Retained tables and `plot(..., type = "comparison")` compare centered
  facet summaries without fitting or automatic ranking. When the
  comparison includes saved response diagnostics, its
  `comparison_response_*` tables and `type = "response_comparison"` plot
  retain aligned predictive quantities; select `metric` for other
  indices.

- response_diagnostics:

  Optional saved
  [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  output matching the fit's calibration and exact source roster. It is
  identity-checked and reused without integration. Ordinary RSM MML and
  testlet/shared-rater fits and two-family GPCM MML support these
  posterior summaries; corrected JML instead supplies conditional
  plug-in summaries. None has reference cutoffs. Two-family results
  default to `include = c("fit", "plots")` and only collect saved
  quantities. Use `compute = "never"` to also avoid computing ordinary
  plug-in diagnostics. Saved posterior summaries appear in `response_*`
  tables and `plot(..., type = "response_diagnostics")`.
  `tables$response_overview` counts selected, available, unresolved,
  missing-score, zero-variance and unselected rows; partial output
  requires review. Older saved results without this table recover the
  overview and matching status from their retained diagnostic rows
  during summary, reporting, export or supported viewing, without
  re-estimation. The original object is unchanged; newly exported
  results include the recovered metadata.

- calibration_intervals:

  For testlet and shared-rater fits, `"none"` (default) retains
  calibration estimates and approximate SEs with missing bounds.
  `"normal"` explicitly requests pointwise observed-information normal
  intervals for fixed facets and steps; finite-sample coverage is not
  established. Numerical, information and estimated-boundary
  restrictions remain. Saved result tables, testlet calibration plots
  and reports retain the selection. This does not select
  individual-rater or Person intervals.

- calibration_level:

  Nominal level for those calibration intervals, between zero and one;
  default 0.95. Nondefault calibration options are unavailable for
  ordinary MFRM fits.

## Value

Depending on `output`, an `mfrm_results` object, a
`summary.mfrm_results` object, a named table list, or an
`mfrm_results_html` object.

## Details

`mfrm_results()` is a high-level result object. It does not introduce a
new estimator or a new validity rule. It fits only when `fit` is a data
frame, computes diagnostics automatically when needed, and collects
output from functions such as
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
code. The examples call this object `res` to distinguish it from
`results <- summary(fit)` in the quick start. Use `mfrm_report(res)` and
`export_mfrm_results(res)` for reporting and export; those functions
need the comprehensive results object. If diagnostics were already
computed, pass them with `diagnostics = diagnostics` to reuse them.

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

- `"gpcm_review"`: standard sections with `GPCM` caveats retained in the
  collected summaries and reports

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
  and next-action text derived from source-fit readiness and the saved
  diagnostic precision profile. Missing precision remains unreviewed; a
  positive precision assessment cannot override source-fit restrictions.
  Reading this summary does not compute new diagnostics or establish
  sampling coverage.

- `readiness`: separate analysis and plot-interpretation checks

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

For ordinary models, `plot(res)` routes to the primary native Wright map
when the fitted object contains compatible person and facet locations.
This default retains available mfrmr facet uncertainty. Use
`plot(res, type = "fit")` when the explicit three-plot
Wright/pathway/category bundle is wanted. The compact native default
discloses any omitted facet locations in its subtitle and
`data$retention`; use `plot(res, top_n = Inf)` for a complete final map.
Other routes include `plot(res, type = "wright")`, `"pathway"`,
`"fit_pathway"`, `"qc"`, `"category"`, `"anchors"`, `"response_time"`,
and `"tables"`. The Wright map is the required first fitted-scale
figure; `"fit_pathway"` is a follow-up with Infit or Outfit on the
horizontal axis and measure on the vertical axis. `output = "html"`
writes a lightweight temporary HTML file; use
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

## Reproduce attached inference

When additional inference or posterior diagnostics are attached, the
code shown by `summary(res)` and in HTML saves and reloads the complete
`res` object. Choose the file path before running it. This preserves
attached methods, levels and unavailable results without fitting or
recalculating. Exported replay scripts only reload the RDS already
written by the export. The starter export index links the saved RSM/PCM
and GPCM inference figures alongside the ordinary maps, whose
uncertainty and fit meanings are separate.

## Saved RSM/PCM fixed-facet intervals

For supported MML fits, use `intervals = list(raters = ci)` with output
from
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).
Native CML and comparison-only fits are not inputs to this collector.
For CML, use `summary(fit)` and save the interval result separately with
`saveRDS(ci, file)`; `summary(ci)`, `plot(ci)` and
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
reuse that result without an ordinary report bundle. The fit must match
the saved data, parameters, constraints, population and integration
settings. Named results give `facet_` plot routes, for example
`plot(res, type = "facet_raters")`; a single result gives
`facet_inference`. Include `"plots"` to enable those routes.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
supports customization. Tables, reports and exports preserve the
selected method, confidence level, contrasts, cluster mapping and
fixed/unavailable targets. Export replay reloads saved results without
refitting or changing the selected intervals. These are pointwise
fixed-facet intervals, not simultaneous rater decisions or uncertainty
for replacement raters. Ordinary map and fit displays keep their own
meanings and are not recalculated with the attached covariance.

## Corrected JML results

For an explicit correction fitted by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
this helper collects saved estimates, numerical status and the RootSE
interpretation without computing ordinary diagnostics. Unavailable
requested sections are labelled in `status`.
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) offers
`"slopes"`, `"locations"` and `"steps"`, with point or
cumulative-distribution displays and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
conversion.
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
retain the estimator, correction order, unavailable inference and
covariance-failure reasons. Saved replay reloads the result without
refitting. Attach saved
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
output through `response_diagnostics` to include conditional
probabilities, expected scores and descriptive Infit/Outfit. The source
and probability definition are checked; collection never recomputes
probabilities. Use `plot(res, type = "response_diagnostics")` for paired
or scatter views, retaining available Infit when Outfit is undefined.
Ordinary diagnostic, comparison, prediction and interval attachments and
individual rater sheets are unavailable; a numerical solution is not a
rater-quality judgment.

## Provisional two-family results

For a two-slope-family GPCM fit, `mfrm_results(fit)` collects its saved
estimates and numerical status, with `include = c("fit", "plots")` when
omitted. Neither `compute` setting fits, integrates or calculates
diagnostics. The `gpcm_fitted_slopes`, `gpcm_fitted_locations` and
`gpcm_fitted_steps` tables retain all saved non-Person estimates when
`"fit"` is included. `gpcm_interpretation_notes` retains the incomplete
method qualification even when no intervals are attached; it accompanies
the result/report CSV tables. Locations retain their centering
reference; steps identify their owner and level and are centered offsets
within that level. Separately computed experimental
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
results may be attached through `intervals = list(locations = ci)`; step
intervals remain unavailable. Reports and CSV exports retain these
values; the report shows at most 20 rows of each table with an explicit
notice. Explicit unsupported sections or attachments are rejected.
Attach saved
[`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
results through `intervals`; these contain provisional fitted values
without intervals. Summary, tables, named curve plots, reports and saved
exports retain that limitation. Separately requested
`confint(fit, parm = "slopes")` results can be attached as
`intervals = list(slopes = ci, curves = curves)`. Their experimental
component-slope approximation, owner identities, numerical checks and
unavailable outcomes follow the saved tables, plots and report. If
exactly one saved curve, slope/location-interval or response-diagnostic
plot is available, `plot(res)` displays it. With multiple saved plots,
select `type` from `summary(res)$plot_map`; no new curves or diagnostics
are calculated. Replay code saves and reloads the complete result,
including the fit's owner identities, estimation settings and unresolved
numerical status. Attach saved conditional new-Person output as
`scores = scores`, from
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
or the format-6 portable calibration workflow. The source identity must
match this fit's calibration, data, category/owner coding, integration
settings and recorded status. Collection does not repeat source checks
or scoring. New source identifiers exclude the writing R version and
attribute insertion order. Older scores without an identity or with a
version-dependent identity still support their standalone methods;
regenerate them if attachment is refused (also re-extract an older
portable calibration), without re-estimating the fit. `person_scores`
and `scoring_*` tables retain unrounded estimates, conditional interval
meanings, source/batch checks, omissions and review labels in reports,
CSV exports and saved replay. Native scoring records omitted row counts
but does not enumerate a not-scored Person roster; portable scoring
retains it. This attachment adds tables and reports; it does not add a
score plot route. The intervals exclude calibration uncertainty;
coverage and population transport remain unqualified.
[`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
provides the separately checked portable route without retaining
training responses. Ordinary diagnostics, Wright/Pathway maps and model
comparison are unavailable. The starter export uses the available saved
curves instead of requesting an unsupported Wright map.

## Saved one-family GPCM Person scores

First compute `scores <- predict_mfrm_units(fit, new_ratings)` under the
intended scoring prior, then attach them with
`res <- mfrm_results(fit, scores = scores, include = "fit", compute = "never")`.
This accepts the existing ordinary MML/JML scoring routes and their
recorded review restrictions; it does not extend scoring to new designs
or estimators. Collection checks the fitted calibration, data,
population coding and numerical state, plus the saved prior, interval
and integration records. It does not refit, rescore or repeat source
numerical checks. Older scores without compatible fitted-analysis
identity or check records must be recreated from the saved fit before
attachment; no model refit is needed.

`res$tables$person_scores` retains EAP (`Estimate`), posterior `SD`,
continuous equal-tail posterior bounds (`Lower`, `Upper`), level and
numerical status. Posterior SD is neither the SD of EAPs across Persons
nor the population SD or a calibration-parameter SE. These bounds differ
from the diagnostic EAP +/- normal-multiplier times posterior-SD bands
elsewhere in the report. Neither route includes calibration/population
estimation uncertainty or establishes frequentist coverage for fixed
abilities.

`scoring_priors` retains each Person's fitted and scoring priors,
including explicit prior overrides and covariate-dependent means. The
scalar `PriorMean`/`PriorSD` in `scoring_settings` are NA when they
differ by Person; use `scoring_priors` instead. `scoring_integration`,
`scoring_row_review` and any `scoring_population_review` retain checks
and omissions. Native scoring does not enumerate a complete not-scored
Person roster: `NotScored` is NA. Review-only scores stay review-only
even when calibration-parameter inference has a different readiness
state. JML-derived EAP scores are post hoc posterior summaries, not the
original JML Person estimates.

[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
retain all attached tables and complete saved scoring objects. Replay
reloads them without recomputing. This adds no score plot route;
ordinary diagnostic maps keep their existing targets and are not
replaced by the attached scores.

## Saved GPCM inference

Attach explicitly selected results, for example
`intervals = list(slopes = confint(fit, parm = "slopes", scale = "standardized"))`.
Tables retain the target, method, confidence level and multiplicity
choice;
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
preserve them. Names become lowercase plot routes, e.g.
`plot(res, type = "gpcm_slopes")`, when `"plots"` is included. A single
result uses `"gpcm_inference"`. Passing a raw slope bootstrap object
selects its default relative 95% pointwise intervals; pass
`confint(bootstrap, ...)` to select a different target or level. Replay
reloads saved results, without refitting or changing interval methods.
Older intervals lacking source metadata must be recomputed from the
saved fit. These results supplement ordinary location and fit displays;
discrimination is not rater quality and does not select scoring weights.

## Testlet and random-rater results

[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
and
[`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
results use a separate reporting route within the same `mfrm_results`
class. It always retains calibration estimates, numerical checks,
settings, data usage and interval meanings. Requested ordinary-model
sections that are unsupported are marked `not_available`. Neither
`compute` setting fits, scores, resamples or computes diagnostics for
these models. Supply separately computed `predictions`, `scores` or
`intervals` explicitly; their absence is recorded. Rebuild results from
an older saved fit to apply current calibration-bound defaults without
refitting. Previously saved result bundles keep their original tables.
Explicit normal bounds do not improve their coverage.

Use
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
for a static report and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
for CSV/HTML/RDS and figures. Numerical convergence does not establish
model adequacy or general interval coverage. The ordinary Wright map,
residual diagnostics, Shiny viewer, response-MI pooling and
portable-calibration workflow do not support these classes. Plot types
are `"calibration"` (first fixed facet by default; select with `facet`)
and `"scores"` for testlets, or `"raters"`, `"intervals"` and `"scores"`
for random-rater results. Both support `"comparison"` and, with
corresponding saved quantities, `"response_comparison"` and
`"response_diagnostics"`. These models also support `"wright"` and
`"fit_pathway"` through the separately defined conditional-location and
posterior-residual routes in
[mfrmr_model_maps](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_model_maps.md),
with matching saved source evidence. All these routes require `"plots"`
in `include`; saved predictions/intervals are required for their
corresponding plots. Report styles use the same stored evidence and
boundaries; they do not add ordinary-model reporting templates.

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
# Long-running workflow; run explicitly when needed.
# example("mfrm_results", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Load the package and example ratings
library(mfrmr)
ratings <- load_mfrmr_data("example_operational")

# Fit these ratings; replace the data-loading line for your own analysis
fit <- fit_mfrm(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1, rating_max = 4, category_policy = "preserve",
  method = "MML",
  model = "RSM"
)

# Build the fuller results object, including diagnostics
res <- mfrm_results(fit)
review <- summary(res)
review$decision
review$next_actions

# Draw the Wright map
plot(res)
} # }
```
