# Plot differences between prespecified D-study plans

Show each plan's change from a reference, with approximate pointwise
intervals. The vertical zero line represents no change; an interval
crossing it does not establish equivalence. Positive G/Phi differences
or negative SEM differences favor the comparison plan. The method
requires normal random effects.

## Usage

``` r
# S3 method for class 'mfrm_multivariate_d_comparison'
plot(x, type = c("coefficients", "sem"), draw = TRUE, preset = "standard", ...)
```

## Arguments

- x:

  A result from
  [`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md).

- type:

  `"coefficients"` for G/Phi or `"sem"` for SEM differences.

- draw:

  Draw the figure; `FALSE` returns its data only.

- preset:

  Plot style: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`.

- ...:

  Reserved; additional arguments are rejected.

## Value

Invisibly, an `mfrm_plot_data` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts the exact plotted `table`, `unavailable` rows, `design_grid`,
`reference`, `weights`, title and labels. Base graphics are supported;
automatic ggplot conversion is not provided for this plot.

## Details

Plans and score weights must have been specified before inspecting the
results. Intervals are not simultaneous over plans or metrics. A point
without an interval is retained and marked as unavailable; missing
values are never replaced by zero. Each panel has its own horizontal
scale. Original score units apply to SEM differences. The figure
identifies the score/composite, its weights and the reference counts.

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

[`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md)
