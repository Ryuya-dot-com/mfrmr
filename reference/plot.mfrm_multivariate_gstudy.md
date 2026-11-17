# Inspect sources of observed-score variation

Plot raw variance components for selected scores or one prespecified
weighted score, or inspect the component covariance matrices. Then use
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
to assess how changing the measurement conditions affects G, Phi and
SEM.

## Usage

``` r
# S3 method for class 'mfrm_multivariate_gstudy'
plot(
  x,
  score = NULL,
  weights = NULL,
  draw = TRUE,
  preset = "standard",
  type = c("components", "covariance"),
  ncol = NULL,
  intervals = FALSE,
  assumption = NULL,
  level = 0.95,
  method = "auto",
  draws = 20000L,
  seed = 20261016L,
  ...
)
```

## Arguments

- x:

  A result from
  [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md).

- score:

  Original score names in display order. Multiple scores produce
  separate component panels. The default selects the first score for
  `type = "components"`, or all scores for `type = "covariance"`. Do not
  supply both `score` and `weights`.

- weights:

  Optional named numeric vector defining one composite. Name every score
  exactly once, with finite weights and at least one nonzero value.
  Names determine order. Signed weights permit difference scores;
  weights are not normalized. For a saved D-study, use its selected
  weight vector, for example `plot(d$gstudy, weights = d$weights)`.

- draw:

  Draw the figure; `FALSE` only returns its data.

- preset:

  Plot style: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`. Omission uses the session plot default.

- type:

  `"components"` for variance-component points, or `"covariance"` for
  one matrix heatmap per source. With `intervals = TRUE`, covariance
  instead displays one signed interval plot for exactly two selected
  scores. Covariance plots do not accept `weights`.

- ncol:

  Positive number of panel columns. Defaults to at most two.

- intervals:

  Logical; `FALSE` (default) shows point estimates. `TRUE` adds
  component confidence intervals in the same call; also specify
  `assumption = "normal"`. Available for complete balanced ANOVA
  component plots, including supported nesting. Covariance intervals
  require an explicit method and exactly two scores. Explicit
  `method = "reml_profile"` also provides variance and two-score
  covariance intervals for identifiable incomplete sources, fitting a
  separate REML model while preserving the original points.
  `method = "residual_contrast"` uses retained ratings without
  likelihood fitting, but only Residual receives an interval. Other
  points remain visible with unavailable intervals and their reasons.
  Other methods use saved ANOVA summaries without refitting.

- assumption:

  With `intervals = TRUE`, explicitly specify `"normal"` for independent
  normal random effects with constant component variances. This
  assumption is not tested.

- level:

  Pointwise confidence level for `intervals = TRUE`, default 0.95.

- method:

  Component interval method passed to
  [`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md).
  Single-score/composite variances use `"auto"` or `"mls"` for balanced
  ANOVA, or explicit experimental `"reml_profile"` for
  balanced/identifiable incomplete sources. Profile intervals have
  approximate calibration and no accompanying sampling SE. Covariance
  intervals require explicit `"gci"`, `"regression_region"` or
  `"reml_profile"`; none is an automatic default. Explicit
  `"residual_contrast"` also supports incomplete sources for Residual
  only: exact normal-model variance limits or conservative covariance
  limits. It retains original points and a separate interval center
  without supplying the original estimator's sampling SE.

- draws, seed:

  Numerical settings for covariance `method = "gci"`. Defaults are 20000
  pivotal draws and seed 20261016. See the confidence interval help for
  requirements and numerical endpoint bands.

- ...:

  Reserved; additional arguments are rejected.

## Value

Invisibly, a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts `table` (source, display label, selected estimate, sign status
and full component-matrix PSD diagnostic), `weights`, `score`, `kind`,
`source_design`, `source_rows`, axis labels and notes. `plot`, `panels`
and `ncol` describe the view. Component tables include `Score`;
covariance tables include `Row`, `Column` and `Element` (variance or
covariance), with a shared `fill_limits` and `heat_colors` palette. With
intervals, `table` also includes `SE`, `Lower`, `Upper`, `RawLower`,
`RawUpper`, `Level`, `Method`, `IntervalStatus` and `IntervalAvailable`.
`intervals` retains one complete
[`confint()`](https://rdrr.io/r/stats/confint.html) table per selected
score or composite, with its assumptions and source context;
`unavailable_intervals` retains rows without a drawable interval.
`Status` still describes the sign of the point estimate. REML component
tables additionally retain `IntervalCenter`, `SEStatus`, candidate
bounds and `Validation`; full numerical profiles are retained in
`intervals`. Saving the plot preserves them for
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
reuse. Covariance interval plots have `kind = "Covariance"`, one forest
panel, and the original pair in `score`. The full interval table retains
covariance units, assumptions, numerical bands and SE/interval
diagnostics. Save the result with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) for later
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
conversion, without recalculating intervals, or save the G-study to
redraw it.

## Details

Plots raw individual-rating variance components in squared score units
(or \\w' \Sigma_s w\\ for composite `weights`, without future-count
division). Nonnegative estimates use filled circles; unconstrained
negative estimates remain unclipped to the left of zero as open circles,
and `ComponentPSD` tracks full-matrix positive semidefiniteness. The
last source (`Residual`) combines the highest-order interaction and
within-cell error; D-study relative/absolute error instead aggregates
across multiple components (see
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)).

With `intervals = TRUE`, horizontal bars show pointwise intervals from
[`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md)
(square outlines mark unavailable rows recorded in
`unavailable_intervals`; `"reml_profile"` and `"residual_contrast"`
retain original points alongside `IntervalCenter`).
`type = "covariance"` displays unstandardized variance-covariance
heatmaps centered at zero, or a two-score signed interval forest plot
when `intervals = TRUE` with an explicit method.

## See also

[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md),
[`plot.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_d_study.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_multivariate_gstudy", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
p <- plot(g, weights = c(V = .5, W = .5), preset = "monochrome",
          intervals = TRUE, assumption = "normal")
plot_data(p, "table")
plot_data(p, "notes")
plot(g, score = c("V", "W"))
covariance_plot <- plot(g, type = "covariance")
plot_data(covariance_plot, "table")
if (requireNamespace("ggplot2", quietly = TRUE)) {
  as_ggplot(p)
}
} # }
```
