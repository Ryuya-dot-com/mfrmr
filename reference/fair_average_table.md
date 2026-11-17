# Build an adjusted-score reference table bundle

Build an adjusted-score reference table bundle

## Usage

``` r
# S3 method for class 'mfrm_fair_average'
confint(
  object,
  parm = NULL,
  level = 0.95,
  nsim,
  seed,
  contrasts = NULL,
  anchor_source = NULL,
  generating_fit = NULL,
  response_map = NULL,
  anchor_uncertainty = c("estimated", "fixed"),
  gradient_tol = 1e-04,
  method = c("refit", "delta", "bounded"),
  generator_method = c("ordinary", "jeffreys"),
  mc_level = 0.95,
  ...
)

# S3 method for class 'mfrm_fair_intervals'
summary(object, ...)

# S3 method for class 'mfrm_fair_intervals'
print(x, ...)

# S3 method for class 'mfrm_fair_intervals'
plot(x, draw = TRUE, show_title = FALSE, show_notes = FALSE, ...)

fair_average_table(
  fit,
  diagnostics = NULL,
  facets = NULL,
  totalscore = TRUE,
  umean = 0,
  uscale = 1,
  udecimals = 2,
  reference = c("both", "mean", "zero"),
  label_style = c("both", "native", "legacy"),
  omit_unobserved = FALSE,
  xtreme = 0,
  fair_se = FALSE,
  ci_level = 0.95,
  xtreme_method = c("display", "facets"),
  reference_plan = NULL
)
```

## Arguments

