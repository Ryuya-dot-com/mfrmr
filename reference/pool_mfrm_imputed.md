# Pool common facet targets across imputed rating analyses

Combine results such as rater severity or a prespecified difference
between raters across completed-data fits. Rubin's rules include
uncertainty within each fit and variation between imputations. The
calculation uses the full covariance for one non-Person facet; it does
not pool Person ability scores.

## Usage

``` r
pool_mfrm_imputed(
  x,
  facet,
  contrasts = NULL,
  ci_level = 0.95,
  df_complete = Inf
)

# S3 method for class 'mfrm_pooled'
print(x, ...)

# S3 method for class 'mfrm_pooled'
summary(object, ...)
```

## Arguments

- x:

  Output from
  [`fit_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_imputed.md).
  All completions must have inference-ready RSM/PCM MML fits and
  unregularized observed information.

- facet:

  A non-person facet column name, for example `"Rater"`.

- contrasts:

  Optional numeric matrix with one named row per target and columns
  named by all facet levels. For example, a row with coefficients
  `c(1, -1, 0)` estimates the first rater minus the second. Without it,
  each facet level is reported. Columns are aligned by level, not
  position.

- ci_level:

  Confidence level, strictly between zero and one.

- df_complete:

  Complete-data degrees of freedom, a positive number or `Inf`
  (default). `Inf` uses the large-sample complete-data approximation. A
  finite value applies the Barnard–Rubin adjustment. No residual degrees
  of freedom are inferred from rating-row counts: ratings within a
  person are not independent sampling units. A supplied finite value
  requires a defensible complete-data reference distribution for the
  chosen target.

- ...:

  Unused.

- object:

  An object returned by `pool_mfrm_imputed()`.

## Value

An `mfrm_pooled` object containing `table`, `within`, `between` and
`total` covariance matrices, `estimates` by imputation, each
`complete_covariance`, the exact `contrasts`, `facet_levels`, `settings`
and source `analyses`. `MonteCarloSE` is the estimated Monte Carlo SE of
the pooled point estimate, `sqrt(B / m)`; it is not its inferential SE.
`MissingVarianceFraction` is `(1 + 1/m) B / T`, not the raw
missing-rate. Fixed targets retain their value and zero variance, but no
inferential interval or degrees of freedom. No imputation is omitted.

## Details

For a common target, `Qbar` is the mean completed-data estimate, `Ubar`
the mean complete-data covariance and `B` their between-imputation
covariance. The total is `T = Ubar + (1 + 1/m) B`. The scalar
t-reference degrees of freedom are `(m - 1) / lambda^2`, with
`lambda = (1 + 1/m) B / T`, before any finite complete-data adjustment.
A zero between-imputation variance has infinite large-sample degrees of
freedom. Full covariances are transformed before scalar inference, so
rater differences include covariance between the two estimates.

All fits must share categories, facet levels, signs, anchors,
interactions and identification. Known anchors are fixed and their
uncertainty is excluded. Singular or regularized free-parameter
information and any failed/ineligible completion prevent pooling. A
target fixed by a constraint is labelled `"fixed"`; it is not evidence
of perfect precision.

The intervals are pointwise model-based multiple-imputation intervals,
conditional on adequate proper imputations and complete-data inference.
They are not robust intervals, simultaneous rater decisions or general
coverage guarantees. Do not pool EAPs, posterior SDs, fit statistics,
cluster labels or likelihood-ratio tests with this function. See the
executable assigned-score example in
[`vignette("mfrmr-response-imputation")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-response-imputation.md).
It compares joint RSM predictive completions with direct observed-score
inference. Proper calibration priors in the imputer and MML estimates in
the completed-data analyses do not give exactly identical Bayesian
moments: that interpretation is a large-sample approximation requiring
review.

Congeniality concerns the imputation distribution and the complete-data
analysis together, including its variance estimator. Preserving
categories or including coefficient uncertainty in an ordinal imputer
does not prove congeniality with an adjacent-category MFRM. Under
incompatibility or model misspecification, Rubin intervals can be too
narrow or too wide. Bootstrapping only the imputation-model training
data, then completing and analyzing the original roster, is not
bootstrap inference for the whole MI analysis. Bartlett and Hughes
(2020) study the latter; their results require conditions including a
consistent point estimator and appropriate resampling units. This
function implements Rubin pooling, not that outer bootstrap procedure.

## Bounded evaluation

A joint-RSM imputation example was examined using 200 independent
datasets, each analyzed with MAR and low-score-dependent MNAR
missingness. The design had 80 Persons, three fixed raters, two
criteria, scores 0–2, forty completions and a correctly specified known
N(0,1) Person distribution. Under MAR, fixed-rater contrast coverage was
96.5 percent among 198 available nominal 95 percent intervals (95
percent Monte Carlo bounds 92.9–98.6). Two imputation posteriors missed
the sampling-diagnostic threshold; counting them as unsuccessful gives
191/200 available-and-covered trials (95.5 percent). Under MNAR,
coverage was 26.0 percent (Monte Carlo bounds 20.1–32.7) and bias was
+0.574 logits, although both missing fractions were near 14 percent. The
MAR imputer cannot correct selection depending on missing scores. These
results concern that imputer, contrast and design, not arbitrary
supplied completions or general coverage. See the assigned-score
vignette for direct-MML/Bayesian comparisons, interval widths and
failure accounting.

## References

Rubin, D. B. (1987). *Multiple Imputation for Nonresponse in Surveys*.
Wiley. Barnard, J. and Rubin, D. B. (1999). Small-sample degrees of
freedom with multiple imputation. *Biometrika*, 86, 948–955.
[doi:10.1093/biomet/86.4.948](https://doi.org/10.1093/biomet/86.4.948) .

Bartlett, J. W. and Hughes, R. A. (2020). Bootstrap inference for
multiple imputation under uncongeniality and misspecification.
*Statistical Methods in Medical Research*, 29, 3533–3546.
[doi:10.1177/0962280220932189](https://doi.org/10.1177/0962280220932189)
.

## See also

[`mice::pool.scalar()`](https://amices.org/mice/reference/pool.scalar.html),
[`mfrm_response_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md),
[`fit_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_imputed.md)
