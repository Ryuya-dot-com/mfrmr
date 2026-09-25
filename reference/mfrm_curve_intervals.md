# Uncertainty in GPCM category probabilities and information curves

Evaluate specified rating contexts at known ability values and propagate
the full calibration covariance to category probabilities or per-rating
Fisher information. This is uncertainty in a fitted curve, not a Person
score interval.

## Usage

``` r
mfrm_curve_intervals(
  fit,
  newdata,
  type = c("probability", "information"),
  method = c("model", "sandwich"),
  clusters = NULL,
  adjust = FALSE,
  level = 0.95,
  simultaneous = c("none", "bonferroni")
)

# S3 method for class 'mfrm_curve_intervals'
print(x, ...)

# S3 method for class 'mfrm_curve_intervals'
plot(
  x,
  title = "GPCM curve uncertainty",
  subtitle = paste("Approximate calibration intervals; fixed ability", x$settings$method,
    paste0(100 * x$settings$level, "%"), if (x$settings$simultaneous == "none")
    "pointwise" else "Bonferroni grid points", sep = " | "),
  palette = NULL,
  draw = TRUE,
  caption = NULL,
  ...
)
```

## Arguments

- fit:

  An eligible native GPCM MML fit.

- newdata:

  Data frame with each fitted non-Person facet and a numeric `Theta`
  column. Each row is one rating context at one known ability value. Use
  original facet labels. Unknown levels and missing inputs are refused.

- type:

  `"probability"` (one row per category) or `"information"` (one row per
  supplied context/ability). Information is per rating, not a sum over
  all observed exposures as in
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md).

- method, clusters, adjust, level, simultaneous:

  As in
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).

- x:

  A saved `mfrm_curve_intervals` result.

- ...:

  Unused.

- title, subtitle:

  Optional plot text; NULL removes it.

- palette:

  Optional vector of colors, one per category/series. Line types
  distinguish series in addition to color. The default is colorblind
  friendly.

- draw:

  Draw the ggplot immediately? Default TRUE; FALSE returns it only.

- caption:

  Optional plot caption. If omitted, unavailable intervals are counted
  and explained. NULL removes the caption without removing markers or
  the reasons in the saved table.

## Value

A `mfrm_curve_intervals` list with `table`, `settings`, and the exact
`newdata`. Its plot method returns a ggplot with the plotted data
available in `plot$data`; titles can be omitted and the plot can be
customized.

## Details

The complete GPCM predictor, including fitted facet interactions, is
evaluated from the free parameter vector. A central-difference Jacobian
propagates the full joint covariance. Probability limits use a logit
delta approximation; information limits use a log delta approximation
for `slope^2 * Var(category | Theta, context)`. Bounds respect their
support. Rounded probabilities zero/one and nonpositive information keep
the point but have unavailable intervals. The supplied Theta values are
fixed on the fitted native scale; their estimation uncertainty is not
included. Estimated population parameters enter the joint covariance as
nuisance parameters, not as a request to transform or integrate the
Theta grid.

Bonferroni applies to the finite collection of all output rows in this
call, not to the continuous curve between them. Ribbons connect
grid-point intervals for display. Sandwich interpretation and
independence assumptions are those of
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).
These are asymptotic approximations; numerical agreement does not
establish sampling coverage. A reanalysis of saved correctly specified
GPCM fits found substantial undercoverage for probability intervals in
small incomplete designs, including Bonferroni-adjusted finite-grid
families. Adjustment cannot repair inaccurate marginal approximations.
Refitting every dataset in the affected unequal-rater-slope condition
with the updated optimizer left its interval results unchanged. See the
GPCM scope vignette for the evaluated grid, denominators and source
limitations; an available interval is not a finite-sample coverage
certification. Printing and the default plot subtitle identify the
approximation. Custom plot text may omit that description; retain the
method and its limitations in the figure legend or accompanying report.
Crosses mark retained estimates whose intervals are unavailable. Ribbons
stop at unavailable grid points; a missing ribbon does not mean zero
uncertainty. Consult the table's `InferenceReview` for each reason.

A numerically verified but ill-conditioned information inverse can
supply intervals with a warning, as described in
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).
The warning is saved in `cautions` and the table's `InferenceReview`,
and appears in printing and the default plot subtitle. A custom
subtitle, including NULL, changes the display without removing saved
diagnostics.

## See also

[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md),
[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)

## Examples

``` r
# After fitting a GPCM:
# grid <- expand.grid(Theta = seq(-3, 3, length.out = 41),
#                     Rater = "R01", Criterion = "C01")
# curves <- mfrm_curve_intervals(fit, grid)
# plot(curves, title = NULL, subtitle = NULL)
```
