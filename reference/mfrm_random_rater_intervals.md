# Bootstrap prediction intervals for observed random raters

Regenerate persons, shared raters and scores on the observed assignment,
refit the same RSM, and retain prediction errors for every planned
replicate.

## Usage

``` r
mfrm_random_rater_intervals(object, nsim = 499L, seed, level = 0.95)

# S3 method for class 'mfrm_random_rater_intervals'
confint(
  object,
  parm = NULL,
  level = 0.95,
  method = c("studentized", "error"),
  ...
)

# S3 method for class 'mfrm_random_rater_intervals'
summary(object, ...)

# S3 method for class 'mfrm_random_rater_intervals'
print(x, ...)
```

## Arguments

- object:

  A numerically ready
  [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  result with positive information, positive population SD and finite
  positive rater prediction SEs. Estimated zero-variance sources are not
  supported.

- nsim:

  Number of planned bootstrap datasets; default 499, minimum 2. Each
  requires a full refit. Small values are useful for checking a
  workflow, not for stable tail quantiles.

- seed:

  Required nonnegative integer simulation seed. The caller's random
  number state is restored. Per-replicate seeds and RNG kind are
  retained.

- level:

  Pointwise nominal coverage; default 0.95.

- parm:

  Rater IDs for [`confint()`](https://rdrr.io/r/stats/confint.html);
  `NULL` returns all fitted raters.

- method:

  `"studentized"` (default) uses generated-minus-estimated rater effects
  divided by each refit's calibration-adjusted `PredictionSE`. `"error"`
  uses unscaled prediction errors as a comparison. Changing method or
  level through [`confint()`](https://rdrr.io/r/stats/confint.html)
  reuses saved draws without new fitting.

- ...:

  Unused.

- x:

  A bootstrap result.

## Value

An `mfrm_random_rater_intervals` object containing the source rater
table, `intervals`, aligned error/studentized matrices, generated
effects, refitted estimates/SEs, per-trial checks, warnings/errors,
seeds, model settings and analysis data.
[`confint()`](https://rdrr.io/r/stats/confint.html) returns a two-column
matrix with availability, method and Monte Carlo resolution attributes.
No native pointers are stored; save with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html).

## Details

Every generated dataset draws one ability per person and one severity
per rater, shared across their observed rows. Generating fixed facets,
steps and both population SDs are the source estimates. Each Person
ability is drawn from the fitted normal population. The refit
re-estimates calibration and each population SD unless originally fixed.
Earlier saved fits retain their known N(0,1) ability population.
Per-trial records include the refitted ability SD and its zero-boundary
status. The target is a realized effect relative to the population mean,
not a centered effect, new-rater score or fixed rater coefficient.
Coverage is marginal over new persons, rater effects and scores at this
assignment; it is not conditional coverage for each fixed true severity.

Studentized endpoints are the source estimate plus its `PredictionSE`
times the empirical tail quantiles (type 1) of bootstrap errors divided
by refitted `PredictionSE`. Unscaled endpoints add error quantiles
directly. All planned replicates remain in the denominator. Failed fits
and unavailable studentizers are unresolved, including studentizers at
estimated variance boundaries. Lower-tail calculations place unresolved
roots at minus infinity; upper-tail calculations place them at plus
infinity. The resulting limits enclose empirical bootstrap limits for
any completion of those roots. They may be unbounded; failures are never
silently removed or replaced. A numerically ready boundary refit still
supplies an unscaled prediction error.

This is a model-based bootstrap candidate, not a general finite-sample
coverage guarantee. Linear mixed-model bootstrap theory motivates the
construction but does not establish its accuracy for this crossed
ordinal RSM, few raters, variance boundaries or Laplace approximation.
Basic error intervals and studentized intervals need separate empirical
qualification. The fit's normal-population and assignment assumptions
remain essential. Omitted scores stay omitted; this conditions on
analyzed rows and does not simulate a missingness mechanism or impute
assigned scores. Rater contrasts, familywise intervals and simultaneous
rater classification are not provided.

## Review unresolved refits

Inspect `$trials` before interpreting the intervals. `FitReady` combines
numerical and information checks; it does not certify interval coverage.
New results also retain `OptimizerCode`, `NumericalReady`,
`InformationPositive`, `PersonQuadratureStable`, `QuadraturePoints`,
`CheckPoints`, `LogLikDifference`, `GradientDifference`,
`EstimatedVarianceBoundary` and `PersonVarianceUpperBoundary` from each
refit. Together with the recorded gradient and Person-variance boundary,
these distinguish unresolved numerical calculations from variance
boundaries and missing regular studentizers. A failed refit has missing
additional check values and its recorded error; missing checks are not
passes. Older saved trial tables lack these additional fields and cannot
acquire them without rerunning the corresponding refits. Failed checks
must not be removed, selectively retried until successful or relabeled
as adequate interval coverage. Increasing Person quadrature can address
integration precision but does not qualify the rater Laplace
approximation, the interval method or the population assumptions.

Increasing `nsim` alone does not resolve unavailable prediction errors.
For example, with 499 planned refits at 95%, 13 unresolved studentized
errors for one rater make both of that rater's limits infinite under the
type-1 completion rule. Twelve unresolved errors leave finite empirical
limits when all other errors and the source estimate/SE are finite. This
describes the calculation, not a threshold establishing accurate
coverage. If the unresolved fraction remains above the nominal tail
probability, a larger run still has unbounded limits. Inspect causes in
`$trials` before committing to more refits; do not discard unresolved
draws.

## References

Chatterjee, S., Lahiri, P. and Li, H. (2008). Parametric bootstrap
approximation to the distribution of EBLUP and related prediction
intervals in linear mixed models. *Annals of Statistics*, 36, 1221–1245.
[doi:10.1214/07-AOS512](https://doi.org/10.1214/07-AOS512) .

## See also

[`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md),
[`plot.mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_random_rater_intervals.md)

## Examples

``` r
example <- readRDS(system.file("examples", "extended-models.rds", package = "mfrmr"))
fit <- example$random_rater$fit
intervals <- example$random_rater$intervals
# To regenerate (requires RTMB >= 2.0 and repeated model fitting):
# intervals <- mfrm_random_rater_intervals(fit, nsim = 19, seed = 923701)
# These 19 saved trials illustrate mechanics, not accurate 2.5% tails.
# Every trial is retained; unresolved trials can give unbounded intervals.
summary(intervals)
#> $intervals
#>     Lower Upper
#> R01  -Inf   Inf
#> R02  -Inf   Inf
#> R03  -Inf   Inf
#> R04  -Inf   Inf
#> attr(,"availability")
#>     Rater Planned Known Unresolved Finite
#> R01   R01      19    17          2  FALSE
#> R02   R02      19    17          2  FALSE
#> R03   R03      19    17          2  FALSE
#> R04   R04      19    17          2  FALSE
#> attr(,"method")
#> [1] "studentized"
#> attr(,"level")
#> [1] 0.95
#> attr(,"expected_tail_draws")
#> [1] 0.475
#> attr(,"note")
#> [1] "Pointwise model-based bootstrap; unresolved roots widen limits, possibly to infinity. Coverage and Monte Carlo tail accuracy require separate assessment."
#> 
#> $availability
#>     Rater Planned Known Unresolved Finite
#> R01   R01      19    17          2  FALSE
#> R02   R02      19    17          2  FALSE
#> R03   R03      19    17          2  FALSE
#> R04   R04      19    17          2  FALSE
#> 
#> $trials
#>           Planned          FitReady EstimatedBoundary 
#>                19                18                 1 
#> 
#> $settings
#> $settings$nsim
#> [1] 19
#> 
#> $settings$seed
#> [1] 923701
#> 
#> $settings$replicate_seeds
#>  [1] 1289759734 1889042303   97805746  219806802 1816506017  464639873
#>  [7] 1916682954  487847372 1641835732   26525370 1507912874 1457296021
#> [13] 1325607976 1595872271 1288178159  782172590 1853828702 1266267398
#> [19] 1539409418
#> 
#> $settings$rng_kind
#> [1] "Mersenne-Twister" "Inversion"        "Rejection"       
#> 
#> $settings$person_sd
#> [1] 0.9686791
#> 
#> $settings$fixed_person_sd
#> NULL
#> 
#> $settings$level
#> [1] 0.95
#> 
#> $settings$target
#> [1] "Realized rater effects relative to the population mean"
#> 
#> $settings$sampling
#> [1] "New persons, shared raters and responses on analyzed rows"
#> 
#> $settings$quantile_type
#> [1] 1
#> 
#> 
confint(intervals, method = "error")
#>     Lower Upper
#> R01  -Inf   Inf
#> R02  -Inf   Inf
#> R03  -Inf   Inf
#> R04  -Inf   Inf
#> attr(,"availability")
#>     Rater Planned Known Unresolved Finite
#> R01   R01      19    18          1  FALSE
#> R02   R02      19    18          1  FALSE
#> R03   R03      19    18          1  FALSE
#> R04   R04      19    18          1  FALSE
#> attr(,"method")
#> [1] "error"
#> attr(,"level")
#> [1] 0.95
#> attr(,"expected_tail_draws")
#> [1] 0.475
#> attr(,"note")
#> [1] "Pointwise model-based bootstrap; unresolved roots widen limits, possibly to infinity. Coverage and Monte Carlo tail accuracy require separate assessment."
# Changing the level reuses the same draws, with no further fitting:
confint(intervals, level = .90)
#>     Lower Upper
#> R01  -Inf   Inf
#> R02  -Inf   Inf
#> R03  -Inf   Inf
#> R04  -Inf   Inf
#> attr(,"availability")
#>     Rater Planned Known Unresolved Finite
#> R01   R01      19    17          2  FALSE
#> R02   R02      19    17          2  FALSE
#> R03   R03      19    17          2  FALSE
#> R04   R04      19    17          2  FALSE
#> attr(,"method")
#> [1] "studentized"
#> attr(,"level")
#> [1] 0.9
#> attr(,"expected_tail_draws")
#> [1] 0.95
#> attr(,"note")
#> [1] "Pointwise model-based bootstrap; unresolved roots widen limits, possibly to infinity. Coverage and Monte Carlo tail accuracy require separate assessment."
```
