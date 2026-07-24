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
  show_ci = NULL,
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

  Plot type. Omit `type` (or use `NULL` / `"wright"`) for the primary
  native Wright map. Use `"bundle"`, `"all"`, or `"default"` for the
  three-part fit bundle; otherwise choose one of `"facet"`, `"person"`,
  `"step"`, `"wright"`, `"pathway"`, `"fit_pathway"`, `"ccc"`,
  `"ccc_surface"`, or `"category_surface"`. `"pathway"` is the
  theta-to-expected-score display; `"fit_pathway"` is the
  fit-statistic-to-measure display.

- facet:

  Optional facet name for `type = "facet"`.

- top_n:

  Maximum number of facet/step locations retained by the native Wright
  map for compact displays. Step transitions are always retained; any
  omitted facet locations are counted in the returned `retention` table
  and disclosed in the plot subtitle/note. Use `Inf` for a complete
  all-level final map. The FACETS-style payload always retains every
  fitted facet and step location.

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

  Whether to add approximate confidence intervals when available. `NULL`
  selects the display-specific default: `TRUE` for the primary native
  Wright map and `type = "fit_pathway"`, and `FALSE` for the
  FACETS-style ruler and other plot types. With `renderer = "facets"`,
  explicitly setting `show_ci = TRUE` creates a hybrid display:
  FACETS-style ruler grammar with mfrmr uncertainty intervals.

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
  new code. The native map is the primary display and includes available
  facet uncertainty by default. The closest FACETS-style visual uses
  `show_ci = FALSE`.

- wright_style:

  Wright-map renderer. `"native"` preserves the package's histogram,
  point, range, and facet-SE display. `"facets_style"` adds a FACETS
  Table 6-style text ruler with person-frequency stars, signed facet
  headers, and labeled score-transition lines. It is a visual-layout
  option, not a claim of numerical equivalence with FACETS. This
  explicit style name is equivalent to `renderer = "facets"`. Adding
  `show_ci = TRUE` to that style is an mfrmr/FACETS hybrid rather than
  the closest FACETS-style view.

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
`"default"`. Each returned fit plot includes domain-specific readiness
and an interpretation status in its data payload.

## Details

This S3 plotting method provides the core fit-family visuals for
`mfrmr`. When `type` is omitted, it returns the Wright map alone as an
`mfrm_plot_data` object (the most useful single figure for a first
inspection). Pass `type = "bundle"` (or `"all"` / `"default"`) to obtain
the legacy three-plot `mfrm_plot_bundle` containing a Wright map,
pathway map, and category characteristic curves. The compact native
default records any omitted facet locations in `data$retention` and
annotates the subtitle and drawn figure; use `top_n = Inf` to retain
every fitted location in the final Wright map. Native text labels remain
collision-aware, so a retained point may be unlabeled; its exact level
and estimate remain available in the returned plot data. When the fit
records boundary-separated facet levels and no display range was
supplied, the native and FACETS-style maps use the same robust automatic
range and place those levels at ruler ends. Exact fitted values and
intervals remain in `OriginalEstimate`, `CI_Lower`, and `CI_Upper`;
`DisplayEstimate`, `DisplayCI_Lower`, `DisplayCI_Upper`, and the
clipping-status columns describe only the rendered coordinates. Endpoint
triangles and the plot footer disclose any omitted or clipped interval.
The returned object always carries machine-readable metadata through the
`mfrm_plot_data` contract, even when the plot is drawn immediately.

