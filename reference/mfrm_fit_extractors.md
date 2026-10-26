# Extract coefficients, covariance, likelihood and observation counts

Standard R accessors for native many-facet fits. They retain the
estimator's coordinates and limitations; extracting a number does not
qualify inference.

## Usage

``` r
# S3 method for class 'mfrm_fit'
coef(object, type = c("free", "locations", "steps", "slopes", "persons"), ...)

# S3 method for class 'mfrm_cml_fit'
coef(object, type = c("free", "locations", "steps", "slopes", "persons"), ...)

# S3 method for class 'mfrm_comparison_fit'
coef(object, ...)

# S3 method for class 'mfrm_fit'
vcov(object, ...)

# S3 method for class 'mfrm_comparison_fit'
vcov(object, ...)

# S3 method for class 'mfrm_fit'
nobs(object, type = c("likelihood", "persons", "ratings"), ...)

# S3 method for class 'mfrm_cml_fit'
nobs(object, type = c("likelihood", "persons", "ratings"), ...)

# S3 method for class 'mfrm_comparison_fit'
nobs(object, type = c("likelihood", "persons", "ratings"), ...)

# S3 method for class 'mfrm_fit'
logLik(object, ...)

# S3 method for class 'mfrm_comparison_fit'
logLik(object, ...)

# S3 method for class 'mfrm_fit'
AIC(object, ..., k = 2)

# S3 method for class 'mfrm_fit'
BIC(object, ...)

# S3 method for class 'mfrm_cml_fit'
AIC(object, ..., k = 2)

# S3 method for class 'mfrm_cml_fit'
BIC(object, ...)

# S3 method for class 'mfrm_cml_fit'
vcov(object, ...)

# S3 method for class 'mfrm_cml_fit'
logLik(object, ...)
```

## Arguments

- object:

  A native result from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Imported and extended-model results use their documented summaries and
  model-specific methods.

