# Plot response-time review summaries

Draw or return reusable plot data for a
[`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
object. Plot types are descriptive screening views and do not represent
a joint response-time model.

## Usage

``` r
plot_response_time_review(
  x,
  type = c("distribution", "person", "facet", "score"),
  facet = NULL,
  top_n = 25L,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  A `mfrm_response_time_review` object.

- type:

  Plot type: `"distribution"`, `"person"`, `"facet"`, or `"score"`.

- facet:

  Optional facet name when `type = "facet"`.

- top_n:

  Maximum number of person or facet rows to plot.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics. If `FALSE`, return only an
  `mfrm_plot_data` object.

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object containing the plot table,
thresholds, overview, and interpretation notes.

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

[`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
toy$ResponseTime <- 10 + seq_len(nrow(toy)) %% 6 + as.numeric(toy$Score)
rt <- response_time_review(
  toy, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", time = "ResponseTime"
)
plot_response_time_review(rt, type = "distribution", draw = FALSE)
plot_response_time_review(rt, type = "person", draw = FALSE)
```
