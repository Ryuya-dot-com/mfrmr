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
  output = c("object", "summary", "tables", "html")
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
  `Person` and `Score`; all remaining columns are treated as facets.

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
workflow. The returned object also carries `next_actions` and
`input$reproducible_code` so users can move from the comprehensive first
screen to explicit reporting or replay code.

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

- `triage`: first-screen signals ordered by unavailable/review/info/ok

- `status`: which sections were available, skipped, or unsupported

- `plot_map`: the supported `plot(res, type = ...)` routes for this
  object

- `next_actions`: recommended follow-up calls

- `reproducible_code`: replay scaffold for the first-screen route

## Data-frame input

Direct data-frame input is intentionally conservative. It is intended
for standard columns such as `Person`, `Score`, `Rater`, and
`Criterion`. For research scripts, use
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
or
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
explicitly when column roles, model, method, anchors, or missing-data
rules need to be documented. Use
[`mfrm_results_interactive()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results_interactive.md)
only when you want an opt-in column-selection wizard in an interactive
session.

## Visualization and HTML

`plot(res)` routes to a FACETS-style model-level visual bundle by
default. Other routes include `plot(res, type = "wright")`, `"pathway"`,
`"qc"`, `"category"`, `"anchors"`, and `"tables"`. `output = "html"`
writes a lightweight temporary HTML file; use
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md)
when you want an optional local Shiny reader for an already-created
`mfrm_results` object. Use
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
for a lightweight download of the comprehensive results object, or
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
when a fit-centered durable analysis archive is needed.

## Typical workflow

1.  Fit explicitly with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    in scripts and manuscripts.

2.  Call `res <- mfrm_results(fit)`.

3.  Read `summary(res)$triage`, `summary(res)$status`,
    `summary(res)$plot_map`, and `summary(res)$next_actions`.

4.  Call `report <- mfrm_report(res)` when a report-ready surface is
    needed.

5.  Use
    [`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
    to write CSV, report, RDS, replay, and manifest files for handoff or
    review.

6.  Use `plot(res, type = "qc")` for the first visual screen.

7.  Optionally inspect the same result with
    [`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md)
    in an interactive session.

8.  Use
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
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:8], , drop = FALSE]

# JML keeps the help example fast; use the recommended workflow settings
# for final analyses.
fit <- fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
res <- mfrm_results(fit)

sx <- summary(res)
sx$overview
sx$triage
sx$plot_map
sx$next_actions
mfrm_results(fit, include = "validation", output = "summary")$status

plot(res, type = "qc", draw = FALSE)

# Direct data-frame input is available for conservative exploratory use
# when Person and Score columns are unambiguous.
mfrm_results(
  toy_small,
  include = c("fit", "diagnostics"),
  output = "summary"
)$mapping
} # }
```
