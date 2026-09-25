# Plot pooled facet estimates or prespecified contrasts

Plot pooled facet estimates or prespecified contrasts

## Usage

``` r
# S3 method for class 'mfrm_pooled'
plot(
  x,
  draw = TRUE,
  preset = "standard",
  title = paste("Pooled", x$settings$facet, "estimates and contrasts"),
  subtitle = sprintf("%d imputations | %.0f%% pointwise MI intervals",
    x$settings$imputations, 100 * x$settings$ci_level),
  ...
)
```

## Arguments

- x:

  Output from
  [`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md).

- draw:

  Logical. With `FALSE`, return the exact plot data without opening a
  graphics device.

- preset:

  A package plotting preset, such as `"standard"` or `"monochrome"`.

- title, subtitle:

  Optional text; `NULL` omits it. The default subtitle retains a notice
  when complete-data information is weak. Full cautions remain in the
  returned plot data even with custom or omitted text.

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object containing the plotted `table`,
exact contrast coefficients and inference settings. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics; automatic
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
conversion is unavailable.

## Details

Plots use the stored pointwise multiple-imputation intervals and
preserve target order. Open diamonds identify fixed targets without an
inferential interval. A zero reference line does not define a practical
importance threshold. The plot does not refit, select significant
raters, adjust for multiplicity or turn severity differences into rater
quality.

## See also

[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md)
