# Summarize a diagnostic-screening validation study

Summarizes output from
[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
for reporting, appendix export, and draw-free visualization handoff. The
summary keeps simulation operating characteristics separate from
validation gates: fit, marginal, pairwise, and report-review signals are
screening readouts rather than pass/fail evidence.

## Usage

``` r
# S3 method for class 'mfrm_diagnostic_screening'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md).

- digits:

  Number of digits used in numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_diagnostic_screening` with:

- `overview`: run-level design, replication, convergence, and
  report-review metadata

- `reading_order`: recommended order for reading the summary tables

- `next_actions`: action-oriented triage for interpreting and exporting
  the summary

- `reporting_notes`: report-facing boundaries and recommended wording
  safeguards

- `figure_recipes`: recommended figure/display recipes for the draw-free
  plot-data tables

- `scenario_summary`: aggregated scenario-by-design screening summaries

- `performance_summary`: operating-characteristic rates and runtime
  summaries

- `report_signal_summary`: optional
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  readiness/review signals

- `scenario_contrast`: misspecification-minus-well-specified contrasts

- `plot_*`: long-form draw-free plot tables for overview, report,
  contrast, and runtime views

- planning metadata, settings, ADEMP metadata, and interpretation notes

## See also

[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md),
[plot.mfrm_diagnostic_screening](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_diagnostic_screening.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
diag_eval <- evaluate_mfrm_diagnostic_screening(
  design = list(person = 10, rater = 2, criterion = 2, assignment = 2),
  reps = 1,
  maxit = 30,
  seed = 123
)
summary(diag_eval)
} # }
```
