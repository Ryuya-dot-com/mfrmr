# Extract coefficients, covariance, likelihood and observation counts

Standard R accessors for native many-facet fits. They retain the
estimator's coordinates and limitations; extracting a number does not
qualify inference.

Describe the retained ratings at the fitted calibration and saved Person
estimates, without fitting, scoring Persons again or computing
covariance.

Returns all facet-level estimates (person and others) in a single tidy
data.frame. Person rows retain their original identifiers; review or
transform them before writing the result outside a controlled analysis
environment.

These methods inspect the separate result returned by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
with `method = "JML", jml_penalty = "jeffreys"`. The result does not
inherit ordinary JML uncertainty or FACETS diagnostics.

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

# S3 method for class 'mfrm_fit'
fitted(object, type = c("response", "prob"), ...)

# S3 method for class 'mfrm_fit'
residuals(object, type = c("response", "pearson"), ...)

# S3 method for class 'mfrm_fit'
predict(object, newdata = NULL, type = c("response", "prob"), ...)

# S3 method for class 'mfrm_cml_fit'
fitted(object, type = c("response", "prob"), ...)

# S3 method for class 'mfrm_comparison_fit'
fitted(object, type = c("response", "prob"), ...)

# S3 method for class 'mfrm_cml_fit'
residuals(object, type = c("response", "pearson"), ...)

# S3 method for class 'mfrm_comparison_fit'
residuals(object, type = c("response", "pearson"), ...)

# S3 method for class 'mfrm_cml_fit'
predict(object, newdata = NULL, type = c("response", "prob"), ...)

# S3 method for class 'mfrm_comparison_fit'
predict(object, newdata = NULL, type = c("response", "prob"), ...)

# S3 method for class 'mfrm_fit'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'mfrm_cml_fit'
vcov(object, ...)

# S3 method for class 'mfrm_cml_fit'
logLik(object, ...)

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

- object:

  A `mfrm_jeffreys_fit` result.

