# Summarize assessment plans with their uncertainty

Read G, Phi and measurement SEM together with their confidence
intervals, methods and limitations. Ordinary `summary(d)` retains its
coefficient-table return value. Request intervals explicitly, or reuse
saved interval results.

## Usage

``` r
# S3 method for class 'mfrm_multivariate_d_study'
summary(
  object,
  intervals = FALSE,
  parm = c("G", "Phi", "RelativeSEM", "AbsoluteSEM"),
  ...
)

# S3 method for class 'summary.mfrm_multivariate_d_study'
print(x, digits = NULL, row.names = FALSE, ...)
```

## Arguments

- object:

  A result from
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md).

- intervals:

  `FALSE` (default) returns the original coefficient table. `TRUE`
  calculates the selected intervals using
  [`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md).
  Alternatively supply a saved `confint(d)` result or a list of such
  results. Saved results may contain different metrics, methods, scores
  or reference plans, but must match this D-study's source, plans and
  score weights. GENOVA-adjusted results retain adjusted points
  alongside original-source population intervals, with separate
  `IntervalEstimate` and `IntervalBasis`. Saved intervals must match the
  component treatment too.

- parm:

  Metrics to calculate when `intervals = TRUE`. The default includes
  `"G"`, `"Phi"`, `"RelativeSEM"` and `"AbsoluteSEM"`. Select fewer
  metrics when only those answer your question, particularly for
  explicitly requested expensive profile methods.

- ...:

  With `intervals = TRUE`, arguments to `confint(d)`, including the
  required `assumption = "normal"`, `score` or `composite`, `level`,
  `method`, `reference`, `draws` and `seed`. The default methods and
  score selection are those of `confint(d)`. Unsupported requests fail
  explicitly; no alternative method is selected after a failure. With
  saved results or `intervals = FALSE`, additional arguments are
  rejected. For printing, arguments are passed to the displayed tables.

- x:

  An interval-aware summary returned by this method.

- digits:

  Display precision passed to the printed tables; `NULL` uses R's
  current setting. Stored estimates are unchanged.

- row.names:

  Logical; print table row names? Defaults to `FALSE`.

## Value

With `intervals = FALSE`, the unchanged `object$coefficients` data
frame. Otherwise a `summary.mfrm_multivariate_d_study` list containing:

- `table`: one row per returned plan, metric and method, with `Interval`
  identifying the entry in `intervals`. It retains all original interval
  columns, including point/interval status, qualifications and any
  separate REML or residual-contrast `IntervalCenter`. Columns not
  applicable to a method are `NA`.

- `intervals`: the complete original interval objects, retaining notes,
  diagnostics, reference context and their existing
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods.

- `source_design`, `source_rows`, `design_grid`, `weights` and
  `component_diagnostics`: the original design, score and review
  context.

- `notes`: method qualifications and interpretation reminders.
  [`print()`](https://rdrr.io/r/base/print.html) returns the same saved
  summary invisibly. For G/Phi with `method = "delta"`, the table
  retains and prints the coefficient sampling `SE`, distinct from
  measurement SEM. For GENOVA-adjusted points it is named `IntervalSE`
  and describes the original estimator, not the adjusted point.
  Normal-reference bounds outside `[0,1]` are not clipped.

## Details

The intervals describe uncertainty from the observed G-study in the
population coefficient or SEM of a specified future complete plan. They
do not represent data already collected under that future plan. G and
Phi are dimensionless; SEM is in the selected score's units. A larger
G/Phi or smaller SEM does not alone determine a worthwhile plan:
consider the intended decision, score meaning and task/rater burden.

`reference` requests the existing paired plan-difference procedure for
each metric. It does not subtract marginal interval endpoints. Positive
G/Phi differences and negative SEM differences favor the comparison
plan, conditional on the stated model. Individual-plan and difference
results remain explicitly labeled if both are supplied as saved results.

Printing and reopening a saved summary do not calculate intervals or
refit models. Printing separates the main estimates, method
qualifications and rows with unavailable points/intervals or incomplete
width formulas; `table` retains all statuses and diagnostics columns. A
completed approximate interval is qualified by its method, not
automatically labeled a failure. Save the complete summary with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) to retain its
context; CSV export of `table` alone loses weights, notes and
diagnostics. Use `plot(s$intervals[[1]])` for its existing forest plot,
or supply a suitable single-metric individual-plan result to
`plot(d, intervals = ...)`. A summary does not create simultaneous
guarantees across metrics, scores or selected plans. Read each method's
qualifications. Availability is not proof of model validity or accurate
finite-sample coverage.

## Choose the operation

`print(d)` displays the D-study and returns it invisibly; `summary(d)`
returns its coefficient table. This opt-in summary collects intervals;
`confint(d)` calculates one metric at a time with the same inference
rules. Neither changes `d`. `print(s)` displays the saved summary
without any estimation, and `s$table` is the data frame for subsetting
or CSV export. Use `plot(d)` for planning curves and
`plot(s$intervals$Phi)` for a saved interval forest. A summary list
itself is not a new plotting input.

This page explains the interface and reading order. Mathematical
constructions, design-specific assumptions, numerical diagnostics and
references are in
[`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md).

## See also

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md),
[`plot.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_d_study.md),
[`plot.mfrm_dstudy_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_dstudy_intervals.md)

## Examples

