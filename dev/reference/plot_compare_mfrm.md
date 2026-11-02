# Compare Wright maps or category curves from two fitted models

Compare Wright maps or category curves from two fitted models

## Usage

``` r
plot_compare_mfrm(
  reference,
  comparison,
  type = c("wright", "ccc"),
  view = c("comparison", "difference", "scatter"),
  labels = c("Reference", "Comparison"),
  curve_groups = NULL,
  panel = c("auto", "category", "group"),
  facet = NULL,
  marginal = c("auto", "histogram", "none"),
  theta_range = c(-6, 6),
  theta_points = 241L,
  preset = c("standard", "publication", "compact", "monochrome"),
  show_title = FALSE,
  show_notes = FALSE,
  draw = TRUE
)
```

## Arguments

- reference, comparison:

  Two `mfrm_fit` objects. All signed differences are comparison minus
  reference, on the fitted coordinate scale.

- type:

  `"wright"` for distributions/locations or `"ccc"` for category
  probabilities at the zero additive-facet reference profile.

- view:

  `"comparison"` for paired displays, `"difference"` for matched
  location differences versus means (or probability differences), or
  `"scatter"` for 2D location scatterplots (`type = "wright"`).

- labels:

  Two distinct, nonempty display labels, reference first.

- curve_groups:

  Optional step-facet levels to compare. By default all groups are
  required in both fits. An RSM common scale is explicitly paired with
  each selected PCM/GPCM group. Non-RSM fits must share a step owner.

- panel:

  CCC layout: `"auto"` uses category panels in monochrome or with more
  than five categories, otherwise `"group"`. `"category"` always
  separates categories; `"group"` overlays categories within each group.

- facet:

  Optional facet or kind filter (`"Person"`, facet name, or `"Step"`)
  for `type = "wright"` comparisons.

- marginal:

  Marginal histogram display on single-panel Wright scatterplots:
  `"auto"` (default), `"histogram"`, or `"none"`.

- theta_range:

  Finite increasing length-two predictor range for CCCs.

- theta_points:

  Integer number of grid points, at least two.

- preset:

  Existing visual preset; monochrome uses shapes/line types as well as
  grey tones.

- show_title, show_notes:

  Display title and explanatory subtitle. Notes and source readiness
  remain in the returned object.

- draw:

  Draw with the optional ggplot2 renderer. `FALSE` returns data without
  requiring ggplot2. Use
  [`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
  to customize/export a view.

## Value

Invisibly, a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
to read the following components. `plot_data(p, "locations")` and
`plot_data(p, "differences")` describe Wright coordinates and matches;
`plot_data(p, "probabilities")`, `plot_data(p, "differences")` and
`plot_data(p, "summary")` describe CCCs. Both types return
`group_selection`, `category_labels`, `basis`, `scale_contracts`,
`fit_readiness`, `notes` and display `settings`. `source_plots`
preserves the native draw-free payloads and their
exclusions/interpretation metadata.

## Details

This is a descriptive paired-model display, not an information-criterion
comparison or an external-software importer. Recorded centering,
anchors, orientation, category coding, estimator method and coordinate
basis must agree. These checks do not establish scale equivalence: no
origin or unit transformation is estimated, and no observations or model
parameters are refitted. Population SDs, full scale contracts and
compared settings are returned for inspection. Different
data/assignments can affect differences.

Wright maps use all source levels, with persons displayed as violins
only when at least two distinct eligible estimates exist; otherwise
points are used. Facet and step points are offset horizontally only.
Step panels pair corresponding adjacent transitions; RSM steps are
repeated as references across selected PCM/GPCM groups, not estimated
separately. Excluded, non-finite, boundary-separated and unmatched
levels remain in the tables. Differences are unavailable for those rows,
never set to zero. No SE or CI for a difference is calculated. Person
distributions are distributions of fitted point estimates, not posterior
or population density estimates.

CCCs reuse
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
probabilities, retaining GPCM slopes. Additive facet effects and
interactions are fixed at zero in both fits. Equal original category
mappings and a common predictor grid are required. The maximum absolute
probability difference is a grid diagnostic, with its signed value,
category and grid location from the first maximizing row returned; it is
not a continuous-domain supremum or a significance test. Use explicit
group selection or a larger export when many panels are needed.
`Category` retains the native internal code; `OriginalCategory` records
the score label shown in the plot. `ExpectedScoreDifference` uses the
native internal score coding, which need not equal the original score
increments.

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

[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compare_mfrm.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("plot_compare_mfrm", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Load one dataset for both models
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# RSM: shared category thresholds
fit_rsm <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# PCM: separate category thresholds for each criterion
fit_pcm <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "PCM",
  step_facet = "Criterion"
)

# Compare fitted locations; drawing requires the optional ggplot2 package
# If needed, install it once with install.packages("ggplot2")
if (requireNamespace("ggplot2", quietly = TRUE)) {
  plot(fit_rsm, comparison = fit_pcm, labels = c("RSM", "PCM"))

  # Run separately: compare score-category probabilities for one criterion
  plot(fit_rsm, comparison = fit_pcm, type = "ccc",
    curve_groups = "Content", labels = c("RSM", "PCM"))
}

# Plot data remain accessible via plot_data()
paired <- plot(fit_rsm, comparison = fit_pcm, draw = FALSE)
head(plot_data(paired, "differences"))
# Differences are PCM minus RSM; no difference SE or significance test is computed
} # }
```
