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
    paste0("Sandwich | ", x$settings$clusters, " independent clusters assumed") else if
(identical(x$settings$procedure, "cml_conditional_information"))
    "Conditional information" else if (identical(x$settings$uncertainty,
    "independent_anchor_delta")) "Information + anchor source" else
    "Observed information"),
  caption = if (any(!is.finite(x$table$Estimate)))
    paste0("Not estimated: no point or interval | ",
    "Crosses: estimated points with unavailable intervals") else if (any(x$table$Status
    != "available"))
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
  interval. With source-propagated anchors, show the separate
  conditional-on-anchors interval. Both use the same point estimate.

- draw:

  Logical; `FALSE` returns exact plotted data without opening a device.

- preset:

  A package plot preset, for example `"standard"` or `"monochrome"`.

- title, subtitle, caption:

  Optional returned text; `NULL` omits it. Defaults describe the facet,
  exact confidence level, method and fixed/unavailable symbols. This
  text is not drawn; use `plot_data(p, "notes")` and
  `plot_data(p, "title")` to retrieve it.

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

Fixed targets use open diamonds without inferential intervals. A
conditionally fixed anchor can have a source-propagated interval; the
comparison displays its conditional fixed value separately. Method
labels distinguish source propagation from conditional observed
information. Unavailable intervals in either displayed method use
crosses; an ordinary comparison interval does not substitute for a
missing sandwich interval. The zero line is a reference, not a threshold
of practical importance or a rater-quality rule. No fit or covariance is
recalculated. Target order is preserved. Weak-information cautions
remain in the returned data and appear in the default subtitle. Custom
or omitted subtitles change display only. For experimental two-family
GPCM locations, the axis uses fixed-N(0,1) ability units and the default
subtitle states the location reference and unqualified coverage, with a
deficient Person-score rank caution when applicable. These are not
uniform expected-rating differences. Standardized contrast axes use
population SD units; returned notes identify whether SD uncertainty is
estimated or the known SD is one. Reviewed interaction contrasts retain
group direction, panel weights and scale in their source result;
returned labels distinguish them from facet locations. Native CML
intervals are labeled conditional information. Their returned notes
describe asymptotic validity without implying weak information or an
estimated ability population SD. When a comparison has no estimate, its
row is labeled "not estimated" and has no point or interval. An empty
display range is only an axis placeholder; it does not assign a value to
unavailable targets. Joint interaction-cell results retain cell
identities, counts and sparse flags in
`plot_data(p, "interaction_cells")`. Their axis uses additive predictor
shifts; row labels show the two level names in fitted facet order. Units
follow the fixed N(0,1) ability scale. Positive effects raise expected
coded scores relative to the jointly fitted main effects. These
pointwise intervals are not fixed-baseline bias screens or fairness
labels.

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
