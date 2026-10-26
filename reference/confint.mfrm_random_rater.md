# Population-SD profiles and explicit shared-rater model intervals

Population-SD profiles and explicit shared-rater model intervals

## Usage

``` r
# S3 method for class 'mfrm_random_rater'
confint(object, parm = "rater_sd", level = 0.95, ...)
```

## Arguments

- object:

  A result from
  [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md).
  Profiling requires estimated rater SD.

- parm:

  `"rater_sd"` (default) profiles population variation. `"raters"`
  explicitly requests first-order normal prediction intervals for all
  observed raters. These are not supplied automatically because their
  nominal coverage is not established. `"calibration"` explicitly
  requests observed-information normal approximations for fixed-facet
  levels and steps, excluding population SDs.

- level:

  Confidence level, between zero and one; default 0.95.

- ...:

  Unused.

## Value

A one-row matrix with `Lower` and `Upper`, and attributes `level`,
`method`, `profile` and `note`. The profile retains every evaluated SD,
refitted likelihood, `LR` (twice the loss from the source fit),
information checks and `Detail`. Unresolved numerical checks or endpoint
searches stop with an `mfrm_profile_error`; its `profile` field retains
the evaluations. A failed search does not establish that a statistical
interval is absent. With `parm = "raters"`, one row per rater, computed
from saved estimates and `PredictionSE` without refitting or RTMB.
Attributes retain the method, target, level and interpretation.
Unresolved numerical/information checks, estimated variance boundaries
and unavailable SEs give missing bounds. With `parm = "calibration"`,
one row per fixed-facet level or step, with the same
level/method/target/note attributes and availability guards. Default
calibration tables omit bounds; this explicit calculation uses saved SEs
without refitting and does not establish finite-sample coverage. Both
normal-interval routes retain row-level `IntervalStatus`, `CIEligible`
and plain-language `InferenceReview` in `attr(ci, "diagnostics")`,
together with saved estimates/SEs, and source checks in
`attr(ci, "checks")`. Export the diagnostics table when saving CSV; a
two-column numeric matrix alone loses the explanation. See
[`confint.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_testlet.md)
for the status meanings. A missing interval does not turn a retained
point into a reliable estimate, and more iterations cannot by themselves
remove an estimated-variance boundary restriction.

## Details

For `parm = "rater_sd"`, fixed facets, steps and any estimated ability
SD are refitted at each candidate rater SD, including zero. A specified
known ability SD stays fixed. Earlier saved fits retain their known
N(0,1) population. The search brackets a lower and upper crossing of
twice the log-likelihood loss with `qchisq(level, df = 1)`, around the
fitted SD. It uses the same approximate marginal likelihood as the fit.
The lower bound is zero when the zero-variance submodel belongs to the
likelihood-ratio region. An estimated boundary can therefore have a
positive upper limit even though ordinary Wald intervals are
unavailable. Each nonzero endpoint must attain the likelihood-ratio
cutoff to `1e-4 * min(1, cutoff)` absolute accuracy. Insufficient
floating-point resolution stops the search instead of reporting
coincident limits. Profile refits require positive nuisance information.
With known ability SD, nuisance curvature is checked at both integration
orders. These local numerical checks do not prove a global optimum or
exclude disconnected likelihood-ratio regions between sampled
candidates.

This is an asymptotic likelihood-ratio interval, not a finite-sample
coverage guarantee. The chi-square reference is nonregular at a true
zero variance; the usual one-degree-of-freedom cutoff is conservative
under the standard single-variance boundary asymptotics. Few raters,
Laplace error and design misspecification can alter coverage. The
numerical checks do not establish those asymptotic conditions. The
calculation stops if the fitted or profiled ability variance is an
estimated zero boundary; that additional nuisance boundary requires a
different reference distribution for inference. No ability-SD interval
is supplied. This interval does not quantify the predictive distribution
of a replacement rater, whose variation is a different target.

The separate `parm = "raters"` calculation uses the conditional mode
plus or minus `qnorm((1 + level)/2) * PredictionSE`. It targets
realized, uncentered rater effects relative to the population mean.
First-order calibration uncertainty does not ensure nominal coverage. In
particular, few-rater coverage remains unresolved; see
[`vignette("mfrmr-random-raters")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-random-raters.md).
Requesting this approximation does not make it qualified for
classification or exclusion of raters. It is not a profile interval, a
bootstrap or an interval for a difference of raters.

## References

Self, S. G. and Liang, K.-Y. (1987). Asymptotic properties of maximum
likelihood estimators and likelihood ratio tests under nonstandard
conditions. *Journal of the American Statistical Association*, 82,
605–610.
[doi:10.1080/01621459.1987.10478472](https://doi.org/10.1080/01621459.1987.10478472)
.
