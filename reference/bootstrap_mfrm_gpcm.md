# Parametric bootstrap for GPCM slopes or a matched PCM comparison

Simulate Persons and scores on the analyzed rating assignment and refit
the model. With no `null_fit`, saved draws support slope intervals. With
a matched PCM `null_fit`, simulate under PCM and refit both models for a
bootstrap LRT.

Plot the selected inference result without fitting or recomputing
covariance. These plots describe discrimination or specified contrasts,
not rater severity, agreement, quality or recommended scoring weights.

## Usage

``` r
bootstrap_mfrm_gpcm(fit, nsim = 499L, seed, null_fit = NULL)

# S3 method for class 'mfrm_gpcm_bootstrap'
confint(
  object,
  parm = "slopes",
  level = 0.95,
  scale = c("relative", "standardized"),
  contrasts = NULL,
  contrast_scale = c("ratio", "difference"),
  simultaneous = c("none", "bonferroni"),
  ...
)

# S3 method for class 'mfrm_gpcm_bootstrap'
summary(object, ...)

# S3 method for class 'mfrm_gpcm_bootstrap'
print(x, ...)

# S3 method for class 'mfrm_slope_intervals'
plot(
  x,
  title = "GPCM slope uncertainty",
  subtitle = paste(attr(x, "target"), attr(x, "method"), paste0(100 * attr(x, "level"),
    "%"), if (attr(x, "simultaneous") == "none") "pointwise" else "Bonferroni", sep =
    " | "),
  reference = NULL,
  draw = TRUE,
  ...,
  type = c("interval", "profile"),
  caption = NULL
)

# S3 method for class 'mfrm_gpcm_bootstrap'
plot(
  x,
  title = "GPCM bootstrap inference",
  subtitle = "Fitted-model parametric bootstrap; unresolved refits retained",
  draw = TRUE,
  ...
)
```

## Arguments

- fit:

  A native GPCM MML fit with eligible local information.

- nsim:

  Planned datasets (default 499, minimum 2). Each needs one or two
  refits. Small values demonstrate mechanics, not accurate tail
  probabilities.

- seed:

  Required nonnegative integer. The caller's RNG state is restored.

- null_fit:

  Optional PCM MML fit accepted by
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  with `nested = TRUE`. This changes the target to an equal-slope LRT;
  its draws must not be used as confidence intervals around the
  alternative GPCM fit.

- object:

  A saved `mfrm_gpcm_bootstrap` result.

- parm:

  Must be `"slopes"`.

- level:

  Nominal confidence level.

- scale:

  As in
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).

- contrasts:

  As in
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).

- contrast_scale:

  As in
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).

- simultaneous:

  As in
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).

