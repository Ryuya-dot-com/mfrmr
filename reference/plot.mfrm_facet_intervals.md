# Plot fixed-facet interval methods

Plot fixed-facet interval methods

## Usage

``` r
# S3 method for class 'mfrm_facet_intervals'
plot(
  x,
  comparison = TRUE,
  draw = TRUE,
  preset = "standard",
  title = paste(x$settings$facet, "estimates and contrasts"),
  subtitle = paste0(format(100 * x$settings$level, trim = TRUE),
    "% pointwise normal intervals | ", if (x$settings$method == "sandwich")
    paste0("Sandwich | ", x$settings$clusters, " independent clusters assumed") else
    "Observed information"),
  caption = if (any(x$table$Status != "available"))
    "Open diamonds: fixed targets | Crosses: unavailable selected intervals" else NULL,
  reference = 0,
  show_legend = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).

- comparison:

  Logical. With a sandwich result, also show its ordinary model-based
  interval. Both intervals use the same point estimate.

- draw:

  Logical; `FALSE` returns exact plotted data without opening a device.

- preset:

  A package plot preset, for example `"standard"` or `"monochrome"`.

- title, subtitle, caption:

  Optional text; `NULL` omits it. Defaults show the facet, exact
  confidence level, method and fixed/unavailable symbols.

- reference:

  Optional finite vertical reference; default zero. Use `NULL` to omit
  it. This is not a rater-quality threshold.

- show_legend:

  Logical; show the method legend (default `TRUE`).

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object retaining the `table`, contrast
coefficients, settings and labels. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics;
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
returns a customizable ggplot with the same saved values.

## Details

Fixed targets use open diamonds without inferential intervals.
Unavailable selected intervals use crosses; an ordinary comparison
interval does not substitute for a missing sandwich interval. The zero
line is a reference, not a threshold of practical importance or a
rater-quality rule. No fit or covariance is recalculated. Target order
is preserved. Weak-information cautions remain in the returned data and
appear in the default subtitle. Custom or omitted subtitles change
display only.
