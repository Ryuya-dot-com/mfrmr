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
  ...
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
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

- ...:

  Additional graphical parameters.

## Value

Invisibly, a list with `persons`, `facets`, `thresholds`, and the
underlying Wright-map tables used for the plot. Native output includes a
`retention` table and `retention_note` documenting compact-display
omissions. All renderers include fit-readiness and interpretation-status
metadata.

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
custom ggplot2/plotly rendering without parsing the base plot. Use
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
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Plot with `plot_wright_unified(fit)`.

3.  Compare person distribution with facet level locations.

4.  Use `show_thresholds = TRUE` when you want the category structure in
    the same view.

## When to use this instead of plot_information

Use `plot_wright_unified()` when your main question is targeting or
coverage on the shared logit scale. Use
[`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
when your main question is measurement precision across theta.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
fit <- fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 30)
map_data <- plot_wright_unified(fit, draw = FALSE)
names(map_data)
#>  [1] "persons"               "facets"                "thresholds"           
#>  [4] "facet_names"           "y_lim"                 "title"                
#>  [7] "wright_style"          "renderer"              "visual_contract"      
#> [10] "person"                "person_exclusions"     "person_hist"          
#> [13] "person_stats"          "locations"             "label_points"         
#> [16] "group_summary"         "group_levels"          "y_range"              
#> [19] "display_settings"      "label_limit"           "retention"            
#> [22] "retention_note"        "show_ci"               "uncertainty_display"  
#> [25] "legend"                "subtitle"              "fit_readiness"        
#> [28] "interpretation_status" "interpretation_note"  
facets_map <- plot_wright_unified(
  fit,
  renderer = "facets",
  category_labels = c(
    `1` = "Beginning", `2` = "Developing", `3` = "Secure", `4` = "Advanced"
  ),
  draw = FALSE
)
facets_map$facets_style$settings
#> # A tibble: 1 × 15
#>   Renderer WrightStyle  VisualCorrespondence  LowerLogit UpperLogit RowsPerLogit
#>   <chr>    <chr>        <chr>                      <dbl>      <dbl>        <int>
#> 1 facets   facets_style FACETS Table 6-style…         -2          2            2
#> # ℹ 9 more variables: ExtremePlacement <chr>, PersonsPerStar <dbl>,
#> #   StarsPerPerson <dbl>, PersonN <int>, AutoRangePolicy <chr>,
#> #   BoundaryLevelsAtEnds <int>, CIClippedCount <int>,
#> #   BoundaryCIEndpointCount <int>, CIDisplayPolicy <chr>
```
