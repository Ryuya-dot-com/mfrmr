# Extract fitted rating values and residuals

Describe the retained ratings at the fitted calibration and saved Person
estimates, without fitting, scoring Persons again or computing
covariance.

## Usage

``` r
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
```

## Arguments

- object:

  A native ordinary RSM/PCM or one-family GPCM fit from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  estimated by MML or uncorrected JML.

- type:

  For [`fitted()`](https://rdrr.io/r/stats/fitted.values.html) and
  [`predict()`](https://rdrr.io/r/stats/predict.html), `"response"`
  returns expected ratings and `"prob"` category probabilities. For
  [`residuals()`](https://rdrr.io/r/stats/residuals.html), `"response"`
  returns observed minus expected ratings and `"pearson"` divides that
  difference by the conditional rating SD.

- ...:

  Unused; additional arguments are rejected. Prediction intervals,
  standard errors, new rating designs and missing-score imputation are
  not supplied by these methods.

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

## Value

A named numeric vector, or for `type = "prob"` a numeric matrix with one
column per modeled category. Attributes include `rows`, `identifiers`,
`score_map`, `diagnostics` (availability, conditional variance and
reason), `settings` (quantity, target, Person basis and limitations) and
`source_readiness`. `predict(fit)` and `fitted(fit)` return the same
source-rating target.

## Details

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

## See also

[mfrm_fit_extractors](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
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
```
