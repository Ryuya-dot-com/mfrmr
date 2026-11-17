# Compare measurement-condition counts in a multivariate D-study

See how a planned change in the number of tasks, raters, or other
conditions affects the dependability of a mean score. Plot an existing
D-study result; no model is refitted. Start with `plot(d)` for G and
Phi, then use `plot(d, type = "sem")` to examine error in score units.
If the result has several composites, select them explicitly with
`composite`.

## Usage

``` r
# S3 method for class 'mfrm_multivariate_d_study'
plot(
  x,
  type = c("coefficients", "sem", "error_components"),
  score = NULL,
  x_var = NULL,
  draw = TRUE,
  preset = "standard",
  composite = NULL,
  metric = NULL,
  reference = NULL,
  panel_by = NULL,
  ncol = NULL,
  intervals = FALSE,
  assumption = NULL,
  method = "auto",
  level = 0.95,
  ...
)
```

## Arguments

- x:

  A result from
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md).

- type:

  `"coefficients"` shows G and Phi in separate panels; `"sem"` shows
  relative and absolute standard errors of measurement;
  `"error_components"` shows each source's contribution to planned error
  variance, with separate panels for selected scores and error
  definitions.

- score:

  One or more distinct original score names, in legend order. An
  explicit name always selects an original score, even if a composite
  has the same name. If both `score` and `composite` are `NULL`, select
  the sole composite, or the first score when there are no composites.
  Several composites require an explicit selection.
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
  identifies the selection and composite weights; a suggested title is
  returned rather than drawn on the figure.

- x_var:

  A count column in `x$design_grid`: `"Tasks"`/`"Raters"` for the
  task/rater interface, or a facet label supplied through `facets`. By
  default use the last varying count column, or the last column if none
  varies. A one-facet result permits only its included facet. Each line
  holds the other facet count constant.

- draw:

  Draw the plot when `TRUE`; `FALSE` only returns its data.

- preset:

  Plot style: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`. The first three use distinct curve colors; monochrome
  uses one dark color. Point shapes and line types also distinguish
  curves. An explicit preset overrides
  `options(mfrmr.plot_preset = ...)`.
  [`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
  retains colors saved in a plot payload.

- composite:

  One or more distinct composite names from `x$coefficients`, as defined
  by a weight-matrix column, or `"Composite"` for vector weights. Supply
  either `score` or `composite`, not both.

- metric:

  Optional single metric compatible with `type`: `"G"` or `"Phi"` for
  coefficients; `"RelativeSEM"` or `"AbsoluteSEM"` for SEM. For error
  components, select `"RelativeErrorVariance"` or
  `"AbsoluteErrorVariance"`. `NULL` shows both metrics in separate
  panels.

- reference:

  Optional numeric reference values: between 0 and 1 for coefficients,
  nonnegative for SEM. `NULL` draws no reference lines. The same values
  apply to each panel. These are user-chosen guides, not universal
  acceptance rules or confidence bounds.

- panel_by:

  Optional non-horizontal count column in `x$design_grid`, such as
  `"Raters"` when `x_var = "Tasks"`. Each count gets a separate panel;
  selected scores/composites keep the same color, line type and point
  shape across panels. `NULL` retains the overlaid curves.

- ncol:

  Optional positive integer number of panel columns. Requires `panel_by`
  for curves; by default use up to two columns. Error-component plots
  use one column by default and do not use `panel_by`. With both curve
  metrics selected, panels run through all counts for the first metric,
  then the second.

- intervals:

  `FALSE` (default) draws point curves. `TRUE` computes intervals and
  adds ribbons in one call; also specify `assumption = "normal"` and
  select one `metric`: `"G"`, `"Phi"`, or, with `type = "sem"`,
  `"RelativeSEM"` or `"AbsoluteSEM"`. Alternatively, supply a saved
  `confint(x)` result, or a list with one result per selected
  score/composite, to avoid recalculation. Saved results must use one
  method/level and match the source, weights and design grid; retain
  unavailable rows. `NULL` is equivalent to `FALSE`. Use `plot(ci)`
  separately to compare several interval methods.

- assumption:

  With `intervals = TRUE`, explicitly specify `"normal"` for independent
  normal random effects; this assumption is not tested.

