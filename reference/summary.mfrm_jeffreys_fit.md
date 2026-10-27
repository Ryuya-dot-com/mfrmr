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
# Long-running workflow; run explicitly when needed.
# example("summary.mfrm_jeffreys_fit", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_core")
# Each row is one Person's rating by a Rater on a Criterion.
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", jml_penalty = "jeffreys", rating_min = 1, rating_max = 4,
  category_policy = "preserve")
summary(fit)$persons # Finite penalized Person points, without SEs
summary(fit)$checks$max_gradient # Penalized score-equation diagnostic
plan <- unique(ratings[c("Rater", "Criterion")])
scores <- fair_average_table(fit, reference_plan = plan)
scores$reference_scores # Expected averages under the same plan for all Persons
intervals <- confint(scores, parm = c("P001", "P002"), method = "delta")
intervals[, c("Target", "Estimate", "SE", "Available", "CIEligible")]
# Numerical availability is not a qualification of small-sample coverage.
} # }
```