Every fit-derived payload also carries `data$fit_readiness`,
`data$interpretation_status`, and `data$interpretation_note`.
Availability and interpretability are separate: when a numerical, data,
design, or stability gate requires review, the coordinates remain
available for diagnosis, but the call warns and marks the returned
subtitle and drawn title `REVIEW ONLY`.

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
and settings tables for custom graphics. `RulerValue` records the
nearest discrete ruler row for line-printer reconstruction, whereas step
and midpoint lines are drawn at their exact fitted `DrawValue` and step
labels print that logit value. The styling emulates the semantics of
FACETS Table 6; estimates and standard errors remain those produced by
`mfrmr`. Use `show_ci = FALSE` for the closest FACETS-style rendering.
If `show_ci = TRUE` is requested, interpret the result as a hybrid that
adds mfrmr uncertainty intervals to FACETS-style ruler grammar.

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
toy <- load_mfrmr_data("example_operational")
# Seven quadrature points keep this executable example short. For a final
# analysis, restore the default or a prespecified grid and review sensitivity.
fit <- fit_mfrm(
  toy,
  "Person",
  c("Rater", "Criterion"),
  "Score",
  method = "MML",
  model = "RSM",
  quad_points = 7,
  maxit = 30
)
wright <- plot(fit, draw = FALSE)
head(wright$data$locations)
#> # A tibble: 6 × 30
#>   Group Label PlotType Estimate    SE CI_Level SE_Method Measure_Source CI_Lower
#>   <fct> <chr> <chr>       <dbl> <dbl>    <dbl> <chr>     <chr>             <dbl>
#> 1 Rater R01   Facet l…   -0.597 0.180     0.95 Observat… fit + observa…  -0.950 
#> 2 Rater R02   Facet l…   -0.334 0.165     0.95 Observat… fit + observa…  -0.657 
#> 3 Rater R05   Facet l…    0.135 0.198     0.95 Observat… fit + observa…  -0.253 
#> 4 Rater R04   Facet l…    0.169 0.184     0.95 Observat… fit + observa…  -0.192 
#> 5 Rater R03   Facet l…    0.259 0.178     0.95 Observat… fit + observa…  -0.0901
#> 6 Rater R06   Facet l…    0.368 0.217     0.95 Observat… fit + observa…  -0.0570
#> # ℹ 21 more variables: CI_Upper <dbl>, Step <chr>, StepIndex <int>,
#> #   BoundarySeparated <lgl>, XBase <dbl>, X <dbl>, OriginalEstimate <dbl>,
#> #   BelowRange <lgl>, AboveRange <lgl>, DisplayEstimate <dbl>,
#> #   DisplayLabel <chr>, OriginalCI_Lower <dbl>, OriginalCI_Upper <dbl>,
#> #   DisplayCI_Lower <dbl>, DisplayCI_Upper <dbl>, CIClippedLower <lgl>,
#> #   CIClippedUpper <lgl>, CIClipped <lgl>, BoundaryEnd <chr>,
#> #   CISuppressed <lgl>, CIDisplayStatus <chr>
# Look for: persons clustered against the facet / step rows on the
#   shared logit axis. Large gaps between the person density and
#   the step / facet rails indicate weak targeting; ceiling /
#   floor stripes mean the test is too easy / hard.
bundle <- plot(fit, type = "bundle", draw = FALSE)
bundle$wright_map$data$group_summary
#> # A tibble: 3 × 16
#>   Group       PlotType        Min     Q1 Median    Q3   Max DisplayMin DisplayQ1
#>   <fct>       <chr>         <dbl>  <dbl>  <dbl> <dbl> <dbl>      <dbl>     <dbl>
#> 1 Rater       Facet level  -0.597 -0.217  0.152 0.236 0.368     -0.597    -0.217
#> 2 Criterion   Facet level  -0.339 -0.110  0.118 0.169 0.221     -0.339    -0.110
#> 3 Step:Common Step thresh… -1.21  -0.520  0.166 0.603 1.04      -1.21     -0.520
#> # ℹ 7 more variables: DisplayMedian <dbl>, DisplayQ3 <dbl>, DisplayMax <dbl>,
#> #   N <int>, XBase <dbl>, TargetGap <dbl>, DisplayTargetGap <dbl>
# Look for: pathway curves rising in the expected order with
#   visible dominant-category bands; CCC curves peaking sequentially
#   without one category being completely overlapped by neighbours.
surface <- plot(fit, type = "ccc_surface", draw = FALSE)
head(surface$data$surface)
#>   Theta Probability ExpectedScore ScoreVariance Information CategoryInformation
#> 1 -6.00   0.9917645      1.008253   0.008219238 0.008219238        6.754698e-05
#> 2 -5.95   0.9913450      1.008674   0.008637056 0.008637056        7.458832e-05
#> 3 -5.90   0.9909043      1.009117   0.009075921 0.009075921        8.236015e-05
#> 4 -5.85   0.9904413      1.009582   0.009536874 0.009536874        9.093770e-05
#> 5 -5.80   0.9899549      1.010071   0.010021004 0.010021004        1.004038e-04
#> 6 -5.75   0.9894439      1.010585   0.010529453 0.010529453        1.108498e-04
#>   CategoryInformationShare Slope Model Category CurveGroup CategoryIndex
#> 1              0.008218156     1   RSM        1     Common             1
#> 2              0.008635851     1   RSM        1     Common             1
#> 3              0.009074579     1   RSM        1     Common             1
#> 4              0.009535378     1   RSM        1     Common             1
#> 5              0.010019337     1   RSM        1     Common             1
#> 6              0.010527594     1   RSM        1     Common             1
#>   CategoryScore SurfaceX SurfaceY  SurfaceZ
#> 1             1    -6.00        1 0.9917645
#> 2             1    -5.95        1 0.9913450
#> 3             1    -5.90        1 0.9909043
#> 4             1    -5.85        1 0.9904413
#> 5             1    -5.80        1 0.9899549
#> 6             1    -5.75        1 0.9894439
surface$data$category_support
#>   Category CategoryIndex CategoryScore ObservedCount ZeroObserved
#> 1        1             1             1            62        FALSE
#> 2        2             2             2            96        FALSE
#> 3        3             3             3            78        FALSE
#> 4        4             4             4            46        FALSE
#>                  SupportRole
#> 1 observed response category
#> 2 observed response category
#> 3 observed response category
#> 4 observed response category
# Look for: every retained category having `Observed > 0`; categories
#   with zero observations are returned as a zero-observation slice and
#   should not be interpreted as a real score region.
surface$data$interpretation_guide
#>                       Topic
#> 1                      Axes
#> 2        Category dominance
#> 3 Zero-frequency categories
#> 4             Reporting use
#> 5         Renderer boundary
#>                                                                                                                                                   Guidance
#> 1                                       Read SurfaceX as theta/logit, SurfaceY as retained category index, and SurfaceZ as predicted category probability.
#> 2 A high SurfaceZ ridge marks the theta region where that category is most probable; compare with the 2D CCC/pathway view before making a reporting claim.
#> 3                                                                          All retained categories have at least one observed response in the fitted data.
#> 4                          Use the 2D pathway or CCC figure as the default manuscript/report figure; use this surface as exploratory or teaching material.
#> 5                                               mfrmr returns the data contract only and does not execute plotly/rgl or any other interactive 3D renderer.
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
```
