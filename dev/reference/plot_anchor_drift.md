# Plot anchor drift or a screened linking chain

Creates ggplot2 figures for inspecting anchor drift across calibration
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

  If `FALSE`, return the `ggplot` object invisibly without printing.

- ...:

  Reserved for compatibility; use the named plot controls.

## Value

Invisibly, a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
to retrieve its reusable plotting data and notes. With `draw = FALSE`,
`plot_data(p, "table")` contains the filtered drift or chain table,
`plot_data(p, "matrix")` contains the heatmap matrix when requested, and
the returned plot data includes package-native `title`, `subtitle`,
`legend`, and `reference_lines`.

## Details

Four plot types are supported:

- **`"drift"`** (for `mfrm_anchor_drift` objects): A dot plot of each
  element's drift value. Vertical reference lines mark the drift
  threshold. The preset's warning colour indicates flagged elements.

- **`"heatmap"`** (for `mfrm_anchor_drift` objects): A wave-by-element
  heat matrix showing drift magnitude. Darker cells represent larger
  absolute drift. Useful for spotting systematic patterns (e.g., all
  criteria shifting in the same direction).

- **`"forest"`** (for `mfrm_anchor_drift` objects): Per-wave estimates
  with approximate normal whiskers from their available SEs. These are
  not intervals for between-wave differences; linking-offset uncertainty
  and cross-wave covariance are not included.

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
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_equating_chain.md)
  to inspect cumulative offsets across waves.

## Interpreting plots

**Drift** is the change in an element's estimated measure between
calibration waves, after accounting for the screened common-element link
offset. An element is flagged when its absolute drift exceeds a
threshold (typically 0.5 logits) **and** the drift-to-SE ratio exceeds a
secondary criterion (typically 2.0). These are heuristic screening
rules, not a calibrated test of change. Subtracting a common offset can
remove a panel-wide shift; unflagged elements do not establish absence
of annual drift.

- Drift dots distinguish flagged elements. Heatmap shading shows
  magnitude, not whether both screening thresholds were exceeded.
  Possible explanations require substantive review, including changes in
  scoring or exposure.

- In chain plots, uneven changes between waves indicate differential
  shifts in the screened linking offsets. The \\y\\-axis shows
  cumulative logit-scale offsets; flatter segments indicate more stable
  adjacent links. Steep segments should be checked alongside
  `LinkSupportAdequate` and the retained common-element counts before
  making longitudinal claims.

- For drift objects, it is usually best to read `summary(x)` first and
  then use the plot to see where the flagged values sit.

## Typical workflow

1.  Build a drift or screened-linking object with
    [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/detect_anchor_drift.md)
    or
    [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_equating_chain.md).

2.  Start with `draw = FALSE` if you want the plotting data for custom
    reporting.

3.  Use the plot for quick screening and then inspect the underlying
    tables for exact values.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-visual-diagnostics.md).

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/detect_anchor_drift.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_equating_chain.md),
[plot(x, type =
"heatmap")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_dif.md),
[plot(x, type =
"bubble")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
