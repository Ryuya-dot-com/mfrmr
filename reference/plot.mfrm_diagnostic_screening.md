# Plot a diagnostic-screening validation study

Builds an integrated visual summary from
[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
output. The default view combines legacy residual, strict marginal,
strict pairwise, strict combined, and optional report-index review rates
so simulation results can be inspected in one operating-characteristic
surface.

## Usage

``` r
# S3 method for class 'mfrm_diagnostic_screening'
plot(
  x,
  type = c("overview", "report", "contrast", "runtime"),
  metric = NULL,
  x_var = c("n_person", "n_rater", "n_criterion", "raters_per_person"),
  group_var = NULL,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md).

- type:

  Plot family. `"overview"` combines screening and optional report rates
  or counts. `"report"` focuses on
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  review signals. `"contrast"` plots
  misspecification-minus-well-specified contrasts. `"runtime"` plots
  elapsed-time summaries.

- metric:

  Metric family. Use `NULL` or `"auto"` for the default within each
  `type`. Supported values are documented by error messages and include
  `"rate"`, `"count"`, `"magnitude"`, `"elapsed"`, and
  `"per_observation"` depending on `type`.

- x_var:

  Design variable for the horizontal axis. Public design aliases from a
  simulation specification are accepted.

- group_var:

  Optional additional design variable to include in group labels. Public
  design aliases are accepted.

- draw:

  Logical; if `FALSE`, return the plot-data bundle without drawing.

- ...:

  Reserved for future extensions.

## Value

An `mfrm_plot_data` object with reusable metadata, a long-form
`plot_long` table, and interpretation handoff tables (`overview`,
`reading_order`, `next_actions`, `reporting_notes`, and
`figure_recipes`). When `draw = TRUE`, the object is returned invisibly
after drawing.

## Examples

``` r
if (FALSE) { # \dontrun{
diag_eval <- evaluate_mfrm_diagnostic_screening(
  design = list(person = 10, rater = 2, criterion = 2, assignment = 2),
  reps = 1,
  maxit = 30,
  include_report = TRUE,
  seed = 123
)
plot(diag_eval, type = "overview", draw = FALSE)
plot_data(diag_eval, type = "overview", component = "plot_long")
plot_data(diag_eval, type = "overview", component = "next_actions")
plot_data(diag_eval, type = "overview", component = "figure_recipes")
plot(diag_eval, type = "report", metric = "rate", draw = FALSE)
} # }
```