- object:

  For [`confint()`](https://rdrr.io/r/stats/confint.html) /
  [`summary()`](https://rdrr.io/r/base/summary.html), output from
  `fair_average_table()` with `reference_plan`, or a saved
  `mfrm_fair_intervals` object.

- parm:

  Person IDs (`NULL` selects all).

- level:

  Pointwise confidence level in `(0, 1)` and joint binomial
  order-statistic Monte Carlo endpoint-enclosure level (`0.95` default
  for `method = "refit"`).

- nsim:

  Replication count (`>= 2`) and seed for `method = "refit"` (unresolved
  refits remain in the planned denominator as `+/-Inf`, yielding
  `Status = "unresolved_tail"` when tail quantiles are unbounded).

- seed:

  Replication count (`>= 2`) and seed for `method = "refit"` (unresolved
  refits remain in the planned denominator as `+/-Inf`, yielding
  `Status = "unresolved_tail"` when tail quantiles are unbounded).

- contrasts:

  Optional named zero-sum Person contrast matrix.

- anchor_source:

  Two-stage anchor-provenance fits, union-event index map
  (`list(calibration = ..., scoring = ...)`), anchor treatment
  (`"estimated"` vs `"fixed"`), and stationarity tolerance (`1e-4`
  default).

- generating_fit:

  Two-stage anchor-provenance fits, union-event index map
  (`list(calibration = ..., scoring = ...)`), anchor treatment
  (`"estimated"` vs `"fixed"`), and stationarity tolerance (`1e-4`
  default).

- response_map:

  Two-stage anchor-provenance fits, union-event index map
  (`list(calibration = ..., scoring = ...)`), anchor treatment
  (`"estimated"` vs `"fixed"`), and stationarity tolerance (`1e-4`
  default).

- anchor_uncertainty:

  Two-stage anchor-provenance fits, union-event index map
  (`list(calibration = ..., scoring = ...)`), anchor treatment
  (`"estimated"` vs `"fixed"`), and stationarity tolerance (`1e-4`
  default).

- gradient_tol:

  Two-stage anchor-provenance fits, union-event index map
  (`list(calibration = ..., scoring = ...)`), anchor treatment
  (`"estimated"` vs `"fixed"`), and stationarity tolerance (`1e-4`
  default).

- method:

  `"refit"` (whole calibration-to-anchor-to-scoring parametric bootstrap
  basic limits), `"delta"` (analytic two-stage event-covariance
  propagation), or `"bounded"` (Hoeffding inequality on declared
  `rating_min:rating_max` with `category_policy = "preserve"`).

- generator_method:

  For `"refit"`, `"ordinary"` or `"jeffreys"` (\\-\ell(b) -
  \tfrac12\log\|I(b)\|\\ generator).

- mc_level:

  Pointwise confidence level in `(0, 1)` and joint binomial
  order-statistic Monte Carlo endpoint-enclosure level (`0.95` default
  for `method = "refit"`).

- ...:

  Unused; must be empty.

- x:

  For `print.mfrm_fair_intervals()`: A saved `mfrm_fair_intervals`
  result.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Saved
  output of `confint.mfrm_fair_average()`.

- draw:

  Logical; print the `ggplot` figure when `TRUE`.

- show_title:

  Logical; display title/cautions, off by default.

- show_notes:

  Logical; display title/cautions, off by default.

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  for this `fit`. Matching saved diagnostics are reusable; recompute
  them after refitting.

- facets:

  Optional subset of facets.

- totalscore:

  Include all observations for score totals (`TRUE`) or apply
  extreme-row exclusion (`FALSE`). In ordinary additive RSM/PCM JML,
  finite direct anchors remain eligible even with
  all-minimum/all-maximum responses, under both `xtreme_method`
  conventions.

- umean:

  Additive origin shift for Measure (not fair-score values).

- uscale:

  Multiplicative scale for Measure and measure SEs (not fair scores).

- udecimals:

  Rounding digits used in formatted output.

- reference:

  Which adjusted-score reference to keep in formatted outputs: `"both"`
  (default), `"mean"`, or `"zero"`.

- label_style:

  Column-label style for formatted outputs: `"both"` (default),
  `"native"`, or `"legacy"`.

- omit_unobserved:

  If `TRUE`, remove unobserved levels.

- xtreme:

  Nonnegative correction smaller than the score range for
  all-minimum/all-maximum rows. Default `0` leaves measures unchanged.
  Its units depend on `xtreme_method`; no responses or primary estimates
  are changed, and this does not correct JML bias.

- fair_se:

  Logical. When `TRUE` and `fit` is an MML `GPCM` fit, add structural
  delta-method standard errors and confidence limits for `Fair(M)` /
  `AdjustedAverage` and `Fair(Z)` / `StandardizedAdjustedAverage`.
  Person rows remain `NA` because MML person EAP estimates are not part
  of the structural Hessian. For `RSM`, `PCM`, and `JML` fits this
  option leaves fair-average SE columns unavailable.

- ci_level:

  Confidence level used when `fair_se = TRUE`; default `0.95`.

- xtreme_method:

  `"display"` (default) retains the historical average-score display
  adjustment. `"facets"` uses conditional total-score extrapolation for
  ordinary additive RSM/PCM JML, without group-mean anchors. Supply
  `xtreme = .3` explicitly to use the usual FACETS main correction.

- reference_plan:

  Optional data frame of non-Person facet columns, using the fitted
  facet names, and an optional positive `Weight` column. For ordinary
  additive RSM/PCM JML, adds `reference_scores`: each Person's expected
  average on this same plan, using its fitted facet locations and scale
  profiles. Weights are normalized to sum to one. This distinct target
  does not replace FairM/FairZ or their administered PCM scale mixture.
  Primary estimates are used, irrespective of display/extrapolation
  settings. Scores use internal score units, unaffected by `umean` or
  `uscale`. The result retains the fit for
  `confint.mfrm_fair_average()`. For an explicit `mfrm_jeffreys_fit`,
  this argument is required and the result contains only common-plan
  `reference_scores`, the plan, fit and estimator identity. Other
  arguments beyond `fit` and `reference_plan` are refused: ordinary
  FairM/FairZ diagnostics do not apply. Inspect `summary(result)`; use
  `plot(confint(result, ...))` for supported interval plots. Direct
  FairM/FairZ plotting is unavailable for this result.

## Value

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly
a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains all result rows, uncertainty labels, `monte_carlo` enclosures,
and `notes`.

A named list with:

- `by_facet`: named list of formatted data.frames

- `stacked`: one stacked data.frame across facets

- `raw_by_facet`: unformatted component tables

- `settings`: resolved options

## Details

**Two-stage delta and bounded formulas.** For stage Jacobians \\H_c,
H_s\\, anchor map \\A = \partial a/\partial b_c\\, cross-derivative
\\B\\, and target derivatives \\G_s, G_a\\, union-event loadings are
\\U_s = X_s H_s^{-1}G_s^\top\\ and \\U_c = X_c H_c^{-1}A^\top(G_a - G_s
H_s^{-1}B)^\top\\ with categorical covariance \\V = \sum_e
\mathrm{Cov}\_{p\_{g,e}}(U_s + U_c)\\ (Murphy & Topel, 1985;
`CIEligible = FALSE` pending short-exposure qualification). For
`"bounded"`, signed event weights \\a_e\\ on scores in \\\[l, u\]\\ have
Hoeffding radius \\r = \sqrt{\tfrac12\log(2/\alpha)\sum_e a_e^2(u -
l)^2}\\ (`CIEligible = TRUE`, `Informative` flags bounds narrower than
the full rubric range; Hoeffding, 1963).

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
common-plan expected-score intervals

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Points are
common-plan expected scores or declared paired differences. Bars show
only available pointwise bounds under the saved method. Missing bars are
not zero uncertainty. Plotting never recalculates the fit or removes
unresolved rows from the saved result. For refit results the bars show
the empirical interval; endpoint Monte Carlo enclosures are retained in
the returned table and `plot_data(p)$monte_carlo`, not drawn as sampling
intervals. See `confint.mfrm_fair_average()` for the estimand,
assumptions and finite-sample limitations.

Computes model-adjusted reference averages in score units across
`by_facet`, `stacked`, and unformatted `raw_by_facet` (`Level` key).
`RSM` uses the shared scale; `PCM` converts each observation's reference
predictor using its administered step profile before weight-averaging
(`Fair(M)` / `AdjustedAverage` sets other facets to their finite means;
`Fair(Z)` / `StandardizedAdjustedAverage` sets them to zero, which is an
expected score at zero reference rather than a z-score).

**Extreme-score handling (`xtreme > 0`)**: `PrimaryMeasure` retains the
original fitted measure. `"display"` inverts an endpoint-shifted average
for `Measure` only (`Model S.E.` is `NA`; fair averages are unchanged).
For ordinary additive RSM/PCM JML without group-mean anchors, `"facets"`
shifts the eligible weighted total inward by `xtreme` times the smallest
positive weight (retaining finite direct anchors unless paired with an
unanchored extreme), solves the conditional score equation, and reports
conditional reciprocal-sqrt-information SE (`MeasureBasis`,
`MeasureSEBasis`, `ExtremeAdjustment`). Fair-score CIs remain
unavailable when `xtreme > 0`.

**GPCM and SE caveat**: For slope-facet element \\j^\star\\,
\$\$\mathrm{FA}\_{p, j^\star} = \sum_k k \cdot P\_{GPCM}(X = k \mid
\theta_p, a\_{j^\star}, \boldsymbol{\delta}\_{j^\star});\$\$ non-slope
facets use unit geometric-mean slope and average threshold profiles
before conversion (a package reporting convention, not FACETS score-side
equivalence). `Model S.E.` / `ModelBasedSE` and `Real S.E.` /
`FitAdjustedSE` are **measure-level** SEs rescaled by `abs(uscale)` –
never use them as \\\pm 1.96\\\mathrm{SE}\\ bounds on fair scores. When
`fair_se = TRUE` on MML GPCM fits, structural delta-method
`Fair(M) S.E.` / `AdjustedAverageSE` columns are added for non-Person
facets (`Person` rows stay `NA`; `FairCIEligible = FALSE`, diagnostic
use only).

## Common-plan Person expected-score intervals (`confint.mfrm_fair_average`)

Compute experimental fixed-Person parametric `"refit"` or two-stage
`"delta"` intervals, or conservative finite-sample `"bounded"` Hoeffding
intervals, on `fair_average_table(..., reference_plan = ...)` outputs
from unit-weight additive RSM/PCM JML (ordinary or
`jml_penalty = "jeffreys"`).

## References

- Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.

- Linacre, J. M. (1994). *Many-facet Rasch Measurement* (2nd ed.). MESA
  Press.

- Linacre, J. M. (2026). *A user's guide to FACETS, version 4.5.0*.
  Winsteps.com. (FACETS Table 7 corresponds to the fair-average
  construction implemented here for `RSM` / `PCM` fits; the slope-aware
  element-conditional construction for `GPCM` is documented in this help
  page.)

- Andrich, D. (1978). A rating formulation for ordered response
  categories. *Psychometrika, 43*(4), 561-573.
  [doi:10.1007/BF02293814](https://doi.org/10.1007/BF02293814)

- Masters, G. N. (1982). A Rasch model for partial credit scoring.
  *Psychometrika, 47*(2), 149-174.
  [doi:10.1007/BF02296272](https://doi.org/10.1007/BF02296272)

- Muraki, E. (1992). A generalized partial credit model: Application of
  an EM algorithm. *Applied Psychological Measurement, 16*(2), 159-176.
  (Cited for the `GPCM` slope-aware extension.)

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("confint.mfrm_fair_average", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
d <- load_mfrmr_data("example_core")
# Calibrate the observed ratings with ordinary joint maximum likelihood.
f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", rating_min = 1, rating_max = 4, category_policy = "preserve",
  optimizer = "BFGS", maxit = 500, reltol = 1e-11)
# The bundled example's rubric is 1--4; declare it independently of sample extrema.
# Every Person is evaluated against these same Rater-Criterion cells.
plan <- unique(d[c("Rater", "Criterion")])
fair <- fair_average_table(f, reference_plan = plan)
head(fair$reference_scores) # Expected average, in internal score units.
# Two replications exercise the API only; they cannot qualify coverage.
# Explicit experimental generator; points and every refit remain ordinary JML.
ci <- confint(fair, parm = c("P001", "P002"), nsim = 2, seed = 71,
  generator_method = "jeffreys",
  contrasts = matrix(c(1, -1), 1,
    dimnames = list("P001 minus P002", c("P001", "P002"))))
summary(ci) # Read Status and Available alongside the limits.
attr(ci, "trials") # Includes unresolved refits and their reasons.
attr(ci, "monte_carlo") # Infinite enclosures expose the two-draw tail uncertainty.
plot(ci, draw = FALSE) # Saved plotting data, including the cautions.
# Deterministic local approximation to the same expected-score target:
delta <- confint(fair, parm = c("P001", "P002"), method = "delta")
delta[, c("Target", "Estimate", "SE", "Available", "CIEligible")]
attr(delta, "covariance") # Includes the covariance between Persons.
# Conservative alternative with explicit observed/unobserved plan support:
bounded <- confint(fair, parm = c("P001", "P002"), method = "bounded")
bounded[, c("Target", "Estimate", "DesignEstimate", "CI_Lower", "CI_Upper", "Informative")]
attr(bounded, "support") # Check how much of the plan was actually observed.
} # }
# Continue the confint.mfrm_fair_average() example:
# plot(ci)
# p <- plot(ci, draw = FALSE)
# plot_data(p, "notes")
# Long-running workflow; run explicitly when needed.
# example("fair_average_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Use the diagnostics saved with this fit
diagnostics <- example_fit$diagnostics

# Compare observed person means with model-based scores on a common reference
fair <- fair_average_table(fit, diagnostics = diagnostics, facets = "Person",
                           reference = "mean", label_style = "native")
head(fair$raw_by_facet$Person[, c("Level", "ObservedAverage", "FairM")])
# FairM uses the mean reference for the other facets; it is in score units
# It is a conditional model prediction, not a guarantee of fairness

# Fit the same synthetic ratings by JML to illustrate total-score extrapolation
toy <- load_mfrmr_data(example_fit$dataset)
jml <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML")
extreme_report <- fair_average_table(jml, xtreme = .3, xtreme_method = "facets")
head(extreme_report$raw_by_facet$Person[, c("Level", "PrimaryMeasure",
     "Measure", "MeasureBasis", "ModelSE", "MeasureSEBasis")])
# ModelSE describes the adjusted total when MeasureBasis says extrapolation
} # }
```
