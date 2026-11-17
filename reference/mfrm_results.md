# Collect fitted estimates, diagnostics and reporting tables

Combine a fitted model and matching diagnostics, intervals, predictions,
or scores into a reusable `mfrm_results` bundle for
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html), and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md).
Start with `summary(res)$decision`, `$triage`, and `$status`;
unsupported or unrequested sections remain marked `not_available` or
`not_computed`.

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
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md),
  or
  [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  (or an unambiguous long-format `data.frame` with `Person`/`Score` and
  recognizable facet names; native CML and comparison-only fits use
  their own [`summary()`](https://rdrr.io/r/base/summary.html) and
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  methods).

- include:

  Section names (`"fit"`, `"diagnostics"`, `"tables"`, `"precision"`,
  `"reporting"`, `"categories"`, `"plots"`, `"facets_fit"`, `"bias"`,
  `"misfit"`, `"linking"`, `"network"`, `"apa"`, `"response_time"`) or
  purpose presets (`"standard"`, `"publication"`, `"validation"`,
  `"facets"`, `"bias"`, `"misfit_review"`, `"linking"`, `"network"`,
  `"gpcm_review"`, `"all"`). Two-family GPCM defaults to
  `c("fit", "plots")`.

- response_time, response_time_data, response_time_facets,
  response_time_score:

  Optional descriptive response-time column, source long-format
  `data.frame`, facet columns, and score column for
  `include = "response_time"`.

- output:

  Return format: `"object"` (`mfrm_results`), `"summary"`, `"tables"`,
  or `"html"`.

- diagnostics, response_diagnostics:

  Optional matching
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  or
  [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  output, identity-checked and reused without recomputation.

- compute:

  `"auto"` (default) computes requested ordinary diagnostics when
  omitted; `"never"` reuses supplied/stored diagnostics only and marks
  missing dependent sections `"not_computed"`.

- predictions, scores:

  Optional matching [`predict()`](https://rdrr.io/r/stats/predict.html)
  or
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  /
  [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  /
  [`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
  / format-6
  [`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  outputs.

- intervals:

  Optional saved
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
  [`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md),
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  (`"slopes"`/`"steps"`),
  [`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md),
  [`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md),
  or
  [`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md)
  object (or named list), identity-checked against `fit` without
  recalculating intervals.

- comparison:

  Optional matching extended-model
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  result.

- calibration_intervals, calibration_level:

  For testlet/random-rater fits, `"none"` (default) or explicit
  `"normal"` fixed-facet/step intervals at `calibration_level` (`0.95`
  default).

## Value

Depending on `output`, an `mfrm_results` object, `summary.mfrm_results`,
named table list, or `mfrm_results_html` object.

## Details

**Reading order and attached inference.** Inspect `overview`,
`readiness`, `fit_readiness*`, `triage`, `status`, `plot_map`, and
`next_actions` in `summary(res)`. Named `intervals` attachments expose
dedicated plot routes (`plot(res, type = "facet_<name>")` or
`"gpcm_<name>"`) without altering Wright-map uncertainty. Two-family
GPCM, corrected JML, testlet, and random-rater fits retain their
estimator-specific tables, status flags, and plot maps (`"calibration"`,
`"raters"`, `"scores"`, `"response_diagnostics"`, or
[mfrmr_model_maps](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_model_maps.md)
where applicable). Exports and RDS archives retain participant
identifiers without automatic deidentification.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
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
