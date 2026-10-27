# Pointwise intervals for a conditional-normal population model

Report coefficients, prespecified linear contrasts and residual variance
from an estimated RSM/PCM MML population model. Coefficient intervals
use a normal approximation; residual variance intervals exponentiate a
normal interval for log residual variance. These experimental intervals
have unqualified repeated-sample coverage. Method qualification is
incomplete even when numerical checks pass. Saved cautions are also
retained as an `interpretation_notes` table in
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

  Optional full sampling covariance of the supplied anchor estimates,
  including their correlations, in native ability units squared. Row and
  column names must match every directly anchored level on the one
  noncentered facet. Requires the fixed-grid direct RSM/PCM
  anchor-origin route with an intercept-only population and fixed SD.
  `NULL` retains the existing conditional-on-anchors calculation.

- independent_anchors:

  Logical, default `FALSE`. Set `TRUE` with `anchor_covariance` only
  when source calibration and receiving responses are independent.
  Shared respondents or dependent clusters require cross-sample
  covariance and are unsupported. This is an explicit assumption, not a
  check inferred from different Person identifiers.

- x:

  An interval result.

- ...:

  Unused.

## Value

An `mfrm_population_intervals` object with the interval table,
working-coordinate covariance, full parameter covariance, numerical
checks, source identity and unchanged source fit. With `contrasts`, also
contains the column-aligned `contrasts` matrix and
`contrast_covariance`; targets in the table have type
`coefficient_contrast` and prefix `contrast:`.

## Details

For the bounded fixed-SD anchor-origin route, `anchor_covariance` with
`independent_anchors = TRUE` propagates an independently estimated
anchor covariance into the population coefficients and contrasts.
Alternatively, pass a saved facet-interval result already containing
source propagation and omit both arguments; its sensitivity and
conditional information are reused once. See
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
for the formula, required independence, supported scope and complete
bundled-data example. Point estimates are unchanged; conditional
SE/bounds remain in separate `Conditional*` columns.
[`vcov()`](https://rdrr.io/r/stats/vcov.html) then returns
source-propagated coefficient covariance. The fixed population variance
still has no SE or interval. Drift, source-estimate bias, dependent
samples and uncertainty in the supplied SD are not corrected.

The fitted model is \\\theta_i\mid X_i\sim N(X_i\beta,\sigma_e^2)\\.
Residual variance is conditional on the fitted predictors; it is not the
marginal variance of ability. Predictor transformations and coefficient
coding are those retained by the fit. The covariance is taken from the
inverse of the full information, including all structural nuisance
terms. A contrast matrix \\L\\ gives estimates \\L\widehat\beta\\ and
covariance \\L V\_\beta L^{\mathsf T}\\, using the coefficient block of
that inverse. Contrast rows are added to the interval table. These
describe conditional population means or their linear combinations, not
differences between two individual abilities or causal effects. For
example, in `~ X`, weights `(0, 2)` compare the means at `X = 1` and
`X = -1`. Interactions, factor reference levels and transformations must
use the fitted coding. The helper accepts weights in coefficient
coordinates; it does not infer raw covariate profiles or rebuild a
transformation from a new sample.

Use direct MML with fixed or adaptive integration, unit observation
weights, full-rank population coding, centered additive facets and
centered steps, without constraint groups or fitted interactions. The
fixed-SD anchor-origin extension described below also admits supplied
anchors. Source consistency, category support, local solution, full
joint information and finer-integration checks must pass as in
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).
The procedure can return eligible intervals while the source fit retains
`InferenceReady = FALSE`; inspect the interval's `CIEligible`, `Status`,
checks and cautions. This does not change overall fit readiness or
qualify other inference procedures. A recorded identification or
boundary failure prevents intervals. Failed numerical checks retain
point estimates and reasons with unavailable uncertainty. This is an
interior, model-based approximation: it does not handle a zero-variance
boundary, misspecified populations, dependent Persons or informative
assignment. Passing numerical checks does not prove global optimality or
coverage. When residual variance is estimated, a zero-residual-variance
candidate at the retained nuisance estimates is also compared with the
fitted likelihood at both integration orders. A higher boundary
likelihood beyond the numerical allowance prevents intervals. This
inexpensive comparison does not optimize the boundary or rule out other
better boundary candidates. Requests using saved facet inference also
perform this likelihood comparison, without refitting or differentiating
again. A fit with explicit `population_sd` conditions on that positive
fixed SD; zero variance is not a feasible candidate. Its
residual-variance row retains the supplied value with
`Status = "fixed"`, missing SE/bounds and `CIEligible = FALSE`.
Coefficients and their contrasts still have model-based intervals when
numerical checks pass. With `population_formula = ~1`, direct anchors on
the selected `noncenter_facet` can identify the population mean and free
facet locations. By default, these intervals condition on the supplied
anchors and SD. The optional `anchor_covariance` extension adds
independent source-anchor uncertainty while still conditioning on the
SD.

