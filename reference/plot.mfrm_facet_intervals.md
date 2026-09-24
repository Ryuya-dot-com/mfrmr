# Plot fixed-facet interval methods

Plot fixed-facet interval methods

## Usage

``` r
# S3 method for class 'mfrm_facet_intervals'
plot(x, comparison = TRUE, draw = TRUE, preset = "standard", ...)
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

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object retaining the `table`, contrast
coefficients, settings and labels. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics; automatic
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
conversion is unavailable.

## Details

Fixed targets use open diamonds without inferential intervals.
Unavailable selected intervals use crosses; an ordinary comparison
interval does not substitute for a missing sandwich interval. The zero
line is a reference, not a threshold of practical importance or a
rater-quality rule. No fit or covariance is recalculated. Target order
is preserved.
