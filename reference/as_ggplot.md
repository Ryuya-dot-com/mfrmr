# Convert draw-free mfrmr plot data to ggplot2

`as_ggplot()` is an optional renderer for an `mfrm_plot_data` object or
an object whose [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
method supports `draw = FALSE`. Base graphics remain the default; the
returned `ggplot` can be restyled or composed downstream.

## Usage

``` r
as_ggplot(x, type = NULL, component = NULL, ...)

# Default S3 method
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_design_evaluation'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_design_evaluation_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_signal_detection'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_signal_detection_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)
```

## Arguments

- x:

  An `mfrm_plot_data` object, or an mfrmr object with a draw-free plot
  method.

- type:

  Optional plot type passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for a
  non-plot-data input.

- component:

  Optional tabular payload component to convert.

- ...:

  Arguments passed to the draw-free plot method. CCC conversion
  additionally accepts `slope_aes`, `facet_by`, and `show_overlay`.

## Value

A `ggplot2` plot object.

## Details

Dedicated conversions are provided for Wright maps,
theta-to-expected-score pathways, fit-statistic-to-measure pathways,
category characteristic curves, bubble charts, and DIF/DFF summaries and
heatmaps. Other draw-free payloads use a conservative tabular fallback;
inspect
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
when automatic inference is not appropriate.

## Examples

``` r
# \donttest{
fit <- fit_mfrm(load_mfrmr_data("example_core"), "Person",
                c("Rater", "Criterion"), "Score", maxit = 30)
as_ggplot(fit, type = "wright")

as_ggplot(fit, type = "fit_pathway", include_person = TRUE)

as_ggplot(plot(fit, type = "ccc", draw = FALSE))

# }
```