`SE` is on the reported estimate scale (delta-method SE for variance).
`WorkingEstimate` and `WorkingSE` use coefficient/log-variance
coordinates. `WorkingLower` and `WorkingUpper` retain the interval on
that scale. Exponentiation can give displayed variance bounds of zero or
infinity outside floating-point range; `NaturalScaleStatus` identifies
that representation limit while the finite log-scale interval is
retained. [`vcov()`](https://rdrr.io/r/stats/vcov.html) returns their
covariance, with explicit coordinate names; its final coordinate is log
residual variance, not natural variance, when variance is estimated. A
fixed variance has no free covariance coordinate. It remains the
coefficient/log-variance covariance when contrasts are supplied;
`contrast_covariance` separately contains the covariance of the
requested rows. No multiplicity adjustment or automatic significance
decision is made.

Save the result directly, or attach it through
`mfrm_results(fit, intervals = list(population = ci), compute = "never")`.
Tables, reports and exports reuse saved intervals and numerical checks.
Supplied contrast weights and their covariance are also exported. These
tables prefix coordinate columns with `beta:`/`contrast:` to distinguish
them from the `Target` identifier column. The saved result retains the
unchanged fit, including its population formula, trained terms, factor
levels and coding; save the raw reference profiles separately if you
used them to construct the weights. The ordinary population summary
remains a point-estimate table.

## Reading the result

Start with `summary(ci)`, then inspect `ci$checks`,
`ci$numerical_checks` and `ci$cautions`. Keep these with the interval
table when saving or sharing.
[plot(ci)](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_population_intervals.md)
displays saved coefficients; `plot(ci, type = "contrasts")` displays the
supplied linear contrasts. Unavailable intervals remain visible, and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
reuses the same data.

- `Status = "available"` and `CIEligible = TRUE` mean that the numerical
  checks permit the experimental interval. They do not certify nominal
  coverage. `InferenceReview` records this distinction in each row.

- `Status = "fixed"` retains a supplied residual variance without an
  inferential interval; missing uncertainty is not an estimated zero SE.

- `Status = "numerical_review_failed"` retains the point estimate and
  failed-check reason, with unavailable SEs and bounds.
  `nonpositive_variance` or `nonfinite_bounds` instead identifies an
  unusable target-specific uncertainty calculation. Missing bounds are
  not infinite endpoints.

- `NaturalScaleStatus = "outside_floating_point_range"` means the finite
  log-variance interval cannot be fully represented after
  exponentiation. Inspect `WorkingLower` and `WorkingUpper`; a displayed
  zero is not an interval qualified for a zero-variance boundary.

Coverage evidence is specific to the target, design and complete
estimation procedure. In the retained RSM checks, mean-at-\\X=1\\ and
log-variance intervals at 20 Persons remain inconclusive under the
prespecified practical criteria. The independent 240-Person
slope/mean-difference confirmation supports those targets in its tested
design; it does not establish a minimum sample size or qualify arbitrary
regressions, PCM designs or all contrasts. All outputs from this helper
therefore retain their experimental status.

These intervals do not add calibration uncertainty to individual
scoring.
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
has separate source and scoring checks; its conditional posterior
intervals hold the fitted calibration and population parameters fixed.
Availability here does not authorize an otherwise refused scoring
result. See
[`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md)
for the different uncertainty targets.

## See also

[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`plot.mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_population_intervals.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)

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
