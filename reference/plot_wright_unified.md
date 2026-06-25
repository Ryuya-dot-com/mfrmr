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
  show_ci = FALSE,
  ci_level = 0.95,
  draw = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  palette = NULL,
  label_angle = 45,
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

- bins:

  Integer number of bins for the person histogram. Default `20`.

- show_thresholds:

  Logical; if `TRUE`, display threshold/step positions on the map.
  Default `TRUE`.

- top_n:

  Maximum number of facet/step points retained for labeling.

- show_ci:

  Logical; if `TRUE`, draw approximate confidence intervals when
  standard errors are available.

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

- ...:

  Additional graphical parameters.

## Value

Invisibly, a list with `persons`, `facets`, and `thresholds` data used
for the plot.

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
#>  [1] "persons"       "facets"        "thresholds"    "facet_names"  
#>  [5] "y_lim"         "title"         "person"        "person_hist"  
#>  [9] "person_stats"  "locations"     "label_points"  "group_summary"
#> [13] "group_levels"  "y_range"      
```
