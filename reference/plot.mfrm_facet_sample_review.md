# Plot a facet sample-size review

Per-level observation counts rendered as a horizontal bar chart coloured
by the Linacre sample-size band assigned in
[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md).
Vertical dashed lines mark the sparse / marginal / standard thresholds
so reviewers see where every facet level sits relative to the Linacre
(1994) guidance.

## Usage

``` r
# S3 method for class 'mfrm_facet_sample_review'
plot(
  x,
  top_n = NULL,
  preset = c("standard", "publication", "compact", "monochrome"),
  ...
)
```

## Arguments

- x:

  An `mfrm_facet_sample_review` object.

- top_n:

  Optional integer; trim the y-axis to the `top_n` smallest level counts
  per facet. `NULL` (default) keeps all.

- preset:

  One of `"standard"`, `"publication"`, `"compact"`, `"monochrome"`.

- ...:

  Reserved.

## Value

Invisibly, the data.frame used for the plot.

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

[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md).
