# Convert draw-free mfrmr plot data to ggplot2

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns a
`ggplot` object that can be restyled or composed directly. Use
`as_ggplot()` to convert saved `mfrm_plot_data` or to select a supported
display from an analysis object. Passing an existing `ggplot` without
extra controls returns it unchanged, including user edits.

## Usage

``` r
as_ggplot(x, type = NULL, component = NULL, ...)

# Default S3 method
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_design_evaluation'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_design_evaluation_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_signal_detection'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_signal_detection_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_slope_intervals'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_curve_intervals'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_gpcm_bootstrap'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_results'
as_ggplot(x, type = NULL, component = NULL, ...)
```

## Arguments

- x:

  An `mfrm_plot_data` object, or an mfrmr object with a draw-free plot
  method. Corrected-JML slope, location and step plots retain their
  point or cumulative-distribution view, labels, reference and
  interpretation note; conversion does not add confidence intervals.

- type:

  Optional plot type passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for a
  non-plot-data input. A saved plot-data input already selects a view
  and rejects `type`.

- component:

  Optional tabular payload component to convert.

- ...:

  Arguments passed to the draw-free plot method. CCC conversion
  additionally accepts `slope_aes`, `facet_by`, and `show_overlay`. A
  saved `mfrm_plot_data` object already contains its view and display
  settings: it rejects extra arguments (except those three CCC controls
  for a complete CCC view). To change the level or source plot settings,
  create a new payload from the fitted model or statistical result. For
  appearance changes after conversion, use ggplot tools such as
  `ggplot2::labs(title = NULL)`.

## Value