- ...:

  For bootstrap slope results, passed to
  [`confint()`](https://rdrr.io/r/stats/confint.html) to select its
  target and level. Otherwise unused.

- x:

  Saved
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  output from `parm = "slopes"`, or `bootstrap_mfrm_gpcm()` output.

- title:

  Optional returned metadata; NULL removes it. The interval description
  defaults to the saved target, method, confidence level and any saved
  numerical or bootstrap cautions. Custom text overrides this default,
  while the diagnostics remain in the plot data and interval tables.
  Titles and notes are not drawn. Use `plot_data(p, "notes")` for
  descriptions and cautions, and `plot_data(p, "title")` for the
  suggested figure title.

- subtitle:

  Optional returned metadata; NULL removes it. The interval description
  defaults to the saved target, method, confidence level and any saved
  numerical or bootstrap cautions. Custom text overrides this default,
  while the diagnostics remain in the plot data and interval tables.
  Titles and notes are not drawn. Use `plot_data(p, "notes")` for
  descriptions and cautions, and `plot_data(p, "title")` for the
  suggested figure title.

- reference:

  Optional finite numeric vertical reference. Default NULL; no quality
  threshold or scoring-policy cutoff is selected.

- draw:

  TRUE draws the ggplot; FALSE returns it only.

- type:

  For saved slope intervals, `"interval"` displays bounds; `"profile"`
  displays saved likelihood evaluations and the same-target Wald limits.
  The default is `"profile"` for saved profile calculations and
  `"interval"` otherwise. This never initiates profiling.

- caption:

  For saved slope intervals, optional returned caption. NULL removes it.
  Two-family intervals state the distinct family references by default.
  Profile plots supply a default explanation of line styles and missing
  coordinates when omitted.

## Value

A serializable result containing `source`, optional `null_fit`, all
`trials` with errors/warnings and seeds, `draws` on the free parameter
scale, and `settings`. `refit_draws` additionally retains returned
alternative-model parameter vectors before eligibility checks; rejected
rows are diagnostic values, never inputs to
[`confint()`](https://rdrr.io/r/stats/confint.html). `trials` identifies
the last stage and whether each model refit returned. `checks` and
`source_checks` retain category counts/states, numerical status and the
information diagnostics already computed; missing fields mean not
recorded, not a successful check. No extra information calculation is
performed for recording. Older saved results may lack these fields. LRT
results also have `comparison` and `test`. Printing or changing the
interval level never refits. Failed replicates remain present.
[`summary()`](https://rdrr.io/r/base/summary.html) returns
planned/available/unresolved counts, settings and either the saved
likelihood-ratio test or default slope intervals, plus retained
numerical cautions. It does not refit or discard unresolved trials. If a
saved analysis records selected refit updates in `settings$recheck`,
printing and slope intervals retain a caution that it is not a complete
rerun under one procedure. Sampling tables preserve that record and any
`settings$diagnostic_checks_scope`. Missing history means not recorded;
it does not certify that all draws used the currently installed
estimator. After changing estimation or acceptance rules, run a separate
complete bootstrap to evaluate the changed procedure; retain the
original result.

Invisibly a ggplot, retaining an `mfrm_plot_data` attribute for
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
No fitting or resampling is performed.

## Details

One ability is drawn per Person from the fitted conditional-normal
population, shared by all that Person's rows. Facets and covariates are
fixed. The observed assignment is preserved; omitted ratings remain
omitted. No assignment or missingness mechanism is simulated. Population
coefficients and variance are reestimated if estimated in the source
model. Retained formula, factor coding and person data must reproduce
the population design.

[`confint()`](https://rdrr.io/r/stats/confint.html) uses basic bootstrap
errors on the log scale for slopes/ratios, and the identity scale for
differences. The point estimate minus reversed empirical error quantiles
(type 1) supplies the limits. Failed refits and rejected returned
estimates are never removed or replaced: their unknown errors are placed
at both extremes to enclose the empirical limits for every completion.
Limits can be zero, infinite or unbounded. `availability` and
`expected_tail_draws` describe this uncertainty. Bonferroni covers only
the requested finite family, assuming adequate marginal bootstrap
approximations; it is not a coverage guarantee.

For an LRT, `test` reports `(1 + exceedances)/(nsim + 1)`. If any
replicate test is unresolved, `PValue` is missing and
`PValueLower`/`PValueUpper` bound all completions. Monte Carlo binomial
bounds and resolution are also retained. This is fitted-model
calibration, not an exact finite-sample test or a remedy for
misspecification, dependence between Persons, or informative assignment.
Increasing `nsim` improves simulation precision, not the underlying
model. A profile-likelihood method is not used by this function.

Crosses retain unavailable intervals. Open circles retain intervals with
infinite endpoints; the plot does not replace them with finite bounds.
Incomplete intervals retain the computed endpoint as a tick, without a
connecting interval line. A missing endpoint is not an infinite endpoint
or a calibrated one-sided interval. Finite review-only bounds use a
dashed line. The table retains `IntervalStatus`, `CIEligible`, `CIUse`
(when saved), all bounds and failure reasons; returned notes explain the
display. For a bootstrap LRT, a histogram shows resolved null statistics
and a line the observed statistic. The returned notes count every
unresolved replicate.

Use
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
for target-aware tables,
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for plotted values, and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
for customization. Attach one result or a named list with
`mfrm_results(fit, intervals = list(slopes = ci, curves = curves), compute = "never")`.
Named plot routes become `gpcm_slopes`, `gpcm_curves`, etc. Exact source
matching is required; default fit diagnostics are preserved.
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
saves these tables and plots; replay reloads the saved RDS, preserving
the selected methods without rerunning estimation. Markdown report
summaries include the finite, unbounded and unavailable interval counts
and the saved inference cautions/reasons.

For positive slope or ratio intervals spanning many orders of magnitude,
use `as_ggplot(ci) + ggplot2::scale_x_log10()`. Finite bounds and
estimates must be strictly positive. Keep a linear axis for signed
differences. Changing the axis does not narrow the interval or make it
more reliable.

## Eligibility and unresolved replicates

A returned fit is not the same as an accepted replicate. For slope
bootstrapping, a singleton score category (observed once) is a warning,
not by itself a reason to exclude the point estimate. This applies to
the source fit and refits only when a fresh category audit confirms all
score categories are observed in every step scope, with no unsupported
step coordinates or category contrasts. Model identity, numerical
convergence, reevaluated likelihood/gradient and unregularized
joint-information checks must still pass. The saved fit's readiness is
not changed.

Basic bootstrap quantiles do not themselves require a variance estimate
for every replicate. The retained information check is a conservative
solution-quality restriction, not a requirement of the basic formula.
Singular information or unstable numerical refinement remains
unresolved, with returned estimates saved for diagnosis. Positive
ill-conditioned information can be used with a caution after refinement,
unregularized inversion and scaled-gradient checks pass. This is
distinct from a random-effect variance estimated at zero; neither proves
optimization failed by itself. Wald intervals, information-criterion
comparisons and LRT eligibility share the numerical information review
but retain their other checks.

`checks` separates `BootstrapEligible` from `WaldEligible` and retains
`BootstrapCaution`. Accepted singleton or weak-information cases produce
an aggregate warning; cautions also follow
[`confint()`](https://rdrr.io/r/stats/confint.html), its printed output,
returned plot notes, APA tables and reports. A custom subtitle
(including NULL) overrides the plot metadata, not the saved diagnostics.
`source_checks` records the source decision. Use
`apa_table(result, which = "checks")` to inspect refits.
`InformationRefinementVerified`, `InformationRelativeChange`,
`InformationInverseResidual` and `InformationScaledGradient` record a
numerical refinement when needed; missing values mean it was not run. Do
not drop unresolved replicates or substitute diagnostic `refit_draws`
for accepted `draws`. A larger `nsim` does not remove an unresolved
estimation problem or guarantee coverage.

`PopulationSD`, `MinimumStandardizedSlope` and
`MaximumStandardizedSlope` describe the returned optimizer solution.
Standardized slopes multiply relative slopes by the fitted population SD
(one for a fixed standard-normal population). With covariates, this is
the residual population SD. These diagnostics help distinguish scale
changes from a slope approaching zero; they do not certify a boundary
solution or label rater quality. A missing field means the required
estimate was not retained. A near-zero slope, an unused score category
and an ill-conditioned information matrix can have different
consequences for different parameters: stable slopes do not establish
finite thresholds or valid Wald intervals. Use `checks` to identify
cases needing further numerical review before interpreting an unresolved
case. APA check tables display scale, slope, gradient and information
diagnostics with significant digits so that small positive values are
not rounded to zero. The original `checks` fields remain unrounded
numeric values.

## References

Chalmers, R. P. (2012). mirt: A Multidimensional Item Response Theory
Package for the R Environment. Journal of Statistical Software, 48(6),
1–29. [doi:10.18637/jss.v048.i06](https://doi.org/10.18637/jss.v048.i06)
.

Davison, A. C., and Hinkley, D. V. (1997). Bootstrap Methods and Their
Application. Cambridge University Press, Chapter 5.

## See also

[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)

## Examples

``` r
# After fitting compatible MML models:
# boot <- bootstrap_mfrm_gpcm(gpcm_fit, nsim = 499, seed = 92401)
# confint(boot, scale = "standardized")
# test <- bootstrap_mfrm_gpcm(gpcm_fit, nsim = 499, seed = 92402,
#                             null_fit = pcm_fit)
# test$test
# ci <- confint(fit, parm = "slopes", scale = "standardized", method = "sandwich")
# plot(ci, title = NULL)
# apa_table(ci)
# plot_data(ci, "table")
```
