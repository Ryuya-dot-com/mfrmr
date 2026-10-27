# Plot DIF/bias screening simulation results

Plot DIF/bias screening simulation results

## Usage

``` r
# S3 method for class 'mfrm_signal_detection'
plot(
  x,
  signal = c("dif", "bias"),
  metric = c("power", "false_positive", "estimate", "screen_rate",
    "screen_false_positive"),
  x_var = c("n_person", "n_rater", "n_criterion", "raters_per_person"),
  group_var = NULL,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md).

- signal:

  Whether to plot DIF or bias screening results.

- metric:

  Metric to plot. For `signal = "bias"`, prefer `metric = "screen_rate"`
  for the screening hit rate. The older `metric = "power"` spelling is
  retained as a backwards-compatible alias that maps to
  `BiasScreenRate`. `"estimate"` plots the signed reference-minus-focal
  DIF contrast or the additive bias shift. A refit contrast requires
  common-scale linking.

- x_var:

  Design variable used on the x-axis. When `x` was generated from a
  `sim_spec` with custom public facet names, the corresponding aliases
  (for example `n_judge`, `n_task`, `judge_per_person`) are also
  accepted. Role keywords (`person`, `rater`, `criterion`, `assignment`)
  are accepted as an abstraction over the current two-facet schema.

- group_var:

  Optional design variable used for separate lines. The same alias rules
  as `x_var` apply.

- draw:

  If `TRUE`, draw with base graphics; otherwise return plotting data.

- ...:

  Reserved for generic compatibility.

## Value

If `draw = TRUE`, invisibly returns plotting data. If `draw = FALSE`,
returns that plotting-data list directly. The returned list includes
resolved canonical variables (`x_var`, `group_var`) together with public
labels (`x_label`, `group_label`), `design_variable_aliases`,
`design_descriptor`, `planning_scope`, `planning_constraints`,
`planning_schema`, `display_metric`, and `interpretation_note` so
callers can label bias-side plots as screening summaries rather than
formal power/error-rate displays. `summary_table` retains per-design
means and availability denominators; `notes` retains interpretation and
legacy-result restrictions. If additional design variables are
collapsed, each plotted point is an equally weighted average of
available design-level means, not a pooled trial/cell rate.

## See also

[`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md),
[summary.mfrm_signal_detection](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_signal_detection.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_signal_detection", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-signal-detection.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
sig_eval <- saved$result
plot(sig_eval, signal = "dif", metric = "power", x_var = "n_person", draw = FALSE)
} # }
```