A `ggplot2` plot object, with a `mfrmr_notes` attribute when the source
plot payload contains a `notes` table. Paired Wright/CCC payloads from
[plot(reference, comparison =
comparison)](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
retain their selected comparison or difference view, group selection and
monochrome panel policy.

## Details

Saved plot conversion retains the selected view, values, intervals,
missing states, display settings and interpretation. It does not refit,
rescore, recompute diagnostics or change interval qualifications. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for other tables; choosing a component does not authorize a different
statistic.

**Model and diagnostic views.** Dedicated converters cover Wright maps,
expected-score/fit pathways, CCCs, bubbles, DIF/DFF, portable scores,
testlet and shared-rater results, conditional Person scores and
multivariate D-studies.

- Bubbles keep radii, colours, facet order and reference lines. Relative
  radii are preserved; base plot units and ggplot physical sizes need
  not match across devices. Recreate payloads lacking radii/colours with
  [plot(x, type =
  "bubble")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

- Matched ordinary/extended comparisons retain centered effects, paired
  or difference views, exclusions and alternative text; see
  [`plot.mfrm_extended_comparison()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

- Portable scores use the default or `component = "data"`, preserving
  axes, endpoints, review symbols and unplotted dispositions.

- Agreement keeps the chosen exact/correlation/difference metric, pair
  order, cutoffs, expected overlay and missing pairs. Heatmaps use saved
  labels, palette and fixed metric scales.

- Linking keeps drift/wave intervals, cumulative offsets or common
  counts; unavailable offsets neither become zero nor connect lines
  across gaps. Drift heatmaps use saved residuals.

- Threshold sensitivity retains tile/curve views and text alternatives;
  see
  [`plot.mfrm_screening_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md).
  Response residuals retain their posterior/plug-in probability target,
  absent reference cutoffs, and available Infit when Outfit is
  undefined; see
  [`plot.mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md).

- Testlet/extended score views keep unavailable/prior-only rows,
  conditional uncertainty, exclusions and alternative text; see
  [`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md).
  Bootstrap views use arrows for infinite endpoints and dashed ordinary
  intervals.

**G/D-study views.** D-studies retain G/Phi or SEM panels, fixed-count
groups, units, unavailable estimates, supplied ribbons and gaps;
`component = "series"` uses the same converter. G-studies retain
negative points, component intervals and square outlines for unavailable
intervals. With an analysis object,
`intervals = TRUE, assumption = "normal"` explicitly computes intervals
in its plot method before conversion. Saved plot conversion only reuses
them.

Difference-interval plots from
[mfrm_d_study_comparison](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md)
return `ggplot` objects via both
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) and
`as_ggplot()`, with underlying tables accessible through
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

**Profiles and exploratory structure.** The default and the listed
`component` selectors keep the complete view:

- Severity (`"data"`): ordered levels, normal bounds, guide bands,
  fixed/ unavailable states and precision notes. "Profile" does not mean
  likelihood profiling or qualify exploratory JML/fallback/regularized
  uncertainty.

- Residual PCA (`"data"`): scree/reference/excess/loadings, saved
  eigenvalues, cutoffs, signed loadings and encodings; method IDs are
  not plotted variables.

- External-feature PCA (`"table"`): selected axes, retained-component
  symbols, group colours/shapes, labels and transformations. Score axes
  have equal units; loadings are coefficients, not correlations.

- Dendrograms (`"tree"`): merges, heights, leaf order, labels and group
  boxes, including tied-height cuts. Heights are not significance or
  branch support.

- Imputation co-membership (`"matrix"`): all-imputation denominator, ID
  order, fixed `[0,1]` scale, legend/labels and imputation count. Gray
  crossed cells are unavailable; zero is a valid fraction. Partitions
  are not pooled.

- Silhouettes (`"table"`): widths on `[-1,1]`, saved order and overall
  mean. Numeric profiles keep original-unit means/medians/counts with
  offset symbols; categorical profiles keep category order, unused
  levels, counts and within-group proportions on `[0,1]` (`"table"` or
  `"matrix"`). These summaries do not estimate uncertainty, rater
  quality or sampling stability.

Main-effects `mfrm_d_study` plots retain the selected design comparison
through their dedicated conversion; use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for its tables.

**Interval displays.** Fit-measure `measure_ci` views keep facet/level
rows, saved normal endpoints (including exploratory JML), notes, open
diamonds for fixed targets and crosses for unavailable intervals
(`component = "table"`). Pooled fixed-facet MI uses the same selector,
retaining t endpoints, df, contrasts and complete-data information
cautions. It additionally marks infinite bounds with arrows; arrow tips
are display limits, not finite bounds.

Selecting `component` must preserve the selected view. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to extract other tables and specify their axes and grouping in custom
graphics. Residual Q-Q conversion retains the saved quantile axes with
the default or `component = "data"`; it adds no normality test.
Residual-correlation heatmaps keep the same facet on both axes, scale
`[-1,1]`, gray unavailable cells, overlap counts and interpretation
notes. Rating-scale and category-structure displays keep selected
counts/thresholds, missing outcomes, expected-count overlay and palette;
use the default or matching `category_table`/`threshold_table`.
Thresholds are points; stored SEs/CI-use flags do not become curve or
gap intervals.

Category-curve bundles (including their overview), category-structure
boundary views and threshold ladders also use dedicated conversion to
retain their distinct curve targets and selected view. Fitted CCC plots
from [plot(fit, type =
"ccc")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
retain their dedicated conversion.

Bias scatter/ranked views preserve their axes, saved review rules and
conditional interval bounds, including dashed search-limited bounds.
Bias heatmaps, histograms and facet profiles have dedicated conversions
that retain the selected layout and screening settings. Halo
distributions, selected per-rater summaries and signed retained-edge
matrices preserve the selected metric, missing comparisons and caveats.
Halo network conversion retains the saved graph layout and edges. Save
the complete analysis result and recreate its plot for current notes.

Shrinkage plots from [plot(fit, type =
"shrinkage")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
preserve both estimates for each facet level, their adjustment direction
and saved descriptive bands. Use the default or `component = "data"`.
Conversion does not turn plug-in bands into calibrated confidence
intervals. Recreate older plots from a fit with a refreshed shrinkage
report first.

Other draw-free payloads use a conservative tabular fallback; inspect
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
when automatic inference is not appropriate. Titles, subtitles and
captions are omitted by default and retained as metadata. Use
`plot_data(p, "notes")` to retrieve descriptions and cautions.
Explicitly enabled text is wrapped at 72 columns; use
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
for custom labels or narrower exports. Fit plots created with
`show_title = FALSE` or `show_notes = FALSE` retain those settings on
conversion. To set them when converting a fit directly, pass the flags
through `...`. Interpretation and display notes remain available in
`attr(plot, "mfrmr_notes")`, when present in the source payload. Wright,
pathway, and CCC conversions share the fit-family series palette, honour
monochrome presets and supplied palette overrides, and preserve
line-type or point-shape distinctions. CCC categories retain their
source order. When `slope_aes = "colour"`, slopes instead use a
continuous viridis scale (a grey gradient in monochrome); categories
still have line types.

Fixed-facet RSM/PCM intervals retain the selected covariance method,
level, status symbols and optional ordinary comparison. Titles,
subtitles, captions, reference lines and legends can be changed through
the source plot arguments. Methods use both line types and vertical
offsets, including in monochrome.

## Interactive views

The [visual
gallery](https://ryuya-dot-com.github.io/mfrmr/dev/articles/visual-gallery.html)
shows how to pass a supported ggplot to
[`plotly::ggplotly()`](https://rdrr.io/pkg/plotly/man/ggplotly.html) for
browser-based hovering, zooming and legend filtering. Plotly is an
optional downstream renderer. Keep the original mfrmr plot and its
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
notes alongside the widget; conversion does not recalculate estimates or
intervals. Check labels, custom geoms and interval layers after
conversion. The gallery includes static figures, numeric tables and an
HTML export recipe.

## See also

[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
with `scope = "plots"` for selected purpose-based routes, conversion
status and alternatives.

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("as_ggplot", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
# A balanced slice retains every Rater and Criterion while running quickly.
toy <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
fit <- fit_mfrm(toy, "Person",
                c("Rater", "Criterion"), "Score", maxit = 30)
as_ggplot(fit, type = "wright")
as_ggplot(fit, type = "fit_pathway", include_person = TRUE)
as_ggplot(plot(fit, type = "ccc", draw = FALSE))
} # }
```
