# Display saved GPCM intervals and bootstrap results

Plot the selected inference result without fitting or recomputing
covariance. These plots describe discrimination or specified contrasts,
not rater severity, agreement, quality or recommended scoring weights.

## Usage

``` r
# S3 method for class 'mfrm_slope_intervals'
plot(
  x,
  title = "GPCM slope uncertainty",
  subtitle = paste(attr(x, "target"), attr(x, "method"), paste0(100 * attr(x, "level"),
    "%"), if (attr(x, "simultaneous") == "none") "pointwise" else "Bonferroni", sep =
    " | "),
  reference = NULL,
  draw = TRUE,
  ...
)

# S3 method for class 'mfrm_gpcm_bootstrap'
plot(
  x,
  title = "GPCM bootstrap inference",
  subtitle = "Fitted-model parametric bootstrap; unresolved refits retained",
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Saved
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  or
  [`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
  output.

- title, subtitle:

  Optional plot text; NULL removes it. The interval subtitle defaults to
  the saved target, method, confidence level and any saved numerical or
  bootstrap cautions. Custom text overrides this default, while the
  diagnostics remain in the plot data and interval tables.

- reference:

  Optional finite numeric vertical reference. Default NULL; no quality
  threshold or scoring-policy cutoff is selected.

- draw:

  TRUE draws the ggplot; FALSE returns it only.

- ...:

  For bootstrap slope results, passed to
  [`confint()`](https://rdrr.io/r/stats/confint.html) to select its
  target and level. Otherwise unused.

## Value

Invisibly a ggplot, retaining an `mfrm_plot_data` attribute for
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
No fitting or resampling is performed.

## Details

Crosses retain unavailable intervals. Open circles retain intervals with
infinite endpoints; the plot does not replace them with finite bounds.
The accompanying table contains all bounds and failure reasons. For a
bootstrap LRT, a histogram shows resolved null statistics and a line the
observed statistic. The annotation counts every unresolved replicate.

Use
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
for target-aware tables,
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for plotted values, and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
for customization. Attach one result or a named list with
`mfrm_results(fit, intervals = list(slopes = ci, curves = curves), compute = "never")`.
Named plot routes become `gpcm_slopes`, `gpcm_curves`, etc. Exact source
matching is required; default fit diagnostics are preserved.
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
saves these tables and plots; replay reloads the saved RDS, preserving
the selected methods without rerunning estimation. Markdown report
summaries include the finite, unbounded and unavailable interval counts
and the saved inference cautions/reasons.

For positive slope or ratio intervals spanning many orders of magnitude,
use `as_ggplot(ci) + ggplot2::scale_x_log10()`. Finite bounds and
estimates must be strictly positive. Keep a linear axis for signed
differences. Changing the axis does not narrow the interval or make it
more reliable.

## Examples

``` r
# ci <- confint(fit, scale = "standardized", method = "sandwich")
# plot(ci, title = NULL)
# apa_table(ci)
# plot_data(ci, "table")
```
