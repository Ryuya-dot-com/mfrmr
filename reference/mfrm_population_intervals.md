# Pointwise intervals for a conditional-normal population model

Report coefficients, prespecified linear contrasts and residual variance
from an estimated RSM/PCM MML population model. Coefficient intervals
use a normal approximation; residual variance intervals exponentiate a
normal interval for log residual variance. For these experimental
intervals, nominal repeated-sample coverage has not been established
across the supported designs. Passing numerical checks does not
establish this statistical property. Saved cautions are also retained as
an `interpretation_notes` table in
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
reports and table exports.

## Usage

``` r
mfrm_population_intervals(
  object,
  level = 0.95,
  contrasts = NULL,
  anchor_covariance = NULL,
  independent_anchors = FALSE
)

# S3 method for class 'mfrm_population_intervals'
plot(
  x,
  type = c("coefficients", "contrasts"),
  draw = TRUE,
  preset = "standard",
  reference = 0,
  ...
)

# S3 method for class 'mfrm_population_intervals'
print(x, ...)

# S3 method for class 'mfrm_population_intervals'
summary(object, ...)

# S3 method for class 'mfrm_population_intervals'
vcov(object, ...)
```

## Arguments

- object:

  A native RSM/PCM MML fit with an active population model, or saved
  native-location
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  output from that fit. The latter reuses its numerically checked full
  joint covariance without differentiation. For
  [`summary()`](https://rdrr.io/r/base/summary.html) and
  [`vcov()`](https://rdrr.io/r/stats/vcov.html), supply the
  population-interval result.

- level:

  Pointwise confidence level, strictly between zero and one.

- contrasts:

  Optional numeric matrix of prespecified linear combinations of
  population coefficients. Give each row a distinct nonempty target name
  and name every column with a fitted coefficient name, including
  zero-weight columns, as in `names(fit$population$coefficients)`.
  Columns are matched by name. Each row must be finite and nonzero;
  dependent rows are allowed for pointwise intervals. `NULL` retains the
  coefficient/variance-only output.

- anchor_covariance:

  Optional full source-anchor sampling covariance matrix (matching all
  direct anchors on the noncentered facet) and explicit
  independent-sample declaration (`FALSE` default) for direct
  intercept-only RSM/PCM anchor-origin MML.

- independent_anchors:

  Optional full source-anchor sampling covariance matrix (matching all
  direct anchors on the noncentered facet) and explicit
  independent-sample declaration (`FALSE` default) for direct
  intercept-only RSM/PCM anchor-origin MML.

- x:

  For `print.mfrm_population_intervals()`: An interval result.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): A saved
  result from `mfrm_population_intervals()`.

- type:

  Show `"coefficients"` (default, including the intercept) or the
  prespecified `"contrasts"` stored in `x`. Residual variance has
  different units and remains in `summary(x)` rather than sharing this
  axis.

- draw:

  Logical; `FALSE` returns the plot data without drawing.

- preset:

  A package plot preset, including `"publication"` and `"monochrome"`.
  The session default is used when omitted.

- reference:

  Optional finite vertical reference, default zero; `NULL` omits it.
  This is not a practical-importance or automatic decision threshold.

- ...:

  For `print.mfrm_population_intervals()`: Unused.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Unused;
  unsupported arguments are rejected.

## Value

An `mfrm_population_intervals` object with the interval table,
working-coordinate covariance, full parameter covariance, numerical
checks, source identity and unchanged source fit. With `contrasts`, also
contains the column-aligned `contrasts` matrix and
`contrast_covariance`; targets in the table have type
`coefficient_contrast` and prefix `contrast:`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object. Through
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
`table` preserves selected source rows and adds `PlotStatus`, `Label`
and `Y`; `intervals` retains the complete original table.
`population_spec` preserves the formula, trained terms, factor levels
and coding; `population_coding` is a readable coding table.
`contrast_weights`, source identity, settings, numerical checks and
interpretation notes accompany the figure. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to inspect these;
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
remains idempotent on the returned object.

## Details

For \\\theta_i \mid X_i \sim N(X_i\beta, \sigma_e^2)\\, extracts the
inverse full joint observed information (including structural nuisance
parameters) to form normal intervals on working coordinates (`beta` and,
when estimated, `\log\sigma_e^2` in `WorkingEstimate`, `WorkingSE`,
`WorkingLower`, `WorkingUpper`, exponentiated to natural variance with
`NaturalScaleStatus`) plus optional linear contrasts \\L\widehat\beta\\
with covariance \\L V\_\beta L^{\mathsf T}\\ (`contrast_covariance`).
Explicit fixed `population_sd` retains `Status = "fixed"` and
`CIEligible = FALSE`.

Requires direct RSM/PCM MML (unit weights, full-rank coding, centered
additive facets/steps, passing local/information/finer-quadrature and
zero-residual-variance likelihood checks). For intercept-only
anchor-origin fits, `anchor_covariance` with
`independent_anchors = TRUE` (or a saved
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
object) propagates independent source-anchor uncertainty
(`AnchorSourceSE` vs `Conditional*` columns). Intervals remain
experimental (`Status`, `CIEligible`, `InferenceReview`) and do not
propagate calibration uncertainty into
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
saved latent-population coefficients or contrasts

Read point estimates and their experimental pointwise intervals from an
existing population analysis, without fitting or recalculating
uncertainty.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Rows
retain their saved order. Filled circles and lines show numerically
available intervals. Crosses with a `CI unavailable` label retain finite
points without eligible finite bounds. A missing point keeps its labeled
row without a marker; it is never plotted at zero. Titles and
explanatory notes are returned, not drawn. No significance colors or
automatic classifications are added. Plotting does not requalify a saved
numerical result.

Coefficients describe the conditional population mean on the fitted
native ability scale. A continuous coefficient is per unit of its fitted
predictor; the intercept depends on predictor zero values and factor
coding. Read interactions, transformations and categorical comparisons
using the saved coding, not an assumed reference group. Coefficients on
different predictor scales are not directly comparable measures of
importance. Higher ability predicts higher coded ratings in these
RSM/PCM models; whether that is better performance depends on the
rubric. Coefficients are not standardized effects.

Contrasts use the stored linear weights and may describe a conditional
mean or a difference between means. They are not individual ability
differences, causal effects, simultaneous intervals or prediction
intervals. Numerical availability does not establish nominal coverage:
the source's experimental status, failed checks and qualifications
remain in `notes` and the tables. A wide interval remains visible.
Missing bounds are not infinite endpoints. When source-anchor
uncertainty was requested, the saved intervals include that
contribution. The returned subtitle, settings and `anchor_uncertainty`
distinguish it from intervals conditional on exact supplied anchors;
conditional bounds remain in the returned table.

For an executable bundled-data example, run the example on
`mfrm_population_intervals()`, which creates `ci` and both views. Then
use `p <- plot(ci, type = "contrasts", draw = FALSE)`,
`plot_data(p, "contrast_weights")` and `plot_data(p, "notes")` to read
it. `as_ggplot(ci, type = "contrasts")` converts the same saved result.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## See also

[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
`plot.mfrm_population_intervals()`,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)

`mfrm_population_intervals()`,
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[`plot.mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("mfrm_population_intervals", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_core")
persons <- data.frame(Person = unique(ratings$Person))
# Fictional predictor for this example; use your observed covariates.
persons$X <- seq(-1, 1, length.out = nrow(persons))
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
  model = "RSM", method = "MML", population_formula = ~ X,
  person_data = persons, quad_points = 61)
L <- matrix(c(0, 2), nrow = 1,
  dimnames = list("X = 1 minus X = -1", c("(Intercept)", "X")))
ci <- mfrm_population_intervals(fit, contrasts = L)
subset(summary(ci), Type == "coefficient_contrast")
plot(ci)
p <- plot(ci, type = "contrasts")
plot_data(p, "contrast_weights")
plot_data(p, "notes")
results <- mfrm_results(fit, intervals = list(population = ci),
  include = "fit", compute = "never")
apa_table(results$population_intervals$population)
} # }
```
