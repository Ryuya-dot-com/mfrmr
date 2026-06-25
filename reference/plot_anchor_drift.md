# Plot anchor drift or a screened linking chain

Creates base-R plots for inspecting anchor drift across calibration
waves or visualising the cumulative offset in a screened linking chain.

## Usage

``` r
plot_anchor_drift(
  x,
  type = c("drift", "chain", "heatmap", "forest"),
  facet = NULL,
  ci_level = 0.95,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  An `mfrm_anchor_drift` or `mfrm_equating_chain` object.

- type:

  Plot type: `"drift"` (dot plot of element drift), `"chain"`
  (cumulative offset line plot), `"heatmap"` (wave-by-element drift
  heatmap), or `"forest"` (per-(Facet, Level, Wave) anchor estimate with
  `+/- z * SE` whiskers; requires `mfrm_anchor_drift`).

- facet:

  Optional character vector to filter drift plots to specific facets.

- ci_level:

  Confidence level used by `type = "forest"` for the anchor-estimate
  whiskers (default `0.95`). Ignored for other plot types.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `FALSE`, return the plot data invisibly without drawing.

- ...:

  Additional graphical parameters passed to base plotting functions.

## Value

A plotting-data object of class `mfrm_plot_data`. With `draw = FALSE`,
`result$data$table` contains the filtered drift or chain table,
`result$data$matrix` contains the heatmap matrix when requested, and the
returned plot data includes package-native `title`, `subtitle`,
`legend`, and `reference_lines`.

## Details

Three plot types are supported:

- **`"drift"`** (for `mfrm_anchor_drift` objects): A dot plot of each
  element's drift value, grouped by facet. Horizontal reference lines
  mark the drift threshold. Red points indicate flagged elements.

- **`"heatmap"`** (for `mfrm_anchor_drift` objects): A wave-by-element
  heat matrix showing drift magnitude. Darker cells represent larger
  absolute drift. Useful for spotting systematic patterns (e.g., all
  criteria shifting in the same direction).

- **`"chain"`** (for `mfrm_equating_chain` objects): A line plot of
  cumulative offsets across the screened linking chain. A flatter line
  indicates smaller between-wave shifts; steep segments suggest larger
  link offsets that deserve review.

## Which plot should I use?

- Use `type = "drift"` with an `mfrm_anchor_drift` object to review
  flagged elements directly.

- Use `type = "heatmap"` with an `mfrm_anchor_drift` object to spot
  wave-by-element patterns.

- Use `type = "chain"` with an `mfrm_equating_chain` object after
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  to inspect cumulative offsets across waves.

## Interpreting plots

**Drift** is the change in an element's estimated measure between
calibration waves, after accounting for the screened common-element link
offset. An element is flagged when its absolute drift exceeds a
threshold (typically 0.5 logits) **and** the drift-to-SE ratio exceeds a
secondary criterion (typically 2.0), ensuring that only practically
noticeable and relatively precise shifts are flagged.

- In drift and heatmap plots, red or dark-shaded elements exceed both
  thresholds. Common causes include rater drift over time, item exposure
  effects, or curriculum changes.

- In chain plots, uneven spacing between waves suggests differential
  shifts in the screened linking offsets. The \\y\\-axis shows
  cumulative logit-scale offsets; flatter segments indicate more stable
  adjacent links. Steep segments should be checked alongside
  `LinkSupportAdequate` and the retained common-element counts before
  making longitudinal claims.

- For drift objects, it is usually best to read `summary(x)` first and
  then use the plot to see where the flagged values sit.

## Typical workflow

1.  Build a drift or screened-linking object with
    [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
    or
    [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md).

2.  Start with `draw = FALSE` if you want the plotting data for custom
    reporting.

3.  Use the base-R plot for quick screening and then inspect the
    underlying tables for exact values.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md),
[`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
[`plot_bubble()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bubble.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
people <- unique(toy$Person)
d1 <- toy[toy$Person %in% people[1:12], , drop = FALSE]
d2 <- toy[toy$Person %in% people[13:24], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
drift <- detect_anchor_drift(list(W1 = fit1, W2 = fit2))
drift_plot <- plot_anchor_drift(drift, type = "drift", draw = FALSE)
class(drift_plot)
names(drift_plot$data)
chain <- build_equating_chain(list(F1 = fit1, F2 = fit2))
chain_plot <- plot_anchor_drift(chain, type = "chain", draw = FALSE)
head(chain_plot$data$table)
if (interactive()) {
  plot_anchor_drift(drift, type = "heatmap", preset = "publication")
}
} # }
```