- type:

  For [`fitted()`](https://rdrr.io/r/stats/fitted.values.html) and
  [`predict()`](https://rdrr.io/r/stats/predict.html), `"response"`
  returns expected ratings and `"prob"` category probabilities. For
  [`residuals()`](https://rdrr.io/r/stats/residuals.html), `"response"`
  returns observed minus expected ratings and `"pearson"` divides that
  difference by the conditional rating SD.

- ...:

  Unused; additional arguments are rejected.

- k:

  Penalty per free parameter for single-fit
  [`AIC()`](https://rdrr.io/r/stats/AIC.html); default 2.

- newdata:

  Must be `NULL`. These methods describe retained source responses only.
  For ability scoring from supplied responses use
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  or
  [`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md);
  those return Person abilities, not predicted rating values.
  [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  supplies conditional source-Person scoring for its documented model
  scope.

- x:

  A `mfrm_jeffreys_fit` result.

- row.names:

  Ignored (included for S3 generic compatibility).

- optional:

  Ignored (included for S3 generic compatibility).

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

A named numeric vector, or for `type = "prob"` a numeric matrix with one
column per modeled category. Attributes include `rows`, `identifiers`,
`score_map`, `diagnostics` (availability, conditional variance and
reason), `settings` (quantity, target, Person basis and limitations) and
`source_readiness`. `predict(fit)` and `fitted(fit)` return the same
source-rating target.

A data.frame with columns `Facet`, `Level`, `Estimate`, and `Extreme`.
The `Extreme` column is populated for person rows from the extreme-score
flag (`"Min"` / `"Max"` / `NA`); non-person facet rows carry `NA` in
that column by design. Corrected-JML fits additionally retain estimator,
correction order, point/covariance status, uncertainty target and
structural `RootSE` columns. Person `RootSE` is missing; extreme Person
flags are `"low"` / `"high"` / `"none"`. The `estimation_note` attribute
explains the local-root uncertainty and remaining bias. Ordinary
diagnostic attachments do not apply to this estimator; see the Corrected
JML section of
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md).

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
[`confint.mfrm_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md).

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
component extraction preserves infinite or missing values in the
selected column.

**GPCM slope columns.** `coef(fit, type = "slopes")` returns the saved
`fit$slopes$Estimate`, which retains working values for compatibility;
it does not select `PrimaryEstimate` or attach status columns. Read
`fit$slopes` before reporting: `PrimaryEstimate` is the target's primary
value under `ParameterStatus` and `PrimaryEstimateBasis`, whereas
`OptimizerEstimate` records the numerical value even when no primary
estimate is available. The distinction matters at boundaries and for
limiting fits. Neither a finite working value nor an available primary
value establishes interval eligibility. See
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md).

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
error rules. For two-family GPCM, the checked covariance includes free
location, step and log-slope coordinates. Use
`confint(fit, parm = "steps")` for separately checked intervals for the
expanded step offsets. Dependent centered steps require their constraint
transformation; diagonal entries alone do not describe all displayed
steps. Nominal coverage across designs has not been established; see
[mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md).
RSM/PCM singleton-category fits can pass the interval-specific
information review while retaining `InferenceReady = FALSE`; returned
`cautions` and checks explain the small-sample limitation. No count
label alone certifies or invalidates this covariance. No JML
structural-truth covariance is supplied. CML
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

For CML, adding extreme-score Persons can increase BIC's penalty even
when the conditional likelihood is unchanged. Report both total and
informative Person counts. A sensitivity calculation using the latter is
`-2 * as.numeric(ll) + attr(ll, "df") * log(attr(ll, "informative_persons"))`,
where `ll <- logLik(fit)` and the informative count is positive. Label
this as an alternative penalty convention, not the package's BIC or a
validated model-selection rule; neither count resolves dependence or
sparse-design asymptotics. Keep the same retained data and conditioning
basis in comparisons.

**Target.** Probabilities are evaluated at saved primary Person
estimates: MML uses the saved EAP, while JML uses its primary point
estimate. Thus `fitted(fit)` is a conditional plug-in expectation.
Evaluating probabilities at an EAP is different from averaging
probabilities over a posterior. For the latter target, use
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
within its stated model/design scope. These methods do not change
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
or its legacy diagnostic conventions. Legacy diagnostic helpers use
finite JML optimizer proxies and omit variances at or below `1e-10`; the
primary boundary limits and small positive variances here can therefore
give different residuals. Their observation tables retain
`PersonMeasureBasis`, `PrimaryPersonMeasure`, `ConditionalVariance` and
`ResponseReason` to explain these differences. Do not assume the routes
agree at these limits.

For model-score categories \\k\\, let \\p\_{ik}\\ be the conditional
probability. The mean is \\\mu_i=\sum_k k p\_{ik}\\, the variance is
\\V_i=\sum_k (k-\mu_i)^2p\_{ik}\\, and the Pearson residual is
\\(y_i-\mu_i)/\sqrt{V_i}\\. Rating weights affect estimation but are not
multiplied into these per-rating residuals or probabilities. The
variance has no artificial positive floor. A zero variance leaves the
mean/raw residual available but the Pearson residual missing, with a
reason.

A positive/negative infinite JML Person estimate with finite structural
calibration has limiting probability one at the maximum/minimum
category. These limits use the primary estimate, not the finite
optimizer proxy. Other unavailable Person estimates leave the
corresponding rows missing. Nonfinite structural estimates, corrected or
penalized fits, two-family GPCM, imported fits, CML and comparison-only
fits are explicitly refused. CML eliminates Person abilities and does
not supply this plug-in target. The supported posterior or corrected-JML
routes remain available through
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md).

**Rows and scale.** Output order is `fit$prep$data` order, including
repeated rating events, and excludes records omitted before fitting.
Vector names and probability-matrix row names are retained-row
positions. The `rows` attribute records these positions and original
input-row positions where retained metadata permit recovery; unknown
positions are `NA`. No response is silently added or dropped during
extraction. The separate `identifiers` attribute retains Person/facet
columns in the same order, including user-supplied facet names that
coincide with `Row`.

Values use the modeled score scale (`InternalScore` in `score_map`), as
in ordinary plug-in diagnostics. With collapsed categories this differs
from the original score labels. The saved `score_map` attribute retains
that mapping; probability columns name the modeled categories. Inspect
the map before comparing fitted values with an original, unrecoded data
column.

**Interpretation.** These same-data summaries hold calibration and
Person estimates fixed. They omit their estimation uncertainty and are
not held-out forecasts, calibrated goodness-of-fit tests or evidence of
rater quality. Point calculation does not establish convergence or
inference readiness. Read `source_readiness` and row-specific
`diagnostics` before interpreting values, and keep these attributes when
saving the result.

`Facet` and `Level` jointly identify a row; `Facet = "Person"`
identifies ability estimates. Use both keys when joining diagnostics:
the same level label can occur in different facets. This compact table
omits uncertainty and estimate-use restrictions; retain the source fit
and read `summary(fit)`.

See
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for the penalty, assumptions and restrictions. `checks$ordinary_nll` is
the ordinary negative log likelihood evaluated at the penalized point;
`checks$objective` also includes the information penalty. Neither is an
ordinary maximized likelihood for AIC or testing. `category_support`
describes observed category usage, including missing categories; its
ordinary-MLE warnings are not penalty-rank diagnostics.

## Interpreting estimates

`Estimate` is on the fitted latent scale, not the raw rating scale. With
default orientation, larger Person values indicate higher ability,
larger Rater values greater severity, and larger task/criterion values
greater difficulty. Non-Person facets in `positive_facets` have the
opposite score direction. Interpret values relative to the fitted
centering/anchors; zero is a scale reference, not absence of ability or
severity.

In an additive RSM/PCM with default signs, a Rater difference of 0.5
lowers adjacent-category odds by a factor `exp(-0.5)` for the same
Person and other facet levels. It does not subtract 0.5 raw-score
points. GPCM slopes and fitted interactions modify that comparison; use
`predict.mfrm_fit()` for response-scale predictions at specified facet
combinations.

Person `Estimate` is an EAP under MML, conditional on fitted calibration
and the specified population model; under ordinary JML it is the fitted
Person parameter. EAP shrinkage affects the spread of these estimates,
so their empirical SD is not the fitted population SD. `Extreme`
describes observed all-minimum/all-maximum scores, not a statistical
outlier test. An extreme score need not give an infinite MML EAP. For
uncertainty use
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
and, for supported structural contrasts,
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md);
a missing interval does not erase an available point.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
mfrm_fit_responses,
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

mfrm_fit_extractors,
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

[`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`export_mfrm_tables`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_tables.md)

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
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 31, maxit = 500)
expected <- fitted(fit) # Expected ratings at saved EAP abilities
head(data.frame(Observed = fit$prep$data$Score, Expected = as.numeric(expected),
  Residual = as.numeric(residuals(fit))))
#>   Observed Expected   Residual
#> 1        3 3.250516 -0.2505157
#> 2        3 3.602067 -0.6020673
#> 3        4 3.479859  0.5201412
#> 4        3 3.342825 -0.3428250
#> 5        2 3.342825 -1.3428250
#> 6        3 2.011682  0.9883180
head(attr(expected, "diagnostics")) # Check unavailable and zero-variance rows
#>   Row ProbabilityAvailable PearsonAvailable  Variance           Status
#> 1   1                 TRUE             TRUE 0.5228537 available_plugin
#> 2   2                 TRUE             TRUE 0.3291720 available_plugin
#> 3   3                 TRUE             TRUE 0.4057018 available_plugin
#> 4   4                 TRUE             TRUE 0.4796505 available_plugin
#> 5   5                 TRUE             TRUE 0.4796505 available_plugin
#> 6   6                 TRUE             TRUE 0.6362030 available_plugin
#>                                                                            Reason
#> 1 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 2 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 3 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 4 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 5 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 6 Conditional point calculation; calibration and Person uncertainty are excluded.
attr(expected, "settings")         # Read the target and interpretation limits
#> $target
#> [1] "Conditional plug-in source ratings"
#> 
#> $quantity
#> [1] "expected rating"
#> 
#> $person_basis
#> [1] "saved EAP"
#> 
#> $score_scale
#> [1] "modeled categories"
#> 
#> $calibration_uncertainty
#> [1] FALSE
#> 
#> $limitation
#> [1] "Same-data descriptive values; no convergence, goodness-of-fit, forecast or coverage guarantee."
#> 
head(fitted(fit, type = "prob"))    # One column per modeled score category
#>             1          2         3          4
#> 1 0.012010114 0.13151772 0.4504185 0.40605370
#> 2 0.001598065 0.04000066 0.3131372 0.64526411
#> 3 0.003727337 0.06687172 0.3752157 0.55418523
#> 4 0.007867801 0.10357384 0.4264239 0.46213446
#> 5 0.007867801 0.10357384 0.4264239 0.46213446
#> 6 0.281447865 0.45630310 0.2313682 0.03088085
# Optional workflow; run the example explicitly as shown below.
# example("as.data.frame.mfrm_fit", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Extract estimates and select the rows to display
estimates <- as.data.frame(fit)
head(subset(estimates, Facet == "Person")) # First six persons
subset(estimates, Facet == "Rater")       # All raters
subset(estimates, Facet == "Criterion")   # All criteria
} # }
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
