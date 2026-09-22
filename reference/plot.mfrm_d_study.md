# Plot design comparisons from a main-effects D-study

Compare planned facet counts using an existing
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
result. G concerns relative ordering; Phi also includes shifts in
absolute score levels. Larger coefficients mean greater dependability
under the selected model and residual assumption, not proven pass/fail
accuracy.

## Usage

``` r
# S3 method for class 'mfrm_d_study'
plot(
  x,
  y = NULL,
  type = c("coefficients", "error_variance", "heatmap", "contour", "surface3d"),
  x_var = NULL,
  y_var = NULL,
  group_var = NULL,
  panel_by = NULL,
  panel_grid = NULL,
  metric = NULL,
  draw = TRUE,
  main = NULL,
  palette = NULL,
  preset = c("standard", "publication", "compact", "monochrome"),
  ...
)
```

## Arguments

- x:

  An
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  result.

- y:

  Reserved for method compatibility.

- type:

  `"coefficients"` for G/Phi curves, `"error_variance"` for error
  variance curves, or `"heatmap"`, `"contour"`, or `"surface3d"` for one
  metric over two facet counts. Error variance is in squared score
  units, not SEM. Lower error variance is better.

- x_var, y_var:

  Planned-count columns such as `"n_Rater"`. The default horizontal axis
  is the first count column; surface plots use the next column on the
  other axis. The two axes must differ.

- group_var:

  Optional additional column distinguishing curves. All non-horizontal
  facet counts and residual assumptions remain separate within each
  panel, including when `group_var` is supplied.

- panel_by:

  One column defining panels, or `NULL`.

- panel_grid:

  One or two columns defining panels. Use this or `panel_by`, not both.
  Surface plots require every other facet count and residual assumption
  to be constant within each panel. Subset the result or add panels when
  they vary; they cannot be silently averaged or overlaid.

- metric:

  Optional selection from `"G"`, `"Phi"`, `"RelativeErrorVariance"`, or
  `"AbsoluteErrorVariance"`, compatible with `type`. Surface plots
  require one metric and default to `"Phi"`.

- draw:

  Draw when `TRUE`; `FALSE` only returns plot data.

- main:

  Optional plot title.

- palette:

  Optional colors.

- preset:

  Plot style: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`.

- ...:

  Reserved for method compatibility.

## Value

Invisibly, an `mfrm_plot_data` object with the scenario `table`, metric
`series`, axis/group/panel settings, and labels. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics. Automatic
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
conversion is not provided for this class; the base plots preserve the
chosen comparisons.

## Details

Points represent requested scenarios; connecting lines and contours are
visual guides. Missing estimates remain missing and break curves. If
none are available, inspect the D-study table and source variance
components. Coefficient curves show 0.70 and 0.80 reference lines; these
are not universal acceptance criteria. Heatmaps include a numeric color
key; exact values remain in the table.

The main-effects G-study combines unmodeled interactions in its
residual. Different residual-scaling curves describe assumptions, not
confidence bounds. All projections hold estimated components fixed.
Check source fit warnings before interpreting even large coefficients.
For supported designs with separately estimated interactions, including
a single score, use
[`mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md)
and
[`mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_study.md).

## See also

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`plot.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_d_study.md)

## Examples

``` r
# After creating ds with mfrm_d_study():
# plot(ds, x_var = "n_Rater", panel_grid = c("Metric", "ResidualScaling"))
# For Rater x Task x Occasion scenarios, separate occasions explicitly:
# plot(ds, type = "heatmap", x_var = "n_Rater", y_var = "n_Task",
#      metric = "Phi", panel_by = "n_Occasion")
# With residual_scaling = "sensitivity", use
# panel_grid = c("n_Occasion", "ResidualScaling") instead.
```