- method:

  With `intervals = TRUE`, the interval method passed to
  [`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md).
  `"auto"` selects exact F for one-facet G and generalized CI for
  one-facet Phi, also for nested plans with source child counts per
  parent unchanged. For two crossed random facets, `"auto"` selects
  approximate `"mls"` null inversion for G/Phi. Undefined MLS widths are
  conservatively retained and flagged in the saved interval result. For
  alternatives or changed nested child counts, select `"approximate_f"`
  or `"mean_square_region"`. For SEM, `"auto"` uses `"mls"` for
  supported balanced crossed/nested sources: chi-square for a single
  mean square, Graybill-Wang for positive sums, Ting for signed sums.
  Two-facet SEM also accepts `"mean_square_region"` for conservative
  normal-model intervals. `"reml_profile"` explicitly fits approximate
  G/Phi intervals for balanced or identifiable incomplete sources; lme4
  and minqa are required for fitting. It preserves the original curve
  points and reports separate REML estimates in the saved intervals. Its
  finite-sample/boundary coverage is not guaranteed. For one-facet
  `RelativeSEM`, explicit `"residual_contrast"` accepts retained
  ANOVA/MINQUE ratings, including incomplete sources. It transforms a
  residual chi-square interval without likelihood fitting, retaining
  original curve points and a separate projected center in the saved
  table. For one-facet G, explicit `"spectral_f"` accepts retained
  ANOVA/MINQUE ratings, including incomplete sources, using a
  normal-model variance-ratio F pivot. It keeps the original points;
  sparse sources can yield wide bands. Balanced crossed G also accepts
  explicit `"score"`, an experimental extended-nuisance score interval
  calculated from stored mean squares. It preserves the source points;
  empty sets and numerical failures remain missing ribbon segments, with
  their reasons in the saved interval object. No method is silently
  substituted after failure.

- level:

  Confidence level for `intervals = TRUE`, default 0.95.

- ...:

  Reserved for future use; additional arguments are rejected.

## Value

Invisibly, a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to extract `table` (the selected scores/composites), `series` (one row
per scenario and plotted metric, including missing values),
`unavailable`, `design_grid`, `weights`, score identity, axis/group
names, labels, `component_note`, and legend settings. In `series`,
`Status` is specific to `Metric`; `table` retains the original row
status and metric-specific columns. `weights` contains a named vector
for one composite, a named matrix for several composites, or `NULL` for
original scores. `reference_lines` and `notes` retain the chosen guides
and their interpretation. When `panel_by` is supplied, `panels` maps
`series$Panel` to its metric, count and label; `ncol` records the
resolved layout for base and ggplot rendering. With `intervals`,
`series` also retains `Lower`, `Upper`, `IntervalStatus`,
`IntervalAvailable` and `IntervalRun` (connected ribbon segments).
`intervals` retains the complete input objects, including diagnostics;
`unavailable_intervals` retains missing bounds separately from missing
point estimates. Save the complete plot object with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) to replay. For
`"error_components"`, `table` and `series` contain the same long
contribution table: `Source`, planned `Multiplier`, projected
`ComponentVariance`, `Contribution`, `DiagonalContribution` and
`CovarianceContribution`. The latter two separate within-score variance
and cross-score covariance terms; they sum to `Contribution`.
`TotalErrorVariance` and `SEMStatus` retain the planned total and its
availability; `totals` retains all original D-study metrics and statuses
for selected scores. `panels`, `legend`, `weights`, `design_grid`,
`component_diagnostics` and `notes` preserve the interpretation.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves these comparisons for editing or export with the optional
ggplot2 package; for example, `as_ggplot(d, type = "sem")`.

## Details

Connects supplied complete balanced plans at fixed other-facet counts
(nested child counts are per parent) without refitting or interpolating
intermediate designs. `"error_components"` displays projected variance
contributions
(`DiagonalContribution + CovarianceContribution = Contribution`,
additive on the variance scale rather than SEM; signed/negative
estimates remain visible).

With `intervals = TRUE` or a compatible saved `confint(x)` object,
pointwise ribbons/segments are overlaid without clipping delta bounds
outside `[0, 1]`; missing bounds break ribbons
(`unavailable_intervals`), and `negative_components` adjustments retain
both adjusted points and original-source bounds. Ribbon overlap is not a
paired difference test; use
[mfrm_d_study_comparison](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md).

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## See also

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_multivariate_d_study", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Question: how much would doubling the common tasks change dependability?
tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
d <- mfrm_d_study(g, data.frame(Tasks = c(3, 6, 12)),
  weights = c(V = -1, W = 1))
plot(d) # Default: the difference W minus V; higher G/Phi is better.
plot(d, type = "sem") # Error in difference-score units; lower is better.
plot(d, score = "V") # Inspect an original score separately.
# Add intervals for both criteria in the same call.
ribbons <- plot(d, score = c("V", "W"), metric = "Phi", reference = 0.8,
  intervals = TRUE, assumption = "normal")
plot_data(ribbons, "intervals") # Saved intervals and their diagnostics.
# 0.8 above is an illustrative user criterion, not a recommended cutoff.
values <- plot_data(plot(d, draw = FALSE))
values$table # Exact values and availability, rather than reading off a line.
if (requireNamespace("ggplot2", quietly = TRUE)) {
  p <- as_ggplot(d, type = "sem")
  print(p)
  # ggplot2::ggsave("d-study-sem.png", p, width = 7, height = 7, dpi = 300)
}

# A weight matrix names several choices; explicitly select the plotted one.
alternatives <- mfrm_d_study(g, data.frame(Tasks = c(3, 6, 12)),
  weights = cbind(Equal = c(V = 0.5, W = 0.5), Difference = c(V = -1, W = 1)))
plot(alternatives, composite = "Equal")
plot(alternatives, composite = "Difference", type = "sem")
if (requireNamespace("ggplot2", quietly = TRUE)) {
  print(as_ggplot(alternatives, composite = "Equal"))
}
# Which sources explain error in the difference score?
sources <- plot(alternatives, composite = "Difference", type = "error_components")
plot_data(sources, "table") # Includes signed cross-score covariance terms.
plot_data(sources, "totals") # Error totals, SEM, G/Phi and availability.
} # }
```
