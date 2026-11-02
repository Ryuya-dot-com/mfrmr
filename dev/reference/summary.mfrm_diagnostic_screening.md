# Summarize a diagnostic-screening simulation study

Summarizes output from
[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/evaluate_mfrm_diagnostic_screening.md)
for reporting, appendix export, and draw-free visualization handoff. The
summary keeps simulation operating characteristics separate from
inferential conclusions: fit, marginal, pairwise, and report-review
signals are screening readouts rather than pass/fail evidence.

## Usage

``` r
# S3 method for class 'mfrm_diagnostic_screening'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/evaluate_mfrm_diagnostic_screening.md).

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
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_report.md)
  readiness/review signals

- `scenario_contrast`: misspecification-minus-well-specified contrasts

- `plot_*`: long-form draw-free plot tables for overview, report,
  contrast, and runtime views

- planning metadata, settings, ADEMP metadata, and interpretation notes

## See also

[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/evaluate_mfrm_diagnostic_screening.md),
[plot.mfrm_diagnostic_screening](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_diagnostic_screening.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.mfrm_diagnostic_screening", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-diagnostic-screening.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
diag_eval <- saved$result
summary(diag_eval)
} # }
```
