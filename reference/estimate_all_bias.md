# Estimate bias across multiple facet pairs

Estimate bias across multiple facet pairs

## Usage

``` r
estimate_all_bias(
  fit,
  diagnostics = NULL,
  pairs = NULL,
  include_person = FALSE,
  drop_empty = TRUE,
  keep_errors = TRUE,
  max_abs = 10,
  omit_extreme = TRUE,
  max_iter = 4,
  tol = 0.001
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When `NULL`, diagnostics are computed with `residual_pca = "none"`.
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
  for migration of saved diagnostics.

- pairs:

  Optional list of facet specifications. Each element should be a
  character vector of length 2 or more, for example
  `list(c("Rater", "Criterion"), c("Task", "Criterion"))`. Explicit
  specifications may include canonical `"Person"` regardless of
  `include_person`. When `NULL`, all 2-way combinations of modeled
  facets are used. Each combination may appear only once, regardless of
  facet order.

- include_person:

  If `TRUE` and `pairs = NULL`, include `"Person"` in the automatically
  generated pair set. `"Person"` denotes the source column supplied as
  `person` to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  and remains opt-in because these cells condition on fitted JML person
  measures or MML EAP scores.

- drop_empty:

  If `TRUE`, omit empty bias tables from `by_pair` while still recording
  them in the summary table.

- keep_errors:

  If `TRUE`, also retain per-pair error rows in the returned `errors`
  table. Either way, errors remain in `summary$Error` and do not stop
  the batch.

- max_abs:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- omit_extreme:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- max_iter:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- tol:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

## Value

A named list with class `mfrm_bias_collection`.

## Details

This function orchestrates repeated calls to
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
across multiple facet pairs and returns a consolidated bundle.

**Bias/interaction** in MFRM refers to a systematic departure from the
additive model for a specific combination of facet elements (e.g., a
particular rater is unexpectedly harsh on a particular criterion). See
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
for the mathematical formulation.

When `pairs = NULL`, the function builds all 2-way combinations of
modelled facets automatically. For a model with facets Rater, Criterion,
and Task, this yields Rater\\\times\\Criterion, Rater\\\times\\Task, and
Criterion\\\times\\Task. With `include_person = TRUE`,
Person\\\times\\facet pairs are prepended in the fit's facet order. They
are conditional plug-in likelihood screens, not jointly fitted
Person\\\times\\facet terms. A single warning records this boundary for
the batch.

The `summary` table aggregates results across pairs:

- `Rows`: number of interaction cells estimated

- `Points`: cells with an available bias estimate (including bounded
  optima; inspect `BiasStatus` in the combined cells)

- `ScreenAvailable`, `ScreenUnavailable`: cells with/without a usable
  conditional screening statistic

- `ScreenPositive`: count of available cells with \\\|t\| \ge 2\\; `NA`
  when no screening statistic is available, including failed pairs

- `Significant`: backward-compatible alias for `ScreenPositive`

- `MeanAbsBias`: average absolute available bias magnitude (native
  ability units)

- `Status`: `available`, `partial`, `unavailable`, `empty`, or `failed`;
  `available` refers to conditional screening, not formal inference

- `FormalInferenceEligible` / `PrimaryReportingEligible`: always
  `FALSE`; these conditional plug-in interaction statistics are
  screening evidence

Per-pair failures (e.g., insufficient data for a sparse pair) are
captured in `errors` rather than stopping the entire batch. There is no
collection-wide multiplicity correction. Cells and pairs reuse the same
observations and fitted calibration. Adjusting their screening tail
areas would not establish formal family-wise error or false-discovery
control. A screen-positive result is a prompt for review, not proof of
unfairness; no screen-positive cells does not establish absence of
interaction. Search-boundary points remain visible, with missing
screening statistics and the `ScreenStatus`/`ScreenReason` returned by
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

## Output

The returned object is a bundle-like list with class
`mfrm_bias_collection` and components such as:

- `summary`: one row per requested interaction

- `by_pair`: named list of successful
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  outputs

- `errors`: per-pair error log

- `settings`: resolved execution settings

- `primary`: first successful bias bundle, useful for downstream helpers

## Typical workflow

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and diagnose with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
    For `RSM` / `PCM` reporting runs, prefer `method = "MML"` plus
    `diagnostic_mode = "both"` in the diagnostics call.

2.  Run `estimate_all_bias()` to compute the requested multi-pair
    interactions.

3.  Inspect `summary(bias_all)$overview` for availability and magnitude,
    then `summary(bias_all)$cells` for all retained cells and their
    observed counts. Use
    [`plot.mfrm_bias_collection()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bias_collection.md)
    for the overview or a named pair.

4.  Use `report <- mfrm_report(bias_all)` to retain the full search,
    failed pairs and all cells in one report;
    [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
    saves its tables. Supply `study_context` to state rubric endpoints
    and score direction. The `by_pair` list also feeds
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    or
    [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md).

5.  For a substantively justified joint interaction model, use
    `facet_interactions` in
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and
    [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
    on compatible fits. Selecting terms from these screens makes
    same-data comparisons exploratory; it does not create a prespecified
    confirmatory test.

## Saved-result reuse

The returned `fit_identity` records the fitted analysis for reuse with
reports and exports. Recreate older results from the saved fit and
matching diagnostics using the original screening options; no model
refit is needed. See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
for migration instructions.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("estimate_all_bias", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML")
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
bias_all <- estimate_all_bias(fit, diagnostics = diag)
summary(bias_all)
head(summary(bias_all)$cells)
report <- mfrm_report(bias_all, study_context = c(
  score_direction = "Higher coded scores indicate better performance"))
report$tables$overview
head(report$tables$bias_cells)
} # }
```
