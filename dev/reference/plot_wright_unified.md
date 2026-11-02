# Plot a unified Wright map with all facets on a shared logit scale

Produces a shared-logit variable map showing person ability distribution
alongside measure estimates for every facet in side-by-side columns on
the same scale.

## Usage

``` r
plot_wright_unified(
  fit,
  diagnostics = NULL,
  bins = 20L,
  show_thresholds = TRUE,
  top_n = 30L,
  show_ci = NULL,
  ci_level = 0.95,
  draw = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  palette = NULL,
  label_angle = 45,
  renderer = NULL,
  wright_style = c("native", "facets_style"),
  category_labels = NULL,
  rows_per_logit = 2L,
  wright_range = NULL,
  extreme_placement = c("ends", "estimate"),
  persons_per_star = NULL,
  highlight = NULL,
  ...
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).
  When supplied, the map uses matching standard errors and precision
  metadata while keeping coordinates from `fit`.

- bins:

  Integer number of bins for the person histogram. Default `20`.

- show_thresholds:

  Logical; if `TRUE`, display threshold/step positions on the map.
  Default `TRUE`.

- top_n:

  Maximum number of facet/step locations retained by the native renderer
  for a compact display. Step transitions are always retained and
  omitted facet locations are reported in `retention`; use `Inf` for the
  complete final map. Every retained native location is labelled using
  collision-aware displaced text and leader lines; step transitions are
  shown as one vertical ladder with fitted logits in their labels. The
  FACETS-style payload retains and labels every fitted location,
  grouping coincident labels when needed.

- show_ci:

  Logical or `NULL`. `NULL` (the default) draws available uncertainty
  intervals for the native renderer and omits them from the FACETS-style
  renderer. Explicit `TRUE` with `renderer = "facets"` creates a hybrid
  FACETS-style ruler with mfrmr uncertainty intervals.

- ci_level:

  Confidence level used when `show_ci = TRUE`.

- draw:

  If `TRUE` (default), draw the plot. If `FALSE`, return plot data
  invisibly.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- palette:

  Optional named color overrides passed to the shared Wright-map drawer.

- label_angle:

  Rotation angle for group labels on the facet panel.

- renderer:

  Canonical Wright-map renderer selector: `"native"` (default) or
  `"facets"` for the FACETS Table 6-style visual layout.

- wright_style:

  Wright-map renderer: `"native"` preserves the histogram, point, range,
  and facet-SE display; `"facets_style"` adds a FACETS Table 6-style
  text ruler. The latter is a visual layout, not a claim of numerical
  equivalence with FACETS, and is equivalent to `renderer = "facets"`.

- category_labels:

  Optional score-rubric labels for `wright_style = "facets_style"`.
  Supply a named character vector keyed by every retained original
  score, an unnamed vector with one label per retained category, or a
  data frame with `Score` and `Label` columns.

- rows_per_logit:

  Number of rows per logit on the FACETS-style ruler.

- wright_range:

  Optional finite increasing length-2 logit range.

- extreme_placement:

  Place extreme-score persons at ruler `"ends"` or at their fitted
  `"estimate"` in the FACETS-style renderer.

- persons_per_star:

  Number of persons represented by one `*`; `NULL` selects a compact
  value automatically.

- highlight:

  Optional named list of non-person facet level IDs, for example
  `list(Rater = c("R01", "R02"))`, for Wright maps only (including
  `view = "unified"` and the Wright component of a bundle). Selected
  labels receive a `> ` prefix in both renderers and saved ggplot
  conversion. Levels outside the usual `top_n` selection are added, so
  the displayed count may exceed that limit. Fitted locations and
  uncertainty do not change; the automatic scale uses all fitted
  locations before compaction. Selection is not a statistical flag.
  Inspect `locations$Highlighted`, `retention` and `notes` in the
  returned plot data. Unknown IDs or levels without finite locations are
  rejected. `NULL` selects no levels.

- ...:

  Additional graphical parameters.

## Value

Invisibly, a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
returns `persons`, `facets`, `thresholds`, and the underlying Wright-map
tables used for the plot. Native output includes a `retention` table and
`retention_note` documenting compact-display omissions. All renderers
include fit-readiness and interpretation-status metadata.

## Details

This unified map arranges:

- Column 1: Person measure distribution (horizontal histogram)

- Shared facet/step panel: facet levels and optional threshold positions
  on the same vertical logit axis

- Range and interquartile overlays for each facet group to show spread

This is the package's most compact targeting view when you want one
display that shows where persons, facet levels, and category thresholds
sit relative to the same latent scale.

The logit scale on the y-axis is shared, allowing direct visual
comparison of all facets and persons.

If the fit records boundary-separated facet levels and `wright_range` is
`NULL`, both renderers derive the display range from supported locations
and place separated levels at ruler ends. The returned tables retain
exact `OriginalEstimate` and `CI_Lower` / `CI_Upper` values alongside
display and clipping metadata; endpoint triangles and footers disclose
the adjustment.

With `renderer = "facets"` (or `wright_style = "facets_style"`), the
draw-free result additionally contains tidy ruler rows, person star
frequencies, signed facet headers, all facet levels, step lines,
original-score transitions, mean half-score boundaries, category labels,
and display settings under `facets_style`. The payload keeps both the
nearest line-printer `RulerValue` and the exact step/midpoint
`DrawValue`; the current renderer draws threshold lines at the exact
value and prints fitted logits in step labels. These tables support
custom ggplot2/plotly rendering without parsing the figure. Use
`show_ci = FALSE` for the closest FACETS-style presentation. A
FACETS-style ruler drawn with `show_ci = TRUE` is intentionally labelled
as a hybrid because its uncertainty intervals are supplied by `mfrmr`.

The returned list separates plotting availability from interpretation.
It includes `fit_readiness`, `interpretation_status`, and
`interpretation_note`. If numerical, data, connectivity, or stability
review is unresolved, the map is returned for diagnosis but the call
warns and prefixes the returned subtitle and drawn title with
`REVIEW ONLY`.

## Interpreting output

- Facet levels at the same height on the map are at similar difficulty.

- The person histogram shows where examinees cluster relative to the
  facet scale.

- Thresholds (if shown) indicate category boundary positions.

- Large gaps between the person distribution and facet locations can
  signal targeting problems.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

2.  Plot with `plot(fit, type = "wright", view = "unified")`.

3.  Compare person distribution with facet level locations.

4.  Use `show_thresholds = TRUE` when you want the category structure in
    the same view.

## When to use this instead of plot_information

Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html) when your
main question is targeting or coverage on the shared logit scale. Use
[plot(x)](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compute_information.md)
when your main question is measurement precision across theta.

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

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_wright_unified", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
fit <- fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 30)
map_plot <- plot(fit, type = "wright", view = "unified", draw = FALSE)
names(plot_data(map_plot))
facets_map <- plot(fit, type = "wright", view = "unified", renderer = "facets", category_labels = c(
    `1` = "Beginning", `2` = "Developing", `3` = "Secure", `4` = "Advanced"
  ), draw = FALSE)
plot_data(facets_map)$facets_style$settings
} # }
```