``` r
# Published synthetic data, not empirical speech-contest records.
ratings <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g <- mfrm_g_study(ratings, c("V", "W"), rater = NULL)
d <- mfrm_d_study(g, data.frame(Tasks = c(6, 12)),
  weights = c(V = .5, W = .5))
# Compare dependability and measurement error under the normal-effects model.
s <- summary(d, intervals = TRUE, assumption = "normal")
print(s, digits = 3)
#> Assessment plans with source-study uncertainty
#> Source G-study: Balanced multivariate ANOVA 
#> Observed level counts (not future replication): Person = 10, Task = 6 
#> Source rows: 60 used of 60 ; 0 explicitly omitted.
#> Future complete balanced plans; counts apply to every person and score.
#> Intervals assume independent normal random effects; the assumption is not tested.
#> Nominal confidence level(s): 0.95 
#> Means over common random tasks 
#> Composite weights (not normalized):
#>   V   W 
#> 0.5 0.5 
#>  Scenario Tasks      Kind     Score      Metric Estimate Lower Upper Level
#>         1     6 Composite Composite           G    0.663 0.187 0.903  0.95
#>         2    12 Composite Composite           G    0.797 0.315 0.949  0.95
#>         1     6 Composite Composite         Phi    0.621 0.145 0.878  0.95
#>         2    12 Composite Composite         Phi    0.766 0.254 0.935  0.95
#>         1     6 Composite Composite RelativeSEM    0.418 0.347 0.527  0.95
#>         2    12 Composite Composite RelativeSEM    0.296 0.245 0.373  0.95
#>         1     6 Composite Composite AbsoluteSEM    0.459 0.389 0.701  0.95
#>         2    12 Composite Composite AbsoluteSEM    0.324 0.275 0.495  0.95
#>  MethodCode
#>     exact_f
#>     exact_f
#>         gci
#>         gci
#>         mls
#>         mls
#>         mls
#>         mls
#> Methods and qualifications:
#>  MethodCode                              Method
#>     exact_f        Exact F under normal effects
#>         gci Generalized CI under normal effects
#>         mls             Chi-square SEM interval
#>         mls      Graybill-Wang MLS SEM interval
#>                                                        Validation
#>                                     Normal-model F confidence set
#>              Generalized interval; frequentist coverage not exact
#>  Exact normal-model interval for positive mean-square expectation
#>           MLS approximation; pointwise coverage is not guaranteed
#> G/Phi are dimensionless; SEM is in score units. Available describes calculation, not coverage.
#> For differences, positive G/Phi and negative SEM favor the comparison plan.
#> Method assumptions and limitations: $notes; complete saved results: $intervals.
# One row per plan for absolute dependability; the complete table is retained.
subset(s$table, Metric == "Phi",
  select = c(Tasks, Estimate, Lower, Upper, Status))
#>   Tasks  Estimate     Lower     Upper    Status
#> 3     6 0.6205514 0.1453685 0.8782785 Available
#> 4    12 0.7658521 0.2538371 0.9351952 Available
# Reuse an interval for a curve, with no interval calculation.
p <- plot(d, metric = "Phi", intervals = s$intervals$Phi, draw = FALSE)
plot_data(p, "notes")
#>           Type
#> 1     subtitle
#> 2      caption
#> 3  uncertainty
#> 4  uncertainty
#> 5  uncertainty
#> 6  uncertainty
#> 7  uncertainty
#> 8  uncertainty
#> 9  uncertainty
#> 10 uncertainty
#> 11 uncertainty
#>                                                                                                                                                                                                                                                                                                                Text
#> 1                                                                                                                                                                                                                          Future complete crossed designs | Saved coefficient intervals | Source-study uncertainty
#> 2                                                                                                                                                                                                                                                                Points are requested scenarios; lines are guides. 
#> 3                                                                                                                                                                                                                                               Nominal 95% intervals; method: Generalized CI under normal effects.
#> 4                           Ribbons connect saved endpoints at requested counts; intermediate plans are not evaluated. Isolated intervals use vertical segments. Open points have no interval; gaps are not interpolated. Inspect unavailable_intervals and the saved interval objects for reasons and diagnostics.
#> 5                                               Ribbons do not establish simultaneous coverage across scores or metrics. Any joint coverage across plans depends on the interval method and its stated model; drawing a band adds no coverage guarantee. Interval overlap does not test a score or plan difference.
#> 6                                                                                                                                                                    Phi includes the random facet main effect in absolute error. Independent normal effects and a complete balanced one-facet source are required.
#> 7                                                                                                                                           This generalized confidence interval does not guarantee exact frequentist coverage. More pivotal draws reduce numerical error, not model uncertainty or coverage error.
#> 8                                                                                                                           The GCI truncates its pivotal numerator at zero, not the source variance estimates. PointStatus and Status describe separate outputs; a zero endpoint is not proof of zero uncertainty.
#> 9                                                                                                                              The monte_carlo attribute contains separate 95% numerical bands for the endpoints. Increase draws if these bands affect the intended decision; save the whole result with saveRDS().
#> 10                                                                                                          All future counts transform the same single-rating interval and use source degrees of freedom. Rows are dependent; overlap does not test a plan difference. These are not pass/fail accuracy intervals.
#> 11 Widths lost to floating-point resolution leave endpoints and their numerical bands unavailable. A base pivotal interval with lost resolution cannot supply difference bounds, including for identical plans. Diagnostic single-rating bounds remain in pivot; the sampled zero atom retains its separate status.
```
