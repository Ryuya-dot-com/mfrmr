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
for custom graphics.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
uses the saved pointwise MI interval endpoints; it does not substitute
normal intervals from the standard errors. Default and
`component = "table"` retain the complete interval view. Target order,
contrasts, degrees of freedom, confidence level and complete-data
information cautions remain attached through
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
Fixed targets have open diamonds without intervals. In ggplot
conversion, infinite endpoints have arrows (their tips are display
limits, not finite bounds); missing intervals have crosses at the saved
estimate. Missing point estimates cause an error rather than being
placed at zero. Use source `title`/`subtitle` arguments or
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
to change text; hiding headings does not remove the attached inference
cautions.

## Details

Plots use the stored pointwise multiple-imputation intervals and
preserve target order. Open diamonds identify fixed targets without an
inferential interval. A zero reference line does not define a practical
importance threshold. The plot does not refit, select significant
raters, adjust for multiplicity or turn severity differences into rater
quality.

## Session plot defaults

Set `options(mfrmr.plot_preset = "publication")` to choose a session
default for plotting functions that expose the common `preset` argument.
The supported values are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. Precedence is an explicit call argument, then the
session option, then `"standard"`. For example, `preset = "standard"`
overrides a session set to `"monochrome"`. Explicit `preset = NULL`
retains the earlier package-default behavior; it does not read the
session option. Invalid session values cause an error only when that
option is needed.

The category-curve, data-quality, fit-review, connectivity and network
routes of [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
report bundles use the same option through `...`. Plots without a common
`preset` argument, including extended-model plots with their own
`palette` controls, keep their own settings. This option selects a
preset, not a universal theme or a guarantee that all renderers
implement every appearance control identically.

New plot payloads retain the resolved preset for supported saved-data
rendering. Converting an existing payload with
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
uses its saved appearance, even after the session option changes. A call
that creates a new plot from a fit or statistical result uses the
current default. For a reproducible script, supply `preset` explicitly
or set the option in that script. Saving only the fitted model does not
save a session option. No global ggplot theme is changed.

Restore previous settings with
`old <- options(mfrmr.plot_preset = "monochrome")` followed by
`options(old)`. Use `options(mfrmr.plot_preset = NULL)` to remove the
option. The preset changes appearance, not estimates, confidence levels
or diagnostic thresholds.

## See also

[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md)
