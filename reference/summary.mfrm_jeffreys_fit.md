# Inspect a Jeffreys-penalized fit

These methods inspect the separate result returned by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
with `method = "JML", jml_penalty = "jeffreys"`. The result does not
inherit ordinary JML uncertainty or FACETS diagnostics.

## Usage

``` r
# S3 method for class 'mfrm_jeffreys_fit'
summary(object, ...)

# S3 method for class 'mfrm_jeffreys_fit'
print(x, ...)

# S3 method for class 'mfrm_jeffreys_fit'
coef(object, ...)

# S3 method for class 'mfrm_jeffreys_fit'
fitted(object, ...)

# S3 method for class 'mfrm_jeffreys_fit'
vcov(object, ...)

# S3 method for class 'mfrm_jeffreys_fit'
confint(object, ...)

# S3 method for class 'mfrm_jeffreys_fit'
logLik(object, ...)
```

## Arguments

- object, x:

  A `mfrm_jeffreys_fit` result.

- ...:

  Unused; additional arguments are rejected.

## Value

[`summary()`](https://rdrr.io/r/base/summary.html) returns Person, facet
and step point-estimate tables, checks, category-support evidence and
notes. [`coef()`](https://rdrr.io/r/stats/coef.html) returns the three
point-estimate tables.
[`fitted()`](https://rdrr.io/r/stats/fitted.values.html) returns
category probabilities in prepared response-row order, with columns from
`rating_min` to `rating_max`.
[`print()`](https://rdrr.io/r/base/print.html) displays the estimator
and numerical status. [`vcov()`](https://rdrr.io/r/stats/vcov.html),
[`confint()`](https://rdrr.io/r/stats/confint.html) and
[`logLik()`](https://rdrr.io/r/stats/logLik.html) on this fit stop
explicitly: parameter uncertainty and likelihood-based model comparison
are not implemented. To estimate common-plan expected-score intervals,
use
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
followed by
[`confint.mfrm_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fair_average.md).

## Details

See
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for the penalty, assumptions and restrictions. `checks$ordinary_nll` is
the ordinary negative log likelihood evaluated at the penalized point;
`checks$objective` also includes the information penalty. Neither is an
ordinary maximized likelihood for AIC or testing. `category_support`
describes observed category usage, including missing categories; its
ordinary-MLE warnings are not penalty-rank diagnostics.

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
# Each row is one Person's rating by a Rater on a Criterion.
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", jml_penalty = "jeffreys", rating_min = 1, rating_max = 4,
  category_policy = "preserve")
summary(fit)$persons # Finite penalized Person points, without SEs
#>    Person    Estimate PrimaryEstimate
#> 1    P001  0.62892988      0.62892988
#> 2    P002  1.54091106      1.54091106
#> 3    P003  1.15811858      1.15811858
#> 4    P004  0.82948467      0.82948467
#> 5    P005  0.82948467      0.82948467
#> 6    P006 -1.40431066     -1.40431066
#> 7    P007  0.82948467      0.82948467
#> 8    P008 -1.53543132     -1.53543132
#> 9    P009 -0.84692262     -0.84692262
#> 10   P010  0.62892988      0.62892988
#> 11   P011  0.25403786      0.25403786
#> 12   P012  0.07396471      0.07396471
#> 13   P013  0.53253690      0.53253690
#> 14   P014  1.15811858      1.15811858
#> 15   P015 -2.00369537     -2.00369537
#> 16   P016 -0.10435286     -0.10435286
#> 17   P017  0.16364309      0.16364309
#> 18   P018 -0.19354172     -0.19354172
#> 19   P019  0.93466618      0.93466618
#> 20   P020 -0.37338828     -0.37338828
#> 21   P021  0.43816437      0.43816437
#> 22   P022 -0.94905294     -0.94905294
#> 23   P023  2.46002873      2.46002873
#> 24   P024  2.02465323      2.02465323
#> 25   P025  0.82948467      0.82948467
#> 26   P026 -1.40431066     -1.40431066
#> 27   P027 -0.19354172     -0.19354172
#> 28   P028 -0.37338828     -0.37338828
#> 29   P029  0.07396471      0.07396471
#> 30   P030  0.25403786      0.25403786
#> 31   P031  0.72775544      0.72775544
#> 32   P032 -0.94905294     -0.94905294
#> 33   P033 -0.65152702     -0.65152702
#> 34   P034 -0.37338828     -0.37338828
#> 35   P035  0.07396471      0.07396471
#> 36   P036  1.68729754      1.68729754
#> 37   P037  0.07396471      0.07396471
#> 38   P038 -0.74793035     -0.74793035
#> 39   P039 -0.01527520     -0.01527520
#> 40   P040 -0.94905294     -0.94905294
#> 41   P041 -1.16547186     -1.16547186
#> 42   P042  0.72775544      0.72775544
#> 43   P043 -0.55723761     -0.55723761
#> 44   P044  0.72775544      0.72775544
#> 45   P045 -1.67694521     -1.67694521
#> 46   P046 -1.40431066     -1.40431066
#> 47   P047 -1.16547186     -1.16547186
#> 48   P048 -0.65152702     -0.65152702
summary(fit)$checks$max_gradient # Penalized score-equation diagnostic
#> [1] 5.615066e-06
plan <- unique(ratings[c("Rater", "Criterion")])
scores <- fair_average_table(fit, reference_plan = plan)
scores$reference_scores # Expected averages under the same plan for all Persons
#>    Person Estimate         Status                       Target          Units
#> 1    P001 2.928024 point_estimate common_plan_expected_average internal_score
#> 2    P002 3.418372 point_estimate common_plan_expected_average internal_score
#> 3    P003 3.234450 point_estimate common_plan_expected_average internal_score
#> 4    P004 3.050576 point_estimate common_plan_expected_average internal_score
#> 5    P005 3.050576 point_estimate common_plan_expected_average internal_score
#> 6    P006 1.643494 point_estimate common_plan_expected_average internal_score
#> 7    P007 3.050576 point_estimate common_plan_expected_average internal_score
#> 8    P008 1.582339 point_estimate common_plan_expected_average internal_score
#> 9    P009 1.949067 point_estimate common_plan_expected_average internal_score
#> 10   P010 2.928024 point_estimate common_plan_expected_average internal_score
#> 11   P011 2.683010 point_estimate common_plan_expected_average internal_score
#> 12   P012 2.560562 point_estimate common_plan_expected_average internal_score
#> 13   P013 2.866758 point_estimate common_plan_expected_average internal_score
#> 14   P014 3.234450 point_estimate common_plan_expected_average internal_score
#> 15   P015 1.398714 point_estimate common_plan_expected_average internal_score
#> 16   P016 2.438163 point_estimate common_plan_expected_average internal_score
#> 17   P017 2.621781 point_estimate common_plan_expected_average internal_score
#> 18   P018 2.376984 point_estimate common_plan_expected_average internal_score
#> 19   P019 3.111861 point_estimate common_plan_expected_average internal_score
#> 20   P020 2.254666 point_estimate common_plan_expected_average internal_score
#> 21   P021 2.805501 point_estimate common_plan_expected_average internal_score
#> 22   P022 1.887965 point_estimate common_plan_expected_average internal_score
#> 23   P023 3.724877 point_estimate common_plan_expected_average internal_score
#> 24   P024 3.602306 point_estimate common_plan_expected_average internal_score
#> 25   P025 3.050576 point_estimate common_plan_expected_average internal_score
#> 26   P026 1.643494 point_estimate common_plan_expected_average internal_score
#> 27   P027 2.376984 point_estimate common_plan_expected_average internal_score
#> 28   P028 2.254666 point_estimate common_plan_expected_average internal_score
#> 29   P029 2.560562 point_estimate common_plan_expected_average internal_score
#> 30   P030 2.683010 point_estimate common_plan_expected_average internal_score
#> 31   P031 2.989297 point_estimate common_plan_expected_average internal_score
#> 32   P032 1.887965 point_estimate common_plan_expected_average internal_score
#> 33   P033 2.071282 point_estimate common_plan_expected_average internal_score
#> 34   P034 2.254666 point_estimate common_plan_expected_average internal_score
#> 35   P035 2.560562 point_estimate common_plan_expected_average internal_score
#> 36   P036 3.479686 point_estimate common_plan_expected_average internal_score
#> 37   P037 2.560562 point_estimate common_plan_expected_average internal_score
#> 38   P038 2.010172 point_estimate common_plan_expected_average internal_score
#> 39   P039 2.499356 point_estimate common_plan_expected_average internal_score
#> 40   P040 1.887965 point_estimate common_plan_expected_average internal_score
#> 41   P041 1.765750 point_estimate common_plan_expected_average internal_score
#> 42   P042 2.989297 point_estimate common_plan_expected_average internal_score
#> 43   P043 2.132399 point_estimate common_plan_expected_average internal_score
#> 44   P044 2.989297 point_estimate common_plan_expected_average internal_score
#> 45   P045 1.521160 point_estimate common_plan_expected_average internal_score
#> 46   P046 1.643494 point_estimate common_plan_expected_average internal_score
#> 47   P047 1.765750 point_estimate common_plan_expected_average internal_score
#> 48   P048 2.071282 point_estimate common_plan_expected_average internal_score
#>     Uncertainty
#> 1  not_computed
#> 2  not_computed
#> 3  not_computed
#> 4  not_computed
#> 5  not_computed
#> 6  not_computed
#> 7  not_computed
#> 8  not_computed
#> 9  not_computed
#> 10 not_computed
#> 11 not_computed
#> 12 not_computed
#> 13 not_computed
#> 14 not_computed
#> 15 not_computed
#> 16 not_computed
#> 17 not_computed
#> 18 not_computed
#> 19 not_computed
#> 20 not_computed
#> 21 not_computed
#> 22 not_computed
#> 23 not_computed
#> 24 not_computed
#> 25 not_computed
#> 26 not_computed
#> 27 not_computed
#> 28 not_computed
#> 29 not_computed
#> 30 not_computed
#> 31 not_computed
#> 32 not_computed
#> 33 not_computed
#> 34 not_computed
#> 35 not_computed
#> 36 not_computed
#> 37 not_computed
#> 38 not_computed
#> 39 not_computed
#> 40 not_computed
#> 41 not_computed
#> 42 not_computed
#> 43 not_computed
#> 44 not_computed
#> 45 not_computed
#> 46 not_computed
#> 47 not_computed
#> 48 not_computed
intervals <- confint(scores, parm = c("P001", "P002"), method = "delta")
intervals[, c("Target", "Estimate", "SE", "Available", "CIEligible")]
#> Common-plan expected-score intervals (experimental)
#>   Target Estimate        SE Available CIEligible
#> 1   P001 2.928024 0.1942444      TRUE      FALSE
#> 2   P002 3.418372 0.1619385      TRUE      FALSE
#> Numerical availability is separate from coverage qualification.
# Numerical availability is not a qualification of small-sample coverage.
```