- type:

  For [`coef()`](https://rdrr.io/r/stats/coef.html), `"free"` (default)
  returns the independent fitted coordinates; `"locations"`, `"steps"`,
  `"slopes"` or `"persons"` returns the corresponding saved primary
  estimates. For [`nobs()`](https://rdrr.io/r/stats/nobs.html),
  `"likelihood"` (default) counts Persons for MML/CML and retained
  response rows for JML; `"persons"` and `"ratings"` request those
  counts explicitly.

- ...:

  Unused for coefficient, covariance, likelihood and count extraction;
  misspelled arguments are rejected. Multiple-model calls to
  [`AIC()`](https://rdrr.io/r/stats/AIC.html)/[`BIC()`](https://rdrr.io/r/stats/AIC.html)
  are refused: use
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  for supported comparisons with matched observations, estimation and
  integration settings.

- k:

  Penalty per free parameter for single-fit
  [`AIC()`](https://rdrr.io/r/stats/AIC.html); default 2.

## Value

[`coef()`](https://rdrr.io/r/stats/coef.html) returns a named numeric
vector; [`vcov()`](https://rdrr.io/r/stats/vcov.html) a matrix in the
matching default coordinates. MML covariance retains `checks`,
`numerical_checks`, `information_review` and `cautions` attributes when
supplied by the interval route.
[`logLik()`](https://rdrr.io/r/stats/logLik.html) returns a `logLik`
object; [`nobs()`](https://rdrr.io/r/stats/nobs.html) an integer count;
single-fit
[`AIC()`](https://rdrr.io/r/stats/AIC.html)/[`BIC()`](https://rdrr.io/r/stats/AIC.html)
a numeric value or `NA` when unsupported. Existing CML covariance
coordinates and numeric values are unchanged. No accessor silently
computes new Person scores.

## Details

**Coordinates.** The default `coef(fit)` is a named numeric vector
aligned with both dimensions of `vcov(fit)`. These are free coordinates,
not every displayed facet level: anchors and dependent centered
coordinates are omitted. MML/JML names such as `Rater[1]` identify
positions within parameter blocks, not literal level names. Steps are
free step offsets, slopes are log slopes, and estimated population
variance is on the log-variance scale. Population regression
coefficients remain on their fitted design scale. CML retains its
existing conditional-coordinate names. Use `type = "locations"` for all
saved facet locations with their level labels, and `summary(fit)` for
tables, readiness, constraints and interpretation. Location signs are
the fitted model's signs; this accessor does not reorient them as
severity. Default
[confint()](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
intervals use these same coordinates; GPCM positive-slope intervals
require explicit `parm = "slopes"`.

`type = "persons"` returns saved primary Person estimates: MML EAPs and
JML point estimates are different targets. Person posterior SDs are not
structural standard errors and do not occur in `vcov(fit)`. CML has no
Person estimates. Free-coordinate extraction refuses corrected or
penalized JML and any fit whose primary estimates are nonfinite: finite
optimizer proxies must not replace primary boundary values. Explicit
component extraction preserves the saved infinite or missing primary
estimates.

**Covariance.** MML [`vcov()`](https://rdrr.io/r/stats/vcov.html) reuses
the same qualified full joint covariance as
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
including its model/design restrictions and numerical checks. It may
reevaluate information and integration, but does not refit. An
ineligible source remains an error. For an otherwise eligible ordinary
fixed-population RSM/PCM fit, information failure returns an `NA` matrix
with `unavailable_reason`, `checks` and `cautions`; default
[`confint()`](https://rdrr.io/r/stats/confint.html) retains coefficient
estimates and reasons in its `diagnostics` attribute while bounds are
missing. No regularized inverse is substituted. If even one dense `NA`
matrix exceeds `mfrmr.max_information_bytes`,
[`vcov()`](https://rdrr.io/r/stats/vcov.html) errors with that reason;
use the smaller target-level
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
result. Other MML routes retain their separate qualification checks and
error rules. RSM/PCM singleton-category fits can pass the
interval-specific information review while retaining
`InferenceReady = FALSE`; returned `cautions` and checks explain the
small-sample limitation. No count label alone certifies or invalidates
this covariance. No JML structural-truth covariance is supplied. CML
[`vcov()`](https://rdrr.io/r/stats/vcov.html) reuses saved conditional
information. If CML's finite numerical point passed its identification,
finite-MLE and stationarity checks but information failed,
[`vcov()`](https://rdrr.io/r/stats/vcov.html) returns an `NA` matrix
with `unavailable_reason`, `checks` and `cautions` attributes.
[`coef()`](https://rdrr.io/r/stats/coef.html) and
[`logLik()`](https://rdrr.io/r/stats/logLik.html) still expose the
retained values; default
[`confint()`](https://rdrr.io/r/stats/confint.html) supplies missing
bounds with diagnostic reasons. The warning also limits confidence in
point accuracy along weak directions; no regularized covariance or
formal inference is substituted. Free-coordinate covariance is not the
covariance of a selected component vector or of all displayed levels;
use
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
or
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
for supported transformations. Comparison-only
[`coef()`](https://rdrr.io/r/stats/coef.html) returns the declared
contrast estimates, retaining unavailable rows as `NA`; its
[`vcov()`](https://rdrr.io/r/stats/vcov.html) is available only for
native CML conditional comparisons, with the same row/column order.

**Likelihood and counts.**
[`logLik()`](https://rdrr.io/r/stats/logLik.html) returns the retained
MML marginal or ordinary JML joint log likelihood, with
`likelihood_basis` and `ICReason` attributes. Nonunit weights give a
weighted objective, not an ordinary sampling likelihood. The `df`
attribute is the free parameter count only when the current
information-criterion contract and solution checks permit its use;
otherwise it is `NA`, so [`AIC()`](https://rdrr.io/r/stats/AIC.html) and
[`BIC()`](https://rdrr.io/r/stats/AIC.html) are also `NA`.
`parameter_count` retains the actual dimension separately. JML and
two-family GPCM do not gain information-criterion eligibility through
these accessors. Corrected JML, penalized objectives and comparison-only
fits do not supply a generic
[`logLik()`](https://rdrr.io/r/stats/logLik.html) here. For
estimated-population/one-family GPCM MML, likelihood qualification may
reevaluate solution information.

CML retains its conditional log likelihood and free dimension. Its
`nobs` attribute counts all retained Persons, including extreme totals
contributing zero conditional information; `informative_persons` records
nonextreme totals separately. This preserves the existing CML method and
is not a new validation of conditional information criteria. Conditional
and marginal likelihoods must not be compared. For MML, BIC uses
Persons, not rating rows or the sum of rating weights. Counts describe
the retained analysis, not omitted input records or an effective sample
size under dependence. Use `nobs(fit, type = "ratings")` to count
retained ratings.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
[mfrm_fit_responses](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_responses.md),
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 31, maxit = 500)
coef(fit, type = "locations") # Labelled facet locations, including constraints
#>              "Rater":"R01"              "Rater":"R02" 
#>                -0.18381527                -0.30884777 
#>              "Rater":"R03"              "Rater":"R04" 
#>                 0.17950268                 0.31316037 
#>     "Criterion":"Accuracy"      "Criterion":"Content" 
#>                 0.23363879                -0.38997303 
#>     "Criterion":"Language" "Criterion":"Organization" 
#>                 0.09146368                 0.06487055 
coef(fit)                     # Independent coordinates, including steps
#>     Rater[1]     Rater[2]     Rater[3] Criterion[1] Criterion[2] Criterion[3] 
#>  -0.18381527  -0.30884777   0.17950268   0.23363879  -0.38997303   0.09146368 
#>     steps[1]     steps[2] 
#>  -1.21981374  -0.05745669 
nobs(fit)                     # Persons contributing to marginal likelihood
#> [1] 48
nobs(fit, type = "ratings")    # Retained response rows
#> [1] 768
ll <- logLik(fit)
attr(ll, "ICReason")          # Read before interpreting AIC/BIC
#> [1] "Current MML likelihood and solution checks permit information criteria; model comparisons require matched sources."
AIC(fit)
#> [1] 1816.025
# When covariance is qualified, its names match the free coefficients:
# V <- vcov(fit); identical(rownames(V), names(coef(fit)))
```
