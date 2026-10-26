# Plot saved latent-population coefficients or contrasts

Read point estimates and their experimental pointwise intervals from an
existing population analysis, without fitting or recalculating
uncertainty.

## Usage

``` r
# S3 method for class 'mfrm_population_intervals'
plot(
  x,
  type = c("coefficients", "contrasts"),
  draw = TRUE,
  preset = "standard",
  reference = 0,
  ...
)
```

## Arguments

- x:

  A saved result from
  [`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md).

- type:

  Show `"coefficients"` (default, including the intercept) or the
  prespecified `"contrasts"` stored in `x`. Residual variance has
  different units and remains in `summary(x)` rather than sharing this
  axis.

- draw:

  Logical; `FALSE` returns the plot data without drawing.

- preset:

  A package plot preset, including `"publication"` and `"monochrome"`.
  The session default is used when omitted.

- reference:

  Optional finite vertical reference, default zero; `NULL` omits it.
  This is not a practical-importance or automatic decision threshold.

- ...:

  Unused; unsupported arguments are rejected.

## Value

Invisibly, an `mfrm_plot_data` object. `table` preserves selected source
rows and adds `PlotStatus`, `Label` and `Y`; `intervals` retains the
complete original table. `population_spec` preserves the formula,
trained terms, factor levels and coding; `population_coding` is a
readable coding table. `contrast_weights`, source identity, settings,
numerical checks and interpretation notes accompany the figure. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to inspect these and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
for an editable figure with the same saved values.

## Details

Rows retain their saved order. Filled circles and lines show numerically
available intervals. Crosses with a `CI unavailable` label retain finite
points without eligible finite bounds. A missing point keeps its labeled
row without a marker; it is never plotted at zero. Titles and
explanatory notes are returned, not drawn. No significance colors or
automatic classifications are added. Plotting does not requalify a saved
numerical result.

Coefficients describe the conditional population mean on the fitted
native ability scale. A continuous coefficient is per unit of its fitted
predictor; the intercept depends on predictor zero values and factor
coding. Read interactions, transformations and categorical comparisons
using the saved coding, not an assumed reference group. Coefficients on
different predictor scales are not directly comparable measures of
importance. Higher ability predicts higher coded ratings in these
RSM/PCM models; whether that is better performance depends on the
rubric. Coefficients are not standardized effects.

Contrasts use the stored linear weights and may describe a conditional
mean or a difference between means. They are not individual ability
differences, causal effects, simultaneous intervals or prediction
intervals. Numerical availability does not establish nominal coverage:
the source's experimental status, failed checks and qualifications
remain in `notes` and the tables. A wide interval remains visible.
Missing bounds are not infinite endpoints. When source-anchor
uncertainty was requested, the saved intervals include that
contribution. The returned subtitle, settings and `anchor_uncertainty`
distinguish it from intervals conditional on exact supplied anchors;
conditional bounds remain in the returned table.

For an executable bundled-data example, run the example on
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md),
which creates `ci` and both views. Then use
`p <- plot(ci, type = "contrasts", draw = FALSE)`,
`plot_data(p, "contrast_weights")` and `plot_data(p, "notes")` to read
it. `as_ggplot(ci, type = "contrasts")` converts the same saved result.

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

[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md),
[`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md),
[`plot.mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_facet_intervals.md)
