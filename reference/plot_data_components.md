# List reusable components in mfrmr plot data

`plot_data_components()` is a companion to
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
It returns a compact table that tells users which plot-data components
are available, what shape they have, and which ones are most useful for
custom graphics, dashboards, or report assembly.

## Usage

``` r
plot_data_components(x, type = NULL, ...)
```

## Arguments

- x:

  An `mfrm_plot_data` object, or a fitted/report/review object with a
  `plot(..., draw = FALSE)` method.

- type:

  Optional plot type passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) when `x` is
  not already an `mfrm_plot_data` object.

- ...:

  Additional arguments passed to `plot(..., draw = FALSE)` when `x` is
  not already an `mfrm_plot_data` object.

## Value

A data frame with one row per reusable plot-data component.

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", maxit = 30)
plot_data_components(fit, type = "pathway")

curves <- category_curves_report(fit, theta_points = 51)
plot_data_components(curves, type = "category_probability")

toy$ResponseTime <- 10 + seq_len(nrow(toy)) %% 6 + as.numeric(toy$Score)
rt <- response_time_review(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  time = "ResponseTime"
)
plot_data_components(plot_response_time_review(rt, draw = FALSE))
} # }
```
