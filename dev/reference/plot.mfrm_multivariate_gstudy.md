# Inspect sources of observed-score variation

Plot raw variance components for selected scores or one prespecified
weighted score, or inspect the component covariance matrices. Then use
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_d_study.md)
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
  [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_g_study.md).

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
  [`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/confint.mfrm_multivariate_gstudy.md).
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
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
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
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
reuse. Covariance interval plots have `kind = "Covariance"`, one forest
panel, and the original pair in `score`. The full interval table retains
covariance units, assumptions, numerical bands and SE/interval
diagnostics. Save the result with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) for later
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
conversion, without recalculating intervals, or save the G-study to
redraw it with base graphics.

## Details

Each point is a variance-component estimate in squared score units. For
weights \\w\\, the component is \\w' \Sigma_s w\\, including
between-score covariances. Multiplying all weights by a constant
multiplies each component by its square. Components describe the source
model at the individual rating level; they have not been divided by
future facet counts. They are not percentages, measurement-error shares
for a future mean score, or MFRM severity estimates. A larger Person
component describes greater person variation, not a defect in the
assessment. A large rater component does not by itself identify which
rater should receive feedback.

Negative estimates remain to the left of zero as open circles;
nonnegative estimates use filled circles. An unconstrained negative
estimate is not a negative population variance. Inspect the data/design
and component diagnostics before interpreting it. No component is
clipped, normalized or removed. A covariance matrix can be
non-positive-semidefinite even when its projection for the selected
score is positive; this is retained in the returned table and notes.

With `intervals = TRUE`, horizontal bars replace the stems from zero.
They show the nonnegative-space intervals from
[`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/confint.mfrm_multivariate_gstudy.md):
approximate Ting MLS intervals for components and chi-square intervals
for the combined residual. They are pointwise, not simultaneous across
components or scores. Negative point estimates can lie outside their
nonnegative-space intervals. Square outlines mark estimates without an
interval; consult `IntervalStatus` and `unavailable_intervals` for the
reason. An empty interval or degenerate mean squares do not mean zero
uncertainty. Raw endpoints, SEs and the full interval tables remain in
the returned data. These intervals concern source variances, not future
mean-score errors, G/Phi or off-diagonal covariance elements. With
`intervals = FALSE`, stems run from zero to the estimate and do not
represent uncertainty.

With `method = "reml_profile"`, the bars instead show approximate
restricted-likelihood component intervals. The points remain the
original ANOVA/MINQUE estimates; the separate `IntervalCenter` is
retained in the table. Profile `SE` and inapplicable MLS
`RawLower/RawUpper` columns are `NA`; `SEStatus` explains this.
Numerical availability does not establish coverage, especially near zero
variances. The interval surrounds the REML center but does not enumerate
remote disconnected accepted regions.

With `method = "residual_contrast"`, only Residual receives a bar, based
on a projection that removes all nonresidual effects. Points still show
original ANOVA/MINQUE components; `IntervalCenter` records the projected
residual estimate. No remaining residual degrees of freedom or
numerically unresolved residual variation means unavailable limits.
Exact variance coverage and conservative covariance coverage require the
normal residual model at a fixed observed assignment; they do not extend
to other sources or nonrandom omissions. See *Residual contrasts* in the
interval help.

Multiple-score component panels share axes. Compare their magnitudes
only when the score units are comparable. Covariance heatmaps show the
selected submatrix for every source, with variances on the diagonal and
covariances off the diagonal. Covariance units are the product of the
two score units; these are not correlations. All panels share a color
scale centered at zero and include signed numeric labels. Color presets
use a diverging palette; `"monochrome"` uses a gray scale. Values are
neither standardized nor converted to correlations. A negative
covariance can be legitimate; a negative variance is an unconstrained
estimate, not a population variance. `ComponentPSD` and returned notes
describe the full source matrix even if only a subset of scores is
shown. A large covariance alone does not diagnose halo. Cell labels are
rounded for display; the table keeps exact values.

With `type = "covariance", intervals = TRUE`, select exactly two scores
and an explicit method. A single horizontal interval plot across sources
replaces the heatmaps. Covariance endpoints remain signed, including
negative values. `"gci"` has approximate coverage and separate Monte
Carlo endpoint bands; `"regression_region"` has conservative
normal-model coverage but may be very wide. Square outlines retain
unavailable intervals. `SEStatus` is separate: a one-df block can
prevent an SE while still permitting a conservative interval. Open
circles mark negative covariances, which can be legitimate. Explicit
`"reml_profile"` instead fits a joint normal model, also for incomplete
sources, and retains its separate `IntervalCenter` and full numerical
diagnostics. Its chi-square calibration is experimental and can
under-cover with few facet levels; no sampling SE is supplied. None of
these methods is a correlation interval.

All estimated interactions are shown. The table preserves the original
`Source` identifiers and adds a readable `Label`. For a crossed Person,
Rater and Task design, the last label is "Person x Rater x Task +
residual". Its `Source` remains `Residual`: with one observation per
cell, the highest-order interaction and other residual variation cannot
be estimated separately. A one-facet design instead shows "Person x
Task + residual" (or the declared facet name); a nested design shows,
for example, "Person x Rater(Task) + residual". No extra independent
error component should be added to these combined estimates.

Measurement error is not synonymous with the component called
`Residual`. For the supported random-facet mean-score projections,
relative error includes the person-by-condition interactions and
combined residual; absolute error additionally includes condition main
effects and interactions without Person. The D-study divides each
component by its applicable future counts, then adds these terms. Use
`plot(d, type = "sem")` to view the square roots of the two error
variances. Neither SEM nor a residual-component point is a sampling
confidence interval. See
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_d_study.md)
for the formulas and assumptions, and
[`vignette("mfrmr-gtheory")`](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-gtheory.md)
for a worked source-to-error example.

This plot reads stored component estimates and preserves missing-data
rules. Explicit REML intervals fit a separate model without replacing
those points; other interval methods use the saved summaries. Titles and
explanations are returned separately from the figure. Use
`plot_data(p, "notes")` and keep them when sharing a figure. Both base R
graphics and optional
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
conversion are supported.

## See also

[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_g_study.md),
[`plot.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_multivariate_d_study.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
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
