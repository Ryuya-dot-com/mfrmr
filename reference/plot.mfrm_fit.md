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
  fit_stat = c("Infit", "Outfit"),
  fit_scale = c("mnsq", "zstd"),
  zstd_method = c("engine", "facets"),
  include_person = FALSE,
  person_subset = NULL,
  top_n_person = 30,
  person_labels = c("flagged", "all", "none"),
  facet_labels = c("all", "flagged", "none"),
  panel = c("combined", "facet"),
  fit_range = c(0.5, 1.5),
  zstd_cut = 2,
  draw = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
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

- x:

  An `mfrm_fit` object from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- type:

  Plot type. Use `NULL`, `"bundle"`, or `"all"` for the three-part fit
  bundle; otherwise choose one of `"facet"`, `"person"`, `"step"`,
  `"wright"`, `"pathway"`, `"fit_pathway"`, `"ccc"`, `"ccc_surface"`, or
  `"category_surface"`. `"pathway"` is the theta-to-expected-score
  display; `"fit_pathway"` is the fit-statistic-to-measure display.

- facet:

  Optional facet name for `type = "facet"`.

- top_n:

  Maximum number of facet/step locations retained by the native Wright
  map for compact displays. The FACETS-style payload always retains
  every fitted facet and step location.

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

  If `TRUE`, add approximate confidence intervals when available. The
  formal default is `FALSE`; `type = "fit_pathway"` is the exception and
  displays intervals when this argument is omitted. Pass
  `show_ci = FALSE` explicitly to suppress them there.

- ci_level:

  Confidence level used when `show_ci = TRUE`.

- group:

  Optional grouping for `type = "wright"` to overlay per-group
  person-density curves (DIF / DFF screening view). Either a column name
  (looked up first in `group_data` when supplied through `...`, then in
  `fit$prep$data`) or a vector aligned with `fit$facets$person`. Ignored
  for other `type` values and for `wright_style = "facets_style"`, whose
  person column is a single FACETS-style star frequency. To pass the
  source data alongside, use
  `plot(fit, type = "wright", group = "MyCol", group_data = <df>)`.

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When supplied, Wright-map standard errors and precision metadata reuse
  matching rows from `diagnostics$measures` without replacing fitted
  coordinates, while pathway plot data reuse `fit_measures`,
  `fit_status`, and `curve_fit_status` instead of recomputing
  diagnostics.

- include_fit_measures:

  If `TRUE` (default), pathway plot data include tidy fit-measure and
  fit-status tables for custom R graphics. Set to `FALSE` when only the
  curve coordinates are needed.

- fit_stat:

  For `type = "fit_pathway"`, the horizontal fit statistic: `"Infit"`
  (default) or `"Outfit"`.

- fit_scale:

  For `type = "fit_pathway"`, use mean squares (`"mnsq"`) or
  standardized fit (`"zstd"`) on the horizontal axis.

- zstd_method:

  For a ZSTD fit pathway, use the package engine degrees of freedom
  (`"engine"`, default) or the FACETS/Wright-Masters companion
  calculation (`"facets"`). The latter is a comparison aid, not a claim
  of complete FACETS output equivalence.

- include_person:

  If `TRUE`, include person rows in a fit pathway.

- person_subset:

  Optional character vector of person IDs retained in a fit pathway
  before ranking.

- top_n_person:

  Maximum person rows retained in a fit pathway, ranked by distance from
  expected fit. Use `Inf` for all selected persons.

- person_labels:

  Person-label policy for a fit pathway: `"flagged"` (default), `"all"`,
  or `"none"`.

- facet_labels:

  Facet-level label policy for a fit pathway: `"all"` (default),
  `"flagged"`, or `"none"`. This changes drawn labels only; all retained
  facet rows remain in the draw-free table.

- panel:

  Fit-pathway layout: `"combined"` (distinguish persons by shape) or
  `"facet"` (one base-graphics panel per facet).

- fit_range:

  Mean-square review lines for a fit pathway.

- zstd_cut:

  Absolute ZSTD review line for a fit pathway.

- draw:

  If `TRUE`, draw the plot with base graphics.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- renderer:

  Wright-map renderer. Use `"native"` (default) or `"facets"` for the
  FACETS Table 6-style visual layout. This is the canonical selector for
  new code.

- wright_style:

  Wright-map renderer. `"native"` preserves the package's histogram,
  point, range, and facet-SE display. `"facets_style"` adds a FACETS
  Table 6-style text ruler with person-frequency stars, signed facet
  headers, and labeled score-transition lines. It is a visual-layout
  option, not a claim of numerical equivalence with FACETS. This
  explicit style name is equivalent to `renderer = "facets"`.

- category_labels:

  Optional score rubric labels used by `wright_style = "facets_style"`.
  Supply a named character vector keyed by original score, an unnamed
  vector with one label per retained category, or a data frame with
  `Score` and `Label` columns.

- rows_per_logit:

  Number of FACETS-style ruler rows per logit.

- wright_range:

  Optional finite increasing length-2 logit range for the FACETS-style
  ruler. `NULL` derives a range that contains the fitted data.

- extreme_placement:

  In the FACETS-style renderer, place extreme-score persons at the ruler
  `"ends"` or retain their fitted `"estimate"`.

- persons_per_star:

  Number of persons represented by one `*` in the FACETS-style frequency
  column. `NULL` chooses a compact value automatically.

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
when reporting.

Set `renderer = "facets"` (equivalently,
`wright_style = "facets_style"`) for a line-printer-inspired common
ruler. That mode retains every facet location in its data and shows
actual (original, when scores were internally recoded) adjacent score
transitions. Its `facets_style` payload contains tidy ruler,
person-frequency, facet, step, mean-half-score, header, category-label,
and settings tables for custom graphics. The styling emulates the
semantics of FACETS Table 6; estimates and standard errors remain those
produced by `mfrmr`.

`type = "pathway"` shows expected score traces and dominant-category
regions across theta. This expected-score display is distinct from the
Bond-and-Fox-style fit-versus-measure pathway: use
`type = "fit_pathway"` for Infit/Outfit on the horizontal axis and
measure logits on the vertical axis. Its draw-free plot data include
person-selection settings, CI columns, and explicit SE-source metadata.
The expected-score pathway draw-free data also includes `pathway_long`,
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

3.  Switch to `type = "pathway"`, `"fit_pathway"`, `"ccc"`, or
    `"shrinkage"` for the relevant follow-up figure, or
    `type = "bundle"` for the three-plot overview when preparing a
    FACETS-style summary.

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
head(wright$data$locations)
# Look for: persons clustered against the facet / step rows on the
#   shared logit axis. Large gaps between the person density and
#   the step / facet rails indicate weak targeting; ceiling /
#   floor stripes mean the test is too easy / hard.
bundle <- plot(fit, type = "bundle", draw = FALSE)
bundle$wright_map$data$group_summary
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
