# Extract reusable data from an mfrmr plot object

`plot_data()` is a small accessor for users who want to build custom
base-R, ggplot2, plotly, or table-based displays from mfrmr plot
helpers. It accepts an existing `mfrm_plot_data` object, or any mfrmr
object whose [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
method supports `draw = FALSE`. Use
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
first when you want to inspect which components are available before
extracting one.

## Usage

``` r
plot_data(x, component = NULL, type = NULL, ...)
```

## Arguments

- x:

  An `mfrm_plot_data` object, or a fitted/report/review object with a
  `plot(..., draw = FALSE)` method.

- component:

  Optional single component name inside the reusable plot data. When
  `NULL`, the full plot-data list is returned.

- type:

  Optional plot type passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) when `x` is
  not already an `mfrm_plot_data` object.

- ...:

  Additional arguments passed to `plot(..., draw = FALSE)` when `x` is
  not already an `mfrm_plot_data` object.

## Value

The full reusable plot-data list, or the selected component.

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", maxit = 30)

wright_plot_data <- plot_data(fit, type = "wright")
names(wright_plot_data)

wright_table <- plot_data(fit, type = "wright", component = "locations")
head(wright_table)

curves <- category_curves_report(fit, theta_points = 51)
curve_long <- plot_data(curves, component = "plot_long")
head(curve_long[, c("PlotType", "Theta", "Series", "Value")])

pathway_long <- plot_data(fit, type = "pathway", component = "pathway_long")
head(pathway_long[, c("Layer", "CurveGroup", "Theta", "Value")])
pathway_fit <- plot_data(fit, type = "pathway", component = "fit_measures")
head(pathway_fit[, c("Facet", "Level", "Infit", "Outfit", "FitStatus")])

# Re-render one component with your own styling while keeping the
# package-generated data and interpretation metadata.
expected <- pathway_long[pathway_long$Layer == "expected_score", , drop = FALSE]
plot(expected$Theta, expected$Value, type = "l",
     xlab = "Theta", ylab = "Expected score",
     main = "Custom expected-score pathway")
abline(v = 0, lty = 2, col = "grey60")

info <- compute_information(fit, theta_points = 51)
sem_long <- plot_data(
  plot_information(info, type = "sem", draw = FALSE),
  component = "plot_long"
)
head(sem_long[, c("Metric", "Theta", "Value", "DisplayedByDefault")])
} # }
```
