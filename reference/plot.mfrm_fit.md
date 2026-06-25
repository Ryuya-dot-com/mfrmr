# Plot fitted MFRM results with base R

Plot fitted MFRM results with base R

## Usage

``` r
# S3 method for class 'mfrm_fit'
plot(
  x,
  type = NULL,
  facet = NULL,
  top_n = 30,
  theta_range = c(-6, 6),
  theta_points = 241,
  title = NULL,
  palette = NULL,
  label_angle = 45,
  show_ci = FALSE,
  ci_level = 0.95,
  group = NULL,
  diagnostics = NULL,
  include_fit_measures = TRUE,
  draw = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  ...
)
```

## Arguments

- x:

  An `mfrm_fit` object from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- type:

  Plot type. Use `NULL`, `"bundle"`, or `"all"` for the three-part fit
  bundle; otherwise choose one of `"facet"`, `"person"`, `"step"`,
  `"wright"`, `"pathway"`, `"ccc"`, `"ccc_surface"`, or
  `"category_surface"`.

- facet:

  Optional facet name for `type = "facet"`.

- top_n:

  Maximum number of facet/step locations retained for compact displays.

- theta_range:

  Numeric length-2 range for pathway, CCC, and category-surface plot
  data.

- theta_points:

  Number of theta grid points used for pathway, CCC, and
  category-surface plot data.

- title:

  Optional custom title.

- palette:

  Optional color overrides.

- label_angle:

  Rotation angle for x-axis labels where applicable.

- show_ci:

  If `TRUE`, add approximate confidence intervals when available.

- ci_level:

  Confidence level used when `show_ci = TRUE`.

- group:

  Optional grouping for `type = "wright"` to overlay per-group
  person-density curves (DIF / DFF screening view). Either a column name
  (looked up first in `group_data` when supplied through `...`, then in
  `fit$prep$data`) or a vector aligned with `fit$facets$person`. Ignored
  for other `type` values. To pass the source data alongside, use
  `plot(fit, type = "wright", group = "MyCol", group_data = <df>)`.

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When supplied, pathway plot data reuse it for `fit_measures`,
  `fit_status`, and `curve_fit_status` instead of recomputing
  diagnostics.

- include_fit_measures:

  If `TRUE` (default), pathway plot data include tidy fit-measure and
  fit-status tables for custom R graphics. Set to `FALSE` when only the
  curve coordinates are needed.

- draw:

  If `TRUE`, draw the plot with base graphics.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- ...:

  Additional arguments ignored for S3 compatibility.

## Value

Invisibly, an `mfrm_plot_data` object (default and for any single
`type`), or an `mfrm_plot_bundle` when `type = "bundle"` / `"all"` /
`"default"`.

## Details

This S3 plotting method provides the core fit-family visuals for
`mfrmr`. When `type` is omitted, it returns the Wright map alone as an
`mfrm_plot_data` object (the most useful single figure for a first
inspection). Pass `type = "bundle"` (or `"all"` / `"default"`) to obtain
the legacy three-plot `mfrm_plot_bundle` containing a Wright map,
pathway map, and category characteristic curves. The returned object
always carries machine-readable metadata through the `mfrm_plot_data`
contract, even when the plot is drawn immediately.

`type = "wright"` shows persons, facet levels, and step thresholds on a
shared logit scale. Estimates are plotted as fitted, so the sign
convention follows the fit: higher person values indicate higher
ability, and higher non-person facet values indicate greater
severity/difficulty under the default negative facet orientation. Facets
listed in `fit_mfrm(positive_facets = ...)` are reversed (higher values
raise expected scores); state the active orientation in figure captions
when reporting. `type = "pathway"` shows expected score traces and
dominant-category regions across theta. This expected-score display is
distinct from the Bond-and-Fox-style measure-versus-fit "pathway" bubble
chart used around FACETS/Winsteps output; for that display, use
[`plot_bubble()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bubble.md).
Its draw-free plot data also includes `pathway_long`,
`pathway_annotations`, `fit_measures`, `fit_status`, and
`curve_fit_status`, so R users can rebuild the pathway map in ggplot2,
plotly, or a report pipeline while keeping the same underfit/overfit
labels used by
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md).
`type = "ccc"` shows category response probabilities.
`type = "ccc_surface"` or `type = "category_surface"` returns 3D-ready
category-probability surface data for external rendering; it
deliberately does not add a plotly/rgl dependency or replace the 2D
CCC/pathway reporting figures. The returned object includes
`category_support`, `interpretation_guide`, and `reporting_policy`
tables so retained zero-frequency categories and manuscript-use
boundaries remain visible to beginners. The remaining types (`"facet"`,
`"person"`, `"step"`, `"shrinkage"`) provide compact location-specific
displays.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Use `plot(fit)` to inspect the Wright map at a glance.

3.  Switch to `type = "pathway"`, `"ccc"`, or `"shrinkage"` for the
    relevant follow-up figure, or `type = "bundle"` for the three-plot
    overview when preparing a FACETS-style summary.

## Further guidance

For a plot-selection guide and extended examples, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md),
[`plot_bubble()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bubble.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy,
  "Person",
  c("Rater", "Criterion"),
  "Score",
  method = "JML",
  model = "RSM",
  maxit = 30
)
wright <- plot(fit, draw = FALSE)
wright$data$plot
# Look for: persons clustered against the facet / step rows on the
#   shared logit axis. Large gaps between the person density and
#   the step / facet rails indicate weak targeting; ceiling /
#   floor stripes mean the test is too easy / hard.
bundle <- plot(fit, type = "bundle", draw = FALSE)
bundle$wright_map$data$plot
# Look for: pathway curves rising in the expected order with
#   visible dominant-category bands; CCC curves peaking sequentially
#   without one category being completely overlapped by neighbours.
surface <- plot(fit, type = "ccc_surface", draw = FALSE)
head(surface$data$surface)
surface$data$category_support
# Look for: every retained category having `Observed > 0`; categories
#   with zero observations are returned as a zero-observation slice and
#   should not be interpreted as a real score region.
surface$data$interpretation_guide
if (interactive()) {
  plot(
    fit,
    type = "wright",
    preset = "publication",
    title = "Customized Wright Map",
    show_ci = TRUE,
    label_angle = 45
  )
  plot(
    fit,
    type = "pathway",
    title = "Customized Pathway Map",
    palette = c("#1f78b4")
  )
  plot(
    fit,
    type = "ccc",
    title = "Customized Category Characteristic Curves",
    palette = c("#1b9e77", "#d95f02", "#7570b3")
  )
}
}
```
