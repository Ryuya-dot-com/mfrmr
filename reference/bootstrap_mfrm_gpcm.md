# Parametric bootstrap for GPCM slopes or a matched PCM comparison

Simulate Persons and scores on the analyzed rating assignment and refit
the model. With no `null_fit`, saved draws support slope intervals. With
a matched PCM `null_fit`, simulate under PCM and refit both models for a
bootstrap LRT.

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
print(x, ...)
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

- object, x:

  A saved `mfrm_gpcm_bootstrap` result.

- parm:

  Must be `"slopes"`.

- level:

  Nominal confidence level.

- scale, contrasts, contrast_scale, simultaneous:

  As in
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).

- ...:

  Unused.

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
interval level never refits. Failed replicates remain present. If a
saved analysis records selected refit updates in `settings$recheck`,
printing and slope intervals retain a caution that it is not a complete
rerun under one procedure. Sampling tables preserve that record and any
`settings$diagnostic_checks_scope`. Missing history means not recorded;
it does not certify that all draws used the currently installed
estimator. After changing estimation or acceptance rules, run a separate
complete bootstrap to evaluate the changed procedure; retain the
original result.

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
default plot subtitle, APA tables and reports. A custom subtitle
(including NULL) overrides the plot text, not the saved diagnostics.
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
```
