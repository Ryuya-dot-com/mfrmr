# Compare D-study confidence interval methods

Compare future plans on one shared coefficient or SEM axis. Each plan
has adjacent method rows, distinguished by color, point shape and line
type. Method agreement in a single dataset is not evidence of coverage.

## Usage

``` r
# S3 method for class 'mfrm_dstudy_intervals'
plot(
  x,
  draw = TRUE,
  preset = "standard",
  ncol = 2L,
  layout = c("combined", "panels"),
  ...
)
```

## Arguments

- x:

  A result from
  [`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/confint.mfrm_multivariate_d_study.md).

- draw:

  Logical; `FALSE` returns the plot data without opening a device.

- preset:

  Package plot style, including `"standard"` (color) and `"monochrome"`.
  Methods also have distinct point shapes.

- ncol:

  Positive integer number of columns for `layout = "panels"`. Unused by
  the default combined view.

- layout:

  `"combined"` (default) groups methods within each plan on one axis,
  with a common method legend. `"panels"` retains one panel per future
  plan, with at most `ncol` columns.

- ...:

  Reserved; additional arguments are rejected.

## Value

Invisibly, a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
retains the exact `table`, `unavailable` rows, source `intervals`,
`design_grid`, `weights` and `notes`.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
remains idempotent on the returned object. No title or explanatory
footnote is drawn.

## Details

All methods concern the same score/composite, metric and source data. A
filled point has an interval; an open point is an available estimate
without an interval. Unavailable intervals are explicitly labeled in the
combined view, or marked by an asterisk in the panel view, even if their
point estimates are missing. An interval can exist without an admissible
ANOVA/MINQUE point estimate. Missing values remain missing; no
substitute interval or zero is drawn. The shared axis includes `[0,1]`
for coefficients and `[-1,1]` for G/Phi differences, expanding to retain
all finite estimates and accepted bounds. Delta normal-reference bounds
outside `[0,1]` remain visible; they flag limitations of that
approximation, not a larger population parameter space. SEM and
SEM-difference axes instead span the estimates and intervals in score
units, including zero. Negative SEM differences favor the comparison
plan. An SEM interval is uncertainty in measurement error, not an
interval for a Person's score. Chi-square and MLS labels retain the
calculation used for each plan; their assumptions and coverage claims
differ. Method limitations, confidence level, normal-effect assumptions
and negative components remain in the returned notes and source object.
Plotting neither refits a model nor recalculates an interval. Save the
complete interval or plot object with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) for later use. Nested
plan labels show child counts per parent, rather than total child pool
sizes; the reference plan uses the same count convention. A
mean-square-region difference is a conservative enclosure from shared
source uncertainty, not a tight joint image or a paired-delta interval.
Its returned source retains the individual projections and reference.
REML profile and residual-contrast rows retain the original source
points; the separate `IntervalCenter` and method diagnostics are
available in the source interval object. A point can lie outside this
separately calculated interval. For GENOVA-adjusted results, points use
the selected component treatment; intervals retain their original-source
population basis. `IntervalEstimate` and `IntervalBasis` in the source
table distinguish them. Drawing the two together does not make the
original sampling SE an adjusted-estimator SE. Unresolved numerical
candidates are retained in the source object but are not drawn as
accepted confidence bounds. For score and MLS intervals, an empty
confidence set is labeled `"Empty set"`; it is distinct from an
estimated coefficient of zero. MLS rows with `FormulaComplete = FALSE`
retain candidate values where a squared width is undefined. Their
conservative bounds are drawn, while the saved interval object and notes
retain the reason and affected ranges.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## See also

[`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/confint.mfrm_multivariate_d_study.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot.mfrm_dstudy_intervals", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
d <- mfrm_d_study(g, data.frame(Tasks = c(6, 12)))
ci <- confint(d, assumption = "normal")
p <- plot(ci, draw = FALSE)
plot_data(p, "notes")
if (requireNamespace("ggplot2", quietly = TRUE)) as_ggplot(p)
} # }
```
